<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,java.util.Vector" buffer="20kb" %>
<%
	DBOperation dbOP   = null;
	String strErrMsg   = null;
	String strTemp     = null;
	String strSQLQuery = null;
	java.sql.ResultSet rs = null;
	
	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};

	WebInterface WI = new WebInterface(request);
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-assessedfees(enrollment)","assessedfees.jsp");
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
	//must do here to get the ID.. 
	if(WI.fillTextValue("stud_id").length() > 0) {
		strTemp = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
		if(strTemp != null && dbOP.strBarcodeID != null && !dbOP.strBarcodeID.equals(strTemp) ) {
			dbOP.cleanUP();
			response.sendRedirect("./assessedfees.jsp?stud_id="+dbOP.strBarcodeID);
			return;
		}
	}
	
	
	
	
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"assessedfees.jsp");
//if(WI.fillTextValue("view_status").length() > 0)
//	iAccessLevel = 2;

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

	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";
	
	String strInfo5 = WI.getStrValue((String)request.getSession(false).getAttribute("info5"));
	//for Jonelta, i have to compute required d/p based on %ge information of plan.

if(strSchoolCode.startsWith("DLSHSI")) //tracking is for lasalle only.. 
	request.getSession(false).setAttribute("start_time_long_or",String.valueOf(new java.util.Date().getTime()));

String strProcessingFee = "Not Set";

if(strSchoolCode.startsWith("AUF")) {
	strTemp = "select PROCESSING_FEE,MIN_PROCESSING_FEE from CCARD_SETTING";
	rs = dbOP.executeQuery(strTemp);
	rs.next();
	strProcessingFee = Double.toString(rs.getDouble(1)/100)+"%";
	if(rs.getInt(2) > 0)
		strProcessingFee += " or Min of "+rs.getString(2);
 }
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD.payment_details{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;
}
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


  /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:7;
	top:0;
    width:385px;
	height:200;/** it expands on its own.. **/
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }
  div.showPayment{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    left:7;
	top:0;
    width:400px;
	height:200;/** it expands on its own.. **/
	overflow:auto;
	visibility:hidden
  }

</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax2.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function UpdateNationality(strStudID, strStudIndex, strIsTempStud) {
	var pgLoc = "./update_stud_nationality.jsp?stud_id="+strStudID+"&stud_index="+strStudIndex+"&is_temp_stud="+strIsTempStud;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=300,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}

/** --> not in use, i have to popup a winodow to maintain naitonality.
function UpdateNationality()
{
//call this to change the nationality status.
	document.fa_payment.updateNationality.value = "1";
	document.fa_payment.submit();
}
*/
/**
*	If this page is called for view or print the assessment directly, then do not submit.
*/
function ReturnValidate()
{
	if(document.fa_payment.view_status.value.length > 0)
	{
		this.PrintViewPayment(document.fa_payment.view_status.value);
		return false;
	}
	return true;
}
function ShowHideApprovalNo()
{
/*	if(document.fa_payment.payment_mode.selectedIndex == 2)
		document.fa_payment.approval_number.disabled = false;
	else
		document.fa_payment.approval_number.disabled = true;
*/	document.fa_payment.amount.value = "";

	ReloadPage();
}
var strFullPaymentDiscountInfo = "";
/**
function ShowHideCheckNO() {
	if(!document.fa_payment.payment_type)
		return;
	var iPaymentTypeSelected = document.fa_payment.payment_type.selectedIndex;
	if(iPaymentTypeSelected == 1 || iPaymentTypeSelected == 2) {
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

	//show or hide emp ID input fields.

<% if (!strSchoolCode.startsWith("CPU")) {%>
	if(iPaymentTypeSelected == 3)
	{
		showLayer('_empID');
		showLayer('_empID1');
	}
	else
	{
		hideLayer('_empID');
		hideLayer('_empID1');
		document.fa_payment.cash_adv_from_emp_id.value = "";
	}
<%}%>

//	var objFullPmtDiscount = document.getElementById("full_pmt_discount");
//	if(objFullPmtDiscount && strFullPaymentDiscountInfo.length == 0)
//		strFullPaymentDiscountInfo  = objFullPmtDiscount.innerHTML;

	if(iPaymentTypeSelected > 3) {//credit card..
		showLayer('credit_card_info');

		var objLabel = document.getElementById("show_processingfee_note");
		if(objLabel) {
			if(iPaymentTypeSelected == 4 && document.fa_payment.payment_mode.selectedIndex == 1)
				objLabel.innerHTML = "<br>Processing fee of <%=strProcessingFee%> will be charged.";
			else
				objLabel.innerHTML = "";
		}
		//if(strFullPaymentDiscountInfo.length > 0) {
//			objFullPmtDiscount.innerHTML = "<font style='text-decoration:line-through;'>"+strFullPaymentDiscountInfo+"</font>";
		//}
	}
	else {
		//if(strFullPaymentDiscountInfo.length > 0)
		//	objFullPmtDiscount.innerHTML = strFullPaymentDiscountInfo;
		hideLayer('credit_card_info');
	}
}**/
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
		//document.fa_payment.hide_search.src = "../../../images/search.gif";
	}
	else
	{
		hideLayer('_empID');
		hideLayer('_empID1');
		document.fa_payment.cash_adv_from_emp_id.value = "";
		//document.fa_payment.hide_search.src = "../../../images/blank.gif";
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
	if(strSchoolCode.startsWith("CPU") || strSchoolCode.startsWith("CLDH") || strSchoolCode.startsWith("WNU") ||
		strSchoolCode.startsWith("DBTC") || strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("FATIMA")){%>
		this.SukliComputation();
	<%}//show Sukli computation%>
	document.fa_payment.submit();
}
function PrintViewPayment(strViewStatus)
{
	var strStudID = document.fa_payment.stud_id.value;
	if(strStudID.length ==0)
		alert("Enter student ID");
	else
	{
		<%//request.getSession(false).setAttribute("school_code","LNU");
		if(request.getSession(false).getAttribute("school_code") != null &&	((String)request.getSession(false).getAttribute("school_code")).startsWith("LNU")){%>//for LNU only.
			location = "./enrollment_receipt_print_lnu.jsp?stud_id="+escape(strStudID)+"&view_status="+strViewStatus;
		<%}else if (strSchoolCode != null && strSchoolCode.startsWith("CPU")){%>
			location = "./assessedfees_print_cpu.jsp?stud_id="+escape(strStudID)+"&view_status="+strViewStatus;
		<%}else{%>
			location = "./assessedfees_print.jsp?stud_id="+escape(strStudID)+"&view_status="+strViewStatus;
		 <%}%>
	}
}
function FocusID() {
	if(document.fa_payment.focus_id.value == '2')
		document.fa_payment.amount.focus();
	else
		document.fa_payment.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud_enrolled.jsp?opner_info=fa_payment.stud_id";
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
		return;
	}

	document.fa_payment.sukli.value = vAmtReceived;

<% if (strSchoolCode.startsWith("CPU")) {%>
	if (Number(vAmtReceived) - Number(vAmtPaid) > 0){
		alert (" CHANGE : " + (Number(vAmtReceived) - Number(vAmtPaid)));
	}
<%}%>
}
function ApplyLateFine() {
	if(!document.fa_payment.late_fine.checked) {
		document.fa_payment.late_fine_amt.value = "";
		document.fa_payment.late_fine_amt.readonly = true;
	}
	else {
		document.fa_payment.late_fine_amt.readonly = false;
		document.fa_payment.late_fine_amt.value = "200";
	}
}

