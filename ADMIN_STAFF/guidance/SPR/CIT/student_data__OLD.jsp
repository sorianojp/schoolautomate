<%@ page language="java" import="utility.*,osaGuidance.StudentPersonalDataCIT,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;

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
boolean bolIsRegistrar = false;


	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Registrar Management","Student Tracker",request.getRemoteAddr(),null);

	if(iAccessLevel == 0)
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Guidance & Counseling","STUDENT PERSONAL DATA-PART I",request.getRemoteAddr(), null);	
	else 
		bolIsRegistrar = true;
																	
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
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function UpdateSiblings(strUserIndex){
		var pgLoc = "./update_sibling.jsp?user_index="+strUserIndex;	
		var win=window.open(pgLoc,"UpdateSiblings",'width=900,height=450,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function FocusID() {
		if (document.form_.dob && document.form_.dob.value.length > 0){
			UpdateAge();
		}
	}

	function UpdateAge(){
		var	strDateToday = "<%=WI.getTodaysDate(1)%>";
		document.form_.age.value = calculateAge(document.form_.dob.value,strDateToday,true);
		//document.form_.f_age.value = calculateAge(document.form_.f_dob.value,strDateToday,true);
		//document.form_.m_age.value = calculateAge(document.form_.m_dob.value,strDateToday,true);
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
		
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=20401&table_name="+strTableName+"&field_name="+strFieldName+"&table_index="+strIndex+"&is_string="+strIsString+"&field_value="+value+"&"+strFieldName+"="+value+"&index_name="+strIndexName;
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
		
	function GoBack(){
		<%if(!bolIsLimited) {%>
			location = "./student_personal_data.jsp?get_student_info=1&stud_id="+document.form_.stud_id.value;	
		<%}else{%>
			location = "./student_personal_data_limited.jsp?get_student_info=1&stud_id="+document.form_.stud_id.value;
		<%}%>
	}
	
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField+"&hide_del=1&opner_form_field=form_";
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdatePreloadAddr(strUserRef, strAddr) {
	var loadPg = "./preload_zip.jsp?user_ref="+strUserRef+"&addr="+strAddr;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=600,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%	
	String strUserIndex = WI.fillTextValue("stud_index");
	if(strUserIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Student reference is not found. Please close this window and click on the Part I link to try again..</p>
	<%return;}
	
	int iTemp = 0;
	StudentPersonalDataCIT spd = new StudentPersonalDataCIT();
	Vector vRetResult = spd.getPart1Info(dbOP, request, strUserIndex);
	if(vRetResult == null)
		strErrMsg = spd.getErrMsg();

%>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<form name="form_" action="student_data_.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: PART I: STUDENT'S PERSONAL DATA ::::</strong></font></div></td>
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
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
					<tr>
						<td height="25" width="20%"><strong>Last Name </strong></td>
						<td width="20%"><strong>First Name </strong></td>
						<td width="20%"><strong>Middle Name </strong></td>
						<td width="20%"><strong>Nickname</strong></td>
						<td width="20%"><strong>Age</strong></td>
					</tr>
					<tr>
						<td height="25">
						<%if(bolIsRegistrar) {%>
							<input type="text" name="lname" value="<%=WI.getStrValue((String)vRetResult.elementAt(0))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','USER_TABLE','lname','1', document.form_.lname);">
						<%}else{%>
							<font style="font-size:12px; font-weight:bold"><%=WI.getStrValue((String)vRetResult.elementAt(0))%></font>
						<%}%>
						</td>
						<td>
						<%if(bolIsRegistrar) {%>
							<input type="text" name="fname" value="<%=WI.getStrValue((String)vRetResult.elementAt(1))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','USER_TABLE','fname','1', document.form_.fname);">
						<%}else{%>
							<font style="font-size:12px; font-weight:bold"><%=WI.getStrValue((String)vRetResult.elementAt(1))%></font>
						<%}%>
						</td>
						<td>
						<%if(bolIsRegistrar) {%>
							<input type="text" name="mname" value="<%=WI.getStrValue((String)vRetResult.elementAt(2))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','USER_TABLE','fname','1', document.form_.fname);">
						<%}else{%>
							<font style="font-size:12px; font-weight:bold"><%=WI.getStrValue((String)vRetResult.elementAt(2))%></font>
						<%}%>
						</td>
						<td>
							<input type="text" name="nickname" value="<%=WI.getStrValue((String)vRetResult.elementAt(3))%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','USER_TABLE','nickname','1', document.form_.nickname);"></td>
						<td><input type="text" name="age" value="" class="textbox_noborder" readonly="yes" size="8" tabindex="-1"></td>
					</tr>
				</table></td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
					<tr>
						<td height="25" width="20%">Gender</td>
						<td width="20%">Nationality</td>
						<td width="20%">Religion</td>
						<td width="12%">Date of Birth </td>
						<td width="16%">Place of Birth </td>
						<td width="12%">Civil Status </td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(4));
						%>
					  	<td height="25">
							<select name="gender" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PERSONAL','gender','1', document.form_.gender);">
								<option value="M">Male</option>
							<%if(strTemp.equals("F")){%>
								<option value="F" selected>Female</option>
							<%}else{%>
								<option value="F">Female</option>
							<%}%>
							</select></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(5));
						%>
					  	<td>
							<select name="nationality" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PERSONAL','nationality','1', document.form_.nationality);" style="font-size:10px;">
								<option value="">Select nationality</option>
                				<%=dbOP.loadCombo("nationality","nationality"," from hr_preload_nationality order by nationality",strTemp,false)%>
							</select>

						  <a href='javascript:viewList("HR_PRELOAD_NATIONALITY","NATIONALITY_INDEX","NATIONALITY","NATIONALITY",
							"HR_INFO_PERSONAL,HR_APPL_INFO_PERSONAL","NATIONALITY_INDEX, NATIONALITY_INDEX", 
							" and HR_INFO_PERSONAL.is_del = 0, and HR_APPL_INFO_PERSONAL.is_del = 0","","nationality")'>Update</a> 

							</td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(6));
						%>
					  	<td>
							<select name="religion" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PERSONAL','religion','1', document.form_.religion);" style="font-size:10px;">
								<option value="">Select Religion</option>
								<%=dbOP.loadCombo("religion","religion"," from hr_preload_religion order by religion",strTemp,false)%>
							</select>
							
						  <a href='javascript:viewList("HR_PRELOAD_RELIGION","RELIGION_INDEX","RELIGION","RELIGION",
				"HR_INFO_PERSONAL,HR_APPL_INFO_PERSONAL","RELIGION_INDEX, RELIGION_INDEX", 
				" and HR_INFO_PERSONAL.is_del = 0, and HR_APPL_INFO_PERSONAL.is_del = 0","","religion")'>Update</a> 

							</td>
					  	<td>
							<input name="dob" type="text" size="10" maxlength="10" value="<%=WI.getStrValue((String)vRetResult.elementAt(7))%>" class="textbox" readonly="yes"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="UpdateAge();style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PERSONAL','dob','2', document.form_.dob);"
								onKeyUP="AllowOnlyIntegerExtn('form_','dob','/');UpdateAge()">
							<a href="javascript:show_calendar('form_.dob',<%=CommonUtil.getMMYYYYForCal()%>);" title="Click to select date" 
								onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
					  	<td>
							<input name="place_of_birth" value="<%=WI.getStrValue((String)vRetResult.elementAt(8))%>" type= "text" class="textbox" size="16" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PERSONAL','place_of_birth','1', document.form_.place_of_birth);"></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(9), "Single");
						%>
					  	<td>
							<select name="civil_stat" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PERSONAL','civil_stat','1', document.form_.civil_stat);" style="font-size:10px;">
							<%if (strTemp.equals("Single")){%>
								<option value="Single" selected>Single</option>
							<%}else{%>
								<option value="Single">Single</option>
							<%}if (strTemp.equals("Married")) {%>
								<option value="Married" selected>Married</option>
							<%}else{%>
								<option value="Married">Married</option>
							<%}if (strTemp.equals("Divorced/Separated")) {%>
								<option value="Divorced/Separated" selected>Divorced/Separated</option>
							<%}else{%>
								<option value="Divorced/Separated">Divorced/Separated</option>
							<%}if (strTemp.equals("Widow/Widower")) {%>
								<option value="Widow/Widower" selected>Widow/Widower</option>
							<%}else{%>
								<option value="Widow/Widower">Widow/Widower</option>
							<%}%>
							</select></td>
				  	</tr>
					<tr>
						<td height="25">Dialect</td>
						<td>Email Address </td>
						<td colspan="4">Tel. No./Cellphone No. </td>
					</tr>
					<tr>
						<td height="25">
							<input type="text" name="native_lan" value="<%=WI.getStrValue((String)vRetResult.elementAt(10))%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PERSONAL','native_lan','1', document.form_.native_lan);"></td>
					  	<td>
							<input name="email" type="text" class="textbox" value="<%=WI.getStrValue((String)vRetResult.elementAt(11))%>" maxlength="64"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PERSONAL','email','1', document.form_.email);"></td>
					  	<td colspan="4">
							<input name="contact_mob_no" type="text" size="16" value="<%=WI.getStrValue((String)vRetResult.elementAt(12))%>" class="textbox" maxlength="16"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PERSONAL','contact_mob_no','1', document.form_.contact_mob_no);"></td>
				  	</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="15" bgcolor="#CCCCCC">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="6"><strong>Phyiscal Description</strong></td>
					</tr>
					<tr>
						<td height="25" width="12%">Height</td>
				  	    <td width="12%">Weight</td>
				  	    <td width="12%">Eye Color </td>
				  	    <td width="12%">Hair Color </td>
				  	    <td width="17%">Complexion</td>
				  	    <td width="35%">Other distinguishing features/marks (ex. Scar, mole) </td>
					</tr>
					<tr>
					  	<td height="25">
							<input name="height" type= "text" value="<%=WI.getStrValue((String)vRetResult.elementAt(13))%>" class="textbox" size="8" maxlength="16"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PHYSICAL','height','1', document.form_.height);"></td>
					  	<td>
							<input name="weight" type= "text" value="<%=WI.getStrValue((String)vRetResult.elementAt(14))%>" class="textbox" size="8" maxlength="16"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PHYSICAL','weight','1', document.form_.weight);"></td>
					  	<td>
							<input name="eye_color" type= "text" value="<%=WI.getStrValue((String)vRetResult.elementAt(15))%>" class="textbox" size="8" maxlength="16"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PHYSICAL','eye_color','1', document.form_.eye_color);"></td>
					  	<td>
							<input name="hair_color" type= "text" value="<%=WI.getStrValue((String)vRetResult.elementAt(16))%>" class="textbox" size="8" maxlength="16"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PHYSICAL','hair_color','1', document.form_.hair_color);"></td>
					  	<td>
							<input name="complexion" type= "text" value="<%=WI.getStrValue((String)vRetResult.elementAt(17))%>" class="textbox" size="8" maxlength="16"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PHYSICAL','complexion','1', document.form_.complexion);"></td>
					  	<td>
							<input name="oth_prominent_feature" type= "text" class="textbox" value="<%=WI.getStrValue((String)vRetResult.elementAt(18))%>" size="40" maxlength="64"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PHYSICAL','oth_prominent_feature','1', document.form_.oth_prominent_feature);"></td>
					</tr>
				</table>			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="2"><strong>Home Address</strong></td>
					</tr>
