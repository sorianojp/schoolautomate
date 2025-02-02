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
function SchedulePayment(strSupplierRef){	
	document.form_.supplier_ref.value = strSupplierRef;
	document.form_.submit();
}
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.submit();
}


function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.AccountPayable, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;

	if(WI.fillTextValue("print_page").equals("1")){%>
		<jsp:forward page="ap_payment_schedule_print.jsp"/>
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
								"Admin/staff-ACCOUNTING-TRANSACTION-AP-AP PROCESSING","ap_payment_schedule.jsp");
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
	AccountPayable AP = new AccountPayable(); boolean bolErrInUpdate = false;
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(AP.operateOnAPRequestForPayment(dbOP, request, Integer.parseInt(strTemp)) == null)
			bolErrInUpdate = true;
		strErrMsg = AP.getErrMsg();
	}
	
	Vector vItemInfo  = null;
	Vector vRetResult = AP.operateOnAPRequestForPayment(dbOP, request, 5);//show all supplier having delivery payment.. 
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = AP.getErrMsg();
	if(WI.fillTextValue("supplier_ref").length() > 0) {
		request.setAttribute("supplier_ref",WI.fillTextValue("supplier_ref"));
		vItemInfo = AP.operateOnAPRequestForPayment(dbOP, request, 7);
		if(vItemInfo == null)
			strErrMsg = AP.getErrMsg();
		/**
		request.setAttribute("show_balance_only","1");
		purchasing.Delivery DEL = new purchasing.Delivery();
		vItemInfo = DEL.viewDeliveries(dbOP, request);
		if(vItemInfo == null)
			strErrMsg = DEL.getErrMsg();
		**/
	}
%>
<form name="form_" method="post" action="ap_payment_schedule.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
	  <strong>:::: SCHEDULE FOR PAYMENT::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" align="right"><a href="./ap_payment_scheduled_not_paid.jsp">Click to View payment already scheduled but  not yet paid</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%if(vItemInfo != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
  <tr>
    <td height="25" align="center" bgcolor="#B4C5D6" class="thinborderTOPLEFTRIGHT"><strong><font color="#000000">:: Payable Detail of Supplier - 
	<%=vItemInfo.elementAt(0)%>	
	:: </font></strong></td>
    </tr>
  </table>
