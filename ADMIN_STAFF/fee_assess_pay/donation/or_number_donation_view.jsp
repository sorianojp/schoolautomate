<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PRINT RECEIPT BY OR NUMBER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function focusOR()
{
	document.form_.or_number.focus();
}
function PrintPg(strPrintStat) {
	if(document.form_.or_number.value.length == 0) {
		alert("Please enter OR Number.");
		return;
	}
	var pgLoc = "./receive_donation_print.jsp?print_page="+strPrintStat+
					"&or_number="+escape(document.form_.or_number.value);
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="javascript:focusOR();">
<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PRINT/VIEW DONATION RECEIPT BY OR NUMBER ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp; &nbsp; &nbsp; <strong></strong></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2" height="25">Enter Reference Number: </td>
      <td width="65%" height="25"><input name="or_number" type="text" size="20" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        (Enter ID of Student) </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25" align="right"><a href="javascript:PrintPg(0);">
	  <img src="../../../images/view.gif" border="0"></a><font size="1">
	  Click to view Receipt</font></td>
      <td height="25"><a href="javascript:PrintPg(1);"> <img src="../../../images/print.gif" border="0"></a><font size="1"> 
        Click to print Receipt</font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25">&nbsp;</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
	</tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
