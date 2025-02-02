<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
//strColorScheme is never null. it has value always.
%>
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
function CallFullScreDTR()
{
	//expandingWindow("./dtr.jsp");
	fullScreen("./dtr.jsp");
	return;
}
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
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[0]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<body bgcolor="#C39E60" onLoad="MM_preloadImages('../../images/home_small_admin_rollover.gif','../../images/help_small_admin_rollover.gif','../../images/logout_admin_rollover.gif')" class="bgDynamic">
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
    <td width="10%" height="19" bgcolor="#E9E0D1">&nbsp;</td>
    <td width="90%" bgcolor="#E9E0D1">
	<a href="<%if(bolIsSchool){%>../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm<%}else{%>../../index.jsp<%}%>" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
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
boolean bolShowLink = false;
IPFilter ipFilter  = new IPFilter();
int iIPAccessLevel = 0;
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
boolean bolIsGovernment = false;
boolean bolMultipleHolRate = false;
boolean bolHasBundyClock = false;
boolean bolIsFacDTRAllowed = false;

if (strSchCode == null)
	strSchCode = "";

if(strUserId != null)
{
	//open dbConnection here to check if user is registered already.
	try
	{
		dbOP = new DBOperation();
		if(strUserId.equalsIgnoreCase("SA-0,1") || strUserId.equalsIgnoreCase("GTI-01") || strUserId.equalsIgnoreCase("bricks"))
			bolShowLink = true; 
 		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolIsGovernment    = readPropFile.readProperty(dbOP, "IS_GOVERNMENT","0").equals("1");
		bolMultipleHolRate = readPropFile.readProperty(dbOP, "MULTIPLE_HOLIDAY_RATE","0").equals("1");	
		bolHasBundyClock   = readPropFile.readProperty(dbOP, "HAS_BUNDY_STYLE","0").equals("1");	
		bolIsFacDTRAllowed = readPropFile.readProperty(dbOP, "IS_FACULTY_APPLICABLE","0").equals("1");	
	}	
	catch(Exception exp){
		exp.printStackTrace();
		strErrMsg = "error in opening connection.";
	}

	if(strErrMsg == null)
	{
		//check here the authentication of the user.
		if(comUtil.IsSuperUser(dbOP,strUserId) || bolShowLink)
			bolGrantAll = true;	//grant all ;-)
			
		iIPAccessLevel = ipFilter.isAuthorizedIP(dbOP,(String)request.getSession(false).getAttribute("userId"),
                            "eDTR(daily time recording)","eDaily Time Record","DAILY TIME RECORDING",
							"dtr.jsp",request.getRemoteAddr());
		
	}
}
else
	strErrMsg = "";
boolean bolAllowWHEditDelete = true;
if(strSchCode.startsWith("CLDH") && !bolGrantAll){
	if(comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","WORKING HOURS MGMT-View/Delete") == 0)
		bolAllowWHEditDelete = false;
}


boolean bolZoningAllowed = false; 
boolean bolIsInternetZone = false;
//if(strSchCode.startsWith("VMUF") || strSchCode.startsWith("TSUNEISHI") || 
//	strSchCode.startsWith("ILIGAN") || strSchCode.startsWith("NONKI") || 
//	strSchCode.startsWith("CLC"))
	bolZoningAllowed = true;
	
if(strSchCode.startsWith("NONKI") || strSchCode.startsWith("ILIGAN"))
	bolIsInternetZone = true;

if(bolZoningAllowed) {
	if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","DTR Zoning") != -0) {
		//do nothing
	}
	else	
		bolZoningAllowed = false;
}

