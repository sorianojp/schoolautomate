<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) {%>
	<p style="font-size:14px; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif">
		You are logged out Please login again.";
<%
return;
}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print page</title>
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

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

</head>
<body>
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	int iElemSubTotal = 0;
	int iHSSubTotal = 0;
	int iPreElemSubTotal = 0;	
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-enrollment summary","enrolment_summary.jsp");
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
														"enrolment_summary.jsp");
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

//I have to get if this is per college or per course program.
boolean bolIsGroupByCollege = WI.getStrValue(WI.fillTextValue("g_by"), "1").equals("2");


ReportEnrollment reportEnrollment = new ReportEnrollment();
Vector vRetResult = null;
//vRetResult = reportEnrollment.getEnrollmentSummary(dbOP, request, bolIsGroupByCollege);
vRetResult = reportEnrollment.getEnrollmentSummaryPerSectionSPC(dbOP, request);

if(vRetResult == null)
	strErrMsg = reportEnrollment.getErrMsg();

String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};

boolean bolShowGenderTotal = false;
if(strSchCode.startsWith("UI") ) 
	bolShowGenderTotal = true;
	
//for non university schools, show College of registrar.
boolean bolIsCollege =  true;
	
String strCourseMajorName = null;
boolean bolIsCIT = strSchCode.startsWith("CIT");
if(strSchCode.startsWith("UI") ) 
	bolShowGenderTotal = true;
if(!bolIsGroupByCollege)
	bolIsCIT = false;
	
if(strErrMsg != null){%>
<table>
	<tr>
		<td>
			<font size="3"> <strong><%=strErrMsg%></strong></font>
		</td>
	</tr>
</table>
<%
dbOP.cleanUP();
return;
}%>
  <table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><br>Statistical Report
      <br>
		<b><%if(strSchCode.startsWith("UI")){%>
		RESUME OF ENROLMENT FOR<%}else{%>ENROLMENT SUMMARY PER SECTION FOR<%}%></b>
        <%=astrConvertToSem[Integer.parseInt((String)request.getParameter("offering_sem"))].toUpperCase()%>, 
		AY (<%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>) 
         
        <% 
		if(WI.fillTextValue("specific_date").length() > 0){%>
        FOR DATE: <%=WI.fillTextValue("specific_date")%> 
        <%}%>
      </div></td>
    </tr>
