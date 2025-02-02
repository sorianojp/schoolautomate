<%@ page language="java" import="utility.*,Accounting.BudgetReports,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Budget Status Comparison</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
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
								"ACCOUNTING-BUDGET","budget_status_comparison.jsp");
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
	
	double dTemp = 0d;
	double dRowTotal = 0d;
	Vector vColleges = null;
	Vector vDepartments = null;
	Vector vRetResult = null;
	Vector vValues = null;
	BudgetReports budgetReports = new BudgetReports();
	
	boolean bolShowCollege = WI.fillTextValue("view_colleges").equals("1");
   	boolean bolShowDept = WI.fillTextValue("view_dept").equals("1");
	
	vRetResult = budgetReports.generateComparisonReport(dbOP, request);
	if(vRetResult == null)
		strErrMsg = budgetReports.getErrMsg();
	else{
		vColleges = (Vector)vRetResult.remove(0);
		vDepartments = (Vector)vRetResult.remove(0);
	}

	if(vRetResult != null && vRetResult.size() > 0){%>
		<table width="100%" cellpadding="0" cellspacing="0">
			<tr>
				<td height="25" align="center"><strong>::: BUDGET STATUS COMPARISON :::</strong></td>
			</tr>
			<tr>
				<td height="15">&nbsp;</td>
			</tr>
			<tr>
		  		<td align="right" style="font-size:9px;">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;</td>
 	 	 	</tr>
		</table>
	<%}
	
	if(vRetResult != null && vRetResult.size() > 0 && bolShowCollege && vColleges.size() > 0){
		double[] dTotal = new double[vColleges.size()/3];
		double dGrandTotal = 0d;
%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" align="center" class="thinborder" width="20%"><strong>EXPENSE NAME</strong></td>
		<%for(int iCol = 0; iCol < vColleges.size(); iCol += 3){%>
			<td align="center" class="thinborder" width="8%"><strong><%=(String)vColleges.elementAt(iCol+1)%></strong></td>
		<%}%>
			<td align="center" class="thinborder" width="10%"><strong>TOTAL</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 4){
		dRowTotal = 0d;
		vValues = (Vector)vRetResult.elementAt(i+2);
	%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		<%for(int j = 0; j < vValues.size(); j++){
			strTemp = (String)vValues.elementAt(j);
			dRowTotal += Double.parseDouble(strTemp);
			dTotal[j] += Double.parseDouble(strTemp);
			
			if(Double.parseDouble(strTemp) <= 0)
				strTemp = "&nbsp;";
			else
				strTemp = CommonUtil.formatFloat(strTemp, false);
		%>		
			<td class="thinborder"><%=strTemp%></td>
		<%}
		
			dGrandTotal += dRowTotal;
		%>
			<td class="thinborder"><%=CommonUtil.formatFloat(dRowTotal, false)%></td>
		</tr>
	<%}%>
		<tr>
			<td height="25" class="thinborder">TOTAL</td>
		<%for(int i = 0; i < dTotal.length; i++){
			if(dTotal[i] <= 0)
				strTemp = "&nbsp;";
			else
				strTemp = CommonUtil.formatFloat(dTotal[i], false);
		%>
			<td class="thinborder"><%=strTemp%></td>
		<%}%>
			<td class="thinborder"><%=CommonUtil.formatFloat(dGrandTotal, false)%></td>
		</tr>
	</table>
<%}

if(vRetResult != null && vRetResult.size() > 0 && bolShowDept && vDepartments.size() > 0){
	double[] dTotal = new double[vDepartments.size()/3];
	double dGrandTotal = 0d;
%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" align="center" class="thinborder" width="20%"><strong>EXPENSE NAME</strong></td>
		<%for(int iCol = 0; iCol < vDepartments.size(); iCol += 3){%>
			<td align="center" class="thinborder" width="8%"><strong><%=(String)vDepartments.elementAt(iCol+1)%></strong></td>
		<%}%>
			<td align="center" class="thinborder" width="10%"><strong>TOTAL</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 4){
		dRowTotal = 0d;
		vValues = (Vector)vRetResult.elementAt(i+3);
	%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		<%for(int j = 0; j < vValues.size(); j++){
			strTemp = (String)vValues.elementAt(j);
			dRowTotal += Double.parseDouble(strTemp);
			dTotal[j] += Double.parseDouble(strTemp);
			
			if(Double.parseDouble(strTemp) <= 0)
				strTemp = "&nbsp;";
			else
				strTemp = CommonUtil.formatFloat(strTemp, false);
		%>		
			<td class="thinborder"><%=strTemp%></td>
		<%}
		
			dGrandTotal += dRowTotal;
		%>
			<td class="thinborder"><%=CommonUtil.formatFloat(dRowTotal, false)%></td>
		</tr>
	<%}%>
		<tr>
			<td height="25" class="thinborder">TOTAL</td>
		<%for(int i = 0; i < dTotal.length; i++){
			if(dTotal[i] <= 0)
				strTemp = "&nbsp;";
			else
				strTemp = CommonUtil.formatFloat(dTotal[i], false);
		%>
			<td class="thinborder"><%=strTemp%></td>
		<%}%>
			<td class="thinborder"><%=CommonUtil.formatFloat(dGrandTotal, false)%></td>
		</tr>
	</table>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
