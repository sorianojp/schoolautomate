<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Announcements</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="./css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
<link href="./css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<%
//I have to get here evnt count. .
	utility.DBOperation dbOP = null;
	String strErrMsg  = null;
	java.util.Vector vRetResult = new java.util.Vector();

	try
	{
		dbOP = new utility.DBOperation();
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

	lms.MgmtEvent mgmtEvent = new lms.MgmtEvent(dbOP);
	lms.MgmtAnnouncement mgmtAnn = new lms.MgmtAnnouncement(dbOP);
	String strEventMsg = null;

	strEventMsg = mgmtEvent.getValidEventCount(dbOP);
	if(strEventMsg == null)
		strEventMsg = "N";
//System.out.println(request.getSession(false).getAttribute("userId"));
	vRetResult = mgmtAnn.viewAnnouncement(dbOP,
					(String)request.getSession(false).getAttribute("userId"));

dbOP.cleanUP();
%>

<body bgcolor="#336699" text="#FFFFFF" link="#FFFF00" vlink="#FFFF00" alink="#FFFF00" topmargin="0">
<table width="100%" border="0" cellspacing="0" cellpadding="3" class="thinborderALL">
  <tr>
    <td width="4%"><img src="./images/ancmt_logo.jpg" width="34" height="32"></td>
    <td width="96%" valign="middle">
	<font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif">
	<%
	if(vRetResult != null && vRetResult.size() > 0) {%>
	<a href="announcement/show_all.jsp" target="mainFrame">
	<font size="1"><%=(String)vRetResult.elementAt(0)%> Message</font></a>
    <%}else{%>
	No Announcement
	<%}%>
	<br>
	<%if(!strEventMsg.startsWith("N")){%>
	<a href="event/show_all.jsp" target="mainFrame"><font size="1"><%=strEventMsg%></font></a>
	<%}else{%>
	No Active Event
	<%}%>


	</font></td>
  </tr>
</table>
</body>
</html>
