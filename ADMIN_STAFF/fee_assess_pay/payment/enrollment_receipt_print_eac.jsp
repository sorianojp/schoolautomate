<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,
	enrollment.FAAssessment,enrollment.SubjectSection,enrollment.EnrlAddDropSubject,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	//strSchoolCode = "FATIMA";
	boolean bolIsFatima = strSchoolCode.startsWith("FATIMA");
	
	if(strSchoolCode == null) {
		%>
		<font style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:#FF0000">
			You are already logged out. Please login again to access this page.
		<%
		return;
	}
	if(bolIsFatima) {%>
	<jsp:forward page="./enrollment_receipt_print_fatima.jsp" />
	<%}
	if(strSchoolCode.startsWith("CIT")) {
		if(WI.fillTextValue("prevent_forward").length() == 0) {%>
			<jsp:forward page="./enrollment_receipt_print_cit.jsp" />
	<%}//System.out.println("Test here.");
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
<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("CGH") && !strSchoolCode.startsWith("FATIMA")){%>
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
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
<%}%>
-->
</style>
</head>

<body onLoad="window.print();" topmargin="55px;">
<%
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

float fTutionFee        = 0f;
float fCompLabFee       = 0f;
float fMiscFee          = 0f;
float fOutstanding      = 0f;
float fTotalPayableAmt 	= 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,

float fEnrollmentDiscount = 0f; //this sum of full payment, early enrollment or late enrollment discount/fine implementations.
String strEnrolmentDiscDetail = null;
float fPayableAfterDiscount = 0f;

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
double dFatimaInstallmentFee = 0d;

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
				(String)vORInfo.elementAt(25),(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
if(vStudInfo == null) 
	strErrMsg = enrlStudInfo.getErrMsg();
else {
	//if add/drop fee is already paid.. 
	enrollment.FAFeeMaintenance FFM = new enrollment.FAFeeMaintenance();
	double dAddDropFeeBal = FFM.addDropFeePayabaleBalance(dbOP, (String)vStudInfo.elementAt(0),
								(String)vORInfo.elementAt(23), (String)vORInfo.elementAt(22));
	if(dAddDropFeeBal > 0d) {
		strErrMsg = "Please pay Add/Drop charges: Total Amount: "+CommonUtil.formatFloat(dAddDropFeeBal, true);
	}
	//System.out.println(FFM.getErrMsg());
}

if(strErrMsg == null) {
	astrSchYrInfo[0] = (String)vORInfo.elementAt(23);
	astrSchYrInfo[1] = (String)vORInfo.elementAt(24);
	astrSchYrInfo[2] = (String)vORInfo.elementAt(22);

	paymentUtil.setTempUser("0");
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        (String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
        (String)vORInfo.elementAt(22));//System.out.println("Test : "+vMiscFeeInfo);

	strTemp = "select c_name, dean_name from college join course_offered on (course_offered.c_index = college.c_index) where course_index = "+(String)vStudInfo.elementAt(5);
	rs = dbOP.executeQuery(strTemp); 
	if(rs.next()) {
		strCollegeName = rs.getString(1);
		strDeanName    = rs.getString(2);
	}
	rs.close();
	
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

		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5), "degree_type"," and is_valid=1 and is_del=0");
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
	
