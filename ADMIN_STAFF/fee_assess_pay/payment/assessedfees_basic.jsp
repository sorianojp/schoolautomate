<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,java.util.Vector" buffer="20kb" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","Regular",""};

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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"assessedfees.jsp");
//if(WI.fillTextValue("view_status").length() == 0)
//	iAccessLevel = 2;

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../admin_staff/admin_staff_bottom_content.htm");
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

if(strSchoolCode.startsWith("DLSHSI")) //tracking is for lasalle only.. 
	request.getSession(false).setAttribute("start_time_long_or",String.valueOf(new java.util.Date().getTime()));

String strProcessingFee = "Not Set";
if(strSchoolCode.startsWith("AUF")) {
	strTemp = "select PROCESSING_FEE,MIN_PROCESSING_FEE from CCARD_SETTING";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	rs.next();
	strProcessingFee = Double.toString(rs.getDouble(1)/100)+"%";
	if(rs.getInt(2) > 0)
		strProcessingFee += " or Min of "+rs.getString(2);
 }

boolean bolIsCPU = strSchoolCode.startsWith("CPU");


boolean bolIsDatePaidReadonly = comUtil.isPaymentDateReadOnly(dbOP, request);

//boolean bolIsDatePaidReadonly = false;
//if(strSchoolCode.startsWith("UC") || strSchoolCode.startsWith("EAC") || strSchoolCode.startsWith("FATIMA"))
//	bolIsDatePaidReadonly = true;

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

