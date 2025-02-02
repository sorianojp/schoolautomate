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
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        CASHIER'S REPORT ::::</strong></font></div></td>
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
<%if(strSchCode.startsWith("SWU")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./consolidated_cash_collection_or_range_SWU.jsp">Daily Cashier's report (Summary)</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cashier_report_orprooflist_SWU.jsp">Daily Cashier's report (Detailed)</a></td>
  </tr>
<%}else{%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cashier_report_summary.jsp">Daily Cashier's report (Summary)</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cashier_report_detailed.jsp">Daily Cashier's report (Detailed)</a></td>
  </tr>
<%}if(strSchCode.startsWith("CDD")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cashier_report_orprooflist_cdd.jsp">OR Proof List</a></td>
  </tr>
<%}if(strSchCode.startsWith("SPC")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cashier_report_orprooflist_spc.jsp">OR Proof List</a></td>
  </tr>
<%}else if(!strSchCode.startsWith("SWU")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cashier_report_orprooflist.jsp">OR Proof List</a></td>
  </tr>
<%}
String strUserId  = (String)request.getSession(false).getAttribute("userId");
if(strUserId == null)
	strUserId = "";
if(strSchCode == null)
	strSchCode = "";
	
if( strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC") || strUserId.equals("1770") || 
strSchCode.startsWith("UPH") || strSchCode.startsWith("CDD")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cashier_report_detailed.jsp?or_range=1">Daily Cashier's report 
      (Detailed) - For OR Range</a></td>
<%}%>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
<%if(strSchCode.startsWith("UB")){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./cashier_report_summary_UB.jsp">Daily Collection Summary</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./cashier_report_pos_UB.jsp">Teller's Tape </a></td>
  </tr>
<%}%>

<%if(strSchCode.startsWith("CIT") || strSchCode.startsWith("UB") || strSchCode.startsWith("CSA")){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../cash_receipt/daily_encoding_den.jsp">Cash Counting</a></td>
  </tr>
<%}%>

<%if(strSchCode.startsWith("EAC")){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./currency_rating/manage_currency.jsp">Manage Currency Conversion Rating</a></td>
  </tr>
<%}%>
<%if(strSchCode.startsWith("UC")){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../cash_receipt/deposit/cash_deposit_main_restricted.jsp">Cash Deposit Report</a></td>
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
