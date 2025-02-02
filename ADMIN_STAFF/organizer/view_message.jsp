<%
if(request.getSession(false).getAttribute("userId") == null){%>
<font style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
	Please login to access this link.
</font>
<%return;
}%>
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
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function Send(strInfoIndex, strPassType) 
{
	location = "./send_msg.jsp?info_index="+strInfoIndex+"&pass_type="+strPassType+"&box_type=1"+"&viewAll=1";
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
<%@ page language="java" import="utility.*, organizer.SBEmail, java.util.Vector " %>
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
								"Admin/staff-Organizer-Message Board","view_message.jsp");
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
														"view_message.jsp");
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
	SBEmail myMailBox = new SBEmail();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myMailBox.operateOnMailBox(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = myMailBox.getErrMsg();
	}
	
	vRetResult = myMailBox.operateOnMailBox(dbOP, request, 3);

	if (vRetResult == null)
		strErrMsg = myMailBox.getErrMsg();
%>
<body bgcolor="#8C9AAA" >
<form action="./view_message.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="2" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          MESSAGES ::::</strong></font></div></td>
    </tr>
       <tr bgcolor="#DBEAF5">
   <td width="75%"><strong>&nbsp;<%=WI.getStrValue(strErrMsg, "&nbsp;")%></strong></td>
   <td width="25%" align="right"><font size="1">Go to: <a href= "./my_inbox.jsp?viewAll=0&box_type=1">Inbox</a>&nbsp;/&nbsp;
   <a href="./sent_msgs.jsp?viewAll=1&box_type=2">Outbox</a>&nbsp;/&nbsp;<a href="./del_msgs.jsp?viewAll=1&box_type=0">Trash</a>&nbsp;</td>
   </tr>
   </table>
   <%if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr bgcolor="#DBEAF5">
   <td width="2.5%%" align="left" >&nbsp;</td>
   <td width="10%" align="left"><a href='javascript:PageAction("0","<%=WI.fillTextValue("info_index")%>")'>Delete</a></td>
   <td width="10%" align="left"><a href='javascript:Send("<%=WI.fillTextValue("info_index")%>","0");'>Reply</a></td>
   <td width="10%" align="left"><a href='javascript:Send("<%=WI.fillTextValue("info_index")%>","2");'>Forward</a></td>
   <td width="67.5%" align="right" colspan="3">&nbsp;</td>
   </tr>
   <tr  bgcolor="#DBEAF5">
   <td colspan="7"><hr size="1"></td>
   </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#DBEAF5">
  		<td width="2.5%" height="25">&nbsp;</td>
  		<td width="10%"><strong>From:</strong></td>
  		<td width="85%"><font size="1">
  		<%=WI.formatName((String)vRetResult.elementAt(9), (String)vRetResult.elementAt(10), (String)vRetResult.elementAt(11),4)%>
  		(<%=(String)vRetResult.elementAt(1)%>)</font></td>
  		<td width="2.5%" height="25">&nbsp;</td>
  	</tr>
  	<tr bgcolor="#DBEAF5">
  		<td height="25">&nbsp;</td>
  		<td><strong>To:</strong></td>
  		<td><font size="1"><%=WI.getStrValue(((String)vRetResult.elementAt(2)),"School Users:&nbsp;","<br>","")%>
	   <%=WI.getStrValue(((String)vRetResult.elementAt(3)),"Other Mail:&nbsp;","","&nbsp")%></font></td>
	   <td>&nbsp;</td>
  	</tr>
  	<tr bgcolor="#DBEAF5">
  		<td height="25">&nbsp;</td>
  		<td><strong>Subject:</strong></td>
  		<td><font size="1"><%=(String)vRetResult.elementAt(4)%></font></td>
  	   <td>&nbsp;</td>
	</tr>
  	<tr bgcolor="#DBEAF5">
  		<td height="10" colspan="4">&nbsp;</td>
	</tr>
<!--
	<tr>
  		<td height="75" bgcolor="#DBEAF5">&nbsp;</td>
  		 		<td valign="top" align="left" colspan="2" class="thinborderALL"><%=ConversionTable.replaceString((String)vRetResult.elementAt(6),"\r\n","<br>")%></td>
	   <td  bgcolor="#DBEAF5">&nbsp;</td>
	</tr>
-->
	<tr>
  		<td height="75" bgcolor="#DBEAF5">&nbsp;</td>
  		<td valign="top" align="left" colspan="2">
		<textarea rows="15" cols="85" class="textbox" style="font-size:11px;overflow:visible; border:0px;"><%=(String)vRetResult.elementAt(6)%></textarea></td>
	   <td  bgcolor="#DBEAF5">&nbsp;</td>
	</tr>
   <tr  bgcolor="#DBEAF5">
  		<td height="10" colspan="4">&nbsp;</td>
	</tr>
</table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr  bgcolor="#DBEAF5"> 
      <td height="10">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
	<input name="viewAll" type="hidden" value="<%=WI.fillTextValue("viewAll")%>">
	<input name="box_type" type="hidden" value="<%=WI.fillTextValue("box_type")%>">
  	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>