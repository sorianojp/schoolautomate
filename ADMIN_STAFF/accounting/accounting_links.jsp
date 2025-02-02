<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Administrator links</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<link href="../../css/treelinkcss.css" rel="stylesheet" type="text/css">
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
//-->
</script>
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<style>
body {
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size:13px;
	color:#FFFFFF;
}
</style>
</head>
<body bgcolor="#C39E60" onLoad="MM_preloadImages('../../images/home_small_admin_rollover.gif','../../images/help_small_admin_rollover.gif','../../images/logout_admin_rollover.gif')">
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
<script language="JavaScript">
var openImg = new Image();
openImg.src = "../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../images/box_with_plus.gif";

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
</script>
<form action="../../commfile/logout.jsp" method="post" target="_parent">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="8%" height="19" bgcolor="#E9E0D1">&nbsp;</td>
      <td width="92%" bgcolor="#E9E0D1"> <a href="../main%20files/admin_staff_home_button_content.htm" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()" ><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
        <input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3">
        </a></td>
  </tr>
  </table>
<input type="hidden" name="logout_url" value="../ADMIN_STAFF/main%20files/admin_staff_bottom_content.htm">
<input type="hidden" name="body_color" value="#C39E60">
</form>
<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
//check if user is logged in, if logged, check authentication list here and allow the authentic user to access the system.
DBOperation dbOP = null;
CommonUtil comUtil = new CommonUtil();
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strErrMsg = null;
boolean bolGrantAll = false;
boolean isAuthorized = false;
if(strUserId != null)
{
	//open dbConnection here to check if user is registered already.
	try	{
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		strErrMsg = "error in opening connection.";
	}

	if(strErrMsg == null)
	{
		//check here the authentication of the user.
		if(comUtil.IsSuperUser(dbOP,strUserId))
			bolGrantAll = true;	//grant all ;-)
	}
}

Vector vAuthList = null;
if(!bolGrantAll && strErrMsg == null) {
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, "Accounting");
	if(vAuthList == null)
		vAuthList = new Vector();
	else if( ((String)vAuthList.elementAt(0)).compareTo("#ALL#") == 0)
		bolGrantAll = true;
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;


boolean bolShowTransPettyCash      = true;
boolean bolShowTransDisbursement   = true;
boolean bolShowTransGJV            = true;
boolean bolShowTransBudget         = true;
boolean bolShowTransAP             = true;
boolean bolShowTransSpecialJournal = true;
if(!bolGrantAll && strSchCode.startsWith("UB")) {
	if(vAuthList.indexOf("TRANSACTION - PETTY CASH") == -1) 
		bolShowTransPettyCash      = false;
	if(vAuthList.indexOf("TRANSACTION - DISBURSEMENT") == -1) 
		bolShowTransDisbursement   = false;
	if(vAuthList.indexOf("TRANSACTION - GENERAL JOURNAL") == -1) 
		bolShowTransGJV            = false;
	if(vAuthList.indexOf("TRANSACTION - BUDGET") == -1) 
		bolShowTransBudget         = false;
	if(vAuthList.indexOf("TRANSACTION - AP") == -1) 
		bolShowTransAP             = false;
	if(vAuthList.indexOf("TRANSACTION - SPECIAL JOURNAL") == -1) 
		bolShowTransSpecialJournal = false;	
}




