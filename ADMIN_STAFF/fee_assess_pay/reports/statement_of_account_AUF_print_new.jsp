<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
}

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
var closeWnd ="";
function CloseWnd() {
	if(closeWnd == 1)
		window.setTimeout("javascript:window.close();", 2000);
}
function ChangeName(labelID) {
	strName = prompt('Please enter new value','');
	if(strName == null || strName.length == 0)
		return;
	document.getElementById(labelID).innerHTML = strName;
}
</script>
<body onLoad="CloseWnd();" topmargin="0" leftmargin="20" rightmargin="0">
<%@ page language="java" import="utility.*,EnrlReport.StatementOfAccount,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","statement_of_account.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"statement_of_account.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vStudInfo     = null;
Vector vMiscFeeInfo  = null;
Vector vTemp         = null;
Vector vScheduledPmt = null;
Vector vSubjectDtls  = null;

double dDebit = 0d; double dTotalDebit = 0d;
double dBalance = 0d;
double dTemp = 0d;

Vector vTuitionFeePaymentDtls = null;

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

//use the leder to get all details.
enrollment.FAStudentLedger faStudLedg = new enrollment.FAStudentLedger();
Vector vLedgerInfo = null;

Vector vTimeSch = null;
Vector vAdjustment = null;
Vector vRefund = null;
Vector vDorm = null;
Vector vOthSchFine = null;
Vector vPayment = null;
Vector vTuitionFeeDetail = null;
///////////// end of using ledger to get all information.


StatementOfAccount SOA = new StatementOfAccount();


vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
					WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
if(vStudInfo == null) strErrMsg = enrlStudInfo.getErrMsg();
else
{
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
//	else {//do not display misc fee detail
//		vMiscFeeInfo = new Vector();//new design
//	}
}
if(strErrMsg == null) {//collect fee details here.
	vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vStudInfo.elementAt(0),request.getParameter("sy_from"),
	request.getParameter("sy_to"),null,request.getParameter("semester"), false);//bolShowOnlyDroppedSub=false
	if(vLedgerInfo == null)
		strErrMsg = faStudLedg.getErrMsg();
	else
	{//System.out.println( (new java.util.Date().getTime() - lTime)/1000);
		vTimeSch 			= (Vector)vLedgerInfo.elementAt(0);
		vTuitionFeeDetail	= (Vector)vLedgerInfo.elementAt(1);
		vAdjustment			= (Vector)vLedgerInfo.elementAt(2);
		vRefund				= (Vector)vLedgerInfo.elementAt(3);
		vDorm 				= (Vector)vLedgerInfo.elementAt(4);
		vOthSchFine			= (Vector)vLedgerInfo.elementAt(5);//System.out.println(vOthSchFine);
		vPayment			= (Vector)vLedgerInfo.elementAt(6);
		if(vTimeSch == null || vTimeSch.size() ==0)
			strErrMsg = faStudLedg.getErrMsg();
	}
}
//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null)
{
//it will set the assessed hour and assesed units -- it is an easier way to set.
	fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),false,WI.fillTextValue("sy_from"),
					WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

	//get misc fee.
	fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	//the above method set the laboratory deposit information. so i have to call.

	vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(vTemp == null)
		strErrMsg = paymentUtil.getErrMsg();
	else
		vMiscFeeInfo.addAll(vTemp);
	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");
	}
}

