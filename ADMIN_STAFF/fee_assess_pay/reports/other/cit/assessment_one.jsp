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
	/**
	if(WI.fillTextValue("pmt_schedule").equals("2")) {%>
		<jsp:forward page="./assessment_one_mterm.jsp" />
	<%return;	
	}
	**/
	

boolean bolIsTempStudyLoad = WI.fillTextValue("temp_sl").equals("1");	

boolean bolIsBatchPrint = WI.fillTextValue("batch_print").equals("1");
	
if(!bolIsBatchPrint){%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Assessment Form</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
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
-->
</style>
</head>

<body onLoad="window.print();" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
<%}
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
	String strExamName   = WI.fillTextValue("grade_name");

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

double dDPFineCGH = 0d;
double dFatimaInstallmentFee = 0d;

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),	strStudID,strSYFrom, strSYTo, strSemester);
if(vStudInfo == null) 
	strErrMsg = enrlStudInfo.getErrMsg();
else {//System.out.println(vStudInfo);
	paymentUtil.setTempUser("0");
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4), strSYFrom, strSYTo, strSemester,false,false,true);//System.out.println("Test : "+vMiscFeeInfo);

	strCollegeName = (String)vStudInfo.elementAt(18);
	strDeanName    = (String)vStudInfo.elementAt(20);

	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
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

		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5), "degree_type"," and is_valid=1 and is_del=0");
		vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					strSYFrom,strSYTo,(String)vStudInfo.elementAt(4),
					strSemester,"1",strDegreeType);
		if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0)
			strErrMsg = FA.getErrMsg();
	}
	else
		strErrMsg = fOperation.getErrMsg();
}
//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null)
{
	if(fMiscFee > 0.1f) {
		vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
						strSYFrom,strSYTo,(String)vStudInfo.elementAt(4),strSemester);
		if(vTemp == null)
			strErrMsg = paymentUtil.getErrMsg();
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
		//if(((String)vStudInfo.elementAt(0)).equals("34966")) {
			//System.out.println(vInstallmentDtls);
			//System.out.println(dDueForThisPeriod);
		//}
	}
	//get this sy/term balance.. 
	dBalance = fOperation.calOutStandingOfPrevYearSem(dbOP,(String)vStudInfo.elementAt(0), true, true, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"), null);
	if(dDueForThisPeriod > dBalance)
		dDueForThisPeriod = dBalance;
	if(dDueForThisPeriod < 0d)
		dDueForThisPeriod = 0d;
	//System.out.println("Balance: "+dBalance);
	if( ((String)vInstallmentDtls.elementAt(1)).toLowerCase().startsWith("final")) {
		strTemp = "select cur_hist_index from stud_curriculum_hist where user_index = "+(String)vStudInfo.elementAt(0)+" and is_valid = 1 ";
		if(WI.fillTextValue("semester").equals("1"))
			strTemp += " and sy_from = "+WI.fillTextValue("sy_from")+" and semester = 2";
		if(WI.fillTextValue("semester").equals("2"))
			strTemp += " and sy_from = "+WI.fillTextValue("sy_from")+" and semester = 0";
		if(WI.fillTextValue("semester").equals("0") || WI.fillTextValue("semester").equals("3"))
			strTemp += " and sy_from > "+WI.fillTextValue("sy_from");
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null) {
			dDueForThisPeriod = Double.parseDouble((String)vInstallmentDtls.elementAt(0)); 
		}	
	
	}

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

 <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="2"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
	  <%=strExamName.toUpperCase()%> ASSESSMENT
	  </font></div></td>
    </tr>
