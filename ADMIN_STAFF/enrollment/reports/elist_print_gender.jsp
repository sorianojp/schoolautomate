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

<body>
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strCollegeName = null;
	String strCollegeIndex = null;
	String strTemp = null;
	
	String strSchCode = null;//for UI , do not show remarks.
	

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
	String[] astrConvertYr	= {"Year level : N/A","FIRST YEAR","SECOND YEAR","THIRD YEAR","FOURTH YAER","FIFTH YEAR","6th Year","7th Year"};

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
Vector vRetResult = enrlReport.getEnrollmentList(dbOP,request,"1");//8 subjects in one row -- change it for different no of subjects per row
if(vRetResult == null || vRetResult.size() ==0)
{
	strErrMsg = enrlReport.getErrMsg();
	if(strErrMsg == null)
		strErrMsg = "Enrollment list not found.";
}//vRetResult.addElement(vRetResult);System.out.println(" I M here.");

strSchCode = dbOP.getSchoolIndex();

//dbOP.cleanUP();
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

int iNoOfRowPerPg = 16;
if(strSchCode.startsWith("UI"))
	iNoOfRowPerPg = 18;
	
String strUserIndex = null;
String strPgCountDisp = null;
int iStudCount =1;
String strCurrentYearLevel  = null;
String strPrevYrLevel = null;
String strCurrentGender= null;
String strPrevGender = null;

iNoOfRowPerPg = 36;
if(strSchCode.startsWith("UI"))
	iNoOfRowPerPg = 36;
	
	String strPrepPropStatus = null;
	boolean bolNewYearLevel = true;
	int iYearLevel = 1;


for ( int i=0 ; i < vRetResult.size();){

	strCurrentGender = (String)vRetResult.elementAt(i+4);
	strPrevYrLevel = (String)vRetResult.elementAt(i+2);
	bolNewYearLevel = true;
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td colspan="2"><div align="center"> 
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%><br>
          <%=SchoolInformation.getAddressLine3(dbOP,false,false)%><br>
          <strong> <%=SchoolInformation.getInfo2(dbOP,false,false)%></strong> <br>
          <br>
          <strong>REPORT ON ENROLLMENT</strong><br>
          <strong><%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%></strong>, School Year <strong><%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong> <br>
          <%=request.getParameter("college_name")%> <br>
          <%=request.getParameter("course_name")%> 
          <%if(WI.fillTextValue("major_name").length() >0){%>
          / <%=request.getParameter("major_name")%> 
          <%}%><br> <br>
**SUMMARY**
      </div></td>
  </tr>
  <tr valign="top"> 
    <td height="20">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>

<table width="80%%" border="0" align="center" cellpadding="0" cellspacing="0" >
  <tr> 
    <td width="80%" height="24" colspan="2"><div align="center"><font size="1"> 
        <strong><font size="2"><%=astrConvertYr[Integer.parseInt(WI.getStrValue(strPrevYrLevel,"0"))]%></font></strong></font></div></td>
  </tr>
  <tr> 
    <td width="50%" height="24" ><div align="center"><font size="2"> <strong>MALE</strong></font></div></td>
    <td width="50%" height="24" ><div align="center"><font size="2"> <strong>FEMALE</strong></font></div></td>
  </tr>
  <tr align="top" valign="top"> 
    <td width="50%"  > 
	<%  
		iStudCount = 1;
		for(; i<vRetResult.size();i+=5){ // all male here
		if (strPrevYrLevel.compareTo((String)vRetResult.elementAt(i+2))!= 0 && !bolNewYearLevel) {	
			break;
		}
		if (((String)vRetResult.elementAt(i+4)).compareTo("M") != 0 ){	
			bolNewYearLevel = false;
			break;
		}
		bolNewYearLevel = false;
	%> <%=iStudCount++%>. <%=((String)vRetResult.elementAt(i+1)).toUpperCase()%><br>
	<%} //end for loop male %>
      &nbsp; </td>
    <td width="50%"  > <% if (!bolNewYearLevel){
		iStudCount = 1;
   		for(; i<vRetResult.size();i+=5){ // all female here
			if (strPrevYrLevel.compareTo((String)vRetResult.elementAt(i+2))!= 0) {	
				break;
			}
			if (((String)vRetResult.elementAt(i+4)).compareTo("F") != 0 ){	
				break;
		}
	%> <%=iStudCount++%>. <%=((String)vRetResult.elementAt(i+1)).toUpperCase()%> <br><%} //end female 
	 } //end if (!bolNewYearLevel) (FEMALE)
	%>
      &nbsp; </td>
  </tr>
</table>
<!-- introduce page break here -->
<%//if(bolShowPageBreak){
%>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%//}//do not call page break if this is last page.

}//end of printing. - outer for loop.
dbOP.cleanUP();
%>

<script language="JavaScript">
	window.print();
</script>
</body>
</html>
