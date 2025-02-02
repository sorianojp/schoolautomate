<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAPayment,java.util.Vector" buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strStudStatus = WI.fillTextValue("stud_status");
	String strPayeeName = null;


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
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	td{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
	}
</style>
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ShowHideApprovalNo()
{
	if(document.form_.payment_mode.selectedIndex == 2)
		document.form_.approval_number.disabled = false;
	else
		document.form_.approval_number.disabled = true;
}
function ShowHideCheckNO()
{
	if(document.form_.payment_type.selectedIndex == 0) {
		document.form_.CHECK_FR_BANK_INDEX.selectedIndex = 0;
		document.form_.CHECK_FR_BANK_INDEX.disabled = true;
		document.form_.check_number.disabled = true;
	}
	else {
		document.form_.CHECK_FR_BANK_INDEX.disabled = false;
		document.form_.check_number.disabled = false;
	}
	if(document.form_.payment_type.selectedIndex == 2)
		showLayer('myADTable1');
	else
		hideLayer('myADTable1');
	document.form_.chk_amt.value = "";
	document.form_.cash_amt.value = "";
}
function ChangeFeeType()
{
	if(document.form_.fee_type.selectedIndex ==0){
		document.form_.payment_for.value="2"; //fine type.
	}else{
		document.form_.payment_for.value="1"; //tution fee type
	}
//	alert(document.form_.payment_for.value);
	document.form_.focus_.value = "2";
	ReloadPage();
}
function ReloadPage()
{
	document.form_.addRecord.value="";
//	document.form_.submit();
	this.SubmitOnce('form_');
}
function AddRecord()
{
	<%
	if(strSchCode.startsWith("CPU") || strSchCode.startsWith("CLDH")){%>
		this.SukliComputation();
	<%}//show Sukli computation%>
	document.form_.addRecord.value="1";
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,menubar=no');
	win.focus();
}
function AddFeeName()
{

	document.form_.add_fee.value = "1";
	document.form_.list_count.value = ++document.form_.list_count.value;


	if (document.form_.fund_type.value=="2"){
		var i =0;
		for (; i < document.form_.rdoGroup.length ; i++) {
			if (document.form_.rdoGroup[i].checked) {
				break;
			}
		}

		if (i !=  document.form_.rdoGroup.length ){
			eval("document.form_.loan_name.value = document.form_.tmp_fee_name" + i +".value");
//			eval("document.form_.fee_amt.value = document.form_.tmp_fee_amt" + i +".value");
// to be mapped
//			eval("document.form_.coa_index.value = document.form_.tmp_coa_index" + i +".value");
			eval("document.form_.payable_amt.value = document.form_.tmp_fee_amt_o" + i +".value");
			eval("document.form_.loan_index.value = document.form_.tmp_loan_index" + i +".value");
			eval("document.form_.loan_type.value = document.form_.tmp_loan_type" + i +".value");

//			alert (eval( "document.form_.tmp_fee_amt" + i +".value"));
//			alert (eval( "document.form_.tmp_fee_amt_o" + i +".value"));

			if (Number(document.form_.fee_amt.value) >
						Number(eval("document.form_.tmp_fee_amt_o" + i +".value"))){
				alert ("Amount to be paid is greater than payable amount");
				document.form_.list_count.value = --document.form_.list_count.value;
				return;
			}

		}else{
			document.form_.add_fee.value ="";
			document.form_.list_count.value = --document.form_.list_count.value;
			alert (" Please select loan/item to be paid");
			return;
		}
	}

//	document.form_.fee_name.value = document.form_.fee_type[document.form_.fee_type.selectedIndex].text;
//	document.form_.fee_index.value = document.form_.fee_type[document.form_.fee_type.selectedIndex].value;

	//get total Fee amount payable .... fee_amount * no_of_units.
//	var noOfUnit = document.form_.no_of_units.value;
//	if(noOfUnit.length == 0)
//		noOfUnit = "1";
//	document.form_.fee_amt.value = eval(document.form_.fee_amount.value) * eval(noOfUnit);

	ReloadPage();
}
function RemoveFeeName(removeIndex)
{
	document.form_.remove_index.value = removeIndex;
	ReloadPage();
}
function computeCashChkAmt() {
	var totAmt  = document.form_.amount.value;
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
///this is added for CLDH and CPU only.
function SukliComputation() {
	var vAmtPaid = document.form_.amount.value;

	var vAmtReceived  = prompt("Please enter Amount received.", vAmtPaid);
    if(vAmtReceived == null || vAmtReceived.length == 0)  {
		vAmtReceived = vAmtPaid;
	}
	document.form_.sukli.value = vAmtReceived;


}


function ShowRecords(){
	if (document.form_.payee_name){
		if(document.form_.payee_name.value.length == 0 &&
			document.form_.fund_type.value != "2"){
			alert (" Please set the Payee");
			document.form_.payee_name.focus();
			return;
		}

	}

	ReloadPage();

}

///for searching COA
var objCOA;
function MapCOAAjax(strIsBlur,strCoaFieldName, strParticularFieldName) {
		if(strCoaFieldName == 'coa_index')
			objCOA=document.getElementById("coa_info");
		else
			objCOA=document.getElementById("coa_info_c");

		var objCOAInput;
		eval('objCOAInput=document.form_.'+strCoaFieldName);
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name="+strCoaFieldName+"&coa_particular="+
			strParticularFieldName+"&is_blur="+strIsBlur;
		this.processRequest(strURL);
}

function COASelected(strAccountName, objParticular) {
	objCOA.innerHTML = "End of Processing..";
	if(objParticular != null) {
		objParticular.value = strAccountName;
	}
}

</script>



<body bgcolor="#D2AE72">
<%


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Other school fees","multiple_payment.jsp");
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
														"multiple_payment.jsp");
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

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
//System.out.println(request.getParameter("payment_for"));

