<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,
	enrollment.FAAssessment,enrollment.SubjectSection,enrollment.EnrlAddDropSubject,java.util.Vector" %>
<%
	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	boolean bolIsFatima = strSchoolCode.startsWith("FATIMA");
	
	if(strSchoolCode == null) {
		%>
		<font style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:#FF0000">
			You are already logged out. Please login again to access this page.
		<%
		return;
	}
	//strSchoolCode = "UL";

	WebInterface WI = new WebInterface(request);

boolean bolIsTempStudyLoad = WI.fillTextValue("temp_sl").equals("1");	


	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Assessment Form</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

@page {
	size:8.50in 3.70in; 
	margin:.1in .1in .1in .1in; 
}

@media print { 
  @page {
		size:8.50in 3.70in; 
		margin:.1in .1in .1in .1in; 
	}
}

body {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborder {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TABLE.thinborderALL {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

</style>
</head>

<body onLoad="window.print();" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
<%
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp = null;
	String strSubSecIndex = null;
	Vector vLabSched      = null;
	java.sql.ResultSet rs = null;
	String strDegreeType  = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	
	String strSYFrom   = WI.fillTextValue("sy_from");
	String strSYTo     = WI.fillTextValue("sy_to");
	String strSemester = WI.fillTextValue("semester");
	String strStudID   = WI.fillTextValue("stud_id"); 
	String strExamPeriod = WI.fillTextValue("pmt_schedule");
	//String strExamName   = WI.fillTextValue("grade_name");
	String strExamName = null;
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
	
	if(strExamPeriod.length() > 0){
		strTemp = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+strExamPeriod;
		strExamName = dbOP.getResultOfAQuery(strTemp, 0);
		if(strExamName != null && !strExamName.toLowerCase().startsWith("prelim")){
			dbOP.cleanUP();
		%><jsp:forward page="./exam_permit_print_SWU.jsp"></jsp:forward>
		<%return;}
	}	
	
	//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;
//end of authenticaion code.

Vector vStudInfo = null;
Vector vMiscFeeInfo = null;
Vector vTemp = null;

float fTutionFee        = 0f;
float fCompLabFee       = 0f;
float fMiscFee          = 0f;
float fOutstanding      = 0f;
float fTotalPayableAmt 	= 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,

///newly added 
double dTotalPayment  = 0d;
double dAdjustment    = 0d;
double dTotalDiscount = 0d;
double dOSBalance     = 0d;
double dAddCharge     = 0d;
double dDueForThisPeriod = 0d;
double dBalance       = 0d;//this sy/term balance.
//end of newly added..
boolean bolIsBasic = false;
float fEnrollmentDiscount = 0f; //this sum of full payment, early enrollment or late enrollment discount/fine implementations.
String strEnrolmentDiscDetail = null;
//float fPayableAfterDiscount = 0f;

String strCollegeName = null; 
String strDeanName    = null;
//if(strSchoolCode != null && strSchoolCode.startsWith("UDMC"))
//	strSchoolCode = "CGH";

double dReservationFee = 0d;//only for CGH.

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();
enrollment.FAStudentLedger faStudLedg = new enrollment.FAStudentLedger();

Vector vAssessedSubDetail = null;
Vector vInstallmentDtls = null;

double dDebit = 0d;
double dDPFineCGH = 0d;
double dFatimaInstallmentFee = 0d;



vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),	strStudID,strSYFrom, strSYTo, strSemester);
if(vStudInfo == null) 
	strErrMsg = enrlStudInfo.getErrMsg();
else {//System.out.println(vStudInfo);
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	reportEnrl.autoGenAdmSlipNum(dbOP, (String)vStudInfo.elementAt(0),strExamPeriod, strSYFrom, strSemester,(String)request.getSession(false).getAttribute("userIndex"));

	bolIsBasic = ((String)vStudInfo.elementAt(5)).equals("0");
	
	paymentUtil.setTempUser("0");
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4), strSYFrom, strSYTo, strSemester,false,false,true);//System.out.println("Test : "+vMiscFeeInfo);

	strCollegeName = (String)vStudInfo.elementAt(18);
	strDeanName    = (String)vStudInfo.elementAt(20);

	if(vMiscFeeInfo == null)
		vMiscFeeInfo = new Vector();
