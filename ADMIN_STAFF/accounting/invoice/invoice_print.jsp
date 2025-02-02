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
<title>Print Invoice</title>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onload="window.print();">	
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","update_invoice.jsp");
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
	
	double dTotal = 0d;
	int iIndex = -1;
	String strInvoiceIndex = WI.fillTextValue("invoice_index");
	CommercialInvoiceMgmt cim = new CommercialInvoiceMgmt();
	
	Vector vInvoiceInfo = cim.getInvoiceInfo(dbOP, request, strInvoiceIndex);
	Vector vRetResult = cim.operateOnInvoiceDtls(dbOP, request, 4, strInvoiceIndex);
	if(vRetResult == null)
		vRetResult = new Vector();
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="2" align="center"><font size="+1"><strong>FIRST CEBU ARTCRAFT CORPORATION</strong></font></td>
		</tr>
		<tr>
			<td height="15" colspan="2" align="center"><font style="font-size:10px">FCAC Bldg., Artville Subdivision, San Isidro, Talisay City, Cebu 6045</font></td>
		</tr>
		<tr>
			<td height="15" colspan="2" align="center"><font style="font-size:10px">Tel./Fax No. 272-7781 / 272 - 7785</font></td>
		</tr>
		<tr>
			<td height="15" colspan="2" align="center"><font style="font-size:10px">VAT Reg. TIN: 000-271-576-000 Zero Rated</font></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20">COMMERCIAL INVOICE </td>
		    <td align="right">NO. <%=(String)vInvoiceInfo.elementAt(1)%>&nbsp;&nbsp;&nbsp;</td>
	    </tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20">Sold to: <%=(String)vInvoiceInfo.elementAt(4)%></td>
		    <td>Date: <%=(String)vInvoiceInfo.elementAt(2)%></td>
	    </tr>
		<tr>
			<td height="20">Address:<%=(String)vInvoiceInfo.elementAt(6)%></td>
		    <td>Destination: <%=(String)vInvoiceInfo.elementAt(10)%></td>
	    </tr>
		<tr>
			<td height="20">Business Name: <%=(String)vInvoiceInfo.elementAt(7)%></td>
		    <td>Tin: <%=(String)vInvoiceInfo.elementAt(8)%></td>
	    </tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" colspan="2" align="center" class="thinborder"><strong>QUANTITY</strong></td>
			<td align="center" class="thinborder"><strong>A R T I C L E S</strong></td>
			<td colspan="2" align="center" class="thinborder"><strong>UNIT PRICE </strong></td>
			<td colspan="2" align="center" class="thinborder"><strong>AMOUNT</strong></td>
		</tr>
	<%	int iCount = 0;
		for(int i = 0; i < vRetResult.size(); i += 8, iCount++){%>
		<tr>
			<td height="20" width="7%" class="thinborder" align="center"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+1), false)%></td>
		    <td width="7%" class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+3)%></td>
		    <td width="58%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<%
				strErrMsg = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5), true);
				iIndex = strErrMsg.indexOf(".");
				strTemp = strErrMsg.substring(0, iIndex+1);
				strErrMsg = strErrMsg.substring(iIndex+1);
			%>
		    <td width="7%" class="thinborder" align="right"><%=strTemp%>&nbsp;&nbsp;</td>
		    <td width="7%" class="thinborder" align="right"><%=strErrMsg%>&nbsp;&nbsp;</td>
			<%
				strErrMsg = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6), true);
				iIndex = strErrMsg.indexOf(".");
				strTemp = strErrMsg.substring(0, iIndex+1);
				strErrMsg = strErrMsg.substring(iIndex+1);
			%>
		    <td width="7%" class="thinborder" align="right"><%=strTemp%>&nbsp;&nbsp;</td>
            <td width="7%" class="thinborder" align="right"><%=strErrMsg%>&nbsp;&nbsp;</td>
			<%
				strErrMsg = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6), true);
				strErrMsg = ConversionTable.replaceString(strErrMsg, ",", "");
				dTotal += Double.parseDouble(strErrMsg);
			%>
		</tr>
		<%}
		
		for(int i = iCount; i <= 30; i++){%>
		<tr>
			<td height="20" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;</td>
		    <td class="thinborder">&nbsp;</td>
		    <td class="thinborder">&nbsp;</td>
		    <td class="thinborder">&nbsp;</td>
            <td class="thinborder">&nbsp;</td>
		</tr>
		<%}%>
		<tr>
			<td height="20" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;</td>
			<td class="thinborder" align="right"><strong>TOTAL</strong>&nbsp;</td>
		    <td class="thinborder">&nbsp;</td>
		    <td class="thinborder">&nbsp;</td>
			<%
				strErrMsg = CommonUtil.formatFloat(dTotal, true);
				iIndex = strErrMsg.indexOf(".");
				strTemp = strErrMsg.substring(0, iIndex+1);
				strErrMsg = strErrMsg.substring(iIndex+1);
			%>
		    <td class="thinborder" align="right"><%=strTemp%>&nbsp;&nbsp;</td>
            <td class="thinborder" align="right"><%=strErrMsg%>&nbsp;&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>FIRST CEBU ARTCRAFT CORP.</strong></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
		    <td height="20">Vessel <%=WI.getStrValue((String)vInvoiceInfo.elementAt(11))%></td>
		</tr>
		<tr>
			<td height="20" width="75%">BY: _______________________________________ </td>
		    <td width="25%">Voyage No. <%=WI.getStrValue((String)vInvoiceInfo.elementAt(12))%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Authorized Signature</td>
		    <td height="20">B L No. <%=WI.getStrValue((String)vInvoiceInfo.elementAt(13))%></td>
		</tr>
	</table>
</body>
</html>
<%
dbOP.cleanUP();
%>
