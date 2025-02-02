<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
    }
-->
</style>
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
function PrintPg() {
	var loadPg = "";
	var strIssueCode = document.form_.code_no.value;
	if(strIssueCode.length == 0) {
		alert("Please enter code.");
		document.form_.code_no.focus();
		return;
	}
	if(document.form_.issue_[0].checked)
		loadPg = "./issue_return_receipt.jsp?is_issue=1&code_no="+strIssueCode;
	else
		loadPg = "./issue_return_receipt.jsp?code_no="+strIssueCode;
	
	var win=window.open(loadPg,"myfile",'dependent=no,width=700,height=500,top=5,left=5,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body onLoad="document.form_.code_no.focus();">
<form name="form_">
<table width="100%" cellpadding="0" cellspacing="0" border="0">
<tr> 
    <td >&nbsp;</td>
  </tr>
<tr> 
    <td >&nbsp;Enter Code :		
    <input type="text" name="code_no" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="20"></td>
  </tr>
<tr>
  <td >&nbsp;<input name="issue_" type="radio" value="1" checked>
    Print Issue Receipt
      <input name="issue_" type="radio" value="0">
      Print Return Receipt </td>
</tr>
<tr>
  <td align="center"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
<font size="1"> Click to print Receipt.</font>  </td>
</tr>
</table>	 
</form>
</body>
</html>
