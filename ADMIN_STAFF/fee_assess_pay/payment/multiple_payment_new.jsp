<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

if(strSchCode.startsWith("DLSHSI")) //tracking is for lasalle only.. 
	request.getSession(false).setAttribute("start_time_long_or",String.valueOf(new java.util.Date().getTime()));

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.nav {
     color: #000000;
     background-color: #D2D6C0;
	 font-weight:normal;
}
.nav-highlight {
     color: #FF0000;
     background-color: #FAFCDD;
	 font-weight:bold;
}

</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/formatFloat.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function navRollOver(obj, state) {
  //document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
function UpdatePaymentInfo(obj, objChkBox, bolIsInputBox) {
	if(bolIsInputBox && !objChkBox.checked)
		return;
	document.fa_payment.amount.value = '';
	document.fa_payment.pmt_desc.value = '';
	if(!objChkBox.checked)
		obj.value = '';
	//I have to check what is already checked and what is not.
	var iMaxDisp = document.fa_payment.list_count.value;
	if(iMaxDisp.length == 0 || iMaxDisp == 0)
		return;
	var totalAmt = 0; var strPmtDesc = "";
	var dAmt = 0; var iNoOfUnits;
	for(i = 0; i < iMaxDisp; ++i) {
		eval('obj=document.fa_payment.fee_i'+i);
		if(!obj.checked)
			continue;

		eval('obj=document.fa_payment.fee_amt'+i);
		dAmt = eval(obj.value);

		eval('obj=document.fa_payment.fee_no_of_units'+i);

		if(obj.value.length == 0) {
			obj.value = '1';
			iNoOfUnits = 1;
		}
		else
			iNoOfUnits = eval(obj.value);
		dAmt = eval(dAmt) * eval(iNoOfUnits);

		totalAmt = totalAmt + eval(dAmt);

		eval('obj=document.fa_payment.fee_name'+i);
		if(strPmtDesc == '')
			strPmtDesc = obj.value+": "+formatFloat(dAmt,1);
		else
			strPmtDesc = strPmtDesc+"<br>\r\n"+obj.value+": "+formatFloat(dAmt,1);
	}
		document.fa_payment.pmt_desc.value = strPmtDesc;
		document.fa_payment.amount.value = formatFloat(totalAmt, 1);
		document.fa_payment.amt_payable_.value = totalAmt;

}
function SelALL() {
	var bolIsChecked = false;
	if(document.fa_payment.sel_all.checked)
		bolIsChecked = true;
	else
		bolIsChecked = false;

	document.fa_payment.amount.value = '';
	document.fa_payment.pmt_desc.value = '';

	var iMaxDisp = document.fa_payment.list_count.value;
	if(iMaxDisp.length == 0 || iMaxDisp == 0)
		return;
	var totalAmt = 0; var strPmtDesc = "";
	var dAmt = 0; var iNoOfUnits;

	if(!bolIsChecked) {
		for(i = 0; i < iMaxDisp; ++i) {
			eval('obj=document.fa_payment.fee_i'+i);
			obj.checked = false;
			eval('obj=document.fa_payment.fee_no_of_units'+i);
			obj.value = '';
		}
		return;
	}
	//I have to now process all row..
	for(i = 0; i < iMaxDisp; ++i) {
		eval('obj=document.fa_payment.fee_i'+i);
		obj.checked = true;

		eval('obj=document.fa_payment.fee_amt'+i);
		dAmt = eval(obj.value);

		eval('obj=document.fa_payment.fee_no_of_units'+i);
		if(obj.value.length == 0) {
			obj.value = '1';
			iNoOfUnits = 1;
		}
		else
			iNoOfUnits = eval(obj.value);
		dAmt = eval(dAmt) * eval(iNoOfUnits);

		totalAmt = totalAmt + eval(dAmt);

		eval('obj=document.fa_payment.fee_name'+i);
		if(strPmtDesc == '')
			strPmtDesc = obj.value+": "+formatFloat(dAmt,1);
		else
			strPmtDesc = strPmtDesc+"<br>\r\n"+obj.value+": "+formatFloat(dAmt,1);
	}
		document.fa_payment.pmt_desc.value = strPmtDesc;
		document.fa_payment.amount.value = formatFloat(totalAmt, 1);


}


function ShowHideApprovalNo()
{
	if(document.fa_payment.payment_mode.selectedIndex == 2)
		document.fa_payment.approval_number.disabled = false;
	else
		document.fa_payment.approval_number.disabled = true;
}
function ShowHideCheckNO()
{
	if(document.fa_payment.payment_type.selectedIndex == 0) {
		document.fa_payment.CHECK_FR_BANK_INDEX.selectedIndex = 0;
		document.fa_payment.CHECK_FR_BANK_INDEX.disabled = true;
		document.fa_payment.check_number.disabled = true;
	}
	else {
		document.fa_payment.CHECK_FR_BANK_INDEX.disabled = false;
		document.fa_payment.check_number.disabled = false;
	}
	if(document.fa_payment.payment_type.selectedIndex == 2)
		showLayer('myADTable1');
	else
		hideLayer('myADTable1');
	document.fa_payment.chk_amt.value = "";
	document.fa_payment.cash_amt.value = "";
}
function ReloadPage()
{
	document.fa_payment.addRecord.value="";
	document.fa_payment.submit();
	//this.SubmitOnce('fa_payment');
}
function AddRecord()
{
	<%if(strSchCode.startsWith("SPC")){%>
		if(document.fa_payment.amount_tendered.value.length == 0) {
			alert("Please enter amount tendered.");
			document.fa_payment.amount_tendered.focus();
			return;
		}
	<%}%>
	//check change should not be -ve..
	if(document.getElementById("change_")) {
		var strChange = document.getElementById("change_").innerHTML;
		if(strChange.length > 0 && strChange.charAt(0) == "-") {
			alert("Amount tendered is less than Amount Paid.");
			document.fa_payment.amount_tendered.focus();
			return;
		}
	}
	this.AllowOnlyFloat('fa_payment','amount');
	<%
	if(strSchCode.startsWith("CPU") || strSchCode.startsWith("CLDH") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("UL") || strSchCode.startsWith("FATIMA")){%>
		this.SukliComputation();
	<%}//show Sukli computation%>


	<%if(strSchCode.startsWith("UC") || true){%>
	var strAmountPayable = document.fa_payment.amt_payable_.value;
	//alert(strAmountPayable);
	//alert(document.fa_payment.amount.value);

	if(strAmountPayable.length == 0) {
		alert('Please select a fee');
		return ;
	}
	if(eval(document.fa_payment.amount.value) != eval(strAmountPayable)) {
		alert('Amount paid should be same with Amount payable. Plse modify ree rate.');
		return;
	}
	<%}%>

	document.fa_payment.addRecord.value="1";
	document.fa_payment.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=fa_payment.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,menubar=no');
	win.focus();
}
function computeCashChkAmt() {
	var totAmt  = document.fa_payment.amount.value;
	var chkAmt  = document.fa_payment.chk_amt.value;
	var cashAmt = document.fa_payment.cash_amt.value;

	if(totAmt.length == 0)
		return;
	if(chkAmt.length == 0) {
		document.fa_payment.cash_amt.value = "";
		return;
	}
	cashAmt = eval(totAmt - chkAmt);
	document.fa_payment.cash_amt.value = eval(cashAmt);
}
///this is added for CLDH and CPU only.
function SukliComputation() {
	return;
	var vAmtPaid = document.fa_payment.amount.value;

	var vAmtReceived  = prompt("Please enter Amount received.", vAmtPaid);
    if(vAmtReceived == null || vAmtReceived.length == 0)  {
		vAmtReceived = vAmtPaid;
	}
	document.fa_payment.sukli.value = vAmtReceived;


}
function ChangeFocus(){
	return;
	var setFocus = document.fa_payment.focus_.value;

	if (setFocus.length == 0)
		setFocus = "1";

	switch(Number(setFocus)){
		case 1 : // set focus to fee types auto scroll
				if (document.fa_payment.auto_scroll)
					document.fa_payment.auto_scroll.focus();
				break;
		case 2 :if (document.fa_payment.no_of_units){
					document.fa_payment.no_of_units.focus();
					document.fa_payment.no_of_units.select();
				}
				break;

	}
}

function ShowRecords(){
	if (document.fa_payment.stud_id){
		if(document.fa_payment.stud_id.value.length == 0){
			alert (" Please set the Student ID ");
			document.fa_payment.stud_id.focus();
			return;
		}
	}else if (document.fa_payment.payee_name){
		if(document.fa_payment.payee_name.value.length == 0){
			alert (" Please set the Payee");
			document.fa_payment.payee_name.focus();
			return;
		}
	}

	document.fa_payment.focus_.value = "1";
	ReloadPage();

}

var calledRef;
//all about ajax - to display student list with same name.
function AjaxMapName(e, strRef) {
		if(e.keyCode == 13) {
			this.ReloadPage();
			return;
		}
	calledRef = strRef;
	var strCompleteName;
	if(strRef == "0") {
		strCompleteName = document.fa_payment.stud_id.value;
		if(strCompleteName.length <3)
			return;
	}
	else {
		strCompleteName = document.fa_payment.payee_name.value;
		if(strCompleteName.length < 3) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}
	}

	/// this is the point i must check if i should call ajax or not..
	if(this.bolReturnStrEmpty && this.startsWith(this.strPrevEntry,strCompleteName, false) == 0)
		return;
	this.strPrevEntry = strCompleteName;

	var objCOAInput;
	objCOAInput = document.getElementById("coa_info");

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&name_format=5&complete_name="+
		escape(strCompleteName);
	if(strRef == '1')
		strURL += "&search_temp=2";

	this.processRequest(strURL);
	//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	if(calledRef == "0") {
		document.fa_payment.stud_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";

		this.ReloadPage();
	}

}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
	if(calledRef == "1") {
		document.fa_payment.payee_name.value = strName;
		document.getElementById("coa_info").innerHTML = "";
	}
}

