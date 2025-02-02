<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
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
String strSchCode    = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";

boolean bolIsWNUSuperUser = false;//a super user to manage system admins.
boolean bolIsWNURestrictedUser = false;//a restricted System admin

boolean bolShowBroadcastMsg = false;
if(strSchCode.startsWith("UC"))
	bolShowBroadcastMsg = true;
	
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

	    String strSQLQuery = "select MANAGE_USER_INDEX from SYSAD_MANAGE_USER where USER_INDEX_TO_MANAGE is null " +
    	  " and SYSAD_USER_INDEX = "+(String)request.getSession(false).getAttribute("userIndex");
    	if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null)
      		bolIsWNUSuperUser = true;
	    strSQLQuery = "select MANAGE_USER_INDEX from SYSAD_MANAGE_USER where USER_INDEX_TO_MANAGE is not null " +
    	  " and SYSAD_USER_INDEX = "+(String)request.getSession(false).getAttribute("userIndex");
    	if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null)
      		bolIsWNURestrictedUser = true;
		

	}
}
else
	strErrMsg = "";


//for WNU, reset password is split.. 
boolean bolResetPassword = false;
boolean bolResetStudentPassword = false;
boolean bolShowAssignRFID = false;
if(!bolGrantAll && comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","USER MANAGEMENT") == 0 && comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","USER MANAGEMENT-RESET PASSWORD") != 0)
	bolResetPassword = true;
if(!bolGrantAll && comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","USER MANAGEMENT") == 0 && comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","USER MANAGEMENT-RESET STUDENT PASSWORD") != 0)
	bolResetStudentPassword = true;
if(!bolGrantAll && comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","USER MANAGEMENT") == 0 && comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","ASSIGN RFID") != 0)
	bolShowAssignRFID = true;



if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","USER MANAGEMENT")!=0 || bolResetPassword || bolResetStudentPassword){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">USER MANAGEMENT </font></strong></div>
<span class="branch" id="branch1">
<%if(bolResetStudentPassword) {%>
		<img src="../../images/broken_lines.gif"> <a href="./student_password.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Student Password</font></a><br>
<%}else if(bolResetPassword) {
	if(!strSchCode.startsWith("CSA") && !strSchCode.startsWith("UB")) {%>
		<img src="../../images/broken_lines.gif"> <a href="accessibility.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Accessibility</font></a><br>
	<%}%>
		<img src="../../images/broken_lines.gif"> <a href="./student_password.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Student Password</font></a><br>
<%}else{%>
	<img src="../../images/broken_lines.gif"> <a href="profile.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Profile</font></a><br>
	<img src="../../images/broken_lines.gif"> <a href="authentication/main.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Authentication</font></a><br>
	<%if(!bolIsWNURestrictedUser){%>
		<img src="../../images/broken_lines.gif"> <a href="accessibility.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Accessibility</font></a><br>
	<%}%>
	<img src="../../images/broken_lines.gif"> <a href="user_stat.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Users Status </font></a><br>
	<img src="../../images/broken_lines.gif"> <a href="./login_activity.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Login Activity</font></a><br>
	<img src="../../images/broken_lines.gif"> <a href="./barcode_mgmt.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Assign RFID to Login ID </font></a><br>
<%if(strSchCode.startsWith("SPC") || strSchCode.startsWith("EAC") || strSchCode.startsWith("UL") || strSchCode.startsWith("CDD") || strSchCode.startsWith("UPH")) {%>
	<img src="../../images/broken_lines.gif"> <a href="./assign_turnstile_mastercard.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Set Turnstile Master Card/User</font></a><br>
<%}%>
	<%if(bolIsSchool){%>
		<img src="../../images/broken_lines.gif"> <a href="./student_password.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Student Password</font></a><br>
	<%}else{%>
		<img src="../../images/broken_lines.gif"> <a href="./update_employee_id.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Update Employee ID </font></a><br>
	<%}if(bolIsWNUSuperUser){%>
		<img src="../../images/broken_lines.gif"> <a href="./su/su_manage_main.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Manage Super User</font></a><br>
	<%}%>

	<%if(strSchCode.startsWith("NEU")) {%>
			<img src="../../images/broken_lines.gif"> <a href="./student_password_batch.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Student Password Print Batch</font></a><br>
	<%}%>
<%}%>
</span>
<!-- <img src="../../images/small_white_box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./set_param_gs.jsp" target="useradminmainFrame">SET PARAMETERS
 </a> </font></strong> -->
