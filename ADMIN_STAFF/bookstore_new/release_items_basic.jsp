<%@ page language="java" import="utility.*, citbookstore.BookOrders, citbookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsForwarded = WI.fillTextValue("is_forwarded").equals("1");
	
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
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
a{
	text-decoration: none;
}
</style>

<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
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

<title>Release Items</title></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
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
		if(document.form_.search_type.value=='1')
			var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strIDNumber);
		else			
			var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20700&for_order=1&id_number="+escape(strIDNumber)+"&offering_sem="+vSemester+"&sy_from="+vSyFrom+"&sy_to="+vSyTo;
			
			//var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20700&id_number="+escape(strIDNumber);
		
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOA.value = strID;
		objCOAInput.innerHTML = "";
		document.form_.search_type.value = '0';
		this.AjaxMapOrders();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.get_order_info.value = "1";
		document.form_.get_ajax.value = '1';
		document.form_.id_number_.value = '';
		document.form_.submit();
	}
	
	function UpdateNameFormat(strName) {
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.get_order_info.value = "1";
		document.form_.get_ajax.value = '1';
		document.form_.submit();
	}
	
	function updateCustomerCode(strOrderIndex, strIDNumber, strOrderNumber){
		<%if(bolIsCIT){%>
			document.form_.id_number.value = strIDNumber;
			document.form_.id_number_.value = strOrderNumber;			
		<%}else{%>
			document.form_.id_number.value = strOrderNumber;
			document.form_.id_number_.value = strIDNumber;
		<%}%>	
		document.form_.get_order_info.value = "1";
		document.form_.get_ajax.value = '1';			
		document.getElementById("coa_info").innerHTML = "";
		document.form_.submit();
	}
	
	function getOrderedInfo(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.get_order_info.value = "1";
		document.form_.get_ajax.value = '1';
		document.form_.id_number_.value = '';
		document.form_.submit();
	}
	
	function ReleaseItem(strOrderItemIndex){
		if(!confirm("Are you sure you want to release this order item?"))
			return;
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.order_item_index.value = strOrderItemIndex;
		document.form_.release_item.value = "1";
		document.form_.get_order_info.value = "1";
		document.form_.submit();
	}
	
	function UnreleaseItem(strOrderItemIndex){
		if(!confirm("Are you sure you want to unrelease this order item?"))
			return;
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.order_item_index.value = strOrderItemIndex;
		document.form_.unrelease_item.value = "1";
		document.form_.get_order_info.value = "1";
		document.form_.submit();
	}
	
	function FinalizeItem(strOrderItemIndex){
		if(!confirm("Are you sure you want to finalize this order item?"))
			return;
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.order_item_index.value = strOrderItemIndex;
		document.form_.finalize_item.value = "1";
		document.form_.get_order_info.value = "1";
		document.form_.submit();
	}
	
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
		
		<%if(bolIsForwarded){%>
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
		<%}%>
	}
	
	function HideLayer(strDiv) {			
		document.getElementById(strDiv).style.visibility = 'hidden';
	}
	
	function ReturnItem(strOrderItemIndex, strTypeIndex, strQtySelected, strBookIndex){
		document.getElementById('processing').style.visibility = 'visible';		
		document.form_.order_item_index.value = strOrderItemIndex;	
		document.form_.type_index.value = strTypeIndex;	
		document.form_.qty_selected.value = strQtySelected;
		document.form_.book_index_return.value = strBookIndex;
		document.form_.show_div.value = '1';
		
		document.form_.submit();
	}
	
	function SaveReturnItems(){		
		if(!document.form_.defective_.checked && !document.form_.change_item.checked){
			alert("Please select from checkbox.");
			return;
		}
		
		document.form_.show_div.value = '';
		document.form_.save_return.value='1';
		document.form_.submit();
	}
	
	function checkAllSaveItems() {
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function FinalizeAllItems(){
		if(!confirm("Do you want to finalize all item?"))
			return;
			
		var maxDisp = document.form_.item_count.value;		
		var iCount = 0;
		var strTemp = null;
		for(var i=1; i< maxDisp; ++i){
			if(eval('document.form_.save_'+i+'.checked')){
				iCount++;				
				if(strTemp == null)	
					strTemp = eval('document.form_.save_'+i+'.value');
				else
					strTemp += ", "+eval('document.form_.save_'+i+'.value');
			}			
		}
		
		if(iCount == 0)
		{
			alert("Please select atleast one item to finalize.");				
			return;
		}
		
		
		
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.order_item_index.value = strTemp;
		document.form_.finalize_item.value = "1";
		document.form_.get_order_info.value = "1";		
		document.form_.finalize_all.value = '1';
		document.form_.submit();
		
		
	}
	
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-ORDERING-RELEASE ITEMS BASIC","release_items_basic.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-ORDERING-RELEASE ITEMS BASIC"),"0"));
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
	
	String strOrderIndex = null;
	Vector vOrderItems = null;
	Vector vRetResult = new Vector();
	BookOrders bo = new BookOrders();
	BookManagement bm = new BookManagement();
	int iCount = 1;
	String strSQLQuery = null;
	String strExcessOfReturn = null;
	boolean bolShowData = false;
	String strOrderItemIndex = WI.fillTextValue("order_item_index");
	
	String strIDNumber = WI.fillTextValue("id_number");
	String strUserIndex = null;
	
	String strSYFrom = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
	String strSemester = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
	
	if(WI.fillTextValue("get_order_info").length() > 0 ){	
		strUserIndex = dbOP.mapUIDToUIndex(strIDNumber);
		if (strUserIndex == null)
            strErrMsg = "User does not exist or is invalidated.";            
        else{
			strTemp =  " select count(*) from bs_book_order_main "+			
			" where is_valid=1 and order_stat > 0 and sy_from ="+strSYFrom+
			" and semester = "+strSemester+
			" and user_index = "+strUserIndex;
			strTemp = dbOP.getResultOfAQuery(strTemp,0);
			if(strTemp.equals("0"))
				strErrMsg = "ID number "+strIDNumber+ " has no existing order.";				
			else{
				bolShowData = true;		
				strOrderIndex = bo.isOrderReadyForReleasing(dbOP, request);		
				if(strOrderIndex == null)
					strErrMsg = bo.getErrMsg();
				else{
					if(WI.fillTextValue("release_item").length() > 0){
						if(!bo.operateOnReleaseFinalize(dbOP, request, 1))
							strErrMsg = bo.getErrMsg();
						else
							strErrMsg = "Order item successfully released.";
					}
					
					if(WI.fillTextValue("unrelease_item").length() > 0){
						if(!bo.operateOnReleaseFinalize(dbOP, request, 0))
							strErrMsg = bo.getErrMsg();
						else
							strErrMsg = "Order item successfully unreleased.";
					}
					
					if(WI.fillTextValue("finalize_item").length() > 0){
						if(!bo.operateOnReleaseFinalize(dbOP, request, 2))
							strErrMsg = bo.getErrMsg();
						else
							strErrMsg = "Order item successfully finalized.";
					}
					
					if(WI.fillTextValue("save_return").length() > 0){
						strExcessOfReturn = bm.operateOnItemReturn(dbOP, request, strOrderIndex);
	
						if(strExcessOfReturn == null){
							strErrMsg = bm.getErrMsg();
						}else{						
							
							strTemp = "select sy_from from bs_book_order_main where is_valid = 1 and order_stat > 0 and order_number="+
								WI.getInsertValueForDB(WI.fillTextValue("id_number_"),true, null);			
							strSYFrom = dbOP.getResultOfAQuery(strTemp,0);
				
							strTemp = "select semester from bs_book_order_main where is_valid = 1 and order_stat > 0 and order_number="+
								WI.getInsertValueForDB(WI.fillTextValue("id_number_"),true, null);			
							strSemester = dbOP.getResultOfAQuery(strTemp,0);
							
							String strBookTitleIndex = WI.fillTextValue("book_title");						
								dbOP.cleanUP();					
								response.sendRedirect("./print_orderlist.jsp?order_index="+strOrderIndex+
								"&sy_from="+strSYFrom+"&offering_sem="+strSemester+
								"&print_excess=1&order_item_index="+strOrderItemIndex+"&return_qty="+WI.fillTextValue("return_qty")+
								"&excess="+strExcessOfReturn+"&book_title="+strBookTitleIndex);							
							return;}	
					}
				
					vOrderItems = bo.getOrderedItems(dbOP, request, strOrderIndex);				
					if(vOrderItems == null)
						strErrMsg = bo.getErrMsg();
					else{
						
						strSQLQuery = " select payment_index, user_index, date_paid, amount_paid from bs_book_payment "+
							" where order_index="+strOrderIndex+
							" and is_valid=1 and FA_PAYMENT_INDEX is not null order by payment_index desc";
		
						java.sql.ResultSet rsTemp = dbOP.executeQuery(strSQLQuery);	
						while(rsTemp.next()){
							vRetResult.addElement(rsTemp.getString(1)); //[0] payment_index
							vRetResult.addElement(rsTemp.getString(2)); //[1] user_index
							vRetResult.addElement(rsTemp.getDate(3));   //[2] date_paid
							double dAmtPaid = rsTemp.getDouble(4);
							vRetResult.addElement(CommonUtil.formatFloat(dAmtPaid, true)); //[3] amount_paid
						}
						rsTemp.close();						
					}					
				}			
			}
		}		
	}
	
	
%>
<body bgcolor="#D2AE72" onload="document.form_.id_number.focus();"  onUnload="ReloadParentWnd();">
<form name="form_" action="./release_items_basic.jsp" method="post">	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: RELEASE ITEMS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
	<tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">SY-Term</td>
      <td width="22%" height="25"> 
<%
strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.getStrValue(WI.fillTextValue("sy_to"),(String)request.getSession(false).getAttribute("cur_sch_yr_to"));
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
	  &nbsp; 
		<%
			strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
		%>		
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
		
		</td>
	</tr>      
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Order Number: </td>
			<td width="80%">
				<%if(bolIsForwarded){%>
					<input type="hidden" name="id_number" value="<%=WI.fillTextValue("id_number")%>" />
					<strong><font size="3" color="#FF0000"><%=WI.fillTextValue("id_number")%></font></strong>
				<%}else{%>
					<input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
						onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapOrders();">
				<%}%>
				&nbsp;&nbsp;
				<label id="coa_info" style="width:300px; position:absolute"></label></td>
		</tr>
	<%if(!bolIsForwarded){%>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:getOrderedInfo();"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to get order information.</font></td>
		</tr>
	<%}%>
	</table>
	
<%if(WI.fillTextValue("get_ajax").length() > 0 && bolIsCIT){%>	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="10" colspan="7"><hr size="1" /></td>
	</tr>		
	<tr>
		<td width="30%">&nbsp;</td>
		<td height="25" colspan="5" align="center">	  
	  		<%=bo.ajaxSearchOrders(dbOP, request)%>	  
	  	</td>
		<td width="30%">&nbsp;</td>
    </tr>
	
	</table>
<%}%>

	
<%if(vOrderItems != null && vOrderItems.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td align="right">
				<input type="button" name="add" value="FINALIZE ALL ITEMS" onclick="javascript:FinalizeAllItems();"
						style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr>
          	<td height="20" bgcolor="#B9B292" colspan="10" class="thinborder"><div align="center"><strong>LIST OF ORDERED PRODUCTS </strong></div></td>
        </tr>
        <tr>
			<td width="5%"  align="center" height="25" class="thinborder"><strong>Count</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Title</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Item Price </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Quantity</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Payable Amt </strong></td>
			<td width="7%"  align="center" class="thinborder"><strong>Release</strong></td>
			<td width="7%"  align="center" class="thinborder"><strong>Finalize</strong></td>
			<td width="8%"  align="center" class="thinborder"><strong>Select All<br />
				<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();">
			</strong></td>
			<td width="6%"  align="center" class="thinborder"><strong>Return</strong></td>
        </tr>
        <%	
			iCount = 1;
			double dPayableAmt = 0d;			
			for(int i = 0; i < vOrderItems.size(); i += 19, iCount++){
		%>
        <tr>
			<td height="25" class="thinborder" align="center"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vOrderItems.elementAt(i+5)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vOrderItems.elementAt(i+6), "N/A")%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vOrderItems.elementAt(i+9), true)%>&nbsp;</td>
			<td class="thinborder">&nbsp;<%=(String)vOrderItems.elementAt(i+10)%></td>
			
	  	  	<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vOrderItems.elementAt(i+11), true)%>&nbsp;</td>
			
			<%
				dPayableAmt += Double.parseDouble((String)vOrderItems.elementAt(i+11));
				strTemp = (String)vOrderItems.elementAt(i+14);
			%>
		  	<td align="center" class="thinborder">
				<%if(strTemp.equals("0")){%>
					<a href="javascript:ReleaseItem('<%=(String)vOrderItems.elementAt(i)%>');">Release</a>
				<%}else if(strTemp.equals("1")){%>
					<a href="javascript:UnreleaseItem('<%=(String)vOrderItems.elementAt(i)%>');">Unrelease</a>
				<%}else{%>
					Finalized
				<%}%></td>
			<td align="center" class="thinborder">
				<%if(strTemp.equals("0") || strTemp.equals("1")){%>
					<a href="javascript:FinalizeItem('<%=(String)vOrderItems.elementAt(i)%>');">Finalize</a>
				<%}else{%>
					Finalized
				<%}%></td>
			<td align="center" class="thinborder">
				<%if(strTemp.equals("0") || strTemp.equals("1")){%>
					<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vOrderItems.elementAt(i)%>" tabindex="-1" />
				<%}else{%>
					<input type="hidden" name="save_<%=iCount%>" value="" />
					&nbsp;
				<%}%>
			</td>
			<td align="center" class="thinborder">
				<%if(!strTemp.equals("0") && !strTemp.equals("1")){%>
					<a href="javascript:ReturnItem('<%=(String)vOrderItems.elementAt(i)%>','<%=(String)vOrderItems.elementAt(i+2)%>',
					'<%=(String)vOrderItems.elementAt(i+10)%>','<%=(String)vOrderItems.elementAt(i+1)%>');">Return</a>
				<%}else{%>
					&nbsp;
				<%}%>
			</td>
		</tr>
        <%}%>
		<input type="hidden" name="item_count" value="<%=iCount%>" />
		<tr>
			<td height="25" colspan="5" align="right">Total Payable Amount :</td>
			<td align="right"><strong><%=CommonUtil.formatFloat(Double.toString(dPayableAmt),true)%></strong>&nbsp;</td>
			<td colspan="4">&nbsp;</td>
		</tr>
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
  	<tr><td valign="top" colspan="2" align="center"><u><b>Return Item</b></u></td></tr>
  	<tr>
			<%
				if(WI.fillTextValue("defective_").length() > 0)
					strTemp = " checked";				
				else
					strTemp = "";
			%>
		<td>
			<input type="checkbox" name="defective_"  value="1" <%=strTemp%> />
			Check if defective
		</td>
			<%
				if(WI.fillTextValue("change_item").length() > 0)
					strTemp = " checked";				
				else
					strTemp = "";
			%>
		<td>			
			<input type="checkbox" name="change_item"  value="1" <%=strTemp%> />			
			Check if change of item
		</td>	  
	</tr>
  
  	<tr><td height="15" colspan="2">&nbsp;</td></tr>	
	<%
		
			
		String strTemp2 = WI.fillTextValue("type_index");
		
			if(strTemp2.length()>0){
				/*strTemp2 = " from bs_book_entry "+
					"join bs_book_dist_inv on(bs_book_dist_inv.book_index = bs_book_entry.book_index) "+
					" left join ( "+
				        " select book_index as BI, sum(quantity) as totUnPaidUnreleased from bs_book_order_items "+
				        " join bs_book_order_main on (bs_book_order_main.order_index = bs_book_order_items.order_index) "+
				        " where bs_book_order_main.is_valid =1  and is_released = 0 and payment_index is null group by book_index) "+
				        " as DT on (DT.BI = bs_book_entry.book_index) "+						
					" where bs_book_dist_inv.is_valid=1 and type_index="+strTemp2+" and (bs_book_dist_inv.available_qty - totUnPaidUnreleased) > 0 order by book_title ";*/
				
				strTemp2 = " from bs_book_entry "+
						" join bs_book_dist_inv on(bs_book_dist_inv.book_index = bs_book_entry.book_index) "+
						" left join ( "+
						" select book_index as BI, sum(quantity) as totUnPaidUnreleased from bs_book_order_items "+
						" join bs_book_order_main on (bs_book_order_main.order_index = bs_book_order_items.order_index) "+
						" where bs_book_order_main.is_valid =1  and is_released = 0 and payment_index is null group by book_index) "+
						" as DT on (DT.BI = bs_book_dist_inv.book_index) "+
						" where bs_book_dist_inv.is_valid=1 and type_index="+strTemp2+
						" and (bs_book_dist_inv.available_qty - isnull(totUnPaidUnreleased,0)) > 0 order by book_title ";						
			}else
				strTemp2 = " from bs_book_entry where is_valid=1 order by book_title";
				
			
			strTemp = WI.fillTextValue("qty_selected");
			if(strTemp.length()==0)
				strTemp = WI.fillTextValue("return_qty");
			
				
	%>
	<tr><td colspan="2"> Quantity : &nbsp; 
		<input type="text" name="return_qty" value="<%=strTemp%>" 
		 maxlength="2" size="2"/>
		<br />
		Select : 		
		<%		
		strTemp = WI.fillTextValue("book_index_return");
			if(strTemp.length()==0)
				strTemp = WI.fillTextValue("book_title");
		%>
		
		<select name="book_title">		
			<option value="">Select Any</option>
			<%=dbOP.loadCombo("bs_book_entry.book_index","book_title", strTemp2 , strTemp, false)%> 
		</select>
	</td></tr>
	
	<tr><td height="15" colspan="2">&nbsp;</td></tr>
	<%if(WI.fillTextValue("defective_").equals("1")){%>
  	<tr><td colspan="2">Remarks</td></tr>
  
  	<tr>  
  		<td colspan="2">
			<textarea name="remarks_" style="width:100%;"><%=WI.fillTextValue("remarks_")%></textarea>
		</td>	
	</tr>
	<%}%>
	<tr><td height="15" colspan="2">&nbsp;</td></tr>
	<tr>
		<td colspan="2">&nbsp; &nbsp; &nbsp; 
		<input type="button" name="add" value=" Save " onclick="javascript:SaveReturnItems();"
						style="font-size:11px; height:28px;border: 1px solid #FF0000;" />&nbsp;
			<font size="1">Click to return item(s)</font>
		</td>
	</tr>
	<tr><td height="15" colspan="2">&nbsp;</td></tr>