function AjaxUpdateChange() {
		var strAmtPaid     = document.fa_payment.amount.value;
		var strAmtTendered = document.fa_payment.amount_tendered.value;
		if(strAmtPaid.length == 0 || strAmtTendered.length == 0)
			return;

		var objCOAInput = document.getElementById("change_");
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=152&amt_tendered="+strAmtTendered+"&amt_paid="+strAmtPaid;
		this.processRequest(strURL);
}
function focusID() {
	if(document.fa_payment.payee_name)
		document.fa_payment.payee_name.focus();
	else
		document.fa_payment.stud_id.focus();
}
function MoveNext(e, objNext1) {//alert("I am here.");
	if(e.keyCode == 13) {
		var objElement = document.getElementById(objNext1);
		if(objElement)
			objElement.focus();
	}
}

</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAPayment,java.util.Vector" buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strStudStatus = WI.fillTextValue("stud_status");


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Other school fees","multiple_payment_new.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"multiple_payment_new.jsp");
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
	if(!comUtil.isTellerAllowedToCollectPmtUB(dbOP, (String)request.getSession(false).getAttribute("userIndex"), WI.getTodaysDate(), (String)request.getSession(false).getAttribute("school_code"))) {
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","<font style='font-size:24px; font-weight:bold'>Not allowed to accept payment.</font>");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}

//end of authenticaion code.

Vector vStudInfo = null;

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
//System.out.println(request.getParameter("payment_for"));
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") ==0)
{
	if(!paymentUtil.isORIssuedToTeller(dbOP, request.getParameter("or_number"), (String)request.getSession(false).getAttribute("userIndex"), strSchCode))
		strErrMsg = paymentUtil.getErrMsg();
	else if(faPayment.saveMultipleReceipt(dbOP,request))//always false for tution / fine payment
	{
		dbOP.cleanUP();
			String strSukli = WI.fillTextValue("sukli");
			if(strSukli.length() > 0) {
				//keep change in attribute.
				double dAmtReceived = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""));
				dAmtReceived = dAmtReceived - Double.parseDouble(WI.fillTextValue("amount"));
				strSukli = "&sukli="+ CommonUtil.formatFloat(dAmtReceived,true);
			}
		response.sendRedirect(response.encodeRedirectURL("./install_assessed_fees_print_receipt.jsp?or_number="+request.getParameter("or_number")+strSukli+
		"&fund_type="+request.getParameter("fund_type")));
		return;
	}
	else
		strErrMsg = faPayment.getErrMsg();
}


