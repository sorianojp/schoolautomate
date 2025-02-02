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
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
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
else
	strErrMsg = "";

if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"Accounting")){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" border="0" id="folder1">
  <strong>ADMINISTRATION</strong></div>

<span class="branch" id="branch1">
	<img src="../../images/broken_lines.gif"> <a href="administration/setup_fiscal_year.jsp" target="accountingmainFrame">Setup Fiscal Year</a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/closing_accounts/closing_accounts.htm" target="accountingmainFrame">Closing Accounts <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Transaction</a><br>
    <img src="../../images/broken_lines.gif"> <a href="administration/transaction_type_create.jsp" target="accountingmainFrame">Transactions Type</a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/chart_of_accounts/chart_of_account_main.jsp" target="accountingmainFrame">Chart of Accounts</a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/map_coa_main.htm" target="accountingmainFrame">Link Chart Of Accounts</a><br>
    <img src="../../images/broken_lines.gif"> <a href="administration/banks_create.jsp" target="accountingmainFrame">Link Bank</a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/setup_bs/page1.jsp" target="accountingmainFrame">Setup Balance Sheet</a><br>


<!--    <img src="../../images/broken_lines.gif"> <a href="administration/set_coa_mapping.jsp" target="accountingmainFrame">Set Other COA Mapping</a><br>
-->
    <img src="../../images/broken_lines.gif"> <a href="administration/chart_of_accounts/chart_of_account_search.jsp" target="accountingmainFrame">Search Chart of Account</a><br>
<!--
	<img src="../../images/broken_lines.gif"> <a href="administration/banks_create.jsp" target="accountingmainFrame">Banks</a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/setup_balance_accounts.htm" target="accountingmainFrame">Setup Accounts Balance</a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/setup_charges_source.htm" target="accountingmainFrame">Set Accounts For Fund<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Charges</a><br>
	<img src="../../images/broken_lines.gif"> <a href="administration/setup_accounts_for_trial_balance.htm" target="accountingmainFrame">Set Accounts For <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Trial Balance</a><br>
<!--
	<img src="../../images/broken_lines.gif"> <a href="administration/link_accounts.htm" target="accountingmainFrame">Link Accounts</a><br>
-->
</span>
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" border="0" id="folder3">
  <strong>TRANSACTION</strong></div>
<span class="branch" id="branch3">
	<img src="../../images/broken_lines.gif"> <a href="transaction/cash_disbursement/cash_disbursement.jsp" target="accountingmainFrame">Disbursement </a><br>
	<img src="../../images/broken_lines.gif"> <a href="transaction/petty_cash/petty_cash.jsp" target="accountingmainFrame">Petty Cash </a><br>
	<img src="../../images/broken_lines.gif"> <a href="transaction/journal_voucher/journal_voucher.jsp" target="accountingmainFrame">Journal Voucher </a><br>
<!--
    <img src="../../images/broken_lines.gif"> <a href="transaction/others/other_transaction_main.htm" target="accountingmainFrame">Others</a><br>
-->
    <img src="../../images/broken_lines.gif"> <a href="transaction/budget_entry/budget_encode.jsp" target="accountingmainFrame">Budget Entry </a><br>
<%if(false){%>
    <img src="../../images/broken_lines.gif"> <a href="transaction/apr/account_payable.jsp" target="accountingmainFrame">Account Payable </a><br>
    <img src="../../images/broken_lines.gif"> <a href="transaction/apr/account_receivable.jsp" target="accountingmainFrame">Account Receivable </a><br>
    <img src="../../images/broken_lines.gif"> <a href="transaction/apr/sl.jsp" target="accountingmainFrame">Subsidary Ledger</a><br>
<%}%>
    <img src="../../images/broken_lines.gif"> <a href="administration/chart_of_accounts/chart_of_account_search.jsp" target="accountingmainFrame">Search Chart of Account</a><br>
</span>

<!-- <img src="../../images/small_white_box.gif" border="0" >
<strong><a href="../user_admin/./ip_filter.jsp" target="useradminmainFrame">IP
FILTER </a></strong>  -->

<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">REPORTS</font></strong></div>
  <span class="branch" id="branch4">
<!--
  <img src="../../images/broken_lines.gif" width="15" height="15"> <a href="reports/income.jsp" target="accountingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Income</font></a><br>
  <img src="../../images/broken_lines.gif" width="15" height="15"> <a href="reports/expenses.jsp" target="accountingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Expenses </font></a><br>
 <img src="../../images/broken_lines.gif" width="15" height="15"> <a href="reports/expenses.jsp" target="accountingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Petty Cash </font></a><br>
-->
  	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="reports/cash_disbursement/rep_cash_disbursement.htm" target="accountingmainFrame">Disbursement</a><br>
  	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="reports/ap_reports/aging_of_accounts/aging_of_accounts.htm" target="accountingmainFrame">Aging of Accounts</a><br>
	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="transaction/ap/check_mgmt/update_check_stat.jsp" target="accountingmainFrame">Bank Adjustments</a><br>
 	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="reports/financial_statements/general_ledger/gl_1st_page.jsp" target="accountingmainFrame">General Ledger</a><br>
   	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="reports/financial_statements/trial_balance/tb_1st_page.jsp" target="accountingmainFrame">Trial Balance</a><br>
  	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="reports/financial_statements/statement_of_rev_expenses/srel_1st_page.htm" target="accountingmainFrame">Statement of Revenues <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;and Expenses</a><br>
  	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="reports/financial_statements/statement_of_general_fund_bal/sgfbl_1st_page.htm" target="accountingmainFrame">Statement of General <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fund Balances</a><br>
  	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="reports/financial_statements/balance_sheet/bl_1st_page.jsp" target="accountingmainFrame">Balance Sheet</a><br>

  </span>


  <%}

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
