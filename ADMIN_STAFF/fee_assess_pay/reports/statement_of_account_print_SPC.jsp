<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,
	enrollment.FAAssessment,enrollment.SubjectSection,enrollment.EnrlAddDropSubject,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5 = WI.getStrValue((String)request.getSession(false).getAttribute("info5"));
	//strSchoolCode = "UPH";
	boolean bolIsFatima = strSchoolCode.startsWith("FATIMA");
	
	if(strSchoolCode == null) {
		%>
		<font style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:#FF0000">
			You are already logged out. Please login again to access this page.
		<%
		return;
	}
	//strSchoolCode = "UL";
	boolean bolIsUL = strSchoolCode.startsWith("UL");

	//for swu :: multiply by two
	boolean bolMultiplyByTwo = false;

	String strStudID = WI.fillTextValue("stud_id");
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	
if(WI.fillTextValue("myhome").length() > 0) 
	strStudID = (String)request.getSession(false).getAttribute("userId");
else {
	if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4")) {%>
		<p style="font-size:24px; font-weight:bold">You are not authorized to access this account.</p>
	<%return;}
	
}
	
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
    TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
-->
</style>
</head>

<body onLoad="window.print();">
<%
	String strErrMsg = null;
	String strTemp = null;
	String strSubSecIndex = null;
	Vector vLabSched      = null;
	
	String strORNumber    = null;
	String strSQLQuery    = null;
	java.sql.ResultSet rs = null;


	String strDegreeType  = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	String[] astrSchYrInfo = {"0","0","0"};

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

///get the downpayment or number.
String strStudIndex = dbOP.mapUIDToUIndex(strStudID);
strSQLQuery = "select or_number from fa_stud_payment where user_index = "+strStudIndex+" and payment_for = 0 and pmt_sch_index = 0 and sy_from = "+WI.fillTextValue("sy_from")+
			" and semester = "+WI.fillTextValue("semester")+" and is_valid = 1 and is_stud_temp = 0";
strORNumber = dbOP.getResultOfAQuery(strSQLQuery, 0);



if(strORNumber == null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Downpayment information not found.</font></p>
		<%
	dbOP.cleanUP();
	return;
}

Vector vStudInfo = null;
Vector vMiscFeeInfo = null;
Vector vTemp = null;
Vector vORInfo = null;

String strPrintedBy = null;


float fTutionFee        = 0f;
float fCompLabFee       = 0f;
float fMiscFee          = 0f;
float fOutstanding      = 0f;
float fTotalPayableAmt 	= 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,

double dTotalDiscount   = 0d;

