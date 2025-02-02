<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector, java.util.Date" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String strInfo5 = (String)request.getSession(false).getAttribute("info5");
if(strSchCode == null)
	strSchCode = "";
if(strInfo5 == null)
	strInfo5 = "";

boolean bolIsCIT = strSchCode.startsWith("CIT");


boolean bolShowDateRange = false;
boolean bolShowDontCheckConflict = false;
if(strInfo5.equals("SEACREST"))
	bolShowDateRange = true;
if(strInfo5.equals("SEACREST"))
	bolShowDontCheckConflict = true;

//for swu, if maritime college, i have to show both.. 
if(strSchCode.startsWith("SWU")){
	strTemp = WI.fillTextValue("course_index");
	if(strTemp.equals("204") || strTemp.equals("205") || strTemp.equals("206") || strTemp.equals("207")) {
		bolShowDateRange = true;
		bolShowDontCheckConflict = true;
	}
}

		
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Subject Section Scheduling Page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function CheckValidHour(strIsIn) {
	var vTime =document.ssection.time_from_hr.value 
	if(strIsIn == '2')
		vTime =document.ssection.time_to_hr.value 
		
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		if(strIsIn == '1')
			document.ssection.time_from_hr.value = "12";
		else	
			document.ssection.time_to_hr.value = "12";
	}