if(bolGrantAll || vAuthList.indexOf("ADMINISTRATION") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" border="0" id="folder1">
  <strong>ADMINISTRATION</strong></div>

<span class="branch" id="branch1">  
	<img src="../../images/broken_lines.gif"> <a href="administration/setup_coa/coa_setup_main.jsp" target="accountingmainFrame">Setup COA </a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/setup_fiscal_year.jsp" target="accountingmainFrame">Setup Fiscal Year</a><br>
<%if(false){%>
	<img src="../../images/broken_lines.gif"> <a href="administration/transaction_type_create.jsp" target="accountingmainFrame">Transactions Tyspe</a><br>
<%}%>
	<img src="../../images/broken_lines.gif"> <a href="administration/chart_of_accounts/chart_of_account_main.jsp" target="accountingmainFrame">Chart of Accounts</a><br>
<%if(bolIsSchool){%>
	<img src="../../images/broken_lines.gif"> <a href="administration/map_coa_main.jsp" target="accountingmainFrame">Link Chart Of Accounts</a><br>
<%}%>
    <img src="../../images/broken_lines.gif"> <a href="administration/banks_create.jsp" target="accountingmainFrame">Link Bank</a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/setup_bs/page1.jsp" target="accountingmainFrame">Setup Balance Sheet</a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/setup_is/is_title.jsp" target="accountingmainFrame">Setup Income Statement</a><br>

<!--
    <img src="../../images/broken_lines.gif"> <a href="administration/set_accts_a_r_students.jsp" target="accountingmainFrame">Set Chart of Accounts<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;for A/R Students</a><br>
    <img src="../../images/broken_lines.gif"> <a href="administration/set_coa_mapping.jsp" target="accountingmainFrame">Set Other COA Mapping</a><br>
-->
    <img src="../../images/broken_lines.gif"> <a href="administration/chart_of_accounts/chart_of_account_search.jsp" target="accountingmainFrame">Search Chart of Account</a><br>
<%if(false){%>
    <img src="../../images/broken_lines.gif"> <a href="./administration/trial_balance/setup.jsp" target="accountingmainFrame">User defined Trial Balance</a><br>
    <img src="../../images/broken_lines.gif"> <a href="./administration/setup_for_taxes/main.jsp" target="accountingmainFrame">Setup for Taxes</a><br>
<%}%>
    <img src="../../images/broken_lines.gif"> <a href="./administration/chart_of_accounts/close_account/close_coa_ALL_pm.jsp" target="accountingmainFrame">Closing of Account (Monthly) </a><br>
    <img src="../../images/broken_lines.gif"> <a href="./administration/chart_of_accounts/close_account/exclude_balance_forward.jsp" target="accountingmainFrame">Exclude Account in Yearly Balance Forwarding</a><br>
    <img src="../../images/broken_lines.gif"> <a href="./administration/chart_of_accounts/setup_sundry.jsp" target="accountingmainFrame">Setup Sundry account</a><br>
<%if(!bolIsSchool || strSchCode.startsWith("AUF") || strSchCode.startsWith("DBTC")  || true){%>
    <img src="../../images/broken_lines.gif"> <a href="./administration/proj_mgmt/main.jsp" target="accountingmainFrame">Project Management</a><br>
<%}%>	
    <img src="../../images/broken_lines.gif"> <a href="./administration/ac_setting.jsp" target="accountingmainFrame">Other Setting</a><br>
<%if(strSchCode.startsWith("CIT") && false){%>
    <img src="../../images/broken_lines.gif"> <a href="./administration/restricted_user.jsp" target="accountingmainFrame">Restricted User</a><br>
<%}%>	
<%if(strSchCode.startsWith("TSUNEISHI")){%>
    <img src="../../images/broken_lines.gif"> <a href="./administration/restricted_user.jsp" target="accountingmainFrame">Manage Signatory</a><br>
<%}%>	
<!--	
	<img src="../../images/broken_lines.gif"> <a href="administration/banks_create.jsp" target="accountingmainFrame">Banks</a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/setup_balance_accounts.htm" target="accountingmainFrame">Setup Accounts Balance</a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/setup_charges_source.htm" target="accountingmainFrame">Set Accounts For Fund<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Charges</a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/setup_accounts_for_trial_balance.htm" target="accountingmainFrame">Set Accounts For <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Trial Balance</a><br>
<!--
	<img src="../../images/broken_lines.gif"> <a href="administration/link_accounts.htm" target="accountingmainFrame">Link Accounts</a><br>
-->
</span> 
<%}if(bolGrantAll || vAuthList.indexOf("TRANSACTION") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" border="0" id="folder3">
  <strong>TRANSACTION</strong></div>
<span class="branch" id="branch3">
	<%if(bolShowTransPettyCash){%> 
		<img src="../../images/broken_lines.gif"> <a href="transaction/petty_cash/petty_cash.jsp" target="accountingmainFrame">Petty Cash </a><br>
	<%}if(bolShowTransDisbursement){%> 
		<img src="../../images/broken_lines.gif"> <a href="transaction/cash_disbursement/cash_disbursement.jsp" target="accountingmainFrame">Disbursement Voucher </a><br>
	<%}if(bolShowTransGJV){%> 
		<img src="../../images/broken_lines.gif"> <a href="transaction/journal_voucher/journal_voucher.jsp" target="accountingmainFrame">General Journal </a><br>
	<%}%> 
	    <img src="../../images/broken_lines.gif"> <a href="administration/chart_of_accounts/chart_of_account_search.jsp" target="accountingmainFrame">Search Chart of Account</a><br>
<%if(bolGrantAll && strSchCode.startsWith("CIT")) {%>
    <img src="../../images/broken_lines.gif"> <a href="transaction/batch_lock_voucher.jsp" target="accountingmainFrame">Batch Lock Voucher</a><br>
    <img src="../../images/broken_lines.gif"> <a href="transaction/batch_lock_voucher.jsp?is_unlock=1" target="accountingmainFrame">Batch Un-Lock Voucher</a><br>
<%}%>
<%if(!strSchCode.startsWith("WNU") && !strSchCode.startsWith("CIT") && false){%>
	<img src="../../images/broken_lines.gif"> <a href="transaction/budget_entry/budget_encode.jsp" target="accountingmainFrame">Budget Entry </a><br>
<%}else if(!strSchCode.startsWith("CIT") && bolShowTransBudget){%>
<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder7">
	<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Budget</font></strong></div>
  	<span class="branch" id="branch7">
	<img src="../../images/broken_lines.gif"><a href="budget/budget_entry_super_user.jsp" target="accountingmainFrame"> Budget Entry Super User</a><br>
	<img src="../../images/broken_lines.gif"><a href="budget/budget_staff_positions.jsp" target="accountingmainFrame"> Manage Budget Levels</a><br>
	<img src="../../images/broken_lines.gif"><a href="budget/budget_employee_positions.jsp" target="accountingmainFrame"> Budget Level In-Charge</a><br>
	<img src="../../images/broken_lines.gif"><a href="budget/budget_periods.jsp" target="accountingmainFrame"> Budget Periods</a><br>
	<img src="../../images/broken_lines.gif"><a href="budget/budget_setup_main.jsp" target="accountingmainFrame"> Budget Setup</a><br>
	<img src="../../images/broken_lines.gif"><a href="budget/budget_entry.jsp" target="accountingmainFrame"> Budget Entry</a><br>
	<img src="../../images/broken_lines.gif"><a href="budget/budget_approve.jsp" target="accountingmainFrame"> Approve Budget</a><br>
	<img src="../../images/broken_lines.gif"><a href="budget/budget_flow.jsp" target="accountingmainFrame"> View Budget Flow</a><br>
	<img src="../../images/broken_lines.gif"><a href="budget/budget_reports.jsp" target="accountingmainFrame"> Reports</a><br>
</span>
<%}%>

<%if(false){%>
    <img src="../../images/broken_lines.gif"> <a href="transaction/apr/account_payable.jsp" target="accountingmainFrame">Account Payable </a><br>
    <img src="../../images/broken_lines.gif"> <a href="transaction/apr/account_receivable.jsp" target="accountingmainFrame">Account Receivable </a><br>
    <img src="../../images/broken_lines.gif"> <a href="transaction/apr/sl.jsp" target="accountingmainFrame">Subsidary Ledger</a><br>
<%}%>
<%if(true){%>
	<%if(bolShowTransAP){%>
		<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../images/box_with_plus.gif" border="0" id="folder6"> 
			<strong><font color="#FFFFFF" font size="2" face="Geneva, Arial, Helvetica, sans-serif">Accounts Payable</font></strong></div>
			<span class="branch" id="branch6"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
			<img src="../../images/broken_lines.gif"> <a href="./transaction/ap/manage_ap.jsp" target="accountingmainFrame">Manage Supplier/Non-supplier Data</a><br>
			<img src="../../images/broken_lines.gif"> <a href="./transaction/ap/ap_deliveries.jsp" target="accountingmainFrame">A/P Processing From Delivery</a> <br>
			<img src="../../images/broken_lines.gif"> <a href="./transaction/ap/ap_payment_schedule.jsp" target="accountingmainFrame">A/P Scheduling For Payment</a> <br>
		</font></span> 
	<%}if(bolShowTransSpecialJournal){%>
		<div class="trigger" onClick="showBranch('branch10');swapFolder('folder10')"> <img src="../../images/box_with_plus.gif" border="0" id="folder10"> 
			<strong><font color="#FFFFFF" font size="2" face="Geneva, Arial, Helvetica, sans-serif">Special Journals</font></strong></div>
			<span class="branch" id="branch10"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
			<img src="../../images/broken_lines.gif"> <a href="./transaction/special_journal/main.jsp?operation=1" target="accountingmainFrame">AR Journal</a><br>
			<%if(strSchCode.startsWith("UPH") && false){%>
				<img src="../../images/broken_lines.gif"> <a href="./transaction/special_journal/ar_journal_split.jsp" target="accountingmainFrame">Split AR Journal</a><br>
			<%}%>
			<img src="../../images/broken_lines.gif"> <a href="./transaction/special_journal/main.jsp?operation=2" target="accountingmainFrame">Scholarship</a> <br>
			<img src="../../images/broken_lines.gif"> <a href="./transaction/special_journal/main.jsp?operation=3" target="accountingmainFrame">Cash Receipt Journal</a> <br>
			<img src="../../images/broken_lines.gif"> <a href="./transaction/special_journal/aej.jsp?jv_type=6" target="accountingmainFrame">Advance Enrollment</a> <br>
			<img src="../../images/broken_lines.gif"> <a href="./transaction/special_journal/aej_reversal.jsp?jv_type=7" target="accountingmainFrame">Advance Enrollment(Reversal Entry)</a> <br>
		</font></span> 
	<%}%>


<%}%>
</span>
<%}if(bolGrantAll || vAuthList.indexOf("REPORTS") != -1){isAuthorized=true;%>
<!-- <img src="../../images/small_white_box.gif" border="0" >
<strong><a href="../user_admin/./ip_filter.jsp" target="useradminmainFrame">IP
FILTER </a></strong>  -->

<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">REPORTS</font></strong></div>
  <span class="branch" id="branch4">
<!--
  <img src="../../images/broken_lines.gif"> <a href="reports/income.jsp" target="accountingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Income</font></a><br>
  <img src="../../images/broken_lines.gif"> <a href="reports/expenses.jsp" target="accountingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Expenses </font></a><br>
 <img src="../../images/broken_lines.gif"> <a href="reports/expenses.jsp" target="accountingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Petty Cash </font></a><br>
-->
  	<img src="../../images/broken_lines.gif"> <a href="reports/cash_disbursement/rep_cash_disbursement.htm" target="accountingmainFrame"> Disbursement</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./reports/journal_voucher/jv_1st_page.jsp" target="accountingmainFrame">General Journal</a><br>
<%if(false){%>
  	<img src="../../images/broken_lines.gif"> <a href="reports/aging_of_accounts/aging_of_accounts.htm" target="accountingmainFrame">Aging of Accounts</a><br>
<%}%>
	<img src="../../images/broken_lines.gif"> <a href="reports/bank_adjustments/update_check_stat.jsp" target="accountingmainFrame">Bank Adjustments</a><br>
 	<img src="../../images/broken_lines.gif"> <a href="reports/general_ledger/gl_1st_page.jsp" target="accountingmainFrame">General Ledger</a><br>
   	<img src="../../images/broken_lines.gif"> <a href="reports/trial_balance/tb_1st_page.jsp" target="accountingmainFrame">Trial Balance</a><br>
<%if(false){%>
  	<img src="../../images/broken_lines.gif"> <a href="reports/statement_of_rev_expenses/srel_1st_page.htm" target="accountingmainFrame">Statement of Revenues <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;and Expenses</a><br>
  	<img src="../../images/broken_lines.gif"> <a href="reports/statement_of_general_fund_bal/sgfbl_1st_page.htm" target="accountingmainFrame">Statement of General <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fund Balances</a><br>
<%}%>
  	<img src="../../images/broken_lines.gif"> <a href="reports/balance_sheet/bl_1st_page.jsp" target="accountingmainFrame">Balance Sheet</a><br>
  	<img src="../../images/broken_lines.gif"> <a href="reports/income_statement/is_report_1st_page.jsp" target="accountingmainFrame">Income Statement </a><br>
	<img src="../../images/broken_lines.gif"> <a href="./reports/general_journal/gen_journal_1st_page.jsp" target="accountingmainFrame">Monthly Transaction Summary (General Journal)</a><br>
<%if(strSchCode.startsWith("CIT")){%>
	<img src="../../images/broken_lines.gif"> <a href="./reports/bir/main.jsp" target="accountingmainFrame">BIR Requirement(Annual Report)</a><br>
<%}%>
<!--	
-- this is not used anymore. refere to General Journal above.
	<img src="../../images/broken_lines.gif"> <a href="./reports/general_journal/gen_journal_new_1st_page.jsp" target="accountingmainFrame">General Journal (Detail)</a><br>
-->
		<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> <img src="../../images/box_with_plus.gif" border="0" id="folder5"> 
		<strong><font color="#FFFFFF" font size="2" face="Geneva, Arial, Helvetica, sans-serif">Special Books</font></strong></div>
		<span class="branch" id="branch5"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
		<img src="../../images/broken_lines.gif"> <a href="./reports/special_books/cash_disb_boook/cd_book_main.jsp" target="accountingmainFrame">Disbursement Book</a><br>
<%if(strSchCode.startsWith("AUF") || true){%>
		<img src="../../images/broken_lines.gif"> <a href="./reports/special_books/cash_receipt/cash_receipt_main.jsp" target="accountingmainFrame">Cash Receipt Book</a><br>
<%}%>
		</font></span> 
		
		<div class="trigger" onClick="showBranch('branch51');swapFolder('folder51')"> <img src="../../images/box_with_plus.gif" border="0" id="folder51"> 
		<strong><font color="#FFFFFF" font size="2" face="Geneva, Arial, Helvetica, sans-serif">Special Journals</font></strong></div>
		<span class="branch" id="branch51"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
		<img src="../../images/broken_lines.gif"> <a href="./reports/special_journal/crj/crj_main.jsp" target="accountingmainFrame">Cash Receipt Journal</a><br>
		<img src="../../images/broken_lines.gif"> <a href="./reports/special_journal/apj/apj_main.jsp" target="accountingmainFrame">A/P Journal</a><br>
		<img src="../../images/broken_lines.gif"> <a href="./reports/special_journal/arj/arj_main.jsp" target="accountingmainFrame">A/R Journal</a><br>
		<img src="../../images/broken_lines.gif"> <a href="./reports/special_journal/scholarship/sj_main.jsp" target="accountingmainFrame">Scholarship Journal</a><br>
		<img src="../../images/broken_lines.gif"> <a href="./reports/special_journal/aej/aej_main.jsp" target="accountingmainFrame">Advance Enrollment Journal</a><br>
		<img src="../../images/broken_lines.gif"> <a href="./reports/special_journal/prj/prj_main.jsp" target="accountingmainFrame">Payroll Journal</a><br>
<!--
		<img src="../../images/broken_lines.gif"> <a href="./reports/special_journal/" target="accountingmainFrame">Payroll Journal</a><br>
-->
		</font></span> 

</span>
<%}if(bolGrantAll || isAuthorized){%>
  	<img src="../../images/arrow_blue.gif"> <a href="administration/chart_of_accounts/chart_of_account_search.jsp" target="accountingmainFrame"><strong>Search Chart of Account</strong></a><br>
<%}
if(strSchCode.startsWith("TSUNEISHI")){
	if(bolGrantAll || vAuthList.indexOf("BILLING") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch17');swapFolder('folder17')"> <img src="../../images/box_with_plus.gif" border="0" id="folder17"> 
		<strong><font color="#FFFFFF" font size="2" face="Geneva, Arial, Helvetica, sans-serif">BILLING</font></strong></div>
		<span class="branch" id="branch17"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
		<img src="../../images/broken_lines.gif"> <a href="./billing/ac_team_mgmt.jsp" target="accountingmainFrame">Team Management </a><br>
		<img src="../../images/broken_lines.gif"> <a href="./billing/project_mgmt.jsp" target="accountingmainFrame">Project Management </a><br>
		<img src="../../images/broken_lines.gif"> <a href="./billing/project_billing_mgmt.jsp" target="accountingmainFrame">Project Billing Mgmt </a><br>
		<img src="../../images/broken_lines.gif"> <a href="./billing/billing_report.jsp" target="accountingmainFrame">Billing Report </a><br>
		<img src="../../images/broken_lines.gif"> <a href="./billing/search_main.jsp" target="accountingmainFrame">Search </a><br>
		<img src="../../images/broken_lines.gif"> <a href="./billing/invoice_main.jsp" target="accountingmainFrame">Invoice Management </a><br>
		<img src="../../images/broken_lines.gif"> <a href="./billing/expense_dist_main.jsp" target="accountingmainFrame">Expense Distribution Mgmt </a><br>
		<img src="../../images/broken_lines.gif"><a href="billing/create_dc_note.jsp" target="accountingmainFrame"> Manage D/C Entries</a><br>
		<img src="../../images/broken_lines.gif"><a href="billing/update_dc_note.jsp" target="accountingmainFrame"> Manage D/C Details</a><br>
	</font></span>
<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8">
	<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">PAYMENT</font></strong></div>
  	<span class="branch" id="branch8">
	<img src="../../images/broken_lines.gif"><a href="payment/sales_exchange_rate.jsp" target="accountingmainFrame"> Manage Exchange Rate</a><br>
	<img src="../../images/broken_lines.gif"><a href="payment/payment_main.jsp" target="accountingmainFrame"> Payment Management </a><br>
	<img src="../../images/broken_lines.gif"><a href="payment/sales_reports_main.jsp" target="accountingmainFrame"> Reports</a><br>
</span>
<div class="trigger" onClick="showBranch('branch9');swapFolder('folder9')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder9">
	<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">SOA</font></strong></div>
  	<span class="branch" id="branch9">
	
	<img src="../../images/broken_lines.gif"><a href="SOA/SOA_entries.jsp" target="accountingmainFrame"> Manage SOA Entries</a><br>
	<img src="../../images/broken_lines.gif"><a href="SOA/SOA_details.jsp" target="accountingmainFrame"> Manage SOA Details</a><br>
</span>

<%}
}