function ViewCheckPmtDtls(strID, strSYFr, strSYTo, strSem)
{
	var pgLoc = "./view_check_payments.jsp?stud_id="+strID+"&sy_from="+strSYFr+"&sy_to="+strSYTo+"&semester="+strSem;
	var win=window.open(pgLoc,"PrintWindow",'width=640,height=480,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//used for PIT only..
function UpdateMiscFeePmt(obj, strAmount) {
	var strInput = document.fa_payment.amount.value;
	if(strInput == '')
		strInput = 0;
	if(obj.checked)
		strInput = eval(strInput) + eval(strAmount);
	else
		strInput = eval(strInput) - eval(strAmount);
	strInput = this.roundOffFloat(strInput, 2, true);
	document.fa_payment.amount.value = strInput;
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
	<%if(strSchoolCode.startsWith("CSA")) {%>
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
	<%}%>
}
**/

function UpdateAmtPaid() {
	var strAmountPayable = document.fa_payment.fine_amount.value;
	if(strAmountPayable.length == 0)
		return;
	if(document.fa_payment.amount.value.length == 0)
		document.fa_payment.amount.value=strAmountPayable;
}

function AjaxMapName(e, strRef) {
		if(e.keyCode == 13) {
			this.ReloadPage();
			return;
		}
	var strSearchCon = "&search_temp=2";

	calledRef = strRef;
	var strCompleteName;

	strCompleteName = document.fa_payment.stud_id.value;
	if(strCompleteName.length < 3) {
		document.getElementById("coa_info").innerHTML = "";
		return;
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
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
		//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	document.fa_payment.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	this.ReloadPage();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

//take me to d/p link.
function GoToDP() {
	<%if(strSchoolCode.startsWith("CSA")){%>
		location = "./tuition_nontuition_payment.jsp?stud_id="+document.fa_payment.stud_id.value;
	<%}else{%>
		location = "./install_assessed_fees_payment.jsp?stud_id="+document.fa_payment.stud_id.value;
	<%}%>
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

function HideLayer(strDiv) {
	if(strDiv == '1')
		document.all.processing.style.visibility='hidden';	
	else if(strDiv == '2')
		document.all.showPayment.style.visibility='hidden';	
	
}
function ApplyAutoDiscount(iChkBox) {
	<%if(!strSchoolCode.startsWith("NEU")) {%>
		return;
	<%}%>
	//do not process if not full payment.. 
	if(document.fa_payment.payment_mode.selectedIndex != 1) 
		return;
		
	var iCount = document.fa_payment.auto_discount_count.value;
	var dPayableAmt = document.fa_payment.amount.value;
	var dTemp = 0;
	var obj;
	if(iChkBox != '') {
		eval('obj=document.fa_payment.auto_discount_'+iChkBox);
		eval('dTemp=document.fa_payment.auto_discount_amt_'+iChkBox+'.value');
		
		if(obj.checked)
			dPayableAmt = eval(dPayableAmt) - eval(dTemp);
		else
			dPayableAmt = eval(dPayableAmt) + eval(dTemp);
		
		if(dPayableAmt <0) {
			dPayableAmt = 0;
		}
	}
	else {//process whole -- this is called onload function.
		for(i = 0; i < iCount; ++i) {
			eval('obj=document.fa_payment.auto_discount_'+i);
			if(!obj.checked)
				continue;
			
			eval('obj=document.fa_payment.auto_discount_amt_'+i);
			dTemp = obj.value;		
			dPayableAmt = eval(dPayableAmt) - eval(dTemp);
			
			if(dPayableAmt <0) {
				dPayableAmt = 0;
				break;
			}
		}
	}
	document.fa_payment.amount.value = dPayableAmt;
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();ShowHideCheckNO();ApplyAutoDiscount('')">
<%
astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)//db error
{
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=dbOP.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}
Vector vStudInfo = null;
Vector vMiscFeeInfo = null, vMiscFeeIndex = null; int iMiscFeeIndex = 0;
Vector vTemp = null;

boolean bolIsPIT = strSchoolCode.startsWith("PIT");
boolean bolIsCSA = strSchoolCode.startsWith("CSAB");
boolean bolIsJonelta = strInfo5.equals("jonelta");
//bolIsJonelta = true;

Vector vMandatoryFee = new Vector(); double dMandatoryFee = 0d;
//for csa only few are mandatory fee.
if(bolIsCSA) {
	//vMandatoryFee.addElement("sg fee");vMandatoryFee.addElement("eagle fee");vMandatoryFee.addElement("developmental fee");
	//vMandatoryFee.addElement("pta");vMandatoryFee.addElement("retreat fee");
	vMandatoryFee.addElement("Dept. Fee".toLowerCase());vMandatoryFee.addElement("Eagle".toLowerCase());vMandatoryFee.addElement("PTA".toLowerCase());
	vMandatoryFee.addElement("SG".toLowerCase());vMandatoryFee.addElement("Recollection".toLowerCase());vMandatoryFee.addElement("Technoscope".toLowerCase());
	vMandatoryFee.addElement("retreat".toLowerCase());
}

boolean bolIsFullPmt = false;


double dTotalDiscount   = 0d;// scholarship/discounts applied.. mostly used for SPC.. but can be used for others.. 
Vector vDiscountApplied = new Vector();


float fTutionFee    = 0f;
float fCompLabFee   = 0f;
float fMiscFee      = 0f;
float fOutstanding  = 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,
double dTotalPayable = 0d;

float fEnrollmentDiscount = 0f; //this sum of full payment, early enrollment or late enrollment discount/fine implementations.
String strEnrolmentDiscDetail = null;
float fPayableAfterDiscount = 0f;

double dReservationFee = 0d;//only for CGH.
double dRequiredDownCPU = 0d;
double dScholarShipGrants = 0d;

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
Advising advising = new Advising();
enrollment.FAAssessment FA = new enrollment.FAAssessment();

//set total assessment later in this page.. 
enrollment.FAStudMinReqDP faMinDP = new enrollment.FAStudMinReqDP(null);


int iNoInstallment = 1;
boolean bolIsCPU = false;

		//true = must pay required d/p.
		boolean bolEnforceDP = false;
		strTemp = (String)request.getAttribute("force_dp_neu"); //--- this is set dring full payment discount.. 
		if(strTemp != null && WI.fillTextValue("stud_id").equals(strTemp)) //must pay required d/p 
			bolEnforceDP = true;
		else
			bolEnforceDP = CommonUtil.bolEnforceDP(dbOP);
		//apply must pay minimum required d/p for vmuf..
		double dReqdDP = 0d;
		String strReqDPMsg = null;
		//boolean bolIsVMUF = true;//strSchoolCode.startsWith("VMUF");

if (strSchoolCode != null && strSchoolCode.startsWith("CPU")) {
	bolIsCPU = true;
}

	boolean bolIsForeignStud = false;
	boolean bolIsTempStud    = false;
	if(WI.fillTextValue("is_tempstud").compareTo("1") == 0)//temp stud.
		bolIsTempStud = true;
	if(WI.fillTextValue("is_alien").compareTo("0") ==0)//change status to alien
		bolIsForeignStud  = true;
if(WI.fillTextValue("updateNationality").compareTo("1") ==0){
	//I have to change the nationality status.
	enrollment.StudentInformation studInfo = new enrollment.StudentInformation();
	if(!studInfo.changeForeignStat(dbOP, WI.fillTextValue("stud_index"),bolIsTempStud,bolIsForeignStud,null))//only called to change status to 0
		strErrMsg = studInfo.getErrMsg();

}

strTemp = request.getParameter("addRecord");
String strStudIndex = null;
if(strTemp != null && strTemp.compareTo("1") ==0) {//dbOP.forceAutoCommitToFalse();
	//for vmuf, i must make sure student pays required d/p..
	if(bolEnforceDP && WI.fillTextValue("reqd_dp").length() > 0) {
		strTemp = WI.fillTextValue("amount");
		double dT1 = Double.parseDouble(WI.getStrValue(WI.fillTextValue("amount"),"0"));
		if(Double.parseDouble(WI.fillTextValue("reqd_dp")) > dT1)
			strErrMsg = "Can't allow payment less than required downpayment.";
	}
	if(strErrMsg == null) {
		//I have to make sure the or number is issued to the teller -- only for some school. 
		if(!paymentUtil.isORIssuedToTeller(dbOP, request.getParameter("or_number"), (String)request.getSession(false).getAttribute("userIndex"), strSchoolCode))
			strErrMsg = paymentUtil.getErrMsg();
		else if(faPayment.savePayment(dbOP,request,true)) {
			if(bolIsPIT || bolIsCSA || bolIsJonelta)
				faPayment.saveMiscPmtDuringDP(dbOP, request, request.getParameter("or_number"));


			if(strSchoolCode.startsWith("LNU")) {
				dbOP.cleanUP();
				response.sendRedirect(response.encodeRedirectURL("./assessedfees_print.jsp?view_status=0&stud_id="+request.getParameter("stud_id")));
			}
			else {
				if(strSchoolCode.startsWith("CNU"))
					strSchoolCode = "UI";

				//if( (strSchoolCode.startsWith("CPU") || strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("UI") ||
				//	strSchoolCode.startsWith("UDMC") || strSchoolCode.startsWith("CGH") || strSchoolCode.startsWith("CLDH")
				//	 || strSchoolCode.startsWith("NU") || strSchoolCode.startsWith("CSAB")) &&
				if(!strSchoolCode.startsWith("VMUF") && !strSchoolCode.startsWith("DBTC")  && !strSchoolCode.startsWith("SWU")  &&
							request.getParameter("stud_id") != null && request.getParameter("stud_id").length() > 0) {
					//student should be validated. -- remember,, it is validating by default for all new installations..

					strStudIndex = dbOP.mapUIDToUIndex(request.getParameter("stud_id"));
					if(strStudIndex != null) {//old student.
						enrollment.RegAssignID regAssignID = new enrollment.RegAssignID();
						if(!regAssignID.confirmOldStudEnrollment(dbOP, request.getParameter("stud_id"),
																(String)request.getSession(false).getAttribute("userId"))){
							strErrMsg = regAssignID.getErrMsg();
						}

					}
					else {//temp student.
						enrollment.RegAssignID regAssignID = new enrollment.RegAssignID();
						strStudIndex = regAssignID.confirmTempStudEnrollment(dbOP, request.getParameter("stud_id"),
															(String)request.getSession(false).getAttribute("userId"));
						//strStudIndex = null;
						if(strStudIndex == null){
							strErrMsg = regAssignID.getErrMsg();
						}
						else {
							strStudIndex = dbOP.mapUIDToUIndex(strStudIndex);
							bolIsTempStud = false;
						}
					}
				}
				int iAutoDiscountCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("auto_discount_count"), "0"));
				if(strSchoolCode.startsWith("NEU") && iAutoDiscountCount > 0) {
					String strSQLQueryChk = "select * from FA_STUD_PMT_ADJUSTMENT where user_index = "+strStudIndex+" and sy_from = "+WI.fillTextValue("sy_from")+
											" and semester = "+WI.fillTextValue("semester");//is_valid = 0, is_del = 0 for temp, is_valid = 1 for old stud.
					String strSQLQueryIns = "insert into FA_STUD_PMT_ADJUSTMENT (date_approved, user_index, sy_from, sy_to, semester, year_level, create_date, created_by, "+
						"is_valid, is_del, fa_fa_index)"+
						" values ('"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_of_payment"))+"',"+
						strStudIndex+","+WI.fillTextValue("sy_from")+","+WI.fillTextValue("sy_to")+","+WI.fillTextValue("semester") +",null,'"+
						WI.getTodaysDate()+"', "+(String)request.getSession(false).getAttribute("userIndex");
					
					if(bolIsTempStud) {
						strSQLQueryChk = strSQLQueryChk + " and is_valid = 0 and is_del = 0 "; //temp student is_valid = 0, is_del = 0
						strSQLQueryIns = strSQLQueryIns + ", 0, 0, ";
					}
					else {
						strSQLQueryChk = strSQLQueryChk + " and is_valid = 1";
						strSQLQueryIns = strSQLQueryIns + ", 1, 0, ";
					}
					
					for(int i = 0; i < iAutoDiscountCount; ++i) {
						strTemp = WI.fillTextValue("auto_discount_"+i);
						if(strTemp.length() == 0) 
							continue;
							
						//now check duplicate and save.
						if(dbOP.getResultOfAQuery(strSQLQueryChk+" and fa_fa_index = "+strTemp, 0) != null)
							continue;
							
						dbOP.executeUpdateWithTrans(strSQLQueryIns+strTemp+")",null,null,false);
					}
					dbOP.commitOP();
				
				}
				
				/**
				//for neu, 
				if(WI.fillTextValue("auto_discount").length() > 0 && strStudIndex != null) {
					//I have to check if alreayd posted, if not posted, post it here. 
					strSQLQuery = "select * from FA_STUD_PMT_ADJUSTMENT where user_index = "+strStudIndex+" and sy_from = "+WI.fillTextValue("sy_from")+
									" and semester = "+WI.fillTextValue("semester")+" and fa_fa_index = "+WI.fillTextValue("auto_discount")+" and is_valid = 1";
					strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
					if(strSQLQuery == null) {
						//insert here now. 
						strSQLQuery = "insert into FA_STUD_PMT_ADJUSTMENT (fa_fa_index, date_approved, user_index, sy_from, sy_to, semester, year_level, create_date, created_by)"+
						" values ("+WI.fillTextValue("auto_discount")+",'"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_of_payment"))+"',"+
						strStudIndex+","+WI.fillTextValue("sy_from")+","+WI.fillTextValue("sy_to")+","+WI.fillTextValue("semester") +",null,'"+
						WI.getTodaysDate()+"', "+(String)request.getSession(false).getAttribute("userIndex")+")";
						dbOP.executeUpdateWithTrans(strSQLQuery,null,null,false);
					}
					
				}
				**/
				

				//addeed for AUF..
				if(faPayment.strCCardFineInsQueryForTempStud != null)
					dbOP.executeUpdateWithTrans(faPayment.strCCardFineInsQueryForTempStud+strStudIndex+")",null, null, false);
				//if SPC and paying fine, Post to ledger.
				if(strSchoolCode.startsWith("SPC") && strStudIndex != null && WI.fillTextValue("late_fine").length() > 0 && WI.fillTextValue("late_fine_amt").length() > 0) {
					strSQLQuery = "select othsch_fee_index from fa_oth_sch_Fee where sy_index <= (select sy_index from fa_schyr where sy_from = "+
									WI.fillTextValue("sy_from")+") and is_valid =1 and fee_name = 'FINES - LATE ENROLMENT' order by sy_index desc";
					strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
					
					//post charge.. 
					strTemp = "insert into FA_STUD_PAYABLE (PAYABLE_TYPE,reference_index, AMOUNT,NO_OF_UNITS,USER_INDEX,SY_FROM,SY_TO,SEMESTER,CREATED_BY,"+
					"CREATE_DATE,TRANSACTION_DATE) values (0,"+strSQLQuery+","+WI.fillTextValue("late_fine_amt")+",1,"+strStudIndex+","+WI.fillTextValue("sy_from")+","+
					WI.fillTextValue("sy_to")+","+WI.fillTextValue("semester")+","+request.getSession(false).getAttribute("userIndex")+",'"+WI.getTodaysDate()+"','"+
					ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_of_payment"))+"')";
					dbOP.executeUpdateWithTrans(strTemp,null,null,false);
				}
				
				//if CGH and if student is paying late fine, post it.
				if(strSchoolCode.startsWith("CGH") && strStudIndex != null &&
						WI.fillTextValue("late_fine").length() > 0 && WI.fillTextValue("late_fine_amt").length() > 0) {
					//post charge here.
					strTemp = "insert into FA_STUD_PAYABLE (PAYABLE_TYPE,AMOUNT,NO_OF_UNITS,USER_INDEX,"+
						"SY_FROM,SY_TO,SEMESTER,CREATED_BY,CREATE_DATE,TRANSACTION_DATE,note) values (4,"+
					WI.fillTextValue("late_fine_amt")+",1,"+strStudIndex+","+WI.fillTextValue("sy_from")+","+
					WI.fillTextValue("sy_to")+","+WI.fillTextValue("semester")+","+
					request.getSession(false).getAttribute("userIndex")+",'"+WI.getTodaysDate()+"','"+
					ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_of_payment"))+
					"','Late payment surcharge(D/P)')";
					dbOP.executeUpdateWithTrans(strTemp,null,null,false);
					double dTotalPmt = Double.parseDouble(WI.fillTextValue("amount"));
					dTotalPmt = dTotalPmt - Double.parseDouble(WI.fillTextValue("late_fine_amt"));
					request.getSession(false).setAttribute("lf_reason",": P"+CommonUtil.formatFloat(dTotalPmt,true)+"<br>Late payment surcharge : P"+
					CommonUtil.formatFloat(Double.parseDouble(WI.fillTextValue("late_fine_amt")),true) );
					//System.out.println("Successful");
				}
				//dbOP.rollbackOP();
				dbOP.cleanUP();
				String strSukli = WI.fillTextValue("sukli");
				if(strSukli.length() > 0) {
					//keep change in attribute.
					double dAmtReceived = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""));
					dAmtReceived = dAmtReceived - Double.parseDouble(WI.fillTextValue("amount"));
					strSukli = "&sukli="+ CommonUtil.formatFloat(dAmtReceived,true);
				}

				if (strSchoolCode.startsWith("CPU")) {
					String strORNum = request.getParameter("or_number");
					if(WI.fillTextValue("amount").equals("0")) {
						strORNum = (String)request.getAttribute("or_number");
						if(strORNum == null)
							strORNum = WI.fillTextValue("or_number");
					}
					response.sendRedirect(response.encodeRedirectURL("./payment_prior_enrolment_print.jsp?or_number="+strORNum+strSukli));
				}else{
					response.sendRedirect(response.encodeRedirectURL("./payment_prior_enrolment_print.jsp?or_number="+request.getParameter("or_number")+strSukli));
				}
			}
			return;
		}
		else
			strErrMsg = faPayment.getErrMsg();
	}//added this condition for vmuf.. only if amount paid is >= required d/p.
}
vStudInfo = advising.getStudInfo(dbOP,request.getParameter("stud_id"));

//System.out.println(vStudInfo);

if(vStudInfo == null) {
	strErrMsg = advising.getErrMsg();
	
	if(dbOP.mapUIDToUIndex(request.getParameter("stud_id")) != null)
		strErrMsg = strErrMsg + "<br> <a href='javascript:GoToDP();'>Click here to go to Installment/Downpayment</a>";
}
else{
	
	//for cit, i have to check if student is advised or not - for SWU, forwarding to payment for new and old stud.
	if((strSchoolCode.startsWith("CIT") && vStudInfo.elementAt(10).equals("1")) || strSchoolCode.startsWith("SWU")) {
		//if not advised, forward this request.
		strSQLQuery = "select enroll_index from enrl_final_cur_list where is_valid = 1 and is_temp_stud = 1 and user_index = "+(String)vStudInfo.elementAt(0) +
						" and sy_from = "+(String)vStudInfo.elementAt(16)+" and current_semester = "+(String)vStudInfo.elementAt(18);
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery == null) {//forward to payment without advising.
			dbOP.cleanUP();
			response.sendRedirect("./payment_prior_enrolment.jsp?fee_type=0&stud_id="+WI.fillTextValue("stud_id"));
			return;
		}
	}

	if(vStudInfo.elementAt(7) == null) {//course index is null, forward this ID to basic..
	//System.out.println("here.");
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./assessedfees_basic.jsp?stud_id="+request.getParameter("stud_id")+"&date_of_payment="+ WI.fillTextValue("date_of_payment")+"&payment_mode="+WI.fillTextValue("payment_mode")));
		return;
	}
	
	///for lasalle, old student, i have to remove the exclude misc installment fee if already posted automatically.
	if(strSchoolCode.startsWith("DLSHSI") && !vStudInfo.elementAt(10).equals("1")) {
		strSQLQuery = "update FA_STUD_ASSESSMENT_EXCLUDE_MISC set is_valid = 0, is_del = 1,last_modified_by = 0, last_modified_date = '"+WI.getTodaysDate()+"' from FA_STUD_ASSESSMENT_EXCLUDE_MISC "+
						"join fa_misc_fee on (fa_misc_fee.misc_fee_index = FA_STUD_ASSESSMENT_EXCLUDE_MISC.MISC_FEE_INDEX) "+
						"where fee_name = 'Installment Fee' and sy_from = "+(String)vStudInfo.elementAt(16)+" and FA_STUD_ASSESSMENT_EXCLUDE_MISC.semester = "+
						(String)vStudInfo.elementAt(18)+" and is_temp_stud = 0 and stud_index= "+(String)vStudInfo.elementAt(0)+
						" and FA_STUD_ASSESSMENT_EXCLUDE_MISC.is_valid = 1 and FA_STUD_ASSESSMENT_EXCLUDE_MISC.encoded_by = 0"; System.out.println(strSQLQuery);
        dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	}
	///////////////// end of lasalle.. 

	astrSchYrInfo[0]=(String)vStudInfo.elementAt(16);//take sy from/to/sem from student registration information.
	astrSchYrInfo[1]=(String)vStudInfo.elementAt(17);
	astrSchYrInfo[2]=(String)vStudInfo.elementAt(18);

	paymentUtil.setTempUser((String)vStudInfo.elementAt(10));
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(2),
        (String)vStudInfo.elementAt(3),(String)vStudInfo.elementAt(6),
        astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);

	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
	else
		vMiscFeeIndex = paymentUtil.vMiscFeeIndex;
	if(vMiscFeeIndex == null)
		vMiscFeeIndex = new Vector();
