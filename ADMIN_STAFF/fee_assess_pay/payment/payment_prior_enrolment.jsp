<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPayment,enrollment.FAPaymentUtil,java.util.Vector" %>
<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";

if(strSchoolCode.startsWith("DLSHSI")) //tracking is for lasalle only.. 
	request.getSession(false).setAttribute("start_time_long_or",String.valueOf(new java.util.Date().getTime()));



if(strSchoolCode.startsWith("DLSHSI")) //tracking is for lasalle only.. 
	request.getSession(false).setAttribute("start_time_long_or",String.valueOf(new java.util.Date().getTime()));

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	Vector vFeeDtls = null;
	boolean bolIsTempUser    = false;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Pre enrollment fee","payment_prior_enrolment.jsp");
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
														"payment_prior_enrolment.jsp");
if(iAccessLevel == 0) 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","BANK UPLOAD",request.getRemoteAddr(),
														null);												
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

//true = must pay required d/p.
boolean bolEnforceDP = CommonUtil.bolEnforceDP(dbOP);


Advising  advising        = new Advising();
FAPayment faPayment       = new FAPayment();
FAPaymentUtil paymentUtil = new FAPaymentUtil();

double dReqdDP = 0d;//must take care of PN..


strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") ==0) {

	strErrMsg = null;
	if(bolEnforceDP && WI.fillTextValue("reqd_dp").length() > 0) {
		strTemp = WI.fillTextValue("amount");
		double dT1 = Double.parseDouble(WI.getStrValue(WI.fillTextValue("amount"),"0"));
		if(Double.parseDouble(WI.fillTextValue("reqd_dp")) > dT1)
			strErrMsg = "Can't allow payment less than required downpayment: "+WI.fillTextValue("reqd_dp");
	}

	if(strErrMsg == null) {
		if(!paymentUtil.isORIssuedToTeller(dbOP, request.getParameter("or_number"), (String)request.getSession(false).getAttribute("userIndex"), strSchoolCode))
			strErrMsg = paymentUtil.getErrMsg();
		else if(faPayment.savePaymentPriorToEnrollment(dbOP,request)) {//always false for tution / fine payment
			//System.out.println("Printing Semesterxx: "+dbOP.getResultOfAQuery("select semester from fa_stud_payment where or_number = '"+request.getParameter("or_number")+"'", 0));
			dbOP.cleanUP();
			//I have to keep sukli here.
			String strSukli = WI.fillTextValue("sukli");
			if(strSukli.length() > 0) {
				//keep change in attribute.
				double dAmtReceived = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""));
				dAmtReceived = dAmtReceived - Double.parseDouble(WI.fillTextValue("amount"));
				strSukli = "&sukli="+ CommonUtil.formatFloat(dAmtReceived,true);
			}
			response.sendRedirect(response.encodeRedirectURL("./payment_prior_enrolment_print.jsp?or_number="+request.getParameter("or_number")+strSukli));
			return;
		}
		else
			strErrMsg = faPayment.getErrMsg();
	}
}
String strStudID = WI.fillTextValue("stud_id");

if(strStudID.length() > 0) {
	if(WI.fillTextValue("sy_from").length() > 0) {
		new enrollment.OfflineAdmission().autoCreateAdmissionInfo(dbOP, request);
	}
	vStudInfo = advising.getStudInfo(dbOP, strStudID);
	//check if rfid is scanned.. 
	if(dbOP.strBarcodeID != null)
		strStudID = dbOP.strBarcodeID;
}
boolean bolAlreadyPaid = false;

//String strStudIndex = null;

double dApplFeePayable = 0d;

