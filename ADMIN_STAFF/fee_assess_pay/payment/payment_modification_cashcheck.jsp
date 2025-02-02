<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strPaymentType = null;//chsh/check or cash & check.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Modifications(Cash/Check)","payment_modification_cashcheck.jsp");
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
														"payment_modification_cashcheck.jsp");
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

FAPayment faPayment = new FAPayment();
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(faPayment.updateCashChkPmtTypeInfo(dbOP, request)) {
		strErrMsg = "Payment Information updated.";
		
		String strSQLQuery = null;
		if(WI.fillTextValue("pmt_type").equals("3"))
			strSQLQuery = "update fa_stud_payment set is_manually_posted = 1 where payment_index = "+WI.fillTextValue("info_index");
		else
			strSQLQuery = "update fa_stud_payment set is_manually_posted = 0 where payment_index = "+WI.fillTextValue("info_index");
			
		System.out.println(strSQLQuery);
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);

	}
	else
		strErrMsg = faPayment.getErrMsg();
}


double dTotalAmt = 0d;
double dChkAmt   = 0d;
double dCashAmt  = 0d;

int iPmtType = 0;
if(strErrMsg == null && WI.fillTextValue("or_number").length() > 0){
	vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));
	if(vRetResult == null)
		strErrMsg = faPayment.getErrMsg();
	else {
		String[] astrConvertPmtType = {"Cash","Check","Cash Advance","Refunded","Refund Transferred","Check+Cash","Credit Card","ePay Payment",""};
		iPmtType = Integer.parseInt((String)vRetResult.elementAt(45));
		strPaymentType = astrConvertPmtType[iPmtType];
		if(iPmtType > 1) {
			strErrMsg = "OR can be modified only if type is cash , or check or cash + check. This OR Payment Type is : "+strPaymentType;
			vRetResult = null;
		}
		dTotalAmt  = Double.parseDouble((String)vRetResult.elementAt(11));
		dChkAmt = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(36),"0"));
		dCashAmt   = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(37),"0"));

		if(iPmtType == 0 && dChkAmt > 0d && dCashAmt > 0d)
			strPaymentType = "Cash + Check";
		if(iPmtType == 0 && vRetResult.elementAt(51) != null) {
			strPaymentType = "Bank Payment";
			iPmtType = 3;
		}
	}
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.page_action.value="";
	document.form_.submit();
}
function focusID() {
	document.form_.or_number.focus();
}
function CashChkClicked(strSelected) {
	var showMsg = true;
	if(strSelected == '') {
		<%if(iPmtType == 0 && dChkAmt == 0d){%>
			strSelected = '0';
		<%}else if(iPmtType == 1){%>
			strSelected = '1';
		<%}else if(iPmtType == 3){%>
			strSelected = '3';
		<%}else{%>
			strSelected = '2';
		<%}%>
		showMsg = false;
	}


	if(strSelected == '0') {
		hideLayer('chk_amt_');
		hideLayer('cash_amt_');
		hideLayer('bank_');
		hideLayer('chk_no_');

		hideLayer('chk_amt_label');
		hideLayer('cash_amt_label');
		hideLayer('bank_label');
		hideLayer('chk_no_label');

		document.form_.chk_amt.value = "";
		document.form_.chk_no.value = "";
		document.form_.cash_amt.value = "";
		document.form_.CHECK_FR_BANK_INDEX.selectedIndex = 0;
		return;
	}
	if(strSelected == '1') {//check payment.
		hideLayer('chk_amt_');
		hideLayer('cash_amt_');

		hideLayer('chk_amt_label');
		hideLayer('cash_amt_label');

		document.form_.chk_amt.value = "";
		document.form_.cash_amt.value = "";

		showLayer('bank_');
		showLayer('bank_label');
		showLayer('chk_no_');
		showLayer('chk_no_label');

		if(showMsg)
			alert('Please select bank information of the check');
		return;
	}
	if(strSelected == '3') {//Bank Payment
		hideLayer('chk_amt_');
		hideLayer('cash_amt_');

		hideLayer('chk_amt_label');
		hideLayer('cash_amt_label');

		hideLayer('chk_no_');
		hideLayer('chk_no_label');
		
		document.form_.chk_amt.value = "";
		document.form_.cash_amt.value = "";

		showLayer('bank_');
		showLayer('bank_label');

		if(showMsg)
			alert('Please select bank information of the check');
		return;
	}
	showLayer('chk_amt_');
	showLayer('cash_amt_');
	showLayer('bank_');
	showLayer('chk_no_');

	showLayer('chk_amt_label');
	showLayer('cash_amt_label');
	showLayer('chk_no_label');

	if(showMsg)
		alert('Please encode amount in cash field only. System will compute the check amount.');
}
function computeCashChkAmt() {
	var totAmt  = document.form_.total_amt.value;
	var chkAmt  = document.form_.chk_amt.value;
	var cashAmt = document.form_.cash_amt.value;

	if(totAmt.length == 0)
		return;
	if(cashAmt.length == 0) {
		document.form_.cash_amt.value = "";
		return;
	}
	chkAmt = eval(totAmt - cashAmt);
	document.form_.chk_amt.value = this.formatFloat(eval(chkAmt), 2, true);
}
</script>
<body bgcolor="#D2AE72" onLoad="focusID();CashChkClicked('');">
<form name="form_" action="./payment_modification_cashcheck.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          PAYMENT MODIFICATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="payment_modification_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
        Go to main page&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"Message: ","","")%></strong></font>
      </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="18%" height="25">Reference Number </td>
      <td width="78%" height="25"><input name="or_number" type="text" size="16" value="<%=WI.fillTextValue("or_number")%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="25" colspan="9"><div align="center">PAYMENT DETAILS </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="18%">Amount Paid: <strong><%=(String)vRetResult.elementAt(11)%></strong></td>
      <td width="48%">Payment Type : <strong><%=strPaymentType%></strong></td>
      <td width="30%">Date Paid : <strong><%=(String)vRetResult.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>New Payment Type </td>
      <td colspan="2">
