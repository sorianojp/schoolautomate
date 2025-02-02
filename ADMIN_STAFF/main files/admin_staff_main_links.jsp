<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="CACHE-CONTROL" content="no-cache"/> 
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<link href="../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">

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

<style>
body{
scrollbar-base-color: #BC7E41
}
</style>
</head>

<body bgcolor="#C39E60" onLoad="MM_preloadImages('../../images/home_small_admin_rollover.gif','../../images/help_small_admin_rollover.gif','../../images/logout_admin_rollover.gif')">
<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
//check if user is logged in, if logged, check authentication list here and allow the authentic user to access the system.
DBOperation dbOP = null;
CommonUtil comUtil = new CommonUtil();
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strErrMsg = null;
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolHideAccounting = false;
boolean bolOnlyAccounting = false;

boolean bolIsCIT = strSchCode.startsWith("CIT");
if(strSchCode.startsWith("WNU") || bolIsCIT || strSchCode.startsWith("UC"))// || strSchCode.startsWith("SWU"))
	bolHideAccounting = true;

/** Un-comment this if this is accounting application server..
bolHideAccounting = false;
bolOnlyAccounting = true;
**/
boolean bolRemoveHostel = false;
if(strSchCode.startsWith("MARINER"))
	bolRemoveHostel = true;

boolean bolGrantAll = false;
if(strUserId != null)
{
	//open dbConnection here to check if user is registered already.
	try
	{
		dbOP = new DBOperation();
		//check if user has filled up the form.
		//check here the authentication of the user. 
		if(comUtil.IsSuperUser(dbOP,strUserId))
			bolGrantAll = true;	//grant all ;-)
		if(strUserId.compareTo("1770") == 0)
			strSchCode = "AUF";
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		strErrMsg = "error in opening connection.";
	}
}
else
	strErrMsg = "";

String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");

String strIsSMS     = null;

if(strUserIndex != null && strUserId != null) {
	strUserIndex = "select BASIC_USER_INDEX from BASIC_USER_LIST where BASIC_USER_INDEX = "+strUserIndex;
	strUserIndex = dbOP.getResultOfAQuery(strUserIndex, 0);
	if(strUserIndex != null)
		strErrMsg = "Authentication is Restricted to Basic Education Installation Only.To go back <a href='../../commfile/logout.jsp?logout_url=../ADMIN_STAFF/main%20files/admin_staff_bottom_content.htm' target=_parent>Click here</a>";
	if(bolGrantAll) {
		strIsSMS = "select prop_val from read_property_file where prop_name='SMS_STATUS'";
		strIsSMS = dbOP.getResultOfAQuery(strIsSMS, 0);
		if(strIsSMS != null && !strIsSMS.equals("1"))
			strIsSMS = null;
	}
}
if(strSchCode == null)
	strSchCode = "";

	
if(strIsSMS == null)
	strIsSMS = "0";	
//System.out.println("testing : strErrMsg ="+strErrMsg);
if(strErrMsg != null && strErrMsg.length() > 0)
{%>
<font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif" size="2"><b><%=strErrMsg%></b></font>
<%//System.out.println("testing");
if(dbOP != null)
	dbOP.cleanUP();
return;
}

//Another way of checking authorization.. 
Vector vAuthList = null;
if(!bolGrantAll) {
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, null);
}
if(vAuthList == null)
	vAuthList = new Vector();


boolean bolShowSAP = false;
boolean bolSAPSU   = false;

if(strSchCode.startsWith("UC")) {
	//put checks here for SAP. Check if SAP is given.. 
	String strSQLQuery = "select module_index from module where module_name = 'SAP'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	//check if user is authenticated.. 
	strSQLQuery = "select auth_list_index from user_auth_list where user_index = "+(String)request.getSession(false).getAttribute("userIndex")+
				" and main_mod_index = "+strSQLQuery +" and is_valid = 1";
	if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null) {
		bolShowSAP = true;
	}
	
}

