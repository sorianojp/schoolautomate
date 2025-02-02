<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Administrator links</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<link href="../../css/treelinkcss.css" rel="stylesheet" type="text/css">

<SCRIPT LANGUAGE="JavaScript" SRC="../../jscript/common.js"></script>
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
function CallFullScreenCardCheck()
{
	//expandingWindow("./dtr.jsp");
	fullScreen("./card_balance.jsp");
	return;
}
function CallFullScreenPOS()
{
	//expandingWindow("./dtr.jsp");
	//fullScreen("./pos.jsp");
	var loadPg = "./pos.jsp";	
	var win=window.open(loadPg,"CallFullScreenPOS",'fullscreen=yes,dependent=no,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	return;
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
</script>
<form action="../../commfile/logout.jsp" method="post" target="_parent">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="8%" height="19" bgcolor="#E9E0D1">&nbsp;</td>
    <td width="92%" bgcolor="#E9E0D1">
	<a href="../main%20files/admin_staff_home_button_content.htm" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
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
String strUserId = (String)request.getSession(false).getAttribute("userId");
if(strUserId == null)
	strUserId = "";
	
String strErrMsg = null;
boolean bolGrantAll = false;
boolean isAuthorized = false;
String strSchCode    = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";
	
if(strUserId.length() > 0)
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

if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Cash Card","CARD MANAGEMENT")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CARD MANAGEMENT </font></strong></div>
<span class="branch" id="branch1">
<img src="../../images/broken_lines.gif"> <a href="card_mgmt/block_user_management.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Block User</font></a><br>
<img src="../../images/broken_lines.gif"> <a href="card_mgmt/load_adjustment.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Load Adjustment </font></a><br>
<img src="../../images/broken_lines.gif"> <a href="card_mgmt/card_setting.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Card Setting </font></a><br>
<img src="../../images/broken_lines.gif"> 
	<a href="card_mgmt/daily_usage_per_user.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Daily Usage per User</font></a><br>
</span>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Cash Card","FOOD PREFERENCE/DISLIKE MANAGEMENT")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">FOOD PREFERENCES</font></strong></div>
<span class="branch" id="branch2">
<img src="../../images/broken_lines.gif"> <a href="food_preferences/allergy_management.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Allergy Mgmt</font></a><br>
<img src="../../images/broken_lines.gif"> <a href="food_preferences/pd_management.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Food Preferences/Dislike Mgmt</font></a><br>
</span>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Cash Card","TERMINAL MANAGEMENT")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">TERMINAL MANAGEMENT </font></strong></div>
<span class="branch" id="branch3">
<img src="../../images/broken_lines.gif"> <a href="terminal_mgmt/terminal_category_management.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Manage Category</font></a><br>
<img src="../../images/broken_lines.gif"> <a href="terminal_mgmt/terminal_dept_management.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Manage Department </font></a><br>
<img src="../../images/broken_lines.gif"> <a href="terminal_mgmt/terminal_ip_management.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Terminal IP Mgmt </font></a><br>
</span>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Cash Card","Inventory")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">INVENTORY MANAGEMENT </font></strong></div>
<span class="branch" id="branch4">
<img src="../../images/broken_lines.gif"> <a href="./inventory/item_master_list.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Item Master List</font></a><br>
<img src="../../images/broken_lines.gif"> <a href="./inventory/inv_summary.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Canteen Inventory </font></a><br>

<!--
	<img src="../../images/broken_lines.gif"> <a href="terminal_mgmt/terminal_ip_management.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Terminal IP Mgmt </font></a><br>
-->
</span>
<%}
if( (bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"CASH CARD","CASH CARD BALANCE INQUIRY")!=0)){isAuthorized=true;%>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0" ><a href="card_balance.jsp" target="useradminmainFrame">
	<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> USER CARD BALANCE</font></strong></a><br>
<%}
if( (bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"CASH CARD","CASH CARD BALANCE INQUIRY")!=0)){isAuthorized=true;%>
<!--
<img src="../../images/small_white_box.gif" width="7" height="7" border="0" ><a href="pos_terminal_report.jsp" target="useradminmainFrame">
	<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> TRANSACTION REPORTS</font></strong></a><br>
-->

<%}
if( (bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"CASH CARD","REPORTS")!=0)){isAuthorized=true;%>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0" ><a href="reports/report_main.jsp" target="useradminmainFrame">
	<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> REPORTS</font></strong></a><br>
<%}
if( (bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"CASH CARD","POS TERMINAL")!=0)){isAuthorized=true;%>
<img src="../../images/arrow_blue.gif" border="0"><a href="javascript:CallFullScreenPOS();"> 
	<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">POS TERMINAL </font></strong></a><br>
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
