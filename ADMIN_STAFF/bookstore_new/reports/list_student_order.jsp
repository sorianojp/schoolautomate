<%@ page language="java" import="utility.*, citbookstore.BookReports, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	
	int iAction = Integer.parseInt(WI.getStrValue(WI.fillTextValue("iAction"),"100"));
	
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>List of Student Order</title></head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">

	function SearchBooks(){
		document.form_.search_books.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	
	function PrintPg(){
		var dateType = document.form_.date_type.value;
		
		var strSortBy1 = document.form_.sort_by1.value;
		var strSortBy2 = document.form_.sort_by2.value;
		var strSortBy3 = document.form_.sort_by3.value;
		
		var strSortBy1Con = document.form_.sort_by1_con.value;
		var strSortBy2Con = document.form_.sort_by2_con.value;
		var strSortBy3Con = document.form_.sort_by3_con.value;
		
		
		var pgLoc = "./print_list_student_order.jsp?book_index="+document.form_.book_index.value+"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+"&offering_sem="+document.form_.offering_sem.value+"&iAction="+<%=iAction%>+
		"&catg_index="+document.form_.catg_index.value+"&view_all=1&date_type="+dateType+"&date_fr="+document.form_.date_fr.value;
		if(dateType != 1)
			pgLoc = pgLoc + "&date_to="+document.form_.date_to.value;
			
		pgLoc = pgLoc + "&sort_by1="+strSortBy1+"&sort_by2="+strSortBy2+"&sort_by3="+strSortBy3+"&sort_by1_con="+strSortBy1Con+
			"&sort_by2_con="+strSortBy2Con+"&sort_by3_con="+strSortBy3Con;
			
		var win=window.open(pgLoc,"PrintPg",'width=1024,height=600,top=20,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	CommonUtil comUtil = new CommonUtil();
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-REPORTS","list_student_order.jsp");
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
	
	//String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
	//String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Transaction Date","Last Name","First Name"};
	String[] astrSortByVal     = {"create_time","lname","fname"};
	
	int iSearchResult = 0;
	Vector vRetResult = new Vector();
	Vector vTemp = new Vector();
	Vector vBookInfo = new Vector();
	BookReports br = new BookReports();
	String strOrderedQty = null;
	String strExtraMsg = null;
	
	if(iAction==2)
		strExtraMsg = "ORDERED QUANTITY";
	if(iAction==3)
		strExtraMsg = "RELEASED QUANTITY";
	if(iAction==4)
		strExtraMsg = "PAID and UNRELEASED QUANTITY";
	if(iAction==5)
		strExtraMsg = "UNPAID and UNRELEASED QUANTITY";
	
	if(WI.fillTextValue("search_books").length() > 0 && WI.fillTextValue("book_index").length() > 0){
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
				
				String strCon = "";
               	String strDateType = WI.fillTextValue("date_type");
               	String strDateFrom = WI.fillTextValue("date_fr");//date from search parameter
               	String strDateTo   = WI.fillTextValue("date_to");//date to search parameter

	 	        if(strDateType.equals("1")){
            		if(strDateFrom.length() > 0){
            		   strDateFrom = ConversionTable.convertTOSQLDateFormat(strDateFrom);
            		   if(strDateFrom == null)
            			   strCon = "";
            		   else
            		   	   strCon = " and transaction_date = '"+strDateFrom+"' ";
            	   }
               }else{
            	   if(strDateFrom.length() > 0 && strDateTo.length() > 0){
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
						" where payable_amt > 0 and order_stat > 0 and is_released > 0 and is_deducted = 1 and "+
						" payment_index is not null and sy_from="+strSYFrom+" and semester="+strSemester+
						" and is_valid=1 "+ strCon +
						" and book_index = "+WI.fillTextValue("book_index");
				}if(iAction == 4){
					strTemp = "	select sum(quantity) from bs_book_order_items "+
						" join bs_book_order_main on (bs_book_Order_main.order_index = bs_book_order_items.order_index) "+
						" where payable_amt > 0 and order_stat > 0 and is_released = 0 and is_deducted = 1 and "+
						" payment_index is not null and sy_from="+strSYFrom+" and semester="+strSemester+
						" and is_valid=1 "+ strCon +
						" and book_index = "+WI.fillTextValue("book_index");
				}if(iAction == 5){
					strTemp = "	select sum(quantity) from bs_book_order_items "+
						" join bs_book_order_main on (bs_book_Order_main.order_index = bs_book_order_items.order_index) "+
						" where payable_amt > 0 and order_stat > 0 and is_released = 0 and is_deducted = 0 and "+
						" payment_index is null and sy_from="+strSYFrom+" and semester="+strSemester+
						" and is_valid=1 "+ strCon +
						" and book_index = "+WI.fillTextValue("book_index");
				}
				strOrderedQty = dbOP.getResultOfAQuery (strTemp , 0);
				
			}			
		}
	}
	
	
		
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./list_student_order.jsp" method="post">
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="" id="myTable1">
		<tr><td height="25" id="TR1" bgcolor="#B9B292" align="center"><strong><%=strExtraMsg%></strong></td></tr>	
		<tr><td height="25" style="padding-left:30px;"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="" id="myTable5">
	<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">SY/TERM: </td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
			<td width="80%">
				<select name="offering_sem">
              	<%if(strTemp.equals("1")){%>
              		<option value="1" selected>1st Sem</option>
              	<%}else{%>
              		<option value="1">1st Sem</option>
				
				<%}if(strTemp.equals("2")){%>
              		<option value="2" selected>2nd Sem</option>
              	<%}else{%>
              		<option value="2">2nd Sem</option>
					
				<%}if(strTemp.equals("3")){%>
              		<option value="3" selected>3rd Sem</option>
              	<%}else{%>
              		<option value="3">3rd Sem</option>
				
				<%}if(strTemp.equals("0")){%>
              		<option value="0" selected>Summer</option>
              	<%}else{%>
              		<option value="0">Summer</option>
              	<%}%>
            	</select>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
				%>
				<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
				-
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
				%>
				<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					readonly="yes">
			
			</td>
		</tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Transaction Date: </td>
		<td width="80%">
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
			%>
			<select name="date_type" onchange="ReloadPage();">
				<%if (strTemp.equals("1")){%>
				<option value="1" selected>Specific Date</option>
				<%}else{%>
				<option value="1">Specific Date</option>
				<%}if (strTemp.equals("2")){%>
				<option value="2" selected>Date Range</option>
				<%}else{%>
				<option value="2">Date Range</option>
				<%}%>
			</select>
			<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
			<img src="../../../images/calendar_new.gif" border="0"></a>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
				if(strTemp.equals("2")){
			%>
			to 
			<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
			<img src="../../../images/calendar_new.gif" border="0"></a>
			<%}%></td>
	</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="" id="myTable5">
	<tr><td height="10" colspan="3"></td></tr>
	<tr>
          	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">Sort by: </td>
		  	<td width="20%">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=br.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="20%">
				<select name="sort_by2">
              		<option value="">N/A</option>
             		<%=br.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="40%">
				<select name="sort_by3">
					<option value="">N/A</option>
              		<%=br.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
            	</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>&nbsp;</td>
		    <td>
				<select name="sort_by1_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
				</select></td>
			<td>
				<select name="sort_by2_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
			<td>
				<select name="sort_by3_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
		</tr>
		</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="" id="myTable5">
	<tr><td height="10" colspan="3"></td></tr>
	<tr>
		<td height="25" colspan="2">&nbsp;</td>
		<td>
			<a href="javascript:SearchBooks();"><img src="../../../images/form_proceed.gif" border="0" /></a>
		</td>
	</tr>
	<tr>
		<td height="15" colspan="3">&nbsp;</td>
	</tr>
	</table>
<%if(vRetResult != null && vRetResult.size() > 0 && strErrMsg == null){%>	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="" id="myTable4">
		<tr>
			<td colspan="5" align="right">
			<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"/></a>
			<font size="1">Click to print result</font>
			</td>
		</tr>
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
	


	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder" id="myTable3">		
		
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(br.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="5"> &nbsp;
			<%
				int iPageCount = 1;
				if(!WI.fillTextValue("view_all").equals("1")){
					iPageCount = iSearchResult/br.defSearchSize;		
					if(iSearchResult % br.defSearchSize > 0)
						++iPageCount;
				}
				strTemp = " - Showing("+br.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page:			  
					  <select name="jumpto" onchange="SearchBooks();">
                        <%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i = 1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
                        <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                        <%}else{%>
                        <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                        <%}
						}%>
                      </select>
					</div>
				<%}%> </td>
		</tr>
		
		
		
		
		
		
		<tr>
			<td height="18" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="" align="center" class="thinborder"><strong>Student Name </strong></td>
			<%
				if(WI.fillTextValue("catg_index").equals("2"))
					strTemp = "Course";
				else
					strTemp = "Year Level";
			%>
			<td width="12%" align="center" class="thinborder"><strong><%=strTemp%></strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Section</strong></td>
			<td width="3%" align="center" class="thinborder"><strong>Qty</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Ordered Date</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Released Date</strong></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=11, iCount++){
	%>
		<tr>
			<td height="18" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
			<td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>			
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5), "N/A")%></td>	
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "N/A")%></td>		
			<td class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+9)), 4)%></td>	
			<%
			strTemp = (String)vRetResult.elementAt(i+10);
			if(strTemp == null)
				strTemp = "&nbsp;";
			else
				strTemp = WI.formatDateTime(Long.parseLong(strTemp), 4);
			%>
			<td class="thinborder">&nbsp;<%=strTemp%></td>	
		</tr>
	<%}%>
	</table>
<%}%>
	
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable2">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page" value="<%=WI.fillTextValue("print_page")%>" />
	<input type="hidden" name="search_books" />
	<input type="hidden" name="book_index" value="<%=WI.fillTextValue("book_index")%>"  />
	<input type="hidden" name="iAction" value="<%=WI.fillTextValue("iAction")%>"  />
	<input type="hidden" name="view_all" value="<%=WI.fillTextValue("view_all")%>" />	
	<input type="hidden" name="catg_index" value="<%=WI.fillTextValue("catg_index")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>