</table>
<% 	
if(vRetResult != null){//System.out.println(vRetResult);
	// I have to keep track of course programs, course, and major.

	String strCourseProgram = null;
	String strCourseName    = null;
	String strMajorName     = null;
	
	//displays the coruse name and major name only if major and course names are different :-)
	String strCourseNameToDisp = null;
	String strMajorNameToDisp  = null;
	
	String str1stYrM = null;
	String str1stYrF = null; int i1stYrTotal = 0;
	String str2ndYrM = null;
	String str2ndYrF = null; int i2ndYrTotal = 0;
	String str3rdYrM = null;
	String str3rdYrF = null; int i3rdYrTotal = 0;
	String str4thYrM = null;
	String str4thYrF = null; int i4thYrTotal = 0;
	String str5thYrM = null;
	String str5thYrF = null; int i5thYrTotal = 0;
	String str6thYrM = null;
	String str6thYrF = null;
	int[] ariMFperYear ={0,0,0,0,0,0,0,0,0,0,0,0};
	
	int iSubTotalM   = 0;int iSubTotalF   = 0;
	
	int iIndexOf = 0; String strTotNew = null; String strTotOld = null;

	int iSubGrandTotal = 0;
	
	for(int i = 1; i< vRetResult.size() ;){//outer loop for each course program.
	strCourseProgram = (String)vRetResult.elementAt(i);
	strCourseName = null;
	iSubGrandTotal = 0;
	%>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    
<%if(i == 1 || WI.fillTextValue("summary_of_roe").compareTo("1") != 0) {%>
    <tr align="center" style="font-weight:bold"> 
      <td width="46%" rowspan="2" class="thinborder"><font size="1">SECTION</font></td>
      <td height="24" colspan="3" class="thinborder"><font size="1">1ST YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">2ND YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">3RD YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">4TH YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">5TH YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">OVER ALL TOTAL</font></td>
    </tr>
    <tr align="center" style="font-weight:bold"> 
      <td width="3%" height="20" class="thinborder"><font size="1">M</font></td>
      <td width="3%" class="thinborder"><font size="1">F</font></td>
      <td width="3%" class="thinborder"><font size="1">TOTAL</font></td>
      <td width="3%" class="thinborder"><font size="1">M</font></td>
      <td width="3%" class="thinborder"><font size="1">F</font></td>
      <td width="3%" class="thinborder"><font size="1">TOTAL</font></td>
      <td width="3%" class="thinborder"><font size="1">M</font></td>
      <td width="3%" class="thinborder"><font size="1">F</font></td>
      <td width="3%" class="thinborder"><font size="1">TOTAL</font></td>
      <td width="3%" class="thinborder"><font size="1">M</font></td>
      <td width="3%" class="thinborder"><font size="1">F</font></td>
      <td width="3%" class="thinborder"><font size="1">TOTAL</font></td>
      <td width="3%" class="thinborder"><font size="1">M</font></td>
      <td width="3%" class="thinborder"><font size="1">F</font></td>
      <td width="3%" class="thinborder"><font size="1">TOTAL</font></td>
      <td width="3%" class="thinborder"><font size="1">M</font></td>
      <td width="3%" class="thinborder"><font size="1">F</font></td>
      <td width="3%" class="thinborder"><font size="1">TOTAL</font></td>
    </tr>
	<%}
	
	for(int j = i; j< vRetResult.size();){//Inner loop for course/major for a course program.
	//if(strCourseProgram.compareTo((String)vRetResult.elementAt(j)) != 0)
	//	break; //go back to main loop.
//System.out.println(strCourseName);
//System.out.println(strMajorName);
	strCourseMajorName = ((String)vRetResult.elementAt(j+1) + WI.getStrValue((String)vRetResult.elementAt(j+2), "N/A")).toUpperCase();

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
	iSubTotal  = 0;
	iSubTotalM = 0;
	iSubTotalF = 0;
	i1stYrTotal = 0;i2ndYrTotal = 0;i3rdYrTotal = 0;i4thYrTotal = 0;i5thYrTotal = 0; 
	//collect information for each year level for a course/major.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("1") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str1stYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrM);
		ariMFperYear[0] += Integer.parseInt(str1stYrM);
		j += 6;	
		i1stYrTotal += Integer.parseInt(str1stYrM);
		iSubTotalM  += Integer.parseInt(str1stYrM);
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("1") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str1stYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrF);
		ariMFperYear[1] += Integer.parseInt(str1stYrF);
		j += 6;	
		i1stYrTotal += Integer.parseInt(str1stYrF);
		iSubTotalF += Integer.parseInt(str1stYrF);
	}
	//2nd year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("2") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str2ndYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str2ndYrM);
		ariMFperYear[2] += Integer.parseInt(str2ndYrM);
		j += 6;	
		i2ndYrTotal += Integer.parseInt(str2ndYrM);
		iSubTotalM  += Integer.parseInt(str2ndYrM);
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("2") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str2ndYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str2ndYrF);
		ariMFperYear[3] += Integer.parseInt(str2ndYrF);
		j += 6;	
		i2ndYrTotal += Integer.parseInt(str2ndYrF);
		iSubTotalF += Integer.parseInt(str2ndYrF);
	}
	//3rd year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("3") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str3rdYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str3rdYrM);
		ariMFperYear[4] += Integer.parseInt(str3rdYrM);
		j += 6;	
		i3rdYrTotal += Integer.parseInt(str3rdYrM);
		iSubTotalM  += Integer.parseInt(str3rdYrM);
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("3") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str3rdYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str3rdYrF);
		ariMFperYear[5] += Integer.parseInt(str3rdYrF);
		j += 6;	
		i3rdYrTotal += Integer.parseInt(str3rdYrF);
		iSubTotalF += Integer.parseInt(str3rdYrF);
	}
	//4th year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("4") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str4thYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str4thYrM);
		ariMFperYear[6] += Integer.parseInt(str4thYrM);
		j += 6;	
		i4thYrTotal += Integer.parseInt(str4thYrM);
		iSubTotalM  += Integer.parseInt(str4thYrM);
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("4") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str4thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str4thYrF);
		ariMFperYear[7] += Integer.parseInt(str4thYrF);
		j += 6;	
		i4thYrTotal += Integer.parseInt(str4thYrF);
		iSubTotalF += Integer.parseInt(str4thYrF);
	}
	//5th year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("5") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str5thYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str5thYrM);
		ariMFperYear[8] += Integer.parseInt(str5thYrM);
		j += 6;	
		i5thYrTotal += Integer.parseInt(str5thYrM);
		iSubTotalM  += Integer.parseInt(str5thYrM);
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("5") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str5thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str5thYrF);
		ariMFperYear[9] += Integer.parseInt(str5thYrF);
		j += 6;	
		i5thYrTotal += Integer.parseInt(str5thYrF);
		iSubTotalF += Integer.parseInt(str5thYrF);
	}
	//6th year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("6") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str6thYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str6thYrM);
		ariMFperYear[10] += Integer.parseInt(str6thYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("6") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str6thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str6thYrF);
		ariMFperYear[11] += Integer.parseInt(str6thYrF);
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
      <td height="20" class="thinborder"><font size="1"><%=strCourseNameToDisp%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str1stYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str1stYrF,"&nbsp;")%></font></td>
		<%
		strTemp = Integer.toString(i1stYrTotal);
		if(i1stYrTotal == 0)
			strTemp = "&nbsp;";
		%>
      <td width="3%" class="thinborder" align="center"><%=strTemp%></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str2ndYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str2ndYrF,"&nbsp;")%></font></td>
		<%
		strTemp = Integer.toString(i2ndYrTotal);
		if(i2ndYrTotal == 0)
			strTemp = "&nbsp;";
		%>
      <td width="3%" class="thinborder" align="center"><%=strTemp%></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str3rdYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str3rdYrF,"&nbsp;")%></font></td>
		<%
		strTemp = Integer.toString(i3rdYrTotal);
		if(i3rdYrTotal == 0)
			strTemp = "&nbsp;";
		%>
      <td width="3%" class="thinborder" align="center"><%=strTemp%></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str4thYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str4thYrF,"&nbsp;")%></font></td>
		<%
		strTemp = Integer.toString(i4thYrTotal);
		if(i4thYrTotal == 0)
			strTemp = "&nbsp;";
		%>
      <td width="3%" class="thinborder" align="center"><%=strTemp%></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str5thYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str5thYrF,"&nbsp;")%></font></td>
		<%
		strTemp = Integer.toString(i5thYrTotal);
		if(i5thYrTotal == 0)
			strTemp = "&nbsp;";
		%>
      <td width="3%" class="thinborder" align="center"><%=strTemp%></td>
		<%
		strTemp = Integer.toString(iSubTotalM);
		if(iSubTotalM == 0)
			strTemp = "&nbsp;";
		%>
      <td width="3%" class="thinborder" align="right"><%=strTemp%></td>
		<%
		strTemp = Integer.toString(iSubTotalF);
		if(iSubTotalF == 0)
			strTemp = "&nbsp;";
		%>
      <td width="3%" class="thinborder" align="right"><%=strTemp%></td>
		<%
		strTemp = Integer.toString(iSubTotal);
		if(iSubTotal == 0)
			strTemp = "&nbsp;";
		%>
      <td width="3%" class="thinborder" align="right"><font size="1"><%=strTemp%></font></td>
    </tr>