if(vStudInfo == null) {
	strErrMsg = advising.getErrMsg();
	if(dbOP.mapUIDToUIndex(request.getParameter("stud_id")) != null)
		strErrMsg = strErrMsg + "<br> <a href='javascript:GoToDP();'>Click here to go to Installment/Downpayment</a>";
}
else {
//	strStudIndex = (String)vStudInfo.elementAt(0);

	if(((String)vStudInfo.elementAt(10)).compareTo("0") == 0)
		bolIsTempUser = false;
	else
		bolIsTempUser = true;

	vFeeDtls  = paymentUtil.getDownPaymentOrRegistrationFee(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(16),
                                           (String)vStudInfo.elementAt(17),(String)vStudInfo.elementAt(18),Integer.parseInt(WI.fillTextValue("fee_type")),
										    bolIsTempUser);
	if(vFeeDtls  == null)
		strErrMsg = paymentUtil.getErrMsg();
	else if(vFeeDtls.elementAt(0) != null)//check if student has already paid.
	{
		bolAlreadyPaid = true;
		strErrMsg = "Student has already paid. Or number is "+(String)vFeeDtls.elementAt(0)+
			". Please proceed to enrollment OR <a href=\"././payment_prior_enrolment_print.jsp?or_number="+(String)vFeeDtls.elementAt(0)+"\">click to print receipt</a>";
	}
	else if(WI.fillTextValue("fee_type").equals("1") && strSchoolCode.startsWith("FATIMA") && vFeeDtls != null) {
		strTemp = WI.fillTextValue("fee_index");
		for(int i = 1; i < vFeeDtls.size(); i += 3) {
			if(strTemp.length() == 0) {
				strTemp = (String)vFeeDtls.elementAt(3);
				break;
			}
			if(strTemp.equals(vFeeDtls.elementAt(i + 1))){
				strTemp = (String)vFeeDtls.elementAt(i + 2);
				break;
			}
		}
		//System.out.println(strTemp);
		dApplFeePayable = new enrollment.FAFeeMaintenance().getApplicationFee(dbOP, (String)vStudInfo.elementAt(2), (String)vStudInfo.elementAt(6), strTemp);
	}
}
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","",""};

if(!strSchoolCode.startsWith("PHILCST"))
	bolAlreadyPaid = false;

//check if this is for downpayment..
boolean bolIsForDP = WI.fillTextValue("fee_type").equals("0");

Vector vInstallmentPlanFatima = null; Vector vStudInstallmentPlanFatima = null;
String strStudFatimaPlanRef = null;

if(bolIsForDP && vStudInfo != null && vStudInfo.size() > 0) {
	enrollment.FAStudMinReqDP faMinDP = new enrollment.FAStudMinReqDP(dbOP);
	vStudInstallmentPlanFatima = faMinDP.getPlanInfoOfAStudent(dbOP, (String)vStudInfo.elementAt(16), (String)vStudInfo.elementAt(18), (String)vStudInfo.elementAt(0), bolIsTempUser);
	if(vStudInstallmentPlanFatima != null && vStudInstallmentPlanFatima.size() > 0)
		strStudFatimaPlanRef = (String)vStudInstallmentPlanFatima.elementAt(0);
}


double dPN = -1d;
//I have to get if student is having PN..
String strSQLQuery =  null;
if(vFeeDtls != null && vFeeDtls.size() > 0) {
	strSQLQuery = "select amount from FA_STUD_PROMISORY_NOTE where sy_from = "+(String)vStudInfo.elementAt(16)+" and semester = "+(String)vStudInfo.elementAt(18)+
						" and pmt_sch_index = 0 and is_valid = 1 and user_index = "+(String)vStudInfo.elementAt(0)+" and is_temp_stud_ = ";
	if(bolIsTempUser)
		strSQLQuery += "1";
	else
		strSQLQuery += "0";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next())
		dPN = rs.getDouble(1);
	rs.close();
}

boolean bolIsICA = false;
strSQLQuery = "select info5 from sys_info";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && strSQLQuery.equals("ICA"))
	bolIsICA = true;

//boolean bolIsDatePaidReadonly = false;
//if(strSchoolCode.startsWith("UC") || strSchoolCode.startsWith("EAC") || strSchoolCode.startsWith("FATIMA"))
//	bolIsDatePaidReadonly = true;
boolean bolIsDatePaidReadonly = comUtil.isPaymentDateReadOnly(dbOP, request);
if(WI.fillTextValue("show_bank_post").equals("1"))
	bolIsDatePaidReadonly = false;


boolean bolIsCCPmtAllowed = false;
if(strSchoolCode.startsWith("PWC") || strSchoolCode.startsWith("SWU") || request.getSession(false).getAttribute("is_cc_allowed") != null)
	bolIsCCPmtAllowed = true;

String strProcessingFee = "Not Set";
if(strSchoolCode.startsWith("AUF")) {
	strTemp = "select PROCESSING_FEE,MIN_PROCESSING_FEE from CCARD_SETTING";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	rs.next();
	strProcessingFee = Double.toString(rs.getDouble(1)/100)+"%";
	if(rs.getInt(2) > 0)
		strProcessingFee += " or Min of "+rs.getString(2);
 }


boolean bolShowBankPost = false;
if(WI.fillTextValue("show_bank_post").length() > 0 || strSchoolCode.startsWith("DLSHSI"))
	bolShowBankPost = true;