/**
	var vTime2 =document.ssection.time_to_hr.value 
	if(eval(vTime2) > 12 || eval(vTime2) == 0) {
		alert("Time should be >0 and <= 12");
		document.ssection.time_to_hr.value = "12";
	}
**/
	
	<%if(bolIsCIT){//must %>	
		//alert(eval(vTime1));
		if(eval(vTime) == 12 || eval(vTime) < 7) {//it is PM
			if(strIsIn == '1') {
				document.ssection.time_from_AMPM.selectedIndex = 1;
				document.ssection.time_to_AMPM.selectedIndex = 1;
			}
			else 
				document.ssection.time_to_AMPM.selectedIndex = 1;
		}
		else {
			if(strIsIn == '1')
				document.ssection.time_from_AMPM.selectedIndex = 0;
			else {
				document.ssection.time_to_AMPM.selectedIndex = 0;
				if(document.ssection.time_from_AMPM.selectedIndex == 1)
					document.ssection.time_to_AMPM.selectedIndex = 1;
			}
		}
	<%}%>
}
function CheckValidMin() {
	if(eval(document.ssection.time_from_min.value) > 59) {
		alert("Time can't be > 59");
		document.ssection.time_from_min.value = "00";
	}
	if(eval(document.ssection.time_to_min.value) > 59) {
		alert("Time can't be > 59");
		document.ssection.time_to_min.value = "00";
	}
}
function ChangeCurYr() {
	document.ssection.showsubject.value = 0;
	this.ReloadPage();
}
function Test() {
	alert(event.keyCode);
}
function PopupEditSection()
{
	var strSYFrom 	= document.ssection.school_year_fr.value;
	var strSYTo   	= document.ssection.school_year_to.value;
	var strSemester = document.ssection.offering_sem.value;
	var strSemName  = document.ssection.offering_sem_name.value;

	if(strSYFrom.length ==0)
	{
		alert("Please enter offering year from.");
		return;
	}
	if(strSYTo.length ==0)
	{
		alert("Please enter offering year to.");
		return;
	}
	if(strSemester.length ==0)
	{
		alert("Please enter offering semester.");
		return;
	}
	var pgLoc = "./edit_section.jsp?sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+strSemester+"&semester_inword="+
				escape(strSemName);
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//this is called when section is selected from drop downlist.
function SelectSection()
{
	document.ssection.section.value = document.ssection.select_section[document.ssection.select_section.selectedIndex].value;
	this.ReloadPage();
}
function ChangeScheduleFormat()
{
	document.ssection.showweeklyschedule.value="";
	ReloadPage();
}
//call this to view course curriculum in detail.
function ViewAll()
{
	var strCName = document.ssection.course_index[document.ssection.course_index.selectedIndex].text;
	var strCIndex = document.ssection.course_index[document.ssection.course_index.selectedIndex].value;

	var strMName = document.ssection.major_index[document.ssection.major_index.selectedIndex].text;
	var strMIndex = document.ssection.major_index[document.ssection.major_index.selectedIndex].value;

	var strSYFrom = document.ssection.sy_from.value;
	var strSYTo = document.ssection.sy_to.value;

	if(document.ssection.course_index.selectedIndex <= 0)
	{
		alert("Please select a course.");
		return;
	}
	if(document.ssection.sy_from.value == null || document.ssection.sy_from.length ==0)
	{
		alert("Please enter <SY From> to view detail course curriculum.");
		return;
	}
	if(document.ssection.sy_to.value == null || document.ssection.sy_to.length ==0)
	{
		alert("Please enter <SY To> to view detail course curriculum.");
		return;
	}

	if(document.ssection.major_index.selectedIndex == 0) //major index is null
	{
		location = "./curriculum_maintenance_viewall.jsp?ci="+strCIndex+"&cname="+escape(strCName)+
			"&syf="+strSYFrom+"&syt="+strSYTo;
	}
	else
	{
		location = "./curriculum_maintenance_viewall.jsp?ci="+strCIndex+"&cname="+escape(strCName)+
			"&syf="+strSYFrom+"&syt="+strSYTo+"&mi="+strMIndex+"&mname="+escape(strMName);
	}
	this.ReloadPage();
}
function AddRecord()
{
	document.ssection.addRecord.value = 1;
	document.ssection.offer.value='';
}
function ValidateEntry() {
	<%if(!bolIsCIT) {%>
		return;
	<%}%>
	if(document.ssection.addRecord.value == 1) {
		if(document.ssection.c_index_sel.selectedIndex == 0) {
			document.ssection.addRecord.value = '';
			alert("Please select offering information.");
			return false;
		}
	}
	
}

function MixSchedule() {
	
	if(!document.ssection.ref_sub_sch_index || document.ssection.ref_sub_sch_index.selectecIndex == 0) {
		alert("Please select a parent subject to mix/merge.");
		return;
	}
	
	document.ssection.mixSchedule.value ="1";
	document.ssection.addRecord.value = 1;
	document.ssection.offer.value='';
	document.ssection.submit();
}
function ReloadCourseIndex()
{
	var strDegreeType = document.ssection.degreeType.value;

	document.ssection.addRecord.value = 0;
	document.ssection.showsubject.value = 0;
	//course index is changed -- so reset all dynamic fields.
	if(document.ssection.sy_from.selectedIndex > -1)
		document.ssection.sy_from[document.ssection.sy_from.selectedIndex].value = "";
	if(document.ssection.major_index.selectedIndex > -1)
		document.ssection.major_index[document.ssection.major_index.selectedIndex].value = "";
	if(strDegreeType.length > 0 && strDegreeType != "1" && strDegreeType != "4")
	{
		if(document.ssection.year.selectedIndex > -1)
			document.ssection.year[document.ssection.year.selectedIndex].value = "";
		if(document.ssection.semester.selectedIndex > -1)
			document.ssection.semester[document.ssection.semester.selectedIndex].value = "";
	}

	this.ReloadPage();
}
function ShowSubject()
{
	document.ssection.showsubject.value = 1;
	document.ssection.addRecord.value = 0;
	document.ssection.offer.value='';
}
function ChangeOfferingSem()
{
	document.ssection.offering_sem_name.value = document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value;
	document.ssection.offer.value='';
}
function changeResOfferingType()
{
	document.ssection.showsubject.value = "";
	document.ssection.offer.value="";

	ReloadPage();
}
function ReloadPage()
{
	if(document.ssection.reload_in_progress.value == 1)
		return;
	document.ssection.offer.value='';
	document.ssection.reload_in_progress.value = "1";
	document.ssection.addRecord.value = 0;
	document.ssection.submit();
}
//strReloadStat == 1 -> reload the page.
function SubjectOffered(strReloadStat)
{
	if(document.ssection.showsubject.value != 1) 
		return;
	var i = document.ssection.subject_offered.selectedIndex;
	if( i < 1)//reset values.
	{
		if(document.ssection.subject_category)
			document.ssection.subject_category.value= "";
		document.ssection.cur_index.value= "";
	}
	else
	{
		if(document.ssection.subject_category)
			document.ssection.subject_category.value= eval('document.ssection.subject_category'+(i-1)+'.value');
		document.ssection.cur_index.value= eval('document.ssection.cur_index'+(i-1)+'.value');
		if( eval('document.ssection.is_lec'+(i-1)+'.value') == 1)
			document.ssection.is_lec.disabled=false;
		else
			document.ssection.is_lec.disabled=true;
	}
	if(strReloadStat == 1) {	
		this.ReloadPage();
	}


	/*if(document.ssection.select_section.selectedIndex > -1)
	{
		document.ssection.select_section.selectedIndex = 0;
		document.ssection.section.value = "";
	}*/
}
//call this to reload the page if necessary
function ReloadIfNecessary()
{
	if(document.ssection.showsubject.value == 1)
	{
		this.ReloadPage();
	}
}

function ShowWeeklySchedule()
{
	document.ssection.showweeklyschedule.value = 1;
}
/*function changeSubject()
{
	document.ssection.addRecord.value = 0;
	document.ssection.changeCourse.value = 0;
	document.ssection.changeSubject.value = 1;

	document.ssection.submit();
}*/

/**
*	Call this function to view sction detail of a course curriculum.
*/
function ViewSection(strViewOneSection) {
	if(strViewOneSection.length > 0) 
		strViewOneSection = "&print_section="+escape(document.ssection.section.value);
		
	var strDegreeType = document.ssection.degreeType.value;
	var strPrepPropStat = "0";
	if(strDegreeType == "3")//with proper
		strPrepPropStat = document.ssection.prep_prop_stat[document.ssection.prep_prop_stat.selectedIndex].value;
	if(strDegreeType.length > 0 && strDegreeType == "100")//in case of reserve subjects.
	{
		location = "./subj_sectioning_view.jsp?degreeType=100&res_offering=1&school_year_fr="+
				document.ssection.school_year_fr.value+"&school_year_to="+
				document.ssection.school_year_to.value+"&offering_sem="+document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value+
				strViewOneSection;
	}
	else if(strDegreeType.length > 0 && strDegreeType != "1" && strDegreeType != "4")
	{
		location = "./subj_sectioning_view.jsp?course_index="+document.ssection.course_index[document.ssection.course_index.selectedIndex].value+"&major_index="+
				document.ssection.major_index[document.ssection.major_index.selectedIndex].value+"&sy_from="+
				document.ssection.sy_from[document.ssection.sy_from.selectedIndex].value+"&sy_to="+
				document.ssection.sy_to.value+"&year="+
				document.ssection.year[document.ssection.year.selectedIndex].value+"&semester="+
				document.ssection.semester[document.ssection.semester.selectedIndex].value+"&school_year_fr="+
				document.ssection.school_year_fr.value+"&school_year_to="+
				document.ssection.school_year_to.value+"&offering_sem="+
				document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value+"&prep_prop_stat="+strPrepPropStat+
				strViewOneSection;
	}
	else
	{
		location = "./subj_sectioning_view.jsp?course_index="+document.ssection.course_index[document.ssection.course_index.selectedIndex].value+"&major_index="+
				document.ssection.major_index[document.ssection.major_index.selectedIndex].value+"&sy_from="+
				document.ssection.sy_from[document.ssection.sy_from.selectedIndex].value+"&sy_to="+
				document.ssection.sy_to.value+"&school_year_fr="+
				document.ssection.school_year_fr.value+"&school_year_to="+
				document.ssection.school_year_to.value+"&offering_sem="+
				document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value+strViewOneSection;
	}

}
function Offer()
{
	document.ssection.offer.value="1";
}
function disableLec() {//call this only if subject is having either lec or lab but not mixed
	document.ssection.is_lec.selectedIndex = 0;
	document.ssection.is_lec.disabled = true;
}


function loadDept() {
	var objCOA=document.getElementById("load_dept");
	var objCollegeInput = document.ssection.c_index_sel[document.ssection.c_index_sel.selectedIndex].value;
	
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	///if blur, i must find one result only,, if there is no result foud
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index_sel&all=1";
	//alert(strURL);
	this.processRequest(strURL);
}
function ResetToLecSel() {
	if(document.ssection.is_lec) {
		if(document.ssection.is_lec.selectedIndex == 1) 
			document.ssection.is_lec.selectedIndex = 0;
	}


}

function SetTBA() {
	if(document.ssection.is_tba.checked) {
		document.ssection.week_day.value='S';
		document.ssection.time_from_hr.value='0';
		document.ssection.time_from_min.value='0';
		document.ssection.time_from_AMPM.selectedIndex = 0;
		
		document.ssection.time_to_hr.value='0';
		document.ssection.time_to_min.value='0';
		document.ssection.time_to_AMPM.selectedIndex = 0;
		
		var roomList = document.getElementById('room_i');
		var iLen = roomList.options.length;
		for(var i = 0; i < iLen; ++i) {
			if(roomList.options[i].text == 'BY ARR' || roomList.options[i].text == 'TBA') {
				roomList.options.selectedIndex = i;
				break;
			}
		}
		
		
	}
	else {
		document.ssection.week_day.value='';
		document.ssection.time_from_hr.value='';
		document.ssection.time_from_min.value='';
		
		document.ssection.time_to_hr.value='';
		document.ssection.time_to_min.value='';
	}
	
}
function autoScrollCourse()
{

	if (document.ssection.scroll_course.value.length == 0)
		return;
	this.ReloadCourseIndex();
}
</script>

<body bgcolor="#D2AE72" onLoad='SubjectOffered("0");'>
<%
	Vector vTemp = new Vector();
	int i = -1;
	int j=0;
	String strSYTo = null; // this is used in
	String strCurIndex = null;
	String strCurIndex0 = null;
	Vector vIsCommonSection = null;
	Vector vIsSubOffered  = null;
	Vector vIsSubOfferedInOthCur = null;
	Vector vAuthorizedColInfo = null;
	boolean bolFatalErr = false;

	//this is necessary for different types of subject offering.
	//degree_type=0->UG,1->Doctoral,2->medicine,3->with prep proper, 4-> care giver.
	//for care giver,doctoral, do not show year level, for prep_prop, show prep/prop status.
	String strDegreeType = null;

	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","1st Term","2nd Term","3rd Term","4th Term","5th Term"};


	String strCollegeIndex = null;
	String strCollegeName  = null;
	String strDeptIndex    = null;
	String strDeptName     = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-subject sectioning","subj_sectioning.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		strTemp = "<form name=ssection><input type=hidden name=showsubject></form>";
		%><%=strTemp%><%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"subj_sectioning.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	if(!response.isCommitted())
		response.sendRedirect("../../../commfile/fatal_error.jsp");
	else
	%>
		<script language="JavaScript">
		location = "../../../commfile/fatal_error.jsp";
		</script>
	<%
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	if(!response.isCommitted())
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	else
	%>
		<script language="JavaScript">
		location = "../../../commfile/unauthorized_page.jsp";
		</script>
	<%
	return;
}

