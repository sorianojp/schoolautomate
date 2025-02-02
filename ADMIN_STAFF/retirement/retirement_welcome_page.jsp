<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<%
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strName = (String)request.getSession(false).getAttribute("first_name");
if(strName == null) strName ="<NOT FOUND>";

%>

<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25"  colspan="3"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        RETIREMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25"  colspan="3"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font></td>
    </tr>
    <tr > 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <%
if(strUserId == null){%>
    <tr > 
      <td height="25" colspan="3" align="center">
	  <font size="3" face="Verdana, Arial, Helvetica, sans-serif">You are already logged out. Please login again.</font></td>
    </tr>
<%}else{%>

    <tr > 
      <td height="25"  colspan="3"><div align="center"><strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">WELCOME 
        <%=strName%> TO THE RETIREMENT PAGE!</font></strong></div></td>
    </tr>
    <tr > 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td  width="8%">&nbsp;</td>
      <td width="84%" height="25"> <div align="justify"> 
          <p><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Please 
            note that every activity is monitored closely. For any problem in 
            the system, contact System Administrator for details. Click the links 
            under MENU to select operation. It is recommended to logout by clicking 
            the logout button everytime you leave your PC.</font></p>
          
        <p><font size="2" face="Verdana, Arial, Helvetica, sans-serif">If you 
          do not agree with the conditions or you are not <b> <%=strUserId%></b>, 
          please logout.</font></p>
        </div></td>
      <td width="8%">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
<%}%>    <tr > 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
  </table>
</body>
</html>