Vector vEmpInfo = null;
Vector vRetirementLoans = null;
if (WI.fillTextValue("emp_id").length() > 0) {
	vEmpInfo =   new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");

	if (vEmpInfo != null && vEmpInfo.size() > 0){
		vRetirementLoans = new payroll.PRSalary().getRetirementLoans(dbOP,
												(String)vEmpInfo.elementAt(0),WI.getTodaysDate(1), 0, 0);
	}
}

	strPayeeName = 	WI.fillTextValue("payee_name");

if ((strPayeeName == null || strPayeeName.length() == 0)
		&& vEmpInfo != null && vEmpInfo.size() > 0){

	strPayeeName = WI.formatName((String)vEmpInfo.elementAt(1), (String)vEmpInfo.elementAt(2),
		(String)vEmpInfo.elementAt(3),4);
}

strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") ==0)
{
	if(faPayment.saveMultipleReceipt(dbOP,request))//always false for tution / fine payment
	{
		dbOP.cleanUP();
			String strSukli = WI.fillTextValue("sukli");
			if(strSukli.length() > 0) {
				//keep change in attribute.
				double dAmtReceived = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""));
				dAmtReceived = dAmtReceived - Double.parseDouble(WI.fillTextValue("amount"));
				strSukli = "&sukli="+ CommonUtil.formatFloat(dAmtReceived,true);
			}
		response.sendRedirect(response.encodeRedirectURL("./install_assessed_fees_print_receipt.jsp?or_number="+request.getParameter("or_number")+strSukli+
		"&fund_type="+request.getParameter("fund_type")));
		return;
	}
	else
		strErrMsg = faPayment.getErrMsg();
}

else
{
	if(strStudStatus.compareTo("1") == 0)
	{
		if(strPayeeName == null || strPayeeName.trim().length() ==0 ||
			request.getParameter("sy_from") == null || request.getParameter("sy_from").trim().length() ==0 ||
			request.getParameter("sy_to") == null 	|| request.getParameter("sy_to").trim().length() ==0 )
		strErrMsg = "Please enter name/school year of other fee information.";
	}
}
if(strErrMsg == null) strErrMsg = "";

