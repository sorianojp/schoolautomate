<%@ page language="java" import="utility.*" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Step increment main page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
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
      PAYROLL :  STEP INCREMENT REPORTS MAIN PAGE ::::</strong></font></td>
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
  <!--
	<tr>
    <td height="25">&nbsp;</td>
    <td height="25" align="right">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../../configuration/step_increment/step_increment_main.jsp">MANAGE ELIGIBLE EMPLOYEES LIST </a></td>
  </tr>
	-->
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25" align="right">Operation : </td>
    <td align="center">&nbsp;</td>
    <td><a href="emplist_for_step_inc.jsp">MANAGE ELIGIBLE EMPLOYEES LIST </a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="emp_period_step_inc.jsp">STEP INCREMENTS FOR THE PERIOD  </a></td>
  </tr>
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