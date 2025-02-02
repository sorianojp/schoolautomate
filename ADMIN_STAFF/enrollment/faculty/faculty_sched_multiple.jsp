<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");	
if (strSchCode == null)
	strSchCode = "";
boolean bolSWU = strSchCode.startsWith("SWU");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript">
function copyValueToParent()
{
	eval('window.opener.document.faculty_page.'+document.facschedule.opner_fac_index.value+'.value='+document.facschedule.fac_index.value);
	eval('window.opener.document.faculty_page.'+document.facschedule.opner_fac_name.value+'.value=\"'+document.facschedule.fac_name.value+'\"');
	//window.opener.document.faculty_page.name0.value="45";
	
	window.close();
}

function ReloadParentWindow(){
	if(document.form_.close_window.value.length > 0)
		return;
	
	window.opener.document.faculty_page.close_window.value = "1";
	window.opener.document.faculty_page.submit();
}

function PageAction(strAction, strInfoIndex) {
	
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.close_window.value = "1";
	document.form_.submit();
}

function AddBreak(e, strField){
	if(e == 13){
		var strValue = eval('document.form_.'+strField+'.value');
		strValue += "<br>";
		
		strField = eval('document.form_.'+strField);
		strField.value = strValue;
	}
}

function SetIsMain(strLoadIndex){
	document.form_.set_is_main.value = strLoadIndex;
}

</script>
<body bgcolor="#D2AE72" onUnload="ReloadParentWindow();">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean[] bolConflict = {false}; // this is passed to getSubjectScheduleTime to check if the subject is conflict with the previous



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
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-LOADING"),"0"));
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
								"Admin/staff-Enrollment-Faculty-schedule","faculty_sched_multiple.jsp");
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
														"faculty_sched_multiple.jsp");
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

Vector vFacultyList  = new Vector();
FacultyManagement FM = new FacultyManagement();

//I have to first save if it is called from proceed.
if(WI.fillTextValue("fac_index").length() > 0) {
	if(FM.operateOnMultipleFacultyLoad(dbOP, request, -1) == null)
		strErrMsg = FM.getErrMsg();
}
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(FM.operateOnMultipleFacultyLoad(dbOP, request, Integer.parseInt(strTemp) ) == null)
		strErrMsg = FM.getErrMsg();
	else	
		strErrMsg = "Faculty Load adjusted successfully.";
}
	
vFacultyList = FM.operateOnMultipleFacultyLoad(dbOP, request,4, true);
//System.out.println("Faculty List : "+vFacultyList);
%>

<form name="form_" action="./faculty_sched_multiple.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FACULTY PAGE - LOADING ADJUST PAGE::::</strong></font></div></td>
    </tr>
<%
if(strErrMsg != null) {%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><font size="3"><b><%=strErrMsg%></b></font></td>
    </tr>
    <%}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="16%">Subject Name(code) : </td>
	  <td width="82%"><b><%=request.getParameter("subject")%></b></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="16%"> Unit :</td>
      <td colspan="2"><b><%= request.getParameter("LECLAB")%> 
	  <%=request.getParameter("total_unit")%></b></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Schedule : <b></b></td>
      <td width="31%" valign="top"><b><%=request.getParameter("schedule")%></b></td>
      <td width="51%" valign="top">Room #: <b><%=WI.fillTextValue("room_no")%></b></td>
    </tr>


    <tr>
      <td colspan="4" height="25">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td width="97%" height="25" colspan="9"><div align="center"><strong><font color="#FFFFFF">LOAD 
          DISTRIBUTION DETAIL</font></strong></div></td>
    </tr>
  </table>
