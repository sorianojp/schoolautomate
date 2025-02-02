<%@ page language="java" import="utility.*,osaGuidance.StudentPersonalDataCIT,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;

	//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-STUDENT PERSONAL DATA-Student Personal Data","student_socio_stat.jsp");
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
															"Registrar Management","STUDENT PERSONAL DATA-PART III",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0)
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Guidance & Counseling","STUDENT PERSONAL DATA-PART III",request.getRemoteAddr(), null);														
																
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
		<p style="font-size:16px; color:#FF0000;">Student reference is not found. Please close this window and click on the Part III link to try again..</p>
	<%return;}
	
	StudentPersonalDataCIT spd = new StudentPersonalDataCIT();
	Vector vRetResult = spd.getPart3Info(dbOP, request, strUserIndex);
	if(vRetResult == null)
		strErrMsg = spd.getErrMsg();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="student_socio_stat.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: PART III: STUDENT'S SOCIO-ECONOMIC STATUS ::::</strong></font></div></td>
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
						<td height="25" width="25%">Father and Mother are: (pls. check)</td>
						<%
							if(((String)vRetResult.elementAt(0)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="25%"><input type="radio" name="parent_stat" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','parent_stat','0', document.form_.parent_stat[0]);">married and living together</td>
						<%
							if(((String)vRetResult.elementAt(0)).equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="25%"><input type="radio" name="parent_stat" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','parent_stat','0', document.form_.parent_stat[1]);">separated</td>
						<%
							if(((String)vRetResult.elementAt(0)).equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="25%"><input type="radio" name="parent_stat" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','parent_stat','0', document.form_.parent_stat[2]);">not married</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(0)).equals("4"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="radio" name="parent_stat" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','parent_stat','0', document.form_.parent_stat[3]);">father deceased</td>
						<%
							if(((String)vRetResult.elementAt(0)).equals("5"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="radio" name="parent_stat" value="5" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','parent_stat','0', document.form_.parent_stat[4]);">mother deceased</td>
						<%
							if(((String)vRetResult.elementAt(0)).equals("6"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="radio" name="parent_stat" value="6" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','parent_stat','0', document.form_.parent_stat[5]);">both deceased</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="2">SOURCES OF INCOME (pls. check) </td>
					</tr>
					<tr>
					  	<td height="25" width="5%">&nbsp;</td>
						<%	
							if(((String)vRetResult.elementAt(1)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td width="95%"><input type="checkbox" name="income_source_salary" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','income_source_salary','0', document.form_.income_source_salary);">&nbsp;salary of parents, brothers and sisters or other members of the family</td>
				  	</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(2)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="income_source_yield" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','income_source_yield','0', document.form_.income_source_yield);">&nbsp;yield from agricultural land (rice, corn, coconut, etc.) </td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(3)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="income_source_rental" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','income_source_rental','0', document.form_.income_source_rental);">&nbsp;rental from residential lots or apartments</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(4)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="income_source_inherited" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','income_source_inherited','0', document.form_.income_source_inherited);">&nbsp;inherited wealth or business profits</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(5)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="income_source_others" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','income_source_others','0', document.form_.income_source_others);">&nbsp;others (pls. specify)
						<input name="income_source_others_text" type="text" size="64" value="<%=WI.getStrValue((String)vRetResult.elementAt(6))%>" class="textbox"
								maxlength="128" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','income_source_others_text','1', document.form_.income_source_others_text);"></td>
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
						<td height="25" colspan="4">MONTHLY FAMILY INCOME FROM ALL SOURCES (pls. check) </td>
					</tr>
					<tr>
						<td height="25" width="5%">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(7)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					    <td width="20%"><input type="radio" name="total_income" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','total_income','0', document.form_.total_income[0]);">Below P10,000</td>
						<%
							if(((String)vRetResult.elementAt(7)).equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					    <td width="20%"><input type="radio" name="total_income" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','total_income','0', document.form_.total_income[1]);">P15,000 - P19,999</td>
						<%
							if(((String)vRetResult.elementAt(7)).equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					    <td width="55%"><input type="radio" name="total_income" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','total_income','0', document.form_.total_income[2]);">P25,000 - and above</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(7)).equals("4"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="radio" name="total_income" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','total_income','0', document.form_.total_income[3]);">P10,000 - P14,999</td>
						<%
							if(((String)vRetResult.elementAt(7)).equals("5"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="radio" name="total_income" value="5" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','total_income','0', document.form_.total_income[4]);">P20,000 - P24,999</td>
						<%
							if(((String)vRetResult.elementAt(7)).equals("6"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
				  	    <td><input type="radio" name="total_income" value="6" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','total_income','0', document.form_.total_income[5]);">others (pls. specify) 
							<input name="total_income_others" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(36))%>" class="textbox"
								maxlength="128" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','total_income_others','1', document.form_.total_income_others);"></td>
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
						<td height="25" colspan="4">PAYING FOR THE CHILD'S TUITION (pls. check) </td>
					</tr>
					<tr>
						<td height="25" width="5%">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(8)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					    <td width="20%"><input type="radio" name="tuition_payer" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','tuition_payer','0', document.form_.tuition_payer[0]);">both parents </td>
						<%
							if(((String)vRetResult.elementAt(8)).equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					    <td width="20%"><input type="radio" name="tuition_payer" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','tuition_payer','0', document.form_.tuition_payer[1]);">grandparents</td>
						<%
							if(((String)vRetResult.elementAt(8)).equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					    <td width="55%"><input type="radio" name="tuition_payer" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','tuition_payer','0', document.form_.tuition_payer[2]);">relatives (aunt, uncle, etc.)</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(8)).equals("4"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="radio" name="tuition_payer" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','tuition_payer','0', document.form_.tuition_payer[3]);">either of the parents</td>
						<%
							if(((String)vRetResult.elementAt(8)).equals("5"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="radio" name="tuition_payer" value="5" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','tuition_payer','0', document.form_.tuition_payer[4]);">scholarship grant</td>
						<%
							if(((String)vRetResult.elementAt(8)).equals("6"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
				  	    <td><input type="radio" name="tuition_payer" value="6" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','tuition_payer','0', document.form_.tuition_payer[5]);">others (pls. specify)
							<input name="tuition_payer_others" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(9))%>" class="textbox"
								maxlength="128" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','tuition_payer_others','1', document.form_.tuition_payer_others);"></td>
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
						<td height="25" colspan="3">TYPE OF OWNERSHIP WHICH APPLIES TO THE PLACE THE FAMILY LIVES IN (pls. check) </td>
					</tr>
					<tr>
						<td height="25" width="5%">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(10)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					    <td width="30%"><input type="radio" name="house_ownership" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','house_ownership','0', document.form_.house_ownership[0]);">owns the house</td>
						<%
							if(((String)vRetResult.elementAt(10)).equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
				      	<td width="65%"><input type="radio" name="house_ownership" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','house_ownership','0', document.form_.house_ownership[1]);">renting</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(10)).equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="radio" name="house_ownership" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','house_ownership','0', document.form_.house_ownership[2]);">staying at relative's house</td>
						<%
							if(((String)vRetResult.elementAt(10)).equals("4"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="radio" name="house_ownership" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','house_ownership','0', document.form_.house_ownership[3]);">others (pls. specify)
							<input name="house_ownership_others" type="text" size="48" value="<%=WI.getStrValue((String)vRetResult.elementAt(11))%>" class="textbox"
								maxlength="128" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','house_ownership_others','1', document.form_.house_ownership_others);"></td>
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
						<td height="25" colspan="3">FAMILY CONVENIENCES (pls. check) </td>
					</tr>
					<tr>
						<td height="25" width="5%">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(21)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					    <td width="30%"><input type="checkbox" name="fam_con_tv" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_tv','0', document.form_.fam_con_tv);">television</td>
						<%
							if(((String)vRetResult.elementAt(22)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
				      	<td width="30%"><input type="checkbox" name="fam_con_organ" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_organ','0', document.form_.fam_con_organ);">organ/piano</td>
						<%
							if(((String)vRetResult.elementAt(23)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td width="35%"><input type="checkbox" name="fam_con_iron" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_iron','0', document.form_.fam_con_iron);">electric iron</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(24)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="fam_con_radio" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_radio','0', document.form_.fam_con_radio);">radio/cassette player</td>
						<%
							if(((String)vRetResult.elementAt(25)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="checkbox" name="fam_con_oven" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_oven','0', document.form_.fam_con_oven);">gas range/oven</td>
						<%
							if(((String)vRetResult.elementAt(26)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="fam_con_aircon" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_aircon','0', document.form_.fam_con_aircon);">air-conditioning unit</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(27)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="fam_con_stereo" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_stereo','0', document.form_.fam_con_stereo);">stereo/component/CD player</td>
						<%
							if(((String)vRetResult.elementAt(28)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="checkbox" name="fam_con_vacuum" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_vacuum','0', document.form_.fam_con_vacuum);">vacuum cleaner</td>
						<%
							if(((String)vRetResult.elementAt(29)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="fam_con_wm" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_wm','0', document.form_.fam_con_wm);">washing machine</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(30)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="fam_con_tel" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_tel','0', document.form_.fam_con_tel);">telephone (landline)</td>
						<%
							if(((String)vRetResult.elementAt(31)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="checkbox" name="fam_con_pc" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_pc','0', document.form_.fam_con_pc);">personal computer</td>
						<%
							if(((String)vRetResult.elementAt(32)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="fam_con_car" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_car','0', document.form_.fam_con_car);">car/jeep</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(33)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="fam_con_celfon" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_celfon','0', document.form_.fam_con_celfon);">cellular phone</td>
						<%
							if(((String)vRetResult.elementAt(34)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="checkbox" name="fam_con_ref" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_ref','0', document.form_.fam_con_ref);">refrigerator/freezer</td>
						<%
							if(((String)vRetResult.elementAt(35)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="fam_con_bike" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','fam_con_bike','0', document.form_.fam_con_bike);">bicycle/motorcycle</td>
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
						<td height="25" colspan="3">MEANS OF GOING TO SCHOOL (pls. check) </td>
					</tr>
					<tr>
						<td height="25" width="5%">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(12)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
				      	<td width="30%"><input type="radio" name="travel_means" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','travel_means','0', document.form_.travel_means[0]);">own transportation (private car)</td>
						<%
							if(((String)vRetResult.elementAt(12)).equals("2"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
				      	<td width="65%"><input type="radio" name="travel_means" value="2" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','travel_means','0', document.form_.travel_means[1]);">walking</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(12)).equals("3"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="radio" name="travel_means" value="3" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','travel_means','0', document.form_.travel_means[2]);">carpool</td>
						<%
							if(((String)vRetResult.elementAt(12)).equals("4"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="radio" name="travel_means" value="4" <%=strErrMsg%> onClick="javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','travel_means','0', document.form_.travel_means[3]);">public utility vehicle</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" order="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="3">REASONS FOR CHOOSING CIT (pls. check) </td>
					</tr>
					<tr>
						<td height="25" width="5%">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(13)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
				      	<td width="30%"><input type="checkbox" name="choice_reason_1" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','choice_reason_1','0', document.form_.choice_reason_1);">High Standard</td>
						<%
							if(((String)vRetResult.elementAt(14)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
				      	<td width="65%"><input type="checkbox" name="choice_reason_2" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','choice_reason_2','0', document.form_.choice_reason_2);">Parents are alumni of CIT/employee of CIT</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(15)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="choice_reason_3" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','choice_reason_3','0', document.form_.choice_reason_3);">Prestigious school</td>
						<%
							if(((String)vRetResult.elementAt(16)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="checkbox" name="choice_reason_4" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','choice_reason_4','0', document.form_.choice_reason_4);">Other siblings or relatives are studying in CIT</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(17)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="choice_reason_5" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','choice_reason_5','0', document.form_.choice_reason_5);">It is near our house</td>
						<%
							if(((String)vRetResult.elementAt(18)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="checkbox" name="choice_reason_6" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','choice_reason_6','0', document.form_.choice_reason_6);">Teachers are conscientious and teach well</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<%
							if(((String)vRetResult.elementAt(19)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
						<td><input type="checkbox" name="choice_reason_7" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','choice_reason_7','0', document.form_.choice_reason_7);">Tuition fee is affordable</td>
						<%
							if(((String)vRetResult.elementAt(20)).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						%>
					  	<td><input type="checkbox" name="choice_reason_8" value="1" <%=strErrMsg%> onClick="javascript:AjaxUpdateCheckbox('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','choice_reason_8','0', document.form_.choice_reason_8);">Discipline among students at CIT</td>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>