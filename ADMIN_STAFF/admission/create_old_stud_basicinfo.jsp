<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript">
function AddRecord()
{
	document.offlineRegd.addRecord.value = "1";
}

function ReloadPage()
{
	document.offlineRegd.reloadPage.value="1";
	document.offlineRegd.addRecord.value = "";
	document.offlineRegd.submit();
}
function ReloadCourseIndex()
{
	//course index is changed -- so reset all dynamic fields.
	if(document.offlineRegd.cy_from.selectedIndex > -1)
		document.offlineRegd.cy_from[document.offlineRegd.cy_from.selectedIndex].value = "";
	if(document.offlineRegd.major_index.selectedIndex > -1)
		document.offlineRegd.major_index[document.offlineRegd.major_index.selectedIndex].value = "";

	document.offlineRegd.submit();
}
function ClearEntry()
{
	location = "./create_old_stud_basicinfo.jsp";
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.offlineRegd.stud_id.value;
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
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.offlineRegd.stud_id.value = strID;
	document.offlineRegd.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.offlineRegd.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}</script>

<body bgcolor="#D2AE72" onLoad="document.offlineRegd.stud_id.focus();">
<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,enrollment.NAApplicationForm,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;

	Vector vTemp = new Vector();
	String strCourseIndex = null;
	String strMajorIndex = null;
	int i=0;int j=0;
	String strCourseType = null;

	String[] astrSchYrInfo = null;
	boolean bolCleanUPEntry = false;

	String strSYTo = null; // this is used in

	Vector vStudBasicInfo = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode  = "";
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","create_old_stud_basicinfo.jsp");
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
														"Admission","Student Info Mgmt",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"FEE ASSESSMENT & PAYMENTS","OTHER EXCEPTION",request.getRemoteAddr(),
														null);
}
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
}

//end of authenticaion code.

SubjectSection SS = new SubjectSection();
OfflineAdmission offlineAdm = new OfflineAdmission();

//I have to check if ID is there in temp ID.. 
boolean bolIsFatalErr = false;
if(WI.fillTextValue("stud_id").length() > 0) {
	String strSQLQuery = "select application_index from new_application where temp_id = '"+WI.fillTextValue("stud_id")+"'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null) {
		strErrMsg = "ID already used in temp ID.";
		bolIsFatalErr = true;
	}
}


if(!bolIsFatalErr) {
	if(WI.fillTextValue("addRecord").compareTo("1") ==0)
	{
		if(!offlineAdm.createOldStudInfoOffline(dbOP,request))
			strErrMsg = offlineAdm.getErrMsg();
		else
		{
			strErrMsg = "Student basic information is created successfully.";
			bolCleanUPEntry = true;
		}
	}
	strCourseType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.getStrValue(WI.fillTextValue("course_index"),"0"),"DEGREE_TYPE",null);
	if(strErrMsg == null && WI.fillTextValue("stud_id").length() > 0) {
		strErrMsg = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("stud_id")+"'","user_index"," and is_valid = 1 and is_del = 0");
		if(strErrMsg != null)
			strErrMsg = "ID Exists";
	}
}
%>
<form action="./create_old_stud_basicinfo.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          OLD STUDENT MANUAL REGISTRATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"></td>
      <td height="25"><a href="old_student_info_mgmt_main.htm"><img src="../../images/go_back.gif" border="0"></a></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" width="1%"></td>
      <td height="25"> <%if(strErrMsg != null){%> <strong><font size="3"><%=strErrMsg%></font></strong> &nbsp; <%}%> </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="top">
      <td height="25">&nbsp;</td>
      <td height="25">Student ID :</td>
      <td height="25"><input type="text" name="stud_id" size="16" maxlength="32" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td height="25"><a href="javascript:ReloadPage();"><img src="../../images/form_proceed.gif" border="0"></a></td>
      <td width="53%" height="25">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course</td>
      <td height="25" colspan="3"><select name="course_index" onChange="ReloadCourseIndex();" style="font-size:10px;">
        <option value="0">Select Any</option>
        <%
	strCourseIndex = WI.fillTextValue("course_index");
%>
        <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 and is_visible = 1 order by course_name asc", strCourseIndex, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Major&nbsp;</td>
      <td height="25" colspan="3"><select name="major_index" onChange="ReloadPage();">
        <option></option>
        <%
strMajorIndex = WI.fillTextValue("major_index");

