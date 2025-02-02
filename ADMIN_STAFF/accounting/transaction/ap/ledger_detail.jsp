<%@ page language="java" import="utility.*,Accounting.AccountPayable,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.

	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Admin/staff-Accounting-Transaction-A/P - View Ledger","ledger_detail.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
	AccountPayable AP = new AccountPayable();
    Vector vRetResult = new Vector(); Vector vSupplierInfo = new Vector();
    Vector vTimeSch   = new Vector();

	Vector vDCInfo  = new Vector();
    Vector vPayable = new Vector();
    Vector vPayment = new Vector();
	  
	vRetResult = AP.viewLedgerComplete(dbOP, request);	
	if(vRetResult == null)
		strErrMsg = AP.getErrMsg();
	else {
		vDCInfo       = (Vector)vRetResult.remove(1);
		vPayable      = (Vector)vRetResult.remove(1);
		vPayment      = (Vector)vRetResult.remove(1);
      	vTimeSch      = (Vector)vRetResult.remove(1);
      	vSupplierInfo = (Vector)vRetResult.remove(1);
	}
	
boolean bolIsCompany = !WI.fillTextValue("payee_type").equals("0");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
function PrintPage() {
	
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(3);
	
	alert("Click OK to print this page");
	window.print();
}
</script>
<body>
<form name="form_" method="post" action="./ledger_detail.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
	  <strong>:::: SUPPLIER LEDGER DETAIL::::</strong></font></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td style="font-size:14px; font-weight:bold; color:#FF0000"><%=WI.getStrValue(strErrMsg,"Message : ","","")%>
	  <input type="hidden" name="payee_type" value="1">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>
	  <select name="ap_info" style="font-size:10px">
		<option value="">Select a Payee</option>
<%
strTemp = " from AC_AP_BASIC_INFO join PUR_SUPPLIER_PROFILE on (profile_index = supplier_index) where is_valid = 1";
if(bolIsCompany)
	strTemp += " and supplier_index is not null";
else	
	strTemp += " and supplier_index is null";

strTemp += " order by supplier_code";
%>
<%=dbOP.loadCombo("AP_INFO_INDEX","supplier_code+' ('+supplier_name+')'",strTemp, WI.fillTextValue("ap_info"), false)%>   
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:9px;">Date Filter: 
	  <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a> 
        to 
	  <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a> 
	  
	  &nbsp;&nbsp;&nbsp;
	  <input type="image" src="../../../../images/refresh.gif" border="0">
	  
	  </td>
    </tr>
  </table>
<%
double dBalance = 0d;

boolean bolNegative = false;
if(vRetResult != null && vRetResult.size() > 0) {
strTemp = (String)vRetResult.remove(0);
dBalance = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));

if(strTemp.startsWith("-")) {
	bolNegative = true;
	strTemp = strTemp.substring(1);
}
else
	bolNegative = false;
	
	
///I have to check here if date range is added.. 
java.util.Date dFrom = null;
java.util.Date dTo   = null;
java.util.Date dTransDate = null;
	
if(WI.fillTextValue("date_fr").length() > 0)
	dFrom = ConversionTable.convertMMDDYYYYToDate(WI.fillTextValue("date_fr"));
if(dFrom != null && WI.fillTextValue("date_to").length() > 0)
	dTo = ConversionTable.convertMMDDYYYYToDate(WI.fillTextValue("date_to"));

