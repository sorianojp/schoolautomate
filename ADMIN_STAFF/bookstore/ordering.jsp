<%@ page language="java" import="utility.*, bookstore.BookOrders, bookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Ordering</title></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript">
	
	var objCOA;
	var objCOAInput;
	function AjaxMapOrders() {
		var strIDNumber = document.form_.id_number.value;
		objCOAInput = document.getElementById("coa_info");
		eval('objCOA=document.form_.id_number');
		if(strIDNumber.length < 3) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var vSemester = document.form_.offering_sem.value;
		var vSyFrom = document.form_.sy_from.value;
		var vSyTo = document.form_.sy_to.value;
		
		if(document.form_.search_type.checked)
			var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strIDNumber);
		else
			var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20700&for_order=1&id_number="+escape(strIDNumber)+"&offering_sem="+vSemester+"&sy_from="+vSyFrom+"&sy_to="+vSyTo;
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOA.value = strID;
		objCOAInput.innerHTML = "";
		document.form_.search_type.checked = false;
		this.AjaxMapOrders();
	}
	
	function updateCustomerCode(strOrderIndex, strIDNumber, strOrderNumber){
		document.form_.id_number.value = strIDNumber;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.order_index.value = strOrderIndex;
		document.form_.submit();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function CancelOrder(){
		document.form_.cancel_order.value = "1";
		document.form_.submit();
	}
	
	function newTransaction(){
		document.form_.new_transaction.value = "1";
		document.form_.submit();
	}
	
	function deleteItems(){
		if(!confirm('Are you sure you want to remove this item from order list.'))
			return;
		document.form_.delete_items.value = "1";
		document.form_.submit();
	}
	
	function CancelOperation(){
		document.form_.cancel_order.value = "1";
		document.form_.delete_items.value = "";
		document.form_.submit();
	}
	
	function AddOrderItems(strOrderIndex, strBookCatg, strClassification, strBookType, strCourseIndex){
		var strIncNoStock = "1";
		<%if(bolIsCIT){%>
			strIncNoStock = "";
		<%}%>
		var pgLoc = "./add_order_items.jsp?for_order=1&include_no_stocks="+strIncNoStock+"&search_books=1&is_book_type="+strBookType+"&order_index="+strOrderIndex+"&book_catg="+strBookCatg+"&classification="+strClassification+"&course_index="+strCourseIndex;	
		var win=window.open(pgLoc,"AddOrderItems",'width=1024,height=600,top=20,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function checkAllDeleteItems() {
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllDeleteItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.del_'+i+'.checked='+bolIsSelAll);
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function releaseItems(strOrderNumber){
		var pgLoc = "./release_items.jsp?is_forwarded=1&get_order_info=1&id_number="+strOrderNumber;
		var win=window.open(pgLoc,"releaseItems",'width=900,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function PrintOrderList(strOrderIndex){
		var pgLoc = "./print_orderlist.jsp?order_index="+strOrderIndex;
		var win=window.open(pgLoc,"PrintOrderList",'width=900,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-BOOK MANAGEMENT","ordering.jsp");
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
	
	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};
	String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	
	int iSearchResult = 0;
	Vector vOrderInfo = null;
	Vector vOrderItems = null;
	Vector vRetResult = null;
	BookOrders bo = new BookOrders();
	BookManagement bm = new BookManagement();
	
	double dTotalOrdered = 0d;
	double dTotalPaid    = 0d;
	double dBalance      = 0d;
	
	String strStudIndex  = null;
	
	String strOrderIndex = WI.fillTextValue("order_index");
	String strIsPaymentFirst = WI.getStrValue(bo.checkIfPaymentFirst(dbOP, request));
	
	if(WI.fillTextValue("cancel_order").length() > 0){
		if(!bo.cancelOrder(dbOP, request))
			strErrMsg = bo.getErrMsg();
		else{
			strErrMsg = "Order canceled successfully.";
			strOrderIndex = "";
		}
	}
	
	if(WI.fillTextValue("delete_items").length() > 0){
		if(!bo.deleteOrderItems(dbOP, request))
			strErrMsg = bo.getErrMsg();
		else
			strErrMsg = "Item(s) removed successfully.";
	}
	
	if(WI.fillTextValue("new_transaction").length() > 0){
		strOrderIndex = bo.createNewTransaction(dbOP, request);
		if(strOrderIndex == null){
			strErrMsg = bo.getErrMsg();
			strOrderIndex = "";
		}
	}
	
	if(strOrderIndex.length() > 0){
		vOrderInfo = bo.viewOrderInfo(dbOP, request, strOrderIndex, "2");
		if(vOrderInfo == null)
			strErrMsg = bo.getErrMsg();
		else{
			vOrderItems = bo.getOrderedItems(dbOP, request, strOrderIndex);
			if(vOrderItems == null)
				strErrMsg = bo.getErrMsg();
		}
	}

if(WI.fillTextValue("id_number").length() > 0) 
	strStudIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("id_number"));
	
if(strStudIndex != null) {
	dTotalOrdered = bo.getStudentTotalOrderForSem(dbOP, request, strStudIndex, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("offering_sem"));
	dTotalPaid    = bo.getStudentPaidAmount(dbOP, request, strStudIndex, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("offering_sem"));
	dBalance      = dTotalPaid - dTotalOrdered;
}
%>
<body bgcolor="#D2AE72" onload="document.form_.id_number.focus();">
<form name="form_" action="./ordering.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: ORDERING ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3">
				<input name="search_type" type="checkbox" value="1" checked onclick="javascript:AjaxMapOrders()">
				<font size="1">check to search students, uncheck to search student orders</font></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">SY/Term:</td>
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
					readonly="yes"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>ID Number:</td>
			<td>
				<input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapOrders();">
				&nbsp;&nbsp;
				<label id="coa_info" style="width:300px; position:absolute"></label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Transcation Date: </td>
			<%
				strTemp = WI.fillTextValue("transaction_date");
				if(strTemp.length() == 0) 
					strTemp = WI.getTodaysDate(1);
			%>
			<td>
				<input name="transaction_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.transaction_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
		  	<td height="25" colspan="2">&nbsp;</td>
		  	<td height="25">
			<input type="button" name="transaction_butt" value=" New Order Transaction " 
					onclick="javascript:newTransaction();" style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></td>
	  </tr>
	</table>
	
<%if(vOrderInfo != null && vOrderInfo.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="6"><hr size="1" /></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="16%">Name:</td>
			<td width="16%"><%=(String)vOrderInfo.elementAt(8)%></td>
		    <td width="14%">Order Number:</td>
		    <td width="16%"><%=(String)vOrderInfo.elementAt(3)%></td>
		    <td align="right">&nbsp;
				<%if(vOrderItems != null && vOrderItems.size() > 0){%>
					<!--
					<input type="button" name="print_order" value=" Print Order " 
						onclick="javascript:PrintOrder('<%=(String)vOrderInfo.elementAt(7)%>');"
						style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
					&nbsp;&nbsp;
					-->
				<%}
			
				strTemp = (String)vOrderInfo.elementAt(6);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");//System.out.println(strTemp);
				if(Double.parseDouble(strTemp) > 0 && (iAccessLevel > 1)){%>
					<!--
					<input type="button" name="pay" value=" Pay " 
						onclick="javascript:payOrder('<%=(String)vOrderInfo.elementAt(3)%>');"
						style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
					&nbsp;&nbsp;
					-->
				<%}
				
				if(Double.parseDouble(strTemp) > 0 && (iAccessLevel > 1) && strIsPaymentFirst.equals("1")){%>
					<input type="button" name="pay" value=" Release Items " 
						onclick="javascript:releaseItems('<%=(String)vOrderInfo.elementAt(3)%>');"
						style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
					&nbsp;&nbsp;
				<%}
			
				if(iAccessLevel > 1 && !bolIsCIT){%>			
					<input type="button" name="cancelorder" value=" Cancel Order " onclick="javascript:CancelOrder();"
						style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
				<%}%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>ID Number: </td>
			<td><%=(String)vOrderInfo.elementAt(1)%></td>
		    <td>Total:</td>
		    <td><strong>Php<%=(String)vOrderInfo.elementAt(5)%></strong></td>
		    <td>TOTAL PAID: <%=CommonUtil.formatFloat(dTotalPaid, true)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>SY/Term:</td>
			<td><%=astrSemester[Integer.parseInt((String)vOrderInfo.elementAt(9))]%>/<%=(String)vOrderInfo.elementAt(10)%>-<%=(String)vOrderInfo.elementAt(11)%></td>
		    <td>Discount: </td>
		    <td><strong>Php<%=(String)vOrderInfo.elementAt(4)%></strong></td>
		    <td> ORDERED: <%=CommonUtil.formatFloat(dTotalOrdered, true)%></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="16%">Transaction Date : </td>
			<td><%=(String)vOrderInfo.elementAt(2)%></td>
	        <td>Payable Amt: </td>
	        <td><strong>Php<%=(String)vOrderInfo.elementAt(6)%></strong></td>
            <td style="font-weight:bold; color:#0000FF; font-size:14px;"><%if(strIsPaymentFirst.equals("1")) {%>BALANCE: <%=CommonUtil.formatFloatToLedger(dBalance)%><%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="6"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
	      <td height="25" colspan="4">
				<input type="button" name="add_order_items" value=" Add Book Type Items " 
					onclick="javascript:AddOrderItems('<%=strOrderIndex%>', '<%=(String)vOrderInfo.elementAt(12)%>', '<%=(String)vOrderInfo.elementAt(13)%>', '1', '<%=(String)vOrderInfo.elementAt(14)%>');"
					style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
				&nbsp;&nbsp;
				<input type="button" name="add_order_items_2" value=" Add Non-Book Type Items " 
					onclick="javascript:AddOrderItems('<%=strOrderIndex%>', '<%=(String)vOrderInfo.elementAt(12)%>', '<%=(String)vOrderInfo.elementAt(13)%>', '0', '<%=(String)vOrderInfo.elementAt(14)%>');"
					style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></td>
          <td height="25" align="right">
				<input type="button" name="rel_page" value=" Reload Page " onclick="javascript:ReloadPage();"
					style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
			<%if(vOrderItems != null && vOrderItems.size() > 0){%>
				&nbsp;&nbsp;
				<input type="button" name="rel_page" value=" Print Orderlist " onclick="javascript:PrintOrderList('<%=strOrderIndex%>');"
					style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
			<%}%></td>
		</tr>
	</table>
	
<%if(vOrderItems != null && vOrderItems.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr>
          	<td height="20" bgcolor="#B9B292" colspan="10" class="thinborder"><div align="center"><strong>LIST OF ORDERED ITEMS </strong></div></td>
        </tr>
        <tr>
			<td width="5%"  align="center" height="25" class="thinborder"><strong>Count</strong></td>
			<td width="18%" align="center" class="thinborder"><strong>Title</strong></td>
			<td width="18%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="16%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Item Price </strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Quantity</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Payable Amt </strong></td>
			<td width="7%"  align="center" class="thinborder"><strong>Select All<br /></strong>
              	<input type="checkbox" name="selAllDeleteItems" value="0" onclick="checkAllDeleteItems();" /></td>
        </tr>
        <%	
			int iCount = 1;
			for(int i = 0; i < vOrderItems.size(); i += 17, iCount++){
		%>
        <tr>
			<td height="25" class="thinborder" align="center"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vOrderItems.elementAt(i+5)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vOrderItems.elementAt(i+6), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vOrderItems.elementAt(i+16), "N/A")%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vOrderItems.elementAt(i+9), true)%>&nbsp;</td>
			<td class="thinborder">&nbsp;<%=(String)vOrderItems.elementAt(i+10)%></td>
				<input type="hidden" name="book_index_<%=iCount%>" value="<%=(String)vOrderItems.elementAt(i+1)%>" />
				<input type="hidden" name="order_qty_<%=iCount%>" value="<%=(String)vOrderItems.elementAt(i+10)%>" />
	  	  	<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vOrderItems.elementAt(i+11), true)%>&nbsp;</td>
		  	<td align="center" class="thinborder">
			<%if(((String)vOrderItems.elementAt(i+14)).equals("0")){%>
				<input type="checkbox" name="del_<%=iCount%>" value="<%=(String)vOrderItems.elementAt(i)%>" tabindex="-1" />
			<%}else{%>
				<input type="hidden" name="del_<%=iCount%>" value="" />
				&nbsp;
			<%}%></td>
		</tr>
        <%}%>
        <input type="hidden" name="item_count" value="<%=iCount%>" />
        <tr>
			<td height="25" colspan="10" align="center"><%if(iAccessLevel == 2){%>
		  		<input type="button" name="delete2" value=" Delete Item(s) " 
					onclick="javascript:deleteItems();" style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
              <%}else{%>
            		Not authorized to remove items from order.
              <%}%></td>
        </tr>
        <tr>
			<td height="20" colspan="10">&nbsp;</td>
        </tr>
	</table>
<%}}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="new_transaction" />
	<input type="hidden" name="order_index" value="<%=strOrderIndex%>" />
	<input type="hidden" name="cancel_order" />
	<input type="hidden" name="delete_items" />
	<input type="hidden" name="for_order" value="1" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
