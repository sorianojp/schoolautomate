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
<title>Multiple Payment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
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
function ChangeFeeType()
{
	if(document.fa_payment.fee_type.selectedIndex ==0){
		document.fa_payment.payment_for.value="2"; //fine type.
	}else{
		document.fa_payment.payment_for.value="1"; //tution fee type
	}
//	alert(document.fa_payment.payment_for.value);
	document.fa_payment.focus_.value = "2";
	ReloadPage();
}
function ReloadPage()
{
	document.fa_payment.addRecord.value="";
	//document.fa_payment.submit();
	document.fa_payment.submit();
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
	<%if(strSchCode.startsWith("UC") || true){%>
	var strAmountPayable = document.fa_payment._fee_amt.value;
	if(strAmountPayable.length == 0) {
		alert('Please enter fee rate');
		return ;
	}
	if(eval(document.fa_payment.amount.value) != eval(strAmountPayable)) {
		alert('Amount paid should be same with Amount payable. Plse modify ree rate.');
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
	<%
	if(strSchCode.startsWith("CPU") || strSchCode.startsWith("CLDH") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("UL") || strSchCode.startsWith("FATIMA")){%>
		this.SukliComputation();
	<%}//show Sukli computation%>
	document.fa_payment.addRecord.value="1";
	document.fa_payment.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=fa_payment.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,menubar=no');
	win.focus();
}
function AddFeeName()
{
	if(document.fa_payment.fee_type.selectedIndex == 0) {
		alert("Please select a fee");
		return;
	}
	document.fa_payment.focus_.value="1";
	document.fa_payment.add_fee.value = "1";
	document.fa_payment.list_count.value = ++document.fa_payment.list_count.value;

	document.fa_payment.fee_name.value = document.fa_payment.fee_type[document.fa_payment.fee_type.selectedIndex].text;
	document.fa_payment.fee_index.value = document.fa_payment.fee_type[document.fa_payment.fee_type.selectedIndex].value;

	//get total Fee amount payable .... fee_amount * no_of_units.
	var noOfUnit = document.fa_payment.no_of_units.value;
	if(noOfUnit.length == 0)
		noOfUnit = "1";
	document.fa_payment.fee_amt.value = eval(document.fa_payment.fee_amount.value) * eval(noOfUnit);

	ReloadPage();
}
function RemoveFeeName(removeIndex)
{
	document.fa_payment.remove_index.value = removeIndex;
	ReloadPage();
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
function focusID() {
	if(document.fa_payment.is_fee_rate_sel.value == '1') {
		document.fa_payment.fee_amount.focus();
		document.fa_payment.fee_amount.select();
		return;
	}
	if(document.fa_payment.payee_name)
		document.fa_payment.payee_name.focus();
	else
		document.fa_payment.stud_id.focus();
}

function computeChange() {
	var strAmtTendered = prompt('Please enter Amount tendered.','');
	if(strAmtTendered == null || strAmtTendered.length == 0)
		return;
	document.all.change_div.style.visibility='visible';
	document.fa_payment.amount_tendered.value = strAmtTendered;

	AjaxUpdateChange();
}
/**
function AjaxUpdateChange() {
	<%if(!strSchCode.startsWith("CSA")) {%>
		return;
	<%}%>
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
}**/

function UpdateAmtPaid() {
	var strAmountPayable = document.fa_payment.fine_amount.value;
	if(strAmountPayable.length == 0)
		return;
	if(document.fa_payment.amount.value.length == 0)
		document.fa_payment.amount.value=strAmountPayable;
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
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Other school fees","multiple_payment.jsp");
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
	
	String strStudID = WI.fillTextValue("stud_id");

	if(strStudID.length() > 0) {
		strTemp = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
		//check if rfid is scanned.. 
		if(dbOP.strBarcodeID != null)
			strStudID = dbOP.strBarcodeID;

		/**
		if(strTemp != null && dbOP.strBarcodeID != null && !dbOP.strBarcodeID.equals(strTemp) ) {
			dbOP.cleanUP();
			response.sendRedirect("./multiple_payment.jsp?stud_id="+dbOP.strBarcodeID);
			return;
		}**/
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"multiple_payment.jsp");
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

Vector vStudInfo = null; String strUserIndex = null;

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
boolean bolIsBasic = false;
if(strStudStatus.compareTo("0") == 0)//only if student id is entered.
{
	vStudInfo = paymentUtil.getStudBasicInfo(dbOP, strStudID);
	if(vStudInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
	else {
		strUserIndex = (String)vStudInfo.elementAt(0);
		if(vStudInfo.elementAt(6).equals("0"))
			bolIsBasic = true;
	}
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
<form name="fa_payment" action="./multiple_payment.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center">

	  <font color="#FFFFFF"><strong>:::: OTHER SCHOOL FEES PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=strErrMsg%></font>
	  <div align="right">
	  <a href="./multiple_payment_new.jsp"><font style="font-size:14px; color:#FF0000; font-weight:bold">Go to New Page</font></a>

	  </div>

	  </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 6);
else
	strTemp = null;
if(strTemp != null){%>
     <tr >
       <td height="25">&nbsp;</td>
       <td height="25" colspan="4"class="thinborderALL" style="font-size:15px; color:#FFFF00; background-color:#7777aa"><%=strTemp%></td>
     </tr>
<%} if (!strSchCode.startsWith("CPU")) {%>
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
      <td width="377" align="center">
	  	  <%//get here cutoff time information.
	  Vector vTempCO = new enrollment.FADailyCashCollectionDtls().getCurrentCutoffStat(dbOP, (String)request.getSession(false).getAttribute("userId"));//System.out.println(vTempCO);
	  //I have to get currency rate..
	  String strCurrencyInfo = new locker.Currency().getLatestCurrencyRate(dbOP);
	  if(vTempCO != null){%>
		  <table width="100%" class="thinborderALL" cellpadding="0" cellspacing="0">
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
if(strTemp.length() == 0 && strSchCode.startsWith("PIT"))
	strTemp = "1";

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
      <td width="141"> <input name="stud_id" type="text" size="16" value="<%=strStudID%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event, '0');">      </td>
      <td colspan="2"><font size="1"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></font>
	  <label id="coa_info"></label>	  </td>
    </tr>
    <%}else{%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Payee Name </td>
      <td colspan="3"><input name="payee_name" type="text" size="40" value="<%=WI.fillTextValue("payee_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event, '1');">
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
      <td colspan="6"><hr size="1">
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
      <td  colspan="4" height="25">
<%if(bolIsBasic){%>
	  	Grade Level: <strong><%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0")))%></strong>
<%}else{%>
	  	Course: <strong><%=(String)vStudInfo.elementAt(2)%></strong>
<%}%>
	  </td>
    </tr>
<%if(bolIsBasic){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">SY/Term : <%=(String)vStudInfo.elementAt(8)%> - <%=(String)vStudInfo.elementAt(9)%>
	  (<%=dbOP.getBasicEducationTerm(Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(5), "0")))%>)</td>
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
<%}else{%>
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
<%}%>
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
		<input type="text" name="scroll_fee" size="16" style="font-size:10px; background:#CCCC33"
		  onKeyUp="AutoScrollList('fa_payment.scroll_fee','fa_payment.fee_type',true);"
		   onBlur="document.fa_payment.is_fee_rate_sel.value='1';ReloadPage()" class="textbox">
		   <font size="1">(enter fee name to scroll the list)</font>	  </td>
      <td width="52%">Fee rate</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><select name="fee_type" onChange="document.fa_payment.is_fee_rate_sel.value='1';ChangeFeeType();document.fa_payment.fee_amount.value=''" style="font-size:11px">
          <option value="0">Select a Fee.</option>
          <%
//System.out.println(vStudInfo.elementAt(8));
//System.out.println(vStudInfo.elementAt(9));

 //if(strStudStatus.compareTo("1") ==0)
 /**
 	strTemp = " from FA_OTH_SCH_FEE where is_del=0 and is_valid=1 and year_level=0 and "+
		"sy_index=(select sy_index from FA_SCHYR where sy_from="+request.getParameter("sy_from")+" and sy_to="+
		request.getParameter("sy_to")+") order by FEE_NAME asc";
else
 	strTemp = " from FA_OTH_SCH_FEE where is_del=0 and is_valid=1 and (year_level=0 or year_level="+(String)vStudInfo.elementAt(4)+
 		") and sy_index=(select sy_index from FA_SCHYR where sy_from="+(String)vStudInfo.elementAt(8)+" and sy_to="+
		(String)vStudInfo.elementAt(9)+") order by FEE_NAME asc";
**/

 	strTemp = " from FA_OTH_SCH_FEE where is_del=0 and is_valid=1 and year_level=0 and "+
		"sy_index=(select sy_index from FA_SCHYR where sy_from="+(String)request.getSession(false).getAttribute("cur_sch_yr_from")+") order by FEE_NAME asc";

 %>
          <%=dbOP.loadCombo("OTHSCH_FEE_INDEX","FEE_NAME",strTemp, request.getParameter("fee_type"), false)%>
        </select></td>
      <td>
        <%
//if(WI.fillTextValue("fee_amount").length() > 0)
//	strTemp = WI.fillTextValue("fee_amount");
//else
{
	strTemp = request.getParameter("fee_type");
	if(strTemp == null || strTemp.trim().length() ==0 || strTemp.compareTo("0") ==0)
		strTemp = "";
	else
		strTemp = dbOP.mapOneToOther("FA_OTH_SCH_FEE","OTHSCH_FEE_INDEX",strTemp,"AMOUNT",null);
}
%>
        <!-- no more hidden field..
		<strong><%=strTemp%></strong>
		<input type="hidden" name="fee_amount" value="<%=strTemp%>">
		-->
	<input type="text" name="fee_amount" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="7" maxlength="10"
	  onKeyUp="AllowOnlyFloat('fa_payment','fee_amount');" style="font-weight:bold;">


		<%if(strTemp.compareTo("0") != 0) {%>
			x <input type="text" name="no_of_units" value="<%=WI.fillTextValue("no_of_units")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="4" maxlength="4"
	  onKeyUp="AllowOnlyInteger('fa_payment','no_of_units');" style="font-weight:bold;"> (nos.)

		<%}%>
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td><a href="javascript:AddFeeName();"><img src="../../../images/add.gif" border="0"></a><font size="1">Click
        to add to list of fees to pay</font></td>
      <td>&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>LIST
          OF FEES TO PAY </strong></div></td>
    </tr>
    <tr bgcolor="#33CCFF">
      <td width="68%" height="25" class="thinborder"><div align="center"><strong><font size="1">FEE
          TYPE/NAME</font></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><font size="1">AMOUNT</font></strong></div></td>
      <td width="9%" class="thinborder"><strong><font size="1">REMOVE</font></strong></td>
    </tr>
    <%
strErrMsg = null;
String strFee = null;//this is fee already calculated.
int iRemoveIndex    = Integer.parseInt(WI.getStrValue(WI.fillTextValue("remove_index"),"-1"));

int iCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("list_count"),"0"));

String strFeeIndex     = null;
String strFeeNoOfUnits = null;

for(int i=0; i<iCount; ++i)
{
	if(i == iRemoveIndex)
		continue;
	if( i == iCount -1 && WI.fillTextValue("add_fee").length() > 0) {
		strTemp          = WI.fillTextValue("fee_name");
		strFee           = WI.fillTextValue("fee_amt");
		strFeeIndex      = WI.fillTextValue("fee_index");
		strFeeNoOfUnits  = WI.getStrValue(WI.fillTextValue("no_of_units"),"1");
	}
	else {
		strTemp          = WI.fillTextValue("fee_name"+i);
		strFee           = WI.fillTextValue("fee_amt"+i);
		strFeeIndex      = WI.fillTextValue("fee_i"+i);
		strFeeNoOfUnits  = WI.fillTextValue("fee_no_of_units"+i);
	}
	if(strReceiptDesc == null)
		strReceiptDesc = strTemp+": "+CommonUtil.formatFloat(strFee,true);
	else
		strReceiptDesc = strReceiptDesc+"<br>\r\n"+strTemp+": "+CommonUtil.formatFloat(strFee,true);

	dTotalAmount += Double.parseDouble(WI.getStrValue(strFee,"0"));
	%>
    <input type="hidden" name="fee_name<%=iListCount%>" value="<%=strTemp%>">
    <input type="hidden" name="fee_amt<%=iListCount%>" value="<%=WI.getStrValue(strFee,"0")%>">

    <input type="hidden" name="fee_i<%=iListCount%>" value="<%=WI.getStrValue(strFeeIndex,"0")%>">
    <input type="hidden" name="fee_no_of_units<%=iListCount%>" value="<%=WI.getStrValue(strFeeNoOfUnits,"0")%>">
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder">&nbsp;&nbsp;&nbsp;<strong></strong><%=CommonUtil.formatFloat(strFee,true)%></td>
      <td class="thinborder"><a href='javascript:RemoveFeeName("<%=iListCount%>");' tabindex="-1"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%
	//add here to list, it is safe now.
	++iListCount;
}%>
    <tr>
      <td height="25" class="thinborder"><div align="right">TOTAL &nbsp;&nbsp;: &nbsp;&nbsp;</div></td>
      <td colspan="2" class="thinborder">&nbsp;&nbsp;&nbsp;<strong><%=CommonUtil.formatFloat(dTotalAmount,true)%></strong>
<input type="hidden" name="_fee_amt" value="<%=ConversionTable.replaceString(CommonUtil.formatFloat(dTotalAmount,true), ", ", "")%>">
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
<%if(false && strSchCode.startsWith("CSA")) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
		<div id="change_div" style="visibility:hidden">
			<table>
		      	<td height="25">&nbsp;</td>
      			<td style="font-size:18px;">Change: </td>
      			<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
			</table>
		</div>
	  	     <a href="javascript:computeChange()">Change</a>	  </td>
    </tr>
<%}%>
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
	strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(dTotalAmount,true), ", ", "");
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
	  		<input name="amount_tendered" type="text" size="16" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();MoveNext(event, '_2')" id="_1" autocomplete="off">
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
      <td colspan="3" height="25">
	 <% if (dTotalAmount > 0d){%>
	 <a href="javascript:AddRecord()" id="_2">
	  <img src="../../../images/save.gif" border="0"></a><font size="1">click to save payment detail</font>

	 <%}%> &nbsp;
	  </td>
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

<!--
<input type="hidden" name="amount_tendered" value="">
-->
<input type="hidden" name="is_fee_rate_sel" value="<%=WI.fillTextValue("is_fee_rate_sel")%>">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
