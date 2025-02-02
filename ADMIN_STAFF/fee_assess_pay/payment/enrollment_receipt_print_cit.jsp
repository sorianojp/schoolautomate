<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,
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
<title>Registration Form</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
    TABLE.thinborder {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborder {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOM {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TABLE.thinborderALL {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
-->
</style>
</head>

<body onLoad="PrintPage();" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
<%
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp = null;
	String strSubSecIndex = null;
	Vector vLabSched      = null;
	String strORNumber    = WI.fillTextValue("or_number");
	java.sql.ResultSet rs = null;


	String strDegreeType  = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	String[] astrSchYrInfo = {"0","0","0"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-assessedfees print(enrollment)","enrollment_receipt_print.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
							//							"assessedfees.jsp");
if(iAccessLevel == -1)//for fatal error.
{

	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
//end of authenticaion code.

if(strORNumber.length() ==0)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		OR Number can't be empty</font></p>
		<%
	dbOP.cleanUP();
	return;
}

Vector vStudInfo = null;
Vector vMiscFeeInfo = null;
Vector vTemp = null;
Vector vORInfo = null;

String strMaxAllowedLoad = null;

float fTutionFee        = 0f;
float fCompLabFee       = 0f;
float fMiscFee          = 0f;
float fOutstanding      = 0f;
float fTotalPayableAmt 	= 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,

float fEnrollmentDiscount = 0f; //this sum of full payment, early enrollment or late enrollment discount/fine implementations.
String strEnrolmentDiscDetail = null;
float fPayableAfterDiscount = 0f;

boolean bolIsTFZero = false;
boolean bolIsMiscZero = false;


String strCollegeName = null; 
String strDeanName    = null;
//if(strSchoolCode != null && strSchoolCode.startsWith("UDMC"))
//	strSchoolCode = "CGH";

double dCurrentBalance = 0d;
double dTotalAmtPaid   = 0d;
String strSQLQuery     = null;

double dReservationFee = 0d;//only for CGH.

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
Advising advising = new Advising();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

Vector vAssessedSubDetail = null;
Vector vInstallmentDtls = null;

vORInfo = faPayment.viewPmtDetail(dbOP,strORNumber);
if(vORInfo == null || vORInfo.size() ==0)
{%>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=faPayment.getErrMsg()%></font></p>
<%
	dbOP.cleanUP();
	return;
}

//I have to check if this is called for basic student.. 
if(vORInfo.elementAt(19) == null) {//basic.. 
	dbOP.cleanUP();
	///forward the page.. 
	response.sendRedirect(response.encodeRedirectURL("./enrollment_receipt_print_bas.jsp?or_number="+strORNumber));
	return;
}

double dDPFineCGH = 0d;
double dFatimaInstallmentFee = 0d; double dTotalDiscount = 0d;

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
				(String)vORInfo.elementAt(25),(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
if(vStudInfo == null) 
	strErrMsg = enrlStudInfo.getErrMsg();
else {//System.out.println(vStudInfo);
	astrSchYrInfo[0] = (String)vORInfo.elementAt(23);
	astrSchYrInfo[1] = (String)vORInfo.elementAt(24);
	astrSchYrInfo[2] = (String)vORInfo.elementAt(22);

	paymentUtil.setTempUser("0");
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        (String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
        (String)vORInfo.elementAt(22),false,false,true);//System.out.println("Test : "+vMiscFeeInfo);

	strCollegeName = (String)vStudInfo.elementAt(18);
	strDeanName    = (String)vStudInfo.elementAt(20);

	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
		
}
if(strErrMsg == null) //collect fee details here.
{
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
	//System.out.println((String)vORInfo.elementAt(4));
	//System.out.println(fTutionFee);
	if(fTutionFee > 0f)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
		fOperation.checkIsEnrolling(dbOP, (String)vStudInfo.elementAt(0),
				(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
		fOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));
		//I have to remove the ledg_history informations.
		if(!paymentUtil.isTempStud()) {
			double dLedgHistoryExcess = fOperation.calLedgHistoryEntryAfterASYTerm(dbOP, (String)vStudInfo.elementAt(0),
            	                                         (String)vORInfo.elementAt(23), (String)vORInfo.elementAt(22));
			if(dLedgHistoryExcess != fOperation.fDefaultErrorValue)
				fOutstanding -= (float)dLedgHistoryExcess;
		}
		fMiscOtherFee = fOperation.getMiscOtherFee();
		
		dTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),(String)vORInfo.elementAt(23),
        				(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),null);


		enrollment.FAFeeOperationDiscountEnrollment test = new enrollment.FAFeeOperationDiscountEnrollment();
		vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
                                        (String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),
                                        fOperation.dReqSubAmt);
		if(vTemp != null && vTemp.size() > 0)
			strEnrolmentDiscDetail = (String)vTemp.elementAt(0);//System.out.println(vTemp);
		if(strEnrolmentDiscDetail != null && vTemp != null && vTemp.size() > 0)
		{
			fEnrollmentDiscount = ((Float)vTemp.elementAt(1)).floatValue();
			fPayableAfterDiscount = fTutionFee+fMiscFee+fCompLabFee+fOutstanding-fEnrollmentDiscount;
		}

		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5), "degree_type"," and is_valid=1 and is_del=0");
		vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
					(String)vORInfo.elementAt(22),"1",strDegreeType);
		if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0)
			strErrMsg = FA.getErrMsg();
	}
	else {
		strErrMsg = fOperation.getErrMsg();
		bolIsTFZero = true;
	}
}
else {
	bolIsTFZero = true;
	bolIsMiscZero = true;
}
if(fTutionFee < 0.1f)
	bolIsTFZero = true;

