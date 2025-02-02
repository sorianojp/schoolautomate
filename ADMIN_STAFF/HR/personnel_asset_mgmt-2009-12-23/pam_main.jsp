<%@ page language="java" import="utility.*"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Personnel Asset Management</title>
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
<script language="JavaScript" src="../../../../jscript/common.js"></script>

<body bgcolor="#D2AE72" class="bgDynamic">

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="2" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" >
				<strong>:::: HEALTH INSURANCE MANAGEMENT PAGE ::::</strong></font></div>
			</td>
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
			<td width="12%" height="25">&nbsp;</td>
			<td width="15%" align="right">Operation : </td>
			<td width="2%"  align="center">&nbsp;</td>
			<td width="71%"><a href="asset_items/create_item.jsp"> Assets Registry </a></td>
		</tr>
		<tr>
		  <td colspan="2" rowspan="3">&nbsp;</td>
		  <td height="25"  align="center">&nbsp;</td>
		  <td><a href="asset_items/pam_item_registry.jsp">PAM Item Registry </a></td>
	  </tr>
		<tr> 
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="issue_assets/issue_assets.jsp"> Issue Asset(s) </a></td>
		</tr>
		<tr> 
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="issued_assets_status/issued_asset_status.jsp"> Issued Asset(s) Status </a></td>
		</tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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