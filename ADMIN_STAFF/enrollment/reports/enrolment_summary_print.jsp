<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");

if(strSchCode == null) {%>
	<p style="font-size:14px; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif">
		You are logged out Please login again.";
<%
return;
}


if(strSchCode.startsWith("EAC")){ %>
	<jsp:forward page="./enrolment_summary_print_EAC.jsp" />

<%}
else if(strSchCode.startsWith("SWU")){%>
	<jsp:forward page="./enrolment_summary_print_SWU.jsp" />

<%}
else if(strSchCode.startsWith("UPH")){ 
%>
	<jsp:forward page="./enrolment_summary_print_uph.jsp" />
<%}%>

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
Vector vRetResultBasic = null;
vRetResult = reportEnrollment.getEnrollmentSummary(dbOP, request, bolIsGroupByCollege);
if(strSchCode.startsWith("UI"))// && WI.fillTextValue("offering_sem").compareTo("1") == 0)
	vRetResultBasic = reportEnrollment.getBasicEnrolment(dbOP,request);

if(vRetResult == null)
	strErrMsg = reportEnrollment.getErrMsg();
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};

boolean bolShowGenderTotal = false;
if(strSchCode.startsWith("UI")) 
	bolShowGenderTotal = true;
	
//for non university schools, show College of registrar.
boolean bolIsCollege = false;
if(strSchCode.startsWith("CLDH") || strSchCode.startsWith("CGH")  || strSchCode.startsWith("UDMC") || strSchCode.startsWith("DBTC"))
	bolIsCollege = true;
	
String strCourseMajorName = null;

boolean bolIsCIT = strSchCode.startsWith("CIT");

	
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
      <td height="30"><div align="center"><br>
        OFFICE OF THE <%if(!bolIsCollege){%>UNIVERSITY <%}%>REGISTRAR<br>
		<b><%if(strSchCode.startsWith("UI")){%>
		RESUME OF ENROLMENT FOR<%}else{%>ENROLMENT SUMMARY FOR<%}%></b>
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
	if (vRetResultBasic != null && vRetResultBasic.size()!=0){ 

%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="20" colspan="7" bgcolor="#DBD8C8" class="thinborder"><strong>COURSE PROGRAM : PREELEMENTARY 
        </strong></td>
    </tr>
    <tr> 
      <td height="20" colspan="2" class="thinborder"><div align="center"><font size="1"><strong>NURSERY</strong></font></div></td>
      <td colspan="2" align="center" class="thinborder"><div align="center"><font size="1"><strong>KINDER 
          I</strong></font></div></td>
      <td colspan="2" align="center" class="thinborder"><div align="center"><font size="1"><strong>KINDER 
          II</strong></font><font size="1">&nbsp;</font></div></td>
      <td width="10%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
    </tr>
    <tr> 
      <td width="15%" height="20" class="thinborder"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>M</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>F</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>M</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>F</strong></font></td>
    </tr>
    <tr> 
      <% int iIndex = 0 ;

	for (; iIndex < 6 ; iIndex++) {
		iPreElemSubTotal += Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
%>
      <td align="center" class="thinborder"><font size="1"><%=(String)vRetResultBasic.elementAt(iIndex)%></font></td>
      <%}%>
      <td height="20" class="thinborder"><font size="1"><strong>&nbsp; <%=iPreElemSubTotal%></strong></font></td>
    </tr>
  </table>
  <br>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="20" colspan="15" bgcolor="#DBD8C8" class="thinborder"><strong>COURSE PROGRAM : 
        ELEMENTARY </strong></td>
    </tr>
    <tr> 
      <td height="20" colspan="2" class="thinborder"><div align="center"><strong></strong><strong><font size="1">GRADE 
          1</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong></strong><strong><font size="1">GRADE 
          2</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong></strong><strong><font size="1">GRADE 
          3</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong></strong><strong><font size="1">GRADE 
          4</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong></strong><strong><font size="1">GRADE 
          5</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong></strong><strong><font size="1">GRADE 
          6</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong><font size="1">GRADE 7</font></strong></div></td>
      <td width="10%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
    </tr>
    <tr> 
      <td width="5%" height="20" class="thinborder"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">M</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>F</strong></font></div></td>
    </tr>
    <tr> 
<% 
	for (; iIndex < 20 ; iIndex++) {
		iElemSubTotal += Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
%>
      <td align="center" class="thinborder"><font size="1"><%=(String)vRetResultBasic.elementAt(iIndex)%></font></td>
      <%}%>
      <td height="20" class="thinborder"><font size="1"><strong>&nbsp; <%=iElemSubTotal%></strong></font></td>
    </tr>
  </table>
  <br>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="20" colspan="9" bgcolor="#DBD8C8" class="thinborder"><strong>COURSE PROGRAM : HIGH 
        SCHOOL</strong></td>
    </tr>
    <tr> 
      <td height="20" colspan="2" class="thinborder"><div align="center"><strong></strong><strong></strong><strong><font size="1">FIRST 
          YEAR</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong></strong><strong></strong><strong><font size="1">SECOND 
          YEAR</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong></strong><strong></strong><strong><font size="1">THIRD 
          YEAR</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong></strong><strong></strong><strong><font size="1">FOURTH 
          YEAR</font></strong></div></td>
      <td width="20%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="24" class="thinborder"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>F</strong></font></div></td>
    </tr>
    <tr> 
      <%
		for (; iIndex < vRetResultBasic.size() ; iIndex++) {
		iHSSubTotal += Integer.parseInt((String)vRetResultBasic.elementAt(iIndex));
%>
      <td class="thinborder"><div align="center"><font size="1">&nbsp;<%=(String)vRetResultBasic.elementAt(iIndex)%></font></div></td>
      <%}%>
      <td height="20" class="thinborder"><div align="center"><strong><font size="1">&nbsp; <%=iHSSubTotal%></font></strong></div></td>
    </tr>
  </table><br>
 <%} // end vRetResultBasic