boolean bolShowMiscDtls = true;
boolean bolShowOthChargeDtls = true;
boolean bolShowExamDate = true;
String strInfo5 = (String)request.getSession(false).getAttribute("info5");
if(strInfo5 != null && strInfo5.startsWith("ICA")) {
	bolShowOthChargeDtls = false;
	bolShowMiscDtls = false;
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
if(vStudInfo != null && vStudInfo.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td align="right" height="20"> Date and Time Printed: <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr align="center" style="font-weight:bold">
		<td width="15%" style="font-size:11px;"><%=(String)vORInfo.elementAt(25)%></td>
		<td width="70%" style="font-size:11px;"><%=(String)vStudInfo.elementAt(1)%></td>
		<td width="5%" style="font-size:11px;"><%=WI.getStrValue(vStudInfo.elementAt(13),"")%></td>
		<td width="5%" style="font-size:11px;"><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></td>
<%
strTemp = Integer.toString(CommonUtil.calculateAGEDatePicker((String)vStudInfo.elementAt(23)));
if(strTemp.equals("0") || strTemp.startsWith("-"))
	strTemp = "";
%>
		<td width="5%"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
	</tr>
	<tr align="center">
		<td style="font-size:11px;">Student No.</td>
		<td style="font-size:11px;">Name</td>
		<td style="font-size:11px;">Sex</td>
		<td style="font-size:11px;">Year</td>
		<td style="font-size:11px;">Age</td>
	</tr>
	<tr align="center" valign="bottom" style="font-weight:bold">
	  <td height="20" style="font-size:11px;"><%=vStudInfo.elementAt(16) + WI.getStrValue((String)vStudInfo.elementAt(22), " - ","","")%></td>
	  <td style="font-size:11px;"><%=vStudInfo.elementAt(2) + WI.getStrValue((String)vStudInfo.elementAt(3), " - ","","")%></td>
	  <td colspan="3" style="font-size:11px;"><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>, <%=astrSchYrInfo[0]+"-"+astrSchYrInfo[1].substring(2,4)%></td>
  </tr>
	<tr align="center" valign="top">
	  <td height="18" style="font-size:11px;">Course</td>
	  <td style="font-size:11px;">Course Description</td>
	  <td colspan="3" style="font-size:11px;">Term, SY</td>
  </tr>
</table>
<br><br><br>
<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0)
{
int iSubjectCount = 0;%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr >
    <td width="12%" class="thinborder"><strong>CONTROL NO.</strong></td>
    <td width="12%" height="19" class="thinborder"><strong>SUBJECT CODE </strong></td>
    <td width="33%" height="19" class="thinborder"><strong>SUBJECT TITLE </strong></td>
    <td width="20%" class="thinborder"><strong>SCHEDULE</strong></td>
    <td width="25%" class="thinborder"><strong>SECTION/ROOM #</strong></td>
    <td width="5%" class="thinborder" align="center"><strong>LEC/LAB </strong></td>
    <td width="5%" class="thinborder" align="center"><strong>UNITS</strong></td>
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
		for(int b=0; b<vSubSecDtls.size(); ++b)
		{
			if(strLecLabStat != null && strLecLabStat.compareTo("1") == 0)//lab only.
				continue;

			if(strRoomAndSection == null)
			{
				strRoomAndSection = (String)vSubSecDtls.elementAt(b)+"/"+(String)vSubSecDtls.elementAt(b+1);
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
				continue;
		    strSchedule += "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
			strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
++iSubjectCount;
%>
  <tr >
    <td class="thinborder"><%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP,request,strSubSecIndex ,astrSchYrInfo[0],astrSchYrInfo[2],"EAC"), "&nbsp;")%></td>
    <td height="19" class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+2)%></td>
    <td class="thinborder"><%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class="thinborder"><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+3)%>/<%=(String)vAssessedSubDetail.elementAt(i+4)%></td>
    <td class="thinborder" align="center"><%=(String)vAssessedSubDetail.elementAt(i+9)%></td>
  </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}%>
  <tr >
    <td colspan="7" height="18" class="thinborder"><div align="center">
        <%if(strErrMsg != null){%>
        <%=strErrMsg%>
        <%}else{%>
        TOTAL LOAD UNITS : <strong>
        <!--<%=fTotalLoad%>/-->
        <%=fUnitsTaken%></strong>
        <%}
		//if Assessed hour is > 0f, I have to show total Assessed hour
		if(fOperation.fTotalAssessedHour > 0f){%>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        ASSESSED UNITS(HOURS) : <strong><%=fOperation.fTotalAssessedHour%></strong>
        <%}%>
      </div></td>
  </tr>
