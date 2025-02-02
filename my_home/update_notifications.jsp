<%@ page language="java" import="utility.*, java.util.Vector, hr.HRNotification, hr.HRLighthouse"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
		
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Health Insurance Tracking</title>
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
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strMyHome = WI.fillTextValue("my_home");
	String strLeave = null;
	String strOT = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../commfile/fatal_error.jsp");
		return;
	}
	
	if (bolMyHome)
		iAccessLevel = 1;
	
	if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"my_home","update_notifications.jsp");
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
		
	Vector vTemp = new Vector();
		
	HRNotification hrNot = new HRNotification();
	HRLighthouse hrl = new HRLighthouse();
	
	String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
	
	vTemp = hrNot.subordinatePendingLeaveApps(dbOP, strUserIndex);
	if(vTemp != null)
		strLeave = (String)vTemp.elementAt(0);
	else
		strErrMsg = "Error in retrieving number of subordinate pending leave applications.";
		
	int iOT = hrNot.subordinatePendingOTApps(dbOP, strUserIndex);
	if(iOT >= 0)
		strOT = ""+iOT;
	else
		strErrMsg = "Error in retrieving number of subordinate pending overtime applications.";
		
	int iPendingPerfEval = hrNot.subordinatePendingPerfEval(dbOP, strUserIndex);
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./update_notifications.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="2" bgcolor="#A49A6A" align="center" class="footerDynamic">
			<font color="#FFFFFF" ><strong>:::: NOTIFICATIONS MANAGEMENT PAGE ::::</strong></font></td>
		</tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25" colspan="4">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" colspan="4">&nbsp;</td>
		</tr>
	<%
	//the overtime and the leave applications can both be accepted or rejected by any hr officer
	if(hrNot.isImmediateSupervisor(dbOP, strUserIndex)){
		if(strLeave!=null){%>
		<tr> 
			<td height="25" colspan="2" align="right">Operation : </td>
			<td width="2%"  align="center">&nbsp;</td>
			<td width="71%"><a href="notifications/update_leave.jsp?my_home=1"> Update Leave Applications (<%=strLeave%>)</a></td>
		</tr>
		<%}
		
		if(strOT!=null){%>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="<%if(bolIsSchool){%>../ADMIN_STAFF/e_dtr<%}else{%>../main/edtr<%}%>/overtime/batch_approve_ot.jsp?my_home=1&status=2&from_batch=1"> Update Overtime Applications (<%=strOT%>)</a></td>
		</tr>
		<%}
	}
	
	//the following methods are only accessible if schoolcode is that of Lighthouse Software Cebu, Inc.
	if(strSchCode.startsWith("LHS")){
		
		//one can only access the pending performance evaluations if he/she is a direct supervisor
		//of a person who has submitted his/her self performance evaluation
		if(hrNot.isImmediateSupervisor(dbOP, strUserIndex)){%>		
		<tr>
			<td colspan="2">&nbsp;</td>
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="../main/HR/evaluations_mgmt/pending_perf_evaluations.jsp?my_home=1"> Performance Evaluation (<%=iPendingPerfEval%>)</a></td>
		</tr>		
		<%}
		
		//if person who logged in is the exit interview in-charge, 
		//then allow that person to see pending exit interview forms
		if(hrl.isOnNotifyList(dbOP, strUserIndex, 0)){
			int iPendingExitIntvCompletion = hrNot.subordinatePendingExitIntvForm(dbOP);
		%>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="../main/HR/exit_interview/update_exit_intv_main.jsp?my_home=1"> Pending Exit Interview Form Completion (<%=iPendingExitIntvCompletion%>)</a></td>
		</tr>
		<%}
		
		//if the person who logged in is one of the persons in-charge of the exit interview checklist,
		//then allow him/her to see this link.
		if(hrl.isPartOfNotifyChecklist(dbOP, strUserIndex)){
			int iPendingExitChecklist = hrNot.subordinatePendingEmployeeLeavingChecklist(dbOP);
		%>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td width="2%" height="25"  align="center">&nbsp;</td>
			<td width="71%"><a href="../main/HR/exit_interview/exit_intv_checklist_main.jsp?my_home=1"> Pending Employee Leaving Checklist (<%=iPendingExitChecklist%>)</a></td>
		</tr>	
		<%}
	}%>	
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
	
	<input type="hidden" name="my_home" value="<%=strMyHome%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>