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
								"Admin/staff-Accounting-Transaction-Special Journal","ar_journal.jsp");
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


boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").equals("1"))
	bolIsBasic = true;

Vector vRetResult = null;
Vector vARTuition = null;
Vector vARMisc    = null;
Vector vAROC      = null;
Vector vARHandsOn = null;

Vector vARMismatchErrDtls = null;

double dTotalT    = 0d;//total tuition.
double dTotalM    = 0d;//total misc
double dTotalO    = 0d;//total Other
double dTotalH    = 0d;//total hands on
double dTemp      = 0d;

double dTotalDebit = 0d; double dTotalCredit = 0d;

Vector vDebitEntry  = null;
Vector vCreditEntry = null;

boolean bolIsAROthSchFeeTuition = false;
if(WI.fillTextValue("is_postcharge").length() > 0) 
	bolIsAROthSchFeeTuition = true;	

//post verify here.. 
	EnrollmentJournal ERJ = new EnrollmentJournal();
if(WI.fillTextValue("post_verify").length() > 0) {
	strErrMsg = ERJ.postVerifyARTuition(dbOP, request);
}
else if(WI.fillTextValue("generate_").length() > 0) {
	vRetResult = ERJ.generateARJournal(dbOP, request);
	if(vRetResult == null) {
		strErrMsg = ERJ.getErrMsg();
		vARMismatchErrDtls = ERJ.getErrMsgVector();
		
		System.out.println(vARMismatchErrDtls);
	}
	else {
		vARTuition = (Vector)vRetResult.elementAt(0);
		if(!bolIsAROthSchFeeTuition) {
			vARMisc    = (Vector)vRetResult.elementAt(1);
			vAROC      = (Vector)vRetResult.elementAt(2);
			vARHandsOn = (Vector)vRetResult.elementAt(3);
		}
	}	
}
%>



<form name="form_" action="./ar_journal.jsp" method="post" onSubmit="SubmitOnceButton(this);return ShowProcessing();">

