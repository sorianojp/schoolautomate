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
//this is called if user is logged out
function LogoutCall() {
	parent.mainFrame.location="../loginsuccess.jsp";
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

if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"LIB_Circulation")){isAuthorized=true;%>
<jsp:include page="../loginframe_inc.jsp?depth=1"></jsp:include>
<div><img src="../images/arrow_blue.gif"><a href="./issue/issue.jsp" target="mainFrame"> Issue/ Renew </a></div>
<div><img src="../images/arrow_blue.gif"><a href="./return/return.jsp" target="mainFrame"> Return</a></div>
<div><img src="../images/arrow_blue.gif"><a href="../patron_info/patron_summary.jsp" target="mainFrame">  Patron Info </a></div>
<!--
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1"> 
 <font color="#FFFFFF"><a href="#">Patron Info</a></font></div>
<span class="branch" id="branch1">
<img src="../images/broken_lines_2.gif"> <a href="#" target="mainFrame">Personal Info</a><br>
<img src="../images/broken_lines_2.gif"> <a href="#" target="mainFrame">Circulation Info</a><br>
</span> 
-->
<div><img src="../images/arrow_blue.gif"><a href="./fine/fine_main_page.jsp" target="mainFrame">  Patron's Fine </a></div>
<div><img src="../images/arrow_blue.gif"><a href="./issue/issue_return_receipt_main.jsp" target="mainFrame"> Reprint I/R Receipt</a></div>
<div><img src="../images/arrow_blue.gif"><a href="./status/status.jsp" target="mainFrame"> Collection Status</a></div> 
<%if(false){%>
<div><img src="../images/arrow_blue.gif"><a href="#" target="mainFrame"> Reserve a book</a></div>
<%}%>
<div><img src="../images/arrow_blue.gif"><a href="reports/reports_main.jsp" target="mainFrame"> Reports</a></div>
<div><img src="../images/arrow_blue.gif"><a href="../administration/feedback/recommend_view_all.jsp" target="mainFrame"> Recommendations</a></div>  

<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8"> 
 <font color="#FFFFFF"><a href="#">Announcements</a></font></div>
<span class="branch" id="branch8">
<img src="../images/broken_lines_2.gif"> <a href="../administration/announcement/ann_create.jsp" target="mainFrame">Create</a><br>
<img src="../images/broken_lines_2.gif"> <a href="../administration/announcement/ann_search.jsp" target="mainFrame">Search</a><br>
</span> 

<div><img src="../images/arrow_blue.gif"><a href="../search/search_main.htm" target="mainFrame"> Search Collection</a></div><br>
<div><img src="../images/arrow_blue.gif"><a href="../../search/srch_stud.jsp" target="_blank"> Search Student</a></div>
 

<%}

if(strUserId == null)
	strErrMsg = "Session timeout. Please login again.";
else if(!isAuthorized)
	strErrMsg = "You are not authorized to view any link in this page. Please contact system admin for access permission.";
if(strErrMsg == null)
	strErrMsg = "";
%>
<font size="3" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"><%=strErrMsg%></font>
<%
if(strErrMsg.length() > 0){%>
<script language="JavaScript">
this.LogoutCall();
</script>
<%}%>
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>
