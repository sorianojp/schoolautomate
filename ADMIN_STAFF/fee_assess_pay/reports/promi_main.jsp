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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) {%>
	<p style="font-size:24px; color:#FFFF00">You are already logged out. Please login again.</p>
<%return;}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        PROMISORY NOTE PAGE ::::</strong></font></div></td>
    </tr>
	</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./promisory_note.jsp">Record Promisory Note </a></td>
  </tr>
<%if(request.getParameter("show") == null) {%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./promisory_general_summary.jsp?adjust_pn=checked">Promisory Note Listing</a></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./promisory_detail_summary.jsp?adjust_pn=checked">Promisory Note Detail</a></td>
  </tr>
<%}if(strSchCode.startsWith("VMUF")){%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./promisory_detail_overdue.jsp">Promisory Overdue Report (apply fine if overdue)</a></td>
  </tr>
<%}%>
<%if(strSchCode.startsWith("AUF")){%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./other/promisory_record_unclaimed_permit_encode.jsp">Encode Unclaimed Permit</a></td>
  </tr>
<%}%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td> 
      <!--<a href="./payment_modification.jsp?page_action=3">REMOVE PAYMENT ENTRY</a>-->
    </td>
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
