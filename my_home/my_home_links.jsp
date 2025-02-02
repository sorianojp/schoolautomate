<%@ page language="java" import="utility.CommonUtil, java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(9);
//strColorScheme is never null. it has value always.
boolean bolIsGovernment = false;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link  href="../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<link href="../css/treelinkcss.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/JavaScript">
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
<link href="../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[0]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<body bgcolor="#C39E60" onLoad="MM_preloadImages('/images/home_small_admin_rollover.gif','/images/help_small_admin_rollover.gif','/images/logout_admin_rollover.gif')" class="bgDynamic">
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
openImg.src = "../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../images/box_with_plus.gif";

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
<form action="../commfile/logout.jsp?my_home=1" method="post" target="_parent">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="8%" height="19" bgcolor="#E9E0D1">&nbsp;</td>
    <td width="92%" bgcolor="#E9E0D1">
	<a href="<%if(bolIsSchool){%>../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm<%}else{%>../index.jsp<%}%>" target="_parent" onMouseOver="MM_swapImage('Image2','','../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
  </tr>
  </table>
<input type="hidden" name="logout_url" value="<%if(bolIsSchool){%>../ADMIN_STAFF/main%20files/admin_staff_bottom_content.htm<%}else{%>../index.jsp<%}%>">
<input type="hidden" name="body_color" value="#C39E60">
</form>
<%
String strErrMsg = "";
String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
utility.DBOperation dbOP = null;
hr.HRNotification  hrNotification = new hr.HRNotification();

boolean bolForceSplitItemRequest = false;

if(strUserIndex == null)
	strErrMsg = "You are loggedout by system. Please login again.";
else{
	dbOP = new utility.DBOperation();
	strErrMsg = "select prop_val from read_property_file where prop_name = 'IS_GOVERNMENT'";
	strErrMsg = dbOP.getResultOfAQuery(strErrMsg, 0);
	if(strErrMsg != null && strErrMsg.equals("1"))
		bolIsGovernment = true;
	strErrMsg = "";

utility.ReadPropertyFile readPropFile = new utility.ReadPropertyFile();
boolean bolIsFacDTRAllowed = readPropFile.readProperty(dbOP, "IS_FACULTY_APPLICABLE","0").equals("1");	
bolForceSplitItemRequest   = readPropFile.readProperty(dbOP, "FORCE_SUPPLY_REQUISITION_MYHOME","0").equals("1");	

if(false){%>
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../images/arrow_blue.gif"><a href="../commfile/chat/chat_main.jsp" target="myhomemainFrame"> SB Chat </a><br>
</font></strong>
<%}%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">HR Files </font></strong></div>
<span class="branch" id="branch1"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_201_file.jsp?my_home=1"  target="myhomemainFrame">201 File </a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_personal_data.jsp?my_home=1" target="myhomemainFrame">Personal Data</a><br>
<%if(strSchCode.startsWith("AUF")){%>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_job_desc_search.jsp?my_home=1" target="myhomemainFrame">Job Description</a><br>
<%}%>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_contact_main.jsp?my_home=1" target="myhomemainFrame">Contact Info</a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_sp_child.jsp?my_home=1" target="myhomemainFrame">Spouse/Children Data</a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_employment.jsp?my_home=1" target="myhomemainFrame">Previous Employment </a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_service_rec.jsp?my_home=1" target="myhomemainFrame">Service Record</a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_education.jsp?my_home=1" target="myhomemainFrame">Education</a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_awards_etc.jsp?my_home=1" target="myhomemainFrame">Awards/Citations/Recognitions</a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_research_etc.jsp?my_home=1" target="myhomemainFrame">Scholarships/Research Works</a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_licenses.jsp?my_home=1" target="myhomemainFrame">Licenses</a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_exams.jsp?my_home=1" target="myhomemainFrame">Exams Taken</a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_skills.jsp?my_home=1" target="myhomemainFrame">Skills</a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_trainings.jsp?my_home=1" target="myhomemainFrame">Trainings</a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_language.jsp?my_home=1" target="myhomemainFrame">Languages</a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_affiliations.jsp?my_home=1" target="myhomemainFrame">Group Affiliations</a> <br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_personnel_x_act_ser.jsp?my_home=1" target="myhomemainFrame">Extra Activities/Services</a> <br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/personnel/hr_employee_logout.jsp?my_home=1" target="myhomemainFrame">Official Business</a> <br>
</font></span> 
<!--  <div> <img src="../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../enrollment/subjects/subj_sectioning.jsp?my_home=1" target="enrolmainFrame">SUBJECT
  SECTIONING</a> </font></strong></div>-->
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Leave</font></strong></div>	
<span class="branch" id="branch2"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/leave/leave_apply.jsp?my_home=1" target="myhomemainFrame">Apply Leave Request</a><br>
</font></span>

<div class="trigger" onClick="showBranch('branch12');swapFolder('folder12')"> 
  <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder12"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Training/Seminar Request</font></strong></div>	
<span class="branch" id="branch12"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/request_training/training_request_application.jsp?my_home=1" target="myhomemainFrame">Apply Training Request</a><br>
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/HR/request_training/training_request_application_view.jsp?my_home=1" target="myhomemainFrame">View Applied Trainings Status</a><br>
</font></span>

<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Payroll</font></strong></div>
	<span class="branch" id="branch3"> <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF/e_dtr<%}else{%>../main/edtr<%}%>/working_hours_mgmt/set_working.jsp?my_home=1" target="myhomemainFrame">Working Hours</a> <br>
	<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF/e_dtr<%}else{%>../main/edtr<%}%>/working_hours_mgmt/rest_days.jsp?my_home=1" target="myhomemainFrame">Rest Days</a><br>	