</table>
<%
if(iSubjectCount > 8){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<br><br><br><br><br>&nbsp;
<br><br><br><br><br>&nbsp;
<br><br><br><br><br>&nbsp;
<br><br><br><br><br>&nbsp;
<%}//page break.
}//if vAssessedSubDetail no null
if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && fTutionFee > 0)
{
	//get here payment detail payment method detail.
	Vector[] vRetResult = faPayment.viewTutionFeePaymentDetail(dbOP,(String)vStudInfo.elementAt(0),(String)vORInfo.elementAt(23),
							(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),paymentUtil.isTempStudInStr(), "0");

	if(vRetResult == null)
	{
	strErrMsg = faPayment.getErrMsg();%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td align="center"><strong><font size="2"><br><%=strErrMsg%></font></strong></td>
  </tr>
</table>
<%}else{

 fTotalPayableAmt = fTutionFee+fCompLabFee+fMiscFee + fOutstanding  - fEnrollmentDiscount;
 float fAmtPaidDurEnrl = Float.parseFloat((String)vRetResult[1].elementAt(5));
 float fFirstInstalAmt = 0f;
 int iEnrlSetting      = FA.getEnrollemntInstallmentSetting();
 int iInstalCount      = FA.getNoOfInstallment(dbOP,(String)vORInfo.elementAt(23),
 							(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
 if(iEnrlSetting ==0) {//1= (total due-first payment)/iInstalCount, 0=total due/iInstallCount - first installment.
 	fFirstInstalAmt = fTotalPayableAmt/iInstalCount - fAmtPaidDurEnrl;
	if(fFirstInstalAmt < 0f)
		fFirstInstalAmt = 0f;
 }
 else
 	fFirstInstalAmt = (fTotalPayableAmt - fAmtPaidDurEnrl)/iInstalCount;


 if(false && strSchoolCode.startsWith("CGH")){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td width="5%" height="18">Student </td>
    <td width="69%"><strong><font size="2"><%=(String)vStudInfo.elementAt(1)%>(<%=(String)vORInfo.elementAt(25)%>)</font></strong></td>
    <td width="26%"><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%> ,AY
      <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%> </td>
  </tr>
</table>
 <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td width="45%" height="14" valign="top">&nbsp;
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
       <%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC") && !bolIsFatima){%>
	    <tr>
          <td width="65%" height="14"><div align="right"><strong>:: FEE DETAILS ::</strong></div></td>
          <td width="35%" height="14">&nbsp;</td>
        </tr>
       <%}%>
	    <tr>
          <td height="14">TUITION FEE<strong><font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%> </font></strong></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></font></div></td>
        </tr>
     <%if(fCompLabFee > 0f){%>
       <tr>
          <td height="14">COMP. LAB. FEE</td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></font></div></td>
        </tr>
     <%}
	 //System.out.println(bolShowMiscDtls);
	 if(bolShowMiscDtls) {%>
	    <tr>
          <td height="14">MISCELLANEOUS FEES</td>
          <td height="14"><div align="right">
       <%if(strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("UDMC")){%>
           <strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong>
        <%}%>
		</div></td>
        </tr>
         <%}
		 if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")){
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0 || !bolShowMiscDtls)
				continue;
		%>
 		<tr>
          <td height="14">&nbsp;&nbsp;<font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
        <tr>
          <td height="14"><strong>TOTAL MISC</strong></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></font></div></td>
        </tr>
        <%}
		if(!strSchoolCode.startsWith("UDMC") && !strSchoolCode.startsWith("CSA") && bolShowOthChargeDtls){%>
		<tr>
		  <td height="14"><font size="1">OTHER CHARGES</font></td>
          <td height="14"><div align="right"></div></td>
        </tr>
         <%}
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if(strSchoolCode.startsWith("CSA"))
				continue;
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0 || !bolShowOthChargeDtls)
				continue;
		%>
        <tr>
          <td height="14">&nbsp;&nbsp;<font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}if(!strSchoolCode.startsWith("UDMC")){%>
        <tr>
          <td height="14"><font size="1"><strong>TOTAL OTHER CHARGE<%if(strSchoolCode.startsWith("CSA")){%>S<%}%></strong></font></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></font></div></td>
        </tr>
<%}
if(bolIsFatima && dFatimaInstallmentFee > 0d){%>
        <tr>
          <td height="14">INSTALLMENT FEE</td>
          <td height="14" style="font-weight:bold"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dFatimaInstallmentFee,true)%></font></div></td>
        </tr>
