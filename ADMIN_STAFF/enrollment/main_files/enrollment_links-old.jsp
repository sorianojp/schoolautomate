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
</script>
<form action="../../../commfile/logout.jsp" method="post" target="_parent">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="8%" height="19" bgcolor="#E9E0D1">&nbsp;</td>
    <td width="92%" bgcolor="#E9E0D1"><a href="../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm" target="_parent" onMouseOver="MM_swapImage('Image2','','../../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
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

//for UI show the re-enrollment link.
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
if(strUserId != null && (strUserId.compareTo("1770") ==0 || strUserId.compareTo("biswa-001") == 0))
	strSchCode = "UI";


//Another way of checking authorization..
Vector vAuthList = null;
if(!bolGrantAll) {
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, "Enrollment");
	if(vAuthList == null)
		vAuthList = new Vector();
	else if( ((String)vAuthList.elementAt(0)).compareTo("#ALL#") == 0)
		bolGrantAll = true;
}
//old way of calling..
//comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Enrollment","ROOMS MONITORING")!=0

if(bolGrantAll || vAuthList.indexOf("ROOMS MONITORING") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ROOMS  MONITORING</font></strong></div>
<span class="branch" id="branch1"> <font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"></font> 
<%
if(bolGrantAll || vAuthList.indexOf("ROOMS MAINTENANCE") != -1) {isAuthorized=true;%>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/room_asg/room_maintenance.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
Maintenance</font></a><br>
<%}%>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/room_asg/room_scheduling.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Assignments</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/room_asg/room_view_scheduling.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">View Room Schedule</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/room_asg/room_listing.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Room Listings</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/room_asg/reserve_room_main.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Reserve Room (for Activity)</font></a><br>
</span> 
<%}if(bolGrantAll || vAuthList.indexOf("SUBJECT OFFERINGS") != -1){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CLASS PROGRAMS </font></strong></div>
<span class="branch" id="branch2"> <font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"></font>
<%if(strSchCode.startsWith("CPU")){%>
<img src="../../../images/broken_lines.gif"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../subjects/cpu/scheduling_main.htm" target="enrolmainFrame">Class Program - Main (CPU)</a></font><br>
<%}%>
<img src="../../../images/broken_lines.gif"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../subjects/subj_sectioning.jsp" target="enrolmainFrame">New Class Program/Sections</a></font><br>
<img src="../../../images/broken_lines.gif"> <a href="../subjects/subj_sectioning_old.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Use Previous Class Program</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../subjects/print_class_program.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Print Class Program</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../subjects/class_program_persub.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Class Program Per Subject</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../subjects/subject_offering_per_college_dept.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Subject Offering Per <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;College/Dept</font></a><br>
</span>

<!--  <div> <img src="../../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../subjects/subj_sectioning.jsp" target="enrolmainFrame">SUBJECT
  SECTIONING</a> </font></strong></div>
-->
<%}if(bolGrantAll ||  vAuthList.indexOf("FACULTY") != -1){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">FACULTY</font></strong></div>
<span class="branch" id="branch3"> <font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"></font>
<!--<img src="../../../images/broken_lines.gif"> <a href="../faculty/enrollment_faculty_add.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Add/Create</font></a><br>-->
<img src="../../../images/broken_lines.gif"><a href="../faculty/faculty_subj_list_load.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">List of Subjects Faculty Can Teach</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../faculty/enrollment_faculty_load_sched.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Loading/Scheduling</font></a><br>
<% if (strSchCode.startsWith("UI") || strSchCode.startsWith("AUF")){%>
<img src="../../../images/broken_lines.gif"> <a href="../faculty/enrollment_ci_faculty_load_sched.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Clin. Instructor Scheduling</font></a><br>
<%}%>
<img src="../../../images/broken_lines.gif"> <a href="../faculty/faculty_substitution.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Substitution</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../faculty/faculty_list_view_load.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">View/Print Plotted Load</font></a> <br>
<img src="../../../images/broken_lines.gif"> <a href="../faculty/teaching_load_slip.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Teaching Load Assignment </font></a> <br>
<img src="../../../images/broken_lines.gif"> <a href="../faculty/summary_faculty_load_main.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Summary of Faculty Load</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../faculty/enrollment__faculty_reports.htm" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Reports</font></a> <br>
</span>

<%}
if(false)
if(bolGrantAll || vAuthList.indexOf("UPDATE CURRICULUM YEAR") != -1){isAuthorized=true;%>
<img src="../../../images/small_white_box.gif" width="7" height="7" border="0">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../../ADMIN_STAFF/enrollment/update_curr_year/update_cur_yr.jsp" target="enrolmainFrame">UPDATE CURRICULUM YEAR </a></font></strong> <br>


<%}if(bolGrantAll || vAuthList.indexOf("ADVISING & SCHEDULING") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ADVISING &amp; SCHEDULING</font></strong></div>

<span class="branch" id="branch4"> <font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"></font>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/advising/advising_old.jsp?pgDisp=OLD" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Old</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/advising/advising_new.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">New</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/advising/advising_transferee.jsp?pgDisp=TRANSFEREE" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Transferee</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/advising/advising_transferee.jsp?pgDisp=CROSS-ENROLLEE" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Cross-Enrolee</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/advising/advising_old.jsp?pgDisp=CHANGE%20COURSE" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Change Course(Shifter)</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/advising/advising_transferee.jsp?pgDisp=SECOND%20COURSE" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Second Course</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/advising/advising_subj_other_course.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Subject(s) from Other Courses</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/advising/print_esl_main.jsp" target="enrolmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Print Enrollment Student Load</font></a><br>
<%
String strTemp = (String)request.getSession(false).getAttribute("school_code");
if(strTemp == null)
	strTemp = "";

if( strTemp.startsWith("AUF") || strTemp.startsWith("CLDH") || strTemp.startsWith("CGH") || 
	strTemp.startsWith("CPU") || strTemp.startsWith("UDMC")){%>
<img src="../../../images/broken_lines.gif"> <a href="../advising/assessment_main_page.jsp" target="enrolmainFrame"> 
<font size="2" face="Geneva, Arial, Helvetica, sans-serif">Assessment(Optional fees/ Print Form)</font></a><br>
<%}%>
</span>
<!--  <img src="../../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../student_sched/enrollment_stud_sched.htm" target="enrolmainFrame">STUDENT
  SCHEDULE</a></font></strong><br>-->
<!--  <div><img src="../../../images/small_white_box.gif" width="7" height="7" border="0" id="folder5">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../assessment/enrollment_assessment.htm" target="enrolmainFrame">ASSESSMENT</a>
  </font></strong></div>-->
<%}if(bolGrantAll ||  vAuthList.indexOf("CHANGE OF SUBJECTS") != -1 ){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')">
	<img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder5"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CHANGE OF SUBJECTS </font></strong></div>
<span class="branch" id="branch5"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<%if(bolGrantAll ||  vAuthList.indexOf("CHANGE OF SUBJECTS-DROP") != -1 ){%>
	<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/change_subjects/change_subject_drop.jsp" target="enrolmainFrame">Drop/Withdraw</a><br>
<%}%>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/change_subjects/change_subject_add.jsp" target="enrolmainFrame">Add</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/change_subjects/add_subj_other_course.jsp" target="enrolmainFrame">Add Subject(Other Course)</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/change_subjects/change_schedule.jsp" target="enrolmainFrame">Change Schedule</a><br>
<%
if(strSchCode.startsWith("UI") || strSchCode.startsWith("AUF")){%>
<img src="../../../images/broken_lines.gif"> <a href="../change_subjects/re_enrolment.jsp" target="enrolmainFrame">Re-Enrolment</a><br>
<%}if(bolGrantAll ||  vAuthList.indexOf("CHANGE OF SUBJECTS-MOVE") != -1 ){%>
	<img src="../../../images/broken_lines.gif"> <a href="../change_subjects/move_section_students_main.jsp" target="enrolmainFrame">Move Students </a><br>
<%}if(bolGrantAll ||  vAuthList.indexOf("CHANGE OF SUBJECTS-REASSIGN") != -1 ){
	if(!strSchCode.startsWith("CPU")){%>
<img src="../../../images/broken_lines.gif"> <a href="../change_subjects/re_assign_lec_lab.jsp" target="enrolmainFrame" title="Click to change units enrolled and Lec/Lab enrollment.">Re-Assign 
units enrolled (or) Lec/Lab enrollment</a><br>
<%}//do not show for CPU.
}%>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/reports/student_sched.jsp" target="enrolmainFrame">Print New Student Load</a><br>
</font></span>
<%}if(bolGrantAll || vAuthList.indexOf("STATISTICS") != -1 ){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">STATISTICS</font></strong></div>

<span class="branch" id="branch6"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/statistics/statistics_enrollees.jsp" target="enrolmainFrame">Enrollees</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/statistics/stats_compare.jsp" target="enrolmainFrame">Enrollment Comparison </a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/statistics/statistics_subjects.jsp" target="enrolmainFrame">Subjects</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/statistics/statistics_sub_sched.jsp" target="enrolmainFrame">Subjects Schedule</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/statistics/statistics_rooms.jsp" target="enrolmainFrame">Rooms</a><br>
<img src="../../../images/broken_lines.gif"> <a href="../statistics/statistics_assessed_hours.jsp" target="enrolmainFrame">Assessed Hour/Unit</a><br>
</font></span>
<%}if(bolGrantAll || vAuthList.indexOf("REPORTS") != -1 ){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder7"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">REPORTS</font></strong></div>

<span class="branch" id="branch7"><font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/reports/elist.jsp" target="enrolmainFrame"><font face="Geneva, Arial, Helvetica, sans-serif">Enrollment Lists</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/reports/class_lists.jsp" target="enrolmainFrame"><font face="Geneva, Arial, Helvetica, sans-serif">Class Lists</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/reports/student_sched.jsp" target="enrolmainFrame"><font face="Geneva, Arial, Helvetica, sans-serif">Students' Schedules</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/reports/enrolment_summary.jsp" target="enrolmainFrame"><font face="Geneva, Arial, Helvetica, sans-serif">Enrolment Summary</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/reports/drop_subject_list.jsp" target="enrolmainFrame"><font face="Geneva, Arial, Helvetica, sans-serif">Dropped Subject Student List</font></a><br>
<img src="../../../images/broken_lines.gif"> <a href="../../../ADMIN_STAFF/enrollment/reports/enrolment_sum_prev_school.jsp" target="enrolmainFrame"><font face="Geneva, Arial, Helvetica, sans-serif">Summary of Stud From Prev School</font></a><br>
</font> </span>
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
