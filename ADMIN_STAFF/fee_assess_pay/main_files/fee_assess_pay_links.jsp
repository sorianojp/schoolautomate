<%
String strSchCode    = (String)request.getSession(false).getAttribute("school_code");//strSchCode = "CSA";
if(strSchCode == null) {%>
	<p style="font-size:14px; font-weight:bold; color:#FF0000">You are already logged out. Please login again.</p>
<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<link href="../../../css/treelinkcss.css" rel="stylesheet" type="text/css">
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
<link href="../../../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<body bgcolor="#C39E60" onLoad="MM_preloadImages('../../../images/home_small_admin_rollover.gif','../../../images/help_small_admin_rollover.gif','../../../images/logout_admin_rollover.gif')">
<!--
	onpageshow='OnPageShowFocus()' onpagehide='OnPageHide();'>
-->

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

/**
function OnPageShowFocus() {
	alert("i m here.");
	document.getElementById("onpages").innerHTML = "<font size='6'>On Page Focus</font>";
}	
function OnPageHide() {
	document.getElementById("onpages").innerHTML = "Hidden";
}	
**/
</script>
<form action="../../../commfile/logout.jsp" method="post" target="_parent">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="8%" height="19" bgcolor="#E9E0D1">&nbsp;<label id='onpages'></label></td>
    <td width="92%" bgcolor="#E9E0D1"><a href="../../main%20files/admin_staff_home_button_content.htm" target="_parent" onMouseOver="MM_swapImage('Image2','','../../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
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
String strTemp   = null;

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

//Another way of checking authorization.. 
Vector vAuthList = null;
if(!bolGrantAll) {
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, "Fee Assessment & Payments");
	if(vAuthList == null)
		vAuthList = new Vector();
	else if( ((String)vAuthList.elementAt(0)).compareTo("#ALL#") == 0) 
		bolGrantAll = true;
}
boolean bolIsLNU = strSchCode.startsWith("LNU");
boolean bolIsUI = strSchCode.startsWith("UI");

boolean bolAllowSubLink = false;


//old way of doing 
//comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Fee Assessment & Payments","ASSESSMENT")!=0
String strInfo5 = (String)request.getSession(false).getAttribute("info5");
if(strInfo5 == null)
	strInfo5 = "";
	
boolean bolIsCavite = false;
if(strInfo5.equals("Cavite"))
	bolIsCavite = true;

boolean bolHasCashierReport = false;

//boolean 

String strSQLQuery = "select module_index from module where module_name = 'Fee Assessment & Payments'";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null) {
	String strModuleIndex = strSQLQuery;
	strSQLQuery = "select sub_mod_index from sub_module where module_index = "+strSQLQuery+" and sub_mod_name = 'Cashier Report'";//System.out.println(strSQLQuery);
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null) {//check if user is authenticated for cashier report.
		strSQLQuery = "select auth_list_index from user_auth_list where user_index = "+(String)request.getSession(false).getAttribute("userIndex")+" and main_mod_index = "+
						strModuleIndex+" and sub_mod_index = "+strSQLQuery+" and is_valid = 1 ";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null)
			bolHasCashierReport = true;
	}
}


boolean bolIsETO = new enrollment.SetParameter().bolIsETO(dbOP, (String)request.getSession(false).getAttribute("userIndex"));

boolean bolShowSchFacilityFee = false;

boolean bolIsCCPmtAllowed = false;
strTemp = (String)request.getSession(false).getAttribute("is_cc_allowed");
if(strTemp != null)
	bolIsCCPmtAllowed = true;
else {
	strSQLQuery = "select prop_val from read_property_file where prop_name = 'IS_CC_ALLOWED'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);	
	if(strSQLQuery != null && strSQLQuery.equals("1")) {
		bolIsCCPmtAllowed = true;
		request.getSession(false).setAttribute("is_cc_allowed", "1");
	}	
}
if(request.getSession(false).getAttribute("PMT_REMARK_ALLOWED") == null) {
	strSQLQuery = "select prop_val from read_property_file where prop_name = 'PMT_REMARK_ALLOWED'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);	
	if(strSQLQuery != null && strSQLQuery.equals("1")) {
		request.getSession(false).setAttribute("PMT_REMARK_ALLOWED", "1");
	}	

}



if(strSchCode.startsWith("AUF") || strSchCode.startsWith("CSA") || strSchCode.startsWith("EAC") || strSchCode.startsWith("PWC") || strSchCode.startsWith("VMA") || 
	strSchCode.startsWith("SWU") || strSchCode.startsWith("UB") || strSchCode.startsWith("UPH")) {
	request.getSession(false).setAttribute("is_cc_allowed", "1");
	bolIsCCPmtAllowed = true;
}
	



