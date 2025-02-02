<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value = '';
	document.form_.prevent_reload.value='1';
	document.form_.submit();
}
function PageAction(strInfoIndex, strAction) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this entry.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	
	document.form_.prevent_reload.value='1';
	document.form_.is_modified.value='1';
	
	document.form_.submit();
}
function PreparedToEdit(strInfoIndex) {
	document.form_.page_action.value = '';
	document.form_.info_index.value = strInfoIndex;
	document.form_.preparedToEdit.value = '1';
	document.form_.prevent_reload.value='1';
	document.form_.submit();
}
function ReloadParent() {
	if(	document.form_.prevent_reload.value == '1')
		return;
	if(	document.form_.is_modified.value == '')
		return;

	window.opener.document.ledger_old.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="document.form_.catg_code.focus();" onUnload="ReloadParent();">
<%@ page language="java" import="utility.*,enrollment.FAStudentLedger,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	//String[] astrConvertSem ={"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
//add security here.
	try
	{
		dbOP = new DBOperation();

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
														"Fee Assessment & Payments","OLD STUDENT ACCOUNT MGMT",request.getRemoteAddr(),
														"old_student_ledger.jsp");
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

FAStudentLedger studLedger = new FAStudentLedger();
Vector vRetResult   = null; Vector vEditInfo = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(studLedger.operateOnOldLedgerCatg(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = studLedger.getErrMsg();
	else {
		strErrMsg = "Operation successful.";
		strPreparedToEdit = "0";
	}
}

//get here subject detail.
	vRetResult = studLedger.operateOnOldLedgerCatg(dbOP, request, 4);
	if(strErrMsg == null)
		strErrMsg = studLedger.getErrMsg();
	if(strPreparedToEdit.equals("1"))
		vEditInfo = studLedger.operateOnOldLedgerCatg(dbOP, request, 3);
%>
<form name="form_" action="./old_student_ledger_category.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: Old Account Particular Information ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="28" width="2%">&nbsp;</td>
      <td colspan="2"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Code </td>
      <td width="83%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("catg_code");
%>
	  <input type="text" name="catg_code" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr valign="top">
      <td height="25" width="2%">&nbsp;</td>
      <td width="15%">Particular/Description</td>
      <td> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("particular");
%>
	  <input type="text" name="particular" value="<%=WI.fillTextValue("particular")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" maxlength="64"></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
	  <a href='javascript:PageAction("","1");'><img src="../../../images/save.gif" border="0"></a>
	<%}else{%>
	  <a href='javascript:PageAction("<%=vEditInfo.elementAt(0)%>","2");'><img src="../../../images/edit.gif" border="0"></a> 
	  <a href='javascript:PageAction("","");'><img src="../../../images/cancel.gif" border="0"></a> 
	<%}%>
<%}%>	  </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="20%" height="25" class="thinborder"><font size="1"> Code </font></td>
      <td width="40%" class="thinborder"><font size="1">Description</font></td>
      <!--<td width="10%" class="thinborder"><font size="1">Edit</font></td>-->
      <td width="10%" class="thinborder"><font size="1">Delete</font></td>
    </tr>
    <%
	boolean bolIsUsed = false; String[] astrConvertTuitionType = {"Non-Tuition","Tuition"};
	
	for(int i = 0 ; i < vRetResult.size(); i += 3){	%>
    <tr>
      <td class="thinborder" height="25"><%=WI.getStrValue(vRetResult.elementAt(i + 1), "Default")%> </td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 2), "Default")%></td>
      <!--<td class="thinborder">&nbsp;
	  	<%if(iAccessLevel > 1 && !bolIsUsed){%> 
	  		<a href='javascript:PreparedToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
		<%}else if(bolIsUsed) {%>
			Already Used
		<%}%>	  </td>-->
      <td class="thinborder">&nbsp;
	  	<%if(iAccessLevel == 2 && !bolIsUsed){%> 
	  		<a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a> 
		<%}else if(bolIsUsed) {%>
			Already Used
		<%}%>	  </td>
    </tr>
    <%}%>
  </table>
<%}//end of display if vRetResult > 0%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="preparedToEdit">

<input type="hidden" name="prevent_reload">
<input type="hidden" name="is_modified" value="<%=WI.fillTextValue("is_modified")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
