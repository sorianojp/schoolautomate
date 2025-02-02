<%@ page language="java" import="utility.*,Accounting.Budget,Accounting.BudgetReports,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Budget Details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
	String strYear = WI.fillTextValue("year");
	String strBudgetSetupIndex = WI.fillTextValue("budget_setup_index");	
	
	if(strYear.length() == 0 || strBudgetSetupIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Budget reference is not found. Please close this window and click link again from main window.</p>
		<%return;
	}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BUDGET"),"0"));
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
								"ACCOUNTING-BUDGET","view_budget_details.jsp");
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
	
	Vector vRetResult = null;
	Vector vBudgetInfo = null;
	Budget budget = new Budget();
	BudgetReports budgetReports = new BudgetReports();
	
	vBudgetInfo = budget.getBudgetInfo(dbOP, request);
	if(vBudgetInfo == null)
		strErrMsg = budget.getErrMsg();
	else{
		vRetResult = budgetReports.getUsedBudgetInfo(dbOP, request);
		if(vRetResult == null)
			strErrMsg = budgetReports.getErrMsg();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./view_budget_details.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><strong>
				<font color="#FFFFFF">:::: BUDGET DETAILS ::::</font></strong></div></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%"><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
		</tr>
	</table>

<%if(vBudgetInfo != null && vBudgetInfo.size() > 0){%>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong>Budget Information: </strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Expense Name: </td>
			<td width="77%"><%=(String)vBudgetInfo.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>:</td>
			<td><%=WI.getStrValue((String)vBudgetInfo.elementAt(4), "N/A")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department:</td>
			<td><%=WI.getStrValue((String)vBudgetInfo.elementAt(5), "ALL")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Max Budget Amt: </td>
			<td><%=CommonUtil.formatFloat((String)vBudgetInfo.elementAt(3), false)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Charge to: </td>
			<%
				Vector vTemp = (Vector)vBudgetInfo.elementAt(6);
				if(vTemp.size() == 0)
					strTemp = "";
				else{
					strTemp = vTemp.toString();
					strTemp = strTemp.substring(1, strTemp.length()-1);
				}
			%>
			<td><%=strTemp%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Remarks:</td>
			<td><div align="justify"><%=WI.getStrValue((String)vBudgetInfo.elementAt(2))%></div></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="8" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: BUDGET DETAIL LISTING ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>JV Date</strong></td>
			<td width="23%" align="center" class="thinborder"><strong>Reference No. </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="45%" align="center" class="thinborder"><strong>Particulars</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 5, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
		</tr>
	<%}%>
	</table>
	<%}
}%>

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" >&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="year" value="<%=strYear%>">
	<input type="hidden" name="budget_setup_index" value="<%=strBudgetSetupIndex%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>