<%@ page language="java" import="utility.*, citbookstore.BookOrders, citbookstore.BookManagement, java.util.Vector"%>
<%


	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">

 /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:0;
    width:350px;
	height:200;/** it expands on its own.. **/
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }
.nav {
     /**color: #000000;**/
	 font-weight:normal;
}
.nav-highlight {
     /**color: #0000FF;**/
     background-color:#BCDEDB;
}

</style>
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
		
		//if(document.form_.search_type.value=='1')
			var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strIDNumber);
		//else
		//	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20700&for_order=1&id_number="+escape(strIDNumber)+"&offering_sem="+vSemester+"&sy_from="+vSyFrom+"&sy_to="+vSyTo;		
		
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOA.value = strID;
		objCOAInput.innerHTML = "";
		document.form_.search_type.value = '0';
		this.AjaxMapOrders();
	}
	
	function updateCustomerCode(strOrderIndex, strIDNumber, strOrderNumber){
		document.form_.id_number.value = strIDNumber;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.order_index.value = strOrderIndex;s		
		document.form_.submit();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		document.form_.page_action.value='1';		
		document.form_.submit();
	}
	
	function UpdateNameFormat(strName) {
		document.form_.page_action.value='1';		
		document.form_.submit();
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
	
	function AddOrderItems(strYearLevel){
		var strIncNoStock = "1";
		<%if(bolIsCIT){%>
			strIncNoStock = "";
		<%}%>
		var pgLoc = "./add_optional.jsp?for_order=1&alert_level=1&classification=100&year_level_="+strYearLevel;	
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
	
	
	function PageAction(strPageAction){
		document.form_.page_action.value=strPageAction;		
		document.form_.submit();
	}

	
	function navRollOver(obj, state) {
	  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
	}
	
	function checkAllSaveItems() {
			
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function ViewSubjectEnrolled(){
		var pgLoc = "../enrollment/reports/student_sched_print.jsp?stud_id="+document.form_.id_number.value+"&sy_from="+document.form_.sy_from.value+" "+
			"&sy_to="+document.form_.sy_to.value+"&offering_sem="+document.form_.offering_sem.value;
		var win=window.open(pgLoc,"PrintOrderList",'width=900,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function HideLayer(strDiv) {			
			document.getElementById(strDiv).style.visibility = 'hidden';
	}
	
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-ORDERING-ORDER ITEMS BASIC","ordering_basic_edu.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-ORDERING-ORDER ITEMS BASIC"),"0"));
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
	Vector vUserDetails = null;
	Vector vBookDetails = null;
	Vector vTemp = new Vector();
	Vector vOrderingBook = null;
	

	String strBookTitle = null;
	BookOrders bo = new BookOrders();
	BookManagement bm = new BookManagement();
	
	//System.out.println("aaaa "+WI.fillTextValue("add_on"));
	
	String strAddOn = null;
	
	Vector vBookMagSelcted = new Vector();
	Vector vBookMagAdded   = new Vector();
	
	strAddOn = WI.fillTextValue("add_on");
		
	if(strAddOn == null || strAddOn.length()==0){}
	else
		strAddOn = strAddOn.substring(1,strAddOn.length()-1);
		
	vBookMagSelcted = CommonUtil.convertCSVToVector(strAddOn);	
	if(vBookMagSelcted== null)
		vBookMagSelcted = new Vector();
	else
		vBookMagAdded = bo.getAddedOrderItemsBasic(dbOP,request,vBookMagSelcted);		
	
	if(vBookMagAdded == null)
		strErrMsg = bo.getErrMsg();
	
	double dTotalOrdered = 0d;
	double dTotalPaid    = 0d;
	double dBalance      = 0d;
	boolean bolShowSave = true;	
	String strSQLQuery = null;
	String strTempIndex  = null;
	String strUserIndex = null;
	java.sql.ResultSet rs  = null;
	
	
	String strStudIndex  = null;
	
	String strOrderIndex = WI.fillTextValue("order_index");	
	String strIsPaymentFirst = WI.getStrValue(bo.checkIfPaymentFirst(dbOP, request));	
		
	//this is for getting info of student and their specified books
	if(WI.fillTextValue("page_action").compareTo("1")==0){	
		vRetResult = bo.viewBasicDetail(dbOP,request ,WI.fillTextValue("id_number"));		
		if(vRetResult == null){				
			strErrMsg = bo.getErrMsg();		
			bolShowSave = false;
		}else{
			vUserDetails = (Vector)vRetResult.remove(0);
			vBookDetails = (Vector)vRetResult.elementAt(0);
			
			if(vBookDetails == null)
				strErrMsg = bo.getErrMsg();
			else
				iSearchResult = bo.getSearchCount();	
				
			strUserIndex = (String)vUserDetails.elementAt(5);							
			if(strUserIndex != null){
				vOrderItems = bo.getOrderedItemsBasic(dbOP, request, strUserIndex);
				if(vOrderItems == null)
					strErrMsg = bo.getErrMsg();
			}
			
			
			
			request.getSession(false).setAttribute("classification_year_level",(String)vUserDetails.elementAt(2));
			
			vOrderingBook = bm.operateOnBooksForOrdering(dbOP, request,4);			
			//System.out.println(vOrderingBook);
		}
		
	//if the student orders
	}else if(WI.fillTextValue("page_action").compareTo("2")==0){//this is printing and ordering.
		//this is for creating order and printing slips..		
			strErrMsg = null;
			strSQLQuery = " select is_book_type from bs_book_order_items "+
			  " join bs_book_entry on (bs_book_entry.book_index = bs_book_order_items.book_index) "+
			  " join bs_book_type on (bs_book_type.type_index = bs_book_entry.type_index) "+
			  " join bs_book_order_main on (bs_book_order_main.order_index = bs_book_order_items.order_index) "+
			  " where bs_book_order_main.is_valid=1 and order_stat > 0 and payable_amt > 0 and sy_from = "+WI.fillTextValue("sy_from")+
			  " and semester = "+WI.fillTextValue("offering_sem")+" and payment_index is null and user_index="+WI.fillTextValue("stud_user_index");

			rs = dbOP.executeQuery(strSQLQuery);
			while(rs.next()){
				 if(rs.getString(1).equals("1"))
					  strErrMsg = "Student has a pending order and does not paid yet.";					 				 
			}rs.close();
		
			if(strErrMsg == null){
				strOrderIndex = bo.createNewTransaction(dbOP, request,2);
			
				if(strOrderIndex == null){
					strErrMsg = bo.getErrMsg();
					strOrderIndex = "";
				}else{
					
					if(!bo.addOrderItems(dbOP, request,strOrderIndex)){
						strErrMsg = bo.getErrMsg();						
						strOrderIndex = "";
					}else{					
						dbOP.cleanUP();
						response.sendRedirect("./print_orderlist.jsp?order_index="+strOrderIndex+
						"&sy_from="+WI.fillTextValue("sy_from")+"&offering_sem="+WI.fillTextValue("offering_sem"));
						return;
					}				
				}	
			}
					
	}
	
%>
<body bgcolor="#D2AE72" onload="document.form_.id_number.focus();">
<form name="form_" action="./ordering_basic_edu.jsp" method="post">

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
		
		<!--<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3">
				<input name="search_type" type="checkbox" value="1" checked onclick="javascript:AjaxMapOrders()">
				<font size="1">check to search students, uncheck to search student orders</font></td>
		</tr>-->
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">SY/Term:</td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
		  	<td width="80%">
				<select name="offering_sem">
              	<%if(strTemp.equals("1")){%>
              		<option value="1" selected>Regular Sem</option>
              	<%}else{%>
              		<option value="1">Regular Sem</option>			
				
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
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  onKeyUp="AjaxMapOrders();">
				&nbsp;&nbsp;	
				<label id="coa_info" style="width:300px; position:absolute"></label>			
		  </td>
				
		</tr>
		
		<tr>
			<td height="25">&nbsp;</td>
			<td>Transaction Date: </td>
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
			<td height="25">&nbsp;</td>
			<td height="25">&nbsp;</td>
			<td colspan="2">
			<%if(iAccessLevel > 1){%>
			<input name="image" type="image" src="../../images/form_proceed.gif" onclick="PageAction('1');"/>
			<%}else{%>
			You are not authorized to access this page.
			<%}%>
			</td>
		</tr>
	</table>
	
	
<%if(vUserDetails != null && vUserDetails.size() > 0 && vBookDetails != null && vBookDetails.size() > 0){%>

<!------STUDENT DETAILS---------->
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" width="3%">&nbsp;</td>		
		<td width="" colspan="3">&nbsp;
		<%if(bolShowSave){%>
		<input type="button" name="view_subj_enrolled" value=" ADD OPTIONAL " onclick="AddOrderItems('<%=vUserDetails.elementAt(2)%>');"
			style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
		<%}%>	
		</td>	
		
	</tr>

	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="16%">Student Name:</td>
		<td width="25%"><%=(String)vUserDetails.elementAt(1)%></td>
		<td><input type="button" name="view_subj_enrolled" value="VIEW SUBJECTS ENROLLED" onclick="ViewSubjectEnrolled();"
			style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></td>
	</tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td>Grade/Year</td>
		<td colspan="2"><%=(String)vUserDetails.elementAt(3)%></td>		
	</tr>
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td>Section</td>		
		<td colspan="2"><%=WI.getStrValue(vUserDetails.elementAt(4),"N/A")%></td>		
	</tr>
</table>



<!----------LIST OF BOOKS ACCORDING TO GRADE LEVEL----------->


<%if(vBookDetails != null && vBookDetails.size() > 0){%>

	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">

		<tr>
			<%if(bolShowSave){%>
			<td colspan="11" align="right"><input type="button" value=" SAVE " name="save" onclick="PageAction('2');" 
				style="font-size:11px; height:28px;border: 1px solid #FF0000;" /> &nbsp; &nbsp; &nbsp; </td>
			<%}%>
		</tr>
	<tr><td height="15">&nbsp;</td></tr>
	</table>

	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="12" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>:::  BOOK ENTRY LISTING ::: </strong></div></td>
		</tr>
		<!--<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="6">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(bo.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="4"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/bo.defSearchSize;		
				if(iSearchResult % bo.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+bo.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.submit();">
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
					</select></div>
				<%}%> </td>
		</tr>-->
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Item Code </strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Book Title </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="8%" align="center" class="thinborder"><strong>Price</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Avail. Qty.</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Unpaid Unreleased </strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Paid Unreleased </strong></td>
			<!--<td width="5%" align="center" class="thinborder"><strong>Unreleased Qty.</strong></td>-->
			<td width="5%" align="center" class="thinborder"><strong>Max Order Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Order Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vBookDetails.size(); i+=16, iCount++){
			
			if(vOrderingBook != null && vOrderingBook.size() > 0){
				if(vOrderingBook.indexOf( (String)vBookDetails.elementAt(i)+".."+(String)vBookDetails.elementAt(i+4)) == -1){
					iCount--;
					continue;
				}				
			}
			
			strTemp = (String)vBookDetails.elementAt(i+7);
			if(strTemp.equals("0")){
				iCount--;
				continue;
			}
	%>
		<tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vBookDetails.elementAt(i+6)%></td>
				<input type="hidden" name="item_code_<%=iCount%>" value="<%=(String)vBookDetails.elementAt(i+6)%>"  />
			<td class="thinborder">&nbsp;<%=(String)vBookDetails.elementAt(i+4)%></td>
				<input type="hidden" name="book_title_<%=iCount%>" value="<%=(String)vBookDetails.elementAt(i+4)%>"  />
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vBookDetails.elementAt(i+9), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vBookDetails.elementAt(i+5), "N/A")%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vBookDetails.elementAt(i+8), true)%>&nbsp;</td>
				<input type="hidden" name="price_<%=iCount%>" value="<%=(String)vBookDetails.elementAt(i+8)%>" />
			<td class="thinborder">&nbsp;<%=(String)vBookDetails.elementAt(i+7)%></td>
				<input type="hidden" name="avail_qty_<%=iCount%>" value="<%=(String)vBookDetails.elementAt(i+7)%>" />
			<!--<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vBookDetails.elementAt(i+10), "0")%></td>-->
			<td class="thinborder"><%=WI.getStrValue((String)vBookDetails.elementAt(i+10), "0")%></td>
				<input type="hidden" name="unpaid_unreleased_<%=iCount%>" value="<%=(String)vBookDetails.elementAt(i+10)%>"  />
			<td class="thinborder"><%=WI.getStrValue((String)vBookDetails.elementAt(i+12), "0")%></td>
			<td class="thinborder" align="center"><%=WI.getStrValue((String)vBookDetails.elementAt(i+15),"1")%></td>
			<td class="thinborder" align="center">
				<input type="text" name="qty_<%=iCount%>" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','qty_<%=iCount%>');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','qty_<%=iCount%>')" size="3" maxlength="5" value="1"/></td>
			
			<%
			
				//if(WI.fillTextValue("course_index").equals("0") && ((String)vRetResult.elementAt(i+11)).equals("1"))
				//	strErrMsg = "checked";
					
				strTemp = "checked";
			%>
			<td class="thinborder" align="center">
				<input type="checkbox" name="save_<%=iCount%>" 
					value="<%=(String)vBookDetails.elementAt(i)%>" tabindex="-1" <%=strTemp%> >
			</td>
		</tr>
	<%}%>
		<input type="hidden" name="item_count" value="<%=iCount%>" />
		<tr><td height="15">&nbsp;</td></tr>
		<tr>
			<%if(bolShowSave){%>
			<td colspan="12" align="right"><input type="button" value=" SAVE " name="save" onclick="PageAction('2');" 
				style="font-size:11px; height:28px;border: 1px solid #FF0000;" /> &nbsp; &nbsp; &nbsp; </td>
			<%}%>
		</tr>
		
	</table>
<%}//end of vBookDetails%>




<%if(vBookMagAdded != null && vBookMagAdded.size() > 0){%>
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
				<td height="15">&nbsp;</td>
			</tr>
		</table>
		
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr>
				<td height="20" bgcolor="#B9B292" colspan="10" class="thinborder">
				<div align="center"><strong>LIST OF ADDED ITEMS </strong></div></td>
			</tr>
			<tr>
				<td width="5%"  align="center" height="25" class="thinborder"><strong>Count</strong></td>
				<td width="18%" align="center" class="thinborder"><strong>Title</strong></td>
				<td width="21%" align="center" class="thinborder"><strong>Author</strong></td>
				<td width="20%" align="center" class="thinborder"><strong>Publisher</strong></td>
				<td width="12%" align="center" class="thinborder"><strong>Item Price </strong></td>
				<td width="12%" align="center" class="thinborder"><strong>Quantity</strong></td>
				<td width="12%" align="center" class="thinborder"><strong>Payable Amt </strong></td>
				
			</tr>
			<%	
				int iCount = 1;
				for(int i = 0; i < vBookMagAdded.size(); i += 10, iCount++){					
			%>
			<tr>
				<td height="25" class="thinborder" align="center"><%=iCount%></td>
				<td class="thinborder">&nbsp;<%=(String)vBookMagAdded.elementAt(i+2)%></td>
				<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vBookMagAdded.elementAt(i+3), "N/A")%></td>
				<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vBookMagAdded.elementAt(i+4), "N/A")%></td>
				<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vBookMagAdded.elementAt(i+5), true)%>&nbsp;
				</td>
				<td class="thinborder">&nbsp;<%=(String)vBookMagAdded.elementAt(i+8)%></td>					
				<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vBookMagAdded.elementAt(i+9), true)%>&nbsp;
				</td>
			</tr>
			<%}%>
		</table>

