<%@ page language="java" import="utility.*,enrollment.FAAssessment,enrollment.FAPaymentUtil,enrollment.FAPayment,java.util.Vector" buffer="16kb" %>
<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

if(strSchoolCode.startsWith("DLSHSI")) //tracking is for lasalle only.. 
	request.getSession(false).setAttribute("start_time_long_or",String.valueOf(new java.util.Date().getTime()));


	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	WebInterface WI = new WebInterface(request);


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Installment fees","install_assessed_fees_payment.jsp");
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
														"install_assessed_fees_payment.jsp");
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

String strProcessingFee = "Not Set";
if(strSchoolCode.startsWith("AUF")) {
	strTemp = "select PROCESSING_FEE,MIN_PROCESSING_FEE from CCARD_SETTING";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	rs.next();
	strProcessingFee = Double.toString(rs.getDouble(1)/100)+"%";
	if(rs.getInt(2) > 0)
		strProcessingFee += " or Min of "+rs.getString(2);
 }

//boolean bolIsDatePaidReadonly = false;
//if(strSchoolCode.startsWith("UC") || strSchoolCode.startsWith("EAC") || strSchoolCode.startsWith("FATIMA"))
//	bolIsDatePaidReadonly = true;
boolean bolIsDatePaidReadonly = comUtil.isPaymentDateReadOnly(dbOP, request);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Basic Schedule Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax2.js"></script>
<script language="JavaScript">
/**
function ShowHideCheckNO()
{
	if(document.fa_payment.payment_type.selectedIndex == 1) {
		document.fa_payment.CHECK_FR_BANK_INDEX.disabled = false;
		document.fa_payment.check_number.disabled = false;
	}
	else {
		document.fa_payment.CHECK_FR_BANK_INDEX.selectedIndex = 0;
		document.fa_payment.CHECK_FR_BANK_INDEX.disabled = true;
		document.fa_payment.check_number.disabled = true;
	}
	//show or hide emp ID input fields.
	if(document.fa_payment.payment_type.selectedIndex == 2)
	{
		showLayer('_empID');
		showLayer('_empID1');
		document.fa_payment.hide_search.src = "../../../images/search.gif";
	}
	else
	{
		hideLayer('_empID');
		hideLayer('_empID1');
		document.fa_payment.cash_adv_from_emp_id.value = "";
		document.fa_payment.hide_search.src = "../../../images/blank.gif";
	}

}**/
function ShowHideCheckNO()
{
	if(!document.fa_payment.payment_type)
		return;
	var iPaymentTypeSelected = document.fa_payment.payment_type.selectedIndex;
	var strPaymentType = document.fa_payment.payment_type[document.fa_payment.payment_type.selectedIndex].text;

	if(iPaymentTypeSelected == 1 || iPaymentTypeSelected == 3 || strPaymentType == "Bank Payment") {
		document.fa_payment.CHECK_FR_BANK_INDEX.disabled = false;
		document.fa_payment.check_number.disabled = false;
	}
	else {
		document.fa_payment.CHECK_FR_BANK_INDEX.selectedIndex = 0;
		document.fa_payment.CHECK_FR_BANK_INDEX.disabled = true;
		document.fa_payment.check_number.disabled = true;
	}
	//show or hide emp ID input fields.
	if(iPaymentTypeSelected == 2)
	{
		showLayer('_empID');
		showLayer('_empID1');
		document.fa_payment.hide_search.src = "../../../images/search.gif";
	}
	else
	{
		hideLayer('_empID');
		hideLayer('_empID1');
		document.fa_payment.cash_adv_from_emp_id.value = "";
		document.fa_payment.hide_search.src = "../../../images/blank.gif";
	}
	if(iPaymentTypeSelected == 3)
		showLayer('myADTable1');
	else
		hideLayer('myADTable1');
	document.fa_payment.chk_amt.value = "";
	document.fa_payment.cash_amt.value = "";

	if(iPaymentTypeSelected > 3 &&  strPaymentType != "Bank Payment") {//credit card..
		showLayer('credit_card_info');

		var objLabel = document.getElementById("show_processingfee_note");
		if(objLabel) {
			if(iPaymentTypeSelected == 4 && document.fa_payment.payment_mode.selectedIndex == 1)
				objLabel.innerHTML = "<br>Processing fee of <%=strProcessingFee%> will be charged.";
			else
				objLabel.innerHTML = "";
		}
	}
	else
		hideLayer('credit_card_info');

}