//		strErrMsg = paymentUtil.getErrMsg();
}
if(strErrMsg == null) //collect fee details here.
{
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					strSYFrom, strSYTo,(String)vStudInfo.elementAt(4),strSemester);
	//System.out.println(fTutionFee);
	if(fTutionFee > 0f)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					strSYFrom,strSYTo,(String)vStudInfo.elementAt(4),strSemester);
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					strSYFrom,strSYTo,(String)vStudInfo.elementAt(4),strSemester);
		fOperation.checkIsEnrolling(dbOP, (String)vStudInfo.elementAt(0),
				strSYFrom,strSYTo,strSemester);
		/**
		fOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));
		//I have to remove the ledg_history informations.
		if(!paymentUtil.isTempStud()) {
			double dLedgHistoryExcess = fOperation.calLedgHistoryEntryAfterASYTerm(dbOP, (String)vStudInfo.elementAt(0),
            	                                         strSYFrom, strSemester);
			if(dLedgHistoryExcess != fOperation.fDefaultErrorValue)
				fOutstanding -= (float)dLedgHistoryExcess;
		}**/
		fMiscOtherFee = fOperation.getMiscOtherFee();

		enrollment.FAFeeOperationDiscountEnrollment test = new enrollment.FAFeeOperationDiscountEnrollment();
		vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					strSYFrom,strSYTo,
                                        (String)vStudInfo.elementAt(4),strSemester,
                                        fOperation.dReqSubAmt);
		if(vTemp != null && vTemp.size() > 0)
			strEnrolmentDiscDetail = (String)vTemp.elementAt(0);//System.out.println(vTemp);
		if(strEnrolmentDiscDetail != null && vTemp != null && vTemp.size() > 0)
		{
			dTotalDiscount = ((Float)vTemp.elementAt(1)).floatValue();
			//fPayableAfterDiscount = fTutionFee+fMiscFee+fCompLabFee+fOutstanding-fEnrollmentDiscount;
		}

		
	}
	//else
	//	strErrMsg = fOperation.getErrMsg();
	
	strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5), "degree_type"," and is_valid=1 and is_del=0");
	vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
				strSYFrom,strSYTo,(String)vStudInfo.elementAt(4),
				strSemester,"1",strDegreeType);
	if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0)
		strErrMsg = FA.getErrMsg();
}
//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null)
{
	if(fMiscFee > 0.1f) {
		vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
						strSYFrom,strSYTo,(String)vStudInfo.elementAt(4),strSemester);
		if(vTemp == null)
			strErrMsg = null;
			//strErrMsg = paymentUtil.getErrMsg();
		else
			vMiscFeeInfo.addAll(vTemp);//System.out.println(vMiscFeeInfo);
	}
	if(fOperation.vMultipleOCMapInfo != null && fOperation.vMultipleOCMapInfo.size() > 0) 
		vMiscFeeInfo.addAll(fOperation.vMultipleOCMapInfo);

	//add here the laboratory deposit if there is any.
	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");
	}

	vInstallmentDtls = FA.getInstallmentSchedulePerStudPerExamSch(dbOP,strExamPeriod, (String)vStudInfo.elementAt(0),
							strSYFrom,strSYTo,(String)vStudInfo.elementAt(4), strSemester) ;
	if(vInstallmentDtls == null)
		strErrMsg = FA.getErrMsg();
	else {
		dDueForThisPeriod = Double.parseDouble((String)vInstallmentDtls.elementAt(5));
	}
	//get this sy/term balance.. 
	dBalance = fOperation.calOutStandingOfPrevYearSem(dbOP,(String)vStudInfo.elementAt(0), true, true, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"), null);
	if(dDueForThisPeriod > dBalance)
		dDueForThisPeriod = dBalance;
	if(dDueForThisPeriod < 0d)
		dDueForThisPeriod = 0d;
	//System.out.println("Balance: "+dBalance);

	///get other Information here.. 
	strTemp = "select sum(amount) from fa_stud_payment where user_index = "+(String)vStudInfo.elementAt(0)+
			  " and sy_from = "+strSYFrom+" and semester = "+strSemester+
			  " and or_number is null and is_valid = 1";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null)
		dAdjustment = Double.parseDouble(strTemp);//debit / credit entry. 

	//get add charge.. 
	String strAddFeeIndex = null;
	
	strTemp = "select othsch_fee_index from fa_oth_sch_fee join FA_OTH_SCH_FEE_TUITION on (FA_OTH_SCH_FEE_TUITION.fee_name_t = fee_name) "+
				"where sy_index = (select sy_index from fa_schyr where sy_from = "+strSYFrom+") and is_valid = 1";
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		if(strAddFeeIndex == null) 
			strAddFeeIndex = rs.getString(1);
		else	
			strAddFeeIndex = strAddFeeIndex + ","+rs.getString(1);
	}
	rs.close();
	strTemp = "select othsch_fee_index from fa_oth_sch_fee where sy_index = (select sy_index from fa_schyr where sy_from = "+strSYFrom+") and is_valid = 1 "+
				" and (fee_name = 'MockBoard' or fee_name = 'Additional Energy Consumption Fee') ";
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		if(strAddFeeIndex == null) 
			strAddFeeIndex = rs.getString(1);
		else	
			strAddFeeIndex = strAddFeeIndex + ","+rs.getString(1);
	}
	rs.close();
	
	
	if(strAddFeeIndex != null) {
		strTemp = "select sum(amount) from fa_stud_payable where reference_index in( "+strAddFeeIndex+" ) and user_index = "+(String)vStudInfo.elementAt(0)+
					" and sy_from = "+strSYFrom +" and semester = "+strSemester+" and is_valid = 1 and payable_type = 0";
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null)
			dAddCharge = Double.parseDouble(strTemp); 
	}
	///get total payment.. 
	strTemp = "select sum(amount) from fa_stud_payment where user_index = "+(String)vStudInfo.elementAt(0)+" and sy_from = "+strSYFrom+
				" and semester = "+strSemester+" and is_valid = 1 and or_number is not null and (payment_for = 0 or payment_for = 10) ";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null)
		dTotalPayment = Double.parseDouble(strTemp); 
	//now get payment for add/drop fee. 
	if(strAddFeeIndex != null) {
		strTemp = "select sum(amount) from fa_stud_payment where user_index = "+(String)vStudInfo.elementAt(0)+" and sy_from = "+strSYFrom+
				" and semester = "+strSemester+" and is_valid = 1 and othsch_fee_index in ("+strAddFeeIndex+")";
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null)
			dTotalPayment += Double.parseDouble(strTemp); 
	}

	//get discounts.. 
	Vector vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), null,
				WI.fillTextValue("semester"), false);
	if(vLedgerInfo != null) {
		Vector vTimeSch 			= (Vector)vLedgerInfo.elementAt(0);
		Vector vTuitionFeeDetail	= (Vector)vLedgerInfo.elementAt(1);
		Vector vAdjustment			= (Vector)vLedgerInfo.elementAt(2);
		Vector vRefund				= (Vector)vLedgerInfo.elementAt(3);
		Vector vDorm 				= (Vector)vLedgerInfo.elementAt(4);
		Vector vOthSchFine			= (Vector)vLedgerInfo.elementAt(5);//System.out.println(vOthSchFine);
		Vector vPayment			= (Vector)vLedgerInfo.elementAt(6);
		if(vTimeSch == null || vTimeSch.size() ==0)
			strErrMsg = faStudLedg.getErrMsg();
		else {
			if(vAdjustment != null) {
				for(int i = 1; i < vAdjustment.size(); i += 7){
					dTotalDiscount += Double.parseDouble((String)vAdjustment.elementAt(i + 1));
				}
			}
		}
		dOSBalance = ((Double)vTuitionFeeDetail.elementAt(0)).doubleValue();
		//System.out.println("vScheduledPmt : "+vScheduledPmt);
	}




}
if(fMiscFee <=0.1f) {
	vMiscFeeInfo = new Vector();
	vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");
}


