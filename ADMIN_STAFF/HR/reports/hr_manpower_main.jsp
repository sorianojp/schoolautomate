<%@ page language="java" import="utility.CommonUtil"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if (strSchCode == null)
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css" />
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>

<body bgcolor="#D2AE72" class="bgDynamic">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        REPORTS AND STATISTICS::::</strong></font></td>
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
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./hr_manpower_summary.jsp">Manpower 
      Grand Total</a></td>
  </tr>

  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" >&nbsp;</td>
    <td width="71%" ><a href="c_rank/hr_faculty_ntp_head_count.jsp">Total Head Count </a></td>
  </tr>

  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="c_rank/hr_faculty_head_count.jsp">Faculty Manpower</a> </td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="c_rank/hr_faculty_listing_per_college.jsp">Faculty Listing </a></td>
  </tr>
<% if (!strSchCode.startsWith("AUF")) {%> 
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="c_rank/hr_faculty_educ_degrees.jsp">Per College Highest Educational Attainment (Holders Only)</a></td>
  </tr>
<%}%> 
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="hr_educ_summary.jsp">Distribution of Highest Educational Attainment </a></td>
  </tr>
 <% if (strSchCode.startsWith("AUF")) {%> 
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./hr_manpower_turnover.jsp">Manpower Turnover Rate</a></td>
  </tr>
  <%}%>
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
    <td valign="middle">&nbsp;</td></tr>
  <tr bgcolor="#A49A6A" class="footerDynamic">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

</body>
</html>
