<%@ page language="java" import="utility.*,Accounting.SalesPayment,Accounting.SOAManagement,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Sales Payment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
	a{
		text-decoration:none
	}
</style>
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function ViewSOAInfo(strSANum){
		var pgLoc = "../SOA/view_SOA_info.jsp?sa_num="+strSANum;
		var win=window.open(pgLoc,"ViewSOAInfo",'width=700,height=500,top=30,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function UpdateForex(){
		var pgLoc = "./sales_exchange_rate.jsp?opner_form_name=form_&is_forwarded=1";
		var win=window.open(pgLoc,"UpdateForex",'width=700,height=500,top=30,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function PlaceCheckAmount(strInfoIndex){
		var vCheckCSV = document.form_.check_csv.value;
		var pgLoc = "./check_detail.jsp?opner_form_name=form_&check_csv="+vCheckCSV;
		if(strInfoIndex.length > 0)
			pgLoc += "&info_index="+strInfoIndex;
		var win=window.open(pgLoc,"PlaceCheckAmount",'width=700,height=500,top=30,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function ReloadPageCheck(strCheckCSV){		
		document.form_.check_csv.value = strCheckCSV;
		document.form_.submit();
	}
	
	function AjaxMapSANumber() {
		var strCustCode = document.form_.sa_num.value;
		var objCOAInput = document.getElementById("coa_info");
		if(strCustCode.length < 3) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
			if(this.xmlHttp == null) {
				alert("Failed to init xmlHttp.");
				return;
			}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20004&sa_num="+escape(strCustCode);
		this.processRequest(strURL);
	}

	function updateSANumber(strEntryIndex, strSANumber){
		document.form_.sa_num.value = strSANumber;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.sa_num.focus();
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function DeletePayment(strInfoIndex){
		if(!confirm("Are you sure you want to delete SOA payment?")){
			return;
		}
		
		document.form_.info_index.value = strInfoIndex;
		document.form_.delete_payment.value = "1";
		document.form_.submit();
	}
	
	function PageAction(strPageAction, strInfoIndex){
		if(document.form_.or_number.value.length == 0){
			alert("Please provide or number.");
			return;
		}
		
		if(document.form_.payment_date.value.length == 0){
			alert("Please provide payment date.");
			return;
		}
		
		if(document.form_.debit.value.length == 0){
			alert("Please provide debit COA.");
			return;
		}
		
		if(document.form_.credit.value.length == 0){
			alert("Please provide credit COA.");
			return;
		}
	
		var sum = 0;
		var vPayableAmt = document.form_.payable_amt.value;
		
		var vCashAmt = document.form_.cash_amt.value;
		if(vCashAmt.length == 0)
			vCashAmt = 0;
		
		var vChkAmt = document.form_.chk_amt.value;
		if(vChkAmt.length == 0)
			vChkAmt = 0;
		
		sum = eval(vCashAmt) + eval(vChkAmt);
		
		if(eval(vPayableAmt) != eval(sum)){
			alert("Total amount must be equal to invoice/soa amount.");
			return;
		}

		document.form_.page_action.value = strPageAction;
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	var objCOA;
	var objCOAInput;
	function MapCOAAjax(strFieldName, strLabelID) {
		objCOA=document.getElementById(strLabelID);
		var strCompleteName = eval("document.form_."+strFieldName+".value");
		eval('objCOAInput=document.form_.'+strFieldName);
		if(strCompleteName.length <= 2) {
			objCOA.innerHTML = "";
			return ;
		}		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
	
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name="+strFieldName;
		this.processRequest(strURL);
	}
	
	function COASelected(strAccountName, objParticular) {
		objCOA.innerHTML = "";
	}
	
	///use ajax to update voucher date and voucher number.
	function UpdateInfo(strIndex) {
		//do nothing..
	}
	
</script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BUDGET"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BUDGET","SOA_payment.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	boolean bolIsPaid = false;
	Vector vEditInfo = null;
	Vector vRetResult = null;
	Vector vSOAInfo = null;
	SOAManagement soa = new SOAManagement();
	SalesPayment sp = new SalesPayment();
	
	String strORNumber = null;
	String strIsReloaded = WI.fillTextValue("is_reloaded");
	String strCheckCSV = WI.fillTextValue("check_csv");
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(!sp.operateOnInvoiceSOAPayment(dbOP, request, Integer.parseInt(strTemp)))
			strErrMsg = sp.getErrMsg();
		else{
			if(strTemp.equals("1"))
				strErrMsg = "SOA payment recorded successful.";
			if(strTemp.equals("2"))
				strErrMsg = "SOA payment edited successfully.";
				
			strIsReloaded = "";				
			strCheckCSV = "";
		}
	}
	
	if(WI.fillTextValue("delete_payment").length() > 0){
		if(!sp.deleteInvoiceSOAPayment(dbOP, request))
			strErrMsg = sp.getErrMsg();
		else{
			strCheckCSV = "";
			strErrMsg = "Payment deleted successfully.";			
		}
	}
	
	if(WI.fillTextValue("sa_num").length() > 0){
		vSOAInfo = soa.getSOAInformation(dbOP, request);
		if(vSOAInfo == null)
			strErrMsg = soa.getErrMsg();
		else{
			strTemp = (String)vSOAInfo.elementAt(15);
			if(strTemp != null)
				bolIsPaid = true;
			
			strORNumber = sp.generateORNumber(dbOP, request);
			if(strORNumber == null && WI.fillTextValue("page_action").length() == 0)
				strErrMsg = sp.getErrMsg();

				
			if(bolIsPaid){
				vRetResult = sp.getSOAPaymentInfo(dbOP, request);
				if(vRetResult == null)
					strErrMsg = sp.getErrMsg();
			}
		}
	}
%>
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" action="./SOA_payment.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SOA PAYMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">S/A No: </td>
			<td width="20%">
				<input name="sa_num" type="text" size="16" value="<%=WI.fillTextValue("sa_num")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapSANumber();">
			<td width="60%" valign="top"><label id="coa_info" style="position:absolute; width:300px"></label></td>
		</tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
		    <td colspan="3">
				<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to view SOA info.</font></td>
	    </tr>
	</table>

<%if(vSOAInfo != null && vSOAInfo.size() > 0){%>
	<input type="hidden" name="payment_for" value="0">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="5"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25" colspan="5"><u><strong>SOA DETAILS</strong></u></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="17%">S/A Number: </td>
		    <td><%=(String)vSOAInfo.elementAt(1)%></td>
		    <td>Date:</td>
		    <td><%=(String)vSOAInfo.elementAt(2)%></td>
		    <input type="hidden" name="entry_index" value="<%=(String)vSOAInfo.elementAt(0)%>" />
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Type:</td>
		    <td width="30%"><%=(String)vSOAInfo.elementAt(4)%></td>
		    <td width="17%">Currency:</td>
		    <td width="33%"><%=(String)vSOAInfo.elementAt(26)%> (<%=(String)vSOAInfo.elementAt(18)%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Amount:	</td>
		    <td>
				<%
					strTemp = CommonUtil.formatFloat((String)vSOAInfo.elementAt(16), false);
					strErrMsg = ConversionTable.replaceString(strTemp, ",", "");
				%>
				<input type="hidden" name="payable_amt" value="<%=strErrMsg%>">
				<%=(String)vSOAInfo.elementAt(18)%><%=strTemp%></td>
		    <td>Details:</td>
		    <td><a href="javascript:ViewSOAInfo('<%=(String)vSOAInfo.elementAt(1)%>');">VIEW</a></td>
		</tr>
		<tr>
			<td height="15" colspan="5"><hr size="1" /></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="5"><u><strong>PAYMENT DETAILS</strong></u></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>OR Number: </td>
			<td>
				<%
					if(vRetResult != null && vRetResult.size() > 0 && strIsReloaded.length() == 0)
						strORNumber = (String)vRetResult.elementAt(7);
					else{
						if(strErrMsg != null && strORNumber == null)
							strORNumber = WI.fillTextValue("or_number");
					}					
				%>
				<input name="or_number" type="text" size="24" maxlength="24" class="textbox" 
					value="<%=WI.getStrValue(strORNumber,"")%>" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'"></td>
		    <td width="17%">Date:</td>
		    <td width="33%">
				<%
					if(vRetResult != null && vRetResult.size() > 0 && strIsReloaded.length() == 0)
						strTemp = (String)vRetResult.elementAt(8);
					else
						strTemp = WI.fillTextValue("payment_date");
				%>
				<input name="payment_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.payment_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="17%">Cash:</td>
		    <td width="30%">
				<%
					if(vRetResult != null && vRetResult.size() > 0 && strIsReloaded.length() == 0){
						strTemp = (String)vRetResult.elementAt(3);
						if(Double.parseDouble(strTemp) == 0)
							strTemp = "";
						else{
							strTemp = CommonUtil.formatFloat(strTemp, false);
							strTemp = ConversionTable.replaceString(strTemp, ",", "");
						}
					}
					else
						strTemp = WI.fillTextValue("cash_amt");
				%>
				<input type="text" name="cash_amt" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="AllowOnlyFloat('form_','cash_amt');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','cash_amt')" size="16" maxlength="16" 
					value="<%=strTemp%>"/></td>
		    <td>&nbsp;</td>
	        <td><a href="javascript:UpdateForex();"><strong>UPDATE EXCHANGE RATE</strong></a><a href="javascript:GetExchangeRate();"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Check:</td>
		    <td>
				<%
					if(vRetResult != null && vRetResult.size() > 0 && strIsReloaded.length() == 0){
						strTemp = (String)vRetResult.elementAt(4);
						if(Double.parseDouble(strTemp) == 0)
							strTemp = "";
						else{
							strTemp = CommonUtil.formatFloat(strTemp, false);
							strTemp = ConversionTable.replaceString(strTemp, ",", "");
						}
						
						strCheckCSV = (String)vRetResult.elementAt(16);
					}
					else
						strTemp = WI.fillTextValue("chk_amt");
				%>
				<input type="text" name="chk_amt" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="AllowOnlyFloat('form_','chk_amt');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','chk_amt')" size="16" maxlength="16" 
					value="<%=strTemp%>"/>
				&nbsp;&nbsp;
				<%
					if(vRetResult != null && vRetResult.size() > 0 && strIsReloaded.length() == 0)
						strTemp = (String)vRetResult.elementAt(0);		
					else
						strTemp = "";
				%>
				<a href="javascript:PlaceCheckAmount('<%=strTemp%>');">UPDATE</a></td>
		    <td colspan="2">&nbsp;</td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Debit:</td>
		    <td>
				<%
					if(vRetResult != null && vRetResult.size() > 0 && strIsReloaded.length() == 0)
						strTemp = (String)vRetResult.elementAt(13);
					else
						strTemp = WI.fillTextValue("debit");
				%>
				<input name="debit" type="text" size="16" value="<%=strTemp%>"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="MapCOAAjax('debit','debit_');" class="textbox"></td>
		    <td colspan="2" valign="top"><label id="debit_" style="font-size:11px;position:absolute;width:300px"></label></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Credit:</td>
		    <td>
				<%
					if(vRetResult != null && vRetResult.size() > 0 && strIsReloaded.length() == 0){
						strTemp = (String)vRetResult.elementAt(12);
						strIsReloaded = "1";
					}
					else
						strTemp = WI.fillTextValue("credit");
				%>
				<input name="credit" type="text" size="16" value="<%=strTemp%>"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="MapCOAAjax('credit','credit_');" class="textbox"></td>
		    <td colspan="2" valign="top"><label id="credit_" style="font-size:11px;position:absolute;width:300px"></label></td>
	    </tr>
		<tr>
			<td height="50" colspan="5" align="center" valign="middle">
			<%if(iAccessLevel > 1){
				if(!bolIsPaid){%>				
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save invoice payment transaction.</font>
				    <%}else{%>
					<a href="javascript:PageAction('2', '<%=(String)vRetResult.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<font size="1">Click to edit invoice payment information.</font>
				    <%}
			}else{%>
				Not authorized for payment transaction.
			<%}%></td>
		</tr>
	</table>
	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="8" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: PAYMENT INFORMATION :::  </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="12%" align="center" class="thinborder"><strong>Date Paid </strong></td>
			<td width="16%" align="center" class="thinborder"><strong>OR Number </strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Cash Amt </strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Check Amt </strong></td>
			<td width="19%" align="center" class="thinborder"><strong>Debit</strong></td>
			<td width="19%" align="center" class="thinborder"><strong>Credit</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Delete</strong></td>
		</tr>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(8)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(7)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(3);
				if(Double.parseDouble(strTemp) == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(strTemp, false);
			%>
			<td class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(4);
				if(Double.parseDouble(strTemp) == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(strTemp, false);
			%>
			<td class="thinborder"><%=strTemp%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(13)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(12)%></td>
			<td align="center" class="thinborder">
				<a href="javascript:DeletePayment('<%=(String)vRetResult.elementAt(0)%>')">
			<img src="../../../images/delete.gif" border="0"></a></td>
		</tr>
	</table>
	<%}
}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="is_reloaded" value="<%=strIsReloaded%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="delete_payment">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">	
	<input type="hidden" name="check_csv" value="<%=strCheckCSV%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>