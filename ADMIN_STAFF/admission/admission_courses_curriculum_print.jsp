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


</script>
</head>

<body>
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	String strErrMsg = null;
	String strTemp = null;

	String strCourseIndex 	= request.getParameter("ci");
	String strCourseName 	= request.getParameter("cname");
	String strMajorIndex 	= request.getParameter("mi");
	String strMajorName 	= request.getParameter("mname");
	if(strMajorName == null) strMajorName = "None";
	String strSYFrom 		= request.getParameter("syf");
	String strSYTo 			= request.getParameter("syt");

	float iNoOfLECUnitPerSem = 0; float iNoOfLABUnitPerSem = 0;
	float iNoOfLECUnitPerCourse = 0;float iNoOfLABUnitPerCourse = 0;

	WebInterface WI = new WebInterface(request);
////request.getSession(false).setAttribute("userId","biswa");
	try
	{
		dbOP = new DBOperation();
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

boolean bolShowCoReq = false;
String strSQLQuery = "select count(*) from SUBJECT_PREQUISITE where is_coreq = 1 and (is_del = 0 or (is_del = 0 and is_preq_disable = 1)) ";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null) {
	if(!strSQLQuery.equals("0"))
		bolShowCoReq = true;
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

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4" ><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=CM.getCollegeName(dbOP,strCourseIndex)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div></td>
    </tr>

    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="40%" valign="middle">Course
        : <strong><%=strCourseName%></strong></td>
      <td width="29%" valign="middle">
	  <%if(strMajorName.compareTo("None") != 0){%>
	  Major : <strong><%=strMajorName%></strong><%}%></td>
      <td width="29%" valign="middle">
        Effective SY: <strong><%=strSYFrom%> - <%=strSYTo%></strong></td>
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
{%>
  <tr>
    <td>&nbsp;</td>
    <td colspan="7"><div align="center"><strong><%=astrConvertToWord[i-1]%> Year
        </strong></div></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
  </tr>
  <%
	for(int j= 1; j<= aiYearSem[i][0]; ++j)
	{%>
  <tr>
    <td width="2%">&nbsp;</td>
    <td colspan="7"><strong><u><%=astrConvertToWord[j-1]%> Semester</u></strong></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
  </tr>
  <%
		vRetResult = CM.viewCurrPerSemester(dbOP, strCourseIndex, i, strMajorIndex,j, strSYFrom, strSYTo);
		int iGenderSpecific = 0;
		if(vRetResult != null)
			for(int k= 0 ; k< vRetResult.size(); ++k)
			{
			//display the heading only once.
			if(i ==1 && j ==1 && k==0)
			{%>
  <tr>
    <td rowspan="2">&nbsp;</td>
    <td  height="19" rowspan="2"><strong>SUBJECT CODE</strong></td>
    <td rowspan="2"><strong>SUBJECT TITLE </strong></td>
    <td colspan="2"><div align="center"><strong>HOURS</strong></div></td>
    <td colspan="2"><div align="center"><strong> UNITS</strong></div></td>
    <td rowspan="2"><strong>PRE-REQUISITE</strong></td>
<%if(bolShowCoReq){%>
    <td rowspan="2"><strong>CO-REQUISITE</strong></td>
<%}%>
  </tr>
  <tr>
    <td><div align="center"><strong>LEC.</strong></div></td>
    <td><div align="center"><strong>LAB.</strong></div></td>
    <td><div align="center"><strong>LEC.</strong></div></td>
    <td><div align="center"><strong>LAB.</strong></div></td>
  </tr>
  <%}%>
  <tr>
    <td>&nbsp;</td>
    <td width="22%"  height="19"><%=(String)vRetResult.elementAt(k+1)%></td>
    <td width="46%"><%=(String)vRetResult.elementAt(k+2)%></td>
    <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+5))%></td>
    <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+6))%></td>
    <td width="7%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+3))%></td>
    <td width="7%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+4))%></td>
    <td width="14%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+7))%></td>
<%if(bolShowCoReq){%>
    <td width="10%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+9))%></td>
<%}%>
  </tr>
  <%
		if(iGenderSpecific <1) {
			iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+3));
			iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+4));
		}
		if( vRetResult.elementAt(k + 8) != null && iGenderSpecific ==0) {
			++iGenderSpecific;
		}else
			iGenderSpecific = 0;
