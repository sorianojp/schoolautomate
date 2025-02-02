<%@ page language="java" import="utility.*,Accounting.SOAManagement,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Manage SOA</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function UpdateCategories(){
		var pgLoc = "../billing/invoice_categories.jsp?opner_form_name=form_";	
		var win=window.open(pgLoc,"UpdateCategories",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function UpdateActivities(){
		var pgLoc = "../billing/invoice_activities.jsp?opner_form_name=form_";	
		var win=window.open(pgLoc,"UpdateActivities",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function UpdateCurrency(){
		var pgLoc = "../billing/billing_currencies.jsp?opner_form_name=form_";	
		var win=window.open(pgLoc,"UpdateCurrency",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function UpdateChargeTo(){
		var pgLoc = "../billing/invoice_chargeto.jsp?opner_form_name=form_";	
		var win=window.open(pgLoc,"UpdateChargeTo",'width=900,height=500,top=80,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function UpdateAttentionList(){
		var pgLoc = "./SOA_attention_list.jsp?opner_form_name=form_";	
		var win=window.open(pgLoc,"UpdateAttentionList",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function UpdateAccounts(){
		var pgLoc = "./SOA_accounts.jsp?opner_form_name=form_";	
		var win=window.open(pgLoc,"UpdateAccounts",'width=850,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function loadAddress() {
		var objAddr=document.getElementById("load_addr");
 		var objChargeTo = document.form_.charge_to[document.form_.charge_to.selectedIndex].value;
		
		this.InitXmlHttpObject(objAddr, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20005&ref="+objChargeTo;
		this.processRequest(strURL);
	}
	
	function loadPosition(){
		var objAddr=document.getElementById("load_position");
 		var objAttention = document.form_.attention[document.form_.attention.selectedIndex].value;
		
		this.InitXmlHttpObject(objAddr, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20006&ref="+objAttention;
		this.processRequest(strURL);
	}
	
	function UpdateDetails(strSANum, strJumpTo){//WI.fillTextValue("jumpto")
		location = "SOA_details.jsp?is_forwarded=1&sa_num="+strSANum+"&jumpto="+strJumpTo;
	}
	
	function getBillIndex(){
		document.form_.submit();
	}
	
	function RefreshPage(){
		document.form_.submit();
	}
	
	function ReloadPage(){
		location = "./SOA_entries.jsp";
	}
	
	function FocusField(){
		document.form_.sa_num.focus();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this SOA?'))
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
	
	function loadDetails(){		
		var objTable = document.getElementById("table_reload");
		var objAccount = document.form_.account[document.form_.account.selectedIndex].value;
				
		this.InitXmlHttpObject(objTable, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20007&ref="+objAccount;
		this.processRequest(strURL);
		
		if(document.getElementById("table_id"))
			document.getElementById("table_id").style.display='none';
	}
	
	function PrintPg(strSANum, strTotal, strType){
		var amortization = "";
		if(strTotal == '0'){
			alert("No SOA details added.");
			return;
		}
		
		if(strType == '1')//salary
			location = "./SOA_print_salary.jsp?sa_num="+strSANum;
		else if(strType == '2')//technical support fee
			location = "./SOA_print_technical.jsp?sa_num="+strSANum;
		else{//Preparation Loan
			amortization = prompt("Amortization: ", "");
			location = "./SOA_print_loan.jsp?sa_num="+strSANum+"&amortization="+amortization;
		}
	}
	
</script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BUDGET"),"0"));
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
								"ACCOUNTING-BUDGET","SOA_entries.jsp");
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String[] astrDropListEqual = {"Starts With","Ends With", "Contains", "Equals"};
	String[] astrDropListValEqual = {"starts","ends","contains","equals"};
	String[] astrSortByName = {"S/A Number","SOA Date"};
	String[] astrSortByVal = {"sa_number","sa_date"};
	Vector vEditInfo  = null; 
	Vector vRetResult = null;
	boolean bolIsPaid = false;
	int iSearchResult = 0;
	SOAManagement soa = new SOAManagement();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(soa.operateOnSOAEntry(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = soa.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "SOA successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "SOA successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "SOA successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = soa.operateOnSOAEntry(dbOP, request, 4);
	if(vRetResult == null){
		if(WI.fillTextValue("page_action").length() == 0)
			strErrMsg = soa.getErrMsg();
	}
	else
		iSearchResult = soa.getSearchCount();
	
	if(strPrepareToEdit.equals("1")){
		vEditInfo = soa.operateOnSOAEntry(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = soa.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" action="./SOA_entries.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SOA MANAGEMENT PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font color="#FF0000" size="2"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">S/A No:</td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("sa_num");
				%>
				<input type="text" name="sa_num" value="<%=strTemp%>" class="textbox" size="16" maxlength="16"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("sa_date");
				%>
				<input name="sa_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.sa_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>S/A Type: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("sa_type");
				%>
				<select name="sa_type">
          			<option value="">Select Type</option>
				<%if (strTemp.equals("1")){%>
					<option value="1" selected>Salary</option>
				<%}else{%>
					<option value="1">Salary</option>
					
				<%}if (strTemp.equals("2")){%>
					<option value="2" selected>Technical Support Fee</option>
				<%}else{%>
					<option value="2">Technical Support Fee</option>
				
				<%}if (strTemp.equals("3")){%>
					<option value="3" selected>Preparation Loan</option>
				<%}else{%>
					<option value="3">Preparation Loan</option>
				<%}%>				
        		</select>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Sales Category: </td>
		  <td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(19);
					else
						strTemp = WI.fillTextValue("catg_index");
				%>
				<select name="catg_index">
          			<option value="">Select Category</option>
          			<%=dbOP.loadCombo("catg_index","catg_code + ' ' + catg_name", " from ac_tun_invoice_catg where is_valid = 1", strTemp,false)%> 
        		</select>
			  &nbsp;
			  <a href="javascript:UpdateCategories();"><img src="../../../images/update.gif" border="0"></a>
	  		  <font size="1">Click to update categories</font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Sales Activity:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(16);
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
			<td>Currency: </td>
		  	<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(13);
					else
						strTemp = WI.fillTextValue("currency");
				%>
				<select name="currency">
          			<option value="">Select currency</option>
          			<%=dbOP.loadCombo("currency_index","currency_code + '(' + currency_name + ')'", " from currency where is_valid = 1", strTemp,false)%> 
        		</select>
				&nbsp;
				<a href="javascript:UpdateCurrency();"><img src="../../../images/update.gif" border="0"></a>
				<font size="1">Click to update list of  currencies.</font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Charge to: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("charge_to");
				%>
				<select name="charge_to" onChange="loadAddress();">
          			<option value="">Select In-charge</option>
          			<%=dbOP.loadCombo("chargeto_index","chargeto_code + ' ' + chargeto_name", " from ac_tun_invoice_chargeto where is_valid = 1", strTemp,false)%> 
        		</select>
			  	&nbsp;
			  	<a href="javascript:UpdateChargeTo();"><img src="../../../images/update.gif" border="0"></a>
			  	<font size="1">Click to update list of in-charge</font>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Address:</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(22);
				else{
					strTemp = WI.fillTextValue("charge_to");
					if(strTemp.length() > 0){
						strTemp = " select address from ac_tun_invoice_chargeto where is_valid = 1 and chargeto_index = "+strTemp;
						strTemp = dbOP.getResultOfAQuery(strTemp, 0);
					}
					else
						strTemp = "";
				}
			%>
			<td><label id="load_addr"><%=strTemp%></label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Attention:</td>
		  	<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(7);
					else
						strTemp = WI.fillTextValue("attention");
				%>
				<select name="attention" onChange="loadPosition();">
          			<option value="">Select Attention</option>
          			<%=dbOP.loadCombo("attention_index","attention_name", " from ac_sa_attention_list where is_valid = 1", strTemp,false)%> 
        		</select>
			  	&nbsp;
			  	<a href="javascript:UpdateAttentionList();"><img src="../../../images/update.gif" border="0"></a>
			  	<font size="1">Click to update attention list</font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Position:</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(9);
				else{
					strTemp = WI.fillTextValue("attention");
					if(strTemp.length() > 0){
						strTemp = " select position from ac_sa_attention_list where is_valid = 1 and attention_index= "+strTemp;
						strTemp = dbOP.getResultOfAQuery(strTemp, 0);
					}
					else
						strTemp = "";
				}
			%>
			<td><label id="load_position"><%=strTemp%></label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><strong><u>Deposit Acct Detail </u></strong></td>
			<td></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Name: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(10);
					else
						strTemp = WI.fillTextValue("account");
				%>
				<select name="account" onChange="loadDetails();">
          			<option value="">Select Account</option>
          			<%=dbOP.loadCombo("account_index","account_name", " from ac_sa_account where is_valid = 1", strTemp,false)%> 
        		</select>
			  	&nbsp;
			  	<a href="javascript:UpdateAccounts();"><img src="../../../images/update.gif" border="0"></a>
			  	<font size="1">Click to update accounts</font></td>
		</tr>
	</table>

	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(12);
			strErrMsg = (String)vEditInfo.elementAt(23) + " - " + (String)vEditInfo.elementAt(24);
		}
		else{
			strTemp = "";
			strErrMsg = "";
			
			strTemp = WI.fillTextValue("account");
			if(strTemp.length() > 0){
				strTemp = " select account_no from ac_sa_account where is_valid = 1 and account_index = "+strTemp;
				strTemp = dbOP.getResultOfAQuery(strTemp, 0);
				
				strErrMsg = 
					" select bank_code + ' - ' + branch from ac_sa_account "+
					" join fa_bank_list on (ac_sa_account.bank_index = fa_bank_list.bank_index) "+
					" where ac_sa_account.is_valid = 1 and account_index = "+WI.fillTextValue("account");
				strErrMsg = dbOP.getResultOfAQuery(strErrMsg, 0);
			}
			else{
				strTemp = "";
				strErrMsg = "";
			}
		}
		%>
<label id="table_reload">
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0" id="table_id">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Account No: </td>
			<td width="80%"><%=strTemp%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bank:</td>
			<td><%=strErrMsg%></td>
		</tr>
	</table>
</label>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="20%">&nbsp;</td>
			<td>
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save SOA</font>
				    <%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit SOA</font>
					    <%}
				}%>
				<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<%
				String strChecked = "";
				if(WI.fillTextValue("show_view_options").length() > 0)
					strChecked = " checked";
			%>
			<td height="25" colspan="2">
				<input type="checkbox" name="show_view_options" value="1" <%=strChecked%> 
					onclick="javascript:RefreshPage();">Show View Options</td>
		</tr>
	</table>
	
<%if(WI.fillTextValue("show_view_options").length() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
      		<td height="25">&nbsp;</td>
      		<td>S/A No. </td>
      		<td colspan="2">
				<select name="soa_num_con">
       				<%=soa.constructGenericDropList(WI.fillTextValue("soa_num_con"),astrDropListEqual,astrDropListValEqual)%>
      			</select>
							
        		<input type="text" name="soa_num" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" size="32" maxlength="64" 
					value="<%=WI.fillTextValue("soa_num")%>" /></td>
      	</tr>
    	<tr> 
      		<td height="25" width="3%">&nbsp;</td>
      		<td width="17%">Sort By: </td>
      		<td width="20%">
				<select name="sort_by1">
        			<option value="">N/A</option>
					<%=soa.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      			</select></td>
      		<td width="60%">
				<select name="sort_by2">
        			<option value="">N/A</option>
					<%=soa.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>      
				</select></td>
      	</tr>
    	<tr> 
      		<td height="25">&nbsp;</td>
      		<td>&nbsp;</td>
      		<td>
				<select name="sort_by1_con">
       				<option value="asc">Ascending</option>
        			<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
        				<option value="desc" selected>Descending</option>
        			<%}else{%>
        				<option value="desc">Descending</option>
        			<%}%>
      			</select></td>
   		  <td>
				<select name="sort_by2_con">
        			<option value="asc">Ascending</option>
        			<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
						<option value="desc" selected>Descending</option>
					<%}else{%>
						<option value="desc">Descending</option>
					<%}%>
				</select>
			  	&nbsp;
			  	<a href="javascript:RefreshPage();"><img src="../../../images/form_proceed.gif" border="0" /></a>
			  	<font size="1">Click to reload SOA listing. </font></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>
<%}
	
if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="8" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF CREATED SOA ENTRIES :::  </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="6"><strong>Total Results: <%=iSearchResult%> - 
				Showing(<%=WI.getStrValue(soa.getDisplayRange(), ""+iSearchResult)%>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="2"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/soa.defSearchSize;		
				if(iSearchResult % soa.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+soa.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="RefreshPage();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
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
				<%}%></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count </strong></td>
			<td width="11%" align="center" class="thinborder"><strong>S/A No. </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Date</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Type/<br>Currency</strong></td>
			<td width="8%"  align="center" class="thinborder"><strong>Charge to</strong></td>
			<td width="18%" align="center" class="thinborder"><strong>Attention</strong></td>
			<td width="19%" align="center" class="thinborder"><strong>Account</strong></td>
			<td width="19%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 27, iCount++){
			if((String)vRetResult.elementAt(i+26) == null)
				bolIsPaid = false;
			else
				bolIsPaid = true;
	%>	
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">
				<%
					strTemp = (String)vRetResult.elementAt(i+3);
					if(strTemp.equals("1"))
						strTemp = "Salary";
					else if(strTemp.equals("2"))
						strTemp = "Technical Support Fee";
					else
						strTemp = "Preparation Loan";
				%>
				<%=strTemp%>/<br>
				<%=(String)vRetResult.elementAt(i+14)%> (<%=(String)vRetResult.elementAt(i+15)%>)</td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder">
				<%=(String)vRetResult.elementAt(i+8)%><br>
				<%=(String)vRetResult.elementAt(i+9)%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i+4), "<br>", "", "")%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+11)%><br><%=(String)vRetResult.elementAt(i+12)%></td>
			<td align="center" class="thinborder">
				<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+25), false);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");
				strErrMsg = (String)vRetResult.elementAt(i+3);
				if(iAccessLevel > 1){
					if(!bolIsPaid){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
					<%}%><br>					
					<a href="javascript:UpdateDetails('<%=(String)vRetResult.elementAt(i+1)%>', '<%=WI.getStrValue(WI.fillTextValue("jumpto"), "1")%>');">
						<img src="../../../images/update.gif" border="0"></a>
					<%}%>
					<a href="javascript:PrintPg('<%=(String)vRetResult.elementAt(i+1)%>', '<%=strTemp%>', '<%=strErrMsg%>');">
						<img src="../../../images/print.gif" border="0"></a>
				<%}else{%>
					Not authorized.
				<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
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