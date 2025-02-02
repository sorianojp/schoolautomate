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
	if(document.studdata_entry.stud_id)
		document.studdata_entry.stud_id.focus();
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
	if(document.studdata_entry.pmt_s_.value.length > 0) {
		if(document.studdata_entry.pmt_s_.value != document.studdata_entry.pmt_sch[document.studdata_entry.pmt_sch.selectedIndex].value) {
			alert("Selected Exam Schedule does not match. Page will reload");
			this.ReloadPage();
		}
	}
	document.studdata_entry.deleteRecord.value = 0;
	document.studdata_entry.addRecord.value = 1;

	//get the remark name,
	document.studdata_entry.remarkName.value = document.studdata_entry.remark_index[document.studdata_entry.remark_index.selectedIndex].text;
//	alert(document.studdata_entry.remarkName.value);
	document.studdata_entry.submit();
}
function DeleteRecord(strTargetIndex)
{
	if(document.studdata_entry.pmt_s_.value.length > 0) {
		if(document.studdata_entry.pmt_s_.value != document.studdata_entry.pmt_sch[document.studdata_entry.pmt_sch.selectedIndex].value) {
			alert("Selected Exam Schedule does not match. Page will reload");
			this.ReloadPage();
			return;
		}
	}
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
function createEnrolInfo() {
	document.studdata_entry.page_action.value = '10';
	document.studdata_entry.submit();
}

///ajax here to load major..
function loadMajor() {
		var objCOA=document.getElementById("load_major");
		
		var objCourseInput = document.studdata_entry.course_index[document.studdata_entry.course_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=104&all=1&course_ref="+objCourseInput;
		this.processRequest(strURL);
}

</script>
<body bgcolor="#D2AE72" onLoad="focusOnGrade();">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.OfflineAdmission,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
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
boolean bolCreateStudInfo = false;

GradeSystem GS = new GradeSystem();
String strUserIndex = null;
OfflineAdmission offlineAdmission = new OfflineAdmission();
if(WI.fillTextValue("stud_id").length() > 0 && WI.fillTextValue("sy_from").length() > 0 &&
	WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("semester").length() > 0) {
	if(WI.fillTextValue("page_action").length() > 0) {
		if(GS.operateOnVeryOldGradeEncoding(dbOP, request, 10, null) == null)
			strErrMsg = GS.getErrMsg();
	}
	if(strErrMsg == null) {
		vStudInfo = offlineAdmission.getStudentBasicInfo(dbOP,WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),
						WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
		if(vStudInfo == null) {
			strSQLQuery = "select user_index, fname, mname, lname from user_table where id_number = "+
						WI.getInsertValueForDB(WI.fillTextValue("stud_id"), true, null)+
						" and is_valid = 1 and auth_type_index = 4";
			java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next())
				strUserIndex = rs.getString(1);
			else
				strErrMsg = "ID Number not found.";
			if(strUserIndex != null) {
				strSQLQuery = "select cur_hist_index, course_index from stud_curriculum_hist "+
								"where user_index = "+strUserIndex+" and stud_curriculum_hist.is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+
								" and semester = "+WI.fillTextValue("semester");
				rs = dbOP.executeQuery(strSQLQuery);
				if(rs.next()) {
					if(rs.getInt(2) == 0)
						strErrMsg = "Student already has entry in Grade school for this sy-term";
					else	
						bolCreateStudInfo = true;
				}
				else
					bolCreateStudInfo = true;
				rs.close();
			}
		}
	}
}

	String strPmtSchIndex = WI.fillTextValue("pmt_sch"); //System.out.println(strPmtSchIndex);
    String strPmtSchName  = null;
    String strGradeTable  = null;
	
	boolean bolIsFinals = true;
	
if(vStudInfo != null && vStudInfo.size() > 0)
{//System.out.println(vStudInfo);

	if(strPmtSchIndex.length() > 0) {
      strSQLQuery = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+strPmtSchIndex;
      strPmtSchName = dbOP.getResultOfAQuery(strSQLQuery, 0);//System.out.println(strPmtSchName);
      if(strPmtSchName != null && strPmtSchName.toLowerCase().startsWith("final"))
        strGradeTable  = "G_SHEET_FINAL";
      else {
        strGradeTable  = "GRADE_SHEET";
		bolIsFinals    = false;
	  }
    }
    else
      strGradeTable  = "G_SHEET_FINAL";


	strUserIndex = (String)vStudInfo.elementAt(12);
	strStudName = WI.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),1);
	strCYFrom = (String)vStudInfo.elementAt(3);
	strCYTo   = (String)vStudInfo.elementAt(4);
	
	strTemp = WI.fillTextValue("addRecord");
	if(strTemp.compareTo("1") == 0) {
		//add it here and give a message.
		//I have to get curriculum reference.. 
		strErrMsg = GS.operateOnVeryOldGradeEncoding(dbOP, request, 1, strUserIndex);
		if(strErrMsg == null)
			strErrMsg = GS.getErrMsg();
		else {
			if(GS.createFinalGrade(dbOP,request,true, strErrMsg,(String)vStudInfo.elementAt(13)))//true -> old data.
				strErrMsg = "Grade added successfully.";
			else
				strErrMsg = GS.getErrMsg();
		}
	}
	else //either it is edit or delete -- this page handles add/edit/delete/viewall :-)
	{
		strTemp = WI.fillTextValue("deleteRecord");
		if(strTemp.compareTo("1") == 0)	{
			if(GS.delFinalGrade(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index"), bolIsFinals))
				strErrMsg = "Grade deleted successfully.";
			else
				strErrMsg = GS.getErrMsg();
		}
	}

	strCourseType = " and is_del=0 and is_valid=1";
	strCourseType = dbOP.mapOneToOther("COURSE_OFFERED","course_index",(String)vStudInfo.elementAt(5),"DEGREE_TYPE",strCourseType);

	  
	 if(bolIsFinals)
	 	strSQLQuery = "";
	 else	
	 	strSQLQuery = " and pmt_sch_index= "+strPmtSchIndex;
	  
	//get grade encoding information.
	strSQLQuery = "select gs_index, id_number, fname, mname, lname, "+strGradeTable+".create_date from "+strGradeTable+" join user_table on (user_table.user_index = "+strGradeTable+".encoded_by) "+
					" where user_index_ = "+strUserIndex+" and "+strGradeTable+".is_valid = 1 and cur_hist_index = "+(String)vStudInfo.elementAt(13)+strSQLQuery;
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);//System.out.println(strSQLQuery);
	while(rs.next()) {
		vGradeEncodingInfo.addElement(new Integer(rs.getInt(1)));
		vGradeEncodingInfo.addElement(rs.getString(2));
		vGradeEncodingInfo.addElement(WebInterface.formatName(rs.getString(3), rs.getString(4), rs.getString(5), 4));
		vGradeEncodingInfo.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(6), true));
	}
	rs.close();

}

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


