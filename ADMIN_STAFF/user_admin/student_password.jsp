<%@ page language="java" import="utility.*,osaGuidance.GDStudReferralFollowUp,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript">
function UpdatePassword() {
	var strPassword = prompt("Please enter password of length between 5 to 30 characters","<%=WI.fillTextValue("stud_id")%>");
	if(strPassword == null) 
		return;
	var len = strPassword.length ;
	if(len < 5 || len > 30) {
		alert("Please enter password of correct length.");
		return;
	}
	document.form_.password.value = strPassword;
	document.form_.page_action.value="1";
	document.form_.submit();
}
function UpdateNoOfRetry() {
	document.form_.page_action.value="2";
	document.form_.submit();
}
function UpdateLoginID() {
	if(!confirm("Are you sure you want to change the Login ID to User ID?",""))
		return;
	document.form_.page_action.value="3";
	document.form_.submit();
}
var AjaxCalledPos;
function AjaxMapName(strPos, e) {
	if(e.keyCode == 13) {
		document.form_.submit();
		return;
	}
		AjaxCalledPos = strPos;
		if(strPos == "1") {
			document.getElementById("stud_info1").innerHTML = "...";
			document.getElementById("stud_info2").innerHTML = "...";
			document.getElementById("updateP").innerHTML = "";
			document.getElementById("updateNR").innerHTML = "";
			document.form_.user_index.value = "";
		}
		
		var strCompleteName;
		if(strPos == "1")
			strCompleteName = document.form_.stud_id.value;
		else	
			strCompleteName = document.form_.emp_id.value;
			
		if(strCompleteName.length == 0)
			return;
		
		var objCOAInput;
		if(strPos == "1")
			objCOAInput = document.getElementById("coa_info");
		else	
			objCOAInput = document.getElementById("coa_info2");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);
		if(strPos == "2")
			strURL += "&is_faculty=1";
		//if(document.form_.account_type[1].checked) //faculty
		//	strURL += "&is_faculty=1";
		//alert(strURL);
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	if(AjaxCalledPos == "2"){
		document.form_.emp_id.value = strID;
		return;
	}
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
	
	document.getElementById("stud_info1").innerHTML = " == Press press enter == ";
	document.getElementById("stud_info2").innerHTML = " == Press press enter == ";
	document.form_.user_index.value = strUserIndex;
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	if(AjaxCalledPos == "1")
		document.getElementById("coa_info").innerHTML = strName;
	else	
		document.getElementById("coa_info2").innerHTML = strName;
}
</script>
<body bgcolor="#93B5BB" onLoad="document.form_.stud_id.focus()">
<%
	String strTemp      = null;
	String strErrMsg    = null;
	String strSQLQuery  = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-FacultyAcad-Student referral","encode_student_ref.jsp");
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
														"System Administration","USER MANAGEMENT",request.getRemoteAddr(), null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Guidance & Counseling","RESET STUDENT PASSWORD",request.getRemoteAddr(), null);
}
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"System Administration","USER MANAGEMENT-RESET PASSWORD",request.getRemoteAddr(), null);
}
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"System Administration","USER MANAGEMENT-RESET STUDENT PASSWORD",request.getRemoteAddr(), null);
}
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


String strStudID     = WI.fillTextValue("stud_id");
String strStudName   = null;
String strPassword   = null;
String strNoOfRetry  = null;
String strUserIndex  = null;

String strLoginID    = null;

