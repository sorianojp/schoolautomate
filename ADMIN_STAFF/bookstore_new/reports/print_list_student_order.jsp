	<%@ page language="java" import="utility.*, citbookstore.BookReports, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>List of Student Order</title></head>
<script language="javascript" src="../../../jscript/common.js"></script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	CommonUtil comUtil = new CommonUtil();
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-REPORTS","print_list_student_order.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
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
		if(iAccessLevel == 0){
			response.sendRedirect("../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	boolean bolPrintPage = false;
	if(WI.fillTextValue("print_page").length() > 0)
		bolPrintPage = true;
	
	int iSearchResult = 0;
	Vector vRetResult = new Vector();
	Vector vTemp = new Vector();
	Vector vBookInfo = new Vector();
	BookReports br = new BookReports();
	String strOrderedQty = null;
	String strExtraMsg = null;
	
	String strCon = "";
	String strDateType = WI.fillTextValue("date_type");
	String strDateFrom = WI.fillTextValue("date_fr");//date from search parameter
	String strDateTo   = WI.fillTextValue("date_to");//date to search parameter
	
	String strDateFrom2 = WI.fillTextValue("date_fr");//date from search parameter
	String strDateTo2   = WI.fillTextValue("date_to");//date to search parameter
	
	
	int iAction = Integer.parseInt(WI.getStrValue(WI.fillTextValue("iAction"),"100"));
	if(iAction==2)
		strExtraMsg = "ORDERED QUANTITY";
	if(iAction==3)
		strExtraMsg = "RELEASED QUANTITY";
	if(iAction==4)
		strExtraMsg = "PAID and UNRELEASED QUANTITY";
	if(iAction==5)
		strExtraMsg = "UNPAID and UNRELEASED QUANTITY";
	
	
	vTemp = br.searchStocksOrderedBySY(dbOP, request,iAction,WI.fillTextValue("book_index"));	
	if(vTemp == null)
		strErrMsg = br.getErrMsg();
	else{
		iSearchResult = br.getSearchCount();		
		vBookInfo 	  = (Vector)vTemp.remove(0);
		vRetResult    = (Vector)vTemp.remove(0);
		
		if(vBookInfo == null || vRetResult == null)
			strErrMsg = br.getErrMsg();
		else{
		
			String strSYFrom = WI.fillTextValue("sy_from");            
            String strSemester = WI.fillTextValue("offering_sem");
			
			
			

			if(strDateType.equals("1")){
				if(strDateFrom.length() == 0){
					strCon = "";
				}else{
				   strDateFrom = ConversionTable.convertTOSQLDateFormat(strDateFrom);
				   if(strDateFrom == null)
					   strCon = "";
				   else
					   strCon = " and transaction_date = '"+strDateFrom+"' ";
			   }
		   }else{
			   if(strDateFrom.length() == 0 || strDateTo.length() == 0){
				   strCon = "";
			   }else{
				   strDateFrom = ConversionTable.convertTOSQLDateFormat(strDateFrom);
				   strDateTo = ConversionTable.convertTOSQLDateFormat(strDateTo);
				   if(strDateFrom == null || strDateTo == null)
					   strCon = "";
				   else
					   strCon = " and transaction_date between '"+strDateFrom+"' and '"+strDateTo+"' ";
			   }                 
		   }
			if(iAction == 2){
				strTemp = "	select sum(quantity) from bs_book_order_items "+
					" join bs_book_order_main on (bs_book_Order_main.order_index = bs_book_order_items.order_index) "+
					" where payable_amt > 0 and order_stat > 0 and sy_from="+strSYFrom+" and semester="+strSemester+
					" and is_valid=1 "+ strCon +
					" and book_index = "+WI.fillTextValue("book_index");
			}if(iAction == 3){
				strTemp = "	select sum(quantity) from bs_book_order_items "+
					" join bs_book_order_main on (bs_book_Order_main.order_index = bs_book_order_items.order_index) "+
					" where payable_amt > 0 and order_stat > 0 and is_released > 0 and is_deducted = 1 "+
					" and payment_index is not null and sy_from="+strSYFrom+" and semester="+strSemester+
					" and is_valid=1 "+ strCon +
					" and book_index = "+WI.fillTextValue("book_index");
			}if(iAction == 4){
				strTemp = "	select sum(quantity) from bs_book_order_items "+
					" join bs_book_order_main on (bs_book_Order_main.order_index = bs_book_order_items.order_index) "+
					" where payable_amt > 0 and order_stat > 0 and is_released = 0 and is_deducted = 1 "+
					" and payment_index is not null and sy_from="+strSYFrom+" and semester="+strSemester+
					" and is_valid=1 "+ strCon +
					" and book_index = "+WI.fillTextValue("book_index");
			}if(iAction == 5){
				strTemp = "	select sum(quantity) from bs_book_order_items "+
					" join bs_book_order_main on (bs_book_Order_main.order_index = bs_book_order_items.order_index) "+
					" where payable_amt > 0 and order_stat > 0 and is_released = 0 and is_deducted = 0 "+
					" and payment_index is null and sy_from="+strSYFrom+" and semester="+strSemester+
					" and is_valid=1 "+ strCon +
					" and book_index = "+WI.fillTextValue("book_index");
			}
								
			strOrderedQty = dbOP.getResultOfAQuery (strTemp , 0)	;
		}
		
	}
		
	String[] astrConvertSem = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};
%>
<body <%if(strErrMsg == null){%> onload="window.print();"<%}%>>

<%if(strErrMsg!=null){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr><td><font size="2" color="#FF0000"><strong><%=strErrMsg%></strong></font></td></tr>
	</table>
<%}if(vRetResult != null && vRetResult.size() > 0 && strErrMsg == null){%>
	


	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="" id="myTable1">		
		<tr><td height="25">&nbsp;</td></tr>		
		<tr><td height="25" align="center"><strong><%=strExtraMsg%></strong></td></tr>
		<tr><td height="25">&nbsp;</td></tr>
		<tr>		
		  	<td height="20">
				<div align="center"><strong> CEBU INSTITUTE OF TECHNOLOGY </strong><br />
				Student Ordered List SY: <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%> <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>
				</div></td>
		</tr>
		<%if(strCon.length() > 0){%>
		<tr>
			<td align="center" height="20">Order Date <%=WI.formatDate(strDateFrom2,6)%><%=WI.getStrValue(WI.formatDate(strDateTo2,6)," to ","","")%></td>
		</tr>
		<%}%>
	</table>
	
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="" id="myTable4">
		<tr>
			<td width="3%" height="20">&nbsp;</td>
			<%
				strTemp = (String)vBookInfo.elementAt(6);
				if(strTemp.equals("1"))
					strTemp = "Book Title : ";
				else
					strTemp = "Item Name : ";
			%>			
			<td width="17%"><%=strTemp%></td>
			<td colspan="3"><%=(String)vBookInfo.elementAt(1)%></td>
		</tr>
		
		<tr>
			<td width="3%" height="20">&nbsp;</td>
			<td width="17%">Item Code:</td>
			<td width="30%"><%=(String)vBookInfo.elementAt(2)%></td>
			<td width="17%">Author:</td>			
			<td><%=WI.getStrValue((String)vBookInfo.elementAt(5), "N/A")%></td>
		</tr>
		
		<tr>
			<td width="3%" height="20">&nbsp;</td>
			<td width="17%">Available Quantity:</td>
			<td width="30%"><%=WI.getStrValue((String)vBookInfo.elementAt(3), "0")%></td>
			<td width="17%">Price:</td>
			<td><%=comUtil.formatFloat((String)vBookInfo.elementAt(4),true)%></td>
		</tr>
		
		<tr>
			<td width="3%" height="20">&nbsp;</td>
			<td width="17%" colspan="2"><strong><%=strExtraMsg%>: &nbsp; &nbsp; <%=WI.getStrValue(strOrderedQty, "0")%></strong></td>
			
		</tr>
		
		<tr><td colspan="5" height="15">&nbsp;</td></tr>
	</table>
	
<%
boolean bolIsPageBreak = false;
int iResultSize = 11;
int iLineCount = 0;
int iMaxLineCount = 34;	
int iCount = 0;	
int i = 0;
while(iResultSize <= vRetResult.size()){
	iLineCount = 0;
%>

	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder" id="myTable3">			
		
		<tr>
			<td height="18" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Student Name</strong></td>
			<%
				if(WI.fillTextValue("catg_index").equals("2"))
					strTemp = "Course";
				else
					strTemp = "Year Level";
			%>
			<td width="20%" align="center" class="thinborder"><strong><%=strTemp%></strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Section</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Qty</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Ordered Date</strong></td>
		</tr>
	<% 			
		for(; i < vRetResult.size();){	
		iCount++;
		iLineCount++;		
		iResultSize += 11;		
	%>
		<tr>
			<td height="18" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
			<td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>			
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5), "N/A")%></td>	
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "N/A")%></td>		
			<td class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+9)), 4)%></td>	
		</tr>
		
		<%
			i+=11;
			if(iLineCount > iMaxLineCount){
				bolIsPageBreak = true;
				break;		
			}else
				bolIsPageBreak = false;	
		%>
	<%}%>
	</table>
	
	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>
	