//System.out.println(fOperation.vAssessedHrDetail);
boolean bolShowMiscDtls = false;
boolean bolShowOthChargeDtls = false;
boolean bolShowExamDate = false;


if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">

    <tr >
      <td height="35" ><div align="center">
	  <strong><%=strErrMsg%></strong></div></td>
    </tr>
</table>
<%
	dbOP.cleanUP();
	return;
}

///get lab fee charges.. 
Vector vInputInfo = new Vector();
vInputInfo.addElement((String)vStudInfo.elementAt(5));//[0] course_index, 
vInputInfo.addElement((String)vStudInfo.elementAt(6));//[1] major_index, 
vInputInfo.addElement(strSYFrom);//[2] sy_from, 
vInputInfo.addElement(strSemester);//[3] semester, 
vInputInfo.addElement((String)vStudInfo.elementAt(4));//[4] yr_level,\

//get here lab fee charges.
FA.getLabFee(dbOP, vInputInfo);
if(strExamName.toUpperCase().equals("FINALS"))
	strExamName = "Final";
%>

 
<%if(vStudInfo != null && vStudInfo.size() > 0){
	
	
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0) {
	
	
/*//subject that tuition is per subject
strTemp = " select distinct subject.sub_code "+
	" from FA_TUTION_FEE "+
	" join subject on (subject.sub_index = fa_tution_fee.sub_index)  "+
	" where sy_index = (select sy_index from fa_schyr where sy_from = "+WI.fillTextValue("sy_from")+") and (ID_RANGE_INDEX is null or ID_RANGE_INDEX = 2)   "+
	" and fa_tution_fee.is_valid = 1 and fa_tution_fee.is_del=0  "+ 
	" and subject.is_del = 0 ";
rs = dbOP.executeQuery(strTemp);
Vector vTuitionPerSubject = new Vector();
while(rs.next()){
	vTuitionPerSubject.addElement(rs.getString(1));
}rs.close();*/

	
	

float fFirstInstalAmt = 0f; int iCount = 0;
float fTotalLoad = 0;float fUnitsTaken = 0f;

float fTotalUnit = 0;

String strSchedule = null;
String strRoomAndSection = null; String strSection = null;
String strLecLabStat = null;//0 = both,1 = lab, 2 = lec.
String strRatePerUnit = null;String strAssessedHour = null;//only if it is UI and the assessment is per hour.
Vector vSubSecDtls = new Vector();
String strFeeTypeCatg = null; //0=>per unit,1= per lec/lab, 2=per subject,3=total tuition fee.

int iIndex = 0;
String strSubTotalRate = null;//System.out.println(fOperation.vTuitionFeeDtls);

java.sql.PreparedStatement pstmtGetLecLabStat = null;
strTemp = "select IS_ONLY_LAB from enrl_final_cur_list where sub_sec_index=? and enrl_final_cur_list.is_valid = 1 and "+
			"user_index = "+(String)vStudInfo.elementAt(0)+" and IS_TEMP_STUD = "+paymentUtil.isTempStudInStr();
pstmtGetLecLabStat = dbOP.getPreparedStatement(strTemp);

String strLabFee = null;
int iIndexOf = 0;
int iRowCount = 0;
int iMaxRowCount = 7;
boolean bolPageBreak = false;




for(int i = 0; i< vAssessedSubDetail.size() ; ){
	
	if(bolPageBreak){
		bolPageBreak = false;
	%>
   <div style="page-break-after:always;">&nbsp;</div>
   <%}
//if(i == 0)   {//show on first page
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="47%" height="18"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
		<td width="28%"><%=strExamName.toUpperCase()%> EXAMINATION PERMIT</td>
		<td width="25%"><%=WI.getTodaysDateTime()%></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="47%" height="18"><%=WI.getStrValue(vStudInfo.elementAt(18)).toUpperCase()%></td>
		<%
		if(Integer.parseInt(strSemester) == 0)
			strTemp = strSYTo;
		else
			strTemp = strSYFrom+" - "+strSYTo;
		%>
		<td width="53%"><%if(!bolIsBasic){%><%=astrConvertSem[Integer.parseInt(strSemester)]%>, <%}else{%>S.Y. <%}%><%=strTemp%></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="18" width="28%"><%=(String)vStudInfo.elementAt(1)%></td>
		<%
		if(bolIsBasic)
			strTemp = dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(4)));
		else{
			strTemp = (String)vStudInfo.elementAt(16);
				if(vStudInfo.elementAt(6) != null)
					strTemp += " / "+WI.getStrValue((String)vStudInfo.elementAt(22));
		
			  strTemp += WI.getStrValue((String)vStudInfo.elementAt(4), " - ","","");
		}
		%>
		<td width="19%"><%=strTemp%></td>
		<td width="53%"><%=strStudID%></td>
	</tr>
