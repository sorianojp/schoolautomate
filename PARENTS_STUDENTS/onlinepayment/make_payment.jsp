<%
String strStudID    = (String)request.getSession(false).getAttribute("userId");
String strSYFrom    = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo      = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
String strSemester  = (String)request.getSession(false).getAttribute("cur_sem");


if(strStudID == null) {
%>
 <p style="font-size:14px; color:#FF0000;">You are already logged out. Please login again.</p>
<%return;}
%>
<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	if(WI.fillTextValue("sy_from").length() > 0) {
		strSYFrom    = WI.fillTextValue("sy_from");
		strSYTo      = WI.fillTextValue("sy_to");
		strSemester  = WI.fillTextValue("semester");
	}
	

	String strErrMsg = null;
	String strTemp   = null;
	String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};

//add security here.
	try
	{
		dbOP = new DBOperation();
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
String strConvertSem[] = {"Summer","First Term","Second Term","Third Term"};
boolean bolIsSYSet = false;
int iIndexOf = 0;

if(WI.fillTextValue("is_sy_set").equals("1"))
	bolIsSYSet = true;

Vector vUserInfo = null;
Vector vScheduledPmtNew = null;

int iEnrollStat = -2;// 0 = not enrolled, 1 = enrolled, 2 = enrolling, 3 = enrolled in advanced Sy-term.
String strSQLQuery = null;
boolean bolIsFatalErr = false; /// if true, do not proceed to payment.. 
//get to fatal err if iEnrollStat != 1 ---- 
OfflineAdmission offlineAdm = new OfflineAdmission();
onlinepayment.OnlinePayment op = new onlinepayment.OnlinePayment();

String strSAUserIndex = (String)request.getSession(false).getAttribute("userIndex");
boolean bolIsInActive = false;
strSQLQuery = "select IS_ACTIVE from ONLINE_PMT_USER_PROFILE where sa_user_index = "+strSAUserIndex; 
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery == null || strSQLQuery.equals("0"))
	bolIsInActive = true;

boolean bolPayDownpayment = false;

if( !bolIsInActive && WI.fillTextValue("amount_").length() > 0 && WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0 && WI.fillTextValue("pmt_method").length() > 0) {
	//I am all set to pay online.. 
	//get URL to forward.. 
	String strForwordURL = request.getRequestURL().toString();//"select PHP_SERVER_URL from ONLINE_PMT_INST_PROFILE";
	strTemp = request.getRequestURI();
	strForwordURL = strForwordURL.substring(0,strForwordURL.indexOf(strTemp));
	
	iIndexOf = strForwordURL.lastIndexOf(":");
	if(iIndexOf > 10)
		strForwordURL = strForwordURL.substring(0,iIndexOf);

	///code to replace the port.. 
	strSQLQuery = "select PHP_SERVER_URL from ONLINE_PMT_INST_PROFILE";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	strForwordURL = strForwordURL + strSQLQuery;//just have the last URL of php.. 
	
	
	//System.out.println(strForwordURL);
	//strForwordURL = dbOP.getResultOfAQuery(strForwordURL, 0);
	
	if(strForwordURL == null) {
		strErrMsg = "Instituion Information not yet set.";
	}
	else {
		String strCheckSum = op.initOnlinePayment(dbOP, request);
		if(strCheckSum == null) 
			strErrMsg = op.getErrMsg();
		else {
			String strURL = request.getRequestURL().toString();
			strTemp = request.getServletPath().toString();			
			strURL = strURL.substring(0,strURL.indexOf(strTemp) + 1);
			if(!op.createMySQLEntries(dbOP,strCheckSum, strURL)) 
				strErrMsg = op.getErrMsg();
			else {
    			strSAUserIndex = "update ONLINE_PMT_USER_PROFILE set IS_SYNC_GS = 1 where SA_USER_INDEX = "+strSAUserIndex;
				dbOP.executeUpdateWithTrans(strSAUserIndex, null, null, false);
				
				strForwordURL = strForwordURL + "?trans_ref="+strCheckSum;
				dbOP.cleanUP();
				//System.out.println(strForwordURL);
				response.sendRedirect(response.encodeURL(strForwordURL));
				return;
			}
		}
	}
}

