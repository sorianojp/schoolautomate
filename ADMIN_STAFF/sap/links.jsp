<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
String strSchCode    = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) {%>
	<p style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:#FF0000">You are already logged out. Please login again.</p>
<%return;}


	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Administrator links</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<link href="../../css/fontStyle.css" rel="stylesheet" type="text/css">
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
	<a href="<%if(bolIsSchool){%>../main%20files/admin_staff_home_button_content.htm<%}else{%>../../index.jsp<%}%>" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
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
if(strUserId == null)
	strUserId = "";
	
String strErrMsg = null;
boolean bolGrantAll = false;
boolean isAuthorized = false;

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

boolean bolIsRestrictedUser = false;
if(!bolGrantAll) {
		//put checks here for SAP. Check if SAP is given.. 
		String strSQLQuery = "select module_index from module where module_name = 'SAP'";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		//check if user is authenticated.. 
		strSQLQuery = "select auth_list_index from user_auth_list where user_index = "+(String)request.getSession(false).getAttribute("userIndex")+
					" and main_mod_index = "+strSQLQuery +" and is_valid = 1";
		if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null) {
			bolIsRestrictedUser = true;
		}
		

}
	if(!strSchCode.startsWith("UC")) {
		bolGrantAll = false;
		bolIsRestrictedUser = false;
	}

if(bolGrantAll || bolIsRestrictedUser){isAuthorized=true;
request.getSession(false).setAttribute("is_sap", "1");
%>
<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" border="0" id="folder1">
	<strong>Configuration</strong></div>
	<span class="branch" id="branch1">
			<img src="../../images/broken_lines.gif"> <a href="./config/set_sy_term.jsp" target="useradminmainFrame">Set Default SY-Term</a><br>
			<img src="../../images/broken_lines.gif"> <a href="./config/set_up_college.jsp" target="useradminmainFrame">Set up College-Code</a><br>
			<img src="../../images/broken_lines.gif"> <a href="./config/map_ar_fee.jsp" target="useradminmainFrame">MAP AR Fee</a><br>
			<img src="../../images/broken_lines.gif"> <a href="./config/map_ar_fee.jsp?is_oc=2" target="useradminmainFrame">MAP AR Other School Fee(Tuition)</a><br>
			<img src="../../images/broken_lines.gif"> <a href="./config/map_scholarship.jsp" target="useradminmainFrame">MAP Scholarship</a><br>
				<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../images/box_with_plus.gif" border="0" id="folder2">
					<strong>Mapping for PAYMENT</strong></div>
					<span class="branch" id="branch2">
						<img src="../../images/broken_lines.gif"> <a href="./config/map_teller.jsp" target="useradminmainFrame">MAP Teller</a><br>
						<img src="../../images/broken_lines.gif"> <a href="./config/map_other_sch_fee.jsp" target="useradminmainFrame">MAP Other School Fee (Non Tuition)</a><br>
					</span>
	</span>
	
<%if(bolGrantAll) {%>
	<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> <img src="../../images/box_with_plus.gif" border="0" id="folder5">
	<strong>Data</strong></div>
	<span class="branch" id="branch5">
			<img src="../../images/broken_lines.gif"> <a href="./data/ar_invoice.jsp" target="useradminmainFrame">AR Invoice</a><br>
			<img src="../../images/broken_lines.gif"> <a href="./data/ar_invoice.jsp?post_charge=1" target="useradminmainFrame">AR - Post Charge</a><br>
			<img src="../../images/broken_lines.gif"> <a href="./data/payment_tuition.jsp" target="useradminmainFrame">Payment - Tuition </a><br>
			<img src="../../images/broken_lines.gif"> <a href="./data/payment_non_tuition.jsp" target="useradminmainFrame">Payment - Non Tuition </a><br>
			<img src="../../images/broken_lines.gif"> <a href="./data/scholarship.jsp" target="useradminmainFrame">Scholarship </a><br>
	</span>
<%}%>
</font>
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
