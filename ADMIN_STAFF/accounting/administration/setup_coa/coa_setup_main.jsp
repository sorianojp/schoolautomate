<%@ page language="java" import="utility.*"%>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COA SET-UP PAGE</title>
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
a{
	text-decoration: none
}
</style>
</head>
<body bgcolor="#D2AE72" class="bgDynamic">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="2" bgcolor="#A49A6A" align="center" class="footerDynamic">
			<font color="#FFFFFF" ><strong>:::: COA SET-UP PAGE ::::</strong></font>			</td>
		</tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25" colspan="4">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" colspan="4">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" colspan="2" align="right">Operation : </td>
			<td width="2%"  align="center">&nbsp;</td>
			<td width="71%"><a href="./coa_setup_segment.jsp"> Setup COA Segments </a></td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="./coa_setup_country_code.jsp"> Setup COA Country Code </a></td>
		</tr>
		<tr>
		  	<td colspan="2">&nbsp;</td>
		  	<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="./coa_setup_acct_classification.jsp"> Setup COA Account Classification </a></td>
		</tr>
		<tr>
		  	<td colspan="2">&nbsp;</td>
		  	<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="./coa_setup_sub_accounts.jsp"> Setup COA Sub-Accounts </a></td>
		</tr>
		<tr>
		  	<td colspan="2">&nbsp;</td>
		  	<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="./coa_setup_cost_centers.jsp"> Setup COA Unit Centers </a></td>
		</tr>
		<tr>
		  	<td colspan="2">&nbsp;</td>
		  	<td height="25"  align="center">&nbsp;</td>
		  	<td><a href="./move_coa.jsp"> MOVE COA </a></td>
	  </tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A" class="footerDynamic"> 
			<td width="1%" height="25">&nbsp;</td>
		</tr>
	</table>
</body>
</html>