<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.DBOperation,enrollment.ExamSchedule,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//end of security code.
strErrMsg = null; //if there is any message set -- show at the bottom of the page.
ExamSchedule examSch = new ExamSchedule();
Vector vRetResult = new Vector();
String strCourseAssigned = null;
strTemp = request.getParameter("index");
if(strTemp == null || strTemp.trim().length() ==0)
	strErrMsg = "Reference to Exam Schedule is lost. Please try again.";
else
{
	vRetResult = examSch.view(dbOP,strTemp);
	if(vRetResult == null || vRetResult.size() ==0)
		strErrMsg = examSch.getErrMsg();
	else
	{
		//get course assigned.
		Vector vTemp = new Vector();
		vTemp = examSch.getAssignedCourse(dbOP,(String)vRetResult.elementAt(2));
		if(vTemp != null)
		{
			StringBuffer strBuf = new StringBuffer();
			for(int i = 0 ;i< vTemp.size(); ++i)
			{
				strBuf.append((String)vTemp.elementAt(++i));
				if(i < vTemp.size() -1)
					strBuf.append(", ");
			}

			strCourseAssigned = strBuf.toString();
		}
		else
			strCourseAssigned = "";
	}

}
dbOP.cleanUP();
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F">
      <td height="25"><div align="center"><strong><font color="#FFFFFF">:::: EXAMINATION
        SCHEDULE DETAIL::::</font></strong></div></td>
    </tr>
    <tr bgcolor="#BECED3">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
	<%
if(strErrMsg != null)
{%>
	<tr>
      <td height="22" colspan="2"><font size="3"> <%=strErrMsg%></td>
    </tr>
<%return;}%>
    <tr>
      <td width="7%">&nbsp;</td>
      <td><strong>EXAMINATION SCHEDULE DETAILS : <%=(String)vRetResult.elementAt(3)%></strong></td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
</table>
<table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="7%">&nbsp;</td>

    <td width="25%">Exam Prepared By</td>
    <td width="78%"><%=(String)vRetResult.elementAt(1)%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>

    <td>Examination Code</td>

    <td><%=(String)vRetResult.elementAt(2)%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>

    <td>Examination Type</td>

    <td><%=(String)vRetResult.elementAt(4)%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Duration</td>

    <td><%=(String)vRetResult.elementAt(5)%> (mins)</td>
    </tr>
    <tr>
      <td>&nbsp;</td>

    <td>DateTime(yyyy-mm-dd)</td>

    <td ><%=vRetResult.elementAt(6)%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Venue</td>

    <td><%=(String)vRetResult.elementAt(7)%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>

    <td>Contact Person</td>

    <td><%=(String)vRetResult.elementAt(8)%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>

    <td>Contact Nos.</td>

    <td><%=(String)vRetResult.elementAt(9)%></td>
    </tr>
	<tr>
      <td>&nbsp;</td>
    <td>Target Courses</td>

    <td><%=strCourseAssigned%> </td>
    </tr>
	<tr>
      <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#47768F">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
</body>
</html>
