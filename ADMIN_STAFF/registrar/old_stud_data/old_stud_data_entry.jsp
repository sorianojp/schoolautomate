<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
var i = 1;
function printKeyCode() {
	if(i == 1) {
		alert(event.keyCode);
		++i;
	}
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=studdata_entry.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusOnGrade()
{
	return;
	//document.studdata_entry.grade.focus();
}
function ViewResidency()
{
	var strStudID = document.studdata_entry.stud_id.value;
	if(strStudID.length == 0)
	{
		alert("Please enter student ID.");
		return;
	}
	location = "../residency/residency_status.jsp?stud_id="+escape(strStudID);
}
function ReloadPage()
{
	document.studdata_entry.deleteRecord.value = 0;
	document.studdata_entry.addRecord.value = 0;
	document.studdata_entry.submit();
}
function CheckStudent()
{
	document.studdata_entry.checkStudent.value = "1";
}
function ChangeProgram()
{
	document.studdata_entry.changeProgram.value="1";
	ReloadPage();
}
function AddRecord()
{
	document.studdata_entry.deleteRecord.value = 0;
	document.studdata_entry.addRecord.value = 1;

	//get the remark name,
	document.studdata_entry.remarkName.value = document.studdata_entry.remark_index[document.studdata_entry.remark_index.selectedIndex].text;
//	alert(document.studdata_entry.remarkName.value);
	document.studdata_entry.submit();
}
function DeleteRecord(strTargetIndex)
{
	document.studdata_entry.deleteRecord.value = 1;
	document.studdata_entry.addRecord.value = 0;

	document.studdata_entry.info_index.value = strTargetIndex;

	document.studdata_entry.submit();
}
function DisplaySYTo() {
	var strSYFrom = document.studdata_entry.sy_from.value;
	if(strSYFrom.length == 4)
		document.studdata_entry.sy_to.value = eval(strSYFrom) + 1;
	if(strSYFrom.length < 4)
		document.studdata_entry.sy_to.value = "";
}

// for AUF / CGH ONLY!!!

var iFailedSelectedIndex = -1;
var iPassedSelectedIndex = -1;
function GetFailedSelectedIndex(){
	for (v= document.studdata_entry.remark_index.length -1 ; v >= 0; --v){
		if (eval("document.studdata_entry.remark_index[" + v + "].text").toLowerCase().indexOf('fail') != -1)
			return v;
	}

}
function GetPassedSelectedIndex(strRemark){
	for (v= document.studdata_entry.remark_index.length -1 ; v >= 0; --v){
		if (eval("document.studdata_entry.remark_index[" + v + "].text").toLowerCase().indexOf('pass') != -1)
			return v;
	}

}

//// - all about ajax..
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.studdata_entry.stud_id.value;
		if(strCompleteName.length < 2)
			return;

		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.studdata_entry.stud_id.value = strID;
	document.studdata_entry.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.studdata_entry.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

function CopyInternshipPlace() {
	var iSelIndex = document.studdata_entry.copy_place.selectedIndex;
	if(iSelIndex == 0)
		document.studdata_entry.internship_place.value = '';
	else	
		document.studdata_entry.internship_place.value = document.studdata_entry.copy_place[document.studdata_entry.copy_place.selectedIndex].text;
}
//I have to now make sure it copies
function CopyInternshipPlace2() {
	document.studdata_entry.i_place.value = "";
	document.studdata_entry.i_hosp.value = "";
	
	var iPlace = document.studdata_entry.i_place_sel[document.studdata_entry.i_place_sel.selectedIndex].value;
	var iHosp = document.studdata_entry.i_hosp_sel[document.studdata_entry.i_hosp_sel.selectedIndex].value;
	
	if(iPlace.length > 0) {
		document.studdata_entry.internship_place.value =iHosp + "<br>"+ iPlace;
	}
	
}
function CopyInternshipPlace3() {
	var iPlace = document.studdata_entry.i_place.value;
	var iHosp  = document.studdata_entry.i_hosp.value;
	
	if(iPlace.length > 0) {
		document.studdata_entry.internship_place.value =iHosp + "<br>"+ iPlace;
	}
}

</script>
<body bgcolor="#D2AE72" onLoad="focusOnGrade();">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.OfflineAdmission,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strStudName = null;
	Vector vTemp = null;
	int i=0; int j=0;
	String strCYFrom = null;
	String strCYTo = null;
	String strCourseType = null;//0->Under graduate, 1->Doctoral, 2-> doctor of medicine, 3-> with proper, 4-> non semestral.
	Vector vStudInfo = null;
	String strSubName = null;String strSubCode = null;
	float fCredit = 0;
	
	String strSQLQuery = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-OLD STUDENT DATA MANAGEMENT","old_stud_data_entry.jsp");
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
														"Registrar Management","OLD STUDENT DATA MANAGEMENT",request.getRemoteAddr(),
														"old_stud_data_entry.jsp");
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
Vector vGradeEncodingInfo = new Vector();
int iIndexOf = 0;

