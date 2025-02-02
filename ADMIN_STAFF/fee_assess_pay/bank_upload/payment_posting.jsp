<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payment Posting</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">

	function LoadRange(strUnpostedPayments){
		<%if(strSchCode.startsWith("CIT")){%>
			return;
		<%}%>
		var vORFrom = document.form_.or_from.value;
		if(vORFrom.length == 0){
			document.form_.or_to.value = "";
			return;
		}
		
		var objCOA=document.form_.or_to;
		this.InitXmlHttpObject(objCOA, 1);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20500&or_from="+vORFrom+"&unposted_payments="+strUnpostedPayments;
		this.processRequest(strURL);
	}
	
	function PrintPg(strValidOR){
		var pgLoc = "./payment_posting_print.jsp?valid_or="+strValidOR;	
		var win=window.open(pgLoc,"PrintPg",'width=850,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function MovePayments(){
		document.form_.move_payments.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.move_payments.value = "";
		document.form_.submit();
	}
	
	function ClearFields(){
		document.form_.or_from.value = "";
		document.form_.or_to.value = "";
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation();
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
	
	String strRangeFrom = WI.fillTextValue("or_from");
	String strRangeTo = WI.fillTextValue("or_to");
	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};
	BankPosting bp = new BankPosting();
	
	boolean bolMoveSuccess = false;
	String strValidOR = null;
	if(WI.fillTextValue("move_payments").length() > 0){
		strValidOR = bp.postPayments(dbOP, request);
		if(strValidOR == null)
			strErrMsg = bp.getErrMsg();
		else{
			bolMoveSuccess = true;
			strErrMsg = "Payment(s) posted successfully.";
		}
	}
	
	int iUnpostedPayments = bp.getNumberUnposted(dbOP, request);
	if(iUnpostedPayments < 0){
		iUnpostedPayments = 0;
		strErrMsg = bp.getErrMsg();
	}
	
	Vector vRetResult = null;
	if(iUnpostedPayments > 0 && strRangeFrom.length() > 0 && strRangeTo.length() > 0 && !bolMoveSuccess){
		vRetResult = bp.getUnpostedPayments(dbOP, request);
		if(vRetResult == null)
			strErrMsg = bp.getErrMsg();
	}
%>
<body bgcolor="#D2AE72">
<form action="payment_posting.jsp" method="post" name="form_">
	<table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A" >
			<td height="25" colspan="3">
				<div align="center"><font color="#FFFFFF"><strong>:::: PAYMENT POSTING PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	<%if(bolMoveSuccess){%>
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="2">
				<a href="javascript:PrintPg('<%=strValidOR%>');"><img src="../../../images/print.gif" border="0"></a>
				<font size="1">Click to print OR.</font></td>
	    </tr>
	<%}%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Bank: </td>
			<td>
				<select name="bank_index" onChange="ReloadPage();">
					<option value="">All Banks</option>
					<%if(strSchCode.startsWith("CIT")){%>
						<%=dbOP.loadCombo("bank_index","bank_name, bank_code"," from fa_bank_list where is_used_bank_post = 1 order by bank_name", WI.fillTextValue("bank_index"), false)%>
					<%}else{%>
						<%=dbOP.loadCombo("bank_index","bank_name, bank_code"," from fa_upload_bank_list order by bank_name", WI.fillTextValue("bank_index"), false)%>
					<%}%>
          		</select>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date Paid: </td>
			<td>
				<input name="transaction_date" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';" value="<%=WI.fillTextValue("transaction_date")%>" size="10" readonly="yes">
        		<a href="javascript:show_calendar('form_.transaction_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;" tabindex="-1">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				
				to 
				<input name="transaction_date_to" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';" value="<%=WI.fillTextValue("transaction_date_to")%>" size="10" readonly="yes">
        		<a href="javascript:show_calendar('form_.transaction_date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;" tabindex="-1">
				<img src="../../../images/calendar_new.gif" border="0"></a>				</td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Total Unposted Payments:</td>
			<td width="80%"><strong><%=iUnpostedPayments%></strong></td>
		</tr>
	<%if(iUnpostedPayments > 0){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>OR Range: </td>
			<td>
				<input name="or_from" type="text" value="<%=WI.fillTextValue("or_from")%>" class="textbox" size="32" maxlength="32"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="javascript:LoadRange('<%=iUnpostedPayments%>');style.backgroundColor='white'">
				-
				<input name="or_to" type="text" value="<%=WI.fillTextValue("or_to")%>" class="textbox" size="32" maxlength="32" tabindex="-1"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%if(!strSchCode.startsWith("CIT")){%>readonly="yes"<%}%>>
				&nbsp;&nbsp;&nbsp;
				<a href="javascript:ClearFields();" tabindex="-1"><img src="../../../images/clear.gif" border="0"></a>
				<font size="1">Click to clear fields.</font></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td colspan="2">Sort Result By: 
<%
strTemp = WI.fillTextValue("sort_by");
if(strTemp.length() == 0) 
	strTemp = "date_paid";
if(strTemp.equals("lname"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		  <input type="radio" name="sort_by" value="lname" <%=strErrMsg%>> Last name
<%
if(strTemp.equals("date_paid"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		  <input type="radio" name="sort_by" value="date_paid" <%=strErrMsg%>> Date Paid		  </td>
	  </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:ReloadPage();LoadRange('<%=iUnpostedPayments%>')"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to view unposted payment info.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	<%}%>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">
				<a href="javascript:MovePayments();"><img src="../../../images/move.gif" border="0"></a>
				<font size="1">Click to post selected payments.</font>&nbsp;</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="10" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: UNPOSTED PAYMENTS :::</strong></div></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="10%"><strong>ID Number </strong></td>
			<td align="center" class="thinborder" width="8%"><strong>College</strong></td>
		    <td align="center" class="thinborder" width="17%"><strong>Name</strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>SY/Term</strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>Date Paid</strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>Amount</strong></td>
			<td align="center" class="thinborder" width="9%"><strong>Payment Type</strong></td>
			<td align="center" class="thinborder" width="15%"><strong>Failed Reason</strong></td>
			<td align="center" class="thinborder" width="9%"><strong>OR No.</strong></td>
			<td align="center" class="thinborder" width="5%"><strong>Select</strong></td>
		</tr>
	<%	int iCount = 0;
		for(int i = 0; i < vRetResult.size(); i += 15, iCount++){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+11)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%>-<%=Integer.parseInt((String)vRetResult.elementAt(i+5))+1%>/
				<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+6))]%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
		    <td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4), false)%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+3);
				if(strTemp.equals("0"))
					strTemp = "Downpayment";
				else
					strTemp = "Installment";
			%>
			<td class="thinborder">&nbsp;<%=strTemp%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+10)%></td>
		    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+12))%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12));
				if(strTemp.length() > 0)
					strTemp = "checked";
			%>
			<input type="hidden" name="or_num_<%=iCount%>" value="<%=WI.getStrValue((String)vRetResult.elementAt(i+12))%>">
			<input type="hidden" name="user_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
			<input type="hidden" name="semester_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+6)%>">
			<input type="hidden" name="sy_from_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+5)%>">
			<input type="hidden" name="is_temp_stud_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+2)%>">
			<input type="hidden" name="date_receipt_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+7)%>">
			<input type="hidden" name="amount_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+4)%>">
			<input type="hidden" name="payment_for_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+3)%>">
			<%
				if(strTemp.equals("checked"))
					strTemp = (String)vRetResult.elementAt(i);
				else
					strTemp = "";
			%>
			<input type="hidden" name="post_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		    <td align="center" class="thinborder"><%if(strTemp.length() > 0){%><img src="../../../images/tick.gif" border="0"><%}else{%>&nbsp;<%}%></td>
		</tr>
	<%}%>
	</table>
	<input type="hidden" name="max_count" value="<%=iCount%>">
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A">
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="move_payments">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
