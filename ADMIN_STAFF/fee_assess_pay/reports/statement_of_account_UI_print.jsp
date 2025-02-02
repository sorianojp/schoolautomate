<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
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
		window.setTimeout("javascript:window.close();", 2000);
}
</script>
<body onLoad="CloseWnd();">
<%@ page language="java" import="utility.*,EnrlReport.StatementOfAccount,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strSchoolCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchoolCode == null)
		strSchoolCode = "";
	boolean bolIsUI = strSchoolCode.startsWith("UI");

	if(strSchoolCode.startsWith("AUF")) {
		if(WI.fillTextValue("is_sa_perexam").equals("1")){%>
			<jsp:forward page="./statement_of_account_AUF_print_perexam.jsp" />
		<%}else{%>
			<jsp:forward page="./statement_of_account_AUF_print_new.jsp" />
	<%}
	return;}
	if(strSchoolCode.startsWith("VMA")) {%>
			<jsp:forward page="./statement_of_account_print_vma.jsp" />
		<%}
	if(strSchoolCode.startsWith("WNU")) {%>
			<jsp:forward page="./statement_of_account_WNU_print_perexam.jsp" />
		<%
	return;}

	if(strSchoolCode.startsWith("SWU")) {%>
			<jsp:forward page="./statement_of_account_print_SWU.jsp" />
		<%
	return;}

	if(strSchoolCode.startsWith("UPH") && !strSchoolCode.startsWith("UPH07")){
		strTemp = (String)request.getSession(false).getAttribute("info5");//dbOP.getResultOfAQuery("select info5 from sys_info", 0);
		if(strTemp != null && strTemp.equals("jonelta")) {%>
			<jsp:forward page="./statement_of_account_UPHJ_print.jsp" />
		<%}
	}

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
Vector vMiscFeeInfo  = null;
Vector vTemp         = null;
Vector vScheduledPmt = null;
Vector vSubjectDtls  = null;

double dDebit = 0f;
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

String strExamDueDate = null;//for DBTC, I have to show the exam due date..
///////////// end of using ledger to get all information.


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

if(strErrMsg == null)
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
//System.out.println("strPmtScheduleName : "+strPmtScheduleName);

if(strSchoolCode.startsWith("DBTC") && strPmtScheduleName.length() > 0) {
	int iIndexOf = vScheduledPmt.indexOf(strPmtScheduleName);
	if(iIndexOf > -1) {
		strExamDueDate = (String)vScheduledPmt.elementAt(iIndexOf + 1);
	}

}




