<%
String strTempStudIndex = (String)request.getSession(false).getAttribute("tempIndex");
if(strTempStudIndex != null) {
	response.sendRedirect("../ADMISSION MODULE PAGES/single file items/ADMISSION FOR NEW_TRANSFERRE STUDENTS/welcome.jsp");
	return;
}
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strName =(String)request.getSession(false).getAttribute("first_name");
if(strName == null) strName = strUserId;
if(strName == null) strName = "";

if(strUserId != null && strUserId.length()> 0) {
	response.sendRedirect("./welcome_stud.jsp");
}


String strUserIDField = "_"+Long.toString(new java.util.Date().getTime());
String strPwdField    = strUserIDField + "0";


String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
utility.WebInterface WI = new utility.WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Schoolautomate - Student-Parent Login Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="login_new.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script>
function LoadPage()
{
	//parent.leftFrame.location="../ADMISSION MODULE PAGES/single file items/ADMISSION FOR NEW_TRANSFERRE STUDENTS/adm_new_transferee_links.jsp";
	parent.rightFrame.location="../ADMISSION MODULE PAGES/single file items/registration_new.jsp";
}
function FocusID()
{
	if(document.login.<%=strUserIDField%>) 
		document.login.<%=strUserIDField%>.focus();
}
  </script>
<body onLoad="FocusID()">
<%if(strUserId == null || strUserId.trim().length() == 0 || (strAuthIndex.compareTo("4") !=0 && strAuthIndex.compareTo("6") !=0) ) {
	String strErrForwarded = (String)request.getSession(false).getAttribute("err_");
	if(strErrForwarded != null)
		request.getSession(false).setAttribute("err_", null);
%>
<div class='maincontainer'>
<div class='holderlogin'>
<div class='signage'>Student/Parent/New Student Login</div>
<div class='boxlogin'>
<div style="font-weight:bold; font-size:16px; height:25px;"><%=WI.getStrValue(strErrForwarded)%></div>
<!--
	<div class='boxlabel'>LOGIN</div>
-->
<div class='boxtable'>
<form name="login"  action="../../commfile/login.jsp" method="post" target="_parent">
<table width='100%' cellspacing='0' cellpadding='0' border='0'>
	<tr>
		<td width='30%' align='right'><div class='labellogin'>Username</div></td>
		<td width='70%'><input type='box' class='inputlogin' name="<%=strUserIDField%>"  autocomplete="off">
		<input type="hidden" name="user_id"  value="<%=strUserIDField%>">
		</td>
	</tr>
	<tr>
		<td width='30%' align='right'><div class='labellogin'>Password</div></td>
		<td width='70%'><input type='password' class='inputlogin' name="<%=strPwdField%>" autocomplete="off">
		 <input type="hidden" name="password"  value="<%=strPwdField%>">
	  	<input type="hidden" name="is_secured" value="1"><!-- this is must to provide 1-->
	</td>
	</tr>
	<tr>
		<td width='30%' align='right'>&nbsp;</td>
		<td width='70%' height="50" valign="bottom"><input type='submit' value='Login Now'></td>
	</tr>
	<tr>
		<td width='30%' align='right'>&nbsp;</td>
		<td width='70%' height="35" valign="bottom"><a href="javascript:LoadPage();"><font style="color:#000000">New User? Click here to Register.</font></a></td>
	</tr>
</table>
<input type="hidden" name="body_color" value="#9FBFD0">
<!-- relative to commfile -->
<input type="hidden" name="welcome_url" value="../PARENTS_STUDENTS/main_files/login_success.htm">
<input type="hidden" name="page_url" value="../PARENTS_STUDENTS/main_files/parents_students_bottom_content.htm">
<input type="hidden" name="login_type" value="parent_student">
</form>
</div>
</div>

<br>&nbsp;
</div>

</div>
<%}%>

</body>
</html>
