<%@ page language="java" import="utility.*,Accounting.Transaction,java.util.Vector" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function EncodePC() {
	strJVNumber = prompt('To edit or view detail, enter PC number.','');
	if(strJVNumber == null)
		strJVNumber = "";
	location = "../journal_voucher/journal_voucher_entry.jsp?jv_number="+strJVNumber+"&jv_type=0&is_cd=2";
}
</script>
<body bgcolor="#D2AE72">
<%		
	WebInterface WI = new WebInterface(request);
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
DBOperation dbOP = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-ACCOUNTING-TRANSACTION-main petty cash","petty_cash.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authentication code.									
	
	Transaction PTCash = new Transaction();
	Vector vRetResult = null;		
	String strTemp = null;
	double dMinAmount = 0d;
	double dWarnAmount = 0d;
	double dCurrentBal = 0d;

	vRetResult = PTCash.operateOnMinMaxPettyCash(dbOP,request,4);
	if (vRetResult != null && vRetResult.size() > 0){
		strTemp = (String)vRetResult.elementAt(0);
		strTemp = WI.getStrValue(strTemp,"0");
		dMinAmount = Double.parseDouble(strTemp);		
		strTemp = (String)vRetResult.elementAt(2);
		strTemp = WI.getStrValue(strTemp,"0");
		dWarnAmount = Double.parseDouble(strTemp);		
		strTemp = (String)vRetResult.elementAt(4);
		strTemp = WI.getStrValue(ConversionTable.replaceString(strTemp,",",""),"0");
		dCurrentBal = Double.parseDouble(strTemp);		
	}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: PETTY CASH PAGE ::::</strong></font></div></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td width="5%" height="25">&nbsp;</td>
    <td width="12%" height="25" align="right"><div align="left">Operation : </div></td>
    <td align="center"><div align="left"><a href="petty_cash_setup_amount.jsp">Set 
        Maximum/Minimum Petty Cash Fund Amount</a> </div></td>
  </tr>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td width="83%">
	<!--<a href="petty_cash_encode.jsp">Create 
        Petty Cash Voucher </a>&nbsp;&nbsp;-->
		<a href="javascript:EncodePC();">Create Petty Cash Voucher</a></td>
  </tr>
  <tr> 
    <td width="5%" height="25">&nbsp;</td>
    <td width="12%" height="25">&nbsp;</td>
    <td><!--<a href="petty_cash_update_payment_stat.jsp" target="_self">Update Petty Cash Voucher Payment Status </a>&nbsp;&nbsp; -->
	<a href="./pc_update_payment_stat_new.jsp">Update Petty Cash Voucher Payment Status</a></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="petty_cash_create_req.jsp" target="_self">Create requisition 
      for reimbursement</a></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td ><a href="petty_cash_reimbursement.jsp" target="_self">Receive Reimbursement</a></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td><a href="petty_cash_summary.jsp">View/Print Petty Cash Fund</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td><a href="./reports/petty_cash_detail.jsp">View/Print Petty Cash Detail</a></td>
  </tr>
  <%}%>
  <tr>
    <td height="18">&nbsp;</td>
    <td height="18">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr> 
    <td height="18">&nbsp;</td>
    <td height="18">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){
	strTemp = "";	
	if(dCurrentBal <= dWarnAmount){
		strTemp = "PETTY CASH FUND IS ALREADY LOW";
	}
	
	if(dCurrentBal <= dMinAmount){
		strTemp = "PETTY CASH FUND BELOW MINIMUM AMOUNT, PLEASE REQUEST REPLENISHMENT.";
	}
	if(dCurrentBal == 0d){
		strTemp = "PETTY CASH FUND ZERO BALANCE";
	}	
	%>
<%if (strTemp.length() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="17%" height="18">&nbsp;</td>
    <td width="83%" height="18"><font color="#FF0000" size="3"><strong><u>NOTICE/WARNING : 
      </u></strong></font> <div align="left"> </div>
      <div align="left"><strong></strong></div></td>
  </tr>
  <tr> 
    <td height="34">&nbsp;</td>
    <td height="34"><div align="center"><strong><font color="#660099" size="3"><%=strTemp%></font></strong></div></td>
  </tr>
</table>
<%}%>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A"> 
    <td width="50%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

</body>
</html>
<%
dbOP.cleanUP();
%>