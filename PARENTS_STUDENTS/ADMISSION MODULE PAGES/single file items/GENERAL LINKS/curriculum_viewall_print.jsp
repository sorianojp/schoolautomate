<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
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

<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	String strCourseIndex 	= request.getParameter("ci");
	String strCourseName 	= request.getParameter("cname");
	String strMajorIndex 	= request.getParameter("mi");
	String strMajorName 	= request.getParameter("mname");
	if(strMajorName == null || strMajorName.trim().length() ==0) strMajorName = "None";
	String strSYFrom 		= request.getParameter("syf");
	String strSYTo 			= request.getParameter("syt");

	float iNoOfLECUnitPerSem = 0f; float iNoOfLABUnitPerSem = 0f;
	float iNoOfLECUnitPerCourse = 0f;float iNoOfLABUnitPerCourse = 0f;
	float fInternship = 0f;
	
	double dNoOfLECHrPerSem = 0d;
	double dNoOfLABHrPerSem = 0d;

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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Admission","Courses Curriculum",request.getRemoteAddr(),
							//							"curriculum_viewall.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.


//end of security code.
strErrMsg = null; //if there is any message set -- show at the bottom of the page.
CurriculumMaintenance CM = new CurriculumMaintenance();
if(strCourseIndex == null || strSYFrom == null || strSYTo == null)
{
	strErrMsg = "Can't process curriculum detail. Curriculum Year information missing.";
	dbOP.cleanUP();
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=strErrMsg%></font></p>
	<%
	return;
}

//get here total year and semester of the course.
int[][] aiYearSem = CM.getMaxYearSemester(dbOP,strCourseIndex, strSYFrom, strSYTo);

if(aiYearSem == null)
{
	dbOP.cleanUP();
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=CM.getErrMsg()%></font></p>
	<%
	return;
}
//get elective subject list.
Vector vElectiveSubList = CM.getElectiveSubListPerCurriculum(dbOP, strCourseIndex,strMajorIndex, strSYFrom, strSYTo);
//These theree variables are very specific to course
String strCourseCode = null;
String strMsgForBSCSAfter3rdYrSummer = "";
String strMsgForBSCSAtEnd = "";
String strMsgForASHE = "";
String strMsgForMedicalTech = "";
String strMsgForMedicalTechAtEnd="";


if(strMajorIndex != null && strMajorIndex.trim().length() > 0 && strMajorIndex.trim().length() > 0)
	strCourseCode = dbOP.mapOneToOther("MAJOR", "major_index",strMajorIndex,"course_code",null);
else
	strCourseCode = dbOP.mapOneToOther("COURSE_OFFERED", "course_index",strCourseIndex,"course_code",null);

if(strCourseCode != null && strCourseCode.indexOf("BSCS") >=0)
{
	strMsgForBSCSAfter3rdYrSummer = "Incoming Senior Students are required to render at least three hundred and twenty (320) hours "+
										"of On-the-Job Training (OJT) in compliance with the CHED's Academe-Industry Linkage Program";
	strMsgForBSCSAtEnd = "<br> <br>NOTE: The first two years curriculum is a Ladderized Course in Associate in Computer Science Leading to "+
							"B.S in computer Science.<br><br>";
}
else if(
	strCourseCode != null && false &&
	(strCourseCode.startsWith("BSMT") 	|| strCourseCode.startsWith("BSN") ||
	strCourseCode.startsWith("BSPharma")  	|| strCourseCode.startsWith("BSPT"))
	)
{
	strMsgForASHE = "** A certificate in Two-Year Associate in Health Science Education will be awarded after completion of the first "+
					"two years as per CMO No. 27,S. 1998.<br> <br>";
}
if(strCourseName != null && (strCourseCode.compareTo("BSMT") == 0 ||
	strCourseName.compareToIgnoreCase("bachelor of science in medical technology")==0) )
{
	strMsgForMedicalTech="Medical Tech. Internship (12 months - 52 weeks w/seminar - 42 units)<br>"+
						 "(6 months - 26 weeks w/seminar)";
	strMsgForMedicalTechAtEnd = " Revalida Examination (Written) ";
}

///added for CPU to view labfee in curriculum. 
boolean bolViewLabFee = false;
if(WI.fillTextValue("lf").length() > 0) 
	bolViewLabFee = true;
