<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Change Password</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">

<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}
-->
</style>
</head>
<script language="JavaScript">
function FormatPK()
{
	//var strProdKey = document.form_.p_key.value;
	//if(strProdKey.length <
}
</script>
<body bgcolor="#449999" onLoad="document.form_.p_key.focus();">
<form name="form_" action="./register.jsp" method="post">
<%@ page language="java" import="utility.*"%>
<%
LicenseFile lF        = new LicenseFile();
String strProdID      = null;
String strProdKey     = request.getParameter("p_key");
String strMessage     = null;
String strErrMsg      = null;//only if error.. 
if(strProdKey == null)
	strProdKey = "";
boolean bolIsLicensed = false;
if(lF.isLicensed(true)) {
	bolIsLicensed = true;
	strMessage = "Product is already registered.";
}

strProdID = lF.getProdID();

if (!bolIsLicensed && strProdKey.length() > 0) {
	//// register the product.. 
	if(!lF.registerProduct(request))
		strErrMsg = lF.getErrMsg();
	else	
		strMessage = "Product successfully registered.";
}

lF.cleanUP();
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><div align="center"><strong>:::: REGISTRATION PAGE - REGISTER YOUR PRODUCT ::::</strong></div></td>
    </tr>
</table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><p>&nbsp;</p>      </td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp; </td>
    </tr>
<%
if(strErrMsg != null) {%>
    <tr> 
      <td height="25" colspan="4">&nbsp; <font size="4"><%=strErrMsg%></font></td>
    </tr>
<%return;}%>
    <tr> 
      <td width="12%" height="37">&nbsp;</td>
      <td width="17%">Product ID</td>
      <td width="71%" colspan="2" style="font-weight:bold; font-size:14px; color:#AAAAAA"><%=strProdID%></td>
    </tr>
    <tr> 
      <td height="37">&nbsp;</td>
      <td>Prodcut Key </td>
      <td colspan="2"><input name="p_key" type="text_box" size="32" maxlength="32" class="textbox_noborder" style="font-size:17px"
	  onKeyUp="FormatPK();"></td>
    </tr>
    <tr> 
      <td height="37">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><input type="image" src="../images/save.gif" width="48" height="28"> 
        <font size="1">click to save new password</font></td>
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
if(strMessage != null){%>
        <%=strMessage%> <a href="../" target="_parent">Click here to login</a> 
<%}%>
        </font></strong></td>
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
  </table>

</form>
</body>
</html>
