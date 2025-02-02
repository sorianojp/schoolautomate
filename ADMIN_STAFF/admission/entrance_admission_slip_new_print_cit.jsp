<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Admission</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-size: 11px;
    }
</style>
</head>
<script language="javascript">
function PrintPage(){
	document.getElementById('header').deleteRow(5);
	window.print();	
}
</script>
<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,java.util.Vector,enrollment.CourseRequirement"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;	
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Registration","entrance_admission_slip_new_print_cit.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();

int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission","Registration",request.getRemoteAddr(),
														"entrance_admission_slip_new_print_cit.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}


//end of authenticaion code.
	String strTempID = WI.fillTextValue("temp_id");
	OfflineAdmission offlineAdd = new OfflineAdmission();
	Vector vRetResult = null;
	Vector vExamSchedules = null;	
	String strSYFrom = null;
	String strSYTo = null;
	String strSemester=null, strORNumber = null;
	String[] astrSemester = {"Summer", " 1st Semester ", "2nd Semester", "3rd Semester "};
	String[] astrPeriod = {"AM","PM"};
	
	String strTemp = dbOP.mapOneToOther("NEW_APPLICATION", "TEMP_ID", 
           "'"+strTempID+"'","TEMP_ID", "");
	if(strTemp == null)		
		strTemp = dbOP.mapOneToOther("user_table", "id_number", 
           "'"+strTempID+"'","id_number", "");

 	strTempID = strTemp;

	if (strTempID != null){		
		vRetResult = offlineAdd.createAdmissionSlipReq(dbOP,strTempID);
		if (vRetResult == null)
			strErrMsg = offlineAdd.getErrMsg();					
	    vExamSchedules = offlineAdd.getExamSchedules(dbOP,strTempID);		
		if (vExamSchedules == null)
			strErrMsg = offlineAdd.getErrMsg();					 			
	}
	else	    
		strErrMsg = "Invalid Temporary ID";

	if(vRetResult != null && vRetResult.size() > 0 && strTempID != null) {
		strSYFrom = (String)vRetResult.elementAt(0);
		strSYTo = (String)vRetResult.elementAt(1);
		strSemester = (String)vRetResult.elementAt(12);
		
		//check exception.. 
		strORNumber = "select TESTFEE_PERMIT_INDEX from CIT_TEMP_TESTFEE_PERMIT where STUD_INDEX = "+vRetResult.elementAt(16)+
					" and sy_from = "+strSYFrom+" and semester = "+strSemester+" and is_valid = 1 and is_temp_stud = 1";
		strORNumber = dbOP.getResultOfAQuery(strORNumber, 0);
		if(strORNumber == null) {//not exempted.
			//get or number here. 
			
			strTemp = (String)vRetResult.elementAt(2);
			if(strTemp.toLowerCase().indexOf("new") > -1 || strTemp.toLowerCase().indexOf("transferee") > -1)
				strTemp = "1";
			else
				strTemp = "0";
			
			strORNumber = "select or_number from fa_stud_payment where is_stud_temp = "+strTemp+" and is_valid = 1 and amount > 0 "+
				 " and user_index = "+vRetResult.elementAt(16) +" order by date_paid";
			strORNumber = dbOP.getResultOfAQuery(strORNumber, 0);
			
			if(strORNumber == null) {
				strErrMsg = "Payment information not found. Please proceed to accounting to pay testing fee.";
			}
		}
		else 
			strORNumber = "-- Payment Exempted --";
	}	
%>
<body bgcolor="#FFFFFF" onLoad="<%if(strErrMsg == null) {%>window.print()<%}%>">

