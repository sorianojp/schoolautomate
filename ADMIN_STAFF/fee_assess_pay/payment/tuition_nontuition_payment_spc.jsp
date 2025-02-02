<%@ page language="java" import="utility.*,enrollment.CheckPayment, enrollment.FAAssessment,enrollment.FAPaymentUtil,enrollment.FAPayment,java.util.Vector" buffer="16kb" %>
<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";
	//strSchoolCode = "CIT";
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	WebInterface WI = new WebInterface(request);
	java.sql.ResultSet rs = null;


//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Installment fees","tuition_nontuition_payment_spc.jsp");
	}
	catch(Exception exp) {
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
			response.sendRedirect("./tuition_nontuition_payment_spc.jsp?stud_id="+dbOP.strBarcodeID);
			return;
		}
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
															"tuition_nontuition_payment_spc.jsp");
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
	rs = dbOP.executeQuery(strTemp);
	rs.next();
	strProcessingFee = Double.toString(rs.getDouble(1)/100)+"%";
	if(rs.getInt(2) > 0)
		strProcessingFee += " or Min of "+rs.getString(2);
 }

	int iListCount = 0;

Vector vStudInfo = new Vector();
Vector vScheduledPmt = new Vector(); Vector vScheduledPmtNew = null;

FAAssessment FA = new FAAssessment();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
//FA.setIsBasic(true);
//pmtUtil.setIsBasic(true);

CheckPayment chkPmt = new CheckPayment();
strTemp = WI.fillTextValue("addRecord");
vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
//System.out.println(vStudInfo);
if(vStudInfo == null) {
	pmtUtil.setIsBasic(true);
	vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
	if(vStudInfo != null) {
		dbOP.cleanUP();
		%>
			<jsp:forward page="./install_assessed_fees_payment_bas.jsp" />
		<%

	}
}

