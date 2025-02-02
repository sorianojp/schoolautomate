<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn, hr.HRInfoLeave, 
									hr.HRNotification, java.util.Calendar, java.util.Date"
			   buffer="16kb" %>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolMyHome = false;	
	if (WI.fillTextValue("my_home").equals("1")) {
		bolMyHome = true;
		strColorScheme = CommonUtil.getColorScheme(9);
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
.style1 {
	color: #FF0000;
	font-weight: bold;
}
</style>
</head>
<script src="../../../jscript/date-picker.js"></script>
<script src="../../../jscript/td.js"></script>
<script src="../../../jscript/common.js"></script>
<script src="../../../Ajax/ajax.js"></script>
<script language="javascript">

function AddRecord(){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.page_action.value="1";
	document.form_.print_list.value = "";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function EditRecord(){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.page_action.value="2";
	document.form_.print_list.value = "";
	document.form_.submit();
}

function PrepareToEdit(strInfoIndex){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value ="1";
	document.form_.page_action.value = "3";
	document.form_.print_list.value = "";	
	document.form_.submit();
}

function DeleteRecord(index){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.page_action.value="0";
	document.form_.info_index.value = index;
	document.form_.prepareToEdit.value ="";
	document.form_.print_list.value = "";
	document.form_.submit();
}

function ReloadParentWnd() {
	document.form_.print_list.value = "";
	if(document.form_.donot_call_close_wnd.value.length > 0)
		return;

	if(document.form_.close_wnd_called.value == "0") 
		window.opener.ReloadPage();
}

function CancelRecord(strEmpID){
	document.form_.donot_call_close_wnd.value = "1";
	location = "./leave_apply.jsp?emp_id="+strEmpID+"&sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+"&semester="+document.form_.semester.value+"&my_home="+
	document.form_.my_home.value;
}

function FocusID() {
	document.form_.emp_id.focus();
}

function OpenSearch() {
	document.form_.donot_call_close_wnd.value = "1";
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
	win.focus();
}

function ChangeLeave(){
	document.form_.donot_call_close_wnd.value = "1";
	if(document.form_.cur_leave_text.value.toUpperCase().indexOf("MATERNITY") != -1){
		document.form_.cur_leave_text.value = document.form_.avail_leave_index[document.form_.avail_leave_index.selectedIndex].text;
		if(document.form_.cur_leave_text.value.toUpperCase().indexOf("MATERNITY") == -1){
			document.form_.submit();
		}
	}else{
		document.form_.cur_leave_text.value = document.form_.avail_leave_index[document.form_.avail_leave_index.selectedIndex].text;
		if(document.form_.cur_leave_text.value.toUpperCase().indexOf("MATERNITY") != -1){
			document.form_.submit();
		}
	}
}

function UpdateReqStatus(){
	if (document.form_.head_approved && 
		document.form_.vp_approved && 
		document.form_.pres_approved && 
		document.form_.leave_appl_status) {
		
		
		if (document.form_.head_approved.selectedIndex == 2 
			|| document.form_.vp_approved.selectedIndex == 2
			|| document.form_.pres_approved.selectedIndex == 2){	
				
			document.form_.leave_appl_status.selectedIndex = 4; // disapproved
			
		} else if ((document.form_.head_approved.selectedIndex == 3 
					|| document.form_.head_approved.selectedIndex == 1) && 
					(document.form_.vp_approved.selectedIndex == 0 
					|| document.form_.vp_approved.selectedIndex == 1) && 
					(document.form_.pres_approved.selectedIndex == 0 
					|| document.form_.pres_approved.selectedIndex == 1)){
			
			document.form_.leave_appl_status.selectedIndex = 3; // approved

		}else if (document.form_.head_approved.selectedIndex == 0){
			document.form_.leave_appl_status.selectedIndex = 0; // pending
		}else if (document.form_.vp_approved.selectedIndex == 3) {
			document.form_.leave_appl_status.selectedIndex = 1; // pending
		}else if (document.form_.pres_approved.selectedIndex == 3) {
			document.form_.leave_appl_status.selectedIndex = 2; // pending
		}
		
		
		if (document.form_.leave_appl_status.selectedIndex == 3){
			document.form_.is_final.checked =true;
			document.form_.actual_days.value = document.form_.days_applied.value;
			document.form_.actual_unit.value = document.form_.unit_applied.value;			
			//document.form_.actual_hours.value = document.form_.hours_applied.value;	
		}else{
			document.form_.is_final.checked =false;
			document.form_.actual_days.value = "";
			//document.form_.actual_hours.value = "";
		}
	}
	
}

function ViewPrintDetails(strInfoIndex,strEmpID, strSYFrom, strSYTo, strSemester, strMyHome){
	document.form_.donot_call_close_wnd.value = "1";
	var pgLoc = "./leave_apply_print.jsp?info_index="+strInfoIndex+
			"&emp_id=" + escape(strEmpID) + "&sy_from=" + strSYFrom+
			"&sy_to="+strSYTo+"&semester="+strSemester+
			"&format_date=6&my_home="+strMyHome;
	var win=window.open(pgLoc,"ViewPrintLeave",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
	win.focus();
}

function PrintList(){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.print_list.value= "1";
	document.form_.submit();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function ReloadPage(){
	document.form_.submit();
}


function ToggleDateTime(){
	if(!document.form_.onedate)
		return;

	if(document.form_.onedate.checked){
		document.form_.ldateto.disabled = true;
		document.form_.unit_applied.value = "1";
		
		document.form_.hrfrom.disabled = false;
		document.form_.fmin.disabled = false;
		document.form_.hrto.disabled = false;
		document.form_.minto.disabled = false;
 	}else{
		document.form_.ldateto.disabled = false;
		document.form_.unit_applied.value = "0";	
		
		document.form_.hrfrom.disabled = true;
		document.form_.fmin.disabled = true;
		document.form_.hrto.disabled = true;
		document.form_.minto.disabled = true;
	}
	ComputeDuration();
}

function ComputeDuration() {
	var strDateFr = document.form_.ldatefrom.value;
	var strDateTo = document.form_.ldateto.value;
	if(document.form_.ldateto.disabled)
		strDateTo = "";
	
	var strHrFr = document.form_.hrfrom.value;
	if(document.form_.hrfrom.disabled)
		strHrFr = "";
			
	var strMinFr = document.form_.fmin.value;
	var strAmPmFr = document.form_.frAMPM.value;
	
	var strHrTo = document.form_.hrto.value;
	if(document.form_.hrto.disabled)
		strHrTo = "";

	var strMinTo = document.form_.minto.value;
	var strAmPmTo = document.form_.toAMPM.value;
	
	var strOrig = document.form_.days_applied.value;
	var strID = document.form_.emp_id.value;

	var objCOAInput = document.form_.days_applied;
	this.InitXmlHttpObject(objCOAInput, 1);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=3001&date_fr="+strDateFr+
						   "&date_to="+strDateTo+"&hr_fr="+strHrFr+"&min_fr="+strMinFr+
							 "&ampm_fr="+strAmPmFr+"&hr_to="+strHrTo+"&min_to="+strMinTo+
							 "&ampm_to="+strAmPmTo+"&orig_val="+strOrig+"&emp_id="+strID;
	
	this.processRequest(strURL);
}
</script>
<%
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	DBOperation dbOP = null;	
	
	if (WI.fillTextValue("print_list").equals("1")) {%> 
		<jsp:forward page="leave_apply_print_list.jsp" />		
	<% return;}
	
	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	boolean bolUseYearly = true;
	boolean bolAllowEditFinal = false;// check if we will allow editing of approved leaves...
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Leave Application","leave_apply.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		bolUseYearly = (readPropFile.getImageFileExtn("LEAVE_SCHEDULER","0")).equals("0");
		bolAllowEditFinal = (readPropFile.getImageFileExtn("EDIT_APPROVED_LEAVE","0")).equals("1");
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","LEAVE APPLICATION",request.getRemoteAddr(),
														"leave_apply.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");

if (strTemp != null){
	if(bolMyHome){//for my home, allow applying leave.
		//if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		//else 
		//	iAccessLevel = 1;
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//

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
Vector vRetResult = null;
Vector vEmpRec = null;
Vector vEditResult = null;
boolean bNoError = false;
boolean bolShowEdit = false;
boolean bolViewOnly = WI.fillTextValue("view_only").equals("1");
boolean bolIsSupervisor = false;
String strFrom = null;
String strTo = null;

HRNotification hrNot = new HRNotification();
bolIsSupervisor = hrNot.isImmediateSupervisor(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

HRInfoLeave hrPx = new HRInfoLeave();

int iAction =  -1;

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}
boolean bolIsAllowedToProcess = false;
if(strTemp.equals((String)request.getSession(false).getAttribute("userId")) || !bolMyHome)
	bolIsAllowedToProcess = true;

if(!bolIsAllowedToProcess){
	bolIsAllowedToProcess = hrPx.isAllowedToProcessID(dbOP, request, strTemp);
}
 
if (strTemp.length()> 0 && bolIsAllowedToProcess){
	enrollment.Authentication authentication = new enrollment.Authentication();
  vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
}
if(!bolIsAllowedToProcess)
	strErrMsg = "Not Allowed to process for employee";

//if Emp ID is empty. I have to get it from session.getAttribute("encoding_in_progress_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else
	request.getSession(false).setAttribute("encoding_in_progress_id", strTemp);
	
strTemp = WI.getStrValue(strTemp);

String strWasFinalized = "";
hrPx.FixLeaveIndexing(dbOP, request);
hrPx.moveHourlyToDailyLeave(dbOP);

if (WI.fillTextValue("page_action").equals("0")){
	if (hrPx.operateOnLeaveApplication(dbOP, request,0) != null)
		strErrMsg = " Leave application removed successfully";
	else
		strErrMsg = hrPx.getErrMsg();
}else if (WI.fillTextValue("page_action").equals("1")){
	if (hrPx.operateOnLeaveApplication(dbOP, request,1) != null)
		strErrMsg = " Leave application saved successfully";
	else
		strErrMsg = hrPx.getErrMsg();
}else if (WI.fillTextValue("page_action").equals("2")){
	if (hrPx.operateOnLeaveApplication(dbOP, request,2) != null){
		strErrMsg = " Leave application updated successfully";
		strPrepareToEdit = "0";
	}else
		strErrMsg = hrPx.getErrMsg();
}

if (strPrepareToEdit.equals("1")){
	vEditResult = hrPx.operateOnLeaveApplication(dbOP,request, 3);
	if (vEditResult == null)
		strErrMsg = hrPx.getErrMsg();
}

//Vector vAllowedLeave = hrPx.getAllowedLeave(dbOP, request);
Vector vAllowedLeave = hrPx.getAvailableLeaveForSemNew(dbOP, request);
//System.out.println("vAllowedLeave " + vAllowedLeave);

vRetResult = hrPx.operateOnLeaveApplication(dbOP, request, 4);

String[] astrConvertAMPM={" AM"," PM"};
String[] astrCurrentStatus ={"Disapproved", "Approved", "Pending/On-process",
							 "Requires Approval of Vice-President", 
							 "Requires Approval of President"};
							 
String[] astrCurrentRemarks ={"Charge to 1st sem SL credits",
				"Charge to 2nd sem SL credits",
				"Charge to Summer SL credits",
				"Charge to 1st sem & 2nd sem SL credits",
				"Charge to 1st sem & summer SL credits",
				"Charge to 1st, 2nd  & summer SL credits",
				"Charge to 2nd sem & summer SL credits",
				"Charge to Vacation Leave Credits",
				"Charge to Paternity Leave",
				"Charge to Bereavement Leave",
				"Charge to Incentive Leave",
				"Excused absence due to calamity",
				"Faculty not attending class anymore",
				"W/ make-up class",
				"Leave w/ pay",
				"No sick leave credits for summer",
				"Official Release Time",
				"Approved for Offsetting",
				"Extra load – SD",
				"Part-time – SD",
				"Substitute – SD",
				"Tardiness – SD",
				"Undertime – SD",
				"Tardiness & Undertime – SD",
				"AWOL – SD",
				"Incentive pay/hr – SD",
				"FT-Prob <6 months – SD",
				"Depleted SL benefit – SD",
				"Filed Late – SD",
				"Leave w/o pay – SD",
				"Leave c/o SSS – SD",
				"Casual – SD",
				"Work Resumption"};
				
String strCurLeaveText = "";

if (vEditResult != null && vEditResult.size() > 0)
	strCurLeaveText = WI.getStrValue((String)vEditResult.elementAt(42),"Leave Without Pay");
else
	strCurLeaveText = WI.fillTextValue("cur_leave_text");

boolean bolNewIDEntered = false;
String strSem = null;
Calendar calTemp = Calendar.getInstance();
Date odTemp = null;
if(!strTemp.equals(WI.fillTextValue("prev_id")))
	bolNewIDEntered = true;

//System.out.println(bolNewIDEntered);
%>
<body bgcolor="#663300" class="bgDynamic" onUnload="ReloadParentWnd();">
<form action="./leave_apply.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4" align="center"  bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" size="2" ><strong>:::: 
      APPLY/UPDATE REQUEST(S) PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
    <% if (!bolMyHome || bolIsSupervisor){%>
    <tr> 
      <td width="16%" height="25">&nbsp;&nbsp;Employee ID : 
	  <%if ((strPrepareToEdit.equals("1") && vEmpRec !=null && vEmpRec.size() > 0) || bolViewOnly ){
			strTemp2 = "readonly = 'yes'";
		}else
			strTemp2 = "";
	  %></td>
      <td width="16%"><input name="emp_id" <%=strTemp2%> type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>" size="16" maxlength="32" onKeyUp="AjaxMapName(1);"></td>
      <td width="5%">
	  <% if (!bolViewOnly){%> 
	  <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>
	  <%}else{%>&nbsp;<%}%>	  </td>
      <td width="63%"><input type="image" src="../../../images/form_proceed.gif" border="0"> <label id="coa_info"></label>      </td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;Employee ID : <font size="3" color="#FF0000"><strong><%=WI.getStrValue(strTemp)%></strong></font> <input name="emp_id" type= "hidden" class="textbox" value="<%=WI.getStrValue(strTemp)%>">
        &nbsp;&nbsp;&nbsp;&nbsp; 
        <input name="image" type="image" src="../../../images/form_proceed.gif" border="0"></td>
    </tr>
    <%}%>
		<%if(bolUseYearly){%>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <%if(bolIsSchool){%>SY / SEM<%}else{%>Year<%}%>&nbsp;: 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) {
	if(bolIsSchool)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	else
		strTemp = WI.getTodaysDate(12);	
}

%> <input name="sy_from" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp)%>" size="4" maxlength="4" onKeyUp="DisplaySYTo('form_', 'sy_from', 'sy_to')"> 

	<%
	strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%>

<%if(bolIsSchool){%>
        -&nbsp; <input name="sy_to" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp)%>" size="4" maxlength="4" readonly="yes"> 
        &nbsp;&nbsp; 
		<select name="semester">
          <option value="1"> 1st Sem</option>
	<%
	strTemp = WI.fillTextValue("semester");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
		if (strTemp.equals("2")) {
	%>
          <option value="2" selected> 2nd Sem</option>
          <%}else{%>
          <option value="2"> 2nd Sem</option>
          <%} if ( strTemp.equals("3")){%>
          <option value="3" selected> 3rd Sem</option>
          <%}else{%>
          <option value="3"> 3rd Sem</option>
          <%}if ( strTemp.equals("0")){%>
          <option value="0" selected> Summer</option>
          <%}else{%>
          <option value="0"> Summer</option>
          <%}%>
        </select> 
<%}else{//for companies.%>
<input type="hidden" name="sy_to" value="<%=strTemp%>">
<input type="hidden" name="semester" value="1">
<%}%>	  </td>
    </tr>
		<%}// end if (bolUseYearly)
			else{%>
		<%
		strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() == 0) {
			if(bolIsSchool)
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
			else
				strTemp = WI.getTodaysDate(12);
		}
		%>
		<input name="sy_from" type= "hidden" class="textbox" value="<%=WI.getStrValue(strTemp)%>">
		<input type="hidden" name="sy_to" value="<%=strTemp%>">
		<input type="hidden" name="semester" value="1">
		<%}%>
<!--
    <tr> 
      <td height="34" colspan="3"><strong><font color="#FF0000" size="2">&nbsp;&nbsp;NOTE 
        : Leave Request is invalid, unless, an approved application printout is 
        filed personally in HR Office. </font></strong></td>
    </tr>
-->
  </table>
<% 
if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0 && WI.fillTextValue("sy_from").length() != 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="100%" height="25">
	 <% if (!bolViewOnly) {%> 
	  <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
	 <%}%> 
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%> <%=strTemp%> <br> <br> <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%> <br> <strong><%=strTemp%></strong><br> <font size="1"><%=strTemp2%></font><br> <font size="1"><%=strTemp3%></font><br> </td>
          </tr>
        </table>
<% if(bolViewOnly){%>
<input type="hidden" name="avail_leave_index" value="<%=WI.fillTextValue("avail_leave_index")%>">
<%}else{%> 
        <br> 
        <table bgcolor="#FFFFFF" width="95%" border="0" cellspacing="0" cellpadding="0">
          <tr bgcolor="#F4F4FF"> 
            <td width="2%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
            <td colspan="2" ><strong><font size="2">Available Leave</font></strong></td>
            <td width="35%"><strong><font size="2">Apply for</font></strong> </td>
            <td width="23%">&nbsp;<!--<strong><font size="2">Current Status</font></strong>--></td>
          </tr>
          <tr bgcolor="#F4F4FF"> 
            <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
            <td width="1%">&nbsp;</td>
            <td width="39%" valign="top"> 
					<% if (vAllowedLeave != null && vAllowedLeave.size() > 0) {
					String[] astrSemester = {"Summer", "1st", "2nd","3rd","4th","Whole Yr"};
					%> 
					<table width="90%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
					<% for(int i = 0 ; i < vAllowedLeave.size(); i+=6) {%>
						<tr> 
							<td width="60%" class="thinborder">&nbsp;&nbsp;<strong>
							<%
								strSem = WI.getStrValue((String)vAllowedLeave.elementAt(i+1),"5");
							%>
							<%=astrSemester[Integer.parseInt(strSem)]%>
							</strong>(<%=(String)vAllowedLeave.elementAt(i+4)%>)
							</td>
							<%
								strTemp = (String)vAllowedLeave.elementAt(i+5);
								if(strTemp.equals("5"))
									strTemp = "hour(s)";
								else
									strTemp = "day(s)";
							%>
							<td width="40%" height="25" align="right" class="thinborder"><strong><%=(String)vAllowedLeave.elementAt(i+2)%> <%=strTemp%>&nbsp;</strong></td>
						 </tr>
					<%}%>
					</table>
              <%}else{%> 
				<font size="2" color="#FF0000">Employee does not have any valid leave benefit</font>
			  <%}%>			  
		    </td>
            <td valign="top">
<%
	if(vEditResult != null)
		strTemp	= (String)vEditResult.elementAt(2);
	else
		strTemp = WI.fillTextValue("avail_leave_index");
%>
              <select name="avail_leave_index" onChange="ChangeLeave()">
                <option value="0"> Leave without Pay </option>
		<% 
		if (vAllowedLeave != null && vAllowedLeave.size() > 0){
		
		for (int i= 0; i < vAllowedLeave.size(); i+=6){
  		  if(vAllowedLeave.elementAt(i+2) != null && Double.parseDouble((String)vAllowedLeave.elementAt(i+2)) <.01d){
 			  if (vEditResult == null || 
			  	!((String)vEditResult.elementAt(2)).equals((String)vAllowedLeave.elementAt(i)))
				continue;
		   }
			 
			 if (((String)vAllowedLeave.elementAt(i)).equals(strTemp)){%>
				<option selected value="<%=(String)vAllowedLeave.elementAt(i)%>">
				<%//=(String)vAllowedLeave.elementAt(i)%><%=(String)vAllowedLeave.elementAt(i+4)%></option>
			<%}else{%>
				<option value="<%=(String)vAllowedLeave.elementAt(i)%>"> 
				<%//=(String)vAllowedLeave.elementAt(i)%><%=(String)vAllowedLeave.elementAt(i+4)%></option>
			<%}
	} // end for loop 

 } // vaAllowedLeave  != null %>

              </select>
							<input type="hidden" name="old_leave_type" value="<%=strTemp%>">
              <br>
              <br>
		    </td>
            <td valign="top">&nbsp;</td>
          </tr>
          <tr bgcolor="#F4F4FF"> 
            <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td valign="top">&nbsp;</td>
            <td valign="top">&nbsp;</td>
          </tr>
        </table>
        <% if (strCurLeaveText.toUpperCase().indexOf("MATERNITY") != -1) {  %> <table width="95%" border="0"  cellpadding="0" cellspacing="0">
          <tr> 
            <td>&nbsp;</td>
            <td colspan="3" bgcolor="#B9B9DD"><table width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr> 
                  <td width="24%" >&nbsp;Present No . of children :</td>
                  <td width="74%" colspan="2"><strong> <%=dbOP.mapOneToOther("HR_INFO_SP_CHILD", "user_index",(String)vEmpRec.elementAt(0), "count(*)", 
			" and relation_index = 1 and is_del =0")%></strong></td>
                </tr>
                <tr> 
                  <td >&nbsp;No. of Previous Deliveries: </td>
                  <td colspan="2"><%=dbOP.mapOneToOther("HR_INFO_SP_CHILD", "user_index",(String)vEmpRec.elementAt(0), "count(*)", " and relation_index = 1 and is_del =0")%></td>
                </tr>
              </table></td>
          </tr>
          <tr> 
            <td width="2%">&nbsp;</td>
            <td bgcolor="#B9B9DD">&nbsp;</td>
            <td bgcolor="#B9B9DD">&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td bgcolor="#B9B9DD">&nbsp;Expected date of delivery : <br> <font color="#000000"> 
              &nbsp; 
<%	if (vEditResult != null) 
		strTemp = WI.getStrValue((String)vRetResult.elementAt(7));
	else
		strTemp = WI.fillTextValue("expected_date");
%>
              <input name="expected_date" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','expected_date','/')" 
		  value ="<%=strTemp%>" size="10" maxlength="10" 
		  onKeyUp="AllowOnlyIntegerExtn('form_','expected_date','/')">
              <a href="javascript:show_calendar('form_.expected_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
              <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
            <td width="65%" bgcolor="#B9B9DD">Start date of two(2) weeks pre-delivery 
              leave of absence :<br> &nbsp; 
<%	if (vEditResult != null) 
		strTemp = WI.getStrValue((String)vRetResult.elementAt(8));
	else
		strTemp = WI.fillTextValue("pre_delivery");
%> <input name="pre_delivery" type= "text"  class="textbox" 
		   onFocus="style.backgroundColor='#D3EBFF'" 
		   onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','pre_delivery','/')" 
		   onKeyUp="AllowOnlyIntegerExtn('form_','pre_delivery','/')" value = "<%=strTemp%>" size="10" maxlength="10"> 
              <a href="javascript:show_calendar('form_.pre_delivery');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td colspan="3" bgcolor="#B9B9DD">&nbsp;</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td colspan="3" bgcolor="#B9B9DD">&nbsp;Number of days of maternity 
              leave : 
              <%
		if (vEditResult != null)
			strTemp = (String)vEditResult.elementAt(9);
		else
			strTemp = WI.fillTextValue("maternity_days");
	
		if (strTemp.length() == 0)
			strTemp = "60"; // default value for maternity leave		
	%> <input name="maternity_days" type= "text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'"
    onBlur="style.backgroundColor='white'; AllowOnlyInteger('form_','maternity_days')"  
	value="<%=strTemp%>" size="3" maxlength="3" onKeyUp="AllowOnlyInteger('form_','maternity_days')"> 
            </td>
          </tr>
          <tr> 
            <td height="15">&nbsp;</td>
            <td colspan="3" bgcolor="#B9B9DD">&nbsp;</td>
          </tr>
        </table>
        <%}%> <table width="95%" border="0"  cellpadding="2" cellspacing="0">
          <tr> 
            <td width="2%">&nbsp;</td>
            <td width="20%" rowspan="3" bgcolor="#F0EFF1" >Date(s) of Leave</td>
            <td width="13%" bgcolor="#F0EFF1" >(FROM) </td>
            <td colspan="2" bgcolor="#F0EFF1" >		
<% if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(10);
	else
		strTemp = WI.fillTextValue("ldatefrom");
%> <input name="ldatefrom" type= "text" class="textbox"  value="<%=strTemp%>" 
			 size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','ldatefrom','/');ComputeDuration();"  
				onKeyUp="AllowOnlyIntegerExtn('form_','ldatefrom','/');ComputeDuration();"> <a href="javascript:show_calendar('form_.ldatefrom');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              Time 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(11));
	else
		strTemp = WI.fillTextValue("hrfrom");
%>
	<input  value="<%=strTemp%>" name="hrfrom" type= "text" class="textbox" 
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','hrfrom');ComputeDuration();"  
			  size="2" maxlength="2"
			  onKeyUp="AllowOnlyInteger('form_','hrfrom');ComputeDuration();">
              : 
<% if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(12);
	else
		strTemp = WI.fillTextValue("fmin");
		
//	if (strTemp.length() < 2) 
//		strTemp = "";
%> 
	<input  value="<%=strTemp%>" name="fmin" type= "text" class="textbox"  size="2"
			   maxlength="2" onFocus="style.backgroundColor='#D3EBFF'" 
			   onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','fmin');ComputeDuration();"
			   onKeyUp="AllowOnlyInteger('form_','fmin');ComputeDuration();" > 
				 <select name="frAMPM" onChange="ComputeDuration();">
                <option value="0">AM</option>
<% if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(13);
	else
		strTemp = WI.fillTextValue("frAMPM");
				strTemp = WI.getStrValue(strTemp);		
				if (strTemp.equals("1")) {%>
                <option value="1" selected>PM</option>
                <%}else{%>
                <option value="1">PM</option>
                <%}%>
              </select></td>
          </tr>
          <tr> 
            <td width="2%">&nbsp;</td>
            <td bgcolor="#F0EFF1">&nbsp;</td>
            <td colspan="2" bgcolor="#F0EFF1">
					<% if (vEditResult != null)
							strTemp = WI.getStrValue((String)vEditResult.elementAt(20));
						else
							strTemp = WI.fillTextValue("onedate");
						
						if (strTemp.equals("1"))
							strTemp = "checked";
						else
							strTemp = "";
					%>
					<label for="oneDate_">
					<input name="onedate" type="checkbox" value="1" <%=strTemp%> onClick="ToggleDateTime();" id="oneDate_">
					<font size="1">Check if leave is not more than 1 day </font>					</label>					</td>
          </tr>
          <tr> 
            <td width="2%">&nbsp;</td>
            <td bgcolor="#F0EFF1" > (TO) </td>
            <td colspan="2" bgcolor="#F0EFF1" >
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(14));
	else
		strTemp = WI.fillTextValue("ldateto");
%>
<input name="ldateto" type= "text"  class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="10" maxlength="10" 
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','ldateto','/');ComputeDuration();" 
			onKeyUp="AllowOnlyIntegerExtn('form_','ldateto','/');ComputeDuration();">
<a href="javascript:show_calendar('form_.ldateto');" title="Click to select date" 
		   onmouseover="window.status='Select date';return true;" 
		   onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> Time 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(15));
	else
		strTemp = WI.fillTextValue("hrto");