String strStudID = WI.fillTextValue("stud_id");

if(strStudStatus.compareTo("0") == 0)//only if student id is entered.
{
	vStudInfo = paymentUtil.getStudBasicInfo(dbOP, strStudID);
		//check if rfid is scanned.. 
	if(dbOP.strBarcodeID != null)
		strStudID = dbOP.strBarcodeID;

	
	if(vStudInfo == null) 
		strErrMsg = paymentUtil.getErrMsg();
	//System.out.println(strErrMsg);
}
if(strStudStatus == null || strStudStatus.trim().length() ==0)
{
	strErrMsg = "Please select student status type.";
}
else
{
	if(strStudStatus.compareTo("1") == 0)
	{
		if(request.getParameter("payee_name") == null  	|| request.getParameter("payee_name").trim().length() ==0 ||
			request.getParameter("sy_from") == null || request.getParameter("sy_from").trim().length() ==0 ||
			request.getParameter("sy_to") == null 	|| request.getParameter("sy_to").trim().length() ==0)
		strErrMsg = "Please enter name/school year of other fee information.";
	}
}
if(strErrMsg == null) strErrMsg = "";

//added here are for multiple fee display.
	int iListCount = 0;
	double dTotalAmount  = 0d;
	String strReceiptDesc = null;


boolean bolRemoveAlreadyPosted = false;
if(strSchCode.startsWith("FATIMA"))
	bolRemoveAlreadyPosted = true;

