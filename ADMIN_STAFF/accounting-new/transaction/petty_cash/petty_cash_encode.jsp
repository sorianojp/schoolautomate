<%@ page language="java" import="utility.*, Accounting.Transaction, java.util.Vector"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function UpdatePayeeType() {
	var pgLoc = "./payee_encode.jsp";
	var win=window.open(pgLoc,"EncodePettyCash",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateChargeTo(strPCIndex,strTotalAmount) {
	var pgLoc = "./charged_to_encode.jsp?pc_index="+strPCIndex+"&total_amount="+strTotalAmount;
	var win=window.open(pgLoc,"EncodeChargeTo",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function CopyPreparedBy(){
	document.form_.prepared_by.value = document.form_.prepared_select[document.form_.prepared_select.selectedIndex].text;
}
function CopyCheckedBy(){
	document.form_.checked_by.value = document.form_.checked_select[document.form_.checked_select.selectedIndex].text;
}
function CopyApprovedBy(){
	document.form_.approved_by.value = document.form_.approved_select[document.form_.approved_select.selectedIndex].text;
}

function PrintPg(){
	document.form_.print_pg.value = '1';
	this.SubmitOnce('form_');
}
function searchVoucher() {
	var pgLoc = "./petty_cash_summary.jsp?opner_info=form_.voucher_no";
	var win=window.open(pgLoc,"SearchWindow",'width=700,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	if(WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="petty_cash_print.jsp"/>
	<%}
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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-DTR Entry (Manual)","dtr_manual.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}

	Transaction transaction = new Transaction();
	String strPageAction = WI.fillTextValue("page_action");
	String strPCIndex = null;
	String strProceedClicked = WI.getStrValue(WI.fillTextValue("proceedClicked"),"0");
	String strPrepareToEdit = "0";
	String strAmount = "";
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vChargedTo = null;

	boolean bolIsEditAllowed = true; //do not allow if posted already.



	if(strPageAction.length() > 0){
		vRetResult =  transaction.operateOnPettyCashEntry(dbOP,request,Integer.parseInt(strPageAction));
	  if(vRetResult == null){
	  	strErrMsg  =  transaction.getErrMsg();
	  }else{
		 strErrMsg = "Operation Successful";
	  	if (strPageAction.equals("1"))
			strPCIndex = (String) vRetResult.elementAt(1);
		request.setAttribute("voucher_no",vRetResult.elementAt(0));
	  }
	}

  	  if(WI.fillTextValue("voucher_no").length() > 0 || vRetResult != null){
		vEditInfo =  transaction.operateOnPettyCashEntry(dbOP,request,3);
		if (vEditInfo != null){
			strPCIndex = (String) vEditInfo.elementAt(0);
			strAmount = (String) vEditInfo.elementAt(6);
			strPrepareToEdit = "1";
			vChargedTo = transaction.operateOnChargeTo(dbOP,request,4,strPCIndex);
			if(vEditInfo.elementAt(11).equals("1"))
				bolIsEditAllowed = false;
		}
	  }


%>
<form name="form_" method="post" action="./petty_cash_encode.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<%if (vEditInfo != null && vEditInfo.size() > 0){%>
	<input type="hidden" name="pc_voucher_stat" value="<%=(String)vEditInfo.elementAt(11)%>">
	<%}%>
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          PETTY CASH VOUCHER ENTRY - DETAILS ENCODING PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold">
	  <%if(WI.fillTextValue("from_main").length() == 0){%>
	  <a href="petty_cash.jsp"><img src="../../../../images/go_back.gif" border="0"></a>
	  <%}%>
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="27">&nbsp;</td>
      <td width="17%">Voucher No.</td>
	  <%if(strPageAction.equals("1") && vRetResult != null)
	  		strTemp = (String)vRetResult.elementAt(0);
	    else if(WI.fillTextValue("voucher_no").length() > 0)
	  		strTemp = WI.fillTextValue("voucher_no");
	  	else
			strTemp = "";
	  %>
      <td width="24%"><input name="voucher_no" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1"><a href="javascript:searchVoucher();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></font></td>
      <td width="55%"><font size="1"><a href="javascript:ProceedClicked();"><img src="../../../../images/form_proceed.gif" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="27" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <%if(strProceedClicked.equals("1")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="22">&nbsp;</td>
      <td>Requisition No.</td>
      <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
		else
		  	strTemp = WI.fillTextValue("req_no");
	  %>
      <td><input name="req_no" type="text" size="16" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td width="4%" height="22">&nbsp;</td>
      <td width="17%" height="22">Voucher Date</td>
      <%if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
		else if(WI.fillTextValue("voucher_date").length() > 0)
		  	strTemp = WI.fillTextValue("voucher_date");
		else
			strTemp = WI.getTodaysDate(1);
	  %>
      <td width="79%" height="22"> <input name="voucher_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.voucher_date');" title="Click to select date"
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
        <img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Payee</td>
      <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(10);
		else
	  		strTemp = WI.fillTextValue("payee");
	  %>
      <td><select name="payee">
          <option value="">Select payee</option>
          <%=dbOP.loadCombo("payee_type_index","payee_name"," from ac_pcv_payeetype where hide_dropdown = 0 order by payee_name asc", strTemp, false)%> </select> <font size="1"><a href="javascript:UpdatePayeeType();"><img src="../../../../images/update.gif" border="0"></a>
        Update Payee list </font></td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Explanation(s)</td>
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(5);
		else
	  		strTemp = WI.fillTextValue("explanation");
	  %>
      <td width="79%"><textarea name="explanation" cols="70" rows="3" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" class="textbox" style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td  width="4%"height="34">&nbsp;</td>
      <td width="17%">Amount </td>
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
		else
		  	strTemp = WI.fillTextValue("amount");
	  %>
      <td><strong><font size="1">
        <input name="amount" type="text" size="16" maxlength="16" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=CommonUtil.formatFloat(WI.getStrValue(strTemp,"0"),true)%>"
	  onKeyUp="AllowOnlyFloat('form_','amount');"
	  onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'">
        </font></strong></td>
    </tr>
	<%if(strPCIndex != null && strPCIndex.length() > 0 && strPrepareToEdit.equals("1")){%>
    <tr>
      <td height="28">&nbsp;</td>
      <td>Charged to </td>
      <td>
	  <%if(bolIsEditAllowed) {%>
	  <font size="1"><a href="javascript:UpdateChargeTo('<%=strPCIndex%>','<%=WI.getStrValue(strAmount,WI.fillTextValue("amount"))%>');"><img src="../../../../images/update.gif" border="0"></a></font>
        click to update list of Fund(s) to be Charged <%}else {%>
		<font style="font-size:11px; color:#FF0000; font-weight:bold">Update not allowed</font><%}%></td>
    </tr>
	<%if(vChargedTo!= null && vChargedTo.size() > 0){%>
    <tr>
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">
	  <table width="68%" border="1" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
		  <%for(int i = 0; i < vChargedTo.size() ; i +=4){%>
          <tr>
            <td width="74%" height="20"><strong><%=(String)vChargedTo.elementAt(i+1)%>
              :: <%=(String)vChargedTo.elementAt(i+2)%></strong></td>
            <td width="26%" height="20"><div align="right"><strong>&nbsp;<%=CommonUtil.formatFloat((String)vChargedTo.elementAt(i+3),true)%>&nbsp;</strong></div></td>
          </tr>
		  <%}%>
        </table>      </td>
    </tr>
	<%}// end if vChargedTo != null%>
	<%}%>
    <tr>
      <td height="33">&nbsp;</td>
      <td height="33">Prepared by</td>
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
		else
		  	strTemp = WI.fillTextValue("prepared_by");
	  %>
      <td height="33">
	  <input name="prepared_by" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="40" maxlength="128"
	  onKeyUp = "AutoScrollList('form_.prepared_by','form_.prepared_select',true);" >      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><select name="prepared_select" onChange="CopyPreparedBy();" onFocus="CopyPreparedBy();">
	  <%=dbOP.loadCombo("distinct PREPARED_BY","PREPARED_BY"," from AC_PC_VOUCHER order by AC_PC_VOUCHER.PREPARED_BY",null,false)%>
        </select>      </td>
    </tr>
    <tr>
      <td height="32">&nbsp;</td>
      <td height="32">Checked by</td>
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(8);
		else
		  	strTemp = WI.fillTextValue("checked_by");
	  %>
      <td height="32"><input name="checked_by" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=strTemp%>" size="40" maxlength="128"
	  onKeyUp = "AutoScrollList('form_.checked_by','form_.checked_select',true);">      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><select name="checked_select" onChange="CopyCheckedBy();" onFocus="CopyCheckedBy();">
	  <%=dbOP.loadCombo("distinct checked_by","checked_by"," from AC_PC_VOUCHER order by AC_PC_VOUCHER.checked_by",null,false)%>
        </select>      </td>
    </tr>
    <tr>
      <td height="33">&nbsp;</td>
      <td height="33">Approved for Payment</td>
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(9);
		else
		  	strTemp = WI.fillTextValue("approved_by");
	  %>
      <td height="33"><input name="approved_by" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   value="<%=strTemp%>" size="40" maxlength="128"
	   onKeyUp = "AutoScrollList('form_.approved_by','form_.approved_select',true);">      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">
	  <select name="approved_select" onChange="CopyApprovedBy();" onFocus="CopyApprovedBy();">
		<%=dbOP.loadCombo("distinct approved_by","approved_by"," from AC_PC_VOUCHER order by AC_PC_VOUCHER.approved_by",null,false)%>
      </select>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="50">&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1">
		<%if(!strPrepareToEdit.equals("1")){%>
		<a href="javascript:PageAction(1,'');"><img src="../../../../images/save.gif" border="0"></a>
        click to save entry
		<%}else{
			if(bolIsEditAllowed) {%>
			<a href="javascript:PageAction(2,'')"><img src="../../../../images/edit.gif" border="0"></a>
        	click to save changes<%}else{%>
				<font style="font-size:11px; color:#FF0000; font-weight:bold">Update not allowed</font><%}
		}%>

		<a href="petty_cash_encode.jsp?from_main="+<%=WI.fillTextValue("from_main")%>><img src="../../../../images/cancel.gif" border="0"></a>click
        to cancel/clear entries </font></td>
    </tr>
	<%if(strPrepareToEdit.equals("1")){%>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="left"><font size="1"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>click
          to print Petty Cash Voucher </font></div></td>
    </tr>
	<%}%>
	<!--
    <tr>
      <td width="4%" height="159"><div align="left"></div></td>
      <td height="159" colspan="2"><p>NOTE: Charged to max prinout in the preformated voucher
          are only 2, excess to this is printed on another sheet.<br>
          * If Charged to exceeds 2, then print in the Charged to &quot;POST FROM
          LIST&quot;<br>
          * If Charged to exceeds 2, then display message &quot;INSERT A BLANK
          SHEET AFTER PRINTING PETTY CASH VOUCHER&quot; for details of Charged
          to.<br>
          * The Charged to accounts are not yet recorded to ledger as expense
          at the Petty Cash module, only in the Disbursement when doing Replenishement<br>
          &nbsp;</p></td>
    </tr>
	-->
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="print_pg">
 <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
 <input type="hidden" name="page_action">
 <input type="hidden" name="info_index" value="<%=strPCIndex%>">
 <input type="hidden" name="from_main" value="<%=WI.fillTextValue("from_main")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