%> 
		<input  value="<%=strTemp%>" name="hrto" type= "text" class="textbox"  
		onFocus="style.backgroundColor='#D3EBFF'"  size="2" maxlength="2"
		onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','hrto');ComputeDuration();" 
		onKeyUp="AllowOnlyInteger('form_','hrto');ComputeDuration();"> : 
<% if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(16);
	else
		strTemp = WI.fillTextValue("minto");
	
%> 
		<input  value="<%=strTemp%>" name="minto" type= "text" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" size="2" maxlength="2"
		onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','minto');ComputeDuration();"
		onKeyUp="AllowOnlyInteger('form_','minto');ComputeDuration();" > 
        <select name="toAMPM" onChange="ComputeDuration();">
           <option value="0">AM</option>
                <%
	if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(17);
	else
		strTemp = WI.fillTextValue("toAMPM");		
		strTemp = WI.getStrValue(strTemp);		
				if (strTemp.compareTo("1") == 0) {
%>
                <option value="1" selected>PM</option>
                <%}else{%>
                <option value="1">PM</option>
                <%}%>
              </select></td>
          </tr>
          <tr> 
            <td height="28">&nbsp;</td>
            <td colspan="3" valign="bottom" bgcolor="#FFFFFF" >No. of days/hrs 
              applied <strong>: 
				<%
					if (vEditResult != null)
						strTemp = (String)vEditResult.elementAt(22);
					else
						strTemp = WI.fillTextValue("days_applied");				
				%>
              <input  value="<%=strTemp%>" name="days_applied" type= "text" class="textbox" 
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','days_applied')" 
			  onKeyUp="AllowOnlyFloat('form_','days_applied')" size="4" maxlength="5">
					<%if(strSchCode.startsWith("TAMIYA") || strSchCode.startsWith("AUF")){%>
						<input type="hidden" name="unit_applied" value="1"> hours
					<%}else{%>
              <select name="unit_applied">
                <option value="0">day(s)</option>
                <% if (vEditResult != null)
										strTemp = (String)vEditResult.elementAt(46);
									else
										strTemp = WI.fillTextValue("unit_applied");
						
				if (strTemp.equals("1")) {%>
                <option value="1" selected>hour(s)</option>
                <%}else{%>
                <option value="1">hour(s)</option>
                <%}%>
              </select>
							<%}%>
              </strong></td>
            <td width="40%" valign="bottom" bgcolor="#FFFFFF" >Date Filed : 