if(bolGrantAll || vAuthList.indexOf("ASSESSMENT") != -1){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder1">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ASSESSMENT</font></strong></div>
	<span class="branch" id="branch1"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<img src="../../../images/broken_lines.gif"> <a href="../assessment/fee_assess_pay_assessment.jsp" target="feemainFrame"> Enrollment</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../assessment/re_assessment.jsp" target="feemainFrame">Re-assessment (Requested Subject Charges)</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../assessment/assessment_sched.jsp" target="feemainFrame">Schedule Assessment</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../assessment/assessment_sched_batch.jsp" target="feemainFrame">Print Schedule Assessment</a><br>
<%if(strSchCode.startsWith("CLDH") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("UL") || strSchCode.startsWith("SWU")){%>
	<img src="../../../images/broken_lines.gif"><a href="../assessment/fixed_tuition_entry_info.jsp" target="feemainFrame">Update Student's entry information (if tuition fee is fixed)</a><br>
<%}
if(strInfo5.equals("jonelta") && false){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/promisory_note_downpayment.jsp" target="feemainFrame">Promisory Note for Downpayment</a><br>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/plan/fatima_plan_main.jsp" target="feemainFrame">PLAN Management</a><br>
<%}
if(strSchCode.startsWith("PWC") || strSchCode.startsWith("SPC") || strSchCode.startsWith("SWU") || strSchCode.startsWith("NEU") || strSchCode.startsWith("DLS") || strSchCode.startsWith("HTC")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/promisory_note_downpayment.jsp" target="feemainFrame">Promisory Note for Downpayment</a><br>
<%}

if(strSchCode.startsWith("FATIMA") || strInfo5.equals("jonelta")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/plan/fatima_plan_main.jsp" target="feemainFrame">PLAN Management</a><br>
<%}
if(strSchCode.startsWith("UC") || strSchCode.startsWith("UPH")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../../enrollment/advising/assessment_fee_exclude.jsp" target="feemainFrame">Exclude Misc/Oth Charge/Set Reqd DownPayment</a><br>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/promisory_note_downpayment.jsp" target="feemainFrame">Promisory Note for Downpayment</a><br>
		<img src="../../../images/broken_lines.gif"> <a href="../../user_admin/set_param/set_advising_rule.jsp" target="feemainFrame">Allow/Block Advising</a><br>
<%}
if(strSchCode.startsWith("CIT") || strSchCode.startsWith("WUP") || strSchCode.startsWith("VMA") || strSchCode.startsWith("PWC") || strSchCode.startsWith("DLSHSI")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../../enrollment/advising/assessment_fee_exclude.jsp" target="feemainFrame">Exclude Misc/Oth Charge</a><br>
<%}
if(strSchCode.startsWith("UPH") || strSchCode.startsWith("SWU") || strSchCode.startsWith("CIT") || strSchCode.startsWith("DLSHSI") || strSchCode.startsWith("CDD")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../assessment/set_tuition_per_student.jsp" target="feemainFrame">Set Specific Tuition Fee for A Student</a><br>
<%}
if(strSchCode.startsWith("CIT") || strSchCode.startsWith("SPC")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../../enrollment/advising/assessment_optional_fee.jsp" target="feemainFrame">Post Optional Fee to a Student</a><br>
<%}
if(strSchCode.startsWith("SWU")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/manage_swu_batch.jsp" target="feemainFrame">Manage Batch Enrollment</a><br>
<%}%>
	<img src="../../../images/broken_lines.gif"> <a href="../assessment/remove_late_fine.jsp" target="feemainFrame">Remove Late Fine</a><br>
	</font>
	</span>
<%}if(bolGrantAll || vAuthList.indexOf("FEE MAINTENANCE") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder2">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">FEE MAINTENANCE</font></strong></div>

<span class="branch" id="branch2"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<%if(strSchCode.startsWith("FATIMA")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/application_fee_per_course.jsp" target="feemainFrame">Manage Application Fee</a><br>
<%}%>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_main_page.jsp?operation=1" target="feemainFrame">Tuition Fees</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_main_page.jsp?operation=2" target="feemainFrame">Miscellaneous Fees</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_main_page.jsp?operation=3" target="feemainFrame">Other Charges</a><br>
<%if(strSchCode.startsWith("UC") || strSchCode.startsWith("CIT")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/manage_subj_catg_per_term.jsp" target="feemainFrame">Manage Subj Catg Per Term</a><br>
<%}if(strSchCode.startsWith("NU") || strSchCode.startsWith("CSAB") || strSchCode.startsWith("CIT") || strSchCode.startsWith("WNU") || strSchCode.startsWith("UL") || strSchCode.startsWith("FATIMA") || strSchCode.startsWith("UPH") || strSchCode.startsWith("CDD") || strSchCode.startsWith("SWU")){%>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_misc_fee_multiple_labfee_tagged.jsp" target="feemainFrame">Map Misc/Other charge To<br>&nbsp;&nbsp;&nbsp;&nbsp; Multiple Sub.Catg</a><br>
<%}if(strSchCode.startsWith("UL") || strSchCode.startsWith("UI") || strSchCode.startsWith("AUF") || strSchCode.startsWith("WUP") ||(strUserId != null && (strUserId.compareTo("1770") ==0 || strUserId.compareTo("biswa-001") == 0)) ){%>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_reenrollment.jsp" target="feemainFrame">Re-enrollment Fee</a><br>
<%}%>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_main_page.jsp?operation=4" target="feemainFrame">Other School Fees</a><br>
<%if(strSchCode.startsWith("WNU")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_other_sch_fee_vatable.jsp" target="feemainFrame">Set Other School Fees as Vatable</a><br>
<%}%>
<%if(strSchCode.startsWith("SPC")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/oth_sch_fee_group_spc.jsp" target="feemainFrame">Group Other School Fees</a><br>
<%}%>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/set_oth_sch_fee_as_tuition.jsp" target="feemainFrame">Set Other School Fees as Tuition</a><br>
<%if(bolShowSchFacilityFee) {%>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_sch_facil_fee.jsp" target="feemainFrame">School Facilities Fees</a><br>
<%}%>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_main_page.jsp?operation=6" target="feemainFrame">Excluded Subjects in Fee Assessment</a><br>
<%
if(!bolIsLNU){%>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_main_page.jsp?operation=7" target="feemainFrame">Variable Load Rate</a><br>
<%}if(!bolIsUI){%>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_main_page.jsp?operation=8" target="feemainFrame">Below Min. Student Enrolees</a><br>
<%}%>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/enrolment_date_param.jsp" target="feemainFrame">Enrollment Date Parameter</a><br>
<%
if(strSchCode.startsWith("CPU") || (strUserId != null && (strUserId.compareTo("1770") ==0 || strUserId.compareTo("biswa-001") == 0)) ){%>
<img src="../../../images/broken_lines.gif"> <a href="../../admission/curriculum_page1.jsp?lf=1" target="feemainFrame">Lab fee (view in curriculum)</a><br>
<%}
if(bolIsLNU || (strUserId != null && (strUserId.compareTo("1770") ==0 || strUserId.compareTo("biswa-001") == 0)) ){%>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/lab_deposit_mgmt.jsp" target="feemainFrame">Laboratory Deposit MGMT</a><br>
<%}
if(strSchCode.startsWith("PHILCST") || strSchCode.startsWith("EAC") || strSchCode.startsWith("NEU")){%>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/set_supplies_fee_philcst.jsp" target="feemainFrame">Set Other  School Fee as Supplies</a><br>
<%}
if(strSchCode.startsWith("EAC") && !bolIsCavite){%>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/set_YLFI_fee.jsp" target="feemainFrame">Set Other  School Fee for YLFI</a><br>
<%}
if(strSchCode.startsWith("FATIMA")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/manage_installment_plans.jsp" target="feemainFrame">Manage Installment Plans</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/add_drop/add_drop_main.jsp" target="feemainFrame">Add/Drop Fee Set up</a><br>
<%}
if(strSchCode.startsWith("EAC") || strSchCode.startsWith("UC") || strSchCode.startsWith("NEU")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/add_drop/add_drop_main.jsp" target="feemainFrame">Add/Drop Fee Set up</a><br>
<%}
if(strInfo5.equals("jonelta")) {%>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/manage_installment_plans_new.jsp" target="feemainFrame">Manage Installment Plans</a><br>
<%}
if(strSchCode.startsWith("UB")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/setup_trust_fund_ub.jsp" target="feemainFrame">Set up Trust Fund</a><br>
<%}if(strSchCode.startsWith("CIT")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/setup_wetlab_cit.jsp" target="feemainFrame">Set up WetLab Fee</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/setup_cit_ojt_remove_fee_main.jsp" target="feemainFrame">Set up OJT Exclude Misc Fee</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../assessment/cit_lec_lab_type_enrollment.jsp" target="feemainFrame">Set Lec/Lab enrollment for Dry Lab</a><br>
<%}%>
	<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/cash_discount_manage.jsp" target="feemainFrame">Manage Cash Discount</a><br>


<!--<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/update_fee.htm" target="feemainFrame">Update Fees </a><br>-->
</font> 
<!-- TO UPDATE DIFFERENT FEE TYPES -->
<%if(true){%>
<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder7"> 
  <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Update/Edit Fees</font></div>
<span class="branch" id="branch7"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/update_tution_fee.jsp" target="feemainFrame">Tuition Fees</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/update_misc_fee.jsp" target="feemainFrame">Miscellaneous and Other charges</a><br>
<!--
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/update_other_sch_fee.jsp" target="feemainFrame">Other School Fees</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/update_sch_facil_fee.jsp" target="feemainFrame">School Facilties Fees</a><br>
-->
</font> </span>
<%}%>
</span>  
<%}if(bolGrantAll || vAuthList.indexOf("PAYMENT MAINTENANCE") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder3">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">PAYMENT MAINTENANCE</font></strong></div>

<span class="branch" id="branch3"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/bank_list_for_check.jsp" target="feemainFrame">Create Bank Info (for check pmt)</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/fee_assess_pay_payee_type.jsp" target="feemainFrame">Payee Type</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/fee_assess_pay_aff_inst_payee.jsp" target="feemainFrame">Affiliated Institutional Payee</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/fee_assess_pay_receive_type.jsp" target="feemainFrame">Payment Receive Type</a><br>
<%if(false){%>
	<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/fee_assess_pay_payment_mode.jsp" target="feemainFrame">Payment Mode</a><br>
<%}%>
<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/fee_assess_pay_payment_sched.jsp" target="feemainFrame">Payment Schedule</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/min_pmt_for_exam_permit.jsp" target="feemainFrame">Required Payment Parameter</a><br>
<%
if(strSchCode.startsWith("UI") || strSchCode.startsWith("CSAB") || (strUserId != null && (strUserId.compareTo("1770") ==0 || strUserId.compareTo("biswa-001") == 0)) ){%>
	<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/entry_status_payment_param.jsp" target="feemainFrame">Entry Status Payment</a><br>
<%}%>
	<%if(!strSchCode.startsWith("WU_")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_main_page.jsp?operation=5" target="feemainFrame">Fee Adjustment Type</a><br>
	<%}%>
	<%if(strSchCode.startsWith("UPH") && (String)request.getSession(false).getAttribute("info5") == null){//do not show for jonelta.%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/uph_adjustment_info/exclude_subject.jsp" target="feemainFrame">Fee Adjustment - Exception</a><br>
	<%}%>
<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/uph_adjustment_info/exclude_subject_max_unit.jsp" target="feemainFrame">Fee Adjustment - Exception(Remove subject from Max Unit Discount)</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/required_dp.jsp" target="feemainFrame">Required Downpayment </a><br>
<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/nodp/stud_no_dp_main.jsp" target="feemainFrame">Automatic Waiver of Downpayment</a><br>
<%
if(strSchCode.startsWith("UB") ){%>
	<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/ub_teller_id.jsp" target="feemainFrame">TELLER NO (For Payment)</a><br>
<%}%>
<%
if(strSchCode.startsWith("SWU")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/swu_teller_number.jsp" target="feemainFrame">TELLER NO (For Payment)</a><br>
<%}%>
<%
if(strSchCode.startsWith("UC") && bolGrantAll){%>
	<img src="../../../images/broken_lines.gif"> <a href="../payment_maintenance/damaged_or.jsp" target="feemainFrame">Manage Damaged OR</a><br>
<%}
if(strSchCode.startsWith("NEU")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/salary_deduction_mgmt_neu.jsp" target="feemainFrame">Salary Deduction Management</a><br>
<%}%>
</font> </span> 
<%}if(bolGrantAll || vAuthList.indexOf("POST CHARGES") != -1){isAuthorized=true;%>
<div> <img src="../../../images/arrow_blue.gif"  border="0" > 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../post_other_sch_fees/post_charges_main.jsp" target="feemainFrame">POST 
  CHARGES</a> </font></strong></div>


<%}if(strSchCode.startsWith("WU_")) {
	if(bolGrantAll || vAuthList.indexOf("DISCOUNTS") != -1){isAuthorized=true;%>
		<div class="trigger" onClick="showBranch('branch15');swapFolder('folder15')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder15"> 
		  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">DISCOUNTS</font></strong></div>
		<span class="branch" id="branch15"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		<img src="../../../images/broken_lines.gif"> <a href="../fee_maintenance/fm_main_page.jsp?operation=5" target="feemainFrame">Discount Management </a><br>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/fee_adjustment.jsp" target="feemainFrame">Apply/Post Discount</a><br>
		</font></span>
	<%}%>


<%}if(bolGrantAll || vAuthList.indexOf("PAYMENT") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder4">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">PAYMENT</font></strong></div>
<span class="branch" id="branch4"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<% if (!strSchCode.startsWith("CPU")){%>  
	<img src="../../../images/broken_lines.gif"> <a href="../payment/assessedfees_main.jsp" target="feemainFrame">Assessed Fees(Enrollment) </a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/install_assessed_fees_payment.jsp" target="feemainFrame">Installment Fees </a><br>
<% if(strSchCode.startsWith("UB")){%>  
	<img src="../../../images/broken_lines.gif"> <a href="../reports/charge_slip_print_control_number_ub.jsp" target="feemainFrame">Print Admission No.</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/check_encashment.jsp" target="feemainFrame">Check Encashment</a><br>
<%}
	if(strSchCode.startsWith("CGH") ){%>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/sponsor_payment.jsp" target="feemainFrame">Sponsor Payment For Student</a><br>
<%}
	
	if(!bolIsLNU){%>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/check_payment_main.jsp" target="feemainFrame">Check Payment Mgmt</a><br>
	<%}if(bolIsCCPmtAllowed){%>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/creditcard/setting.jsp" target="feemainFrame">Credit Card/E-Pay Mgmt</a><br>
	<%}%>
<%if(!strSchCode.startsWith("VMA") && !strSchCode.startsWith("DLSHSI") && !strSchCode.startsWith("LICEO") && !strSchCode.startsWith("HTC")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/multiple_payment.jsp" target="feemainFrame">Multiple Payment</a><br>
<%}if(false){
		if(strSchCode != null && !bolIsLNU && !strSchCode.startsWith("DBTC") && !strSchCode.startsWith("CLDH") && !strSchCode.startsWith("UDMC") && !strSchCode.startsWith("CGH") && !strSchCode.startsWith("WNU")){%>
		<img src="../../../images/broken_lines.gif"> 
		<a href="<%if(!strSchCode.startsWith("VMUF")){%>../payment/install_assessed_fees_payment_bas.jsp<%}else{%>../payment/basic_education_payment_main.htm<%}%>" target="feemainFrame">Basic Education Payment</a><br>
	<%}
	}%>
	<%if(!strSchCode.startsWith("FATIMA")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/tuition_nontuition_payment.jsp" target="feemainFrame">Tuition-NonTuition Payment</a><br>
	<%}%>
	<%if(!strSchCode.startsWith("SPC")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/otherschoolfees.jsp" target="feemainFrame">Other School Fees</a><br>
	<%}if(bolShowSchFacilityFee) {%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/school_facilities.jsp" target="feemainFrame">School Facilities Fees</a><br>
	<%}%>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/back_accounts.jsp" target="feemainFrame">Back Accounts</a><br>
	<%if(strSchCode.startsWith("UB") || strSchCode.startsWith("CSA") || strSchCode.startsWith("FATIMA")){
		if(bolGrantAll || vAuthList.indexOf("PAYMENT-FEE ADJUSTMENT") != -1){%>
			<img src="../../../images/broken_lines.gif"> <a href="../payment/fee_adjustment.jsp" target="feemainFrame"> Fee Adjustments</a> <br>
	<%}%>
	<%}else if(!strSchCode.startsWith("WU_")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/fee_adjustment.jsp" target="feemainFrame">
		<%if(strSchCode.startsWith("AUF")){%>Discounts<%}else{%>Fee Adjustments<%}%></a> <br>
	<%}%>
	<%if(!bolIsLNU){%>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/educational_plans_main.htm" target="feemainFrame">Educational Plans</a> <br>
	<%}if(bolGrantAll || vAuthList.indexOf("PAYMENT-MODIFICATION") != -1){%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/payment_modification_main.jsp" target="feemainFrame">Modifications</a><br>
	<%}%>
	<%if(strSchCode.startsWith("CIT") || strSchCode.startsWith("UC") || strSchCode.startsWith("FATIMA") || strSchCode.startsWith("UB") || strSchCode.startsWith("CSA") || 
	strSchCode.startsWith("VMA") || strSchCode.startsWith("SWU") || strSchCode.startsWith("WUP")) {
		if(bolGrantAll || vAuthList.indexOf("PAYMENT-CANCEL-OR") != -1){%>
			<img src="../../../images/broken_lines.gif"> <a href="../payment/cancel_or_new.jsp<%if(strSchCode.startsWith("SWU")){%>?keep_info=1<%}%>" target="feemainFrame">Cancel OR</a><br>
		<%}%>
	<%}else if(strSchCode.startsWith("EAC")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/cancel_or_new.jsp" target="feemainFrame">Cancel OR</a><br>
	<%}else{%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/cancel_or_new.jsp?keep_info=1" target="feemainFrame">Cancel OR</a><br>
	<%}%>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/or_number_view.jsp" target="feemainFrame">Re-print OR </a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/re_print_assessment.jsp" target="feemainFrame">Re-print Student Assessment</a><br>
	<%if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("CSA")){
		if(bolGrantAll || vAuthList.indexOf("PAYMENT-DEBIT-CREDIT") != -1){%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/refunds.jsp" target="feemainFrame">Refund/Debit/Credit</a> <br>
	<%}//do not show if not authorize..
	}
	else if(strSchCode.startsWith("PHILCST")){
		if(bolGrantAll || vAuthList.indexOf("PAYMENT-MODIFICATION") != -1){%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/refunds.jsp" target="feemainFrame">Refund/Debit/Credit</a> <br>
	<%}//do not show if not authorize..
	}else{//no special authentication..%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/refunds.jsp" target="feemainFrame">Refund/Debit/Credit</a> <br>
	<%}
	if(strSchCode.startsWith("CLDH")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../payment/exam_permit_exemption.jsp" target="feemainFrame">Allow Exam Permit Printing</a><br>
		<img src="../../../images/broken_lines.gif"> <a href="../../user_admin/appl_fix/insert_ledg_history_info.jsp" target="feemainFrame">Application Fix(Balance Forwarding)</a><br>
	<%}%>
	<%
	if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("EAC") || 
		strSchCode.startsWith("CDD") || strSchCode.startsWith("WU_") || strSchCode.startsWith("UB") || strInfo5.equals("jonelta")  || strSchCode.startsWith("DLS")){%>
		<!--
		<img src="../../../images/broken_lines.gif"> <a href="../payment/plan/fatima_plan_main.jsp" target="feemainFrame">PLAN Management</a><br>
		-->
		<img src="../../../images/broken_lines.gif"> <a href="../reports/promisory_note_downpayment.jsp" target="feemainFrame">Promisory Note for Downpayment</a><br>
	<%}%>

