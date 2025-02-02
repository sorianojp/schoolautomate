<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
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
		if(AP.operateOnProcessAPManual(dbOP, request, Integer.parseInt(strTemp)) == null) 
			strErrMsg = AP.getErrMsg();
		else	
			strErrMsg = "Operation Successful.";
	}
	vRetResult = AP.operateOnProcessAPManual(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = AP.getErrMsg();

%>
<form name="form_" method="post" action="ap_deliveries_manual_encoding.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
	  <strong>:::: ACCOUNTS PAYABLE - DELIVERIES  PROCESSING PAGE - MANUAL ENCODING ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Supplier</td>
      <td width="84%" height="25">
  	  <select name="ap_info" style="font-size:11px">
		<%
		strTemp = " from AC_AP_BASIC_INFO where is_valid = 1 and supplier_index is not null order by PAYEE_CODE";
		%>
		<%=dbOP.loadCombo("AP_INFO_INDEX","PAYEE_CODE+' ('+PAYEE_NAME+')'",strTemp, WI.fillTextValue("ap_info"), false)%>   
	  </select>	  </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Invoice Amount </td>
      <td height="25"><input name="amt_payable" type="text" size="16" maxlength="24" value="<%=WI.fillTextValue("amt_payable")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','amt_payable');" 
	  onKeyUp="AllowOnlyFloat('form_','amt_payable');"></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Date Posted </td>
      <td height="25">
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
      <td height="25"><input value="<%=WI.fillTextValue("item_detail")%>" name="item_detail" type="text" size="64" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Reference</td>
      <td height="25"><input value="<%=WI.fillTextValue("reference")%>" name="reference" type="text" size="64" class="textbox" 
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
      <td height="25">
		<input name="credit_coa" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("credit_coa")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('credit_coa', 'coa_info_dc');">  	  </td>
    </tr>
<!--
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Lock Date </td>
      <td height="25">
        <input name="lock_date"  type= "text" class="textbox"  value="<%=WI.fillTextValue("lock_date")%>" 
			 size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','lock_date','/')"  
				onKeyUp="AllowOnlyIntegerExtn('form_','lock_date','/')">
        <a href="javascript:show_calendar('form_.lock_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>

  	  </td>
    </tr>
-->
    <tr bgcolor="#FFFFFF">
      <td></td>
      <td></td>
      <td><label id="coa_info_dc" style="font-size:11px;"></label></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">
	  <input type="submit" name="1" value="&nbsp;&nbsp;Save Information&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';document.form_.info_index.value='';">	  </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Sort By: Supplier Date </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3" align="right" style="font-size:10px;"><a href="javascript:ReloadPage();"><img src="../../../../images/refresh.gif" border="0"></a> Please click refresh to reload the page incase there are on spot editing.&nbsp;
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
    <td width="20%" align="center"class="thinborder" style="font-size:9px; font-weight:bold">Supplier</td>
    <td width="10%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Posted Date</td>
    <td width="20%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Item Detail </td>
    <td width="10%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Reference</td>
    <td width="7%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Payable Amt</td>
    <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Balance Payable </td>
    <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">To be Processed Amt  </td>
    <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Debit COA </td>
    <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Credit COA </td>
    <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Delete</td>
    </tr>
<%int iCount = 0; 
for(int i = 0;i < vRetResult.size();i+=14,++iCount){
if(vRetResult.elementAt(i + 10) != null) {
	strErrMsg = " bgcolor='cccccc'";
	continue;
}
else	
	strErrMsg = "";
%>
  <tr<%=strErrMsg%>> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%> <br><%=(String)vRetResult.elementAt(i + 8)%></td>
    <td class="thinborder" align="center">
	<input name="date_posted_<%=iCount%>" type="text" size="11" class="textbox_noborder" style="font-size:9px;"
			onBlur="UpdateInfo(document.form_.date_posted_<%=iCount%>,'2','<%=vRetResult.elementAt(i)%>');style.backgroundColor='white'"
			value="<%=(String)vRetResult.elementAt(i + 2)%>" onFocus="style.backgroundColor='#D3EBFF'">	</td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "Not Set")%></td>
    <td align="right" class="thinborder">
	<input name="payable_amt_<%=iCount%>" type="text" size="16" class="textbox_noborder" style="font-size:9px;" align="right"
			onBlur="UpdateInfo(document.form_.payable_amt_<%=iCount%>,'1','<%=(String)vRetResult.elementAt(i)%>');style.backgroundColor='white'"
			value='<%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true),",","")%>' onFocus="style.backgroundColor='#D3EBFF'">	</td>
    <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%>&nbsp;</td>
    <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%>&nbsp;</td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+11), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+12), "&nbsp;")%></td>
    <td class="thinborder" align="center"><%if(((String)vRetResult.elementAt(i + 9)).equals("0.00") && strErrMsg.length() == 0 && vRetResult.elementAt(i+13) == null){%>
		<a href="javascript:PageAction('<%=vRetResult.elementAt(i)%>','0')"><img src="../../../../images/delete.gif" border="0"></a>
	<%}%>&nbsp;	</td>
    </tr>
<%}%>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr> 
    	<td height="25" align="center"><font size="1"><br><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0" ></a>click to print </font></td>
    </tr>
	</table>
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