if(strCourseIndex != null && strCourseIndex.compareTo("0") != 0 && strCourseIndex.length()>0)
{
strTemp = " from major where is_del=0 and course_index="+strCourseIndex+" order by major_name asc" ;
%>
        <%=dbOP.loadCombo("major_index","major_name",strTemp, strMajorIndex, false)%>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Curr. Year      </td>
      <td height="25"><select name="cy_from" onChange="ReloadPage();">
        <%
//get here school year
vTemp = SS.getSchYear(dbOP, request);
strTemp = WI.fillTextValue("cy_from");

for(i = 0, j=0 ; i< vTemp.size();)
{
	if(	((String)vTemp.elementAt(i)).compareTo(strTemp) == 0)
	{%>
        <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i)%></option>
        <%	j = i;
	}
	else{
	%>
        <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i)%></option>
        <%	}
	i = i+2;

}
if(vTemp.size() > 0)
	strSYTo = (String)vTemp.elementAt(j+1);
else
	strSYTo = "";

%>
      </select>
to <b><%=strSYTo%></b>
<input type="hidden" name="cy_to" value="<%=strSYTo%>"></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
 <%
 if(strSYTo.length() > 0){%>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="13%" height="25"> Year level entry</td>
      <td width="21%">
<%
if(strCourseType.compareTo("1") != 0 && strCourseType.compareTo("4") != 0)//year is not applicable for non semestral and masteral.
{%>	  <select name="year_level">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("2") == 0){%>
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
        </select>
<%}//do not show year for masteral and non semestral.
else{%> N/A
<%}
if(strCourseType.compareTo("3") ==0)//for prep-prop type curriculum
{%>
		<select name="prep_prop_stat">
		<option value="1">Preparatory</option>
<%if(WI.fillTextValue("prep_prop_stat").compareTo("2") ==0){%>
		<option value="2" selected>Proper</option>
<%}else{%>
		<option value="2">Proper</option>
<%}%>
		</select>
<%}%>		 </td>
      <td width="12%" height="25" align="center">Term </td>
      <td><select name="semester">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}
		  
		  if(!strSchCode.startsWith("CPU")){
		  
		    if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <% }else{%>
          <option value="3">3rd</option>
          <% }
		   }
		  
		  if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%} %>
        </select> </td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="13%" height="25"> School Year</td>
      <td height="25" colspan="3"><input type="text" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("offlineRegd","sy_from","sy_to")'>
        to
        <input type="text" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp;<font size="1"><strong>NOTE:</strong> Do not enter current
        enrolling information.Enter student's any of old information</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td align="right">Student Entry status&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td><select name="entry_status">
          <%=dbOP.loadCombo("status_index","status"," from user_status where status <> 'old' and status <> 'Change Course' and is_for_student = 1 order by status asc",
					WI.fillTextValue("entry_status"), false)%> </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom" align="right">Gender&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td valign="bottom"><select name="gender">
          <%
strTemp = WI.getStrValue("gender");
if(strTemp.compareTo("M") ==0)
{%>
          <option value="M" selected>Male</option>
          <%}else{%>
          <option value="M">Male</option>
          <%}if(strTemp.compareTo("F") ==0)
{%>
          <option value="F" selected>Female</option>
          <%}else{%>
          <option value="F">Female</option>
          <%}%>
        </select></td>
      <td height="25" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="35%" height="25" valign="bottom">Student last name </td>
      <td width="34%" valign="bottom">Student first name </td>
      <td width="30%" height="25" valign="bottom">Student middle name </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">
        <%
if(bolCleanUPEntry)
	strTemp = "";
else
	strTemp = WI.fillTextValue("lname");
%>
        <input name="lname" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td>
        <%
if(bolCleanUPEntry)
	strTemp = "";
else
	strTemp = WI.fillTextValue("fname");
%>
        <input name="fname" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td height="25">
        <%
if(bolCleanUPEntry)
	strTemp = "";
else
	strTemp = WI.fillTextValue("mname");
%>
        <input name="mname" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="7"><div align="center"></div></td>
      <td width="26%" height="25"><input type="image" src="../../images/save.gif" onClick="AddRecord();">
        <font size="1" >click to save entries</font></td>
      <td width="53%" height="25"><a href="javascript:ClearEntry();"><img src="../../images/clear.gif" width="55" height="19" border="0"></a>
        <font size="1" >click to clear entries</font></td>
    </tr>

<%}//if strSYTo.length() > 0)
%>

    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
