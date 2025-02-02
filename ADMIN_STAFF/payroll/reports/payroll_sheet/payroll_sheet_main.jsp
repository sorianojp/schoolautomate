<%@ page language="java" import="utility.*" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Sheet/Register Main Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
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
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
      PAYROLL SHEET MAIN PAGE ::::</strong></font></td>
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
    <td width="11%" height="25">&nbsp;</td>
    <td width="14%" height="25" align="right">Payroll Sheet : &nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="73%"><a href="./payroll_sheet_cgh_pt.jsp">Part-Time 
      Teaching Staff/ CI / Physician </a></td>
  </tr>
  <tr> 
    <td height="26">&nbsp;</td>
    <td height="26">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./payroll_sheet_cgh.jsp">Full-Time</a></td>
  </tr>
  <tr>
    <td height="26">&nbsp;</td>
    <td height="26">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./payroll_summary_cgh.jsp">Payroll Sheet Summary</a></td>
  </tr>
  <!--
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center"><div align="left"><a href="./payroll_slip_main.jsp">Regular Payroll 
        </a></div></td>
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
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="1%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
</body>
</html>