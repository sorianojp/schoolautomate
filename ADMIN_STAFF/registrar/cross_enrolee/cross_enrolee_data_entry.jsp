<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 9px}
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
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
function UpdateSchoolList()
{
	//pop up here.
	var pgLoc = "../sub_creditation/schools_accredited.jsp?parent_wnd=studdata_entry";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.studdata_entry.stud_id.value;
		if(strCompleteName.length < 3) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}
		
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

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Cross Enrollee Data Entry","cross_enrolee_data_entry.jsp");
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
														"Registrar Management","CROSS_ENROLEE Info Maintenance",request.getRemoteAddr(),
														"cross_enrolee_data_entry.jsp");
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

GradeSystem GS = new GradeSystem();
OfflineAdmission offlineAdmission = new OfflineAdmission();
vStudInfo = offlineAdmission.getStudentBasicInfo(dbOP,WI.fillTextValue("stud_id"));

if(vStudInfo != null && vStudInfo.size() > 0)
{
	strStudName = WI.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),1);
	strCYFrom = (String)vStudInfo.elementAt(3);
	strCYTo   = (String)vStudInfo.elementAt(4);

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
%>


<form action="./cross_enrolee_data_entry.jsp" method="post" name="studdata_entry">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: CROSS-ENROLEE
          STUDENT DATA MANAGEMENT ::::<br>
          </strong>(Encoding of old student's academic records)</font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
		<td width="2%" height="25" colspan="4">&nbsp;</td>
      <td width="98%"><strong><%=strErrMsg%></strong></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr valign="top">
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%">Student ID</td>
      <td width="15%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td width="10%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="10%">
      <input type="image" onClick="CheckStudent();" src="../../../images/form_proceed.gif">      </td>
      <td width="51%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr >
      <td  colspan="6" height="25"><hr size="1"></td>
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
      <td height="25">&nbsp;</td>
      <td colspan="3">School where subject is enrolled::
        <input type="text" name="starts_with2" value="<%=WI.fillTextValue("starts_with2")%>" size="25" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		   style="font-size:12px" onKeyUp = "AutoScrollList('studdata_entry.starts_with2','studdata_entry.prev_school',true);">
      &nbsp;&nbsp;<a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a><font size="1">click to update  school list</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3"><select name="prev_school">
<%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0  " + 
" and sch_name not like '%elem.%' and sch_name not like '%element%' " + 
" and sch_name not like '%high s%' order by SCH_NAME",
 WI.fillTextValue("prev_school"),false)%>
        </select></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">School Year </td>
      <td width="18%"> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("studdata_entry","sy_from","sy_to")'>
        to
      <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td width="66%">&nbsp;Term
        <select name="semester" onChange="ReloadPage();">
          <option value=""></option>
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
      </select></td>
    </tr>
</table>
<%
if(strCourseType.compareTo("4") != 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">
<% if(strCourseType.compareTo("1") !=0){ %>	  
	  Year Level &nbsp;
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
        <%}//if degree type is not 1(masters) %>      </td>
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
        <%}%>      </td>
      <td>&nbsp;&nbsp;
        <!--        <%if(request.getParameter("is_internship") != null && request.getParameter("is_internship").compareTo("1") == 0){%>
        <input name="is_internship" type="checkbox" value="1" checked>
        <%}else{%>
        <input name="is_internship" type="checkbox" value="1">
        <%}%>
        (check if INTERNSHIP)-->
        <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a> <font size="1">Click to refresh the page</font></td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="21%">&nbsp;</td>
      <td width="14%">&nbsp; </td>
      <td width="62%">&nbsp;</td>
    </tr>
  </table>
