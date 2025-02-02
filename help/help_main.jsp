<%@ page language="java" import="utility.*"%>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Help</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/reportlink.css" rel="stylesheet" type="text/css">
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
		<tr bgcolor="#A49A6A" class="footerDynamic">
		  <td height="25" colspan="2" bgcolor="#A49A6A" class="footerDynamic">
		  	<div align="center"><font color="#FFFFFF" ><strong>:::: HELP MANAGEMENT PAGE ::::</strong></font></div></td>
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
			<td width="71%"><a href="manage_links.jsp"> Manage Links </a></td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="manage_system_help.jsp"> Manage System Help </a></td>
		</tr>
		<tr>
		  <td colspan="2">&nbsp;</td>
		  <td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="quick_help.jsp">Quick Help </a></td>
		</tr>
		<tr>
		  <td colspan="2">&nbsp;</td>
		  <td width="2%" height="25"  align="center">&nbsp;</td>
		  <!--<td width="71%"><a href="search_help.jsp"> Search Help </a></td>-->
		  <td width="71%"><a href="search_help.jsp"> Search Help </a></td>
		</tr>
		<tr>
		  <td colspan="2">&nbsp;</td>
		  <td width="2%" height="25" align="center">&nbsp;</td>
		  <td width="71%"><a href="manage_faq.jsp">Manage FAQ </a></td>
		</tr>
		<tr>
		  <td colspan="2">&nbsp;</td>
		  <td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="search_faq.jsp">Search FAQ </a></td>
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