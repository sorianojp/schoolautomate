<%@ page language="java" import="utility.*, bookstore.BookOrders, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");
	
	int iMaxRow = 0;
	
	if(bolIsCIT)
		iMaxRow = 4;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Print Orderlist</title></head>
<script language="javascript" src="../../jscript/common.js"></script>
<body onload="window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-BOOK MANAGEMENT","release_items.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-ORDERING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	Vector vTemp = null;
	Vector vBookTypeOrders = null;
	Vector vNonBookTypeOrders = null;
	String strOrderIndex = WI.fillTextValue("order_index");
	BookOrders bo = new BookOrders();
	
	Vector vRetResult = bo.getOrderedItemsForPrinting(dbOP, request, strOrderIndex);
	if(vRetResult != null && vRetResult.size() > 0){
		vBookTypeOrders = (Vector)vRetResult.remove(0);
		vNonBookTypeOrders = (Vector)vRetResult.remove(0);
		
		//System.out.println(vBookTypeOrders);
		strTemp = "select order_number from BS_BOOK_ORDER_main where order_index = "+ WI.fillTextValue("order_index");
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		
		
	if(vBookTypeOrders != null && vBookTypeOrders.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="25" colspan="2" align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%>
			<%if(bolIsCIT){%>
				<br />INSTRUCTIONAL MATERIALS DISTRIBUTION CENTER<br /><br /> ORDER SLIP
			<%}%>
			
			</font></td>
		</tr>
		<tr>
			<td height="25"><%=(String)vRetResult.elementAt(0)%></td>
		    <td align="right">Order Slip# : <%=strTemp%></td>
		</tr>
		<tr>
			<td height="25" width="70%"><%=(String)vRetResult.elementAt(1)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(2);
				if(strTemp.equals("0"))//if basic
					strErrMsg = (String)vRetResult.elementAt(4) + " - " + (String)vRetResult.elementAt(5);
				else
					strErrMsg = (String)vRetResult.elementAt(6) + " - " + (String)vRetResult.elementAt(3);
			%>
			<td width="30%"><%=strErrMsg%></td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="22" width="5%">No.</td>
			<td width="20%">Subject</td>
			<td width="35%">Title</td>
			<td width="25%">Author</td>
			<td width="5%">Qty</td>
			<td align="right" width="10%">Price</td>
		</tr>		
	<%	int iCount = 1;
		double dTotal = 0d;
		double dTotalCatg = 0d;
		for(int j = 0; j < vBookTypeOrders.size(); j += 3){
			dTotalCatg = 0d;
			vTemp = (Vector)vBookTypeOrders.elementAt(j+2);
			for(int i = 0; i < vTemp.size(); i += 6, iCount++){
				--iMaxRow;
	
	if(j > 0 && i == 0){%>
		<tr>
			<td height="22" colspan="6">ADD <%=((String)vBookTypeOrders.elementAt(j+1)).toUpperCase()%></td>
		</tr>
	<%}%>
		<tr>
			<td height="22"><%=iCount%>.&nbsp;</td>
			<td><%=WI.getStrValue((String)vTemp.elementAt(i))%></td>
			<td><%=(String)vTemp.elementAt(i+1)%></td>
			<td><%=WI.getStrValue((String)vTemp.elementAt(i+2))%></td>
			<td><%=(String)vTemp.elementAt(i+3)%></td>
			<%
				dTotal += Double.parseDouble((String)vTemp.elementAt(i+4));
				dTotalCatg += Double.parseDouble((String)vTemp.elementAt(i+4));
			%>
			<td align="right"><%=CommonUtil.formatFloat((String)vTemp.elementAt(i+4), true)%></td>
		</tr>
	  <%}%>
		<tr>
			<td height="15" colspan="5" align="right">&nbsp;</td>
			<td><hr size="1" /></td>
		</tr>
		<tr>
			<td height="22" colspan="5">TOTAL <%=((String)vBookTypeOrders.elementAt(j+1)).toUpperCase()%></td>
			<td align="right"><%=CommonUtil.formatFloat(dTotalCatg, true)%></td>
		</tr>
	<%}%>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="25" width="40%">&nbsp;</td>
			<td width="40%">Grand Total</td>
			<td width="20%" align="right">&nbsp;<%=CommonUtil.formatFloat(dTotal, true)%></td>
		</tr>
		<!--
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="2">Minimum Down Payment: <%=CommonUtil.formatFloat(dTotal/2, true)%></td>
		</tr>
		-->
	</table>
	<%}
	
	if(vBookTypeOrders != null && vBookTypeOrders.size() > 0 && vNonBookTypeOrders != null && vNonBookTypeOrders.size() > 0){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}
	
	if(vNonBookTypeOrders != null && vNonBookTypeOrders.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="22" colspan="2" align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%>
			<%if(bolIsCIT){%>
				<br />INSTRUCTIONAL MATERIALS DISTRIBUTION CENTER<br /><br /> ORDER SLIP
			<%}%>
			</font></td>
		</tr>
		<tr>
			<td height="22" colspan="2"><%=(String)vRetResult.elementAt(0)%></td>
		</tr>
		<tr>
			<td height="22" width="70%"><%=(String)vRetResult.elementAt(1)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(2);
				if(strTemp.equals("0"))//if basic
					strErrMsg = (String)vRetResult.elementAt(4) + " - " + (String)vRetResult.elementAt(5);
				else
					strErrMsg = (String)vRetResult.elementAt(6) + " - " + (String)vRetResult.elementAt(3);
			%>
			<td width="30%"><%=strErrMsg%></td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="22" align="center" width="5%">No.</td>
			<td width="80%">Item Name </td>
			<td width="5%">Qty</td>
			<td align="right" width="10%">Price</td>
		</tr>		
	<%	int iCount = 1;
		double dTotal = 0d;
		for(int i = 0; i < vNonBookTypeOrders.size(); i += 6, iCount++){--iMaxRow;%>
		<tr>
			<td height="22" align="right"><%=iCount%>.&nbsp;</td>
			<td>&nbsp;<%=(String)vNonBookTypeOrders.elementAt(i+1)%></td>
			<td><%=(String)vNonBookTypeOrders.elementAt(i+3)%></td>
			<%
				dTotal += Double.parseDouble((String)vNonBookTypeOrders.elementAt(i+4));
			%>
			<td align="right"><%=CommonUtil.formatFloat((String)vNonBookTypeOrders.elementAt(i+4), true)%></td>
		</tr>
	  <%}%>
		<tr>
			<td height="15" colspan="3" align="right">&nbsp;</td>
			<td><hr size="1" /></td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="25" width="40%">&nbsp;</td>
			<td width="40%">Grand Total</td>
			<td width="20%" align="right">&nbsp;<%=CommonUtil.formatFloat(dTotal, true)%></td>
		</tr>
		<!--<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="2">Minimum Down Payment: <%=CommonUtil.formatFloat(dTotal, true)%></td>
		</tr>-->
	</table>
	<%}
	
	}//end of vRetResult != null%>
	
	<%if(bolIsCIT){%>
	<%if(iMaxRow > 0) {%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<%for(int i =0; i < iMaxRow; ++i) {%>
		<tr>
			<td height="22">&nbsp;</td>
		</tr>
		<%}%>
	</table>
	<%}%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="25" width="28%">FOR IMDC USE ONLY</td>
			<td width="36%" align="center"><%=request.getSession(false).getAttribute("first_name")%> <%=WI.getTodaysDateTime()%></td>
			<td width="36%" align="right">&nbsp;</td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td align="center" class="thinborderTOP" style="font-size:12px" valign="top">VERIFIED BY/DATE</td>
		  <td align="right">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td align="right">&nbsp;</td>
	  </tr>
		<tr align="center">
		  <td height="25"><table width="90%" cellpadding="0" cellspacing="0" border="0"><tr><td class="thinborderBOTTOM">&nbsp;</td></tr></table></td>
		  <td><table width="90%" cellpadding="0" cellspacing="0" border="0"><tr><td class="thinborderBOTTOM">&nbsp;</td></tr></table></td>
		  <td><table width="90%" cellpadding="0" cellspacing="0" border="0"><tr><td class="thinborderBOTTOM">&nbsp;</td></tr></table></td>
	  </tr>
		<tr align="center">
		  <td>TELLER'S RECEIPT NO. </td>
		  <td>RELEASED BY/DATE </td>
		  <td>RECEIVED BY FULL NAME AND SIGNATURE </td>
	  </tr>
	</table>	
	
	<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>