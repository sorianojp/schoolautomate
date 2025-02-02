<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript">
function ViewRecord(strTargetIndex)
{
	location="./exam_sch_viewdetail.jsp?index="+strTargetIndex;
	return;
}
</script>
<%@ page language="java" import="utility.DBOperation,enrollment.ExamSchedule,java.util.Vector, java.util.Date" %>
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
vRetResult = examSch.getIndividualExamSch(dbOP,(String)request.getSession(false).getAttribute("tempId"));
dbOP.cleanUP();

if(vRetResult == null || vRetResult.size() == 0)
	strErrMsg = examSch.getErrMsg();
%>
<body bgcolor="#9FBFD0">

<%
if(strErrMsg != null)
{%>
<table width="100%" border="0">
<tr>
<td><b>Message : <%=strErrMsg%></b>
</td></tr>
</table>
<%
return ;
}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          EXAM/INTERVIEW SCHEDULES ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#BECED3">
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
	</table>


  <table width="100%" bgcolor="#FFFFFF" border="1">
    <tr>
      <td width="12%">Exam Code</td>
      <td width="12%">Exam Type</td>
      <td width="20%">Date and Time</td>
	  <td width="21%">Contact Person</td>
      <td width="28%">Venue</td>
      <td align="center" width="7%">View Detail</td>
    </tr>
<%
for(int i = 0 ; i< vRetResult.size(); ++i)
{%>
    <tr>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=(String)vRetResult.elementAt(i+2)%></td>
      <td><%=((Date)vRetResult.elementAt(i+3)).toString()%></td>
	  <td><%=(String)vRetResult.elementAt(i+4)%></td>
      <td><%=(String)vRetResult.elementAt(i+5)%></td>
      <td align="center"><a href='javascript:ViewRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../../images/view.gif" border="0"></a></td>
    </tr>
<%
	i = i+5;
}%>

</table>


 </form>
</body>
</html>
