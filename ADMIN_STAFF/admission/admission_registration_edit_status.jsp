<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,enrollment.NAApplicationForm,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript">
function EditRecord()
{
	document.offlineRegd.close_wnd_called.value = "1";
	document.offlineRegd.editRecord.value = "1";
	this.ReloadPage();
}
function ReloadPage() {
	document.offlineRegd.close_wnd_called.value = "1";
	document.offlineRegd.submit();
}
function ReloadParentWnd() {
	if(!window.opener)
		return;

	if(document.offlineRegd.donot_call_close_wnd.value.length >0)
		return;
	if(document.offlineRegd.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
		window.opener.focus();
	}
}

function CloseWindow(){
	document.offlineRegd.close_wnd_called.value = "1";
	
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();
}

</script>

<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<%
	Vector vTemp = new Vector();	
	String strCourseIndex = null;
	String strMajorIndex = null;
	String strErrMsg = "";
	String strTemp = null;
	String strStudStatus = null;
	String strSYTo = null; // this is used in
	int i=0; int j=0;
	boolean bolProceed = false;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Registration","admission_registration_edit_status.jsp");
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
														"Admission","Registration",request.getRemoteAddr(),
														"admission_registration.jsp");													
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
}//end of authenticaion code.
	
OfflineAdmission offlineAdm = new OfflineAdmission();
Vector vecRetResult = new Vector();
if(request.getParameter("editRecord") != null && request.getParameter("editRecord").compareTo("1") ==0)
{//addrecord now.
	if(!offlineAdm.editTempStudStatus(dbOP,request))
		strErrMsg = offlineAdm.getErrMsg();
	else
		strErrMsg = "Student basic information for enrollment process is edited successfully. reference ID = "+request.getParameter("stud_id");
}


Vector vStudBasicInfo = offlineAdm.getBasicEnrolleeInfo(dbOP, request.getParameter("stud_id"));
if(vStudBasicInfo == null) 
	strErrMsg = offlineAdm.getErrMsg();	
else {
	strStudStatus = (String)vStudBasicInfo.elementAt(5);
}
if(WI.fillTextValue("proceed_clicked").compareTo("1") == 0)
	bolProceed = true;

%>
<form action="./admission_registration_edit_status.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="6" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ADMISSION - REGISTRATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" width="1%"></td>
      <td width="88%" height="25" colspan="4"> <%if(strErrMsg != null){%> <strong><%=strErrMsg%></strong> &nbsp; <%}%> </td>
      <td width="11%" height="25">&nbsp;
	 <% if (WI.fillTextValue("opner_form_name").length() > 0){%>
	  <a href="javascript:CloseWindow();">
	  	<img src="../../images/close_window.gif" width="71" height="32" border="0" align="right"></a>
	 <%}%>	  </td>
    </tr>
  </table>
<%
if(vStudBasicInfo != null){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
    
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="16%" height="25">Student Status </td>
      <td width="20%" height="25">
		<select name="stud_status"  onChange="document.offlineRegd.editRecord.value='';document.offlineRegd.submit();"> 
		   <option value="New">New</option>
			<%
			strTemp = WI.fillTextValue("stud_status");
			if(strTemp.length() == 0) 
				strTemp = strStudStatus; 
			else	
				strStudStatus = strTemp;
				
			if(strTemp.equals("Transferee"))
				strErrMsg = "selected";
			else	
				strErrMsg = "";
			%>
					  <option value="Transferee" <%=strErrMsg%>>Transferee</option>
			<%
			if(strTemp.equals("Second Course"))
				strErrMsg = "selected";
			else	
				strErrMsg = "";
			%>
					  <option value="Second Course" <%=strErrMsg%>>Second Course</option>
			<%
			if(strTemp.equals("Cross Enrollee"))
				strErrMsg = "selected";
			else	
				strErrMsg = "";
			%>
					  <option value="Cross Enrollee" <%=strErrMsg%>>Cross Enrollee</option>
	   </select>	  </td>
      <td width="63%" height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <%if(strStudStatus.compareTo("Transferee") ==0 || strStudStatus.compareTo("Second Course") ==0 || strStudStatus.compareTo("New") ==0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4" height="26"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" valign="bottom">Previous school</td>
      <td height="25" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom"> 
<%
	strTemp = WI.fillTextValue("prev_sch_name");
	if(strTemp.length() ==0  || bolProceed)
		strTemp = WI.getStrValue(vStudBasicInfo.elementAt(19));
%> <select name="sch_index">
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> </select> </td>
    </tr>
<%if(strStudStatus.compareTo("Transferee") ==0 || strStudStatus.compareTo("Second Course") ==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Previous course</td>
      <td height="25" valign="bottom">Major </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> <%
	strTemp = WI.fillTextValue("prev_course");
	if(strTemp.length() ==0  || bolProceed)
		strTemp = WI.getStrValue(vStudBasicInfo.elementAt(15));
%> <input name="prev_course" type="text" size="40" maxlength="90" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td height="25"> <%
	strTemp = WI.fillTextValue("prev_major");
	if(strTemp.length() ==0  || bolProceed)
		strTemp = WI.getStrValue(vStudBasicInfo.elementAt(16));
%> <input name="prev_major" type="text" size="40" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp; </td>
    </tr>
  </table>
<%}
}if(strStudStatus.equals("Cross Enrollee")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Current school</td>
      <td height="25" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom"><select name="sch_index">
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",(String)vStudBasicInfo.elementAt(19),false)%> </select> <font size="1">Click to update accredited school 
        list</font> <a href="javascript:UpdateSchoolList();"> <img src="../../images/update.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">Course</td>
      <td valign="bottom">Major </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><input name="cur_course" type="text" size="40" maxlength="128" value="<%=WI.getStrValue((String)vStudBasicInfo.elementAt(15))%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td height="25"> <input name="cur_major" type="text" size="40" maxlength="128" value="<%=WI.getStrValue((String)vStudBasicInfo.elementAt(16))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp; </td>
    </tr>
  </table>
<%}%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">

    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
<%
if(iAccessLevel > 1){%>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="7">&nbsp;</td>
      <td width="29%" height="25"><a href="javascript:EditRecord();"><img src="../../images/edit.gif" border="0"></a>
        <font size="1" >click to edit entries</font></td>
      <td width="56%">&nbsp;</td>
    </tr>
<%}%>
  </table>
  <input type="hidden" name="user_index" value="<%=(String)vStudBasicInfo.elementAt(1)%>">
  <input type="hidden" name="is_tempuser" value="<%=(String)vStudBasicInfo.elementAt(0)%>">
<%}//end of displaying if vStudBasicInfo != null%>

<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="proceed_clicked" value="0">

  <input type="hidden" name="opner_form_name" value="<%=WI.fillTextValue("opner_form_name")%>">	
  <input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">	
	
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
<!-- this is very important - onUnload do not call close window -->	


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>