if(strErrMsg == null && WI.fillTextValue("pmt_schedule").length() > 0)
{
	vScheduledPmt = FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(vScheduledPmt == null)
		strErrMsg = FA.getErrMsg();
}
String strPrintedBy = CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1);
if(strErrMsg == null)
{
	vSubjectDtls = SOA.getEnrolledSubSummary(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                      WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vSubjectDtls == null || vSubjectDtls.size() ==0)
		strErrMsg = SOA.getErrMsg();
	vTuitionFeePaymentDtls = SOA.getTuitionFeeDetailForSA(dbOP, (String)vStudInfo.elementAt(0),
								WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	//System.out.println(vScheduledPmt);
}

if(strErrMsg == null) strErrMsg = "";

String strPmtScheduleName  = null;

if(WI.fillTextValue("pmt_schedule").length() > 0)
	strPmtScheduleName = dbOP.mapOneToOther("FA_PMT_SCHEDULE","pmt_sch_index",WI.fillTextValue("pmt_schedule"),"exam_name",null);

strPmtScheduleName  = WI.getStrValue(strPmtScheduleName);



String[] astrConvertYrLevel = {"",",1st Year",",2nd Year",",3rd Year",",4th Year",",5th Year",",6th Year",",7th Year"};
String[] astrConvertSem     = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
//System.out.println(fOperation.fTotalAssessedHour);
if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="2"><strong><%=strErrMsg%></strong></font></td>
    </tr>
  </table>
<%}

 if(vStudInfo != null && vStudInfo.size() > 0)
 {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="3"><%=WI.getTodaysDate(6)%><br>&nbsp;</td>
  </tr>
  <tr>
    <td colspan="3"><font size="2">&nbsp;</font></td>
  </tr>
  <tr>
    <td colspan="3"><font style="font-size:16px;">STATEMENT OF TUITION FEES AND OTHER CHARGES </font></td>
  </tr>
  <tr>
    <td colspan="3" align="center">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="3"><font size="3">
	<%if(((String)vStudInfo.elementAt(13)).startsWith("M")){%>MR.<%}else{%>MS.<%}%> <%=WebInterface.formatName((String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11),
	  	(String)vStudInfo.elementAt(12),6).toUpperCase()%></font></td>
  </tr>
  <tr>
    <td colspan="3"><font size="3"><%=(String)vStudInfo.elementAt(16)%> <%
	  if(vStudInfo.elementAt(3) != null){%>
      - <%=(String)vStudInfo.elementAt(3)%> <%}%>
	  <%=WI.getStrValue((String)vStudInfo.elementAt(4), " - ", "","")%></font></td>
  </tr>
  <tr>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="3" align="left">
		<table width="95%" cellpadding="0" cellspacing="0" border="0">
		  <tr>
		    <td colspan="2"><u>Breakdown of Fees <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%> AY <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%></u></td>
		    <td align="right">&nbsp;</td>
		    <td align="right"><u>AMOUNT</u></td>
		    <td>&nbsp;</td>
	      </tr>
		  <tr>
		    <td colspan="2">&nbsp;</td>
		    <td align="right">&nbsp;</td>
		    <td align="right">&nbsp;</td>
		    <td>&nbsp;</td>
	      </tr>
		  <tr>
			<td colspan="2">Tuition Fee</td>
			<td width="12%" align="right">&nbsp;</td>
			<td width="17%" align="right"> <%
		dDebit = ((Double)vTuitionFeeDetail.elementAt(1)).doubleValue();
		dBalance += dDebit;
		%>
			  <%=CommonUtil.formatFloat((float)dDebit,true)%> </td>
		    <td width="24%">&nbsp;</td>
		  </tr>
		  <tr>
			<td colspan="2">Miscellaneous Fee</td>
			<td>&nbsp;</td>
			<td align="right">
			  <%
		dDebit = ((Double)vTuitionFeeDetail.elementAt(2)).doubleValue();
		dBalance += dDebit;
		%>
			  <%=CommonUtil.formatFloat((float)dDebit,true)%></td>
		    <td>&nbsp;</td>
		  </tr>
		  <%
		dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();

		if(dDebit > 0d){
		dBalance += dDebit;
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
				continue;
			}
			%>
		  <tr>
			<td colspan="2"><%=(String)vMiscFeeInfo.elementAt(i)%></td>
			<td>&nbsp;</td>
			<td align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
		    <td>&nbsp;</td>
		  </tr>
		  <%}//end of for loop.
		}//end of if dDebit > 0d
		//show hands on.
		dDebit = ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
		if(dDebit > 0d){
		dBalance += dDebit;
		%>
		  <!-- HANDS ON -->
		  <tr>
			<td colspan="2">Hands On</td>
			<td>&nbsp;</td>
			<td align="right"><%=CommonUtil.formatFloat((float)dDebit,true)%></td>
		    <td>&nbsp;</td>
		  </tr>
		  <%}
		//show now all the other facilities taken by student like internet card - printing etc.
		dDebit = ((Double)vOthSchFine.elementAt(0)).doubleValue();

		if(dDebit > 0d){
		dBalance += dDebit;
		for(int i = 1; i< vOthSchFine.size(); i +=3) {%>
		  <tr>
			<td colspan="2"><%=(String)vOthSchFine.elementAt(i)%></td>
			<td>&nbsp;</td>
			<td align="right"><%=CommonUtil.formatFloat((String)vOthSchFine.elementAt(i+1),true)%></td>
		    <td>&nbsp;</td>
		  </tr>
		  <%}
		}%>
		  <tr>
			<td colspan="2">&nbsp;</td>
			<td>&nbsp;</td>
			<td><img src='./singleline.jpg'></td>
		    <td>&nbsp;</td>
		  </tr>
		  <tr>
			<td height="10" colspan="2">Total Charges </td>
			<td height="10">&nbsp;</td>
			<td height="10" align="right"><%=CommonUtil.formatFloat((float)dBalance,true)%><!--<br>
			<img src="./doubleline.jpg">--></td>
		    <td height="10">&nbsp;</td>
		  </tr>