function FullPayment() {
	document.fa_payment.amount.value = "";
	this.ReloadPage();
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
	var strPrevID = document.fa_payment.prev_id.value;
	var strNewID  = document.fa_payment.stud_id.value;

	if(strPrevID != strNewID) {
		alert("ID on Screen and Name displayed does not belong to same student. Click OK to refresh Page. You can save this transaction after page is reloaded.");
		document.fa_payment.addRecord.value="";
		document.fa_payment.submit();
		return;
	}
	//check change should not be -ve..
	if(document.getElementById("change_")) {
		var strChange = document.getElementById("change_").innerHTML;
		if(strChange.length > 0 && strChange.charAt(0) == "-") {
			alert("Amount tendered is less than Amount Paid.");
			document.fa_payment.amount_tendered.focus();
			return;
		}
	}
	document.fa_payment.addRecord.value="1";
	document.fa_payment.hide_save.src = "../../../images/blank.gif";
	<%
	if(strSchoolCode.startsWith("CPU") || strSchoolCode.startsWith("CLDH") || strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("DBTC") ||
		strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("CIT") || strSchoolCode.startsWith("FATIMA")){%>
		this.SukliComputation();
	<%}//show Sukli computation%>
	document.fa_payment.submit();
}
function ChangePmtSchName()
{
	document.fa_payment.pmt_schedule_name.value = document.fa_payment.pmt_schedule[document.fa_payment.pmt_schedule.selectedIndex].value;
}

function FocusID() {
	if(document.fa_payment.amount_shown.value == "1")
		document.fa_payment.amount.focus();
	else
		document.fa_payment.stud_id.focus();
}
//function FocusAmount() {
//	document.fa_payment.pmt_schedule.focus();
//}

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud_basic.jsp?opner_info=fa_payment.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
function OpenSearchFaculty() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=fa_payment.cash_adv_from_emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function GoToCollege() {
	location = "./install_assessed_fees_payment.jsp?stud_id="+document.fa_payment.stud_id.value;
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

//// - all about ajax..
function AjaxMapName(e, strPos) {
		if(e.keyCode == 13) {
			this.ReloadPage();
			return;
		}
	var strCompleteName;
	strCompleteName = document.fa_payment.stud_id.value;
	if(strCompleteName.length < 2)
		return;

	var objCOAInput;
	objCOAInput = document.getElementById("coa_info");

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.fa_payment.stud_id.value = strID;
	document.fa_payment.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.fa_payment.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
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
function AjaxFormatAmount() {
	var strAmtPaid     = document.fa_payment.amount.value;

	var objCOAInput = document.getElementById("format_amt");
	this.InitXmlHttpObject3(objCOAInput, 2);//I want to get value in this.retObj
	if(this.xmlHttp2 == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=153&show_=0&amt_="+strAmtPaid;
	this.processRequest2(strURL);
}
function MoveNext(e, objNext1) {//alert("I am here.");
	if(e.keyCode == 13) {
		var objElement = document.getElementById(objNext1);
		if(objElement)
			objElement.focus();
	}
}

</script>
<body bgcolor="#8C9AAA"  onLoad="FocusID();">
<%
Vector vStudInfo = new Vector();
Vector vScheduledPmt = new Vector();

FAAssessment FA = new FAAssessment();
FA.setIsBasic(true);

FAPaymentUtil pmtUtil = new FAPaymentUtil();
pmtUtil.setIsBasic(true);

FAPayment faPayment = new FAPayment();

String strUserIndex = null;

//if full payment link is clicked.
double dFullPmtPayableAmt = 0d;

if(WI.fillTextValue("addRecord").equals("1")) {
	if(!pmtUtil.isORIssuedToTeller(dbOP, request.getParameter("or_number"), (String)request.getSession(false).getAttribute("userIndex"), strSchoolCode))
		strErrMsg = pmtUtil.getErrMsg();
	else if(faPayment.savePayment(dbOP,request,false))
	{
		dbOP.cleanUP();
			String strSukli = WI.fillTextValue("sukli");
			if(strSukli.length() > 0) {
				//keep change in attribute.
				double dAmtReceived = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""));
				dAmtReceived = dAmtReceived - Double.parseDouble(WI.fillTextValue("amount"));
				strSukli = "&sukli="+ CommonUtil.formatFloat(dAmtReceived,true);
			}
		response.sendRedirect(response.encodeRedirectURL("./install_assessed_fees_print_receipt_bas.jsp?view_status=0&or_number="+
		request.getParameter("or_number")+"&pmt_schedule="+request.getParameter("pmt_schedule")+
		"&pmt_schedule_name="+request.getParameter("pmt_schedule_name")+strSukli));
		return;
	}
	else{
		strErrMsg = faPayment.getErrMsg();
//		System.out.println("strErrMsg 1: " + strErrMsg);
	}
}

vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));//System.out.println(pmtUtil.getIsBasic());System.out.println(vStudInfo);
if(!pmtUtil.getIsBasic()) {
	strErrMsg = "Student is not from Basic Education.";
	vStudInfo = null;
}
//for full pmt.
String strEnrolmentDiscDetail = null;
double dEnrollmentDiscount = 0d;
double dPayableAfterDiscount = 0d;
double dTotalAmtPaid =0d;

