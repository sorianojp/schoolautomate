<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";//strSchCode = "UPH";
boolean bolIsWNU = strSchCode.startsWith("WNU");

boolean bolDefault = false;
if(strSchCode.startsWith("HTC"))
	bolDefault = true;
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
    <td width="48%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./collection_report_fatima.jsp">Collection Report</a> </td>
    <td><a href="./posted_to_ledger_summary.jsp">Posted to Ledger (Debit/Credit)</a></td>
    <td>&nbsp;</td>
  </tr>
<%if(strSchCode.startsWith("HTC")){%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./eac/cashier_report_summary.jsp">Collection Report (Tuition)</a> </td>
    <td></td>
    <td>&nbsp;</td>
  </tr>
<%}%>
<%if(strSchCode.startsWith("VMA")){%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./control_list_vma.jsp">Control List</a> </td>
    <td></td>
    <td>&nbsp;</td>
  </tr>
<%}%>
<%if(strSchCode.startsWith("FATIMA")){%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./collection_report_fatima_assessment_profile.jsp">Assessment Profile</a> </td>
    <td><a href="./periodic_account_balance.jsp">Periodic Account Balance</a></td>
    <td>&nbsp;</td>
  </tr>
<%}%>
<%if(strSchCode.startsWith("UPH") || strSchCode.startsWith("CDD")){%>
   <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./periodic_account_balance.jsp">Periodic Account Balance</a></td>
    <td></td>
    <td>&nbsp;</td>
  </tr>
<%if(strSchCode.startsWith("UPH")){%>
   <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./rotc_income_uph.jsp">ROTC Income Report</a></td>
    <td><a href="./assessment_report_uph.jsp">Assessment Report</a></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./collection_report_fatima_assessment_profile.jsp">Assessment Profile</a> </td>
    <td><a href="./uph/set_subject_catg_main.jsp">Report Per Subject Category</a> </td>
    <td>&nbsp;</td>
  </tr>
<%}
}%>
<%if(strSchCode.startsWith("WUP") || strSchCode.startsWith("CDD")){%>
   <tr> 
    <td height="25">&nbsp;</td>
    <td><a href="./eac/back_account_payment.jsp">Back Account Report</a></td>
    <td height="25"><a href="misc_oc_payable.jsp">Misc/Other Charge Payable(Detailed)</a></td>
    <td>&nbsp;</td>
  </tr>
<%}%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
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
