<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
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
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: REPORT MAIN PAGE ::::</strong></font></div></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25" width="5%">&nbsp;</td>
    <td width="37%">&nbsp;</td>
    <td width="51%">&nbsp;</td>
    <td width="7%">&nbsp;</td>
  </tr>
<%if(strSchCode.startsWith("WNU") || strSchCode.startsWith("PIT") || strSchCode.startsWith("CIT") || strSchCode.startsWith("UC") || strSchCode.startsWith("PWC") || strSchCode.startsWith("UB")){%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./other/other_sch_fee_summary.jsp">Other School Fee Collection</a> </td>
    <td><a href="./other/posted_to_ledger_summary.jsp">Posted to Ledger (Debit/Credit)</a></td>
    <td>&nbsp;</td>
  </tr>
<%}else if(strSchCode.startsWith("UL")){%>
   <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./other/installment_dues_ul.jsp">Installment Dues</a> </td>
    <td><a href="./other/posted_to_ledger_summary.jsp">Posted to Ledger (Debit/Credit)</a></td>
    <td>&nbsp;</td>
  </tr>
<%}else if(strSchCode.startsWith("AUF")){%>
   <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./other/posted_to_ledger_summary.jsp">Posted to Ledger (Debit/Credit)</a></td>
    <td></td>
    <td>&nbsp;</td>
  </tr>
<%}%>
<%if(strSchCode.startsWith("CIT")){%>
   <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./other/cit/assessment_main.jsp?print_by=1">Print Assessment</a></td>
    <td></td>
    <td>&nbsp;</td>
  </tr>
   <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./other/cit/cit_lab_deposit.jsp">Lab Deposit</a></td>
    <td></td>
    <td>&nbsp;</td>
  </tr>
   <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./other/cit/cit_nstp_tuition.jsp">NSTP Tuition Report</a></td>
    <td></td>
    <td>&nbsp;</td>
  </tr>
<%}%>
<%if(strSchCode.startsWith("UC")){%>
   <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./other/periodic_account_balance.jsp">Periodic Account Balance</a></td>
    <td><a href="./other/clearance_account_slip.jsp">Clearance(Account Slip)</a></td>
    <td>&nbsp;</td>
  </tr>
<%}%>
   <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./other/posted_to_ledger_postcharge.jsp">Posted To Ledger(Post charge - Tuition/Non-Tuition)</a></td>
    <td></td>
    <td>&nbsp;</td>
  </tr>
<tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./other/eac/back_account_payment.jsp">Back Account Payment Details</a></td>
    <td height="25"><a href="./other/misc_oc_payable.jsp">Misc/Other Charge Payable(Detailed)</a></td>
    <td align="center">&nbsp;</td>
  </tr>
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
