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
<body bgcolor="#FFFFFF" onLoad="window.print()">
<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,java.util.Vector,enrollment.CourseRequirement"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;	
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
	if (strSchCode.startsWith("CGH")) { %>
	<jsp:forward page="./entrance_admission_slip_new_print_cgh.jsp" />
	<% return; 	}
	if (strSchCode.startsWith("CIT")) { %>
	<jsp:forward page="./entrance_admission_slip_new_print_cit.jsp" />
	<% return; 	}
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Registration","entrance_admission_slip.jsp");
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
														"entrance_admission_slip.jsp");
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
	String strSemester = null;
	String[] astrSemester = {"Summer", " First Semester ", "Second Semester", "Third Semester "};
	String[] astrPeriod = {"AM","PM"};
	
	strTempID = dbOP.mapOneToOther("NEW_APPLICATION", "TEMP_ID", 
           "'"+strTempID+"'","TEMP_ID", "");		
	
	if (strTempID != null){		
		vRetResult = offlineAdd.createAdmissionSlipReqNew(dbOP,request,strTempID);
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
		strSemester = (String)vRetResult.elementAt(6);	
	}	
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
	<%if(strErrMsg == null){%> 
      <td width="91%" height="25"><div align="center"><strong><font size="2">:::: 
          ENTRANCE EXAM SLIP::::</font></strong></div></td>
	<%}%>
    </tr>
  </table>
<%
if(strErrMsg != null){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="18"><font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
  </table>
<%}%>
<%if(strErrMsg == null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr> 
      <td width="25" height="25">&nbsp;</td>
      <td width="395" height="25"> Name : <strong><%=WI.formatName((String)vRetResult.elementAt(3),WI.getStrValue((String)vRetResult.elementAt(4),""),(String)vRetResult.elementAt(5),8)%></strong></td>
      <td width="350" height="25">Temporary ID : <strong><%=WI.getStrValue((String)vRetResult.elementAt(2))%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">School Year/Term : <strong><%=WI.getStrValue((String)vRetResult.elementAt(0))%> - <%=WI.getStrValue((String)vRetResult.elementAt(1))%>/<%=WI.getStrValue(astrSemester[Integer.parseInt(strSemester)])%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Schedule of Exam(s):</td>
    </tr>
    <tr> 
      <td height="15" colspan="3"> <table width="94%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
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
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18"><div align="right"></div></td>
      <td height="18" align="right"><font size="1">print date: <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
    </tr>
  </table>
  <%}%>
</body>
</html>
<% 
dbOP.cleanUP();
%>