enrollment.FAFeeOperation fOperation  = new enrollment.FAFeeOperation();
double dRefunded = 0d;//I have to consider refunded amout at the end of payment schedule.
if(vStudInfo != null) {
	strUserIndex = (String)vStudInfo.elementAt(0);
	dRefunded = fOperation.calRefundedAmount(dbOP, -1, (String)vStudInfo.elementAt(0),
						 (String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(9),
						 (String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5), true);
}
if(vStudInfo != null && WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").equals("1"))
{
String[] astrSchYrInfo= {(String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(9),
						(String)vStudInfo.elementAt(5)};
	float fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
	float fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
	float fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
	fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
							astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	float fOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));

	float fMiscOtherFee = fOperation.getMiscOtherFee();

	enrollment.FAFeeOperationDiscountEnrollment test =
	new enrollment.FAFeeOperationDiscountEnrollment(true,WI.getTodaysDate(1));

test.setForceFullPmt();

Vector vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,
(String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
			astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),
                        astrSchYrInfo[2],fOperation.dReqSubAmt);

	if(vTemp != null && vTemp.size() > 0)
		strEnrolmentDiscDetail = (String)vTemp.elementAt(0);
	if(strEnrolmentDiscDetail != null)
		dEnrollmentDiscount = ((Float)vTemp.elementAt(1)).doubleValue();

	//I have to consider all the payment so far.
	dTotalAmtPaid =
			fOperation.calTotalAmoutPaid(dbOP, (String)vStudInfo.elementAt(0),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);

}//end of additional code for full payment discount.


double dOutStandingBal = 0d;

if(vStudInfo == null || vStudInfo.size() == 0){
	if(strErrMsg == null)
		strErrMsg = pmtUtil.getErrMsg();
//	System.out.println("strErrMsg 2: " + strErrMsg);
}
 else
{
	dOutStandingBal = fOperation.calOutStandingOfPrevYearSem(dbOP,(String)vStudInfo.elementAt(0), true, true);
	
	vScheduledPmt =FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(8),
						(String)vStudInfo.elementAt(9),(String)vStudInfo.elementAt(4),
						WI.getStrValue((String)vStudInfo.elementAt(5),"1"));

if(vScheduledPmt == null || vScheduledPmt.size() ==0){
		strErrMsg = FA.getErrMsg();//System.out.println(FA.getErrMsg());
//		System.out.println("strErrMsg 3: " + strErrMsg);
}else
		dPayableAfterDiscount = Double.parseDouble((vScheduledPmt.elementAt(0)).toString()) -
									dEnrollmentDiscount;

		dFullPmtPayableAmt = fOperation.calOutStandingCurYr(dbOP, (String)vStudInfo.elementAt(0),	(String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(9),
						(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5));
		dFullPmtPayableAmt = dFullPmtPayableAmt - dEnrollmentDiscount;

}

if(strErrMsg == null) strErrMsg = "";
String[] astrConvertToSem = {"Summer","",""};


String strPaymentForVal = (String)request.getSession(false).getAttribute("pmt_schedule2");
//I have to get the next pmt schedule.
if(vStudInfo != null && vStudInfo.size() > 0 && !strSchoolCode.startsWith("UC")) {
	if(!WI.fillTextValue("stud_id").equals(WI.fillTextValue("prev_id")) ) {
		strPaymentForVal = pmtUtil.getCurrentPmtSchedule(dbOP, (String)vStudInfo.elementAt(8), (String)vStudInfo.elementAt(5), true);
	}
}

if(strPaymentForVal == null) {// || !strPaymentForVal.equals(WI.getStrValue(WI.fillTextValue("pmt_schedule"),strPaymentForVal) )) {//only if a different value is selected, replace the session.
	strPaymentForVal = WI.fillTextValue("pmt_schedule");
	if(strPaymentForVal.length() > 0)
		request.getSession(false).setAttribute("pmt_schedule2",strPaymentForVal);
}
//if(strSchoolCode.startsWith("UC"))
//	strPaymentForVal = "";
//System.out.println("Printing: "+strPaymentForVal);

//System.out.println(vScheduledPmt);
boolean bolIsNoDP = false;

//I have to check if studnet has no DP, in that case, i have to show the downpayment link..
String strSQLQuery = null;
if(vStudInfo != null && vStudInfo.size() > 0) {
	strSQLQuery = "select payment_index from fa_stud_payment where is_stud_temp = 0 and user_index = "+(String)vStudInfo.elementAt(0) +
						" and is_valid = 1 and sy_from = "+(String)vStudInfo.elementAt(8) +" and semester = "+(String)vStudInfo.elementAt(5)+" and pmt_sch_index = 0 and payment_for = 0 and not exists (select * from FA_CANCEL_OR where OR_NUMBER = fa_stud_payment.or_number) ";
	if(dbOP.getResultOfAQuery(strSQLQuery, 0) == null)
		bolIsNoDP = true;
}
if(bolIsNoDP)
	strPaymentForVal = "";


