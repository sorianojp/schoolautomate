<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function EncodeCD(strJVType) {
	strJVNumber = prompt('To edit or view detail, enter CD number.','Enter CD Number');
	if(strJVNumber == null)
		strJVNumber = "";
	location = "../journal_voucher/journal_voucher_entry.jsp?jv_number="+strJVNumber+"&jv_type="+strJVType+"&is_cd=1";
}
</script>
<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
        DISBURSEMENT PAGE ::::</strong></font></div></td>
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
    <td width="21%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="#" style="text-decoration:none">Encode/Modify
        Cash Disburshement Entries</a></div></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td> <table border="0" cellpadding="0" cellspacing="0" class="thinborder" width="90%">
        <tr>
          <td class="thinborder" width="33%" height="20"><a href="javascript:EncodeCD('10');"><font color="#000000">Others</font></a></td>
          <td width="33%" class="thinborder"><a href="javascript:EncodeCD('11');"><font color="#000000">Petty
            Cash </font></a></td>
          <td width="34%" class="thinborder">&nbsp;</td>
        </tr>
      </table></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr>
    <td width="12%" height="25">&nbsp;</td>
    <td width="21%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td align="center"><div align="left"><a href="cdv_update_payment_stat.jsp">Update
        Disbursement Voucher Payment Status (Cashier)</a><a href="jv_post.htm"></a></div></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./cdv_encode_check_dtls.jsp">Encode Voucher Check Details (Cashier)</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center"><div align="left"><a href="cancel_cd_check.htm">Encode
        Cancelled CD/CV and/or Check</a></div></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center"><div align="left"><a href="../journal_voucher/jv_summary.jsp?is_cd=1">View/Print
        Cash disbursement Voucher Summary</a></div></td>
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
