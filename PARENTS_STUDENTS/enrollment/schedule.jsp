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
<body bgcolor="#9FBFD0">
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
//authenticate this user.
//end of authenticaion code.

boolean bolFatalErr = false;
Vector vStudInfo = null;
Vector vEnrolledList = null;
String strEnrlDateTime = null;
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

String[] astrSchYrInfo = {
(String)request.getSession(false).getAttribute("cur_sch_yr_from"), 
(String)request.getSession(false).getAttribute("cur_sch_yr_to"),
(String)request.getSession(false).getAttribute("cur_sem")
};//dbOP.getCurSchYr();
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();
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
	if(!bolFatalErr) // show enrolled list
	{
		vEnrolledList = enrlAddDropSub.getEnrolledList(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
		if(vEnrolledList == null)
		{
			bolFatalErr = true;
			strErrMsg = enrlAddDropSub.getErrMsg();
		}
	}
}

dbOP.cleanUP();
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#47768F"><div align="center"><font color="#FFFFFF"><strong>::::
          SCHEDULE ::::</strong></font></div></td>
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
      <td height="25" bgcolor="#BECED3" ><div align="center"><font color="#FFFFFF" size="1"><strong>STUDENT
          LOAD &amp; SCHEDULE FOR <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>,
	  SCHOOL YEAR <%=astrSchYrInfo[0]+"-"+astrSchYrInfo[1]%></strong></font></div></td>
    </tr>
  </table>

<table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="15%" height="25"><div align="center"><font size="1"><strong>SUBJECT
        CODE </strong></font></div></td>
    <td width="30%"><div align="center"><font size="1"><strong>SUBJECT NAME</strong></font></div></td>
    <td width="22%"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
    <td width="23%"><div align="center"><font size="1"><strong>SECTION &amp; ROOM
        #</strong></font></div></td>
<%if(!enrlAddDropSub.getIsBasic()) {%>
    <td width="5%"><div align="center"><font size="1"><strong>LEC/LAB. UNITS</strong></font></div></td>
<%}%>
    <td width="5%"><div align="center"><font size="1"><strong>TOTAL UNITS </strong></font></div></td>
  </tr>
  <%
 for(int i=1; i< vEnrolledList.size(); ++i){%>
  <tr>
    <td height="25"><%=(String)vEnrolledList.elementAt(i+3)%>&nbsp;</td>
    <td><%=(String)vEnrolledList.elementAt(i+4)%>&nbsp;</td>
    <td><%=WI.getStrValue(vEnrolledList.elementAt(i+6),"N/A")%>&nbsp;</td>
    <td><!--<%=(String)vEnrolledList.elementAt(i+7)%>/--><%=WI.getStrValue(vEnrolledList.elementAt(i+8),"N/A")%>&nbsp;</td>
<%if(!enrlAddDropSub.getIsBasic()) {%>
    <td align="center"><%=(String)vEnrolledList.elementAt(i+11)%>/<%=(String)vEnrolledList.elementAt(i+12)%>&nbsp;</td>
<%}%>
    <td align="center"><%=(String)vEnrolledList.elementAt(i+13)%>&nbsp;</td>
  </tr>
<%
i = i+13;
 }%>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	  <tr bgcolor="#FFFFFF">
		<td colspan="6" height="25"><div align="center">TOTAL LOAD UNITS : <font size="1"><strong><%=(String)vEnrolledList.elementAt(0)%></strong></font></div></td>
	  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#47768F">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
</body>
</html>