//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null)
{
	if(fMiscFee > 0.1f) {
		vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
						(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
		if(vTemp == null)
			strErrMsg = paymentUtil.getErrMsg();
		else
			vMiscFeeInfo.addAll(vTemp);//System.out.println(vMiscFeeInfo);
	}
	else
		bolIsMiscZero = true;
		
	if(fOperation.vMultipleOCMapInfo != null && fOperation.vMultipleOCMapInfo.size() > 0) 
		vMiscFeeInfo.addAll(fOperation.vMultipleOCMapInfo);

	//add here the laboratory deposit if there is any.
	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");
	}

	vInstallmentDtls = FA.getInstallmentPayablePerStudent(dbOP,(String)vStudInfo.elementAt(0),
							(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
							(String)vORInfo.elementAt(22)) ;
	if(vInstallmentDtls == null)
		strErrMsg = FA.getErrMsg();

dCurrentBalance = fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0), true, true, 
(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22),(String)vStudInfo.elementAt(4));
if(dCurrentBalance <=0d) {
	strSQLQuery = "select sum(amount) from fa_stud_payment where payment_for = 0 and is_valid = 1 and user_index = "+(String)vStudInfo.elementAt(0)+
				" and sy_from = "+(String)vORInfo.elementAt(23)+" and semester = "+(String)vORInfo.elementAt(22)+" and is_stud_temp = 0";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next())
		dTotalAmtPaid = rs.getDouble(1);
	rs.close();
}

//System.out.println(dCurrentBalance);
}
if(fMiscFee <=0.1f) {
	vMiscFeeInfo = new Vector();
	vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");
}


//System.out.println(fOperation.vAssessedHrDetail);
boolean bolShowMiscDtls = false;
boolean bolShowOthChargeDtls = false;
boolean bolShowExamDate = false;