<%}
if(bolShowAssignRFID){isAuthorized=true;%>
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
  	<img src="../../images/arrow_blue.gif"border="0"> <a href="barcode_mgmt.jsp" target="useradminmainFrame">Assign RFID</a>
  </font></strong>
<%}
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","SET PARAMETERS")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">SET PARAMETERS</font></strong></div>
<span class="branch" id="branch2"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<%if(bolIsSchool){%>
<%if(strSchCode.startsWith("CIT")) {%>
	<img src="../../images/broken_lines.gif"> <a href="../ADMISSION MAINTENANCE MODULE/school_year/sy.jsp" target="useradminmainFrame">Set Default SY-Term</a><br>
<%}%>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/set_dates/main.jsp" target="useradminmainFrame">Set System Dates</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./set_color_scheme.jsp" target="useradminmainFrame">Set System Color Scheme</a><br>
<%if(bolShowBroadcastMsg) {%>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/broadcast_msg.jsp" target="useradminmainFrame">Set Broadcast Message</a><br>
<%}%>
<%if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("NEU")){%>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/hold_unhold_student.jsp" target="useradminmainFrame">Hold - UnHold Student</a><br>
<%}%>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/bday_msg.jsp" target="useradminmainFrame">Set Birthday Message</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/lock_cur.jsp" target="useradminmainFrame">Lock Curiculum</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/lock_fee_main.htm" target="useradminmainFrame">Lock Fees</a><br>
	<img src="../../images/broken_lines.gif"> <a href="set_param/grade_setting_main.jsp" target="useradminmainFrame">Grade Sheet Setting</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./set_param_e_security.jsp" target="useradminmainFrame">eSecurity</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./set_param_user_acct_validity.jsp" target="useradminmainFrame">User Account Validity</a><br>
	<%
	if(!strSchCode.startsWith("LNU")){%>
		<img src="../../images/broken_lines.gif"> <a href="./set_param/system_set.jsp" target="useradminmainFrame">System Setting</a><br>
	<%}%>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/manage_mod_submod.jsp" target="useradminmainFrame">Manage Module/Submodule Links</a><br>
	<%if(strSchCode.startsWith("UDMC") || strUserId.equals("1770") || strSchCode.startsWith("DBTC") || 
	strSchCode.startsWith("PIT") || strSchCode.startsWith("CIT")){%>
		<img src="../../images/broken_lines.gif"> <a href="./pre_enrollment/pre_enrollment_main.htm" target="useradminmainFrame">Pre-Enrollment Setting</a><br>
	<%}%>
		<img src="../../images/broken_lines.gif"> <a href="./set_param/set_msg_user.jsp" target="useradminmainFrame">Message System</a><br>
<%if(!strSchCode.startsWith("UB")){%>
		<img src="../../images/broken_lines.gif"> <a href="./set_param/set_advising_rule.jsp" target="useradminmainFrame">Set Enrollment-advising Rules</a><br>
<%}if(strSchCode.startsWith("CIT")){%>
		<img src="../../images/broken_lines.gif"> <a href="./set_param/lock_credential_access.jsp" target="useradminmainFrame">Block Credential Access</a><br>
		<img src="../../images/broken_lines.gif"> <a href="./set_param/lock_stud_batch.jsp" target="useradminmainFrame">Lock Advising by Dept. - Batch</a><br>
<%}%>

<%}else{//links for company...%>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/bday_msg.jsp" target="useradminmainFrame">Set Birthday Message</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./set_param_user_acct_validity.jsp" target="useradminmainFrame">User Account Validity</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/system_set.jsp" target="useradminmainFrame">System Setting</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/division.jsp" target="useradminmainFrame">Manage Division</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/department.jsp" target="useradminmainFrame">Manage Department </a><br>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/set_msg_user.jsp" target="useradminmainFrame">Send Msg to User </a><br>
<%}
if(strSchCode.startsWith("AUF")){%>
	<img src="../../images/broken_lines.gif"> <a href="./table_migration/main.jsp" target="useradminmainFrame">Move Records to Backup DB</a><br>
<%}%>	
<%if(strSchCode.startsWith("FATIMA")){%>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/generate_fatima_id_in_advance.jsp" target="useradminmainFrame">Generate ID In Advance</a><br>
<%}%>	
<%if(true){%>
	<img src="../../images/broken_lines.gif"> <a href="./set_param/cit/setting_main.jsp" target="useradminmainFrame">Other System Setting</a><br>
<%}%>	
</font></span>
<%}
if(bolIsSchool){
	if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","OVERRIDE PARAMETERS")!=0){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3"> 
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">OVERRIDE PARAMETERS </font></strong></div>
	<span class="branch" id="branch3"> 
	<%if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","Override Parameters(Room Capacity)")!=0){%>
		<img src="../../images/broken_lines.gif"> <a href="override_room.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Room Capacity </font></a><br>
	<%}%>
	<img src="../../images/broken_lines.gif"><a href="./override_param/allow_prereq.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Allow Pre-requisite Subject</font></a><br>
	<img src="../../images/broken_lines.gif"><a href="override_subj_capacity.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Min. Subject Capacity</font></a><br>
	<img src="../../images/broken_lines.gif"> <a href="override_student_load.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Student Load</font></a><br>
	<img src="../../images/broken_lines.gif"> <a href="overload_student_detail.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Student OverLoad Detail</font></a><br>
	<img src="../../images/broken_lines.gif"> <a href="stud_repeater.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Student Repeater</font></a><br>
