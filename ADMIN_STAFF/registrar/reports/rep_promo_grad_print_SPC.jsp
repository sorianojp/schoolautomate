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
int iDefNoOfRowPerPg = Integer.parseInt(WI.getStrValue(WI.fillTextValue("stud_per_pg"),"12"));   

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

boolean bolShowSubj = false;
int iCount = 0;
//Vector vTemp = vRetResult; vTemp.removeElementAt(0);vTemp.removeElementAt(0);vTemp.removeElementAt(0);vTemp.removeElementAt(0);
while(vRetResult.size() > 0) {

	/*if(!bolShowSubj || vEnrlInfo.size() == 0){
		vEnrlInfo = (Vector)vRetResult.elementAt(11);
		if(vEnrlInfo.size() == 0) {
			vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
			vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
			continue;
		}	
	}*/

	iNoOfRowPerPg = iDefNoOfRowPerPg;
	if(iPageCount > 1) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}
	
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td colspan="2" align="center">REPORT ON PROMOTION/GRADUATION<br>
			SCHOOL YEAR <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>
		</td>
	</tr>
	<tr><td colspan="2" height="25">&nbsp;</td></tr>
  <tr>
    <td colspan="2"><div align="center">
        <p><%=strSchoolName%><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=WI.getStrValue(strLine1, "", "<br>", "&nbsp;")%>
         <!-- REGION I -->
          <%=strLine4%> <br><br>          
          <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>,
      School Year <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>      </div></td>
  </tr>
  
  <!--<tr>
    <td>Total Enrollees: <strong><%=strTotalMaleFemale%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	Female(<%=strTotalFemale%>) : Male(<%=strTotalMale%>)</strong></td>
    <td>Date Printed: <%=WI.getTodaysDate(6)%></td>
  </tr>-->
</table>
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">

  <tr>
      <td width="4%" class="thinborder">&nbsp;</td>
    <td width="32%" height="24" class="thinborder"><div align="center"><strong>Student Name</strong></div></td>
    <td width="16%" class="thinborder"><strong>Course</strong></td>
    <td width="6%" class="thinborder"><strong>YrLevel</strong> </td>
		
	<td width="18%" class="thinborder"><div align="center"><strong>Subject</strong></div></td>
	<td width="6%" class="thinborder"><div align="center"><strong>Grade</strong></div></td>
   	<td width="6%" class="thinborder"><div align="center"><strong>Units</strong></div></td>
	
   	<td width="6%" class="thinborder"><div align="center"><strong>Total</strong></div></td>
    <td width="6%" class="thinborder" align="center"><strong>WPA</strong></td>
  </tr>
<%


while(vRetResult.size() > 0) {

if(!bolShowSubj || vEnrlInfo.size() == 0){
	vEnrlInfo = (Vector)vRetResult.elementAt(11);
	if(vEnrlInfo.size() == 0) {
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		continue;
	}
	--iNoOfRowPerPg;
	%>
  <tr>
      <td width="4%" class="thinborder"><%=++iCount%></td>
    <td width="32%" height="24" class="thinborder"><div><%=vRetResult.elementAt(2)%></div></td>
    <td width="16%" class="thinborder"><%=vRetResult.elementAt(3)%><%=WI.getStrValue((String)vRetResult.elementAt(4), " ","","")%></td>
    <td width="6%" class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(5), "N/A")%></td>
<!--
    <td width="2%" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(8), "N/A")%></td>
-->
	<%
	dTotalUnits = 0d;
	for(int q = 0; q < vEnrlInfo.size(); q += 3) {
		dTotalUnits += Double.parseDouble(WI.getStrValue((String)vEnrlInfo.elementAt(q + 2), "0"));
		//System.out.println(vEnrlInfo.elementAt(q + 2));
	}
		%>
	
		<td width="18%" class="thinborder"><div align="center">
			<%if(vEnrlInfo.size() > 0) {%><%=WI.getStrValue((String)vEnrlInfo.remove(0),"&nbsp;")%><%}else{%>&nbsp;<%}%></div></td>
		<td width="6%" class="thinborder"><div align="center">
			<%if(vEnrlInfo.size() > 0) {%><%=WI.getStrValue((String)vEnrlInfo.remove(0),"&nbsp;")%><%}else{%>&nbsp;<%}%></div></div></td>
    	<td width="6%" class="thinborder"><div align="center">
			<%if(vEnrlInfo.size() > 0) {%><%=WI.getStrValue((String)vEnrlInfo.remove(0),"&nbsp;")%><%}else{%>&nbsp;<%}%></div></td>
	
    	<td width="6%" class="thinborder"><div align="center"><%=CommonUtil.formatFloat(dTotalUnits,false)%></div></td>
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
    <td width="6%" class="thinborder" align="center"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
  </tr>
  <%
}//end of bolShowSubj == false
  while(vEnrlInfo.size() > 0) {--iNoOfRowPerPg;
  	bolShowSubj = false;
  %>
	  <tr>
	      <td width="4%" class="thinborder">&nbsp;</td>
		<td width="32%" height="24" class="thinborder">&nbsp;</td>
		<td width="16%" class="thinborder">&nbsp;</td>
		<td width="6%" class="thinborder">&nbsp;</td>
		
			
		<td width="18%" class="thinborder"><div align="center">
			<%if(vEnrlInfo.size() > 0) {%><%=WI.getStrValue((String)vEnrlInfo.remove(0),"&nbsp;")%><%}else{%>&nbsp;<%}%></div></td>
		<td width="6%" class="thinborder"><div align="center">
			<%if(vEnrlInfo.size() > 0) {%><%=WI.getStrValue((String)vEnrlInfo.remove(0),"&nbsp;")%><%}else{%>&nbsp;<%}%></div></div></td>
		<td width="6%" class="thinborder"><div align="center">
			<%if(vEnrlInfo.size() > 0) {%><%=WI.getStrValue((String)vEnrlInfo.remove(0),"&nbsp;")%><%}else{%>&nbsp;<%}%></div></td>
		
		<td width="6%" class="thinborder">&nbsp;</td>
		<td width="6%" class="thinborder" align="center">&nbsp;</td>
	  </tr>
  <%
  	if(iNoOfRowPerPg <= 0)  {
		bolShowSubj = true;
		//++iPageCount;
		break;
	}  
  }//end of while loop for subject - grade - units
  
  if(!bolShowSubj){  		
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	}


	if(iNoOfRowPerPg <=0 || bolShowSubj)  {
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