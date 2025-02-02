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
<style type="text/css">
	a{
		text-decoration:none
	}
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function ViewInfo(strIsCollege, strCatgIndex){
		var pgLoc = "./budget_status_info.jsp?opner_form_name=form_&is_college="+strIsCollege+"&catg_index="+strCatgIndex+"&year="+document.form_.year.value;
		if(document.form_.budget_period.value.length > 0)
			pgLoc += "&budget_period="+document.form_.budget_period.value;
		
		var win=window.open(pgLoc,"ViewInfo",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}

	function ViewComparison(){		
		document.form_.view_comparison.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PrintPg(){
		//check for fiscal year
		if(document.form_.year.value.length == 0){
			alert("Please provide fiscal year information.");
			return;
		}
		
		//check that one show option must be checked
		if(!document.form_.view_colleges.checked && !document.form_.view_dept.checked){
			alert("Please select atleast one show option.");
			return;
		}
		
		document.form_.print_page.value = "1";
		document.form_.view_comparison.value = "";
		document.form_.submit();
	}

	function ReloadPage(){
		document.form_.view_comparison.value = "";
		document.form_.print_page.value = "";
		document.form_.submit();
	}

</script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./budget_status_comparison_print.jsp" />
	<% 
		return;}
	
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
	
	if(WI.fillTextValue("view_comparison").length() > 0){
		vRetResult = budgetReports.generateComparisonReport(dbOP, request);
		if(vRetResult == null)
			strErrMsg = budgetReports.getErrMsg();
		else{
			vColleges = (Vector)vRetResult.remove(0);
			vDepartments = (Vector)vRetResult.remove(0);
		}
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./budget_status_comparison.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><strong>
				<font color="#FFFFFF">:::: BUDGET STATUS COMPARISON ::::</font></strong></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Fiscal Year: </td>
			<td width="80%">
				<%
					strTemp = WI.fillTextValue("year");
					if(strTemp.length() == 0)
						strTemp = "-1";
				%>
				<select name="year" size="1" id="year" onChange="ReloadPage();">
					<option value="-1">Select fiscal year</option>
					<%=dbOP.loadComboYear(strTemp, 1, 3)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Budget Period: </td>
			<td>
				<%
					strTemp = 
						" from ac_budget_period where is_valid = 1 "+
						" and fiscal_year = "+WI.getStrValue(WI.fillTextValue("year"), "-1");
				%>
				<select name="budget_period">
          			<option value="">All Budget Periods</option>
          			<%=dbOP.loadCombo("budget_period_index","period_name", strTemp, WI.fillTextValue("budget_period"),false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Expense Name: </td>
			<td>
				<select name="catg_index" onChange="ReloadPage();">
          			<option value="">ALL</option>
          			<%=dbOP.loadCombo("catg_index","catg_name", " from ac_budget_setup_catg where is_valid = 1 ", WI.fillTextValue("catg_index"), false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Show: </td>
			<td>
				<%
					if(WI.fillTextValue("view_colleges").length() > 0)
						strTemp = " checked";				
					else
						strTemp = "";
				%>
				<input name="view_colleges" type="checkbox" value="1"<%=strTemp%>>&nbsp;College</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%
					if(WI.fillTextValue("view_dept").length() > 0)
						strTemp = " checked";				
					else
						strTemp = "";
				%>
				<input name="view_dept" type="checkbox" value="1"<%=strTemp%>>&nbsp;Department/Offices</td>
		</tr>
		<tr>
			<td height="40" colspan="2"></td>
			<td valign="middle">
				<a href="javascript:ViewComparison();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to view budget status comparison report.</font></td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a></td>
		</tr>
	</table>
<%}%>	
	
<%if(vRetResult != null && vRetResult.size() > 0 && bolShowCollege && vColleges.size() > 0){
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
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%><br>
				(<a href="javascript:ViewInfo('1', '<%=(String)vRetResult.elementAt(i)%>');">Approved Budget</a>)</td>
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
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%><br>
				(<a href="javascript:ViewInfo('0', '<%=(String)vRetResult.elementAt(i)%>');">Approved Budget</a>)</td>
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

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" >&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page">
	<input type="hidden" name="view_comparison">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>