<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
function PageAction(strInfoIndex,strAction) {	
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this record.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
	document.form_.submit();
}
function EditInfo(strInfoIndex,strAPNumber) {	
	var win=window.open("./ap_deliveries_manual_encoding_edit.jsp?jv_number="+escape(strAPNumber)+"&info_index="+strInfoIndex,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
}
function ReloadPage() {	
	document.form_.page_action.value="";
	document.form_.submit()
}
//ajax to update payable amount and date posted.
function UpdateInfo(objInput, strAction, strInfoIndex){
	this.InitXmlHttpObject(objInput, 1);//I want to get value in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=501&page_action="+strAction+
	"&ref="+strInfoIndex+"&info="+objInput.value;
	this.processRequest(strURL);
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


function AddMore() {
	var iTotalDeb = document.form_.total_debit.value;
	++iTotalDeb;
	document.form_.total_debit.value = iTotalDeb;
	
	strNewDeb = "<input name='debit_coa"+iTotalDeb+"' type='text' size='26' class='textbox' onfocus='style.backgroundColor=\"#D3EBFF\"' onBlur='style.backgroundColor=\"white\"' "+
				"onkeyUP='MapCOAAjax(\"debit_coa"+iTotalDeb+"\", \"coa_info_dc\");'> Amount <input name='debit_coa_amt"+iTotalDeb+"' type='text' size='8' class='textbox' "+
				"onfocus='style.backgroundColor=\"#D3EBFF\"' onBlur='style.backgroundColor=\"white\";AllowOnlyFloat(\"form_\",\"debit_coa_amt"+iTotalDeb+"\"); "+
				"onKeyUp='AllowOnlyFloat(\"form_\",\"debit_coa_amt"+iTotalDeb+"\");'>";

	this.insRow(--iTotalDeb, 1, strNewDeb);
}
function SaveInformation() {
	var iTotDebit = document.form_.total_debit.value;
	if(document.form_.total_debit.value.length == 0) 
		iTotalDebit = 1; 
	
	var dCredit = document.form_.amt_payable.value;
	var dDebit  = 0; var dTempDebit;
	for(i = 0; i <= eval(iTotDebit); ++i)  {
		eval('dTempDebit = document.form_.debit_coa_amt'+i);
		if(!dTempDebit)
			continue;
		dDebit += eval(dTempDebit.value);
	}
	
	if(dDebit != dCredit) {
		alert("Debit and Credit does not match.");
		return;
	}
	
	
	
	document.form_.page_action.value='1';
	document.form_.info_index.value='';
	document.form_.submit();
}
function PrintPg(strAPNumber) {
	var win=window.open("../journal_voucher/print_ap_GENERIC.jsp?jv_number="+escape(strAPNumber)+"&is_cd=0&jv_type=12","PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	
}
function GoToBatchLock() {
	location = "./ap_deliveries_manual_encoding_batch_lock.jsp?show_open=1";
}
var iMaxLen = '';
function updateMaxLen() {
	var iMaxLen = document.form_.item_detail.value.length;
	iMaxLen = eval(document.form_.max_len_.value) - eval (iMaxLen);
	document.form_.max_len_ta.value = eval(iMaxLen);
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*, purchasing.Delivery, Accounting.AccountPayable, java.util.Vector" %>
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
								"Admin/staff-ACCOUNTING-TRANSACTION-AP-AP PROCESSING-Manual Encoding","ap_deliveries_manual_encoding.jsp");
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
	AccountPayable AP = new AccountPayable();
	Vector vRetResult = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(AP.operateOnProcessAPManualNew(dbOP, request, Integer.parseInt(strTemp)) == null) 
			strErrMsg = AP.getErrMsg();
		else	
			strErrMsg = "Operation Successful.";
	}
	vRetResult = AP.operateOnProcessAPManualNew(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = AP.getErrMsg();

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form name="form_" method="post" action="ap_deliveries_manual_encoding.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
	  <strong>:::: ACCOUNTS PAYABLE - DELIVERIES  PROCESSING PAGE - MANUAL ENCODING ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Supplier</td>
      <td width="67%" height="25">
  	  <select name="ap_info" style="font-size:11px">
		<%
		strTemp = " from AC_AP_BASIC_INFO where is_valid = 1 and supplier_index is not null order by PAYEE_CODE";
		%>
		<%=dbOP.loadCombo("AP_INFO_INDEX","PAYEE_CODE+' ('+PAYEE_NAME+')'",strTemp, WI.fillTextValue("ap_info"), false)%>   
	  </select>	  </td>
      <td width="17%" align="right">
	  <%if(!strSchCode.startsWith("CIT")){%>
	  	<a href="javascript:GoToBatchLock();">Go To Batch Lock</a>
	  <%}%>
	  </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Invoice Amount </td>
      <td height="25" colspan="2"><input name="amt_payable" type="text" size="16" maxlength="24" value="<%=WI.fillTextValue("amt_payable")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','amt_payable');" 
	  onKeyUp="AllowOnlyFloat('form_','amt_payable');"></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Date Posted </td>
      <td height="25" colspan="2">
<%
strTemp = WI.fillTextValue("date_posted");
if (strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_posted"  type= "text" class="textbox"  value="<%=strTemp%>" 
			 size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_posted','/')"  
				onKeyUp="AllowOnlyIntegerExtn('form_','date_posted','/')">
        <a href="javascript:show_calendar('form_.date_posted');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>	  </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Item Detail </td>
      <td height="25" colspan="2">
	  <textarea name="item_detail" cols="75" rows="3"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" class="textbox"
	   maxlength="<%if(strSchCode.startsWith("UPH")){%>1024<%}else{%>250<%}%>" onKeyUp="updateMaxLen();return isMaxLen(this)" style="font-size:11px;"><%=WI.fillTextValue("item_detail")%></textarea>
	  <font size="1" style="font-weight:bold">Max Length:
	  <input type="text" name="max_len_ta" value="<%if(strSchCode.startsWith("UPH")){%>1024<%}else{%>250<%}%>" size="4" class="textbox_noborder" style="font-size:9px;">
	  </font>
	  <input type="hidden" name="max_len_" value="<%if(strSchCode.startsWith("UPH")){%>1024<%}else{%>250<%}%>">
	  <!--<input value="<%//=WI.fillTextValue("item_detail")%>" name="item_detail" type="text" size="64" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >-->
	  </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Reference</td>
      <td height="25" colspan="2"><input value="<%=WI.fillTextValue("reference")%>" name="reference" type="text" size="64" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
    </tr>
<!--
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Debit Account </td>
      <td height="25">
	  <input name="debit_coa" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("debit_coa")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('debit_coa', 'coa_info_dc');">
	  </td>
    </tr>
-->
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Credit Account </td>
      <td height="25" colspan="2">
		<input name="credit_coa" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("credit_coa")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('credit_coa', 'coa_info_dc');">  	  </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td valign="top">Debit Account </td>
      <td height="25" colspan="2">
	  <table id="myADTable" cellpadding="0" cellspacing="0" border="0">
	  	<tr>
			<td>
			  <input name="debit_coa1" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("debit_coa1")%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			  onkeyUP="MapCOAAjax('debit_coa1', 'coa_info_dc');"> 
				Amount 
				<input name="debit_coa_amt1" type="text" size="8" maxlength="24" value="<%=WI.fillTextValue("debit_coa_amt1")%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','debit_coa_amt1');" 
			  onKeyUp="AllowOnlyFloat('form_','debit_coa_amt1');">
			  
			  &nbsp;&nbsp;&nbsp;
			  <a href="javascript:AddMore();">Add More</a>	  		</td>
		</tr>
	  </table>
	  <input type="hidden" name="total_debit" value="1">	  </td>
    </tr>
<%if(!strSchCode.startsWith("UPH")){%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Lock Date </td>
      <td height="25" colspan="2">
        <input name="lock_date"  type= "text" class="textbox"  value="<%=WI.fillTextValue("lock_date")%>" 
			 size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','lock_date','/')"  
				onKeyUp="AllowOnlyIntegerExtn('form_','lock_date','/')">
        <a href="javascript:show_calendar('form_.lock_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>  	  </td>
    </tr>
<%}%>
    <tr bgcolor="#FFFFFF">
      <td></td>
      <td></td>
      <td colspan="2"><label id="coa_info_dc" style="font-size:11px;"></label></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25" colspan="2">
	  <input type="button" name="1" value="&nbsp;&nbsp;Save Information&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="SaveInformation()">	  </td>
    </tr>
<!--
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Sort By: Supplier Date </td>
    </tr>
-->
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4" align="right" style="font-size:10px;">
<%if(strSchCode.startsWith("UPH")){%>
	  <input type="checkbox" value="checked" name="show_open" <%=WI.fillTextValue("show_open")%>> Show only vouchers not Locked
<%}%>
	  
	  <a href="javascript:ReloadPage();"><img src="../../../../images/refresh.gif" border="0"></a> Please click refresh to reload the page incase there are on spot editing.&nbsp;
	  <br>
	  <strong>NOTE :</strong> If Payable amount is changed, updated balance payable will not be shown in this page unless refresh is clicked.	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
  <tr>
    <td height="25" colspan="11" align="center" bgcolor="#B4C5D6" class="thinborderTOPLEFTRIGHT"><strong><font color="#000000">:: ENCODED DELIVERY INFORMATION :: </font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
  <tr> 
    <td width="18%" align="center"class="thinborder" style="font-size:9px; font-weight:bold">Supplier</td>
    <td width="8%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Posted Date</td>
    <td width="18%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Item Detail </td>
    <td width="10%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Reference</td>
    <td width="7%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Payable Amt</td>
    <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Balance Payable </td>
    <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">To be Processed Amt  </td>
    <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Charged To Account</td>
    <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Lock Date </td>
    <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Delete</td>
    <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Print AP </td>
    <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Voucher Number </td>
  </tr>
<%int iCount = 0; 
Vector vDCAccount = null;
for(int i = 0;i < vRetResult.size();i+=14,++iCount){
if(vRetResult.elementAt(i + 10) != null) {
	strErrMsg = " bgcolor='cccccc'";
	continue;
}
else	
	strErrMsg = "";
vDCAccount = null;
if(vRetResult.elementAt(i + 13) != null)
	vDCAccount = (Vector)vRetResult.elementAt(i + 13);

%>
  <tr<%=strErrMsg%>> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%> <br><%=(String)vRetResult.elementAt(i + 8)%></td>
    <td class="thinborder" align="center">
	<input name="date_posted_<%=iCount%>" type="text" size="11" class="textbox_noborder" style="font-size:9px;"
			onBlur="UpdateInfo(document.form_.date_posted_<%=iCount%>,'2','<%=vRetResult.elementAt(i)%>');style.backgroundColor='white'"
			value="<%=(String)vRetResult.elementAt(i + 2)%>" onFocus="style.backgroundColor='#D3EBFF'">	</td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "Not Set")%></td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true)%>	
<!--
	<input name="payable_amt_<%=iCount%>" type="text" size="16" class="textbox_noborder" style="font-size:9px;" align="right"
			onBlur="UpdateInfo(document.form_.payable_amt_<%=iCount%>,'1','<%=(String)vRetResult.elementAt(i)%>');style.backgroundColor='white'"
			value='<%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true),",","")%>' onFocus="style.backgroundColor='#D3EBFF'">	
-->	</td>
    <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%>&nbsp;</td>
    <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%>&nbsp;</td>
    <td class="thinborder">
	<%if(vDCAccount == null) {%>
		Not Defined
	<%}else{%>
		<table cellpadding="0" cellspacing="0">
			<!--<tr>
				<td class="thinborderBOTTOM">Account Code</td>
				<td class="thinborderBOTTOM">Account Name</td>
				<td class="thinborderBOTTOM">Amount</td>				
			</tr>-->
			<%while(vDCAccount.size() > 0) {
			if(vDCAccount.remove(0).equals("0"))
				strErrMsg = " bgcolor='#dddddd'";
			else
				strErrMsg = "";%>
			<tr<%=strErrMsg%>>
				<td class="thinborderBOTTOMRIGHT" style="font-size:9px;"><%=vDCAccount.remove(0)%></td>
				<td class="thinborderBOTTOMRIGHT" style="font-size:9px;"><%=vDCAccount.remove(0)%></td>
				<td class="thinborderBOTTOMRIGHT" style="font-size:9px;"><%=vDCAccount.remove(0)%></td>				
			</tr>
			<%}%>
		</table>
	
	<%}%>	</td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+11),"Not Locked")%></td>
    <td class="thinborder" align="center"><%if(((String)vRetResult.elementAt(i + 9)).equals("0.00") && strErrMsg.length() == 0 && vRetResult.elementAt(i+11) == null){%>
		<a href="javascript:EditInfo('<%=vRetResult.elementAt(i)%>', '<%=vRetResult.elementAt(i+12)%>')"><img src="../../../../images/edit.gif" border="0"></a>
		<a href="javascript:PageAction('<%=vRetResult.elementAt(i)%>','0')"><img src="../../../../images/delete.gif" border="0"></a>
	<%}%>&nbsp;	</td>
    <td class="thinborder" align="center">
	<a href="javascript:PrintPg('<%=WI.getStrValue((String)vRetResult.elementAt(i+12), "Not Set")%>')"><img src="../../../../images/print.gif" border="0" ></a>	</td>
    <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+12), "Not Set")%></td>
  </tr>
<%}%>
  </table>
<!--
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr> 
    	<td height="25" align="center"><font size="1"><br><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0" ></a>click to print </font></td>
    </tr>
	</table>
-->
  <%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="100%" height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>	
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
