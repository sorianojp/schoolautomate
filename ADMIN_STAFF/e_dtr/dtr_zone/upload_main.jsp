<%@ page language="java" import="utility.*" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Upload Main</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record-DTR ZONING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record"),"0"));
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
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-eDaily Time Record-DTR ZONING-Upload Main","upload_main.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="2" bgcolor="#A49A6A" align="center" class="footerDynamic">
			<font color="#FFFFFF" ><strong>:::: UPLOAD MANAGEMENT PAGE::::</strong></font>			</td>
		</tr>
		<tr bgcolor="#FFFFFF"> 
			<td height="25" colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25" align="right">&nbsp;</td>
			<td colspan="2"><font color="#FF0000">Operations</font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td><a href="./upload_pending.jsp">Pending Uploads</a></td>
		</tr>
		<tr>
			<td height="25" width="25%">&nbsp;</td>
			<td width="15%">&nbsp;</td>
		    <td width="70%"><a href="./upload_hist.jsp">Upload History</a></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td colspan="2">&nbsp;</td>
	  </tr>
<%if(strSchCode.startsWith("VMUF")){%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td style="font-weight:bold; font-size:10px; color:#0000FF"><a href="./terminal_query_wnd.jsp">Query window for Offline location</a></td>
	  </tr>
<%}%>
<!--
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td style="font-weight:bold; font-size:10px; color:#0000FF"><a href="./terminal_query_wnd.jsp">Trigger File Download</a></td>
	  </tr>
-->
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
<%
dbOP.cleanUP();
%>