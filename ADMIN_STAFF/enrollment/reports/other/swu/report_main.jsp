<%@ page language="java" import="utility.*"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
a{
	text-decoration: none;
}
</style>
<title>Untitled Document</title></head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<%	
	/*
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}*/
	//end of security
%>
<body bgcolor="#D2AE72">


	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: ENROLLMENT REPORTS ::::</strong></font></div></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
		<tr>
			<td colspan="3" height="25">&nbsp;</td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./daily_enrollment_report_swu.jsp">Student Daily Enrollment Encoding</a></td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./daily_enrollment_report.jsp">Student Daily Enrollment</a></td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./student_master_list_swu.jsp">Student Master List</a></td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./student_mailing_list_swu.jsp">Student Mailing List</a></td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./enrolment_summary_print_SWU.jsp">Enrollment Summary</a></td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./enrolment_summary_print_SWU_detailed.jsp">Enrollment Summary Detailed</a></td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./statistics_demographic.jsp">Demographic Statistics</a></td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./statistics_demographic_detailed.jsp">Demographic Statistics Detailed</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./statistics_master_list_zipcode.jsp">Zip Code - Mater List</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./statistics_per_course_zipcode.jsp">Zip Code - Per Course</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./subj_with_below_min_req.jsp">Subjects below Minimum Requirement</a></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
	</table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>

</body>
</html>