//end of authenticaion code.
if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("selany") != 0)
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");
if(WI.fillTextValue("res_offering").compareTo("1") ==0)
	strDegreeType = "100";

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
SubjectSection SS = new SubjectSection();

strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(SS.addSection(dbOP,request))
	{
		strErrMsg = "Subject offered successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=SS.getErrMsg()%></font></p>
		<%
		strTemp = "<form name=ssection><input type=hidden name=showsubject></form>";
		%><%=strTemp%><%
		return;
	}
}
else if(WI.fillTextValue("offer").compareTo("1") ==0)//check here if copy from common offer subject is clicked.
{
	if(SS.copyCommonSecSchedule(dbOP,request))
		strErrMsg = "Subject offered successfully.";
	else
	{
		strErrMsg = SS.getErrMsg();
		bolFatalErr = true;
	}
}
else
	vIsCommonSection = SS.checkIfCommonSection(dbOP,request.getParameter("subject_offered"),request.getParameter("section"),
	        request.getParameter("school_year_fr"),request.getParameter("school_year_to"),request.getParameter("offering_sem"),
			request.getParameter("is_lec"));
//System.out.println(vIsCommonSection);
boolean bolIsCPSU = false;//if class program super user.. 
String strSQLQuery = null;
java.sql.ResultSet rs = null;


bolIsCPSU = new enrollment.SetParameter().bolIsCPSU(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
vAuthorizedColInfo = comUtil.getAuthorizedCollegeInfo(dbOP,(String)request.getSession(false).getAttribute("userId"));
if(!bolIsCPSU && vAuthorizedColInfo == null)
{
	strErrMsg = comUtil.getErrMsg();
	bolFatalErr = true;
}
if(bolIsCPSU && WI.fillTextValue("c_index_sel").length() > 0) {
	strSQLQuery = "select c_name from college where c_index = "+WI.fillTextValue("c_index_sel");
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	
	vAuthorizedColInfo = new Vector();
	vAuthorizedColInfo.addElement(strSQLQuery);
	vAuthorizedColInfo.addElement(WI.fillTextValue("c_index_sel"));
	if(WI.fillTextValue("d_index_sel").length() > 0) {
		strSQLQuery = "select d_name from department where d_index = "+WI.fillTextValue("d_index_sel");
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		
		vAuthorizedColInfo.addElement(strSQLQuery);
		vAuthorizedColInfo.addElement(WI.fillTextValue("d_index_sel"));
	}
	else {
		vAuthorizedColInfo.addElement(null);
		vAuthorizedColInfo.addElement(null);
	}
}


//if(!bolFatalErr && WI.fillTextValue("course_index").length()>0 && WI.fillTextValue("course_index").compareTo("0") != 0 &&
//	WI.fillTextValue("subject_offered").length()>0 && WI.fillTextValue("subject_offered").compareTo("selany") != 0)
{

/**
	vIsSubOfferedInOthCur = SS.checkIfSectionOfferedForSameCur(dbOP, WI.fillTextValue("course_index"),WI.fillTextValue("major_index"),
								WI.fillTextValue("subject_offered"), WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),
								request.getParameter("school_year_fr"),request.getParameter("school_year_to"),
								request.getParameter("offering_sem"));
	if(vIsSubOfferedInOthCur != null && vIsSubOfferedInOthCur.size() > 0)//removing this check.
	{
		bolFatalErr = true;
		if(vIsSubOfferedInOthCur != null && vIsSubOfferedInOthCur.size() > 0)
		{
			strErrMsg = "Subject already offered for curriculum year "+(String)vIsSubOfferedInOthCur.elementAt(0)+"-"+(String)vIsSubOfferedInOthCur.elementAt(1)+
			". Please use the same curriculum year to offer for other section or delete the offering to offer for "+request.getParameter("sy_from")+"-"+
			request.getParameter("sy_to");
		}
		else
			strErrMsg = SS.getErrMsg();
	}//System.out.println(vIsSubOfferedInOthCur);
**/
}

if(!bolFatalErr && WI.fillTextValue("showsubject").compareTo("1") ==0)
{
	//check if subject is already offered.
	vIsSubOffered = SS.checkIfSectionOffered(dbOP,request.getParameter("cur_index"),request.getParameter("section"),
					request.getParameter("is_lec"),request.getParameter("school_year_fr"),request.getParameter("school_year_to"),
					request.getParameter("offering_sem"),request.getParameter("subject_offered"));

	//get the college/dept offering the course if it is already offered, else = get from vAuthorizedColInfo
	if(vIsSubOffered != null && vIsSubOffered.size() > 0)
	{
		strCollegeIndex = (String)vIsSubOffered.elementAt(2);
		strCollegeName  = (String)vIsSubOffered.elementAt(3);
		strDeptIndex    = (String)vIsSubOffered.elementAt(4);
		strDeptName     = (String)vIsSubOffered.elementAt(5);
	}
	else if(vIsCommonSection != null && vIsCommonSection.size() > 0)
	{//System.out.println(vIsCommonSection);
		//strCollegeIndex = (String)vIsCommonSection.elementAt(3); - i HAVE TO ALLOW THE OFFERING TO BE DELETED BY THE CHILD OFFERING
		strCollegeIndex = (String)vAuthorizedColInfo.elementAt(1);
		strCollegeName  = (String)vIsCommonSection.elementAt(4);
		strDeptIndex    = (String)vIsCommonSection.elementAt(5);
		strDeptName     = (String)vIsCommonSection.elementAt(6);
	}
	else if(vAuthorizedColInfo != null && vAuthorizedColInfo.size() > 0)
	{
		strCollegeIndex = (String)vAuthorizedColInfo.elementAt(1);
		strCollegeName  = (String)vAuthorizedColInfo.elementAt(0);
		strDeptIndex    = (String)vAuthorizedColInfo.elementAt(3);
		strDeptName     = (String)vAuthorizedColInfo.elementAt(2);
	}
}
if(!bolFatalErr)
{
	astrSchYrInfo = dbOP.getCurSchYr();
	if(astrSchYrInfo == null)//db error
	{
		strErrMsg = dbOP.getErrMsg();
		bolFatalErr = true;
	}
}//if !bolFatalErr

boolean bolIsRoomOwnerShipForced = false;
if(new utility.ReadPropertyFile().readProperty(dbOP, "ROOM_OWNERSHIP","0").equals("1")) 
	bolIsRoomOwnerShipForced = true;

%>

<form name="ssection" action="./subj_sectioning.jsp" method="post" onSubmit="return ValidateEntry();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          CLASS PROGRAMS - NEW CLASS PROGRAMS/SECTIONS PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(strErrMsg != null) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <font size="3"><b><%=strErrMsg%></b></font>      </td>
    </tr>
<%} if(bolFatalErr){
	dbOP.cleanUP();//System.out.println(" I am here");
strTemp = "<input type=hidden name=showsubject></form>";
		%>
    <%=strTemp%>
    <%
	return;
}%>
    <tr>
      <td height="4">&nbsp;</td>
      <td height="25" valign="bottom" > 
        <%if(WI.fillTextValue("res_offering").compareTo("1") ==0)
			strTemp = "checked";
		else
			strTemp = "";
		%>
        <input type="checkbox" name="res_offering" <%=strTemp%> value="1" onClick="changeResOfferingType();">
        Check for International/Additional subject offerings/schedules (offerings 
        for all courses) </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
