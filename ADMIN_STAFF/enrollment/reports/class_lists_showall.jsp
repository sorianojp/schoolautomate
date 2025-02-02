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

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<body >
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-print class list","class_lists_print.jsp");
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
Vector vClassList = null;
Vector vOfferingCollege = null;

ReportEnrollment reportEnrl= new ReportEnrollment();
	vClassList = reportEnrl.getClassList(dbOP,request);
	if(vClassList == null)
		strErrMsg = reportEnrl.getErrMsg();
if(strErrMsg == null)
{
	vOfferingCollege = reportEnrl.getCollegeDeptOffering(dbOP,request.getParameter("course_index"));
	if(vOfferingCollege == null)
		strErrMsg = reportEnrl.getErrMsg();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCGH    = strSchCode.startsWith("CGH");
boolean bolIsFATIMA = strSchCode.startsWith("FATIMA");


String strSubCode = request.getParameter("subject_name");
String strSubUnit = null;
if(WI.fillTextValue("subject").length() > 0) {
	strTemp    = "select lec_unit + lab_unit from curriculum where is_valid = 1 and sub_index = "+WI.fillTextValue("subject");
	strSubUnit = dbOP.getResultOfAQuery(strTemp, 0);
}

//dbOP.cleanUP();//clean up here.
if(strErrMsg != null){dbOP.cleanUP();
%>
<table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%}else{
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
%>
<%//heading is repeading.. else move this to line number
boolean bolShowPageBreak = false;

int iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("no_of_stud"));
int iStudPrinted = 0;
int iTotalStud = Integer.parseInt( (String)vClassList.elementAt(0));
int iStudCount = 1;
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud %iNoOfStudPerPage > 0)
	++iTotalPageCount;