//get total max units allowed.
if(strErrMsg == null) {
	Vector vOverloadDtls = new enrollment.OverideParameter().getStudentLoadInfo(dbOP, (String)vORInfo.elementAt(25), 
							(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24), (String)vORInfo.elementAt(22));
	if(vOverloadDtls  != null)
		strMaxAllowedLoad = (String)vOverloadDtls.elementAt(5);
}




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
vInputInfo.addElement((String)vORInfo.elementAt(23));//[2] sy_from, 
vInputInfo.addElement((String)vORInfo.elementAt(22));//[3] semester, 
vInputInfo.addElement((String)vORInfo.elementAt(4));//[4] yr_level,\

//get here lab fee charges.
FA.getLabFee(dbOP, vInputInfo);

Vector vDryLabSubject = new Vector();
	////added to handle wetlab per course.
        Vector vForceRemoveWetLabCIT = new Vector();
        strSQLQuery = "select sub_index from subject_wetlab_cit where is_valid = 1 and sy_f = "+(String)vORInfo.elementAt(23)+
          " and (sem is null or sem = "+(String)vORInfo.elementAt(22)+") and course_i = "+(String)vStudInfo.elementAt(5);
        rs = dbOP.executeQuery(strSQLQuery);
        while(rs.next())
          vForceRemoveWetLabCIT.addElement(rs.getString(1));
        rs.close();

        strSQLQuery = "select sub_index from subject_wetlab_cit where is_valid = 1 and sy_f = "+(String)vORInfo.elementAt(23)+
          " and (sem is null or sem = "+(String)vORInfo.elementAt(22)+") and course_i <> "+(String)vStudInfo.elementAt(5);
        if(vForceRemoveWetLabCIT.size() > 0) {
          strSQLQuery += " and sub_index not in ("+CommonUtil.convertVectorToCSV(vForceRemoveWetLabCIT)+")";
          vForceRemoveWetLabCIT.removeAllElements();
        }
        rs = dbOP.executeQuery(strSQLQuery);
        while(rs.next()) 
          vForceRemoveWetLabCIT.addElement(rs.getString(1));
        rs.close();

	strSQLQuery = "select distinct sub_code, subject.sub_index from fa_tution_fee join subject on (subject.sub_index = fa_tution_fee.sub_index) "+
						"where (semester is null or semester = "+(String)vORInfo.elementAt(22)+") and is_valid = 1 and sy_index = (select sy_index from fa_schyr where sy_from = "+
						(String)vORInfo.elementAt(23)+") "+
						" and not exists (select wetlab_index from subject_wetlab_cit  where sub_index = subject.sub_index and sy_f = "+(String)vORInfo.elementAt(23)+
						" and (sem is null or sem = "+(String)vORInfo.elementAt(22)+") and (course_i is null or course_i = "+(String)vStudInfo.elementAt(5)+") and is_valid = 1) ";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
  if(vForceRemoveWetLabCIT.indexOf(rs.getString(2)) > -1)
  	continue;
  vDryLabSubject.addElement(rs.getString(1));//[0] sub_code. of dry labs..
}
rs.close();

/**
* I have to remove lab fee if fee is excluded
*/
strSQLQuery = "select sub_code from FA_STUD_ASSESSMENT_EXCLUDE_MISC "+
				"join fa_misc_Fee on (fa_misc_fee.MISC_FEE_INDEX = FA_STUD_ASSESSMENT_EXCLUDE_MISC.MISC_FEE_INDEX) "+
				"join subject on (subject.CATG_INDEX = fa_misc_fee.CATG_INDEX) "+
				"where stud_index =  "+(String)vStudInfo.elementAt(0)+
				"and sy_from = "+(String)vORInfo.elementAt(23)+" and FA_STUD_ASSESSMENT_EXCLUDE_MISC.semester = "+(String)vORInfo.elementAt(22)+
				" and FA_STUD_ASSESSMENT_EXCLUDE_MISC.is_valid = 1 and IS_TEMP_STUD = 0";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next())
  vDryLabSubject.addElement(rs.getString(1));//[0] sub_code. of dry labs..
rs.close();


