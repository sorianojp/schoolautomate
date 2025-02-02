<%@ page language="java" import="utility.*, citbookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.nav {     
	 font-weight:normal;
}
.nav-highlight {    
     background-color:#BCDEDB;
}

</style>
<title>Stocks Inventory</title></head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>

<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">

	function PrintPg(){
		var pgLoc = "./print_inventory_property.jsp?sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&offering_sem="+document.form_.offering_sem.value+
			"&book_catg="+document.form_.book_catg.value+"&classification="+document.form_.classification.value+
			"&for_printing=1&is_book_type="+document.form_.is_book_type.value+"&book_type="+document.form_.book_type.value;
		
		var win=window.open(pgLoc,"PrintPg",'width=1024,height=600,top=20,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}

	function SearchBooks(){
		if(document.form_.book_catg.value.length == ''){
			alert("Please select book category.");
			return;
		}
		document.form_.search_books.value = "1";
		document.form_.inventory_.value = '1';
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function ViewStudent(strInfoIndex){
		var pgLoc = "./list_student_order.jsp?order_index="+strInfoIndex;
		
		var win=window.open(pgLoc,"ViewStudentOrder",'width=1024,height=600,top=20,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function navRollOver(obj, state) {
	  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
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
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-REPORTS-PROPERTY INVENTORY","inventory_property.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-REPORTS-PROPERTY INVENTORY"),"0"));
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
	
	
	String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Book Title","Author","Item Code"};
	String[] astrSortByVal     = {"book_title","author","item_code"};
	
	int iSearchResult = 0;
	Vector vRetResult = new Vector();
	BookManagement bm = new BookManagement();

	
	boolean bolShowBookWithoutInventory = true;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
		if(strSchCode == null)
			strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");
	
	if(bolIsCIT)
		bolShowBookWithoutInventory = false;
	
	if(WI.fillTextValue("search_books").length() > 0){
		vRetResult = bm.viewPropertyInventory(dbOP, request,1);
		
		if(vRetResult == null)
			strErrMsg = bm.getErrMsg();
		else
			iSearchResult = bm.getSearchCount();		
	}
	
	
%>
<body bgcolor="#D2AE72">

<form name="form_" action="./inventory_property.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: PROPERTY INVENTORY MANAGEMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="1"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>		
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
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
			<td width="17%">Material Type: </td>	
			<%
				strTemp = WI.fillTextValue("is_book_type");
			%>			
		  	<td width="80%">
				<select name="is_book_type" onchange="document.form_.submit();">          			
          			<%if(strTemp.equals("1")){%>
					<option value="1" selected>Book Type</option>
					<%}else{%>
					<option value="1">Book Type</option>
					<%}if(strTemp.equals("0")){%>
					<option value="0" selected>Non-Book Type</option>
					<%}else{%>
					<option value="0">Non-Book Type</option>
					<%}%>
        		</select></td>
		</tr>
	
	
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Type: </td>
				<%				
					strTemp = " from bs_book_type where is_valid = 1 and is_book_type = "+WI.fillTextValue("is_book_type")+" order by type_name ";
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
				strTemp = " from bs_book_catg where is_valid = 1 order by catg_name";
			%>
	  	  <td>
				<select name="book_catg" onChange="loadClassification();">          			
          			<option value="">Select Book Category</option>
					<%=dbOP.loadCombo("catg_index","catg_name", strTemp, strCatg, false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Grade Level:</td>
			<%					
				//strErrMsg = "";				
				strTemp = WI.fillTextValue("classification");
										
				if(strCatg.length() == 0 || strCatg.equals("0") || strCatg.equals("2"))//college or not selected
					strErrMsg = " where edu_level = 0 ";
				else
					strErrMsg = "";
			
			%>
			<td>
				<label id="load_classification">
				<select name="classification">
					<option value="">All</option>
					<%=dbOP.loadCombo("g_level","level_name", " from bed_level_info "+strErrMsg, strTemp, false)%> 
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
	</table>
	
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr><td height="10" colspan="6"></td></tr>
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
		<!--<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td height="25" colspan="3">
			<%
				if(WI.fillTextValue("view_all").length() > 0)
					strTemp = " checked";				
				else
					strTemp = "";
			%>
			<input name="view_all" type="checkbox" value="1"<%//=strTemp%> onClick="document.form_.submit();"> View ALL</td>
	    </tr>-->
		<input type="hidden" name="view_all" />
		<tr>
			<td height="25" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="3">
				<a href="javascript:SearchBooks();"><img src="../../../images/form_proceed.gif" border="0" /></a>
			</td>
		</tr>
		<tr>
			<td height="25" colspan="5">&nbsp;</td>
		</tr>
	</table>
	
	
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" >
		<tr><td align="right">
			<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
			<font size="1">Click to print report</font>
		</td></tr>
		<tr><td height="15"></td></tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="12" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>:::  SEARCH RESULTS ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="7">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(bm.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="5"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/bm.defSearchSize;		
				if(iSearchResult % bm.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+bm.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="javascript:SearchBooks();">
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
			<td width="25%" align="center" class="thinborder"><strong>Book Title </strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Beginning Inventory</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Current Inventory</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Total Sales</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Returned Not Defective</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Returned Defective</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Available Quantity</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Total Qty Order</strong></td>			
			<td width="7%" align="center" class="thinborder"><strong>Total Delivered</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Total Accepted</strong></td>			
			<td width="7%" align="center" class="thinborder"><strong>Price</strong></td>
		</tr>
	<% 	int iCount = 1;
		String strSQLQuery = null;
		String strQty = null;
		for(int i = 0; i < vRetResult.size(); i+=11, iCount++){
	%>
		<tr title="<%=(String)vRetResult.elementAt(i)%>" class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7), "0")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8), "0")%></td>
			
			<%
				int iRetNotDef = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+9), "0"));
				int iRetDef = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+10), "0"));
				
				int totAccepted = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+6), "0"));
				
				int iTotSales = (totAccepted - iRetNotDef) - iRetDef;
			%>
			
			<td class="thinborder">&nbsp;<%=iTotSales%></td>
			
			<td class="thinborder">&nbsp;<%=iRetNotDef%></td>
			<td class="thinborder">&nbsp;<%=iRetDef%></td>
			
			
			
			<%
				//int iAvailQty = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2), "0"));		
				
				int iPrevInv = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+7), "0"));
				int iCurrInv = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+8), "0"));
				int iTotDelivered = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5), "0"));
				
				int iAvailQty = (iPrevInv + iCurrInv) - iTotDelivered;
				
				iAvailQty = iAvailQty + iRetNotDef +  iRetDef;
						
			%>		
			
			<td class="thinborder">&nbsp;<%=iAvailQty%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"0")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5), "0")%></td>
			<td class="thinborder">&nbsp;<%=totAccepted%></td>				
			<td class="thinborder" align="right"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "0")%>&nbsp;</td>			
		</tr>
	<%}%>
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
	<input type="hidden" name="inventory_" value="<%=WI.fillTextValue("inventory_")%>"  />
	<input type="hidden" name="for_order" value="1"  />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>