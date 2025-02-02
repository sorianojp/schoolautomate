<%@ page language="java" import="utility.*" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
String strUserId = (String)request.getSession(false).getAttribute("userId");
boolean bolShowAllLinks = false;
if(strUserId != null){
 	if(strUserId.equals("bricks") || strUserId.toLowerCase().equals("sa-01"))// para show tanan links
		bolShowAllLinks = true;
}
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Period Loans reconciliation</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
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
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
      PAYROLL : LOAN REPORTS   MAIN PAGE ::::</strong></font></td>
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
    <td width="71%"><a href="reconciliation/loan_period_recon.jsp">Period Loans reconciliation</a></td>
  </tr>
 <%//if(false){%>
  <tr> 
    <td height="26">&nbsp;</td>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="reconciliation/emp_loans_recon.jsp">Employee Loans reconciliation</a></td>
  </tr>
  <%//}%>   
  <tr>
    <td height="26">&nbsp;</td>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="payments/emp_loans_summary.jsp">Loans Summary</a></td>
  </tr>  
  
  <tr>
    <td height="26">&nbsp;</td>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="reports/indv_total_loan_bal.jsp">Individual Total Balances</a></td>
  </tr>
  <tr>
    <td height="26">&nbsp;</td>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="reports/emp_loans_balance.jsp">Employee Loan Balances</a></td>
  </tr>
  <tr>
    <td height="26">&nbsp;</td>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="reports/no_schedule_payable.jsp">Loans with balance and no schedule</a></td>
  </tr>
	<tr>
	  <td height="26">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td><a href="forwarded_loans.jsp">Forwarded Loans</a></td>
  </tr>
  <%if(bolShowAllLinks || strSchCode.startsWith("CLC")){%>
	<tr>
	  <td height="26">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td><a href="reports/loan_first_payment.jsp">Loans First Payment</a></td>
  </tr>		
	<tr>
	  <td height="26">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td><a href="reports/unpaid_first_schedule.jsp">First Payment Due</a></td>
  </tr>		
	<%}%>
	<%if(bolShowAllLinks){%>	
	<tr>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="reports/initial_loan_payable.jsp">Initial Loan Payable</a></td>
  </tr>
	<%}%>
	
	<tr>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="upload_loan.jsp">UPLOAD existing loans</a></td>
  </tr>		
		
	<tr>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="manual_loan_schedule.jsp">Manual Update Loan Schedule</a></td>
  </tr>	
	<tr>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="upload_loan_ext.jsp">UPLOAD existing loans (External/internal)</a></td>
  </tr>	
		
	<!--
	note:
	fused with no_schedule_payable.jsp
  <tr>  
	  <td height="26">&nbsp;</td>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="reports/loan_extension.jsp">Loans extension for loans without schedule </a></td>
  </tr>
	-->
  <tr>
    <td height="26">&nbsp;</td>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>    
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
</body>
</html>
