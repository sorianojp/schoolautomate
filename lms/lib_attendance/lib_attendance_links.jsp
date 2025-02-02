<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/treelinkcss.css"rel="stylesheet" type="text/css">
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
</head>

<body bgcolor="#006699">
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
boolean isAuthorized = false;
String strSchCode    = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
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

if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"LIB_Library Attendance")){isAuthorized=true;%>
<jsp:include page="../loginframe_inc.jsp?depth=1"></jsp:include>
<div> <img src="../images/arrow_blue.gif" border="0" > 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="lib_attendance_check.jsp" target="_blank">ATTENDANCE CHECK</a></font></strong></div>
<div> <img src="../images/arrow_blue.gif" border="0" > 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="login_terminal.jsp" target="mainFrame">ASSIGN LOGIN TERMINAL</a></font></strong></div>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">REPORTS</font></strong></div>
<span class="branch" id="branch1"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../images/broken_lines_2.gif"> <a href="reports/daily_attendance.jsp" target="mainFrame">Daily Attendance</a><br>
<img src="../images/broken_lines_2.gif"> <a href="reports/monthly_attendance.jsp" target="mainFrame">Monthly Attendance</a><br>
<img src="../images/broken_lines_2.gif"> <a href="reports/weekly_attendance.jsp" target="mainFrame">Weekly Attendance</a><br>
<img src="../images/broken_lines_2.gif"> <a href="reports/semestral_attendance.jsp" target="mainFrame">Semestral Attendance</a><br>
<%if(strSchCode.startsWith("WUP") || bolGrantAll){%>
<img src="../images/broken_lines_2.gif"> <a href="reports/lib_attendance_detailed.jsp" target="mainFrame">Attendance Detailed</a><br>
<%}%>
<img src="../images/broken_lines_2.gif"> <a href="reports/lib_attendance_summary.jsp" target="mainFrame">Attendance Summary</a><br>
<!--
<img src="../images/broken_lines_2.gif"> <a href="reports/lib_attendance_per_college_dept.jsp" target="mainFrame">Attendance Statistics</a><br>
<img src="../images/broken_lines_2.gif"> <a href="reports/lib_attendance_per_college.jsp" target="mainFrame">Attendance Statistics per College</a><br>
-->
</font>
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