<%}%>	


<%if(vOrderItems != null && vOrderItems.size() > 0){%>	
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
				<td height="15">&nbsp;</td>
			</tr>
		</table>
		
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr>
				<td height="20" bgcolor="#9999FF" colspan="10" class="thinborder">
				<div align="center"><strong>HISTORY OF ORDERED ITEMS </strong></div></td>
			</tr>
			<tr  bgcolor="#CCCCFF">
				<td width="5%"  align="center" height="25" class="thinborder"><strong>Count</strong></td>
				<td width="20%" align="center" class="thinborder"><strong>Title</strong></td>
				<td width="15%" align="center" class="thinborder"><strong>Author</strong></td>
				<td width="15%" align="center" class="thinborder"><strong>Publisher</strong></td>
				<td width="10%" align="center" class="thinborder"><strong>Item Price </strong></td>
				<td width="10%" align="center" class="thinborder"><strong>Quantity</strong></td>
				<td width="10%" align="center" class="thinborder"><strong>Ordered Date</strong></td>
				<td width="8%" align="center" class="thinborder"><strong>Payable Amt </strong></td>
				<td width="7%" align="center" class="thinborder"><strong>Status</strong></td>				
			</tr>
			<%	
				int iCount = 1;
				String strColor = null;
				for(int i = 0; i < vOrderItems.size(); i += 18, iCount++){
				
					strTemp = (String)vOrderItems.elementAt(i+17);
					if(strTemp != null){
						strTemp = "Paid";
						strColor = "#CCCCFF";
					}
					else{
						strTemp = "Unpaid";
						strColor = "#999999";
					}
					
				
				
			%>
			<tr  bgcolor="<%=strColor%>">
				<td bgcolor="" height="25" class="thinborder" align="center"><%=iCount%></td>
				<td class="thinborder">&nbsp;<%=(String)vOrderItems.elementAt(i+5)%></td>
				<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vOrderItems.elementAt(i+6), "N/A")%></td>
				<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vOrderItems.elementAt(i+16), "N/A")%></td>
				<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vOrderItems.elementAt(i+9), true)%>&nbsp;</td>
				<td class="thinborder">&nbsp;<%=(String)vOrderItems.elementAt(i+10)%></td>					
				<td class="thinborder">&nbsp;<%=((String)vOrderItems.elementAt(i+12)).substring(0,10)%></td>					
				<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vOrderItems.elementAt(i+11), true)%>&nbsp;</td>		
					
				<td class="thinborder">&nbsp;<%=strTemp%></td>					
			</tr>
			<%}%>			
		</table>

