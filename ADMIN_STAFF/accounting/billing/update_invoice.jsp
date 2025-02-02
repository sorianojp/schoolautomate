<%@ page language="java" import="utility.*, Accounting.billing.BillingTsuneishi, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsForwarded = WI.fillTextValue("is_forwarded").equals("1");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Update Invoice</title>
</head>

<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function GoBack(){
		location = "./create_invoice.jsp";
	}
	
	function ReloadPage(){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.print_page.value = "";
		document.form_.team_index.value = "";
		document.form_.activity_index.value = "";
		document.form_.ship_no.value = "";
		document.form_.quantity.value = "";
		document.form_.unit_index.value = "";
		document.form_.amount.value = "";
		document.form_.desc.value = "";
		document.form_.submit();
	}
	
	function UpdateActivities(){
		var pgLoc = "./invoice_activities.jsp?opner_form_name=form_";	
		var win=window.open(pgLoc,"UpdateActivities",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}

	function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
		var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
			"&table_list="+escape(tablelist)+
			"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
			"&opner_form_name=form_&opner_form_field="+strFormField;
		
		var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function RefreshPage(){
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}

	function AjaxMapInvoiceNo() {
		var strCustCode = document.form_.invoice_no.value;
		var objCOAInput = document.getElementById("coa_info");
		if(strCustCode.length < 3) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
			if(this.xmlHttp == null) {
				alert("Failed to init xmlHttp.");
				return;
			}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20001&invoice_no="+escape(strCustCode);
		this.processRequest(strURL);
	}

	function updateInvoiceNo(strInvoiceIndex, strInvoiceNo){
		document.form_.print_page.value = "";
		document.form_.invoice_no.value = strInvoiceNo;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.submit();
	}
	
	function GetInvoiceNo(){
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this invoice detail?'))
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
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./update_invoice_print.jsp" />
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
								"ACCOUNTING-BILLING","update_invoice.jsp");
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
	
	boolean bolIsPaid = false;
	int iSearchResult = 0;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vInvoiceInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vTemp = null;
	BillingTsuneishi billTsu = new BillingTsuneishi();
	
	if(WI.fillTextValue("invoice_no").length() > 0){
		vInvoiceInfo = billTsu.getInvoiceInfo(dbOP, request);
		if(vInvoiceInfo == null)
			strErrMsg = billTsu.getErrMsg();
		else{
			if((String)vInvoiceInfo.elementAt(14) != null)
				bolIsPaid = true;
			
			strTemp = WI.fillTextValue("page_action");
			if(strTemp.length() > 0){
				if(billTsu.operateOnInvoiceDtls(dbOP, request, Integer.parseInt(strTemp)) == null)
					strErrMsg = billTsu.getErrMsg();
				else{
					if(strTemp.equals("0"))
						strErrMsg = "Invoice detail successfully removed.";
					if(strTemp.equals("1"))
						strErrMsg = "Invoice detail successfully recorded.";
					if(strTemp.equals("2"))
						strErrMsg = "Invoice detail successfully edited.";
					
					strPrepareToEdit = "0";
				}
			}
			
			vRetResult = billTsu.getInvoiceDetails(dbOP, request, (String)vInvoiceInfo.elementAt(0));
		
			if(strPrepareToEdit.equals("1")){
				vEditInfo = billTsu.operateOnInvoiceDtls(dbOP, request, 3);
				if(vEditInfo == null)
					strErrMsg = billTsu.getErrMsg();
			}
		}
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./update_invoice.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: INVOICE PARTICULARS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		    <td align="right">
				<%if(bolIsForwarded){%>
					<a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0" /></a>
				<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Invoice No: </td>
			<td>
				<%if(!bolIsForwarded){%>
				<input name="invoice_no" type="text" size="16" value="<%=WI.fillTextValue("invoice_no")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapInvoiceNo();">
				<%}else{%>
					<input type="hidden" name="invoice_no" value="<%=WI.fillTextValue("invoice_no")%>" />
					<strong><font size="3" color="#FF0000"><%=WI.fillTextValue("invoice_no")%></font></strong>
				<%}%></td>
			<td colspan="2" valign="top"><label id="coa_info" style="position:absolute; width:300px"></label></td>
		</tr>
		<tr>
			<td height="15" width="3%">&nbsp;</td>
		    <td width="17%">&nbsp;</td>
		    <td width="20%">&nbsp;</td>
		    <td width="45%">&nbsp;</td>
		    <td width="15%">&nbsp;</td>
		</tr>
		<%if(!bolIsForwarded){%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="3">
				<a href="javascript:GetInvoiceNo();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to view invoice details. </font></td>
	    </tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
		<%}%>
	</table>
	
<%if(vInvoiceInfo != null && vInvoiceInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="5"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="17%">Invoice No: </td>
		    <td width="30%"><%=(String)vInvoiceInfo.elementAt(3)%></td>
		    <td width="17%">Invoice Category: </td>
		    <td width="33%"><%=(String)vInvoiceInfo.elementAt(1)%></td>
			<input type="hidden" name="invoice_index" value="<%=(String)vInvoiceInfo.elementAt(0)%>" />
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Invoice Date: </td>
		    <td><%=(String)vInvoiceInfo.elementAt(2)%></td>
		    <td>Terms:</td>
		    <td><%=(String)vInvoiceInfo.elementAt(6)%> days </td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Unit Price: </td>
		    <td><%=(String)vInvoiceInfo.elementAt(7)%></td>
		    <td>Currency:</td>
		    <td><%=WI.getStrValue((String)vInvoiceInfo.elementAt(8), "Php")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Charge To: </td>
		    <td colspan="3"><%=(String)vInvoiceInfo.elementAt(4)%></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Address:</td>
		    <td colspan="3"><%=(String)vInvoiceInfo.elementAt(5)%></td>
	    </tr>
		<tr>
			<td height="15" colspan="5"><hr size="1" /></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="17%">Team: </td>
		    <td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("team_index");
				%>
				<select name="team_index">
          			<option value="">Select Team</option>
          			<%=dbOP.loadCombo("team_index","team_name", " from ac_tun_team where is_valid = 1", strTemp,false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Sales Activity:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(7);
					else
						strTemp = WI.fillTextValue("activity_index");
				%>
				<select name="activity_index">
					<option value="">Select Activity</option>
					<%=dbOP.loadCombo("activity_index","activity_code"," from ac_tun_sales_activity where is_valid = 1 ",strTemp,false)%>
				</select>
				&nbsp;
				<a href="javascript:UpdateActivities();"><img src="../../../images/update.gif" border="0"></a>
		  		<font size="1">Click to update list of sales activities.</font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Ship No:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("ship_no");
				%>
		  		<input type="text" name="ship_no" value="<%=strTemp%>" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					size="24" maxlength="24"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Quantity:</td>
			<td>
				<%
					if (vEditInfo != null && vEditInfo.size()>0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(1), "");
					else		
						strTemp = WI.fillTextValue("quantity");
				%>
				<input name="quantity" type="text" class="textbox" value="<%=strTemp%>" size="10" maxlength="12"
					onkeyup="AllowOnlyInteger('form_','quantity')" onfocus="style.backgroundColor='#D3EBFF'"
					onblur="AllowOnlyInteger('form_','quantity');style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Unit:</td>
			<td>
				<%
					if (vEditInfo != null && vEditInfo.size()>0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(2), "");
					else		
						strTemp = WI.fillTextValue("unit_index");
				%>
				<select name="unit_index">
          			<option value="">Select Unit</option>
          			<%=dbOP.loadCombo("unit_index","unit_name", " from pur_preload_unit order by unit_name", strTemp,false)%> 
        		</select>
				&nbsp;
				<a href='javascript:viewList("PUR_PRELOAD_UNIT","UNIT_INDEX","UNIT_NAME","UNITS",
					"AC_TUN_INVOICE_DTLS","DTLS_INDEX", 
					" and AC_TUN_INVOICE_DTLS.is_valid = 1","","form_")'>
				<img src="../../../images/update.gif" border="0"></a>
				<font size="1">click to update list of units </font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Amount:</td>
			<td>
				<%
					if (vEditInfo != null && vEditInfo.size()>0)
						strTemp = (String)vEditInfo.elementAt(3);
					else		
						strTemp = WI.fillTextValue("amount");
						
					strTemp = CommonUtil.formatFloat(strTemp, true);
					strTemp = ConversionTable.replaceString(strTemp, ",", "");
					
					if(strTemp.equals("0"))
						strTemp = "";
				%>
				<input name="amount" type="text" class="textbox" value="<%=strTemp%>" size="10" maxlength="12"
					onkeyup="AllowOnlyFloat('form_','amount')" onfocus="style.backgroundColor='#D3EBFF'"
					onblur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Description:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.fillTextValue("desc");
				%>
		  		<input type="text" name="desc" value="<%=strTemp%>" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					size="64" maxlength="256"></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
			<%if(!bolIsPaid){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save invoice details.</font>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit invoice detail.</font>
					<%}
				}%>
				<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0" /></a>
			<%}else{%>
				Save/edit operations not allowed. Invoice already paid.
			<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
				<font size="1">Click to print invoice details.</font>&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: INVOICE DETAILS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="12%" align="center" class="thinborder"><strong>Quantity</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Unit</strong></td>
			<td width="27%" align="center" class="thinborder"><strong>Description</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Activity</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Unit Price</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
		<%	for(int i = 0; i < vRetResult.size(); i+=3){
				vTemp = (Vector)vRetResult.elementAt(i+2);
		%>
		<tr>
			<td height="30" class="thinborderLEFT">&nbsp;</td>
		    <td class="thinborderLEFT">&nbsp;</td>
		    <td class="thinborderLEFT"><font size="2"><%=(String)vRetResult.elementAt(i+1)%></font></td>
		    <td class="thinborderLEFT">&nbsp;</td>
		    <td class="thinborderLEFT">&nbsp;</td>
		    <td class="thinborderLEFT">&nbsp;</td>
		    <td class="thinborderLEFT">&nbsp;</td>
		</tr>
		<%for(int j = 0; j < vTemp.size(); j+=7){%>
		<tr>
			<td height="20" class="thinborderLEFT"><%=WI.getStrValue((String)vTemp.elementAt(j+1), "&nbsp;")%></td>
		    <td class="thinborderLEFT"><%=WI.getStrValue((String)vTemp.elementAt(j+2), "&nbsp;")%></td>
		    <td class="thinborderLEFT"><%=(String)vTemp.elementAt(j+3)%> <%=(String)vTemp.elementAt(j+4)%></td>
		    <td class="thinborderLEFT"><%=WI.getStrValue((String)vTemp.elementAt(j+6), "&nbsp;")%></td>
		    <td class="thinborderLEFT">&nbsp;</td>
		    <td class="thinborderLEFT" align="right"><%=CommonUtil.formatFloat((String)vTemp.elementAt(j+5), true)%>&nbsp;&nbsp;</td>
		    <td align="center" class="thinborderLEFT">
			<%if(!bolIsPaid){//if not yet paid
				if(iAccessLevel > 1){%>					
					<a href="javascript:PrepareToEdit('<%=(String)vTemp.elementAt(j)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vTemp.elementAt(j)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
					<%}%>
				<%}else{%>
					Not authorized.
				<%}
			}else{%>
				Not allowed.
			<%}%></td>
		</tr>
		<%}}%>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="6" class="thinborderTOP">&nbsp;</td>
		</tr>
	</table>
	<%}
}%>	

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page" />
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