</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
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
function ShowHideCheckNO()
{
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

	if(iPaymentTypeSelected > 3) {//credit card..
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
	if(strSchoolCode.startsWith("CPU") || strSchoolCode.startsWith("CLDH") || strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("DBTC") ||
	strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("FATIMA")){%>
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
		<%}else{%>
			location = "./assessedfees_print_basic.jsp?stud_id="+escape(strStudID)+"&view_status="+strViewStatus;
		<%}%>
	}
}
function FocusID() {
	if(document.fa_payment.amount)
		document.fa_payment.amount.focus();
	else
		document.fa_payment.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud_basic.jsp?opner_info=fa_payment.stud_id";
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

/*** this ajax is called for required downpayment update **/
function ajaxUpdateReqDP() {
	//if there is no change, just return here..
	if(document.fa_payment.reqd_dp_old.value == document.fa_payment.reqd_dp_per_stud.value)
		return;

	var strReqDP = document.fa_payment.reqd_dp_per_stud.value;
	if(strReqDP == '')  {
		alert("Please enter an amount. 0 amount is a valid entry as well.");
		return;
	}
	var strParam = "stud_ref="+document.fa_payment.stud_index.value+"&sy_from="+document.fa_payment.sy_from.value+
					"&semester="+document.fa_payment.semester.value+"&is_tempstud="+document.fa_payment.is_tempstud.value+
					"&req_dp="+strReqDP;
	var objCOAInput = document.getElementById("coa_info");
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=114&"+strParam;
	this.processRequest(strURL);
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
	<%if(!strSchoolCode.startsWith("CSA")) {%>
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
<body bgcolor="#8C9AAA" onLoad="FocusID();ShowHideCheckNO();">
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
Vector vMiscFeeInfo = null, vMiscFeeIndex = null; int iMiscFeeIndex = 0;//for PIT, i have to show check box for misc fee.
Vector vTemp = null;

double dReservationFee = 0d;//only for DBTC.

boolean bolIsPIT = strSchoolCode.startsWith("PIT");


double dTutionFee    = 0d; double dTotalPayable=0d;
double dCompLabFee   = 0d;
double dMiscFee      = 0d;
double dOutstanding  = 0d;
double dMiscOtherFee = 0d;//This is the misc fee other charges,

double dEnrollmentDiscount = 0d; //this sum of full payment, early enrollment or late enrollment discount/fine implementations.
String strEnrolmentDiscDetail = null;
double dPayableAfterDiscount = 0d;


		//apply must pay minimum required d/p for vmuf..
		double dReqdDP = 0d;
		String strReqDPMsg = null;
		boolean bolIsVMUF = strSchoolCode.startsWith("VMUF");



FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
Advising advising = new Advising();
paymentUtil.setIsBasic(true);
fOperation.setIsBasic(true);
if(WI.fillTextValue("updateNationality").compareTo("1") ==0){
	//I have to change the nationality status.
	boolean bolIsForeignStud = false;
	boolean bolIsTempStud    = false;
	enrollment.StudentInformation studInfo = new enrollment.StudentInformation();
	if(WI.fillTextValue("is_tempstud").compareTo("1") == 0)//temp stud.
		bolIsTempStud = true;
	if(WI.fillTextValue("is_alien").compareTo("0") ==0)//change status to alien
		bolIsForeignStud  = true;
	if(!studInfo.changeForeignStat(dbOP, WI.fillTextValue("stud_index"),bolIsTempStud,bolIsForeignStud,null))//only called to change status to 0
		strErrMsg = studInfo.getErrMsg();

}

strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") ==0) {
	if(bolIsVMUF && WI.fillTextValue("reqd_dp").length() > 0) {
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
			if(bolIsPIT)
				faPayment.saveMiscPmtDuringDP(dbOP, request, request.getParameter("or_number"));

			//if(!bolIsVMUF && !strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("CLDH") &&
			//		!strSchoolCode.startsWith("CPU") && !strSchoolCode.startsWith("UI")) {
			if(strSchoolCode.startsWith("LNU")) {
				dbOP.cleanUP();
				//response.sendRedirect(response.encodeRedirectURL("./assessedfees_print_basic.jsp?view_status=0&stud_id="+request.getParameter("stud_id")));
				response.sendRedirect(response.encodeRedirectURL("./payment_prior_enrolment_print_basic.jsp?or_number="+request.getParameter("or_number")));
			}
			else {
				//if((strSchoolCode.startsWith("CPU") || strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("UI")) && request.getParameter("stud_id") != null) {
					//student should be validated.
				if(!strSchoolCode.startsWith("VMUF") && !strSchoolCode.startsWith("DBTC")  && !strSchoolCode.startsWith("SWU")  &&
							request.getParameter("stud_id") != null && request.getParameter("stud_id").length() > 0) {
					if(dbOP.mapUIDToUIndex(request.getParameter("stud_id")) != null) {//old student.
						enrollment.RegAssignID regAssignID = new enrollment.RegAssignID();
						if(!regAssignID.confirmOldStudEnrollment(dbOP, request.getParameter("stud_id"),(String)request.getSession(false).getAttribute("userId")))
							strErrMsg = regAssignID.getErrMsg();
					}
					else {//temp student.
						enrollment.RegAssignID regAssignID = new enrollment.RegAssignID();
						if(regAssignID.confirmTempStudEnrollment(dbOP, request.getParameter("stud_id"),(String)request.getSession(false).getAttribute("userId")) == null)
							strErrMsg = regAssignID.getErrMsg();
					}
				}
				dbOP.cleanUP();
				String strSukli = WI.fillTextValue("sukli");
				if(strSukli.length() > 0) {
					//keep change in attribute.
					double dAmtReceived = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""));
					dAmtReceived = dAmtReceived - Double.parseDouble(WI.fillTextValue("amount"));
					strSukli = "&sukli="+ CommonUtil.formatFloat(dAmtReceived,true);
				}

				response.sendRedirect(response.encodeRedirectURL("./payment_prior_enrolment_print_basic.jsp?or_number="+request.getParameter("or_number")+strSukli));
			}
			return;
		}
		else
			strErrMsg = faPayment.getErrMsg();
	}//added this condition for vmuf.. only if amount paid is >= required d/p.
}

vStudInfo = advising.getStudInfo(dbOP,request.getParameter("stud_id"));
if(vStudInfo == null) strErrMsg = advising.getErrMsg();
else
{
	if(vStudInfo.elementAt(7) != null) {//course index is null, forward this ID to basic..
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./assessedfees.jsp?stud_id="+request.getParameter("stud_id") ));
		return;
	}

	astrSchYrInfo[0]=(String)vStudInfo.elementAt(16);//take sy from/to/sem from student registration information.
	astrSchYrInfo[1]=(String)vStudInfo.elementAt(17);
	astrSchYrInfo[2]=(String)vStudInfo.elementAt(18);

	paymentUtil.setTempUser((String)vStudInfo.elementAt(10));
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),"0",null,(String)vStudInfo.elementAt(6),
        astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	//if(vMiscFeeInfo == null)
	//	strErrMsg = paymentUtil.getErrMsg();
	//else
	//	vMiscFeeIndex = paymentUtil.vMiscFeeIndex;
	if(vMiscFeeIndex == null)
		vMiscFeeIndex = new Vector();
	if(vMiscFeeInfo == null)
		vMiscFeeInfo = new Vector();

