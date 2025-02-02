<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,enrollment.NAApplicationForm,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript">
function EditRecord()
{
	document.offlineRegd.close_wnd_called.value = "1";
	document.offlineRegd.editRecord.value = "1";
	this.ReloadPage();
}
function ReloadPage() {
	document.offlineRegd.close_wnd_called.value = "1";
	this.SubmitOnce('offlineRegd');
}
function ReloadCourseIndex(iStatus) {
	//course index is changed -- so reset all dynamic fields.
	
	if (iStatus == 1 && document.offlineRegd.scroll_course.value.length == 0){
		return;
	}
	
	if(document.offlineRegd.cy_from.selectedIndex > -1)
		document.offlineRegd.cy_from[document.offlineRegd.cy_from.selectedIndex].value = "";
		
	if(document.offlineRegd.major_index.selectedIndex > -1)
		document.offlineRegd.major_index[document.offlineRegd.major_index.selectedIndex].value = "";

	document.offlineRegd.set_focus.value = "1";
	document.offlineRegd.close_wnd_called.value = "1";	
	this.SubmitOnce('offlineRegd');
}
function ChangeCurYear() {
	var curYrTo = document.offlineRegd.cy_from.selectedIndex;
	document.offlineRegd.close_wnd_called.value = "1";
	curYrTo = eval('document.offlineRegd.cy_to'+curYrTo+'.value');
//	alert(curYrTo);
	document.offlineRegd.cy_to.value = curYrTo;
	this.ReloadPage();
}
function OpenSearch() {
	var pgLoc = "../../search/srch_stud_temp.jsp?opner_info=offlineRegd.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	document.offlineRegd.proceed_clicked.value = "1";
}
function UpdateStatus(strStudID) {
	var pgLoc = "./admission_registration_edit_status.jsp?opner_info=offlineRegd.stud_id&stud_id="+strStudID;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateIsGraduating() {
	document.offlineRegd.update_graduating.value = '1';
	this.ReloadPage();
}
function UpdateIsAttcNB() {
	document.offlineRegd.update_attcnb.value = '1';
	this.ReloadPage();
}
function FocusID() {
	
}
function ProceedClicked(){
	document.offlineRegd.close_wnd_called.value = "1";
	document.offlineRegd.proceed_clicked.value = "1";
	this.SubmitOnce('offlineRegd');
}

function moveFocus(){

//	alert ( document.offlineRegd.set_focus.value);
	
	if (document.offlineRegd.set_focus.value == "1"){
		if (document.offlineRegd.course_index.selectedIndex != 0){
			if (document.offlineRegd.major_index.length > 1) 
				document.offlineRegd.major_index.focus();
			else
				document.offlineRegd.cy_from.focus();
			return;
		}
	}
	
	// default
	document.offlineRegd.stud_id.focus();

}

function ReloadParentWnd() {
	if(!window.opener)
		return;

	if(document.offlineRegd.donot_call_close_wnd.value.length >0)
		return;
	if(document.offlineRegd.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
		window.opener.focus();
	}
}

function CloseWindow(){
	document.offlineRegd.close_wnd_called.value = "1";
	
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();
}

var strNewStat = "";
//Ajax interface for toggle authentication :: 
function AjaxToggleRegularity(strStatToUpdate) {
	var objCOAInput = document.getElementById("coa_info");

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strTempID = document.offlineRegd.stud_id.value;
	if(strTempID.length == 0) {
		alert("Please enter student's ID");
		return;
	}
	if(strNewStat.length == 0) 
		strNewStat = strStatToUpdate;
	else	
		strStatToUpdate = strNewStat;
	if(strStatToUpdate == '1')
		strNewStat = '0';
	else
		strNewStat = '1';
	
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=203&updateVal="+strStatToUpdate+"&tempID="+strTempID;

	this.processRequest(strURL);
}
function UpdateNationality(strStudID, strStudIndex, strIsTempStud) {
	var pgLoc = "../fee_assess_pay/payment/update_stud_nationality.jsp?stud_id="+strStudID+"&stud_index="+strStudIndex+"&is_temp_stud="+strIsTempStud;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=300,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();" onUnload="ReloadParentWnd();">
<%
	Vector vTemp = new Vector();	
	String strCourseIndex = null;
	String strMajorIndex = null;
	String strErrMsg = "";
	String strTemp = null;
	String strStudStatus = null;
	String strSYTo = null; // this is used in
	int i=0; int j=0;
	boolean bolProceed = false;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Registration","admission_registration.jsp");
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
														"admission_registration.jsp");													
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
}//end of authenticaion code.
	
