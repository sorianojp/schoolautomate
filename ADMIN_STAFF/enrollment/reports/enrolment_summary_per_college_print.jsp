<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Enrollment Summary - Per College</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
 td.thinBorderBottomDB{
	border-bottom-width: 4px;
	border-bottom-style: double;
	border-bottom-color: #000000;
 }
 td.thinBorderTopDB{
	border-top-width: 1px;
	border-top-style: dashed;
	border-top-color: #000000;
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 9px;
	border-bottom-width: 4px;
	border-bottom-style: double;
	border-bottom-color: #000000;
 }
.style2 {font-size: 11px}
</style>
</head>

<body>
<%
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	String strErrMsg = null;
	String strTemp2 = null;
	
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-Enrollment Summary","enrolment_summary_per_college.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"enrolment_summary_per_college.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strSchCode = (String)request.getSession(false).getAttribute("school_code");

if(strSchCode == null)
	strSchCode = "";//for UI, the detrails are different from others. UI adds elementary details.

ReportEnrollment reportEnrollment = new ReportEnrollment();
Vector vRetResult = null;
Vector vRetResultBasic = null;
Vector vRetResultGrad = null;


if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 &&
				WI.fillTextValue("reloadPage").equals("1"))		
{
	if(WI.fillTextValue("show_reports").equals("3")
		|| WI.fillTextValue("show_reports").equals("4"))
		//&& WI.fillTextValue("offering_sem").compareTo("1") == 0)
		vRetResultBasic = reportEnrollment.getBasicEnrolment(dbOP,request);
		
	if (WI.fillTextValue("show_reports").length() == 0) {
		vRetResult = reportEnrollment.getEnrollmentSummary(dbOP, request,true);
	}
		
	if (WI.fillTextValue("show_reports").equals("1")
		|| WI.fillTextValue("show_reports").equals("3")) {

		request.setAttribute("show_reports","1");
		vRetResult = reportEnrollment.getEnrollmentSummary(dbOP, request,true);
	}
	

	if (WI.fillTextValue("show_reports").equals("3")
		|| WI.fillTextValue("show_reports").equals("2")){
		request.setAttribute("show_reports","2");
		vRetResultGrad = reportEnrollment.getEnrollmentSummary(dbOP, request,true);
	}

	if(vRetResult == null || vRetResultBasic ==null)
		strErrMsg = reportEnrollment.getErrMsg();
}
boolean bolShowGradeSchInfo = true;
if(WI.fillTextValue("offering_sem").compareTo("0") == 0) 
	bolShowGradeSchInfo = false;

boolean bolShowGenderTotal = true;
	
int[] iUnivTotals = {0,0,0,0,0,0,0,0,0,0,0,0};
int[] iUnivGenderTotal = {0,0};
String[] astrSemester = {"Summer","First Semester", "Second Semester", "Third Semester"};


%>


<% if (strErrMsg != null)  {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          SUMMARY REPORT ON ENROLMENT PAGE - PER COLLEGE::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%} // (strErrMsg != null)
 

