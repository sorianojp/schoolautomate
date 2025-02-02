<%@ page language="java" import="utility.*,enrollment.ReportRegistrarExtn,java.util.Vector" %>



<%

String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");

if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4")) {
 request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
 request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
 response.sendRedirect("../../../commfile/fatal_error.jsp");
 return;
}

	boolean bolFilterCollege = false;
	String strCIndex = (String)request.getSession(false).getAttribute("info_faculty_basic.c_index");	
	if(strCIndex != null && strCIndex.length() > 0 && !strCIndex.equals("0"))
		bolFilterCollege = true;

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	if(WI.fillTextValue("print_pg").length() > 0) {%>
		<jsp:forward page="./student_list_w_inc_print.jsp" />
	<%return;}
	
	
	boolean bolShowData = true;
	if(WI.fillTextValue("export_excel").length() > 0)
		bolShowData = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

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

var strFieldName = "";
var strObj       = "";
function AjaxMapName(fieldName, objCOAInput, strType) {
		var strCompleteName = eval('document.report_registrar.'+fieldName+'.value');
		if(strCompleteName.length < 2)
			return;
		strFieldName = fieldName;
		strObj       = objCOAInput;
		objCOAInput = document.getElementById(objCOAInput);
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);
		
		if(strType == "1")
			strURL += "&is_faculty=1";
		
		

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	strFieldName = eval('document.report_registrar.'+strFieldName);
	strFieldName.value = strID
	//document.report_registrar.stud_id.value = strID;
	//document.report_registrar.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.report_registrar.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById(strObj).innerHTML = "";
}


