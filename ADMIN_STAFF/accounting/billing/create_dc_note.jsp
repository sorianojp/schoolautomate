<%@ page language="java" import="utility.*, Accounting.TsuneishiDC, java.util.Vector"%>
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
<title>DC Note Management</title>
</head>

<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function updateDCNote(strDCNumber){
		location = "update_dc_note.jsp?is_forwarded=1&dc_number="+strDCNumber;
	}
	
	function UpdateCurrency(){
		var pgLoc = "./billing_currencies.jsp?opner_form_name=form_";	
		var win=window.open(pgLoc,"UpdateCurrency",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function UpdateChargeTo(){
		var pgLoc = "./invoice_chargeto.jsp?opner_form_name=form_";	
		var win=window.open(pgLoc,"UpdateChargeTo",'width=900,height=500,top=80,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this D/C note?'))
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
	
	function RefreshPage(){
		this.ReloadPage();
	}
	
	function CancelOperation() {
		location = "./create_dc_note.jsp";
	}
	
	function ReloadPage(){
		document.form_.info_index.value = "";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";		
		document.form_.submit();
	}
	
	function getBillIndex(){
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
								"ACCOUNTING-BILLING","create_dc_note.jsp");
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
	Vector vEditInfo  = null; 
	Vector vRetResult = null;
	boolean bolIsPaid = false;
	int i = 0;
	int iSearchResult = 0;
	
	TsuneishiDC dc = new TsuneishiDC();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(dc.operateOnDCNote(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = dc.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "D/C note successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "D/C note successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "D/C note successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}

	if(strPrepareToEdit.equals("1")){
		vEditInfo = dc.operateOnDCNote(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = dc.getErrMsg();
	}
	
	vRetResult = dc.operateOnDCNote(dbOP, request, 4);
	if(vRetResult == null){
		if(WI.fillTextValue("page_action").length() == 0)
			strErrMsg = dc.getErrMsg();
	}
	else
		iSearchResult = dc.getSearchCount();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./create_dc_note.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: CREATE DEBIT/CREDIT NOTE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">D/C Note No.:</td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("dc_number");
				%>
		  		<input type="text" name="dc_number" value="<%=strTemp%>" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					size="32" maxlength="32"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>D/C Type:</td>
			<td>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("dc_type"),"0");
					if(vEditInfo != null && vEditInfo.size() > 0){
						strErrMsg = (String)vEditInfo.elementAt(1);
						if(strErrMsg.equals("1")){
							strTemp = "";
							strErrMsg = "checked";
						}
						else{
							strTemp = "checked";
							strErrMsg = "";
						}
					}
					else{
						if(strTemp.equals("0")){
							strTemp = "checked";
							strErrMsg = "";
						}else{
							strTemp = "";
							strErrMsg = "checked";
						}
					}
				%>
				<input type="radio" name="dc_type" value="0"<%=strTemp%>>Debit&nbsp;			
  		  		<input type="radio" name="dc_type" value="1"<%=strErrMsg%>>Credit</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>D/C Date:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("dc_date");
				%>
				<input name="dc_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.dc_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Charge To: </td>
	  	  	<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.fillTextValue("charge_to");
				%>
				<select name="charge_to">
          			<option value="">Select In-charge</option>
          			<%=dbOP.loadCombo("chargeto_index","chargeto_code + ' ' + chargeto_name", " from ac_tun_invoice_chargeto where is_valid = 1", strTemp,false)%> 
        		</select>
			  	&nbsp;
			  	<a href="javascript:UpdateChargeTo();"><img src="../../../images/update.gif" border="0"></a>
			  	<font size="1">Click to update list of in-charge </font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Currency: </td>
		  	<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
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
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="20%">&nbsp;</td>
			<td width="80%">
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save D/C info.</font>
				    <%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit D/C info.</font>
					    <%}
				}%>
				<a href="javascript:CancelOperation();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font>
			</td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: DEBIT/CREDIT NOTE LISTING ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="5">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(dc.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="2"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/dc.defSearchSize;		
				if(iSearchResult % dc.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+dc.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="ReloadPage();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						i = Integer.parseInt(strTemp);
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
			<td width="12%" align="center" class="thinborder"><strong>D/C No.</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>D/C Type </strong></td>
			<td width="12%" align="center" class="thinborder"><strong>D/C Date</strong></td>
			<td width="29%" align="center" class="thinborder"><strong>Charge To<br />(Address)</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Currency</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<% 	int iCount = 1;
		for(i = 0; i < vRetResult.size(); i+=11, iCount++){
			if((String)vRetResult.elementAt(i+9) == null)
				bolIsPaid = false;
			else
				bolIsPaid = true;
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+1);
				if(strTemp.equals("0"))
					strTemp = "Debit";
				else
					strTemp = "Credit";
			%>
			<td class="thinborder"><%=strTemp%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">
				<%=(String)vRetResult.elementAt(i+5)%><br />
				<%=(String)vRetResult.elementAt(i+10)%></td>
			<td class="thinborder">
				<%=(String)vRetResult.elementAt(i+8)%>&nbsp;
				(<%=(String)vRetResult.elementAt(i+7)%>)</td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){
					if(!bolIsPaid){%>					
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
					<%}%>
					<br />
					<a href="javascript:updateDCNote('<%=(String)vRetResult.elementAt(i+2)%>');">
						<img src="../../../images/update.gif" border="0" /></a>
					<%}else{%>
						Paid.
					<%}
				}else{%>
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