</table>
</div>

	
	
<%}%>


<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
          	<td height="20" bgcolor="#B9B292" colspan="3" class="thinborder"><div align="center"><strong>PAYMENT STATUS</strong></div></td>
        </tr>
		
		<tr>
			<td width="10%" align="center" height="25" class="thinborder"><strong>Count</strong></td>
			<td width="45%" align="center" class="thinborder"><strong>Date Paid</strong></td>
			<td width="45%" align="center" class="thinborder"><strong>Amount</strong></td>			
        </tr>
		
		<%
		iCount = 1;		
		double dAmtPaid = 0d;
		for(int iCtr = 0; iCtr < vRetResult.size(); iCtr+= 4, iCount++){
			strTemp = (String)vRetResult.elementAt(iCtr+3);
			strTemp = ConversionTable.replaceString(strTemp, ",", "");
			dAmtPaid += Double.parseDouble(strTemp);
		%>
		<tr>
			<td align="center" height="25" class="thinborder">&nbsp;<%=iCount%></td>
			<td align="center" class="thinborder">&nbsp;<%=vRetResult.elementAt(iCtr+2)%></td>
			<td align="right" class="thinborder">&nbsp;<%=vRetResult.elementAt(iCtr+3)%>&nbsp;</td>						
		 </tr>
		<%}%>	
	</table>	
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="10%">&nbsp;</td>
		<td width="45%" height="25" align="right">Total Amount Paid: </td>
		<td width="45%" align="right"><strong><%=CommonUtil.formatFloat(dAmtPaid, 2)%></strong>&nbsp;</td>
	</tr>
	</table>
