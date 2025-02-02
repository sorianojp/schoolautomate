<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/treelinkcss.css" rel="stylesheet" type="text/css">
<link href="../../css/regmainlinkcssHEALTH.css" rel="stylesheet" type="text/css">
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
<style>
body {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

.bodystyle {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}


</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[0]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<body bgcolor="#32466B" onLoad="MM_preloadImages('../../images/buttons/home_roll.gif','../../images/buttons/help_roll.gif','../../images/buttons/logout_roll.gif')" class="bgDynamic">
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
      <td height="33"  align="center">
		  <a href="<%if(bolIsSchool){%>../main%20files/admin_staff_home_button_content.htm<%}else{%>../../index.jsp<%}%>" target="_parent" onMouseOver="MM_swapImage('Image1','','../../images/home_small_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small.gif" name="Image1" border="0" id="Image1"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image2','','../../images/help_small_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small.gif" name="Image2"  border="0" id="Image2"></a>
          <a onMouseOver="MM_swapImage('Image3','','../../images/logout_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../../images/logout.gif" name="Image3" border="0" id="Image3"></a>
	</td>
    </tr>
    <tr>
      <td height="19" ><hr size="1"></td>
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsAUF = strSchCode.startsWith("AUF");

Vector vAuthList = null;
if(!bolGrantAll) {
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, "Health Monitoring");
	if(vAuthList == null)
		vAuthList = new Vector();
	else if( ((String)vAuthList.elementAt(0)).compareTo("#ALL#") == 0)
		bolGrantAll = true;
}

Vector vLeaveApplication = null;
if(strSchCode.startsWith("TSUNEISHI"))
	vLeaveApplication = comUtil.getAuthModSubModNameList(dbOP, strUserId, "Hr Management");
if(vLeaveApplication == null)
	vLeaveApplication = new Vector();


///i have to check if for student only or employee only access.. it is hardcoded.. used for DLSHSI.
String strSQLQuery = null;
java.sql.ResultSet rs = null;





