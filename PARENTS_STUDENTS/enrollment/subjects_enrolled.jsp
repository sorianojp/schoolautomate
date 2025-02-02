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
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.Advising,student.Enrollment,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
	int j = 0; // used to fill up the page with white boxes to make it apprear better .

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Parent/Student-enrollment","subjects_enrolled.jsp");
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
Vector vEnrolledList = null;
String strMaxAllowedLoad = null;
String strOverLoadDetail = null;
String strEnrlDateTime = null;
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

String[] astrSchYrInfo = {
(String)request.getSession(false).getAttribute("cur_sch_yr_from"), 
(String)request.getSession(false).getAttribute("cur_sch_yr_to"),
(String)request.getSession(false).getAttribute("cur_sem")
};//dbOP.getCurSchYr();

EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();
Advising advising = new Advising();
Enrollment enrlInfo = new Enrollment();
if(astrSchYrInfo == null)//db error
{
	strErrMsg = dbOP.getErrMsg();
	bolFatalErr = true;
}
if(!bolFatalErr)
{
	vStudInfo = enrlAddDropSub.getEnrolledStudInfo(dbOP,strStudID);
	if(vStudInfo == null)
	{
		bolFatalErr = true;
		strErrMsg = enrlAddDropSub.getErrMsg();
	}
	else {
		astrSchYrInfo[0] = (String)vStudInfo.elementAt(40);
		astrSchYrInfo[1] = (String)vStudInfo.elementAt(41);
		astrSchYrInfo[2] = (String)vStudInfo.elementAt(42);
		
		request.getSession(false).setAttribute("cur_sch_yr_from",astrSchYrInfo[0]);
		request.getSession(false).setAttribute("cur_sch_yr_to",astrSchYrInfo[1]);
		request.getSession(false).setAttribute("cur_sem",astrSchYrInfo[2]);
	}
	//check if basic. 
	if(enrlAddDropSub.getIsBasic()) {
		if(!astrSchYrInfo[2].equals("1") && !astrSchYrInfo[2].equals("0")) {
			astrSchYrInfo[2] = "1";
			request.getSession(false).setAttribute("cur_sem", "1");
		}
	}
	
	if(!bolFatalErr)
	{
		strEnrlDateTime = enrlInfo.getStudEnrollDateTime(dbOP,strStudID,astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
		if(strEnrlDateTime == null)
		{
			bolFatalErr = true;
			strErrMsg = enrlInfo.getErrMsg();
		}
		//System.out.println(strEnrlDateTime);
	}
	if(!bolFatalErr)
	{
		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(5),(String)vStudInfo.elementAt(6),
			astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2],(String)vStudInfo.elementAt(7),
			(String)vStudInfo.elementAt(8));
		if(vMaxLoadDetail == null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
		else
		{
			strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
			if(vMaxLoadDetail.size() > 1)
				strOverLoadDetail = "Maximum load in curriculum for this sem "+(String)vMaxLoadDetail.elementAt(1)+
				" overloaded load "+(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+(String)vMaxLoadDetail.elementAt(2)+")";
		}
	}
	if(!bolFatalErr) // show enrolled list
	{
		//check if this is basic. 
		if(vStudInfo.elementAt(5) == null)
			enrlAddDropSub.setIsBasic(true);
		vEnrolledList = enrlAddDropSub.getEnrolledList(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
		if(vEnrolledList == null)
		{
			bolFatalErr = true;
			strErrMsg = enrlAddDropSub.getErrMsg();
		}
		
	}
}
if(strErrMsg == null)
	strErrMsg = "";
dbOP.cleanUP();
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#47768F">
      <td height="25" colspan="3" bgcolor="#47768F"><div align="center"><font color="#FFFFFF"><strong>::::
      SUBJECTS ENROLLED ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#BECED3">
      <td height="25" bgcolor="#BECED3"><div align="center"><font color="#FFFFFF" size="1"><strong>LIST
        OF SUBJECTS ENROLLED FOR <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>,
        SCHOOL YEAR <%=astrSchYrInfo[0]+"-"+astrSchYrInfo[1]%></strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="2%"></td>
    <td colspan="2" height="25" ><strong><font size="3"><%=strErrMsg%></font></strong></td>
    </tr>
	</table>
<%
if(bolFatalErr)
	return;
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
		<td width="2%"></td>
    	<td colspan="2" height="25" style="font-size:18px; font-weight:bold">ENROLLED SY-TERM: <%=astrSchYrInfo[0]+"-"+astrSchYrInfo[1]+"-"+astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>
	  	</td>
	</tr>

	<tr>
	<td width="2%"></td>
      <td colspan="2" height="25" ><font size="1">DATE  OFFICIALLY ENROLLED
        : <%=strEnrlDateTime%></font></td>

    </tr>
<%
if(strOverLoadDetail != null){%>
    <tr>
      <td  height="25">&nbsp;</td>
      <td colspan="2" height="25"><font size="1">Overload detail : <%=strOverLoadDetail%></font></td>
    </tr>
<%}%>
    <tr>
	<td></td>

    <td height="25"><font size="1"> MAXIMUM UNITS FOR THIS SEMESTER : <strong><%=strMaxAllowedLoad%></strong></font></td>
      <td width="40%" height="25"><div align="right"><font size="1">TOTAL UNITS
          LOAD TAKEN : <strong><%=(String)vEnrolledList.elementAt(0)%></strong></font>&nbsp;&nbsp;</div></td>
    </tr>
  </table>
<table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td width="20%" height="25"><div align="center"><font size="1"><strong><u>SUBJECT
        CODE</u></strong></font></div></td>
    <td width="60%"><div align="center"><font size="1"><strong><u>SUBJECT TITLE</u></strong></font></div></td>
<%if(!enrlAddDropSub.getIsBasic()) {%>
    <td width="10%"><div align="center"><font size="1"><strong><u>LEC/LAB UNITS</u></strong></font></div></td>
<%}%>
    <td width="10%"><div align="center"><font size="1"><strong><u>TOTAL UNITS</u></strong></font></div></td>
  </tr>
 <%
 for(int i=1; i< vEnrolledList.size(); ++i){%>
  <tr>
    <td height="25"><%=(String)vEnrolledList.elementAt(i+3)%></td>
    <td><%=(String)vEnrolledList.elementAt(i+4)%></td>
<%if(!enrlAddDropSub.getIsBasic()) {%>
    <td align="center"><%=(String)vEnrolledList.elementAt(i+11)%>/<%=(String)vEnrolledList.elementAt(i+12)%></td>
<%}%>
    <td align="center"><%=(String)vEnrolledList.elementAt(i+13)%></td>
  </tr>
 <%
i = i+13;
 }%>
</table>

  <table width="100%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr bgcolor="#47768F">
      <td height="25">&nbsp;</td>
    </tr>
  </table>

</body>
</html>
