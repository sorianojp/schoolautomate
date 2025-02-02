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
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function ClearAll()
{
	document.form_.to_addr.value = "";
	document.form_.subject.value = "";
	document.form_.msg.value = "";
}
function Inbox()
{
	location= "./webmail_main.jsp?init="+document.form_.init.value;
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


	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-Message Board","send_webmsg.jsp");
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
/**authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Organizer","Message Board",request.getRemoteAddr(),
														"send_webmsg.jsp");
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
**/
	SBWebMail myWebMail = new SBWebMail();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myWebMail.operateOnUserWebMail(dbOP, request, response, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = myWebMail.getErrMsg();
			if (strErrMsg == null)
				strErrMsg = "Mail sent successfully";
		}
		else
			strErrMsg = myWebMail.getErrMsg();
	}


%>
<body bgcolor="#8C9AAA">
<form action="./send_webmsg.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="6" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SEND MESSAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="6"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    	<tr>
		<td colspan="6" height="10">Send to: <font size="1">[enter fields separated by commas]</font></td>    
	</tr>
    	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
	<tr>
    	<td>&nbsp;<%
    	strTemp = WI.fillTextValue("target");
    	if (strTemp.length()==0)
    	strTemp = WI.fillTextValue("to_addr");%></td>
    	<td><div align="left"><font size="1"><strong>Email Address: </strong></font></div></td>
    	<td colspan="4"><div align="left"><input name="to_addr" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" value="<%=strTemp%>"></div></td>
    </tr>
   	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
    <tr>
    	<td>&nbsp;<%strTemp = WI.fillTextValue("subj");
    	if (strTemp.length()==0)
	    	strTemp = WI.fillTextValue("subject");%></td>
    	<td><div align="left"><strong>Subject</strong></div></td>
    	<td colspan="4"><div align="left">
    	<input name="subject" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" value="<%=strTemp%>"></div></td>
    </tr>
    <tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
<%if (false){%>
	<tr>
    	<td>&nbsp;</td>
    	<td><div align="left"><strong>Attachment </strong></div></td>
    	<td colspan="4"><div align="left">
    	<%strTemp = WI.fillTextValue("filepath");%>
		<input name="filepath" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" value="<%=strTemp%>">
    	</div></td>
    </tr>
<%}%>
	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
   
    <tr>
    	<td>&nbsp;</td>
    	<td valign="top"><div align="left"><strong>Message</strong></div></td>
    	<td colspan="4">
    	<%strTemp = WI.fillTextValue("msg");%>
    	<textarea name="msg" cols="75" rows="15" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea> </td>
    </tr>
	
    <tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
		<tr>
		<td colspan="6" align="center"><font size="1">
		<%if (WI.fillTextValue("fw_msg").length()>0 && WI.fillTextValue("target").length()==0){%>
		<a href='javascript:PageAction(2,"");'><img src="../../images/execute_query.gif" border="0" ></a>Forward Message&nbsp;&nbsp;&nbsp; 
		<%}else{%>
		<a href='javascript:PageAction(1,"");'><img src="../../images/send_email.gif" border="0" ></a>Send Message&nbsp;&nbsp;&nbsp;  
		<%}%> 
		<a href="javascript:ClearAll()"><img src="../../images/clear.gif" border="0"></a>Clear fields
		<a href="javascript:Inbox()"><img src="../../images/go_back.gif" border="0"></a>Go Back to Inbox
		</td>    
	</tr>
	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="page_action">
	<input name="init" type="hidden" value="<%=WI.fillTextValue("init")%>">
	<input name="target" type="hidden" value="<%=WI.fillTextValue("target")%>">
	<input name="subj" type="hidden" value="<%=WI.fillTextValue("subj")%>">
	<input name="fw_msg" type="hidden" value="<%=WI.fillTextValue("fw_msg")%>">
	<input name="is_trash" type="hidden" value="<%=WI.fillTextValue("is_trash")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>