if(vRetResult != null){//System.out.println(vRetResult);
	// I have to keep track of course programs, course, and major.
	String strCourseProgram = "";
	String strCurrentCourseProgram = null;
	String strCourseName    = null;
	String strMajorName     = null;
	boolean bolShowCollege = false;

	//displays the coruse name and major name only if major and course names are different :-)
	String strCourseNameToDisp = null;
	String strMajorNameToDisp  = null;

	String str1stYrM = null;
	String str1stYrF = null;
	String str2ndYrM = null;
	String str2ndYrF = null;
	String str3rdYrM = null;
	String str3rdYrF = null;
	String str4thYrM = null;
	String str4thYrF = null;
	String str5thYrM = null;
	String str5thYrF = null;
	String str6thYrM = null;
	String str6thYrF = null;
	
	// m,f,m,f....
	int[] iCollegeTotals = {0,0,0,0,0,0,0,0,0,0,0,0};
	int[] iCollGenderTotal = {0,0};

	
	int iSubGrandTotal = 0;
	


	
%>
  <table  bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td style="font-size: 11px"> &nbsp;
		<% 
		if (WI.fillTextValue("offering_sem").equals("0") && strSchCode.startsWith("CPU"))
			strTemp2 = WI.fillTextValue("sy_to");
		else
			strTemp2 = WI.fillTextValue("sy_from") + "-"+ WI.fillTextValue("sy_to");
		
		if(WI.fillTextValue("show_reports").length() == 0) 
			strTemp = "";
		else
			strTemp = "Undergraduates";
		
		if (strSchCode.startsWith("CPU")) { %>
		
			CPU Detailed Enrollment Summary <%=WI.getStrValue(strTemp," - "," - "," ")%>
			<%=astrSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>
			<%=strTemp2%> (As of <%=WI.getTodaysDate(10)%>) 
		<%}else {%>
			Enrollment Summary <%=WI.getStrValue(strTemp," - "," - "," ")%> 
			<%=astrSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>
			<%=strTemp2%> (As of <%=WI.getTodaysDate(10)%>) 
		<%}%>
		</td>
	</tr>
	<tr>
		<td>&nbsp;  </td>
	</tr>	
  </table>
 <%
	if (WI.fillTextValue("show_border").equals("1"))
		strTemp = " border='1'";
	else
		strTemp = "";
 %>
  
  
  <table  bgcolor="#FFFFFF" width="100%" <%=strTemp%> cellspacing="0" cellpadding="0">
    <% int j = 0; int k = 0;

	for(int i = 1 ; i< vRetResult.size() ;){//outer loop for each course program.

	strCourseProgram = (String)vRetResult.elementAt(i);
	bolShowCollege= true;
	
	for (k =0; k < 12; k++) 
		iCollegeTotals[k] = 0;
//reset college gender total		
		iCollGenderTotal[0] = 0;
		iCollGenderTotal[1] = 0;
//reset college gender total
	
	strCourseName = null;
	iSubGrandTotal = 0;

	if (i == 1) {%>
    <tr> 
      <td width="9%" rowspan="2" valign="bottom"><div align="center"><strong><font size="1">COLLEGE</font></strong></div></td>
      <td width="10%" rowspan="2" valign="bottom"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
      <% if (!WI.fillTextValue("hide_major").equals("1")) {%>
      <td width="5%" rowspan="2" align="center" valign="bottom"><strong><font size="1">MAJOR</font></strong></td>
      <%}%>
      <td height="16" colspan="2"><div align="center"><strong><font size="1">First 
          Year</font></strong></div></td>
      <td colspan="2"> <div align="center"><strong><font size="1">Second Year</font></strong></div></td>
      <td colspan="2"> <div align="center"><strong><font size="1">Third Year</font></strong></div></td>
      <td colspan="2"> <div align="center"><strong><font size="1">Fourth Year</font></strong></div></td>
      <td colspan="2"> <div align="center"><strong><font size="1">Fifth Year</font></strong></div></td>
      <td colspan="2"><div align="center"><strong><font size="1">Sixth Year</font></strong></div></td>
      <td colspan="2"> <div align="center">&nbsp;<strong><font size="1">TOTAL 
          </font></strong></div></td>
      <td width="5%" rowspan="2" valign="bottom"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
    </tr>
    <tr> 
      <td width="5%" height="12" align="right"><font size="1">Male</font></td>
      <td width="4%" align="right"><font size="1">Female</font></td>
      <td width="5%" align="right"><font size="1">Male</font></td>
      <td width="4%" align="right"><font size="1">Female</font></td>
      <td width="5%" align="right"><font size="1">Male</font></td>
      <td width="4%" align="right"><font size="1">Female</font></td>
      <td width="5%" align="right"><font size="1">Male</font></td>
      <td width="4%" align="right"><font size="1">Female</font></td>
      <td width="5%" align="right"><font size="1">Male</font></td>
      <td width="4%" align="right"><font size="1">Female</font></td>
      <td width="5%" align="right"><font size="1">Male</font></td>
      <td width="4%" align="right"><font size="1">Female</font></td>
      <td width="6%" align="right"><font size="1">Male</font></td>
      <td width="4%" align="right"><font size="1">Female</font></td>
    </tr>
    <%}%>
    <%
	for(j = i; j< vRetResult.size();){//Inner loop for course/major for a course program.
	strCurrentCourseProgram = "";

	
	if(!strCourseProgram.equals((String)vRetResult.elementAt(j))){
		break; 
	}
	
	if (bolShowCollege){
		bolShowCollege = false;
		strCurrentCourseProgram = strCourseProgram;
	}
	

	if(strCourseName == null || strCourseName.compareTo((String)vRetResult.elementAt(j+1)) !=0)
	{
		strCourseName = (String)vRetResult.elementAt(j+1);
		strCourseNameToDisp = strCourseName;
		strMajorName = WI.getStrValue(vRetResult.elementAt(j+2));
		strMajorNameToDisp = strMajorName;
	}
	else if(strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0)//course name is same.
	{
		strCourseNameToDisp = "&nbsp;";
		if(strMajorName == null || strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2)) ) !=0)
		{
			strMajorName = WI.getStrValue(vRetResult.elementAt(j+2));
			strMajorNameToDisp = strMajorName;

		}
		else if(strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2)) ) ==0)
			strMajorNameToDisp = "&nbsp;";
	}
	str1stYrM = null;str1stYrF = null;
	str2ndYrM = null;str2ndYrF = null;str3rdYrM = null;str3rdYrF = null;str4thYrM = null;str4thYrF = null;
	str5thYrM = null;str5thYrF = null;str6thYrM = null;str6thYrF = null;
	iSubTotal = 0;
	//collect information for each year level for a course/major.
	
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).equals("1") &&
		((String)vRetResult.elementAt(j+4)).equals("M")) // 1st year. male.
	{
		str1stYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrM);
		iCollegeTotals[0] += Integer.parseInt(str1stYrM);
		iUnivTotals[0] += Integer.parseInt(str1stYrM);
		iCollGenderTotal[0] +=Integer.parseInt(str1stYrM);
		iUnivGenderTotal[0] +=Integer.parseInt(str1stYrM);
		j += 6;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).equals("1") &&
		((String)vRetResult.elementAt(j+4)).equals("F")) // 1st year. male.
	{
		str1stYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrF);
		iCollegeTotals[1] += Integer.parseInt(str1stYrF);
		iUnivTotals[1] += Integer.parseInt(str1stYrF);
		iCollGenderTotal[1] +=Integer.parseInt(str1stYrF);
		iUnivGenderTotal[1] +=Integer.parseInt(str1stYrF);


		j += 6;
	}
	//2nd year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).equals("2") &&
		((String)vRetResult.elementAt(j+4)).equals("M")) // 1st year. male.
	{
		str2ndYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str2ndYrM);
		iCollegeTotals[2] += Integer.parseInt(str2ndYrM);
		iUnivTotals[2] += Integer.parseInt(str2ndYrM);
		iCollGenderTotal[0] +=Integer.parseInt(str2ndYrM);
		iUnivGenderTotal[0] +=Integer.parseInt(str2ndYrM);

		j += 6;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).equals("2") &&
		((String)vRetResult.elementAt(j+4)).equals("F")) // 1st year. male.
	{
		str2ndYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str2ndYrF);
		iCollegeTotals[3] += Integer.parseInt(str2ndYrF);
		iUnivTotals[3] += Integer.parseInt(str2ndYrF);
		iCollGenderTotal[1] +=Integer.parseInt(str2ndYrF);
		iUnivGenderTotal[1] +=Integer.parseInt(str2ndYrF);

		j += 6;
	}
	//3rd year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).equals("3") &&
		((String)vRetResult.elementAt(j+4)).equals("M")) // 1st year. male.
	{
		str3rdYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str3rdYrM);
		iCollegeTotals[4] += Integer.parseInt(str3rdYrM);
		iUnivTotals[4] += Integer.parseInt(str3rdYrM);
		iCollGenderTotal[0] +=Integer.parseInt(str3rdYrM);
		iUnivGenderTotal[0] +=Integer.parseInt(str3rdYrM);
		
		j += 6;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).equals("3") &&
		((String)vRetResult.elementAt(j+4)).equals("F")) // 1st year. male.
	{
		str3rdYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str3rdYrF);
		iCollegeTotals[5] += Integer.parseInt(str3rdYrF);
		iUnivTotals[5] += Integer.parseInt(str3rdYrF);
		iCollGenderTotal[1] +=Integer.parseInt(str3rdYrF);
		iUnivGenderTotal[1] +=Integer.parseInt(str3rdYrF);
		
		j += 6;
	}
	//4th year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).equals("4") &&
		((String)vRetResult.elementAt(j+4)).equals("M")) // 1st year. male.
	{
		str4thYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str4thYrM);
		iCollegeTotals[6] += Integer.parseInt(str4thYrM);
		iUnivTotals[6] += Integer.parseInt(str4thYrM);
		iCollGenderTotal[0] +=Integer.parseInt(str4thYrM);
		iUnivGenderTotal[0] +=Integer.parseInt(str4thYrM);

		j += 6;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).equals("4") &&
		((String)vRetResult.elementAt(j+4)).equals("F")) // 1st year. male.
	{
		str4thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str4thYrF);
		iCollegeTotals[7] += Integer.parseInt(str4thYrF);
		iUnivTotals[7] += Integer.parseInt(str4thYrF);
		iCollGenderTotal[1] +=Integer.parseInt(str4thYrF);
		iUnivGenderTotal[1] +=Integer.parseInt(str4thYrF);

		j += 6;
	}
	//5th year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).equals("5") &&
		((String)vRetResult.elementAt(j+4)).equals("M")) // 1st year. male.
	{
		str5thYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str5thYrM);
		iCollegeTotals[8] += Integer.parseInt(str5thYrM);
		iUnivTotals[8] += Integer.parseInt(str5thYrM);
		iCollGenderTotal[0] +=Integer.parseInt(str5thYrM);
		iUnivGenderTotal[0] +=Integer.parseInt(str5thYrM);
		
		j += 6;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).equals("5") &&
		((String)vRetResult.elementAt(j+4)).equals("F")) // 1st year. male.
	{
		str5thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str5thYrF);
		iCollegeTotals[9] += Integer.parseInt(str5thYrF);
		iUnivTotals[9] += Integer.parseInt(str5thYrF);
		iCollGenderTotal[1] +=Integer.parseInt(str5thYrF);
		iUnivGenderTotal[1] +=Integer.parseInt(str5thYrF);
		
		j += 6;
	}
	//6th year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).equals("6") &&
		((String)vRetResult.elementAt(j+4)).equals("M")) // 1st year. male.
	{
		str6thYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str6thYrM);
		iCollegeTotals[10] += Integer.parseInt(str6thYrM);
		iUnivTotals[10] += Integer.parseInt(str6thYrM);
		iCollGenderTotal[0] +=Integer.parseInt(str6thYrM);
		iUnivGenderTotal[0] +=Integer.parseInt(str6thYrM);

		j += 6;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).equals("6") &&
		((String)vRetResult.elementAt(j+4)).equals("F")) // 1st year. male.
	{
		str6thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str6thYrF);
		iCollegeTotals[11] += Integer.parseInt(str6thYrF);
		iUnivTotals[11] += Integer.parseInt(str6thYrF);
		iCollGenderTotal[1] +=Integer.parseInt(str6thYrF);
		iUnivGenderTotal[1] +=Integer.parseInt(str6thYrF);

		j += 6;
	}
	if(iSubTotal == 0) {
		System.out.println("------ Wrong Yr Level in Enrollment Summary ----------");
		System.out.println(" Course Name : "+vRetResult.elementAt(j+1));
		System.out.println(" strMajorName : "+vRetResult.elementAt(j+2));
		System.out.println(" Year Level : "+vRetResult.elementAt(j+3));
		System.out.println(" Gender : "+vRetResult.elementAt(j+4));
		
		j += 6;
	}
	iSubGrandTotal += iSubTotal;