Vector vLabFeeDtls = new enrollment.FAFeeOperation().getLabFeeForACourse(dbOP, WI.fillTextValue("syf"),WI.fillTextValue("syt"), 
							WI.fillTextValue("ci"), WI.fillTextValue("mi"), WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), 
							WI.fillTextValue("semester"));
Vector vLabFeeSub = null;
if(vLabFeeDtls != null && vLabFeeDtls.size() > 0) 
	vLabFeeSub = (Vector)vLabFeeDtls.remove(0);
int iIndex = 0;
double dBusUnit = 0d;
double dLabFee  = 0d;
int iLabCharge  = 0;//0 = PER UNIT, 1 = PER TYPE, 2=PER HOUR.


String strSchCode = dbOP.getSchoolIndex();

boolean bolShowRLE = false;
if(strSchCode.startsWith("DLSHSI")) {
	if(strCourseName.indexOf("Nursing") > 0 )
		bolShowRLE = true;
	else {//i have to find if any subject in the curriculum has RLE.
		String strSQLQuery = "select count(*) from curriculum join subject on (subject.sub_index = curriculum.sub_index) where is_valid = 1 and sub_name like '%RLE)' and course_index = "+strCourseIndex+
					" and (major_index is null or major_index = "+WI.getStrValue(strMajorIndex, "0")+") and sy_from = "+strSYFrom+" and sy_to = "+strSYTo;
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) { 
			if(rs.getInt(1) > 0) 
				bolShowRLE = true;
		}
		rs.close();
	}
}
	
String strLABUnit = null;
String strRLEUnit = null;
double dNoOfRLEUnitPerSem = 0d;	
double dNoOfRLEUnitPerCourse = 0d;
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="100%" height="25" colspan="4" ><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=CM.getCollegeName(dbOP,strCourseIndex)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <br>
        <strong><%=strCourseName%></strong> <br>
        <%if(strMajorName.compareTo("None") !=0){//for elementary education, print Concentration instead of major
		if(strCourseName.compareToIgnoreCase("bachelor of elementary education") ==0 || 
				strCourseName.compareToIgnoreCase("bachelor in elementary education") ==0){%>
	  Concentration
	  <%}else{%>Major<%}%> in <strong><%=strMajorName%></strong><br>
		<%}%>
        Curriculum Year <strong><%=strSYFrom%> - <%=strSYTo%></strong><br>
      </div></td>
  </tr>
  <tr>
    <td height="25" colspan="4"><hr size="1"></td>
  </tr>
</table>

<table width="100%" border="0">
  <%