//check if first payment is already paid, if so, take to view/print instead of displaying all information detail.


	if(strErrMsg == null)
	{
		if(faPayment.isFirstPmtDuringEnrlPaid(dbOP,(String)vStudInfo.elementAt(0),
												astrSchYrInfo[0],astrSchYrInfo[1],
												(String)vStudInfo.elementAt(6),astrSchYrInfo[2],
												paymentUtil.isTempStudInStr()))
		{
			if(faPayment.dDPPaidFatima > 0d)
				strErrMsg = faPayment.getErrMsg();
		}
	}

	if (bolIsCPU) {
		 strTemp = dbOP.mapOneToOther("TEMP_FEE_ADJUST","user_index",(String)vStudInfo.elementAt(0),"max(adjust_amt)",
								" and sy_from = " + astrSchYrInfo[0] +  "and semester = " +  astrSchYrInfo[2]  +
								" and (is_rejected is null or is_rejected = 0)" );
		if (strTemp != null) {
				dScholarShipGrants = Double.parseDouble(strTemp);
		}
  	}
}

if(strErrMsg == null) { //collect fee details here.

	//here is the extra condition applied for VMUF... for vmuf, student can't pay less than required d/p..
	//and there is no exception..
		//System.out.println(vStudInfo.elementAt(0));
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);

	if(fTutionFee > 0)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
							astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);

		fOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));

		fMiscOtherFee = fOperation.getMiscOtherFee();

		if(WI.fillTextValue("payment_mode").equals("0"))
			bolIsFullPmt = true;
		
		
		//I have to check if there is scholarship.. 
		//check here if tehre are grants.. 
		strSQLQuery = "select fa_fa_index from FA_STUD_PMT_ADJUSTMENT where user_index = "+(String)vStudInfo.elementAt(0)+" and sy_from = "+astrSchYrInfo[0]+
						" and semester = "+	astrSchYrInfo[2];
		if(paymentUtil.isTempStud())
			strSQLQuery += " and is_valid = 0 and is_del = 0";
		else
			strSQLQuery +=" and is_valid = 1";//System.out.println(strSQLQuery);
			
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next())
			vDiscountApplied.addElement(rs.getString(1));
		rs.close();
		while(vDiscountApplied.size() > 0) {
			dTotalDiscount += fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),astrSchYrInfo[0],astrSchYrInfo[1],
		       				(String)vStudInfo.elementAt(6),astrSchYrInfo[2],(String)vDiscountApplied.remove(0), false, paymentUtil.isTempStud(), false);
		}
		if(dTotalDiscount > 0d) {
			dTotalDiscount = Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTotalDiscount, true), ",",""));
			if(strSchoolCode.startsWith("SPC"))
				bolIsFullPmt = false;//I am not sure how many schools are implementing this... 
		}
		//System.out.println(dTotalDiscount);
			
			
			

		if(WI.fillTextValue("date_of_payment").length() > 0) {
			enrollment.FAFeeOperationDiscountEnrollment test = new enrollment.FAFeeOperationDiscountEnrollment(bolIsFullPmt,
																			WI.fillTextValue("date_of_payment"));

			vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,
			(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
						astrSchYrInfo[0],astrSchYrInfo[1],
                                                (String)vStudInfo.elementAt(6),astrSchYrInfo[2],
                                                fOperation.dReqSubAmt);//System.out.println(vTemp);
			if(vTemp != null && vTemp.size() == 0) {
				vTemp = null;
			}
			//System.out.println(vTemp);
			//added for NEU.. if enrolled less than 15 units, must pay in full and no fp discount.. 
			if(test.isNeu14unitsAndLessEnrolled()) {
				request.getSession(false).setAttribute("force_dp_neu", WI.fillTextValue("stud_id"));
				dReqdDP = fTutionFee+fMiscFee+fCompLabFee+fOutstanding;
			}

			if(vTemp != null)
				strEnrolmentDiscDetail = (String)vTemp.elementAt(0);



			if(strEnrolmentDiscDetail != null)
				fEnrollmentDiscount = ((Float)vTemp.elementAt(1)).floatValue();

//			System.out.println("fEnrollmentDiscount : " + fEnrollmentDiscount);

			if(bolIsFullPmt)
				fPayableAfterDiscount = fTutionFee+fMiscFee+fCompLabFee+fOutstanding-fEnrollmentDiscount - (float)dScholarShipGrants - (float)dTotalDiscount;
			
			//if(dTotalDiscount > 0d)
			//	bolIsFullPmt = false;

			//for jonelta -- set here required d/p.. 
			if(strInfo5.equals("jonelta")) {
				if(!WI.fillTextValue("prev_id").equals(WI.fillTextValue("stud_id"))) {
					faMinDP.updateJoneltaPlanReqdDP(dbOP, request, astrSchYrInfo[0], astrSchYrInfo[2], (String)vStudInfo.elementAt(10), (String)vStudInfo.elementAt(6), 
							(String)vStudInfo.elementAt(0), fTutionFee+fMiscFee+fCompLabFee+fOutstanding-fEnrollmentDiscount, strSchoolCode, true);
					//System.out.println("I am here.");
				}
			}
			
		}
		
		//I have to set if full payment - again, because if there is a scholarship, full payment is set to false... i have to make to true, so that
		//system will show balance amount to be paid, but will not calculate fp discount.. 
		if(WI.fillTextValue("payment_mode").equals("0"))
			bolIsFullPmt = true;

		
		
		//System.out.println(strSchoolCode);
		if(strSchoolCode.startsWith("CGH") || strSchoolCode.startsWith("UDMC") ||
		strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("PHILCST")  || strSchoolCode.startsWith("DBTC")  || strSchoolCode.startsWith("SPC") )
			dReservationFee = paymentUtil.getReservationFeeCGH(dbOP, (String)vStudInfo.elementAt(0),
													astrSchYrInfo[0], astrSchYrInfo[1],
													astrSchYrInfo[2],paymentUtil.isTempStud());


		faMinDP.setTotalAssessment(fTutionFee+fMiscFee+fCompLabFee+fOutstanding);
		if(dReqdDP == 0d)
			dReqdDP = faMinDP.getPayableDownPayment(dbOP, request.getParameter("stud_id"), astrSchYrInfo[0], astrSchYrInfo[1],astrSchYrInfo[2], strSchoolCode, 1,
							(String)vStudInfo.elementAt(0), paymentUtil.isTempStud());
							
		if(dReqdDP > 0d) {//I have to check the PN given..
			///for UC,, if overpayment, ajust to d/p
			//System.out.println("Before: "+dReqdDP);
			if(strSchoolCode.startsWith("UC") && fOutstanding < 1d) {
				dReqdDP = dReqdDP + (int)fOutstanding;
				if(dReqdDP < 1d)
					dReqdDP = 1d;
			}
			//System.out.println("Before: "+dReqdDP);
			
			double dPN = 0d;
			strSQLQuery = "select amount from FA_STUD_PROMISORY_NOTE where sy_from = "+astrSchYrInfo[0]+" and semester = "+astrSchYrInfo[2]+
								" and pmt_sch_index = 0 and is_valid = 1 and user_index = "+(String)vStudInfo.elementAt(0)+" and is_temp_stud_ = "+paymentUtil.isTempStudInStr();
			rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next())
				dPN = rs.getDouble(1);
			rs.close();
			if(dPN > 0d) {
				dReqdDP = dReqdDP - dPN;
				if(dReqdDP < 0d)
					dReqdDP = 0d;
			}
		}
		if(bolEnforceDP) {
			if(dReqdDP == 0d)
				strReqDPMsg = "Min required downpayment is not set. Please set minimum required d/p.";
			else
				strReqDPMsg = "Student must pay minimum downpayment: "+CommonUtil.formatFloat(dReqdDP, true);
		}

	}
	else{
		strErrMsg = fOperation.getErrMsg();
	}

	iNoInstallment=FA.getNoOfInstallment(dbOP,astrSchYrInfo[0], astrSchYrInfo[1], astrSchYrInfo[2]);

	if (iNoInstallment == 0){
		strErrMsg = FA.getErrMsg();
	}

}

