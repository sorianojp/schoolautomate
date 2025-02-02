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
								"Admin/staff-ACCOUNTING-TRANSACTION-AP-AP PROCESSING-Manual Encoding","ap_deliveries_manual_encoding_edit.jsp");
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
	String strSQLQuery = null;
	java.sql.ResultSet rs = null;
	String strJVNumber = null;
	String strJVIndex  = null;
	String strInfoIndex = WI.fillTextValue("info_index");
	
	strSQLQuery = "select jv_number, jv_index from ac_jv join PUR_AP_PROCESSING on (jv_index = jv_ref) where ap_processing_index = "+strInfoIndex;
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strJVNumber = rs.getString(1);
		strJVIndex  = rs.getString(2);
	}
	rs.close();
	
	if(strJVNumber == null) {
		strErrMsg = "Vocher Number not found.";
	}
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.equals("1") && strJVNumber != null && strInfoIndex.length() > 0) {
		//check if number is duplicate.
		String strNewJVNumber = WI.fillTextValue("jv_number");
		
		if(strNewJVNumber.length() == 0 || strNewJVNumber.equals(strJVNumber) )
			strErrMsg = "Please enter Voucher Number.";
		else {
			strSQLQuery = "select jv_index from ac_jv where jv_number = '"+strNewJVNumber+"'";
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0) ;
			if(strSQLQuery != null) {
				strErrMsg = "Voucher already exists.";
			}
			else {
				strSQLQuery = "select jv_index from AC_JV_CANCELLED where jv_number = '"+strNewJVNumber+"'";
				strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0) ;
				if(strSQLQuery != null) {
					strErrMsg = "Voucher already exists.";
				}
				else {
					strSQLQuery = "update ac_jv set jv_number = '"+strNewJVNumber+"' where jv_index ="+strJVIndex;
					if(dbOP.executeUpdateWithTrans(strSQLQuery, (String)request.getSession(false).getAttribute("login_log_index"), "AC_JV", true) == -1)
						strErrMsg = "Error in updating voucher numer.";
					else {
						strErrMsg = "Voucher Number successfully updated.";
						strJVNumber = strNewJVNumber;
					}
				}
			}
		}
	}
	if(strTemp.equals("2") && strInfoIndex.length() > 0) {
		String strSupplier   = WI.fillTextValue("ap_info");
		String strDatePosted = WI.fillTextValue("date_posted");
		String strItemDetail = WI.fillTextValue("item_detail");
		String strReference  = WI.fillTextValue("reference");
		
		
		
		if(strSupplier.length() == 0 || strDatePosted.length() == 0 || strItemDetail.length() == 0 || strReference.length() == 0)
			strErrMsg = "Please enter all information.";
		else {
			strDatePosted = ConversionTable.convertTOSQLDateFormat(strDatePosted);
			strSQLQuery = "update PUR_AP_PROCESSING set ap_info_index = "+strSupplier+", date_posted = '"+strDatePosted+"', item_detail = "+
							WI.getInsertValueForDB(strItemDetail, true, null)+", reference = "+WI.getInsertValueForDB(strReference, true, null)+
							" where ap_processing_index = "+strInfoIndex;
			if(dbOP.executeUpdateWithTrans(strSQLQuery, "AC_JV", (String)request.getSession(false).getAttribute("login_log_index"), true) == -1)
				strErrMsg = "Error in updating other voucher information.";
			else
				strErrMsg = "Voucher other information successfully updated.";
		}	
	
	}
		
		
		
		
		
	
	//get voucher Information.
	Vector vOtherInfo = new Vector();	
	if(strInfoIndex.length() == 0){
		strErrMsg = "Reference index is not found.";
	}
	else {
		strSQLQuery = "select ap_info_index, amount_payable, date_posted, item_detail, reference from PUR_AP_PROCESSING where ap_processing_index = "+strInfoIndex;
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			vOtherInfo.addElement(rs.getString(1));//[0] ap_info_index
			vOtherInfo.addElement(rs.getString(2));//[1] amount_payable
			vOtherInfo.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(3)));//[2] date_posted
			vOtherInfo.addElement(rs.getString(4));//[3] item_detail
			vOtherInfo.addElement(rs.getString(5));//[4] reference
		} 
		rs.close();
	}	
	
	
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
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
function SaveInformation(strAction) {	
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function ReloadPage() {	
	document.form_.page_action.value="";
	document.form_.submit()
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
	
	strNewDeb = "<input name='debit_coa"+iTotalDeb+"' type='text' size='26' class='textbox' onfocus='style.backgroundColor=\"#D3EBFF\"' onBlur='style.backgroundColor=\"#0099FF\"' "+
				"onkeyUP='MapCOAAjax(\"debit_coa"+iTotalDeb+"\", \"coa_info_dc\");'> Amount <input name='debit_coa_amt"+iTotalDeb+"' type='text' size='8' class='textbox' "+
				"onfocus='style.backgroundColor=\"#D3EBFF\"' onBlur='style.backgroundColor=\"white\";AllowOnlyFloat(\"form_\",\"debit_coa_amt"+iTotalDeb+"\"); "+
				"onKeyUp='AllowOnlyFloat(\"form_\",\"debit_coa_amt"+iTotalDeb+"\");'>";

	this.insRow(--iTotalDeb, 1, strNewDeb);
}
var iMaxLen = '';
function updateMaxLen() {
	var iMaxLen = document.form_.item_detail.value.length;
	iMaxLen = eval(document.form_.max_len_.value) - eval (iMaxLen);
	document.form_.max_len_ta.value = eval(iMaxLen);
}
function GoToJV() {
	var strJVNumber = "<%=strJVNumber%>";
	location = "../journal_voucher/journal_voucher_entry.jsp?jv_number="+escape(strJVNumber)+"&jv_type=12";
}
</script>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="ap_deliveries_manual_encoding_edit.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
	  <strong>:::: ACCOUNTS PAYABLE - EDIT PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
<%if(vOtherInfo.size() > 0) {%>
    <tr bgcolor="#cccccc">
      <td height="25">&nbsp;</td>
      <td>APV Number: </td>
      <td height="25"><input name="jv_number" type="text" size="26" maxlength="32" value="<%=strJVNumber%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  &nbsp;&nbsp;&nbsp;
      <input type="button" name="12" value="&nbsp;&nbsp; Update APV Number &nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="SaveInformation('1')"></td>
      <td align="right">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFCC99">
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td align="right">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFCC99">
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Supplier</td>
      <td width="67%" height="25">
  	  <select name="ap_info" style="font-size:11px">
		<%
		strTemp = " from AC_AP_BASIC_INFO where is_valid = 1 and supplier_index is not null order by PAYEE_CODE";
		%>
		<%=dbOP.loadCombo("AP_INFO_INDEX","PAYEE_CODE+' ('+PAYEE_NAME+')'",strTemp,(String)vOtherInfo.elementAt(0), false)%>   
	  </select>	  </td>
      <td width="17%" align="right">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFCC99">
      <td height="25">&nbsp;</td>
      <td>Date Posted </td>
      <td height="25" colspan="2">
        <input name="date_posted"  type= "text" class="textbox"  value="<%=(String)vOtherInfo.elementAt(2)%>" 
			 size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_posted','/')"  
				onKeyUp="AllowOnlyIntegerExtn('form_','date_posted','/')">
        <a href="javascript:show_calendar('form_.date_posted');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>	  </td>
    </tr>
    <tr bgcolor="#FFCC99">
      <td height="25">&nbsp;</td>
      <td>Item Detail </td>
      <td height="25" colspan="2">
	  <textarea name="item_detail" cols="75" rows="3"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" class="textbox"
	   maxlength="<%if(strSchCode.startsWith("UPH")){%>1024<%}else{%>250<%}%>" onKeyUp="updateMaxLen();return isMaxLen(this)" style="font-size:11px;"><%=(String)vOtherInfo.elementAt(3)%></textarea>
	  <font size="1" style="font-weight:bold">Max Length:
	  <input type="text" name="max_len_ta" value="<%if(strSchCode.startsWith("UPH")){%>1024<%}else{%>250<%}%>" size="4" class="textbox_noborder" style="font-size:9px;">
	  </font>
	  <input type="hidden" name="max_len_" value="<%if(strSchCode.startsWith("UPH")){%>1024<%}else{%>250<%}%>">
	  <!--<input value="<%//=WI.fillTextValue("item_detail")%>" name="item_detail" type="text" size="64" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >-->	  </td>
    </tr>
    <tr bgcolor="#FFCC99">
      <td height="25">&nbsp;</td>
      <td>Reference</td>
      <td height="25" colspan="2"><input value="<%=(String)vOtherInfo.elementAt(4)%>" name="reference" type="text" size="64" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
    </tr>
    <tr bgcolor="#FFCC99">
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25" colspan="2"><input type="button" name="122" value="&nbsp;&nbsp; Update Other Information &nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="SaveInformation('2')">
	  
	  <div align="right" style="position:absolute; right:10px;"><a href="javascript:GoToJV();">Go to Edit Accounts</a></div>
	  
	  </td>
    </tr>
    <tr bgcolor="#FFCC99">
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
<!--
    <tr bgcolor="#0099FF">
      <td height="25">&nbsp;</td>
      <td>Invoice Amount</td>
      <td height="25" colspan="2">
	  <input name="amt_payable" type="text" size="16" maxlength="24" value="<%=(String)vOtherInfo.elementAt(1)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','amt_payable');" 
	  onKeyUp="AllowOnlyFloat('form_','amt_payable');">
	  </td>
    </tr>
    <tr bgcolor="#0099FF">
      <td height="25">&nbsp;</td>
      <td>Credit Account </td>
      <td height="25" colspan="2">
		<input name="credit_coa" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("credit_coa")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('credit_coa', 'coa_info_dc');">  	  </td>
    </tr>
    <tr bgcolor="#0099FF">
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
    <tr bgcolor="#0099FF">
      <td></td>
      <td></td>
      <td colspan="2"><label id="coa_info_dc" style="font-size:11px;"></label></td>
    </tr>
    <tr bgcolor="#0099FF">
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25" colspan="2">
	  <input type="button" name="1" value="&nbsp;&nbsp; Update Debit/Credit Information &nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="SaveInformation()">	  </td>
    </tr>
-->
<%}//only if vOtherInfo.size() > 0%>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="100%" height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>	
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
