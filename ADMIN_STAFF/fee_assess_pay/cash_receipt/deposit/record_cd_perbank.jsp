<%@ page language="java" import="utility.*,Accounting.CashReceiptBook,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this record.'))
				return;
		}
		document.form_.page_action.value = strAction;
		document.form_.info_index.value  = strInfoIndex;
		
		document.form_.reload_parent.value = '0';
		document.form_.submit();
	}
	function ReloadParent() {
		if(document.form_.reload_parent.value == '0')
			return;
		window.opener.document.all.processing.style.visibility='visible';	
		window.opener.document.bgColor = "#DDDDDD";
		window.opener.document.form_.submit();
	}
</script>
<body bgcolor="#D2AE72" onUnload="ReloadParent();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-CASH DEPOSIT-record cash deposit detail","record_cd_perbank.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(),
														null);
}
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
Vector vRetResult = null;
Vector vCDSummary = null;

enrollment.CashDeposit CD = new enrollment.CashDeposit();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(CD.operateOnCashDepositDetail(dbOP, request, Integer.parseInt(strTemp), WI.fillTextValue("ref_")) == null) 
		strErrMsg = CD.getErrMsg();
	else	
		strErrMsg = "Operation successful";
}
vRetResult = CD.operateOnCashDepositDetail(dbOP, request, 4, WI.fillTextValue("ref_"));
if(strErrMsg == null && vRetResult == null)
	strErrMsg = CD.getErrMsg();
if(vRetResult != null && vRetResult.size() > 0) {
	vCDSummary = (Vector)vRetResult.remove(0);
}

%>
<form name="form_" action="./record_cd_perbank.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: CASH DEPOSIT DETAIL INFORMATION ::::</strong></font></div></td>
		</tr>
		<tr>
			<td width="3%" height="20">&nbsp;</td>
			<td width="97%" colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="28">&nbsp;</td>
		  <td colspan="2" style="font-size:14px; font-weight:bold">
		  
		  <u>Total Recoded:  <%=vCDSummary.elementAt(1)%>
		  To Encode: <%=vCDSummary.elementAt(2)%></u>
		  
		  </td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">Amount</td>
		  <td><input type="text" name="amt_" value="<%=WI.fillTextValue("amt_")%>" class="textbox_bigfont" size="14" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  </tr>
		<tr>
			<td width="3%" height="20">&nbsp;</td>
			<td width="15%" style="font-size:11px;">Bank</td>
		    <td width="82%">
	  <select name="bank_index">
      	<%=dbOP.loadCombo("BANK_INDEX","BANK_CODE, BANK_NAME", " from FA_BANK_LIST where is_valid = 1 and is_used_bank_deposit = 1 order by bank_code", request.getParameter("bank_index"), false)%>
      </select>			</td>
		</tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">Deposit Slip# </td>
		  <td>
			<input type="text" name="deposit_slip" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("deposit_slip")%>">		  </td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">Deposit Type </td>
		  <td>
	  <select name="deposit_type">
		<option value="0">CASH</option>
		<option value="1">CHECK</option>
      </select>		  </td>
	  </tr>
		
		
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">Remaks</td>
		  <td>
		  <textarea name="remarks" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			 rows="2" cols="90" style="font-size:9px;"><%=WI.fillTextValue("remarks")%></textarea>		  </td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">&nbsp;</td>
		  <td style="font-size:11px;"><a href="javascript:PageAction('1', '')"><img src="../../../../images/save.gif" border="0"></a></td>
	  </tr>
	</table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" style="font-size:9px; font-weight:bold" align="center">::: BEGINING BALANCE SET UP :::</td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		
		<tr style="font-weight:bold" align="center">
			<td width="5%" height="20" class="thinborder">Count</td>
			<td width="10%" class="thinborder">Bank Code</td>
			<td width="15%" class="thinborder">Bank Name </td>
			<td width="10%" class="thinborder">Deposit Slip </td>
			<td width="10%" class="thinborder">Amount Deposited </td>
			<td width="5%" class="thinborder">Type </td>
		    <td width="40%" class="thinborder">Remarks</td>
		    <!--<td width="7%" class="thinborder">Edit</td>-->
		    <td width="5%" class="thinborder">Delete</td>
		</tr>
	<%	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i += 7) {%>
		<tr>
			<td height="20" align="center" class="thinborder"><%=iCount++%></td>
		    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 1), "&nbsp;")%></td>
		    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 2), "&nbsp;")%></td>
		    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3), "&nbsp;")%></td>
		    <td class="thinborder" align="right"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4), "&nbsp;")%></td>
          <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 5), "&nbsp;")%></td>
		  <!--<td class="thinborder"></td>-->
		  <td class="thinborder">
		  	<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../../images/delete.gif" border="0"></a>		  </td>
		</tr>
	<%}%>
	</table>
<%}%>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20">&nbsp;</td>
		</tr>
		<tr bgcolor="#B8CDD1">
			<td height="20" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>

<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="ref_" value="<%=WI.fillTextValue("ref_")%>">
<input type="hidden" name="reload_parent">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>