if(strSchCode.startsWith("AUF"))
	if(bolGrantAll || vAuthList.indexOf("CLINICAL TEST(PRE-ENROLLMENT)") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch11');swapFolder('folder11')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder11">
  <strong><font color="#FFFFFF">CLINICAL TEST(PRE-ENROLLMENT)</font></strong></div>
<span class="branch" id="branch11"> <font color="#FFFFFF"> <img src="../../images/broken_lines.gif">
<a href="./ct_pre_enrollment/manage_ct_type.jsp" target="hrmainFrame">Manage Test Schedule</a><br>
<img src="../../images/broken_lines.gif"> <a href="./ct_pre_enrollment/edit_ct_sched.jsp" target="hrmainFrame">Edit Student Schedule</a><br>
<img src="../../images/broken_lines.gif"> <a href="./ct_pre_enrollment/search_ct.jsp" target="hrmainFrame">Search</a><br>
</font></span>
<%}if(bolGrantAll || vAuthList.indexOf("PRESENT HEALTH STATUS") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
  <strong><font color="#FFFFFF">PRESENT HEALTH STATUS</font></strong></div>
<span class="branch" id="branch1"> <font color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="./present_health_stat/phs_entry_mgmt.jsp" target="hrmainFrame">Health Stat. Entry Mgmt.</a><br>
<img src="../../images/broken_lines.gif"> <a href="./present_health_stat/patient_phs_entry.jsp" target="hrmainFrame">Health Stat. Entry</a><br>
<img src="../../images/broken_lines.gif"> <a href="./present_health_stat/patient_phs_rec.jsp" target="hrmainFrame">Health Stat. Record</a><br>
</font></span>

<!--  <div> <img src="../../images/small_%20white_%20box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF"><a href="../enrollment/subjects/subj_sectioning.jsp" target="enrolmainFrame">SUBJECT
  SECTIONING</a> </font></strong></div>-->
<%}if(bolGrantAll || vAuthList.indexOf("FAMILY HISTORY") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2">
<strong><font color="#FFFFFF">FAMILY HISTORY </font></strong></div>
<span class="branch" id="branch2"> <font color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="./present_health_stat/phs_entry_mgmt.jsp" target="hrmainFrame">Family History Entry Mgmt.</a><br>
<img src="../../images/broken_lines.gif"><a href="./family_history/family_history_entry.jsp" target="hrmainFrame">Family History Entry</a><br>
<img src="../../images/broken_lines.gif"> <a href="./family_history/family_history_rec.jsp" target="hrmainFrame">Family History Record</a><br>
</font></span>

<%}if(bolGrantAll || vAuthList.indexOf("PAST MEDICAL HISTORY") != -1){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3">
<strong><font color="#FFFFFF">PAST MEDICAL  HISTORY </font></strong></div>
<span class="branch" id="branch3"> <font color="#FFFFFF">
<%if(strSchCode.startsWith("TSUNEISHI")){%>
	<img src="../../images/broken_lines.gif"><a href="past_medical_hist_tsuneishi/past_medical_history.jsp" target="hrmainFrame">Past Medical History Record</a> <br>
<%}else{%>
	<img src="../../images/broken_lines.gif"> <a href="./present_health_stat/phs_entry_mgmt.jsp" target="hrmainFrame">Past Medical History Entry Mgmt.</a><br>
	<img src="../../images/broken_lines.gif"><a href="./past_medical_hist/past_mh_entry.jsp" target="hrmainFrame"> Past Medical History Entry</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./past_medical_hist/past_mh_rec.jsp" target="hrmainFrame">Past Medical History Record</a><br>
<%}%>

</font></span>
<%}if(bolGrantAll || vAuthList.indexOf("SOCIAL HISTORY") != -1){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4">  <strong><font color="#FFFFFF">SOCIAL HISTORY </font></strong></div>
<span class="branch" id="branch4"><font color="#FFFFFF">
 <img src="../../images/broken_lines.gif"><a href="./social_hist/sh_entry.jsp" target="hrmainFrame"> Social History Entry</a><br>
 <img src="../../images/broken_lines.gif"> <a href="./social_hist/sh_rec.jsp" target="hrmainFrame">Social History Record</a><br></font></span>
<%}if(bolGrantAll || vAuthList.indexOf("OB GYN HISTORY") != -1){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder5"> <strong><font color="#FFFFFF">OB GYN HISTORY </font></strong></div>
<span class="branch" id="branch5"><font color="#FFFFFF"> <img src="../../images/broken_lines.gif"><a href="./ob_gyn/og_entry.jsp" target="hrmainFrame"> OB GYN History Entry</a><br>
  <img src="../../images/broken_lines.gif"> <a href="./ob_gyn/og_rec.jsp" target="hrmainFrame">OB GYN History Record</a><br></font></span>
<%}if(bolGrantAll || vAuthList.indexOf("CLINIC VISIT LOG") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
  <strong><font color="#FFFFFF">CLINIC VISIT LOG</font></strong></div>
<span class="branch" id="branch6"> <font color="#FFFFFF">
<%if(bolIsAUF){%>
<img src="../../images/broken_lines.gif"> <a href="clinic_visit_log/program_members.jsp" target="hrmainFrame">AUFHP Dependents</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="clinic_visit_log/log_main.jsp" target="hrmainFrame">Log</a><br>
<%if(bolIsAUF){%>
	<img src="../../images/broken_lines.gif"> <a href="clinic_visit_log/listings_main.jsp" target="hrmainFrame">Listings</a><br>
	<img src="../../images/broken_lines.gif"> <a href="clinic_visit_log/accredited_physicians_mgmt.jsp" target="hrmainFrame">ACCREDITED PHYSICIANS MGMT</a><br>
<%}else{%>
<img src="../../images/broken_lines.gif"> <a href="clinic_visit_log/visit_listings.jsp" target="hrmainFrame">Listings</a><br>
<%}%>
</font></span>

<!--
<img src="../../images/small_white_box.gif" width="7" height="7" border="0">
<strong><font color="#FFFFFF" face="Geneva, Arial, Helvetica, sans-serif">
	<a href="clinic_visit_log/accredited_physicians_mgmt.jsp" target="hrmainFrame">ACCREDITED PHYSICIANS MGMT</a></font></strong><br>
-->		
<%}if(bolGrantAll || vAuthList.indexOf("MEDICATIONS MANAGEMENT") != -1){isAuthorized=true;%>
 <div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder7">
<strong><font color="#FFFFFF">MEDICATIONS MANAGEMENT </font></strong></div>
<span class="branch" id="branch7"> <font color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="medications_mgmt/medication.jsp" target="hrmainFrame">Medication</a><br>
<img src="../../images/broken_lines.gif"> <a href="medications_mgmt/prescriptions.jsp" target="hrmainFrame">Prescriptions</a> <br>
<%if(false){%>
	<img src="../../images/broken_lines.gif"> <a href="medications_mgmt/medication_log.jsp" target="hrmainFrame">Medication Log/Tracking </a><br>
<%}
if(bolIsSchool){%>
<img src="../../images/broken_lines.gif"> <a href="medications_mgmt/authorization.jsp" target="hrmainFrame">Parent/Guardian Consent</a><br>
<%}%>
</font></span>

<%}if(bolGrantAll || vAuthList.indexOf("IMMUNIZATIONS") != -1){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8">
<strong><font color="#FFFFFF">IMMUNIZATIONS</font></strong></div>
<span class="branch" id="branch8"><font color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="immunizations/immunizations_entry.jsp" target="hrmainFrame">Add/Update Record</a><br>
<img src="../../images/broken_lines.gif"> <a href="immunizations/immunizations_listings.jsp" target="hrmainFrame">Listings</a><br>
</font></span>
<%}if(bolGrantAll || vAuthList.indexOf("DENTAL") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch12');swapFolder('folder12')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder12"><strong><font color="#FFFFFF"> DENTAL STATUS</font></strong></div>
<span class="branch" id="branch12"><font color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="dental/dental_status_setup.jsp" target="hrmainFrame"> Manage Dental status</a><br>
<img src="../../images/broken_lines.gif"> <a href="dental/dental_entry.jsp" target="hrmainFrame"> Add/Update Record</a><br>
<img src="../../images/broken_lines.gif"> <a href="dental/statistics.jsp" target="hrmainFrame"> Dental Statistics</a><br>
<%if(strSchCode.startsWith("UB")){%>
	<img src="../../images/broken_lines.gif"> <a href="./dental/dental_medical_exam/menu_link.jsp" target="hrmainFrame"> Dental Medical Examination</a><br>
<%}%>
</font></span>
<%}if(bolGrantAll || vAuthList.indexOf("REPORTS") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch9');swapFolder('folder9')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder9">
<strong><font color="#FFFFFF">REPORTS</font></strong></div>
<span class="branch" id="branch9"><font color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"><a href="./report/complete_health_record.jsp" target="hrmainFrame">Complete Health Record</a><br>
<img src="../../images/broken_lines.gif"><a href="./report/blood_group_report.jsp" target="hrmainFrame">Blood Grouping</a><br>
<img src="../../images/broken_lines.gif"><a href="./report/clinic_vlog_rpt.jsp" target="hrmainFrame">Clinic Visit Logs</a><br>
<img src="../../images/broken_lines.gif"><a href="./report/immunization_rpt.jsp" target="hrmainFrame">Immunization</a><br>
<img src="../../images/broken_lines.gif"><a href="./report/medical_history.jsp" target="hrmainFrame">Medical History</a><br>

<%if(strSchCode.startsWith("VMA")){%>
	<img src="../../images/broken_lines.gif"><a href="./VMA_health_exam_report/health_exam_entry.jsp" target="hrmainFrame">Medical Examination</a><br>
<%}%>
<%if(strSchCode.startsWith("CSA")){%>
	<img src="../../images/broken_lines.gif"><a href="./VMA_health_exam_report/health_exam_entry_csa.jsp" target="hrmainFrame">Medical Examination</a><br>
<%}%>
<%if(strSchCode.startsWith("SPC")){%>
	<img src="../../images/broken_lines.gif"><a href="./VMA_health_exam_report/health_exam_main.jsp" target="hrmainFrame">Medical Examination</a><br>
	<img src="../../images/broken_lines.gif"><a href="./report/parent_consent/parent_consent.jsp" target="hrmainFrame">Parent's Consent</a><br>
<%}%>
<%if(strSchCode.startsWith("SPC")){%>
	<img src="../../images/broken_lines.gif"> <a href="./report/physical_examination_report.jsp" target="hrmainFrame">Print Physical Examination Report</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./report/student_attending_physician.jsp" target="hrmainFrame">Manage Student Attending Physician</a><br>
<%}%>
<%if (false){%>
<img src="../../images/broken_lines.gif"> <a href="#">Health Statistical Listing</a><br><%}%>
</font> </span>
<%}
if(false)
if(bolGrantAll || vAuthList.indexOf("ALERT") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch10');swapFolder('folder10')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder10">
<strong><font color="#FFFFFF">ALERT</font></strong></div>
 <span class="branch" id="branch10"><font color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="#">Alert Parameters</a><br>
<img src="../../images/broken_lines.gif"> <a href="#">View Alert(s)</a></font> </span>
 <%}///System.out.println(strSchCode);System.out.println(vLeaveApplication);
if(strSchCode.startsWith("TSUNEISHI") && vLeaveApplication.indexOf("LEAVE APPLICATION") != -1 ){isAuthorized=true;%>
<img src="../../images/arrow_blue.gif" border="0">
<strong><a href="../HR/hr_index.htm" target="_top"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Leave Application</font></a></strong>
<%}

if(strUserId == null)
	strErrMsg = "Session timeout. Please login again.";
else if(!isAuthorized)
	strErrMsg = "You are not authorized to view any link in this page. Please contact system admin for access permission.";
if(strErrMsg == null)
	strErrMsg = "";
%>
<font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"><%=strErrMsg%></font>
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>