boolean bolWHRestricted = false;
if(!bolGrantAll || true) {
	if(comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","WORKING HOURS MGMT-- DUMMY") == 0) {
		if(comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","WORKING HOURS MGMT - Restricted") !=0 )
			bolWHRestricted = true;
	}
}

//bolWHRestricted = true;

if(bolWHRestricted)
	request.getSession(false).setAttribute("wh_restricted", "1");
else
	request.getSession(false).setAttribute("wh_restricted", null);
%>
<%
if(bolWHRestricted) {isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
	<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">WORKING HOURS MGMT </font></strong></div>
	<span class="branch" id="branch1"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
		<img src="../../images/broken_lines.gif"> <a href="working_hours_mgmt/set_working_main.jsp" target="edtrmainFrame">Set Workings Hours</a><br>
		<img src="../../images/broken_lines.gif"> <a href="working_hours_mgmt/set_rest_days_main.jsp" target="edtrmainFrame">Manage Rest Days</a><br>
	</font></span>
<%}else if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","WORKING HOURS MGMT")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">WORKING HOURS MGMT </font></strong></div>
<span class="branch" id="branch1"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF">
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/set_dtr_regular_wh.jsp" target="edtrmainFrame">Set Regular working hour</a><br>
<img src="../../images/broken_lines.gif"> <a href="working_hours_mgmt/set_working_main.jsp" target="edtrmainFrame">Set Workings Hours</a><br>
<img src="../../images/broken_lines.gif"> <a href="working_hours_mgmt/set_rest_days_main.jsp" target="edtrmainFrame">Manage Rest Days</a><br>
<%if(bolAllowWHEditDelete || bolShowLink){%>
<img src="../../images/broken_lines.gif"> <a href="working_hours_mgmt/view_working_hours.jsp" target="edtrmainFrame">View / Delete Working Hours</a><br>
<%}if(bolIsSchool || bolShowLink){%>
<%if(!strSchCode.startsWith("UC")){%>
	<img src="../../images/broken_lines.gif"> <a href="working_hours_mgmt/multiple_workhours/working_hour_main.jsp" target="edtrmainFrame">Multiple Working Hours</a><br>
<%}if(strSchCode.startsWith("FATIMA")){%>
	<img src="../../images/broken_lines.gif"> <a href="working_hours_mgmt/proctor/proctor_main.jsp" target="edtrmainFrame">Proctor Scheduling</a><br>
<%}

}%>
<%if(bolShowLink || strSchCode.startsWith("CEBUEASY")){%>
<img src="../../images/broken_lines.gif"> <a href="working_hours_mgmt/set_working_cebueasy.jsp" target="edtrmainFrame">Manage Working Hour (Requested)</a><br>
<%}%>
<%if(bolShowLink || bolHasBundyClock){%>
<img src="../../images/broken_lines.gif"> <a href="working_hours_mgmt/set_whour_exception.jsp" target="edtrmainFrame">Working Hour Exception</a><br>
<img src="../../images/broken_lines.gif"> <a href="working_hours_mgmt/view_bundy_employees.jsp" target="edtrmainFrame">View Bundy Hours</a><br>
<%}%>
</font></span>

<%}
boolean bolAllDtrOp = false;	
boolean bolApprove = false;
boolean bolAdjustDtr = false;