<!--
					<tr>
					  	<td height="25" width="22%">House no./ Street / Barangay </td>
				  	    <td width="22%">City/Municipality</td>
				  	    <td width="22%">Province/State</td>
				  	    <td width="22%">Country</td>
				  	    <td width="12%">Zip Code </td>
					</tr>
					<tr>
					  	<td height="25">
							<input name="res_house_no" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(19))%>" size="24" class="textbox" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','res_house_no','1', document.form_.res_house_no);"></td>
					  	<td>
							<input name="res_city" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(20))%>" size="24" class="textbox"  maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','res_city','1', document.form_.res_city);"></td>
					  	<td>
							<input name="res_provience" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(21))%>" class="textbox" size="16" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','res_provience','1', document.form_.res_provience);"></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(22));
							if(strTemp.length() == 0) 
								strTemp = "2";//philippines.
						%>
					  	<td>
							<select name="res_country" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','res_country','1', document.form_.res_country);">
								<option value="">Select Country</option>
								<%=dbOP.loadCombo("country","country"," from hr_preload_country",strTemp,false)%>
							</select></td>
					  	<td>
							<input name="res_zip" type="text"  value="<%=WI.getStrValue((String)vRetResult.elementAt(23))%>" class="textbox" size="12" maxlength="10"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','res_zip','1', document.form_.res_zip);"></td>
				  	</tr>