<%if(bolIsCPSU) {%>
    <tr>
      <td height="4">&nbsp;</td>
      <td colspan="2" valign="bottom" >Offering College: 
	  <select name="c_index_sel" onChange="loadDept();">
	  <option value=""></option>
	  <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", WI.fillTextValue("c_index_sel"), false)%>
	  </select>
	  </td>
    </tr>
    <tr>
      <td height="4">&nbsp;</td>
      <td colspan="2" valign="bottom" >Offering Department: 
<label id="load_dept">
<%if(WI.fillTextValue("c_index_sel").length() > 0) {%>
	  <select name="d_index_sel">
          <option value=""></option>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index = "+WI.fillTextValue("c_index_sel")+" order by d_name asc",WI.fillTextValue("d_index_sel"), false)%>
        </select>
<%}%>
</label>	  
	  </td>
    </tr>
<%}
if(strSchCode.startsWith("PHILCST") || strSchCode.startsWith("EAC")){%>
	 <tr>
      <td height="4">&nbsp;</td>
      <td height="25" valign="bottom" style="font-size:14px; color:#0000FF; font-weight:bold">Please enter Offering CODE :
        <input type="text" name="offering_count" value="<%=WI.fillTextValue("offering_count")%>" size="12" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom">&nbsp;</td>
    </tr>
<%}
if(WI.fillTextValue("res_offering").compareTo("1") !=0){%>

    <tr>
      <td height="4">&nbsp;</td>
      <td height="25" valign="bottom" >Course Program(Optional to
        select) :
        <select name="cc_index" onChange="document.ssection.offer.value='';ReloadPage();">
          <option value="0">Select a Program</option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc", request.getParameter("cc_index"), false)%>
        </select></td>
      <td valign="bottom">&nbsp; </td>
    </tr>
    <tr>
      <td width="2%" height="4">&nbsp;</td>
      <td height="25" valign="bottom" >Offerings for course
	  
	  <input type="text" name="scroll_course" size="16" style="font-size:12px"
		  onKeyUp="AutoScrollList('ssection.scroll_course','ssection.course_index',true);"
		   onBlur="autoScrollCourse()" class="textbox">
	  
	  </td>
      <td width="36%" valign="bottom">Curriculum Year </td>
    </tr>
    <tr>
      <td width="2%" height="3">&nbsp;</td>
      <td><select name="course_index" onChange="document.ssection.offer.value='';ReloadCourseIndex();" style="font-size:12px; width:500px">
          <option value="0">Select Any</option>
          <%
//if course program is selected, then filter course offered displayed else, show all courses offered.
if(WI.fillTextValue("cc_index").length()>0 && WI.fillTextValue("cc_index").compareTo("0") != 0)
{
	strTemp = " from course_offered where IS_DEL=0 and is_valid=1 and cc_index="+request.getParameter("cc_index")+
		  	" order by course_name asc" ;
}
else
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_code, course_name",strTemp, WI.fillTextValue("course_index"), false)%>
        </select></td>
      <td><select name="sy_from" onChange="document.ssection.offer.value='';ChangeCurYr();">
          <%
//get here school year
vTemp = SS.getSchYear(dbOP, request);
strTemp = request.getParameter("sy_from");//System.out.println(strTemp);
if(strTemp == null) strTemp = "";

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
        to <b><%=strSYTo%></b> <input type="hidden" name="sy_to" value="<%=strSYTo%>">      </td>
    </tr>
    <tr>
      <td width="2%" height="6">&nbsp;</td>
      <td height="25" valign="bottom">Major </td>
      <td valign="bottom">
        <%if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
        Year and Term
        <%}%>      </td>
    </tr>
    <tr>
      <td width="2%">&nbsp;</td>
      <td><select name="major_index" onChange="document.ssection.offer.value='';ReloadPage();">
          <option></option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.length() > 0 && strTemp.compareTo("selany") != 0 && strTemp.compareTo("0") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select> </td>
      <td width="36%">
        <%if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
        <select name="year" onChange="ReloadIfNecessary();">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("year");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}if(strTemp.compareTo("7") ==0)
{%>
          <option value="7" selected>7th</option>
          <%}else{%>
          <option value="7">7th</option>
          <%}if(strTemp.compareTo("8") ==0)
{%>
          <option value="8" selected>8th</option>
          <%}else{%>
          <option value="8">8th</option>
          <%}%>
        </select> <select name="semester" onChange="ReloadIfNecessary();">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";

if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
        <%}//only if degree type is not care giver type.%>      </td>
    </tr>
    <%
if(strDegreeType != null && strDegreeType.compareTo("3") ==0){%>
    <tr>
      <td height="6">&nbsp;</td>
      <td height="25" >Select Preparatory/Proper :
        <select name="prep_prop_stat" onChange="ReloadPage();">
          <option value="1">Preparatory</option>
          <%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
        </select> </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <%}//only if strDegree type is 3
}//only if WI.fillTextValue("res_offering").compareTo("1") == 0)%>
  </table>
