<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode= "";

if(strSchCode.startsWith("DLSHSI")) //tracking is for lasalle only.. 
	request.getSession(false).setAttribute("start_time_long_or",String.valueOf(new java.util.Date().getTime()));


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Back Accounts</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax2.js"></script>
<script language="JavaScript">
function focusID() {
	if(document.form_.AMOUNT)
		document.form_.AMOUNT.focus();
	else
		document.form_.stud_id.focus();
}
function ShowHideCheckNO() {
	if(!document.form_.payment_type)
		return;
	var iPaymentTypeSelected = document.form_.payment_type.selectedIndex;
	var strPaymentType = document.form_.payment_type[document.form_.payment_type.selectedIndex].text;
	var strPaymentTypeVal = document.form_.payment_type[document.form_.payment_type.selectedIndex].value;
	
	if(document.form_.prevent_chk_pmt && document.form_.prevent_chk_pmt.value == '1') {
		if(strPaymentTypeVal == '1' || strPaymentTypeVal == '5') {
			alert("Check Payment is not allowed.");
			document.form_.payment_type.selectedIndex = 0;
			return;
		} 
	}

	if(iPaymentTypeSelected == 1 || iPaymentTypeSelected == 2 || strPaymentType == "Bank Payment") {
		document.form_.CHECK_FR_BANK_INDEX.disabled = false;
		document.form_.check_number.disabled = false;
	}
	else {
		document.form_.CHECK_FR_BANK_INDEX.selectedIndex = 0;
		document.form_.CHECK_FR_BANK_INDEX.disabled = true;
		document.form_.check_number.disabled = true;
	}


	if(iPaymentTypeSelected == 2)
		showLayer('myADTable1');
	else
		hideLayer('myADTable1');
	document.form_.chk_amt.value = "";
	document.form_.cash_amt.value = "";

	if(iPaymentTypeSelected == 3)
	{
		showLayer('_empID');
		showLayer('_empID1');
	}
	else
	{
		hideLayer('_empID');
		hideLayer('_empID1');
		document.form_.SD_EMP_ID.value = "";
	}

	if(iPaymentTypeSelected > 3 &&  strPaymentType != "Bank Payment")//credit card..
		showLayer('credit_card_info');
	else
		hideLayer('credit_card_info');

/**

	if(document.form_.payment_type.selectedIndex == 1 || document.form_.payment_type.selectedIndex == 3) {
		document.form_.CHECK_FR_BANK_INDEX.disabled = false;
		document.form_.check_number.disabled = false;
	}
	else {
		document.form_.CHECK_FR_BANK_INDEX.selectedIndex = 0;
		document.form_.CHECK_FR_BANK_INDEX.disabled = true;
		document.form_.check_number.disabled = true;
	}
	//show or hide emp ID input fields.
	if(document.form_.payment_type.selectedIndex == 2)
	{
		showLayer('_empID');
		showLayer('_empID1');
		document.form_.hide_search.src = "../../../images/search.gif";
	}
	else
	{
		hideLayer('_empID');
		hideLayer('_empID1');
		document.form_.SD_EMP_ID.value = "";
		document.form_.hide_search.src = "../../../images/blank.gif";
	}
	if(document.form_.payment_type.selectedIndex == 3)
		showLayer('myADTable1');
	else
		hideLayer('myADTable1');
	document.form_.chk_amt.value = "";
	document.form_.cash_amt.value = "";
**/
}
function ReloadPage()
{
	document.form_.addRecord.value="";
	document.form_.submit();
}
function AddRecord()
{
	<%if(strSchCode.startsWith("SPC")){%>
		if(document.form_.amount_tendered.value.length == 0) {
			alert("Please enter amount tendered.");
			document.form_.amount_tendered.focus();
			return;
		}
	<%}%>
	//check change should not be -ve..
	if(document.getElementById("change_")) {
		var strChange = document.getElementById("change_").innerHTML;
		if(strChange.length > 0 && strChange.charAt(0) == "-") {
			alert("Amount tendered is less than Amount Paid.");
			document.form_.amount_tendered.focus();
			return;
		}
	}
	document.form_.addRecord.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	<%
	if(strSchCode.startsWith("CPU") || strSchCode.startsWith("CLDH") || strSchCode.startsWith("WNU") || strSchCode.startsWith("PHILCST") || strSchCode.startsWith("DBTC") ||
	strSchCode.startsWith("UL") || strSchCode.startsWith("FATIMA")){%>
		this.SukliComputation();
	<%}//show Sukli computation%>
	document.form_.submit();

}
///this is added for CLDH and CPU only.
function SukliComputation() {
	return;
	var vAmtPaid = document.form_.AMOUNT.value;

	var vAmtReceived  = prompt("Please enter Amount received.", vAmtPaid);
    if(vAmtReceived == null || vAmtReceived.length == 0)  {
		vAmtReceived = vAmtPaid;
	}
	document.form_.sukli.value = vAmtReceived;
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function computeCashChkAmt() {
	var totAmt  = document.form_.AMOUNT.value;
	var chkAmt  = document.form_.chk_amt.value;
	var cashAmt = document.form_.cash_amt.value;

	if(totAmt.length == 0)
		return;
	if(chkAmt.length == 0) {
		document.form_.cash_amt.value = "";
		return;
	}
	cashAmt = eval(totAmt - chkAmt);
	document.form_.cash_amt.value = eval(cashAmt);
}

//// - all about ajax..
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
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
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

function computeChange() {
	var strAmtTendered = prompt('Please enter Amount tendered.','');
	if(strAmtTendered == null || strAmtTendered.length == 0)
		return;
	document.all.change_div.style.visibility='visible';
	document.form_.amount_tendered.value = strAmtTendered;

	AjaxUpdateChange();
}
/**
function AjaxUpdateChange() {
	<%if(!strSchCode.startsWith("CSA")) {%>
		return;
	<%}%>
	var strAmtPaid     = document.form_.AMOUNT.value;
	var strAmtTendered = document.form_.amount_tendered.value;
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
function AjaxUpdateChange(e) {
	if(e) {
		if(e.keyCode == 13) {
			AddRecord();
			return;
		}
	}
		var strAmtPaid     = document.form_.AMOUNT.value;
		var strAmtTendered = document.form_.amount_tendered.value;
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
	var strAmtPaid     = document.form_.AMOUNT.value;

	var objCOAInput = document.getElementById("format_amt");
	this.InitXmlHttpObject3(objCOAInput, 2);//I want to get value in this.retObj
	if(this.xmlHttp2 == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=153&show_=0&amt_="+strAmtPaid;
	this.processRequest2(strURL);
}
function ViewCheckPmtDtls(strID, strSYFr, strSYTo, strSem)
{
	var pgLoc = "./view_check_payments.jsp?stud_id="+strID+"&sy_from="+strSYFr+"&sy_to="+strSYTo+"&semester="+strSem;
	var win=window.open(pgLoc,"PrintWindow",'width=640,height=480,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,enrollment.FAPayment,enrollment.FAPaymentUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);

	if(WI.fillTextValue("print_pg").compareTo("1") == 0){%>
		<jsp:forward page="./back_account_print.jsp" />
	<%return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Back account","back_account.jsp");
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
	if(WI.fillTextValue("stud_id").length() > 0) {
		strTemp = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
		if(strTemp != null && dbOP.strBarcodeID != null && !dbOP.strBarcodeID.equals(strTemp) ) {
			dbOP.cleanUP();
			response.sendRedirect("./back_accounts.jsp?stud_id="+dbOP.strBarcodeID);
			return;
		}
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"back_account.jsp");
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

FAPayment faPayment = new FAPayment();
Vector vRetResult = new Vector();Vector vBasicInfo = null;
boolean bolIsBasic = false;

FAPaymentUtil paymentUtil = new FAPaymentUtil();

if(WI.fillTextValue("stud_id").length() > 0){
	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
	//may be it is basic student..
	if(vBasicInfo == null) {//may be it is the teacher/staff
		strErrMsg = paymentUtil.getErrMsg();
		paymentUtil.setIsBasic(true);
		vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
		if(vBasicInfo == null)
			paymentUtil.setIsBasic(false);
		else {
			strErrMsg = null;
			bolIsBasic = true;
		}
	}

}




strTemp = WI.fillTextValue("addRecord");
if(strTemp.length() > 0) {
	enrollment.FABackAccountPmt backAcc = new enrollment.FABackAccountPmt();
	if(!paymentUtil.isORIssuedToTeller(dbOP, request.getParameter("or_number"), (String)request.getSession(false).getAttribute("userIndex"), strSchCode))
		strErrMsg = paymentUtil.getErrMsg();
	else if(backAcc.savePayment(dbOP, request)) {
		//forward to printing receipt.
		dbOP.cleanUP();
		String strSukli = WI.fillTextValue("sukli");
		if(strSukli.length() > 0) {
			//keep change in attribute.
			double dAmtReceived = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""));
			dAmtReceived = dAmtReceived - Double.parseDouble(WI.fillTextValue("AMOUNT"));
			strSukli = "&sukli="+ CommonUtil.formatFloat(dAmtReceived,true);
		}
		response.sendRedirect(response.encodeRedirectURL("./install_assessed_fees_print_receipt.jsp?view_status=0&or_number="+
		request.getParameter("or_number")+"&pmt_schedule="+request.getParameter("pmt_schedule")+"&pmt_for_=Back%20Account"+strSukli));
		return;
	}
	else {
		strErrMsg = backAcc.getErrMsg();
	}

}

String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
String[] astrConvertYR = {"N/A","1st yr","2nd yr","3rd yr","4th yr","5th yr","6th yr","7th yr"};


boolean bolIsICA = false;
String strSQLQuery = "select info5 from sys_info";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && strSQLQuery.equals("ICA"))
	bolIsICA = true;

//boolean bolIsDatePaidReadonly = false;
//if(strSchCode.startsWith("UC") || strSchCode.startsWith("EAC") || strSchCode.startsWith("FATIMA"))
//	bolIsDatePaidReadonly = true;
boolean bolIsDatePaidReadonly = comUtil.isPaymentDateReadOnly(dbOP, request);

boolean bolShowBankPost = false;
//if(strSchCode.startsWith("UB") || strSchCode.startsWith("FATIMA"))
	bolShowBankPost = true;

boolean bolIsChkPmtAllowed = true;
//for Lasalle, if there is a bounced check, do not allow check payment.


boolean bolIsCCPmtAllowed = false;
if(strSchCode.startsWith("PWC") || request.getSession(false).getAttribute("is_cc_allowed") != null)
	bolIsCCPmtAllowed = true;
%>
<form name="form_" method="post" action="./back_accounts.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#A49A6A">
    <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
        BACK ACCOUNTS PAYMENT PAGE ::::</strong></font></div></td>
  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp; <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
<%if(strSchCode.startsWith("PHILCST")){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" style="font-weight:bold; color:#0000FF; font-size:14px;">
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
		<%if (vBasicInfo != null && vBasicInfo.size() > 0){
		Vector vChkPmt = null;
		enrollment.CheckPayment chkPmt = new enrollment.CheckPayment();
		vChkPmt = chkPmt.getChkPaymentDtls(dbOP, WI.fillTextValue("stud_id"),(String)vBasicInfo.elementAt(8),(String)vBasicInfo.elementAt(5));
		//System.out.println((String)vBasicInfo.elementAt(8)+" :: "+(String)vBasicInfo.elementAt(5));
		//System.out.println(chkPmt.getErrMsg());
		if (vChkPmt!= null && vChkPmt.size()>0){
		if (vChkPmt.elementAt(0)!=null){%>
		<tr> <td colspan="4">
			<table width="90%" class="thinborderALL" cellpadding="0" cellspacing="0">
			<tr>
				<td>
				<%if (((String)vChkPmt.elementAt(0)).equals("0")){
					if(strSchCode.startsWith("DLSHSI"))
						bolIsChkPmtAllowed = false;
				%>
				<font color="#FF0000" size="3"><strong>Having BLOCKED check
				  payment</strong></font>
				<%} else {%>
				<font size="3">Having <strong><%=(String)vChkPmt.elementAt(0)%></strong> check payment(s)</font><%}%>
	<a href='javascript:ViewCheckPmtDtls("<%=WI.fillTextValue("stud_id")%>","<%=(String)vBasicInfo.elementAt(8)%>", "<%=(String)vBasicInfo.elementAt(9)%>","<%=(String)vBasicInfo.elementAt(5)%>");'><img src="../../../images/view.gif" border="0"></a>
				  <font size="1">View Dtls</font></td>
			</tr>
			</table>
		</td></tr>
		<%}}}%>	  
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%">Enter Student ID</td>
      <td width="26%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
        &nbsp;&nbsp;<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>      </td>
      <td width="51%" height="25">
<%if(!bolIsICA) {%>
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
}//do not show ICA.		%> </td>
    </tr>
    <tr >
      <td></td>
      <td></td>
      <td colspan="2"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="25"></a> </td>
    </tr>
    <tr >
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(vBasicInfo != null && vBasicInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="37%" height="25">Student name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td width="61%" height="25"  colspan="4">Last Year/Term of Attendance :<strong>
<%if(!bolIsBasic){%>
        <%=astrConvertYR[Integer.parseInt(WI.getStrValue(vBasicInfo.elementAt(4),"0"))]%>,
<%}%>
		<%=(String)vBasicInfo.elementAt(8) + " - "+(String)vBasicInfo.elementAt(9)%> (<%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%>)</strong>
		<input type="hidden" name="sy_from" value="<%=(String)vBasicInfo.elementAt(8)%>">
		<input type="hidden" name="sy_to" value="<%=(String)vBasicInfo.elementAt(9)%>">
		<input type="hidden" name="semester" value="<%=(String)vBasicInfo.elementAt(5)%>">
		<input type="hidden" name="year_level" value="<%=(String)vBasicInfo.elementAt(4)%>">

	  </td>
    </tr>
<%if(bolIsBasic) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">Grade : <b><%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vBasicInfo.elementAt(4)))%></b></td>
    </tr>
<%}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
        <%
	  if(vBasicInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
        <%}%>
        </strong></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">Old Account :
<%
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	fOperation.isEnrolling(true);
	//I must enter the sy/term/year level, else it does not give me correct amount..
	float fOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vBasicInfo.elementAt(0),true,true, (String)vBasicInfo.elementAt(8), (String)vBasicInfo.elementAt(9), (String)vBasicInfo.elementAt(5),(String)vBasicInfo.elementAt(4));
%><font size="2"><strong><%=CommonUtil.formatFloat(new Double(fOutstanding).doubleValue(),true)%></strong></font>
</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(fOutstanding > 0f || true) {
if(fOutstanding <0f)
	fOutstanding = 0f;
%>
    <tr>
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center">PAYMENT
          DETAILS </div></td>
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
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Amount paid </td>
      <td width="29%"> <%
strTemp = WI.fillTextValue("AMOUNT");
if(strTemp.length() == 0 && !strSchCode.startsWith("UC"))
	strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(fOutstanding,true),",","");

%> <input name="AMOUNT" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" onKeyUp="AjaxFormatAmount();AjaxUpdateChange();">
        Php </td>
      <td colspan="2"><label id="format_amt" style="font-size:18px; font-weight:bold; color:#00CCFF"></label>	</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Amount Tendered </td>
      <td>
	  		<input name="amount_tendered" type="text" size="16" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange(event);">	  </td>
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
      <td>Date paid</td>
      <td> <%
strTemp = WI.fillTextValue("DATE_PAID");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%> <input name="DATE_PAID" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%if(!bolIsDatePaidReadonly) {%>
        <a href="javascript:show_calendar('form_.DATE_PAID');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
<%}%>		</td>
      <td width="15%">Reference number</td>
      <td width="38%"> <input name="or_number" type="text" size="18" value="<%=paymentUtil.generateORNumber(dbOP,(String)request.getSession(false).getAttribute("userIndex"), true)%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Payment type</td>
      <td valign="top"><font size="1">
		  <select name="payment_type" onChange="ShowHideCheckNO();">
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
				if(strTemp.equals("2")){%>
				  <option value="2" selected>Salary deduction</option>
				  <%}else{%>
				  <option value="2">Salary deduction</option>
				<%}
if(strSchCode.startsWith("AUF") || strSchCode.startsWith("CSA") || bolIsCCPmtAllowed){
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
        <input name="text" type="text" class="textbox_noborder" id="_empID" value="Emp ID:" size="6" readonly="yes">
        <input type="text" name="SD_EMP_ID" value="<%=WI.fillTextValue("SD_EMP_ID")%>" size="12" id="_empID1" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearchFaculty();"><img src="../../../images/search.gif" width="25" height="23" border="0" id="hide_search"></a>
        </font> </td>
      <td colspan="2" valign="top"><font size="1">&nbsp;<strong>Additional Payment
        for Information: </strong><br>
        <input name="pmt_for_dtls" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("pmt_for_dtls")%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </font></td>
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
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;&nbsp;&nbsp; <select name="CHECK_FR_BANK_INDEX" style="font-size:10px" >
          <option value=""></option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH",
		" from FA_BANK_LIST where is_valid = 1 order by bank_code", request.getParameter("CHECK_FR_BANK_INDEX"), false)%>
        </select> </td>
    </tr>
    <tr id="myADTable1">
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">Check amount:
        <input name="chk_amt" type="text" size="12" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','AMOUNT');computeCashChkAmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','chk_amt');computeCashChkAmt();">
        , cash amount:
        <input name="cash_amt" type="text" size="12" class="textbox_noborder" readonly="yes"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">	  </td>
    </tr>
    <tr>
      <td height="25"></td>
	  <td></td>
      <td colspan="3" id="credit_card_info">
		  <table class="thinborder" cellpadding="0" cellspacing="0" width="70%" bgcolor="#bbbbbb">
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
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="19%">&nbsp;</td>
      <td colspan="2"><a href="javascript:AddRecord();"><img name="hide_save" src="../../../images/save.gif" border="0"></a>
        <font size="1">click to save entries </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="31%" valign="middle">&nbsp;</td>
      <td width="50%" valign="middle">&nbsp;</td>
    </tr>
    <%}//only if fOutstanding is > 0f
else {%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="middle"><strong><font size="4">Back account should be > 0</font></strong></td>
    </tr>
    <%}%>
  </table>
<%}//only if stud info is not null.%>
<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
</table>
<script language="JavaScript">
ShowHideCheckNO();
</script>

<input type="hidden" name="addRecord">
 <input type="hidden" name="sukli">

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
