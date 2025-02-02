<%@ page language="java" import="utility.*,enrollment.ReportRegistrar,java.util.Vector, java.util.Date" %>
<%
WebInterface WI = new WebInterface(request);
String strTemp  = WI.fillTextValue("font_size");

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strTemp%>px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strTemp%>px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strTemp%>px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strTemp%>px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strTemp%>px;
    }


-->
</style>
</head>

<body onLoad="window.print()">
<%
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strDegreeType = null;
	
	

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
	
	
	
	String[] astrConvertYr	= {"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Promotion for Graduation PRINT","rep_promo_grad_print.jsp");
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
//get the enrollment list here.


	if(WI.getStrValue(WI.fillTextValue("cc_index")).length() > 0)
		strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","cc_index",WI.fillTextValue("cc_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");

	if(WI.getStrValue(WI.fillTextValue("course_index")).length() > 0)
		strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");

		
	if(WI.getStrValue(strDegreeType).equals("1")){
		astrConvertSem[0] = "Summer";
		astrConvertSem[1] = "1st Trimester";
		astrConvertSem[2] = "2nd Trimester";
		astrConvertSem[3] = "3rd Trimester";
		astrConvertSem[4] = "4th Trimester";
		astrConvertSem[5] = "5th Trimester";
		
	}
ReportRegistrar regReport = new ReportRegistrar();
Vector vEnrlInfo = new Vector();
Vector vGWAInfo  = null;

Vector vRetResult = regReport.getPromoForGradSPC(dbOP,request);//8 subjects in one row -- change it for different no of subjects per row
if(vRetResult == null || vRetResult.size() ==0)
{
	strErrMsg = regReport.getErrMsg();
	if(strErrMsg == null)
		strErrMsg = "Promotion for graduation list not found.";
}
else {
	student.GWA gwa = new student.GWA();
	vGWAInfo = gwa.getTopStudentNew(dbOP, request);
	if(vGWAInfo == null) 
		vGWAInfo = new Vector();
}
if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0">
<tr>
	<td>
		<%=strErrMsg%>
	</td>
</tr>
</table>
<%dbOP.cleanUP();
return;
}
int iDefNoOfRowPerPg = 0;
if(request.getParameter("stud_per_pg") == null) 
	iDefNoOfRowPerPg = 12;
else	
	iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("stud_per_pg"));   

int iNoOfRowPerPg = 0;
int iStudCount = 1;
int iTemp = (vRetResult.size() - 3)/12;
int iTotalNoOfPage = iTemp / iDefNoOfRowPerPg;
if(iTemp%iDefNoOfRowPerPg > 0) ++iTotalNoOfPage;

int iPageCount = 1;

String strPgCountDisp = null;
double dTotalUnits = 0d;

boolean bolShowPageBreak = false;
String strTotalMaleFemale = (String)vRetResult.remove(0);
String strTotalMale       = (String)vRetResult.remove(0);
String strTotalFemale     = (String)vRetResult.remove(0);

int iIndexOf = 0;
String strLine1 = SchoolInformation.getAddressLine1(dbOP,false,false);
String strLine2 = SchoolInformation.getAddressLine2(dbOP,false,false);
String strLine3 = SchoolInformation.getAddressLine3(dbOP,false,false);
String strLine4 = SchoolInformation.getInfo2(dbOP,false,false);
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);

int iLineCount = 0;
//Vector vTemp = vRetResult; vTemp.removeElementAt(0);vTemp.removeElementAt(0);vTemp.removeElementAt(0);vTemp.removeElementAt(0);
while(vRetResult.size() > 0) {

	vEnrlInfo = (Vector)vRetResult.elementAt(11);
	if(vEnrlInfo.size() == 0) {
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		continue;
	}

	iNoOfRowPerPg = iDefNoOfRowPerPg;
	if(iPageCount > 1) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}
%>
<table width="1136" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"><div align="center">
        <p><strong><%=strSchoolName%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=WI.getStrValue(strLine1, "", "<br>", "&nbsp;")%>
          <!-- Pangasinan 2420 Philippines -->
          <%=WI.getStrValue(strLine2, "", "<br>", "&nbsp;")%>
          <!-- Tel Nos. (075) 532-2380; (075) 955-5054 FAX No. (075) 955-5477 -->
          <%=WI.getStrValue(strLine3, "", "<br>", "&nbsp;")%>
          <strong><!-- REGION I -->
          <%=strLine4%></strong> <br>
          <br>
     REPORT ON PROMOTION/GRADUATION</strong><br>
          <strong><%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%></strong>,
      School Year <strong><%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong>      </div></td>
  </tr>
  
  <tr>
    <td width="761">Total Enrollees: <strong><%=strTotalMaleFemale%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	Female(<%=strTotalFemale%>) : Male(<%=strTotalMale%>)</strong></td>
    <td width="224">Date Printed: <%=WI.getTodaysDate(6)%></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="4%" class="thinborder">Count</td>
    <td width="8%" height="24" class="thinborder"><div align="center">Name of Student </div></td>
    <td width="4%" class="thinborder">Course</td>
    <td width="2%" class="thinborder">Year Level </td>
