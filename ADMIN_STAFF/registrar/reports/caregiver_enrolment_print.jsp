<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summarized Rating Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td.subheader {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}	

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;

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
	font-size: 10px;
    }
    .thinborderALL {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	border-top: 1px solid #000000;
	border-right: 1px solid #000000;
	border-bottom: 1px solid #000000;
	border-left: 1px solid #000000;
    }
    TD.thinborderLRB {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

-->
</style>
</head>

<body leftmargin="1" topmargin="0">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment, enrollment.EntranceNGraduationData,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp =  null;
	String strErrMsg = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
	String[] astrConvYrLevel = {"short-term","1st-year", "2nd-year", "3rd-year"};
	String[] astrConvCourseDur = {"6-months","1 Year", "2 Years", "3 Years", "4 Years"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-TESDA Reports","caregiver_enrolment_print.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(), 
														"caregiver_enrolment_print.jsp");	
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

// end of authentication

String strCollegeName = new enrollment.CurriculumMaintenance().getCollegeName(dbOP,WI.fillTextValue("course_index"));
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);

ReportEnrollment re = new ReportEnrollment();

Vector vRetResult = null;

int iTmpValue = new EntranceNGraduationData().getMaxYearLevel(dbOP,WI.fillTextValue("course_index"));


Vector vMapCivilStatus = new Vector();	
	vMapCivilStatus.addElement(null);
	vMapCivilStatus.addElement("Single");
	vMapCivilStatus.addElement("Married");
	vMapCivilStatus.addElement("Widow/Widower");
	vMapCivilStatus.addElement("SingleParent");
	vMapCivilStatus.addElement("Divorced");

Vector vMapSex = new Vector();
	vMapSex.addElement("F");
	vMapSex.addElement("M");
	

	vRetResult = re.getTesdaEnrollment(dbOP,request);
	//System.out.println(re.getErrMsg());
	int i = 0;
%>