<%
if(vARMismatchErrDtls != null) {
	Vector v1 = (Vector)vARMismatchErrDtls.remove(0);
	Vector v2 = (Vector)vARMismatchErrDtls.remove(0);

	if(v1 != null && v1.size() > 0) {
		strTemp = "";
		String strMisc = (String)v1.remove(0);
		if(!strMisc.equals("0.00"))
			strTemp = " Total Misc Diff: "+strMisc;
		strMisc = (String)v1.remove(0);
		if(!strMisc.equals("0.00"))
			strTemp = " Total OC Diff: "+strMisc;
	%>
		<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
			<tr>
				<td style="font-size:18px; color:#FF0000; font-weight:bold" colspan="6"><u>Difference found in AR total and details: AR needs to be initialized ::: <%=strTemp%></u></td>
			</tr>
		</table>
		<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
			<tr bgcolor="#999999" style="font-weight:bold" align="center" class="thinborder">
				<td height="22" class="thinborder" width="10%">Student ID</td>
				<td class="thinborder" width="15%">Student Name</td>
				<td class="thinborder" width="15%">Misc AR(Total)</td>
				<td class="thinborder" width="15%">Misc Difference</td>
				<td class="thinborder" width="15%">OC AR(Total)</td>
				<td class="thinborder" width="15%">OC Difference</td>
			</tr>
			<%
			strTemp = "";
			for(int i =0; i < v1.size(); i+=8){%>
				<tr>
					<td height="22" class="thinborder"><%=v1.elementAt(i)%></td>
					<td class="thinborder"><%=v1.elementAt(i + 1)%></td>
					<td class="thinborder"><%=v1.elementAt(i + 2)%></td>
					<td class="thinborder"><%=v1.elementAt(i + 4)%></td>
					<td class="thinborder"><%=v1.elementAt(i + 5)%></td>
					<td class="thinborder"><%=v1.elementAt(i + 7)%></td>
				</tr>
			<%strTemp = strTemp + "'"+v1.elementAt(i)+"',";}//System.out.println(strTemp);%>
		</table>
	<%}if(v2 != null && v2.size() > 0) {
		strTemp = "";
		String strMisc = (String)v2.remove(0);
		if(!strMisc.equals("0.00"))
			strTemp = " Total Misc Lacking: "+strMisc;
		strMisc = (String)v2.remove(0);
		if(!strMisc.equals("0.00"))
			strTemp = " Total OC Lacking: "+strMisc;
			
		String[] astrConvertMiscOC = {"Misc","OC"};
		%>
		<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
			<tr>
				<td style="font-size:18px; color:#FF0000; font-weight:bold" colspan="6"><u>Fee not mapped. ::: <%=strTemp%></u></td>
			</tr>
		</table>
		<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
			<tr bgcolor="#999999" style="font-weight:bold" align="center" class="thinborder">
				<td height="22" class="thinborder" width="10%">Student ID</td>
				<td class="thinborder" width="15%">Student Name</td>
				<td class="thinborder" width="25%">Fee Name</td>
				<td class="thinborder" width="10%">Course</td>
				<td class="thinborder" width="10%">College</td>
				<td class="thinborder" width="10%">Misc/OC</td>
			</tr>
			<%for(int i =0; i < v2.size(); i+=8){%>
				<tr>
					<td height="22" class="thinborder"><%=v2.elementAt(i)%></td>
					<td class="thinborder"><%=v2.elementAt(i + 1)%></td>
					<td class="thinborder"><%=v2.elementAt(i + 2)%></td>
					<td class="thinborder"><%=v2.elementAt(i + 3)%><%=WI.getStrValue((String)v2.elementAt(i + 5), "-","","")%></td>
					<td class="thinborder"><%=WI.getStrValue((String)v2.elementAt(i + 4), "&nbsp;")%></td>
					<td class="thinborder"><%=astrConvertMiscOC[Integer.parseInt((String)v2.elementAt(i + 6))]%></td>
				</tr>
			<%}%>
		</table>
	<%}//if v2 is not null..

}%>




  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: AR INVOICE <%if(bolIsAROthSchFeeTuition){%>(OTHER SCHOOL FEE - TUITION)<%}%> - <%if(bolIsBasic) {%>BASIC<%}else{%>COLLEGE<%}%> 
      ::::</strong></font></div></td>
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
      <td height="40">&nbsp;</td>
      <td colspan="6" style="font-size:18px">SY-Term:&nbsp;&nbsp; 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox_bigfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp=" DisplaySYTo('form_','sy_from','sy_to')">
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox_bigfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        <select name="semester" class="textbox_bigfont">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp  = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.equals("1")){%>
          <option value="1" selected>1st Term</option>
          <%}else{%>
          <option value="1">1st Term</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Term</option>
          <%}else{%>
          <option value="2">2nd Term</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Term</option>
          <%}else{%>
          <option value="3">3rd Term</option>
          <%}%>
        </select>      </td>
    </tr>
    <tr>
      <td height="50">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td width="38%" align="center" valign="bottom">
	  
	  <input type="submit" name="122" value="Generate Invoice" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.generate_.value='1';ShowProcessing();">	  </td>
      <td width="41%" align="center">&nbsp;</td>
      <td width="7%" align="center">&nbsp;</td>
    </tr>
  </table>
  
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9" align="center" style="font-weight:bold; font-size:16px;" valign="bottom" class="thinborderBOTTOM">DEBIT ENTRY</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(!bolIsAROthSchFeeTuition) {%>
    <tr>
      <td height="25" colspan="3" style="font-weight:bold; font-size:11px;"><u>Tuition</u></td>
    </tr>
<%}%>
	<tr>
	  <td height="22" style="font-weight:bold; font-size:11px;" width="20%">Account Number</td>
	  <td style="font-weight:bold; font-size:11px;" width="60%">Account Name</td>
	  <td style="font-weight:bold; font-size:11px;" align="right" width="20%">Amount</td>
	</tr>
	<%
	vDebitEntry = (Vector)vARTuition.remove(0);
	for(int i = 0; i < vDebitEntry.size(); i += 4) {
	dTemp = Double.parseDouble((String)vDebitEntry.elementAt(i + 3));
	dTotalT += Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTemp, true), ",",""));%>
		<tr>
		  <td height="22"><%=vDebitEntry.elementAt(i + 1)%></td>
		  <td><%=vDebitEntry.elementAt(i + 2)%></td>
		  <td align="right"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		</tr>
	<%}%>
	<tr>
	  <td height="22" colspan="3" align="right" style="font-weight:bold; font-size:11px;">Total: <%=CommonUtil.formatFloat(dTotalT, true)%></td>
	</tr>
