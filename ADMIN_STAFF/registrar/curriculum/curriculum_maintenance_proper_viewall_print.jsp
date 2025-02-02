<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";
%>
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

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOM {
		border-bottom: solid 1px #000000;
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
	Vector vRetResult 		= new Vector();
	String strCollegeName   = null;

	float iNoOfLECUnitPerSem = 0f; float iNoOfLABUnitPerSem = 0f;
	float iNoOfLECUnitPerCourse = 0f;float iNoOfLABUnitPerCourse = 0f;
	
	double dNoOfLECHrPerSem = 0d;
	double dNoOfLABHrPerSem = 0d;

	WebInterface WI = new WebInterface(request);
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Courses curriculum - proper print","curriculum_maintenance_proper_viewall_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


//end of security code.
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
vRetResult = CM.getPREPCurDetail(dbOP, strCourseIndex,strMajorIndex, strSYFrom,strSYTo);
strCollegeName = CM.getCollegeName(dbOP,strCourseIndex);
//dbOP.cleanUP();

//get the footer Information. .
String strDeanName = null;
String strAssistRegistrar = null;
String strSchoolDirector  = null;

if(strSchCode.startsWith("UPH")){
	String strSQLQuery = "select dean_name from course_offered join college on (college.c_index = course_offered.c_index) where course_index =  "+strCourseIndex;
	strDeanName = WI.getStrValue(dbOP.getResultOfAQuery(strSQLQuery, 0)).toUpperCase();
	strAssistRegistrar = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"Assistant Registrar",7)).toUpperCase();
	strSchoolDirector  = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"School Director",7)).toUpperCase();
}


if(vRetResult == null || vRetResult.size() ==0)
{
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=CM.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
        return;
}
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="100%" height="25" colspan="4" ><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
        <br>
        <%=strCollegeName%><br>
        <strong><%=strCourseName%></strong> <br>
        <%if(strMajorName.compareTo("None") !=0){%>
		Major in <strong><%=strMajorName%></strong><br>
		<%}%>
        Curriculum Year <strong><%=strSYFrom%> - <%=strSYTo%></strong><br>
      </div></td>
  </tr>
  <tr>
    <td height="25" colspan="4"><hr size="1"></td>
  </tr>
</table>
  
<table width="100%" border="0" bgcolor="#FFFFFF">
  <%
