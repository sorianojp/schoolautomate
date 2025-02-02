<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null || strSchCode.length() == 0) {%>
<p style="font-size:14px; color:#FF0000; font-weight:bold;">You are already logged out. Please login again.</p>
<%return;}%>
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
        SUMMARY FACULTY LOAD REPORTS ::::</strong></font></div></td>
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
    <td width="71%" align="center"><div align="left"> <a href="./summary_faculty_load_individual.jsp">Summary
        of Faculty Load (Individual)</a><br>
      </div></td>
  </tr>
  <tr>
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25"></td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="summary_faculty_load_per_college_dept.jsp">Summary
        of Faculty Load (Per College/Department)</a></div></td>
  </tr>
  <tr>
    <td height="24">&nbsp;</td>
    <td height="24">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="faculty_per_college_loading.jsp">Print Detailed Faculty Load 
      (Per College / Department)</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
<%if(strSchCode.startsWith("UDMC")){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>
		<a href="summary_faculty_load_detailed_per_college.jsp">Detailed Faculty Load per college (shown in one page)</a>
	</td>
  </tr>
<%}%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
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
