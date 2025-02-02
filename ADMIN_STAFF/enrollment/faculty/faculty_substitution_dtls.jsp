<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage() {
	document.form_.submit();
}
function focusID() {
	document.form_.emp_id.focus();
}
//all about ajax - to display student list with same name.
function AjaxMapName(e) {
		if(e.keyCode == 13) {
			ReloadPage();
			return;
		}
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
-->
</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector, java.util.Date" %>
<%
	//simple authentication added here.
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4")) {
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Not Authorized to view this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	Vector vFacultyInfo    = null;
	String strFacultyName  = null;

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
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-SUBSTITUTION"),"0"));
		}		
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-substitute","faculty_substitution_dtls.jsp");
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
														"faculty_substitution_dtls.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
**/
//end of authenticaion code.

FacultyManagement FM = new FacultyManagement();
enrollment.FacMgmtSubstitution facSubs = new enrollment.FacMgmtSubstitution(dbOP);

Vector vUserDetail   = null;
Vector vFacSubs      = null;

String strTotalSubstituted = null;
String strSYFrom   = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");
if(strSYFrom.length() ==0) {
	strSYFrom   = WI.getStrValue((String)request.getSession(false).getAttribute("cur_sch_yr_from"));
	strSemester = WI.getStrValue((String)request.getSession(false).getAttribute("cur_sem"));
}

String strEmployeeIndex = null;
if(WI.fillTextValue("emp_id").length() > 0) 
	strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));

if(strEmployeeIndex != null) {
	vUserDetail = FM.viewFacultyDetail(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"));
	if(vUserDetail == null)
		strErrMsg = FM.getErrMsg();
}
else if(WI.fillTextValue("emp_id").length() > 0 && strEmployeeIndex == null)
	strErrMsg = "Employee ID :"+WI.fillTextValue("emp_id")+" does not exist.";

if(strEmployeeIndex != null && WI.fillTextValue("sy_from").length() > 0) {
	vFacSubs = facSubs.getFacultySubsDetailALL(dbOP, request, strEmployeeIndex);
	if(vFacSubs == null) 
		strErrMsg = facSubs.getErrMsg();
	else	
		strTotalSubstituted = (String)vFacSubs.remove(0);
}
%>

<form name="form_" action="./faculty_substitution_dtls.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FACULTY SUBSTITUTION PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="4%">&nbsp;</td>
      <td colspan="3" height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td valign="bottom">School Year/Term : </td>
      <td colspan="2" valign="bottom"> 
 <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
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
	  readonly="yes"> &nbsp;&nbsp; 
	  <select name="semester">
	  	<option value="-1">Show All</option>
<%
if(strSemester.equals("1"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st</option>
<%
if(strSemester.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd</option>
<%
if(strSemester.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%>>3rd</option>
<%
if(strSemester.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="0" <%=strErrMsg%>>Summer</option>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="19%">Faculty ID : </td>
      <td width="21%"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event);">
      <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" height="25" hspace="10"></a></td>
      <td width="56%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr >
      <td></td>
      <td colspan="4"><label id="coa_info" style="position:absolute; width:400px;"></label></td>
    </tr>
    
    <tr> 
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
  </table>
<%
if(vUserDetail != null && vUserDetail.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="19%">Faculty Name</td>
      <td width="59%"><strong><%=(String)vUserDetail.elementAt(1)%></strong></td>
      <td width="18%" rowspan="4" valign="middle"> <img src="../../../upload_img/<%=WI.fillTextValue("emp_id").toUpperCase() + "."+(String)request.getSession(false).getAttribute("image_extn")%>" width="90" height="90" border="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">College / Dept</td>
      <td height="25"><strong><%=WI.getStrValue(vUserDetail.elementAt(4))%>  <%=WI.getStrValue((String)vUserDetail.elementAt(5)," / ","","")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Emp. Status</td>
      <td height="25"><strong><%=(String)vUserDetail.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Total Load</td>
      <td><strong><%=(String)vUserDetail.elementAt(6)%></strong></td>
    </tr>
	
	<%if(strTotalSubstituted != null) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Total Substituted</td>
      <td><strong><%=strTotalSubstituted%> hrs.</strong></td>
    </tr>
	<%}%>
  </table>
<%}//only if user info is not null.
if(vFacSubs != null && vFacSubs.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="8" align="center" class="thinborder" bgcolor="#B9B292"><strong>LIST 
        OF SUBSTITUTION</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="15%" height="25" class="thinborder"><strong><font size="1">EMPLOYEE ID</font></strong></td>
      <td width="20%" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="15%" class="thinborder"><strong><font size="1">SUJECT CODE</font></strong></td>
      <td width="20%" class="thinborder"><strong><font size="1">SUBJECT NAME </font></strong></td>
      <td width="10%" class="thinborder"><strong><font size="1">SECTION</font></strong></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">SUBSTITUTED HOUR </font></strong></div></td>
      <td width="7%" class="thinborder" align="center"><strong><font size="1">TERM</font></strong></td>
      <td width="10%" class="thinborder" align="center"><strong><font size="1">DATE SUBSTITUTED</font></strong></td>
    </tr>
    <%
for(int i = 0; i < vFacSubs.size(); i += 9){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" class="thinborder"><%=(String)vFacSubs.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vFacSubs.elementAt(i + 3)%></td>
      <td class="thinborder"><%=(String)vFacSubs.elementAt(i + 4)%></td>
      <td class="thinborder"><%=(String)vFacSubs.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vFacSubs.elementAt(i + 6)%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(vFacSubs.elementAt(i + 7),"0.00")%></td>
      <td class="thinborder" align="center"><%=(String)vFacSubs.elementAt(i + 8)%></td>
      <td class="thinborder" align="center"><%=(String)vFacSubs.elementAt(i + 1)%></td>
    </tr>
    <%}%>
  </table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