<% if (vEditResult != null) 
		strTemp = WI.getStrValue((String)vEditResult.elementAt(3));
	else
		strTemp = WI.fillTextValue("datefiled");
	
	if(strTemp.length()  == 0) 
		strTemp = WI.getTodaysDate(1);
%> <input name="date_filed" type= "text"  class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" size="10" maxlength="10"
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_filed','/')" 
	  onKeyUp="AllowOnlyIntegerExtn('form_','date_filed','/')" value="<%=strTemp%>"> 
	  <a href="javascript:show_calendar('form_.date_filed');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
          <%if(!strSchCode.startsWith("TAMIYA")){%>
					<tr>
            <td height="22">&nbsp;</td>
            <td colspan="3" valign="bottom" bgcolor="#FFFFFF" >Note : 1 day = 8 hours</td>
            <td valign="bottom" bgcolor="#FFFFFF" >&nbsp;</td>
          </tr>
					<%}%>
          <tr> 
            <td height="114">&nbsp;</td>
            <td colspan="4" bgcolor="#FFFFFF" >Explanation/Reason : <br> 
<% if (vEditResult != null) 
		strTemp = WI.getStrValue((String)vEditResult.elementAt(23));
	else
		strTemp = WI.fillTextValue("reason");
%> <textarea name="reason" cols="64" rows="3"  class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea>            </td>
          </tr>
        </table>
        <table width="100%" border="0" cellpadding="2" cellspacing="0">
          <tr> 
            <td height="10" colspan="4"><hr size="1"></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="3" valign="bottom"><strong><u><font size="2">Contact 
              info while on leave :</font></u></strong></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td width="12%" height="25">Address</td>
            <td width="86%" height="25" colspan="2"> 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(4));
	else
		strTemp = WI.fillTextValue("caddress");
	if(bolNewIDEntered)
		strTemp = "";
	if (strTemp.length() == 0 && vEmpRec!= null && vEmpRec.size() > 0)	 
		strTemp = WI.getStrValue((String)vEmpRec.elementAt(8));
