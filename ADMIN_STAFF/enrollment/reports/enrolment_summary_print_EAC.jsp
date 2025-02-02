<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print page</title>
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
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

</head>
<body onLoad="window.print();">
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
String strSchCode = dbOP.getSchoolIndex();
if(strSchCode == null)
	strSchCode = "";//for UI, the detrails are different from others. UI adds elementary details.

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
if(strSchCode.startsWith("UI") ) 
	bolShowGenderTotal = true;
	
//for non university schools, show College of registrar.
boolean bolIsCollege = false;
if(strSchCode.startsWith("CLDH") || strSchCode.startsWith("CGH")  || strSchCode.startsWith("UDMC"))
	bolIsCollege = true;
	
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" align="center"><font style="font-size:16px; font-weight:bold">
	  	  Republic of the Philippines<br>
		  Commision on Higher Education<br>
		  NATIONAL CAPITAL REGION<br>
		  </font>
		  2nd Floor, Higher Education Development Center(HEDC) Building<br>
		  C.P. Garcia Ave., U.P. Diliman, Quezon City
	  </td>
    </tr>
    <tr>
		<td>NCR-HED Form 11<br>(Revised: 9/1/78)</td>
    </tr>
</table><br>
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td width="60%">
			  <table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				  <td valign="top"><pre style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif">
School:                    EMILIO AGUINALDO COLLEGE
Tel. No:                   521-27-10 local 5359/ 5360
School Head:           JOSE PAULO E. CAMPUS, Ed. D.
Registrar:                GRACE SANTILLAN-LEE, MAT 
</pre>
					</td>
				</tr>
			  </table>
		</td>
		<td valign="top">
			  <table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td align="right">
						Location:  1113-1117 San Marcelino St., cor., <br>
                     	Gonzales St., Ermita, Manila <br>
						Designation:     President  <br>
						Liason Officer:  Honey H. Sambrano<br>
					</td>
				</tr>
			  </table>
		</td>
	</tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" align="center"><font style="font-size:16px; font-weight:bold">
	  	  ENROLMENT SUMMARY FOR <%=astrConvertToSem[Integer.parseInt((String)request.getParameter("offering_sem"))].toUpperCase()%>, AY (<%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>)</td>
    </tr>