String [] astrConvertToWord={"First","Second","Third","Fourth","Fifth","Sixth","Seventh","Eighth","Nineth"};
Vector vRetResult = new Vector();
for( int i = 1; i<= aiYearSem[0][0]; ++i) //[0][0] = no of years
{	//get here year level internship - if so display it here.
	vRetResult = CM.viewInternshipPerYearForCourse(dbOP, strCourseIndex, strMajorIndex,strSYFrom,strSYTo,i);
	if(vRetResult != null && vRetResult.size() > 0){%>
  <tr> 
    <td>&nbsp;</td>
    <td colspan="11"><div align="center"><strong><%=astrConvertToWord[i-1]%> Year (Internship) </strong></div></td>
  </tr>
  <%
if(i == 4 && strMsgForMedicalTech.length() > 0){%>
  <tr> 
    <td>&nbsp;</td>
    <td colspan="11"><div align="center"><%=strMsgForMedicalTech%></div></td>
  </tr>
  <%}
	for(int k=0; k< vRetResult.size(); ++k){
	fInternship += Float.parseFloat((String)vRetResult.elementAt(k+2));
	%>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><%=(String)vRetResult.elementAt(k)%></td>
    <td colspan="5"><%=(String)vRetResult.elementAt(k+2)%> (<%=(String)vRetResult.elementAt(k+1)%>) </td>
<%if(!bolViewLabFee){%>
      <td>&nbsp;</td>
<%}else{%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}%>
  </tr>
  <%k = k+2;
	}%>
  <%if(strMsgForMedicalTechAtEnd.length() > 0){%>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><%=strMsgForMedicalTechAtEnd%></td>
    <td colspan="5"></strong></em></td>
<%if(!bolViewLabFee){%>
      <td>&nbsp;</td>
<%}else{%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}%>
  </tr>
  <%}%>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><div align="right"><strong><em>Total</em></strong></div></td>
    <td colspan="5"><em><strong><%=fInternship%> (<%=(String)vRetResult.elementAt(1)%>)</strong></em></td>
<%if(!bolViewLabFee){%>
      <td>&nbsp;</td>
<%}else{%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}%>
  </tr>
  <%continue;}//end of yearly internship%>
  <% if(i ==3 && strMsgForASHE.length() > 0){//third year - print for ASHE ;-)%>
  <tr> 
    <td>&nbsp;</td>
    <td colspan="11"><div align="center"><%=strMsgForASHE%></div></td>
  </tr>
  <%}%>
  <tr> 
    <td>&nbsp;</td>
    <td colspan="11"><div align="center"><strong><%=astrConvertToWord[i-1]%> Year </strong></div></td>
  </tr>
  <%
if(i == 4 && strMsgForMedicalTech.length() > 0){%>
  <tr> 
    <td>&nbsp;</td>
    <td colspan="11"><div align="center"><%=strMsgForMedicalTech%></div></td>
  </tr>
  <%}
	for(int j= 1; j<= aiYearSem[i][0]; ++j)
	{%>
  <tr> 
    <td width="2%">&nbsp;</td>
    <td colspan="11"><strong><u><%=astrConvertToWord[j-1]%> Semester</u></strong></td>
  </tr>
  <%
		vRetResult = CM.viewCurrPerSemester(dbOP, strCourseIndex, i, strMajorIndex,j, strSYFrom, strSYTo);
		int iGenderSpecific = 0;
		if(vRetResult != null)
			for(int k= 0 ; k< vRetResult.size(); ++k)
			{

	strLABUnit = (String)vRetResult.elementAt(k+4);

	if(((String)vRetResult.elementAt(k+2)).indexOf("RLE") > 0) {
		strRLEUnit = strLABUnit;
		strLABUnit = null;
	}
	else	
		strRLEUnit = null;

			//display the heading only once.
			if(i ==1 && j ==1 && k==0)
			{%>
  <tr> 
    <td rowspan="2">&nbsp;</td>
    <td  height="19" rowspan="2"><div align="left"><strong>SUBJECT CODE</strong></div></td>
    <td rowspan="2"><div align="left"><strong>SUBJECT NAME/DESCRIPTION</strong></div></td>
<%if(true || !bolShowRLE){%>
    <td colspan="2"><div align="center"><strong>HOURS</strong></div></td>
<%}%>
    <td colspan="2"><div align="center"><strong>UNITS</strong></div></td>
<%if(bolShowRLE){%>
				  <td>&nbsp;</td>
<%}if(!bolViewLabFee){%>
      <td rowspan="2"><div align="left"><font size="1"><strong>PRE-REQUISITE</strong></font></div></td>
<%}else{%>
      <td rowspan="2"><font size="1"><strong>TOTAL REG. UNIT</strong></font> </td>
      <td rowspan="2"><font size="1"><strong>TOTAL BUS. UNIT</strong></font></td>
      <td rowspan="2"><font size="1"><strong>LAB FEE</strong></font></td>
<%}%>
  </tr>
  <tr> 
<%if(true || !bolShowRLE){%>
    <td><div align="center"><strong>LEC.</strong></div></td>
    <td><div align="center"><strong>LAB.</strong></div></td>
<%}%>
    <td><div align="center"><strong>LEC.</strong></div></td>
    <td><div align="center"><strong>LAB.</strong></div></td>
<%if(bolShowRLE){%>
    <td><div align="center"><strong>RLE</strong></div></td>
<%}%>
  </tr>
  <%}%>
  <tr> 
    <td>&nbsp;</td>
    <td width="22%"><%=(String)vRetResult.elementAt(k+1)%></td>
    <td width="46%"><%=(String)vRetResult.elementAt(k+2)%></td>
<%if(true || !bolShowRLE){%>
    <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+5))%></td>
    <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+6))%></td>
<%}%>
    <td width="7%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+3))%></td>
      <td align="center" width="7%"><%=WI.getStrValue(strLABUnit, "&nbsp")%></td>
