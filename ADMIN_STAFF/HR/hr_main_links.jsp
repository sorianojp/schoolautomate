<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false; boolean bolIsGovt = false;

if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;

if( (new ReadPropertyFile().getImageFileExtn("IS_GOVERNMENT","0")).equals("1"))
	bolIsGovt = true;

String[] strColorScheme = CommonUtil.getColorScheme(5);

//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Main Links</title>
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
<link href="../../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[0]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<body bgcolor="#C39E60" onLoad="MM_preloadImages('../../images/home_small_admin_rollover.gif','../../images/help_small_admin_rollover.gif','../../images/logout_admin_rollover.gif')" class="bgDynamic">
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
    <td width="10%" height="19" bgcolor="#E9E0D1">&nbsp;</td>
    <td width="90%" bgcolor="#E9E0D1">
	<a href="<%if(bolIsSchool){%>../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm<%}else{%>../../index.jsp<%}%>" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
	<input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
  </tr>
  </table>
<input type="hidden" name="logout_url" value="<%if(bolIsSchool){%>../ADMIN_STAFF/main%20files/admin_staff_bottom_content.htm<%}else{%>../index.jsp<%}%>">
<input type="hidden" name="body_color" value="#C39E60">
</form>
<%
//check if user is logged in, if logged, check authentication list here and allow the authentic user to access the system.
DBOperation dbOP = null;
CommonUtil comUtil = new CommonUtil();
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strErrMsg = null;
boolean bolGrantAll = false;
boolean isAuthorized = false;
//boolean bolUseRange = false;
String strLeaveCreditSched = "2";
boolean bolShowLinks = false;
if(strUserId != null){
	if(strUserId.toUpperCase().equals("BRICKS"))
		bolShowLinks = true;
	//open dbConnection here to check if user is registered already.
	try
	{
		dbOP = new DBOperation();
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		//bolUseRange = (readPropFile.getImageFileExtn("LEAVE_SCHEDULER","0")).equals("1");
		strLeaveCreditSched = readPropFile.getImageFileExtn("LEAVE_SCHEDULER","0");
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

Vector vAuthList = null;
if(!bolGrantAll) {
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, "HR Management");
	if(vAuthList == null)
		vAuthList = new Vector();
	else if( ((String)vAuthList.elementAt(0)).compareTo("#ALL#") == 0)
		bolGrantAll = true;
}
//old way of calling..
//comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Enrollment","ROOMS MONITORING")!=0
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String strInfo5 = (String)request.getSession(false).getAttribute("info5");

if(strSchCode == null)
	strSchCode = "";
if(strUserId == null)
	strUserId = "";


//I need to add some more authentication for CLDH for 201 and offenses.
boolean bolAllow201     = true;
boolean bolAllowOffense = true;
if(!bolGrantAll){
	if(vAuthList.indexOf("PERSONNEL-201") == -1)
		bolAllow201 = false;

	if(strSchCode.startsWith("CLDH") && vAuthList.indexOf("PERSONNEL-OFFENSE") == -1)
		bolAllowOffense = false;
}

boolean bolHasTeam = new ReadPropertyFile().getImageFileExtn("HAS_TEAMS","0").equals("1");

//boolean bolHavingTeam = false;
//if(strSchCode.startsWith("TSUNEISHI") || strSchCode.startsWith("CEBUEASY"))
//	bolHavingTeam = true;
	

if(bolGrantAll || vAuthList.indexOf("PERSONNEL") != -1){isAuthorized=true;%>	
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">PERSONNEL</font></strong></div>
<span class="branch" id="branch1"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<%if(bolAllow201){%>
	<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_201_file.jsp" target="HRmainFrame"> 201 File</a><br>
	<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_201_file_batch_search.jsp" target="HRmainFrame"> 201 File (Batch Print)</a><br>
<%}if (bolGrantAll){
	if(bolHasTeam) {%>
	<img src="../../images/broken_lines.gif"> <a href="../accounting/billing/ac_team_mgmt.jsp" target="HRmainFrame">Manage Team</a><br>
<%}if(strSchCode.startsWith("TSUNEISHI")){%>
	<img src="../../images/broken_lines.gif"> <a href="./personnel/hiring_batch_main.jsp" target="HRmainFrame">Manage Hiring Batch</a><br>
<%}
}%>
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_personal_data.jsp?uncheck_is_valid=1" target="HRmainFrame">Personal Data</a><br>
<%if(strSchCode.startsWith("AUF")){%>
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_job_descr_main.jsp" target="HRmainFrame">Job Description</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_contact_main.jsp" target="HRmainFrame">Contact Info</a><br>
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_sp_child.jsp" target="HRmainFrame">Spouse / Children's Data</a> <br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_employment.jsp" target="HRmainFrame">Previous Employment </a><br>
<%if(!strSchCode.startsWith("DEPED")){%>
	<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_service_rec.jsp" target="HRmainFrame">Service Record</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_education.jsp" target="HRmainFrame">Education</a><br>
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_awards_etc.jsp" target="HRmainFrame">Awards/Citations/<br> Recognitions</a> <br>
<% if (strSchCode.startsWith("AUF")){%>
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_research_etc_auf.jsp" target="HRmainFrame">Scholarships/Research 
<br>
Works </a>
<%}else{%>
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_research_etc.jsp" target="HRmainFrame">Scholarships/Research 
<br>
Works </a>
<%}%>
<br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_licenses.jsp" target="HRmainFrame">Licenses</a> <br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_exams.jsp" target="HRmainFrame">Exams Taken</a><br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_skills.jsp" target="HRmainFrame">Skills</a><br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_trainings.jsp" target="HRmainFrame">Trainings</a><br>
<%if(!strSchCode.startsWith("TSUNEISHI")){%>
	<img src="../../images/broken_lines.gif">
		<%if(!strSchCode.startsWith("DBTC")){%>
			<a href="./personnel/hr_employee_logout.jsp" target="HRmainFrame">Official <% if (strSchCode.startsWith("AUF")){%>Logout<%}else{%>Business<%}%></a><br>
		<%}else{%>
			<a href="./personnel/hr_OB_main_page.jsp" target="HRmainFrame">Official Business</a><br>
		<%}%>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_language.jsp" target="HRmainFrame">Languages</a><br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_affiliations.jsp" target="HRmainFrame">Group Affiliations</a> <br>
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_x_act_ser.jsp" target="HRmainFrame">
<% if (strSchCode.startsWith("CPU")){%>Extra Services/Committee Work<%}else{%>Extra Activities/Services<%}%> </a> <br>
<!--
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_leave_summary.jsp" target="HRmainFrame">Leave 
Summary </a><br>
-->
<%if(bolAllowOffense){%>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_offenses.jsp" target="HRmainFrame">Offenses</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> 
<% if(strSchCode.startsWith("CPU")) {%> <a href="./personnel/hr_exit_interview.jsp" target="HRmainFrame">Separation 
<%}else if(strSchCode.startsWith("LHS")){%>
	<a href="./exit_interview/exit_intv_main.jsp" target="HRmainFrame">Exit Interview / Separation 
<%}else{%>
	<a href="./personnel/hr_exit_interview.jsp" target="HRmainFrame">Exit Interview / Separation 
<%}%></a><br>
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_rehire_employee.jsp" target="HRmainFrame"> Re-Hire Employee </a><br>
<img src="../../images/broken_lines.gif"> <a href="../admission/upload_id_step1.jsp?hr_emp=1" target="HRmainFrame">Upload Employee Picture</a><br>
<img src="../../images/broken_lines.gif"> <a href="../user_admin/barcode_mgmt.jsp" target="HRmainFrame">Assign RFID to Employee ID</a><br>
<%if (bolIsSchool) {%> 
<img src="../../images/broken_lines.gif"> <a href="../enrollment/faculty/faculty_subj_list_load.jsp" target="HRmainFrame">Subjects To Handle</a><br>
<%} if (!strSchCode.startsWith("AUF") || true) {
	if(bolGrantAll || vAuthList.indexOf("Personnel-Salary/Benefit/Incentive Management".toUpperCase()) != -1){%> 
<img src="../../images/broken_lines.gif"> <a href="personnel/sal_ben_incent_mgmt_main.jsp" target="HRmainFrame">Salary/Benefits/Incentives Mgmt </a><br>
<%}
}%>
<% if(strSchCode.startsWith("TAMIYA")) {%>
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_notice_of_action.jsp" target="HRmainFrame">Notice of Personnel Action </a><br> 
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_perf_appraisal.jsp" target="HRmainFrame">Performance Appraisal Form </a><br> 
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_perf_appraisal_period.jsp" target="HRmainFrame">Appraisal Period Mgmt</a> <br>
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_perf_appraisal_setting.jsp" target="HRmainFrame">Performance Appraisal Setting</a><br>
<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_perf_appraisal_summary.jsp" target="HRmainFrame">Performance Appraisal Summary </a><br>
<%}
if(strSchCode.startsWith("TAMIYA") || strSchCode.startsWith("AUF")) {%>
<img src="../../images/broken_lines.gif"> <a href="download_mgmt/hr_download_link_mgmt.jsp" target="HRmainFrame">HR Forms Download Management</a><br>
<%}
if(strSchCode.startsWith("UPH") && strInfo5 == null) {%>
	<img src="../../images/broken_lines.gif"> <a href="../fee_assess_pay/reports/employee_discount_application.jsp" target="HRmainFrame">Employee Discount Application</a><br>
	<img src="../../images/broken_lines.gif"> <a href="../payroll/reports/uph/hr_personnel_set_retiring_uph.jsp" target="HRmainFrame">Tag Employee as Retiring</a><br>
<%}%>
</font></span> 
<%}
	String strTemp = null;
	
 if(strSchCode.startsWith("UI") || strSchCode.startsWith("PIT") || strSchCode.startsWith("DEPED") || strUserId.compareTo("1770") == 0) 
 if(bolGrantAll || vAuthList.indexOf("OLD SERVICE RECORD MGMT") != -1){isAuthorized=true;
 if(strSchCode.startsWith("UI"))
 	strTemp = "old_service_record_mgmt.jsp";
 else	
 	strTemp = "pit/govt_old_service_rcd.jsp";
 %>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
  <a href="./old_service_record_mgmt/<%=strTemp%>" target="HRmainFrame"><%if(!strSchCode.startsWith("DEPED")){%>OLD <%}%>SERVICE RECORD MGMT </a> </font></strong><br>
<%}
if(strSchCode.startsWith("TSUNEISHI")){
	if(bolGrantAll || vAuthList.indexOf("OFFICIAL BUSINESS") != -1){isAuthorized=true;
%>
	<img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
	  <a href="./personnel/hr_employee_logout.jsp" target="HRmainFrame">Official Business </a> </font></strong><br>
<%}
}

if(!bolIsSchool && ( strSchCode.startsWith("LHS") || strSchCode.startsWith("CLC") || strSchCode.startsWith("CEBUEASY") ) ) {//show only for specific client.. 
	if(bolGrantAll || vAuthList.indexOf("PERSONNEL ASSET MANAGEMENT") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch11');swapFolder('folder11')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder11">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">PERSONNEL ASSET MANAGEMENT </font></strong></div>
	<span class="branch" id="branch11"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
	<img src="../../images/broken_lines.gif"> <a href="./personnel_asset_mgmt/asset_items/create_item.jsp" target="HRmainFrame">Asset Registry</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./personnel_asset_mgmt/asset_items/pam_item_registry.jsp" target="HRmainFrame">Item Registry</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./personnel_asset_mgmt/issue_assets/issue_assets.jsp" target="HRmainFrame">Issue Asset</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./personnel_asset_mgmt/issued_assets_status/issued_asset_status.jsp" target="HRmainFrame">Return Status</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./personnel_asset_mgmt/update_item_status.jsp" target="HRmainFrame">Update Asset Status</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./personnel_asset_mgmt/search_item.jsp" target="HRmainFrame">Search</a><br>
	</font> </span>
<%}
}

if (!bolIsSchool || strUserId.equals("1770")) {
if(bolGrantAll || vAuthList.indexOf("CLEARANCE") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch19');swapFolder('folder19')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder19">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CLEARANCE</font></strong></div>
<span class="branch" id="branch19"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"><a href="clearance/hr_clearance_post.jsp" target="HRmainFrame"> For Clearance </a><br>
<img src="../../images/broken_lines.gif"><a href="clearance/hr_clearance_clear.jsp" target="HRmainFrame"> Update Clearance</a><br>
<img src="../../images/broken_lines.gif"><a href="clearance/hr_view_clearance_status.jsp" target="HRmainFrame"> View Clearance Status</a><br>
<img src="../../images/broken_lines.gif"><a href="clearance/hr_clearance_search.jsp" target="HRmainFrame"> Search Clearance</a></font><br></span>
<%}if(bolGrantAll || vAuthList.indexOf("HEALTH INSURANCE MANAGEMENT") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch20');swapFolder('folder20')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder20">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">HEALTH INSURANCE MANAGEMENT</font></strong></div>
<span class="branch" id="branch20"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"><a href="./health_insurance/health_insurance_application.jsp" target="HRmainFrame"> Application and Tracking </a><br>
<img src="../../images/broken_lines.gif"><a href="health_insurance/health_insurance_details.jsp" target="HRmainFrame"> Update Insurance Usage</a><br>
<img src="../../images/broken_lines.gif"><a href="health_insurance/health_insurance_copy.jsp" target="HRmainFrame"> Copy Previous Record</a><br></font></span>
<%}
}
if(bolGrantAll || vAuthList.indexOf("REQUEST FOR TRAININGS") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">REQUEST FOR TRAININGS </font></strong></div>
<span class="branch" id="branch2"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"> <a href="./request_training/training_request_application.jsp" target="HRmainFrame">Application</a><br>
<img src="../../images/broken_lines.gif"> <a href="./request_training/training_request_application_view.jsp" target="HRmainFrame">Search 
Application</a><br>
</font> </span>

<%}if(bolGrantAll || vAuthList.indexOf("LEAVE APPLICATION") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">LEAVE APPLICATION </font></strong></div>
<span class="branch" id="branch4"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<%if(bolIsGovt){%>
<img src="../../images/broken_lines.gif"> <a href="leave/leave_signatories.jsp" target="HRmainFrame">Leave Signatories</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="leave/leave_setting.jsp" target="HRmainFrame">Leave Setting</a><br>
<img src="../../images/broken_lines.gif"> <a href="leave/leave_apply.jsp" target="HRmainFrame">Application</a><br>
<%if (strSchCode.startsWith("AUF")){%> 
<img src="../../images/broken_lines.gif"> <a href="./reports/hr_leave_summary_auf.jsp" target="HRmainFrame">Leave Summary</a><br>
<%}else{%>
<img src="../../images/broken_lines.gif"> <a href="leave/leave_summary.jsp" target="HRmainFrame">Leave Summary</a><br>
<%}%>
<!--
<%// if (strSchCode.startsWith("AUF") || strUserId.equals("dang")){%> 
<img src="../../images/broken_lines.gif"> <a href="leave/leave_auto_apply.jsp" target="HRmainFrame">Auto Create Leave Credits</a><br>
<%//}%>
-->
<img src="../../images/broken_lines.gif"> <a href="leave/leave_encoding.jsp" target="HRmainFrame">Manual Leave Update</a><br>
<img src="../../images/broken_lines.gif"> <a href="leave/leave_auto_apply.jsp" target="HRmainFrame">Apply leave credit</a><br>
<%if(strLeaveCreditSched.equals("1") || strLeaveCreditSched.equals("3")){%>
<img src="../../images/broken_lines.gif"> <a href="leave/leave_schedule_update.jsp" target="HRmainFrame">Schedule leave credit</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="leave/leave_interval_start.jsp" target="HRmainFrame"> Start of Leave Interval</a><br>
<!--
<img src="../../images/broken_lines.gif"> <a href="assessment/hr_assessment_sheet_mgmt_main.jsp" target="HRmainFrame">Update 
Application</a><br>
<img src="../../images/broken_lines.gif"> <a href="assessment/hr_assessment_ranking.jsp" target="HRmainFrame">View/Edit 
Application </a>
-->
<%if(strSchCode.startsWith("DEPED")){%>
	<img src="../../images/broken_lines.gif"> <a href="leave/must_work.jsp" target="HRmainFrame"> Employee Leave Exception</a><br>
<%}%>	
</font> </span>

<%}if(!bolIsGovt && (bolGrantAll || vAuthList.indexOf("ASSESSMENT AND EVALUATION") != -1) ){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder5">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ASSESSMENT AND EVALUATION</font></strong></div>
<span class="branch" id="branch5"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<% if (strSchCode.startsWith("TSUNEISHI")){%>
	<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_perf_appraisal_tsuneishi.jsp" target="HRmainFrame">Technical Evaluation</a><br>
	<img src="../../images/broken_lines.gif"> <a href="personnel/hr_personnel_perf_appraisal_tun_nontechnical.jsp" target="HRmainFrame">Non-Technical Evaluation</a><br>
<%}else{%>
	
	<img src="../../images/broken_lines.gif"> <a href="assessment/hr_assessment_mgmt.jsp" target="HRmainFrame">Evaluation Criteria Management</a><br>
<% if (strSchCode.startsWith("VMA")){%>	
	<img src="../../images/broken_lines.gif"><a href="../guidance/cit_fac_eval/manage_eval_point.jsp" target="HRmainFrame"> Manage Evaluation Point</a><br>	
<%}%>	
	<img src="../../images/broken_lines.gif"> <a href="assessment/hr_assessment_sheet_mgmt_main.jsp" target="HRmainFrame">Evaluation Sheet Management</a><br>
<% if (!strSchCode.startsWith("VMA")){%>	
	<img src="../../images/broken_lines.gif"> <a href="assessment/hr_assessment_ranking.jsp" target="HRmainFrame">Ranking System</a><br>
	<img src="../../images/broken_lines.gif"> <a href="assessment/hr_assessment_main.jsp" target="HRmainFrame">Assessment And Evaluation</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./assessment/final_assessment_main.jsp" target="HRmainFrame">Final Assessment & Evaluation</a><br>
<%}else{%>
	<img src="../../images/broken_lines.gif"> <a href="./assessment/hr_assessment_view_evaluated_personnel.jsp" target="HRmainFrame">View Evaluated Personnel</a><br>
<%}
}%>
</font> </span>
<%}%>


<%if(bolIsGovt && 
	(bolGrantAll || vAuthList.indexOf("ASSESSMENT AND EVALUATION") != -1) ){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch12');swapFolder('folder12')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder12">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ASSESSMENT AND EVALUATION </font></strong></div>
	<span class="branch" id="branch12"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
		<img src="../../images/broken_lines.gif"> <a href="./govt_evaluation/activities_mgmt.jsp"  target="HRmainFrame">Work/Activities Management</a> <br>
		<img src="../../images/broken_lines.gif"> <a href="./govt_evaluation/quarterly_eval.jsp" target="HRmainFrame">Quarterly Performance Evaluation</a> <br>
		<img src="../../images/broken_lines.gif"> <a href="./govt_evaluation/create_review_period.jsp"  target="HRmainFrame">Rating Period Management</a> <br>
		<img src="../../images/broken_lines.gif"> <a href="./govt_evaluation/manage_rater_weights.jsp" target="HRmainFrame">Manage Rater Weights</a><br>
		<img src="../../images/broken_lines.gif"> <a href="./govt_evaluation/agency_perf_eval.jsp" target="HRmainFrame">Agency Performance Evaluation</a> 
	</font> </span>
<%}%>



<%if (false)
if(bolGrantAll || vAuthList.indexOf("CAREER DEVELOPMENT") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CAREER
  DEVELOPMENT</font></strong></div>
<span class="branch" id="branch6"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="../../ADMIN_STAFF/HR/career/hr_career_feedback_main.jsp" target="HRmainFrame">Upward Feedback </a><br>
<img src="../../images/broken_lines.gif"> <a href="career/hr_career_evaluation_main.jsp" target="HRmainFrame">Career Evaluation<br>(Teaching/Non-Teaching)</a><br>
<img src="../../images/broken_lines.gif"> <a href="../../ADMIN_STAFF/HR/career/hr_career_seminars.jsp" target="HRmainFrame">Seminar/Trainings</a><br>
<img src="../../images/broken_lines.gif"> <a href="../../ADMIN_STAFF/HR/career/hr_career_viewall.jsp" target="HRmainFrame">Career Evaluation Summary</a></font></span>
<%} 

if (!bolIsSchool || strUserId.equals("1770")) 
if(bolGrantAll || vAuthList.indexOf("TRAINING MANAGEMENT") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch9');swapFolder('folder9')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder9">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">TRAINING MANAGEMENT</font></strong></div>
<span class="branch" id="branch9"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="training/set_mandatory_training.jsp" target="HRmainFrame">Set Mandatory Training</a><br>
<img src="../../images/broken_lines.gif"> <a href="training/training_schedule.jsp"  target="HRmainFrame">Training Schedule</a><br>
<img src="../../images/broken_lines.gif"> <a href="training/training_attendance.jsp"  target="HRmainFrame">Training Attendance</a><br>
<img src="../../images/broken_lines.gif"> <a href="training/search.jsp"  target="HRmainFrame">Search</a>
 </font></span>
<%}if (strSchCode.startsWith("LHS") && bolGrantAll) {//show %>
<div class="trigger" onClick="showBranch('branch79');swapFolder('folder79')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder79">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">EVALUATIONS MANAGEMENT</font></strong></div>
<span class="branch" id="branch79"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="evaluations_mgmt/create_review_period.jsp"  target="HRmainFrame">Review Period Management</a> <br>
<img src="../../images/broken_lines.gif"> <a href="evaluations_mgmt/review_questions_mgmt.jsp"  target="HRmainFrame">Review Questions Management</a> <br>
<img src="../../images/broken_lines.gif"> <a href="evaluations_mgmt/evaluations_summary.jsp" target="HRmainFrame"> Evaluation Summary</a></font></span>
<%}if (bolShowLinks || (bolGrantAll && !bolIsSchool)) {//show %>
<div class="trigger" onClick="showBranch('branch80');swapFolder('folder80')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder80">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">MANPOWER MANAGEMENT</font></strong></div>
<span class="branch" id="branch80"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="manpower_mgmt/manpower_request.jsp"  target="HRmainFrame">Manpower Request</a> <br>
<img src="../../images/broken_lines.gif"> <a href="manpower_mgmt/approve_request.jsp"  target="HRmainFrame">Manpower Approval</a> <br>
<img src="../../images/broken_lines.gif"> <a href="manpower_mgmt/manpower_mapping.jsp"  target="HRmainFrame">Request Mapping</a> <br>
</font></span>
<%}if (!bolIsSchool || strUserId.equals("sa-01")) 
if(bolGrantAll || vAuthList.indexOf("MEMO MANAGEMENT") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch10');swapFolder('folder10')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder10">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">MEMO MANAGEMENT</font></strong></div>
<span class="branch" id="branch10"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="memo/create_memo_details.jsp" target="HRmainFrame">Set Memo Details </a><br>
<img src="../../images/broken_lines.gif"> <a href="memo/circulate_memo.jsp" target="HRmainFrame">Circulate Memo</a></font><br>
<font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"><img src="../../images/broken_lines.gif">&nbsp;<a href="memo/circular_memo.jsp" target="HRmainFrame">Memo Circular</a> </font><br>
<font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"><img src="../../images/broken_lines.gif">&nbsp;<a href="memo/employee_circular.jsp" target="HRmainFrame">Employee Circular</a> </font>

</span>
<%}if(bolGrantAll || vAuthList.indexOf("APPLICANTS DIRECTORY") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder7">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">APPLICANTS DIRECTORY </font></strong></div>
<span class="branch" id="branch7"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"> <a href="applicants/new_applicant_main.jsp" target="HRmainFrame">Profile</a><br>
<img src="../../images/broken_lines.gif"> <a href="../admission/upload_id_step1.jsp?hr_emp=2" target="HRmainFrame">Upload Applicant Picture</a><br>
<img src="../../images/broken_lines.gif"> <a href="./applicants/hr_applicant_201.jsp" target="HRmainFrame">Applicant Resume</a><br>
<img src="../../images/broken_lines.gif"> <a href="./applicants/hr_applicant_personal.jsp" target="HRmainFrame">Personal Data</a><br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_education.jsp?applicant_=1" target="HRmainFrame">Education</a> <br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_licenses.jsp?applicant_=1" target="HRmainFrame">Licenses</a> <br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_employment.jsp?applicant_=1" target="HRmainFrame"> Employment Record</a><br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_exams.jsp?applicant_=1" target="HRmainFrame">Exams Taken</a></font><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"><br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_skills.jsp?applicant_=1" target="HRmainFrame">Skills</a> <br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_trainings.jsp?applicant_=1" target="HRmainFrame">Trainings/Seminars</a></font><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"><br>
<img src="../../images/broken_lines.gif"> <a href="./personnel/hr_personnel_language.jsp?applicant_=1" target="HRmainFrame">Languages</a> 
<br>
<img src="../../images/broken_lines.gif"> <a href="./applicants/hr_applicant_reference.jsp" target="HRmainFrame">References</a><br>
<img src="../../images/broken_lines.gif"> <a href="./applicants/hr_applicant_assessment.jsp" target="HRmainFrame">Preliminary Interview Assessment</a><br>
<img src="../../images/broken_lines.gif"> <a href="./applicants/interview_result.jsp" target="HRmainFrame">Interview Result</a><br>
<img src="../../images/broken_lines.gif"> <a href="applicants/hr_applicant_viewall.jsp" target="HRmainFrame">View All Applicants</a><br>
<img src="../../images/broken_lines.gif"> <a href="applicants/confirm_applicant.jsp" target="HRmainFrame">Confirm Applicant to Employee</a><br>
</font></span> 

<%}if(bolGrantAll || vAuthList.indexOf("REPORTS AND STATISTICS") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">REPORTS
  AND STATISTICS</font></strong></div>
<span class="branch" id="branch8"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"> <a href="./reports/hr_stat_separating.jsp" target="HRmainFrame">Separating Employee Listing</a><br>
<%if(strSchCode.startsWith("AUF")){%> 
	<img src="../../images/broken_lines.gif"> <a href="../enrollment/faculty/reports/room_faculty_assignment.jsp" target="HRmainFrame">Attendance Monitoring Report</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./reports/hr_stat_separated_AUF.jsp" target="HRmainFrame">Separated Employees</a><br>
<%}else{%>
	<img src="../../images/broken_lines.gif"> <a href="./reports/hr_stat_separated.jsp" target="HRmainFrame">Separated Employees</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="./reports/hr_demo_dependents.jsp" target="HRmainFrame">Children</a><br>
<img src="../../images/broken_lines.gif"> <a href="./reports/hr_educ_reports.jsp" target="HRmainFrame">Education</a><br>
<img src="../../images/broken_lines.gif"> <a href="./reports/hr_stat_trainings.jsp" target="HRmainFrame">Trainings</a><br>
<img src="../../images/broken_lines.gif"> <a href="./reports/hr_stat_work_type.jsp" target="HRmainFrame">Research</a><br>
<img src="../../images/broken_lines.gif"> <a href="./reports/hr_offenses.jsp" target="HRmainFrame">Offenses </a><br>
<%if (!strSchCode.startsWith("AUF")) {%> 
<img src="../../images/broken_lines.gif"> <a href="./reports/hr_leave_summary.jsp" target="HRmainFrame">Leave Summary </a><br>
<img src="../../images/broken_lines.gif"> <a href="./reports/hr_emp_leaves.jsp" target="HRmainFrame">Leave Applications</a><br>
<%}%>
<%if(strSchCode.startsWith("AUF")){%> 
<img src="../../images/broken_lines.gif"> <a href="./reports/hr_leave_summary_auf.jsp" target="HRmainFrame">Leave Summary</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/hr_stat_work_type.jsp" target="HRmainFrame">Research</a><br>
<%}
if(strSchCode.startsWith("TAMIYA")){%>
	<img src="../../images/broken_lines.gif"> <a href="reports/hr_awards.jsp" target="HRmainFrame">Awards/Recognitions</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="reports/hr_skills_lang.jsp" target="HRmainFrame">Skills / Language</a><br>
<%
	if (bolIsSchool){
		if (strSchCode.startsWith("AUF"))
			strTemp = " / AUFRP";
		else
			strTemp = " / PERAA";
	}
	else
		strTemp = "";
%>
<img src="../../images/broken_lines.gif"> <a href="reports/hr_sss_tin_pag_report.jsp" target="HRmainFrame">SSS / TIN / PAG-IBIG<%=strTemp%></a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/hr_stat_logout_new.jsp" target="HRmainFrame">Official <% if (strSchCode.startsWith("AUF")){%>Logout<%}else{%>Business<%}%></a><br>
<% if (strSchCode.startsWith("AUF")){%> 
<img src="../../images/broken_lines.gif"> <a href="reports/senior_junior_demo/hr_junior_senior_demo.jsp" target="HRmainFrame">Senior / Junior Staff Demo</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/c_rank/hr_ranking_reranking.jsp" target="HRmainFrame">Ranking / Re-Ranking<br></a>
<img src="../../images/broken_lines.gif"> <a href="reports/benefits/hr_benefits.jsp" target="HRmainFrame">Benefits</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/certification/hr_certifications_auf.jsp" target="HRmainFrame">Certification</a><br>
<!--
<img src="../../images/broken_lines.gif"> <a href="reports/hr_faculty_qualifications.jsp" target="HRmainFrame">Faculty Education Profile </a><br>
-->
<%} if (!strSchCode.startsWith("AUF") && false){%> 
<img src="../../images/broken_lines.gif"> <a href="reports/certification/hr_cert_common_main.jsp" target="HRmainFrame">Certification</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="reports/hr_supervisory_listing.jsp" target="HRmainFrame"> Supervisory listing </a><br>
<img src="../../images/broken_lines.gif"> <a href="./reports/hr_demo_relationship.jsp" target="HRmainFrame">Employee relations</a><br>
<img src="../../images/broken_lines.gif"> <a href="./reports/hr_demo_affiliations.jsp" target="HRmainFrame">Group Affiliations</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/hr_demographic_profile.jsp" target="HRmainFrame">Demographic Reports</a><br>
<% if (strSchCode.startsWith("UI")) {%> 
<img src="../../images/broken_lines.gif"> <a href="reports/hr_demographic_profile_ui.jsp" target="HRmainFrame">Faculty Demographic Reports</a><br>
<%} if (strSchCode.startsWith("AUF")) {%> 
<img src="../../images/broken_lines.gif"> <a href="reports/hr_demographic_profile_rank.jsp" target="HRmainFrame">Length of Service</a><br>
<%}%>
<%if(bolIsSchool){%>
<img src="../../images/broken_lines.gif"> <a href="reports/hr_manpower_main.jsp" target="HRmainFrame">Manpower Stats</a><br>
<%}if(strSchCode.startsWith("DBTC") || strSchCode.startsWith("ILIGAN")){%>
	<img src="../../images/broken_lines.gif"> <a href="../user_admin/set_param/set_msg_user.jsp" target="HRmainFrame">Message System</a> <br>
<%}if(strSchCode.startsWith("UB")){%>
	<img src="../../images/broken_lines.gif"> <a href="reports/hr_employee_directory.jsp" target="HRmainFrame">Employee Directory</a> <br>
<%}%>
</font></span> 

<%}if(bolGrantAll || vAuthList.indexOf("SEARCH") != -1){isAuthorized=true;%>
<img src="../../images/arrow_blue.gif" border="0"><strong><a href="../../search/srch_emp_hr.jsp" target="HRmainFrame"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">SEARCH</font></a></strong><br></p></div>
<%}if(strSchCode.startsWith("UB") && (bolGrantAll || vAuthList.indexOf("ENCODE-FACULTY ABSENCES") != -1) ) {isAuthorized=true;%>
<img src="../../images/arrow_blue.gif" border="0"><strong><a href="../payroll/dtr/absences_encoding_main.jsp" target="HRmainFrame"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Encode Faculty Absences</font></a></strong><br></p></div>
<%}%>


<%if(bolShowLinks){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch100');swapFolder('folder100')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder100">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">DEVELOPER PAGES</font></strong></div>
<span class="branch" id="branch100"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">

</font> 
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
</body>
</html>
<%
if(dbOP != null)
	dbOP.cleanUP();
%>
