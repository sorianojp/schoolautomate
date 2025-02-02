<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAPayment,java.util.Vector" buffer="16kb" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";
if(strSchoolCode.startsWith("CIT") && WI.fillTextValue("pay_res_fee").length() == 0){
	response.sendRedirect("./otherschoolfees_new.jsp");
	return;
}

if(strSchoolCode.startsWith("DLSHSI")) //tracking is for lasalle only.. 
	request.getSession(false).setAttribute("start_time_long_or",String.valueOf(new java.util.Date().getTime()));

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Other School Fees</title>
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
	if(!document.fa_payment.payment_type)
		return;
	var iPaymentTypeSelected = document.fa_payment.payment_type.selectedIndex;
	var strPaymentType = document.fa_payment.payment_type[document.fa_payment.payment_type.selectedIndex].text;
	var strPaymentTypeVal = document.fa_payment.payment_type[document.fa_payment.payment_type.selectedIndex].value;
	
	if(document.fa_payment.prevent_chk_pmt && document.fa_payment.prevent_chk_pmt.value == '1') {
		if(strPaymentTypeVal == '1' || strPaymentTypeVal == '5') {
			alert("Check Payment is not allowed.");
			document.fa_payment.payment_type.selectedIndex = 0;
			return;
		} 
	}

	if(iPaymentTypeSelected == 1 || iPaymentTypeSelected == 2 || strPaymentType == "Bank Payment") {
		document.fa_payment.CHECK_FR_BANK_INDEX.disabled = false;
		document.fa_payment.check_number.disabled = false;
	}
	else {
		document.fa_payment.CHECK_FR_BANK_INDEX.selectedIndex = 0;
		document.fa_payment.CHECK_FR_BANK_INDEX.disabled = true;
		document.fa_payment.check_number.disabled = true;
	}


	if(iPaymentTypeSelected == 2)
		showLayer('myADTable1');
	else
		hideLayer('myADTable1');
	document.fa_payment.chk_amt.value = "";
	document.fa_payment.cash_amt.value = "";

	if(iPaymentTypeSelected >= 3 &&  strPaymentType != "Bank Payment")//credit card..
		showLayer('credit_card_info');
	else
		hideLayer('credit_card_info');

