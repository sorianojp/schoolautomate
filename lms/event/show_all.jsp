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

	lms.MgmtEvent mgmtEvent = new lms.MgmtEvent(dbOP);
	Vector vRetResult = null;

	vRetResult = mgmtEvent.operateOnEvent(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = mgmtEvent.getErrMsg();

dbOP.cleanUP();
%>




<table border="0" width="100%" cellpadding="0" cellspacing="0">
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
    <td width="35%" height="25" align="center" class="thinborder"><font size="1"><strong>EVENT
      NAME </strong></font></td>
    <td width="22%" align="center" class="thinborder"><font size="1"><strong>START
      - END DATE</strong></font></td>
    <td width="43%" align="center" class="thinborder"><font size="1"><strong>EVENT
      DESCRIPTION </strong></font></td>
  </tr>
  <%
  String[] astrConvertAMPM={"AM","PM"};
  for(int i =0; i < vRetResult.size(); i +=13 ){
  %>
  <tr bgcolor="#CCCFDA">
    <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 9)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%>
	<%=CommonUtil.formatMinute((String)vRetResult.elementAt(i + 2))%>:<%=CommonUtil.formatMinute((String)vRetResult.elementAt(i + 3))%>
	<%=astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i + 4))]%><br>
        <%=(String)vRetResult.elementAt(i + 5)%>
	<%=CommonUtil.formatMinute((String)vRetResult.elementAt(i + 6))%>:<%=CommonUtil.formatMinute((String)vRetResult.elementAt(i + 7))%>
	<%=astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i + 8))]%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 10)%></td>
  </tr>
  <%}%>
</table>
<%}//if vRetResult > 0) %>
</body>

</html>

<%
dbOP.cleanUP();
%>
