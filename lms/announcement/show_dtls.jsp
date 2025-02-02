<html>

<head>
<meta http-equiv="Content-Language" content="en-us">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Announcement Summary</title>
</head>

<body bgcolor="#98BED5">
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
//I have to get here if there is any announcement .
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg  = null;

	try
	{
		dbOP = new DBOperation();
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

	lms.MgmtAnnouncement mgmtAnn = new lms.MgmtAnnouncement(dbOP);
	Vector vRetResult = null;

	vRetResult = mgmtAnn.operateOnAnnouncement(dbOP, request, 3);
	if(vRetResult == null)
		strErrMsg = mgmtAnn.getErrMsg();
	else {
		//i have to set the read status only if it is called from view all, not from search.
		if(WI.fillTextValue("read_stat").length() > 0) {
			mgmtAnn.setReadAnnStat(dbOP, WI.fillTextValue("info_index"),
				(String)request.getSession(false).getAttribute("userId"),
				WI.fillTextValue("read_stat") );
		}
	}

dbOP.cleanUP();
%>




<table border="0" width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td align="right"><img src="../images/announcementtitle.jpg"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
<%
if(strErrMsg != null) {%>
  <tr>
    <td height="25"><%=strErrMsg%></td>
  </tr>
<%}%>
</table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table border="0" width="100%" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#FFFFDD">
    <td width="53%" height="25" align="center" class="thinborder"><font size="1"><strong>SUBJECT</strong></font></td>
    <td width="17%" align="center" class="thinborder"><font size="1"><strong>VALIDITY
      DATE RANGE</strong></font></td>
    <td width="30%" align="center" class="thinborder"><font size="1"><strong>ANNOUNCED
      BY</strong></font></td>
  </tr>
  <tr>
    <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(3)%></td>
    <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(4)%> - <%=(String)vRetResult.elementAt(5)%></div></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(6)%></td>
  </tr>
  </table>
 <br>
<table border="0" width="100%" cellpadding="0" cellspacing="0">
  <tr valign="top">
    <td width="13%" height="25"> <strong>Message</strong> : </td>
    <td width="87%" height="25"><%=(String)vRetResult.elementAt(7)%></td>
  </tr>
</table>
<%}//if vRetResult > 0) %>
</body>

</html>

<%
dbOP.cleanUP();
%>
