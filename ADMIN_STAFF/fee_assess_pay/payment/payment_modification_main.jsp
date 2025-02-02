<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) {%>
	You are already logged out. Please login again.
<%return;}

	boolean bolShowDateMod = false;
if(strSchCode.startsWith("VMA") || strSchCode.startsWith("CIT") || strSchCode.startsWith("UB") || 
strSchCode.startsWith("CGH") || strSchCode.startsWith("PWC") || strSchCode.startsWith("DBTC") || 
strSchCode.startsWith("MARINER") || strSchCode.startsWith("NEU") || strSchCode.startsWith("DLSHSI")) {
	bolShowDateMod = true;
}

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
        PAYMENT MODIFICATION MAIN PAGE ::::</strong></font></div></td>
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
    <td height="25" colspan="3"><strong><font color="#6666FF" size="3">NOTE : 
      Click desired link only if there is an error in payment encoding.</font></strong></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./payment_modification.jsp?page_action=0">Change 
      AMOUNT paid</a></td>
  </tr>
<%if(bolShowDateMod) {%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./payment_modification.jsp?page_action=1">Change 
      DATE of PAYMENT</a></td>
  </tr>
<%}%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./payment_modification.jsp?page_action=2">Change PAYMENT MODE 
      (full or Installment)</a></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td> <a href="./payment_modification.jsp?page_action=4">Change Payment School 
      Year Information</a> </td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./payment_modification.jsp?page_action=5">Change OR Number (only 
      if payment is downpayment type)</a> </td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./payment_modification.jsp?page_action=6">Change Payment Schedule 
      Information </a> </td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td> 
      <!--<a href="./payment_modification.jsp?page_action=3">REMOVE PAYMENT ENTRY</a>-->
    <a href="./payment_modification_cashcheck.jsp?">Change Payment Info (Cash/Check)</a></td>
  </tr>
<%if(strSchCode.startsWith("CIT") && false){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./payment_modification.jsp?page_action=7">Modify Student ID</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
<%}if(strSchCode.startsWith("CIT") || strSchCode.startsWith("UB")){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./payment_modification.jsp?page_action=10">Change Bank Information in Bank Payment </a></td>
  </tr>
<%}if(strSchCode.startsWith("UC") || true){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./payment_modification.jsp?page_action=5&allow_orchng_all=1">Change OR Number</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./payment_modification_report.jsp">Report for Modified Payment</a></td>
  </tr>
<%}%>
  <!--
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./payment_modification_move_oth_instalfee.jsp">Move Other School Fee to Installment Fee</a></td>
  </tr>

  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>Move Installment Fee to Other School Fee </td>
  </tr>
-->
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
