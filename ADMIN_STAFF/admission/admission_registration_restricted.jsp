<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,enrollment.NAApplicationForm,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;
	String strStudStatus = WI.fillTextValue("stud_status");
	if(strStudStatus.length() ==0) strStudStatus="New";


String strSchCode = (String)request.getSession(false).getAttribute("school_code");

if(strSchCode == null) {%>
	<font style="font-size:14px; color:#FF0000; ">You are already logged out. Please login again.</font>
<%return;}


if(strSchCode.startsWith("CIT")){%>
	<jsp:forward page="./admission_registration_cit.jsp" />
<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintBasicInfo(strStudID) {
	var pgLoc = "./admission_registration_print_new_stud.jsp?temp_id="+strStudID;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

	document.offlineRegd.pullStudInfo.value= "1";
	document.offlineRegd.reloadPage.value="1";
}

function OpenSearch() {
<% if(!strStudStatus.equals("New (HS Grad)")) { %>
	var pgLoc = "../../search/srch_stud.jsp?opner_info=offlineRegd.stud_id";
<%}else{%>
	var pgLoc = "../../search/srch_stud.jsp?opner_info=offlineRegd.old_stud_id";
<%}%>

	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

	document.offlineRegd.pullStudInfo.value= "1";
	document.offlineRegd.reloadPage.value="1";
}
function UpdateNationality(table,indexname,colname,labelname){
	var loadPg = "../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
		"&opner_form_name=offlineRegd";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SelPrevCourse()
{
	if(document.offlineRegd.prev_course_ref.selectedIndex > 0)
	{
		document.offlineRegd.prev_course.value =
			document.offlineRegd.prev_course_ref[document.offlineRegd.prev_course_ref.selectedIndex].text;
	}
	document.offlineRegd.prev_course.focus();
}

function AddRecord()
{
	
	if(document.offlineRegd.gender &&  document.offlineRegd.gender.selectedIndex == 0) {
		alert("Please select Gender");
		return;
	}
	if(document.offlineRegd.sch_index &&  document.offlineRegd.sch_index.selectedIndex == 0) {
		alert("Please select Previous School Information");
		return;
	}
	<%if(strSchCode.startsWith("VMA") && false){%>
		if(document.offlineRegd.section_name_.selectedIndex == 0) {
			alert("Please select a section.");
			return;
		}
	<%}%>
	
	
	document.offlineRegd.addRecord.value = "1";
	document.offlineRegd.hide_save.src="../../images/blank.gif";
	
	this.SubmitOnce("offlineRegd");
}
function ChangeOfStatus()
{
	document.offlineRegd.pullStudInfo.value= "";
	document.offlineRegd.reloadPage.value="1";
	this.SubmitOnce("offlineRegd");
}
function ReloadPage()
{
	document.offlineRegd.reloadPage.value="1";
	this.SubmitOnce("offlineRegd");
}
//default form submit.
function PullStudInfo()
{
	document.offlineRegd.addRecord.value = "";
	if (document.offlineRegd.stud_id) {
		if(document.offlineRegd.stud_id.value.length ==0) {
			alert("Please enter student ID.");
			document.offlineRegd.pullStudInfo.value = "";
			return;
		}
		else
		{
			document.offlineRegd.pullStudInfo.value= "1";
			document.offlineRegd.reloadPage.value="1";
		}
	}
	if (document.offlineRegd.old_stud_id) {
		if(document.offlineRegd.old_stud_id.value.length ==0) {
			alert("Please enter student ID.");
			document.offlineRegd.pullStudInfo.value = "";
			return;
		}
		else
		{
			document.offlineRegd.pullStudInfo.value= "1";
			document.offlineRegd.reloadPage.value="1";
		}
	}

	this.SubmitOnce("offlineRegd");
}
function ReloadCourseIndex(iStatus)
{

	if (iStatus == 1 && document.offlineRegd.scroll_course.value.length == 0)
		return;
	//if this is for old student, pls give error message and do not proceed.
	if(document.offlineRegd.stud_status.selectedIndex == 2) {
		alert("Please enter Student's ID and click <Proceed>. You can't change the student's course or curriculum year in this page.");
		this.ReloadPage();
		return;
	}
	//course index is changed -- so reset all dynamic fields.
	if(document.offlineRegd.cy_from.selectedIndex > -1)
		document.offlineRegd.cy_from[document.offlineRegd.cy_from.selectedIndex].value = "";
	if(document.offlineRegd.major_index.selectedIndex > -1)
		document.offlineRegd.major_index[document.offlineRegd.major_index.selectedIndex].value = "";

	this.SubmitOnce("offlineRegd");
}
function ClearEntry()
{
	location = "./admission_registration_restricted.jsp?stud_status="+escape(document.offlineRegd.stud_status[document.offlineRegd.stud_status.selectedIndex].text);
}
function UpdateSchoolList()
{
	//pop up here.
	var pgLoc = "../registrar/sub_creditation/schools_accredited.jsp?parent_wnd=offlineRegd";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function DisplaySYTo() {
	var strSYFrom = document.offlineRegd.sy_from.value;
	if(strSYFrom.length == 4)
		document.offlineRegd.sy_to.value = eval(strSYFrom) + 1;
	if(strSYFrom.length < 4)
		document.offlineRegd.sy_to.value = "";
}
/**
function SubmitOnce("offlineRegd") {
	//do not submit the page if page is submitted once.
	if(document.offlineRegd.reload_in_progress.value == 1)
		return;
	document.offlineRegd.reload_in_progress.value = "1";
	document.offlineRegd.submit();
}**/

function ChangeCurYear() {
	var curYrTo = document.offlineRegd.cy_from.selectedIndex;
	curYrTo = eval('document.offlineRegd.cy_to'+curYrTo+'.value');
//	alert(curYrTo);
	document.offlineRegd.cy_to.value = curYrTo;
	this.ReloadPage();
}
function isHavingID() {
	if(document.offlineRegd.is_having_ID.checked) {
		document.offlineRegd.having_ID.style.visibility  = "hidden";
		document.offlineRegd.having_ID.disabled = false;
	}
	else {
		document.offlineRegd.having_ID.value = "";
		document.offlineRegd.having_ID.style.visibility  = "visible";
		document.offlineRegd.having_ID.disabled = true;
	}
}

var calledRef;
//all about ajax - to display student list with same name.
function AjaxMapName(strRef) {
	var strSearchCon = "&search_temp=2";

		calledRef = strRef;
		var strCompleteName;
		if(strRef == "0") {
			strSearchCon = "";

			if(document.offlineRegd.old_stud_id)
				strCompleteName = document.offlineRegd.old_stud_id.value;
			else
				strCompleteName = document.offlineRegd.stud_id.value;
			if(strCompleteName.length <3)
				return;
		}
		else {

			if(!document.offlineRegd.no_auto_disp || document.offlineRegd.no_auto_disp.checked)
				return;
			strCompleteName = document.offlineRegd.lname.value;
			if(strCompleteName.length == 0)
				return;
			if(document.offlineRegd.fname.value.length > 0)
				strCompleteName = strCompleteName+","+document.offlineRegd.fname.value;
		}

		/// this is the point i must check if i should call ajax or not..
		if(this.bolReturnStrEmpty && this.startsWith(this.strPrevEntry,strCompleteName, false) == 0)
			return;
		this.strPrevEntry = strCompleteName;

		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
		//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	if(calledRef == "0") {
		if(document.offlineRegd.old_stud_id)
			document.offlineRegd.old_stud_id.value = strID;
		else
			document.offlineRegd.stud_id.value = strID;

		document.getElementById("coa_info").innerHTML = "";
	}

}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>

<body bgcolor="#D2AE72">
<%
	String strTempId = null;
	
	boolean boolAllowAdvising = true;
	String strUserMsg = null;
	boolean bolShowStudInfo = false; //when proceed is clicked.
	
	Vector vTemp = new Vector();
	String strCourseIndex = null;
	String strMajorIndex = null;
	int i=0; int j=0;

	String strDegreeType = null;
	String[] astrSchYrInfo = null;
	String strSYTo = null; // this is used in

	Vector vStudBasicInfo = null;
//add security here.
	try
	{
		dbOP = new DBOperation();
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
														"Admission","Registration",request.getRemoteAddr(),
														null);
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
//long lStartTime = new java.util.Date().getTime();

SubjectSection SS = new SubjectSection();
OfflineAdmission offlineAdm = new OfflineAdmission();
boolean bolClearEntry = false; // only if page is successful.
Vector vecRetResult = new Vector();
if(request.getParameter("reloadPage") == null || request.getParameter("reloadPage").trim().length() ==0 ||
	request.getParameter("reloadPage").compareTo("1") == 0) //get new temporary id only if it is regenerated.
	strTempId = "";//new NAApplicationForm().generateTempID(dbOP, null);
else
	strTempId = WI.fillTextValue("stud_id");
if(strTempId == null || strTempId.trim().length() ==0)
	strTempId = "";//new NAApplicationForm().generateTempID(dbOP, null);



if(request.getParameter("addRecord") != null && request.getParameter("addRecord").equals("1"))
{//addrecord now.
	if(!offlineAdm.createApplicant(dbOP,request))
		strErrMsg = offlineAdm.getErrMsg();
	else
	{
		strTempId = "";
		strErrMsg = "Student basic information for enrollment process is created successfully. reference ID = ";
		if(offlineAdm.strNewStudTempID != null)
			strTempId += offlineAdm.strNewStudTempID;//ID is different.
		else
			strTempId += request.getParameter("stud_id");
		if(strSchCode.startsWith("CIT"))
			strErrMsg += "<a href=\"javascript:PrintBasicInfo('"+strTempId+"')\">"+strTempId+"</a>";
		else
			strErrMsg += strTempId;
		
		strTempId = "";//new NAApplicationForm().generateTempID(dbOP, null);
		bolClearEntry = true;
	}
}else
{
	if(WI.fillTextValue("pullStudInfo").equals("1"))
		bolShowStudInfo = true;
	
	if(bolShowStudInfo)
	{
		if (!WI.fillTextValue("stud_status").equals("New (HS Grad)"))
			vStudBasicInfo = offlineAdm.getStudentBasicInfo(dbOP, request.getParameter("stud_id"));
		else
			vStudBasicInfo = offlineAdm.getStudentBasicInfo(dbOP, request.getParameter("old_stud_id"));
		
		if(vStudBasicInfo == null) {
		 strErrMsg = offlineAdm.getErrMsg();
		 if(true || strStudStatus.equals("Old") || strStudStatus.equals("New (HS Grad)")) {
		 	dbOP.cleanUP();
			%>
			<font face="Verdana, Arial, Helvetica, sans-serif" size="3">
				Please create student information before enrolling student.</font>
			<%
			return;
		  }
		}
		else if(vStudBasicInfo.elementAt(13).equals("0")) {
			dbOP.cleanUP();
			%>
			<font face="Verdana, Arial, Helvetica, sans-serif" size="3">
				ID entered is TEMPORARY ID. Pls ask assistance of SA System admin.</font>
			<%
			return;
		}
		else {//get the old student index;;
			strUserMsg = new utility.MessageSystem().getSystemMsg(dbOP, (String)vStudBasicInfo.elementAt(12), 2);
			//check if studnet is not allowed to advise.. deny here .. 			
			enrollment.SetParameter sParam = new enrollment.SetParameter();
			boolAllowAdvising = sParam.allowAdvising(dbOP, (String)vStudBasicInfo.elementAt(12), 0d, 
											WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
			if(!boolAllowAdvising)
				strErrMsg = sParam.getErrMsg();
				
			//I have to check if student is blocked.. 
			strTemp = new enrollment.SetParameter().bolStudentIsOnHold(dbOP, (String)vStudBasicInfo.elementAt(12));
			if(strTemp != null) {
				boolAllowAdvising = false;
				strErrMsg = "<font style='color:red;font-size:18px;font-weight:bold'>"+strTemp+"</font>";
			}

		}
	}
}

astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)
{
	dbOP.cleanUP();
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		School year information not found.</font></p>
		<%
		return;
}
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

if(strStudStatus.compareTo("Old") ==0 && vStudBasicInfo != null && vStudBasicInfo.size() > 0)
{
	request.setAttribute("course_index",vStudBasicInfo.elementAt(5));
	request.setAttribute("major_index",vStudBasicInfo.elementAt(6));
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",
									(String)vStudBasicInfo.elementAt(5),"DEGREE_TYPE",
									" and is_valid=1 and is_del=0");
}

if(strDegreeType == null && WI.fillTextValue("course_index").length() > 0
		&& !WI.fillTextValue("course_index").equals("selany")
		&& !WI.fillTextValue("course_index").equals("0")){

	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",
					WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");
}

//System.out.println(new java.util.Date().getTime()- lStartTime);
/**
NAApplicationForm nAF = new NAApplicationForm();
for(int a = 0; a < 1000; ++a){
	System.out.println(nAF.generateTempIDNewFormat(dbOP));
}
**/

%>
<form action="./admission_registration_restricted.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          ADMISSION - REGISTRATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="1%"></td>
	  <td height="25">
<%if(strErrMsg != null){%>
	<strong><font size="3"><%=strErrMsg%></font></strong>
	&nbsp;
<%}%>	  </td>
    </tr>
  </table>

    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(strUserMsg != null){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strUserMsg%></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%}%>
  </table>

  
<%
if(bolShowStudInfo && false && vStudBasicInfo != null){//System.out.println(vStudBasicInfo);
//check if student is having outstanding balance.
	//strTemp = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
	strTemp = (String)vStudBasicInfo.elementAt(12);
	if(strTemp != null) {
	//System.out.println("strTemp : "+strTemp);
	//System.out.println("strSYFrom : "+vStudBasicInfo.elementAt(10));
	//System.out.println("strSYTo : "+vStudBasicInfo.elementAt(11));
	//System.out.println("semester : "+vStudBasicInfo.elementAt(9));
	//System.out.println("Year : "+vStudBasicInfo.elementAt(14));
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	float fOutstanding = //fOperation.calOutStandingCurYr(dbOP, strTemp, (String)vStudBasicInfo.elementAt(10),(String)vStudBasicInfo.elementAt(11),
							//(String)vStudBasicInfo.elementAt(14),(String)vStudBasicInfo.elementAt(9));
						fOperation.calOutStandingOfPrevYearSem(dbOP, strTemp);
	//System.out.println("Outstanding : "+fOutstanding);
	if(fOutstanding > 0f){%>
  <table width="100%" bgcolor="#FFFFFF"><tr><td>
  <table width="50%" bgcolor="#000000"><tr><td bgcolor="#FFFFFF">
	  <font size="4" color="red"><strong>OLD ACCOUNT
        : <%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></td></tr></table>
</td></tr></table>
<%}}
///this is where i have user index of old student. i can call for system message here.
}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(false && strStudStatus.compareTo("New") ==0){%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25" colspan="3">
	<%
	strTemp = WI.fillTextValue("is_having_ID");
	if(strTemp.compareTo("1") ==0 && !bolClearEntry)
		strTemp = " checked";
	else
		strTemp = "";
	%>	  <input type="checkbox" name="is_having_ID" value="1"<%=strTemp%> onClick="isHavingID();">
	Student already has Old ID :
	<input type="text" name="having_ID" class="textbox" value="<%=WI.fillTextValue("having_ID")%>">	</td>
    </tr>
<script language="JavaScript">
this.isHavingID();
</script>
<%}%>
    <tr valign="top">
      <td  width="1%"height="25">&nbsp;</td>
      <td width="8%" height="25">Student Status </td>
      <td width="26%" height="25">
	  	<select name="stud_status" onChange="ChangeOfStatus();" >
<%
if(strStudStatus.equals("Old")){%>
          <option selected>Old</option>
<%}else {%>
          <option>Old</option>
<%}if(strStudStatus.equals("Change Course")){%>
          <option selected value="Change Course">Change Course</option>
<%}else{%>
          <option value="Change Course">Change Course</option>
<%}if(strStudStatus.equals("Second Course(Old stud)")){%>
          <option selected>Second Course(Old stud)</option>
<%}else{%>
          <option>Second Course(Old stud)</option>
<%}%>
      </select>
	  </td>
      <td width="12%" height="25">Student ID :</td>
      <td width="53%" height="25">
<%	if(bolShowStudInfo){
		if (!strStudStatus.equals("New (HS Grad)")){
			strTemp = WI.fillTextValue("stud_id");
		}else{
			strTemp = WI.fillTextValue("old_stud_id");
		}
	}else
		strTemp = "";



if(strStudStatus.equals("Old") || strStudStatus.equals("Change Course") ||
	strStudStatus.equals("Second Course(Old stud)") || strStudStatus.equals("New (HS Grad)")){

	if (!strStudStatus.equals("New (HS Grad)")){
%>
<input type="text" name="stud_id" size="16" maxlength="32" value="<%=strTemp%>"
 class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
 onKeyUp="AjaxMapName('0');"> <br>
		<label id="coa_info"></label>
<%}else{%>
<input type="text" name="old_stud_id" size="16" maxlength="32" value="<%=strTemp%>"
 class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
 onKeyUp="AjaxMapName('0');">
 <input type="hidden" name="stud_id" value="abcd<%//=strTempId%>"><br>
		<label id="coa_info"></label>
<%}%>
  <a href="javascript:OpenSearch();"><img src="../../images/search.gif" width="30" height="24" border="0" ></a>
        &nbsp;&nbsp;<a href="javascript:PullStudInfo();"><img src="../../images/form_proceed.gif" width="81" height="21" border="0"></a>
        <%}else {%> <strong><%//=strTempId%>
        <font color="#FF0000"> (temp ID will be given after saving info.)</font></strong>
        <input type="hidden" name="stud_id" value="abcd<%//=strTempId%>">
      <%}%>

	</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(strSchCode.startsWith("FATIMA")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:13px; font-weight:bold; color:#CC0033">
<%
strTemp = WI.fillTextValue("is_graduating");

if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>
        <input type="checkbox" value="1" name="is_graduating" <%=strTemp%>> Is Graduating? </td>
    </tr>
<%}if(strSchCode.startsWith("UC")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:13px; font-weight:bold; color:#CC0033">
<%
strTemp = WI.fillTextValue("is_attcnb");

if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>
        <input type="checkbox" value="1" name="is_attcnb" <%=strTemp%>> Is ATTC/NB? </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:13px; font-weight:bold; color:#CC0033">
<%
strTemp = WI.fillTextValue("regularity_stat");

if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>
	  <input type="checkbox" value="1" name="regularity_stat" <%=strTemp%>> Check if Student is Irregular</td>
    </tr>
<%if(strSchCode.startsWith("VMA") && false){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:13px; font-weight:bold; color:#CC0033">
	  Set Section of Student: 
		<select name="section_name_">
			<option value=""></option>
          <%=dbOP.loadCombo("vma_section.section_name","vma_section.section_name"," from vma_section order by section_name asc", WI.fillTextValue("section_name_"), false)%>
		</select>	  </td>
    </tr>
<%}if(!strStudStatus.equals("Old") && !strStudStatus.equals("New (HS Grad)")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"> <%
strTemp = WI.fillTextValue("is_alien");
if(strTemp.compareTo("1") ==0 && !bolClearEntry)
	strTemp = " checked";
else
	strTemp = "";
%> <input type="checkbox" name="is_alien" value="1"<%=strTemp%>>
        <font color="#6600FF" size="2"><strong>Check and specify if student is
        a FOREIGN NATIONAL </strong></font> <select name="nationality">
          <option value=""></option>
          <%=dbOP.loadCombo("ALIEN_NATIONALITY_INDEX","NATIONALITY"," from NA_ALIEN_NATIONALITY order by NATIONALITY asc", strTemp, false)%> </select> <a href='javascript:UpdateNationality("NA_ALIEN_NATIONALITY","ALIEN_NATIONALITY_INDEX","NATIONALITY","NATIONALITY");'>
        <img src="../../images/update.gif" border="0"></a><font size="1"> Update
        Nationality</font> </td>
    </tr>
    <%}%>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td>Course Program(Optional to select)</td>
      <td>
	  <%if(strStudStatus.equals("Old")){%>
	  <input type="checkbox" name="is_returnee" value="1">
      <font style="font-size:14px; color:#0000FF; font-weight:bold">Is Student Returnee?</font>
	  <%}%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><select name="cc_index" onChange="ReloadPage();">
          <option value="0">Select a Program</option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc",
		  								WI.fillTextValue("cc_index"), false)%>
          </select>      </td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="61%">Course :
        <input type="text" name="scroll_course" size="16" style="font-size:12px"
		  onKeyUp="AutoScrollList('offlineRegd.scroll_course','offlineRegd.course_index',true);"
		   onBlur="ReloadCourseIndex(1)" class="textbox">
		   <font size="1">(enter course code to scroll course list)</font></td>
      <td width="37%">Cur. Year:
        <select name="cy_from" onChange="ChangeCurYear();">
          <%
//get here school year
/*
if(bolShowStudInfo && vStudBasicInfo!= null && vStudBasicInfo.size() >0 &&
	(WI.fillTextValue("stud_status").compareTo("Change Course") !=0 || WI.fillTextValue("course_index").compareTo("0") ==0) )
*/
if( bolShowStudInfo && vStudBasicInfo!= null && vStudBasicInfo.size() >0 &&
	!WI.fillTextValue("stud_status").equals("Change Course") &&
	!WI.fillTextValue("stud_status").equals("New (HS Grad)") &&
	(!WI.fillTextValue("stud_status").equals("Second Course(Old stud)") ||
		WI.fillTextValue("course_index").equals("0")) )

	vTemp = SS.getSchYear(dbOP,(String)vStudBasicInfo.elementAt(5),(String)vStudBasicInfo.elementAt(6));
else
	vTemp = SS.getSchYear(dbOP, request, true);
if(vTemp == null)
	vTemp = new Vector();
/*
if(bolShowStudInfo && vStudBasicInfo!= null && vStudBasicInfo.size() >0 &&
(WI.fillTextValue("stud_status").compareTo("Change Course") !=0 || WI.fillTextValue("cy_from").length() ==0) )
	strTemp = (String)vStudBasicInfo.elementAt(3);
*/
if( bolShowStudInfo && vStudBasicInfo!= null && vStudBasicInfo.size() >0 &&
	!WI.fillTextValue("stud_status").equals("Change Course") &&
	(!WI.fillTextValue("stud_status").equals("Second Course(Old stud)") ||
	   WI.fillTextValue("course_index").equals("0")) )

	strTemp = (String)vStudBasicInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("cy_from");

for(i = 0, j=0 ; i< vTemp.size();)
{
	if(	((String)vTemp.elementAt(i)).equals(strTemp))
	{%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected>
		  		<%=(String)vTemp.elementAt(i)%> - <%=(String)vTemp.elementAt(i + 1)%>	      </option>
      <% j = i;
	}else{
	%>
        <option value="<%=(String)vTemp.elementAt(i)%>">
				<%=(String)vTemp.elementAt(i)%> - <%=(String)vTemp.elementAt(i + 1)%>		</option>
    <%} // end else
	i = i+2;
} // end for loop

if(vTemp.size() > 0)

	strSYTo = (String)vTemp.elementAt(j+1);
else
	strSYTo = "";

%>
        </select>
        <!--to <b><%=strSYTo%></b>-->
        <input type="hidden" name="cy_to" value="<%=strSYTo%>">
        <%for(i = 0,j=0; i< vTemp.size(); i += 2, ++j) {%>
			<input type="hidden" name="cy_to<%=j%>" value="<%=(String)vTemp.elementAt(i + 1)%>">
        <%}%> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="middle">
	  	<select name="course_index" onChange="ReloadCourseIndex(2);" style="font-size:10px;font-weight:bold">
          <option value="0">Select Course</option>
          <%
if( bolShowStudInfo && vStudBasicInfo!= null && vStudBasicInfo.size() >0 &&
	WI.fillTextValue("stud_status").compareTo("Change Course") !=0 &&
	(WI.fillTextValue("stud_status").compareTo("Second Course(Old stud)") !=0 ||
	WI.fillTextValue("course_index").compareTo("0") ==0) &&
	!WI.fillTextValue("stud_status").equals("New (HS Grad)"))

	strCourseIndex = (String)vStudBasicInfo.elementAt(5);
else
	strCourseIndex = WI.fillTextValue("course_index");

//if course program is selected, then filter course offered displayed else, show all courses offered.
	if (strSchCode.startsWith("UI"))
		strTemp = " and is_offered = 1";
	else
		strTemp = "";


if(WI.fillTextValue("cc_index").length()>0 && !WI.fillTextValue("cc_index").equals("0"))
	strTemp = " from course_offered where IS_DEL=0 and is_valid=1  " + strTemp +
				" and is_visible = 1 and is_offered = 1 and cc_index=" +
				WI.fillTextValue("cc_index") +	" order by course_name asc" ;
else
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1  " + strTemp +
			 " and is_visible = 1 and is_offered = 1 order by course_code asc";
%>
          <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name",strTemp,strCourseIndex, false)%>
	    </select>	  </td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="61%">Major&nbsp; <select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
if(bolShowStudInfo && vStudBasicInfo!= null && vStudBasicInfo.size() >0 &&
	!WI.fillTextValue("stud_status").equals("Change Course") &&
	!WI.fillTextValue("stud_status").equals("New (HS Grad)") &&
	( !WI.fillTextValue("stud_status").equals("Second Course(Old stud)")
		|| WI.fillTextValue("major_index").length() ==0) )
{
	strMajorIndex = (String)vStudBasicInfo.elementAt(6);
}
else
	strMajorIndex = WI.fillTextValue("major_index");

if(strCourseIndex != null && !strCourseIndex.equals("0") && strCourseIndex.length()>0)
{
	strTemp = " from major where is_del=0 and course_index="+strCourseIndex+" order by major_name asc" ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strMajorIndex, false)%>
          <%}%>
        </select></td>
      <td width="37%">&nbsp;</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
	if(strSchCode.startsWith("UC") || (strDegreeType != null && !strDegreeType.equals("4") && !strDegreeType.equals("1"))){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" height="25"> Year level entry</td>
      <td height="25" colspan="4">
	  <select name="year_level">
          <option value="1">1st</option>
    <%
	strTemp = WI.fillTextValue("year_level");

	vTemp = offlineAdm.determineYrLevelOfStud(dbOP,WI.fillTextValue("stud_id"));
	if(vTemp != null && vTemp.size() > 0)
		strTemp = WI.getStrValue((String)vTemp.elementAt(0));

		  if(strTemp.equals("2")){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.equals("4")){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.equals("5")){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.equals("6")){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select>
        <em><font color="#0066FF" size="1">Change year level outstanding if year level displayed is not year level standing of student</font></em></td>
    </tr>
    <%}
		if(strDegreeType != null && strDegreeType.compareTo("3") ==0  ){//System.out.println(vStudBasicInfo);%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Select Prep/Proper</td>
      <td height="25"><select name="prep_prop_stat">
          <option value="1">Preparatory</option>
          <%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
        </select></td>
      <td height="25">&nbsp;</td>
      <td colspan="2"></td>
    </tr>
    <%}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" height="25"> School Year</td>
      <td width="19%">
        <%
	  strTemp = WI.fillTextValue("sy_from");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[0];
	  %>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp=" DisplaySYTo('offlineRegd','sy_from','sy_to')">
        <%
	  strTemp = WI.fillTextValue("sy_to");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[1];
	  %>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
      </td>
      <td width="7%" height="25">Term :</td>
      <td width="56%" colspan="2">
	  <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = astrSchYrInfo[2];
if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.equals("3") && !strSchCode.startsWith("CPU") ){%>
          <option value="3" selected>3rd Sem</option>
          <%}else if(!strSchCode.startsWith("CPU")){%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>
	  </td>
    </tr>
  </table>
  <%

if(strStudStatus == null || strStudStatus.equals("New") || bolShowStudInfo || strStudStatus.equals("Transferee") ||
	strStudStatus.equals("Cross Enrollee") || strStudStatus.equals("Second Course")){

	if (bolShowStudInfo && 	strStudStatus.equals("New (HS Grad)")
			&& vStudBasicInfo!= null && vStudBasicInfo.size() > 0){
%>
	<input type="hidden" value="<%=(String)vStudBasicInfo.elementAt(16)%>" name="gender">
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    <%
if(!bolShowStudInfo){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Gender
        <select name="gender">
			<option value=""></option>
			<%
			strTemp = WI.fillTextValue("gender");
			if(strTemp.equals("M"))
				strErrMsg = " selected";
			else	
				strErrMsg = "";
			%>
					  <option value="M" <%=strErrMsg%>>Male</option>
			<%if(strTemp.equals("F")){%>
					  <option value="F" selected>Female</option>
			<%}else{%>
					  <option value="F">Female</option>
			<%}%>
        </select></td>
      <td valign="bottom">&nbsp;</td>
      <td height="25" valign="bottom">&nbsp;</td>
    </tr>
<%}if(strStudStatus.startsWith("New") ){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom">Previous school::
        <input type="text" name="scroll_school3" size="25" style="font-size:12px"
	  onKeyUp="AutoScrollList('offlineRegd.scroll_school3','offlineRegd.sch_index',true);"
	   class="textbox">
        <a href="javascript:UpdateSchoolList();"><img src="../../images/update.gif" border="0"></a><font size="1">click
      to update schools' list</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom"><select name="sch_index" style="font-size:12px; width:700px">
	  <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME",
		  " from SCH_ACCREDITED where IS_DEL=0 and sch_name not like '%elem%' "+
		  " order by SCH_NAME",WI.fillTextValue("sch_index"),false)%>
        </select></td>
    </tr>
<%}//end of school%>

    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="35%" height="25" valign="bottom">Student last name &nbsp;&nbsp;
	  <%if(!bolShowStudInfo || vStudBasicInfo == null){%>
	  	<input type="checkbox" name="no_auto_disp" value="0">
	  	<font style="font-size:9px;font-weight:bold;color:#0000FF">Stop Auto display</font>
	  <%}%>	  </td>
      <td width="34%" valign="bottom">Student first name </td>
      <td width="30%" height="25" valign="bottom">Student middle name </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">
	 <%
		if(bolShowStudInfo && vStudBasicInfo != null && vStudBasicInfo.size() >0){%>
	 <b><font size="3"><%=(String)vStudBasicInfo.elementAt(2)%></font></b>
	 <% if (strStudStatus.equals("New (HS Grad)")) {%>
		<input name="lname" type="hidden" value="<%=(String)vStudBasicInfo.elementAt(2)%>">
		<%}%>
	<%  }else {
		if(bolClearEntry)
			strTemp = "";
		else
			strTemp = WI.fillTextValue("lname");
	%>
	<input name="lname" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">
        <%}%> </td>
      <td>
 <%
		if(bolShowStudInfo && vStudBasicInfo!= null && vStudBasicInfo.size() >0){%>
			<b><font size="3"><%=(String)vStudBasicInfo.elementAt(0)%></font></b>

		<% if (strStudStatus.equals("New (HS Grad)")) {%>
		<input name="fname" type="hidden" value="<%=(String)vStudBasicInfo.elementAt(0)%>">
		<%}%>


<%
}else {
if(bolClearEntry)
	strTemp = "";
else
	strTemp = WI.fillTextValue("fname");
%>
<input name="fname" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">
<%}%> </td>
      <td height="25"> <%
if(bolShowStudInfo && vStudBasicInfo!= null && vStudBasicInfo.size() >0){%>
	<b><font size="3"><%=WI.getStrValue(vStudBasicInfo.elementAt(1))%></font></b>
	<% if (strStudStatus.equals("New (HS Grad)")) {%>
	<input name="mname" type="hidden" value="<%=WI.getStrValue(vStudBasicInfo.elementAt(1))%>">
	<%}%>
<%
}else {
if(bolClearEntry)
	strTemp = "";
else
	strTemp = WI.fillTextValue("mname");
%> <input name="mname" type="text" size="20" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">
        <%}%> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><label id="coa_info"></label></td>
    </tr>
  </table>

<%}if(strStudStatus.compareTo("Transferee") ==0 || strStudStatus.compareTo("Second Course") ==0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2" height="26"><hr size="1"></td>
    </tr>
    <!--    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom"><font size="1">&lt;the
        top and this when status is TRANSFEREE:delete this row when done&gt;</font></td>
      <td colspan="3" height="25" valign="bottom">&nbsp;</td>
    </tr> -->
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" valign="bottom">Previous school ::
      <input type="text" name="scroll_school" size="25" style="font-size:12px"
	  onKeyUp="AutoScrollList('offlineRegd.scroll_school','offlineRegd.sch_index',true);"
	   class="textbox">
      <a href="javascript:UpdateSchoolList();"><img src="../../images/update.gif" border="0"></a><font size="1">click
      to update schools' list</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom"><select name="sch_index" style="font-size:11px; width:700px">
	  <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL = 0  "+
		  " and sch_name not like  '%elem%' "+
		  " and sch_name not like '%high sch%' order by SCH_NAME",WI.fillTextValue("sch_index"),false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Previous course :
        <select name="prev_course_ref" onChange="SelPrevCourse();">
          <option value="0">Course reference (select or type below)</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc", null, false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom"><input name="prev_course" type="text" size="60" maxlength="90" value="<%=WI.fillTextValue("prev_course")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Major</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><input name="prev_major" type="text" size="60" maxlength="64" value="<%=WI.fillTextValue("prev_major")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
  </table>
<%}if(strStudStatus.compareTo("Change Course") ==0 || strStudStatus.compareTo("Second Course(Old stud)") ==0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3" height="26"><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" valign="bottom">Previous course</td>
      <td height="25" valign="bottom">Previous Major </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="44%" height="25" valign="bottom"><strong>
        <select name="prev_course" onChange="ReloadCourseIndex(2);">
          <option value="0">Select Any</option>
          <%
if(bolShowStudInfo && vStudBasicInfo!= null && vStudBasicInfo.size() >0)
	strCourseIndex = (String)vStudBasicInfo.elementAt(5);
else
	strCourseIndex = WI.fillTextValue("prev_course");

try {
	Integer.parseInt(strCourseIndex);
}catch(Exception e){strCourseIndex = null;}
%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 " +
								 "AND IS_VALID=1 and is_visible = 1 order by course_name asc", strCourseIndex, false)%>
        </select>
        </strong></td>
      <td width="55%" valign="bottom"><select name="select2">
          <option></option>
          <%
if(bolShowStudInfo && vStudBasicInfo!= null && vStudBasicInfo.size() >0)
	strMajorIndex = (String)vStudBasicInfo.elementAt(6);
else
	strMajorIndex = WI.fillTextValue("prev_major");

if(strCourseIndex != null && strCourseIndex.compareTo("0") != 0 && strCourseIndex.length()>0)
{
strTemp = " from major where is_del=0 and course_index="+strCourseIndex+" order by major_name asc" ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strMajorIndex, false)%>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom">Curriculum Year</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <select name="prev_cy_from" onChange="ReloadPage();">
          <%
//get here school year
vTemp = SS.getSchYear(dbOP, strCourseIndex,strMajorIndex);
if(vTemp == null)
	vTemp = new Vector();

if(bolShowStudInfo && vStudBasicInfo!= null && vStudBasicInfo.size() >0)
	strTemp = (String)vStudBasicInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("prev_cy_from");

for(i = 0, j=0 ; i< vTemp.size();)
{
	if(	((String)vTemp.elementAt(i)).compareTo(strTemp) == 0)
	{%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i)%></option>
          <%	j = i;
	}
	else{
	%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i)%></option>
          <%	}
	i = i+2;

}
if(vTemp.size() > 0)
	strSYTo = (String)vTemp.elementAt(j+1);
