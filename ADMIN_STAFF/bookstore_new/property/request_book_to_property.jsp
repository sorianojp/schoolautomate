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
<style type="text/css">

 /*this is what we want the div to look like*/
  div.processing{
    display:none;	

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
  
  div.processing2{
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
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
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
	
	function loadClassification() {	
		var objCOA=document.getElementById("load_classification");
		var header = "All";
		var selName = "classification";
		var onChange = "";
		var tableName = "bed_level_info";
		var fields = "g_level,level_name";
		var headerValue = "";
		
		var vCondition = '';
		var vClassValue = document.form_.book_catg.value;
		if(vClassValue.length == 0)
			vCondition = ' where edu_level@0';
		else{
			if(vClassValue == '1')
				vCondition = '';
			else//if college
				vCondition = ' where edu_level@0';
		}
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20400&query_con="+vCondition+"&onchange="+onChange+"&sel_name="+selName+"&table_name="+tableName+"&fields="+fields+"&header="+header+"&header_value="+headerValue;
	
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
	
	
	function checkAllDeleteItems() {
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllDeleteItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.del_'+i+'.checked='+bolIsSelAll);
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function RefreshPage() {
		location = "./request_book_to_property.jsp";
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
		if(strAction == '1' && document.form_.book_catg.value == '1' && document.form_.classification.value == ''){
			alert("Please select grade level information.");
			return;
		}
		
		if(strAction == '1' && document.form_.book_catg.value.length == ''){
			alert("Please select book category information.");
			return;
		}
	
		
		if(strAction == '0' || strAction == '100') {
			if(!confirm('Do you want to delete book request?'))
				return;
		}
		
		if(strAction == '2'){
			document.form_.show_request_form.value='';
			document.form_.show_info.value = '1';
		}
		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
			
		document.form_.page_action.value=strAction;
		document.form_.submit();
	}
	
	function UpdatePublisher(){
		var pgLoc = "../publisher.jsp";	
		var win=window.open(pgLoc,"UpdatePublisher",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.show_request_form.value='1';
		document.form_.info_index.value = strInfoIndex;
		document.form_.show_info.value='1';
		document.form_.submit();
	}
	
	function HideLayer(strDiv) {			
		document.getElementById(strDiv).style.visibility = 'hidden';
	}
	
	function FinalizeRequest(strRequestIndex){
		if(!confirm("Are you sure you want to finalize this request item?"))
			return;		
			
		document.form_.info_index.value = strRequestIndex;
		document.form_.page_action.value='5';
		document.form_.prepareToEdit.value= '';		
		document.form_.show_info.value='1';
		document.form_.submit();
	}
	
	function ViewItems(strAction){
		if(strAction =='1'){
			document.form_.show_request_form.value='';
			document.form_.show_info.value='1';		
		}
		else{
			document.form_.show_request_form.value='1';
			document.form_.show_info.value='1';
		}
		document.form_.prepareToEdit.value='';
		document.form_.submit();
	}
	
	function PrintPg(){
		var pgLoc = "./print_requested_books.jsp?offering_sem="+document.form_.offering_sem.value+"&sy_from="+document.form_.sy_from.value+
			"&sy_to="+document.form_.sy_to.value+"&book_catg="+document.form_.book_catg.value+"&classification="+document.form_.classification.value+
			"&view_request_book=2&for_printing=1";
			
		var win=window.open(pgLoc,"PrintPg",'width=1000,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	/**<a href="javascript:PageAction('100','<%//=(String)vRetResult.elementAt(i)%>');">*/
	
	function CancelRequestedOrder(strInfoIndex){
		document.getElementById('processing').style.visibility = 'visible';		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.show_div.value = '1';		
		document.form_.submit();
	}
	
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolFatalErr = false;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-ORDERING-REQUEST BOOK","request_book_to_property.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-ORDERING-REQUEST BOOK"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
	
	strTemp = dbOP.mapOneToOther("BS_BOOK_LOGIN_TERMINAL","IP_ADDR","'"+request.getRemoteAddr()+"'",
                          "LOGIN_TERM_INDEX"," and is_valid = 1");
	if(strTemp == null) {
		strErrMsg = "IP : "+request.getRemoteAddr()+" IS NOT ASSINGED FOR LOGIN TERMINAL";
		bolFatalErr = true;
	}
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	int iSearchResult = 0;
	Vector vEditInfo = null;	
	Vector vRetResult = null;
	BookRequest br = new BookRequest();
		
	String strYearLevel = null;
	BookManagement bm = new BookManagement();	
	Vector vLocCatgIndex = new Vector();	
	vLocCatgIndex = bm.checkIPAddress(dbOP,request,request.getRemoteAddr());	
	
	String strOrderIndex = WI.fillTextValue("order_index");	
	
	String[] astrConvertSem = {"SUMMER","1st SEMESTER","2nd SEMESTER","3rd SEMESTER"};
	
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0) {
		if(br.operateOnBookRequest(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = br.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Request Successful Deleted.";
			if(strTemp.equals("1"))
				strErrMsg = "Request Successful Added.";			
			if(strTemp.equals("2"))
				strErrMsg = "Request Successful Edited.";
				
			strPrepareToEdit = "0";
		}	
			
	}
	
	
	if(WI.fillTextValue("show_info").compareTo("1")==0){
		vRetResult = br.operateOnBookRequest(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = br.getErrMsg();
		else
			iSearchResult = br.getSearchCount();
	}
	
	if(strPrepareToEdit.equals("1")){
		vEditInfo = br.operateOnBookRequest(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = bm.getErrMsg();
	}
	
	
	
	
%>
<body bgcolor="#D2AE72">
<%
if(bolFatalErr){
	dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3" color="#FFFF00">
		<strong><%=strErrMsg%></strong></font></p>
<%
	return;
}%>

<form name="form_" action="./request_book_to_property.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: ORDERING - REQUEST BOOK TO PROPERTY ::::</strong></font></div></td>
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
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Book Category :</td>
			<%	
			String strCatg = WI.fillTextValue("book_catg");			
			if(vEditInfo != null)
				strCatg = (String)vEditInfo.elementAt(8);
			
			%>
			
			<td><select name="book_catg" onChange="loadClassification();document.form_.submit();">
          			<%=dbOP.loadCombo("catg_index","catg_name", " from bs_book_catg where is_valid = 1 and catg_index="+(String)vLocCatgIndex.elementAt(1)+" order by catg_name ", strCatg, false)%> 
        		</select></td>
		</tr>
		
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Grade Level :</td>
			<%	
				strYearLevel = (String)vLocCatgIndex.elementAt(0);
				strErrMsg = "";				
				strTemp = WI.fillTextValue("classification");
				if(vEditInfo != null)
					strTemp = (String)vEditInfo.elementAt(7);
				else{
					if(strYearLevel.equals("1"))//college or not selected
						strErrMsg = " where edu_level = 0 ";
					else{
						if(strYearLevel.equals("2"))
							strErrMsg = " where g_level > 10 ";
						else
							strErrMsg = " where g_level < 11 ";
					}			
				}
					
			%>
			<td><label id="load_classification">
				<select name="classification" onchange="document.form_.submit();">										
					<%=dbOP.loadCombo("g_level","level_name", " from bed_level_info "+strErrMsg, strTemp, false)%> 
				</select>
				</label></td>
		</tr>
		
		
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
		  	<td height="25" colspan="2">&nbsp;</td>
			<%
			strTemp = "";
			if(strPrepareToEdit.equals("1"))
				strTemp = " disabled"; 
			%>
			
	  	  <td height="25">
		  	<%if(iAccessLevel > 1){%>
		  	<input type="button" name="request_book" value=" REQUEST ITEM " 
				onclick="ViewItems('2')" <%=strTemp%>
				style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
			
					&nbsp; &nbsp; &nbsp; &nbsp; 
				
			<input type="button" name="request_book" value=" VIEW REQUESTED ITEMS " 
				onclick="ViewItems('1');" 
				style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
			<%}else{%>
			Not authorized to access this page.
			<%}%>
 		  </td>
	  </tr>
	  <tr><td height="15" colspan="3">&nbsp;</td></tr>
	</table>
<%if(WI.fillTextValue("show_request_form").compareTo("1")==0){%>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Book Type :</td>
			<%			
			strTemp = WI.fillTextValue("book_type");
			if(vEditInfo != null && vEditInfo.size() >0)
				strTemp = (String)vEditInfo.elementAt(14);
				
			
				strTemp2 = " from bs_book_type join bs_book_type_request on (bs_book_type_request.type_index = bs_book_type.type_index)"+
					" where bs_book_type_request.is_valid=1 and dist_loc_index="+(String)vLocCatgIndex.elementAt(0);					
				
			%>
			<td><select name="book_type" onchange="document.form_.submit();">
                  <option value="">Select Book Type</option>
                  <%=dbOP.loadCombo("bs_book_type.type_index","type_name", strTemp2 ,strTemp, false)%>
                </select></td>
		</tr>		
	<%if(strTemp.length() > 0 ){
		boolean bolIsBookType = bm.checkIfBookType(dbOP, strTemp);
		%>
		
		<tr>
      		<td>&nbsp;</td>
      		<td>&nbsp;</td>
      		<td>
			<input type="text" name="scroll_fee" size="20" style="font-size:10px; background:#CCCC33" 
		  			onKeyUp="AutoScrollList('form_.scroll_fee','form_.book_title',true);"
		   			class="textbox" value="<%=WI.fillTextValue("scroll_fee")%>">
		   		<font size="1">(enter book title to scroll the list)</font>	  
			</td>
    	</tr>
			<%
				
				if(bolIsBookType)
					strTemp2 = "Book Title";
				else
					strTemp2 = "Item Name";
			%>
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%"><%=strTemp2%> :</td>
			<%
				String strBookTitle = WI.fillTextValue("book_title");
				strTemp = " from bs_book_entry where is_valid=1 order by book_title";
				if(vEditInfo != null && vEditInfo.size() >0){
					strBookTitle = (String)vEditInfo.elementAt(1);					
				}else{
					String strBookCatg = WI.fillTextValue("book_catg");
					
					
					if(strBookCatg.length() >0){					
						if(strBookCatg.equals("2"))
							strTemp = " from bs_book_entry where (catg_index is null or catg_index=1 or catg_index=2)";
						else
							strTemp = " from bs_book_entry where (catg_index is null or catg_index="+strBookCatg+")";
					
					if(strBookCatg.equals("1")){
						if(WI.fillTextValue("classification").length() >0)
							strTemp += " and year_level="+WI.fillTextValue("classification");
						else
							strTemp += " and year_level <> 0";
					}
					
					//System.out.println("strTemp1 "+strTemp);
					
					if(WI.fillTextValue("book_type").length() >0)
						strTemp += " and type_index="+WI.fillTextValue("book_type");
						
					strTemp += " and is_valid=1 order by book_title ";
					
					}
				}
			%>
			
			<td>
				<select name="book_title" onchange="document.form_.submit();" onblur="document.form_.submit();">
					<option value="">Select <%=strTemp2%></option>
				<%=dbOP.loadCombo("book_index","book_title", strTemp , strBookTitle, false)%> 
				</select>
			</td>
		</tr>
	<%if(bolIsBookType){%>	
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Author :</td>
			<%
				String strAuthor = WI.fillTextValue("author");
				strTemp = " from bs_book_entry where is_valid=1 order by author";
				
				if(vEditInfo != null && vEditInfo.size() >0){
					strAuthor = (String)vEditInfo.elementAt(1);					
				}else{
					if(WI.fillTextValue("book_title").length() >0)
						strTemp = " from bs_book_entry where is_valid=1 and book_index="+WI.fillTextValue("book_title");			
				}
			
			%>
			<td>
				<select name="author">				
				<%=dbOP.loadCombo("book_index"," author ", strTemp, strAuthor, false)%> 
				</select>
			</td>
		</tr>
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Publisher :</td>
			<%
				String strPublisher = WI.fillTextValue("publisher");
				strTemp = " from bs_book_publisher where is_valid = 1 ";
				if(vEditInfo != null && vEditInfo.size() >0){
					strPublisher = (String)vEditInfo.elementAt(6);					
				}else{
					if(WI.fillTextValue("book_title").length() >0)
						strTemp = " from bs_book_publisher left join bs_book_entry on(bs_book_entry.publisher_index=bs_book_publisher.publisher_index) "+
							" where bs_book_entry.is_valid=1 and book_index="+WI.fillTextValue("book_title");
				}
				
				if(vEditInfo != null && vEditInfo.size() >0){
					strTemp += " and bs_book_publisher.publisher_index="+strPublisher;
				}
				
				strTemp += " order by publisher_name ";
			
			%>
			<td><select name="publisher">
          			<option value="">Select Publisher</option>
          			<%=dbOP.loadCombo("bs_book_publisher.publisher_index","bs_book_publisher.publisher_name", strTemp, strPublisher, false)%> 
        		</select>
		  </td>
		</tr>
	<%}%>	
	
		<tr><td height="15" colspan="5">&nbsp;</td></tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Property Available Qty :</td>	
			
			<%
				strTemp = null;
				if(WI.fillTextValue("book_title").length() >0){
					
					strTemp = " select available_qty from bs_book_entry where is_valid=1 "+
						" and book_index="+WI.fillTextValue("book_title");								
						
					strTemp = dbOP.getResultOfAQuery(strTemp, 0);
				}
			%>
					
		  	<td>&nbsp;<%=WI.getStrValue(strTemp, "0")%></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Quantity :</td>
			<%strTemp = WI.fillTextValue("qty");
			if(vEditInfo!=null)
				strTemp = (String)vEditInfo.elementAt(4);
			%>
			<td>
					 
					<input type="text" name="qty" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onblur="AllowOnlyInteger('form_','qty');style.backgroundColor='white'" 
					onkeyup="AllowOnlyInteger('form_','qty')" size="10" maxlength="5" 
					value="<%=strTemp%>" />				</td>
		</tr>
		
		<tr>
			<td colspan="2">&nbsp;</td>
			<td>
			<%if(iAccessLevel > 1){
				if(WI.fillTextValue("show_request_form").equals("1") && !strPrepareToEdit.equals("1")){%>
				<a href="javascript:PageAction('1','');">
				<img src="../../../images/save.gif"  border="0"/></a><font size="1">Click to save</font>
				<%}else{%>				
				<a href="javascript:PageAction('2','');">
				<img src="../../../images/edit.gif" border="0"/></a><font size="1">Click to update</font>
				<%}%>
				<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a>
					<font size="1">Click to refresh page.</font>
			<%}else{%>
				Not authorized to request book.
			<%}%>			</td></tr>
		<tr><td colspan="3" height="25">&nbsp;</td></tr>
		
	<%}%>
	</table>
	
	
	
	
	
<%}if(vRetResult != null && vRetResult.size() >0 && WI.fillTextValue("show_info").compareTo("1")==0){%>
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr><td height="15">&nbsp;</td></tr>
			<tr><td align="right">
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
						<font size="1">Click to print requested books</font>
			</td></tr>
		</table>


		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			
			<tr>
				<td height="20" bgcolor="#B9B292" colspan="12" class="thinborder"><div align="center">
					<strong>LIST OF REQUESTED ITEMS &nbsp; &nbsp; SY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>
					&nbsp;<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>					</strong></div></td>
			</tr>
			
			
			<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(br.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="8"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/br.defSearchSize;		
				if(iSearchResult % br.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+br.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.show_info.value='1';document.form_.submit();">
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
		</tr>
			
			
			<tr>
				<td width="5%"  align="center" height="25" class="thinborder"><strong>Count</strong></td>
				<td width="15%" align="center" class="thinborder"><strong>Title</strong></td>
				<td width="8%" align="center" class="thinborder"><strong>Author</strong></td>
				<td width="8%" align="center" class="thinborder"><strong>Publisher</strong></td>				
				<td width="5%" align="center" class="thinborder"><strong>Qty</strong></td>
				<td width="12%" align="center" class="thinborder"><strong>Year/Grade Level</strong></td>
				<td width="8%" align="center" class="thinborder"><strong>Requested by</strong></td>
				<td width="12%" align="center" class="thinborder"><strong>Department</strong></td>			
				<td width="5%"  align="center" class="thinborder"><strong>Requested Date</strong></td>
				<td width="13%"  align="center" class="thinborder"><strong>EDIT/DELETE</strong></td>
				<td width="5%"  align="center" class="thinborder"><strong>FINALIZE</strong></td>
				<td width="4%"  align="center" class="thinborder"><strong>Status</strong></td>
			</tr>
			
			<%for(int i=0,iCount=1;i<vRetResult.size();i+=21,iCount++){%>
			<tr>	
				<td align="center" height="25" class="thinborder"><%=iCount%></td>
				<td align="left" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
				<td align="left" class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+3),"N/A")%></td>
				<td align="left" class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5),"N/A")%></td>				
				<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>	
			  	<td align="left" class="thinborder">
					<%=WI.getStrValue((String)vRetResult.elementAt(i+9))%><%=WI.getStrValue((String)vRetResult.elementAt(i+11),"/ ","","")%>
				    <%=WI.getStrValue((String)vRetResult.elementAt(i+10),"/ ","","")%></td>
					
				<td align="left" class="thinborder">
					<%=WI.getStrValue((String)vRetResult.elementAt(i+17))%>
					<%=WI.getStrValue((String)vRetResult.elementAt(i+18))%>.
				    <%=WI.getStrValue((String)vRetResult.elementAt(i+19))%>
				</td>	
				
				<%
					strTemp = (String)vRetResult.elementAt(i+20);					
					int iIndexOf = strTemp.indexOf("DISTRIBUTION");		
					//System.out.println(iIndexOf);			
					strTemp = strTemp.substring(0,iIndexOf-1);
				%>
				
				<td align="left" class="thinborder"> <%=WI.getStrValue(strTemp)%></td>
				
				<td align="left" class="thinborder"><%=(String)vRetResult.elementAt(i+15)%></td>
				
				
				
				
				<%strTemp = (String)vRetResult.elementAt(i+12);%>
				<td class="thinborder" align="center">
					<%if(iAccessLevel > 1){
						strTemp2  = (String)vRetResult.elementAt(i+13);
						if(!strTemp.equals("1")){%>
							<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/edit.gif" border="0"></a>
							<%if(iAccessLevel == 2){%>
								<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
								<img src="../../../images/delete.gif" border="0"></a>
							<%}%>
						<%}else if(iAccessLevel == 2 && strTemp.equals("1") && !strTemp2.equals("1")){%>						
							<a href="javascript:CancelRequestedOrder('<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/delete.gif" border="0"></a>
						<%}else{%>			
							Finalized
						<%}%>
					<%}else{%>
						Not authorized.
					<%}%>
				</td>
				
				<td class="thinborder" align="center">
				<%if(iAccessLevel > 1){
					if(!strTemp.equals("1")){%>
					<a href="javascript:FinalizeRequest('<%=(String)vRetResult.elementAt(i)%>');"><font color="#FF0000">Finalize</font></a>
					<%}else{%>
					Finalized
					<%}%>
				<%}else{%>	
					Not authorized.
				<%}%>				</td>
				
				<td align="center" class="thinborder">
					<%					
					strTemp = (String)vRetResult.elementAt(i+13);					
					if(strTemp.equals("1")){%>
					<img src="../../../images/tick.gif" border="0" />
					<%}else{%>
					<img src="../../../images/x.gif" border="0" />
					<%}%>
				
				</td>
				
				
			</tr>
			<%}%>			
		</table>
		
		
<%
if(WI.fillTextValue("show_div").length() > 0)
	strTemp = "processing2";
else
	strTemp = "processing"; 

%>		
		
<div id="processing" class="<%=strTemp%>">
<table cellpadding=0 cellspacing=0 border=0 Width=100% align=Center class="thinborderALL">
	<tr><td valign="top" colspan="2" align="right"><a href="javascript:HideLayer('processing')">Close Window X</a></td></tr>	  	  
  	<tr><td valign="top" colspan="2" align="center"><u><b>CANCEL REQUEST</b></u></td></tr>
	<tr><td colspan="2">Remarks</td></tr>
	<tr><td colspan="2"><textarea name="remarks_" style="width:100%;"><%=WI.fillTextValue("remarks_")%></textarea></td></tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr><td colspan="2">
	&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
	<a href="javascript:PageAction('100','<%=WI.fillTextValue("info_index")%>');">
		<img src="../../../images/save.gif"  border="0"/>
	</a></td></tr>
</table>
</div>
		
		
		
		
		
		
		
		
		
		

<%}//end of vRetResult!=null%>














	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="show_info" value="<%=WI.fillTextValue("show_info")%>"/>
	<input type="hidden" name="page_action" />
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="view_request_book" value="1" />
	<input type="hidden" name="show_request_form" value="<%=WI.fillTextValue("show_request_form")%>"/>
	<input type="hidden" name="loc_index" value="<%=strYearLevel%>"  />
	<input type="hidden" name="show_div" value=""/>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