<%}else{%> 
	<img src="../../../images/broken_lines.gif"> <a href="../payment/assessedfees.jsp" target="feemainFrame">A/R Students(Enroll)</a>  <br>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/install_assessed_fees_payment.jsp" target="feemainFrame">A/R Students(Installment)</a>  <br> 
	<img src="../../../images/broken_lines.gif"> <a href="../payment/multiple_payment_cpu.jsp?stud_status=1&fund_type=0" target="feemainFrame">General Accounts </a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/multiple_payment_cpu.jsp?stud_status=1&fund_type=2" target="feemainFrame">Faculty / Staff</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/multiple_payment_cpu.jsp?stud_status=1&fund_type=1" target="feemainFrame">Endowment Fund </a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../payment/re_print_assessment.jsp" target="feemainFrame">Print RF</a><br>
	<!--
	<img src="../../../images/broken_lines.gif"> <a href="../payment/refunds.jsp" target="feemainFrame">Endowment Fund </a><br>
	-->
<%}%> </font></span> 
<%}%>
<%if(bolGrantAll || vAuthList.indexOf("CASH RECEIPT") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch11');swapFolder('folder11')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder11">
		<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CASH RECEIPTS</font></strong></div>
	<span class="branch" id="branch11"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<img src="../../../images/broken_lines.gif"> <a href="../cash_receipt/or_issue.jsp" target="feemainFrame">Issue OR</a><br>
<%if(strSchCode.startsWith("CIT")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../cash_receipt/encode_cr_cit.jsp" target="feemainFrame">Receive Cash</a>
<%}%>	
	</font>
	</span>

<%}
if(!strSchCode.startsWith("FATIMA"))
if(bolGrantAll || vAuthList.indexOf("CASH DEPOSIT") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch12');swapFolder('folder12')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder12">
		<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CASH DEPOSIT</font></strong></div>
	<span class="branch" id="branch12"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<img src="../../../images/broken_lines.gif"> <a href="../cash_receipt/deposit/set_bank.jsp" target="feemainFrame">Set Bank</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../cash_receipt/deposit/set_begin_balance.jsp" target="feemainFrame">Set Begining Balance</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../cash_receipt/deposit/cash_deposit_main.jsp" target="feemainFrame">Deposit Detail</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../cash_receipt/deposit/cash_deposit_dc.jsp" target="feemainFrame">Debit/Credit Entry</a><br>
<%
if(false)
if(true || bolGrantAll || vAuthList.indexOf("CASH DEPOSIT-UNLOCK") != -1){isAuthorized=true;%>
	<img src="../../../images/broken_lines.gif"> <a href="../cash_receipt/deposit/cash_deposit_unlock.jsp" target="feemainFrame">Unlock Cash Deposit Entry</a><br>
<%}%>
	</font></span>
<%}
if(strSchCode.startsWith("VMUF"))
	if(bolGrantAll || vAuthList.indexOf("DONATION") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder5"> 
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">DONATION</font></strong></div>
	<span class="branch" id="branch5"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
	<img src="../../../images/broken_lines.gif"> <a href="../donation/post_donation.jsp" target="feemainFrame">Post donation </a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../donation/receive_donation.jsp" target="feemainFrame">Receive Donation</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../donation/ledger.jsp" target="feemainFrame">View Ledger </a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../donation/or_number_donation_view.jsp" target="feemainFrame">Print donation receipt</a></font> </span> 
	<%}%>
