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

<body >
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
 	
	double dNoOfLABHrPerSem = 0d; 
	double dNoOfLECHrPerSem = 0d;
	
	WebInterface WI = new WebInterface(request);
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Courses Curriculum","curriculum_proper_viewall.jsp");
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
														"Admission","Courses Curriculum",request.getRemoteAddr(),
														"curriculum_proper_viewall.jsp");
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
/////////end...

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
        <%=strCollegeName%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
        <br>
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
    <td colspan="10"><div align="center"><strong><%=astrConvertToYr[iYear]%> (<%=astrConvertToProper[iPrep]%>)</strong></div></td>
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
    <td colspan="10"><strong><u><%=astrConvertToSem[iSem]%></u></strong></td>
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
    <td rowspan="2"><div align="left"><font size="1"><strong>SUBJECT TITLE </strong></strong></font></div></td>
    <td colspan="2"><div align="center"><font size="1"><strong>HOURS</strong></font></div></td>
    <td colspan="2"><div align="center"><font size="1"><strong>UNITS</strong></font></div></td>
<%if(!bolViewLabFee){%>
      <td rowspan="2"><div align="left"><font size="1"><strong>PRE-REQUISITE</strong></font></div></td>
<%}else{%>
      <td rowspan="2"><font size="1"><strong>TOTAL REG. UNIT</strong></font> </td>
      <td rowspan="2"><font size="1"><strong>TOTAL BUS. UNIT</strong></font></td>
      <td rowspan="2"><font size="1"><strong>LAB FEE</strong></font></td>
<%}%>
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
    <td width="18%"  height="19"><%=(String)vRetResult.elementAt(k+3)%></td>
    <td width="39%"><%=(String)vRetResult.elementAt(k+4)%></td>
    <td align="center"><%=WI.getStrValue(vRetResult.elementAt(k+7))%></td>
    <td align="center"><%=WI.getStrValue(vRetResult.elementAt(k+8))%></td>
    <td align="center"><%=WI.getStrValue(vRetResult.elementAt(k+5))%></td>
    <td align="center"><%=WI.getStrValue(vRetResult.elementAt(k+6))%></td>
<%if(!bolViewLabFee){%>
      <td width="16%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+10))%></td>
<%}else{
dBusUnit = Double.parseDouble((String)vRetResult.elementAt(k+7)) + Double.parseDouble((String)vRetResult.elementAt(k+8));
iIndex = vLabFeeSub.indexOf(vRetResult.elementAt(k+3));
if(iIndex != -1) {
	dLabFee = ((Double)vLabFeeDtls.elementAt( (iIndex - 1)*3/2 + 2)).doubleValue();
	if(dLabFee == 0d)
		dLabFee = ((Double)vLabFeeDtls.elementAt( (iIndex - 1)*3/2 + 1)).doubleValue();
	iLabCharge = Integer.parseInt((String)vLabFeeDtls.elementAt( (iIndex - 1)*3/2 ));
	if(iLabCharge == 0) //per unit.
		dLabFee = dLabFee * (Double.parseDouble((String)vRetResult.elementAt(k+5)) + Double.parseDouble((String)vRetResult.elementAt(k+6)));
	else if(iLabCharge == 2) //per hour.	
		dLabFee = dLabFee * dBusUnit;
} 
if(dBusUnit > 20d)
	dBusUnit = 0d;
%>
      <td width="16%" align="center"><%=Double.parseDouble((String)vRetResult.elementAt(k+5)) + Double.parseDouble((String)vRetResult.elementAt(k+6))%></td>
      <td width="16%" align="center"><%=dBusUnit%></td>
      <td width="16%" align="center"><%if(iIndex != -1){%><%=dLabFee%><%}%></td>
<%}%>
  </tr>
  <%
					iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+5));
					iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+6));
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
      <%}%> <div align="right"><strong><font size="1">TOTAL</font></strong></div></td>
    <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfLECHrPerSem%></strong></font></div></td>
    <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfLABHrPerSem%></strong></font></div></td>
    <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=iNoOfLECUnitPerSem%></strong></font></div></td>
    <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=iNoOfLABUnitPerSem%></strong></font></div></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="11" align="center"><font size="1"><strong>TOTAL ACADEMIC UNIT(S): 
      <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem)%></strong></font></td>
  </tr>
  <tr> 
    <td height="22" colspan="11">&nbsp;</td>
  </tr>
  <%
	iNoOfLECUnitPerCourse += iNoOfLECUnitPerSem;
	iNoOfLABUnitPerCourse += iNoOfLABUnitPerSem;

	iNoOfLECUnitPerSem = 0;
	iNoOfLABUnitPerSem = 0; dNoOfLABHrPerSem = 0d; dNoOfLECHrPerSem = 0d;
	}//end of loop for semesters



}//end of loop for year.
%>
</table>

<table bgcolor="#FFFFFF" width="100%">


    <tr>
      
    <td colspan="5"><strong>Total academic units for course <%=strCourseName%>: <u><%=iNoOfLECUnitPerCourse+iNoOfLABUnitPerCourse%> ,Lecture Unit = <%=iNoOfLECUnitPerCourse%>, Lab Unit=<%=iNoOfLABUnitPerCourse%></u></strong></td>
    </tr>
  </table>



<script language="javascript">
	window.print();
window.setInterval("javascript:window.close();",0);
</script>

</body>
</html>