SubjectSection SS = new SubjectSection();
OfflineAdmission offlineAdm = new OfflineAdmission();
Vector vecRetResult = new Vector();
if(WI.fillTextValue("update_graduating").length() > 0 && WI.fillTextValue("stud_id").length() > 0) {
	strTemp = "update new_application set is_graduating = "+WI.getStrValue(WI.fillTextValue("is_graduating"), "0")+ " where temp_id = '"+
		WI.fillTextValue("stud_id")+"'";
	dbOP.executeUpdateWithTrans(strTemp, null, null, false);
}
if(WI.fillTextValue("update_attcnb").length() > 0 && WI.fillTextValue("stud_id").length() > 0) {
	strTemp = "update new_application set is_attcnb_stud = "+WI.getStrValue(WI.fillTextValue("is_attcnb"), "0")+ " where temp_id = '"+
		WI.fillTextValue("stud_id")+"'";
	dbOP.executeUpdateWithTrans(strTemp, null, null, false);
}

if(request.getParameter("editRecord") != null && request.getParameter("editRecord").compareTo("1") ==0)
{//addrecord now.
	if(!offlineAdm.editEnrollmentInfo(dbOP,request))
		strErrMsg = offlineAdm.getErrMsg();
	else
		strErrMsg = "Student basic information for enrollment process is edited successfully. reference ID = "+request.getParameter("stud_id");
}

String strCourseRegularityStat = null;

Vector vStudBasicInfo = offlineAdm.getBasicEnrolleeInfo(dbOP, request.getParameter("stud_id"));
if(vStudBasicInfo == null) 
	strErrMsg = offlineAdm.getErrMsg();	
else {
	if(vStudBasicInfo.elementAt(0).equals("0")){//temp student.. 
		strCourseRegularityStat = "select regularity_stat from new_application where application_index="+
									vStudBasicInfo.elementAt(1);
		strCourseRegularityStat = dbOP.getResultOfAQuery(strCourseRegularityStat,0);
	}
}
	
if(WI.fillTextValue("proceed_clicked").compareTo("1") == 0)
	bolProceed = true;
%>
<form action="./admission_registration_edit.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="6" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ADMISSION - REGISTRATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" width="1%"></td>
      <td height="25" colspan="4"> <%if(strErrMsg != null){%> <strong><%=strErrMsg%></strong> &nbsp; <%}%> </td>
      <td height="25">&nbsp;
	 <% if (WI.fillTextValue("opner_form_name").length() > 0){%>
	  <a href="javascript:CloseWindow();">
	  	<img src="../../images/close_window.gif" width="71" height="32" border="0" align="right"></a>
	 <%}%>		  
	  
	  </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" width="1%"></td>
      <td width="27%" height="25">Student's Temporary ID</td>
      <td width="18%">
	  <input type="text" name="stud_id" size="16" maxlength="32" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0" ></a></td>
      <td width="38%"><a href="javascript:ProceedClicked();"><img src="../../images/form_proceed.gif" border="0"></a></td>
      <td width="11%">&nbsp;</td>
    </tr>
  </table>