<%if(!bolIsAROthSchFeeTuition) {%>
    <tr>
      <td height="25" colspan="3" style="font-weight:bold; font-size:11px;"><u>Misc</u></td>
    </tr>
	<%
	vDebitEntry = (Vector)vARMisc.remove(0);
	for(int i = 0; i < vDebitEntry.size(); i += 4) {
	dTemp = Double.parseDouble((String)vDebitEntry.elementAt(i + 3));
	dTotalM += Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTemp, true), ",",""));%>
		<tr>
		  <td height="22"><%=vDebitEntry.elementAt(i + 1)%></td>
		  <td><%=vDebitEntry.elementAt(i + 2)%></td>
		  <td align="right"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		</tr>
	<%}%>
	<tr>
	  <td height="22" colspan="3" align="right" style="font-weight:bold; font-size:11px;">Total: <%=CommonUtil.formatFloat(dTotalM, true)%></td>
	</tr>
    <tr>
      <td height="25" colspan="3" style="font-weight:bold; font-size:11px;"><u>Other Charge</u></td>
    </tr>
	<%
	vDebitEntry = (Vector)vAROC.remove(0);
	for(int i = 0; i < vDebitEntry.size(); i += 4) {
	dTemp = Double.parseDouble((String)vDebitEntry.elementAt(i + 3));
	dTotalO += Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTemp, true), ",",""));%>
		<tr>
		  <td height="22"><%=vDebitEntry.elementAt(i + 1)%></td>
		  <td><%=vDebitEntry.elementAt(i + 2)%></td>
		  <td align="right"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		</tr>
	<%}%>
	<tr>
	  <td height="22" colspan="3" align="right" style="font-weight:bold; font-size:11px;">Total: <%=CommonUtil.formatFloat(dTotalO, true)%></td>
	</tr>
	<%if(vARHandsOn != null && vARHandsOn.size() > 0) {
		vDebitEntry = (Vector)vARHandsOn.remove(0); //System.out.println(vDebitEntry);
		if(vDebitEntry != null && vDebitEntry.size() > 0) {%>
			<tr>
			  <td height="25" colspan="3" style="font-weight:bold; font-size:11px;"><u>Computer HandsOn</u></td>
			</tr>
			<%
			for(int i = 0; i < vDebitEntry.size(); i += 4) {
			dTemp = Double.parseDouble((String)vDebitEntry.elementAt(i + 3));
			dTotalH += Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTemp, true), ",",""));%>
				<tr>
				  <td height="22"><%=vDebitEntry.elementAt(i + 1)%></td>
				  <td><%=vDebitEntry.elementAt(i + 2)%></td>
				  <td align="right"><%=CommonUtil.formatFloat(dTemp, true)%></td>
				</tr>
			<%}%>
			<tr>
			  <td height="22" colspan="3" align="right" style="font-weight:bold; font-size:11px;">Total: <%=CommonUtil.formatFloat(dTotalH, true)%></td>
			</tr>
	<%}
	}//only if handson is having data.
	dTotalDebit = dTotalT+dTotalM+dTotalO+dTotalH;%>
	<tr>
	  <td height="22" colspan="3" style="font-weight:bold; font-size:11px;" align="right">Total AR: <%=CommonUtil.formatFloat(dTotalDebit, true)%></td>
	</tr>
	
<%}//do not show if this is ar for other school fee.%>
  </table>
  
  
  
  

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9" align="center" style="font-weight:bold; font-size:16px;" valign="bottom" class="thinborderBOTTOM">CREDIT ENTRY</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(!bolIsAROthSchFeeTuition) {%>
    <tr>
      <td height="25" colspan="3" style="font-weight:bold; font-size:11px;"><u>Tuition</u></td>
    </tr>
<%}%>
	<tr>
	  <td height="22" style="font-weight:bold; font-size:11px;" width="20%">Account Number</td>
	  <td style="font-weight:bold; font-size:11px;" width="60%">Account Name</td>
	  <td style="font-weight:bold; font-size:11px;" align="right" width="20%">Amount</td>
	</tr>
	<%
	dTotalT = 0d; dTotalM = 0d; dTotalO = 0d;; dTotalH = 0d;
	vCreditEntry = (Vector)vARTuition.remove(0);
	for(int i = 0; i < vCreditEntry.size(); i += 4) {
	dTemp = Double.parseDouble((String)vCreditEntry.elementAt(i + 3));
	dTotalT += Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTemp, true), ",",""));%>
		<tr>
		  <td height="22"><%=vCreditEntry.elementAt(i + 1)%></td>
		  <td><%=vCreditEntry.elementAt(i + 2)%></td>
		  <td align="right"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		</tr>
	<%}%>
	<tr>
	  <td height="22" colspan="3" align="right" style="font-weight:bold; font-size:11px;">Total: <%=CommonUtil.formatFloat(dTotalT, true)%></td>
	</tr>
