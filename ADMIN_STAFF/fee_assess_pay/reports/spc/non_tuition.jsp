<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function ShowProcessing()
{
	imgWnd=
	window.open("../../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	imgWnd.focus();
	return true;
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}
</script>

<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<%@ page language="java" import="utility.*,enrollment.SPC, java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//authenticate user access level
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth.get("FEE ASSESSMENT & PAYMENTS") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

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



Vector vRetResult   = null;
SPC  spc = new SPC();

if (WI.fillTextValue("date_from").length() > 0 && WI.fillTextValue("generate_").length() > 0){
	vRetResult = spc.getNonTuitionCollection(dbOP, request);
	if ( vRetResult != null)
		strErrMsg = " Non-Tuition Fee Collection Generated Successfully.";
	else
		strErrMsg= spc.getErrMsg();
}
%>
<form name="form_" action="./non_tuition.jsp" method="post" onSubmit="SubmitOnceButton(this);return ShowProcessing();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: PAYMENT - NON-TUITION (OTHER SCHOOL FEES) ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr style="font-weight:bold;">
      <td width="6%" height="25">&nbsp;</td>
      <td colspan="4" style="font-size:18px">		Payment Date: 
	  <input name="date_from" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_from")%>" class="textbox" style="font-size:18px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>

-

	  <input name="date_to" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_to")%>" class="textbox" style="font-size:18px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>

	  </td>
    </tr>
    <tr>
      <td height="60">&nbsp;</td>
      <td width="8%" align="center">&nbsp;</td>
      <td width="54%" align="center" valign="bottom">
	  
	  <input type="submit" name="122" value="Generate Payment (Non-Tuition Payments)" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.generate_.value='1';ShowProcessing();">
	  </td>
      <td width="25%" align="center">&nbsp;</td>
      <td width="7%" align="center">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="25" colspan="9" style="font-weight:bold; font-size:16px;">Header Information
		  </td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="25" colspan="9">
		  <%
		  Vector vHeader = (Vector)vRetResult.remove(0);
		  %>
		  <textarea rows="50" cols="150" style="font-size:11px; background-color:#dddddd"><%while(vHeader.size() > 0) {%><%=vHeader.remove(0)%>,<%=vHeader.remove(0)%>,<%=vHeader.remove(0)%>,<%=vHeader.remove(0)%>,<%=vHeader.remove(0)%>,<%=vHeader.remove(0)%>,<%=vHeader.remove(0)%>
<%}%></textarea>
		  </td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="25" colspan="9" style="font-weight:bold; font-size:16px;">Detail Information
		  </td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="25" colspan="9">
		  <%
		  vHeader = (Vector)vRetResult.remove(0);
		  %>
		  <textarea rows="50" cols="150" style="font-size:11px; background-color:#FFFF99"><%while(vHeader.size() > 0) {%><%=vHeader.remove(0)%>,<%=vHeader.remove(0)%>,<%=vHeader.remove(0)%>,<%=vHeader.remove(0)%>
<%}%></textarea>
		  </td>
		</tr>
	</table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="generate_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
