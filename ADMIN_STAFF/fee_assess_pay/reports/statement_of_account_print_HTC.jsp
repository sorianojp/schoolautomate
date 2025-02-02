<%@ page language="java" import="utility.*,EnrlReport.StatementOfAccount,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null) {%>
		<p style="font-size:16px; font-weight:bold; color:#FF0000">
			Session Expired. Please login again.		</p>
	<%return; 
}
	WebInterface WI = new WebInterface(request);
	String strStudID = WI.fillTextValue("stud_id");
	
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	
if(WI.fillTextValue("myhome").length() > 0) 
	strStudID = (String)request.getSession(false).getAttribute("userId");
else {
	if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4")) {%>
		<p style="font-size:24px; font-weight:bold">You are not authorized to access this account.</p>
	<%return;}
	
}
	java.sql.ResultSet rs = null;
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	boolean bolIsFatima = strSchoolCode.startsWith("FATIMA");
	double dInstallmentFee = 0d;
	String strPlanInfo     = null;
	double dAddDropFee     = 0d;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<body onLoad="window.print();">
<%
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
/**
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
**/

//end of authenticaion code.
Vector vStudInfo     = null;
Vector vMiscFeeInfo  = null;
Vector vTemp         = null;
Vector vScheduledPmt = null;
Vector vSubjectDtls  = null;
Vector vLabCharges = new Vector();
Vector vPayment 	 = null;
Vector vOthSchFeePayment = new Vector();
Vector vDiscountAddlDetail = null;

String strExamDate = null;
String strPmtSchedule = WI.fillTextValue("pmt_schedule");
String strExamName = null;
int iExamOrder = 0;

double dExamPayable = 0d;
double dTemp = 0d;
double dTotPayableAmt = 0d;
double dTotOthSchFee = 0d;
double dTutionFee    = 0d;
double dCompLabFee   = 0d;
double dMiscFee      = 0d;
double dOutstanding  = 0d;
double dMiscOtherFee = 0d;//This is the misc fee other charges,
double dMiscOtherFeeTemp = 0d;
//double dDiscount 	 = 0d;
double dOtherSchPayable = 0d;//for CSA, i have to show total adjustment + other school payable.. 

float fTotalDiscount = 0f;
float fDownpayment   = 0f;
double dTotalAmtPaid  = 0f;
float fEnrolmentDiscount = 0f;//discount / fines during enrollment.

String strDiscountName = null;//shown for fatima. name of discount.

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();
StatementOfAccount SOA = new StatementOfAccount();
enrollment.FAStudentLedger faStudLedg = new enrollment.FAStudentLedger();
boolean bolIsBasic = false;

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
					strStudID,WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));


if(vStudInfo == null) 
	strErrMsg = enrlStudInfo.getErrMsg();
else {

	if(vStudInfo.elementAt(2) == null) 
		bolIsBasic = true;
	paymentUtil.setIsBasic(bolIsBasic);
	fOperation.setIsBasic(bolIsBasic);
	FA.setIsBasic(bolIsBasic);



	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
		
	strTemp = (String)vStudInfo.elementAt(6);//major
	if(WI.getStrValue(strTemp).length() > 0)
		strTemp = " and major_index = "+strTemp;
	else
		strTemp = "";
	
	//if(WI.getStrValue((String)vStudInfo.elementAt(4)).length() > 0)	//year level
	//	strTemp += " and year_level = "+(String)vStudInfo.elementAt(4);
	strTemp += " and sy_index=(select sy_index from FA_SCHYR where sy_from=" + WI.fillTextValue("sy_from") + ") ";
	
	strTemp = " select distinct fee_name,AMOUNT  from FA_MISC_FEE where CATG_INDEX is not null  "+ 
			" and COURSE_INDEX = "+(String)vStudInfo.elementAt(5)+ strTemp +" and IS_VALID = 1 and is_del = 0 "+
			" and MISC_OTHER_CHARGE = 1 and fee_name like '%lab%'";
	rs = dbOP.executeQuery(strTemp);	
	while(rs.next()){
		vLabCharges.addElement(rs.getString(1));
		vLabCharges.addElement(rs.getString(2));		
	}rs.close();
}