<%} %>
    <tr>
      <td height="20" class="thinborder">&nbsp;</td>
      <td class="thinborder"><%=ariMFperYear[0]%></td>
      <td class="thinborder"><%=ariMFperYear[1]%></td>
		<%
		strTemp = Integer.toString(ariMFperYear[0] + ariMFperYear[1]);
		if(ariMFperYear[0] + ariMFperYear[1] == 0)
			strTemp = "&nbsp;";
		%>
      <td class="thinborder" align="center"><%=strTemp%></td>
      <td class="thinborder"><%=ariMFperYear[2]%></td>
      <td class="thinborder"><%=ariMFperYear[3]%></td>
		<%
		strTemp = Integer.toString(ariMFperYear[2] + ariMFperYear[3]);
		if(ariMFperYear[2] + ariMFperYear[3] == 0)
			strTemp = "&nbsp;";
		%>
      <td class="thinborder" align="center"><%=strTemp%></td>
      <td class="thinborder"><%=ariMFperYear[4]%></td>
      <td class="thinborder"><%=ariMFperYear[5]%></td>
		<%
		strTemp = Integer.toString(ariMFperYear[4] + ariMFperYear[5]);
		if(ariMFperYear[4] + ariMFperYear[5] == 0)
			strTemp = "&nbsp;";
		%>
      <td class="thinborder" align="center"><%=strTemp%></td>
      <td class="thinborder"><%=ariMFperYear[6]%></td>
      <td class="thinborder"><%=ariMFperYear[7]%></td>
		<%
		strTemp = Integer.toString(ariMFperYear[6] + ariMFperYear[7]);
		if(ariMFperYear[6] + ariMFperYear[7] == 0)
			strTemp = "&nbsp;";
		%>
      <td class="thinborder" align="center"><%=strTemp%></td>
      <td class="thinborder"><%=ariMFperYear[8]%></td>
      <td class="thinborder"><%=ariMFperYear[9]%></td>
		<%
		strTemp = Integer.toString(ariMFperYear[8] + ariMFperYear[9]);
		if(ariMFperYear[8] + ariMFperYear[9] == 0)
			strTemp = "&nbsp;";
		%>
      <td class="thinborder" align="center"><%=strTemp%></td>
      <td class="thinborder" align="right"><%=ariMFperYear[0] + ariMFperYear[2] + ariMFperYear[4] + ariMFperYear[6] + ariMFperYear[8]%></td>
      <td class="thinborder" align="right"><%=ariMFperYear[1] + ariMFperYear[3] + ariMFperYear[5] + ariMFperYear[7] + ariMFperYear[9]%></td>
      <td class="thinborder" align="right"><font color="#FF0000" size="1"><strong><%=Integer.parseInt((String)vRetResult.elementAt(0))%></strong></font></td>
    </tr>
  </table>
 <%}
 }//outer most loop
 %>

<script language="JavaScript">
	window.print();
</script>

</body>
</html>
<%
dbOP.cleanUP();
%>