<%if(bolShowRLE){%>
      <td align="center" width="7%"><%=WI.getStrValue(strRLEUnit, "&nbsp")%></td>
<%}if(!bolViewLabFee){%>
    <td width="14%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+7))%></td>
<%}else{
dBusUnit = Double.parseDouble((String)vRetResult.elementAt(k+5)) + Double.parseDouble((String)vRetResult.elementAt(k+6));
iIndex = vLabFeeSub.indexOf(vRetResult.elementAt(k+1));
if(iIndex != -1) {
	dLabFee = ((Double)vLabFeeDtls.elementAt( (iIndex - 1)*3/2 + 2)).doubleValue();
	if(dLabFee == 0d)
		dLabFee = ((Double)vLabFeeDtls.elementAt( (iIndex - 1)*3/2 + 1)).doubleValue();
	iLabCharge = Integer.parseInt((String)vLabFeeDtls.elementAt( (iIndex - 1)*3/2 ));
	if(iLabCharge == 0) //per unit.
		dLabFee = dLabFee * (Double.parseDouble((String)vRetResult.elementAt(k+3)) + Double.parseDouble((String)vRetResult.elementAt(k+4)));
	else if(iLabCharge == 2) //per hour.	
		dLabFee = dLabFee * dBusUnit;
} 
if(dBusUnit > 20d)
	dBusUnit = 0d;
%>
      <td width="16%" align="center"><%=Double.parseDouble((String)vRetResult.elementAt(k+3)) + Double.parseDouble((String)vRetResult.elementAt(k+4))%></td>
      <td width="16%" align="center"><%=dBusUnit%></td>
      <td width="16%" align="center"><%if(iIndex != -1){%><%=dLabFee%><%}%></td>
<%}%>
  </tr>
  <%
		if(iGenderSpecific <1) {
			iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+3));
			if(strRLEUnit == null)
				iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+4));
			else	
				dNoOfRLEUnitPerSem += Double.parseDouble((String)vRetResult.elementAt(k+4));
			
			dNoOfLECHrPerSem += Double.parseDouble((String)vRetResult.elementAt(k+5));
			dNoOfLABHrPerSem += Double.parseDouble((String)vRetResult.elementAt(k+6));
		}
		if( vRetResult.elementAt(k + 8) != null && iGenderSpecific ==0) {
			++iGenderSpecific;
		}else
			iGenderSpecific = 0;
//			iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+3));
//			iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+4));
			k = k+9;
			}%>
  <%//Time to print Rivelda exam for medical tech.
if(i ==4 && strMsgForMedicalTechAtEnd.length() > 0){%>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><%=strMsgForMedicalTechAtEnd%></td>
<%if(true || !bolShowRLE){%>
    <td colspan="2">&nbsp;</td>
<%}%>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
<%if(bolShowRLE){%>
    <td>&nbsp;</td>
<%}if(!bolViewLabFee){%>
      <td>&nbsp;</td>
 <%}else{%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}%>
  </tr>
  <%}%>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><div align="right"><strong><font size="1">TOTAL</font></strong></div></td>
<%if(true || !bolShowRLE){%>
    <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfLECHrPerSem%></strong></font></div></td>
    <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfLABHrPerSem%></strong></font></div></td>
<%}%>
    <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=iNoOfLECUnitPerSem%></strong></font></div></td>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=iNoOfLABUnitPerSem%></strong></font></div></td>
<%if(bolShowRLE){%>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfRLEUnitPerSem%></strong></font></div></td>
<%}if(!bolViewLabFee){%>
      <td>&nbsp;</td>
 <%}else{%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}%>
  </tr>
  <tr> 
    <td colspan="12" align="center"><font size="1"><strong>TOTAL ACADEMIC UNIT(S): 
      <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem + dNoOfRLEUnitPerSem)%></strong></font></td>
  </tr>
  <%
		iNoOfLECUnitPerCourse += iNoOfLECUnitPerSem;
		iNoOfLABUnitPerCourse += iNoOfLABUnitPerSem;
		dNoOfRLEUnitPerCourse += dNoOfRLEUnitPerSem;

		iNoOfLECUnitPerSem = 0;
		iNoOfLABUnitPerSem = 0; dNoOfLABHrPerSem = 0d;dNoOfLECHrPerSem = 0d;
		
		dNoOfRLEUnitPerSem =0d;
	}//end of loop for semesters
/// end of a year == check if it is having summer for this year.
	vRetResult = CM.viewSummerCurrPerYr(dbOP,strCourseIndex,i, strMajorIndex,strSYFrom, strSYTo);
	if(vRetResult != null && vRetResult.size() > 0)
	{//start of summer courses.
	%>
  <tr> 
    <td>&nbsp;</td>
    <td colspan="11" align="center"><b>SUMMER</b></td>
  </tr>
  <%//
  	for(int p=0; p< vRetResult.size(); ++p) {
	
	strLABUnit = (String)vRetResult.elementAt(p+4);

	if(((String)vRetResult.elementAt(p+2)).indexOf("RLE") > 0) {
		strRLEUnit = strLABUnit;
		strLABUnit = null;
	}
	else	
		strRLEUnit = null;
	
	%>
  <tr> 
    <td>&nbsp;</td>
    <td width="22%"><%=(String)vRetResult.elementAt(p+1)%></td>
    <td width="46%"><%=(String)vRetResult.elementAt(p+2)%></td>
<%if(true || !bolShowRLE){%>
    <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+5))%></td>
    <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+6))%></td>
