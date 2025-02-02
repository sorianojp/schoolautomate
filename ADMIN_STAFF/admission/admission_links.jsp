<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
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
      <td bgcolor="#E9E0D1" width="6%">&nbsp;</td>
      <td height="25" bgcolor="#E9E0D1"><a href="../main%20files/admin_staff_home_button_content.htm" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()" ><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
        <input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3">
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

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "LNU";

if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","COURSES OFFERED")!=0){isAuthorized=true;%>

<div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="admission_courses_offered.jsp" target="admissionFrame">COURSES OFFERED</a></font></strong></div>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","COURSES CURRICULUM")!=0){isAuthorized=true;%>
<div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="curriculum_page1.jsp" target="admissionFrame">COURSES CURRICULUM </a></font></strong></div>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","COURSES FEES")!=0){isAuthorized=true;%>
<div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="admission_courses_fees.jsp" target="admissionFrame">COURSES FEES</a></font></strong></div>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","REQUIREMENTS")!=0){isAuthorized=true;%>
<div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="admission_courses_requirements.jsp" target="admissionFrame">REQUIREMENTS</a></font></strong></div>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","ADMISSION SCHEDULES")!=0){isAuthorized=true;%>
<div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="admission_admission_schedules.jsp" target="admissionFrame">ADMISSION SCHEDULES </a></font></strong></div>
<%}if(false)
	if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","EXAMINATION RESULTS")!=0){isAuthorized=true;%>
<div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="admission_scholar_exam_result.jsp" target="admissionFrame">EXAMINATION RESULTS </a></font></strong></div>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","ACCREDITED SCHOOLS LIST")!=0){isAuthorized=true;%>
<div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="admission_accredited_school.jsp" target="admissionFrame">ACCREDITED SCHOOLS LIST</a></font></strong></div>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","REGISTRATION")!=0){isAuthorized=true;%>
<div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="admission_registration_main.jsp" target="admissionFrame">REGISTRATION</a></font></strong></div>

<%}
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","STUDENT INFO MGMT")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">STUDENT'S INFO MGMT</font></strong></div>
<span class="branch" id="branch3"> <font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"></font>
<%
boolean bolShow = true;
if(strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("UB")) {
	if( comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","Student Info Mgmt-View/Edit")!=0)
		bolShow = true;
	else	
		bolShow = false;

}
if(strSchoolCode.startsWith("CIT")) 
	bolShow = false;

if(bolShow){%>
<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="stud_personal_info_page1.jsp" target="admissionFrame">View/Edit Information</a></font><br>
<%}
if(strSchoolCode.startsWith("CIT")) {%>
	<img src="../../images/broken_lines.gif"> <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../guidance/SPR/CIT/student_personal_data_limited.jsp" target="admissionFrame">Student Personal Information Sheet</a></font><br>
<%}%>

<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="upload_id_step1.jsp" target="admissionFrame">Upload/Delete Picture</a></font><br>
<%if(strSchoolCode.startsWith("LNU")){%>
	<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./create_old_stud_basicinfo.jsp" target="admissionFrame">Create Old Student Basic Information</a></font><br>
<%}else{
	bolShow = true;
	if(strSchoolCode.startsWith("UB")) {
		if( comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","Student Info Mgmt-Create Old Student Basic Info")!=0)
			bolShow = true;
		else	
			bolShow = false;
	
	}

if(bolShow){%>
	<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="old_student_info_mgmt_main.htm" target="admissionFrame">Create Old Student Basic Information</a></font><br>
<%}
}%>
<%
bolShow = true;
if(strSchoolCode.startsWith("UB")) {
	if( comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","STUDENT INFO MGMT-CRITICAL INFO")!=0)
		bolShow = true;
	else	
		bolShow = false;

}
if(bolShow) {%>
	<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./change_student_critical_info.jsp" target="admissionFrame">Change Student's Critical Information</a></font><br>
<%}
if(strSchoolCode.startsWith("PWC")) {%>
	<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./spis_recruitment_info.jsp" target="admissionFrame">Recruitment Info</a></font><br>
<%}
if(strSchoolCode.startsWith("SWU")) {%>
	<img src="../../images/broken_lines.gif" > <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../fee_assess_pay/payment/reg_form/cit_main.jsp" target="admissionFrame">Print Study Load</a></font><br>
<%}%>

</span>

<%if(!strSchoolCode.startsWith("UB")) {%>
<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder7">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">SEARCH</font></strong></div>

<span class="branch" id="branch7"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
	<img src="../../images/broken_lines.gif"> <a href="../../search/srch_stud.jsp" target="admissionFrame">Students</a><br>
	<img src="../../images/broken_lines.gif"> <a href="../../search/srch_stud_temp.jsp" target="admissionFrame">Temporary Students</a><br>
	<img src="../../images/broken_lines.gif"> <a href="../../search/srch_stud_enrolled.jsp" target="admissionFrame">OLD Stud Enrollment progress</a> 
	<%if(strSchoolCode.startsWith("PWC")) {%>
		<br><img src="../../images/broken_lines.gif"> <a href="./recruitment_report_summary.jsp" target="admissionFrame">Recruitment Listing</a> 
	<%}%>
 </font></span>
<%}//for UB only.. 

}%>

<%
boolean bolShow = false;
if(strSchoolCode.startsWith("UB")) {
	if( comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","SEARCH")!=0) {
		bolShow = true;
		isAuthorized=true;
	}
	else	
		bolShow = false;

}
if(bolShow){%>
<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder7">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">SEARCH</font></strong></div>

<span class="branch" id="branch7"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"> <a href="../../search/srch_stud.jsp" target="admissionFrame">Students</a><br>
<img src="../../images/broken_lines.gif"> <a href="../../search/srch_stud_temp.jsp" target="admissionFrame">Temporary Students</a><br>
<img src="../../images/broken_lines.gif"> <a href="../../search/srch_stud_enrolled.jsp" target="admissionFrame">OLD Stud Enrollment progress</a> </font> </span> 

<%}//for UB only.. %>


<%if(strSchoolCode.startsWith("FATIMA")) {
	if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Admission","HOLD UNHOLD")!=0){isAuthorized=true;%>
		<div> <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  		<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../user_admin/set_param/hold_unhold_student.jsp" target="admissionFrame">Hold - UnHold Student</a></font></strong></div>

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