<%}%>
        <tr>
          <td height="14" colspan="2"><hr size="1"></td>
        </tr>
        <tr>
          <td height="14"><strong>TOTAL ASSESSMENT</strong></td>
          <td height="14"><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + dFatimaInstallmentFee,true)%></strong></font></div></td>
        </tr>
        <tr>
          <td height="14">OLD ACCOUNTS</td>
          <td height="14"><div align="right"><font size="1">Php <%=CommonUtil.formatFloat(fOutstanding,true)%></font></div></td>
        </tr>
<%if(!strSchoolCode.startsWith("AUF")){%>
		<tr>
          <td height="14">TOTAL AMOUNT DUE</td>
          <td height="14"><div align="right"><font size="1">Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding,true)%></font></div></td>
        </tr>
<%}//donot show total amt due.. 

if(strSchoolCode.startsWith("UDMC") && strEnrolmentDiscDetail != null){
int iIndexOf = strEnrolmentDiscDetail.indexOf(":");
if(iIndexOf > 0) {
	strTemp = strEnrolmentDiscDetail.substring(iIndexOf + 1);
	strEnrolmentDiscDetail = strEnrolmentDiscDetail.substring(0,iIndexOf - 1);
}
else	
	strTemp = "";
%>
        <tr style="font-weight:bold; font-size:9px;">
          <td height="14"><%=strEnrolmentDiscDetail.toUpperCase()%></td>
          <td height="14" align="right"><%=strTemp%></td>
        </tr>
<%}

if(dReservationFee > 0d){
fTotalPayableAmt = fTotalPayableAmt - (float)dReservationFee;%>
        <tr>
          <td height="14">LESS RESERVATION FEE</td>
          <td height="14"><div align="right"><font size="1">Php <%=CommonUtil.formatFloat(dReservationFee ,true)%></font></div></td>
        </tr>
<%}
if(dDPFineCGH > 0d && strSchoolCode.startsWith("CGH")){%>
        <tr>
          <td height="14">LATE SURCHARGE</td>
          <td height="14"><div align="right"><font size="1">Php <%=CommonUtil.formatFloat(dDPFineCGH,true)%></font></div></td>
        </tr>
<%}%>
        <tr>
          <td height="14"><strong>TOTAL BALANCE DUE</strong></td>
          <td height="14"><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTotalPayableAmt + dDPFineCGH + dFatimaInstallmentFee - fAmtPaidDurEnrl ,true)%></strong></font></div></td>
        </tr>
        <tr>
          <td height="14">&nbsp;</td>
          <td height="14"><div align="right"></div></td>
        </tr>
<%
//last person advised.. 
String strSQLQuery = "select encoded_by from enrl_final_cur_list where user_index = "+(String)vStudInfo.elementAt(0)+
					" and is_valid =1 and is_temp_stud = 0 and sy_from = "+ astrSchYrInfo[0] +" and current_semester="+astrSchYrInfo[2]+" order by enroll_index desc";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null)
	strSQLQuery = comUtil.getName(dbOP, Integer.parseInt(strSQLQuery), 4);
