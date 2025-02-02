<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function FixRPError(strRPAction) {
	document.form_.rp_error_fix.value = strRPAction;
	this.SubmitOnce('form_');
}

function RemoveTuition() {
	document.form_.indexT.value = "0";
	this.SubmitOnce('form_');
}
function RemoveFeeName(strFeeCatg, strIndex) {
	if(strFeeCatg == 1) {//misc fee
		eval('document.form_.misc_'+strIndex+'.value = ""');
	}
	else {//other fee.
		eval('document.form_.others_'+strIndex+'.value = ""');
	}
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function AddFeeName()
{
	//if it is tuition fee, add in the tuition fee.
	if(document.form_.fee_catg.selectedIndex == 0) {
		document.form_.indexT.value = 1;
		document.form_.tuition_.value = "ALL";
	}
	else if(document.form_.fee_catg.selectedIndex == 1) {
		if(document.form_.fee_name.selectedIndex == 0)
			document.form_.indexM.value = "1";
		else
			document.form_.indexM.value = eval(document.form_.indexM.value) + 1;
		document.form_.misc_.value = document.form_.fee_name[document.form_.fee_name.selectedIndex].text;
	}
	else if(document.form_.fee_catg.selectedIndex == 2) {
		document.form_.indexO.value = eval(document.form_.indexO.value) + 1;
		document.form_.others_.value = document.form_.fee_name[document.form_.fee_name.selectedIndex].text;
	}
	
	ReloadPage();
}

//call this to print receivable projection.
/**
function PrintPg() {
	var pgLoc;
	if(document.form_.report_type.selectedIndex ==0) {//summary per course.
		pgLoc = "./rec_projection_print_percourse.jsp?";
	}
	else {//Detailed (per student)
		pgLoc = "./rec_projection_print_perstud.jsp?show_course="+
			escape(document.form_.show_course[document.form_.show_course.selectedIndex].value)+"&";	
	}
	pgLoc += "sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&semester="+
		document.form_.semester.value;
	//pop up now.
	if(document.form_.yr_level) {
		if(document.form_.yr_level.selectedIndex > 0) 
			pgLoc += "&yr_level="+document.form_.yr_level.selectedIndex;
	}
	//alert(pgLoc);
	var win=window.open(pgLoc);
	win.focus();

}**/
function PrintPgNew() {
	var strIsBasic = "";
	//alert();
	//alert();
	if(document.form_.is_basic && document.form_.is_basic.checked)
		strIsBasic = "&is_basic=1";
	var pgLoc;
	var strReportType = document.form_.report_type[document.form_.report_type.selectedIndex].value;
	if( strReportType == "0" || strReportType == "2") {//summary per course.
		pgLoc = "./rec_projection_print_percourse_new.jsp?";
		if(document.form_.group_yrlevel && document.form_.group_yrlevel.checked)
			pgLoc += "group_yrlevel=1&";
	}
	else {//Detailed (per student)
		if(document.form_.show_course)
			pgLoc = "./rec_projection_print_perstud_new.jsp?show_course="+
				escape(document.form_.show_course[document.form_.show_course.selectedIndex].value)+"&";	
		else
			pgLoc = "./rec_projection_print_perstud_new.jsp?show_course=0&";
	}
	pgLoc += "sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&semester="+
		document.form_.semester.value+"&report_type="+strReportType+strIsBasic;
	if(document.form_.use_map && document.form_.use_map.checked)
		pgLoc += "&use_map=1";
	pgLoc += "&font_size="+document.form_.font_size[document.form_.font_size.selectedIndex].value;
	//pop up now.
	
	if(document.form_.yr_level) {
		if(document.form_.yr_level.selectedIndex > 0) 
			pgLoc += "&yr_level="+document.form_.yr_level.selectedIndex;
	}
	if(document.form_.year_level) {
		if(document.form_.year_level.selectedIndex > 0) 
			pgLoc += "&year_level="+document.form_.year_level.selectedIndex;
	}
	//alert(pgLoc);

	var win=window.open(pgLoc);
	win.focus();

}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","rec_projection.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
boolean bolIsSuperUser = false;
if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
	bolIsSuperUser = true;
	
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(),
														"rec_projection.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
Vector vRetResult = new Vector();

EnrlReport.FeeExtraction FE = new EnrlReport.FeeExtraction();
Vector vCheckRPProcess = null;
if(WI.fillTextValue("sy_from").length() > 0) {
	vCheckRPProcess = FE.getRecProjNew(dbOP, request, true);
	if(vCheckRPProcess == null || ((String)vCheckRPProcess.elementAt(0)).compareTo("1") == 0) {
		strErrMsg = FE.getErrMsg();
	}
}


////////////// fix rp errors in db..////////////////
strTemp = WI.fillTextValue("rp_error_fix");
Vector vRPError = null;
if(strTemp.length() > 0) {
	vRPError = FE.checkRPDifference(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), Integer.parseInt(strTemp));
	if(vRPError == null) {
		if(strErrMsg == null)
			strErrMsg = FE.getErrMsg();
		else
			strErrMsg = strErrMsg + "<br>"+FE.getErrMsg();
	}
}