<% if (vRetResult == null || vRetResult.size() == 0) {%>
<table>  <tr> 
    <td>&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
  </tr></table>
<%}else{%>
<table width="1125" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td width="1019"> <div align="center"> 
        <p><strong><font size="2">Republic of the Philippines</font></strong> 
          <br>
          <font size="2"> <strong>TECHNICAL EDUCATION AND SKILLS DEVELOPMENT AUTHORITY</strong><br>
          <%=SchoolInformation.getInfo5(dbOP,false,false)%></font><br>
          <strong><br>
          <font size="2">ENROLMENT REPORT</font> </strong>
        <p></div></td>
  </tr>
</table>
<table width="1125" cellpadding="1" cellspacing="0" >
  <tr> 
    <td width="119">Name of School: </td>
    <td width="692"><strong><%=SchoolInformation.getSchoolName(dbOP,false, false)%></strong></td>
    <td width="181"> Revised TESDA Form 1</td>
  </tr>
  <tr>
    <td>Complete Address:</td>
    <td><strong><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></strong></td>
    <td> (for school-based courses)</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<table width="1125" cellpadding="1" cellspacing="0" class="thinborder">
  <tr> 
    <td width="579" valign="top" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="25%">School Year: </td>
          <td width="75%"><strong><%=WI.fillTextValue("sy_from")%><%=WI.getStrValue(request.getParameter("sy_to")," - ", "","")%></strong></td>
        </tr>
        <tr> 
          <td>Program CourseTitle:</td>
          <td><strong>&nbsp;<%=dbOP.mapOneToOther("course_offered", "is_del","0","course_name"," and course_index =" + WI.fillTextValue("course_index"))%></strong></td>
        </tr>
        <tr> 
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr> 
          <td colspan="2">Program/Course Certification No. (UTPRAS):&nbsp;<strong><%=WI.fillTextValue("utpras")%></strong>&nbsp;&nbsp;&nbsp;&nbsp;Date 
            Issued: <strong><%=WI.fillTextValue("doi")%></strong></td>
        </tr>
      </table>
      <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr> 
          <td width="24%" colspan="4">Course Duration</td>
        </tr>
        <tr> 
          <td>( ) 3 - year</td>
          <td>( ) 2 -year</td>
          <td>( ) 1-year</td>
          <td>( ) 6 months</td>
        </tr>
        <tr> 
          <td colspan="2">( ) below 6 months , pls. indicate ____</td>
          <td> ( ) CBC Modular</td>
          <td>&nbsp;</td>
        </tr>
        <tr> 
          <td colspan="4">Term : </td>
        </tr>
<%
	String strTemp2 = null;
	strTemp = WI.fillTextValue("semester");
	if (strTemp.compareTo("1") ==0) strTemp2 = "<img src=\"../../../images/tick.gif\">";
%>
        <tr>
          <td>(<%=WI.getStrValue(strTemp2)%>) First Semester</td>
<%	strTemp2=null;if (strTemp.compareTo("2") ==0) strTemp2 = "<img src=\"../../../images/tick.gif\">";%>
          <td>(<%=WI.getStrValue(strTemp2)%>) Second Semester</td>
<%	strTemp2=null;if (strTemp.compareTo("3") ==0) strTemp2 = "<img src=\"../../../images/tick.gif\">";%>
          <td>(<%=WI.getStrValue(strTemp2)%>) Third Semester</td>
<%	strTemp2=null;if (strTemp.compareTo("0") ==0) strTemp2 = "<img src=\"../../../images/tick.gif\">";%>
          <td>(<%=WI.getStrValue(strTemp2)%>) Summer</td>
        </tr>
        <tr> 
          <td colspan="4">Year Level : </td>
        </tr>
        <tr> 
          <td>( ) 3 year </td>
          <td>( ) 2 year</td>
          <td>( ) 1 - year</td>
          <td>( ) Short Term</td>
        </tr>
      </table> </td>
    <td width="313" valign="top" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td colspan="3">Date Started: </td>
        </tr>
        <tr> 
          <td colspan="3">&nbsp;</td>
        </tr>
        <tr> 
          <td colspan="3">Date Finished: </td>
        </tr>
        <tr> 
          <td colspan="3">&nbsp;</td>
        </tr>
        <tr> 
          <td colspan="3">&nbsp;</td>
        </tr>
        <tr> 
          <td width="51%">Number of Enrolees</td>
          <td width="22%">Male : </td>
          <td width="27%">__<u><%=(String)vRetResult.elementAt(1)%></u>__</td>
        </tr>
        <tr> 
          <td>&nbsp;</td>
          <td>Female : </td>
          <td>__<u><%=(String)vRetResult.elementAt(0)%></u>__</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>Total : </td>
          <td>__<u><%=Integer.parseInt((String)vRetResult.elementAt(0)) + Integer.parseInt((String)vRetResult.elementAt(1))%></u>__</td>
        </tr>
      </table></td>
    <td width="225" valign="top" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td>Names of Instructors : </td>
        </tr>
        <tr>
          <td>&nbsp;</td>
        </tr>
      </table></td>
  </tr>
</table>
<% 
	boolean bolShowPageBreak = false;	
	int iCount = 1; 
	int iRows = 1; 
	int iMaxRows = 18;
	int iMaxRowsPage2=36;
	i = 2; 
	for (;i < vRetResult.size();){		
%>
<table width="1125" border="0" cellpadding="1" cellspacing="0" class="thinborder">
  <tr> 
    <td colspan="4" class="thinborder"><div align="center">NAME</div></td>
    <td colspan="4" class="thinborder"><div align="center">ADDRESS</div></td>
    <td colspan="3" class="thinborder"><div align="center">PROFILE</div></td>
    <td width="60" rowspan="2" class="thinborder"><div align="center">Remarks</div></td>
  </tr>
  <tr> 
    <td width="10" class="thinborder">No.</td>
    <td width="85" class="thinborder"><div align="center">Last Name</div></td>
    <td width="85" class="thinborder"><div align="center">First Name</div></td>
    <td width="35" class="thinborder"><div align="center">MI.</div></td>
    <td width="214" class="thinborder"><div align="center">No./ Street / Brgy.</div></td>
    <td width="94" class="thinborder"><div align="center">Municipality</div></td>
    <td width="53" class="thinborder"><div align="center">District</div></td>
    <td width="115" class="thinborder"><div align="center">Province</div></td>
    <td width="49" class="thinborder"><div align="center">Civil Status</div></td>
    <td width="40" class="thinborder"><div align="center">Sex</div></td>
    <td width="50" class="thinborder"><div align="center">Age</div></td>
  </tr>
<%

	for (; i < vRetResult.size() ; i+=11,iRows++){
		if (iRows >= iMaxRows){
			iRows = 1;
			iMaxRows = iMaxRowsPage2;
			bolShowPageBreak = true;
			break;			
		}
		else
			bolShowPageBreak = false;	
%>
  <tr> 
    <td class="thinborder"><%=iCount++%>&nbsp;</td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder">
		<% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+2));
			if (strTemp.length() > 0){%> <%=strTemp.charAt(0) + "."%>
			<%}else{%>&nbsp<%}%>
			</td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"&nbsp")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+9),"&nbsp")%></td>
	<% 	
		strTemp = Integer.toString(vMapCivilStatus.indexOf((String)vRetResult.elementAt(i+5)));
		if (strTemp.compareTo("-1") == 0 || (String)vRetResult.elementAt(i+5) == null){
			strTemp = "&nbsp";
		}
	%>
	
    <td class="thinborder"><%=strTemp%></td>

	<% 	
		strTemp = Integer.toString(vMapSex.indexOf((String)vRetResult.elementAt(i+4)));
		if (strTemp.compareTo("-1") == 0 || (String)vRetResult.elementAt(i+4) == null){
			strTemp = "&nbsp";
		}
	%>
    <td class="thinborder"><%=strTemp%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp")%></td>
    <td class="thinborder">&nbsp;</td>
  </tr>
