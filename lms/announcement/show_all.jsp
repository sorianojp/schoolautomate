<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Announcement</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Announcement Summary</title>
</head>

<script language="JavaScript">
function ViewDtls(strInfoIndex) {
	var pgLoc = "./show_dtls.jsp?info_index="+strInfoIndex+"&read_stat=1";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>


<body bgcolor="#98BED5">
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
//I have to get here if there is any announcement .
	DBOperation dbOP = null;
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

	vRetResult = mgmtAnn.viewAnnouncement(dbOP, (String)request.getSession(false).getAttribute("userId"));
	if(vRetResult == null)
		strErrMsg = mgmtAnn.getErrMsg();

dbOP.cleanUP();
%>




<table border="0" width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td align="right"><img src="../images/announcementtitle.jpg" width="300" height="30"></td>
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
    <td width="26%" height="25" align="center" class="thinborder"><font size="1"><strong>SUBJECT</strong></font></td>
    <td width="27%" align="center" class="thinborder"><font size="1"><strong>VALIDITY DATE RANGE</strong></font></td>
    <td width="21%" align="center" class="thinborder"><font size="1"><strong>ANNOUNCED BY</strong></font></td>
    <td width="20%" align="center" class="thinborder"><font size="1"><strong>ANNOUNCEMENT</strong></font></td>
    <td width="6%" align="center" class="thinborder"><font size="1"><strong>DETAIL</strong></font></td>
  </tr>
  <%
	String strBGColor = "";
	int iReadStat = 0;

  for(int i =1; i < vRetResult.size(); i +=7 ){
 	iReadStat = Integer.parseInt((String)vRetResult.elementAt(i + 5));
	if(iReadStat == 0)
		strBGColor = "bgcolor=\"#CCCFDA\"";
	else
		strBGColor = "";
  %>
  <tr <%=strBGColor%>>
    <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
    <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i + 1)%> - <%=(String)vRetResult.elementAt(i + 2)%></div></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></td>
    <td align="center" class="thinborder"><a href="javascript:ViewDtls(<%=(String)vRetResult.elementAt(i + 6)%>);">VIEW</a></td>
  </tr>
 <%}%>
</table>
<%}//if vRetResult > 0) %>
</body>

</html>

<%
dbOP.cleanUP();
%>
