<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function DeleteS(strInfoIndex) {
	document.form_.page_action.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.search_page.value = "1";
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.print_pg.value = "";
	document.form_.search_page.value = "";
	document.form_.submit();
}
function Search() {
	document.form_.page_action.value = "";
	document.form_.print_pg.value = "";
	document.form_.search_page.value = "1";
	document.form_.submit();
}
function PrintPg() {
	document.form_.page_action.value = "";
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
-->
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	//page forward if pring page is called.
	if(WI.fillTextValue("print_pg").length() > 0) {%>
		<jsp:forward page="./list_of_teachers_with_subs_print.jsp" />
	<%return;}

	Vector vFacultyInfo    = null;
	String strFacultyName  = null;
	Vector vTemp = null;

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
								"Admin/staff-Enrollment-Faculty-substitute-REPORTS","list_of_teachers_with_subs.jsp");
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
														"list_of_teachers_with_subs.jsp");
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
enrollment.FacMgmtSubstitution facSubs = new enrollment.FacMgmtSubstitution(dbOP);
Vector vRetResult   = null;
if(WI.fillTextValue("page_action").length() > 0) {
	if(!facSubs.operateOnSubstitution(dbOP, request, 0))
		strErrMsg = facSubs.getErrMsg();
	else
		strErrMsg = "Faculty substitution information removed successfully.";
}
if(WI.fillTextValue("search_page").length() > 0) {
	vRetResult = facSubs.facListWithSubs(dbOP, request);
	if(vRetResult == null)
		strErrMsg = facSubs.getErrMsg();
}
%>

<form name="form_" action="./list_of_teachers_with_subs.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          FACULTY/REPORTS PAGE - LIST OF TEACHERS WITH SUBSTITUTION ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr>
      <td colspan="3"><a href="../enrollment__faculty_reports.jsp"><img src="../../../../images/go_back.gif" border="0" hspace="20"></a>
	  <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY/Term :
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
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
        <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>"
		 class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        to
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>"
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">College
        <select name="c_index" onChange="ReloadPage();">
          <option value="">Select a college</option>
          <%
	strTemp = WI.fillTextValue("c_index");
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Department
        <select name="d_index">
          <option value="">Select a Department</option>
          <%
	strTemp = WI.fillTextValue("c_index");
	if(strTemp.length() == 0)
		strTemp = " and (c_index is null or c_index = 0)";
	else
		strTemp = " and c_index = "+strTemp;
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 "+strTemp+" order by d_name asc",
		  WI.fillTextValue("d_index"), false)%> </select></td>
    </tr>
    <tr>
      <td width="2%" height="50">&nbsp;</td>
      <td width="40%">Faculty ID :
        <input name="emp_id" type="text" size="16" class="textbox" value="<%=WI.fillTextValue("emp_id")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">
        <a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" border="0" hspace="20"></a></td>
      <td width="58%"><a href="javascript:Search();"><img src="../../../../images/form_proceed.gif"border="0"></a></td>
    </tr>
    <tr >
      <td></td>
      <td colspan="2"><label id="coa_info"></label></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="40%" height="25"><div align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a><font size="1">click
          to print list</font></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="8"><div align="center"><strong>LIST OF TEACHER(S)
          WITH SUBSTITUTION</strong><strong></strong></div></td>
    </tr>
    <tr>
      <td width="15%" height="25"><div align="center"><strong><font size="1">SUBSTITUTING
          INSTRUCTOR</font></strong></div></td>
      <td width="15%"><div align="center"><strong><font size="1"> INSTRUCTOR SUBSTITUTED</font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1">SUBS. DATE</font></strong></div></td>
      <td width="20%" height="25"><div align="center"><strong><font size="1">SUBJECT</font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1">SECTION</font></strong></div></td>
      <td width="20%"><div align="center"><strong><font size="1">SCHEDULE /ROOM
          #</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">TOTAL NO. OF STUDS.</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">DELETE</font></strong></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 10){%>
    <tr>
      <td height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td height="25"><%=(String)vRetResult.elementAt(i + 4)%><br><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td valign="middle"><%=(String)vRetResult.elementAt(i + 6)%> </td>
      <td valign="middle"><%=(String)vRetResult.elementAt(i + 9)%></td>
      <td valign="middle"><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td valign="middle">
	  <%if(iAccessLevel == 2) {%>
	  	<a href="javascript:DeleteS(<%=(String)vRetResult.elementAt(i)%>);"><img src="../../../../images/delete.gif" border="0" width="50"></a>
	  <%}%>
	  </td>
    </tr>
<%}//end of for loop.%>
  </table>
<%}///end of vRetResult%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" >&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="search_page">
<input type="hidden" name="print_pg">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
