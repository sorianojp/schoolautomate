<%@ page language="java" import="utility.*, Accounting.invoice.CommercialInvoiceMgmt, java.util.Vector"%>
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
<title>View Invoice Info</title></head>
<script language="javascript" src="../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","view_invoice_info.jsp");
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
	//end of security
	
	String strInvoiceIndex = WI.fillTextValue("invoice_index");
	if(strInvoiceIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Invoice reference is not found. Please close this window and click view link again from main window.</p>
		<%return;
	}
	
	Vector vRetResult = null;
	CommercialInvoiceMgmt cim = new CommercialInvoiceMgmt();
	Vector vInvoiceInfo = cim.getInvoiceInfo(dbOP, request, strInvoiceIndex);
	if(vInvoiceInfo == null)
		strErrMsg = cim.getErrMsg();
	else{
		vRetResult = cim.operateOnInvoiceDtls(dbOP, request, 4, strInvoiceIndex);
		if(vRetResult == null)
			strErrMsg = cim.getErrMsg();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./view_invoice_info.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: INVOICE INFORMATION ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	<%if(vInvoiceInfo != null && vInvoiceInfo.size() > 0){%>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Invoice No: </td>
			<td width="80%"><%=(String)vInvoiceInfo.elementAt(1)%></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
			<td>Invoice Date: </td>
			<td><%=(String)vInvoiceInfo.elementAt(2)%></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
			<td>Customer:</td>
			<td><%=(String)vInvoiceInfo.elementAt(4)%></td>
	  	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Address:</td>
			<td><%=(String)vInvoiceInfo.elementAt(6)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Business Name:</td>
			<td><%=(String)vInvoiceInfo.elementAt(7)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Tin:</td>
			<td><%=(String)vInvoiceInfo.elementAt(8)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Destination:</td>
			<td><%=(String)vInvoiceInfo.elementAt(10)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Vessel: </td>
			<td><%=WI.getStrValue((String)vInvoiceInfo.elementAt(11))%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Voyage No: </td>
			<td><%=WI.getStrValue((String)vInvoiceInfo.elementAt(12))%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>B L No: </td>
			<td><%=WI.getStrValue((String)vInvoiceInfo.elementAt(13))%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		  	<td>Total Amount: </td>
		  	<td><%=CommonUtil.formatFloat(WI.getStrValue((String)vInvoiceInfo.elementAt(9), "0"), true)%></td>
	  	</tr>
	<%if((String)vInvoiceInfo.elementAt(14) != null){%>
		<tr>
			<td height="25">&nbsp;</td>
		  	<td>Exchange Rate: </td>
		  	<td><%=CommonUtil.formatFloat((String)vInvoiceInfo.elementAt(14), false)%></td>
	  	</tr>
	<%}%>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	<%}%>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: INVOICE DETAILS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="15%" align="center" class="thinborder"><strong>QUANTITY</strong></td>
			<td width="55%" align="center" class="thinborder"><strong>A R T I C L E S </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>UNIT PRICE </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>AMOUNT</strong></td>
		</tr>
		<%for(int i = 0; i < vRetResult.size(); i += 8){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+1), false)%> (<%=(String)vRetResult.elementAt(i+3)%>)</td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
		    <td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+5), true)%>&nbsp;&nbsp;</td>
		    <td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+6), true)%>&nbsp;&nbsp;</td>
		</tr>
		<%}%>
	</table>
<%}%>	

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="invoice_info" value="<%=strInvoiceIndex%>"/>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>