<%@ page language="java" import="utility.*, Accounting.SalesPayment, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<title>Validation Page</title>
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function Validate(){
		document.form_.validate.value = "1";
		document.form_.submit();
	}
	
	function MapInvoiceNo() {
		var strInvoiceNo = document.form_.invoice_search.value;		
		var objInvoiceInput = document.getElementById("invoice_info");
		
		if(strInvoiceNo.length <=2) {
			objInvoiceInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objInvoiceInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
			
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20003&for_payment=1&invoice_no="+escape(strInvoiceNo);
		this.processRequest(strURL);
	}
	
	function updateInvoiceNo(strInvoiceIndex, strInvoiceNo){
		var strInvoiceList = document.form_.invoice_list.value;
		if(strInvoiceList.length == 0) 
			strInvoiceList = strInvoiceNo;
		else if(strInvoiceList.indexOf(strInvoiceNo) > -1){
			document.getElementById("invoice_info").innerHTML = "";
			return;
		}
		else 	
			strInvoiceList += ", "+strInvoiceNo;
		
		document.form_.invoice_list.value = strInvoiceList;
		document.getElementById("invoice_info").innerHTML = "";
	}
	
	function MapSOANo() {
		var strSANum = document.form_.soa_search.value;		
		var objSOAInput = document.getElementById("soa_info");
		
		if(strSANum.length <=2) {
			objSOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objSOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
			
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20004&for_payment=1&sa_num="+escape(strSANum);
		this.processRequest(strURL);
	}
	
	function updateSANumber(strEntryIndex, strSANum){
		var strSOAList = document.form_.soa_list.value;
		if(strSOAList.length == 0) 
			strSOAList = strSANum;
		else if(strSOAList.indexOf(strSANum) > -1){
			document.getElementById("soa_info").innerHTML = "";
			return;
		}
		else 	
			strSOAList += ", "+strSANum;
		
		document.form_.soa_list.value = strSOAList;
		document.getElementById("soa_info").innerHTML = "";
	}
	
	function MapDCNumber(){
		var strDCNumber = document.form_.dc_search.value;		
		var objDCInput = document.getElementById("dc_info");
		
		if(strDCNumber.length <=2) {
			objDCInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objDCInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
			
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20009&for_payment=1&dc_number="+escape(strDCNumber);
		this.processRequest(strURL);
	}
	
	function updateDCNumber(strDCIndex, strDCNumber){
		var strDCList = document.form_.dc_list.value;
		if(strDCList.length == 0) 
			strDCList = strDCNumber;
		else if(strDCList.indexOf(strDCNumber) > -1){
			document.getElementById("dc_info").innerHTML = "";
			return;
		}
		else 	
			strDCList += ", "+strDCNumber;
		
		document.form_.dc_list.value = strDCList;
		document.getElementById("dc_info").innerHTML = "";
	}
	
	function FocusField(){
		document.form_.invoice_list.focus();
	}
	
	function InputRange(strFieldName){
		var newIntVal = "";
		var lastChar;
		
		var vStart = prompt("Input starting number: ", "");
		if(vStart.length == 0)
			return;
		for(i = 0; i < vStart.length; ++i) {
			lastChar = 	vStart.charAt(i);
			if(lastChar == '0' || lastChar == '1' || lastChar == '2' || lastChar == '3' || 
				lastChar == '4' || lastChar == '5' || lastChar == '6' || lastChar == '7' || 
				lastChar == '8' || lastChar == '9') 
					newIntVal += lastChar;
			else{
				alert("Invalid start number.");
				return;
			}
		}
		vStart = newIntVal;
		
		newIntVal = "";
		var vEnd = prompt("Input end number: ", "");
		if(vEnd.length == 0)
			return;
		for(i = 0; i < vEnd.length; ++i) {
			lastChar = 	vEnd.charAt(i);
			if(lastChar == '0' || lastChar == '1' || lastChar == '2' || lastChar == '3' || 
				lastChar == '4' || lastChar == '5' || lastChar == '6' || lastChar == '7' || 
				lastChar == '8' || lastChar == '9' ) 
					newIntVal += lastChar;
			else{
				alert("Invalid end number.");
				return;
			}
		}
		vEnd = newIntVal;
		
		if(eval(vStart) >= eval(vEnd)){
			alert("Invalid range specified.");
			return;
		}
		
		var strList = eval('document.form_.'+strFieldName+'.value');
		for(var i = vStart; i <= vEnd; i++){
			if(strList.indexOf(""+i) == -1){
				if(strList.length == 0)
					strList = i;
				else
					strList += ", "+i;
			}
		}
		eval('document.form_.'+strFieldName+'.value="'+strList+'"');
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
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
								"ACCOUNTING-BILLING","validate_payment.jsp");
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
	
	double dAmount = 0d;
	Vector vSOA = null;
	Vector vInvoice = null;
	Vector vRetResult = null;
	Vector vDetails = null;
	String strCustomerIndex = null;
	String strCurrencyIndex = null;
	SalesPayment sp = new SalesPayment();
	
	if(WI.fillTextValue("validate").length() > 0){
		vRetResult = sp.validateInvoiceSOANumbers(dbOP, request);
		if(vRetResult == null)
			strErrMsg = sp.getErrMsg();
		else{%>
			<jsp:forward page="./payment.jsp" />
		<% return;
		}
	}
%>
<body bgcolor="#D2AE72" onload="FocusField();">
<form name="form_" action="validate_payment.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>::::  SALES PAYMENT::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
		    <td width="17%">Invoice No.: </td>
		    <td width="80%">
				<textarea name="invoice_list" style="font-size:12px" cols="70" rows="4" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox" 
					onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("invoice_list")%></textarea>
				<a href="javascript:InputRange('invoice_list');" style="text-decoration:none">Input Range</a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Invoice Search:</td>
			<td>
				<input type="text" name="invoice_search" class="textbox" size="16"
	  				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  				onkeyUP="MapInvoiceNo();">&nbsp;&nbsp;&nbsp;
				<label id="invoice_info" style="font-size:11px;position:absolute;width:300px"></label></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
		    <td width="17%">SOA No.: </td>
		    <td width="80%">
				<textarea name="soa_list" style="font-size:12px" cols="70" rows="4" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox" 
					onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("soa_list")%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>SOA Search:</td>
			<td>
				<input type="text" name="soa_search" class="textbox" size="16"
	  				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  				onkeyUP="MapSOANo();">&nbsp;&nbsp;&nbsp;
				<label id="soa_info" style="font-size:11px;position:absolute;width:300px"></label></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
		    <td width="17%">D/C Number: </td>
		    <td width="80%">
				<textarea name="dc_list" style="font-size:12px" cols="70" rows="4" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox" 
					onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("dc_list")%></textarea>
				<a href="javascript:InputRange('dc_list');" style="text-decoration:none">Input Range</a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>D/C Search :</td>
			<td>
				<input type="text" name="dc_search" class="textbox" size="16"
	  				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  				onkeyUP="MapDCNumber();">&nbsp;&nbsp;&nbsp;
				<label id="dc_info" style="font-size:11px;position:absolute;width:300px"></label></td>
		</tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
			<td><a href="javascript:Validate();"><img src="../../../images/form_proceed.gif" border="0" /></a></td>
		</tr>
	</table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="validate" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