%>        <tr>
          <td height="14" colspan="2" style="font-size:12px;">Advised By: <u><%=WI.getStrValue(strSQLQuery)%></u></td>
          </tr>
        <tr>
          <td height="14" colspan="2" style="font-size:12px;">Printed By: <u><%=comUtil.getName(dbOP,Integer.parseInt((String)request.getSession(false).getAttribute("userIndex")),4)%></u></td>
          </tr>
      </table>

	</td>
    <td width="10%">&nbsp;</td>
    <td width="45%" valign="top">&nbsp;
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC") && !bolIsFatima){%>
        <tr>
          <td width="54%" height="14"><div align="right"><strong>:: PAYMENT DETAILS
              ::</strong></div></td>
          <td width="46%" height="14">&nbsp;</td>
        </tr>
<%}%>
<%if(!strSchoolCode.startsWith("WNU") && !strSchoolCode.startsWith("UL") && !strSchoolCode.startsWith("CSA") && false){%>
        <tr>
          <td height="14">PAYEE TYPE</td>
          <td height="14"><strong><%=(String)vRetResult[0].elementAt(1)%></strong></td>
        </tr>
<%}%>
        <%if(vRetResult[0].elementAt(2) != null){%>
        <tr>
          <td height="14">PAYEE NAME </td>
          <td height="14"><strong><%=WI.getStrValue(vRetResult[0].elementAt(2))%></strong></td>
        </tr>
        <%}%>
        <tr>
          <td height="14">PAYMENT MODE </td>
          <td height="14"><strong><%=(String)vRetResult[0].elementAt(3)%></strong></td>
        </tr>
        <%if(vRetResult[0].elementAt(4) != null){%>
        <tr>
          <td height="14">ASSISTANCE TYPE</td>
          <td height="14"><strong><%=WI.getStrValue(vRetResult[0].elementAt(4))%></strong></td>
        </tr>
        <%}%>
        <tr>
          <td height="14">AMOUNT PAID</td>
          <td height="14"><strong><%=CommonUtil.formatFloat((String)vRetResult[1].elementAt(5),true)%></strong></td>
        </tr>
        <%if(strEnrolmentDiscDetail != null && !strSchoolCode.startsWith("UDMC")){%>
        <tr>
          <td height="14" colspan="2"><font size="1">(<%=strEnrolmentDiscDetail%>)</font></td>
        </tr>
        <%}
		if(vRetResult[1].elementAt(3) != null){%>
        <tr>
          <td height="14">APPROVAL NO.</td>
          <td height="14"><strong><%=WI.getStrValue(vRetResult[1].elementAt(3))%></strong></td>
        </tr>
        <%} if(vRetResult[1].elementAt(1) != null && !(vRetResult[1].elementAt(1)).equals("Internal")){%>
        <tr>
          <td height="14">PAYMENT RECEIVE TYPE</td>
          <td height="14"><strong><%=(String)vRetResult[1].elementAt(1)%></strong></td>
        </tr>
		<%}if(vRetResult[1].elementAt(2) != null){%>
        <tr>
          <td height="14">BANK NAME </td>
          <td height="14"><strong><%=WI.getStrValue(vRetResult[1].elementAt(2))%></strong></td>
        </tr>
        <%}%>
        <tr>
          <td height="14">DATE PAID</td>
          <td height="14"><strong><%=(String)vRetResult[1].elementAt(8)%></strong></td>
        </tr>
        <%if(vRetResult[1].elementAt(4) != null){%>
        <tr>
          <td height="14">PAYMENT TYPE</td>
          <td height="14"><strong><%=(String)vRetResult[1].elementAt(4)%></strong></td>
        </tr>
        <%}if(vRetResult[1].elementAt(6) != null){%>
        <tr>
          <td height="14">CHECK #</td>
          <td height="14"><strong><%=WI.getStrValue(vRetResult[1].elementAt(6))%></strong></td>
        </tr>
        <%}%>
        <tr>
          <td height="14">REFERENCE NUMBER</td>
          <td height="14"><strong><%=(String)vRetResult[1].elementAt(7)%></strong></td>
        </tr>
        <tr>
          <td height="14" colspan="2"></td>
          </tr>