<!--
    <td width="2%" class="thinborder">Age</td>
-->
	<td width="2" class="thinborder"><div align="center">Gender</div></td>
    <%for(int p = 0; p < 11; ++p) {%>	
		<td width="3%" class="thinborder"><div align="center">Subject</div></td>
		<td width="2%" class="thinborder"><div align="center">Grade</div></td>
    	<td width="2%" class="thinborder"><div align="center">Units</div></td>
	<%}%>
    	<td width="2%" class="thinborder"><div align="center">Total</div></td>
    <td width="2%" class="thinborder" align="center">WPA</td>
  </tr>
<%
while(vRetResult.size() > 0) {
	vEnrlInfo = (Vector)vRetResult.elementAt(11);
	if(vEnrlInfo.size() == 0) {
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		continue;
	}%>
  <tr>
    <td width="4%" class="thinborder"><%=++iLineCount%></td>
    <td width="8%" height="24" class="thinborder"><div align="center"><%=vRetResult.elementAt(2)%></div></td>
    <td width="4%" class="thinborder"><%=vRetResult.elementAt(3)%><%=WI.getStrValue((String)vRetResult.elementAt(4), " ","","")%></td>
    <td width="2%" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(5), "N/A")%></td>
<!--
    <td width="2%" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(8), "N/A")%></td>
-->
	<td width="2" class="thinborder"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(6), "N/A")%></div></td>
    <%
	dTotalUnits = 0d;
	for(int q = 0; q < vEnrlInfo.size(); q += 3) {
		dTotalUnits += Double.parseDouble(WI.getStrValue((String)vEnrlInfo.elementAt(q + 2), "0"));
		//System.out.println(vEnrlInfo.elementAt(q + 2));
	}
		
	for(int p = 0; p < 11; ++p) {%>	
		<td width="3%" class="thinborder"><div align="center"><%if(vEnrlInfo.size() > 0) {%><%=vEnrlInfo.remove(0)%><%}else{%>&nbsp;<%}%></div></td>
		<td width="2%" class="thinborder"><div align="center"><%if(vEnrlInfo.size() > 0) {%><%=WI.getStrValue((String)vEnrlInfo.remove(0),"&nbsp;")%><%}else{%>&nbsp;<%}%></div></div></td>
    	<td width="2%" class="thinborder"><div align="center"><%if(vEnrlInfo.size() > 0) {%><%=WI.getStrValue((String)vEnrlInfo.remove(0),"&nbsp;")%><%}else{%>&nbsp;<%}%></div></td>
	<%}%>
    	<td width="2%" class="thinborder"><div align="center"><%=CommonUtil.formatFloat(dTotalUnits,false)%></div></td>
<%
iIndexOf = vGWAInfo.indexOf(vRetResult.elementAt(1));
if(iIndexOf == -1)
	strTemp = "&nbsp;";
else {
	strTemp = (String)vGWAInfo.elementAt(iIndexOf + 3);
	vGWAInfo.remove(iIndexOf);vGWAInfo.remove(iIndexOf);vGWAInfo.remove(iIndexOf);
	vGWAInfo.remove(iIndexOf);vGWAInfo.remove(iIndexOf);
}
%>
    <td width="2%" class="thinborder" align="center"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
  </tr>
  <%
  if(vEnrlInfo.size() > 0) {--iNoOfRowPerPg;%>
	  <tr>
	    <td width="4%" class="thinborder">&nbsp;</td>
		<td width="8%" height="24" class="thinborder">&nbsp;</td>
		<td width="4%" class="thinborder">&nbsp;</td>
		<td width="2%" class="thinborder">&nbsp;</td>
		<td width="2%" class="thinborder">&nbsp;</td>
<!--
		<td width="2" class="thinborder">&nbsp;</td>
-->
		<%for(int p = 0; p < 11; ++p) {%>	
			<td width="3%" class="thinborder"><div align="center"><%if(vEnrlInfo.size() > 0) {%><%=vEnrlInfo.remove(0)%><%}else{%>&nbsp;<%}%></div></td>
			<td width="2%" class="thinborder"><div align="center"><%if(vEnrlInfo.size() > 0) {%><%=vEnrlInfo.remove(0)%><%}else{%>&nbsp;<%}%></div></div></td>
			<td width="2%" class="thinborder"><div align="center"><%if(vEnrlInfo.size() > 0) {%><%=vEnrlInfo.remove(0)%><%}else{%>&nbsp;<%}%></div></td>
		<%}%>
			<td width="2%" class="thinborder">&nbsp;</td>
		<td width="2%" class="thinborder" align="center">&nbsp;</td>
	  </tr>
  <%}%>

<%
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);

--iNoOfRowPerPg;
	if(iNoOfRowPerPg <=0)  {
		++iPageCount;
		break;
	}
}%>
  </table>
<%}//end of printing.%>

</body>
</html>
<%
dbOP.cleanUP();
%>