/**
	if(document.fa_payment.payment_type.selectedIndex == 1 || document.fa_payment.payment_type.selectedIndex == 2) {
		document.fa_payment.CHECK_FR_BANK_INDEX.disabled = false;
		document.fa_payment.check_number.disabled = false;
	}
	else {
		document.fa_payment.CHECK_FR_BANK_INDEX.selectedIndex = 0;
		document.fa_payment.CHECK_FR_BANK_INDEX.disabled = true;
		document.fa_payment.check_number.disabled = true;
	}
	if(document.fa_payment.payment_type.selectedIndex == 2)
		showLayer('myADTable1');
	else
		hideLayer('myADTable1');
	document.fa_payment.chk_amt.value = "";
	document.fa_payment.cash_amt.value = "";
**/
}
function ChangeFeeType()
{
	if(document.fa_payment.fee_type.selectedIndex ==0)
		document.fa_payment.payment_for.value="2"; //fine type.
	else
		document.fa_payment.payment_for.value="1"; //tution fee type
//	alert(document.fa_payment.payment_for.value);
	ReloadPage();
}
function ReloadPage()
{
	document.fa_payment.addRecord.value="";
	document.fa_payment.submit();
}
function AddRecord()
{
	<%if(strSchoolCode.startsWith("SPC")){%>
		if(document.fa_payment.amount_tendered.value.length == 0) {
			alert("Please enter amount tendered.");
			document.fa_payment.amount_tendered.focus();
			return;
		}
	<%}%>
	//For UC, i have to make sure the amount paid and fee rate are the same.. 
	<%if(strSchoolCode.startsWith("UC") || true){%>
	var strAmountPayable = document.fa_payment.fine_amount.value;
	if(strAmountPayable.length == 0) {
		alert('Please enter fee rate');
		return ;
	}
	if(document.fa_payment.no_of_units) {
		if(document.fa_payment.no_of_units.value != '') {
			strAmountPayable = eval(strAmountPayable) * eval(document.fa_payment.no_of_units.value);
		}
	}
	if(eval(document.fa_payment.amount.value) != eval(strAmountPayable)) {
		alert('Amount paid should be same with Amount payable. Plse modify ree rate.');
		return;
	}
	<%}%>
	
	<%
	if(strSchoolCode.startsWith("CPU") || strSchoolCode.startsWith("CLDH") || strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("PHILCST") ||
	strSchoolCode.startsWith("DBTC") || strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("FATIMA")){%>
		this.SukliComputation();
	<%}//show Sukli computation%>
	document.fa_payment.addRecord.value="1";
	document.fa_payment.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=fa_payment.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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

//to compute change for CSA --
function computeChange() {
	var strAmtTendered = prompt('Please enter Amount tendered.','');
	if(strAmtTendered == null || strAmtTendered.length == 0)
		return;
	document.all.change_div.style.visibility='visible';
	document.fa_payment.amount_tendered.value = strAmtTendered;

	AjaxUpdateChange();
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
	<%if(WI.fillTextValue("book_payment").equals("1")){%>
		if(document.fa_payment.amount_tendered) {
			document.fa_payment.amount_tendered.focus();
			return;
		}
	<%}%>
	if(document.fa_payment.payee_name)
		document.fa_payment.payee_name.focus();
	else
		document.fa_payment.stud_id.focus();

	if(!document.fa_payment.fine_amount)
		return;
	if(document.fa_payment.is_fee_rate_sel.value == '1') {
		document.fa_payment.fine_amount.focus();
		document.fa_payment.fine_amount.select();
		return;
	}

}
function UpdateAmtPaid() {
	var strAmountPayable = document.fa_payment.fine_amount.value;
	if(strAmountPayable.length == 0)
		return;
	if(document.fa_payment.amount.value.length == 0)
		document.fa_payment.amount.value=strAmountPayable;
}
function UpdateAmtPaidForce() {
	var strAmountPayable = document.fa_payment.fine_amount.value;
	if(strAmountPayable.length == 0)
		return;

	if(document.fa_payment.no_of_units) {
		if(document.fa_payment.no_of_units.value != '') {
			strAmountPayable = eval(strAmountPayable) * eval(document.fa_payment.no_of_units.value);
		}
	}
	document.fa_payment.amount.value=strAmountPayable;
}
/**
function UpdateAmtPayabeForce() {
	if(document.fa_payment.no_of_units) {
		if(document.fa_payment.no_of_units.value != '' && document.fa_payment.no_of_units.value != '') {
	var strAmountPayable = document.fa_payment.fine_amount.value;
	if(strAmountPayable.length == 0)
		return;

	if(document.fa_payment.no_of_units) {
		if(document.fa_payment.no_of_units.value != '') {
			strAmountPayable = eval(strAmountPayable) * eval(document.fa_payment.no_of_units.value);
		}
	}
	document.fa_payment.amount.value=strAmountPayable;
}**/
function PayBookStore(strAmt, strFeeRef) {
	document.fa_payment.amount.value = strAmt;
	document.fa_payment.fee_type[document.fa_payment.fee_type.selectedIndex].value = strFeeRef;
	document.fa_payment.book_payment_amt.value = strAmt;
	document.fa_payment.book_payment.value = '1';
	document.fa_payment.payment_for.value="1";

	//alert(document.fa_payment.fee_type[document.fa_payment.fee_type.selectedIndex].value);
	document.fa_payment.submit();
}
function MoveNext(e, objNext1) {//alert("I am here.");
	if(e.keyCode == 13) {
		var objElement = document.getElementById(objNext1);
		if(objElement)
			objElement.focus();
	}
}

function ViewCheckPmtDtls(strID, strSYFr, strSYTo, strSem)
{
	var pgLoc = "./view_check_payments.jsp?stud_id="+strID+"&sy_from="+strSYFr+"&sy_to="+strSYTo+"&semester="+strSem;
	var win=window.open(pgLoc,"PrintWindow",'width=640,height=480,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp = null; String strTemp2 = null;
	String strStudStatus = WI.fillTextValue("stud_status");


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Other school fees","otherschoolfees.jsp");
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
		strTemp = dbOP.mapUIDToUIndex(strStudID);
		//check if rfid is scanned.. 
		if(dbOP.strBarcodeID != null)
			strStudID = dbOP.strBarcodeID;
		/**
		if(strTemp != null && dbOP.strBarcodeID != null && !dbOP.strBarcodeID.equals(strTemp) ) {
			dbOP.cleanUP();
			response.sendRedirect("./otherschoolfees.jsp?stud_id="+dbOP.strBarcodeID);
			return;
		}**/
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"otherschoolfees.jsp");
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
boolean bolPayReservationFee = false;
if(WI.fillTextValue("pay_res_fee").length() > 0) 
	bolPayReservationFee = true;


Vector vStudInfo = null; String strUserIndex = null;

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
//System.out.println(request.getParameter("payment_for"));
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") ==0) {
	//I have to now check if fee selected is having same SY information as sy selected.
	strErrMsg = null;

	String strOthSchFee = WI.fillTextValue("fee_type");
	
	//If old student, I have to create entry in na_old_student if not yet created and paying for bolPayReservationFee
	if(bolPayReservationFee) {
		vStudInfo = paymentUtil.getStudBasicInfo(dbOP, strStudID);
		if(vStudInfo == null)
			strErrMsg = paymentUtil.getErrMsg();
		else {
			//only if not enrolled.. and not temp student.. 
			if(!paymentUtil.isTempStud() && CommonUtil.compareSYTerm(WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), 
								(String)vStudInfo.elementAt(8), (String)vStudInfo.elementAt(5)) != 0) {
				strUserIndex = (String)vStudInfo.elementAt(0);
				
				//check if enrolled otherwise.
				strErrMsg = "select cur_hist_index from stud_curriculum_hist where user_index = "+strUserIndex+
							" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester")+
							" and is_valid = 1";
				if(dbOP.getResultOfAQuery(strErrMsg, 0) == null) {
					strErrMsg = "select old_stud_appl_index from na_old_stud where user_index = "+strUserIndex+
								" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester")+
								" and is_valid = 1";
					if(dbOP.getResultOfAQuery(strErrMsg, 0) == null) {
						strErrMsg = "insert into na_old_stud (user_index, course_index, major_index, course_type, sY_from, sy_to, semester, year_level, "+
						"cy_from, cy_to, appl_catg, course_regularity_stat, prep_prop_status, create_date, time_of_enrollment, is_enrolled) values ("+
						strUserIndex+","+(String)vStudInfo.elementAt(6)+","+(String)vStudInfo.elementAt(7)+","+
						(String)vStudInfo.elementAt(12)+","+WI.fillTextValue("sy_from")+","+WI.fillTextValue("sy_to")+","+WI.fillTextValue("semester")+","+
						(String)vStudInfo.elementAt(4)+","+(String)vStudInfo.elementAt(10)+","+(String)vStudInfo.elementAt(11)+",'Old',0,"+
						(String)vStudInfo.elementAt(13)+",'"+WI.getTodaysDate()+"',"+WI.getTodaysDate(28)+",0)";
						dbOP.executeUpdateWithTrans(strErrMsg, null, null, false);
					}
				}
			}
		}
	}
	strErrMsg = null;
	
	
	
