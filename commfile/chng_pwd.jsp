<%
String strBGCol = request.getParameter("bgcol");
String strHeaderCol = request.getParameter("headercol");
if(strBGCol == null || strBGCol.trim().length() ==0)
	strBGCol = "D2AE72";
else
	strBGCol = strBGCol;
if(strHeaderCol == null || strHeaderCol.trim().length() ==0)
	strHeaderCol = "A49A6A";
else
	strHeaderCol = strHeaderCol;	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Change Password</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">

<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}
-->
</style>
</head>
<script language="JavaScript">
function ChangePassword()
{
	document.form_.changePassword.value = 1;
}
</script>
<body bgcolor="#<%=strBGCol%>">
<%@ page language="java" import="utility.*" %>
<%
 //only used to load the Course offered, degree, year offered, semester offered and curriculum year (School year)
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strEmpID = null;
	WebInterface WI = new WebInterface(request);
	boolean bolChangePassword = false;
	
	if(request.getParameter("changePassword") != null && request.getParameter("changePassword").compareTo("1") ==0 && 
		request.getSession(false).getAttribute("userId_") != null) 
		bolChangePassword = true;

	try
	{
		//if(bolChangePassword)
			dbOP = new DBOperation();
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
//create the user information only if no temp id is created and 
strEmpID = (String)request.getSession(false).getAttribute("userId_");
String strPwd = (String)request.getSession(false).getAttribute("pwd");
strErrMsg = (String)request.getSession(false).getAttribute("errorMsg");
if(strEmpID == null || strEmpID.trim().length() == 0 || strPwd == null) {
	strErrMsg = "Please login to change login ID and Password.";
}
else if(bolChangePassword){ //update password 
	if(WI.fillTextValue("new_pwd").toLowerCase().compareTo(WI.fillTextValue("retype").toLowerCase()) != 0) {
		strErrMsg = "New Password and repeat password does not match";
	}
	else {
		PasswordManagement PM = new PasswordManagement();
		if(! PM.changePassword(dbOP, strPwd, WI.fillTextValue("new_pwd"), strEmpID, null,null,false,null) )
			strErrMsg = PM.getErrMsg();
		else {
			strErrMsg = null;
			request.getSession(false).removeAttribute("pwd");
			request.getSession(false).removeAttribute("userId_");
			request.getSession(false).removeAttribute("errorMsg");
		}
	}
}

boolean bolIsPasswordComplex = false;
String strTemp = "select prop_val from read_Property_file where prop_name = 'FORCE_COMPLEX_PASSWORD' and prop_val = '1'";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp != null)
	bolIsPasswordComplex = true;

if(dbOP != null)
	dbOP.cleanUP();
	

%>
<form name="form_" action="./chng_pwd.jsp" method="post">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" bgcolor="#<%=strHeaderCol%>"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CHANGE PASSWORD ::::</strong></font></div></td>
    </tr>
</table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(request.getSession(false).getAttribute("userId_")!= null){%>
    <tr> 
      <td width="7%" height="25"><p><br>
        </p></td>
      <td height="25" colspan="3"><p><font size="3" color="#0000FF"><strong> 
          <%if(strErrMsg == null) {%>
          You are logging in for the first time. Please change your Login ID and 
          password.</strong>
          <%}else{%><%=strErrMsg%><%}%>
          <strong> </strong></font></p>
        <font size="3"> <u>Rules to change Password</u><br>
		<%if(bolIsPasswordComplex) {%>
		1. Length of password must be more than 7 characters and less than 30 characters<br>
		2. Password must contain digits 0 to 9 <br>
		3. Password must contain characters a to z or A to Z<br>
		4. Password must contain special characters. Allowed special characters are <br>
			&nbsp;&nbsp;&nbsp;&nbsp; ~ ! @ # $ % ^ & * ( ) - _ = + { [ } ] ; : | \ < , > . ? /
		<%}else{%>
		1. Length of password must be more than 4 characters and less than 26 characters<br>
		2. Password should not be same as Login ID or Employee ID
		<%}%>
		<!--
        1. Password should be more than 4 characters and less than 30 characters.<br>
        2. Password should not be same as Login ID or Employee ID 
		-->
		</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp; </td>
    </tr>
    <tr> 
      <td height="37">&nbsp;</td>
      <td width="13%">New Password</td>
      <td width="80%" colspan="2"><input name="new_pwd" type="password" size="32" maxlength="32" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:17px"></td>
    </tr>
    <tr> 
      <td height="37">&nbsp;</td>
      <td>Retype Password</td>
      <td colspan="2"><input name="retype" type="password" size="32" maxlength="32" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:17px"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><input type="image" src="../images/save.gif" width="48" height="28" onClick="ChangePassword();"> 
        <font size="1">click to save new password</font></td>
    </tr>
<%}%>    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><strong><font size="3"> 
        <%
if(bolChangePassword && strErrMsg == null)
{%>
        Password successfully changed. <a href="../" target="_parent">Click 
        here to login</a> 
        <%}%>
        </font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><strong></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#<%=strHeaderCol%>"> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="bgcol" value="<%=strBGCol%>">
  <input type="hidden" name="headercol" value="<%=strHeaderCol%>">
<input type="hidden" name="changePassword" value="0">

</form>
</body>
</html>