-->
					<tr>
					  	<td height="25" width="55%">House no./ Street / Barangay </td>
				  	    <td width="45%">City/Town/Province/Zip</td>
			  	    </tr>
					<tr>
					  	<td height="25">
							<input name="res_house_no" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(19))%>" size="72" class="textbox" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','res_house_no','1', document.form_.res_house_no);"></td>
					  	<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(20), "", ",", "") + WI.getStrValue((String)vRetResult.elementAt(21), "", " - ", "")+
							WI.getStrValue((String)vRetResult.elementAt(23));
							
						%>
					  	<td><label id="_res_addr"><%=strTemp%></label> 
						
						<a href='javascript:UpdatePreloadAddr("<%=strUserIndex%>","1")'>Update</a>
				
						</td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">Telephone Nos./Cellphone Nos. </td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">
							<input name="res_tel" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(24))%>" size="24" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','res_tel','1', document.form_.res_tel);"></td>
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
						<td height="25" width="40%"><strong>Residence while enrolled in CIT University </strong></td>
						<%
							if(((String)vRetResult.elementAt(91)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="20%"><input type="radio" name="study_residence" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','study_residence','0', document.form_.study_residence[0]);">with parents</td>
						<%
							if(((String)vRetResult.elementAt(91)).equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="20%"><input type="radio" name="study_residence" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','study_residence','0', document.form_.study_residence[1]);">with guardians</td>
						<%
							if(((String)vRetResult.elementAt(91)).equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="20%"><input type="radio" name="study_residence" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','study_residence','0', document.form_.study_residence[2]);">boarding</td>	
					</tr>
					<tr>
					  	<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(91)).equals("4"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="radio" name="study_residence" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','study_residence','0', document.form_.study_residence[3]);">with relatives</td>
						<%
							if(((String)vRetResult.elementAt(91)).equals("5"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td colspan="2"><input type="radio" name="study_residence" value="5" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','study_residence','0', document.form_.study_residence[4]);">others (pls. specify)
							<input name="study_residence_text" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(92))%>" size="32" class="textbox" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','study_residence_text','1', document.form_.study_residence_text);"></td>
				  	</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
					<tr>
						<td height="25"><strong>FATHER'S NAME</strong> </td>
					</tr>
					<!--<tr>
					  	<td height="25" width="20%">Last Name </td>
				  	    <td width="20%">First Name </td>
				  	    <td width="20%">Middle Name </td>
						<td width="40%">&nbsp;</td>
					</tr>
					<tr>
					  	<td height="25">
							<input type="text" name="f_lname" value="<%=WI.getStrValue((String)vRetResult.elementAt(57))%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_lname','1', document.form_.f_lname);"></td>
					  	<td>
							<input type="text" name="f_fname" value="<%=WI.getStrValue((String)vRetResult.elementAt(58))%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_fname','1', document.form_.f_fname);"></td>
					  	<td>
							<input type="text" name="f_mname" value="<%=WI.getStrValue((String)vRetResult.elementAt(59))%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_mname','1', document.form_.f_mname);"></td>
				  	    <td></td>
					</tr>-->
					<tr>
					  	<td height="25" width="20%">First Name MI. Last name </td>
			  	    </tr>
					<tr>
					  	<td height="25">
							<input type="text" name="f_name" value="<%=WI.getStrValue((String)vRetResult.elementAt(57))%>" class="textbox" maxlength="64" size="64"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_name','1', document.form_.f_name);"></td>
				  	</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
					<tr>
						<td height="25" width="10%">Age</td>
					    <td width="15%">Place of Birth </td>
					    <td width="15%">Dialect</td>
					    <td width="20%">Nationality</td>
					    <td width="20%">Religion</td>
					    <td width="15%">Email Address </td>
					</tr>
					<tr>
						<td height="25">
							<input name="f_age" type="text" size="4" maxlength="2" value="<%=WI.getStrValue((String)vRetResult.elementAt(93))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','f_age');"
								onBlur="AllowOnlyInteger('form_','f_age');style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_age','0', document.form_.f_age);">
							<!--<input type="text" name="f_age" value="" class="textbox_noborder" size="8" tabindex="-1">--></td>
						<td>
							<input name="f_place_of_birth" value="<%=WI.getStrValue((String)vRetResult.elementAt(61))%>" type= "text" class="textbox" size="16" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_place_of_birth','1', document.form_.f_place_of_birth);"></td>
						<td>
							<input name="f_dialect" value="<%=WI.getStrValue((String)vRetResult.elementAt(62))%>" type= "text" class="textbox" size="16" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_dialect','1', document.form_.f_dialect);"></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(63));
						%>
						<td>
							<select name="f_nationality" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_nationality','1', document.form_.f_nationality);">
								<option value="">Select nationality</option>
                				<%=dbOP.loadCombo("nationality","nationality"," from hr_preload_nationality order by nationality",strTemp,false)%>
							</select></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(64));
						%>
					  	<td>
							<select name="f_religion" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_religion','1', document.form_.f_religion);">
								<option value="">Select Religion</option>
								<%=dbOP.loadCombo("religion","religion"," from hr_preload_religion order by religion",strTemp,false)%>
							</select></td>
						<td>
							<input name="f_email" type="text" class="textbox" value="<%=WI.getStrValue((String)vRetResult.elementAt(65))%>" maxlength="64"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_email','1', document.form_.f_email);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
					<tr>
						<td height="25" width="50%">Highest Educational Attainment:
						<input type="text" name="f_educ_attainment" value="<%=WI.getStrValue((String)vRetResult.elementAt(66))%>" class="textbox" size="36" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_educ_attainment','1', document.form_.f_educ_attainment);"></td>
						<td width="50%">Present Job/Position:
					    <input type="text" name="f_occupation" value="<%=WI.getStrValue((String)vRetResult.elementAt(67))%>" class="textbox" size="36" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_occupation','1', document.form_.f_occupation);"></td>
					</tr>
					<tr>
						<td height="25">Company Name: 
			    		<input type="text" name="f_comp_name" value="<%=WI.getStrValue((String)vRetResult.elementAt(68))%>" class="textbox" size="50" maxlength="64"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_comp_name','1', document.form_.f_comp_name);"></td>
						<td>Company Address: 
				    	<input type="text" name="f_comp_addr" value="<%=WI.getStrValue((String)vRetResult.elementAt(69))%>" class="textbox" size="38"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_comp_addr','1', document.form_.f_comp_addr);"></td>
					</tr>
					<tr>
						<td height="25" colspan="2">Company Tel No./Cellphone No. 
				    	<input type="text" name="f_tel" value="<%=WI.getStrValue((String)vRetResult.elementAt(70))%>" class="textbox" size="37" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_tel','1', document.form_.f_tel);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
					<tr>
						<td height="25" width="30%">Company/Agency Type (pls. check)</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(71)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="20%"><input type="radio" name="f_comp_type" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_comp_type','0', document.form_.f_comp_type[0]);">government</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(71)).equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="20%"><input type="radio" name="f_comp_type" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_comp_type','0', document.form_.f_comp_type[1]);">self-employed</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(71)).equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="30%"><input type="radio" name="f_comp_type" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_comp_type','0', document.form_.f_comp_type[2]);">private agency/company</td>	
					</tr>
					<tr>
					  	<td height="25">If not working, state the reason (pls. check) </td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(72)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="radio" name="f_not_working_reason" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_not_working_reason','0', document.form_.f_not_working_reason[0]);">retired</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(72)).equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="radio" name="f_not_working_reason" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_not_working_reason','0', document.form_.f_not_working_reason[1]);">sick</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(72)).equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="radio" name="f_not_working_reason" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_not_working_reason','0', document.form_.f_not_working_reason[2]);">resigned</td>
				  	</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(72)).equals("4"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="radio" name="f_not_working_reason" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_not_working_reason','0', document.form_.f_not_working_reason[3]);">disabled</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(72)).equals("5"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td colspan="2"><input type="radio" name="f_not_working_reason" value="5" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_not_working_reason','0', document.form_.f_not_working_reason[4]);">others (pls. specify)
							<input name="f_not_working_others" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(89))%>" size="32" class="textbox" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_not_working_others','1', document.form_.f_not_working_others);"></td>
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
						<td height="25"><strong>MOTHER'S NAME</strong> </td>
					</tr>
					<!--
					<tr>
					  	<td height="25" width="20%">Last Name </td>
				  	    <td width="20%">First Name </td>
				  	    <td width="20%">Middle Name </td>
						<td width="40%"></td>
					</tr>
					<tr>
					  	<td height="25">
							<input type="text" name="m_lname" value="<%=WI.getStrValue((String)vRetResult.elementAt(73))%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_lname','1', document.form_.m_lname);"></td>
					  	<td>
							<input type="text" name="m_fname" value="<%=WI.getStrValue((String)vRetResult.elementAt(74))%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_fname','1', document.form_.m_fname);"></td>
					  	<td>
							<input type="text" name="m_mname" value="<%=WI.getStrValue((String)vRetResult.elementAt(75))%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_mname','1', document.form_.m_mname);"></td>
						<td></td>
				  	</tr>-->
					<tr>
					  	<td height="25" width="20%">First Name MI. Last name </td>
			  	    </tr>
					<tr>
					  	<td height="25">
							<input type="text" name="m_name" value="<%=WI.getStrValue((String)vRetResult.elementAt(73))%>" class="textbox" maxlength="64" size="64"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_name','1', document.form_.m_name);"></td>
				  	</tr>

				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" width="10%">Age</td>
					    <td width="15%">Place of Birth </td>
					    <td width="15%">Dialect</td>
					    <td width="20%">Nationality</td>
					    <td width="20%">Religion</td>
					    <td width="15%">Email Address </td>
					</tr>
					<tr>
						<td height="25">
							<input name="m_age" type="text" size="4" maxlength="2" value="<%=WI.getStrValue((String)vRetResult.elementAt(94))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','m_age');"
								onBlur="AllowOnlyInteger('form_','m_age');style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_age','0', document.form_.m_age);">
							<!--<input type="text" name="m_age" value="" class="textbox_noborder" size="8" tabindex="-1">--></td>
						<td>
							<input name="m_place_of_birth" value="<%=WI.getStrValue((String)vRetResult.elementAt(77))%>" type= "text" class="textbox" size="16" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_place_of_birth','1', document.form_.m_place_of_birth);"></td>
						<td>
							<input name="m_dialect" value="<%=WI.getStrValue((String)vRetResult.elementAt(78))%>" type= "text" class="textbox" size="16" maxlength="32"
									onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_dialect','1', document.form_.m_dialect);"></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(79));
						%>
						<td>
							<select name="m_nationality" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_nationality','1', document.form_.m_nationality);">
								<option value="">Select nationality</option>
                				<%=dbOP.loadCombo("nationality","nationality"," from hr_preload_nationality order by nationality",strTemp,false)%>
							</select></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(80));
						%>
					  	<td>
							<select name="m_religion" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_religion','1', document.form_.m_religion);">
								<option value="">Select Religion</option>
								<%=dbOP.loadCombo("religion","religion"," from hr_preload_religion order by religion",strTemp,false)%>
							</select></td>
						<td>
							<input name="m_email" type="text" class="textbox" value="<%=WI.getStrValue((String)vRetResult.elementAt(81))%>" maxlength="64"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_email','1', document.form_.m_email);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" width="50%">Highest Educational Attainment:
						<input type="text" name="m_educ_attainment" value="<%=WI.getStrValue((String)vRetResult.elementAt(82))%>" class="textbox" size="36" accept="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_educ_attainment','1', document.form_.m_educ_attainment);"></td>
						<td width="50%">Present Job/Position:
					    <input type="text" name="m_occupation" value="<%=WI.getStrValue((String)vRetResult.elementAt(83))%>" class="textbox" size="36"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_occupation','1', document.form_.m_occupation);"></td>
					</tr>
					<tr>
						<td height="25">Company Name: 
				    		<input type="text" name="m_comp_name" value="<%=WI.getStrValue((String)vRetResult.elementAt(84))%>" class="textbox" size="50" maxlength="64"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_comp_name','1', document.form_.m_comp_name);"></td>
						<td>Company Address: 
					    	<input type="text" name="m_comp_addr" value="<%=WI.getStrValue((String)vRetResult.elementAt(85))%>" class="textbox" size="38"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_comp_addr','1', document.form_.m_comp_addr);"></td>
					</tr>
					<tr>
						<td height="25" colspan="2">Company Tel No./Cellphone No. 
					    	<input type="text" name="m_tel" value="<%=WI.getStrValue((String)vRetResult.elementAt(86))%>" class="textbox" size="37" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_tel','1', document.form_.m_tel);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" width="30%">Company/Agency Type (pls. check)</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(87)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="20%"><input type="radio" name="m_comp_type" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_comp_type','0', document.form_.m_comp_type[0]);">government</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(87)).equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="20%"><input type="radio" name="m_comp_type" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_comp_type','0', document.form_.m_comp_type[1]);">self-employed</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(87)).equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="30%"><input type="radio" name="m_comp_type" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_comp_type','0', document.form_.m_comp_type[2]);">private agency/company</td>	
					</tr>
					<tr>
					  	<td height="25">If not working, state the reason (pls. check) </td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(88)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="radio" name="m_not_working_reason" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_not_working_reason','0', document.form_.m_not_working_reason[0]);">retired</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(88)).equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="radio" name="m_not_working_reason" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_not_working_reason','0', document.form_.m_not_working_reason[1]);">sick</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(88)).equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="radio" name="m_not_working_reason" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_not_working_reason','0', document.form_.m_not_working_reason[2]);">resigned</td>
				  	</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(88)).equals("4"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="radio" name="m_not_working_reason" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_not_working_reason','0', document.form_.m_not_working_reason[3]);">disabled</td>
						<%
							if(WI.getStrValue((String)vRetResult.elementAt(88)).equals("5"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td colspan="2"><input type="radio" name="m_not_working_reason" value="5" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_not_working_reason','0', document.form_.m_not_working_reason[4]);">others (pls. specify)
							<input name="m_not_working_others" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(90))%>" size="32" class="textbox" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_not_working_others','1', document.form_.m_not_working_others);"></td>
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
						<td height="25" width="20%">Birth Rank </td>
					    <td width="20%">No. of Brothers </td>
					    <td width="20%">No. of Sisters </td>
					    <td width="40%">Brothers &amp; Sisters in CIT University </td>
					</tr>
					<tr>
						<td height="25">
							<input name="birth_order" type="text" size="10" maxlength="4" value="<%=WI.getStrValue((String)vRetResult.elementAt(53))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','birth_order');"
								onBlur="AllowOnlyInteger('form_','birth_order');style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PERSONAL','birth_order','0', document.form_.birth_order);"></td>
						<td>
							<input name="num_brothers" type="text" size="10" maxlength="4" value="<%=WI.getStrValue((String)vRetResult.elementAt(54))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','num_brothers');"
								onBlur="AllowOnlyInteger('form_','num_brothers');style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','num_brothers','0', document.form_.num_brothers);"></td>
						<td>
							<input name="num_sisters" type="text" size="10" maxlength="4" value="<%=WI.getStrValue((String)vRetResult.elementAt(55))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','num_sisters');"
								onBlur="AllowOnlyInteger('form_','num_sisters');style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','num_sisters','0', document.form_.num_sisters);"></td>
						<td>
							<input name="num_siblings_in_cit" type="text" size="10" maxlength="4" value="<%=WI.getStrValue((String)vRetResult.elementAt(56))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','num_siblings_in_cit');"
								onBlur="AllowOnlyInteger('form_','num_siblings_in_cit');style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','num_siblings_in_cit','0', document.form_.num_siblings_in_cit);"></td>
				  	</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="3"><strong>How many are...</strong></td>
					</tr>
					<tr>
					  	<td height="25" width="10%">&nbsp;</td>
				 	    <td width="25%">
							<input name="sibling_elem" type="text" size="10" maxlength="2" value="<%=WI.getStrValue((String)vRetResult.elementAt(48))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','sibling_elem');"
								onBlur="AllowOnlyInteger('form_','sibling_elem');style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','sibling_elem','0', document.form_.sibling_elem);">
							in Elementary </td>
				 	    <td width="65%">
							<input name="sibling_hs" type="text" size="10" maxlength="2" value="<%=WI.getStrValue((String)vRetResult.elementAt(49))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','sibling_hs');"
								onBlur="AllowOnlyInteger('form_','sibling_hs');style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','sibling_hs','0', document.form_.sibling_hs);"> 
							in High School </td>
					</tr>
					<tr>
					  	<td height="25">&nbsp;</td>
					  	<td>
							<input name="sibling_college" type="text" size="10" maxlength="2" value="<%=WI.getStrValue((String)vRetResult.elementAt(50))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','sibling_college');"
								onBlur="AllowOnlyInteger('form_','sibling_college');style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','sibling_college','0', document.form_.sibling_college);">
							in College </td>
					  	<td>
							<input name="sibling_out_of_school" type="text" size="10" maxlength="2" value="<%=WI.getStrValue((String)vRetResult.elementAt(51))%>" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','sibling_out_of_school');"
								onBlur="AllowOnlyInteger('form_','sibling_out_of_school');style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','sibling_out_of_school','0', document.form_.sibling_out_of_school);">
							out of School </td>
				 	</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<td colspan="2">
							<input name="sibling_work_emp_married" type="text" size="10" maxlength="2" value="<%=WI.getStrValue((String)vRetResult.elementAt(52))%>" 
								class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','sibling_work_emp_married');"
								onBlur="AllowOnlyInteger('form_','sibling_work_emp_married');style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','sibling_work_emp_married','0', document.form_.sibling_work_emp_married);">
							already working/unemployed/married</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<%
					Vector vTemp = (Vector)vRetResult.elementAt(95);
				%>
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="3"><strong>BROTHER and SISTERS (of the student) </strong>
							<a href="javascript:UpdateSiblings('<%=strUserIndex%>');"><img src="../../../../images/update.gif" border="0"></a>
							<font size="1">Click to update sibling information.</font></td>
					</tr>
				</table>
				<%if(vTemp == null || vTemp.size() == 0){%>
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="3">No record of siblings.</td>
					</tr>
				</table>
				<%}else{%>
				<table width="100%" cellpadding="0" cellspacing="0" border="1" bgcolor="#FFFFFF">
					<tr>
						<td height="25" width="35%">NAMES(eldest to youngest)</td>
						<td width="10%">Age</td>
						<td width="55%">School/Occupation &amp; Name of Company</td>
					</tr>
					<%for(int i = 0 ; i < vTemp.size(); i += 4){%>
					<tr>
						<td height="25">&nbsp;<%=(String)vTemp.elementAt(i)%></td>
						<td>&nbsp;<%=(String)vTemp.elementAt(i+1)%></td>
						<td>&nbsp;<%=(String)vTemp.elementAt(i+2)%>/<%=(String)vTemp.elementAt(i+3)%></td>
					</tr>
					<%}%>
				</table>
				<%}%>
			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#CCCCCC">
					<tr>
						<td height="25" width="60%"><strong>GUARDIAN'S NAME </strong>&nbsp;
							<input type="text" name="con_per_name" value="<%=WI.getStrValue((String)vRetResult.elementAt(25))%>" class="textbox" size="64"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','con_per_name','1', document.form_.con_per_name);"></td>
						<td width="40%">Relation to the Guardian&nbsp;
							<input type="text" name="con_per_relation" value="<%=WI.getStrValue((String)vRetResult.elementAt(26))%>" class="textbox" size="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','con_per_relation','1', document.form_.con_per_relation);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#CCCCCC">
<!--
					<tr>
					  	<td height="25" width="22%">House no./ Street / Barangay </td>
				  	    <td width="22%">City/Municipality</td>
				  	    <td width="22%">Province/State</td>
				  	    <td width="22%">Country</td>
				  	    <td width="12%">Zip Code </td>
					</tr>
					<tr>
					  	<td height="25">
							<input name="con_house_no" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(27))%>" size="24" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','con_house_no','1', document.form_.con_house_no);"></td>
					  	<td>
							<input name="con_city" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(28))%>" size="24" class="textbox" 
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','con_city','1', document.form_.con_city);"></td>
					  	<td>
							<input name="con_provience" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(29))%>" class="textbox" size="16"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','con_provience','1', document.form_.con_provience);"></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(30));
						%>
					  	<td>
							<select name="con_country" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','con_country','1', document.form_.con_country);">
								<option value="">Select Country</option>
								<%=dbOP.loadCombo("country","country"," from hr_preload_country",strTemp,false)%>
							</select></td>
					  	<td>
							<input name="con_zip" type="text"  value="<%=WI.getStrValue((String)vRetResult.elementAt(31))%>" class="textbox" size="12"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','con_zip','1', document.form_.con_zip);"></td>
				  	</tr>