%> <input value="<%=strTemp%>" name="caddress" type="text" size="64" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Tel. No.</td>
            <td height="25" colspan="2"> 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(5));
	else
		strTemp = WI.fillTextValue("contact_tel");
	
	if(bolNewIDEntered)
		strTemp = "";
	if (strTemp.length() == 0 && vEmpRec != null && vEmpRec.size() > 0) 
		 strTemp = WI.getStrValue((String)vEmpRec.elementAt(7));
%> <input value="<%=strTemp%>"  name="contact_tel" type="text" 
			size="25"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" ></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Cell No.</td>
            <td height="25" colspan="2"> 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(6));
	else
		strTemp = WI.fillTextValue("contact_mobile");
	if(bolNewIDEntered)
		strTemp = "";
%> <input value="<%=strTemp%>" name="contact_mobile" type="text" size="25"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
          </tr>
        </table>
        <% if (!bolMyHome || bolIsSupervisor){%> 
        <table width="100%" border="0" cellpadding="5" cellspacing="0">
          <tr> 
            <td height="25" colspan="3"><hr size="1"></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25" colspan="2" valign="bottom">Recommending Approval 
              by
              <% if(bolIsSchool){%>
              Dean/
              <%}%>
            Head:</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td width="36%" height="25">
			<select name="head_approved" onChange="UpdateReqStatus()">
                <option value="2">Pending</option>
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(28),"3");
	else
		strTemp = WI.fillTextValue("head_approved");
		
	if (strTemp.equals("1")) {
%>
                <option value="1" selected>Approved</option>
                <%}else{%>
                <option value="1">Approved</option>
                <%} if (strTemp.equals("0")) {%>
                <option value="0" selected>Disapproved</option>
                <%}else{%>
                <option value="0">Disapproved</option>
                <%} if (strTemp.equals("3")) {%>
                <option value="3" selected>Not Required</option>
                <%}else{%>
                <option value="3">Not Required</option>
                <%}%>
              </select> 
              <!--			  
			   <select name="head_approved_option">
                <option value="1">With Pay</option>
                <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(0),"0");
	else
		strTemp = WI.fillTextValue("head_approved_option");
		
		if (strTemp.equals("0")) {%>
                <option value="0" selected>Without Pay</option>
                <%}else{%>
                <option value="0">Without Pay</option>
                <%}%>
              </select>