//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null)
{
	vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
	if(vTemp == null)
		strErrMsg = paymentUtil.getErrMsg();
	else
		vMiscFeeInfo.addAll(vTemp);//System.out.println(vTemp);

	if(fOperation.vMultipleOCMapInfo != null && fOperation.vMultipleOCMapInfo.size() > 0) {
		vMiscFeeInfo.addAll(fOperation.vMultipleOCMapInfo);
		vMiscFeeIndex.addAll(fOperation.vMultipleOCIndex);
	}


	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");//Other charges.
	}
}//System.out.println(fOperation.getReqSubFeeDtls());
//System.out.println(fCompLabFee);
//System.out.println(vMiscFeeInfo);

if(fMiscFee <=0.1f) {
	vMiscFeeInfo = new Vector();
	fCompLabFee = 0f;
	vMiscFeeInfo.addElement("");
	vMiscFeeInfo.addElement("");
	vMiscFeeInfo.addElement("");
}



////////////// addl for AUF
Vector vOthAssessmentSetting = null;
if(vStudInfo != null && vStudInfo.size() > 0 && astrSchYrInfo != null){
	request.setAttribute("sy_from",astrSchYrInfo[0]);
	request.setAttribute("sy_to",astrSchYrInfo[1]);
	request.setAttribute("semester",astrSchYrInfo[2]);
	vOthAssessmentSetting = new enrollment.FAFeeOptional().operateOnAddlAssessementSetting(dbOP, request, 7);

//	System.out.println("vOthAssessmentSetting : " + vOthAssessmentSetting);

}



//Incase of CGH, i have to check if there is a late fine set, if not set, i have to findout if
//student should pay late fine.
boolean bolShowLateFine = false;
if((strSchoolCode.startsWith("CGH") || strSchoolCode.startsWith("SPC")) && astrSchYrInfo[0] != null && WI.fillTextValue("date_of_payment").length() > 0){
	enrollment.FAFeeOperationDiscountEnrollment fafeeDisc = new enrollment.FAFeeOperationDiscountEnrollment();
	
	bolShowLateFine = fafeeDisc.isLateFeeApplicable(dbOP,astrSchYrInfo[0],astrSchYrInfo[2],WI.fillTextValue("date_of_payment"), strSchoolCode);
		
	if(bolShowLateFine && (WI.fillTextValue("late_fine").length() > 0 || request.getParameter("late_fine_amt") == null) ) {
		if(strSchoolCode.startsWith("CGH"))
			fEnrollmentDiscount = -1 * Float.parseFloat(WI.getStrValue(WI.fillTextValue("late_fine_amt"),"200"));
		else {
			fEnrollmentDiscount = -1 * Float.parseFloat(WI.getStrValue(WI.fillTextValue("late_fine_amt"),Double.toString(fafeeDisc.getFineAmtSPC()) ));
		}
		
		if(bolIsFullPmt)
			fPayableAfterDiscount = fPayableAfterDiscount - fEnrollmentDiscount;
	}
}


