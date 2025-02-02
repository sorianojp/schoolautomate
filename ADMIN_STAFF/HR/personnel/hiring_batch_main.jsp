<%@ page language="java" import="utility.*" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>

<body bgcolor="#D2AE72" class="bgDynamic">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#A49A6A">
    <td height="25" colspan="2" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
      ADMISSION - REGISTRATION MAIN PAGE ::::</strong></font></div></td>
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
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./create_hiring_batch.jsp">Manage Hiring Batch(add/edit/delete)</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./assign_hiring_batch.jsp">Assign Hiring Batch</a></td>
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
    <td width="1%" height="25" colspan="3" class="footerDynamic">&nbsp;</td>
  </tr>
</table>

</body>
</html>