//show if list of ID is -> 
String strUserID = (String)request.getSession(false).getAttribute("userId");
if(strUserID == null)
	strUserID = "";
else
	strUserID = strUserID.toLowerCase();

boolean bolAllowedToInitialize = false;
String strSQLQuery = "select prop_val from read_property_file where prop_name = 'ID_ALLOWED_INITILIZE'";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null) {
	Vector vAllowedList = CommonUtil.convertCSVToVector(strSQLQuery.toLowerCase());
	if(vAllowedList != null && vAllowedList.indexOf(strUserID) > -1)
		bolAllowedToInitialize = true;
}

//if(WI.fillTextValue("sy_from").length() > 0)
//	FE.getRecProjPerCourseNew(dbOP, request);
	//FE.getRecProj(dbOP, request);

int iIndexM = Integer.parseInt(WI.getStrValue(WI.fillTextValue("indexM"),"0"));

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<form name="form_" action="./rec_projection.jsp" method="post">

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::ACCOUNTS RECEIVABLE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><b>
	  <%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
<%
if(false){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="27%">
<%
strTemp = WI.fillTextValue("load_save_report");
if(strTemp.compareTo("0") ==0)
	strTemp = "checked";
else
	strTemp = "";
%>
	  <input type="radio" name="load_save_report" value="0" <%=strTemp%> onClick="ReloadPage();">
        Load Save Report Layout</td>
      <td width="70%">
<%//default value;
if(strTemp.length() ==0)
	strTemp = "checked";
else
	strTemp = "";
%>	  <input type="radio" name="load_save_report" value="1" <%=strTemp%> onClick="ReloadPage();">
        Create New Report Layout</td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%}//do not show now.
%>  
  <table width="100%" border="0" cellpadding="0"  cellspacing="0" bgcolor="#FFFFFF">
<%if(!strSchCode.startsWith("FATIMA")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td style="font-size:11px; font-weight:bold; color:#0000FF">
<%
strTemp = WI.fillTextValue("is_basic");
if(strTemp.length() > 0) 
	strTemp = " checked";
%>
		  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="document.form_.submit();"> AR  for Grade School </td>
      <td>&nbsp;</td>
    </tr>
<%}%>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="10%">School Year</td>
      <td width="33%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
      <td width="54%"><font size="1"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a> 
        click to refresh the page.</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td>Display report : 
        <select name="report_type" onChange="ReloadPage();">
          <option value="0">Summary (per course)</option>
          <%
strTemp = WI.fillTextValue("report_type");
if(strTemp.compareTo("1") == 0 ){%>
          <option value="1" selected>Detailed (per student)</option>
<%}else if(true){%>
          <option value="1">Detailed (per student)</option>
<%}if(strTemp.compareTo("2") == 0) {%>
          <option value="2" selected>Summary (per college)</option>
<%}else{%>
          <option value="2">Summary (per college)</option>
<%}%>
        </select>
		