if(strErrMsg == null) {//collect fee details here.
	

	vPayment = faStudLedg.getPaymentInfo(new Vector(), dbOP, (String)vStudInfo.elementAt(0), request.getParameter("sy_from"), 
		request.getParameter("sy_to"),(String)vStudInfo.elementAt(4), request.getParameter("semester"));
		
	vOthSchFeePayment = faStudLedg.getSchFacOthSchAndFinePosting(new Vector(), dbOP, (String)vStudInfo.elementAt(0), request.getParameter("sy_from"), 
		request.getParameter("sy_to"),(String)vStudInfo.elementAt(4), request.getParameter("semester"));
	int iIndexOf = 0;
	/**check if  there are payment made for post charges. so it will not display*/
	if(vOthSchFeePayment != null && vOthSchFeePayment.size() > 0){	
		dTotOthSchFee = ((Double)vOthSchFeePayment.remove(0)).doubleValue();
	
	
		/** I have to run again bec multiple payment not saving the oth_fee_index**/
		strTemp = " select fee_name, FA_STUD_PAYMENT.AMOUNT from FA_STUD_PAYMENT  "+ 
			" join fa_oth_sch_fee on (FA_STUD_PAYMENT.OTHSCH_FEE_INDEX = fa_oth_sch_fee.OTHSCH_FEE_INDEX)  "+
			" where user_index ="+(String)vStudInfo.elementAt(0)+
			" and sy_from = "+request.getParameter("sy_from")+
			" and SEMESTER = "+request.getParameter("semester")+
			" and FA_STUD_PAYMENT.IS_VALID = 1  "+
			" and FA_STUD_PAYMENT.PMT_SCH_INDEX = -1  "+
			" and FA_STUD_PAYMENT.othsch_fee_index is not null and is_stud_temp = 0 ";
		
		rs = dbOP.executeQuery(strTemp);
		while(rs.next()){
			iIndexOf = vOthSchFeePayment.indexOf(rs.getString(1));
			if(iIndexOf > -1){
				dOtherSchPayable = Double.parseDouble((String)vOthSchFeePayment.elementAt(iIndexOf + 1));				
				if(dOtherSchPayable == rs.getDouble(2)){
					dTotOthSchFee -= rs.getDouble(2);
					vOthSchFeePayment.remove(iIndexOf);vOthSchFeePayment.remove(iIndexOf);
					vOthSchFeePayment.remove(iIndexOf);
				}
			}
		}rs.close();	
		
		strTemp = " select fee_name, FA_STUD_PAYABLE.AMOUNT * isnull(no_of_units,1) "+ 
			" from FA_STUD_PAYMENT   "+
			" join FA_STUD_PAYABLE on (FA_STUD_PAYABLE.payment_index = fa_stud_payment.PAYMENT_INDEX) "+
			" join fa_oth_sch_fee on (fa_oth_sch_fee.OTHSCH_FEE_INDEX = FA_STUD_PAYABLE.REFERENCE_INDEX) "+   
			" where FA_STUD_PAYMENT.user_index ="+(String)vStudInfo.elementAt(0)+
			" and FA_STUD_PAYMENT.sy_from = "+request.getParameter("sy_from")+
			" and FA_STUD_PAYMENT.SEMESTER =  "+request.getParameter("semester")+
			" and FA_STUD_PAYMENT.IS_VALID = 1   "+
			" and MULTIPLE_PMT_NOTE is not null ";
		rs = dbOP.executeQuery(strTemp);
		while(rs.next()){
			iIndexOf = vOthSchFeePayment.indexOf(rs.getString(1));
			if(iIndexOf > -1){
				dOtherSchPayable = Double.parseDouble((String)vOthSchFeePayment.elementAt(iIndexOf + 1));				
				if(dOtherSchPayable == rs.getDouble(2)){
					dTotOthSchFee -= rs.getDouble(2);
					vOthSchFeePayment.remove(iIndexOf);vOthSchFeePayment.remove(iIndexOf);
					vOthSchFeePayment.remove(iIndexOf);
				}
			}
		}rs.close();
	}
	
	
	
	
	
	strTemp = "select EXAM_PERIOD_ORDER ,EXAM_NAME, EXAM_SCHEDULE from FA_PMT_SCHEDULE where PMT_SCH_INDEX = "+strPmtSchedule;
	rs = dbOP.executeQuery(strTemp);
	if(rs.next()){
		iExamOrder = rs.getInt(1);
		strExamName = rs.getString(2);
		strExamDate = ConversionTable.convertMMDDYYYY(rs.getDate(3));
	}rs.close();
	
	
}

