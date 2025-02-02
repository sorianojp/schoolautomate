<%@ page language="java" import="utility.*, Accounting.BudgetReports, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Budget Status Info</title>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	String strIsCollege = WI.fillTextValue("is_college");
	String strCatgIndex = WI.fillTextValue("catg_index");
	String strBudgetPeriod = WI.fillTextValue("budget_period");
	String strYear = WI.fillTextValue("year");
	
	if(strIsCollege.length() == 0 || strCatgIndex.length() == 0 || strYear.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Reference is not found. Please close this window and click link again from main window.</p>
		<%return;
	}	
	
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
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","budgetReports_status_info.jsp");
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
	
	BudgetReports budgetReports = new BudgetReports();
	
	strTemp = 
		" select catg_name from ac_budget_setup_catg "+
		" where is_valid = 1 and catg_index = "+strCatgIndex;
	String strExpenseName = dbOP.getResultOfAQuery(strTemp, 0);
	
	Vector vRetResult = budgetReports.getApprovedBudgetInfo(dbOP, request);
	if(vRetResult == null)
		strErrMsg = budgetReports.getErrMsg();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./budget_status_info.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>::::  APPROVED BUDGET INFORMATION ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Expense: </td>
			<td width="80%"><strong><%=strExpenseName%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" align="center" class="thinborder" width="35%">College</td>
			<td align="center" class="thinborder" width="35%">Department</td>
			<td align="center" class="thinborder" width="30%">Approved Budget</td>
		</tr>
	<%
	for(int i = 0; i < vRetResult.size(); i+=7){%>
		<tr>
			<%
				strTemp = (String)vRetResult.elementAt(i+3);
				strErrMsg = (String)vRetResult.elementAt(i+4);
				
				if(strTemp == null)
					strTemp = "&nbsp;";
				else
					strTemp += " (" + strErrMsg + ")";
			%>
			<td height="25" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
				strErrMsg = (String)vRetResult.elementAt(i+6);
				
				if(strTemp == null){
					if(strIsCollege.equals("1"))
						strTemp = "ALL";
					else
						strTemp = "&nbsp;";
				}
				else
					strTemp += " (" + strErrMsg + ")";
			%>
			<td class="thinborder"><%=strTemp%></td>
			<td class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), true)%></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="is_college" value="<%=strIsCollege%>" />
	<input type="hidden" name="catg_index" value="<%=strCatgIndex%>" />
	<input type="hidden" name="year" value="<%=strYear%>" />
	<input type="hidden" name="budget_period" value="<%=strBudgetPeriod%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>