<%if(!bolIsAROthSchFeeTuition) {%>
    <tr>
      <td height="25" colspan="3" style="font-weight:bold; font-size:11px;"><u>Misc</u></td>
    </tr>
	<%
	vCreditEntry = (Vector)vARMisc.remove(0);
	for(int i = 0; i < vCreditEntry.size(); i += 4) {
	dTemp = Double.parseDouble((String)vCreditEntry.elementAt(i + 3));
	dTotalM += Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTemp, true), ",",""));%>
		<tr>
		  <td height="22"><%=vCreditEntry.elementAt(i + 1)%></td>
		  <td><%=vCreditEntry.elementAt(i + 2)%></td>
		  <td align="right"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		</tr>
	<%}%>
	<tr>
	  <td height="22" colspan="3" align="right" style="font-weight:bold; font-size:11px;">Total: <%=CommonUtil.formatFloat(dTotalM, true)%></td>
	</tr>
    <tr>
      <td height="25" colspan="3" style="font-weight:bold; font-size:11px;"><u>Other Charge</u></td>
    </tr>
	<%
	vCreditEntry = (Vector)vAROC.remove(0);
	for(int i = 0; i < vCreditEntry.size(); i += 4) {
	dTemp = Double.parseDouble((String)vCreditEntry.elementAt(i + 3));
	dTotalO += Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTemp, true), ",",""));%>
		<tr>
		  <td height="22"><%=vCreditEntry.elementAt(i + 1)%></td>
		  <td><%=vCreditEntry.elementAt(i + 2)%></td>
		  <td align="right"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		</tr>
	<%}%>
	<tr>
	  <td height="22" colspan="3" align="right" style="font-weight:bold; font-size:11px;">Total: <%=CommonUtil.formatFloat(dTotalO, true)%></td>
	</tr>
	<%if(vARHandsOn != null && vARHandsOn.size() > 0) {
		vCreditEntry = (Vector)vARHandsOn.remove(0); //System.out.println(vDebitEntry);
		if(vCreditEntry != null && vCreditEntry.size() > 0) {%>
			<tr>
			  <td height="25" colspan="3" style="font-weight:bold; font-size:11px;"><u>Computer HandsOn</u></td>
			</tr>
			<%
			for(int i = 0; i < vCreditEntry.size(); i += 4) {
			dTemp = Double.parseDouble((String)vCreditEntry.elementAt(i + 3));
			dTotalH += Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTemp, true), ",",""));%>
				<tr>
				  <td height="22"><%=vCreditEntry.elementAt(i + 1)%></td>
				  <td><%=vCreditEntry.elementAt(i + 2)%></td>
				  <td align="right"><%=CommonUtil.formatFloat(dTemp, true)%></td>
				</tr>
			<%}%>
			<tr>
			  <td height="22" colspan="3" align="right" style="font-weight:bold; font-size:11px;">Total: <%=CommonUtil.formatFloat(dTotalH, true)%></td>
			</tr>
	<%}
	}//only if handson is having data.
	dTotalCredit = dTotalT+dTotalM+dTotalO+dTotalH;%>
	<tr>
	  <td height="22" colspan="3" style="font-weight:bold; font-size:11px;" align="right">Total AR: <%=CommonUtil.formatFloat(dTotalCredit, true)%></td>
	</tr>
<%}%>
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
      <td width="1%" height="50">&nbsp;</td>
      <td width="10%" align="center">&nbsp;</td>
      <td width="76%" align="center" valign="bottom" style="font-size:18px;">
	  
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
      <td width="13%" align="center">&nbsp;</td>
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
<input type="hidden" name="post_verify">
<input type="hidden" name="is_basic"  value="<%=WI.fillTextValue("is_basic")%>">
<input type="hidden" name="is_postcharge"  value="<%=WI.fillTextValue("is_postcharge")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