-->
					<tr>
					  	<td height="25" width="55%">House no./ Street / Barangay </td>
				  	    <td width="45%">City/Town/Province/Zip</td>
			  	    </tr>
					<tr>
					  	<td height="25">
							<input name="con_house_no" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(27))%>" size="72" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','con_house_no','1', document.form_.con_house_no);"></td>
					  	<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(28), "", ",", "") + WI.getStrValue((String)vRetResult.elementAt(29), "", " - ", "")+
							WI.getStrValue((String)vRetResult.elementAt(31));
							
						%>
					  	<td><label id="_con_addr"><%=strTemp%></label> 
						
						<a href='javascript:UpdatePreloadAddr("<%=strUserIndex%>","2")'>Update</a>
				
						</td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">Telephone Nos./Cellphone Nos. </td>
				  	</tr>
					<tr>
				  	  <td height="25" colspan="2">
							<input name="con_tel" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(32))%>" size="24" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','con_tel','1', document.form_.con_tel);"></td>
				  	</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="15" bgcolor="#CCCCCC">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" width="70%"><strong>In case of Emergency, please contact: </strong>&nbsp;
					      	<input type="text" name="emgn_per_name" value="<%=WI.getStrValue((String)vRetResult.elementAt(34))%>" class="textbox" size="64" maxlength="64"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','emgn_per_name','1', document.form_.emgn_per_name);"></td>
						<td width="30%">Relation&nbsp;
							<input type="text" name="emgn_per_rel" value="<%=WI.getStrValue((String)vRetResult.elementAt(35))%>" class="textbox" size="32" maxlength="24"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','emgn_per_rel','1', document.form_.emgn_per_rel);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
