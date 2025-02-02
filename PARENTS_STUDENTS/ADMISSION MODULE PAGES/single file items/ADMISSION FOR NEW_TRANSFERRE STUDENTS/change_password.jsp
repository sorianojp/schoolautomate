<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript">
function ChangePassword()
{
	document.chngpassword.changePassword.value = 1;
}
</script>
<body bgcolor="#9FBFD0">
<form name="chngpassword" action="./change_password.jsp" method="post">
<%@ page language="java" import="utility.*" %>
<%
 //only used to load the Course offered, degree, year offered, semester offered and curriculum year (School year)
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTempID = null;
	boolean bolChangePassword = false;
	
	if(request.getParameter("changePassword") != null && request.getParameter("changePassword").compareTo("1") ==0)
		bolChangePassword = true;

	try
	{
		if(bolChangePassword)
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
strTempID = (String)request.getSession(false).getAttribute("tempId");
if(strTempID == null || strTempID.trim().length() == 0)
{
	strErrMsg = "Please login to change password.";
}
else if(bolChangePassword) //update password
{
	String strPassword = request.getParameter("new_password");
	String strRetypePassword = request.getParameter("retype_password");
	if(strRetypePassword == null) strRetypePassword = "";
	if(strPassword != null && strPassword.compareTo(strRetypePassword) == 0)//update password now.
	{
		PasswordManagement PM = new PasswordManagement();
		if(! PM.changePassword(dbOP,request.getParameter("old_password"), request.getParameter("new_password"),strTempID, 
                                  request.getParameter("forgot_pass_ques"), request.getParameter("forgot_pass_ans"),true,(String)request.getSession(false).getAttribute("login_log_index")) )
		{
			strErrMsg = PM.getErrMsg();
		}
	}
	else
		strErrMsg = "Password and Retype password does not match.";	
}

if(dbOP != null)
	dbOP.cleanUP();
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#47768F"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CHANGE PASSWORD ::::</strong></font></div></td>
    </tr>
</table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
<%
if(strErrMsg != null)
{%>	<tr> 
      <td height="25" colspan="4">&nbsp; <%=strErrMsg%></td>
    </tr>
<%return;}%>	
    <tr> 
      <td width="24%" height="25">&nbsp;</td>
      <td width="18%">Old Password</td>
      <td width="58%" colspan="2"><input name="old_password" type="password" size="32" maxlength="32"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>New Password</td> 
      <td colspan="2"><input name="new_password" type="password" size="32" maxlength="32"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Retype Password</td>
      <td colspan="2"><input name="retype_password" type="password" size="32" maxlength="32"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Forget Password?</td>
      <td colspan="2"><select name="forgot_pass_ques">
          <option value="1" selected>What is your pet name</option>
          <option value="2">What is your favourite color</option>
          <option value="3">What is your mother's maiden name</option>
          <option value="4">What is your best friends name</option>
          <option value="5">What is your favourite Flower</option>
          <option value="6">What is your food</option>
          <option value="7">Keep an arbitray answer.</option>
        </select></td>
    </tr><tr> 
      <td height="25">&nbsp;</td>
      <td><em>Hint Question.</em></td>
      <td colspan="2" valign="top"><font size="1">(optional) - used if you forget your password. 
        </font></td>
    </tr><tr> 
      <td height="25">&nbsp;</td>
      <td>Hint Question Answer</td>
      <td colspan="2"><input type="text" name="forgot_pass_ans" maxlength="64"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font size="1">(optional) </font></td>
    </tr>
	<tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><input type="image" src="../../../../images/save.gif" width="48" height="28" onClick="ChangePassword();"><font size="1">click 
        to save new password</font></td>
    </tr>
    <tr> 
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
if(bolChangePassword)
{%>	  Password successfully changed.
<%}%></font></strong></td>
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
    <tr> 
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td colspan="3" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="changePassword" value="0">
</form>
</body>
</html>