function ViewDetail(strStudID)
{
	//var pgLoc = "./student_list_w_inc_view_one.jsp?stud_id="+escape(strStudID)+
	//	"&report_type=<%=WI.fillTextValue("report_type")%>&report_type_name="+escape("<%=WI.fillTextValue("report_type_name")%>");
	var pgLoc = "../residency/residency_status.jsp?selCourse=under&stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"ViewDetail",'width=800,height=600,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewGradeFactorPerCollege(strReportType){
	
	var pgLoc = "./student_list_w_inc_auf_graph/grade_factor_per_college.jsp?remark_index="+document.report_registrar.remark_index_col_all_col.value;
	if(strReportType == "1")
		pgLoc = "./student_list_w_inc_auf_graph/grade_factor_per_course.jsp?remark_index="+document.report_registrar.remark_index_course_all_col_course.value;
	
	if(strReportType == "2")
		pgLoc = "./student_list_w_inc_auf_graph/subject_deficiency_per_course.jsp?remark_index="+document.report_registrar.subject_per_course.value+
			"&course_index="+document.report_registrar.	subject_per_course_index.value;	
	
	if(strReportType == "3")
		pgLoc = "./student_list_w_inc_auf_graph/remark_per_faculty_per_subject.jsp?remark_index="+document.report_registrar.faculty_per_subject.value+
			"&sub_index="+document.report_registrar.faculty_per_subject_index.value;	
	
	pgLoc += "&sy_from="+document.report_registrar.sy_from.value+
	"&semester="+document.report_registrar.semester.value;
	var win=window.open(pgLoc,"ViewInfo",'width=800,height=600,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateReportName() {
	document.getElementById("report_n").innerHTML = document.report_registrar.report_name.value;
}
function PrintPage() {
	document.report_registrar.print_pg.value ='1';
	document.report_registrar.submit();
	return;
	
	//not used.. 
	
	var addCon = "";
	if(document.report_registrar.rem_course.checked)
		addCon = "&rem_course=1";
	if(document.report_registrar.rem_fac.checked)
		addCon += "&rem_fac=1";
	if(document.report_registrar.year_level.selectedIndex > 0) 
		addCon += "&year_level="+document.report_registrar.year_level.selectedIndex;
	if(document.report_registrar.section_.value.length > 0) 
		addCon += "&section_="+document.report_registrar.section_.value;

	if(document.report_registrar.rem_tc && document.report_registrar.rem_tc.checked) 
		addCon += "&rem_tc=1";
	if(document.report_registrar.show_no_of_stud && document.report_registrar.show_no_of_stud.checked) 
		addCon += "&show_no_of_stud=1";
	//alert(addCon);
	
	
	var pgLoc = "./student_list_w_inc_print.jsp?report_type=<%=WI.fillTextValue("report_type")%>&course_index="+
	document.report_registrar.course_index[document.report_registrar.course_index.selectedIndex].value+
	"&major_index="+document.report_registrar.major_index.value+
	"&lname_from="+document.report_registrar.lname_from[document.report_registrar.lname_from.selectedIndex].text+
	"&lname_to="+document.report_registrar.lname_to[document.report_registrar.lname_to.selectedIndex].text+
	"&report_type_name="+escape(document.report_registrar.report_type[document.report_registrar.report_type.selectedIndex].text)+
	"&min_no="+document.report_registrar.min_no.value+
	"&sy_from="+document.report_registrar.sy_from.value+
	"&sy_to="+document.report_registrar.sy_to.value+
	"&semester="+document.report_registrar.semester[document.report_registrar.semester.selectedIndex].value+
	addCon+"&s1="+document.report_registrar.s1[document.report_registrar.s1.selectedIndex].value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.report_registrar.print_pg.value ='';
	//document.report_registrar.report_type_name.value = 
	//		document.report_registrar.report_type[document.report_registrar.report_type.selectedIndex].text;
	this.SubmitOnce('report_registrar');
}
function ShowResult() {
	/*var display = document.getElementById('branch1').style.display;
	alert(display);
	return;*/
	
	document.report_registrar.showResult.value = "1";
	ReloadPage();
}
/*function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=report_registrar.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}*/
function ChangeRemarkName() {
	if(document.report_registrar.report_type.selectedIndex == 0)
		document.report_regisrar.remark_name.value = "";
	else	
		document.report_regisrar.remark_name.value = 
			document.report_regisrar.report_type[document.report_regisrar.report_type.selectedIndex].text;
	///document.report_registrar.gradeName.value = "Test";
}
///ajax here to load major..
function loadMajor() {
		var objCOA=document.getElementById("load_major");
 		var objCourseInput = document.report_registrar.course_index[document.report_registrar.course_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?all=1&methodRef=104&course_ref="+objCourseInput+"&sel_name=major_index";
		//alert(strURL);
		this.processRequest(strURL);
}


function DisplayDownload(){
	document.getElementById('display_download').style.visibility = "visible";
	document.getElementById('display_download').style.display = "block";
}
</script>

<body bgcolor="#D2AE72">
<%
	String[] astrConvertYear ={"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Student list with INC","student_list_w_inc.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","REPORTS",request.getRemoteAddr(),
							//							"student_list_w_inc.jsp");
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

java.sql.ResultSet rs = null;

String[] astrYear = {"","1st","2nd","3rd","4th","5th","6th"};
String[] astrLogic = {"OR","NOT"};
int i = 0;
int iFieldCount = 0;
//end of authenticaion code.
ReportRegistrarExtn RR = new ReportRegistrarExtn();
//enrollment.ReportRegistrarAUF RR = new enrollment.ReportRegistrarAUF();
Vector vRetResult      = null;
String strLoadComboSubIndex  =null;

boolean bolHasColOverTotCol = false;
boolean bolHasCourseOverTotColCourse = false;

boolean bolHasSubGenEd = false;
boolean bolHasSubProf = false;

String[] strConvertAlphabet =
		{"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
if(WI.fillTextValue("showResult").length() > 0){

	RR.clearReportSession(request);

	vRetResult = RR.listStudWithINCAUF(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RR.getErrMsg();
	else{
		Vector vTemp = (Vector)request.getSession(false).getAttribute("vGFColOverTotCol");		
		if(vTemp != null && vTemp.size() > 0)
			bolHasColOverTotCol = true;
			
		vTemp = (Vector)request.getSession(false).getAttribute("vGFCourseOverTotColCourse");
		if(vTemp != null && vTemp.size() > 0)
			bolHasCourseOverTotColCourse = true;
			
		vTemp = (Vector)request.getSession(false).getAttribute("vGenSubjList");
		if(vTemp != null && vTemp.size() > 0)
			bolHasSubGenEd = true;
			
		vTemp = (Vector)request.getSession(false).getAttribute("vProfSubjList");
		if(vTemp != null && vTemp.size() > 0)
			bolHasSubProf = true;		
		strLoadComboSubIndex = RR.getLoadComboSubIndex();
	}	
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");

//if(vRetResult != null)
//	System.out.println(vRetResult.size());

boolean bolShowOnlyFinals = true;
if(WI.fillTextValue("show_other_grade").length() > 0) 
	bolShowOnlyFinals = false;
	
Vector vSubjectSummary = null;
///if show_no_of_stud is clicked i have to show # of student per subject. 
if(WI.fillTextValue("show_no_of_stud").length() > 0 && vRetResult != null && vRetResult.size() > 0 && 
	!WI.fillTextValue("report_type").equals("0")) 
	vSubjectSummary = (Vector)vRetResult.remove(0);


String strCourseIndexList = "";
%>
<form action="./student_list_w_inc_auf.jsp" method="post" name="report_registrar">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          LIST OF STUDENTS PER GRADES STATUS ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
	<tr>
        <td height="25">&nbsp;</td>
        <td colspan="2" style="font-size:9px; color:#FF0000; font-weight:bold">
		NOTE: For multiple filters, use the text field beside each filter options<br>
		Only work if entered greater than 1.		</td>
    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td colspan="2" style="font-size:11px; color:#FF0000;">
		<%if(bolFilterCollege){%>
		<div style="border:solid 1px #FF0000; height:auto;  font-size:10px;">
		NOTE:
		<br>&nbsp; &nbsp; 1. System will check if student is under user's college.
		<br>&nbsp; &nbsp; &nbsp; &nbsp; 1.1 If student is under college, it will show all subject-grade status.
		<br>&nbsp; &nbsp; &nbsp; &nbsp; 1.2 If student is not under college, it will show all subject-grade status offered by the college.		</div>
		<%}%>		</td>
	    </tr>
<%if(strSchCode.startsWith("DBTC") || strSchCode.startsWith("DBTC")){%>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:11px; color:#0000FF; font-weight:bold">
<%
if(bolIsBasic)
	strTemp = " checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="is_basic" value="1" <%=strTemp%> onClick="ReloadPage();"> Search Grade School </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");	  
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("report_registrar","sy_from","sy_to")'>
-
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");	  
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
&nbsp; 
<select name="semester">
<!--<%=CommonUtil.constructTermList(dbOP, request, WI.fillTextValue("semester"))%>-->
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = WI.getStrValue((String)request.getSession(false).getAttribute("cur_sem"));
	
for(i = 0; i < astrConvertSem.length; ++i){
if(strTemp.equals(Integer.toString(i)))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>
<option value="<%=i%>" <%=strErrMsg%>><%=astrConvertSem[i]%></option>
<%}%>
</select>
&nbsp;
TO
&nbsp;
<%
strTemp = WI.fillTextValue("sy_from_");
%>
        <input name="sy_from_" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("report_registrar","sy_from_","sy_to_")'>
-
<%
strTemp = WI.fillTextValue("sy_to_");
%>
<input name="sy_to_" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
&nbsp; 
<select name="semester_">
<!--<%=CommonUtil.constructTermList(dbOP, request, WI.fillTextValue("semester_"))%>-->
<%
strTemp = WI.fillTextValue("semester_");
for(i = 0; i < astrConvertSem.length; ++i){
if(strTemp.equals(Integer.toString(i)))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>
<option value="<%=i%>" <%=strErrMsg%>><%=astrConvertSem[i]%></option>
<%}%>
</select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:9px; color:#0000FF; font-weight:bold">
	<!--<input type="checkbox" name="show_graduating" value="checked" <%=WI.fillTextValue("show_graduating")%>> Show Only Graduating Student
	<br>-->
	 <input type="checkbox" name="show_other_grade" onClick="document.report_registrar.submit();" value="checked" <%=WI.fillTextValue("show_other_grade")%>> Show Other Grading Period (if not checked, system shows Final Grade) <br>
<%if(WI.fillTextValue("show_other_grade").length() > 0) {

	
try{
	iFieldCount = Integer.parseInt(WI.fillTextValue("pmt_schedule_count"));
}catch(Exception e){
	iFieldCount = 0;
}

if(iFieldCount > 1){%>
		<select name="pmt_schedule_logic_0" style='width:60px;'> 
		   	     <%
			 strTemp = WI.fillTextValue("pmt_schedule_logic_0");
			 for(int j = 0; j < astrLogic.length; ++j){
			 if(strTemp.equals(Integer.toString(j)))
			 	strErrMsg = "selected";
			else
				strErrMsg = "";
			 %>
		   	     <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
		   	     <%}%>
	   	        </select><%}%>
        <select name="pmt_schedule_0">
		<%
		if(bolIsBasic) 
	strTemp = "2 and bsc_grading_name is not null";
else	
	strTemp = "1 and exam_name not like 'final%'";
		%>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_valid="+strTemp+" order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule_0"), false)%> 
        </select>
		<input name="pmt_schedule_count" type="text" size="1" maxlength="1" style="background:#D3EBFF" 
		  value="<%=WI.fillTextValue("pmt_schedule_count")%>" class="textbox"
	`		 onKeyUp="AllowOnlyInteger('report_registrar','pmt_schedule_count');"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('report_registrar','pmt_schedule_count');ReloadPage();">	
	
<%}%>	  </td>
    </tr>
	
<%
if(iFieldCount > 1){
	for(i = 1; i < iFieldCount; ++i){
%>	
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
	   <select name="pmt_schedule_logic_<%=i%>" style='width:60px;'> 
		   	     <%
			 strTemp = WI.fillTextValue("pmt_schedule_logic_"+i);
			 for(int j = 0; j < astrLogic.length; ++j){
			 if(strTemp.equals(Integer.toString(j)))
			 	strErrMsg = "selected";
			else
				strErrMsg = "";
			 %>
		   	     <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
		   	     <%}%>
	   	        </select>
          <select name="pmt_schedule_<%=i%>">
		  <%
		  if(bolIsBasic) 
				strTemp = "2 and bsc_grading_name is not null";
			else	
				strTemp = "1 and exam_name not like 'final%'";
		  %>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_valid="+strTemp+" order by EXAM_PERIOD_ORDER asc", 
		  	request.getParameter("pmt_schedule_"+i), false)%> 
        </select>		   			 </td>
      </tr>
<%	}
}

try{
	iFieldCount = Integer.parseInt(WI.fillTextValue("report_type_count"));
}catch(Exception e){
	iFieldCount = 0;
}
%>	
	
	
	
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  
      <font size="1">(Grades not yet encoded works only for the stuents 
        enrolled in system)</font><br>
		<%if(iFieldCount > 1){%>
		<select name="report_type_logic_0" style='width:60px;'> 
		   	     <%
			 strTemp = WI.fillTextValue("report_type_logic_0");
			 for(int j = 0; j < astrLogic.length; ++j){
			 if(strTemp.equals(Integer.toString(j)))
			 	strErrMsg = "selected";
			else
				strErrMsg = "";
			 %>
		   	     <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
		   	     <%}%>
	   	        </select><%}%>
	  <select name="report_type_0">
          <option value="0">Grades not yet encoded</option>
<%
if(WI.fillTextValue("report_type_0").equals("-1"))
	strTemp = " selected";
else	
	strTemp = "";
%>
		  <option value="-1" <%=strTemp%>>Grade encoded and having any remark</option>
<%
if(WI.fillTextValue("report_type_0").equals("-2"))
	strTemp = " selected";
else	
	strTemp = "";
%>
		  <option value="-2" <%=strTemp%>>All remarks except PASS</option>
          <%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("report_type_0"), false)%> 
        </select>
		<input name="report_type_count" type="text" size="1" maxlength="1" style="background:#D3EBFF" 
		  value="<%=WI.fillTextValue("report_type_count")%>" class="textbox"
	`		 onKeyUp="AllowOnlyInteger('report_registrar','report_type_count');"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('report_registrar','report_type_count');ReloadPage();">				
		  <font size="1" color="#FF0000" style="font-weight:bold">===> NOTE: Selecting "Grades not yet encoded" will ignore other remarks filter</font>		  </td>
    </tr>
<%

if(iFieldCount > 1){
	for(i = 1; i < iFieldCount; ++i){
%>	
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  <select name="report_type_logic_<%=i%>" style='width:60px;'> 
		   	     <%
			 strTemp = WI.fillTextValue("report_type_logic_"+i);
			 for(int j = 0; j < astrLogic.length; ++j){
			 if(strTemp.equals(Integer.toString(j)))
			 	strErrMsg = "selected";
			else
				strErrMsg = "";
			 %>
		   	     <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
		   	     <%}%>
	   	        </select>
          <select name="report_type_<%=i%>">
              <!--<option value="0">Grades not yet encoded</option>-->
    <%
if(WI.fillTextValue("report_type_"+i).equals("-1"))
	strTemp = " selected";
else	
	strTemp = "";
%>
              <option value="-1" <%=strTemp%>>Grade encoded and having any remark</option>
    <%
if(WI.fillTextValue("report_type_"+i).equals("-2"))
	strTemp = " selected";
else	
	strTemp = "";
%>
              <option value="-2" <%=strTemp%>>All remarks except PASS</option>
              <%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("report_type_"+i), false)%> 
            </select>		   	 		 </td>
      </tr>
<%	}
}
%>	
	
	
	
	
	
	
	
	
	
	
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  Number of Minimum <!--&quot;<strong><label id="gradeName">xyz</label></strong>&quot;--> Grade
      <input type="text" name="min_no" size="2" maxlength="2" value="<%=WI.fillTextValue("min_no")%>" class="textbox"
	   onKeyUp="AllowOnlyInteger('report_registrar','min_no');"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('report_registrar','min_no');style.backgroundColor='white'"> 
      <font size="1" color="#0000FF"><b>=&gt; for example, show student with min 3 failures</b></font></td>
    </tr>
<%if(!bolIsBasic){

try{
	iFieldCount = Integer.parseInt(WI.fillTextValue("course_count"));
}catch(Exception e){
	iFieldCount = 0;
}
%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="10%">Course</td>
      <td width="88%">
	  <%if(iFieldCount > 1){%>
	  	<select name="course_logic_0" style='width:60px;'> 
		 <%
		 strTemp = WI.fillTextValue("course_logic_0");
		 for(int j = 0; j < astrLogic.length; ++j){
		 if(strTemp.equals(Integer.toString(j)))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		 %>
		 <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
		 <%}%>
		 </select>
	  <%}%>
	  <select name="course_index_0" onChange="ReloadPage();" style="width:400px;">
          <%if(iFieldCount < 2){%><option value="">Select a course</option><%}%>
          <%
			strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 ";			
			if(bolFilterCollege)
				strTemp += " and c_index = "+strCIndex;
			strTemp += " order by course_name asc";
			
			if(WI.fillTextValue("course_index_0").length() > 0){
				if(strCourseIndexList.length() == 0)
					strCourseIndexList = WI.fillTextValue("course_index_0");
				else
					strCourseIndexList += "," +WI.fillTextValue("course_index_0");
			}
			%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, WI.fillTextValue("course_index_0"), false)%> </select>
		  <input name="course_count" type="text" size="1" maxlength="1" style="background:#D3EBFF" 
		  value="<%=WI.fillTextValue("course_count")%>" class="textbox"
	`		 onKeyUp="AllowOnlyInteger('report_registrar','course_count');"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('report_registrar','course_count');ReloadPage();">		 </td>
    </tr>

<%

if(iFieldCount > 1){
	for(i = 1; i < iFieldCount; ++i){
%>	
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="10%">Course</td>
      <td width="88%">
	  <select name="course_logic_<%=i%>" style='width:60px;'> 
		 <%
		 strTemp = WI.fillTextValue("course_logic_"+i);
		 for(int j = 0; j < astrLogic.length; ++j){
		 if(strTemp.equals(Integer.toString(j)))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		 %>
		 <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
		 <%}%>
		 </select>
	  <select name="course_index_<%=i%>" onChange="ReloadPage();" style="width:400px;">
         
          <%
			strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 ";			
			if(bolFilterCollege)
				strTemp += " and c_index = "+strCIndex;
			strTemp += " order by course_name asc";
			
			if(WI.fillTextValue("course_index_"+i).length() > 0){
				if(strCourseIndexList.length() == 0)
					strCourseIndexList = WI.fillTextValue("course_index_"+i);
				else
					strCourseIndexList += "," +WI.fillTextValue("course_index_"+i);
			}
			%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, WI.fillTextValue("course_index_"+i), false)%> </select>		   	 		 </td>
    </tr>
<%	}
}


try{
	iFieldCount = Integer.parseInt(WI.fillTextValue("major_count"));
}catch(Exception e){
	iFieldCount = 0;
}
%>	


    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major</td>
      <td>	  
	  <%if(iFieldCount > 1){%>
	  <select name="major_logic_0" style='width:60px;'> 
			 <%
			 strTemp = WI.fillTextValue("major_logic_0");
			 for(int j = 0; j < astrLogic.length; ++j){
			 if(strTemp.equals(Integer.toString(j)))
			 	strErrMsg = "selected";
			else
				strErrMsg = "";
			 %>
			 <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
			 <%}%>
			 </select>
	<%}%>
	  <select name="major_index_0" style="width:400px;">
          <%if(iFieldCount < 2){%><option value=""> ALL </option><%}%>
          <%
if(strCourseIndexList.length() > 0)
{
strTemp = " from major where is_del=0 and course_index in ("+ strCourseIndexList+")";
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index_0"), false)%> 
          <%}%>
        </select>
		<input name="major_count" type="text" size="1" maxlength="1"  style="background:#D3EBFF" 
		  value="<%=WI.fillTextValue("major_count")%>" class="textbox"
	`		 onKeyUp="AllowOnlyInteger('report_registrar','major_count');"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('report_registrar','major_count');ReloadPage();">	  </td>
    </tr>
	
	
<%

if(iFieldCount > 1){
	for(i = 1; i < iFieldCount; ++i){
%>	
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="10%">Major</td>
      <td width="88%">
	  <select name="major_logic_<%=i%>" style='width:60px;'> 
			 <%
			 strTemp = WI.fillTextValue("major_logic_"+i);
			 for(int j = 0; j < astrLogic.length; ++j){
			 if(strTemp.equals(Integer.toString(j)))
			 	strErrMsg = "selected";
			else
				strErrMsg = "";
			 %>
			 <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
			 <%}%>
			 </select>
	  <select name="major_index_<%=i%>" style="width:400px;">          
          <%

if(strCourseIndexList.length() > 0)
{
strTemp = " from major where is_del=0 and course_index in ("+strCourseIndexList +")";
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index_"+i), false)%> 
          <%}%>
        </select></td>
    </tr>
<%	}
}


try{
	iFieldCount = Integer.parseInt(WI.fillTextValue("year_level_count"));
}catch(Exception e){
	iFieldCount = 0;
}
%>			
    <tr>
      <td height="25">&nbsp;</td>
      <td>Year </td>
      <td>
	  <%if(iFieldCount > 1){%>
	  <select name="year_level_logic_0" style='width:60px;'> 
			 <%
			 strTemp = WI.fillTextValue("year_level_logic_0");
			 for(int j = 0; j < astrLogic.length; ++j){
			 if(strTemp.equals(Integer.toString(j)))
			 	strErrMsg = "selected";
			else
				strErrMsg = "";
			 %>
			 <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
			 <%}%>
			 </select><%}%>
	  <select name="year_level_0">
        <%if(iFieldCount < 2){%><option value="">No Filter</option><%}%>
        <%

strTemp = WI.fillTextValue("year_level_0");
for(int j = 1; j < astrYear.length; j++){
if(strTemp.equals(Integer.toString(j))) 
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="<%=j%>" <%=strErrMsg%>><%=astrYear[j]%></option>
<%}%>
      </select>
	  
	  <input name="year_level_count" type="text" size="1" maxlength="1" style="background:#D3EBFF" 
		  value="<%=WI.fillTextValue("year_level_count")%>" class="textbox"
			 onKeyUp="AllowOnlyInteger('report_registrar','year_level_count');"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('report_registrar','year_level_count');ReloadPage();">	  </td>
    </tr>
	
	
	
<%

if(iFieldCount > 1){
	for(i = 1; i < iFieldCount; ++i){
%>	
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="10%">Year</td>
      <td width="88%">
	  <select name="year_level_logic_<%=i%>" style='width:60px;'> 
			 <%
			 strTemp = WI.fillTextValue("year_level_logic_"+i);
			 for(int j = 0; j < astrLogic.length; ++j){
			 if(strTemp.equals(Integer.toString(j)))
			 	strErrMsg = "selected";
			else
				strErrMsg = "";
			 %>
			 <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
			 <%}%>
			 </select>
	 <select name="year_level_<%=i%>">        
        <%

strTemp = WI.fillTextValue("year_level_"+i);
for(int j = 1; j < astrYear.length; j++){
if(strTemp.equals(Integer.toString(j))) 
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="<%=j%>" <%=strErrMsg%>><%=astrYear[j]%></option>
<%}%>
      </select>		   	 		 </td>
    </tr>
<%	}
}%>		
	
	
	
	
	
<%}else{//basic.%>
	<tr >
	  <td height="25">&nbsp;</td>
	  <td width="10%">Grade Level </td>
	  <td width="88%"><select name="year_level" onChange="ReloadPage()">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("G_LEVEL","LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",WI.fillTextValue("year_level"),false)%>
      </select></td>
    </tr>
<%}

try{
	iFieldCount = Integer.parseInt(WI.fillTextValue("stud_id_count"));
}catch(Exception e){
	iFieldCount = 0;
}
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Student ID :
	<%if(iFieldCount > 1){%>
	  <select name="stud_id_logic_0" style='width:60px;'> 
	 <%
	 strTemp = WI.fillTextValue("stud_id_logic_0");
	 for(int j = 0; j < astrLogic.length; ++j){
	 if(strTemp.equals(Integer.toString(j)))
		strErrMsg = "selected";
	else
		strErrMsg = "";
	 %>
	 <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
	 <%}%>
	 </select> 
	 <%}%>
        <input name="stud_id_0" type="text" value="<%=WI.fillTextValue("stud_id_0")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('stud_id_0','coa_info_0','0');">
	  <input name="stud_id_count" type="text" size="1" maxlength="1"  style="background:#D3EBFF"
		  value="<%=WI.fillTextValue("stud_id_count")%>" class="textbox"
			 onKeyUp="AllowOnlyInteger('report_registrar','stud_id_count');"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('report_registrar','stud_id_count');ReloadPage();">
	  &nbsp;
	  <label id="coa_info_0" style="font-size:11px; position:absolute; width:500px; font-weight:bold; color:#0000FF"></label>       </td>
    </tr>
	
<%

if(iFieldCount > 1){
	for(i = 1; i < iFieldCount; ++i){
%>	
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Student ID : 
	  <select name="stud_id_logic_<%=i%>" style='width:60px;'> 
	 <%
	 strTemp = WI.fillTextValue("stud_id_logic_"+i);
	 for(int j = 0; j < astrLogic.length; ++j){
	 if(strTemp.equals(Integer.toString(j)))
		strErrMsg = "selected";
	else
		strErrMsg = "";
	 %>
	 <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
	 <%}%>
	 </select>
        <input name="stud_id_<%=i%>" type="text" value="<%=WI.fillTextValue("stud_id_"+i)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('stud_id_<%=i%>','coa_info_<%=i%>','0');">	  
	  
	  &nbsp;
	  <label id="coa_info_<%=i%>" style="font-size:11px; position:absolute; width:500px; font-weight:bold; color:#0000FF"></label>       </td>
    </tr>

<%	}
}


try{
	iFieldCount = Integer.parseInt(WI.fillTextValue("fac_id_count"));
}catch(Exception e){
	iFieldCount = 0;
}
%>			
	
    <tr>
        <td height="25">&nbsp;</td>
        <td colspan="2">Faculty ID : 
		<%if(iFieldCount > 1){%>
		<select name="fac_id_logic_<%=i%>" style='width:60px;'> 
	 <%
	 strTemp = WI.fillTextValue("fac_id_logic_"+i);
	 for(int j = 0; j < astrLogic.length; ++j){
	 if(strTemp.equals(Integer.toString(j)))
		strErrMsg = "selected";
	else
		strErrMsg = "";
	 %>
	 <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
	 <%}%>
	 </select><%}%>
        <input name="fac_id_0" type="text" value="<%=WI.fillTextValue("fac_id_0")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('fac_id_0','fac_info_0','1');">
	  <input name="fac_id_count" type="text" size="1" maxlength="1"  style="background:#D3EBFF"
		  value="<%=WI.fillTextValue("fac_id_count")%>" class="textbox"
			 onKeyUp="AllowOnlyInteger('report_registrar','fac_id_count');"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('report_registrar','fac_id_count');ReloadPage();">
	  &nbsp;
	  <label id="fac_info_0" style="font-size:11px; position:absolute; width:500px; font-weight:bold; color:#0000FF"></label>       </td>
    </tr>
    
<%

if(iFieldCount > 1){
	for(i = 1; i < iFieldCount; ++i){
%>	
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Faculty ID : 
	  <select name="fac_id_logic_<%=i%>" style='width:60px;'> 
	 <%
	 strTemp = WI.fillTextValue("fac_id_logic_"+i);
	 for(int j = 0; j < astrLogic.length; ++j){
	 if(strTemp.equals(Integer.toString(j)))
		strErrMsg = "selected";
	else
		strErrMsg = "";
	 %>
	 <option value="<%=j%>" <%=strErrMsg%>><%=astrLogic[j]%></option>
	 <%}%>
	 </select>
        <input name="fac_id_<%=i%>" type="text" value="<%=WI.fillTextValue("fac_id_"+i)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('fac_id_<%=i%>','fac_info_<%=i%>','1');">	  
	  
	  &nbsp;
	  <label id="fac_info_<%=i%>" style="font-size:11px; position:absolute; width:500px; font-weight:bold; color:#0000FF"></label>       </td>
    </tr>

<%	}
}

int j = 0;
%>				
	
	<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Print students whose lastname starts with 
        <select name="lname_from" onChange="ReloadPage()">
          <%
 strTemp = WI.fillTextValue("lname_from");
  //displays from and to to avoid conflict -- check the page ;-)
 for(i=0; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 j = i;%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select>
        to 
        <select name="lname_to">
          <option value="0"></option>
          <%
 strTemp = WI.fillTextValue("lname_to");
 
 for(i=++j; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select>
        &nbsp;&nbsp;&nbsp; </td>
    </tr>-->
    <tr bgcolor="#999999">
      <td height="25">&nbsp;</td>
      <td colspan="2">Additonal Filter ::&nbsp;Section 
      <input name="section_" type="text" value="<%=WI.fillTextValue("section_")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr bgcolor="#999999">
        <td height="25">&nbsp;</td>
<%
Vector vSubjectGroup = new Vector();
strTemp = "select GROUP_INDEX, GROUP_NAME as group_name from SUBJECT_GROUP where IS_DEL = 0 order by GROUP_NAME";
rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	vSubjectGroup.addElement(rs.getString(1));
	vSubjectGroup.addElement(rs.getString(2));
}rs.close();	


try{
	iFieldCount = Integer.parseInt(WI.fillTextValue("sub_group_count"));
}catch(Exception e){
	iFieldCount = 0;
}
		
%>
        <td colspan="2">Subject Group : &nbsp;
		
		<%if(iFieldCount > 1){%>
		  <select name="sub_group_logic_0" style='width:60px;'> 
		 <%
		 strTemp = WI.fillTextValue("subject_logic_0");
		 for(int k = 0; k < astrLogic.length; ++k){
		 if(strTemp.equals(Integer.toString(k)))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		 %>
		 <option value="<%=k%>" <%=strErrMsg%>><%=astrLogic[k]%></option>
		 <%}%>
		 </select><%}%>
		
		<select name="sub_group_0" style="width:100px;">
        <%if(iFieldCount < 2){%><option value="">All</option><%}%>
        <%

strTemp = WI.fillTextValue("sub_group_0");
for(j = 0; j < vSubjectGroup.size(); j+=2){
if(strTemp.equals( (String)vSubjectGroup.elementAt(j) )) 
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="<%=vSubjectGroup.elementAt(j)%>" <%=strErrMsg%>><%=vSubjectGroup.elementAt(j+1)%></option>
<%}%>
      </select>
	  
	  <input name="sub_group_count" type="text" size="1" maxlength="1" style="background:#D3EBFF" 
		  value="<%=WI.fillTextValue("sub_group_count")%>" class="textbox"
			 onKeyUp="AllowOnlyInteger('report_registrar','sub_group_count');"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('report_registrar','sub_group_count');ReloadPage();">
		</td>
    </tr>

<%
if(iFieldCount > 1){
	for(i = 1; i < iFieldCount; ++i){
%>	
    <tr bgcolor="#999999">
      <td height="25">&nbsp;</td>
      <td colspan="2">Subject Group : 
	      <select name="sub_group_logic_<%=i%>" style='width:60px;'> 
	 <%
	 strTemp = WI.fillTextValue("subject_logic_"+i);
	 for(int k = 0; k < astrLogic.length; ++k){
	 if(strTemp.equals(Integer.toString(k)))
		strErrMsg = "selected";
	else
		strErrMsg = "";
	 %>
	 <option value="<%=k%>" <%=strErrMsg%>><%=astrLogic[k]%></option>
	 <%}%>
	 </select>
	  
	  <select name="sub_group_<%=i%>" style="width:100px;">        
<%
strTemp = WI.fillTextValue("sub_group_"+i);
for(j = 0; j < vSubjectGroup.size(); j+=2){
if(strTemp.equals( (String)vSubjectGroup.elementAt(j) )) 
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="<%=vSubjectGroup.elementAt(j)%>" <%=strErrMsg%>><%=vSubjectGroup.elementAt(j+1)%></option>
<%}%>
      </select>
	  </td>
    </tr>

<%	}
}%>	
	
	
	
<%
try{
	iFieldCount = Integer.parseInt(WI.fillTextValue("subject_count"));
}catch(Exception e){
	iFieldCount = 0;
}
%>
    <tr bgcolor="#999999">
      <td height="25">&nbsp;</td>
      <td colspan="2">Subject Code : 
	  <%if(iFieldCount > 1){%>
	  <select name="subject_logic_0" style='width:60px;'> 
	 <%
	 strTemp = WI.fillTextValue("subject_logic_0");
	 for(int k = 0; k < astrLogic.length; ++k){
	 if(strTemp.equals(Integer.toString(k)))
		strErrMsg = "selected";
	else
		strErrMsg = "";
	 %>
	 <option value="<%=k%>" <%=strErrMsg%>><%=astrLogic[k]%></option>
	 <%}%>
	 </select><%}%>
      <input name="subject_0" type="text" value="<%=WI.fillTextValue("subject_0")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
      <font size="1">(starts with)</font>	
	  <input name="subject_count" type="text" size="1" maxlength="1"  style="background:#D3EBFF"
		  value="<%=WI.fillTextValue("subject_count")%>" class="textbox"
			 onKeyUp="AllowOnlyInteger('report_registrar','subject_count');"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('report_registrar','subject_count');ReloadPage();">	  </td>
    </tr>
	
	
<%
if(iFieldCount > 1){
	for(i = 1; i < iFieldCount; ++i){
%>	
    <tr bgcolor="#999999">
      <td height="25">&nbsp;</td>
      <td colspan="2">Subject Code : 
	  <select name="subject_logic_<%=i%>" style='width:60px;'> 
	 <%
	 strTemp = WI.fillTextValue("subject_logic_"+i);
	 for(int k = 0; k < astrLogic.length; ++k){
	 if(strTemp.equals(Integer.toString(k)))
		strErrMsg = "selected";
	else
		strErrMsg = "";
	 %>
	 <option value="<%=k%>" <%=strErrMsg%>><%=astrLogic[k]%></option>
	 <%}%>
	 </select>
        <input name="subject_<%=i%>" type="text" value="<%=WI.fillTextValue("subject_"+i)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">	 </td>
    </tr>

<%	}
}%>	
		
	
    <tr bgcolor="#999999">
        <td height="25">&nbsp;</td>
        <td colspan="2">
		Grade Range: 
	  
	  <input name="gr_fr" type="text" value="<%=WI.fillTextValue("gr_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="6"> 
	  to 
	  <input name="gr_to" type="text" value="<%=WI.fillTextValue("gr_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="6">		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Sort Result (ascending) : 
	  <select name="s1">
	  <option value=""></option>
<%
strTemp = WI.fillTextValue("s1");
if(strTemp.equals("id_number"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="id_number"<%=strErrMsg%>>Student ID</option>
<%
if(strTemp.equals("lname"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="lname"<%=strErrMsg%>>Last Name</option>
<%
if(strTemp.equals("fname"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="fname"<%=strErrMsg%>>First Name</option>
	</select>
	  (default is by id_number)	  
	  &nbsp;&nbsp;
	  <a href="javascript:ShowResult();"><img src="../../../images/refresh.gif" border="0"></a>
		
		<%
		strTemp = WI.fillTextValue("export_excel");
		if(strTemp.length() > 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%><input type="checkbox" name="export_excel" value="1" <%=strErrMsg%>>		Click to generate downloadable excel format.
	  
	  </td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%if(!bolFilterCollege || true){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
<tr>
      <td><div onClick="showBranch('branch1');swapFolder('folder1')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
          <b><font color="#0000FF">For Graphical Presentation</font></b><br>
		  <font color="#FF0000"><strong>Percentage will be rounded to zero if less that .5</strong></font>
		  </div>
		  <span class="branch1" id="branch1">
		  	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<tr>					
					<td>Grade Factor per College vs. All Colleges
					
					<select name="remark_index_col_all_col" style="width:100px;">
						<option value="">Please choose a remark</option>
              			<%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("remark_index_col_all_col"), false)%> 
           			</select>					
					<%if(bolHasColOverTotCol){%>
					<a href="javascript:ViewGradeFactorPerCollege('0');"><img src="../../../images/view.gif" height="25" border="0"></a>
					<%}%>					</td>
				</tr>
				<!--<tr>
					<td>Grade Factor per College vs. Total population
					<select name="remark_index_col_total_pop" style="width:100px;">
              			<option value="">Please choose a remark</option>
						<%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("remark_index_col_total_pop"), false)%> 
           			</select>
					</td>
				</tr>-->
				<tr>					
					<td>Grade Factor per Course vs. All College Courses
					<select name="remark_index_course_all_col_course" style="width:100px;">
              			<option value="">Please choose a remark</option>
						<%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("remark_index_course_all_col_course"), false)%> 
           			</select>
					<%if(bolHasCourseOverTotColCourse){%>
					<a href="javascript:ViewGradeFactorPerCollege('1');"><img src="../../../images/view.gif" height="25" border="0"></a>
					<%}%>					</td>
				</tr>
				<tr>					
					<td>Academic Deficiencies (Subject Per Course) 
					    <select name="subject_per_course" style="width:100px;">
              			<option value="">Please choose a remark</option>
						<%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("subject_per_course"), false)%> 
           			</select>
					
					<select name="subject_per_course_index" style="width:200px;">
              			<option value="">Please choose a course</option>
						<%
						strTemp = " from course_offered where is_valid =1 and is_offered = 1";
						if(strCourseIndexList.length() > 0)
							strTemp +=" and course_index in ("+strCourseIndexList+")";
						strTemp += " order by course_code";
						
						%>
						<%=dbOP.loadCombo("course_index", "course_code, course_name", strTemp,request.getParameter("subject_per_course_index"), false)%> 
           			</select>
					
					<%if(bolHasSubGenEd || bolHasSubProf){%>
					<a href="javascript:ViewGradeFactorPerCollege('2');"><img src="../../../images/view.gif" height="25" border="0"></a>
					<%}%>					</td>
				</tr>
				
				
				<tr>					
					<td>Academic Deficiencies (Faculty per Subject) 
					<select name="faculty_per_subject" style="width:100px;">
              			<option value="">Please choose a remark</option>
						<%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("faculty_per_subject"), false)%> 
           			</select>
					
					<select name="faculty_per_subject_index" style="width:200px;">
              			<%if(strLoadComboSubIndex == null || strLoadComboSubIndex.length() == 0){%>
						<option value="">Subject list after page is reloaded</option>
						<%}
						if(strLoadComboSubIndex != null && strLoadComboSubIndex.length() > 0){
						strTemp = "select sub_index, sub_code, sub_name from subject where sub_index in ("+strLoadComboSubIndex+") order by sub_code ";						
						rs = dbOP.executeQuery(strTemp);
						while(rs.next()){
						%>
						<option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> (<%=rs.getString(3)%>)</option>
						<%}rs.close();}%>
           			</select>
					
					<%if(strLoadComboSubIndex != null && strLoadComboSubIndex.length() > 0){%>
					<a href="javascript:ViewGradeFactorPerCollege('3');"><img src="../../../images/view.gif" height="25" border="0"></a>
					<%}%>					</td>
				</tr>
				<!--<tr>					
					<td>Grade Factor per Course vs. Total College population
					<select name="remark_index_course_tot_col_pop" style="width:100px;">
              			<option value="">Please choose a remark</option>
						<%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("remark_index_course_tot_col_pop"), false)%> 
           			</select>
					</td>
				</tr>-->
			</table>
		  </span>
	</td>
</tr>
</table>
<%}


if(vRetResult != null && vRetResult.size() > 0){
int iMaxRow = 15;
if(WI.fillTextValue("report_type_0").equals("0"))
	iMaxRow = 12;
	
utility.CreateExcelSheet ces = new utility.CreateExcelSheet();
ces.dontCreateFile(bolShowData);
ces.createFile(dbOP, request, "StudentGradeStatus");	
ces.createNewSheet("StudentGradeStatus");
%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<!--    <tr>
      <TD colspan="3" style="font-size:11px; font-weight:bold">&nbsp;&nbsp; <u>Report Name : 
        <input name="report_name" type="text" value="<%=WI.fillTextValue("report_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="UpdateReportName();style.backgroundColor='white'" size="90" style="font-size:11px;">
      </u></TD>
    </tr>-->
    <tr> 
      <TD width="27%" style="font-size:11px">&nbsp;&nbsp;&nbsp;<strong>Total Subject Count : <%=vRetResult.size() /iMaxRow%></strong></TD>
      
	
	
      <%if(!bolShowData){
	  strTemp = "../../../download/StudentGradeStatus_"+WI.getTodaysDate()+".xls";
	  %>
	  <TD width="51%" align="right">
	  <div id="display_download" style="visibility:hidden; display:none;"><a href="<%=strTemp%>"><img src="../../../images/download.gif" border="0"></a>Click to download excel file</div>
	  </TD>
	  <%}%>
	  <TD width="22%" align="right"><a href='javascript:PrintPage();'> <img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print</font></TD>
    </tr>
    <tr>
      <TD colspan="3">
<%
strTemp = WI.fillTextValue("rem_course");
if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>	  <input type="checkbox" name="rem_course" value="1" <%=strTemp%>>Remove Course information 
<%
strTemp = WI.fillTextValue("rem_fac");
if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>      <input type="checkbox" name="rem_fac" value="1" <%=strTemp%>>Remove Instructor information	  
<%
strTemp = WI.fillTextValue("show_grade");
if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>      <input type="checkbox" name="show_grade" value="1" <%=strTemp%>> Show Grade  
		<input type="checkbox" name="show_address" value="checked" <%=WI.fillTextValue("show_address")%>> Show Address	</TD>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <%
	ces.setFontSize(11);				
	ces.setBold(true);
	ces.setBorder(0);
	ces.setBorderLineStyle(0);
	ces.setAlignment(1);
	ces.addData("LIST OF STUDENTS WITH GRADE STATUS", true, 7, 0);
  %>
    <tr> 
      <td height="25" colspan="8" bgcolor="#FFFF99" class="thinborder" style="font-weight:bold"><div align="center">
	  <label id="report_n">LIST OF STUDENTS WITH GRADE STATUS</label></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
	<%
	ces.addData("Count");
	ces.addData("Student ID");
	ces.addData("Student Name");
	ces.addData("Subject Code");
	ces.addData("Grade");
	ces.addData("Course");
	ces.addData("Section");
	ces.addData("Instructor", true);
	ces.setAlignment(0);
	ces.setBold(false);
	%>
      <td width="2%" class="thinborder" align="center"><strong><font size="1">Count</font></strong></td> 
      <td width="10%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Student ID </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>Student Name </strong></font></div></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">Subject Code </font></strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">Grade</font></strong></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>Course</strong></font></div></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>Section</strong></font></td>
      <td width="18%" align="center" class="thinborder"><font size="1"><strong>Instructor</strong></font></td>
<%
String strStudID = null;
int iCount = 0;
int iCountExcel = 0;
boolean bolShowID = false;//show Name and show view icon.

for(i = 0; i< vRetResult.size() ; i += iMaxRow){
bolShowID = false;
if(strStudID == null) {
	bolShowID = true;
	strStudID = (String)vRetResult.elementAt(i);
}
else {
	if(strStudID.compareTo(WI.getStrValue(vRetResult.elementAt(i))) != 0) {//id is different.
		bolShowID = true;
		strStudID = (String)vRetResult.elementAt(i);
	}

} 
++iCountExcel;
ces.addData(iCountExcel+".");
ces.addData((String)vRetResult.elementAt(i));
%>
    <tr>
      <td class="thinborder">&nbsp;<%if(bolShowID){%><%=++iCount%>.<%}%></td> 
      <td height="25" class="thinborder">
	  <%if(bolShowID) {%>
	  <a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i)%>");'><%=(String)vRetResult.elementAt(i)%></a>
	  <%}else{%>&nbsp;<%}%>	  </td>
	  <%
	  strTemp = "&nbsp;";
	  if(bolShowID)
	  	strTemp = (String)vRetResult.elementAt(i + 1);
	  ces.addData((String)vRetResult.elementAt(i + 1));	
	  %>
      <td class="thinborder"><%=strTemp%></td>
	  <%
	  strTemp = (String)vRetResult.elementAt(i + 4);
	  ces.addData(strTemp);	
	  %>
	  <td class="thinborder"><%=strTemp%></td>
	  <%
	  strTemp = "&nbsp;";
	  if(iMaxRow > 12)
	  	strTemp = WI.getStrValue(vRetResult.elementAt(i + 12), "&nbsp;");
	ces.addData(strTemp);
	  %>
      <td class="thinborder"><%=strTemp%></td>
	  <%
	  strTemp = "&nbsp;";
	  if(bolShowID)
	  	strTemp = (String)vRetResult.elementAt(i + 2) + WI.getStrValue((String)vRetResult.elementAt(i + 3)," / ","","");
	  ces.addData((String)vRetResult.elementAt(i + 2) + WI.getStrValue((String)vRetResult.elementAt(i + 3)," / ","",""));
	  %>
      <td class="thinborder"><%=strTemp%></td>
	  <%
	  strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 11),"N/F");
	  ces.addData(strTemp);	
	  %>
      <td class="thinborder"><%=strTemp%></td>
	  <%
	  strTemp = WI.getStrValue(vRetResult.elementAt(i + 10),"N/F");
	  ces.addData(strTemp, true);	
	  %>
      <td class="thinborder"><%=strTemp%> </td>      	
	 </tr>
<%}%>
  </table>
<%if(vSubjectSummary != null && vSubjectSummary.size() > 0) {%><br>
 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
        <tr bgcolor="#DDDDDD">
			<TD width="25%" class="thinborderBOTTOM">Subject Code </TD>
			<TD width="22%" class="thinborderBOTTOM"># of Student </TD>
			<TD class="thinborderBOTTOMRIGHT">&nbsp;</TD>
			<TD class="thinborderBOTTOM">&nbsp;</TD>
			<TD width="25%" class="thinborderBOTTOM">Subject Code </TD>
        	<TD width="22%" class="thinborderBOTTOM"># of Student</TD>
        </tr>
<%//iCount = 0;
for(i =0; i < vSubjectSummary.size(); i += 2){//iCount += Integer.parseInt((String)vSubjectSummary.elementAt(i + 1));%>
        <tr>
          <TD class="thinborderNONE"><%=vSubjectSummary.elementAt(i)%></TD>
          <TD class="thinborderNONE"><%=vSubjectSummary.elementAt(i + 1)%></TD>
          <TD class="thinborderRIGHT">&nbsp;</TD>
          <TD class="thinborderNONE">&nbsp;</TD>
          <TD class="thinborderNONE">&nbsp;<%i = i +2; if(i < vSubjectSummary.size()){//iCount += Integer.parseInt((String)vSubjectSummary.elementAt(i + 1));%> <%=vSubjectSummary.elementAt(i)%><%}%></TD>
          <TD class="thinborderNONE">&nbsp;<%if(i < vSubjectSummary.size()){%> <%=vSubjectSummary.elementAt(i + 1)%><%}%></TD>
        </tr>
<%}//System.out.println(iCount);%>
 </table>
<%}%>

 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>

      <TD align="right"><a href='javascript:PrintPage();'> <img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print </font></TD>
        </tr>
 </table>
<%
ces.writeAndClose(request);
if(!bolShowData){
	strTemp = "../../../download/StudentGradeStatus_"+WI.getTodaysDate()+".xls";
%><script>DisplayDownload();</script>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td><a href="<%=strTemp%>"><img src="../../../images/download.gif" border="0"></a>Click to download excel file</td></tr>
	
	</table>
<%}

}//only if vRetResult not null
%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="showResult">
<input type="hidden" name="report_type_name">
<input type="hidden" name="remark_name" value="<%=WI.fillTextValue("remark_name")%>">
<input type="hidden" name="print_pg">
<input type="hidden" name="installDir" value="installDir">

<input type="hidden" name="pmt_schedule_count_prev" value="<%=WI.fillTextValue("pmt_schedule_count_prev")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>