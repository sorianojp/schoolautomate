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
	if(strSchoolCode.startsWith("WNU")) {%>
			<jsp:forward page="./statement_of_account_WNU_print_perexam.jsp" />
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
Vector vPayment = new Vector();
Vector vTuitionFeeDetail = null;

String strExamDueDate = null;//for DBTC, I have to show the exam due date..
///////////// end of using ledger to get all information.
double dOutStandingBalance = 0d;

StatementOfAccount SOA = new StatementOfAccount();
Vector vOCPayable = new Vector();


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
		//vPayment			= (Vector)vLedgerInfo.elementAt(6);
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
	
		//get add charge details.. 
		int iIndexOf          = 0;
		strTemp = "select reference_index,fee_name, sum(fa_oth_sch_Fee.amount) from fa_stud_payable join fa_oth_sch_Fee on (othsch_fee_index = reference_index) where user_index = "+
				(String)vStudInfo.elementAt(0)+" and sy_from = "+WI.fillTextValue("sy_from") +" and semester = "+WI.fillTextValue("semester")+
				" and fa_stud_payable.is_valid = 1 and payable_type = 0 group by reference_index,fee_name";
		//System.out.println(strTemp);
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp); 
		while(rs.next()) {
			vOCPayable.addElement(rs.getString(1));//fee_index
			vOCPayable.addElement(rs.getString(2));//fee Name
			vOCPayable.addElement(CommonUtil.formatFloat(rs.getDouble(3), true));
		}
		rs.close();
		
		//now get payment for add/drop fee. 
		if(vOCPayable.size() > 0) {
			strTemp = "select othsch_fee_index from fa_stud_payment where user_index = "+(String)vStudInfo.elementAt(0)+" and sy_from = "+WI.fillTextValue("sy_from")+
					" and semester = "+WI.fillTextValue("semester")+" and is_valid = 1 and othsch_fee_index is not null";
			//System.out.println(strTemp);
			rs = dbOP.executeQuery(strTemp);
			while(rs.next()) {
				iIndexOf = vOCPayable.indexOf(rs.getString(1));
				if(iIndexOf == -1)
					continue;
				
				vOCPayable.remove(iIndexOf);
				vOCPayable.remove(iIndexOf);
				vOCPayable.remove(iIndexOf);
			}
			rs.close();
		}
		
		//get details of tuition only.. 
		strTemp = "select date_paid, or_number, amount from fa_stud_payment where user_index = "+(String)vStudInfo.elementAt(0)+" and sy_from = "+WI.fillTextValue("sy_from")+
					" and semester = "+WI.fillTextValue("semester")+" and is_valid = 1 and payment_for = 0 and or_number is not null and amount > 0";
		rs = dbOP.executeQuery(strTemp);
		while(rs.next()) {
			vPayment.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(1))); 
			vPayment.addElement(rs.getString(2));
			vPayment.addElement(rs.getString(3));
		}
		rs.close();
}

if(strErrMsg == null)
{
	//vScheduledPmt = FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
    //    						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	
	vScheduledPmt = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
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
	dOutStandingBalance= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0), true, true);
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
      <%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%>
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
<%
dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();

if(dDebit > 0d){
dBalance += dDebit;%>
		  <tr>
            <td></td>
            <td>Other Charges</td>
            <td><div align="right"><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
          </tr>
<%}//end of displaying other Charges.

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
<%}%>
        <tr>
          <td></td>
          <td>&nbsp;</td>
          <td><div align="right">---------------&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <tr>
          <td></td>
          <td>Total Assessment</td>
          <td><div align="right"><strong><%=CommonUtil.formatFloat((float)dBalance,true)%></strong>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
        </tr>
        <tr>
          <td></td>
          <td>A/R Students</td>
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
	  
	  <table width="100%" cellpadding="0" cellspacing="0" border="0">
        <tr>
          <td width="48%">&nbsp;
            <!--Date/OR #-->          </td>
          <td width="20%">&nbsp;
            <!--AMOUNT-->          </td>
          <td colspan="2"><div align="right"></div></td>
        </tr>
        <tr>
          <td width="48%">Less Payments</td>
          <td width="20%">&nbsp;
            <!--AMOUNT-->          </td>
          <td colspan="2"><div align="right"></div></td>
        </tr>
        <tr>
          <td width="48%">&nbsp;
            <!--Date/OR #-->          </td>
          <td width="20%">&nbsp;
            <!--AMOUNT-->          </td>
          <td colspan="2"><div align="right"></div></td>
        </tr>
        <%
