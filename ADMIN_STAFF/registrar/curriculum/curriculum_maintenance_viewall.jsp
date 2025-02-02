<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript">
function PrintPage()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
		return true;
	return false;
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	String strCourseIndex 	= request.getParameter("ci");
	String strCourseName 	= request.getParameter("cname");
	String strMajorIndex 	= request.getParameter("mi");
	String strMajorName 	= request.getParameter("mname");
	if(strMajorName == null) strMajorName = "None";
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
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Courses curriculum -view","curriculum_maintenance_viewall.jsp");
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_maintenance_viewall.jsp");
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

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
CurriculumMaintenance CM = new CurriculumMaintenance();
if(strCourseIndex == null || strSYFrom == null || strSYTo == null)
{
	strErrMsg = "Can't process curriculum detail. couse, SY From , SY To information missing.";
	dbOP.cleanUP();
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=strErrMsg%></font></p>
	<%
	return;
}

//get here total year and semester of the course.
int[][] aiYearSem = null;
if(strSYFrom.length() > 0 && strSYTo.length() > 0)
	aiYearSem = CM.getMaxYearSemester(dbOP,strCourseIndex, strSYFrom, strSYTo);

if(aiYearSem == null) {
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
//added for LNU
String strMsgCertificateAfter1stYr = "";
String strMsgCertificateAfter2ndYr = "";
String strMsgCertificateAfter3rdYr = "";
String strMsgCertificateAfter4thYr = "";

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
	if(	((String)request.getSession(false).getAttribute("school_code")).startsWith("LNU"))
	{
		strMsgCertificateAfter1stYr = "Certificate to be awarded: Computer Encoding/Programming";
	 	strMsgCertificateAfter2ndYr = "Certificate to be awarded: Associate in Computer Science";
	 	strMsgCertificateAfter3rdYr = "Certificate to be awarded: Computer Programming Analyst";
	 	strMsgCertificateAfter4thYr = "To be awarded Diploma: B.S. Computer Science";
	}
}
else if(
	strCourseCode != null && false &&
	(strCourseCode.startsWith("BSMT") 	    || strCourseCode.startsWith("BSN") ||
	strCourseCode.startsWith("BSPharma")  	|| strCourseCode.startsWith("BSPT")) ) {
	strMsgForASHE = "** A certificate in Two-Year Associate in Health Science Education will be awarded after completion of the first "+
					"two years as per CMO No. 27,S. 1998.<br> <br>";
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
if(strSchCode.startsWith("UI"))
	strMsgForASHE = "";

if(strCourseName != null && strSchCode.startsWith("VMUF") && (strCourseCode.compareTo("BSMT") == 0 ||
	strCourseName.compareToIgnoreCase("bachelor of science in medical technology")==0) ) {
	strMsgForMedicalTech="Medical Tech. Internship (12 months - 52 weeks w/seminar - 42 units)<br>"+
						 "(6 months - 26 weeks w/seminar)";
	if(strSchCode.startsWith("VMUF"))
		strMsgForMedicalTechAtEnd = " Revalida Examination (Written) ";
}


///get the non-credit units.. 
Vector vNonCreditSubj = new enrollment.CurriculumSM().operateOnNonCreditSubject(dbOP, request, 4);

if(vNonCreditSubj == null)
	vNonCreditSubj = new Vector();
		
Integer objInt = null; int iIndexOf = 0;

String strCreditUnitLec = null;
String strCreditUnitLab = null;


boolean bolIsUC = strSchCode.startsWith("UC");

if(bolIsUC) {
//	if(strCourseName.toLowerCase().indexOf("nursing") > 0 || strCourseName.toLowerCase().indexOf("of law") > 0)
//		bolIsUC = false;
	String strSQLQuery = "select max(semester) from curriculum where is_valid = 1 and course_index = "+strCourseIndex;
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null && strSQLQuery.equals("3"))
		bolIsUC = true;
	else	
		bolIsUC = false;

}

boolean bolShowPayUnit = false;
if(strSchCode.startsWith("UB"))
	bolShowPayUnit = true;

double dPayUnit = 0d;//applicable for UB.  -- payunit = lec+lab unit + non-credit unit.



