<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

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
<link href="../../css/maintenancemainlinkscss.css" rel="stylesheet" type="text/css">
<link href="../../css/treelinkcss.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#C39E60" onLoad="MM_preloadImages('../../images/home_small_admin_rollover.gif','../../images/help_small_admin_rollover.gif','../../images/logout_admin_rollover.gif')">
<style>
.trigger{
	cursor: hand;
	cursor: pointer;
	
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
      <td bgcolor="#E9E0D1" width="6%">&nbsp;</td>
      <td height="25" bgcolor="#E9E0D1"><a href="../main%20files/admin_staff_home_button_content.htm" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
        </a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
        <input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3">
        </a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
        </a></td>
    </tr>
    <input type="hidden" name="logout_url" value="../ADMIN_STAFF/main%20files/admin_staff_bottom_content.htm">
    <input type="hidden" name="body_color" value="#C39E60">
  </table>
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

boolean bolIsLNU = false;
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
bolIsLNU = strSchCode.startsWith("LNU");


boolean bolShow = true;

if(!strSchCode.startsWith("CIT"))
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission Maintenance","SET SCHOOL YEAR & TERM")!=0){isAuthorized=true;%>
<div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
  <a href="school_year/sy.jsp" target="admissionmainFrame">SET SCHOOL YEAR &amp;
  TERM</a> </font></strong></div>
<%} if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission Maintenance","ADMISSION SCHEDULING")!=0){isAuthorized=true;%>
<div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
  <a href="admission_scheduling/admission_sched.jsp" target="admissionmainFrame">ADMISSION
  SCHEDULING </a></font></strong></div>
<%}
if(!bolIsLNU) 
	if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission Maintenance","ENTRANCE EXAM/INTERVIEW")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">PLACEMENT EXAM</font></strong></div>
<span class="branch" id="branch3"> <font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"></font>
<%
if(strSchCode.startsWith("UI")) {
	if( comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission Maintenance","Exam SubType")!=0)
		bolShow = true;
	else	
		bolShow = false;
}else 
	bolShow = true;
if(bolShow){%>
<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="entrance_exam_interview/subtype_create.jsp" target="admissionmainFrame">Exam SubType Creation</a></font><br>
<%}%>
<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="entrance_exam_interview/exam_sched.jsp" target="admissionmainFrame">Exam/Interview Scheduling</a></font><br>
<%if(strSchCode.startsWith("CIT")){%>
	<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="entrance_exam_interview/copy_exam_sched.jsp" target="admissionmainFrame">Copy Previous Exam Schedule</a></font><br>
<%}%>
<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../admission/admission_registration_main_link.jsp" target="admissionmainFrame">Create/Edit Applicant </a></font><br>
<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="entrance_exam_interview/applicant_scheduling.jsp" target="admissionmainFrame">Applicant Scheduling</a></font><br>
<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="entrance_exam_interview/applicant_sched_view.jsp" target="admissionmainFrame">View Applicant Schedule</a></font><br>
<%if(strSchCode.startsWith("CGH")){
	if(strSchCode.startsWith("CIT")){%>
		<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="entrance_exam_interview/applicant_master_list_cit.jsp" target="admissionmainFrame">Applicant Master List</a></font><br>
	<%}else{%>
		<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="entrance_exam_interview/applicant_master_list.jsp" target="admissionmainFrame">Applicant Master List</a></font><br>
	<%}%>	
<%}
if(strSchCode.startsWith("UI")) {
	if(comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission Maintenance","Result Encoding")!=0)
		bolShow = true;
	else	
		bolShow = false;
}else 
	bolShow = true;

if(strSchCode.startsWith("CIT")){
	bolShow = false;
	//show the result encoding only for guidance.
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Guidance & Counseling","Result Encoding",request.getRemoteAddr(),null);
	if(iAccessLevel > 0)
		bolShow = true;
}


if(bolShow){%>
<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="entrance_exam_interview/exam_interview_encode_result.jsp" target="admissionmainFrame">Result Encoding/Viewing</a></font><br>
<%}
bolShow = true;

 if (strSchCode.startsWith("CGH")) {%> 
<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="entrance_exam_interview/set_applicant_interview.jsp" target="admissionmainFrame">Set Applicant Interview</a></font><br>
<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="entrance_exam_interview/edit_applicant_interview.jsp" target="admissionmainFrame">Review Applicant Interview</a></font><br>
<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="entrance_exam_interview/view_applicant_enrichment.jsp" target="admissionmainFrame">Applicant Enrichment Status</a></font><br>
<%}else{

if(strSchCode.startsWith("UI")) {
	if(comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission Maintenance","Result Encoding")!=0)
		bolShow = true;
	else	
		bolShow = false;
}else 
	bolShow = true;
if(bolShow){

	if(strSchCode.startsWith("CIT")){%> 
		<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../admission/entrance_admission_slip_cit_final.jsp" target="admissionmainFrame">Admission Slip</a></font><br>
	<%}else{%>
		<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../admission/entrance_admission_slip.jsp" target="admissionmainFrame">Admission Slip</a></font><br>
	<%}%>
<%}
}%>
<%//show only if UDMC
if(strSchCode.startsWith("UDMC")){%>
	<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./other_report/new_stud_prev_school.jsp" target="admissionmainFrame">Student List From Previous School</a></font><br>
<%}if(strSchCode.startsWith("AUF")){%>
	<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./applicant_status/encode_application_stat_auf.jsp" target="admissionmainFrame">Encode Application Status</a></font><br>
<%}%>
</span>
<%}
if(!bolIsLNU && !strSchCode.startsWith("CGH") ) 
 if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission Maintenance","APPLICANT STATUS")!=0){isAuthorized=true;%>
<div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
  <a href="applicant_status/applicant_status_main.jsp" target="admissionmainFrame">APPLICANT
  STATUS </a></font></strong></div>
<%}%>
</span>
<%
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission Maintenance","STUDENT SCHEDULE")!=0){isAuthorized=true;%>
<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../../images/small_white_box.gif" width="7" height="7"> <a href="../enrollment/reports/student_sched.jsp" target="admissionmainFrame"><strong>Student Schedule</strong></a><br>
</font>
<%}
if(strSchCode.startsWith("CIT"))
	if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission Maintenance","Student Tracker")!=0){isAuthorized=true;%>
		 <img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../guidance/SPR/CIT/student_personal_data_limited.jsp" target="admissionmainFrame">Student Personal Information Sheet</a></font></strong><br>
	
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
if(dbOP != null) dbOP.cleanUP();
%>
