<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan,
																	payroll.PRExternalPayment, payroll.ReportPayrollExtn"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee balances</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.BorderBottomLeft{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottomLeftRight{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderAll{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TABLE.thinborder{
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
}

TD.thinborder{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strPageAction, strInfoIndex,strCode){	
	document.form_.print_page.value = "";
	document.form_.proceed.value = "1";
	if (strPageAction == 0){
		var vProceed = confirm('Delete payment with OR number '+strCode+'?');
		if(vProceed){
			document.form_.page_action.value = strPageAction;
			document.form_.info_index.value = strInfoIndex;
		//	document.form_.prepareToEdit.value = "";
			this.SubmitOnce('form_');
		}		
	}else{
		document.form_.page_action.value = strPageAction;
		document.form_.info_index.value = strInfoIndex;
		//document.form_.prepareToEdit.value = "";
		if (strPageAction == 1)
			document.form_.save.disabled = true;
		document.form_.submit();
		//this.SubmitOnce("form_");
	}	
}

function copyOneRow(strFr, strTo, strIsLoan, strRow){
	eval('document.form_.'+strTo+'.value = document.form_.'+strFr+'.value');
	if(strIsLoan == '1')
		ComputeLoanPayable(strRow);
	else
		ComputeMiscPayable(strRow);
}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.print_page.value="";
	document.form_.proceed.value = "1";
	document.form_.payee_id.value = document.form_.emp_id.value;
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function CopyID(strID)
{
	document.form_.print_page.value="";
	document.form_.emp_id.value=strID;
	document.form_.proceed.value = "1";
	this.SubmitOnce("form_");
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
		}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.print_page.value="";
 	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.proceed.value = "1";	
	document.form_.submit();
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function viewPaymentDetail(strPayIndex) {
	var pgLoc = "./payment_details.jsp?payment_index="+strPayIndex;
 	var win=window.open(pgLoc,"payDetail",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewDetails(strCodeIndex) {
	var pgLoc = "../../loans_advances/reconciliation/emp_loans_recon.jsp?hide_navigator=1"+
							"&emp_id="+document.form_.emp_id.value+"&code_index="+strCodeIndex;
 	var win=window.open(pgLoc,"viewDetails",'width=700,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ComputeLoanPayable(strRow){
 	var vLoanPay =  null;
	var vTotalPay = 0;
	var vLoanCount = document.form_.loan_count.value;
	

	for(var i = 1; i < eval(vLoanCount);i++){
		vLoanPay = eval('document.form_.loan_payment_'+i+'.value');
		if (vLoanPay.length == 0)
			vLoanPay = "0";

		vTotalPay = eval(vTotalPay) + eval(vLoanPay);
	}
	document.form_.total_loan.value = eval(vTotalPay);	
 	//document.form_.total_loan.value = truncateFloat(document.form_.total_loan.value,2,false);
	document.form_.total_loan.value = roundOffFloat(document.form_.total_loan.value,2,true);
 	ComputeLoansMisc();
}

function ComputeMiscPayable(strRow){
	var vAmount = eval('document.form_.misc_to_pay_'+strRow+'.value');
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vMiscCount = document.form_.post_ded_count.value;
	if (vAmount.length == 0){
		return;
	}

	for(var i = 1; i < eval(vMiscCount);i++){
		vPeriodPay = eval('document.form_.misc_to_pay_'+i+'.value');
		if (vPeriodPay.length == 0)
			vPeriodPay = "0";		
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);
 	}
	document.form_.total_misc.value = eval(vTotalPay);
	document.form_.total_misc.value = truncateFloat(document.form_.total_misc.value,2,false);
	ComputeLoansMisc();
}

function ComputeLoansMisc(){
	var vMiscTotal = 0;
	var vLoanTotal = 0;
	
	if(document.form_.total_loan)
		vLoanTotal = eval(document.form_.total_loan.value);
	
	if(document.form_.total_misc)
		vMiscTotal = eval(document.form_.total_misc.value);
	
  if(document.form_.total_loan_misc){
	  document.form_.total_loan_misc.value = vLoanTotal + vMiscTotal;
	  document.form_.total_loan_misc.value = truncateFloat(document.form_.total_loan_misc.value,2,false);
  }
}

function updateAllLoan(strOption){
 	var vLoanPay =  null;
	var vTotalPay = 0;
	var vLoanCount = document.form_.loan_count.value;
	
	for(var i = 1; i < eval(vLoanCount);i++){
		if(strOption == '1') // copy otherwise clear
			eval('document.form_.loan_payment_'+i+'.value = document.form_.l_bal_'+i+'.value');
		else
			eval('document.form_.loan_payment_'+i+'.value = ""');

		vLoanPay = eval('document.form_.loan_payment_'+i+'.value');
		if (vLoanPay.length == 0)
			vLoanPay = "0";

		vTotalPay = eval(vTotalPay) + eval(vLoanPay);
	}
	document.form_.total_loan.value = eval(vTotalPay);
 	document.form_.total_loan.value = truncateFloat(document.form_.total_loan.value,2,false);
 	ComputeLoansMisc();
}


function updateAllMiscDed(strOption){
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vMiscCount = document.form_.post_ded_count.value;
	
	for(var i = 1; i < eval(vMiscCount);i++){
		if(strOption == '1') // copy otherwise clear
			eval('document.form_.misc_to_pay_'+i+'.value = document.form_.orig_misc_amt_'+i+'.value');
		else
			eval('document.form_.misc_to_pay_'+i+'.value = ""');

		vPeriodPay = eval('document.form_.misc_to_pay_'+i+'.value');
		if (vPeriodPay.length == 0)
			vPeriodPay = "0";		

		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);
	}

	document.form_.total_misc.value = eval(vTotalPay);
	document.form_.total_misc.value = truncateFloat(document.form_.total_misc.value,2,false);
 	ComputeLoansMisc();
} 

function ajaxSearchPayeeID(strFieldName, strLabel) {
	var strCompleteName = eval('document.form_.'+strFieldName+'.value');
	var objCOAInput = document.getElementById(strLabel);
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=310&name_format=4&complete_name="+
		escape(strCompleteName)+"&field_name="+strFieldName+"&label_name="+strLabel;

	this.processRequest(strURL);
}

function setID(strID, strUserIndex, strFieldName, strLabelName) {
	document.form_.print_page.value="";
 	//eval('document.form_.'+strFieldName+'.value = '+ strID);
	document.form_.payee_id.value = strID;
	document.getElementById(strLabelName).innerHTML = "";
}

function togglePayeeOpt() {
	if(!document.form_.payee_opt)
		return;
		
	if(document.form_.payee_opt[0].checked){
		document.form_.payee_id.disabled = false;
		document.form_.payee_name.disabled = true;
	}else{
		document.form_.payee_id.disabled = true;
		document.form_.payee_name.disabled = false;
	}
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strEmpID = null;
	String strDisabled = "";
//add security here.
		
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./emp_with_balances_print.jsp" />
<% return;}

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
		
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
			if(iAccessLevel == 0) {
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
			}						
		}
	}

	strEmpID = WI.fillTextValue("emp_id");
	if(strEmpID.length() == 0)
		strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
	strEmpID = WI.getStrValue(strEmpID, "");

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}	else if(iAccessLevel == 0) //NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-Employee Payable Balances","external_payment.jsp");
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

	//end of authenticaion code.	
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	ReportPayrollExtn rptMisc = new ReportPayrollExtn(request);
	PRExternalPayment prExt = new PRExternalPayment(request);
	Vector vLoans = null;
	Vector vPersonalDetails = null;
	Vector vPostCharges = null;
	Vector vRetResult = null;
	int iCount = 1;
	String[] astrLoanType = {"Retirement","Emergency","Institutional/Company", "SSS ", "PAG-IBIG", "PERAA","GSIS"};
	
	int iLoansResult = 0;
	int iChargeResult = 0;
	int i = 0;
	int iDefault = 0;
	double dTotalLoan = 0d;
	double dTotalPaid = 0d;
	double dPayable = 0d;	
	String strPageAction = WI.fillTextValue("page_action");
	String strInfoIndex = WI.fillTextValue("info_index");
	String strPayeeOpt  = WI.getStrValue(WI.fillTextValue("payee_opt"), "0");
	//System.out.println("wasitacatisaw");
	if (strPageAction.length() > 0){
			if (prExt.operateOnPRExternalPayment(dbOP, request, Integer.parseInt(strPageAction)) != null)
				strErrMsg = "Operation Successful";
			else 
				strErrMsg = prExt.getErrMsg();
	}
	
	if (WI.fillTextValue("proceed").length() > 0) {
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

		if (vPersonalDetails == null || vPersonalDetails.size()==0){
			strErrMsg = authentication.getErrMsg();
			vPersonalDetails = null;
		}
		
		vLoans = PRRetLoan.getEmpLoanWithBalance(dbOP,request);		
		//System.out.println("vLoans " + vLoans);
		if(vLoans != null)
			iLoansResult = PRRetLoan.getSearchCount();
		
		vPostCharges = rptMisc.getUnpaidPostCharges(dbOP);
		//System.out.println("vPostCharges " + vPostCharges);
		if(vPostCharges != null && vPostCharges.size() > 1)
			iChargeResult = rptMisc.getSearchCount();		
		
		vRetResult = prExt.operateOnPRExternalPayment(dbOP, request, 4);
		//System.out.println("vRetResult " + vRetResult);
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="external_payment.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: REPORTS - EMPLOYEE EXTERNAL PAYMENT PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="14%" height="27">Employee ID</td>
      <td width="83%">
			<input name="emp_id" type="text" size="16" onKeyUp="AjaxMapName();"
			value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	 		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></td>
    </tr>
		<!--
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="12%" height="27"> Date :</td>
	  <%
	  	strTemp = WI.fillTextValue("end_date");
		if(strTemp.length() == 0){
			strTemp = WI.getTodaysDate(1);
		}
	  %>	  
	  <td width="85%"><strong>
	    <input name="end_date" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp,"")%>" size="12" maxlength="12" readonly="yes">
        <a href="javascript:show_calendar('form_.end_date');"><img src="../../../../images/calendar_new.gif" border="0"></a></strong></td>
    </tr>
    -->
    <tr>
      <td>&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18" valign="top">
			<div style="position:absolute;width:500px;">
			<label id="coa_info"></label>
			</div>
			</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">&nbsp;</td>
      <td height="27">
			<!--
			<a href="javascript:ReloadPage()"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">			</td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
	<%if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>  
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">&nbsp;Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>&nbsp;Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <%
				strTemp = (String)vPersonalDetails.elementAt(13);
				if (strTemp == null)
					strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
				else
					strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
			%>
      <td height="30">&nbsp;
        <%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>&nbsp;Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="97%">&nbsp;Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%> </strong></td>
    </tr>
    <tr>
      <td height="13" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
	<%}%>
	<%if((vLoans != null && vLoans.size() > 0)
		|| (vPostCharges != null && vPostCharges.size() > 1)){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="97%" height="18">OUTSTANDING BALANCES AS OF <%=WI.getTodaysDate(1)%></td>
    </tr>
    <!--
		<tr> 
      <td height="10" colspan="2" align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print list</font></td>
    </tr>
		-->
  </table>  
	<%}%>
	<%if(vPostCharges != null && vPostCharges.size() > 1){%>  
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr>
      <td height="10" colspan="4" class="BorderBottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="13%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">COUNT</font></strong></td>
      <td width="58%" align="center" class="BorderBottomLeft"><strong><font size="1">POST CHARGE NAME</font></strong></td>
      <td width="12%" align="center" class="BorderBottomLeft"><strong><font size="1">BALANCE</font></strong></td>

      <td width="12%" align="center" class="BorderBottomLeft"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="51%" align="center"><a href="javascript:updateAllMiscDed('1');">Copy</a></td>
          <td width="49%" align="center"><a href="javascript:updateAllMiscDed('');">Clear</a></td>
        </tr>
      </table>        </td>
      </tr>
    <%
	iCount = 1;
	dPayable = 0d;
	for(i = 1; i < vPostCharges.size(); i+=3,iCount++){
	%>
		<input type="hidden" name="post_ded_index_<%=iCount%>" value="<%=vPostCharges.elementAt(i)%>">
    <tr> 
      <td height="24" align="right" class="BorderBottomLeft"><%=iCount%>&nbsp;</td>
			<%
				strTemp = WI.getStrValue((String)vPostCharges.elementAt(i+1),"&nbsp;");
			%>
			<input type="hidden" name="post_name_<%=iCount%>" value="<%=strTemp%>">
      <td class="BorderBottomLeft"><%=strTemp%></td>
      <%	
				strTemp = CommonUtil.formatFloat((String)vPostCharges.elementAt(i+2),true);
				strTemp = ConversionTable.replaceString(strTemp,",","");		
				dPayable += Double.parseDouble(strTemp);
			%>      
		<input type="hidden" name="orig_misc_amt_<%=iCount%>" value="<%=strTemp%>">
	  <td align="right" class="BorderBottomLeft"><a href="javascript:copyOneRow('orig_misc_amt_<%=iCount%>', 'misc_to_pay_<%=iCount%>', '0', '<%=iCount%>')"><%=strTemp%></a>&nbsp;</td>
    <td align="center" class="BorderBottomLeft"><strong>
      <input name="misc_to_pay_<%=iCount%>" type="text" class="textbox" value="<%=WI.fillTextValue("misc_to_pay_"+iCount)%>"
			onFocus="style.backgroundColor='#D3EBFF'" size="10" maxlength="10" style="text-align:right" 
			onKeyUp="AllowOnlyFloat('form_','misc_to_pay_<%=iCount%>');ComputeMiscPayable('<%=iCount%>');"
		  onBlur="AllowOnlyFloat('form_','misc_to_pay_<%=iCount%>');ComputeMiscPayable('<%=iCount%>');
							style.backgroundColor='white'">
    </strong></td>
    </tr>
    <%}%>
    <tr> 
      <td height="24" colspan="2" align="right" class="BorderBottomLeft">TOTAL :&nbsp;&nbsp;&nbsp;</td>
      <td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("total_misc");
			%>
      <td align="center" class="BorderBottomLeft"><strong>
        <input name="total_misc" type="text" class="textbox_noborder" value="<%=WI.getStrValue(strTemp,"0")%>"
	    size="10" maxlength="10" style="text-align:right" readonly>
      </strong></td>
      </tr>
  </table>
	<%}%>		
	<input type="hidden" name="post_ded_count" value="<%=iCount%>">	
	<%if(vLoans != null && vLoans.size() > 0){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr>
      <td height="10" colspan="7" class="BorderBottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="7%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">COUNT</font></strong></td>
      <td width="32%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN NAME</font></strong></td>
      <td width="12%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL 
      LOAN </font></strong></td>
      <td width="12%" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL PAYMENT</font></strong></td>
      <td width="12%" align="center" class="BorderBottomLeft"><strong><font size="1"> BALANCE</font></strong></td>
      <td width="8%" align="center" class="BorderBottomLeft"><strong>DETAILS</strong></td>
      <td width="12%" align="center" class="BorderBottomLeft">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="51%" align="center"><a href="javascript:updateAllLoan('1');">Copy</a></td>
          <td width="49%" align="center"><a href="javascript:updateAllLoan('');">Clear</a></td>
        </tr>
      </table>
			</td>
    </tr>
    <%
	iCount = 1;
	dPayable = 0d;
	for(i = 0; i < vLoans.size(); i+=13,iCount++){
	%>
		<input type="hidden" name="ret_loan_index_<%=iCount%>" value="<%=vLoans.elementAt(i)%>">
    <tr> 
      <td height="24" align="right" class="BorderBottomLeft"><%=iCount%>&nbsp;</td>
      <td class="BorderBottomLeft">&nbsp;<%=astrLoanType[Integer.parseInt((String)vLoans.elementAt(i+2))]%> (<%=WI.getStrValue((String)vLoans.elementAt(i+1),"&nbsp;")%>)</td>
      <%	
		strTemp = CommonUtil.formatFloat((String)vLoans.elementAt(i+3),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalLoan += Double.parseDouble(strTemp);
	%>							
      <td height="24" align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vLoans.elementAt(i+5),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalPaid += Double.parseDouble(strTemp);
	%>      
	  <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vLoans.elementAt(i+4),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dPayable += Double.parseDouble(strTemp);
	%>      
	  <td align="right" class="BorderBottomLeft"><a href="javascript:copyOneRow('l_bal_<%=iCount%>', 'loan_payment_<%=iCount%>', '1', '<%=iCount%>')"><%=strTemp%></a>&nbsp;
			<input type="hidden" name="l_bal_<%=iCount%>" value="<%=strTemp%>"></td>
      <!--
	  <td class="BorderBottomLeftRight"><div align="center"><a href="javascript:ViewDetails('<%=(String)vLoans.elementAt(i+6)%>')"><img src="../../../../images/view.gif" border="0" ></a></div></td>
	  -->
	    <td align="center" class="BorderBottomLeft">
	        <a href="javascript:ViewDetails('<%=(String)vLoans.elementAt(i+6)%>');">
          <img src="../../../../images/view.gif" border="0" ></a></td>

      <td align="center" class="BorderBottomLeft"><strong>
      <input name="loan_payment_<%=iCount%>" type="text" class="textbox" value="<%=WI.fillTextValue("loan_payment_"+iCount)%>"
			onFocus="style.backgroundColor='#D3EBFF'" size="10" maxlength="10" style="text-align:right"
			onKeyUp="AllowOnlyFloat('form_','loan_payment_<%=iCount%>');ComputeLoanPayable('<%=iCount%>');"
		  onBlur="AllowOnlyFloat('form_','loan_payment_<%=iCount%>');ComputeLoanPayable('<%=iCount%>');
			style.backgroundColor='white'">
      </strong></td>
    </tr>
    <%}%>
    <tr>
      <td height="24" colspan="2" align="right" class="BorderBottomLeft">TOTAL :&nbsp;&nbsp;&nbsp;</td>
      <td height="24" align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalLoan,true)%>&nbsp;</td>
      <td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalPaid,true)%>&nbsp;</td>
      <td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
      <td class="BorderBottomLeft">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("total_loan");
			%>
      <td align="center" class="BorderBottomLeft"><strong>
      <input name="total_loan" type="text" class="textbox_noborder" value="<%=WI.getStrValue(strTemp,"0")%>"
	    size="10" maxlength="10" style="text-align:right" readonly>
      </strong></td>
    </tr>
  </table>	
	<%}%>	
	<input type="hidden" name="loan_count" value="<%=iCount%>">
