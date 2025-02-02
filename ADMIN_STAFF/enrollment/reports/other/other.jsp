<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String strUserId  = (String)request.getSession(false).getAttribute("userId");
if(strUserId == null)
	strUserId = "";
if(strSchCode == null)
	strSchCode = "";
else {
	if(strSchCode.startsWith("UB"))
		strSchCode = "WNU";
}
%>
<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        LIST OF ALL OTHER REPORTS ::::</strong></font></div></td>
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
  <tr> 
    <td width="12%">&nbsp;</td>
    <td width="15%" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"></td>
  </tr>
<%if(strSchCode.startsWith("WNU")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right"></td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./comparative_enrollment.jsp">Comparative Enrollment Summary</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./overall_enrollment.jsp">Enrollment Statistics Summary</a></td>
  </tr>
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./enrollment_summary_percollege.jsp">Enrollment Statistics Detailed</a></td>
  </tr>
<%} else if(strSchCode.startsWith("UC")){%>
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./enrollment_summary_percollege.jsp">Enrollment Statistics Detailed</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./enrollment_per_subject.jsp">Enrollment Per Subject</a></td>
  </tr>
<!--
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="uc_enrollment_stat.jsp">Enrollment Status Summary</a></td>
  </tr>
-->
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../../subjects/cp/print_per_college_dept_offering.jsp">Enrollment Status Detail</a></td>
  </tr>
<%} else if(strSchCode.startsWith("EAC")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cit/nstp_enrollment.jsp">NSTP Enrollment</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./enrollment_per_subject.jsp">Enrollment Per Subject</a></td>
  </tr>
<!--
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./eac_enrol_statistics_summary.jsp">Enrollment Statistics Summary</a></td>
  </tr>
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./eac_enrol_statistics_detailed.jsp">Enrollment Statistics Detailed</a></td>
  </tr>
-->
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./eac/eac_exam_sched_main.jsp">Exam Schedule Information</a></td>
  </tr>

<%} else if(strSchCode.startsWith("CIT")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cit/freshmen.jsp">Freshmen Enrollment Detail</a></td>
  </tr>
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./cit/nstp_enrollment.jsp">NSTP Enrollment</a></td>
  </tr>

   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./cit/average_class_size_cit.jsp">Average Class Size Per Department</a></td>
  </tr>
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./cit/edit_department_section.jsp">Edit Program Section</a></td>
  </tr>
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./cit/section_per_program_cit.jsp">Section Per Program</a></td>
  </tr>
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td></td>
  </tr>
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./cit/tag_professional_subj_cit.jsp">Set up Professional Subject</a></td>
  </tr>
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./cit/average_class_size_per_program_cit.jsp">Average Class Size Per Program</a></td>
  </tr>
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./cit/sy_term_offered_per_subjects.jsp">List of Subject Offered Per SY-Term</a></td>
  </tr>
   <tr>
     <td height="25">&nbsp;</td>
     <td height="25">&nbsp;</td>
     <td align="center">&nbsp;</td>
     <td>&nbsp;</td>
   </tr>
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../../subjects/subject_list_with_conflict.jsp">Subject having Conflict Offering</a></td>
  </tr>
<%}%>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" width="1%">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A"> 
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

</body>
</html>
