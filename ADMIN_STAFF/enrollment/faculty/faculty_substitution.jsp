<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage() {
	document.form_.show_list.value = "";
	document.form_.page_action.value = "";
	document.form_.info_index.value = "";
	document.form_.submit();
}
function ShowList() {
	document.form_.show_list.value = "1";
	document.form_.page_action.value = "";
	document.form_.info_index.value = "";
	document.form_.submit();
}
function focusID() {
	document.form_.emp_id.focus();
}
function ViewFacultyLoadDtls(strStudID) {
	var pgLoc = "./teaching_load_slip.jsp?get_hour_load=1&emp_id="+strStudID+"&sy_from="+
	document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function Assign(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "1";
	document.form_.show_list.value = "1";
	
	document.form_.submit();
}
function RemoveAssign(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "0";
	document.form_.show_list.value = "1";
	document.form_.submit();
}
function ShowTempSch() {
	if(document.form_.subject)
		document.form_.subject.selectedIndex = 0;
	if(document.form_.sub_section)
		document.form_.sub_section.selectedIndex = 0;
	
	document.form_.submit();
}
function ViewFacultySubstitutionDtls() {
	if(document.form_.emp_id.value == '') {
		alert("Please enter employee id.");
		return;
	}
	
	var pgLoc = "./faculty_substitution_dtls.jsp?emp_id="+document.form_.emp_id.value+
	"&sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//all about ajax - to display student list with same name.
function AjaxMapName(e) {
		if(e.keyCode == 13) {
			ReloadPage();
			return;
		}
		var strCompleteName = document.form_.emp_id.value;
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
-->
</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector, java.util.Date" %>
<%
	//simple authentication added here.
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4")) {
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Not Authorized to view this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	Vector vFacultyInfo    = null;
	String strFacultyName  = null;

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-SUBSTITUTION"),"0"));
		}		
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-substitute","faculty_substitution.jsp");
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
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"faculty_substitution.jsp");
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
**/
//end of authenticaion code.

FacultyManagement FM = new FacultyManagement();
enrollment.FacMgmtSubstitution facSubs = new enrollment.FacMgmtSubstitution(dbOP);

Vector vUserDetail   = null;
Vector vSubHandled   = null;
Vector vSubSection   = null;
Vector vFacAvailable = null;//available faculty list to take this subject.

String strEmployeeIndex = null;
if(WI.fillTextValue("emp_id").length() > 0) 
	strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));

if(strEmployeeIndex != null) {
	vUserDetail = FM.viewFacultyDetail(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"));
	if(vUserDetail == null)
		strErrMsg = FM.getErrMsg();
}
else if(WI.fillTextValue("emp_id").length() > 0 && strEmployeeIndex == null)
	strErrMsg = "Employee ID :"+WI.fillTextValue("emp_id")+" does not exist.";

//assign or remove assignment here. 
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(facSubs.operateOnSubstitution(dbOP, request, Integer.parseInt(strTemp)) )
		strErrMsg = "Operation successful.";
	else	
		strErrMsg = facSubs.getErrMsg();
}



if(WI.fillTextValue("show_list").length() > 0) {
	vFacAvailable = facSubs.showAvailableFacultyToSubstitute(dbOP, request);
	if(vFacAvailable == null)
		strErrMsg = facSubs.getErrMsg();
	//System.out.println(vFacAvailable);
}


if(strEmployeeIndex != null) {
	vSubHandled = facSubs.getSubjHandled(dbOP, request);
	if(vSubHandled == null) 
		strErrMsg = facSubs.getErrMsg();
	else if(WI.fillTextValue("subject").length() > 0){
		vSubSection	= facSubs.getSectionHandled(dbOP, request);
		if(vSubHandled == null) 
			strErrMsg = facSubs.getErrMsg();		
	}

}

Vector vSubstitutedOneDate = null;

if(strEmployeeIndex != null) {
	if(WI.fillTextValue("subs_date").length() > 0 && WI.fillTextValue("sub_section").length() > 0) {
		vSubstitutedOneDate = facSubs.getFacultySubsDetail(dbOP, WI.fillTextValue("sub_section"), WI.fillTextValue("subs_date"),-1, strEmployeeIndex);
	}
}

