<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
</script>
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	Vector vRetResult = null;
	Vector vEditInfo  = null;
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit = null;
	String strInfoIndex = WI.fillTextValue("info_index");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW",
								"subtype_create.jsp");
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
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",
														request.getRemoteAddr(), "subtype_create.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","Exam SubType",
														request.getRemoteAddr(), "subtype_create.jsp");
}

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
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(appMgmt.operateOnExamName(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = appMgmt.getErrMsg();
	}


	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = appMgmt.operateOnExamName(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null )
			strErrMsg = appMgmt.getErrMsg();
	}
	//view all
	vRetResult = appMgmt.operateOnExamName(dbOP, request, 4);
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./subtype_create.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF">::::
          ENTRANCE EXAMINATION/INTERVIEW SUBTYPE CREATION PAGE::::</font></strong></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td height="31">&nbsp;</td>
      <td>Exam Type </td>
      <td><select name="m_exam_index">
        <option value="0" selected>Written</option>
        <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("m_exam_index");
if(strTemp.compareTo("1") == 0) {
%>
        <option value="1" selected>Interview</option>
        <%}else{%>
        <option value="1">Interview</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td width="2%" height="30">&nbsp;</td>
      <td width="20%">Exam Subtype </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("exam_sub");
%>
	  <input name="exam_sub" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="32" value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="78%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Maximum Score/ Rate </td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("max_scr");
%>
        <input name="max_scr" type="text" class="textbox" value="<%=strTemp%>"
         onKeyUp= 'AllowOnlyInteger("form_","max_scr")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","max_scr");style.backgroundColor="white"' size="4" maxlength="4"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Passing Score/ Rate </td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("pass_scr");
%>
<input name="pass_scr" type="text"  class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
		  onKeyUp= 'AllowOnlyInteger("form_","pass_scr")' onFocus="style.backgroundColor='#D3EBFF'"
		  onblur='AllowOnlyInteger("form_","pass_scr");style.backgroundColor="white"'></td>
    </tr>
<% if(iAccessLevel > 1) {%>
    <tr>
      <td height="43">&nbsp;</td>
      <td height="43">&nbsp;</td>
      <td height="43" valign="bottom"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> Click to save entries
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> Click to edit event
        <%}%>
        <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> Click to clear entries </font></td>
    </tr>
<%}//only if authorized.%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="6"><div align="center"><strong><font color="#FFFFFF" size="1">LIST
          OF EXAMINATION SUBTYPES </font></strong></div></td>
    </tr>
    <tr>
      <td width="28%" height="25"><div align="center"><strong><font size="1">EXAMINATION TYPE</font></strong>
        <div align="center"><strong><font size="1"> </font></strong></div>
      </div></td>
      <td width="28%" height="25"><div align="center"><strong><font size="1">EXAMINATION SUBTYPE</font></strong></div></td>
      <td width="14%"><div align="center"><strong><font size="1">Maximum Score/ Rate </font></strong></div></td>
      <td width="13%"><div align="center"><strong><font size="1">Passing Score/ Rate </font></strong></div></td>
      <b>      </b>
      <td colspan="2" align="center" class="thinborder"><b><font size="1">OPTIONS</font></b></td>
    </tr>
    <% String [] astrConvType={"Written","Interview"};
for(int i = 0 ; i< vRetResult.size(); i += 5){%>
    <tr>
      <td><div align="center"><%=astrConvType[Integer.parseInt((String)vRetResult.elementAt(i + 1))]%></div></td>
      <td><div align="center"><%=(String)vRetResult.elementAt(i+2)%></div></td>
      <td><div align="center"><%=(String)vRetResult.elementAt(i+3)%></div></td>
      <td><div align="center"><%=(String)vRetResult.elementAt(i+4)%></div></td>
      <td width="8%" align="center" class="thinborder"> <font size="1">
<% if(iAccessLevel ==2 || iAccessLevel == 3){%>
<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
<%}else{%>
        Not authorized to edit
        <%}%>
        </font></td>
      <td width="9%" align="center" class="thinborder"> <font size="1">
        <% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        Not authorized to delete
        <%}%>
        </font></td>
    </tr>
    <%}%>
  </table>
<%}//if vRetResult != null%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input name = "info_index" type = "hidden"  value="<%=strInfoIndex%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<% dbOP.cleanUP();
%>