Vector vAdvisedList = null;


if (strSchoolCode.startsWith("CPU")){
	if (vStudInfo != null && vStudInfo.size() > 0) {
		vAdvisedList = advising.getAdvisedList(dbOP, (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(10),
									(String)vStudInfo.elementAt(2), astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
		if(vAdvisedList == null)
		{
			strErrMsg = advising.getErrMsg();
		}
	}
}

boolean bolIsICA = false;
strSQLQuery = "select info5 from sys_info";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && strSQLQuery.equals("ICA"))
	bolIsICA = true;

boolean bolIsCCPmtAllowed = false;
if(strSchoolCode.startsWith("PWC") || strSchoolCode.startsWith("SWU") || request.getSession(false).getAttribute("is_cc_allowed") != null)
	bolIsCCPmtAllowed = true;
boolean bolShowBankPost = false;
if(strSchoolCode.startsWith("UB") || strSchoolCode.startsWith("FATIMA") || strSchoolCode.startsWith("DLSHSI"))
	bolShowBankPost = true;

boolean bolShowRemark = false;
if(request.getSession(false).getAttribute("PMT_REMARK_ALLOWED") != null)
	bolShowRemark = true;

boolean bolIsDatePaidReadonly = comUtil.isPaymentDateReadOnly(dbOP, request);
//if(strSchoolCode.startsWith("UC") || strSchoolCode.startsWith("EAC") || strSchoolCode.startsWith("FATIMA"))
//	bolIsDatePaidReadonly = true;

	//System.out.println(vMiscFeeIndex);
	//System.out.println(vMiscFeeInfo);


//if installment Fee, i have add it to the d/p.
double dInstallmentFeeCGH = 0d;



/******************* auto discount for NEU -- so tellers can apply ***************************/
//[0] = fa_fa_index, [1] = main_type_name, [2] = discount %ge, [3] discount amt
Vector vAutoDiscountTeller = new Vector();
double dTemp = 0d;
if(strSchoolCode.startsWith("NEU") && fTutionFee > 0f) {
	//if discount already applied, do not show anymore. 
	strSQLQuery = "select fa_fa_index from FA_STUD_PMT_ADJUSTMENT where user_index = "+(String)vStudInfo.elementAt(0)+" and sy_from = "+astrSchYrInfo[0]+
					" and semester = "+astrSchYrInfo[2];
	if(bolIsTempStud)
		strSQLQuery += " and is_valid = 0 and is_del = 0";
	else
		strSQLQuery += " and is_valid = 1";
	if(dbOP.getResultOfAQuery(strSQLQuery, 0) == null) {
		strSQLQuery = "select fa_fa_index,Main_type_name, discount  from FA_FEE_ADJUSTMENT where is_valid = 1 and sy_from = "+astrSchYrInfo[0]+
						" and (semester is null or semester = "+astrSchYrInfo[2]+") and discount > 0 and "+
						"(main_type_name like 'INC%' or main_type_name like 'Minister%' or main_type_name like 'Iglesia%') order by main_type_name";
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vAutoDiscountTeller.addElement(rs.getString(1));//[0] fa_fa_index
			vAutoDiscountTeller.addElement(rs.getString(2));//[1] Main_type_name
			vAutoDiscountTeller.addElement(rs.getString(3));//[2] discount
			
			dTemp = rs.getDouble(3) * fTutionFee/100d;
			dTemp = Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTemp, true), ", ", ""));
			
			vAutoDiscountTeller.addElement(new Double(dTemp));//[3] Amount.
		}
		rs.close();
	}//do not show if already having discount.. 
}

boolean bolIsChkPmtAllowed = true;
//for Lasalle, if there is a bounced check, do not allow check payment.

%>
<form name="fa_payment" action="./assessedfees.jsp" method="post" onSubmit="return ReturnValidate();">
 <input type="hidden" name="focus_id">
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr bgcolor="#A49A6A">
        <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          PAYMENT OF ASSESSED FEES PAGE ::::</strong></font></div></td>
      </tr>
      <tr bgcolor="#FFFFFF">
        <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"> <%=WI.getStrValue(strErrMsg)%></font> </td>
      </tr>
    </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if (WI.fillTextValue("stud_id").length() > 0){
		enrollment.CheckPayment chkPmt = new enrollment.CheckPayment();
		Vector vChkPmt = null;
		vChkPmt = chkPmt.getChkPaymentDtls(dbOP, WI.fillTextValue("stud_id"),astrSchYrInfo[0],astrSchYrInfo[2]);
		if (vChkPmt!= null && vChkPmt.size()>0){
		if (vChkPmt.elementAt(0)!=null){%>
		<tr><td height="25">&nbsp;</td>
      	<td height="25" colspan="5">
		<table width="60%" class="thinborderALL" cellpadding="0" cellspacing="0">
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
<a href='javascript:ViewCheckPmtDtls("<%=WI.fillTextValue("stud_id")%>","<%=astrSchYrInfo[0]%>", "<%=astrSchYrInfo[1]%>","<%=astrSchYrInfo[2]%>");'><img src="../../../images/view.gif" border="0"></a>
              <font size="1">View Dtls</font></td>
		</tr>
		</table></td></tr>
		<%}}}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%">Student ID </td>
      <td width="20%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event, '0');">      </td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="15%">
	  <a href="#">
	  	<img src="../../../images/form_proceed.gif" onClick="ReloadPage()" border="0"></a>	  </td>
      <td width="35%">
<%if(!bolIsICA) {%>
	  <%//get here cutoff time information.
	  Vector vTempCO = new enrollment.FADailyCashCollectionDtls().getCurrentCutoffStat(dbOP, (String)request.getSession(false).getAttribute("userId"));//System.out.println(vTempCO);
	  //I have to get currency rate..
	  String strCurrencyInfo = new locker.Currency().getLatestCurrencyRate(dbOP);

	  if(vTempCO != null){%>
		  <table width="85%" class="thinborderALL" cellpadding="0" cellspacing="0">
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
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><label id="coa_info"></label></td>
      <td colspan="2" style="font-size:16px;">
	  <%if(vStudInfo != null && vStudInfo.elementAt(0) != null) {%>
			Auto Apply Discount: 
		  <select name="auto_discount" style="font-size:20px; font-weight:bold">
			<option value=""></option>
			<%//=dbOP.loadCombo("fa_fa_index","Main_type_name"," from FA_FEE_ADJUSTMENT where is_valid = 1 and sy_from = "+astrSchYrInfo[0]+" and (semester is null or semester = "+astrSchYrInfo[2]+") and discount > 0 and (main_type_name like 'INC%' or main_type_name like 'Minister%' or main_type_name like 'Iglesia%') order by main_type_name", request.getParameter("auto_discount"), false)%>
		  </select>	  
	  <%}%>
	  </td>
    </tr>
-->
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payment Date</td>
      <td colspan="2">
<%
strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%> <input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%if(!bolIsDatePaidReadonly) {%>
        <a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>      
<%}%>		</td>
      <td height="25" colspan="2">
<%if(bolShowLateFine){//System.out.println(request.getParameter("late_fine_amt"));
	strTemp = WI.fillTextValue("late_fine");
	if(strTemp.equals("1") || request.getParameter("late_fine_amt") == null)
		strTemp = " checked";
%>
	  	<input name="late_fine" type="checkbox" value="1" onClick="ApplyLateFine();"<%=strTemp%>>
		<font size="1" color="#0000FF"><b>Apply Late Fine</b></font>
<%
strTemp = WI.fillTextValue("late_fine_amt");
if(strTemp.length() == 0) {
	strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(-1*fEnrollmentDiscount, true), ",","");//to handle SPC and CGH.
	
	//strTemp = "200";
}
%>
		<input type="text" name="late_fine_amt" class="textbox" value="<%=strTemp%>"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="5"
		 onKeyUp="AllowOnlyInteger('fa_payment','late_fine_amt');" maxlength="5">
<%}%>	  </td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3"><hr size="1">
        <!-- enter here all hidden fields for student. -->
        <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
        <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(6)%>">
        <input type="hidden" name="semester" value="<%=astrSchYrInfo[2]%>">
		<input type="hidden" name="sy_from" value="<%=astrSchYrInfo[0]%>">
        <input type="hidden" name="sy_to" value="<%=astrSchYrInfo[1]%>"> <input type="hidden" name="is_tempstud" value="<%=paymentUtil.isTempStudInStr()%>">      </td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="38%" height="25">Name :<strong> <%=(String)vStudInfo.elementAt(1)%>
        </strong></td>
      <td width="60%" height="25">Course :<strong><%=(String)vStudInfo.elementAt(7)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Enrolling Year :<strong><%=WI.getStrValue(vStudInfo.elementAt(6),"N/A")%></strong>      </td>
      <td height="25">
        <%if(vStudInfo.elementAt(8) != null){%>
        Major:<strong><%=(String)vStudInfo.elementAt(8)%></strong>
        <%}%>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">SY/Term : <strong><%=astrSchYrInfo[0]%>
        - <%=astrSchYrInfo[1].substring(2)%> / <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%></strong>      </td>
      <td height="25">Foreign Student : <font color="#9900FF"><strong>
      <%
enrollment.CourseRequirement CR = new enrollment.CourseRequirement();
boolean bolIsAlienNationality = CR.isForeignNational(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud());
if(bolIsAlienNationality)
	strTemp = "1";
else
	strTemp = "0";

	  if(bolIsAlienNationality){%>
YES <%=WI.getStrValue(CR.getStudNationality(),"(",")","")%>
<input type="hidden" name="is_alien" value="1">
<%}else{%>
NO
<input type="hidden" name="is_alien" value="0">
<%}%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <a href='javascript:UpdateNationality("<%=WI.fillTextValue("stud_id")%>","<%=(String)vStudInfo.elementAt(0)%>",
	  "<%=paymentUtil.isTempStudInStr()%>");'><img src="../../../images/update.gif" border="0"></a></strong></font></td>
    </tr>
