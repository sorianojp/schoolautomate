<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;

	document.form_.submit();
}
function ShowProcessing()
{
	imgWnd=
	window.open("../../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	imgWnd.focus();
	return true;
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}
</script>

<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<%@ page language="java" import="utility.*,Accounting.EnrollmentJournal,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction-Special Journal","crj_tuition.jsp");

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
boolean bolIsTuition = true;
if(WI.fillTextValue("non_tuition").equals("1"))
	bolIsTuition = false;
	
Vector vRetResult = null;
double dTotalDebit = 0d; double dTotalCredit = 0d;
double dTemp      = 0d;
Vector vDebitEntry  = null;
Vector vCreditEntry = null;

Vector vMismatchErrDtls = null;

EnrollmentJournal ERJ = new EnrollmentJournal();
if(WI.fillTextValue("post_verify").length() > 0) {
	strErrMsg = ERJ.postVerifyCRJ(dbOP, request, bolIsTuition);
	if(strErrMsg == null)
		strErrMsg = ERJ.getErrMsg();
}
else if(WI.fillTextValue("generate_").length() > 0) {
	vRetResult = ERJ.generateCRJ(dbOP, request, bolIsTuition);
	if(vRetResult == null) {
		strErrMsg = ERJ.getErrMsg();
		vMismatchErrDtls = ERJ.getErrMsgVector();
	}
}

%>


<form name="form_" action="./crj_tuition.jsp" method="post" onSubmit="SubmitOnceButton(this);return ShowProcessing();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: PAYMENT - <%if(!bolIsTuition){%>NON <%}%>TUITION ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr style="font-weight:bold;">
      <td width="6%" height="25">&nbsp;</td>
      <td colspan="4" style="font-size:18px">		Payment Date: 
	  <input name="date_fr" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_fr")%>" class="textbox" style="font-size:18px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>

-

	  <input name="date_to" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_to")%>" class="textbox" style="font-size:18px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>

	  </td>
    </tr>
    <tr>
      <td height="60">&nbsp;</td>
      <td width="8%" align="center">&nbsp;</td>
      <td width="54%" align="center" valign="bottom">
	  
	  <input type="submit" name="122" value="Generate Payment (<%if(!bolIsTuition){%>Non-<%}%>Tuition Payments)" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.generate_.value='1';ShowProcessing();">
	  </td>
      <td width="25%" align="center">&nbsp;</td>
      <td width="7%" align="center">&nbsp;</td>
    </tr>
  </table>
<%if(vMismatchErrDtls != null && vMismatchErrDtls.size() > 0) {%>
		<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
			<tr>
				<td style="font-size:18px; color:#FF0000; font-weight:bold" colspan="6"><u>Mismatch Amount due to fee not mapped. ::: <%=vMismatchErrDtls.remove(0)%></u></td>
			</tr>
		</table>
		<table width="100%" bgcolor="#FFFFFF">
		<tr><td>
			<table width="55%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
				<tr bgcolor="#999999" style="font-weight:bold" align="center" class="thinborder">
					<td height="22" class="thinborder" width="79%">Source Not Mapped</td>
					<td class="thinborder" width="21%">Amount</td>
				</tr>
				<%for(int i =0; i < vMismatchErrDtls.size(); i+=2){%>
					<tr>
						<td height="22" class="thinborder"><%=vMismatchErrDtls.elementAt(i)%></td>
						<td class="thinborder" align="right"><%=vMismatchErrDtls.elementAt(i + 1)%></td>					
					</tr>
				<%}%>
		  </table>
		</td></tr></table>
<%}
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9" align="center" style="font-weight:bold; font-size:16px;" valign="bottom" class="thinborderBOTTOM">DEBIT ENTRY</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	  <td height="22" style="font-weight:bold; font-size:11px;" width="20%">Account Number</td>
	  <td style="font-weight:bold; font-size:11px;" width="60%">Account Name</td>
	  <td style="font-weight:bold; font-size:11px;" align="right" width="20%">Amount</td>
	</tr>
	<%
	vDebitEntry = (Vector)vRetResult.remove(0);
	for(int i = 0; i < vDebitEntry.size(); i += 4) {
	dTemp = Double.parseDouble((String)vDebitEntry.elementAt(i + 3));
	dTotalDebit += Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTemp, true), ",",""));%>
		<tr>
		  <td height="22"><%=vDebitEntry.elementAt(i + 1)%></td>
		  <td><%=vDebitEntry.elementAt(i + 2)%></td>
		  <td align="right"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		</tr>
	<%}%>
	<tr>
	  <td height="22" colspan="3" align="right" style="font-weight:bold; font-size:11px;">Total: <%=CommonUtil.formatFloat(dTotalDebit, true)%></td>
	</tr>
 </table>
 
 
 
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9" align="center" style="font-weight:bold; font-size:16px;" valign="bottom" class="thinborderBOTTOM">CREDIT ENTRY</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	  <td height="22" style="font-weight:bold; font-size:11px;" width="20%">Account Number</td>
	  <td style="font-weight:bold; font-size:11px;" width="60%">Account Name</td>
	  <td style="font-weight:bold; font-size:11px;" align="right" width="20%">Amount</td>
	</tr>
	<%
	vCreditEntry = (Vector)vRetResult.remove(0);
	for(int i = 0; i < vCreditEntry.size(); i += 4) {
	dTemp = Double.parseDouble((String)vCreditEntry.elementAt(i + 3));
	dTotalCredit += Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTemp, true), ",",""));%>
		<tr>
		  <td height="22"><%=vCreditEntry.elementAt(i + 1)%></td>
		  <td><%=vCreditEntry.elementAt(i + 2)%></td>
		  <td align="right"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		</tr>
	<%}%>
	<tr>
	  <td height="22" colspan="3" style="font-weight:bold; font-size:11px;" align="right">Total: <%=CommonUtil.formatFloat(dTotalCredit, true)%></td>
	</tr>
  </table>
<%
if(!CommonUtil.formatFloat(dTotalDebit, true).equals(CommonUtil.formatFloat(dTotalCredit, true))) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="50">&nbsp;</td>
      <td width="10%" align="center">&nbsp;</td>
      <td width="76%" align="center" valign="bottom" style="font-size:18px;">
	  
	  		Total Debit and Total Credit does not match. Voucher can't be created!!!

		  </td>
      <td width="13%" align="center">&nbsp;</td>
    </tr>
  </table>
<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="50">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center" valign="bottom" style="font-size:18px;">
	  
	  <input type="submit" name="122" value="POST VERIFY - CREATE JOURNAL" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.post_verify.value='1';ShowProcessing();">	  
		  Date Posted (Lock Date):		  

<%
strTemp = WI.fillTextValue("lock_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
	  <input name="lock_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox" style="font-size:18px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.lock_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  &nbsp;<img src="../../../../images/calendar_new.gif" border="0"></a>
		  </td>
      <td width="7%" align="center">&nbsp;</td>
    </tr>
  </table>
<%}%>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="generate_">
<input type="hidden" name="non_tuition" value="<%=WI.fillTextValue("non_tuition")%>">
<input type="hidden" name="post_verify">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