//added here are for multiple fee display.
	int iListCount = 0;
	double dTotalAmount  = 0d;
	String strReceiptDesc = null;

%>
<form name="form_" action="./multiple_payment_cpu.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center">
		<% if (WI.fillTextValue("fund_type").equals("0"))
				strTemp = " GENERAL ACCOUNTS PAYMENT";
			else if ( WI.fillTextValue("fund_type").equals("1"))
				strTemp = " ENDOWMENT ACCEPTANCE ";
			else if ( WI.fillTextValue("fund_type").equals("2"))
				strTemp = " FACULTY / STAFF PAYMENT ";
		 %>

	  <font color="#FFFFFF"><strong>:::: <%=strTemp%> PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=strErrMsg%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	 <% if (!WI.fillTextValue("fund_type").equals("2")) {%>
    <tr >
      <td width="3%" height="25">&nbsp;</td>
      <td width="12%" height="25">Payee Name </td>
      <td width="85%" colspan="2">
	  <input name="payee_name" type="text" size="40" value="<%=strPayeeName%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">

	 <input type="hidden" name="stud_status" value="1">

		</font></td>
    </tr>
  <%}else{

  %>
    <tr >
      <td width="3%" height="25">&nbsp;</td>
      <td width="12%" height="25">Employee  ID </td>
      <td width="85%" colspan="2">
	  <input name="emp_id" type="text" class="textbox" id="emp_id"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16">
	<% strTemp = WI.fillTextValue("emp_index");
		if (strTemp.length() == 0 && vEmpInfo != null && vEmpInfo.size() >0)
			strTemp = (String)vEmpInfo.elementAt(0);
	%>
	 <input type="hidden" name="emp_index" value="<%=strTemp%>">

	 <input type="hidden" name="payee_name" value="<%=strPayeeName%>">
	 <input type="hidden" name="stud_status" value="1">

		</font></td>
    </tr>
 <%}%>
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
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' tabindex = "-1">
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes" tabindex="-1">
        TERM:
        <select name="semester" tabindex="-1">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")){
		  	if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }
		  if(strTemp.equals("0")){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>

    <tr >
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="2">

	  <a href="javascript:ShowRecords();"><img src="../../../images/form_proceed.gif" border="0"></a>	  </td>
    </tr>
  </table>

<%
if(strErrMsg.length() == 0 && strPayeeName != null && strPayeeName.length() > 0){
	// the outer most condition.

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="25" colspan="9" bgcolor="#B9B292"><div align="center">FEE
          DETAILS </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="2%" height="24">&nbsp;</td>
      <td width="46%" valign="top">Account No  :
        <input name="coa_index" type="text" size="26" maxlength="32" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onkeyUP="MapCOAAjax('0','coa_index','document.form_.fee_name');">	  </td>
      <td width="52%" rowspan="3" valign="top"><label id="coa_info" style="font-size:11px;"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Account Name :
      <input name="fee_name" type="text" size="26" maxlength="128"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Amount : <input name="fee_amt" type="text"
	  	class="textbox" id="fee_amt" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		size="6"></td>
    </tr>
<!--
    <tr >
      <td height="25">&nbsp;</td>
      <td><a href="javascript:AddFeeName();"><img src="../../../images/add.gif" border="0"></a><font size="1">Click
        to add to list of fees to pay</font></td>
      <td>&nbsp;
	  </td>
    </tr>
-->


<% if (WI.fillTextValue("fund_type").equals("2")) {
	Vector vRetResult = null;
	payroll.PRLoansAdv prd = new payroll.PRLoansAdv(request);
	vRetResult = prd.operateOnLoansAdv(dbOP,request,4);

	if (vRetResult != null && vRetResult.size() > 0){
	int iSelected = 0;
	boolean bolInfiniteLoop = true;

	for (int i = 3; i < vRetResult.size() ; ){
		bolInfiniteLoop = true;
%>
    <tr>
      <td width="2%" height="24">&nbsp;</td>
      <td width="46%" valign="middle">
	  <% while (i < vRetResult.size()) {

			if (Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+15),"0")) <= 0d){
		 		i +=  18;
				continue;
			}
			bolInfiniteLoop = false;

	  %>
	  <input type="radio" name="rdoGroup" value="<%=iSelected%>">
	  <%=(String)vRetResult.elementAt(i+5)%>
        <input name="tmp_loan_index<%=iSelected%>" type="hidden"
			value="<%=(String)vRetResult.elementAt(i)%>">

	  <input name="tmp_fee_name<%=iSelected%>" type="hidden"
	  		value="<%=(String)vRetResult.elementAt(i+5)%>">

	  <input name="tmp_fee_amt<%=iSelected%>" type="text" class="textbox_noborder" readonly
	  		value="(<%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vRetResult.elementAt(i+15),true),",","")%>)"  tabindex="-1"
			size="16">
	  <input name="tmp_loan_type<%=iSelected%>" type="hidden" class="textbox"  value="5"  >

	  <input name="tmp_fee_amt_o<%=iSelected%>" type="hidden"
	  		value="<%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vRetResult.elementAt(i+15),true),",","")%>">
	 <% i+=18;
		iSelected++;
	 	break;
	 }%>
&nbsp;	  </td>


      <td width="52%">&nbsp;
	 <% while ( i  < vRetResult.size()) {

			if (Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+15),"0")) <= 0d){
		 		i +=  18;
				continue;
			}

			bolInfiniteLoop = false;

	  %>
	  <input type="radio" name="rdoGroup" value="<%=iSelected%>">
        <input name="tmp_loan_index<%=iSelected%>" type="hidden"
			value="<%=(String)vRetResult.elementAt(i)%>">
	  <%=(String)vRetResult.elementAt(i+5)%>
	  <input name="tmp_fee_name<%=iSelected%>" type="hidden"
	  		value="<%=(String)vRetResult.elementAt(i+5)%>">

	  <input name="tmp_fee_amt<%=iSelected%>" type="text" class="textbox_noborder"
	  		value="(<%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vRetResult.elementAt(i+15),true),",","")%>)"    tabindex="-1"
			size="16">

	  <input name="tmp_loan_type<%=iSelected%>" type="hidden" class="textbox"  value="5"  >

	  <input name="tmp_fee_amt_o<%=iSelected%>" type="hidden"
	  		value="<%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vRetResult.elementAt(i+15),true),",","")%>">
	 <% i += 18;
		iSelected++;
	 	break;
	 }%></td>
    </tr>
