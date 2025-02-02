<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<body>
<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date,enrollment.NAApplCommonUtil" %>
<%
 //only used to load the Course offered, degree, year offered, semester offered and curriculum year (School year)
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
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

NAApplCommonUtil nacUtil 	= new NAApplCommonUtil();
Vector vOpenCourseDetail	= nacUtil.getCourseOpenStatus(dbOP,request.getParameter("ci"),request.getParameter("year"),
						          request.getParameter("sem"));
dbOP.cleanUP();
strErrMsg = nacUtil.getErrMsg();

%>

<table width="100%" border="0">
  <tr>
    <td colspan="4">&nbsp; <strong><%=strErrMsg%></strong> <font size="1">(list of open year/sem schedule)</font></td>
  </tr>
 <tr>
    <td width="15%">&nbsp;</td>
    <td width="15%">&nbsp;</td>
    <td width="35%">&nbsp;</td>
    <td width="35%">&nbsp;</td>
  </tr>
  <tr>
    <td colspan=3>&nbsp; Course Name : <%=request.getParameter("cn")%></td>
    <td> Date (YYYY-mm-dd): <strong><%=WI.getTodaysDate()%></strong></td>
  </tr>
<tr>
    <td width="15%">&nbsp;</td>
    <td width="15%">&nbsp;</td>
    <td width="35%">&nbsp;</td>
    <td width="35%">&nbsp;</td>
  </tr><%
if(vOpenCourseDetail != null && vOpenCourseDetail.size() > 0)
{%>
  <tr>
    <td align="center"><strong>Year</strong></td>
    <td align="center"><strong>Semester</strong></td>
    <td align="center"><strong>Start Date</strong></td>
    <td align="center"><strong>End Date</strong></td>
  </tr>
	<% for(int i = 0 ; i< vOpenCourseDetail.size();++i)
	{
		strTemp = (String)vOpenCourseDetail.elementAt(i+1);
		if(strTemp == null)
			strTemp = "ALL";
			
		if(strTemp.compareTo("0") ==0)
			strTemp = "Summer";
	%>
	  <tr>
		<td align="center"><%=WI.getStrValue(vOpenCourseDetail.elementAt(i++),"ALL")%></td>
		<td align="center"><%=strTemp%></td>
		<td align="center"><%=WI.getStrValue(vOpenCourseDetail.elementAt(++i),"ALL")%></td>
		<td align="center"><%=WI.getStrValue(vOpenCourseDetail.elementAt(++i),"ALL")%></td>
  	</tr>
   <%}
 }%>
 <tr>
    <td width="15%">&nbsp;</td>
    <td width="15%">&nbsp;</td>
    <td width="35%">&nbsp;</td>
    <td width="35%">&nbsp;</td>
  </tr>
</table>

</body>
</html>
