<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strSchCode = null;//for UI , do not show remarks.
	//for CLDH, show total enrolled unit instead of remark.
	strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5 = (String)request.getSession(false).getAttribute("info5");
	boolean bolIsUPHD = false;
	if(strSchCode.equals("UPH") &&  strInfo5 == null) {
		bolIsUPHD = true;
		strSchCode = "CGH";
	}
	if(strSchCode == null)
		strSchCode = "";

	String strOrigSchCode = strSchCode;
	
//	if(strSchCode.startsWith("DBTC"))
		//strSchCode = "UDMC";
		
	if(strSchCode.startsWith("WUP")){%>
		<jsp:forward page="./elist_print_WUP.jsp"/>
	<%}
	if(strSchCode.startsWith("DBTC")){%>
		<jsp:forward page="./elist_print_dbtc.jsp"/>
	<%
	return;}	
	if(strSchCode.startsWith("CSA")){%>
		<jsp:forward page="./elist_print_CSA.jsp"/>
	<%
	return;}	
	if(strSchCode.startsWith("UL") || strSchCode.startsWith("CDD")){%>
		<jsp:forward page="./elist_print_UL.jsp"/>
	<%
	return;}	
		
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
	font-size: <%=WI.fillTextValue("font_size")%>px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
}
/**
<%if(WI.fillTextValue("show_border").compareTo("1") ==0){%>
**/
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.thinborderSP {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
/**
<%}else{%>
**/
    TD.thinborderSP {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
/**
<%}%>
**/
    TABLE.jumboborder {
    border-top: solid 2px #000000;
    border-bottom: solid 2px #000000;
    border-left: solid 2px #000000;
    border-right: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderRIGHT {
    border-right: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderTOP {
    border-top: solid 2px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderTOPex {
    /**border-top: solid 1px #000000;**/
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.jumboborderTOPONLY {
    border-top: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }


-->
</style>
</head>

<body topmargin="0" bottommargin="0" onLoad="window.print();">
<%
	String strErrMsg = null;String strTemp = null;
	String strCollegeName = null;
	String strCollegeIndex = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
	String[] astrConvertYr	= {"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-Enrollment list print","elist_print.jsp");
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
ReportEnrollment enrlReport = new ReportEnrollment();
Vector vEnrlInfo = new Vector();
boolean bolSeparateName = false;
int iNoOfSubPerRow = 6;
boolean bolShowPageBreak = false;

String strOrigSchooCode = strSchCode;

//strSchCode = "VMUF";
boolean bolShowID = false; 

boolean bolIsForm19 = false; Vector avAddlInfo = null;
//strSchCode  = "AUF";
	
if(strSchCode.startsWith("AUF") || strSchCode.startsWith("UDMC") || strSchCode.startsWith("WNU")) {
	bolShowID = true;
	if(WI.fillTextValue("form_19").equals("1")) {
		bolIsForm19 = true;
		iNoOfSubPerRow = 4;
		strSchCode  = "AUF";
	}

	request.setAttribute("ShowAllYr","1");
}

if(strSchCode.startsWith("AUF") && WI.fillTextValue("course_index").length() > 0) {
	strTemp = "select degree_type from course_offered where course_index = "+WI.fillTextValue("course_index");
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null && strTemp.equals("1")) {
		astrConvertSem[1] = "1st Trimester";
		astrConvertSem[2] = "2nd Trimester";
		astrConvertSem[3] = "3rd Trimester";
	}

}

if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC")) {
	bolSeparateName = true;
	iNoOfSubPerRow = 20;
}
Vector vAddressUL = null;
int iIndexOf = 0;
String strAddress = null;

Vector vRetResult = enrlReport.getEnrollmentList(dbOP,request,iNoOfSubPerRow,bolSeparateName);//8 subjects in one row -- change it for different no of subjects per row
	//System.out.println(vRetResult);
if(vRetResult == null || vRetResult.size() ==0) {
	strErrMsg = enrlReport.getErrMsg();

	if(strErrMsg == null)
		strErrMsg = "Enrollment list not found.";
}
else if(bolIsForm19)
	avAddlInfo = (Vector)vRetResult.remove(0);

//System.out.println(avAddlInfo);
if(strSchCode.startsWith("UL")) {
	vAddressUL = enrlReport.getStudentAddressUL(dbOP, request);
}
	
	if(vAddressUL == null)
		vAddressUL = new Vector();

//I have to now check if it is called to view only male or female - applicable for UDMC.
strTemp = WI.fillTextValue("gender_x");
if(strTemp.length() > 0 && vRetResult != null && vRetResult.size() > 0) {//filter gender
	for(int i = 4; i < vRetResult.size();) {
		vEnrlInfo = (Vector)vRetResult.elementAt(i);
		//System.out.println(vEnrlInfo.elementAt(2));
		if(!strTemp.equals(vEnrlInfo.elementAt(2)))
			vRetResult.removeElementAt(i);
		else
			++i;
	}
}
//System.out.println(vRetResult.size());


//dbOP.cleanUP();
if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0">
<tr>
	<td>
		<font size="4"><%=strErrMsg%></font>
	</td>
</tr>
</table>
<%dbOP.cleanUP();
return;
}

int iDefNoOfRowPerPg = 0;
if(request.getParameter("stud_per_pg") == null)
	iDefNoOfRowPerPg = 18;
else
	iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("stud_per_pg"));

int iNoOfRowPerPg = iDefNoOfRowPerPg;
//if(strSchCode.startsWith("UI") || strSchCode.startsWith("LNU") )
//	iNoOfRowPerPg = 20;

int iStudCount = 1;
int iTemp = Integer.parseInt((String)vRetResult.elementAt(3));//total no of rows.
//iTemp is not correct -- i have to run a for loop to find number of rows.

int iTotalNoOfPage = iTemp / iNoOfRowPerPg;
if(iTemp%iNoOfRowPerPg > 0) ++iTotalNoOfPage;

/////////////////// compute here number of pages. //////////////////////
int iTempPageNo = 1;
for(int i=4; i<vRetResult.size();){
	iNoOfRowPerPg = iDefNoOfRowPerPg;
	for(; i<vRetResult.size();++i){// this is for page wise display.
		vEnrlInfo = (Vector)vRetResult.elementAt(i);
		if(iNoOfRowPerPg <= 0) {
			++iTempPageNo;
			break;
		}
		if(iNoOfSubPerRow == 20) {
			--iNoOfRowPerPg;
			continue;
		}
		for(int k=4; k<vEnrlInfo.size();){
			//if( k > 0) k -= 4;
			--iNoOfRowPerPg;
			k += iNoOfSubPerRow * 2; // only 6 rows or 4 rows(for AUF)
		}
	}
}

if(iTempPageNo != iTotalNoOfPage)
	iTotalNoOfPage = iTempPageNo;





/////////////////// end of computation for total # of pages. ///////////




int iPageCount = 1;
String strUserIndex = null;
String strPgCountDisp = null;
for(int i=4; i<vRetResult.size();){
//iNoOfRowPerPg = 18;
//if(strSchCode.startsWith("UI") || strSchCode.startsWith("LNU") )
//	iNoOfRowPerPg = 20;
iNoOfRowPerPg = iDefNoOfRowPerPg;

strPgCountDisp = "Page count : "+Integer.toString(iPageCount++) +" of "+Integer.toString(iTotalNoOfPage);

String strTableWidth = null;
if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC"))
	strTableWidth = "width=100%";
else
	strTableWidth = "width=1136";

if(bolIsUPHD) {%>
<table width=100% border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="20%" height="20">Name Of Institution: </td>
		<td style="font-weight:bold">UNIVERSITY OF PERPETUAL HELP SYSTEM DALTA </td>
	    <td style="font-weight:bold">Tel. No. <b>871 0639 </b></td>
	</tr>
	<tr>
		<td height="20">Address:</td>
		<td colspan="2" style="font-weight:bold">ALABANG-ZAPOTE ROAD, PAMPLONA LAS PINAS </td>
	</tr>
	<tr>
		<td height="20">Sem/Tri: </td>
		<td colspan="2" style="font-weight:bold"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, SY<%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></td>
	</tr>
	<tr>
		<td height="20">Institutional Identifier:</td>
		<td width="56%" style="font-weight:bold">13136</td>
	    <td width="24%">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">Course/Program:</td>
		<td colspan="2" style="font-weight:bold">
		<%=request.getParameter("course_name")%>
	<%if(WI.fillTextValue("major_name").length() >0){%>Major in <%=request.getParameter("major_name")%><%}%>		</td>
	</tr>
	<tr>
		<td height="20">Year Level:</td>
		<td colspan="2" style="font-weight:bold"><%=astrConvertYr[Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"),"0"))]%></td>
	</tr>
</table>

<%}else if(strOrigSchCode.startsWith("DBTC")){%>
	<table width=100% border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="20%" height="20">Name Of Institution: </td>
		<td colspan="2" style="font-weight:bold">DON BOSCO TECHNOLOGY CENTER</td>
	</tr>
	<tr>
		<td height="20">Address:</td>
		<td colspan="2" style="font-weight:bold">Punta Princesa, Cebu City</td>
	</tr>
	<tr>
		<td height="20">Institutional Identifier:</td>
		<td width="47%" style="font-weight:bold">07089</td>
	    <td width="33%">Tel. No. &nbsp;&nbsp;&nbsp;<b>272-2910</b></td>
	</tr>
	<tr>
		<td height="20">Sem/Tri: </td>
		<td colspan="2" style="font-weight:bold"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, Academic Year <strong><%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></td>
	</tr>
	<tr>
		<td height="20">Course/Program:</td>
		<td colspan="2" style="font-weight:bold">
		<%=request.getParameter("course_name")%>
	<%if(WI.fillTextValue("major_name").length() >0){%>Major in <%=request.getParameter("major_name")%><%}%>		</td>
	</tr>
	<tr>
		<td height="20">Year Level:</td>
		<td colspan="2" style="font-weight:bold"><%=astrConvertYr[Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"),"0"))]%></td>
	</tr>
</table>
<%}else if(strOrigSchCode.startsWith("UL")){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="3"><div align="center">
        <p><strong>REPORT ON ENROLMENT LIST</strong><br>
		<%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>
		<%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>		</p></div></td>
  </tr>
  <tr valign="top">
    <td width="33%" height="20"><%=request.getParameter("college_name").toUpperCase()%></td>
    <td width="33%">&nbsp;</td>
    <td width="33%">Year level : <%=astrConvertYr[Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"),"0"))]%></td>
  </tr>
  <tr valign="top">
    <td height="20">School: University of Luzon </td>
    <td colspan="2">Course: <%=request.getParameter("course_name")%>
	<%if(WI.fillTextValue("major_name").length() >0){%>
	 / <%=request.getParameter("major_name")%>
    <%}%></td>
    </tr>
  <tr valign="top">
    <td height="20">Address: Dagupan City <strong>
	
	 </strong></td>
    <td>Tel.No: 522-8295 </td>
    <td>Region: 1 </td>
  </tr>
</table>
<%}else{%>
	<table <%=strTableWidth%> border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"><div align="center">
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false), ",","")%>
          <!-- Pangasinan 2420 Philippines -->
          <br>
          <!-- Tel Nos. (075) 532-2380; (075) 955-5054 FAX No. (075) 955-5477 -->
          <%=WI.getStrValue(SchoolInformation.getAddressLine3(dbOP,false,false),"","<br>","")%>
          <strong><!-- REGION I -->
          <%=WI.getStrValue(SchoolInformation.getInfo2(dbOP,false,false),"","<br>","")%></strong> <br>
          <strong><%if(bolIsForm19){%>
          REPORT ON COLLEGIATE GRADES &amp; CREDITS EARNED
          <%}else if(WI.fillTextValue("sub_code_").length() > 0){%><%=WI.fillTextValue("sub_code_")%> LIST<%}else{%>ENROLMENT LIST<%}%>
		  <%if(strSchCode.startsWith("UDMC")){%>As of Date <%=WI.getTodaysDate(10)%><%}%>
		  </strong><br>
          <%=request.getParameter("college_name")%><br>
          <strong>
<%
strTemp = request.getParameter("semester");
if(WI.fillTextValue("show_2nd_sem").length() > 0)
	strTemp = "2";
%>		  <%=astrConvertSem[Integer.parseInt(strTemp)]%></strong>, Academic Year <strong><%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong> </div></td>
  </tr>
<%
if(strTableWidth.endsWith("%")) {
	strTableWidth = "width=70%";
	strTemp = " align=right";
}
else {
	strTableWidth = "width=761";
	strTemp = "";
}
%>
  <tr valign="top">
    <td <%=strTableWidth%> height="20">Course / Major : <strong>
	<%=request.getParameter("course_name")%>
	<%if(WI.fillTextValue("major_name").length() >0){%>
	 / <%=request.getParameter("major_name")%>
	 <%}%>
	 </strong></td>
    <td<%=strTemp%>>&nbsp;
	<%if(!bolShowID || strSchCode.startsWith("UDMC")){%>Year level : <strong><%=astrConvertYr[Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"),"0"))]%></strong><%}%></td>
  </tr>
  <tr>
    <td>Total Enrolees: <strong><%=(String)vRetResult.elementAt(0)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	Female(<%=(String)vRetResult.elementAt(2)%>) : Male(<%=(String)vRetResult.elementAt(1)%>)</strong></td>
    <td align="right"><%if(WI.fillTextValue("section_name").length() > 0) {%>Section : <strong><%=WI.fillTextValue("section_name")%></strong><%}%></td>
  </tr>
</table>
<%}
if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC")){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="5%" height="24" class="thinborderSP" align="center">Sl. No</td>
    <td width="15%" class="thinborderSP"><div align="center">Student ID</div></td>
    <td width="10%" class="thinborderSP" align="center">Last Name</td>
    <td width="10%" class="thinborderSP"><div align="center">First Name</div></td>
    <td width="10%" class="thinborderSP" align="center">Middle Name</td>
    <td width="5%" class="thinborderSP"><div align="center">Gender</div></td>
    <td width="40%" class="thinborderSP"><div align="center">Subject(s) Enrolled</div></td>
    <td width="5%" class="thinborderSP"><div align="center">Total Unit</div></td>
  </tr>
  <%//bolShowID = true;
float fUnitEnrolled = 0f;

for(; i<vRetResult.size();++i){// this is for page wise display.
	vEnrlInfo = (Vector)vRetResult.elementAt(i);
	//System.out.println(vEnrlInfo);
if(iNoOfRowPerPg <= 0) {
	bolShowPageBreak = true;
	break;
}
	--iNoOfRowPerPg;
	bolShowPageBreak = false;
	fUnitEnrolled = 0f;

%>
  <tr>
    <td height="21" class="thinborder"><%=iStudCount++%>.</td>
    <td class="thinborder"><%=(String)vEnrlInfo.remove(0)%></td>
    <td class="thinborder"><%=(String)vEnrlInfo.remove(5)%></td>
    <td class="thinborder"><%=(String)vEnrlInfo.remove(3)%></td>
    <td class="thinborder"><%=(String)vEnrlInfo.remove(3)%></td>
    <td align="center" class="thinborder"><%=(String)vEnrlInfo.remove(1)%></td>
    <td class="thinborder">
	<%//print all subjects enrolled.
	vEnrlInfo.removeElementAt(0);vEnrlInfo.removeElementAt(0);//now i have combination of sub code and units in list.
	fUnitEnrolled = 0f;
	strTemp = null;
	for(int k=0; k < vEnrlInfo.size() ; k+= 2){//only sub and units enrolled.
		if(strTemp == null)
			strTemp = (String)vEnrlInfo.elementAt(k);
		else
			strTemp = strTemp +", "+(String)vEnrlInfo.elementAt(k);
		fUnitEnrolled += Float.parseFloat(WI.getStrValue(vEnrlInfo.elementAt(k + 1), "0"));
	}%>
	<%=strTemp%>
	</td>
    <td align="center" class="thinborder"><%=fUnitEnrolled%></td>
  </tr>
  <%
 }//end of print per page.%>
</table>
<%}else{//chinese gen is having differnt format.%>
<table width="1136" border="0" cellpadding="0" cellspacing="0" class="jumboborder">
  <tr>
    <td width="5" height="24" class="jumboborderRIGHT">EL NO.</td>
    <%if(bolShowID){%>
	<td width="85" class="jumboborderRIGHT">STUDENT NO.</td>
	<%}%>
    <td width="239" class="jumboborderRIGHT">NAME OF STUDENT</td>
    <%if(bolShowID){%>
    <td width="5" class="jumboborderRIGHT" align="center">YEAR</td>
	<%}%>
    <td width="45" class="jumboborderRIGHT"><div align="center">GENDER</div></td>
<!-- 6th line -->
    <td width="82" class="jumboborderRIGHT">SUBJECT</td>
<%if(bolIsForm19){%><td width="40" class="jumboborderRIGHT">GRADE</td><%}%>
    <td width="34" class="jumboborderRIGHT"><div align="center">UNITS</div></td>
    <td width="85" class="jumboborderRIGHT">SUBJECT</td>
<%if(bolIsForm19){%><td width="40" class="jumboborderRIGHT">GRADE</td><%}%>
    <td width="34" class="jumboborderRIGHT"><div align="center">UNITS</div></td>
    <td width="85" class="jumboborderRIGHT">SUBJECT</td>
<%if(bolIsForm19){%><td width="40" class="jumboborderRIGHT">GRADE</td><%}%>
    <td width="34" class="jumboborderRIGHT"><div align="center">UNITS</div></td>
    <td width="85" class="jumboborderRIGHT">SUBJECT</td>
<%if(bolIsForm19){%><td width="40" class="jumboborderRIGHT">GRADE</td><%}%>
    <td width="34" class="jumboborderRIGHT"><div align="center">UNITS</div></td>
<%///added for AUF - they want to show only 4 subjects.
if(!bolIsForm19){%>
    <td width="85" class="jumboborderRIGHT">SUBJECT</td>
<%if(bolIsForm19){%><td width="40" class="jumboborderRIGHT">GRADE</td><%}%>
    <td width="34" class="jumboborderRIGHT"><div align="center">UNITS</div></td>
    <td width="85" class="jumboborderRIGHT">SUBJECT</td>
<%if(bolIsForm19){%><td width="40" class="jumboborderRIGHT">GRADE</td><%}%>
    <td width="34" class="jumboborderRIGHT"><div align="center">UNITS</div></td>
<%}///end of showing 4 subjects.%>
    <!-- removing 4 rows of subjects = saving 200px
    <td width="60" class="thinborder"><div align="center">SUBJECT</div></td>
    <td width="40" class="thinborder"><div align="center">UNITS</div></td>
    <td width="60" class="thinborder"><div align="center">SUBJECT</div></td>
    <td width="40" class="thinborder"><div align="center">UNITS</div></td>
-->
<%if(true && !strSchCode.startsWith("UL")){//for AUF form 19, show REMARKS.. %>
    <td width="46" align="center">
	<%if(!bolIsForm19 &&
		(strSchCode.startsWith("CLDH") || strSchCode.startsWith("AUF") || strSchCode.startsWith("VMUF") || strSchCode.startsWith("WNU") || strSchCode.startsWith("UC")) ){%>
      TOTAL UNITS
      <%}else{if(bolIsForm19){//put image for AUF%><img src="./Remarks_AUF_F19.jpg"><%}else{%>REMARKS<%}}%></td>
<%}%>
  </tr>
<%
float fUnitEnrolled = 0f; String strUnit = null; String strGrade = null;
int iTotCol = iNoOfSubPerRow * 2;// = 12
int iTotColPlus = iTotCol + 4;///= 16,  4 = number of elements before subject+unit info =
//Vector -> [0]=id [1] =name,[2]=gender,[3]=course regularity -- one time. =>repeat =>[4]=sub_code,[5]=unit

for(; i<vRetResult.size();++i){// this is for page wise display.
	vEnrlInfo = (Vector)vRetResult.elementAt(i);
	//System.out.println("Printing ID NUmber : "+vEnrlInfo.elementAt(0));
	//System.out.println("Name : "+vEnrlInfo.elementAt(1));
	//System.out.println(" vEnrlInfo  = "+vEnrlInfo);
	
	//check here if address is already set.
	iIndexOf = vAddressUL.indexOf(vEnrlInfo.elementAt(0));
	if(iIndexOf > -1)
		strAddress = (String)vAddressUL.elementAt(iIndexOf + 1);//System.out.println("Address : "+strAddress);
	
if(iNoOfRowPerPg <= 0) {
	bolShowPageBreak = true;
	break;
}
	bolShowPageBreak = false;
	fUnitEnrolled = 0f;
	String strClass = null;
	//System.out.println("What are you?: "+vEnrlInfo.size());
	for(int k=5; k<vEnrlInfo.size(); k += 2)
		fUnitEnrolled += Float.parseFloat(WI.getStrValue(vEnrlInfo.elementAt(k), "0"));

	for(int k=0; k<vEnrlInfo.size();k += 4){
	if( k > 0) k -= 4;
	--iNoOfRowPerPg;
	%>
  <tr>
  <%if (k==0)
  	strClass = "jumboborderTOP";
  	else
  	strClass = "jumboborderTOPex";
  %>
<!-- 1st line -->
    <% if(k == 0 && vEnrlInfo.size()>iTotColPlus){%>
    <td height="21" class="<%=strClass%>" rowspan="2">  <%=iStudCount++%>.</td>
    <%} else if (k==0 && vEnrlInfo.size()<=iTotColPlus){%><td height="21" class="<%=strClass%>"><%=iStudCount++%>.</td>
	<%} else if (k > iTotCol && vEnrlInfo.size()>iTotColPlus){%>
    	<td class="<%=strClass%>" height="21">&nbsp;</td>
		<td class="<%=strClass%>" height="21">&nbsp;</td>
    	<td class="<%=strClass%>" height="21">&nbsp;</td>
    	<%if(bolShowID){%>
			<td class="<%=strClass%>" height="21">&nbsp;</td>
			<td class="<%=strClass%>" height="21">&nbsp;</td>
		<%}%>
	<%}%>

<!-- 2nd line -->
    <% if(k == 0 && vEnrlInfo.size()>iTotColPlus){%>
    <%if(bolShowID){%><td class="<%=strClass%>" height="21" rowspan="2"><%=WI.getStrValue(vEnrlInfo.elementAt(k), "&nbsp;")%></td><%}%>
    <%} else if (k==0 && vEnrlInfo.size()<=iTotColPlus){%>
    <%if(bolShowID){%><td class="<%=strClass%>" height="21"><%=(String)vEnrlInfo.elementAt(k)%></td><%}}%>
<!-- 3rd line -->
    <% if(k == 0 && vEnrlInfo.size()>iTotColPlus){%>
    <td height="21" class="<%=strClass%>" rowspan="2"> <%=(String)vEnrlInfo.elementAt(k+1)%><%=WI.getStrValue(strAddress, "<br>","","")%></td>
    <%} else if (k==0 && vEnrlInfo.size()<=iTotColPlus){%>
    <td height="21" class="<%=strClass%>"> <%=WI.getStrValue(vEnrlInfo.elementAt(k+1), "&nbsp;")%><%=WI.getStrValue(strAddress, "<br>","","")%></td><%}%>

<!-- 4th line -->
    <% if(k == 0 && vEnrlInfo.size()>iTotColPlus){%>
    <%if(bolShowID){%><td class="<%=strClass%>" align="center" height="21" rowspan="2"><%=(String)vEnrlInfo.elementAt(k + 3)%></td><%}%>
    <%} else if (k==0 && vEnrlInfo.size()<=iTotColPlus){%>
    <%if(bolShowID){%><td class="<%=strClass%>" align="center" height="21" ><%=(String)vEnrlInfo.elementAt(k + 3)%></td><%}}%>

<!-- 5th line -->
    <% if(k == 0 && vEnrlInfo.size()>iTotColPlus){%>
    <td align="center" class="<%=strClass%>" rowspan="2"><%=(String)vEnrlInfo.elementAt(k+2)%></td>
    <%} else if (k==0 && vEnrlInfo.size()<=iTotColPlus){%>
    <td align="center" class="<%=strClass%>"><%=(String)vEnrlInfo.elementAt(k+2)%></td><%}%>

<!-- 6th line(subject) -->
<%
strUnit = (String)vEnrlInfo.elementAt(k+5);
if(bolIsForm19 && avAddlInfo != null && avAddlInfo.size() > 0)
	strUnit = enrlReport.getUnitForAUFForm19(strUnit, (String)avAddlInfo.elementAt(0),strOrigSchooCode);
%>
    <td class="<%=strClass%>"><%=(String)vEnrlInfo.elementAt(k+4)%></td>
<%if(bolIsForm19){%><td width="40" class="<%=strClass%>">&nbsp;
			<%if(avAddlInfo != null && avAddlInfo.size() > 0 ) {%>
				<%=WI.getStrValue((String)avAddlInfo.remove(0))%><%}%></td><%}%>
<!-- 7th line(unit) -->
    <td align="center" class="<%=strClass%>"><%=WI.getStrValue(strUnit, "&nbsp;")%></td>
<!-- 8th line(subject) -->
<%
if( (k+6) < vEnrlInfo.size()) {
	strUnit = (String)vEnrlInfo.elementAt(k+7);
	if(bolIsForm19 && avAddlInfo != null && avAddlInfo.size() > 0)
		strUnit = enrlReport.getUnitForAUFForm19(strUnit, (String)avAddlInfo.elementAt(0),strOrigSchooCode);
}
%>

    <td class="<%=strClass%>"> <%if( (k+6) < vEnrlInfo.size()){%> <%=(String)vEnrlInfo.elementAt(k+6)%> <%}else{%> &nbsp; <%}%> </td>
<%if(bolIsForm19){%><td width="40" class="<%=strClass%>">&nbsp;
			<%if(avAddlInfo != null && avAddlInfo.size() > 0 && (k+6) < vEnrlInfo.size() ) {%>
				<%=WI.getStrValue((String)avAddlInfo.remove(0))%><%}%></td><%}%>
<!-- 9th line (unit)-->
    <td align="center" class="<%=strClass%>"> <%if( (k+6) < vEnrlInfo.size()){%> <%=strUnit%> <%}else{%> &nbsp; <%}%> </td>
<!-- 10th line (subject)-->
<%
if( (k+8) < vEnrlInfo.size()) {
	strUnit = (String)vEnrlInfo.elementAt(k+9);
	if(bolIsForm19 && avAddlInfo != null && avAddlInfo.size() > 0)
		strUnit = enrlReport.getUnitForAUFForm19(strUnit, (String)avAddlInfo.elementAt(0),strOrigSchooCode);
}
%>
    <td class="<%=strClass%>"> <%if( (k+8) < vEnrlInfo.size()){%> <%=(String)vEnrlInfo.elementAt(k+8)%> <%}else{%> &nbsp; <%}%> </td>
<%if(bolIsForm19){%><td width="40" class="<%=strClass%>">&nbsp;
			<%if(avAddlInfo != null && avAddlInfo.size() > 0 && (k+8) < vEnrlInfo.size() ) {%>
				<%=WI.getStrValue((String)avAddlInfo.remove(0))%><%}%></td><%}%>
<!-- 11th line (unit)-->
    <td align="center" class="<%=strClass%>"> <%if( (k+8) < vEnrlInfo.size()){%> <%=WI.getStrValue(strUnit,"&nbsp;")%> <%}else{%> &nbsp; <%}%> </td>
<!-- 12th line (subject-->
<%
if( (k+10) < vEnrlInfo.size()) {
	strUnit = (String)vEnrlInfo.elementAt(k+11);
	if(bolIsForm19 && avAddlInfo != null && avAddlInfo.size() > 0)
		strUnit = enrlReport.getUnitForAUFForm19(strUnit, (String)avAddlInfo.elementAt(0),strOrigSchooCode);
}
%>    <td class="<%=strClass%>"> <%if( (k+10) < vEnrlInfo.size()){%> <%=(String)vEnrlInfo.elementAt(k+10)%> <%}else{%> &nbsp; <%}%> </td>
<%if(bolIsForm19){%><td width="40" class="<%=strClass%>">&nbsp;
			<%if(avAddlInfo != null && avAddlInfo.size() > 0 && (k+10) < vEnrlInfo.size() ) {%>
				<%=WI.getStrValue((String)avAddlInfo.remove(0))%><%}%></td><%}%>
<!-- 13th line (unit)-->
    <td align="center" class="<%=strClass%>"> <%if( (k+10) < vEnrlInfo.size()){%> <%=strUnit%> <%}else{%> &nbsp; <%}%> </td>
<!-- 14th line (subject)-->
<%//do not show below if it is called for form 19 - AUF
	///added for AUF - they want to show only 4 subjects.
if(!bolIsForm19){%>

    <td class="<%=strClass%>"> <%if( (k+12) < vEnrlInfo.size()){%> <%=(String)vEnrlInfo.elementAt(k+12)%> <%}else{%> &nbsp; <%}%> </td>
<%if(bolIsForm19){%><td width="40" class="<%=strClass%>">&nbsp;
			<%if(avAddlInfo != null && avAddlInfo.size() > 0 && (k+12) < vEnrlInfo.size() ) {%>
				<%=WI.getStrValue((String)avAddlInfo.remove(0))%><%}%></td><%}%>
<!-- 15th line (unit)-->
    <td align="center" class="<%=strClass%>"> <%if( (k+13) < vEnrlInfo.size()){%> <%=(String)vEnrlInfo.elementAt(k+13)%> <%}else{%> &nbsp; <%}%> </td>
<!-- 16th line (subject)-->
    <td class="<%=strClass%>"> <%if( (k+14) < vEnrlInfo.size()){%> <%=(String)vEnrlInfo.elementAt(k+14)%> <%}else{%> &nbsp; <%}%> </td>
<%if(bolIsForm19){%><td width="40" class="<%=strClass%>">&nbsp;
			<%if(avAddlInfo != null && avAddlInfo.size() > 0 && (k+14) < vEnrlInfo.size() ) {%>
				<%=WI.getStrValue((String)avAddlInfo.remove(0))%><%}%></td><%}%>
<!-- 17th line (unit)-->
    <td align="center" class="<%=strClass%>"> <%if( (k+14) < vEnrlInfo.size()){%> <%=(String)vEnrlInfo.elementAt(k+15)%> <%}else{%> &nbsp; <%}%> </td>

<%}//do not show for AUF form 19%>

    <!--    <td class="thinborder">
      <%if( (k+16) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+16)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td align="center" class="thinborder">
      <%if( (k+16) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+17)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td class="thinborder">
      <%if( (k+18) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+18)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td align="center" class="thinborder">
      <%if( (k+18) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+19)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
-->
<%if(true  && !strSchCode.startsWith("UL")){
	//it is the right most. for one line, class is jumboborderTOPONLY. else no class.
	if(k == 0)
		strClass = "class=jumboborderTOPONLY";
	else
		strClass = "";%>
    <td align="center" <%=strClass%>>
	<% if(!bolIsForm19 && k ==0 && (strSchCode.startsWith("CLDH") || strSchCode.startsWith("AUF") || strSchCode.startsWith("VMUF") || strSchCode.startsWith("WNU") || strSchCode.startsWith("UC")) ){%>
	<%=fUnitEnrolled%>
	<%}else if(!bolIsForm19 && k ==0 && !strSchCode.startsWith("UI") ){%>
	<%=(String)vEnrlInfo.elementAt(k+3)%>
	<%}else{%> &nbsp; <%}%> </td>
<%}%>
  </tr>
  <%
k += iNoOfSubPerRow * 2; // only 6 rows or 4 rows(for AUF)
}//end of printing rows.

 }//end of print per page.%>
</table>
<%}//end of dispay enrollment list other than chinese gen/udmc
if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC")){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(strSchCode.startsWith("CGH")){%>
  <tr>
	<td>&nbsp;</td>
	<td align="right"><%=strPgCountDisp%></td>
  </tr>
<%}else {//print registrar name.%>
  <tr>
	<td><%=strPgCountDisp%></td>
	<td align="right"><br>
	____________________________<br>
	Minda O. Gnilo &nbsp;&nbsp;&nbsp;  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <br>
	Registrar&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </td>
  </tr>
<%}%>
</table>
<%}else{//for other schools.%>
<table width="1136" border="0" cellspacing="0" cellpadding="0">
  <tr valign="top">
    <td height="15" valign="bottom"><%if(strSchCode.startsWith("VMUF")) {%>Example Abbreviation:<%}%>
	<%if(strSchCode.startsWith("AUF")){//print registrar name.
	if(bolIsForm19){%>
	<font face="Arial, Helvetica, sans-serif" style="font-size:9px;">
	AUF-Form-RO-19<br>
	August 1, 2007-Rev.0
	</font>
	<!--	<img src="../../registrar/reports/OTR/image/auf_ro_<%if(bolIsForm19){%>19<%}else{%>05<%}%>.jpg">-->
	<%}else{%>
	<font face="Arial, Helvetica, sans-serif" style="font-size:9px;">
	AUF-Form-RO-05<br>
	August 1, 2007-Rev.0
	</font>
	<%}%>
	
	<%}%>
&nbsp;
	
	</td>
	<td width="461" align="right"><%=strPgCountDisp%></td>
  </tr>
<%if(strSchCode.startsWith("VMUF")){%>
  <tr>
    <td width="675">&nbsp;&nbsp;&nbsp;&nbsp;Engl 101 - English 1 : Math 101 - Mathematics 1: Fil 101 -
      FIlipino 1 </td>
    <td>&nbsp;</td>
  </tr>
<%}%>
</table>
<%}//if not UDMC/CGH%>

<!-- introduce page break here -->
<%if(bolShowPageBreak){%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}//break only if it is not last page.

}//end of printing. - outer for loop.

if(strSchCode.startsWith("PHILCST")){//print registrar name.%>
<div align="right"><br><table cellpadding="0" cellspacing="0"><tr>
	<td align="center">
	______________________________<br>
	  Mrs. Gina Elena F. Gironella <br>
	  Registrar	</td>
	<td align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
</tr></table>
</div>
<%}
else if(strSchCode.startsWith("CLDH")){//print registrar name.%>
<div align="right"><br><table cellpadding="0" cellspacing="0"><tr><td align="center">
_________________________________<br>
  EDNA C. SALVADOR <br>
  Registrar
</td></tr></table></div>
<%}
else if(strSchCode.startsWith("CGH")){//print registrar name.%>
<div align="left">
  <table cellpadding="0" cellspacing="0">
    <tr>
      <td width="172" valign="top"> Certified Correct by: </td>
      <td width="259" align="left">&nbsp;<br>
	  <%=CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)%><br>
	  <font size="1"> Registrar<br>
	  <%=WI.getTodaysDate(1)%></font>
	  </td>
    </tr>
  </table>
</div>
<%}%>
<%if (true){%>
<script language="JavaScript">
alert("Total no of pages to print : <%=iTotalNoOfPage%>");
//window.print();
</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
