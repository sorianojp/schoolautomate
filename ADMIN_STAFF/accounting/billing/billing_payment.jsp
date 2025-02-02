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
<title>Billing Report</title>
</head>

<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/formatFloat.js"></script>
<script language="javascript">

	function AjaxMapBilling() {
		var strBillingNo = document.form_.bill_no.value;
		var objCOAInput = document.getElementById("coa_info");
		if(strBillingNo.length < 3) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20000&bill_no="+escape(strBillingNo);
		this.processRequest(strURL);
	}
	
	function updateBillNo(strBillingIndex, strBillNum){
		document.form_.bill_no.value = strBillNum;
		document.getElementById("coa_info").innerHTML = "";
		this.getBillIndex();
	}
	
	function getBillIndex(){
		document.form_.get_billing_index.value = "1";
		document.form_.submit();
	}
	
	function OperateOnCurrency(){
		var pgLoc = "./billing_currencies.jsp?opner_form_name=form_";
		var win=window.open(pgLoc,"OperateOnCurrency",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function FocusField(){
		if(document.form_.payment_amount)
			document.form_.payment_amount.focus();
		else
			document.form_.bill_no.focus();
	}
	
	function SaveRecord(){
		document.form_.save_record.value = "1";
		this.getBillIndex();
	}
	
	function CancelOperation(){
		document.form_.date_paid.value = "";
		document.form_.payment_amount.value = "";
		document.form_.exchange_rate.value = "";
		document.form_.rate_date.value = "";
		document.form_.cash_amt.value = "";
		document.form_.or_number.value = "";
		this.getBillIndex();
	}
	
	function CancelPayment(strPaymentIndex){
		if(!confirm("Are you sure you want to cancel this billing payment?"))
			return;
		document.form_.cancel_payment.value = strPaymentIndex;
		this.getBillIndex();
	}
	
	function Convert(){
		var value = 0;
		var amount = document.form_.payment_amount.value;
		var rate = document.form_.exchange_rate.value;
		var currency = document.form_.currency.value;
		
		if(currency.length == 0)
			rate = 1;
		if(rate.length == 0)
			rate = 0;
		
		if(amount.length > 0 && amount != '-' && amount != '.')
			value = eval(amount) * eval(rate);
		else
			value = 0;
		
		value = truncateFloat(value,1,true);
		
		document.form_.cash_amt.value = value;
	}
	
	function PrintPg(strBillingIndex){
		document.form_.billing_index.value = strBillingIndex;
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./billing_payment_print.jsp" />
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
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","billing_payment.jsp");
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
	
	Vector vBillingInfo = null;
	Vector vRetResult = null;

	BillingTsuneishi billTsu = new BillingTsuneishi();
	String strBillingIndex = null;
	
	if(WI.fillTextValue("get_billing_index").length() > 0){
		strBillingIndex = billTsu.getBillingIndex(dbOP, request);
		if(strBillingIndex == null)
			strErrMsg = billTsu.getErrMsg();
	}
	
	if(strBillingIndex != null && strBillingIndex.length() > 0){
		if(WI.fillTextValue("save_record").length() > 0){
			if(!billTsu.saveProjectBillingPayment(dbOP, request, strBillingIndex))
				strErrMsg = billTsu.getErrMsg();
			else
				strErrMsg = "Payment successfully recorded.";
		}
		
		if(WI.fillTextValue("cancel_payment").length() > 0){
			if(!billTsu.cancelBillingPayment(dbOP, request, strBillingIndex))
				strErrMsg = billTsu.getErrMsg();
			else
				strErrMsg = "Payment successfully cancelled.";
		}
	
		vBillingInfo = billTsu.getBillingInfo(dbOP, request, strBillingIndex);
		if(vBillingInfo == null)
			strErrMsg = billTsu.getErrMsg();
		else{
			vRetResult = billTsu.getBillingPayments(dbOP, request, strBillingIndex);
			if(vRetResult == null)
				strErrMsg = billTsu.getErrMsg();
		}
	}
%>
<body bgcolor="#D2AE72" onload="FocusField();">
<form name="form_" action="./billing_payment.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: BILLING PAYMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Bill Number:</td>
			<td width="20%">
				<input name="bill_no" type="text" size="16" value="<%=WI.fillTextValue("bill_no")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapBilling();"></td>			
			<td width="60%" valign="top"><label id="coa_info" style="position:absolute; width:300px"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="2">
				<a href="javascript:getBillIndex();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to view billing information.</font></td>
	    </tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>			
	</table>
	
<%if(vBillingInfo != null && vBillingInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
			<td><b><u>Billing Details: </u></b></td>
		    <td width="48%">&nbsp;</td>
		    <td width="32%"><b>Billing Date: <%=(String)vBillingInfo.elementAt(6)%></b></td>
		</tr>
		<tr>
			<td height="22" width="3%">&nbsp;</td>
			<td width="17%">Project Name: </td>
			<td colspan="2"><%=(String)vBillingInfo.elementAt(1)%> (<%=(String)vBillingInfo.elementAt(3)%> - <%=(String)vBillingInfo.elementAt(4)%>)</td>
		</tr>
		
		<tr>
			<td height="25">&nbsp;</td>
			<td>Bill Number: </td>
			<td><%=(String)vBillingInfo.elementAt(8)%></td>
		    <td>Bill Reference: <%=(String)vBillingInfo.elementAt(7)%></td>
		</tr>		
		<tr>
			<td height="25">&nbsp;</td>
			<td>Billing Amount: </td>
			<td>Php<%=(String)vBillingInfo.elementAt(2)%></td>
		    <td>Payable Amount: Php<%=(String)vBillingInfo.elementAt(13)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project Head: </td>
			<td><%=(String)vBillingInfo.elementAt(12)%></td>
		    <td>Manpower: <%=(String)vBillingInfo.elementAt(5)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project Detail: </td>
			<td colspan="2"><%=WI.getStrValue((String)vBillingInfo.elementAt(9), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Special Ref: </td>
			<td colspan="2"><%=WI.getStrValue((String)vBillingInfo.elementAt(10), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Note:</td>
			<td colspan="2"><%=WI.getStrValue((String)vBillingInfo.elementAt(11), "&nbsp;")%></td>
		</tr>		
		<tr>
			<td height="15" colspan="4"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><b><u>Payment Details: </u></b></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Payment Date: </td>
			<td colspan="2">
				<%
					strTemp = WI.fillTextValue("date_paid");
					if(strTemp.length() == 0) 
						strTemp = WI.getTodaysDate(1);
				%>
				<input name="date_paid" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_paid');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Payment Amount: </td>
			<td colspan="2">
				<input type="text" name="payment_amount" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','payment_amount');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','payment_amount');Convert();" 
					size="12" maxlength="10" value="<%=WI.fillTextValue("payment_amount")%>" />
				&nbsp;
				<select name="currency" onchange="Convert();">
					<option value="">Philippine Peso (Php)</option>
					<%=dbOP.loadCombo("currency_index","currency_name + ' (' + currency_code + ')'"," from currency where is_valid = 1 order by currency_name",WI.fillTextValue("currency"),false)%>
				</select>
				&nbsp;
				<a href="javascript:OperateOnCurrency();"><img src="../../../images/update.gif" border="0"></a>
				<font size="1">Click to update list of currencies.</font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2">
				<input type="text" name="exchange_rate" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','exchange_rate');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','exchange_rate');Convert();" 
					size="12" maxlength="10" value="<%=WI.fillTextValue("exchange_rate")%>" />
				&nbsp;
				Rate as of 
				<%
					strTemp = WI.fillTextValue("rate_date");
					if(strTemp.length() == 0) 
						strTemp = WI.getTodaysDate(1);
				%>
				<input name="rate_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.rate_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Philippine Peso: </td>
			<td colspan="2">
				<input name="cash_amt" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("cash_amt")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>OR #: </td>
			<td colspan="2">
				<input name="or_number" type="text" size="24" maxlength="24" value="<%=WI.fillTextValue("or_number")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="2">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:SaveRecord();"><img src="../../../images/save.gif" border="0" /></a>
					<font size="1">Click to save payment information.</font>
				<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0" /></a>
					<font size="1">Click to cancel operation</font>
			<%}else{%>
				Not Authorized to save billing payment information.
			<%}%></td>
	    </tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
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
				<a href="javascript:PrintPg('<%=strBillingIndex%>');"><img src="../../../images/print.gif" border="0" /></a>
				<font size="1">Click to print billing payments.</font></td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: PROJECT BILLING PAYMENTS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="7%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>OR Number</strong></td>
			<td width="18%" align="center" class="thinborder"><strong>Date Paid</strong></td>
			<td width="40%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Cancel</strong></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 7, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;
				<%
					strTemp = (String)vRetResult.elementAt(i+5);
					if(strTemp == null)
						strTemp = "";
					else
						strTemp = (String)vRetResult.elementAt(i+4) + " (" + strTemp + ") - ";
				%>
				<%=strTemp%>Php<%=(String)vRetResult.elementAt(i+6)%></td>
			<td align="center" class="thinborder">
				<a href="javascript:CancelPayment('<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../images/cancel.gif" border="0" /></a></td>
		</tr>
	<%}%>
	</table>
	<%}
}%>

	<table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="get_billing_index" />
	<input type="hidden" name="cancel_payment" />
	<input type="hidden" name="save_record" />
	<input type="hidden" name="print_page" />
	<input type="hidden" name="billing_index" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>