</table>
<% 	
int iDefRowPerPg = 40;
int iCurRow = 0;
if(vRetResult != null){//System.out.println(vRetResult);
	// I have to keep track of course programs, course, and major.
	String strCourseProgram = null;
	String strCourseName    = null;
	String strMajorName     = null;
	
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
	int[] ariMFperYear ={0,0,0,0,0,0,0,0,0,0,0,0};
	
	int iIndexOf = 0; String strTotNew = null; String strTotOld = null;

	int iSubGrandTotal = 0;
	
	boolean bolReset = false;
	
	for(int i = 1; i< vRetResult.size() ;){//outer loop for each course program.
	strCourseProgram = (String)vRetResult.elementAt(i);
	strCourseName = null;
	if(bolReset)
		iSubGrandTotal = 0;//System.out.println("iSubGrandTotal: "+iSubGrandTotal);
	
	if(i > 1 && !bolReset) {%>
			<DIV style="page-break-after:always">&nbsp;</DIV>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		  <td width="100%" align="center"><font style="font-size:16px; font-weight:bold">EMILIO AGUINALDO COLLEGE<br>
		  <font style="font-weight:normal; font-size:9px;">1113-1117 San Marcelino St., cor., Gonzales St., Ermita, Manila</font></td>
		</tr>
		<tr>
		  <td width="100%" align="center"><font style="font-size:16px; font-weight:bold">
			  ENROLMENT SUMMARY FOR <%=astrConvertToSem[Integer.parseInt((String)request.getParameter("offering_sem"))].toUpperCase()%>, AY (<%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>)</td>
		</tr>
	  </table>
	<%}%>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
<%if(WI.fillTextValue("summary_of_roe").compareTo("1") != 0){++iCurRow;%>
    <tr> 
      <td height="20" colspan="17" bgcolor="#DBD8C8" class="thinborder"><strong>COURSE PROGRAM : <%=strCourseProgram%></strong></td>
    </tr>
<%}if(true || WI.fillTextValue("summary_of_roe").compareTo("1") != 0) {++iCurRow;%>
    <tr align="center" style="font-weight:bold"> 
      <td width="30%" rowspan="2" class="thinborder"><font size="1">COURSE</font></td>
      <td width="20%" rowspan="2" class="thinborder"><font size="1">MAJOR</font></td>
      <td height="24" colspan="2" class="thinborder"><font size="1">1ST YEAR</font></td>
      <td colspan="2" class="thinborder"><font size="1">2ND YEAR</font></td>
      <td colspan="2" class="thinborder"><font size="1">3RD YEAR</font></td>
      <td colspan="2" class="thinborder"><font size="1">4TH YEAR</font></td>
      <td colspan="2" class="thinborder"><font size="1">5TH YEAR</font></td>
      <td colspan="2" class="thinborder"><font size="1"> 
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
      <td width="5%" rowspan="2" class="thinborder"><font size="1">TOTAL</font></td>
    </tr>
    <tr align="center" style="font-weight:bold"> 
      <td width="2%" height="20" class="thinborder"><font size="1">M</font></td>
      <td width="2%" class="thinborder"><font size="1">F</font></td>
      <td width="2%" class="thinborder"><font size="1">M</font></td>
      <td width="2%" class="thinborder"><font size="1">F</font></td>
      <td width="2%" class="thinborder"><font size="1">M</font></td>
      <td width="2%" class="thinborder"><font size="1">F</font></td>
      <td width="2%" class="thinborder"><font size="1">M</font></td>
      <td width="2%" class="thinborder"><font size="1">F</font></td>
      <td width="2%" class="thinborder"><font size="1">M</font></td>
      <td width="2%" class="thinborder"><font size="1">F</font></td>
      <td width="2%" class="thinborder"><font size="1">M</font></td>
      <td width="2%" class="thinborder"><font size="1">F</font></td>
    </tr>
	<%}
	
	for(int j = i; j< vRetResult.size();){//Inner loop for course/major for a course program.
	//if(strCourseProgram.compareTo((String)vRetResult.elementAt(j)) != 0) {
	//	bolReset = true;
	//	break; 
	//}
	++iCurRow;
	if(iCurRow > iDefRowPerPg) {
		bolReset = false;
		iCurRow = 0;
		break;
	}
	
	//go back to main loop.
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
      <td class="thinborder"><%=WI.getStrValue(strMajorNameToDisp,"&nbsp;")%></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str1stYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str1stYrF,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str2ndYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str2ndYrF,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str3rdYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str3rdYrF,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str4thYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str4thYrF,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str5thYrM,"&nbsp;")%></font></td>
      <td width="3%" class="thinborder"><font size="1"><%=WI.getStrValue(str5thYrF,"&nbsp;")%></font></td>
      
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
<%}%>
      <td width="7%" class="thinborder" align="right"><font size="1"><%=iSubTotal%></font></td>
    </tr>
<%} %>
  </table>
<%if(WI.fillTextValue("summary_of_roe").compareTo("1") != 0){%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" align="right" style="font-size:9px; font-weight:bold">
	  <%if(!bolReset) {%>Next Page ...<%}else{%>SUB TOTAL :&nbsp;&nbsp;&nbsp; <%=iSubGrandTotal%><%}%></td>
    </tr>
  </table>
 <%}

 }%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr align="right"> 
      <td width="93%" align="right" style="font-size:9px; font-weight:bold">GRAND TOTAL :&nbsp;&nbsp;&nbsp; <%=iPreElemSubTotal+iElemSubTotal+iHSSubTotal+Integer.parseInt((String)vRetResult.elementAt(0))%></td>
    </tr>  </table>
<%}//only if vRetResult is not null
%>
<br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr align="center"> 
      <td width="38%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="38%" class="thinborderBOTTOM">&nbsp;</td>
	  <td width="12%">&nbsp;</td>
	</tr>
	<tr align="center">
	  <td style="font-weight:bold; font-size:14px;">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td style="font-weight:bold; font-size:14px;"><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1)%></td>
	  <td>&nbsp;</td>
    </tr>
	<tr align="center">
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>Registrar</td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td>Prepared by: </td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr align="center">
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr align="center">
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr align="center">
	  <td class="thinborderBOTTOM">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr align="center">
	  <td style="font-weight:bold; font-size:14px;"><%=CommonUtil.getNameForAMemberType(dbOP,"Evaluator",1)%></td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr align="center">
	  <td>Evaluator</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>