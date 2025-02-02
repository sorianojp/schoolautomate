<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.show_detail.value = "1";
	document.form_.submit();
}
function SaveInfo() {
	document.form_.page_action.value = "1";
	document.form_.submit();
}
function viewList(table,indexname,colname,labelname){
	var loadPg = "../HR/hr_updatelist.jsp?opner_form_name=form_&tablename=" + table + "&indexname=" + 
		indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,basicEdu.UserInformation,java.util.Vector,java.util.StringTokenizer" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolFatalErr = false;
	

	Vector vStudBasicInfo = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","basic_old_stud_mgmt.jsp");
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

//I have to create basic information, if it exists, edit it.
String strShowDetail = WI.fillTextValue("show_detail");

UserInformation basicUserInfo = new UserInformation();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(basicUserInfo.operateOnBasicInfo(dbOP, request, Integer.parseInt(strTemp)) == null) {
		bolFatalErr = true;
		strErrMsg = basicUserInfo.getErrMsg();
	}
	else {	
		strErrMsg = "Operation successful.";
		strShowDetail = "";
	}
}
if(WI.fillTextValue("stud_id").length() > 0) {
	vStudBasicInfo = basicUserInfo.operateOnBasicInfo(dbOP, request, 4);
	if(vStudBasicInfo == null && strErrMsg == null)
		strErrMsg = basicUserInfo.getErrMsg();
}

%>
<form name="form_" action="./basic_old_stud_mgmt.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          BASIC EDUCATION - OLD STUDENT BASIC INFO MGMT PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="38" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font>
	  </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Student ID :</td>
      <td width="28%"><input type="text" name="stud_id" size="16" maxlength="32" 
	  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="52%"><a href="javascript:ReloadPage();"><img src="../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
	</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <%
if(strShowDetail.length() > 0){%>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="3"><strong><u>CURRENT EDUCATION INFORMATION:</u></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="19%">School Name</td>
      <td width="74%"> <%
if(vStudBasicInfo != null && !bolFatalErr)
	strTemp = (String)vStudBasicInfo.elementAt(11);
else	
	strTemp = WI.fillTextValue("sch_index");
%> <select name="sch_index">
          <%=dbOP.loadCombo("SCH_INDEX","SCH_NAME"," from SCHOOL_LIST order by SCH_NAME",strTemp,false)%> </select> <a href='javascript:viewList("SCHOOL_LIST","SCH_INDEX","SCH_NAME","LIST OF SCHOOL");'><img src="../../images/update.gif" border="0"></a></td>
      <td width="0%"></select>
      <td width="0%"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td> Education Level</td>
      <td> <%
if(vStudBasicInfo != null && !bolFatalErr)
	strTemp = (String)vStudBasicInfo.elementAt(12);
else	
	strTemp = WI.fillTextValue("g_level");//System.out.println(strTemp);
%> <select name="g_level">
          <%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",strTemp,false)%> </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Curriculum Year</td>
      <td>
        <%
if(vStudBasicInfo != null && !bolFatalErr)
	strTemp = (String)vStudBasicInfo.elementAt(16);
else	
	strTemp = WI.fillTextValue("cy_from");
%>
        <input type="text" name="cy_from" value="<%=strTemp%>" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        - 
        <%
if(vStudBasicInfo != null && !bolFatalErr)
	strTemp = (String)vStudBasicInfo.elementAt(17);
else	
	strTemp = WI.fillTextValue("cy_to");
%>
        <input type="text" name="cy_to" value="<%=strTemp%>" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>School Year</td>
      <td> <%
if(vStudBasicInfo != null && !bolFatalErr)
	strTemp = (String)vStudBasicInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("sy_from");
%> <input type="text" name="sy_from" value="<%=strTemp%>" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
if(vStudBasicInfo != null && !bolFatalErr)
	strTemp = (String)vStudBasicInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("sy_to");
%> <input type="text" name="sy_to" value="<%=strTemp%>" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes"></td>
    </tr>
    <tr> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="3"><strong><u>ENTRY INFORMATION :</u></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="19%">Entry Status</td>
      <td width="74%"> <%
if(vStudBasicInfo != null && !bolFatalErr)
	strTemp = (String)vStudBasicInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("status_index");
%> <select name="status_index">
          <%=dbOP.loadCombo("status_index","status"," from user_status where status <> 'old' and "+
	"status not like '%c%' and is_for_student = 1 order by status asc",strTemp, false)%> </select></td></select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Age Upon Entry</td>
      <td> <%
if(vStudBasicInfo != null && !bolFatalErr)
	strTemp = (String)vStudBasicInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("age");
%> <input type="text" name="age" value="<%=strTemp%>" size="2" maxlength="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        years </td>
    </tr>
    <tr> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><strong><u>PERSONAL INFORMATION :</u></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Lastname </td>
      <td> <%
if(vStudBasicInfo != null && !bolFatalErr)
	strTemp = (String)vStudBasicInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("lname");
%> <input name="lname" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Firstname</td>
      <td> <%
if(vStudBasicInfo != null && !bolFatalErr)
	strTemp = (String)vStudBasicInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("fname");
%> <input name="fname" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="23">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Middlename</td>
      <td> <%
if(vStudBasicInfo != null && !bolFatalErr)
	strTemp = (String)vStudBasicInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("mname");
%> <input name="mname" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Date of Birth</td>
      <td> <%
String strMM   = WI.fillTextValue("mm");
String strDD   = WI.fillTextValue("dd");
String strYYYY = WI.fillTextValue("yyyy");
if(vStudBasicInfo != null && !bolFatalErr) {
	strTemp = (String)vStudBasicInfo.elementAt(7);
	StringTokenizer strToken = new StringTokenizer(strTemp, "/");
	if(strToken.hasMoreElements())
		strMM =(String)strToken.nextElement();
	if(strToken.hasMoreElements())
		strDD =(String)strToken.nextElement();
	if(strToken.hasMoreElements())
		strYYYY =(String)strToken.nextElement();
}
%> <input type="text" name="mm" value="<%=strMM%>" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        / 
        <input type="text" name="dd" value="<%=strDD%>" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        / 
        <input type="text" name="yyyy" value="<%=strYYYY%>" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <font size="1">(mm/dd/yyyy) </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Gender </td>
      <td><select name="gender">
          <%
if(vStudBasicInfo != null && !bolFatalErr)
	strTemp = (String)vStudBasicInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("gender");
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
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td height="40">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><div align="center"> 
          <%if(vStudBasicInfo != null && vStudBasicInfo.size() > 0){%>
          <a href="javascript:SaveInfo();"><img src="../../images/edit.gif" border="0"></a><font size="1">click 
          to edit entries </font> 
          <%}else{%>
          <a href="javascript:SaveInfo();"><img src="../../images/save.gif" border="0"></a><font size="1">click 
          to save entries </font> 
          <%}%>
          <a href="./basic_old_stud_mgmt.jsp"><img src="../../images/cancel.gif" border="0"></a> 
          <font size="1">click to cancel/clear entries </font></div></td>
    </tr>
    <%}//if iAccessLevel > 1
 
 }//only if strShowDetail.length() > 0%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="show_detail" value="<%=strShowDetail%>">
<input type="hidden" name="page_action">
<%
if(vStudBasicInfo != null && vStudBasicInfo.size() > 0){%>
<input type="hidden" name="user_index" value="<%=(String)vStudBasicInfo.elementAt(0)%>">
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>