<%if(strReqDPMsg != null) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" style="font-size:11px; font-weight:bold; color:#FF0000"><%=strReqDPMsg%></td>
    </tr>
<%}%>
  </table>
<%}//if student info is not null
if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && fTutionFee > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="25" colspan="9"><div align="center">STUDENT ASSESSMENT</div></td>
    </tr>
  </table>

<%
	if (vAdvisedList != null && vAdvisedList.size()  > 0 && strSchoolCode.startsWith("CPU")) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
  <tr>
    <td width="18%" height="25" class="thinborder"><font size="1"><strong>&nbsp;SUBJECT CODE</strong></font></td>
    <td width="29%" class="thinborder"><font size="1"><strong>&nbsp;SUBJECT TITLE</strong></font></td>
	<td width="8%" class="thinborder"><font size="1"><strong>&nbsp;TOTAL &nbsp;UNITS</strong></font></td>
    <td width="8%" class="thinborder"><strong><font size="1">&nbsp;UNITS &nbsp;TAKEN</font></strong></td>
    <td width="12%" class="thinborder"><font size="1"><strong>&nbsp;ROOM</strong></font></td>
    <td width="25%" class="thinborder"><font size="1"><strong>&nbsp;SCHEDULE</strong></font></td>
  </tr>
  <%
for(int i = 1; i<vAdvisedList.size(); ++i)
{%>
  <tr>
    <td height="20" class="thinborder"><font size="1"><%=(String)vAdvisedList.elementAt(i)%></font></td>
    <td class="thinborder"><font size="1"><%=(String)vAdvisedList.elementAt(i+1)%></font></td>
<%if(!strSchoolCode.startsWith("AUF")){%>
    <td class="thinborder"><font size="1"><%=(String)vAdvisedList.elementAt(i+8)%></font></td>
<%}%>
    <td class="thinborder"><font size="1"><%=(String)vAdvisedList.elementAt(i+9)%></font></td>
    <td class="thinborder"><font size="1">
			<%=WI.getStrValue((String)vAdvisedList.elementAt(i+4),"TBA")%></font></td>
    <td class="thinborder"><font size="1">
			<%=WI.getStrValue((String)vAdvisedList.elementAt(i+2),"TBA")%> </font></td>
  </tr>
  <%
i = i+10;
}%>
</table>
<%}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4" bgcolor="#D2D6C0"><div align="center"><font color="#000066" size="1"><strong>::
          FEE DETAILS ::</strong></font></div></td>
      <td height="31" colspan="3" bgcolor="#E9EADF"><div align="center"><font color="#000066" size="1"><strong>::
          PAYMENT DETAILS ::</strong></font></div></td>
    </tr>
    <tr >
      <td width="2%" height="25" bgcolor="#D2D6C0">&nbsp;</td>
      <td colspan="3" valign="top" bgcolor="#D2D6C0"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td height="20" colspan="2"><font size="1"><strong>TUITION FEE :<font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%> </font></strong></font></td>
          <td width="29%" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></font></td>
          <td width="5%">&nbsp;</td>
        </tr>
<% if (!strSchoolCode.startsWith("CPU")){%>
        <tr>
          <td height="20" colspan="2"><font size="1">COMP. LAB. FEE : </font></td>
          <td align="right"><font size="1"><strong><%=CommonUtil.formatFloat((double)fCompLabFee, true)%> </strong></font></td>
          <td>&nbsp;</td>
        </tr>
<%}%>
        <tr>
          <td height="20" colspan="4"><font size="1">MISCELLANEOUS FEES</font></td>
        </tr>
        <%
		vTemp = new Vector();//System.out.println(vMiscFeeInfo);
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).equals("1"))
				continue;
		%>
        <tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
          <td width="3%" height="20">
		  <%if( (bolIsPIT  || bolIsCSA || bolIsJonelta)&& vMiscFeeIndex.size() > 0){
			  while(vMiscFeeIndex.size() > 0) {
				if(vMiscFeeIndex.elementAt(1).equals("1")) {
					vTemp.addElement(vMiscFeeIndex.remove(0));vTemp.addElement(vMiscFeeIndex.remove(0));
					continue;
				}
				break;
			  }
			  //for PIT, all misc fee checked, for CSA, only few are checked.
			  strTemp = "";
			  if(bolIsPIT || bolIsFullPmt)
			  	strTemp = " checked";
			  else if(bolIsCSA) {
			  	strTemp = ((String)vMiscFeeInfo.elementAt(i)).toLowerCase();
			  	if(vMandatoryFee.indexOf(strTemp) > -1) {
					strTemp = " checked";
					dMandatoryFee += Double.parseDouble((String)vMiscFeeInfo.elementAt(i+1));
				}
				else
					strTemp = "";
			  }
			  else if(bolIsFullPmt && bolIsJonelta)
			  	strTemp = " checked";
			  %>
			  <input type="checkbox" name="_<%=iMiscFeeIndex%>" <%=strTemp%> value="<%=vMiscFeeIndex.remove(0)%>" onClick="UpdateMiscFeePmt(document.fa_payment._<%=iMiscFeeIndex%>, '<%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true),",","")%>');">
			  <input type="hidden" name="__<%=iMiscFeeIndex++%>" value="<%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true),",","")%>">

		  <%vMiscFeeIndex.remove(0);}%>		  </td>
          <td width="63%"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="20" align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%> </font></td>
          <td>&nbsp;</td>
        </tr>
        <%}%>
        <tr>
          <td height="20">&nbsp;</td>
          <td><font size="1"><strong>TOTAL MISC:</strong></font></td>
          <td height="20" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%> </strong></font></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" colspan="2"><font size="1">OTHER CHARGES</font></td>
          <td height="20">&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <%
		  //System.out.println("Printing vMiscFeeIndex------------: "+vMiscFeeIndex);
		  vTemp.addAll(vMiscFeeIndex);
		  vMiscFeeIndex = vTemp;
		  //System.out.println("Printing vTemp: "+vTemp);
		if (vMiscFeeInfo!= null)
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).equals("0"))
				continue;
				
			if(strSchoolCode.startsWith("CGH")) {
				if(((String)vMiscFeeInfo.elementAt(i)).toLowerCase().startsWith("installment fee"))
					dInstallmentFeeCGH = Double.parseDouble((String)vMiscFeeInfo.elementAt(i+1));
			}
		%>
        <tr class="nav" id="msg<%=(i+1)*1000%>" onMouseOver="navRollOver('msg<%=(i+1)*1000%>', 'on')" onMouseOut="navRollOver('msg<%=(i+1)*1000%>', 'off')">
          <td height="20">
		  <%
		  if( (bolIsPIT || bolIsCSA || bolIsJonelta)&& vMiscFeeIndex.size() > 0){
			  while(vMiscFeeIndex.size() > 0) {
				if(vMiscFeeIndex.elementAt(1).equals("0")) {
					vMiscFeeIndex.remove(0);vMiscFeeIndex.remove(0);
					continue;
				}
				break;
			  }
			
			  //for PIT, all misc fee checked, for CSA, only few are checked.
			  strTemp = "";
			  if(bolIsFullPmt)
			  	strTemp = " checked";
			  else if(bolIsCSA) {
			  	strTemp = ((String)vMiscFeeInfo.elementAt(i)).toLowerCase();
			  	if(vMandatoryFee.indexOf(strTemp) > -1) {
					strTemp = " checked";
					dMandatoryFee += Double.parseDouble((String)vMiscFeeInfo.elementAt(i+1));
				}
				else
					strTemp = "";
			  }
			  %>
			  <input type="checkbox" name="_<%=iMiscFeeIndex%>" <%=strTemp%> value="<%=vMiscFeeIndex.remove(0)%>" onClick="UpdateMiscFeePmt(document.fa_payment._<%=iMiscFeeIndex%>, '<%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true),",","")%>');">
			  <input type="hidden" name="__<%=iMiscFeeIndex++%>" value="<%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true),",","")%>">

		  <%vMiscFeeIndex.remove(0);}%>		  </td>
          <td height="20"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="20" align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></td>
          <td>&nbsp;</td>
        </tr>
        <%}%>
		<input type="hidden" name="max_disp_misc" value="<%=iMiscFeeIndex%>">
        <tr>
          <td height="20">&nbsp;</td>
          <td height="20"><font size="1"><strong>OTHER CHARGE :</strong></font></td>
          <td height="20" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%> </strong></font></td>
          <td>&nbsp;</td>
        </tr>
<% if (!strSchoolCode.startsWith("CPU")) {%>
        <tr>
          <td height="20" colspan="4"><hr size="1"></td>
          </tr>
        <tr>
          <td height="20" colspan="2"><font size="1"><strong>TOTAL TUITION FEE
        : </strong></font></td>
          <td height="20" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%> </strong></font></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" colspan="2"><font size="1"><strong>OLD ACCOUNT :</strong></font></td>
          <td height="20" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" colspan="2"><font size="1"><strong>TOTAL AMOUNT DUE
        :</strong></font></td>
          <td height="20" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding - fEnrollmentDiscount,true)%></strong></font></td>
          <td>&nbsp;</td>
        </tr>
    <% } // end do not show for CPU
