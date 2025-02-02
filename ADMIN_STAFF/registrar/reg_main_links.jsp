<%
String strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSem    = (String)request.getSession(false).getAttribute("cur_sem");
%>
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

function getSYTerm() {
	var strSYTerm = prompt('Please enter sy/Term. Sample 2009-0 or 2009-1 or 2009-2 . 0 = summer, 1 = 1st sem and 2 = seconed sem','<%=strSYFrom%>-<%=strSem%>');
	if(strSYTerm == null || strSYTerm.length == 0)
		return;
		
	if(strSYTerm.length != 6 || strSYTerm.indexOf("-") == -1) {
		alert("Please enter sy/term in syfrom-sem format.");
		return;
	}	
	var strSYFr = strSYTerm.substring(0,4);
	var strSYTo = eval(strSYFr)+ 1;
	
	//alert(strSYFr);
	//alert(strSYTo);
	//alert(strSYTerm.charAt(5));
	
	parent.regmainFrame.location = "../enrollment/reports/elist_print_new_WNU.jsp?sy_from="+strSYFr+
	"&sy_to="+strSYTo+"&semester="+strSYTerm.charAt(5);
	return;
}
</script>
<form action="../../commfile/logout.jsp" method="post" target="_parent">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="10%" height="19" bgcolor="#E9E0D1">&nbsp;</td>
    <td width="90%" bgcolor="#E9E0D1"><a href="../main%20files/admin_staff_home_button_content.htm" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
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
WebInterface WI = new WebInterface();

String strUserId = (String)request.getSession(false).getAttribute("userId");

String strErrMsg = null; String strTemp = null;

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


String strSchCode    = (String)request.getSession(false).getAttribute("school_code");
String strInfo5      = (String)request.getSession(false).getAttribute("info5");
if(strSchCode == null)
	strSchCode = "";

//strSchCode = "FATIMA";\

boolean bolIsSEACREST = false;
if(strSchCode.startsWith("SWU") && strInfo5 != null && strInfo5.toLowerCase().startsWith("seacrest"))
	bolIsSEACREST = true;

///do not proceed if session timeout.
if(strUserId == null) {
	strErrMsg = "Session timeout. Please login again.";
	%>
	<font size="4" color="#FFFFFF"><%=strErrMsg%></font>	
<%return;}




	
//check if grade sheet encoding is locked. 
boolean bolIsGSLocked = new enrollment.SetParameter().isGsLocked(dbOP);

if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","CURRICULUM")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CURRICULUM
  </font></strong></div>
<span class="branch" id="branch1"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"> <a href="./curriculum/curriculum_course_classification.jsp" target="regmainFrame">Course Programs</a><br>
<img src="../../images/broken_lines.gif"> <a href="./curriculum/curriculum_college.jsp" target="regmainFrame">Colleges</a><br>
<img src="../../images/broken_lines.gif"> <a href="./curriculum/curriculum_department_main.jsp" target="regmainFrame">Departments</a><br>
<img src="../../images/broken_lines.gif"> <a href="./curriculum/curriculum_course.jsp" target="regmainFrame">Courses</a><br>
<%
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","CURRICULUM-Subjects Maintenance")!=0){%>
<img src="../../images/broken_lines.gif"><a href="curriculum/curriculum_subject.jsp" target="regmainFrame"> Subjects Maintenance</a><br>
<%if(strSchCode.startsWith("CIT") || strSchCode.startsWith("SWU") || strSchCode.startsWith("SPC") || strSchCode.startsWith("UB") || 
strSchCode.startsWith("NEU") || strSchCode.startsWith("UC") || strSchCode.startsWith("HTC") || strSchCode.startsWith("LDCU")){%>
	<img src="../../images/broken_lines.gif"><a href="curriculum/sub_equiv_advising.jsp" target="regmainFrame"> Equivalent Subject - For Advising</a><br>
<%}
//show to all.
if(true || strSchCode.startsWith("PIT") || strSchCode.startsWith("WNU") || strSchCode.startsWith("CSAB")){%>
	<img src="../../images/broken_lines.gif"><a href="curriculum/curriculum_subject_enrichment.jsp" target="regmainFrame"> Subject Without Credit Unit</a><br>
<%}

}%>
<img src="../../images/broken_lines.gif"> <a href="curriculum/curriculum_maintenance_page1.jsp" target="regmainFrame">Courses Curriculum</a><br>
<img src="../../images/broken_lines.gif"> <a href="curriculum/copy_curriculum.jsp" target="regmainFrame">Copy/Delete Curriculum</a><br>
<img src="../../images/broken_lines.gif"> <a href="./curriculum/course_offering_sub.jsp" target="regmainFrame">List Of Course Offering<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Subject</a><br>
<img src="../../images/broken_lines.gif"> <a href="curriculum/update_curriculum_with_zero_leclab.jsp" target="regmainFrame">Update Subject Unit (Subject Migrated during Grade Migration)</a><br>
</font>
</span> 
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","SUBJECT ACCREDITATION")!=0){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">SUBJECT
  ACCREDITATION </font></strong></div>