//System.out.println(vAuthList);
//old way of calling.. 
//comUtil.IsAuthorizedModule(dbOP,strUserId,"System Administration")
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <form action="../../commfile/logout.jsp" method="post" target="_parent">
    <tr> 
      <td bgcolor="#E9E0D1" width="6%">&nbsp;</td>
      <td height="25" bgcolor="#E9E0D1"><a href="../../commfile/logout.jsp?logout_url=../index.htm" target="_top" onMouseOver="window.status='Go back to home page'; MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1); return true" onMouseOut="MM_swapImgRestore()" ><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"> 
        <input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3">
        </a></td>
    </tr>
    <input type="hidden" name="logout_url" value="../ADMIN_STAFF/main%20files/admin_staff_bottom_content.htm">
    <input type="hidden" name="body_color" value="#C39E60">
  </form>
  <%if(strUserId == null || strUserId.trim().length() ==0){
%>
  <tr> 
    <td>&nbsp;</td>
    <td height="25"><a href="./admin_staff_contentFrame.jsp" target="rightFrame"> 
      <img src="../../images/login_2.gif" border="0"></a><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><em>click 
      to login</em></font></td>
  </tr>
  <%}//show login if user is not logged in.%>
  
	  <tr> 
		<td height="10">&nbsp;</td>
		<td height="10" class="admissionmainmenu">&nbsp;</td>
	  </tr>
  
 