<%if(strErrMsg != null){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="18"><font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
  </table>
<%}%>
<%if(strErrMsg == null){%>
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="2%" height="2">&nbsp;</td>
        <td width="98%" align="center">
		<font size="3">
			<strong><%=SchoolInformation.getSchoolName(dbOP,false,false)%></strong></font>
				<br>
			<font size="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>		</td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td align="center" style="font-weight:bold;">OFFICE OF ADMISSIONS AND SCHOLARSHIPS </td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td align="center" style="font-weight:bold;">&nbsp;</td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td>
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td width="43%">Student ID No&nbsp;&nbsp;&nbsp;&nbsp;: <b><%=strTempID%></b></td>
					<td width="41%">Term & SY: <b><%=astrSemester[Integer.parseInt(strSemester)]%>, <%=strSYFrom%>-<%=strSYTo%></b></td>
					<td width="16%" rowspan="4"><img src="../../temp_stud_upload_img/<%=strTempID%>.jpg" height="200" width="200" border="1"></td>
				</tr>
				<tr>
				  <td>Status&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: <b><%=WI.getStrValue((String)vRetResult.elementAt(2))%></b></td>
				  <td>Applied Course &amp; Year: <b><%=WI.getStrValue((String)vRetResult.elementAt(9))%><%=WI.getStrValue((String)vRetResult.elementAt(10),"(",")","")%> - <%=WI.getStrValue((String)vRetResult.elementAt(17), "N/A")%></b></td>
		      </tr>
				<tr valign="top">
				  <td>Name of Student: <b><%=WI.getStrValue((String)vRetResult.elementAt(7))%></b></td>
				  <td>OR. No.: <b><%=strORNumber%></b></td>
		      </tr>
				<tr valign="top">
				  <td colspan="2"><br>
				  
				  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr> 
      <td width="848" height="25" colspan="3">Schedule of Exam(s):</td>
      </tr>
    <tr> 
      <td height="15" colspan="3"> <table width="96%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr bgcolor="#FFFFFF"> 
            <td  class="thinborder" ><div align="center">ScheduleCode</div></td>
            <td class="thinborder"><div align="center">Subject</div></td>
            <td class="thinborder"><div align="center">Date of Exam</div></td>
            <td class="thinborder"><div align="center">Time</div></td>
            <td class="thinborder"><div align="center">Duration</div></td>
            <td class="thinborder"><div align="center">Venue</div></td>
          </tr>
          <% for(int iLoop = 0; iLoop < vExamSchedules.size() ;iLoop += 8 ){%>
          <tr bgcolor="#FFFFFF"> 
            <td class="thinborder" height="25"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)vExamSchedules.elementAt(iLoop)%></div></td>
            <td class="thinborder" height="25"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)vExamSchedules.elementAt(iLoop+1)%></div></td>
            <td class="thinborder" height="25"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)vExamSchedules.elementAt(iLoop+2)%></div></td>
            <td class="thinborder" height="25"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)vExamSchedules.elementAt(iLoop+3)%>:<%=CommonUtil.formatMinute((String)vExamSchedules.elementAt(iLoop+4))%> <%=WI.getStrValue(astrPeriod[Integer.parseInt((String)vExamSchedules.elementAt(iLoop+5))])%></div></td>
            <td class="thinborder" height="25"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)vExamSchedules.elementAt(iLoop+6)%> mins</div></td>
            <td class="thinborder" height="25"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)vExamSchedules.elementAt(iLoop+7)%></div></td>
          </tr>
          <%}%>
        </table></td>
    </tr>
  </table>
				  
				  </td>
			  </tr>
			</table>		</td>
      </tr>
    </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    
    <tr> 
      <td width="18" height="18">&nbsp;</td>
      <td width="432" height="18"><div align="right"></div></td>
      <td width="398" height="18" align="right">&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">Prepared by: <b><%=(String)request.getSession(false).getAttribute("first_name")%></b></td>
      <td height="18" align="right" style="font-weight:bold"><%=WI.getTodaysDate(6)%> <%=WI.getTodaysDate(15)%></td>
    </tr>
  </table>
<%}%>
</body>
</html>
<% 
dbOP.cleanUP();
%>