if(bolIsSYSet) {
	vUserInfo = offlineAdm.getStudentBasicInfo(dbOP, strStudID);
	if(vUserInfo == null) 
		strErrMsg = offlineAdm.getErrMsg();
	else {///check if enrolled, or enrolled in advanced sy-term.
		//strSYFrom,strSemester = user intend to pay.. this sy-term must be either same or greater.. If less, than, not allowed.. 
		iEnrollStat = CommonUtil.compareSYTerm(strSYFrom, strSemester, (String)vUserInfo.elementAt(10), (String)vUserInfo.elementAt(9));
		if(iEnrollStat == 0)
			iEnrollStat = 1;
		else if(iEnrollStat == -1) //Error,, can't proceed to payment.. 
			iEnrollStat = 3;
		else
			iEnrollStat = 2;//may be enrolling.
		
		if(iEnrollStat == 2) {
			strSQLQuery = "select old_stud_appl_index from na_old_stud where user_index = "+vUserInfo.elementAt(12)+" and sy_from = "+strSYFrom+
							" and semester = "+strSemester+" and is_valid = 1";
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery == null)
				iEnrollStat = 0;
		}
	}
}
if(iEnrollStat == 0 || iEnrollStat == 2) {
	if(strErrMsg == null)
		strErrMsg = "You are not enrolled to selected SY-Term. Please check SY-Term OR Click Pay Downpayment to continue payment.";
	bolIsFatalErr = true;
	bolPayDownpayment = true;
}
else if(iEnrollStat == 3) {
	strErrMsg = "Failed to Proceed. Already enrolled in advance SY-Term. Please check SY-Term selected and last sy-term enrolled information.";
	bolIsFatalErr = true;
}
//if enrolling -- I just have to collect payment.

if(bolIsInActive){
	strErrMsg = "Failed to Proceed. Not allowed for online payment.";
	bolIsFatalErr = true;
}

//get payment sched and os balance information here.
double dOutStandingBal = 0d; double dRunningBal = 0d;
enrollment.FAFeeOperation fOperation  = new enrollment.FAFeeOperation();
enrollment.FAAssessment FA = new enrollment.FAAssessment();
//FAPaymentUtil pmtUtil = new FAPaymentUtil();
//FAPayment faPayment = new FAPayment();

String strPmtSchIndex = null;
long lTime = new java.util.Date().getTime();
if(iEnrollStat == 1) {
	vScheduledPmtNew = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vUserInfo.elementAt(12),strSYFrom, strSYTo,(String)vUserInfo.elementAt(14),strSemester);
	if(vScheduledPmtNew == null || vScheduledPmtNew.size() == 0) {
		strErrMsg = FA.getErrMsg();
		bolIsFatalErr = true;
	}
	else {
		dOutStandingBal = Double.parseDouble(ConversionTable.replaceString((String)vScheduledPmtNew.elementAt(6),",",""));
		strPmtSchIndex = (String)vScheduledPmtNew.elementAt(7);
		strPmtSchIndex = "select pmt_sch_index from fa_pmt_schedule where exam_name = '"+strPmtSchIndex+"' and is_valid > 0";
		strPmtSchIndex = dbOP.getResultOfAQuery(strPmtSchIndex, 0);
	}
}

