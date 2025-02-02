<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Subject Schedule Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
//	System.out.println("StrSchCode : " + strSchCode);
	
	if (strSchCode == null) 
		strSchCode = "";
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-advising-block section view","block_section_view.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//end of security code.
SubjectSection SS = new SubjectSection();
Vector vSecSch = SS.getSchOfASecForACourse(dbOP,request.getParameter("sec"),request.getParameter("ci"),
		request.getParameter("mi"),	request.getParameter("syf"),request.getParameter("syt"),
		request.getParameter("year_level"), request.getParameter("semester"), request.getParameter("sy_from"),
		request.getParameter("sy_to"), request.getParameter("offering_sem"), strSchCode);

if(vSecSch == null)
	strErrMsg = SS.getErrMsg();
dbOP.cleanUP();
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          BLOCK SECTION- VIEW PAGE ::::</strong></font></div></td>
    </tr>
<%
if(strErrMsg != null)
{%>	<tr bgcolor="#FFFFFF">
      <td width="3%" height="25">&nbsp;</td>
      <td width="97%"><%=strErrMsg%></td>

    </tr>
<%return;}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9"><div align="center">SUBJECT DETAILS FOR SECTION<strong> <%=request.getParameter("sec")%></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="11%" height="25"><div align="center"><strong><font size="1">SUBJECT</font></strong></div></td>
      <td width="25%"><div align="center"><font size="1"><strong>SCHEDULE (Days/Time)
          </strong></font></div></td>
<% if (!strSchCode.startsWith("CPU")) {%> 
      <td width="7%"><div align="center"><font size="1"><strong>REGULAR / IRREGULAR</strong></font></div></td>
<%}%> 
      <td width="8%"><div align="center"><strong><font size="1">MAX. NO. OF STUDENTS</font></strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>NO. OF STUDENTS
          ENROLLED</strong></font></div></td>
      <td width="6%"><div align="center"><strong><font size="1">STATUS</font></strong></div></td>
    </tr>
    <%
for(int i=0; i< vSecSch.size(); ++i){
 %>
    <tr>
      <td height="25" align="center"><%=(String)vSecSch.elementAt(i)%></td>
    <td align="center"> <%=(String)vSecSch.elementAt(i+2)%> </td>
<% if (!strSchCode.startsWith("CPU")) {%> 
    <td align="center"><%=WI.getStrValue(vSecSch.elementAt(i+3),"N/A")%>/<%=WI.getStrValue(vSecSch.elementAt(i+4),"N/A")%></td>
<%}%> 
    <td align="center"><%=(String)vSecSch.elementAt(i+5)%></td>
    <td align="center"><%=(String)vSecSch.elementAt(i+6)%></td>

    <td align="center"><%=(String)vSecSch.elementAt(i+7)%></td>
    </tr>
 <%	i = i+7;}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <td width="12%"></tr>
    <tr bgcolor="#FFFFFF">
      <td width="84%">&nbsp;</td>
      <td width="16%" height="25">&nbsp; </td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</body>
</html>
