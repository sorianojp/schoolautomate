<%@ page language="java" import="utility.*,Accounting.CashReceiptBook,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	if(WI.fillTextValue("print_pg").length() > 0) {
		if(strSchCode.startsWith("UB")){%>
			<jsp:forward page="./daily_encoding_den_print_UB.jsp" />
		<%}else{%>
			<jsp:forward page="./daily_encoding_den_print.jsp" />
	<%}}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/formatFloat.js"></script>
<script language="javascript">
	
	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
			
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		document.form_.emp_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}

	function PageAction(strAction, strInfoIndex) {
		document.form_.print_pg.value = "";
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete encoded denomination?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		document.form_.view_transactions.value = "1";
		document.form_.submit();
	}
	
	function ReloadTotal(iCount){
		if(document.form_.qty_0){
			var vTotal = 0;
			var amount = 0;
			var quantity = 0;
			var objCOA=document.getElementById("load_total");
			
			for(var i = 0; i < iCount; i++){
				amount = eval('document.form_.den_amount_'+i+'.value');
				quantity = eval('document.form_.qty_'+i+'.value');

				if(quantity.length > 0)
					vTotal += eval(amount*quantity);
			}
			
			objCOA.innerHTML = formatFloat(vTotal, 1, false);
		}
	}
	
	function ViewTransactions(){
		document.form_.view_transactions.value = "1";
		document.form_.print_pg.value = "";
		document.form_.submit();
	}
	function PrintPg() {
		document.form_.print_pg.value = '1';
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS-Daily Encoding Denomination","daily_encoding_den.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
							//								"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(),
								//							"daily_encoding_den.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
	int iTemp = 0;

	double dTotCollection = 0d;
	double dTotCash  = 0d;
	double dTotCheck = 0d;
	double dTotSD    = 0d;
	double dTotCC    = 0d;

	Vector vRetResult = null;
	CashReceiptBook crb = new CashReceiptBook();
	
	Vector vCollectInfo = null;
	
	if(WI.fillTextValue("view_transactions").length() > 0){
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0){
			if(crb.operateOnDenominationDeposit(dbOP, request, Integer.parseInt(strTemp)) == null)
				strErrMsg = crb.getErrMsg();
			else{
				if(strTemp.equals("0"))
					strErrMsg = "Encoded denominations successfully removed.";
				else if(strTemp.equals("1"))
					strErrMsg = "Denominations successfully recorded.";
			}
		}
		
		vRetResult = crb.operateOnDenominationDeposit(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = crb.getErrMsg();
		else
			iTemp = vRetResult.size()/4;
			
		vCollectInfo = crb.getTotalTellerAmount(dbOP, request);
		if(vCollectInfo == null)
			strErrMsg = crb.getErrMsg();
		else {
				dTotCollection = 0d;
				dTotCash  = ((Double)vCollectInfo.elementAt(0)).doubleValue();
				dTotCheck = ((Double)vCollectInfo.elementAt(1)).doubleValue();
				dTotSD    = ((Double)vCollectInfo.elementAt(2)).doubleValue();
				dTotCC    = ((Double)vCollectInfo.elementAt(3)).doubleValue();
				
				dTotCollection = dTotCash+dTotCheck+dTotSD+dTotCC;
		}
	}
	String strORRange = "";
	if(WI.fillTextValue("date_fr").length() > 0) { 
		Vector vORUsed = new EnrlReport.DailyCashCollection().getOrNumberRangeUsed(dbOP, (String)request.getSession(false).getAttribute("userIndex"), WI.fillTextValue("date_fr"));

		if(vORUsed != null) {
			while(vORUsed.size() > 0) {
				if(strORRange.length() > 0)
					strORRange = strORRange + ", ";
				
				strORRange = strORRange + (String)vORUsed.remove(0) + " - "+(String)vORUsed.remove(0);
			}
				
		}
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./daily_encoding_den.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: DENOMINATION ENCODING ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>ID Number: </td>
		  	<td valign="top">
<%
if(WI.fillTextValue("emp_id").length() == 0) {
	strTemp = (String)request.getSession(false).getAttribute("userId");
	strErrMsg = "readonly";
}else{
	strTemp = WI.fillTextValue("emp_id");
	strErrMsg = "";
}
%>
				<input name="emp_id" type="text" class="textbox" size="16"
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
					onBlur="style.backgroundColor='white'" <%=strErrMsg%>>&nbsp;
				<label id="coa_info" style="position:absolute; width:350px;"></label></td>
	  	</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Date:</td>
			<td width="80%">
<%
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:ViewTransactions();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to view teller transactions.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){
	int iCountDen = vRetResult.size()/4;
%>
	<input type="hidden" name="max_count" value="<%=iCountDen%>">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%">
			<strong>Total Collection: <%=CommonUtil.formatFloat(dTotCollection, false)%></strong> &nbsp;&nbsp;&nbsp;
<%if(dTotCash > 0d) {%>
			<strong>Total Cash: <%=CommonUtil.formatFloat(dTotCash, false)%></strong> &nbsp;&nbsp;&nbsp;
<%}if(dTotCheck >= 0d) {%>
			<strong>Total Check: <%=CommonUtil.formatFloat(dTotCheck, false)%></strong> &nbsp;&nbsp;&nbsp;
<%}if(dTotSD > 0d) {%>
			<strong>Total Salary Deduction: <%=CommonUtil.formatFloat(dTotSD, false)%></strong> &nbsp;&nbsp;&nbsp;
<%}if(dTotCC > 0d) {%>
			<strong>Total Credit Card: <%=CommonUtil.formatFloat(dTotCC, false)%></strong>
<%}%>			</td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>OR#: <%=WI.getStrValue(strORRange)%></td>
	  </tr>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="20%">&nbsp;</td>
			<td width="60%">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
					<tr>
						<td height="20" width="50%" align="center" class="thinborder"><strong>Denomination</strong></td>
						<td width="50%" align="center" class="thinborder"><strong>Quantity</strong></td>
					</tr>
				<%	int iCount = 0;
				double dAmtEncoded = 0d;
					//System.out.println(vRetResult);
				
					for(int i = 0; i < vRetResult.size(); i += 4, iCount++){
						if(vRetResult.elementAt(i+3) != null)
							dAmtEncoded += Double.parseDouble((String)vRetResult.elementAt(i+2)) * Double.parseDouble((String)vRetResult.elementAt(i+3));
					%>
					<input type="hidden" name="den_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
					<input type="hidden" name="den_amount_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+2)%>">
					<tr>
						<td height="20" align="center" class="thinborder">P <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), false)%></td>
						<td align="center" class="thinborder">
							<input type="text" name="qty_<%=iCount%>" class="textbox" style="font-size:11px;" onFocus="style.backgroundColor='#D3EBFF'"
								onBlur="AllowOnlyInteger('form_','qty_<%=iCount%>');ReloadTotal('<%=iCountDen%>');style.backgroundColor='white'"
								onkeyup="AllowOnlyInteger('form_','qty_<%=iCount%>');ReloadTotal('<%=iCountDen%>');"
								size="12" maxlength="10" value="<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%>" /></td>
					</tr>
				<%}%>
					<tr>
						<td height="20" align="center" class="thinborder"><strong>Total</strong></td>
						<td align="center" class="thinborder"><label id="load_total"><%=CommonUtil.formatFloat(dAmtEncoded, true)%></label></td>
					</tr>
				</table>
			</td>
			<td width="20%">&nbsp;</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="40" valign="bottom" align="center"><font size="1">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
				Click to save denomination information.			
			<%}else{%>
				Not authorized to save daily encoding denomination.
			<%}%>
			
			<%if(dAmtEncoded > 0d) {%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> Print Page.
			<%}%></font>
			</td>
		</tr>
	</table>
<%}%>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#B8CDD1">
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="view_transactions">
	<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>