<%
if(vStudBasicInfo != null){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">HS Student ID </td>
<%
	strTemp = WI.fillTextValue("old_stud_id");
	if(strTemp.length() ==0 || bolProceed){
		if (vStudBasicInfo.size() == 16) 
			strTemp = WI.getStrValue((String)vStudBasicInfo.elementAt(15));
		else if (vStudBasicInfo.size() == 21)
			strTemp = WI.getStrValue((String)vStudBasicInfo.elementAt(20));
		else if (vStudBasicInfo.size() == 18)
			strTemp = WI.getStrValue((String)vStudBasicInfo.elementAt(17));
	}
%>	  
      <td height="25" colspan="3"><input name="old_stud_id" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="16"> 
	  <font size="1">(encode only if New HS Graduate of this University)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student Name </td>
      <td height="25" colspan="3">
<%
	strTemp = WI.fillTextValue("lname");
	if(strTemp.length() ==0 || bolProceed)
		strTemp = (String)vStudBasicInfo.elementAt(4);
%>
	  <input type="text" name="lname" value="<%=strTemp%>" size="20" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%
	strTemp = WI.fillTextValue("fname");
	if(strTemp.length() == 0 || bolProceed)
		strTemp = (String)vStudBasicInfo.elementAt(2);
%>
        <input type="text" name="fname" value="<%=strTemp%>" size="20" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%
	strTemp = WI.fillTextValue("mname");
	if(strTemp.length() ==0 || bolProceed)
		strTemp = WI.getStrValue(vStudBasicInfo.elementAt(3));
%>
        <input type="text" name="mname" value="<%=strTemp%>" size="20" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="3" valign="top"><font size="1">(lastname)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        (firstname)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (middlename) </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student Status </td>
      <td height="25">
        <%//System.out.println(vStudBasicInfo);
			strStudStatus = (String)vStudBasicInfo.elementAt(5);
		%>
		<strong><%=strStudStatus%></strong>
		<input type="hidden" name="stud_status" value="<%=strStudStatus%>">
		<%if(((String)vStudBasicInfo.elementAt(0)).equals("0")){//show change of status only if new student.. %>
			<a href="javascript:UpdateStatus('<%=WI.fillTextValue("stud_id")%>')"><img src="../../images/update.gif" border="0"></a>
		<%}%>		</td>
      <td height="25" colspan="2">Regularity Status : 
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <%if(strCourseRegularityStat == null){
	  		strTemp = " not defined";
			strCourseRegularityStat = "1";
		}
		else if(strCourseRegularityStat.equals("0")) {
			strTemp = "Regular";
			strCourseRegularityStat = "1";
		}			
		else {	
			strTemp = "Irregular";
			strCourseRegularityStat = "0";
		}%>			
	  <%=strTemp%>	  </label>
	  
	  <a href="javascript:AjaxToggleRegularity('<%=strCourseRegularityStat%>');"><img src="../../images/update.gif" border="0"></a>
	  <font size="1">Click to Toggle</font>	  </td>
    </tr>
<%if(strSchCode.startsWith("FATIMA")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:13px; font-weight:bold; color:#CC0033">
<%
strTemp = WI.getStrValue((String)vStudBasicInfo.elementAt(22));

if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>
        <input type="checkbox" value="1" name="is_graduating" <%=strTemp%>> Is Graduating? 
		<a href="javascript:UpdateIsGraduating()"><img src="../../images/update.gif" border="0"></a>		</td>

      <td colspan="2">&nbsp;</td>
    </tr>
<%}if(strSchCode.startsWith("UC")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:13px; font-weight:bold; color:#CC0033">
<%
strTemp = WI.getStrValue((String)vStudBasicInfo.elementAt(23));

if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>
        <input type="checkbox" value="1" name="is_attcnb" <%=strTemp%>> Is ATTC/NB? 
		<a href="javascript:UpdateIsAttcNB()"><img src="../../images/update.gif" border="0"></a>		</td>

      <td colspan="2">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
	  Foreign Student : <font color="#9900FF"><strong>
<%
enrollment.CourseRequirement CR = new enrollment.CourseRequirement();
boolean bolIsAlienNationality = CR.isForeignNational(dbOP, (String)vStudBasicInfo.elementAt(1),true);
if(bolIsAlienNationality) {%>
YES <%=WI.getStrValue(CR.getStudNationality(),"(",")","")%>
<%}else{%>
NO
<%}%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <a href='javascript:UpdateNationality("<%=WI.fillTextValue("stud_id")%>","<%=(String)vStudBasicInfo.elementAt(1)%>","1");'><img src="../../images/update.gif" border="0"></a></strong></font>
	  </td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="16%" height="25"> Year level entry</td>
      <td width="21%"><select name="year_level">
		  <option></option>
<%
	strTemp = WI.fillTextValue("year_level");
	if(strTemp.length() == 0 || bolProceed)
		strTemp = WI.getStrValue((String)vStudBasicInfo.elementAt(10));

if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>1st</option>
<%}else{%>
          <option value="1">1st</option>
<%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.compareTo("3") ==0){%>
   		  <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select> </td>
      <td width="9%" height="25">Term </td>
      <td width="53%"> <select name="semester">
          <option value="1">1st</option>
<%
	strTemp = WI.fillTextValue("semester");
	if(strTemp.length() ==0  || bolProceed)
		strTemp = (String)vStudBasicInfo.elementAt(12);

if(strTemp.compareTo("1") ==0) strTemp = "100"; //internship
else
	strTemp = (String)vStudBasicInfo.elementAt(11);
if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}
	  
	  	  if (!strSchCode.startsWith("CPU") && 
		      !strSchCode.startsWith("UI")) { 		
		  if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}
		  } // remove 3rd sem for CPU and UI
		  if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="16%" height="25"> School Year</td>
      <td width="21%">