/** -- removed checking of other school fee belonging to same sy/term.. - April 04-2011 -
	if(strOthSchFee.length() > 0) {
		strTemp = "select sy_from from fa_oth_sch_fee "+
					"join fa_schyr on (fa_schyr.sy_index=fa_oth_sch_fee.sy_index) "+
					"where othsch_fee_index="+strOthSchFee;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	}
	if(strTemp == null || !strTemp.equals(WI.fillTextValue("sy_from")) )
		strErrMsg = "Other school fee does not blong to this SY. Please refresh the page everytime sy/term is changed.";
**/

	if(strErrMsg == null && strOthSchFee.length() > 0) {
		if(!paymentUtil.isORIssuedToTeller(dbOP, request.getParameter("or_number"), (String)request.getSession(false).getAttribute("userIndex"), strSchoolCode))
			strErrMsg = paymentUtil.getErrMsg();
		else if(faPayment.savePayment(dbOP,request,false)) {//always false for tution / fine payment
			dbOP.cleanUP();
				String strSukli = WI.fillTextValue("sukli");
				if(strSukli.length() > 0) {
					//keep change in attribute.
					double dAmtReceived = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""));
					dAmtReceived = dAmtReceived - Double.parseDouble(WI.fillTextValue("amount"));
					strSukli = "&sukli="+ CommonUtil.formatFloat(dAmtReceived,true);
				}
	
			response.sendRedirect(response.encodeRedirectURL("./otherschoolfees_print_receipt.jsp?or_number="+
			request.getParameter("or_number")+"&stud_status="+request.getParameter("stud_status")+strSukli));
			return;
		}
		else
			strErrMsg = faPayment.getErrMsg();
	}
}

Vector vBookPmtPayable = null;//for CIT only..

