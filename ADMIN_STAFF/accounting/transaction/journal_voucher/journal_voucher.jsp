<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new utility.CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function EncodeJV(strJVType) {
	strJVNumber = prompt('To edit or view detail, enter JV number.','');
	if(strJVNumber == null)
		strJVNumber = "";
	if(strJVType == 3 && strJVNumber == "") {
		//alert("Please enter jv number to modify/view enrollment information. To create enrollment jv , go to Fee assment and payment -> Reports -> Specific Fee Collection (AR)");
		location = "../../../fee_assess_pay/reports/specific_acct_cpu.jsp";
		return;
	}
	if(strJVType == "100") {
		strJVType ="0&jv_liquidation=1";
	}
	if(strJVType == "200") {
		strJVType ="0&jv_crj=1";
	}
	location = "./journal_voucher_entry.jsp?jv_number="+escape(strJVNumber)+"&jv_type="+strJVType;
}
function CreateDuplicate() {
	var pgLoc = "../cash_disbursement/duplicate_voucher.jsp?is_cd=0";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=400,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        General Journal Page ::::</strong></font></div></td>
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
    <td width="6%" height="25">&nbsp;</td>
    <td width="21%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center">
	<%if(bolIsSchool && false){%>
		<div align="left"><a href="#" style="text-decoration:none">Encode/Modify Voucher Entries</a></div></td>
	<%}%>
  </tr>
  
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>
	<%if(bolIsSchool){%>
		<table border="0" cellpadding="0" cellspacing="0" class="thinborder" width="90%">
			<tr>
				<td class="thinborder" width="33%" height="20"><a href="javascript:EncodeJV('0');"><font color="#000000">Create Entries</font></a></td>
				<td width="33%" class="thinborder"><a href="javascript:EncodeJV('8');"><font color="#000000">Student Debit/Credit</font></a></td>
			    <td width="34%" class="thinborder">&nbsp;
				<!--
				<a href="javascript:EncodeJV('100');"><font color="#000000">Liquidation</font></a>
				-->				</td>
			</tr>
			<tr>
			  <td class="thinborder" height="20">
				<a href="javascript:EncodeJV('200');"><font color="#000000">Create GJV for Bank Deposit from CRJ</font></a>
 			  </td>
			  <td class="thinborder">&nbsp;</td>
			  <td class="thinborder">&nbsp;</td>
		  </tr>
			<tr>
				<td height="20" colspan="3" class="thinborder"><a href="javascript:CreateDuplicate();"><font color="#9900CC">Copy Voucher (Duplicate voucher entries)</font></a></td>
			</tr>
	</table>	
	<%}else{%>
		<a href="javascript:EncodeJV('0');">Manage(Create/Modify) Voucher Entries</a><br><br>
		<a href="javascript:CreateDuplicate();"><font color="#9900CC">Copy Voucher (Duplicate voucher entries)</font></a>
	<%}%>
	</td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr> 
    <td width="6%" height="25">&nbsp;</td>
    <td width="21%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td align="center"><div align="left"><a href="jv_post.jsp">Post/Verify General Journal </a></div></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center"><div align="left"><a href="jv_summary.jsp">View/Print General Journal Summary</a></div></td>
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