boolean bolIsTempStud = false;


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	strUserIndex = WI.fillTextValue("user_index");
	if(strUserIndex.length() == 0)
		strErrMsg = "Student information is missing.";
	if(WI.fillTextValue("temp_user").equals("true"))
		bolIsTempStud = true;

	if(strTemp.equals("1") && strUserIndex.length() > 0){
		String strPasswordNew = WI.fillTextValue("password");
		if(strPasswordNew.length() == 0 || strPasswordNew.indexOf("'") > -1 || strPasswordNew.length() < 5 ||
			strPasswordNew.length() > 30) {
			strErrMsg = "Password must not contain ' and length should be between 5 and 30 chars";
		}
		else {
			if(bolIsTempStud)
				dbOP.executeUpdateWithTrans("update new_application set password='"+strPasswordNew+"' where application_index="+strUserIndex,null, null, false);
			else
				dbOP.executeUpdateWithTrans("update login_info set password='"+strPasswordNew+"' where user_index="+strUserIndex,null, null, false);
		}
	}
	if(strTemp.equals("2") && strUserIndex.length() > 0){
		if(bolIsTempStud)
			dbOP.executeUpdateWithTrans("update new_application set no_of_retry=0 where application_index="+strUserIndex, null, null, false);
		else
			dbOP.executeUpdateWithTrans("update login_info set no_of_retry=0 where user_index="+strUserIndex, null, null, false);
	}
	if(strTemp.equals("3") && strUserIndex.length() > 0 && !bolIsTempStud){
		dbOP.executeUpdateWithTrans("update login_info set last_renew = null, user_id=(select id_number from user_table where user_index="+strUserIndex+
		") where user_index = "+strUserIndex , null, null, false);
	}
	
}


bolIsTempStud = false;
strSQLQuery = "select fname, mname, lname, password,no_of_retry,user_table.user_index,user_id from user_table "+
	"join login_info on (login_info.user_index = user_table.user_index) "+
	" where id_number='"+strStudID+"' and auth_type_index=4";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
if(rs.next()) {
	strStudName  = WI.formatName(rs.getString(1),rs.getString(2),
								rs.getString(3),4);
	strPassword  = rs.getString(4);
	strNoOfRetry = rs.getString(5);
	strUserIndex = rs.getString(6);
	
	strLoginID   = rs.getString(7);
}
else {
	strSQLQuery = "select fname, mname, lname, password,no_of_retry,new_application.application_index,temp_id from new_application "+
		"join na_personal_info on (na_personal_info.application_index = new_application.application_index) "+
		" where temp_id='"+strStudID+"'";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strStudName  = WI.formatName(rs.getString(1),rs.getString(2),rs.getString(3),4);
		strPassword  = rs.getString(4);
		strNoOfRetry = rs.getString(5);
		strUserIndex = rs.getString(6);
		
		strLoginID   = rs.getString(7);
		
		bolIsTempStud = true;
	}
	
	rs.close();
}
rs.close();
%>
<form action="./student_password.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#FFFFFF">
    <tr>
     <td width="100%" height="25" bgcolor="#6A99A2"><div align="center"><font color="#FFFFFF"><strong>:::: 
          STUDENT PASSWORD ACCESS/MODIFICATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="22%">Student ID</td>
      <td width="73%">
	  	<input name="stud_id" type="text"  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AjaxMapName('1',event);">
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td> Student Name</td>
      <td height="25" colspan="2"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"><%=WI.getStrValue(strStudName)%></label></td>
    </tr>
    <tr> 
      <td  width="5%"height="25">&nbsp;</td>
      <td width="22%" height="25">Password</td>
      <td width="33%" height="25"><strong>
      <label id="stud_info1"><%=WI.getStrValue(strPassword)%></label></strong></td>
      <td width="40%"><font style="color:#FF0000; font-size:10px; font-weight:bold">
	  	<label id="updateP" onClick="UpdatePassword();">
			<%if(strPassword != null) {%> Click here to change password<%}%> </label></font>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">No of retry </td>
      <td height="25"><label id="stud_info2"><%=WI.getStrValue(strNoOfRetry)%></label></td>
      <td height="25">
		<font style="color:#FF0000; font-size:10px; font-weight:bold">
	  	<label id="updateNR" onClick="UpdateNoOfRetry();">
			<%if(strPassword != null) {%> 
			Click here to reset number of retry
			<%}%> </label></font>	  </td>
    </tr>
<%
if(!bolIsTempStud) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Login ID </td>
      <td height="25"><%=WI.getStrValue(strLoginID)%></td>
      <td height="25"><font style="color:#FF0000; font-size:10px; font-weight:bold">
        <label id="updateLID" onClick="UpdateLoginID();">
		<%if(strLoginID != null) {%>
			Click here to reset Login ID
		<%}%>
        </label>
      </font> </td>
    </tr>
<%}%>
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#6A99A2">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="user_index" value="<%=strUserIndex%>">
<input type="hidden" name="temp_user" value="<%=bolIsTempStud%>">

<input type="hidden" name="password">

<input type="hidden" name="page_action">
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>