if(bolIsTempStudyLoad){%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="2"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
	  TEMPORARY STUDY LOAD
	  </font></div></td>
    </tr>
</table>
<%}else {//add top margin.. %>
 <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="2"><font size="2"><strong>&nbsp;</strong></font></td>
    </tr>
</table>
<%}%>	

<%if(vStudInfo != null && vStudInfo.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td width="71%" height="18"><font size="2"><%=(String)vStudInfo.elementAt(1)%></font></td>
    <td width="29%" style="font-weight:bold"><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>, AY <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%> </td>
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
    <td height="18" style="font-size:11px;"><%=(String)vORInfo.elementAt(25)%> &nbsp;&nbsp;&nbsp;[<%=strTemp%>]&nbsp;&nbsp;&nbsp;&nbsp;
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
	<table width="100%" cellpadding="0" cellspacing="0" border="0" height="200px">
		<tr>
			<td width="85%" valign="top">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	  <tr >
		<td width="12%" height="18" class="thinborder"><strong>SUBJECT </strong></td>
		<td width="10%" class="thinborder"><strong>SECTION</strong></td>
		<td width="28%" class="thinborder"><strong>DESCRIPTIVE TITLE </strong></td>
		<td width="5%" class="thinborder"><strong>UNITS</strong></td>
		<td width="20%" class="thinborder" align="center"><strong>SCHEDULE</strong></td>
		<td width="8%" class="thinborder"><strong>ROOM</strong></td>
		<td width="17%" class="thinborder"><strong> LAB FEE </strong></td>
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
			strLecLabStat = "0";//null; -- no need to filter.
			/**if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
				pstmtGetLecLabStat.setString(1,strSubSecIndex);
				rs = pstmtGetLecLabStat.executeQuery();
				if(rs.next())
					strLecLabStat = rs.getString(1);
				rs.close();
			}**/
			
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
			  if(strSection == null)
			  	strSection = (String)vSubSecDtls.elementAt(0); 
			  for (int p = 0; p < vLabSched.size(); ++p)
			  {
				  if(strLecLabStat != null && strLecLabStat.compareTo("2") == 0)//lec only.
					break;
				if(strSchedule != null)
					strSchedule += "<br>"+(String)vLabSched.elementAt(p+2);
				else
					strSchedule = (String)vLabSched.elementAt(p+2);
				if(strRoomAndSection != null)
					strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1);
				else
					strRoomAndSection = (String) vLabSched.elementAt(p + 1);
				p = p+ 2;
			  }
			}
			//System.out.println(FA.vCommonVector);
			strLabFee = null;
			if(FA.vCommonVector != null) {
				if(vDryLabSubject.indexOf(vAssessedSubDetail.elementAt(i+1)) == -1) {
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
		<td class="thinborder" align="center"><%=strSection%></td>
		<td class="thinborder"><%=strTemp%></td>
		<td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+9)%></td>
		<td class="thinborder"><%=WI.getStrValue(strSchedule,"N/A")%></td>
		<td class="thinborder"><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
		<td class="thinborder"><%=WI.getStrValue(strLabFee)%></td>
	  </tr>
	  <% i = i+9;
	strRoomAndSection = null;
	strSchedule = null;
	}%>
	  <tr >
		<td colspan="7" class="thinborder" align="center" style="font-weight:bold">TOTAL UNITS ENROLLED: <%=fUnitsTaken%>
		(Max allowable units to take: <%=strMaxAllowedLoad%>)	</td>
	  </tr>
	</table>
			</td>
			<td width="1%">&nbsp;</td>
			<td width="11%" valign="top">