if(strTemp != null && strTemp.compareTo("1") ==0) {
	if(!pmtUtil.isORIssuedToTeller(dbOP, request.getParameter("or_number"), (String)request.getSession(false).getAttribute("userIndex"), strSchoolCode))
		strErrMsg = pmtUtil.getErrMsg();
	else if(faPayment.savePayment(dbOP,request,false))
	{
		//post late fee if there is any..
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./install_assessed_fees_print_receipt.jsp?view_status=0&or_number="+request.getParameter("or_number")));
		return;
	}
	else
		strErrMsg = faPayment.getErrMsg();
}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Installment Fees</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
  /*this is what we want the div to look like*/
  div.processing{
    display:block;
    /*set the div in the bottom right corner*/
    position:absolute;
    right:7;
	top:10;
    width:300px;
	height:150;/** it expands on its own.. **/
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/formatFloat.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax2.js"></script>
<script language="JavaScript">
function navRollOver(obj, state) {
  //document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
function ShowHideCheckNO() {
	if(!document.fa_payment.payment_type)
		return;
	var iPaymentTypeSelected = document.fa_payment.payment_type.selectedIndex;

	if(iPaymentTypeSelected == 1 || iPaymentTypeSelected == 3) {
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
	if(document.fa_payment.payment_type.selectedIndex == 3)
		showLayer('myADTable1');
	else
		hideLayer('myADTable1');
	document.fa_payment.chk_amt.value = "";
	document.fa_payment.cash_amt.value = "";

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
function ResetPageAction() {
	document.fa_payment.addRecord.value = "";
	document.fa_payment.submit();
}
function AddRecord() {
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

	document.fa_payment.submit();
}
function FocusID() {
	if(document.fa_payment.amount_shown.value == "1") {
		if(document.fa_payment.tuition_amt.value == '')
			document.fa_payment.tuition_amt.focus();
		else
			document.fa_payment._fake.focus();
	}
		//document.fa_payment.tuition_amt.focus();
	else
		document.fa_payment.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=fa_payment.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearchFaculty() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=fa_payment.cash_adv_from_emp_id";
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
	
	document.fa_payment.cash_amt.value = roundOffFloat(cashAmt, 2, true);//eval(cashAmt);
}
function ViewCheckPmtDtls(strID, strSYFr, strSYTo, strSem)
{
	var pgLoc = "./view_check_payments.jsp?stud_id="+strID+"&sy_from="+strSYFr+"&sy_to="+strSYTo+"&semester="+strSem;
	var win=window.open(pgLoc,"PrintWindow",'width=640,height=480,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function GoToBasic() {
	location = "./install_assessed_fees_payment_bas.jsp";
}

//// - all about ajax..
function AjaxMapName(e, strPos) {
		if(e.keyCode == 13) {
			this.ResetPageAction();
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
	if(strAmtPaid.length == 0 || strAmtTendered.length == 0) {
		document.getElementById("change_").innerHTML = "";
		return;
	}

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

function UpdatePaymentInfo() {
	if(document.fa_payment.fee_index.value.length == 0) 
		return;
		
	if(true)
		return AjaxUpdatePaymentInfo();
		
		
	var obj = '';

	document.fa_payment.amount.value = '';
	//document.fa_payment.pmt_desc.value = '';
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

		totalAmt = totalAmt + eval(dAmt);

		eval('obj=document.fa_payment.fee_name'+i);
		if(strPmtDesc == '')
			strPmtDesc = obj.value+": "+roundOffFloat(totalAmt, 2, true);//formatFloat(dAmt,1);
		else
			strPmtDesc = strPmtDesc+"<br>\r\n"+obj.value+": "+roundOffFloat(totalAmt, 2, true);//formatFloat(dAmt,1);
	}
		document.getElementById("oc_detail").innerHTML = strPmtDesc;
		//alert(strPmtDesc);

		var dTuition = document.fa_payment.tuition_amt.value;
		if(dTuition == '')
			dTuition = 0.0;
		totalAmt = totalAmt + eval(dTuition);
		//document.fa_payment.amount.value = formatFloat(totalAmt, 1);
		document.fa_payment.amount.value = roundOffFloat(totalAmt, 2, true);
		

}
function AjaxUpdatePaymentInfo() {
	var obj = '';
	document.fa_payment.amount.value = '';

	var iMaxDisp = document.fa_payment.list_count.value;
	if(iMaxDisp.length == 0 || iMaxDisp == 0)
		return;
	var totalAmt = 0; var strPmtDesc = "";
	var dAmt = 0; var iNoOfUnits;
	
	var strAmtPaid = "";
	for(i = 0; i < iMaxDisp; ++i) {
		eval('obj=document.fa_payment.fee_i'+i);
		if(!obj.checked)
			continue;

		eval('obj=document.fa_payment.fee_amt'+i);

		if(strAmtPaid.length == 0)
			strAmtPaid = obj.value;
		else	
			strAmtPaid = strAmtPaid + "_"+obj.value;


		totalAmt = eval(obj.value);

		eval('obj=document.fa_payment.fee_name'+i);
		if(strPmtDesc == '')
			strPmtDesc = obj.value+": "+roundOffFloat(totalAmt, 2, true);//formatFloat(dAmt,1);
		else
			strPmtDesc = strPmtDesc+"<br>\r\n"+obj.value+": "+roundOffFloat(totalAmt, 2, true);//formatFloat(dAmt,1);
	}
		document.getElementById("oc_detail").innerHTML = strPmtDesc;
		//alert(strPmtDesc);

		var dTuition = document.fa_payment.tuition_amt.value;
		if(dTuition == '')
			dTuition = 0.0;
		
		if(strAmtPaid.length == 0)
			strAmtPaid = dTuition;
		else	
			strAmtPaid = strAmtPaid + "_"+dTuition;


	var objCOAInput = document.fa_payment.amount;
	this.InitXmlHttpObject(objCOAInput, 1);//I want to get value in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=150&input="+strAmtPaid;
	this.processRequest(strURL);
}
function FilterOCList(e) {
	if(e.keyCode == 13) {
			this.ResetPageAction();
			return;
	}
}
function GoToLedger() {
	var strLoc = "../student_ledger/student_ledger.jsp";
	<%if(vStudInfo != null && vStudInfo.size() > 0) {%>
		strLoc += "?stud_id=<%=request.getParameter("stud_id")%>&sy_from=<%=(String)vStudInfo.elementAt(8)%>&sy_to=<%=(String)vStudInfo.elementAt(9)%>&semester=<%=(String)vStudInfo.elementAt(5)%>";
	<%}%>
	location = strLoc;
}
function AjaxFormatAmount() {
	var strAmtPaid     = document.fa_payment.tuition_amt.value;

	var objCOAInput = document.getElementById("format_amt");
	this.InitXmlHttpObject3(objCOAInput, 2);//I want to get value in this.retObj
	if(this.xmlHttp2 == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=153&show_=0&amt_="+strAmtPaid;
	this.processRequest2(strURL);
}

/////// additional code starts from here.
function ChangeFeeType()
{
	var iSelected = document.fa_payment.fee_type.selectedIndex;
	var strAmt;
	eval('strAmt = document.fa_payment.fee_type_amt_'+iSelected+'.value');
	document.fa_payment.fee_amount_.value = strAmt;
	//document.fa_payment.fee_amount_.select();
}
function AddFeeName()
{
	if(document.fa_payment.fee_type.selectedIndex == 0) {
		alert("Please select a fee");
		return;
	}
	document.fa_payment.add_fee.value = "1";
	document.fa_payment.list_count.value = ++document.fa_payment.list_count.value;
	if(document.fa_payment.fee_index.value.length > 0) {
		document.fa_payment.fee_index.value = document.fa_payment.fee_index.value+","+document.fa_payment.fee_type[document.fa_payment.fee_type.selectedIndex].value;
		document.fa_payment.fee_index_amt.value = document.fa_payment.fee_index_amt.value+"*"+document.fa_payment.fee_amount_.value;
	}
	else { 
		document.fa_payment.fee_index.value = document.fa_payment.fee_type[document.fa_payment.fee_type.selectedIndex].value;
		document.fa_payment.fee_index_amt.value = document.fa_payment.fee_amount_.value;
	}


	ReloadPage();
}
function RemoveFee(strIndex) {
	document.fa_payment.remove_fee_i.value = strIndex;
	document.fa_payment.submit();
}
function EnterPressed(e) {
	//alert("i m here.");
	if(e.keyCode == 13) {
		//AddFeeName();
	}
}

function HideLayerGroupFee(strDiv) {
	if(strDiv == '1')
		document.all.processing.style.visibility='hidden';	
}
function ShowLayerGroupFee(strDiv) {
	if(strDiv == '1')
		document.all.processing.style.visibility='visible';	
}
function AddGroupedFee() {
	document.fa_payment.add_group_fee.value = '1';
	document.fa_payment.submit();
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();UpdatePaymentInfo()">
<%
//for full pmt.
String strEnrolmentDiscDetail = null;
double dEnrollmentDiscount = 0d;
double dPayableAfterDiscount = 0d;
double dTotalAmtPaid =0d;

String strUserIndex = null;

enrollment.FAFeeOperation fOperation  = new enrollment.FAFeeOperation();
double dRefunded = 0d;//I have to consider refunded amout at the end of payment schedule.
if(vStudInfo != null) {
	dRefunded = fOperation.calRefundedAmount(dbOP, -1, (String)vStudInfo.elementAt(0),
						 (String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(9),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5), true);
	strUserIndex = (String)vStudInfo.elementAt(0);
}

double dFullPmtPayableAmt = 0d;
if(vStudInfo != null && WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") == 0) {
String[] astrSchYrInfo= {(String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(9),
						(String)vStudInfo.elementAt(5)};

/**
float fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
		float fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
		float fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
							astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
//		float fOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));
		float fOutstanding= fOperation.calOutStandingCurYr(dbOP, (String)vStudInfo.elementAt(0),
								astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);

		float fMiscOtherFee = fOperation.getMiscOtherFee();
		enrollment.FAFeeOperationDiscountEnrollment test =
	new enrollment.FAFeeOperationDiscountEnrollment(true,WI.getTodaysDate(4));
test.setForceFullPmt();
Vector vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,
(String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
			astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),
                        astrSchYrInfo[2],fOperation.dReqSubAmt);

	if(vTemp != null && vTemp.size() > 0)
		strEnrolmentDiscDetail = (String)vTemp.elementAt(0);
	if(strEnrolmentDiscDetail != null)
		dEnrollmentDiscount = ((Float)vTemp.elementAt(1)).floatValue();

	//I have to consider all the payment so far.
	dTotalAmtPaid =
			fOperation.calTotalAmoutPaid(dbOP, (String)vStudInfo.elementAt(0),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
System.out.println("fOutstanding : " +fOutstanding);
System.out.println("dEnrollmentDiscount : "+dTotalAmtPaid);
System.out.println("vTemp : "+vTemp);
**/
float fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
		float fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
		float fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
							astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);

		//dFullPmtPayableAmt= fOperation.calOutStandingCurYr(dbOP, (String)vStudInfo.elementAt(0),
		//						astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);

		float fMiscOtherFee = fOperation.getMiscOtherFee();
		enrollment.FAFeeOperationDiscountEnrollment test = new enrollment.FAFeeOperationDiscountEnrollment(true,WI.getTodaysDate(1));
		test.setForceFullPmt();
		Vector vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,  (String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
						astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6), astrSchYrInfo[2],fOperation.dReqSubAmt);

	if(vTemp != null && vTemp.size() > 0)
		strEnrolmentDiscDetail = (String)vTemp.elementAt(0);
	if(strEnrolmentDiscDetail != null) {
		dEnrollmentDiscount = ((Float)vTemp.elementAt(1)).doubleValue();

		//dFullPmtPayableAmt = dFullPmtPayableAmt - dEnrollmentDiscount;
	}

//System.out.println("dFullPmtPayableAmt : " +dFullPmtPayableAmt);
//System.out.println("dEnrollmentDiscount : "+dTotalAmtPaid);

}//end of additional code for full payment discount.

double dOutStandingBal = 0d;

if(vStudInfo == null || vStudInfo.size() == 0)
	strErrMsg = pmtUtil.getErrMsg();
else
{
dOutStandingBal = fOperation.calOutStandingOfPrevYearSem(dbOP,(String)vStudInfo.elementAt(0), true, true);

	//get scheduled payment information.
	vScheduledPmt =FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(8),
						(String)vStudInfo.elementAt(9),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5));

	if(!strSchoolCode.startsWith("CIT") && !strSchoolCode.startsWith("PHILCST")) {
		vScheduledPmtNew = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(8),
							(String)vStudInfo.elementAt(9),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5));
	}
	if(vScheduledPmtNew != null)
		dFullPmtPayableAmt = Double.parseDouble(ConversionTable.replaceString((String)vScheduledPmtNew.elementAt(6), ",",""));
	//System.out.println(FA.getInstallmentSchedulePerStudPerExamSch(dbOP,"3",(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(8),
	//					(String)vStudInfo.elementAt(9),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5)));

	//System.out.println("New2 : "+vScheduledPmtNew);
	//System.out.println("Old : "+vScheduledPmt);
if(vScheduledPmt == null || vScheduledPmt.size() ==0)
		strErrMsg = FA.getErrMsg();//System.out.println(FA.getErrMsg());
	else
		dPayableAfterDiscount = Float.parseFloat((vScheduledPmt.elementAt(0)).toString()) -
									dEnrollmentDiscount;
}

if(strErrMsg == null) strErrMsg = "";
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

String strPaymentForVal = (String)request.getSession(false).getAttribute("pmt_schedule");
//I have to get the next pmt schedule.
if(vStudInfo != null && vStudInfo.size() > 0) {
	if(!WI.fillTextValue("stud_id").equals(WI.fillTextValue("prev_id")) ) {
		strPaymentForVal = pmtUtil.getCurrentPmtSchedule(dbOP, (String)vStudInfo.elementAt(8), (String)vStudInfo.elementAt(5), false);
	}
}

if(strPaymentForVal == null) {// || !strPaymentForVal.equals(WI.getStrValue(WI.fillTextValue("pmt_schedule"),strPaymentForVal) )) {//only if a different value is selected, replace the session.
	strPaymentForVal = WI.fillTextValue("pmt_schedule");
	if(strPaymentForVal.length() > 0)
		request.getSession(false).setAttribute("pmt_schedule",strPaymentForVal);
}
//System.out.println(strPaymentForVal);

// added for CLDH .. i have to find if student is being advised.. if student has advising information
// i must give warning msg..

if(strSchoolCode.startsWith("CLDH") && vStudInfo != null) {
	strTemp = "select count(*) from enrl_final_cur_list as efc where efc.is_valid = 1 and efc.user_index = "+
		vStudInfo.elementAt(0)+" and not exists (select * from stud_curriculum_hist where is_valid = 1 and sy_from = efc.sy_from and "+
		"semester = efc.current_semester and user_index = efc.user_index) and IS_TEMP_STUD = 0";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null && !strTemp.equals("0")) {
		strErrMsg = "<font style='font-size:14px; color:#ff0000; font-weight:bold'>Student is enrolling, pls pay downpayment in Assessed Fees(Enrollment) /Downpayment (Student is advised) link. "+
		"<a href='./assessedfees.jsp?stud_id="+WI.fillTextValue("stud_id")+"'>Click here to go directly to the link.</a></font>";
		iAccessLevel = 0;
	}
}

/**
select sy_from, current_semester from enrl_final_cur_list as efc where efc.is_valid = 1 and efc.user_index =
(select user_index from user_Table where id_number = '044971')  and not exists (select * from stud_curriculum_hist where is_valid = 1 and
sy_from = efc.sy_from and semester = efc.current_semester and user_index = efc.user_index) and IS_TEMP_STUD = 0
**/

boolean bolIsNoDP = false;

//I have to check if studnet has no DP, in that case, i have to show the downpayment link..
String strSQLQuery = null;
if(vStudInfo != null && vStudInfo.size() > 0) {
	strSQLQuery = "select payment_index from fa_stud_payment where is_stud_temp = 0 and user_index = "+(String)vStudInfo.elementAt(0) +
						" and is_valid = 1 and sy_from = "+(String)vStudInfo.elementAt(8) +" and semester = "+(String)vStudInfo.elementAt(5)+" and pmt_sch_index = 0 and payment_for = 0 and not exists (select * from FA_CANCEL_OR where OR_NUMBER = fa_stud_payment.or_number) ";
	if(dbOP.getResultOfAQuery(strSQLQuery, 0) == null)
		bolIsNoDP = true;

}




///set here date field to read only upon request of school
//boolean bolIsDatePaidReadonly = false;
//if(strSchoolCode.startsWith("UC") || strSchoolCode.startsWith("EAC") || strSchoolCode.startsWith("FATIMA"))
//	bolIsDatePaidReadonly = true;
boolean bolIsDatePaidReadonly = comUtil.isPaymentDateReadOnly(dbOP, request);

boolean bolIsICA = false;
strSQLQuery = "select info5 from sys_info";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && strSQLQuery.equals("ICA"))
	bolIsICA = true;

boolean bolIsCCPmtAllowed = false;
if(strSchoolCode.startsWith("PWC"))
	bolIsCCPmtAllowed = true;

int iIndexOf = 0;
Vector vOCAddedIndex = new Vector();
Vector vOCAddedAmt   = new Vector();
if(WI.fillTextValue("fee_index").length() >0) {
	vOCAddedIndex = CommonUtil.convertCSVToVector(WI.fillTextValue("fee_index"), ",",true);
	vOCAddedAmt   = CommonUtil.convertCSVToVector(WI.fillTextValue("fee_index_amt"), "*",true);
	
	//System.out.println("Before: "+vOCAddedIndex);
	
	if(WI.fillTextValue("remove_fee_i").length() > 0) {
		iIndexOf  = vOCAddedIndex.indexOf(WI.fillTextValue("remove_fee_i"));
		if(iIndexOf > -1) {
			vOCAddedIndex.remove(iIndexOf);
			vOCAddedAmt.remove(iIndexOf);
		}
	}
}
if(WI.fillTextValue("add_group_fee").length() > 0) {
	strTemp = "";
	int iMaxDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_count_grouped"), "0"));
	
	for(int i = 1; i <= iMaxDisp; ++i) {
		if(WI.fillTextValue("_group_"+i).length() == 0) 
			continue;
			
		if(strTemp.length() == 0) 
			strTemp = "'"+WI.fillTextValue("_group_"+i)+"'";
		else	
			strTemp = strTemp +","+"'"+WI.fillTextValue("_group_"+i)+"'";
	}
	Vector vTempGroup = new Vector();
	if(strTemp.length() > 0) {
		strSQLQuery = "select othsch_fee_index,group_fee_amt,fee_name from FA_OTH_SCH_FEE_GROUP join fa_oth_sch_fee on (fee_name =fee_name_t) "+
		" where group_name in ("+strTemp+") and sy_index=(select sy_index from FA_SCHYR where sy_from="+(String)request.getSession(false).getAttribute("cur_sch_yr_from")+") and is_valid=1 and year_level=0";
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			if(vTempGroup.indexOf(rs.getString(3)) > -1)
				continue;
			vTempGroup.addElement(rs.getString(3));
				
			vOCAddedIndex.addElement(rs.getString(1));		
			vOCAddedAmt.addElement(rs.getString(2));		
		}
		rs.close();
	}
}
	//System.out.println(WI.fillTextValue("remove_fee_i"));
	//System.out.println("After: "+vOCAddedIndex);

