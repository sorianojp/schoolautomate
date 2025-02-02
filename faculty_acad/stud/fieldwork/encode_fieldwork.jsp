<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">



function goBack() {
	var strSubSecIndex = document.form_.section.value;
	var strSYFrom = document.form_.sy_from.value;
	var strSemester = document.form_.offering_sem.value;
	var strSubIndex = document.form_.subject.value;
	location = "./list_fieldwork.jsp?section="+strSubSecIndex+
		"&sy_from="+strSYFrom+"&sy_to=2007&offering_sem="+strSemester+
		"&subject="+strSubIndex+"&section_name="+
		document.form_.section_name.value;
}

//all about ajax
var AjaxCalledPos;
function AjaxMapName(strPos) {
	return;
		AjaxCalledPos = strPos;
		
		var strCompleteName;
		if(strPos == "1")
			strCompleteName = document.form_.stud_id.value;
		else	
			strCompleteName = document.form_.emp_id.value;
			
		if(strCompleteName.length == 0)
			return;
		
		var objCOAInput;
		if(strPos == "1")
			objCOAInput = document.getElementById("coa_info");
		else	
			objCOAInput = document.getElementById("coa_info2");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);
		if(strPos == "2")
			strURL += "&is_faculty=1";
		//if(document.form_.account_type[1].checked) //faculty
		//	strURL += "&is_faculty=1";
		//alert(strURL);
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	if(AjaxCalledPos == "2"){
		document.form_.emp_id.value = strID;
		return;
	}
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
	//alert(strUserIndex);
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	if(AjaxCalledPos == "1")
		document.getElementById("coa_info").innerHTML = strName;
	else	
		document.getElementById("coa_info2").innerHTML = strName;
}

function UpdateCompany() {
	var loadPg = "./company_list.jsp";

	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function UpdateSupervisor() {
	if(document.form_.company_index.selectedIndex < 1) {
		alert("Please select a company to add supervisor to it.");
		return;
	}
	var loadPg = "./company_supervisor.jsp?company_index="+document.form_.company_index[document.form_.company_index.selectedIndex].value;

	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>
<body bgcolor="#93B5BB">
<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMStudPerformance " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-Class Management-Attendance","encode_fieldwork.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Faculty/Acad. Admin","STUDENT PERFORMANCE",request.getRemoteAddr(), 
														"encode_fieldwork.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
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

//end of authenticaion code.
Vector vEditInfo = null;
CMStudPerformance cmp = new CMStudPerformance();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cmp.operateOnFieldWork(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = cmp.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
vEditInfo = cmp.operateOnFieldWork(dbOP, request, 5);

%>

<form name="form_" action="./encode_fieldwork.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#6A99A2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          STUDENT FIELDWORK/OJT PROFILE MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold"><a href="javascript:goBack();"><img src="../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="21%">Student ID</td>
      <td width="73%">
	  	<input name="stud_id" type="text"  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AjaxMapName('1');" readonly>
	  	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="submit" name="12" value=" Reload Page " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.page_action.value=''"></td>
    </tr>
<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td> Student Name</td>
      <td height="25"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
-->
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Company/Organization Name&nbsp;&nbsp;&nbsp;
	  <a href="javascript:UpdateCompany();"> <img src="../../../images/update.gif" border="0"></a>
	  
	  <font size="1">Update company list</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("company_index");
%>
	  	<select name="company_index">
		<option value="">Select a company from list</option>
          <%=dbOP.loadCombo("company_index","COMPANY_NAME"," from CM_STUD_COMPANY_LIST where is_valid = 1 order by company_name",strTemp, false)%> 
		</select>
	  
	  </td>
    </tr>
    <tr> 
      <td height="31">&nbsp;</td>
      <td height="31" colspan="2">Immediate Supervisor/Head &nbsp;&nbsp;&nbsp;
	  <a href="javascript:UpdateSupervisor();"> <img src="../../../images/update.gif" border="0"></a>
	  <font size="1">Update Supervisor List </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("supervisor");
%>
	  	<select name="supervisor">
		<option value="">Select a company from list</option>
          <%=dbOP.loadCombo("SUPERVISOR_INDEX","NAME"," from CM_STUD_COMPANY_SVISOR where is_valid = 1 order by NAME",strTemp, false)%> 
		</select>
	  
	  </td>
    </tr>
    
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Start Date : 
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("start_date");
%>        <input name="start_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.start_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td height="25">End Date : 
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("end_date");
%>        <input name="end_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.end_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Work Profile/Description</td>
      <td width="48%" height="25">Performance Feedback</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("work_profile");
%>	  <textarea name="work_profile" rows="4" cols="40" class="textbox" style="font-size:11px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(11);
else	
	strTemp = WI.fillTextValue("performance");
%>	  <textarea name="performance" rows="4" cols="40" class="textbox" style="font-size:11px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="44" valign="bottom"><div align="center">
        <%if(iAccessLevel > 1) {
	if(vEditInfo == null){%>
        <input type="button" name="Submit" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="document.form_.page_action.value='1';document.form_.Submit.disabled=true;document.form_.submit();">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<input type="button" name="EditInfo" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="document.form_.page_action.value='2';document.form_.EditInfo.disabled=true;document.form_.submit();">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="button" name="Cancel" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.reason.value='';document.form_.refer_date.value=''; document.form_.Cancel.disabled=true;document.form_.submit();">
      </div></td>
    </tr>
    <tr> 
      <td width="94%" height="25"><div align="center"></div></td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#6A99A2">&nbsp;</td>
    </tr>
  </table>
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(0);
else	
	strTemp = "";
%>  
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=strTemp%>">
<!-- Persistant field values -->
<input type="hidden" name="section"      value="<%=WI.fillTextValue("section")%>">
<input type="hidden" name="stud_index"   value="<%=WI.fillTextValue("stud_index")%>">
<input type="hidden" name="sy_from"      value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>">
<input type="hidden" name="subject"      value="<%=WI.fillTextValue("subject")%>">
<input type="hidden" name="section_name" value="<%=WI.fillTextValue("section_name")%>">
</form>
</body>
</html>
<%
 dbOP.cleanUP();
%>
