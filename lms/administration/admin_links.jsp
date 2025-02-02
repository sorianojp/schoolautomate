<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/treelinkcss.css"rel="stylesheet" type="text/css">
<link href="../css/regmainlinkcssHEALTH.css" rel="stylesheet" type="text/css">
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 15px;
	line-height:1.2;
}

.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
.trigger1 {	cursor: pointer;
	cursor: hand;
}
.trigger2 {	cursor: pointer;
	cursor: hand;
}
.trigger11 {cursor: pointer;
	cursor: hand;
}
</style>
</head>

<body bgcolor="#006699">
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
boolean isAuthorized = false;
String strSchCode    = (String)request.getSession(false).getAttribute("school_code");
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

if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"LIB_Administration")){isAuthorized=true;%>
<jsp:include page="../loginframe_inc.jsp?depth=1"></jsp:include>

<div> <img src="../images/arrow_blue.gif"><a href="system_info/system_info.jsp" target="mainFrame"> System Information </a> </div>
<div><img src="../images/arrow_blue.gif"><a href="./patron_maintenance/main.jsp" target="mainFrame"> Patron Management </a></div>
<div><img src="../images/arrow_blue.gif"><a href="../../ADMIN_STAFF/user_admin/set_param/hold_unhold_student.jsp" target="mainFrame"> Hold - UnHold Student</a></div>
<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> 
<img src="../images/box_with_plus.gif" border="0" id="folder5"> <a href="#">Catalog</a> </div>
<span class="branch" id="branch5">  
<img src="../images/broken_lines_2.gif"> <a href="cataloging/circ_type.jsp" target="mainFrame">Circulation Type </a><br>
<!--<img src="../images/broken_lines_2.gif"> <a href="cataloging/material_type.htm" target="mainFrame">Material Type </a><br>
-->
<img src="../images/broken_lines_2.gif"> <a href="cataloging/fs_main.htm" target="mainFrame">Funding Source </a><br>
<img src="../images/broken_lines_2.gif"> <a href="cataloging/articles.jsp" target="mainFrame">Articles </a><br>
<!-- <img src="../images/broken_lines_2.gif"> <a href="organizations/year_end_report.jsp" target="saomainFrame">Organization Year-End Report</a><br>
<img src="../images/broken_lines_2.gif"> <a href="organizations/performance_rep.jsp" target="saomainFrame">Performance Report</a><br>
 --></span> 

<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> 
<img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6"> <a href="#">Circulation </a></div>
<span class="branch" id="branch6">  
<img src="../images/broken_lines_2.gif"> <a href="circulation/borrowing_param.jsp" target="mainFrame">Borrowing Parameter</a><br>
<img src="../images/broken_lines_2.gif"> <a href="circulation/reservation_param.jsp" target="mainFrame">Reservation</a><br>
<img src="../images/broken_lines_2.gif"> <a href="circulation/fines.htm" target="mainFrame">Fines</a><br>
<img src="../images/broken_lines_2.gif"> <a href="circulation/wh.jsp" target="mainFrame">Working Hour Mgmt</a><br>
<img src="../images/broken_lines_2.gif"> <a href="circulation/wh_calendar.jsp" target="mainFrame">Working Days Calendar</a><br>
<!-- <img src="../images/broken_lines_2.gif"> <a href="../enrollment/change_subjects/reg_change_subject_print.htm" target="enrolmainFrame">Schedule</a><br>
 --></span>

<div><img src="../images/arrow_blue.gif"> <a href="links/links.jsp" target="mainFrame">Links Management </a> </div>

<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> 
<img src="../images/box_with_plus.gif" border="0" id="folder7"> <a href="#">Announcement</a></div>
<span class="branch" id="branch7"> 
<img src="../images/broken_lines_2.gif"> <a href="announcement/ann_create.jsp" target="mainFrame">Create<br></a>
<img src="../images/broken_lines_2.gif"> <a href="announcement/ann_search.jsp" target="mainFrame">Search</a><br>
</span> 

<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> 
<img src="../images/box_with_plus.gif" border="0" id="folder8"><a href="#"> Events</a></div>
<span class="branch" id="branch8"> 
<img src="../images/broken_lines_2.gif"> <a href="events/event_create.jsp" target="mainFrame">Create<br></a>
<img src="../images/broken_lines_2.gif"> <a href="events/event_search.jsp" target="mainFrame">Search</a><br>
</span> 

<div class="trigger" onClick="showBranch('branch10');swapFolder('folder10')"> 
<img src="../images/box_with_plus.gif" border="0" id="folder10"> <a href="#">Feedback</a></div>
<span class="branch" id="branch10"> 
<img src="../images/broken_lines_2.gif"> <a href="feedback/setting.jsp" target="mainFrame">Setting</a><br>
<img src="../images/broken_lines_2.gif"> <a href="feedback/forbidden_words.jsp" target="mainFrame">Forbidden Words </a><br>
<img src="../images/broken_lines_2.gif"> <a href="feedback/recommend_view_all.jsp" target="mainFrame">Recommendation</a><br>
<img src="../images/broken_lines_2.gif"> <a href="feedback/comment_main.jsp" target="mainFrame">Comments</a><br>
</span> 
<%}

if(strUserId == null)
	strErrMsg = "Session timeout. Please login again.";
else if(!isAuthorized)
	strErrMsg = "You are not authorized to view any link in this page. Please contact system admin for access permission.";
if(strErrMsg == null)
	strErrMsg = "";
%>
<font size="3" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"><%=strErrMsg%></font>
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>
