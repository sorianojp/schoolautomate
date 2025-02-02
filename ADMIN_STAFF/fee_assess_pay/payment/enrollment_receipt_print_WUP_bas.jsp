<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,
	enrollment.FAAssessment,enrollment.SubjectSection,enrollment.EnrlAddDropSubject,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	//strSchoolCode = "FATIMA";
	//boolean bolIsFatima = strSchoolCode.startsWith("FATIMA");
	boolean bolIsFatima = false;
	if(strSchoolCode == null) {
		%>
		<font style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:#FF0000">
			You are already logged out. Please login again to access this page.
		<%
		return;
	}
	
	//strSchoolCode = "UL";
	boolean bolIsUL = strSchoolCode.startsWith("UL");
	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Registration Form</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

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
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	TD.fontSize6{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 6px;	
	}


</style>
</head>

<body onLoad="window.print();" >
<%
	String strErrMsg = null;
	String strTemp = null;
	String strSubSecIndex = null;
	Vector vLabSched      = null;
	String strORNumber    = WI.fillTextValue("or_number");
	java.sql.ResultSet rs = null;


	String strDegreeType  = "0";

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	String[] astrSchYrInfo = {"0","0","0"};
	String[] astrConvertYear = {"","1st Year","2nd Year","3rd Year"};

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

Date dateTime = new Date();
Vector vStudInfo = null;
Vector vMiscFeeInfo = null;
Vector vTemp = null;
Vector vORInfo = null;

float fTutionFee        = 0f;
float fCompLabFee       = 0f;
float fMiscFee          = 0f;
float fOutstanding      = 0f;
float fTotalPayableAmt 	= 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,

float fEnrollmentDiscount = 0f; //this sum of full payment, early enrollment or late enrollment discount/fine implementations.
String strEnrolmentDiscDetail = null;
float fPayableAfterDiscount = 0f;

String strInstructor = "";
String strLabInstructor = "";

double dReservationFee = 0d;//only for CGH.

enrollment.SubjectSectionCPU ssCPU = new enrollment.SubjectSectionCPU();
SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
Advising advising = new Advising();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

Vector vAssessedSubDetail = null;
Vector vInstallmentDtls = null;

FA.setIsBasic(true);
paymentUtil.setIsBasic(true);
fOperation.setIsBasic(true);

vORInfo = faPayment.viewPmtDetail(dbOP,strORNumber);
if(vORInfo == null || vORInfo.size() ==0)
{%>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=faPayment.getErrMsg()%></font></p>
<%
	dbOP.cleanUP();
	return;
}