//check if first payment is already paid, if so, take to view/print instead of displaying all information detail.
	if(strErrMsg == null)
	{
		if(faPayment.isFirstPmtDuringEnrlPaid(dbOP,(String)vStudInfo.elementAt(0),
												astrSchYrInfo[0],astrSchYrInfo[1],
												(String)vStudInfo.elementAt(6),astrSchYrInfo[2],
												paymentUtil.isTempStudInStr()) )
		{
			strErrMsg = faPayment.getErrMsg();
		}
	}
}
if(strErrMsg == null) {//collect fee details here.
	//here is the extra condition applied for VMUF... for vmuf, student can't pay less than required d/p..
	//and there is no exception..
		if(bolIsVMUF) {
			enrollment.FAStudMinReqDP faMinDP = new enrollment.FAStudMinReqDP(null);
			faMinDP.bolIsBasic = true;
			dReqdDP = faMinDP.getPayableDownPayment(dbOP, request.getParameter("stud_id"), astrSchYrInfo[0], astrSchYrInfo[1],astrSchYrInfo[2], strSchoolCode, 1,
								(String)vStudInfo.elementAt(0), paymentUtil.isTempStud());
			if(dReqdDP == 0d)
				strReqDPMsg = "Min required downpayment is not set. Please set minimum required d/p.";
			else
				strReqDPMsg = "Student must pay minimum downpayment: "+CommonUtil.formatFloat(dReqdDP, true);
		}

	dTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);


	if(dTutionFee > 0)
	{
		dMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		dCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
							astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);

		dOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));

		dMiscOtherFee = fOperation.getMiscOtherFee();

		boolean bolIsFullPmt = false;
		if(WI.fillTextValue("payment_mode").equals("0"))
			bolIsFullPmt = true;

		if(WI.fillTextValue("date_of_payment").length() > 0) {
			enrollment.FAFeeOperationDiscountEnrollment test = new enrollment.FAFeeOperationDiscountEnrollment(bolIsFullPmt,
																			WI.fillTextValue("date_of_payment"));
			test.setIsBasic(true);

			vTemp = test.calEnrollmentDateDiscount(dbOP, (float) dTutionFee,(float) (dTutionFee+dMiscFee+dCompLabFee),
													(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
													astrSchYrInfo[0],astrSchYrInfo[1],
													(String)vStudInfo.elementAt(6),astrSchYrInfo[2],
													fOperation.dReqSubAmt);


			if(vTemp != null && vTemp.size() > 0)
				strEnrolmentDiscDetail = (String)vTemp.elementAt(0);
			if(strEnrolmentDiscDetail != null && bolIsFullPmt)
			{
				dEnrollmentDiscount = ((Float)vTemp.elementAt(1)).doubleValue();
				dPayableAfterDiscount = dTutionFee+dMiscFee+dCompLabFee+dOutstanding-dEnrollmentDiscount;
			}
			else if(bolIsFullPmt)
				dPayableAfterDiscount = dTutionFee+dMiscFee+dCompLabFee+dOutstanding;
		}
		//get here reservation fee this is for DBTC>.
		if(strSchoolCode.startsWith("DBTC")) {
			dReservationFee = paymentUtil.getReservationFeeCGH(dbOP, (String)vStudInfo.elementAt(0),
								astrSchYrInfo[0], astrSchYrInfo[1],	astrSchYrInfo[2],paymentUtil.isTempStud());
		}
	}
	else
		strErrMsg = fOperation.getErrMsg();
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

	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");//Other charges.
	}
}//System.out.println(fOperation.getReqSubFeeDtls());


////////////// addl for AUF
Vector vOthAssessmentSetting = null;
if(vStudInfo != null && vStudInfo.size() > 0 && astrSchYrInfo != null){
	request.setAttribute("sy_from",astrSchYrInfo[0]);
	request.setAttribute("sy_to",astrSchYrInfo[1]);
	request.setAttribute("semester",astrSchYrInfo[2]);
	vOthAssessmentSetting = new enrollment.FAFeeOptional().operateOnAddlAssessementSetting(dbOP, request, 7);
}


