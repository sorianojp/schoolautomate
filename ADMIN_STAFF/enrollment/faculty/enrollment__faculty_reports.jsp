<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");

	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        FACULTY LOADING REPORTS ::::</strong></font></div></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
<% if (!strSchCode.startsWith("CPU")) {%> 
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"> <a href="../subjects/print_class_program.jsp?sched_per_section=1">Display 
        Schedule per Section</a><br>
      </div></td>
  </tr>
<%}%> 
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25"  align="right">
	<% if (strSchCode.startsWith("CPU")) {%> 
	Operation : 
	<%}%>&nbsp;	</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="reports/list_of_subjects_not_yet_assigned.jsp">List 
        of Subjects Not Yet Assigned to Faculty</a></div></td>
  </tr>
  <tr> 
    <td height="24">&nbsp;</td>
    <td height="24">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><p><a href="faculty_subj_can_teach.jsp">List of Faculty that can Teach 
        Subject</a></p></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center"><div align="left"><a href="reports/final_sched_of_classes.jsp">Final 
        Schedule of Classes</a></div></td>
  </tr>
<% if (!strSchCode.startsWith("CPU")) {%> 
<!--
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center"><div align="left"><a href="reports/list_of_subjects_with_subs.jsp">List 
        of Subjects with Substitution</a></div></td>
  </tr>
-->
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center"><div align="left"><a href="reports/list_of_teachers_with_subs.jsp">List 
        of Teachers with Substitution</a></div></td>
  </tr>
<%}%> 
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./reports/faculty_availability.jsp">Search Faculty Availability</a></td>
  </tr>
<% if (strSchCode.startsWith("SPC")) {%> 
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./reports/room_faculty_assignment.jsp">Faculty Room Assignment(For Attendance)</a></td>
  </tr>
<%}%>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="44%" height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" valign="middle"></tr>
  <tr bgcolor="#A49A6A"> 
    <td height="25">&nbsp;</td>
  </tr>
</table>

</body>
</html>
