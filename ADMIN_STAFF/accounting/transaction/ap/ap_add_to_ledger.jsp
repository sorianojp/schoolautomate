<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript">
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}

var objCOA;
function MapCOAAjax(strCoaFieldName, strParticularFieldName) {
		objCOA=document.getElementById(strParticularFieldName);
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var objCOAInput;
		eval('objCOAInput=document.form_.'+strCoaFieldName);
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name="+strCoaFieldName;
		//this.processRequest(strURL);
		this.processRequestPOST("../../../../Ajax/AjaxInterface.jsp","methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name="+strCoaFieldName);
}
function COASelected(strAccountName, objParticular) {
	objCOA.innerHTML = "<b>"+strAccountName+"</b>";
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*, purchasing.Delivery, Accounting.AccountPayable, 
																 java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-ACCOUNTING-TRANSACTION-AP-AP PROCESSING","ap_add_to_ledger.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Delivery DEL = new Delivery();	
	AccountPayable AP = new AccountPayable();
	
	Vector vItemInfo = null;
	Vector vRetResult = null;
	
	String strPageAction = WI.fillTextValue("page_action");

	if(strPageAction.length() > 0) {
		if(AP.operateOnProcessAP(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg = AP.getErrMsg();
		else {
			if(strPageAction.compareTo("1") == 0)
				strErrMsg = "AP successfully posted.";
			if(strPageAction.compareTo("2") == 0)
				strErrMsg = "AP successfully edited.";
			if(strPageAction.compareTo("0") == 0)
				strErrMsg = "AP successfully removed.";
		}
	}
	request.setAttribute("item_delivery_ref", WI.fillTextValue("item_delivery_ref"));
	vItemInfo = DEL.viewDeliveries(dbOP, request);
	vRetResult = AP.operateOnProcessAP(dbOP, request, 3);	
	
	boolean bolReturn = false;
	if(vItemInfo == null) {
		strErrMsg = DEL.getErrMsg();
		bolReturn = true;
		dbOP.cleanUP();
	}


%>
<form name="form_" method="post" action="ap_add_to_ledger.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
	  <strong>:::: ACCOUNTS PAYABLE   - POSTING TO SUBSIDIARY LEDGER PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="7%" height="25"><a href="ap_deliveries.jsp?show_processed=<%=WI.fillTextValue("show_processed")%>"><img src="../../../../images/go_back.gif" border="0"></a></td>
      <td width="93%" style="font-size:14px; font-weight:bold; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%
if(bolReturn)
	return;
boolean bolEditAllowed = false;
if( ((String)vItemInfo.elementAt(15)).equals("0.00"))
	bolEditAllowed = true;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="4%" height="25">&nbsp;</td>
    <td width="54%">Supplier Name : <%=vItemInfo.elementAt(0)%></td>
    <td width="42%">Delivery Date : <%=vItemInfo.elementAt(1)%></td>
    </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>Checked By :      <%=vItemInfo.elementAt(6)%></td>
    <td>Invoice # : <%=vItemInfo.elementAt(2)%></td>
    </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>Received By : <%=vItemInfo.elementAt(5)%></td>
    <td>PO # : <%=vItemInfo.elementAt(3)%></td>
    </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>Item Description : <%=vItemInfo.elementAt(18)%></td>
    <td>Item Quantity : <%=vItemInfo.elementAt(17)%></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>Total Delivered Amount : <%=CommonUtil.formatFloat((String)vItemInfo.elementAt(4), true)%></td>
<%
strTemp = WI.getStrValue(vItemInfo.elementAt(16));
if(strTemp.equals("0.00"))
	strTemp = CommonUtil.formatFloat((String)vItemInfo.elementAt(4), true);
%>
    <td>Amount payable after discount : <%=strTemp%></td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="4%">&nbsp;</td>
    <td width="11%">&nbsp;</td>
    <td width="31%">&nbsp;</td>
    <td width="11%">&nbsp;</td>
    <td width="43%">&nbsp;</td>
    </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>New Discount: </td>
    <td>
<%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String) vRetResult.elementAt(1);
else
	strTemp = WI.fillTextValue("ap_discount");
%>
	<input name="ap_discount" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" size="10" maxlength="10" style="text-align : right"
		 onBlur="AllowOnlyFloat('form_','ap_discount');style.backgroundColor='white'" 
		 onKeyUp="AllowOnlyFloat('form_','ap_discount');" value="<%=WI.getStrValue(strTemp,"0")%>">
<%
	if(vRetResult != null && vRetResult.size() > 1)
		strTemp = (String) vRetResult.elementAt(2);
	else
		strTemp = WI.fillTextValue("ap_discount_unit");
%>
      <select name="ap_discount_unit">
        <option value="0">%</option>
        <%			
			if(strTemp.compareTo("1") == 0) {%>
        <option value="1" selected>Specific Amount</option>
        <%}else{%>
        <option value="1">Specific Amount</option>
        <%}%>
      </select></td>
    <td height="25">Due date:</td>
        <td>
<%
	if(vRetResult != null && vRetResult.size() > 0)
		strTemp = (String) vRetResult.elementAt(7);
	else
		strTemp = WI.fillTextValue("due_date");
	if(strTemp == null || strTemp.length() == 0)
		strTemp = WI.getTodaysDate(1);
%>
          <input name="due_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <a href="javascript:show_calendar('form_.due_date');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../../images/calendar_new.gif" border="0"></a></td>
  </tr>
  
  <tr>
    <td height="25">&nbsp;</td>
    <td colspan="2">Reason for editing/deleting :</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
<%
	if(vRetResult != null && vRetResult.size() > 0)
		strTemp = (String) vRetResult.elementAt(6);
	else
		strTemp = WI.fillTextValue("edit_reason");
%>			
    <td colspan="2"><textarea name="edit_reason" cols="32" rows="3"><%=WI.getStrValue(strTemp)%></textarea></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>Lock Date </td>
    <td>
<%
String strLockDate = null;
	if(vRetResult != null && vRetResult.size() > 0) {
		strTemp = (String) vRetResult.elementAt(12);
		strLockDate = strTemp;
		
	}
	else
		strTemp = WI.fillTextValue("lock_date");
%>

        <input name="lock_date"  type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" 
			 size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','lock_date','/')"  
				onKeyUp="AllowOnlyIntegerExtn('form_','lock_date','/')">
        <a href="javascript:show_calendar('form_.lock_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>Debit Account</td>
    <td>
<%
	if(vRetResult != null && vRetResult.size() > 0)
		strTemp = (String) vRetResult.elementAt(10);
	else
		strTemp = WI.fillTextValue("debit_coa");
%>
	<input name="debit_coa" type="text" size="26" maxlength="32" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('debit_coa', 'coa_info_d');">
	  </td>
    <td>Credit Account </td>
    <td>
<%
	if(vRetResult != null && vRetResult.size() > 0)
		strTemp = (String) vRetResult.elementAt(11);
	else
		strTemp = WI.fillTextValue("credit_coa");
%>
	<input name="credit_coa" type="text" size="26" maxlength="32" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('credit_coa', 'coa_info_c');">
	  	</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><label id="coa_info_d" style="font-size:11px;"></label></td>
    <td>&nbsp;</td>
    <td><label id="coa_info_c" style="font-size:11px;"></label></td>
  </tr>
  <tr> 
    <td height="25" colspan="5" align="center" style="font-size:13px; color:#FF0000">
<%if(bolEditAllowed){%>
			<font style="font-size:9px; color:#000000">
			<% if(vRetResult == null || vRetResult.size() == 0) {%>
	      <a href='javascript:PageAction(1);'><img src="../../../../images/save.gif" border="0" name="hide_save"></a>click to SAVE TO SUPPLIER LEDGER
      <%}else{%>
<%if(strLockDate == null) {%>
				<a href='javascript:PageAction(2);'><img src="../../../../images/edit.gif" border="0"></a>click to EDIT entries
				<a href='javascript:PageAction(0);'><img src="../../../../images/delete.gif" border="0"></a>click to DELETE FROM LEDGER			
<%}%>
      <%}%>
			</font>			
<%}else{%>
	<b>Any modification not allowed because Account already paid. Please check Complete Ledger.</b>
<%}%>			</td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="17%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="is_edited" value="1">
  <%if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(0);
		else
			strTemp = "";
	%>
	<input type="hidden" name="info_index" value="<%=strTemp%>">	
	<input type="hidden" name="page_action">	
	<input type="hidden" name="gross_amt" value="<%=WI.fillTextValue("gross_amt")%>">
	<input type="hidden" name="show_processed" value="<%=WI.fillTextValue("show_processed")%>">
	
	<input type="hidden" name="item_delivery_ref" value="<%=WI.fillTextValue("item_delivery_ref")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>