double dDPFineCGH = 0d;
double dFatimaInstallmentFee = 0d;

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
				(String)vORInfo.elementAt(25),(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
if(vStudInfo == null) 
	strErrMsg = enrlStudInfo.getErrMsg();
else
{//System.out.println(vStudInfo);
	astrSchYrInfo[0] = (String)vORInfo.elementAt(23);
	astrSchYrInfo[1] = (String)vORInfo.elementAt(24);
	astrSchYrInfo[2] = (String)vORInfo.elementAt(22);

	paymentUtil.setTempUser("0");
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        (String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
        (String)vORInfo.elementAt(22));//System.out.println("Test : "+vMiscFeeInfo);

	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
}


	//get here payment detail payment method detail.
	Vector[] vRetResult = faPayment.viewTutionFeePaymentDetail(dbOP,(String)vStudInfo.elementAt(0),(String)vORInfo.elementAt(23),
							(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),paymentUtil.isTempStudInStr(), "0");

	if(vRetResult == null)	
		strErrMsg = faPayment.getErrMsg();
	
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
			
			//System.out.println(" fEnrollmentDiscount : "+fEnrollmentDiscount);
			//System.out.println(" fPayableAfterDiscount : "+fPayableAfterDiscount);
			//System.out.println(" fMiscFee : "+fMiscFee);
			//System.out.println(" fTutionFee : "+fTutionFee);
			//System.out.println(" fCompLabFee : "+fCompLabFee);
			//System.out.println(" fMiscOtherFee : "+fMiscOtherFee);
			//System.out.println(" fOutstanding : "+fOutstanding);
		}

		vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
					(String)vORInfo.elementAt(22),"1",strDegreeType);
		if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0)
			strErrMsg = FA.getErrMsg();
			//System.out.println(vAssessedSubDetail); 
			//System.out.println(strErrMsg); 
			
		if(strSchoolCode.startsWith("CGH") || strSchoolCode.startsWith("UDMC") || 
		strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("DBTC")) {
			dReservationFee = paymentUtil.getReservationFeeCGH(dbOP, (String)vStudInfo.elementAt(0),astrSchYrInfo[0], astrSchYrInfo[1],
						astrSchYrInfo[2],paymentUtil.isTempStud());
			//I have to find out if there is a d/p late charge.
			if(strSchoolCode.startsWith("CGH")){
				//get late fine for d/p
				strTemp = "select AMOUNT from FA_STUD_PAYABLE where is_valid = 1 and user_index = "+
					(String)vStudInfo.elementAt(0)+" and sy_from ="+(String)vORInfo.elementAt(23)+
					" and semester = "+(String)vORInfo.elementAt(22) +" and note like 'Late payment surcharge(D/P)'";
				strTemp = dbOP.getResultOfAQuery(strTemp,0);
				if(strTemp != null) {
					try {
						dDPFineCGH = Double.parseDouble(strTemp);
					}
					catch(Exception e){}
				}
					
			}
		}
		if(bolIsFatima) {			
			String strSQLQuery = "select amount from fa_stud_payable where user_index = "+vORInfo.elementAt(0) +" and sy_from = "+astrSchYrInfo[0]+
									" and semester = "+astrSchYrInfo[2]+" and is_valid = 1 and reference_index = 582";//fee name is Installment Fee and sy_index = 0;
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null)
				dFatimaInstallmentFee = Double.parseDouble(strSQLQuery);
		}
	}
	else
		strErrMsg = fOperation.getErrMsg();
}
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


}
if(fMiscFee <=0.1f) {
	vMiscFeeInfo = new Vector();
	vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");
}
boolean bolShowReceiptHeading = false;
if(!bolShowReceiptHeading) { //forced to enter ;-)
	ReadPropertyFile readPropFile = new ReadPropertyFile();
	strTemp = readPropFile.getImageFileExtn("showHeadingOnPrintReceipt");
	if(strTemp != null && strTemp.compareTo("1") == 0)
		bolShowReceiptHeading = true;
}

//for auf , i have to print the footer for 2007/08 2nd sem.. 
String strAUFFooter = null;
//System.out.println(strSchoolCode);
//System.out.println(astrSchYrInfo[2]);
//System.out.println(astrSchYrInfo[1]);
if(astrSchYrInfo != null && strSchoolCode.startsWith("AUF") && astrSchYrInfo[2].equals("2") && astrSchYrInfo[0].equals("2007") ) {
	strAUFFooter = "<font style='font-size:10px;'>AUF-Form-RO-02<br>August 1, 2007-Rev.0</font>";
}
	

//System.out.println(fOperation.vAssessedHrDetail);
boolean bolShowMiscDtls = true;
boolean bolShowOthChargeDtls = true;

boolean bolShowExamDate = false;
if(strSchoolCode.startsWith("DBTC") || bolIsFatima)
	bolShowExamDate = true;
if(strSchoolCode.startsWith("PIT") || strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("CSA")
	|| strSchoolCode.startsWith("VMUF") || bolIsFatima)
	bolShowReceiptHeading = false;