<span class="branch" id="branch3"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="./sub_creditation/schools_accredited.jsp" target="regmainFrame"><font face="Geneva, Arial, Helvetica, sans-serif">Schools
Accredited</font></a><br>
<!--
<img src="../../images/broken_lines.gif"> <a href="sub_creditation/subjects_accredited_main.jsp" target="regmainFrame"><font face="Geneva, Arial, Helvetica, sans-serif">Subjects
Accredited</font></a><br>-->
<%if(false){%>
<img src="../../images/broken_lines.gif"> <a href="./sub_creditation/grading_system.jsp" target="regmainFrame"><font face="Geneva, Arial, Helvetica, sans-serif">Schools Accredited Grading System</font></a></font><br>
<%}%>
</span>

<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES")!=0
				  || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grading System")!=0
				  || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grade Sheets")!=0
				  || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grade Releasing")!=0
				  || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grade Certification")!=0
				  || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grade Modification")!=0
				  || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grade Sheets Verification")!=0){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">GRADES</font></strong></div>
<span class="branch" id="branch4"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<%if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES")!=0 
				 || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grading System")!=0){%>
<img src="../../images/broken_lines.gif"> <a href="./grade/grading_system.jsp" target="regmainFrame">Grading System</a><br>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES")!=0 
				  || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grade Sheets")!=0){%>
<img src="../../images/broken_lines.gif"> 
<%if(bolIsGSLocked){%> Grade Sheets (Locked ...)<%}else{%><a href="grade/grade_sheet_main.jsp" target="regmainFrame">Grade Sheets</a><%}%><br>
<img src="../../images/broken_lines.gif"> <a href="grade/grade_sheet_final_report.jsp" target="regmainFrame">Grade Sheets Final Report</a><br>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES")!=0 
				  || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grade Releasing")!=0){
if(strSchCode.startsWith("UI") || strSchCode.startsWith("CGH") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("PHILCST") || strSchCode.startsWith("CSA") || strSchCode.startsWith("UL") || strSchCode.startsWith("EAC") || strSchCode.startsWith("UC")){//show batch printing.%>
<img src="../../images/broken_lines.gif"> <a href="grade/grade_release_main.jsp?print_by=1" target="regmainFrame">Grade Releasing</a><br>
<%}else{
	if(strSchCode.startsWith("SWU")){%>
		<img src="../../images/broken_lines.gif"> <a href="grade/grade_completion_swu.jsp" target="regmainFrame">Grade Completion</a><br>
	<%}%>
	<img src="../../images/broken_lines.gif"> <a href="grade/grade_release.jsp" target="regmainFrame">Grade Releasing</a><br>
<%}//end displaying only for UI.
}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES")!=0 
				  || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grade Certification")!=0){%>
	<%if(strSchCode.startsWith("EAC")){%>
		<img src="../../images/broken_lines.gif"> <a href="reports/OTR/otr.jsp?is_eac_cog=1" target="regmainFrame">Grade Certification</a><br>
	<%}else{%>
		<img src="../../images/broken_lines.gif"> <a href="grade/grade_certificate.jsp" target="regmainFrame">Grade Certification</a><br>
	<%}%>
	<%if(strSchCode.startsWith("UPH") && WI.getStrValue(strInfo5).startsWith("jonelta")){%>
	<img src="../../images/broken_lines.gif"> <a href="grade/grade_certificate_scholastic_ul.jsp" target="regmainFrame">Scholastic Records</a><br>
	<img src="../../images/broken_lines.gif"> <a href="grade/grade_certificate_cross_enrollee.jsp" target="regmainFrame">Cross Enrollee</a><br>
	<%}%>
	<%if(strSchCode.startsWith("UL") || strSchCode.startsWith("CDD")){%>
		<img src="../../images/broken_lines.gif"> <a href="grade/grade_certificate_scholastic_ul.jsp" target="regmainFrame">Scholastic Records</a><br>
	<%}%>
	
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES")!=0 
				  || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grade Sheets Verification")!=0){%>
	<%if(strSchCode.startsWith("WUP")){%>
		<img src="../../images/broken_lines.gif"> <a href="grade/grade_sheet_verify_wup.jsp" target="regmainFrame">Grade Sheets Verification(Final Grade)</a><br>
	<%}else if(strSchCode.startsWith("SWU")){%>
		<img src="../../images/broken_lines.gif"> <a href="grade/grade_sheet_verify_swu_main.jsp" target="regmainFrame">Grade Sheets Verification</a><br>
	<%}else{%>
		<img src="../../images/broken_lines.gif"> <a href="grade/grade_sheet_verify.jsp" target="regmainFrame">Grade Sheets Verification</a><br>
	<%}%>	
	<%if(bolGrantAll && strSchCode.startsWith("SWU")){%>
		<img src="../../images/broken_lines.gif"> <a href="grade/grade_sheet_verify.jsp" target="regmainFrame">Grade Sheet Unlock</a><br>
	<%}%>	