<%}//do not show for WNU%>		
 <%if(!strSchoolCode.startsWith("UL")){
 double dAddToInstallationFee = 0d;
 if(bolIsFatima && dFatimaInstallmentFee > 0d) {
 	int iNoOfInstallment = 0;
	if(vInstallmentDtls != null && vInstallmentDtls.size() > 0) 
		iNoOfInstallment = (vInstallmentDtls.size() - 5)/3;
 	dAddToInstallationFee = dFatimaInstallmentFee/iNoOfInstallment;
 }
/**
 if(fOutstanding !=0d && strSchoolCode.startsWith("EAC")) {
 	int iNoOfInstallment = 0;
	if(vInstallmentDtls != null && vInstallmentDtls.size() > 0) 
		iNoOfInstallment = (vInstallmentDtls.size() - 5)/3;

 	dAddToInstallationFee = -1 * fOutstanding/iNoOfInstallment;
	
}**/
 
 %>
       <tr>
          <td height="14" colspan="2"><font size="2"><b><%=((String)vInstallmentDtls.elementAt(5)).toUpperCase()%> DUE
		  <%if(bolShowExamDate){%>(<%=vInstallmentDtls.elementAt(6)%>)
		  <%}%>
		  : <%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(7)) + dAddToInstallationFee,true)%></b></font> </td>
        </tr>
<%
//loop here.
if(vInstallmentDtls != null){
	for(int i = 5 + 3 * 1; i < vInstallmentDtls.size(); i += 3) {%>
        <tr>
          <td height="14" colspan="2"><%=((String)vInstallmentDtls.elementAt(i)).toUpperCase()%> DUE <%if(bolShowExamDate){%>(<%=vInstallmentDtls.elementAt(i + 1)%>)<%}%>: <%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(i+2)) + dAddToInstallationFee,true)%> </td>
        </tr>
<%}
}%>
       <tr>
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
        <tr>
          <td height="14" colspan="2">(NOTE: Above installment schedule may change based on actual payment and after enrolment adjustments.)</td>
        </tr>
        <tr>
          <td height="14" colspan="2">&nbsp;</td>
        </tr>

        <tr>
          <td height="14" colspan="2" style="border-top:solid 1px #000000;border-bottom:solid 1px #000000;border-left:solid 1px #000000;border-right:solid 1px #000000;">
		  	<table width="95%" align="center"><tr>
		  	  <td style="font-size:10px; font"><div align="justify">
				<i><font style="font-size:12px;">RULES GOVERNING RECORD/ADJUSTMENT OF FEES</font></i><br>
				1. When a student registers in the College, it is understood that he/she is enrolling for the entire semester. 
				<br>
				2. A student who transfers or otherwise withdraws, in writing, within two (2) weeks after the beginning of classes and who has already paid the pertinent tuition and other school fees in full or any length of time longer than one (1) month may be charged ten percent (10%) of tuition of he/she withdraws within the first week of classes or twenty percent (20%) of tuition if within the second week of classes, regardless of whether or not he/she has actually attended the classes. The student may be charged all the school fees in full if he/she withdraws anytime after the second week of classes. 
				<br>
				3. If the transfer or withdrawal is due to a justifiable reason, the student shall be charged the pertinent fees only up to and including the last month of attendance. 
				<br>
				4. Registration and other pertinent fees are not refundable.

		  	    </div></td>
	  	  </tr></table>		  </td></tr>

      </table>
	</td>
  </tr>
</table>
<%
		}//if payment detail and payment mode not null;
	}//if student information exists.
}//if miscellaneous fee information exists.
dbOP.cleanUP();
%>
</body>
</html>