boolean bolIsICA = false;
String strSQLQuery = "select info5 from sys_info";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && strSQLQuery.equals("ICA"))
	bolIsICA = true;

boolean bolIsCCPmtAllowed = false;
if(strSchoolCode.startsWith("PWC"))
	bolIsCCPmtAllowed = true;

if(vMiscFeeInfo == null)
	vMiscFeeInfo = new Vector();
%>
<form name="fa_payment" action="./assessedfees_basic.jsp" method="post" onSubmit="return ReturnValidate();">
 <input type="hidden" name="focus_id">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#697A8F">
      <td height="25" align="center"><font color="#FFFFFF"><strong>::::
        PAYMENT OF ASSESSED FEES PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3">
	  <%=WI.getStrValue(strErrMsg)%></font>
	  </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">Enter Student ID </td>
      <td width="18%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event, '0');">      </td>
      <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="28%">
	  <a href="#">
	  	<img src="../../../images/form_proceed.gif" onClick="ReloadPage()" border="0">
	  </a>
	  </td>
      <td width="29%">
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
                  	strTemp += "<br>Collection :: "+WI.getStrValue(vTempCO.elementAt(3), "0.00");
                  %>
              <strong><%=strTemp%><%=strCurrencyInfo%></strong> </td>
          </tr>
		  </table>
	   <%}//only if cutoff time is set.
}	   %>	  </td>
    </tr>
    <tr>
      <td height="25"></td>
      <td colspan="3" height="25"><label id="coa_info"></label></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date of payment</td>
      <td height="25" colspan="3">
<%
strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%> <input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%if(!bolIsDatePaidReadonly) {%>
        <a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
<%}%>
		</td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3" height="25"><hr size="1">
        <!-- enter here all hidden fields for student. -->
        <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
        <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(6)%>">
        <input type="hidden" name="semester" value="<%=astrSchYrInfo[2]%>"> <input type="hidden" name="sy_from" value="<%=astrSchYrInfo[0]%>">
        <input type="hidden" name="sy_to" value="<%=astrSchYrInfo[1]%>"> <input type="hidden" name="is_tempstud" value="<%=paymentUtil.isTempStudInStr()%>">
      </td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="47%" height="25">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%>
      </strong></td>
      <td width="51%" height="25" style="font-weight:bold; color:#FF0000; font-size:14px;">
	  <%if(strSchoolCode.startsWith("DBTC")) {
	  	strTemp = "select REQ_DP from FA_STUD_MIN_REQ_DP_PER_STUD where stud_index = "+vStudInfo.elementAt(0)+" and IS_TEMP_STUD="+paymentUtil.isTempStudInStr()+
			" and sy_From = "+astrSchYrInfo[0]+  " and semester = "+astrSchYrInfo[2];
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp== null)
			strTemp = "";
		else
			strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp, false), ",","");
	  %>
  	  Required Downpayment :
	  <input type="text" name="reqd_dp_per_stud" value="<%=strTemp%>" class="textbox_bigfont" size="5" onKeyUp="AllowOnlyInteger('fa_payment','reqd_dp_per_stud');"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="ajaxUpdateReqDP();style.backgroundColor='white'">
	  <input type="hidden" name="reqd_dp_old" value="<%=strTemp%>">
	  <%}%><label id="coa_info" style="font-size:9px; font-weight:bold"></label>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Enrolling yr level :<strong><%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(6),"0")))%></strong>
      </td>
      <td height="25">&nbsp; </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">School Year/Term : <strong><%=astrSchYrInfo[0]%>
        - <%=astrSchYrInfo[1]%>
		<%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%></strong>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Foreign Student : <font color="#9900FF"><strong>
        <%
enrollment.CourseRequirement CR = new enrollment.CourseRequirement();
boolean bolIsAlienNationality = CR.isForeignNational(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud());
if(bolIsAlienNationality)
	strTemp = "1";
else
	strTemp = "0";

	  if(bolIsAlienNationality){%>
        YES <%=WI.getStrValue(CR.getStudNationality(),"(",")","")%><input type="hidden" name="is_alien" value="1">
        <%}else{%>
        NO <input type="hidden" name="is_alien" value="0">
        <%}%>
        </strong></font></td>
      <td height="25">
	  <a href='javascript:UpdateNationality("<%=WI.fillTextValue("stud_id")%>","<%=(String)vStudInfo.elementAt(0)%>",
	  "<%=paymentUtil.isTempStudInStr()%>");'><img src="../../../images/update.gif" border="0"></a>
	  	<font size="1">Click to change foreign nationality status</font></td>
    </tr>