if(vRetResult != null){//System.out.println(vRetResult);
	// I have to keep track of course programs, course, and major.
	String strCourseProgram = null;
	String strCourseName    = null;
	String strMajorName     = null;
	
	//displays the coruse name and major name only if major and course names are different :-)
	String strCourseNameToDisp = null;
	String strMajorNameToDisp  = null;
	
	String str1stYrM = null; int i1stYrM = 0;
	String str1stYrF = null; int i1stYrF = 0;
	String str2ndYrM = null; int i2ndYrM = 0;
	String str2ndYrF = null; int i2ndYrF = 0;
	String str3rdYrM = null; int i3rdYrM = 0;
	String str3rdYrF = null; int i3rdYrF = 0;
	String str4thYrM = null; int i4thYrM = 0;
	String str4thYrF = null; int i4thYrF = 0;
	String str5thYrM = null; int i5thYrM = 0;
	String str5thYrF = null; int i5thYrF = 0;
	String str6thYrM = null; int i6thYrM = 0;
	String str6thYrF = null; int i6thYrF = 0;
	int[] ariMFperYear ={0,0,0,0,0,0,0,0,0,0,0,0};
	
	int iIndexOf = 0; String strTotNew = null; String strTotOld = null;
	
    int iTotNew = 0;
	int iTotOld = 0;
	int iTotalGenderM = 0;
    int iTotalGenderF = 0;
	
	int iSubGrandTotal = 0;
	
	for(int i = 1; i< vRetResult.size() ;){//outer loop for each course program.
	strCourseProgram = (String)vRetResult.elementAt(i);
	strCourseName = null;
	iSubGrandTotal = 0;
	iTotNew = 0;
	iTotOld = 0;
	i1stYrM = 0; i1stYrF = 0; i2ndYrM = 0; i2ndYrF = 0; 
	i3rdYrM = 0; i3rdYrF = 0; i4thYrM = 0; i4thYrF = 0; 
	i5thYrM = 0; i5thYrF = 0; i6thYrM = 0; i6thYrF = 0;
	
	iTotalGenderM = 0;
	iTotalGenderF = 0;
	%>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
<%if(true || WI.fillTextValue("summary_of_roe").compareTo("1") != 0){%>
    <tr> 
      <td height="20" colspan="23" bgcolor="#DBD8C8" class="thinborder"><strong><%if(bolIsGroupByCollege){%>COLLEGE<%}else{%>COURSE PROGRAM<%}%>: <%=strCourseProgram%></strong></td>
    </tr>
<%}if(true) {//i == 1 || WI.fillTextValue("summary_of_roe").compareTo("1") != 0) {%>
    <tr align="center" style="font-weight:bold"> 
      <td width="20%" rowspan="2" class="thinborder"><font size="1">COURSE</font></td>
      <td width="20%" rowspan="2" class="thinborder"><font size="1">MAJOR</font></td>
      <td height="24" colspan="3" class="thinborder"><font size="1">1ST YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">2ND YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">3RD YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">4TH YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">5TH YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1"> 
          <%if(bolShowGenderTotal){%>
          TOTAL
          <%}else{%>
          6TH YEAR
          <%}%>
        </font></td>
<%if(bolIsCIT) {%>
      <td width="5%" rowspan="2" class="thinborder"><font size="1">&nbsp;NEW&nbsp;</font></td>
      <td width="5%" rowspan="2" class="thinborder"><font size="1">&nbsp;OLD&nbsp;</font></td>
<%}%>
      <td width="7%" rowspan="2" class="thinborder"><font size="1">TOTAL</font></td>
    </tr>
    <tr align="center" style="font-weight:bold"> 
      <td width="3%" height="20" class="thinborder"><font size="1">M</font></td>
      <td width="3%" class="thinborder"><font size="1">F</font></td>
	  <td width="3%" class="thinborder"><font size="1">T</font></td>
      <td width="3%" class="thinborder"><font size="1">M</font></td>
	  <td width="3%" class="thinborder"><font size="1">F</font></td>
	  <td width="3%" class="thinborder"><font size="1">T</font></td>
      <td width="3%" class="thinborder"><font size="1">M</font></td>
      <td width="3%" class="thinborder"><font size="1">F</font></td>
	  <td width="3%" class="thinborder"><font size="1">T</font></td>
      <td width="3%" class="thinborder"><font size="1">M</font></td>
      <td width="3%" class="thinborder"><font size="1">F</font></td>
	  <td width="3%" class="thinborder"><font size="1">T</font></td>
      <td width="3%" class="thinborder"><font size="1">M</font></td>
      <td width="3%" class="thinborder"><font size="1">F</font></td>
	  <td width="3%" class="thinborder"><font size="1">T</font></td>
      <td width="3%" class="thinborder"><font size="1">M</font></td>
      <td width="3%" class="thinborder"><font size="1">F</font></td>
	  <td width="3%" class="thinborder"><font size="1">T</font></td>
    </tr>
	<%}
	
	for(int j = i; j< vRetResult.size();){//Inner loop for course/major for a course program.
	if(strCourseProgram.compareTo((String)vRetResult.elementAt(j)) != 0)
		break; //go back to main loop.
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
	iSubTotal = 0;
	//collect information for each year level for a course/major.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("1") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str1stYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrM);
		ariMFperYear[0] += Integer.parseInt(str1stYrM);
		i1stYrM += Integer.parseInt(str1stYrM);
		
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("1") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str1stYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrF);
		ariMFperYear[1] += Integer.parseInt(str1stYrF);
		i1stYrF += Integer.parseInt(str1stYrF);
		
		j += 6;	
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
		i2ndYrM += Integer.parseInt(str2ndYrM);
		
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("2") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str2ndYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str2ndYrF);
		ariMFperYear[3] += Integer.parseInt(str2ndYrF);
		i2ndYrF += Integer.parseInt(str2ndYrF);
		j += 6;	
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
		i3rdYrM += Integer.parseInt(str3rdYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("3") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str3rdYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str3rdYrF);
		ariMFperYear[5] += Integer.parseInt(str3rdYrF);
		i3rdYrF += Integer.parseInt(str3rdYrF);
		j += 6;	
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
		i4thYrM += Integer.parseInt(str4thYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("4") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str4thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str4thYrF);
		ariMFperYear[7] += Integer.parseInt(str4thYrF);
		i4thYrF += Integer.parseInt(str4thYrF);
		j += 6;	
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
		i5thYrM += Integer.parseInt(str5thYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("5") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str5thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str5thYrF);
		ariMFperYear[9] += Integer.parseInt(str5thYrF);
		i5thYrF += Integer.parseInt(str5thYrF);
		j += 6;	
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
		i6thYrM += Integer.parseInt(str6thYrM);
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
		i6thYrF += Integer.parseInt(str6thYrF);
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
	iTotalGenderM  += Integer.parseInt(WI.getStrValue(str1stYrM,"0"))+Integer.parseInt(WI.getStrValue(str2ndYrM,"0"))
	               +Integer.parseInt(WI.getStrValue(str3rdYrM,"0"))+Integer.parseInt(WI.getStrValue(str4thYrM,"0"))
				   +Integer.parseInt(WI.getStrValue(str5thYrM,"0"));
	iTotalGenderF  += Integer.parseInt(WI.getStrValue(str1stYrF,"0"))+Integer.parseInt(WI.getStrValue(str2ndYrF,"0"))
	               +Integer.parseInt(WI.getStrValue(str3rdYrF,"0"))+Integer.parseInt(WI.getStrValue(str4thYrF,"0"))
				   +Integer.parseInt(WI.getStrValue(str5thYrF,"0"));
	i = j;
	
	
	%>
    <tr> 
      <td height="20" class="thinborder"><font size="1"><%=strCourseNameToDisp%></font></td>
      <td class="thinborder"><%=WI.getStrValue(strMajorNameToDisp,"&nbsp;")%></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str1stYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str1stYrF,"&nbsp;")%></font></td>
	  <td class="thinborder"><font size="1"><%=Integer.parseInt(WI.getStrValue(str1stYrM,"0"))+Integer.parseInt(WI.getStrValue(str1stYrF,"0"))%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str2ndYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str2ndYrF,"&nbsp;")%></font></td>
	  <td class="thinborder"><font size="1"><%=Integer.parseInt(WI.getStrValue(str2ndYrM,"0"))+Integer.parseInt(WI.getStrValue(str2ndYrF,"0"))%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str3rdYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str3rdYrF,"&nbsp;")%></font></td>
	  <td class="thinborder"><font size="1"><%=Integer.parseInt(WI.getStrValue(str3rdYrM,"0"))+Integer.parseInt(WI.getStrValue(str3rdYrF,"0"))%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str4thYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str4thYrF,"&nbsp;")%></font></td>
	  <td class="thinborder"><font size="1"><%=Integer.parseInt(WI.getStrValue(str4thYrM,"0"))+Integer.parseInt(WI.getStrValue(str4thYrF,"0"))%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str5thYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str5thYrF,"&nbsp;")%></font></td>
	  <td class="thinborder"><font size="1"><%=Integer.parseInt(WI.getStrValue(str5thYrM,"0"))+Integer.parseInt(WI.getStrValue(str5thYrF,"0"))%></font></td>      
    <td width="3%" class="thinborder"><font size="1">
      <%if(bolShowGenderTotal){%>
      <%=Integer.parseInt(WI.getStrValue(str1stYrM,"0"))+Integer.parseInt(WI.getStrValue(str2ndYrM,"0"))+Integer.parseInt(WI.getStrValue(str3rdYrM,"0"))+
	  Integer.parseInt(WI.getStrValue(str4thYrM,"0"))+Integer.parseInt(WI.getStrValue(str5thYrM,"0"))%> 
      <%}else{%>
      <%=WI.getStrValue(str6thYrM,"&nbsp;")%>
      <%}%>
      </font></td>
      
    <td width="3%" class="thinborder"><font size="1"> 
      <%if(bolShowGenderTotal){%>
      <%=Integer.parseInt(WI.getStrValue(str1stYrF,"0"))+Integer.parseInt(WI.getStrValue(str2ndYrF,"0"))+Integer.parseInt(WI.getStrValue(str3rdYrF,"0"))+
	  Integer.parseInt(WI.getStrValue(str4thYrF,"0"))+Integer.parseInt(WI.getStrValue(str5thYrF,"0"))%> 
      <%}else{%>
      <%=WI.getStrValue(str6thYrF,"&nbsp;")%>
      <%}%>
      </font></td>
	  <td class="thinborder"><font size="1"><%if(bolShowGenderTotal){%>
	  <%=iSubTotal%>
	  <%}else{%><%=Integer.parseInt(WI.getStrValue(str6thYrM,"0"))+Integer.parseInt(WI.getStrValue(str6thYrF,"0"))%><%}%>
	  </font></font></td>
