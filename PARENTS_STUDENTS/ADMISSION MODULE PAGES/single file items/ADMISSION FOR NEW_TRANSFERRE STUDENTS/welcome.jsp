<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Welcome</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>

<script language="JavaScript">
function LoadLeftFrame()
{
	//parent.leftFrame.location="./adm_new_transferee_links.jsp";
}
function Logout()
{
	document.logout.submit();
}
</script>
<body bgcolor="#9FBFD0" onLoad="LoadLeftFrame();">
<form action="../../../../commfile/logout.jsp" method="post" target="_parent" name="logout">
<%
String strUserId = (String)request.getSession(false).getAttribute("tempId");
String strName = (String)request.getSession(false).getAttribute("first_name");
if(strUserId == null || strUserId.trim().length() ==0)
{
	response.sendRedirect(response.encodeRedirectURL("../registration_page.jsp"));
	return;
}

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" bgcolor="#47768F">&nbsp;</td>
      <td height="28" colspan="3" bgcolor="#47768F"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          MY PERSONAL ONLINE ADMISSION PAGE ::::</strong></font></div></td>
      <td height="28" bgcolor="#47768F">&nbsp;</td>
    </tr>
    <tr> 
      <td height="28" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="28" colspan="3" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="28" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0"><div align="center"><strong></strong></div></td>
      <td height="25">&nbsp;</td>
      <td height="25"><div align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Welcome 
          <%=(String)request.getSession(false).getAttribute("first_name")%> to 
          </font><font color="#000000" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>your 
          personal online admission page</strong>!</font></strong></div></td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td width="8%" height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td width="4%"><p align="justify">&nbsp;</p>
        <p>&nbsp;</p></td>
      <td width="80%"><p align="justify"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Please 
          note that every activity is monitored closely. For any problem in the 
          system, contact System Administrator for details. Click the links under 
          MENU to select operation. It is recommended to logout by clicking the 
          logout button everytime you leave your PC.</font></p>
        <p align="justify"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">If 
          you do not agree with the conditions or you are not <b> <%=strUserId %> 
          </b> Please logout.</font></p></td>
      <td width="3%">&nbsp;</td>
      <td width="5%" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="28" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="logout_url" value="../PARENTS_STUDENTS/main_files/parents_students_bottom_content.jsp">
<input type="hidden" name="body_color" value="#9FBFD0">
<input type="hidden" name="login_type" value="temp_stud">

</form>
</body>
</html>