<%if((vPostCharges != null && vPostCharges.size() > 1) || 
		 (vLoans != null && vLoans.size() > 0) ){%>  	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

<tr>
      <td height="25">&nbsp;</td>
      <td>Payee ID </td>
			<%
 				if(strPayeeOpt.equals("0")){
					strTemp = "checked";
					strDisabled = "";
				}else{
					strTemp = "";
					strDisabled = "disabled";
				}
			%>
      <td>
			<input type="radio" name="payee_opt" value="0" <%=strTemp%> onClick="togglePayeeOpt();">
			<input name="payee_id" type="text" size="16" onKeyUp="ajaxSearchPayeeID('payee_id','payee_');"
			value="<%=WI.fillTextValue("payee_id")%>" class="textbox" <%=strDisabled%>
	 		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<div style="position:absolute;width:400px;">
			<label id="payee_"></label>
			</div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payee name </td>
			<%
 				if(!strPayeeOpt.equals("0")){
					strTemp = "checked";
					strDisabled = "";
				}else{
					strTemp = "";
					strDisabled = "disabled";
				}
			%>
      <td><input type="radio" name="payee_opt" value="1" <%=strTemp%> onClick="togglePayeeOpt();">
      <input name="payee_name" type="text" size="32"
			value="<%=WI.fillTextValue("payee_name")%>" class="textbox" <%=strDisabled%>
	 		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%">OR Number</td>
			<%
				strTemp = WI.fillTextValue("or_number");
			%>
      <td width="82%"><strong>
        <input name="or_number" type="text" value="<%=WI.getStrValue(strTemp)%>"
	    size="10" maxlength="10" style="text-align:right">
      </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date Paid </td>
			<%
				strTemp = WI.fillTextValue("date_paid");
				if(strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);
			%>
      <td height="25"><input name="date_paid" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_paid');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
			<%
				strTemp = WI.fillTextValue("total_loan_misc");
			%>
      <td height="25">&nbsp;</td>
      <td>Total Payment</td>
      <td height="25"><strong>
        <input name="total_loan_misc" type="text" class="textbox_noborder" value="<%=WI.getStrValue(strTemp,"0")%>"
	    size="10" maxlength="10" style="text-align:right" readonly>
      </strong></td>
    </tr>
    
    <tr>
      <td height="25" colspan="3"><input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(1, '','');"></td>
    </tr>
  </table>	
	<%}%>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td align="center" height="10"><hr size="1"></td>
  </tr>
  <tr>
    <td align="center"><table width="80%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="26" colspan="6" align="center" bgcolor="#B9B292" class="BorderBottomLeft"><strong>LIST
      OF EXTERNAL PAYMENTS </strong></td>
    </tr>
    <tr>
      <td width="25%" height="28" align="center" class="BorderBottomLeft"><strong><font size="1">OR NUMBER </font></strong></td>
      <td width="21%" align="center" class="BorderBottomLeft"><font size="1"><strong>AMOUNT PAID </strong></font></td>
      <td align="center" class="BorderBottomLeft"><font size="1"><strong>DATE PAID </strong></font></td>
      <td align="center" class="BorderBottomLeft"><strong><font size="1">DETAIL</font></strong></td>
      <!--
			<td align="center" class="BorderBottomLeft"><font size="1"><strong>POSTED BY</strong></font></td>
			-->
 
      <td align="center" class="BorderBottomLeft"><font size="1"><strong>OPTIONS</strong></font></td>
    </tr>
	<% for (i = 0; i < vRetResult.size(); i+=10){%>
    <tr>
			<%
			strTemp = (String)vRetResult.elementAt(i+1);
			%>
      <td class="BorderBottomLeft"><font size="1">&nbsp;<%=strTemp%></font></td>
			<%
			strTemp = (String)vRetResult.elementAt(i+2);
			%>
	    <td align="right" class="BorderBottomLeft"><font size="1"><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</font></td>
			<%
			strTemp = (String)vRetResult.elementAt(i+3);
			%>			
      <td width="31%" class="BorderBottomLeft"><font size="1">&nbsp;<%=strTemp%></font></td>
      <td width="12%" align="center" class="BorderBottomLeft"><a href="javascript:viewPaymentDetail('<%=(String)vRetResult.elementAt(i)%>')">view</a></td>
      <td width="12%" align="center" class="BorderBottomLeft">
	  <%if (iAccessLevel==2) {%>
	  <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>', '<%=(String)vRetResult.elementAt(i+1)%>')"><img src="../../../../images/delete.gif" border="0" ></a>
	  <%}else{%>
	  N/A
	  <%}%>	  </td>
    </tr>
    <%} //end for loop%>
  </table></td>
  </tr>
</table>
	
	<%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="proceed">
	<input type="hidden" name="show_all" value="1">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>