<%
//if(!bolIsLNU)
if(strSchCode.startsWith("VMUF") || strSchCode.startsWith("DBTC"))
	if(bolGrantAll || vAuthList.indexOf("REMITTANCE") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder6">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">REMITTANCE</font></strong></div>
<span class="branch" id="branch6"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../../../images/broken_lines.gif"> <a href="../remittance/remittance_type.jsp" target="feemainFrame">Remittance Type</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../remittance/receive_remittance.jsp" target="feemainFrame">Receive Remittance</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../remittance/modification.jsp" target="feemainFrame">Modifications</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../remittance/viewall_remittance.jsp" target="feemainFrame">View All Remittance</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../remittance/remittance_print.jsp" target="feemainFrame">Re-print OR</a><br>
</font>
</span>
<%}if(bolGrantAll || vAuthList.indexOf("OLD STUDENT ACCOUNT MGMT") != -1){isAuthorized=true;%>
<div> <img src="../../../images/arrow_blue.gif"  border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../student_ledger/old_student_ledger.jsp" target="feemainFrame">OLD STUDENT ACCOUNT MGMT</a> </font></strong></div>

<%}if(bolGrantAll || vAuthList.indexOf("STUDENT LEDGER") != -1){isAuthorized=true;%>
<div> <img src="../../../images/arrow_blue.gif"  border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../student_ledger/student_ledger.jsp" target="feemainFrame">STUDENT LEDGER</a> </font></strong></div>

<%}if(bolGrantAll || vAuthList.indexOf("STUDENT LEDGER") != -1){isAuthorized=true;
if(false){%>
<div> <img src="../../../images/arrow_blue.gif"  border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../schl_fac_fees_ledger/old_schl_fac_ledger.jsp" target="feemainFrame">OLD OCCUPANT'S LEDGER MGMT</a> </font></strong></div>

<%}
}if(!bolIsLNU && !strSchCode.startsWith("CIT"))
	if(bolGrantAll || vAuthList.indexOf("STUDENT LEDGER") != -1){isAuthorized=true;%>
<div> <img src="../../../images/arrow_blue.gif"  border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../schl_fac_fees_ledger/schl_fac_ledger_view.jsp" target="feemainFrame">SCHOOL FACILITIES LEDGER</a> </font></strong></div>

  <%}if(bolGrantAll || vAuthList.indexOf("DAILY CASH COLLECTION MGMT") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder8">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">DAILY CASH COLLECTION MGMT</font></strong></div>
<span class="branch" id="branch8"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../../../images/broken_lines.gif"> <a href="../daily_cash_collection/setup_cutoff_time.jsp" target="feemainFrame">Set
Cutoff Time for Cash Collection</a> <br>
<!-- FOR NOW I M NOT WORKING ON THE CASH RECEIVE.
<img src="../../../images/broken_lines.gif"> <a href="../daily_cash_collection/cash_fr_teller.jsp" target="feemainFrame">Receive
Cash from Teller</a> <br>
<img src="../../../images/broken_lines.gif"> <a href="../daily_cash_collection/cash_fr_teller.jsp" target="feemainFrame">Modify
Cash Collection Information</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../daily_cash_collection/cash_fr_teller.jsp" target="feemainFrame">List
of Teller having shortage</a><br>
-->
</font> </span>
<%}if(strSchCode.startsWith("CPU")){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch10');swapFolder('folder10')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder10">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">FEE ADJUSTMENTS</font></strong></div>
<span class="branch" id="branch10"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../../../images/broken_lines.gif"> <a href="../fee_adjustments/fee_adjustment_entry_temp.jsp" target="feemainFrame">Add Student Adjustment </a><br>
<img src="../../../images/broken_lines.gif"> <a href="../fee_adjustments/fee_adjustment_entry_view.jsp" target="feemainFrame">View Adjustments </a> <br>
<img src="../../../images/broken_lines.gif"> <a href="../fee_adjustments/add_drop_entry_view.jsp" target="feemainFrame">View Add/Drop Subjects </a><br>
<!--
<img src="../../../images/broken_lines.gif"> <a href="../fee_adjustments/fee_adjustment_for_confirm.jsp" target="feemainFrame">Confirm Adjustment</a><br>
-->
<img src="../../../images/broken_lines.gif"> <a href="../fee_adjustments/fee_adjustment_for_cancel.jsp" target="feemainFrame">Cancel Adjustments </a><br>
<!-- FOR NOW I M NOT WORKING ON THE CASH RECEIVE.
<img src="../../../images/broken_lines.gif"> <a href="../daily_cash_collection/cash_fr_teller.jsp" target="feemainFrame">Receive
Cash from Teller</a> <br>
<img src="../../../images/broken_lines.gif"> <a href="../daily_cash_collection/cash_fr_teller.jsp" target="feemainFrame">Modify
Cash Collection Information</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../daily_cash_collection/cash_fr_teller.jsp" target="feemainFrame">List
of Teller having shortage</a><br>
-->
</font> </span>
<%}if(bolGrantAll || vAuthList.indexOf("REPORTS") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch9');swapFolder('folder9')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder9">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">REPORTS</font></strong></div>
<span class="branch" id="branch9"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<%if(bolHasCashierReport) {%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/cashier_report_main.jsp" target="feemainFrame">Cashier's Report </a> <br>
<%}else{%>

	<%if(strSchCode.startsWith("CGH")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/bank_deposit/bd_main.jsp" target="feemainFrame">Manage Bank Deposits</a> <br>
	<%}if(!strSchCode.startsWith("FATIMA")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../../user_admin/set_param/set_msg_user.jsp" target="feemainFrame">Message System</a> <br>
	<%}else if(bolGrantAll || vAuthList.indexOf("REPORTS-MESSAGE SYSTEM") != -1){%>
		<img src="../../../images/broken_lines.gif"> <a href="../../user_admin/set_param/set_msg_user.jsp" target="feemainFrame">Message System</a> <br>
	<%}%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/cashier_report_main.jsp" target="feemainFrame">Cashier's Report </a> <br>
	<%if(!strSchCode.startsWith("FATIMA") && !strSchCode.startsWith("UB")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/promi_main.jsp" target="feemainFrame">Promisory Note</a> <br>
	<%}%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/daily_cash_col.jsp" target="feemainFrame">Daily Cash Collection Details</a> <br>
	<%if(strSchCode.startsWith("AUF")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/auf_dropped_outs_details.jsp" target="feemainFrame">Dropout list</a> <br>
	<%}%>
<%if(strSchCode.startsWith("SPC")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/other/misc_oc_payable.jsp" target="feemainFrame">Misc/Other Charge Payable(Detailed)</a> <br>
<%}%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/specific_acct.jsp" target="feemainFrame">Specific Fee Collection</a> <br>
	<%if(!strSchCode.startsWith("PHILCST")) {%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/summary_daily_cash_coll_new.jsp" target="feemainFrame">Summary of Daily Cash Collection</a><br>
	<%}if(!strSchCode.startsWith("FATIMA")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/rec_projection_main.jsp" target="feemainFrame">Accounts Receivable</a><br>
	<%}else if(bolGrantAll || vAuthList.indexOf("REPORTS-AR") != -1){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/rec_projection_main.jsp" target="feemainFrame">Accounts Receivable</a><br>
	<%}%>

	<%if(false){%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/back_accounts.htm" target="feemainFrame">Back Accounts</a> <br>
	<%}
	if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("EAC") || strSchCode.startsWith("UL")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/admission_slip_monitor.jsp" target="feemainFrame">Reports on Admission Slip Already Printed</a> <br>
	<%}if(strSchCode.startsWith("UI") || strSchCode.startsWith("AUF") || strSchCode.startsWith("CPU") || strSchCode.startsWith("UDMC") || 
		strSchCode.startsWith("CGH") || strSchCode.startsWith("CLDH") || strSchCode.startsWith("PHILCST") || strSchCode.startsWith("VMUF")  || strSchCode.startsWith("UC") || 
		strSchCode.startsWith("DBTC") || strSchCode.startsWith("PIT") || strSchCode.startsWith("UL")  || strSchCode.startsWith("EAC")  || 
		strSchCode.startsWith("UPH")  || strSchCode.startsWith("WUP") || strSchCode.startsWith("VMA") || strSchCode.startsWith("SPC") || 
		strSchCode.startsWith("MARINER") || strSchCode.startsWith("HTC")){
		
		//if(false && !strSchCode.startsWith("SWU")){%>
			<img src="../../../images/broken_lines.gif"> <a href="../reports/admission_slip_main.jsp" target="feemainFrame"><%if(strSchCode.startsWith("SPC")){%>Exam Permit<%}else{%>Admission Slip<%}%></a><br>
		<%//}%>
			<img src="../../../images/broken_lines.gif"> <a href="../reports/statement_of_account_UI_main.jsp" target="feemainFrame">
		<%if(strSchCode.startsWith("AUF")){%>Certification of Tuition Fees and Payments<%}else{%>Student's SA<%}%>
		</a><br>
	<%}else if(strSchCode.startsWith("WNU") || strSchCode.startsWith("DBTC")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/statement_of_account_UI_main.jsp" target="feemainFrame">Student's SA</a><br>
	<%}else if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("CDD") || strSchCode.startsWith("CSA")) {%>
		<%if(!strSchCode.startsWith("FATIMA")){%>
			<img src="../../../images/broken_lines.gif"> <a href="../reports/admission_slip_main.jsp" target="feemainFrame">Admission Slip</a><br>
		<%}%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/statement_of_account.jsp" target="feemainFrame">Student's SA</a><br>
	<%}else if(strSchCode.startsWith("UB") || strSchCode.startsWith("PWC")) {%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/admission_slip_main.jsp" target="feemainFrame">Admission Slip</a><br>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/statement_of_account.jsp" target="feemainFrame">Student's SA</a><br>
	<%}else{%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/statement_of_account.jsp" target="feemainFrame">Student's SA</a><br>
	<%}%>
	<%if(strSchCode.startsWith("FATIMA") && (bolGrantAll || vAuthList.indexOf("REPORTS-ADMISSION SLIP") != -1 )){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/admission_slip_main.jsp" target="feemainFrame">Admission Slip</a><br>
	<%}%>
	<%if(strSchCode.startsWith("SPC")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/spc/clearance_slip_main_spc.jsp" target="feemainFrame">Clearance Slip</a><br>
	<%}%>
	<%if(strSchCode.startsWith("UB")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/clearance_account_slip_UB.jsp" target="feemainFrame">Clearance Slip</a><br>
	<%}%>
	
	<%
	if(strSchCode != null && strSchCode.startsWith("UI"))
		strTemp = "../reports/cert_enrol_billing_ched_ui.jsp";
	else
		strTemp = "../reports/cert_enrol_billing_ched.jsp";
	if(!bolIsLNU){%>
	<img src="../../../images/broken_lines.gif"> <a href="<%=strTemp%>" target="feemainFrame">Certificate of Enrolment and Billing (CHED)</a> <br>
	<%}if(strSchCode.startsWith("AUF") ){%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/auf_certification(scholarship).jsp" target="feemainFrame">Certification of Fees</a> 
	<br>
	<%}if(!bolIsLNU){%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/list_of_stud_educ_plans.jsp" target="feemainFrame">Students with Educational <br>Plans</a><br>
	<%}
	if(false){///use promisory note link
	%><img src="../../../images/broken_lines.gif"> <a href="../reports/list_stud_take_exam.jsp" target="feemainFrame">Students List for Examination</a><br>
	<%}%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/list_stud_paid_full.jsp" target="feemainFrame">Students Who Paid in FULL</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/list_stud_outstanding_refund.jsp" target="feemainFrame">Students With Outstanding Balance (OR) Refund</a><br>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/list_educational_assistance.jsp" target="feemainFrame">Students with Educational Assistance</a> <br>
	<%if(strSchCode.startsWith("SPC")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/periodic_account_balance_all.jsp" target="feemainFrame">Periodic Account Balance</a><br>
	<%}%>
	<%if(strSchCode.startsWith("AUF") || strSchCode.startsWith("UI") || strSchCode.startsWith("UDMC") || 
	strSchCode.startsWith("WNU") || strSchCode.startsWith("CLDH")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other_report_main.jsp" target="feemainFrame">Other Reports</a><br>
	<%}%>
	<%if(strSchCode.startsWith("EAC")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/other/other_report_main_eac.jsp" target="feemainFrame">Other Reports</a><br>
	<%}%>
	<%if(strSchCode.startsWith("WUP") || strSchCode.startsWith("UPH") || strSchCode.startsWith("CDD") || 
	strSchCode.startsWith("VMA") || strSchCode.startsWith("NEU") || strSchCode.startsWith("DLSHSI") || strSchCode.startsWith("HTC")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/other/other_report_main_fatima.jsp" target="feemainFrame">Other Reports</a><br>
	<%}%>
	<%if(strSchCode.startsWith("FATIMA") && (bolGrantAll || vAuthList.indexOf("REPORTS-OTHERS") != -1 )){%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/other/other_report_main_fatima.jsp" target="feemainFrame">Other Reports</a><br>
	<%}%>
	<%if(strSchCode.startsWith("PIT") || strSchCode.startsWith("WNU") || strSchCode.startsWith("UL") || strSchCode.startsWith("CIT") || 
		strSchCode.startsWith("UC") || strSchCode.startsWith("PWC") || strSchCode.startsWith("UB")){%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/other_report_main2.jsp" target="feemainFrame">Other Reports (2)</a> <br>
	<%}%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/external_payments.jsp" target="feemainFrame">List of External/Internal Payment</a> <br>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/list_student_payments.jsp" target="feemainFrame">List of Student Payment</a> <br>
	<%if(!bolIsLNU && false){//donot show to LNU.%>
	<img src="../../../images/broken_lines.gif"> <a href="../reports/list_basic_educ_payments.jsp" target="feemainFrame">List of Basic Educ Payments</a> <br>
	<%}if(strSchCode.startsWith("UI")){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/tuition_fee_compare.jsp" target="feemainFrame">Tuition Fee Comparison</a><br>
		<img src="../../../images/broken_lines.gif"> <a href="../student_ledger/ui_ledger_summary.jsp" target="feemainFrame">Print Student Ledger Summary</a><br>
	<%}%>
	<%if( strSchCode.startsWith("FATIMA") && bolGrantAll || true){%><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
		<img src="../../../images/broken_lines.gif"> <a href="../reports/courses_fees.jsp" target="feemainFrame">Course Fees</a></font><br>
	<%}%>
	<%if( strSchCode.startsWith("UB")){%><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/exam_permit_statistics_UB.jsp" target="feemainFrame">Admission Slip Statistics</a></font><br>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/ub/trust_fund_collection_report.jsp" target="feemainFrame">Trust fund Collection Summary</a></font><br>
	<%}%>
	<%if( strSchCode.startsWith("UC")){%>
		<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<img src="../../../images/broken_lines.gif"> <a href="../payment/enrollment_receipt_print_uc_batch_main.jsp" target="feemainFrame">Final Class Schedule</a>
		</font><br>
	<%}%>
	<%if( strSchCode.startsWith("DLSHSI")){%>
		<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<img src="../../../images/broken_lines.gif"> <a href="../../registrar/reports/other/dlshsi/monitoring_and_budgeting_report.jsp" target="feemainFrame">Monitoring and Budget</a>
		</font><br>
	<%}%>
<%}//show if not teller.%>
</font> </span> 

