<%
if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:16px; font-weight:bold; color:#FF0000">You are already logged out. Please login again.</p>
<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        AUTOMATIC WIVER OF DOWNPAYMENT DURING ENROLLMENT ::::</strong></font></div></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25" colspan="4">&nbsp;</td>
   </tr>
  <tr> 
    <td height="25" colspan="4">&nbsp;</td>
   </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./no_dp_req_stud.jsp">Exclude for Downpayment(Per student) </a></td>
  </tr>
  
  <tr> 
    <td height="25" colspan="3"></td>
    <td width="71%"><a href="./no_dp_req_course.jsp">Excluded Student from Downpayment(Per Course/Grade Level) </a></td>
  </tr>
<!--
  <tr> 
    <td height="25" colspan="3"></td>
    <td width="71%"><a href="./stud_no_dp_req_excluded_copy.jsp">Copy Excluded Student from Downpayment </a></td>
  </tr>
-->
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

  <tr><td height="25">&nbsp;</td></tr>
  <tr bgcolor="#A49A6A"><td width="1%" height="25">&nbsp;</td></tr>
</table>

</body>
</html>
