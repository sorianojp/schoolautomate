<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        GRADE-SHEET ENCODING MAIN PAGE ::::</strong></font></div></td>
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
    <td width="8%" height="25" align="right">Operation: </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="78%" align="center"><div align="left"><a href="./sub_accredition_change_course.jsp">CHANGE 
        COURSE INFORMATION MANAGEMENT (SAME SCHOOL)</a></div></td>
  </tr>
<%if(strSchCode.startsWith("UI") || strSchCode.startsWith("VMUF") || strSchCode.startsWith("DBTC")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="8%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="78%" align="center"><div align="left"><a href="./sub_accredition_foreign_stud.jsp">SUBJECT 
        CREDITATION (FOREIGN STUDENT)</a></div></td>
  </tr>
<%}%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./sub_accredition_foreign_stud.jsp?local_stud=1">SUBJECT CREDITATION</a></td>
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
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

</body>
</html>
