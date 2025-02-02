<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-Guidance-Reports-Other","exit_interview_mgmt.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
	
	

osaGuidance.GDExitInterview gdExitInterview = new osaGuidance.GDExitInterview();
Vector vRetResult = null;
	


vRetResult = gdExitInterview.generateExitInterviewReport(dbOP, request);
if(vRetResult == null)
	strErrMsg = gdExitInterview.getErrMsg();

	
	
%>
<body>
  

<%
if(strErrMsg != null){dbOP.cleanUP();%>
	<div style="text-align:center;font-size:13px; color:#FF0000;"><%=strErrMsg%></div>
<%return;}
if(vRetResult != null && vRetResult.size() > 0){
String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAddr = SchoolInformation.getAddressLine1(dbOP, false, false);
String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester", "Fourth Semester"};
int iStudCount= 0;
int iMaxCount = 35;
int iRowCount = 0;
boolean bolPageBreak = false;
for(int i =0 ; i < vRetResult.size(); ){
iRowCount = 0;
if(bolPageBreak){bolPageBreak = false;%>
<div style="page-break-after:always;"></div>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	
	<tr>
		<td height="22" colspan="2" align="center" style="font-weight:bold">
		<strong><%=strSchName%></strong><br><%=strSchAddr%><br><br>
		LIST OF STUDENT AVAILED EXIT INTERVIEW<br>
		<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, AY <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%>		</td>
	</tr>
	<tr>
		<%
		strTemp = (String)request.getSession(false).getAttribute("first_name");
		if(strTemp == null)
			strTemp = "";
		%>
	    <td width="50%" align="left"><font size="1">Printed by: <%=strTemp%></font></td>
        <td width="50%" align="right">Printed Date & Time: <%=WI.getTodaysDateTime()%></td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr style="font-weight:bold;">
    <td width="4%" height="24" class="thinborder" align="center">Sl. No</td>
    <td width="13%" class="thinborder"><div align="center">Student ID</div></td>
    <td width="24%" class="thinborder" align="center">Student Name</td>
    <td width="24%" class="thinborder"><div align="center">Course-Major</div></td>
    <td width="9%" class="thinborder"><div align="center">Gender</div></td>
    <td width="15%" class="thinborder"><div align="center">Applied Date</div></td>
    </tr>
<%

for(; i<vRetResult.size(); i += 11){// this is for page wise display.
	
	if(++iRowCount > iMaxCount){
		bolPageBreak = true;
		break;
	}
%>
  <tr>
    <td height="21" class="thinborder" align="right"><%=++iStudCount%>.&nbsp;</td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
	<%
	strTemp = WebInterface.formatName((String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),(String)vRetResult.elementAt(i + 5),4);
	%>
    <td class="thinborder"><%=strTemp%></td>
	<%
	strTemp = WI.getStrValue(vRetResult.elementAt(i + 6))+WI.getStrValue((String)vRetResult.elementAt(i + 7)," - ","","");
	%>
    <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%
	strTemp =WI.getStrValue((String)vRetResult.elementAt(i + 10),"M").toLowerCase();
	if(strTemp.equals("m"))
		strTemp = "Male";
	else
		strTemp = "Female";
	%>
    <td align="center" class="thinborder"><%=strTemp%></td>
	<%
	strTemp =WI.getStrValue((String)vRetResult.elementAt(i + 9),"&nbsp;");
	%>
    <td align="center" class="thinborder"><%=strTemp%></td>
    </tr>
  <%  
  }//end of print per page.%>
</table>

<%}//end of outer loop%>
<script>window.print();</script>
<%}//end of vRetResult!=null && vRetResult.size()>0%>

</body>
</html>
<%
dbOP.cleanUP();
%>