<%}
strErrMsg = ""; String strSubIndex = null;
if(WI.fillTextValue("course_index").length() > 0)
{
	vTemp = GS.getSubjectList(dbOP, request, strCYFrom, strCYTo, true);
	if(vTemp == null)
		strErrMsg = GS.getErrMsg();
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
if(vTemp != null)
{%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="8" ><hr size="1"></td>
    </tr>
    <tr>
      <td height="21" >&nbsp;</td>
      <td  height="21" colspan="6" >&nbsp;
	  <%if(WI.fillTextValue("is_internship").compareTo("1") == 0){%>
          <input name="is_internship" type="checkbox" value="1" checked onClick="ReloadPage();">
          <%}else{%>
          <input name="is_internship" type="checkbox" value="1" onClick="ReloadPage();">
      <%}%>
          <span class="style1">(check if INTERNSHIP/CLERKSHIP/CADETSHIP subject)</span></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="29%"  height="25" ><font size="1">
 
        <strong>SUBJECT CODE</strong></font></td>
      <td width="41%" > <font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="9%" ><strong><font size="1">UNIT</font></strong></td>
      <td width="9%" align="center" ><font size="1"><strong>CREDIT EARNED</strong></font></td>
      <td width="9%" align="center" ><font size="1"><strong>FINAL GRADE</strong></font></td>
      <td width="10%" align="center" ><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" ><select name="subject" onChange="ReloadPage();">
          <%//System.out.println(vTemp);
	strTemp = WI.fillTextValue("subject");//cur_index.
	for(i = 0; i< vTemp.size(); ++i)
	{
		if(strTemp.compareTo( (String)vTemp.elementAt(i)) ==0) {
			strSubIndex = (String)vTemp.elementAt(i + 5);
			strSubName  = (String)vTemp.elementAt(i+2);
			strSubCode  = (String)vTemp.elementAt(i+1);
			fCredit     = Float.parseFloat((String)vTemp.elementAt(i+3))+Float.parseFloat((String)vTemp.elementAt(i+4));
			%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i+1)%></option>
          <%}else{%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i+1)%></option>
          <%}
i = i+5;
}//System.out.println(vTemp);
if(strSubName == null && fCredit ==0)//first time - so select the top result.
{
	strSubIndex = (String)vTemp.elementAt(5);
	strSubName = (String)vTemp.elementAt(2);
	fCredit  = Float.parseFloat((String)vTemp.elementAt(3))+Float.parseFloat((String)vTemp.elementAt(4));
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
        </select> <%}//only if subject is NSTP %> </td>
      <td><%=strSubName%></td>
      <td><%=fCredit%></td>
      <td align="center"><input name="credit_earned" type="text" size="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=fCredit%>"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td align="center"><input name="grade" type="text" size="4" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="top"><select name="remark_index">
          <%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("remark_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="10" >&nbsp;</td>
      <td  height="10" colspan="6" valign="bottom"><strong><em><font color="#0000FF">NOTE:
        Enter if subject code and sub description are different from subject in
        curriculum</font></em></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" ><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td colspan="5" ><font size="1"><strong>SUBJECT TITLE</strong></font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" > <input name="ce_sub_code" type="text" size="20" maxlength="64" value="<%=WI.fillTextValue("ce_sub_code")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="5" > <input name="ce_sub_name" type="text" size="60" maxlength="128" value="<%=WI.fillTextValue("ce_sub_name")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
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
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="6" >Place taken :
        <input name="internship_place" type="text" size="60" maxlength="128" value="<%=WI.fillTextValue("internship_place")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
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
          <%}else{%>
          <option value="2">Months</option>
          <%}%>
        </select></td>
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
<%
//get here the list of grade created already for this year/sem course
	vTemp = GS.viewFinalGradePerYrSem(dbOP, request);
	//System.out.println(GS.getErrMsg());
	if(vTemp != null && vTemp.size() > 0)
	{%>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9" bgcolor="#B9B292"><div align="center">LIST OF
          GRADE FOR <%=WI.getStrValue(request.getParameter("year"),"(N/A)")%> YEAR- <%=request.getParameter("semester")%>
          SEM
          <%
		  if(request.getParameter("is_internship") != null && request.getParameter("is_internship").compareTo("1") ==0) //it is internship
          {%>
          <strong>(Internship)</strong>
          <%}%>
        </div></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="20%"  height="25" ><div align="left"><font size="1"><strong>SUBJECT
          CODE</strong></font></div></td>
      <td width="45%" ><div align="left"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
      <td width="9%" ><div align="left"><font size="1"><strong>UNIT</strong></font></div></td>
      <td width="9%" ><font size="1"><strong>CREDITS EARNED</strong></font></td>
      <td width="9%" ><div align="left"><font size="1"><strong>FINAL GRADES</strong></font></div></td>
      <td width="9%" ><font size="1"><strong>REMARKS</strong></font></td>
      <td width="6%" >&nbsp;</td>
    </tr>
    <%//System.out.println(vTemp);
	for(i=0; i< vTemp.size(); ++i)
	{//System.out.println((String)vTemp.elementAt(3) + " : "+(String)vTemp.elementAt(4));
	fCredit  = Float.parseFloat((String)vTemp.elementAt(i+3))+Float.parseFloat((String)vTemp.elementAt(i+4));%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><%=(String)vTemp.elementAt(i+1)%></td>
      <td><%=(String)vTemp.elementAt(i+2)%></td>
      <td><%=fCredit%></td>
      <td><%=(String)vTemp.elementAt(i+7)%></td>
      <td><%//Display F for failed grade.
	  if( ((String)vTemp.elementAt(i+6)).toLowerCase().indexOf("fail") != -1){%>
	  F<%}else{%>
	  <%=(String)vTemp.elementAt(i+5)%>
	  <%}%></td>
      <td><%=(String)vTemp.elementAt(i+6)%></td>
      <td> <a href='javascript:DeleteRecord("<%=(String)vTemp.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></td>
      <%i = i+8;
	}%>
    </tr>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