<%if(bolIsCIT) {
//System.out.println(strCourseMajorName);
iIndexOf = reportEnrollment.avAddlInfo.indexOf(strCourseMajorName);
	strTotNew = "&nbsp;";
	strTotOld = "&nbsp;";
if(iIndexOf > -1) {
	if(reportEnrollment.avAddlInfo.elementAt(iIndexOf + 1).equals("New")) {
		strTotNew = (String)reportEnrollment.avAddlInfo.elementAt(iIndexOf + 2);
		if(reportEnrollment.avAddlInfo.size () > iIndexOf + 3 && reportEnrollment.avAddlInfo.elementAt(iIndexOf + 3).equals(strCourseMajorName) && 
			reportEnrollment.avAddlInfo.elementAt(iIndexOf + 4).equals("Old") ) {
				reportEnrollment.avAddlInfo.remove(iIndexOf); reportEnrollment.avAddlInfo.remove(iIndexOf);	reportEnrollment.avAddlInfo.remove(iIndexOf);
				
				strTotOld = (String)reportEnrollment.avAddlInfo.elementAt(iIndexOf + 2);
		}
		else	
			strTotOld = "&nbsp;";
	}
	else {
		strTotOld = (String)reportEnrollment.avAddlInfo.elementAt(iIndexOf + 2);	
		strTotNew = "&nbsp;";
	}
	reportEnrollment.avAddlInfo.remove(iIndexOf); reportEnrollment.avAddlInfo.remove(iIndexOf);	reportEnrollment.avAddlInfo.remove(iIndexOf);
}
%>
      <td class="thinborder" align="right"><font size="1"><%=strTotNew%></font></td>
      <td class="thinborder" align="right"><font size="1"><%=strTotOld%></font></td>
<%    
		try{
			iTotNew += Integer.parseInt(WI.getStrValue(strTotNew,"0"));	  		
		}catch(NumberFormatException e){
			iTotNew += 0;	  		
		}
		
		try{			
	  		iTotOld += Integer.parseInt(WI.getStrValue(strTotOld,"0"));
		}catch(NumberFormatException e){			
	  		iTotOld += 0;
		}

		
    }%>
      <td width="7%" class="thinborder" align="right"><font size="1"><%=iSubTotal%></font></td>
    </tr>
