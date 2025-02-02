<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<%
String strErrMsg = null;
if(request.getSession(false).getAttribute("userIndex") == null) 
	strErrMsg = " You are already logged out. Please login again.";
else {
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4") || strAuthTypeIndex.equals("6"))
		strErrMsg = "Intruder Alert !!! You should not be here.";
}
%>
<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A" align="center"><font color="#FFFFFF" ><strong>::::
        DB DATA MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
<%
if(strErrMsg != null) {%>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="2" style="font-size:16px; font-weight:bold; color:#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;<%=strErrMsg%></td>
    </tr>
<%return;}%>

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
    <td width="8%" height="25">&nbsp;</td>
    <td width="12%" height="25" align="right">Operation : </td>
    <td width="4%">&nbsp;</td>
    <td width="76%"><a href="./migration_settings.jsp">DB Migration Setting</a></td>
  </tr>
  <tr> 
    <td width="8%" height="25">&nbsp;</td>
    <td width="12%" height="25">&nbsp;</td>
    <td width="4%">&nbsp;</td>
    <td width="76%"><a href="./return_old_records.jsp">Restore from Backup DB to Main DB</a></td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" width="1%">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
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
