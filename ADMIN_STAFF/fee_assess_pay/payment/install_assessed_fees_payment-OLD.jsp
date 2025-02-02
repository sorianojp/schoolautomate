<%@ page language="java" import="utility.*,enrollment.CheckPayment, enrollment.FAAssessment,enrollment.FAPaymentUtil,enrollment.FAPayment,java.util.Vector" buffer="16kb" %>
<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	WebInterface WI = new WebInterface(request);


//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Installment fees","install_assessed_fees_payment.jsp");
	}
	catch(Exception exp) {
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

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Installment Fees</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
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
function FullPayment() {
	if (document.fa_payment.amount)
		document.fa_payment.amount.value = "";
	this.ReloadPage();
}
function ReloadPage()
{
	document.fa_payment.addRecord.value="";
	document.fa_payment.submit();
}
function ResetPageAction() {
	document.fa_payment.addRecord.value = "";
}
function AddRecord()
{
	document.fa_payment.addRecord.value="1";
	document.fa_payment.hide_save.src = "../../../images/blank.gif";
	<%
	if(strSchoolCode.startsWith("CPU") || strSchoolCode.startsWith("CLDH") || strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("PHILCST") || 
		strSchoolCode.startsWith("DBTC") || strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("FATIMA")){%>
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
	document.fa_payment.cash_amt.value = eval(cashAmt);
}
function ViewCheckPmtDtls(strID, strSYFr, strSYTo, strSem)
{
	var pgLoc = "./view_check_payments.jsp?stud_id="+strID+"&sy_from="+strSYFr+"&sy_to="+strSYTo+"&semester="+strSem;
	var win=window.open(pgLoc,"PrintWindow",'width=640,height=480,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
function GoToBasic() {
	location = "./install_assessed_fees_payment_bas.jsp";
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
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

</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%
Vector vStudInfo = new Vector();
Vector vScheduledPmt = new Vector(); Vector vScheduledPmtNew = new Vector();

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

if(strTemp != null && strTemp.compareTo("1") ==0)
{
	if(faPayment.savePayment(dbOP,request,false))
	{
		//post late fee if there is any..
		if(WI.fillTextValue("lf_amt").length() > 0 && WI.fillTextValue("no_fine").length() == 0) {//insert into fa_stud_payable
			strTemp = "insert into FA_STUD_PAYABLE (PAYABLE_TYPE,AMOUNT,NO_OF_UNITS,USER_INDEX,"+
				"SY_FROM,SY_TO,SEMESTER,CREATED_BY,CREATE_DATE,TRANSACTION_DATE,note) values (4,"+
			WI.fillTextValue("lf_amt")+",1,"+(String)vStudInfo.elementAt(0)+","+
			(String)vStudInfo.elementAt(8)+","+(String)vStudInfo.elementAt(9)+","+
			(String)vStudInfo.elementAt(5)+","+request.getSession(false).getAttribute("userIndex")+",'"+
			WI.getTodaysDate()+"','"+
			ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_of_payment"))+"','"+
			WI.fillTextValue("lf_reason")+"')";
			dbOP.executeUpdateWithTrans(strTemp,null,null,false);
			double dTotalPmt = Double.parseDouble(WI.fillTextValue("amount"));
			dTotalPmt = dTotalPmt - Double.parseDouble(WI.fillTextValue("lf_amt"));
			request.getSession(false).setAttribute("lf_reason",": P"+CommonUtil.formatFloat(dTotalPmt,true)+"<br>Late payment surcharge : P"+
			CommonUtil.formatFloat(Double.parseDouble(WI.fillTextValue("lf_amt")),true) );
		}
		dbOP.cleanUP();
			String strSukli = WI.fillTextValue("sukli");
			if(strSukli.length() > 0) {
				//keep change in attribute.
				double dAmtReceived = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""));
				dAmtReceived = dAmtReceived - Double.parseDouble(WI.fillTextValue("amount"));
				strSukli = "&sukli="+ CommonUtil.formatFloat(dAmtReceived,true);
			}
		strTemp = WI.fillTextValue("IS_FULL_PMT_INSTALLMENT");
		if(strTemp.equals("1"))
			strTemp = "&fp=1";
		else	
			strTemp = "";
		response.sendRedirect(response.encodeRedirectURL("./install_assessed_fees_print_receipt.jsp?view_status=0&or_number="+
		request.getParameter("or_number")+"&pmt_schedule="+request.getParameter("pmt_schedule")+"&pmt_schedule_name="+request.getParameter("pmt_schedule_name")+strSukli+strTemp));
		return;
	}
	else
		strErrMsg = faPayment.getErrMsg();
}

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

		dFullPmtPayableAmt= fOperation.calOutStandingCurYr(dbOP, (String)vStudInfo.elementAt(0),
								astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);

		float fMiscOtherFee = fOperation.getMiscOtherFee();
		enrollment.FAFeeOperationDiscountEnrollment test = new enrollment.FAFeeOperationDiscountEnrollment(true,WI.getTodaysDate(1));
		test.setForceFullPmt();
		Vector vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,  (String)vStudInfo.elementAt(0),pmtUtil.isTempStud(),
						astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6), astrSchYrInfo[2],fOperation.dReqSubAmt);

	if(vTemp != null && vTemp.size() > 0)
		strEnrolmentDiscDetail = (String)vTemp.elementAt(0);
	if(strEnrolmentDiscDetail != null) {
		dEnrollmentDiscount = ((Float)vTemp.elementAt(1)).doubleValue();

		dFullPmtPayableAmt = dFullPmtPayableAmt - dEnrollmentDiscount;
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


	vScheduledPmtNew = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(8),
						(String)vStudInfo.elementAt(9),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5));
	System.out.println("New : "+vScheduledPmtNew);
	System.out.println("Old : "+vScheduledPmt);
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
if(vStudInfo != null && vStudInfo.size() > 0) {
	String strSQLQuery = "select payment_index from fa_stud_payment where is_stud_temp = 0 and user_index = "+(String)vStudInfo.elementAt(0) +
						" and is_valid = 1 and sy_from = "+(String)vStudInfo.elementAt(8) +" and semester = "+(String)vStudInfo.elementAt(5)+" and pmt_sch_index = 0 and payment_for = 0 and not exists (select * from FA_CANCEL_OR where OR_NUMBER = fa_stud_payment.or_number) ";
	if(dbOP.getResultOfAQuery(strSQLQuery, 0) == null)
		bolIsNoDP = true;

}

