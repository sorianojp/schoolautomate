<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsDBTC = strSchCode.startsWith("DBTC");

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
	font-size: 10px;
    }
    .thinborderALL {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
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
	font-size: 8px;
    }

-->
</style>
</head>

<body>
<%@ page language="java" import="utility.*, java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp =  null;
	String strErrMsg = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
	String[] astrConvYrLevel = {"short-term","1st-year", "2nd-year", "3rd-year"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-TESDA Reports","terminal_report_print.jsp");
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
														"terminal_report_print.jsp");	
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

String strCourseName = "select course_name from course_offered where course_index = "+WI.fillTextValue("course_index");
strCourseName = dbOP.getResultOfAQuery(strCourseName, 0);


enrollment.GraduationDataReport gradData = new enrollment.GraduationDataReport();


Vector vRetResult = null;
Vector vSchInfo = null;
Vector vGradList = null;


vRetResult = gradData.operateOnTerminalReport(dbOP, request, 4, WI.fillTextValue("course_index"));
if(vRetResult != null && vRetResult.size() > 0)
	vSchInfo = (Vector)vRetResult.remove(0);


int  iElemCount = 0;
vGradList = gradData.operateOnTerminalReport(dbOP, request, 5, WI.fillTextValue("course_index"));
if(vGradList == null)
	strErrMsg = gradData.getErrMsg();
else
	iElemCount = gradData.getElemCount();

String strRegion = null;
String strProvince = null;
String strDistrict = null;
String strMunicipal = null;
String strAddress = null;
String strSector = null;


if(vSchInfo != null && vSchInfo.size() > 0){
	strRegion = (String)vSchInfo.elementAt(0);
	strProvince = (String)vSchInfo.elementAt(1);
	strDistrict = (String)vSchInfo.elementAt(2);
	strMunicipal = (String)vSchInfo.elementAt(7);
	strAddress = (String)vSchInfo.elementAt(6)+WI.getStrValue((String)vSchInfo.elementAt(7),", ","","");
	
	strSector = (String)vSchInfo.elementAt(8);
	if(strSector != null && strSector.equals("0"))
		strSector = "Private";
	else
		strSector = "Public";
}
String strIsEnrollment = WI.getStrValue(WI.fillTextValue("is_enrollment"), "0");
int iIndexOf = 0;
if(strErrMsg != null){
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td style="text-indent:30px;"><font color="#FF0000" size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>
<%dbOP.cleanUP(); return;}

if(vGradList != null && vGradList.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td align="center"><%=strSchoolName%><br><%=strAddress%><br><br>
		<%
		strTemp = "TERMINAL REPORT";
		if(strIsEnrollment.equals("1"))
			strTemp = "ENROLLMENT REPORT";
		%><%=strTemp%><br><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> SCHOOL YEAR <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%>
		<br><%=strCourseName%>
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
	  <td height="500" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
        <tr><%
		strTemp = "9";
		if(bolIsDBTC)
			strTemp = "8";
		%>
            <td height="22" colspan="<%=strTemp%>" align="center" class="thinborder">Students Profile</td>
            <td colspan="3" align="center" class="thinborder">Employment</td>
            </tr>
        <tr>
          <td height="22" class="thinborder" width="" align="center"><strong>Highest Educational Attainment</strong></td>
		 <%if(!bolIsDBTC){%>
          <td class="thinborder" width="8%" align="center"><strong>Scholarship</strong></td>
		 <%}%>
          <td class="thinborder" width="8%" align="center"><strong>Training Component</strong></td>
          <td class="thinborder" width="8%" align="center"><strong>Voucher Number</strong></td>
          <td class="thinborder" width="8%" align="center"><strong>Client Type</strong></td>
          <td class="thinborder" width="8%" align="center"><strong>Date Started<br>
          (mm-dd-yy)</strong></td>
          <td class="thinborder" width="8%" align="center"><strong>Date Finished<br>
          (mm-dd-yy)</strong></td>
		  <%
		  if(bolIsDBTC){
		  %>
          <td class="thinborder" width="8%" align="center"><strong>Training Result</strong></td>
		  <%}
		  if(!bolIsDBTC){
		  %>
          <td class="thinborder" width="8%" align="center"><strong>Reason for not Finishing</strong></td>
		  <%}%>
          <td class="thinborder" width="8%" align="center"><strong>Assessment Results</strong></td>
          <td class="thinborder" width="8%" align="center"><strong>Employment Date<br>
          (mm-dd-yy)</strong></td>
		  <td class="thinborder" width="8%" align="center"><strong>Name of Employer</strong></td>
		  <td class="thinborder" width="8%" align="center"><strong>Address of Employer</strong></td>
        </tr>
        <%
	for(int i = 0; i < vGradList.size(); i+=iElemCount){
	%>
        <tr>
        <%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+10);
		
		}
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+11);
		
		}
		if(!bolIsDBTC){
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%}
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+12);
		
		}
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+13);
		
		}
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+14);
		
		}
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+15);
		
		}
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+16);
		
		}
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+22);
		
		}
		if(bolIsDBTC){
		%>
		<td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%}
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+17);
		
		}
		if(!bolIsDBTC){
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%}
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+18);
		
		}
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+19);
		
		}
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+20);
		
		}
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+21);
		
		}
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
        </tr>
        <%}%>
      </table></td>
	</tr>
	<tr>
		<td>
			<%if(bolIsDBTC){%>
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="39%" height="25" valign="top">Prepared by:</td>
					<td width="35%" valign="top">Reviewed By:</td>
					<td width="26%" align="" valign="top">Certified Correct By:</td>
				</tr>
				<tr>
					<td height="25" valign="bottom" style="padding-left:30px;"><u><%=WI.getStrValue(WI.fillTextValue("prepared_by"))%></u></td>
					<td height="25" valign="bottom" style="padding-left:30px;"><u><%=WI.getStrValue(WI.fillTextValue("reviewed_by"))%></u></td>
					<td height="25" valign="bottom" align="" style="padding-left:30px;"><u><%=WI.getStrValue(WI.fillTextValue("certified"))%></u></td>
				</tr>
				<tr>
					<td valign="top" style="padding-left:30px;"><%=WI.getStrValue(WI.fillTextValue("designation1"))%></td>
					<td valign="top" style="padding-left:30px;"><%=WI.getStrValue(WI.fillTextValue("designation3"))%></td>
					<td valign="top" align="" style="padding-left:30px;"><%=WI.getStrValue(WI.fillTextValue("designation2"))%></td>
				</tr>
			</table>
			<%}else{%>
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="42%" height="25" valign="top">Prepared by:</td>
					<td width="58%" align="center" valign="top">Certified True and Correct:</td>
				</tr>
				<tr>
					<td height="25" valign="bottom"><%=WI.getStrValue(WI.fillTextValue("prepared_by"))%></td>
					<td height="25" valign="bottom" align="center"><%=WI.getStrValue(WI.fillTextValue("certified"))%></td>
				</tr>
				<tr>
					<td valign="top"><%=WI.getStrValue(WI.fillTextValue("designation1"))%></td>
					<td valign="top" align="center"><%=WI.getStrValue(WI.fillTextValue("designation2"))%></td>
				</tr>
			</table>
			<%}%>		
		</td>
	</tr>
</table>

<script>
	window.print();
</script>


<%}%>

</body>
</html>