//boolean bolIsDatePaidReadonly = false;
//if(strSchCode.startsWith("UC") || strSchCode.startsWith("EAC") || strSchCode.startsWith("FATIMA"))
//	bolIsDatePaidReadonly = true;
boolean bolIsDatePaidReadonly = comUtil.isPaymentDateReadOnly(dbOP, request);

%>
<form name="fa_payment" action="./multiple_payment_new.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center">

	  <font color="#FFFFFF"><strong>:::: OTHER SCHOOL FEES PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=strErrMsg%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	 <% if (!strSchCode.startsWith("CPU")) {%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;<% if (!strSchCode.startsWith("CPU")) {%>Accounts<%}%></td>
      <td colspan="2">


	  <select name="stud_status" onChange="ReloadPage();">
          <option value="0">Internal</option>
          <% if(strStudStatus.equals("1")){%>
          <option value="1" selected>External</option>
          <%}else{%>
          <option value="1">External</option>
          <%}%>
        </select>


	&nbsp;</td>
      <td width="266" align="center">
	  	  <%//get here cutoff time information.
	  Vector vTempCO = new enrollment.FADailyCashCollectionDtls().getCurrentCutoffStat(dbOP, (String)request.getSession(false).getAttribute("userId"));//System.out.println(vTempCO);
	  //I have to get currency rate..
	  String strCurrencyInfo = new locker.Currency().getLatestCurrencyRate(dbOP);
	  if(vTempCO != null){%>
		  <table width="65%" class="thinborderALL" cellpadding="0" cellspacing="0">
		  <tr><td height="20" align="right">
		  <%
		  strTemp = "Time :: "+(String)vTempCO.elementAt(0) + "&nbsp;&nbsp;";
		  if(vTempCO.elementAt(1) != null) {//cut off time is set.
		  	if( ((String)vTempCO.elementAt(2)).equals("1"))
				strTemp += "<br><font color=red>Cut off :: "+(String)vTempCO.elementAt(1)+"</font>"+
							"&nbsp;&nbsp;";
			else
				strTemp += "<br>Cut off :: "+(String)vTempCO.elementAt(1) +
							"&nbsp;&nbsp;" ;
		  }
                  if(vTempCO.elementAt(2) != null)
                  	strTemp += "<br>Collection :: "+(String)vTempCO.elementAt(3) +
							 "&nbsp;&nbsp;";
                  %>
              <strong><%=strTemp%><%=strCurrencyInfo%></strong> </td>
          </tr>
	    </table>
      <%}//only if cutoff time is set.%>	  </td>
    </tr>
    <% }

	if(!strStudStatus.equals("1")){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Payment status</td>
      <td  colspan="3"> <select name="pmt_status">
          <option value="0">Payment for Charges NOT POSTED</option>
          <%
strTemp = WI.fillTextValue("pmt_status");
if(!bolRemoveAlreadyPosted) {
	if(strTemp.compareTo("1") ==0){%>
			  <option value="1" selected>Payment for Charges ALREADY POSTED</option>
			  <%}else{%>
			  <option value="1">Payment for Charges ALREADY POSTED</option>
	<%}
}%>
        </select> <font size="1">Pls ask support for any question </font></td>
    </tr>
    <tr valign="top">
      <td width="14" height="25">&nbsp;</td>
      <td width="126" height="25">Student ID &nbsp; </td>
      <td width="141"><input name="stud_id" type="text" size="16" value="<%=strStudID%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event, '0');"></td>
      <td colspan="2"><font size="1"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></font>
	  <label id="coa_info"></label>	  </td>
    </tr>
    <%}else{%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Payee Name </td>
      <td colspan="3"><input name="payee_name" type="text" size="40" value="<%=WI.fillTextValue("payee_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event,'1');">
        <font size="1">
		<% if (!strSchCode.startsWith("CPU")) {%>
			&lt;if payee is not a current student of the school&gt;
			<input type="hidden" name="pmt_status" value="0">
		<%}else{%>
		<input type="hidden" name="stud_status" value="1">
			&lt; Student Name or Company Name, as is &gt;
		<%}%>
		</font>
	  <br>
	  <label id="coa_info"></label>		</td>
    </tr>
    <!-- this is current school year the payee is paying. if payee is paying for 2 times,
	I can differentiate for school year. -->
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">School year</td>
      <td colspan="3">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>	  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fa_payment","sy_from","sy_to")' tabindex = "-1">
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes" tabindex="-1">
        TERM:
        <select name="semester" tabindex="-1">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")){
		  	if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }
		  if(strTemp.equals("0")){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
    <%}%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="3">

	  <a href="javascript:ShowRecords();"><img src="../../../images/form_proceed.gif" border="0"></a>	  </td>
    </tr>
  </table>

