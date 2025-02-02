<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;

	if(strAction.length == 0) {
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}

	document.form_.donot_call_close_wnd.value = "1";
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";

	document.form_.donot_call_close_wnd.value = "1";
}

///////////////to reload parent window if this is closed //////////////
function CloseWindow(){
	document.form_.close_wnd_called.value = "1";

	window.opener.document.form_.submit();
	window.opener.focus();
	self.close();
}
//window.onbeforeunload = ReloadParentWnd;
function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.form_.submit();

		window.opener.focus();
	}
}

</script>

<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<%@ page language="java" import="utility.*,Accounting.Administration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","tax_code.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Administration adm = new Administration();
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(adm.operateOnTaxCode(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = adm.operateOnTaxCode(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = adm.getErrMsg();

if(strPreparedToEdit.equals("1"))
	vEditInfo = adm.operateOnTaxCode(dbOP, request, 3);


%>
<form action="./tax_code.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::CHART
          OF ACCOUNTS - TAX CODE MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" style="font-size:13px; color:#FF0000; font-weight:bold"><a href="javascript:CloseWindow();"><img src="../../../../images/close_window.gif" border="0"></a><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td width="8%" height="25">&nbsp;</td>
      <td width="16%">Tax Code</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("tax_code");
%>	  <input name="tax_code" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Tax Description</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("description");
%>	  <input name="description" type="text" size="64" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Tax Rate (%)</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("tax_rate");
%>	  <input name="tax_rate" type="text" size="3" maxlength="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','tax_rate');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','tax_rate');"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="76%"><%if(iAccessLevel > 1) {
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
		 onClick="PageAction('','');document.form_.year_fr.value='';document.form_.year_to.value='';document.form_.donot_call_close_wnd.value='1'"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="5" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST
          OF EXISTING TAX CODE</strong></font></div></td>
    </tr>
    <tr>
      <td width="20%" height="25" class="thinborder"><div align="center"><font size="1"><strong>TAX
          CODE </strong></font></div></td>
      <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>TAX DESCRIPTION</strong></font></div></td>
      <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>TAX RATE (%)</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>EDIT</strong></font></div></td>
      <td class="thinborder"><center>
        <font size="1"><strong>REMOVE</strong>        </font>
      </center></td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 4){%>
    <tr>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%> % </td>
      <td width="9%" class="thinborder">
	  <%if(iAccessLevel > 1) {%>
        <input type="submit" name="122" value="Edit" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
      <%}%></td>
      <td width="11%" class="thinborder">&nbsp;
        <%if(iAccessLevel ==2 ) {%>
        <input type="submit" name="123" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
      <%}%></td>
    </tr>
<%}%>
  </table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" width="1%">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">

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