GradeSystem GS = new GradeSystem();
String strUserIndex = null;
OfflineAdmission offlineAdmission = new OfflineAdmission();
if(WI.fillTextValue("stud_id").length() > 0 && WI.fillTextValue("sy_from").length() > 0 &&
	WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("semester").length() > 0) {
	vStudInfo = offlineAdmission.getStudentBasicInfo(dbOP,WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),
					WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vStudInfo == null)
		vStudInfo = offlineAdmission.getStudentBasicInfo(dbOP,WI.fillTextValue("stud_id"));
}

if(vStudInfo != null && vStudInfo.size() > 0)
{//System.out.println(vStudInfo);
	strUserIndex = (String)vStudInfo.elementAt(12);
	strStudName = WI.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),1);
	strCYFrom = (String)vStudInfo.elementAt(3);
	strCYTo   = (String)vStudInfo.elementAt(4);
	
	//get grade encoding information.
	strSQLQuery = "select gs_index, id_number, fname, mname, lname, g_sheet_final.create_date from g_sheet_final join user_table on (user_table.user_index = g_sheet_final.encoded_by) "+
					" where user_index_ = "+strUserIndex+" and g_sheet_final.is_valid = 1 and cur_hist_index = "+(String)vStudInfo.elementAt(13);
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vGradeEncodingInfo.addElement(new Integer(rs.getInt(1)));
		vGradeEncodingInfo.addElement(rs.getString(2));
		vGradeEncodingInfo.addElement(WebInterface.formatName(rs.getString(3), rs.getString(4), rs.getString(5), 4));
		vGradeEncodingInfo.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(6), true));
	}
	rs.close();

	strTemp = WI.fillTextValue("addRecord");
	if(strTemp.compareTo("1") == 0)
	{
		//add it here and give a message.
		if(GS.createFinalGrade(dbOP,request,true))//true -> old data.
			strErrMsg = "Grade added successfully.";
		else
			strErrMsg = GS.getErrMsg();
	}
	else //either it is edit or delete -- this page handles add/edit/delete/viewall :-)
	{
		strTemp = WI.fillTextValue("deleteRecord");
		if(strTemp.compareTo("1") == 0)
		{
			if(GS.delFinalGrade(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
				strErrMsg = "Grade deleted successfully.";
			else
				strErrMsg = GS.getErrMsg();
		}
	}

	strCourseType = " and is_del=0 and is_valid=1";
	strCourseType = dbOP.mapOneToOther("COURSE_OFFERED","course_index",(String)vStudInfo.elementAt(5),"DEGREE_TYPE",strCourseType);

}
else
	strErrMsg = offlineAdmission.getErrMsg();


if(strErrMsg == null) strErrMsg = "";

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
//strSchCode = "CGH";

boolean bolIsCGH = strSchCode.startsWith("CGH");
boolean bolIsWUP = strSchCode.startsWith("WUP");


//UPDATE THE INTERNSHIP HOSPITAL AND LOCATION NAME.. 
if(WI.fillTextValue("i_hosp").length() > 0) {
	strSQLQuery = "insert into INTERNSHIP_PLACE_PRELOAD (IPLACE) values ("+WI.getInsertValueForDB(WI.fillTextValue("i_place"), true, null)+")"; 
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	strSQLQuery = "insert into INTERNSHIP_HOSP_PRELOAD (HOSP_NAME) values ("+WI.getInsertValueForDB(WI.fillTextValue("i_hosp"), true, null)+")";
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false); 
}
%>


