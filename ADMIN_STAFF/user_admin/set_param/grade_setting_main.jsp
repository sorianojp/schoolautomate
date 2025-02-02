<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) {%>
	<p style="font-size:16px; color:#FF0000">You are already logged out. Please login again.</p>

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
      <td height="25" colspan="2" bgcolor="#A49A6A" align="center"><font color="#FFFFFF" ><strong>:::: SET GRADE SHEET PARAMETER ::::</strong></font></td>
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
    <td width="8%" height="25">&nbsp;</td>
    <td width="12%" height="25" align="right">Operation : </td>
    <td width="4%">&nbsp;</td>
    <td width="76%"><a href="../set_param_gs.jsp">Last Date of Grade sheet encoding</a></td>
  </tr>
  <tr> 
    <td width="8%" height="25">&nbsp;</td>
    <td width="12%" height="25">&nbsp;</td>
    <td width="4%">&nbsp;</td>
    <td width="76%"><a href="./lock_gs.jsp">Lock grade sheet encoding (To be used during enrollment - only if needed)</a></td>
  </tr>
<%if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("UC") || strSchCode.startsWith("SPC")){%>
  <tr> 
    <td width="8%" height="25">&nbsp;</td>
    <td width="12%" height="25">&nbsp;</td>
    <td width="4%">&nbsp;</td>
    <td width="76%"><a href="./gs_allow_user_to_encode_grade.jsp">Allow Other Users to Encode Faculty Grade</a></td>
  </tr>
<%}%>
<%if(strSchCode.startsWith("UB")){%>
  <tr> 
    <td width="8%" height="25">&nbsp;</td>
    <td width="12%" height="25">&nbsp;</td>
    <td width="4%">&nbsp;</td>
    <td width="76%"><a href="../set_param_gs.jsp?is_ng=1">Last Date of Grade sheet encoding - NG Grade</a></td>
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
