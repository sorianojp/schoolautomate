<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<%
String strUserId = (String)request.getSession(false).getAttribute("userId");
if(strUserId == null)
{%>
		<jsp:forward page="./administrators_contentFrame.jsp?errorMessage=You%20are%20loggedout.%20Please%20login%20again." />
<%}		
String strName = (String)request.getSession(false).getAttribute("first_name");
if(strName == null) strName ="<NOT FOUND>";

%>
<body bgcolor="#46689B">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#004488"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: 
          ADMIN/STAFF MAIN PAGE::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="3"><div align="center"><strong><font size="3">WELCOME 
          <%=strName.toUpperCase()%> TO THE ADMIN/STAFF MAIN PAGE!</font></strong></div></td>
    </tr>
    
    <tr > 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25">&nbsp; </td>
      <td width="84%" height="25"> <div align="justify"> 
          <p>Please 
            note that every activity is monitored closely. For any problem in 
            the system, contact System Administrator for details. Click the links 
            under MENU to select operation. It is recommended to logout by clicking 
            the logout button everytime you leave your PC.</p>
          <p>If you 
            do not agree with the conditions or you are not <b> <%= strUserId %> 
            </b> Logout now. </p>
        </div></td>
      <td width="8%" height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    
    <tr bgcolor="#004488"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
</body>
</html>