<%
if(strErrMsg.length() == 0){ // the outer most condition.

if(vStudInfo != null && vStudInfo.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1">
	  <!-- enter here all hidden fields for student. -->
	  <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
	  <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(4)%>">
	  <input type="hidden" name="is_tempstud" value="<%=paymentUtil.isTempStudInStr()%>">
	  <input type="hidden" name="sy_from" value="<%=(String)vStudInfo.elementAt(8)%>">
	  <input type="hidden" name="sy_to" value="<%=(String)vStudInfo.elementAt(9)%>">
	  <input type="hidden" name="semester" value="<%=(String)vStudInfo.elementAt(5)%>">
	  </td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="43%" height="25">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%> </strong></td>
      <td  colspan="4" height="25">Course :<strong><%=(String)vStudInfo.elementAt(2)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Year :<strong><%=dbOP.getHEYearLevel(Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0")))%></strong> </td>
      <td  colspan="4" height="25">Major : <strong><%=WI.getStrValue((String)vStudInfo.elementAt(3))%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">SY/Term : <%=(String)vStudInfo.elementAt(8)%> - <%=(String)vStudInfo.elementAt(9)%>
	  (<%=dbOP.getHETerm(Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(5), "-1")))%>)</td>
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
  </table>
<%}//if student info is not null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="25" colspan="9" bgcolor="#B9B292"><div align="center">FEE
          DETAILS </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="24">&nbsp;</td>
      <td width="46%" valign="middle">Fee type :
		<input type="text" name="scroll_fee" size="20" style="font-size:10px; background:#CCCC33" class="textbox">
		   <font size="1">(Click refresh to limit the display below)</font>	  </td>
      <td width="52%" style="font-size:9px; color:#FF0000; font-weight:bold">
	  <input type="checkbox" name="sel_all" onClick="SelALL();">
	  Click to select all
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  <div style="height:250px; overflow:scroll">
	  <table width="80%" cellpadding="0" cellspacing="0" align="center" class="thinborder">
	  	<tr>
			<td colspan="2" align="center" class="thinborder" bgcolor="#FFCC99"><strong>Select Multiple Fee</strong></td>
		</tr>
		<%
		strTemp = "select OTHSCH_FEE_INDEX, fee_name, amount ";
 	strTemp += " from FA_OTH_SCH_FEE where is_del=0 and is_valid=1 and year_level=0 and "+
		"sy_index=(select sy_index from FA_SCHYR where sy_from="+(String)request.getSession(false).getAttribute("cur_sch_yr_from")+")";
