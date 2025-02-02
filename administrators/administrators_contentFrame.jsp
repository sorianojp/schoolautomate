<%
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strName =(String)request.getSession(false).getAttribute("first_name");
if(strName == null) strName = strUserId;
if(strName == null) strName = "";


String strUserIDField = "_"+Long.toString(new java.util.Date().getTime());
String strPwdField    = strUserIDField + "0";

utility.WebInterface WI = new utility.WebInterface(request);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript">
function FocusID() {
	<%
	if(strUserId == null || strUserId.trim().length() == 0)
	{%>
	document.login.<%=strUserIDField%>.focus();
	<%}%>
}
</script>
<body bgcolor="#46689B" onLoad="FocusID();">
<%if(strUserId == null || strUserId.trim().length() == 0){%>
<form name="login"  action="../commfile/login.jsp" method="post" target="_parent">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="19%">&nbsp;</td>
      <td height="25" colspan="3" bgcolor="#004488"><div align="center"><font color="#FFFFFF" size="3"><strong>Please 
          Login</strong></font></div></td>
      <td width="17%">&nbsp;</td>
    </tr>
<%
String strErrForwarded = (String)request.getSession(false).getAttribute("err_");
if(strErrForwarded != null) {
	request.getSession(false).setAttribute("err_", null);
}
%>
    <tr> 
      <td>&nbsp;</td>
      <td height="45" colspan="3" bgcolor="#FFFFFF" style="font-weight:bold; font-size:18px; color:#FF0000" align="center"><%=WI.getStrValue(strErrForwarded)%>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="15%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="10%" bgcolor="#FFFFFF">Username</td>
      <td width="39%" bgcolor="#FFFFFF"> 
	  <input type="text" name="<%=strUserIDField%>"  class="username_field" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" autocomplete="off">
	  <input type="hidden" name="user_id"  value="<%=strUserIDField%>">
      <!--
	    <input type="text" name="user_id" class="username_field" onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  -->	  </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="22" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="22" bgcolor="#FFFFFF">Password</td>
      <td height="22" bgcolor="#FFFFFF"> 
	  <input type="password" name="<%=strPwdField%>"  class="password_field" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" autocomplete="off">
	  <input type="hidden" name="password"  value="<%=strPwdField%>">
	  <input type="hidden" name="is_secured" value="1"><!-- this is must to provide 1-->

<!--
        <input type="password" name="password" class="password_field" onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
-->	  </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="29" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="29" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="29" valign="middle" bgcolor="#FFFFFF"><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="image" src="../images/form_login.gif">
	  <br>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="3" bgcolor="#FFFFFF"><div align="center"><strong>New 
          user?</strong> Please see system administrator for your username and 
          password.</div></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="3" bgcolor="#FFFFFF"><div align="center"></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="3" bgcolor="#004488">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="body_color" value="#46689B">
<!-- relative to commfile -->
<input type="hidden" name="welcome_url" value="../administrators/bottom_content_welcome.jsp">
<input type="hidden" name="page_url" value="../administrators/bottom_content_welcome.jsp">
<input type="hidden" name="login_type" value="admin_staff">
</form>
<%}else{%>
<p align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"> 
  Current user : <b><%=strName%></b>. Please logout to change user or to continue.</font></p>
<%}%>
</body>
</html>