//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null)
{
	vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(vTemp == null)
		strErrMsg = paymentUtil.getErrMsg();
	else
		vMiscFeeInfo.addAll(vTemp);
	if(fOperation.vMultipleOCMapInfo != null && fOperation.vMultipleOCMapInfo.size() > 0) 
		vMiscFeeInfo.addAll(fOperation.vMultipleOCMapInfo);
	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");
	}
}

if(strErrMsg == null)
{

		dTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(dTutionFee > 0d)
	{
		dMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		dCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
				WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
		dOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));

		dMiscOtherFee = fOperation.getMiscOtherFee();

		fTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),null);
								
		//calculate discount during enrollment.
		enrollment.FAFeeOperationDiscountEnrollment faEnrlDiscount =
								new enrollment.FAFeeOperationDiscountEnrollment();
    	vTemp = faEnrlDiscount.calEnrollmentDateDiscount(dbOP,(float)dTutionFee, (float)(dTutionFee + dMiscFee + dCompLabFee),
		(String)vStudInfo.elementAt(0),false, WI.fillTextValue("sy_from"),
        	WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),
                fOperation.dReqSubAmt);
    	if (vTemp != null && vTemp.size() > 0 && vTemp.elementAt(0) != null) {
      		fEnrolmentDiscount = ( (Float) vTemp.elementAt(1)).floatValue();
      		//System.out.println(fEnrolmentDiscount);
			fTotalDiscount += fEnrolmentDiscount;
    	}
		dTotPayableAmt -= fTotalDiscount;
	}
	else
		strErrMsg = fOperation.getErrMsg();	
	
	/*vScheduledPmt = FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

	if(vScheduledPmt == null)
		strErrMsg = FA.getErrMsg();

	vScheduledPmt = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));*/
}
String strPrintedBy = CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1);
if(strErrMsg == null)
{
	vSubjectDtls = SOA.getEnrolledSubSummary(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                      WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vSubjectDtls == null || vSubjectDtls.size() ==0)
		strErrMsg = SOA.getErrMsg();

	///get here the other other school fee and adjustment payable.. 
/*	if(strSchoolCode.startsWith("CSA") || strSchoolCode.startsWith("VMA") || true){
		vTemp = FA.getOtherChargePayable(dbOP,WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"), (String)vStudInfo.elementAt(0));
		if(vTemp != null && vTemp.size() > 0) {
			strTemp = (String)vTemp.elementAt(0);
			if(strTemp != null && !strTemp.equals("0.00"))
				dOtherSchPayable = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		}
	}
	
	if(bolIsFatima) {
		dAddDropFee = 0d;//new enrollment.FAFeeMaintenance().addDropFeePayabaleBalance(dbOP, (String)vStudInfo.elementAt(0), WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
		if(dAddDropFee < 0d)
			dAddDropFee = 0d; 
		dOtherSchPayable = dOtherSchPayable - dAddDropFee;		

		String strSQLQuery = "select PLAN_NAME from FA_STUD_MIN_REQ_DP_PER_STUD "+
							"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.plan_ref = FA_STUD_MIN_REQ_DP_PER_STUD.plan_ref) "+
							" where is_temp_stud = 0 and stud_index = "+vStudInfo.elementAt(0)+
							" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester");
		strPlanInfo = dbOP.getResultOfAQuery(strSQLQuery, 0);

		if(strPlanInfo != null) {
			strSQLQuery = "select sum(fa_stud_payable.amount) from fa_stud_payable join fa_oth_sch_fee on (fa_oth_sch_fee.othsch_fee_index = reference_index) where user_index = "+
						vStudInfo.elementAt(0) +" and fa_stud_payable.sy_from = "+WI.fillTextValue("sy_from")+
						" and fa_stud_payable.semester = "+WI.fillTextValue("semester")+" and fa_stud_payable.is_valid = 1 and fee_name like 'installment%'";//reference_index = 582";//fee name is Installment Fee and sy_index = 0;
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null) {
				dInstallmentFee = Double.parseDouble(strSQLQuery);
				dOtherSchPayable = dOtherSchPayable - dInstallmentFee;
			}
		}
	}
*/
}


