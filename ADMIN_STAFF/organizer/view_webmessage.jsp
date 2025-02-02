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
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function Inbox()
{
	location= "./webmail_main.jsp?init="+document.form_.init.value;
}
function Send(strFrom, strTo, strSubj, strPassType) 
{
	var newSubj = "";
	var target = "";
	
	if (strPassType == "0")
	{
		newSubj = "Re: "+strSubj;
		target = strFrom;
	}
	else if (strPassType == "1")
	{
		newSubj = newSubj = "Re: "+strSubj;
		target = strFrom+", "+strTo;
	}
	else if (strPassType == "2")
	{
		newSubj = "Fw: "+strSubj;
		target = "";
	}
	
	location = "./send_webmsg.jsp?init="+document.form_.init.value+"&target="+target+"&subj="+newSubj+"&fw_msg="+document.form_.msgnum.value+"&is_trash="+document.form_.is_trash.value;
}
function StartDownload(strNum, strPart)
{
	document.form_.mNum.value = strNum;
	document.form_.mPart.value = strPart;	
	document.form_.downloadNow.value = "1";
	this.SubmitOnce('form_');
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
	Vector vTemp = null;
	int iSearchResult = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strDL = null;
	strDL = WI.getStrValue(request.getParameter("downloadNow"),"0");
	
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
/** authenticate this user.
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
//end of authenticaion code.
**/

if (!strDL.equals("1")){
	SBWebMail myWebMail = new SBWebMail();
	vRetResult = myWebMail.operateOnUserWebMail(dbOP, request, response, 3);
	if (vRetResult == null)
		strErrMsg = myWebMail.getErrMsg();
	}
	
%>
<body bgcolor="#8C9AAA">
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
   <%if (WI.fillTextValue("downloadNow").equals("1")){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#DBEAF5">
		<td width="5%" height="25"><a href="javascript:history.back(1)"><img src="../../images/go_back.gif" border="0"></a></td>
		<td width="95%"><font size="1">Downloading file. Please wait a moment. Please click the back button after download is finished.</font></td>
	</tr>
</table>
	<iframe width="0" height="0" src="../../servlet/organizer.DownloadAttachment?msgnum=<%=WI.fillTextValue("mNum")%>&msgprt=<%=WI.fillTextValue("mPart")%>&init=<%=WI.fillTextValue("init")%>&is_trash=<%=WI.fillTextValue("is_trash")%>"></iframe>
<%}
   else if (vRetResult != null && vRetResult.size()>0 && !strDL.equals("1")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#DBEAF5">
  		<td width="2.5%" height="30">&nbsp;</td>
  		<td width="10%"><font size="1"><strong> :::Options::: </strong></font></td>
  		<td width="85%"><font size="1">
  		<a href='javascript:Send("<%=(String)vRetResult.elementAt(2)%>","<%=(String)vRetResult.elementAt(3)%>","<%=(String)vRetResult.elementAt(1)%>","0");'>Reply</a>&nbsp;&nbsp;
  		<a href='javascript:Send("<%=(String)vRetResult.elementAt(2)%>","<%=(String)vRetResult.elementAt(3)%>","<%=(String)vRetResult.elementAt(1)%>","1");'>Reply to All</a>&nbsp;&nbsp;
  		<a href='javascript:Send("<%=(String)vRetResult.elementAt(2)%>","<%=(String)vRetResult.elementAt(3)%>","<%=(String)vRetResult.elementAt(1)%>","2");'>Forward</a>&nbsp;&nbsp;
  		</font></td>
  		<td width="2.5%">&nbsp;</td>
  	</tr>
  	<tr bgcolor="#DBEAF5">
  		<td colspan="4"><hr size="1"></td>
  	</tr>
	<tr bgcolor="#DBEAF5">
  		<td height="25">&nbsp;</td>
  		<td><strong>Date Sent:</strong></td>
  		<td><font size="1">
  		<%=vRetResult.elementAt(0)%></font></td>
  		<td>&nbsp;</td>
  	</tr>
  	<tr bgcolor="#DBEAF5">
  		<td height="25">&nbsp;</td>
  		<td><strong>From:</strong></td>
  		<td><font size="1"><%=(String)vRetResult.elementAt(2)%></font></td>
	   <td>&nbsp;</td>
  	</tr>
  	<tr bgcolor="#DBEAF5">
  		<td height="25">&nbsp;</td>
  		<td><strong>To:</strong></td>
  		<td><font size="1"><%=(String)vRetResult.elementAt(3)%></font></td>
	   <td>&nbsp;</td>
  	</tr>
  	<tr bgcolor="#DBEAF5">
  		<td height="25">&nbsp;</td>
  		<td><strong>Subject:</strong></td>
  		<td><font size="1"><%=(String)vRetResult.elementAt(1)%></font></td>
  	   <td>&nbsp;</td>
	</tr>
  	<tr bgcolor="#DBEAF5">
  		<td height="10" colspan="4">&nbsp;</td>
	</tr>
<!--
	<tr>
  		<td height="75" bgcolor="#DBEAF5">&nbsp;</td>
  		 		<td valign="top" align="left" colspan="2"><%=(String)vRetResult.elementAt(4)%></td>
	   <td  bgcolor="#DBEAF5">&nbsp;</td>
	</tr>
-->
	<tr>
  		<td height="75" bgcolor="#DBEAF5">&nbsp;</td>
  		<td valign="top" align="left" colspan="2" class="thinborderALL">
			<!--<textarea rows="15" cols="85" class="textbox" style="font-size:11px;overflow:visible; border:0px;"><%//=(String)vRetResult.elementAt(4)%></textarea>-->
			<pre>
			<%=(String)vRetResult.elementAt(4)%>
			</pre>
			
			</td>
	   <td  bgcolor="#DBEAF5">&nbsp;</td>
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
<%}%>

	<input name="msgnum" type="hidden" value="<%=WI.fillTextValue("msgnum")%>">
	<input name="init" type="hidden" value="<%=WI.fillTextValue("init")%>">
	<input name="downloadNow" type="hidden" value="<%=WI.fillTextValue("strDL")%>">
	<input name="mNum" type="hidden" value="<%=WI.fillTextValue("mNum")%>">
	<input name="mPart" type="hidden" value="<%=WI.fillTextValue("mPrt")%>">
	<input name="is_trash" type="hidden" value="<%=WI.fillTextValue("is_trash")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>