<form action="./old_stud_data_entry.jsp" method="post" name="studdata_entry">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>::::
          OLD STUDENT DATA MANAGEMENT ::::<br>
          </strong>(Encoding of old student's academic records)</font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
	  <td width="2%" height="25">&nbsp;</td>
      <td width="96%"><strong><%=strErrMsg%></strong></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 9);
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%}%>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Student ID</td>
      <td width="13%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">
      </td>
      <td width="8%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="61%"><font size="1">
        <input name="image" type="image" onClick="CheckStudent();" src="../../../images/form_proceed.gif">
        </font> </td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">SY /Term : </td>
      <td colspan="3"><input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="DisplaySYTo();">
        to
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> <font size="1">&nbsp; </font></td>
    </tr>
    <tr >
      <td  colspan="5" height="25">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>
	  <hr size="1"></td>
    </tr>
  </table>
<%if(vStudInfo != null && vStudInfo.size() > 0)
{%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td height="25">&nbsp;</td>
      <td>Student Name : <strong><%=strStudName%></strong></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td>Course/Major (curriculum year) <font size="1"><strong>NOTE:</strong>
        To edit course or curriculm please edit student's information.</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong><%=(String)vStudInfo.elementAt(7)%>
        <%
	  if((String)vStudInfo.elementAt(8) != null){%>
        /<%=(String)vStudInfo.elementAt(8)%>
        <%}%>
        (<%=(String)vStudInfo.elementAt(3)+" - "+ (String)vStudInfo.elementAt(4)%>)</strong></td>
</tr>
<tr>
	<td colspan="2"><hr size="1"></td>
</tr>
  </table>
    <input type="hidden" name="course_index" value="<%=(String)vStudInfo.elementAt(5)%>">
    <input type="hidden" name="major_index" value="<%=WI.getStrValue(vStudInfo.elementAt(6))%>">
    <input type="hidden" name="cy_from" value="<%=(String)vStudInfo.elementAt(3)%>">
    <input type="hidden" name="cy_to" value="<%=(String)vStudInfo.elementAt(4)%>">
<%
if(strCYTo.length() > 0)
{%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td width="84%">&nbsp; </td>
    </tr>
</table>
<%
if(strCourseType.compareTo("4") != 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(strCourseType.compareTo("1") !=0){
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Year
        <select name="year">
          <option value=""></option>
          <%
strTemp = request.getParameter("year");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
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
          <%}%>
        </select>
        <%}//if degree type is not 1(masters)
%>
      </td>
      <td height="25">
        <%
if(strCourseType.compareTo("3") ==0){%>
        <select name="prep_prop_stat">
          <option value="1">Preparatory</option>
          <%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
        </select>
        <%}%>
      </td>
      <td colspan="3"> &nbsp;&nbsp;
        <!--        <%if(request.getParameter("is_internship") != null && request.getParameter("is_internship").compareTo("1") == 0){%>
        <input name="is_internship" type="checkbox" value="1" checked>
        <%}else{%>
        <input name="is_internship" type="checkbox" value="1">
        <%}%>
        (check if INTERNSHIP)-->
        <a href="javascript:ReloadPage();"> <img src="../../../images/refresh.gif" border="0"></a><font size="1">
        Click to refresh page</font> </td>
    </tr>
    <tr>
      <td width="2%">&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td width="14%">&nbsp; </td>
      <td width="21%">&nbsp;</td>
      <td width="30%">&nbsp;</td>
      <td width="19%">&nbsp;</td>
    </tr>
  </table>
<%}//cy from is not null.
strErrMsg = ""; String strSubIndex = null;
if(WI.fillTextValue("course_index").length() > 0)
{
	vTemp = GS.getSubjectList(dbOP, request, strCYFrom, strCYTo, true);
	if(vTemp == null) {
		strErrMsg = "No subject found. Please check curriculm year in student enrollment history. (Probable cause of this error is migration)";
		vTemp = new Vector();
	}
}
if(strErrMsg == null) strErrMsg = "";
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%">&nbsp;</td>
      <td colspan="2"><font size="1"><strong><%=strErrMsg%></strong> &nbsp;&nbsp;
        <a href="javascript:ViewResidency();"><img src="../../../images/view.gif" border="0"></a>click
        to view Residency status of student</font></td>
    </tr>
  </table>
<%
if(vTemp != null) {
	if(vTemp.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="8" ><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="25" >&nbsp;</td>
      <td width="41%"  height="25" ><div align="left"><font size="1">
          <%if(WI.fillTextValue("is_internship").compareTo("1") == 0){%>
          <input name="is_internship" type="checkbox" value="1" checked onClick="ReloadPage();">
          <%}else{%>
          <input name="is_internship" type="checkbox" value="1" onClick="ReloadPage();">
          <%}%>
          (check if INTERNSHIP/CLERKSHIP/CADETSHIP subject) <strong><br>
          SUBJECT CODE</strong></font></div></td>
      <td width="9%" ><strong><font size="1">UNIT</font></strong></td>
      <td width="14%" ><div align="left"><font size="1"><strong>CREDITS EARNED</strong></font></div></td>
      <td width="9%" ><center>
        <font size="1"><strong> GRADE
          <%if(bolIsCGH){%>
          <br>
          FP
          <%}%>
          </strong></font>
      </center>      </td>
<%if(bolIsCGH){%>
      <td width="9%" ><center>
        <font size="1"><strong>GRADE <br>
          %ge</strong></font>
      </center>      </td>
<%}%>
      <td width="17%" ><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" ><select name="subject" onChange="ReloadPage();">
          <%//System.out.println(vTemp);
	strTemp = WI.fillTextValue("subject");//cur_index.
	for(i = 0; i< vTemp.size(); ++i) {
		if(strTemp.compareTo( (String)vTemp.elementAt(i)) ==0) {
			strSubIndex = (String)vTemp.elementAt(i + 5);
			strSubName  = (String)vTemp.elementAt(i+2);
			strSubCode  = (String)vTemp.elementAt(i+1);
			fCredit     = Float.parseFloat(WI.getStrValue(vTemp.elementAt(i+3),"0"))+Float.parseFloat(WI.getStrValue(vTemp.elementAt(i+4),"0"));
			%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i+1)%></option>
          <%}else{%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i+1)%></option>
          <%}
i = i+5;
}//System.out.println(vTemp);
if(strSubName == null && fCredit ==0 && vTemp.size() > 0)//first time - so select the top result.
{
	strSubIndex = (String)vTemp.elementAt(5);
	strSubName = (String)vTemp.elementAt(2);
	fCredit  = Float.parseFloat(WI.getStrValue(vTemp.elementAt(3),"0"))+Float.parseFloat(WI.getStrValue(vTemp.elementAt(4),"0"));
}%>
        </select>
<input type="hidden" name="sub_index_" value="<%=strSubIndex%>">
        <%if(WI.getStrValue(strSubCode).indexOf("NSTP") != -1){
strTemp = WI.fillTextValue("nstp_val");%>
        <select name="nstp_val" style="font-weight:bold;">
          <option value="CWTS">CWTS</option>
          <%
if(strTemp.compareTo("LTS") ==0){%>
          <option value="LTS" selected>LTS</option>
          <%}else{%>
          <option value="LTS">LTS</option>
          <%}if(strTemp.compareTo("ROTC") ==0){%>
          <option value="ROTC" selected>ROTC</option>
          <%}else{%>
          <option value="ROTC">ROTC</option>
          <%}%>
        </select>
        <%}//only if subject is NSTP %>      </td>
      <td valign="top"><%=fCredit%></td>
      <td valign="top"><input name="credit_earned" type="text" size="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=fCredit%>"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td valign="top">
<%
	if (strSchCode.startsWith("AUF") || strSchCode.startsWith("CGH"))
		strTemp = "UpdateRemarks('grade');";
	else
		strTemp = "";
%>
	  <input name="grade" type="text" size="4" maxlength="5" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="<%=strTemp%>style.backgroundColor='white'"
	  onKeyPress="if(event.keyCode == 115 || event.keyCode ==83 || event.keyCode == 47) event.returnValue=true; else if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
<%if(bolIsCGH){%>
      <td align="center"><input name="grade_percent" type="text" size="3" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white';UpdateRemarks('grade_percent');"
	  	  onKeyUp="AllowOnlyFloat('studdata_entry','grade_percent');"></td>
<%}%>
      <td valign="top"><select name="remark_index">
          <%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("remark_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td></td>
      <td colspan="7">Subject Title : <%=strSubName%></td>
    </tr>

<%if(WI.fillTextValue("is_internship").compareTo("1") ==0){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="6" >Inclusive date of internship/clerkship :
        <input name="internship_date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("internship_date_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('studdata_entry.internship_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;&nbsp;to
        &nbsp;&nbsp; <input name="internship_date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("internship_date_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('studdata_entry.internship_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;</td>
    </tr>
<%if(strSchCode.startsWith("AUF")){%>
    <tr bgcolor="#DDDDDD">
      <td height="25" class="thinborderTOPLEFT">&nbsp;</td>
      <td  height="25" colspan="6" style="font-size:11px;" class="thinborderTOPRIGHT">Hospital Name :<select name="i_hosp_sel" onChange="CopyInternshipPlace2();" style="width:392px;">
	  <option value="">Select to copy</option>
<%=dbOP.loadCombo("HOSP_NAME","HOSP_NAME"," from INTERNSHIP_HOSP_PRELOAD order by hosp_name",null, false)%>
	  </select>
	  &nbsp;&nbsp;&nbsp;
	  Place :<select name="i_place_sel" onChange="CopyInternshipPlace2();" style="width:250px;">
	  <option value="">Select to copy</option>
<%=dbOP.loadCombo("IPLACE","IPLACE"," from INTERNSHIP_PLACE_PRELOAD order by IPLACE",null, false)%>
	  </select>	</td>
    </tr>
    <tr bgcolor="#DDDDDD">
      <td height="25" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td  height="25" colspan="6" style="font-size:11px;" class="thinborderBOTTOMRIGHT">(or) Enter Hospital Name : 
	  <input name="i_hosp" type="text" size="60" maxlength="92" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="CopyInternshipPlace3();style.backgroundColor='white'">
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;
	  Place : 
	  <input name="i_place" type="text" size="32" maxlength="32" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="CopyInternshipPlace3();style.backgroundColor='white'">
	  
	  </td>
    </tr>

<%}else{%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="6" >	  <select name="copy_place" onChange="CopyInternshipPlace();">
	  <option value="">Select to copy</option>
<%=dbOP.loadCombo("distinct INTERNSHIP_PLACE","INTERNSHIP_PLACE"," from g_sheet_final where INTERNSHIP_PLACE is not null",null, false)%>
	  </select>	</td>
    </tr>
<%}%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="6" >Hospital Name and place taken :
        <input name="internship_place" type="text" size="60" maxlength="128" value="<%=WI.fillTextValue("internship_place")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">(Note : add &lt;br&gt; for 2nd line)</font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="6" >Duration :
        <input name="internship_dur" type="text" size="5" value="<%=WI.fillTextValue("internship_dur")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <select name="internship_dur_unit">
          <option value="0">Hours</option>
<%
strTemp = WI.fillTextValue("internship_dur_unit");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Weeks</option>
<%}else{%>
          <option value="1">Weeks</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Months</option>
<%}else{%>          <option value="2">Months</option>
<%}%>        </select></td>
    </tr>
<%}%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" >&nbsp;</td>
      <td  colspan="5" > <div align="left"> <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click
          to add</font> </div></td>
    </tr>
  </table>
<%}///do not show if vTmep is empty.. 
//get here the list of grade created already for this year/sem course
	vTemp = GS.viewFinalGradePerYrSem(dbOP, request);
	//System.out.println(GS.getErrMsg());
	if(vTemp != null && vTemp.size() > 0)
	{%>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="11" bgcolor="#B9B292" class="thinborder"><div align="center">LIST OF
          GRADE FOR <%=WI.getStrValue(request.getParameter("year"),"(N/A)")%>
          YEAR- <%=request.getParameter("semester")%> SEM
          <%
		  if(request.getParameter("is_internship") != null && request.getParameter("is_internship").compareTo("1") ==0) //it is internship
          {%>
          <strong>(Internship)</strong>
          <%}%>
        </div></td>
    </tr>
    <tr>
      <td width="16%"  height="25" class="thinborder"><font size="1"><strong>SUBJECT
          CODE</strong></font></td>
      <td width="30%" class="thinborder"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="7%" class="thinborder"><font size="1"><strong>UNIT</strong></font></td>
      <td width="7%" class="thinborder"><font size="1"><strong>CREDITS EARNED</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong> GRADE<%if(bolIsCGH){%><br>FP<%}%></strong></font></td>
<%if(bolIsCGH){%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>GRADE <br>%ge</strong></font></td>
<%}%>
      <td width="12%" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
      <td width="10%" class="thinborder"><font size="1"><strong>Encoded By</strong></font></td>
      <td width="10%" class="thinborder"><font size="1"><strong>Date Encoded</strong></font></td>
      <td width="7%" class="thinborder">&nbsp;</td>
    </tr>
    <%//System.out.println(vTemp);
	int p=0;
	String strGrade = null;
	for(i=0; i< vTemp.size(); ++i,++p)
	{//System.out.println((String)vTemp.elementAt(3) + " : "+(String)vTemp.elementAt(4));
	fCredit  = Float.parseFloat(WI.getStrValue(vTemp.elementAt(i+3),"0"))+Float.parseFloat(WI.getStrValue(vTemp.elementAt(i+4),"0"));
	
	iIndexOf = vGradeEncodingInfo.indexOf(new Integer((String)vTemp.elementAt(i)));
	if(iIndexOf == -1) {
		strTemp = null;
		strErrMsg = null;
	}
	else {
		strTemp = (String)vGradeEncodingInfo.elementAt(iIndexOf + 1);
		strErrMsg = (String)vGradeEncodingInfo.elementAt(iIndexOf + 3);
	}
	strGrade = (String)vTemp.elementAt(i+5);
	if(strGrade != null && strGrade.indexOf("/") > -1) 
		strGrade = strGrade.substring(0, strGrade.indexOf("/"));
	%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vTemp.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+2)%></td>
      <td class="thinborder"><%=fCredit%></td>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+7)%></td>
      <td class="thinborder">
        <%//Display F for failed grade.
	  //if( ((String)vTemp.elementAt(i+6)).toLowerCase().indexOf("fail") != -1){%>
        <!--F-->
        <%//}else{%>
        <%=strGrade%>
        <%//}%>		</td>
<%if(bolIsCGH){%>
      <td class="thinborder"><font size="1"><%=WI.getStrValue(GS.vCGHGrade.elementAt(p * 2 + 1))%></font>&nbsp;</td>
<%}%>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+6)%></td>
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strErrMsg, "&nbsp;")%></td>
      <td class="thinborder"> <a href='javascript:DeleteRecord("<%=(String)vTemp.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></td>
    </tr>
