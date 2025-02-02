<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Administrator's Links</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/treelinkcss.css" rel="stylesheet" type="text/css">
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
<body bgcolor="#004182" onLoad="MM_preloadImages('../../images/home_small_rollover.gif','../../images/help_small_rollover.gif','../../images/logout_rollover.gif')">
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
<form action="../commfile/logout.jsp" method="post" target="_parent">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="8%" height="19" bgcolor="#004182">&nbsp;</td>
      <td width="92%" bgcolor="#004182"><a href="../commfile/logout.jsp?logout_url=../index.htm" target="_top" onMouseOver="window.status='Go back to home page'; MM_swapImage('Image1','','../images/home_small_rollover.gif',1); return true" onMouseOut="MM_swapImgRestore()"><img src="../images/home_small.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image2','','../images/help_small_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../images/help_small.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a onMouseOver="MM_swapImage('Image3','','../images/logout_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../images/logout.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
  </tr>
  </table>
<input type="hidden" name="logout_url" value="../administrators/administrators_bottom_content.jsp">
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
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");

//System.out.println("testing : strErrMsg ="+strErrMsg);
if(strErrMsg != null && strErrMsg.length() > 0)
{%>
<font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif" size="2"><b><%=strErrMsg%></b></font>
<%//System.out.println("testing");
if(dbOP != null) dbOP.cleanUP();
return;
}

if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"Executive Management System")){%>

<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ENROLMENT</font></strong></div>

<span class="branch" id="branch1"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../images/broken_lines_2.gif"> <a href="enrolment/enrollees.jsp" target="contentFrame">Enrollees</a><br>
<img src="../images/broken_lines_2.gif"> <a href="enrolment/subjects.jsp" target="contentFrame">Subjects Offerings</a><br>
<img src="../images/broken_lines_2.gif"> <a href="enrolment/rooms.jsp" target="contentFrame">Rooms</a><br>
<img src="../images/broken_lines_2.gif"> <a href="enrolment/students.jsp" target="contentFrame">Students</a><br>
<img src="../images/broken_lines_2.gif"> <a href="enrolment/faculties.jsp" target="contentFrame">Faculties Load</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/enrollment/reports/enrolment_summary.jsp" target="contentFrame">Enrolment Summary</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/enrollment/statistics/stats_compare.jsp" target="contentFrame">Enrolment Comparison</a><br></font>
</span>
<!--
<div> <img src="../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../ADMIN_STAFF/enrollment/subjects/subj_sectioning.jsp" target="contentFrame">SUBJECT
  SECTIONING</a> </font></strong></div>
-->
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../images/box_with_plus.gif" border="0" id="folder3"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">FINANCIALS</font></strong></div>
<span class="branch" id="branch3"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<%if(strSchCode.startsWith("MARINER")){%>
	<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/fee_assess_pay/reports/cashier_report_main.jsp" target="contentFrame">Teller's Report</a><br>
<%}%>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/accounting/reports/general_journal/gen_journal_1st_page.jsp" target="contentFrame">General Journal</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/accounting/reports/general_ledger/gl_1st_page.jsp" target="contentFrame">General Ledger</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/accounting/reports/trial_balance/tb_1st_page.jsp" target="contentFrame">Trial Balance</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/accounting/reports/balance_sheet/bl_1st_page.jsp" target="contentFrame">Balance Sheet</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/accounting/reports/income_statement/is_report_1st_page.jsp" target="contentFrame">Income Statement</a><br>
<%if(false){%>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/accounting/reports/statement_of_rev_expenses/srel_1st_page.htm" target="contentFrame">Statement of Revenues<br>&nbsp;&nbsp;&nbsp;&nbsp; and Expenses</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/enrollment/faculty/enrollment_faculty_load_sched.htm" target="contentFrame">Statement of Changes in <br>&nbsp;&nbsp;&nbsp;&nbsp; Stockholder's Equity</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/enrollment/faculty/enrollment_view_print_load.htm" target="contentFrame">Cash Flows (Direct/Indirect)</a><br>
<%}%>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/accounting/reports/journal_voucher/jv_1st_page.jsp" target="contentFrame">Journal Voucher</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/accounting/reports/special_books/cash_disb_boook/cd_book_main.jsp" target="contentFrame">Special Books</a><br>
</font>
</span>

<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">STUDENTS</font></strong></div>

<span class="branch" id="branch4"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/enrollment/reports/student_sched.jsp" target="contentFrame">Student's Schedule</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/fee_assess_pay/reports/scholarship_summary.jsp" target="contentFrame">Scholars/Grantees/Priveleges</a><br>
</font>
</span>

<img src="../images/small_white_box.gif" width="7" height="7" border="0" ><a href="personnel/personnel_main.htm" target="contentFrame"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> PERSONNEL</font></strong></a><br>
<img src="../images/small_white_box.gif" width="7" height="7" border="0" ><a href="../ADMIN_STAFF/health_monitoring/report/complete_health_record.jsp" target="contentFrame"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> HEALTH</font></strong></a><br>


<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder7"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">INVENTORY</font></strong></div>
<span class="branch" id="branch7"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/inventory/fixed_asset_mgmt/fixed_asset_value.jsp" target="contentFrame">Fixed Assest Report</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/inventory/fixed_asset_mgmt/asset_report/fam_report_main.jsp" target="contentFrame">Land and Buildings</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../ADMIN_STAFF/inventory/inv_maint/inv_view_per_office.jsp" target="contentFrame">Inventory Per Office</a><br>
</font></span>

<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> 
<img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">SEARCH</font></strong></div>
<span class="branch" id="branch8"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../images/broken_lines_2.gif"> <a href="../search/srch_stud.jsp" target="contentFrame">Students</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../search/srch_emp.jsp" target="contentFrame">Employees</a><br>
</font> </span>

<!-- <div> <img src="../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../lms_blizcom" target="_blank">LMS</a> </font></strong></div>
 <div> <img src="../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../lms_blizcom" target="_blank">DATA ARCHIVING</a> </font></strong></div>
-->

<%}//only if super user or having access to Administrators

dbOP.cleanUP();
%>
</body>
</html>