String[] astrConvertYrLevel = {"",",1st Year",",2nd Year",",3rd Year",",4th Year",",5th Year",",6th Year",",7th Year"};
String[] astrConvertSem     = {"Summer","1ST SEM","2ND SEM","3RD SEM","4TH SEM","5TH SEM"};
//System.out.println(fOperation.fTotalAssessedHour);;
if(strErrMsg != null && strErrMsg.length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
  </table>
<%}
String strSectionName = null;//set only if dbtc..
 if(vStudInfo != null && vStudInfo.size() > 0){

	 if(strSchoolCode.startsWith("DBTC")) {
	 	if(bolIsBasic) {
			strSectionName = "select section from enrl_final_cur_list join e_sub_section on(e_sub_section.sub_sec_index = enrl_final_cur_list.sub_sec_index) "+
	 		" where is_temp_stud = 0 and user_index = "+(String)vStudInfo.elementAt(0)+" and enrl_final_cur_list.sy_from = "+WI.fillTextValue("sy_from")+" and current_semester = "+
			WI.fillTextValue("semester")+" and enrl_final_cur_list.is_valid = 1";
			//System.out.println(strSectionName);
			strSectionName = dbOP.getResultOfAQuery(strSectionName, 0);
	 	}

	 %>
	 	<table width="100%" cellpadding="0" cellspacing="0">
		<tr >
		  <td width="90%" height="25"><div align="center">
		  <strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
			<font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></div></td>
		</tr>
		<tr >
		  <td height="20"><div align="center"><strong>STATEMENT OF ACCOUNT </strong><br>
			<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, AY <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%>
			</div></td>
		</tr>
		</table>
	 <%}//show the heading only for dbtc.. %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td height="18">&nbsp;</td>
    <td width="30%">&nbsp;</td>
    <td colspan="2" align="right">Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td>
  </tr>
  <tr>
    <td width="7%" height="20">&nbsp;</td>
    <td><%=WebInterface.formatName((String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11),
	  	(String)vStudInfo.elementAt(12),4)%></td>
    <td width="49%"><%=WI.fillTextValue("stud_id").toUpperCase()%></td>
    <td width="14%"><%if(bolIsUI){%><%if(!bolIsBasic){%><%=(String)vSubjectDtls.elementAt(2)%><%}%><%}%></td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td>
	<%//System.out.println(vStudInfo);
	if(bolIsBasic){%>
	<%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0")))%>
	<%}else{//non basic student.%>
	<%=(String)vStudInfo.elementAt(16)%> <%
	  if(vStudInfo.elementAt(3) != null){%>
      /<%=(String)vStudInfo.elementAt(3)%> <%}%>
      <strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%></strong>
	  <%}//end of non basic student.%>    </td>
    <td valign="top"><%if(!bolIsBasic){%><%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>,<%}%>
        <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%></td>
    <td valign="top">
	<%if(strSectionName != null) {%><%=strSectionName%><%}//only for dbtc.. %>

	<%if(bolIsUI){%>
<%//System.out.println(fOperation.fTotalAssessedHour);
if(!bolIsBasic){
	if(fOperation.fTotalAssessedHour > 0f){%>
		<%=fOperation.fTotalAssessedHour%>
	<%}else{%>
		<%=(String)vSubjectDtls.elementAt(2)%>
	<%}
}%>

<%}//show only if UI%>	</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td width="100%" height="25" colspan="5">&nbsp;</td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
  	<td width="40%" valign="top">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
        <tr>
          <td width="4%"></td>
          <td width="56%">Tuition Fees</td>
          <td width="40%"> <div align="right">
              <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(1)).doubleValue();
dBalance += dDebit;
%>
              <strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong>
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <tr>
          <td></td>
          <td>Miscellaneous Fees</td>
          <td><div align="right"><strong>
              <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(2)).doubleValue();
dBalance += dDebit;
%>
              <%=CommonUtil.formatFloat((float)dDebit,true)%></strong>
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <%if(dDebit > 0d)
{//display mis fee detail.
	for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
		if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
			continue;
		}%>
        <!--<tr>
            <td></td>
            <td>&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
            <td><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
          </tr>-->
        <%}//end of for loop.
}//if misc fee is not null

dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();

if(dDebit > 0d){
dBalance += dDebit;%>
        <!-- do not display
		  <tr>
            <td></td>
            <td>Other Charges</td>
            <td><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></td>
          </tr> -->
        <%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		continue;
	}
	%>
        <tr>
          <td></td>
          <td><%=(String)vMiscFeeInfo.elementAt(i)%></td>
          <td><div align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <%}
}//end of displaying other Charges.

//show hands on.
dDebit = ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
if(dDebit > 0d){
dBalance += dDebit;%>
        <!-- HANDS ON -->
        <tr>
          <td></td>
          <td>Hands On</td>
          <td><div align="right"><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <%}
//show now all the other facilities taken by student like internet card - printing etc.
dDebit = ((Double)vOthSchFine.elementAt(0)).doubleValue();

if(dDebit > 0d){
dBalance += dDebit;%>
        <!-- do not display
		  <tr>
            <td></td>
            <td>Other Charges</td>
            <td><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></td>
          </tr>-->
        <%
for(int i = 1; i< vOthSchFine.size(); i +=3) {%>
        <tr>
          <td></td>
          <td><%=(String)vOthSchFine.elementAt(i)%></td>
          <td><div align="right"><%=CommonUtil.formatFloat((String)vOthSchFine.elementAt(i+1),true)%>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <%}
}//end of displaying other Charges.