String[] astrConvertYrLevel = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
String[] astrConvertSem     = {"Summer","1ST SEM","2ND SEM","3RD SEM",
								"4TH SEM","5TH SEM","6TH SEM","7TH SEM"};
if(strErrMsg == null) strErrMsg = "";

 if(vStudInfo != null && vStudInfo.size() > 0)
 {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><Td align="right"><strong style="font-size:12px;"><%=((String)vStudInfo.elementAt(1)).toUpperCase()%> 
		<%=WI.getStrValue((String)vStudInfo.elementAt(16)+" "+(String)vStudInfo.elementAt(4),"--","-","")%></strong></Td></tr>
	<tr>
	    <Td align="right">
		<%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>,
		  S.Y. <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%></Td>
    </tr>
	<tr>
	    <Td align="right">Student # <%=strStudID%></Td>
    </tr>
	<tr>
	    <Td align="center"><strong style="font-size:13px;">*** STATEMENT OF ACCOUNTS ***</strong></Td>
    </tr>
</table> 
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td valign="top" width="33%">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
   
	    <tr>
          <td width="69%" height="14">TUITION FEE &nbsp; <strong><font size="1"><%=(String)vSubjectDtls.elementAt(2)%> <%=(String)vSubjectDtls.elementAt(3)%></font></strong></td>
          <td width="31%" height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dTutionFee,true)%></strong></font></div></td>
        </tr>    
		<%
		dTotPayableAmt += dTutionFee;
		dTotPayableAmt += (dMiscFee - dMiscOtherFee);
		%>
	    <tr>
          <td height="14">MISCELLANEOUS FEES</td>
          <td height="14"><div align="right">       
           <strong><%=CommonUtil.formatFloat(dMiscFee - dMiscOtherFee,true)%></strong>        
		</div></td>
        </tr>
         <%
		
		

		Vector vLabFee = new Vector();
		boolean bolShowLabFee = false;
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
				continue;			
			
			if(vLabCharges.indexOf((String)vMiscFeeInfo.elementAt(i)) > -1){
				vLabFee.addElement(vMiscFeeInfo.remove(i));
				vLabFee.addElement(vMiscFeeInfo.remove(i));
				vLabFee.addElement(vMiscFeeInfo.remove(i));
				i-=3;
				continue;		
			}
			if(!bolShowLabFee)
				bolShowLabFee = true;			
		}
		if(bolShowLabFee){
		%>
		<tr>
		  <td height="14"><font size="1">OTHER CHARGES</font></td>
          <td height="14"><div align="right"></div></td>
        </tr>
         <%
		 dMiscOtherFeeTemp = 0f;
			for(int i = 0; i< vMiscFeeInfo.size(); i +=3){						
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
				continue;
			try{
				dMiscOtherFeeTemp += Float.parseFloat((String)vMiscFeeInfo.elementAt(i+1));
			}catch(Exception e){}
		%>
        <tr>
          <td valign="top" height="14" style="padding-left:5px;"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td valign="top" height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
        <tr>
          <td height="14"><font size="1"><strong>TOTAL OTHER CHARGES</strong></font></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dMiscOtherFeeTemp,true)%></strong></font></div></td>
        </tr>
		
		<%dTotPayableAmt += dMiscOtherFeeTemp;}
		
		if(vLabFee != null && vLabFee.size() > 0){
			//vMiscFeeInfo = vLabFee;
		dMiscOtherFeeTemp = 0f;
		%>
		<tr>
		  <td height="14"><font size="1">LABORATORY FEES</font></td>
          <td height="14"><div align="right"></div></td>
        </tr>
         <%
		for(int i = 0; i< vLabFee.size(); i +=3){		
		try{
				dMiscOtherFeeTemp += Float.parseFloat((String)vLabFee.elementAt(i+1));
			}catch(Exception e){}				
		%>
        <tr>
          <td valign="top" height="14" style="padding-left:5px;"><font size="1"><%=(String)vLabFee.elementAt(i)%></font></td>
          <td valign="top" height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vLabFee.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
        <tr>
          <td height="14"><font size="1"><strong>TOTAL LABORATORY FEES</strong></font></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dMiscOtherFeeTemp,true)%></strong></font></div></td>
        </tr>
		<%dTotPayableAmt += dMiscOtherFeeTemp;}
		
		
		
		if(vOthSchFeePayment != null && vOthSchFeePayment.size() > 0){			
		//dMiscOtherFeeTemp = 0f;
		%>
		<tr>
		  <td height="14"><font size="1">OTHER SCHOOL FEES</font></td>
          <td height="14"><div align="right"></div></td>
        </tr>
         <%
		for(int i = 0; i< vOthSchFeePayment.size(); i +=3){								
		%>
        <tr>
          <td valign="top" height="14" style="padding-left:5px;"><font size="1"><%=(String)vOthSchFeePayment.elementAt(i)%></font></td>
          <td valign="top" height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vOthSchFeePayment.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
        <tr>
          <td height="14"><font size="1"><strong>TOTAL OTHER SCHOOL FEES</strong></font></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dTotOthSchFee,true)%></strong></font></div></td>
        </tr>
		<%dTotPayableAmt += dTotOthSchFee;}%>
		
      </table>
	  <%
	  if(false && dOutstanding > 0d){
	  %>
	  <br><br>
	  <table width="95%" border="0" cellpadding="0" cellspacing="0">
	  	<tr><td><strong>PREVIOUS BALANCE</strong></td></tr>
	  </table>		
	 <%}%>
	 </td>
		
		
		
		<td valign="top" align="center" width=""><br>
		<table width="95%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		    <td colspan="3" align="center">&nbsp;<strong>PAYMENTS MADE</strong></td>
		    </tr>
		<tr>
            <td width="43%">OR DATE</td>
            <td width="27%">OR #</td>
            <td width="30%" align="right">AMOUNT</td>
          </tr>
          <%