<%if( false && (strSchCode.startsWith("UI") || strSchCode.startsWith("WNU") || strSchCode.startsWith("EAC")) && bolGrantAll){%><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<img src="../../../images/arrow_blue.gif"> <a href="../close_sy_ledg/close_sy_ledg.jsp" target="feemainFrame">Close SY-Term (Finalize Ledger)</a></font><br>
<%}%>
<%if(strSchCode.startsWith("SPC") && bolGrantAll){%><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<img src="../../../images/arrow_blue.gif"> <a href="../reports/spc/fee_map_main.jsp" target="feemainFrame">Fee Collection Report (Accounting)</a></font><br>
<%}%>

<%}
if(!bolIsLNU && !strSchCode.startsWith("CIT"))
	if(bolGrantAll || vAuthList.indexOf("LISTING FOR EXAMINATION") != -1){isAuthorized=true;%>
<div> <img src="../../../images/arrow_blue.gif"  border="0" > 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../fee_assess_pay/listing_for_exam/list_stud_take_exam.jsp" target="feemainFrame">LISTING FOR EXAMINATION</a> </font></strong></div>

<%}
if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("AUF") || strSchCode.startsWith("CIT") || strSchCode.startsWith("UB") || strSchCode.startsWith("DLS")){
	if(bolGrantAll || vAuthList.indexOf("BANK UPLOAD") != -1){isAuthorized=true;%>
		
	<div class="trigger" onClick="showBranch('branch19');swapFolder('folder19')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder19">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">BANK UPLOAD</font></strong></div>
	<span class="branch" id="branch19"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		
		<%if(strSchCode.startsWith("CIT")){%>
			<img src="../../../images/broken_lines.gif"> <a href="../../fee_assess_pay/payment/payment_post_temporary.jsp" target="feemainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Post Bank Payment(temporary)</font></a><br>
			<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/invalidate_payment.jsp" target="feemainFrame">View/Remove Temporary/Permanent Bank Posting</a><br>
			<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/temp_posting_management.jsp" target="feemainFrame"> Non-Posting Payments Mgmt</a><br>
			<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/payment_posting.jsp" target="feemainFrame">Payment Posting</a> <br>
			<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/batch_print_or.jsp" target="feemainFrame">Batch Print OR</a> <br>
			<img src="../../../images/broken_lines.gif"> <a href="../payment/otherschoolfees_new.jsp?show_bank_post=1" target="feemainFrame">Bank Posting For Non-Tuition</a> <br>
			<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/report_invalidated_payment.jsp" target="feemainFrame">Bank Posting List(Report)</a> <br>
			<img src="../../../images/broken_lines.gif"> <a href="../payment/sponsor_payment_new.jsp" target="feemainFrame">Sponsor Payment For Student</a><br>
		<%}else if(strSchCode.startsWith("UB") || strSchCode.startsWith("DLS")){%>
			<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/invalidate_payment.jsp" target="feemainFrame">View/Remove Temporary/Permanent Bank Posting</a><br>
		<%}else{%>
			<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/upload_bank_details.jsp" target="feemainFrame"> Bank Upload</a><br>
			<%if(strSchCode.startsWith("FATIMA")){%>
				<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/payment_posting.jsp" target="feemainFrame">List of Failed Bank Upload</a><br>
				<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/invalidate_payment.jsp" target="feemainFrame">View/Remove Temporary/Permanent Bank Posting</a><br>
			<%}if(strSchCode.startsWith("AUF")){%>
			<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/payment_posting.jsp" target="feemainFrame">Payment Posting</a> <br>
			<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/batch_print_or.jsp" target="feemainFrame">Batch Print OR</a> <br>
			<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/transmittal_report.jsp" target="feemainFrame"> Transmittal Report</a><br>
			<%}%>
				<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/edit_id_number.jsp" target="feemainFrame"> ID Number Editing</a><br>
				<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/temp_posting_management.jsp" target="feemainFrame"> Non-Posting Payments Mgmt</a><br>
			<%if(strSchCode.startsWith("FATIMA")){%>
				<img src="../../../images/broken_lines.gif"> <a href="../bank_upload/view_temp_post_removed.jsp" target="feemainFrame">View Deleted Temp Bank Posting</a><br>
			<%}%>
	    <%}//do not show for CIT.. %>
	
	</font></span>
<%}
}
if(strSchCode.startsWith("FATIMA")){%>
<div>  
	<%if(bolGrantAll || vAuthList.indexOf("TEMPORARY BANK POSTING") != -1){%>
	  	<img src="../../../images/arrow_blue.gif"  border="0" > <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../payment/payment_post_temporary_ledger.jsp" target="feemainFrame">TEMPORARY BANK POSTING</a> </font></strong><br>
	<%}if(bolGrantAll || vAuthList.indexOf("BOOKSTORE BANK POSTING") != -1){%>
  		<img src="../../../images/arrow_blue.gif"  border="0" > <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../payment/payment_post_temporary_ledger_bookstore.jsp" target="feemainFrame">BOOKSTORE BANK POSTING</a> </font></strong><br>
	<%}if(bolGrantAll || vAuthList.indexOf("PROMISORY NOTE") != -1){%>
		<img src="../../../images/arrow_blue.gif"  border="0" > <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../reports/promi_main.jsp" target="feemainFrame">PROMISORY NOTE</a></font></strong><br>
	<%}if(bolGrantAll || vAuthList.indexOf("REPORTS-ADMISSION SLIP") != -1){%>
		<img src="../../../images/arrow_blue.gif"  border="0" > <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../reports/admission_slip_main.jsp" target="feemainFrame">Admission Slip</a></font></strong><br>
	<%}if(bolGrantAll || vAuthList.indexOf("PERMANENT BANK POSTING") != -1){%>
  		<img src="../../../images/arrow_blue.gif"  border="0" > <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../payment/payment_post_perm_ledger.jsp" target="feemainFrame">PERMANENT BANK POSTING</a> </font></strong><br>
	<%}if(bolGrantAll || vAuthList.indexOf("VIEW BANK UPLOAD") != -1){%>
  		<img src="../../../images/arrow_blue.gif"  border="0" > <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../bank_upload/invalidate_payment.jsp?show_report=1" target="feemainFrame">BANK POSTING REPORT</a> </font></strong><br>
	<%}%>
  </div>
<%}
if(strSchCode.startsWith("UB")){%>
<div>  
	<%if(bolGrantAll || vAuthList.indexOf("PROMISORY NOTE") != -1){%>
		<img src="../../../images/arrow_blue.gif"  border="0" > <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../reports/promi_main.jsp" target="feemainFrame">PROMISORY NOTE</a></font></strong><br>
	<%}%>
  </div>
<%}
if(strSchCode.startsWith("CIT") || strSchCode.startsWith("UB") || strSchCode.startsWith("DLS")){%>
<div>  
  <img src="../../../images/arrow_blue.gif"  border="0" > <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../payment/payment_post_perm_ledger.jsp" target="feemainFrame">PERMANENT BANK POSTING</a> </font></strong><br>
  </div>
<%}