<%
//if it is having school year - display resulet - else do not display anything below this
if(vTemp.size() > 0 || WI.fillTextValue("res_offering").compareTo("1") ==0)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td  colspan="2" height="25">Class Program for school year : <strong> <%
	  strTemp = WI.fillTextValue("school_year_fr");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[0];
	  %> <input name="school_year_fr" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("ssection","school_year_fr","school_year_to")'> 
        <%
	  strTemp = WI.fillTextValue("school_year_to");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[1];
	  %>
        - 
        <input name="school_year_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp;&nbsp;&nbsp; <select name="offering_sem">
<%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = astrSchYrInfo[2];
%>
		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select> <input type="hidden" name="offering_sem_name" value="<%=astrConvertSem[Integer.parseInt(strTemp)]%>"> 
      </td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="39%"><input type="submit" name="showsub" value="Show Subjects" onClick="document.ssection.offer.value='';ShowSubject();"> 
        <font size="1">click to show subjects</font></td>
      <td width="59%"><a href="javascript:ViewSection('');"><img src="../../../images/view.gif" border="0"></a><font size="1">click 
        to show class program with details</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">To filter SUBJECT display enter subject code starts with 
        <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="6" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        and click SHOW SUBJECTs<a href="javascript:ReloadPage();"></a> </td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>

