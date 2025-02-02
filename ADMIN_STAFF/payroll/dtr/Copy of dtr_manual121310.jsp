<%@ page language="java" import="utility.*,payroll.PReDTRME, payroll.PRSalaryRate, payroll.PRSalary,
	payroll.PRMiscDeduction, payroll.PRLoansAdv, enrollment.FacultyManagement, payroll.PRRetirementLoan,
	payroll.PRSalaryExtn,	payroll.PRConfidential, java.util.Vector, java.util.Date" buffer="24kb"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
//System.out.println("1 " + strColorScheme[1]);
//System.out.println("2 " + strColorScheme[2]);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>DTR Manual</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function Recompute(){
	var vProceed = confirm("This would remove the employee payroll. Do you want to continue?");
	if(vProceed){
		document.form_.prepareToEdit.value = "0";
		document.form_.page_action.value = "";
		document.form_.ResetFacultyPay.value = "";
		document.form_.recompute.value = "1";
		document.form_.submit();
	//this.SubmitOnce('form_');
	}else{
		return;
	}
}

function ReloadPage() {
	document.form_.prepareToEdit.value = "0";
	document.form_.page_action.value = "";
	document.form_.ResetFacultyPay.value = "";
	this.SubmitOnce('form_');
}

function CancelRecord(){
	document.form_.prepareToEdit.value = "0";
	document.form_.page_action.value = "";
	document.form_.ResetFacultyPay.value = "";
	this.SubmitOnce('form_');
}

function ResetFacultyPay(strSalIndex){
	document.form_.ResetFacultyPay.value = "1";
	document.form_.info_index.value = strSalIndex;
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}

function PageAction(strAction, strInfoIndex, strDedIndex) {
	document.form_.page_action.value = strAction;
	if(strDedIndex.length > 0){
		document.form_.Ded_index.value = strDedIndex;
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1)
		document.form_.save.disabled = true;
	document.form_.submit();
		//document.form_.hide_save.src = "../../../images/blank.gif";
	//this.SubmitOnce('form_');
}

function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce('form_');
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID() {
	document.form_.emp_id.focus();
}