-->            </td>
            <td height="25">Date : 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(35));
	else
		strTemp = WI.fillTextValue("head_date");
%> <input name="head_date" type="text" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','head_date','/')" 
			  onKeyUp="AllowOnlyIntegerExtn('form_','head_date','/')" value = "<%=strTemp%>" size="10" maxlength="10"> 
              <a href="javascript:show_calendar('form_.head_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2" valign="bottom"> Approval by
              <%if(strSchCode.startsWith("TSUNEISHI")){%>
Team Supervisor
<%}else{%>
Vice-President
<%}%>
concerned : </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25"> <select name="vp_approved" onChange="UpdateReqStatus()">
                <option value="3">Not Required</option>
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(29),"3");
	else
		strTemp = WI.getStrValue(WI.fillTextValue("vp_approved"),"3");
		
		if (strTemp.equals("1")) {%>
                <option value="1" selected>Approved</option>
                <%}else{%>
                <option value="1">Approved</option>
                <%}if (strTemp.equals("0")){%>
                <option value="0" selected>Disapproved</option>
                <%}else{%>
                <option value="0">Disapproved</option>
                <%}if (strTemp.equals("2")){%>
                <option value="2" selected>Pending</option>
                <%}else{%>
                <option value="2">Pending</option>
                <%}%>

              </select> 
              <!--			  
			   <select name="vp_approved_option">
                <option value="1">With Pay</option>
                <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(0),"0");
	else
		strTemp = WI.fillTextValue("vp_approved_option");
		
		if (strTemp.equals("0")) {%>
                <option value="0" selected>Without Pay</option>
                <%}else{%>
                <option value="0">Without Pay</option>
                <%}%>
              </select>
