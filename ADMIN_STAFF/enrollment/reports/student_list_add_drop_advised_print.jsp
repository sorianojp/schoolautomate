<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<style type="text/css">
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

TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
}

TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}




</style>

<body>
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS","student_list_add_drop_advised.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"student_list_add_drop_advised.jsp");
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

//end of authenticaion code.

int iRowsPerPg = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iRowsPrinted = 0;

String strDateTimePrinted = WI.formatDateTime(null, 5);
int iPageNo = 0;

ReportEnrollment reportEnrl = new ReportEnrollment();

Vector vRetResult    = null;
Vector vDropHistList = new Vector();
if(WI.fillTextValue("show_list").length() > 0){
	vRetResult = reportEnrl.getStudAddDropAdvised(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();
	else
		vDropHistList = (Vector)vRetResult.remove(0);
}


if(vRetResult != null && vRetResult.size() > 0){

String strCCode = null;
String strPrevCCode = "";
String strEnrollIndex = null;

String strDroppedBy = null;
String strDroppedDate = null;
int iIndexOf = 0;
String[] astrSubStatus = {"Regular", "Added", "Dropped"}; 

boolean bolPageBreak = false;
for(int i = 0; i < vRetResult.size();){
	if(bolPageBreak){
		bolPageBreak = false;
%>	
	<div style="page-break-after:always;">&nbsp;</div>
	<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">	
	<tr><td align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
	<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
	</strong></td></tr>
	<%
	if(WI.fillTextValue("show").equals("0"))
		strTemp = " ARE ADVISED";
	if(WI.fillTextValue("show").equals("1"))
		strTemp = " ADDED SUBJECT(S)";
	if(WI.fillTextValue("show").equals("2"))
		strTemp = " DROPPED SUBJECT(S)";
	%>
	<tr><td height="20" align="center" class="thinborderNONE"><strong>LIST OF STUDENTS WHO<%=strTemp%></strong></td></tr>
	<%if(WI.fillTextValue("c_index").length() > 0){
		strTemp = dbOP.mapOneToOther("college", "c_index", WI.fillTextValue("c_index"), "c_Code", " and is_del = 0");
	%>
	<tr><td height="20" align="center">
		<strong>PER COLLEGE <%if(WI.fillTextValue("course_index").length() > 0){%> AND COURSE <%}%> : <%=WI.getStrValue(strTemp)%>
		<%if(WI.fillTextValue("course_index").length() > 0){
			strTemp = dbOP.mapOneToOther("course_offered", "course_index", WI.fillTextValue("course_index"), "course_code", " and is_del = 0");
		%><%=WI.getStrValue(strTemp," - ","","")%><%}%>
		</strong>
	</td></tr>
	<%}%>
	
	<tr><td>&nbsp;</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="70%" style="font-size:9px;">Date Printed: <%=strDateTimePrinted%></td>
		<td width="30%" style="font-size:9px;" align="right">Page #: <%=++iPageNo%></td>
	</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="11%" height="22" class="thinborder"><strong>ID Number</strong></td>
		<td width="18%" class="thinborder"><strong>Student Name</strong></td>
		<td width="12%" class="thinborder"><strong>Course and Year Level</strong></td>
		<td width="12%" class="thinborder"><strong>Advised By</strong></td>
		<td width="13%" class="thinborder"><strong>Advised Date</strong></td>
		<td width="7%" class="thinborder"><strong>Subject Code</strong></td>
		<td width="8%" class="thinborder"><strong>Subject Status</strong></td>
	   <%
		if(WI.fillTextValue("show").equals("2")){%>
		<td width="10%" class="thinborder"><strong>Dropped By</strong></td>
	   <td width="9%" class="thinborder"><strong>Date Dropped</strong></td>
		<%}%>
	</tr>
	<%
for( iRowsPrinted = 0 ; i < vRetResult.size(); i+=19, ++iRowsPrinted){
	strCCode = (String)vRetResult.elementAt(i+7);
	strEnrollIndex = (String)vRetResult.elementAt(i);
	
	
	
	if(iRowsPrinted >= iRowsPerPg){
		bolPageBreak = true;
		break;
	}
	
	if(!strPrevCCode.equals(strCCode)){
		strPrevCCode = strCCode;
	%>
	<tr><td colspan="9" height="18" class="thinborder"><strong><%=strCCode%></strong></td></tr>
	<%}%>
	
	<tr>
		<td height="18" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+4) + WI.getStrValue((String)vRetResult.elementAt(i+5), " / ", "", "") +
					WI.getStrValue((String)vRetResult.elementAt(i+6), " - ", "", "N/A");
		%>
		<td class="thinborder"><%=strTemp%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+9)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+10)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+13)%></td>
		<td class="thinborder"><%=astrSubStatus[Integer.parseInt((String)vRetResult.elementAt(i+11))]%></td>
	   <%if(WI.fillTextValue("show").equals("2")){
		
		iIndexOf = vDropHistList.indexOf(strEnrollIndex);
		if(iIndexOf > -1){
			strDroppedBy = (String)vDropHistList.elementAt(iIndexOf + 2);
			strDroppedDate = (String)vDropHistList.elementAt(iIndexOf + 3);
		}
			
		%>
		<td class="thinborder"><%=WI.getStrValue(strDroppedBy,"&nbsp;")%></td>
	   <td class="thinborder"><%=WI.getStrValue(strDroppedDate,"&nbsp;")%></td>
		<%}%>
	</tr>
	
<%}%>
</table>


<%}%>
<script>window.print();</script>
<%}//end vREtResult != null%>

</body>
</html>
<%
dbOP.cleanUP();
%>
