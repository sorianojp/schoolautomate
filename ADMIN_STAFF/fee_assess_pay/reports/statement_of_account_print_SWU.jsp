<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">

/*
@page {
	size:8in 3.70in; 
	margin:.1in 0in 0in 0in; 
}
@media print { 
  @page {
		size:8in 3.70in; 
		margin:.1in 0in 0in 0in; 
	}
}
*/
<!--

@media print { 
  @page {
		margin-top:0in;
		margin-bottom:0in;
	}
}

body {
	font-family: Arial;
	font-size: 11px;
}

td {
	font-family: Arial;
	font-size: 11px;
}

th {
	font-family: Arial;
	font-size: 11px;
}

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
var closeWnd ="";
function CloseWnd() {
	if(closeWnd == 1)
		window.setTimeout("javascript:window.close();", 6000);
}
</script>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,EnrlReport.StatementOfAccount,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector,java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strSchoolCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchoolCode == null)
		strSchoolCode = "";
	
	java.sql.ResultSet rs  =null;
	
	

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

boolean bolIsBasic = false;



//end of authenticaion code.
Vector vStudInfo     = null;
//Vector vMiscFeeInfo  = null;
//Vector vTemp         = null;
//Vector vScheduledPmt = null;
//Vector vSubjectDtls  = null;

int iIndex = 0;
double dDebit = 0f;
double dBalance = 0d;
double dTemp = 0d;
double dCredit = 0d;

String strTransDate = "";
String strDownpaymentORNumber = "";
String strDownpaymentDate = "";

//float fDownpayment   = 0f;
float fTotalDiscount = 0f;

double dDownpayment  = 0d;
Vector vDPInfo = new Vector();//[0] OR number, and [1] date paid. 

//Vector vTuitionFeePaymentDtls = null;

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
Vector vDiscountDtls = null;

String strDiscountName = null;
StatementOfAccount SOA = new StatementOfAccount();


vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
					WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));



if(vStudInfo == null)
	strErrMsg = enrlStudInfo.getErrMsg();
else {
	if(((String)vStudInfo.elementAt(5)).equals("0") ) {
		bolIsBasic = true;
		FA.setIsBasic(true);
	}

//	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
//        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
//        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
//        WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
//	if(vMiscFeeInfo == null)
//		strErrMsg = paymentUtil.getErrMsg();
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
	
	//fDownpayment   = fOperation.calAmoutPaidDurEnrollment(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
   //     				WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
						
	fTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),null);
							
	strTemp = " select or_number, date_paid,amount from fa_stud_payment where user_index = "+
				(String)vStudInfo.elementAt(0)+" and sy_from = "+WI.fillTextValue("sy_from")+
				" and semester = "+WI.fillTextValue("semester")+
				" and is_valid = 1  and pmt_sch_index = 0 and amount > 0 and payment_for = 0 ";
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		vDPInfo.addElement(rs.getString(1));//[0] or_number
		vDPInfo.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(2)));//[1] date_paid
		vDPInfo.addElement(CommonUtil.formatFloat(rs.getDouble(3), true));//[3] Amount paid. 	
		dDownpayment += rs.getDouble(3);	
	}
	rs.close();
	
	if(fTotalDiscount > 0f) {
			strTemp = "select grant_name, discount_amt from FA_FEE_HISTORY_GRANTS where USER_INDEX = "+(String)vStudInfo.elementAt(0)+
						" and SY_FROM = "+WI.fillTextValue("sy_from")+" and SEMESTER = "+WI.fillTextValue("semester");
			rs = dbOP.executeQuery(strTemp);
			vDiscountDtls = new Vector();
			while(rs.next()) {
				vDiscountDtls.addElement(rs.getString(1));
				vDiscountDtls.addElement(rs.getString(2));
			}
			rs.close();	
	
			/*strDiscountName = "select MAIN_TYPE_NAME, SUB_TYPE_NAME1,SUB_TYPE_NAME2,SUB_TYPE_NAME3,SUB_TYPE_NAME4,SUB_TYPE_NAME5 "+
				" from FA_STUD_PMT_ADJUSTMENT  "+
				"join FA_FEE_ADJUSTMENT on (FA_FEE_ADJUSTMENT.fa_fa_index = FA_STUD_PMT_ADJUSTMENT.fa_fa_index) " +
				" where USER_INDEX = "+vStudInfo.elementAt(0)+
				" and FA_STUD_PMT_ADJUSTMENT.sy_from = "+WI.fillTextValue("sy_from")+
				" and FA_STUD_PMT_ADJUSTMENT.semester = "+WI.fillTextValue("semester")+
				" and FA_STUD_PMT_ADJUSTMENT.is_valid = 1";			
			rs = dbOP.executeQuery(strDiscountName);
			strDiscountName = null;
			while(rs.next()) {
				strTemp = rs.getString(1);
				if(rs.getString(2) != null)
					strTemp = strTemp + ": "+rs.getString(2);
				if(rs.getString(3) != null)
					strTemp = strTemp +": "+rs.getString(3);
				if(rs.getString(4) != null)
					strTemp = strTemp +": "+rs.getString(4);
				if(rs.getString(5) != null)
					strTemp = strTemp +": "+rs.getString(5);
				if(rs.getString(6) != null)
					strTemp = strTemp +": "+rs.getString(6);
					
				if(strDiscountName == null)
					strDiscountName = WI.getStrValue(strTemp,"DISCOUNTS(",")","");
				else	
					strDiscountName += WI.getStrValue(strTemp,"<br>DISCOUNTS(",")","");
			}rs.close();*/
		}

		
	
}

