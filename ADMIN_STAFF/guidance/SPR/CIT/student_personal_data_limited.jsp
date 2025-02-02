<%@ page language="java" import="utility.*,osaGuidance.StudentPersonalDataCIT,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	request.getSession(false).setAttribute("is_limited","1");
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
	
	var imgWnd;
	var objCOA;
	var objCOAInput;
	function AjaxMapName(e, strFieldName, strLabelID) {
		if(e.keyCode == 13) {
			this.GetStudentInfo();
			return;
		}
		
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
	
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOAInput.value = strID;
		objCOA.innerHTML = "";
		this.GetStudentInfo();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function GetStudentInfo(){
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	function Redirect(strURL) {
		//check first if ID enter is mapped.. 
		if(document.form_.prev_id.value != document.form_.stud_id.value) {
			alert("This page needs to reload. Click OK to reload this page.");
			document.form_.submit();
			return;
		}
		location = strURL;
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./spis_print.jsp" />
	<% 
		return;}

	//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Guidance & Counseling-SPR","student_personal_data.jsp");
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
boolean bolShowPartial = false;
if(bolIsETO)
	bolShowPartial = true;
	
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Guidance & Counseling","SPR",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Registrar Management","Student Tracker",request.getRemoteAddr(),null);
		bolShowPartial = true;
	}														
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Admission","Student Info Mgmt",request.getRemoteAddr(),null);
		bolShowPartial = true;
	}														
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Student Affairs","Student Tracker",request.getRemoteAddr(),null);
		bolShowPartial = true;
	}														
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Admission Maintenance","Student Tracker",request.getRemoteAddr(),null);
		bolShowPartial = true;
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
	boolean bolIsTempStud = false;
	
	String strStudIndex = null;
	if(WI.fillTextValue("stud_id").length() > 0){
		strStudIndex = WI.fillTextValue("stud_id");
    	if(strStudIndex.length() == 0){
			strStudIndex = null;
     	 	strErrMsg = "Please provide student id.";
		}
		else{
		    strStudIndex = dbOP.mapUIDToUIndex(strStudIndex, 4);
    		if(strStudIndex == null || strStudIndex.length() == 0) {
				String strSQLQuery = "select application_index, old_stud_id from new_application where temp_id = '"+
					WI.fillTextValue("stud_id")+"' and is_valid = 1";
				java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
				String strHSGradID    = null;
				if(rs.next()) {
					strStudIndex = rs.getString(1);
					strHSGradID  = rs.getString(2);
				}
				rs.close();
				if(strHSGradID != null) {
					dbOP.cleanUP();
					response.sendRedirect("./student_personal_data_limited.jsp?stud_id="+strHSGradID);
					return;
				}
				
				if(strStudIndex == null)	
					strErrMsg = "ID number does not exist or is invalidated.";
				else {
					bolIsTempStud  = true;
					bolShowPartial = true;
				}
			}
		}
	}
%>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();">
<form name="form_" action="student_personal_data_limited.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: Student Personal Information Sheet ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%">&nbsp;</td>
		</tr>
		<tr>
		  	<td height="25" width="3%">&nbsp;</td>
			<td width="17%">ID Number: </td>
		  	<td colspan="2">
				<input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName(event, 'stud_id','stud_id_');">&nbsp;&nbsp;&nbsp;
				<label id="stud_id_" style="position:absolute; width: 400px"></label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2">
				<a href="javascript:GetStudentInfo();"><img src="../../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to get student information. </font></td>
		</tr>
	</table>
	
<%if(bolIsTempStud){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="2"><hr size="1"></td>
		</tr>
		<tr>
		    <td height="25" width="32%" style="font-size:16px; color:#0000FF; font-weight:bold"><strong>STUDENT NOT YET ENROLLED</strong> </td>
		    <td width="68%"><a href="javascript:Redirect('./student_data_temp.jsp?stud_id=<%=WI.fillTextValue("stud_id")%>&stud_index=<%=strStudIndex%>');" style="text-decoration:none">Part I: Student's Personal Data </a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><a href="javascript:Redirect('./student_acad_info_temp.jsp?stud_id=<%=WI.fillTextValue("stud_id")%>&stud_index=<%=strStudIndex%>')" style="text-decoration:none">Part II: Student's Academic Information</a></td>
		</tr>
	</table>
<%}else if(strStudIndex != null){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="2"><hr size="1"></td>
		</tr>
		<tr>
		    <td height="25" width="32%">&nbsp;</td>
		    <td width="68%"><a href="javascript:Redirect('./student_data_.jsp?stud_id=<%=WI.fillTextValue("stud_id")%>&stud_index=<%=strStudIndex%>')" style="text-decoration:none">Part I: Student's Personal Data </a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><a href="javascript:Redirect('./student_acad_info.jsp?stud_id=<%=WI.fillTextValue("stud_id")%>&stud_index=<%=strStudIndex%>')" style="text-decoration:none">Part II: Student's Academic Information</a></td>
		</tr>
	</table>
<%}%>

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td colspan="8" height="25" >&nbsp;</td>
		</tr>
		<tr>
			<td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page">
	<input type="hidden" name="stud_index" value="<%=WI.getStrValue(strStudIndex)%>">
	<input type="hidden" name="prev_id" value="<%=WI.fillTextValue("stud_id")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>