<form action="./very_old_stud_data_entry.jsp" method="post" name="studdata_entry">
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
      <td width="96%" style="font-size:16px; color:#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
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
<%if(strSchCode.startsWith("MARINER")) {%>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Encode Grade For: </td>
      <td colspan="3">
        <select name="pmt_sch" onChange="ReloadPage();">
          <%=dbOP.loadCombo("FA_PMT_SCHEDULE.pmt_sch_index","FA_PMT_SCHEDULE.EXAM_NAME",
		  " from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER desc", request.getParameter("pmt_sch"), false)%>
        </select>
	  </td>
    </tr>
<%}%>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Student ID</td>
      <td width="13%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">      </td>
      <td width="8%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="61%">
        <input name="image" type="image" onClick="CheckStudent();" src="../../../images/form_proceed.gif">
        
		
		<font size="1">
        <a href="javascript:ViewResidency();"><img src="../../../images/view.gif" border="0"></a>click
        to view Residency status of student</font>		</td>
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
<%if(bolCreateStudInfo) {%>
     <tr >
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:14px; font-weight:bold;"><u>Create Student SY-Term Information</u></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="3">
		<select name="course_index" onChange="loadMajor();" style="width:500px">
          <option value=""></option>
      		<%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND is_valid = 1 order by course_name asc",	WI.fillTextValue("course_index"), false)%> 
	  </select>	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Major</td>
      <td colspan="3">
<label id="load_major">
		<select name="major_index">
          <option value=""></option>
<%if(WI.fillTextValue("course_index").length() > 0) {%>
          	<%=dbOP.loadCombo("major_index","major_name"," from	 major where IS_DEL=0 and course_index = " + WI.fillTextValue("course_index") + " order by major_name asc",	WI.fillTextValue("major_index"), false)%> 
<%}%>
		</select> 		  
</label>	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Year Level </td>
      <td colspan="3">
	  <select name="year_level">
	  <option value=""></option>
<%
int iDef = Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"), "0"));
for (i =1 ; i < 7; ++i){
if(i == iDef)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
<%}%>
	</select>	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3"><input type="button" onClick="createEnrolInfo();" value="&nbsp;&nbsp; Create Information &nbsp;&nbsp; "></td>
    </tr>
<%}%>
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
        <%}%></strong></td>
