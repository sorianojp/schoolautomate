<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage(){
	document.form_.showall.value = "";
	document.form_.print_page.value = "";
	document.form_.submit();
}

function showValues(){
	document.form_.showall.value = "1";
	document.form_.print_page.value = "";
	document.form_.submit();
}

function PrintPg(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}

function UpdateCollege(){

	if (document.form_.view_reserved.checked){
		document.form_.c_index.selectedIndex = 0;
		document.form_.course_index.selectedIndex = 0;
		document.form_.major_index.selectedIndex = 0;
		document.form_.course_index[0].text = "All";
	}
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportFaculty,java.util.Vector, java.util.Date" %>
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

//add security here.

	if (WI.fillTextValue("print_page").compareTo("1") == 0){ %>
	<jsp:forward page="list_of_subjects_no_faculty_print.jsp" />
<%	}

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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-load schedule","enrollment_faculty_load_sched.jsp");
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
														"list_of_subjects_not_yet_assigned.jsp");
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

ReportFaculty rf = new ReportFaculty();
Vector vRetResult = null;


if (WI.fillTextValue("showall").length() > 0){
	vRetResult = rf.getSectNoFac(dbOP,request);

	if(vRetResult == null){
		strErrMsg = rf.getErrMsg();
	}
}
%>

<form action="./list_of_subjects_not_yet_assigned.jsp" method="post" name="form_" id="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          FACULTY/REPORTS PAGE - LIST OF SUBJECTS NOT YET ASSIGNED TO FACULTIES
          ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td>&nbsp;</td>
      <td colspan="2"><a href="../enrollment__faculty_reports.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td width="48%" valign="bottom">School year :
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strTemp%>" size="4" maxlength="4">
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  readonly="yes"> &nbsp;&nbsp;&nbsp; &nbsp;</td>
      <td width="50%" valign="bottom">Term :
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" valign="bottom"><font size="1">
	  <% if (WI.fillTextValue("view_reserved").length()>0) strTemp = "checked";
	  	else
			strTemp = "";
	  %>
        <input name="view_reserved" type="checkbox" id="view_reserved" value="1" <%=strTemp%> onClick="UpdateCollege()">
        </font> <font color="#0000FF"> Check to view only the Reserved/ International
        Subjects</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="12%" valign="bottom">College</td>
      <td width="86%" colspan="2" valign="bottom"> <select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <% strTemp = WI.fillTextValue("c_index"); %>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td valign="bottom">Course</td>
      <td colspan="2" valign="bottom"> <select name="course_index" onChange="ReloadPage();">
          <option value="0">Select a Course</option>
          <% if (strTemp.length() >  0){
		  	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and c_index ="+request.getParameter("c_index");%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, strCourseIndex, false)%>
		  <%}%>
		   </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom"> Major </td>
      <td colspan="2" valign="bottom"> <% //if (WI.fillTextValue("course_index").length() > 0) { %> <select name="major_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%
if(strCourseIndex != null && strCourseIndex.compareTo("0") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strCourseIndex+" order by major_name asc" ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strMajorIndex, false)%>
          <%}%>
        </select> <%//} // end if (WI.fillTextValue("course_index").length() > 0)%> &nbsp; </td>
    </tr>
    <tr>
      <td height="35" valign="bottom">&nbsp;</td>
      <td height="35" colspan="3" valign="bottom" ><a href="javascript:showValues()"><img src="../../../../images/form_proceed.gif"border="0"></a></td>
    </tr>
    <tr>
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) { %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="60%" height="25">&nbsp; Total Sections Found  : <%=vRetResult.size()/11%></td>
      <td width="40%"><div align="right"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
          to print list</font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="30" colspan="9"><div align="center"><strong>LIST OF SUBJECTS
          NOT YET ASSIGNED TO FACULTIES</strong><strong></strong></div></td>
    </tr>
    <tr>
      <td width="7%"><strong><font size="1">SUBJECT CODE</font></strong></td>
      <td width="26%"><div align="center"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
      <td width="8%" height="25"><div align="center"><strong><font size="1">SECTION</font></strong></div></td>
      <td width="11%"><div align="center"><strong><font size="1">SCHEDULE (Days::Time)</font></strong></div></td>
      <td width="7%"><div align="center"><strong><font size="1">ROOM #</font></strong></div></td>
      <td width="6%"><div align="center"><strong><font size="1">(LEC/ LAB)</font></strong></div></td>
      <td width="7%"><div align="center"><strong><font size="1">TOTAL UNITS</font></strong></div></td>
      <td width="8%" height="25"><div align="center"><strong><font size="1">TOTAL
          NO. OF STUDS.</font></strong></div></td>
      <td width="20%"><div align="center"><strong><font size="1">COLLEGE OFFERING</font></strong></div></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size() ; i+=11) {%>
    <tr>
      <td height="33"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
      <td><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></div></td>
      <td><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></div></td>
      <td><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+9)%></font></div></td>
      <td><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+10)%></font></div></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+6)%> </font></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" >&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="showall">
<input type="hidden" name="print_page">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
