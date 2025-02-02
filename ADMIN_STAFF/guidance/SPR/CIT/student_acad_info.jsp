<%@ page language="java" import="utility.*,osaGuidance.StudentPersonalDataCIT,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;

	String strUserIndex = WI.fillTextValue("stud_index");
	if(strUserIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Student reference is not found. Please close this window and click on the Part II link to try again..</p>
	<%return;}
	//add security here.
	try	{
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
	
boolean bolIsETO = new enrollment.SetParameter().bolIsETO(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Registrar Management","STUDENT PERSONAL DATA-PART II",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0)
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Guidance & Counseling","STUDENT PERSONAL DATA-PART II",request.getRemoteAddr(), null);														
																
	if(iAccessLevel == 0) {
		if(bolIsETO)
			iAccessLevel = 2;
	}													
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Admission","Student Info Mgmt",request.getRemoteAddr(),null);
	}														
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Student Affairs","Student Tracker",request.getRemoteAddr(),null);
	}														
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Admission Maintenance","Student Tracker",request.getRemoteAddr(),null);
	}														

	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
boolean bolIsLimited = true;
if(request.getSession(false).getAttribute("is_limited") == null)
	bolIsLimited = false;

	boolean bolIsTransfer = false;
	//check if the student is transferee..
	//get the status_index first in the stud_curriculum_hist. dont join bec. i only have user_index, no sy-term.
	strTemp = "select status_index from stud_curriculum_hist where user_index = "+strUserIndex+
		" and is_valid = 1 order by sy_from desc, semester desc ";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp == null)
		bolIsTransfer = false;
	else{
		strTemp = "select status from USER_STATUS where status_index = "+strTemp;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp == null)
			bolIsTransfer = false;
		else{
			if(strTemp.equalsIgnoreCase("Transferee"))
				bolIsTransfer = true;
			else
				bolIsTransfer = false;
		}
	
	}
	
	
	

	strTemp = "select appl_catg from new_application where application_index = "+strUserIndex;
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp == null)
		bolIsTransfer = false;
	else{
		if(strTemp.startsWith("Trans"))
			bolIsTransfer = true;
		else
			bolIsTransfer = false;
	}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student Personal Data</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">

	function EditLastSchool(){
		document.form_.edit_last_school.value = "1";
		document.form_.submit();
	}

	function EditSchoolInfo(){
		document.form_.edit_sch_info.value = "1";
		document.form_.submit();
	}

	function AjaxUpdateCheckbox(strIndexName, strIndex, strTableName, strFieldName, strIsString, objCOA){
		<%if(iAccessLevel == 1){%>
			return;
		<%}%>
		var value = "0";
		if(objCOA.checked)
			value = "1";
		else
			value = "0";
			
		//var objCOA=eval('document.form_.'+strFieldName);
		this.InitXmlHttpObject(objCOA, 1);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=20401&table_name="+strTableName+"&field_name="+strFieldName+"&table_index="+strIndex+"&is_string="+strIsString+"&field_value="+escape(value)+"&"+strFieldName+"="+escape(value)+"&index_name="+strIndexName;
		this.processRequest(strURL);
	}

	function AjaxUpdateOthers(strIndexName, strIndex, strTableName, strFieldName, strIsString, objCOA){		
		<%if(iAccessLevel == 1){%>
			return;
		<%}%>
		//var objCOA=eval('document.form_.'+strFieldName);
		this.InitXmlHttpObject(objCOA, 1);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=20401&table_name="+strTableName+"&field_name="+strFieldName+"&table_index="+strIndex+"&is_string="+strIsString+"&field_value="+escape(objCOA.value)+"&"+strFieldName+"="+escape(objCOA.value)+"&index_name="+strIndexName;
		this.processRequest(strURL);
	}
	function AjaxUpdateLastSchoolAttended(){	
		<%if(iAccessLevel == 1){%>
			return;
		<%}%>
		var objCOA = document.getElementById("lsa_update");
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=20403&user_=<%=strUserIndex%>&lsa="+document.form_.last_school_attended[document.form_.last_school_attended.selectedIndex].value;
		this.processRequest(strURL);
	}
	function AjaxUpdateSchoolInfo(strExamName, strUpdateRef,strObj) {//document.form_.hs_grade_completed) {
		<%if(iAccessLevel == 1){%>
			return;
		<%}%>
		var objCOA = document.getElementById("update_sch_attended");
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		
		
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=20404&user_=<%=strUserIndex%>&exam_name="+strExamName+
						"&update_ref="+strUpdateRef;
		if(strUpdateRef == '1') //school
			strURL += "&sch_name="+escape(strObj[strObj.selectedIndex].value);
		else if(strUpdateRef == '2') //school
			strURL += "&year_grad="+escape(strObj.value);
		else if(strUpdateRef == '3') //school
			strURL += "&grade_completed="+escape(strObj.value);
							
		this.processRequest(strURL);
	}

	
	
