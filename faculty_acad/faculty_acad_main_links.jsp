<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Administrator's Links</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/treelinkcss.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
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
<link href="../css/administratorcss.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#63939C" onLoad="MM_preloadImages('../images/home3_rollover.gif','../images/help3_rollover.gif','../images/logout3_rollover.gif')">
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
<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
//check if user is logged in, if logged, check authentication list here and allow the authentic user to access the system.
DBOperation dbOP = null;
CommonUtil comUtil = new CommonUtil();
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strErrMsg = null;

boolean bolGrantAll = false;
if(strUserId != null) {
	//open dbConnection here to check if user is registered already.
	try
	{
		dbOP = new DBOperation();
		//check if user has filled up the form.
		//check here the authentication of the user. 
		if(comUtil.IsSuperUser(dbOP,strUserId))
			bolGrantAll = true;	//grant all ;-)
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		strErrMsg = "error in opening connection.";
	}
}
else
	strErrMsg = "";

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsRestricted = false;
if(strSchCode.startsWith("DLSHSI")) {
	if(comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
										"Registrar Management","Grade Releasing - Restricted",request.getRemoteAddr(),
										null) > 0) {
		bolIsRestricted = true;//limit only college of logged in user.
	}
}	
boolean bolWithGrade = true;
if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC") || strSchCode.startsWith("CLDH"))
	bolWithGrade = false;
		
//System.out.println("testing : strErrMsg ="+strErrMsg);
if(strErrMsg != null && strErrMsg.length() > 0)
{%>
<font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif" size="2"><b><%=strErrMsg%></b></font>
<%//System.out.println("testing");
if(dbOP != null)
	dbOP.cleanUP();
return;
}
if(strUserId == null)
	strUserId = "";
%>

<form action="../commfile/logout.jsp" method="post" target="_parent">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="5%" height="19" bgcolor="#63939C">&nbsp;</td>
      <td width="95%" bgcolor="#63939C"><a  href="../commfile/logout.jsp?logout_url=../index.htm" target="_top" onMouseOver="window.status='Go back to home page'; MM_swapImage('Image2','','../images/home3_rollover.gif',1); return true" onMouseOut="MM_swapImgRestore()" ><img src="../images/home3.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../images/help3_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../images/help3.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a>
	  <a href="javascript:;" onMouseOver="MM_swapImage('Image3','','../images/logout3_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
	  <input type="image" src="../images/logout3.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
    </tr>
  </table>
<input type="hidden" name="logout_url" value="../faculty_acad/faculty_acad_bottom_content.htm">
<input type="hidden" name="body_color" value="#C39E60">
</form>

