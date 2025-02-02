<%@ page language="java" import="utility.*,Accounting.BudgetReports,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Budget Status</title>
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
								"ACCOUNTING-BUDGET","budget_status_print.jsp");
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
	
	Vector vValues = null;
	Vector vRetResult = null;
	BudgetReports budgetReports = new BudgetReports();
	
	vRetResult = budgetReports.generateBudgetStatusReport(dbOP, request);
	if(vRetResult == null){%>
		<p style="font-size:16px; color:#FF0000;"><%=budgetReports.getErrMsg()%></p>
		<%return;
	}
	
	if(vRetResult != null && vRetResult.size() > 0){%>
	
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" align="center"><strong>::: BUDGET STATUS :::</strong></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
		  	<td align="right" style="font-size:9px;">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;</td>
 	  	</tr>
	</table>

	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<%	for(int i = 0; i < vRetResult.size(); i += 5){
			vValues = (Vector)vRetResult.elementAt(i+4);
	%>
	<tr>
		<td height="25" class="thinborderLEFT" colspan="4"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>: 
			<%=WI.getStrValue((String)vRetResult.elementAt(i+2), "ALL")%></td>
	</tr>
	<tr>
		<td height="25" class="thinborderBOTTOMLEFT" colspan="4">Department: 
			<%=WI.getStrValue((String)vRetResult.elementAt(i+3), "ALL")%></td>
	</tr>
	<tr>

		<td height="25" width="40%" align="center" class="thinborder">EXPENSE NAME</td>
		<td width="20%" align="center" class="thinborder">APPROVED BUDGET </td>
		<td width="20%" align="center" class="thinborder">USED BUDGET </td>
		<td width="20%" align="center" class="thinborder">BALANCE</td>
	</tr>
	<%for(int j = 0; j < vValues.size(); j += 5){%>
	<tr>
		<td height="25" class="thinborder"><%=(String)vValues.elementAt(j+1)%></td>
		<td class="thinborder"><%=CommonUtil.formatFloat((String)vValues.elementAt(j+2), false)%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vValues.elementAt(j+3), "&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vValues.elementAt(j+4), "&nbsp;")%></td>
	</tr>
	<%}}%>
	</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>