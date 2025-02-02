<%@ page language="java" import="utility.*,java.util.Vector, enrollment.ReportRegistrar " %>
<%
WebInterface WI = new WebInterface(request);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

if(strSchCode.startsWith("SPC") && WI.fillTextValue("show_only_fail").length() == 0){%>
	<jsp:forward page="./certificate_of_grade_print_spc.jsp"></jsp:forward>
<%return;}
%>

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

<%
	DBOperation dbOP = null;
	

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


String[] astrSemester = {"Summer","<u>First</u> Semester", "<u>Second</u> Semester", "<u>Third</u> Semester", "<u>Fourth</u> Semester"};
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
		vSubjectList = (Vector)vRetResult.elementAt(15);
		strParentGuardian = (String)vRetResult.elementAt(9);
		
		strParentAddress = WI.getStrValue((String)vRetResult.elementAt(11)) + WI.getStrValue((String)vRetResult.elementAt(12),", ","","") + 
				WI.getStrValue((String)vRetResult.elementAt(13),", ","","") + WI.getStrValue((String)vRetResult.elementAt(14),", ","","");
				
		strStudentName = WebInterface.formatName((String)vRetResult.elementAt(2),(String)vRetResult.elementAt(3),(String)vRetResult.elementAt(4),5);
		
		strCourse = (String)vRetResult.elementAt(6) + WI.getStrValue((String)vRetResult.elementAt(7)," major in ","","") + 
			WI.getStrValue((String)vRetResult.elementAt(8)," - ","","");
		strExamName = WI.getStrValue((String)vRetResult.elementAt(16));
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
	<tr><td align="center" height="25"><strong><%=strSchName%> </strong>
	<br><%=strAddress%><br></td>
	</tr>
	<tr><td height="20"><%=WI.getTodaysDate(6)%></td></tr>
	<tr><td>&nbsp;</td></tr>	
	<tr><td height="20"><%=WI.getStrValue(strParentGuardian)%>&nbsp;</td></tr>
	<tr><td height="20"><%=WI.getStrValue(strParentAddress)%>&nbsp;</td></tr>
	<tr><td>&nbsp;</td></tr>	
	<tr><td height="20">Dear Parents / Guardians:</td></tr>	
	<tr><td>&nbsp;</td></tr>	
	<tr><td height="20" align="justify">
	Thank you very much for choosing <%=strSchName%> as your partner for the education
	of your son / daughter.
	</td></tr>	
	<tr><td>&nbsp;</td></tr>	
	
	<tr><td align="justify" height="20">
	
	Please be informed that <u><%=strStudentName%></U> <%=WI.getStrValue(strCourse," (",") ","")%> failed in the following subject/s during
	the <u><%=strExamName.toUpperCase()%></u> Period, <%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]%>, 
	Academic Year <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%>.
	
	</td></tr>	
	<tr><td>&nbsp;</td></tr>
	<tr>
		<td valign="top">
			<table bgcolor="#FFFFFF" align="center" width="50%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="54%" height="18" align="center">Subject</td>
					<td width="46%" align="center">Grade</td>
				</tr>
				<%
				for(int i = 0; i < vSubjectList.size(); i+=6){
					strTemp = WI.getStrValue((String)vSubjectList.elementAt(i+3),(String)vSubjectList.elementAt(i+4));
				%>
				<tr>
					<td style="padding-left:30px;" height="18"><%=WI.getStrValue(vSubjectList.elementAt(i+1)).toUpperCase()%></td>
					<td align="center"><%=strTemp%></td>
				</tr>
				<%}%>
			</table>
		</td>
	</tr>
	
	
	<tr><td>&nbsp;</td></tr>
	<tr><td height="20">Truly Yours,</td></tr>
	<tr><td height="30">&nbsp;</td></tr>
	<tr><td height="20"><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7).toUpperCase()%></td></tr>
	<tr><td height="20">Registrar</td></tr>
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
