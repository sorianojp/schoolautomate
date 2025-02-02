<%@ page language="java" import="utility.*, health.ClinicVisitLog ,java.util.Vector " %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsAUF = strSchCode.startsWith("AUF");
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<script language="javascript" src="../../../jscript/common.js" ></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ViewDetails(strInfoIndex)
{
	var pgLoc = "./case_detail.jsp?info_index="+strInfoIndex+"&visit_index="+strInfoIndex+"&stud_id="+document.form_.stud_id.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0'){
		if(!confirm("Are you sure you want to delete this entry?"))
			return;
	}

	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function DiagnosticChecklist(strVisitLogIndex){
	var pgLoc = "./diagnostic_checklist.jsp?opner_info=form_.stud_id&visit_log_index="+strVisitLogIndex;
	var win=window.open(pgLoc,"DiagnosticChecklist",'width=800,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintSlips(strVisitLogIndex, strRefIndex){
	var pgLoc = "./print_slips.jsp?opner_info=form_.stud_id&visit_log_index="+strVisitLogIndex+"&ref_index="+strRefIndex;
	var win=window.open(pgLoc,"PrintSlips",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function Cancel()
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function EmpSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function DepSearch() {
	var pgLoc = "./search_dependent.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function DocSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.doc_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function updatePhysicians(){
	var pgLoc = "./accredited_physicians_mgmt.jsp?is_forwarded=1";
	var win=window.open(pgLoc,"updatePhysicians",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function NurseSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.nurse_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID() {
	document.form_.stud_id.focus();
}
function PrintPg() {
	var strID = document.form_.stud_id.value;
	if(strID.length == 0) {
		alert("Please enter ID Number.");
		return;
	}
	location = "./patient_hist.jsp?stud_id="+strID;
}
function viewList(table,indexname,colname,labelname,tablelist,
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
	"&opner_form_name=form_";
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateComplaints(strVisitIndex) {
	var pgLoc = "./complaints.jsp?visit_index="+strVisitIndex;
	var win=window.open(pgLoc,"updateComplaints",'width=650,height=350,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdatePrognosis(strVisitIndex) {
	var pgLoc = "./prognosis.jsp?visit_index="+strVisitIndex;
	var win=window.open(pgLoc,"updatePrognosis",'width=650,height=350,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CopyDiagnosis() {
	var vSelected = document.form_.diagnosis;
	var vIndex = -1;
	if(vSelected.value.length == 0) {
		alert("Please select diagnosis to add");
		return;
	}

	vIndex = eval("document.form_.diag_txt.value").indexOf(vSelected[vSelected.selectedIndex].text);
  	if(vIndex == -1 || document.form_.diag_txt.value.length == 0 || document.form_.allow_double_diag.checked){
		if(document.form_.diag_txt.value.length > 0)
			document.form_.diag_txt.value +=	", ";
		document.form_.diag_txt.value += vSelected[vSelected.selectedIndex].text;
	}
}

function AjaxMapName(strPos) {
	var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
	
	if(strCompleteName.length <=2)
		return;

	var objCOAInput = document.getElementById("coa_info");

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+
		escape(strCompleteName)+ "&is_faculty=1";
	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {

}
function UpdateNameFormat(strName) {
	//do nothing..
}</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strCaseNo = null;
	String [] astrYN = {"No", "Yes"};
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	int iSearchResult = 0;
	String strUserIndex = null;

	boolean bolNoRecord = true; //it is false if there is error in edit info.
	String strImgFileExt = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","log.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

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
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
														"log.jsp");
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

//end of authenticaion code.
Vector vBasicInfo = null;
boolean bolIsStaff = false;
boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
String strSlash = "";

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
//get all levels created.
if(WI.fillTextValue("stud_id").length() > 0) {
	if(bolIsSchool) {
		vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
		if(vBasicInfo == null) //may be it is the teacher/staff
		{
			request.setAttribute("emp_id",request.getParameter("stud_id"));
			vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vBasicInfo != null)
				bolIsStaff = true;
		}
		else {//check if student is currently enrolled
			Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"),
			(String)vBasicInfo.elementAt(10),(String)vBasicInfo.elementAt(11),(String)vBasicInfo.elementAt(9));
			if(vTempBasicInfo != null)
				bolIsStudEnrolled = true;
		}
		if(vBasicInfo == null)
			strErrMsg = OAdm.getErrMsg();
	}
	else{//check faculty only if not school...
			request.setAttribute("emp_id",request.getParameter("stud_id"));
			vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vBasicInfo != null)
				bolIsStaff = true;
			if(vBasicInfo == null)
				strErrMsg = "Employee Information not found.";
	}
}

	ClinicVisitLog CVLog = new ClinicVisitLog();
	strCaseNo = CVLog.generateCaseNo();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(CVLog.operateOnClinicVisit(dbOP, request, Integer.parseInt(strTemp)) != null ) {
				strErrMsg = "Operation successful.";
				strPrepareToEdit = "";
		}
		else
			strErrMsg = CVLog.getErrMsg();
	}

	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = CVLog.operateOnClinicVisit(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null )
			strErrMsg = CVLog.getErrMsg();
	}

	vRetResult = CVLog.operateOnClinicVisit(dbOP, request, 4);
	iSearchResult = CVLog.getSearchCount();
	if (strErrMsg == null && WI.fillTextValue("stud_id").length()>0)
		strErrMsg = CVLog.getErrMsg();

%>
<body bgcolor="#8C9AAA" onLoad="FocusID();" class="bgDynamic">
<form action="log.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="28" colspan="5" align="center" bgcolor="#697A8F" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        CLINIC VISIT LOG - LOG PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td height="18" colspan="5" style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td width="3%"  height="28">&nbsp;</td>
      <td width="15%" height="28">Enter ID No. :</td>
      <td width="25%" height="28">
      <%strTemp = WI.fillTextValue("stud_id");%>
      <input type="text" name="stud_id" class="textbox"
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName('1');"> 
	  </td>
      <td width="28%" height="28"><font size="1">
<%if(bolIsSchool){%>
      <a href="javascript:StudSearch();"><img src="../../../images/search.gif" border="0" ></a> Click to search for student
<br><%}%>
      <a href="javascript:EmpSearch();">
      <img src="../../../images/search.gif" border="0" ></a> Click to search for employee
	 <%if(bolIsAUF){%>
	  <br>	  
	  <a href="javascript:DepSearch();">
      <img src="../../../images/search.gif" border="0" ></a> Click to search for dependent
	  <%}%>
      </font></td>
      <td width="29%"><%if(WI.fillTextValue("stud_id").length() > 0) {%>
	  <%strTemp = "<img src=\"../../../upload_img/" + WI.fillTextValue("stud_id").toUpperCase() +
								"."+strImgFileExt+"\" width=150 height=150>";%>
                    <%=strTemp%>
      <%}%>
	  </td>
    </tr>
    <tr>
		<td height="28">&nbsp;</td>
		<td height="28">&nbsp;</td>
		<td height="28"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
		<td height="28" colspan="2"><label id="coa_info" style="font-size:11px;"></label></td>
    </tr>
    <tr>
		<td height="18" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%
if(vBasicInfo != null){
	strUserIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(!bolIsStaff){%>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="15%" >Student Name : </td>
      <td width="46%" ><strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></td>
      <td width="13%" >Status : </td>
      <td width="24%" > <%if(bolIsStudEnrolled){%>
        Currently Enrolled <%}else{%>
        Not Currently Enrolled <%}%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course/Major :</td>
      <td height="25" colspan="3" ><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Year :</td>
      <td ><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <%}//if not staff
else{%>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Emp. Name :</td>
      <td ><strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(1),
	  (String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),4)%></strong></td>
      <td >Emp. Status :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td ><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office :</td>
      <td > <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/
	  <%=WI.getStrValue(vBasicInfo.elementAt(14))%></strong></td>
      <td >Designation :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <%}//only if staff %>
   <tr>
      <td height="18" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%}%>
  <%if (vBasicInfo!=null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">CASE #</td>
      <td height="25" colspan="3" style="font-weight:bold; color:#0000FF;">
	  <%if(vEditInfo != null && vEditInfo.size() > 0) {%>
	  <%=vEditInfo.elementAt(2)%>
	  <%}else{%>
	  	<%=WI.fillTextValue("case_no")%>
	  <%}%>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date</td>
      <td height="25" colspan="3">
      <%
       if(vEditInfo != null && vEditInfo.size() > 0)
				 strTemp = (String)vEditInfo.elementAt(1);
			 else
				 strTemp = WI.fillTextValue("visit_date");

		 if (strTemp == null || strTemp.length()==0)
        	  	strTemp = WI.getTodaysDate(1);
		%>
		<input name="visit_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true">
        <a href="javascript:show_calendar('form_.visit_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
		&nbsp;&nbsp;Time :
    <%
		 if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(14);
		 else
				strTemp = WI.fillTextValue("time_");

		 if ((strTemp == null || strTemp.length()==0) && vEditInfo == null)
        	strTemp = WI.getTodaysDate(15);
  	%>
		<input name="time_" type="text" size="12" maxlength="12" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>">
		<font size="1">(optional)</font></td>
    </tr>
<%if(bolIsStaff && bolIsAUF){%>
	<tr>
		<td height="25">&nbsp;</td>
	    <td>Dependent</td>
	    <td colspan="3">
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(27);
				else
					strTemp= WI.fillTextValue("dependent_index");
					
				strErrMsg = 
					" from hm_program_members where is_valid = 1 "+
					" and user_index = "+strUserIndex+" order by fname ";
			%>
			<select name="dependent_index">
				<option value="">Select Dependent</option>
				<%=dbOP.loadCombo("member_index","fname + ' ' + lname + ' (' + id_number + ')'", strErrMsg, strTemp,false)%>
			</select>
			<font size="1">Only fill this up if patient is dependent, otherwise it will be recorded as employee or student.</font></td>
	</tr>
<%}%>
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td width="14%" height="25">Doctor</td>
      <td width="19%" height="25">
      <%if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(6);
			else
				strTemp = WI.fillTextValue("doc_id");
			%>
      <input name="doc_id" type="text" size="16" class="textbox"
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			value="<%=WI.getStrValue(strTemp)%>">			</td>
      <td width="65%" colspan="2"><font size="1"><a href="javascript:DocSearch();"><img src="../../../images/search.gif" border="0" ></a> Click to search for doctor</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Nurse ID </td>
      <td height="25" colspan="3"><font size="1">
    <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(19);
		else
			strTemp = WI.fillTextValue("nurse_id");
		%>
        <input name="nurse_id" type="text" size="16" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				value="<%=WI.getStrValue(strTemp)%>">
      <a href="javascript:NurseSearch();"><img src="../../../images/search.gif" border="0" ></a> Click to search for nurse</font></td>
    </tr>
<%if(bolIsAUF){%>
	<tr>
		<td height="25">&nbsp;</td>
	    <td height="25">Physician</td>
	    <td height="25" colspan="3">
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(24);
				else
					strTemp= WI.fillTextValue("physician");
			%>
			<select name="physician">
				<option value="">Select Physician</option>
				<%=dbOP.loadCombo("physician_index","physician_name", " from hm_accredited_physicians where is_valid = 1 order by physician_name",strTemp,false)%>
			</select>
			<%if(iAccessLevel > 1){%>
				<a href="javascript:updatePhysicians();"><img src="../../../images/update.gif" border="0" ></a> 
				<font size="1">click to add list of accredited physicians </font>
			<%}%></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Purpose of visit </td>
      <td height="25" colspan="3">
	  	<select name="purpose">
				<%if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(17);
					else
						strTemp= WI.fillTextValue("purpose");
				%>
        <option value="">Select purpose of visit</option>
        <%=dbOP.loadCombo("purpose_index","purpose", " from hm_preload_purpose order by purpose",strTemp,false)%>
      </select>
<%if(iAccessLevel > 1){%>
        <a href='javascript:viewList("hm_preload_purpose","purpose_index","purpose",
																		 "PURPOSE OF VISIT","HM_CLINIC_VISIT","visit_purpose_index",
																		 "and HM_CLINIC_VISIT.is_valid = 1","","purpose");'><img src="../../../images/update.gif" border="0" ></a> <font size="1">click to add purpose of visit </font>
<%}%>	 </td>
    </tr>
<%if(bolIsAUF){%>
	<tr>
		<td height="25">&nbsp;</td>
	    <td>Referred by: </td>
	    <td colspan="2">
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(26));
				else
					strTemp= WI.fillTextValue("ref_physician");
			%>
			<select name="ref_physician">
				<option value="">Select Physician</option>
				<%=dbOP.loadCombo("physician_index","physician_name", " from hm_accredited_physicians where is_valid = 1 order by physician_name",strTemp,false)%>
			</select>
			<font size="1">(mandatory if purpose is referral, else value will not be saved)</font></td>
	</tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Complaints</td>
      <td height="25" colspan="3">
	  <%if(vEditInfo != null && vEditInfo.size() > 0) {%>
	  <%=WI.getStrValue((String)vEditInfo.elementAt(15),"<br>","<br>","")%>
	  <%}%>
	  <font size="1">
      <%if (strPrepareToEdit.compareTo("1")==0){%>
      <!--
			<a href='./complaints.jsp?visit_index=<%//=((String)vEditInfo.elementAt(0))%>' target="_blank">
			-->
<%if(iAccessLevel > 1){%>
			<a href="javascript:UpdateComplaints('<%=((String)vEditInfo.elementAt(0))%>');">
	  <img src="../../../images/update.gif" border="0"></a>click
        to update list of complaints from this patient for this visit
        <%} else {%>
        Please click edit to add complaints
        <%}%></font>
<%}%>		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="top">&nbsp;</td>
      <td height="25" colspan="3">
        <%strTemp= WI.fillTextValue("diagnosis");%>
				<select name="diagnosis">
          <option value="">Select diagnosis</option>
          <%=dbOP.loadCombo("diagnosis_index","diagnosis", " from hm_preload_diagnosis order by diagnosis",strTemp,false)%>
        </select>
<%if(iAccessLevel > 1){%>
				<a href='javascript:viewList("hm_preload_diagnosis","diagnosis_index","diagnosis",
																		 "DIAGNOSIS","","","","","diagnosis");'>
      	<img src="../../../images/update.gif" border="0"></a>
				<font size="1">click to update diagnosis list &nbsp;<br>
</font><strong><a href="javascript:CopyDiagnosis();">Copy selected diagnosis</a></strong>
<%}%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="top">Diagnose(s)</td>
      <td height="25" colspan="3">
      <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
		else
			strTemp = WI.fillTextValue("diag_txt");
		%>
      <textarea name="diag_txt" cols="48" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
      <font size="1">
      <input type="checkbox" name="allow_double_diag" value="1">
allow same diagnosis </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Prognosis</td>
      <td height="25" colspan="3"><font size="1">
	  <%if(vEditInfo != null && vEditInfo.size() > 0) {%>
	  	<%=WI.getStrValue((String)vEditInfo.elementAt(16),"<br>","<br>","")%>
	  <%}%>
        <%if (strPrepareToEdit.compareTo("1")==0){%>
        <!--
				<a href='./prognosis.jsp?visit_index=<%//=((String)vEditInfo.elementAt(0))%>' target="_blank">
				-->
<%if(iAccessLevel > 1){%>
				<a href="javascript:UpdatePrognosis('<%=((String)vEditInfo.elementAt(0))%>');">
        <img src="../../../images/update.gif" border="0"></a>click to update list
        of prognosis for this patient for this visit
        <%} else {%>
        Please click edit to add prognosis
        <%}%>
        </font>
<%}%>		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="top">Treatment Plan</td>
      <td height="25" colspan="3">
      <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(8);
		else
			strTemp = WI.fillTextValue("rec_txt");
		%>
		<textarea name="rec_txt" cols="48" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>    </tr>
    <tr>
    	<td height="25"></td>
    	<td height="25" valign="top"></td>
    	<td height="25" colspan="3">
    	 <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp2 = (String)vEditInfo.elementAt(9);
		else
			strTemp2 = WI.fillTextValue("prescript");

		if(strTemp2.compareTo("1") == 0)
			strTemp = "checked";
		else
			strTemp = "";
		%>
    	<input type="checkbox" name="prescript" value="1" <%=strTemp%>> Tick if prescription (Rx)is given
		<%//I have to here check if case is closed or open. If case is open, i have to give option to close the case, else i will not
		//give any option.
		boolean bolIsClosed = true;
		if(vEditInfo != null && vEditInfo.size() > 0 &&  vEditInfo.elementAt(10).equals("0"))
			bolIsClosed = false;
		if(!bolIsClosed) {%>
	    	<input type="checkbox" name="is_closed" value="1"> Close this case <font size="1">(Please note that, after case is closed, it can't be re-opened/edited or deleted)</font>
		<%}%>       </td>
    </tr>
    <tr>
      <td height="48">&nbsp;</td>
      <td height="48">&nbsp;</td>
      <td height="48" colspan="3" valign="bottom"> 
<%if(iAccessLevel > 1){%>
	  <%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
        Click to add entry
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a>
        Click to edit event <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>
        Click to clear entries
        <%}%> 
<%}%>		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click
          to print record</font></div></td>
    </tr>
  </table>
<%if (vRetResult!=null && vRetResult.size()>0){%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="12" bgcolor="#FFFF9F" class="thinborder"><div align="center"><strong>LIST
          OF VISITS</strong></div></td>
    </tr>
<tr>
<td colspan="10" class="thinborder"><div align="right"><font size="1">&nbsp;
      <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/CVLog.defSearchSize;
		if(iSearchResult % CVLog.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>Jump To page:
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}}%>
          </select>
          <%} else {%>&nbsp;<%}%></font></div></td>
</tr>
<tr>
	<td width="10%" align="center" class="thinborder"><font size="1"><strong>Visit Date</strong></font></td>
	<td width="8%" align="center" class="thinborder"><font size="1"><strong>Case #</strong></font></td>
	<td width="12%" align="center" class="thinborder"><font size="1"><strong>Doctor/Nurse</strong></font></td>
	<td width="18%" align="center" class="thinborder"><font size="1"><strong>Purpose of Visit/Complains</strong></font></td>
	<td width="18%" align="center" class="thinborder"><font size="1"><strong>Diagnosis</strong></font></td>
	<td width="18%" align="center" class="thinborder"><font size="1"><strong>Treatment Plan</strong></font></td>
	<td width="5%" align="center" class="thinborder"><font size="1"><strong>Rx Given</strong></font></td>
	<%if(bolIsAUF){%>
	<td width="12%" align="center" class="thinborder"><font size="1"><strong>Referred To </strong></font></td>
	<td width="12%" align="center" class="thinborder"><font size="1"><strong>Diagnostic</strong></font></td>
	<%}%>
	<td width="15%" align="center" class="thinborder"><font size="1"><strong>Options</strong></font></td>
  	</tr>
<% boolean bolShowDelete = true;
for(int i =0; i<vRetResult.size(); i+=30){
	bolShowDelete = true;
%>
<tr>
<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%><%//=WI.getStrValue((String)vRetResult.elementAt(i+14),"<br>","","")%></td>
<td class="thinborder"><a href="javascript:ViewDetails('<%=(String)vRetResult.elementAt(i)%>');">
	<%=(String)vRetResult.elementAt(i+2)%></a></td>
<%
strTemp = WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5),7);
strTemp2 = WI.formatName((String)vRetResult.elementAt(i+21), (String)vRetResult.elementAt(i+22), (String)vRetResult.elementAt(i+23),7);
if(strTemp.length() > 0 && strTemp2.length() > 0)
	strSlash = " / ";