boolean bolIsICA = false;
strSQLQuery = "select info5 from sys_info";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && strSQLQuery.equals("ICA"))
	bolIsICA = true;


boolean bolIsCCPmtAllowed = false;
if(strSchoolCode.startsWith("PWC") || strSchoolCode.startsWith("SWU") || strSchoolCode.startsWith("UB") || request.getSession(false).getAttribute("is_cc_allowed") != null)
	bolIsCCPmtAllowed = true;

boolean bolShowBankPost = false;
if(strSchoolCode.startsWith("UB") || strSchoolCode.startsWith("FATIMA") || strSchoolCode.startsWith("DLSHSI"))
	bolShowBankPost = true;

boolean bolShowRemark = false;
if(request.getSession(false).getAttribute("PMT_REMARK_ALLOWED") != null)
	bolShowRemark = true;
%>

<form name="fa_payment" action="./install_assessed_fees_payment_bas.jsp" method="post">
<input type="hidden" name="amount_shown" value="0">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="20" colspan="3" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>::::
          BASIC SCHEDULE ASSESSMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="20" colspan="3" >&nbsp;&nbsp;&nbsp; <strong><%=WI.getStrValue(strErrMsg,"<font size='3' color='#FF0000'>","</font>","")%></strong></td>
    </tr>
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 6);
else
	strTemp = null;
if(strTemp != null){%>
    <tr bgcolor="#FFFFFF">
      <td width="2%">&nbsp;</td>
      <td width="96%" class="thinborderALL" style="font-size:15px; color:#FFFF00; background-color:#7777aa"><span class="thinborderALL" style="font-size:15px; color:#FFFF00; background-color:#7777aa"><%=strTemp%></span></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
%>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20" colspan="4"> <input type="checkbox" name="IS_FULL_PMT_INSTALLMENT" value="1"
	  onClick="FullPayment();" <%=strTemp%>>
        <font color="#0000FF" size="3"><strong> TICK if full pmt &amp; should
        have full pmt discount</strong></font></td>
      <td width="36%" height="20">
<%if(!bolIsICA) {%>
	  <%//get here cutoff time information.
	  Vector vTempCO = new enrollment.FADailyCashCollectionDtls().getCurrentCutoffStat(dbOP, (String)request.getSession(false).getAttribute("userId"));//System.out.println(vTempCO);
	  //I have to get currency rate..
	  String strCurrencyInfo = new locker.Currency().getLatestCurrencyRate(dbOP);
	  if(vTempCO != null){%>
		  <table width="90%" class="thinborderALL" cellpadding="0" cellspacing="0">
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
}	   %>	  </td>
    </tr>
    <tr>
      <td width="2%" height="20">&nbsp;</td>
      <td width="11%" height="20"> Student ID </td>
      <td width="18%" height="20"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  style="font-size: 18" onKeyUp="AjaxMapName(event, '1');"></td>
      <td width="5%" height="20"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td colspan="2">
	  <a href="#">
	  <img src="../../../images/form_proceed.gif" border="0" onClick="ReloadPage()">
	  </a>
<%
if(strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("UI")){%>
	<input type="checkbox" onClick="GoToCollege();">
	<font style="font-size:9px; font-weight:bold; color:#0000FF">Go to College payment.</font>
    <%}%>      </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Date Paid </td>
      <td>
<%
strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%> <input name="date_of_payment" type="text" class="textbox" tabindex="-1"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12">
<%if(!bolIsDatePaidReadonly) {%>
        <a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;" tabindex="-1"><img src="../../../images/calendar_new.gif" border="0"></a>
<%}%>
	  </td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td colspan="4"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4" height="20"><hr size="1">
        <!-- enter here all hidden fields for student. -->
        <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
        <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(4)%>">
        <input type="hidden" name="semester" value="<%=(String)vStudInfo.elementAt(5)%>">
        <input type="hidden" name="sy_from" value="<%=(String)vStudInfo.elementAt(8)%>">
        <input type="hidden" name="sy_to" value="<%=(String)vStudInfo.elementAt(9)%>">
        <input type="hidden" name="is_tempstud" value="0"> </td>
    </tr>
    <tr>
      <td  width="2%" height="20">&nbsp;</td>
      <td width="43%" height="20">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%></strong></td>
      <td  colspan="2" height="20">&nbsp;</td>
    </tr>
    <tr>
      <td  width="2%" height="20">&nbsp;</td>
      <td width="43%" height="20">Year :<strong> <%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(4),"0")))%></strong></td>
      <td height="20">School Year :<strong> <%=(String)vStudInfo.elementAt(8)+" - "+(String)vStudInfo.elementAt(9) /*+
	  WI.getStrValue(astrConvertToSem[Integer.parseInt((String)vStudInfo.elementAt(5))],"(",")","")*/%></strong></td>
      <td width="22%" colspan="-1">&nbsp;</td>
    </tr>
  </table>