if(strSchoolCode.startsWith("CGH") || strSchoolCode.startsWith("UDMC") ||
strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("PHILCST") || strSchoolCode.startsWith("DBTC")   || strSchoolCode.startsWith("SPC")){
 dTotalPayable = fTutionFee+fCompLabFee+fMiscFee + fOutstanding - dReservationFee - fEnrollmentDiscount;
%>
        <tr>
          <td height="20" colspan="2">&nbsp;
 <%if(dTotalPayable > 0d){%> <font size="1"><strong>LESS RESERVATION FEE
        :</strong></font> <%}%>		  </td>
          <td height="20" align="right" style="font-size:9px; font-weight:bold"><%if(dTotalPayable > 0d){%>
            <%=CommonUtil.formatFloat(dReservationFee,true)%>
            <%}%></td>
          <td>&nbsp;</td>
        </tr>
<%}if(dTotalDiscount > 0d) {%>
        <tr>
          <td height="20" colspan="2" style="font-size:9px; font-weight:bold">&nbsp;&nbsp; LESS SCHOLARSHIP/GRANTS</td>
          <td height="20" align="right" style="font-size:9px; font-weight:bold"><%=CommonUtil.formatFloat(dTotalDiscount, true)%></td>
          <td>&nbsp;</td>
        </tr>
<%}%>
      </table></td>
      <td width="3%" bgcolor="#E9EADF">&nbsp;</td>
      <td width="53%" colspan="2" valign="top" bgcolor="#E9EADF"><table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <% if (!bolIsCPU && false) {%>
        <tr>
          <td width="44%"> <font size="1">PAYEE TYPE</font> &nbsp;</td>
          <td width="56%"><font size="1"><strong>
	        <select name="payee_type" onChange="ReloadPage();">
    	      <option value="0">Student/Parent/Relative/Grants</option>
          <% strTemp = WI.fillTextValue("payee_type");
			 if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Institutional</option>
          <%}else{%>
          <option value="1">Institutional</option>
          <%}%>
        </select>

        </strong> </font></td>
        </tr>

        <tr>
          <td height="20"><font size="1">PAYEE NAME </font></td>
          <td><font size="1">
        <% if(strTemp.compareTo("1") ==0) //institutional
{%>
        <select name="ai_index">
          <%=dbOP.loadCombo("AI_INDEX","AFF_INST_NAME"," from FA_AFFILIATED_INST where is_del=0 order by AFF_INST_NAME asc", request.getParameter("ai_index"), false)%>
        </select>
        <%}else{%>
        N/A
        <%}%>
        </font></td>
        </tr>
	 <%}else if(bolIsCPU){%>
        <tr>
          <td height="20" colspan="2"><table width="75%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborderALL">
            <tr>
              <td class="payment_details">&nbsp;</td>
              <td align="right" class="payment_details">&nbsp;</td>
            </tr>
            <tr>
              <td width="54%" class="payment_details">&nbsp;&nbsp;TOTAL CHARGES </td>
              <td width="31%" align="right" class="payment_details"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%>&nbsp;&nbsp;</strong></td>
              </tr>
            <tr>
              <td class="payment_details">&nbsp;&nbsp;
			 <% if (fOutstanding < 0f){%>
			  REFUND
			  <%}else{%> OLD ACCOUNT <%}%>			  </td>
              <td align="right" class="payment_details"><strong>
			  <%if (fOutstanding < 0f) {%>
			  	<%=CommonUtil.formatFloat(fOutstanding * -1,true)%>
			  <%}else{%>
			  	<%=CommonUtil.formatFloat(fOutstanding,true)%>
			  <%}%>
				&nbsp;&nbsp;</strong></td>
              </tr>
            <tr>
              <td class="payment_details">&nbsp;&nbsp;DISCOUNT (FULL PAYMENT)</td>
              <td align="right" class="payment_details"><strong><%=CommonUtil.formatFloat(fEnrollmentDiscount,true)%>&nbsp;&nbsp;</strong></td>
              </tr>
            <tr>
              <td height="17" class="payment_details">&nbsp;&nbsp;SCHOLARSHIPS / GRANTS </td>
              <td align="right" class="payment_details">
			  <strong><%=CommonUtil.formatFloat(dScholarShipGrants,true)%></strong>&nbsp;&nbsp;			  </td>
            </tr>
            <tr>
              <td class="payment_details">&nbsp;&nbsp;REQ. DOWNPAYMENT</td>
              <td align="right" class="payment_details"><strong>
			  		<%=CommonUtil.formatFloat((fTutionFee+fCompLabFee+fMiscFee)/iNoInstallment,true)%>&nbsp;&nbsp;</strong>			  </td>
             </tr>
            <tr>
              <td class="payment_details">&nbsp;</td>
              <td align="right" class="payment_details">&nbsp;</td>
            </tr>
          </table></td>
          </tr>
        <tr>
          <td height="20">&nbsp;</td>
          <td>&nbsp; </td>
        </tr>
	 <%}%>
        <tr>
          <td height="20"><font size="1">PAYMENT MODE </font></td>
          <td><font size="1"><strong>
            <select name="payment_mode" onChange="ShowHideApprovalNo();">
              <option value="1">Installment</option>
              <%
strTemp = request.getParameter("payment_mode");
if(strTemp == null && vOthAssessmentSetting != null && vOthAssessmentSetting.size() > 0)
	strTemp = (String)vOthAssessmentSetting.elementAt(1);
if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("0") ==0) {%>
              <option value="0" selected>Full</option>
              <%}else{%>
              <option value="0">Full</option>
              <%}%>
            </select>
          </strong></font></td>
        </tr>
<%
if(false)
if(strSchoolCode.startsWith("CSA") || strSchoolCode.startsWith("CIT")) {%>
        <tr>
          <td height="20" colspan="2">
			<div id="change_div" style="visibility:hidden">
				<table>
					<td height="25">&nbsp;</td>
					<td style="font-size:18px;">Change: </td>
					<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
				</table>
			</div>			</td>
        </tr>
<%}%>
    <tr>
		<td colspan="2">
			<div id="change_div">
			<table cellpadding="0" cellspacing="0" width="100%">
      			<td width="50%" style="font-size:18px;">Change: &nbsp;<label id="change_" style="width:200px;font-weight:bold; color:#FF0000">&nbsp;</label></td>
      			<td width="50%">
				<label id="format_amt" style="font-size:18px; font-weight:bold; color:#00CCFF"></label>				</td>
			</table>
		</div>		</td>
    </tr>

        <tr>
          <td height="20"><font size="1">AMOUNT PAID </font></td>
          <td>
            <% if(fPayableAfterDiscount > 0f){%>
            <%//=CommonUtil.formatFloat(fPayableAfterDiscount,true)%>
          <!-- <input type="hidden" name="amount" value="<%=fPayableAfterDiscount%>"> -->
          <%strTemp = CommonUtil.formatFloat((fPayableAfterDiscount - dReservationFee),true);
strTemp = ConversionTable.replaceString(strTemp,",","");
if(vOthAssessmentSetting != null && vOthAssessmentSetting.size() > 0
	&& request.getParameter("amount") == null && vOthAssessmentSetting.elementAt(3) != null)
	strTemp = (String)vOthAssessmentSetting.elementAt(3);
%>
          <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxFormatAmount();AjaxUpdateChange();MoveNext(event, '_1')" autocomplete="off">
          <%}else{
		  //for vmuf, must pay d/p..
		  strTemp = WI.fillTextValue("amount");
		  if(dReqdDP > 0d) {
				double dReqdPmt = fTutionFee+fCompLabFee+fMiscFee + fOutstanding - fEnrollmentDiscount - dTotalDiscount;
				if(dReqdDP > dReqdPmt)
					dReqdDP = dReqdPmt;
				if(dReqdPmt <=0d || dReqdDP <0d)
					dReqdDP = 0d;

				if(dReqdDP > 0d) {
					strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(dReqdDP,true),",","");
					dReqdDP = Double.parseDouble(strTemp);
				}
		  }
		  if(bolIsPIT) {//payment equals to misc fee..
		  	strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true),",","");
		  }
		  else if(bolIsCSA) {
		  	strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(dMandatoryFee,true),",","");
		  }
		  else if(strSchoolCode.startsWith("SPC") && iNoInstallment > 0) {
		  	dTemp = fTutionFee+fCompLabFee+fMiscFee - dTotalDiscount;
			
			if(fEnrollmentDiscount > 0d)//only if discount.. if -ve, it is a fine.. 
				dTemp = dTemp - fEnrollmentDiscount;
				
			dTemp = dTemp/(iNoInstallment + 1);
			
			//System.out.println(dTemp);
			double[] adTemp = FA.convertDoubleToNearestInt("SPC", dTemp);//AUF code will give me the rounded value
			if(adTemp != null)
				dTemp = adTemp[0];
			
			dTemp = dTemp + fOutstanding;
			if(fEnrollmentDiscount < 0d)
				dTemp = dTemp - fEnrollmentDiscount;
				
			if(dTemp <=0d)
				dTemp = 1d;

			
		  	strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(dTemp,true),",","");
		  }
		  %>
          <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" onKeyUp="AjaxFormatAmount();AjaxUpdateChange();MoveNext(event, '_1')" autocomplete="off">
          <%}%></td>
<script language="javascript">
	document.fa_payment.focus_id.value = "2";
</script>
        </tr>
<%if(bolIsJonelta){%>
    <tr style="font-weight:bold">
      <td style="font-size:11px; color:#0000FF">NSTP Amount Paid </td>
      <td><input name="nstp_amount" type="text" size="16" class="textbox" style="color:#0000FF; font-weight:bold"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td style="font-size:11px;" colspan="2"><strong>Note:</strong> Total Amount Paid value should include NSTP Amount. For example
	  student pays 1,000 tuition, 500 nstp, Input 1,500 in amount paid and 500 in nstp amount paid	  </td>
    </tr>
<%}%>
        <tr>
          <td height="20"><font size="1">Amount Tendered</font></td>
          <td>
	  		<input name="amount_tendered" type="text" size="16" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();MoveNext(event, '_2')" id="_1">		  </td>
        </tr>
