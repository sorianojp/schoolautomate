<%@ page language="java" import="utility.*, citbookstore.BookPricing, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>View Update Book Quantity</title></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript">

	function loadClassification() {	
		var objCOA=document.getElementById("load_classification");
		var header = "Not Applicable";
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
		document.form_.search_book.value='1';
		document.form_.submit();
	}
	
	function checkAll() {
		var maxDisp = document.form_.total_count.value;
		var bolIsSelAll = document.form_.selAll.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function PrintPg(){
	var PageLoc = "";
	
	if(document.form_.date_type.value == '2'){
		PageLoc = "print_view_update_book_quantity.jsp?book_type="+document.form_.book_type.value+"&book_catg="+document.form_.book_catg.value+
			"&classification="+document.form_.classification.value+"&date_type="+document.form_.date_type.value+"&date_fr="+document.form_.date_fr.value+
			"&date_to="+document.form_.date_to.value+"&for_printing=1";
	}else{
		PageLoc = "print_view_update_book_quantity.jsp?book_type="+document.form_.book_type.value+"&book_catg="+document.form_.book_catg.value+
			"&classification="+document.form_.classification.value+"&date_type="+document.form_.date_type.value+"&date_fr="+document.form_.date_fr.value+
			"&for_printing=1";
	}
	
			
		var win=window.open(PageLoc,"PrintPg",'width=1000,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function SaveQuantity(){
		document.form_.save_quantity.value = "1";
		document.form_.submit();
	}
	
	function toggleSel(objQty, objChkBox){
		if(objQty.value.length > 0)
			objChkBox.checked = true;
		else
			objChkBox.checked = false;
	}
		
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-BOOK MANAGEMENT","update_book_quantity.jsp");
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
	
	BookPricing bp = new BookPricing();
	
	int iSearchResult = 0;
	Vector vRetResult = new Vector();
	if(WI.fillTextValue("search_book").length()>0){
		vRetResult = bp.getBooksEdited(dbOP, request);
		if(vRetResult == null)
			strErrMsg = bp.getErrMsg();
		else
			iSearchResult = bp.getSearchCount();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./view_update_book_quantity.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SET QUANTITY OF BOOKS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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
					<option value="">Not Applicable</option>
					<%=dbOP.loadCombo("g_level","level_name", " from bed_level_info "+strErrMsg, WI.fillTextValue("classification"), false)%> 
				</select>
				</label></td>
		</tr>
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Transaction Date: </td>
			<td width="80%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
				%>
				<select name="date_type" onchange="document.form_.submit();">
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
				<img src="../../images/calendar_new.gif" border="0"></a>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
					if(strTemp.equals("2")){
				%>
				to 
				<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
					value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../images/calendar_new.gif" border="0"></a>
				<%}%></td>
		</tr>
		
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="20%" height="25">&nbsp;</td>
			<td width="80%" colspan="3">
				<a href="javascript:SearchBooks();"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to search book. </font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){
if(iAccessLevel > 1){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<%if(iAccessLevel > 1){%>
		<tr>
			<td height="25" align="right">
				<a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0" /></a>
				<font size="1">Click to print report.</font></td>
		</tr>
		<%}%>
	</table>
<%}%>
<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="10" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>:::  SEARCH RESULTS ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="7">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(bp.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="3"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/bp.defSearchSize;		
				if(iSearchResult % bp.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+bp.getDisplayRange()+")";
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
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Book Title</strong></td>
			<td width="13%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="13%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Item Code </strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Price</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Prev. Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>New Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Difference</strong></td>
			<td width="19%" align="center" class="thinborder"><strong>Modified by & Date</strong></td>
		</tr>
		
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=17, iCount++){
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9), "N/A")%></td>
		  	<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10), "N/A")%></td>
			<td class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+14),(String)vRetResult.elementAt(i+15),(String)vRetResult.elementAt(i+16),4)%> - 
			<%=((String)vRetResult.elementAt(i+12)).substring(0,10)%></td>
			
		</tr>
	<%}%>
	<input type="hidden" name="total_count" value="<%=iCount%>" />
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" align="center">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0" /></a>
					<font size="1">Click to print report.</font>
				<%}else{%>
					Not allowed to save book quantity.
				<%}%>
			</td>
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
	
	<input type="hidden" name="save_quantity" />
	<input type="hidden" name="search_book" value="<%=WI.fillTextValue("search_book")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>