<%if(false){%>
		  <tr>
			<td height="10" colspan="2">Back Account</td>
			<td height="10">&nbsp;</td>
			<td height="10" align="right"> <%
		dDebit = ((Double)vTuitionFeeDetail.elementAt(0)).doubleValue();
		dBalance += dDebit;
		%>
			  <%=CommonUtil.formatFloat((float)dDebit,true)%> </td>
		    <td height="10">&nbsp;</td>
		  </tr>
<%}%>
		  <tr>
			<td height="10" colspan="2">&nbsp;</td>
			<td height="10">&nbsp;</td>
			<td height="10" colspan="2">&nbsp;</td>
		  </tr>
<!--
		  <tr>
			<td colspan="2">TOTAL CHARGES</td>
			<td align="right"><font size="2">P</font></td>
			<td align="right"><font size="2"><%=CommonUtil.formatFloat((float)dBalance,true)%></font></td>
		    <td>&nbsp;</td>
		  </tr>
		  <tr>
			<td colspan="2">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2">&nbsp;</td>
		  </tr>
-->
		  <tr>
			<td colspan="2">Less : Payment</td>
			<td>&nbsp;</td>
			<td colspan="2">&nbsp;</td>
		  </tr>
		  <%
		if(vPayment != null && vPayment.size() > 0){
			for(int i = 0; i < vPayment.size(); i += 6){
		dDebit = Double.parseDouble((String)vPayment.elementAt(i));
		dTemp += dDebit;
			%>
		  <tr>
			<td width="2%">&nbsp;</td>
			<td width="45%"><%=ConversionTable.convertMMDDYYYY((java.util.Date)vPayment.elementAt(i + 2))%>&nbsp;&nbsp;&nbsp; <%
		//refund is called also.
		if(	vPayment.elementAt(i + 1) == null) {%> <%=(String)vPayment.elementAt(i + 3)%> <%}else{%> OR# <%=(String)vPayment.elementAt(i + 1)%> <%}%> </td>
			<td align="right"><%=CommonUtil.formatFloat(dDebit,true)%><%dTotalDebit += dDebit;%></td>
			<td align="right">&nbsp;</td>
		    <td>&nbsp;</td>
		  </tr>
		  <%}//end of for loop
		dBalance -= dTemp;//end of for loop
		}//end of if condition for payment detail with OR.
		 //show enrollment discount if there is any.
		 if(vTuitionFeeDetail.elementAt(5) != null){
		dDebit = ((Double)vTuitionFeeDetail.elementAt(5)).doubleValue();
		dBalance -= dDebit;
		%>
		  <tr>
			<td>&nbsp;</td>
			<td><%=vTuitionFeeDetail.elementAt(6)%></td>
			<td align="right"><%=CommonUtil.formatFloat(dDebit,true)%><%dTotalDebit += dDebit;%></td>
			<td align="right">&nbsp;</td>
		    <td>&nbsp;</td>
		  </tr>
		  <%}
		//show here grant / adjustmnet details.
		if(vAdjustment != null && vAdjustment.size() > 1){
		int iIndex = 0;
			for(int i = 1; i < vAdjustment.size(); i += 7) {

		dDebit = Double.parseDouble((String)vAdjustment.elementAt(i + 1));
		dBalance -= dDebit;
		strTemp = (String)vAdjustment.elementAt(i);
		iIndex = strTemp.indexOf(":::");
		strTemp = strTemp.substring(0,iIndex);
		%>
		  <tr>
			<td>&nbsp;</td>
			<td><%=strTemp%></td>
			<td align="right"><%=CommonUtil.formatFloat(dDebit,true)%><%dTotalDebit += dDebit;%></td>
			<td align="right">&nbsp;</td>
		    <td>&nbsp;</td>
		  </tr>
		  <%}
		  }
		//now get refund.
		for(int i = 0; i < vRefund.size() ; i += 4) {
			dDebit = Double.parseDouble((String)vRefund.elementAt(i + 2));
			dBalance += dDebit;
		%>
		  <tr>
			<td>&nbsp;</td>
			<td><%=WI.getStrValue(vRefund.elementAt(i + 1))%> (Refund)</td>
			<td align="right"><%=CommonUtil.formatFloat(dDebit,true)%><%dTotalDebit += dDebit;%></td>
			<td align="right">&nbsp;</td>
		    <td>&nbsp;</td>
		  </tr>
		<%}//end of displaying refund.%>
		  <tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td align="right"><%=CommonUtil.formatFloat(dTotalDebit,true)%></td>
		    <td align="right">&nbsp;</td>
		  </tr>
		  <tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2" align="right"><img src="./singleline.jpg" width="225"></td>
		    <td>&nbsp;</td>
		  </tr>
		  <tr>
			<td colspan="2"><font size="2">BALANCE</font></td>
			<td align="right">&nbsp;</td>
			<td align="right"><font size="2"><%=CommonUtil.formatFloat((float)dBalance,true)%></font></td>
		    <td>&nbsp;</td>
		  </tr>
		  <tr>
		    <td colspan="2">&nbsp;</td>
		    <td align="right">&nbsp;</td>
		    <td colspan="2"><img src="./doubleline.jpg"></td>
	      </tr>
				</table>	</td>
  </tr>
  <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();

if(dDebit > 0d){
dBalance += dDebit;
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		continue;
	}
	%>
  <%}//end of for loop.
}//end of if dDebit > 0d
//show hands on.
dDebit = ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
if(dDebit > 0d){
dBalance += dDebit;
%>
  <!-- HANDS ON -->
  <%}