<%
if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && fTutionFee > 0) {//bolIsTempStudyLoad = true;
	//get here payment detail payment method detail.
	Vector[] vRetResult = faPayment.viewTutionFeePaymentDetail(dbOP,(String)vStudInfo.elementAt(0),(String)vORInfo.elementAt(23),
							(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),paymentUtil.isTempStudInStr(), "0");
if(vRetResult != null) {%><br>
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
					<tr>
						<td width="60%" height="18" style="font-weight:bold"><%if(bolIsTempStudyLoad || true){%>Tuition<%}%></td>
						<td width="40%" align="right"><%=CommonUtil.formatFloat(fTutionFee,true)%></td>
					</tr>
					<tr>
						<td height="18" style="font-weight:bold"><%if(bolIsTempStudyLoad || true){%>Lab Fee<%}%></td>
						<td align="right"><%=CommonUtil.formatFloat(fMiscOtherFee + fCompLabFee,true)%></td>
					</tr>
					<tr>
					  <td height="18" style="font-weight:bold"><%if(bolIsTempStudyLoad || true){%>Miscellaneous<%}%></td>
					  <td align="right"><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></td>
				  </tr>
					<tr>
					  <td height="18" style="font-weight:bold"><%if(bolIsTempStudyLoad || true){%>Total<%}%></td>
					  <td align="right"><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></td>
				  </tr>
					<tr>
					  <td height="18" style="font-weight:bold"><%if(bolIsTempStudyLoad || true){%>Discount Amt<%}%></td>
					  <td align="right">
					  <%if(dTotalDiscount == 0d) {%>
					  	&nbsp;
					  <%}else{%>
					  	<%=CommonUtil.formatFloat(dTotalDiscount, true)%>
					  <%}%>
					  
					  </td>
				  </tr>
					<tr>
					  <td height="18" style="font-weight:bold"><%if(bolIsTempStudyLoad || true){%>Amount Paid<%}%></td>
					  <td align="right">
					  <%if(dCurrentBalance <= 0d){%> <%=CommonUtil.formatFloat(dTotalAmtPaid,true)%><%}else{%>
					  <%=CommonUtil.formatFloat((String)vRetResult[1].elementAt(5),true)%>
					  <%}%>
					  
					  </td>
				  </tr>
				<%if(true){%>
					<tr>
					  <td height="18" style="font-weight:bold"><%=((String)vInstallmentDtls.elementAt(5))%></td>
					  <td align="right">
					  <%if(dCurrentBalance <= 0d){%> 0.00<%}else{%>
					  <%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(7)),true)%>
					  <%}%>
					  </td>
				  </tr>
				  <%if(vInstallmentDtls != null && vInstallmentDtls.size() > 5 + 3*1){
				  	strTemp = (String)vInstallmentDtls.elementAt(5+3*1);
					if(strTemp.toLowerCase().equals("finals"))
						strTemp = "Final";
				  %>
					<tr>
					  <td height="18" style="font-weight:bold"><%=strTemp%></td>
					  <td align="right"><%if(dCurrentBalance <= 0d){%> 0.00<%}else{%>
					  <%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+3*1 +2)) ,true)%>
					  <%}%></td>
				  </tr>
				  <%}if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*2) {
				  	strTemp = (String)vInstallmentDtls.elementAt(5+3*2);
					if(strTemp.toLowerCase().equals("finals"))
						strTemp = "Final";
				  %>
					<tr>
					  <td height="18" style="font-weight:bold"><%=strTemp%> </td>
					  <td align="right"><%if(dCurrentBalance <= 0d){%> 0.00<%}else{%>
					  <%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+ 3*2+2)),true)%>
					  <%}%>
					  </td>
				  </tr>
				  <%}if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*3) {
				  	strTemp = (String)vInstallmentDtls.elementAt(5+3*3);
					if(strTemp.toLowerCase().equals("finals"))
						strTemp = "Final";
				  %>
					<tr>
					  <td height="18" style="font-weight:bold"><%=strTemp%></td>
					  <td align="right"><%if(dCurrentBalance <= 0d){%> 0.00<%}else{%>
					  <%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+ 3*3+2)),true)%>
					  <%}%></td>
				  </tr>
				  <%}
				  }%>
				</table>