%>
        <tr>
          <td></td>
          <td>&nbsp;</td>
          <td><div align="center">---------------</div></td>
        </tr>
        <tr>
          <td></td>
          <td>Total Assessment</td>
          <td><div align="right"><strong><%=CommonUtil.formatFloat((float)dBalance,true)%></strong>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <tr>
          <td></td>
          <td>Back Account</td>
          <td> <div align="right">
              <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(0)).doubleValue();
dBalance += dDebit;
%>
              <strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong>
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <tr>
          <td></td>
          <td>Total Charges</td>
          <td><div align="right"><strong><%=CommonUtil.formatFloat((float)dBalance,true)%></strong>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
      </table>
	</td>
  	  <td width="60%" valign="top">
	  <table width="100%" cellpadding="0" cellspacing="0" border="0">
        <tr>
          <td colspan="2">
            <!--TOTAL CHARGES-->
          </td>
          <td width="32%"><div align="right"><strong><%=CommonUtil.formatFloat((float)dBalance,true)%></strong>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <tr>
          <td colspan="2">
            <!--LESS PAYMENTS/ADJUSTMENTS-->
          </td>
          <td><div align="right">&nbsp;</div></td>
        </tr>
        <tr>
          <td colspan="2">
            <!--LESS PAYMENTS/ADJUSTMENTS (added 8-10-2005)-->
          </td>
          <td><div align="right">&nbsp;</div></td>
        </tr>
        <tr>
          <td width="48%">&nbsp;
            <!--Date/OR #-->
          </td>
          <td width="20%">&nbsp;
            <!--AMOUNT-->
          </td>
          <td><div align="right"></div></td>
        </tr>
        <tr>
          <td width="48%">&nbsp;
            <!--Date/OR #-->
          </td>
          <td width="20%">&nbsp;
            <!--AMOUNT-->
          </td>
          <td><div align="right"></div></td>
        </tr>
        <tr>
          <td width="48%">&nbsp;
            <!--Date/OR #-->
          </td>
          <td width="20%">&nbsp;
            <!--AMOUNT-->
          </td>
          <td><div align="right"></div></td>
        </tr>
        <%
if(vPayment != null && vPayment.size() > 0){
	for(int i = 0; i < vPayment.size(); i += 6){
dDebit = Double.parseDouble((String)vPayment.elementAt(i));
dTemp += dDebit;
	%>
        <tr>
          <td><%=ConversionTable.convertMMDDYYYY((java.util.Date)vPayment.elementAt(i + 2))%>&nbsp;&nbsp;&nbsp; <%
//refund is called also.
if(	vPayment.elementAt(i + 1) == null) {%> <%=(String)vPayment.elementAt(i + 3)%> <%}else{%> <%=(String)vPayment.elementAt(i + 1)%> <%}%> </td>
          <td><div align="right"><%=CommonUtil.formatFloat((float)dDebit,true)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
          <td><div align="right"></div></td>
        </tr>
        <%}
dBalance -= dTemp;//end of for loop%>
        <tr>
          <td align="right">&nbsp;</td>
          <td>TOTAL PAID</td>
          <td><div align="right"><u><strong><%=CommonUtil.formatFloat((float)dTemp,true)%></strong></u>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <%}else{//no payment -- whichi is not possible - because there has to be a downpayment.%>
        <tr>
          <td>&nbsp;</td>
          <td>0.00</td>
          <td><div align="right"></div></td>
        </tr>
        <%}
 //show enrollment discount if there is any.
 if(vTuitionFeeDetail.elementAt(5) != null){
dDebit = ((Double)vTuitionFeeDetail.elementAt(5)).doubleValue();
dBalance -= dDebit;
%>
        <tr>
          <td><%=vTuitionFeeDetail.elementAt(6)%></td>
          <td>&nbsp;</td>
          <td><div align="right"><u><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></u>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
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
          <td><%=strTemp%></td>
          <td>&nbsp;</td>
          <td><div align="right"><u><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></u>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <%}//end of for loop

}//show if adjustment is valid.