-->            </td>
            <td width="62%">Date : 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(37));
	else
		strTemp = WI.fillTextValue("vp_date");
%> <input name="vp_date" type="text" class="textbox"  value = "<%=strTemp%>"
  			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','vp_date','/')" 
			  onKeyUp="AllowOnlyIntegerExtn('form_','vp_date','/')" size="10" maxlength="10" > 
              <a href="javascript:show_calendar('form_.vp_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2" valign="bottom"><%if(strSchCode.startsWith("TSUNEISHI")){%>
Group Leader/Manager's
  <%}else{%>
President's
<%}%>
Approval: </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom"> <select name="pres_approved"  onChange="UpdateReqStatus()">
                <option value="3">Not Required</option>
                <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(30),"3");
	else
		strTemp = WI.getStrValue(WI.fillTextValue("pres_approved"),"3");
		
				if (strTemp.equals("1")){%>
                <option value="1" selected>Approved</option>
                <%}else{%>
                <option value="1">Approved</option>
                <%}if (strTemp.equals("0")){%>
                <option value="0" selected>Disapproved</option>
                <%}else{%>
                <option value="0">Disapproved</option>
                <%}if (strTemp.equals("2") ){%>
                <option value="2" selected>Pending</option>
                <%}else{%>
                <option value="2">Pending</option>
                <%}%>
              </select> 
              <!--			  
			  <select name="pres_approved_option">
                <option value="1">With Pay</option>
                <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(0),"0");
	else
		strTemp = WI.fillTextValue("pres_approved_option");
		
		if (strTemp.equals("1")){%>
                <option value="0" selected>Without Pay</option>
                <%}else{%>
                <option value="0">Without Pay</option>
                <%}%>
              </select>
-->            </td>
            <td>Date : 
              <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(37));
	else
		strTemp = WI.fillTextValue("pres_date");
%> <input name="pres_date" type="text" class="textbox" value="<%=strTemp%>"
   			  onFocus="style.backgroundColor='#D3EBFF'" size="10" maxlength="10" 
			  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','pres_date','/')" 
			  onKeyUp="AllowOnlyIntegerExtn('form_','pres_date','/')"> <a href="javascript:show_calendar('form_.pres_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>            </td>
          </tr>
          <tr> 
            <td height="10" colspan="3"><hr size="1"></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td colspan="2">Subsitute : <font size="1">(type lastname)</font> 
              <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="16" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px" onKeyUp = "AutoScrollList('form_.starts_with','form_.substitute',true);"> 
              <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(24));
	else
		strTemp = WI.fillTextValue("substitute");
%> <select name="substitute">
                <option value="" >Select Substitute </option>
                <%=dbOP.loadCombo("user_index","lname +'&nbsp;' + fname as emp_name",
				" FROM USER_TABLE WHERE ((AUTH_TYPE_INDEX <>4 and AUTH_TYPE_INDEX<>6) or AUTH_TYPE_INDEX is null) and is_valid = 1 and is_del =0  order by lname  ",strTemp,false)%> </select> <font size="1">(select Emp. ID)</font></td>
          </tr>
          <tr> 
            <td height="10" colspan="3"><hr size="1"></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td colspan="2"><u> <font size="2"><strong>Request Status:</strong></font></u>            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
						<% if (vEditResult != null)
								strTemp = WI.getStrValue((String)vEditResult.elementAt(31));
							else
								strTemp = WI.fillTextValue("leave_appl_status");
						%>
            <td colspan="2"> 
	<select name="leave_appl_status" onChange="UpdateReqStatus();">
       <option value="2">Pending/On-process</option>
		 <%
			if(strSchCode.startsWith("TSUNEISHI"))
				strTemp2 = "Team Supervisor";
			else
				strTemp2 = "Vice-President";				
			 if(strTemp.equals("3")){%>
	   	<option value="3" selected>Recommends Approval by <%=strTemp2%></option>
			<%}else{%>
			<option value="3">Recommends Approval by <%=strTemp2%></option>
			<%}
			
			if(strSchCode.startsWith("TSUNEISHI"))
				strTemp2 = "Group Leader/Manager";
			else
				strTemp2 = "President";				
			if(strTemp.equals("4")){%>
	   <option value="4" selected>Recommends Approval by <%=strTemp2%></option>
		 <%}else{%>
		 <option value="4">Recommends Approval by <%=strTemp2%></option>
		 <%}if(strTemp.equals("1")){%>		 
       <option value="1" selected>Approved</option>
			 <%}else{%>
			 <option value="1">Approved</option>
		 <%}if(strTemp.equals("0")){%>		 
       <option value="0" selected>Disapproved</option>
			 <%}else{%>
			 <option value="0">Disapproved</option>
			 <%}%>
    </select>					</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td colspan="2">Date of Request Status Update : 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(38));
	else
		strTemp = WI.fillTextValue("date_status");
		
		if (strTemp.length() == 0) {
			strTemp = WI.getTodaysDate(1);
		}