function UpdateSalPeriod() {
	var pgLoc = "./salary_period.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function updateLoans(){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
//	var pgLoc = "../loans_advances/view_edit_loans.jsp?emp_id="+document.form_.emp_id.value+
//				"&sal_period_index="+document.form_.sal_period_index.value+
//				"&sal_index="+strSalIndex;
	var pgLoc = "./pay_loansmisc/pay_loans.jsp?emp_id="+document.form_.emp_id.value+
				"&index_name=salary_index&index="+document.form_.sal_index.value+
				"&sal_period_index="+document.form_.sal_period_index.value;
	var win=window.open(pgLoc,"updateLoan",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function updateAllowances(){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../configuration/view_edit_allowances.jsp?emp_id="+document.form_.emp_id.value+
				"&sal_period_index="+document.form_.sal_period_index.value+
				"&sal_index="+document.form_.sal_index.value;				
	var win=window.open(pgLoc,"updateAllowances",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function updateEarnDed(){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../earnings_deductions/view_edit_ded.jsp?emp_id="+document.form_.emp_id.value+
							"&sal_index="+document.form_.sal_index.value;
	var win=window.open(pgLoc,"updateEarnDed",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function updateMiscellaneous(strSalIndex){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
//	var pgLoc = "../misc_deductions/view_edit_misc.jsp?emp_id="+document.form_.emp_id.value+
//  "&sal_index="+strSalIndex;
	var pgLoc = "./pay_loansmisc/pay_misc.jsp?emp_id="+document.form_.emp_id.value+
				"&index_name=salary_index&index="+strSalIndex;	
	var win=window.open(pgLoc,"updateMiscDed",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function encodeMiscellaneous(strDateFrom,strDateTo){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../misc_deductions/post_ded.jsp?popup=1&emp_id="+document.form_.emp_id.value+
							"&month_of="+document.form_.month_of.value+
							"&year_of="+document.form_.year_of.value+
							"&sal_period_index="+document.form_.sal_period_index.value+
							"&date_from="+strDateFrom+"&date_to="+strDateTo;
							
	var win=window.open(pgLoc,"updateMiscDed",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}


function updateMiscEarnings(){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../misc_earnings/edit_misc_earning.jsp?emp_id="+document.form_.emp_id.value+
				"&sal_period_index="+document.form_.sal_period_index.value+
				"&sal_index="+document.form_.sal_index.value;
	var win=window.open(pgLoc,"updateMiscEarn",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function updateContributions(){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "./other_contributions.jsp?emp_id="+document.form_.emp_id.value+
							"&sal_index="+document.form_.sal_index.value;
	var win=window.open(pgLoc,"UpdateCont",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function updateIncentives(){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "./edit_incentives.jsp?emp_id="+document.form_.emp_id.value+
							"&sal_index="+document.form_.sal_index.value;
	var win=window.open(pgLoc,"updateIncent",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function ViewSalDetail() {
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../salary_rate/salary_rate.jsp?view=1&emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewOtherDeductionDetail() {
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../misc_deductions/post_ded.jsp?view=1&emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewLoansAndOtherDetail(){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../loans_advances/loans_advances_entry.jsp?view=1&emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}

function ViewHrsWorkDetail(strDateFrom,strDateTo) {
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../../e_dtr/dtr_operations/dtr_view_detail.jsp?view=1&DateDefaultSpecify=1&SummaryDetail=1&from_date="+strDateFrom+"&to_date="+strDateTo+"&emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateToZero(strTextName){
	if(eval('document.form_.'+strTextName+'.value.length') == 0){
		eval('document.form_.'+strTextName+'.value= "0"');
	}
}

function ComputeLoanPayable(strRow){
	var vPrincipal = eval('document.form_.principal_amt'+strRow+'.value');
	var vInterest =  eval('document.form_.interest_amt'+strRow+'.value');
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vLoanCount = document.form_.loan_count.value;
	  if (vPrincipal.length == 0){
		vPrincipal = "0";
	  }

	  if (vInterest.length == 0){
		vInterest = "0";
	  }

	  vPeriodPay = eval(vPrincipal) +  eval(vInterest);
		vPeriodPay = truncateFloat(vPeriodPay,2,false);
	  eval('document.form_.period_pay'+strRow+'.value = vPeriodPay');

	for(var i = 0; i < eval(vLoanCount);i++){
		vPeriodPay = eval('document.form_.period_pay'+i+'.value');
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);
	}
	document.form_.loans_adv_deduction.value = eval(vTotalPay);
 	document.form_.loans_adv_deduction.value = truncateFloat(document.form_.loans_adv_deduction.value,2,false);
 	ComputeLoansMisc();
}

function ComputeMiscPayable(strRow){
	var vAmount = eval('document.form_.misc_amt'+strRow+'.value');
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vMiscCount = document.form_.misc_count.value;
	  if (vAmount.length == 0){
		return;
	  }

	for(var i = 0; i < eval(vMiscCount);i++){
		vPeriodPay = eval('document.form_.misc_amt'+i+'.value');
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);
	}
	document.form_.misc_deduction.value = eval(vTotalPay);
	document.form_.misc_deduction.value = truncateFloat(document.form_.misc_deduction.value,2,false);
	ComputeLoansMisc();
}

function ComputeIncentive(strRow){
	var vAmount = eval('document.form_.incentive_amt'+strRow+'.value');
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vTaxStatus = null;
	var vTotalTaxable = 0;	
	var vTaxableHon = document.form_.taxable_honorarium.value;
	var vIncCount = document.form_.incentive_count.value;
	  if (vAmount.length == 0){
		return;
	  }
	
	for(var i = 0; i < eval(vIncCount);i++){
		vPeriodPay = eval('document.form_.incentive_amt'+i+'.value');
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);
		vTaxStatus = eval('document.form_.incentive_tax'+i+'.value');
		if(vTaxStatus == 1){
		vTotalTaxable = eval(vTotalTaxable) + eval(vPeriodPay);
		}
	}
		
	document.form_.total_incentive.value = eval(vTotalPay);	
	document.form_.taxable_inc.value = eval(vTotalTaxable);		
	vTotalTaxable = eval(vTotalTaxable) + eval(vTaxableHon);	
	document.form_.total_tax_inc.value = eval(vTotalTaxable);
}

function ComputeHonor(strRow){
	var vAmount = eval('document.form_.honorarium_amt'+strRow+'.value');
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vTaxStatus = null;
	var vTotalTaxable = 0;	
	var vTaxableInc = document.form_.taxable_inc.value;
	var vHonCount = document.form_.honorarium_count.value;
	  if (vAmount.length == 0){
		return;
	  }

	for(var i = 0; i < eval(vHonCount);i++){
		vPeriodPay = eval('document.form_.honorarium_amt'+i+'.value');
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);
		vTaxStatus = eval('document.form_.honorarium_tax'+i+'.value');
		if(vTaxStatus == 1){
		vTotalTaxable = eval(vTotalTaxable) + eval(vPeriodPay);
		}
	}
	
	document.form_.taxable_honorarium.value = eval(vTotalTaxable);	
	document.form_.honorarium.value = eval(vTotalPay);
	vTotalTaxable = eval(vTotalTaxable) + eval(vTaxableInc);	
	document.form_.total_tax_inc.value = eval(vTotalTaxable);	
}

function ComputeMiscEarning(strRow){
	var vAmount = eval('document.form_.earning_amt'+strRow+'.value');
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vMiscCount = document.form_.earning_count.value;
	var vTaxStatus = null;
	var vTotalTaxable = 0;	
	
	if (vAmount.length == 0)
		return;	

	for(var i = 0; i < eval(vMiscCount);i++){
		vPeriodPay = eval('document.form_.earning_amt'+i+'.value');
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);

		vTaxStatus = eval('document.form_.earning_tax'+i+'.value');
		if(vTaxStatus == 1){
		vTotalTaxable = eval(vTotalTaxable) + eval(vPeriodPay);
		}		
	}
	document.form_.misc_earning.value = eval(vTotalPay);
	document.form_.taxable_earning.value = eval(vTotalTaxable);	
	
}

function ComputeAllowance(strRow){
	var vAmount = eval('document.form_.allowance_amt'+strRow+'.value');
	var vTaxStatus = null;
	var vTotalTaxable = 0;
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vAllowCount = document.form_.allowance_count.value;
	  if (vAmount.length == 0){
		return;
	  }

	for(var i = 0; i < eval(vAllowCount);i++){
		vPeriodPay = eval('document.form_.allowance_amt'+i+'.value');
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);
		vTaxStatus = eval('document.form_.allowance_tax'+i+'.value');
		if(vTaxStatus == 1){
		vTotalTaxable = eval(vTotalTaxable) + eval(vPeriodPay);
		}
	}

	vAllowCount = document.form_.sub_allow_count.value;
	for(var i = 0; i < eval(vAllowCount);i++){
		vPeriodPay = eval('document.form_.sub_allow_amt_'+i+'.value');
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);
		vTotalTaxable = eval(vTotalTaxable) + eval(vPeriodPay);
	}
	
	document.form_.total_allowance.value = eval(vTotalPay);
	document.form_.taxable_allowance.value = eval(vTotalTaxable);	
}

function ComputeContPayable(strRow){
	var vAmount = eval('document.form_.other_cont_amt'+strRow+'.value');
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vContCount = document.form_.cont_count.value;
	  if (vAmount.length == 0){
		return;
	  }

	for(var i = 0; i < eval(vContCount);i++){
		vPeriodPay = eval('document.form_.other_cont_amt'+i+'.value');
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);
	}
	document.form_.other_contribution.value = eval(vTotalPay);
	document.form_.other_contribution.value = truncateFloat(document.form_.other_contribution.value,2,false);
	ComputeLoansMisc();
}

function ComputeLoansMisc(){
  if(document.form_.loans_misc_ded){
	  document.form_.loans_misc_ded.value = eval(document.form_.loans_adv_deduction.value) +
											eval(document.form_.misc_deduction.value) +
											eval(document.form_.other_contribution.value);
	  document.form_.loans_misc_ded.value = truncateFloat(document.form_.loans_misc_ded.value,2,false);
  }
}

function ComputeOvertime(){
	var vRegular = document.form_.regular_ot.value;	
	var vRestDay = document.form_.restday_ot.value;
	var vRegularRate = document.form_.reg_rate.value;
	var vRestDayRate = document.form_.rest_rate.value;
	var vHourlyRate = document.form_.hourly_rate.value;
	var vRegAmt = 0;	
	var vRestAmt = 0;	
	
	var vTotalHr = 0;
	var vTotalAmt = 0;
	
	if(vRegular.length == 0 || vRestDay.length == 0)
		return;
	
	if(vRegularRate > 0){
		vRegularRate = 1 + eval(vRegularRate)/100;	
		vRegAmt = eval(vRegular) * eval(vRegularRate) * eval(vHourlyRate);		
	}
	
	if(vRestDayRate > 0){
		vRestDayRate = 1 + eval(vRestDayRate)/100;	
		vRestAmt = eval(vRestDay) * eval(vRestDayRate) * eval(vHourlyRate);		
	}
	
	document.form_.reg_ot_amt.value = eval(vRegAmt);
	document.form_.reg_ot_amt.value = truncateFloat(document.form_.reg_ot_amt.value,1,true);
	document.form_.rest_ot_amt.value = eval(vRestAmt);			
	document.form_.rest_ot_amt.value = truncateFloat(document.form_.rest_ot_amt.value,1,true);
	
	vTotalAmt = eval(document.form_.rest_ot_amt.value) + eval(document.form_.reg_ot_amt.value);	
	vTotalHr = eval(vRestDay) + eval(vRegular);	
	document.form_.OT_Amt.value = eval(vTotalAmt);
	document.form_.OT_Amt.value = truncateFloat(document.form_.OT_Amt.value,1,false);
	document.form_.hours_OT.value = eval(vTotalHr);
}

function updateOTHour(strRow){
	var vAmount = eval('document.form_.ot_hour_'+strRow+'.value');
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vCount = document.form_.ot_count.value;
	
	for(var i = 0; i < eval(vCount);i++){
		vPeriodPay = eval('document.form_.ot_hour_'+i+'.value');
		if(vPeriodPay.length == 0)
			continue;
			
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);
	}
 	document.form_.hours_OT.value = eval(vTotalPay);			
}

function updateOTAmount(strRow){
	/*
	var vTotalAmt = 0;
	var vRegularAmt = document.form_.reg_ot_amt.value;	
	var vRestDayAmt = document.form_.rest_ot_amt.value;

	if(vRegularAmt.length == 0 || vRestDayAmt.length == 0)
		return;
	
	if(isNaN(vRegularAmt) || isNaN(vRestDayAmt))
		return;
		
	vTotalAmt = eval(vRegularAmt) + eval(vRestDayAmt);	
	document.form_.OT_Amt.value = eval(vTotalAmt);
	document.form_.OT_Amt.value = truncateFloat(document.form_.OT_Amt.value,1,false);	
	*/
	var vAmount = eval('document.form_.ot_amt_'+strRow+'.value');
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vCount = document.form_.ot_count.value;
 	
//if (vAmount.length == 0)
//		return;	

	for(var i = 0; i < eval(vCount);i++){
		vPeriodPay = eval('document.form_.ot_amt_'+i+'.value');
		if(vPeriodPay.length == 0)
			continue;
			
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);
	}
 	document.form_.OT_Amt.value = eval(vTotalPay);			
}
/*
function setLabelText(strLabelName, strLabel){
	var strOld = document.getElementById(strLabelName).innerHTML;
	var strNewValue = prompt(strLabel, strOld);

	if(isNaN(strNewValue)){
		return;
	}
	if(eval(strNewValue) < 0){
		return;
	}
	if (strNewValue != null && strNewValue.length > 0){
		document.getElementById(strLabelName).innerHTML = strNewValue;
		if(document.form_.manual_tax)
			document.form_.manual_tax.value= strNewValue;
	}
}
*/

///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}

///////////////////////////////////////// End of collapse and expand filter ////////////////////

function CopyID(strID)
{
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	//var iframe = document.getElementById('iframetop');
	//var layer = document.getElementById("processing_");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
	//	layer.style.display = 'none';	
		//iframe.style.display = 'none';		
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
	
	//layer.style.display = 'block';	
	//iframe.style.display = 'block';
	//alert("offsetWidth " + (layer.offsetWidth-5));
	//iframe.style.width = layer.offsetWidth-5;	
	//iframe.style.left = layer.offsetLeft;
	//iframe.style.top = layer.offsetTop;
	//alert("layer " + (layer.offsetHeight-5));
	//alert("height " + (objCOAInput.offsetHeight-5));	
	//alert("width " + (iframe.style.width));
	//alert("height " + (iframe.style.height));
	//
	//iframe.style.height = (layer.offsetHeight-5);
	 
}

function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function viewLateDetails(strEmpID, strYear, strDateFrom, strDateTo){
//popup window here. 
	var pgLoc = null;
	<%if(bolIsSchool){%>
	 pgLoc = "../../e_dtr/reports/summary_emp_late_timein_detail.jsp?show_detail=1&viewRecords=1&emp_id="+escape(strEmpID)+
		"&from_date=" + escape(strDateFrom) + "&to_date=" + escape(strDateTo) +
		//"&month=" + document.form_.month_of[document.form_.month_of.selectedIndex].value + 
		"&year="+strYear;
	<%}else{%>
	 pgLoc = "../../edtr/reports/summary_emp_late_timein_detail.jsp?show_detail=1&viewRecords=1&emp_id="+escape(strEmpID)+
		"&from_date=" + escape(strDateFrom) + "&to_date=" + escape(strDateTo) +
		//"&month=" + document.form_.month_of[document.form_.month_of.selectedIndex].value + 
		"&year="+strYear;	
	<%}%>
		
	var win=window.open(pgLoc,"ShowLateDetail",'width=550,height=400,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewUTDetails(strUserIndex, strEmpID, strDateFrom, strDateTo){
	var pageLoc = null;
 	<%
 	if(bolIsSchool){%>
		pageLoc = "../../e_dtr/reports/summary_emp_undertime_detail.jsp?strUserIndex="+strUserIndex+
		"&strDateFrom="+escape(strDateFrom)+"&strDateTo="+escape(strDateTo)+	
		"&emp_id=" + escape(strEmpID);
	<%}else{%>
		pageLoc = "../../edtr/reports/summary_emp_undertime_detail.jsp?strUserIndex="+strUserIndex+
		"&strDateFrom="+escape(strDateFrom)+"&strDateTo="+escape(strDateTo)+	
		"&emp_id=" + escape(strEmpID);		
	<%}%>
	var win=window.open(pageLoc,"ShowUTDetails",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strNoFormula = null;
	WebInterface WI = new WebInterface(request);
	boolean bolHasInternal = false;
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-DTR"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-DTR Entry (Manual)","dtr_manual.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasInternal = (readPropFile.getImageFileExtn("HAS_INTERNAL","0")).equals("1");
 	}	catch(Exception exp){
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}

	PReDTRME prEdtrME = new PReDTRME();
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	PRSalary salary = new PRSalary();
	PRSalaryExtn salaryExtn = new PRSalaryExtn();	
	FacultyManagement FM = new FacultyManagement();
	PRMiscDeduction prd = new PRMiscDeduction(request);
	PRConfidential prCon = new PRConfidential();

	Vector vDTRManual 		= null; // Details of the DTR manual entry
	Vector vSalaryPeriod 	= null;// detail of salary period.
	Vector vLoansAndAdv     = null;
	Vector vMiscDeductions  = null;
	Vector vOtherCons       = null;
	Vector vDTRDetails      = null;
	Vector vLoadDetails     = null;
	Vector vSalIncentives   = null;
	Vector vHonorarium      = null;
	Vector vFacultySalary   = null;
	Vector vUnworkedDays    = null;
	Vector vLoans			      = null;
	Vector vAllowances		  = null;
	Vector vEmpList         = null;
	Vector vMiscEarnings    = null;
	Vector vOTDetail        = null;
	Vector vOverload        = null;
	Vector vSubAllowance    = null;
	Vector vUserDetail     = null;
	Vector vOTWithType      = null;
 	double dLoansAdvMisc    = 0d;
	double dTeachingRate    = 0d;
	double dFacAbsentAmt    = 0d;
	double dTotalAllowance  = 0d;
	double dTotalEarnings   = 0d;
	double dTaxableEarnings = 0d;
	double dTaxableAllowance = 0d;
	double dTaxableIncentive = 0d;
	double dTaxableHonor = 0d;
	double dTotalTaxInc = 0d;	

	boolean bolShowDetails = false;
	boolean bolOnLeave = false;
	boolean bolMoreDeduct = false;
	boolean bolIsReleased = false;
	double dDaysAwol = 0d;
	double dHoursAwol = 0d;
	double dTemp = 0d;

	String strEmpID = WI.fillTextValue("emp_id");
	String[] astrTeachingUnit = {"Per hour","Per Unit","Per Session"};
	String[] astrTaxStatus = {"Zero","Single","Head of the Family","Married"};
	String[] astrExemptionName = {"Zero", "Single","Head of the Family", "Head of Family 1 Dependent (HF1)", 
																"Head of Family 2 Dependents (HF2)","Head of Family 3 Dependents (HF3)", 
																"Head of Family 2 Dependents (HF4)", "Married Employed", 																	 
																"Married Employed 1 Dependent (ME1)", "Married Employed 2 Dependents (ME2)",
																"Married Employed 3 Dependents (ME3)", "Married Employed 4 Dependents (ME4)"};
	String strTaxStatus = null;																		
	String strSYFr = null;
	String strSYTo = null;
	String strCurSem = null;

	String strTemp2 = null;
	int iTaxStatus  = 0;
	String 	strDateFrom  = null;
	String 	strDateTo  = null;
	String strReadOnly = null;
	String strPtFt = "";

	int iCount = 0;
	int l = 0;
	int iRow = 0;
	
	String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));	
 //	String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
//							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");


	Vector vSemSetting = salaryExtn.getEmpSemSetting(dbOP, strEmployeeIndex, WI.getTodaysDate());
 	if(vSemSetting != null && vSemSetting.size() > 0){
		// [0] sem_date_index [1] term_type [1=semester, 2=trimester]
		// [2] term [summer, 1st term , 2nd term, 3rd term]
		// [3] date_from [4] date_to [5] max_units
		// [6] sy_from_  [7] sy_to
		strCurSem = (String)vSemSetting.elementAt(2);
		strSYFr = (String)vSemSetting.elementAt(6);
		strSYTo = (String)vSemSetting.elementAt(7);
	}

	String strSchCode = dbOP.getSchoolIndex();
	if(strSchCode.startsWith("VMUF") || strSchCode.startsWith("CLDH")){
		bolShowDetails = true;
	}
	
	if (WI.fillTextValue("ResetFacultyPay").length() > 0 && vSemSetting != null && vSemSetting.size() > 0){
		if (salary.operateOnFacultyPay(dbOP,request,strCurSem, strSYFr, strSYTo) == false)
			strErrMsg = salary.getErrMsg();
		else
			strErrMsg = "Faculty Salary is updated";
	}

	if(WI.fillTextValue("recompute").length() > 0){
		if (salaryExtn.removeSavedPayroll(dbOP,request, WI.fillTextValue("sal_index")) == false)
			strErrMsg = salaryExtn.getErrMsg();
		else{
			strErrMsg = "Removed Payroll";
		}
	}
	
if (strEmpID.length() > 0 && WI.fillTextValue("sal_period_index").length() > 0 && WI.fillTextValue("reset_page").length() == 0) {
	vUserDetail = salaryExtn.getEmployeeInfo(dbOP, strEmployeeIndex);	
 	if(bolIsSchool && vSemSetting != null && vSemSetting.size() > 0){
		vLoadDetails = FM.viewFacultyDetail(dbOP, strEmployeeIndex, strSYFr, strSYTo, strCurSem);
	}
//	vUserDetail = FM.viewFacBasicWithLoadStat(dbOP, strEmployeeIndex, strSYFr, strSYTo, strCurSem);  
	if(new payroll.PRBuiltInCI().checkIfEmployeeIsCI(dbOP, strEmployeeIndex)){
		strErrMsg = "Cannot process CI Employee salary in this page";
	}else{
		vDTRDetails = salary.getDTRDetails(dbOP,request);		
		if (vDTRDetails == null){
			strErrMsg = salary.getErrMsg();
		}else{
			vSalIncentives = (Vector)vDTRDetails.elementAt(10);
			vHonorarium    = (Vector)vDTRDetails.elementAt(31);
			vLoans         = (Vector)vDTRDetails.elementAt(47);
			vMiscDeductions= (Vector)vDTRDetails.elementAt(48);
			vOtherCons		 = (Vector)vDTRDetails.elementAt(49);
			vAllowances		 = (Vector)vDTRDetails.elementAt(50);
			vMiscEarnings  = (Vector)vDTRDetails.elementAt(59);
			vOTDetail			 = (Vector)vDTRDetails.elementAt(60);
			vOverload      = (Vector)vDTRDetails.elementAt(67);
			vSubAllowance  = (Vector)vDTRDetails.elementAt(69);
			vOTWithType    = (Vector)vDTRDetails.elementAt(76);
			
			if(vDTRDetails.elementAt(39) != null){
				if(((Double)vDTRDetails.elementAt(39)).doubleValue() <= 0 
					&& (((Double)vDTRDetails.elementAt(3)).doubleValue() > 0
						|| ((Double)vDTRDetails.elementAt(5)).doubleValue() > 0) 
					&& vOverload == null){
				bolOnLeave = true;
				strErrMsg = "Employee is on Leave. Deductions and Earnings will be ignored.";
				}
			}
		}
		
		//vDTRManual = salary.operateOnDTRManual(dbOP, request, 4);
		//System.out.println("vDTRManual -- " + vDTRManual);
		vEmpList = prd.getEmployeesList(dbOP);	

		int iTemp = prCon.checkIfEmpIsProcessor(dbOP, request, strEmployeeIndex, false);
		// dont use in the java file
		// if checking is done in the java file..dili na maka view ang employee sa sariling payslip!!!
    if(iTemp < 1){
      if(iTemp == 0)
        strErrMsg = "Not allowed to process the employee. -";
      else
        strErrMsg = "Query Error";
			vDTRDetails = null;
    }
	}
}

if(WI.fillTextValue("year_of").length() > 0) {
// old
//	vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);
// new
	vSalaryPeriod = prEdtrME.getEmployeePeriods(dbOP, request, strEmployeeIndex);
	if(vSalaryPeriod == null)
		strErrMsg = prEdtrME.getErrMsg();
}

String strPageAction = WI.fillTextValue("page_action");
  if(strPageAction.length() > 0 && (!strPageAction.equals("6"))) {
		if(salary.operateOnDTRManual(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = salary.getErrMsg();
			//vDTRDetails = null;
		} else {
			if(strPageAction.equals("1"))
				strErrMsg = "DTR successfully posted.";
			if(strPageAction.equals("2")){
				strErrMsg = "DTR information successfully edited.";
				}
			if(strPageAction.equals("0"))
				strErrMsg = "DTR information successfully removed.";
			if(strPageAction.equals("5"))
				strErrMsg = "Successfully removed deduction.";			
		}		
		//vDTRManual = salary.operateOnDTRManual(dbOP, request, 4);
		//System.out.println("vDTRManual ----- " + vDTRManual);
  }
	vDTRManual = salary.operateOnDTRManual(dbOP, request, 4);
//	System.out.println("vDTRDetails " + vDTRDetails);
//	System.out.println("vDTRManual " + vDTRManual);
	if(vDTRManual != null && vDTRManual.size() > 0){
		strPrepareToEdit = "1";
		if(((String)vDTRManual.elementAt(41)).equals("1")){
			bolIsReleased = true;
		}		
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		if (strPageAction.equals("6")){
			vEditInfo = salary.operateOnDTRManual(dbOP, request,6);
		}else {
			vEditInfo = vDTRManual;
		}
		
		if(vEditInfo == null){
			strPrepareToEdit = "0";
			strErrMsg = salary.getErrMsg();
			vDTRDetails = null;
		}else{
			vLoans          = (Vector)vEditInfo.elementAt(1);
			vMiscDeductions = (Vector)vEditInfo.elementAt(0);
			vOtherCons		  = (Vector)vEditInfo.elementAt(42);
			vAllowances	  	= (Vector)vEditInfo.elementAt(59);
			vMiscEarnings  	= (Vector)vEditInfo.elementAt(62);
			vSalIncentives  = (Vector)vEditInfo.elementAt(63);
			vHonorarium     = (Vector)vEditInfo.elementAt(64);
			vOTDetail       = (Vector)vEditInfo.elementAt(65);
			vSubAllowance   = (Vector)vEditInfo.elementAt(69);
			vOTWithType    = (Vector)vEditInfo.elementAt(78);
		}
	}	
%>
<form name="form_" action="./dtr_manual.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
			PAYROLL:  DTR ENTRY (MANUAL) PAGE ::::</strong></font></td>
		</tr>
	</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="3">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
      <td width="46%"><div align="right">
        <%
	  		if (vEmpList != null && vEmpList.size() > 0){
			  %>
        <%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.indexOf((String)vEmpList.elementAt(0))){%>
        <a href="javascript:CopyID('<%=vEmpList.elementAt(0)%>');">FIRST</a>
        <%}else{%>
FIRST
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) > 0){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) - 1)%>');"> PREVIOUS</a>
<%}else{%>
PREVIOUS
<%}%>
<%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) < vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) + 1)%>');"> NEXT</a>
<%}else{%>
NEXT
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=((String)vEmpList.elementAt(vEmpList.size()-1)).toUpperCase()%>');">LAST</a>
<%}else{%>
LAST
<%}%>
<%}// if (vEmpList != null && vEmpList.size() > 0)%>
      </div></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td>Employee ID</td>
      <td colspan="2"><input name="emp_id" type="text" size="16" value="<%=strEmpID%>" class="textbox" onKeyUp="AjaxMapName(1);"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>				
				<!--
				<iframe width="0" scrolling="no" height="0" frameborder="0" id="iframetop" style="position:absolute;height:75;">
				</iframe>
				-->
				<div style="position:absolute; overflow:auto; width:300px;" id="processing_">
				<label id="coa_info"></label>
				</div>				
			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="2"> <select name="month_of" onChange="document.form_.reset_page.value='1';ReloadPage();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
        </select> -
				<select name="year_of" onChange="document.form_.reset_page.value='1';ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"), 2, 1)%>
        </select> (Must be filled up to display salary period information)</td>
    </tr> 
    <tr>
      <td height="25">&nbsp;</td>
      <td width="19%">Salary Period</td>
      <td colspan="2">
			
	  <select name="sal_period_index" style="font-weight:bold;font-size:11px;" onChange="document.form_.reset_page.value='1';ReloadPage();">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");
 		for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
		  if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
			strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
			strTemp2 += "Whole Month";
		  }else{
			strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
			strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//			strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//				(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		  }
			
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
          <%
		  	strDateFrom = (String)vSalaryPeriod.elementAt(i+1);
		  	strDateTo = (String)vSalaryPeriod.elementAt(i+2);
			strPtFt = "select pt_ft from info_faculty_basic where user_index = " + strEmployeeIndex;
			strPtFt = dbOP.getResultOfAQuery(strPtFt,0);
			if(strPtFt == null)
				strPtFt = "1";
		  %>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
          <%}//end of if condition.
		 }//end of for loop.%>
        </select>
				<%if(bolHasInternal){
					strTemp = WI.fillTextValue("show_external");
					if(strTemp.length() > 0)
						strTemp = "checked";
					else	
						strTemp = "";
				%>
				<input type="checkbox" name="show_external" value="1" <%=strTemp%> onClick="ReloadPage();">
				<font size="1">show external</font>
				<%}%>
			</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><!--<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>-->
			<font size="1">