<%
if(iPmtType == 0 && dChkAmt == 0d)
	strTemp = "checked";
else
	strTemp = "";
%>
	  <input name="pmt_type" type="radio" value="0" <%=strTemp%> onClick="CashChkClicked('0');"> Cash
<%
if(iPmtType == 1)
	strTemp = "checked";
else
	strTemp = "";
%>
	  <input name="pmt_type" type="radio" value="1" <%=strTemp%> onClick="CashChkClicked('1');"> Check
<%
if(iPmtType == 0 && dChkAmt > 0d)
	strTemp = "checked";
else
	strTemp = "";
%>
	  <input name="pmt_type" type="radio" value="2" <%=strTemp%> onClick="CashChkClicked('2');"> Cash + Check	  
<%
if(iPmtType == 3)
	strTemp = "checked";
else
	strTemp = "";
%>
	  <input name="pmt_type" type="radio" value="3" <%=strTemp%> onClick="CashChkClicked('3');"> Bank Payment	  
	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Total Amount </td>
      <td colspan="2"><input name="total_amt" type="text" size="16" value="<%=dTotalAmt%>" class="textbox_noborder"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td id="cash_amt_label">New Cash Amount </td>
      <td colspan="2" id="cash_amt_"><input name="cash_amt" type="text" size="16" value="<%=dCashAmt%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','cash_amt');computeCashChkAmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','cash_amt');computeCashChkAmt();"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td id="chk_amt_label">New Check Amount </td>
      <td colspan="2" id="chk_amt_"><input name="chk_amt" type="text" size="16" value="<%=dChkAmt%>" class="textbox_noborder"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','chk_amt');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','chk_amt');"></td>
    </tr>
<%
strTemp = null;
if(vRetResult != null)
	strTemp = (String)vRetResult.elementAt(14);
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td id="chk_no_label">New Check Number </td>
      <td colspan="2" id="chk_no_">
	  <input name="chk_no" type="text" size="16" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td id="bank_">New Bank Information </td>
      <td colspan="2" id="bank_label">
	  <select name="CHECK_FR_BANK_INDEX" style="font-size:10px" tabindex="-1">
          <option value=""></option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH",
		" from FA_BANK_LIST where is_valid = 1 order by bank_code", (String)vRetResult.elementAt(46), false)%>
        </select>	 </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong> </strong></td>
      <td colspan="2">
	  <input type="image" src="../../../images/save.gif" onClick="document.form_.page_action.value='1';">
        <font size="1">Update Payment Information. </font>      </td>
    </tr>
  </table>
 <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="17%" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">
<%if(vRetResult != null && vRetResult.size() > 0){%>
<input type="hidden" name="info_index" value="<%=vRetResult.elementAt(30)%>">
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