<% } // end for loop

	// other type of loans
    if (vRetirementLoans != null && vRetirementLoans.size()>0){
		if (((String)vRetirementLoans.elementAt(6)).equals("0")){
			strTemp = " Retirement Loan";
		} else{
			strTemp = " Emergency Loan";
		}

%>
    <tr>
      <td width="2%" height="24">&nbsp;</td>
      <td width="46%" valign="middle">

	  <input type="radio" name="rdoGroup" value="<%=iSelected%>">
	  <%=strTemp%>
      <input name="tmp_loan_index<%=iSelected%>" type="hidden"
	  		value="<%=(String)vRetirementLoans.elementAt(1)%>">
	  <input name="tmp_fee_name<%=iSelected%>" type="hidden"  value="<%=strTemp%>">
	  <input name="tmp_fee_amt<%=iSelected%>" type="text" class="textbox_noborder" readonly
	  		value="(<%=ConversionTable.replaceString((String)vRetirementLoans.elementAt(2),",","")%>)"  size="16" tabindex="-1">
	  <input name="tmp_loan_type<%=iSelected%>" type="hidden" class="textbox"
	  		value="<%=(String)vRetirementLoans.elementAt(6)%>"  >
	  <input name="tmp_fee_amt_o<%=iSelected%>" type="hidden"
	  		value="<%=ConversionTable.replaceString((String)vRetirementLoans.elementAt(2),",","")%>">
	 <% iSelected++;
	 	vRetirementLoans.removeElementAt(0);vRetirementLoans.removeElementAt(0);vRetirementLoans.removeElementAt(0);
		vRetirementLoans.removeElementAt(0);vRetirementLoans.removeElementAt(0);vRetirementLoans.removeElementAt(0);
		vRetirementLoans.removeElementAt(0);
	 %>
&nbsp;	  </td>

      <td width="52%">
	 <% if (vRetirementLoans != null && vRetirementLoans.size()>0) { %>
	  <input type="radio" name="rdoGroup" value="<%=iSelected%>">
	  <%=strTemp%>
      <input name="tmp_loan_index<%=iSelected%>" type="hidden"
	  		value="<%=(String)vRetirementLoans.elementAt(1)%>">
	  <input name="tmp_fee_name<%=iSelected%>" type="hidden"  value="<%=strTemp%>">
	  <input name="tmp_fee_amt<%=iSelected%>" type="text" class="textbox_noborder" readonly
	  		value="(<%=ConversionTable.replaceString((String)vRetirementLoans.elementAt(2),",","")%>)"    tabindex="-1" size="16">
	  <input name="tmp_loan_type<%=iSelected%>" type="hidden" class="textbox"
	  		value="<%=(String)vRetirementLoans.elementAt(6)%>"  >
	  <input name="tmp_fee_amt_o<%=iSelected%>" type="hidden"
	  		value="<%=ConversionTable.replaceString((String)vRetirementLoans.elementAt(2),",","")%>">
	<% iSelected++;
	 	vRetirementLoans.removeElementAt(0);vRetirementLoans.removeElementAt(0);vRetirementLoans.removeElementAt(0);
		vRetirementLoans.removeElementAt(0);vRetirementLoans.removeElementAt(0);vRetirementLoans.removeElementAt(0);
		vRetirementLoans.removeElementAt(0);
	 }
	 %></td>
    </tr>
<% }
  } // end  if vRetResult != null
 } // end if else
