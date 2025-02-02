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

int iElemCount = 0;
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
<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage()">
	<tr>
		<td height="500" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
	    <td height="22" colspan="2" align="center" class="thinborder">Program Profile</td>
	    <td colspan="5" align="center" class="thinborder">Students Profile</td>
	    </tr>
	<tr>
		<td height="22" class="thinborder" width="22%" align="center"><strong>Industry Sector of Qualification</strong></td>
		<td class="thinborder" width="16%" align="center"><strong>Others, Please specify</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>Student ID Number</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>Family/Last Name</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>First Name</strong></td>
		<td class="thinborder" width="5%" align="center"><strong>MI</strong></td>
		<td class="thinborder" width="12%" align="center"><strong>Contact No.</strong></td>		
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
				strTemp = (String)vRetResult.elementAt(iIndexOf+7);
		
		}
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0){
			iIndexOf = vRetResult.indexOf(vGradList.elementAt(i));
			if(iIndexOf > -1)
				strTemp = (String)vRetResult.elementAt(iIndexOf+8);
		
		}
		%>
		<td class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>		
		<td align="center" class="thinborder" height="22">&nbsp;<%=WI.getStrValue((String)vGradList.elementAt(i+2))%></td>		
		<td align="center" class="thinborder" height="22">&nbsp;<%=WI.getStrValue((String)vGradList.elementAt(i+5))%></td>		
		<td align="center" class="thinborder" height="22">&nbsp;<%=WI.getStrValue((String)vGradList.elementAt(i+3))%></td>
		<%
		strTemp = (String)vGradList.elementAt(i+4);
		if(strTemp != null)
			strTemp = strTemp.substring(0,1);
		%>		
		<td align="center" class="thinborder" height="22">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<td align="center" class="thinborder" height="22">&nbsp;<%=WI.getStrValue((String)vGradList.elementAt(i+6))%></td>
	</tr>
	
	<%}%>
</table>
		</td>
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

<script>
function PrintNextPage() {	
	if(!confirm("Click Ok to print next page and Cancel to stay in this page."))
		return;	
	location = "./terminal_report_print_page4.jsp?sy_from="+<%=WI.fillTextValue("sy_from")%>+
	"&sy_to="+<%=WI.fillTextValue("sy_to")%>+
	"&semester="+<%=WI.fillTextValue("semester")%>+
	"&course_index="+<%=WI.fillTextValue("course_index")%>+
	"&prepared_by="+<%=WI.getInsertValueForDB(WI.fillTextValue("prepared_by"),true,null)%>+
	"&certified="+<%=WI.getInsertValueForDB(WI.fillTextValue("certified"),true,null)%>+
	"&is_enrollment="+<%=strIsEnrollment%>+
	"&designation1="+<%=WI.getInsertValueForDB(WI.fillTextValue("designation1"),true,null)%>+
	"&designation2="+<%=WI.getInsertValueForDB(WI.fillTextValue("designation2"),true,null)%>+
	"&reviewed_by="+<%=WI.getInsertValueForDB(WI.fillTextValue("reviewed_by"),true,null)%>+
	"&designation3="+<%=WI.getInsertValueForDB(WI.fillTextValue("designation3"),true,null)%>+"";
	
		
}
</script>
<%}%>

</body>
</html>