<%}
if(strSchCode.startsWith("CSA")){
	if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES")!=0 
				   || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grade Printing")!=0){%>
	<img src="../../images/broken_lines.gif"> <a href="grade/grade_sheet_print_per_faculty_main.jsp" target="regmainFrame">Grade Sheets Printing</a><br>
<%}
}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES")!=0 
				  || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grade Modification")!=0){%>
<img src="../../images/broken_lines.gif"> <a href="grade/grade_modification.jsp" target="regmainFrame">Grade Modification</a><br>
<img src="../../images/broken_lines.gif"> <a href="grade/convert_inc_failed.jsp" target="regmainFrame">Convert INC to Failed Grade</a> <br>

<%if(strSchCode.startsWith("CDD")){%>
	<img src="../../images/broken_lines.gif"> <a href="grade/student_permanent_record_print_cdd_main.jsp" target="regmainFrame">Student Permanent Record</a> <br>
<%}%>
<%if(strSchCode.startsWith("CIT")){%>
	<img src="../../images/broken_lines.gif"> <a href="grade/grade_sheet_encode_lock.jsp" target="regmainFrame">Unlock Grade</a> <br>
<%}%>

<%}%>
<%if(strSchCode.startsWith("EAC") && bolGrantAll){%>
	<img src="../../images/broken_lines.gif"> <a href="grade/grade_sheet_uploadCSV_EAC.jsp" target="regmainFrame">Grade CSV Upload</a> <br>
<%}%>
<%if(strSchCode.startsWith("SPC") && (bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADES-Grade Modification")!=0)){%>
	<img src="../../images/broken_lines.gif"> <a href="./grade/lock_grade_in_batch.jsp" target="regmainFrame">One click Locking of Grade</a> <br>
<%}%>
<%if(strSchCode.startsWith("UPH") && bolGrantAll && strInfo5 != null ){%>
	<img src="../../images/broken_lines.gif"> <a href="grade/grade_sheet_percent_computation_persub.jsp" target="regmainFrame">Encode Percent Computation Per Subject</a> <br>
	<img src="../../images/broken_lines.gif"> <a href="grade/grade_sheet_fix_grade_encoded_jonelta.jsp" target="regmainFrame">Fix Grade encoded </a> <br>
<%}%>
</font></span> 
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","OLD STUDENT DATA MANAGEMENT")!=0){isAuthorized=true;%>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./old_stud_data/old_stud_data_entry_main.jsp" target="regmainFrame">OLD STUDENT DATA MGMT</a></font></strong><br>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","ENTRANCE DATA")!=0){isAuthorized=true;%>
 <img src="../../images/small_white_box.gif" width="7" height="7" border="0">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="entrance_data/entrance_data.jsp" target="regmainFrame">ENTRANCE DATA</a></font></strong><br>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","TOR ENCODING")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')">
	<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder5"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">TOR ENCODING</font></strong></div>
<span class="branch" id="branch5"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<%if(false){%>
<img src="../../images/broken_lines.gif"> <a href="./type_grade_entries/type_grade_entries.htm" target="regmainFrame">Manual TOR Encoding </a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="./type_grade_entries/tor_remarks.jsp" target="regmainFrame">Multiple Remarks Encoding</a><br>
<%if(strSchCode.startsWith("UC")){%>
	<img src="../../images/broken_lines.gif"> <a href="../admission/upload_id_step1.jsp" target="regmainFrame">Upload/Delete Picture of Student</a><br>
<%}%>
</font></span>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","TRANSFEREE INFO MAINTENANCE")!=0){isAuthorized=true;%>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="transferee_acc/main.jsp" target="regmainFrame">TRANSFEREE INFO MAINTENANCE</a></font></strong><br>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","CROSS_ENROLEE INFO MAINTENANCE")!=0){isAuthorized=true;%>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="cross_enrolee/cross_enrolee_data_entry.jsp" target="regmainFrame">CROSS-ENROLEE GRADE ENCODING</a></font></strong><br>
<%}
 if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","SUBJECT UNITS CREDITATION")!=0){isAuthorized=true;%>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0">