String strServiceCharge = WI.fillTextValue("service_charge");
//get service charge.
if(strServiceCharge.length() == 0) {
	strSQLQuery = "select service_fee from ONLINE_PMT_INST_PROFILE";
	strServiceCharge = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strServiceCharge == null)
		strServiceCharge = "35";
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function SetSYTerm() {
	document.form_.is_sy_set.value = '1';
	
	objButton = document.getElementById('_setSY');
	objButton.disabled=true;
	
	objInProgress = document.getElementById("_setSYImg");
	objInProgress.style.visibility='visible';
	
	document.form_.amount_.value = '';
	document.form_.submit();
}
function ResetSYTerm() {
	document.form_.is_sy_set.value = '';
	document.form_.amount_.value = '';
	document.form_.is_downpayment.value='';
	document.form_.submit();
}
function Pay(strAmount,bolPayVariable,strAmountToDeduct) {
	if(bolPayVariable)
		strAmount = document.form_.variable_amt.value;
	if(strAmount.length == 0) {
		alert("Please enter valid amount");
		return;
	}
	if(eval(strAmount) < 100) {
		alert("Minimum allowed amount is Php100.00");
		return;
	}
	
	var iSelected = document.form_.pmt_method.selectedIndex;
	if(iSelected == 1) {
		if(document.form_.mobile_number.value.length == 0) {
			alert("Please enter mobile number for G-Cash Payment.");
			return;
		}
	}
	if(bolPayVariable) {
		strAmountToDeduct = eval(strAmount) + <%=strServiceCharge%>;
	}
	
	//if(!confirm('Please be reminded that a service charge of P<%=strServiceCharge%> will be charged by Bancnet to your payment.\r\n\r\nAmount P'+strAmount+' will be posted to student\'s account.\r\n\r\nAmount P'+strAmountToDeduct+' will be deducted from the ATM bank account used. \r\n\r\nClick Ok to Proceed'))
	//	return;
	if(!confirm('Please be reminded that a convenience and processing fee of PHP <%=strServiceCharge%> will be charged for this transaction.\r\n\r\nAmount P'+strAmount+' will be posted to student\'s account.\r\n\r\nAmount P'+strAmountToDeduct+' will be deducted from the ATM bank account used. \r\n\r\nClick Ok to Proceed'))
		return;
	document.form_.amount_.value = strAmount;
	
	var iMaxDisp = document.form_.max_disp.value;
	for(i = 0; i < iMaxDisp+1; ++i) {
		obj = document.getElementById("_"+i);
		if(!obj)
			continue;
		obj.disabled=true;
	}
	document.getElementById("_resetButton").disabled = true;
	
	document.getElementById("_setSYImg").style.visibility='visible';
	document.form_.submit();
}
function SetPmtMethod() {
	objMobile = document.getElementById("_mobile");

	if(document.form_.pmt_method.selectedIndex == 1)
		objMobile.style.visibility='visible';
	else
		objMobile.style.visibility='hidden';
	
}
function ViewDp() {
	window.open("http://fatima.edu.ph/content.asp?pid=283&cat=8");
}
</script>
<body>
<jsp:include page="./inc.jsp?pgIndex=3" />

<form name="form_" action="./make_payment.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#47768F"><div align="center"><font color="#FFFFFF"><strong>::::
      MAKE PAYMENT ::::</strong></font></div></td>
    </tr>
  </table>
<%
if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" style="font-weight:bold; color:#FF0000; font-size:18px;">Message: <%=strErrMsg%></td>
    </tr>
  </table>