<%
if(strSchCode.startsWith("FATIMA")){%>
	<img src="../../images/broken_lines.gif"> <a href="./override_param/allow_zero.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Allow Zero Downpayment</font></a><br>
<%}%>
<%
if(strSchCode.startsWith("SWU")){%>
	<img src="../../images/broken_lines.gif"> <a href="../registrar/grade/grade_sheet_verify_swu_mgmt.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Allow Grade Verification</font></a><br>
<%}%>
	</span> 
<%}
}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","IP FILTER")!=0){isAuthorized=true;%>
<!--<img src="../../images/small_white_box.gif" width="7" height="7" border="0" > 
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./ip_filter.jsp" target="useradminmainFrame">IP FILTER </a></font></strong>--> 

<%}if(!bolIsSchool && bolGrantAll){%>
	<div class="trigger" onClick="showBranch('branch22');swapFolder('folder22')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder22">
	<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">FS Setting</font></strong></div>
	<span class="branch" id="branch22"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
		<img src="../../images/broken_lines.gif"> <a href="./fingerscan/exclude_user_fs.jsp" target="useradminmainFrame">Exclude FS Verification</a><br>
		<img src="../../images/broken_lines.gif"> <a href="../../search/srch_emp.jsp?fs=1" target="useradminmainFrame">Search Employee</a><br> 
		</font>
	</span>
<%}
if(bolIsSchool){
	if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","APPLICATION FIX")!=0){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3"> 
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">APPLICATION FIX </font></strong></div>
	<span class="branch" id="branch4"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/convert_file_extension.jsp" target="useradminmainFrame">Convert Image extension JPG to jpg</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/insert_ledg_history_info.jsp" target="useradminmainFrame">Update Back Account</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/move_stud_id.jsp" target="useradminmainFrame"> Move Student ID</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/room_info_not_found.jsp" target="useradminmainFrame"> Room Info Not Found</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/update_coll_dept_offer.jsp" target="useradminmainFrame">Class Program College/Dept Offered by Information</a><br>
<%if(strSchCode.startsWith("SWU")){%>
	<!--
		<img src="../../images/broken_lines.gif"> <a href="./appl_fix/move_payment_swu.jsp" target="useradminmainFrame"> Move Payment</a><br>
	-->
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/update_coll_dept_offer_to.jsp" target="useradminmainFrame">Class Program College/Dept Offered TO Information</a><br>
<%}%>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/col_dept_sharing_section.jsp" target="useradminmainFrame">Class Program Shared by College/Dept</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/check_child_offering.jsp" target="useradminmainFrame">Check Class Program Error</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/check_room_conflict.jsp" target="useradminmainFrame">Check Room Assignment Error</a><br>
	<!--
		<img src="../../images/broken_lines.gif"> <a href="./appl_fix/fix_cur_hist_table.jsp" target="useradminmainFrame">Check Student Curriculum Standing Error</a><br>
	-->
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/fix_cur_hist_table_new.jsp" target="useradminmainFrame">Check Student Enrollment Record Duplicate Entry</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/auto_create_table.jsp" target="useradminmainFrame">Auto Create Table</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/move_multiple_payments.jsp" target="useradminmainFrame">Re-index Multiple Payment</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/lacking_info_dcc.jsp" target="useradminmainFrame">Lacking Info in DCC</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/missing_oth_sch_fee_post.jsp" target="useradminmainFrame">Missing Other School Fee - Debit Entry</a><br>
<%if(strSchCode.startsWith("FATIMA")){%>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/fatima_installment_doublepost.jsp" target="useradminmainFrame">Installment Fee Double Entry</a><br>
<%}%>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/temp_id_in_perm_table_error.jsp" target="useradminmainFrame">Valid Temp ID in Permanent Table</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./appl_fix/auto_credit_grade.jsp" target="useradminmainFrame">Auto Credit Grade</a><br>
	</font>
	<!--<img src="../../images/broken_lines.gif"> <a href="overload_student_detail.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Student 
	OverLoad Detail</font></a><br>-->
	</span> 
	<%}
	if(strSchCode.startsWith("AUF") || strSchCode.startsWith("CPU") || (strUserId != null && (strUserId.toLowerCase().equals("sa-01") || strUserId.equals("93245-0161"))) )
	if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","DATA MIGRATE")!=0){isAuthorized=true;%>
	<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3"> 
	  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">DATA MIGRATE </font></strong></div>
	<span class="branch" id="branch5"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
	<img src="../../images/broken_lines.gif"> <a href="./data_migration/migrate_sub.jsp" target="useradminmainFrame">Migrate Subject</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./data_migration/check_duplicate_sub.jsp" target="useradminmainFrame">Check Dup. Sub. Entry</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./data_migration/migrate_rooms.jsp" target="useradminmainFrame">Migrate Room Information</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./data_migration/migrate_hrprofile.jsp" target="useradminmainFrame">Migrate HR Profile(Basic and Login Info)</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./data_migration/migrate_hrInfo.jsp" target="useradminmainFrame">Migrate HR Profile(Other Info)</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./data_migration/migrate_studprofile.jsp" target="useradminmainFrame">Migrate Student Basic Info</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./data_migration/migrate_studledger.jsp" target="useradminmainFrame">Migrate Student Ledger</a><br>
	<img src="../../images/broken_lines.gif"> <a href="./data_migration/migrate_studgrade.jsp" target="useradminmainFrame">Migrate Student Grade Info</a><br>
	<%if(strSchCode.startsWith("CIT")) {%>
		<img src="../../images/broken_lines.gif"> <a href="./data_migration/others/main.jsp" target="useradminmainFrame">Other Migration</a><br>
	<%}%></font>
	</span> 
