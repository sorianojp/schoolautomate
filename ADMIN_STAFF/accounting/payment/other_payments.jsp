<%@ page language="java" import="utility.*, Accounting.SalesPayment, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<title>Payment</title>
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">

	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objInput = document.getElementById("emp_id_");
		
		if(strCompleteName.length <=2) {
			objInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objInput, 2);//I want to get innerHTML in this.retObj
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
		document.getElementById("emp_id_").innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	var objCOA;
	var objCOAInput;
	var objCOAList;
	function MapCOAAjax(strFieldName, strLabelID, strList) {
		objCOA=document.getElementById(strLabelID);
		objCOAList = strList;
		var strCompleteName = eval("document.form_."+strFieldName+".value");
		eval('objCOAInput=document.form_.'+strFieldName);
		if(strCompleteName.length <= 2) {
			objCOA.innerHTML = "";
			return ;
		}		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name="+strFieldName;
		this.processRequest(strURL);
	}
	
	function COASelected(strAccountName, objParticular) {
		var strInvoiceNo = objCOAInput.value;
		var strInvoiceList = eval("document.form_."+objCOAList+".value");
		if(strInvoiceList.length == 0) 
			strInvoiceList = strInvoiceNo;
		else if(strInvoiceList.indexOf(strInvoiceNo) > -1){
			objCOAInput.value = "";
			objCOA.innerHTML = "";
			return;
		}
		else
			strInvoiceList += ", "+strInvoiceNo;
			
		eval("document.form_."+objCOAList+".value = '"+strInvoiceList+"' ");
		objCOAInput.value = "";
		objCOA.innerHTML = "";
	}
	
	///use ajax to update voucher date and voucher number.
	function UpdateInfo(strIndex) {
		//do nothing..
	}
	
	function UpdateForex(){
		var pgLoc = "./sales_exchange_rate.jsp?opner_form_name=form_&is_forwarded=1";
		var win=window.open(pgLoc,"UpdateForex",'width=700,height=500,top=30,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function PlaceCheckAmount(){
		var vCheckCSV = document.form_.check_csv.value;
		var pgLoc = "./check_detail.jsp?opner_form_name=form_&check_csv="+vCheckCSV;
		var win=window.open(pgLoc,"PlaceCheckAmount",'width=700,height=500,top=30,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function ReloadPageCheck(strCheckCSV){		
		document.form_.check_csv.value = strCheckCSV;
		document.form_.submit();
	}
	
	function SavePayment(){
		if(document.form_.emp_id.value.length == 0){
			alert("Please provide charge to information.");
			return;
		}
		
		if(document.form_.currency.value.length == 0){
			alert("Please provide currency information.");
			return;
		}
	
		if(document.form_.or_number.value.length == 0){
			alert("Please provide or number.");
			return;
		}
		
		if(document.form_.payment_date.value.length == 0){
			alert("Please provide payment date.");
			return;
		}
		
		if(document.form_.debit.value.length == 0){
			alert("Please provide debit COA.");
			return;
		}
		
		if(document.form_.credit.value.length == 0){
			alert("Please provide credit COA.");
			return;
		}
		
		if(document.form_.particulars.value.length == 0){
			alert("Please provide particulars.");
			return;
		}
	
		var sum = 0;
		
		var vCashAmt = document.form_.cash_amt.value;
		if(vCashAmt.length == 0)
			vCashAmt = 0;
		
		var vChkAmt = document.form_.chk_amt.value;
		if(vChkAmt.length == 0)
			vChkAmt = 0;
		
		sum = eval(vCashAmt) + eval(vChkAmt);
		
		if(eval(sum) <= 0){
			alert("Please provide at least one amount.");
			return;
		}

		document.form_.save_payment.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.emp_id.focus();
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
								"ACCOUNTING-BILLING","other_payments.jsp");
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
	
	String strCheckCSV = WI.fillTextValue("check_csv");
	String strORNumber = null;
	SalesPayment sp = new SalesPayment();
	
	if(WI.fillTextValue("save_payment").length() > 0){
		if(!sp.operateOnOtherPayments(dbOP, request))
			strErrMsg = sp.getErrMsg();
		else{%>
			<jsp:forward page="./OR_print.jsp" />
		<%	return;
		}
	}
%>	
<body bgcolor="#D2AE72" onload="FocusField();">
<form name="form_" action="other_payments.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>::::  OTHER PAYMENTS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Charge To: </td>
		    <td colspan="3">
				<input name="emp_id" type="text" class="textbox" size="16" onKeyUp="AjaxMapName();" 
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("emp_id")%>"
					onBlur="style.backgroundColor='white'">
				&nbsp;&nbsp;&nbsp;
				<label id="emp_id_" style="font-size:11px;position:absolute;width:300px"></label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Currency:</td>
		    <td colspan="3">
				<%
					strTemp = " from currency where is_valid = 1 order by is_local desc, currency_name ";
				%>
				<select name="currency">
					<option value="">Select currency</option>
					<%=dbOP.loadCombo("currency_index", "currency_name", strTemp, WI.fillTextValue("currency"), false)%>
				</select></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>OR Number: </td>
			<%
				strORNumber = sp.generateORNumber(dbOP, request);
				if(strORNumber == null && WI.fillTextValue("save_payment").length() == 0)
					strErrMsg = sp.getErrMsg();
					
				if(strErrMsg != null && strORNumber == null)
					strORNumber = WI.fillTextValue("or_number");
			%>
			<td>
				<input name="or_number" type="text" size="24" maxlength="24" class="textbox" 
					value="<%=WI.getStrValue(strORNumber,"")%>" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'"></td>
		    <td width="17%">Date:</td>
		    <td width="33%">
				<input name="payment_date" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
					value="<%=WI.fillTextValue("payment_date")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.payment_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="17%">Cash:</td>
		    <td width="30%">
				<input type="text" name="cash_amt" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="AllowOnlyFloat('form_','cash_amt');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','cash_amt')" size="16" maxlength="16" 
					value="<%=WI.fillTextValue("cash_amt")%>"/></td>
		    <td>&nbsp;</td>
	        <td><a href="javascript:UpdateForex();"><strong>UPDATE EXCHANGE RATE</strong></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Check:</td>
		    <td>
				<input type="text" name="chk_amt" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="AllowOnlyFloat('form_','chk_amt');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','chk_amt')" size="16" maxlength="16" 
					value="<%=WI.fillTextValue("chk_amt")%>"/>
				&nbsp;&nbsp;
				<a href="javascript:PlaceCheckAmount();">UPDATE</a></td>
		    <td colspan="2">&nbsp;</td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Debit:</td>
		    <td colspan="3">
				<textarea name="debit" style="font-size:12px" cols="80" rows="2" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox" 
					onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("debit")%></textarea></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Debit Search:</td>
		    <td colspan="3">
				<input name="debit_list" type="text" size="16" value="<%=WI.fillTextValue("debit_list")%>"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="MapCOAAjax('debit_list','debit_','debit');" class="textbox">
				&nbsp;&nbsp;&nbsp;
				<label id="debit_" style="font-size:11px;position:absolute;width:300px"></label></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Credit:</td>
		    <td colspan="3">
				<textarea name="credit" style="font-size:12px" cols="80" rows="2" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox" 
					onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("credit")%></textarea></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Credit Search:</td>
		    <td colspan="3">
				<input name="credit_list" type="text" size="16" value="<%=WI.fillTextValue("credit_list")%>"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="MapCOAAjax('credit_list','credit_','credit');" class="textbox">
				&nbsp;&nbsp;&nbsp;
				<label id="credit_" style="font-size:11px;position:absolute;width:300px"></label></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Particulars:</td>
		    <td colspan="3">
				<textarea name="particulars" style="font-size:12px" cols="65" rows="4" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox" 
					onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("particulars")%></textarea></td>
	    </tr>
		<tr>
			<td height="50" colspan="5" align="center" valign="middle">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:SavePayment();"><img src="../../../images/save.gif" border="0"></a>
				<font size="1">Click to save payment transaction.</font>
			<%}else{%>
				Not authorized for payment transaction.
			<%}%></td>
		</tr>
	</table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="save_payment">
	<input type="hidden" name="check_csv" value="<%=strCheckCSV%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>