</table>
<%if(vStudInfo != null && vStudInfo.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td width="71%" height="18"><font size="2"><%=(String)vStudInfo.elementAt(1)%></font></td>
    <td width="29%" style="font-weight:bold"><%=astrConvertSem[Integer.parseInt(strSemester)]%>, AY <%=strSYFrom+" - "+strSYTo%> </td>
  </tr>
  <tr>
<%
strTemp = (String)vStudInfo.elementAt(15);
if(strTemp != null) {
	if(vStudInfo.elementAt(30).equals("1"))
		strTemp = "Returnee";
	else if(strTemp.startsWith("N"))
		strTemp = "Freshmen";
}
%>
    <td height="18" style="font-size:11px;"><%=strStudID%> &nbsp;&nbsp;&nbsp;[<%=strTemp%>]&nbsp;&nbsp;&nbsp;&nbsp;
	<%=(String)vStudInfo.elementAt(16)%>
        <%if(vStudInfo.elementAt(6) != null){%>
/ <%=WI.getStrValue(vStudInfo.elementAt(22))%>
<%}%> - 
<%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></td>
    <td style="font-size:11px"><%=WI.getTodaysDateTime()%></td>
  </tr>
  
</table>
<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0) {%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" height="225px">
		<tr>
			<td width="60%" valign="top">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	  <tr >
		<td width="20%" height="18" class="thinborder" style="font-size:11px;"><strong>SUBJECT </strong></td>
		<td width="20%" class="thinborder" style="font-size:11px;"><strong>SECTION</strong></td>
		<td width="5%" class="thinborder" style="font-size:11px;"><strong>UNITS</strong></td>
		<td width="55%" class="thinborder" style="font-size:11px;"><strong> LAB FEE </strong></td>
	  </tr>
	  <%//System.out.println(vAssessedSubDetail);
		float fFirstInstalAmt = 0f; int iCount = 0;
		float fTotalLoad = 0;float fUnitsTaken = 0f;
	//	float fTotalSubFee = 0;
		float fTotalUnit = 0;
	//	float fSubTotalRate = 0 ; //unit * rate per unit.
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
		
		///get the subject do not have lab fee (dry lab subject are the subject having subject fee in tuition)
		Vector vSubWithNoLabFee = new Vector();
		strTemp = "select sy_index from fa_schyr where sy_from = "+strSYFrom;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		
		strTemp = "select distinct sub_code from fa_tution_fee join subject on (subject.sub_index = fa_tution_fee.sub_index) "+
					"where fa_tution_fee.is_valid = 1 and sy_index = "+strTemp;
		rs = dbOP.executeQuery(strTemp);
		while(rs.next()) 
			vSubWithNoLabFee.addElement(rs.getString(1));
		rs.close();

		
		
		for(int i = 0; i< vAssessedSubDetail.size() ; ++i)
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
				iIndexOf = vSubWithNoLabFee.indexOf((String)vAssessedSubDetail.elementAt(i+1));
				if(iIndexOf == -1) {
					iIndexOf = FA.vCommonVector.indexOf((String)vAssessedSubDetail.elementAt(i+1));
					if(iIndexOf > -1) {
						strLabFee = (String)FA.vCommonVector.elementAt(iIndexOf + 2);
					}
				}
			}
			
	strTemp = (String)vAssessedSubDetail.elementAt(i+2);
	if(strTemp.length() > 26) 
		strTemp = strTemp.substring(0, 26);
	%>
	  <tr >
		<td height="16" class="thinborder"><%=++iCount%>.<%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
		<td class="thinborder"><%=strSection%></td>
		<td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+9)%></td>
		<td class="thinborder"><%=WI.getStrValue(strLabFee)%></td>
	  </tr>
	  <% i = i+9;
	strRoomAndSection = null;
	strSchedule = null;
	}%>
	  <tr >
		<td colspan="4" class="thinborder" align="center" style="font-weight:bold; font-size:11px;">TOTAL UNITS ENROLLED: <%=fUnitsTaken%></td>
	  </tr>
	</table>
			</td>
			<td width="1%">&nbsp;</td>
			<td width="39%" valign="top">
<%
if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && fTutionFee > 0) {//bolIsTempStudyLoad = true;
	//get here payment detail payment method detail.
	Vector[] vRetResult = faPayment.viewTutionFeePaymentDetail(dbOP,(String)vStudInfo.elementAt(0),strSYFrom,
							strSYTo,(String)vStudInfo.elementAt(4),strSemester,paymentUtil.isTempStudInStr(), "0");
if(vRetResult != null) {%><br>
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
					<tr>
						<td height="18">Previous Balance </td>
						<td align="right"><%=CommonUtil.formatFloat(dOSBalance,true)%></td>
					</tr>
					<tr>
						<td colspan="2" align="center">CURRENT FEES</td>
					</tr>
					<tr>
						<td width="60%" height="18"><%if(bolIsTempStudyLoad || true){%>Tuition<%}%></td>
						<td width="40%" align="right"><%=CommonUtil.formatFloat(fTutionFee,true)%></td>
					</tr>
					<tr>
						<td height="18"><%if(bolIsTempStudyLoad || true){%>Lab Fee<%}%></td>
						<td align="right"><%=CommonUtil.formatFloat(fMiscOtherFee + fCompLabFee,true)%></td>
					</tr>
					<tr>
					  <td height="18"><%if(bolIsTempStudyLoad || true){%>Miscellaneous<%}%></td>
					  <td align="right"><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></td>
				  </tr>
					<tr>
					  <td height="18">Add Charge </td>
					  <td align="right"><%=CommonUtil.formatFloat(dAddCharge,true)%></td>
				  </tr>
					<tr>
					  <td height="18"><%if(bolIsTempStudyLoad || true){%>Total<%}%></td>
					  <td align="right"><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee+dAddCharge+dOSBalance,true)%></td>
				  </tr>
					<tr>
					  <td height="18"><%if(bolIsTempStudyLoad || true){%>Discount Amt<%}%></td>
					  <td align="right"><%=CommonUtil.formatFloat(dTotalDiscount,true)%></td>
				  </tr>
					<tr>
					  <td height="18">Adjustment</td>
					  <td align="right"><%=CommonUtil.formatFloat(dAdjustment,true)%></td>
				  </tr>
					<tr>
					  <td height="18"><%if(bolIsTempStudyLoad || true){%>Total Amount Paid<%}%></td>
					  <td align="right"><%=CommonUtil.formatFloat(dTotalPayment,true)%></td>
				  </tr>
					<tr>
					  <td colspan="2" align="center">____________________________________________________
					  	<!--<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr><td></td></tr>
						</table> 
					  -->
					  </td>
				  </tr> 
					<tr>
					  <td height="18" style="font-weight:bold"><%=strExamName.toUpperCase()%> REQ.</td>
					  <td align="right" style="font-weight:bold"><%=CommonUtil.formatFloat(dDueForThisPeriod,true)%></td>
				  </tr>
				</table>
				
<%}//if vRetResult != null
}//show only if misc fee is not null%>			
			</td>
		</tr>
	</table>

	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td width="33%">SUBJECT TO AUDIT</td>
			<td width="33%">Checked by: <%=(String)request.getSession(false).getAttribute("first_name")%></td>
			<td>Verified by: ________________</td>			
		</tr>
	</table>
<%
}//if vAssessedSubDetail no null

}//if(vStudInfo != null && vStudInfo.size() > 0){
dbOP.cleanUP();

if(!bolIsBatchPrint) {%>
</body>
</html>
<%}%>