<%if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"Faculty/Acad. Admin")){%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CLASS 
  MANAGEMENT </font></strong></div>

<font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<span class="branch" id="branch1">  
<img src="../images/broken_lines_3.gif"> <a href="classman/syllabus/syllabus_new.jsp" target="rightFrame">Syllabus</a><br>
<%if(bolWithGrade){%>
	<img src="../images/broken_lines_3.gif"> <a href="classman/lp/lp_main_links.htm" target="rightFrame">Lesson Plan</a><br>
<%}%>
<!--
<img src="../images/broken_lines_3.gif"> <a href="classman/cm_requirements.jsp" target="rightFrame">Requirements</a><br>
-->
<img src="../images/broken_lines_3.gif"> <a href="classman/cm_assignment_main.htm" target="rightFrame">Assignments/Homeworks</a><br>
<%if(strSchCode.startsWith("CDD")){%>
	<img src="../images/broken_lines_3.gif"> <a href="../ADMIN_STAFF/sao/attendance_monitoring/attendance_main.jsp?is_faculty=1" target="rightFrame">Attendance Monitoring</a><br> 
<%}else{%>
	<img src="../images/broken_lines_3.gif"> <a href="classman/cm_attendance_main.jsp" target="rightFrame">Attendance</a><br>
<%}%>
<img src="../images/broken_lines_3.gif"> <a href="../ADMIN_STAFF/registrar/grade/grade_sheet.jsp" target="rightFrame">Grade Sheets</a><br>
<img src="../images/broken_lines_3.gif"> <a href="../ADMIN_STAFF/registrar/grade/grade_sheet_final_report.jsp" target="rightFrame">Grade Sheets Final Report</a><br>
<!--
<img src="../images/broken_lines_3.gif"> <a href="classman/cm_course_ref.jsp" target="rightFrame">Course Reference Materials</a><br>
-->
</span>
</font>

<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<%if(!strSchCode.startsWith("AUF")){%>
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../images/box_with_plus.gif" border="0" id="folder3"> 
  <strong>STUDENT'S PERFORMANCE</strong></div>
<span class="branch" id="branch3"> 
<%if(!strSchCode.startsWith("PIT") && !strSchCode.startsWith("UB")){%>
	<img src="../images/broken_lines_3.gif"> <a href="../ADMIN_STAFF/registrar/residency/residency_status.jsp" target="rightFrame">Unofficial TOR</a><br>
	<img src="../images/broken_lines_3.gif"> <a href="../ADMIN_STAFF/registrar/residency/stud_cur_residency_eval.jsp" target="rightFrame">Check List</a><br>
<%}%>
<img src="../images/broken_lines_3.gif"> <a href="stud/stud_acad.jsp" target="rightFrame">Academic Achievements</a> <br>
<img src="../images/broken_lines_3.gif"> <a href="stud/fieldwork/list_fieldwork.jsp" target="rightFrame">Fieldwork/OJT Profile</a> <br>
<img src="../images/broken_lines_3.gif"> <a href="stud/stud_non_acad.jsp" target="rightFrame">Non-academic Achievements</a> <br>
<%if(bolIsRestricted) {%>
	<img src="../images/broken_lines_3.gif"> <a href="../ADMIN_STAFF/registrar/grade/grade_release.jsp" target="rightFrame">Grade Releasing(one/batch)</a> <br>
	<img src="../images/broken_lines_3.gif"> <a href="../ADMIN_STAFF/enrollment/reports/elist.jsp" target="rightFrame">Enrollment List</a> <br>
	<img src="../images/broken_lines_3.gif"> <a href="../ADMIN_STAFF/enrollment/reports/class_lists.jsp" target="rightFrame">Class List</a> <br>
<%}%>
</span> 
<%}%></font>
<div class="trigger" onClick="showBranch('branch10');swapFolder('folder10')"> 
<img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder10"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">STUDENT'S REFERRAL </font></strong></div>
<span class="branch" id="branch10"> <font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"></font> 
<img src="../images/broken_lines_3.gif"> <a href="student_referral/encode_student_ref.jsp" target="rightFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Encode Student Referral</font></a><br>
<img src="../images/broken_lines_3.gif"> <a href="student_referral/list_of_referrals.jsp" target="rightFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">List of Student Referrals </font></a><br>
</span> 
<%
if(false)
if(strSchCode.startsWith("AUF") || strUserId.equals("1770")){%>
<img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder5"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
  <a href="./online_exam/online_exam_index.htm" target="bottomFrame">ONLINE EXAMINATION MGMT  </a></font></strong>
  </font> 
<%}
if(strSchCode.startsWith("AUF")){%>
<img src="../images/arrow_blue.gif"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
  <a href="http://search.ebscohost.com/login.aspx?authtype=uid" target="_blank">Go to EBSCO research Database</a>
  </font></strong> 

<%}
%>


<%}else{
	if(strUserId != null){%>
	<font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif" size="3">
	User is not authorized to view links</font>
<%}else{%>
	<font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif" size="3">
	Please login to access class management.</font>
<%}
}%>
</body>
</html>
<%
if(dbOP != null) 
	dbOP.cleanUP();
%>