double dLateFineSPC     = 0d;//hard coded to FINES - LATE ENROLMENT

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
Vector vScheduledPmt = null;
double dOtherSchPayable = 0d;
double dTotalAmtPaid = 0d;


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
if(vStudInfo == null) strErrMsg = enrlStudInfo.getErrMsg();
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

		dTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),(String)vORInfo.elementAt(23),
        				(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),null);
		dTotalAmtPaid  = fOperation.calTotalAmoutPaidPerFee(dbOP, 0,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

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
			
		strSQLQuery = "select fa_stud_payable.amount from fa_stud_payable join fa_oth_sch_fee on (othsch_fee_index = reference_index) where user_index = "+
						vORInfo.elementAt(0) +" and sy_from = "+astrSchYrInfo[0]+" and semester = "+
						astrSchYrInfo[2]+" and fa_stud_payable.is_valid = 1 and fee_name = 'FINES - LATE ENROLMENT'";//fee name is Installment Fee and sy_index = 0;
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null)
			dLateFineSPC = Double.parseDouble(strSQLQuery);
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
	vScheduledPmt = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(vScheduledPmt == null)
		strErrMsg = FA.getErrMsg();
	vTemp = FA.getOtherChargePayable(dbOP,WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"), (String)vStudInfo.elementAt(0));
	if(vTemp != null && vTemp.size() > 0) {
		strTemp = (String)vTemp.elementAt(0);
		if(strTemp != null && !strTemp.equals("0.00"))
			dOtherSchPayable = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
	}

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

strPrintedBy = (String)request.getSession(false).getAttribute("userIndex");
if(strPrintedBy != null) {
	strPrintedBy = "select fname from user_table where user_index = "+strPrintedBy;
	strPrintedBy = dbOP.getResultOfAQuery(strPrintedBy, 0).toLowerCase();
}



Vector vSection = new Vector();//sections.
/**
* added to get hours enrolled/per hour computation
*/
double dTotalUnitsCharged = 0d;
Vector vSubjectPerHour = new Vector();
double dHoursCharged   = 0d;
double dUnitsExcluded  = 0d; double dUnitsSubNoFee = 0d;

Vector vDiscountDtls   = new Vector();

Vector vSubExcluded = new Vector();

String strSectionName = null;
/********* done *******/
if(strErrMsg == null && vStudInfo != null) {
	String strCourseIndex = null;
	String strMajorIndex  = null;
	String strYearLevel   = null;
	
	strSQLQuery = "select section_name from stud_curriculum_hist where user_index = "+(String)vStudInfo.elementAt(0)+
		" and sy_from = "+astrSchYrInfo[0]+" and semester = "+astrSchYrInfo[2]+" and is_valid = 1";
	strSectionName = dbOP.getResultOfAQuery(strSQLQuery, 0);	
	//System.out.println(strSQLQuery);	

	
	strSQLQuery = "select sub_code, max_hour from fa_tution_fee "+
	"join fa_schyr on (fa_schyr.sy_index = fa_tution_fee.sy_index) "+
	"join subject on (subject.sub_index = fa_tution_fee.sub_index) "+
	" join ( "+
 	"       select max(hour_lec + hour_lab) as max_hour, sub_index as si from curriculum "+
	"       where is_valid = 1 group by sub_index) as dt_cur on dt_cur.si = fa_tution_fee.sub_index "+
	" where compute_per_hour = 1 and (semester is null or semester = "+astrSchYrInfo[2]+
	") and sy_from = "+astrSchYrInfo[0]+" and fa_tution_fee.is_Valid = 1 and (sub_index_course = 0 or sub_index_course= "+
	(String)vStudInfo.elementAt(5)+")";
	
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vSubjectPerHour.addElement(rs.getString(1));
		vSubjectPerHour.addElement(new Double(rs.getDouble(2)));
	}
	rs.close();
	
	if(dTotalDiscount > 0d) {
		strSQLQuery = "select grant_name, discount_amt from FA_FEE_HISTORY_GRANTS where USER_INDEX = "+(String)vStudInfo.elementAt(0)+
						" and SY_FROM = "+astrSchYrInfo[0]+" and SEMESTER = "+astrSchYrInfo[2];
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vDiscountDtls.addElement(rs.getString(1));
			vDiscountDtls.addElement(CommonUtil.formatFloat(rs.getDouble(2), true));
		}
		rs.close();
		
	}
	strSQLQuery = "select sub_code from subject join FA_SUB_NOFEE on (FA_SUB_NOFEE.SUB_INDEX = subject.SUB_INDEX) "+
					"where FA_SUB_NOFEE.IS_DEL = 0 and SY_FROM = "+astrSchYrInfo[0]+" and SEMESTER = "+astrSchYrInfo[2];
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vSubExcluded.addElement(rs.getString(1));
	}
	rs.close();

}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="7"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
		  STATEMENT OF ACCOUNT        
          <br>        
        <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>, AY <%=astrSchYrInfo[0]%>-<%=astrSchYrInfo[1]%></div></td>
    </tr>   
</table>
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

 <table width="100%" border="0" cellpadding="0" cellspacing="0">
 	<tr>
		<td height="17" width="10%">Student No. </td>
		<td width="65%"><strong>: <%=(String)vORInfo.elementAt(25)%></strong></td>
		<td width="7%">Status</td>
		<td width="18%"><strong>: <%=(String)vStudInfo.elementAt(15)%></strong></td>
	</tr>
	<tr>
		<td height="17">Name </td>
		<td><strong>: <font size="2"><%=(String)vStudInfo.elementAt(1)%></font></strong></td>
		<td>Section</td>
		<td> 
		<strong>: 
		<%if(strSectionName!= null) {%>
			<%=strSectionName%>
		<%}else{%>
			<label id="section_name"></label>
		<%}%>
		</strong>
		</td>
	</tr>
	<tr>
		<td height="17">Course/Yr </td>
		<td>
		<strong>: <%=(String)vStudInfo.elementAt(2)%><%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%>
		<%=WI.getStrValue((String)vStudInfo.elementAt(4)," - ","","N/A")%></strong>
		</td>
		<td>Gender</td>
		<td><strong>: <%=WI.getStrValue(vStudInfo.elementAt(13),"")%></strong></td>
	</tr>
	<tr><td colspan="4" height="12"></td></tr>
 </table>

 <%