<%}%>


	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="release_item" />
	<input type="hidden" name="unrelease_item" />
	<input type="hidden" name="finalize_item" />
	<input type="hidden" name="get_order_info"  value="<%=WI.fillTextValue("get_order_info")%>"/>
	<input type="hidden" name="order_item_index" value="<%=WI.fillTextValue("order_item_index")%>"  />
	<input type="hidden" name="id_number_" value="<%=WI.fillTextValue("id_number_")%>"  />
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>" /> 
	<input type="hidden" name="close_wnd_called" value="0" />
	<input type="hidden" name="donot_call_close_wnd" />
	<input type="hidden" name="reloadPage" value="0" />
	<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>" />
	<input type="hidden" name="for_release" value="1" />
	<input type="hidden" name="get_ajax" value="<%=WI.fillTextValue("get_ajax")%>"  />
	<input type="hidden" name="search_type"  value="1"/>
	<input type="hidden" name="save_return"  />
	<input type="hidden" name="type_index"  value="<%=WI.fillTextValue("type_index")%>"/>
	<input type="hidden" name="qty_selected" value="<%=WI.fillTextValue("qty_selected")%>"/>
	<input type="hidden" name="book_index_return" value="<%=WI.fillTextValue("book_index_return")%>"/>
	<input type="hidden" name="show_div" value=""/>
	<input type="hidden" name="is_basic" value="1" />
	<input type="hidden" name="for_order" value="1" />
	<input type="hidden" name="finalize_all" value="<%=WI.fillTextValue("finalize_all")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>