if(bolIsFatima) {
	bolShowMiscDtls      = false;
	bolShowOthChargeDtls = false;
}
%>
<% if(strErrMsg != null){%>
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

if(vStudInfo != null && vStudInfo.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" >	
	<tr>
		<td height="900px" valign="top" width="100%">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td width="50%"><font size="2">WESLEYAN UNIVERSITY - PHILIPPINES</font></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td height="25" style="border-bottom: solid 1px #000000;"><font size="1">Cabanatuan City</font></td>
		<td align="right" width="40%" style="border-bottom: solid 1px #000000;">&nbsp;</td>	
		<td align="right" style="border-bottom: solid 1px #000000;">&nbsp;<font size="2"><strong><!--<%=(String)vRetResult[1].elementAt(7)%>911SMI65509--></strong></font></td>	
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td width="10%">Date Assessed:</td>
		<td width="50%">&nbsp; <%=WI.getTodaysDate(6)%></td>
		<td rowspan="2" align="right">&nbsp;</td>
	</tr>
	
	<tr>
		<td>School Year:</td>
		<td>&nbsp; <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%>, <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%></td>
		
	</tr>
	
	<tr>
		<td>Student:</td>
		<td>&nbsp; <font size="2"><strong><%=(String)vStudInfo.elementAt(1)%></strong></font></td>
		<td align="right">&nbsp;<!--STUDENT'S COPY--></td>
	</tr>
	
	<tr>
		<td>Grade :</td>
		<td colspan="2">&nbsp; <%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(4),"0")))%></td>
	</tr>
</table>
<!--
<table width="100%" border="1" cellpadding="0" cellspacing="0" >
  <tr>
  	<td height="18" width="15%">&nbsp;</td>
	
  	<td width="25%" align="left">&nbsp;<%=(String)vStudInfo.elementAt(1)%></td>
    <td width="5%">&nbsp;</td>	
    <td width="5%">&nbsp;</td>	
    <td width="10%">&nbsp;</td>	
    <td width="15%">&nbsp;</td>
	<td width="10%">&nbsp;</td>
	<td width="15%">&nbsp;<%=WI.getTodaysDate(1)%></td>
  </tr>
  
  <tr>
  	<td height="18" width="15%">&nbsp;</td>
	
  	<td width="25%" align="left">&nbsp;<%=(String)vORInfo.elementAt(25)%></td>
    <td width="5%">&nbsp;</td>	
    <td width="5%">&nbsp;<%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></td>	
    <td width="10%">&nbsp;<%=(String)vStudInfo.elementAt(16)%></td>	
    <td width="15%">&nbsp;</td>
	<td width="10%">&nbsp;</td>
	<td width="15%">&nbsp;<%=WI.formatDateTime(dateTime.getTime(),3)%></td>
  </tr>
  
  <tr>
  	<td height="18" width="15%">&nbsp;</td>
	
  	<td width="25%" align="left">&nbsp;</td>
    
    <td width="5%" colspan="2" align="right">&nbsp;<%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%></td>	
    <td width="10%" colspan="2" align="center">&nbsp;<%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%></td>    
	<td width="10%">&nbsp;</td>
	<td width="15%"><strong>&nbsp;</strong></td>
  </tr>
  
  <tr>  	 
	<td colspan="7">&nbsp;</td>
	<td width="15%">&nbsp;<%=(String)vRetResult[1].elementAt(7)%></td>
  </tr>
  
  <tr>  	 
	<td colspan="7">&nbsp;</td>
	<td width="15%">&nbsp;<%=(String)request.getSession(false).getAttribute("userId")%></td>
  </tr>
	
</table>
-->



<%if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="">

	
	<tr ><td colspan="7" align="center" height="50"><strong><font size="1"><u>SUBJECTS ENROLLED</u></font></strong></td>	</tr>
  
  
  <tr >
  	<td width="15%" class=""><strong>SCHEDULE</strong></td>
  	<td width="10%" height="18" class=""><strong>&nbsp;SCHED CODE </strong></td>
    <td width="13%" height="18" class=""><strong>&nbsp;SUBJECT CODE</strong></td>
    <td width="30%" height="19" class=""><strong>&nbsp;SUBJECT DESCRIPTION </strong></td>
	<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")){%>
    <td width="7%" class="" align="center"><strong>&nbsp;UNITS</strong></td>
    <%}%>
	
    
    <td width="10%" class=""><strong>ROOM</strong></td>
    
	<!--<td width="15%" class=""><strong>&nbsp;PROFESSOR</strong></td>-->
	
  </tr>
  <%//System.out.println(vAssessedSubDetail);
 	float fFirstInstalAmt = 0f;
	float fTotalLoad = 0;float fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	float fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.