</table>
<%//}%>


<table width="100%" cellpadding="0" cellspacing="0" border="0" class="">
	<tr>
   	<td width="8%">&nbsp;</td>
      <td class="" width="3%">No.</td>
      <td class="" width="14%" align="center">Subject</td>
      <td class="" width="40%" align="center">Description</td>
      <td class="" width="7%" align="center">Units</td>
      <td class="" width="14%" align="right">Tuition</td>
      <td class="" width="14%" align="right">Lab-Fee</td>
   </tr>
   
   <%

		for(; i< vAssessedSubDetail.size() ; i+=10)
		{
			if(strFeeTypeCatg == null)	strFeeTypeCatg = (String)vAssessedSubDetail.elementAt(8);
	
			fTotalUnit = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+3))+Float.parseFloat((String)vAssessedSubDetail.elementAt(i+4));
			fTotalLoad += fTotalUnit;
			fUnitsTaken += Float.parseFloat((String)vAssessedSubDetail.elementAt(i+9));
			strSubSecIndex = (String)vAssessedSubDetail.elementAt(i);
	
			strTemp = (String)vAssessedSubDetail.elementAt(i+1);
			if(strTemp.indexOf("NSTP") != -1){
			  iIndex = strTemp.indexOf("(");
			  if(iIndex != -1){
				strTemp = strTemp.substring(0,iIndex);
				strTemp = strTemp.trim();
				vAssessedSubDetail.setElementAt(strTemp, i+1);
			  }
			}
			if( (iIndex = fOperation.vTuitionFeeDtls.indexOf(strTemp)) != -1) {
				strRatePerUnit = (String)fOperation.vTuitionFeeDtls.elementAt(iIndex+1);
				strSubTotalRate  = (String)fOperation.vTuitionFeeDtls.elementAt(iIndex+2);
				if(iIndex %3 > 0)
					iIndex = iIndex / 3 + 1;
				else
					iIndex = iIndex / 3;
	
				if(fOperation.vAssessedHrDetail != null && fOperation.vAssessedHrDetail.size() > iIndex)
					strAssessedHour = (String)fOperation.vAssessedHrDetail.elementAt(iIndex);
				else
					strAssessedHour = "&nbsp;";
			}
			else {
				strRatePerUnit = "0.00";
				strSubTotalRate  = "0.00";
				strAssessedHour = "&nbsp;";
			}
	
	/**
			strLecLabStat  = dbOP.mapOneToOther("enrl_final_cur_list","sub_sec_index",strSubSecIndex, "IS_ONLY_LAB",
				" and enrl_final_cur_list.is_valid = 1 and enrl_final_cur_list.is_del = 0 and user_index = "+
				(String)vStudInfo.elementAt(0)+" and IS_TEMP_STUD = "+paymentUtil.isTempStudInStr());
	**/
			strLecLabStat = null;
			if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
				pstmtGetLecLabStat.setString(1,strSubSecIndex);
				rs = pstmtGetLecLabStat.executeQuery();
				if(rs.next())
					strLecLabStat = rs.getString(1);
				rs.close();
			}
			
			//get schedule here.
			if(strSubSecIndex != null && strSubSecIndex.compareTo("-1") != 0) {
				vSubSecDtls = SS.getRoomScheduleDetailInMWF(dbOP, strSubSecIndex);
				vLabSched   = SS.getLabSched(dbOP,strSubSecIndex);
			}else {
				vSubSecDtls = null;vLabSched = null;
			}
			if(vSubSecDtls == null || vSubSecDtls.size() ==0)
			{
				if(strSubSecIndex != null && strSubSecIndex.compareTo("-1") == 0) {//re-enrollment.
					vSubSecDtls = new Vector();
				}
				else {
					strErrMsg = SS.getErrMsg();
					break;
				}
			}
			//if(strSubSecIndex.equals("24678")) {
			//	System.out.println(strSchedule);
			//	System.out.println(strSchedule);
			//}
			for(int b=0; b<vSubSecDtls.size(); ++b)
			{
				if(strLecLabStat != null && strLecLabStat.compareTo("1") == 0)//lab only.
					break;
	
				if(strRoomAndSection == null)
				{
					strSection = (String)vSubSecDtls.elementAt(b);
					strRoomAndSection = (String)vSubSecDtls.elementAt(b+1);
					strSchedule = (String)vSubSecDtls.elementAt(b+2);
				}
				else
				{
					strRoomAndSection += "<br>"+(String)vSubSecDtls.elementAt(b+1);
					strSchedule += "<br>"+(String)vSubSecDtls.elementAt(b+2);
				}
				b = b+2;
			}
			if(vLabSched != null)
			{
			  for (int p = 0; p < vLabSched.size(); ++p)
			  {
				  if(strLecLabStat != null && strLecLabStat.compareTo("2") == 0)//lec only.
					break;
				strSchedule += "<br>"+(String)vLabSched.elementAt(p+2);
				strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1);
				p = p+ 2;
			  }
			}
			
			strLabFee = null;
		
			if(FA.vCommonVector != null) {
				iIndexOf = FA.vCommonVector.indexOf((String)vAssessedSubDetail.elementAt(i+1));
				if(iIndexOf > -1) {
					strLabFee = (String)FA.vCommonVector.elementAt(iIndexOf + 2);
				}
			}
			
	strTemp = (String)vAssessedSubDetail.elementAt(i+2);
	if(strTemp.length() > 26) 
		strTemp = strTemp.substring(0, 26);
	%>
	  <tr >
     	<td>_________</td>
		<td height="16" class=""><%=++iCount%>.</td>
		<td><%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
      <td class=""><%=(String)vAssessedSubDetail.elementAt(i+2)%></td>
		<td class="" align="center"><%=(String)vAssessedSubDetail.elementAt(i+9)%></td>
      <%
		/*strTemp = WI.getStrValue((String)vAssessedSubDetail.elementAt(i+5),"0.00");
		if(vTuitionPerSubject.indexOf((String)vAssessedSubDetail.elementAt(i+1)) > -1)
			strTemp = WI.getStrValue((String)vAssessedSubDetail.elementAt(i+5),"0.00");
		else
			strTemp = CommonUtil.formatFloat( 
				Double.parseDouble(WI.getStrValue((String)vAssessedSubDetail.elementAt(i+5),"0.00")) * 
				Double.parseDouble((String)vAssessedSubDetail.elementAt(i+9)), true );*/
		%>
      <td align="right" class=""><%=WI.getStrValue(strSubTotalRate,"0.00")%></td>
		<td align="right" class=""><%=WI.getStrValue(strLabFee,"0.00")%></td>
	  </tr>
	  <% 	  
	strRoomAndSection = null;
	strSchedule = null;
	if(iRowCount++ >= iMaxRowCount){
		iRowCount = 0;
		i+=10;
		bolPageBreak = true;
		break;	
	}
	}%>
   
