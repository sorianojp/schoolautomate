<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf-2007.09.06/css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf-2007.09.06/css/tableBorder.css" rel="stylesheet" type="text/css"></head>
</head>
<script language="javascript" src="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf-2007.09.06/jscript/date-picker.js"></script>
<script language="javascript">
function ShowDetail(strPrintStat) {
	strTBDate = document.form_.bl_date.value;
	if(strTBDate.length == 0) {
		alert("Please enter  cutoff date..");
		return;
	}
	document.form_.print_stat.value = strPrintStat;
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.WebInterface" %>
<form name="form_" method="post" action="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf-2007.09.06/ADMIN_STAFF/accounting/reports/balance_sheet/bl_1st_page.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A" align="center"><font color="#FFFFFF">
	  <strong>:::: DISBURSEMENT SUMMARY PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="30"><font size="2">MONTH / YEAR : <strong><font color="#0000FF">$MONTH_SELECTED / $YEAR </font></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="26" align="center" class="thinborder"><font size="1"><strong>NAME/TAX PAYER</strong></font></td>
      <td class="thinborder" align="center"><font size="1"><strong>TIN #</strong> </font></td>
      <td class="thinborder" align="center"><font size="1"><strong>ALPHANUMERIC TAX CODE</strong></font></td>
      <td class="thinborder" align="center"><font size="1"><strong>CHECK NUMBER </strong></font></td>
      <td class="thinborder" align="center"><font size="1"><strong>AMOUNT</strong></font></td>
    </tr>
    <tr>
      <td width="52%" height="26" class="thinborder">&nbsp;</td>
      <td width="12%" class="thinborder">&nbsp;</td>
      <td width="14%" class="thinborder">&nbsp;</td>
      <td width="11%" class="thinborder">&nbsp;</td>
      <td width="11%" class="thinborder" align="right">321,744.00</td>
    </tr>
    <tr>
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right">63,675.00</td>
    </tr>
    <tr>
      <td height="23" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right">50,926.26</td>
    </tr>
    <tr>
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right">&nbsp;</td>
    </tr>
    <tr>
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right">50,000.00</td>
    </tr>
    <tr>
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right">8,838.43</td>
    </tr>
    <tr>
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right">649,849.65</td>
    </tr>
    <tr>
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <tr>
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right">&nbsp;</td>
    </tr>
    <tr>
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right">&nbsp;</td>
      <td class="thinborder" align="right">&nbsp;</td>
      <td class="thinborder" align="right"><strong>TOTAL : &nbsp;&nbsp;&nbsp;</strong></td>
      <td class="thinborder" align="right">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_pg">
  <input type="hidden" name="print_stat">
</form>
</body>
</html>