/**
		 if(strStudStatus.compareTo("1") ==0)
			strTemp += " from FA_OTH_SCH_FEE where is_del=0 and is_valid=1 and year_level=0 and "+
				"sy_index=(select sy_index from FA_SCHYR where sy_from="+request.getParameter("sy_from")+") ";
		 else
			strTemp += " from FA_OTH_SCH_FEE where is_del=0 and is_valid=1 and (year_level=0 or year_level="+(String)vStudInfo.elementAt(4)+
				") and sy_index=(select sy_index from FA_SCHYR where sy_from="+(String)vStudInfo.elementAt(8)+") ";
**/
			if(WI.fillTextValue("scroll_fee").length() > 0) {
				String strCon = WI.fillTextValue("scroll_fee");
				Vector vSplit = CommonUtil.convertCSVToVector(strCon," ", true);
				strCon = "";
				while(vSplit.size() > 0) {
					if(strCon.length() == 0)
						strCon = " fee_name like '"+(String)vSplit.remove(0)+"%' ";
					else
						strCon += " or fee_name like '"+(String)vSplit.remove(0)+"%' ";
				}

				strTemp += " and ("+strCon+") ";//" and fee_name like '"+WI.fillTextValue("scroll_fee")+"%' ";

			}
			strTemp += " order by fee_name";
			java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
			while(rs.next()){
 		%>
			<tr class="nav" id="msg<%=iListCount%>" onMouseOver="navRollOver('msg<%=iListCount%>', 'on')" onMouseOut="navRollOver('msg<%=iListCount%>', 'off')">
				<td class="thinborder" width="70%" style="font-size:9px;">
				<label for="_id<%=iListCount%>">
				<input type="checkbox" id="_id<%=iListCount%>" name="fee_i<%=iListCount%>" value="<%=rs.getString(1)%>" onClick="UpdatePaymentInfo(document.fa_payment.fee_no_of_units<%=iListCount%>,document.fa_payment.fee_i<%=iListCount%>);"><%=rs.getString(2)%>
			    </label>
				<input type="hidden" name="fee_name<%=iListCount%>" value="<%=rs.getString(2)%>">
				</td>
				<td class="thinborder">
				<input type="text" name="fee_amt<%=iListCount%>" value="<%=ConversionTable.replaceString(CommonUtil.formatFloat(rs.getDouble(3), true), ",","")%>"
				 class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12" maxlength="12"
				 onKeyUp="AllowOnlyFloat('fa_payment','fee_amt<%=iListCount%>');"> X
				<input type="text" name="fee_no_of_units<%=iListCount%>" value="<%=WI.fillTextValue("fee_no_of_units"+iListCount)%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
				onBlur="UpdatePaymentInfo(document.fa_payment.fee_no_of_units<%=iListCount%>,document.fa_payment.fee_i<%=iListCount%>, true);style.backgroundColor='white'" size="4" maxlength="4" onKeyUp="AllowOnlyInteger('fa_payment','fee_no_of_units<%=iListCount%>');"
				> (nos)</td>
			</tr>

		<%++iListCount;}rs.close();%>

	  </table>
	  </div>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5" bgcolor="#FFFFCF"><div align="center"><strong>PAYMENT
          DETAILS </strong></div></td>
    </tr>
    <tr bgcolor="#CCCCCC">
      <td height="18" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="top" class="thinborderTOP">&nbsp;</td>
      <td colspan="3" class="thinborderTOPRIGHT">&nbsp;</td>
    </tr>
    <tr bgcolor="#CCCCCC">
      <td height="25" class="thinborderLEFT">&nbsp;</td>
      <td valign="top"> Payment Detail<br> <font size="1" color="#0000FF">add
        &lt;br&gt; to insert line break. Example : <br>
        OTR Pmt : 200&lt;br&gt;<br>
        Diploma: 500&lt;br&gt;<br>
        Grad fee: 1000&lt;br&gt;</font></td>
      <td colspan="3" class="thinborderRIGHT"><textarea name="pmt_desc" rows="6" cols="80" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  style="font-size:10px; color:#194685; font-weight:bold"
	  tabindex="-1"><%=WI.getStrValue(strReceiptDesc)%></textarea></td>
    </tr>
    <tr bgcolor="#CCCCCC">
      <td height="18" class="thinborderLEFT">&nbsp;</td>
      <td align="right"> <font size="2" color="#660099"><strong>Must Read: </strong></font>&nbsp;&nbsp;&nbsp;</td>
      <td colspan="3" class="thinborderRIGHT"><font size="2" color="#660099"><strong>
        Please do not accept Tuition<% if (!strSchCode.startsWith("CPU")){%>/Misc<%}%> fee here. Go to Installment payment.
        </strong></font></td>
    </tr>
    <tr bgcolor="#CCCCCC">
      <td height="18" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOM">&nbsp;</td>
      <td colspan="3" class="thinborderBOTTOMRIGHT">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
			<div id="change_div">
			<table cellpadding="0" cellspacing="0">
      			<td style="font-size:18px;">Change: &nbsp;</td>
      			<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
			</table>
		</div>
	  </td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Amount paid </td>
      <td width="21%"> <%