//			iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+3));
//			iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+4));
			k = k+9;
			}%>
  <tr>
    <td colspan="8"><div align="center"><em><strong>Total units : <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem)%>
        ,Lecture Unit = <%=iNoOfLECUnitPerSem%>, Lab Unit=<%=iNoOfLABUnitPerSem%></strong></em></div></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
  </tr>
  <%
	iNoOfLECUnitPerCourse += iNoOfLECUnitPerSem;
	iNoOfLABUnitPerCourse += iNoOfLABUnitPerSem;

	iNoOfLECUnitPerSem = 0;
	iNoOfLABUnitPerSem = 0;
	}//end of loop for semesters

/// end of a year == check if it is having summer for this year.
	vRetResult = CM.viewSummerCurrPerYr(dbOP,strCourseIndex,i, strMajorIndex,strSYFrom, strSYTo);
	if(vRetResult != null && vRetResult.size() > 0)
	{//start of summer courses.
	%>
  <tr>
    <td>&nbsp;</td>
    <td colspan="7" align="center"><b>SUMMER</b></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
 </tr>
  <%//
  	for(int p=0; p< vRetResult.size(); ++p)
	{%>
  <tr>
    <td>&nbsp;</td>
    <td width="22%"  height="19"><%=(String)vRetResult.elementAt(p+1)%></td>
    <td width="46%"><%=(String)vRetResult.elementAt(p+2)%></td>
    <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+5))%></td>
    <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+6))%></td>
    <td width="7%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+3))%></td>
    <td width="7%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+4))%></td>
    <td width="14%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+7))%></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
  </tr>
  <%
		iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(p+3));
		iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(p+4));
		p = p+7;
	}%>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
  </tr>
  <tr>
    <td colspan="8" align="center"><em><strong>Total units : <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem)%>
      ,Lecture Unit = <%=iNoOfLECUnitPerSem%>, Lab Unit=<%=iNoOfLABUnitPerSem%></strong></em></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
  </tr>
  <tr>
    <td height="22" colspan="8">&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
  </tr>
  <%
	iNoOfLECUnitPerCourse += iNoOfLECUnitPerSem;
	iNoOfLABUnitPerCourse += iNoOfLABUnitPerSem;

	iNoOfLECUnitPerSem = 0;
	iNoOfLABUnitPerSem = 0;
	}//end of loop for Summer == It starts after semister loops.


}//end of loop for year.
%>
</table>

<table  width="100%">

    <tr>
      <td colspan="5">&nbsp;</td>
  </tr>

    <tr>
      <td colspan="5"><strong>Total
        units for course <%=strCourseName%>: <u><%=iNoOfLECUnitPerCourse+iNoOfLABUnitPerCourse%> ,Lecture Unit = <%=iNoOfLECUnitPerCourse%>, Lab Unit=<%=iNoOfLABUnitPerCourse%></u></strong></td>
    </tr>

</table>
<table width="100%" bgcolor="#FFFFFF">
<tr>
<td width="50%"></td>
<td width="50%"></td>
</tr>
<%
//get Internship detail here,
String[] astrDuration= {"week","hours"};
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
Vector vElectiveSubList = CM.getElectiveSubListPerCurriculum(dbOP, strCourseIndex,strMajorIndex, strSYFrom, strSYTo);
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
for(int s=0; s< vElectiveSubList.size(); ++s){
strTemp = (String)vElectiveSubList.elementAt(s);
%>
	<tr>
	  <td align="right" valign="top"><strong><%=strTemp%></strong>&nbsp; &nbsp; &nbsp;</td>
	<td>
	<%
	for(int t=0;s<vElectiveSubList.size(); ++s,++t){
	if(strTemp.compareTo((String)vElectiveSubList.elementAt(s)) ==0){
	if(t !=0){%>,<%}%>
	<%=(String)vElectiveSubList.elementAt(s+1)%>
	<% s = s+1;
	continue;
	}else {s = s-2; break;}
	}%>
	</td>
	</tr>
<%++s;
}%>
</table>
<%}//if there is elective.



dbOP.cleanUP();
%>
<script language="JavaScript">
	window.print();
window.setInterval("javascript:window.close();",0);
//window.setInterval("javascript:self.close();",0);
</script>

</body>
</html>