%>
    <tr >
      <td height="25">&nbsp;</td>
      <td><a href="javascript:AddFeeName();"><img src="../../../images/add.gif" border="0"></a><font size="1">Click
        to add to list of fees to pay</font></td>
      <td>&nbsp;
<!--	<input type="hidden" name="fee_name"> -->
<!--	<input type="hidden" name="fee_amt"> -->
<!--	<input type="hidden" name="coa_index"> -->
<% if (WI.fillTextValue("fund_type").equals("2")){%>
	<input type="hidden" name="payable_amt">
	<input type="hidden" name="loan_index">
	<input type="hidden" name="loan_name">
	<input type="hidden" name="loan_type">
<%}%>
	</td>
    </tr>

  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>LIST
          OF FEES TO PAY </strong></div></td>
    </tr>
    <tr bgcolor="#33CCFF">
      <td width="68%" height="25" class="thinborder"><div align="center"><strong><font size="1">FEE
          TYPE/NAME</font></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><font size="1">AMOUNT</font></strong></div></td>
      <td width="9%" class="thinborder"><strong><font size="1">REMOVE</font></strong></td>
    </tr>
    <%
strErrMsg = null;
String strFee = null;//this is fee already calculated.
int iRemoveIndex    = Integer.parseInt(WI.getStrValue(WI.fillTextValue("remove_index"),"-1"));

int iCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("list_count"),"0"));

String strFeeIndex     = null;
String strFeeNoOfUnits = null;
String strCOACode      = null;
String strPayableAmt   = null;
String strLoanName	   = null;
String strLoanIndex    = null;
String strLoanType	   = null;