String[] astrConvertToYr={"","First Year","Second Year","Third Year","Fourth Year","Fifth Year","Sixth Year","Seventh Year"};
String[] astrConvertToSem={"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
String[] astrConvertToProper = {"","Preparatory","Proper"};

int iYear = 0;
int iSem  = 0;
int iPrep = 0;
for( int i = 0; i< vRetResult.size();) //preparatory subjects.
{
iYear = Integer.parseInt((String)vRetResult.elementAt(i+1));
iSem  = Integer.parseInt((String)vRetResult.elementAt(i+2));
iPrep = Integer.parseInt((String)vRetResult.elementAt(i+9));
%>
  <tr> 
    <td>&nbsp;</td>
    <td colspan="7"><div align="center"><strong><%=astrConvertToYr[iYear]%> (<%=astrConvertToProper[iPrep]%>)</strong></div></td>
  </tr>
  <%
	for(int j= i; j<vRetResult.size();)
	{
		if( iYear != Integer.parseInt((String)vRetResult.elementAt(j+1)) || iPrep != Integer.parseInt((String)vRetResult.elementAt(i+9)))
			break;
		iSem  = Integer.parseInt((String)vRetResult.elementAt(j+2));
	%>
  <tr> 
    <td width="1%">&nbsp;</td>
    <td colspan="7"><strong><u><%=astrConvertToSem[iSem]%></u></strong></td>
  </tr>
  <%
		for(int k= i ; k< vRetResult.size();)
		{
			if(iSem != Integer.parseInt((String)vRetResult.elementAt(k+2)))
				break;

			//display the heading only once.
			if(k==0)
			{%>
  <tr> 
    <td rowspan="2">&nbsp;</td>
    <td  height="19" rowspan="2"><div align="left"><font size="1"><strong>SUBJECT 
        CODE</strong></font></div></td>
    <td rowspan="2"><div align="left"><font size="1"><strong>SUBJECT NAME/DESCRIPTION</strong></strong></font></div></td>
    <td colspan="2"><div align="center"><font size="1"><strong>HOURS</strong></font></div></td>
    <td colspan="2"><div align="center"><font size="1"><strong>UNITS</strong></font></div></td>
    <td rowspan="2"><div align="left"><font size="1"><strong>PRE-REQUISITE</strong></font></div></td>
  </tr>
  <tr> 
    <td width="7%"><div align="center"><font size="1"><strong>LEC.</strong></font></div></td>
    <td width="8%"><div align="center"><font size="1"><strong>LAB.</strong></font></div></td>
    <td width="5%"><div align="center"><font size="1"><strong>LEC.</strong></font></div></td>
    <td width="6%"><div align="center"><font size="1"><strong>LAB.</strong></font></div></td>
  </tr>
  <%}%>
  <tr> 
    <td>&nbsp;</td>
    <td width="18%"><%=(String)vRetResult.elementAt(k+3)%></td>
    <td width="39%"><%=(String)vRetResult.elementAt(k+4)%></td>
    <td align="center"><%=WI.getStrValue(vRetResult.elementAt(k+7))%></td>
    <td align="center"><%=WI.getStrValue(vRetResult.elementAt(k+8))%></td>
    <td align="center"><%=WI.getStrValue(vRetResult.elementAt(k+5))%></td>
    <td align="center"><%=WI.getStrValue(vRetResult.elementAt(k+6))%></td>
    <td width="16%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+10))%></td>
  </tr>
  <%
					iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+5));
					iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+6));
			
					dNoOfLECHrPerSem += Double.parseDouble((String)vRetResult.elementAt(k+5));
					dNoOfLABHrPerSem += Double.parseDouble((String)vRetResult.elementAt(k+6));
					k = k+11;
					j = k;
					i = j;
			}%>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><%
      if( i > vRetResult.size() -2){%>
      COMPREHENSIVE EXAM. 
      <%}%> <strong><font size="1">
      <div align="right">TOTAL</div>
      </font></strong></td>
    <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfLECHrPerSem%></strong></font></div></td>
    <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfLABHrPerSem%></strong></font></div></td>
    <td class="thinborderTOP"><div align="center"><strong><%=iNoOfLECUnitPerSem%></strong></div></td>
    <td class="thinborderTOP"><div align="center"><strong><%=iNoOfLABUnitPerSem%></strong></div></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="8" align="center"><font size="1"><strong>TOTAL ACADEMIC UNIT(S): 
      <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem)%></strong></font></td>
  </tr>
  <tr> 
    <td height="22" colspan="8">&nbsp;</td>
  </tr>
  <%
	iNoOfLECUnitPerCourse += iNoOfLECUnitPerSem;
	iNoOfLABUnitPerCourse += iNoOfLABUnitPerSem;

	iNoOfLECUnitPerSem = 0;
	iNoOfLABUnitPerSem = 0; dNoOfLABHrPerSem = 0d;dNoOfLECHrPerSem = 0d;
	}//end of loop for semesters



}//end of loop for year.
%>
</table>

<table bgcolor="#FFFFFF" width="100%">


    <tr>
      <td colspan="5"><strong>Total
        units for course <%=strCourseName%>: <u><%=iNoOfLECUnitPerCourse+iNoOfLABUnitPerCourse%> ,Lecture Unit = <%=iNoOfLECUnitPerCourse%>, Lab Unit=<%=iNoOfLABUnitPerCourse%></u></strong></td>
    </tr>
  </table>
  <%if(strSchCode.startsWith("UPH")){%><br><br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr align="center">
      <td width="32%" class="thinborderBOTTOM"><%=WI.getStrValue(strDeanName, "&nbsp;")%></td>
      <td width="2%">&nbsp;</td>
      <td width="32%">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="32%" class="thinborderBOTTOM"><%=WI.getStrValue(strAssistRegistrar, "&nbsp;")%></td>
    </tr>
    <tr align="center">
      <td>Dean</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>Assistant Registrar</td>
    </tr>
    <tr align="center">
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr align="center">
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td width="32%" class="thinborderBOTTOM"><%=WI.getStrValue(strSchoolDirector, "DR. ALFONSO H. LORETO")%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr align="center">
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>School Director</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}%>

</body>
</html>
