<%
String strStudID    = (String)request.getSession(false).getAttribute("userId");
if(strStudID == null) {
%>
 <p style="font-size:14px; color:#FF0000;">You are already logged out. Please login again.</p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<body  bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	int j = 0; // used to fill up the page with white boxes to make it apprear better .

//add security here.
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

boolean bolFatalErr = false;
Vector vStudInfo = null;
Vector vAddedSubList = null;
Vector vDroppedSubList = null;

String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
String[] astrSchYrInfo = dbOP.getCurSchYr();

EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();

if(strStudID == null || strStudID.trim().length() == 0)
{
	strErrMsg = "You are logged out. Please login again.";
	bolFatalErr = true;
}
if(astrSchYrInfo == null)//db error
{
	strErrMsg = dbOP.getErrMsg();
	bolFatalErr = true;
}
if(!bolFatalErr)
{
	vStudInfo = enrlAddDropSub.getEnrolledStudInfo(dbOP,strStudID,strStudID,
                                    astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	if(vStudInfo == null)
	{
		bolFatalErr = true;
		strErrMsg = enrlAddDropSub.getErrMsg();
	}
	if(!bolFatalErr) // get added and dropped list.
	{
		vAddedSubList 	= enrlAddDropSub.getAddedDroppedList(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2],true);
		vDroppedSubList = enrlAddDropSub.getAddedDroppedList(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2],false);
		if(vAddedSubList == null || vDroppedSubList == null)
		{
			if(enrlAddDropSub.getErrMsg() != null && enrlAddDropSub.getErrMsg().indexOf("Connection") != -1) //error in connection.
				strErrMsg = enrlAddDropSub.getErrMsg();
			else if(vAddedSubList == null && vDroppedSubList == null)
				strErrMsg = "No subject added/dropped for "+astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]+ ", School year "+
					astrSchYrInfo[0]+"-"+astrSchYrInfo[1];
			bolFatalErr = true;
		}
	}
}

dbOP.cleanUP();
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="2" bgcolor="#47768F"><div align="center"><font color="#FFFFFF"><strong>::::
          CHANGED SUBJECTS::::</strong></font></div></td>
    </tr>
	<%
if(strErrMsg != null && strErrMsg.trim().length() > 0){%>
    </tr>
		<tr bgcolor="#FFFFFF">
		<td width="2%"></td>
    <td height="25" ><strong><font size="3"><%=strErrMsg%></font></strong></td>
    </tr>
<%
if(bolFatalErr)
	return;
}%>

  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#BECED3">
      <td height="25" bgcolor="#BECED3"><div align="center"><font color="#FFFFFF" size="1"><strong>LIST
        OF SUBJECTS THAT WERE CHANGED FOR <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>,
        SCHOOL YEAR <%=astrSchYrInfo[0]+"-"+astrSchYrInfo[1]%></strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="12%" height="34"><div align="center"><font size="1"><strong>SUBJECT
          CODE </strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>SUBJECT NAME</strong></font></div></td>
      <td width="21%"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>SECTION &amp;
          ROOM #</strong></font></div></td>
      <td width="9%"><div align="center"><font size="1"><strong>LEC. UNITS </strong></font></div></td>
      <td width="9%"><div align="center"><font size="1"><strong>LAB. UNITS</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>CHANGED TYPE</strong></font></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>DATE</strong></font></div></td>
    </tr>
 <%if(vAddedSubList == null) vAddedSubList = new Vector();
 for(int i=0; i< vAddedSubList.size(); ++i){%>
    <tr>
      <td height="25"><%=(String)vAddedSubList.elementAt(i+2)%>&nbsp;</td>
      <td><%=(String)vAddedSubList.elementAt(i+3)%></td>
      <td><%=WI.getStrValue(vAddedSubList.elementAt(i+5),"N/A")%></td>
    <td><%=WI.getStrValue(vAddedSubList.elementAt(i+6),"N/A")%>/<%=WI.getStrValue(vAddedSubList.elementAt(i+7),"N/A")%></td>
    <td><%=(String)vAddedSubList.elementAt(i+10)%></td>
    <td><%=(String)vAddedSubList.elementAt(i+11)%></td>
      <td align="center">ADDED</td>
      <td align="center"><%=WI.getStrValue((String)vAddedSubList.elementAt(i+14),"&nbsp;")%></td>
    </tr>
<%
i = i+17;
}%>
 <%if(vDroppedSubList == null) vDroppedSubList = new Vector();
 for(int i=0; i< vDroppedSubList.size(); ++i){%>
    <tr>
      <td height="25"><%=(String)vDroppedSubList.elementAt(i+2)%>&nbsp;</td>
      <td><%=(String)vDroppedSubList.elementAt(i+3)%></td>
      <td><%=(String)vDroppedSubList.elementAt(i+5)%></td>
    <td><%=(String)vDroppedSubList.elementAt(i+6)%>/<%=(String)vDroppedSubList.elementAt(i+7)%></td>
    <td><%=(String)vDroppedSubList.elementAt(i+10)%></td>
    <td><%=(String)vDroppedSubList.elementAt(i+11)%></td>
      <td align="center">DROPPED/ WITHDRAWN</td>
      <td align="center"><%=(String)vDroppedSubList.elementAt(i+14)%></td>
    </tr>
<%
i = i+17;
}%>

  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9"><div align="right"><em></em></div></td>
    </tr>
    <tr bgcolor="#47768F">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>

</body>
</html>
