<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Hold-Unhold Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function AjaxMapName() {
	var strCompleteName = document.form_.stud_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	//var strURL = "../../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&name_format=5&complete_name="+escape(strCompleteName);
	
	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

<!--
function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.submit();
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.info_index.value  = strInfoIndex;
	document.form_.submit();
}

function PrepareToEdit(strInfoIndex){	
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value    = strInfoIndex;	
	document.form_.submit();
}

function EditRecord(){	
	document.form_.page_action.value = "2";
	document.form_.submit();
}

function CancelRecord(){
	location = "./hold_unhold_student.jsp?stud_id="+document.form_.stud_id.value;
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewStudent(){
	var pgLoc = "view_student_with_hold.jsp";	
	if(document.form_.is_basic.checked)
		pgLoc += "?is_basic=1";
			
	var win=window.open(pgLoc,"ViewStudent",'width=1000,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

-->
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus()">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameters","hold_unhold_student.jsp");
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
boolean bolIsRestricted = false;
if(WI.fillTextValue("override_param").length() > 0) 
	bolIsRestricted = true;

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 0;
if(bolIsRestricted) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Override Parameters","HOLD-UNHOLD",
															request.getRemoteAddr(),
															null);
}
else {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"System Administration","Set Parameters",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0) 
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Admission","Hold Unhold",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0) 
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Registrar Management","Hold-Unhold",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0) 
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"LIB_Administration","SYSTEM INFORMATION",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0) 
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Guidance & Counseling","Hold-Unhold",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0) 
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Student Affairs","Hold-Unhold",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0) 
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","Reports-",request.getRemoteAddr(),//intentionally made "reports-" sot hat system will authenticate only if for complete module.
															null);
}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = new Vector();
Vector vEditInfo  = new Vector();
Vector vStudInfo  = new Vector();

SetParameter setParam = new SetParameter();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
boolean bolIsAuthorized = true;

String strLoggedInUserCIndex = (String)request.getSession(false).getAttribute("info_faculty_basic.c_index");
String strLoggedInUserDIndex = (String)request.getSession(false).getAttribute("info_faculty_basic.d_index");
if(strLoggedInUserCIndex == null)
	strLoggedInUserCIndex = "0";
if(strLoggedInUserDIndex == null)
	strLoggedInUserDIndex = "0";




if(WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = setParam.operateOnHoldUnholdStudent(dbOP, request, WI.fillTextValue("stud_id"), 5);
	if(vStudInfo == null)
		strErrMsg = setParam.getErrMsg();	
	else {
		if(!strLoggedInUserCIndex.equals("0")) {//user has college in profile.
			if(!strLoggedInUserCIndex.equals((String)vStudInfo.elementAt(4))) {
				bolIsAuthorized = false;
				strErrMsg = "You are not authorized to process this student. Student belong to different College.";
			}
		}
	}
	/** removed and now based on profile.. -- dated Nov 07, 2014.
	else if(bolIsRestricted) {
		if(strFacCollege == null || !strFacCollege.equals((String)vStudInfo.elementAt(4))) {
			bolIsAuthorized = false;
			strErrMsg = "You are not authorized to process this student. Student belong to different College.";
		}
	}**/
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){	
	if(setParam.operateOnHoldUnholdStudent(dbOP, request, WI.fillTextValue("stud_id"), Integer.parseInt(strTemp)) == null)	
		strErrMsg = setParam.getErrMsg();
	else{
		if(strTemp.equals("1"))
			strErrMsg = "Entry Successfully Saved";
		if(strTemp.equals("2"))
			strErrMsg = "Entry Successfully Updated";
		if(strTemp.equals("0"))
			strErrMsg = "Entry Successfully Deleted";
		strPrepareToEdit = "";
	}
}

if(vStudInfo != null && vStudInfo.size() > 0){
	vRetResult = setParam.operateOnHoldUnholdStudent(dbOP, request, WI.fillTextValue("stud_id"), 4);
	if(vRetResult == null)
		strErrMsg = setParam.getErrMsg();
}

