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
								"certificate_of_grade.jsp");
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
											"certificate_of_grade.jsp");

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
String strSem    = WI.fillTextValue("semester");

String strCourseIndex = WI.fillTextValue("course_index");
String strMajorIndex  = WI.fillTextValue("major_index");
String strYearLevel   = WI.fillTextValue("year_level");

Vector vRetResult = null;

ReportRegistrar reportReg = new ReportRegistrar();


vRetResult = reportReg.getStudentListWithFailure(dbOP, request);
if(vRetResult == null)
	strErrMsg = reportReg.getErrMsg();

if(strErrMsg != null){dbOP.cleanUP();%>
	<div align="center"><strong style="font-size:14px; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></strong></div>
<%return;}

double dGWA = 0d;




String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddress = SchoolInformation.getAddressLine1(dbOP,false,false);
String strParentGuardian = null;
String strParentAddress = null;
String strStudentName = null;
String strCourse = null;
String strExamName = null;
if(vRetResult != null && vRetResult.size() > 0){
	Vector vSubjectList = null;
	while(vRetResult.size() > 0){
		
		dGWA = new student.GWA().getGWAForAStud(dbOP,(String)vRetResult.elementAt(0),
				request.getParameter("sy_from"),request.getParameter("sy_to"),
				request.getParameter("semester"), (String)vRetResult.elementAt(17),
				(String)vRetResult.elementAt(18),null);
		
	
		vSubjectList = (Vector)vRetResult.elementAt(15);
		strParentGuardian = (String)vRetResult.elementAt(9);
		
		strParentAddress = WI.getStrValue((String)vRetResult.elementAt(11)) + WI.getStrValue((String)vRetResult.elementAt(12),", ","","") + 
				WI.getStrValue((String)vRetResult.elementAt(13),", ","","") + WI.getStrValue((String)vRetResult.elementAt(14),", ","","");
				
		strStudentName = WebInterface.formatName((String)vRetResult.elementAt(2),(String)vRetResult.elementAt(3),(String)vRetResult.elementAt(4),5);
		
		strCourse = (String)vRetResult.elementAt(6) + WI.getStrValue((String)vRetResult.elementAt(7)," major in ","","") + 
			WI.getStrValue((String)vRetResult.elementAt(8)," - ","","");
		strExamName = WI.getStrValue((String)vRetResult.elementAt(16));
%>
<table bgcolor="#FFFFFF" width="80%" align="center" border="0" cellspacing="0" cellpadding="0">	
	
    <tr><td height="100">&nbsp;</td></tr>
	<tr><td height="20" align="center"><strong style="font-size:24px;"><u>C E R T I F I C A T I O N</u></strong></td></tr>
	<tr><td height="40">&nbsp;</td></tr>	
	<tr><td height="20" style="text-align:justify; font-size:14px">This &nbsp; is &nbsp; to &nbsp; certify &nbsp; that &nbsp; this &nbsp; is &nbsp; a &nbsp; TRUE &nbsp; COPY &nbsp; of &nbsp; the &nbsp; grades &nbsp; of</td></tr>
	<tr><td align="center" height="20"><strong style="font-size:14px"><%=strStudentName%><%=WI.getStrValue(strCourse," - ","","")%></strong></td></tr>
	<tr><td height="20" style="text-align:justify; font-size:14px">during the semester indicated hereunder with the corresponding units earned:</td></tr>
	
	<tr><td>&nbsp;</td></tr>	
	
	<tr>
		<td valign="top">
			<table bgcolor="#FFFFFF" width="94%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="21%" valign="top" height="18">Subject Code</td>
					<td width="55%" valign="top" style="padding-left:50px;" align="center">Description</td>
					<td width="11%" valign="top" align="center"><%=WI.getStrValue(vRetResult.elementAt(16))%><br>Grade</td>
				    <td width="13%" valign="top" align="center">Units</td>
				</tr>
				<tr>
					<%
					strTemp = astrSemester[Integer.parseInt(WI.fillTextValue("semester"))] + " SY " +WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to");
					%>
				    <td height="40" colspan="4" align="center"><strong><%=strTemp%></strong></td>
			    </tr>
				<%
				double dCE = 0d;
				for(int i = 0; i < vSubjectList.size(); i+=6){
					strTemp = WI.getStrValue((String)vSubjectList.elementAt(i+3),(String)vSubjectList.elementAt(i+4));
					
					if(strTemp.indexOf(".0") > -1)
						strTemp = strTemp.substring(0, strTemp.indexOf(".0"));
					
					try{
						dCE += Double.parseDouble(WI.getStrValue((String)vSubjectList.elementAt(i+5),"0"));
					}catch(NumberFormatException e){
						dCE += 0d;
					}
					
				%>
				<tr>
					<td height="18"><%=WI.getStrValue(vSubjectList.elementAt(i+1))%></td>
					<td height="18"><%=WI.getStrValue(vSubjectList.elementAt(i+2))%></td>
					<td align="center"><%=strTemp%></td>
					<%
					strTemp = WI.getStrValue(vSubjectList.elementAt(i+5));
					if(strTemp.indexOf(".0") > -1)
						strTemp = strTemp.substring(0, strTemp.indexOf(".0"));
					%>
				    <td align="center"><%=strTemp%></td>
				</tr>
				<%}%>
				
				<tr>
					<td height="18">&nbsp;</td>
					<td height="18" align="right"><strong>WPA</strong>&nbsp;</td>
					<td align="center"><div style="border-top:dotted 1px #000000; width:50%"><%=CommonUtil.formatFloat(dGWA, 2)%></div></td>
				    <td align="center"><div style="border-top:dotted 1px #000000; width:50%"><%=CommonUtil.formatFloat(dCE, 1)%></div></td>
				</tr>
			</table>
		</td>
	</tr>
	
	
	<tr><td height="50">&nbsp;</td></tr>
	<tr>
	  <td style="text-align:justify; font-size:14px">This certification is issued upon his/her request for whatever legal purpose it may serve him/her.</td></tr>
	
	<tr><td height="50">&nbsp;</td></tr>
	<tr><td height="20"><strong style="font-size:14px">MARIA LUISA A. BURLAZA, PhD<%//="MARIA LUISA A. BURLAZA, PhD"//CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7).toUpperCase()%></strong></td></tr>
	<tr><td height="20" style="font-size:14px">Registrar</td></tr>
	<tr><td height="30">&nbsp;</td></tr>
	<tr><td height="20" style="font-size:14px"><%=WI.getTodaysDate(6)%></td></tr>
	<tr><td height="20" style="font-size:9px"><i>Not valid without<br>the college seal</i></td></tr>
</table>
<div style="page-break-after:always;">&nbsp;</div>
<%
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	}//end of while%>
<script>
	window.print();
</script>	
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
