<%@ page language="java" import="utility.*,Accounting.Budget,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Approve Budget</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function ReloadPage(){
		if(document.form_.c_index)
			document.form_.c_index.value = "";		
		if(document.form_.d_index)
			document.form_.d_index.value = "";
		document.form_.submit();
	}
	
	function PageAction(strAction){
		if(strAction == '0'){
			if(!confirm('Are you sure you want to delete the selected budgets?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		this.ShowBudget();
	}
	
	function ShowBudget(){
		document.form_.show_budget.value = "1";
		document.form_.submit();
	}
	
	function checkAllSave() {
		var maxDisp = document.form_.entry_count.value;		
		var bolIsSelAll = document.form_.selAllSave.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		this.processRequest(strURL);
	}
	
</script>
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;
	String strTemp2   = null;
	boolean bolIsRestricted = true;
	boolean bolIsCreator = true;

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
								"ACCOUNTING-BUDGET","budget_approve.jsp");
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
	
	Vector vTemp = null;
	Vector vRetResult = null;
	Vector vUserInfo = null;
	Vector vAuthLevels = null;
	Budget budget = new Budget();
	
	String strCurrentFiscalYear = budget.getCurrentFiscalYear(dbOP, request);
	vUserInfo = budget.getUserCollegeDeptInfo(dbOP, request);
	vAuthLevels = budget.operateOnAuthLevel(dbOP, request, 4);
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(!budget.operateOnBudgetEntryAmounts(dbOP, request, Integer.parseInt(strTemp)))
			strErrMsg = budget.getErrMsg();
	}
	
	if(WI.fillTextValue("order_no").length() > 0){
		strTemp = " select is_restricted from ac_budget_auth_level where is_valid = 1 and order_no = "+WI.fillTextValue("order_no");
		bolIsRestricted = (dbOP.getResultOfAQuery(strTemp, 0)).equals("1");
	}
	
	if(WI.fillTextValue("show_budget").length() > 0){
		vRetResult = budget.getApprovedBudgets(dbOP, request);
		if(vRetResult == null)
			strErrMsg = budget.getErrMsg();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./budget_approve.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: APPROVE BUDGET ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Level Name: </td>
			<td width="80%">
				<select name="order_no" onChange="ReloadPage();">
          			<option value="">Select Level</option>
          			<%=dbOP.loadCombo("order_no","level_name", " from ac_budget_auth_level where is_valid = 1 and is_restricted = 1", WI.fillTextValue("order_no"),false)%>
					<%
						strTemp =
							" from ac_budget_auth_user "+
							" join ac_budget_auth_level on (ac_budget_auth_level.auth_level_index = ac_budget_auth_user.auth_level_index) "+
							" and user_index = "+request.getSession(false).getAttribute("userIndex")+
							" order by order_no ";
					%>
					<%=dbOP.loadCombo("order_no","level_name", strTemp, WI.fillTextValue("order_no"),false)%> 
        		</select></td>
		</tr>
	<%if(WI.fillTextValue("order_no").length() > 0){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Fiscal Year: </td>
			<td>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("year"), WI.getStrValue(strCurrentFiscalYear, "-1"));
				%>
				<select name="year" size="1" id="year" onChange="document.form_.submit();">
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
						" and fiscal_year = "+strTemp;
				%>
				<select name="budget_period">
          			<option value="">Select budget period</option>
          			<%=dbOP.loadCombo("budget_period_index","period_name", strTemp, WI.fillTextValue("budget_period"),false)%> 
        		</select></td>
		</tr>
	<%	
		String strCollegeIndex = WI.fillTextValue("c_index");
		if(bolIsRestricted){
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
			<td colspan="2">
				<input type="hidden" name="c_index" value="<%=WI.getStrValue((String)vUserInfo.elementAt(0))%>">
				<%=strTemp%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department:</td>
			<td colspan="2">
				<input type="hidden" name="d_index" value="<%=WI.getStrValue((String)vUserInfo.elementAt(2))%>">
				<%=strErrMsg%></td>
		</tr>
	<%}else{%>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>:</td>
			<td colspan="2">
				<select name="c_index" onChange="loadDept();">
          			<option value="0">ALL</option>
          			<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
        		</select></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department: </td>
			<td colspan="2">
				<label id="load_dept">
				<select name="d_index">
         			<option value="">ALL</option>
          		<%if ((strCollegeIndex.length() == 0) || strCollegeIndex.equals("0")){%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          		<%}else{%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
         		 <%}%>
  	   			</select>
				</label></td>
        </tr>
	<%}%>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<a href="javascript:ShowBudget();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to show pending and approved budget for this level.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	<%}%>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" >&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="<%=(vAuthLevels.size()/5)+6%>" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF EXPENSES APPROVED BUDGET ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="19%" align="center" class="thinborder"><strong>Expense Name</strong></td>
			<td width="9%" align="center" class="thinborder"><strong><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/<br>Department</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Timetable</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Proposed<br>Budget</strong></td>
		<%for(int i = 0; i < vAuthLevels.size(); i += 5){%>
			<td width="<%=40/(vAuthLevels.size()/5)%>%" align="center" class="thinborder"><strong><%=(String)vAuthLevels.elementAt(i+1)%></strong></td>
		<%}%>
			<td width="7%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br></strong>
        		<input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();"></font></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 8, iCount++){
			vTemp = (Vector)vRetResult.elementAt(i+5);
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">
				<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "", "", "ALL")%>/<br>
				<%=WI.getStrValue((String)vRetResult.elementAt(i+7), "ALL")%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%>-<br><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
		<%for(int j = 0; j < vTemp.size(); j += 5){
			if((String)vTemp.elementAt(j) == null)
				strTemp = "&nbsp;";
			else
				strTemp = CommonUtil.formatFloat((String)vTemp.elementAt(j), false);
				
			strErrMsg = (String)vTemp.elementAt(j+2);
			
			strTemp2 = (String)vTemp.elementAt(j+1);
			if(strTemp2 == null)
				bolIsCreator = true;
			else{
				if(strTemp2.equals(strUserIndex))
					bolIsCreator = true;
				else
					bolIsCreator = false;
			}
		%>
			<td align="center" class="thinborder">
			<%	//conditions: for this level, if approved by prev level, and creator of budget, and not approved by higher level
				if(strErrMsg.equals(WI.fillTextValue("order_no")) && ((String)vTemp.elementAt(j+3)).equals("1") && bolIsCreator && ((String)vTemp.elementAt(j+4)).equals("0")){
					if(strTemp.equals("&nbsp;"))
						strTemp = "";
					strTemp = ConversionTable.replaceString(strTemp, ",", "");
			%>
				<input type="text" name="edit_budget_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','edit_budget_<%=iCount%>');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','edit_budget_<%=iCount%>')" size="8" maxlength="15" />
			<%}else{%>
				<%=strTemp%>
			<%}%></td>
		<%}%>
			<td align="center" class="thinborder">
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1"></td>
		</tr>
	<%}%>
	<input type="hidden" name="entry_count" value="<%=iCount%>">
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="center">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PageAction('1');"><img src="../../../images/save.gif" border="0"></a>
				<font size="1">Click to save budget.</font>
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0');"><img src="../../../images/delete.gif" border="0"></a>
					<font size="1">Click to delete budget.</font>
				<%}
			}else{%>
				Not authorized.
			<%}%></td>
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
	
	<input type="hidden" name="show_budget">
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="info_count">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>