<%}//if vRetResult != null
}//show only if misc fee is not null%>			
			</td>
			<td width="1%">&nbsp;</td>
		</tr>
	</table>

	<table width="98%" cellpadding="0" cellspacing="0" border="0">
<%if(bolIsTempStudyLoad){
//I have to get now when to claim the final study load.. 
String strDateToClaim = "select prop_val from read_property_file where prop_name = 'cit_claim_official_load'";
strDateToClaim = dbOP.getResultOfAQuery(strDateToClaim, 0);
int iDateToAdd = 7;
if(strDateToClaim != null && strDateToClaim.length() > 0){
	try {
		iDateToAdd = Integer.parseInt(strDateToClaim);
	}
	catch(Exception e) {}
}

java.util.Calendar cal = java.util.Calendar.getInstance();
for(int i = 0; i < iDateToAdd; ++i) {
	cal.add(java.util.Calendar.DAY_OF_MONTH, 1);
    if (cal.get(java.util.Calendar.DAY_OF_WEEK) == java.util.Calendar.SUNDAY || cal.get(java.util.Calendar.DAY_OF_WEEK) == java.util.Calendar.SATURDAY)
		--i;
}
    
strDateToClaim = WI.formatDate(cal.getTime(), 6);
//now i have to check if start of class is after this date
strSQLQuery = "select SPECIFIC_DATE from FA_FEE_ADJ_ENROLLMENT where ADJ_PARAMETER = 6 and IS_VALID = 1 and sy_from = "+(String)vORInfo.elementAt(23)+
				" and semester = "+(String)vORInfo.elementAt(22)+" and specific_date > '"+ WI.getTodaysDate(cal)+"'";
rs = dbOP.executeQuery(strSQLQuery);
if(rs.next()) 
	strDateToClaim = WI.formatDate(rs.getDate(1), 6);
rs.close();
%>	
		<tr>
			<td align="right"> Checked By: <%=(String)request.getSession(false).getAttribute("first_name")%>&nbsp;&nbsp;&nbsp;&nbsp;
			</td>
		</tr>
		<tr>
			<td>Note: Claim your OFFICIAL STUDY LOAD at the Registrar's Office On or AFTER <%=strDateToClaim%>. However, for Freshmen/Transferees with lacking documents, 
			you can only claim your OFFICIAL STUDY LOAD at the said office upon submission of the lacking documents. Total load is subject for FINAL EVALUATION by the 
			Registrar.
			</td>
		</tr>
<%}else{%>
		<tr>
		  <td> GRETCHEN LIZARES - TORMIS, MBA <br>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;UNIVERSITY REGISTRAR			
		  <div align="right"><%=(String)request.getSession(false).getAttribute("first_name")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  
		  </div>
		  </td>
		</tr>
		<tr>
			<td>Note: 1. This will serve as your <%if(astrSchYrInfo[2].equals("0")){%>Midterm<%}else{%>Prelim<%}%> Assessment(Subject to Audit and CHED Approval) 2. Year level shall be subject for review by the Registrar. </td>
		</tr>

<%}%>
	</table>
<%
}//if vAssessedSubDetail no null

}//if(vStudInfo != null && vStudInfo.size() > 0){
dbOP.cleanUP();
%>


<script>
function PrintPage() {
	<%if(bolIsTFZero && bolIsMiscZero) {%>
		if(!confirm('Tuition and Misc Fee Amount is 0. Click Ok to Print and Cancel to Stay on this page.'))
			return;
	<%}else if(bolIsTFZero) {%>
		if(!confirm('Tuition Fee Amount is 0. Click Ok to Print and Cancel to Stay on this page.'))
			return;
	<%}else if(bolIsMiscZero) {%>
		if(!confirm('Misc Fee Amount is 0. Click Ok to Print and Cancel to Stay on this page.'))
			return;
	<%}%>
	window.print();
}
</script>
</body>
</html>