String strFeeIndexList = WI.fillTextValue("fee_index");
String strFeeAmtList   = WI.fillTextValue("fee_index_amt");
//strTemp = WI.fillTextValue("remove_fee_i")
if(WI.fillTextValue("remove_fee_i").length() > 0 || WI.fillTextValue("add_group_fee").length() > 0) {
	strFeeIndexList = CommonUtil.convertVectorToCSV(vOCAddedIndex);
	
	strFeeAmtList = "";
	for(int i = 0; i < vOCAddedAmt.size(); ++i) {
		if(strFeeAmtList.length() > 0) 
			strFeeAmtList = strFeeAmtList +"*"+(String)vOCAddedAmt.elementAt(i);
		else
			strFeeAmtList = (String)vOCAddedAmt.elementAt(i);
	}
}



///I have to get the list of groups here. 
Vector vGroupDtls = new Vector();
Vector vGroupList = new Vector();
Vector vGroupList2 = new Vector();
int iGroupRef = 0;
strSQLQuery = "select group_name, fee_name_t from FA_OTH_SCH_FEE_GROUP order by group_name";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	if(vGroupList.indexOf(rs.getString(1)) == -1) {
		vGroupList.addElement(rs.getString(1));
		vGroupList2.addElement(rs.getString(1));
		vGroupList2.addElement(null);//fill up the position of fees from group.. 
	}
	
	vGroupDtls.addElement(rs.getString(1));
	vGroupDtls.addElement(rs.getString(2).toLowerCase());
}

