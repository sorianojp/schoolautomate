<%@ page language="java" import="utility.*, bookstore.BookPricing, java.util.Vector"%>
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
		document.form_.submit();
	}
	
	function checkAll() {
		var maxDisp = document.form_.total_count.value;
		var bolIsSelAll = document.form_.selAll.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function SavePrice(){
		document.form_.save_price.value = "1";
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
								"BOOKSTORE-BOOK MANAGEMENT","book_pricing.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-PRICE MANAGEMENT"),"0"));
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
	
	BookPricing bp = new BookPricing();
	
	if(WI.fillTextValue("save_price").length() > 0){
		if(!bp.changeBookPrice(dbOP, request))
			strErrMsg = bp.getErrMsg();
	}
	
	int iSearchResult = 0;
	Vector vRetResult = bp.getBooksForEditing(dbOP, request);
	if(vRetResult == null)
		strErrMsg = bp.getErrMsg();
	else
		iSearchResult = bp.getSearchCount();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./book_pricing.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SET PRICING OF BOOKS ::::</strong></font></div></td>
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
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="20%" height="25">&nbsp;</td>
			<td width="80%" colspan="3">
				<a href="javascript:SearchBooks();"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to book filter. </font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){
if(iAccessLevel > 1){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">
				<a href="javascript:SavePrice();"><img src="../../images/save.gif" border="0" /></a>
				<font size="1">Click to save book price.</font></td>
		</tr>
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
			<td width="10%" align="center" class="thinborder"><strong>Type</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Category</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Grade Level </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Item Code </strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Book Title </strong></td>
			<td width="13%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="13%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Price</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Select</strong><br />
				<input type="checkbox" name="selAll" value="0" onClick="checkAll();"></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=10, iCount++){
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7), "N/A")%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+8), false);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");
			%>
			<td class="thinborder" align="center">
				<input type="text" name="price_<%=iCount%>" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onblur="AllowOnlyFloat('form_','price_<%=iCount%>');style.backgroundColor='white';toggleSel(document.form_.price_<%=iCount%>, document.form_.save_<%=iCount%>)"
					onkeyup="AllowOnlyFloat('form_','price_<%=iCount%>')" size="12" maxlength="12" 
					value="<%=strTemp%>"/></td>
			<td class="thinborder" align="center">
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1"></td>
		</tr>
	<%}%>
	<input type="hidden" name="total_count" value="<%=iCount%>" />
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" align="center">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:SavePrice();"><img src="../../images/save.gif" border="0" /></a>
					<font size="1">Click to save book price.</font>
				<%}else{%>
					Not allowed to save book price.
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
	
	<input type="hidden" name="save_price" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>