%> <input name="date_status"  type= "text" class="textbox"  value="<%=strTemp%>" 
			 size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_status','/')"  
				onKeyUp="AllowOnlyIntegerExtn('form_','date_status','/')"> <a href="javascript:show_calendar('form_.date_status');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
					<%if(strSchCode.startsWith("AUF")){%>
          <tr> 
            <td height="25">&nbsp;</td>
            <td colspan="2">Remarks : <br> 
					<% if (vEditResult != null)
							strTemp = WI.getStrValue((String)vEditResult.elementAt(39));
						else
							strTemp = WI.fillTextValue("request_remarks");
					%> 
					<select name="request_remarks">
					<%for (int i = 0; i <astrCurrentRemarks.length;  i++){
						if (strTemp.equals(astrCurrentRemarks[i])) {
					%> 
						<option selected> <%=astrCurrentRemarks[i]%></option>
					<%}else{%>
						<option> <%=astrCurrentRemarks[i]%></option>
					<%} // end if else
					} // end for loop%> 		
					</select>					  </td>
       		</tr>
			 <%} else {%>
          <tr> 
            <td height="25">&nbsp;</td>
            <td colspan="2">
						Remarks : <br> 
					<% if (vEditResult != null)
							strTemp = WI.getStrValue((String)vEditResult.elementAt(39));
						else
							strTemp = WI.fillTextValue("request_remarks");
						%> 	 
					 <textarea name="request_remarks" cols="48" rows="3" class="textbox"
					 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>					 </td>
          </tr>
					<%}%>					
          <tr bgcolor="#FDEEEA">
            <td height="25">&nbsp;</td>
            <td colspan="2"><strong><font color="#0000FF">UPDATE ONLY 
              THIS PORTION WHEN EMPLOYEE RETURNS FOR WORK:</font></strong></td>
          </tr>
          <tr bgcolor="#FDEEEA"> 
            <td height="25">&nbsp;</td>
            <td colspan="2">RETURN DATE :
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(25));
	else
		strTemp = WI.fillTextValue("date_return");
%> <input name="date_return"  type= "text" class="textbox"  value="<%=strTemp%>" 
			 size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_return','/')"  
				onKeyUp="AllowOnlyIntegerExtn('form_','date_return','/')"> <a href="javascript:show_calendar('form_.date_return');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;RETURN TIME : 
              <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(32));
	else
		strTemp = WI.fillTextValue("hr_ret");
%> <input name="hr_ret" type= "text" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','hr_ret')" 
			onKeyUp=" AllowOnlyInteger('form_','hr_ret')"  value="<%=strTemp%>" size="2" maxlength="2">
              : 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(33));
	else
		strTemp = WI.fillTextValue("min_ret");
		
		if (strTemp.length() <2) strTemp = "";
%> <input  value="<%=strTemp%>" name="min_ret" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','min_ret')" onKeyUp="AllowOnlyInteger('form_','min_ret')" size="2" maxlength="2"> 
              <select name="ampm_ret">
                <option value="0">AM</option>
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(34));
	else
		strTemp = WI.fillTextValue("ampm_ret");
%>               <% if (strTemp.equals("1")) {%>
                <option value="1" selected>PM</option>
                <%}else{%>
                <option value="1">PM</option>
                <%}%>
              </select></td>
          </tr>
          <tr bgcolor="#FDEEEA"> 
            <td height="25">&nbsp;</td>
            <td colspan="2">Actual No. days/hrs<strong>: 
            <%
 							if (vEditResult != null)
								strTemp = (String)vEditResult.elementAt(26);
							else
								strTemp = WI.fillTextValue("actual_days");
							
 							if (strTemp.equals("0")) 
								strTemp = "";
						%>
              <input  value="<%=strTemp%>" name="actual_days" type= "text" class="textbox" 
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','actual_days')" 
			  onKeyUp="AllowOnlyFloat('form_','actual_days')" size="4" maxlength="5">
              </strong><strong>
					<%if(strSchCode.startsWith("TAMIYA") || strSchCode.startsWith("AUF")){%>
						<input type="hidden" name="actual_unit" value="1"> hours
					<%}else{%>				
					<select name="actual_unit">
						<option value="0">day(s)</option>
					<% if (vEditResult != null)
							strTemp = (String)vEditResult.elementAt(47);
						else
							strTemp = WI.fillTextValue("actual_unit");
											
						if (strTemp.equals("1")) {%>	
						<option value="1" selected>hour(s)</option>
						<%}else{%>
						<option value="1">hour(s)</option>
						<%}%>
					</select>
					<%}%>
					&nbsp;&nbsp;
              <% 
	if (vEditResult != null && vEditResult.size() > 0){
		strTemp = WI.getStrValue((String)vEditResult.elementAt(44));
		strWasFinalized = strTemp;
	}else
		strTemp = WI.fillTextValue("is_final");


if (strTemp.equals("1")) 
		strTemp = "checked";
	else
		strTemp = "";
%>
              <input type="checkbox" name="is_final" value="1" <%=strTemp%>><font color="#FF0000">
              CHECK TO UPDATE LEAVE CREDITS
              </font></strong></td>
          </tr>
          <tr bgcolor="#FDEEEA">
            <td height="18">&nbsp;</td>
						<%
						strTemp = WI.fillTextValue("ignore_overlap");
						if (strTemp.equals("1")) 
								strTemp = "checked";
							else
								strTemp = "";
						%>						
            <td colspan="2"><strong><font color="#FF0000">
              <input type="checkbox" name="ignore_overlap" value="1" <%=strTemp%>>
Ignore Overlapping Dates </font></strong></td>
          </tr>
        </table>
      <%}  // end if not bol my home%> 
	 
	  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="98%" height="51" align="center" valign="bottom"> 
              <% if (iAccessLevel > 1){
		if(vEditResult == null  || vEditResult.size() == 0) { %>              
			<a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
              <font size="1">click to save entries</font> 
              <%}else{%>              <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> 
              <font size="1">click to save changes</font> <a href='javascript:CancelRecord("<%=WI.fillTextValue("emp_id")%>")'> 
              <img src="../../../images/cancel.gif" border="0"></a> <font size="1">click 
                  to cancel and clear entries</font> 
              <%}}%></td>
          </tr>
        </table>
