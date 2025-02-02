<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false; boolean bolIsGovt = false;

if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;

if( (new ReadPropertyFile().getImageFileExtn("IS_GOVERNMENT","0")).equals("1"))
	bolIsGovt = true;

String[] strColorScheme = CommonUtil.getColorScheme(5);

//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<link href="../../../css/treelinkcss.css" rel="stylesheet" type="text/css">
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
<style>
body {
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size:13px;
	color:#FFFFFF;
}
</style>
</head>
<body bgcolor="#C39E60" onLoad="MM_preloadImages('../../../images/home_small_admin_rollover.gif','../../../images/help_small_admin_rollover.gif','../../../images/logout_admin_rollover.gif')">
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
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

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
<form action="../../../commfile/logout.jsp" method="post" target="_parent">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="10%" height="19" bgcolor="#E9E0D1">&nbsp;</td>
    <td width="90%" bgcolor="#E9E0D1">
	<a href="<%if(bolIsSchool){%>../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm<%}else{%>../../../index.jsp<%}%>" target="_parent" onMouseOver="MM_swapImage('Image2','','../../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
	<input type="image" src="../../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
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

if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"Document Tracking")){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../../images/box_with_plus.gif" border="0" id="folder2">
  <strong>DOCUMENT TRACKING</strong></div>

<span class="branch" id="branch2">
<%if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Document Tracking","Manage Transactions")!=0){%>
	<img src="../../../images/broken_lines.gif"><a href="../doc_catg_mgmt.jsp" target="docmainFrame"> Document Catg Management</a><br>
	<img src="../../../images/broken_lines.gif"><a href="../doc_transaction_mgmt.jsp" target="docmainFrame"> Manage Transactions</a><br>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Document Tracking","Receive Release")!=0){%>
	<img src="../../../images/broken_lines.gif"><a href="../transaction_receive.jsp" target="docmainFrame"> Receive Document by Office</a><br>
	<img src="../../../images/broken_lines.gif"><a href="../transaction_release.jsp" target="docmainFrame"> Release Document by Office</a><br>
	<img src="../../../images/broken_lines.gif"><a href="../document_release.jsp" target="docmainFrame"> Document Releasing</a><br>
<%}%>
	<img src="../../../images/broken_lines.gif"><a href="../document_tracking.jsp" target="docmainFrame"> Document Tracking</a><br>
<%if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Document Tracking","Reports")!=0){%>
	<img src="../../../images/broken_lines.gif"><a href="../statistics_ave_duration.jsp" target="docmainFrame"> Ave. Duration Statistics</a><br>
	<img src="../../../images/broken_lines.gif"><a href="../pending_documents.jsp" target="docmainFrame"> Pending Documents</a><br>
	<img src="../../../images/broken_lines.gif"><a href="../unreleased_documents.jsp" target="docmainFrame"> Unreleased Documents</a><br>
	<img src="../../../images/broken_lines.gif"><a href="../transaction_log.jsp" target="docmainFrame"> Transaction Log</a><br>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Document Tracking","Search")!=0){%>
	<img src="../../../images/broken_lines.gif"><a href="../transaction_search.jsp" target="docmainFrame"> Search Transaction</a><br>
	<img src="../../../images/broken_lines.gif"><a href="../transaction_search_completed.jsp" target="docmainFrame"> Completed Transactions</a><br>
<%}if((bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Document Tracking","Superuser Accounts")!=0)){%>
	<img src="../../../images/broken_lines.gif"><a href="../manage_superusers.jsp" target="docmainFrame"> Manage Superusers</a><br>
<%}%>
<%if(bolGrantAll){%>
	<img src="../../../images/broken_lines.gif"><a href="../open_completed_doc.jsp" target="docmainFrame"> Open Completed Docs</a><br>
<%}%>
	
</span> 
<%}

if(strUserId == null)
	strErrMsg = "Session timeout. Please login again.";
else if(!isAuthorized)
	strErrMsg = "You are not authorized to view any link in this page. Please contact system admin for access permission.";
if(strErrMsg == null)
	strErrMsg = "";
%>
  <font size="2" face="Verdana, Arial, Helvetica, sans-serif"><%=strErrMsg%></font>
  
  <!--
  	auto show the branched links. this is not showing before.. i did this because it has only 1 branch unlike in other modules
	where there are multiple branches.
  -->
  <script language="javascript">
  	showBranch('branch2');swapFolder('folder2');
  </script>
</div>
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>