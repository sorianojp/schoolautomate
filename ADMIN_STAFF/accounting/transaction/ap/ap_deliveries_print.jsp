<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*, purchasing.Delivery, Accounting.AccountPayable, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-PURCHASE ORDER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
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
								"Admin/staff-ACCOUNTING-TRANSACTION-AP-AP PROCESSING","ap_deliveries.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Delivery DEL = new Delivery();	
	AccountPayable AP = new AccountPayable();
	Vector vRetResult = null;
	String strReceiver = null;
	String strChecker = null;
	int iCount = 0;
		
	vRetResult = DEL.viewDeliveries(dbOP, request);	

if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
<%
boolean bolIsProcessed = false;

	if(WI.fillTextValue("show_processed").equals("1")) {
		strTemp = "PROCESSED";
		bolIsProcessed = true;
	}
	else
		strTemp = "UNPROCESSED";
%>	
    <td height="25" colspan="8" align="center" class="thinborderTOPLEFTRIGHT"><strong>:: LIST OF DELIVERIES <%=strTemp%> AS OF <%=WI.getTodaysDate(1)%> :: </strong></td>
    </tr>
   </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td width="22%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;" height="25">Supplier/Payee Name</td>
    <td width="12%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Delivery Date</td>
    <td width="10%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Invoice #</td>
    <td width="9%"  align="center" class="thinborder" style="font-weight:bold; font-size:9px;">PO #</td>
    <td width="13%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Received By</td>
    <td width="13%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Checked By</td>
<%if(bolIsProcessed){%>
    <td width="11%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Amount Payable </td>
<%}else{%>
    <td width="11%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Amount</strong></td>
<%}%>
  </tr>
	<%for(int i = 0;i < vRetResult.size();i+=19,iCount++){%>
  <tr> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
    <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
<%if(bolIsProcessed){%>
    <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+14)%>&nbsp;</td>
<%}else{%>
    <td height="25" align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true)%>&nbsp;</td>
<%}%>
  </tr>
	<%}%>
</table>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
