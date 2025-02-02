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
boolean bolIsWNU = strSchCode.startsWith("WNU");
%>
<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: REPORT MAIN PAGE ::::</strong></font></div></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25" width="5%">&nbsp;</td>
    <td width="37%">&nbsp;</td>
    <td width="28%">&nbsp;</td>
    <td width="30%">&nbsp;</td>
  </tr>
<%if(bolIsWNU || strSchCode.startsWith("CLDH")) {%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./other/projected_collection_wnu.jsp">Projected Collection </a> </td>
    <td><a href="./other/cash_receipt_register.jsp">Cash Receipt Register</a></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./other/periodic_account_balance.jsp">Periodic Account Balance</a> </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
<%}if(!bolIsWNU){%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="3"><strong><u>SCHOLARSHIP</u></strong></td>
  </tr>
  <tr> 
    <td width="5%" height="25">&nbsp;</td>
    <td width="37%" height="25"><a href="./scholarship_summary.jsp">Summary 
      of Scholarship</a> </td>
    <td width="28%"><a href="./scholarship_details.jsp">Details 
    of Scholarship</a></td>
    <td width="30%">&nbsp;</td>
  </tr>
  <tr> 
    <td width="5%" height="25">&nbsp;</td>
    <td height="25" colspan="3"><strong><u>PAYMENT &amp; PROMISORY 
      NOTE</u>
    </strong></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">
	<!--
		<a href="./major_exam_summary.jsp">Report by Major Exams(Payment)</a> 
	-->
		<a href="./major_exam_summary_new.jsp">Report by Major Exams(Payment)</a> 
	</td>
    <td><a href="promi_main.jsp">Promisory Note Report</a></td>
    <td>&nbsp;</td>
  </tr>
<%if(strSchCode.startsWith("UDMC")){%>  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25"><a href="./enrollment_data.jsp">Enrollment Data </a></td>
    <td><a href="./udmc_orusage.jsp">OR Usage </a></td>
    <td>&nbsp;</td>
  </tr>
<%}%>  
<%if(strSchCode.startsWith("CLDH")){%>  <tr> 
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25"><a href="./other/dropout_dueto_absence.jsp">Dropped out student due to Absenses</a></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
<%}%>  
<%}//show only if bolIsWNU is true.. %>
<%if(strSchCode.startsWith("AUF")){%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25"><a href="./other/auf_semestral_remark.jsp">Semestral Ledger Remark Listing</a></td>
    <td><a href="./other/posted_to_ledger_summary.jsp">Posted to Ledger (Debit/Credit)</a></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25"><a href="./other/auf_posted_to_ledger_print.jsp">Posted To Ledger</a></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
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
    <td align="center">&nbsp;</td>
  </tr>
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