i = j;


	%>
    <tr> 
      <td><font size="1">&nbsp;<%=strCurrentCourseProgram%></font></td>
      <td height="20"><font size="1">&nbsp;<%=strCourseNameToDisp%></font></td>
      <%if(!WI.fillTextValue("hide_major").equals("1")){%>
      <td><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(strMajorNameToDisp)%></font></td>
      <%}%>
      <td align="right"><font size="1"><%=WI.getStrValue(str1stYrM,"-")%></font></td>
      <td align="right"><font size="1">&nbsp;<%=WI.getStrValue(str1stYrF,"-")%></font></td>
      <td align="right"><font size="1">&nbsp;<%=WI.getStrValue(str2ndYrM,"-")%></font></td>
      <td align="right"><font size="1">&nbsp;<%=WI.getStrValue(str2ndYrF,"-")%></font></td>
      <td align="right"><font size="1">&nbsp;<%=WI.getStrValue(str3rdYrM,"-")%></font></td>
      <td align="right"><font size="1">&nbsp;<%=WI.getStrValue(str3rdYrF,"-")%></font></td>
      <td align="right"><font size="1">&nbsp;<%=WI.getStrValue(str4thYrM,"-")%></font></td>
      <td align="right"><font size="1">&nbsp;<%=WI.getStrValue(str4thYrF,"-")%></font></td>
      <td align="right"><font size="1">&nbsp;<%=WI.getStrValue(str5thYrM,"-")%></font></td>
      <td align="right"><font size="1">&nbsp;<%=WI.getStrValue(str5thYrF,"-")%></font></td>
      <td align="right"><font size="1">&nbsp;<%=WI.getStrValue(str6thYrM,"-")%></font></td>
      <td align="right"><font size="1">&nbsp;<%=WI.getStrValue(str6thYrF,"-")%></font></td>
      <td align="right"><font size="1">
        <%if(bolShowGenderTotal){%>
        <%=Integer.parseInt(WI.getStrValue(str1stYrM,"0"))+Integer.parseInt(WI.getStrValue(str2ndYrM,"0"))+Integer.parseInt(WI.getStrValue(str3rdYrM,"0"))+
	  Integer.parseInt(WI.getStrValue(str4thYrM,"0"))+Integer.parseInt(WI.getStrValue(str5thYrM,"0"))%> 
        <%}else{%>
        <%=WI.getStrValue(str6thYrM,"&nbsp;")%> 
        <%}%>
        </font></td>
      <td align="right"><font size="1">
        <%if(bolShowGenderTotal){%>
        <%=Integer.parseInt(WI.getStrValue(str1stYrF,"0"))+Integer.parseInt(WI.getStrValue(str2ndYrF,"0"))+Integer.parseInt(WI.getStrValue(str3rdYrF,"0"))+
	  Integer.parseInt(WI.getStrValue(str4thYrF,"0"))+Integer.parseInt(WI.getStrValue(str5thYrF,"0"))%> 
        <%}else{%>
        <%=WI.getStrValue(str6thYrF,"&nbsp;")%> 
        <%}%>
        </font></td>
      <td><div align="right"><font size="1"><%=iSubTotal%></font></div></td>
    </tr>
    <%}
	
		if (WI.fillTextValue("hide_major").equals("1"))
			strTemp = "2";
		else
			strTemp = "3";
	%>
    <tr> 
      <td height="20" colspan="<%=strTemp%>"><div align="right"><font size="1">COLLEGE 
          TOTALS:&nbsp;&nbsp;<strong>&nbsp;&nbsp;</strong></font></div></td>
      <td align="right"><font size="1">&nbsp;<%=iCollegeTotals[0]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollegeTotals[1]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollegeTotals[2]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollegeTotals[3]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollegeTotals[4]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollegeTotals[5]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollegeTotals[6]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollegeTotals[7]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollegeTotals[8]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollegeTotals[9]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollegeTotals[10]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollegeTotals[11]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollGenderTotal[0]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iCollGenderTotal[1]%></font></td>
      <td align="right"><font size="1">&nbsp;<%=iSubGrandTotal%></font></td>
    </tr>
    <%}//outer most loop%>
	<% 
	  if (!WI.fillTextValue("show_border").equals("1")) 
			strTemp2 = "class=\"thinBorderTopDB\"";
	  else
			strTemp2 = "";		
	
	   
	  if (WI.fillTextValue("hide_major").equals("1"))
			strTemp = "2";
		else
			strTemp = "3";		
	%>
    <tr > 
      <td height="25" colspan="<%=strTemp%>" <%=strTemp2%>><font size="1">&nbsp;TOTAL </font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivTotals[0]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivTotals[1]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivTotals[2]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivTotals[3]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivTotals[4]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivTotals[5]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivTotals[6]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivTotals[7]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivTotals[8]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivTotals[9]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivTotals[10]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivTotals[11]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivGenderTotal[0]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivGenderTotal[1]%></font></td>
      <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iUnivGenderTotal[0] + iUnivGenderTotal[1]%></font></td>
    </tr>  	
  </table>
