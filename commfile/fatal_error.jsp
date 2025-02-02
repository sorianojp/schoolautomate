<%@ page language="java" import="utility.WebInterface, java.util.Vector" %>
<%
String strErrMsg = new WebInterface().getStrValue((String)request.getSession(false).getAttribute("errorMessage"),"Error description not found.");
boolean bolLogout = true;
if(strErrMsg.indexOf("Not allowed to accept payment") > -1 || strErrMsg.indexOf("Not allowed to encode check encashment information") > -1)
	bolLogout = false;
if(bolLogout)
	request.getSession(false).removeAttribute("userId");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Fatal Error Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<meta http-equiv="refresh" content="10;url=javascript:GoHome();"> 
</head>
<script language="JavaScript">
function GoHome()
{
	parent.location="<%=(String)request.getSession(false).getAttribute("go_home")%>";
}
</script>
<body bgcolor="#BFCDD0">

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#869D9D"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        ERROR PAGE ::::</strong></font></div></td>
  </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25"><div align="center"><font size="3"><%=strErrMsg%><br>
        <br>
        </font></div></td>
  </tr>
<%if(bolLogout){%>
  <tr> 
    <td height="25"><div align="center">This page will be redirected to home page 
        in 10 seconds or <b><a href="javascript:GoHome();">click here </a></b>to 
        go to home page<br>
        </div></td>
  </tr>
<%}%>
  <tr> 
    <td height="25"><div align="center"></div></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#869D9D"><div align="center"><font color="#FFFFFF" ></font></div></td>
  </tr>
</table>
</body>
</html>