<%}//end of vOrderItems%>



<%
String strAlertFinal = null;
	if(vBookDetails != null && vBookDetails.size() > 0){
	int iAvailQty = 0;
	int iAlertLevel = 0;
	int iAlertFinal = 0;
		for(int x=0; x < vBookDetails.size() ; x+=16){
			iAvailQty = Integer.parseInt((String)vBookDetails.elementAt(x+7));
			iAlertLevel = Integer.parseInt((String)vBookDetails.elementAt(x+13));
			iAlertFinal = Integer.parseInt((String)vBookDetails.elementAt(x+14));
			if((iAvailQty <= iAlertLevel) && (iAvailQty > iAlertFinal)){
				if(strBookTitle == null)
					strBookTitle = (String)vBookDetails.elementAt(x+4) +
					", "+(String)vBookDetails.elementAt(x+7)+", "+(String)vBookDetails.elementAt(x+13);
				else
					strBookTitle += ", " + (String)vBookDetails.elementAt(x+4) +
					", "+(String)vBookDetails.elementAt(x+7)+", "+(String)vBookDetails.elementAt(x+13);
			}
			
			if(iAvailQty <= iAlertFinal){
				if(strAlertFinal == null)
					strAlertFinal = (String)vBookDetails.elementAt(x+4) +
					", "+(String)vBookDetails.elementAt(x+7)+", "+(String)vBookDetails.elementAt(x+14);
				else
					strAlertFinal += ", " + (String)vBookDetails.elementAt(x+4) +
					", "+(String)vBookDetails.elementAt(x+7)+", "+(String)vBookDetails.elementAt(x+14);
			}
		}	
	}


