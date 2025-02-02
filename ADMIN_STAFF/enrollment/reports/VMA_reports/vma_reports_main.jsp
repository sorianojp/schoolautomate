<%@ page language="java" import="utility.*"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
a{
	text-decoration: none;
}
</style>
<title>Untitled Document</title></head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<%	
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Enrollment-Reports"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Enrollment"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
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
		    <td width="68%"><a href="./section_mgt.jsp">Manage Section Name</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./class_list_per_section.jsp">Class List per Section</a></td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./class_list_per_section_simple.jsp">Class List per Section - Simple</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./enrollment_head_count_per_course.jsp">Head Count per Course</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./enrollment_head_count_all.jsp">Head Count - All</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./master_list.jsp">Student Master List</a></td>
		</tr>

		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./class_time_sched.jsp?print_type=1">Class Time Schedule</a></td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./class_time_sched.jsp?print_type=2">Schedule Per Section</a></td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./head_count_per_course.jsp">Student Head Count</a></td>
		</tr>
		
		
		
		
		
		<!--
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./score_rating.jsp">Set Score Rating</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./scaled_score_conversion_chart.jsp">Set Scaled Score Conversion Chart</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./percentile_conversion_chart.jsp">Set Percentile Conversion Chart</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./view_scaled_score_conversion_chart.jsp">View Scaled Score Conversion Chart</a></td>
		</tr>
		

		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./view_percentile_conversion_chart.jsp">View Percentile Conversion Chart</a></td>
		</tr>
		
		-->
		
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