else
	strSYTo = "";

%>
        </select>
        to <b><%=strSYTo%></b> <input type="hidden" name="prev_cy_to" value="<%=strSYTo%>">
      </td>
    </tr>
  </table>
<%}if(strStudStatus.compareTo("Cross Enrollee") ==0){%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom">Current school::
        <input type="text" name="scroll_school2" size="25" style="font-size:12px"
	  onKeyUp="AutoScrollList('offlineRegd.scroll_school2','offlineRegd.sch_index',true);"
	   class="textbox">
        <a href="javascript:UpdateSchoolList();"><img src="../../images/update.gif" border="0"></a><font size="1">click
      to update schools' list</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom"><select name="sch_index" style="font-size:11px;width:750px">
	  <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",WI.fillTextValue("sch_index"),false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">Course</td>
      <td valign="bottom">Major </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><input name="cur_course" type="text" size="40" maxlength="128" value="<%=WI.fillTextValue("cur_course")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td height="25"> <input name="cur_major" type="text" size="40" maxlength="128" value="<%=WI.fillTextValue("cur_major")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp; </td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <%
if(WI.fillTextValue("stud_status").startsWith("New") || WI.fillTextValue("stud_status").length() ==0){%>
    <tr>
      <td height="25" colspan="9"><strong><font color="#000099">NOTE : Curriculum
        year must always be the latest curriculum year for all new students</font></strong></td>
    </tr>
    <%}%>
    <tr>
      <td height="23" colspan="9">&nbsp;
<%
boolean bolShow = false;
if(strSchCode.startsWith("CPU") || strSchCode.startsWith("CLDH"))
	bolShow = true;
	//bolShow = true;

if (bolShow &&
			(WI.fillTextValue("stud_status").compareToIgnoreCase("old") == 0  ||
			 WI.fillTextValue("stud_status").compareToIgnoreCase("change course") == 0)   &&
			vStudBasicInfo != null ) {
		//long lStartTime = new java.util.Date().getTime();
		enrollment.AdvisingExtn adv = new enrollment.AdvisingExtn();
		Vector vDropIncFail = adv.countFailDropCPU(dbOP, WI.fillTextValue("stud_id"));
		//System.out.println(new java.util.Date().getTime() - lStartTime);

%>
	<table width="60%" border="0" align="center"  cellpadding="0" cellspacing="0">
	<tr>
		<td width="27%">
			<img src="../../upload_img/<%=WI.fillTextValue("stud_id")%>.jpg" width="125" height="125" />
		</td>
		<td width="73%" valign="top">
		<% if (vDropIncFail!= null && vDropIncFail.size()>0)  {%>

		<table width="80%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr>
            <td width="43%" height="25" class="thinborder"> &nbsp;REMARKS </td>
            <td width="57%" class="thinborder">&nbsp;NUMBER OF TIMES</td>
          </tr>
	<% for ( i = 0; i < vDropIncFail.size(); i+=2) {%>
          <tr>
            <td height="25" class="thinborder">&nbsp;<strong><%=(String)vDropIncFail.elementAt(i)%></strong> </td>
            <td class="thinborder">&nbsp;<%=(String)vDropIncFail.elementAt(i+1)%></td>
          </tr>
	<% }%>
        </table>
	<%}else{%>
		<font size="2" color="#0000FF"> <strong> &nbsp;&nbsp;&nbsp;Student is of Good Standing</strong></font>
	<%}%>		</td>
	    </tr>
	<tr>
		<td colspan=2>&nbsp;  </td>
	</tr>
	</table>

<%}%>

	  </td>
    </tr>
    <tr>
      <td height="23" colspan="9">&nbsp;</td>
    </tr>
    <%
boolean bolShowSave = true;
if(!boolAllowAdvising)
	bolShowSave = false;
else {	
	if(strStudStatus.equals("Old") || strStudStatus.equals("Change Course") ||
		strStudStatus.equals("New (HS Grad)")) {
	
		if(!bolShowStudInfo || vStudBasicInfo == null || vStudBasicInfo.size() == 0){
			bolShowSave = false;
			strErrMsg = "Please enter student ID and click proceed.";
		}
	}
}
if(bolShowSave){%>
    <tr>
      <td height="25" colspan="7">&nbsp;</td>
      <td width="26%" height="25"><a href="javascript:AddRecord();"> <img src="../../images/save.gif" border="0" name="hide_save"></a>
        <font size="1" >click to save entries</font></td>
      <td width="53%" height="25"><a href="javascript:ClearEntry();"><img src="../../images/clear.gif" width="55" height="19" border="0"></a>
        <font size="1" >click to clear entries</font></td>
    </tr>
<%}else {%>
    <tr>
      <td height="25" colspan="7">&nbsp;</td>
      <td height="25" colspan="2"><%=strErrMsg%></td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="pullStudInfo" value="<%=WI.fillTextValue("pullStudInfo")%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="degreeType" value="<%=WI.getStrValue(strDegreeType)%>">

<input type="hidden" name="reload_in_progress">

<input type="hidden" name="from_placement_exam" value="<%=WI.fillTextValue("from_placement_exam")%>">
<input type="hidden" name="remove_old" value="<%=WI.fillTextValue("remove_old")%>"><!-- Set for UDMC -->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
