<%@ page language="java" import="utility.*,hr.HRNotification,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
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
			"my_home","notifications.jsp");
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
	
	String strName = null;
	String strQty = null;
	String strType = null;
	String[] links = 
		{"../main/HR/memo/employee_circular.jsp?my_home=1",//memo
		"notifications/leave.jsp?my_home=1",//leave
		"notifications/overtime.jsp?my_home=1",//overtime
		"notifications/messages.jsp?my_home=1",//messages
		""};
	if(bolIsSchool) {
		links[0] = "";
		links[3] = "";
	}
	Vector vRetResult = new Vector();
	HRNotification not = new HRNotification();
	vRetResult = not.getAllNotifications(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
	if(vRetResult == null)
		strErrMsg = not.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="2" bgcolor="#A49A6A" align="center" class="footerDynamic">
			<font color="#FFFFFF" ><strong>:::: NOTIFICATIONS PAGE ::::</strong></font>			</td>
		</tr>
		<tr bgcolor="#FFFFFF"> 
			<td height="25" colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<%if(vRetResult!=null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
		<tr> 
			<td width="20%" height="25">&nbsp;</td>
		    <td height="25" colspan="2">
				<strong><font size="2" color="#FF0000">Total Notifications: <%=vRetResult.remove(0)%></font></strong>
			</td>
	    </tr>
		<tr> 
			<td height="25" colspan="2" align="right">&nbsp;</td>
			<td width="70%">&nbsp;</td>
		</tr>
		<%
			for(int i = 0; i <= 4 ; i++){
				strName = (String)vRetResult.remove(0);
				strQty  = (String)vRetResult.remove(0);
				strType = (String)vRetResult.remove(0);
				if(links[i].length() == 0) 
					continue;
		%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td width="70%"><a href="<%=links[i]%>"> <%=strName%>(<%=strQty%>)</a></td>
		</tr>
		<%}%>
	</table>
	<%}%>
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