if(!bolGrantAll){
	bolAllDtrOp = (comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","DTR OPERATIONS") != 0);
	if(!bolAllDtrOp){
		bolApprove = (comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","DTR OPERATIONS-APPROVE DTR") != 0);
		bolAdjustDtr = (comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","DTR Operations-Adjust DTR") != 0);
	}
}

if(bolGrantAll || bolAllDtrOp || bolApprove || bolAdjustDtr){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">DTR OPERATIONS </font></strong></div>
<span class="branch" id="branch2"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<%if(bolGrantAll || bolAllDtrOp){%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/set_dtr_date.jsp" target="edtrmainFrame">Set DTR cut-off dates</a><br>
<%
// if naay goverment client na mo angal ngano walay night diff
// i enable lang ni... tapos ipa update ang ilahang payroll sheet... 
// bugo man gud tong gi sample nila na payroll sheet... di mabal an kung asa ibutang ang night diff
// ipa delete ang whatever setting for gov na existing... 
if(!bolIsGovernment || bolShowLink){%>
<img src="../../images/broken_lines.gif"> <a href="overtime/set_night_diff.jsp" target="edtrmainFrame">Night Differential Parameters</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/employee_ndf_management.jsp" target="edtrmainFrame">Night Differential Restrictions</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/employee_exclude_msg_mgt.jsp" target="edtrmainFrame">Late/UT Error Message Settings</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/set_dtr_late_timein.jsp" target="edtrmainFrame">Set DTR Settings</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/max_diff_setting.jsp" target="edtrmainFrame">Max Time Difference</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/set_flexi_dtr_setting.jsp" target="edtrmainFrame">Set Flexi DTR Settings</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/set_without_grace.jsp" target="edtrmainFrame">Set without grace period</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/set_without_ot.jsp" target="edtrmainFrame">Set without Overtime</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/set_allowed_ot_cost.jsp" target="edtrmainFrame">Set Allowed to View OT Cost</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/set_holidays.jsp" target="edtrmainFrame">Set Holidays</a><br>
<%if(bolMultipleHolRate){%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/holiday_group/holiday_mgmt_main.jsp" target="edtrmainFrame">Holiday Grouping</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/copy_holiday.jsp" target="edtrmainFrame">Copy Holidays</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/holiday_max_hours.jsp" target="edtrmainFrame">Max Holiday Hours</a><br>
<%}%>

<%if(strSchCode.startsWith("FOODA") || bolShowLink){
	if(bolGrantAll || bolAllDtrOp || bolApprove || bolAdjustDtr){
%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/add_dtr_temp.jsp" target="edtrmainFrame">Add Temp Time-in Time-out(Fooda)</a><br>
<%if(bolGrantAll || bolAllDtrOp || bolApprove){%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/approve_temp_dtr.jsp" target="edtrmainFrame">Approve Temp Time-in Time-out</a><br>
<%} // end super user for fooda or person authorized to approve temp dtr...
if(bolGrantAll || bolAdjustDtr){%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/add_dtr.jsp?info_logged=1" target="edtrmainFrame">Adjust Time-in Time-out</a><br>
<%}
 }
}%>
<%if((!strSchCode.startsWith("FOODA") && (bolGrantAll || bolAllDtrOp || bolAdjustDtr)) || bolShowLink){%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/add_dtr.jsp?info_logged=1" target="edtrmainFrame">Adjust Time-in Time-out</a><br>
<%}%>
<%if(bolGrantAll || bolAllDtrOp){%>
<%if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("UPH") || bolShowLink){%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/class_suspension.jsp" target="edtrmainFrame">Class Suspension</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/faculty_leave.jsp" target="edtrmainFrame">Encode Faculty Leave</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/dtr_view.jsp" target="edtrmainFrame">View/Print DTR</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/holiday_restrictions.jsp" target="edtrmainFrame">Holiday Restrictions</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/emp_with_dtr_on_holiday.jsp" target="edtrmainFrame">Employees with dtr entries <br>
&nbsp;&nbsp;&nbsp;&nbsp; on restricted dates</a><br>
<%if(strSchCode.startsWith("PIT")){%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/login_restriction.jsp" target="edtrmainFrame">Employees with login time<br>
&nbsp;&nbsp;&nbsp;&nbsp; restriction</a><br>
<%}%>
<%if(bolGrantAll || bolShowLink){%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/update_ut_special.jsp" target="edtrmainFrame">Update undertime minutes</a><br>
<%}
 } 
 if(bolGrantAll || bolShowLink || strSchCode.startsWith("DEPED")){%>
 <img src="../../images/broken_lines.gif"> <a href="dtr_operations/convert_awol_to_late_ut.jsp" target="edtrmainFrame">Move AWOL to Late/Undertime</a><br>
 <%} %> 
 
<%if(strSchCode.startsWith("CIT")  || bolShowLink ){ //transfered from payroll_links because edtr staff will do this, not the payroll staff.sul02232013 %>
<img src="../../images/broken_lines.gif"> <a href="../payroll/dtr/manual_encoding/encode_awol_amt.jsp" target="edtrmainFrame">Manual Encoding Absence</a><br>
<img src="../../images/broken_lines.gif"> <a href="../payroll/dtr/manual_encoding/encode_duration_manual.jsp" target="edtrmainFrame">Manual Encoding days/hours<br>&nbsp;&nbsp;&nbsp;&nbsp;work</a><br>
<img src="../../images/broken_lines.gif"> <a href="../payroll/dtr/manual_encoding/encode_late_ut.jsp" target="edtrmainFrame">Manual Encode Late/ Undertime</a><br>
<img src="../../images/broken_lines.gif"> <a href="../payroll/dtr/manual_encoding/overtime/overtime_main.jsp" target="edtrmainFrame">Manual Overtime Encoding</a><br>
<%}%>
 
 
<%}// end DTROperations%>
</font></span> 
<%
if(bolZoningAllowed){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">DTR ZONING </font></strong></div>
<span class="branch" id="branch6"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="dtr_zone/manage_zone.jsp" target="edtrmainFrame">Manage Zone</a><br>
	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="dtr_zone/manage_restricted_user_list.jsp" target="edtrmainFrame">Manage Restricted User List</a><br>
<%if(strSchCode.startsWith("VMUF")){%>
		<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="dtr_zone/upload_main.jsp" target="edtrmainFrame">Upload Management </a><br>
<%}if(bolIsInternetZone){%>
	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="dtr_zone/dtr_download_local.jsp" target="edtrmainFrame">Download Local DTR </a><br>
	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="dtr_zone/dtr_upload_local.jsp" target="edtrmainFrame">Upload Local DTR </a><br>
	<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="dtr_zone/force_unsynchronize.jsp" target="edtrmainFrame">Force Synchronize</a><br>
<%}%>	
</font></span> 
<%}// end bolZoningAllowed

boolean bolAllOTLinks = false;	
boolean bolOtParam = false;
boolean bolOTSetting = false;
boolean bolOTRequest = false;
boolean bolOTReqBatch = false;
boolean bolOTApproveBatch = false;
boolean bolViewEdit = false;

if(!bolGrantAll){
	bolAllOTLinks = (comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","OVERTIME MANAGEMENT") != 0);
	if(!bolAllOTLinks){
		bolOtParam = (comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","OVERTIME MANAGEMENT-Set Overtime Parameters") != 0);
		bolOTSetting = (comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","OVERTIME MANAGEMENT-Set Overtime Setting") != 0);
		bolOTRequest = (comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","OVERTIME MANAGEMENT-Overtime Request") != 0);
		bolOTReqBatch = (comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","OVERTIME MANAGEMENT-Request Overtime") != 0);
		bolOTApproveBatch = (comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","OVERTIME MANAGEMENT-Approve Overtime") != 0);
		bolViewEdit = (comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","OVERTIME MANAGEMENT-View/Edit Overtime") != 0);
	}
}
if(bolGrantAll || bolAllOTLinks  || bolOtParam || bolOTSetting || bolOTRequest || 
	 bolOTReqBatch || bolOTApproveBatch || bolViewEdit){ isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')">
	<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">OVERTIME MANAGEMENT</font></strong></div>
<span class="branch" id="branch4"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<%if(bolGrantAll || bolAllOTLinks || bolOtParam){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"> <a href="overtime/set_overtime_param.jsp" target="edtrmainFrame">Set Overtime Parameters</a><br>
<%}if(bolGrantAll || bolAllOTLinks || bolOTSetting){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"> <a href="overtime/set_dtr_min_ot.jsp" target="edtrmainFrame">Set Overtime Setting</a><br>
<%}if(bolGrantAll || bolAllOTLinks || bolOTRequest){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"> <a href="overtime/schedule_overtime.jsp" target="edtrmainFrame">Overtime Request</a><br>
<%}if(bolShowLink || ((bolGrantAll || bolAllOTLinks) && strSchCode.startsWith("TAMIYA"))){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"> <a href="overtime/ot_restriction.jsp" target="edtrmainFrame">OT Request Restriction</a><br>
<%}if(bolGrantAll || bolAllOTLinks || bolOTReqBatch){isAuthorized=true;%>
<!--
<img src="../../images/broken_lines.gif"> <a href="overtime/validate_approve_ot.jsp" target="edtrmainFrame">Validate/Approve Overtime </a><br>
-->
<%if(strSchCode.startsWith("TSUNEISHI") || bolShowLink){%>
<img src="../../images/broken_lines.gif"> <a href="overtime/batch_ot_request.jsp" target="edtrmainFrame">Request Overtime(Batch)</a><br>
<%}%>
<%if(!strSchCode.startsWith("TSUNEISHI") || bolShowLink){%>
<img src="../../images/broken_lines.gif"> <a href="overtime/batch_ot_request_new.jsp" target="edtrmainFrame">Request Overtime(Batch)</a><br>
<%}%>
<%}if(bolGrantAll || bolAllOTLinks || bolOTApproveBatch){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"> <a href="overtime/batch_approve_ot.jsp" target="edtrmainFrame">Approve Overtime(Batch)</a><br>
<%}if(bolGrantAll || bolAllOTLinks || bolViewEdit){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"> <a href="overtime/view_all_ot_request.jsp" target="edtrmainFrame">View/Edit Overtime</a><br>
<img src="../../images/broken_lines.gif"> <a href="edtr_utilities/deleted_ot.jsp?search_deleted=1" target="edtrmainFrame">Search Deleted OT</a><br>
<%}%>
</font></span>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","STATISTICS & REPORTS")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder5">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">STATISTICS &amp; REPORTS</font></strong></div>
<span class="branch" id="branch5"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/dtr_update_all.jsp" target="edtrmainFrame">Recompute ALL</a><br>

<img src="../../images/broken_lines.gif"> <a href="dtr_operations/dtr_leave_with_late_and_ut.jsp" target="edtrmainFrame">Recompute Late and Undertime With Leave</a><br>

<%if(false && (strSchCode.startsWith("DEPED") || bolIsGovernment || bolShowLink)){//awol to late/ut is not possible as of this date211142012%>
	<img src="../../images/broken_lines.gif"> <a href="dtr_operations/convert_awol_to_late_ut.jsp" target="edtrmainFrame">Convert AWOL to Late/UT</a><br>
<%}%>

<%if(strSchCode.startsWith("VMUF") || strSchCode.startsWith("FADI") || bolShowLink){%>
<!--old page for mass updating dtr of employees due to power failure or any other forces of nature
or whatever cases wherein many employees were not able to use the dtr.
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/dtr_update_faulty_dtr.jsp" target="edtrmainFrame">Update Faulty DTR(VMU)</a><br>
-->
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/dtr_update_faulty_new.jsp" target="edtrmainFrame">Update Faulty DTR</a><br>
<%}%>
<%if(strSchCode.startsWith("EAC") || bolShowLink){%>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_tin_tout.jsp" target="edtrmainFrame">View Employee TinTout</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/dtr_view.jsp" target="edtrmainFrame">View/Print  DTR</a><br>


<% if (strSchCode.startsWith("VMA") || bolShowLink) {%>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_with_deductions_vma.jsp" target="edtrmainFrame">Summary of Employee DTR</a><br>
<%}%>

<%if(bolIsGovernment || bolShowLink){%>
<img src="../../images/broken_lines.gif"> <a href="reports/government/cs_dtr_form.jsp" target="edtrmainFrame">Form #48 (Daily Time Record)</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/government/cs_dtr_form_batch.jsp" target="edtrmainFrame">Form #48 (batch)</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="overtime/view_all_ot_request.jsp" target="edtrmainFrame">View/Print Overtime</a><br>
<%if(strSchCode.startsWith("TAMIYA") || strSchCode.startsWith("EAC") ||  bolShowLink){%>
<img src="../../images/broken_lines.gif"> <a href="overtime/ot_request_per_office.jsp" target="edtrmainFrame">Overtime Request Per Office </a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="reports/holiday_records.jsp" target="edtrmainFrame">List of Holidays</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/emp_non_dtr.jsp" target="edtrmainFrame">Non DTR Employees</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/emp_edtr_adjustments.jsp" target="edtrmainFrame">Summary of EDTR Adjustments </a><br>		
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_with_ut.jsp" target="edtrmainFrame">Summary of Employees with<br>	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Undertime Record</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_late_timein.jsp" target="edtrmainFrame">Summary of Employees with<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Late Time-in Record</a><br>
<%if(bolIsFacDTRAllowed){%>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_faculty_late_ut.jsp" target="edtrmainFrame">Suumary of Faculty with Late or Undertime </a><br>
<%}%>

<%// if (strSchCode.startsWith("LCP") || bolShowLink) {%> 
<!--
		<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_late_timein.jsp" target="edtrmainFrame">Summary of Employees with <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Consecutive Late Time In</a><br>
-->
<%//}%> 
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_extra_time_records.jsp" target="edtrmainFrame"> Summary of Employees with <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Extra Time Record</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_with_lacking_timeout_records.jsp" target="edtrmainFrame"> Summary of Employees with<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Lacking Time Out Record</a><br>
<!--
<img src="../../images/broken_lines.gif"> 
		<a href="reports/summary_emp_with_absent.jsp" target="edtrmainFrame">Summary of Employees with<br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Absences</a><br>
-->
<% if (!strSchCode.startsWith("AUF") || bolShowLink) {%>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_with_awol.jsp" target="edtrmainFrame">Summary of Employees with<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Absences</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_with_deductions.jsp" target="edtrmainFrame">Summary of Employees with <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Deductions</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_leaves.jsp" target="edtrmainFrame">Summary of Employee Leaves</a><br>
<%}%>


<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_leaves_uncredited.jsp" target="edtrmainFrame">Summary of Uncredited Leaves</a><br>
<img src="../../images/broken_lines.gif"> <a href="overtime/view_all_uncredited_ot.jsp" target="edtrmainFrame">Summary of Uncredited Overtime</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_without_absent.jsp" target="edtrmainFrame">Summary of Employees <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;without Absences</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_perfect_attendance.jsp" target="edtrmainFrame">Perfect Attendance</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/dtr_view_summary.jsp" target="edtrmainFrame">Summary of Employees Edtr</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_wout_whours.jsp" target="edtrmainFrame">Summary of Employees<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Without valid working hours</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/monthly_report_emp_attendance.jsp" target="edtrmainFrame">Individual Monthly Report <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;of Employee's Attendance</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/emp_attendance.jsp" target="edtrmainFrame">Monthly Report <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;of Employee's Attendance</a><br>
<% if (bolIsGovernment || strSchCode.startsWith("PIT") || bolShowLink){%> 
<img src="../../images/broken_lines.gif"> <a href="reports/emp_without_late_ut.jsp" target="edtrmainFrame">Employee without <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Late and/or Undertime</a><br>
<%if(strSchCode.startsWith("PIT")){%>
<img src="../../images/broken_lines.gif"> <a href="reports/government/gov_reports_main.jsp" target="edtrmainFrame">PIT Reports</a><br>
<%}
}
if (strSchCode.startsWith("LHS") || bolShowLink){%> 
<img src="../../images/broken_lines.gif"> <a href="reports/emp_flexi_one_timein.jsp" target="edtrmainFrame">Flexi One Login</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/emp_breaks.jsp" target="edtrmainFrame">Employee Breaks</a><br>
<%}
if (strSchCode.startsWith("CGH") || bolShowLink){%> 
		<img src="../../images/broken_lines.gif"> <a href="reports/monthly_report_emp_attendance_cgh.jsp" target="edtrmainFrame">Individual Summary<br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;of Employee's Attendance(CGH)</a><br>
<%} if (strSchCode.startsWith("LCP") || bolShowLink) {%>
<img src="../../images/broken_lines.gif"> <a href="reports/monthly_report_lcp.jsp" target="edtrmainFrame">LCP Report of Attendance </a><br>
<%} if (strSchCode.startsWith("AUF") || bolShowLink) {%>
<img src="../../images/broken_lines.gif"> <a href="../HR/reports/hr_leave_summary_auf.jsp" target="edtrmainFrame">Leave Summary(AUF)</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/monthly_report_dean_heads.jsp" target="edtrmainFrame"> Monthly Office Report(AU)</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/emp_salary_deductions.jsp" target="edtrmainFrame"> Salary Deduction Report(AU)</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/auf_ob_ot_report.jsp" target="edtrmainFrame">OB / OT Reports(AU)</a><br>
<%}%> 

<%if(strSchCode.startsWith("FOODA") || bolShowLink){%>
<img src="../../images/broken_lines.gif"> <a href="reports/edtr_salary_adjust.jsp" target="edtrmainFrame">Salary Adjustments</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="reports/government/login_tracking_main.jsp" target="edtrmainFrame"> Employee Login Tracking</a><br>
<% if (strSchCode.startsWith("TAMIYA") || bolShowLink){%> 
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_with_inc_time.jsp" target="edtrmainFrame">Offenses Summary(by Emp)</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_with_inc_time_daily.jsp" target="edtrmainFrame">Offenses Summary(by day)</a><br>
<%}%>
<% if (strSchCode.startsWith("TSUNEISHI") || strSchCode.startsWith("CIT") || strSchCode.startsWith("DEPED") || bolShowLink){%> 
<img src="../../images/broken_lines.gif"><a href="overtime/ot_rendered.jsp" target="edtrmainFrame"> Summary of OT Rendered</a><br>
<img src="../../images/broken_lines.gif"><a href="overtime/ot_summary.jsp" target="edtrmainFrame">Detailed OT Rendered</a><br>
<%}%>
<%if (strSchCode.startsWith("CLC") || bolShowLink){%> 
<img src="../../images/broken_lines.gif"><a href="overtime/ot_rendered.jsp" target="edtrmainFrame"> Summary of OT Rendered</a><br>
<%}%>
<% if (strSchCode.startsWith("EAC") || strSchCode.startsWith("UPH") || bolShowLink){%> 
<img src="../../images/broken_lines.gif"><a href="overtime/night_differential_report.jsp" target="edtrmainFrame"> Summary of Night Differential</a><br>
<%}%>
<% if (strSchCode.startsWith("TSUNEISHI") || bolShowLink){%> 
<img src="../../images/broken_lines.gif"> <a href="reports/government/undertime_summary.jsp?for_undertime=1&hide_back=1" target="edtrmainFrame">Undertime</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/government/undertime_summary.jsp?for_undertime=0&hide_back=1" target="edtrmainFrame">Tardiness</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/attendance_summary_tsu.jsp" target="edtrmainFrame">Attendance Summary</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/summary_emp_with_ob.jsp" target="edtrmainFrame">Summary of Employees w/ OB</a><br>
<%}%>
<% if (bolIsGovernment || bolShowLink){%> 
<img src="../../images/broken_lines.gif"> <a href="overtime/coc_mgmt.jsp" target="edtrmainFrame">Leave Management(COC)</a><br>
<img src="../../images/broken_lines.gif"> <a href="overtime/ot_leave_crediting.jsp" target="edtrmainFrame">Compensatory Leave Credit</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/government/late_ut_gov.jsp" target="edtrmainFrame">Offset Late/undertime</a><br>
<%}%>
<% if (strSchCode.startsWith("CLC") || bolShowLink){%> 
<img src="../../images/broken_lines.gif"> <a href="reports/gate_security/gate_security.jsp" target="edtrmainFrame">Gate Security</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="working_hours_mgmt/adhoc_working_hours.jsp" target="edtrmainFrame">Changed Schedules</a><br>
</font></span> 

<%if(bolShowLink){%>
<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> 
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder7">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">DEVELOPER / UNRELEASED PAGES</font></strong></div>
<span class="branch" id="branch7"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
<img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="javascript:CallFullScreDTR();">DAILY TIME RECORDING</a> </font></strong><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/util_convert_long.jsp" target="edtrmainFrame">Long Converter</a><br>
<img src="../../images/broken_lines.gif"> <a href="working_hours_mgmt/multiple_workhours/force_pay_schedule.jsp" target="edtrmainFrame">Force schedule as with/without pay</a><br>

<img src="../../images/broken_lines.gif"> <a href="dtr_operations/dtr_awol.jsp" target="edtrmainFrame">View/Update AWOL</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/fix_dtr_date.jsp" target="edtrmainFrame">Fix DTR dates</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/holiday_credit.jsp" target="edtrmainFrame">Auto Credit Holiday</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/dtr_update_old.jsp" target="edtrmainFrame">Recompute OLD EDTR (Hours)</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/dtr_update_late.jsp" target="edtrmainFrame">Recompute OLD EDTR (Late)</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr_operations/dtr_update_ut.jsp" target="edtrmainFrame">Recompute OLD EDTR (UT)</a><br>
<img src="../../images/broken_lines.gif"> <a href="./reports/leave_wout_pay.jsp" target="edtrmainFrame">Leave Without Pay</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/monthly_report_sd_acctng.jsp?sd=1" target="edtrmainFrame">Personnel Late/UT/AWOL</a><br>
<img src="../../images/broken_lines.gif"> <a href="edtr_utilities/updated_dtr.jsp" target="edtrmainFrame">Updated DTR entries</a><br>
</font></span>
<%}%>
<%

}
if(strSchCode.startsWith("NEU") && !bolGrantAll) {
	if(comUtil.IsAuthorizedSubModule(dbOP,strUserId,"eDaily Time Record","STATISTICS & REPORTS - Restricted")!=0){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch15');swapFolder('folder15')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder15">
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">STATISTICS &amp; REPORTS</font></strong></div>
	<span class="branch" id="branch15"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif" color="#FFFFFF"> 
	<img src="../../images/broken_lines.gif"> <a href="dtr_operations/dtr_view.jsp" target="edtrmainFrame">View/Print  DTR</a><br>
	<img src="../../images/broken_lines.gif"> <a href="overtime/view_all_ot_request.jsp" target="edtrmainFrame">View/Print Overtime</a><br>
	</font></span>
<%}

}//for individual authentication.




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
