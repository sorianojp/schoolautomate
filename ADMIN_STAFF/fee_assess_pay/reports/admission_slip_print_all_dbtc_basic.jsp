<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

-->
</style>
</head>

<body onLoad="window.print()">
<%@ page language="java" import="utility.*,enrollment.FAAssessment,enrollment.FAPaymentUtil,enrollment.CurriculumMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;

	WebInterface WI = new WebInterface(request);

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

Vector vStudInfo = new Vector();

int iNoOfStudToPrint = 8;//Integer.parseInt(WI.getStrValue(WI.fillTextValue("stud_per_pg"),"4"));

String[] strConvertYrSem = {"N/A","Summer","1st Sem","2nd Sem", "3rd Sem","4th Sem","5th","6th","7th"};


String strSYFrom   = WI.fillTextValue("sy_from");
String strSYTo     = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");
String strExamName = WI.fillTextValue("exam_name");

String strGradeLevel = WI.fillTextValue("year_level");
String strSection    = WI.fillTextValue("section_name");

if(strGradeLevel.length() == 0) 
	strGradeLevel = null;
else
	strGradeLevel = dbOP.getBasicEducationLevel(Integer.parseInt(strGradeLevel), false);
	

String strPmtSchIndex = WI.fillTextValue("pmt_schedule");
String strExamDate = null;
java.sql.ResultSet rs = null;
String strSQLQuery = null;

strSQLQuery = "select exam_schedule from FA_PMT_SCHEDULE_EXTN where pmt_sch_index = "+strPmtSchIndex+" and sy_from = "+strSYFrom+
						" and (semester is null or semester = "+strSemester+") and is_del = 2";
rs = dbOP.executeQuery(strSQLQuery);
if(rs.next()) 
	strExamDate = ConversionTable.convertMMDDYYYY(rs.getDate(1));
rs.close();
if(strExamDate == null) {
	strSQLQuery = "select exam_schedule from FA_PMT_SCHEDULE where pmt_sch_index = "+strPmtSchIndex;
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) 
		strExamDate = ConversionTable.convertMMDDYYYY(rs.getDate(1));
}

int iMaxDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_disp"), "0"));
//System.out.println("iMaxDisp : "+iMaxDisp);
strSQLQuery = "select id_number, fname, mname, lname from user_Table where id_number = ";
String strIDNumber = null;
String strStudName = null;
for(int i=0; i<= iMaxDisp;){ 
if(i > 0) {%>
<br><br>
<%}
	++i;
	rs = dbOP.executeQuery(strSQLQuery+"'"+WI.fillTextValue("stud_id_"+i)+"'");
	
	if(!rs.next())
		break;
	strIDNumber = rs.getString(1);
	strStudName = WebInterface.formatName(rs.getString(2),rs.getString(3),rs.getString(4), 4);
	rs.close();
if(i > 0 && i % 13 == 0) {//for 12 student per page.%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
	<td width="2%">&nbsp;</td>
    <td width="48%" height="25">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td align="center">
					<strong><font style="font-size:14px; font-weight:bold">EXAMINATION PERMIT <BR>
					<%=strExamName%> <BR></font></strong>
					Academic Year <%=strSYFrom%> - <%=strSYTo%>	<br>&nbsp;			</td>
			</tr>
			<tr>
			  <td style="font-weight:bold; font-size:12px">Student Number: <u><%=strIDNumber%></u></td>
		  </tr>
			<tr>
			  <td style="font-weight:bold; font-size:12px">Name: <u><%=strStudName%></u></td>
		  </tr>
			<tr>
			  <td><u><%=strGradeLevel%> - <%=strSection%></u></td>
		  </tr>
			<tr>
			  <td>Date of Exam: <u><%=strExamDate%></u></td>
		  </tr>
		</table>	</td>
	<td width="2%">&nbsp;</td>
    <td width="48%">
	<%	++i;
	if(i <= iMaxDisp) {
	rs = dbOP.executeQuery(strSQLQuery+"'"+WI.fillTextValue("stud_id_"+i)+"'");
	//System.out.println("ID : "+i +" : "+WI.fillTextValue("stud_id_"+i));
	rs.next();
	strIDNumber = rs.getString(1);
	strStudName = WebInterface.formatName(rs.getString(2),rs.getString(3),rs.getString(4), 4);
	rs.close();
	%>
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td align="center">
					<strong><font style="font-size:14px; font-weight:bold">EXAMINATION PERMIT <BR>
					<%=strExamName%> <BR></font></strong>
					Academic Year <%=strSYFrom%> - <%=strSYTo%>	<br>&nbsp;				</td>
			</tr>
			<tr>
			  <td style="font-weight:bold; font-size:12px">Student Number: <u><%=strIDNumber%></u></td>
		  </tr>
			<tr>
			  <td style="font-weight:bold; font-size:12px">Name: <u><%=strStudName%></u></td>
		  </tr>
			<tr>
			  <td><u><%=strGradeLevel%> - <%=strSection%></u></td>
		  </tr>
			<tr>
			  <td>Date of Exam: <u><%=strExamDate%></u></td>
		  </tr>
		</table>
	<%}%>	</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td colspan="3"><hr size="1"></td>
    </tr>
</table>
<%}%>
</body>
</html>
<%dbOP.cleanUP();%>