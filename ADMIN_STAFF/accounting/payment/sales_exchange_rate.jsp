<%@ page language="java" import="utility.*, Accounting.SalesPayment, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Check Banks</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
	function ReloadPage(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.submit();
	}
	
	//called for add or edit and delete.
	function CancelOperation(){
		document.form_.donot_call_close_wnd.value = "1";
		location = "./sales_exchange_rate.jsp";
	}
	
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0" && document.form_.is_forwarded.value == "1") 
			window.opener.ReloadPage();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this forex information?'))
				return;
		}
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
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
	else{
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
			"ACCOUNTING-BILLING","sales_exchange_rate.jsp");
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
	
	String[] astrSortByName = {"Curreny Name","Date"};
	String[] astrSortByVal = {"currency_name","date"};
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo  = null; 
	Vector vRetResult = null;
	int iSearchResult = 0;
	
	SalesPayment payment  = new SalesPayment();
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0) {
		if(payment.operateOnExchangeRate(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = payment.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Exchange rate successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Exchange rate successfully added.";
			if(strTemp.equals("2"))
				strErrMsg = "Exchange rate successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}
	

	vRetResult = payment.operateOnExchangeRate(dbOP, request,4);
	if(vRetResult == null){
		if(WI.fillTextValue("page_action").length() == 0)
			strErrMsg = payment.getErrMsg();
	}
	else
		iSearchResult = payment.getSearchCount();
		
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = payment.operateOnExchangeRate(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = payment.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<form name="form_" method="post" action="sales_exchange_rate.jsp">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="5" bgcolor="#A49A6A" align="center">
				<div align="center"><font color="#FFFFFF"><strong>::: FOREIGN EXCHANGE MANAGEMENT :::</strong></font></div></td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Currency:</td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("currency");
						
					strErrMsg = " from currency where is_valid = 1 and is_local = 0 order by currency_name ";
				%>
				<select name="currency">
					<option value="">Select currency</option>
					<%=dbOP.loadCombo("currency_index","currency_name", strErrMsg, strTemp, false)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Exchange Rate: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(4);
						strTemp = CommonUtil.formatFloat(strTemp, false);
						strTemp = ConversionTable.replaceString(strTemp, ",", "");
					}
					else
						strTemp = WI.fillTextValue("exchange_rate");
				%>
				<input name="exchange_rate" type="text" class="textbox" value="<%=strTemp%>" size="12" maxlength="12"
					onkeyup="AllowOnlyFloat('form_','exchange_rate')" onFocus="style.backgroundColor='#D3EBFF'"
					onblur="AllowOnlyFloat('form_','exchange_rate');style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("date");
				%>
				<input name="date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
					<img src="../../../images/calendar_new.gif" border="0"></a></td>
	  	</tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
			<td valign="middle">
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
							<img src="../../../images/edit.gif" border="0"></a>
					<%}
				}%>
				
				<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a>
			<%}else{%>
				Not authorized to save forex information.
			    <%}%></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="47%"><strong><u>View Options</u></strong></td>		    
		    <td width="50%"><strong><u>Sort Options</u></strong></td>
		</tr>
		<tr>
			<td colspan="2" valign="top">				
				<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">						
					<tr>
						<td width="6%" height="25">&nbsp;</td>
						<td width="34%">Currency</td>		
					  	<td width="60%"><select name="cur_option">
                        	<option value="">Select currency</option>
                        	<%=dbOP.loadCombo("currency_index","currency_name"," from currency where is_valid = 1 and is_local = 0 " +
												"order by currency_name", WI.fillTextValue("cur_option"), false)%>
                      		</select></td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<td>Date: </td>
						<td>
							<input name="date_option" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_option")%>" 
								class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
							&nbsp; 
							<a href="javascript:show_calendar('form_.date_option');" title="Click to select date" 
								onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
								<img src="../../../images/calendar_new.gif" border="0"></a></td>
					</tr>
				</table></td>
			<td valign="top">
				<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
					<tr> 
						<td height="25" width="40%">
							<select name="sort_by1">
								<option value="">N/A</option>
								<%=payment.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
							</select></td>
						<td width="60%">
							<select name="sort_by2">
								<option value="">N/A</option>
								<%=payment.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
							</select></td>
				    </tr>
					<tr> 
						<td height="25">
							<select name="sort_by1_con">
								<option value="asc">Ascending</option>
							<% if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
								<option value="desc" selected>Descending</option>
							<%}else{%>
								<option value="desc">Descending</option>
							<%}%>
						</select></td>
					<td>
						<select name="sort_by2_con">
							<option value="asc">Ascending</option>
						<% if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
							<option value="desc" selected>Descending</option>
						<%}else{%>
							<option value="desc">Descending</option>
						<%}%>
						</select></td>
				    </tr>
				</table></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="40" width="20%">&nbsp;</td>
			<td width="80%" valign="middle">
				<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: EXCHANGE RATE LISTING ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="2"><strong>Total Results: <%=iSearchResult%> - 
				Showing(<%=WI.getStrValue(payment.getDisplayRange(), ""+iSearchResult)%>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="2"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/payment.defSearchSize;		
				if(iSearchResult % payment.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+payment.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="ReloadPage();">
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
				<%}%> </td>
		</tr>
		<tr style="font-weight:bold">
			<td height="25" class="thinborder" width="20%" align="center">Date</td>
			<td width="40%" class="thinborder" align="center">Currency</td>
			<td width="20%" class="thinborder" align="center">Exchange Rate </td>
			<td width="20%" align="center" class="thinborder">Operations</td>
		</tr>
	<%
		int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=6, iCount++){
	%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4), false)%></td>
			<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
				<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/delete.gif" border="0"></a>
				<%}
			}else{%>
				No edit/delete privilege.
			<%}%>
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
	
	<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">  	
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>