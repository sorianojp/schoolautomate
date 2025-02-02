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
<style type="text/css">
a{
	text-decoration: none
}
</style>
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
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
	
	function ViewDCInfo(strDCNumber){
		var pgLoc = "./view_dc_info.jsp?dc_number="+strDCNumber;
		var win=window.open(pgLoc,"ViewDCInfo",'width=900,height=500,top=30,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

	function ViewInvoiceInfo(strInvoiceNo){
		var pgLoc = "./view_invoice_desc.jsp?invoice_no="+strInvoiceNo;
		var win=window.open(pgLoc,"ViewInvoiceInfo",'width=900,height=500,top=30,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function ViewSOAInfo(strSANum){
		var pgLoc = "../SOA/view_SOA_info.jsp?sa_num="+strSANum;
		var win=window.open(pgLoc,"ViewSOAInfo",'width=700,height=500,top=30,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
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
	
		var sum = 0;
		var vPayableAmt = document.form_.payable_amt.value;
		
		var vCashAmt = document.form_.cash_amt.value;
		if(vCashAmt.length == 0)
			vCashAmt = 0;
		
		var vChkAmt = document.form_.chk_amt.value;
		if(vChkAmt.length == 0)
			vChkAmt = 0;
		
		sum = eval(vCashAmt) + eval(vChkAmt);
		
		if(eval(vPayableAmt) != eval(sum)){
			alert("Total amount must be equal to amount payable.");
			return;
		}

		document.form_.save_payment.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function GoBack(){
		location = "./validate_payment.jsp";
	}
	
	function FocusField(){
		document.form_.or_number.focus();
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
								"ACCOUNTING-BILLING","payment.jsp");
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
	
	double dAmount = 0d;
	Vector vDC = null;
	Vector vSOA = null;	
	Vector vInvoice = null;
	Vector vRetResult = null;
	Vector vDetails = null;
	String strCustomerIndex = null;
	String strCurrencyIndex = null;
	String strORNumber = null;
	String strIsReloaded = WI.fillTextValue("is_reloaded");
	String strCheckCSV = WI.fillTextValue("check_csv");
	String strIsPaid = WI.fillTextValue("is_paid");
	SalesPayment sp = new SalesPayment();
	
	//on else condition before forward to print or page implementation
	/**
		strErrMsg = "Payment recorded successful.";	
		strIsPaid = "1";
		strIsReloaded = "";
		strCheckCSV = "";
	**/
	if(WI.fillTextValue("save_payment").length() > 0){
		if(!sp.operateOnSalesPayment(dbOP, request))
			strErrMsg = sp.getErrMsg();
		else{%>
			<jsp:forward page="./OR_print.jsp" />
			<%	return;
		}
	}
	
	if(strIsPaid.length() == 0){
		vRetResult = sp.validateInvoiceSOANumbers(dbOP, request);
		if(vRetResult == null)
			strErrMsg = sp.getErrMsg();
		else{
			vInvoice = (Vector)vRetResult.elementAt(0);
			vSOA = (Vector)vRetResult.elementAt(1);
			vDC = (Vector)vRetResult.elementAt(2);
			dAmount = Double.parseDouble((String)vRetResult.elementAt(3));
			vDetails = (Vector)vRetResult.elementAt(4);
			
			strORNumber = sp.generateORNumber(dbOP, request);
			if(strORNumber == null && WI.fillTextValue("save_payment").length() == 0)
				strErrMsg = sp.getErrMsg();
		}
	}
%>	
<body bgcolor="#D2AE72" onload="FocusField();">
<form name="form_" action="payment.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>::::  SALES PAYMENT::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="87%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right"><a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0" /></a></td>
		</tr>
	</table>

<%if(vDetails != null && vDetails.size() > 0){%>
	<input type="hidden" name="customer_index" value="<%=(String)vDetails.elementAt(0)%>" />
	<input type="hidden" name="currency_index" value="<%=(String)vDetails.elementAt(4)%>" />
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Charge To: </td>
			<td width="80%"><%=(String)vDetails.elementAt(2)%> (<%=(String)vDetails.elementAt(1)%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Address:</td>
			<td><%=(String)vDetails.elementAt(3)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Currency:</td>
			<td><%=(String)vDetails.elementAt(6)%> (<%=(String)vDetails.elementAt(5)%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Payable Amount: </td>
			<%
				strTemp = CommonUtil.formatFloat(dAmount, true);
				strErrMsg = ConversionTable.replaceString(strTemp, ",", "");
			%>
			<input type="hidden" name="payable_amt" value="<%=strErrMsg%>">
			<td><%=(String)vDetails.elementAt(5)%><%=strTemp%></td>
		</tr>
	</table>
<%}

if(vInvoice != null && vInvoice.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr><td height="15">&nbsp;</td></tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: INVOICE INFORMATION :::  </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="23%" align="center" class="thinborder"><strong>Invoice Number </strong></td>
			<td width="23%" align="center" class="thinborder"><strong>Invoice Date </strong></td>
			<td width="23%" align="center" class="thinborder"><strong>Category</strong></td>
			<td width="21%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Details</strong></td>
		</tr>
	<%for(int i = 0; i < vInvoice.size(); i += 4){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vInvoice.elementAt(i)%></td>
			<td class="thinborder"><%=(String)vInvoice.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vInvoice.elementAt(i+3)%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vInvoice.elementAt(i+2), true)%>&nbsp;</td>
			<td align="center" class="thinborder">
				<a href="javascript:ViewInvoiceInfo('<%=(String)vInvoice.elementAt(i)%>');">VIEW</a></td>
		</tr>
	<%}%>
	</table>
<%}

if(vSOA != null && vSOA.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr><td height="15">&nbsp;</td></tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: SOA INFORMATION :::</strong></div></td>
		</tr>
		<tr>
			<td height="25" width="23%" align="center" class="thinborder"><strong>S/A Number </strong></td>
			<td width="23%" align="center" class="thinborder"><strong>S/A Date </strong></td>
			<td width="23%" align="center" class="thinborder"><strong>Type</strong></td>
			<td width="21%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Details</strong></td>
		</tr>
	<%for(int i = 0; i < vSOA.size(); i += 4){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vSOA.elementAt(i)%></td>
			<td class="thinborder"><%=(String)vSOA.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vSOA.elementAt(i+3)%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vSOA.elementAt(i+2), true)%>&nbsp;</td>
			<td align="center" class="thinborder">
				<a href="javascript:ViewSOAInfo('<%=(String)vSOA.elementAt(i)%>');">VIEW</a></td>
		</tr>
	<%}%>
	</table>
<%}

if(vDC != null && vDC.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr><td height="15">&nbsp;</td></tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: D/C NOTE INFORMATION :::  </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="23%" align="center" class="thinborder"><strong>D/C Number </strong></td>
			<td width="23%" align="center" class="thinborder"><strong>D/C Date </strong></td>
			<td width="23%" align="center" class="thinborder"><strong>Type</strong></td>
			<td width="21%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Details</strong></td>
		</tr>
	<%for(int i = 0; i < vDC.size(); i += 4){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vDC.elementAt(i)%></td>
			<td class="thinborder"><%=(String)vDC.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vDC.elementAt(i+3)%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vDC.elementAt(i+2), true)%>&nbsp;</td>
			<td align="center" class="thinborder">
				<a href="javascript:ViewDCInfo('<%=(String)vDC.elementAt(i)%>');">VIEW</a></td>
		</tr>
	<%}%>
	</table>
<%}

if(vDetails != null && vDetails.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="5"><u><strong>PAYMENT DETAILS</strong></u></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>OR Number: </td>
			<td>
				<%
					if(strErrMsg != null && strORNumber == null)
						strORNumber = WI.fillTextValue("or_number");				
				%>
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
				<font size="1">Click to save invoice payment transaction.</font>
			<%}else{%>
				Not authorized for payment transaction.
			<%}%></td>
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
	
	<input type="hidden" name="invoice_list" value="<%=WI.fillTextValue("invoice_list")%>" />
	<input type="hidden" name="soa_list" value="<%=WI.fillTextValue("soa_list")%>" />
	<input type="hidden" name="dc_list" value="<%=WI.fillTextValue("dc_list")%>" />
	<input type="hidden" name="is_reloaded" value="<%=strIsReloaded%>">
	<input type="hidden" name="save_payment">
	<input type="hidden" name="check_csv" value="<%=strCheckCSV%>" />
	<input type="hidden" name="is_paid" value="<%=strIsPaid%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>