//if no error, get the misc fee details having hands on without computer subjects.
//if(strErrMsg == null)
//{
//it will set the assessed hour and assesed units -- it is an easier way to set.
//	fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),false,WI.fillTextValue("sy_from"),
//					WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
//
//	//get misc fee.
//	fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),false,
//					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	//the above method set the laboratory deposit information. so i have to call.

	//vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
//					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
//	if(vTemp == null)
//		strErrMsg = paymentUtil.getErrMsg();
//	else
//		vMiscFeeInfo.addAll(vTemp);
//	if(fOperation.getLabDepositAmt() > 0f)
//	{
//		vMiscFeeInfo.addElement("Laboratory Deposit");
//		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
//		vMiscFeeInfo.addElement("1");
//	}
//}
//
//if(strErrMsg == null)
//{
//	vScheduledPmt = FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
//        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
//	if(vScheduledPmt == null)
//		strErrMsg = FA.getErrMsg();
//}
//String strPrintedBy = CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1);
//if(strErrMsg == null)
//{
//	vSubjectDtls = SOA.getEnrolledSubSummary(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
//                                      WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
//	if(vSubjectDtls == null || vSubjectDtls.size() ==0)
//		strErrMsg = SOA.getErrMsg();
//	vTuitionFeePaymentDtls = SOA.getTuitionFeeDetailForSA(dbOP, (String)vStudInfo.elementAt(0),
//								WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
//	System.out.println(vScheduledPmt);
//}

if(strErrMsg == null) strErrMsg = "";




String[] astrConvertYrLevel = {"",",1st Year",",2nd Year",",3rd Year",",4th Year",",5th Year",",6th Year",",7th Year"};
String[] astrConvertSem     = {"Summer","1ST SEMESTER","2ND SEMESTER","3RD SEMESTER","4TH SEMESTER","5TH SEMESTER"};
//System.out.println(fOperation.fTotalAssessedHour);;
if(strErrMsg != null && strErrMsg.length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
  </table>
<%}
int iPageCount = 1;
int iRowCount = 1;
int iMaxRowCount = 10;
int i = 0;
strTemp = (String)request.getSession(false).getAttribute("swu_page_counter");
int iCount = 0;
boolean bolShowPageCount = false;
if(strTemp != null && strTemp.length() > 0 && WI.fillTextValue("batch_print").length() > 0){
	bolShowPageCount = true;
	iCount = Integer.parseInt(WI.getStrValue(strTemp,"0"));	
}
boolean bolIsPageBreak = false;
if(vStudInfo != null && vStudInfo.size() > 0){
boolean bolHasElement = true;
while(true){

iRowCount = 4;
if(bolShowPageCount)
	iRowCount = 5;
%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%if(bolShowPageCount){%><tr><td><%=++iCount%></td></tr><%}%>
	<tr><td align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td></tr>
	<tr><td align="center"><%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false),"&nbsp;")%></td></tr>	
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<%
		strTemp = WebInterface.formatName((String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11),(String)vStudInfo.elementAt(12),4);
		%>
	  <td height="20" valign="bottom" width="39%">&nbsp; &nbsp;<%=WI.getStrValue(strTemp).toUpperCase()%></td>
	  <td valign="bottom" width="35%">&nbsp; &nbsp;<%=((String)vStudInfo.elementAt(16)).toUpperCase()%> 
	  <%=WI.getStrValue((String)vStudInfo.elementAt(4), " - ","","")%></td>
	  <td valign="bottom" width="26%">&nbsp; &nbsp;<%=WI.fillTextValue("stud_id")%></td>
	</tr>
	<%
	if(Integer.parseInt(WI.fillTextValue("semester")) == 0)
		strTemp = WI.fillTextValue("sy_to");
	else
		strTemp = WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to");
	%>
	<tr><td colspan="3" align="center" valign="bottom" height="18"><%if(!bolIsBasic){%><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%><%}%>
		&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
        <%=strTemp%></td></tr>
