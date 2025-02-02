<%
String strErrMsg = null;
String strAuthType = (String)request.getSession(false).getAttribute("authTypeIndex");
if(request.getSession(false).getAttribute("userIndex") == null)
	strErrMsg = "You are already logged out. Please login again to view this page.";
else if(strAuthType != null && (strAuthType.equals("4") || strAuthType.equals("6")) )
	strErrMsg = "You are not authorized to view this page.";

if(strErrMsg != null) {%>
<font style="font-size:14px; color:#FF0000; font-weight:bold"><%=strErrMsg%></font>	
<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
        SETUP TAXES PAGE ::::</strong></font></div></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" width="12%">&nbsp;</td>
    <td width="21%" align="right">Operation : </td>
    <td align="center" width="2%">&nbsp;</td>
    <td width="71%"><a href="./tax_codes.jsp">Tax Codes </a></td>
  </tr>
<!--
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25" align="right">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="left"><a href="#" target="_self">Withholding Taxes</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="21%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td align="left"><a href="#" target="_self">Withholding Taxes - Expanded </a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="#">Input Taxes </a></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="left"><a href="#">Output Taxes </a></td>
  </tr>
-->  
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" width="1%">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

</body>
</html>
