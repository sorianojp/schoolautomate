<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../jscript/common.js" ></script>
</head>
<script language="JavaScript">

function ReloadPage()
{
	this.SubmitOnce('form_');
}
function Inbox()
{
	location= "./webmail_main.jsp?accnt="+document.form_.accnt.value+"&pass="+document.form_.pass.value+"&host="+document.form_.host.value;
}
function DownloadFile(strMsgNum, strPartNum)
{
	location = "./downloadfile.jsp?accnt="+document.form_.accnt.value+"&pass="+document.form_.pass.value+"&host="+document.form_.host.value+"&msgnum="+strMsgNum+"&msgpart="+strPartNum;
}
</script>
<style>
a:link {
	color: #000000;
	text-decoration: none;
}
a:visited {
	color: #000000;
	text-decoration: none;

}
a:hover {
	font-weight: bold;
	color: #000000;
	text-decoration: underline;

}
a:active {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
</style>
<%@ page language="java" import="utility.*, organizer.SBWebMail, java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	int iSearchResult = 0;
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-Message Board","view_webmessage.jsp");
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
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Organizer","Message Board",request.getRemoteAddr(),
														"view_webmessage.jsp");
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
**/
//end of authenticaion code.
		SBWebMail myWebMail = new SBWebMail();
	vRetResult = myWebMail.operateOnUserWebMail(dbOP, request, response, 5);

%>
<body bgcolor="#8C9AAA" >
<form action="./view_webmessage.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="2" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          READ MESSAGE ::::</strong></font></div></td>
    </tr>
       <tr bgcolor="#DBEAF5">
   <td width="75%"><strong>&nbsp;<%=WI.getStrValue(strErrMsg, "&nbsp;")%></strong></td>
   <td width="25%" align="right"><font size="1">Go to: <a href= "javascript:Inbox()">Inbox</a>&nbsp;</td>
   </tr>
   </table>
   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr  bgcolor="#DBEAF5"> 
      <td height="10">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
	<input name="accnt" type="hidden" value="<%=WI.fillTextValue("accnt")%>">
	<input type="hidden" name="host" value="<%=WI.fillTextValue("host")%>">
	<input name="pass" type="hidden" value="<%=WI.fillTextValue("pass")%>">
	<input name="msgnum" type="hidden" value="<%=WI.fillTextValue("msgnum")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>