<%
if(vFacultyList != null && vFacultyList.size() > 0){%>  
	
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
		<td width="4%" align="center"><strong><font size="1">MAIN<br>FACULTY</font></strong></td>
      	<td width="39%" height="25"><div align="center"><font size="1"><strong>FACULTY NAME </strong></font></div></td>	  
	  <%if(bolSWU){%>
      <td width="22%"><div align="center"><font size="1"><strong>FACULTY 
          SCHEDULE </strong></font></div></td>
	<%}%>
      <td width="9%" align="center" height="25"><font size="1"><strong>LOAD<br>SHARE</strong></font></td>
      <td width="8%" align="center" style="font-size:9px; font-weight:bold">LOAD<br>HOUR </td>
      <td width="9%" align="center"><font size="1"><strong>TOTAL<br>LOAD</strong></font></td>
      <td width="9%" align="center"><font size="1"><strong>DELETE </strong></font></td>
    </tr>
    <%
int j = 0; 
int iIncrement = 8;

 for(int i = 0 ; i< vFacultyList.size(); i += iIncrement,++j){%>
    <tr> 
      
      <%	  
	  	strTemp = WI.getStrValue((String)vFacultyList.elementAt(i+7),"0");		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";	 
	  %>
      <td height="25" align="center">
	  	<input type="radio" name="is_main_faculty" value="1" <%=strErrMsg%> onClick="SetIsMain('<%=(String)vFacultyList.elementAt(i)%>')">
	  </td>
	  <td height="25"><%=(String)vFacultyList.elementAt(i + 2)%></td>
      <%if(bolSWU){
	strTemp = (String)vFacultyList.elementAt(i + 6);
	if(strTemp == null)
		strTemp = WI.fillTextValue("faculty_load_sched_"+j);
%>	  
	  <td height="25" align="center">	  
		<textarea name="faculty_load_sched_<%=j%>" rows="1" 
			onKeyPress="AddBreak(event.keyCode, 'faculty_load_sched_<%=j%>')"><%=strTemp%></textarea>	  </td>
<%}%>
      <td align="center"><input type="text" name="new_load<%=j%>" maxlength="3" size="4" class="textbox"
	  value="<%=WI.getStrValue((String)vFacultyList.elementAt(i + 3))%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	 onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td align="center"><input type="text" name="new_load_hr<%=j%>" maxlength="3" size="4" class="textbox"
	  value="<%=WI.getStrValue((String)vFacultyList.elementAt(i + 5))%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	 onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td align="center">&nbsp;<%=WI.getStrValue((String)vFacultyList.elementAt(i + 4))%></td>
      <td align="center"><a href='javascript:PageAction("0","<%=(String)vFacultyList.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
	  <input type="hidden" name="load_index<%=j%>" value="<%=(String)vFacultyList.elementAt(i)%>"></td>
    </tr>
    <%}
	%>
	<input type="hidden" name="max_fac" value="<%=j%>">
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="24%">&nbsp;</td>
      <td width="76%" height="25"> <a href='javascript:PageAction("1","");'><img src="../../../images/save.gif" border="0"></a> 
        Click to save faculty load.</td>
    </tr>
  </table>
<%}//only if vFacultyLoadList is not null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<!-- not necessary 
  <input type="hidden" name="fac_name" value="<%=WI.fillTextValue("fac_name")%>">  
  <input type="hidden" name="fac_index" value="<%=WI.fillTextValue("fac_index")%>">
-->  
  <input type="hidden" name="opner_fac_name" value="<%=WI.fillTextValue("opner_fac_name")%>">
  <input type="hidden" name="opner_fac_index" value="<%=WI.fillTextValue("opner_fac_index")%>">
  
  <input type="hidden" name="multiple_assign" value="<%=WI.fillTextValue("multiple_assign")%>">
  <input type="hidden" name="sec_index" value="<%=WI.fillTextValue("sec_index")%>">
  <input type="hidden" name="LECLAB" value="<%=WI.fillTextValue("LECLAB")%>">
  <input type="hidden" name="total_unit" value="<%=WI.fillTextValue("total_unit")%>">
  <input type="hidden" name="sub_off_yrf" value="<%=WI.fillTextValue("sub_off_yrf")%>">
  <input type="hidden" name="sub_off_yrt" value="<%=WI.fillTextValue("sub_off_yrt")%>">
  <input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>">

  <input type="hidden" name="subject" value="<%=WI.fillTextValue("subject")%>">
  <input type="hidden" name="room_no" value="<%=WI.fillTextValue("room_no")%>">
  <input type="hidden" name="schedule" value="<%=WI.fillTextValue("schedule")%>">


<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="close_window" value="">

<input type="hidden" name="faculty_schedule">
<input type="hidden" name="set_is_main" value="<%=WI.fillTextValue("set_is_main")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