for(int i=0; i<iCount; ++i)
{
	if(i == iRemoveIndex)
		continue;
	if( i == iCount -1 && WI.fillTextValue("add_fee").length() > 0) {
		strTemp          = WI.fillTextValue("fee_name");
		strFee           = WI.fillTextValue("fee_amt");
		strFeeIndex      = WI.fillTextValue("fee_index");
		strFeeNoOfUnits  = WI.getStrValue(WI.fillTextValue("no_of_units"),"1");
		strCOACode 		 = WI.fillTextValue("coa_index");
		strPayableAmt	 = WI.fillTextValue("payable_amt");
		strLoanName 	 = WI.fillTextValue("loan_name");
		strLoanIndex 	 = WI.fillTextValue("loan_index");
	    strLoanType		 = WI.fillTextValue("loan_type");

	}
	else {
		strTemp          = WI.fillTextValue("fee_name"+i);
		strFee           = WI.fillTextValue("fee_amt"+i);
		strFeeIndex      = WI.fillTextValue("fee_i"+i);
		strFeeNoOfUnits  = WI.fillTextValue("fee_no_of_units"+i);
		strCOACode		 = WI.fillTextValue("coa_index"+i);
		strPayableAmt	 = WI.fillTextValue("payable_amt"+i);
		strLoanName		 = WI.fillTextValue("loan_name"+i);
		strLoanIndex	 = WI.fillTextValue("loan_index"+i);
		strLoanType		 = WI.fillTextValue("loan_type"+i);

	}
	if(strReceiptDesc == null)
		strReceiptDesc = strTemp+": "+CommonUtil.formatFloat(strFee,true);
	else
		strReceiptDesc = strReceiptDesc+"<br>\r\n"+strTemp+": "+CommonUtil.formatFloat(strFee,true);

	dTotalAmount += Double.parseDouble(WI.getStrValue(strFee,"0"));
	%>
    <input type="hidden" name="fee_name<%=iListCount%>" value="<%=strTemp%>">
	<input type="hidden" name="loan_name<%=iListCount%>" value="<%=strLoanName%>">
    <input type="hidden" name="fee_amt<%=iListCount%>" value="<%=WI.getStrValue(strFee,"0")%>">
	<input type="hidden" name="coa_index<%=iListCount%>" value="<%=strCOACode%>">
	<input type="hiddeN" name="loan_type<%=iListCount%>" value="<%=strLoanType%>">
	<input type="hidden" name="loan_index<%=iListCount%>" value="<%=strLoanIndex%>">
    <input type="hidden" name="fee_i<%=iListCount%>" value="<%=WI.getStrValue(strFeeIndex,"0")%>">
    <input type="hidden" name="fee_no_of_units<%=iListCount%>" value="<%=WI.getStrValue(strFeeNoOfUnits,"0")%>">
    <input type="hidden" name="payable_amt<%=iListCount%>" value="<%=WI.getStrValue(strPayableAmt,"0")%>">
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=strTemp%>
	  			<%=WI.getStrValue(strLoanName,"&nbsp;(", ")","")%></td>
      <td class="thinborder"><div align="right"><strong></strong><%=CommonUtil.formatFloat(strFee,true)%>&nbsp;&nbsp;</div></td>
      <td class="thinborder"><a href='javascript:RemoveFeeName("<%=iListCount%>");' tabindex="-1"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%
	//add here to list, it is safe now.
	++iListCount;
}%>
    <tr>
      <td height="25" class="thinborder"><div align="right">TOTAL &nbsp;&nbsp;: &nbsp;&nbsp;</div></td>
      <td class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%>&nbsp;&nbsp;</strong></div></td>
      <td class="thinborderBOTTOM">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5" bgcolor="#FFFFCF"><div align="center"><strong>PAYMENT
          DETAILS <input type="hidden" name="pmt_desc" value="<%=WI.getStrValue(strReceiptDesc)%>">	  </strong></div></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Amount paid </td>
      <td width="21%"> <%
strTemp = WI.fillTextValue("amount");
if(dTotalAmount > 0d)
	strTemp = Double.toString(dTotalAmount);