%>

<form name="fa_payment" action="./tuition_nontuition_payment_spc.jsp" method="post">
<input type="hidden" name="amount_shown" value="0">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          TUITION-NON TUITION PAYMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong>
	  <div align="right">
		<a href="./tuition_nontuition_payment_external.jsp">Go to External Payment</a>	
	</div>
	  </td>
    </tr>
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 6);
else
	strTemp = null;
if(strTemp != null){%>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25" >&nbsp;</td>
      <td width="96%" class="thinborderALL" style="font-size:15px; color:#FFFF00; background-color:#7777aa"><%=strTemp%></td>
      <td width="2%" >&nbsp;</td>
    </tr>
<%}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
	  <%if (vStudInfo != null && vStudInfo.size() > 0){
		Vector vChkPmt = null;
		vChkPmt = chkPmt.getChkPaymentDtls(dbOP, WI.fillTextValue("stud_id"),(String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(5));
		//System.out.println((String)vStudInfo.elementAt(8)+" :: "+(String)vStudInfo.elementAt(5));
		//System.out.println(chkPmt.getErrMsg());
		if (vChkPmt!= null && vChkPmt.size()>0){
		if (vChkPmt.elementAt(0)!=null){%>
		<table width="90%" class="thinborderALL" cellpadding="0" cellspacing="0">
		<tr>
			<td>
			<%if (((String)vChkPmt.elementAt(0)).equals("0")){%>
			<font color="#FF0000" size="3"><strong>Having BLOCKED check
              payment</strong></font>
			<%} else {%>
			<font size="3">Having <strong><%=(String)vChkPmt.elementAt(0)%></strong> check payment(s)</font><%}%>
<a href='javascript:ViewCheckPmtDtls("<%=WI.fillTextValue("stud_id")%>","<%=(String)vStudInfo.elementAt(8)%>", "<%=(String)vStudInfo.elementAt(9)%>","<%=(String)vStudInfo.elementAt(5)%>");'><img src="../../../images/view.gif" border="0"></a>
              <font size="1">View Dtls</font></td>
		</tr>
		</table>
	  <%}}}%>	  </td>
      <td width="36%" height="25">
<%if(!bolIsICA && false) {%>
	  <%//get here cutoff time information.
	  Vector vTempCO = new enrollment.FADailyCashCollectionDtls().getCurrentCutoffStat(dbOP, (String)request.getSession(false).getAttribute("userId"));//System.out.println(vTempCO);
	  //I have to get currency rate..
	  String strCurrencyInfo = new locker.Currency().getLatestCurrencyRate(dbOP);
	  if(vTempCO != null){%> <table width="90%" class="thinborderALL" cellpadding="0" cellspacing="0">
          <tr>
            <td height="20" align="right"> <%
		  strTemp = "Time :: "+(String)vTempCO.elementAt(0);
		  if(vTempCO.elementAt(1) != null) {//cut off time is set.
		  	if( ((String)vTempCO.elementAt(2)).compareTo("1") == 0)
				strTemp += "<br><font color=red>Cut off :: "+(String)vTempCO.elementAt(1)+"</font>";
			else
				strTemp += "<br>Cut off :: "+(String)vTempCO.elementAt(1);
		  }
                  if(vTempCO.elementAt(2) != null)
                  	strTemp += "<br>Collection :: "+(String)vTempCO.elementAt(3);
                  %> <strong><%=strTemp%><%=strCurrencyInfo%></strong> </td>
          </tr>
        </table>
        <%}//only if cutoff time is set.
}		%> </td>
    </tr>
<%if(strSchoolCode.startsWith("PHILCST")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5" style="font-weight:bold; color:#0000FF; font-size:14px;">
	  <%
	  strTemp = WI.fillTextValue("is_partial");
	  if(strTemp.equals("1"))
	  	strTemp = " checked";
	  else
	  	strTemp = "";
	  %>
	  <input type="checkbox" name="is_partial" value="1" <%=strTemp%>> Is Partial Payment (this appears on OR)	  </td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%" height="25"> Student ID </td>
      <td width="22%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  style="font-size: 18" onKeyUp="AjaxMapName(event, '1');"></td>
      <td width="4%" height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td colspan="2">
	  <a href="#">
	  <img src="../../../images/form_proceed.gif" onClick="ResetPageAction();" border="0"></a>
<%if(strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("VMUF")
|| strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("PIT") || strSchoolCode.startsWith("DBTC") ||
strSchoolCode.startsWith("PHILCST") || strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("CSA")
 || strSchoolCode.startsWith("CIT")){%>
	<input type="checkbox" onClick="GoToBasic();"><font style="font-size:9px; font-weight:bold; color:#0000FF">Go to Grade school payment.</font>
<%}%>      
	<%if(strSchoolCode.startsWith("SPC")){%>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="button" value="Go to Ledger" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="GoToLedger();">
<%}%>
</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td colspan="3"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date Paid</td>
      <td height="25"> <%
strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%> <input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%if(!bolIsDatePaidReadonly) {%>
        <a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
<%}%>	  </td>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="top">&nbsp;</td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0 &&
		(WI.fillTextValue("pmt_schedule").length() > 0 || !strSchoolCode.startsWith("CGH")) ){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3" height="10"><hr size="1">
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
      <td width="43%" class="thinborderNONE">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%></strong></td>
      <td class="thinborderNONE">Course/Major :<strong> <%=(String)vStudInfo.elementAt(2)%>
        <%if(vStudInfo.elementAt(3) != null){%>
        / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
        <%}%>
        </strong></td>
    </tr>
    <tr>
      <td  width="2%" height="20">&nbsp;</td>
      <td width="43%" class="thinborderNONE">Year :<strong> <%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></strong></td>
      <td class="thinborderNONE">SY-Term :<strong>
	  <%=(String)vStudInfo.elementAt(8)+" - "+(String)vStudInfo.elementAt(9)+" ("+
	  	astrConvertToSem[Integer.parseInt((String)vStudInfo.elementAt(5))]+")"%></strong></td>
    </tr>
<%
if(strSchoolCode.startsWith("FATIMA")){
String strPlanInfo = "select PLAN_NAME from FA_STUD_MIN_REQ_DP_PER_STUD "+
					"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.plan_ref = FA_STUD_MIN_REQ_DP_PER_STUD.plan_ref) "+
					" where is_temp_stud = 0 and  stud_index = "+vStudInfo.elementAt(0)+
					" and sy_from = "+(String)vStudInfo.elementAt(8)+" and semester = "+(String)vStudInfo.elementAt(5);
strPlanInfo = dbOP.getResultOfAQuery(strPlanInfo, 0);
if(strPlanInfo != null){
%>
    <tr>
      <td  width="2%" height="20">&nbsp;</td>
      <td width="43%" style="font-weight:bold; color:#0000FF; font-size:12px;"><u>Plan Subscribed: <%=strPlanInfo.toUpperCase()%></u></td>
      <td class="thinborderNONE">&nbsp;</td>
    </tr>
<%}
}%>
  </table>
<%
if(vScheduledPmt != null && vScheduledPmt.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="20" colspan="9" bgcolor="#B9B292"><div align="center">STUDENT
          ACCOUNT SCHEDULE</div></td>
    </tr>
  </table>
<%
if(WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") != 0){%>
<%if(vScheduledPmtNew == null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="20" width="2%">&nbsp;</td>
      <td width="10%" style="font-size:9px; font-weight:bold">Payment Schedule </td>
      <%if(false || strSchoolCode.startsWith("PHILCST")){%><td width="10%" align="center" style="font-size:9px; font-weight:bold">Installment Amt</td><%}%>
      <td width="20%" align="center" style="font-size:9px; font-weight:bold">Last Due Date</td>
      <td width="20%" align="right" style="font-size:9px; font-weight:bold">Amount Due</td>
      <td width="20%" align="right" style="font-size:9px; font-weight:bold">Amount Paid</td>
      <td width="18%" align="right" style="font-size:9px; font-weight:bold">Balance</td>
    </tr>
    <%
//System.out.println(vScheduledPmt);
int iEnrlSetting      = FA.getEnrollemntInstallmentSetting();//1= (total due-first payment)/iInstalCount, 0=total due/iInstallCount - first installment.
double dAmoutPaidDurEnrollment = ((Float)vScheduledPmt.elementAt(2)).doubleValue();
double dInstallAmount = ((Float)vScheduledPmt.elementAt(3)).doubleValue();
double dCumAmountPaid = 0d; // total amount paid
if(iEnrlSetting ==0)
	dCumAmountPaid = dAmoutPaidDurEnrollment;
double dAmountDue = 0d; //installment amount + amount due in previous payment.
int iNoOfInstallments = ((Integer)vScheduledPmt.elementAt(4)).intValue();



  //////////// Posting pmt schedule.
   Vector vInstallPmtSchedule =
        FA.getOtherChargePayable(dbOP, (String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(9),
			(String)vStudInfo.elementAt(5), (String)vStudInfo.elementAt(0) );
	if(vInstallPmtSchedule != null) {
		//System.out.println("JSP : Installment Pmt Sch : "+vInstallPmtSchedule);
		vInstallPmtSchedule.removeElementAt(0);
/** wrong
		double dTemp = 0d;
		for(int i = 0; i < vInstallPmtSchedule.size(); i += 3) {
			dTemp = Double.parseDouble((String)vInstallPmtSchedule.elementAt(i + 2));
			if(dTemp < 0)
				vInstallPmtSchedule.setElementAt("-500", i + 2);
		}
**/
	}
	//System.out.println(" vInstallPmtSchedule : "+vInstallPmtSchedule);
//System.out.println(" vScheduledPmt : "+vScheduledPmt);

    double dInstallmentPayable = 0d;double dCumInstallmentPayable = 0d;
    //this determines how the posting fees paid.

//vInstallPmtSchedule = null;
//System.out.println("JSP : "+vInstallPmtSchedule);
double dDiff = 0d; double dDiffOrig = 0d;
double dTemp = 0d;
double[] adTemp = null;
adTemp = FA.convertDoubleToNearestInt(strSchoolCode, dInstallAmount);
if(adTemp != null) {
	dTemp = dInstallAmount;
	dInstallAmount = adTemp[0];
	dDiffOrig = adTemp[1];
}
for(int i=0,j=5; i<iNoOfInstallments ;++i) {
	if(i >=(iNoOfInstallments-1))
		dInstallAmount += dDiff + dDiffOrig;
	else
		dDiff += dDiffOrig;
	//System.out.println(" i : "+i +" .. dDiff : "+dDiff+" ... dInstallAmount : "+dInstallAmount);
	if(j ==5)
	{
		if(iEnrlSetting ==0)
			dAmountDue = dInstallAmount - dAmoutPaidDurEnrollment;
		else if(iEnrlSetting == 1)
			dAmountDue = dInstallAmount;
		else if(iEnrlSetting == 2) //UI
			dAmountDue = ((Double)vScheduledPmt.elementAt(vScheduledPmt.size() - 1)).doubleValue();
	}
	else
		dAmountDue += dInstallAmount - ((Float)vScheduledPmt.elementAt(j+2 - 3)).doubleValue();
	dCumAmountPaid += ((Float)vScheduledPmt.elementAt(j+2)).doubleValue();



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
		if( ((String)vScheduledPmt.elementAt(j)).toLowerCase().startsWith("final")) {
			dAmountDue = dOutStandingBal;
			//System.out.println("dOutStandingBal : "+dOutStandingBal);
		}

//System.out.println(dInstallAmount);
//System.out.println(dInstallmentPayable);
%>
    <tr>
      <td height="20">&nbsp;</td>
      <td><%=vScheduledPmt.elementAt(j)%></td>
<%if(false || strSchoolCode.startsWith("PHILCST")){%>
	      <td align="center"> <%if(j ==5 && iEnrlSetting == 0){%> <%=CommonUtil.formatFloat(dInstallAmount - dAmoutPaidDurEnrollment + dInstallmentPayable,true)%>
	  						<%}else{%> <%=CommonUtil.formatFloat(dInstallAmount + dInstallmentPayable,true)%> <%}%>
		  </td>
<%}%>
      <td align="center"> <%
	  if(vScheduledPmt.size() > j){%> <%=(String)vScheduledPmt.elementAt(j+1)%> <%}%> </td>
      <td align="right"><%=CommonUtil.formatFloat(dAmountDue,true)%>&nbsp;&nbsp;</td>
      <td align="right"> <%
	  if(vScheduledPmt.size() > j){%> <%=CommonUtil.formatFloat(vScheduledPmt.elementAt(j+2).toString(),true)%> <%}%> &nbsp;&nbsp;</td>
      <td align="right">
	  <%if( ((String)vScheduledPmt.elementAt(j)).toLowerCase().startsWith("final")){%>
	  	<%=CommonUtil.formatFloat(dOutStandingBal, true)%>
	  <%} else if(iEnrlSetting == 2){%> <%=CommonUtil.formatFloat(dAmountDue - ((Float)vScheduledPmt.elementAt(j+2)).doubleValue(),true)%>
	<%}else{%> <%=CommonUtil.formatFloat(dInstallAmount*(i+1) + dCumInstallmentPayable - dCumAmountPaid,true)%> <%}%></td>
    </tr>
    <%
j = j+3;
}

if(dRefunded > 0.2d || dRefunded < -0.2d){%>
 <tr>
      <td height="20">&nbsp;</td>
      <td align="center">&nbsp;</td>
<%if(false){%>      <td align="center">&nbsp;</td><%}%>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="right"><font size="1" color="#0033FF"><b>AMOUNT REFUNDED</b></font> &nbsp;&nbsp;</td>
      <td align="right"><font size="1" color="#0033FF"><b><%=CommonUtil.formatFloat(dRefunded,true)%></b></font> &nbsp;&nbsp;</td>
    </tr>
<%}//show refund if there is any.%>
  </table>
<%}//turn it off for sometime and test new program.. %>

<%if(vScheduledPmtNew != null && vScheduledPmtNew.size() > 0) {
//System.out.println("vScheduledPmtNew : "+vScheduledPmtNew);%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="20" width="2%">&nbsp;</td>
		  <td width="10%" style="font-size:9px; font-weight:bold">Payment Schedule </td>
		  <td width="20%" align="center" style="font-size:9px; font-weight:bold">Last Due Date</td>
		  <td width="20%" align="right" style="font-size:9px; font-weight:bold">Amount Due</td>
		  <td width="20%" align="right" style="font-size:9px; font-weight:bold">Amount Paid</td>
		  <td width="18%" align="right" style="font-size:9px; font-weight:bold">Cumulative Balance</td>
		</tr>
		<%
	//System.out.println(vScheduledPmt);
	int iNoOfInstallments = ((Integer)vScheduledPmt.elementAt(4)).intValue();
	double[] adTemp = null; double dAmtDue = 0; double dTotalDue = 0d; double dOSBal = Double.parseDouble(ConversionTable.replaceString((String)vScheduledPmtNew.elementAt(6), ",",""));
	for(int i = 7; i < vScheduledPmtNew.size(); i += 2) {
		iIndexOf = vScheduledPmt.indexOf(vScheduledPmtNew.elementAt(i));
		if(iIndexOf == -1)
			strTemp = null;
		else
			strTemp = (String)vScheduledPmt.elementAt(iIndexOf + 1);
		dAmtDue = ((Double)vScheduledPmtNew.elementAt(i + 1)).doubleValue();//System.out.println("Amt Due: "+dAmtDue);
		if(dOSBal <= 0 && dAmtDue <=0d)
			dTotalDue = dAmtDue;
		else
			dTotalDue += dAmtDue;

		//if(dTotalDue >= dOSBal)
		//	dTotalDue = dOSBal;

		if(((i + 3) > vScheduledPmtNew.size()) )
			dTotalDue = dOSBal;
	%>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td><%=vScheduledPmtNew.elementAt(i)%></td>
		  <td align="center"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
		  <td align="right"><%=CommonUtil.formatFloat(dAmtDue, true)%></td>
		  <td align="right"><%=vScheduledPmt.elementAt(iIndexOf + 2)%></td>
		  <td align="right"><%=CommonUtil.formatFloat(dTotalDue, true)%></td>
		</tr>
	<%}//show refund if there is any.%>
  </table>
<%}%>


<%}//do not show if is_full_pmt_installment.
//only if IS_FULL_PMT_INSTALLMENT is not checked.. condition -> WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") != 0
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td style="font-size:18px; font-weight:bold" colspan="5" class="thinborderTOPBOTTOM">::: PAYMENT DETAILS ::: </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="18%" style="font-size:18px; font-weight:bold">Tuition Amount </td>
      <td colspan="3" style="font-size:18px; font-weight:bold">
<%
strTemp = WI.fillTextValue("tuition_amt");
%>
	  <input name="tuition_amt" type="text" size="18" value="<%=strTemp%>" autocomplete="off"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxFormatAmount();UpdatePaymentInfo();MoveNext(event, '_1')" class="textbox_bigfont">
<!-- removed on keyup and on blur :: AllowOnlyFloat('fa_payment','amount'); -->
	  &nbsp;&nbsp;&nbsp; Schedule:

        <select name="pmt_schedule" style="font-size:18px; font-weight:bold">
<%if(strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("FATIMA") || strSchoolCode.startsWith("UC") || strSchoolCode.startsWith("VMA") || bolIsNoDP){%>
		<option value="0">DownPayment</option>
<%}
if(bolIsNoDP)
	strPaymentForVal = "";

//i have to check if i should use the fa_pmt_schedule_extn or fa_pmt_schedule table.

strTemp = dbOP.loadCombo("fa_pmt_schedule_extn.PMT_SCH_INDEX","EXAM_NAME",
		" from fa_pmt_schedule_extn  join fa_pmt_schedule on (fa_pmt_schedule_extn.pmt_sch_index = fa_pmt_schedule.pmt_sch_index)"+
		" where fa_pmt_schedule_extn.is_del=0 and fa_pmt_schedule_extn.is_valid=1 and sy_from="+(String)vStudInfo.elementAt(8)+
		" and sy_to="+(String)vStudInfo.elementAt(9)+" and semester="+(String)vStudInfo.elementAt(5)+
		 " order by fa_pmt_schedule_extn.EXAM_PERIOD_ORDER asc", strPaymentForVal, false);
//System.out.println("Printing : "+(String)vStudInfo.elementAt(8)+","+(String)vStudInfo.elementAt(9)+","+(String)vStudInfo.elementAt(5));
if(strTemp.length() > 0 && strSchoolCode.startsWith("AUF")) {
	//I have to check the course, as it preceeds over per sem schedule.
	strErrMsg = dbOP.loadCombo("FA_PMT_SCH_EXTN_COURSE.PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCH_EXTN_COURSE  join fa_pmt_schedule on (FA_PMT_SCH_EXTN_COURSE.pmt_sch_index = fa_pmt_schedule.pmt_sch_index)"+
		" where FA_PMT_SCH_EXTN_COURSE.is_del=0 and FA_PMT_SCH_EXTN_COURSE.is_valid=1 and (semester is null or semester="+
		(String)vStudInfo.elementAt(5)+ ") and course_index = "+(String)vStudInfo.elementAt(6)+
		" order by FA_PMT_SCH_EXTN_COURSE.EXAM_PERIOD_ORDER asc", strPaymentForVal, false);
	if(strErrMsg.length() > 0)
		strTemp = strErrMsg;
}
if(strTemp.length() == 0)
	strTemp = dbOP.loadCombo("FA_PMT_SCH_EXTN_COURSE.PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCH_EXTN_COURSE  join fa_pmt_schedule on (FA_PMT_SCH_EXTN_COURSE.pmt_sch_index = fa_pmt_schedule.pmt_sch_index)"+
		" where FA_PMT_SCH_EXTN_COURSE.is_del=0 and FA_PMT_SCH_EXTN_COURSE.is_valid=1 and (semester is null or semester="+
		(String)vStudInfo.elementAt(5)+ ") and course_index = "+(String)vStudInfo.elementAt(6)+
		" order by FA_PMT_SCH_EXTN_COURSE.EXAM_PERIOD_ORDER asc", strPaymentForVal, false);
if(strTemp.length() ==0)
	strTemp = dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc",
		strPaymentForVal, false);
%>
          <%=strTemp%> </select>
		  
		  <label id="format_amt" style="font-size:18px; font-weight:bold; color:#00CCFF"></label>		  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:18px; font-weight:bold" valign="top">Other Charge Status  </td>
      <td colspan="3" style="font-size:18px; font-weight:bold">
	  <select name="pmt_status" style="font-weight:bold; font-size:18px; font-family:Verdana, Arial, Helvetica, sans-serif">
          <option value="0">OC NOT POSTED</option>
<%
boolean bolRemoveAlreadyPosted = false;
if(strSchoolCode.startsWith("FATIMA"))
	bolRemoveAlreadyPosted = true;

strTemp = WI.fillTextValue("pmt_status");
if(strTemp.length() == 0 && (strSchoolCode.startsWith("PIT") || strSchoolCode.startsWith("UPH")))
	strTemp = "1";

if(!bolRemoveAlreadyPosted) {
	if(strTemp.compareTo("1") ==0){%>
			  <option value="1" selected>OC ALREADY POSTED</option>
			  <%}else{%>
			  <option value="1">OC ALREADY POSTED</option>
	<%}
}%>
        </select>
		
	  &nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:18px; font-weight:bold" valign="top">&nbsp;</td>
      <td colspan="3" style="font-size:9px" valign="bottom">
	  <input type="text" name="scroll_fee" size="16" style="font-size:10px; background:#CCCC33" autocomplete="off"
		  onKeyUp="AutoScrollList('fa_payment.scroll_fee','fa_payment.fee_type',true);"
		   onBlur="document.fa_payment.scroll_fee.value='';ChangeFeeType()" class="textbox"> (Auto scroll Fee)
	</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:18px; font-weight:bold" valign="top">Fee Name	  </td>
      <td colspan="3" style="font-size:18px; font-weight:bold">
	  <select name="fee_type" onChange="ChangeFeeType();" style="font-size:11px; width:400px;">
          <option value=""></option>
<%
Vector vOCFee = new Vector();

strSQLQuery = "select othsch_fee_index, fee_name, amount from FA_OTH_SCH_FEE where is_del=0 and is_valid=1 and year_level=0 and "+
		"sy_index=(select sy_index from FA_SCHYR where sy_from="+(String)request.getSession(false).getAttribute("cur_sch_yr_from")+") order by FEE_NAME asc";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vOCFee.addElement(rs.getString(1));
	vOCFee.addElement(rs.getString(2));
	vOCFee.addElement(ConversionTable.replaceString(CommonUtil.formatFloat(rs.getDouble(3), true), ",",""));
}
rs.close();
 %>
        <%for(int a = 0; a < vOCFee.size(); a += 3) {%>
			<option value="<%=vOCFee.elementAt(a)%>"><%=vOCFee.elementAt(a + 1)%></option>
		<%}%>  
        </select>
<%for(int a = 0; a < vOCFee.size(); a += 3) {%>
<input type="hidden" name="fee_type_amt_<%=a/3+1%>" value="<%=vOCFee.elementAt(a + 2)%>">
<%}%>	  
	  
	  <input type="text" name="fee_amount_" value="" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="7" maxlength="10"
	  style="font-weight:bold;">
	  &nbsp;&nbsp;
	  <input type="button" value="Click to add to list of fees to pay" style="font-size:11px; height:25px;border: 1px solid #FF0000; background:#6699CC; font-weight:bold" onClick="AddFeeName();">
	  <%if(vGroupDtls.size() > 0) {%>
		   <font  style="font-size:11px; font-weight:bold">
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  <a href="javascript:ShowLayerGroupFee('1');">
		  Show Grouped Fees		  </a>		  </font>
	  <%}%>
		  <div id="processing" class="processing"  style="visibility:hidden; overflow:auto">
		  	<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#FFCC99">
				<tr><td valign="top">
					<table width="100%" cellpadding="0" cellspacing="0">
					  <tr>
					  	<td>&nbsp;</td>
						<td valign="top" align="right" class="thinborderNONE" height="20"><a href="javascript:HideLayerGroupFee(1)">Close Window X</a></td>
					  </tr>
					  <%while(vGroupList.size() > 0) {%>
						<tr>
							<td height="20" width="50%"><input type="checkbox" name="_group_<%=++iGroupRef%>" value="<%=vGroupList.elementAt(0)%>"> <%=vGroupList.remove(0)%></td>
							<td width="50%"><%if(vGroupList.size() > 0) {%><input type="checkbox" name="_group_<%=++iGroupRef%>" value="<%=vGroupList.elementAt(0)%>"> <%=vGroupList.remove(0)%><%}%></td>
						</tr>
					  <%}%>
					  <tr>
					  	<td colspan="2" align="center"><br><input type="button" value="&nbsp;&nbsp; Add Fee &nbsp;&nbsp;" style="font-size:11px; height:24px;border: 1px solid #FF0000;" onClick="AddGroupedFee();"></td>
					  </tr>
					</table>
				</td></tr>
				<input type="hidden" name="max_count_grouped" value="<%=iGroupRef%>">
			</table>
          </div>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:18px; font-weight:bold" valign="top"><br>Other Charge To Pay
	  <br>
	  <label id="oc_detail" style="font-size:8px; font-weight:normal"></label>	  </td>
      <td colspan="3" style="font-size:18px; font-weight:bold">

	  <div style="height:250px; overflow:scroll; border:inset" id="scroll_">
	  <table width="100%" cellpadding="0" cellspacing="0" align="center" class="thinborder">
	  	<tr>
			<td colspan="3" align="center" class="thinborder" bgcolor="#FFCC99"><strong>Select Multiple Fee</strong></td>
		</tr>
		<%
		/** before..
		strTemp = "select OTHSCH_FEE_INDEX, fee_name, amount from FA_OTH_SCH_FEE where othsch_Fee_index in ("+WI.getStrValue(WI.fillTextValue("fee_index"), "-1")+")";
		if(WI.fillTextValue("remove_fee_i").length() > 0) 
			strTemp += " and othsch_fee_index <> "+WI.fillTextValue("remove_fee_i");
		**/
		//new 
		strTemp = "select OTHSCH_FEE_INDEX, fee_name, amount from FA_OTH_SCH_FEE where othsch_Fee_index in ("+WI.getStrValue(strFeeIndexList, "-1")+")";
		
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
			rs = dbOP.executeQuery(strTemp);
			while(rs.next()){
 		%>
			<tr class="nav" id="msg<%=iListCount%>" onMouseOver="navRollOver('msg<%=iListCount%>', 'on')" onMouseOut="navRollOver('msg<%=iListCount%>', 'off')">
			  <td class="thinborder" width="10%" style="font-size:9px;"><a href="javascript:RemoveFee('<%=rs.getString(1)%>');">Remove</a></td>
				<td class="thinborder" width="67%" style="font-size:9px;">
				<label for="_id<%=iListCount%>">
				<%//if(WI.fillTextValue("fee_i"+iListCount).length() > 0)
					strTemp = " checked";
				  //else
				  //	strTemp = ""; 
				%>
				<label style="visibility:hidden">
				<input type="checkbox" id="_id<%=iListCount%>" name="fee_i<%=iListCount%>" value="<%=rs.getString(1)%>" checked="checked" onClick="return false" onKeyDown="return false"> <!-- onClick="UpdatePaymentInfo();" <%=strTemp%>>-->			    </label>
				</label><%=rs.getString(2)%>
				<input type="hidden" name="fee_name<%=iListCount%>" value="<%=rs.getString(2)%>">			  </td>
			  <td width="23%" class="thinborder">
			  <%
			  //strTemp = WI.fillTextValue("fee_amt"+iListCount);
			  //if(strTemp.length() == 0)
			  //	strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(rs.getDouble(3), true), ",","");
			  	  iIndexOf = vOCAddedIndex.indexOf(rs.getString(1));
				  strTemp = "0.00";
				  while(iIndexOf > -1) {
				  	vOCAddedIndex.remove(iIndexOf);
					
					strTemp = (String)vOCAddedAmt.remove(iIndexOf);
					iIndexOf = vOCAddedIndex.indexOf(rs.getString(1));
				  }

			  %>

				<input type="text" name="fee_amt<%=iListCount%>" value="<%=strTemp%>"
				 class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12" maxlength="12"
				 onKeyUp="AllowOnlyFloat('fa_payment','fee_amt<%=iListCount%>');UpdatePaymentInfo();"></td>
			</tr>

		<%++iListCount;}rs.close();%>
	  </table>
	  </div>	  </td>
    </tr>
<script language="javascript">
	document.fa_payment.amount_shown.value = "1";
</script>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Total Payable Amount </td>
      <td>
      <input name="amount" type="text" size="18" value="<%=WI.fillTextValue("amount")%>" autocomplete="off"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxUpdateChange();MoveNext(event, '_2')" class="textbox_bigfont" id="_1" readonly="yes">      </td>
      <td colspan="2">&nbsp;
	  <input type="text" name="_fake" style="border:0px; height:0px; width:0px; size:0px;" tabindex="-1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Amount Tendered </td>
      <td width="28%">
	  		<input name="amount_tendered" type="text" size="16" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();MoveNext(event, '_3')" autocomplete="off" id="_2">	  </td>
      <td colspan="2">
		<div id="change_div">
			<table cellpadding="0" cellspacing="0">
      			<td style="font-size:18px;">Change: &nbsp;</td>
      			<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
			</table>
		</div>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Payment type</td>
      <td><font size="1">
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

			  <%}//show credit card for AUF only.. %>       </select>
        <br>
        <input name="text" type="text" class="textbox_noborder" id="_empID" value="Emp ID:" size="6" readonly="yes" tabindex="-1">
        <input type="text" name="cash_adv_from_emp_id" value="<%=WI.fillTextValue("cash_adv_from_emp_id")%>" size="12" id="_empID1" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="-1">
        <a href="javascript:OpenSearchFaculty();" tabindex="-1"><img src="../../../images/search.gif" width="25" height="23" border="0" id="hide_search"></a>


        </font> </td>
      <td width="19%">Ref number</td>
      <td width="33%"><font size="1"><b>
        <!--       <%
	   	//strTemp = paymentUtil.generateORNumber(dbOP);
	   //	if(strTemp == null)
	   //		strTemp = paymentUtil.getErrMsg();
		//else{%>
        <input type="hidden" name="or_number" value="<%//=strTemp%>">
        <%//}%>
        <%//=strTemp%> -->
        <input name="or_number" type="text" size="18" value="<%=pmtUtil.generateORNumber(dbOP,(String)request.getSession(false).getAttribute("userId"))%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="-1">
        </b></font> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Check #</td>
      <td colspan="3"> <%
strTemp = "";
if(request.getParameter("payment_type") == null || 	 request.getParameter("payment_type").trim().length() ==0 ||
	request.getParameter("payment_type").compareTo("0") == 0)
{
	strTemp = "disabled";
}%> <input name="check_number" type="text" size="16" value="<%=WI.fillTextValue("check_number")%>" <%=strTemp%> class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="-1">
        &nbsp;&nbsp;&nbsp; <select name="CHECK_FR_BANK_INDEX" style="font-size:10px" tabindex="-1">
          <option value=""></option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH",
		" from FA_BANK_LIST where is_valid = 1 order by bank_code", request.getParameter("CHECK_FR_BANK_INDEX"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
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
      <td height="25">&nbsp;</td>
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
</table>
<script language="JavaScript">
ShowHideCheckNO();
</script>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="15" colspan="9"><hr size="1"></td>
    </tr>
<%if(iAccessLevel > 1){%>
    <tr >
      <td width="2%" height="20">&nbsp;</td>
      <td colspan="4" valign="bottom">&nbsp;</td>
      <td colspan="3" height="25"><a href="javascript:AddRecord();" id="_3">
	  		<img name="hide_save" src="../../../images/save.gif" border="0"></a>
        <font size="1">click to save entries&nbsp; </font></td>
      <td width="10%"  height="25">&nbsp;</td>
    </tr>
<%		}//only if iAccessLevel > 1
	}//only if vScheduledPmt != null;
}//only if stud info is not null;
%>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="payment_for" value="0">
 <input type="hidden" name="addRecord" value="0">
 <input type="hidden" name="pmt_schedule_name" value="<%=WI.fillTextValue("pmt_schedule_name")%>">

 <input type="hidden" name="prev_id" value="<%=WI.fillTextValue("stud_id")%>">

 <input type="hidden" name="list_count" value="<%=iListCount%>">
<input type="hidden" name="sukli">
<input type="hidden" name="tuition_non_tuition" value="1">
<input type="hidden" name="add_fee" value="">
	<input type="hidden" name="fee_index" value="<%=strFeeIndexList%>">
	<input type="hidden" name="fee_index_amt" value="<%=strFeeAmtList%>">

<input type="hidden" name="remove_fee_i">
<input type="hidden" name="add_group_fee">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
