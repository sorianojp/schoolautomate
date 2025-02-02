<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function UpdateStatus()
{
	document.form_.toggle_status.value = "1";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,eSC.TimeInTimeOut" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameter","set_param_e_security.jsp");

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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														"set_param_e_security.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String streSecurityStat = null;
if(WI.fillTextValue("toggle_status").compareTo("1") == 0){
	TimeInTimeOut tIntOut = new TimeInTimeOut();
	if(!tIntOut.toggleeSecurityStatus(dbOP, (String)request.getSession(false).getAttribute("login_log_index")) )
		strErrMsg = tIntOut.getErrMsg();
}
streSecurityStat = dbOP.mapOneToOther("esc_status","ESECURITY_STATUS","1","ESECURITY_STATUS",null);
if(streSecurityStat != null)
	streSecurityStat = "Enabled";
else
	streSecurityStat = "Disabled";
%>
<form name="form_" action="./set_param_e_security.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          SET PARAMETERS - eSECURITY PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;</font> </td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td width="6%" height="24"><font size="3">&nbsp;</font></td>
      <td width="58%"><strong><font size="3"> eSecurity Validation Status : 
        <font color="#0000FF"><%=streSecurityStat%></font></font></strong></td>
      <td width="36%"> <%if( iAccessLevel >1){%> <a href="javascript:UpdateStatus();"> <img src="../../images/update.gif" border="0"></a> 
        <%}%> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><strong><font  size="1">NOTE : If status is disabled, system does not generage 
        error warning for the students not enrolled in the current system. Normal 
        practice is to set off the eSecurity check during enrollment. But eSecurity 
        checks invalid IDs.</font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="toggle_status">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
