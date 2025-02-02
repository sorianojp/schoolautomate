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
<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
//check if user is logged in, if logged, check authentication list here and allow the authentic user to access the system.
DBOperation dbOP = null;
CommonUtil comUtil = new CommonUtil();
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strErrMsg = null;

boolean bolGrantAll = false;
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
		//check if user has filled up the form.
		//check here the authentication of the user.
		if(comUtil.IsSuperUser(dbOP,strUserId))
			bolGrantAll = true;	//grant all ;-)
	}
}
else
	strErrMsg = " Please login to access the available modules.";
//System.out.println("testing : strErrMsg ="+strErrMsg);

Vector vAuthList = null;
if(!bolGrantAll) {
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, "STUDENT AFFAIRS");
	if(vAuthList == null)
		vAuthList = new Vector();
	else if( ((String)vAuthList.elementAt(0)).compareTo("#ALL#") == 0)
		bolGrantAll = true;
}

boolean bolIsBasic = new WebInterface(request).fillTextValue("is_basic").equals("1");

if(strErrMsg != null && strErrMsg.length() > 0)
{%>
<font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif" size="2"><b><%=strErrMsg%></b></font>

<%//System.out.println("testing");
if(dbOP != null) dbOP.cleanUP();
return;
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCIT = strSchCode.startsWith("CIT");

boolean isAuthorized = false;
if(bolGrantAll || vAuthList.indexOf("STUDENT TRACKER") != -1){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">STUDENT TRACKER </font></strong></div>

<span class="branch" id="branch1">
<font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="../admission/stud_personal_info_page1.jsp" target="saomainFrame">Personal Info</a><br>
<img src="../../images/broken_lines.gif"> <a href="../enrollment/reports/student_sched.jsp" target="saomainFrame">Schedules</a><br>
<img src="../../images/broken_lines.gif"> <a href="./stud_track/membership_track.jsp" target="saomainFrame">Membership</a><br>
<img src="../../images/broken_lines.gif"> <a href="./stud_track/disciplinary_stat_track.jsp" target="saomainFrame">Disciplinary Status</a><br>
<%if(strSchCode.startsWith("UI")){%>
<img src="../../images/broken_lines.gif"> <a href="./stud_track/scholarship_list.jsp" target="saomainFrame">Scholarship Listing</a><br>
<%}if(strSchCode.startsWith("CDD")){%>
	<img src="../../images/broken_lines.gif"> <a href="./attendance_monitoring/attendance_main.jsp" target="saomainFrame">Attendance Monitoring</a><br>
	<img src="../../images/broken_lines.gif"><a href="../guidance/student_tracker/absences/absences_main.jsp<%if(bolIsBasic){%>?is_basic=1<%}%>" target="saomainFrame"> Absences</a><br>
<%}%>
<%if(strSchCode.startsWith("UB") || strSchCode.startsWith("SPC")){%>
	<img src="../../images/broken_lines.gif"> <a href="../user_admin/set_param/set_msg_user.jsp" target="regmainFrame">Message System</a> <br>
<%}%>
 </font>
</span>
<!--  <div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../enrollment/subjects/subj_sectioning.jsp" target="enrolmainFrame">SUBJECT
  SECTIONING</a> </font></strong></div>-->
<%}if(bolGrantAll || vAuthList.indexOf("ORGANIZATIONS") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ORGANIZATIONS</font></strong></div>
<span class="branch" id="branch3"> 
<font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="organizations/org_add.jsp" target="saomainFrame">Add/Create</a><br>
<img src="../../images/broken_lines.gif"> <a href="search/srch_org.jsp" target="saomainFrame">Search Organization</a><br>
<img src="../../images/broken_lines.gif"> <a href="organizations/action_plan_org.jsp" target="saomainFrame">Action Plan</a><br>
<img src="../../images/broken_lines.gif"> <a href="organizations/activities_add.jsp" target="saomainFrame">Activities</a><br>
<img src="../../images/broken_lines.gif"> <a href="organizations/income_statement.jsp" target="saomainFrame">Income Statement</a><br>
<img src="../../images/broken_lines.gif"> <a href="organizations/year_end_report.jsp" target="saomainFrame">Organization Year-End Report</a><br>
<img src="../../images/broken_lines.gif"> <a href="organizations/action_plan_org.jsp?performance=1" target="saomainFrame">Performance Report</a><br>
</font>
</span>

<%}if(bolGrantAll || vAuthList.indexOf("PROGRAM OF ACTIVITIES") != -1){isAuthorized=true;%>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="program_of_act/prog_act_create.jsp" target="saomainFrame">PROGRAM OF ACTIVITIES </a></font></strong><br>

<%}if(bolGrantAll || vAuthList.indexOf("VIOLATIONS & CONFLICTS") != -1){isAuthorized=true;%>
 <div><img src="../../images/small_white_box.gif" width="7" height="7" border="0" id="folder5">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./vio_conflict/<%if(strSchCode.startsWith("SPC")){%>main.jsp<%}else{%>vio_conflict.jsp<%}%>" target="saomainFrame">VIOLATIONS &amp; CONFLICTS</a>
  </font></strong></div>


<!--  <div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder5">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">VIOLATIONS
  &amp; CONFLICTS</font></strong></div>
<span class="branch" id="branch5"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="../enrollment/change_subjects/reg_change_subject_drop.htm" target="enrolmainFrame">Add</a><br>
<img src="../../images/broken_lines.gif"> <a href="../enrollment/change_subjects/reg_change_subject_add.htm" target="enrolmainFrame">Edit/View/Delete</a><br>
<img src="../../images/broken_lines.gif"> <a href="../enrollment/change_subjects/reg_change_subject_schedules.htm" target="enrolmainFrame">Findings</a><br>
<img src="../../images/broken_lines.gif"> <a href="../enrollment/change_subjects/reg_change_subject_print.htm" target="enrolmainFrame">Actions/Recommendations</a><br>
</font></span>-->

<%}if(bolGrantAll || vAuthList.indexOf("LOST & FOUND") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">LOST &amp; FOUND</font></strong></div>

<span class="branch" id="branch6"> 
<font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="lost_found/lost_found_add.jsp" target="saomainFrame">Add</a><br>
<img src="../../images/broken_lines.gif"> <a href="lost_found/lost_found_viewall.jsp" target="saomainFrame">View/Edit/Delete</a><br>
</font>
</span>
<%}if(bolGrantAll || vAuthList.indexOf("Search") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder7">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">SEARCH</font></strong></div>

<span class="branch" id="branch7">
<font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"> <a href="../../search/srch_stud.jsp" target="saomainFrame">Students</a><br>
<img src="../../images/broken_lines.gif"> <a href="../../search/srch_stud_temp.jsp" target="saomainFrame">Temporary Students</a><br>
<img src="../../images/broken_lines.gif"> <a href="../../search/srch_stud_enrolled.jsp" target="saomainFrame">OLD Stud Enrollment progress</a><br>
<img src="../../images/broken_lines.gif"> <a href="../../search/srch_GSPIS.jsp" target="saomainFrame">Students Info from GSPIS</a><br>
</font> 
</span> 
<%}if(bolGrantAll){%>
<!--  <div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">STUDENT IDs</font></strong></div>

<span class="branch" id="branch8"><font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="#"><font face="Geneva, Arial, Helvetica, sans-serif">Picture
Taking Schedule</font></a><br>
<img src="../../images/broken_lines.gif"> <a href="#"><font face="Geneva, Arial, Helvetica, sans-serif">ID
Printing </font></a><br>
<img src="../../images/broken_lines.gif"> <a href="#"><font face="Geneva, Arial, Helvetica, sans-serif">ID Releasing </font></a><br>
</font> </span>-->
<%if(strSchCode.startsWith("VMUF")){%>
<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">STUDENT IDs</font></strong></div>
<span class="branch" id="branch8"> 
<font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"> <a href="../registrar/student_ids/new_id.jsp" target="saomainFrame">New IDs </a><br>
</font>
</span>
<%}
 if(strSchCode.startsWith("CLDH")){%>
 <div class="trigger" onClick="showBranch('branch14');swapFolder('folder14')"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
 <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder14"><strong> REPORTS</strong></font></div>
 <span class="branch" id="branch14">
 <font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<%if(!bolIsCIT) {%>
 	<img src="../../images/broken_lines.gif"><a href="../fee_assess_pay/reports/list_educational_assistance.jsp" target="saomainFrame">Students With Educational<br>&nbsp; &nbsp;Assistance</a><br>
<%}%>
 <img src="../../images/broken_lines.gif"><a href="../registrar/reports/student_list_w_inc.jsp" target="saomainFrame">List of Students Per <br>&nbsp; &nbsp;Grades Status</a><br>
 <img src="../../images/broken_lines.gif"><a href="../enrollment/reports/drop_subject_list.jsp" target="saomainFrame">List of Students With <br>&nbsp; &nbsp;Dropped Subjects</a><br>
 <img src="../../images/broken_lines.gif"><a href="../registrar/top_students/top_stud.jsp" target="saomainFrame">Top Students</a><br> 
 </font>
 </span>
 <%}%>

<!--
<div class="trigger" onClick="showBranch('branch9');swapFolder('folder9')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder9"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">REPORTS</font></strong></div>
 <span class="branch" id="branch9"><font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="#"><font face="Geneva, Arial, Helvetica, sans-serif">Certificate of Waiver</font></a><br>
<img src="../../images/broken_lines.gif"> <a href="#"><font face="Geneva, Arial, Helvetica, sans-serif">Good Moral Character</font></a><br>
<br>
</font> </span>
-->
<% if (strSchCode.startsWith("UI")){%>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./disc_agreement_p1.jsp" target="saomainFrame">STUDENT DISCIPLINE AGREEMENT</a></font></strong><br><%}%>

<%}//only if super user or having access to SAO link.
if(strSchCode.startsWith("CIT")){
	if(bolGrantAll || vAuthList.indexOf("LOCK ADVISING") != -1){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch20');swapFolder('folder20')"> <img src="../../images/box_with_plus.gif"  border="0" id="folder20">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Block/Unblock Advising</font></strong></div>
	<span class="branch" id="branch20"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		<img src="../../images/broken_lines.gif"> <a href="../enrollment/advising_dept_lock/lock_stud.jsp" target="saomainFrame">Block/Unblock</a> <br>
		<img src="../../images/broken_lines.gif"> <a href="../enrollment/advising_dept_lock/unlock_stud.jsp" target="saomainFrame">Unblocked Student Listing</a> <br>
	</font></span>
<%}
}
	if(strSchCode.startsWith("NEU")){
		if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Student Affairs","HOLD-UNHOLD")!=0){isAuthorized=true;%>
	 		<img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<a href="../user_admin/set_param/hold_unhold_student.jsp" target="saomainFrame"> Hold - UnHold Student</a></font></strong><br>
<%}}

dbOP.cleanUP();
%>
</body>
</html>