<%if(strEnrolmentDiscDetail != null && !bolIsCPU){%>
        <tr>
          <td height="20" colspan="2"><font size="1" color="#0000FF"><b>
            <label id="full_pmt_discount"><%=strEnrolmentDiscDetail%></label>
          </b></font>&nbsp;</td>
         </tr>
	<%} if (!bolIsCPU && false) {%>
        <tr>
          <td height="20"><font size="1">APPROVAL DATE</font></td>
          <td height="20"><font size="1">
            <input name="date_approved" type="text" size="16" value="<%=WI.fillTextValue("date_approved")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
            <a href="javascript:show_calendar('fa_payment.date_approved');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
        </tr>
	<%}%>
<!--
        <tr>
          <td height="20"><font size="1">PAYMENT RECEIVE TYPE</font></td>
          <td height="20"><select name="pmt_receive_type" onChange="ReloadPage();">
            <option value="Internal">Internal</option>
            <%
strTemp = WI.fillTextValue("pmt_receive_type");
if(false && strTemp.compareTo("External") ==0){%>
            <option value="External" selected>External</option>
            <%}else if(false){%>
            <option value="External">External</option>
            <%}%>
          </select></td>
        </tr>
--><input type="hidden" name="pmt_receive_type" value="Internal">
<%
if(false){%>
        <tr>
          <td height="20"><font size="1">BANK NAME </font></td>
          <td height="20"><% if(strTemp.compareTo("External") ==0) //External
{%>
            <select name="bank">
              <%=dbOP.loadCombo("AB_INDEX","AFF_BANK_NAME"," from FA_AFFILIATED_BANK where is_del=0 order by AFF_BANK_NAME asc",
   		request.getParameter("bank"), false)%>
            </select>
            <%}else{%>
N/A
<%}%></td>
        </tr>
<%}%>
        <tr>
          <td height="20"><font size="1">PAYMENT TYPE</font></td>
          <td height="20">
		  <select name="payment_type" onChange="ShowHideCheckNO();">
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
if(strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("CSA") || strSchoolCode.startsWith("EAC") || bolIsCCPmtAllowed){
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
<%}%>
<%if(bolShowBankPost) {
	if(strTemp.compareTo("8") ==0){%>
			  <option value="8" selected>Bank Payment</option>
	<%}else{%>
			  <option value="8">Bank Payment</option>
	<%}

}%>		  
			  </select>		  </td>
        </tr>
        <tr>
          <td height="20" colspan="2"><font size="1">
            <div id="myADTable1">Amt Chk
              <input name="chk_amt" type="text" size="8" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('fa_payment','amount');computeCashChkAmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('fa_payment','chk_amt');computeCashChkAmt();">
              Cash
  <input name="cash_amt" type="text" size="8" class="textbox_noborder" readonly="yes" style="background-color: #E9EADF;">
            </div>
	<% if (!bolIsCPU) {%>
            <input name="text2" type="text" class="textbox_noborder" id="_empID" style="background-color: #E9EADF;" value="Emp ID:" size="6" readonly="yes">
            <input type="text" name="cash_adv_from_emp_id" value="<%=WI.fillTextValue("cash_adv_from_emp_id")%>" size="16" id="_empID1" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	<%}%>
          </font></td>
          </tr>
        <tr>
          <td height="20"><font size="1">CHECK #</font></td>
          <td height="20">
            <%
strTemp = "";
if(request.getParameter("payment_type") == null || 	 request.getParameter("payment_type").trim().length() ==0 ||
	request.getParameter("payment_type").compareTo("0") == 0)
{
	strTemp = "disabled";
}%>
            <input type="text" name="check_number" value="<%=WI.fillTextValue("check_number")%>" <%=strTemp%> class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
            <br>
            <select name="CHECK_FR_BANK_INDEX" style="font-size:10px" >
              <option value=""></option>
              <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH", " from FA_BANK_LIST where is_valid =1 order by bank_code", request.getParameter("CHECK_FR_BANK_INDEX"), false)%>
            </select>          </td>
        </tr>
        <tr>
          <td height="20"><font size="1">REFERENCE NUMBER</font></td>
          <td height="20"><font size="1"><b>
            <input name="or_number" type="text" size="16" value="<%=paymentUtil.generateORNumber(dbOP,(String)request.getSession(false).getAttribute("userIndex"), true)%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          </b></font></td>
        </tr>

        <tr>
          <td height="20" colspan="2" id="credit_card_info">
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
		  </table>		  </td>
        </tr>
<%if(bolShowRemark){%>
        <tr>
          <td height="20" colspan="2">
			  Payment Note: <br>
			  <textarea class="textbox" rows="3" cols="50" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" name="pmt_for_dtls"><%=WI.fillTextValue("pmt_for_dtls")%></textarea>
		  </td>
        </tr>
<%}%>
<%
if(strSchoolCode.startsWith("CGH") || strSchoolCode.startsWith("UDMC") ){
%>
        <tr>
          <td height="20">&nbsp;<font size="1"><strong>FULL PAYMENT : <%=CommonUtil.formatFloat(dTotalPayable,true)%></strong></font></td>
          <td height="20">&nbsp;<font size="1"><strong>
	  <%if(strSchoolCode.startsWith("CGH")){%>
	  50% : <%=CommonUtil.formatFloat((dTotalPayable+fEnrollmentDiscount)/2 + dInstallmentFeeCGH/2 - fEnrollmentDiscount,true)%>
	  <%}else{%>
	  DP : <%=CommonUtil.formatFloat( (dTotalPayable + dReservationFee)/2 - dReservationFee,true)%>
	  <%}%>

	  </strong></font></td>
        </tr>
<%}else if(strSchoolCode.startsWith("NU")){%>
        <tr>
          <td height="20" colspan="2" style="font-size:9px; font-weight:bold"><u>Downpayment : <%=CommonUtil.formatFloat(fMiscFee,true)%></u></td>
        </tr>
<%}%>
      </table></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9"><hr size="1"></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="0%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><div align="center">
<%if(iAccessLevel > 1){%>
          <a href="javascript:AddRecord();" id="_2"><img name="hide_save" src="../../../images/save.gif" border="0"></a>
          <font size="1">click to save entries</font>
<%}%>		  </div></td>
      <td colspan="3" height="25">&nbsp;</td>
      <td width="5%"  height="25">&nbsp;</td>
    </tr>
</table>

<!-- all for NEU -- to show discount to teller.. -->
	<%if(vAutoDiscountTeller != null && vAutoDiscountTeller.size() > 0) {
		int iCount = 0;%>
		<div id="processing" class="processing"  style="visibility:visible">
			<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#FFCC99">
			  <tr>
				<td valign="top" align="right"><a href="javascript:HideLayer(1)">Close Window X</a></td>
			  </tr>
			  <tr>
				  <td valign="top">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						  <tr style="font-weight:bold">
							  <td width="75%" style="font-size:11px;" class="thinborderBOTTOMRIGHT">Name</td>
							  <td width="10%" style="font-size:11px;" class="thinborderBOTTOMRIGHT">%ge</td>
							  <td width="15%" style="font-size:11px;" align="right" class="thinborderBOTTOM">Amount</td>
						  </tr>
						<%while(vAutoDiscountTeller.size() > 0) {
							strTemp = WI.fillTextValue("auto_discount_"+iCount);
							if(strTemp.length() > 0) 
								strTemp = " checked";
							else	
								strTemp = "";
						%>
						  <tr>
							  <td style="font-size:9px;" class="thinborderRIGHT"><input type="checkbox" name="auto_discount_<%=iCount%>" value="<%=vAutoDiscountTeller.elementAt(0)%>"
							   onClick="ApplyAutoDiscount('<%=iCount%>');" <%=strTemp%>> <%=vAutoDiscountTeller.elementAt(1)%></td>
							  <td style="font-size:9px;" class="thinborderRIGHT"><%=vAutoDiscountTeller.elementAt(2)%></td>
							  <td style="font-size:9px;" align="right"><%=CommonUtil.formatFloat(((Double)vAutoDiscountTeller.elementAt(3)).doubleValue(), true)%>
							  <input type="hidden" name="auto_discount_amt_<%=iCount%>" value="<%=((Double)vAutoDiscountTeller.elementAt(3)).doubleValue()%>"></td>
						  </tr>
						<%++iCount;
						vAutoDiscountTeller.remove(0);vAutoDiscountTeller.remove(0);vAutoDiscountTeller.remove(0);vAutoDiscountTeller.remove(0);
						}%>
						<input type="hidden" name="auto_discount_count" value="<%=iCount%>">
					</table>
				  </td>
			  </tr>
			  </table>

		
		</div>
	<%}%>


<%}else{ //end of display if vMisFee is not null
%>
	<input type="hidden" name="payment_mode" value="<%=WI.fillTextValue("payment_mode")%>">
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">
<%
//this is used to allow the user to view or print the fee payment if studetn has already paid
if(WI.fillTextValue("view_status").length() > 0 || (strErrMsg != null && strErrMsg.endsWith("#PRINT#")) )
{%>
<a href="javascript:PrintViewPayment(1);"><img src="../../../images/view.gif" border="0"></a><font size="1">Click to view payment detail</font>
 &nbsp;(OR) &nbsp; <a href="javascript:PrintViewPayment(0);"><img src="../../../images/print.gif" border="0"></a><font size="1">Click to print payment detail</font>

<%}%>
	 </td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

 <input type="hidden" name="addRecord" value="0">
 <input type="hidden" name="payment_for" value="0">
 <input type="hidden" name="view_status" value="<%=WI.fillTextValue("view_status")%>">
 <input type="hidden" name="updateNationality">

 <input type="hidden" name="sukli">

 <input type="hidden" name="reqd_dp" value="<%=dReqdDP%>">
 <input type="hidden" name="prev_id" value="<%=WI.fillTextValue("stud_id")%>">

 <input type="hidden" name="page_reloaded">

<!--
<input type="hidden" name="amount_tendered" value="">
-->

<input type="hidden" name="prevent_chk_pmt" value="<%if(!bolIsChkPmtAllowed){%>1<%}else{%><%}%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