%>
<td class="thinborder"><%=strTemp%><%=strSlash%><%=strTemp2%>&nbsp;</td>
<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+18))%><br><%=WI.getStrValue(vRetResult.elementAt(i+15),"&nbsp;")%></td>
<td class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8), "&nbsp;")%></td>
<td class="thinborder"><%=astrYN[Integer.parseInt((String)vRetResult.elementAt(i+9))]%></td>
<%if(bolIsAUF){%>
<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+28), "&nbsp;")%></td>
<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+29), "&nbsp;")%></td>
<%}%>
<td class="thinborder">
        <% if(iAccessLevel >1){
			if(((String)vRetResult.elementAt(i+10)).equals("0")){//if case is still open%>
				<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'>
					<img src="../../../images/edit.gif" border="0"></a>
				<%if(bolIsAUF){%>
				<a href="javascript:PrintSlips('<%=(String)vRetResult.elementAt(i)%>', '<%=WI.getStrValue((String)vRetResult.elementAt(i+26))%>');">
					<img src="../../../images/print.gif" border="0"></a>
				<a href="javascript:DiagnosticChecklist('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/update.gif" border="0"></a>
				<%}
			}
			
			if(bolIsAUF && ((String)vRetResult.elementAt(i+10)).equals("1"))
				bolShowDelete = false;
			
			if(iAccessLevel == 2){
				if(bolShowDelete){%>
				<a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'>
					<img src="../../../images/delete.gif" border="0"></a>
				<%}else{%>
					&nbsp;
				<%}
			}
		}else{%>
			<font size="1">Not authorized</font>
        <%}%></td>
</tr>
<%}%>
</table>
<%}}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>	
	
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="show_close" value="">
	<input type="hidden" name="case_no" value="<%=strCaseNo%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

