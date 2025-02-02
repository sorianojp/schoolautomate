<%@ page language="java" import="utility.*"%>
<%
	WebInterface WI = new WebInterface(request);
	
	boolean bolIsFaculty = (WI.fillTextValue("is_faculty").length() > 0);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
a{
	text-decoration: none;
}
</style>
<title>Untitled Document</title></head>
<script language="javascript" src="../../../jscript/common.js"></script>
<%	
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS-STUDENT TRACKER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS"),"0"));
		}
	}
	
	if(bolIsFaculty)
		iAccessLevel =2;
	
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of security
	String strTemp = null;
	
	
	
	strTemp = "D2AE72";
	if(bolIsFaculty)
		strTemp = "93B5BB";

%>
<body bgcolor="#<%=strTemp%>">


	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%
	strTemp = "A49A6A";
	if(bolIsFaculty)
		strTemp = "6A99A2";
	%>
		<tr bgcolor="#<%=strTemp%>"> 
			<td height="25" colspan="2"><div align="center">
				<font color="#FFFFFF"><strong>:::: ATTENDANCE MONITORING MAIN PAGE ::::</strong></font></div></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
		<tr>
			<td colspan="3" height="25">&nbsp;</td>
		</tr>
<%
if(!bolIsFaculty){
%>
		<tr>
		    <td height="25" width="30%" align="right">Operation:</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./attendance_monitoring.jsp">Attendance Monitoring</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./attendance_monitoring_report.jsp">Student List</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./last_date_encoding.jsp">Set Last Date of Encoding</a></td>
		</tr>
<%}else{%>		
		<tr>
		    <td height="25" width="30%" align="right">Operation:</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./attendance_class_lists.jsp">Print Attendance Sheet per Class list</a></td>
		</tr>
		
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./attendance_monitoring_per_subject.jsp">Encode Student Attendance</a></td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="./attendance_summary_report.jsp">View Students Attendance Summary</a></td>
		</tr>


<%}%>
		
		
		
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
	</table>
<%
	strTemp = "A49A6A";
	if(bolIsFaculty)
		strTemp = "6A99A2";
	%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#<%=strTemp%>">&nbsp;</td>
		</tr>
	</table>

</body>
</html>