double dUnitsTaken = 0d;

if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0)
{%>
<!--
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
		<td width="16%" height="18" class="thinborderTOPBOTTOM">Schedule Code</td>
		<td width="38%" class="thinborderTOPBOTTOM">Description</td>
		<td width="5%" align="center" class="thinborderTOPBOTTOM">Unit</td>
		<td width="20%" align="" class="thinborderTOPBOTTOM">Day - Time</td>
		<td width="8%" class="thinborderTOPBOTTOM">Room</td>
		<td width="13%" class="thinborderTOPBOTTOM">Section Code</td>
  </tr>
  <%
  	int iIndexOf = 0;
	
	String strTime = null;
	String strDay = null;
	String strSchedule = null;
	
	String strSection = null; String strRoom = null; String strRoomAndSection = null;
	Vector vSubSecDtls = new Vector();
	String strFeeTypeCatg = null; //0=>per unit,1= per lec/lab, 2=per subject,3=total tuition fee.

for(int i = 0; i<vAssessedSubDetail.size(); ++i) {
	dUnitsTaken += Double.parseDouble((String)vAssessedSubDetail.elementAt(i+9));
	strSubSecIndex = (String)vAssessedSubDetail.elementAt(i);

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
		if(strSchedule == null) {
			strSection  = (String)vSubSecDtls.elementAt(b);
			strRoom     = (String)vSubSecDtls.elementAt(b+1);
			strSchedule = (String)vSubSecDtls.elementAt(b+2);
		}
		else
		{
			strRoom     += "<br>"+(String)vSubSecDtls.elementAt(b+1);
			strSchedule += "<br>"+(String)vSubSecDtls.elementAt(b+2);
		}
		b = b+2;
	}
	if(vLabSched != null)
	{
	  for (int p = 0; p < vLabSched.size(); ++p)
	  {
		strSchedule += "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
		strRoom     += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
		p = p+ 2;
	  }
	}
	
	
	iIndexOf = vSubjectPerHour.indexOf(vAssessedSubDetail.elementAt(i + 1));
	if(iIndexOf > -1) {//compute per hour
		dUnitsExcluded += Double.parseDouble((String)vAssessedSubDetail.elementAt(i + 9));
		dHoursCharged  += ((Double)vSubjectPerHour.elementAt(iIndexOf + 1)).doubleValue();
	}
	
	strTemp = (String)vAssessedSubDetail.elementAt(i+1);
	if(strTemp.indexOf("NSTP") != -1){
	  iIndexOf = strTemp.indexOf("(");
	  if(iIndexOf != -1){
		strTemp = strTemp.substring(0,iIndexOf);
		strTemp = strTemp.trim();
	  }
	}
	if(vSubExcluded.indexOf(strTemp) > -1) {
		dUnitsSubNoFee += Double.parseDouble((String)vAssessedSubDetail.elementAt(i + 9));
	}

%>
  <tr>
    <td height="16" class="thinborderBOTTOM"><%=(String)vAssessedSubDetail.elementAt(i + 1)%></td>
    <td class="thinborderBOTTOM"><%=(String)vAssessedSubDetail.elementAt(i+2)%></td>
    <td class="thinborderBOTTOM" align="center"><%=(String)vAssessedSubDetail.elementAt(i+9)%></td>
    <td class="thinborderBOTTOM"><%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class="thinborderBOTTOM"><%=WI.getStrValue(strRoom,"TBA")%></td>
	<td class="thinborderBOTTOM"><%=WI.getStrValue(strSection,"TBA")%></td>
  </tr>
  <%
	iIndexOf = vSection.indexOf(strSection);
	if(iIndexOf == -1) {
		vSection.addElement(strSection);
		vSection.addElement("1");
	}
	else {
		vSection.setElementAt(Integer.toString(Integer.parseInt((String)vSection.elementAt(iIndexOf + 1)) + 1), iIndexOf + 1);
	}
strSection  = null;
strRoom     = null;
strSchedule = null;
i = i+9;

}
//set the section name here.
int iCount = 0;
for(int i = 0; i < vSection.size(); i += 2) {
	if(iCount < Integer.parseInt((String)vSection.elementAt(i + 1)))
		iCount = Integer.parseInt((String)vSection.elementAt(i + 1));	
}
iIndexOf = vSection.indexOf(Integer.toString(iCount));
if(iIndexOf > 0) {%>
<script>
	var objSection = document.getElementById('section_name');
	if(objSection)
		objSection.innerHTML = '<%=vSection.elementAt(iIndexOf - 1)%>';
</script>
<%}%>

