<%@ page language="java" import="utility.*"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css" />
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css" />
<title>Search</title>
<style type="text/css">
	a{
		text-decoration: none
	}
</style>
</head>
<%	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
%>
<body bgcolor="#D2AE72">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td width="100%" height="25" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SEARCH  ::::</strong></font></div></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
		<tr>
			<td colspan="3" height="25">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="3" height="25">&nbsp;</td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">Operation:</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./project_search.jsp">Search Projects</a></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td height="25"><a href="./team_search.jsp">Search Teams</a></td>
		</tr>
		<tr>
			<td colspan="3" height="25">&nbsp;</td>
		</tr>
	</table>

	<table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
</body>
</html>