%>

<form name="form_" action="./faculty_substitution.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FACULTY SUBSTITUTION PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="4%">&nbsp;</td>
      <td colspan="3" height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td valign="bottom">School Year/Term : </td>
      <td colspan="2" valign="bottom"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select>     
		<input type="checkbox" name="inc_temp_schd" value="checked" <%=WI.fillTextValue("inc_temp_schd")%> onClick="ShowTempSch();"> Show Temporary Schedule		</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="19%">Faculty ID : </td>
      <td width="48%"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event);">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" height="25" hspace="20"></a></td>
      <td width="29%" align="right">
	  <a href='javascript:ViewFacultySubstitutionDtls();'><img src="../../../images/view.gif" border="0"></a>
	  <font size="1">Click to view Substitution for this faculty</font>	  </td>
    </tr>
    <tr >
      <td></td>
      <td colspan="4"><label id="coa_info" style="position:absolute; width:400px;"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date of Substitution</td>
      <td colspan="2"><input name="subs_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("subs_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.subs_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" hspace="70" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
	</table>
<%
if(vUserDetail != null && vUserDetail.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="19%">Faculty Name</td>
      <td width="59%"><strong><%=(String)vUserDetail.elementAt(1)%></strong></td>
      <td width="18%" rowspan="4" valign="middle"> <img src="../../../upload_img/<%=WI.fillTextValue("emp_id").toUpperCase() + "."+(String)request.getSession(false).getAttribute("image_extn")%>" width="90" height="90" border="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">College / Dept</td>
      <td height="25"><strong><%=WI.getStrValue(vUserDetail.elementAt(4))%>  <%=WI.getStrValue((String)vUserDetail.elementAt(5)," / ","","")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Emp. Status</td>
      <td height="25"><strong><%=(String)vUserDetail.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Total Load</td>
      <td><strong><%=(String)vUserDetail.elementAt(6)%></strong>&nbsp;&nbsp;
	  <a href='javascript:ViewFacultyLoadDtls("<%=WI.fillTextValue("emp_id")%>");'>
	  <img src="../../../images/view.gif" height="25" border="0"></a>
	  <font size="1">Click to view faculty load detail.</font></td>
    </tr>
  </table>
<%}//only if user info is not null.
if(vSubHandled != null) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="95%" height="25" valign="bottom"><strong>Subjects Handled </strong></td>
      <td width="1%" height="25" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <select name="subject" onChange="ReloadPage();">
          <option value="">Select a subject</option>
          <%
