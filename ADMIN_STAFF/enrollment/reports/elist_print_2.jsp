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
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
	border: 1px solid #000000;
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

	String strSchCode = null;//for UI , do not show remarks.


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
Vector vRetResult = enrlReport.getEnrollmentList(dbOP,request,1,false);//8 subjects in one row -- change it for different no of subjects per row
Vector vAddlInfo = null;

if(vRetResult == null || vRetResult.size() ==0)
{
	strErrMsg = enrlReport.getErrMsg();
	if(strErrMsg == null)
		strErrMsg = "Enrollment list not found.";
}
else {
	if(WI.fillTextValue("form_19").length() > 0) 
		vAddlInfo = (Vector)vRetResult.remove(0);
}

//System.out.println(vRetResult);
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

int iRequiredRows = 0;
int iAvailableRows = 70;  // includes the name, space, subject  per row
int iDefaultAvailableRows = 70;
int i = 4;  // starting point of vRetResult (0-3 totals)
int iStudCount = 1;
int iCountSubj = 1;
boolean bolShowPageBreak = false; // do not show page break if it is last page.


	for (; i<vRetResult.size();){
		iAvailableRows = iDefaultAvailableRows;
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%"><div align="center">
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false),",","","")%><br>
          <%=SchoolInformation.getAddressLine3(dbOP,false,false)%> <br>
          <strong> <%=SchoolInformation.getInfo2(dbOP,false,false)%></strong> <br>
          <br>
          <strong>REPORT ON ENROLMENT </strong><br>
          <strong><%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>, A.Y. :</strong><strong> <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong> <br>
          <strong><%=request.getParameter("course_name")%>
          <%if(WI.fillTextValue("major_name").length() >0){%>
          / <%=request.getParameter("major_name")%>
          <%}%>
          <br>
          Year level : <strong><%=astrConvertYr[Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"),"0"))]%></strong> </strong> </div></td>
  </tr>
   <tr>
    <td  height="24" colspan="2"><hr size="1"></td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="3" cellspacing="0">
  <tr valign="top">
    <td width="50%" > <%
	for (; i<vRetResult.size();) {
		vEnrlInfo = (Vector)vRetResult.elementAt(i++);

	iCountSubj = 1 ;

	if (vEnrlInfo != null && vEnrlInfo.size () != 0){
		iRequiredRows = 1 + (vEnrlInfo.size()-4 )/2;

		if (iRequiredRows < iAvailableRows) {
			iAvailableRows -= iRequiredRows;
%>

	<%=iStudCount++%>. <%=(String)vEnrlInfo.elementAt(1)%>  <br>
	  <table width="90%" align="center" cellpadding="0" cellspacing="0" class="thinborder">
		<%for(int k =4; k < vEnrlInfo.size(); k+=2) {%>
        <tr>
          <td width="75%" class="thinborder"><%=iCountSubj++%>. <%=(String)vEnrlInfo.elementAt(k)%></td>
          <td width="25%" class="thinborder"><%=(String)vEnrlInfo.elementAt(k+1)%></td>
        </tr>
		<%} --iAvailableRows;//end for loop k%>
      </table><br>
	  <%bolShowPageBreak = false;
          	}else{ i--; bolShowPageBreak = true; break; } // // if iRequireRows > AvailableRows
            } // vEnrlInfo !=null
	  } // upper for loop %>
	 </td>


    <td width="50%" > <%
 	iAvailableRows = iDefaultAvailableRows;
	for (; i<vRetResult.size();) {
	vEnrlInfo = (Vector)vRetResult.elementAt(i++);
	iCountSubj = 1;

	if (vEnrlInfo != null && vEnrlInfo.size () != 0){

		iRequiredRows = 1 + (vEnrlInfo.size()-4 )/2;
		if (iRequiredRows < iAvailableRows) {
			iAvailableRows -= iRequiredRows;
%>

	<%=iStudCount++%>. <%=(String)vEnrlInfo.elementAt(1)%>  <br>
	  <table width="90%" align="center" cellpadding="0" cellspacing="0" class="thinborder">
		<% for(int k =4; k < vEnrlInfo.size(); k+=2) {%>
        <tr>
          <td width="75%" class="thinborder"><%=iCountSubj++%>. <%=(String)vEnrlInfo.elementAt(k)%></td>
          <td width="25%" class="thinborder"><%=(String)vEnrlInfo.elementAt(k+1)%></td>
        </tr>
		<%} --iAvailableRows;bolShowPageBreak = false;//end for loop k%>
      </table><br>
	  <%; }else{i--; bolShowPageBreak = true;break; } // // if iRequireRows > AvailableRows
	  } // vEnrlInfo !=null
	  } // upper for loop %>
	 </td>
  </tr>
</table>
<%if(bolShowPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break only if it is not last page.

} // end vRetResult == null

dbOP.cleanUP();
%>

<script language="JavaScript">
	window.print();
</script>
</body>
</html>
