<%@ page language="java" import="utility.*, citbookstore.BookManagement, citbookstore.BookOrders, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
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
<title>Add Order Items</title>
</head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
	
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
	}
	
	function addItems(){
		document.form_.add_items.value = "1";
		
		document.form_.force_close.value = '1';
		this.SearchBooks();
	}
	
	function ReloadPage(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.submit();
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
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20400&query_con="+vCondition+"&onchange="+onChange+"&sel_name="+selName+"&table_name="+tableName+"&fields="+fields+"&header="+header+"&header_value="+headerValue;
	
		this.processRequest(strURL);
	}
	
	function SearchBooks(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.search_books.value = "1";
		document.form_.submit();
	}
	
	function checkAllSaveItems() {
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function toggleSel(objQty, objChkBox){
		if(objQty.value.length > 0)
			objChkBox.checked = true;
		else
			objChkBox.checked = false;
	}
	function HideLayer(strDiv) {			
			document.getElementById(strDiv).style.visibility = 'hidden';
	}
		
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	boolean bolForceClose = false;
	if(WI.fillTextValue("force_close").equals("1"))
		bolForceClose = true;
	
	String strOrderIndex = WI.fillTextValue("order_index");
	if(strOrderIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Order reference is not found. Please close this window and click Add Items button again from main window.</p>
		<%return;
	}
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-ORDERING-ORDER ITEMS COLLEGE","add_order_items.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-ORDERING-ORDER ITEMS COLLEGE"),"0"));
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
	
	String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName = {"Book Title","Author","Item Code"};
	String[] astrSortByVal = {"book_title","author","item_code"};
	
	int iSearchResult = 0;
	Vector vRetResult = null;
	BookOrders bo = new BookOrders();
	BookManagement bm = new BookManagement();
	
	if(WI.fillTextValue("add_items").length() > 0){
		if(!bo.addOrderItems(dbOP, request,strOrderIndex)) {
			strErrMsg = bo.getErrMsg();
			bolForceClose = false;
		}
		else {
			strErrMsg = bo.getErrMsg();
			if(strErrMsg == null)
				strErrMsg = "Items added successfully.";
		}
	}
	
	if(WI.fillTextValue("search_books").length() > 0){
		vRetResult = bm.searchBooks(dbOP, request,0);
		if(vRetResult == null){
			if(WI.fillTextValue("add_items").length() == 0)
				strErrMsg = bm.getErrMsg();
		}
		else
			iSearchResult = bm.getSearchCount();		
	}
	
	String strIsPaymentFirst = WI.getStrValue(bo.checkIfPaymentFirst(dbOP, request));
	String strPrepaidAmount = bo.getStudentPrepaidAmount(dbOP, request, strOrderIndex);

	boolean bolShowBookWithoutInventory = true;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");
	
	if(bolIsCIT)
		bolShowBookWithoutInventory = false;
%>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();" <%if(bolForceClose){%> onload="window.close();"<%}%>>
<form name="form_" action="./add_order_items.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: ADD ORDER ITEMS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Type: </td>
				<%
					strTemp = " from bs_book_type where is_valid = 1 ";
					if(WI.fillTextValue("is_book_type").equals("1"))
						strTemp += " and is_book_type = 1 ";
					else
						strTemp += " and is_book_type = 0 ";
					strTemp += " order by type_name ";
				%>
		  	<td width="80%">
				<select name="book_type">
          			<option value="">Select Book Type</option>
          			<%=dbOP.loadCombo("type_index","type_name", strTemp, WI.fillTextValue("book_type"), false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Category:</td>
			<%
				String strCatg = WI.fillTextValue("book_catg");
			%>
	  	  <td>
				<select name="book_catg" onChange="loadClassification();">
          			<option value="">Select Book Category</option>
          			<%=dbOP.loadCombo("catg_index","catg_name", " from bs_book_catg where is_valid = 1 order by catg_name ", strCatg, false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Grade Level:</td>
			<%						
				if(strCatg.length() == 0 || strCatg.equals("0") || strCatg.equals("2"))//college or not selected
					strErrMsg = " where edu_level = 0 ";
				else
					strErrMsg = "";
			%>
			<td>
				<label id="load_classification">
				<select name="classification">
					<option value="">All</option>
					<%=dbOP.loadCombo("g_level","level_name", " from bed_level_info "+strErrMsg, WI.fillTextValue("classification"), false)%> 
				</select>
				</label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Book Title:</td>
			<td>
				<select name="book_title_con">
					<%=bm.constructGenericDropList(WI.fillTextValue("book_title_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
				<input type="text" name="book_title" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="256" value="<%=WI.fillTextValue("book_title")%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Author:</td>
			<td>
				<select name="author_con">
					<%=bm.constructGenericDropList(WI.fillTextValue("author_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
				<input type="text" name="author" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="128" value="<%=WI.fillTextValue("author")%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Publisher:</td>
			<%
				strTemp = " from bs_book_publisher where is_valid = 1 order by publisher_name ";
			%>
			<td>
				<select name="publisher">
          			<option value="">Select Publisher</option>
          			<%=dbOP.loadCombo("publisher_index","publisher_name", strTemp, WI.fillTextValue("publisher"), false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Item Code: </td>
	      	<td>
				<select name="item_code_con">
					<%=bm.constructGenericDropList(WI.fillTextValue("item_code_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
				<input name="item_code" type="text" class="textbox" value="<%=WI.fillTextValue("item_code")%>" maxlength="16"
					size="16" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
		</tr>

		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("include_no_stocks");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
				if(!bolShowBookWithoutInventory) 
					strTemp = "  disabled='disabled'";
			%>
		    <td><input type="checkbox" name="include_no_stocks" value="1" <%=strTemp%>>Include items with no stocks.</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
          	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">Sort by: </td>
		  	<td width="20%">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=bm.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="20%">
				<select name="sort_by2">
              		<option value="">N/A</option>
             		<%=bm.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="40%">
				<select name="sort_by3">
					<option value="">N/A</option>
              		<%=bm.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td height="25" colspan="3">
			<%
				if(WI.fillTextValue("view_all").length() > 0)
					strTemp = " checked";				
				else
					strTemp = "";
			%>
			<input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="document.form_.submit();"> View ALL</td>
	    </tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="4">
				<a href="javascript:SearchBooks();"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to search for  books.</font></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="50%" style="font-weight:bold; font-size:15px;">&nbsp;<%if(strIsPaymentFirst.equals("1")){%>
			Credit Left: <strong><%=strPrepaidAmount%></strong><%}%></td>
			<td width="50%" align="right">&nbsp;
				<%if(iAccessLevel > 1){%>
					<input type="button" name="add" value=" Add Item(s) " onclick="javascript:addItems();"
						style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
				<%}%></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="11" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>:::  BOOK ENTRY LISTING ::: </strong></div></td>
		</tr>
		<%
		boolean bolShowJump = true;
		if(bolIsCIT)
			bolShowJump = false;
		//if(bolIsCIT && WI.fillTextValue("is_book_type").equals("0"))
		//	bolShowJump = false;
		
		if(bolShowJump){%>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="6">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(bm.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="5"> &nbsp;
			<%
				int iPageCount = 1;
				if(!WI.fillTextValue("view_all").equals("1")){
					iPageCount = iSearchResult/bm.defSearchSize;		
					if(iSearchResult % bm.defSearchSize > 0)
						++iPageCount;
				}
				strTemp = " - Showing("+bm.getDisplayRange()+")";
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
		</tr>
		<%}%>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Item Code </strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Book Title </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="8%" align="center" class="thinborder"><strong>Price</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Avail. Qty.</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Unreleased Qty.</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Max Order Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Order Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=16, iCount++){
	%>
		<tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5), "N/A")%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+8), true)%>&nbsp;</td>
				<input type="hidden" name="price_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+8)%>" />
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
				<input type="hidden" name="avail_qty_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+7)%>" />
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+10), "0")%></td>
			<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+15),"1")%></td>
			<td class="thinborder" align="center">
				<input type="text" name="qty_<%=iCount%>" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','qty_<%=iCount%>');style.backgroundColor='white';toggleSel(document.form_.qty_<%=iCount%>, document.form_.save_<%=iCount%>)" 
					onkeyup="AllowOnlyInteger('form_','qty_<%=iCount%>')" size="3" maxlength="5" value="1"/></td>
			<%
				strErrMsg = "";
				//if basic and books, select
				//System.out.println(i + ": "+ (String)vRetResult.elementAt(i));
				//System.out.println("course_index: "+WI.fillTextValue("course_index"));
				if(WI.fillTextValue("course_index").equals("0") && ((String)vRetResult.elementAt(i+11)).equals("1"))
					strErrMsg = "checked";
			%>
			<td class="thinborder" align="center">				
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1" <%=strErrMsg%>></td>
		</tr>
	<%}%>
		<input type="hidden" name="item_count" value="<%=iCount%>" />
	</table>
	
	
	


<%
	Vector vTemp = new Vector();
	String strBookTitle = null;
	String strAlertFinal = null;
	if(vRetResult != null && vRetResult.size() > 0){
	int iAvailQty = 0;
	int iAlertLevel = 0;
	int iAlertFinal = 0;
		for(int x=0; x < vRetResult.size() ; x+=16){
			iAvailQty = Integer.parseInt((String)vRetResult.elementAt(x+7));
			iAlertLevel = Integer.parseInt((String)vRetResult.elementAt(x+13));
			iAlertFinal = Integer.parseInt((String)vRetResult.elementAt(x+14));			
			
			if((iAvailQty <= iAlertLevel) && (iAvailQty > iAlertFinal)){
				if(strBookTitle == null)
					strBookTitle = (String)vRetResult.elementAt(x+4) +
					", "+(String)vRetResult.elementAt(x+7)+", "+(String)vRetResult.elementAt(x+13);
				else
					strBookTitle += ", " + (String)vRetResult.elementAt(x+4) +
					", "+(String)vRetResult.elementAt(x+7)+", "+(String)vRetResult.elementAt(x+13);
			}
			
			if((iAvailQty <= iAlertFinal)){				
				if(strAlertFinal == null)
					strAlertFinal = (String)vRetResult.elementAt(x+4) +
					", "+(String)vRetResult.elementAt(x+7)+", "+(String)vRetResult.elementAt(x+14);
				else
					strAlertFinal += ", " + (String)vRetResult.elementAt(x+4) +
					", "+(String)vRetResult.elementAt(x+7)+", "+(String)vRetResult.elementAt(x+14);
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
	
	

	
	
	
<%}//if vREtResult not null%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="search_books" value="<%=WI.fillTextValue("search_books")%>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> 
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="order_index" value="<%=strOrderIndex%>" />
	<input type="hidden" name="add_items" />
	
	<input type="hidden" name="for_order" value="1" />
	<input type="hidden" name="is_book_type" value="<%=WI.fillTextValue("is_book_type")%>" />
	<input type="hidden" name="course_index" value="<%=WI.fillTextValue("course_index")%>" />
	<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>" />
	<input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>" />
	<input type="hidden" name="alert_level" value="1" />
	<input type="hidden" name="force_close" />
	<input type="hidden" name="show_all_book_items" value="1" />

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>