<%
if(vTemp.elementAt(i+8) != null){%>
    <tr>
      <td height="15" colspan="10" class="thinborder">&nbsp; <font size="1"><%=(String)vTemp.elementAt(i + 8)%></font></td>
    </tr>
    <%}
	i = i+8;
}%>
  </table>
 <%
 	}//if(strCYFrom.length()>0)
  }//if subject list is not null;
 }//if vTemp !=null - student is having grade created already.
}//biggest loop == only if the Proceed for Student id is cliecked - checkStudent.compareTo("1") ==0
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="checkStudent" value="<%=WI.fillTextValue("checkStudent")%>">
<input type="hidden" name="remarkName">
<input type="hidden" name="changeProgram" value="0">
<input type="hidden" name="course_type" value="<%=strCourseType%>">


<script language="javascript">
<%
//I have to add here converting grade from percent to final point.
Vector vGradeSystem = GS.viewAllGrade(dbOP, request);
if(vGradeSystem != null){%>
function CovertGrade(){
	var bolError = false;
	var gradeEncoded   = ""; var gradeEquivalent = "";
	gradeEncoded = document.studdata_entry.grade_percent.value;
	if(gradeEncoded.length == 0)
		return;
	gradeEquivalent = "";
	<%//double dGrade = 100d;
	for(int p =0; p < vGradeSystem.size(); p += 7){	%>
		<%if(p > 0){%>else <%}%>if(gradeEncoded >= <%=(String)vGradeSystem.elementAt(p + 2)%> &&
			gradeEncoded <= <%=(String)vGradeSystem.elementAt(p + 3)%>)//for 80.5 grade - faculties giving grade in point :-|
				gradeEquivalent = <%=(String)vGradeSystem.elementAt(p + 1)%>;
		<%}//System.out.println(dGrade);%>
		//if grade equivalent is having final point, change it, else continue;

	if(gradeEquivalent.length == 0) {
		bolError = true;
	}
	else
		document.studdata_entry.grade.value=gradeEquivalent;

	if(bolError)
		alert("Error in converting grade. Please check grade encoded.");

}
<%}else{%>
function CovertGrade(){
	alert("Grade system is not set. Please check link :: Grade System :: and fill up the grade system.");
	return;
}
<%}%>

function UpdateRemarks(strGradeFieldName){
	var vGrade = "";
	eval('vGrade=document.studdata_entry.'+strGradeFieldName+'.value');

	if(vGrade.length == 0 || vGrade <= 5)
		return;

/**
	if (vGrade <60 || vGrade > 100){
		alert (" Invalid grade");
//		eval("document.studdata_entry."+strGrade+".focus()");
//		eval("document.studdata_entry."+strGrade+".select()");
		return;
	}

**/
	if (vGrade < 75){
		if (iFailedSelectedIndex == -1)
			iFailedSelectedIndex = GetFailedSelectedIndex();
		document.studdata_entry.remark_index.selectedIndex = iFailedSelectedIndex;
	}
	else if (vGrade >= 75){
		if (iPassedSelectedIndex == -1)
			iPassedSelectedIndex = GetPassedSelectedIndex();
		document.studdata_entry.remark_index.selectedIndex = iPassedSelectedIndex;
	}
	<%if(bolIsCGH){%>
		this.CovertGrade();
	<%}%>

}

</script>


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