<%
if(vScheduledPmt != null && vScheduledPmt.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="20" colspan="9" bgcolor="#DDEEE1"><div align="center"><strong>STUDENT
          ACCOUNT SCHEDULE</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="22%" height="20">&nbsp;</td>
      <td width="29%"><font size="1">OUTSTANDING BALANCE</font></td>
      <td width="49%"><font size="1">Php <%=CommonUtil.formatFloat((vScheduledPmt.elementAt(1)).toString(),true)%> </font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td><font size="1">TOTAL PAYABLE TUITION FEE</font></td>
      <td><font size="1">Php
        <%//=CommonUtil.formatFloat((vScheduledPmt.elementAt(0)).toString(),true)%>
		<%if(WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").length() > 0) {%>
        	<%=CommonUtil.formatFloat(dFullPmtPayableAmt,true)%> (Total Payable)
		<%}else{%>
        	<%=CommonUtil.formatFloat(dPayableAfterDiscount,true)%>(tuition fee - adjustment)
		<%}%></font>
    </tr>
    <%
if(strEnrolmentDiscDetail != null) {%>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="2"><%=strEnrolmentDiscDetail%></td>
    </tr>
    <%}%>
    <tr>
      <td height="20">&nbsp;</td>
      <td><font size="1">AMOUNT PAID UPON ENROLLMENT</font></td>
      <td><font size="1"> Php <%=CommonUtil.formatFloat((vScheduledPmt.elementAt(2)).toString(),true)%></font></td>
   	</tr>
   <%
	if(dRefunded > 0.2d || dRefunded < -0.2d){%>
	 <tr>
      <td height="20">&nbsp;</td>
      <td><font size="1" color="#0033FF"><b>AMOUNT ADJUSTED </b></font></td>
      <td><font size="1" color="#0033FF"> <b>Php <%=CommonUtil.formatFloat(dRefunded,true)%></b></font></td>
    </tr>
   <%}%>
  </table>
<%
if(WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") != 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="20" colspan="7"><hr size="1"></td>
    </tr>
    <tr>
      <td height="20" width="2%">&nbsp;</td>
      <td width="20%" align="center" style="font-size:9px; font-weight:bold">Payment Schedule </td>
      <td width="10%" align="center" style="font-size:9px; font-weight:bold">Installment Amt</td>
      <td width="10%" align="center" style="font-size:9px; font-weight:bold">Last Due Date</td>
      <td width="20%" align="right" style="font-size:9px; font-weight:bold">Amount Due</td>
      <td width="20%" align="right" style="font-size:9px; font-weight:bold">Amount Paid</td>
      <td width="18%" align="right" style="font-size:9px; font-weight:bold">Balance</td>
    </tr>
    <%
int iEnrlSetting      = FA.getEnrollemntInstallmentSetting();//1= (total due-first payment)/iInstalCount, 0=total due/iInstallCount - first installment.
double dAmoutPaidDurEnrollment = ((Float)vScheduledPmt.elementAt(2)).doubleValue();
double dInstallAmount = ((Float)vScheduledPmt.elementAt(3)).doubleValue();
double dCumAmountPaid = 0d; // total amount paid
if(iEnrlSetting ==0)
	dCumAmountPaid= dAmoutPaidDurEnrollment;
double dAmountDue = 0d; //installment amount + amount due in previous payment.
int iNoOfInstallments = ((Integer)vScheduledPmt.elementAt(4)).intValue();

  //////////// Posting pmt schedule.
   Vector vInstallPmtSchedule =
        FA.getOtherChargePayable(dbOP, (String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(9),
			(String)vStudInfo.elementAt(5), (String)vStudInfo.elementAt(0) );
	if(vInstallPmtSchedule != null)
		vInstallPmtSchedule.removeElementAt(0);
    double dInstallmentPayable = 0d;double dCumInstallmentPayable = 0d;
    //this determines how the posting fees paid.

//System.out.println("vScheduledPmt : "+vScheduledPmt);
//System.out.println("vInstallPmtSchedule : "+vInstallPmtSchedule);
//System.out.println(" dCumAmountPaid: "+fCumAmountPaid);
for(int i=0,j=5; i<iNoOfInstallments ;++i)
{
	if(j ==5)
	{
		if(iEnrlSetting ==0)
			dAmountDue = dInstallAmount - dAmoutPaidDurEnrollment;
		else if(iEnrlSetting == 1)
			dAmountDue = dInstallAmount;
		else if(iEnrlSetting == 2) {//UI
			dAmountDue = ((Double)vScheduledPmt.elementAt(vScheduledPmt.size() - 1)).doubleValue();

			//reservation fee is removed from total tuition.. (adjusted to total Tuition)
		  //if(strSchoolCode.startsWith("DBTC")) {//strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("CGH")
		//	double dReservationFee = pmtUtil.getReservationFeeCGH(dbOP, (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(9),
		//				(String)vStudInfo.elementAt(5),false);
		//	dAmountDue += dReservationFee;
		 // }

		}
	}
	else
		dAmountDue += dInstallAmount - ((Float)vScheduledPmt.elementAt(j+2 - 3)).doubleValue();
	if(vScheduledPmt.size() > (j + 2))
		dCumAmountPaid+= ((Float)vScheduledPmt.elementAt(j+2)).doubleValue();



       //////////////// installment payment - start /////////
	   dInstallmentPayable = 0d;
        if(vInstallPmtSchedule != null) {
          for(;vInstallPmtSchedule.size() > 0;) {
            //if matching, get value and break. else continue;
            if( ((String)vInstallPmtSchedule.elementAt(1)).compareTo((String)vScheduledPmt.elementAt(j)) == 0) {
              dInstallmentPayable = Double.parseDouble((String)vInstallPmtSchedule.elementAt(2));
              vInstallPmtSchedule.removeElementAt(0);
              vInstallPmtSchedule.removeElementAt(0);
              vInstallPmtSchedule.removeElementAt(0);
              break;
            }
            ///keep adding to payable.
            dInstallmentPayable = Double.parseDouble((String)vInstallPmtSchedule.elementAt(2));
            vInstallPmtSchedule.removeElementAt(0);
            vInstallPmtSchedule.removeElementAt(0);
            vInstallPmtSchedule.removeElementAt(0);
          }
        }
		dCumInstallmentPayable += dInstallmentPayable;
		dAmountDue += dInstallmentPayable;
        //////////////// installment payment - end /////////
		if(i + 1 == iNoOfInstallments) {
			dAmountDue = dOutStandingBal;
			//System.out.println("dOutStandingBal : "+dOutStandingBal);
		}

%>
    <tr>
      <td height="20">&nbsp;</td>
      <td><%=vScheduledPmt.elementAt(j)%></td>
      <td align="center"> <%
	  if(j ==5 && iEnrlSetting == 0){%> <%=CommonUtil.formatFloat(dInstallAmount - dAmoutPaidDurEnrollment + dInstallmentPayable,true)%>
	  <%}else{%> <%=CommonUtil.formatFloat(dInstallAmount + dInstallmentPayable,true)%> <%}%> </td>
      <td align="center"> <%
	  if(vScheduledPmt.size() > (j + 1)){%> <%=(String)vScheduledPmt.elementAt(j+1)%> <%}%> </td>
      <td align="right"><%=CommonUtil.formatFloat(dAmountDue,true)%>&nbsp;&nbsp;</td>
      <td align="right"> <%
	  if(vScheduledPmt.size() > (j + 2)){%> <%=CommonUtil.formatFloat(vScheduledPmt.elementAt(j+2).toString(),true)%> <%}%> &nbsp;&nbsp;</td>
      <td align="right">
	  <%if(i + 1 == iNoOfInstallments) {%>
		  <%=CommonUtil.formatFloat(dAmountDue, true)%>
	  <%}else if(iEnrlSetting == 2 && vScheduledPmt.size() > (j + 2)){%> <%=CommonUtil.formatFloat(dAmountDue - ((Float)vScheduledPmt.elementAt(j+2)).doubleValue(),true)%>
	<%}else{%> <%=CommonUtil.formatFloat(dInstallAmount*(i+1) + dCumInstallmentPayable - dCumAmountPaid,true)%> <%}%> &nbsp;&nbsp;</td>
    </tr>
    <%
j = j+3;
}

if(dRefunded > 0.2d || dRefunded < -0.2d){%>
 <tr>
      <td height="20">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="right"><font size="1" color="#0033FF"><b>AMOUNT ADJUSTED </b></font> &nbsp;&nbsp;</td>
      <td align="right"><font size="1" color="#0033FF"><b><%=CommonUtil.formatFloat(dRefunded,true)%></b></font> &nbsp;&nbsp;</td>
    </tr>
<%}//show refund if there is any.%>
  </table>
<%}
//only if IS_FULL_PMT_INSTALLMENT is not checked.. condition -> WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") != 0
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#DDEEE1">
      <td height="20" width="2%"><div align="center"></div></td>
      <td width="18%">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="19%"><strong>PAYMENT DETAILS </strong></td>
      <td width="33%">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Payment for exam</td>
      <td> <select name="pmt_schedule" onChange="ChangePmtSchName();">
<%if(strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("FATIMA") ||
strSchoolCode.startsWith("UC") || strSchoolCode.startsWith("PWC") || bolIsNoDP){%>
		<!--<option value="0">DownPayment</option>-->
<%}
//i have to check if i should use the fa_pmt_schedule_extn or fa_pmt_schedule table.
if(bolIsNoDP)
	strPaymentForVal = "";
	
strTemp = dbOP.loadCombo("fa_pmt_schedule_extn.PMT_SCH_INDEX","EXAM_NAME",
		" from fa_pmt_schedule_extn  join fa_pmt_schedule on (fa_pmt_schedule_extn.pmt_sch_index = fa_pmt_schedule.pmt_sch_index)"+
		" where fa_pmt_schedule_extn.is_del=0 and fa_pmt_schedule_extn.is_valid=2 and sy_from="+(String)vStudInfo.elementAt(8)+
		" and sy_to="+(String)vStudInfo.elementAt(9)+" and semester="+(String)vStudInfo.elementAt(5)+
		 " order by fa_pmt_schedule_extn.EXAM_PERIOD_ORDER asc", strPaymentForVal, false);
//System.out.println("Printing : "+(String)vStudInfo.elementAt(8)+","+(String)vStudInfo.elementAt(9)+","+(String)vStudInfo.elementAt(5));
/**
if(strTemp.length() == 0)
	strTemp = dbOP.loadCombo("FA_PMT_SCH_EXTN_COURSE.PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCH_EXTN_COURSE  join fa_pmt_schedule on (FA_PMT_SCH_EXTN_COURSE.pmt_sch_index = fa_pmt_schedule.pmt_sch_index)"+
		" where FA_PMT_SCH_EXTN_COURSE.is_del=0 and FA_PMT_SCH_EXTN_COURSE.is_valid=1 and (semester is null or semester="+
		(String)vStudInfo.elementAt(5)+ ") and course_index = "+(String)vStudInfo.elementAt(6)+
		" order by FA_PMT_SCH_EXTN_COURSE.EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false);
**/
//strTemp = "";
if(strTemp.length() ==0)
	strTemp = dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=2 order by EXAM_PERIOD_ORDER asc",strPaymentForVal, false);
%>
          <%=strTemp%> 
<%
if(bolIsNoDP)
	strTemp = " selected";
else	
	strTemp = "";

if(strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("FATIMA") || 
strSchoolCode.startsWith("UC") || strSchoolCode.startsWith("VMA") || strSchoolCode.startsWith("PWC") || bolIsNoDP){%>
		<option value="0"<%=strTemp%>>DownPayment</option>
<%}%>
		  </select></td>
      <td>&nbsp;</td>
      <td></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td style="font-size:18px; font-weight:bold">Amount paid </td>
      <td colspan="3"> 
	  <%
/**
if(WI.fillTextValue("amount").length() == 0 &&
	WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") ==0) {
	strTemp = CommonUtil.formatFloat(dPayableAfterDiscount - dTotalAmtPaid,true);
	strTemp = ConversionTable.replaceString(strTemp,",","");
}
else
	strTemp = WI.fillTextValue("amount");
**/
%> 

<%
if(WI.fillTextValue("amount").length() == 0 &&
	WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") ==0) {
	strTemp = CommonUtil.formatFloat(dFullPmtPayableAmt,true);
	strTemp = ConversionTable.replaceString(strTemp,",","");
}
else
	strTemp = WI.fillTextValue("amount");
%>

<input name="amount" type="text" size="18" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" autocomplete="off"
	  onBlur="style.backgroundColor='white';AllowOnlyFloat('fa_payment','amount');computeCashChkAmt();"
	  onKeyUp="AllowOnlyFloat('fa_payment','amount');computeCashChkAmt();AjaxUpdateChange();AjaxFormatAmount();MoveNext(event, '_1')"  class="textbox_bigfont">
        <font size="4">Php</font>
		&nbsp;&nbsp;&nbsp;
		<label id="format_amt" style="font-size:18px; font-weight:bold; color:#00CCFF"></label>

<script language="javascript">
<!--
	document.fa_payment.amount_shown.value = "1";
-->
</script>	  </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Amount Tendered </td>
      <td>
	  		<input name="amount_tendered" type="text" size="16" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();MoveNext(event, '_2')" autocomplete="off" id="_1">	  </td>
      <td colspan="2">
		<div id="change_div">
			<table cellpadding="0" cellspacing="0">
      			<td style="font-size:18px;">Change: &nbsp;</td>
      			<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
			</table>
		</div>	  </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td valign="top">Payment type</td>
      <td valign="top"><font size="1">
        <select name="payment_type" onChange="ShowHideCheckNO();" tabindex="-1">
          <option value="0">Cash</option>
          <%
strTemp = WI.fillTextValue("payment_type");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Check</option>
          <%}else{%>
          <option value="1">Check</option>
          <%}
		  if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Salary deduction</option>
          <%}else{%>
          <option value="2">Salary deduction</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>Cash and check</option>
          <%}else{%>
          <option value="5">Cash and check</option>
          <%}
		   			  if(strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("CSA") || bolIsCCPmtAllowed){
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
<%if(bolShowBankPost) {
	if(strTemp.compareTo("8") ==0){%>
			  <option value="8" selected>Bank Payment</option>
	<%}else{%>
			  <option value="8">Bank Payment</option>
	<%}

}%>		  
    </select>
        <br>
        <input name="text" type="text" class="textbox_noborder" id="_empID" value="Emp ID:" size="6" readonly="yes" tabindex="-1">
        <input type="text" name="cash_adv_from_emp_id" tabindex="-1"
		value="<%=WI.fillTextValue("cash_adv_from_emp_id")%>" size="12" id="_empID1" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearchFaculty();" tabindex="-1"><img src="../../../images/search.gif" width="25" height="23" border="0" id="hide_search"></a>
      </font></td>
      <td>Ref number</td>
      <td><font size="1"><b>
        <!--       <%
	   	//strTemp = paymentUtil.generateORNumber(dbOP);
	   //	if(strTemp == null)
	   //		strTemp = paymentUtil.getErrMsg();
		//else{%>
        <input type="hidden" name="or_number" value="<%//=strTemp%>">
        <%//}%>
        <%//=strTemp%> -->
        <input name="or_number" type="text" size="18" value="<%=pmtUtil.generateORNumber(dbOP,(String)request.getSession(false).getAttribute("userId"))%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   tabindex="-1">
        </b></font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Check #</td>
      <td colspan="3"> <%
strTemp = "";
if(request.getParameter("payment_type") == null || 	 request.getParameter("payment_type").trim().length() ==0 ||
	request.getParameter("payment_type").compareTo("0") == 0)
{
	strTemp = "disabled";
}%> <input name="check_number" type="text" size="16" value="<%=WI.fillTextValue("check_number")%>" <%=strTemp%> class="textbox" tabindex="-1"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;&nbsp;&nbsp;
		<select name="CHECK_FR_BANK_INDEX" style="font-size:10px" tabindex="-1" >
          <option value=""></option>
		  <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH",
		" from FA_BANK_LIST where is_valid = 1 order by bank_code", request.getParameter("CHECK_FR_BANK_INDEX"), false)%>
        </select>      </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3" id="myADTable1">Check amount:
        <input name="chk_amt" type="text" size="12" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('fa_payment','amount');computeCashChkAmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('fa_payment','chk_amt');computeCashChkAmt();" tabindex="-1">
        , cash amount:
        <input name="cash_amt" type="text" size="12" class="textbox_noborder" readonly="yes" tabindex="-1"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3" id="credit_card_info">
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
		  	<tr>
				<td colspan="2" class="thinborder" style="font-weight:bold">NOTE : No Full Payment discount.
				 <label id="show_processingfee_note"></label>				</td>
		  </tr>
	    </table>	  </td>
    </tr>
