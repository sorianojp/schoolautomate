<%@ page language="java" import="utility.*, hr.HRLighthouse, hr.HRNotification"%>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-EXIT INTERVIEW MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
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
			"Admin/staff-HR Management-Exit Interview Management-Exit Interview Main Page","exit_intv_main.jsp");
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
	
	HRLighthouse hrl = new HRLighthouse();
	HRNotification hrNot = new HRNotification();
%>

<body bgcolor="#D2AE72" class="bgDynamic">
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="2" bgcolor="#A49A6A" align="center" class="footerDynamic">
				<font color="#FFFFFF"><strong>:::: EXIT INTERVIEW MANAGEMENT PAGE ::::</strong></font></td>
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
			<td width="15%" height="25" align="right">Operation : </td>
			<td width="2%" align="center">&nbsp;</td>
			<td width="71%"><a href="./update_notify_list.jsp">Setup Exit Interview Notify List </a></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td height="25" align="right">&nbsp;</td>
		  <td align="center">&nbsp;</td>
		  <td><a href="../personnel/hr_exit_interview.jsp">Encode Employee Separation Details (1st Step)</a></td>
	  </tr>
		
	<%if(hrl.isOnNotifyList(dbOP, (String)request.getSession(false).getAttribute("userIndex"), 0)){
		int iPendingExitIntvCompletion = hrNot.subordinatePendingExitIntvForm(dbOP);
	%>
		<tr> 
			<td width="12%" height="25">&nbsp;</td>
			<td width="15%" height="25">&nbsp;</td>
			<td width="2%" align="center">&nbsp;</td>
			<td width="71%"><a href="update_exit_intv_main.jsp">Update Exit Interview Form Filled by Employee (Pending: <%=iPendingExitIntvCompletion%>) - 2nd step </a></td>
		</tr>
	<%}
	
	if(hrl.isPartOfNotifyChecklist(dbOP, (String)request.getSession(false).getAttribute("userIndex"))){
		int iPendingEmployeeChecklists = hrNot.subordinatePendingEmployeeLeavingChecklist(dbOP);
	%>
		<tr> 
			<td width="12%" height="25">&nbsp;</td>
			<td width="15%" height="25">&nbsp;</td>
			<td width="2%" align="center">&nbsp;</td>
			<td width="71%"><a href="./exit_intv_checklist_main.jsp">Employee Leaving Checklist (Pending: <%=iPendingEmployeeChecklists%>) - Last Step </a></td>
		</tr>
	<%}%>
		<tr> 
			<td width="12%" height="25">&nbsp;</td>
			<td width="15%" height="25">&nbsp;</td>
			<td width="2%" align="center">&nbsp;</td>
			<td width="71%"><a href="./emp_exit_intv_form.jsp">View Employee Exit Interview Form</a></td>
		</tr>>
	</table>
			
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" width="1%">&nbsp;</td>
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