if(strBookTitle != null){

vTemp = CommonUtil.convertCSVToVector(strBookTitle);

%>
<div id="processing2" class="processing">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#FFCC99">
  <tr><td valign="top" align="right"><a href="javascript:HideLayer('processing2')">Close Window X</a></td></tr>	  	  
  <tr><td valign="top" align="center"><u><b>List of Books within FIRST ALERT LEVEL</b></u></td></tr>
  <tr>
	  <td valign="top">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<%if(vTemp.size()>0 && vTemp != null){%>
			  <tr>
			  	<td width="70%" style="font-size:11px;"><u>Book Title</u></td>
				<td align="center" width="15%" style="font-size:11px;"><u>Available Qty</u></td>
				<td align="center" width="15%" style="font-size:11px;"><u>Order Point</u></td>
			  </tr>
			<%for(int i=0; i<vTemp.size(); i+=3){%>
			  <tr>
				  <td width="70%" style="font-size:11px;"><%=vTemp.elementAt(i)%></td>				 
				  <td align="center" width="15%" style="font-size:11px;" valign="top"><%=vTemp.elementAt(i+1)%></td>
				  <td align="center" width="15%" style="font-size:11px;" valign="top"><%=vTemp.elementAt(i+2)%></td>
			  </tr>
			  <%}%>
			<%}%>
		</table>
	  </td>
  </tr>
</table>
</div>
<%}