//now get refund.
for(int i = 0; i < vRefund.size() ; i += 4) {
	dDebit = Double.parseDouble((String)vRefund.elementAt(i + 2));
	dBalance += dDebit;
%>
        <tr>
          <td><%=WI.getStrValue(vRefund.elementAt(i + 1))%> (Refund)</td>
          <td>&nbsp;</td>
          <td><div align="right"><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
<%}%>
        <tr>
          <td>BALANCE</td>
          <td>&nbsp;</td>
          <td><div align="right"><strong><%=CommonUtil.formatFloat((float)dBalance,true)%></strong>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <%
//compute here amt due for this prelim
double dAmtDue = 0d;//System.out.println(vScheduledPmt);
double dDueForThisPeriod = 0d;
double dTotalInstalAmtPaid = 0d;//this is the total installment amt paid.
String strExamPeriodName = null;///i have to get the exam period from vScheduledPmt

  //////////// Posting pmt schedule.
   Vector vInstallPmtSchedule =
        FA.getOtherChargePayable(dbOP, WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"), (String)vStudInfo.elementAt(0));
	if(vInstallPmtSchedule != null)
		vInstallPmtSchedule.removeElementAt(0);
    double dInstallmentPayable = 0d;double dCumInstallmentPayable = 0d;
    //this determines how the posting fees paid.
//vScheduledPmt = null;
//System.out.println(vScheduledPmt);
if(vScheduledPmt != null && vScheduledPmt.size() > 0) {
//	System.out.println("553 : im here");
	for(int i = 5; i < vScheduledPmt.size(); i +=3) {
        if(i == 5) {
        	dAmtDue = ((Double)vScheduledPmt.remove(vScheduledPmt.size() - 1)).doubleValue() -
                          ( (Float)vScheduledPmt.elementAt(3)).doubleValue();
			//if(strSchoolCode.startsWith("DBTC")) {//strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("CGH")
			//	double dReservationFee = paymentUtil.getReservationFeeCGH(dbOP, (String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"),false);
			//	dAmtDue += dReservationFee;
		  	//}
		}
		dAmtDue = ( (Float)vScheduledPmt.elementAt(3)).doubleValue() -
				 ((Float)vScheduledPmt.elementAt(i + 2)).doubleValue()+dAmtDue;


       //////////////// installment payment - start /////////
	   dInstallmentPayable = 0d;
        if(vInstallPmtSchedule != null) {
          for(;vInstallPmtSchedule.size() > 0;) {
            //if matching, get value and break. else continue;
            if( ((String)vInstallPmtSchedule.elementAt(1)).compareTo((String)vScheduledPmt.elementAt(i)) == 0) {
              dInstallmentPayable = Double.parseDouble((String)vInstallPmtSchedule.elementAt(2));
              vInstallPmtSchedule.removeElementAt(0);
              vInstallPmtSchedule.removeElementAt(0);
              vInstallPmtSchedule.removeElementAt(0);
              break;
            }
            ///keep adding to payable.
            dInstallmentPayable = Double.parseDouble((String)vInstallPmtSchedule.elementAt(2));
            vInstallPmtSchedule.removeElementAt(0);
            vInstallPmtSchedule.removeElementAt(0);
            vInstallPmtSchedule.removeElementAt(0);
          }
        }
		dCumInstallmentPayable += dInstallmentPayable;
		dAmtDue += dInstallmentPayable;
        //////////////// installment payment - end /////////



		strExamPeriodName = (String)vScheduledPmt.elementAt(i);//System.out.println(strExamPeriodName);
		if(strExamPeriodName.compareTo(strPmtScheduleName) != 0 && !strExamPeriodName.startsWith("Unit"))
			continue;//do not print if this is not called for this exam period.

		//If already paid, i have to deduct this amount.
		for(int p = i + 3; p < vScheduledPmt.size() - 1; p += 3) {
			dAmtDue = dAmtDue - ((Float)vScheduledPmt.elementAt(p + 2)).doubleValue();
			//System.out.println(((Float)vScheduledPmt.elementAt(p + 2)).doubleValue());
		}
		if(dBalance < dAmtDue)
			dAmtDue = dBalance;

		if( dAmtDue < 0d)
			dDueForThisPeriod = 0d;
		else
			dDueForThisPeriod = dAmtDue;
		if(dBalance != dDueForThisPeriod && strPmtScheduleName.toLowerCase().startsWith("fin"))
			dDueForThisPeriod = dBalance;

		if (bolIsBasic && WI.fillTextValue("print_final").equals("1"))
			dDueForThisPeriod = dBalance;
		%>

        <tr>
          <td colspan="3"> <font size="2"><strong>Amount Due this
		  <%
		  	if (bolIsBasic && WI.fillTextValue("print_final").equals("1")) {%>
				Fourth Grading
		  <%}else{%>
		  <%=strPmtScheduleName%> Examination:
		   <%}%>
		   <%=CommonUtil.formatFloat((float)dDueForThisPeriod,true)%></strong></font></td>
        </tr>
        <%break;}//end of for loop

}//end of if condition
%>
        <tr>
          <td><%if(strExamDueDate != null) {%>Due Date : <%=strExamDueDate%><%}%></td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
<%
strSchoolCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchoolCode.startsWith("VMA") && dDueForThisPeriod > 0d) {

	double dOSPayable = ((Double)vTuitionFeeDetail.elementAt(0)).doubleValue();
	
	double dTuitionPayable = dDueForThisPeriod;
	double dOthChargePayable = 0d;
	
	java.sql.ResultSet rs    = null;
	String strSQLQuery = "select sum(amount*no_of_units) from fa_stud_payable where is_valid = 1 and sy_from = "+request.getParameter("sy_from") + 
					" and semester = "+request.getParameter("semester")+" and user_index = "+(String)vStudInfo.elementAt(0);
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next())
		dOthChargePayable = rs.getDouble(1);
	rs.close();
	
	if(dOthChargePayable > 0d) {
		strSQLQuery = "select sum(amount) from fa_stud_payment where is_valid = 1 and sy_from = "+request.getParameter("sy_from") + 
						" and semester = "+request.getParameter("semester")+" and user_index = "+(String)vStudInfo.elementAt(0)+
						" and amount > 0 and or_number is not null and (othsch_fee_index is not null or payment_for = 8) and is_stud_temp = 0";
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next())
			dOthChargePayable -= rs.getDouble(1);
		rs.close();
	}
	
	if(dOthChargePayable <=0d)
		dOthChargePayable = 0d;
		
	double dTotalTuitionPaid = 0d;
	if(dOSPayable >0d) {
		strSQLQuery = "select sum(amount) from fa_stud_payment where is_valid = 1 and sy_from = "+request.getParameter("sy_from") + 
						" and semester = "+request.getParameter("semester")+" and user_index = "+(String)vStudInfo.elementAt(0)+
						" and amount > 0 and or_number is not null and payment_for in (0, 10) and is_stud_temp = 0";
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next())
			dTotalTuitionPaid = rs.getDouble(1);
		rs.close();
		if(dTotalTuitionPaid >dOSPayable) 
			dOSPayable = 0d;
		else	
			dOSPayable = dOSPayable - dTotalTuitionPaid;
	}
	else	
		dOSPayable = 0d;  
		
	
	if(dOthChargePayable < 1d)
		dOthChargePayable = 0d;
	
	dTuitionPayable = dTuitionPayable - dOSPayable - dOthChargePayable;
	if(dTuitionPayable < 0d) {
		dOSPayable = dOSPayable + dTuitionPayable;
		dTuitionPayable = 0d; 
	}

if(dOSPayable > 0d || dOthChargePayable > 0d){
%>
        <tr>
          <td>
		  Tuition: <%=CommonUtil.formatFloat(dTuitionPayable, true)%>
		  <%if(dOSPayable > 0d){%>
		  <br>Old Account: <%=CommonUtil.formatFloat(dOSPayable, true)%>
		  <%}%>
		  <%if(dOthChargePayable > 0d){%>
		  <br>Total Charges: <%=CommonUtil.formatFloat(dOthChargePayable, true)%>
		  <%}%>
		  </td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>

<%}

}%>	
      </table>

	  </td>
  </tr>
  </table>
<script language="JavaScript">
//get this from common.js
//this.autoPrint();

//closeWnd = 1;
window.print();
</script>
<%
	}//only if student information is found.
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
