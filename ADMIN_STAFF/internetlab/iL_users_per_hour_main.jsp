<%@ page language="java" import="utility.*"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-INTERNET LAB OPERATION",
								"iL_users_per_hour_main.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Internet Cafe Management",
															"INTERNET LAB OPERATION",request.getRemoteAddr(),
															"iL_users_per_hour_main.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}	
	//end of authenticaion code.
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3"><div align="center"><font color="#FFFFFF">
				<strong>:::: INTERNET CAFE REPORTS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="30%" align="right">OPERATIONS:</td>
			<td width="2%">&nbsp;</td>
			<td width="68%"><a href="reports/iL_users_per_hour.jsp" style="text-decoration:none">Daily</a></td>
		</tr>
		<tr>
			<td height="25" width="30%">&nbsp;</td>
			<td width="2%">&nbsp;</td>
			<td width="68%"><a href="reports/iL_users_per_hour_weekly.jsp" style="text-decoration:none">Weekly</a></td>
		</tr>
		<tr>
			<td height="25" width="30%">&nbsp;</td>
			<td width="2%">&nbsp;</td>
			<td width="68%"><a href="reports/iL_users_per_hour_monthly.jsp" style="text-decoration:none">Monthly</a></td>
		</tr>
		<tr>
			<td height="25" width="30%">&nbsp;</td>
			<td width="2%">&nbsp;</td>
			<td width="68%"><a href="reports/iL_users_per_hour_semestral.jsp" style="text-decoration:none">Semestral</a></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
	</table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
</body>
</html>
<%
dbOP.cleanUP();
%>