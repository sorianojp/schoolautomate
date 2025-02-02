<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String strUserId  = (String)request.getSession(false).getAttribute("userId");

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
      <td height="25">&nbsp;</td>
      <td height="25">REPORTS</td>
      <td align="center">&nbsp;</td>
      <td><a href="./enrolment_data_per_course_and_year.jsp">Comparative Enrollment Data by Course/Year Level</a></td>
  </tr>
  <tr>
      <td height="25">&nbsp;</td>
      <td height="25" align="right"></td>
      <td align="center">&nbsp;</td>
      <td><a href="./expected_enrollee_per_course_and_year.jsp">Expected Enrollees per Course/ Year level</a></td>
  </tr>
 <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td><a href="./enrolment_data_per_course_and_year_and_gender.jsp">Enrollment Data per Year Level w/ Gender</a></td>
  </tr>
  <tr>
      <td height="25">&nbsp;</td>
      <td height="25" align="right"></td>
      <td align="center">&nbsp;</td>
      <td><a href="./comparative_enrl_data_basic_ed.jsp">Comparative Enrollment Data Basic Ed</a></td>
  </tr>
   <tr>
      <td height="25">&nbsp;</td>
      <td height="25" align="right"></td>
      <td align="center">&nbsp;</td>
      <td><a href="./enrolment_data_per_college_basic.jsp">Comparative Enrollment Data by College/Basic Education(Summary)</a></td>
  </tr>
  
  <tr>
      <td height="25">&nbsp;</td>
      <td height="25" align="right"></td>
      <td align="center">&nbsp;</td>
      <td><a href="./report_enrollment_projection.jsp">Comparative Enrollment Data (Projection)</a></td>
  </tr>
  
  
  <tr>
      <td height="25">&nbsp;</td>
      <td height="25" align="right"></td>
      <td align="center">&nbsp;</td>
      <td>&nbsp;</td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">ENCODING</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./encode_max_min_enrol_projection.jsp">Encode Max/Min Enrollment Projection</a></td>
  </tr>
  <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td><a href="./encode_max_min_enrol_projection.jsp?is_basic=1&is_basic_expected_enrol=1">Encode Basic Ed Expected Enrollees</a></td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">  
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"> <td width="1%" height="25">&nbsp;</td></tr>
</table>

</body>
</html>
