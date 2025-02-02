<%@ page language="java" import="utility.*, Accounting.billing.BillingTsuneishi, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Invoice Description</title>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
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
								"ACCOUNTING-BILLING","view_invoice_desc.jsp");
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
	
	Vector vInvoiceInfo = null;
	Vector vRetResult = null;
	Vector vTemp = null;
	BillingTsuneishi billTsu = new BillingTsuneishi();
	
	if(WI.fillTextValue("invoice_no").length() > 0){
		vInvoiceInfo = billTsu.getInvoiceInfo(dbOP, request);
		if(vInvoiceInfo == null)
			strErrMsg = billTsu.getErrMsg();
		else		
			vRetResult = billTsu.getInvoiceDetails(dbOP, request, (String)vInvoiceInfo.elementAt(0));
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./view_invoice_desc.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: INVOICE DESCRIPTION ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	    </tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Invoice No: </td>
			<td width="80%">
				<input type="hidden" name="invoice_no" value="<%=WI.fillTextValue("invoice_no")%>" />
				<strong><font size="3" color="#FF0000"><%=WI.fillTextValue("invoice_no")%></font></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
	    </tr>
	</table>
	
<%if(vInvoiceInfo != null && vInvoiceInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="5"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="17%">Invoice No: </td>
		    <td width="30%"><%=(String)vInvoiceInfo.elementAt(3)%></td>
		    <td width="17%">Invoice Category: </td>
		    <td width="33%"><%=(String)vInvoiceInfo.elementAt(1)%></td>
			<input type="hidden" name="invoice_index" value="<%=(String)vInvoiceInfo.elementAt(0)%>" />
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Invoice Date: </td>
		    <td><%=(String)vInvoiceInfo.elementAt(2)%></td>
		    <td>Currency:</td>
		    <td><%=WI.getStrValue((String)vInvoiceInfo.elementAt(8), "Php")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Unit Price: </td>
		    <td><%=(String)vInvoiceInfo.elementAt(7)%></td>
		    <td>Terms:</td>
		    <td><%=(String)vInvoiceInfo.elementAt(6)%> days </td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Charge To: </td>
		    <td colspan="3"><%=(String)vInvoiceInfo.elementAt(4)%></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Address:</td>
		    <td colspan="3"><%=(String)vInvoiceInfo.elementAt(5)%></td>
	    </tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
	
	<%if(vRetResult != null && vRetResult.size() > 0){%>	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: INVOICE DETAILS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="15%" align="center" class="thinborder"><strong>Quantity</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Unit</strong></td>
			<td width="40%" align="center" class="thinborder"><strong>Description</strong></td>
			<td width="16%" align="center" class="thinborder"><strong>Unit Price</strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Amount</strong></td>
		</tr>
		<%	for(int i = 0; i < vRetResult.size(); i+=3){
				vTemp = (Vector)vRetResult.elementAt(i+2);
		%>
		<tr>
			<td height="30" class="thinborderLEFT">&nbsp;</td>
		    <td class="thinborderLEFT">&nbsp;</td>
		    <td class="thinborderLEFT"><font size="2"><%=(String)vRetResult.elementAt(i+1)%></font></td>
		    <td class="thinborderLEFT">&nbsp;</td>
		    <td class="thinborderLEFT">&nbsp;</td>
	    </tr>
		<%for(int j = 0; j < vTemp.size(); j+=7){%>
		<tr>
			<td height="20" class="thinborderLEFT"><%=WI.getStrValue((String)vTemp.elementAt(j+1), "&nbsp;")%></td>
		    <td class="thinborderLEFT"><%=WI.getStrValue((String)vTemp.elementAt(j+2), "&nbsp;")%></td>
		    <td class="thinborderLEFT"><%=(String)vTemp.elementAt(j+3)%> <%=(String)vTemp.elementAt(j+4)%></td>
		    <td class="thinborderLEFT">&nbsp;</td>
		    <td class="thinborderLEFT" align="right"><%=CommonUtil.formatFloat((String)vTemp.elementAt(j+5), true)%>&nbsp;&nbsp;</td>
	    </tr>
		<%}}%>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="6" class="thinborderTOP">&nbsp;</td>
		</tr>
	</table>
	<%}
}%>	

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>