<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
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
<body bgcolor="#C39E60" onLoad="MM_preloadImages('../../images/home_roll.gif','../../images/help_roll.gif','../../images/logout_roll.gif')">
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
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#E9E0D1">
    <tr> 
      <td height="25"> <div align="center"><a href="../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm" target="_parent" onMouseOver="MM_swapImage('Image1','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small_admin.gif" name="Image1" border="0" id="Image1"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image2','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image2"  border="0" id="Image2"></a> 
          <a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../../images/logout_admin.gif" border="0" id="Image3"></a> 
        </div></td>
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

//make icafe table here. 
new CreateTable().createIcafeVio(dbOP);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	

if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Internet Cafe Management","USERS LOGIN") >0){isAuthorized=true;%>
<img src="../../images/small_white_box.gif" width="7" height="7" border="0" > 
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="iL_login.jsp" target="_blank">USERS 
LOGIN </a></font></strong> 
<%}
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Internet Cafe Management","INTERNET LAB OPERATION") >0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
  INTERNET LAB OPERATION</font></strong></div>
  
<span class="branch" id="branch1"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="./iL_comp_rec.jsp" target="iLFrame">Computer 
Records</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="./iL_table.jsp" target="iLFrame">Computer 
Usage</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="iL_assign.jsp" target="iLFrame">Assign 
User</a><br>
<!--<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="./iL_transfer.htm" target="iLFrame">Transfer 
User</a><br>-->
</font></span> 
<%}if(false)
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Internet Cafe Management","INTERNET OTHER SERVICES") >0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
  INTERNET OTHER SERVICES</font></strong></div>
  <span class="branch" id="branch2"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="iL_service_create.jsp" target="iLFrame">Add Other Services Entries</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="iL_services_post_charge.jsp" target="iLFrame">Post 
Charge </a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="iL_services_summary.jsp" target="iLFrame">Summary Of Other Charges</a> 
<br>
</font></span> 

<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Internet Cafe Management","USAGE DETAILS") >0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
  USAGE DETAILS (AND) SETTING</font></strong></div>
  
<span class="branch" id="branch3"><font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="iL_usage_users.jsp" target="iLFrame">Users Usage Summary</a> <br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="iL_usage_users_dtls.jsp" target="iLFrame">Users Usage Detail</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="iL_usage_overload.jsp" target="iLFrame">Overload User </a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="iL_usage_internet_lab_main.jsp" target="iLFrame">Internet Lab </a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="./iL_set_usage.jsp" target="iLFrame">Set User Usage Duration</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="./iL_assign_login_terminal.jsp" target="iLFrame">Assign LOGIN Terminal</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="iL_old_account.jsp" target="iLFrame">Old Account</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="iL_allow_multiple_term.jsp" target="iLFrame">Allow Multiple Term</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="./violation/violation_main.jsp" target="iLFrame">Violation</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="iL_users_per_hour_main.jsp" target="iLFrame">Users per Hour Report</a><br>
<%if(strSchCode.startsWith("UDMC")){%>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="./pos/main.jsp" target="iLFrame">Other Services(POS)</a><br>
<%}%>
</font></span> 
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
if(dbOP != null)
	dbOP.cleanUP();
%>