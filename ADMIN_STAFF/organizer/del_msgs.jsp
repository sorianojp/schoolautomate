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
</head>
<%@ page language="java" import="utility.*, organizer.SBEmail, java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;
	

	int iSearchResult = 0;
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-Message Board","del_msgs.jsp");
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
														"del_msgs.jsp");
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
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myMailBox.operateOnMailBox(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = myMailBox.getErrMsg();
	}

	vRetResult = myMailBox.operateOnMailBox(dbOP, request, 4);
	if (vRetResult == null)
		strErrMsg = myMailBox.getErrMsg();

%>
<body bgcolor="#8C9AAA" >
<form action="./del_msgs.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="7" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          DELETED MESSAGES ::::</strong></font></div></td>
    </tr>
       <tr>
   <td colspan="3" height="25" valign="middle"><strong><%=WI.getStrValue(strErrMsg, "&nbsp;")%></strong></td>
   </tr>
</table>
<%if(vRetResult != null && vRetResult.size()>0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr bgcolor="#DBEAF5">
	   <td width="2%" height="25" align="center" valign="middle"><img src="../../images/prior_h.gif" border="0"></td>

	   <td width="24%"><div align="left"><strong><font size="1">From</font></strong></div></td>
	   <td width="34%"><div align="left"><strong><font size="1">Subject</font></strong></div></td>
	   <td width="20%"><div align="left"><strong><font size="1">Date</font></strong></div></td>
	   <td colspan="2">&nbsp;</td>
   </tr>
   <%for (int i = 0; i<vRetResult.size(); i+=12){%>
   <tr>
	   <td class="thinborderBOTTOM" height="25"><div align="center"><%if (((String)vRetResult.elementAt(i+5)).compareTo("1")==0){%>
   	<img src="../../images/prior_h.gif" border="0"><%}else{%>
   	<img src="../../images/prior_l.gif" border="0"><%}%></div></td>
	
	   <td class="thinborderBOTTOM">	   <%if (((String)vRetResult.elementAt(i+7)).compareTo("0")==0){%><strong>
	   <%=WI.formatName((String)vRetResult.elementAt(i+9), (String)vRetResult.elementAt(i+10), (String)vRetResult.elementAt(i+11),4)%>(<%=(String)vRetResult.elementAt(i+1)%>)</strong>
	   <%}else{%>
	   <%=WI.formatName((String)vRetResult.elementAt(i+9), (String)vRetResult.elementAt(i+10), (String)vRetResult.elementAt(i+11),4)%>(<%=(String)vRetResult.elementAt(i+1)%>)<%}%></td>
	   <td class="thinborderBOTTOM"><%if (((String)vRetResult.elementAt(i+7)).compareTo("0")==0){%><strong>
	   <%=(String)vRetResult.elementAt(i+4)%></strong><%}else{%>
	  <%=(String)vRetResult.elementAt(i+4)%><%}%></td>
	   <td class="thinborderBOTTOM"><%if (((String)vRetResult.elementAt(i+7)).compareTo("0")==0){%>
	   <strong><%=WI.formatDate((String)vRetResult.elementAt(i+8),10)%></strong>
   		<%}else{%>
   		<%=WI.formatDate((String)vRetResult.elementAt(i+8),10)%><%}%></td>
	   <td width="10%" class="thinborderBOTTOM"><a href='javascript:PageAction("7","<%=(String)vRetResult.elementAt(i)%>")'>Recover</a></td>
   	   <td width="10%" class="thinborderBOTTOM"><a href='javascript:PageAction("5","<%=(String)vRetResult.elementAt(i)%>")'>Delete</a></td>
   </tr>
   <%}%>
   <tr>
   	<td colspan="6">&nbsp;</td>
   </tr>
   <tr>
   	<td colspan="4">&nbsp;</td>
   	<td align="left" colspan="2"><a href='javascript:PageAction("6","")'>Clear Messages</a></td>
   </tr>
   </table>
   <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr> 
      <td height="10">&nbsp;</td>
    </tr>
    <tr>
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