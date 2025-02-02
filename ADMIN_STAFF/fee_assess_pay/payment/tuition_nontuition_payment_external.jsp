<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";


if(strSchoolCode.startsWith("SPC")) {
	response.sendRedirect("./tuition_nontuition_payment_external_spc.jsp");
	return;
}

if(strSchoolCode.startsWith("DLSHSI")) //tracking is for lasalle only.. 
	request.getSession(false).setAttribute("start_time_long_or",String.valueOf(new java.util.Date().getTime()));
%>
<%@ page language="java" import="utility.*,enrollment.CheckPayment, enrollment.FAAssessment,enrollment.FAPaymentUtil,enrollment.FAPayment,java.util.Vector" buffer="16kb" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	WebInterface WI = new WebInterface(request);


//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-nontuition external fees","tuition_nontuition_payment_external.jsp");
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
															"tuition_nontuition_payment_external.jsp");
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

	int iListCount = 0;

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
/**
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
		document.fa_payment.payee_name.focus();
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
//// - all about ajax..
function AjaxMapName(e, strPos) {
		if(e.keyCode == 13) {
			
			document.fa_payment.amount.focus();
			return;
		}


		var strCompleteName;
		strCompleteName = document.fa_payment.payee_name.value;
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
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.fa_payment.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.fa_payment.payee_name.value = strName;
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
	return AjaxUpdatePaymentInfo();
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


	var objCOAInput = document.fa_payment.amount;
	this.InitXmlHttpObject(objCOAInput, 1);//I want to get value in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=150&input="+strAmtPaid;
	this.processRequest(strURL);
}

function AutoScroll() {
	var strChar  = document.fa_payment.auto_scroll_fee.value.charAt(0).toLowerCase();
	var iIndex;
	var objChar;
	eval('objChar=document.fa_payment._'+strChar);
	if(objChar) { 
		iIndex = objChar.value;
		var iIndex2 = eval(iIndex) + 1000;
		//I have to check if there is any value next to the first char entered.
		var obj2; var strTemp;
		eval('obj2=document.fa_payment._'+strChar+'_');
		if(obj2)
			iIndex2 = obj2.value;
		//alert(iIndex2);
//alert(iIndex);alert(iIndex2);
		//I have to now match the whole word.
		strChar  = document.fa_payment.auto_scroll_fee.value.toLowerCase();
		if(strChar.length > 1) {
			//iIndex = -1;
			for(i = iIndex; i< iIndex2; ++i) {
				//alert(i);
				eval('obj2=document.fa_payment.fee_name'+i);
				//alert(i);
				if(!obj2)
					break;
				strTemp = obj2.value.toLowerCase();
				//alert(strTemp);
				if(strTemp.indexOf(strChar) == 0) {
					iIndex = i;
					break;;
				}
				else
					iIndex = -1;
			}
		}
		if(iIndex > -1)
			document.getElementById("_id"+iIndex).focus();
			
		document.fa_payment.auto_scroll_fee.focus();
		//alert(objChar.value);
	}
}
function HideLayer(strDiv) {
	if(strDiv == '1')
		document.all.processing.style.visibility='hidden';	
}
function ShowLayer(strDiv) {
	if(strDiv == '1')
		document.all.processing.style.visibility='visible';	
}
function GroupClicked(objChkBox, iGroupRef) {
	var bolIsChecked = objChkBox.checked;
	//get the items to be checked.
	var obj;
	eval('obj=document.fa_payment._group_ref'+iGroupRef);
	if(!obj)
		return;
		
	var strFeeToSelect = obj.value;
	var strTemp;
	var iIndexOf;
	while(true) {
		iIndexOf = strFeeToSelect.indexOf(",");
		if(iIndexOf == -1) {
			eval('obj=document.fa_payment.fee_i'+strFeeToSelect);
			obj.checked = bolIsChecked;
			break;
		}
		strTemp = strFeeToSelect.substring(0,iIndexOf);
		//alert(strTemp);
		strFeeToSelect = strFeeToSelect.substring(iIndexOf + 1);
		//alert(strFeeToSelect);
		eval('obj=document.fa_payment.fee_i'+strTemp);
		obj.checked = bolIsChecked;
	}
	this.UpdatePaymentInfo();
	
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%
FAPaymentUtil pmtUtil = new FAPaymentUtil();
FAPayment faPayment   = new FAPayment();

if(WI.fillTextValue("addRecord").equals("1")) {
	if(!pmtUtil.isORIssuedToTeller(dbOP, request.getParameter("or_number"), (String)request.getSession(false).getAttribute("userIndex"), strSchoolCode))
		strErrMsg = pmtUtil.getErrMsg();
	else if(faPayment.savePayment(dbOP,request,false)) {
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./install_assessed_fees_print_receipt.jsp?view_status=0&or_number="+request.getParameter("or_number")));
		return;
	}
	else
		strErrMsg = faPayment.getErrMsg();
}

if(strErrMsg == null) 
	strErrMsg = "";

String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

boolean bolIsCCPmtAllowed = false;
if(strSchoolCode.startsWith("PWC") || request.getSession(false).getAttribute("is_cc_allowed") != null)
	bolIsCCPmtAllowed = true;
boolean bolShowBankPost = false;
if(strSchoolCode.startsWith("UB") || strSchoolCode.startsWith("FATIMA") || strSchoolCode.startsWith("DLSHSI"))
	bolShowBankPost = true;

boolean bolShowRemark = false;
if(request.getSession(false).getAttribute("PMT_REMARK_ALLOWED") != null)
	bolShowRemark = true;



boolean bolIsDatePaidReadonly = comUtil.isPaymentDateReadOnly(dbOP, request);
boolean bolIsICA = false;
strTemp = (String)request.getSession(false).getAttribute("info5");
if(strTemp != null && strTemp.equals("ICA"))
	bolIsICA = true;

Vector vFeeIndexes = new Vector();
int iIndexCount = 0;


///I have to get the list of groups here. 
Vector vGroupDtls = new Vector();
Vector vGroupList = new Vector();
Vector vGroupList2 = new Vector();
int iGroupRef = 0;
String strSQLQuery = "select group_name, fee_name_t from FA_OTH_SCH_FEE_GROUP order by group_name";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
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

<form name="fa_payment" action="./tuition_nontuition_payment_external.jsp" method="post">
<input type="hidden" name="amount_shown" value="0">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          SCHEDULE ASSESSMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong>
	  <div align="right">
		<a href="./tuition_nontuition_payment.jsp">Go to Internal Payment</a>	
	</div>
	  </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%if(!bolIsICA) {//get here cutoff time information.
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
}%>	  
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Payee Name </td>
      <td colspan="2"><input name="payee_name" type="text" size="40" value="<%=WI.fillTextValue("payee_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event, '1');">
		<label id="coa_info" style="position:absolute"></label>		</td>
    </tr>
    <!-- this is current school year the payee is paying. if payee is paying for 2 times,
	I can differentiate for school year. -->
    <tr >
      <td height="25">&nbsp;</td>
      <td>School year</td>
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
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="17%">Date Paid</td>
      <td width="36%"> <%
strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%> <input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%if(!bolIsDatePaidReadonly) {%>
        <a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
<%}%>	  </td>
      <td width="65%">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3" class="thinborderTOPBOTTOM" style="font-size:18px; font-weight:bold">::: PAYMENT DETAILS ::: </td>
      <td colspan="2" class="thinborderTOPBOTTOM" style="font-size:11px; font-weight:bold">Auto Scroll Fee: 
		  <input type="text" name="auto_scroll_fee" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="20" maxlength="32"
		  onKeyUp="AutoScroll();">
		  <%if(vGroupDtls.size() > 0) {%>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  <a href="javascript:ShowLayer('1');">
		  Show Grouped Fees
		  </a>
		  <%}%>
		  <div id="processing" class="processing"  style="visibility:hidden; overflow:auto">
		  	<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#FFCC99">
				<tr><td valign="top">
					<table width="100%" cellpadding="0" cellspacing="0">
					  <tr>
					  	<td>&nbsp;</td>
						<td valign="top" align="right" class="thinborderNONE" height="20"><a href="javascript:HideLayer(1)">Close Window X</a></td>
					  </tr>
					  <%while(vGroupList.size() > 0) {%>
						<tr>
							<td height="20" width="50%"><input type="checkbox" name="_group_<%=++iGroupRef%>" onClick="GroupClicked(document.fa_payment._group_<%=iGroupRef%>,'<%=iGroupRef%>');"> <%=vGroupList.remove(0)%></td>
							<td width="50%"><%if(vGroupList.size() > 0) {%><input type="checkbox" name="_group_<%=++iGroupRef%>" onClick="GroupClicked(document.fa_payment._group_<%=iGroupRef%>,'<%=iGroupRef%>');"> <%=vGroupList.remove(0)%><%}%></td>
						</tr>
					  <%}%>
					</table>
				</td></tr>
			</table>
          </div>
			
	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="4">&nbsp;</td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td width="18%" valign="top" style="font-size:18px; font-weight:bold"><br>Other Charge
	  <br>
	  <label id="oc_detail" style="font-size:8px; font-weight:normal"></label>	  </td>
      <td colspan="3" style="font-size:18px; font-weight:bold">

	  <div style="height:250px; overflow:scroll">
	  <table width="100%" cellpadding="0" cellspacing="0" align="center" class="thinborder">
	  	<tr>
			<td colspan="2" align="center" class="thinborder" bgcolor="#FFCC99"><strong>Select Multiple Fee</strong></td>
		</tr>
		<%
		strTemp = "select OTHSCH_FEE_INDEX, fee_name, amount from FA_OTH_SCH_FEE where is_del=0 and is_valid=1 and year_level=0 and "+
		"sy_index=(select sy_index from FA_SCHYR where sy_from="+(String)request.getSession(false).getAttribute("cur_sch_yr_from")+")";

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
			rs = dbOP.executeQuery(strTemp);//System.out.println(vGroupList2);
			while(rs.next()){
				strTemp = String.valueOf(rs.getString(2).toLowerCase().charAt(0));
				if(vFeeIndexes.indexOf(strTemp) == -1) {
					vFeeIndexes.addElement(strTemp);
					vFeeIndexes.addElement(Integer.toString(iIndexCount));
				}
				
				///I have to map now group fees.
				iGroupRef = vGroupDtls.indexOf(rs.getString(2).toLowerCase());
				if(iGroupRef > -1) {//it is grouped..
					//System.out.println(vGroupDtls.elementAt(iGroupRef - 1));
					iGroupRef = vGroupList2.indexOf(vGroupDtls.elementAt(iGroupRef - 1));
					//System.out.println(iGroupRef);
					if(iGroupRef > -1) {
						strTemp = (String)vGroupList2.elementAt(iGroupRef + 1);
						if(strTemp == null)
							strTemp = Integer.toString(iIndexCount);
						else	
							strTemp +=","+ Integer.toString(iIndexCount);		
						vGroupList2.setElementAt(strTemp, iGroupRef + 1);
					}
						
				}
				
				++iIndexCount;
 		%>
			<tr class="nav" id="msg<%=iListCount%>" onMouseOver="navRollOver('msg<%=iListCount%>', 'on')" onMouseOut="navRollOver('msg<%=iListCount%>', 'off')">
				<td class="thinborder" width="77%" style="font-size:9px;">
				<label for="_id<%=iListCount%>">
				<%if(WI.fillTextValue("fee_i"+iListCount).length() > 0)
					strTemp = " checked";
				  else
				  	strTemp = "";
				%>
				<input type="checkbox" id="_id<%=iListCount%>" name="fee_i<%=iListCount%>" value="<%=rs.getString(1)%>" onClick="UpdatePaymentInfo();" <%=strTemp%>><%=rs.getString(2)%>			    </label>
				<input type="hidden" name="fee_name<%=iListCount%>" value="<%=rs.getString(2)%>">			  </td>
			  <td width="23%" class="thinborder">
			  <%
			  strTemp = WI.fillTextValue("fee_amt"+iListCount);
			  if(strTemp.length() == 0)
			  	strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(rs.getDouble(3), true), ",","");
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
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('fa_payment','amount');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('fa_payment','amount');AjaxUpdateChange();MoveNext(event, '_2')" class="textbox_bigfont" id="_1" readonly="yes">      </td>
      <td colspan="2">&nbsp;</td>
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
        <input type="text" name="cash_adv_from_emp_id" value="<%=WI.fillTextValue("cash_adv_from_emp_id")%>" size="12" id="_empID1" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="-1">
        <a href="javascript:OpenSearchFaculty();" tabindex="-1"><img src="../../../images/search.gif" width="25" height="23" border="0" id="hide_search"></a>


        </font> </td>
      <td width="19%">Ref number</td>
      <td width="33%"><font size="1"><b>
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
<%}//only if iAccessLevel > 1%>
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
<input type="hidden" name="is_external" value="1">
<%while(vFeeIndexes.size() > 0) {
	strTemp = (String)vFeeIndexes.remove(0);%>
	<input type="hidden" name="_<%=strTemp%>" value="<%=vFeeIndexes.remove(0)%>">
	<%if(vFeeIndexes.size() > 0) {%>
		<input type="hidden" name="_<%=strTemp%>_" value="<%=vFeeIndexes.elementAt(1)%>">
	<%}%>	
<%}%>
<%
iGroupRef = 0;
while(vGroupList2.size() > 0) {
	vGroupList2.remove(0);
	if(vGroupList2.elementAt(0) == null) {
		vGroupList2.remove(0);
		continue;
	}
	++iGroupRef;
	%>
	<input type="hidden" name="_group_ref<%=iGroupRef%>" value="<%=vGroupList2.remove(0)%>">
<%}%>



</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
