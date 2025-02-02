<%@ page language="java" import="utility.*"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Sibling Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body bgcolor="#8C9AAA">
<%
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Sibling Management","main_sibling.jsp");
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
															"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
															"main_sibling.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../admin_staff/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{

		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
%>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F">
			<td height="25" align="center" colspan="4"><font color="#FFFFFF">
				<strong>::::  SIBLING MANAGEMENT ::::</strong></font></td>
		</tr>
		<tr> 
			<td height="25" colspan="4">&nbsp;</td>
		</tr>
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
			<td width="71%"><a href="link_sibling.jsp"> Link Sibling </a></td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td height="25"  align="center">&nbsp;</td>
		  <td><a href="search_sibling.jsp">Search Sibling </a></td>
	  	</tr>
		<tr>
		  <td height="25" colspan="4">&nbsp;</td>
	    </tr>
		<tr>
		  <td height="25" colspan="4">&nbsp;</td>
	  </tr>
	  <tr>
		  <td height="25" colspan="4">&nbsp;</td>
	  </tr>
	</table>
	
</body>
</html>
<%
dbOP.cleanUP();
%>