<%if(bolIsGovernment){%>
	<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF/e_dtr<%}else{%>../main/edtr<%}%>/reports/government/cs_dtr_form.jsp?my_home=1" target="myhomemainFrame">DTR - Form 48</a><br>
<%}%>
	<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF/e_dtr<%}else{%>../main/edtr<%}%>/reports/monthly_report_emp_attendance.jsp?my_home=1" target="myhomemainFrame">DTR</a><br>
<%if(hrNotification.isImmediateSupervisor(dbOP, strUserIndex)){%>
	<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF/e_dtr<%}else{%>../main/edtr<%}%>/reports/emp_attendance.jsp?my_home=1" target="myhomemainFrame">DTR(Subordinates)</a><br>
<%}%>	
<%if(bolIsFacDTRAllowed){
	if(!strSchCode.startsWith("FATIMA")){%>
		<img src="../images/broken_lines.gif"> <a href="../ADMIN_STAFF/e_dtr/working_hours_mgmt/multiple_workhours/faculty_sched_detail.jsp?my_home=1" target="myhomemainFrame">DTR(Faculty)</a><br>
	<%}else{%>
		<img src="../images/broken_lines.gif"> <a href="../ADMIN_STAFF/e_dtr/working_hours_mgmt/multiple_workhours/faculty_sched_detail_fatima.jsp?my_home=1" target="myhomemainFrame">DTR(Faculty)</a><br>
	<%}%>
<%}%>	
	<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/payroll/reports/payslips/regular_pay.jsp?my_home=1" target="myhomemainFrame">Payslip</a><br>
	<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/payroll/loans_advances/reports/emp_loans_balance.jsp?my_home=1" target="myhomemainFrame">Loans</a><br>
	<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/payroll/misc_deductions/post_ded.jsp?my_home=1" target="myhomemainFrame">Misc Deduction</a><br>
	<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/payroll/reports/payslips/thirteenth_month.jsp?my_home=1" target="myhomemainFrame">Addl. Month Payslip</a><br>
</font></span>

<%if(!strSchCode.startsWith("PWC")){%>
<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> 
  <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Overtime </font></strong></div>	
<span class="branch" id="branch4"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF/e_dtr<%}else{%>../main/edtr<%}%>/overtime/schedule_overtime.jsp?my_home=1" target="myhomemainFrame">Apply/View Overtime Request</a><br>
<!--
<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/e_dtr/overtime/view_all_ot_request.jsp?my_home=1" target="myhomemainFrame">Approve/Validate Overtime</a><br>
-->
</font></span>
<%}%>

<%if(bolIsSchool){%>
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Requisition</font></strong></div>
  <span class="branch" id="branch6"><font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF">
  	<%if(bolForceSplitItemRequest) {%>
		<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/purchasing/requisition/req_info.jsp?my_home=1" target="myhomemainFrame">Make Requisition</a> <br>
		<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/purchasing/requisition/requisition_view_search.jsp?my_home=1" target="myhomemainFrame">View Requisition Status</a><br>
		<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/purchasing/transfer_req/request_info.jsp?my_home=1" target="myhomemainFrame">Request For Item Transfer</a><br>
		<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/purchasing/transfer_req/request_view_search.jsp?my_home=1" target="myhomemainFrame">View Item Transfer Request Status</a><br>
   	<%}else{%>
		<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/purchasing/requisition/req_info.jsp?my_home=1" target="myhomemainFrame">Make Requisition</a> <br>
		<img src="../images/broken_lines.gif"> <a href="<%if(bolIsSchool){%>../ADMIN_STAFF<%}else{%>../main<%}%>/purchasing/requisition/requisition_view_search.jsp?my_home=1" target="myhomemainFrame">View Requisition Status</a><br>
	<%}%>
   </font>
</span>
<%}

