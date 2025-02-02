<%@ page language="java" import="utility.*, citbookstore.BookReports,citbookstore.BookManagement, java.util.Vector"%>
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
<title>Untitled Document</title></head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="javascript">
	function FixDiscrepancy(){
		document.form_.fix_discrepancy.value = "1";
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

	function SearchBooks(){
		if(document.form_.book_catg.value.length == ''){
			alert("Please select book category.");
			return;
		}
		document.form_.search_books.value = "1";
		document.form_.submit();
	}
	
	function checkAllSaveItems() {
			
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
</script>
<%

	String strBookType = WI.fillTextValue("is_book_type");	
	if(strBookType.length() == 0)
		strBookType = "1";

	boolean bolIsBasic = false;
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;	
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-REPORTS-STOCKS ORDERED","fix_discrepancy_qty.jsp");
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
	boolean bolIsProperty = false;
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-REPORTS-STOCKS ORDERED"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		else{//check if property
			int iiAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-PROPERTY"),"0"));
			if(iiAccessLevel > 0)
				bolIsProperty = true;
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
	
	
	if(strBookType.equals("1"))
		strTemp = "Book Title";
	else
		strTemp = "Item Name";
	
	String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {strTemp,"Author","Item Code"};
	String[] astrSortByVal     = {"book_title","author","item_code"};
	
	Vector vRetResult = null;
	BookManagement bm = new BookManagement();
	
	if(WI.fillTextValue("fix_discrepancy").length() > 0){
		if(!bm.fixDiscrepancy(dbOP, request))
			strErrMsg = bm.getErrMsg();
		else
			strErrMsg = "Discrepancy Fixed.";
	}
	
	if(WI.fillTextValue("search_books").length() > 0){
		vRetResult = bm.getInventoryDiscrepancy(dbOP, request);
		if(vRetResult == null)
			strErrMsg = bm.getErrMsg();
	}
	
%>
<body bgcolor="#D2AE72">

<form name="form_" action="./fix_discrepancy_qty.jsp" method="post">
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: FIX DISCREPANCY ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">SY/TERM: </td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
			<td width="80%">
				<select name="semester">              	
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
					strTemp = " from bs_book_type where is_valid = 1 and is_book_type = "+strBookType+" order by type_name ";
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
							
				strTemp = WI.fillTextValue("classification");
				/*
				if(!bolIsProperty){					
					if(strYearLevel.equals("1"))//college or not selected
						strErrMsg = " where edu_level = 0 ";
					else{
						if(strYearLevel.equals("2"))
							strErrMsg = " where g_level > 10 ";
						else
							strErrMsg = " where g_level < 11 ";
					}
				}*/
			%>
			<td>
				<label id="load_classification">
				<select name="classification">
					<option value="">All</option>
					<%=dbOP.loadCombo("g_level","level_name", " from bed_level_info ", strTemp, false)%> 
				</select>
				</label></td>
		</tr>
		
		
				
		<%//}%>
		
		<tr>
			<td height="10" colspan="3"></td>
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
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="13" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>:::  SEARCH RESULTS ::: </strong></div></td>
		</tr>
		
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<%
			if(strBookType.equals("1"))
				strTemp = "Book Title";
			else
				strTemp = "Item Name";
			%>
			<td width="" align="center" class="thinborder"><strong><%=strTemp%></strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Available Qty</strong></td>						
			<td width="5%" align="center" class="thinborder"><strong>Released Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Paid Unreleased Qty</strong></td>		
			<td width="5%" align="center" class="thinborder"><strong>Ordered Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Physical Count</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Discrepancy</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=8, iCount++){			
	%>
		<tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')" title="<%=vRetResult.elementAt(i)%>">
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2), "0")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3), "0")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4), "0")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "0")%></td>
			
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5), "0")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7), "0")%></td>			
			<%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+7), "0") +".."+ (String)vRetResult.elementAt(i);
			%>
			<td class="thinborder" align="center">				
				<input type="checkbox" name="save_<%=iCount%>" value="<%=strTemp%>" tabindex="-1" ></td>							
		</tr>
	<%}%>
	<input type="hidden" name="item_count" value="<%=iCount%>"  />
	</table>
	
	
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td align="right">
<input type="button" name="save_me" value=" FIX QUANTITY " 
	onclick="javascript:FixDiscrepancy();" style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
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
	
	<input type="hidden" name="fix_discrepancy" />			
	<input type="hidden" name="search_books" />			
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>