<%if(false) {//this is not used anymore..   as it is used by calling Delivery method.. new call is shown above.. %>
<!--
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
  <tr> 
    <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Item Name </td>
    <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Date Delivered </td>
    <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Invoice Number </td>
    <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">PO Number </td>
    <td width="10%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Delivery Amt</td>
    <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><span class="thinborder" style="font-size:9px; font-weight:bold">Total Requested As of Now </span></td>
    <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><span class="thinborder" style="font-size:9px; font-weight:bold">Balance Payable</span></td>
    <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Pay on or Before<br>(mm/dd/yyyy)</td>
    <td width="5%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Select</td>
    </tr>
<%
int iRowCount = 0;
for(int i = 0;i < vItemInfo.size();i+=19, ++iRowCount){%>
  <tr> 
    <td class="thinborder"><%=(String)vItemInfo.elementAt(i + 18)%></td>
    <td class="thinborder"><%=(String)vItemInfo.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vItemInfo.elementAt(i+2)%></td>
    <td class="thinborder"><%=(String)vItemInfo.elementAt(i+3)%></td>
    <td align="right" class="thinborder"><%=vItemInfo.elementAt(i + 16)%>&nbsp;</td>
    <td align="right" class="thinborder"><%=(String)vItemInfo.elementAt(i+13)%>&nbsp;</td>
    <td align="right" class="thinborder">
<%
if(bolErrInUpdate)
	strTemp = WI.fillTextValue("to_process"+iRowCount);
else
	strTemp = ConversionTable.replaceString((String)vItemInfo.elementAt(i+14), ",","");
%>	
	  <input name="to_process<%=iRowCount%>" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	</td>
    <td align="right" class="thinborder">
<%
if(bolErrInUpdate)
	strTemp = WI.fillTextValue("date_"+iRowCount);
else
	strTemp = WI.getTodaysDate(1);
%>	
	<input name="date_<%=iRowCount%>" type="text" size="10" maxlength="10" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','date_<%=iRowCount%>','/')"></td>
    <td height="25" align="center" class="thinborder"><input type="checkbox" value="<%=vItemInfo.elementAt(i+12)%>" name="checkbox<%=iRowCount%>" checked="checked"></td>
    </tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=iRowCount%>">
	</table>
-->
<%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
	  <tr> 
		<td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Item Description  </td>
		<td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Posted Date </td>
		<td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Reference</td>
		<td width="10%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Payable Amt</td>
		<td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><span class="thinborder" style="font-size:9px; font-weight:bold">Total Requested As of Now </span></td>
		<td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><span class="thinborder" style="font-size:9px; font-weight:bold">Balance Payable</span></td>
		<td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Pay on or Before<br>(mm/dd/yyyy)</td>
		<td width="5%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Select</td>
		</tr>
	<%
	int iRowCount = 0;
	for(int i = 0;i < vItemInfo.size();i+=11, ++iRowCount){%>
	  <tr> 
		<td class="thinborder"><%=(String)vItemInfo.elementAt(i + 9)%></td>
		<td class="thinborder"><%=(String)vItemInfo.elementAt(i+10)%></td>
		<td class="thinborder"><%=(String)vItemInfo.elementAt(i+2)%></td>
		<td align="right" class="thinborder"><%=vItemInfo.elementAt(i + 8)%>&nbsp;</td>
		<td align="right" class="thinborder"><%=(String)vItemInfo.elementAt(i+5)%>&nbsp;</td>
		<td align="right" class="thinborder">
	<%
	if(bolErrInUpdate)
		strTemp = WI.fillTextValue("to_process"+iRowCount);
	else
		strTemp = ConversionTable.replaceString((String)vItemInfo.elementAt(i+6), ",","");
	%>	
		  <input name="to_process<%=iRowCount%>" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	</td>
		<td align="right" class="thinborder">
	<%
	if(bolErrInUpdate)
		strTemp = WI.fillTextValue("date_"+iRowCount);
	else
		strTemp = WI.getTodaysDate(1);
	%>	
		<input name="date_<%=iRowCount%>" type="text" size="10" maxlength="10" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','date_<%=iRowCount%>','/')"></td>
		<td height="25" align="center" class="thinborder"><input type="checkbox" value="<%=vItemInfo.elementAt(i+4)%>" name="checkbox<%=iRowCount%>" checked="checked"></td>
		</tr>
	<%}%>
	<input type="hidden" name="max_disp" value="<%=iRowCount%>">
		</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr> 
    	<td height="25" align="center"><font size="1"><br><a href="javascript:PageAction('1')"><img src="../../../../images/update.gif" border="0" ></a>Click to Update Schedule of Payment </font><br>&nbsp;</td>
    </tr>
	</table>
<%}

if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
  <tr>
    <td height="25" colspan="11" align="center" bgcolor="#B4C5D6" class="thinborderTOPLEFTRIGHT"><strong><font color="#000000">:: List of Pending Payable Per Supplier :: </font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
  <tr> 
    <td width="10%" align="center"class="thinborder" style="font-size:9px; font-weight:bold">Supplier Code </td>
    <td width="30%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Supplier Name </td>
    <td width="15%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Delivery Amt</td>
    <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><span class="thinborder" style="font-size:9px; font-weight:bold">Total Requested As of Now </span></td>
    <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><span class="thinborder" style="font-size:9px; font-weight:bold">Balance Payable</span></td>
    <td width="10%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Schedule Payment </td>
    </tr>
<%for(int i = 0;i < vRetResult.size();i+=6){%>
  <tr> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
    <td align="right" class="thinborder"><%=vRetResult.elementAt(i)%>&nbsp;</td>
    <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;</td>
    <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%>&nbsp;</td>
    <td height="25" align="center" class="thinborder"><a href="javascript:SchedulePayment('<%=vRetResult.elementAt(i + 5)%>');"><img src="../../../../images/edit.gif" border="0"></a></td>
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

<input type="hidden" name="print_page">	
<input type="hidden" name="page_action">	
<input type="hidden" name="supplier_ref" value="<%=WI.fillTextValue("supplier_ref")%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