<!--
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="sub_creditation/sub_accredition_main.jsp" target="regmainFrame">SUBJECT UNITS CREDITATION</a></font></strong> <br>
-->
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="sub_creditation/sub_accredition_foreign_stud.jsp" target="regmainFrame">SUBJECT UNITS CREDITATION</a></font></strong> <br>
<%}
 if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","SECOND COURSE INFO MGMT")!=0){isAuthorized=true;%>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="change_course/second_course_data_entry.jsp" target="regmainFrame">SECOND COURSE INFO MGMT</a></font></strong> <br>
<%}
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","RESIDENCY STATUS MONITORING")!=0){isAuthorized=true;%>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="residency/residency_status.jsp" target="regmainFrame">RESIDENCY STATUS</a> </font></strong><br>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","STUDENT COURSE EVALUATION")!=0){isAuthorized=true;%>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="residency/stud_cur_residency_eval.jsp" target="regmainFrame">STUDENT COURSE EVALUATION</a> </font></strong>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","STUDENT IDs")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ID VALIDATION  <%if(strSchCode.startsWith("CIT")){%>and STUDY LOAD<%}%></font></strong></div>
<span class="branch" id="branch6"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<%if(strSchCode.startsWith("WNU")){%>
	<img src="../../images/broken_lines.gif"> <a href="student_ids/validate_and_print_reg_form.jsp" target="regmainFrame">Confirm Enrollment and Print COR</a><br>
<%}else if(strSchCode.startsWith("CIT")){%>
	<img src="../../images/broken_lines.gif"> <a href="student_ids/validate_and_print_reg_form.jsp" target="regmainFrame">Confirm Enrollment and Print Study Load</a><br>
<%}else if(!strSchCode.startsWith("VMUF")){%>
	<img src="../../images/broken_lines.gif"> <a href="student_ids/validate_and_print_reg_form.jsp" target="regmainFrame">Confirm Enrollment and Print Reg Form</a><br>
<%}else{%>
	<img src="../../images/broken_lines.gif"> <a href="student_ids/new_id.jsp" target="regmainFrame">New IDs </a><br>
	<img src="../../images/broken_lines.gif"> <a href="student_ids/validate_ids.jsp" target="regmainFrame">Old IDs </a></font><br>
<%}%>
</span>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GRADUATES")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch10');swapFolder('folder10')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder10"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">GRADUATES</font></strong></div>
<span class="branch" id="branch10"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"> <a href="graduates/grad_mgt.jsp" target="regmainFrame">Graduates Management</a><br>
<img src="../../images/broken_lines.gif"> <a href="graduates/grad_candidates.jsp" target="regmainFrame">Candidates for Graduation</a><br>
<%if(bolIsSEACREST){%>
	<img src="../../images/broken_lines.gif"> <a href="graduates/graduate_status_tracker_report.jsp" target="regmainFrame">Encode Graduate Status</a><br>
<%}
if(strSchCode.startsWith("SWU")){%>
	<img src="../../images/broken_lines.gif"> <a href="graduates/grad_stat_report.jsp" target="regmainFrame">Graduation Statistics</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="graduates/grad_search.jsp" target="regmainFrame">Search Records</a></font><br>
</span> 

<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","REPORTS")!=0){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder7">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">REPORTS</font></strong></div>
<span class="branch" id="branch7"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<%if(strSchCode.startsWith("UB")){%>
	<img src="../../images/broken_lines.gif" width="15" height="15"><a href="../fee_assess_pay/reports/other/clearance_account_slip_UB.jsp" target="regmainFrame"> Cleanrance Slip</a><br>
<%}if(strSchCode.startsWith("DBTC")){%>
	<img src="../../images/broken_lines.gif" width="15" height="15"><a href="reports/stud_directory_college.jsp" target="regmainFrame"> Student's Directory College</a><br>
<%}if(strSchCode.startsWith("PHILCST")){%>
	<img src="../../images/broken_lines.gif"> <a href="../fee_assess_pay/reports/promi_main.jsp?show=1" target="regmainFrame">Promisory Note</a> <br>
	<img src="../../images/broken_lines.gif"> <a href="../fee_assess_pay/reports/admission_slip_main.jsp" target="regmainFrame">Admission Slip</a> <br>
<%}if(strSchCode.startsWith("CLDH")){%>
	<img src="../../images/broken_lines.gif"> <a href="../enrollment/reports/drop_subject_list.jsp" target="regmainFrame">Dropped Subject Student List</a> <br>
<%}if(strSchCode.startsWith("UI") || strSchCode.startsWith("WNU") || strSchCode.startsWith("UPH")){%>
	<img src="../../images/broken_lines.gif"> <a href="./ched_reports/ched_reports.jsp" target="regmainFrame">Ched Report</a> <br>
<%}if(strSchCode.startsWith("UDMC") || true){%>
	<img src="../../images/broken_lines.gif"> <a href="../user_admin/set_param/set_msg_user.jsp" target="regmainFrame">Message System</a> <br>
<%}if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC") || strSchCode.startsWith("VMUF") || 
	strSchCode.startsWith("AUF") || strSchCode.startsWith("PHILCST") || strSchCode.startsWith("CIT") || 
	strSchCode.startsWith("UL") || strSchCode.startsWith("CSA") || strSchCode.startsWith("SPC") || 
	strSchCode.startsWith("CDD") || strSchCode.startsWith("UB") || strSchCode.startsWith("UC")){%>
	<img src="../../images/broken_lines.gif"> <a href="../registrar/reports/other/other.jsp" target="regmainFrame">Other Reports</a><br>
<%}if(strSchCode.startsWith("UPH") && strInfo5 == null && false){%>
	<img src="../../images/broken_lines.gif"> <a href="../registrar/reports/other/uph/other_uphd.jsp" target="regmainFrame">Other Reports</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="../registrar/reports/elist_page1.jsp" target="regmainFrame">Enrollment List</a><br>
<img src="../../images/broken_lines.gif"> <a href="../registrar/reports/enrollment_reports.htm" target="regmainFrame">Enrollment Reports </a><br>
<%
if(strSchCode != null && strSchCode.startsWith("UI"))
	strTemp = "../fee_assess_pay/reports/cert_enrol_billing_ched_ui.jsp";
else
	strTemp = "../fee_assess_pay/reports/cert_enrol_billing_ched.jsp";
if(!strSchCode.startsWith("UB")){%>
	<img src="../../images/broken_lines.gif"> <a href="<%=strTemp%>" target="regmainFrame">Certificate of Enrolment and Billing (CHED)</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="../registrar/reports/tesda_reports.htm" target="regmainFrame">TESDA REPORTS </a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/rep_promo_grad.jsp" target="regmainFrame">
<%if(strSchCode.startsWith("AUF")){%>
<a href="reports/elist_page1.jsp?form_19=1" target="regmainFrame">Form 19</a>
<%}else{%>
<a href="reports/rep_promo_grad.jsp" target="regmainFrame">
	<%if(strSchCode.startsWith("UDMC")){%>Summary Of Ratings<%}else{%>Promotional Report<%}%></a>
<%}%><br>
<img src="../../images/broken_lines.gif"> <a href="reports/rec_can_grad.jsp" target="regmainFrame">Records of Candidate for Graduation</a><br>
	<%if(!strSchCode.startsWith("FATIMA")){%>
	<img src="../../images/broken_lines.gif"> <a href="reports/otr_can_grad.jsp" target="regmainFrame">Official Transcript of Records <br>of Candidate for Graduation</a><br>
	<img src="../../images/broken_lines.gif"> <a href="reports/OTR/otr.jsp" target="regmainFrame">Official Transcript of Records</a><br>
<%}
if(false){//not needed.%>
<img src="../../images/broken_lines.gif"> <a href="./grade/registrar_grades_grade_releasing_page.htm" target="regmainFrame">Consolidated Enrollment Report on Foreign Students</a><br>
<%}
if(false){//not needed.%>
<img src="../../images/broken_lines.gif"> <a href="reports/stud_term_stat.htm" target="regmainFrame">Student's Term Status</a><br>
<%}%>
</font><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"> <a href="reports/student_list_w_inc.jsp" target="regmainFrame">List of Students Per Grades Status</a><br>
<img src="../../images/broken_lines.gif"> <a href="grade/report/grade_encoding_stat.jsp" target="regmainFrame"> Grade Encoding Status</a><br>
<%if(strSchCode.startsWith("CGH") || strSchCode.startsWith("VMUF") || strSchCode.startsWith("UDMC") || 
strSchCode.startsWith("EAC") || strSchCode.startsWith("UB") || strSchCode.startsWith("SPC") || strSchCode.startsWith("UC") || strUserId.equals("1770") ){%>
<img src="../../images/broken_lines.gif"> <a href="./reports/tc_main.jsp" target="regmainFrame">Transfer Of Credential Information</a><br>
<%}//show tc to CGH only.
if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC")){%>
<img src="../../images/broken_lines.gif"><a href="./reports/grade_per_subject.jsp" target="regmainFrame">Grade(Finals) Per subject</a><br>
<%}
if(strSchCode.startsWith("UC")){%>
	<img src="../../images/broken_lines.gif"><a href="./reports/list_of_stud_with_failed_grade_uc.jsp" target="regmainFrame">Grade Status Report With Address</a><br>
	<img src="../../images/broken_lines.gif"><a href="./reports/final_grade_report_uc.jsp" target="regmainFrame">Final Grade Report (Form 19)</a><br>
<%}
if(strSchCode.startsWith("VMA")){%>
	<img src="../../images/broken_lines.gif"><a href="./reports/final_grade_report_VMA.jsp" target="regmainFrame">Summary Of Grades</a><br>
<%}%>
<%if(strSchCode.startsWith("UPH") && strInfo5 == null ){%>
	<img src="../../images/broken_lines.gif"> <a href="./reports/uph/cert_main_uph.jsp" target="regmainFrame">Certification</a> <br>
<%}%>
<%if(strSchCode.startsWith("UB")){%>
	<img src="../../images/broken_lines.gif"> <a href="./reports/application_grad_ub.jsp" target="regmainFrame">Application for Graduation</a> <br>
<%}%>
<%if(strSchCode.startsWith("CIT")){%>
	<img src="../../images/broken_lines.gif"> <a href="../enrollment/subjects/cp/print_per_college_dept_offering.jsp?is_registrar=1" target="regmainFrame">Pass/Fail Report</a> <br>
	<img src="../../images/broken_lines.gif"> <a href="./reports/other/cit/freshmen_subject_grade_report.jsp" target="regmainFrame">Freshmen enrollment report</a> <br>
<%}%>
<%if(strSchCode.startsWith("PWC")){%>
	<img src="../../images/broken_lines.gif"> <a href="../../search/srch_GSPIS.jsp" target="regmainFrame">Students Info from GSPIS</a> <br>
<%}%>
<%if(strSchCode.startsWith("SWU")){%>
	<img src="../../images/broken_lines.gif"> <a href="./reports/other/spc/deliberation_report.jsp" target="regmainFrame">INE/INR report</a> <br>
	<img src="../../images/broken_lines.gif"> <a href="./reports/OTR/otr.jsp?is_swu_gpa=1" target="regmainFrame">Print Grades Point Average</a> <br>
<%}%>
<%if(strSchCode.startsWith("DBTC")){%>
	<img src="../../images/broken_lines.gif"> <a href="../user_admin/overload_student_report.jsp" target="regmainFrame">Student Overload Report</a> <br>
	<img src="../../images/broken_lines.gif"> <a href="../user_admin/sys_track/final_gs_mod_report.jsp" target="regmainFrame">Grade Modification Report</a> <br>
<%}%>
<%if(strSchCode.startsWith("HTC")){%>
	<img src="../../images/broken_lines.gif"> <a href="../enrollment/subjects/class_program_persection_term_htc.jsp" target="regmainFrame">Subject Enrollment Status</a> <br>
<%}%>
<%if(strSchCode.startsWith("DLSHSI") && false){//moved to fee_assessment_payment-reports%>
	<img src="../../images/broken_lines.gif"> <a href="./reports/other/dlshsi/monitoring_and_budgeting_report.jsp" target="regmainFrame">Monitoring and Budget</a> <br>
<%}%>
</font>
</span> 
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","ADMISSION REQUIREMENTS")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ADMISSION
  REQUIREMENTS </font></strong></div>
<span class="branch" id="branch8"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"> <a href="admission_requirements/course_requirement.jsp" target="regmainFrame"> Admission Requirements</a><br>
<img src="../../images/broken_lines.gif"> <a href="admission_requirements/stud_admission_req.jsp" target="regmainFrame">Student Admission </a><br>
<img src="../../images/broken_lines.gif"> <a href="admission_requirements/copy_requirement.jsp" target="regmainFrame">Copy Requirements</a><br>
<img src="../../images/broken_lines.gif"> <a href="admission_requirements/report_admission.jsp" target="regmainFrame">Admission Requirements Report</a><br>
<%if(strSchCode.startsWith("UC")){%>
	<img src="../../images/broken_lines.gif"> <a href="admission_requirements/other_requirement_uc.jsp" target="regmainFrame">Set Other Requirement</a><br>
<%}%>
	<img src="../../images/broken_lines.gif"> <a href="admission_requirements/allow_block_temp_id_advising.jsp" target="regmainFrame">Allow/Block Temp ID for Advising</a><br>
</font></span><span class="branch"> </span>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","TOP STUDENTS")!=0){isAuthorized=true;
if(strSchCode.startsWith("UDMC"))
	strTemp = "?gwa_con=3&gwa_fr=1&gwa_to=1.75&final_grade_con=1&final_grade=2.01";
else	
	strTemp = "";%>
 <img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="top_students/top_stud.jsp<%=strTemp%>" target="regmainFrame">TOP STUDENTS </a></font></strong><br>
<%}
if(strSchCode.startsWith("UI"))
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","HONOR STUDENT")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch9');swapFolder('folder9')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder9"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">HONOR 
  STUDENT </font></strong></div>
<span class="branch" id="branch9"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"> <a href="reports/OTR/otr.jsp?honor_point=1" target="regmainFrame"> View/Print</a><br>
<img src="../../images/broken_lines.gif"> <a href="admission_requirements/stud_admission_req.jsp" target="regmainFrame">List Honor Student</a><br>
</font></span><span class="branch"> </span>

<%}
if(strSchCode.startsWith("CIT")){
	if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","LOCK ADVISING")!=0){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch20');swapFolder('folder20')"> <img src="../../images/box_with_plus.gif"  border="0" id="folder20">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Block/Unblock Advising</font></strong></div>
	<span class="branch" id="branch20"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		<img src="../../images/broken_lines.gif"> <a href="../enrollment/advising_dept_lock/lock_stud.jsp" target="regmainFrame">Block/Unblock</a> <br>
		<img src="../../images/broken_lines.gif"> <a href="../enrollment/advising_dept_lock/unlock_stud.jsp" target="regmainFrame">Unblocked Student Listing</a> <br>
	</font></span>
<%}
	if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","CHED SCHOLAR")!=0){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch21');swapFolder('folder21')"> <img src="../../images/box_with_plus.gif"  border="0" id="folder21">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CHED Scholar</font></strong></div>
	<span class="branch" id="branch21"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		<img src="../../images/broken_lines.gif"> <a href="./cit/ched/setup_type.jsp" target="regmainFrame">Manage Scholarship Type</a> <br>
		<img src="../../images/broken_lines.gif"> <a href="./cit/ched/assign_student.jsp" target="regmainFrame">Assign Scholarship Type</a> <br>
		<img src="../../images/broken_lines.gif"> <a href="./cit/ched/master_file.jsp" target="regmainFrame">Student Master File</a> <br>
	</font></span>