<%
if(WI.fillTextValue("report_type").compareTo("1") == 0) {
if(WI.fillTextValue("is_basic").length() > 0){%>
	<br><select name="year_level" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10px;font-weight:bold;">
        <option value=""></option>
		<%=dbOP.loadCombo("g_level","LEVEL_NAME"," from BED_LEVEL_INFO order by g_level",WI.fillTextValue("year_level"),false)%> 
	</select>
<%}else{%>
	<br><select name="show_course" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10px;font-weight:bold;">
<%if(strSchCode.startsWith("CDD")){%>
        <option value=""></option>
<%}%>
	<%=dbOP.loadCombo("course_index","course_code+' ('+course_name+')'",
		  	" from course_offered where is_del = 0 and IS_OFFERED=1 and IS_VISIBLE=1 order by course_code",
			WI.fillTextValue("show_course"), false)%>
	</select>
	<br>
	Year Level : 
	<select name="yr_level">
		<option value=""></option>
		<option value="1">1st Yr</option>
		<option value="2">2nd Yr</option>
		<option value="3">3rd Yr</option>
		<option value="4">4th Yr</option>
		<option value="5">5th Yr</option>
		<option value="6">6th Yr</option>
		
	</select>	
<%}
}%>
		
		
	  </td>
    </tr>
<%
//if(strUserID.startsWith("biswa") || strUserID.compareTo("1770") == 0 || strUserID.startsWith("jan ")){
if(bolIsSuperUser || bolAllowedToInitialize){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><font color="#0000FF" size="1"><strong>
	  <%if(bolIsSuperUser){%>
	  	<input type="checkbox" value="1" name="force_compute"> Re calculate AR &nbsp;&nbsp;&nbsp;&nbsp; 
       <%}%>
		
		<input type="checkbox" value="1" name="force_clean"> 
        Initialize AR Report (this will re-compute fee) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		</strong></font>
	  </td>
    </tr>
    <%}
//check here if rp mapping is done. 
strTemp = "select misc_fee_index from fa_misc_fee where not exists (select * from  FA_FEE_HISTORY_RP_MAP where FEE_NAME_ORIG = fee_name) and is_del=0";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp == null) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><font color="#0000FF" size="1"><strong><input type="checkbox" value="1" name="use_map"> Include AR Mapped Fee.</strong></font></td>
    </tr>
<%}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:10px; font-weight:bold; color:#FF0000"><u>Note : AR Mapping is not yet complete. Please map all fees to be able to select option to print with Mapped Fee.</u></td>
    </tr>
<%}if(false && WI.fillTextValue("load_save_report").compareTo("0") == 0){%>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td>Report Layout : 
        <select name="select3">
        </select></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="2"><hr size="1"></td>
    </tr>
  </table>
 <%
 //in receivable projection, i am showing all info for now.
 if(false){%>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom">Fee Category</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="23%" height="25" valign="middle"> <select name="fee_catg" onChange="ReloadPage();">
          <option value="0">Tuition Fee</option>
          <%
strTemp = WI.fillTextValue("fee_catg");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Miscellneous Fees</option>
          <%}else{%>
          <option value="1">Miscellneous Fees</option>
          <%}if(strTemp.compareTo("2") == 0){%>
<!--          <option value="2" selected>Other School Fees</option> This option is removed .. -->
          <%}else{%>
<!--          <option value="2">Other School Fees</option>		-->
          <%}%>
        </select></td>
      <td width="9%" height="25" valign="middle"><select name="fee_name">
	  <option value="0">ALL</option>
          <%
if(strTemp.compareTo("1") ==0){//misc fee%>
          <%=dbOP.loadCombo("distinct fee_name","fee_name",
		  	" from fa_misc_fee join fa_schyr on (fa_schyr.sy_index = fa_misc_fee.sy_index) where IS_DEL=0 and is_valid=1 "+
			"and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
			" and (semester is null or semester = "+
			WI.fillTextValue("semester")+") order by fa_misc_fee.fee_name",WI.fillTextValue("fee_name"), false)%> 
<%}else if(strTemp.compareTo("2") ==0){//other sch fee %>
          <%=dbOP.loadCombo("distinct fee_name","fee_name",
		  " from FA_OTH_SCH_FEE join fa_schyr on (fa_schyr.sy_index = FA_OTH_SCH_FEE.sy_index) where IS_DEL=0 and is_valid=1 "+
			"and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
			" order by FA_OTH_SCH_FEE.fee_name",WI.fillTextValue("fee_name"), false)%> 
<%}%>
        </select>
      </td>
      <td width="65%" height="25" valign="middle"><a href="javascript:AddFeeName();"><img src="../../../images/add.gif"  border="0"></a></td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%}%>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(false){%>    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">
        Report Name
        </td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>     
	<tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="31%" height="25">
<input name="report_name" type="text" size="32" value="<%=WI.fillTextValue("report_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <%}%> </td>
      <td width="31%" height="25"> <%if(false){%> <font size="1"><a href="javascript:SaveReport();"><img src="../../../images/save.gif" border="0"></a>click 
      to save report layout</font>  </td>
      <td height="25" colspan="3" align="right">&nbsp;</td>
    </tr>
<%}%>    
	<tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td style="font-size:11px;">
	  Font size of Printout: 
        <select name="font_size">
          <option value="8">8 &nbsp;px</option>
