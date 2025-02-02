<%@ page language="java" import="utility.*, health.TsuneishiHealth, java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(8);
	boolean bolIsEdit = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Past Medical History</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
a{
	text-decoration: none
}
</style>
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src ="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">

	function CancelOperation(){
		location = "./past_medical_history.jsp?view_fields=1&emp_id="+document.form_.emp_id.value;
	}
	
	function OpenSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2 ) {
			objCOAInput.innerHTML = "";
			return ;
		}
		
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);
		
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		document.form_.emp_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function ReloadPage(){
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function RefreshPage(strViewFields){
		document.form_.view_fields.value = strViewFields;
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.emp_id.focus();
	}
	
	function toggleSel(objQty, objChkBox){
		if(objQty.value.length > 0)
			objChkBox.checked = true;
		else
			objChkBox.checked = false;
	}
	
	function UpdatePE(objChkBox, objTextField){
		objTextField.value = "";
		if(objChkBox.checked)			
			objTextField.disabled = true;
		else
			objTextField.disabled = false;
	}
	
	function DeleteRecord(strInfoIndex){
		if(!confirm("Are you sure you want to delete this record?"))
			return;
		document.form_.prepareToEdit.value="";
		document.form_.info_index.value = strInfoIndex;
		document.form_.page_action.value = "0";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function UpdateRecord(){
		document.form_.prepareToEdit.value = "";
		document.form_.page_action.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function EditRecord(strInfoIndex){		
		document.form_.info_index.value = strInfoIndex;
		document.form_.page_action.value = "2";
		document.form_.is_reloaded.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.view_fields.value = "1";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PrintPg(strInfoIndex){
		document.form_.info_index.value = strInfoIndex;
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./past_medical_history_print.jsp" />
	<% 
		return;}

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","past_medical_history.jsp");
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
															"past_medical_history.jsp");
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

	Vector vEditInfo = null;
	Vector vRetResult = null;
	Vector vBasicInfo = null;
	TsuneishiHealth health = new TsuneishiHealth();
	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strViewFields = WI.getStrValue(WI.fillTextValue("view_fields"),"0");
	
	//get all levels created.
	if(WI.fillTextValue("emp_id").length() > 0) {	
		strTemp = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
		if(strTemp == null)
			strErrMsg = "ID number does not exist or is invalidated.";
	}
	
	//if(WI.fillTextValue("stud_id").length() > 0) {	
	if(strTemp != null){
		vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("emp_id"));
		if(vBasicInfo == null) //may be it is the teacher/staff
		{
			request.setAttribute("emp_id",request.getParameter("emp_id"));
			vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
		}
		
		if(vBasicInfo == null)
			strErrMsg = OAdm.getErrMsg();
	}
	
	if(vBasicInfo != null){
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0){
			if(health.operateOnPastMedicalHistoryEntry(dbOP, request, Integer.parseInt(strTemp)) == null)
				strErrMsg = health.getErrMsg();
			else{
				if(strTemp.equals("0"))
					strErrMsg = "Health Record successfully removed.";
				if(strTemp.equals("1"))
					strErrMsg = "Health Record successfully recorded.";
				if(strTemp.equals("2"))
					strErrMsg = "Health Record successfully edited.";
					
				strPrepareToEdit = "0";
				strViewFields = "0";//after save, edit, and delete, do not show the form.
			}
		}
		
		if(strPrepareToEdit.equals("1")){
			bolIsEdit = true;
			vEditInfo = health.operateOnPastMedicalHistoryEntry(dbOP, request, 3);
			if(vEditInfo == null && strViewFields.equals("1"))
				strErrMsg = health.getErrMsg();
		}
		
		vRetResult = health.operateOnPastMedicalHistoryEntry(dbOP, request, 4);
	}
%>
<body bgcolor="#8C9AAA" class="bgDynamic" onLoad="FocusField();">
<form action="./past_medical_history.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F"> 
			<td height="25" align="center" colspan="4" class="footerDynamic">
				<font color="#FFFFFF"><strong>:::: PAST MEDICAL HISTORY ::::</strong></font></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Employee ID </td>
			<td width="25%">
				<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">
		  		<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
			<td width="55%" valign="top"><label id="coa_info" style="position:absolute; width:300px"></label></td>
		</tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
			<td><a href="javascript:RefreshPage('');"><img src="../../../images/form_proceed.gif" border="0"></a></td>
		    <td><a href="javascript:RefreshPage('1');">Click to create new record.</a></td>
		</tr>
	</table>
<%if(vBasicInfo != null){%>
	<table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15"><hr size="1"></td>
		</tr>
	</table>

	<%if(strViewFields.equals("1")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Effective Date: </td>
		    <td colspan="4">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("date_fr");
				%>
        			<input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        			<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
						onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
					<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font>
				-
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("date_to");
				%>
        			<input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        			<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
						onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
					<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
	    </tr>
		<tr>
			<td>&nbsp;</td>
			<td>Date Recorded: </td>
			<td><font size="1">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(0);
					else
						strTemp = WI.fillTextValue("date_recorded");
				%>
        		<input name="date_recorded" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.date_recorded');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
      		<td valign="top" >
				<%if(bolIsEdit){%>
				<table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#B0B0FF">
					<tr>
         				<td><font size="1">Record Last Updated :
              				<%if(vEditInfo != null && vEditInfo.size() > 0){%>
            					<%=(String)vEditInfo.elementAt(83)%>
            				<%}%>
            				<br><br>
							</font><font size="1">Updated by :
							<%if(vEditInfo != null && vEditInfo.size() > 0){%>
								<%=(String)vEditInfo.elementAt(82)%>
							<%}%>
							</font></td>
					</tr>
				</table>
				<%}else{%>
					&nbsp;
				<%}%></td>
      		<td valign="top">&nbsp;</td>
		</tr>
		<tr>
			<td height="15" width="3%">&nbsp;</td>
		    <td width="17%">&nbsp;</td>
		    <td width="40%">&nbsp;</td>
		    <td width="38%">&nbsp;</td>
			<td width="2%">&nbsp;</td>
		</tr>
	</table>
	<%}%>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Emp. Name :</td>
			<td width="40%"><strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),4)%></strong></td>
			<td width="17%">Emp. Status :</td>
			<td width="23%"><strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Division:</td>
			<%
				if((String)vBasicInfo.elementAt(13)== null || (String)vBasicInfo.elementAt(14)== null)
					strTemp = " ";			
				else
					strTemp = " - ";
			%>
			<td><strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>
				<%=strTemp%><%=WI.getStrValue(vBasicInfo.elementAt(14))%></strong></td>
			<td>Designation :</td>
			<td><strong><%=(String)vBasicInfo.elementAt(15)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
	