hr.HRLighthouse hrl = new hr.HRLighthouse();
	
if(strSchCode.startsWith("LHS")){

if(hrl.hasNotSentExitIntvForm(dbOP, strUserIndex)){
%>
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../images/arrow_blue.gif"><a href="lhs/lhs_exit_intv_form.jsp?my_home=1" target="myhomemainFrame"> Exit Interview Form</a> <br>
</font></strong>
<%}

if(hrl.getNumberOfSelfEvaluations(dbOP, request) > 0){%>
	<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><img src="../images/arrow_blue.gif">
		<a href="lhs/evaluation_main.jsp?my_home=1" target="myhomemainFrame"> Evaluations</a> <br></font></strong>
<%}
}%>

<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../images/arrow_blue.gif"><a href="change_password.jsp?my_home=1" target="myhomemainFrame"> Change Password</a> <br></font></strong>

<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
<%if(bolIsSchool){%>
<img src="../images/arrow_blue.gif"><a href="../ADMIN_STAFF/organizer/organizer_index.jsp?my_home=1" target="_parent"> Organizer/Message Board/Email </a><br>
<%}
int iNumOfNotifications = 0;
if(!bolIsSchool || strSchCode.startsWith("EAC")){
	
	Vector vNotifications = hrNotification.getAllNotifications(dbOP, strUserIndex);
	if(vNotifications == null)
		iNumOfNotifications = 0;
	else
		iNumOfNotifications = Integer.parseInt((String)vNotifications.elementAt(0));
if(false){%>
<img src="../images/arrow_blue.gif"><a href="./email/send_email.jsp?my_home=1" target="myhomemainFrame"> Send Email</a><br>
<%}%>
<img src="../images/arrow_blue.gif"><a href="notifications.jsp?my_home=1" target="myhomemainFrame"> Notification (New : <%=iNumOfNotifications%>)</a><br>
<%
boolean bolIsSupervisor = hrNotification.isImmediateSupervisor(dbOP, strUserIndex);

if(bolIsSupervisor || (strSchCode.startsWith("LHS") && hrl.isPartOfNotifyChecklist(dbOP, strUserIndex)) ){
	iNumOfNotifications = hrNotification.getTotalSubordinateApps(dbOP, strUserIndex);%>
<img src="../images/arrow_blue.gif"><a href="./update_notifications.jsp?my_home=1" target="myhomemainFrame"> Update Notification Status (Pending : <%=iNumOfNotifications%>)</a><br>
<%}//end of showing Notification to supervisors.
if(strSchCode.startsWith("TAMIYA") && bolIsSupervisor) {%>
	<img src="../images/arrow_blue.gif"><a href="../main/HR/personnel/hr_personnel_perf_appraisal.jsp?my_home=1" target="myhomemainFrame"> Performance Appraisal</a><br>
<%}//end of performance evaluation for tamiya.

}//end of else.. %>
<%if(strSchCode.startsWith("VMUF") || true) {
boolean bolIsSupervisor = hrNotification.isImmediateSupervisor(dbOP, strUserIndex);
%>
	<img src="../images/arrow_blue.gif"><a href="notifications.jsp?my_home=1" target="myhomemainFrame"> Notification (New : <%=iNumOfNotifications%>)</a><br>
<%if(bolIsSupervisor){
	iNumOfNotifications = hrNotification.getTotalSubordinateApps(dbOP, strUserIndex);%>
	<img src="../images/arrow_blue.gif"><a href="./update_notifications.jsp?my_home=1" target="myhomemainFrame"> Update Notification Status (Pending : <%=iNumOfNotifications%>)</a><br>
<%}
}
%>
<%if(strSchCode.startsWith("LHS")){%>
<img src="../images/arrow_blue.gif"><a href="./manual/" target="myhomemainFrame"> Employee Manual</a><br>
<%}%>
<%if(strSchCode.startsWith("TAMIYA") || strSchCode.startsWith("AUF")){%>
<img src="../images/arrow_blue.gif"><a href="./download/download_hr_forms.jsp?my_home=1" target="myhomemainFrame"> Download Forms</a><br>
<%}%>

<%if(strSchCode.startsWith("GTI")){%>
<img src="../images/arrow_blue.gif"><a href="./proj_mgmt/employee_todo.jsp?pgIndex=1" target="myhomemainFrame"> Project Management</a><br>
<%}%>
<%if(strSchCode.startsWith("VMA")){%>
	<img src="../images/arrow_blue.gif"><a href="../ADMIN_STAFF/HR/assessment/hr_assessment_vma.jsp" target="myhomemainFrame"> Employee Evaluation</a><br>
<%}%>


</font></strong>


<%}%>
</body>
</html>