<!--
					<tr>
					  	<td height="25" width="22%">House no./ Street / Barangay </td>
				  	    <td width="22%">City/Municipality</td>
				  	    <td width="22%">Province/State</td>
				  	    <td width="22%">Country</td>
				  	    <td width="12%">Zip Code </td>
					</tr>
					<tr>
					  	<td height="25">
							<input name="emgn_house_no" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(36))%>" size="24" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','emgn_house_no','1', document.form_.emgn_house_no);"></td>
					  	<td>
							<input name="emgn_city" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(37))%>" size="24" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','emgn_city','1', document.form_.emgn_city);"></td>
					  	<td>
							<input name="emgn_provience" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(38))%>" class="textbox" size="16" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','emgn_provience','1', document.form_.emgn_provience);"></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(39));
						%>
					  	<td>
							<select name="emgn_country" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','emgn_country','1', document.form_.emgn_country);">
								<option value="">Select Country</option>
								<%=dbOP.loadCombo("country","country"," from hr_preload_country",strTemp,false)%>
							</select></td>
					  	<td>
							<input name="emgn_zip" type="text"  value="<%=WI.getStrValue((String)vRetResult.elementAt(40))%>" class="textbox" size="12" maxlength="10"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','emgn_zip','1', document.form_.emgn_zip);"></td>
				  	</tr>
