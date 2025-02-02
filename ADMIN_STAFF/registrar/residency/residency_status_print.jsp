<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style></head>
<script language="JavaScript">

</script>

<body>
<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.CurriculumMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vTemp = null;
	int i=0; int j=0;
	int iYear = 0;
	int iSem  = 0;
	int iTempYear = 0;
	int iTempSem = 0;
	int iSchYrFrom = 0;
	int iTempSchYrFrom = 0;

	double dGWA         = 0d;

	String strCollegeName = null;

	String[] astrPrepPropInfo = {""," (Preparatory)","(Proper)"};
	String[] astrConvertYear ={"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
	String strResidencyStatus = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-RESIDENCY STATUS MONITORING - PRINT","residency_status_print.jsp");
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
GradeSystem GS = new GradeSystem();
enrollment.GradeSystemTransferee GSTransferee = new enrollment.GradeSystemTransferee();
Vector vTFInfo = null;

vTFInfo = GSTransferee.viewFinalGradePerYrSemTransferee(dbOP,request.getParameter("stud_id"),true);
vTemp = GS.getResidencySummary(dbOP,request.getParameter("stud_id"));
if(vTemp == null)
	strErrMsg = GS.getErrMsg();
else
{
	//do something.
	strCollegeName = new CurriculumMaintenance().getCollegeName(dbOP,(String)vTemp.elementAt(15));
}
//I have to get the GWA for all the subjects completed so far.
	student.GWA gwa = new student.GWA();
	dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));

%>
<form action="./residency_status.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" ><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=strCollegeName%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div></td>
    </tr>

    <tr>
      <td height="25"><hr size="1"></td>
    </tr>
  </table>
<%
if(WI.getStrValue(strErrMsg).length() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
	  <td height="25" colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
</table>
<%}