if(strPrepareToEdit.length() > 0){
	vEditInfo = setParam.operateOnHoldUnholdStudent(dbOP, request, WI.fillTextValue("stud_id"), 3);
	if(vEditInfo == null)
		strErrMsg = setParam.getErrMsg();
}
String[] astrConverSem = {"Summer", "1st Sem", "2nd Sem", "3rd Sem", "4th Sem", "5th Sem"};

boolean bolIsBasic = false;
if(vStudInfo != null && vStudInfo.size() > 0 && ((String)vStudInfo.elementAt(4)).equals("0")) {
	bolIsBasic = true;
	astrConverSem[1] = "Regular";
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<form name="form_" action="./hold_unhold_student.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SET PARAMETERS - HOLD AND UNHOLD STUDENT ::::</strong></font></div></td>
    </tr>
	<tr> 
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">Student ID</td>
		<%
		strTemp = WI.fillTextValue("stud_id");
		%>
		<td>		
		<input type="text" name="stud_id" value="<%=strTemp%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" size="20" maxlength="32" onKeyUp="AjaxMapName();">
		&nbsp; &nbsp;
		<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>
		&nbsp; &nbsp;
		<a href="javascript:document.form_.submit();">
		<img src="../../../images/form_proceed.gif" border="0">
		</a>
		</td>
		<td align="right"><%if(!bolIsRestricted) {%>
			<%if(strSchCode.startsWith("NEU")){%>
			<input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%>> 
			<font style="font-weight:bold; font-size:10px; color:#0000FF">Show Basic</font>
			<%}%>
			<a href="javascript:ViewStudent()">
			<img src="../../../images/view.gif" border="0"></a>
			<font size="1">Click to view student with holding entry</font>
			<%}%>
		</td>
	</tr>
	
	<tr>
      <td height="15">&nbsp;</td>
	  <td height="">&nbsp;</td>
      <td colspan="2"><label id="coa_info"></label></td>
    </tr>
	
	
	
	
<%if(vStudInfo != null && vStudInfo.size() > 0){%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Student Name</td>
		<td colspan="2"><strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Last School Year/Term</td>
		<td colspan="2"><strong><%=astrConverSem[Integer.parseInt((String)vStudInfo.elementAt(3))]%>, <%=(String)vStudInfo.elementAt(2)%></strong></td>
	</tr>

	<tr> 
      <td height="25">&nbsp;</td>
	  <td height="25">&nbsp;</td>
      <td colspan="2">
<%
strTemp = request.getParameter("hold_unhold");
if(strTemp == null)
	strTemp = "";
	
if(strTemp.length() == 0 || strTemp.equals("1"))
	strErrMsg = " checked";
else
	strErrMsg = "";

%>
	  <input name="hold_unhold" type="radio" value="1" <%=strErrMsg%> onClick="document.form_.submit();" />  Hold
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else
	strErrMsg = "";
if(strPrepareToEdit.length() > 0){
%>

      <input name="hold_unhold" type="radio" value="2" <%=strErrMsg%> onClick="document.form_.submit();" > Unhold <%}%></td>
    </tr>
	
	<%if(strPrepareToEdit.length() == 0 || strTemp.equals("1")){%>
<!--
	<tr>
		<td height="25">&nbsp;</td>
		<td>College</td>
		
		<%
		strTemp = WI.fillTextValue("college_index");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vRetResult.elementAt(3);
		%>
		
		<td colspan="3"> 
		<select name="college_index" onChange="document.form_.submit();">
		<option value="">All</option>
		<%=dbOP.loadCombo("c_index","c_name, c_code", " from college where is_del = 0 order by c_name ", strTemp, false)%> 
		</select>		</td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Department</td>
		<%
		strTemp2 = WI.fillTextValue("college_index");	
		String strTemp3  = WI.fillTextValue("d_index");
		
	 	if(vEditInfo != null && vEditInfo.size() > 0){
	  		strTemp3 = (String)vEditInfo.elementAt(4);
			strTemp2 = (String)vEditInfo.elementAt(3);
		}
	  	
		if(strTemp.length() > 0)
			strTemp = " where is_del = 0 and c_index = "+strTemp2+" order by d_name ";
		else
			strTemp = " where is_del = 0 order by d_name ";
		
		%>
		<td colspan="3"> 
		<select name="d_index">
		<option value="">All</option>
		<%=dbOP.loadCombo("d_index","d_name, d_code", " from department "+strTemp , strTemp3, false)%> 
		</select>		</td>
	</tr>
-->    
    <%}%>
    
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Reason </td>
	  <%
	  strTemp = WI.fillTextValue("reason");
	  if(vEditInfo != null && vEditInfo.size() > 0)
	  	strTemp = WI.getStrValue((String)vEditInfo.elementAt(2), (String)vEditInfo.elementAt(5));
	  %>
      <td colspan="2">
	  	<textarea name="reason" cols="48" rows="3" class="textbox" 
			id="reason" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
    </tr>
    
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
<%if(bolIsAuthorized) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"> 
		<%if(iAccessLevel > 1){
			if(strPrepareToEdit.length() == 0){
		%> 	  		
			<a href="javascript:AddRecord();"><img src="../../../images/save.gif" width="48" height="28" border="0"></a>
			<font size="1">click to save</font> 
			<%}else{%>
			<a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
			<font size="1">click to update</font>
			<%}%>
			<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
			<font size="1">click to cancel</font>
		<%}%> &nbsp;</td>
    </tr>
<%}%>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
	<%}%>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr style="font-weight:bold">