<%}%>
    <td width="7%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+3))%></td>
      <td align="center" width="7%"><%=WI.getStrValue(strLABUnit, "&nbsp")%></td>
<%if(bolShowRLE){%>
      <td align="center" width="7%"><%=WI.getStrValue(strRLEUnit, "&nbsp")%></td>
<%}if(!bolViewLabFee){%>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(p+7))%></td>
<%}else{
dBusUnit = Double.parseDouble((String)vRetResult.elementAt(p+5)) + Double.parseDouble((String)vRetResult.elementAt(p+6));
iIndex = vLabFeeSub.indexOf(vRetResult.elementAt(p+1));
if(iIndex != -1) {
	dLabFee = ((Double)vLabFeeDtls.elementAt( (iIndex - 1)*3/2 + 2)).doubleValue();
	if(dLabFee == 0d)
		dLabFee = ((Double)vLabFeeDtls.elementAt( (iIndex - 1)*3/2 + 1)).doubleValue();
	iLabCharge = Integer.parseInt((String)vLabFeeDtls.elementAt( (iIndex - 1)*3/2 ));
	if(iLabCharge == 0) //per unit.
		dLabFee = dLabFee * (Double.parseDouble((String)vRetResult.elementAt(p+3)) + Double.parseDouble((String)vRetResult.elementAt(p+4)));
	else if(iLabCharge == 2) //per hour.	
		dLabFee = dLabFee * dBusUnit;
} 
if(dBusUnit > 20d)
	dBusUnit = 0d;
%>
      <td align="center"><%=Double.parseDouble((String)vRetResult.elementAt(p+3)) + Double.parseDouble((String)vRetResult.elementAt(p+4))%></td>
      <td align="center"><%=dBusUnit%></td>
      <td align="center"><%if(iIndex != -1){%><%=dLabFee%><%}%>      </td>
<%}%>
  </tr>
  <%
		iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(p+3));
			if(strRLEUnit == null)
				iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(p+4));
			else	
				dNoOfRLEUnitPerSem += Double.parseDouble((String)vRetResult.elementAt(p+4));
			
		dNoOfLECHrPerSem += Double.parseDouble((String)vRetResult.elementAt(p+5));
		dNoOfLABHrPerSem += Double.parseDouble((String)vRetResult.elementAt(p+6));
		p = p+7;
	}%>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td bgcolor="#FFFFFF"><div align="right"><strong><font size="1">TOTAL</font></strong></div></td>
<%if(true || !bolShowRLE){%>
    <td bgcolor="#FFFFFF" class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfLECHrPerSem%></strong></font></div></td>
    <td bgcolor="#FFFFFF" class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfLABHrPerSem%></strong></font></div></td>
<%}%>
    <td bgcolor="#FFFFFF" class="thinborderTOP"><div align="center"><font size="1"><strong><%=iNoOfLECUnitPerSem%></strong></font></div></td>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=iNoOfLABUnitPerSem%></strong></font></div></td>
<%if(bolShowRLE){%>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfRLEUnitPerSem%></strong></font></div></td>
<%}if(!bolViewLabFee){%>
      <td>&nbsp;</td>
 <%}else{%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}%>
  </tr>
  <tr> 
    <td colspan="12" align="center"><font size="1"><strong>TOTAL ACADEMIC UNIT(S): 
      <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem + dNoOfRLEUnitPerSem)%></strong></font></td>
  </tr>
  <%