if(vTemp != null && vTemp.size()>0)
{%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25">&nbsp;</td>
    <td width="15%">Student name : </td>
    <td width="45%"><strong><%=WI.formatName((String)vTemp.elementAt(1),(String)vTemp.elementAt(2),(String)vTemp.elementAt(3),1)%></strong></td>
    <td width="6%">
      <%
	  if(vTemp.elementAt(10) != null){%>
      Year :
      <%}%>
    </td>
    <td width="32%"><strong>
      <%if(vTemp.elementAt(10) != null){%>
      <%=astrConvertYear[Integer.parseInt((String)vTemp.elementAt(10))]%>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td width="2%" height="25">&nbsp;</td>
    <td>Course/Major :</td>
    <td><strong><%=(String)vTemp.elementAt(6)%>/<%=WI.getStrValue(vTemp.elementAt(7))%>
      (<%=(String)vTemp.elementAt(8)%>-<%=(String)vTemp.elementAt(9)%>)</strong></td>
    <td>Status:<strong> </strong></td>
    <td><strong>
      <%
strResidencyStatus = (String)vTemp.elementAt(14);
if(strResidencyStatus != null && strResidencyStatus.compareTo("0") ==0)
	strResidencyStatus = "Irregular";
else if(strResidencyStatus != null && strResidencyStatus.compareTo("1") ==0)
	strResidencyStatus = "Regular";
%>
      &nbsp;<%=WI.getStrValue(strResidencyStatus)%></strong></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25"  colspan="2">Total units required for this course : <strong><%=(String)vTemp.elementAt(12)%></strong></td>
    <td height="25"  colspan="2">Total Credit Earned: <strong><%=WI.getStrValue(vTemp.elementAt(13))%></strong></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25"  colspan="2">&nbsp;</td>
    <td height="25">GWA : </td>
    <td height="25"><strong><%=CommonUtil.formatFloat(dGWA, true)%></strong></td>
  </tr>
  <!--    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><div align="right"></div></td>
    </tr>
-->
</table>
  <%
//print here the transferee grade information.
if(vTFInfo != null && vTFInfo.size() > 0){
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="20" colspan="6" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF"><strong>-
          TOR ENTRIES FROM PREVIOUS SCHOOL - </strong></font></div></td>
    </tr>
    <tr>
      <td width="3%" height="25" >&nbsp;</td>
      <td width="23%"  height="25" ><div align="left"><font size="1"><strong>SUBJECT
          CODE</strong></font></div></td>
      <td width="53%" ><div align="left"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
      <td width="6%" ><div align="left"><font size="1"><strong>CREDITS EARNED</strong></font></div></td>
      <td width="5%" ><div align="left"><font size="1"><strong>FINAL GRADES</strong></font></div></td>
      <td width="10%" ><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
<%
for(i=0; i< vTFInfo.size(); )
{
	iSem = Integer.parseInt((String)vTFInfo.elementAt(i+10));
	iSchYrFrom = Integer.parseInt((String)vTFInfo.elementAt(i+8));

	/*System.out.println(vTFInfo.elementAt(i));
	System.out.println(vTFInfo.elementAt(i+1));
	System.out.println(vTemp.elementAt(i+2));
	System.out.println(vTFInfo.elementAt(i+3));
	System.out.println(vTFInfo.elementAt(i+4));
	System.out.println(vTFInfo.elementAt(i+5));
	System.out.println(vTFInfo.elementAt(i+6));
	*/
	%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="5">SCHOOL YEAR
	  (<%=(String)vTFInfo.elementAt(i+8) + " - "+(String)vTFInfo.elementAt(i+9)%>)/(<%=astrConvertYear[Integer.parseInt(WI.getStrValue(vTFInfo.elementAt(i + 11),"0"))] +
	  	 " - "+ (String)vTFInfo.elementAt(i+12)%>) </td>
    </tr>
	<%
	//run a loop here to display transferee information.
	 for(j=i; j< vTFInfo.size();)
	 {//System.out.println(vTemp.elementAt(j+4));System.out.println(vTemp.elementAt(j+5));

		iTempSem = Integer.parseInt((String)vTFInfo.elementAt(i+10));
		iTempSchYrFrom = Integer.parseInt((String)vTFInfo.elementAt(i+8));
		if(iTempSem != iSem || iTempSchYrFrom != iSchYrFrom)
			break;
	if(vTFInfo.elementAt(i) != null){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="5">School Name: <strong><%=(String)vTFInfo.elementAt(i)%></strong></td>
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><%=WI.getStrValue(vTFInfo.elementAt(j+1),"&nbsp;")%></td>
      <td><%=(String)vTFInfo.elementAt(j+2)%></td>
      <td><%=(String)vTFInfo.elementAt(j+3)%></td>
      <td><%=(String)vTFInfo.elementAt(j+5)%></td>
      <td><%=(String)vTFInfo.elementAt(j+6)%></td>
    </tr>
	<%
	j = j + 13;
	i = j;
	}
}%>
  </table>
    <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="20" colspan="6" bgcolor="#B9B292" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>-
          TOR ENTRIES FROM CURRENT SCHOOL - </strong></font></div></td>
    </tr>
</table>
 <%
 }//if vTemp !=null - student is having grade created already.


//check residency status in detail.
String strCourseType = (String)vTemp.elementAt(11);
float fTotalUnits = 0;
float fTotalUnitPerSem = 0;

vTemp = GS.getCompleteResidencyStatus(dbOP,(String)vTemp.elementAt(0),strCourseType);
if(vTemp == null)
{%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0">
  <td width="2%" height="25">&nbsp;</td>
  <td><%=GS.getErrMsg()%></td>
</table>
<%}
else {

	if(strCourseType.compareTo("0") ==0 || strCourseType.compareTo("3") ==0 || strCourseType.compareTo("4") ==0)//under graduate
	{%>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;</td>
    <td colspan="7"><div align="right"></div></td>
  </tr>
  <tr>
    <td rowspan="2">&nbsp;</td>
    <td width="15%"  height="19" rowspan="2"><div align="left"><strong>SUBJECT_CODE</strong></div></td>
    <td width="36%" rowspan="2"><div align="left"><strong>SUBJECT DESCRIPTION</strong></div></td>
    <td height="15" colspan="2"><div align="left"></div>
      <div align="center"><strong>UNIT</strong></div></td>
    <td width="16%" rowspan="2"><div align="center"><strong>CREDITS EARNED</strong></div></td>
    <td width="8%" rowspan="2"><strong>GRADE</strong></td>
    <td width="12%" rowspan="2"><strong>REMARKS</strong></td>
  </tr>
  <tr>
    <td width="6%" height="15"><div align="center"><strong>LEC </strong></div></td>
    <td width="6%"><div align="center"><strong>LAB</strong></div></td>
  </tr>
  <%
for(i=0 ; i< vTemp.size();){
if(vTemp.elementAt(i) != null)
	iYear = Integer.parseInt((String)vTemp.elementAt(i));
else
	iYear = -1;

if(vTemp.elementAt(i+1) != null)
	iSem = Integer.parseInt((String)vTemp.elementAt(i+1));
else
	iSem = -1;

if(vTemp.elementAt(i+10) != null)
	iSchYrFrom = Integer.parseInt((String)vTemp.elementAt(i+10));

if(iYear != -1 && iSem != -1){%>
  <tr>
    <td width="1%">&nbsp;</td>
    <td colspan="7"><strong><u><%=iYear%> Year/<%=astrConvertSem[iSem]%>,SY <%=(String)vTemp.elementAt(i+10) + " - "+(String)vTemp.elementAt(i+11)%>
      <%=astrPrepPropInfo[Integer.parseInt((String)vTemp.elementAt(i+9))]%></u></strong></td>
  </tr>
    <%}else if(iYear == -1 && iSem != -1){%>
  <tr>
    <td width="1%">&nbsp;</td>
    <td colspan="7"><strong><u><%=astrConvertSem[iSem]%>,SY <%=(String)vTemp.elementAt(i+10) + " - "+(String)vTemp.elementAt(i+11)%>
      <%=astrPrepPropInfo[Integer.parseInt((String)vTemp.elementAt(i+9))]%></u></strong></td>
  </tr>
<%} for(j=i; j< vTemp.size();){//System.out.println(vTemp.elementAt(j+4));System.out.println(vTemp.elementAt(j+5));

	if(iYear != -1)
		iTempYear = Integer.parseInt(WI.getStrValue((String)vTemp.elementAt(j),"0"));
	else
		iTempYear = -1;
	if(iSem != -1)
		iTempSem  = Integer.parseInt((String)vTemp.elementAt(j+1));
	else
		iTempSem = -1;
	//System.out.println(iTempYear);
	//System.out.println(iTempSem);
	//System.out.println(vTemp.size());

	if(vTemp.elementAt(i+10) != null)
		iTempSchYrFrom = Integer.parseInt((String)vTemp.elementAt(i+10));

	if(iTempYear!= iYear || iTempSem != iSem || iTempSchYrFrom != iSchYrFrom)
		break;
	//only if remark status is passed.
	//if( ((String)vTemp.elementAt(j+7)).compareToIgnoreCase("passed") ==0)
		fTotalUnitPerSem += Float.parseFloat(WI.getStrValue(vTemp.elementAt(j+8),"0"));
	 %>
  <tr>
    <td>&nbsp;</td>
    <td  height="19"><div align="left"><%=(String)vTemp.elementAt(j+2)%></div></td>
    <td><%=(String)vTemp.elementAt(j+3)%></td>
    <td><div align="center"><%=(String)vTemp.elementAt(j+4)%></div></td>
    <td><div align="center"><%=(String)vTemp.elementAt(j+5)%></div></td>
    <td align="center"><%=WI.getStrValue(vTemp.elementAt(j+8))%></td>
    <td>
      <%//Display F for failed grade.
	  //if( ((String)vTemp.elementAt(j+7)).toLowerCase().indexOf("fail") != -1){%>
      <!--F-->
      <%//}else{%>
      <%=(String)vTemp.elementAt(j+6)%>
      <%//}%>    </td>
    <td><%=(String)vTemp.elementAt(j+7)%></td>
  </tr>
  <%if(vTemp.elementAt(j+12) != null){%>
  <tr>
    <td>&nbsp;</td>
    <td  height="19"></td>
    <td colspan="6"><font size="1"><%=(String)vTemp.elementAt(j+12)%></font></td>
  </tr>
  <%}
	j = j+13;
	i = j;
	}///end of inner loop%>

  <tr>
    <td colspan="8"><div align="center"><em>Total units completed for this semester
        :<strong> <%=fTotalUnitPerSem%></strong></em></div></td>
  </tr>
  <%
fTotalUnits += fTotalUnitPerSem;
fTotalUnitPerSem = 0;
}//end of outer loop %>
</table>
<%}//end of displaying for graduate course.
else if(strCourseType.compareTo("2") ==0)//College of Medicine.
{%>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="2%">&nbsp;</td>
    <td colspan="8"><div align="right"></div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td  height="19" ><strong>SUBJECT CODE</strong></td>
    <td colspan="3"><strong>SUBJECT TITLE</strong></td>
    <td><strong>TOTAL LOAD</strong></td>
    <td><strong>CREDIT EARNED</strong></td>
    <td><strong>GRADE</strong></td>
    <td width="7%"><strong>REMARK</strong></td>
  </tr>
  <%
	String strMainSubject = null;
for(i=0 ; i< vTemp.size();){
iYear = Integer.parseInt((String)vTemp.elementAt(i));
iSem = Integer.parseInt((String)vTemp.elementAt(i+1));

	iSchYrFrom = Integer.parseInt((String)vTemp.elementAt(i+12));


%>
  <tr>
    <td align="center">&nbsp;</td>
    <td colspan="8"><strong><u> <%=iYear%> YEAR/<%=iSem%> SEMESTER<strong><u>,
      SY <%=(String)vTemp.elementAt(i+12) + " - "+(String)vTemp.elementAt(i+13)%></u></strong></u></strong></td>
  </tr>
  <%
for(j = i ; j< vTemp.size(); ++j)
{
iTempYear = Integer.parseInt((String)vTemp.elementAt(j));
iTempSem = Integer.parseInt((String)vTemp.elementAt(j+1));

	iTempSchYrFrom = Integer.parseInt((String)vTemp.elementAt(i+12));

if(iTempYear != iYear || iTempSem != iSem ||  iTempSchYrFrom != iSchYrFrom) break;

	strMainSubject = (String)vTemp.elementAt(j+2);
%>
  <tr>
    <td align="center"><em></em></td>
    <td align="center"><div align="left"><%=strMainSubject%></div></td>
    <td  colspan="3" align="center"><div align="left"><%=(String)vTemp.elementAt(j+3)%></div></td>
    <td align="center"><div align="left"><%=(String)vTemp.elementAt(j+6)%> (<%=(String)vTemp.elementAt(j+8)%>)
      </div></td>
    <td align="center"><%=(String)vTemp.elementAt(j+11)%></td>
    <td align="center"><div align="left">
        <%//Display F for failed grade.
	  if( ((String)vTemp.elementAt(j+10)).toLowerCase().indexOf("fail") != -1){%>
        F
        <%}else{%>
        <%=(String)vTemp.elementAt(j+9)%>
        <%}%>
      </div></td>
    <td><%=(String)vTemp.elementAt(j+10)%></td>
  </tr>
<%if(vTemp.elementAt(j + 14) != null){%>
    <tr>
      <td ></td>
      <td></td>
      <td  colspan="6"><font size="1"><%=(String)vTemp.elementAt(j+14)%></font></td>
    </tr>
    <%}
	for(int k = j ; k< vTemp.size();)
	{
		if(true)//forced break - because I am not displaying the sub Subject information.
			break;
		if(strMainSubject.compareTo((String)vTemp.elementAt(k+2)) !=0)
		{
			j = j-15;
			break;
		}
		%>
	  <tr>
		<td align="center">&nbsp;</td>
		<td width="21%"  height="21">&nbsp;</td>
		<td colspan="2">&nbsp;&nbsp;<%=(String)vTemp.elementAt(j+4)%></td>
		<td width="29%"><%=(String)vTemp.elementAt(j+5)%></td>
		<td width="8%"><%=(String)vTemp.elementAt(j+7)%></td>
		<td width="8%">&nbsp;</td>
		<td width="7%"><%=(String)vTemp.elementAt(j+9)%></td>
		<td><%=(String)vTemp.elementAt(j+10)%></td>
	  </tr>
	  <%
		k = k +15;
		j = k;
	}//show the sub subject.

	j = j+15;
	i = j;
  }//show the main subject for same year/ semester.%>
  <tr>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td  colspan="3" align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <%}//show major / sub subject detail %>
  <!--    <tr>
      <td colspan="8" align="center"><strong>4th Year </strong></td>
    </tr>
    <tr>
      <td colspan="8" align="center"><strong><u>Twelve Full-Month Clinical Clerkship
        Program</u></strong></td>
    </tr>-->
  <%
}//end of displyaing college of medicine course.
else if(strCourseType.compareTo("1") ==0)
{
	%>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
      <td width="1%">&nbsp;</td>
      <td width="17%" height="25"><strong>SUBJECT CODE</strong></td>
      <td width="28%"><strong>SUBJECT TITLE</strong></td>
      <td width="16%"><strong>TOTAL LOAD</strong></td>
      <td width="20%"><div align="center"><strong>CREDIT EARNED</strong></div></td>
      <td width="9%"><strong>GRADE</strong></td>
      <td width="9%"><strong>REMARK</strong></td>
    </tr>
	    <%
for(i=0 ; i< vTemp.size();)
{
if(vTemp.elementAt(i+2) != null)
	iSem = Integer.parseInt((String)vTemp.elementAt(i+2));
else
	iSem = 0;//for summer.
if(vTemp.elementAt(i) != null)
	iSchYrFrom = Integer.parseInt((String)vTemp.elementAt(i));

if(iSem != -1){%>
    <tr>
      <td width="1%">&nbsp;</td>
      <td colspan="7"><strong><u><%=astrConvertSem[iSem]%>,SY <%=(String)vTemp.elementAt(i) + " - "+(String)vTemp.elementAt(i+1)%></u></strong></td>
    </tr>
    <%}
 for(j=i; j< vTemp.size();)
 {
 	if(iSem != -1)
	{
		if(vTemp.elementAt(j+2) == null)
			iTempSem = 0;
		else
			iTempSem  = Integer.parseInt((String)vTemp.elementAt(j+2));
	}
	else
		iTempSem = -1;

	if(vTemp.elementAt(j) != null)
		iTempSchYrFrom = Integer.parseInt((String)vTemp.elementAt(j));

	if(iTempYear!= iYear || iTempSem != iSem || iTempSchYrFrom != iSchYrFrom)//and check for school year ;-)
		break;
	 %>
    <tr>
      <td>&nbsp;</td>
      <td  height="19"><%=(String)vTemp.elementAt(j+3)%></td>
      <td><%=(String)vTemp.elementAt(j+4)%></td>
      <td align="center"><%=(String)vTemp.elementAt(j+5)%> </td>
      <td align="center"><%=(String)vTemp.elementAt(j+8)%></td>
      <td align="center"><%=WI.getStrValue(vTemp.elementAt(j+6))%></td>
      <td><%//Display F for failed grade.
	  if( ((String)vTemp.elementAt(j+7)).toLowerCase().indexOf("fail") != -1){%>
	  F<%}else{%>
	  <%=(String)vTemp.elementAt(j+7)%>
	  <%}%>
	  </td>
    </tr>
<%if(vTemp.elementAt(j + 9) != null){%>
    <tr>
      <td>&nbsp;</td>
      <td  height="19">&nbsp;</td>
      <td colspan="5"><font size="1"><%=(String)vTemp.elementAt(j+9)%></font></td>
    </tr>
    <%}
j = j+10;
i = j;
}///end of inner loop%>

    <%
}//end of outer loop %>
  </table>
<%
			}//only if there course type is DOCTORAL / MASTERAL.
		}//if residency summery exisits
	   }//if student residency status in detail exists.


%>
<script language="JavaScript">
//alert("print");
window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