String strSchedule = null;
String strRoomAndSection = null;
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

	for(int i = 0; i< vAssessedSubDetail.size() ; ++i)
	{
		if(strFeeTypeCatg == null)	strFeeTypeCatg = (String)vAssessedSubDetail.elementAt(8);

		fTotalUnit = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+3))+Float.parseFloat((String)vAssessedSubDetail.elementAt(i+4));
		fTotalLoad += fTotalUnit;
		fUnitsTaken += Float.parseFloat((String)vAssessedSubDetail.elementAt(i+9));
		strSubSecIndex = (String)vAssessedSubDetail.elementAt(i);
		//if( Float.parseFloat((String)vSubjectDtls.elementAt(i+6)) == 0 && Float.parseFloat((String)vSubjectDtls.elementAt(i+7)) == 0)
/********************************************************************************************************************************
***************************************************** OLD WAY OF COMPUTATION ****************************************************
*********************************************************************************************************************************
		if(strFeeTypeCatg.compareTo("0") ==0)//per unit
		{
			strRatePerUnit = (String)vAssessedSubDetail.elementAt(i+5);
			//fSubTotalRate = fTotalUnit * Float.parseFloat(strRatePerUnit);
			fSubTotalRate = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+9)) * Float.parseFloat(strRatePerUnit);//units taken
		}
		//else
		else if(strFeeTypeCatg.compareTo("1") ==0)//per unit
		{
			strRatePerUnit = (String)vAssessedSubDetail.elementAt(i+6) +"/lec "+(String)vAssessedSubDetail.elementAt(i+7)+"/lab";
			fSubTotalRate  = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+3)) * Float.parseFloat((String)vAssessedSubDetail.elementAt(i+3))
							+Float.parseFloat((String)vAssessedSubDetail.elementAt(i+6)) * Float.parseFloat((String)vAssessedSubDetail.elementAt(i+7));
		}
		else if(strFeeTypeCatg.compareTo("2") ==0)//per subject
		{
			strRatePerUnit = (String)vAssessedSubDetail.elementAt(i+5)+"/subject";
			fSubTotalRate = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+5));
		}
		else if(strFeeTypeCatg.compareTo("3") == 0)
		{
			strRatePerUnit = "&nbsp;";
			fSubTotalRate = 0;
		}
		if(fSubTotalRate > 0f)
		{
			if(dbOP.mapOneToOther("FA_SUB_NOFEE join e_sub_section on (e_sub_section.sub_index = FA_SUB_NOFEE.sub_index) ","sub_sec_index",
				(String)vAssessedSubDetail.elementAt(i),"SUB_NOFEE_INDEX"," and FA_SUB_NOFEE.is_del=0 ") !=null)
				fSubTotalRate = 0f;
		}
********************************************************************************************************************************
***************************************************** END OF OLD WAY OF COMPUTATION ********************************************
********************************************************************************************************************************/
		//GET THE INFORMATION FROM TUITION FEE FAFeeOperation.vTuitionFeeDtls;
		strTemp = (String)vAssessedSubDetail.elementAt(i+1);
		if(strTemp.indexOf("NSTP") != -1){
          iIndex = strTemp.indexOf("(");
          if(iIndex != -1){
            strTemp = strTemp.substring(0,iIndex);
            strTemp = strTemp.trim();
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
		
		strInstructor = "";
		strLabInstructor = "";
		//Vector vSubSecDtlsss = new Vector();
		if(strSubSecIndex != null && strSubSecIndex.compareTo("-1") != 0) {
			vSubSecDtls = SS.getRoomScheduleDetailInMWF(dbOP, strSubSecIndex);
			//vSubSecDtlsss = ssCPU.operateOnSchedule(dbOP,request,0,strSubSecIndex);		
			
			vLabSched   = SS.getLabSched(dbOP,strSubSecIndex);
			//System.out.println("vSubSecDtls "+vSubSecDtls);
			//if (vSubSecDtls != null) {
				//vSubSchedule = (Vector) vSubSecDtls.elementAt(20);
			//	strInstructor = (String)vSubSecDtls.elementAt(21);
			//}
			
		}else {
			vSubSecDtls = null;
			vLabSched = null;
		}
		
		if(vSubSecDtls == null || vSubSecDtls.size() ==0)
		{
			if(strSubSecIndex != null && strSubSecIndex.compareTo("-1") == 0) {//re-enrollment.			
				vSubSecDtls = new Vector();
				strInstructor = "*******";
			}
			else {
				strErrMsg = SS.getErrMsg();
				break;
			}
		}
		for(int b=0; b<vSubSecDtls.size(); ++b)
		{
			if(strLecLabStat != null && strLecLabStat.compareTo("1") == 0)//lab only.
				continue;

			if(strRoomAndSection == null)
			{
				//System.out.println("a");
				//strRoomAndSection = (String)vSubSecDtls.elementAt(b)+"/"+(String)vSubSecDtls.elementAt(b+1);
				strRoomAndSection = (String)vSubSecDtls.elementAt(b+1);
				strSchedule = (String)vSubSecDtls.elementAt(b+2);
				//System.out.println("strSchedule "+strSchedule);
			}
			else
			{
				//System.out.println("b");
				strRoomAndSection += "<br>"+(String)vSubSecDtls.elementAt(b+1);
				strSchedule += "<br>"+(String)vSubSecDtls.elementAt(b+2);
			}
			b = b+2;
			
		}
		//System.out.println("strSchedule "+strSchedule);
		if(vLabSched != null)
		{
		  for (int p = 0; p < vLabSched.size(); ++p)
		  {
			  if(strLecLabStat != null && strLecLabStat.compareTo("2") == 0)//lec only.
				continue;
			//System.out.println("c");
		    strSchedule += "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
			strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
%>
  <tr >
  	<td class=""><%=WI.getStrValue(strSchedule,"N/A")%></td>
  	<td height="19" class="">&nbsp;<%=strSubSecIndex%></td>
    <td height="19" class="">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
    <td class="">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+2)%></td>
	<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")) {%>
    <td class="" align="center"><%=(String)vAssessedSubDetail.elementAt(i+9)%> <!--<%=(String)vAssessedSubDetail.elementAt(i+3)%>/<%=(String)vAssessedSubDetail.elementAt(i+4)%>--></td>
    <%}%>
	
    
    <td class=""><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
    
	<!--<td class="" align="left">&nbsp;<%=WI.getStrValue(strInstructor,"c/o") + WI.getStrValue(strLabInstructor,"<br>","","")%></td>-->
	
  </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}%>

  <tr >
      <td height="20" align="right" colspan="4" style="border-top: solid 1px #000000; border-bottom: solid 1px #000000;">&nbsp; TOTAL UNITS  :</td>
	  <td align="center" style="border-top: solid 1px #000000; border-bottom: solid 1px #000000;">&nbsp;<%=CommonUtil.formatFloat(fUnitsTaken, false)%></td>
	  <td colspan="2" align="right" style="border-top: solid 1px #000000; border-bottom: solid 1px #000000;"><strong>&nbsp;<!--<%=CommonUtil.formatFloat(fTutionFee,true)%>--></strong></td>
  </tr>  
</table>

<!---------------------PARA SA MISCELLANEOUS-------------------------------->
<!--
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td width="15%">REGISTRATION</td>
		<td width="15%" align="right">&nbsp;350.00</td>
		<td width="5%" align="right">&nbsp;</td>
		<td width="15%">LIBRARY</td>
		<td width="15%" align="right">1,669.00</td>
		<td width="5%" align="right">&nbsp;</td>
		<td width="15%">MEDICAL</td>
		<td width="15%" align="right">908.00</td>
	</tr>
	<tr>
		<td>ATHLETEC</td>
		<td align="right">311.00</td>
		<td width="5%" align="right">&nbsp;</td>
		<td>GUIDANCE</td>
		<td align="right">437.00</td>
		<td width="5%" align="right">&nbsp;</td>
		<td>TESTING</td>
		<td align="right">397.00</td>
	</tr>
	<tr>
		<td>INSURANCE</td>
		<td align="right">200.00</td>
		<td width="5%" align="right">&nbsp;</td>
		<td>CURRICULUM</td>
		<td align="right">100.00</td>
		<td width="5%" align="right">&nbsp;</td>
		<td>SPECIAL DEVELOPMENT</td>
		<td align="right">2,506.00</td>
	</tr>
	<tr>
		<td>AIRON</td>
		<td align="right">1,300.00</td>
		<td colspan="6" align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>SSC FEE</td>
		<td align="right">20.00</td>
		<td align="right">&nbsp;</td>
		<td>PERPETUALITE</td>
		<td align="right">20.00</td>
		<td align="right" colspan="3">&nbsp;</td>
	</tr>
	<tr><td colspan="8"><hr width="100%"></td></tr>
	<tr>
		<td colspan="7" >&nbsp;</td>
		<td align="right"><strong>8,220.00</strong></td>		
	</tr>
	<tr><td colspan="8"><hr width="100%"></td></tr>
	<tr>
		<td colspan="7" align="right">TOTAL AMOUNT DUE &nbsp;&nbsp;&nbsp; : &nbsp;&nbsp;&nbsp;</td>
		<td align="right"><strong>&nbsp;</strong></td>		
	</tr>
	<tr>
		<td colspan="7" align="right">Old Account Charges &nbsp;&nbsp;&nbsp; : &nbsp;&nbsp;&nbsp;</td>
		<td align="right"><strong>&nbsp;</strong></td>		
	</tr>
	<tr>
		<td colspan="7" align="right">DROP / CANCEL CHARGES &nbsp;&nbsp;&nbsp; : &nbsp;&nbsp;&nbsp;</td>
		<td align="right"><strong>&nbsp;</strong></td>		
	</tr>
	<tr>
		<td colspan="7" align="right">TUITION ADJUSTMENTS (RETENTION) &nbsp;&nbsp;&nbsp; : &nbsp;&nbsp;&nbsp;</td>
		<td align="right"><strong>&nbsp;</strong></td>		
	</tr>
	<tr>
		<td colspan="7" align="right">SCHOLARSHIP/DISCOUNTS &nbsp;&nbsp;&nbsp; : &nbsp;&nbsp;&nbsp;</td>
		<td align="right"><strong>&nbsp;</strong></td>		
	</tr>
	<tr>
		<td colspan="7" align="right">CREDITS &nbsp;&nbsp;&nbsp; : &nbsp;&nbsp;&nbsp;</td>
		<td align="right"><strong>&nbsp;</strong></td>		
	</tr>
	
	<tr>
		<td colspan="7" align="right">CURRENT BALANCE &nbsp;&nbsp;&nbsp; : &nbsp;&nbsp;&nbsp;</td>
		<td align="right"><strong>&nbsp;</strong></td>		
	</tr>
	
</table>
-->
<!---------------------END PARA SA MISCELLANEOUS-------------------------------->
<%if(strSchoolCode.startsWith("DBTC")){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr >
    <td colspan="9" height="18">Note: Above schedule may change after enrolment adjustments</td>
  </tr>
</table>
<%}%>
<%
if(false && strSchoolCode.startsWith("CGH")){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break.
}//if vAssessedSubDetail no null
if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && fTutionFee > 0)
{
	//get here payment detail payment method detail.
	//Vector[] vRetResult = faPayment.viewTutionFeePaymentDetail(dbOP,(String)vStudInfo.elementAt(0),(String)vORInfo.elementAt(23),
	//						(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),paymentUtil.isTempStudInStr(), "0");

	if(vRetResult == null)
	{
	strErrMsg = faPayment.getErrMsg();
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td align="center"><strong><font size="2"><br><%=strErrMsg%></font></strong></td>
  </tr>
</table>
<%}else {%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td width="25%">&nbsp;</td>
		<td width="25%">&nbsp;</td>
		<td width="10%">&nbsp;</td>
		<td width="10%">&nbsp;</td>
		<td width="">&nbsp;</td>
	</tr>
	
	<tr><td align="center" colspan="5"><u><strong><font size="1">ASSESSMENT</font></strong></u></td></tr>
	
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;<strong><font size="1">CHARGES</font></strong></td>
		<td>&nbsp;</td>
		<td align="right">&nbsp;<strong><font size="1">AMOUNT</font></strong></td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;&nbsp;&nbsp; TUITION FEE</td>
		<td>&nbsp;</td>
		<td align="right">&nbsp;<%=CommonUtil.formatFloat(fTutionFee,true)%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;&nbsp;&nbsp; MISCELLANEOUS</td>
		<td>&nbsp;</td>
		<td align="right">&nbsp;<%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></td>
	</tr>
<%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0)
		continue;
%>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
	  <td align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></td>
	  <td align="right">&nbsp;</td>
	  </tr>
<%}%>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;&nbsp;&nbsp; OTHERS</td>
		<td>&nbsp;</td>
		<td align="right">&nbsp;<%=CommonUtil.formatFloat(fMiscOtherFee  + fCompLabFee,true)%></td>
	</tr>