if(dFrom != null) {
	if(vDCInfo != null && vDCInfo.size() > 0) {
		for(int i = 0; i < vDCInfo.size(); i += 7) {
			dTransDate = ConversionTable.convertMMDDYYYYToDate((String)vDCInfo.elementAt(i));
			
			if(dTransDate.getTime() >= dFrom.getTime()) {
				if(dTo == null)
					break;
				if(dTo.getTime() >= dTransDate.getTime())
					continue;
				vDCInfo.remove(i);vDCInfo.remove(i);vDCInfo.remove(i);vDCInfo.remove(i);vDCInfo.remove(i);vDCInfo.remove(i);vDCInfo.remove(i);
				i = i -7;
				continue;
			}
			if(vDCInfo.elementAt(i + 2).equals("1"))
				dBalance += Double.parseDouble(ConversionTable.replaceString((String)vDCInfo.elementAt(i + 1),",",""));
			else
				dBalance -= Double.parseDouble(ConversionTable.replaceString((String)vDCInfo.elementAt(i + 1),",",""));
			vDCInfo.remove(i);vDCInfo.remove(i);vDCInfo.remove(i);vDCInfo.remove(i);vDCInfo.remove(i);vDCInfo.remove(i);vDCInfo.remove(i);
			
			i = i -7;
		}
	}
	if(vPayable != null && vPayable.size() > 0) {
		for(int i = 0; i < vPayable.size(); i += 8) {
			dTransDate = ConversionTable.convertMMDDYYYYToDate((String)vPayable.elementAt(i));
			
			if(dTransDate.getTime() >= dFrom.getTime()) {
				if(dTo == null)
					break;
				if(dTo.getTime() >= dTransDate.getTime())
					continue;
				vPayable.remove(i);vPayable.remove(i);vPayable.remove(i);vPayable.remove(i);vPayable.remove(i);vPayable.remove(i);vPayable.remove(i);vPayable.remove(i);
				i = i -8;
				continue;
			}
			if(vPayable.elementAt(i + 2).equals("1"))
				dBalance += Double.parseDouble(ConversionTable.replaceString((String)vPayable.elementAt(i + 1),",",""));
			else
				dBalance -= Double.parseDouble(ConversionTable.replaceString((String)vPayable.elementAt(i + 1),",",""));
			vPayable.remove(i);vPayable.remove(i);vPayable.remove(i);vPayable.remove(i);vPayable.remove(i);vPayable.remove(i);vPayable.remove(i);vPayable.remove(i);
			
			i = i -8;
		}
	}
	if(vPayment != null && vPayment.size() > 0) {
		for(int i = 0; i < vPayment.size(); i += 8) {
			dTransDate = ConversionTable.convertMMDDYYYYToDate((String)vPayment.elementAt(i));
			
			if(dTransDate.getTime() >= dFrom.getTime()) {
				if(dTo == null)
					break;
				if(dTo.getTime() >= dTransDate.getTime())
					continue;
				vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);
				i = i -8;
				continue;
			}
			if(vPayment.elementAt(i + 2).equals("1"))
				dBalance += Double.parseDouble(ConversionTable.replaceString((String)vPayment.elementAt(i + 1),",",""));
			else
				dBalance -= Double.parseDouble(ConversionTable.replaceString((String)vPayment.elementAt(i + 1),",",""));
			vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);
			
			i = i -8;
		}
	}
}	
if(dBalance < 0d) {
	bolNegative = true;
	strTemp = CommonUtil.formatFloat(dBalance, true).substring(1);
}
else {
	bolNegative = false;
	strTemp = CommonUtil.formatFloat(dBalance, true);
}

		//vDCInfo       = (Vector)vRetResult.remove(1);
		//vPayable      = (Vector)vRetResult.remove(1);
		//vPayment      = (Vector)vRetResult.remove(1);

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr>
      <td height="25" colspan="5" align="center" style="font-weight:bold">CREDITOR/SUPPLIER'S LEDGER</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="10%">Name : </td>
      <td width="56%"><%=vSupplierInfo.elementAt(1)%> :: <%=vSupplierInfo.elementAt(2)%></td>
      <td width="10%">Telephone/Fax </td>
      <td width="22%">
	  <%=WI.getStrValue(vSupplierInfo.elementAt(4),"--")%>/
	  <%=WI.getStrValue(vSupplierInfo.elementAt(5),"--")%>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Address</td>
      <td colspan="3"><%=WI.getStrValue(vSupplierInfo.elementAt(3), "Not set")%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3" align="right" style="font-size:9px;"><a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a> Print Page&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td height="25" colspan="6" align="center" bgcolor="#B4C5D6" class="thinborder"><strong><font color="#000000">:: Complete Ledger :: </font></strong></td>
    </tr>
    <tr>
      <td width="15%" class="thinborder" height="25"><strong>Transaction Date </strong></td>
      <td width="15%" class="thinborder" style="font-weight:bold">Reference</td>
      <td width="40%" class="thinborder"><strong>Transaction Note </strong></td>
      <td width="10%" class="thinborder"><strong>Debit</strong></td>
      <td width="10%" class="thinborder"><strong>Credit</strong></td>
      <td width="15%" class="thinborder"><strong>Balance</strong></td>
    </tr>
    <tr>
      <td height="25" colspan="5" class="thinborder" align="right">Balance Forwarded &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td class="thinborder" align="right"><%if(bolNegative){%>(<%}%><%=strTemp%><%if(bolNegative){%>)<%}%></td>
    </tr>

