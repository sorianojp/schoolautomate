<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function MoveAP(strItemDeliveryIndex,strGrossAmt){	
	document.form_.item_delivery_ref.value = strItemDeliveryIndex;
	document.form_.gross_amt.value         = strGrossAmt;
	
	if(document.form_.show_processed.checked)
		document.form_.forward_to.value = "1";
	else{
		var vProceed = confirm('Edit amount or due date before moving?. Click OK to Edit, and Cancel to move without editing');
		if(vProceed)				
			document.form_.forward_to.value = "1";
		else		
			document.form_.move.value = "1";		
	}
	this.SubmitOnce('form_');
}
function ReloadPage() {	
	document.form_.forward_to.value='';
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function PrintPg(){
	document.form_.forward_to.value='';
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
function RegisterSupplier(strSupplierIndex) {
	var win=window.open("./manage_ap_basic_info.jsp?supplier_index="+strSupplierIndex,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*, purchasing.Delivery, Accounting.AccountPayable, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;

	if(WI.fillTextValue("forward_to").equals("1")){%>
		<jsp:forward page="ap_add_to_ledger.jsp"/>
	<%return;}

	if(WI.fillTextValue("print_page").equals("1")){%>
		<jsp:forward page="ap_deliveries_print.jsp"/>
	<%return;}
	
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
								"Admin/staff-ACCOUNTING-TRANSACTION-AP-AP PROCESSING","ap_deliveries.jsp");
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
	Vector vRetResult = null;
	Vector vAPProcessingInfo = new Vector();
	
	String strReceiver = null;
	String strChecker = null;
	int iCount = 0;
	
	strTemp = WI.fillTextValue("move");
	if(strTemp.length() > 0){
		if(AP.operateOnProcessAP(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = AP.getErrMsg();
	}
	
	vRetResult = DEL.viewDeliveries(dbOP, request);
	if(vRetResult == null)
		strErrMsg = DEL.getErrMsg();
	else {
		for(int i = 0; i < vRetResult.size(); i += 19) {
			///review this.. 
			/**
			if(vAPProcessingInfo.indexOf(WI.getStrValue(vRetResult.elementAt(i + 12))) == -1)
				vAPProcessingInfo.addElement(vRetResult.elementAt(i + 12));
			**/
			//System.out.println(vAPProcessingInfo);
			vAPProcessingInfo = AP.getPurAPProcessingInfo(dbOP, vAPProcessingInfo);
			//System.out.println(vAPProcessingInfo);
		}
	}
if(vAPProcessingInfo == null)
	vAPProcessingInfo = new Vector();	

//get all the suppliers registered for AP account... 
Vector vRegisteredSupplier = new Vector();
String strSQLQuery = "select SUPPLIER_INDEX from AC_AP_BASIC_INFO where IS_VALID = 1";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
while(rs.next())
	vRegisteredSupplier.addElement(rs.getString(1));
rs.close();
boolean bolRegistered = true;
//////////////////// end of getting registered supplier for AP ///////////
%>
<form name="form_" method="post" action="ap_deliveries.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
	  <strong>:::: ACCOUNTS PAYABLE - DELIVERIES  PROCESSING PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="61%" height="25">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
      <td width="39%" align="right" style="font-size:10px; font-weight:bold;">
  	  <a href="./ap_deliveries_manual_encoding.jsp">Manually Encode Processed Delivery (no delivery in System)</a></td>
    </tr>
    <tr bgcolor="#FFFFFF">
		<%
			strTemp = WI.fillTextValue("show_processed");
			if(strTemp.length() > 0)
				strTemp = " checked";
			else
				strTemp = "";
		%>
      <td height="25" colspan="2">&nbsp;<input type="checkbox" name="show_processed" value="1" <%=strTemp%> onClick="ReloadPage();">
        <strong><font size="1">show only processed deliveries</font></strong>
		
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:document.form_.submit();"><img src="../../../../images/refresh.gif" border="0" onClick="document.form_.print_page.value=''"></a>		</td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
  <tr>
<%
boolean bolIsProcessed = false;

	if(WI.fillTextValue("show_processed").equals("1")) {
		strTemp = "PROCESSED";
		bolIsProcessed = true;
	}
	else
		strTemp = "UNPROCESSED";
%>
    <td height="25" colspan="11" align="center" bgcolor="#B4C5D6" class="thinborderTOPLEFTRIGHT"><strong><font color="#000000">:: LIST OF DELIVERIES <%=strTemp%> AS OF <%=WI.getTodaysDate(1)%> :: </font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
  <tr> 
    <td width="21%" align="center"class="thinborder" style="font-size:9px; font-weight:bold">Supplier/ Payee Name</td>
    <td width="11%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Delivery Date</td>
    <td width="9%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Invoice #</td>
    <td width="8%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">PO #</td>
    <td width="10%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Received By</td>
    <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Checked By</td>
    <td width="12%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Delivery Amt</td>
<%if(false){%>
		<td width="12%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Debit</td>
		<td width="12%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Credit</td>
<%}%>
    <td width="12%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Lock Date </td>
    <%if(bolIsProcessed) {%>
    <td width="12%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Balance Payable </td>
    <td width="12%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">To be Processed Amt  </td>
    <td width="12%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Delete</td>
    <%}%>
    <td width="9%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">
		<%if(bolIsProcessed) {%>Edit <%}else{%>Move to <%}%>AP Ledger</td>
    </tr>
<%

if(bolIsProcessed) {
	strTemp = "../../../../images/edit.gif";	
	strErrMsg = " bgcolor='#dddddd'";
}		
else {
	strTemp = "../../../../images/move.gif";
	strErrMsg = "";
}
boolean bolDelAllowed = false;
String strTemp2 = null;

int iIndexOf = 0;
String strDebitCOA  = null;
String strCreditCOA = null;
String strLockDate  = null;


for(int i = 0;i < vRetResult.size();i+=19,iCount++){
strErrMsg = "";
strTemp2 = (String)vRetResult.elementAt(i + 10); //supplier index. 
if(vRegisteredSupplier.indexOf(strTemp2) > -1) {
	bolRegistered = true;
	if(bolIsProcessed)
		strErrMsg = " bgcolor='#dddddd'";
}
else {	
	bolRegistered = false;
	strErrMsg = " bgcolor='#dd0000'";
}

iIndexOf = vAPProcessingInfo.indexOf(vRetResult.elementAt(i + 12));
if(iIndexOf == -1) {
	strDebitCOA  = null;
	strCreditCOA = null;
	strLockDate  = null;
}
else {
	strDebitCOA  = (String)vAPProcessingInfo.elementAt(iIndexOf + 1)+"<br>"+(String)vAPProcessingInfo.elementAt(iIndexOf + 2);
	strCreditCOA = (String)vAPProcessingInfo.elementAt(iIndexOf + 3)+"<br>"+(String)vAPProcessingInfo.elementAt(iIndexOf + 4);
	strLockDate  = (String)vAPProcessingInfo.elementAt(iIndexOf + 5);
}
%>
  <tr <%=strErrMsg%>> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5), "Not Set")%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "Not Set")%></td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true)%>&nbsp;</td>
<%if(false){%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strDebitCOA,"&nbsp;")%></td>
    <td align="right" class="thinborder"><%=WI.getStrValue(strCreditCOA,"&nbsp;")%></td>
<%}%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strLockDate,"&nbsp;")%></td>
    <%if(bolIsProcessed) {%>
    <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+14)%>&nbsp;</td>
    <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+13)%>&nbsp;</td>
    <td class="thinborder" align="center"><%if(((String)vRetResult.elementAt(i + 15)).equals("0.00") && bolRegistered && strLockDate == null){%>
		<input name="image" src="../../../../images/delete.gif" type="image" onClick="document.form_.info_index.value='<%=vRetResult.elementAt(i + 12)%>'; document.form_.move.value='0';document.form_.item_delivery_ref.value='<%=vRetResult.elementAt(i + 11)%>'">
		<%}%>&nbsp;	</td>
