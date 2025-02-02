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
<title>Stocks Ordered</title></head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="javascript">
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
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function ReturnBooks(){
		document.form_.return_books.value='1';
		document.form_.submit();
	}
	
	function ViewStudent(strInfoIndex,strAction){
		var pgLoc = "./list_student_order.jsp?book_index="+strInfoIndex+"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+"&offering_sem="+document.form_.offering_sem.value+"&iAction="+strAction+
		"&catg_index="+document.form_.book_catg.value+"&search_books=1";
		
		var win=window.open(pgLoc,"ViewStudentOrder",'width=1024,height=600,top=20,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function PrintPg(){
		var maxDisp = document.form_.item_count.value;
		var printIt = "";
		var iCount = 0;
		var strTemp = null;
		var qty = "";
		for(var i=1; i< maxDisp; ++i){
			if(eval('document.form_.save_'+i+'.checked')){
				iCount++;
				printIt = '1';
				
				if(eval('document.form_.qty_'+i+'.value.length == 0'))			
					qty = '0'; //if 0 then i will get all of his available item
				else
					qty = eval('document.form_.qty_'+i+'.value');
				

			if(strTemp == null)	
				strTemp = eval('document.form_.save_'+i+'.value')+", "+qty;
			else
				strTemp += ", "+eval('document.form_.save_'+i+'.value')+", "+qty;
			}		
		}
		
		if(iCount == 0)
		{
				alert("Please select atleast one boook to return.");
				printIt = "";
				return;
		}		
		
		if(printIt.length > 0){
			var pgLoc = "./print_stocks_return.jsp?offering_sem="+document.form_.offering_sem.value+
			"&sy_from="+document.form_.sy_from.value+
			"&sy_to="+document.form_.sy_to.value+"&catg_index="+document.form_.catg_index.value+
			"&ditribution_loc="+document.form_.ditribution_loc.value+
			"&for_printing=1&item_count="+document.form_.item_count.value+"&strCSV="+strTemp;			
var win=window.open(pgLoc,"PrintPg",'width=1000,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
			win.focus();
		}
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
	boolean bolFatalErr = false;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-REPORTS-STOCKS ORDERED","stocks_ordered.jsp");
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
	
	if(!bolIsProperty){
		strTemp = dbOP.mapOneToOther("BS_BOOK_LOGIN_TERMINAL","IP_ADDR","'"+request.getRemoteAddr()+"'",
                          "LOGIN_TERM_INDEX"," and is_valid = 1");
		if(strTemp == null) {
			strErrMsg = "IP : "+request.getRemoteAddr()+" IS NOT ASSINGED FOR LOGIN TERMINAL";
			bolFatalErr = true;
		}
	}
	
	
	if(strBookType.equals("1"))
		strTemp = "Book Title";
	else
		strTemp = "Item Name";
	
	String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {strTemp,"Author","Item Code"};
	String[] astrSortByVal     = {"book_title","author","item_code"};
	
	Vector vRetResult = null;
	Vector vLocCatgIndex = new Vector();	
	
	BookReports br = new BookReports();	
	BookManagement bm = new BookManagement();
	
	//i have to check the IP to check if he is college/highschool/elem distribution center.	
	String strYearLevel = null;
	vLocCatgIndex = bm.checkIPAddress(dbOP,request,request.getRemoteAddr());
	
	if(WI.fillTextValue("search_books").length() > 0){
		vRetResult = br.searchStocksOrderedBySY(dbOP, request,1,null);//this null is for book_index.. used if iAction=2,3,4,5
		if(vRetResult == null)
			strErrMsg = br.getErrMsg();		
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

<form name="form_" action="./stocks_ordered_basic.jsp" method="post">
	
	<%
	strYearLevel = (String)vLocCatgIndex.elementAt(0);
	if(!strYearLevel.equals("1"))//college or not selected
		bolIsBasic = true;
		
	if(bolIsProperty)
		bolIsBasic = false;
	%>	
	
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: STOCKS ORDERED ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">SY/TERM: </td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
			<td width="80%">
				<select name="offering_sem">
              	<%if(bolIsBasic){%>
					<%if(strTemp.equals("1")){%>
              			<option value="1" selected>Regular Sem</option>
					<%}else{%>
						<option value="1">Regular Sem</option>					
					<%}if(strTemp.equals("0")){%>
						<option value="0" selected>Summer</option>
					<%}else{%>
						<option value="0">Summer</option>
					<%}%>				
				<%}else{%>
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
		
		<%
		//bolIsProperty = true;
		//if(bolIsProperty){
		%>
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
				if(!bolIsProperty)
					strTemp = " from bs_book_catg where is_valid = 1 and catg_index="+(String)vLocCatgIndex.elementAt(1)+" order by catg_name";
				else
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
				strErrMsg = "";				
				strTemp = WI.fillTextValue("classification");
				
				if(!bolIsProperty){					
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
			<td>
				<label id="load_classification">
				<select name="classification">
					<option value="">All</option>
					<%=dbOP.loadCombo("g_level","level_name", " from bed_level_info "+strErrMsg, strTemp, false)%> 
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
			<td width="25%" align="center" class="thinborder"><strong><%=strTemp%></strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Item Code </strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Available Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Defective Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Ordered Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Released Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Paid Unreleased Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Unpaid Unreleased Qty</strong></td>			
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=13, iCount++){			
	%>
		<tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6),"0")%></td>
			
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+11)%></td>
			<td class="thinborder">&nbsp;<a href="javascript:ViewStudent('<%=vRetResult.elementAt(i)%>','2')"><%=(String)vRetResult.elementAt(i+7)%></a></td>			
			<td class="thinborder">&nbsp;<a href="javascript:ViewStudent('<%=vRetResult.elementAt(i)%>','3')"><%=(String)vRetResult.elementAt(i+8)%></a></td>	
			<td class="thinborder">&nbsp;<a href="javascript:ViewStudent('<%=vRetResult.elementAt(i)%>','4')"><%=(String)vRetResult.elementAt(i+9)%></a></td>			
			<td class="thinborder">&nbsp;<a href="javascript:ViewStudent('<%=vRetResult.elementAt(i)%>','5')"><%=(String)vRetResult.elementAt(i+10)%></a></td>				
		</tr>
	<%}%>
	<input type="hidden" name="item_count" value="<%=iCount%>"  />
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
	
	<%if(!bolIsProperty && false){%>
	<input type="hidden" name="catg_index" value="<%=(String)vLocCatgIndex.elementAt(1)%>"  />
	<input type="hidden" name="ditribution_loc" value="<%=(String)vLocCatgIndex.elementAt(0)%>"  />
	<%}%>
	
	<input type="hidden" name="view_all" value="" />
	<input type="hidden" name="return_books" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>