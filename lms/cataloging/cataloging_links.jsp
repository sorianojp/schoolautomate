<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/treelinkcss.css"rel="stylesheet" type="text/css">
<link href="../css/regmainlinkcssHEALTH.css" rel="stylesheet" type="text/css">
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
if(strSchCode == null)
	strSchCode = "";

boolean bolIsDBTC = strSchCode.startsWith("DBTC");

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

if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"LIB_Cataloging")){isAuthorized=true;%>
<jsp:include page="../loginframe_inc.jsp?depth=1"></jsp:include>

 <div><img src="../images/arrow_blue.gif"><a href="lib_collection/lib_main.htm" target="mainFrame"> Library Collection </a></div>
 <div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3"> 
  <a href="#">Author Codes</a></div>
 <span class="branch" id="branch3">  
<img src="../images/broken_lines_2.gif"><a href="./ac/ac.jsp" target="mainFrame">Manage code</a><br>
<img src="../images/broken_lines_2.gif"><a href="./ac/ac.jsp?search_only=1" target="mainFrame">Search</a><br>
</span> 

<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> 
<img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder5"> 
  <a href="#">DDC Number</a></div>
<span class="branch" id="branch5"> 
<img src="../images/broken_lines_2.gif" > <a href="ddc/ddc_main.htm" target="mainFrame">Create</a><br>
<img src="../images/broken_lines_2.gif" > <a href="./ddc/ddc_book_search.jsp" target="mainFrame">Search</a><br>
<img src="../images/broken_lines_2.gif" > <a href="./ddc/ddc_summary.jsp" target="mainFrame">View Summaries </a><br>
</span> 
<%if(!strSchCode.startsWith("UI")){%>
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6"> <a href="#">LC</a></div>
<span class="branch" id="branch6">
<img src="../images/broken_lines_2.gif" > <a href="lc/lc_main.htm" target="mainFrame">Create</a><br>
<img src="../images/broken_lines_2.gif" > <a href="./lc/lc_book_search.jsp" target="mainFrame">Search</a><br>
<img src="../images/broken_lines_2.gif" > <a href="./lc/lc_summary.jsp?is_lc=1" target="mainFrame">View Summaries </a><br>
</span> 
<%}%>
<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> <img src="../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8"> 
  <a href="#">Announcement</a></div>
<span class="branch" id="branch8">
<img src="../images/broken_lines_2.gif" > <a href="../administration/announcement/ann_create.jsp" target="mainFrame">Create</a><br>
<img src="../images/broken_lines_2.gif" > <a href="../administration/announcement/ann_search.jsp" target="mainFrame">Search</a><br>
</span> 

 
<div>
	<img src="../images/arrow_blue.gif"> <a href="./reports/main_page.jsp" target="mainFrame">Reports</a> <br>
	<img src="../images/arrow_blue.gif"> <a href="../search/search_main.htm" target="mainFrame">Search Collection </a><br />
	<%if(bolIsDBTC){%>
	<img src="../images/arrow_blue.gif"> <a href="inventory/inventory_main.jsp" target="mainFrame">Inventory</a>
	<%}%>
</div>
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