<%} %>
<%if(WI.fillTextValue("summary_of_roe").compareTo("1") != 0){%>
<tr>
  <td colspan="2" align="right" class="thinborder"><strong><font size="1">SUB TOTAL :</font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i1stYrM%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i1stYrF%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i1stYrM+i1stYrF %></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i2ndYrM%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i2ndYrF%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i2ndYrM+i2ndYrF%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i3rdYrM%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i3rdYrF%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i3rdYrM+i3rdYrF%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i4thYrM%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i4thYrF%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i4thYrM+i4thYrF%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i5thYrM%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i5thYrF%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=i5thYrM+i5thYrF%></font></strong></td>
  <td class="thinborder"><strong><font size="1">
  <%if(bolShowGenderTotal){%><%=iTotalGenderM%><%}else{%><%=i6thYrM%><%}%></font></strong></td>
  <td class="thinborder"><strong><font size="1">
  <%if(bolShowGenderTotal){%><%=iTotalGenderF%><%}else{%><%=i6thYrF%><%}%></font></strong></td>
  <td class="thinborder"><strong><font size="1">
  <%if(bolShowGenderTotal){%><%=iSubGrandTotal%><%}else{%><%=i6thYrM+i6thYrF%><%}%></font></strong></td>
  <%if(bolIsCIT) {%>  
  <td class="thinborder"><strong><font size="1"><%=iTotNew%></font></strong></td>
  <td class="thinborder"><strong><font size="1"><%=iTotOld%></font></strong></td>
  <%}%>
  <td class="thinborder" align="right"><strong><font size="1"><%=iSubGrandTotal%></font></strong></td>
  </tr>
  <%}%>
  </table>

 <% }//outer most loop
 if (false && (vRetResult.size() > 0 || WI.fillTextValue("summary_of_roe").compareTo("1")!=0)
 	&& !strSchCode.startsWith("UI")){%>
    <table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
      <td height="24" align="right" width="56%" class="thinborder"><font size="1">TOTAL :&nbsp; </font></td>
<%for (int i = 0 ; i < 12; ++i) { %>
      <td width="3%" class="thinborder"><font size="1">&nbsp;<%=ariMFperYear[i]%></font></td>
<%}%>
      <td width="7%" class="thinborder"><font size="1">&nbsp;</font></td>
    </tr>
 </table>
<%} // end show total of M/F per year level %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
<%
if(strSchCode.startsWith("UI")){// && WI.fillTextValue("offering_sem").compareTo("1") == 0){%>
    <tr align="right"> 
      <td width="93%" align="right" class="thinborder"><strong><font size="1"> TOTAL COLLEGE:&nbsp;&nbsp;&nbsp;</font></strong></td>
      <td width="7%" height="20" class="thinborder"><strong><font size="1">&nbsp; <%=(String)vRetResult.elementAt(0)%></font></strong>&nbsp;</td>
    </tr>
    <tr align="right">
      <td align="right" class="thinborder"><strong><font size="1">PREELEMENTARY:&nbsp; &nbsp;</font></strong></td>
      <td height="20" class="thinborder"><strong><font size="1">&nbsp; <%=iPreElemSubTotal%></font></strong>&nbsp;</td>
    </tr>
    <tr align="right"> 
      <td align="right" class="thinborder"><font size="1"><strong>ELEMENTARY :&nbsp;&nbsp;&nbsp;</strong></font> 
      </td>
      <td height="20" class="thinborder"><font size="1"><strong>&nbsp; <%=iElemSubTotal%></strong></font>&nbsp;</td>
    </tr>
    <tr align="right"> 
      <td align="right" class="thinborder"><font size="1"><strong>HIGH SCHOOL :&nbsp;&nbsp;&nbsp;</strong></font></td>
      <td height="20" class="thinborder"><font size="1"><strong>&nbsp; <%=iHSSubTotal%></strong></font>&nbsp;</td>
    </tr>
<%}//only if it is called from UI%>    <tr align="right"> 
      <td width="93%" align="right" class="thinborder"><strong><font size="1">GRAND TOTAL :&nbsp;&nbsp;&nbsp;</font></strong></td>
      <td height="20" class="thinborder"><font color="#FF0000" size="1"><strong>&nbsp; <%=iPreElemSubTotal+iElemSubTotal+iHSSubTotal+Integer.parseInt((String)vRetResult.elementAt(0))%></strong></font>&nbsp;</td>
    </tr>  </table>
<%}//only if vRetResult is not null
%>

<script language="JavaScript">
	window.print();
</script>

</body>
</html>
<%
dbOP.cleanUP();
%>