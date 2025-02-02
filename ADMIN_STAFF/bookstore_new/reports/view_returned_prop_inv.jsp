<%@ page language="java" import="utility.*, citbookstore.BookManagement, java.util.Vector"%>
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

	function PrintPage(){
		document.form_.print_page.value = '1';
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.submit();
	}

	function SearchBooks(){		
		document.form_.search_books.value = "1";		
		document.form_.submit();
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
								"BOOKSTORE-REPORTS-PROPERTY INVENTORY","view_returned_prop_inv.jsp");
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
	String[] astrSortByName    = {"Book Title","Author","Item Code","Date Returned"};
	String[] astrSortByVal     = {"book_title","author","item_code","bs_book_prop_inv_return.create_date"};
	
	Vector vRetResult = new Vector();
	BookManagement bm = new BookManagement();
	
	String strSYFrom = WI.fillTextValue("sy_from");
	String strSemester = WI.fillTextValue("offering_sem");
	
	
	if(WI.fillTextValue("print_page").length() > 0){		
		if(strSYFrom.length() > 0 && strSemester.length() > 0){		
			//response.sendRedirect("./return_property_inv_print.jsp?sy_from="+strSYFrom+"&offering_sem="+strSemester+"&for_printing=1");							
			dbOP.cleanUP();%>			
			<jsp:forward page="./return_property_inv_print.jsp"></jsp:forward>
			<%return;		
		}
	}
	
	
	int iSearchResult = 0;
	if(strSYFrom.length() > 0 && strSemester.length() > 0 && WI.fillTextValue("search_books").length() > 0){
		vRetResult = bm.getReturnedItems(dbOP, request, strSYFrom, strSemester,1);		
		if(vRetResult == null)
			strErrMsg = bm.getErrMsg();		
		else
			iSearchResult = bm.getSearchCount();
	}
	
	
%>
<body bgcolor="#D2AE72">

<form name="form_" action="view_returned_prop_inv.jsp" method="post">

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
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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
		<tr><td align="right" valign="bottom">
			<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0" /></a>
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
			<td width="10%" height="20" align="center" class="thinborder"><strong>Item Code</strong></td>
			<%
			if(WI.fillTextValue("is_book_type").equals("1"))
				strTemp = "Book Title";
			else
				strTemp = "Item Name";
			%>
			<td width="25%" align="center" class="thinborder"><strong><%=strTemp%></strong></td>			
			<td width="7%" align="center" class="thinborder"><strong>Returned QTY</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Price</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Return by</strong></td>			
			<td align="center" class="thinborder"><strong>Return date</strong></td>			
		</tr>
	<% 
		for(int i = 0; i < vRetResult.size(); i+=11){
	%>
		<tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">			
			<td height="20" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1))%></td>
			<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></td>			
			
			<td class="thinborder" align="right"><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%></td>
			
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5))%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>				
			<%
			strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+7),(String)vRetResult.elementAt(i+8),(String)vRetResult.elementAt(i+9),4);
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>				
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
	<input type="hidden" name="print_page" />
	<input type="hidden" name="iAction" value="1" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>