<%} //end for loop%>
</table>
<% if (i<vRetResult.size()){%>
<table width="1125" cellpadding="0" cellspacing="0" >
  <tr> 
    <td> <table width="1125" align="right" cellpadding="0" cellspacing="0" >
        <tr> 
          <td width="8%"><strong>Legends:</strong></td>
          <td width="10%">&nbsp;</td>
          <td width="9%">&nbsp;</td>
          <td width="15%">&nbsp;</td>
          <td width="15%">&nbsp;</td>
          <td width="21%"><strong>&nbsp;&nbsp; Prepared by </strong></td>
          <td width="22%"><strong>Noted by:</strong></td>
        </tr>
        <tr> 
          <td colspan="2"><strong>Civil Status</strong></td>
          <td><strong>Sex</strong></td>
          <td><strong>Remarks</strong></td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr> 
          <td>1 - Single</td>
          <td>4 - solo parent</td>
          <td>0 - Female</td>
          <td>1 - DAP</td>
          <td>5 - PESFA Scholar</td>
          <td><div align="center"><u><font size="1">____<%=WI.fillTextValue("prepared")%>____</font></u></div></td>
          <td><div align="center"><u><font size="1">____<%=WI.fillTextValue("certified")%>____</font></u></div></td>
        </tr>
        <tr> 
          <td>2 - Married</td>
          <td>5 - Separated</td>
          <td>1 - Male</td>
          <td>2 - OFW</td>
          <td>6 - TESDP - ADB Scholar</td>
          <td><div align="center"><font size="1"><%=WI.fillTextValue("designation3")%></font></div></td>
          <td><div align="center"><font size="1"><%=WI.fillTextValue("designation1")%></font></div></td>
        </tr>
        <tr> 
          <td height="18">3 - Widow / er</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>3 - Displaced Worker</td>
          <td>7 - DTS</td>
          <td colspan="2"><div align="center"><strong>Attested by: </strong></div></td>
        </tr>
        <tr> 
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>4 - With College Units or College Graduate</td>
          <td>8 - UNDP</td>
          <td colspan="2"><div align="center"><u><font size="1"><br>
              ____<%=WI.fillTextValue("attested")%>____</font></u> <br>
              <font size="1"><%=WI.fillTextValue("designation2")%></font></div></td>
        </tr>
      </table></td>
  </tr>
</table>
<%
if(bolShowPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//do not break if this is not last page.

	} // end if (i<vRetResult.size())
} //end upper for loop%>
<table width="1125" cellpadding="0" cellspacing="0">
<tr>
	<td colspan="12" class="thinborderLRB"><div align="center"><font size="1">xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</font></div></td>