<%}%>
    <td height="25" align="center" class="thinborder">
	<%if(bolRegistered){%>
		<%if(strLockDate == null) {%>
			<a href="javascript:MoveAP('<%=vRetResult.elementAt(i + 11)%>','<%=vRetResult.elementAt(i+4)%>');"><img src="<%=strTemp%>" border="0"></a>
		<%}%>
	<%}else{%>
	<a href="javascript:RegisterSupplier('<%=strTemp%>');"><font color="#FFFFFF">Register Supplier</font></a>
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
	
	<input type="hidden" name="print_page">
  <input type="hidden" name="forward_to">
	<input type="hidden" name="supplier_name">
	<input type="hidden" name="delivery_date">
	<input type="hidden" name="invoice_no">
	<input type="hidden" name="po_number">
	<input type="hidden" name="received_by">
	<input type="hidden" name="checked_by">	
	<input type="hidden" name="po_index">	
	<input type="hidden" name="supplier_index">		
	<input type="hidden" name="receiver">	
	<input type="hidden" name="checker">	
	
	<input type="hidden" name="info_index">
	<input type="hidden" name="move">
	<input type="hidden" name="item_delivery_ref">
	<input type="hidden" name="due_date" value="<%=WI.getTodaysDate(1)%>">
	<input type="hidden" name="gross_amt">
			
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
