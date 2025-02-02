<%@ page language="java" import="utility.*,osaGuidance.StudentPersonalRecord,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student Personal Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function AjaxUpdateCheckbox(strIndexName, strIndex, strTableName, strFieldName, strIsString, objCOA){
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
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20401&table_name="+strTableName+"&field_name="+strFieldName+"&table_index="+strIndex+"&is_string="+strIsString+"&field_value="+objCOA.value+"&"+strFieldName+"="+value+"&index_name="+strIndexName;
		this.processRequest(strURL);
	}

	function AjaxUpdateOthers(strIndexName, strIndex, strTableName, strFieldName, strIsString, objCOA){		
		//var objCOA=eval('document.form_.'+strFieldName);
		this.InitXmlHttpObject(objCOA, 1);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20401&table_name="+strTableName+"&field_name="+strFieldName+"&table_index="+strIndex+"&is_string="+strIsString+"&field_value="+objCOA.value+"&"+strFieldName+"="+objCOA.value+"&index_name="+strIndexName;
		this.processRequest(strURL);
	}

	var objCOA;
	var objCOAInput;
	function AjaxMapName(strFieldName, strLabelID) {
		objCOA=document.getElementById(strLabelID);
		var strCompleteName = eval("document.form_."+strFieldName+".value");
		eval('objCOAInput=document.form_.'+strFieldName);
		if(strCompleteName.length <= 2) {
			objCOA.innerHTML = "";
			return ;
		}		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
	
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOAInput.value = strID;
		objCOA.innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function ViewStudentInfo(){
		document.form_.view_student_info.value = "1";
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.stud_id.focus();
	}
	
</script>
<body bgcolor="#D2AE72" onLoad="FocusField();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Guidance & Counseling-SPR","student_personal_record.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Guidance & Counseling","SPR",request.getRemoteAddr(),
															"student_personal_record.jsp");
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
	//end of security
	
	String strUserIndex = null;
	Vector vTemp = null;
	Vector vRetResult = null;
	StudentPersonalRecord spr = new StudentPersonalRecord();
	if(WI.fillTextValue("view_student_info").length() > 0){
		vRetResult = spr.getSPRInformation(dbOP, request);
		if(vRetResult == null)
			strErrMsg = spr.getErrMsg();
		else
			strUserIndex = (String)vRetResult.elementAt(0);
	}
