<%@ page language="java" import="utility.*, Accounting.billing.BillingTsuneishi, java.util.Vector"%>
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
<title>Expense Distribution Mgmt</title>
<style type="text/css">
.expenses {
	height:120px; overflow:auto; width:auto; background-color:#FFFFFF;
}
.distributions {
	height:120px; overflow:auto; width:auto; background-color:#FFFFFF;
}
</style>
</head>

<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function checkAllExp() {
		var maxDisp = document.form_.exp_count.value;
		var bolIsSelAll = document.form_.selAllExp.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.exp_'+i+'.checked='+bolIsSelAll);
	}
	
	function checkAllDist() {
		var maxDisp = document.form_.dist_count.value;
		var bolIsSelAll = document.form_.selAllDist.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.dist_'+i+'.checked='+bolIsSelAll);
	}
	
	function GenerateReport(){
		document.form_.print_page.value = "";
		document.form_.generate_report.value = "1";
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./expense_distribution_report_print.jsp" />
	<% 
		return;}
	
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","expense_distribution_report.jsp");
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
	
	Vector vExpenses = null;
	Vector vDistribution = null;
	Vector vRetResult = null;
	Vector vTeams = null;
	Vector vValues = null;
	
	Integer iObjTemp = null;
    int iIndexOf = 0;
	int iWidth = 0;
	
	double[] dTotal = null;
	double dTotAmt = 0d;	
	BillingTsuneishi billTsu = new BillingTsuneishi();
	
	vExpenses = billTsu.operateOnExpenseAccount(dbOP, request, 4);
	vDistribution = billTsu.operateOnTeams(dbOP, request, 4);
	
	if(WI.fillTextValue("generate_report").length() > 0){
		vRetResult = billTsu.generateDistributionReport(dbOP, request);
		if(vRetResult == null)
			strErrMsg = billTsu.getErrMsg();
		else{			
			vTeams = (Vector)vRetResult.remove(0);
			iWidth = 55/(vTeams.size()/3);
			dTotal = new double[vTeams.size()/3];
		}
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./expense_distribution_report.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: EXPENSE DISTRIBUTION REPORT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Expense Period: </td>
			<td width="80%">From 
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a> 
				&nbsp;To&nbsp;
				<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">Expense Name:</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
			<%if(vExpenses != null && vExpenses.size() > 0){%>
				<div class="expenses">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
					<tr> 
						<td height="20" colspan="3" bgcolor="#B9B292" class="thinborder">
							<div align="center"><strong>::: EXPENSE ACCOUNT LISTING ::: </strong></div></td>
					</tr>
					<tr>
						<td height="25" align="center" class="thinborder" width="10%"><strong>Count</strong></td>
						<td align="center" class="thinborder" width="80%"><strong>Expense Name</strong></td>
						<td align="center" class="thinborder" width="20%"><strong>Select All<br />
							<%
								strTemp = WI.fillTextValue("selAllExp");
								if(strTemp.length() > 0)
									strTemp = "checked";
								else
									strTemp = "";
							%>
							<input type="checkbox" name="selAllExp" value="0" 
								onClick="checkAllExp();" <%=strTemp%>></font></strong></td>
					</tr>
				<%	int iCount = 1;
					for(int i = 0; i < vExpenses.size(); i += 9, iCount++){%>
					<tr>
						<td height="25" align="center" class="thinborder"><%=iCount%></td>
						<td class="thinborder"><%=(String)vExpenses.elementAt(i+1)%></td>
						<td align="center" class="thinborder">
							<%
								strTemp = WI.fillTextValue("exp_"+iCount);
								if(strTemp.length() > 0)
									strTemp = "checked";
								else
									strTemp = "";
							%>
							<input type="checkbox" name="exp_<%=iCount%>" value="<%=(String)vExpenses.elementAt(i)%>" <%=strTemp%> tabindex="-1"></td>
					</tr>
				<%}%>
					<input type="hidden" name="exp_count" value="<%=iCount%>">
				</table></div>
			<%}else{%>No Expense Account Created.<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">Distribution: </td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
			<%if(vDistribution != null && vDistribution.size() > 0){%>
				<div class="distributions">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
					<tr> 
						<td height="20" colspan="3" bgcolor="#B9B292" class="thinborder">
							<div align="center"><strong>::: DISTRIBUTION LISTING ::: </strong></div></td>
					</tr>
					<tr>
						<td height="25" align="center" class="thinborder" width="10%"><strong>Count</strong></td>
						<td align="center" class="thinborder" width="80%"><strong>Team Name</strong></td>
						<td align="center" class="thinborder" width="20%"><strong>Select All<br />
							<%
								strTemp = WI.fillTextValue("selAllDist");
								if(strTemp.length() > 0)
									strTemp = "checked";
								else
									strTemp = "";
							%>
							<input type="checkbox" name="selAllDist" value="0" 
								onClick="checkAllDist();" <%=strTemp%>></font></strong></td>
					</tr>
				<%	int iCount = 1;
					for(int i = 0; i < vDistribution.size(); i += 5, iCount++){%>
					<tr>
						<td height="25" align="center" class="thinborder"><%=iCount%></td>
						<td class="thinborder"><%=(String)vDistribution.elementAt(i+1)%></td>
						<td align="center" class="thinborder">
							<%
								strTemp = WI.fillTextValue("dist_"+iCount);
								if(strTemp.length() > 0)
									strTemp = "checked";
								else
									strTemp = "";
							%>
							<input type="checkbox" name="dist_<%=iCount%>" value="<%=(String)vDistribution.elementAt(i)%>" <%=strTemp%> tabindex="-1"></td>
					</tr>
				<%}%>
					<input type="hidden" name="dist_count" value="<%=iCount%>">
				</table></div>
			<%}else{%>No Expense Account Created.<%}%></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:GenerateReport();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click here to generate distribution report.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" align="right">
				<font size="2">Number of Rows Per Page :</font>
				<select name="num_rec_page">
				<% 
				int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
				for(int i = 10; i <=40 ; i++) {
					if ( i == iDefault) {%>
						<option selected value="<%=i%>"><%=i%></option>
					<%}else{%>
						<option value="<%=i%>"><%=i%></option>
					<%}
				}%>
				</select>
				&nbsp;
				<a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" /></a>&nbsp;</td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr> 
		  	<td height="20" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: EXPENSE DISTRIBUTION DETAILS ::: </strong></div></td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Expense Name</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Total Amount</strong></td>
		<%	for(int i = 0; i < vTeams.size(); i+=3){%>
			<td width="<%=iWidth%>%" align="center" class="thinborder">
				<strong><%=(String)vTeams.elementAt(i+1)%><br />(<%=(String)vTeams.elementAt(i+2)%>)</strong></td>
		<%}%>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=5, iCount++){
			vValues = (Vector)vRetResult.elementAt(i+4);
			dTotAmt = dTotAmt + Double.parseDouble((String)vRetResult.elementAt(i+3));
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">Php<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), true)%></td>
		<%	int iTemp = 0;
			for(int j = 0; j < vTeams.size(); j+=3, iTemp++){
				iObjTemp = (Integer)vTeams.elementAt(j);
				iIndexOf = vValues.indexOf(iObjTemp);
				
				if(iIndexOf != -1){
					dTotal[iTemp] += Double.parseDouble((String)vValues.elementAt(iIndexOf+1));
					strTemp = "Php"+CommonUtil.formatFloat((String)vValues.elementAt(iIndexOf+1), true);
				}
				else
					strTemp = "&nbsp;";
		%>
			<td class="thinborder"><%=strTemp%></td>
		<%}%>
		</tr>
	<%}%>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">TOTAL</td>
			<td class="thinborder">Php<%=CommonUtil.formatFloat(dTotAmt, true)%></td>
		<%	int iTemp = 0;
			for(int j = 0; j < vTeams.size(); j+=3, iTemp++){%>
			<td class="thinborder">Php<%=CommonUtil.formatFloat(dTotal[iTemp], true)%></td>
		<%}%>
		</tr>
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
	
	<input type="hidden" name="print_page" />
	<input type="hidden" name="generate_report" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
