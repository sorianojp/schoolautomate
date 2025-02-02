<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">

</head>

<body>
<%@ page language="java" import="utility.*,java.util.Vector, enrollment.ReportRegistrar " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	
	
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS",
								"deliberation_report.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"Registrar Management","REPORTS",
											request.getRemoteAddr(),
											"deliberation_report.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}


String[] astrSemester = {"Summer","First Semester", "Second Semester", "Third Semester", "Fourth Semester"};
String strSYFrom = WI.fillTextValue("sy_from");
String strSYTo = WI.fillTextValue("sy_to");
String strSem    = WI.fillTextValue("semester");

String strCourseIndex = WI.fillTextValue("course_index");
String strMajorIndex  = WI.fillTextValue("major_index");
String strYearLevel   = WI.fillTextValue("year_level");

Vector vRetResult = null;

ReportRegistrar reportReg = new ReportRegistrar();


vRetResult = reportReg.getStudListForDeliberationSPC(dbOP, request);
if(vRetResult == null)
	strErrMsg = reportReg.getErrMsg();

if(strErrMsg != null){dbOP.cleanUP();%>
	<div align="center"><strong style="font-size:14px; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></strong></div>
<%return;}


if(vRetResult != null && vRetResult.size() > 0){

Vector vSubList = new Vector();
		 

int iRowCount = 1;
int iNoOfStudPerPage = 45;

if(WI.fillTextValue("rows_per_pg").length() > 0)
	iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
	
	
int iStudCount = 1;
int iPageCount = 1;
int iTotalStud = (vRetResult.size()/15);
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud % iNoOfStudPerPage > 0)
	++iTotalPageCount;
boolean bolPageBreak = false;
for(int i = 0; i < vRetResult.size(); ){
	iRowCount = 1;
%>




<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4"><div align="center"><font style="font-size:13px; font-weight:bold;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
			 DELIBERATION (FINALS)<br><br>
			<%=astrSemester[Integer.parseInt(strSem)]%> <%=strSYFrom+"-"+strSYTo%>
	  </div></td>
    </tr>
	<tr><td align="right" colspan="9" height="22">Page <%=iPageCount++%></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="bottom" width="37%" height="22" style="padding-left:40px;"><u><em>Student Name</em></u></td>
		<td valign="bottom" width="17%"><u><em>Course/Yr</em></u></td>
		<td valign="bottom" width="12%"><u><em>Subject</em></u></td>
		<td valign="bottom" width="7%" align="center"><u><em>Grade</em></u></td>
		<td valign="bottom" width="4%"><u><em>Units</em></u></td>
		<td valign="bottom" width="9%" align="center"><u><em>No. of<br>
	   Units<br>Enrolled</em></u></td>
		<td valign="bottom" width="14%" align="center"><u><em>Remarks</em></u></td>		
	</tr>
	
	<%
	
	for( ; i < vRetResult.size(); i+=15){
		iRowCount++;
		vSubList = (Vector)vRetResult.elementAt(i+9);
	%>
	<tr>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
		%>
		<td><%=strTemp%></td>
		<td><%=(String)vRetResult.elementAt(i+6)%><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"-","","")%> &nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
		<td><%if(vSubList.size() > 0){%><%=vSubList.elementAt(1)%><%}%></td>
		<td align="center"><%if(vSubList.size() > 0){%><%=WI.getStrValue((String)vSubList.elementAt(3),(String)vRetResult.elementAt(4))%><%}%></td>
		<td align="center"><%if(vSubList.size() > 0){%><%=vSubList.elementAt(6)%><%}%></td>
		<%
		vSubList.remove(0);vSubList.remove(0);vSubList.remove(0);
		vSubList.remove(0);vSubList.remove(0);vSubList.remove(0);vSubList.remove(0);
		%>
		<td align="center"><%=(String)vRetResult.elementAt(i+10)%></td>
		<td align="center" valign="bottom"><div style=" border-bottom: solid 1px #000000; width:90%;"></div></td>
	</tr>
<%while(vSubList.size() > 0){
	iRowCount++;
%>
	<tr>		
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td><%if(vSubList.size() > 0){%><%=vSubList.elementAt(1)%><%}%></td>
		<td align="center"><%if(vSubList.size() > 0){%><%=WI.getStrValue((String)vSubList.elementAt(3),(String)vRetResult.elementAt(4))%><%}%></td>
		<td align="center"><%if(vSubList.size() > 0){%><%=vSubList.elementAt(6)%><%}%></td>
		<%
		vSubList.remove(0);vSubList.remove(0);vSubList.remove(0);
		vSubList.remove(0);vSubList.remove(0);vSubList.remove(0);vSubList.remove(0);
		%>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
<%}%>	
	
	<%
	if(iRowCount >= iNoOfStudPerPage){
		
		i+=15;
		bolPageBreak = true;
		break;
	}
	}%>
	
</table>
<%	
if(bolPageBreak){
	bolPageBreak = false;
%>
	<div style="page-break-after:always;">&nbsp;</div>
<%}	



}%>
	<script>
		window.print();
	</script>

<%}//end vRetResult%>

</body>
</html>
<%
dbOP.cleanUP();
%>
