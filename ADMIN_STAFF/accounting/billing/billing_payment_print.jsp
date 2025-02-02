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
<title>Billing Payment</title>
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
								"ACCOUNTING-BILLING","billing_payment.jsp");
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
	
	boolean bolPageBreak = false;
	int i = 0;
	int iSearchResult = 0;
	Vector vBillingInfo = null;
	Vector vRetResult = null;

	BillingTsuneishi billTsu = new BillingTsuneishi();
	String strBillingIndex = WI.fillTextValue("billing_index");

	vBillingInfo = billTsu.getBillingInfo(dbOP, request, strBillingIndex);
	if(vBillingInfo != null)
		vRetResult = billTsu.getBillingPayments(dbOP, request, strBillingIndex);

	if (vRetResult != null) {			
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(7*iMaxRecPerPage);	
		if(vRetResult.size()%(7*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25" colspan="2"><div align="center">
				<strong>:::: BILLING PAYMENT ::::</strong></div></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
			<td><b><u>Billing Details: </u></b></td>
		    <td width="48%">&nbsp;</td>
		    <td width="32%"><b>Billing Date: <%=(String)vBillingInfo.elementAt(6)%></b></td>
		</tr>
		<tr>
			<td height="22" width="3%">&nbsp;</td>
			<td width="17%">Project Name: </td>
			<td colspan="2"><%=(String)vBillingInfo.elementAt(1)%> (<%=(String)vBillingInfo.elementAt(3)%> - <%=(String)vBillingInfo.elementAt(4)%>)</td>
		</tr>
		
		<tr>
			<td height="25">&nbsp;</td>
			<td>Bill Number: </td>
			<td><%=(String)vBillingInfo.elementAt(8)%></td>
		    <td>Bill Reference: <%=(String)vBillingInfo.elementAt(7)%></td>
		</tr>		
		<tr>
			<td height="25">&nbsp;</td>
			<td>Billing Amount: </td>
			<td>Php<%=(String)vBillingInfo.elementAt(2)%></td>
		    <td>Payable Amount: Php<%=(String)vBillingInfo.elementAt(13)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project Head: </td>
			<td><%=(String)vBillingInfo.elementAt(12)%></td>
		    <td>Manpower: <%=(String)vBillingInfo.elementAt(5)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project Detail: </td>
			<td colspan="2"><%=WI.getStrValue((String)vBillingInfo.elementAt(9), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Special Ref: </td>
			<td colspan="2"><%=WI.getStrValue((String)vBillingInfo.elementAt(10), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Note:</td>
			<td colspan="2"><%=WI.getStrValue((String)vBillingInfo.elementAt(11), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="50%" height="25" align="left" style="font-size:9px;">Page <%=iPageNo%> of <%=iTotalPages%></td>
		  	<td width="50%" align="right" style="font-size:9px;">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;</td>
	  	</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="4" class="thinborder">
				<div align="center"><strong>::: PROJECT BILLING PAYMENTS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="10%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>OR Number</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Date Paid</strong></td>
			<td width="45%" align="center" class="thinborder"><strong>Amount</strong></td>
		</tr>
		<% 
			int iResultCount = (iPageNo - 1) * iMaxRecPerPage + 1;
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=7, ++iCount,++iResultCount){
				i = iNumRec;
				if (iCount > iMaxRecPerPage){
					bolPageBreak = true;
					break;
				}
				else 
					bolPageBreak = false;			
		%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iResultCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;
				<%
					strTemp = (String)vRetResult.elementAt(i+5);
					if(strTemp == null)
						strTemp = "";
					else
						strTemp = (String)vRetResult.elementAt(i+4) + " (" + strTemp + ") - ";
				%>
				<%=strTemp%>Php<%=(String)vRetResult.elementAt(i+6)%></td>
		</tr>
	<%} //end for loop%>
	</table>
	<%if (bolPageBreak){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
	} //end end upper most if (vRetResult !=null)%>
</body>
</html>
<%
dbOP.cleanUP();
%>