</table>
<%}%>

	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td width="49%" valign="top">&nbsp;
				
			</td>
			<td width="51%" valign="top">
<%
if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && fTutionFee > 0) {//bolIsTempStudyLoad = true;
	//get here payment detail payment method detail.
	Vector[] vRetResult = faPayment.viewTutionFeePaymentDetail(dbOP,(String)vStudInfo.elementAt(0),strSYFrom,
							strSYTo,(String)vStudInfo.elementAt(4),strSemester,paymentUtil.isTempStudInStr(), "0");
if(vRetResult != null) {%><br>
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<%if(dOSBalance != 0d){%>
               <tr>
						<td height="18">Previous Balance </td>
						<td align="right"><%=CommonUtil.formatFloat(dOSBalance,true)%></td>
				</tr>
               <%}%>
					
					<tr>
						<td width="60%" height="18"><%if(bolIsTempStudyLoad || true){%>Total (Tuition / Lab Fee)<%}%></td>
						<td width="40%" align="right"><%=CommonUtil.formatFloat(fTutionFee + fMiscOtherFee + fCompLabFee,true)%></td>
					</tr>
					<!--<tr>
						<td height="18"><%if(bolIsTempStudyLoad || true){%>Lab Fee<%}%></td>
						<td align="right"><%=CommonUtil.formatFloat(fMiscOtherFee + fCompLabFee,true)%></td>
					</tr>-->
					<tr>
					  <td height="18"><%if(bolIsTempStudyLoad || true){%>Miscellaneous<%}%></td>
					  <td align="right"><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></td>
				  </tr>
              <%if(dAddCharge > 0d){%>
					<tr>
					  <td height="18">Add Charge </td>
					  <td align="right"><%=CommonUtil.formatFloat(dAddCharge,true)%></td>
				  </tr>
              <%}if(dAdjustment > 0d){%>
              <tr>
					  <td height="18">Adjustment</td>
					  <td align="right"><%=CommonUtil.formatFloat(dAdjustment,true)%></td>
				  </tr>
              <%}%>
					<tr>
					  <td height="18" align="center"><%if(bolIsTempStudyLoad || true){%>Total<%}%></td>
					  <td align="right" style="border-top:solid 1px #000000;">					  
<%=CommonUtil.formatFloat((fTutionFee+fMiscOtherFee+fCompLabFee+(fMiscFee - fMiscOtherFee)+dAddCharge+dOSBalance),true)%></td>
				  </tr>
					<!--<tr>
					  <td height="18"><%if(bolIsTempStudyLoad || true){%>Discount Amt<%}%></td>
					  <td align="right"><%=CommonUtil.formatFloat(dTotalDiscount,true)%></td>
				  </tr>-->
					
					<!--<tr>
					  <td height="18"><%if(bolIsTempStudyLoad || true){%>Total Amount Paid<%}%></td>
					  <td align="right"><%=CommonUtil.formatFloat(dTotalPayment,true)%></td>
				  </tr>-->
				<!--	<tr>
					  <td colspan="2" align="center">____________________________________________________
					  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr><td></td></tr>
						</table> 
					 
					  </td>
				  </tr>  
					<tr>
					  <td height="18" style="font-weight:bold"><%=strExamName.toUpperCase()%> REQ.</td>
					  <td align="right" style="font-weight:bold"><%=CommonUtil.formatFloat(dDueForThisPeriod,true)%></td>
				  </tr>-->
				</table>
				
<%}//if vRetResult != null
}//show only if misc fee is not null%>			
			</td>
		</tr>
	</table>

	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>			
			<td width="33%">Released by: <%=(String)request.getSession(false).getAttribute("first_name")%></td>			
		</tr>
	</table>
<%
}//if vAssessedSubDetail no null

}//if(vStudInfo != null && vStudInfo.size() > 0){
dbOP.cleanUP();

%>
</body>
</html>