if(strStudStatus.compareTo("0") == 0) {//only if student id is entered.
	if(vStudInfo == null) 
		vStudInfo = paymentUtil.getStudBasicInfo(dbOP, strStudID);
	if(vStudInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
	else {
		strUserIndex = (String)vStudInfo.elementAt(0);

		if(strSchoolCode.startsWith("CIT") && !bolPayReservationFee) {
			bookstore.BookOrders BO = new bookstore.BookOrders();

			vBookPmtPayable = BO.paymentInterface(dbOP, request, strUserIndex, (String)vStudInfo.elementAt(8), (String)vStudInfo.elementAt(5));
		}
	}
}
if(strStudStatus == null || strStudStatus.trim().length() ==0)
	strErrMsg = "Please select student status type.";
else {
	if(strStudStatus.compareTo("1") == 0) {
		if(request.getParameter("payee_name") == null  	|| request.getParameter("payee_name").trim().length() ==0 ||
			request.getParameter("sy_from") == null || request.getParameter("sy_from").trim().length() ==0 ||
			request.getParameter("sy_to") == null 	|| request.getParameter("sy_to").trim().length() ==0)
		strErrMsg = "Please eneter name/school year of other fee information.";
	}
}


boolean bolIsICA = false;
String strSQLQuery = "select info5 from sys_info";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && strSQLQuery.equals("ICA"))
	bolIsICA = true;


boolean bolRemoveAlreadyPosted = false;
if(strSchoolCode.startsWith("FATIMA"))
	bolRemoveAlreadyPosted = true;
	
boolean bolShowBankPost = false;
if(strSchoolCode.startsWith("UB") || strSchoolCode.startsWith("FATIMA") || strSchoolCode.startsWith("DLSHSI"))
	bolShowBankPost = true;

boolean bolIsCCPmtAllowed = false;
if(strSchoolCode.startsWith("PWC") || strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("CSA") || 
strSchoolCode.startsWith("SWU") || request.getSession(false).getAttribute("is_cc_allowed") != null)
	bolIsCCPmtAllowed = true;

boolean bolShowRemark = false;
if(request.getSession(false).getAttribute("PMT_REMARK_ALLOWED") != null)
	bolShowRemark = true;

boolean bolIsDatePaidReadonly = comUtil.isPaymentDateReadOnly(dbOP, request);

if(strErrMsg == null) 
	strErrMsg = "";

boolean bolIsChkPmtAllowed = true;

%>
<form name="fa_payment" action="./otherschoolfees.jsp" method="post">
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
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 6);
else
	strTemp = null;
