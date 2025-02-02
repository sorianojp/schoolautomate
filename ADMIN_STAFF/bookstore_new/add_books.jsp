<%@ page language="java" import="utility.*, citbookstore.BookManagement, citbookstore.BookLogs, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Add Order Items</title>
</head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
	
	function addItems(){
		document.form_.add_items.value = "1";
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
		document.form_.search_books.value = "1";
		document.form_.submit();
	}
	
	function checkAllSaveItems() {
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.item_'+i+'.checked='+bolIsSelAll);
	}
	
	function toggleSel(objQty, objChkBox){
		if(objQty.value.length > 0)
			objChkBox.checked = true;
		else
			objChkBox.checked = false;
	}
	
	function GoBack(){
		location = "./book_supply_log_main.jsp";
	}
		
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-BOOK MANAGEMENT","add_books.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-BOOK MANAGEMENT"),"0"));
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
		//iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
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
	BookLogs bl = new BookLogs();
	BookManagement bm = new BookManagement();
	
	if(WI.fillTextValue("add_items").length() > 0){
		if(bl.operateOnBookLogs(dbOP, request, 1) == null)
			strErrMsg = bl.getErrMsg();
		else
			strErrMsg = "Book log(s) added successfully.";
	}
	
	if(WI.fillTextValue("search_books").length() > 0){
		vRetResult = bm.searchBooks(dbOP, request,1);
		if(vRetResult == null){
			if(WI.fillTextValue("add_items").length() == 0)
				strErrMsg = bm.getErrMsg();
		}
		else
			iSearchResult = bm.getSearchCount();	
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./add_books.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: ADD BOOKS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="87%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right"><a href="javascript:GoBack();"><img src="../../images/go_back.gif" border="0" /></a></td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Type: </td>
		  	<td width="80%">
				<select name="book_type">
          			<option value="">Select Book Type</option>
          			<%=dbOP.loadCombo("type_index","type_name", " from bs_book_type where is_valid = 1 order by type_name ", WI.fillTextValue("book_type"), false)%> 
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
		</tr><tr>
			<td height="15" colspan="3">&nbsp;</td>
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
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="4">
				<a href="javascript:SearchBooks();"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to search for  books.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="5"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="12%">Log Date: </td>
			<td width="35%">
				<input name="log_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("log_date")%>" 
					class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
				&nbsp;
				<a href="javascript:show_calendar('form_.log_date');" title="Click to select date" 
					onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;">
				<img src="../../images/calendar_new.gif" border="0" /> </a></td>
			<td width="12%">PO Num: </td>
			<td width="38%">
				<input type="text" name="po_num" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="20" maxlength="16" value="<%=WI.fillTextValue("po_num")%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		  	<td>Supplier:</td>
		  	<td>
				<select name="supplier_index">
					<option value="">Select Supplier</option>
                  	<%=dbOP.loadCombo("profile_index","supplier_name"," from pur_supplier_profile where is_del = 0 order by supplier_name",WI.fillTextValue("supplier_index"), false)%>
				</select></td>
		  	<td>DR Num: </td>
		  	<td>
			<input type="text" name="dr_num" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="20" maxlength="16" value="<%=WI.fillTextValue("dr_num")%>"/></td>
	  	</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">&nbsp;
				<%if(iAccessLevel > 1){%>
					<input type="button" name="add" value=" Add Book(s) " onclick="javascript:addItems();"
						style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
		        <%}%></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>:::  BOOK ENTRY LISTING ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="5">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(bm.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="4"> &nbsp;
			<%
				int iPageCount = 1;
				int iDefSearchSize = bm.defSearchSize;
				
				if(iDefSearchSize > 0){
					iPageCount = iSearchResult/iDefSearchSize;		
					if(iSearchResult % bm.defSearchSize > 0)
						++iPageCount;
				}
									
				strTemp = " - Showing("+bm.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.search_books.value='1';document.form_.submit();">
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
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Item Code </strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Book Title </strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="9%" align="center" class="thinborder"><strong>Price</strong></td>
			<td width="9%" align="center" class="thinborder"><strong>Avail. Qty.</strong></td>
			<td width="9%" align="center" class="thinborder"><strong>Log Qty</strong></td>
			<td width="6%" align="center" class="thinborder"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=10, iCount++){
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5), "N/A")%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+8), true)%>&nbsp;</td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
			<td class="thinborder" align="center">
				<input type="text" name="qty_<%=iCount%>" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','qty_<%=iCount%>');style.backgroundColor='white';toggleSel(document.form_.qty_<%=iCount%>, document.form_.item_<%=iCount%>)" 
					onkeyup="AllowOnlyInteger('form_','qty_<%=iCount%>')" size="5" maxlength="10" /></td>
			<td class="thinborder" align="center">
				<input type="checkbox" name="item_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1"></td>
		</tr>
	<%}%>
		<input type="hidden" name="item_count" value="<%=iCount%>" />
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
	
	<input type="hidden" name="search_books" />
	<input type="hidden" name="add_items" />
	<input type="hidden" name="f5_identifier" value="<%=new java.util.Date().getTime()%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>