%>

<form name="fa_payment" action="./install_assessed_fees_payment.jsp" method="post">
<input type="hidden" name="amount_shown" value="0">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          SCHEDULE ASSESSMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
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
    <%
if(WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"> <input type="checkbox" name="IS_FULL_PMT_INSTALLMENT" value="1"
	  onClick="FullPayment();" <%=strTemp%>> <font color="#0000FF" size="3">TICK
        if full pmt &amp; should have full pmt discount</font>
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
      <td width="36%" height="25"> <%//get here cutoff time information.
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
        <%}//only if cutoff time is set.%> </td>
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
	  style="font-size: 18" onKeyUp="AjaxMapName('1');"></td>
      <td width="4%" height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td colspan="2">
	  <input type="image" src="../../../images/form_proceed.gif" onClick="ResetPageAction();">
<%if(strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("VMUF") 
|| strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("PIT") || strSchoolCode.startsWith("DBTC") || 
strSchoolCode.startsWith("PHILCST") || strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("CSA")
 || strSchoolCode.startsWith("CIT")){%>
	<input type="checkbox" onClick="GoToBasic();"><font style="font-size:9px; font-weight:bold; color:#0000FF">Go to Grade school payment.</font>
<%}%>      </td>
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
        <a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td height="25">&nbsp;</td>
      <td colspan="2" rowspan="2" valign="top">
