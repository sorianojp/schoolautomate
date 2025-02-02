<%
if(true) {
	response.sendRedirect("./login_new.jsp");
	return;
}
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strName =(String)request.getSession(false).getAttribute("first_name");
if(strName == null) strName = strUserId;
if(strName == null) strName = "";



String strUserIDField = "_"+Long.toString(new java.util.Date().getTime());
String strPwdField    = strUserIDField + "0";


String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
utility.WebInterface WI = new utility.WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript">
function LoadPage()
{
	parent.leftFrame.location="../ADMISSION MODULE PAGES/single file items/ADMISSION FOR NEW_TRANSFERRE STUDENTS/adm_new_transferee_links.jsp";
	parent.rightFrame.location="../ADMISSION MODULE PAGES/single file items/registration_page.jsp";
}
function FocusID()
{
	<%
	if(strUserId == null || strUserId.trim().length() == 0 || (strAuthIndex.compareTo("4") !=0 && strAuthIndex.compareTo("6") !=0) )
	{%>
		document.login.<%=strUserIDField%>.focus();
	<%}%>
}
</script>
<body bgcolor="#9FBFD0" onLoad="javascript:FocusID();">
<%if(strUserId == null || strUserId.trim().length() == 0 || (strAuthIndex.compareTo("4") !=0 && strAuthIndex.compareTo("6") !=0) ) {%>
<form name="login"  action="../../commfile/login.jsp" method="post" target="_parent">
  <div align="center"> 
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr> 
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr> 
        <td>&nbsp;</td>
        <td height="25" colspan="3">&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr> 
        <td>&nbsp;</td>
        <td height="25" colspan="3">&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr> 
        <td width="17%">&nbsp;</td>
        <td height="25" colspan="3" bgcolor="#47768F"><div align="center"><font color="#FFFFFF" size="3"><strong>Please 
            Login</strong></font></div></td>
        <td width="17%">&nbsp;</td>
      </tr>
<%
String strErrForwarded = (String)request.getSession(false).getAttribute("err_");
if(strErrForwarded != null) {
	request.getSession(false).setAttribute("err_", null);
}
%>
      <tr align="center"> 
        <td>&nbsp;</td>
      		<td height="45" colspan="3" bgcolor="#FFFFFF" style="font-weight:bold; font-size:18px; color:#FF0000"><%=WI.getStrValue(strErrForwarded)%>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr> 
        <td>&nbsp;</td>
        <td width="14%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
        <td width="11%" valign="middle" bgcolor="#FFFFFF">Username</td>
        <td width="41%" valign="bottom" bgcolor="#FFFFFF">
	  <input type="text" name="<%=strUserIDField%>"  class="username_field" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" autocomplete="off">
	  <input type="hidden" name="user_id"  value="<%=strUserIDField%>">
<!--
	  <input type="text" name="user_id" class="username_field" onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
-->	  </td>
        <td>&nbsp;</td>
      </tr>
      <tr> 
        <td>&nbsp;</td>
        <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
        <td valign="middle" bgcolor="#FFFFFF">Password</td>
        <td bgcolor="#FFFFFF">
	  <input type="password" name="<%=strPwdField%>"  class="password_field" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" autocomplete="off">
	  <input type="hidden" name="password"  value="<%=strPwdField%>">
	  <input type="hidden" name="is_secured" value="1"><!-- this is must to provide 1-->
<!--
	  	<input type="password" name="password" class="password_field" onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
-->		</td>
        <td>&nbsp;</td>
      </tr>
      <tr> 
        <td>&nbsp;</td>
        <td height="36" bgcolor="#FFFFFF">&nbsp;</td>
        <td bgcolor="#FFFFFF">&nbsp;</td>
        <td height="36" valign="bottom" bgcolor="#FFFFFF"><br><input type="image" src="../../images/form_login.gif"> 
          &nbsp;&nbsp;<font size="1"><em><b>(for enrolled students/parents only)</b></em></font><br>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr> 
        <td>&nbsp;</td>
        <td height="20" bgcolor="#FFFFFF">&nbsp;</td>
        <td bgcolor="#FFFFFF">&nbsp;</td>
        <td height="20" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td colspan="3" height="20" bgcolor="#FFFFFF"><div align="center">New 
            User?&nbsp;<a href="javascript:LoadPage();"><b>Click here to Register/Login</b></a> 
            </div></td>
      </tr>
      <tr> 
        <td>&nbsp;</td>
        <td colspan="3" height="20" bgcolor="#FFFFFF"></td>
      </tr>
      <tr> 
        <td>&nbsp;</td>
        <td height="25" bgcolor="#47768F">&nbsp;</td>
        <td bgcolor="#47768F">&nbsp;</td>
        <td height="25" valign="bottom" bgcolor="#47768F">&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
    </table>
  </div>
<!--  
  <table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr> 
		<td height="50">&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
  	</tr>
	<tr>
	  <td height="50"><a href="javascript:onlinePmtHelp();"><img src="./olfu_one_pay.jpg" border="0"></a></td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
  </table>
-->
   
<input type="hidden" name="body_color" value="#9FBFD0">
<!-- relative to commfile -->
<input type="hidden" name="welcome_url" value="../PARENTS_STUDENTS/main_files/login_success.htm">
<input type="hidden" name="page_url" value="../PARENTS_STUDENTS/main_files/parents_students_bottom_content.htm">
<input type="hidden" name="login_type" value="parent_student">
</form>
<%}%>
</body>
</html>