<%
	strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0  || bolProceed)
		strTemp = (String)vStudBasicInfo.elementAt(6);
%>
	  <input type="text" name="sy_from" value="<%=strTemp%>" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("offlineRegd","sy_from","sy_to")'>
        to
<%
	strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0  || bolProceed)
		strTemp = (String)vStudBasicInfo.elementAt(7);
%>
        <input type="text" name="sy_to" value="<%=strTemp%>" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="9%" height="25">&nbsp;</td>
      <td width="53%">&nbsp; </td>
    </tr>
  </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	<tr>
      <td height="25" width="1%">&nbsp;</td>
	  <td width="49%">Course : <font size="1"> 
        <input type="text" name="scroll_course" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollList('offlineRegd.scroll_course','offlineRegd.course_index',true);"
	   onBlur="ReloadCourseIndex(1)" class="textbox">
        (enter course code to scroll course list)</font></td>
	  <td width="50%">Curriculum Year</td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td valign="middle">
<select name="course_index" onChange="ReloadCourseIndex(2);" style="font-size:10px;font-weight:bold">
          <option value="0">Select Any</option>
<%
	strCourseIndex = WI.fillTextValue("course_index");
	if(strCourseIndex.length() ==0  || bolProceed)
		strCourseIndex = (String)vStudBasicInfo.elementAt(13);
%>
<%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 and is_visible = 1 order by course_code  asc", strCourseIndex, false)%>
        </select>
      </td>
      <td valign="middle"> <select name="cy_from" onChange="ChangeCurYear();">
          <%
//get here school year
/*
if(bolShowStudInfo && vStudBasicInfo!= null && vStudBasicInfo.size() >0 &&
	(WI.fillTextValue("stud_status").compareTo("Change Course") !=0 || WI.fillTextValue("course_index").compareTo("0") ==0) )
*/
if(WI.fillTextValue("course_index").length() ==0 && vStudBasicInfo.elementAt(8) != null)
{
	request.setAttribute("course_index",vStudBasicInfo.elementAt(13));
	request.setAttribute("major_index",(String)vStudBasicInfo.elementAt(14));
}
vTemp = SS.getSchYear(dbOP, request, true);
strTemp = WI.fillTextValue("cy_from");
if(strTemp.length() ==0  || bolProceed)
	strTemp = (String)vStudBasicInfo.elementAt(8);

if(strTemp == null) strTemp = "";

if(vTemp != null)
for(i = 0, j=0 ; i< vTemp.size();)
{
	if(	((String)vTemp.elementAt(i)).compareTo(strTemp) == 0)
	{%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i)%> 
          - <%=(String)vTemp.elementAt(i + 1)%></option>
          <%	j = i;
	}
	else{
	%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i)%> 
          - <%=(String)vTemp.elementAt(i + 1)%></option>
          <%	}
	i = i+2;

}
if(vTemp != null && vTemp.size() > 0)
	strSYTo = (String)vTemp.elementAt(j+1);		
else
	strSYTo = "";

%>
        </select> 
        <!--to <b><%=strSYTo%></b>-->
        <input type="hidden" name="cy_to" value="<%=strSYTo%>"> 
        <%for(i = 0,j=0; i< vTemp.size(); i += 2, ++j) {%>
        <input type="hidden" name="cy_to<%=j%>" value="<%=(String)vTemp.elementAt(i + 1)%>"> 
        <%}%>
    </tr>
  <tr>
      <td height="25" width="1%">&nbsp;</td>
	  <td width="49%">Major&nbsp;
<select name="major_index" onChange="ReloadPage();">
          <option></option>
<%
	strMajorIndex = WI.fillTextValue("major_index");
	if(strMajorIndex.length() ==0  || bolProceed)
		strMajorIndex = (String)vStudBasicInfo.elementAt(14);

if(strCourseIndex != null && strCourseIndex.compareTo("0") != 0 && strCourseIndex.length()>0)
{
strTemp = " from major where is_del=0 and is_offered_major_ =1 and course_index="+strCourseIndex+" order by major_name asc" ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strMajorIndex, false)%>
          <%}%>
        </select></td>
	  <td width="50%">&nbsp;</td>
    </tr>
  </table>
