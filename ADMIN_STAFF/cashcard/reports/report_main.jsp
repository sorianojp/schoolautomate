<%@ page language="java" import="utility.*"%>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Report Main</title>
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
a{
	text-decoration:none
}
</style>
</head>
<body bgcolor="#D2AE72" class="bgDynamic">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="2" bgcolor="#A49A6A" align="center" class="footerDynamic">
			<font color="#FFFFFF" ><strong>:::: CASH CARD REPORTS::::</strong></font>			</td>
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
			<td width="71%"><a href="./terminal_report.jsp"> Generate Report by Terminal</a></td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="./daily_report.jsp"> Generate Daily Report</a></td>
		</tr>
		
		<tr>
			<td colspan="2">&nbsp;</td>
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="./user_transaction.jsp"> Generate User Transaction</a></td>
		</tr>
		
		<tr>
			<td colspan="2">&nbsp;</td>
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="./list_of_blocked_user.jsp"> Generate Blocked Users</a></td>
		</tr>	
		<tr>
			<td colspan="2">&nbsp;</td>
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="./load_adjustment_report.jsp"> Generate Load Adjustment Report</a></td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="./floating_orders.jsp"> Generate Floating Orders</a></td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="./alert_level.jsp"> Alert Level</a></td>
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