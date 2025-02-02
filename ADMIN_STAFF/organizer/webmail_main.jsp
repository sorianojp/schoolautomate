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
<script>
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}

function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
function ShowMessage(strMsgNum, strIndex)
{
	location= "./view_webmessage.jsp?msgnum="+strMsgNum+"&init="+strIndex+"&is_trash="+document.form_.is_trash.value;
}
function Compose()
{
	location= "./send_webmsg.jsp?init="+document.form_.init.value;
}
function ReloadPage()
{
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function CheckAll()
{
	var iMaxDisp = document.form_.msgCtr.value;
	if (iMaxDisp.length == 0)
		return;	
	if (document.form_.selAll.checked ){
		for (var i = 1 ; i <= eval(iMaxDisp)-1;++i)
			eval('document.form_.msg'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i <= eval(iMaxDisp)-1;++i)
			eval('document.form_.msg'+i+'.checked=false');
	document.form_.page_action.value = "";
}
function Inbox()
{
	location= "./webmail_main.jsp?init="+document.form_.init.value;
}
</script>
<style>
.nav {
     color: #000000;
     background-color: #FFFFFF;
}
.nav-highlight {
     color: #000000;
     background-color: #FAFCDD;
}

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
	String strFonCol = null;
	int i = 0;
	int iMsgs = 1;
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-Message Board","webmail_main.jsp");
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
														"webmail_main.jsp");
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
	SBWebMail myWebMail = new SBWebMail();
			strErrMsg = "Connect successful";
			strTemp = WI.fillTextValue("page_action");
			
			if(strTemp.length() > 0) {
				if(myWebMail.operateOnUserWebMail(dbOP, request, response, Integer.parseInt(strTemp)) != null ) {
						strErrMsg = "Operation successful.";
				}
				else
						strErrMsg = myWebMail.getErrMsg();
				}
			
			vRetResult = myWebMail.operateOnUserWebMail(dbOP, request, response, 4);
				if (vRetResult ==  null && strErrMsg==null)
					strErrMsg = myWebMail.getErrMsg();
				else if (vRetResult !=  null && strErrMsg==null)
					strErrMsg = "Connect Successful.";
%>
<body bgcolor="#8C9AAA" >
<form action="./webmail_main.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          <%if (WI.fillTextValue("is_trash").equals("1")){%>DELETED MESSAGES<%} else {%>EMAIL INBOX<%}%> ::::</strong></font></div></td>
    </tr>
   <tr>
   <td><%=WI.getStrValue(strErrMsg)%></td>
   </tr>
   <tr> 
      <td height="25"><strong>&nbsp;
      <%if (WI.fillTextValue("is_trash").equals("1")){%>
      <a href= "javascript:Inbox()">Inbox</a><%} else {%>
      <a href="javascript:Compose();">Compose</a><%}%></strong></td>
    </tr>
</table>
<%if (vRetResult != null && vRetResult.size()>0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr> 
      <td align="right" colspan="4"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iMsgCount = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(0),"0"));
		int iPageCount = iMsgCount/myWebMail.getDefShow();
		if(iMsgCount % myWebMail.getDefShow() > 0) ++iPageCount;
		if(iPageCount > 1)
		{%><font size="1">Jump To page: </font>
          <select name="jumpto" onChange="ReloadPage();" style="font-size:10px">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%	}
			}
			%>
          </select>
          <%} else {%>&nbsp;<%}%></td>
    </tr>
   <tr bgcolor="#DBEAF5">
   <td width="10%" align="center" height="25"><input type="checkbox" name="selAll" value="0" onClick="CheckAll();"></td>
   <td width="30%" align="left"><strong><font size="1">&nbsp;From</font></strong></td>
   <td width="40%" align="left"><strong><font size="1">&nbsp;Subject</font></strong></td>
   <td width="20%" align="left"><strong><font size="1">&nbsp;Date</font></strong></td>
   </tr>
<%
for (i = 1;i<vRetResult.size(); i+=6, iMsgs++) {%>   
   <tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
	<%strTemp = (String)vRetResult.elementAt(i+4);%>
   <td class="thinborderBOTTOM" height="25" align="center">
	<input type="checkbox" name="msg<%=iMsgs%>" value="<%=(String)vRetResult.elementAt(i+3)%>">
   </td>
   <td  class="thinborderBOTTOM">&nbsp;
	<a href="javascript:ShowMessage(<%=(String)vRetResult.elementAt(i+3)%>, <%=WI.fillTextValue("init")%>);">   
   <%if (strTemp.compareTo("0")==0) {%><strong><%=(String)vRetResult.elementAt(i)%></strong><%} else {%>
   <%=(String)vRetResult.elementAt(i)%><%}%>
   </a>
   </td>
   <td  class="thinborderBOTTOM">&nbsp;
   <%if (strTemp.compareTo("0")==0) {%><strong><%=(String)vRetResult.elementAt(i+2)%></strong><%} else {%>
   <%=(String)vRetResult.elementAt(i+2)%><%}%>
   
   
   <%if (((String)vRetResult.elementAt(i+5)).equals("1")){%><img src="../../images/paperclip.gif"><%}else{%>&nbsp;<%}%>
   </td>
   <td  class="thinborderBOTTOM">&nbsp;
   <%if (strTemp.compareTo("0")==0) {%><strong><%=(String)vRetResult.elementAt(i+1)%></strong><%} else {%>
<%=(String)vRetResult.elementAt(i+1)%><%}%></td>
   </tr>
<%}%>
  <tr>
  	<td align="center">
  	<a href='javascript:PageAction("0")'>
        <img src="../../images/delete.gif" border="0"></a>
  	</td>
	<td align="center"><%if (WI.fillTextValue("is_trash").equals("1")){%>
  	<a href='javascript:PageAction("5")'>
        <img src="../../images/undelete.gif" border="0"></a><%} else {%>&nbsp;<%}%>
  	</td>
   	<td colspan="3" height="25">&nbsp;</td>
   </tr>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
    	<input type="hidden" name="msgCtr" value ="<%=iMsgs%>">
		<input name="init" type="hidden" value="<%=WI.fillTextValue("init")%>">
		<input name="is_trash" type="hidden" value="<%=WI.fillTextValue("is_trash")%>">
		<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
