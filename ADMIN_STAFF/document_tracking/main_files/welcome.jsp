<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<body bgcolor="#D2AE72">
<%
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strName = (String)request.getSession(false).getAttribute("first_name");
if(strName == null)
	strName ="<NOT FOUND>";

%><form>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr bgcolor="#A49A6A"> 
      <td height="25"  colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: DOCUMENT MANAGEMENT SYSTEM ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
<%
if(strUserId == null){%>
    <tr > 
      <td height="25" colspan="3" align="center">
	  <font size="3" face="Verdana, Arial, Helvetica, sans-serif">You are already logged out. Please login again.</font></td>
    </tr>
<%}else{%>
    <tr> 
      <td height="25"  colspan="3"><div align="center"><strong><font size="3">WELCOME 
          <%=strName.toUpperCase()%> TO THE DOCUMENT MANAGEMENT SYSTEM!</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="5%">&nbsp;</td>
      <td width="91%" height="25"> <div align="justify"> 
          Please 
            note that every activity is monitored closely. For any problem in 
            the system, contact System Administrator for details. Click the links 
            under MENU to select operation. It is recommended to logout by clicking 
            the logout button everytime you leave your PC.
          <p>If you 
            do not agree with the conditions or you are not <b><%= strUserId %></b>, Logout now. </p>
          </div></td>
      <td width="4%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" align="center">&nbsp;</td>
    </tr>
<%}%>    
    
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
