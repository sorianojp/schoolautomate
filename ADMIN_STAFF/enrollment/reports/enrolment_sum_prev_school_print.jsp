<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

-->
</style>

</head>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.

	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-enrollment summary from prev School","enrolment_sum_prev_school.jsp");
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
														"enrolment_sum_prev_school.jsp");
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
ReportEnrollment reportEnrollment = new ReportEnrollment();
Vector vRetResult = null;
Vector vSchoolInfo = null;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 &&
				WI.fillTextValue("reloadPage").compareTo("1") !=0)
{
	vRetResult = reportEnrollment.getEnrolSumFromPrevSchool(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrollment.getErrMsg();
	else {
		vSchoolInfo = (Vector)vRetResult.remove(0);
	}
}

String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" height="20" colspan="4"><div align="center">
	  <strong><font size="2">:::: SUMMARY REPORT OF ENROLLEE FROM PREVIOUS SCHOOL ::::</font><br>
		  SY:  <%=WI.fillTextValue("sy_from") + " - "+WI.fillTextValue("sy_to")%>
		  (<%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]%>)</strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="20" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%
dbOP.cleanUP();

//if called for saci printout school summary format.. print it and return.. 
if(WI.fillTextValue("print_summary_SACI").length() > 0) {%>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr style="font-weight:bold">
		<td width="25%" class="thinborder" height="25">School Name</td>
		<td width="60%" class="thinborder">School Address</td>
		<td width="15%" class="thinborder">Number of Student</td>
	</tr>
	<%for(int i = 1; i < vSchoolInfo.size(); i += 4){%>
		<tr>
			<td height="22" class="thinborder"><%=vSchoolInfo.elementAt(i + 1)%></td>
			<td class="thinborder"><%=WI.getStrValue(vSchoolInfo.elementAt(i + 2),"-")%></td>
			<td class="thinborder"><%=vSchoolInfo.elementAt(i + 3)%></td>
		</tr>
	<%}%>
  </table>
<%
return;
}//end of saci format.. %>



<%if(vRetResult != null){//System.out.println(vRetResult);
	int iRowTotal = 0;//column total is in vSchoolInfo
	String strCourseName = null;
	String strMajorName  = null;
	int iRowSubTotal = 0;
%>
  <table  bgcolor="#000000" width="100%" border="0" cellspacing="1" cellpadding="1">
    <tr bgcolor="#DBD8C8"> 
      <%
	  for(int p = 1 ; p < vSchoolInfo.size(); p += 4){%>
	  <td height="20" align="center" width="7%">
	  <strong><font size="1"><%=(String)vSchoolInfo.elementAt(p)%></font></strong></td>
	  <%}%>
      <td width="6%"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
    </tr>
<%
	for(int i = 0 ; i< vRetResult.size() ;){//outer loop for each course program.
		strCourseName = (String)vRetResult.elementAt(i); 
		strMajorName  = (String)vRetResult.elementAt(i + 1);
		iRowTotal = 0;
		iRowSubTotal = 0;
	%>

    <tr bgcolor="#FFFFFF"> 
      <td height="20" colspan="<%=1 + (vSchoolInfo.size()-1)/4%>"><font size="1">COURSE/MAJOR:<strong> 
	  <%=strCourseName%> <%=WI.getStrValue(strMajorName,"/","","&nbsp;")%></strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
	<%
	  for(int p = 1 ; p < vSchoolInfo.size() ; p += 4){
	  	
	  if(i < vRetResult.size() && 
	  		strCourseName.compareTo((String)vRetResult.elementAt(i)) == 0 && 
	  		WI.getStrValue(strMajorName).compareTo(WI.getStrValue(vRetResult.elementAt(i + 1))) == 0) {
			//proceed.
			//if it has any value for the college, continue;
			if(((String)vSchoolInfo.elementAt(p)).compareTo((String)vRetResult.elementAt(i + 2)) == 0){
				iRowSubTotal = Integer.parseInt((String)vRetResult.elementAt(i + 3));
				iRowTotal += iRowSubTotal;
				i += 4;
			}
			else	
				iRowSubTotal = 0;
		}
		else	
			iRowSubTotal = 0;
	  
	  %>	
      <td height="25" width="7%" align="center"><%=iRowSubTotal%></td>
	<%}%>
      
    <td width="6%" align="center"><strong><%=iRowTotal%></strong></td>
    </tr>
    <%}%>
    <tr bgcolor="#FFFFFF">
      <td colspan="<%=1 + (vSchoolInfo.size()-1)/4%>"><strong><font size="1">GRAND TOTAL :&nbsp;&nbsp;&nbsp;</font></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <%
	  for(int p = 1 ; p < vSchoolInfo.size(); p += 4){%>
	  <td height="25" bgcolor="#FFFFFF" align="center" width="7%">
	  <strong><font size="1"><%=(String)vSchoolInfo.elementAt(p + 3)%></font></strong></td>
	  <%}%>
      <td width="6%" bgcolor="#FFFFFF"><div align="center"><strong><font size="1"><%=(String)vSchoolInfo.elementAt(0)%></font></strong></div></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%//PRINT LEGEND
	  for(int p = 1 ; p < vSchoolInfo.size(); p += 4){%>    
	  <tr>
      	<td width="50%" height="25">&nbsp;&nbsp;<strong><%=(String)vSchoolInfo.elementAt(p)%></strong> - <%=(String)vSchoolInfo.elementAt(p+1)%></td>
	  <% p +=4; 
	  	if (p < vSchoolInfo.size()) 
			strTemp = "<strong>" + (String)vSchoolInfo.elementAt(p) + "</strong> - " +(String)vSchoolInfo.elementAt(p+1);
		else
			strTemp = "";
	  %> 
      	<td width="50%">&nbsp;&nbsp;&nbsp;&nbsp;<%=strTemp%></td>
	  </tr>
	<%}%>
  </table>
<%}//only if vRetResult is not null
%>
</body>
</html>