int iPageCount = 1;
String strDispPageNo = null;
for(int i=1; i<vClassList.size();){
strDispPageNo = Integer.toString(iPageCount)+" of "+Integer.toString(iTotalPageCount);
++iPageCount;
iStudPrinted = 0;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
<%if(bolIsCGH){%>
		  <br>
		  <%=SchoolInformation.getAddressLine3(dbOP,false,false)%><br>
		  <%=SchoolInformation.getInfo2(dbOP,false,false)%>
<%}%>
		  </div></td>
    </tr>
    <tr>
      <td height="30"><div align="center">
	  	<%if(!bolIsCGH){%><%=(String)vOfferingCollege.elementAt(0)%><%}%><br>
        <%=WI.getStrValue((String)vOfferingCollege.elementAt(1),"","<br>","")%>
        <strong><%if(!bolIsCGH){%>CLASS LIST<br><%}%>
        </strong><%=astrConvertSem[Integer.parseInt(request.getParameter("offering_sem"))]%>, SY
		<%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>
<%if(bolIsCGH){%><br>Course/Program : Bachelor of Science in Nursing<br>Year Level : 1 <br><%}%>
		</div></td>
    </tr>
</table>
<%if(!bolIsCGH){%>
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr >
    <td height="10" colspan="2" ><div align="center">
        <hr size="1">
      </div></td>
  </tr>
  <tr >
    <td width="42%" height="10" >Subject code : <%=strSubCode%>
	<%if(WI.fillTextValue("nstp_val").length() > 0) {%>
			- <%=WI.fillTextValue("nstp_val")%>
	<%}%>
    </td>
    <td width="58%">Descriptive Title : <%=request.getParameter("subject_desc")%>
    </td>
  </tr>
  <tr >
    <td colspan="2" height="10" ><hr size="1"></td>
  </tr>
  <tr >
    <td height="25" valign="top">Subject Unit  :
	<%
		strTemp = "select lec_unit + lab_unit from curriculum where is_valid = 1 and sub_index = "+
			WI.fillTextValue("subject");
	%>
	<%=dbOP.getResultOfAQuery(strTemp, 0)%>
	</td>
    <td height="25" valign="top"><%if(bolIsCGH){%>Year Level : 1 &nbsp;&nbsp;
	Course/Program : Bachelor of Science in Nursing<%}%></td>
  </tr>
  <tr >
    <td height="20"  colspan="2" bgcolor="#DBD8C8"><div align="center"><strong>LIST
        OF STUDENTS OFFICIALLY ENROLLED
        <%if(WI.fillTextValue("show_not_validated").compareTo("1") == 0){%>
        NOT VALIDATED
        <%}%>
        </strong></div></td>
  </tr>
</table>
<%}//show only if not cgh..



if(WI.fillTextValue("show_not_validated").length() == 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC" class="thinborder">
  <tr>
    <td width="3%" rowspan="2" align="center" class="thinborder"><strong>SL #</strong></td>
    <td width="20%" height="27" rowspan="2" align="center" class="thinborder"><strong>Student ID </strong></td>
    <td height="20" colspan="3" align="center" class="thinborder"><strong>Student Name </strong></td>
<%if(!bolIsCGH){%>
    <td width="12%" rowspan="2" align="center" class="thinborder"><strong>Course Code  </strong></td>
    <td width="15%" rowspan="2" align="center" class="thinborder"><strong>Major</strong></td>
    <td width="6%" rowspan="2" align="center" class="thinborder"><strong>Year Level </strong></td>
<%}%>
    <td width="7%" rowspan="2" align="center" class="thinborder"><strong>Gender</strong></td>
<%if(!bolIsCGH){%>
    <td width="7%" rowspan="2" align="center" class="thinborder"><strong>Section</strong></td>
    <%}else{%>
    <td width="7%" rowspan="2" align="center" class="thinborder"><b>Subject Enrolled</b></td>
    <td width="7%" rowspan="2" align="center" class="thinborder"><b>No. of Units</b></td>
    <%}%>
  </tr>
      <td width="12%" align="center" class="thinborder"><strong>Last Name </strong></td>
    <td width="15%" align="center" class="thinborder"><strong>First Name </strong></td>
    <td width="<%if(bolIsCGH){%>10<%}else{%>4<%}%>%" align="center" class="thinborder"><strong><%if(bolIsCGH){%>Middle Name<%}else{%>MI<%}%></strong></td>
  </tr>
  <%
int iIndexOf; String strSectionName = null;
for(;i<vClassList.size();){
	if(iStudPrinted++ == iNoOfStudPerPage) {
		bolShowPageBreak = true;
		break;
	}
	else {
		bolShowPageBreak = false;
	}
	if(bolIsFATIMA) {
		if(strSectionName != null && !strSectionName.equals((String)vClassList.elementAt(i+8))) {
			bolShowPageBreak = true;
			iStudCount = 1;
			break;
		}
	}
	strSectionName = (String)vClassList.elementAt(i+8);

	
	strTemp = WI.getStrValue(vClassList.elementAt(i+3)," ");
	
	if(strTemp.length() > 1 ) {
		iIndexOf = strTemp.indexOf(" ",1);
		if(iIndexOf > -1 && strTemp.length() > (iIndexOf + 1) )
			strTemp = String.valueOf(strTemp.charAt(0))+"."+strTemp.charAt(iIndexOf + 1);
		else	
			strTemp = String.valueOf(strTemp.charAt(0));
	}
%>
  <tr>
    <td class="thinborder"<%if(bolIsCGH){%> align="center"<%}%>><%=iStudCount++%></td>
    <td height="25" align="center" class="thinborder"><%=(String)vClassList.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vClassList.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vClassList.elementAt(i+2)%></td>
    <td <%if(!bolIsCGH){%>align="center"<%}%> class="thinborder">&nbsp;<%if(bolIsCGH){%><%=WI.getStrValue(vClassList.elementAt(i+3),"&nbsp;")%><%}else{%><%=strTemp%><%}%></td>
<%if(!bolIsCGH){%>
    <td class="thinborder"><%=(String)vClassList.elementAt(i+4)%></td>
    <td class="thinborder"><%=WI.getStrValue(vClassList.elementAt(i+5),"&nbsp;")%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue(vClassList.elementAt(i+6),"N/A")%></td>
<%}%>
    <td align="center" class="thinborder"><%=(String)vClassList.elementAt(i+7)%></td>
<%if(!bolIsCGH){%>
    <td class="thinborder"><%=(String)vClassList.elementAt(i+8)%></td>
<%}else{%>
    <td class="thinborder" align="center"><%=strSubCode%></td>
    <td class="thinborder" align="center">3</td>
<%}%>
  </tr>
  <%
i = i+9;
}%>
</table>
<%}else{//show the students not confirmed.%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
    <td width="14%" rowspan="2" align="center" class="thinborder"><strong>DATE
      OF ENROLLMENT</strong></td>
    <td width="14%" height="27" rowspan="2" align="center" class="thinborder"><strong>STUDENT
      ID</strong></td>
    <td height="27" colspan="3" align="center" class="thinborder"><strong>STUDENT
      NAME</strong></td>
    <td width="14%" rowspan="2" align="center" class="thinborder"><strong>COURSE
      CODE </strong></td>
    <td width="14%" rowspan="2" align="center" class="thinborder"><strong>MAJOR</strong></td>
    <td width="7%" rowspan="2" align="center" class="thinborder"><strong>YR</strong></td>
    <td width="7%" rowspan="2" align="center" class="thinborder"><strong>GEN</strong></td>
  </tr>
  <tr>
    <td width="17%" align="center" class="thinborder"><strong>LASTNAME</strong></td>
    <td width="16%" align="center" class="thinborder"><strong>FIRSTNAME</strong></td>
    <td width="5%" align="center" class="thinborder"><strong>MI</strong></td>
  </tr>
  <%
for(;i<vClassList.size();){
if(iStudPrinted++ == iNoOfStudPerPage) {
	bolShowPageBreak = true;
	break;
}
else
	bolShowPageBreak = false;
%>
  <tr>
    <td align="center" class="thinborder"><%=(String)vClassList.elementAt(i + 8)%></td>
    <td height="25" class="thinborder"><div align="center"><%=(String)vClassList.elementAt(i)%></div></td>
    <td class="thinborder"><%=(String)vClassList.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vClassList.elementAt(i+2)%></td>
    <td class="thinborder"><div align="center">&nbsp;<%=WI.getStrValue(vClassList.elementAt(i+3)," ").charAt(0)%>&nbsp;</div></td>
    <td class="thinborder"><%=(String)vClassList.elementAt(i+4)%></td>
    <td class="thinborder"><%=WI.getStrValue(vClassList.elementAt(i+5),"&nbsp;")%></td>
    <td class="thinborder"><div align="center"><%=WI.getStrValue(vClassList.elementAt(i+6),"N/A")%></div></td>
    <td class="thinborder"><div align="center"><%=(String)vClassList.elementAt(i+7)%></div></td>
  </tr>
  <%
i = i+9;
}%>
</table>
<%}%>
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="76%" valign="top">Certified Correct by : <br>
      <br>
	<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7))%><br>
	<!--&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-->Registrar<br>
	<%=WI.getTodaysDate(6)%>

	</td>
    <td width="24%" valign="top align="right"><%if(!bolIsFATIMA){%>page <strong><%=strDispPageNo%></strong><%}%></td>
  </tr>
 
</table>
<!-- introduce page break here -->
<% if(bolShowPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//do not print for last page.

}%>


<script language="JavaScript">
	window.print();
</script>
<%} // only if there is no error
%>


</body>
</html>
<%
dbOP.cleanUP();
%>