<%
strTemp = request.getParameter("font_size");
if(strTemp == null)
	strTemp = "11";
if(strTemp.compareTo("9") == 0) {%>
          <option value="9" selected>9 px</option>
<%}else{%>
          <option value="9">9 &nbsp;px</option>
<%}if(strTemp.compareTo("10") == 0) {%>
          <option value="10" selected>10 px</option>
<%}else{%>
          <option value="10">10 px</option>
<%}if(strTemp.compareTo("11") == 0) {%>
          <option value="11" selected>11 px</option>
<%}else{%>
          <option value="11">11 px</option>
<%}if(strTemp.compareTo("12") == 0) {%>
          <option value="12" selected>12 px</option>
<%}else{%>
          <option value="12">12 px</option>
<%}if(strTemp.compareTo("14") == 0) {%>
          <option value="14" selected>14 px</option>
<%}else{%>
          <option value="14">14 px</option>
<%}%>
        </select>
	  </td>
      <td colspan="3" align="right">
	  <%if(strErrMsg == null && WI.fillTextValue("sy_from").length() > 0) {%>
	  <input type="checkbox" name="group_yrlevel" value="checked" <%=WI.fillTextValue("group_yrlevel")%>> 
	  <font size="1">Print Per YR Level</font>
	  
        <a href="javascript:PrintPgNew();"><img src="../../../images/print.gif" border="0"></a> <font size="1">click to print </font>
        <%}%></td>
    </tr>
    <tr> 
      <td height="25" colspan="6"><hr color="blue" size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:FixRPError(1);"><img src="../../../images/verify.gif" border="0" height="25" width="70"></a><font size="1">Click 
        to check Accounts Receivable Error</font></td>
      <td width="21%" height="25">&nbsp;</td>
      <td width="7%" height="25">&nbsp;</td>
      <td width="7%" height="25">&nbsp;</td>
    </tr>
  </table>