//show now all the other facilities taken by student like internet card - printing etc.
dDebit = ((Double)vOthSchFine.elementAt(0)).doubleValue();

if(dDebit > 0d){
dBalance += dDebit;
for(int i = 1; i< vOthSchFine.size(); i +=3) {%>
  <%}
}%>
  <%
if(vPayment != null && vPayment.size() > 0){
	for(int i = 0; i < vPayment.size(); i += 6){
dDebit = Double.parseDouble((String)vPayment.elementAt(i));
dTemp += dDebit;
	%>
  <%}//end of for loop
dBalance -= dTemp;//end of for loop
}//end of if condition for payment detail with OR.
 //show enrollment discount if there is any.
 if(vTuitionFeeDetail.elementAt(5) != null){
dDebit = ((Double)vTuitionFeeDetail.elementAt(5)).doubleValue();
dBalance -= dDebit;
%>
  <%}
//show here grant / adjustmnet details.
if(vAdjustment != null && vAdjustment.size() > 1){
int iIndex = 0;
	for(int i = 1; i < vAdjustment.size(); i += 7) {

dDebit = Double.parseDouble((String)vAdjustment.elementAt(i + 1));
dBalance -= dDebit;
strTemp = (String)vAdjustment.elementAt(i);
iIndex = strTemp.indexOf(":::");
strTemp = strTemp.substring(0,iIndex);
%>
  <%}
  }
//now get refund.
for(int i = 0; i < vRefund.size() ; i += 4) {
	dDebit = Double.parseDouble((String)vRefund.elementAt(i + 2));
	dBalance += dDebit;
%>
<%}//end of displaying refund.%>
  <tr>
    <td width="40%"><font size="2">&nbsp;</font></td>
    <td width="24%"><font size="2">&nbsp;</font></td>
    <td width="36%">&nbsp;</td>
  </tr>
  <tr>
    <td><font size="2">&nbsp;</font></td>
    <td><font size="2">&nbsp;</font></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>Prepared By </td>
    <td><font size="2">&nbsp;</font></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td><font size="2">&nbsp;</font></td>
    <td><font size="2">&nbsp;</font></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td><font size="2">&nbsp;</font></td>
    <td><font size="2">&nbsp;</font></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td colspan="3"></td>
  </tr>
  <tr>
    <td><label id="head_acc_pos" onClick="ChangeName('head_acc_pos');">Head, Accounts Management</label></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<script language="JavaScript">
//get this from common.js
this.autoPrint();

//closeWnd = 1;
</script>
<%
	}//only if student information is found.
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
