<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<style>
body {
	line-height:1.5;
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
    <td width="92%" bgcolor="#E9E0D1">
	<a href="../main%20files/admin_staff_home_button_content.htm" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
  </tr>
  </table>
<input type="hidden" name="logout_url" value="../ADMIN_STAFF/main%20files/admin_staff_bottom_content.htm">
<input type="hidden" name="body_color" value="#C39E60">
</form>
<font style="font-size:12px; font-family:Verdana, Geneva, Arial, Helvetica, sans-serif;color:#FFFFFF">

<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
//check if user is logged in, if logged, check authentication list here and allow the authentic user to access the system.
DBOperation dbOP = null; WebInterface WI = new WebInterface(request);
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

//Another way of checking authorization.. 
Vector vAuthList = new Vector();
if(!bolGrantAll) {
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, "Guidance & Counseling");
	if(vAuthList == null)
		vAuthList = new Vector();
	else if( ((String)vAuthList.elementAt(0)).compareTo("#ALL#") == 0) 
		bolGrantAll = true;
}
//else 
//	bolGrantAll = false;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";

boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
boolean bolIsCIT = strSchCode.startsWith("CIT");

if(strSchCode.startsWith("CIT") || strSchCode.startsWith("SWU") || strSchCode.startsWith("NEU")){
	if(bolGrantAll || vAuthList.indexOf("FACULTY EVALUATION") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../../images/box_with_plus.gif" border="0" id="folder7"> <strong>FACULTY EVALUATION</strong></div>
	
	<span class="branch" id="branch7"> 
	<img src="../../images/broken_lines.gif"><a href="./cit_fac_eval/manage_eval_point.jsp" target="guidanceFrame">Manage Evaluation Point</a><br>
	<img src="../../images/broken_lines.gif"><a href="./cit_fac_eval/manage_ques_catg.jsp" target="guidanceFrame">Manage Question Category</a><br>
	<img src="../../images/broken_lines.gif"><a href="./cit_fac_eval/manage_eval_ques.jsp" target="guidanceFrame">Manage Evluation Question</a><br>
	<img src="../../images/broken_lines.gif"><a href="./cit_fac_eval/manage_eval_sched.jsp" target="guidanceFrame">Manage Evaluation Schedule</a><br>
	<img src="../../images/broken_lines.gif"><a href="./cit_fac_eval/manage_eval_subject.jsp" target="guidanceFrame">Set Subjects for Evaluation</a><br>
	<img src="../../images/broken_lines.gif"><a href="./cit_fac_eval/exclude_faculty_frm_eval_report.jsp" target="guidanceFrame">Exclude Faculty from Evaluation Report</a><br>
	<img src="../../images/broken_lines.gif"><a href="./cit_fac_eval/reports/main.jsp" target="guidanceFrame">Reports</a><br>
	</span>
	<%}
}
if(bolGrantAll || vAuthList.indexOf("STUDENT TRACKER") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1"> 
  <strong>STUDENT TRACKER</strong></div>

<span class="branch" id="branch1"> 
<%if(!strSchCode.startsWith("CIT")){%>
	<img src="../../images/broken_lines.gif"><a href="../admission/stud_personal_info_page1.jsp" target="guidanceFrame">Personal Info</a><br>
<%}if(strSchCode.startsWith("AUF")){%>
<img src="../../images/broken_lines.gif"><a href="SPR/student_personal_record.jsp" target="guidanceFrame">Student Personal Information Sheet (Detailed)</a><br>
<img src="../../images/broken_lines.gif"><a href="SPR/frequency_report_auf.jsp" target="guidanceFrame">Student Frequency Report (SPIS)</a><br>
<%}%>
<%if(strSchCode.startsWith("CIT")){%>
<img src="../../images/broken_lines.gif"><a href="SPR/CIT/student_personal_data.jsp" target="guidanceFrame">Student Personal Information Sheet (Detailed)</a><br>
<%}%>

<img src="../../images/broken_lines.gif"><a href="../enrollment/reports/student_sched.jsp" target="guidanceFrame">Schedules</a><br>
<img src="../../images/broken_lines.gif"><a href="../sao/stud_track/membership_track.jsp" target="guidanceFrame">Membership</a><br>
<img src="../../images/broken_lines.gif"><a href="../sao/stud_track/disciplinary_stat_track.jsp" target="guidanceFrame">Disciplinary Status</a><br>
<%if(!strSchCode.startsWith("CDD")){%>
	<img src="../../images/broken_lines.gif"><a href="student_tracker/absences/absences_main.jsp<%if(bolIsBasic){%>?is_basic=1<%}%>" target="guidanceFrame">Absences</a><br>
<%}if(strSchCode.startsWith("DBTC")){%>
<img src="../../images/broken_lines.gif"><a href="./sibling_mgmt/main_sibling.jsp" target="guidanceFrame">Sibling Management</a><br>
<%}if(!bolIsBasic){%>
	<%if(!strSchCode.startsWith("CLDH") && !strSchCode.startsWith("UB") && !bolIsCIT){%>
	<img src="../../images/broken_lines.gif"><a href="../registrar/residency/residency_status.jsp" target="guidanceFrame">Unofficial TOR</a><br>
	<img src="../../images/broken_lines.gif"><a href="../fee_assess_pay/student_ledger/student_ledger.jsp" target="guidanceFrame">Student Ledger</a><br>
	<%}%>
<%if(strSchCode.startsWith("CDD")){%>
	<img src="../../images/broken_lines.gif"><a href="cdd_scaled_chart/scaled_chart_main.jsp" target="guidanceFrame">Psychological Status</a><br>
<%}else{%>
	<img src="../../images/broken_lines.gif"><a href="student_tracker/track_psych_cases.jsp" target="guidanceFrame">Psychological Status</a><br>
	<img src="../../images/broken_lines.gif"><a href="student_tracker/track_counseling_cases.jsp" target="guidanceFrame">Counseling Status</a><br>
	<img src="../../images/broken_lines.gif"><a href="student_tracker/track_mental_ability.jsp" target="guidanceFrame">Mental Ability</a><br>
<%}%>
<%}%>
</span>

<%} if(bolGrantAll || vAuthList.indexOf("STUDENT REFERRAL") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2"> 
  <strong>STUDENT REFERRAL</strong></div>
<span class="branch" id="branch2"> 
<img src="../../images/broken_lines.gif"><a href="student_referral/student_ref_info.jsp" target="guidanceFrame">Student Referral Info</a><br>
<img src="../../images/broken_lines.gif"><a href="student_referral/student_ref_feedback.jsp" target="guidanceFrame">Feedback</a><br>
<img src="../../images/broken_lines.gif"><a href="student_referral/search_listings.jsp<%if(bolIsBasic){%>?is_basic=1<%}%>" target="guidanceFrame">Search/Listings</a><br>
</span> 

<%} if(bolGrantAll || vAuthList.indexOf("FOLLOW UP") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch12');swapFolder('folder12')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder12"> 
  <strong>FOLLOW-UP</strong></div>
<span class="branch" id="branch12">
<img src="../../images/broken_lines.gif"><a href="follow_up/student_followup_encode.jsp<%if(bolIsBasic){%>?is_basic=1<%}%>" target="guidanceFrame">Update Follow-up Remarks</a><br>
<img src="../../images/broken_lines.gif"><a href="follow_up/followup_record.jsp<%if(bolIsBasic){%>?is_basic=1<%}%>" target="guidanceFrame">Follow-up Record</a><br>
</span> 

<!--  <div> <img src="../../images/small_%20white_%20box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../enrollment/subjects/subj_sectioning.jsp" target="enrolmainFrame">SUBJECT
  SECTIONING</a> </font></strong></div>-->
<%} 
if(!bolIsBasic){
	if(bolGrantAll || vAuthList.indexOf("MENTAL ABILITY TEST RESULT") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3"> 
	  <strong>MENTAL ABILITY TEST RESULT</strong></div>
	<span class="branch" id="branch3"> 
	<img src="../../images/broken_lines.gif"><a href="mental_ability/encode_mental_ability.jsp" target="guidanceFrame">Encode Result</a><br>
	<img src="../../images/broken_lines.gif"><a href="mental_ability/search_mental_ability.jsp" target="guidanceFrame">Search</a><br>
	</span> 
	<%} if(bolGrantAll || vAuthList.indexOf("PSYCHOLOGICAL CASES") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4"> 
	<strong>PSYCHOLOGICAL CASES</strong></div>
	<span class="branch" id="branch4"> 
	<img src="../../images/broken_lines.gif"><a href="pyschological_cases/add_psych_cases.jsp" target="guidanceFrame">Add/Create</a><br>
	<img src="../../images/broken_lines.gif"><a href="pyschological_cases/search_psych_cases.jsp" target="guidanceFrame">Search</a><br>
	</span>
	<%} if(bolGrantAll || vAuthList.indexOf("PSYCHOLOGICAL TESTS") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch13');swapFolder('folder13')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder12"> 
	 <strong>PSYCHOLOGICAL TESTS</strong></div>
	<span class="branch" id="branch13"> 
	<img src="../../images/broken_lines.gif"><a href="psychological_tests/create_tests.jsp" target="guidanceFrame"> <%if(strSchCode.startsWith("AUF")){%>Test Inventory<%}else{%>Manage Exams<%}%></a><br>
	<img src="../../images/broken_lines.gif"><a href="psychological_tests/test_factors.jsp" target="guidanceFrame"> <%if(!strSchCode.startsWith("AUF")){%>Manage<%}%> Factors</a><br>
	<img src="../../images/broken_lines.gif"><a href="psychological_tests/create_tests_schedules.jsp" target="guidanceFrame"> <%if(strSchCode.startsWith("AUF")){%>Schedule and list of Examinees<%}else{%>Manage Schedules<%}%></a><br>
	<img src="../../images/broken_lines.gif"><a href="psychological_tests/percentile_score_map.jsp" target="guidanceFrame"> <%if(strSchCode.startsWith("AUF")){%>Test Profile<%}else{%>Percentile Mapping<%}%></a><br>
	<img src="../../images/broken_lines.gif"><a href="psychological_tests/create_tests_interpretation.jsp" target="guidanceFrame"> <%if(strSchCode.startsWith("AUF")){%>Norms<%}else{%>Result Interpretation<%}%></a><br>
	<img src="../../images/broken_lines.gif"><a href="psychological_tests/encode_tests_results.jsp" target="guidanceFrame"> <%if(strSchCode.startsWith("AUF")){%>Encode Test Scores<%}else{%>Encode Result<%}%></a><br>
	<%if(strSchCode.startsWith("UB")){%>	
		<img src="../../images/broken_lines.gif"><a href="psychological_tests/test_reports.jsp" target="guidanceFrame"> Reports</a><br>
	<%}%>
	</span>
	
	 <!--<img src="../../images/small_%20white_%20box.gif" width="7" height="7" border="0" > 
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../student_sched/enrollment_stud_sched.htm" target="enrolmainFrame">STUDENT 
	  SCHEDULE</a></font></strong><br>-->
	
	<!--  <div><img src="../../images/small_%20white_%20box.gif" width="7" height="7" border="0" id="folder5">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../assessment/enrollment_assessment.htm" target="enrolmainFrame">ASSESSMENT</a>
	  </font></strong></div>-->
	<%} if(bolGrantAll || vAuthList.indexOf("COUNSELING CASES") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder5"> 
	<strong>COUNSELING CASES</strong></div>
	<span class="branch" id="branch5"> 
	<img src="../../images/broken_lines.gif"> <a href="counseling_cases/add_counseling_cases.jsp" target="guidanceFrame">Add/Create</a><br>
	<img src="../../images/broken_lines.gif"> <a href="counseling_cases/search_counseling_cases.jsp" target="guidanceFrame">Search</a><br>
	</span>
	
	<%} if(bolGrantAll || vAuthList.indexOf("EMOTIONAL INTELLIGENCE SCALE") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6"> 
	  <strong>EMOTIONAL INTELLIGENCE<br>&nbsp;&nbsp;&nbsp; SCALE (Employees)</strong></div>
	<span class="branch" id="branch6">
	<img src="../../images/broken_lines.gif"><a href="eis/eis_eq_dim_entry.jsp" target="guidanceFrame">EQ Dimension</a><br>
	<img src="../../images/broken_lines.gif"><a href="eis/eis_inter_table_entry.jsp" target="guidanceFrame">Interpretation Table</a><br>
	<img src="../../images/broken_lines.gif"><a href="eis/eis_result_encoding.jsp" target="guidanceFrame">Results Encoding</a><br> 
	<img src="../../images/broken_lines.gif"><a href="eis/search_eis_result.jsp" target="guidanceFrame">Search</a><br>
	</span> 
	
	<%}
	if(!strSchCode.startsWith("CGH") && !strSchCode.startsWith("UB")){
	 if(bolGrantAll || vAuthList.indexOf("GOOD MORAL CERTIFICATION") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8"> <strong>GOOD MORAL CERTIFICATION</strong></div>
	<span class="branch" id="branch8"><font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
	<%if(false){//I am not sure who requested this %>
		<img src="../../images/broken_lines.gif"><a href="good_moral_cert/cert_req_entry.jsp" target="guidanceFrame">Certification Request Entry</a><br>
		<img src="../../images/broken_lines.gif"><a href="good_moral_cert/cert_req_view_edit.jsp" target="guidanceFrame">View/Edit Request</a><br>
		<img src="../../images/broken_lines.gif"><a href="javascript:alert('Not Available');">Print Certification </a><br> 
	<%}else if(strSchCode.startsWith("CGH")){%>
		<img src="../../images/broken_lines.gif"><a href="good_moral_cert/cgh_certificate_main.jsp" target="guidanceFrame">Print Certification</a><br>
	<%}else if(strSchCode.startsWith("UDMC")){%>
		<img src="../../images/broken_lines.gif"><a href="good_moral_cert/udmc_certificate_main.jsp" target="guidanceFrame">Print Certification</a><br>
	<%}else{%>
		<img src="../../images/broken_lines.gif"><a href="good_moral_cert/common_cert_main.jsp" target="guidanceFrame">Print Certification</a><br>
	<%}%>
	</span>
	<%}%>
	<!-- <div class="trigger" onClick="showBranch('branch10');swapFolder('folder10')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder10"> 
	 <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">SEARCH</font></strong></div>
	<span class="branch" id="branch10"><font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
	<img src="../../images/broken_lines.gif"> <a href="../../search/srch_stud.jsp" target="guidanceFrame"><font face="Geneva, Arial, Helvetica, sans-serif">Students</font></a><br>
	</font> </span> -->
	
	<%} if(bolGrantAll || vAuthList.indexOf("REPORTS") != -1){isAuthorized=true;%>
	 <div class="trigger" onClick="showBranch('branch14');swapFolder('folder14')">
	 <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder14"><strong> REPORTS</strong></div>
	 <span class="branch" id="branch14">
	<%if(strSchCode.startsWith("UDMC")){%>
		<img src="../../images/broken_lines.gif"><a href="./reports/other/main.jsp" target="guidanceFrame">Other Reports</a><br>
	<%}if(!bolIsCIT) {%>
	 <img src="../../images/broken_lines.gif"><a href='../fee_assess_pay/reports/list_educational_assistance.jsp' target="guidanceFrame">Students With Educational<br>&nbsp; &nbsp;Assistance</a><br>
	 <%}%>
	 <img src="../../images/broken_lines.gif"><a href="../registrar/reports/student_list_w_inc.jsp" target="guidanceFrame">List of Students Per <br>&nbsp; &nbsp;Grades Status</a><br>
	 <img src="../../images/broken_lines.gif"><a href="../enrollment/reports/drop_subject_list.jsp" target="guidanceFrame">List of Students With <br>&nbsp; &nbsp;Dropped Subjects</a><br>
	 <img src="../../images/broken_lines.gif"><a href="../registrar/top_students/top_stud.jsp" target="guidanceFrame">Top Students</a><br> 
<%if(strSchCode.startsWith("UB")){%>
		<img src="../../images/broken_lines.gif"><a href="./reports/other/UB/main.jsp" target="guidanceFrame">Other Reports</a><br>	
		<!--
		<img src="../../images/broken_lines.gif"><a href="reports/other/UB/guidance_tracker.jsp" target="guidanceFrame">Guidance Tracker</a><br>
		<img src="../../images/broken_lines.gif"><a href="reports/other/UB/guidance_tracker_report.jsp" target="guidanceFrame">Guidance Tracker Reports</a><br>
		<img src="../../images/broken_lines.gif"><a href="reports/other/UB/guidance_services.jsp" target="guidanceFrame">Guidance Services</a><br>
		<img src="../../images/broken_lines.gif"><a href="reports/other/UB/guidance_services_report.jsp" target="guidanceFrame">Guidance Service Reports</a><br>
		-->
<%}%>
	 </span>
	 <%}%>
<%
if(strSchCode.startsWith("CIT")){
	strSchCode = "select * from user_auth_list where user_index = "+(String)request.getSession(false).getAttribute("userIndex")+" and sub_mod_index = 347";
	strSchCode = dbOP.getResultOfAQuery(strSchCode, 0);
	if(strSchCode != null) {%>
	 	<img src="../../images/arrow_blue.gif"><a href="../user_admin/student_password.jsp" target="guidanceFrame"><strong> Reset Student Password</strong></a><br>
<%}}
	if(strSchCode.startsWith("NEU")){
		if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Guidance & Counseling","HOLD-UNHOLD")!=0){isAuthorized=true;%>
	 		<img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<a href="../user_admin/set_param/hold_unhold_student.jsp" target="guidanceFrame"> Hold - UnHold Student</a></font></strong><br>
<%}}

}//do not show for basic.. 
if(strUserId == null)
	strErrMsg = "Session timeout. Please login again.";
else if(!isAuthorized)
	strErrMsg = "You are not authorized to view any link in this page. Please contact system admin for access permission.";
if(strErrMsg == null)
	strErrMsg = "";
%>
</font>

<font size="2" face="Verdana, Arial, Helvetica, sans-serif"><%=strErrMsg%></font>
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>