<%if(bolIsVMUF && strReqDPMsg != null) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" style="font-size:11px; font-weight:bold; color:#FF0000"><%=strReqDPMsg%></td>
    </tr>
<%}%>
  </table>
<%}//if student info is not null
if(dTutionFee > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#BEDAC1">
      <td width="58%" height="25" colspan="9" align="center">STUDENT ASSESSMENT</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="41%" align="center" bgcolor="#D2D6C0" style="font-size:9px;font-weight:bold">:: FEE DETAILS ::</td>
      <td width="59%" height="25" align="center" bgcolor="#E9EADF" style="font-size:9px;font-weight:bold">:: PAYMENT DETAILS ::</td>
    </tr>
    <tr>
      <td align="center" bgcolor="#D2D6C0" valign="top"><table width="95%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td height="20" colspan="2"><font size="1"><strong>TUITION FEE :<font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%> </font></strong></font></td>
          <td width="29%" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dTutionFee,true)%></strong></font></td>
          <td width="5%">&nbsp;</td>
        </tr>
        <% if (!strSchoolCode.startsWith("CPU")){%>
        <tr>
          <td height="20" colspan="2"><font size="1">COMP. LAB. FEE : </font></td>
          <td align="right"><font size="1"><strong><%=dCompLabFee%> </strong></font></td>
          <td>&nbsp;</td>
        </tr>
        <%}%>
        <tr>
          <td height="20" colspan="4"><font size="1">MISCELLANEOUS FEES</font></td>
        </tr>
        <%
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).equals("1"))
				continue;
		%>
        <tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
          <td width="3%" height="20">
		  <%if(bolIsPIT && vMiscFeeIndex.size() > 0){
			  while(vMiscFeeIndex.size() > 0) {
				if(vMiscFeeIndex.elementAt(1).equals("1")) {
					vMiscFeeIndex.remove(0);vMiscFeeIndex.remove(0);
					continue;
				}
				break;
			  }%>
			  <input type="checkbox" name="_<%=iMiscFeeIndex%>" checked value="<%=vMiscFeeIndex.remove(0)%>" onClick="UpdateMiscFeePmt(document.fa_payment._<%=iMiscFeeIndex%>, '<%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true),",","")%>');">
			  <input type="hidden" name="__<%=iMiscFeeIndex++%>" value="<%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true),",","")%>">

		  <%vMiscFeeIndex.remove(0);}%>
		  </td>
          <td width="63%"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="20" align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%> </font></td>
          <td>&nbsp;</td>
        </tr>
        <%}%>
		<input type="hidden" name="max_disp_misc" value="<%=iMiscFeeIndex%>">
        <tr>
          <td height="20">&nbsp;</td>
          <td><font size="1"><strong>TOTAL MISC :</strong></font></td>
          <td height="20" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dMiscFee - dMiscOtherFee,true)%> </strong></font></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" colspan="2"><font size="1">OTHER CHARGES</font></td>
          <td height="20">&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <%
		if (vMiscFeeInfo!= null)
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).equals("0"))
				continue;
		%>
        <tr>
          <td height="20">&nbsp;</td>
          <td height="20"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="20" align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></td>
          <td>&nbsp;</td>
        </tr>
        <%}%>
        <tr>
          <td height="20">&nbsp;</td>
          <td height="20"><font size="1"><strong>OTHER CHARGE :</strong></font></td>
          <td height="20" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dMiscOtherFee,true)%> </strong></font></td>
          <td>&nbsp;</td>
        </tr>
        <% if (!strSchoolCode.startsWith("CPU")) {%>
        <tr>
          <td height="20" colspan="4"><hr size="1"></td>
        </tr>
        <tr>
          <td height="20" colspan="2"><font size="1"><strong>TOTAL TUITION FEE
            : </strong></font></td>
          <td height="20" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dTutionFee+dCompLabFee+dMiscFee,true)%> </strong></font></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" colspan="2"><font size="1"><strong>OLD ACCOUNT :</strong></font></td>
          <td height="20" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dOutstanding,true)%></strong></font></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" colspan="2"><font size="1"><strong>TOTAL AMOUNT DUE
            :</strong></font></td>
          <td height="20" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dTutionFee+dCompLabFee+dMiscFee + dOutstanding - dEnrollmentDiscount,true)%></strong></font></td>
          <td>&nbsp;</td>
        </tr>
        <% } // end do not show for CPU