if(strTemp != null){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"class="thinborderALL" style="font-size:15px; color:#FFFF00; background-color:#7777aa"><%=strTemp%></td>
    </tr>
<%}%>
		<%if (vStudInfo != null && vStudInfo.size() > 0){
		Vector vChkPmt = null;
		enrollment.CheckPayment chkPmt = new enrollment.CheckPayment();
		vChkPmt = chkPmt.getChkPaymentDtls(dbOP, WI.fillTextValue("stud_id"),(String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(5));
		//System.out.println((String)vStudInfo.elementAt(8)+" :: "+(String)vStudInfo.elementAt(5));
		//System.out.println(chkPmt.getErrMsg());
		if (vChkPmt!= null && vChkPmt.size()>0){
		if (vChkPmt.elementAt(0)!=null){%>
		<tr> <td colspan="4">
			<table width="90%" class="thinborderALL" cellpadding="0" cellspacing="0">
			<tr>
				<td>
				<%if (((String)vChkPmt.elementAt(0)).equals("0")){
					if(strSchoolCode.startsWith("DLSHSI"))
						bolIsChkPmtAllowed = false;
				%>
				<font color="#FF0000" size="3"><strong>Having BLOCKED check
				  payment</strong></font>
				<%} else {%>
				<font size="3">Having <strong><%=(String)vChkPmt.elementAt(0)%></strong> check payment(s)</font><%}%>
	<a href='javascript:ViewCheckPmtDtls("<%=WI.fillTextValue("stud_id")%>","<%=(String)vStudInfo.elementAt(8)%>", "<%=(String)vStudInfo.elementAt(9)%>","<%=(String)vStudInfo.elementAt(5)%>");'><img src="../../../images/view.gif" border="0"></a>
				  <font size="1">View Dtls</font></td>
			</tr>
			</table>
		</td></tr>
		<%}}}%>	  
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Accounts</td>
      <td><select name="stud_status" onChange="ReloadPage();">
          <option value="0">Internal</option>
<%if(!bolPayReservationFee  || strSchoolCode.startsWith("EAC")) {
		if(strStudStatus.compareTo("1") ==0){%>
          <option value="1" selected>External</option>
        <%}else{%>
          <option value="1">External</option>
        <%}
}		%>
        </select></td>
      <td align="center">
<%if(!bolIsICA) {%>
	  	  <%//get here cutoff time information.
	  Vector vTempCO = new enrollment.FADailyCashCollectionDtls().getCurrentCutoffStat(dbOP, (String)request.getSession(false).getAttribute("userId"));//System.out.println(vTempCO);
	  //I have to get currency rate..
	  String strCurrencyInfo = new locker.Currency().getLatestCurrencyRate(dbOP);
	  if(vTempCO != null){%>
		  <table width="50%" class="thinborderALL" cellpadding="0" cellspacing="0">
		  <tr><td height="20" align="right">
		  <%
		  strTemp = "Time :: "+(String)vTempCO.elementAt(0);
		  if(vTempCO.elementAt(1) != null) {//cut off time is set.
		  	if( ((String)vTempCO.elementAt(2)).compareTo("1") == 0)
				strTemp += "<br><font color=red>Cut off :: "+(String)vTempCO.elementAt(1)+"</font>";
			else
				strTemp += "<br>Cut off :: "+(String)vTempCO.elementAt(1);
		  }
                  if(vTempCO.elementAt(2) != null)
                  	strTemp += "<br>Collection :: "+(String)vTempCO.elementAt(3);
                  %>
              <strong><%=strTemp%><%=strCurrencyInfo%></strong> </td>
          </tr>
		  </table>
	   <%}//only if cutoff time is set.
}	   %></td>
    </tr>
    <%if(strStudStatus.compareTo("1") != 0){%>
<%if(!bolPayReservationFee) {%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Payment status</td>
      <td  colspan="2"> <select name="pmt_status">
          <option value="0">Payment for Charges NOT POSTED</option>
<%
strTemp = WI.fillTextValue("pmt_status");
if(strTemp.length() == 0 && strSchoolCode.startsWith("PIT"))
	strTemp = "1";
	
//for NEU, if payment is PN FiNE, i have to make sure, it is already posted.. 
if(strSchoolCode.startsWith("NEU") && WI.fillTextValue("fee_type").length() > 0) {
	strTemp2 = "select fee_name from fa_oth_sch_Fee where othsch_fee_index = "+WI.fillTextValue("fee_type");
	strTemp2 = dbOP.getResultOfAQuery(strTemp2, 0);
	if(strTemp2.startsWith("PN Fine"))
		strTemp = "1";
	//else	
	//	strTemp = "0";
}

if(!bolRemoveAlreadyPosted) {
	if(strTemp.compareTo("1") ==0){%>
			  <option value="1" selected>Payment for Charges ALREADY POSTED</option>
			  <%}else{%>
			  <option value="1">Payment for Charges ALREADY POSTED</option>
	<%}
}%>
        </select> 
        <font size="1">Pls ask support for any clarification </font></td>
    </tr>
<%}%>
    <tr valign="top">
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%" height="25">Student ID &nbsp; </td>
      <td width="16%"> 
	  	<input name="stud_id" type="text" size="16" value="<%=strStudID%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event, '0');">	  </td>
      <td width="65%" style="font-size:11px; font-weight:bold; color:#0000FF">
	  	<!--
		<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>-->
		<label id="coa_info" style="position:absolute"></label> 
		
		<input type="checkbox" name="pay_res_fee" value="checked" <%=WI.fillTextValue("pay_res_fee")%> onClick="ReloadPage();"> 
		Select if payment is  Reservation fee for advanced SY-Term Enrollment	  </td>
    </tr>
<%if(bolPayReservationFee) {%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">School year</td>
      <td colspan="2">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>	  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox" style="font-weight:bold; font-size:15px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fa_payment","sy_from","sy_to")'>
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox" style="font-weight:bold; font-size:15px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        TERM:
        <select name="semester" style="font-weight:bold; font-size:15px;">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
<%}%>

    <%}else{%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Payee Name </td>
      <td colspan="2"><input name="payee_name" type="text" size="40" value="<%=WI.fillTextValue("payee_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event, '1');">
        <font size="1">&lt;if payee is not a current student of the school&gt;</font>
		<br>
		<label id="coa_info"></label>		</td>
    </tr>
    <!-- this is current school year the payee is paying. if payee is paying for 2 times,
	I can differentiate for school year. -->
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">School year</td>
      <td colspan="2">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>	  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fa_payment","sy_from","sy_to")'>
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        TERM:
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
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
      <td colspan="2"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>

<%
if(strErrMsg.length() == 0){ // the outer most condition.

if(vStudInfo != null && vStudInfo.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	  <!-- enter here all hidden fields for student. -->
	  <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
	  <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(4)%>">
	  <input type="hidden" name="is_tempstud" value="<%=paymentUtil.isTempStudInStr()%>">
	<%if(!bolPayReservationFee){%>
		  <input type="hidden" name="sy_from" value="<%=(String)vStudInfo.elementAt(8)%>">
		  <input type="hidden" name="sy_to" value="<%=(String)vStudInfo.elementAt(9)%>">
		  <input type="hidden" name="semester" value="<%=(String)vStudInfo.elementAt(5)%>">	  
	<%}%>
    <tr>
      <td  width="2%" height="25" class="thinborderTOP">&nbsp;</td>
      <td width="43%" class="thinborderTOP">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%> </strong></td>
      <td  colspan="4" class="thinborderTOP">Course :<strong><%=WI.getStrValue(vStudInfo.elementAt(2))%></strong></td>
    </tr>
<%if(vStudInfo.elementAt(2) != null) {%>
    <tr>
      <td height="22">&nbsp;</td>
      <td>Year :<strong><%=(String)vStudInfo.elementAt(4)%></strong> </td>
      <td  colspan="4">Major : <strong><%=WI.getStrValue(vStudInfo.elementAt(3))%></strong></td>
    </tr>
<%}%>
    <tr>
      <td height="22">&nbsp;</td>
      <td>Term : <%=(String)vStudInfo.elementAt(5)%></td>
      <td  colspan="4">&nbsp;</td>
    </tr>
<%if(vBookPmtPayable != null) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5" align="center">

	  	<table border="0" cellpadding="0" cellspacing="0" width="90%" class="thinborderALL" bgcolor="#CCCCCC">
			<%for(int i = 0; i < vBookPmtPayable.size(); i += 3) {
				strTemp = CommonUtil.formatFloat( ((Double)vBookPmtPayable.elementAt(i)).doubleValue(), true);
			%>
			<tr>
				<td width="30%">Book Store Payable : <%=strTemp%></td>
				<td width="50%">Fee Name : <%=vBookPmtPayable.elementAt(i + 1)%></td>
				<td><input type="button" name="_bs" value="Make Payment" onClick="document.fa_payment.force_sy.value='<%=(String)vStudInfo.elementAt(8)%>';PayBookStore('<%=ConversionTable.replaceString(strTemp, ",","")%>','<%=vBookPmtPayable.elementAt(i + 2)%>');"></td>
			</tr>
		    <%}%>
		</table>
	  </td>
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
      <td width="2%" height="18">&nbsp;</td>
      <td width="46%" valign="bottom">Fee type :
	  <input type="text" name="scroll_fee" size="16" style="font-size:10px; background:#CCCC33"
		  onKeyUp="AutoScrollList('fa_payment.scroll_fee','fa_payment.fee_type',true);"
		   onBlur="document.fa_payment.is_fee_rate_sel.value='1';ReloadPage()" class="textbox">
		   <font size="1">(enter fee name to scroll the list)</font>
	  </td>
      <td width="52%" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><select name="fee_type" onChange="document.fa_payment.amount.value='';document.fa_payment.is_fee_rate_sel.value='1';ChangeFeeType();" style="font-size:11px;">
	  <option value="">Select a Fee Name</option>
<%
//System.out.println(vStudInfo.elementAt(8));
//System.out.println(vStudInfo.elementAt(9));
//System.out.println(request.getParameter("fee_type"));

// if(strStudStatus.compareTo("1") ==0)
	
//if(WI.fillTextValue("sy_from").length() > 0)//removed May 2014.. because system can't accept payment for student who are not enrolled but want to pay for TOR or any other sch fee.
//	strTemp = WI.fillTextValue("sy_from");
//else
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");

 	strTemp = " from FA_OTH_SCH_FEE where is_valid=1 and ("+
		"sy_index is null or sy_index=(select sy_index from FA_SCHYR where sy_from="+strTemp+")) ";
if(bolPayReservationFee && !strSchoolCode.startsWith("SWU"))
	strTemp += " and (fee_name like 'application%' or is_during_enrollment = 1)	";
else if(!strSchoolCode.startsWith("EAC") && !strSchoolCode.startsWith("SWU")) {
	strTemp += " and fee_name not like 'application%' and is_during_enrollment = 0";
}

/**
 else
 	strTemp = " from FA_OTH_SCH_FEE where is_del=0 and is_valid=1 and (year_level=0 or year_level="+(String)vStudInfo.elementAt(4)+
 		") and sy_index=(select sy_index from FA_SCHYR where sy_from="+(String)vStudInfo.elementAt(8)+" and sy_to="+
		(String)vStudInfo.elementAt(9)+") order by FEE_NAME asc";
**/
//System.out.println(strTemp);
//I have to map the fee if passed thru' URL.
if(WI.fillTextValue("fee_type_to_process").length() > 0)  {
	strTemp2 = "select OTHSCH_FEE_INDEX "+strTemp+" and fee_name = "+WI.getInsertValueForDB(WI.fillTextValue("fee_type_to_process"), true, null);
	strTemp2 = dbOP.getResultOfAQuery(strTemp2, 0);
}
else
	strTemp2 = (String)request.getParameter("fee_type");
	
strTemp +=" order by FEE_NAME asc";


 %>
<%=dbOP.loadCombo("OTHSCH_FEE_INDEX","FEE_NAME",strTemp, strTemp2, false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Fee Rate : <strong>
        <%
strTemp = request.getParameter("fee_type");
if(strTemp == null || strTemp.trim().length() ==0 || strTemp.compareTo("0") ==0)
	strTemp = "-";
else strTemp = dbOP.mapOneToOther("FA_OTH_SCH_FEE","OTHSCH_FEE_INDEX",strTemp,"AMOUNT",null);
if(WI.fillTextValue("book_payment").equals("1"))
	strTemp = WI.fillTextValue("book_payment_amt");

//if called from other page.. make sure amt is also copied.. 
if(WI.fillTextValue("fee_type_to_process").length() > 0) 
	strTemp = WI.fillTextValue("amount");
%>
        <%//=strTemp%>
<%if((WI.fillTextValue("fee_type_to_process").length() > 0) || (WI.fillTextValue("fee_type").compareTo("0") != 0 && WI.fillTextValue("fee_type").length() >0)){%>
        <input name="fine_amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="UpdateAmtPaidForce();style.backgroundColor='white'; AllowOnlyFloat('fa_payment','fine_amount');"
	   onKeyUp="AllowOnlyFloat('fa_payment','fine_amount');UpdateAmtPaidForce();MoveNext(event, '_01')">

<!-- show for EAC only. -->
		<%if(strTemp.compareTo("0") != 0) {%>
			x <input type="text" name="no_of_units" value="<%=WI.fillTextValue("no_of_units")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="4" maxlength="4"
	  onKeyUp="AllowOnlyInteger('fa_payment','no_of_units');UpdateAmtPaidForce();MoveNext(event, '_02')" style="font-weight:bold;" id="_01"> (nos.)

		<%}%>


        <%}%>
      </strong></td>
    </tr>
<%
if(request.getParameter("fee_type") != null && request.getParameter("fee_type").compareTo("0") ==0)
{%>
    <tr>
      <td height="18">&nbsp;</td>
      <td valign="bottom">Fine imposed by&nbsp;</td>
      <td valign="bottom">Fine
        description </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">
        <input type="text" name="fine_imposedby" size="33" value="<%=WI.fillTextValue("fine_imposedby")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <td height="25"><input name="description" type="text" size="32" value="<%=WI.fillTextValue("description")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr >
      <td height="18">&nbsp; </td>
      <td height="18" valign="bottom">Fine amount </td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25"><select name="is_replacement">
          <option value="0">Amount </option>
<%
strTemp = WI.fillTextValue("is_replacement");
if(strTemp.compareTo("1") ==0){%>
          <!--<option value="1" selected>Replacement</option>-->
 <%}else{%><!--<option value="1">Replacement</option>-->
<%}%>        </select>
        <input name="fine_amount" type="text" size="16" value="<%=WI.fillTextValue("fine_amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <!--<font size="1">(incase of replacement enter qty)</font>--></td>
      <td height="25">&nbsp;</td>
    </tr>
<%}//if fee type is fine
%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center">PAYMENT DETAILS </div></td>
    </tr>
    <tr>
		<td colspan="5">
			<div id="change_div">
			<table>
		      	<td height="25">&nbsp;</td>
      			<td style="font-size:18px;">Change: </td>
      			<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
			</table>
		</div>		</td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="12%">Amount paid </td>
      <td width="29%"><input name="amount" type="text" size="12" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();MoveNext(event, '_1')" autocomplete="off" style="font-size:18px; font-weight:bold" id="_02"></td>
      <td width="10%">Check #</td>
      <td width="48%">
<%
strTemp = "";
if(request.getParameter("payment_type") == null || 	 request.getParameter("payment_type").trim().length() ==0 ||
	request.getParameter("payment_type").compareTo("0") == 0) {
	strTemp = "disabled";
}%> <input name="check_number" type="text" size="16" value="<%=WI.fillTextValue("check_number")%>" <%=strTemp%> class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>
			Amount Tendered:	  </td>
      <td>
	  		<input name="amount_tendered" type="text" size="16" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();MoveNext(event, '_2')" autocomplete="off" id="_1">	  </td>
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
      <td> <select name="payment_type" onChange="ShowHideCheckNO();" tabindex="-1">
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
          <%}
if(bolIsCCPmtAllowed){
if(strTemp.equals("6"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>					<option value="6" <%=strErrMsg%>>Credit Card</option>
<%
if(strTemp.equals("7"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
			  		<option value="7" <%=strErrMsg%>>E-Pay</option>
<%}//show credit card for AUF only.. %>
<%if(bolShowBankPost) {//do not show to tellers.
	if(strTemp.compareTo("8") ==0){%>
			  <option value="8" selected>Bank Payment</option>
	<%}else{%>
			  <option value="8">Bank Payment</option>
	<%}
}%>
        </select>      </td>
      <td>Date paid</td>
      <td><font size="1">
        <%
strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%>
        <input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="-1">
<%if(!bolIsDatePaidReadonly) {%>
        <a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;" tabindex="-1"><img src="../../../images/calendar_new.gif" border="0"></a>
<%}%>
        </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" id="credit_card_info">
			<table class="thinborder" cellpadding="0" cellspacing="0" width="100%" bgcolor="#bbbbbb">
				<tr>
					<td width="30%" class="thinborder">Card Type : </td>
					<td width="70%" class="thinborder">
					<select name="card_type_index" style="font-size:11px;">
	<%=dbOP.loadCombo("card_type_index","CARD_TYPE"," from CCARD_TYPE where IS_ACTIVE=1 order by CARD_TYPE asc", request.getParameter("card_type_index"), false)%>
					</select>				</td>
				</tr>
				<tr>
					<td class="thinborder">Issuing Bank : </td>
					<td class="thinborder">
					<select name="bank_ref" style="font-size:11px;">
	<%=dbOP.loadCombo("AUTH_BANK_INDEX","BANK_NAME_"," from CCARD_AUTHORIZED_BANK where IS_ACTIVE=1 order by BANK_NAME_ asc", request.getParameter("bank_ref"), false)%>
					</select>				</td>
				</tr>
				<tr>
					<td class="thinborder">Receipt Refrence :</td>
					<td class="thinborder">
	<input type="text" name="ccard_auth_code" value="<%=WI.fillTextValue("ccard_auth_code")%>" size="16" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;">				</td>
				</tr>
		  	</table>	  </td>
      <td>Ref number</td>
      <td><input name="or_number" type="text" size="18" value="<%=paymentUtil.generateORNumber(dbOP,(String)request.getSession(false).getAttribute("userIndex"), true)%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
<%if(strSchoolCode.startsWith("SWU") || bolShowRemark){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">Payment Note: <br>
      <textarea class="textbox" rows="3" cols="75" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" name="pmt_for_dtls"><%=WI.fillTextValue("pmt_for_dtls")%></textarea></td>
    </tr>
<%}%>
  </table>
<script language="JavaScript">
ShowHideCheckNO();
</script>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="9"><hr size="1"></td>
    </tr>
<%if(WI.fillTextValue("fee_type_to_process").length() > 0 || (iAccessLevel > 1 && WI.fillTextValue("fee_type").compareTo("0") != 0 && WI.fillTextValue("fee_type").length() >0)){%>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4" height="25"></td>
      <td colspan="3" height="25">
	  <a href="javascript:AddRecord();" id="_2">
	  <img src="../../../images/save.gif" border="0"></a>
		<font size="1">click to save payment detail</font></td>
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
  <%
  strTemp = WI.fillTextValue("payment_for");
  //if(strTemp.length() ==0)
  	strTemp = "1"; //fine is not applicable anymore..
%>

 <input type="hidden" name="addRecord" value="0">
<input type="hidden" name="payment_for" value="<%=strTemp%>">

 <input type="hidden" name="sukli">
<input type="hidden" name="is_fee_rate_sel" value="<%=WI.fillTextValue("is_fee_rate_sel")%>">
<input type="hidden" name="pmt_receive_type" value="Internal">
<input type="hidden" name="book_payment" value="">
<input type="hidden" name="book_payment_amt" value="">
<input type="hidden" name="force_sy" value="<%=WI.fillTextValue("force_sy")%>">

<input type="hidden" name="prevent_chk_pmt" value="<%if(!bolIsChkPmtAllowed){%>1<%}else{%><%}%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