<%
if(vStudInfo != null && vStudInfo.size() > 0 && WI.fillTextValue("pmt_schedule").length() > 0){
	enrollment.FAFeeMaintenanceVairable fmVariable = new enrollment.FAFeeMaintenanceVairable();
	Vector vLateFee = fmVariable.getLateFeeFine(dbOP, WI.fillTextValue("pmt_schedule"),(String)vStudInfo.elementAt(8),
						(String)vStudInfo.elementAt(5), WI.fillTextValue("date_of_payment"));
	if(vLateFee != null && vLateFee.size() > 0) {%>
		<table width="90%" cellpadding="0" cellspacing="0" class="thinborderALL">
		<tr>
			<td><font size="3" color="#0000FF"><input type="checkbox" value="1" name="no_fine">
              <strong>Do not apply fine (incase paid earlier in bank)</strong></font></td>
		</tr>
		<%for(int i = 0; i < vLateFee.size(); i += 3){%>
		<tr>
			<td><%if(i == 0){%><font color="#FF0000"><img src="../../../images/tick.gif"><%}else{%><font color="#CCCCCC"><%}%>
				Late Fine : <%=CommonUtil.formatFloat(Double.parseDouble((String)vLateFee.elementAt(i + 1)),true)%>.
				(on or after <%=(String)vLateFee.elementAt(i)%>)
				<%if(i == 0){%></font><%}%>			</td>
		</tr>
		<%}%>
		<tr>
			<td><font color="#999999">NOTE : The Fine amount in red will be posted
              to ledger.</font>
			  <input type="hidden" name="lf_amt" value="<%=(String)vLateFee.elementAt(1)%>">
			  <input type="hidden" name="lf_reason" value="Late payment surcharge for <%=(String)vLateFee.elementAt(2)%>">		    </td>
		</tr>
		</table>
	 <%}//end of vLateFee
}//only if vStudInfo is not null.%>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"> <%if(vStudInfo != null && vStudInfo.size() > 0){%>
        Payment for exam <%}%> </td>
      <td height="25"> <%
if(vStudInfo != null && vStudInfo.size() > 0){%>
        <select name="pmt_schedule" onChange="ChangePmtSchName();">
<%if(strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("FATIMA") || strSchoolCode.startsWith("UC") || bolIsNoDP){%>
		<option value="0">DownPayment</option>
<%}
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
          <%=strTemp%> </select> <%}%> </td>
      <td height="25">&nbsp;</td>
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
  </table>