<%
if(vRPError != null && vRPError.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EEEEEE"> 
      <td height="25" colspan="2" class="thinborder">&nbsp;&nbsp;&nbsp;<strong><font color="#CC0000">NOTE 
        ::: Error found. Check errors first before removing error from Accounts Receivable. CLICK TO REMOVE ERROUNOUS ENTRIES </font></strong> <a href="javascript:FixRPError(0);"><img src="../../../images/delete.gif" border="1" height="22" width="55">. 
        &nbsp;&nbsp;&nbsp;&nbsp;<strong>TOTAL STUDENT : <%=(vRPError.size() - 1)/3%></strong></td>
    </tr>
    <tr bgcolor="#FFFFAF"> 
      <td width="63%" height="25" align="center" class="thinborder"><font size="1"><strong>ID 
        NUMBER (NAME) </strong></font></td>
      <td width="26%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
    </tr>
    <%
for(int i = 1; i < vRPError.size(); i += 3){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRPError.elementAt(i) + " ("+(String)vRPError.elementAt(i + 1)+")"%></td>
      <td class="thinborder">&nbsp;<%=(String)vRPError.elementAt(i + 2)%></td>
    </tr>
    <%}%>
    <tr bgcolor="#FF9999"> 
      <td height="25" align="right" class="thinborder"><strong>TOTAL : <%=(String)vRPError.elementAt(0)%></strong></td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" align="center" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
  </table>
  
  
  
  
<%}
if(false){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#808080">
    <tr bgcolor="#CCCCCC"> 
      <td height="25" align="center" colspan="3">LIST OF SELECTED FEE TO BE DISPLAYED</td>
    </tr>
    <tr bgcolor="#FFFFAF"> 
      <td width="21%" height="25" align="center"><font size="1"><strong>FEE CATEGORY</strong></font></td>
      <td width="68%" align="center"><font size="1"><strong>FEE NAME</strong></font></td>
      <td width="11%" align="center"><font size="1"><strong>REMOVE</strong></font></td>
    </tr>
<%
int iIndex = 0;
iIndex = Integer.parseInt(WI.getStrValue(WI.fillTextValue("indexT"),"0"));
for(int i = 0 ; i < iIndex; ++i){%>
    <tr bgcolor="#FFFFFF">
      <td height="25" align="center">Tuition Fee</td>
      <td align="center">ALL</td>
      <td align="center"><a href="javascript:RemoveTuition();"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}
if(WI.fillTextValue("misc_").length()> 0)
	vRetResult.addElement(WI.fillTextValue("misc_"));
if(WI.fillTextValue("misc_").compareTo("ALL") != 0 ) {
	for(int i = 0 ; i < iIndexM; ++i) {
		if(WI.fillTextValue("misc_"+i).length() == 0)
			continue;
		if(vRetResult.indexOf(WI.fillTextValue("misc_"+i)) != -1)
			continue;
		vRetResult.addElement(WI.fillTextValue("misc_"+i));
		if(WI.fillTextValue("misc_"+i).compareTo("ALL") == 0) {
			vRetResult.removeAllElements();
			vRetResult.addElement("ALL");
			break;
		}
	}
}//end of if condition.
iIndexM = 0;
for(int i = 0 ; i < vRetResult.size(); ++i, ++iIndexM){%>
    <tr bgcolor="#FFFFFF">
      <td height="25" align="center">
	  <%if(i == 0){%>Misc Fee <%}%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i)%>
	  <input type="hidden" name="misc_<%=i%>" value="<%=(String)vRetResult.elementAt(i)%>"></td>
      <td align="center"><a href="javascript:RemoveFeeName(1,<%=i%>);"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}
vRetResult.removeAllElements();
iIndex = Integer.parseInt(WI.getStrValue(WI.fillTextValue("indexO"),"0"));
if(WI.fillTextValue("others_").length()> 0)
	vRetResult.addElement(WI.fillTextValue("others_"));
if(WI.fillTextValue("others_").compareTo("ALL") != 0 )
	for(int i = 0 ; i < iIndex; ++i) {
		if(WI.fillTextValue("others_"+i).length() == 0)
			continue;
		if(vRetResult.indexOf(WI.fillTextValue("others_"+i)) != -1)
			continue;
		vRetResult.addElement(WI.fillTextValue("others_"+i));
		if(WI.fillTextValue("others_"+i).compareTo("ALL") == 0) {
			vRetResult.removeAllElements();
			vRetResult.addElement("ALL");
			break;
		}
	}
for(int i = 0 ; i < vRetResult.size(); ++i){%>
    <tr bgcolor="#FFFFFF">
      <td height="25" align="center">
	  <%if(i == 0){%>Other School Fee <%}%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i)%>
	  <input type="hidden" name="others_<%=i%>" value="<%=(String)vRetResult.elementAt(i)%>"></td>
      <td align="center"><a href="javascript:RemoveFeeName(2,<%=i%>);"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>


  </table>
 <%}//do not show this table for now -- if(false)
 %>
 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="tuition_">
<input type="hidden" name="misc_">
<input type="hidden" name="others_">
<input type="hidden" name="indexT" value="<%=WI.getStrValue(WI.fillTextValue("indexT"),"0")%>">
<input type="hidden" name="indexM" value="<%=iIndexM%>">
<input type="hidden" name="indexO" value="<%=WI.getStrValue(WI.fillTextValue("indexO"),"0")%>">

<input type="hidden" name="rp_error_fix">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>