<tr>
	<td colspan="2" align="right"><strong>Total Unit &nbsp; &nbsp; &nbsp;</strong></td>
	<td class="thinborderBOTTOM" align="center"><strong><%=dUnitsTaken%></strong></td>
</tr>
<tr><td height="10"></td></tr>
</table>
-->
<%}//if vAssessedSubDetail no null

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
dUnitsTaken = dUnitsTaken - dUnitsSubNoFee;
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	
	<tr>
		<td width="70%" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="dotborderBOTTOM" width="48%" height="18" style="padding-left:40px;">School Fee</td>
					<td class="dotborderBOTTOM" width="8%">Units</td>
					<td class="dotborderBOTTOM" width="9%">Hrs</td>
					<td class="dotborderBOTTOM" width="11%" align="right">Rate</td>
					<td class="dotborderBOTTOM" width="20%" align="right">Amount</td>
					<td class="dotborderBOTTOM" width="4%">&nbsp;</td>
				</tr>
<%if(dHoursCharged == 0d) {%>
				<tr>				 
				  <td height="18">Tuition Fee</td>
				  <td><%=dUnitsTaken%></td>
				  <td>&nbsp;</td>
				  <td align="right"><%if(dUnitsTaken == 0d) {%> 0.00<%}else{%><%=CommonUtil.formatFloat(((double)fTutionFee / dUnitsTaken) ,true)%><%}%></td>
				  <td align="right"><strong><%if(dUnitsTaken == 0d) {%> 0.00<%}else{%><%=CommonUtil.formatFloat(fTutionFee,true)%><%}%></strong></td>				 
				</tr>
<%}else{
double dUnitsCharged = dUnitsTaken - dUnitsExcluded;
double dUnitRate = fTutionFee / (dUnitsCharged + dHoursCharged) ;
if(dUnitsCharged > 0d) {
%>
				<tr>				 
				  <td height="18">Tuition Fee</td>
				  <td><%=dUnitsCharged%></td>
				  <td>&nbsp;</td>
				  <td align="right"><%=CommonUtil.formatFloat(dUnitRate ,true)%></td>
				  <td align="right"><strong><%=CommonUtil.formatFloat(dUnitRate *dUnitsCharged ,true)%></strong></td>				 
				</tr>
<%}%>
				<tr>				 
				  <td height="18">Tuition Fee w/Lab</td>
				  <td><%=dUnitsExcluded%></td>
				  <td><%=dHoursCharged%></td>
				  <td align="right"><%=CommonUtil.formatFloat(dUnitRate ,true)%></td>
				  <td align="right"><strong><%=CommonUtil.formatFloat(dUnitRate *dHoursCharged ,true)%></strong></td>				 
				</tr>
<%}if(fCompLabFee > 0f){%>
					<tr>					  
					  <td height="18">Computer Lab Fee.</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td><td>&nbsp;</td>
					  <td align="right"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></td>
					</tr>
<%}%>
<%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
		continue;
%>
				<tr>				
				  <td>&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
				  <td align="right">&nbsp;<strong></strong></td>
				</tr>
