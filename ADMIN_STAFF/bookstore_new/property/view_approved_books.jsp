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
<script language="javascript">
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
	
	function UndeliveredBooks(){		
		document.form_.show_info.value='1'; 
		document.form_.view_approved_books_.value = '';
		document.form_.submit();
	}
	
	function DeliveredBooks(){		
		document.form_.show_info.value='1'; 
		document.form_.view_approved_books_.value = '1';
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
	
	function FinalizeDisapprovedItem(){
		if(!confirm("Do you want to disapproved this item(s)? "))
			return;
			
		document.form_.disapproved_item.value = "1";
		document.form_.submit();		
	}
	
	
	
	
	function DisapproveItem(){
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
			alert("Please select atleast one item to disapproved");			
			return;
		}
		
		document.getElementById('processing').style.visibility = 'visible';	
		document.form_.request_indexes.value = strTemp;		
		document.form_.show_info.value='1'; 
		document.form_.show_div.value = '1';
		document.form_.submit();
		
	}
	
	
	function PrintPg(){
		var maxDisp = document.form_.item_count.value;
		var printIt = "";
		var iCount = 0;
		var strTemp = null;
		for(var i=1; i< maxDisp; ++i){
			if(eval('document.form_.save_'+i+'.checked')){
				iCount++;
				printIt = '1';
				if(strTemp == null)	
					strTemp = eval('document.form_.save_'+i+'.value');
				else
					strTemp += ", "+eval('document.form_.save_'+i+'.value');
			}			
		}
		
		if(iCount == 0)
		{
				alert("Please select atleast one boook to deliver");
				printIt = "";
				return;
		}		
		
		if(printIt.length > 0){
			var pgLoc = "./print_deliverylist.jsp?offering_sem="+document.form_.offering_sem.value+"&sy_from="+document.form_.sy_from.value+
				"&sy_to="+document.form_.sy_to.value+"&book_catg="+document.form_.book_catg.value+"&classification="+document.form_.classification.value+
				"&for_printing=1&item_count="+document.form_.item_count.value+"&strCSV="+strTemp;			
			var win=window.open(pgLoc,"PrintPg",'width=1000,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
			win.focus();
		}
	}
		
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-PROPERTY","view_approved_books.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-PROPERTY"),"0"));
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

	
	int iSearchResult = 0;
	Vector vApprovedBook = null;
		
	BookRequest br = new BookRequest();	
	BookManagement bm = new BookManagement();
	
	if(WI.fillTextValue("disapproved_item").equals("1")){
		if(br.operateOnBookDeliveryProcess(dbOP, request, 3) == null)
			strErrMsg = br.getErrMsg();
		else
			strErrMsg = "Item(s) Disapprove.";
	}
	
	
	if(WI.fillTextValue("show_info").compareTo("1")==0){		
		vApprovedBook = br.operateOnBookDeliveryProcess(dbOP, request, 2);			
		if(vApprovedBook == null)
			strErrMsg = br.getErrMsg();
		else
			iSearchResult = br.getSearchCount();
	}
	
	
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./view_approved_books.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable1">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: PROPERTY REQUEST MONITORING - APPROVED BOOKS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">SY/Term:</td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
		  	<td width="" colspan="2">
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
			%>
			
			<td colspan="2"><select name="book_catg" onChange="loadClassification();document.form_.submit();">
          			<option value="">Select Book Category</option>
          			<%=dbOP.loadCombo("catg_index","catg_name", " from bs_book_catg where is_valid = 1 order by catg_name ", strCatg, false)%> 
        		</select></td>
		</tr>
		
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Grade Level :</td>
			<%			
				strTemp = WI.fillTextValue("classification");			
				if(strCatg.length() == 0 || strCatg.equals("0") || strCatg.equals("2"))//college or not selected
					strErrMsg = " where edu_level = 0 ";
				else
					strErrMsg = "";
			%>
			<td colspan="2"><label id="load_classification">
				<select name="classification" onchange="document.form_.submit();">
					<option value="">All</option>
				<%=dbOP.loadCombo("g_level","level_name", " from bed_level_info "+strErrMsg, strTemp, false)%> 
				</select>
				</label></td>
		</tr>
		
		
		
		<tr><td height="15" colspan="4">&nbsp;</td></tr>
		<tr>
		  	<td height="25" colspan="2">&nbsp;</td>
	  	  	<td height="25"><input type="button" name="request_book2" value=" UNDELIVERED BOOKS " 
					onclick="UndeliveredBooks();" style="font-size:11px; height:25px;border: 1px solid #FF0000;" />
					
			<input type="button" name="request_book2" value=" DELIVERED BOOKS " 
					onclick="DeliveredBooks();" style="font-size:11px; height:25px;border: 1px solid #FF0000;" /></td>
	  </tr>
	  <tr><td colspan="4" height="25">&nbsp;</td></tr>
	</table>


<%if(vApprovedBook != null && vApprovedBook.size() >0){%>

		<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable3">
			
			<tr>
				<td>
					&nbsp;
					<%if(WI.fillTextValue("view_approved_books_").length()==0){%>
					<a href="javascript:DisapproveItem();"><img src="../../../images/delete.gif" border="0" /></a>					
					<font size="1">Click to disapprove undelivered books</font>
					<%}%>
				</td>
				<td align="right">
				<%if(WI.fillTextValue("view_approved_books_").length()==0){%>
					<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
					<font size="1">Click to print for delivery</font>
				<%}%>
				&nbsp;
				</td>
			</tr>
			<tr><td height="15">&nbsp;</td></tr>
		</table>

		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<%
				strTemp = "";
				if(WI.fillTextValue("view_approved_books_").length() > 0)
					strTemp = " AND DELIVERED ";
			%>
			<tr>
				<td height="20" bgcolor="#B9B292" colspan="12" class="thinborder"><div align="center"><strong>LIST OF APPROVED <%=strTemp%> BOOKS </strong></div></td>
			</tr>
			
			<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="6">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(br.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="6"> &nbsp;
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
				<td width="20%" align="center" class="thinborder"><strong>Title</strong></td>
				<td width="10%" align="center" class="thinborder"><strong>Author</strong></td>
				<td width="15%" align="center" class="thinborder"><strong>Publisher</strong></td>				
				<td width="5%" align="center" class="thinborder"><strong>Qty</strong></td>								
				<td width="15%" align="center" class="thinborder"><strong>Approved By</strong></td>
				<td width="10%" align="center" class="thinborder"><strong>Approved Date</strong></td>
				<td width="15%" align="center" class="thinborder"><strong>Requested by</strong></td>	
						
				<td width="5%" align="center" class="thinborder">				
				<strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();">				
				</td>		
				
			</tr>
			
			<%
			int iCount=1;
			for(int i=0;i<vApprovedBook.size();i+=16,iCount++){%>
			<tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
				<td align="center" height="25" class="thinborder"><%=iCount%></td>
				<td align="" class="thinborder"><%=(String)vApprovedBook.elementAt(i+2)%></td>
				<td align="" class="thinborder"><%=WI.getStrValue(vApprovedBook.elementAt(i+3),"N/A")%></td>
				<td align="" class="thinborder"><%=WI.getStrValue(vApprovedBook.elementAt(i+5),"N/A")%></td>				
				<td align="left" class="thinborder"><%=(String)vApprovedBook.elementAt(i+4)%></td>												
				<td align="" class="thinborder">
				<%=WebInterface.formatName((String)vApprovedBook.elementAt(i+9),(String)vApprovedBook.elementAt(i+10),(String)vApprovedBook.elementAt(i+11),4)%>			
					</td>												
				<td align="" class="thinborder"><%=((String)vApprovedBook.elementAt(i+7)).substring(0,10)%></td>
				<td align="" class="thinborder">
					
					<%=WI.getStrValue((String)vApprovedBook.elementAt(i+13))%>
					<%=WI.getStrValue((String)vApprovedBook.elementAt(i+14),"/ ","","")%>
					<%=WI.getStrValue((String)vApprovedBook.elementAt(i+15),"/ ","","")%>					
				</td>
						
				<td class="thinborder" align="center">		
				<%if(WI.fillTextValue("view_approved_books_").length() == 0){%>			
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vApprovedBook.elementAt(i)%>" tabindex="-1" >
				<%}else{%>
					<input type="hidden" name="save_<%=iCount%>" value="" />
					&nbsp;
				<%}%>
				</td>
				
			</tr>			

			<%}%>		
			<input type="hidden" name="item_count" value="<%=iCount%>"  />
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
  	<tr><td valign="top" colspan="2" align="center"><u><b>DISAPPROVE REQUEST</b></u></td></tr>
	<tr><td colspan="2">Remarks</td></tr>
	<tr><td colspan="2"><textarea name="remarks_" style="width:100%;"><%=WI.fillTextValue("remarks_")%></textarea></td></tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr><td colspan="2">
	&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
	<a href="javascript:FinalizeDisapprovedItem();">
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
	
	<input type="hidden" name="show_info" />
	<input type="hidden" name="page_action" />
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="sel_book" value="<%=WI.fillTextValue("sel_book")%>"  />
	<input type="hidden" name="is_printing" value="0"  />
	<input type="hidden" name="view_approved_books_"  value="<%=WI.fillTextValue("view_approved_books_")%>"/>
	<input type="hidden" name="request_indexes" value="<%=WI.fillTextValue("request_indexes")%>" />
	<input type="hidden" name="show_div" value=""/>
	<input type="hidden" name="disapproved_item" value="" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
