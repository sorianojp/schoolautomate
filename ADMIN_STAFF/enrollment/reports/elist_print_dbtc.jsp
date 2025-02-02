<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

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

	String[] astrConvertSem = {"Summer","1","2","3"};
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
int iNoOfSubPerRow = 6;
boolean bolShowPageBreak = false;


boolean bolShowID = true; 
request.setAttribute("ShowAllYr","1");

Vector vRetResult = enrlReport.getEnrollmentList(dbOP,request,iNoOfSubPerRow,true);//8 subjects in one row -- change it for different no of subjects per row
String strCourseCode  = null;//course being printed.. 


if(vRetResult == null || vRetResult.size() ==0) {
	strErrMsg = enrlReport.getErrMsg();

	if(strErrMsg == null)
		strErrMsg = "Enrollment list not found.";
}
else {
	strCourseCode = "select course_code from course_offered where course_index = "+WI.fillTextValue("course_index");
	strCourseCode = dbOP.getResultOfAQuery(strCourseCode, 0);
	if(WI.fillTextValue("major_index").length() > 0) {
		String strSQLQuery = "select course_code from major where major_index = "+WI.fillTextValue("major_index");
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null)
			strCourseCode = strCourseCode + "-"+strSQLQuery;
	}
}

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

int iStudCount = 1;
int iTemp = Integer.parseInt((String)vRetResult.elementAt(0));//total no of rows.
//iTemp is not correct -- i have to run a for loop to find number of rows.

int iTotalNoOfPage = iTemp / iNoOfRowPerPg;
if(iTemp%iNoOfRowPerPg > 0) ++iTotalNoOfPage;

/////////////////// compute here number of pages. //////////////////////
/**
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

**/



/////////////////// end of computation for total # of pages. ///////////


//System.out.println(vRetResult);

int iPageCount = 1;
String strUserIndex = null;
String strPgCountDisp = null;
for(int i=4; i<vRetResult.size();){
//iNoOfRowPerPg = 18;

iNoOfRowPerPg = iDefNoOfRowPerPg;

strPgCountDisp = "Page count : "+Integer.toString(iPageCount++) +" of "+Integer.toString(iTotalNoOfPage);

String strTableWidth ="width=1136";
%>
	<table width=100% border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="20%" height="20">Name of Institution: </td>
		<td colspan="2" style="font-weight:bold">DON BOSCO TECHNOLOGY CENTER</td>
	</tr>
	<tr>
		<td height="20">Address:</td>
		<td colspan="2" style="font-weight:bold">Punta Princesa, Cebu City</td>
	</tr>
	<tr>
		<td height="20">Institutional Identifier:</td>
		<td width="47%" style="font-weight:bold">07089</td>
	    <td width="33%">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">School Year: </td>
		<td colspan="2" style="font-weight:bold"><%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="5%" height="24" class="thinborderSP" align="center">SL. No</td>
    <td width="12%" class="thinborderSP"><div align="center">Student No </div></td>
    <td width="10%" class="thinborderSP" align="center">Surname</td>
    <td width="10%" class="thinborderSP"><div align="center">First Name</div></td>
    <td width="10%" class="thinborderSP" align="center">Middle Name</td>
    <td width="5%" class="thinborderSP"><div align="center">Gender</div></td>
    <td width="5%" class="thinborderSP" align="center">Semester</td>
    <td width="5%" class="thinborderSP" align="center">Year</td>
    <td width="5%" class="thinborderSP" align="center">Course</td>
    <td width="30%" class="thinborderSP"><div align="center">Subject(s) Enrolled</div></td>
    <td width="5%" class="thinborderSP"><div align="center">No. of Units</div></td>
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
    <td class="thinborder"><%=(String)vEnrlInfo.elementAt(0)%></td>
    <td class="thinborder"><%=(String)vEnrlInfo.elementAt(6)%></td>
    <td class="thinborder"><%=(String)vEnrlInfo.elementAt(4)%></td>
    <td class="thinborder"><%=(String)vEnrlInfo.elementAt(5)%></td>
    <td align="center" class="thinborder"><%=(String)vEnrlInfo.elementAt(2)%></td>
    <td align="center" class="thinborder"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%></td>
    <td align="center" class="thinborder"><%if(vEnrlInfo.elementAt(3).equals("N/A")){%>N/A<%}else{%><%=astrConvertYr[Integer.parseInt((String)vEnrlInfo.elementAt(3))]%><%}%></td> 
    <td align="center" class="thinborder"><%=strCourseCode%></td>
    <td class="thinborder">
	<%//print all subjects enrolled.
	vEnrlInfo.removeElementAt(0);vEnrlInfo.removeElementAt(0);vEnrlInfo.removeElementAt(0);vEnrlInfo.removeElementAt(0);vEnrlInfo.removeElementAt(0);
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
	<%=strTemp%>	</td>
    <td align="center" class="thinborder"><%=fUnitEnrolled%></td>
  </tr>
  <%
 }//end of print per page.%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
	<td width="50%">Certified correct by:<br>&nbsp;
	  <div align="center">
____________________________<br>
<%=CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)%><br>
Registrar</div>
</td>
	<td width="50%" align="right"><%=strPgCountDisp%> </td>
  </tr>
</table>

<!-- introduce page break here -->
<%if(bolShowPageBreak){%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}//break only if it is not last page.
}//end of printing. - outer for loop.%>

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