if(strAlertFinal != null){

vTemp = CommonUtil.convertCSVToVector(strAlertFinal);

%>
<div id="processing" class="processing">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#9999CC">
  <tr><td valign="top" align="right"><a href="javascript:HideLayer('processing')">Close Window X</a></td></tr>	  	  
  <tr><td valign="top" align="center"><u><b>List of Books within FINAL ALERT LEVEL</b></u></td></tr>
  <tr>
	  <td valign="top">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<%if(vTemp.size()>0 && vTemp != null){%>
			  <tr>
			  	<td width="70%" style="font-size:11px;"><u>Book Title</u></td>
				<td align="center" width="15%" style="font-size:11px;"><u>Available Qty</u></td>
				<td align="center" width="15%" style="font-size:11px;"><u>Order Point</u></td>
			  </tr>
			<%for(int i=0; i<vTemp.size(); i+=3){%>
			  <tr>
				  <td width="70%" style="font-size:11px;"><%=vTemp.elementAt(i)%></td>				 
				  <td align="center" width="15%" style="font-size:11px;" valign="top"><%=vTemp.elementAt(i+1)%></td>
				  <td align="center" width="15%" style="font-size:11px;" valign="top"><%=vTemp.elementAt(i+2)%></td>
			  </tr>
			  <%}%>
			<%}%>
		</table>
	  </td>
  </tr>
</table>
</div>
<%}%>

<%}//end of vUserDetails%>
	
	


	<input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>" />
	<input type="hidden" name="new_transaction" />
	<input type="hidden" name="order_index" value="<%=strOrderIndex%>" />
	<input type="hidden" name="stud_user_index" value="<%=strUserIndex%>"  />
	<input type="hidden" name="cancel_order" />
	<input type="hidden" name="delete_items" />
	<input type="hidden" name="for_order" value="1" />
	<input type="hidden" name="unlock_button" value="<%=WI.fillTextValue("unlock_button")%>"  />
	<input type="hidden" name="add_on" value="<%=WI.fillTextValue("add_on")%>"  />
	<input type="hidden" name="basic_order" value="1" />
	<input type="hidden" name="search_type"  value="1"/>
	
	<input type="hidden" name="book_catg" value="1" /> <!--this is basic education. used in getting the list of ordering per sem-->
	
</form>
								
</body>
</html>

<%
dbOP.cleanUP();
%>
