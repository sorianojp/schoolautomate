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
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function EncodeCD(strJVType) {
	strJVNumber = prompt('To edit or view detail, enter CD number.','');
	if(strJVNumber == null)
		strJVNumber = "";
	location = "../journal_voucher/journal_voucher_entry.jsp?jv_number="+escape(strJVNumber)+"&jv_type="+strJVType+"&is_cd=1";
}
function CreateDuplicate() {
	var pgLoc = "./duplicate_voucher.jsp?is_cd=1";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=400,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
         DISBURSEMENT VOUCHER PAGE ::::</strong></font></div></td>
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
    <td width="11%" height="25">&nbsp;</td>
    <td width="9%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="78%"><a href="#" style="text-decoration:none">Encode/Modify Voucher Entries</a></td>
  </tr>
  
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>
		<table border="0" cellpadding="0" cellspacing="0" class="thinborder" width="90%">
			<tr>
				<td class="thinborder" width="26%" height="20"><a href="javascript:EncodeCD('10');"><font color="#000000">Others</font></a></td>
				<td width="23%" class="thinborder"><a href="javascript:EncodeCD('11');"><font color="#000000">Petty Cash </font></a></td>
			    <td width="51%" class="thinborder">
					<a href="javascript:EncodeCD('8');"><font color="#000000">Student Refund</font></a>				
				</td>
			</tr>
			<tr>
			  <td height="20" colspan="3" class="thinborder">
					<a href="javascript:CreateDuplicate();"><font color="#9900CC">Copy Voucher (Duplicate voucher entries)</font></a>
			  </td>
		  </tr>
	</table>	</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr> 
    <td width="11%" height="25">&nbsp;</td>
    <td width="9%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td><a href="cdv_update_payment_stat.jsp">Update Disbursement Voucher Payment Status (Cashier)</a></td>
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
    <td><a href="cancel_cd_check.jsp">Encode Cancelled CD/CV and/or Check</a></td>
  </tr>
  
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./cd_summary.jsp">View/Print Disbursement Voucher Summary</a></td>
  </tr>
<%
//utility.DBOperation dbOP = new utility.DBOperation();
//String strSQLQuery = dbOP.readProperty("AC_CD_LOCK_SETTING"); 
//dbOP.cleanUP();
//if(strSQLQuery != null && strSQLQuery.equals("2")){
if(true) {%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./lock_cd.jsp">Lock Disbursement Voucher Manually</a></td>
  </tr>
<%}%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
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