<%if(strViewFields.equals("1")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="5"><strong><u>PHYSICAL EXAMINATION</u></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Height: </td>
			<td width="30%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("height");
				%>
				<input name="height" type="text" size="24" maxlength="24" class="textbox" value="<%=strTemp%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td width="17%">Weight: </td>
			<td width="33%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.fillTextValue("weight");
				%>
				<input name="weight" type="text" size="24" maxlength="24" class="textbox" value="<%=strTemp%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Body Build: </td>
			<td colspan="3">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("body_build");
				%>
				<input name="body_build" type="text" size="24" maxlength="24" class="textbox" value="<%=strTemp%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="4">Visual Acuity: </td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Left: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(6), "&nbsp;");
					else
						strTemp = WI.fillTextValue("left_acuity");
				%>
				<input name="left_acuity" type="text" size="24" maxlength="24" class="textbox" value="<%=strTemp%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>Right: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(7));
					else
						strTemp = WI.fillTextValue("right_acuity");
				%>
				<input name="right_acuity" type="text" size="24" maxlength="24" class="textbox" value="<%=strTemp%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="4">
				<%				
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(8));
					else
						strTemp = WI.fillTextValue("is_corrected");
					
					if(strTemp.equals("1") || strTemp.length() == 0)
						strTemp = "checked";
					else
						strTemp = "";
				%>					
				<input name="is_corrected" type="radio" value="1" <%=strTemp%>>Corrected 
				
				<%				
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(8);
					else
						strTemp = WI.fillTextValue("is_corrected");
					
					if(strTemp.equals("0"))
						strTemp = "checked";
					else
						strTemp = "";
				%>	
				<input name="is_corrected" type="radio" value="0" <%=strTemp%>>Uncorrected</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="4">Vital Signs: </td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Temperature: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(9);
					else
						strTemp = WI.fillTextValue("temperature");
				%>
				<input name="temperature" type="text" size="24" maxlength="24" class="textbox" value="<%=strTemp%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>Blood Pressure: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(10);
					else
						strTemp = WI.fillTextValue("blood_pressure");
				%>
				<input name="blood_pressure" type="text" size="24" maxlength="24" class="textbox" value="<%=strTemp%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Pulse Rate : </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(11);
					else
						strTemp = WI.fillTextValue("pulse_rate");
				%>
				<input name="pulse_rate" type="text" size="24" maxlength="24" class="textbox" value="<%=strTemp%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>Respiratory Rate: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(12);
					else
						strTemp = WI.fillTextValue("resp_rate");
				%>
				<input name="resp_rate" type="text" size="24" maxlength="24" class="textbox" value="<%=strTemp%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="32%">&nbsp;</td>
			<td width="10%" align="center" class="thinborderTOPLEFTRIGHT"><strong>NORMAL</strong></td>
			<td width="55%" align="center" class="thinborderTOPRIGHT"><strong>FINDINGS</strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td>General Appearance </td>
			<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(13);
					else
						strTemp = WI.fillTextValue("pe_isnormal_1");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_1" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_1, document.form_.pe_findings_1);"></td>
			<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(14));
					else
						strErrMsg = WI.fillTextValue("pe_findings_1");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_1" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Skin</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(15);
					else
						strTemp = WI.fillTextValue("pe_isnormal_2");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_2" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_2, document.form_.pe_findings_2);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(16));
					else
						strErrMsg = WI.fillTextValue("pe_findings_2");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_2" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Head and Scalp</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(17);
					else
						strTemp = WI.fillTextValue("pe_isnormal_3");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_3" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_3, document.form_.pe_findings_3);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(18));
					else
						strErrMsg = WI.fillTextValue("pe_findings_3");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_3" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Eyes and Pupils</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(19);
					else
						strTemp = WI.fillTextValue("pe_isnormal_4");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_4" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_4, document.form_.pe_findings_4);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(20));
					else
						strErrMsg = WI.fillTextValue("pe_findings_4");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_4" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Ears and Eardrums</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(21);
					else
						strTemp = WI.fillTextValue("pe_isnormal_5");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_5" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_5, document.form_.pe_findings_5);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(22));
					else
						strErrMsg = WI.fillTextValue("pe_findings_5");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_5" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Nose, Throat and Sinuses</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(23);
					else
						strTemp = WI.fillTextValue("pe_isnormal_6");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_6" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_6, document.form_.pe_findings_6);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(24));
					else
						strErrMsg = WI.fillTextValue("pe_findings_6");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_6" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Mouth and Teeth</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(25);
					else
						strTemp = WI.fillTextValue("pe_isnormal_7");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_7" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_7, document.form_.pe_findings_7);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(26));
					else
						strErrMsg = WI.fillTextValue("pe_findings_7");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_7" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		 	<td>Neck and Thyroid</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(27);
					else
						strTemp = WI.fillTextValue("pe_isnormal_8");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_8" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_8, document.form_.pe_findings_8);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(28));
					else
						strErrMsg = WI.fillTextValue("pe_findings_8");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_8" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Chest, Breast and Axilla</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(29);
					else
						strTemp = WI.fillTextValue("pe_isnormal_9");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_9" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_9, document.form_.pe_findings_9);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(30));
					else
						strErrMsg = WI.fillTextValue("pe_findings_9");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_9" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Heart- Cardiovascular</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(31);
					else
						strTemp = WI.fillTextValue("pe_isnormal_10");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_10" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_10, document.form_.pe_findings_10);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(32));
					else
						strErrMsg = WI.fillTextValue("pe_findings_10");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_10" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Lungs- Respiratory</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(33);
					else
						strTemp = WI.fillTextValue("pe_isnormal_11");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_11" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_11, document.form_.pe_findings_11);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(34));
					else
						strErrMsg = WI.fillTextValue("pe_findings_11");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_11" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Abdomen</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(35);
					else
						strTemp = WI.fillTextValue("pe_isnormal_12");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_12" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_12, document.form_.pe_findings_12);"></td>
		 	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(36));
					else
						strErrMsg = WI.fillTextValue("pe_findings_12");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_12" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Back</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(37);
					else
						strTemp = WI.fillTextValue("pe_isnormal_13");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_13" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_13, document.form_.pe_findings_13);"></td>
		 	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(38));
					else
						strErrMsg = WI.fillTextValue("pe_findings_13");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_13" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Genito- urinary System</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(39);
					else
						strTemp = WI.fillTextValue("pe_isnormal_14");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_14" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_14, document.form_.pe_findings_14);"></td>
		 	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(40));
					else
						strErrMsg = WI.fillTextValue("pe_findings_14");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_14" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Musculoskeletal</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(41);
					else
						strTemp = WI.fillTextValue("pe_isnormal_15");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_15" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_15, document.form_.pe_findings_15);"></td>
		 	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(42));
					else
						strErrMsg = WI.fillTextValue("pe_findings_15");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_15" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Extremities</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(43);
					else
						strTemp = WI.fillTextValue("pe_isnormal_16");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_16" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_16, document.form_.pe_findings_16);"></td>
		 	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(44));
					else
						strErrMsg = WI.fillTextValue("pe_findings_16");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_16" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Reflexes</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(45);
					else
						strTemp = WI.fillTextValue("pe_isnormal_17");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_17" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_17, document.form_.pe_findings_17);"></td>
		 	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(46));
					else
						strErrMsg = WI.fillTextValue("pe_findings_17");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_17" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%> 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Neurologic System</td>
		  	<td align="center" class="thinborderALL">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(47);
					else
						strTemp = WI.fillTextValue("pe_isnormal_18");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="pe_isnormal_18" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.pe_isnormal_18, document.form_.pe_findings_18);"></td>
		  	<td align="center" class="thinborderTOPBOTTOMRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(48));
					else
						strErrMsg = WI.fillTextValue("pe_findings_18");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="pe_findings_18" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
			<td>&nbsp;</td>
			<td>Others: </td>
			<td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(49));
					else
						strErrMsg = WI.fillTextValue("physical_others");
				%>
				<textarea name="physical_others" style="font-size:12px" cols="65" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strErrMsg%></textarea></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="4"><strong><u>RADIOLOGICAL AND LABORATORY EXAMINATIONS</u></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="32%">&nbsp;</td>
			<td width="10%" align="center" class="thinborderTOPLEFTRIGHT"><strong>NORMAL</strong></td>
			<td width="55%" align="center" class="thinborderTOPRIGHT"><strong>FINDINGS</strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td>Complete Blood Count</td>
			<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(50);
					else
						strTemp = WI.fillTextValue("re_isnormal_1");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="re_isnormal_1" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.re_isnormal_1, document.form_.re_findings_1);"></td>
			<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(51));
					else
						strErrMsg = WI.fillTextValue("re_findings_1");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="re_findings_1" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Urinalysis</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(52);
					else
						strTemp = WI.fillTextValue("re_isnormal_2");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="re_isnormal_2" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.re_isnormal_2, document.form_.re_findings_2);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(53));
					else
						strErrMsg = WI.fillTextValue("re_findings_2");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="re_findings_2" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Fecalysis</td>
		  	<td align="center" class="thinborderALL">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(54);
					else
						strTemp = WI.fillTextValue("re_isnormal_3");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="re_isnormal_3" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.re_isnormal_3, document.form_.re_findings_3);"></td>
		  	<td align="center" class="thinborderTOPBOTTOMRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(55));
					else
						strErrMsg = WI.fillTextValue("re_findings_3");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="re_findings_3" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3">Lipid Panel</td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>&nbsp;&nbsp;&nbsp;&nbsp;Cholestrol</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(56);
					else
						strTemp = WI.fillTextValue("re_isnormal_4");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="re_isnormal_4" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.re_isnormal_4, document.form_.re_findings_4);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(57));
					else
						strErrMsg = WI.fillTextValue("re_findings_4");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="re_findings_4" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>&nbsp;&nbsp;&nbsp;&nbsp;HDL</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(58);
					else
						strTemp = WI.fillTextValue("re_isnormal_5");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="re_isnormal_5" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.re_isnormal_5, document.form_.re_findings_5);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(59));
					else
						strErrMsg = WI.fillTextValue("re_findings_5");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="re_findings_5" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>&nbsp;&nbsp;&nbsp;&nbsp;LDL</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(60);
					else
						strTemp = WI.fillTextValue("re_isnormal_6");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="re_isnormal_6" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.re_isnormal_6, document.form_.re_findings_6);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(61));
					else
						strErrMsg = WI.fillTextValue("re_findings_6");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="re_findings_6" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>&nbsp;&nbsp;&nbsp;&nbsp;VLDL</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(62);
					else
						strTemp = WI.fillTextValue("re_isnormal_7");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="re_isnormal_7" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.re_isnormal_7, document.form_.re_findings_7);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(63));
					else
						strErrMsg = WI.fillTextValue("re_findings_7");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="re_findings_7" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		 	<td>Creatine</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(64);
					else
						strTemp = WI.fillTextValue("re_isnormal_8");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="re_isnormal_8" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.re_isnormal_8, document.form_.re_findings_8);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(65));
					else
						strErrMsg = WI.fillTextValue("re_findings_8");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="re_findings_8" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>SGPT</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(66);
					else
						strTemp = WI.fillTextValue("re_isnormal_9");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="re_isnormal_9" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.re_isnormal_9, document.form_.re_findings_9);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(67));
					else
						strErrMsg = WI.fillTextValue("re_findings_9");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="re_findings_9" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Blood Sugar Test</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(68);
					else
						strTemp = WI.fillTextValue("re_isnormal_10");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="re_isnormal_10" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.re_isnormal_10, document.form_.re_findings_10);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(69));
					else
						strErrMsg = WI.fillTextValue("re_findings_10");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="re_findings_10" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Chest Xray</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(70);
					else
						strTemp = WI.fillTextValue("re_isnormal_11");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="re_isnormal_11" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.re_isnormal_11, document.form_.re_findings_11);"></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(71));
					else
						strErrMsg = WI.fillTextValue("re_findings_11");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="re_findings_11" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>ECG</td>
		  	<td align="center" class="thinborderALL">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strTemp = (String)vEditInfo.elementAt(72);
					else
						strTemp = WI.fillTextValue("re_isnormal_12");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
				%>
				<input type="checkbox" name="re_isnormal_12" tabindex="-1" value="1" <%=strTemp%>
					onChange="UpdatePE(document.form_.re_isnormal_12, document.form_.re_findings_12);"></td>
		 	<td align="center" class="thinborderTOPBOTTOMRIGHT">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(73));
					else
						strErrMsg = WI.fillTextValue("re_findings_12");
					
					if(strTemp.equals("checked"))
						strTemp = "disabled";
				%>
				<input name="re_findings_12" type="text" size="53" maxlength="256" value="<%=strErrMsg%>" <%=strTemp%>
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
	</table>
		
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="32%">&nbsp;</td>
			<td width="32%" align="center" class="thinborderTOPLEFTRIGHT"><strong>NEGATIVE</strong></td>
			<td width="33%" align="center" class="thinborderTOPRIGHT"><strong>POSITIVE</strong></td>
		</tr>
		<tr>
  	  	  <td height="25">&nbsp;</td>
		  	<td>Hepatitis B Screening</td>
			<%
			strTemp = WI.getStrValue(WI.fillTextValue("hepatitis_b"),"0");
			if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0){
				strErrMsg = (String)vEditInfo.elementAt(74);
				if(strErrMsg.equals("0")){					
					strTemp = "checked";
					strErrMsg = "";
				}
				else{
					strTemp = "";
					strErrMsg = "checked";
				}
			}
			else{
				if(strTemp.equals("0")){
					strTemp = "checked";
					strErrMsg = "";										
				}else{
					strTemp = "";
					strErrMsg = "checked";
				}
			}
			%>
  	  	  	<td align="center" class="thinborderALL"><input type="radio" name="hepatitis_b" value="0"<%=strTemp%>></td>
		  	<td align="center" class="thinborderTOPBOTTOMRIGHT"><input type="radio" name="hepatitis_b" value="1"<%=strErrMsg%>></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td colspan="3">Drug Test</td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>&nbsp;&nbsp;&nbsp;&nbsp;Methamphetamine</td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("methamphetamine"),"0");
				if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0){
					strErrMsg = (String)vEditInfo.elementAt(75);
					if(strErrMsg.equals("0")){					
						strTemp = "checked";
						strErrMsg = "";
					}
					else{
						strTemp = "";
						strErrMsg = "checked";
					}
				}
				else{
					if(strTemp.equals("0")){
						strTemp = "checked";
						strErrMsg = "";										
					}else{
						strTemp = "";
						strErrMsg = "checked";
					}
				}
			%>
		  	<td align="center" class="thinborderTOPLEFTRIGHT"><input type="radio" name="methamphetamine" value="0"<%=strTemp%>></td>
		  	<td align="center" class="thinborderTOPRIGHT"><input type="radio" name="methamphetamine" value="1"<%=strErrMsg%>></td>
	  	</tr>
		<tr>
		 	<td height="25">&nbsp;</td>
		  	<td>&nbsp;&nbsp;&nbsp;&nbsp;Tetrahydrocannabinol</td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("tetrahydrocannabinol"),"0");
				if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0){
					strErrMsg = (String)vEditInfo.elementAt(76);
					if(strErrMsg.equals("0")){
						strTemp = "checked";
						strErrMsg = "";
					}
					else{
						strTemp = "";
						strErrMsg = "checked";
					}
				}
				else{
					if(strTemp.equals("0")){
						strTemp = "checked";
						strErrMsg = "";										
					}else{
						strTemp = "";
						strErrMsg = "checked";
					}
				}
			%>
		  	<td align="center" class="thinborderALL"><input type="radio" name="tetrahydrocannabinol" value="0"<%=strTemp%>></td>
		  	<td align="center" class="thinborderTOPBOTTOMRIGHT"><input type="radio" name="tetrahydrocannabinol" value="1"<%=strErrMsg%>></td>
	  	</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>Others: </td>
			<td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(77));
					else
						strErrMsg = WI.fillTextValue("lab_others");
				%>
				<textarea name="lab_others" style="font-size:12px" cols="65" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strErrMsg%></textarea></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>Remarks/Recommendations: </td>
			<td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("is_reloaded").length() == 0)
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(78));
					else
						strErrMsg = WI.fillTextValue("remarks");
				%>
				<textarea name="remarks" style="font-size:12px" cols="65" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strErrMsg%></textarea></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="4"><div align="center">
				<%if(iAccessLevel > 1){
					if(bolIsEdit){%>
						<a href="javascript:EditRecord('<%=WI.fillTextValue("info_index")%>');">
							<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">click to edit entries</font>
					<%}else{%>
						<a href="javascript:UpdateRecord();"><img src="../../../images/save.gif" border="0"></a>
							<font size="1">click to save entries</font>
					<%}
				}else{%>
					<font size="1">Not authorized to change information</font>
				<%}%>
				<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a>
					<font size="1">click to cancel/erase entries</font></font></div></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>
	<%}
}//only if vBasicInfo is not null

if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF PAST RECORDS :::</strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Effective Date</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Recorded Date</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Updated Date</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Updated By</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=7,iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%> - <%=(String)vRetResult.elementAt(i+3)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i+5), "<br>(", ")", "&nbsp;")%></td>
		    <td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
					<a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')">
						<img src="../../../images/delete.gif" border="0"></a>
				<%}%>
				<a href="javascript:PrintPg('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/print.gif" border="0"></a>
			<%}else{%>
				No edit/delete privilege.
			<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>
  
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page">
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="view_fields" value="<%=strViewFields%>">
	<input type="hidden" name="is_reloaded">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
