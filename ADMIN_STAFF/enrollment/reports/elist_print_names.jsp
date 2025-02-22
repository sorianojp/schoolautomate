<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = ""; //strSchCode = "DBTC";
if(false && strSchCode.startsWith("PWC")){%>
	<jsp:forward page="./elist_print_names_PWC.jsp" />
<%
	return;
}	
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
	
	boolean bolShowPageBreak = false;
	

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
}

	
String strDateRange = null;
if(WI.fillTextValue("enrl_date_fr").length() > 0) {
	if(WI.fillTextValue("enrl_date_to").length() > 0)
		strDateRange = "FOR DATE RANGE : "+WI.fillTextValue("enrl_date_fr")+" to " +WI.fillTextValue("enrl_date_to");
	else
		strDateRange = "FOR DATE : "+WI.fillTextValue("enrl_date_fr");
}

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

iNoOfRowPerPg = 36;
if(strSchCode.startsWith("UI"))
	iNoOfRowPerPg = 36;
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td colspan="2"><div align="center"> 
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false),",","","")%><br>
          <%=SchoolInformation.getAddressLine3(dbOP,false,false)%><br>
          <strong> <%=SchoolInformation.getInfo2(dbOP,false,false)%></strong> <br>
          <br>
          <strong>REPORT ON ENROLLMENT</strong><br>
          <strong><%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%></strong>, School Year <strong><%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong> <br>
          <%=request.getParameter("college_name")%> <br>
          <%if(WI.fillTextValue("course_name").length() >0){//for pwc. only college is selected.. %> 
		 	<%=request.getParameter("course_name")%> 
          <%}if(WI.fillTextValue("major_name").length() >0){%>
          / <%=request.getParameter("major_name")%> 
          <%}%><br>
<br>
** SUMMARY <%=WI.getStrValue(strDateRange)%>**
      </div></td>
  </tr>
  <tr valign="top"> 
    <td width="761" height="20">&nbsp;</td>
    <td width="224">&nbsp;</td>
  </tr>
</table>
<% if (vRetResult.size()> 0) {
	String strPrepPropStatus = null;
	boolean bolNewYearLevel = true;
	int iYearLevel = 1;
	
	for (int i=0; i < vRetResult.size();){  // course
		strPrevYrLevel = (String)vRetResult.elementAt(i+2);
		bolNewYearLevel = true;
		iStudCount = 1 ;
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td width="100%" height="24" class="thinborder" colspan="3"><div align="center"><font size="1">
	<%=astrConvertYr[Integer.parseInt(WI.getStrValue(strPrevYrLevel,"0"))]%></font></div></td>
  </tr>
<%
	for(; i<vRetResult.size();i+=5){// year level;
		
		if (strPrevYrLevel.compareTo((String)vRetResult.elementAt(i+2))!= 0 && !bolNewYearLevel) {	
			break;
		}
		bolNewYearLevel = false;
%>
  <tr> 
    <td height="24" class="thinborder" width="33%">&nbsp;<%=iStudCount++%>. <%=(String)vRetResult.elementAt(i+1)%> </td>
<%	if (i+5 < vRetResult.size()) { 
		i+=5; strTemp = (String)vRetResult.elementAt(i+1);
	 	if (strPrevYrLevel.compareTo((String)vRetResult.elementAt(i+2))!= 0 && !bolNewYearLevel){%>
		<td height="24" class="thinborder" width="33%">&nbsp;</td>
		<td height="24" class="thinborder" width="33%">&nbsp;</td>
		<%
		break;
		}
	}else{ 
		strTemp = null;}
%>
    <td height="24" class="thinborder" width="33%">&nbsp; <%=WI.getStrValue(strTemp,Integer.toString(iStudCount++)+".","","&nbsp;")%> </td>
<%	if (i+5 < vRetResult.size()) { 
		i+=5; strTemp = (String)vRetResult.elementAt(i+1);
	 	if (strPrevYrLevel.compareTo((String)vRetResult.elementAt(i+2))!= 0 && !bolNewYearLevel) {%>
		<td height="24" class="thinborder" width="33%">&nbsp;</td>
		<%
		break;
		}
	}else{ 
		strTemp = null;}
%>
    <td height="24" class="thinborder" width="34%">&nbsp;<%=WI.getStrValue(strTemp,Integer.toString(iStudCount++)+".","","&nbsp;")%> </td>
  </tr>
<% }// end of year level%>
</table>
<br>
<%}// end of course%>

<!-- introduce page break here -->
<DIV style="page-break-after:always">&nbsp;</DIV>
<%}//end of printing. - outer for loop.
dbOP.cleanUP();
%>

<script language="JavaScript">
	window.print();
</script>
</body>
</html>