%>
<form name="form_" method="post" action="./student_personal_record.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: STUDENT PERSONAL RECORD ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Student ID: </td>
			<td width="22%">
				<input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('stud_id','stud_id_');"></td>
			<td width="58%" valign="top"><label id="stud_id_" style="position:absolute; width: 400px"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">
				<a href="javascript:ViewStudentInfo();"><img src="../../../images/form_proceed.gif" border="0"></a>
					<font size="1">Click to view student personal record.</font>
			</td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td width="49%" valign="top" class="thinborder">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="2"><strong>I. PERSONAL/SOCIAL</strong></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20" width="4%">&nbsp;</td>
						<td width="96%">&#9642; Student ID Number: <%=(String)vRetResult.elementAt(1)%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<%
							strTemp = (String)vRetResult.elementAt(2);
							strErrMsg = (String)vRetResult.elementAt(3);
							
							if(strTemp != null && strErrMsg != null)
								strTemp += "-"+strErrMsg;
							else
								strTemp = WI.getStrValue(strTemp) + WI.getStrValue(strErrMsg);
						%>
						<td>&#9642; Course/Year Level: <%=strTemp%></td>
				  	</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&#9642; Surname: <%=(String)vRetResult.elementAt(8)%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&#9642; First Name: <%=(String)vRetResult.elementAt(6)%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&#9642; Middle Name: <%=(String)vRetResult.elementAt(7)%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&#9642; Date of Birth: <%=WI.getStrValue(WI.formatDate((String)vRetResult.elementAt(9), 6))%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&#9642; Age: 
							<script language="javascript"> 
								var	strDateToday = "<%=WI.getTodaysDate(1)%>";
								var strDOB = "<%=WI.getStrValue((String)vRetResult.elementAt(9), "")%>";
								if (strDOB.length > 0) 
									document.write(calculateAge(strDOB,strDateToday,true));
							</script> 
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Sex:
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(10), "");
								if(strTemp.equals("M"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="gender" value="M" <%=strErrMsg%>>Male
							<%
								if(strTemp.equals("F"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="gender" value="F" <%=strErrMsg%>>Female</td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&#9642; Citizenship: </td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(12));
							if(strTemp.toLowerCase().equals("filipino"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td>&nbsp;&nbsp;
							<input type="radio" name="nationality" <%=strErrMsg%>>Filipino
							<%
								if(!strTemp.toLowerCase().equals("filipino"))
									strErrMsg = "checked";
								else{
									strErrMsg = "";
									strTemp = "";
								}
							%>
							<input type="radio" name="nationality" <%=strErrMsg%>>Foreign (specify) <%=strTemp%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&#9642; Civil Status </td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(13));
								if(strTemp.indexOf("Single") != -1)
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="civil_status" <%=strErrMsg%>>Single
							<%
								if(strTemp.indexOf("Married") != -1)
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="civil_status" <%=strErrMsg%>>Married</td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Name of Spouse: 
							<%if(strErrMsg.equals("checked")){%><%=WI.getStrValue((String)vRetResult.elementAt(14))%><%}%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							No. of Children: <%if(strErrMsg.equals("checked")){%><%=(String)vRetResult.elementAt(15)%><%}%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<%
								if(strTemp.indexOf("Separated") != -1)
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="civil_status" <%=strErrMsg%>>Separated</td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&nbsp;</td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&#9642; Religion </td>
					</tr>					
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(16));
							if(strTemp.toLowerCase().indexOf("catholic") != -1 && strTemp.toLowerCase().indexOf("non") == -1)
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td>&nbsp;&nbsp;
							<input type="radio" name="religion" <%=strErrMsg%>>Catholic
							<%
								if(strTemp.toLowerCase().indexOf("catholic") != -1 && strTemp.toLowerCase().indexOf("non") == -1){
									strErrMsg = "";
									strTemp = "";
								}
								else
									strErrMsg = "checked";
							%>
							<input type="radio" name="religion" <%=strErrMsg%>>Non-Catholic (specify) <%=strTemp%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;</td>
						<td>&#9642; Complete Address </td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="40">&nbsp;</td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(17));
							strErrMsg = WI.getStrValue((String)vRetResult.elementAt(18));							
							if(strTemp.length() > 0 && strErrMsg.length() > 0)
								strTemp += ", "+strErrMsg;
							else
								strTemp += strErrMsg;
								
							strErrMsg = WI.getStrValue((String)vRetResult.elementAt(19));							
							if(strTemp.length() > 0 && strErrMsg.length() > 0)
								strTemp += ", "+strErrMsg;
							else
								strTemp += strErrMsg;
								
							strErrMsg = WI.getStrValue((String)vRetResult.elementAt(20));							
							if(strTemp.length() > 0 && strErrMsg.length() > 0)
								strTemp += ", "+strErrMsg;
							else
								strTemp += strErrMsg;
							
							//add zip code here						
							strTemp += " "+WI.getStrValue((String)vRetResult.elementAt(21));
						%>
						<td><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&#9642; Contact Numbers </td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;Mobile:&nbsp;
							<input name="contact_mob_no" type="text" size="16" value="<%=WI.getStrValue((String)vRetResult.elementAt(23))%>" class="textbox" maxlength="16"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PERSONAL','contact_mob_no','1', document.form_.contact_mob_no);"></td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;Landline:&nbsp;
							<input name="res_tel" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(22))%>" class="textbox" maxlength="32"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_CONTACT','res_tel','1', document.form_.res_tel);"></td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&#9642; E-mail Address:&nbsp;
							<input name="email" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(11))%>" class="textbox" maxlength="64"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PERSONAL','email','1', document.form_.email);"></td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&#9642; Where do you live or stay during the school year?</td>
					</tr>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(29));
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;<input type="radio" name="residence" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','residence','0', document.form_.residence[0]);">Residence/Home</td>
					</tr>
					<%
						if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;<input type="radio" name="residence" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','residence','0', document.form_.residence[1]);">Boarding House/Dorm/Apartment </td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;(indicate address)
							<input name="apartment_loc" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(30))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','apartment_loc','1', document.form_.apartment_loc);"></td>
					</tr>
					<%
						if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;<input type="radio" name="residence" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','residence','0', document.form_.residence[2]);">Relatives’ House</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;(indicate address)
							<input name="relative_loc" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(31))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','relative_loc','1', document.form_.relative_loc);"></td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&#9642; Organizational Affiliations</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>
							<input name="org_aff" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(32))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','org_aff','1', document.form_.org_aff);"></td>
					</tr>
					<tr>
						<td height="20" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&#9642; Scholarship Grants: </td>
					</tr>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(33));
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;<input type="checkbox" name="grant_bya" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_bya','0', document.form_.grant_bya);">Barbara Yap Angeles (BYA)</td>
					</tr>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(34));
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;<input type="checkbox" name="grant_apa" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_apa','0', document.form_.grant_apa);">Agustin P. Angeles (APA)</td>
					</tr>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(35));
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;<input type="checkbox" name="grant_athletes" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_athletes','0', document.form_.grant_athletes);">Athletes
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(36));
								if(strTemp.equals("1"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%><input type="checkbox" name="grant_cdc" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_cdc','0', document.form_.grant_cdc);">CDC Scholar</td>
					</tr>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(37));
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;<input type="checkbox" name="grant_service" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_service','0', document.form_.grant_service);">Service Grant (Student Aide) </td>
					</tr>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(38));
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;<input type="checkbox" name="grant_perf" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_perf','0', document.form_.grant_perf);">Performing Arts (Concert Chorus, Dance Troupe, Band, Rondalla, PEP Squad) </td>
					</tr>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(39));
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;<input type="checkbox" name="grant_snpl" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_snpl','0', document.form_.grant_snpl);">Study-Now-Pay-Later</td>
					</tr>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(40));
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;<input type="checkbox" name="grant_pnp" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_pnp','0', document.form_.grant_pnp);">PNP Scholarship 
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(41));
								if(strTemp.equals("1"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%><input type="checkbox" name="grant_afp" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_afp','0', document.form_.grant_afp);">AFP Scholarship </td>
					</tr>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(42));
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;<input type="checkbox" name="grant_brgy" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_brgy','0', document.form_.grant_brgy);">Barangay Scholarship
							&nbsp;&nbsp;&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(43));
								if(strTemp.equals("1"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%><input type="checkbox" name="grant_gma" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_gma','0', document.form_.grant_gma);">GMA Scholarship</td>
					</tr>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(44));
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;<input type="checkbox" name="grant_others" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_others','0', document.form_.grant_others);">Others
							<input name="grant_info" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(45))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','grant_info','1', document.form_.grant_info);"></td>
					</tr>
				</table>			</td>
			<td width="2%" align="center" class="thinborder">&nbsp;</td>
			<td width="49%" valign="top" class="thinborder">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25"><strong>II. ACADEMIC </strong></td>
					</tr>
					<tr>
					  	<td height="20"><strong><u>ELEMENTARY</u></strong></td>
				  	</tr>
					<%
						vTemp = (Vector)vRetResult.elementAt(24);
					%>
					<tr bgcolor="#FFCCCC">
					  	<td height="20">Name of School: <%=WI.getStrValue((String)vTemp.elementAt(0))%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
					  	<td height="20">School Address: <%=WI.getStrValue((String)vTemp.elementAt(1))%></td>
					</tr>
					<tr>
						<td height="20">Year Graduated:&nbsp;
							<input name="year_grad" type="text" size="4" maxlength="4" class="textbox"
								onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue((String)vTemp.elementAt(2))%>"
								onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','year_grad');javascript:AjaxUpdateOthers('info_index', '<%=(String)vTemp.elementAt(4)%>','INFO_EDU_QUALIF','year_grad','0', document.form_.year_grad);"></td>
					</tr>
					<tr>
						<td height="20">Awards/Honors received:&nbsp;
							<input name="honor_award" type="text" size="32" value="<%=WI.getStrValue((String)vTemp.elementAt(3))%>" class="textbox" maxlength="64"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('info_index', '<%=(String)vTemp.elementAt(4)%>','INFO_EDU_QUALIF','honor_award','1', document.form_.honor_award);"></td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
				  	</tr>
					<%
						vTemp = (Vector)vRetResult.elementAt(25);
					%>
					<tr>
					  	<td height="20"><strong><u>HIGH SCHOOL </u></strong></td>
				  	</tr>
					<tr bgcolor="#FFCCCC">
					  	<td height="20">Name of School: <%=WI.getStrValue((String)vTemp.elementAt(0))%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
					  	<td height="20">School Address: <%=WI.getStrValue((String)vTemp.elementAt(1))%></td>
					</tr>
					<tr>
						<td height="20">Year Graduated:&nbsp;
							<input name="year_grad_" type="text" size="4" maxlength="4" class="textbox"
								onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue((String)vTemp.elementAt(2))%>"
								onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','year_grad_');javascript:AjaxUpdateOthers('info_index', '<%=(String)vTemp.elementAt(4)%>','INFO_EDU_QUALIF','year_grad','0', document.form_.year_grad_);"></td>
					</tr>
					<tr>
						<td height="20">Awards/Honors received:&nbsp;
							<input name="honor_award_" type="text" size="32" value="<%=WI.getStrValue((String)vTemp.elementAt(3))%>" class="textbox" maxlength="64"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('info_index', '<%=(String)vTemp.elementAt(4)%>','INFO_EDU_QUALIF','honor_award','1', document.form_.honor_award_);"></td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					</tr>
					<tr>
					  	<td height="20">&#9642; Describe the type of high school you attended</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(46));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="hs_type" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','hs_type','0', document.form_.hs_type[0]);">Public</td>
					</tr>
					<tr>
						<%
							if(strTemp.equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="hs_type" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','hs_type','0', document.form_.hs_type[1]);">Private Sectarian</td>
					</tr>
					<tr>
						<%
							if(strTemp.equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="hs_type" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','hs_type','0', document.form_.hs_type[2]);">Private Non-Sectarian</td>
					</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					</tr>
					<tr bgcolor="#FFCCCC">
					  	<td height="20">&#9642; Current Academic Status</td>
					</tr>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(4));
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr bgcolor="#FFCCCC">
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="status_index" value="1" <%=strErrMsg%>>Regular</td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<%
							if(strTemp.equals("0"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="status_index" value="0" <%=strErrMsg%>>Irregular (specify reasons)
						<%if(strTemp.equals("0")){%>
							<input name="current_stat_reason" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(47))%>" class="textbox"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','current_stat_reason','1', document.form_.current_stat_reason);"><%}%></td>
					</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					</tr>
					<tr bgcolor="#FFCCCC">
					  	<td height="20">&#9642; Entry Status At AUF</td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(5));
							if(strTemp.equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="entry_status" value="2" <%=strErrMsg%>>Freshman</td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<%
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="entry_status" value="1" <%=strErrMsg%>>Old Student – Returnee</td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<%
							if(strTemp.equals("1"))
								strErrMsg = (String)vRetResult.elementAt(107);
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Last Semester/School Year Attended: <%=strErrMsg%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Reason for deciding to temporarily leave AUF: <%if(!strTemp.equals("1")){%><%=WI.getStrValue((String)vRetResult.elementAt(51))%><%}%></td>
					</tr>
				<%if(strTemp.equals("1")){%>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input name="old_status_reason" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(51))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','old_status_reason','1', document.form_.old_status_reason);"></td>
					</tr>
				<%}%>
					<tr bgcolor="#FFCCCC">
						<%
							if(strTemp.equals("8"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="entry_status" value="8" <%=strErrMsg%>>Second Course</td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<%
							if(strTemp.equals("8"))
								strErrMsg = WI.getStrValue((String)vRetResult.elementAt(26)) + " " + WI.getStrValue((String)vRetResult.elementAt(27));
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Degree Earned: <%=strErrMsg%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<%
							if(strTemp.equals("8"))
								strErrMsg = WI.getStrValue((String)vRetResult.elementAt(28));
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Name of School: <%=strErrMsg%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Year Graduated: <%=WI.getStrValue((String)vRetResult.elementAt(48))%></td>
					</tr>
					<%
						if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="entry_status" value="4" <%=strErrMsg%>>Transferee from another School</td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<%
							if(strTemp.equals("4"))
								strErrMsg = WI.getStrValue((String)vRetResult.elementAt(28));
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Name of School: <%=strErrMsg%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<%
							if(strTemp.equals("4"))
								strErrMsg = WI.getStrValue((String)vRetResult.elementAt(26)) + " " + WI.getStrValue((String)vRetResult.elementAt(27));
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Course: <%=strErrMsg%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Reason/s for Transferring: <%if(!strTemp.equals("4")){%><%=WI.getStrValue((String)vRetResult.elementAt(49))%><%}%></td>
					</tr>
				<%if(strTemp.equals("4")){%>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input name="trans_status_reason" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(49))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','trans_status_reason','1', document.form_.trans_status_reason);"></td>
					</tr>
				<%}%>
					<tr bgcolor="#FFCCCC">
						<%
							if(strTemp.equals("5"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="entry_status" value="5" <%=strErrMsg%>>Shifter</td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<%
							if(strTemp.equals("5"))
								strErrMsg = WI.getStrValue((String)vRetResult.elementAt(26)) + " " + WI.getStrValue((String)vRetResult.elementAt(27));
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Previous Course: <%=strErrMsg%></td>
					</tr>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Reason/s for Shifting: <%if(!strTemp.equals("5")){%><%=WI.getStrValue((String)vRetResult.elementAt(50))%><%}%></td>
					</tr>
				<%if(strTemp.equals("5")){%>
					<tr bgcolor="#FFCCCC">
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input name="shifter_status_reason" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(50))%>" class="textbox"
								maxlength="128"	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','shifter_status_reason','1', document.form_.shifter_status_reason);"></td>
					</tr>
				<%}%>
					<tr>
						<td height="20">&nbsp;</td>
					</tr>
					<tr> 
					  	<td height="20">&#9642; Prior to entering college, which of the following contributed in gaining more knowledge about AUF? (you may check more than one)</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(52));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="influence_career" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','influence_career','0', document.form_.influence_career);">Career Talk</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(53));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="influence_campus" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','influence_campus','0', document.form_.influence_campus);">Campus Open</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(54));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="influence_comp" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','influence_comp','0', document.form_.influence_comp);">Academic/Co-curricular competitions</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(55));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="influence_concert" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','influence_concert','0', document.form_.influence_concert);">Concert/Theater Play</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(56));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="influence_others" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','influence_others','0', document.form_.influence_others);">Others (kindly specify)&nbsp;
							<input name="influence_reason" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(57))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','influence_reason','1', document.form_.influence_reason);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="15" colspan="3" class="thinborderBOTTOM">&nbsp;</td>
		</tr>
		<tr>
			<td class="thinborder">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="2"><strong>ACADEMIC (continued)</strong></td>
					</tr>
					<tr>
						<td height="20" width="4%">&nbsp;</td>
						<td width="96%">&#9642; Who chose AUF for your college education?</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>(you may check more than one)</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(58));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<input type="checkbox" name="choice_self" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','choice_self','0', document.form_.choice_self);">myself</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(59));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<input type="checkbox" name="choice_parent" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','choice_parent','0', document.form_.choice_parent);">my parents</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(60));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<input type="checkbox" name="choice_relative" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','choice_relative','0', document.form_.choice_relative);">relatives</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(61));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<input type="checkbox" name="choice_friends" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','choice_friends','0', document.form_.choice_friends);">friends</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(62));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<input type="checkbox" name="choice_others" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','choice_others','0', document.form_.choice_others);">others (kindly specify)&nbsp;
							<input name="choice_reason" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(63))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','choice_reason','1', document.form_.choice_reason);"></td>
					</tr>
					<tr>
						<td height="20" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&#9642; Referring to your answer above, what was the</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>primary reason for choosing AUF? (check only one)</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(64));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<input type="radio" name="primary_reason" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','primary_reason','0', document.form_.primary_reason[0]);">quality education	</td>
					</tr>
					<tr>
						<%
							if(strTemp.equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<input type="radio" name="primary_reason" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','primary_reason','0', document.form_.primary_reason[1]);">good facilities</td>
					</tr>
					<tr>
						<%
							if(strTemp.equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<input type="radio" name="primary_reason" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','primary_reason','0', document.form_.primary_reason[2]);">safe environment</td>
					</tr>
					<tr>
						<%
							if(strTemp.equals("4"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<input type="radio" name="primary_reason" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','primary_reason','0', document.form_.primary_reason[3]);">proximity to residence</td>
					</tr>
					<tr>
						<%
							if(strTemp.equals("5"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<input type="radio" name="primary_reason" value="5" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','primary_reason','0', document.form_.primary_reason[4]);">scholarship </td>
					</tr>
					<tr>
						<%
							if(strTemp.equals("6"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;
							<input type="radio" name="primary_reason" value="6" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','primary_reason','0', document.form_.primary_reason[5]);">others (kindly specify)&nbsp;
							<input name="primary_reason_text" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(65))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','primary_reason_text','1', document.form_.primary_reason_text);"></td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&#9642; What are your reasons for choosing your course?</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>(Choose 3 and rank your choices being 1 as the highest and 3 as the lowest)</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(66));
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;&nbsp;
							<select name="course_choice_1" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','course_choice_1','0', document.form_.course_choice_1);">
							<%if(strTemp.equals("0")){%>
								<option value="0" selected></option>
							<%}else{%>
								<option value="0"></option>
								
							<%}if(strTemp.equals("1")){%>
								<option value="1" selected>1</option>
							<%}else{%>
								<option value="1">1</option>
								
							<%}if(strTemp.equals("2")){%>
								<option value="2" selected>2</option>
							<%}else{%>
								<option value="2">2</option>
								
							<%}if(strTemp.equals("3")){%>
								<option value="3" selected>3</option>
							<%}else{%>
								<option value="3">3</option>
							<%}%>
							</select>
							The course suits my abilities and interest</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(67));
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;&nbsp;
							<select name="course_choice_2" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','course_choice_2','0', document.form_.course_choice_2);">
							<%if(strTemp.equals("0")){%>
								<option value="0" selected></option>
							<%}else{%>
								<option value="0"></option>
								
							<%}if(strTemp.equals("1")){%>
								<option value="1" selected>1</option>
							<%}else{%>
								<option value="1">1</option>
								
							<%}if(strTemp.equals("2")){%>
								<option value="2" selected>2</option>
							<%}else{%>
								<option value="2">2</option>
								
							<%}if(strTemp.equals("3")){%>
								<option value="3" selected>3</option>
							<%}else{%>
								<option value="3">3</option>
							<%}%>
							</select>
							The employment opportunities are high here and/ or abroad</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(68));
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;&nbsp;
							<select name="course_choice_3" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','course_choice_3','0', document.form_.course_choice_3);">
							<%if(strTemp.equals("0")){%>
								<option value="0" selected></option>
							<%}else{%>
								<option value="0"></option>
								
							<%}if(strTemp.equals("1")){%>
								<option value="1" selected>1</option>
							<%}else{%>
								<option value="1">1</option>
								
							<%}if(strTemp.equals("2")){%>
								<option value="2" selected>2</option>
							<%}else{%>
								<option value="2">2</option>
								
							<%}if(strTemp.equals("3")){%>
								<option value="3" selected>3</option>
							<%}else{%>
								<option value="3">3</option>
							<%}%>
							</select>
							Parents’ decision</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(69));
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;&nbsp;
							<select name="course_choice_4" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','course_choice_4','0', document.form_.course_choice_4);">
							<%if(strTemp.equals("0")){%>
								<option value="0" selected></option>
							<%}else{%>
								<option value="0"></option>
								
							<%}if(strTemp.equals("1")){%>
								<option value="1" selected>1</option>
							<%}else{%>
								<option value="1">1</option>
								
							<%}if(strTemp.equals("2")){%>
								<option value="2" selected>2</option>
							<%}else{%>
								<option value="2">2</option>
								
							<%}if(strTemp.equals("3")){%>
								<option value="3" selected>3</option>
							<%}else{%>
								<option value="3">3</option>
							<%}%>
							</select>
							Suggestion from relatives</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(70));
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;&nbsp;
							<select name="course_choice_5" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','course_choice_5','0', document.form_.course_choice_5);">
							<%if(strTemp.equals("0")){%>
								<option value="0" selected></option>
							<%}else{%>
								<option value="0"></option>
								
							<%}if(strTemp.equals("1")){%>
								<option value="1" selected>1</option>
							<%}else{%>
								<option value="1">1</option>
								
							<%}if(strTemp.equals("2")){%>
								<option value="2" selected>2</option>
							<%}else{%>
								<option value="2">2</option>
								
							<%}if(strTemp.equals("3")){%>
								<option value="3" selected>3</option>
							<%}else{%>
								<option value="3">3</option>
							<%}%>
							</select>
							Suggestion from my counselor/teacher</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(71));
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;&nbsp;
							<select name="course_choice_6" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','course_choice_6','0', document.form_.course_choice_6);">
							<%if(strTemp.equals("0")){%>
								<option value="0" selected></option>
							<%}else{%>
								<option value="0"></option>
								
							<%}if(strTemp.equals("1")){%>
								<option value="1" selected>1</option>
							<%}else{%>
								<option value="1">1</option>
								
							<%}if(strTemp.equals("2")){%>
								<option value="2" selected>2</option>
							<%}else{%>
								<option value="2">2</option>
								
							<%}if(strTemp.equals("3")){%>
								<option value="3" selected>3</option>
							<%}else{%>
								<option value="3">3</option>
							<%}%>
							</select>
							Peer Influence</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(72));
						%>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;&nbsp;
							<select name="course_choice_7" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','course_choice_7','0', document.form_.course_choice_7);">
							<%if(strTemp.equals("0")){%>
								<option value="0" selected></option>
							<%}else{%>
								<option value="0"></option>
								
							<%}if(strTemp.equals("1")){%>
								<option value="1" selected>1</option>
							<%}else{%>
								<option value="1">1</option>
								
							<%}if(strTemp.equals("2")){%>
								<option value="2" selected>2</option>
							<%}else{%>
								<option value="2">2</option>
								
							<%}if(strTemp.equals("3")){%>
								<option value="3" selected>3</option>
							<%}else{%>
								<option value="3">3</option>
							<%}%>
							</select>
							Others (specify)&nbsp;
							<input name="course_choice_reason" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(73))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','course_choice_reason','1', document.form_.course_choice_reason);"></td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td>&nbsp;&nbsp;</td>
					</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td><strong>III. FAMILY </strong></td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>Father’s Name:&nbsp;
							<input name="f_name" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(103))%>" class="textbox" maxlength="64"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_name','1', document.form_.f_name);"></td>
				  	</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(74));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td><input type="checkbox" name="f_deceased" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_deceased','0', document.form_.f_deceased);">Check if father is deceased</td>
					</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>Mother’s Name:&nbsp;
							<input name="m_name" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(104))%>" class="textbox" maxlength="64"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_name','1', document.form_.m_name);"></td>
				  	</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(75));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;</td>
						<td><input type="checkbox" name="m_deceased" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_deceased','0', document.form_.m_deceased);">Check if mother is deceased</td>
					</tr>
					<tr>
					  	<td height="20" colspan="2">&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. What is your father’s educational attainment?</td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. What is your mother’s educational attainment?</td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>&nbsp;1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2</td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(76));
								if(strTemp.equals("1"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_education" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_education','0', document.form_.f_education[0]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(77));
								if(strTemp.equals("1"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_education" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_education','0', document.form_.m_education[0]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Post-Graduate </td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(76));
								if(strTemp.equals("2"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_education" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_education','0', document.form_.f_education[1]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(77));
								if(strTemp.equals("2"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_education" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_education','0', document.form_.m_education[1]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							College Graduate </td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(76));
								if(strTemp.equals("3"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_education" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_education','0', document.form_.f_education[2]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(77));
								if(strTemp.equals("3"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_education" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_education','0', document.form_.m_education[2]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							College Undergraduate </td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(76));
								if(strTemp.equals("4"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_education" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_education','0', document.form_.f_education[3]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(77));
								if(strTemp.equals("4"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_education" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_education','0', document.form_.m_education[3]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Vocational/Technical Graduate </td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(76));
								if(strTemp.equals("5"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_education" value="5" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_education','0', document.form_.f_education[4]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(77));
								if(strTemp.equals("5"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_education" value="5" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_education','0', document.form_.m_education[4]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							High School Graduate </td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(76));
								if(strTemp.equals("6"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_education" value="6" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_education','0', document.form_.f_education[5]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(77));
								if(strTemp.equals("6"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_education" value="6" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_education','0', document.form_.m_education[5]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							High School Undergraduate </td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(76));
								if(strTemp.equals("7"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_education" value="7" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_education','0', document.form_.f_education[6]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(77));
								if(strTemp.equals("7"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_education" value="7" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_education','0', document.form_.m_education[6]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Elementary Graduate </td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(76));
								if(strTemp.equals("8"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_education" value="8" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_education','0', document.form_.f_education[7]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(77));
								if(strTemp.equals("8"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_education" value="8" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_education','0', document.form_.m_education[7]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Elementary Undergraduate </td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(76));
								if(strTemp.equals("9"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_education" value="9" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_education','0', document.form_.f_education[8]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(77));
								if(strTemp.equals("9"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_education" value="9" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_education','0', document.form_.m_education[8]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							No schooling </td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. What is your father’s occupation?</td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4. What is your mother’s occupation?</td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>&nbsp;3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4</td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(78));
								if(strTemp.equals("1"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_occupation" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_occupation','0', document.form_.f_occupation[0]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(79));
								if(strTemp.equals("1"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_occupation" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_occupation','0', document.form_.m_occupation[0]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Professional</td>
					</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(78));
								if(strTemp.equals("2"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_occupation" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_occupation','0', document.form_.f_occupation[1]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(79));
								if(strTemp.equals("2"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_occupation" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_occupation','0', document.form_.m_occupation[1]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Skilled/Manual Job  (Technician/Laborer) </td>
					</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(78));
								if(strTemp.equals("3"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_occupation" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_occupation','0', document.form_.f_occupation[2]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(79));
								if(strTemp.equals("3"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_occupation" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_occupation','0', document.form_.m_occupation[2]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Self-Employed</td>
					</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(78));
								if(strTemp.equals("4"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_occupation" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_occupation','0', document.form_.f_occupation[3]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(79));
								if(strTemp.equals("4"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_occupation" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_occupation','0', document.form_.m_occupation[3]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Overseas Filipino Worker (OFW)</td>
					</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(78));
								if(strTemp.equals("5"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_occupation" value="5" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_occupation','0', document.form_.f_occupation[4]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(79));
								if(strTemp.equals("5"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_occupation" value="5" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_occupation','0', document.form_.m_occupation[4]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Retired</td>
					</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(78));
								if(strTemp.equals("6"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_occupation" value="6" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_occupation','0', document.form_.f_occupation[5]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(79));
								if(strTemp.equals("6"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_occupation" value="6" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_occupation','0', document.form_.m_occupation[5]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Unemployed</td>
					</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td>
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(78));
								if(strTemp.equals("7"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_occupation" value="7" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_occupation','0', document.form_.f_occupation[6]);">&nbsp;
							<%
								strTemp = WI.getStrValue((String)vRetResult.elementAt(79));
								if(strTemp.equals("7"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_occupation" value="7" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_occupation','0', document.form_.m_occupation[6]);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Others (specify) &nbsp;
							<input name="occupation_text" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(80))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','occupation_text','1', document.form_.occupation_text);"></td>
					</tr>
					<tr>
						<td height="25" colspan="2">&nbsp;</td>
					</tr>
				</table>
			</td>
		    <td class="thinborder">&nbsp;</td>
		    <td valign="top" class="thinborder">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25">&#9642; Place of Work:</td>
					</tr>
					<tr>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Father:&nbsp;<!--F_COMP_ADDR-->
							<input name="f_comp_addr" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(105))%>" class="textbox"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','f_comp_addr','1', document.form_.f_comp_addr);"></td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(81));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="f_work_local" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_work_local','0', document.form_.f_work_local[0]);">Local
							<%
								if(strTemp.equals("2"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="f_work_local" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','f_work_local','0', document.form_.f_work_local[1]);">Abroad</td>
					</tr>
					<tr>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Mother:&nbsp;
							<input name="m_comp_addr" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(106))%>" class="textbox"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_PARENT','m_comp_addr','1', document.form_.m_comp_addr);"></td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(82));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="m_work_local" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_work_local','0', document.form_.m_work_local[0]);">Local
							<%
								if(strTemp.equals("2"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="m_work_local" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','m_work_local','0', document.form_.m_work_local[1]);">Abroad</td>
					</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="20">&#9642; Parents’ Marital Status</td>
			  	  	</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(83));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="marital_status" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','marital_status','0', document.form_.marital_status[0]);">Living together</td>
				  	</tr>
					<tr>
						<%
							if(strTemp.equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="marital_status" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','marital_status','0', document.form_.marital_status[1]);">Single Parent (never married)</td>
				  	</tr>
					<tr>
						<%
							if(strTemp.equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="marital_status" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','marital_status','0', document.form_.marital_status[2]);">Separated</td>
				  	</tr>
					<tr>
						<td height="20">&nbsp;</td>
				  	</tr>
					<tr>
						<td height="20"><u><i>For student with single/separated parents, with whom do you stay?</i></u></td>
				  	</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(84));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="single_stay_status" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','single_stay_status','0', document.form_.single_stay_status[0]);">Father
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%
								if(strTemp.equals("2"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="single_stay_status" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','single_stay_status','0', document.form_.single_stay_status[1]);">Mother</td>
				  	</tr>
					<tr>
						<%
							if(strTemp.equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="single_stay_status" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','single_stay_status','0', document.form_.single_stay_status[2]);">Others (specify)&nbsp;
							<input name="single_stay_status_others" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(85))%>" maxlength="128"
								class="textbox"	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','single_stay_status_others','1', document.form_.single_stay_status_others);"></td>
				  	</tr>
					<tr>
						<td height="20">&nbsp;</td>
				  	</tr>
					<tr>
						<td height="20">&#9642; Monthly Income of the Family</td>
				  	</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(86));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="monthly_income" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','monthly_income','0', document.form_.monthly_income[0]);">Less than 10,000
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%
								if(strTemp.equals("7"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="monthly_income" value="7" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','monthly_income','0', document.form_.monthly_income[1]);">60,000 to 79,999</td>
				  	</tr>
					<tr>
						<%
							if(strTemp.equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="monthly_income" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','monthly_income','0', document.form_.monthly_income[2]);">10,000 to 19,999
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%
								if(strTemp.equals("8"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="monthly_income" value="8" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','monthly_income','0', document.form_.monthly_income[3]);">80,000 to 99,999</td>
				  	</tr>
					<tr>
						<%
							if(strTemp.equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="monthly_income" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','monthly_income','0', document.form_.monthly_income[4]);">20,000 to 29,999
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%
								if(strTemp.equals("9"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="monthly_income" value="9" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','monthly_income','0', document.form_.monthly_income[5]);">100,000 to 149,999</td>
				  	</tr>
					<tr>
						<%
							if(strTemp.equals("4"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="monthly_income" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','monthly_income','0', document.form_.monthly_income[6]);">30,000 to 39,999
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%
								if(strTemp.equals("10"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="monthly_income" value="10" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','monthly_income','0', document.form_.monthly_income[7]);">150,000 to 249,999</td>
				  	</tr>
					<tr>
						<%
							if(strTemp.equals("5"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
				  	  <td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="monthly_income" value="5" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','monthly_income','0', document.form_.monthly_income[8]);">40,000 to 49,999
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%
								if(strTemp.equals("11"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="monthly_income" value="11" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','monthly_income','0', document.form_.monthly_income[9]);">250,000 to 499,999</td>
				  	</tr>
					<tr>
						<%
							if(strTemp.equals("6"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="monthly_income" value="6" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','monthly_income','0', document.form_.monthly_income[10]);">50,000 to 59,999
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%
								if(strTemp.equals("12"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="monthly_income" value="12" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','monthly_income','0', document.form_.monthly_income[11]);">500,000 or more</td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="20">&#9642; Who supports your studies?</td>
				  	</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(87));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="study_support" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','study_support','0', document.form_.study_support[0]);">Parents</td>
				  	</tr>
					<tr>
						<%
							if(strTemp.equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="study_support" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','study_support','0', document.form_.study_support[1]);">Siblings (Brother/Sister)</td>
				  	</tr>
					<tr>
						<%
							if(strTemp.equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="study_support" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','study_support','0', document.form_.study_support[2]);">Others (specify relationship)&nbsp;
							<input name="study_support_others" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(88))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','study_support_others','1', document.form_.study_support_others);"></td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;&#9642; Number of children in the family:&nbsp;
							<input name="no_children" type="text" class="textbox" value="<%=WI.getStrValue((String)vRetResult.elementAt(89))%>" size="2" maxlength="2"
								onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','no_children')"
								onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','no_children');javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','no_children','0', document.form_.no_children);"></td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="20">&nbsp;&#9642;  Your birth order: </td>
				  	</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(90));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="birth_order" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','birth_order','0', document.form_.birth_order[0]);">Eldest&nbsp;&nbsp;&nbsp;
							<%
								if(strTemp.equals("2"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="birth_order" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','birth_order','0', document.form_.birth_order[1]);">Middle&nbsp;&nbsp;&nbsp;
							<%
								if(strTemp.equals("3"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="birth_order" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','birth_order','0', document.form_.birth_order[2]);">Youngest&nbsp;&nbsp;&nbsp;
							<%
								if(strTemp.equals("4"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="birth_order" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','birth_order','0', document.form_.birth_order[3]);">Only Child</td>
				  	</tr>
					<tr>
						<td height="20">&nbsp;</td>
					</tr>
					<tr>
						<td height="20"><strong>IV. OTHERS</strong></td>
					</tr>
					<tr>
						<td height="20">Check the items of which you need assistance/ intervention.</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(91));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="checkbox" name="intervention_health" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','intervention_health','0', document.form_.intervention_health);">Health (indicate if you have any existing illness)</td>
					</tr>
					<tr>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input name="intervention_health_dtls" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(99))%>" maxlength="128"
								class="textbox"	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','intervention_health_dtls','1', document.form_.intervention_health_dtls);"></td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(92));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="checkbox" name="intervention_family" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','intervention_family','0', document.form_.intervention_family);">Family</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(93));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="checkbox" name="intervention_pers" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','intervention_pers','0', document.form_.intervention_pers);">Personality</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(94));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="checkbox" name="intervention_acad" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','intervention_acad','0', document.form_.intervention_acad);">Academic</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(95));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="checkbox" name="intervention_career" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','intervention_career','0', document.form_.intervention_career);">Career</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(96));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="checkbox" name="intervention_social" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','intervention_social','0', document.form_.intervention_social);">Social Life</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(97));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="checkbox" name="intervention_spiritual" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','intervention_spiritual','0', document.form_.intervention_spiritual);">Spiritual Life</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(98));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="checkbox" name="intervention_others" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','intervention_others','0', document.form_.intervention_others);">Others (specify)&nbsp;
							<input name="intervention_others_dtls" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(100))%>" class="textbox"
								maxlength="128" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','intervention_others_dtls','1', document.form_.intervention_others_dtls);"></td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
					</tr>
					<tr>
						<td height="20">&nbsp;&#9642; Do you feel the need to talk to your counselor?</td>
					</tr>
					<tr>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(101));
							if(strTemp.equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" name="talk_to_counsellor" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','talk_to_counsellor','0', document.form_.talk_to_counsellor[0]);">Yes
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%
								if(strTemp.equals("2"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							%>
							<input type="radio" name="talk_to_counsellor" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','talk_to_counsellor','0', document.form_.talk_to_counsellor[1]);">No</td>
				  	</tr>
					<tr>
						<td height="30">&nbsp;</td>
					</tr>
					<tr>
						<td height="20">
							<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
								<tr>
									<td width="15%">&nbsp;</td>
									<td width="70%" class="thinborderBOTTOM">&nbsp;</td>
									<td width="15%">&nbsp;</td>
								</tr>
								<tr>
								  	<td>&nbsp;</td>
								  	<td align="center">Signature Over Printed Name</td>
								  	<td>&nbsp;</td>
							  	</tr>
							</table></td>
					</tr>
					<tr>
						<td height="30">&nbsp;</td>
					</tr>
					<tr>
					  <td height="20" align="center">Date Accomplished: 
					  	<input name="date_accomplished" type="text" class="textbox" value="<%=WI.getStrValue((String)vRetResult.elementAt(102))%>" size="10" readonly="yes"
							onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPR_AUF','date_accomplished','2', document.form_.date_accomplished);" >
        				<a href="javascript:show_calendar('form_.date_accomplished');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;" tabindex="-1">
						<img src="../../../images/calendar_new.gif" border="0"></a></td>
				  </tr>
				</table>
			</td>
		</tr>
	</table>
<%}%>
  
	<table bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="view_student_info">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>