strTemp = WI.fillTextValue("amount");
if(dTotalAmount > 0d)
	strTemp = Double.toString(dTotalAmount);
%> <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-weight:bold; font-size:15px;" onKeyUp="AjaxUpdateChange();MoveNext(event, '_1')" autocomplete="off">      </td>
      <td width="11%">Check #</td>
      <td width="46%"> <%
strTemp = "";
if(request.getParameter("payment_type") == null || 	 request.getParameter("payment_type").trim().length() ==0 ||
	request.getParameter("payment_type").compareTo("0") == 0)
{
	strTemp = "disabled";
}%> <input name="check_number" type="text" size="16" value="<%=WI.fillTextValue("check_number")%>" <%=strTemp%> class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Amount Tendered </td>
      <td>
	  		<input name="amount_tendered" type="text" size="16" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();MoveNext(event, '_2')" autocomplete="off">
	  </td>
      <td>&nbsp;</td>
      <td><select name="CHECK_FR_BANK_INDEX" style="font-size:10px" >
          <option value=""></option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH"," from FA_BANK_LIST where is_valid = 1 order by bank_code", request.getParameter("CHECK_FR_BANK_INDEX"), false)%>
        </select>
        <div id="myADTable1">Amt Chk
        <input name="chk_amt" type="text" size="8" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('fa_payment','amount');computeCashChkAmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('fa_payment','chk_amt');computeCashChkAmt();">
        Cash
        <input name="cash_amt" type="text" size="8" class="textbox_noborder" readonly="yes">
       </div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payment type</td>
      <td> <select name="payment_type" onChange="ShowHideCheckNO();">
          <option value="0">Cash</option>
          <%
 strTemp = WI.fillTextValue("payment_type");
 if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Check</option>
          <%}else{%>
          <option value="1">Check</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>Cash and check</option>
          <%}else{%>
          <option value="5">Cash and check</option>
          <%}%>
        </select> </td>
      <td>Date paid</td>
      <td><font size="1">&nbsp;
        <%
strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%>
        <input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%if(!bolIsDatePaidReadonly) {%>
        <a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
<%}%>
        </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payment receive type</td>
      <td> <select name="pmt_receive_type" onChange="ReloadPage();">
          <option value="Internal">Internal</option>
          <%
strTemp = WI.fillTextValue("pmt_receive_type");
if(strTemp.compareTo("External") ==0){%>
          <option value="External" selected>External</option>
          <%}else{%>
          <option value="External">External</option>
          <%}%>
        </select> </td>
      <td>Ref #</td>
      <td><font size="1"><b>
        <!--       <%
	   	//strTemp = paymentUtil.generateORNumber(dbOP);
	   //	if(strTemp == null)
	   //		strTemp = paymentUtil.getErrMsg();
		//else{%>
        <input type="hidden" name="or_number" value="<%//=strTemp%>">
        <%//}%>
        <%//=strTemp%> -->
        <input name="or_number" type="text" size="18" value="<%=paymentUtil.generateORNumber(dbOP,(String)request.getSession(false).getAttribute("userIndex"), true)%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </b></font></td>
    </tr>
    <% if(strTemp.compareTo("External") ==0) //External
{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Bank name</td>
      <td colspan="3"> <select name="bank">
          <%=dbOP.loadCombo("AB_INDEX","AFF_BANK_NAME"," from FA_AFFILIATED_BANK where is_del=0 order by AFF_BANK_NAME asc",
   		request.getParameter("bank"), false)%> </select> </td>
    </tr>
    <%}//only if receive type is external
%>
  </table>
<script language="JavaScript">
ShowHideCheckNO();
</script>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="9"><hr size="1"></td>
    </tr>
<%if(iAccessLevel > 1){%>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td colspan="3" height="25"><a href="javascript:AddRecord();" id="_2">
	  <img src="../../../images/save.gif" border="0"></a>
	  <font size="1">click
        to save payment detail</font>&nbsp;	  </td>
      <td width="10%"  height="25">&nbsp;</td>
    </tr>
<%}%>
</table>

<%
}//if error message is null -> outer most condition.
%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	<td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

 <input type="hidden" name="addRecord" value="0">
<input type="hidden" name="payment_for" value="8">

<input type="hidden" name="list_count" value="<%=iListCount%>">
<input type="hidden" name="remove_index">
<input type="hidden" name="add_fee">


<input type="hidden" name="fee_name">
<input type="hidden" name="fee_amt">
<input type="hidden" name="fee_index">
<input type="hidden" name="sukli">
<input type="hidden" name="focus_" value="<%=WI.fillTextValue("focus_")%>">
<input type="hidden" name="fund_type" value="<%=WI.fillTextValue("fund_type")%>">
<input type="hidden" name="amt_payable_">

<script language="javascript">
	ChangeFocus();
</script>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
