<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*" %>
<%
	DBOperation dbOP = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CHANGE OF SUBJECTS-Move Section / Students",
								"move_section_students_main.jsp");
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
															"Enrollment","CHANGE OF SUBJECTS",request.getRemoteAddr(),
															"move_section_students_main.jsp");
	dbOP.cleanUP();
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        MOVE SECTION / STUDENT(S) MAIN PAGE ::::</strong></font></div></td>
		</tr>
	</table>
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25" colspan="4">&nbsp;</td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation :</td>
    <td width="2%" height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" colspan="3">&nbsp;</td>
    <td width="71%"><a href="../change_subjects/move_students.jsp">Move Student(s)</a></td>
  </tr>
  <tr> 
    <td height="25" colspan="3">&nbsp;</td>
    <td width="71%"><a href="../change_subjects/move_section.jsp">Move Section</a></td>
    </td>
  </tr>
  <tr> 
    <td height="25" colspan="4">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" colspan="4">&nbsp;</td>
  </tr>
</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	  <tr bgcolor="#A49A6A"> 
		<td width="100%" height="25">&nbsp;</td>
	  </tr>
	</table>
</body>
</html>
<%
	dbOP.cleanUP();
%>