strTemp = WI.fillTextValue("subject");
for(int i = 0; i < vSubHandled.size(); i += 2) {
	if(strTemp.compareTo((String)vSubHandled.elementAt(i)) == 0){%>
          <option value="<%=(String)vSubHandled.elementAt(i)%>" selected><%=(String)vSubHandled.elementAt(i + 1)%></option>
          <%}else{%>
          <option value="<%=(String)vSubHandled.elementAt(i)%>"><%=(String)vSubHandled.elementAt(i + 1)%></option>
          <%}
}//end of for loop%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom"><strong>Section</strong></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <% 
if(vSubSection != null && vSubSection.size() > 0){
String strSecSchedule = null;
%> <select name="sub_section" onChange="ReloadPage();">
          <option value="">Select a Section</option>
          <%
strTemp = WI.fillTextValue("sub_section");
for(int i = 0; i < vSubSection.size(); i += 4) {
	if(strTemp.compareTo((String)vSubSection.elementAt(i)) == 0){
		strSecSchedule = (String)vSubSection.elementAt(i + 2)+" Room Number : "+(String)vSubSection.elementAt(i + 3);%>
          <option value="<%=(String)vSubSection.elementAt(i)%>" selected><%=(String)vSubSection.elementAt(i + 1)%></option>
          <%}else{%>
          <option value="<%=(String)vSubSection.elementAt(i)%>"><%=(String)vSubSection.elementAt(i + 1)%></option>
          <%}
}//end of for loop%>
        </select> <font size="1" color="#0000FF"><strong><%=WI.getStrValue(strSecSchedule," Schedule :","","")%> </strong></font> <%}//end of if condition.%> </td>
    </tr>
    <%if(vSubstitutedOneDate != null && vSubstitutedOneDate.size() > 0){%>
    <tr> 
      <td height="35">&nbsp;</td>
      <td height="35" colspan="2" valign="bottom"><strong>Substituting faculty<br>
	  	<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
			<tr style="font-weight:bold;" bgcolor="#CCCCCC">
				<td class="thinborder" height="22" width="22%">Faculty ID</td>
				<td class="thinborder" width="22%">Faculty Name</td>
				<td class="thinborder" width="22%">Load Hour</td>
				<td class="thinborder">Remove</td>
			</tr>
			<%while(vSubstitutedOneDate.size() > 0) {%>
				<tr>
					<td class="thinborder" height="20"><%=vSubstitutedOneDate.elementAt(1)%></td>
					<td class="thinborder"><%=vSubstitutedOneDate.elementAt(2)%></td>
					<td class="thinborder"><%=vSubstitutedOneDate.elementAt(3)%></td>
					<td class="thinborder"><a href='javascript:RemoveAssign(<%=(String)vSubstitutedOneDate.elementAt(0)%>);'><img src="../../../images/delete.gif" border="0" hspace="15"></a></td>
				</tr>
			<%vSubstitutedOneDate.remove(0);vSubstitutedOneDate.remove(0);vSubstitutedOneDate.remove(0);vSubstitutedOneDate.remove(0);}%>
		</table>
	  </td>
    </tr>
    <%}//else{

	if (ConversionTable.compareDate(WI.getTodaysDate(1),WI.fillTextValue("subs_date")) != -1){ 
		strTemp = WI.fillTextValue("chk_attendance");
		if (strTemp.length() > 0) strTemp = "checked";
	%>
	
    <tr>
      <td height="35">&nbsp;</td>
      <td height="35" colspan="2" valign="middle"><input name="chk_attendance" type="checkbox" id="chk_attendance" value="1" <%=strTemp%>>  
        <font size="1">check substitute faculty attendance for the day </font></td>
    </tr>
	<%//} //end Date Comparison %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Click to show list of faculties available for 
        the schedule <a href="javascript:ShowList();"><img src="../../../images/show_list.gif" border="0"></a>	
      </td>
    </tr>
    <%}%>
  </table>
<%}//only if vSubHandled != null
if(vFacAvailable != null && vFacAvailable.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="7" align="center" class="thinborder" bgcolor="#B9B292"><strong>LIST 
        OF FACULTY CAN SUBSTITUTE</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="20%" height="25" class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="24%" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="20%" class="thinborder"><strong><font size="1">COLLEGE</font></strong></td>
      <td width="20%" class="thinborder"><strong><font size="1">DEPARTMENT</font></strong></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">LOAD</font></strong></div></td>
      <td width="9%" class="thinborder"><font size="1"><strong>HOUR TO SUBS</strong></font></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">ASSIGN</font></strong></div></td>
    </tr>
    <%
for(int i = 0; i < vFacAvailable.size(); i += 7){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" class="thinborder"><%=(String)vFacAvailable.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vFacAvailable.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vFacAvailable.elementAt(i + 3),"N/A")%></td>
      <td class="thinborder"><%=WI.getStrValue(vFacAvailable.elementAt(i + 4),"N/A")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(vFacAvailable.elementAt(i + 5),"0.00")%></td>
      <td class="thinborder">
	  <input type="text" name="<%=(String)vFacAvailable.elementAt(i)%>" value="<%=(String)vFacAvailable.elementAt(i + 6)%>"
	  size="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td class="thinborder" align="center"><a href='javascript:Assign(<%=(String)vFacAvailable.elementAt(i)%>);'><img src="../../../images/assign.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="show_list">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
