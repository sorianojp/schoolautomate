<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>

<body>
<%@ page language="java" import="utility.*,enrollment.FAAssessment,enrollment.FAPaymentUtil,enrollment.CurriculumMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;

	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-ASSESSMENT-assessment sched","assessment_sched.jsp");
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

Vector vStudInfo = new Vector();
Vector vScheduledPmt = new Vector();

FAAssessment FA = new FAAssessment();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));

if(vStudInfo == null || vStudInfo.size() == 0)
	strErrMsg = pmtUtil.getErrMsg();
else
{
	//get scheduled payment information.
	vScheduledPmt =FA.getInstallmentSchedulePerStudPerExamSch(dbOP,request.getParameter("exam_sch"),(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(8),
						(String)vStudInfo.elementAt(9),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5));
	if(vScheduledPmt == null || vScheduledPmt.size() ==0)
		strErrMsg = FA.getErrMsg();
}
String strCollegeName = new CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(6));
//dbOP.cleanUP();
String[] strConvertYrSem = {"Summer","1st Sem","2nd Sem", "3rd Sem","4th Sem","5th","6th","7th"};
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <%
  if(strErrMsg != null){dbOP.cleanUP();%>
  <tr>
    <td height="10" colspan="2"><%=strErrMsg%></td>
  </tr>
  <%return;}%>
  <tr>
    <td width="50%" height="25"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
        <%=strCollegeName%><br>
        <strong><br>
        </strong>STUDENT SCHEDULE ASSESSMENT <br>
        <br>
        <strong><%=((String)vScheduledPmt.elementAt(1)).toUpperCase()%> EXAMINATION</strong><br>
        <%=strConvertYrSem[Integer.parseInt((String)vStudInfo.elementAt(5))]%> , AY <%=(String)vStudInfo.elementAt(8)%> to 
		<%=(String)vStudInfo.elementAt(9)%><br>
        Schedule of examination period : <strong><%=(String)vScheduledPmt.elementAt(2)%></strong><br>
      </div></td>
    <td width="50%"><div align="center"> </div></td>
  </tr>
  <tr>
    <td height="10" colspan="2">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="14%" height="20">Student ID</td>
    <td width="36%"><strong><%=request.getParameter("stud_id")%></strong></td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr>
    <td height="16">Student name</td>
    <td height="16"><strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    <td height="16">&nbsp;</td>
  </tr>
  <tr>
    <td height="18">Course/Major</td>
    <td height="18"><strong><%=(String)vStudInfo.elementAt(2)%> / <%=WI.getStrValue(vStudInfo.elementAt(3))%></strong></td>
    <td height="18">&nbsp;</td>
  </tr>
  <tr>
    <td height="18">Year Level</td>
    <td height="18"><strong><%=strConvertYrSem[Integer.parseInt((String)vStudInfo.elementAt(4))]%></strong></td>
    <td height="18">&nbsp;</td>
  </tr>
  <tr>
    <td height="18" colspan="2"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong>Back 
      Account/Balance previous due:<u><%=CommonUtil.formatFloat((String)vScheduledPmt.elementAt(4),true)%></u> Php</td>
    <td height="18">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" colspan="2"><div align="left"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong>&nbsp;Installment
        due for this period: <u><%=CommonUtil.formatFloat((String)vScheduledPmt.elementAt(0),true)%> Php</u></div></td>
    <td height="25"><strong> &nbsp;</strong></td>
  </tr>
  <tr>
    <td height="18" colspan="2"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong>&nbsp;Advance
      payment for this period: <u><%=CommonUtil.formatFloat((String)vScheduledPmt.elementAt(3),true)%> Php</u></td>
    <td height="18">&nbsp;</td>
  </tr>
  <tr>
    <td height="18" colspan="2"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong><strong>Total
      amount due for this period :<u><%=CommonUtil.formatFloat((String)vScheduledPmt.elementAt(5),true)%></u>
      Php</strong></td>
    <td height="18">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" colspan="2">&nbsp; Released by :______________________________
    </td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" colspan="2" valign="top"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Business
        Office)</div></td>
    <td height="25" valign="top">&nbsp;</td>
  </tr>
</table>
<script language="JavaScript">
	window.print();
window.setInterval("javascript:window.close();",0);
//window.setInterval("javascript:window.close()",0);
</script>

</body>
</html>
