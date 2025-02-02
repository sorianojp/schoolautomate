<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#D2AE72">
<%
utility.ReadPropertyFile rp = new utility.ReadPropertyFile();
String strGsPmtLinked = rp.getImageFileExtn("GS_PMT_LINKED","0");
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
if (strSchCode == null) {%>
	<p style="font-family:Geneva, Arial, Helvetica, sans-serif; font-weight:bold; color:#FF0000;"> You are already logged out. please login again.</p>
<%return;}

if(strSchCode.startsWith("CIT") || strSchCode.startsWith("VMA")) {
	response.sendRedirect("./grade_sheet.jsp");
	return;
}

%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" align="center"><font color="#FFFFFF"><strong>::::
          GRADE SHEETS  ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25" align="left">&nbsp;&nbsp;&nbsp;</td>
    </tr>
	<tr>
		<td height="35" align="center" valign="middle"><a href="./grade_sheet.jsp">ENCODE GRADE</a></td>
	</tr>
	<%if ((strSchCode.startsWith("UC") || strSchCode.startsWith("PHILCST") || 
		strSchCode.startsWith("CGH") || strSchCode.startsWith("NEU")) && strGsPmtLinked.equals("0") && !strSchCode.startsWith("CIT")){// && (strSchCode.startsWith("AUF") || strSchCode.startsWith("CPU")) ) {%>
	<tr>
		<td height="35" align="center" valign="middle"><a href="./grade_sheet_uploadCSV.jsp">UPLOAD GRADE IN CSV</a></td>
	</tr>
	<%}%>
	<%if(strSchCode.startsWith("UB")){// && (strSchCode.startsWith("AUF") || strSchCode.startsWith("CPU")) ) {%>
	<tr>
		<td height="35" align="center" valign="middle"><a href="./grade_sheet_ng.jsp">ENCODE GRADE - (NG GRADE)</a></td>
	</tr>
	<%}%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
          </tr>
  </table>
</body>
</html>
