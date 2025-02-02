<%@ page language="java" import="utility.*, Accounting.invoice.CommercialInvoiceMgmt, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Search Invoice</title></head>

<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function ViewDetail(strInvoiceIndex){
		var pgLoc = "./view_invoice_info.jsp?invoice_index="+strInvoiceIndex;
		var win=window.open(pgLoc,"ViewDetail",'width=700,height=500,top=30,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

	function PrintPg(){		
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
	function SearchInvoice(){
		document.form_.print_page.value = "";
		document.form_.search_invoice.value = "1";
		document.form_.submit();
	}

	function ReloadPage(){
		document.form_.print_page.value = "";
		document.form_.search_invoice.value = "";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./search_invoice_print.jsp" />
		<% 
	return;}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
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
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","search_invoice.jsp");
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

	String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Invoice No","Invoice Date","Customer Name"};
	String[] astrSortByVal     = {"invoice_no","invoice_date","cust_name"};

	CommercialInvoiceMgmt cim = new CommercialInvoiceMgmt();
	Vector vRetResult = null;
	int iSearchResult = 0;
	int i = 0;
	
	if(WI.fillTextValue("search_invoice").length() > 0){
		vRetResult = cim.searchInvoice(dbOP, request);
		if(vRetResult == null)
			strErrMsg = cim.getErrMsg();
		else
			iSearchResult = cim.getSearchCount();
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./search_invoice.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SEARCH INVOICE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Invoice Date: </td>
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
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Invoice No:</td>
		    <td>
				<select name="invoice_no_con">
					<%=cim.constructGenericDropList(WI.fillTextValue("invoice_no_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
				<input type="text" name="invoice_no" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" size="32" maxlength="32" value="<%=WI.fillTextValue("invoice_no")%>">
				</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Customer Name:</td>
	      	<td>
				<select name="cust_name_con">
					<%=cim.constructGenericDropList(WI.fillTextValue("cust_name_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
				<input type="text" name="cust_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" size="32" maxlength="32" value="<%=WI.fillTextValue("cust_name")%>"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Destination:</td>
		    <td>
				<select name="destination_con">
					<%=cim.constructGenericDropList(WI.fillTextValue("destination_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
				<input type="text" name="destination" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" size="48" maxlength="128" value="<%=WI.fillTextValue("destination")%>"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Tin: </td>
		    <td>
				<select name="tin_con">
					<%=cim.constructGenericDropList(WI.fillTextValue("tin_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
				<input type="text" name="tin" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" size="48" maxlength="128" value="<%=WI.fillTextValue("tin")%>"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Business Name:</td>
		    <td>
				<select name="business_name_con">
					<%=cim.constructGenericDropList(WI.fillTextValue("business_name_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
				<input type="text" name="business_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" size="48" maxlength="128" value="<%=WI.fillTextValue("business_name")%>"></td>
		</tr>
		<tr>
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
					<%=cim.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="20%">
				<select name="sort_by2">
              		<option value="">N/A</option>
             		<%=cim.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="40%">
				<select name="sort_by3">
					<option value="">N/A</option>
              		<%=cim.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
			<td height="25" colspan="2">&nbsp;</td>
		    <td height="25" colspan="3">
			<%
				if(WI.fillTextValue("view_all").length() > 0)
					strTemp = " checked";				
				else
					strTemp = "";
			%>
			<input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();"> 
			View ALL</td>
	    </tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="4">
				<a href="javascript:SearchInvoice();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to search for  billing invoice..</font></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td align="right">
				<font size="2">Number of Rows Per Page :</font>
				<select name="num_rec_page">
				<% 
				int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
				for(i = 10; i <=40 ; i++) {
					if ( i == iDefault) {%>
						<option selected value="<%=i%>"><%=i%></option>
					<%}else{%>
						<option value="<%=i%>"><%=i%></option>
					<%}
				}%>
				</select>
				&nbsp;
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
				<font size="1">Click to print search results.</font>
			</td>
		</tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" bgcolor="#B9B292" colspan="7" class="thinborder">
				<div align="center"><strong>SEARCH RESULTS </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(cim.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="3"> &nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/cim.defSearchSize;		
				if(iSearchResult % cim.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+cim.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="SearchInvoice();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}
			}%></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
		    <td width="12%" align="center" class="thinborder"><strong>Invoice Date</strong></td>
		    <td width="14%" align="center" class="thinborder"><strong>Invoice No</strong></td>
			<td width="19%" align="center" class="thinborder"><strong>Customer</strong></td>
			<td width="28%" align="center" class="thinborder"><strong>Address</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>View</strong></td>
		</tr>
	<%	int iCount = 1;
		for(i = 0; i < vRetResult.size(); i+=15, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+13)%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+14), "0");
				strTemp = CommonUtil.formatFloat(strTemp, true);
			%>
			<td class="thinborder" align="right"><%=strTemp%>&nbsp;&nbsp;</td>
			<td class="thinborder" align="center">
				<a href="javascript:ViewDetail('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/view.gif" border="0" /></a></td>
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
	
	<input type="hidden" name="search_invoice" />
	<input type="hidden" name="print_page" />
	<input type="hidden" name="category_name" />
	<input type="hidden" name="invoice_no_name" />
	<input type="hidden" name="chargeto_name" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>