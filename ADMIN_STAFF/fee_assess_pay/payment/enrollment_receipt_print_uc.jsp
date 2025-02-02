<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,
	enrollment.FAAssessment,enrollment.SubjectSection,enrollment.EnrlAddDropSubject,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	strSchoolCode = "UC";
	boolean bolIsFatima = strSchoolCode.startsWith("FATIMA");
	
	if(strSchoolCode == null) {
		%>
		<font style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:#FF0000">
			You are already logged out. Please login again to access this page.
		<%
		return;
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
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderTOPBOTTOM {
    border-bottom: solid 1px #000000;
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderTOPBOTTOMRIGHT {
    border-bottom: solid 1px #000000;
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
</head>

<body onLoad="window.print();" leftmargin="0" rightmargin="0" bottommargin="0" topmargin="125">
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

double dReqdDP = 0d;

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
String strEnrollmentNo = null;

String strLastSchoolAttended = null;
String strSecondarySchName   = null;
String strSecondarySchAddr   = null;
String strSecondarySchYear   = null;

String strAdviser = null;

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
				(String)vORInfo.elementAt(25),(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
if(vStudInfo == null) strErrMsg = enrlStudInfo.getErrMsg();
else
{//System.out.println(vStudInfo);
	astrSchYrInfo[0] = (String)vORInfo.elementAt(23);
	astrSchYrInfo[1] = (String)vORInfo.elementAt(24);
	astrSchYrInfo[2] = (String)vORInfo.elementAt(22);
	
	///////////////////////save printed by:: 
	String strSQLQuery = "select cur_hist_index, DATE_PRINTED from stud_curriculum_hist where user_index = "+(String)vStudInfo.elementAt(0)+
						" and is_valid = 1 and sy_from = "+astrSchYrInfo[0]+
						" and semester = "+astrSchYrInfo[2];
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		if(rs.getDate(2) == null) {
			strSQLQuery = "update stud_curriculum_hist set date_printed = '"+WI.getTodaysDate()+
							"', FORM_PRINTED_BY="+(String)request.getSession(false).getAttribute("userIndex")+" where cur_hist_index = "+rs.getString(1);
			rs.close();
			dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
		}	
		else	
			rs.close();
	}
	//////////////////////////// end of cose saved by.. 
	

//get other informtion here..
strLastSchoolAttended = "select sch_name from SCH_ACCREDITED "+
				"join CROSS_ENROLEE_INFO on (CROSS_ENROLEE_INFO.sch_index = sch_accredited.sch_accr_index) "+
				"where CROSS_ENROLEE_INFO.is_valid = 1 and is_tempstud = 0 and user_index = "+(String)vStudInfo.elementAt(0);
strLastSchoolAttended = dbOP.getResultOfAQuery(strLastSchoolAttended, 0);
if(strLastSchoolAttended == null) {
	strLastSchoolAttended = "select sch_name from SCH_ACCREDITED "+
					"join transferee_info on (transferee_info.sch_index = sch_accredited.sch_accr_index) "+
					"where transferee_info.is_valid = 1 and is_tempstud = 0 and user_index = "+(String)vStudInfo.elementAt(0);
	strLastSchoolAttended = dbOP.getResultOfAQuery(strLastSchoolAttended, 0);
}
	

strSecondarySchName = "select SCH_ACCREDITED.sch_name, sch_addr, year_grad from INFO_EDU_QUALIF "+
						"join SCH_ACCREDITED on (SCH_ACCREDITED.sch_name = INFO_EDU_QUALIF.SCH_NAME) " +
						" where info_edu_qualif.user_index ="+(String)vStudInfo.elementAt(0);
rs = dbOP.executeQuery(strSecondarySchName);
if(rs.next()) {
	strSecondarySchName = rs.getString(1);
	strSecondarySchAddr = rs.getString(2);
	strSecondarySchYear = rs.getString(3);
}
else
	strSecondarySchName = null;
rs.close();	

	paymentUtil.setTempUser("0");
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        (String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
        (String)vORInfo.elementAt(22));//System.out.println("Test : "+vMiscFeeInfo);
	
	strTemp = "select c_name, dean_name,tution_type from college join course_offered on (course_offered.c_index = college.c_index) where course_index = "+(String)vStudInfo.elementAt(5);
	rs = dbOP.executeQuery(strTemp); 
	strTemp = null;
	if(rs.next()) {
		strCollegeName = rs.getString(1);
		strDeanName    = rs.getString(2);
		strTemp = rs.getString(3);
	}
	rs.close();
	
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
		
	///get here cur_hist_index
	strEnrollmentNo = "select cur_hist_index from stud_curriculum_hist where sy_from = "+vORInfo.elementAt(23)+" and semester = "+vORInfo.elementAt(22)+
						" and is_valid = 1 and user_index = "+vStudInfo.elementAt(0);
	strEnrollmentNo = dbOP.getResultOfAQuery(strEnrollmentNo, 0);
	if(strTemp != null && strTemp.equals("2")) {
		astrConvertSem[1] = "1st Trimester";
		astrConvertSem[2] = "2nd Trimester";
		astrConvertSem[3] = "3rd Trimester";
	}
	if(strEnrollmentNo != null) {
		while(strEnrollmentNo.length() < 6)
			strEnrollmentNo = "0"+strEnrollmentNo;
	}
	//System.out.println(new java.util.Date().getTime());
	//get adviser.. 
	strTemp = "select encoded_by from enrl_final_cur_list where sy_from = "+vORInfo.elementAt(23)+" and current_semester = "+vORInfo.elementAt(22)+
			" and is_valid = 1 and user_index = "+vStudInfo.elementAt(0)+" order by enroll_index desc";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null) {
		strTemp = "select fname, mname, lname from user_table where user_index = "+strTemp;
		rs = dbOP.executeQuery(strTemp);
		if(rs.next())
			strAdviser = WI.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 4);
		rs.close();
	}
	//System.out.println(new java.util.Date().getTime());
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
		else {
			enrollment.FAStudMinReqDP faMinDP = new enrollment.FAStudMinReqDP(null);
			faMinDP.setTotalAssessment(fTutionFee+fMiscFee+fCompLabFee+fOutstanding);
			dReqdDP = faMinDP.getPayableDownPayment(dbOP, (String)vORInfo.elementAt(25), astrSchYrInfo[0], astrSchYrInfo[1],astrSchYrInfo[2], strSchoolCode, 1, 
							(String)vStudInfo.elementAt(0), paymentUtil.isTempStud());
							
			
			
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

//System.out.println(fOperation.vAssessedHrDetail);
boolean bolShowMiscDtls = true;
boolean bolShowOthChargeDtls = true;

boolean bolShowExamDate = false;
if(strSchoolCode.startsWith("DBTC") || bolIsFatima)
	bolShowExamDate = true;

if(bolIsFatima) {
	bolShowMiscDtls      = false;
	bolShowOthChargeDtls = false;
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
		<td width="50%">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td width="24%">Enrollment No.</td>
					<td><%=strEnrollmentNo%></td>
				</tr>
				<tr>
					<td colspan="2"></td>
				</tr>
				<tr>
				  <td colspan="2">
				  	<%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>, SY <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%>
				  </td>
			  </tr>
				<tr>
					<td width="24%">Student ID</td>
					<td><%=(String)vORInfo.elementAt(25)%> (<%=(String)vStudInfo.elementAt(15)%>)</td>
				</tr>
				<tr>
					<td width="24%">Student Name</td>
					<td><%=(String)vStudInfo.elementAt(1)%></td>
				</tr>
			</table>
		</td>
		<td width="50%" valign="top">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td width="17%">Course</td>
					<td width="83%"><%=(String)vStudInfo.elementAt(2)%></td>
				</tr>
				<tr>
					<td colspan="2"></td>
				</tr>
				<tr>
					<td width="17%">Major</td>
					<td><%=WI.getStrValue(vStudInfo.elementAt(3))%></td>
				</tr>
				<tr>
					<td width="17%">Year Level </td>
					<td><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>


<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0)
{%>
<table width="100%" cellpadding="0" cellspacing="0" border="0" height="300"><tr><td valign="top">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr align="center">
    <td width="10%" class="thinborderTOPBOTTOMRIGHT"><strong>SECTION</strong></td>
    <td width="10%" height="19" class="thinborderTOPBOTTOMRIGHT"><strong>SUBJECT CODE </strong></td>
    <td width="42%" height="19" class="thinborderTOPBOTTOMRIGHT"><strong>DESCRIPTION</strong></td>
    <td width="23%" class="thinborderTOPBOTTOMRIGHT"><strong>SCHEDULE</strong></td>
    <td width="10%" class="thinborderTOPBOTTOMRIGHT"><strong>ROOM </strong></td>
    <td width="5%" class="thinborderTOPBOTTOM"><strong>UNITS TAKEN</strong></td>
  </tr>
  <%//System.out.println(vAssessedSubDetail);
 	float fFirstInstalAmt = 0f;
	float fTotalLoad = 0;float fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	float fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.
String strSchedule = null;
String strRoom = null; String strSection = null;
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

			if(strRoom == null)
			{
				strSection  = (String)vSubSecDtls.elementAt(b);
				strRoom     = (String)vSubSecDtls.elementAt(b+1);
				strSchedule = (String)vSubSecDtls.elementAt(b+2);
			}
			else
			{
				strRoom += "<br>"+(String)vSubSecDtls.elementAt(b+1);
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
			strRoom += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
%>
  <tr >
    <td class="thinborderRIGHT"><%=WI.getStrValue(strSection,"N/A")%></td>
    <td height="19" class="thinborderRIGHT"><%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
    <td class="thinborderRIGHT"><%=(String)vAssessedSubDetail.elementAt(i+2)%></td>
    <td class="thinborderRIGHT"><%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class="thinborderRIGHT"><%=WI.getStrValue(strRoom,"N/A")%></td>
    <td class="thinborderNONE"><%=(String)vAssessedSubDetail.elementAt(i+9)%></td>
  </tr>
  <% i = i+9;
strRoom = null;
strSchedule = null;
}%>
  <tr >
    <td colspan="5" align="right" class="thinborderTOP">
        <%if(strErrMsg != null){%>
        	<%=strErrMsg%>
        <%}else{%>
        TOTAL LOAD UNITS: 
        <%}%>    
	</td>
    <td class="thinborderTOP">
        <%if(strErrMsg != null){%>
        	<%=strErrMsg%>
        <%}else{%>
        <%=fUnitsTaken%>
        <%}%>    
	</td>
  </tr>
</table>
</td></tr></table><!-- added to have fixex height -->

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

 fTotalPayableAmt = fTutionFee+fCompLabFee+fMiscFee + fOutstanding  - fEnrollmentDiscount;
 //float fAmtPaidDurEnrl = Float.parseFloat((String)vRetResult[1].elementAt(5));
 //float fFirstInstalAmt = 0f;
 //int iEnrlSetting      = FA.getEnrollemntInstallmentSetting();
 //int iInstalCount      = FA.getNoOfInstallment(dbOP,(String)vORInfo.elementAt(23),
 //s							(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
	vInstallmentDtls = FA.getInstallmentPayablePerStudent(dbOP,(String)vStudInfo.elementAt(0),
							(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
							(String)vORInfo.elementAt(22)) ;//System.out.println(vInstallmentDtls);
	if(vInstallmentDtls == null)
		strErrMsg = FA.getErrMsg();
 	
	int iInstalCount = (vInstallmentDtls.size() - 5)/3;
 
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td width="48%" height="14" valign="top">&nbsp;
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
	    <tr>
          <td height="14" colspan="2" class="thinborderBOTTOM">ASSESSMENT OF FEES</td>
        </tr>
	    <tr>
          <td height="14" width="65%">TUITION FEE<strong><font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%> </font></strong></td>
          <td width="35%"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></font></div></td>
        </tr>
     <%if(fCompLabFee > 0f){%>
       <tr>
          <td height="14">COMP. LAB. FEE</td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></font></div></td>
        </tr>
     <%}if(bolShowMiscDtls) {%>
	    <tr>
          <td height="14">MISCELLANEOUS FEES</td>
          <td height="14" align="right"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></td>
        </tr>
         <%}
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0 || !bolShowMiscDtls)
				continue;
		%>
 		<!--<tr>
          <td height="14">&nbsp;&nbsp;<font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>-->
        <%}%>
		<tr>
		  <td height="14"><font size="1">OTHER CHARGES</font></td>
          <td height="14" align="right"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></td>
        </tr>
         <%
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0 || !bolShowOthChargeDtls)
				continue;
		%>
        <tr>
          <td height="14">&nbsp;&nbsp;<font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
        <tr>
          <td height="14" class="thinborderTOP"><strong>TOTAL ASSESSMENT</strong></td>
          <td height="14" class="thinborderTOP"><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + dFatimaInstallmentFee,true)%></strong></font></div></td>
        </tr>
         <tr>
          <td height="14">REQUIRED DOWNPAYMENT</td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dReqdDP,true)%></font></div></td>
        </tr>
         <tr>
          <td height="14">&nbsp;</td>
          <td height="14"></td>
        </tr>
      </table>

	</td>
    <td width="6%">&nbsp;</td>
    <td width="48%" valign="top">&nbsp;
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td height="14" colspan="2" class="thinborderBOTTOM">PAYMENT DETAILS</td>
        </tr>
        <tr>
          <td height="14">OLD ACCOUNTS/(ADVANCED PAYMENT) </td>
          <td><%=CommonUtil.formatFloatToLedger(fOutstanding)%></td>
        </tr>
        <tr>
          <td height="14" width="54%">PAYMENT MODE </td>
          <td width="46%"><%=(String)vRetResult[0].elementAt(3)%></td>
        </tr>
        <tr>
          <td height="14">AMOUNT PAID</td>
          <td height="14"><%=CommonUtil.formatFloat((String)vRetResult[1].elementAt(5),true)%></td>
        </tr>
        <%if(strEnrolmentDiscDetail != null){%>
        <tr>
          <td height="14" colspan="2"><font size="1">(<%=strEnrolmentDiscDetail%>)</font></td>
        </tr>
        <%}%>
        <tr>
          <td height="14">DATE PAID</td>
          <td height="14"><%=(String)vRetResult[1].elementAt(8)%></td>
        </tr>
        <%if(vRetResult[1].elementAt(4) != null){%>
        <tr>
          <td height="14">PAYMENT TYPE</td>
          <td height="14"><%=(String)vRetResult[1].elementAt(4)%></td>
        </tr>
        <%}if(vRetResult[1].elementAt(6) != null){%>
        <tr>
          <td height="14">CHECK #</td>
          <td height="14"><%=WI.getStrValue(vRetResult[1].elementAt(6))%></td>
        </tr>
        <%}%>
        <tr>
          <td height="14">REFERENCE NUMBER</td>
          <td height="14"><%=(String)vRetResult[1].elementAt(7)%></td>
        </tr>
        <tr>
          <td height="14">RECEIPT ISSUED BY</td>
          <td><%=vORInfo.elementAt(39)%></td>
        </tr>
        <tr>
          <td height="14" colspan="2">&nbsp;</td>
        </tr>
        <tr>
          <td valign="top" colspan="2">
		  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td width="65%" valign="top"><br>
					
					<table width="100%" cellpadding="0" cellspacing="0">
							<%if(vInstallmentDtls != null) 
								for(int i = 5; i < vInstallmentDtls.size(); i += 3) {%>
								<tr>
									<td style="font-size:14px;" width="30%"><%=vInstallmentDtls.elementAt(i)%></td>
								  <td width="70%" style="font-size:14px;"><%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(i + 2), true)%></td>
								</tr>
							<%}%>
					</table>					</td>
					<td>
						<table width="100%" cellpadding="0" cellspacing="0" class="thinborderALL" height="150">
							<tr><td valign="bottom" align="center">NOT VALID WITHOUT<br>A SEAL</td></tr>
						</table>					</td>
				</tr>
				<tr>
				  <td valign="top">&nbsp;</td>
				  <td>&nbsp;</td>
			  </tr>
			</table>		  </td>
        </tr>
      </table>
	</td>
  </tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" class="thinborderALL">
	<tr>
		<td align="center" style="font-weight:bold" height="18" colspan="3"> PERSONAL INFORMATION </td>
	</tr>
	<tr>
		<td width="40%" height="16"> Email Address: <%=WI.getStrValue(vStudInfo.elementAt(31), "&nbsp;")%></td>
		<td width="30%">Landline: <%=WI.getStrValue(vStudInfo.elementAt(38), "&nbsp;")%></td>
		<td width="30%">Mobile No.: <%=WI.getStrValue(vStudInfo.elementAt(25), "&nbsp;")%></td>
	</tr>
	<tr>
	  <td height="16" colspan="3">Permanent Address: <%=WI.getStrValue(vStudInfo.elementAt(26), "&nbsp;")%></td>
  </tr>
	<tr>
	  <td height="16" colspan="3">Baguio Address: <%=WI.getStrValue(vStudInfo.elementAt(39), "&nbsp;")%></td>
  </tr>
	<tr>
	  <td height="16" colspan="3">Name of Guardian in Baguio: <%=WI.getStrValue(vStudInfo.elementAt(37), "&nbsp;")%></td>
  </tr>
	<tr>
	  <td height="16">Gender: <%=WI.getStrValue(vStudInfo.elementAt(13), "&nbsp;")%></td>
	  <td>Civil Status: <%=WI.getStrValue(vStudInfo.elementAt(32), "&nbsp;")%></td>
	  <td>Citizenship: <%=WI.getStrValue(vStudInfo.elementAt(34), "&nbsp;")%></td>
  </tr>
	<tr>
	  <td height="16">Nationality: <%=WI.getStrValue(vStudInfo.elementAt(34), "&nbsp;")%></td>
	  <td>Religious Affiliation: <%=WI.getStrValue(vStudInfo.elementAt(33), "&nbsp;")%></td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="16">Date of Birth: <%=WI.getStrValue(vStudInfo.elementAt(23), "&nbsp;")%></td>
	  <td>Place of Birth: <%=WI.getStrValue(vStudInfo.elementAt(27), "&nbsp;")%></td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="16">Name of Father: <%=WI.getStrValue(vStudInfo.elementAt(28), "&nbsp;")%></td>
	  <td>Occupation: <%=WI.getStrValue(vStudInfo.elementAt(35), "&nbsp;")%></td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="16">Name of Mother: <%=WI.getStrValue(vStudInfo.elementAt(29), "&nbsp;")%></td>
	  <td>Occupation: <%=WI.getStrValue(vStudInfo.elementAt(36), "&nbsp;")%></td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="16" colspan="3">Last School Attended: <%=WI.getStrValue(strLastSchoolAttended)%></td>
	  <!--<td>Term: School Year: </td>-->
  </tr>
	<tr>
	  <td height="16" colspan="">Secondary School: 
	  <table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td>
	  		<%=WI.getStrValue(strSecondarySchName)%></td></tr></table></td>
	  <td><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td>
	  <%=WI.getStrValue(strSecondarySchAddr)%></td></tr></table></td>
	  <td><%=WI.getStrValue(strSecondarySchYear)%></td>
  </tr>
	<tr>
	  <td height="16" align="center">Name of School </td>
	  <td>Address</td>
	  <td>Year</td>
  </tr>
</table>
<br>
<table width="100%" cellpadding="0" cellspacing="0" class="thinborderALL">
	<tr>
		<td style="font-weight:bold" colspan="3"><u>CONFORME:</u></td>
	</tr>
	<tr>
		<td colspan="3">STUDENT'S SIGNATURE: _______________________________</td>
	</tr>
	<tr>
		<td width="45%" height="16">Subjects encoded by: <u><%=strAdviser%></u></td>
		<td width="30%" align="right">Student load verified & confirmed by: </td>
		<td width="25%" class="thinborderBOTTOM">&nbsp;</td>
	</tr>
	<tr>
	  <td height="16">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td align="center">Signature of Authorized Personnel</td>
  </tr>
</table>











<%		}//if payment detail and payment mode not null;
	}//if student information exists.
}//if miscellaneous fee information exists.
dbOP.cleanUP();
%>
</body>
</html>