function UpdateSchoolList()
{
	//pop up here.
	var pgLoc = "../../../registrar/sub_creditation/schools_accredited.jsp?parent_wnd=offlineRegd";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function GetFocusElement(){
	strFocus = document.form_.move_focus_to.value;	
	if(strFocus != null || strFocus != "")
		eval('document.form_.'+strFocus+'.focus()');
}
var objToFocus = "";
function Verify(strLoad) {

	var strVerifyMsg = "Please provide the following information(s) ";
	objToFocus = "";
	
	if(document.form_.hs_sch_name.value == "" || document.form_.hs_year_grade.value == ""){
		strVerifyMsg += "\r\nSchools Attended(High School)";
		if(objToFocus == ""){
			if(document.form_.hs_sch_name.value == "")
				objToFocus = "hs_sch_name";
			else if(document.form_.hs_year_grade.value == "")
				objToFocus = "hs_year_grade";				
		}		
	}		
	
	if(document.form_.elem_sch_name.value == "" || document.form_.elem_year_grade.value == ""){
		strVerifyMsg += "\r\nSchools Attended(Elementary School)";
		
		if(objToFocus == ""){
			if(document.form_.elem_sch_name.value == "")
				objToFocus = "elem_sch_name";
			else if(document.form_.elem_year_grade.value == "")
				objToFocus = "elem_year_grade";						
		}			
	}	
	
	<%if(bolIsTransfer){%>
	if(document.form_.trans_prev_course.value == "" || document.form_.trans_sy.value == ""){
		strVerifyMsg += "\r\nPrevious Course";
		
		if(objToFocus == ""){
			if(document.form_.trans_prev_course.value == "")
				objToFocus = "trans_prev_course";
			else 
				objToFocus = "trans_sy";				
		}			
	}
	<%}%>
	
	if(objToFocus != ""){
		document.form_.move_focus_to.value = objToFocus;
		document.form_.verify_msg.value = strVerifyMsg;		
		if(strLoad == "1")
			document.form_.submit();
	}	
}

function GoBack(){
		
	this.Verify('0');
	
	if(document.form_.verify_msg.value != "" && objToFocus != ""){
		alert(document.form_.verify_msg.value);		
		eval('document.form_.'+objToFocus+'.focus();');				
		return;	
	}
	
	
	<%if(!bolIsLimited) {%>
		location = "./student_personal_data.jsp?get_student_info=1&stud_id="+document.form_.stud_id.value;	
	<%}else{%>
		location = "./student_personal_data_limited.jsp?get_student_info=1&stud_id="+document.form_.stud_id.value;
	<%}%>

//		location = "./student_personal_data.jsp?get_student_info=1&stud_id="+document.form_.stud_id.value;
}


function GetVerifyMsg(){
	alert(document.form_.verify_msg.value);
	document.form_.verify_msg.value = "";
}


</script>
<%	
	
	StudentPersonalDataCIT spd = new StudentPersonalDataCIT();
	
	//not used any more.. 
	/**
	if(WI.fillTextValue("edit_last_school").length() > 0){
		if(!spd.editLastSchoolAttended(dbOP, request, strUserIndex))
			strErrMsg = spd.getErrMsg();
		else
			strErrMsg = "Last school information edited successfully.";
	}**/
	
	if(WI.fillTextValue("edit_sch_info").length() > 0){
		if(!spd.editSchoolInformation(dbOP, request, strUserIndex))
			strErrMsg = spd.getErrMsg();
		else
			strErrMsg = "School information edited successfully.";
	}
	
	Vector vRetResult = spd.getPart2Info(dbOP, request, strUserIndex);
	if(vRetResult == null)
		strErrMsg = spd.getErrMsg();
		
	
	String strTDColor = " bgcolor='#FF0000'";
%>
<body bgcolor="#D2AE72" onLoad="<%if(WI.fillTextValue("move_focus_to").length() > 0){%>GetFocusElement();<%}%>" onUnload="Verify('1');" >
<form name="form_" action="student_acad_info.jsp" method="post">
	<input type="hidden" name="verify_msg" value="<%=WI.fillTextValue("verify_msg")%>">
	
	
	<%if(WI.fillTextValue("verify_msg").length() > 0){%><script>GetVerifyMsg();</script><%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: PART II: ACADEMIC INFORMATION ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td width="90%" height="25"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right">
				<a href="javascript:GoBack();"><img src="../../../../images/go_back.gif" border="0"></a></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" width="40%">Scholarship (If any)
							<input name="scholarship" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(15))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','scholarship','1', document.form_.scholarship);"></td>
						<td width="60%">High School General Average: 
							<input name="hs_gen_ave" type="text" size="16" value="<%=WI.getStrValue((String)vRetResult.elementAt(16))%>" class="textbox" maxlength="6"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','hs_gen_ave');style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','hs_gen_ave','0', document.form_.hs_gen_ave);"></td>
					</tr>
					<tr>
						<td height="25" colspan="2">Are you working?
							<%
								if(((String)vRetResult.elementAt(0)).equals("1"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="is_working" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','is_working','0', document.form_.is_working[0]);">Yes
							<%
								if(((String)vRetResult.elementAt(0)).equals("2"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="is_working" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','is_working','0', document.form_.is_working[1]);">No
							&nbsp;&nbsp;
							If Yes, Name of Company
							<input name="company_name" type="text" size="64" value="<%=WI.getStrValue((String)vRetResult.elementAt(1))%>" class="textbox" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','company_name','1', document.form_.company_name);">
					  </td>
					</tr>
					<tr>
						<td height="25" colspan="2">Company Address 
							<input name="company_addr" type="text" size="64" value="<%=WI.getStrValue((String)vRetResult.elementAt(2))%>" class="textbox" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','company_addr','1', document.form_.company_addr);">
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Company Tel no. 
							<input name="company_tel" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(3))%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','company_tel','1', document.form_.company_tel);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" width="35%">Course Preferences in CIT University</td>
						<td width="20%">Course 1</td>
						<td width="20%">Course 2</td>
						<td width="25%">Course 3</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(4));
						%>
						<td>
							<select name="course_pref1" 
								onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','course_pref1','0', document.form_.course_pref1);">
								<option value="">Select Course</option>
								<%=dbOP.loadCombo("course_index","course_code"," from course_offered where is_valid = 1 and is_del = 0 "+
												" and is_offered = 1 and is_visible = 1 order by course_code ",strTemp,false)%>
							</select></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(5));
						%>
						<td>
							<select name="course_pref2" 
								onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','course_pref2','0', document.form_.course_pref2);">
								<option value="">Select Course</option>
								<%=dbOP.loadCombo("course_index","course_code"," from course_offered where is_valid = 1 and is_del = 0 "+
												" and is_offered = 1 and is_visible = 1 order by course_code ",strTemp,false)%>
							</select></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(6));
						%>
						<td>
							<select name="course_pref3" 
								onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','course_pref3','0', document.form_.course_pref3);">
								<option value="">Select Course</option>
								<%=dbOP.loadCombo("course_index","course_code"," from course_offered where is_valid = 1 and is_del = 0 "+
												" and is_offered = 1 and is_visible = 1 order by course_code ",strTemp,false)%>
							</select></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(21));
						%>
						<td height="25">Last School Attended: 
							<select name="last_school_attended" style="font-size:10px; width:300px" onChange="AjaxUpdateLastSchoolAttended();">
								<option value=""></option>
								<%=dbOP.loadCombo("sch_accr_index","sch_name, sch_addr"," from sch_accredited where is_del=0 order by sch_name",strTemp,false)%>
							</select>
							&nbsp;&nbsp;
							<label id="lsa_update" style="color:#FF0000; font-weight:bold"></label>&nbsp;&nbsp;
							<!--
								cannot do ajax to change last school information. there is is_valid flag for each entry.
								if there is an entry, update if WI.fillTextValue(last_school_attended) > 0, else invalidate this entry
								if there is no entry, create one if WI.fillTextValue(last_school_attended) > 0, else do nothing
							
							<input type="button" name="edit2" value="Change Information >>" onClick="javascript:EditLastSchool();">
							-->
						</td>
					</tr>
					<tr>
						<td height="25">School Year:
							<input name="last_sch_yr" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(19))%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','last_sch_yr','1', document.form_.last_sch_yr);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>			
			<td>
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
					<%
						Vector vTemp = (Vector)vRetResult.elementAt(20);
					%>
					<tr>
						<td height="25" colspan="4"><strong>Schools Attended: 
						  <a href="javascript:UpdateSchoolList();">Update</a> 
						
						</strong></td>
					</tr>
					<tr>
						<td height="25" width="15%"><label id="update_sch_attended" style="font-weight:bold; font-size:13px; color:blue"></label></td>
						<td width="15%">NAME</td>
						<td width="15%"><!--COURSE/-->YEAR GRADUATED </td>
						<td width="15%"><!--sHONORS_AWARDS-->GRADE COMPLETED</td>
					</tr>
					<tr>
						<%
						strErrMsg = "";
						strTemp = WI.getStrValue((String)vTemp.elementAt(0));
						if(strTemp.length() == 0)
							strErrMsg = strTDColor;			
						strTemp = WI.getStrValue((String)vTemp.elementAt(2));
						if(strTemp.length() == 0)
							strErrMsg = strTDColor;
						strTemp = WI.getStrValue((String)vTemp.elementAt(3));
						if(strTemp.length() == 0)
							strErrMsg = strTDColor;
				
						%>
						<td height="25" <%=strErrMsg%>>High School</td>
						<%
							strTemp = WI.getStrValue((String)vTemp.elementAt(0));
						%>
						<td>
							<select name="hs_sch_name" style="font-size:10px; width:300px" onChange="AjaxUpdateSchoolInfo('High school','1',document.form_.hs_sch_name);">
								<option value=""></option>
								<%=dbOP.loadCombo("sch_accredited.sch_name","sch_accredited.sch_name, sch_addr"," from sch_accredited where is_del=0 order by sch_accredited.sch_name",strTemp,false)%>
							</select></td>
						<td>
							<!--
							<input name="hs_course_taken" type="text" size="16" maxlength="64" value="<%=WI.getStrValue((String)vTemp.elementAt(1))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
							-->
							<input name="hs_year_grade" type="text" size="4" maxlength="4" value="<%=WI.getStrValue((String)vTemp.elementAt(2))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'; AjaxUpdateSchoolInfo('High school','2',document.form_.hs_year_grade);"
								onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
						<td>
							<input name="hs_grade_completed" type="text" size="28" maxlength="64" value="<%=WI.getStrValue((String)vTemp.elementAt(3))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AjaxUpdateSchoolInfo('High school','3',document.form_.hs_grade_completed);"></td>
					</tr>
					<tr>
						<%
						strErrMsg = "";
						strTemp = WI.getStrValue((String)vTemp.elementAt(5));
						if(strTemp.length() == 0)
							strErrMsg = strTDColor;			
						strTemp = WI.getStrValue((String)vTemp.elementAt(7));
						if(strTemp.length() == 0)
							strErrMsg = strTDColor;
						strTemp = WI.getStrValue((String)vTemp.elementAt(8));
						if(strTemp.length() == 0)
							strErrMsg = strTDColor;
				
						%>
						<td height="25" <%=strErrMsg%>>Elementary</td>
						<%
							strTemp = WI.getStrValue((String)vTemp.elementAt(5));
						%>
						<td>
							<select name="elem_sch_name" style="font-size:10px; width:300px" onChange="AjaxUpdateSchoolInfo('Elementary','1',document.form_.elem_sch_name);">
								<option value=""></option>
								<%=dbOP.loadCombo("sch_accredited.sch_name","sch_accredited.sch_name, sch_addr"," from sch_accredited where is_del=0 order by sch_accredited.sch_name",strTemp,false)%>
							</select></td>
						<td>
							<!--
							<input name="elem_course_taken" type="text" size="16" maxlength="64" value="<%=WI.getStrValue((String)vTemp.elementAt(6))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
							-->
							<input name="elem_year_grade" type="text" size="4" maxlength="4" value="<%=WI.getStrValue((String)vTemp.elementAt(7))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AjaxUpdateSchoolInfo('Elementary','2',document.form_.elem_year_grade);"
								onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
						<td>
							<input name="elem_grade_completed" type="text" size="28" maxlength="64" value="<%=WI.getStrValue((String)vTemp.elementAt(8))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AjaxUpdateSchoolInfo('Elementary','3',document.form_.elem_grade_completed);"></td>
					</tr>
					<tr>
					  <td height="25">Preschool</td>
						<%
							strTemp = WI.getStrValue((String)vTemp.elementAt(10));
						%>
						<td>
							<select name="ps_sch_name" style="font-size:10px; width:300px" onChange="AjaxUpdateSchoolInfo('Preschool','1',document.form_.ps_sch_name);">
								<option value=""></option>
								<%=dbOP.loadCombo("sch_accredited.sch_name","sch_accredited.sch_name, sch_addr"," from sch_accredited where is_del=0 order by sch_accredited.sch_name",strTemp,false)%>
							</select></td>
						<td>
							<!--
							<input name="ps_course_taken" type="text" size="16" maxlength="64" value="<%=WI.getStrValue((String)vTemp.elementAt(11))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
							-->
							<input name="ps_year_grade" type="text" size="4" maxlength="4" value="<%=WI.getStrValue((String)vTemp.elementAt(12))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AjaxUpdateSchoolInfo('Preschool','2',document.form_.ps_year_grade);"
								onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
						<td>
							<input name="ps_grade_completed" type="text" size="28" maxlength="64" value="<%=WI.getStrValue((String)vTemp.elementAt(13))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AjaxUpdateSchoolInfo('Preschool','3',document.form_.ps_grade_completed);"></td>
				  </tr><!--
					<tr>
						<td height="25" colspan="4" align="center"><input type="button" name="edit" value="Change Information >>" onClick="javascript:EditSchoolInfo();"></td>
					</tr>
					-->
				</table>
			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="2"><strong>If Transferee/College Graduate</strong></td>
					</tr>
					<tr>
						<%
						strErrMsg = "";
						strTemp = WI.getStrValue((String)vRetResult.elementAt(17));
						if(strTemp.length() == 0 && bolIsTransfer)
							strErrMsg = strTDColor;					
						%>
						<td height="25" width="50%" <%=strErrMsg%>>Previous Course
							<input name="trans_prev_course" type="text" size="50" value="<%=WI.getStrValue((String)vRetResult.elementAt(17))%>" class="textbox" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','trans_prev_course','1', document.form_.trans_prev_course);"></td>
						<%
						strErrMsg = "";
						strTemp = WI.getStrValue((String)vRetResult.elementAt(18));
						if(strTemp.length() == 0 && bolIsTransfer)
							strErrMsg = strTDColor;					
						%>
						<td width="50%" <%=strErrMsg%>>School Year
							<input name="trans_sy" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(18))%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','trans_sy','1', document.form_.trans_sy);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="3">Have you ever stopped going to school before the end of the school year? 
							<%
								if(((String)vRetResult.elementAt(7)).equals("1"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="has_stopped" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','has_stopped','0', document.form_.has_stopped[0]);">Yes
							<%
								if(((String)vRetResult.elementAt(7)).equals("2"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="has_stopped" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','has_stopped','0', document.form_.has_stopped[1]);">No</td>
					</tr>
					<tr>
						<td height="25" width="15%">If YES, state the: </td>
						<td colspan="2">REASON 
							<input name="stop_reason" type="text" size="100" value="<%=WI.getStrValue((String)vRetResult.elementAt(8))%>" class="textbox" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','stop_reason','1', document.form_.stop_reason);"></td>
					</tr>
					<tr>
						<td height="25" width="15%">&nbsp;</td>
						<td width="50%">Grade you were in 
							<input name="stop_grade" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(9))%>" class="textbox" maxlength="64"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','stop_grade','1', document.form_.stop_grade);"></td>
						<td width="35%">School Year
							<input name="stop_sy" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(10))%>" class="textbox" maxlength="64"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','stop_sy','1', document.form_.stop_sy);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="3">Have you been dismissed from any other school or denied readmission? 
							<%
								if(((String)vRetResult.elementAt(11)).equals("1"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="has_dismissed" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','has_dismissed','0', document.form_.has_dismissed[0]);">Yes
							<%
								if(((String)vRetResult.elementAt(11)).equals("2"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
					  <input type="radio" name="has_dismissed" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','has_dismissed','0', document.form_.has_dismissed[1]);">No</td>
					</tr>
					<tr>
						<td height="25" width="15%">If YES, state the: </td>
						<td colspan="2">REASON 
							<input name="dismiss_reason" type="text" size="100" value="<%=WI.getStrValue((String)vRetResult.elementAt(12))%>" class="textbox" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','dismiss_reason','1', document.form_.dismiss_reason);"></td>
					</tr>
					<tr>
						<td height="25" width="15%">&nbsp;</td>
						<td width="50%">Grade you were in 
							<input name="dismiss_grade" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(13))%>" class="textbox" maxlength="64"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','dismiss_grade','1', document.form_.dismiss_grade);"></td>
						<td width="35%">School Year
							<input name="dismiss_sy" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(14))%>" class="textbox" maxlength="64"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','dismiss_sy','1', document.form_.dismiss_sy);"></td>
					</tr>
				</table>
			</td>
		</tr>
  </table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td colspan="8" height="25" >&nbsp;</td>
		</tr>
		<tr>
			<td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="stud_index" value="<%=strUserIndex%>">
	<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
	<input type="hidden" name="edit_sch_info">
	<input type="hidden" name="edit_last_school">
	<input type="hidden" name="move_focus_to" value="<%=WI.fillTextValue("move_focus_to")%>" />
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>