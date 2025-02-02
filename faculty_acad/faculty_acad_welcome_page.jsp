<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<script language="JavaScript">
function LoadLeftFrame()
{
	//parent.linkFrame.location="./admin_staff_main_links.jsp";
}
</script>
<%
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strName = (String)request.getSession(false).getAttribute("first_name");
if(strName == null) strName ="<NOT FOUND>";

%>
<body bgcolor="#93B5BB">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        FACULTY/ACADEMIC ADMIN MAIN PAGE::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4"><div align="center"><strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">WELCOME 
        <%=strName.toUpperCase()%> TO THE FACULTY/ACADEMIC ADMIN MAIN PAGE!</font></strong></div></td>
    </tr>
    
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp; </td>
      <td width="84%" height="25" colspan="-1"> <div align="justify"> 
          <p><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Please 
            note that every activity is monitored closely. For any problem in 
            the system, contact System Administrator for details. Click the links 
            under MENU to select operation. It is recommended to logout by clicking 
            the logout button everytime you leave your PC.</font></p>
          <p><font size="2" face="Verdana, Arial, Helvetica, sans-serif">If you 
            do not agree with the conditions or you are not <b> <%= strUserId %> 
            </b> Logout now.</font> </p>
        </div></td>
      <td width="8%" height="25" colspan="-1">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
</body>
</html>
