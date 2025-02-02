<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
WebInterface WI          = new WebInterface(request);
DBOperation dbOP         = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assescrbent & Payments-CASH RECEIPT".toUpperCase()),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assescrbent & Payments".toUpperCase()),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.


String strReportType = WI.fillTextValue("report_format");
String strErrMsg     = null;
String strTemp       = null;
Accounting.CashReceiptBook CRB = new Accounting.CashReceiptBook();

Vector vRetResult  = null; 
Vector vEncoded    = null;
Vector vNotEncoded = null;

dbOP = new DBOperation();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(CRB.encodeCashInHandInfoPerTeller(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = CRB.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}

if(WI.fillTextValue("show_list").length() > 0) {
	vRetResult = CRB.encodeCashInHandInfoPerTeller(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = CRB.getErrMsg();
	else {
		vEncoded = (Vector)vRetResult.remove(0);
		vNotEncoded = (Vector)vRetResult.remove(0);
	}
}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">
function ShowDetail() {
	document.form_.page_action.value = '';
	document.form_.show_list.value = '1';
	document.form_.submit();
}

//all ajax functions here. 
function ajaxUpdate() {

}
function ajaxInsert() {

}
function UpdateChkBox(objTxtBox, objChkBox) {
	if(objTxtBox.value.length > 0) 
		objChkBox.checked = true;
	else	
		objChkBox.checked = false;
}
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.show_list.value = '1';
	document.form_.submit();
}
function ViewDenomination(strReference) {
	var pgLoc = "./daily_encoding_den.jsp?view_transactions=1&emp_id="+strReference+"&date_fr="+document.form_.date_fr.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="./encode_cr_cit.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A" align="center"><font color="#FFFFFF">
	  <strong>:::: CASH RECEIPT MANAGEMENT PAGE  ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<input type="hidden" name="report_format" value="0"><!-- default is date range -->
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="11%" style="font-size:11px;">Date</td>
      <td width="86%">
      <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="14%" height="25">&nbsp;</td>
      <td width="86%" height="25" style="font-size:10px;">
	  	<a href="javascript:ShowDetail();"><img src="../../../images/show_list.gif" border="0"></a>click to preview list</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%if(vNotEncoded != null && vNotEncoded.size() > 0) {
int iNotEncoded = 0;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#A77A81" class="thinborder" >
    <tr> 
      <td height="25" colspan="7" style="font-weight:bold; font-size:14px; color:#FF0000" align="center" bgcolor="#cccccc" class="thinborder">Cash Receipt Not Yet Encoded</td>
    </tr>
		<tr align="center" style="font-weight:bold"> 
		  <td width="15%" height="22" class="thinborder">Teller ID </td>
		  <td class="thinborder" width="20%">Teller Name </td>
		  <td class="thinborder" width="25%">OR Range Used </td>
		  <td class="thinborder" width="15%">Amount Collected</td>
		  <td class="thinborder" width="15%">Cash on hand</td>
		  <td class="thinborder" align="center" width="5%">Select</td>
		  <td class="thinborder" align="center" width="5%">View Denomination </td>
		</tr>
	<%for(int i = 0; i < vNotEncoded.size(); i += 6, ++iNotEncoded) {
	strTemp = CommonUtil.formatFloat(((Double)vNotEncoded.elementAt(i + 4)).doubleValue(), true);
	%>
		<tr> 
		  <td height="22" class="thinborder"><%=vNotEncoded.elementAt(i + 1)%></td>
		  <td class="thinborder"><%=vNotEncoded.elementAt(i + 2)%></td>
		  <td class="thinborder">
	  	  <textarea name="or_range_<%=iNotEncoded%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			 rows="2" cols="50" style="font-size:9px;"><%=vNotEncoded.elementAt(i + 5)%></textarea></td>
		  <td class="thinborder"><%=strTemp%></td>
		  <td class="thinborder"><input type="text" name="coh_<%=iNotEncoded%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		  onKeyUp="UpdateChkBox(document.form_.coh_<%=iNotEncoded%>, document.form_.sel_<%=iNotEncoded%>);" value="<%=strTemp%>"></td>
		  <td class="thinborder" align="center"><input type="checkbox" name="sel_<%=iNotEncoded%>" value="<%=vNotEncoded.elementAt(i)%>" checked></td>
		  <td class="thinborder" align="center"><a href="javascript:ViewDenomination('<%=vNotEncoded.elementAt(i + 1)%>')">View</a></td>
		  <input type="hidden" name="cs_<%=iNotEncoded%>" value="<%=strTemp%>">
		</tr>
	<%}%>
<input type="hidden" name="max_disp_ne" value="<%=iNotEncoded%>">
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td align="center"><a href="javascript:PageAction('1');"><img src="../../../images/save.gif" border="0"></a><font size="1">Click to Save </font></td>
	</tr>
  </table>

<%}if(vEncoded != null && vEncoded.size() > 0) {
int iNotEncoded = 0;
double dCashOnHand = 0d;
double dShort      = 0d;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFCC" class="thinborder">
    <tr> 
      <td height="25" colspan="8" style="font-weight:bold; font-size:14px; color:#0000FF" align="center" bgcolor="#cccccc" class="thinborder">Cash Receipt Already Encoded</td>
    </tr>
		<tr align="center" style="font-weight:bold"> 
		  <td height="22" class="thinborder" width="15%" >Teller ID </td>
		  <td class="thinborder" width="20%" >Teller Name </td>
		  <td class="thinborder" width="15%" >Or Range Used </td>
		  <td class="thinborder" width="15%" >Amount Collected</td>
		  <td class="thinborder" width="15%" >Cash on hand</td>
		  <td class="thinborder" width="15%" >Shortage</td>
		  <td class="thinborder" align="center" width="5%" >Select		  </td>
		  <td class="thinborder" align="center" width="5%" >View Denomination </td>
		</tr>
	<%for(int i = 0; i < vEncoded.size(); i += 6, ++iNotEncoded) {
		dCashOnHand = ((Double)vEncoded.elementAt(i + 4)).doubleValue();
		dShort      = ((Double)vEncoded.elementAt(i + 5)).doubleValue();
	%>
		<tr> 
		  <td height="22" class="thinborder"><%=vEncoded.elementAt(i + 1)%></td>
		  <td class="thinborder"><%=vEncoded.elementAt(i + 2)%></td>
		  <td class="thinborder"><%=vEncoded.elementAt(i + 3)%></td>
		  <td class="thinborder"><%=CommonUtil.formatFloat(dCashOnHand + dShort, true)%></td>
		  <td class="thinborder"><%=CommonUtil.formatFloat(dCashOnHand, true)%></td>
		  <td class="thinborder"><%=CommonUtil.formatFloat(dShort, true)%></td>
		  <td class="thinborder" align="center"><input type="checkbox" name="sel_0<%=iNotEncoded%>" value="<%=vEncoded.elementAt(i)%>">		  </td>
		  <td class="thinborder" align="center"><a href="javascript:ViewDenomination('<%=vEncoded.elementAt(i + 1)%>')">View</a></td>
		</tr>
	<%}%>
<input type="hidden" name="max_disp_e" value="<%=iNotEncoded%>">
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td align="center"><br><a href="javascript:PageAction('0');"><img src="../../../images/cancel.gif" border="0"></a><font size="1">Click to Cancel Entries</font></td>
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
<input type="hidden" name="show_list">  
<input type="hidden" name="page_action">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>