<% if (WI.fillTextValue("show_reports").equals("3")){%>
<br><br>
<span class="style2">Printed : <%=WI.getTodaysDate()%></span>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%} // if (WI.fillTextValue("show_reports").equals("3")
} // vRetResult != null

if (vRetResultGrad != null && vRetResultGrad.size() > 0){

	String strCourseProgram = "";
	String strCurrentCourseProgram = null;
	String strCourseName    = null;
	String strMajorName     = null;
	boolean bolShowCollege = false;

	//displays the coruse name and major name only if major and course names are different :-)
	String strCourseNameToDisp = null;
	String strMajorNameToDisp  = null;

	String str1stYrM = null;
	String str1stYrF = null;
	String str2ndYrM = null;
	String str2ndYrF = null;
	String str3rdYrM = null;
	String str3rdYrF = null;
	String str4thYrM = null;
	String str4thYrF = null;
	String str5thYrM = null;
	String str5thYrF = null;
	String str6thYrM = null;
	String str6thYrF = null;
	
	// m,f,m,f....
	int[] iCollegeTotals = {0,0,0,0,0,0,0,0,0,0,0,0};
	int[] iCollGenderTotal = {0,0};
	
	int iSubGrandTotal = 0;
%> 
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
  <tr>
    <td>
  
	  <table width="100%" align="center" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
          <tr> 
            <td style="font-size:11px"> <% 
		if (WI.fillTextValue("offering_sem").equals("0") && strSchCode.startsWith("CPU"))
			strTemp2 = WI.fillTextValue("sy_to");
		else
			strTemp2 = WI.fillTextValue("sy_from") + "-"+ WI.fillTextValue("sy_to");
		
		if(WI.fillTextValue("show_reports").length() == 0) 
			strTemp = "";
		else
			strTemp = "Graduate School";
		
		if (strSchCode.startsWith("CPU")) { %>
              CPU Detailed Enrollment Summary <%=WI.getStrValue(strTemp," - "," - "," ")%> <%=astrSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> <%=strTemp2%> (As of <%=WI.getTodaysDate(10)%>) 
              <%}else {%>
              Enrollment Summary <%=WI.getStrValue(strTemp,"-","-"," ")%> <%=astrSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> <%=strTemp2%> (As of <%=WI.getTodaysDate(10)%>) 
              <%}%> </td>
          </tr>
          <tr>
            <td style="font-size:11px">&nbsp;</td>
          </tr>
      </table>
   <%
		if (WI.fillTextValue("show_border").equals("1"))
			strTemp = " border='1'";
		else
			strTemp = "";
   %>
	  
        <table width="75%" <%=strTemp%> align="center" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
  <% int j = 0; int k = 0;

	for(int i = 1 ; i< vRetResultGrad.size() ;){
	//outer loop for each course program.

	strCourseProgram = (String)vRetResultGrad.elementAt(i);
	bolShowCollege= true;
	
	for (k =0; k < 12; k++) 
		iCollegeTotals[k] = 0;
//reset college gender total		
		iCollGenderTotal[0] = 0;
		iCollGenderTotal[1] = 0;
//reset college gender total
	
	strCourseName = null;
	iSubGrandTotal = 0;

	if (i == 1) {%>
  <tr> 
    <td height="25"><div align="center"><strong><font size="1">COLLEGE</font></strong></div></td>
    <td><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
    <% if (!WI.fillTextValue("hide_major").equals("1")) {%>
    <td align="center"><strong><font size="1">MAJOR</font></strong></td>
    <%}%>
    <td height="12" align="right"><font size="1"><strong>Male&nbsp;</strong></font></td>
    <td align="right"><font size="1"><strong>Female&nbsp;</strong></font></td>
    <td><div align="right"><strong><font size="1">TOTAL&nbsp;&nbsp;</font></strong></div></td>
  </tr>
  <tr> </tr>
  <%}%>
  <%
	for(j = i; j< vRetResultGrad.size();){//Inner loop for course/major for a course program.
	strCurrentCourseProgram = "";

	
	if(!strCourseProgram.equals((String)vRetResultGrad.elementAt(j))){
		break; 
	}
	
	if (bolShowCollege){
		bolShowCollege = false;
		strCurrentCourseProgram = strCourseProgram;
	}
	

	if(strCourseName == null || strCourseName.compareTo((String)vRetResultGrad.elementAt(j+1)) !=0)
	{
		strCourseName = (String)vRetResultGrad.elementAt(j+1);
		strCourseNameToDisp = strCourseName;
		strMajorName = WI.getStrValue(vRetResultGrad.elementAt(j+2));
		strMajorNameToDisp = strMajorName;
	}
	else if(strCourseName.compareTo((String)vRetResultGrad.elementAt(j+1)) ==0)//course name is same.
	{
		strCourseNameToDisp = "&nbsp;";
		if(strMajorName == null || strMajorName.compareTo(WI.getStrValue(vRetResultGrad.elementAt(j+2)) ) !=0)
		{
			strMajorName = WI.getStrValue(vRetResultGrad.elementAt(j+2));
			strMajorNameToDisp = strMajorName;

		}
		else if(strMajorName.compareTo(WI.getStrValue(vRetResultGrad.elementAt(j+2)) ) ==0)
			strMajorNameToDisp = "&nbsp;";
	}
	str1stYrM = null;str1stYrF = null;
	str2ndYrM = null;str2ndYrF = null;str3rdYrM = null;str3rdYrF = null;str4thYrM = null;str4thYrF = null;
	str5thYrM = null;str5thYrF = null;str6thYrM = null;str6thYrF = null;
	iSubTotal = 0;
	//collect information for each year level for a course/major.
	
	if(j < vRetResultGrad.size() && strCourseName.compareTo((String)vRetResultGrad.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResultGrad.elementAt(j+2))) == 0 &&
		((String)vRetResultGrad.elementAt(j+3)).equals("1") &&
		((String)vRetResultGrad.elementAt(j+4)).equals("M")) // 1st year. male.
	{
		str1stYrM = (String)vRetResultGrad.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrM);
		iCollegeTotals[0] += Integer.parseInt(str1stYrM);
		iUnivTotals[0] += Integer.parseInt(str1stYrM);
		iCollGenderTotal[0] +=Integer.parseInt(str1stYrM);
		iUnivGenderTotal[0] +=Integer.parseInt(str1stYrM);
		j += 6;
	}
	if(j < vRetResultGrad.size() && strCourseName.compareTo((String)vRetResultGrad.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResultGrad.elementAt(j+2))) == 0 &&
		((String)vRetResultGrad.elementAt(j+3)).equals("1") &&
		((String)vRetResultGrad.elementAt(j+4)).equals("F")) // 1st year. male.
	{
		str1stYrF = (String)vRetResultGrad.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrF);
		iCollegeTotals[1] += Integer.parseInt(str1stYrF);
		iUnivTotals[1] += Integer.parseInt(str1stYrF);
		iCollGenderTotal[1] +=Integer.parseInt(str1stYrF);
		iUnivGenderTotal[1] +=Integer.parseInt(str1stYrF);


		j += 6;
	}
	//2nd year.
	if(j < vRetResultGrad.size() && strCourseName.compareTo((String)vRetResultGrad.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResultGrad.elementAt(j+2))) == 0 &&
		((String)vRetResultGrad.elementAt(j+3)).equals("2") &&
		((String)vRetResultGrad.elementAt(j+4)).equals("M")) // 1st year. male.
	{
		str2ndYrM = (String)vRetResultGrad.elementAt(j+5);
		iSubTotal += Integer.parseInt(str2ndYrM);
		iCollegeTotals[2] += Integer.parseInt(str2ndYrM);
		iUnivTotals[2] += Integer.parseInt(str2ndYrM);
		iCollGenderTotal[0] +=Integer.parseInt(str2ndYrM);
		iUnivGenderTotal[0] +=Integer.parseInt(str2ndYrM);

		j += 6;
	}
	if(j < vRetResultGrad.size() && strCourseName.compareTo((String)vRetResultGrad.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResultGrad.elementAt(j+2))) == 0 &&
		((String)vRetResultGrad.elementAt(j+3)).equals("2") &&
		((String)vRetResultGrad.elementAt(j+4)).equals("F")) // 1st year. male.
	{
		str2ndYrF = (String)vRetResultGrad.elementAt(j+5);
		iSubTotal += Integer.parseInt(str2ndYrF);
		iCollegeTotals[3] += Integer.parseInt(str2ndYrF);
		iUnivTotals[3] += Integer.parseInt(str2ndYrF);
		iCollGenderTotal[1] +=Integer.parseInt(str2ndYrF);
		iUnivGenderTotal[1] +=Integer.parseInt(str2ndYrF);

		j += 6;
	}

	iSubGrandTotal += iSubTotal;
	i = j;

	%>
  <tr> 
    <td><font size="1">&nbsp;&nbsp;<%=strCurrentCourseProgram%></font></td>
    <td height="20"><font size="1">&nbsp;<%=strCourseNameToDisp%></font></td>
    <%if(!WI.fillTextValue("hide_major").equals("1")){%>
    <td><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(strMajorNameToDisp)%></font></td>
    <%}%>
    <td align="right"><font size="1"><%=WI.getStrValue(str1stYrM,"-")%>&nbsp;&nbsp;</font></td>
    <td align="right"><font size="1">&nbsp;<%=WI.getStrValue(str1stYrF,"-")%>&nbsp;&nbsp;</font></td>
    <td><div align="right"><font size="1"><%=iSubTotal%>&nbsp;&nbsp;&nbsp;&nbsp;</font></div></td>
  </tr>
  <%}
	
		if (WI.fillTextValue("hide_major").equals("1"))
			strTemp = "2";
		else
			strTemp = "3";
	%>
  <%}//outer most loop
  
  
  	if (!WI.fillTextValue("show_border").equals("1"))
		strTemp2= " class=\"thinBorderTopDB\" ";
	else
		strTemp2 = "";
  %>
  
  
  <tr> 
    <td height="25" colspan="<%=strTemp%>" <%=strTemp2%>><font size="1">&nbsp;&nbsp;TOTAL </font></td>
    <td align="right" <%=strTemp2%>><font size="1">&nbsp;&nbsp;<%=iCollGenderTotal[0]%>&nbsp;&nbsp;</font></td>
    <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iCollGenderTotal[1]%>&nbsp;&nbsp;</font></td>
    <td align="right" <%=strTemp2%>><font size="1">&nbsp;<%=iCollGenderTotal[0] + iCollGenderTotal[1]%>&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
  </tr>