if((strSchCode.startsWith("CSA") || strSchCode.startsWith("FATIMA") || strSchCode.startsWith("WUP")) && !bolGrantAll && vAuthList.indexOf("PAYMENT-FEE ADJUSTMENT") != -1){isAuthorized=true;%>
<div> <img src="../../../images/arrow_blue.gif"  border="0" > 
  	<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../payment/fee_adjustment.jsp" target="feemainFrame"> Fee Adjustments</a> </font></strong></div>
<%}
if(strSchCode.startsWith("CSA")){isAuthorized=true;%>
	<div> <img src="../../../images/arrow_blue.gif"  border="0" > 
 		<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../reports/statement_of_account.jsp" target="feemainFrame">STATEMENT OF ACCOUNT</a> </font></strong>
	</div>
<%}
if(strSchCode.startsWith("UL") || strSchCode.startsWith("SPC")){%>
	<font style="font-size:12px; color:#FFFFFF; font-family:Geneva, Arial, Helvetica, sans-serif; font-weight:bold">
	<%if(!bolGrantAll && vAuthList.indexOf("REPORTS") == -1 && vAuthList.indexOf("REPORTS-CASHIER REPORT") != -1){isAuthorized=true;%>
		<div>
			<img src="../../../images/arrow_blue.gif" border="0">  <a href="../reports/cashier_report_main.jsp" target="feemainFrame">Cashier's Report</a> 
		</div>
	<%}if(!bolGrantAll && vAuthList.indexOf("REPORTS") == -1 && vAuthList.indexOf("REPORTS-EDUCATIONAL ASSISTANCE") != -1){isAuthorized=true;%>
		<div>
			<img src="../../../images/arrow_blue.gif" border="0"> <a href="../reports/list_educational_assistance.jsp" target="feemainFrame">Students with Educational Assistance</a> 
		</div>
	<%}if(!bolGrantAll && vAuthList.indexOf("PAYMENT") == -1 && vAuthList.indexOf("PAYMENT-FEE ADJUSTMENT") != -1){isAuthorized=true;%>
		<div>
			<img src="../../../images/arrow_blue.gif" border="0"> <a href="../payment/fee_adjustment.jsp" target="feemainFrame">Fee Adjustment</a> 
		</div>
	<%}if(!bolGrantAll && vAuthList.indexOf("PAYMENT MAINTENANCE-FEE ADJUSTMENT TYPE") != -1){isAuthorized=true;%>
		<div>
			<img src="../../../images/arrow_blue.gif" border="0"> <a href="../fee_maintenance/fm_main_page.jsp?operation=5" target="feemainFrame">Fee Adjustment Type</a> 
		</div>
	<%}if(!bolGrantAll && vAuthList.indexOf("PAYMENT") == -1 && vAuthList.indexOf("PAYMENT-DEBIT CREDIT") != -1){isAuthorized=true;%>
		<div>
			<img src="../../../images/arrow_blue.gif" border="0"> <a href="../payment/refunds.jsp" target="feemainFrame">Refund/Debit/Credit</a> 
		</div>
	<%}%>
	</font>
<%}
if(strSchCode.startsWith("CIT")){
	if(bolGrantAll || vAuthList.indexOf("LOCK ADVISING") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch20');swapFolder('folder20')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder20">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Block/Unblock Advising</font></strong></div>
	<span class="branch" id="branch20"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		<img src="../../../images/broken_lines.gif"> <a href="../../enrollment/advising_dept_lock/lock_stud.jsp" target="feemainFrame">Block/Unblock - College</a> <br>
		<img src="../../../images/broken_lines.gif"> <a href="../../enrollment/advising_dept_lock/lock_stud.jsp?is_basic=1" target="feemainFrame">Block/Unblock - Grade School</a> <br>
		<img src="../../../images/broken_lines.gif"> <a href="../../enrollment/advising_dept_lock/unlock_stud.jsp" target="feemainFrame">Unblocked Student Listing</a> <br>
	</font></span>
<%}
	if(bolGrantAll || vAuthList.indexOf("EXAM PERMIT") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch21');swapFolder('folder21')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder21">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Exam Permit</font></strong></div>
	<span class="branch" id="branch21"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
	<%if(bolGrantAll || vAuthList.indexOf("EXAM PERMIT-TEMP PERMIT") != -1){%>
			<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/exam_permit_temp_main.jsp" target="feemainFrame">Issue Temporary Permit</a> <br>
	<%}if(bolGrantAll || vAuthList.indexOf("EXAM PERMIT-PRINT") != -1){%>
			<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/exam_permit_main.jsp" target="feemainFrame">Print Admission slip</a> <br>
	<%}if(bolGrantAll || vAuthList.indexOf("EXAM PERMIT-ALLOW REPRINT") != -1){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/exam_permit_allow_second_copy.jsp" target="feemainFrame">Allow Printing Admission Slip</a> <br>
	<%}%>
	<%if(bolGrantAll || vAuthList.indexOf("EXAM PERMIT-STATISTICS") != -1){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/exam_permit_statistics.jsp" target="feemainFrame">Admission Slip Statistics</a> <br>
	<%}%>
	<%if(bolIsETO){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/exam_permit_report_summary.jsp" target="feemainFrame">Other Reports</a> <br>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/exam_permit_list_main.jsp" target="feemainFrame">Exam Permit List</a> <br>
	<%}%>
	</font></span>

<%}
	if(bolGrantAll || vAuthList.indexOf("OTHER EXCEPTION") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch22');swapFolder('folder22')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder22">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Other Exception</font></strong></div>
	<span class="branch" id="branch22"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/temp_enrollment_permit.jsp" target="feemainFrame">Temporary Enrollment Permit</a> <br>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/override_testfee.jsp" target="feemainFrame">Override Test Fee</a> <br>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/promisory_note_downpayment.jsp" target="feemainFrame">Promisory Note for Downpayment</a><br>
		<img src="../../../images/broken_lines.gif"> <a href="../../admission/old_student_info_mgmt_main.htm" target="feemainFrame">Create Old Student Information</a><br>
		<!--
			<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/exam_permit_main.jsp" target="feemainFrame">Override Testing Fee</a> <br>
		-->
	</font></span>
<%}if(bolGrantAll || vAuthList.indexOf("SPONSOR") != -1){isAuthorized=true;%>
		<div><b><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<img src="../../../images/arrow_blue.gif" border="0"> <a href="../sponsor/manage_sponsor.jsp" target="feemainFrame">Sponsor Management</a> 
			</font></b>
		</div>


<%}

}
if(strSchCode.startsWith("SWU")){
	if(bolGrantAll || vAuthList.indexOf("EXAM PERMIT") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch21');swapFolder('folder21')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder21">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Exam Permit</font></strong></div>
	<span class="branch" id="branch21"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
	<%if(bolGrantAll || vAuthList.indexOf("EXAM PERMIT-TEMP PERMIT") != -1){%>
			<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/exam_permit_temp_main.jsp" target="feemainFrame">Issue Temporary Permit</a> <br>
	<%}if(bolGrantAll || vAuthList.indexOf("EXAM PERMIT-PRINT") != -1){%>
			<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/exam_permit_main.jsp" target="feemainFrame">Print Admission slip</a> <br>
	<%}if(bolGrantAll || vAuthList.indexOf("EXAM PERMIT-ALLOW REPRINT") != -1){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/exam_permit_allow_second_copy.jsp" target="feemainFrame">Allow Printing Admission Slip</a> <br>
	<%}%>
	<%if(bolGrantAll || vAuthList.indexOf("EXAM PERMIT-STATISTICS") != -1){%>
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/cit/exam_permit_statistics.jsp" target="feemainFrame">Admission Slip Statistics</a> <br>
	<%}%>
	</font></span>

<%}
}