%> <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-weight:bold; font-size:15px;">      </td>
      <td width="11%">Check #</td>
      <td width="46%"> <%
strTemp = "";
if(request.getParameter("payment_type") == null || 	 request.getParameter("payment_type").trim().length() ==0 ||
	request.getParameter("payment_type").compareTo("0") == 0)
{
	strTemp = "disabled";
}%> <input name="check_number" type="text" size="16" value="<%=WI.fillTextValue("check_number")%>" <%=strTemp%> class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Approval no.</td>
      <td valign="top"><input name="approval_no" type="text" class="textbox" tabindex="-1" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("approval_no")%>" size="16">      </td>
      <td>&nbsp;</td>
      <td><select name="CHECK_FR_BANK_INDEX" style="font-size:10px" >
          <option value=""></option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH"," from FA_BANK_LIST where is_valid = 1 order by bank_code", request.getParameter("CHECK_FR_BANK_INDEX"), false)%>
        </select>
        <div id="myADTable1">Amt Chk
        <input name="chk_amt" type="text" size="8" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount');computeCashChkAmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','chk_amt');computeCashChkAmt();">
        Cash
        <input name="cash_amt" type="text" size="8" class="textbox_noborder" readonly="yes">
       </div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payment type</td>
      <td> <select name="payment_type" onChange="ShowHideCheckNO();">
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
          <%}%>
        </select> </td>
      <td>Date paid</td>
      <td><font size="1">&nbsp;
        <%
strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%>
        <input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payment receive type</td>
      <td> <select name="pmt_receive_type" onChange="ReloadPage();">
          <option value="Internal">Internal</option>
          <%
strTemp = WI.fillTextValue("pmt_receive_type");
if(strTemp.compareTo("External") ==0){%>
          <option value="External" selected>External</option>
          <%}else{%>
          <option value="External">External</option>
          <%}%>
        </select> </td>
      <td>Ref #</td>
      <td><font size="1"><b>
        <!--       <%
	   	//strTemp = paymentUtil.generateORNumber(dbOP);
	   //	if(strTemp == null)
	   //		strTemp = paymentUtil.getErrMsg();
		//else{%>
        <input type="hidden" name="or_number" value="<%//=strTemp%>">
        <%//}%>
        <%//=strTemp%> -->
        <input name="or_number" type="text" size="18" value="<%=paymentUtil.generateORNumber(dbOP,(String)request.getSession(false).getAttribute("userId"))%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </b></font></td>
    </tr>
    <% if(strTemp.compareTo("External") ==0) //External
{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Bank name</td>
      <td colspan="3"> <select name="bank">
          <%=dbOP.loadCombo("AB_INDEX","AFF_BANK_NAME"," from FA_AFFILIATED_BANK where is_del=0 order by AFF_BANK_NAME asc",
   		request.getParameter("bank"), false)%> </select> </td>
    </tr>
    <%}//only if receive type is external
%>
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
	 <% if (dTotalAmount > 0d){%>
	  <input type="image" src="../../../images/save.gif" onClick="AddRecord();">
	  	<font size="1">click to save payment detail</font>
	 <%}%> &nbsp;
	  </td>
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

 <input type="hidden" name="addRecord" value="0">
<input type="hidden" name="payment_for" value="8">

<input type="hidden" name="list_count" value="<%=iListCount%>">
<input type="hidden" name="remove_index">
<input type="hidden" name="add_fee">

<!--
<input type="hidden" name="fee_name">
<input type="hidden" name="fee_amt">
-->
<input type="hidden" name="fee_index">
<input type="hidden" name="sukli">
<input type="hidden" name="focus_" value="<%=WI.fillTextValue("focus_")%>">
<input type="hidden" name="fund_type" value="<%=WI.fillTextValue("fund_type")%>">
<input type="hidden" name="multiple_payment_cpu" value="1">
<input type="hidden" name="first_load" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