if(vPayment != null && vPayment.size() > 0){
	for(int i = 0; i < vPayment.size(); i += 3){
dDebit = Double.parseDouble((String)vPayment.elementAt(i + 2));
dTemp += dDebit;
	%>
        <tr>
          <td><%=vPayment.elementAt(i)%>&nbsp;&nbsp;&nbsp; 
		  <%=(String)vPayment.elementAt(i + 1)%></td>
          <td><div align="right"><%=CommonUtil.formatFloat((float)dDebit,true)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
          <td colspan="2"><div align="right"></div></td>
        </tr>
        <%}
dBalance -= dTemp;//end of for loop%>
        <tr>
          <td align="right">TOTAL PAID &nbsp;</td>
          <td align="right"><u><strong><%=CommonUtil.formatFloat(dTemp,true)%></strong></u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
          <td colspan="2">&nbsp;</td>
        </tr>
        <%}else{//no payment -- whichi is not possible - because there has to be a downpayment.%>
        <tr>
          <td align="right">TOTAL PAID &nbsp;</td>
          <td align="right"><u><strong>0.00</strong></u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
          <td colspan="2"><div align="right"></div></td>
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
          <td><div align="right"><u><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></u></div></td>
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
          <td><%=strTemp%></td>
          <td>&nbsp;</td>
          <td><div align="right"><u><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></u></div></td>
          <td>&nbsp;</td>
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
          <td><div align="right"><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></div></td>
          <td>&nbsp;</td>
        </tr>
<%}%>
        <tr>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td></td>
          <td></td>
        </tr>
        <tr>
          <td>BALANCE</td>
          <td>&nbsp;</td>
          <td width="23%"><div align="right"><strong><%=CommonUtil.formatFloat(dOutStandingBalance,true)%></strong></div></td>
          <td width="9%">&nbsp;</td>
        </tr>
      </table>
	  
	  
	</td>
  	  <td width="60%" valign="bottom"> 
	  	<%if(vOCPayable.size() > 0) {%>
			<table border="0" width="100%" class="thinborder" align="left" cellpadding="0" cellspacing="0">
				<tr>
					<td width="73%" height="18" class="thinborder"><strong>Other School Fees Posted</strong></td>
					<td width="27%" class="thinborder"><strong>Amount</strong></td>
				</tr>
				<%
				for(int i = 0; i < vOCPayable.size(); i += 3) {%>
				<tr>
				  <td width="73%" class="thinborder" height="18"><%=vOCPayable.elementAt(i + 1)%></td>
					<td width="27%" class="thinborder"><%=vOCPayable.elementAt(i + 2)%></td>
				</tr>
				<%}%>
			</table>
	  
	  	<%}%>
		<br><br><br><br>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
			  <td>&nbsp;</td>
		    </tr>
			<%
			dTemp = 0d;
			for(int i = 7; i < vScheduledPmt.size(); i += 2) {
				dTemp += ((Double)vScheduledPmt.elementAt(i + 1)).doubleValue();
				if( ((String)vScheduledPmt.elementAt(i)).toUpperCase().equals(strPmtScheduleName.toUpperCase()))
					break;
			
			}
			if(dTemp < 0d)
				dTemp = 0d;
			else if(dTemp > dOutStandingBalance)
				dTemp = dOutStandingBalance;
			%>
			<tr>
			  <td style="font-size:18px; font-weight:bold" align="center">Payment due for <%=strPmtScheduleName%>: <%=CommonUtil.formatFloat(dTemp, true)%></td>
		    </tr>
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
