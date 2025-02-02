<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	document.form_.close_wnd_called.value = "1";

	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
}
function PreparedToEdit(strInfoIndex) {
	document.form_.close_wnd_called.value = "1";

	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}

<!-- Reload parent window when closed -->
function CloseWindow(){
	document.form_.close_wnd_called.value = "1";
	
	window.opener.document.form_.focus_field.value = "focusCourseR";
	window.opener.document.form_.submit();
	window.opener.focus();
	
	window.close();
}
function ReloadParentWnd() {
	if(document.form_.close_wnd_called.value == "1")
		return;
	window.opener.document.form_.focus_field.value = "focusCourseR";
	window.opener.document.form_.submit();
	window.opener.focus();
}
</script>
<body bgcolor="#93B5BB" onUnload="ReloadParentWnd();">
<%@ page language="java" import="utility.*,ClassMgmt.CMSyllabusNew,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Faculty Acad-Syllabus","course_requirements.jsp");
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
int iAccessLevel = 2;

CMSyllabusNew cmsNew = new CMSyllabusNew();
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cmsNew.operateOnCourseRequirement(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = cmsNew.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = cmsNew.operateOnCourseRequirement(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = cmsNew.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = cmsNew.operateOnCourseRequirement(dbOP, request, 3);

%>
<form action="./course_requirements.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#6A99A2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          SYLLABUS MAINTENANCE - COURSE REQUIREMENTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;<a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a> <font style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="12%" height="25">&nbsp; </td>
      <td width="88%">Requirements/Evaluation Column Entry : </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("requirement");
%>	  <textarea name="requirement" cols="65" rows="3" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr> 
      <td height="42">&nbsp;</td>
      <td>Percentage : 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("percentage");
%>        <input name="percentage" type="text" size="12" maxlength="12" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        (NOTE: Can be empty if no percentage required. Can accept alphanumeric. 
        This is not use for any computation, this is purely informative)</td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>
        <%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<input type="submit" name="12" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.book_name.value='';document.form_.author.value=''; document.form_.edition.value=''">
      </td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="4" class="thinborder"><div align="center"><strong><font color="#0000FF">:: 
          COURSE REQUIREMENTS ::</font></strong></div></td>
    </tr>
    <tr> 
      <td width="60%" height="25" class="thinborder"><strong><font size="1">REQUIREMENTS/EVALUATION 
          </font></strong></td>
      <td width="25%" class="thinborder"><strong><font size="1">PERCENTAGE</font></strong></td>
      <td width="7%" class="thinborder">&nbsp;</td>
      <td width="8%" class="thinborder">&nbsp;</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 3){%>
    <tr> 
      <td height="25" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 1), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 2), "&nbsp;")%></td>
      <td class="thinborder"><%if(iAccessLevel > 1){%>
        <input type="submit" name="122" value=" Edit " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
        <%}else{%>
        &nbsp;
      <%}%></td>
      <td class="thinborder"><%if(iAccessLevel ==2 ){%>
        <input type="submit" name="123" value="Delete" style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
        <%}else{%>
        &nbsp;
      <%}%></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25" valign="bottom">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#6A99A2">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">

<input type="hidden" name="sub_index" value="<%=WI.fillTextValue("sub_index")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">

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