//time to print for CS instruction after summer
if( i ==3 && strMsgForBSCSAfter3rdYrSummer.length() >0){%>
  <tr> 
    <td height="22" colspan="12" align="center"><%=strMsgForBSCSAfter3rdYrSummer%></td>
  </tr>
  <%}%>
  <tr> 
    <td height="22" colspan="12">&nbsp;</td>
  </tr>
  <%
		iNoOfLECUnitPerCourse += iNoOfLECUnitPerSem;
		iNoOfLABUnitPerCourse += iNoOfLABUnitPerSem;
		dNoOfRLEUnitPerCourse += dNoOfRLEUnitPerSem;
	
		iNoOfLECUnitPerSem = 0;
		iNoOfLABUnitPerSem = 0; dNoOfLABHrPerSem = 0d;dNoOfLECHrPerSem = 0d;
		
		dNoOfRLEUnitPerSem =0d;
	}//end of loop for Summer == It starts after semister loops.

}//end of loop for year.
%>
</table>


<table  width="100%">

    <tr>
      <td colspan="5">&nbsp;</td>
  </tr>

    <tr>
      
    <td colspan="5"><strong>Total academic units for course <%=strCourseName%>: <u><%=iNoOfLECUnitPerCourse+iNoOfLABUnitPerCourse+dNoOfRLEUnitPerCourse%> ,Lecture Unit = <%=iNoOfLECUnitPerCourse%>, Lab Unit=<%=iNoOfLABUnitPerCourse%>
	<%if(bolShowRLE) {%>
		, RLE Unit = <%=dNoOfRLEUnitPerCourse%>
	<%}%>
	</u></strong></td>
    </tr>

</table>

<table width="100%" bgcolor="#FFFFFF">
<tr>
<td width="50%"></td>
<td width="50%"></td>
</tr>
<%
//get Internship detail here,
String[] astrDuration= {"week","hours","months"};
vRetResult = CM.viewInternshipForCourse(dbOP, strCourseIndex,  strMajorIndex, strSYFrom, strSYTo);
if(vRetResult != null && vRetResult.size() > 0)
{%>
	<tr>
	<td colspan="2" align="center"><b>:SUGGESTED INTERNSHIP SCHEDULE:</b></td>
	</tr>
<%
	for(int q=0; q< vRetResult.size() ; ++q)
	{
		if( ((String)vRetResult.elementAt(q+4)).compareTo("0") ==0)//in summer.
			strTemp = "Summer after "+astrConvertToWord[Integer.parseInt((String)vRetResult.elementAt(q+3)) - 1]+" year";
		else //sem break
			strTemp = astrConvertToWord[Integer.parseInt((String)vRetResult.elementAt(q+4)) - 1]+" Sem break of the "+
						astrConvertToWord[Integer.parseInt((String)vRetResult.elementAt(q+3)) -1]+" year";
		%>
		<tr>
		<td align="right"><%=strTemp%>&nbsp; &nbsp; &nbsp;</td>
		<td><%=(String)vRetResult.elementAt(q+2)%> <%=astrDuration[Integer.parseInt((String)vRetResult.elementAt(q+1))]%> -
			<%=(String)vRetResult.elementAt(q)%></td>
		</tr>
 	<%q = q+4;}

}//end of displaying internship%>


</table>
<%
if(vElectiveSubList != null && vElectiveSubList.size() > 0)
{%>
<table width="100%" bgcolor="#FFFFFF">
	<tr>
	<td width="17%"></td>
	<td width="83%"></td>
	</tr>
	<tr>
	  <td colspan="2" align="center"><b>:ELECTIVE SUBJECT LIST:</b></td>
	</tr>
<%//System.out.println(vElectiveSubList);
for(int i=0; i< vElectiveSubList.size(); ++i){
strTemp = (String)vElectiveSubList.elementAt(i);
%>
	<tr>
	  <td align="right" valign="top"><strong><%=strTemp%></strong>&nbsp; &nbsp; &nbsp;</td>
	<td>
	<%
	for(int j=0;i<vElectiveSubList.size(); ++i,++j){
	if(strTemp.compareTo((String)vElectiveSubList.elementAt(i)) ==0){
	if(j !=0){%>,<%}%>
	<%=(String)vElectiveSubList.elementAt(i+1)%>
	<% i = i+1;
	continue;
	}else {i = i-2; break;}
	}%>
	</td>
	</tr>
<%++i;
}%>
</table>
<%}//if there is elective.

dbOP.cleanUP();

if(strMsgForBSCSAtEnd.length() > 0){%>
<table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
 <tr>
    <td width="17%" height="25">&nbsp;</td>
      <td width="83%" align="center"><%=strMsgForBSCSAtEnd%></td>
  </tr>
</table>
<%}%>
<script language="javascript">
//window.print();
//window.setInterval("javascript:window.close();",0);
//window.setInterval("javascript:window.close();",0)
</script>

</body>
</html>
