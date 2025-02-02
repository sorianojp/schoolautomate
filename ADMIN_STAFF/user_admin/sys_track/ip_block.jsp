<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Untitled Document</title>
</head>
<%@ page language="java" import="utility.*, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administration-User Visit Log","access_log_main.jsp");
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
														"System Administration","System Tracking",request.getRemoteAddr(),
														"access_log_main.jsp");
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

AccessSecurityLog aSL = new AccessSecurityLog();
Vector vRetResult = aSL.viewAccessLogUserSummary(dbOP, null);
if(vRetResult == null) 
	strErrMsg = aSL.getErrMsg();
%>

<body topmargin="0">
<form>
<table border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td width="8" height="24" background=".././../../images/tableft.gif" bgcolor="#A9B9D1">&nbsp;</td>
    <td width="160" bgcolor="#00468C" align="center"  class="tabFont"><a href="access_log_main.jsp">Todays Visit Log Summary</a></td>
    <td width="10" background=".././../../images/tabright.gif" bgcolor="#A9B9D1">&nbsp;</td>
    <td width="8" height="24" background=".././../../images/tableft.gif" bgcolor="#A9B9D1">&nbsp;</td>
    <td width="116" bgcolor="#00468C" align="center" class="tabFont"><a href="access_log.jsp">Visit Log</a> </td>
    <td width="8" background=".././../../images/tabright.gif" bgcolor="#A9B9D1">&nbsp;</td>
    <td width="8" height="24" background=".././../../images/tableft_selected.gif" bgcolor="#A9B9D1">&nbsp;</td>
    <td width="114" bgcolor="#A9B9D1" align="center" class="tabFont"><a href="ip_block.jsp">Block IP Access</a> </td>
    <td width="8" background=".././../../images/tabright_selected.gif" bgcolor="#A9B9D1">&nbsp;</td>
  </tr>
</table>
<%if(strErrMsg != null) {%>
<table border="0" cellspacing="0" cellpadding="0" >
 <tr>
	<td><font style="font-size:14px; color:#FF0000; font-weight:bold;"><%=strErrMsg%></font></td>
 </tr>
</table>
<%}
if(vRetResult != null) {%>
<table border="0" cellspacing="0" cellpadding="0" width="100%" class="thinborder">
 <tr bgcolor="#99CCFF">
	<td height="22" width="18%" style="font-size:11px; font-weight:bold" class="thinborder">User ID</td>
	<td width="67%" style="font-size:11px; font-weight:bold" class="thinborder">Module - Sub Module Name</td>
	<td width="15%" style="font-size:11px; font-weight:bold" class="thinborder">Number of Times Accessed</td>
 </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 3){%>
  <tr>
	<td height="22" class="thinborder"><%=vRetResult.elementAt(i)%></td>
	<td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
	<td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>

 </tr>
<%}%>

</table>
<%}%>
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>