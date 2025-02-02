<%@ page language="java" import="utility.*,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Messages</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="javascript">
	function ReadInfo(strMessageIndex){
		document.form_.message_index.value = strMessageIndex;
		document.form_.submit();
	}	
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if (bolMyHome)
		iAccessLevel = 1;
	
	if(iAccessLevel == -1)//for fatal error.
	{
		if(bolIsSchool)
			request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		else
			request.getSession(false).setAttribute("go_home","../../../index.jsp");
		
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"my_home","messages.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}

	Vector vRetResult = null;
	Vector vRetDetail = null;
	
	hr.HRNotification  not = new hr.HRNotification();
		
	strTemp = (String)request.getSession(false).getAttribute("userId");	
	
	if (strTemp.length() > 0) {
		vRetResult = not.GetUnreadMessages(dbOP, request, (String)request.getSession(false).getAttribute("userIndex"),4);
		if (vRetResult == null)
			strErrMsg = not.getErrMsg();
		
		if (WI.fillTextValue("message_index").length() > 0){
			vRetDetail = not.GetUnreadMessages(dbOP, request, (String)request.getSession(false).getAttribute("userIndex"),3);
			if (vRetDetail == null)
				strErrMsg = not.getErrMsg();
		}
	}
%>
<body bgcolor="#FFFFFF"  class="bgDynamic">
<form action="./messages.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic" align="center">
	  	<font color="#FFFFFF" ><strong>:::: MESSAGES PAGE::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr > 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="16%" height="25">EMPLOYEE ID </td>
 	  <td height="25" colspan="3">
		<font size="3" color="#FF000"><strong><%=(String)request.getSession(false).getAttribute("userId")%> </strong> </font>	  </td>
    </tr>
    <tr>
      <td height="18" colspan="5">&nbsp;</td>
    </tr>
  </table>

<% if (WI.fillTextValue("message_index").length() > 0) {%>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <% if (vRetDetail !=null && vRetDetail.size() > 0) {%>
    <tr>
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="5%" height="23">&nbsp;</td>
      <td width="88%" class="thinborderALL" style="padding:5x"><%=(String)vRetDetail.elementAt(1)%></td>
      <td width="7%">&nbsp;</td>
    </tr>
    <tr>
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
	<%}%>
  </table>
<%}
if (vRetResult != null) {
	if(vRetResult.size() == 0){%>
		<table bgcolor="#FFFFFF" width="100%">
			<%
				strTemp = (String)request.getSession(false).getAttribute("userId");
			%>
			<tr>
				<td width="3%">&nbsp;</td>
				<td><strong>No messages sent to: <%=strTemp%>.</strong></td>
			</tr>
		</table>
	<%}else{%> 
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
      <td height="25" colspan="3" align="center" bgcolor="#F4F2F3" class="thinborder">
	  	<strong>LIST OF MESSAGES SENT TO EMPLOYEE</strong></td>
    </tr>
	<tr>
		<td height="25" colspan="2" align="center" class="thinborder"><strong>Sender</strong></td>
		<td class="thinborder" align="center"><strong>Date Sent</strong></td>
	</tr>
	<% 
		String strIsRead = null;
		String strTableColor = "#FFFFFF";
		for(int i = 0; i < vRetResult.size(); i+=5){
			strIsRead = (String)vRetResult.elementAt(i+4);
			if(strIsRead.equals("1"))
				strTableColor = "#FFFF00";
	%> 
    <tr bgcolor="<%=strTableColor%>">
      <td width="6%" height="20" class="thinborder">&nbsp;</td>
      <td width="60%" class="thinborderBOTTOM">
	  	&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td width="34%" class="thinborder">&nbsp;
	  	<a href="javascript:ReadInfo('<%=(String)vRetResult.elementAt(i)%>')"><%=(String)vRetResult.elementAt(i+2)%></a></td>
    </tr>
	<%}%> 
  </table>
<%}}%> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="message_index" value="">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