-->
					<tr>
					  	<td height="25" width="55%">House no./ Street / Barangay </td>
				  	    <td width="45%">City/Town/Province/Zip</td>
			  	    </tr>
					<tr>
					  	<td height="25">
							<input name="emgn_house_no" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(36))%>" size="72" class="textbox" maxlength="72"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','emgn_house_no','1', document.form_.emgn_house_no);"></td>
					  	<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(37), "", ",", "") + WI.getStrValue((String)vRetResult.elementAt(38), "", " - ", "")+
							WI.getStrValue((String)vRetResult.elementAt(40));
							
						%>
					  	<td><label id="_emgn_addr"><%=strTemp%></label> 
						
						<a href='javascript:UpdatePreloadAddr("<%=strUserIndex%>","3")'>Update</a>
				
						</td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">Telephone Nos./Cellphone Nos. </td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">
							<input name="emgn_tel" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(41))%>" size="24" class="textbox"  maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','emgn_tel','1', document.form_.emgn_tel);"></td>
				  	</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
					<tr>
						<td height="25" colspan="2"><strong>Grades - Mailing Information </strong></td>
					</tr>
					<tr>
						<td height="25" colspan="2">Send To&nbsp;&nbsp;
							<input type="text" name="mail_to" value="<%=WI.getStrValue((String)vRetResult.elementAt(42))%>" class="textbox" size="64" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_MAIL_GRADE','mail_to','1', document.form_.mail_to);"></td>
					</tr>