if(strSchoolCode.startsWith("CGH") || strSchoolCode.startsWith("UDMC") || strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("DBTC")){
 dTotalPayable = dTutionFee+dCompLabFee+dMiscFee + dOutstanding - dEnrollmentDiscount - dReservationFee;
%>
        <tr>
          <td height="20" colspan="2">&nbsp;
 <%if(dTotalPayable > 0d){%> <font size="1"><strong>LESS RESERVATION FEE
        :</strong></font> <%}%>		  </td>
          <td height="20" align="right"><%if(dTotalPayable > 0d){%>
            <%=CommonUtil.formatFloat(dReservationFee,true)%>
            <%}%></td>
          <td>&nbsp;</td>
        </tr>
        <%}%>
      </table></td>
      <td height="31" align="center" bgcolor="#E9EADF" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="21%" height="20"><font size="1">PAYMENT MODE </font></td>
          <td width="79%"><font size="1"><strong>
            <select name="payment_mode" onChange="ShowHideApprovalNo();">
              <option value="1">Installment</option>
              <%
strTemp = request.getParameter("payment_mode");
if(strTemp == null && vOthAssessmentSetting != null && vOthAssessmentSetting.size() > 0)
	strTemp = (String)vOthAssessmentSetting.elementAt(1);
if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("0") ==0){%>
              <option value="0" selected>Full</option>
<%}else{%>
              <option value="0">Full</option>
<%}%>
            </select>
          </strong></font></td>
        </tr>
<%if(false && strSchoolCode.startsWith("CSA")) {%>
        <tr>
          <td height="20" colspan="2">
			<div id="change_div" style="visibility:hidden">
				<table cellpadding="0" cellspacing="0">
					<td style="font-size:18px;">Change: &nbsp;</td>
					<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
				</table>
			</div>		  </td>
          </tr>
<%}%>
    <tr>
		<td colspan="2">
			<div id="change_div">
			<table cellpadding="0" cellspacing="0">
      			<td style="font-size:18px;">Change: &nbsp;</td>
      			<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
			</table>
		</div>
		</td>
    </tr>
        <tr>
          <td height="20"><font size="1">AMOUNT PAID </font></td>
          <td><font size="1"><strong>
<%
//System.out.println(dPayableAfterDiscount);
//System.out.println(dReservationFee);
//System.out.println(vOthAssessmentSetting);

 if(dPayableAfterDiscount > 0f){%>
            <%//=CommonUtil.formatFloat(dPayableAfterDiscount,true)%>
            <!-- <input type="hidden" name="amount" value="<%=dPayableAfterDiscount%>"> -->
<%strTemp = CommonUtil.formatFloat((dPayableAfterDiscount - dReservationFee),true);
strTemp = ConversionTable.replaceString(strTemp,",","");
if(vOthAssessmentSetting != null && vOthAssessmentSetting.size() > 0
	&& request.getParameter("amount") == null && vOthAssessmentSetting.elementAt(3) != null)
	strTemp = (String)vOthAssessmentSetting.elementAt(3);
%>
            <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();MoveNext(event, '_1')" autocomplete="off">
            <%}else{
			  //for vmuf, must pay d/p..
			  strTemp = WI.fillTextValue("amount");
			  if(bolIsVMUF && dReqdDP > 0d) {
					double dReqdPmt = dTutionFee+dCompLabFee+dMiscFee + dOutstanding - dEnrollmentDiscount;
					if(dReqdDP > dReqdPmt)
						dReqdDP = dReqdPmt;
					if(dReqdPmt <=0d || dReqdDP <0)
						dReqdDP = 0;

					if(dReqdDP > 0d) {
						strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(dReqdDP,true),",","");
						dReqdDP = Double.parseDouble(strTemp);
					}
			  }
			  if(bolIsPIT) //payment equals to misc fee..
			  	strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(dMiscFee - dMiscOtherFee,true),",","");
			%>
            <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" onKeyUp="AjaxUpdateChange();MoveNext(event, '_1')" autocomplete="off">
            <%}%>
            Php </strong></font>