<%}

if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","Student Tracker")!=0){isAuthorized=true;%>
	 <img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../guidance/SPR/CIT/student_personal_data.jsp" target="regmainFrame">Student Personal Information Sheet</a></font></strong><br>

<%}
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","Update Year Level")!=0){isAuthorized=true;%>
	 <img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../admission/change_stud_critical_info_yrlevel.jsp" target="regmainFrame">Update Student's Year Level</a></font></strong><br>

<%}
if(strSchCode.startsWith("CIT")){
	if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","DROP SUBJECT")!=0){isAuthorized=true;%>
	 <img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../enrollment/change_subjects/change_subject_drop.jsp?registrar=1" target="regmainFrame">Drop Subject (With Grade)</a></font></strong><br>
<%}}

}
	if(strSchCode.startsWith("FATIMA")){
		if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","Document Request Tracking")!=0){isAuthorized=true;%>
	 	<img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./document_request_tracking/request_due_made.jsp?pgIndex=0" target="regmainFrame">Document Request Tracking</a></font></strong><br>

<%}
}
	if(strSchCode.startsWith("UPH") || strSchCode.startsWith("AUF") || strSchCode.startsWith("DLSHSI")){
		if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","DROP SUBJECT")!=0){isAuthorized=true;%>
	 <img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../enrollment/change_subjects/change_subject_drop.jsp?registrar=1" target="regmainFrame">Drop Subject (With Grade)</a></font></strong><br>

<%}
}
	if(strSchCode.startsWith("UB")){
		if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","GOOD MORAL CERTIFICATION")!=0){isAuthorized=true;%>
	 <img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../guidance/good_moral_cert/common_cert_main.jsp" target="regmainFrame">Good Moral Certification</a></font></strong><br>

<%}
}
	if(strSchCode.startsWith("FATIMA")){
		if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","ONLINE REGISTRATION")!=0){isAuthorized=true;%>
	 		<img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../PARENTS_STUDENTS/onlinepayment/register_new_admin.jsp" target="regmainFrame">Online Payment Registration</a></font></strong><br>
		<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","OTR")!=0){isAuthorized=true;%>
	 		<img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="reports/OTR/otr.jsp" target="regmainFrame">OTR</a></font></strong><br>
		<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","OTR-GRAD")!=0){isAuthorized=true;%>
	 		<img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="reports/otr_can_grad.jsp" target="regmainFrame">OTR-Candidate of Graduation</a></font></strong><br>

<%}
}
//comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Enrollment","CHANGE OF SUBJECTS-REASSIGN") !=0
if (strSchCode.startsWith("WUP")){
	if(bolGrantAll ||  comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Enrollment","CHANGE OF SUBJECTS") !=0 ){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch25');swapFolder('folder25')">
		<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder25"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CHANGE OF SUBJECTS </font></strong></div>
	<span class="branch" id="branch25"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
	<%if(bolGrantAll ||  comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Enrollment","CHANGE OF SUBJECTS-DROP") !=0 ){%>
		<img src="../../images/broken_lines.gif"> <a href="../../ADMIN_STAFF/enrollment/change_subjects/change_subject_drop.jsp" target="regmainFrame">Drop/Withdraw</a><br>
	<%}%>
	<img src="../../images/broken_lines.gif"> <a href="../../ADMIN_STAFF/enrollment/change_subjects/change_subject_add.jsp" target="regmainFrame">Add</a><br>
	<img src="../../images/broken_lines.gif"> <a href="../../ADMIN_STAFF/enrollment/change_subjects/add_subj_other_course.jsp" target="regmainFrame">Add Subject(Other Course)</a><br>
	<img src="../../images/broken_lines.gif"> <a href="../../ADMIN_STAFF/enrollment/change_subjects/change_schedule.jsp" target="regmainFrame">Change Schedule</a><br>
	<img src="../../images/broken_lines.gif"> <a href="../../ADMIN_STAFF/enrollment/change_subjects/re_enrolment.jsp" target="regmainFrame">Re-Enrolment</a><br>
	<%if(bolGrantAll ||  comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Enrollment","CHANGE OF SUBJECTS-MOVE") !=0 ){%>
		<img src="../../images/broken_lines.gif"> <a href="../../ADMIN_STAFF/enrollment/change_subjects/move_section_students_main.jsp" target="regmainFrame">Move Students </a><br>
	<%}if(bolGrantAll ||  comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Enrollment","CHANGE OF SUBJECTS-REASSIGN") !=0 ){%>
	<img src="../../images/broken_lines.gif"> <a href="../../ADMIN_STAFF/enrollment/change_subjects/re_assign_lec_lab.jsp" target="regmainFrame" title="Click to change units enrolled and Lec/Lab enrollment.">Re-Assign
	units enrolled (or) Lec/Lab enrollment</a><br>
	<%}//do not show for CPU.%>
	<img src="../../images/broken_lines.gif"> <a href="../../ADMIN_STAFF/enrollment/reports/student_sched.jsp" target="regmainFrame">Print New Student Load</a><br>
	
	</font></span>
	<%}
}
	if(strSchCode.startsWith("NEU")){
		if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","HOLD-UNHOLD")!=0){isAuthorized=true;%>
	 		<img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<a href="../user_admin/set_param/hold_unhold_student.jsp" target="regmainFrame"> Hold - UnHold Student</a></font></strong><br>

<%}
}
	if(strSchCode.startsWith("DLSHSI")){
		if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","HOLD-UNHOLD")!=0){isAuthorized=true;%>
	 		<img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<a href="../user_admin/set_param/hold_unhold_student.jsp" target="regmainFrame"> Hold - UnHold Student</a></font></strong><br>

		<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","Assign RFID") != 0) {%>
	 		<img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<a href="../user_admin/barcode_mgmt.jsp" target="regmainFrame"> Assign RFID to User</a></font></strong><br>
		<%}

}
	if(strSchCode.startsWith("AUF")){
		if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Registrar Management","Reports - Student Per Grades Status")!=0){isAuthorized=true;%>
	 		<img src="../../images/arrow_blue.gif"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<a href="reports/student_list_w_inc.jsp" target="regmainFrame">List of Students Per Grades Status</a><br>
		<%}

}


if(!isAuthorized)
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