<% } // end !bolViewOnly %>		
		
	  </td>
    </tr>
  </table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<%
				strTemp = WI.fillTextValue("show_all");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
			<td><input type="checkbox" name="show_all" value="1" <%=strTemp%> onClick="ReloadPage();">
			  Show all leaves(ignore year) </td>
		</tr>
	</table>

         <% if (vRetResult != null && vRetResult.size() > 0) {%> 
        <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
          <tr> 
            <td height="21" colspan="<%=(!bolViewOnly)?9:8%>" align="center" bgcolor="#F2EDE6" class="thinborder"><strong>LIST 
              OF APPLIED LEAVES </strong></td>
          </tr>
          <tr> 
            <td width="10%" height="25" align="center" class="thinborder"><font size="1"><strong>Date 
              Filed</strong></font></td>
            <td width="13%" align="center" class="thinborder"><font size="1"><strong> Type 
              of Leave</strong></font></td>
            <td width="16%" align="center" class="thinborder"><font size="1"><strong> 
              Date Fr (Time) ::<br>
            Date To (Time)</strong></font></td>
            <td width="8%" align="center" class="thinborder"><font size="1"><strong>Days 
              (Hours) <br>
              Applied</strong></font></td>
            <td width="12%" align="center" class="thinborder"><font size="1"><strong>Status</strong></font></td>
            <td width="12%" align="center" class="thinborder"><font size="1"><strong> &nbsp;Date 
              (Time) Return </strong></font></td>
            <td width="10%" align="center" class="thinborder"><font size="1"><strong>Actual Days 
              (Hours)</strong></font></td>
            <td width="5%" align="center" class="thinborder"><font size="1"><strong>View 
              / Print</strong></font></td>
			<% if (!bolViewOnly) {%> 
            <td width="14%" align="center" class="thinborder"><font size="1"><strong>Options</strong></font></td>
			<%}%>
          </tr>
    <% for (int i =0 ; i < vRetResult.size() ; i+= 50) {
		  bolShowEdit = true;
		  if (!WI.getStrValue((String)vRetResult.elementAt(i+44)).equals("1")){
		  	strTemp = "#FFF2F2";
		  }else{
		  	strTemp = "";
		  }
	  %>
          <tr bgcolor="<%=strTemp%>"> 
            <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+42),"Leave Without Pay")%></td>
            <%
				strTemp = (String)vRetResult.elementAt(i+10);
				if ((String)vRetResult.elementAt(i+11) != null){
					strTemp += "(" + (String)vRetResult.elementAt(i+11)  + ":" +
								(String)vRetResult.elementAt(i+12) +
								astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+13))] + 
								")";
				}
				
				strTemp += "<br>";
				
				if ((String)vRetResult.elementAt(i+14) != null) {
					strTemp +=" :: "  + (String)vRetResult.elementAt(i+14);
				}
				
									
				if ((String)vRetResult.elementAt(i+15) != null){
					if ((String)vRetResult.elementAt(i+14) == null){
						strFrom = WI.getStrValue((String)vRetResult.elementAt(i+18), "0");
						strFrom = ConversionTable.replaceString(strFrom, ",","");
						strTo = WI.getStrValue((String)vRetResult.elementAt(i+19), "0");
						strTo = ConversionTable.replaceString(strTo, ",","");
						if(Double.parseDouble(strFrom) > Double.parseDouble(strTo)){
						  odTemp = ConversionTable.convertMMDDYYYYToDate((String)vRetResult.elementAt(i+10));
							calTemp.setTime(odTemp);
							calTemp.add(Calendar.DAY_OF_MONTH, 1);
							strTemp += ConversionTable.convertMMDDYYYY(calTemp.getTime());
						}else{					
							strTemp += (String)vRetResult.elementAt(i+10);
						}
					}
					strTemp += "(" + (String)vRetResult.elementAt(i+15)  + ":" +
								(String)vRetResult.elementAt(i+16) +
								astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+17))] + 
								")";
				}
				
			%>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
          <%
					strTemp = (String)vRetResult.elementAt(i+22);
					if(((String)vRetResult.elementAt(i+46)).equals("1"))
						strTemp = WI.getStrValue(strTemp, "(",")","");					
					//if (!((String)vRetResult.elementAt(i+21)).equals("0"))
					//	strTemp += "(" + (String)vRetResult.elementAt(i+21) + ")";
					%>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
            <td class="thinborder">&nbsp;<strong><%=astrCurrentStatus[Integer.parseInt((String)vRetResult.elementAt(i+31))]%></strong></td>
            <%
				strTemp =WI.getStrValue((String)vRetResult.elementAt(i+25));
				if ((String)vRetResult.elementAt(i+32) != null)
					strTemp += "(" + (String)vRetResult.elementAt(i+32) + ":" 
						 + (String)vRetResult.elementAt(i+33) +  
						 astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+34))]					  
						 + ")";				
			%>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
         <%
					strTemp =(String)vRetResult.elementAt(i+26);
					if(((String)vRetResult.elementAt(i+47)).equals("1"))
						strTemp = WI.getStrValue(strTemp, "(",")","");		
				//if (!((String)vRetResult.elementAt(i+27)).equals("0")){
				//	strTemp += "(" + (String)vRetResult.elementAt(i+27) + ")";
				//}
				 %>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
            <td align="center" class="thinborder">
						<a href="javascript:ViewPrintDetails('<%=(String)vRetResult.elementAt(i)%>',
																								 '<%=WI.fillTextValue("emp_id")%>',
																								 	<%=WI.fillTextValue("sy_from")%>,
																									<%=WI.fillTextValue("sy_to")%>,
																									<%=WI.fillTextValue("semester")%>,
																									<%=WI.getStrValue(WI.fillTextValue("my_home"),"0")%>)">
						<img src="../../../images/view.gif" width="40" height="31" border="0">
						</a></td>
            <% if (!bolViewOnly) {%> 			
            <td class="thinborder"> 
		
			
			<%
			if(bolAllowEditFinal || !((String)vRetResult.elementAt(i+31)).equals("1") || 
				!WI.getStrValue((String)vRetResult.elementAt(i+44)).equals("1")){
			if(((String)vRetResult.elementAt(i+44)).equals("1") && bolMyHome)
				bolShowEdit = false;			
			if (iAccessLevel > 1 && bolShowEdit) {
				%> 
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
					
              <% if (iAccessLevel == 2) {%> <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
              <% 	} // end iAccessLevel ==2
			 }else{%>
              N/A 
       <%}
			 }// end if bolAllowEditFinal
			 	else{%>
				Already Approved
				<%}%>
		    </td>
			<%}%>
          </tr>
          <%} // end for loop %>
  </table>
		<table bgcolor="#FFFFFF" width="100%" cellpadding="0" cellspacing="0">
		<tr>
		  <td>&nbsp;<strong>Note</strong> : Items in <span class="style1">Red</span> are not yet finalized</td>
		  </tr>
		<tr> <td align="center"><a href='javascript:PrintList()'><img src="../../../images/print.gif" width="58" height="26" border="0"></a> click to print list </td>
		</tr>
		</table>
        <%} %>  
<% } %>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<% if (!bolMyHome) {%>
  <script language="JavaScript">
    <% if (vEmpRec!= null && (vEditResult == null || vEditResult.size() == 0)){%>
		UpdateReqStatus();
	<%}%>
	FocusID();
  </script>
<%}%>
<script language="JavaScript">
	<%if(vEditResult == null || vEditResult.size() == 0){%>
	ToggleDateTime();
	<%}%>
</script>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="cur_leave_text" value="<%=strCurLeaveText%>">
<input type="hidden" name="prepareToEdit">
<input type="hidden" name="was_finalized" value="<%=strWasFinalized%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
<input type="hidden" name="view_only" value="<%=WI.fillTextValue("view_only")%>">
<input type="hidden" name="print_list" value="">
<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> 
<input type="hidden" name="close_wnd_called" value="0">
<input type="hidden" name="donot_call_close_wnd">
<% if (bolViewOnly) {%> 
<input type="hidden" name="benefit_index" value="<%=WI.fillTextValue("benefit_index")%>">
<%}%> 
<input type="hidden" name="prev_id" value="<%=WI.fillTextValue("emp_id")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