<%
String strTransDate  = null;
String strDateToDisp = null;
while(vTimeSch.size() > 0) {
strTransDate = ConversionTable.convertMMDDYYYY((Date)vTimeSch.remove(0));
strDateToDisp = strTransDate;

//System.out.println("Main Date: "+strTransDate);

	while(vDCInfo.size() > 0){
		if(!strTransDate.equals((String)vDCInfo.elementAt(0)))
			break;
		%>
		<tr>
		  <td class="thinborder" height="25"><%=WI.getStrValue(strDateToDisp,"&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vDCInfo.elementAt(6),"&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vDCInfo.elementAt(5),"&nbsp;")%></td>
		  <td class="thinborder" align="right"><%if(vDCInfo.elementAt(2).equals("1")){dBalance += Double.parseDouble(ConversionTable.replaceString((String)vDCInfo.elementAt(1),",",""));%><%=vDCInfo.elementAt(1)%><%}else{%>&nbsp;<%}%></td>
		  <td class="thinborder" align="right"><%if(vDCInfo.elementAt(2).equals("0")){dBalance -= Double.parseDouble(ConversionTable.replaceString((String)vDCInfo.elementAt(1),",",""));%><%=vDCInfo.elementAt(1)%><%}else{%>&nbsp;<%}%></td>
		  <td class="thinborder" align="right">
		  <%
		  strTemp = CommonUtil.formatFloat(dBalance, true);
		  if(strTemp.startsWith("-"))
		  	strTemp = strTemp.substring(1);
		  if(dBalance < 0){%>(<%}%><%=strTemp%><%if(dBalance < 0){%>)<%}%></td>
		</tr>
	<%
	vDCInfo.remove(0);vDCInfo.remove(0);vDCInfo.remove(0);vDCInfo.remove(0);vDCInfo.remove(0);vDCInfo.remove(0);vDCInfo.remove(0);
	strDateToDisp = null;
	}
	while(vPayable.size() > 0){//process.vPayable
		if(!strTransDate.equals((String)vPayable.elementAt(0)))
			break;
		%>
		<tr>
		  <td class="thinborder" height="25"><%=WI.getStrValue(strDateToDisp,"&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vPayable.elementAt(6),"&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vPayable.elementAt(5),"&nbsp;")%></td>
		  <td class="thinborder" align="right"><%if(vPayable.elementAt(2).equals("1")){dBalance += Double.parseDouble(ConversionTable.replaceString((String)vPayable.elementAt(1),",",""));%><%=vPayable.elementAt(1)%><%}else{%>&nbsp;<%}%></td>
		  <td class="thinborder" align="right"><%if(vPayable.elementAt(2).equals("0")){dBalance -= Double.parseDouble(ConversionTable.replaceString((String)vPayable.elementAt(1),",",""));%><%=vPayable.elementAt(1)%><%}else{%>&nbsp;<%}%></td>
		  <td class="thinborder" align="right">
		  <%
		  strTemp = CommonUtil.formatFloat(dBalance, true);
		  if(strTemp.startsWith("-"))
		  	strTemp = strTemp.substring(1);
		  if(dBalance < 0){%>(<%}%><%=strTemp%><%if(dBalance < 0){%>)<%}%></td>
		</tr>
	<%
	vPayable.remove(0);vPayable.remove(0);vPayable.remove(0);vPayable.remove(0);vPayable.remove(0);vPayable.remove(0);vPayable.remove(0);vPayable.remove(0);
	strDateToDisp = null;
	}
		while(vPayment.size() > 0){
		if(!strTransDate.equals((String)vPayment.elementAt(0))) {
			//System.out.println("Does not match Date: "+vPayment.elementAt(0));
			break;
		}
		%>
		<tr>
		  <td class="thinborder" height="25"><%=WI.getStrValue(strDateToDisp,"&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vPayment.elementAt(6),"&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vPayment.elementAt(5),"&nbsp;")%></td>
		  <td class="thinborder" align="right"><%if(vPayment.elementAt(2).equals("1")){dBalance += Double.parseDouble(ConversionTable.replaceString((String)vPayment.elementAt(1),",",""));%><%=vPayment.elementAt(1)%><%}else{%>&nbsp;<%}%></td>
		  <td class="thinborder" align="right"><%if(vPayment.elementAt(2).equals("0")){dBalance -= Double.parseDouble(ConversionTable.replaceString((String)vPayment.elementAt(1),",",""));%><%=vPayment.elementAt(1)%><%}else{%>&nbsp;<%}%></td>
		  <td class="thinborder" align="right">
		  <%
		  strTemp = CommonUtil.formatFloat(dBalance, true);
		  if(strTemp.startsWith("-"))
		  	strTemp = strTemp.substring(1);
		  if(dBalance < 0){%>(<%}%><%=strTemp%><%if(dBalance < 0){%>)<%}%></td>
		</tr>
	<%
	vPayment.remove(0);vPayment.remove(0);vPayment.remove(0);vPayment.remove(0);vPayment.remove(0);vPayment.remove(0);vPayment.remove(0);vPayment.remove(0);
	strDateToDisp = null;
	}%>

<%}%>
  </table>
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>