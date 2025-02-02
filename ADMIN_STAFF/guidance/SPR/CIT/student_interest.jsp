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
	
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Registrar Management","STUDENT PERSONAL DATA-PART IV",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0)
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Guidance & Counseling","STUDENT PERSONAL DATA-PART IV",request.getRemoteAddr(), null);														
																
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
		
	function GoBack(){
		location = "./student_personal_data.jsp?get_student_info=1&stud_id="+document.form_.stud_id.value;
	}
	
</script>
<%	
	String strUserIndex = WI.fillTextValue("stud_index");
	if(strUserIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Student reference is not found. Please close this window and click on the Part IV link to try again..</p>
	<%return;}
	
	int iTemp = 0;
	StudentPersonalDataCIT spd = new StudentPersonalDataCIT();
	Vector vRetResult = spd.getPart4Info(dbOP, request, strUserIndex);
	if(vRetResult == null)
		strErrMsg = spd.getErrMsg();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="student_interest.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: PART IV: STUDENT'S INTEREST - ATTITUDE INVENTORIES ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td width="90%" height="25"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right">
				<a href="javascript:GoBack();"><img src="../../../../images/go_back.gif" border="0"></a></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">Rank subjects from 1-8 (1 as most interested and 8 as least interested) </td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<%
							iTemp = Integer.parseInt((String)vRetResult.elementAt(0));
						%>
						<td height="25" width="40%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<select name="interest_math" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','interest_math','0', document.form_.interest_math);">
								<option value="0"></option>
							<%for(int i = 1; i <= 8; i++){
								if(iTemp == i){%>
									<option value="<%=i%>" selected><%=i%></option>
								<%}else{%>
									<option value="<%=i%>"><%=i%></option>
								<%}
							}%>
							</select>&nbsp;
							Mathematics</td>
						<%
							iTemp = Integer.parseInt((String)vRetResult.elementAt(1));
						%>
						<td width="30%">
							<select name="interest_pehm" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','interest_pehm','0', document.form_.interest_pehm);">
								<option value="0"></option>
							<%for(int i = 1; i <= 8; i++){
								if(iTemp == i){%>
									<option value="<%=i%>" selected><%=i%></option>
								<%}else{%>
									<option value="<%=i%>"><%=i%></option>
								<%}
							}%>
							</select>&nbsp;
							PEHM</td>
						<%
							iTemp = Integer.parseInt((String)vRetResult.elementAt(2));
						%>
						<td width="30%">
							<select name="interest_social" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','interest_social','0', document.form_.interest_social);">
								<option value="0"></option>
							<%for(int i = 1; i <= 8; i++){
								if(iTemp == i){%>
									<option value="<%=i%>" selected><%=i%></option>
								<%}else{%>
									<option value="<%=i%>"><%=i%></option>
								<%}
							}%>
							</select>&nbsp;
							Social Studies</td>
					</tr>
					<tr>
						<%
							iTemp = Integer.parseInt((String)vRetResult.elementAt(3));
						%>
					  	<td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<select name="interest_science" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','interest_science','0', document.form_.interest_science);">
								<option value="0"></option>
							<%for(int i = 1; i <= 8; i++){
								if(iTemp == i){%>
									<option value="<%=i%>" selected><%=i%></option>
								<%}else{%>
									<option value="<%=i%>"><%=i%></option>
								<%}
							}%>
							</select>&nbsp;
							Science</td>
						<%
							iTemp = Integer.parseInt((String)vRetResult.elementAt(4));
						%>
					  	<td>
							<select name="interest_english" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','interest_english','0', document.form_.interest_english);">
								<option value="0"></option>
							<%for(int i = 1; i <= 8; i++){
								if(iTemp == i){%>
									<option value="<%=i%>" selected><%=i%></option>
								<%}else{%>
									<option value="<%=i%>"><%=i%></option>
								<%}
							}%>
							</select>&nbsp;
							English</td>
						<%
							iTemp = Integer.parseInt((String)vRetResult.elementAt(5));
						%>
					  	<td>
							<select name="interest_filipino" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','interest_filipino','0', document.form_.interest_filipino);">
								<option value="0"></option>
							<%for(int i = 1; i <= 8; i++){
								if(iTemp == i){%>
									<option value="<%=i%>" selected><%=i%></option>
								<%}else{%>
									<option value="<%=i%>"><%=i%></option>
								<%}
							}%>
							</select>&nbsp;
							Filipino</td>
					</tr>
					<tr>
						<%
							iTemp = Integer.parseInt((String)vRetResult.elementAt(6));
						%>
					  	<td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<select name="interest_the" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','interest_the','0', document.form_.interest_the);">
								<option value="0"></option>
							<%for(int i = 1; i <= 8; i++){
								if(iTemp == i){%>
									<option value="<%=i%>" selected><%=i%></option>
								<%}else{%>
									<option value="<%=i%>"><%=i%></option>
								<%}
							}%>
							</select>&nbsp;
							THE (Computer/Food Tech./Electronics)</td>
						<%
							iTemp = Integer.parseInt((String)vRetResult.elementAt(7));
						%>
					  	<td colspan="2">
							<select name="interest_values" onChange="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','interest_values','0', document.form_.interest_values);">
								<option value="0"></option>
							<%for(int i = 1; i <= 8; i++){
								if(iTemp == i){%>
									<option value="<%=i%>" selected><%=i%></option>
								<%}else{%>
									<option value="<%=i%>"><%=i%></option>
								<%}
							}%>
							</select>&nbsp;
							Values Education</td>
				  	</tr>
				</table></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr>
			<td height="25"><strong>CLUBS AND ORGANIZATIONS</strong></td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" width="5%">&nbsp;</td>
						<td width="15%">In School</td>
						<td width="40%">1.
							<input name="clubs_inschool1" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(8))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','clubs_inschool1','1', document.form_.clubs_inschool1);"></td>
						<td width="40%">2.
							<input name="clubs_inschool2" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(9))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','clubs_inschool2','1', document.form_.clubs_inschool2);"></td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<td>Out of School </td>
						<td>1.
							<input name="clubs_outschool1" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(10))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','clubs_outschool1','1', document.form_.clubs_outschool1);"></td>
						<td>2.
					    	<input name="clubs_outschool2" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(11))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','clubs_outschool2','1', document.form_.clubs_outschool2);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="25"><strong>LEADERSHIP</strong></td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" width="5%">&nbsp;</td>
						<td width="35%">Name responsible positions you hold or have held</td>
						<td width="30%">1.
							<input name="pos_held1" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(12))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','pos_held1','1', document.form_.pos_held1);"></td>
						<td width="30%">2.
							<input name="pos_held2" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(13))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','pos_held2','1', document.form_.pos_held2);"></td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<td>Name of persons you admire or respect </td>
						<td>1.
					    	<input name="person_admire1" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(14))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','person_admire1','1', document.form_.person_admire1);"></td>
						<td>2.
					    	<input name="person_admire2" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(15))%>" class="textbox" maxlength="128"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','person_admire2','1', document.form_.person_admire2);"></td>
					</tr>
				</table>			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="25"><strong>EDUCATIONAL GOALS</strong></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">Do you have a definite study schedule or time for study? (pls. check)
				<%
					if(((String)vRetResult.elementAt(16)).equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				%>
				<input type="radio" name="has_study_sched" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','has_study_sched','0', document.form_.has_study_sched[0]);">YES
				<%
					if(((String)vRetResult.elementAt(16)).equals("2"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				%>
				<input type="radio" name="has_study_sched" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','has_study_sched','0', document.form_.has_study_sched[1]);">NO
				<%
					if(((String)vRetResult.elementAt(16)).equals("3"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				%>
				<input type="radio" name="has_study_sched" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','has_study_sched','0', document.form_.has_study_sched[2]);">MAYBE</td>
		</tr>
		<tr>
			<td height="25">If YES, when? 
				<input name="study_sched_when" type="text" size="64" value="<%=WI.getStrValue((String)vRetResult.elementAt(17))%>" class="textbox" maxlength="128"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','study_sched_when','1', document.form_.study_sched_when);"></td>
		</tr>
		<tr>
			<td height="25">If NO, why? 
				<input name="study_sched_why" type="text" size="64" value="<%=WI.getStrValue((String)vRetResult.elementAt(18))%>" class="textbox" maxlength="128"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','study_sched_why','1', document.form_.study_sched_why);"></td>
		</tr>
		<tr>
		  	<td height="25">Indicate weakest subject 
				<input name="weakest_subject" type="text" size="64" value="<%=WI.getStrValue((String)vRetResult.elementAt(19))%>" class="textbox" maxlength="128"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','weakest_subject','1', document.form_.weakest_subject);"></td>
	  	</tr>
		<tr>
		  	<td height="25">Would you like to get special help for this subject? (pls. check)
				<%
					if(((String)vRetResult.elementAt(20)).equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				%>
				<input type="radio" name="need_special_help" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','need_special_help','0', document.form_.need_special_help[0]);">YES
				<%
					if(((String)vRetResult.elementAt(20)).equals("2"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				%>
				<input type="radio" name="need_special_help" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','need_special_help','0', document.form_.need_special_help[1]);">NO
				<%
					if(((String)vRetResult.elementAt(20)).equals("3"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				%>
				<input type="radio" name="need_special_help" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','need_special_help','0', document.form_.need_special_help[2]);">MAYBE</td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
	  	</tr>
		<tr>
		  	<td height="25"><strong>HOBBIES AND ACTIVITIES </strong></td>
	  	</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<%
							if(((String)vRetResult.elementAt(21)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="25" width="30%">
							<input type="checkbox" name="hobbies_singing" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','hobbies_singing','0', document.form_.hobbies_singing);">singing</td>
						<%
							if(((String)vRetResult.elementAt(24)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="30%"><input type="checkbox" name="hobbies_sketching" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','hobbies_sketching','0', document.form_.hobbies_sketching);">sketching/drawing</td>
						<%
							if(((String)vRetResult.elementAt(27)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="40%"><input type="checkbox" name="hobbies_arts" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','hobbies_arts','0', document.form_.hobbies_arts);">arts and crafts</td>
					</tr>
					<tr>
						<%
							if(((String)vRetResult.elementAt(22)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="25"><input type="checkbox" name="hobbies_dancing" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','hobbies_dancing','0', document.form_.hobbies_dancing);">dancing</td>
						<%
							if(((String)vRetResult.elementAt(25)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="hobbies_movies" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','hobbies_movies','0', document.form_.hobbies_movies);">watching movies</td>
						<%
							if(((String)vRetResult.elementAt(28)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="hobbies_outing" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','hobbies_outing','0', document.form_.hobbies_outing);">outing/socializing (with friends or family)</td>
					</tr>
					<tr>
						<%
							if(((String)vRetResult.elementAt(23)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td height="25"><input type="checkbox" name="hobbies_music" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','hobbies_music','0', document.form_.hobbies_music);">music</td>
						<%
							if(((String)vRetResult.elementAt(26)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="hobbies_sports" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','hobbies_sports','0', document.form_.hobbies_sports);">sports</td>
						<%
							if(((String)vRetResult.elementAt(29)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="hobbies_others" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','hobbies_others','0', document.form_.hobbies_others);">others (pls specify)
							<input name="hobbies_others_text" type="text" size="32" value="<%=WI.getStrValue((String)vRetResult.elementAt(30))%>"
								class="textbox" maxlength="128" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','hobbies_others_text','1', document.form_.hobbies_others_text);"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
	  	</tr>
		<tr>
		  	<td height="25">Please indicate any concern or problems you want to discuss with your Guidance Counselor.</td>
	  	</tr>
		<tr>
			<td>
				<textarea name="problems_concerns" style="font-size:12px" cols="120" rows="6" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','problems_concerns','1', document.form_.problems_concerns);"><%=WI.getStrValue((String)vRetResult.elementAt(31))%></textarea></td>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>