</td>
          <script language="javascript">
	document.fa_payment.focus_id.value = "2";
      </script>
        </tr>
        <tr>
          <td height="20"><font size="1">Amount Tendered</font></td>
          <td>
	  		<input name="amount_tendered" type="text" size="16" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();MoveNext(event, '_2')" id="_1" autocomplete="off">
		  </td>
        </tr>
<%if(strEnrolmentDiscDetail != null && !bolIsCPU){%>
        <tr>
          <td height="20" colspan="2"><font size="1" color="#0000FF"><b>
            <label id="full_pmt_discount"><%=strEnrolmentDiscDetail%></label>
          </b></font>&nbsp;</td>
        </tr>
<%}%>
        <input type="hidden" name="pmt_receive_type" value="Internal">
        <tr>
          <td height="20"><font size="1">PAYMENT TYPE</font></td>
          <td height="20"><select name="payment_type" onChange="ShowHideCheckNO();">
              <option value="0">Cash</option>
              <%
strTemp = WI.fillTextValue("payment_type");
if(strTemp.compareTo("1") ==0){%>
              <option value="1" selected>Check</option>
              <%}else{%>
              <option value="1">Check</option>
              <%}
			  if(strTemp.equals("5")){%>
              <option value="5" selected>Cash and check</option>
              <%}else{%>
              <option value="5">Cash and check</option>
              <%}
			  	if (!bolIsCPU) {
					if(strTemp.equals("2")){%>
              <option value="2" selected>Salary deduction</option>
              <%}else{%>
              <option value="2">Salary deduction</option>
              <%}
			  	} // remove salary deduction from CPU
			  if(strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("CSA") || bolIsCCPmtAllowed){
if(strTemp.equals("6"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
              <option value="6" <%=strErrMsg%>>Credit Card</option>
              <%
if(strTemp.equals("7"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
              <option value="7" <%=strErrMsg%>>E-Pay</option>
              <%}//show credit card for AUF only.. %>
            </select>          </td>
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
          <td height="20"><%
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
                <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH",
		" from FA_BANK_LIST where is_valid = 1 order by bank_code", request.getParameter("CHECK_FR_BANK_INDEX"), false)%>
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
          <td height="20" colspan="2" id="credit_card_info"><table class="thinborder" cellpadding="0" cellspacing="0" width="100%" bgcolor="#bbbbbb">
              <tr>
                <td width="30%" class="thinborder">Card Type : </td>
                <td width="70%" class="thinborder"><select name="card_type_index" style="font-size:11px;">
                    <%=dbOP.loadCombo("card_type_index","CARD_TYPE"," from CCARD_TYPE where IS_ACTIVE=1 order by CARD_TYPE asc", request.getParameter("card_type_index"), false)%>
                  </select>                </td>
              </tr>
              <tr>
                <td class="thinborder">Issuing Bank : </td>
                <td class="thinborder"><select name="bank_ref" style="font-size:11px;">
                    <%=dbOP.loadCombo("AUTH_BANK_INDEX","BANK_NAME_"," from CCARD_AUTHORIZED_BANK where IS_ACTIVE=1 order by BANK_NAME_ asc", request.getParameter("bank_ref"), false)%>
                  </select>                </td>
              </tr>
              <tr>
                <td class="thinborder">Receipt Refrence :</td>
                <td class="thinborder"><input type="text" name="ccard_auth_code" value="<%=WI.fillTextValue("ccard_auth_code")%>" size="16" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;">                </td>
              </tr>
              <tr>
                <td colspan="2" class="thinborder" style="font-weight:bold">NOTE : No Full Payment discount.
                  <label id="show_processingfee_note"></label>                </td>
              </tr>
          </table></td>
        </tr>
      </table></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td colspan="9"><hr size="1"></td>
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
<%} //end of display if vMisFee is not null
%>
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
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>

 <input type="hidden" name="addRecord" value="0">
 <input type="hidden" name="payment_for" value="0">
 <input type="hidden" name="view_status" value="<%=WI.fillTextValue("view_status")%>">
 <input type="hidden" name="updateNationality">

 <input type="hidden" name="sukli">
 <input type="hidden" name="reqd_dp" value="<%=dReqdDP%>">

 <input type="hidden" name="prev_id" value="<%=WI.fillTextValue("stud_id")%>">

<!--
<input type="hidden" name="amount_tendered" value="">
-->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