</table> 


<table width="100%"  border="0" cellpadding="0" cellspacing="0">
	<tr><td colspan="6" height="32">&nbsp;</td></tr>
	<tr>
	  <td  align="center">DATE</td>
	  <td align="center">OR NUMBER</td>
	  <td align="center">PARTICULAR</td>
	  <td align="center">DEBIT</td>
	  <td align="center">CREDIT</td>
	  <td align="center">BALANCE</td>
  </tr>
	<%
if(iPageCount == 1){
	dDebit = ((Double)vTuitionFeeDetail.elementAt(0)).doubleValue();
	if(dDebit != 0d){
		dBalance += dDebit;
	
	iRowCount++;
	%>
	
	<tr>
		<td width="13%">&nbsp;</td>
		<td valign="top" width="11%">prev</td>
		<td valign="top" width="40%">PREV. BAL.</td>
	  	<td valign="top" width="11%" align="right"><%=CommonUtil.formatFloat((float)dDebit,true)%></td>
		<td width="11%">&nbsp;</td>
		<td valign="top" width="14%" align="right"><%=CommonUtil.formatFloat((float)dBalance,true)%></td>
	</tr>
	<%}
	
	dTemp = ((Double)vTuitionFeeDetail.elementAt(1)).doubleValue() //tuition
			 + ((Double)vTuitionFeeDetail.elementAt(2)).doubleValue() //misc
			 + ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue() //other charge
			 + ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
	if(dTemp > 0d){
		dBalance += dTemp;
	iRowCount++;
	%>
	
	
	<tr>
		<td>&nbsp;</td>
		<td valign="top">ass</td>
		<td valign="top">ASSESSMENT</td>
		<td valign="top" align="right"><%=CommonUtil.formatFloat(dTemp,true)%></td>
		<td>&nbsp;</td>
		<td valign="top" align="right"><%=CommonUtil.formatFloat((float)dBalance,true)%></td>
	</tr>
	
	
	<%	
	}
	dTemp = 0d;
	if(dDownpayment > 0d){

		for(int p = 0; p < vDPInfo.size(); p += 3) {
			dTemp = Double.parseDouble(ConversionTable.replaceString((String)vDPInfo.elementAt(p + 2), ",",""));
			dBalance -= dTemp;
			iRowCount++;
		%>
			<tr>
				<td valign="top">&nbsp; &nbsp;<%=ConversionTable.replaceString((String)vDPInfo.elementAt(p + 1),"/","")%></td>
				<td valign="top"><%=vDPInfo.elementAt(p)%></td>
				<td valign="top">TUITION</td>
				<td>&nbsp;</td>
				<td valign="top" align="right"><%=CommonUtil.formatFloat(dTemp,true)%></td>
				<td valign="top" align="right"><%=CommonUtil.formatFloat((float)dBalance,true)%></td>
			</tr>
		<%}
		
	}

	
}//end if(iPageCount == 1)
	

	
boolean bolDatePrinted = false;
for(; i < vTimeSch.size(); ++i){
bolIsPageBreak = false;
//
strTransDate = ConversionTable.convertMMDDYYYY((Date)vTimeSch.elementAt(i));
bolDatePrinted = false;



strTemp = "";
while(strTransDate.indexOf("/") > -1){
	strErrMsg = strTransDate.substring(0, strTransDate.indexOf("/"));
	if(strErrMsg.length() == 1)
		strErrMsg = "0"+strErrMsg;
	strTemp += strErrMsg;
	strTransDate = strTransDate.substring(strTransDate.indexOf("/")+1);
}
strTransDate = strTemp + strTransDate;


	
int iIndexOf2 = 0;			
Vector vDiscountAddlDetail = faStudLedg.vDiscountAddlDetail;
String strGrant = null;
String strGrantNote = null;

if(vDiscountAddlDetail == null)
	vDiscountAddlDetail = new Vector();
	

	
while( (iIndex = vAdjustment.indexOf((Date)vTimeSch.elementAt(i))) != -1){
	//dBalance -= Double.parseDouble(WI.getStrValue(vDiscountDtls.elementAt(x+1),"0"));	
	
	
	strErrMsg = null;
	
	dCredit = Double.parseDouble((String)vAdjustment.elementAt(iIndex-3));
	dBalance -= dCredit;
	iRowCount++;
	
	iIndexOf2 = vDiscountAddlDetail.indexOf(new Integer((String)vAdjustment.elementAt(iIndex + 2)));
	if(iIndexOf2 == -1) {
		strTemp = null;
		strErrMsg = null;
	}
	else {		
		if(vDiscountAddlDetail.elementAt(iIndexOf2 + 2) != null && ((String)vDiscountAddlDetail.elementAt(iIndexOf2 + 2)).length() > 0) 
			strErrMsg = (String)vDiscountAddlDetail.elementAt(iIndexOf2 + 2);		
	}
	
	strGrant = (String)vAdjustment.elementAt(iIndex-4);
	if(strGrant != null && strGrant.length()  > 30){
		strGrant = strGrant.substring(0,30);
		strGrant = strGrant.substring(0, strGrant.lastIndexOf(" "));
	}
	%>
	<tr>
		<td> <% if(bolDatePrinted){%> &nbsp; <%}else{%> &nbsp; &nbsp;<%=ConversionTable.replaceString(strTransDate,"/","")%> <%bolDatePrinted=true;}%></td>
		<td>&nbsp;</td>
		<td valign="top" colspan="2"><%=strGrant%>(Grant)
	  <%=WI.getStrValue(strErrMsg, "<br>Approval #: ","","")%>
	  <%=WI.getStrValue(strGrantNote, "<br>","","")%></td>		
		<td valign="top" align="right"><%=CommonUtil.formatFloat(dCredit,true)%></td>
		<td valign="top" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
	</tr>
<%
vAdjustment.removeElementAt(iIndex);vAdjustment.removeElementAt(iIndex-1);vAdjustment.removeElementAt(iIndex-2);
vAdjustment.removeElementAt(iIndex-3);vAdjustment.removeElementAt(iIndex-4);
}//end for loop



	
	//Other school fees/fine/school facility fee charges(except dormitory)
while( (iIndex = vOthSchFine.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dDebit = Double.parseDouble((String)vOthSchFine.elementAt(iIndex-1));
	dBalance += dDebit;
%>
    <tr >
      <td valign="top" width="13%" height="16"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> &nbsp; &nbsp;<%=ConversionTable.replaceString(strTransDate,"/","")%> <%bolDatePrinted=true;}%> </td>
	   <%
	  strTemp = WI.getStrValue((String)vOthSchFine.elementAt(iIndex-2));
	  if(strTemp.length() > 15)
	  	strTemp = strTemp.substring(0, 15);
		%>
      <td>&nbsp;</td>
      <td valign="top"><%=strTemp%></td>
      <td valign="top" width="11%" align="right"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td>&nbsp;</td>
      <td valign="top" width="14%" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
//remove the element here.
vOthSchFine.removeElementAt(iIndex);vOthSchFine.removeElementAt(iIndex-1);vOthSchFine.removeElementAt(iIndex-2);
	
	if(++iRowCount >= iMaxRowCount){		
		bolIsPageBreak = true;
		break;//break while loop
	}
}

//vPayment goes here,
while( (iIndex = vPayment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
//	if(strDownpaymentORNumber.equals((String)vPayment.elementAt(iIndex-1))){ //this should be the downpayment of the student.
//		vPayment.removeElementAt(iIndex+3);
//		vPayment.removeElementAt(iIndex+2);
//		vPayment.removeElementAt(iIndex+1);
//		vPayment.removeElementAt(iIndex);
//		vPayment.removeElementAt(iIndex-1);
//		vPayment.removeElementAt(iIndex-2);
//		continue;	
//	}

	if(vDPInfo.indexOf((String)vPayment.elementAt(iIndex-1)) > -1){
		vPayment.removeElementAt(iIndex+3);
		vPayment.removeElementAt(iIndex+2);
		vPayment.removeElementAt(iIndex+1);
		vPayment.removeElementAt(iIndex);
		vPayment.removeElementAt(iIndex-1);
		vPayment.removeElementAt(iIndex-2);
		continue;
	}
	dCredit = Double.parseDouble((String)vPayment.elementAt(iIndex-2));
	dBalance -= dCredit;
%>
    <tr >
      <td valign="top" width="13%" height="16"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> &nbsp; &nbsp;<%=ConversionTable.replaceString(strTransDate,"/","")%> <%bolDatePrinted=true;}%> </td>
      <td valign="top" width="11%"><%=WI.getStrValue(vPayment.elementAt(iIndex-1))%></td>
	  <%

	  strTemp = (String)vPayment.elementAt(iIndex + 1);
	  if(strTemp.length() > 15)
	  	strTemp = strTemp.substring(0, 15);
	  %>
      <td valign="top" width="40%" align=""><%=strTemp%></td>
      <td valign="top" width="11%"  align="right">&nbsp;
	  <%//show only the refunds in debit column.
	  if(dCredit < 0d || 
	  	(vPayment.elementAt(iIndex+1) != null && ((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
	  <%=CommonUtil.formatFloat(-1 * dCredit,true)%>
	  <%}%></td>
      <td valign="top" width="11%" align="right">&nbsp;
	  <%if(dCredit >= 0d && 
	  	(vPayment.elementAt(iIndex+1) == null || !((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
	  <%=CommonUtil.formatFloat(dCredit,true)%>
	  <%}%>	  </td>
      <td valign="top" width="14%" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
	//remove the element here.
	vPayment.removeElementAt(iIndex+3);
	vPayment.removeElementAt(iIndex+2);
	vPayment.removeElementAt(iIndex+1);
	vPayment.removeElementAt(iIndex);
	vPayment.removeElementAt(iIndex-1);
	vPayment.removeElementAt(iIndex-2);
	
	

	if(++iRowCount >= iMaxRowCount){		
		bolIsPageBreak = true;
		break;//break while loop
	}

}//end while

if(bolIsPageBreak){%>
	<tr>
		<td colspan="6" align="right">page : <%=iPageCount%></td>
	</tr>
<%	
	iPageCount++;
	iRowCount = 0;
	break;//break for loop
}//end if(bolIsPageBreak)
}//end of vTimeSch%>
	
	

<%
bolIsPageBreak = false;
if(vTimeSch.size() <= i){
	bolIsPageBreak = true;
	if(iRowCount < 10){
	for(int j = iRowCount; j <= 9; ++j){
%>
	<tr><td colspan="6">&nbsp;</td></tr>
	
	<%}
	}
%>

	<tr>
		<td colspan="5" align="center">**Subject to Audit**</td>
		<td align="right"><strong><%=CommonUtil.formatFloat(dBalance,true)%></strong></td>
	</tr>
	<tr><td colspan="6" align="right"><%=WI.getTodaysDate(1)%></td></tr>
	<tr><td colspan="6" align="right">page : <%=iPageCount%></td></tr>
<%	
//break;
}
%>
</table>
<%
if(bolIsPageBreak){
	bolIsPageBreak = false;
	break;
}
}//end while loop
if(bolShowPageCount)
	request.getSession(false).setAttribute("swu_page_counter", Integer.toString(iCount));


	}//only if student information is found.
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