<%}//show only if school..
}
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","SYSTEM TRACKING")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">SYSTEM TRACKING</font></strong></div>
<span class="branch" id="branch6"> 
<%if(bolIsSchool){%>
	<img src="../../images/broken_lines.gif"> <a href="./sys_track/final_gs_mod.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Final Grade Modification</font></a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="./sys_track/access_log_main.jsp" target="useradminmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">User Access Log</font></a><br>
</span> 
<%}
if(strUserId.equals("1770"))
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","HELP MANAGEMENT")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">HELP MANAGEMENT</font></strong></div>
<span class="branch" id="branch7"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../../images/broken_lines.gif"> <a href="../../help/manage_links.jsp" target="useradminmainFrame">Manage Links</a><br>
<img src="../../images/broken_lines.gif"> <a href="../../help/manage_system_help.jsp" target="useradminmainFrame">Manage Help</a><br>
<img src="../../images/broken_lines.gif"> <a href="../../help/quick_help.jsp" target="useradminmainFrame">Manage Quick Help</a><br>
<img src="../../images/broken_lines.gif"> <a href="../../help/search_help.jsp" target="useradminmainFrame">Search Help</a><br>
<img src="../../images/broken_lines.gif"> <a href="../../help/manage_faq.jsp" target="useradminmainFrame">Manage FAQ</a><br>
<img src="../../images/broken_lines.gif"> <a href="../../help/search_faq.jsp" target="useradminmainFrame">Search FAQ</a><br>
</font></span> 
<%}
if(!bolGrantAll && comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","User Management - Accessibility")!=0){isAuthorized=true;%>
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
  	<img src="../../images/arrow_blue.gif"border="0"> <a href="accessibility.jsp" target="useradminmainFrame">User Management - Accessibility</a>
  </font></strong><br>
<%}
if(!bolGrantAll && comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","User Management - Authentication")!=0){isAuthorized=true;%>
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
  	<img src="../../images/arrow_blue.gif"border="0"> <a href="authentication/main.jsp" target="useradminmainFrame">User Management - Authentication</a>
  </font></strong><br>
<%}
if(!bolGrantAll && comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","Set Parameters-Lock Fees")!=0){isAuthorized=true;%>
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
  	<img src="../../images/arrow_blue.gif"border="0"> <a href="./set_param/lock_fee_main.htm" target="useradminmainFrame">Lock Fees</a>
  </font></strong><br>
<%}
if((strSchCode.startsWith("UB") || strSchCode.startsWith("NEU")) && (bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"System Administration","Enrollment-Advising Rules")!=0) ){isAuthorized=true;%>
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
  	<img src="../../images/arrow_blue.gif"border="0"> <a href="./set_param/set_advising_rule.jsp" target="useradminmainFrame">Set Enrollment - Advising Rules</a>
  </font></strong>
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