</tr>
<tr>
	<td colspan="2"><hr size="1"></td>
</tr>
  </table>
    <input type="hidden" name="course_index" value="<%=(String)vStudInfo.elementAt(5)%>">
    <input type="hidden" name="major_index" value="<%=WI.getStrValue(vStudInfo.elementAt(6))%>">
    <input type="hidden" name="cy_from" value="<%=(String)vStudInfo.elementAt(3)%>">
    <input type="hidden" name="cy_to" value="<%=(String)vStudInfo.elementAt(4)%>">
<%if(strCYTo.length() > 0){
if(true){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="1%" height="25" >&nbsp;</td>
      <td width="59%"  height="25" ><div align="left"><font size="1">
	  <%if(bolIsFinals){%>
          <%if(WI.fillTextValue("is_internship").compareTo("1") == 0){%>
          <input name="is_internship" type="checkbox" value="1" checked onClick="ReloadPage();">
          <%}else{%>
          <input name="is_internship" type="checkbox" value="1" onClick="ReloadPage();">
          <%}%>
          (check if INTERNSHIP/CLERKSHIP/CADETSHIP subject) <%}%><strong><br>
          SUBJECT CODE</strong></font></div></td>
      <td width="10%" ><div align="left"><font size="1"><strong>CREDITS EARNED</strong></font></div></td>
      <td width="10%" ><center>
        <font size="1"><strong> GRADE</strong></font></center>      </td>
      <td width="10%" ><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" >
<select name="sub_index_" style="width:500px; font-size:11px;">
          <option value=""></option>
      		<%=dbOP.loadCombo("sub_index","sub_code,sub_name"," from subject where IS_DEL=0 order by sub_code asc",	WI.fillTextValue("sub_index_"), false)%> 
	  </select>
	  </td>
      <td valign="top"><input name="credit_earned" type="text" size="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("credit_earned")%>"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td valign="top" align="center">
<%
	if (strSchCode.startsWith("AUF") || strSchCode.startsWith("CGH"))
		strTemp = "UpdateRemarks('grade');";
	else
		strTemp = "";
%>
	  <input name="grade" type="text" size="4" maxlength="5" class="textbox" value="<%=WI.fillTextValue("grade")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="<%=strTemp%>style.backgroundColor='white'"
	  onKeyPress="if(event.keyCode == 115 || event.keyCode ==83 || event.keyCode == 47) event.returnValue=true; else if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
<%if(bolIsCGH){%>
      <%}%>
      <td valign="top"><select name="remark_index">
          <%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("remark_index"), false)%>
        </select></td>
    </tr>
    

<%if(WI.fillTextValue("is_internship").compareTo("1") ==0){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="4" >Inclusive date of internship/clerkship :
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
      <td  height="25" colspan="4" style="font-size:11px;" class="thinborderTOPRIGHT">Hospital Name :<select name="i_hosp_sel" onChange="CopyInternshipPlace2();" style="width:392px;">
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
      <td  height="25" colspan="4" style="font-size:11px;" class="thinborderBOTTOMRIGHT">(or) Enter Hospital Name : 
	  <input name="i_hosp" type="text" size="60" maxlength="92" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="CopyInternshipPlace3();style.backgroundColor='white'">
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;
	  Place : 
	  <input name="i_place" type="text" size="32" maxlength="32" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="CopyInternshipPlace3();style.backgroundColor='white'">	  </td>
    </tr>

<%}else{%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="4" >	  <select name="copy_place" onChange="CopyInternshipPlace();">
	  <option value="">Select to copy</option>
<%=dbOP.loadCombo("distinct INTERNSHIP_PLACE","INTERNSHIP_PLACE"," from g_sheet_final where INTERNSHIP_PLACE is not null",null, false)%>
	  </select>	</td>
    </tr>
<%}%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="4" >Hospital Name and place taken :
        <input name="internship_place" type="text" size="60" maxlength="128" value="<%=WI.fillTextValue("internship_place")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">(Note : add &lt;br&gt; for 2nd line)</font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="4" >Duration :
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
      <td  colspan="3" > <div align="left"> <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click
          to add</font> </div></td>
    </tr>
  </table>
<%
//get here the list of grade created already for this year/sem course
	vTemp = GS.viewFinalGradePerYrSem(dbOP, (String)vStudInfo.elementAt(13), false, strPmtSchIndex);
	//System.out.println(vTemp);
	if(vTemp != null && vTemp.size() > 0)
	{%>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9" bgcolor="#B9B292" class="thinborder"><div align="center">LIST OF
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
      <td width="16%"  height="25" class="thinborder"><font size="1"><strong>Subject Code </strong></font></td>
      <td width="30%" class="thinborder"><font size="1"><strong>Subject Title </strong></font></td>
      <td width="7%" class="thinborder"><font size="1"><strong>Credit Earned </strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>Grade</strong></font></td>
      <td width="12%" class="thinborder"><font size="1"><strong>Remarks</strong></font></td>
      <td width="10%" class="thinborder"><font size="1"><strong>Encoded By</strong></font></td>
      <td width="10%" class="thinborder"><font size="1"><strong>Date Encoded</strong></font></td>
      <td width="7%" class="thinborder">&nbsp;</td>
    </tr>
    <%//System.out.println(vTemp);
	int p=0;
	String strGrade = null;
	for(i=0; i< vTemp.size(); ++i,++p)
	{//System.out.println((String)vTemp.elementAt(3) + " : "+(String)vTemp.elementAt(4));
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
      <td class="thinborder"><%=(String)vTemp.elementAt(i+7)%></td>
      <td class="thinborder"><%=strGrade%></td>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+6)%></td>
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strErrMsg, "&nbsp;")%></td>
      <td class="thinborder"> <a href='javascript:DeleteRecord("<%=(String)vTemp.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></td>
    </tr>
<%
if(vTemp.elementAt(i+8) != null){%>
    <tr>
      <td height="15" colspan="8" class="thinborder">&nbsp; <font size="1"><%=(String)vTemp.elementAt(i + 8)%></font></td>
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
<input type="hidden" name="page_action">


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

<input type="hidden" name="pmt_s_" value="<%=WI.fillTextValue("pmt_sch")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
