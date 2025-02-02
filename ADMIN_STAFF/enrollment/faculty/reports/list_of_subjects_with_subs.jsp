<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strCourseIndex = request.getParameter("course_index");
	String strMajorIndex  = request.getParameter("major_index");

	Vector vFacultyInfo    = null;
	String strFacultyName  = null;
	String strCommonSubMsg = null;

	//this is necessary for different types of subject offering.
	//degree_type=0->UG,1->Doctoral,2->medicine,3->with prep proper, 4-> care giver.
	//for care giver,doctoral, do not show year level, for prep_prop, show prep/prop status.
	String strDegreeType = null;

	Vector vTemp = null;

	int j = -1 ;

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-REPORTS"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-load schedule","list_of_subjects_with_subs.jsp");
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
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"list_of_subjects_with_subs.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
**/
//end of authenticaion code.
if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("selany") != 0)
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");


strErrMsg = null; //if there is any message set -- show at the bottom of the page.
FacultyManagement FM = new FacultyManagement();
if(request.getParameter("addFacultyLoad") != null && request.getParameter("addFacultyLoad").compareTo("1") ==0)
{
	if(!FM.saveFacultyLoad(dbOP,request))
		strErrMsg = FM.getErrMsg();
	else
	 	strErrMsg = "Faculty load added successfully.";
}
else if(WI.fillTextValue("delFacLoad").compareTo("1") ==0)
{
	//delete the load here.
	if(!FM.delFacLoad(dbOP,(String)request.getSession(false).getAttribute("login_log_index"),request.getParameter("info_index")))
		strErrMsg = FM.getErrMsg();
	else
	 	strErrMsg = "Faculty load deleted successfully.";
}

if(strErrMsg == null) strErrMsg = "";
%>

<form name="form_" action="./list_of_subjects_with_subs.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          FACULTY/REPORTS PAGE - LIST OF SUBJECTS WITH SUBSTITUTION ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td>&nbsp;</td>
      <td colspan="2"><a href="../enrollment__faculty_reports.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY/Term :
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td>Date Range :
        <input name="date_fr" type="text" size="10" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>"
		 class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        to
        <input name="date_to" type="text" size="10" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>"
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="43%">LIST OF SUBJECT : </td>
      <td width="55%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24"><a href="../enrollment__faculty_reports.jsp"><img src="../../../../images/form_proceed.gif"border="0"></a></td>
    </tr>
    <tr>
      <td colspan="3" height="25"><hr size="1"></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="60%" height="25">&nbsp;&nbsp; </td>
      <td width="40%"><div align="right"><img src="../../../../images/print.gif" width="58" height="26"><font size="1">click
          to print list</font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="7"><div align="center">LIST OF SUBJECTS WITH SUBSTITUTION<strong></strong></div></td>
    </tr>
    <tr>
      <td height="25" colspan="7">TOTAL : </td>
    </tr>
    <tr>
      <td width="20%"><div align="center"><strong><font size="1">SUBJECT</font></strong></div></td>
      <td width="10%" height="25"><div align="center"><strong><font size="1">SECTION</font></strong></div></td>
      <td width="15%"><div align="center"><strong><font size="1">SCHEDULE /ROOM
          #</font></strong></div></td>
      <td width="11%" height="25"><div align="center"><strong><font size="1">TOTAL
          NO. OF STUDS.</font></strong></div></td>
      <td width="13%"><div align="center"><strong><font size="1">ASSIGNED INSTRUCTOR</font></strong></div></td>
      <td width="17%"><div align="center"><strong><font size="1">SUBS. INSTRUCTOR</font></strong></div></td>
      <td width="8%"><div align="center"><strong><font size="1">SUBS. DATE</font></strong></div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="33">&nbsp;</td>
      <td height="33">&nbsp;</td>
      <td height="33"><div align="center">&nbsp;</div></td>
      <td valign="middle">&nbsp; </td>
      <td valign="middle">&nbsp;</td>
      <td valign="middle">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr >
      <td height="25"><div align="center"><input type="image" src="../../../../images/save.gif" onClick="AddFacultyLoad();"><font size="1">click
          to save entries</font></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" >&nbsp;</td>
    </tr>
  </table>
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