boolean bolShowCoReq = false;
String strSQLQuery = "select count(*) from SUBJECT_PREQUISITE where is_coreq = 1 and (is_del = 0 or (is_del = 1 and is_preq_disable = 1)) ";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null) {
	if(!strSQLQuery.equals("0"))
		bolShowCoReq = true;
}

boolean bolShowRLE = false;
if(strSchCode.startsWith("DLSHSI")) {
	if(strCourseName.indexOf("Nursing") > 0 )
		bolShowRLE = true;
	else {//i have to find if any subject in the curriculum has RLE.
		strSQLQuery = "select count(*) from curriculum join subject on (subject.sub_index = curriculum.sub_index) where is_valid = 1 and sub_name like '%RLE)' and course_index = "+strCourseIndex+
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
<form action="./curriculum_maintenance_viewall_print.jsp" method="post" target="_blank" onSubmit="return PrintPage();">
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" ><div align="center"><font color="#FFFFFF"><strong>::::
          COURSES CURRICULUM MAINTENANCE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:history.back()" target="_self"> <img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td width="23%" height="25" style="font-weight:bold; font-size:11px; color:#0000FF">
	  <input type="checkbox" name="show_subject_group" value="checked" <%=WI.fillTextValue("show_subject_group")%>> 
	  Show subject Group in Printout</td>
      <td width="27%" height="25"><div align="right">
          <input type="image" src="../../../images/print.gif" width="58" height="26">
          <font size="1">click to print curriculum</font></div></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="49%" valign="middle">Course: <strong><%=strCourseName%></strong></td>
      <td  colspan="2" valign="middle">
	  <%
	  if(strMajorName.compareTo("None") != 0){
	  if(strCourseName.compareToIgnoreCase("bachelor of elementary education") ==0 ||
	  strCourseName.compareToIgnoreCase("bachelor in elementary education") ==0){%>
	  Concentration
	  <%}else{%>Major<%}%>: <strong><%=strMajorName%></strong><%}%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Curriculum Year :<strong> <%=strSYFrom%> - <%=strSYTo%></strong></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <%
String strLecHour = null;
String strLabHour = null;

String [] astrConvertToWord={"First","Second","Third","Fourth","Fifth","Sixth","Seventh","Eighth","Nineth"};
Vector vRetResult = new Vector();
for( int i = 1; i<= aiYearSem[0][0]; ++i) //[0][0] = no of years
{
	//get here year level internship - if so display it here.
	vRetResult = CM.viewInternshipPerYearForCourse(dbOP, strCourseIndex, strMajorIndex,strSYFrom,strSYTo,i);
	if(vRetResult != null && vRetResult.size() > 0){%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="8"><div align="center"><strong><%=astrConvertToWord[i-1]%> Year (Internship) </strong></div></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%
if(i == 4 && strMsgForMedicalTech.length() > 0){%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="8"><div align="center"><%=strMsgForMedicalTech%></div></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
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
      <td>&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
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
      <td>&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><strong><em>Total</em></strong></div></td>
      <td colspan="5"><em><strong><%=fInternship%> (<%=(String)vRetResult.elementAt(1)%>)</strong></em></td>
      <td>&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%continue;}//end of yearly internship%>
    <% if(i ==3 && strMsgForASHE.length() > 0){//third year - print for ASHE ;-)%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="8"><div align="center"><%=strMsgForASHE%></div></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="8"><div align="center"><strong><%=astrConvertToWord[i-1]%> Year </strong></div></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%
if(i == 4 && strMsgForMedicalTech.length() > 0){%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="8"><div align="center"><%=strMsgForMedicalTech%></div></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%}
	for(int j= 1; j<= aiYearSem[i][0]; ++j)
	{%>
    <tr> 
      <td width="1%">&nbsp;</td>
      <td colspan="8"><strong><u><%=astrConvertToWord[j-1]%> <%if(bolIsUC) {%>Trimester<%}else{%>Semester<%}%></u></strong></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%
		vRetResult = CM.viewCurrPerSemester(dbOP, strCourseIndex, i, strMajorIndex,j, strSYFrom, strSYTo);
		int iGenderSpecific = 0;
		if(vRetResult != null)
			for(int k= 0 ; k< vRetResult.size(); ++k) {
			
				strTemp = (String)vRetResult.elementAt(k + 1);
				iIndexOf = vNonCreditSubj.indexOf(strTemp);
				
				if(iIndexOf > -1 && vNonCreditSubj.elementAt(iIndexOf + 1).equals(vRetResult.elementAt(k + 2)) ) {--iIndexOf;
					strCreditUnitLec = (String)vNonCreditSubj.elementAt(iIndexOf + 3);
					strCreditUnitLab = (String)vNonCreditSubj.elementAt(iIndexOf + 4);
					if(strCreditUnitLec != null && !strCreditUnitLec.equals("0")) {
						dPayUnit += Double.parseDouble(strCreditUnitLec);
						strCreditUnitLec = "("+strCreditUnitLec+".0)";
					}
					else	
						strCreditUnitLec = "0.0";
						
					if(strCreditUnitLab != null && !strCreditUnitLab.equals("0")) {
						dPayUnit += Double.parseDouble(strCreditUnitLab);
						strCreditUnitLab = "("+strCreditUnitLab+".0)";		
					}
					else	
						strCreditUnitLab = "0.0";
					vNonCreditSubj.remove(iIndexOf);vNonCreditSubj.remove(iIndexOf);vNonCreditSubj.remove(iIndexOf);
					vNonCreditSubj.remove(iIndexOf);vNonCreditSubj.remove(iIndexOf);vNonCreditSubj.remove(iIndexOf);
				}
				else {
					strCreditUnitLec = null;
					strCreditUnitLab = null;
				}

			
			//display the heading only once.
			if(i ==1 && j ==1 && k==0)
			{%>
				<tr> 
				  <td rowspan="2">&nbsp;</td>
				  <td  height="19" rowspan="2"><div align="left"><font size="1"><strong>SUBJECT 
					  CODE</strong></font></div></td>
				  <td rowspan="2"><div align="left"><font size="1"><strong>SUBJECT NAME/DESCRIPTION</strong></strong></font></div></td>
<%if(true || !bolShowRLE){%>
				  <td colspan="2"><div align="center"><font size="1"><strong>
				  <%if(!bolIsUC){%>HOURS<%}else{%>
				  	<table width="100%">
						<tr align="center" style="font-weight:bold">
							<td width="50%" style="font-size:9px;">Hrs:Mins</td>
							<td width="50%" style="font-size:9px;">Hrs:Mins</td>
						</tr>
					</table>
				  <%}%></strong></font></div></td>
<%}%>
				  <td colspan="2"><div align="center"><font size="1"><strong>UNITS</strong></font></div></td>
<%if(bolShowRLE){%>
				  <td>&nbsp;</td>
<%}%>
				  <td rowspan="2"><font size="1"><strong>PRE-REQUISITE</strong></font></td>
				  <%if(bolShowCoReq){%>
					<td rowspan="2"><font size="1"><strong>CO-REQUISITE</strong></font></td>
				  <%}%>
				</tr>
				<tr> 
<%if(true || !bolShowRLE){%>
				  <td width="7%"><div align="center"><font size="1"><strong>LEC.</strong></font></div></td>
				  <td width="7%"><div align="center"><font size="1"><strong>LAB.</strong></font></div></td>
<%}%>
				  <td width="6%"><div align="center"><font size="1"><strong>LEC.</strong></font></div></td>
				  <td width="6%"><div align="center"><font size="1"><strong>LAB.</strong></font></div></td>
<%if(bolShowRLE){%>
				  <td width="6%"><div align="center"><strong><font size="1">RLE</font></strong></div></td>
<%}%>
				</tr>
				<%}%>
<%
strLecHour = WI.getStrValue(vRetResult.elementAt(k+5));
strLabHour = WI.getStrValue(vRetResult.elementAt(k+6));


if(strCreditUnitLec != null) 
	strLABUnit = strCreditUnitLab;
else
	strLABUnit = (String)vRetResult.elementAt(k+4);

if(((String)vRetResult.elementAt(k+2)).indexOf("RLE") > 0) {
	strRLEUnit = strLABUnit;
	strLABUnit = null;
}
else	
	strRLEUnit = null;

//I have to format hour/min for UC.
if(bolIsUC) {
	if(strLecHour.length() > 0) {
		strLecHour = CommonUtil.formatFloat(strLecHour, true);
		strLecHour = ConversionTable.replaceString(strLecHour, ".",":");
	}
	if(strLabHour.length() > 0) {
		strLabHour = CommonUtil.formatFloat(strLabHour, true);
		strLabHour = ConversionTable.replaceString(strLabHour, ".",":");
	}

}%>
    <tr> 
      <td>&nbsp;</td>
      <td width="18%"  height="19"><%=(String)vRetResult.elementAt(k+1)%></td>
      <td width="39%"><%=(String)vRetResult.elementAt(k+2)%></td>
<%if(true || !bolShowRLE){%>
      <td align="center"><%=strLecHour%></td>
      <td align="center"><%=strLabHour%></td>
<%}%>
      <td align="center"><%if(strCreditUnitLec != null) {%>
	  	<%=strCreditUnitLec%>
	  <%}else{%>
	  	<%=WI.getStrValue(vRetResult.elementAt(k+3))%>
	  <%}%></td>
      <td align="center" width="3%"><%=WI.getStrValue(strLABUnit, "&nbsp")%></td>
<%if(bolShowRLE){%>
      <td align="center" width="3%"><%=WI.getStrValue(strRLEUnit, "&nbsp")%></td>
<%}%>
      <td width="16%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+7))%></td>
<%if(bolShowCoReq){%>
      <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+9))%></td>
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
				
			k = k+9;
			}%>
    <% if(i ==4 && strMsgForMedicalTechAtEnd.length() > 0){%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><%=strMsgForMedicalTechAtEnd%></td>
      <td colspan="2">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
      <td>&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%}	
if(bolIsUC) {
	strLecHour = CommonUtil.formatFloat(dNoOfLECHrPerSem, true);
	strLabHour = CommonUtil.formatFloat(dNoOfLABHrPerSem, true);

	//strLecHour = ConversionTable.replaceString(strLecHour, ".",":");
	//strLabHour = ConversionTable.replaceString(strLabHour, ".",":");
	strLecHour = "&nbsp;";
	strLabHour = "&nbsp;";
	
}
else {
	strLecHour = CommonUtil.formatFloat(dNoOfLECHrPerSem, false);
	strLabHour = CommonUtil.formatFloat(dNoOfLABHrPerSem, false);
}
%>    
	<tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><strong><font size="1">TOTAL</font></strong></div></td>
<%if(true || !bolShowRLE){%>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=strLecHour%></strong></font></div></td>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=strLabHour%></strong></font></div></td>
<%}%>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=iNoOfLECUnitPerSem%></strong></font></div></td>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=iNoOfLABUnitPerSem%></strong></font></div></td>
<%if(bolShowRLE){%>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfRLEUnitPerSem%></strong></font></div></td>
<%}%>
      <td>&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
	</tr>
    <tr> 
      <td colspan="9" align="center"><font size="1"><strong>TOTAL ACADEMIC UNIT(S): 
        <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem + dNoOfRLEUnitPerSem)%>
		<%if(bolShowPayUnit){%>
        	/<%=(iNoOfLECUnitPerSem + iNoOfLABUnitPerSem + dPayUnit)%>
		<%}%>
		</strong></font></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <tr> 
      <td height="22" colspan="9">&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%
		iNoOfLECUnitPerCourse += iNoOfLECUnitPerSem;
		iNoOfLABUnitPerCourse += iNoOfLABUnitPerSem;
		dNoOfRLEUnitPerCourse += dNoOfRLEUnitPerSem;

		iNoOfLECUnitPerSem = 0f; dPayUnit = 0d;
		iNoOfLABUnitPerSem = 0f; dNoOfLABHrPerSem = 0d;dNoOfLECHrPerSem = 0d;
		
		dNoOfRLEUnitPerSem =0d;
	}//end of loop for semesters

/// end of a year == check if it is having summer for this year.
	vRetResult = CM.viewSummerCurrPerYr(dbOP,strCourseIndex,i, strMajorIndex,strSYFrom, strSYTo);
	if(vRetResult != null && vRetResult.size() > 0)
	{//start of summer courses.
	%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="8" align="center"><b>SUMMER</b></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%//
  	for(int p=0; p< vRetResult.size(); ++p) {
		strLecHour = WI.getStrValue(vRetResult.elementAt(p+5));
		strLabHour = WI.getStrValue(vRetResult.elementAt(p+6));
		
		//I have to format hour/min for UC.
		if(bolIsUC) {
			if(strLecHour.length() > 0) {
				strLecHour = CommonUtil.formatFloat(strLecHour, true);
				strLecHour = ConversionTable.replaceString(strLecHour, ".",":");
			}
			if(strLabHour.length() > 0) {
				strLabHour = CommonUtil.formatFloat(strLabHour, true);
				strLabHour = ConversionTable.replaceString(strLabHour, ".",":");
			}
		
		}
				/////// for non-credit subjects.. 
				strTemp = (String)vRetResult.elementAt(p + 1);
				iIndexOf = vNonCreditSubj.indexOf(strTemp);
				
				if(iIndexOf > -1 && vNonCreditSubj.elementAt(iIndexOf + 1).equals(vRetResult.elementAt(p + 2)) ) {--iIndexOf;
					strCreditUnitLec = (String)vNonCreditSubj.elementAt(iIndexOf + 3);
					strCreditUnitLab = (String)vNonCreditSubj.elementAt(iIndexOf + 4);
					if(strCreditUnitLec != null && !strCreditUnitLec.equals("0")) {
						dPayUnit += Double.parseDouble(strCreditUnitLec);
						strCreditUnitLec = "("+strCreditUnitLec+".0)";
					}
					else	
						strCreditUnitLec = "0.0";
						
					if(strCreditUnitLab != null && !strCreditUnitLab.equals("0")) {
						dPayUnit += Double.parseDouble(strCreditUnitLab);
						strCreditUnitLab = "("+strCreditUnitLab+".0)";		
					}
					else	
						strCreditUnitLab = "0.0";
					vNonCreditSubj.remove(iIndexOf);vNonCreditSubj.remove(iIndexOf);vNonCreditSubj.remove(iIndexOf);
					vNonCreditSubj.remove(iIndexOf);vNonCreditSubj.remove(iIndexOf);vNonCreditSubj.remove(iIndexOf);
				}
				else {
					strCreditUnitLec = null;
					strCreditUnitLab = null;
				}
				///for non credit subject.. 
		
		
		
if(strCreditUnitLec != null) 
	strLABUnit = strCreditUnitLab;
else
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
      <td width="18%"  height="19"><%=(String)vRetResult.elementAt(p+1)%></td>
      <td width="39%"><%=(String)vRetResult.elementAt(p+2)%></td>
<%if(true || !bolShowRLE){%>
      <td align="center"><%=strLecHour%></td>
      <td align="center"><%=strLabHour%></td>
<%}%>
      <td align="center">
	  <%if(strCreditUnitLec != null) {%>
	  	<%=strCreditUnitLec%>
	  <%}else{%>
	  	<%=WI.getStrValue(vRetResult.elementAt(p+3))%>
	  <%}%>
	  
	  <%//=WI.getStrValue(vRetResult.elementAt(p+3))%></td>
      <td align="center"><%=WI.getStrValue(strLABUnit, "&nbsp")%></td>
<%if(bolShowRLE){%>
      <td align="center"><%=WI.getStrValue(strRLEUnit, "&nbsp")%></td>
<%}%>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(p+7))%></td>
<%if(bolShowCoReq){%>
      <td></td>
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
	}

if(bolIsUC) {
	strLecHour = CommonUtil.formatFloat(dNoOfLECHrPerSem, true);
	strLabHour = CommonUtil.formatFloat(dNoOfLABHrPerSem, true);

	//strLecHour = ConversionTable.replaceString(strLecHour, ".",":");
	//strLabHour = ConversionTable.replaceString(strLabHour, ".",":");
	strLecHour = "&nbsp;";
	strLabHour = "&nbsp;";
}
else {
	strLecHour = CommonUtil.formatFloat(dNoOfLECHrPerSem, false);
	strLabHour = CommonUtil.formatFloat(dNoOfLABHrPerSem, false);
}

	%>

    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><strong><font size="1">TOTAL</font></strong></div></td>
<%if(true || !bolShowRLE){%>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=strLecHour%></strong></font></div></td>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=strLabHour%></strong></font></div></td>
<%}%>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=iNoOfLECUnitPerSem%></strong></font></div></td>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=iNoOfLABUnitPerSem%></strong></font></div></td>
<%if(bolShowRLE){%>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfRLEUnitPerSem%></strong></font></div></td>
 <%}%>
      <td>&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <tr> 
      <td colspan="9" align="center"><strong><font size="1"><strong>TOTAL ACADEMIC 
        UNIT(S): <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem + dNoOfRLEUnitPerSem)%>
		<%if(bolShowPayUnit){%>
        	/<%=(iNoOfLECUnitPerSem + iNoOfLABUnitPerSem + dPayUnit)%>
		<%}%>
		</strong></font> </strong>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
		</td>
    </tr>
    <%
//time to print for CS instruction after summer
if( i ==3 && strMsgForBSCSAfter3rdYrSummer.length() >0){%>
    <tr> 
      <td height="22" colspan="9" align="center"><%=strMsgForBSCSAfter3rdYrSummer%></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%}%>
    <tr> 
      <td height="22" colspan="9">&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%
	iNoOfLECUnitPerCourse += iNoOfLECUnitPerSem;
	iNoOfLABUnitPerCourse += iNoOfLABUnitPerSem;
	dNoOfRLEUnitPerCourse += dNoOfRLEUnitPerSem;

	iNoOfLECUnitPerSem = 0;dPayUnit = 0d; dNoOfRLEUnitPerSem = 0d;
	iNoOfLABUnitPerSem = 0; dNoOfLABHrPerSem = 0d;dNoOfLECHrPerSem = 0d;
	}//end of loop for Summer == It starts after semister loops.

//time to print for Certificates given by LNU.
if( i ==1 && strMsgCertificateAfter1stYr.length() >0){%>
    <tr> 
      <td height="22" colspan="9" align="center"><em><%=strMsgCertificateAfter1stYr%></em></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%}
if( i ==2 && strMsgCertificateAfter2ndYr.length() >0){%>
    <tr> 
      <td height="22" colspan="9" align="center"><em><%=strMsgCertificateAfter2ndYr%></em></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%}
if( i ==3 && strMsgCertificateAfter3rdYr.length() >0){%>
    <tr> 
      <td height="22" colspan="9" align="center"><em><%=strMsgCertificateAfter3rdYr%></em></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%}
if( i ==4 && strMsgCertificateAfter4thYr.length() >0){%>
    <tr> 
      <td height="22" colspan="9" align="center"><em><%=strMsgCertificateAfter4thYr%></em></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%}



}//end of loop for year.
%>
  </table>

<table bgcolor="#FFFFFF" width="100%">


    <tr>
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="5"><font size="3"><strong>Total academic units for course <%=strCourseName%>:
        <u><%=iNoOfLECUnitPerCourse+iNoOfLABUnitPerCourse+dNoOfRLEUnitPerCourse%> ,Lecture Unit = <%=iNoOfLECUnitPerCourse%>,
        Lab Unit=<%=iNoOfLABUnitPerCourse%>
	<%if(bolShowRLE) {%>
		, RLE Unit = <%=dNoOfRLEUnitPerCourse%>
	<%}%>
		</u></strong></font></td>
    </tr>
    <tr>
      <td colspan="5">&nbsp;</td>
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
						astrConvertToWord[Integer.parseInt((String)vRetResult.elementAt(q+3)) - 1]+" year";
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
%>


<table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
<%
if(strMsgForBSCSAtEnd.length() > 0){%>  <tr>
    <td width="17%" height="25">&nbsp;</td>
      <td width="83%" align="center"><%=strMsgForBSCSAtEnd%></td>
  </tr>
<%}%>
  <tr>
    <td width="17%" height="25">&nbsp;</td>
    <td width="83%" height="25"><input type="image" src="../../../images/print.gif" width="58" height="26"><font size="1">click
      to print curriculum</font></td>
  </tr>
  <tr>
    <td colspan="2"><div align="center"> </div></td>
  </tr>
  <tr>
    <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="ci" value="<%=request.getParameter("ci")%>">
<input type="hidden" name="cname" value="<%=request.getParameter("cname")%>">
<input type="hidden" name="mname" value="<%=WI.fillTextValue("mname")%>">

<%
strTemp = request.getParameter("mi");
if(strTemp == null) strTemp = "";
%>
<input type="hidden" name="mi" value="<%=strTemp%>">
<input type="hidden" name="syf" value="<%=request.getParameter("syf")%>">
<input type="hidden" name="syt" value="<%=request.getParameter("syt")%>">
</form>

</body>
</html>