</tr>
<% while (iRows < iMaxRows) { %>
<tr>
	<td width="24">&nbsp;</td>
	<td width="105" >&nbsp;</td>
    <td width="106">&nbsp;</td>
	<td width="45">&nbsp;</td>
	<td width="263">&nbsp;</td>
	<td width="116">&nbsp;</td>
	<td width="69">&nbsp;</td>
	<td width="138">&nbsp;</td>
	<td width="62">&nbsp;</td>
	<td width="53">&nbsp;</td>
	<td width="61">&nbsp;</td>
	<td width="86">&nbsp;</td>
</tr>
<%iRows++;}%>
</table>
<table width="1125" cellpadding="0" cellspacing="0" >
  <tr> 
    <td> <table width="1125" align="right" cellpadding="0" cellspacing="0" >
        <tr> 
          <td width="7%"><strong>Legends:</strong></td>
          <td width="9%">&nbsp;</td>
          <td width="11%">&nbsp;</td>
          <td width="15%">&nbsp;</td>
          <td width="15%">&nbsp;</td>
          <td width="21%"><strong>&nbsp;&nbsp; Prepared by </strong></td>
          <td width="22%"><strong>Noted by:</strong></td>
        </tr>
        <tr> 
          <td colspan="2"><strong>Civil Status</strong></td>
          <td><strong>Sex</strong></td>
          <td><strong>Remarks</strong></td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr> 
          <td>1 - Single</td>
          <td>4 - solo parent</td>
          <td>0 - Female</td>
          <td>1 - DAP</td>
          <td>5 - PESFA Scholar</td>
          <td><div align="center"><u><font size="1">____<%=WI.fillTextValue("prepared")%>____</font></u></div></td>
          <td><div align="center"><u><font size="1">____<%=WI.fillTextValue("certified")%>____</font></u></div></td>
        </tr>
        <tr> 
          <td>2 - Married</td>
          <td>5 - Separated</td>
          <td>1 - Male</td>
          <td>2 - OFW</td>
          <td>6 - TESDP - ADB Scholar</td>
          <td><div align="center"><font size="1"><%=WI.fillTextValue("designation3")%></font></div></td>
          <td><div align="center"><font size="1"><%=WI.fillTextValue("designation1")%></font></div></td>
        </tr>
        <tr> 
          <td height="25">3 - Widow / er</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>3 - Displaced Worker</td>
          <td>7 - DTS</td>
          <td colspan="2"><div align="center"><strong>Attested by: </strong></div></td>
        </tr>
        <tr> 
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>4 - With College Units or College Graduate</td>
          <td>8 - UNDP</td>
          <td colspan="2"><div align="center"><u><font size="1"><br>
              ____<%=WI.fillTextValue("attested")%>____</font></u> <br>
              <font size="1"><%=WI.fillTextValue("designation2")%></font></div></td>
        </tr>
      </table></td>
  </tr>
</table>
<script language="JavaScript">
windowwindow.print();ript>
<%} // end vRetResult != null%>
</body>
</html>