<%
//System.out.println(request.getParameter("showsubject"));
if(request.getParameter("showsubject") != null && request.getParameter("showsubject").compareTo("1") ==0)
{
	//here get detail of the subject offered , and the course index.
	vTemp = SS.getSubjectOffered(dbOP,request,strSYTo);
	if(vTemp == null || vTemp.size() == 0)
	{
		if(SS.getErrMsg() == null)
			strTemp = "No curriculum found. Please create curriculum before assiging section.";
		else
			strTemp = SS.getErrMsg();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<b><%=strTemp%></b></font></p>
		<%
	}
	else
	{
		//construct all the hidden fields.

		for( i = 0,j=0; i< vTemp.size(); ++j)
		{
			if(j ==0)
				strCurIndex0 = (String)vTemp.elementAt(i);
			%>
			<input type="hidden" name="cur_index<%=j%>" value="<%=(String)vTemp.elementAt(i)%>">
			<input type="hidden" name="subject_category<%=j%>" value="<%=(String)vTemp.elementAt(i+3)%>">
			<input type="hidden" name="is_lec<%=j%>" value="<%=(String)vTemp.elementAt(i+4)%>">
		<%
		i = i+5;
		}//System.out.println(vTemp.size());
		//set the cur_index if the vTemp size == 2;
		if(vTemp.size() == 5) //only one set
			strCurIndex = (String)vTemp.elementAt(0);

		%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(strSchCode.startsWith("CGH") || strSchCode.startsWith("DLSHSI") || bolShowDontCheckConflict){%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2" valign="bottom"> <%
strTemp = WI.fillTextValue("donot_check_conflict");
if(strTemp.compareTo("1") ==0)
	strTemp = " checked";
else
	strTemp = "";
%> <input type="checkbox" name="donot_check_conflict" value="1"<%=strTemp%>> 
        <font color="#0000FF"><strong>DO NOT CHECK CONFLICT (ex. Off campus subjects.)</strong></font></td>
    </tr>
<%}%>
    <tr> 
      <td width="1%">&nbsp;</td>
      <td width="46%" height="25" valign="bottom">Subject: 
        <!--<input type="text" name="scroll_sub" class="textbox" style="font-size:9px"
		 onKeyUp="AutoScrollListSubject('scroll_sub','subject_offered',true,'ssection');">
        <font size="1">(scroll sub)</font>--></td>
      <td valign="bottom">Section<a href="javascript:PopupEditSection();"><img src="../../../images/edit.gif" width="53" height="26" border="0"></a><font size="1">click 
        to edit section(s)</font></td>
    </tr>
    <tr> 
      <td width="1%">&nbsp;</td>
      <td><select name="subject_offered" onChange='ResetToLecSel();SubjectOffered("1");'>
          <option value="selany">Select Subject code</option>
          <%
		strTemp = WI.fillTextValue("subject_offered");
		int iIndex = 0;
		for(i = 0; i< vTemp.size(); )
		{
			dbOP.constructAutoScrollHiddenField((String)vTemp.elementAt(i+2), iIndex++);
		if(strTemp.compareTo((String)vTemp.elementAt(i+1)) ==0){%>
          <option selected value="<%=(String)vTemp.elementAt(i+1)%>"><%=(String)vTemp.elementAt(i+2)%></option>
          <%}else{%>
          <option value="<%=(String)vTemp.elementAt(i+1)%>"><%=(String)vTemp.elementAt(i+2)%></option>
          <%}
		i = i+5;
		}dbOP.constructAutoScrollHiddenField(null, iIndex);%>
        </select> <select name="is_lec" disabled onChange="ReloadPage();">
          <option value="0">Lec</option>
          <%
boolean bolDisableLecLab = false;
if(WI.fillTextValue("res_offering").compareTo("1") ==0){//i have to check if i should show lec/lab
	bolDisableLecLab = SS.disableIsLecDropDown(dbOP, WI.fillTextValue("subject_offered"));
}
strTemp = WI.fillTextValue("is_lec");
if(strTemp.compareTo("1") == 0 && !bolDisableLecLab){%>
          <option value="1" selected>Lab</option>
          <%}else if(!bolDisableLecLab){%>
          <option value="1">Lab</option>
          <%}%>
        </select></td>
      <td> <select name="select_section" onChange="SelectSection();">
          <option value="">Select/enter new</option>
          <%
Vector vDistinctSection = null;
if(strSchCode.startsWith("EAC"))
	vDistinctSection = SS.getDistinctSection(dbOP,strDegreeType, "- and offering_sy_from = "+WI.fillTextValue("school_year_fr")+" and offering_sem = "+WI.fillTextValue("offering_sem"));
else	
	vDistinctSection = SS.getDistinctSection(dbOP,strDegreeType);
	
strTemp = WI.fillTextValue("select_section");
for(int x = 0 ; x < vDistinctSection.size() ; ++x)
{
	if(strTemp.compareTo(WI.getStrValue(vDistinctSection.elementAt(x))) ==0){%>
          <option selected value="<%=WI.getStrValue(vDistinctSection.elementAt(x))%>"><%=WI.getStrValue(vDistinctSection.elementAt(x))%></option>
          <%}else{%>
          <option value="<%=WI.getStrValue(vDistinctSection.elementAt(x))%>"><%=WI.getStrValue(vDistinctSection.elementAt(x))%></option>
          <%
		}
	}%>
        </select> &nbsp; <%
if(WI.fillTextValue("ref_sub_sch").compareTo("1") ==0)
	strTemp = "readonly";
else
	strTemp = "";
%> <input type="text" name="section" size="20" <%=strTemp%> value="<%=WI.fillTextValue("section")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeypress="if(event.keyCode==39 || event.keyCode==34) event.returnValue=false;" <%if(strSchCode.startsWith("CIT")){%>OnKeyUP="javascript:this.value=this.value.toUpperCase();"<%}%>>
	   <a href="javascript:ViewSection('1');">View One Section</a>      </td>
    </tr>
    <%
 if(WI.fillTextValue("subject_offered").compareTo("selany") != 0 && WI.fillTextValue("subject_offered").length() > 0){
 strTemp = "select lec_unit, lab_unit from curriculum where sub_index = "+WI.fillTextValue("subject_offered");
 rs = dbOP.executeQuery(strTemp);
 strTemp = null;
 if(rs.next()) {
 	strTemp = " (Lec Unit: "+rs.getString(1)+", Lab Unit: "+rs.getString(2)+") ";
 }
 rs.close();
 %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Subject Title: <b><%=dbOP.mapOneToOther("SUBJECT","sub_index",WI.fillTextValue("subject_offered"),"sub_name",null)%>
	  <%=WI.getStrValue(strTemp, "&nbsp;&nbsp; ", "","")%>
	  </b></td>
    </tr>
    <%}%>
<%if(!bolIsCIT){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom"> <%
strTemp = WI.fillTextValue("is_requested_sub");
if(strTemp.compareTo("1") ==0)
	strTemp = " checked";
else
	strTemp = "";
%> <input type="checkbox" name="is_requested_sub" value="1"<%=strTemp%>> 
        <font color="#0000FF"><strong>IS REQUESTED SUBJECT ?</strong></font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td valign="bottom">Subject Offering type</td>
      <td valign="bottom">Subject Category </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><select name="sub_offer_type">
          <option value="regular">Regular Subject</option>
          <option value="irregular">Irregular Subject</option>
          <!--          <option value="requested">Requested Subject</option> -->
        </select></td>
      <td><input type="text" name="subject_category" readonly="yes" size="32" class="textbox_noborder"
	  onfocus="style.color='red'" onBlur="style.color='black'"></td>
    </tr>
    <%}else{%>
		<input type="hidden" name="is_requested_sub" value="">
		<input type="hidden" name="sub_offer_type" value="regular">
	<%}%>
	
	
<%vTemp = null;
if(true)//it will never happen that mixing is done during subject offering
	if(WI.fillTextValue("subject_offered").length() > 0 && WI.fillTextValue("subject_offered").compareTo("selany") != 0 && WI.fillTextValue("section").length() >0
	&& (vIsCommonSection == null || vIsCommonSection.size() == 0 )){%>

	<!--- added for spc === dated >. 2013-10-30 --- It can now mix and merge with any subject and section.. I do not know how it will work out if other section., 
	needs to be tested.. and leave commnet here if it works well for SPC... 
	
	-->
	
	<%if(strSchCode.startsWith("SPC")){%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td colspan="2" valign="bottom">Copy Schedule from another Section/Subject: 
			  <select name="ref_sub_sch_index" style="width:400px;">
				  <option value="">Select a Section-Subject</option>
					<%
					strSQLQuery = "select sub_sec_index, section, sub_code, sub_name from e_sub_section join subject on (e_sub_section.sub_index = subject.sub_index) "+
								" where is_valid = 1 and is_lec = 0 and is_child_offering = 0 and section <> '"+WI.fillTextValue("section")+"' and offering_sy_from = "+
								WI.fillTextValue("school_year_fr")+" and offering_sem = "+WI.fillTextValue("offering_sem")+
								" and exists (select * from e_room_assign where e_room_assign.sub_sec_index = e_sub_section.sub_sec_index) "+
								" order by section, sub_code";
					rs = dbOP.executeQuery(strSQLQuery);
					strTemp = WI.fillTextValue("ref_sub_sch_index");
					while(rs.next()) {
						if(strTemp.equals(rs.getString(1)))
							strErrMsg =" selected";
						else	
							strErrMsg = "";
					%>				  
					<option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> - <%=rs.getString(3)%> (<%=rs.getString(4)%>)</option>
					<%}%>
			</select>
		  
		  &nbsp;&nbsp;&nbsp;
		  <a href="javascript:MixSchedule();"><img src="../../../images/copy_all.gif" border="0"></a><font size="1"> 
        Click to mix section offering.</font>
		  </td>
		</tr>
	<%}//show only for SPC.. weird type of merging.. 
	else {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Check to copy Schedule from another subject 
        <%
if(WI.fillTextValue("ref_sub_sch").compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
%> <input type="checkbox" name="ref_sub_sch" value="1"  <%=strTemp%> onClick="ReloadPage();"> 
        <%if(WI.fillTextValue("ref_sub_sch").compareTo("1") ==0){%> 
			<select name="ref_sub_sch_index" onChange="ReloadPage();">
			  <option value="0">Select a subject</option>
			  <%=dbOP.loadCombo("distinct e_sub_section.sub_sec_index","sub_code"," from e_sub_section join subject on (subject.sub_index=e_sub_section.sub_index) where e_sub_section.IS_DEL=0 "+
									" and e_sub_section.is_valid=1 and section='"+WI.fillTextValue("section")+"' and is_child_offering=0 and is_lec="+
									WI.getStrValue(WI.fillTextValue("is_lec"),"0")+" and offering_sem="+WI.fillTextValue("offering_sem")+
									" and offering_sy_from = "+WI.fillTextValue("school_year_fr")+" order by sub_code asc",
									request.getParameter("ref_sub_sch_index"), false)%> 
			</select> &nbsp;&nbsp;<b><font size="1"><%=WI.getStrValue(dbOP.mapOneToOther("E_SUB_SECTION join subject on (e_sub_section.sub_index=subject.sub_index) ",
											"sub_sec_index",WI.fillTextValue("ref_sub_sch_index"),"sub_name",null))%></font></b> 
		<%}%> 
	  </td>
    </tr>
<%}//show only if not SPC.. %>



	
			
    <%}//show only if a subject is selected.
if(!strSchCode.startsWith("SPC") && WI.fillTextValue("ref_sub_sch_index").length() > 0  && WI.fillTextValue("ref_sub_sch").compareTo("1")==0){//d not show offer button for SPC..
vTemp = SS.getRoomScheduleDetailInMWF(dbOP,WI.fillTextValue("ref_sub_sch_index"));
if(vTemp != null){
%>
    <!--  I do not have to give the section name to be displyed -- infact, the section name should follow the section copied from value.
<tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">Select a section to mix schedule to:
        <select name="destination_sec" onChange="ReloadPage();">
          <option value="0">Select a Section</option>
          <%/*=dbOP.loadCombo("distinct e_sub_section.section","section"," from e_sub_section join curriculum on (curriculum.cur_index=e_sub_section.cur_index) "+
		  						"where e_sub_section.IS_DEL=0 "+
		  						" and e_sub_section.is_valid=1 and course_index='"+WI.fillTextValue("course_index")+"' and is_child_offering=0 and is_lec="+
								WI.getStrValue(WI.fillTextValue("is_lec"),"0")+" and curriculum.course_index="+WI.fillTextValue("course_index")+" order by section asc",
								request.getParameter("destination_sec"), false)*/%>
        </select></td>
      <td valign="bottom">&nbsp;</td>
    </tr> -->
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Schedule : <strong><%=(String)vTemp.elementAt(2)%> 
        <%if(vTemp.elementAt(1) != null){%>
        /<%=(String)vTemp.elementAt(1)%> 
        <%}%>
        </strong></td>
      <td valign="bottom"> <%
//do not show copy button, if it is already offered.
if(vIsSubOffered == null || vIsSubOffered.size()==0){%> <a href="javascript:MixSchedule();"><img src="../../../images/copy_all.gif" border="0"></a><font size="1"> 
        Click to mix section offering.</font> <%}%> </td>
    </tr>
    <%}
}%>
<%if(!strSchCode.startsWith("CIT")){%>    
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Schedule created by college</td>
      <td valign="bottom">Schedule created by department</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><strong><%=strCollegeName%></strong></td>
      <td><strong><%=WI.getStrValue(strDeptName,"All depts")%></strong></td>
    </tr>
<%}%>
  </table>
    <input type="hidden" name="c_index" value="<%=strCollegeIndex%>">
    <input type="hidden" name="d_index" value="<%=WI.getStrValue(strDeptIndex,"")%>">
<%
//check if the subject is already offered. - NOTE for subject -> OFFER from other subject can't have see this.
//System.out.println(vIsSubOffered);
String strTermHTC = null;
if(vTemp == null && vIsSubOffered != null && vIsSubOffered.size()>0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="34%">Schedule: <strong><%=(String)vIsSubOffered.elementAt(6)%></strong></td>
      <td width="39%">Room number<strong>: <%=WI.getStrValue(vIsSubOffered.elementAt(1),"Not assigned")%></strong>
      <td width="25%" style="font-weight:bold; font-size:14px;">
<%
if(strSchCode.startsWith("HTC")) {
strTermHTC = (String)vIsSubOffered.elementAt(7);
if(strTermHTC != null && !strTermHTC.equals("0"))
	strTemp = "Term: "+strTermHTC;
else	
	strTemp = "Term: ALL";
%>
<%=strTemp%>
<%}%>

		</td>
	  </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>NOTE: Subject is having schedule and offered.</td>
      <td colspan="2">Check to schedule another time for same section
        <%
 strTemp = WI.fillTextValue("force_another_time");
 if(strTemp.compareTo("1") ==0)
 	strTemp = "checked";
else
	strTemp = "";
//check if it is allowed.
if(SS.checkIfSchedAnotherTimeAllowed(dbOP,(String)vIsSubOffered.elementAt(0))){%>
        <input type="checkbox" name="force_another_time" value="1" onClick="ReloadPage();" <%=strTemp%>>
<%}else{%>
	-<strong> N/A</strong>
<%}%>			</td>
    </tr>
  </table>
<%} if(WI.fillTextValue("force_another_time").compareTo("1") ==0 || vIsSubOffered == null || vIsSubOffered.size() ==0){//check other conditions.

if(vTemp == null && vIsCommonSection != null && vIsCommonSection.size() > 0 && WI.fillTextValue("force_another_time").compareTo("1") != 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2"><font size="1"><strong>SCHEDULE</strong></font></td>
      <td width="22%"><font size="1"><strong>ROOM NUMBER</strong></font></td>
      <td width="42%"><strong><font size="1">OFFER</font></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2"><strong><%=(String)vIsCommonSection.elementAt(0)%></strong>
      </td>
      <td width="22%"><strong><%=WI.getStrValue(vIsCommonSection.elementAt(2),"Not assigned")%></strong>
        <input type="hidden" name="copyFromSection" value="<%=(String)vIsCommonSection.elementAt(1)%>" ></td>
      <td width="42%">
	  <%
	  if(iAccessLevel > 1){%>
	  <input type="image" onClick="Offer();" src="../../../images/offer.gif">click to offer
	  <%}else{%>Not authorized <%}%></td>
    </tr>
  </table>
<%}else if( (request.getParameter("showweeklyschedule") == null || request.getParameter("showweeklyschedule").compareTo("1") != 0) &&
	vTemp == null && WI.fillTextValue("subject_offered").compareTo("selany") != 0
	&& WI.fillTextValue("subject_offered").length() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%">&nbsp;</td>
      <td colspan="2">Schedule (M-T-W-TH-F-SAT-S)</td>
      <td width="22%">Time From</td>
      <td width="28%">Time To </td>
      <td width="14%">Room No </td>
    </tr>
    <tr>
      <td width="2%">&nbsp;</td>
      <td colspan="2" style="font-weight:bold; font-size:14px;"><input type="text" name="week_day" size="20" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("week_day")%>"
	  onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" OnKeyUP="javascript:this.value=this.value.toUpperCase();">
	  <%if(strSchCode.startsWith("SWU") || strSchCode.startsWith("DLSHSI")){%>    
		  <input type="checkbox" name="is_tba" onClick="SetTBA();"> Is TBA
	  <%}%>	  </td>
      <td><input type="text" name="time_from_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_hr")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidHour('1');">
        :
        <input type="text" name="time_from_min" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_min")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin();">
        :
        <select name="time_from_AMPM">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_from_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
      <td><input type="text" name="time_to_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_to_hr")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidHour('2');">
        :
        <input type="text" name="time_to_min"  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_to_min")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin();">
        :
        <select name="time_to_AMPM">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_to_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
      <td>
	  <select name="room_index" style="font-size:12px; color:#0000FF; font-weight:bold" id="room_i">
<%if(!bolIsCIT){%>
          <option value="">Optional To Set</option>
<%}
//I have to check if ownership is implmeneted.. 
strTemp = "";
if(bolIsRoomOwnerShipForced) {
	if(WI.fillTextValue("c_index_sel").length() > 0)
		strTemp = WI.fillTextValue("c_index_sel");
	else	
		strTemp = strCollegeIndex;
	
	strTemp = " and exists (select * from E_ROOM_ASSIGN_OWNERSHIP where college_index = "+strTemp+" and room_index = e_room_detail.room_index) ";
}
//System.out.println(strTemp);
%>
          <%=dbOP.loadCombo("room_index","room_number"," from e_room_detail where is_valid = 1 and nfs_assignment = 0"+strTemp+" order by room_number", WI.fillTextValue("room_index"), false)%>
        </select>	  </td>
    </tr>
    <%
if(strDegreeType != null && strDegreeType.compareTo("4") ==0){%>
     <tr>
      <td>&nbsp;</td>
      <td colspan="5" height="25">Duration of Schedule :
        <input type="text" name="offering_dur" size="40" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("offering_dur")%>">
        (Please note, System will not check conflict for CareGiver)</td>
    </tr>
<%}if(bolShowDateRange) {%>
     <tr>
      <td>&nbsp;</td>
      <td colspan="5" height="25">Duration of Schedule:
		<input name="v_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("v_fr")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		<a href="javascript:show_calendar('ssection.v_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> to
	   
	    <input name="v_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("restdate_fr")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">				
		<a href="javascript:show_calendar('ssection.v_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
<%}if(strSchCode.startsWith("HTC")) {%>
    </tr>
     <tr>
       <td>&nbsp;</td>
       <td colspan="5" height="25" style="font-weight:bold; font-size:18px;">TERM OFFERING: 
	   <select name="term_ess" style="font-weight:bold; font-size:18px; color:#CC0000">
	   		<option></option>
<%
strTemp = WI.fillTextValue("term_ess");
if(strTermHTC != null)
	strTemp = strTermHTC;
	
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="1"<%=strErrMsg%>>TERM 01</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="2"<%=strErrMsg%>>TERM 02</option>
	   </select>
	   
	   </td>
     </tr>
<%}%>
    <tr>
      <td width="2%">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td colspan="3">
        <%if(iAccessLevel > 1){%>
        <input name="image" type="image" onClick="AddRecord();" src="../../../images/add.gif">
        <%}else{%>
        Not authorized
        <%}%>
        <%if(false){//do not show for now-- only for the schools do not follow MWF FORMAT%>
        OR
        <input type="image" onClick="ShowWeeklySchedule();" src="../../../images/schedule.gif">
        <font size="1">click schedule if there are different schedules in a day        </font>
        <%}%>      </td>
    </tr>
  </table>
	<%
	}else if(vTemp == null && WI.fillTextValue("subject_offered").compareTo("selany") != 0 && WI.fillTextValue("select_section").length() > 0)
	{%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr bgcolor="#B9B292">
			  <td height="25"colspan="5"><div align="center">Subject
				  Schedule</div></td>
			</tr>
			<tr bgcolor="#FFFFFF">
			  <td width="43%" height="25"><div align="right"> </div></td>
			  <td width="20%" height="25">&nbsp; </td>
			  <td width="25%" height="25">&nbsp;</td>

      <td width="8%" height="25"><div align="right"><a href="javascript:ChangeScheduleFormat();"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></div></td>
			  <td width="4%" height="25">&nbsp;</td>
			</tr>
		  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td><font size="1"><b>Monday</b></font></td>
      <td><font size="1"><strong>Tuesday</strong></font></td>
      <td><font size="1"><strong>Wednesday</strong></font></td>
      <td><font size="1"><strong>Thrusday</strong></font></td>
      <td><font size="1"><strong>Friday</strong></font></td>
      <td><font size="1"><strong>Saturday</strong></font></td>
      <td><font size="1"><strong>Sunday</strong></font></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td><input type="text" name="time_from_hr1" size="2" maxlength="2">
        :
        <input type="text" name="time_from_min1"  size="2" maxlength="2" value="00">
        :
        <select name="time_from_AMPM1">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select>
        TO <br> <input type="text" name="time_to_hr1"  size="2" maxlength="2">
        :
        <input type="text" name="time_to_min1" size="2" maxlength="2" value="00">
        :
        <select name="time_to_AMPM1">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select> </td>
      <td><input type="text" name="time_from_hr2" size="2" maxlength="2">
        :
        <input type="text" name="time_from_min2" size="2" maxlength="2" value="00">
        :
        <select name="time_from_AMPM2">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select>
        TO <br> <input type="text" name="time_to_hr2" size="2" maxlength="2">
        :
        <input type="text" name="time_to_min2" size="2" maxlength="2" value="00">
        :
        <select name="time_to_AMPM2">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select></td>
      <td><input type="text" name="time_from_hr3" size="2" maxlength="2">
        :
        <input type="text" name="time_from_min3" size="2" maxlength="2" value="00">
        :
        <select name="time_from_AMPM3">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select>
        TO <br> <input type="text" name="time_to_hr3" size="2" maxlength="2">
        :
        <input type="text" name="time_to_min3" size="2" maxlength="2" value="00">
        :
        <select name="time_to_AMPM3">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select></td>
      <td><input type="text" name="time_from_hr4" size="2" maxlength="2">
        :
        <input type="text" name="time_from_min4" size="2" maxlength="2" value="00">
        :
        <select name="time_from_AMPM4">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select>
        TO <br> <input type="text" name="time_to_hr4" size="2" maxlength="2">
        :
        <input type="text" name="time_to_min4" size="2" maxlength="2" value="00">
        :
        <select name="time_to_AMPM4">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select></td>
      <td><input type="text" name="time_from_hr5" size="2" maxlength="2">
        :
        <input type="text" name="time_from_min5" size="2" maxlength="2" value="00">
        :
        <select name="time_from_AMPM5">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select>
        TO <br> <input type="text" name="time_to_hr5" size="2" maxlength="2">
        :
        <input type="text" name="time_to_min5" size="2" maxlength="2" value="00">
        :
        <select name="time_to_AMPM5">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select></td>
      <td><input type="text" name="time_from_hr6" size="2" maxlength="2">
        :
        <input type="text" name="time_from_min6" size="2" maxlength="2" value="00">
        :
        <select name="time_from_AMPM6">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select>
        TO <br> <input type="text" name="time_to_hr6" size="2" maxlength="2">
        :
        <input type="text" name="time_to_min6" size="2" maxlength="2" value="00">
        :
        <select name="time_to_AMPM6">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select></td>
      <td><input type="text" name="time_from_hr0" size="2" maxlength="2">
        :
        <input type="text" name="time_from_min0" size="2" maxlength="2" value="00">
        :
        <select name="time_from_AMPM0">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select>
        TO <br> <input type="text" name="time_to_hr0" size="2" maxlength="2">
        :
        <input type="text" name="time_to_min0" size="2" maxlength="2" value="00">
        :
        <select name="time_to_AMPM0">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select></td>
      <td><%if(iAccessLevel > 1){%>
	  <input name="image" type="image" onClick="AddRecord();" src="../../../images/add.gif">
	  <%}else{%>Not authorized<%}%></td>
    </tr>
    <%		}//only if vIsSubOffered is null -- shows subject is not offered yet.
	 	}//show the weekly schedule only of Shedule Imange icon is clicked.
	}//shows the subject details or error mesage - after calling getSubjectOffered(..);
  } //End of show subject -- content below the Show Subjects button.
}//END OF SHOWING THE OPTIONS IF THERE IS SCHOOL YEAR

%>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="showsubject" value="<%=WI.fillTextValue("showsubject")%>">
<%
if(strCurIndex == null)
{
	strTemp = request.getParameter("cur_index");
	if(strTemp == null || strTemp.compareTo("0") ==0)
		strTemp = request.getParameter("cur_index0");
	if(strTemp == null || strTemp.trim().length() ==0) strTemp = strCurIndex0;
	if(strTemp == null) strTemp = "0";
}
else
	strTemp = strCurIndex;
%>
<input type="hidden" name="cur_index" value="<%=strTemp%>">
<input type="hidden" name="showweeklyschedule" value="<%=request.getParameter("showweeklyschedule")%>">
<input type="hidden" name="offer">
<input type="hidden" name="degreeType" value="<%=WI.getStrValue(strDegreeType)%>">
<input type="hidden" name="mixSchedule">

<input type="hidden" name="reload_in_progress">
<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>
</body>
</html>

<%
dbOP.cleanUP();
%>