<%}

if(iResultSize > vRetResult.size()){%>
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
			<tr><td colspan="3" height="25">&nbsp;</td></tr>
			<tr>
				<td height="25" width="28%">FOR IMDC USE ONLY</td>
				<td width="36%" align="center"></td>
				<td width="36%" align="right">&nbsp;</td>
			</tr>
			
			<tr>
		  		<td height="20">&nbsp;</td>
		  		<td>&nbsp;</td>
		  		<td align="right">&nbsp;</td>
	  		</tr>
			<tr align="center">		  
		  		<td><table width="90%" cellpadding="0" cellspacing="0" border="0"><tr><td class="thinborderBOTTOM">&nbsp;</td></tr></table></td>
		  		<td height="25">&nbsp;</td>
		  		<td><table width="90%" cellpadding="0" cellspacing="0" border="0">
					<tr><td class="thinborderBOTTOM" align="center">&nbsp;
					<%=request.getSession(false).getAttribute("first_name")%> <%=WI.getTodaysDateTime()%></td></tr></table></td>
	  		</tr>
			<tr align="center">
		  		<td>APPROVED BY/DATE </td>
		  		<td>&nbsp;</td>		  
		  		<td>VERIFIED BY/DATE</td>
	  		</tr>
	</table>



<%
	}//end if(iResultSize > vRetResut.size())
}//end if vRetResult != null%>	
</body>
</html>
<%
dbOP.cleanUP();
%>