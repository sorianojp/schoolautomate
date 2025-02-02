<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Admission</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

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

    TD{
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

    TD.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }	
	
</style>
</head>
<script language="javascript">
function PrintPage(){
	document.getElementById('footer').deleteRow(0);
	window.print();	
}
</script>
<body topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,java.util.Vector,enrollment.CourseRequirement"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;	
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
if(strErrMsg != null){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="18"><font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
  </table>
<%}

if(strErrMsg == null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr>
      <td colspan="5" align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
      <strong><br>
      ENTRANCE EXAMINATION PERMIT <br>
      &nbsp;</strong>Temporary ID : <strong><%=WI.getStrValue((String)vRetResult.elementAt(2))%></strong></font></td>
      <td width="15%" rowspan="3" valign="bottom"><img src="../../images/blank.gif" alt="insert 2 x 2 photo here" width="100" height="100" border="1" align="right"></td>
    </tr>
    <tr>
      <td width="8%" height="25" valign="bottom">Name :</td>
      <td width="22%" align="center" valign="bottom" class="thinborderBottom"><strong><%=(String)vRetResult.elementAt(5)%>
	  </strong></td>
      <td width="26%" align="center" valign="bottom" class="thinborderBottom">
	  			<strong><%=(String)vRetResult.elementAt(3)%>  	            </strong></td>
      <td width="26%" align="center" valign="bottom" class="thinborderBottom">
	  		<strong><%=(String)vRetResult.elementAt(4)%>	        </strong></td>
      <td width="3%">&nbsp;</td>
    </tr>
    <tr>
      <td height="19" valign="bottom">&nbsp;</td>
      <td align="center" valign="top"><font size="1">(Surname)</font></td>
      <td align="center" valign="top"><font size="1">(First Name)</font></td>
      <td align="center" valign="top"><font size="1">(Middle Name)</font></td>
      <td>&nbsp;</td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>

    <tr>
      <td width="7%" height="18"><font size="2">Date :</font></td>
      <td width="29%" height="18" class="thinborderBottom">
	    <font size="2">
	    <% if (vExamSchedules != null && vExamSchedules.size() > 0){%>
			&nbsp;<strong><%=WI.formatDate((String)vExamSchedules.elementAt(2),6)%></strong>
        <%}%>	  
      </font></td>
      <td width="26%">&nbsp;</td>
      <td width="38%">&nbsp;</td>
    </tr>
    <tr>
      <td height="18"><font size="2">Time : </font></td>
      <td height="18" class="thinborderBottom"><font size="2">&nbsp;
      <% if (vExamSchedules != null && vExamSchedules.size() > 0){%>
        <strong><%=(String)vExamSchedules.elementAt(3)%>:
		<%=CommonUtil.formatMinute((String)vExamSchedules.elementAt(4))%> 
		<%=astrPeriod[Integer.parseInt(WI.getStrValue((String)vExamSchedules.elementAt(5),"0"))]%></strong>
      <%}%> 
      </font></td>
      <td>&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr>
      <td height="18"><font size="2">Room : </font></td>
      <td height="18" class="thinborderBottom"><font size="2">&nbsp;
      <% if (vExamSchedules != null && vExamSchedules.size() > 0){%>	  
	      <strong><%=(String)vExamSchedules.elementAt(7)%></strong>
      <%}%>	  
      </font></td>
      <td>&nbsp;</td>
      <td rowspan="6" class="thinborderall"><table width="98%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="53%" height="18" valign="bottom"><font size="1">&nbsp;Official Receipt #:</font></td>
          <td width="47%" valign="bottom" class="thinborderBottom"><font size="1">&nbsp;</font></td>
        </tr>
      </table>
<table width="98%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="16%" height="18" valign="bottom"><font size="1"> &nbsp;Date :</font></td>
          <td width="84%" valign="bottom" class="thinborderBottom"><font size="1">&nbsp;</font></td>
        </tr>
        <tr>
          <td height="18">&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
      </table>



	  
	  <table width="98%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="34%" height="18" valign="bottom"><font size="1">&nbsp;Issued by :</font></td>
          <td width="66%" valign="bottom" class="thinborderBottom"><font size="1">
		  <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),4)%></font></td>
        </tr>
      </table>
	  <table width="98%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="16%" height="18" valign="bottom"><font size="1">&nbsp;Date : </font></td>
          <td width="84%" valign="bottom" class="thinborderBottom" align="center"><font size="1">
		  	<%=WI.getTodaysDate(2)%></font></td>
        </tr>
        <tr>
          <td height="18">&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
      </table></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="2"><span style="font-weight: bold"><font style="font-size:12px;">Note to the Applicant </font></span></td>
      <td height="18"><font style="font-size:12px;">&nbsp;</font></td>
    </tr>
    <tr>
      <td height="18" colspan="3"><font style="font-size:12px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. Please bring 2pcs. Mongol #2 Pencil </font></td>
    </tr>
    <tr>
      <td height="18" colspan="3"><font style="font-size:12px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. No Permit, No Exam </font></td>
    </tr>
    <tr>
      <td height="18" colspan="3"><font style="font-size:12px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. Please come 30 minutes before your schedule</font></td>
    </tr>
    <tr>
      <td height="18" colspan="4"><font style="font-size:12px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4. You are not allowed to bring snacks inside the testing room </font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="footer">
    <tr>
      <td height="25" colspan="4"><div align="center"> <a href="javascript:PrintPage()"><img src="../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print admission slip</font></div></td>
    </tr>
</table>
  <%}%>
</body>
</html>
<% 
dbOP.cleanUP();
%>