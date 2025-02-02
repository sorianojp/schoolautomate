<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_gd_.page_action.value =strAction;
	if(strAction == 1)
		document.form_gd_.hide_save.src = "../../../images/blank.gif";
	document.form_gd_.submit();
}
function ReloadPage() {
	document.form_gd_.page_action.value = "";
	document.form_gd_.submit();
}
function CancelRecord(strEmpID){
	location = "./graduation_data.jsp?stud_id="+document.form_gd_.stud_id.value+"&parent_wnd="+document.form_gd_.parent_wnd.value;
}

function FocusID() {
	document.form_gd_.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_gd_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CloseWindow()
{
	eval("window.opener.document."+document.form_gd_.parent_wnd.value+".submit()");
	window.opener.focus();
	self.close();
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.EntranceNGraduationData,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	Vector vStudInfo = null;
	boolean bolShowEditInfo = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-ENTRANCE DATA","graduation_data.jsp");
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
														"Registrar Management","ENTRANCE DATA",request.getRemoteAddr(),
														"graduation_data.jsp");
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

//end of authenticaion code.
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
Vector vRetResult = null;

if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	int iAction = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_action"),"4"));//default = 4, view all.
	EntranceNGraduationData graduationData = new EntranceNGraduationData();
	vRetResult = graduationData.operateOnGraduationData(dbOP, request,iAction);
	if(vRetResult == null || vRetResult.size() ==0)
		strErrMsg = graduationData.getErrMsg();
	else {
		if(iAction == 1) {
			strErrMsg = "Graduation Data saved successfully.";
		}
		else if(iAction == 2) {
			strErrMsg = "Graduation Data information changed successfully.";
		}
	}
}

strTemp = WI.getStrValue(WI.fillTextValue("new_id_entered"),"0");

if(vRetResult != null && vRetResult.size() > 0 && strTemp.compareTo(WI.fillTextValue("stud_id")) != 0)
	bolShowEditInfo = true;

String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
%>

<form name="form_gd_" action="./graduation_data.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          GRADUATION DATA PAGE ::::</strong></font></div></td>
    </tr>
<%
if(WI.fillTextValue("parent_wnd").length() > 0){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="4" ><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a>
        <font size="1"><strong>Click to close window</strong></font></td>
    </tr>
<%}%>    <tr>
      <td width="4%" height="25" >&nbsp;</td>
      <td height="25" colspan="4" ><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td width="4%" height="25" >&nbsp;</td>
      <td width="15%" height="25" >Student ID :</td>
      <td width="20%" > <input name="stud_id" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
		value="<%=WI.fillTextValue("stud_id")%>"></td>
      <td width="7%" >&nbsp; <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="54%" ><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td colspan="5" height="25" ><hr size="1"></td>
    </tr>
    <% if(vStudInfo != null && vStudInfo.size() > 0){//outer loops%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="4" >Student name : <strong> <%=WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),
	  	(String)vStudInfo.elementAt(2),4)%> 
		<input type="hidden" name="fname" value="<%=(String)vStudInfo.elementAt(0)%>">
		<input type="hidden" name="mname" value="<%=(String)vStudInfo.elementAt(1)%>">
		<input type="hidden" name="lname" value="<%=(String)vStudInfo.elementAt(2)%>">
		<%if(vStudInfo.elementAt(16) == null || ((String)vStudInfo.elementAt(16)).compareTo("0") == 0) {%>
		<input type="hidden" name="gender" value="0">
		<%}else{%>
		<input type="hidden" name="gender" value="1">
		<%}%>
		</strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="4" height="25" >Year : <strong><%=WI.getStrValue(vStudInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="4" height="25" >Course /Major: <strong><%=(String)vStudInfo.elementAt(7)%>
		 <input type="hidden" name="course_index" value="<%=(String)vStudInfo.elementAt(5)%>">
 		 <input type="hidden" name="major_index" value="<%=(String)vStudInfo.elementAt(6)%>">
        <%
		  if(vStudInfo.elementAt(8) != null){%>
        / <%=WI.getStrValue(vStudInfo.elementAt(8))%>
        <%}%>

        </strong></td>
    </tr>
    <tr>
      <td colspan="5" height="25" ><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" ><u><strong>Graduation Data</strong></u></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="31%" height="25" >CHED Special Order No.</td>
      <td width="63%" height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(6);
else
	strTemp = WI.fillTextValue("ched_special_no");
%> <input name="ched_special_no" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Date Issued</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(7);
else
	strTemp = WI.fillTextValue("csn_issue_date");
%> <input name="csn_issue_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_gd_.csn_issue_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Date of Graduation</td>
      <td height="25" > 
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(8);
else
	strTemp = WI.fillTextValue("grad_date");
%> <input name="grad_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_gd_.grad_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >SEMESTER</td>
      <td height="25" >
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(11);
else
	strTemp = WI.fillTextValue("semester");
if(strTemp == null)
	strTemp = "";
%>	  <select name="semester" >
          <option  value="">&nbsp;</option>
          <% if (strTemp.compareTo("0") == 0){%>
          <option  value="0" selected>Summer</option>
          <%}else {%>
          <option value="0">Summer</option>
          <%}if (strTemp.compareTo("1") == 0) {%>
          <option  value="1" selected>1st</option>
          <%}else {%>
          <option value="1">1st</option>
          <%}if (strTemp.compareTo("2") == 0) {%>
          <option  value="2" selected>2nd</option>
          <%}else {%>
          <option value="2">2nd</option>
          <%}if (strTemp.compareTo("3") == 0) {%>
          <option  value="3" selected>3rd</option>
          <%}else {%>
          <option value="3">3rd</option>
          <%}%>
        </select></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td><div align="center"><font size="1">
          <% if (iAccessLevel > 1){
	if(vRetResult == null || vRetResult.size() == 0) {%>
          <a href="javascript:PageAction(1);"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
          click to save entries
          <%}else{%>
          <a href='javascript:CancelRecord()'><img src="../../../images/cancel.gif" border="0"></a>
		  click to cancel and clear entries
		  <a href="javascript:PageAction(2);"><img src="../../../images/edit.gif" border="0"></a>
          click to save changes
          <%}
		}%></font>
        </div></td>
      <td width="17%">&nbsp;</td>
    </tr>
  </table>
<%}//end if vStudInfo is not null%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="new_id_entered" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="parent_wnd" value="<%=WI.fillTextValue("parent_wnd")%>">
<%
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(13) != null){%>
<input type="hidden" name="info_index" value="<%=(String)vRetResult.elementAt(13)%>">
<%}%>
 </form>
</body>
</html>
<%//System.out.println(vRetResult);
dbOP.cleanUP();
%>
