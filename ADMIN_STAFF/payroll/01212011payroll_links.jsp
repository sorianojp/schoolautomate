<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
	
boolean bolHasConfidential = false;
boolean bolIsGovernment = false;

String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
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
    <td width="8%" height="19" bgcolor="#E9E0D1">&nbsp;</td>
      <td width="92%" bgcolor="#E9E0D1"> <a href="<%if(bolIsSchool){%>../main%20files/admin_staff_home_button_content.htm<%}else{%>../../index.jsp<%}%>" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()" ><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
        <input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3">
        </a></td>
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
String strTemp = null;
boolean bolGrantAll = false;
boolean isAuthorized = false;
boolean bolShowAllLinks = false;
boolean bolNewSchool = false;
boolean bolHasLateConv = false;
boolean bolHasWeekly = false;

if(strUserId != null){
	//open dbConnection here to check if user is registered already.
	try
	{
		dbOP = new DBOperation();
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");		
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");		
		bolHasWeekly = (readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0")).equals("1");
 		if(strUserId.equals("bricks"))// para show tanan links
			bolShowAllLinks = true;
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


//Another way of checking authorization..
Vector vAuthList = null;
if(!bolGrantAll) {
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, "Payroll");
	if(vAuthList == null)
		vAuthList = new Vector();
	else if( ((String)vAuthList.elementAt(0)).compareTo("#ALL#") == 0)
		bolGrantAll = true;
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
 if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsDefaultPayrollRegister = true;
if(strSchCode.startsWith("VMUF") || strSchCode.startsWith("AUF") || strSchCode.startsWith("CGH") || strSchCode.startsWith("WNU")) 
	bolIsDefaultPayrollRegister = false;
	
if(strSchCode.startsWith("TAMIYA") || strSchCode.startsWith("TSUNE") || strSchCode.startsWith("FADI"))
	bolHasLateConv = true;

//old way of calling..
//comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Enrollment","ROOMS MONITORING")!=0
if(bolGrantAll || vAuthList.indexOf("TAX STATUS") != -1){isAuthorized=true;%>
<img src="../../images/arrow_blue.gif" border="0" ><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> <a href="tax_status/tax_status_main.jsp" target="payrollmainFrame">TAX STATUS</a></font></strong><br>
<%}if(bolGrantAll || vAuthList.indexOf("SALARY RATE") != -1){isAuthorized=true;%>
<img src="../../images/arrow_blue.gif" border="0" ><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> <a href="salary_rate/salary_rate_main.jsp" target="payrollmainFrame">SALARY RATE</a></font></strong><br>
<%}if(strSchCode.startsWith("TSUNEISHI") && (bolGrantAll || vAuthList.indexOf("LEAVE CONVERSION") != -1)){isAuthorized=true;%>
<img src="../../images/arrow_blue.gif" border="0" ><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> <a href="dtr/leave/leave_conversion_batch.jsp" target="payrollmainFrame">Leave Conversion(batch)</a></font></strong><br>
<!--
i guess this was for CPU before....
<img src="../../images/arrow_blue.gif" border="0" ><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> <a href="increment/encode_salary_inc.jsp" target="payrollmainFrame">SALARY INCREMENT</a> </font></strong><br>
-->
<%}if(bolGrantAll || vAuthList.indexOf("CONFIGURATION") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CONFIGURATION</font></strong></div>
<span class="branch" id="branch2"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../../images/broken_lines.gif"> <a href="configuration/auto_config.jsp" target="payrollmainFrame">Auto Create(Configuration)</a><br>
<%}if(bolGrantAll){isAuthorized=true;%>
<!--
<img src="../../images/broken_lines.gif"> <a href="confidential/confidential_setting.jsp" target="payrollmainFrame">Confidential Setting</a><br>
-->
<%if(bolHasConfidential || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="confidential/group_setting.jsp" target="payrollmainFrame">Group Setting</a><br>
<img src="../../images/broken_lines.gif"> <a href="confidential/group_processor.jsp" target="payrollmainFrame">Group Processor</a><br>
<%}%>
<%}if(bolGrantAll || vAuthList.indexOf("CONFIGURATION") != -1 || vAuthList.indexOf("CONFIGURATION-TT") != -1){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"> <a href="configuration/tax_table.jsp" target="payrollmainFrame">Tax table</a><br>
<img src="../../images/broken_lines.gif"> <a href="configuration/tax_per_type.jsp" target="payrollmainFrame">Tax table Per Salary Type</a><br>
<%}if(bolGrantAll || vAuthList.indexOf("CONFIGURATION") != -1 || vAuthList.indexOf("CONFIGURATION-TE") != -1){isAuthorized=true;%>
<!--
<img src="../../images/broken_lines.gif"> <a href="configuration/tax_exemptions.jsp" target="payrollmainFrame">Tax exemption</a><br>
-->
<img src="../../images/broken_lines.gif"> <a href="configuration/tax_exemptions_manual.jsp" target="payrollmainFrame">Tax exemption</a><br>
<%}if(bolGrantAll || vAuthList.indexOf("CONFIGURATION") != -1 || vAuthList.indexOf("CONFIGURATION-SSS") != -1){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"> <a href="configuration/sss_table.jsp" target="payrollmainFrame">SSS contribution table</a><br>
<%}if(bolGrantAll || vAuthList.indexOf("CONFIGURATION") != -1 || vAuthList.indexOf("CONFIGURATION-PH") != -1){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"> <a href="configuration/philhealth_table.jsp" target="payrollmainFrame">Philhealth contribution table</a><br>
<%}if(bolGrantAll || vAuthList.indexOf("CONFIGURATION") != -1 || vAuthList.indexOf("CONFIGURATION-OTHERS") != -1){isAuthorized=true;%>
<%if(!strSchCode.startsWith("UI")){%>
<img src="../../images/broken_lines.gif"> <a href="configuration/pagibig_contribution.jsp" target="payrollmainFrame">Pag-ibig contribution</a><br>
<%}else{%>
<img src="../../images/broken_lines.gif"> <a href="configuration/pagibig_contribution_new.jsp" target="payrollmainFrame">Pag-ibig contribution</a><br>
<%}%>
<%if(bolIsGovernment || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="configuration/gsis_contribution.jsp" target="payrollmainFrame">GSIS contribution</a><br>
<!--
<img src="../../images/broken_lines.gif"> <a href="configuration/gsis_no.jsp" target="payrollmainFrame">GSIS Numbers</a><br>
-->
<%}%>
<img src="../../images/broken_lines.gif"> <a href="configuration/set_contribution_basis.jsp" target="payrollmainFrame">Contribution Basis</a><br>
<%}%>
<%if(bolGrantAll || vAuthList.indexOf("CONFIGURATION") != -1){isAuthorized=true;%>
<%if(strSchCode.startsWith("CLDH") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"><a href="configuration/peraa_contribution.jsp" target="payrollmainFrame"> PERAA contribution(CL)</a><br>
<%}%>
<%if(strSchCode.startsWith("AUF") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"><a href="configuration/peraa_contribution.jsp" target="payrollmainFrame"> Ret. Plan Premium(AU)</a><br>
<%}%>

<img src="../../images/broken_lines.gif"> <a href="configuration/schedule_deduction.jsp" target="payrollmainFrame">Schedule of deduction</a><br>

<%if(strSchCode.startsWith("AUF") || !bolIsSchool){%>
<img src="../../images/broken_lines.gif"> <a href="../HR/personnel/sal_ben_incent_mgmt_main.jsp" target="payrollmainFrame">Salary/Benefits/Incentives Mgmt</a><br>
<%}%>
<%if(!strSchCode.startsWith("CLDH")){%>
<img src="../../images/broken_lines.gif"> <a href="configuration/cola_ecola.jsp?is_cola=1" target="payrollmainFrame">COLA/ECOLA</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="configuration/allowance/variable_allowance_main.jsp" target="payrollmainFrame">Variable Allowance</a><br>
<%if(false){%>
<img src="../../images/broken_lines.gif"> <a href="configuration/holidays_pay_implementation.htm" target="payrollmainFrame">Holidays Credit Pay <br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Implementation</a><br>
<%}%>
<%}%>
<%if(bolGrantAll || vAuthList.indexOf("CONFIGURATION") != -1 || vAuthList.indexOf("CONFIGURATION-ITEMDED") != -1){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"> <a href="configuration/set_items_deducted_from_gross.jsp" target="payrollmainFrame">Items Deducted from Gross<br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Income For Tax Computation</a><br>
<%}if(bolGrantAll || vAuthList.indexOf("CONFIGURATION") != -1 || vAuthList.indexOf("CONFIGURATION-SETADDLMNTH") != -1){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"> <a href="configuration/additional_month_pay/addtl_mth_pay_main.jsp" target="payrollmainFrame">Set Additional Month <br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Pay Parameters</a><br>
<%}%>
<%if(bolGrantAll || vAuthList.indexOf("CONFIGURATION") != -1){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"> <a href="configuration/overtime_rate.jsp" target="payrollmainFrame">Set Overtime Rates</a><br>
<img src="../../images/broken_lines.gif"> <a href="configuration/overtime_mgmt/overtime_type_create.jsp?ot_type=1" target="payrollmainFrame"> 
Overtime Type Mgmt</a><br>
<img src="../../images/broken_lines.gif"> <a href="configuration/overtime_mgmt/overtime_type_create.jsp" target="payrollmainFrame"> 
Adjustment Type Mgmt</a><br>
<%if(bolIsGovernment || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="configuration/step_increment/step_increment_main.jsp" target="payrollmainFrame">Step Increment Management(GOV)</a><br>
<%}%>
<!--
<img src="../../images/broken_lines.gif"> <a href="configuration/min_rate_setting.jsp" target="payrollmainFrame">Minimum Daily Rate</a><br>
-->
<img src="../../images/broken_lines.gif"> <a href="configuration/tax_override/tax_override.jsp" target="payrollmainFrame">Tax Setting Override</a><br>
<%if(strSchCode.startsWith("CLDH") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="configuration/cash_gift/cash_gift_main.jsp" target="payrollmainFrame">Cash Gift Management(CL)</a><br>
<%}// end if cldh%>
<%if(strSchCode.startsWith("CGH") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="configuration/distortion/distortion_setting.jsp" target="payrollmainFrame">Distortion Management(CG)</a><br>
<%}// end if CGH%>
<img src="../../images/broken_lines.gif"> <a href="configuration/salary_floor/sal_floor_setting.jsp" target="payrollmainFrame">Floor Salary Setting</a><br>
<img src="../../images/broken_lines.gif"> <a href="configuration/payslip_setting.jsp?is_for_sheet=0" target="payrollmainFrame">Payslip Setting</a><br>
<% 
	 if(!strSchCode.startsWith("CGH")){
   if(!strSchCode.startsWith("UI")){
   if(!strSchCode.startsWith("AUF")){
	 if(!strSchCode.startsWith("UDMC")){
	 if(!strSchCode.startsWith("CLDH")){
	 if(!strSchCode.startsWith("VMUF")){%>
<img src="../../images/broken_lines.gif"> <a href="configuration/payslip_use.jsp" target="payrollmainFrame">Payslip to Use</a><br>
	<% }// !VMUF
	 	 }// !CLDH
	  }// !UDMC
	 }// !AUF
	}// !UI
}// !CGH%>
<%if(!strSchCode.startsWith("AUF") || strUserId.equals("bs-01") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="configuration/payslip_setting.jsp?is_for_sheet=1" target="payrollmainFrame">Payroll Sheet/Register Setting</a><br>
<%}%>
<%if(strSchCode.startsWith("VMUF") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="configuration/employer_setting.jsp" target="payrollmainFrame">Employer Mapping</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="configuration/deduction_priority.jsp" target="payrollmainFrame">Deduction Priority</a><br>
<%if(bolIsSchool || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="configuration/faculty_term_type.jsp" target="payrollmainFrame">Faculty Term Type</a><br>
<img src="../../images/broken_lines.gif"> <a href="configuration/term_inc_dates.jsp" target="payrollmainFrame">Term Inclusive Dates</a><br>
<%}%>
<%if(bolHasLateConv || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="configuration/dtr_late_conversion.jsp" target="payrollmainFrame">Late Conversion</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="configuration/payroll_setting.jsp" target="payrollmainFrame">Payroll Parameters</a><br>
<%}%>
</font></span>
<%if(bolGrantAll || vAuthList.indexOf("DTR") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">DTR</font></strong></div>
<span class="branch" id="branch1"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../../images/broken_lines.gif"> <a href="dtr/salary_period_range.jsp" target="payrollmainFrame">Auto 
Create Salary Period</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr/salary_period_new.jsp" target="payrollmainFrame">Salary Period</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr/salary_period_setting.jsp" target="payrollmainFrame">Salary Schedule</a><br>
<%if(strSchCode.startsWith("AUF") || !bolIsSchool){%>
<img src="../../images/broken_lines.gif"> <a href="../HR/personnel/hr_personnel_service_rec_benefit.jsp" target="payrollmainFrame">Update Employee Benefits</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="dtr/dtr_manual.jsp" target="payrollmainFrame">DTR Entry (Manual)</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr/autocreate_pay.jsp" target="payrollmainFrame">Create Payroll (Batch)</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr/batch_delete.jsp" target="payrollmainFrame">Remove Payroll (Batch)</a><br>
<%if(bolShowAllLinks || bolGrantAll){%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_bonus_encoding.jsp" target="payrollmainFrame">Addl Month Pay (Manual-Batch)</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="dtr/generate_bonus_emplist.jsp" target="payrollmainFrame">Addl Month Pay (Auto)</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr/additional_month/addl_month.jsp" target="payrollmainFrame">Addl Month Pay</a><br>
<%if(bolShowAllLinks || strSchCode.startsWith("FOODA")){%>
<img src="../../images/broken_lines.gif"> <a href="dtr/additional_month/move_bonus.jsp" target="payrollmainFrame">Forward bonus to salary</a><br>
<%}
if((bolIsSchool && !strSchCode.startsWith("UI")) || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/encode_hours_worked.jsp" target="payrollmainFrame">Encoding hours worked for<br>&nbsp;&nbsp;&nbsp;&nbsp;Faculties</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/encode_duration_manual.jsp" target="payrollmainFrame">Manual Encoding days/hours<br>&nbsp;&nbsp;&nbsp;&nbsp;work</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/encode_awol_amt.jsp" target="payrollmainFrame">Manual Encoding Absence
</a><br>
<%if(strSchCode.startsWith("UDMC")){%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/allowances_manual_udmc.jsp" target="payrollmainFrame">Manual Allowances Encoding</a><br>
<%}else{%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/allowances_manual.jsp" target="payrollmainFrame">Manual Allowances Encoding</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/tax_manual.jsp" target="payrollmainFrame">Manual Tax Encoding</a><br>
<%if(bolIsSchool){%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/subject_allowances.jsp" target="payrollmainFrame">Subject Allowances Encoding</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/encode_manual_adjust.jsp" target="payrollmainFrame">Manual Adjustment Encoding</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr/absences_encoding_main.jsp" target="payrollmainFrame">Encoding of Absences for<br>&nbsp;&nbsp;&nbsp;&nbsp; <%if(bolIsSchool){%>Faculties/<%}%>Non-DTR Employee</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_contributions/manual_contribution_main.jsp" target="payrollmainFrame">Fixed Employee Contribution</a><br>
<!--
<img src="../../images/broken_lines.gif"> <a href="dtr/cont_manual_entry.jsp" target="payrollmainFrame">Manual Contribution Entry</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr/dtr_view_edit.jsp" target="payrollmainFrame">View/Edit Hours Worked</a><br>
-->
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/overtime/overtime_main.jsp" target="payrollmainFrame">Manual Overtime Encoding</a><br>
<%if(strSchCode.startsWith("CLDH") || strSchCode.startsWith("CGH") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/encode_hours_overload.jsp" target="payrollmainFrame">Overload Hours Encoding(*)</a><br>
<%}%>
<%if(strSchCode.startsWith("VMUF") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/hours_overload_vmuf.jsp" target="payrollmainFrame">Overload Hours Encoding(VMU)</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/encode_previous_sal.jsp" target="payrollmainFrame">Previous Salary Encoding</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr/leave/leave_conversion.jsp" target="payrollmainFrame">Leave Conversion</a><br>
<%if(strSchCode.startsWith("TSUNEISHI") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="dtr/leave/leave_conversion_batch.jsp" target="payrollmainFrame">Leave Conversion(batch)</a><br>
<%}%>
<%if(strSchCode.startsWith("CLDH") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="dtr/cash_gift/cash_gift_create.jsp" target="payrollmainFrame">Cash Gift Create(CL)</a><br>
<%}%>
<%if(strSchCode.startsWith("CGH") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/commendation.jsp" target="payrollmainFrame">Commendation(CG)</a><br>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/built_in_ci/ci_main.jsp" target="payrollmainFrame">Built-in CI / Physician(CG)</a><br>
<%}
if(bolIsSchool || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/substitutions/substitutions_main.jsp" target="payrollmainFrame">Faculty Substitutions</a><br>
<%}
if(false){%>
<img src="../../images/broken_lines.gif"> <a href="dtr/manual_encoding/holiday_credit.jsp" target="payrollmainFrame">Credit Holiday</a>
<%}%>
</font></span>
<%}if(bolGrantAll || vAuthList.indexOf("LOANS/ADVANCES") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">LOANS</font></strong></div>
<span class="branch" id="branch6"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../../images/broken_lines.gif"> <a href="loans_advances/loan_setting.jsp?loan_type=2" target="payrollmainFrame">Loans Setting</a><br>
<img src="../../images/broken_lines.gif"> <a href="loans_advances/encode_approved_loan.jsp" target="payrollmainFrame">Encode Approved <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%if(bolIsSchool){%>School <%}else{%>Company <%}%>Loan Data</a><br>
<img src="../../images/broken_lines.gif"> <a href="loans_advances/encode_loan_amo.jsp?loan_type=3" target="payrollmainFrame">Encode 
SSS Loan<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Amortization</a><br>
<img src="../../images/broken_lines.gif"> <a href="loans_advances/encode_loan_amo.jsp?loan_type=4" target="payrollmainFrame">Encode 
PAG-IBIG Loan <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Amortization</a><br>
<%if(bolIsSchool){
	if(strSchCode.startsWith("AUF"))
		strTemp = "Encode PS Bank Loan";
	else
		strTemp = "Encode PERAA Loan";
%>
<img src="../../images/broken_lines.gif"> <a href="loans_advances/encode_loan_amo.jsp?loan_type=5" target="payrollmainFrame"><%=strTemp%><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Amortization</a><br>
<%}%>
<%if(bolIsGovernment || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="loans_advances/encode_loan_amo.jsp?loan_type=6" target="payrollmainFrame">Encode 
GSIS Loan <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Amortization</a><br>
<%}%>
<%if(bolHasWeekly || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> 
<a href="loans_advances/encode_weekly_loan.jsp" target="payrollmainFrame">Encode Loan Amortization<br>
&nbsp;&nbsp;&nbsp;&nbsp; for Weekly Employees </a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="loans_advances/loan_pay_sched.jsp" target="payrollmainFrame">Set schedule as paid</a><br>
<img src="../../images/broken_lines.gif"> <a href="loans_advances/emp_loans_full.jsp" target="payrollmainFrame">Set Loan Payable to Zero</a><br>
<img src="../../images/broken_lines.gif"> <a href="loans_advances/loans_report_main.jsp" target="payrollmainFrame">Reports</a><br>
<!-- 
<img src="../../images/broken_lines.gif"> <a href="loans_advances/reports/search_by_loan.jsp" target="payrollmainFrame">Search by Loan</a><br>
<img src="../../images/broken_lines.gif"> <a href="loans_advances/view_fs_loan_ledger.jsp" target="payrollmainFrame">View F/S Loan Ledger</a><br>
<img src="../../images/broken_lines.gif"> <a href="loans_advances/loans_advances_entry.jsp" target="payrollmainFrame">Create Entries</a><br>
<img src="../../images/broken_lines.gif"> <a href="loans_advances/search_entry.jsp" target="payrollmainFrame">Search Entries</a><br>
<img src="../../images/broken_lines.gif"> <a href="loans_advances/search_by_loan.jsp" target="payrollmainFrame">Loans By Type</a><br>
 --></font></span>
<%}if(bolGrantAll || vAuthList.indexOf("MISC_EARNINGS") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch10');swapFolder('folder10')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder10">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">MISCELLANEOUS EARNINGS</font></strong></div>
<span class="branch" id="branch10"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../../images/broken_lines.gif"> <a href="misc_earnings/post_earnings.jsp" target="payrollmainFrame">Post Earnings </a><br>
<img src="../../images/broken_lines.gif"> <a href="misc_earnings/view_print_posted.jsp" target="payrollmainFrame">View/Print Posted Earnings</a><br>
</font></span>
<%}if(bolGrantAll || vAuthList.indexOf("MISC. DEDUCTIONS") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8">
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">MISC. DEDUCTIONS</font></strong></div>
<span class="branch" id="branch8"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../../images/broken_lines.gif"> <a href="misc_deductions/misc_deduction_main.jsp" target="payrollmainFrame">Post Deductions </a><br>
<img src="../../images/broken_lines.gif"> <a href="misc_deductions/view_print_posted.jsp" target="payrollmainFrame">View/Print Posted Deductions</a><br>
<img src="../../images/broken_lines.gif"> <a href="misc_deductions/view_posted_balances.jsp" target="payrollmainFrame">Posted Deductions w/ (Balance) </a><br>
<img src="../../images/broken_lines.gif"> <a href="misc_deductions/total_recurring.jsp" target="payrollmainFrame">Total Recurring Deduction</a><br>
<%if(strSchCode.startsWith("ILIGAN") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="misc_deductions/total_recurring_detailed.jsp" target="payrollmainFrame">Detailed Recurring Deduction</a><br>
<%}%>
</font></span>
<%}if(bolGrantAll || vAuthList.indexOf("EARNING DEDUCTIONS") != -1){isAuthorized=true;%>
<%if(strSchCode.startsWith("WNU")){%>
<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder7"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">EARNING DEDUCTIONS</font></strong></div>
<span class="branch" id="branch7"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../../images/broken_lines.gif"> <a href="earnings_deductions/earning_deduct.jsp" target="payrollmainFrame">Post Deductions </a><br>
<img src="../../images/broken_lines.gif"> <a href="earnings_deductions/view_print_posted.jsp" target="payrollmainFrame">View/Print Posted Deductions</a><br>
</font></span>
<%}%>
<%}if(bolGrantAll || vAuthList.indexOf("REPORTS") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch9');swapFolder('folder9')">
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder9"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">REPORTS</font></strong></div>

<span class="branch" id="branch9"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../../images/broken_lines.gif"> <a href="reports/emp_with_balances.jsp" target="payrollmainFrame">Employee Payable Balances</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/payslips/pay_slips_main.jsp" target="payrollmainFrame">Pay 
Slips</a><br>
<%if(strSchCode.startsWith("CLDH")){%>
<img src="../../images/broken_lines.gif"><a href="reports/for_bank_listing_cldh.jsp" target="payrollmainFrame">Bank List (per Department)</a><br>
<%}else{%>
<img src="../../images/broken_lines.gif"><a href="reports/atm_payroll_listing.jsp" target="payrollmainFrame">ATM/Non-ATM Payroll List</a><br>
<%}%>
<%if(strSchCode.startsWith("VMUF") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_breakdown.jsp" target="payrollmainFrame">Payroll breakdown(per Department) (VMU)</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="reports/employee_ledger/employee_ledger.jsp" target="payrollmainFrame">Employee Ledger</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/monthly_misc_ded.jsp" target="payrollmainFrame">Miscellaneous Deductions</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/misc_ded_payable.jsp" target="payrollmainFrame">Misc. postings not deducted</a> <br>
<%if(bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/emp_with_awol_rest_date.jsp" target="payrollmainFrame">Employees with absence <br>
&nbsp;&nbsp;&nbsp;&nbsp;before/after rest day</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="reports/monthly_other_contribution.jsp" target="payrollmainFrame">Contributions/Plans</a><br>
<!--
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_summary_by_employee.jsp" target="payrollmainFrame">Payroll Summary <br>
&nbsp;&nbsp;&nbsp;&nbsp;(By Employee)</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_summary_by_group.jsp" target="payrollmainFrame">Payroll Summary <br>
&nbsp;&nbsp;&nbsp;&nbsp;(By Payroll Group)</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/generate_addl_month_pay.jsp" target="payrollmainFrame">Payroll Summary <br>
&nbsp;&nbsp;&nbsp;&nbsp;Additional Pay(Bonuses)</a><br>
-->
<%if(strSchCode.startsWith("UI") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_summary_addl_pay.jsp" target="payrollmainFrame">Payroll Summary<br>
&nbsp;&nbsp;&nbsp;&nbsp;(Additional Pay)(UI)</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_summary_per_bank.jsp" target="payrollmainFrame">Payroll Summary <br>
&nbsp;&nbsp;&nbsp;&nbsp;(Per Bank)(UI)</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_summary_per_office.jsp" target="payrollmainFrame">Employee Summary <br>
&nbsp;&nbsp;&nbsp;&nbsp;Per Office(UI)</a><br>
<%}%>
<%if(strSchCode.startsWith("VMUF") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_sheet/payroll_sheet_vmuf.jsp" target="payrollmainFrame">Payroll Sheet(VMU)</a><br>
<%}%>
<%if(strSchCode.startsWith("AUF") || bolShowAllLinks){%>
<%if(strUserId.equals("bs-01") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_sheet/psheet_auf.jsp" target="payrollmainFrame">Payroll Master For Check</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_sheet/payroll_sheet_auf.jsp" target="payrollmainFrame">Payroll Master List</a><br>
<%}%>
<%if(strSchCode.startsWith("CGH") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_sheet/payroll_sheet_main.jsp" target="payrollmainFrame">Payroll 
Sheet Main</a><br>
<%}%>
<%if(strSchCode.startsWith("WNU") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_sheet/payroll_register_wnu.jsp" target="payrollmainFrame">Payroll Register(WNU)</a><br>
<%}%>
<%if(bolIsDefaultPayrollRegister || !bolIsSchool || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_sheet/payroll_register_cl.jsp" target="payrollmainFrame">Payroll Register</a><br>
<%}%>
<%if(!bolIsSchool || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_sheet/psheet_grouped.jsp" target="payrollmainFrame">Payroll Register by Office</a><br>
<%}%>
<%if(strSchCode.startsWith("UDMC") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_sheet/payroll_reg_udmc.jsp" target="payrollmainFrame">Payroll Register</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_sheet/psheet_summary_udmc.jsp" target="payrollmainFrame">Payroll Register Summary</a><br>
<%}%>
<%if(strSchCode.startsWith("ILIGAN") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_sheet/payroll_register_ili.jsp" target="payrollmainFrame">Payroll Register(ILI)</a><br>
<%}%>
<%if(strSchCode.startsWith("DBTC") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_summary_bystatus.jsp" target="payrollmainFrame">Payroll 
Summary<br>&nbsp;&nbsp;&nbsp;&nbsp;(By Status)</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="reports/alphalist/alphalist_main.jsp" target="payrollmainFrame">TAX 
Schedules (Alphalist)</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/tax_status_summary/tax_status_summary_page1.jsp" target="payrollmainFrame">TAX 
Status Summary</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/tax_year_to_date.jsp" target="payrollmainFrame">Tax Withheld for Year</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/tax_report/non_tax_income_main.jsp" target="payrollmainFrame">Non Taxable Income</a><br>
<!--
<img src="../../images/broken_lines.gif"> <a href="reports/payroll_masterlist_AUF.jsp" target="payrollmainFrame">Salary Master List</a><br>
-->
<img src="../../images/broken_lines.gif"> <a href="reports/remittances/remittances_main.jsp" target="payrollmainFrame">Remittances</a> <br>
<%if(bolIsGovernment || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/step_increment/step_inc_main.jsp" target="payrollmainFrame">Step Increment(GOV)</a><br>
<img src="../../images/broken_lines.gif"> <a href="reports/longevity/quarterly_longevity.jsp" target="payrollmainFrame">Longevity Pay(GOV)</a><br>
<%}%>
<%if(bolShowAllLinks || strSchCode.startsWith("VMUF") || strSchCode.startsWith("FADI")){%>
<img src="../../images/broken_lines.gif"> <a href="reports/bonuses/bonus_details.jsp" target="payrollmainFrame">Salary Details(for bonus)</a><br>
<%}%>
<%if(bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="reports/bonuses/current_bonus_emplist.jsp" target="payrollmainFrame">Bonus Checker</a><br>
<%}%>
<%if(strSchCode.startsWith("LHS") || strSchCode.startsWith("DBTC") || bolShowAllLinks){%>
<img src="../../images/broken_lines.gif"> <a href="coa_mapping/coa_main.jsp" target="payrollmainFrame">Payroll COA Config</a><br>
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
</div>
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>