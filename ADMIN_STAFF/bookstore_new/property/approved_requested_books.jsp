<%@ page language="java" import="utility.*, citbookstore.BookRequest,citbookstore.BookManagement, java.util.Vector"%>
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
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Ordering</title></head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
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
	
	function PageAction(strAction,strInfoIndex){
		
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete book request?'))
				return;
		}
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
			
		document.form_.page_action.value=strAction;
		document.form_.submit();
	}
	
	function UpdatePublisher(){
		var pgLoc = "./publisher.jsp";	
		var win=window.open(pgLoc,"UpdatePublisher",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function checkAllSaveItems() {
			
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function SelectBookRequested(objChkBox, objVal) {
		var reqType = document.form_.is_book_type[document.form_.is_book_type.selectedIndex].value;
		var maxDisp = document.form_.item_count.value;	
		
		var strOrigVal = document.form_.add_on.value;
		
		if(strOrigVal.length == 0){			
			strOrigVal = ",";
		}
			
		var iIndexOf; var strTemp;
		//for(var i =1; i< maxDisp; ++i){		
			iIndexOf = 	strOrigVal.indexOf(","+objVal+","+objQty.value+",");
			
			if(objChkBox.checked) {
				if(iIndexOf == -1){					
					strOrigVal =  strOrigVal + objVal+"," + objQty.value + ",";
				}
			}
			else if(iIndexOf > -1) {	
				strTemp = strOrigVal;				
				strOrigVal =  strOrigVal.substring(0, iIndexOf+1); 
				if(strTemp.length == (strOrigVal.length + objVal.length + objQty.value.length + 2)) {				
				}
				else{					
					strOrigVal = strOrigVal + strTemp.substring(iIndexOf + objVal.length + 1 + objQty.value.length + 2);					
				}
			}
		//}
			
		document.form_.sel_book.value = strOrigVal ;//+ obj.value;
			
	} 	
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-BOOK MANAGEMENT","approved_requested_books.jsp");
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	int iSearchResult = 0;
	Vector vEditInfo = null;	
	Vector vRetResult = null;
	Vector vApprovedBook = null;
	
	BookRequest br = new BookRequest();
	BookManagement bm = new BookManagement();
	double dTotalOrdered = 0d;
	double dTotalPaid    = 0d;
	double dBalance      = 0d;
	
	String strStudIndex  = null;
	
	String strOrderIndex = WI.fillTextValue("order_index");	
	
	
	
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0) {
		if(br.operateOnBookDeliveryProcess(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = br.getErrMsg();
		else{
			//if(strTemp.equals("0"))
			//	strErrMsg = "Request Successful Deleted.";
			if(strTemp.equals("1"))
				strErrMsg = "Requested Books Approved.";			
			//if(strTemp.equals("2"))
			//	strErrMsg = "Request Successful Edited.";
				
			strPrepareToEdit = "0";
		}	
			
	}
	
	if(WI.fillTextValue("show_info").compareTo("1")==0){
		vRetResult = br.operateOnBookRequest(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = br.getErrMsg();
			
		vApprovedBook = br.operateOnBookDeliveryProcess(dbOP, request, 2);
		if(vApprovedBook == null)
			strErrMsg = br.getErrMsg();
	}
	
	
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./approved_requested_books.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: PROPERTY REQUEST MONITORING ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		
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
			<td>Transaction Date: </td>
			<%
				strTemp = WI.fillTextValue("transaction_date");
				if(strTemp.length() == 0) 
					strTemp = WI.getTodaysDate(1);
			%>
			<td><input name="transaction_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />			  &nbsp; 
				<a href="javascript:show_calendar('form_.transaction_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
		  	<td height="25" colspan="2">&nbsp;</td>
	  	  <td height="25"><input type="button" name="request_book2" value=" VIEW REQUESTED BOOKS " 
					onclick="document.form_.show_info.value='1'; document.form_.submit();" style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></td>
	  </tr>
	</table>

<%if(WI.fillTextValue("show_info").equals("1")){%>
	<%if(vRetResult != null && vRetResult.size() >0){%>

		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr>
				<td height="20" bgcolor="#B9B292" colspan="10" class="thinborder"><div align="center"><strong>LIST OF REQUESTED BOOKS </strong></div></td>
			</tr>
			<tr>
				<td width="5%"  align="center" height="25" class="thinborder"><strong>Count</strong></td>
				<td width="25%" align="center" class="thinborder"><strong>Title</strong></td>
				<td width="20%" align="center" class="thinborder"><strong>Author</strong></td>
				<td width="20%" align="center" class="thinborder"><strong>Publisher</strong></td>				
				<td width="15%" align="center" class="thinborder"><strong>Quantity</strong></td>				
				<td width="15%"  align="center" class="thinborder"><strong>SELECT ALL<br /></strong>
					<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();">
				</td>
			</tr>
			
			<%
			int iCount=1;
			for(int i=0;i<vRetResult.size();i+=6,iCount++){%>
			<tr>	
				<td width="5%"  align="center" height="25" class="thinborder"><strong><%=iCount%></strong></td>
				<td width="18%" align="" class="thinborder"><strong><%=(String)vRetResult.elementAt(i+1)%></strong></td>
				<td width="18%" align="" class="thinborder"><strong><%=WI.getStrValue(vRetResult.elementAt(i+2),"N/A")%></strong></td>
				<td width="16%" align="" class="thinborder"><strong><%=WI.getStrValue(vRetResult.elementAt(i+4),"N/A")%></strong></td>				
				<td width="12%" align="center" class="thinborder"><strong><%=(String)vRetResult.elementAt(i+3)%></strong></td>								
				<td height="25" align="center" class="thinborder">
					<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1">
				</td>
			</tr>
			<%}%>
			<input type="hidden" name="item_count" value="<%=iCount%>" />			
		</table>
		
		

		<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td><input type="button" name="request_book" value=" APPROVED REQUESTED BOOKS " 
					onclick="document.form_.page_action.value='1'; document.form_.submit();" style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></td>
			</tr>
			<tr><td height="25">&nbsp;</td></tr>	
			
		</table>
<%}//end of vRetResult!=null%>



<%if(vApprovedBook != null && vApprovedBook.size() >0){%>

		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr>
				<td height="20" bgcolor="#B9B292" colspan="10" class="thinborder"><div align="center"><strong>LIST OF APPROVED BOOKS </strong></div></td>
			</tr>
			<tr>
				<td width="5%"  align="center" height="25" class="thinborder"><strong>Count</strong></td>
				<td width="20%" align="center" class="thinborder"><strong>Title</strong></td>
				<td width="20%" align="center" class="thinborder"><strong>Author</strong></td>
				<td width="20%" align="center" class="thinborder"><strong>Publisher</strong></td>				
				<td width="10%" align="center" class="thinborder"><strong>Quantity</strong></td>								
				<td width="15%" align="center" class="thinborder"><strong>Approved By</strong></td>
				<td width="10%" align="center" class="thinborder"><strong>Approved Date</strong></td>
			</tr>
			
			<%
			int iCount=1;
			for(int i=0;i<vApprovedBook.size();i+=8,iCount++){%>
			<tr>	
				<td align="center" height="25" class="thinborder"><strong><%=iCount%></strong></td>
				<td align="" class="thinborder"><strong><%=(String)vApprovedBook.elementAt(i+1)%></strong></td>
				<td align="" class="thinborder"><strong><%=WI.getStrValue(vApprovedBook.elementAt(i+2),"N/A")%></strong></td>
				<td align="" class="thinborder"><strong><%=WI.getStrValue(vApprovedBook.elementAt(i+4),"N/A")%></strong></td>				
				<td align="center" class="thinborder"><strong><%=(String)vApprovedBook.elementAt(i+3)%></strong></td>												
				<td align="" class="thinborder"><strong><%=(String)vApprovedBook.elementAt(i+7)%></strong></td>												
				<td align="" class="thinborder"><strong><%=(String)vApprovedBook.elementAt(i+6)%></strong></td>
			</tr>
			<%}%>					
		</table>
		
<%}//end of vRetResult!=null%>




<%}//if show info ==1%>













	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="show_info" value="<%=WI.fillTextValue("show_info")%>" />
	<input type="hidden" name="page_action" />
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="sel_book" value="<%=WI.fillTextValue("sel_book")%>"  />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