<%}%>
				
				<tr>				  
				  <td height="18">Miscellaneous and Other Fees</td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				</tr>
				<%
				for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
					if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0)
						continue;
				%>
				<tr>				
				  <td>&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
				  <%
				  strTemp = "";
				  if(i + 3 >= vMiscFeeInfo.size())
				  	strTemp = CommonUtil.formatFloat(fMiscFee + dLateFineSPC,true);
				  %>
				  <td align="right">&nbsp;<strong><%if(dLateFineSPC == 0d){%><%=strTemp%><%}%></strong></td>
				</tr>
				<%}%>
				<%if(dLateFineSPC > 0d){%>
				<tr>				
				  <td>&nbsp;&nbsp;&nbsp;Late Enrollment Fine</td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td align="right"><%=CommonUtil.formatFloat(dLateFineSPC,true)%></td>
				  <td align="right">&nbsp;<strong><%=strTemp%></strong></td>
				</tr>
				<%}%>
				<tr>
					<td height="18">TOTAL FEES</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td align="right" style="padding-left:10px;"><div style="border-top:solid 2px #000000; border-bottom:solid 2px #000000; font-weight:bold;">
						<%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee+dLateFineSPC,true)%></div></td>
				</tr>
				<tr>
				  <td height="18">OLD ACCOUNT (ADD)/REFUNDED (LESS) </td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td style="padding-left:10px;" align="right">&nbsp;</td>
				  <td align="right" style="padding-left:10px;"><%=CommonUtil.formatFloat(fOutstanding, true)%></td>
			  </tr>
				<tr>
				  <td height="18">OTHERSCHOOL FEE+ADJUSTMENTS (ADD)/(LESS) </td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td style="padding-left:10px;" align="right">&nbsp;</td>
				  <td align="right" style="padding-left:10px;"><%=CommonUtil.formatFloat(dOtherSchPayable, true)%></td>
			  </tr>
			  <%if(fEnrollmentDiscount > 0f) {%>
				<tr>
				  <td height="18">FULL PAYMENT DISCOUNT (LESS) </td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td style="padding-left:10px;" align="right">&nbsp;</td>
				  <td align="right" style="padding-left:10px;"><%=CommonUtil.formatFloat(fEnrollmentDiscount, true)%></td>
			  </tr>
			  <%}%>
				<tr>
				  <td height="18">SCHOLARSHIP/GRANTS (LESS)</td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td style="padding-left:10px;" align="right">&nbsp;</td>
				  <td align="right" style="padding-left:10px;"><%=CommonUtil.formatFloat(dTotalDiscount, true)%></td>
			  </tr>
				<tr>
				  <td height="18">TOTAL PAYMENT (LESS)</td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td style="padding-left:10px;" align="right">&nbsp;</td>
				  <td align="right" style="padding-left:10px;"><%=CommonUtil.formatFloat(dTotalAmtPaid, true)%></td>
			  </tr>
				<tr>
				  <td height="18">CURRENT BALANCE </td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td style="padding-left:10px;" align="right">&nbsp;</td>
				  <td align="right" style="padding-left:10px;">
				  <div style="border-top:solid 2px #000000; border-bottom:solid 2px #000000; font-weight:bold;">
				  <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee+dLateFineSPC - fEnrollmentDiscount
				  +fOutstanding+dOtherSchPayable-dTotalDiscount-dTotalAmtPaid
				  ,true)%>				  </div>				  </td>
			  </tr>
			</table>		</td>
		
	  <td width="30%" align="center" valign="top" style="border-left:dotted 1px #000000;">
	  
	      <%
			double dTemp = 0d;
		if(vScheduledPmt != null && vScheduledPmt.size() > 0) {%>
				<table width="100%">
					<tr><td align="center">PAYMENT SCHEDULE</td></tr>
				</table>
				<table border="0" width="96%" class="thinborder" cellpadding="0" cellspacing="0">
					<%
					for(int i = 7; i < vScheduledPmt.size(); i += 2) {
					dTemp = ((Double)vScheduledPmt.elementAt(i + 1)).doubleValue();
					if(dTemp < 0d) {
						if( (i + 3) <  vScheduledPmt.size()) {
							vScheduledPmt.setElementAt(new Double(((Double)vScheduledPmt.elementAt(i + 3)).doubleValue() + dTemp), i + 3);
						}
						dTemp = 0d;
						
					}%>
					<tr>
						<td class="thinborder" height="22" style="font-size:12px;"><%=vScheduledPmt.elementAt(i)%></td>
						<td class="thinborder" style="font-size:12px;"><%=CommonUtil.formatFloat(dTemp, true)%></td>
					</tr>
					<%}%>
				</table>
		<%}//if(vScheduledPmt != null && vScheduledPmt.size() > 0) %>	  </td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td width="1%" height="10">&nbsp;</td>
      <td colspan="2" >&nbsp;</td>
      <td colspan="3" >&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td colspan="2" >&nbsp;</td>
      <td colspan="3" >&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td colspan="2" >Prepared by :</td>
      <td colspan="3" >&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="50%"><u>&nbsp;&nbsp;<%=strPrintedBy%>&nbsp;&nbsp;</u></td>
      <td width="9%">&nbsp;</td>

    <td width="23%">&nbsp;</td>
    <td width="9%">&nbsp;</td>
    </tr>
<!--
    <tr>
      <td height="16">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center" valign="top">&nbsp;Comptroller</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center" valign="top">&nbsp;Registrar</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center" valign="top">&nbsp;OSA</td>
      <td>&nbsp;</td>
    </tr>
-->
</table>


<%
		}//if payment detail and payment mode not null;
	}//if student information exists.
}//if miscellaneous fee information exists.
dbOP.cleanUP();
%>
</body>
</html>