<%
if(vScheduledPmt != null && vScheduledPmt.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="20" colspan="9" bgcolor="#B9B292"><div align="center">STUDENT
          ACCOUNT SCHEDULE</div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="22%" height="18">&nbsp;</td>
      <td width="29%"><font size="1">OUTSTANDING BALANCE</font></td>
      <td width="49%"><font size="1">Php <%=CommonUtil.formatFloat((vScheduledPmt.elementAt(1)).toString(),true)%> </font></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td><font size="1">TOTAL PAYABLE TUITION FEE</font></td>
      <td><font size="1">Php
        <%//=CommonUtil.formatFloat((vScheduledPmt.elementAt(0)).toString(),true)%>
		<%if(WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").length() > 0) {%>
        	<%=CommonUtil.formatFloat(dFullPmtPayableAmt + dEnrollmentDiscount,true)%> (Total Payable)
		<%}else{%>
        	<%=CommonUtil.formatFloat(dPayableAfterDiscount,true)%>(tuition fee - adjustment)
		<%}%>
		</font></td>
    </tr>
    <%
if(strEnrolmentDiscDetail != null) {%>
    <tr>
      <td height="18">&nbsp;</td>
      <td colspan="2"><%=strEnrolmentDiscDetail%></td>
    </tr>
    <%}%>
    <tr>
      <td height="18">&nbsp;</td>
      <td><font size="1">AMOUNT PAID UPON ENROLLMENT</font></td>
      <td><font size="1"> Php <%=CommonUtil.formatFloat((vScheduledPmt.elementAt(2)).toString(),true)%></font></td>
   	</tr>
   <%
	if(dRefunded > 0.2d || dRefunded < -0.2d){%>
	 <tr>
      <td height="18">&nbsp;</td>
      <td><font size="1" color="#0033FF"><b>AMOUNT REFUNDED</b></font></td>
      <td><font size="1" color="#0033FF"> <b>Php <%=CommonUtil.formatFloat(dRefunded,true)%></b></font></td>
    </tr>
   <%}%>
  </table>
<%
if(WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") != 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td><hr size="1"></td>
    </tr>
  </table>

<%if(vScheduledPmtNew == null || true){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="20" width="2%">&nbsp;</td>
      <td width="10%" style="font-size:9px; font-weight:bold">Payment Schedule </td>
      <%if(false){%><td width="10%" align="center" style="font-size:9px; font-weight:bold">Installment Amt</td><%}%>
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
<%if(false){%>
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

<%if(vScheduledPmtNew != null && vScheduledPmtNew.size() > 0) {%>



<%}%>


<%}//do not show if is_full_pmt_installment.
//only if IS_FULL_PMT_INSTALLMENT is not checked.. condition -> WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") != 0
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="20" colspan="5" bgcolor="#B9B292"><div align="center">PAYMENT
          DETAILS </div></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">Amount paid </td>
      <td width="28%"> <%
if(WI.fillTextValue("amount").length() == 0 &&
	WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") ==0) {
	strTemp = CommonUtil.formatFloat(dFullPmtPayableAmt,true);
	strTemp = ConversionTable.replaceString(strTemp,",","");
}
else
	strTemp = WI.fillTextValue("amount");
%> <input name="amount" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('fa_payment','amount');computeCashChkAmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('fa_payment','amount');computeCashChkAmt();AjaxUpdateChange();" on>
        Php </td>
<script language="javascript">
	document.fa_payment.amount_shown.value = "1";
</script>
      <td width="19%"><%if(false){%>Payment receive type<%}%></td>
      <td width="33%"><%if(false){%>
	  <select name="pmt_receive_type" onChange="ReloadPage();" tabindex="-1">
          <option value="Internal">Internal</option>
          <%
strTemp = WI.fillTextValue("pmt_receive_type");
if(strTemp.compareTo("External") ==0){%>
          <option value="External" selected>External</option>
          <%}else{%>
          <option value="External">External</option>
          <%}%>
        </select><%}%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Amount Tendered </td>
      <td>
	  		<input name="amount_tendered" type="text" size="16" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();">
	  </td>
      <td colspan="2">
		<div id="change_div">
			<table cellpadding="0" cellspacing="0">
      			<td style="font-size:18px;">Change: &nbsp;</td>
      			<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
			</table>
		</div>		
	  </td>
    </tr>
<%if(false){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Approval date</td>
      <td><font size="1">
        <input name="date_approved" type="text" size="16" value="<%=WI.fillTextValue("date_approved")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="-1">
        <a href="javascript:show_calendar('fa_payment.date_approved');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;" tabindex="-1"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font> </td>
      <td>Bank name</td>
      <td> <% //only if external.
if(request.getParameter("pmt_receive_type") != null && request.getParameter("pmt_receive_type").compareTo("External") ==0)
{%> <select name="bank" tabindex="-1">
          <%=dbOP.loadCombo("AB_INDEX","AFF_BANK_NAME"," from FA_AFFILIATED_BANK where is_del=0 order by AFF_BANK_NAME asc",
   		request.getParameter("bank"), false)%> </select> <%}else{%>
        N/A
        <%}%> </td>
    </tr>
<%}%>
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
 			  if(strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("CSA")){
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
		" from FA_BANK_LIST  order by bank_code", request.getParameter("CHECK_FR_BANK_INDEX"), false)%>
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
      <td colspan="3" height="25"><a href="javascript:AddRecord();">
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

 <input type="hidden" name="sukli">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