<!--
		<td class="thinborder" height="25" width="20%"><strong>College</strong></td>
		<td class="thinborder" height="25" width="20%"><strong>Department</strong></td>
-->
		<td class="thinborder" height="25" width="20%"><strong>Hold Reason</strong></td>
		<td class="thinborder" height="25" width="20%"><strong>Unhold Reason</strong></td>
		<td class="thinborder" height="25" width="10%"><strong>SY/Term</strong></td>
		<td class="thinborder" width="10%">Holding College </td>
		<td class="thinborder" width="10%">Holding Dept. </td>
		<td class="thinborder" height="25" width="10%"><strong>Edit Option</strong></td>
	</tr>
	
	<%
	String strCollege = null;
	String strDepartment = null;
	boolean bolIsAlterAllowed = false;
	for(int i = 0; i < vRetResult.size(); i+=10){	
		strCollege = (String)vRetResult.elementAt(i+6);
		if(((String)vRetResult.elementAt(i+3)).equals("0"))
			strCollege = " - ";
		
		strDepartment = (String)vRetResult.elementAt(i+7);
		if(((String)vRetResult.elementAt(i+4)).equals("0"))
			strDepartment = " - ";
			
		bolIsAlterAllowed = false;
		
		if(!strLoggedInUserCIndex.equals("0")) {//belong to college, check now, must be locked by college. 
			if(strLoggedInUserCIndex.equals(vRetResult.elementAt(i+3)))
				bolIsAlterAllowed = true;
		}
		else {
			if(strLoggedInUserDIndex.equals(vRetResult.elementAt(i+4)))
				bolIsAlterAllowed = true;
		}
		//old data exception.
		if(vRetResult.elementAt(i+3).equals("0") && vRetResult.elementAt(i+4).equals("0"))
			bolIsAlterAllowed = true;
		
	%>
	
	<tr>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2), "&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5), "&nbsp;")%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i + 8)%> <%=astrConverSem[Integer.parseInt((String)vRetResult.elementAt(i+9))]%></td>
		<td class="thinborder" height="25"><%=strCollege%></td>
		<td class="thinborder"><%=strDepartment%></td>
		<td class="thinborder">
		<%if(bolIsAlterAllowed) {
			if(iAccessLevel > 1){%>
			<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')">
			<img src="../../../images/edit.gif" border="0"></a>
			
			<%if(iAccessLevel == 2){%>
			<a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')">
			<img src="../../../images/delete.gif" border="0"></a>
			<%}
			}
		}else{%>
			Not Allowed.
		<%}%>		
		</td>
	</tr>
	
	<%}%>
</table>

<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

<input type="hidden" name="override_param" value="<%=WI.fillTextValue("override_param")%>">

<input type="hidden" name="college_index" value="<%=strLoggedInUserCIndex%>">
<input type="hidden" name="d_index" value="<%=strLoggedInUserDIndex%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