<%if(strStudStatus.compareTo("New") ==0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4" height="26"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" valign="bottom">Previous school</td>
      <td height="25" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom"> 
<%
	strTemp = WI.fillTextValue("prev_sch_name");System.out.println(strTemp);
	if(strTemp.length() ==0  || bolProceed)
		strTemp = WI.getStrValue(vStudBasicInfo.elementAt(19));
%> <select name="sch_index">
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> </select> </td>
    </tr>
	</table>
<%}else if(strStudStatus.compareTo("Transferee") ==0 || strStudStatus.compareTo("Second Course") ==0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4" height="26"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" valign="bottom">Previous school</td>
      <td height="25" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom"> 
<%
	strTemp = WI.fillTextValue("prev_sch_name");System.out.println(strTemp);
	if(strTemp.length() ==0  || bolProceed)
		strTemp = WI.getStrValue(vStudBasicInfo.elementAt(19));
%> <select name="sch_index">
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Previous course</td>
      <td height="25" valign="bottom">Major </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> <%
	strTemp = WI.fillTextValue("prev_course");
	if(strTemp.length() ==0  || bolProceed)
		strTemp = WI.getStrValue(vStudBasicInfo.elementAt(15));
%> <input name="prev_course" type="text" size="40" maxlength="90" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td height="25"> <%
	strTemp = WI.fillTextValue("prev_major");
	if(strTemp.length() ==0  || bolProceed)
		strTemp = WI.getStrValue(vStudBasicInfo.elementAt(16));
%> <input name="prev_major" type="text" size="40" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp; </td>
    </tr>
  </table>
<%}else if(strStudStatus.compareTo("Change Course") ==0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3" height="26"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom">Previous course</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom"><strong> 
        <select name="prev_course_index" onChange="ReloadCourseIndex(2);">
          <option value="0">Select Any</option>
          <%
	strCourseIndex = WI.fillTextValue("prev_course_index");
	if(strCourseIndex.length() ==0  || bolProceed)
		strCourseIndex = WI.getStrValue(vStudBasicInfo.elementAt(15));
%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc", strCourseIndex, false)%> 
        </select>
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom">Previous Major</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><select name="prev_major_index">
          <option></option>
          <%
	strMajorIndex = WI.fillTextValue("prev_course_index");
	if(strMajorIndex.length() ==0  || bolProceed)
		strMajorIndex = WI.getStrValue(vStudBasicInfo.elementAt(16));

if(strCourseIndex != null && strCourseIndex.compareTo("0") != 0 && strCourseIndex.length()>0)
{
strTemp = " from major where is_del=0 and course_index="+strCourseIndex+" order by major_name asc" ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strMajorIndex, false)%> 
          <%}%>
        </select></td>
    </tr>
  </table>
<%}else if(strStudStatus.equals("Cross Enrollee")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Current school</td>
      <td height="25" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom"><select name="sch_index">
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",(String)vStudBasicInfo.elementAt(19),false)%> </select> <font size="1">Click to update accredited school 
        list</font> <a href="javascript:UpdateSchoolList();"> <img src="../../images/update.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">Course</td>
      <td valign="bottom">Major </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><input name="cur_course" type="text" size="40" maxlength="128" value="<%=(String)vStudBasicInfo.elementAt(15)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td height="25"> <input name="cur_major" type="text" size="40" maxlength="128" value="<%=(String)vStudBasicInfo.elementAt(16)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp; </td>
    </tr>
  </table>
<%}%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">

    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
<%
if(iAccessLevel > 1){%>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="7">&nbsp;</td>
      <td width="29%" height="25"><a href="javascript:EditRecord();"><img src="../../images/edit.gif" border="0"></a>
        <font size="1" >click to edit entries</font></td>
      <td width="56%">&nbsp;</td>
    </tr>
<%}%>
  </table>
  <input type="hidden" name="user_index" value="<%=(String)vStudBasicInfo.elementAt(1)%>">
  <input type="hidden" name="is_tempuser" value="<%=(String)vStudBasicInfo.elementAt(0)%>">
<%}//end of displaying if vStudBasicInfo != null%>

<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="proceed_clicked" value="0">
<input type="hidden" name="set_focus" value="<%=WI.fillTextValue("set_focus")%>">

<script language="javascript">
	moveFocus();
</script>

  <input type="hidden" name="opner_form_name" value="<%=WI.fillTextValue("opner_form_name")%>">	
	
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
<!-- this is very important - onUnload do not call close window -->	

<input type="hidden" name="update_graduating">
<input type="hidden" name="update_attcnb">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>