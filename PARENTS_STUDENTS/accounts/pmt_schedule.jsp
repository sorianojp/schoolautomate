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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
	document.form_.submit();
}
function Pay(strAmount) {
	var iSelected = document.form_.pmt_method.selectedIndex;
	if(iSelected == 0) {
		alert("Please select paymet method (Bancnet/gcash)");
		return;
	}
	else if(iSelected == 2) {
		if(document.form_.mobile_number.value.length == 0) {
			alert("Please enter mobile number for G-Cash Payment.");
			return;
		}
	}
	if(!confirm('Are you sure you want to pay: '+strAmount+". Click Ok to Proceed."))
		return;
	document.form_.amount_.value = strAmount;
	
	var iMaxDisp = document.form_.max_disp.value;
	for(i = 0; i < iMaxDisp; ++i) {
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

	if(document.form_.pmt_method.selectedIndex == 2)
		objMobile.style.visibility='visible';
	else
		objMobile.style.visibility='hidden';
	
}
</script>
<body bgcolor="#9FBFD0">
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
String strConvertSem[] = {"Summer","First Term","Second Term","Third Term", "Fourth Term","Fifth Term"};
boolean bolIsSYSet = false;
//if(WI.fillTextValue("is_sy_set").equals("1")) == Open it later.
	bolIsSYSet = true;

Vector vUserInfo = null;
Vector vScheduledPmtNew = null;

int iEnrollStat = 0;// 0 = not enrolled, 1 = enrolled, 2 = enrolling, 3 = enrolled in advanced Sy-term.
String strSQLQuery = null;
boolean bolIsFatalErr = false; /// if true, do not proceed to payment.. 
//get to fatal err if iEnrollStat != 1 ---- 
	
OfflineAdmission offlineAdm = new OfflineAdmission();
if(bolIsSYSet) {
	vUserInfo = offlineAdm.getStudentBasicInfo(dbOP, strStudID);
	if(vUserInfo == null) 
		strErrMsg = offlineAdm.getErrMsg();
	else {///check if enrolled, or enrolled in advanced sy-term.
		//strSYFrom,strSemester = user intend to pay.. this sy-term must be either same or greater.. If less, than, not allowed.. 
		//0 = equal, 1 = syFrom > vUserInfo (enrolled in previous sy-term), -1 = syFrom < vUserInfo( enrolled in advance sy)
		iEnrollStat = CommonUtil.compareSYTerm(strSYFrom, strSemester, (String)vUserInfo.elementAt(10), (String)vUserInfo.elementAt(9));
		//System.out.println("iEnrollStat: "+iEnrollStat);
		if(iEnrollStat == 1)
			iEnrollStat = 0;
		else if(iEnrollStat == 0)
			iEnrollStat = 1;
		else if(iEnrollStat == -1) {
			iEnrollStat = 3;
			//strSYFrom = (String)vUserInfo.elementAt(10);
			//strSYTo = Integer.toString(Integer.parseInt(strSYFrom) + 1);
			//strSemester = (String)vUserInfo.elementAt(9);
		}
		//else
		//	iEnrollStat = 2;//may be enrolling.
		
		if(iEnrollStat == 1) {
			strSQLQuery = "select old_stud_appl_index from na_old_stud where user_index = "+vUserInfo.elementAt(12)+" and sy_from = "+strSYFrom+
							" and semester = "+strSemester+" and is_valid = 1";
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null)
				iEnrollStat = 2;
		}
	}
}
if(iEnrollStat == 0) {
	strErrMsg = "Failed to Proceed. Not Enrolled, Please check SY-Term selected.";
	bolIsFatalErr = true;
}
//else if(iEnrollStat == 3) {
//	strErrMsg = "Failed to Proceed. Already enrolled in advance SY-Term. Please check SY-Term selected and last sy-term enrolled information.";
//	bolIsFatalErr = true;
//}
//if enrolling -- I just have to collect payment.

//get payment sched and os balance information here.
double dOutStandingBal = 0d; double dRunningBal = 0d;
enrollment.FAFeeOperation fOperation  = new enrollment.FAFeeOperation();
enrollment.FAAssessment FA = new enrollment.FAAssessment();
//FAPaymentUtil pmtUtil = new FAPaymentUtil();
//FAPayment faPayment = new FAPayment();
long lTime = new java.util.Date().getTime();
if(iEnrollStat == 1 || iEnrollStat == 3) {
	vScheduledPmtNew = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vUserInfo.elementAt(12),(String)vUserInfo.elementAt(10), 
						(String)vUserInfo.elementAt(11),(String)vUserInfo.elementAt(14),(String)vUserInfo.elementAt(9));
	if(vScheduledPmtNew == null || vScheduledPmtNew.size() == 0) {
		strErrMsg = FA.getErrMsg();
		bolIsFatalErr = true;
	}
	else {
		dOutStandingBal = Double.parseDouble(ConversionTable.replaceString((String)vScheduledPmtNew.elementAt(6),",",""));
	}

}
else {

}
if(vScheduledPmtNew == null)
	vScheduledPmtNew = new Vector();

%>
<form name="form_" action="./pmt_schedule.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#47768F"><div align="center"><font color="#FFFFFF"><strong>::::
      PAYMENT SCHEDULE ::::</strong></font></div></td>
    </tr>
  </table>
<%
if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" style="font-weight:bold; color:#FF0000; font-size:16px;">Failed to Proceed ==> (Message): <%=strErrMsg%></td>
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
	strTemp = "<font style='color=red'>Status: Enrolled In Advance SY-Term</font>";
	
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="48%" height="25" style="font-size:20px; font-weight:bold"><%=strConvertSem[Integer.parseInt(strSemester)]%>, <%=strSYFrom%> - <%=strSYTo.substring(2)%>&nbsp;&nbsp;&nbsp;&nbsp;
	    <!--<input type="button" name="12" value=" Reset SY-Term >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="ResetSYTerm();" id="_resetButton">-->      
		
		&nbsp;&nbsp;&nbsp;
	   <label id="_setSYImg" style="visibility:hidden;">
	   <img src="../../Ajax/ajax-loader_small_black.gif">
	   </label>
		
	  </td>
      <td width="50%" style="font-size:24px; font-weight:bold" align="right">
	  <%=WI.getStrValue(strTemp)%>
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
<%if(!bolIsFatalErr) {%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
			  <td style="font-weight:bold;font-size:16px;">&nbsp;</td>
		  </tr>
		</table>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr bgcolor="#B9B292">
		  <td width="15%" height="25" align="center" bgcolor="#BECED3" class="thinborder"><strong><font size="1">PAYMENT SCHEDULE</font></strong></td>
		  <td width="40%" align="center" bgcolor="#BECED3" class="thinborder"><font size="1"><strong>REQUIRED AMOUNT</strong></font></td>
		  <td width="15%" bgcolor="#BECED3" class="thinborder" align="center"><font size="1"><strong>CUMULATIVE BALANCE</strong></font></td>
	    </tr>
			<%
			double dCumulativeBal = 0d; double dPay = 0d; int iCount = 0;
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
		    </tr>
		<%}%>
		<input type="hidden" name="max_disp" value="<%=iCount%>">
	  </table>
<%}else if(dOutStandingBal > 0d) {%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
			  <td style="font-weight:bold;font-size:16px;">Total Outstanding Balance: <%=CommonUtil.formatFloat(dOutStandingBal, true)%></td>
		  </tr>
		</table>
<%}%>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>