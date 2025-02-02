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
<title>Budget Entry</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function RefreshPage(strBudgetIndex){
		location = "./budget_entry.jsp?budget_setup_index="+strBudgetIndex;
	}
	
	function ReloadPage(strReset){		
		document.form_.page_action.value = "";
		
		if(strReset == '1'){
			document.form_.prepareToEdit.value = "";
			document.form_.info_index.value = "";
		}
		else{
			document.form_.is_reloaded.value = "1";
		}
		
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this entry?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;
	String strTemp2   = null;
	String strCIndex  = null;
	String strDIndex  = null;

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
	
	String strBudgetSetupIndex = WI.fillTextValue("budget_setup_index");
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vBudgetInfo = null;
	Vector vEditInfo  = null; 
	Vector vRetResult = null;
	Vector vUserInfo = null;
	
	Budget budget = new Budget();
	
	String strFiscalYear = budget.getCurrentFiscalYear(dbOP, request);
	
	vUserInfo = budget.getUserCollegeDeptInfo(dbOP, request);
	if(strBudgetSetupIndex.length() > 0){
		vBudgetInfo = budget.getBudgetInfo(dbOP, request);
		if(vBudgetInfo == null)
			strErrMsg = budget.getErrMsg();
		else{
			strTemp = WI.fillTextValue("page_action");
			
			if(strTemp.length() > 0){
				if(budget.operateOnBudgetEntry(dbOP, request, Integer.parseInt(strTemp)) == null)
					strErrMsg = budget.getErrMsg();
				else{
					if(strTemp.equals("0"))
						strErrMsg = "Budget entry successfully removed.";
					if(strTemp.equals("1"))
						strErrMsg = "Budget entry successfully recorded.";
					if(strTemp.equals("2"))
						strErrMsg = "Budget entry successfully edited.";
						
					strPrepareToEdit = "0";
				}
			}
			
			vRetResult = budget.operateOnBudgetEntry(dbOP, request, 4);
			
			if(strPrepareToEdit.equals("1")){
				vEditInfo = budget.operateOnBudgetEntry(dbOP, request, 3);
				if(vEditInfo == null)
					strErrMsg = budget.getErrMsg();
			}
		}
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
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Expense Name: </td>
			<td width="77%">
				<%
					if(vUserInfo == null){
						strCIndex = null;
						strDIndex = null;
					}
					else{
						strCIndex = (String)vUserInfo.elementAt(0);//c_index of user
						strDIndex = (String)vUserInfo.elementAt(2);//d_index of user
						
						if(strCIndex != null && strCIndex.equals("0"))
							strCIndex = null;
					}
					
					strTemp =  
						" from ac_budget_setup where is_valid = 1 ";
					if(strCIndex != null || strDIndex != null){
					strTemp +=
						" and ( "+
						"	(college_index is null and dept_index is null) ";
					if(strCIndex == null && strDIndex != null){
						strTemp +=
						"	or "+
						"   (college_index is null and dept_index = "+strDIndex+") ";
					}
					if(strCIndex != null && strDIndex == null){
						strTemp +=
						"	or "+
						"   (college_index = "+strCIndex+" and dept_index is null) ";
					}
					if(strCIndex != null && strDIndex != null){
						strTemp +=
						"	or "+
						"	(college_index = "+strCIndex+" and dept_index = "+strDIndex+")";
					}
					strTemp += " ) ";
					}
					else
						strTemp += " and college_index is null and dept_index is null ";
				%>
				<select name="budget_setup_index" onChange="ReloadPage('1');">
          			<option value="">Select Expense</option>
          			<%=dbOP.loadCombo("budget_setup_index","expense_name", strTemp, WI.fillTextValue("budget_setup_index"),false)%> 
        		</select></td>
		</tr>
	</table>
	
<%if(vBudgetInfo != null && vBudgetInfo.size() > 0){%>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="3"><hr size="1" /></td>
		</tr>
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
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="3"><hr size="1" /></td>
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
			<td height="25">&nbsp;</td>
			<td>Fiscal Year: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp2 = (String)vEditInfo.elementAt(10);
					else				
						strTemp2 = WI.getStrValue(WI.getStrValue(WI.fillTextValue("year"), strFiscalYear), "-1");
				%>
				<select name="year" size="1" id="year" onChange="ReloadPage('0');">
					<option value="-1">Select fiscal year</option>
					<%=dbOP.loadComboYear(strTemp2, 1, 3)%>
				</select></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Budget Period: </td>
	  	    <td width="77%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(9);
					else
						strTemp = WI.fillTextValue("budget_period");
						
					strErrMsg = 
						" from ac_budget_period where is_valid = 1 "+
						" and fiscal_year = "+strTemp2;
				%>
				<select name="budget_period">
          			<option value="">Select budget period</option>
          			<%=dbOP.loadCombo("budget_period_index","period_name", strErrMsg, strTemp,false)%> 
        		</select></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Budget Amount: </td>
		    <td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("amount");
						
					strTemp = CommonUtil.formatFloat(strTemp, false);
					strTemp = ConversionTable.replaceString(strTemp, ",", "");
					if(strTemp.equals("0"))
						strTemp = "";
				%>
				<input type="text" name="amount" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','amount')" size="15" maxlength="15" /></td>
	    </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save budget entry.</font>
				    <%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit budget entry info.</font>
					    <%}
				}%>
				<a href="javascript:RefreshPage('<%=WI.fillTextValue("budget_setup_index")%>');">
					<img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font>
			<%}else{%>
				Not authorized.
			<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: BUDGET ENTRIES :::  </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Budget Timetable </strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Status</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Final Amount</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 11, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;
				<%=WI.formatDate((String)vRetResult.elementAt(i+3), 10)%>-<%=WI.formatDate((String)vRetResult.elementAt(i+4), 10)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+6);
				if(strTemp.equals("0")){
					strTemp = "Disapproved";
					strErrMsg = "";
				}
				else if(strTemp.equals("1")){
					strTemp = "Approved";
					strErrMsg = "";
				}
				else{
					strTemp = "Pending";
					strErrMsg = 
						" select level_name from ac_budget_auth_level "+
						" where is_valid = 1 and order_no > "+(String)vRetResult.elementAt(i+7);
					strErrMsg = WI.getStrValue(dbOP.getResultOfAQuery(strErrMsg, 0), "(", ")", "");
				}
			%>
			<td class="thinborder">&nbsp;<%=strTemp%> <%=strErrMsg%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+8);
				if(strTemp == null)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(strTemp, false);
			%>
			<td class="thinborder">&nbsp;<%=strTemp%></td>
			<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){
				if(((String)vRetResult.elementAt(i+6)).equals("0")){%>
					Disapproved.
				<%}else if(((String)vRetResult.elementAt(i+6)).equals("1")){%>
					Approved.
				<%}else{%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
					<%}
				}
			}else{%>
				Not authorized.
			<%}%></td>
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
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="is_reloaded">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>