</table>
        <br>
        <br>
        <br>
        <br></td>
  </tr>
  </table>
<%}	
	if (vRetResultBasic != null && vRetResultBasic.size()!=0){ 
	
	int[] iCollegeTotals = {0,0,0,0,0,0,0,0,0,0,0,0};
	int iIndex = 0 ;
	int iMaxIndex = 0;
	int iColumnsPrinted = 0;
	int iColumnsNeeded = 12;
%>

  <table width="100%" align="center" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td style="font-size:11px"> <% 
		if (WI.fillTextValue("offering_sem").equals("0") && strSchCode.startsWith("CPU"))
			strTemp2 = WI.fillTextValue("sy_to");
		else
			strTemp2 = WI.fillTextValue("sy_from") + "-"+ WI.fillTextValue("sy_to");
		
		if(WI.fillTextValue("show_reports").length() == 0) 
			strTemp = "";
		else
			strTemp = "Graduate School";
		
		if (strSchCode.startsWith("CPU")) { %>
        CPU Detailed Enrollment Summary <%=WI.getStrValue(strTemp," - "," - "," ")%> <%=astrSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> <%=strTemp2%> (As of <%=WI.getTodaysDate(10)%>) 
        <%}else {%>
        Enrollment Summary <%=WI.getStrValue(strTemp,"-","-"," ")%> <%=astrSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> <%=strTemp2%> (As of <%=WI.getTodaysDate(10)%>) 
        <%}%> </td>
    </tr>
    <tr>
      <td style="font-size:11px">&nbsp;</td>
    </tr>
  </table>
<%
	if (WI.fillTextValue("show_border").equals("1"))
		strTemp = "border='1'";
	else
		strTemp = "";
%>

  <table  bgcolor="#FFFFFF" width="100%" <%=strTemp%> cellspacing="0" cellpadding="0">
    <tr> 
      <td width="15%" rowspan="2" valign="bottom"><font size="1"><strong>&nbsp;DEPARMENT</strong></font></td>
      <td height="13" colspan="2"><div align="center"><strong><font size="1">First 
          Yr/Gr</font></strong></div></td>
      <td colspan="2"><div align="center"><strong><font size="1">Second Yr/Gr</font></strong></div></td>
      <td colspan="2"><div align="center"><strong><font size="1">Third Yr/Gr</font></strong></div></td>
      <td colspan="2"><div align="center"><strong><font size="1">Fourth Yr/Gr</font></strong></div></td>
      <td colspan="2"><div align="center"><strong><font size="1">Fifth Yr/Gr</font></strong></div></td>
      <td colspan="2"><div align="center"><strong><font size="1">Sixth Yr/Gr</font></strong></div></td>
      <td colspan="2"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
      <td width="8%" rowspan="2" valign="bottom"><div align="center"><font size="1"><strong>TOTAL</strong></font></div></td>
    </tr>
    <tr> 
      <td width="6%" align="right"><font size="1">Male&nbsp;</font></td>
      <td width="5%" align="right"><font size="1">Female&nbsp;</font></td>
      <td width="6%" align="right"><font size="1">Male&nbsp;</font></td>
      <td width="5%" align="right"><font size="1">Female&nbsp;</font></td>
      <td width="6%" align="right"><font size="1">Male&nbsp;</font></td>
      <td width="5%" align="right"><font size="1">Female</font></td>
      <td width="6%" align="right"><font size="1">Male</font></td>
      <td width="5%" align="right"><font size="1">Female</font></td>
      <td width="6%" align="right"><font size="1">Male</font></td>
      <td width="5%" align="right"><font size="1">Female</font></td>
      <td width="6%" align="right"><font size="1">Male</font></td>
      <td width="5%" align="right"><font size="1">Female</font></td>
      <td width="6%" align="right"><font size="1">Male</font></td>
      <td width="5%" align="right"><font size="1">Female</font></td>
    </tr>
    <tr> 
      <td height="25" valign="middle">&nbsp;<font size="1">High School</font></td>
      <% iIndex = 20;
	   iColumnsPrinted= 0;
	   int[] iCollGenderTotal={0,0};
	   int[] iRowTotal={0,0};
       
	   while (iIndex < vRetResultBasic.size()){
		if ((iIndex%2)==1){
			iCollGenderTotal[0] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
			iUnivGenderTotal[0] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
			iUnivTotals[iColumnsPrinted] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
			iCollegeTotals[iColumnsPrinted] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
			}else{
			iCollGenderTotal[1] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
			iUnivGenderTotal[1] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
			iUnivTotals[iColumnsPrinted] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
			iCollegeTotals[iColumnsPrinted] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
		}
		
		++iColumnsPrinted;
	  %>
      <td align="right" valign="middle"><font size="1">&nbsp;<%=(String)vRetResultBasic.elementAt(iIndex)%>&nbsp;</font></td>
      <% ++iIndex;
	  }
	  	while (iColumnsPrinted < iColumnsNeeded) {
			++iColumnsPrinted;
	  %>
      <td align="right" valign="middle"><font size="1">0&nbsp;</font></td>
      <%}
	  
	  %>
      <td align="right" valign="middle"><font size="1">&nbsp;<%=iCollGenderTotal[0]%>&nbsp;</font></td>
      <td align="right" valign="middle"><font size="1">&nbsp;<%=iCollGenderTotal[1]%>&nbsp;</font></td>
      <td align="right" valign="middle"><font size="1">&nbsp;<%=iCollGenderTotal[0] + iCollGenderTotal[1]%>&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="25" valign="middle"> &nbsp;<font size="1">Elementary</font></td>
      <% iIndex = 6;
	   iColumnsPrinted= 0;
	   iRowTotal[0]=0;
	   iRowTotal[1]=0;
    	   iMaxIndex = 18;  // disregarding GRADE 7 i case grade 7 is required.. set value to 20
	   while (iIndex < iMaxIndex){
		if ((iIndex%2)==1){
			iRowTotal[0] += Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
			iCollGenderTotal[0] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
			iUnivGenderTotal[0] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
			iUnivTotals[iColumnsPrinted] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));					
			iCollegeTotals[iColumnsPrinted] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
		}else{
			iRowTotal[1] += Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
			iCollGenderTotal[1] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
			iUnivGenderTotal[1] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
			iUnivTotals[iColumnsPrinted] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
			iCollegeTotals[iColumnsPrinted] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
		}
		
		++iColumnsPrinted;
	  %>
      <td align="right" valign="middle"><font size="1">&nbsp;<%=(String)vRetResultBasic.elementAt(iIndex)%>&nbsp;</font></td>
      <% ++iIndex;
	  }
	  	while (iColumnsPrinted < iColumnsNeeded) {
			++iColumnsPrinted;
	  %>
      <td align="right" valign="middle"><font size="1">0&nbsp;</font></td>
      <%}
	  
	  %>
      <td align="right" valign="middle"><font size="1">&nbsp;<%=iRowTotal[0]%>&nbsp;</font></td>
      <td align="right" valign="middle"><font size="1">&nbsp;<%=iRowTotal[1]%>&nbsp;</font></td>
      <td align="right" valign="middle"><font size="1">&nbsp;<%=iRowTotal[0] + iRowTotal[1]%>&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="25" valign="middle"><font size="1">&nbsp;Kindergarten</font></td>
      <% iIndex = 0;
	   iColumnsPrinted= 0;
	   iRowTotal[0]=0;
	   iRowTotal[1]=0;
    	   iMaxIndex = 6;  // 
	   while (iIndex < iMaxIndex){
		if ((iIndex%2)==1){
			iRowTotal[0] += Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
			iCollGenderTotal[0] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
			iUnivGenderTotal[0] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
			iUnivTotals[iColumnsPrinted] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
			iCollegeTotals[iColumnsPrinted] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));											
		}else{
			iRowTotal[1] += Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
			iCollGenderTotal[1] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
			iUnivGenderTotal[1] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
			iUnivTotals[iColumnsPrinted] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
			iCollegeTotals[iColumnsPrinted] +=Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));				
		}
		
		++iColumnsPrinted;
	  %>
      <td align="right" valign="middle"><font size="1">&nbsp;<%=(String)vRetResultBasic.elementAt(iIndex)%>&nbsp;</font></td>
      <% ++iIndex;
	  }
	  	while (iColumnsPrinted < iColumnsNeeded) {
			++iColumnsPrinted;
	  %>
      <td align="right" valign="middle"><font size="1">0&nbsp;</font></td>
      <%}
	  
	  %>
      <td align="right" valign="middle"><font size="1">&nbsp;<%=iRowTotal[0]%>&nbsp;</font></td>
      <td align="right" valign="middle"><font size="1">&nbsp;<%=iRowTotal[1]%>&nbsp;</font></td>
      <td align="right" valign="middle"><font size="1">&nbsp;<%=iRowTotal[0] + iRowTotal[1]%>&nbsp;</font></td>
    </tr>
    <% if (!WI.fillTextValue("show_border").equals("1")) 
			strTemp = " class=\"thinBorderTopDB\"";
		else
			strTemp = "";
    %>
    <tr> 
      <td height="25" align="right" <%=strTemp%>><font size="1">TOTAL : &nbsp;&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollegeTotals[0]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollegeTotals[1]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollegeTotals[2]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollegeTotals[3]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollegeTotals[4]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollegeTotals[5]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollegeTotals[6]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollegeTotals[7]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollegeTotals[8]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollegeTotals[9]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollegeTotals[10]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollegeTotals[11]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollGenderTotal[0]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollGenderTotal[1]%>&nbsp;</font></td>
      <td align="right"<%=strTemp%>><font size="1"><%=iCollGenderTotal[0] + iCollGenderTotal[1]%>&nbsp;</font></td>
    </tr>
  </table>

  <% } // end vRetResultBasic

 if ((vRetResult != null && vRetResult.size() > 0)  ||
		(vRetResultGrad != null && vRetResultGrad.size() > 0) ||
		(vRetResultBasic != null && vRetResultBasic.size() > 0)) {


	// show only grand total if show reports is split
	
	if (WI.fillTextValue("show_reports").equals("3"))  {		
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="15%" height="18" class="thinBorderBottomDB"><font size="1">&nbsp;&nbsp;GRAND 
        &nbsp;TOTAL </font></td>
      <td width="6%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivTotals[0]%></font></td>
      <td width="5%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivTotals[1]%></font></td>
      <td width="6%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivTotals[2]%></font></td>
      <td width="5%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivTotals[3]%></font></td>
      <td width="6%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivTotals[4]%></font></td>
      <td width="5%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivTotals[5]%></font></td>
      <td width="6%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivTotals[6]%></font></td>
      <td width="5%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivTotals[7]%></font></td>
      <td width="6%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivTotals[8]%></font></td>
      <td width="5%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivTotals[9]%></font></td>
      <td width="6%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivTotals[10]%></font></td>
      <td width="5%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivTotals[11]%></font></td>
      <td width="6%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivGenderTotal[0]%></font></td>
      <td width="5%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivGenderTotal[1]%></font></td>
      <td width="8%" align="right" class="thinBorderBottomDB"><font size="1">&nbsp;<%=iUnivGenderTotal[0] + iUnivGenderTotal[1]%></font></td>
    </tr>
  </table>
<%} //end show univ totals %>
<br><br>
<span class="style2">Printed : <%=WI.getTodaysDate()%></span>
<%
}//only if vRetResult is not null
%>

<% if (strErrMsg == null) {%>
<script language="javascript">
	window.print();
</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>