double dBalance = 0d;
double dDebit = 0d;

double dPaymentMade = 0d;

if(vPayment != null && vPayment.size() > 0){
	for(int i = 0; i < vPayment.size(); i += 6){
		if( WI.getStrValue(vPayment.elementAt(i+4)).equals("-1") )
			continue;
		dDebit = Double.parseDouble((String)vPayment.elementAt(i));
		dPaymentMade += dDebit;
	%>
          <tr>
            <td valign="top"><%=ConversionTable.convertMMDDYYYY((java.util.Date)vPayment.elementAt(i + 2))%>&nbsp;&nbsp;&nbsp;			</td>
			<%
			
			strTemp = (String)vPayment.elementAt(i + 1);
			if(strTemp == null)
				strTemp = (String)vPayment.elementAt(i + 3);
			%>
            <td valign="top"><%=WI.getStrValue(strTemp)%></td>
            <td valign="top" align="right"><%=CommonUtil.formatFloat((float)dDebit,true)%></td>
          </tr>
         
<%}%>
		 <tr>
              <td colspan="2"><strong>TOTAL AMOUNT PAID</strong></td>
              <td align="right"><strong><%=CommonUtil.formatFloat(dPaymentMade,true)%></strong></td>
          </tr>
<%}%>
		</table>
		<br><br><br><br><br><br>
		<table style="border:solid 1px #000000;" width="95%" border="0" cellpadding="0" cellspacing="0">
			<tr><td colspan="3">MODES OF PAYMENTS</td></tr>
				<%
				//dTotPayableAmt = (dTutionFee + dCompLabFee + dMiscFee + dOutstanding) - fTotalDiscount;
				vTemp = new Vector();
				dTotPayableAmt += dOutstanding;
				
				vTemp.addElement("On Registration");vTemp.addElement("35% of SubTotal");vTemp.addElement(Double.toString(dTotPayableAmt * .35));
				vTemp.addElement("1st Term Midterm ");vTemp.addElement("20%");vTemp.addElement(Double.toString(dTotPayableAmt * .2));
				vTemp.addElement("1st Term Finals");vTemp.addElement("20%");vTemp.addElement(Double.toString(dTotPayableAmt * .2));
				vTemp.addElement("2nd Term Midterm");vTemp.addElement("20%");vTemp.addElement(Double.toString(dTotPayableAmt * .2));
				vTemp.addElement("2nd Term Finals");vTemp.addElement("5%");vTemp.addElement(Double.toString(dTotPayableAmt * .05));
				iExamOrder++; //add 1 for downpayment
				for(int i =0; i < vTemp.size(); i+=3){
					if(iExamOrder-- == 0)
						break;
					strTemp = (String)vTemp.elementAt(i+2);//need to do this 3 line of code, bec. it they will complain even .01 cent missing.
					strTemp = CommonUtil.formatFloat(strTemp,true);
					strTemp = ConversionTable.replaceString(strTemp, ",","");
					dExamPayable += Double.parseDouble(strTemp);					
				}
				while(vTemp.size() > 0){%>		
			<tr>
          <td width="44%" height="14" style="padding-left:10px;"><%=vTemp.remove(0)%></td>
          <td width="31%"><%=vTemp.remove(0)%></td>
          <td width="25%" align="right"><%=CommonUtil.formatFloat((String)vTemp.remove(0),true)%></td>
			</tr>
		 <%}%>
		 <tr><td colspan="3">&nbsp;</td></tr>
		 <tr><td colspan="2"><strong>AMOUNT DUE ON <%=WI.getStrValue(strExamName)%> </strong></td>
		     <td align="right"><strong><%=CommonUtil.formatFloat(dExamPayable - dPaymentMade,true)%></strong></td>
		 </tr>
		</table>		</td>
		<td width="33%" valign="top" align="center">
		<table width="95%" border="0" cellpadding="0" cellspacing="0">
			<tr><Td align="center"><strong>Summary of Charges</strong></Td></tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
   		<%
		dBalance += dTutionFee;
		
		%>
	    <tr>
          <td width="69%" height="14">TUITION FEES</td>
          <td width="31%" height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dTutionFee,true)%></strong></font></div></td>
        </tr>    

	    <tr>
          <td height="14">MISCELLANEOUS</td>
		  <%
		  dBalance += (dMiscFee - dMiscOtherFee);
		  
		  %>
          <td height="14"><div align="right">
       
           <strong><%=CommonUtil.formatFloat(dMiscFee - dMiscOtherFee,true)%></strong>
        
		</div></td>
        </tr>
         <%
		 dMiscOtherFeeTemp = 0d;
		 for(int i = 0; i< vMiscFeeInfo.size(); i +=3){						
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
				continue;
			try{
				dMiscOtherFeeTemp += Float.parseFloat((String)vMiscFeeInfo.elementAt(i+1));
			}catch(Exception e){}
			}
		if(dMiscOtherFeeTemp > 0d){
			dBalance += dMiscOtherFeeTemp;
			
		 %>
		<tr>
		  <td height="14"><font size="1">OTHER CHARGES</font></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dMiscOtherFeeTemp,true)%></strong></font></div></td>
        </tr>		
		<%}
		
		if(vLabFee != null && vLabFee.size() > 0){
			//vMiscFeeInfo = vLabFee;
			dMiscOtherFeeTemp = 0d;
			for(int i = 0; i< vLabFee.size(); i +=3){		
		try{
				dMiscOtherFeeTemp += Float.parseFloat((String)vLabFee.elementAt(i+1));
			}catch(Exception e){}}
		dBalance += dMiscOtherFeeTemp;
		
		%>
		<tr>
		  <td height="14"><font size="1">LABORATORY FEES</font></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dMiscOtherFeeTemp,true)%></strong></font></div></td>
        </tr>		         
		<%}
		if(dTotOthSchFee > 0){
			dBalance += dTotOthSchFee;
			
		%>	
		<tr>
		    <td height="14"><font size="1">OTHER SCHOOL FEES</font></td>
		    <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dTotOthSchFee,true)%></strong></font></div></td>
		</tr>
		<%}
		if(dOutstanding > 0d){
		dBalance += dOutstanding;
		%>		
		
		<tr>
		    <td height="14">PREVIOUS BALANCE</td>
		    <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dOutstanding,true)%></strong></font></div></td>
		</tr>
		<%}%>
		<tr>
		    <td height="14"><strong>SUB-TOTAL</strong></td>
		    <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dBalance,true)%></strong></font></div></td>
		</tr>
		<%
		if(fTotalDiscount > 0f){
		dBalance -= fTotalDiscount;
		
		%>
		<tr>
		    <td height="14">Less: Discount</td>
		    <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTotalDiscount,true)%></strong></font></div></td>
	    </tr>
		<%}if(dPaymentMade > 0d){%>
		<tr>
		    <td height="14">Less: Total Payments</td>
		    <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dPaymentMade,true)%></strong></font></div></td>
	    </tr>
		<%}%>
		<tr>
		    <td height="14"><strong>TOTAL BALANCE</strong></td>
		    <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dBalance - dPaymentMade,true)%></strong></font></div></td>
	    </tr>
		<tr><td align="center" colspan="2">TOTAL BALANCE as of today<br><%=WI.getTodaysDate(6)%><br><br>
		Php <strong><%=CommonUtil.formatFloat(dBalance - dPaymentMade,true)%></strong></td></tr>
      </table>
  		</td>
	</tr>
	<tr><td height="30" colspan="3">Exam Date: <%=WI.getStrValue(strExamDate)%><br>
	Due Date : On or before exam date.<br>
	</td></tr>
	<tr>
	    <td colspan="2" valign="top" style="padding-left:10px;">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td><strong>NOTE:</strong></td>
				<td>1. Please pay PhP 30.00 for a second or every lost copy of this Statement of Account.</td>
			</tr>
			<tr>
			    <td>&nbsp;</td>
			    <td>2. Please disregard this statement of account if full payment has been made.</td>
			    </tr>
			<tr>
			    <td>&nbsp;</td>
			    <td>3. You can pay directly to Pen Bank RD plaza branch, Security Bank Santiago Branch.</td>
			    </tr>
			<tr>
			    <td>&nbsp;</td>
			    <td>4. This is a system generated notice. No signature is necessary.<br><font size="2"><strong>T h a n k &nbsp; Y o u.</strong></font></td>
			    </tr>
		</table>
		</td>
	    <td valign="top" align="center">
		<table width="95%" border="0" cellpadding="0" cellspacing="0">
	  	<tr><td>Prepared by:</td></tr>
		<%
		strTemp = (String)request.getSession(false).getAttribute("first_name");
		%>
		<tr><td align="center" valign="bottom" height="40"><div style="border-bottom: solid 1px #000000; width:90%;"><%=WI.getStrValue(strTemp)%></div>Accounts In-Charge</td></tr>
	  </table>
		</td>
    </tr>
</table>












<%
}//if(vStudInfo != null && vStudInfo.size() > 0) %>
 

</body>
</html>
<%
dbOP.cleanUP();
%>
