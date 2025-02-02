<%@ page language="java" import="utility.*, Accounting.SalesPayment, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsForwarded = WI.fillTextValue("is_forwarded").equals("1");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<title>OR Print</title>
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function AjaxMapORNumber() {
		var strORNumber = document.form_.or_number.value;
		var objCOAInput = document.getElementById("coa_info");
		if(strORNumber.length < 3) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20008&or_number="+escape(strORNumber);
		this.processRequest(strURL);
	}

	function updateORNumber(strORNumber, strPaymentIndex){
		document.form_.print_page.value = "";
		document.form_.or_number.value = strORNumber;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.or_number.focus();
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
								"ACCOUNTING-BILLING","OR_print_main.jsp");
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
	
	if(WI.fillTextValue("or_number").length() > 0){
		strTemp = 
			" select payment_index from customer_payment where is_del = 0 "+
			" and or_number = "+WI.getInsertValueForDB(WI.fillTextValue("or_number"), true, null);
		if(dbOP.getResultOfAQuery(strTemp, 0) == null)
			strErrMsg = "OR number does not exist.";
		else{
			strTemp += " and is_valid = 1 ";
			if(dbOP.getResultOfAQuery(strTemp, 0) == null)
				strErrMsg = "OR number cancelled.";
			else{%>
				<jsp:forward page="./OR_print.jsp" />
			<%	return;
			}
		}
	}
%>	
<body bgcolor="#D2AE72" onload="FocusField();">
<form name="form_" action="OR_print_main.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: OR PRINTING PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">OR Number : </td>
			<td width="20%">
				<%if(!bolIsForwarded){%>
				<input name="or_number" type="text" size="16" value="<%=WI.fillTextValue("or_number")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapORNumber();">
				<%}else{%>
					<input type="hidden" name="or_number" value="<%=WI.fillTextValue("or_number")%>" />
					<strong><font size="3" color="#FF0000"><%=WI.fillTextValue("or_number")%></font></strong>
				<%}%></td>
			<td width="60%" valign="top"><label id="coa_info" style="position:absolute; width:400px"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="2" height="25">&nbsp;</td>
			<td colspan="2">
				<a href="javascript:ReloadPage();"><img src="../../../images/print.gif" border="0" /></a>
				<font size="1">Click to print OR.</font></td>
		</tr>
		<tr> 
			<td height="25" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="4" bgcolor="#A49A6A">&nbsp;</td>
		</table>

	<input type="hidden" name="print_page" />
	<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>