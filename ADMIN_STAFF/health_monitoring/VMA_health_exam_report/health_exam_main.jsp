<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
a{
	text-decoration: none
}
</style>
</head>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","log_main.jsp");
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
															"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
															"log_main.jsp");
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

%>
<body bgcolor="#8C9AAA" class="bgDynamic">
<form action="listings_main.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="28" colspan="4" bgcolor="#697A8F" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
			HEALTH EXAM - MAIN ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<%if(strSchCode.startsWith("CSA")){%>
		<tr> 
			<td width="25%"  height="25">&nbsp;</td>
			<td width="50%" height="25"><div align="center"><a href="./health_exam_entry_csa.jsp">Health Exam</a></div></td>
			<td width="25%" height="25">&nbsp;</td>
		</tr>
		<%}%>
		<%if(strSchCode.startsWith("VMA")){%>
		<tr> 
			<td width="25%"  height="25">&nbsp;</td>
			<td width="50%" height="25"><div align="center"><a href="./health_exam_entry.jsp">Health Exam</a></div></td>
			<td width="25%" height="25">&nbsp;</td>
		</tr>
		<%}%>
		<%if(strSchCode.startsWith("SPC")){%>
		<tr> 
			<td width="25%"  height="25">&nbsp;</td>
			<td width="50%" height="25"><div align="center"><a href="./health_exam_entry_spc_grade_school.jsp">Health Exam (Elementary)</a></div></td>
			<td width="25%" height="25">&nbsp;</td>
		</tr>
		<tr> 
			<td width="25%"  height="25">&nbsp;</td>
			<td width="50%" height="25"><div align="center"><a href="./health_exam_entry_spc_high_school.jsp">Health Exam (Highschool)</a></div></td>
			<td width="25%" height="25">&nbsp;</td>
		</tr>
		<%}%>
		<!--<tr> 
			<td height="28">&nbsp;</td>
			<td height="28"><div align="center"><a href="./dependent_listing.jsp">DEPENDENT VISIT LOG LISTING </a></div></td>
			<td height="28">&nbsp;</td>
		</tr>-->
		<tr> 
			<td height="28">&nbsp;</td>
			<td height="28">&nbsp;</td>
			<td height="28">&nbsp;</td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr >
			<td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>