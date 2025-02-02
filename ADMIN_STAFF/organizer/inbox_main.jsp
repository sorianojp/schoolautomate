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
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
function ShowMessage(strInfoIndex)
{
	location= "./view_message.jsp?info_index="+strInfoIndex+"&box_type=1&viewAll=0";
}
function ConnectMail(strIndex, strTrash)
{
	location= "./webmail_main.jsp?init="+strIndex+"&is_trash="+strTrash;
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
<%@ page language="java" import="utility.*, organizer.SBEmail, java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vOtherAccounts = null;
	int iMsgs = 1;
	int i = 0;
	int iSearchResult = 0;
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-Message Board","inbox_main.jsp");
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
														"inbox_main.jsp");
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

	SBEmail myMailBox = new SBEmail();
	vRetResult = myMailBox.operateOnMailBox(dbOP, request, 2);
	if (vRetResult == null)
		strErrMsg = myMailBox.getErrMsg();
		
	vOtherAccounts = myMailBox.chkOtherMail(dbOP, (String)request.getSession(false).getAttribute("userId"));
%>
<body bgcolor="#8C9AAA" >
<form action="./inbox_main.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="2" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INBOX MAIN ::::</strong></font></div></td>
    </tr>
       <tr>
   <td colspan="2">&nbsp;</td>
   </tr>
   <tr> 
   	<%
   	
	String strUserId = (String)request.getSession(false).getAttribute("userId");
	String strName = (String)request.getSession(false).getAttribute("first_name");
	if(strName == null) strName ="Anonymous";
   	
   	int iNewMsgs = 0;
   	if (vRetResult!=null)
   		iNewMsgs = vRetResult.size()/12;
   	%>
      <td height="25"><strong>Welcome <%=strName%> ! You have (<%=iNewMsgs%>) new messages.<strong></strong></font></td>
      <td ><font size="1"><div align="right"><font size="1"><a href= "./my_inbox.jsp?viewAll=0&box_type=1">Go to my inbox</a>
          </font></div>
        </td>
    </tr>
</table>
<%if (vRetResult != null && vRetResult.size()>0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
   <tr bgcolor="#DBEAF5">
   <td width="2%" height="25" class="thinborder" align="center"><img src="../../images/prior_h.gif" border="0"></td>
   <td width="29%" class="thinborder"><div align="left"><strong><font size="1">&nbsp;From</font></strong></div></td>
   <td width="40%" class="thinborder"><div align="left"><strong><font size="1">&nbsp;Subject</font></strong></div></td>
   <td width="29%" class="thinborder"><div align="left"><strong><font size="1">&nbsp;Date</font></strong></div></td>
   </tr>
<%for (i = 0;i<vRetResult.size(); i+=12) {
	if (i<60) {%>   
   <tr onClick="javascript:ShowMessage(<%=(String)vRetResult.elementAt(i)%>)" class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
   <td  class="thinborder" height="25"><div align="center"><%if (((String)vRetResult.elementAt(i+5)).compareTo("1")==0){%>
   	<img src="../../images/prior_h.gif" border="0"><%}else{%>
   	<img src="../../images/prior_l.gif" border="0"><%}%></div></td>
   <td  class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+9), (String)vRetResult.elementAt(i+10), (String)vRetResult.elementAt(i+11),4)%>(<%=(String)vRetResult.elementAt(i+1)%>)</td>
   <td  class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
   <td  class="thinborder">&nbsp;<%=WI.formatDate((String)vRetResult.elementAt(i+8),10)%></td>
   </tr>
<%}}%>
  <tr>
   	<td colspan="5" height="25">&nbsp;</td>
   </tr>
  </table>
<%}

if (vOtherAccounts != null && vOtherAccounts.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
   <tr bgcolor="#DBEAF5">
  	<td colspan="6" height="25" class="thinborder"><strong><a href= "./inbox_settings.jsp">My Accounts</a></strong></td>
  </tr>
   <tr bgcolor="#FAFCDD">
   <td width="29%" class="thinborder" height="20"><div align="left"><strong><font size="1">&nbsp;Account Name</font></strong></div></td>
   <td width="30%" class="thinborder"><div align="left"><strong><font size="1">&nbsp;Host</font></strong></div></td>
   <td width="20%" class="thinborder"><div align="left"><strong><font size="1">&nbsp;Message Details</font></strong></div></td>
   <td width="12%" class="thinborder"><div align="center"><strong><font size="1">&nbsp;Trash</font></strong></div></td>
   <td width="12%"  class="thinborder"><div align="center"><strong><font size="1">&nbsp;Inbox</font></strong></div></td>
   </tr>
  <% for (i=0; i<vOtherAccounts.size(); i+=8) {%>
	<tr>
		<td height="20" class="thinborder"><font color="black"><%=(String)vOtherAccounts.elementAt(i+1)%></font></a></td>
		<td class="thinborder"><%=(String)vOtherAccounts.elementAt(i+3)%></td>
	<%if(((String)vOtherAccounts.elementAt(i+6)).startsWith("ERROR")){%>
		<td class="thinborder"><font color="red"><%=(String)vOtherAccounts.elementAt(i+6)%></font></td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
	<%}else{%>
		<td class="thinborder"><font color="black"><%=(String)vOtherAccounts.elementAt(i+6)%></font></td>
		<td class="thinborder" align="center">
		<%if(((String)vOtherAccounts.elementAt(i+7)).startsWith("ERROR")){%>&nbsp;<%} else {
		if (!((String)vOtherAccounts.elementAt(i+7)).equals("(0)")){%>
		<a href='javascript:ConnectMail("<%=(String)vOtherAccounts.elementAt(i)%>","1");'><img src="../../images/trash_small.gif" border="0"></a><%}%>
		<strong><%=(String)vOtherAccounts.elementAt(i+7)%></strong><%}%></td>
		<td class="thinborder" align="center">
		<%if (vOtherAccounts.elementAt(i+4).equals("1")){%>
		<a href='javascript:ConnectMail("<%=(String)vOtherAccounts.elementAt(i)%>","0");'><img src="../../images/inbox_small.gif" border="0" ></a>
		<%}else{%>&nbsp;<%}%>
		</td>
	<%}%>
	</tr>
	<%}%>
   <tr>
   	<td colspan="6">&nbsp;</td>
   </tr>
</table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>