<input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">			
Click to reload page</font></td>
    </tr>
    <tr>
      <td height="10" colspan="4"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
 <% 
if(vDTRDetails != null && vDTRDetails.size() > 0){	
	if((vUserDetail != null && vUserDetail.size() > 0) ){
%>

<% 
	strTemp = (String)vDTRDetails.elementAt(40);
	vUnworkedDays = (Vector) vDTRDetails.elementAt(41);
	strTemp2 = ((Double)vDTRDetails.elementAt(29)).toString(); // number days absent
%>
<input type="hidden" name="is_senior_citizen" value="<%=WI.getStrValue(strTemp,"0")%>">
<input type="hidden" name="days_absent" value="<%=WI.getStrValue(strTemp2,"0")%>">
<%if(bolOnLeave)
 	strTemp = "1";
  else
	strTemp = "0";
%>
<input type="hidden" name="is_on_leave" value="<%=WI.getStrValue(strTemp,"0")%>">
<input type="hidden" name="ot_string" value="<%=WI.getStrValue((String)vDTRDetails.elementAt(73),"")%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="22">&nbsp;</td>
      <td width="23%"> Name</td>
      <% 
			strTemp =WI.formatName((String)vUserDetail.elementAt(2),(String)vUserDetail.elementAt(3),
															(String)vUserDetail.elementAt(4),4); 
			%>
      <td colspan="2"><strong><%=WI.getStrValue(strTemp," ")%></strong></td>
      <td width="14%">Emp. Status</td>
      <%if(vUserDetail != null && vUserDetail.size() > 0 ){
	     	strTemp =(String)vUserDetail.elementAt(5);
			}else{
			  strTemp = "1";
			}
			if(strTemp.equals("1"))
				strTemp = "Full Time";
			else
				strTemp = "Part Time";				
	  %>
      <td width="35%" colspan="2">&nbsp;<strong><%=WI.getStrValue(strTemp," ")%></strong></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td> <%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office</td>
      <%if((String)vUserDetail.elementAt(7) == null || (String)vUserDetail.elementAt(8) == null){
	    	 strTemp = " ";
			}else{
				strTemp = "-";
			}
			%>
      <td colspan="2"><strong><%=WI.getStrValue(vUserDetail.elementAt(7),"")%><%=strTemp%><%=WI.getStrValue(vUserDetail.elementAt(8),"")%></strong></td>
      <td>Emp. Type</td>
      <td colspan="2">&nbsp;<strong	><%=WI.getStrValue((String)vUserDetail.elementAt(9),"")%></strong></td>
    </tr>
    <tr >
      <td height="7" colspan="7"><hr size="1" color="#0000FF"></td>
    </tr>
	</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFB895">
      <td height="18">&nbsp;</td>
      <td colspan="6"><strong><font color="#0000FF">:: COMPENSATION RATE ::</font></strong></td>
    </tr>
    <tr >
      <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){
			strTemp = (String)vDTRDetails.elementAt(22);
		}else{
			strTemp = WI.fillTextValue("salary_period");
		}
 	%>
      <td height="25">&nbsp; <input type="hidden" name="salary_period" value="<%=WI.getStrValue(strTemp,"0")%>"></td>
      <td>Basic Rate</td>
      <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){
			strTemp = (String)vDTRDetails.elementAt(26);
		}else{
			strTemp = WI.fillTextValue("monthly_rate");
		}
		%>
      <td width="11%"> <strong><%=WI.getStrValue(strTemp,"0")%></strong> <input type="hidden" name="monthly_rate" value="<%=WI.getStrValue(strTemp,"0")%>">      </td>
      <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){
			strTemp = (String)vDTRDetails.elementAt(17);
		}else{
			strTemp = WI.fillTextValue("period_rate");
		}
 		%>
      <td width="14%"><input type="hidden" name="period_rate" value="<%=WI.getStrValue(strTemp,"0")%>"></td>
      <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){
			strTemp = (String)vDTRDetails.elementAt(19);
		}else{
			strTemp = WI.fillTextValue("hourly_rate");
		}
	%>
      <td>Hourly Rate</td>
      <td colspan="2"><strong><%=WI.getStrValue(strTemp,"0")%>
        <input type="hidden" name="hourly_rate" value="<%=WI.getStrValue(strTemp,"0")%>">
        <a href="javascript:ViewSalDetail();"><img src="../../../images/view.gif" border="0"></a>
        <font size="1">View salary detail</font> </strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){
			strTemp = (String)vDTRDetails.elementAt(18);
		}else{
			strTemp = WI.fillTextValue("daily_rate");
		}
	%>
      <td>Daily Rate</td>
      <td colspan="2"><strong><%=WI.getStrValue(strTemp,"0")%></strong> <input type="hidden" name="daily_rate" value="<%=WI.getStrValue(strTemp,"0")%>">      </td>
      <%
		if (vDTRDetails != null)
			strTemp = (String)vDTRDetails.elementAt(20);
	   %>
      <td>Addl. Responsibility</td>
      <td colspan="2"><strong><%=WI.getStrValue(strTemp,"0")%></strong></td>
    </tr>
    <%if(bolIsSchool){%>
    <tr >
      <td height="25"></td>
      <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){
			strTemp = (String)vDTRDetails.elementAt(27);
		}else{
			strTemp = WI.fillTextValue("teaching_rate");
		}
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTeachingRate = Double.parseDouble(strTemp);
	%>
      <td>Teaching Rate</td>
      <td colspan="2"><strong><%=WI.getStrValue(strTemp,"0")%>
        <input type="hidden" name="teaching_rate" value="<%=WI.getStrValue(strTemp,"0")%>">
      <%
				if (vDTRDetails != null && vDTRDetails.size() > 0){
					strTemp = (String)vDTRDetails.elementAt(33);
					strTemp = astrTeachingUnit[Integer.parseInt(WI.getStrValue(strTemp,"0"))];
				}else{
					strTemp = WI.fillTextValue("overload_rate");
				}
   	  %>
        <%=WI.getStrValue(strTemp,"0")%>
        <input type="hidden" name="teaching_rate_unit" value="<%=WI.getStrValue(strTemp,"0")%>">
        </strong></td>
      <td>Total Load</td>
			<%
				if(vLoadDetails != null && vLoadDetails.size() > 0)
					strTemp = (String)vLoadDetails.elementAt(6);
				else
					strTemp = "";
			%>
      <td colspan="2"><font size="1"><strong><%=strTemp%></strong></font></td>
    </tr>
    <tr >
      <td height="25"></td>
      <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){
			strTemp = (String)vDTRDetails.elementAt(28);
		} else {
			strTemp = WI.fillTextValue("overload_rate");
		}
   	  %>
      <td>Overload Rate</td>
      <td colspan="2"><strong><%=WI.getStrValue(strTemp,"0")%>
        <input type="hidden" name="overload_rate" value="<%=WI.getStrValue(strTemp,"0")%>">
        <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){
			strTemp = (String)vDTRDetails.elementAt(34);
			strTemp = astrTeachingUnit[Integer.parseInt(WI.getStrValue(strTemp,"0"))];
		}else{
			strTemp = WI.fillTextValue("overload_rate_unit");
		}
   	  %>
        <%=WI.getStrValue(strTemp,"0")%>
        <input type="hidden" name="overload_rate_unit" value="<%=WI.getStrValue(strTemp,"0")%>">
        </strong></td>
      <td><font size="1">TOTAL NO. OF HOURS/WEEK :</font></td>
      <%if(vLoadDetails != null && vLoadDetails.size() > 0 ){
	     	  strTemp =(String)vLoadDetails.elementAt(9);
				}else{
					strTemp = "";
				}
			%>
      <td colspan="2"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr>
      <td height="36"></td>
      <td>Faculty Salary</td>
      <%
		strTemp = "0";
		if (vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String) vEditInfo.elementAt(44);
		}else{
			if (vDTRDetails != null ){
				vFacultySalary = (Vector) vDTRDetails.elementAt(32);
				if (vFacultySalary != null && vFacultySalary.size() > 0){
					strTemp = (String)vFacultySalary.elementAt(0);
				}else
					strTemp = "0";
			}else{
				strTemp = "0";
			}
		}
		strTemp = ConversionTable.replaceString(strTemp,",","");
		// (String)vDTRDetails.elementAt(33) --> strTeachRateUnit
		%>
      <td colspan="2"><strong><%=WI.getStrValue(strTemp,"0")%></strong> <input type="hidden" name="faculty_salary" value="<%=WI.getStrValue(strTemp,"0")%>">
        <%if(strPrepareToEdit.compareTo("0") != 0 && strSchCode.startsWith("UI")  && !bolIsReleased) {%> <a href='javascript:ResetFacultyPay();'>
        <img src="../../../images/update.gif" width="60" height="26" border="0" id="compute">
        </a> <%}%> </td>
      <td> <%if(strSchCode.startsWith("UDMC")){%>
        Faculty Allowance
        <%}%></td>
      <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){
			strTemp = Double.toString(((Double)vDTRDetails.elementAt(43)).doubleValue());
		}else{
			strTemp = WI.fillTextValue("fac_allowance");
		}
   	  %>
      <td colspan="2"> <%if(strSchCode.startsWith("UDMC")){%> <%=WI.getStrValue(strTemp,"")%>
        <%}%>
        <input type="hidden" name="fac_allowance" value="<%=WI.getStrValue(strTemp,"0")%>"></td>
    </tr>
    <%}// end checking if for school%>

    <%if(!strSchCode.startsWith("UI")){%>
    <tr bgcolor="#FFB895">
      <td height="18">&nbsp;</td>
      <td colspan="6"><strong><font color="#0000FF">:: WORKING HOURS/DAYS INFORMATION
        ::</font></strong></td>
    </tr>
    <tr>
      <td width="2%" height="23">&nbsp;</td>
      <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(2);
				else{
					if (vDTRDetails != null ){
						strTemp = (String)vDTRDetails.elementAt(0);
					}else{
						strTemp = WI.fillTextValue("hrs_worked");
					}
				}
			%>
      <td width="20%">Hours Worked</td>
      <td colspan="2"> 
			<input name="hrs_worked" type="text" size="10" maxlength="10" class="textbox_noborder"
		  value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
			<!--
			<a href="javascript:ViewHrsWorkDetail('<%=strDateFrom%>','<%=strDateTo%>');"><img src="../../../images/view.gif" border="0"></a>
			<font size="1">View detail</font>
			-->			</td>
      <td>Days Credited</td>
      <%
				if (vDTRDetails != null)
					strTemp = (String)vDTRDetails.elementAt(63);
				else
					strTemp = WI.fillTextValue("days_worked");
			%>			
      <td width="29%"><input name="days_worked" type="text" size="10" maxlength="10" class="textbox_noborder"
		  value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly></td>
      <td width="7%">&nbsp;</td>
    </tr>
    <%
	if(strSchCode.startsWith("VMUF") && WI.getStrValue(WI.fillTextValue("is_on_leave"),"0").equals("0")){%>
    <tr>
      <td height="23">&nbsp;</td>
      <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(46);
			else{
				if(vOverload != null && vOverload.size() > 0)
					strTemp = (String)vOverload.elementAt(0);
				else
					strTemp = WI.fillTextValue("multiplier_in");
			}

			strTemp = WI.getStrValue(strTemp,"60");
			%>
      <td>Excess Hour Multiplier</td>
      <td colspan="5"><select name="multiplier_in">
          <option value="60">60%</option>
          <% if(strTemp.compareTo("100") ==0){%>
          <option value="100"selected>100%</option>
          <%}else{%>
          <option value="100">100%</option>
          <%}%>
        </select> <font size="1">(multiplier for overload rate within regular
        office hours)</font></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(47);
		else{
			if(vOverload != null && vOverload.size() > 0)
				strTemp = (String)vOverload.elementAt(1);
			else
				strTemp = WI.fillTextValue("excess_lec_in");			
		}
	  %>
      <td>Excess Lecture hours</td>
      <td colspan="5"><input name="excess_lec_in" type="text" size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	  onBlur="AllowOnlyFloat('form_','excess_lec_in');UpdateToZero('excess_lec_in');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','excess_lec_in');" style="text-align : right"> <font size="1">(excess
        lecture hours within regular office hours)</font></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(48);
		else{
			if(vOverload != null && vOverload.size() > 0)
				strTemp = (String)vOverload.elementAt(2);
			else
				strTemp = WI.fillTextValue("excess_lab_in");						
		}
		
		%>
      <td>Excess Lab hours</td>
      <td colspan="5"><input name="excess_lab_in" type="text" size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	  onBlur="AllowOnlyFloat('form_','excess_lab_in');UpdateToZero('excess_lab_in');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','excess_lab_in');" style="text-align : right"> <font size="1">(excess
        laboratory hours within regular office hours)</font></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(49);
			else{
				if(vOverload != null && vOverload.size() > 0)
					strTemp = (String)vOverload.elementAt(3);
				else
					strTemp = WI.fillTextValue("multiplier_out");			
			}
			strTemp = WI.getStrValue(strTemp,"100");
			%>
      <td>Excess Hour Multiplier</td>
      <td colspan="5"><select name="multiplier_out">
          <option value="100">100%</option>
          <% if(strTemp.compareTo("60") ==0){%>
          <option value="60" selected>60%</option>
          <%}else{%>
          <option value="60">60%</option>
          <%}%>
        </select> <font size="1">(multiplier for overload rate outside regular
        office hours)</font></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(50);
		else{
			if(vOverload != null && vOverload.size() > 0)
				strTemp = (String)vOverload.elementAt(4);
			else
				strTemp = WI.fillTextValue("excess_lec_out");			
		}
		%>
      <td>Excess Lecture hours</td>
      <td colspan="5"><input name="excess_lec_out" type="text" size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	  onBlur="AllowOnlyFloat('form_','excess_lec_out');UpdateToZero('excess_lec_out');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','excess_lec_out');" style="text-align : right"> <font size="1">(excess
        lecture hours outside regular office hours)</font></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(51);
		else{
			if(vOverload != null && vOverload.size() > 0)
				strTemp = (String)vOverload.elementAt(5);
			else
				strTemp = WI.fillTextValue("excess_lab_out");			
		}
		%>
      <td>Excess Lab hours</td>
      <td colspan="5"><input name="excess_lab_out" type="text" size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	  onBlur="AllowOnlyFloat('form_','excess_lab_out');UpdateToZero('excess_lab_out');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','excess_lab_out');" style="text-align : right"> <font size="1">(excess
        laboratory hours outside regular office hours)</font></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>Overload Amount</td>
     	<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(67);
		else{
			if (vDTRDetails != null )
				strTemp = (String)vDTRDetails.elementAt(66);
			else
				strTemp = "0";
		}
		%>	
      <td colspan="5"><strong>
        <input  name="overload_amt" type="text" class="textbox_noborder" size="10" 
				value="<%=WI.getStrValue(strTemp,"0")%>"style="text-align : right" readonly>
      </strong></td>
    </tr>
    <%}// end if if(strSchCode.startsWith("VMUF") && WI.fillTextValue("is_on........%>
	<%if ((!strPtFt.equals("0") && strSchCode.startsWith("CGH")) || !strSchCode.startsWith("CGH")){%>
    <%if(!strSchCode.startsWith("VMUF")){%>
    <tr>
      <td height="23">&nbsp;</td>
      <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(5);
	else{
		if (vDTRDetails != null ){
			strTemp = ((Double)vDTRDetails.elementAt(3)).toString();
		}else{
			strTemp = WI.fillTextValue("leave_days_wpay");
		}
	   }
	%>
      <td>Leave With Pay</td>
      <td colspan="2"><input name="leave_days_wpay" type="text" size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right"
	  onBlur="AllowOnlyFloat('form_','leave_days_wpay');UpdateToZero('leave_days_wpay');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','leave_days_wpay');" >
        (Days)</td>
      <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(3);
	else{
		if (vDTRDetails != null ){
			strTemp = ((Double)vDTRDetails.elementAt(4)).toString();
		}else{
			strTemp = WI.fillTextValue("leave_hrs_wpay");
		}
	   }
	%>
      <td>Leave with Pay</td>
      <td colspan="2"><input name="leave_hrs_wpay" type="text" size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right"
	  onBlur="AllowOnlyFloat('form_','leave_hrs_wpay');UpdateToZero('leave_hrs_wpay');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','leave_hrs_wpay');" >
        (hrs) </td>
    </tr>
    <tr >
      <td height="23">&nbsp;</td>
      <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(6);
	else{
		if (vDTRDetails != null ){
			strTemp = ((Double)vDTRDetails.elementAt(5)).toString();
		}else{
			strTemp = WI.fillTextValue("leave_days_wopay");
		}
	   }
	%>
      <td>Leave w/out Pay</td>
      <td colspan="2"><input name="leave_days_wopay" type="text" size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right"
	  onBlur="AllowOnlyFloat('form_','leave_days_wopay');UpdateToZero('leave_days_wopay');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','leave_days_wopay');">
        (Days)</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(4);
		else{
			if (vDTRDetails != null ){
				strTemp = ((Double)vDTRDetails.elementAt(6)).toString();
			}else{
				strTemp = WI.fillTextValue("leave_hrs_wopay");
			}
		   }
	%>
      <td>Leave w/out Pay</td>
      <td colspan="2"><input name="leave_hrs_wopay" type="text" size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right"
	  onBlur="AllowOnlyFloat('form_','leave_hrs_wopay');UpdateToZero('leave_hrs_wopay');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','leave_hrs_wopay');" >
        (hrs) </td>
    </tr>
	<% if(!strSchCode.startsWith("VMUF") && bolIsSchool){%>
	<tr>
      <td height="23">&nbsp;</td>
      <td>Overload</td>
      <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(66);
			else{
				if (vDTRDetails != null )
					strTemp = (String)vDTRDetails.elementAt(65);
				else
					strTemp = "0";
			}
			%>		
      <td colspan="2"><strong>
        <input  name="overload_hr" type="text" class="textbox_noborder" size="10" 
				value="<%=WI.getStrValue(strTemp,"0")%>"style="text-align : right" readonly>
        &nbsp;</strong>(hrs)</td>
      <td>Overload Amount</td>
      <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(67);
			else{
				if (vDTRDetails != null )
					strTemp = (String)vDTRDetails.elementAt(66);
				else
					strTemp = "0";
			}
			%>			
      <td colspan="2"><strong>
        <input  name="overload_amt" type="text" class="textbox_noborder" size="10" 
				value="<%=WI.getStrValue(strTemp,"0")%>"style="text-align : right" readonly>
      </strong></td>
    </tr>	
	<%}%>
	<%}// if(!strSchCode.startsWith("VMUF"))%>
    <tr>
      <td height="23">&nbsp;</td>
      <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(7);
	else{
		if (vDTRDetails != null ){
			strTemp = (String)vDTRDetails.elementAt(1);
		}else{
			strTemp = WI.fillTextValue("hours_OT");
		}
	}
	
	if(strSchCode.startsWith("VMUF")){
		strTemp = (String)vDTRDetails.elementAt(1);
		strReadOnly = "readonly";
	}else{
		strReadOnly = "";
	}
	%>
      <td>OverTime</td>
      <td colspan="2"> <input name="hours_OT" type="text" size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	  onBlur="AllowOnlyFloat('form_','hours_OT');UpdateToZero('hours_OT');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','hours_OT');" <%=strReadOnly%> style="text-align : right">
(hrs)</td>
      <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(10);
	else{
		if (vDTRDetails != null ){
			strTemp = (String)vDTRDetails.elementAt(2);
		}else{
			strTemp = WI.fillTextValue("OT_Amt");
		}
	   }
	%>
      <td width="17%">Overtime Amount</td>
      <td colspan="2"><strong>
        <input name="OT_Amt" type="text" size="10" maxlength="10" class="textbox"
			value="<%=WI.getStrValue(strTemp,"0")%>" onFocus="style.backgroundColor='#D3EBFF'"
			onBlur="AllowOnlyFloat('form_','OT_Amt');UpdateToZero('OT_Amt');style.backgroundColor='white'"
	    onKeyUp="AllowOnlyFloat('form_','OT_Amt');" style="text-align : right" <%=strReadOnly%>>
      </strong></td>
    </tr>    	
    <tr>
      <td height="25" colspan="7">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="60%" valign="top">
				<%if(vOTWithType != null && vOTWithType.size() > 0){%>
				<div onClick="showBranch('branch8');swapFolder('folder8')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8">
          <b><font color="#0000FF">Overtime Types</font></b></div>
        <span class="branch" id="branch8">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="43%">&nbsp;</td>
            <td align="center" width="27%" ><font size="1"><strong>Number of hours </strong></font></td>
            <td align="center" width="25%"><font size="1"><strong>Amount</strong></font></td>
            <td align="center" width="5%">&nbsp;</td>
          </tr>
					<%
					iRow = 0;	
					for(int i = 1; i < vOTWithType.size(); i+=11,iRow++){%>
          <tr>
					<input name="ot_type_index_<%=iRow%>" value="<%=vOTWithType.elementAt(i)%>" type="hidden">
					<input name="is_rd_ot_<%=iRow%>" value="<%=vOTWithType.elementAt(i+3)%>" type="hidden">
					<input name="is_nd_ot_<%=iRow%>" value="<%=vOTWithType.elementAt(i+4)%>" type="hidden">
					<%
						strTemp = (String)vOTWithType.elementAt(i+9);
					%>
            <td height="20">&nbsp;<%=WI.getStrValue(strTemp)%></td>
					<%
						strTemp = (String)vOTWithType.elementAt(i+6);
					%>
            <td align="center"><strong><font size="1">
              <input name="ot_hour_<%=iRow%>" type="text" size="6" maxlength="10" class="textbox"
						onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
						style="text-align : right" onKeyUp="AllowOnlyFloat('form_','ot_hour_<%=iRow%>');updateOTHour('<%=iRow%>');" 
						onBlur="AllowOnlyFloat('form_','ot_hour_<%=iRow%>');UpdateToZero('ot_hour_<%=iRow%>');
						style.backgroundColor='white';updateOTHour('<%=iRow%>');">
            </font></strong></td>
						<%
						strTemp = (String)vOTWithType.elementAt(i+5);
						%>						
            <td align="center"><strong><font size="1">
              <input name="ot_amt_<%=iRow%>" type="text" size="10" maxlength="10" class="textbox_noborder" 
							value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" 
							onKeyUp="AllowOnlyFloat('form_','ot_amt_<%=iRow%>');updateOTAmount('<%=iRow%>');" 
							onBlur="AllowOnlyFloat('form_','ot_amt_<%=iRow%>');updateOTAmount('<%=iRow%>');UpdateToZero('ot_amt_<%=iRow%>')">
            </font></strong></td>
            <td align="center">&nbsp;</td>
          </tr>
					<%}%>
					<input type="hidden" name="ot_count" value="<%=iRow%>">
        </table>
        </span>
				<%}// end vOTWithType%>
				</td>
			  <td width="40%" valign="top">&nbsp;</td>
			</tr>
		</table>

		  </td>
    </tr>  
	<%}// if (!strPtFt.equals("0"))%>
    <%}// if(!strSchCode.startsWith("UI")%>
  </table>
  <%if ((!strPtFt.equals("0") && strSchCode.startsWith("CGH")) || !strSchCode.startsWith("CGH")){// start 1234%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFB895">
      <td height="18">&nbsp;</td>
      <td colspan="4"><strong><font color="#0000FF">:: ADDITIONAL COMPENSATION
        ::</font></strong></td>
    </tr>
    <%if(bolShowDetails){%>
    
    <%if(strSchCode.startsWith("CLDH")){%>
    <tr>
      <td height="23">&nbsp;</td>
      <td>Tax Refund</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(57);
		else{
				strTemp = "0";
			}
		%>
      <td><strong>
        <input name="tax_refund" type="text"  size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	  onBlur="AllowOnlyFloat('form_','tax_refund');UpdateToZero('tax_refund');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','tax_refund');" style="text-align : right">
      </strong></td>
      <%
			if (!strSchCode.startsWith("CLDH"))
				strTemp = "Additional Bonus";
			else
				strTemp = "Uniform";
			%>				
      <td width="15%"><%=WI.getStrValue(strTemp,"Additional Bonus")%></td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(22);
		else
	//		strTemp = WI.fillTextValue("addl_bonus_amt");
			strTemp = "0";
		%>
      <td width="26%"><strong>
        <input name="addl_bonus_amt" type="text"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'"	 style="text-align : right"
	  onBlur="AllowOnlyFloat('form_','addl_bonus_amt');UpdateToZero('addl_bonus_amt');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','addl_bonus_amt');" value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="10">
      </strong></td>
    </tr>
    <%}// para lang guid ni sa CLDH..... addl pay amount field is reused as tax refund... %>
    <%}// if(strSchCode.startsWith("VMUF") VMUF & CLDH lang!%>
    <%if(!strSchCode.startsWith("UI")){%>
    <%if(!bolShowDetails){%>
    <tr>
      <td width="2%" height="23">&nbsp;</td>
      <%
	if(vEditInfo != null && vEditInfo.size() > 0) {
		strTemp = (String)vEditInfo.elementAt(17);
	}
	else{
//		strTemp = WI.fillTextValue("addl_pay_amt");
		strTemp = "0";
	   }
	%>
      <td>Additional Pay Amount</td>
      <td><strong>
        <input name="addl_pay_amt" type="text"  size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	  onBlur="AllowOnlyFloat('form_','addl_pay_amt');UpdateToZero('addl_pay_amt');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','addl_pay_amt');" style="text-align : right">
        </strong></td>
      <td>Additional Bonus</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(22);
		else
	//		strTemp = WI.fillTextValue("addl_bonus_amt");
			strTemp = "0";
	  %>
      <td><input name="addl_bonus_amt" type="text"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'"	size="10" maxlength="10" style="text-align : right"
	  onBlur="AllowOnlyFloat('form_','addl_bonus_amt');UpdateToZero('addl_bonus_amt');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','addl_bonus_amt');" value="<%=WI.getStrValue(strTemp,"0")%>">      </td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>Addl. Pay Description</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(30);
		else
	//		strTemp = WI.fillTextValue("addl_pay_desc");
			strTemp = null;
		%>
      <td><input name="addl_pay_desc" type="text"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.getStrValue(strTemp,"")%>"></td>
      <td>Bonus Description</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(23);
		else
		//		strTemp = WI.fillTextValue("addl_bonus_desc");
			strTemp = null;
		%>
      <td><input name="addl_bonus_desc" type="text"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.getStrValue(strTemp,"")%>" style="text-align : right"></td>
    </tr>
    <%}// if(!strSchCode.startsWith("VMUF") || !strSchCode.startsWith("CLDH")) hide from addl pay to bonus desc...%>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;</td>
			<td>&nbsp;</td>
			<!--
			<%
			/*
			// additional resposibility is never used anymore... sa CPU ata ni gikan na request
			// removed july 6, 2010
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(27);
			else{
				if (vDTRDetails != null ){
					strTemp = (String)vDTRDetails.elementAt(20);
				}else{
		
					strTemp = WI.fillTextValue("addl_resp_amt");
				}
			}
			*/
			%>
			<td>Addl. Responsibility</td>
      <td colspan="2"><input name="addl_resp_amt" type="text" size="10" maxlength="10"
	  value="<%//=WI.getStrValue(strTemp,"0")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onKeyUp="AllowOnlyFloat('form_','addl_resp_amt');" style="text-align : right"
	  onBlur="AllowOnlyFloat('form_','addl_resp_amt');UpdateToZero('addl_resp_amt');style.backgroundColor='white'">
        <font size="1">(amount to be paid)</font></td>
			-->
      <td>Night Differentials </td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(25);
		else{
			if (vDTRDetails != null ){
				strTemp = (String) vDTRDetails.elementAt(9);
			} else {
				strTemp = "0";
			}
		}
		if(strSchCode.startsWith("VMUF"))
			strReadOnly = "readonly";
	%>
    <td> <input name="night_diff_amt" type="text" class="textbox" style="text-align : right"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	  onBlur="AllowOnlyFloat('form_','night_diff_amt');UpdateToZero('night_diff_amt');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','night_diff_amt');" size="10" maxlength="10" <%=strReadOnly%>>    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(26);
		else{
			if (vDTRDetails != null){
				strTemp = (String)vDTRDetails.elementAt(8);
			}else {
				strTemp = "0";
			}
		}
 		if(strSchCode.startsWith("VMUF"))
			strReadOnly = "readonly";
	%>
      <td>Holiday pay</td>
      <td> <input name="holiday_pay" type="text" class="textbox" size="10" maxlength="10"
		onFocus="style.backgroundColor='#D3EBFF'" style="text-align : right"
	  	onBlur="AllowOnlyFloat('form_','holiday_pay');UpdateToZero('holiday_pay');style.backgroundColor='white'"
		onKeyUp="AllowOnlyFloat('form_','holiday_pay');" value="<%=WI.getStrValue(strTemp,"0")%>"
		<%=strReadOnly%>> </td>
      <%
		strTemp = null;
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(16);
		else{
			if (vDTRDetails != null && vDTRDetails.size() > 0 ){
				if (vSalIncentives != null && vSalIncentives.size() > 0 ){
					strTemp = ((Double) vSalIncentives.elementAt(0)).toString();
				}else{
					strTemp = "0";
				}
			}else{
				strTemp = "0";
			}
		}
		%>
      <td>Total Incentive Amount</td>
      <td><strong>
        <input name="total_incentive" type="text" class="textbox" size="10" maxlength="10"
		 onFocus="style.backgroundColor='#D3EBFF'" style="text-align : right"
		 onBlur="AllowOnlyFloat('form_','total_incentive');UpdateToZero('total_incentive');style.backgroundColor='white'"
		 onKeyUp="AllowOnlyFloat('form_','total_incentive');" value="<%=WI.getStrValue(strTemp,"0")%>"
		 readonly>
        </strong></td>
    </tr>
    <%}// end checking for school codes%>
    <tr>
      <td height="23">&nbsp;</td>
      <%
	if (!strSchCode.startsWith("CLDH")){
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(31);
		else{
			if (vDTRDetails != null ){
				strTemp = (String)vDTRDetails.elementAt(21);
			}else{
				strTemp = WI.fillTextValue("cola_amt");
			}
		}
		strTemp2 = "";
	}else{
		strTemp = "0";
		strTemp2 = "readonly";
	}
	%>
      <td width="23%">COLA<%if(strSchCode.startsWith("CGH")){%>/ Distortion<%}%></td>
      <td> <strong>
        <input name="cola_amt" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	  onKeyUp="AllowOnlyFloat('form_','cola_amt');" <%=strTemp2%> style="text-align : right"
	  onBlur="AllowOnlyFloat('form_','cola_amt');UpdateToZero('cola_amt');style.backgroundColor='white'">
        </strong> </td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(43);
		}else{
			if (vDTRDetails != null ){				
				if (vHonorarium != null && vHonorarium.size() > 0)
				strTemp = ((Double)vHonorarium.elementAt(0)).toString();
			}else{
				strTemp = WI.fillTextValue("honorarium");
			}
		}
	%>
      <td>Honorarium</td>
      <td><strong>
        <input name="honorarium" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		 onBlur="AllowOnlyFloat('form_','honorarium');UpdateToZero('honorarium');style.backgroundColor='white'" onKeyUp="AllowOnlyFloat('form_','honorarium');"
		 value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="10" style="text-align : right"
		 readonly>
        </strong></td>
    </tr>
		<%if(bolIsSchool){%>
    <tr>
      <td height="23">&nbsp;</td>
	  <%
	  if(strSchCode.startsWith("UI"))
			strTemp = "Substitution";
		else
			strTemp = "Make-up / Sub Teaching";
		
	  %>
      <td><%=strTemp%></td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(60);
		else{
			if (vDTRDetails != null ){
				strTemp = (String)vDTRDetails.elementAt(51);
			}else{
				strTemp = WI.fillTextValue("sub_teaching");
			}
		}
       %>
      <td><strong>
        <input name="sub_teaching" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	  onKeyUp="AllowOnlyFloat('form_','sub_teaching');" <%=strTemp2%> style="text-align : right"
	  onBlur="AllowOnlyFloat('form_','sub_teaching');UpdateToZero('sub_teaching');	  style.backgroundColor='white'">
        </strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
		<%}// for school only%>
	</table>  
	<%}%>
	<%//if ((!strPtFt.equals("0") && strSchCode.startsWith("CGH")) || !strSchCode.startsWith("CGH")){// start 1234567%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
    <%if((vAllowances != null && vAllowances.size() > 6) || (vSubAllowance != null && vSubAllowance.size() > 1)){%>
    <tr>
      <td height="25" colspan="4">
				<div onClick="showBranch('branch5');swapFolder('folder5')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder5">
          <b><font color="#0000FF">Variable Allowances</font></b></div>
        <span class="branch" id="branch5">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="2%">&nbsp;</td>
            <td width="34%" align="center"><font size="1"><strong>&nbsp;ALLOWANCE NAME </strong></font></td>
            <td width="20%" align="center"><font size="1"><strong>AMOUNT</strong></font></td>
            <td width="44%">&nbsp;</td>
          </tr>
					<%if(vAllowances != null && vAllowances.size() > 6){%>
          <%iRow = 0;		  
		  for(l = 6;l < vAllowances.size(); l+=6,iRow++){%>
          <tr>
            <td>&nbsp;</td>
         <%
				strTemp = WI.getStrValue((String)vAllowances.elementAt(l+1),"&nbsp;");
				strTemp += WI.getStrValue((String)vAllowances.elementAt(l+2)," (",")","&nbsp;");
				%>
            <td>&nbsp;<%=strTemp%></td>
            <%
		  strTemp = WI.getStrValue((String)vAllowances.elementAt(l+3),"0");
		  strTemp = ConversionTable.replaceString(strTemp,",","");
		  dTotalAllowance += Double.parseDouble(strTemp);
		  if(((String)vAllowances.elementAt(l+4)).equals("1")){
			  dTaxableAllowance +=Double.parseDouble(strTemp);
		  }
		  %>
            <td align="right"><strong><font size="1">
              <input name="allowance_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','allowance_amt<%=iRow%>');ComputeAllowance('<%=iRow%>')" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','allowance_amt<%=iRow%>');UpdateToZero('allowance_amt<%=iRow%>');
			  style.backgroundColor='white';ComputeAllowance('<%=iRow%>')">
		          <input name="allowance_tax<%=iRow%>" type="hidden" value="<%=(String)vAllowances.elementAt(l+4)%>">
            </font></strong></td>
						<%if (strPrepareToEdit.equals("1")){%>
						<input type="hidden" name="allowance_index<%=iRow%>" value="<%=(String)vAllowances.elementAt(l)%>">
						<%}else{%>
							<input type="hidden" name="manual_index_<%=iRow%>" value="<%=(String)vAllowances.elementAt(l+5)%>">
							<input type="hidden" name="cola_set_index<%=iRow%>" value="<%=(String)vAllowances.elementAt(l)%>">
						<%}%>						
            <td>&nbsp;</td>
          </tr>
					<%}// end for loop allowances%>
					<%}// if (vAllowances != null && vAllowances.size() > 2)%>
	      <input type="hidden" name="allowance_count" value="<%=iRow%>">
				<% iRow = 0;
				if(vSubAllowance != null && vSubAllowance.size() > 1){%>
			    <%		  
			  for(l = 1;l < vSubAllowance.size(); l+=3,iRow++){
					strTemp = WI.getStrValue((String)vSubAllowance.elementAt(l+2),"0");
					strTemp = ConversionTable.replaceString(strTemp,",","");
					dTotalAllowance += Double.parseDouble(strTemp);
				  dTaxableAllowance += Double.parseDouble(strTemp);
				%>										
          <tr>
            <td>&nbsp;</td>
						<%
							strTemp = WI.getStrValue((String)vSubAllowance.elementAt(l+1),"&nbsp;");
						%>						
            <td>&nbsp;Subject allowance : <%=strTemp%></td>						
						<%
							strTemp = WI.getStrValue((String)vSubAllowance.elementAt(l+2),"&nbsp;");
						%>						
            <td align="right">            
              <input name="sub_allow_amt_<%=iRow%>" type="text" class="textbox_noborder" size="10" 
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>" 
				style="text-align : right" onBlur="style.backgroundColor='white';" maxlength="10" readonly>             </td>						
            <td>&nbsp;</td>
          </tr>
						<%if (strPrepareToEdit.equals("1")){%>
						<input type="hidden" name="allowance_index2_<%=iRow%>" value="<%=(String)vSubAllowance.elementAt(l)%>">
						<%}else{%>
						<input type="hidden" name="sub_allow_index_<%=iRow%>" value="<%=(String)vSubAllowance.elementAt(l)%>">
						<%}%>						
          <%}// end for loop allowances%>
					<%}%>
        </table>
        </span> </td>
      <input type="hidden" name="sub_allow_count" value="<%=iRow%>">
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="23%" height="25">Total Allowance </td>
	  <%
	  	strTemp = CommonUtil.formatFloat(dTotalAllowance,true);
			strTemp = ConversionTable.replaceString(strTemp,",","");
	  %>
      <td width="14%" height="25"><font size="1"><strong>
        <input name="total_allowance" type="text" size="10" maxlength="10" class="textbox_noborder"
		   value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
      </strong></font></td>
	  <%	  	
		strTemp = CommonUtil.formatFloat(dTaxableAllowance,true);
		strTemp = ConversionTable.replaceString(strTemp,",","");
	  %>
      <td width="61%" height="25"><font size="1"><strong>
        <input name="taxable_allowance" type="hidden" value="<%=WI.getStrValue(strTemp,"0")%>">
      </strong></font></td>
    </tr>
    <%}// end if vAllowances != null && vAllowances.size() > 0%>
  </table>	
	<%//}// end if ((!strPtFt.equals("0") && ... start 1234567%>
  <%if((vSalIncentives != null && vSalIncentives.size() > 1) || (vHonorarium != null && vHonorarium.size() > 1)){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFB895">
      <td width="1%" height="18">&nbsp;</td>
      <td colspan="5"><strong><font color="#0000FF">:: INCENTIVES &amp; HONORARIUM ::</font></strong></td>
    </tr>
		<%if ((strPtFt.equals("0") && strSchCode.startsWith("CGH"))){// start 1234%>
    <tr>
      <td height="18">&nbsp;</td>
      <td width="24%" height="18">Total Incentive Amount</td>
      <%
		strTemp = null;
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(16);
		else{
			if (vDTRDetails != null && vDTRDetails.size() > 0 ){
				if (vSalIncentives != null && vSalIncentives.size() > 0 ){
					strTemp = ((Double) vSalIncentives.elementAt(0)).toString();
				}else{
					strTemp = "0";
				}
			}else{
				strTemp = "0";
			}
		}
		%>
      <td width="34%" height="18"><strong>
        <input name="total_incentive" type="text" class="textbox" size="10" maxlength="10"
		 onFocus="style.backgroundColor='#D3EBFF'" style="text-align : right"
		 onBlur="AllowOnlyFloat('form_','total_incentive');UpdateToZero('total_incentive');style.backgroundColor='white'"
		 onKeyUp="AllowOnlyFloat('form_','total_incentive');" value="<%=WI.getStrValue(strTemp,"0")%>"
		 readonly>
      </strong></td>
      <td width="15%" height="18">Honorarium</td>
      <%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(43);
				}else{
					if (vDTRDetails != null ){				
						if (vHonorarium != null && vHonorarium.size() > 0)
						strTemp = ((Double)vHonorarium.elementAt(0)).toString();
					}else{
						strTemp = WI.fillTextValue("honorarium");
					}
				}
			%>
      <td width="23%" height="18"><strong>
        <input name="honorarium" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		 onBlur="AllowOnlyFloat('form_','honorarium');UpdateToZero('honorarium');style.backgroundColor='white'" onKeyUp="AllowOnlyFloat('form_','honorarium');"
		 value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="10" style="text-align : right"
		 readonly>
      </strong></td>
      <td width="3%" height="18">&nbsp;</td>
    </tr>
		<%}%>
    <tr>
      <td height="34" colspan="6"><div onClick="showBranch('branch12');swapFolder('folder12')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder12">
          <b><font color="#0000FF">View Incentives </font></b> </div>
        <span class="branch" id="branch12">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="49%"> 
			  <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td width="36%"><div align="center"><font size="1"><strong>INCENTIVE/HONORARIUM NAME </strong></font></div></td>
                  <td width="25%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
                  <td width="39%">&nbsp;</td>
                </tr>
                <% 
				 if(vSalIncentives != null && vSalIncentives.size() > 1){
				 iRow = 0;
				 for (int i = 1; i < vSalIncentives.size(); i +=5,iRow++){
				%>
                <tr>
                  <td height="18">&nbsp;<%=WI.getStrValue((String)vSalIncentives.elementAt(i+4))%></td>
                  <%
				  strTemp = (String)vSalIncentives.elementAt(i);
				  strTemp = ConversionTable.replaceString(strTemp,",","");
					if(((String)vSalIncentives.elementAt(i+2)).equals("1")){
						dTaxableIncentive += Double.parseDouble(strTemp);
					}				  				  
				  %>
                  <td><div align="center">&nbsp;<strong><font size="1">
                      <input name="incentive_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
				  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
				  onKeyUp="AllowOnlyFloat('form_','incentive_amt<%=iRow%>');ComputeIncentive('<%=iRow%>');" style="text-align : right"
				  onBlur="AllowOnlyFloat('form_','incentive_amt<%=iRow%>');UpdateToZero('incentive_amt<%=iRow%>');
				  ComputeIncentive('<%=iRow%>');style.backgroundColor='white'">
                      &nbsp; </font></strong><strong><font size="1">
					<input name="incentive_tax<%=iRow%>" type="hidden" value="<%=(String)vSalIncentives.elementAt(i+2)%>">					  
                      <%if (strPrepareToEdit.equals("1")){%>
                      <input type="hidden" name="incentive_index<%=iRow%>" value="<%=(String)vSalIncentives.elementAt(i+1)%>">
                      <%}%>
                      <input type="hidden" name="inc_benefit_index<%=iRow%>" value="<%=(String)vSalIncentives.elementAt(i+3)%>">
                      </font></strong></div></td>
                  <td>&nbsp;</td>
                  <input type="hidden" name="old_incentive<%=iRow%>" value="<%=WI.getStrValue(strTemp,"0")%>">                 
                </tr>
                <%}
				}%>
				<input type="hidden" name="incentive_count" value="<%=iRow%>">
			  <%		  
				strTemp = CommonUtil.formatFloat(dTaxableIncentive,true);
				strTemp = ConversionTable.replaceString(strTemp,",","");
			  %>			  
			<input name="taxable_inc" type="hidden" value="<%=WI.getStrValue(strTemp,"0")%>">				
				<% 
				 if(vHonorarium != null && vHonorarium.size() > 1){
				iRow = 0;				
				 for (int i = 1; i < vHonorarium.size(); i +=5, iRow++){
				%>
                <tr>
                  <td height="18">&nbsp;<%=WI.getStrValue((String)vHonorarium.elementAt(i+4))%></td>
                  <%
				  strTemp = (String)vHonorarium.elementAt(i);
				  strTemp = ConversionTable.replaceString(strTemp,",","");	
					if(((String)vHonorarium.elementAt(i+2)).equals("1")){
						dTaxableHonor += Double.parseDouble(strTemp);
					}						  			  
				  %>
                  <td><div align="center">&nbsp;<strong><font size="1">
                      <input name="honorarium_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
				  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
				  onKeyUp="AllowOnlyFloat('form_','honorarium_amt<%=iRow%>');ComputeHonor('<%=iRow%>');" style="text-align : right"
				  onBlur="AllowOnlyFloat('form_','honorarium_amt<%=iRow%>');UpdateToZero('honorarium_amt<%=iRow%>');
				  ComputeHonor('<%=iRow%>');style.backgroundColor='white'">
                      &nbsp; </font></strong><strong><font size="1">
					  <input name="honorarium_tax<%=iRow%>" type="hidden" value="<%=(String)vHonorarium.elementAt(i+2)%>">					  
                      <%if (strPrepareToEdit.equals("1")){%>
                      <input type="hidden" name="honorarium_index<%=iRow%>" value="<%=(String)vHonorarium.elementAt(i+1)%>">
                      <%}%>
                      <input type="hidden" name="hon_benefit_index<%=iRow%>" value="<%=(String)vHonorarium.elementAt(i+3)%>">
                      </font></strong></div></td>
                  <td>&nbsp;</td>
                  <input type="hidden" name="old_honorarium<%=iRow%>" value="<%=WI.getStrValue(strTemp,"0")%>">                  
                </tr>
                <%}
				}%>				
				<input type="hidden" name="honorarium_count" value="<%=iRow%>">
              </table></td>
			  <%		  
				strTemp = CommonUtil.formatFloat(dTaxableHonor,true);
				strTemp = ConversionTable.replaceString(strTemp,",","");
			  %>			  
			<input name="taxable_honorarium" type="hidden" value="<%=WI.getStrValue(strTemp,"0")%>">
		  <%		  
		    dTotalTaxInc = dTaxableIncentive + dTaxableHonor;
			strTemp = CommonUtil.formatFloat(dTotalTaxInc,true);
			strTemp = ConversionTable.replaceString(strTemp,",","");
		  %>
			<input name="total_tax_inc" type="hidden" value="<%=WI.getStrValue(strTemp,"0")%>">			  
          </tr>
        </table>
        </span> </td>
    </tr>
  </table> 
  <%}%>
	<% if(!strSchCode.startsWith("UI")){
	if ((!strPtFt.equals("0") && strSchCode.startsWith("CGH")) || !strSchCode.startsWith("CGH")){// start 123456%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFB895">
      <td width="2%" height="18">&nbsp;</td>
      <td colspan="6"><strong><font color="#0000FF">:: OTHER EARNINGS ::</font></strong></td>
    </tr>
    <%if(vMiscEarnings != null && vMiscEarnings.size() > 2){%>
    <tr>
      <td height="34" colspan="7">
				<div onClick="showBranch('branch11');swapFolder('folder11')">
        <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder11">
        <b><font color="#0000FF">View Miscellaneous Earnings </font></b> **<font size="1">- indicates that the earning is taxable</font></div>
        
				<span class="branch" id="branch11">				
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="2%">&nbsp;</td>
            <td width="49%"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td width="25%"><div align="center"><font size="1"><strong>&nbsp;EARNINGS 
                      NAME </strong></font></div></td>
                  <td width="25%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
                </tr>
                <% iRow = 0;
					dTotalEarnings = 0d;				
					dTaxableEarnings = 0d;
					for (l = 2; l < vMiscEarnings.size(); l+=5,iCount++,iRow++){
						if(iCount == 5){
							bolMoreDeduct = true;
							break;
						}
					%>
					<input name="earning_tax<%=iRow%>" type="hidden" value="<%=(String)vMiscEarnings.elementAt(l+4)%>">
                <tr>
									<%
										if(((String)vMiscEarnings.elementAt(l+4)).equals("1")){
											strTemp = "**";
										}else{
											strTemp = "";
										}
									%>
                  <td height="18">&nbsp;<%=(String)vMiscEarnings.elementAt(l+1)%> <%=strTemp%></td>
                  <%
									strTemp = (String)vMiscEarnings.elementAt(l+2);
									strTemp = ConversionTable.replaceString(strTemp,",","");
									dTemp = Double.parseDouble(strTemp);					
									dTotalEarnings += dTemp;					
									if(((String)vMiscEarnings.elementAt(l+4)).equals("1")){
										dTaxableEarnings += dTemp;					
									}
									%>
                  <td><div align="center">&nbsp;<strong><font size="1">
                      <input name="earning_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
				  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
				  onKeyUp="AllowOnlyFloat('form_','earning_amt<%=iRow%>');ComputeMiscEarning('<%=iRow%>');" style="text-align : right"
				  onBlur="AllowOnlyFloat('form_','earning_amt<%=iRow%>');UpdateToZero('earning_amt<%=iRow%>');
				  ComputeMiscEarning('<%=iRow%>');style.backgroundColor='white'">
                      &nbsp; </font></strong></div></td>
                  <input type="hidden" name="old_earning<%=iRow%>" value="<%=WI.getStrValue(strTemp,"0")%>">
								 <%if(strPrepareToEdit.equals("1")){%>
									<input type="hidden" name="earning_index<%=iRow%>" value="<%=(String)vMiscEarnings.elementAt(l+3)%>">
									<%}%>
                  <input type="hidden" name="post_earning_index<%=iRow%>" value="<%=(String)vMiscEarnings.elementAt(l)%>">
                </tr>
                <%}%>
              </table></td>
            <td width="49%"> <%if(bolMoreDeduct){%> <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td width="25%"><div align="center"><font size="1"><strong>&nbsp;EARNINGS NAME </strong></font></div></td>
                  <td width="25%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
                </tr>
                <%for (; l < vMiscEarnings.size(); l+=5,iCount++,iRow++){%>
								<input name="earning_tax<%=iRow%>" type="hidden" value="<%=(String)vMiscEarnings.elementAt(l+4)%>">
                <tr>
                  <td height="18">&nbsp;<%=(String)vMiscEarnings.elementAt(l+1)%></td>
                  <%
				  strTemp = (String)vMiscEarnings.elementAt(l+2);
				  strTemp = ConversionTable.replaceString(strTemp,",","");
				  dTotalEarnings += Double.parseDouble(strTemp);

					if(((String)vMiscEarnings.elementAt(l+4)).equals("1"))
						dTaxableEarnings += dTemp;										
				  %>
                  <td><div align="center">&nbsp;<strong><font size="1">
                      <input name="earning_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','earning_amt<%=iRow%>');ComputeMiscEarning('<%=iRow%>');" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','earning_amt<%=iRow%>');UpdateToZero('earning_amt<%=iRow%>');
			  ComputeMiscEarning('<%=iRow%>');style.backgroundColor='white'">
                      &nbsp; </font></strong></div></td>
                  <input type="hidden" name="old_earning<%=iRow%>" value="<%=WI.getStrValue(strTemp,"0")%>">
								<%if(strPrepareToEdit.equals("1")){%>
								<input type="hidden" name="earning_index<%=iRow%>" value="<%=(String)vMiscEarnings.elementAt(l+3)%>">
								<%}%>
                  <input type="hidden" name="post_earning_index<%=iRow%>" value="<%=(String)vMiscEarnings.elementAt(l)%>">
                </tr>
                <%}// end for (; l < vMiscDeductions.size(); l+= ......%>
              </table>
              <%}// end if bolMoreDeduct%> </td>
          </tr>
        </table>
        </span> </td>
      <input type="hidden" name="earning_count" value="<%=iRow%>">
    </tr>
    <%}%>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="21%">Miscellaneous Earnings</td>
      <td width="15%"> <div align="right">
					<%if(iAccessLevel > 1){%>
          <%if(strPrepareToEdit.compareTo("0") != 0 && !bolIsReleased) {%>
          <a href='javascript:updateMiscEarnings("<%=WI.getStrValue((String)vDTRManual.elementAt(29),"0")%>");'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>
          <%}%>
					<%}%>
      </div></td>
      <td width="13%"><div align="right"><font size="1"><strong>
          <input name="misc_earning" type="text" size="10" maxlength="10" class="textbox_noborder"
		   value="<%=WI.getStrValue(Double.toString(dTotalEarnings),"0")%>" style="text-align : right" readonly>
      </strong></font> </div></td>
      <td width="49%" colspan="3"><font size="1"><strong>
        <input name="taxable_earning" type="hidden" value="<%=WI.getStrValue(Double.toString(dTaxableEarnings),"0")%>">
      </strong></font></td>
    </tr>
  </table>  
	<%} // end not UI
	}// end if ((!strPtFt.equals("0")...start 123456%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#99CCFF">
      <td height="18">&nbsp;</td>
      <td colspan="4"><strong><font color="#FF3300">:: DEDUCTIONS - GOVERNMENT
        MANDATED ::</font></strong></td>
    </tr>
	<%if ((!strPtFt.equals("0") && strSchCode.startsWith("CGH")) || !strSchCode.startsWith("CGH")){// start 12345%>
    <tr>
      <td width="2%" height="23">&nbsp;</td>
      <td width="21%">&nbsp;&nbsp;SSS</td>
    <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(12);
	else{
		if (vDTRDetails != null ){
			strTemp = (String)vDTRDetails.elementAt(13);
		}else{
			strTemp = "0";
		}
	   }
	%>
      <td><input name="sss_deduction" type="text" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" style="text-align : right"
	    onBlur="AllowOnlyFloat('form_','sss_deduction');UpdateToZero('sss_deduction');style.backgroundColor='white'" onKeyUp="AllowOnlyFloat('form_','sss_deduction');"
		value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="10"> </td>
      <td width="19%"> &nbsp;&nbsp;PAG-IBIG</td>
     <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(14);
			else{
				if (vDTRDetails != null)
					strTemp = (String)vDTRDetails.elementAt(16);
				else
					strTemp = WI.fillTextValue("pagibig_deduction");			
			 }
		 %>
      <td><input name="pagibig_deduction" type="text" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" style="text-align : right"
	    onBlur="AllowOnlyFloat('form_','pagibig_deduction');UpdateToZero('pagibig_deduction');style.backgroundColor='white'" 
		onKeyUp="AllowOnlyFloat('form_','pagibig_deduction');" value="<%=WI.getStrValue(strTemp,"0")%>" 
		size="10" maxlength="10"></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;&nbsp;Philhealth</td>
      <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(13);
	else{
		if (vDTRDetails != null ){
			strTemp = (String)vDTRDetails.elementAt(14);
		}else{
			strTemp = "0";
		}
	   }
	%>
      <td> <input name="philhealth_deduction" type="text" class="textbox" size="10" maxlength="10"
	    onFocus="style.backgroundColor='#D3EBFF'" style="text-align : right"
	    onBlur="AllowOnlyFloat('form_','philhealth_deduction');UpdateToZero('philhealth_deduction');style.backgroundColor='white'"
		onKeyUp="AllowOnlyFloat('form_','philhealth_deduction');" value="<%=WI.getStrValue(strTemp,"0")%>">
      </td>
      <td>&nbsp;&nbsp;
	  <%if(strSchCode.startsWith("CLDH")){%>
        PERAA
        <%}else if(strSchCode.startsWith("AUF")){%>
        Ret. Plan Premium
      <%}%>		
      </td>
      <%
	  if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(54);
	  else{
			if (vDTRDetails != null ){
				strTemp = (String)vDTRDetails.elementAt(42);
			}else{
				strTemp = "0";
			}
	  }
			strTemp = CommonUtil.formatFloat(strTemp,true);
			strTemp = ConversionTable.replaceString(strTemp,",","");
	  %>
      <td> <%if(strSchCode.startsWith("CLDH") || strSchCode.startsWith("AUF")){%> 
	    <input name="peraa" type="text" class="textbox"	 style="text-align : right"
	    onBlur="AllowOnlyFloat('form_','peraa');UpdateToZero('peraa');style.backgroundColor='white'" 
		onKeyUp="AllowOnlyFloat('form_','peraa');"
		value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="10"> 
		<%}%></td>
    </tr>
	<%}// end if 12345 (!strPtFt.equals("0")) %>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;&nbsp;Tax</td>
      <%
			strTemp = "";
		if(strTemp.length() == 0 || strTemp.equals("0")){
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(24);			
		}
	  %>
      <td><input name="tax_deduction" type="text" class="textbox" size="10" maxlength="10"
	    onFocus="style.backgroundColor='#D3EBFF'" style="text-align : right"
	    onBlur="AllowOnlyFloat('form_','tax_deduction');UpdateToZero('tax_deduction');style.backgroundColor='white'"
		onKeyUp="AllowOnlyFloat('form_','tax_deduction');" value="<%=WI.getStrValue(strTemp,"0")%>">
				<%if(strPrepareToEdit.compareTo("0") != 0) {%>
        <input type="button" name="compute" value="Compute" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(6,'','');">				
				<%}%>
      </td>
      <td>
      <%if(!strSchCode.startsWith("UI")){%>
	    <%if ((!strPtFt.equals("0") && strSchCode.startsWith("CGH")) || !strSchCode.startsWith("CGH")){// start 12345%>
	  		&nbsp;&nbsp;GSIS 
	    <%}// not CGH%>
	  <%}// starts with UI%>
	  </td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(61);
		else{
			if (vDTRDetails != null ){
				strTemp = (String)vDTRDetails.elementAt(56);
			}else{
				strTemp = "0";
			}
		}		 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		%>		
      <td>
	    <%if(!strSchCode.startsWith("UI")){%>
	    <%if ((!strPtFt.equals("0") && strSchCode.startsWith("CGH")) || !strSchCode.startsWith("CGH")){// start 12345%>
		<input name="gsis_deduction" type="text" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" style="text-align : right"
	    onBlur="AllowOnlyFloat('form_','gsis_deduction');UpdateToZero('gsis_deduction');style.backgroundColor='white'" onKeyUp="AllowOnlyFloat('form_','sss_deduction');"
		value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="10">
		<%}%>
		<%}// starts with UI%>
	  </td>
    </tr>
      <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){
			strTaxStatus = (String)vDTRDetails.elementAt(36);// tax status
			strTemp = (String)vDTRDetails.elementAt(38); // amount exemption
			strTemp2 = (String)vDTRDetails.elementAt(37); // dependents				
			if(strTaxStatus.length() == 2){
				strTemp2 = strTaxStatus.substring(1,2);
				strTaxStatus = strTaxStatus.substring(0,1);
			}
			iTaxStatus  = Integer.parseInt(WI.getStrValue(strTaxStatus,"0"));
		}
 		%>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;&nbsp;Tax Status</td>
      <td colspan="3"><strong><%=astrTaxStatus[iTaxStatus]%></strong> 
				<%if (iTaxStatus > 1){%>
        with <strong><%=strTemp2%></strong> eligible dependent(s).
        <%}%>
        (<%=WI.getStrValue(strTemp,"0")%> tax exemption)
		  </td>
    </tr>
		<%if ((!strPtFt.equals("0") && strSchCode.startsWith("CGH")) || !strSchCode.startsWith("CGH")){// start 12345%>
    <tr>
      <td height="23">&nbsp;</td>
      <td colspan="4">			<div onClick="showBranch('branch13');swapFolder('folder13')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder13">
          <b><font color="#0000FF">Other contribution details</font></b></div>
        <span class="branch" id="branch13">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr>
            <td width="26%">&nbsp;SSS Employer Share </td>	
						<%
						// sss_es
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(70);
						else{
							if (vDTRDetails != null)
								strTemp = (String)vDTRDetails.elementAt(52);
							else
								strTemp = "0";
					  }
						%>						
            <td width="25%">
              <strong><font size="1">
              <input name="sss_employer_ss" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','sss_employer_ss');" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','sss_employer_ss');UpdateToZero('sss_employer_ss');
			  style.backgroundColor='white';">
            </font></strong></td>
						<td width="21%">&nbsp;SSS  EC </td>
						<%
						// sss ec
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(71);
						else{
							if (vDTRDetails != null)
								strTemp = (String)vDTRDetails.elementAt(53);
							else
								strTemp = "0";
					  }
						%>								
						<td width="28%">
						  <strong><font size="1">
						  <input name="sss_employer_ec" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','sss_employer_ec');" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','sss_employer_ec');UpdateToZero('sss_employer_ec');
			  style.backgroundColor='white';">
					  </font></strong></td>
          </tr>
          <tr>
            <td>&nbsp;Philhealth Employer Share </td>
						<%
						// phealth es
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(72);
						else{
							if (vDTRDetails != null ){
								strTemp = (String)vDTRDetails.elementAt(54);
							}else{
								strTemp = "0";
							}
					  }
						%>									
              <td><strong><font size="1">
              <input name="phic_employer_es" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','phic_employer_es');" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','phic_employer_es');UpdateToZero('phic_employer_es');
			  style.backgroundColor='white';">
            </font></strong></td>
						<%
						// phealth bracket
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(73);
						else{
							if (vDTRDetails != null )
								strTemp = (String)vDTRDetails.elementAt(55);							
					  }
						strTemp = WI.getStrValue(strTemp,"0");
 						%>
						<td>&nbsp;Philhealth bracket </td>
						<td><select name="phic_sal_bracket">
                <option value="0">Select bracket</option>
								<%for(int i = 1; i < 28; i++){%>
								<%if(Integer.parseInt(strTemp) == i){%>
								<option value="<%=i%>" selected><%=i%></option>
								<%} else {%>
								<option value="<%=i%>"><%=i%></option>
								<%} // end if
								}// end for%>
              </select></td>
          </tr>
          <tr>
            <td>&nbsp;GSIS Employer Share </td>
						<%
							// gsis gs
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(75);
						else{
							if (vDTRDetails != null ){
							strTemp = (String)vDTRDetails.elementAt(57);
							}else{
							strTemp = "0";
							}
						}
						%>
            <td><strong><font size="1">
              <input name="gsis_govt_share" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','gsis_govt_share');" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','gsis_govt_share');UpdateToZero('gsis_govt_share');
			  style.backgroundColor='white';">
            </font></strong></td>
            <td>&nbsp;GSIS EC </td>
						<%
						// gsis ec
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(76);
						else{
							if (vDTRDetails != null ){
								strTemp = (String)vDTRDetails.elementAt(58);
							}else{
								strTemp = "0";
							}
						}
						%>		
            <td><strong><font size="1">
              <input name="gsis_ec" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','gsis_ec');" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','gsis_ec');UpdateToZero('gsis_ec');
			  style.backgroundColor='white';">
            </font></strong></td>
          </tr>
        </table>
        </span> </td>
    </tr>		
    <tr bgcolor="#99CCFF">
      <td height="18">&nbsp;</td>
      <td colspan="4"><strong><font color="#FF3300">:: DEDUCTIONS - LEAVES/ABSENCES
        W/OUT PAY; LATES / UNDERTIME ::</font></strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>Late &amp; Undertime</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(33);
	  	else{
				if (vDTRDetails != null ){
					strTemp = (String)vDTRDetails.elementAt(25);
				}else{
					strTemp = WI.fillTextValue("hours_UT_late");
				}
	   	}

		if(strSchCode.startsWith("VMUF")){
			strReadOnly = "readonly";
		}else{
			strReadOnly = "";
		}
	  %>
      <td> <input name="hours_UT_late" type="text" size="10" maxlength="10" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
		  onKeyUp="AllowOnlyFloat('form_','hours_UT_late');" style="text-align : right"
		  onBlur="AllowOnlyFloat('form_','hours_UT_late');UpdateToZero('hours_UT_late');style.backgroundColor='white'"
		  <%=strReadOnly%>>
      <a href="javascript:viewLateDetails('<%=WI.fillTextValue("emp_id")%>','<%=WI.fillTextValue("year_of")%>', '<%=strDateFrom%>', '<%=strDateTo%>');">Late</a>&nbsp;&nbsp;
			<a href="javascript:ViewUTDetails('<%=strEmployeeIndex%>','<%=WI.fillTextValue("emp_id")%>', '<%=strDateFrom%>', '<%=strDateTo%>')">undertime</a></td>
      <td>Additional Deductions</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(18);
		else
	//		strTemp = WI.fillTextValue("addl_deduction");
			strTemp = "0";
	  %>
      <td><input name="addl_deduction" type="text" size="10" maxlength="10" class="textbox"
	    onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	    onKeyUp="AllowOnlyFloat('form_','addl_deduction');" style="text-align : right"
	    onBlur="AllowOnlyFloat('form_','addl_deduction');UpdateToZero('addl_deduction');style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>Leave Deduction Amount</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
		else{
			if (vDTRDetails != null ){
				strTemp = (String)vDTRDetails.elementAt(11);
			}else{
				strTemp = "0";
			}
		}

		if(strSchCode.startsWith("VMUF")){
			strReadOnly = "readonly";
		}else{
			strReadOnly = "";
		}
	%>
      <td> <input name="leave_deductions" type="text" class="textbox" size="10" maxlength="10"
	    onFocus="style.backgroundColor='#D3EBFF'" <%=strReadOnly%> style="text-align : right"
	    onBlur="AllowOnlyFloat('form_','leave_deductions');UpdateToZero('leave_deductions');style.backgroundColor='white';"
		onKeyUp="AllowOnlyFloat('form_','leave_deductions');" value="<%=WI.getStrValue(strTemp,"0")%>">
      </td>
      <td>Description</td>
      <%
		strTemp = null;
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(19);
		} else{
	//		strTemp = WI.fillTextValue("addl_deduction_desc");
			strTemp = null;
		}
  	  %>
      <td><input name="addl_deduction_desc" type="text" class="textbox" value="<%=WI.getStrValue(strTemp,"")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>Absences w/out Leave</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(32);
		else{
			if (vDTRDetails != null ){
				strTemp = (String)vDTRDetails.elementAt(24);
			}else{
				strTemp = "0";
			}
		}

		if(strSchCode.startsWith("VMUF"))
			strReadOnly = "readonly";
		else
			strReadOnly = "";
	  %>
      <td><strong>
        <input name="awol_amt" type="text" class="textbox" size="10" maxlength="10"
		onFocus="style.backgroundColor='#D3EBFF'" style="text-align : right"
	    onBlur="AllowOnlyFloat('form_','awol_amt');UpdateToZero('awol_amt');style.backgroundColor='white'"
		onKeyUp="AllowOnlyFloat('form_','awol_amt');" value="<%=WI.getStrValue(strTemp,"0")%>" <%=strReadOnly%>>
        </strong> </td>
      <td>Non - dtr<%if(bolIsSchool){%>/ Faculty<%}%> Absences</td>
      <%
		if (vDTRDetails != null ){
//			if (!strSchCode.startsWith("VMUF")){
//				dFacAbsentAmt = ((Double)vDTRDetails.elementAt(35)).doubleValue() * dTeachingRate/3;
//			dFacAbsentAmt = 27 * dTeachingRate/3;
//			System.out.println(dTeachingRate);
//			System.out.println(dFacAbsentAmt);
//			}else{
				dFacAbsentAmt = ((Double)vDTRDetails.elementAt(35)).doubleValue();
//			}
		}else{
			dFacAbsentAmt = 0;
		}
	%>
      <td><strong><%=WI.getStrValue(CommonUtil.formatFloat(dFacAbsentAmt,true),"0")%></strong> <input type="hidden" name="faculty_absence" value="<%=WI.getStrValue(CommonUtil.formatFloat(dFacAbsentAmt,true),"0")%>">
      </td>
    </tr>
    <%if(vUnworkedDays != null && vUnworkedDays.size() > 0){
				dDaysAwol = (vUnworkedDays.size()-1)/2;
				dHoursAwol = Double.parseDouble((String)vUnworkedDays.elementAt(0));
		%>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;</td>
      <td> 
				<%if(vUnworkedDays != null && vUnworkedDays.size() > 1){%>
				<div onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
          <b><font color="#0000FF">View days without dtr entry </font></b> </div>
        <span class="branch" id="branch1">
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
          <%for (int i = 1;i<vUnworkedDays.size();i+=2){%>
          <tr>
            <td width="20%" height="15"><div align="left">&nbsp;&nbsp;<font size="1"><%=(Date)vUnworkedDays.elementAt(i)%> </font></div></td>
          </tr>
          <%}%>
        </table>
        </span>
				<%}%>
			</td>
      <td colspan="2">&nbsp;</td>
    </tr>
	<%}%>
		<input type="hidden" name="days_awol" value="<%=dDaysAwol%>">
		<input type="hidden" name="hours_awol" value="<%=dHoursAwol%>">
    <%}// end 4321 if (!strPtFt.equals("0"))%>
  </table>  
  <%if ((!strPtFt.equals("0") && strSchCode.startsWith("CGH")) || !strSchCode.startsWith("CGH")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#99CCFF">
      <td width="2%" height="18">&nbsp;</td>
      <td colspan="6"><strong><font color="#FF3300">:: DEDUCTIONS - LOANS ::</font></strong></td>
    </tr>
    <%if(vLoans != null && vLoans.size() > 1){%>
    <tr>
      <td height="25" colspan="7"><div onClick="showBranch('branch2');swapFolder('folder2')"><img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2">
          <b><font color="#0000FF">View Loans</font></b></div>
        <span class="branch" id="branch2">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="2%">&nbsp;</td>
            <td width="35%"><div align="center"><font size="1"><strong>&nbsp;LOAN
                CODE - NAME</strong></font></div></td>
            <td width="21%"><div align="center"><font size="1"><strong>PAYABLE
                PRINCIPAL</strong></font></div></td>
            <td width="21%"><div align="center"><font size="1"><strong>PAYABLE
                INTEREST </strong></font></div></td>
            <td width="21%"><div align="center"><font size="1"><strong>TOTAL PAYABLE</strong></font></div></td>
          </tr>
			<%iRow = 0;					
				for (l = 1; l < vLoans.size(); l+=9,iRow++){
			%>
          <tr>
            <td>&nbsp;</td>
				<%
					if(((String)vLoans.elementAt(l+6)).equals("0"))
						strTemp = " - Retirement";
					else if(((String)vLoans.elementAt(l+6)).equals("1"))
						strTemp = " - Emergency";
					else
						strTemp = "";
				%>
				<input type="hidden" name="oth_ded_index<%=iRow%>" value="<%=(String)vLoans.elementAt(l)%>">
				<input type="hidden" name="schedule_index_<%=iRow%>" value="<%=(String)vLoans.elementAt(l+8)%>">
            <td height="18"><font size="1">&nbsp;<%=WI.getStrValue((String)vLoans.elementAt(l+5))%></font></td>
            <%
							strTemp = (String)vLoans.elementAt(l+2);
						%>
            <td><div align="center"><font size="1">&nbsp;<strong>
              <input name="principal_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','principal_amt<%=iRow%>');ComputeLoanPayable('<%=iRow%>')" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','principal_amt<%=iRow%>');UpdateToZero('principal_amt<%=iRow%>');
			  ComputeLoanPayable('<%=iRow%>');style.backgroundColor='white'">
                <%if (strPrepareToEdit.equals("1")){%>
									<input type="hidden" name="old_principal<%=iRow%>" value="<%=WI.getStrValue(strTemp,"0")%>">
								<%}%>
                <input type="hidden" name="loan_index<%=iRow%>" value="<%=(String)vLoans.elementAt(l+7)%>">								
                &nbsp; </strong></font></div></td>
            <%
							strTemp = (String)vLoans.elementAt(l+3);
						%>
            <td><div align="center"><font size="1"><strong>
                <input name="interest_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','interest_amt<%=iRow%>');ComputeLoanPayable('<%=iRow%>')" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','interest_amt<%=iRow%>');UpdateToZero('interest_amt<%=iRow%>');
			  ComputeLoanPayable('<%=iRow%>');style.backgroundColor='white'">
                <input type="hidden" name="old_interest<%=iRow%>" value="<%=WI.getStrValue(strTemp,"0")%>">
                &nbsp; </strong></font></div></td>
            <%
				strTemp = (String)vLoans.elementAt(l+1);
			%>
            <td><div align="center"><font size="1"><strong>
                <input name="period_pay<%=iRow%>" type="text" size="10" maxlength="10" class="textbox_noborder"
			  value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
                &nbsp; </strong></font> </div></td>
          </tr>
          <%}%>
          <input type="hidden" name="loan_count" value="<%=iRow%>">
        </table>
        </span> </td>
    </tr>
	<%}// end if vLoans != null%>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="23%">Loans and Advances</td>
      <%
		strTemp = "0";
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(39);
	else{
		if (vDTRDetails != null ){
			strTemp = (String) vDTRDetails.elementAt(12);
		}else{
			strTemp = "0";
		}
	}
		//System.out.println("strTemp " + (String) vDTRDetails.elementAt(12));
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dLoansAdvMisc += Double.parseDouble(strTemp);
	%>
      <td width="14%">
					<%if(iAccessLevel > 1){%>
					<div align="right">
          <%if(strPrepareToEdit.compareTo("0") != 0 && !bolIsReleased) {%>
          <a href='javascript:updateLoans("<%=WI.getStrValue((String)vDTRManual.elementAt(29),"0")%>");'>
          <img src="../../../images/update.gif" width="60" height="26" border="0"></a>
          <%}%></div>
					<%}%>
					</td>
      <td width="13%" align="right"> <font size="1"><strong>
        <input name="loans_adv_deduction" type="text" size="10" maxlength="10" class="textbox_noborder"
		   value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
      </strong></font> </td>
      <td colspan="3">
      <!--
			<strong><a href="javascript:ViewLoansAndOtherDetail();"><img src="../../../images/view.gif" border="0"></a><font size="1">View
					loans and advances detail</font></strong>
			-->
      </td>
    </tr>
    <tr bgcolor="#99CCFF">
      <td height="18">&nbsp;</td>
      <td colspan="6"><strong><font color="#FF3300">:: DEDUCTIONS - MISCELLANEOUS
        ::</font></strong></td>
    </tr>
    <%if(vMiscDeductions != null && vMiscDeductions.size() > 1){
	%>
    <tr>
      <td height="32" colspan="7"><div onClick="showBranch('branch3');swapFolder('folder3')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3">
          <b><font color="#0000FF">View Miscellaneous Deductions</font></b></div>
        <span class="branch" id="branch3">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="2%">&nbsp;</td>
            <td width="49%"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td width="25%"><div align="center"><font size="1"><strong>&nbsp;CHARGES
                      NAME </strong></font></div></td>
                  <td width="25%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
                </tr>
                <% iRow = 0;
				bolMoreDeduct = false;
				for (l = 1; l < vMiscDeductions.size(); l+=4,iCount++,iRow++){
					if(iCount == 5){
						bolMoreDeduct = true;
						break;
					}
				%>
                <tr>
                  <td height="18">&nbsp;<%=(String)vMiscDeductions.elementAt(l+1)%></td>
                  <%
				  strTemp = (String)vMiscDeductions.elementAt(l+2);
				  strTemp = ConversionTable.replaceString(strTemp,",","");
				  %>
                  <td><div align="center">&nbsp;<strong><font size="1">
                      <input name="misc_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
				  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
				  onKeyUp="AllowOnlyFloat('form_','misc_amt<%=iRow%>');ComputeMiscPayable('<%=iRow%>');" style="text-align : right"
				  onBlur="AllowOnlyFloat('form_','misc_amt<%=iRow%>');UpdateToZero('misc_amt<%=iRow%>');
				  ComputeMiscPayable('<%=iRow%>');style.backgroundColor='white'">
                      &nbsp; </font></strong></div></td>
                  <input type="hidden" name="old_misc<%=iRow%>" value="<%=WI.getStrValue(strTemp,"0")%>">
				 <%if(strPrepareToEdit.equals("1")){%>
				  <input type="hidden" name="misc_ded_index<%=iRow%>" value="<%=(String)vMiscDeductions.elementAt(l+3)%>">
				  <%}%>
                  <input type="hidden" name="post_deduct_index<%=iRow%>" value="<%=(String)vMiscDeductions.elementAt(l)%>">

                </tr>
                <%}%>
              </table></td>
            <td width="49%" valign="	"> <%if(bolMoreDeduct){%> <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td width="25%"><div align="center"><font size="1"><strong>&nbsp;CHARGES
                      NAME </strong></font></div></td>
                  <td width="25%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
                </tr>
                <%for (; l < vMiscDeductions.size(); l+=4,iCount++,iRow++){%>
                <tr>
                  <td height="18">&nbsp;<%=(String)vMiscDeductions.elementAt(l+1)%></td>
                  <%
				  strTemp = (String)vMiscDeductions.elementAt(l+2);
				  strTemp = ConversionTable.replaceString(strTemp,",","");
				  %>
                  <td><div align="center">&nbsp;<strong><font size="1">
                      <input name="misc_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','misc_amt<%=iRow%>');ComputeMiscPayable('<%=iRow%>');" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','misc_amt<%=iRow%>');UpdateToZero('misc_amt<%=iRow%>');
			  ComputeMiscPayable('<%=iRow%>');style.backgroundColor='white'">
                      &nbsp; </font></strong></div></td>
                  <input type="hidden" name="old_misc<%=iRow%>" value="<%=WI.getStrValue(strTemp,"0")%>">
				  <%if(strPrepareToEdit.equals("1")){%>
				  <input type="hidden" name="misc_ded_index<%=iRow%>" value="<%=(String)vMiscDeductions.elementAt(l+3)%>">
				  <%}%>
                  <input type="hidden" name="post_deduct_index<%=iRow%>" value="<%=(String)vMiscDeductions.elementAt(l)%>">
                </tr>
                <%}// end for (; l < vMiscDeductions.size(); l+= ......%>
              </table>
              <%}// end if bolMoreDeduct%> </td>
          </tr>
        </table>
      </span> </td>
      <input type="hidden" name="misc_count" value="<%=iRow%>">
    </tr>
    <%}%>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Miscellaneous Deductions</td>
      <%
	  	strTemp = "0";
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(40);
		}else{
			if (vDTRDetails != null ){
				strTemp = (String)vDTRDetails.elementAt(15);
			}else{
				strTemp = "0";
			}
		}

		if (strTemp != null) {
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dLoansAdvMisc += Double.parseDouble(strTemp);
		}else{
			strTemp = "0";
		}
	   %>
      <td align="right"> 
        <%if(iAccessLevel > 1){%>
				<%if(strPrepareToEdit.compareTo("0") != 0 && !bolIsReleased) {%>
        <a href='javascript:updateMiscellaneous("<%=WI.getStrValue((String)vDTRManual.elementAt(29),"0")%>");'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>
        <%}else{%>
        <a href='javascript:encodeMiscellaneous("<%=strDateFrom%>","<%=strDateTo%>");'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>        
				<%}%>			
				<%}%>
				</td>
      <td align="right"><font size="1"><strong>
        <input name="misc_deduction" type="text" size="10" maxlength="10" class="textbox_noborder"
		   value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
      </strong></font> </td>
      <td colspan="3">
        <!--
	  <strong><a href="javascript:ViewOtherDeductionDetail();"><img src="../../../images/view.gif" border="0"></a><font size="1">View
        other deductions detail</font></strong>
	  -->
      </td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Earning Deductions</td>
      <td align="right"> 
        <%if(strPrepareToEdit.compareTo("0") != 0 && !bolIsReleased) {%>
        <a href='javascript:updateEarnDed("<%=WI.getStrValue((String)vDTRManual.elementAt(29),"0")%>");'>
        <img src="../../../images/update.gif" width="60" height="26" border="0"></a>
        <%}%>      </td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(56);
		}else{
		  if (vDTRDetails != null ){
			strTemp = (String) vDTRDetails.elementAt(44);
		  }else{
			strTemp = "0";
		  }
		}
	  %>
      <td align="right"><%=WI.getStrValue(strTemp,"0")%><input type="hidden" name="earn_deduct" value="<%=WI.getStrValue(strTemp,"0")%>">      </td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <%if (strSchCode.startsWith("VMUF")){%>
    <tr>
      <td height="22">&nbsp;</td>
      <td>Board &amp; Lodging</td>
      <td>&nbsp;</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(53);
		else{
			strTemp = WI.fillTextValue("board_lodging");
		}
	  %>
      <td><div align="right"><strong><font size="1">
          <input name="board_lodging" type="text" size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	  onKeyUp="AllowOnlyFloat('form_','board_lodging');"
	  onBlur="AllowOnlyFloat('form_','board_lodging');UpdateToZero('board_lodging');style.backgroundColor='white'">
          </font></strong></div></td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <%}%>
    <tr bgcolor="#99CCFF">
      <td height="18">&nbsp;</td>
      <td height="18" colspan="6"><strong><font color="#FF3300">:: DEDUCTIONS
        - OTHER CONTRIBUTIONS ::</font></strong></td>
    </tr>
    <%if(vOtherCons != null && vOtherCons.size() > 1){%>
    <tr>
      <td height="25" colspan="7"><div onClick="showBranch('branch4');swapFolder('folder4')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4">
          <b><font color="#0000FF">View Other Contributions</font></b></div>
        <span class="branch" id="branch4">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td>&nbsp;</td>
            <td><div align="center"><font size="1"><strong>&nbsp;CONTRIBUTION
                NAME </strong></font></div></td>
            <td><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
            <td>&nbsp;</td>
          </tr>
          <%iRow = 0;
		  for(l = 1;l < vOtherCons.size();l+=5,iRow++){%>
          <tr>
            <td width="2%">&nbsp;</td>
            <td width="35%">&nbsp;<%=(String)vOtherCons.elementAt(l+4)%> </td>
            <%
			  strTemp = (String)vOtherCons.elementAt(l);
			  strTemp = ConversionTable.replaceString(strTemp,",","");
			%>
            <td width="17%"><div align="center"><strong><font size="1">
                <input name="other_cont_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','other_cont_amt<%=iRow%>');ComputeContPayable('<%=iRow%>')" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','other_cont_amt<%=iRow%>');UpdateToZero('other_cont_amt<%=iRow%>');
			  ComputeContPayable('<%=iRow%>');style.backgroundColor='white'">
                </font></strong></div></td>
		    <%if(strPrepareToEdit.equals("1")){%>
			   <input type="hidden" name="cont_ded_index<%=iRow%>" value="<%=(String)vOtherCons.elementAt(l+3)%>">
			<%}%>
            <input type="hidden" name="cont_index<%=iRow%>" value="<%=(String)vOtherCons.elementAt(l+3)%>">
            <td width="46%">&nbsp;</td>
          </tr>
          <%}%>
        </table>
        </span></td>
      <input type="hidden" name="cont_count" value="<%=iRow%>">
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Other Contributions</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0){
			vOtherCons = (Vector) vEditInfo.elementAt(42);
			if (vOtherCons != null && vOtherCons.size() > 0 ){
				strTemp = ((Double) vOtherCons.elementAt(0)).toString();
			}else {
					strTemp = "0";
			}
		}else{
		  if (vDTRDetails != null ){
			strTemp = (String) vDTRDetails.elementAt(30);
		  }else{
			strTemp = "0";
		  }
		}

		if (strTemp != null) {
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dLoansAdvMisc += Double.parseDouble(strTemp);
		}
	  %>
      <td> <div align="right">
          <%if(strPrepareToEdit.compareTo("0") != 0 && !bolIsReleased) {%>
          <a href='javascript:updateContributions("<%=WI.getStrValue((String)vDTRManual.elementAt(29),"0")%>");'>
          <img src="../../../images/update.gif" width="60" height="26" border="0">
          </a>
          <%}%>
        </div></td>
      <td align="right"><font size="1"><strong>
        <input name="other_contribution" type="text" size="10" maxlength="10" class="textbox_noborder"
		   value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
      </strong></font> </td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Loans, Misc &amp; Other Contribution</td>
      <%			
	  	//strTemp = WI.fillTextValue("loans_misc_ded");
			strTemp = CommonUtil.formatFloat(dLoansAdvMisc,true);
		  %>
      <td><div align="right"><strong>
          <input name="loans_misc_ded" type="text" value="<%=WI.getStrValue(strTemp,"0")%>"
		size="12" maxlength="12"  class="textbox_noborder" style="text-align: right" readonly>
          </strong></div></td>
      <td width="48%" colspan="3">&nbsp;</td>
    </tr>
  </table>  
  <%}// end if (!strPtFt.equals("0"))%>    
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
	if(vEditInfo != null && vEditInfo.size() > 0) {
		strTemp = (String)vEditInfo.elementAt(34);
		}
	else{
		strTemp = WI.fillTextValue("gross_salary");
		}
	%>
    <input type="hidden" name="gross_salary" value="<%=WI.getStrValue(strTemp,"0")%>" >
    <%
	if(vEditInfo != null && vEditInfo.size() > 0) {
		strTemp = (String)vEditInfo.elementAt(35);
		}
	else{
		strTemp = WI.fillTextValue("taxable_income");
		}
	%>
    <input type="hidden" name="taxable_income" value="<%=WI.getStrValue(strTemp,"0")%>" >
    <tr bgcolor="#99CCFF">
      <td height="23">&nbsp;</td>
      <td colspan="6"><strong><font color="#FF3300">ADDITIONAL / ADJUSTMENTS</font></strong></td>
    </tr>
    <tr>
      <td width="2%" height="23">&nbsp;</td>
    <%
			strTemp = "0";
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(20);
				
				if(((String)vEditInfo.elementAt(77)).equals("1"))
					strReadOnly = "readonly";
				else
					strReadOnly = "";				
			}else{
				if (vDTRDetails != null && vDTRDetails.size() > 0){
					strTemp = (String)vDTRDetails.elementAt(64);

					if(((String)vDTRDetails.elementAt(75)).equals("1"))
						strReadOnly = "readonly";
					else
						strReadOnly = "";
				}else{
					strTemp = "0";
				}
			}
			strTemp2 = ConversionTable.replaceString(strTemp,"-","");
		%>
      <td width="20%">Adjustments</td>
      <td colspan="2"><input name="adjustment_amt" type="text" size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp2,"0")%>"
	  onKeyUp="AllowOnlyFloat('form_','adjustment_amt');" style="text-align : right" <%=strReadOnly%>
	  onBlur="AllowOnlyFloat('form_','adjustment_amt'); UpdateToZero('adjustment_amt');style.backgroundColor='white'">
        <%if(strReadOnly.length() == 0){%>
				<select name="adjustment_type">
          <option value="0">credit</option>
					<%if(Double.parseDouble(strTemp) < 0){%>
	          <option value="1" selected>debit</option>
					<%} else {%>
						<option value="1">debit</option>
					<%}%>
        </select> 
				<%}else{%>
					<%if(Double.parseDouble(strTemp) < 0){%>
						debit
						<input type="hidden" name="adjustment_type" value="1">
					<%}else{%>
						credit
						<input type="hidden" name="adjustment_type" value="0">
					<%}%>
				<%}%>
			</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0) {
			strTemp = (String)vEditInfo.elementAt(36);
			}
		else{
			strTemp = WI.fillTextValue("total_deduction");
			}
		%>
      <td width="34%" colspan="3"><input type="hidden" name="total_deduction" value="<%=WI.getStrValue(strTemp,"0")%>"></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <%
			 strTemp = null;
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(21);
			else
		//		strTemp = WI.fillTextValue("adjustment_desc");
				strTemp = null;
			%>
      <td>Description</td>
      <td colspan="5">
			<input name="adjustment_desc" type="text" class="textbox" value="<%=WI.getStrValue(strTemp,"")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(37);
			else{
				if (vDTRDetails != null && vDTRDetails.size() > 0)
					strTemp = (String)vDTRDetails.elementAt(74);
				else
					strTemp = "0";				
			}
			%>
      <td>Taxable Adjustment</td>
      <td colspan="5"><input name="taxable_adjust" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="AllowOnlyFloat('form_','taxable_adjust'); UpdateToZero('taxable_adjust');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','taxable_adjust');" style="text-align : right"
	  value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="10"> </td>
    </tr>
    <tr >
      <td height="18" colspan="7">&nbsp;</td>
    </tr>
  </table>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <%
	 strTemp = null;
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(9);
	%>
      <td width="20%">Payable Salary</td>
      <td width="78%" colspan="5"><strong><%=WI.getStrValue(strTemp,"0")%></strong> <input type="hidden" name="payable_salary" value="<%=WI.getStrValue(strTemp,"0")%>">
      </td>
    </tr>
    <tr>
      <td height="17" colspan="7"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<%if(strPrepareToEdit.compareTo("1") == 0) {%>
			<%if(!bolIsReleased){%>
    <tr>
      <td height="14"  colspan="3" align="center" valign="bottom" bgcolor="#FFFFFF">
			<%if(iAccessLevel == 2){%>
			<font size="1">
        <input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:Recompute('<%=WI.getStrValue((String)vDTRManual.elementAt(28),"0")%>');">
      click to delete saved payroll </font>
			<%}%>
			</td>
    </tr>
			<%}%>
		<%}%>
    <tr>
      <td height="46"  colspan="3" valign="bottom" bgcolor="#FFFFFF"><div align="center">
      <%if(iAccessLevel > 1) {%>			
			<%if(!bolIsReleased){%>
				<input name="bypass_floor" type="checkbox" value="1"> Ignore Floor Salary Setting for Employee<br>
			  <%if(strPrepareToEdit.compareTo("1") != 0) {%>
			  <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(1, '','');">
				<font size="1"> click to save entries</font>
			  <%}else{%>				
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(2,'<%=WI.getStrValue((String)vDTRManual.elementAt(28))%>','');">
				<font size="1"> to save changes</font>
			  <%}%>
			  <font size="1"> 
			  <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();">
			  click to cancel </font>
			  
			  <%}else{%>
				  Payslip already created
			    <%}%>
		      <%}else{%>
		  Not Allowed
		  <%}%>
          
			  <hr size="1" color="#0000FF">
        </div></td>
    </tr>
  </table>
 <%if(vDTRManual != null && vDTRManual.size() > 0) { %>
	<%if(!strSchCode.startsWith("UI")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="22" colspan="6" align="center" bgcolor="#B9B292" class="thinborder"><strong>DTR
      MANUAL ENTRY</strong></td>
    </tr>
    <tr class="thinborder">
      <td width="11%" class="thinborder"><div align="center"><font size="1">Hours
          Worked</font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1">Overtime
          (Hours)</font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1">Leave
          Days (w/ pay)</font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1">Leave
          Days (w/out pay)</font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1">Leave
          with Pay (Hours)</font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1">Leave
          w/out Pay (Hours)</font></div></td>
    </tr>
    <tr class="thinborder">
      <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vDTRManual.elementAt(2))%></div></td>
      <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vDTRManual.elementAt(7))%></div></td>
      <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vDTRManual.elementAt(5))%></div></td>
      <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vDTRManual.elementAt(6))%></div></td>
      <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vDTRManual.elementAt(3))%></div></td>
      <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vDTRManual.elementAt(4))%></div></td>
    </tr>
  </table>
  <%}//!strSchCode.startsWith("UI")%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="22" colspan="11" align="center" bgcolor="#B9B292" class="thinborder"><strong>EARNINGS</strong></td>
    </tr>
    <tr class="thinborder">
      <td width="4%" height="24" align="center" class="thinborder"><font size="1">Salary</font></td>
      <%if(!strSchCode.startsWith("UI")){%>
      <td width="4%" align="center" class="thinborder"><font size="1">Night
        Diff</font></td>
      <td width="4%" align="center" class="thinborder"><font size="1">Holiday
        Pay</font></td>
      <td width="4%" align="center" class="thinborder"><font size="1">OT
        Amount</font></td>
      <td width="4%" align="center" class="thinborder"><font size="1">Total
        Incentive</font></td>
      <%}//!strSchCode.startsWith("UI")%>
      <td width="4%" align="center" class="thinborder"><font size="1">COLA</font></td>
      <td width="4%" align="center" class="thinborder"><font size="1">Honorariums</font></td>
      <td width="4%" align="center" class="thinborder"><font size="1">Overload</font></td>
      <%if(!strSchCode.startsWith("UI")){%>
      <td width="4%" align="center" class="thinborder"><font size="1">Additional
        Resp</font></td>
      <td width="4%" align="center" class="thinborder"><font size="1">Additional
        Payment</font></td>
	  <%
	  	if (strSchCode.startsWith("CLDH"))
			strTemp = "Uniform";
		else
			strTemp = "Additional Bonus";
	  %>
      <td width="4%" align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>
      <%}//!strSchCode.startsWith("UI")%>
    </tr>
    <tr class="thinborder">
      <td height="22" align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(9))%></td>
      <%if(!strSchCode.startsWith("UI")){%>
      <td align="center" class="thinborder">
        <%=WI.getStrValue((String)vDTRManual.elementAt(25))%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(26))%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(10))%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(16))%></td>
      <%}//!strSchCode.startsWith("UI")%>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(31),"0")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(43),"0")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(67),"0")%></td>
      <%if(!strSchCode.startsWith("UI")){%>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(27))%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(17))%><%=WI.getStrValue((String)vDTRManual.elementAt(30)," - ","","")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(22))%><%=WI.getStrValue((String)vDTRManual.elementAt(23)," - ","","")%></td>
      <%}// !strSchCode.startsWith("UI")%>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr class="thinborder">
      <td height="22" colspan="7" align="center" bgcolor="#B9B292" class="thinborder"><strong>DEDUCTIONS</strong></td>
    </tr>
    <tr class="thinborder">
      <td width="18%" align="center" class="thinborder"><font size="1">Leave
        Deduction Amt</font></td>
      <td width="15%" align="center" class="thinborder"><font size="1">AWOL
        Deduction</font></td>
      <td width="17%" align="center" class="thinborder"><font size="1">Tardiness/Undertime</font></td>
      <td width="18%" align="center" class="thinborder"><font size="1">Loans
        / Misc</font></td>
      <td width="20%" align="center" class="thinborder"><font size="1">Earning Deductions</font></td>
      <td width="20%" align="center" class="thinborder"><font size="1">Addl
        Deduction</font></td>
      <td width="12%" align="center" class="thinborder"><font size="1">Tax</font></td>
    </tr>
    <tr>
      <td height="22" align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(11))%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(32))%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(33))%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(15))%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(56))%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(18))%><%=WI.getStrValue((String)vDTRManual.elementAt(19)," - ","","")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(24))%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr class="thinborder">
      <td height="22" colspan="7" align="center" bgcolor="#B9B292" class="thinborder"><strong>CONTRIBUTIONS</strong></td>
    </tr>
    <tr class="thinborder">
      <td width="15%" align="center" class="thinborder"><font size="1">SSS</font></td>
      <td width="12%" align="center" class="thinborder"><font size="1">Philhealth</font></td>
      <td width="14%" align="center" class="thinborder"><font size="1">PAG
        IBIG</font></td>
      <%if(bolIsSchool){%>
      <td width="15%" align="center" class="thinborder">PERAA</td>
      <%}%>
	    <td width="13%" align="center" class="thinborder"><font size="1">GSIS</font></td>
	    <td width="14%" align="center" class="thinborder"><font size="1">Adjustment
	      Amt</font></td>
	    <td width="17%" align="center" class="thinborder"><font size="1">Total
	      Deduction</font></td>
    </tr>
    <tr>
      <td height="22" align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(12))%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(13))%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(14))%></td>
      <%if(bolIsSchool){%>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(54))%></td>
      <%}%>
	    <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(61))%></td>
	    <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(20))%><%=WI.getStrValue((String)vDTRManual.elementAt(21)," - ","","")%></td>
	    <td align="center" class="thinborder"><%=WI.getStrValue((String)vDTRManual.elementAt(36))%></td>
    </tr>
  </table>
<%} // if vDTRManual is not null%>
<%}//show only if vPersonalDtls not null.%>
<%}//show only if vDTRDetails not null.%>

<table cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td height="20"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
</table>

  <input type="hidden" name="Ded_index" value="<%=WI.fillTextValue("Ded_index")%>">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="ResetFacultyPay">
  <input type="hidden" name="reset_page">
  <input type="hidden" name="old_id" value="<%=WI.fillTextValue("emp_id")%>">
	<input type="hidden" name="recompute">	
	<%
		if(vDTRManual != null && vDTRManual.size() > 0){
			strTemp = (String)vDTRManual.elementAt(29);
		}
	%>
	<input type="hidden" name="sal_index" value="<%=WI.getStrValue(strTemp,"0")%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
