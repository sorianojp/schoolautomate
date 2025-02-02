<%@ page language="java" import="utility.CommonUtil"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css" />
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body bgcolor="#C39E60" class="bgDynamic">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr bgcolor="#A49A6A" class="footerDynamic">
    <td width="1%" height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
 <!--
  <tr>
    <td height="25">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="hr_ind_salary.jsp">C.3 Individual Salary of Faculty and NTP </a></td>
  </tr>  
 -->
  <tr>
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation :</td>
    <td width="2%" align="center">&nbsp;</td>
    <td><div align="left"><a href="./hr_faculty_agd.jsp">C.4 List of Faculty with MA-MS / PhD For AGD purposes (for VP Submission) </a></div></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="hr_ntp_agd.jsp">C.5 List of NTP with MA-MS / PhD For AGD purposes (for VP Submission)</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="hr_fac_ntp_agd_acctg.jsp">C.6 List of Faculty/NTP with MA / PhD for AGD Purpose (for Accounting)</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="hr_list_licensure.jsp?show_all=1">C.7 List of Faculty/Personnel with Licensure</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./hr_faculty_profile_acad_qualification.jsp">C.8.1 Faculty Profile by Academic Qualifications</a></td>
  </tr>

  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./hr_faculty_ranking.jsp">C.8.2 Summary - Ranks </a></td>
  </tr>
 <%if(false){//this is old report%>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./hr_faculty_educ_degrees.jsp">C.8.3 Summary - Education Degrees</a></td>
  </tr>
  <%}%>
 <!--   <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./hr_manpower_summary_faculty.jsp">List of Faculty Per Rank </a></td>
  </tr>

  -->
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="../hr_faculty_qualifications.jsp">C.8.3 Summary - Education Degrees</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" width="1%">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
  </tr>
  <tr bgcolor="#A49A6A" class="footerDynamic">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>
</body>
</html>
