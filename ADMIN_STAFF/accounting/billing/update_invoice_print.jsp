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
<title>Invoice</title>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onload="window.print();">
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
								"ACCOUNTING-BILLING","update_invoice.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> <%=strErrMsg%></font></p>
	<%
		return;
	}	
	
	double dTotal = 0d;
	Vector vInvoiceInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vTemp = null;
	BillingTsuneishi billTsu = new BillingTsuneishi();
	
	int iLineCount = 1;
	int iMaxLines = 23;
	
	vInvoiceInfo = billTsu.getInvoiceInfo(dbOP, request);
	vRetResult = billTsu.getInvoiceDetails(dbOP, request, (String)vInvoiceInfo.elementAt(0));
	
	if(vRetResult != null && vRetResult.size() > 0){%>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td width="30%">&nbsp;</td>
		</tr>
		<tr>
			<td height="75" colspan="2">&nbsp;</td>
			<td align="center">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="40%" class="thinborderALL" align="center"><strong><%=(String)vInvoiceInfo.elementAt(1)%></strong></td>
		    <td width="30%">&nbsp;</td>
		    <td align="center">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td align="center">&nbsp;</td>
		</tr>
		<tr>
			<td height="40" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="13%">&nbsp;</td>
			<td width="57%"><%=(String)vInvoiceInfo.elementAt(4)%></td>
			<td width="16%">&nbsp;</td>
			<td width="14%"><%=(String)vInvoiceInfo.elementAt(2)%></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="10%">&nbsp;</td>
			<td width="35%"><%=(String)vInvoiceInfo.elementAt(5)%></td>
			<td width="5%">&nbsp;</td>
			<td width="20%"><%=(String)vInvoiceInfo.elementAt(9)%></td>
			<td width="17%">&nbsp;</td>
			<td width="13%"><%=(String)vInvoiceInfo.elementAt(6)%></td>
		</tr>
		<tr>
			<td height="25" colspan="6">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" width="15%">&nbsp;</td>
			<td width="10%">&nbsp;</td>
			<td width="45%">&nbsp;</td>
			<td width="15%">&nbsp;</td>
			<td width="15%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>&nbsp;</td>
			<td>&nbsp;</td>
		    <td><strong><%=(String)vInvoiceInfo.elementAt(7)%></strong></td>
		    <td><strong><%=WI.getStrValue((String)vInvoiceInfo.elementAt(8), "Php")%></strong></td>		    
	    </tr>
		<%	for(int i = 0; i < vRetResult.size(); i+=3){
				iLineCount++;
				vTemp = (Vector)vRetResult.elementAt(i+2);
		%>
		<tr>
			<td height="30">&nbsp;</td>
		    <td>&nbsp;</td>
		    <td><strong><%=(String)vRetResult.elementAt(i+1)%></strong></td>
		    <td>&nbsp;</td>
		    <td>&nbsp;</td>
	    </tr>
		<%	for(int j = 0; j < vTemp.size(); j+=7){
				iLineCount++;
				dTotal += Double.parseDouble((String)vTemp.elementAt(j+5));
		%>
		<tr>
			<td height="20"><%=WI.getStrValue((String)vTemp.elementAt(j+1), "&nbsp;")%></td>
		    <td><%=WI.getStrValue((String)vTemp.elementAt(j+2), "&nbsp;")%></td>
		    <td><%=(String)vTemp.elementAt(j+3)%> <%=(String)vTemp.elementAt(j+4)%></td>
		    <td>&nbsp;</td>
		    <td align="right"><%=CommonUtil.formatFloat((String)vTemp.elementAt(j+5), true)%>&nbsp;&nbsp;</td>
	    </tr>
		<%}}
		
	for(int i = iLineCount; i < iMaxLines; i++){%>
		<tr>
			<td height="20" colspan="5">&nbsp;</td>
	    </tr>
	<%}%>
		<tr>
			<td height="25" colspan="3" align="center">&nbsp;</td>
			<td colspan="2" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<font size="2"><strong><%=(String)vInvoiceInfo.elementAt(8)%> <%=CommonUtil.formatFloat(dTotal, 2)%></strong></font></td>
		</tr>
		<tr>
			<td height="70" colspan="5">&nbsp;</td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="25%">&nbsp;</td>
			<td width="75%">Checked by: <u>Rachel Nufable</u></td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="7%">&nbsp;</td>
			<td width="30%">Maritsuo Fuse</td>
			<td width="63%">Segismundo Exaltacion Jr.</td>
		</tr>
	</table>
	<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>