boolean bolShowRemark = false;
if(request.getSession(false).getAttribute("PMT_REMARK_ALLOWED") != null)
	bolShowRemark = true;


String strBatchNumber = null;///used for SWU.. 
if(strSchoolCode.startsWith("SWU") && vStudInfo != null && vStudInfo.size() > 0) {
	if(bolIsTempUser)
		strBatchNumber = "select section_name_ from new_application where application_index = "+(String)vStudInfo.elementAt(0);
	else
		strBatchNumber = "select section_name from stud_curriculum_hist where user_index = "+(String)vStudInfo.elementAt(0)+" and section_name is not null and sy_from = "+vStudInfo.elementAt(16);
	strBatchNumber = dbOP.getResultOfAQuery(strBatchNumber, 0) ;
}
if(strBatchNumber != null) {
	astrConvertToSem[1] = "1st Term";
	astrConvertToSem[2] = "2nd Term";
	astrConvertToSem[3] = "3rd Term";
	astrConvertToSem[4] = "4th Term";
	astrConvertToSem[5] = "5th Term";
}


String strDefaultTerm = (String)request.getSession(false).getAttribute("cur_sem");
if(strDefaultTerm == null)
	strDefaultTerm = "";
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ShowHideCheckNO()
{
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
	if(!document.fa_payment.payment_type)
		return;
	var iPaymentTypeSelected = document.fa_payment.payment_type.selectedIndex;
	var strPaymentType = document.fa_payment.payment_type[document.fa_payment.payment_type.selectedIndex].text;

	if(iPaymentTypeSelected == 1 || iPaymentTypeSelected == 2 || strPaymentType == "Bank Payment") {
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

	if(iPaymentTypeSelected > 2 &&  strPaymentType != "Bank Payment") {//credit card..
		showLayer('credit_card_info');

		var objLabel = document.getElementById("show_processingfee_note");
		if(objLabel) {
			if(iPaymentTypeSelected == 3 && document.fa_payment.payment_mode.selectedIndex == 1)
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
	<%
	if(strSchoolCode.startsWith("CPU") || strSchoolCode.startsWith("CLDH") || strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("PHILCST") ||
	strSchoolCode.startsWith("DBTC") || strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("CIT") || strSchoolCode.startsWith("FATIMA")){%>
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
}**/
function UpdateAmtPaid() {
	var strAmountPayable = document.fa_payment.fine_amount.value;
	if(strAmountPayable.length == 0)
		return;
	if(document.fa_payment.amount.value.length == 0)
		document.fa_payment.amount.value=strAmountPayable;
}

///for fatima..
function updatePlanFatima() {
	<%if(vStudInfo == null || vStudInfo.size() == 0) {%>
		return;
	<%}else{%>

	if(document.fa_payment.perv_id.value != document.fa_payment.stud_id.value) {
		document.fa_payment.submit();
		return;
	}

	var strPlanRef = document.fa_payment.plan_ref[document.fa_payment.plan_ref.selectedIndex].value;
	//alert(strPlanRef);

	var strParam = "stud_ref=<%=(String)vStudInfo.elementAt(0)%>&sy_from=<%=(String)vStudInfo.elementAt(16)%>"+
					"&semester=<%=(String)vStudInfo.elementAt(18)%>&is_tempstud=<%=(String)vStudInfo.elementAt(10)%>&new_plan="+strPlanRef;
	var objCOAInput = document.getElementById("coa_info");
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=123&"+strParam;
	this.processRequest(strURL);
	<%}%>
}

//take me to d/p link.
function GoToDP() {
	location = "./install_assessed_fees_payment.jsp?stud_id="+document.fa_payment.stud_id.value;
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
function EnterPressed(e) {
		if(e.keyCode == 13) {
			this.ReloadPage();
			return;
		}
}
function MoveNext(e, objNext1) {//alert("I am here.");
	if(e.keyCode == 13) {
		var objElement = document.getElementById(objNext1);
		if(objElement)
			objElement.focus();
	}
}
function focusID() {
	if(document.fa_payment.amount)
		document.fa_payment.amount.focus();
	else
		document.fa_payment.stud_id.focus();
}

function UpdateSY() {
	<%
	if(!strDefaultTerm.equals("0")){%>
		return;
	<%}%>
	
	var strSemester = document.fa_payment.semester[document.fa_payment.semester.selectedIndex].value;

	if(strSemester == '1') {
		if(document.fa_payment.is_sy_updated.value == '0') {
			document.fa_payment.sy_from.value = eval(document.fa_payment.sy_from.value) + 1;
			document.fa_payment.sy_to.value   = eval(document.fa_payment.sy_to.value) + 1;
			
			document.fa_payment.is_sy_updated.value = '1';
		}
	}
	else if(document.fa_payment.is_sy_updated.value == '1') {
		document.fa_payment.sy_from.value = eval(document.fa_payment.sy_from.value) - 1;
		document.fa_payment.sy_to.value   = eval(document.fa_payment.sy_to.value) - 1;
		
		document.fa_payment.is_sy_updated.value = '0';
	}	
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

</script>
<body bgcolor="#D2AE72" onLoad="focusID()">
<form name="fa_payment" action="./payment_prior_enrolment.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF"><strong>::::
          PAYMENT PRIOR TO ENROLMENT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" height="25"> <%
	  if(WI.fillTextValue("fee_type").compareTo("1") ==0){//it is for sure temporary ID.%>
        Temp.
        <%}%>
        Student ID &nbsp; </td>
      <td width="30%"><input name="stud_id" type="text" size="16" value="<%=strStudID%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  onKeyUp="AjaxMapName(event, '0');"><!-- onKeyUp="EnterPressed(event)"--> 
	  <label id="coa_info" style="position:absolute; width:350px;"></label>
	  
	  </td>
      <td width="4%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="10%"><font size="1"> <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
        </font></td>
      <td width="39%">&nbsp;
<%if(!bolIsICA) {%>
	  <%//get here cutoff time information.
	  Vector vTempCO = new enrollment.FADailyCashCollectionDtls().getCurrentCutoffStat(dbOP, (String)request.getSession(false).getAttribute("userId"));//System.out.println(vTempCO);
	  //I have to get currency rate..
	  String strCurrencyInfo = new locker.Currency().getLatestCurrencyRate(dbOP);
	  if(vTempCO != null){%> <table width="85%" class="thinborderALL" cellpadding="0" cellspacing="0">
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
<%if(bolIsForDP && vStudInfo == null){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">SY-Term</td>
      <td colspan="4">
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
        - 
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
        <select name="semester" style="font-weight:bold; font-size:15px;" onChange="UpdateSY();">
		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select>
		<font style="font-size:9px; font-weight:bold; color:#0000FF">
		(SY-Term will be ignored if student already went thru' admission or student is new)
		</font>
		
		</td>
	  
    </tr>
<%}

if(strSchoolCode.startsWith("FATIMA") && bolIsForDP && vStudInfo != null){
if(strStudFatimaPlanRef == null)
	strStudFatimaPlanRef = WI.fillTextValue("plan_ref");
%>
    <tr >
      <td height="25">&nbsp;</td>
      <td style="font-size:9px; font-weight:bold; color:#0000FF">Apply Installment Plan </td>
      <td colspan="4">
	  	<select name="plan_ref" style="font-size:10px" onChange="updatePlanFatima()">
          <option value=""></option>
          <%=dbOP.loadCombo("plan_ref","PLAN_NAME,INSTALLMENT_FEE"," from FA_STUD_PLAN_FATIMA where is_valid = 1 order by PLAN_NAME", strStudFatimaPlanRef, false)%>
        </select>
		&nbsp;&nbsp;
		<label id="coa_info" style="font-size:9px; font-weight:bold"></label>	  </td>
    </tr>
<%}%>
    <tr >
      <td colspan="6"><hr size="1"></td>
    </tr>
  </table>
 <%
if(vStudInfo != null && vStudInfo.size() > 0) {
strTemp = (String)vStudInfo.elementAt(7);
//if null, may be basic student..
if(strTemp == null && vStudInfo.elementAt(6) != null)
	strTemp = dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(6)), false);
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="43%" height="25">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%> </strong></td>
      <td  colspan="4" height="25">Course :<strong><%=strTemp%></strong></td>
    </tr>
<%if(vStudInfo.elementAt(7) != null) {//do not show for basic student.. %>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Year :<strong><%=WI.getStrValue(vStudInfo.elementAt(6),"N/A")%></strong> </td>
      <td  colspan="4" height="25">Major : <strong><%=WI.getStrValue(vStudInfo.elementAt(8))%></strong></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">SY-Term : <strong><%=vStudInfo.elementAt(16)%> - <%=vStudInfo.elementAt(17)%>, <%=astrConvertToSem[Integer.parseInt((String)vStudInfo.elementAt(18))]%></strong></td>
      <td  colspan="4" height="25" style="font-weight:bold; font-size:22px;"><%if(strBatchNumber != null) {%>Batch: <%=strBatchNumber%><%}%></td>
    </tr>
  </table>
<%}//made just for display%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="25" colspan="9" bgcolor="#B9B292"><div align="center">FEE
          DETAILS </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="18">&nbsp;</td>
      <td width="46%" valign="bottom">Fee type</td>
      <td width="52%" valign="bottom">Fee rate</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td> <%
if(WI.fillTextValue("fee_type").compareTo("0") ==0)
	strTemp = "checked";
else
	strTemp = "";
//Rules changed -- I have to show what is selected -- do not show if it is not selected.
if(strTemp.length() > 0){%>
	<input type="radio" name="fee_type" value="0" <%=strTemp%> onClick="ReloadPage();"> Down Payment
	<input type="hidden" name="pmt_schedule" value="0">
<%
if(vFeeDtls != null) {
	strTemp = (String)vFeeDtls.elementAt(1);
	if(dPN > -1d) {
		//pn is given for difference..
		double dTemp = Double.parseDouble(strTemp);
		dTemp = dTemp - dPN;
		if(dTemp <= 0d)
			dTemp = 0d;
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(dTemp, true), ",","");
		//strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(dPN, true), ",","");
	}
%>
	<input type="hidden" name="reqd_dp" value="<%=strTemp%>">
<%}//set reqd d/p only if it is set.. %>


<%//collect the amount of downpayment.
}
else {%>
	<input type="hidden" name="fee_type" value="1">
        <%} if(vFeeDtls != null && WI.fillTextValue("fee_type").compareTo("1") ==0){//force the fee type tag to 1, and arrange the fee index in drop down %>
	<select name="fee_index" onChange="ReloadPage();">
<%
	//collect the first amount incase it is not selected.
	strTemp = (String)vFeeDtls.elementAt(1);
	for(int i = 1; i< vFeeDtls.size(); i += 3){
	if( WI.fillTextValue("fee_index").compareTo((String)vFeeDtls.elementAt(i+1)) ==0){
	strTemp = (String)vFeeDtls.elementAt(i);//collect the amount.
	%>
          <option value="<%=(String)vFeeDtls.elementAt(i+1)%>" selected><%=(String)vFeeDtls.elementAt(i+2)%></option>
          <%}else{%>
          <option value="<%=(String)vFeeDtls.elementAt(i+1)%>"><%=(String)vFeeDtls.elementAt(i+2)%></option>
          <%}%>
          <%}//end of for loop%>
        </select> <%}//end of else%> </td>
<%
	if(dApplFeePayable > 0d)
		strTemp = Double.toString(dApplFeePayable);
%>
      <td> <strong><%=CommonUtil.formatFloat(strTemp, true)%> </strong></td>
    </tr>
<%if(strSchoolCode.startsWith("VMA") && WI.fillTextValue("fee_type").equals("0")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:14px; font-weight:bold;">
<%
String strTemp2 = WI.fillTextValue("is_unearned");
if(strTemp2.equals("1"))
	strTemp2 = " checked";
else
	strTemp2 = "";
%>

	  <input type="checkbox" name="is_unearned" value="1" <%=strTemp2%>> Un-Earned (Downpayment Type)
	  </td>
      <td>&nbsp;</td>
    </tr>
<%}%>
  </table>
<% if(vStudInfo != null && vStudInfo.size() > 0 && !bolAlreadyPaid){
//check if student is having outstanding balance.
String strTemp2 = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
if(strTemp2 != null) {
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	fOperation.checkIsEnrolling(dbOP,strTemp2, (String)vStudInfo.elementAt(16),
					(String)vStudInfo.elementAt(17),(String)vStudInfo.elementAt(18));
	float fOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, strTemp2);
	if(fOutstanding > 0.1f || fOutstanding < -0.1f){
%>
  <table width="100%" bgcolor="#FFFFFF"><tr><td>
  <table width="50%" bgcolor="#000000"><tr><td height="25" bgcolor="#FFFFFF">
	  <font size="4" color="red"><strong>OLD ACCOUNT
        : <%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></td></tr></table>
</td></tr></table>
<%}} //end of showing outstanding balance.

  if(vFeeDtls != null && vFeeDtls.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center">PAYMENT
          DETAILS </div></td>
    </tr>
<%
if(strTemp != null && strTemp.length() > 0 && strTemp.endsWith(".0000"))
	strTemp = strTemp.substring(0, strTemp.length() - 2);

if(strSchoolCode.startsWith("CSA") && false) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
		<div id="change_div" style="visibility:hidden">
			<table>
		      	<td height="25">&nbsp;</td>
      			<td style="font-size:18px;">Change: ----------- NOT USED.. </td>
      			<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
			</table>
		</div>
	  	     <a href="javascript:computeChange()">Change</a>	  </td>
    </tr>
<%}%>
    <tr>
		<td colspan="5">
			<div id="change_div">
			<table>
		      	<td height="25">&nbsp;</td>
      			<td style="font-size:18px;">Change: </td>
      			<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
			</table>
		</div>
		</td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="22%">Amount paid </td>
      <td width="20%"><input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox_bigfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();MoveNext(event, '_1')" autocomplete="off"></td>
      <td width="12%">Check #</td>
      <td width="45%"> <%
strTemp = "";
if(request.getParameter("payment_type") == null || 	 request.getParameter("payment_type").trim().length() ==0 ||
	request.getParameter("payment_type").compareTo("0") == 0)
{
	strTemp = "disabled";
}%> <input name="check_number" type="text" size="16" value="<%=WI.fillTextValue("check_number")%>" <%=strTemp%> class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
<%if(strSchoolCode.startsWith("WNU")){%>
    <tr style="font-weight:bold">
      <td height="25">&nbsp;</td>
      <td style="font-size:11px; color:#0000FF">NSTP Amount Paid </td>
      <td><input name="nstp_amount" type="text" size="16" class="textbox" style="color:#0000FF; font-weight:bold"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Amount Tendered:</td>
      <td>
	  		<input name="amount_tendered" type="text" size="16" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();MoveNext(event, '_2')" autocomplete="off" id="_1">
	  </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Payment type</td>
      <td valign="top"><select name="payment_type" onChange="ShowHideCheckNO();">
          <option value="0">Cash</option>
          <%
if(request.getParameter("payment_type") == null && WI.fillTextValue("show_bank_post").equals("1"))
	strTemp = "8";
else
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

<%}if(bolShowBankPost) {//do not show to tellers.

	if(strTemp.compareTo("8") ==0){%>
			  <option value="8" selected>Bank Payment</option>
	<%}else{%>
			  <option value="8">Bank Payment</option>
	<%}
}%>
			  
			  
			  
			  </select></td>
      <td>&nbsp;</td>
      <td><select name="CHECK_FR_BANK_INDEX" style="font-size:10px" >
          <option value=""></option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE ,BRANCH"," from FA_BANK_LIST where is_valid = 1 order by bank_code", request.getParameter("CHECK_FR_BANK_INDEX"), false)%>
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
        <input name="or_number" type="text" size="18" value="<%=paymentUtil.generateORNumber(dbOP,(String)request.getSession(false).getAttribute("userIndex"), true)%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </b></font></td>
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
<%if(iAccessLevel > 1){%>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td colspan="3" height="25">
	  <a href="javascript:AddRecord();" id="_2">
	  <img src="../../../images/save.gif" border="0"></a>
	  <font size="1">click
        to save payment detail</font></td>
      <td width="10%"  height="25">&nbsp;</td>
    </tr>
<%}

	}//only if astrFeeDtls is not null.
%>
</table>
		  <!-- enter here all hidden fields for student. -->
	<input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
  <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(6)%>">
  <input type="hidden" name="semester" value="<%=(String)vStudInfo.elementAt(18)%>">
  <input type="hidden" name="sy_from" value="<%=(String)vStudInfo.elementAt(16)%>">
  <input type="hidden" name="sy_to" value="<%=(String)vStudInfo.elementAt(17)%>">
  <input type="hidden" name="is_tempstud" value="<%=(String)vStudInfo.elementAt(10)%>">

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
<input type="hidden" name="payment_for" value="<%=WI.fillTextValue("fee_type")%>">
<input type="hidden" name="pmt_receive_type" value="Internal">
<input type="hidden" name="payee_type" value="0"><!--Student/Parent/Relative/Grants-->
<input type="hidden" name="payment_mode" value="1"><!--Installment-->

 <input type="hidden" name="sukli">

<!--
<input type="hidden" name="amount_tendered" value="">
-->
<input type="hidden" name="perv_id" value="<%=WI.fillTextValue("stud_id")%>">


<input type="hidden" name="show_bank_post" value="<%=WI.fillTextValue("show_bank_post")%>">
<input type="hidden" name="is_sy_updated" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
