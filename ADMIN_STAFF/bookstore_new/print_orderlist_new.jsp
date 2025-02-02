<%@ page language="java" import="utility.*, citbookstore.BookOrders, java.util.Vector,java.util.*"%>
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
								"BOOKSTORE-ORDERING","print_orderlist.jsp");
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
	Vector vExcess = null;
	BookOrders bo = new BookOrders();
	
	String strTemp2 = null;
	
	boolean bolIsPrinted = false;
	
	double dDownPayment = 0d;
	double dDownPayment1 = 0d;
	double dDownPayment2 = 0d;
	
	String strBasicOrder = null;
	String strSQLQuery = null;
	
	String strBookTitleIndex = WI.fillTextValue("book_title");
	String strDateExpire = null;
	Vector vRetResult = bo.getOrderedItemsForPrinting(dbOP, request, strOrderIndex);

	if(vRetResult != null && vRetResult.size() > 0){
		if(WI.fillTextValue("print_excess").length()>0){
			vExcess = (Vector)vRetResult.remove(0);
		}else{
			vBookTypeOrders = (Vector)vRetResult.remove(0);
			vNonBookTypeOrders = (Vector)vRetResult.remove(0);
		}		
		
		/////////////////////////////////////
		strTemp = "select is_printed from bs_book_order_main where order_index = "+strOrderIndex;
		strTemp = dbOP.getResultOfAQuery(strTemp,0);		
		
		if(!bo.operateOnOrderPrinting(dbOP,request,Integer.parseInt(strTemp) + 1,strOrderIndex))
				strErrMsg = bo.getErrMsg();
		////////////////////////////////////////////////////////////////////////////////
			
		
		
		strTemp2 = "select order_number from BS_BOOK_ORDER_main where order_index = "+strOrderIndex;
		strTemp2 = dbOP.getResultOfAQuery(strTemp2, 0);	
				
		
		String strSYFrom = WI.fillTextValue("sy_from");		
		String strSemester = WI.fillTextValue("offering_sem");	
		
		strSQLQuery = " select course_index from stud_curriculum_hist "+
			" join bs_book_order_main on (bs_book_order_main.user_index=stud_curriculum_hist.user_index) "+
			" where order_index="+strOrderIndex+" and bs_book_order_main.is_valid=1 "+ 
			" and stud_curriculum_hist.semester="+strSemester+
			" and stud_curriculum_hist.sy_from="+strSYFrom;			
		strBasicOrder = dbOP.getResultOfAQuery(strSQLQuery,0);
		
		if(WI.fillTextValue("print_order").equals("1") && !strBasicOrder.equals("0") && bolIsCIT)			
			strDateExpire = bo.setOrderExpirationDate(dbOP, request, strTemp2);
		
		
		
		Vector vReturned = new Vector();
		if(strBookTitleIndex.length() > 0){
			//dri mag kuha ug details sa replaced item
			strSQLQuery = " select book_index, book_title, author, price from bs_book_entry where book_index = "+strBookTitleIndex;
			java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
			
			while(rs.next()){
				vReturned.addElement(rs.getString(1));
				vReturned.addElement(rs.getString(2));
				vReturned.addElement(rs.getString(3));
				vReturned.addElement(rs.getString(4));
			}rs.close();
		}	
		
	if( ( vBookTypeOrders != null && vBookTypeOrders.size() > 0 ) || (vNonBookTypeOrders != null && vNonBookTypeOrders.size() > 0) ){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="25" colspan="2" align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%>
			<%if(bolIsCIT){%>
				<br />INSTRUCTIONAL MATERIALS DISTRIBUTION CENTER<br />ORDER SLIP
			<%}%>
			
			</font></td>
		</tr>
		<%if(!strBasicOrder.equals("0") && bolIsCIT){%>
		<tr>
			<td>&nbsp;</td>
		    <td align="right">Order Expiration Date : <%=WI.getStrValue(strDateExpire, "N/A")%></td>
		</tr>
		<%}%>
		<tr>
			<td><%=(String)vRetResult.elementAt(0)%></td>
		    <td align="right">Order Slip# : <%=strTemp2%></td>
		</tr>
		<tr>
			<td width="70%"><%=(String)vRetResult.elementAt(1)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(2);
				if(strTemp.equals("0"))//if basic
					strErrMsg = (String)vRetResult.elementAt(4)+WI.getStrValue((String)vRetResult.elementAt(5)," - ","","");
				else
					strErrMsg = (String)vRetResult.elementAt(6) +WI.getStrValue((String)vRetResult.elementAt(3)," - ","","");
			%>
			<td width="30%"><%=strErrMsg%></td>
		</tr>
	</table>
	
	
	<%
	int iCount = 1;
	double dTotal = 0d;
	double dTotalCatg = 0d;
	
	if(vBookTypeOrders != null && vBookTypeOrders.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td width="5%">No.</td>
			<td width="15%">Subject</td>
			<td width="">Title</td>
			<td width="20%">Author</td>
			<td width="5%">Qty</td>
			<td align="right" width="10%">Price</td>
		</tr>		
	<%	
		
		for(int j = 0; j < vBookTypeOrders.size(); j += 3){
			dTotalCatg = 0d;
			vTemp = (Vector)vBookTypeOrders.elementAt(j+2);
			if(j+3 >= vBookTypeOrders.size()){
				if(vNonBookTypeOrders != null && vNonBookTypeOrders.size() > 0){
					vTemp.addAll(vNonBookTypeOrders);
					vNonBookTypeOrders = new Vector();
				}
			}
				
			for(int i = 0; i < vTemp.size(); i += 6, iCount++){
				--iMaxRow;
	
		if(false && j > 0 && i == 0){%>
		<tr>
			<td height="22" colspan="6">ADD <%=((String)vBookTypeOrders.elementAt(j+1)).toUpperCase()%></td>
		</tr>
		<%}%>
		<tr>
			<td><%=iCount%>.&nbsp;</td>
			<td><%=WI.getStrValue((String)vTemp.elementAt(i))%></td>
			<td><%=(String)vTemp.elementAt(i+1)%></td>
			<td><%=WI.getStrValue(vTemp.elementAt(i+2),"N/A")%></td>
			<td><%=(String)vTemp.elementAt(i+3)%></td>
			<%
				dTotal += Double.parseDouble((String)vTemp.elementAt(i+4));
				dDownPayment1 = dTotal;
				dTotalCatg += Double.parseDouble((String)vTemp.elementAt(i+4));
			%>
			<td align="right"><%=CommonUtil.formatFloat((String)vTemp.elementAt(i+4), true)%></td>
		</tr>
	  <%}%>
		<!--<tr>
			<td height="7" colspan="5" align="right"></td>
			<td><hr size="1" /></td>
		</tr>
		<tr>
			<td height="22" colspan="5">TOTAL <%=((String)vBookTypeOrders.elementAt(j+1)).toUpperCase()%></td>
			<td align="right"><%=CommonUtil.formatFloat(dTotalCatg, true)%></td>
		</tr>-->
	<%}%>
	
	
	
	</table>
	<%}
	
	
	if(vNonBookTypeOrders != null && vNonBookTypeOrders.size() > 0){
	%>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td width="5%">No.</td>
			<td width="80%">Item Name </td>
			<td width="5%">Qty</td>
			<td align="right" width="10%">Price</td>
		</tr>		
	<%			
		for(int i = 0; i < vNonBookTypeOrders.size(); i += 6, iCount++){			
			--iMaxRow;
	%>
		<tr>
			<td><%=iCount%>.&nbsp;</td>
			<td>&nbsp;<%=(String)vNonBookTypeOrders.elementAt(i+1)%></td>
			<td><%=(String)vNonBookTypeOrders.elementAt(i+3)%></td>
			<%
				dTotal += Double.parseDouble((String)vNonBookTypeOrders.elementAt(i+4));
				dDownPayment2 = dTotal;
					
			%>
			<td align="right"><%=CommonUtil.formatFloat((String)vNonBookTypeOrders.elementAt(i+4), true)%></td>
		</tr>
	  <%}%>
		<tr>
			<td height="7" colspan="3" align="right"></td>
			<td><hr size="1" /></td>
		</tr>
	</table>
	<%}%>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td width="40%">&nbsp;</td>
			<td width="45%"><strong>Grand Total</strong></td>
			<td width="15%" align="right" class="thinborderTOP">&nbsp;<strong style="font-size:12px;"><%=CommonUtil.formatFloat(dTotal, true)%></strong></td>
		</tr>		
	</table>
	<%}
	
	if(vExcess != null && vExcess.size() > 0){%>
	
	
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="22" colspan="2" align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%>
			<%if(bolIsCIT){%>
				<br />INSTRUCTIONAL MATERIALS DISTRIBUTION CENTER<br />ORDER SLIP
			<%}%>
			</font></td>
		</tr>
		<tr>
			<td height="22"><%=(String)vRetResult.elementAt(0)%></td>
			<td align="right">Order Slip# : <%=strTemp2%></td>
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
		<tr><td colspan="4">Returned Item</td></tr>
		<tr>
			<td height="22" align="center" width="5%">No.</td>
			<td width="80%">Item Name </td>
			<td width="5%">Qty</td>
			<td align="right" width="10%">Price</td>
		</tr>			
	<%	int iCount = 1;
		double dTotal = 0d;
		int iQty = 0;
		double dAmt = 0d;
		for(int i = 0; i < vExcess.size(); i += 3, iCount++){--iMaxRow;%>
		<tr>
			<td height="22" align="center"><%=iCount%>.&nbsp;</td>
			<td>&nbsp;<%=(String)vExcess.elementAt(i+1)%></td>
			<%
				iQty = Integer.parseInt(WI.fillTextValue("return_qty"));
			%>
			<td><%=iQty%></td>
			<%				
				dAmt = Double.parseDouble((String)vExcess.elementAt(i+2)) * iQty;					
			%>
			<td align="right"><%=CommonUtil.formatFloat(dAmt, true)%></td>
		</tr>
	  <%}%>
	  
	  <tr><td colspan="4">Replaced Item</td></tr>
	  <tr>
			<td height="22" align="center" width="5%">No.</td>
			<td width="80%">Item Name </td>
			<td width="5%">&nbsp;</td>
			<td align="right" width="10%">&nbsp;</td>
		</tr>
		
		
		<%	
		iCount = 1;
		double dAmt1 = 0d;
		iQty = 0;
		if(vReturned.size()>0){
			for(int i = 0; i < vReturned.size(); i += 4, iCount++){--iMaxRow;%>
		<tr>
			<td height="22" align="center"><%=iCount%>.&nbsp;</td>
			<td>&nbsp;<%=(String)vReturned.elementAt(i+1)%></td>
			<%
				iQty = Integer.parseInt(WI.fillTextValue("return_qty"));			
			%>
			<td><%=iQty%></td>
			<%				
				dAmt1 = Double.parseDouble((String)vReturned.elementAt(i+3)) * iQty;					
			%>
			<td align="right"><%=CommonUtil.formatFloat(dAmt1, true)%></td>
		</tr>
	  <%}
	  }//if vReturned not null%>
		
		
		
		
	  
	  <%
	  strTemp = "";
	  	dTotal = dAmt - dAmt1;		
		
		if(dTotal > 0d)
			strTemp = "Refundable";
		else
			strTemp = "Grand Total";
	  %>
	  
	  
		<tr>
			<td height="15" colspan="3" align="right">&nbsp;</td>
			<td><hr size="1" /></td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="25" width="40%">&nbsp;</td>
			<td width="40%"><%=strTemp%></td>
			<td width="20%" align="right">&nbsp;<%=CommonUtil.formatFloat(Math.abs(dTotal), true)%></td>
		</tr>		
	</table>
	
	
	
	<%}
	
	
	
	
	if( vBookTypeOrders != null &&  vBookTypeOrders.size() > 0 && strBasicOrder.equals("0") && !WI.fillTextValue("print_excess").equals("1") ){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="25" width="40%">&nbsp;</td>
			<td width="20%">Down Payment ====</td>
			<%
			dDownPayment = dDownPayment1 + dDownPayment2;
			strTemp = "select downpayment from bs_book_expire_setting where is_valid=1";
			strTemp = dbOP.getResultOfAQuery(strTemp,0);
			
			double dPercent = Double.parseDouble(WI.getStrValue(strTemp,"0"))/100;			
			
			%>
			<td width="40%" align="left">&nbsp;<%=CommonUtil.formatFloat(dDownPayment*dPercent, true)%></td>
		</tr>
	</table>
	<%}%>
	
	<%}//end of vRetResult != null
	if(bolIsCIT){
	if(iMaxRow > 0) {%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<%for(int i =0; i < iMaxRow; ++i) {%>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<%}%>
	</table>
	<%}%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr><td colspan="3" height="20">&nbsp;</td></tr>
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