<%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
		continue;
%>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
	  <td align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></td>
	  <td align="right">&nbsp;</td>
	  </tr>
<%}if(fOutstanding != 0f) {%>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;&nbsp;&nbsp; OUTSTANDING</td>
		<td>&nbsp;</td>
		<td align="right">&nbsp;<%=CommonUtil.formatFloat(fOutstanding,true)%></td>
	</tr>
<%}%>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;<strong><font size="1">TOTAL CHARGES</font></strong></td>
		<td>&nbsp;</td>
		<td align="right" style="border-bottom: solid 1px #000000;border-top: solid 1px #000000;">&nbsp;<%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></td>
	</tr>
	

</table>





<table width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td width="35%">&nbsp;</td>
		<td width="15%">&nbsp;</td>
		<td width="">&nbsp;</td>
		<td width="">&nbsp;</td>
		<td width="">&nbsp;</td>
	</tr>
	
	<tr><td align="center" colspan="5" height="30px"><u><strong><font size="1">PAYMENT SCHEME</font></strong></u></td></tr>
	
<%
 double dAddToInstallationFee = 0d;
 	int iNoOfInstallment = 0;
	if(vInstallmentDtls != null && vInstallmentDtls.size() > 0) 
		iNoOfInstallment = (vInstallmentDtls.size() - 5)/3 + 1;
 double dInstallmentAmt = (fTutionFee+fCompLabFee+fMiscFee)/iNoOfInstallment;
 %>
 
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp; DOWN PAYMENT</td>
		<td>&nbsp; :&nbsp;<%//=CommonUtil.formatFloat((String)vRetResult[1].elementAt(5),true)%><%=CommonUtil.formatFloat(dInstallmentAmt, true)%></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>

	<%for(int i =5; i < vInstallmentDtls.size(); i += 3) {%>
       <tr>
	   		<td width="25%">&nbsp;</td>
          	<td width="25%">&nbsp;&nbsp;<%=((String)vInstallmentDtls.elementAt(i)).toUpperCase()%></td>
			<td width="10%">&nbsp; :&nbsp;<%=CommonUtil.formatFloat(dInstallmentAmt, true)%></td>		  
			<td width="10%">&nbsp;</td>
			<td width="">&nbsp;</td>
  	   </tr>
	<%}%>
</table>
		
		</td>
	</tr>
	
	<!----------------------------------FOOTER----------------------------------------------->
	<tr>
		<td width="100%">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" >
				<tr>
					<td width="65%" style="border-top: solid 1px #000000;" class="fontSize6"><font size="1">
						Note: This assessment form is not valid unless marked enrolled and signed by the teller/cashier.</font></td>
					<td align="right" width="20%" style="border-top: solid 1px #000000;">Print Date: <%=WI.getTodaysDate(16)%> <%=WI.getTodaysDate(15)%></td>
					<td align="right" style="border-top: solid 1px #000000;"><strong>ASSESSMENT FORM</strong></td>
				</tr>
			</table>
		</td>
	</tr>
	<!------------------------------------END FOOTER------------------------------------------------------->
	
</table>

<!------------------------------END MAIN TABLE---------------------------------------------->
<%}%>






<!--------------------------------------OTHER SCHOOLS--------------------------------------------------------->

<%
	}//if student information exists.
}//if miscellaneous fee information exists.
dbOP.cleanUP();
%>
</body>
</html>