<%if(bolShowRemark){%>
    <tr>
      <td>&nbsp;</td>
      <td colspan="4">
	  Payment Note: <br>
      <textarea class="textbox" rows="3" cols="75" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" name="pmt_for_dtls"><%=WI.fillTextValue("pmt_for_dtls")%></textarea>
	  </td>
    </tr>
<%}%>
  </table>
<script language="JavaScript">
ShowHideCheckNO();
//FocusAmount();
</script>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="20" colspan="9"><hr size="1"></td>
    </tr>
<%if(iAccessLevel > 1){%>
    <tr >
      <td width="2%" height="20">&nbsp;</td>
      <td colspan="4" height="20">&nbsp;</td>
      <td colspan="3" height="20"><a href="javascript:AddRecord();" id="_2">
	  		<img name="hide_save" src="../../../images/save.gif" border="0"></a>
        <font size="1">click to save entries&nbsp; </font></td>
      <td width="10%" height="20">&nbsp;</td>
    </tr>
<%		}//only if iAccessLevel > 1
	}//only if vScheduledPmt != null;
}//only if stud info is not null;
%>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1">
      <td height="20" colspan="8" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="payment_for" value="0">
 <input type="hidden" name="addRecord" value="0">
 <input type="hidden" name="pmt_schedule_name" value="<%=WI.fillTextValue("pmt_schedule_name")%>">

  <input type="hidden" name="sukli">
 <input type="hidden" name="prev_id" value="<%=WI.fillTextValue("stud_id")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