<!--
					<tr>
					  	<td height="25" width="22%">House no./ Street / Barangay </td>
				  	    <td width="22%">City/Municipality</td>
				  	    <td width="22%">Province/State</td>
				  	    <td width="22%">Country</td>
				  	    <td width="12%">Zip Code </td>
					</tr>
					<tr>
					  	<td height="25">
							<input name="mail_house_no" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(43))%>" size="72" class="textbox" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_MAIL_GRADE','mail_house_no','1', document.form_.mail_house_no);"></td>
					  	<td>
							<input name="mail_city" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(44))%>" size="24" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_MAIL_GRADE','mail_city','1', document.form_.mail_city);"></td>
					  	<td>
							<input name="mail_province" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(45))%>" class="textbox" size="16" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_MAIL_GRADE','mail_province','1', document.form_.mail_province);"></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(46));
						%>
					  	<td>
							<select name="mail_country" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_MAIL_GRADE','mail_country','1', document.form_.mail_country);">
								<option value="">Select Country</option>
								<%=dbOP.loadCombo("country","country"," from hr_preload_country",strTemp,false)%>
							</select></td>
					  	<td>
							<input name="mail_zip" type="text"  value="<%=WI.getStrValue((String)vRetResult.elementAt(47))%>" class="textbox" size="12" maxlength="50"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_MAIL_GRADE','mail_zip','1', document.form_.mail_zip);"></td>
				  	</tr>
-->
					<tr>
					  	<td height="25" width="55%">House no./ Street / Barangay </td>
				  	    <td width="45%">City/Town/Province/Zip</td>
			  	    </tr>
					<tr>
					  	<td height="25">
							<input name="mail_house_no" type="text" value="<%=WI.getStrValue((String)vRetResult.elementAt(43))%>" size="72" class="textbox" maxlength="128"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_MAIL_GRADE','mail_house_no','1', document.form_.mail_house_no);"></td>
					  	<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(44), "", ",", "") + WI.getStrValue((String)vRetResult.elementAt(45), "", " - ", "")+
							WI.getStrValue((String)vRetResult.elementAt(47));
							
						%>
					  	<td><label id="_mail_addr"><%=strTemp%></label> 
						
						<a href='javascript:UpdatePreloadAddr("<%=strUserIndex%>","4")'>Update</a>
				
						</td>
				  	</tr>
				</table>
			</td>
		</tr>
	</table>

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" >&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="stud_index" value="<%=strUserIndex%>">
	<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>