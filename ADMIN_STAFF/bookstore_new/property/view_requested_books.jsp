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
<title>Ordering</title>

<style>
.nav {
     /**color: #000000;**/
	 font-weight:normal;
}
.nav-highlight {
     /**color: #0000FF;**/
     background-color:#BCDEDB;
}

</style>
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
	
	function checkAllSaveItems() {
			
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
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
	
	
	function PrintPg(){
		var pgLoc = "./print_requested_books.jsp?offering_sem="+document.form_.offering_sem.value+"&sy_from="+document.form_.sy_from.value+
			"&sy_to="+document.form_.sy_to.value+"&book_catg="+document.form_.book_catg.value+"&classification="+document.form_.classification.value+
			"&view_request_book=2&for_printing=1";
			
		var win=window.open(pgLoc,"PrintPg",'width=1000,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function ApprovedBooks(){	
	document.form_.page_action.value='1'; 
	document.form_.show_info.value='1';
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
								"BOOKSTORE-PROPERTY","view_requested_books.jsp");
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
	Vector vRetResult = null;
	String[] astrConvertSem = {"SUMMER","1st SEMESTER","2nd SEMESTER","3rd SEMESTER"};	
	
	BookRequest br = new BookRequest();
	
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0) {
		if(br.operateOnBookDeliveryProcess(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = br.getErrMsg();
		else{
			if(strTemp.equals("1"))
				strErrMsg = "Requested Books Approved.";
		}	
			
	}
	
	if(WI.fillTextValue("show_info").compareTo("1")==0){
		vRetResult = br.operateOnBookRequest(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = br.getErrMsg();
		else
			iSearchResult = br.getSearchCount();
	}
	
	
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="view_requested_books.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: PROPERTY REQUEST MONITORING - REQUESTED BOOKS ::::</strong></font></div></td>
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
			%>
			
			<td><select name="book_catg" onChange="loadClassification();">
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
			<td><label id="load_classification">
				<select name="classification">
					<option value="">All</option>
					<%=dbOP.loadCombo(" g_level "," level_name ", " from bed_level_info"+strErrMsg, strTemp, false)%> 
				</select>
				</label></td>
		</tr>
		
		
		
		
		
		
		
		
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
		  	<td height="25" colspan="2">&nbsp;</td>
	  	  <td height="25"><input type="button" name="request_book2" value=" VIEW REQUESTED BOOKS " 
					onclick="document.form_.show_info.value='1'; document.form_.submit();" style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></td>
	  </tr>
	  <tr><td colspan="3" height="25">&nbsp;</td></tr>
	</table>


	<%if(vRetResult != null && vRetResult.size() >0){%>
		<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
			
			<tr>
				<td align="left"> &nbsp; &nbsp; 
					<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
					<font size="1">Click to print requested books</font>
			  </td>
				<td align="right"><input type="button" name="request_book" value=" APPROVED REQUESTED BOOKS " 
					onclick="ApprovedBooks();" style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></td>
			</tr>
			<tr><td height="15" colspan="2">&nbsp;</td></tr>	
			
		</table>
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr>
				<td height="20" bgcolor="#B9B292" colspan="12" class="thinborder"><div align="center">
					<strong>LIST OF REQUESTED BOOKS &nbsp; &nbsp; SY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>
					&nbsp;<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>
					</strong></div></td>
			</tr>
			
			<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(br.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="7"> &nbsp;
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
				<td width="10%" align="center" class="thinborder"><strong>Author</strong></td>
				<td width="10%" align="center" class="thinborder"><strong>Publisher</strong></td>				
				<td width="5%" align="center" class="thinborder"><strong>Qty</strong></td>	
				<td width="5%" align="center" class="thinborder"><strong>Approved</strong></td>	
				<td width="15%" align="center" class="thinborder"><strong>Year/Grade Level</strong></td>
				<td width="10%" align="center" class="thinborder"><strong>Requested by</strong></td>
				<td width="10%" align="center" class="thinborder"><strong>Department</strong></td>
				<td width="10%" align="center" class="thinborder"><strong>Requested Date</strong></td>	
				<td width="5%"  align="center" class="thinborder"><strong>SELECT ALL<br /></strong>
					<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();">
				</td>
				
			</tr>
			
			<%
			int iCount=1;
			for(int i=0; i < vRetResult.size(); i+=21,iCount++){%>
			<tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
				<td   align="center" height="25" class="thinborder"><%=iCount%></td>
				<td align="" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
				<td align="" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3),"N/A")%></td>
				<td align="" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+5),"N/A")%></td>				
				<td align="" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>	
				<td align="center" class="thinborder">
					<%
					strErrMsg = "";
					strTemp = (String)vRetResult.elementAt(i+13);					
					if(strTemp.equals("1")){%>
					<img src="../../../images/tick.gif" border="0" />
					<%}else{%>
					<img src="../../../images/x.gif" border="0" />
					<%}%>
				
				</td>		
				<td align="" class="thinborder">
					
						<%=WI.getStrValue((String)vRetResult.elementAt(i+9))%>
						<%=WI.getStrValue((String)vRetResult.elementAt(i+10),"/ ","","")%>
						<%=WI.getStrValue((String)vRetResult.elementAt(i+11),"/ ","","")%>
			  	</td>								
				
				<input type="hidden" name="book_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>"  />
				<td align="left" class="thinborder">
				<%=WebInterface.formatName((String)vRetResult.elementAt(i+17),(String)vRetResult.elementAt(i+18),(String)vRetResult.elementAt(i+19),4)%>					
				</td>
				
				<%
					strTemp = (String)vRetResult.elementAt(i+20);					
					int iIndexOf = strTemp.indexOf("DISTRIBUTION");					
					strTemp = strTemp.substring(0,iIndexOf);
				%>				
				<td align="left" class="thinborder"> <%=WI.getStrValue(strTemp)%></td>					
				<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+15)%></td>
				
				<td height="25" align="center" class="thinborder">
					<%if(!((String)vRetResult.elementAt(i+13)).equals("1")){%>					
						<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1" />					
					<%}else{%>
						<input type="hidden" name="save_<%=iCount%>" value="" />
						&nbsp;
					<%}%>
				</td>
			</tr>
			<%}%>
			<input type="hidden" name="item_count" value="<%=iCount%>" />			
		</table>
		
		

		
<%}//end of vRetResult!=null%>















	
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="show_info"/>
	<input type="hidden" name="page_action" />
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

	<input type="hidden" name="sel_book" value="<%=WI.fillTextValue("sel_book")%>"  />
	<input type="hidden" name="view_request_book" value="2" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
