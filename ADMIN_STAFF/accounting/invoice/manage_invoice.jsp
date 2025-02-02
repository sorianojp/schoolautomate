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
<title>Manage Invoice</title>
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this invoice?'))
				return;
		}
		
		document.form_.print_page.value = "";
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
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function CancelOperation(){
		location = "./manage_invoice.jsp";
	}
	
	function updateInvoice(strInvoiceNo){
		location = "update_invoice.jsp?is_forwarded=1&invoice_no="+strInvoiceNo;
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./manage_invoice_print.jsp" />
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
								"ACCOUNTING-BILLING","manage_invoice.jsp");
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
	
	String[] astrDropListEqual = {"Starts With","Ends With", "Contains"};
	String[] astrDropListValEqual = {"starts","ends","contains"};
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	int iSearchResult = 0;
	
	CommercialInvoiceMgmt cim = new CommercialInvoiceMgmt();	
	
	strTemp = WI.fillTextValue("page_action");	
	if(strTemp.length() > 0) {
		if(cim.operateOnInvoice(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = cim.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Invoice successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Invoice successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Invoice successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}

	vRetResult = cim.operateOnInvoice(dbOP, request,4);
	if(vRetResult != null)
		iSearchResult = cim.getSearchCount();
	else{
		if(strTemp.length() == 0)
			strErrMsg = cim.getErrMsg();
	}
	
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = cim.operateOnInvoice(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = cim.getErrMsg();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./manage_invoice.jsp" method="post">
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: MANAGE INVOICE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Customer:</td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("customer_index");
				%>
				<select name="customer_index">
          			<option value="">Select Customer</option>
          			<%=dbOP.loadCombo("customer_index","cust_name, cust_code", " from ac_fcac_customers where is_valid = 1 order by cust_name", strTemp, false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Invoice No:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.fillTextValue("invoice_no");
				%>
				<input type="text" name="invoice_no" value="<%=strTemp%>" class="textbox" size="16" maxlength="16"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("invoice_date");
					
					if(strTemp.length() == 0) 
						strTemp = WI.getTodaysDate(1);
				%>
				<input name="invoice_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.invoice_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Destination:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("destination");
				%>
		  		<input type="text" name="destination" value="<%=strTemp%>" class="textbox" size="32" maxlength="256"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Vessel:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(7));
					else
						strTemp = WI.fillTextValue("vessel");
				%>
		  		<input type="text" name="vessel" value="<%=strTemp%>" class="textbox" size="32" maxlength="128"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Voyage No :</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(8));
					else
						strTemp = WI.fillTextValue("voyage_no");
				%>
		  		<input type="text" name="voyage_no" value="<%=strTemp%>" class="textbox" size="32" maxlength="32"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>BL No :</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(9));
					else
						strTemp = WI.fillTextValue("bl_no");
				%>
		  		<input type="text" name="bl_no" value="<%=strTemp%>" class="textbox" size="32" maxlength="32"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Exchange Rate: </td>
		    <td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(11));
						if(strTemp.length() > 0){
							strTemp = CommonUtil.formatFloat(strTemp, false);
							strTemp = ConversionTable.replaceString(strTemp, ",", "");
						}
					}
					else
						strTemp = WI.fillTextValue("exchange_rate");
				%>
				<input type="text" name="exchange_rate" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
					onBlur="AllowOnlyFloat('form_','exchange_rate');style.backgroundColor='white'"
					onkeyup="AllowOnlyFloat('form_','exchange_rate')" size="10" maxlength="10" />
				<font size="1">Note: If exchange rate is not provided, invoice currency will be in peso.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(iAccessLevel > 1){
					if(vEditInfo != null && vEditInfo.size() > 0){%>
						<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');"><img src="../../../images/edit.gif" border="0" /></a>
					<font size="1">click to edit invoice </font>&nbsp; 
					<%}else{%>
						<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0" /></a>
						<font size="1">click to save info </font>&nbsp;			
					    <%}%>
					
					<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0" /></a>
					<font size="1">click to cancel/clear entries</font>
				<%}else{%>
					Not authorized to add invoice information.
				<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
				<font size="1">Click to print invoice list.</font>&nbsp;</td>
		</tr>
	</table>	
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="8" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>:::  INVOICE LISTING ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="5">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(cim.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="3"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/cim.defSearchSize;		
				if(iSearchResult % cim.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+cim.getDisplayRange()+")";
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
			<td width="20%" align="center" class="thinborder"><strong>Customer Name </strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Invoice Date </strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Invoice No. </strong></td>
			<td width="21%" align="center" class="thinborder"><strong>Destination</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Total Amount</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=12, iCount++){
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+10), "0");
				strTemp = CommonUtil.formatFloat(strTemp, true);
			%>
			<td class="thinborder" align="right"><%=strTemp%>&nbsp;&nbsp;</td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
					<%}%>
					<br />
					<a href="javascript:updateInvoice('<%=(String)vRetResult.elementAt(i+4)%>');">
						<img src="../../../images/update.gif" border="0" /></a>
				<%}else{%>
					Not authorized.
				<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page" />
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>