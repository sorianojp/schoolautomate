<%@ page language="java" import="utility.*,Accounting.Budget,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<title>Budget Entry</title>
<style type="text/css">
.pending {
	height:150px; overflow:auto; width:auto; background-color:#FFFFFF;
}
.encoded {
	height:150px; overflow:auto; width:auto; background-color:#FFFFFF;
}
</style>

</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function checkAllSaveBudget() {
		var maxDisp = document.form_.setup_count.value;
		var bolIsSelAll = document.form_.selAllSaveBudget.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function toggleSel(objQty, objChkBox){
		if(objQty.value.length > 0)
			objChkBox.checked = true;
		else
			objChkBox.checked = false;
	}
	
	function PageAction(strAction, strInfoIndex, strInfoCount) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this budget entry?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		if(strInfoCount.length > 0)
			document.form_.info_count.value = strInfoCount;
		this.SearchSetup();
	}

	function SearchSetup(){
		document.form_.search_setup.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.search_setup.value = "";
		document.form_.submit();
	}
	
</script>
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
								"ACCOUNTING-BUDGET","budget_entry.jsp");
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
	Vector vBudgetEntries = null;
	Budget budget = new Budget();
	String strFiscalYear = budget.getCurrentFiscalYear(dbOP, request);	
	Vector vUserInfo = budget.getUserCollegeDeptInfo(dbOP, request);
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(!budget.operateOnBudgetEntry(dbOP, request, Integer.parseInt(strTemp)))
			strErrMsg = budget.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Budget entry successfully removed.";
			if(strTemp.equals("2"))
				strErrMsg = "Budget entry successfully edited.";
		}
	}
	
	if(WI.fillTextValue("search_setup").length() > 0){
		vRetResult = budget.getBudgetSetupForEncoding(dbOP, request);
		vBudgetEntries = budget.getEncodedBudgetEntries(dbOP, request);
		if(vRetResult == null && vBudgetEntries == null)
			strErrMsg = "No result found.";
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./budget_entry.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: BUDGET ENTRY ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<%
			if(vUserInfo == null){
				strTemp = "";
				strErrMsg = "";
			}
			else{
				strTemp = WI.getStrValue((String)vUserInfo.elementAt(1), "N/A");
				strErrMsg = WI.getStrValue((String)vUserInfo.elementAt(3), "ALL");
			}
		%>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>:</td>
			<td><%=strTemp%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department/Office:</td>
			<td><%=strErrMsg%></td>
		</tr>
		<tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Fiscal Year: </td>
			<td>
				<%
					strTemp = WI.getStrValue(WI.getStrValue(WI.fillTextValue("year"), strFiscalYear), "-1");
				%>
				<select name="year" size="1" id="year" onChange="ReloadPage();">
					<option value="-1">Select fiscal year</option>
					<%=dbOP.loadComboYear(strTemp, 1, 3, true)%>
				</select></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Budget Period: </td>
	  	    <td width="77%">
				<%						
					strErrMsg = 
						" from ac_budget_period where is_valid = 1 "+
						" and fiscal_year = "+strTemp;
				%>
				<select name="budget_period" onChange="ReloadPage();">
          			<option value="">Select budget period</option>
          			<%=dbOP.loadCombo("budget_period_index","period_name",strErrMsg,WI.fillTextValue("budget_period"),false)%> 
        		</select></td>
	    </tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
			<td valign="middle"><a href="javascript:SearchSetup();">
					<img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to search valid budget setup.</font></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">&nbsp;				
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PageAction('1','','');"><img src="../../../images/add.gif" border="0"></a>
				<%}%></td>
		</tr>
	</table>
	<div class="pending">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="8" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>LIST OF PENDING BUDGET SETUP </strong></div></td>
		</tr>
    	<tr>
			<td width="5%"  align="center" height="23" class="thinborder"><strong>Count</strong></td>
			<td width="43%" align="center" class="thinborder"><strong>Expense Name </strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Category</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Amount </strong></td>
			<td width="7%"  align="center" class="thinborder"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllSaveBudget" value="0" onClick="checkAllSaveBudget();"></td>
    	</tr>
		<% 
			int iCount = 1;
	   		for (int i = 0; i < vRetResult.size(); i+=3,iCount++){
		%>
		<tr>
      		<td height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      		<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      		<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      		<td align="center" class="thinborder">
				<input type="text" name="amount_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','amount_<%=iCount%>');style.backgroundColor='white';toggleSel(document.form_.amount_<%=iCount%>, document.form_.save_<%=iCount%>)" 
					onkeyup="AllowOnlyFloat('form_','amount_<%=iCount%>')" size="16" maxlength="16" /></td>
      		<td align="center" class="thinborder">        
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1"></td>
    	</tr>
    	<%}%>
		<input type="hidden" name="setup_count" value="<%=iCount%>">
	</table>
	</div>
<%}

if(vBudgetEntries != null && vBudgetEntries.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	<div class="encoded">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="8" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>LIST OF ENCODED BUDGET SETUP </strong></div></td>
		</tr>
    	<tr>
			<td width="5%"  align="center" height="23" class="thinborder"><strong>Count</strong></td>
			<td width="40%" align="center" class="thinborder"><strong>Expense Name </strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Category</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Amount </strong></td>
			<td width="15%"  align="center" class="thinborder"><strong>Options</strong></td>
    	</tr>
		<% 
			boolean bolIsApproved = false;
			boolean bolIsAllowed = false;
			int iCount = 1;
	   		for (int i = 0; i < vBudgetEntries.size(); i+=7,iCount++){
				bolIsApproved = ((String)vBudgetEntries.elementAt(i+3)).equals("1");
				bolIsAllowed = ((String)vBudgetEntries.elementAt(i+4)).equals("0");
		%>
		<tr>
      		<td height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      		<td class="thinborder"><%=(String)vBudgetEntries.elementAt(i+1)%></td>
      		<td class="thinborder"><%=(String)vBudgetEntries.elementAt(i+6)%></td>
			<%
				if(!bolIsApproved && bolIsAllowed)
					strTemp = "align='center'";
				else
					strTemp = "";
			%>
      		<td <%=strTemp%> class="thinborder">
			<%
			strTemp = (String)vBudgetEntries.elementAt(i+2);
			if(bolIsApproved || !bolIsAllowed){%>
				<%=CommonUtil.formatFloat(strTemp, true)%>
			<%}else{
				strTemp = CommonUtil.formatFloat(strTemp, false);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");
			%>
				<input type="text" name="encoded_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','encoded_<%=iCount%>');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','encoded_<%=iCount%>')" size="16" maxlength="16" />
			<%}%></td>
      		<td align="center" class="thinborder">
				<%if(bolIsApproved){%>
					Approved.
				<%}else if(!bolIsAllowed){%>
					Not allowed.
				<%}else{
					if(iAccessLevel > 1){%>
						<a href="javascript:PageAction('2', '<%=(String)vBudgetEntries.elementAt(i)%>', '<%=iCount%>');">
						<img src="../../../images/edit.gif" border="0"></a>
						<%if(iAccessLevel == 2){%>
							<a href="javascript:PageAction('0','<%=(String)vBudgetEntries.elementAt(i)%>', '<%=iCount%>');">
							<img src="../../../images/delete.gif" border="0"></a>
						<%}
					}else{%>
						Not authorized.
					<%}
				}%>
			</td>
    	</tr>
    	<%}%>
	</table>
	</div>
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" >&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="search_setup">
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="info_count">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>