if(strSchCode.startsWith("SPC")){%>
	<div> <img src="../../../images/arrow_blue.gif"  border="0" > 
 		<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../reports/statement_of_account.jsp" target="feemainFrame">STATEMENT OF ACCOUNT</a> </font></strong>
	</div>
<%
	if(bolGrantAll || vAuthList.indexOf("SPONSOR") != -1){isAuthorized=true;%>
		<div><b><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<img src="../../../images/arrow_blue.gif" border="0"> <a href="../sponsor/manage_sponsor.jsp" target="feemainFrame">Sponsor Management</a> 
			</font></b>
		</div>
		<div><b><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<img src="../../../images/arrow_blue.gif" border="0"> <a href="../payment/sponsor_payment_new.jsp" target="feemainFrame">Sponsor Payment</a> 
			</font></b>
		</div>


<%}

}
if(!strSchCode.startsWith("CIT")){
	if(bolGrantAll || vAuthList.indexOf("OTHER EXCEPTION") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch22');swapFolder('folder22')"> <img src="../../../images/box_with_plus.gif"  border="0" id="folder22">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Other Exception</font></strong></div>
	<span class="branch" id="branch22"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		<img src="../../../images/broken_lines.gif"> <a href="../reports/other/ub/otr_print_exception.jsp" target="feemainFrame">OTR Print Payment Exception</a> <br>
	</font></span>
<%}
}
if(strSchCode.startsWith("NEU")){
	if(bolGrantAll || vAuthList.indexOf("SPONSOR") != -1){isAuthorized=true;%>
		<div><b><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<img src="../../../images/arrow_blue.gif" border="0"> <a href="../sponsor/manage_sponsor.jsp" target="feemainFrame">Sponsor Management</a> 
			</font></b>
		</div>
		<div><b><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<img src="../../../images/arrow_blue.gif" border="0"> <a href="../payment/sponsor_payment_new.jsp" target="feemainFrame">Sponsor Payment</a> 
			</font></b>
		</div>
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
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>
