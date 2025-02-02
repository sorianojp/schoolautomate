<%@ page language="java" import="utility.*, bookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Book Management</title></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function UpdateSubjects(strBookIndex, strCatg){
		var pgLoc = "./book_subjects.jsp?book_index="+strBookIndex+"&book_catg="+strCatg;	
		var win=window.open(pgLoc,"UpdateSubjects",'width=850,height=600,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function UpdateBookType(){
		var pgLoc = "./book_type.jsp";	
		var win=window.open(pgLoc,"UpdateBookType",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function UpdatePublisher(){
		var pgLoc = "./publisher.jsp";	
		var win=window.open(pgLoc,"UpdatePublisher",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function loadClassification() {	
		var objCOA=document.getElementById("load_classification");
		var header = "Not Applicable";
		var selName = "classification";
		var onChange = "";
		var tableName = "bed_level_info";
		var fields = "g_level,level_name";
		var headerValue = "0";
		
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
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete book entry?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function RefreshPage() {
		location = "./book_management.jsp";
	}
	
	function ReloadPage(){
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
								"BOOKSTORE-BOOK MANAGEMENT","book_management.jsp");
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
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-BOOK MANAGEMENT-MANAGEMENT"),"0"));
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

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo  = null; 
	Vector vRetResult = null;
	
	BookManagement bm = new BookManagement();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(bm.operateOnBookEntries(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = bm.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Book entry successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Book entry successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Book entry successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}
	
	int iSearchResult = 0;
	vRetResult = bm.operateOnBookEntries(dbOP, request, 4);
	if(vRetResult == null){
		if(strTemp.length() == 0)
			strErrMsg = bm.getErrMsg();
	}
	else
		iSearchResult = bm.getSearchCount();

	if(strPrepareToEdit.equals("1")){
		vEditInfo = bm.operateOnBookEntries(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = bm.getErrMsg();
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./book_management.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: BOOK MANAGEMENT ::::</strong></font></div></td>
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
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("book_type");
				%>
			    <select name="book_type" onchange="document.form_.submit();">
                  <option value="">Select Book Type</option>
                  <%=dbOP.loadCombo("type_index","type_name", " from bs_book_type where is_valid = 1 order by type_name ", strTemp, false)%>
                </select>
		      &nbsp;&nbsp;
			  <a href="javascript:UpdateBookType();"><img src="../../images/update.gif" border="0" /></a>
	  		  <font size="1">Click to update book type</font></td>
		</tr>
	<%if(strTemp.length() > 0){
		boolean bolIsBookType = bm.checkIfBookType(dbOP, strTemp);
	%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Category:</td>
		  	<td>
				<%
					String strCatg = null;
					if(vEditInfo != null && vEditInfo.size() > 0)
						strCatg = (String)vEditInfo.elementAt(3);
					else
						strCatg = WI.fillTextValue("book_catg");
				%>
				<select name="book_catg" onChange="loadClassification();">
          			<%=dbOP.loadCombo("catg_index","catg_name", " from bs_book_catg where is_valid = 1 order by catg_name desc", strCatg, false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Grade Level:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("classification");
						
					if(strCatg == null || strCatg.length() == 0 || strCatg.equals("0") || strCatg.equals("2"))//college or not selected
						strErrMsg = " where edu_level = 0 ";
					else
						strErrMsg = "";
				%>
				<label id="load_classification">
				<select name="classification">
					<option value="0">Not Applicable</option>
					<%=dbOP.loadCombo("g_level","level_name", " from bed_level_info "+strErrMsg, strTemp, false)%> 
				</select>
				</label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<%
				if(bolIsBookType)
					strTemp = "Book Title:";
				else
					strTemp = "Item Name:";
			%>
			<td><%=strTemp%></td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("book_title");
				%>
				<input type="text" name="book_title" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="256" value="<%=strTemp%>"/></td>
		</tr>
	<%if(bolIsBookType){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Author:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(7);
					else
						strTemp = WI.fillTextValue("author");
				%>
				<input type="text" name="author" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="128" value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Publisher:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(8);
					else
						strTemp = WI.fillTextValue("publisher");
				%>
				<select name="publisher">
          			<option value="">Select Publisher</option>
          			<%=dbOP.loadCombo("publisher_index","publisher_name", " from bs_book_publisher where is_valid = 1 order by publisher_name ", strTemp, false)%> 
        		</select>
				&nbsp;&nbsp;
				<a href="javascript:UpdatePublisher();"><img src="../../images/update.gif" border="0" /></a>
		  		<font size="1">Click to update publisher</font></td>
		</tr>
	<%}%>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Price: </td>
		    <td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(12);
						strTemp = CommonUtil.formatFloat(strTemp, false);
						strTemp = ConversionTable.replaceString(strTemp, ",", "");
					}
					else
						strTemp = WI.fillTextValue("price");
				%>
	  	  		<input type="text" name="price" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onblur="AllowOnlyFloat('form_','price');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','price')" size="16" maxlength="64" 
					value="<%=strTemp%>"/> <strong>(in Php)</strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Alert Level: </td>
		    <td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(13);
					else
						strTemp = WI.fillTextValue("alert_level");
				%>
				<input type="text" name="alert_level" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onblur="AllowOnlyFloat('form_','alert_level');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','alert_level')" size="16" maxlength="64" 
					value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Item Code: </td>
		    <td>
				<%
					if (vEditInfo != null && vEditInfo.size()>0)
						strTemp = (String)vEditInfo.elementAt(10);
					else		
						strTemp = WI.fillTextValue("item_code");
				%>	
				<input name="item_code" type="text" class="textbox" value="<%=strTemp%>" maxlength="16"
					size="16" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'>
				<%
					if(WI.fillTextValue("auto_gen").length() > 0)
						strTemp = " checked";				
					else
						strTemp = "";
				%>
				<input name="auto_gen" type="checkbox" value="1"<%=strTemp%>>
				<font size="1">Auto-generate</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		  	<td>
				<%if(iAccessLevel > 1){
					if(strPrepareToEdit.equals("0")) {%>
						<a href="javascript:PageAction('1', '');"><img src="../../images/save.gif" border="0"></a>
						<font size="1">Click to save book entry.</font>
					<%}else {
						if(vEditInfo!=null){%>
							<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
								<img src="../../images/edit.gif" border="0"></a>
							<font size="1">Click to edit book entry.</font>
						<%}
					}%>
					<a href="javascript:RefreshPage();"><img src="../../images/refresh.gif" border="0"></a>
					<font size="1">Click to refresh page.</font>
				<%}else{%>
					Not authorized to save book entry information.
				<%}%></td>
		</tr>
		<tr>
		  <td height="25" colspan="2">&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
	<%}%>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder"><tr><td align="center">
		<table width="90%" cellpadding="0" cellspacing="0" border="0" bgcolor="#CCCCCC" class="thinborder">
			<tr> 
				<td height="20" colspan="5" bgcolor="#CCCCCC" class="thinborder"> <strong>Search Condition</strong> </td>
			</tr>
			<tr>
			  <td class="thinborder" width="10%">Type </td>
			  <td class="thinborder" width="30%"><select name="search_book_type" style="font-size:11px;">
					  <option value=""></option>
					  <%=dbOP.loadCombo("type_index","type_name", " from bs_book_type where is_valid = 1 order by type_name ", WI.fillTextValue("search_book_type"), false)%>
					</select>
					</td>
			  <td class="thinborder" width="10%">Book Category </td>
			  <td height="20" class="thinborder" width="30%">
				<select name="search_book_catg" style="font-size:11px;">
					  <option value=""></option>
						<%=dbOP.loadCombo("catg_index","catg_name", " from bs_book_catg where is_valid = 1 order by catg_name desc", WI.fillTextValue("search_book_catg"), false)%> 
				</select>
			  </td>
			  <td class="thinborder" width="20%"><input type="submit" name="_s" value="Filter Search" onclick="document.form_.page_action.value=''"></td>
		  </tr>
		</table>
	</td></tr></table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>:::  BOOK ENTRY LISTING ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
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
			<td width="17%" align="center" class="thinborder"><strong>Book Title </strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="9%" align="center" class="thinborder"><strong>Avail. Qty.</strong></td>
			<td width="9%" align="center" class="thinborder"><strong>Price</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Item Code </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=14, iCount++){
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7))%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9))%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+11)%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+12), true)%>&nbsp;</td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+10)%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../images/delete.gif" border="0"></a>
					<%}%>
					<br />
					<a href="javascript:UpdateSubjects('<%=(String)vRetResult.elementAt(i)%>', '<%=(String)vRetResult.elementAt(i+3)%>');">
						<img src="../../images/update.gif" border="0" /></a>
				<%}else{%>
					Not authorized.
				<%}%></td>
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
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>