<%if(!bolOnlyAccounting){
	if(bolShowSAP){%>
		  <tr> 
			<td width="6%" height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
			<td width="94%" height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../sap/" target="_parent">SAP Integration</a></font></strong></td>
		  </tr>
	<%}



	if(bolGrantAll || vAuthList.indexOf("SYSTEM ADMINISTRATION") != -1){// comUtil.IsAuthorizedModule(dbOP,strUserId,"System Administration")){%>
	  <tr> 
		<td width="6%" height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td width="94%" height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../user_admin/user_admin_index.htm" target="_parent">System 
		  Administration</a></font></strong></td>
	  </tr>
	  <%}if(bolGrantAll){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Override Parameters")){%>
	  <tr>
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
		<a href="../fingerscan/fs_index.htm" target="_parent">Finger Scanner Interface</a></font></strong></td>
	  </tr>
	<%}if(bolGrantAll || vAuthList.indexOf("VISITOR MANAGEMENT") != -1){// comUtil.IsAuthorizedModule(dbOP,strUserId,"System Administration")){%>
	  <tr> 
		<td width="6%" height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td width="94%" height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../visit_log/total_visitors.jsp?pgIndex=0" target="rightFrame">Visitor's Management</a></font></strong></td>
	  </tr>
	<%}if(bolGrantAll || vAuthList.indexOf("OVERRIDE PARAMETERS") != -1){// comUtil.IsAuthorizedModule(dbOP,strUserId,"System Administration")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./override_parameter_links.jsp" target="_self">Override 
		  Parameters</a></font></strong></td>
	  </tr>
	<%}if(bolGrantAll  || vAuthList.indexOf("ENROLLMENT") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Enrollment")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		  <a href="../enrollment/enrollment_index.htm" target="_parent">Enrollment</a></font></strong></td>
	  </tr>
	<%}
	if(strSchCode.startsWith("CIT") || strSchCode.startsWith("FATIMA")) {
		if(bolGrantAll  || vAuthList.indexOf("BOOKSTORE") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Enrollment")){%>
		  <tr> 
			<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
			<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
			  <a href="../<%if(strSchCode.startsWith("CIT")){%>bookstore_new<%}else{%>bookstore<%}%>/bookstore_index.htm" target="_parent">Bookstore</a></font></strong></td>
		  </tr>
	<%}%>
	<%}if(bolGrantAll || vAuthList.indexOf("ADMISSION MAINTENANCE") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Admission Maintenance")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		  <a href="../ADMISSION%20MAINTENANCE%20MODULE/admin_admission_index.htm" target="bottomFrame">Admission 
		  Maintenance</a></font> </strong></td>
	  </tr>
	  <%}if(bolGrantAll || vAuthList.indexOf("ADMISSION") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Admission")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../admission/admission_index.htm" target="_parent">Admission</a></font></strong></td>
	  </tr>
	  <%}if(bolGrantAll || vAuthList.indexOf("FEE ASSESSMENT & PAYMENTS") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Fee Assessment & Payments")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		  <a href="../fee_assess_pay/fee_assess_pay_index.htm" target="_parent">Fee 
		  Assessment &amp; Payments</a></font></strong></td>
	  </tr>
	  <%}if(bolGrantAll || vAuthList.indexOf("REGISTRAR MANAGEMENT") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Registrar Management")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		  <a href="../registrar/admin_registrar_index.htm" target="bottomFrame">Registrar 
		  Management</a></font></strong></td>
	  </tr>
	  <%}//System.out.println(strSchCode);
	  if(!strSchCode.startsWith("CGH") && !strSchCode.startsWith("UDMC") && !strSchCode.startsWith("UI")) {
		if(bolGrantAll || vAuthList.indexOf("CLEARANCES") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Clearences")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../clearances/clearances_index.htm" target="bottomFrame">Clearances</a></font></strong></td>
	  </tr>
	  <%}
	  }if(bolGrantAll || vAuthList.indexOf("HR MANAGEMENT") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"HR Management")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		  <a href="../HR/admin_hr_index.htm" target="bottomFrame">HR Management</a></font></strong></td>
	  </tr>
<%    }
}//hide if it is only for accounting.%>

  <%if(bolGrantAll || vAuthList.indexOf("ACCOUNTING") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Accounting")){%>
	<%if(!bolHideAccounting){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../accounting/accounting_index.htm" target="_parent">Accounting</a></font></strong></td>
	  </tr>
	<%}%>

	<%if(request.getSession(false).getAttribute("userId").equals("1770")){%>
		  <tr> 
			<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
			<td height="22" class="admissionmainmenu"><a href="../accounting-new/accounting_index.htm" target="_parent">Accounting(new) - do not click</a></td>
		  </tr><%}%>
  <%}if(bolGrantAll || vAuthList.indexOf("EDAILY TIME RECORD") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"eDaily Time Record")){%>
  <tr> 
    <td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../e_dtr/edtr_index.htm" target="bottomFrame">eDaily 
      Time Record</a></font></strong></td>
  </tr>
  <%}
  if(!bolHideAccounting)
  if(bolGrantAll || vAuthList.indexOf("PAYROLL") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Payroll")){%>
  <tr> 
    <td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../payroll/payroll_index.htm" target="_parent">Payroll</a></font></strong></td>
  </tr>
<%}if(strSchCode.startsWith("CPU") && (bolGrantAll || vAuthList.indexOf("PAYROLL") != -1)){%>
  <tr>
    <td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../retirement/retirement_index.htm" target="_parent">Retirement</a></font></strong></td>
  </tr>
<%}
if(!bolOnlyAccounting){

	if(!strSchCode.startsWith("VMUF") && (bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"PURCHASING")) ){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../purchasing/purchasing_index.htm" target="bottomFrame">Purchasing</a></font></strong></td>
	  </tr>
	  <%}
		if(bolGrantAll || vAuthList.indexOf("INVENTORY") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Inventory")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../inventory/inventory_index.htm" target="bottomFrame">Inventory</a></font></strong></td>
	  </tr>
	  <%}
	  if(bolGrantAll || vAuthList.indexOf("GUIDANCE & COUNSELING") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Guidance & Counseling")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../guidance/guidance_index.htm" target="bottomFrame">Guidance 
		  &amp; Counseling</a></font></strong></td>
	  </tr>
	  <%}if(bolGrantAll || vAuthList.indexOf("STUDENT AFFAIRS") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Student Affairs")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../sao/sao_index.htm" target="bottomFrame">Student's 
		  Affairs</a></font></strong></td>
	  </tr>
	  <%}
		if(bolGrantAll || vAuthList.indexOf("ESECURITY CHECK") != -1 ){//comUtil.IsAuthorizedModule(dbOP,strUserId,"eSecurity Check")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../e_security/e_security_index.htm" target="bottomFrame">eSecurity 
		  Check</a></font></strong></td>
	  </tr>
	  <%}
	   if(!strSchCode.startsWith("CGH"))
		if(!strSchCode.startsWith("VMUF") && (bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"INTERNET CAFE MANAGEMENT")) ){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../internetlab/iL_index.htm" target="bottomFrame">Internet 
		  Cafe Management</a></font></strong></td>
	  </tr>
	  <%} if(!strSchCode.startsWith("VMUF") && (bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"HEALTH MONITORING")) ){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong> <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		  <a href="../health_monitoring/hm_index.htm" target="bottomFrame">Health 
		  Monitoring</a></font></strong></td>
	  </tr>
	  <%}if(!strSchCode.startsWith("CGH") && !strSchCode.startsWith("UDMC") && 
		!strSchCode.startsWith("CLDH") && !bolRemoveHostel) 
	  if(bolGrantAll || vAuthList.indexOf("HOSTEL MANAGEMENT") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Hostel Management")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../hostel/hostel_mgmt_index.htm" target="bottomFrame">Hostel 
		  Management</a></font></strong></td>
	  </tr>
	  <%} 
	  if(!strSchCode.equals("VMUF") && (bolGrantAll || vAuthList.indexOf("ORGANIZER") != -1) ){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Hostel Management")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../organizer/organizer_index.jsp" target="bottomFrame">Organizer</a></font></strong></td>
	  </tr>
	  <%}if(false && !strSchCode.startsWith("VMUF") && (bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"TRANSPORTATION")) ){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../hostel/hostel_mgmt_index.htm" target="bottomFrame">Transportation</a></font></strong></td>
	  </tr>
	  <%} if(false && !strSchCode.startsWith("VMUF") && (bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"CAFETERIA")) ){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../hostel/hostel_mgmt_index.htm" target="bottomFrame">Cafeteria</a></font></strong></td>
	  </tr>
	  <%} if((strSchCode.startsWith("SPC") || strSchCode.startsWith("UPH") || strSchCode.startsWith("EAC") || strSchCode.startsWith("NEU")) && (bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"CASH CARD")) ){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../cashcard/cash_card_index.htm" target="bottomFrame">Cash Card</a></font></strong></td>
	  </tr>
	  <%}if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"Parent Registration")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../parent_registration/main.jsp" target="rightFrame">Parent Registration</a></font></strong></td>
	  </tr>
	  <%}if(bolGrantAll || vAuthList.indexOf("DATA ARCHIVE") != -1){//comUtil.IsAuthorizedModule(dbOP,strUserId,"Data Archive")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../dataarchive/data_archive_index.htm" target="bottomFrame">Data 
		  Archive</a></font></strong></td>
	  </tr>
	  <%}%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><a href="../../lms" target="_top">Library</a></font></strong></td>
	  </tr>
	  <%if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"Home")){%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../my_home/my_home_index.htm" target="bottomFrame">My Home</a></font></strong></td>
	  </tr>
	  <%}%>
	
	<%if(strIsSMS.equals("1")){%>
	  <tr>
		<td height="25"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../sms/" target="bottomFrame">iSMS (SMS Integrated)</a></font></strong></td>
	  </tr>
	<%}%>
<%}//do not show this if used for only accounting.. %>
  <%//if(bolGrantAll || bolAlumni){%>
  <!--  <tr>
    <td height="25"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Alumni Center</font></strong></td>
  </tr>
<%//}if(bolGrantAll || bolMessageBoard){%>
  <tr>
    <td height="25"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Message Board </font> </strong></td>
  </tr>
<%//}if(bolGrantAll || bolSponsorship){%>
  <tr>
    <td height="25"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Sponsorship Program</font></strong></td>
  </tr>
<%//}if(bolGrantAll || bolAnnouncement){%>
  <tr>
    <td height="25"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Announcements</font></strong></td>
  </tr>-->
  <%//}%>
</table>
</body>
</html>
<%
if(dbOP != null) 
	dbOP.cleanUP();
%>