<%}
if(!bolIsSYSet){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%" style="font-size:20px; font-weight:bold">SY-TERM</td>
      <td width="50%" height="25"> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox_bigfont" style="font-size:20px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
 <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox_bigfont" style="font-size:20px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester" style="font-size:20px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif">
         <option value="1">1st Term</option>
<%
if(strSemester.compareTo("2") ==0){%>
          <option value="2" selected>2nd Term</option>
<%}else{%>
          <option value="2">2nd Term</option>
<%}if(strSemester.compareTo("3") ==0){%>
          <option value="3" selected>3rd Term</option>
<%}else{%>
          <option value="3">3rd Term</option>
<%}if(strSemester.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
      </select>       
	  &nbsp;&nbsp;&nbsp;&nbsp;
	   <input type="button" name="12" value=" Proceed >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="SetSYTerm();" id="_setSY">
	   &nbsp;&nbsp;&nbsp;
	   <label id="_setSYImg" style="visibility:hidden;">
	   <img src="../../Ajax/ajax-loader_small_black.gif">
	   </label>
	   
      </td>
      <td width="35%" style="font-size:24px; font-weight:bold" align="right">&nbsp;</td>
    </tr>
  </table>
	
<%}else{

// 0 = not enrolled, 1 = enrolled, 2 = enrolling, 3 = enrolled in advanced Sy-term.
if(iEnrollStat == 0) 
	strTemp = "<font style='color=red'>Status: Not Enrolled</font>";
else if(iEnrollStat == 1) 
	strTemp = "Status: Enrolled";
else if(iEnrollStat == 2) 
	strTemp = "<font style='color=blue'>Status: Enrolling</font>";
else if(iEnrollStat == 3) 
	strTemp = "<font style='color=red'>Status: Enrolled In Prev. SY-Term</font>";
	
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="48%" height="25" style="font-size:20px; font-weight:bold"><%=strConvertSem[Integer.parseInt(strSemester)]%>, <%=strSYFrom%> - <%=strSYTo.substring(2)%>&nbsp;&nbsp;&nbsp;&nbsp;
	    <input type="button" name="12" value=" Reset SY-Term >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="ResetSYTerm();" id="_resetButton">      
		
		&nbsp;&nbsp;&nbsp;
	   <label id="_setSYImg" style="visibility:hidden;">
	   <img src="../../Ajax/ajax-loader_small_black.gif">
	   </label>
		
	  </td>
      <td width="50%" style="font-size:24px; font-weight:bold" align="right">
	  <%=strTemp%>
	  </td>
    </tr>
  </table>
<input type="hidden" name="sy_from" value="<%=strSYFrom%>">
<input type="hidden" name="sy_to" value="<%=strSYTo%>">
<input type="hidden" name="semester" value="<%=strSemester%>">
<%}if(vUserInfo != null && vUserInfo.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="39%" height="25">Student ID :<strong> <%=strStudID%></strong></td>
      <td width="59%" height="25"  colspan="4">Student Name: <strong><%=WI.formatName((String)vUserInfo.elementAt(0),(String)vUserInfo.elementAt(1),(String)vUserInfo.elementAt(2),4 )%></strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Last Enrolled SY-Term: <strong><%=strConvertSem[Integer.parseInt((String)vUserInfo.elementAt(9))]%>, <%=(String)vUserInfo.elementAt(10)%> - <%=((String)vUserInfo.elementAt(11)).substring(2)%></strong></td>
      <td  colspan="4">Last Enrolled Course-Yr: <b>
	  <%=(String)vUserInfo.elementAt(24)%><%=WI.getStrValue((String)vUserInfo.elementAt(25), " ", "","")%>
	  <%=WI.getStrValue((String)vUserInfo.elementAt(14), "-", "","")%>
	  </b>
	  </td>
    </tr>
  </table>
<%if(!bolIsFatalErr || bolPayDownpayment) {
	if(dOutStandingBal < 100d && false) {%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr>
			  <td style="font-weight:bold;font-size:16px;">Failed to Proceed to Online Payment. Low Outstanding Balance: <%=vScheduledPmtNew.elementAt(6)%></td>
			</tr>
		</table>
	<%}else{%>	
	
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
			  <td style="font-weight:bold;font-size:16px;">&nbsp;</td>
		  </tr>
			<tr>
			  <td style="font-weight:bold;font-size:16px;">Select a Payment Method: 
			  <select name="pmt_method" style="font-size:18px; font-weight:bold" onChange="SetPmtMethod();">
			  	<option value="0">Bancnet</option>
<%
strTemp = WI.fillTextValue("pmt_method");
if(strTemp.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%>
			  	<!--<option value="1"<%=strTemp%>>G-Cash</option>-->
			  </select>
			  &nbsp;&nbsp;&nbsp;&nbsp;
<%
strTemp = WI.fillTextValue("mobile_number");
if(strTemp.length() == 0) {
	strTemp = "select PAYER_PHONE from ONLINE_PMT_USER_PROFILE where SA_USER_INDEX = "+vUserInfo.elementAt(12);
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp == null)
		strTemp = "";
}
%>
			  <label style="visibility:hidden" id="_mobile">
			  Mobile Number: 
			  	 <input name="mobile_number" type="text" size="12" value="<%=strTemp%>" class="textbox" style="font-size:14px;" maxlength="11"
	  				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			  </label>
			  </td>
			</tr>
		</table>
		<%
		double dCumulativeBal = 0d; double dPay = 0d; int iCount = 0;
		if(vScheduledPmtNew != null && vScheduledPmtNew.size() > 0) {%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr bgcolor="#B9B292">
			  <td width="20%" height="25" align="center" bgcolor="#BECED3" class="thinborder"><strong><font size="1">PAYMENT SCHEDULE</font></strong></td>
			  <td width="20%" align="center" bgcolor="#BECED3" class="thinborder"><font size="1"><strong>REQUIRED AMOUNT</strong></font></td>
			  <td width="20%" bgcolor="#BECED3" class="thinborder" align="center"><font size="1"><strong>PAYABLE BALANCE</strong></font></td>
			  <td width="15%" bgcolor="#BECED3" class="thinborder" align="center"><font size="1"><strong>PAY</strong></font></td>
			</tr>
				<%
				if(vScheduledPmtNew == null)
					vScheduledPmtNew = new Vector();
					
				for(int i = 7; i < vScheduledPmtNew.size(); i += 2, ++iCount) {
				double dTemp = ((Double)vScheduledPmtNew.elementAt(i + 1)).doubleValue();
				if(dTemp < 0d) {
					if( (i + 3) <  vScheduledPmtNew.size()) {
						vScheduledPmtNew.setElementAt(new Double(((Double)vScheduledPmtNew.elementAt(i + 3)).doubleValue() + dTemp), i + 3);
					}
					dTemp = 0d;
					
				}
				dCumulativeBal += dTemp;
				if((i + 3) > vScheduledPmtNew.size() && dOutStandingBal != dCumulativeBal)
					dCumulativeBal = dOutStandingBal;
				
				dPay = dCumulativeBal;
				if(dPay < 1d) 
					dPay = 0d;
				%>
				<tr>
				  <td height="25" class="thinborder" style="font-size:18px;"><%=vScheduledPmtNew.elementAt(i)%></td>
				  <td align="right" class="thinborder" style="font-size:18px;"><%=CommonUtil.formatFloat(dTemp, true)%></td>
				  <td class="thinborder" align="right" style="font-size:18px;"><%=CommonUtil.formatFloat(dPay, true)%></td>
				  <td class="thinborder" align="center">
				  <%if(dPay > 0d) {
					strTemp = (String)vScheduledPmtNew.elementAt(i);
					iIndexOf = strTemp.indexOf(" ");
					if(iIndexOf > 0)
						strTemp = strTemp.substring(0, iIndexOf);
				  %>
					<input type="button" name="12" id="_<%=iCount%>" value=" Pay <%=strTemp%> " style="font-size:11px; height:28px;border: 1px solid #FF0000; width:100px; font-weight:bold" onClick="Pay('<%=CommonUtil.formatFloat(dPay, true)%>', false,'<%=CommonUtil.formatFloat(dPay+Integer.parseInt(strServiceCharge), true)%>');">
				  <%}else{%>
					&nbsp;
				  <%}%>
				  </td>
				</tr>
			<%}%>
		  </table>
	  <%}if(dPay > 0d || true){
	  if(bolPayDownpayment)
	  	dPay = 4500d;
	  
	  	if(dPay < 100d)
			dPay = 100d;%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
			  <td align="right">&nbsp;</td>
			  <td>&nbsp;</td>
		    </tr>
			<tr>
			  <td width="34%" align="right">
<%
strTemp = WI.fillTextValue("variable_amt");
if(strTemp.length() == 0) 
	strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(dPay, true), ",","");
%>
			  <input type="text" name="variable_amt" class="textbox_bigfont" style="font-size:22px;" size="12" value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  			onKeyUp="AllowOnlyChar(document.form_.variable_amt,'0123456789.');">&nbsp;&nbsp;&nbsp;</td>
			  <td width="66%">&nbsp;&nbsp;&nbsp;
			    <input type="button" name="122" id="_<%=++iCount%>" value=" Make <%if(bolPayDownpayment){%>Down<%}%>Payment " style="font-size:11px; height:32px;border: 1px solid #FF0000;font-weight: bold" onClick="document.form_.pmt_schedule.value='0';Pay('',true, '')">
			  <font style="font-size:9px;">
			  	<%if(bolPayDownpayment){%>
			  	(Note: Change amount and click Make DownPayment to pay required downpayment. <a href="javascript:ViewDp();"><font color="#0000FF" style="font-weight:bold">Click here to view required downpayment</font></a>)
				<%}else{%>
			  	(Note: change amount and click Make Payment to pay amount different from scheduled payment amount)
				<%}%>
			  </font>
			  </td>
			</tr>
			<tr>
			  <td colspan="2"><font style="font-size:12px; font-weight:bold; color:">
			  <u>Important Notice:</u><br>
<%if(bolPayDownpayment){%>
			  1. If Payment amount is less than required downpayment, advising will not be allowed.<br>
			  2. After succesful payment student may proceed to advising.<br>
			  3. In case of descrepancy, please proceed to sudent accounting office.
<%}else{%>
			  1. If Payment amount is less than examimation amount required, student may not get examination permit.<br>
			  2. After succesful payment student may print acknowledgement receipt for thier reference.<br>
			  3. Proceed to student ledger to reivew and verify after payment is successful.<br>
			  4. In case of descrepancy, please proceed to sudent accounting office.
<%}%>
			  </font></td>
		    </tr>
		  </table>
		<%}%>
		<input type="hidden" name="max_disp" value="<%=iCount%>">
	<%
	}
}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
      <td colspan="3" height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
<%} //only if basic info is not null;
%>
<input type="hidden" name="is_sy_set" value="<%=WI.fillTextValue("is_sy_set")%>">
<input type="hidden" name="amount_" value="">
	<input type="hidden" name="pmt_schedule" value="<%=WI.getStrValue(strPmtSchIndex)%>">
<input type="hidden" name="service_charge" value="<%=strServiceCharge%>">
<input type="hidden" name="is_downpayment" value="<%=WI.fillTextValue("is_downpayment")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>