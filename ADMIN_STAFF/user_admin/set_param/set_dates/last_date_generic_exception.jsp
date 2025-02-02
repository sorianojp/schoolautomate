<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function AddRecord(){
	document.form_.page_action.value = "1";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value="0";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function ReloadPage()
{
	document.form_.page_action.value = "";
	this.SubmitOnce("form_");
}

//all about ajax - to display student list with same name.
function AjaxMapName(strRef) {
	var strSearchCon = "&search_temp=2";
	var strCompleteName;
	strCompleteName = document.form_.stud_id.value;
	if(strCompleteName.length == 0)
		return;

	var objCOAInput;
	objCOAInput = document.getElementById("coa_info");

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strstud_id) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameters","last_date_generic_exception.jsp");
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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Set Parameters-Sysem Dates",request.getRemoteAddr(),
														null);
}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = new Vector();
SetParameter setParam = new SetParameter();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)//add/ delete.
{
	if(setParam.operateOnLockGenericException(dbOP,request,Integer.parseInt(strTemp)) != null)
		strErrMsg = "Operation Successful.";
	else
		strErrMsg = setParam.getErrMsg();
}
vRetResult = setParam.operateOnLockGenericException(dbOP,request,4);
if(vRetResult == null && strErrMsg == null)
		strErrMsg = setParam.getErrMsg();
		
String[] astrConvertTerm = {"S","FS","SS","TS"};
boolean bolIsCourseAllowed = false;
if(WI.fillTextValue("allow_course").length() > 0) 
	bolIsCourseAllowed = true;
%>
<form name="form_" action="./last_date_generic_exception.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: LOCK EXCEPTION ::::</strong></font></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%> onClick="ReloadPage();"> 
	  Show only Basic </td>
    </tr>
-->
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="17%">SY-Term</td>
      <td colspan="2"> 
<% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> 
	  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' maxlength=4>
        - 
        <% strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        - 
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>
        &nbsp;
		
		<input type="checkbox" name="allow_course" value="checked" <%=WI.fillTextValue("allow_course")%> onClick="document.form_.submit()"> 
		Allow course(all student enrolling a course)	  </td>
    </tr>
<%if(bolIsCourseAllowed) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course </td>
      <td colspan="2">
	  <select name="course_index" style="font-size:12; width:600;">
          <option value="">&lt;Select Any&gt;</option>
          <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name as cname"," from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 order by cname asc", strTemp, false)%> 
        </select>	  </td>
    </tr>
<%}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Student ID(temp/old) </td>
      <td>
	  <input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=WI.fillTextValue("stud_id")%>" maxlength="32" onKeyUp="AjaxMapName('1');">	  </td>
      <td><label id="coa_info" style="position:absolute; width:450px"></label></td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Last date</td>
      <td width="13%"><input name="last_date" type="text" class="textbox" id="last_date"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("last_date")%>" size="12" maxlength="12" readonly="yes">      </td>
      <td width="66%"><a href="javascript:show_calendar('form_.last_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <%
if( iAccessLevel >1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Apply Exception On </td>
      <td colspan="2">
	  <select name="lock_type">
	  	<option></option>
<%
strTemp = WI.fillTextValue("lock_type");
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="1"<%=strErrMsg%>>Enrollment</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="2"<%=strErrMsg%>>Scholarship/Grants</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="3"<%=strErrMsg%>>Add/Drop</option>
<%
if(strTemp.equals("4"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="4"<%=strErrMsg%>>System Lock For Fees</option>
	  </select>	  
	  <a href="javascript:ReloadPage();"><img src="../../../../images/refresh.gif" border="0"></a>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="javascript:AddRecord()"><img src="../../../../images/save.gif" border='0'></a><font size="1">click 
        to save setting </font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
boolean bolDelAllowed = false;
String[] astrLockType = {"","ENROLLMENT","SCHOLARSHIP/GRANT","ADD/DROP","FEES"};

%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr bgcolor="#B9B292">
      <td height="25"><div align="center"><strong>LIST OF EXCEPTIONS FOR: <%=astrLockType[Integer.parseInt(WI.getStrValue(WI.fillTextValue("lock_type"),"0"))]%></strong></div></td>
    </tr>
</table>


  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold;">
	  <td height="22" width="1%" class="thinborder">Count</td>
	  <%if(bolIsCourseAllowed){%>
	  	  <td width="25%" class="thinborder">Course</td>
	  <%}else{%>
		  <td width="15%" class="thinborder">Student ID </td>
		  <td width="25%" class="thinborder">Student Name </td>
		  <td width="10%" class="thinborder">Last Date </td>
		  <td width="5%" class="thinborder">Is Temp ID </td>
	  <%}%>
	  <td width="5%" class="thinborder">Remove Exception </td>
    </tr>
	<%for(int i = 0; i < vRetResult.size(); i += 6) {
	
	%>
		<tr>
		  <td height="22" class="thinborder"><%=i/6 + 1%></td>
		  <%if(bolIsCourseAllowed){%>
			  <td class="thinborder"><%=vRetResult.elementAt(i + 1)%>: <%=vRetResult.elementAt(i + 2)%></td>
		  <%}else{%>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
			  <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
			  <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
			  <td class="thinborder"><%if(((String)vRetResult.elementAt(i + 5)).equals("1")){%> <font size="4"><b>Y</b></font><%}else{%>&nbsp;<%}%></td>
		  <%}%>
		  <td class="thinborder"><a href="javascript:DeleteRecord('<%=vRetResult.elementAt(i)%>')"><img src="../../../../images/delete.gif" border="0"></a> </td>
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
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