if(strSchCode.startsWith("ARTCRAFT")){
	if(bolGrantAll || vAuthList.indexOf("INVOICE") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch18');swapFolder('folder18')"> <img src="../../images/box_with_plus.gif" border="0" id="folder18"> 
		<strong><font color="#FFFFFF" font size="2" face="Geneva, Arial, Helvetica, sans-serif">INVOICE</font></strong></div>
		<span class="branch" id="branch18"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
		<img src="../../images/broken_lines.gif"><a href="invoice/manage_customers.jsp" target="accountingmainFrame"> Manage Customers</a><br>
		<img src="../../images/broken_lines.gif"><a href="invoice/manage_invoice.jsp" target="accountingmainFrame"> Manage Invoice</a><br>
		<img src="../../images/broken_lines.gif"><a href="invoice/update_invoice.jsp" target="accountingmainFrame"> Manage Invoice Details</a><br>
		<img src="../../images/broken_lines.gif"><a href="invoice/print_invoice.jsp" target="accountingmainFrame"> Print Invoice</a><br>
		<img src="../../images/broken_lines.gif"><a href="invoice/search_invoice.jsp" target="accountingmainFrame"> Search</a><br>
	</font></span>
<%}
}




if(strUserId == null)
	strErrMsg = "Session timeout. Please login again.";
else if(!isAuthorized)
	strErrMsg = "You are not authorized to view any link in this page. Please contact system admin for access permission.";
if(strErrMsg == null)
	strErrMsg = "";
%>
  <font size="2" face="Verdana, Arial, Helvetica, sans-serif"><%=strErrMsg%></font>
</div>
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>
