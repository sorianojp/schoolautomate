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

</style>
</head>

<body onLoad="window.print();">
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

String strCollegeName = null; 
String strDeanName    = null;

boolean bolIsLastSubj = false;
boolean nextPageBreak = false;
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

		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5), "degree_type"," and is_valid=1 and is_del=0");
		vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
					(String)vORInfo.elementAt(22),"1",strDegreeType);
		if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0)
			strErrMsg = FA.getErrMsg();
			//System.out.println(vAssessedSubDetail); 
			//System.out.println(strErrMsg); 
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

%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr><td height="100px">&nbsp;</td></tr>
    <tr >
      <td height="20" align="right" colspan="2">&nbsp;</td>
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
		<td width="50%" valign="top" height="550">
			<!--------------------------------------- LEFT SIDE ------------------------------------------>
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="20%" height="13">&nbsp;<!--TRANCODE--></td>
					<td width="50%">&nbsp;</td>
					<td>&nbsp; <%=WI.fillTextValue("or_number")%></td>
				</tr>
				<tr>
					<td height="13">&nbsp;<!--STUDENT NO--></td>
					<td><%=(String)vORInfo.elementAt(25)%> <%=(String)vStudInfo.elementAt(1)%></td>
					<td>&nbsp; <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%></td>
				</tr>
				<tr>
					<td height="13">&nbsp;<!--COURSE/CURR--></td>
					<td><%=(String)vStudInfo.elementAt(16)%> <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%></td>
					<td>&nbsp; <%=WI.getTodaysDate(1)%></td>
				</tr>
				<tr>
					<td height="13">&nbsp;<!--DEPARMENT CODE--></td>
					<td><%=(String)vStudInfo.elementAt(19)%></td>
					<td>&nbsp; <%=WI.formatDateTime(dateTime.getTime(),3)%></td>
				</tr>
				<tr>
					<td height="13">&nbsp;<!--FEE CODE--></td>
					<td>&nbsp;</td>
					<td>&nbsp; <%=(String)request.getSession(false).getAttribute("userId")%></td>
				</tr>
			</table>
			
			
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="">
  <tr >
  	<td width="10%" height="70" class=""><strong>&nbsp;<!--SUBJECT CODE--> </strong></td>
    <td width="15%" height="18" class=""><strong>&nbsp;<!--SUBJECT CODE--> </strong></td>
    <td width="20%" height="19" class=""><strong>&nbsp;<!--SUBJECT TITLE--> </strong></td>	
	<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")){%>
    <td width="5%" class=""><strong>&nbsp;<!--LEC/LAB UNITS --></strong></td>
    <%}%>
	
    <td width="20%" class=""><strong>&nbsp;<!--SCHEDULE--></strong></td>
    <td width="15%" class=""><strong>&nbsp;<!--ROOM #--></strong></td>
    
	<!--<td width="15%" class="thinborder"><strong>&nbsp;<!--TOTAL SUBJECT FEE</strong></td>-->
  </tr>
  <%//System.out.println(vAssessedSubDetail);
 	//float fFirstInstalAmt = 0f;
	float fTotalLoad = 0;float fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	float fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.
	String strSchedule = null;
	String strRoomAndSection = null;
	String strSection = null;
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
				strSection = (String)vSubSecDtls.elementAt(b);
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
  	<td height="19" class=""><%=strSection%></td>
    <td height="19" class=""><%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
    <td class=""><%=(String)vAssessedSubDetail.elementAt(i+1)%><!--<%=(String)vAssessedSubDetail.elementAt(i+2)%>--></td>
	<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")) {%>
    <td class="" align="center"><%=(String)vAssessedSubDetail.elementAt(i+9)%> <!--<%=(String)vAssessedSubDetail.elementAt(i+3)%>/<%=(String)vAssessedSubDetail.elementAt(i+4)%>--></td>
    <%}%>
    <td class=""><%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class=""><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
    
	
	<!-----------------------THIS IS FOR YT
	<td class="thinborder" align="right"><%=strSubTotalRate%></td>
				------------------------------------>
	
	
  </tr>
	<% i = i+9;
		strRoomAndSection = null;
		strSchedule = null;
		
				//this will determine if it stop printing the subject		
				if(i==vAssessedSubDetail.size()-1)
					bolIsLastSubj = true;
	}%>
	
	<%if(bolIsLastSubj){%>
	<tr >	
  		<td align="center" colspan="6" valign="top" style="border-bottom: solid 1px #000000;">***NOTHING FOLLOWS***</td>    		  
  	</tr>
	<%}%>
		
	<tr >	
  		<td align="left" colspan="2" valign="top"> <strong>Total Units Taken : <%=fUnitsTaken%></strong>&nbsp;&nbsp;</td>  
		
		<%				
			strTemp = (String)vStudInfo.elementAt(15);
			if(strTemp != null) {
				if(vStudInfo.elementAt(30).equals("1"))
					strTemp = "RETURNEE";
				else if(strTemp.startsWith("N"))
					strTemp = "NEW STUDENT";
			}
		%>  	
		<td align="left" colspan="2">Stat: <%=strTemp%></td>			
		<td colspan="2">Year: <%=(String)vStudInfo.elementAt(4)%></td>	
		  
  	</tr> 
  
  <tr><td colspan="6" align="right">Date and time printed: <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;&nbsp;</td></tr>  
  
</table>		

	
		</td>
		
		
		
		
		
		<!----------------------RIGHT SIDE--------------------------------->
		
		<td width="50%" valign="top" height="550">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="30%" height="13">&nbsp;<!--TRANCODE--></td>
					<td width="50%">&nbsp;</td>
					<td>&nbsp; <%=WI.fillTextValue("or_number")%></td>
				</tr>
				<tr>
					<td height="13">&nbsp;<!--STUDENT NO--></td>
					<td><%=(String)vORInfo.elementAt(25)%></td>
					<td>&nbsp; <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%></td>
				</tr>
				<tr>
					<td height="13">&nbsp;<!--COURSE/CURR--></td>
					<td><%=(String)vStudInfo.elementAt(16)%> <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%></td>
					<td>&nbsp; <%=WI.getTodaysDate(1)%></td>
				</tr>
				<tr>
					<td height="13">&nbsp;<!--DEPARMENT CODE--></td>
					<td><%=(String)vStudInfo.elementAt(19)%></td>
					<td>&nbsp; <%=WI.formatDateTime(dateTime.getTime(),3)%></td>
				</tr>
				<tr>
					<td height="13">&nbsp;<!--FEE CODE--></td>
					<td>&nbsp;</td>
					<td>&nbsp; <%=(String)request.getSession(false).getAttribute("userId")%></td>
				</tr>
			</table>
			
			
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="">
  <tr >
  	<td width="10%" height="70" class=""><strong>&nbsp;<!--SUBJECT CODE--> </strong></td>
    <td width="15%" height="18" class=""><strong>&nbsp;<!--SUBJECT CODE--> </strong></td>
    <td width="20%" height="19" class=""><strong>&nbsp;<!--SUBJECT TITLE--> </strong></td>
	<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")){%>
    <td width="5%" class=""><strong>&nbsp;<!--LEC/LAB UNITS --></strong></td>
    <%}%>
	
    <td width="20%" class=""><strong>&nbsp;<!--SCHEDULE--></strong></td>
    <td width="15%" class=""><strong>&nbsp;<!--ROOM #--></strong></td>
    
	<!--<td width="15%" class="thinborder"><strong>&nbsp;<!--TOTAL SUBJECT FEE</strong></td>-->
  </tr>
  <%//System.out.println(vAssessedSubDetail);
 	//float fFirstInstalAmt = 0f;
	 fTotalLoad = 0; fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	 fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.
 strSchedule = null;
 strRoomAndSection = null;
 strLecLabStat = null;//0 = both,1 = lab, 2 = lec.
	 strRatePerUnit = null; strAssessedHour = null;//only if it is UI and the assessment is per hour.
	 vSubSecDtls = new Vector();
	 strFeeTypeCatg = null; //0=>per unit,1= per lec/lab, 2=per subject,3=total tuition fee.

	iIndex = 0;
	 strSubTotalRate = null;//System.out.println(fOperation.vTuitionFeeDtls);
	
	pstmtGetLecLabStat = null;
	strTemp = "select IS_ONLY_LAB from enrl_final_cur_list where sub_sec_index=? and enrl_final_cur_list.is_valid = 1 and "+
				"user_index = "+(String)vStudInfo.elementAt(0)+" and IS_TEMP_STUD = "+paymentUtil.isTempStudInStr();
	pstmtGetLecLabStat = dbOP.getPreparedStatement(strTemp);

	
	
	for(int i = 0; i< vAssessedSubDetail.size() ; ++i)
	{
		//System.out.println(" vAssessedSubDetail "+vAssessedSubDetail);
		//System.out.println(" vRetResult "+vRetResult);
		if(strFeeTypeCatg == null)	
			strFeeTypeCatg = (String)vAssessedSubDetail.elementAt(8);

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
  	<td height="19" class=""><%=strSection%><!--<%=strSubSecIndex%>--></td>
    <td height="19" class=""><%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
    <td class=""><%=(String)vAssessedSubDetail.elementAt(i+1)%><!--<%=(String)vAssessedSubDetail.elementAt(i+2)%>--></td>
	<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")) {%>
    <td class="" align="center"><%=(String)vAssessedSubDetail.elementAt(i+9)%> <!--<%=(String)vAssessedSubDetail.elementAt(i+3)%>/<%=(String)vAssessedSubDetail.elementAt(i+4)%>--></td>
    <%}%>
    <td class=""><%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class=""><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
    
	
	<!-----------------------THIS IS FOR YT
	<td class="thinborder" align="right"><%=strSubTotalRate%></td>
				------------------------------------>
	
	
  </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
	
		//this will determine if it stop printing the subject
		if(i==vAssessedSubDetail.size()-1)
			bolIsLastSubj = true;
}%>
	<%if(bolIsLastSubj){%>
	<tr >	
  		<td align="center" colspan="6" valign="top" style="border-bottom: solid 1px #000000;">***NOTHING FOLLOWS***</td>    		  
  	</tr>
	<%}%>
		
	<tr >	
  		<td align="left" colspan="2" valign="top"> <strong>Total Units Taken : <%=fUnitsTaken%></strong>&nbsp;&nbsp;</td>  
		
		<%				
			strTemp = (String)vStudInfo.elementAt(15);
			if(strTemp != null) {
				if(vStudInfo.elementAt(30).equals("1"))
					strTemp = "RETURNEE";
				else if(strTemp.startsWith("N"))
					strTemp = "NEW STUDENT";
			}
		%>  	
		<td align="left" colspan="2">Stat: <%=strTemp%></td>			
		<td colspan="2">Year: <%=(String)vStudInfo.elementAt(4)%></td>	
		  
  	</tr> 
  
  <tr><td colspan="6" align="right">Date and time printed: <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;&nbsp;</td></tr>  
</table>
		
		
		</td>
	</tr>
</table>

<!-----------------------------------END FIRST PAGE------------------------------------------------------------->





























<!-----------------------------------------------------------SECOND PAGE-------------------------------------------------------------------------->
	
<%for(int iLoop=0;iLoop<2;iLoop++){%>
		

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	
	<tr>
		<td width="58%" valign="top" height="470">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr><td height="90px" colspan="2">&nbsp;</td></tr>    			
				<tr>
					<td width="15%" height="13">&nbsp;<!--TRANCODE--></td>
					<td width="55%">&nbsp;</td>
					<td>&nbsp; <%=WI.fillTextValue("or_number")%></td>
				</tr>
				<tr>
					<td height="13">&nbsp;<!--STUDENT NO--></td>
					<td><%=(String)vORInfo.elementAt(25)%></td>
					<td>&nbsp; <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%></td>
				</tr>
				<tr>
				
					<td height="13">&nbsp;<!--COURSE/CURR--></td>
					<td><%=(String)vStudInfo.elementAt(16)%> <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%></td>
					<td>&nbsp; <%=WI.getTodaysDate(1)%></td>
				</tr>
				<tr>
					<td height="13">&nbsp;<!--DEPARMENT CODE--></td>
					<td><%=(String)vStudInfo.elementAt(19)%></td>
					<td>&nbsp; <%=WI.formatDateTime(dateTime.getTime(),3)%></td>
				</tr>
				<tr>
					<td height="13">&nbsp;<!--FEE CODE--></td>
					<td>&nbsp;</td>
					<td>&nbsp; <%=(String)request.getSession(false).getAttribute("userId")%></td>
				</tr>
			</table>
			
			
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="">
  <tr >
  	<td width="10%" height="50" class=""><strong>&nbsp;<!--SUBJECT CODE--> </strong></td>
    <td width="15%" height="18" class=""><strong>&nbsp;<!--SUBJECT CODE--> </strong></td>
    <td width="20%" height="19" class=""><strong>&nbsp;<!--SUBJECT TITLE--> </strong></td>
	<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")){%>
    <td width="5%" class=""><strong>&nbsp;<!--LEC/LAB UNITS --></strong></td>
    <%}%>
	
    <td width="20%" class=""><strong>&nbsp;<!--SCHEDULE--></strong></td>
    <td width="15%" class=""><strong>&nbsp;<!--ROOM #--></strong></td>
    
	<!--<td width="15%" class="thinborder"><strong>&nbsp;<!--TOTAL SUBJECT FEE</strong></td>-->
  </tr>
  <%//System.out.println(vAssessedSubDetail);
 	//float fFirstInstalAmt = 0f;
	fTotalLoad = 0;fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.
	strSchedule = null;
	strRoomAndSection = null;
	strLecLabStat = null;//0 = both,1 = lab, 2 = lec.
	strRatePerUnit = null;
	strAssessedHour = null;//only if it is UI and the assessment is per hour.
	vSubSecDtls = new Vector();
	strFeeTypeCatg = null; //0=>per unit,1= per lec/lab, 2=per subject,3=total tuition fee.

	iIndex = 0;
	strSubTotalRate = null;//System.out.println(fOperation.vTuitionFeeDtls);
	
	pstmtGetLecLabStat = null;
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
  	<td height="19" class=""><%=strSection%><!--<%=strSubSecIndex%>--></td>
    <td height="19" class=""><%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
    <td class=""><%=(String)vAssessedSubDetail.elementAt(i+1)%><!--<%=(String)vAssessedSubDetail.elementAt(i+2)%>--></td>
	<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")) {%>
    <td class="" align="center"><%=(String)vAssessedSubDetail.elementAt(i+9)%> <!--<%=(String)vAssessedSubDetail.elementAt(i+3)%>/<%=(String)vAssessedSubDetail.elementAt(i+4)%>--></td>
    <%}%>
    <td class=""><%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class=""><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
    
	
	<!-----------------------THIS IS FOR YT
	<td class="thinborder" align="right"><%=strSubTotalRate%></td>
				------------------------------------>
	
	
  </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;

	//this will determine if it stop printing the subject
	//bolIsPageBreak = true;
		if(i==vAssessedSubDetail.size()-1)		
				bolIsLastSubj = true;
}%>	

	<%if(bolIsLastSubj){%>
	<tr >	
  		<td align="center" colspan="6" valign="top" style="border-bottom: solid 1px #000000;">***NOTHING FOLLOWS***</td>    		  
  	</tr>
	<%}%>
		
	<tr >	
  		<td align="left" colspan="2" valign="top"> <strong>Total Units Taken : <%=fUnitsTaken%></strong>&nbsp;&nbsp;</td>  
		
		<%				
			strTemp = (String)vStudInfo.elementAt(15);
			if(strTemp != null) {
				if(vStudInfo.elementAt(30).equals("1"))
					strTemp = "RETURNEE";
				else if(strTemp.startsWith("N"))
					strTemp = "NEW STUDENT";
			}
		%>  	
		<td align="left" colspan="2">Stat: <%=strTemp%></td>			
		<td colspan="2">Year: <%=(String)vStudInfo.elementAt(4)%></td>	
		  
  	</tr> 
  <tr><td colspan="6" align="right">Date and time printed: <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;&nbsp;</td></tr>   
</table>			


	
			
		</td>
		<!----------------------RIGHT SIDE--------------------------------->
		
		<td width="42%" valign="top" height="470">
		
		<%
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
		%>
		
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
       
	    <tr>
          <td width="65%" height="14" colspan="2">&nbsp;</td>          
        </tr>
       
	    <tr>
          <td height="14">TUITION FEE<strong><font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%> </font></strong></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></font></div></td>
        </tr>
     <%if(fCompLabFee > 0f){%>
       <tr>
          <td height="14">COMP. LAB. FEE</td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></font></div></td>
        </tr>
     <%}if(bolShowMiscDtls) {%>
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
		
		
		 <%if(!strSchoolCode.startsWith("UL")){
 			double dAddToInstallationFee = 0d;
 			if(bolIsFatima && dFatimaInstallmentFee > 0d) {
 			int iNoOfInstallment = 0;
			if(vInstallmentDtls != null && vInstallmentDtls.size() > 0) 
					iNoOfInstallment = (vInstallmentDtls.size() - 5)/3;
 			dAddToInstallationFee = dFatimaInstallmentFee/iNoOfInstallment;
 			}
 
 			%>
			
		<tr>
          <td height="14"><strong>AMOUNT PAID: <%=CommonUtil.formatFloat((String)vRetResult[1].elementAt(5),true)%></strong></td>
        </tr>
       	<tr>
          <td height="14" colspan="2"><b><%=((String)vInstallmentDtls.elementAt(5)).toUpperCase()%> DUE
		  	<%if(bolShowExamDate){%>(<%=vInstallmentDtls.elementAt(6)%>)<%}%>: 
		  	<%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(7)) + dAddToInstallationFee,true)%></b> 
		  </td>
        </tr>
        <tr>
          <td height="14" colspan="2"><strong>
		  	<%
			if(vInstallmentDtls != null && vInstallmentDtls.size() > 5 + 3*1) //prelim
				{%> <%=((String)vInstallmentDtls.elementAt(5+3*1)).toUpperCase()%> DUE 
			<%if(bolShowExamDate){%>(<%=vInstallmentDtls.elementAt(5+3*1 + 1)%>)<%}%>: 
			<%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+3*1 +2)) + dAddToInstallationFee,true)%> <%}%> 
			</strong> 
		  </td>
        </tr>
        <%if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*2) {//midterm%>
        <tr>
          	<td height="14" colspan="2"><strong> <%=((String)vInstallmentDtls.elementAt(5+ 3*2)).toUpperCase()%> DUE 
		  		<%if(bolShowExamDate){%>(<%=vInstallmentDtls.elementAt(5+3*2 + 1)%>)<%}%>: 
		  		<%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+ 3*2+2)) + dAddToInstallationFee,true)%> </strong> 
			</td>
        </tr>
        <%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*3) {//prelim%>
        <tr>
          	<td height="14" colspan="2"><strong> <%=((String)vInstallmentDtls.elementAt(5+ 3*3)).toUpperCase()%> DUE 
		  		<%if(bolShowExamDate){%>(<%=vInstallmentDtls.elementAt(5+3*3 + 1)%>)<%}%>: 
				<%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+ 3*3+2)) + dAddToInstallationFee,true)%> </strong> 
			</td>
        </tr>
        <%}%>
<%}//for UL have to show differently.%>	

      </table>
		
		</td>
		
		<!----------------------------END OF RIGHT SIDE--------------------------------------------->
	</tr>
</table>

	
<%}//end of for loop%>







<!------------------------------------------------------------------END OF SECOND PAGE---------------------------------------------------------------------------------------->














<!-----------------------------------------OLD RECORD LAYOUT----------------------------------------------------->
<!--
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
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
<!--
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
     <%}if(bolShowMiscDtls) {%>
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
<%if(strSchoolCode.startsWith("WNU")){
String strSQLQuery = "select NSTP_PMT_WNU from fa_stud_payment where or_number = '"+(String)vRetResult[1].elementAt(7)+"'";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && !strSQLQuery.equals("0.0") ) {%>
        <tr>
          <td height="14" style="font-weight:bold; font-size:11px;"><u>NOTE : NSTP Fee Paid : <%=CommonUtil.formatFloat(strSQLQuery, true)%></u></td>
          <td height="14"><div align="right"></div></td>
        </tr>
<%}//show only if NSTP fee paid.. 

}%>
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
        
<%
if(!strSchoolCode.startsWith("WNU") && !strSchoolCode.startsWith("UL")){%>

<%if(!strSchoolCode.startsWith("UDMC") && !strSchoolCode.startsWith("CGH")){%>
        <tr>
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
<%}if(!strSchoolCode.startsWith("CSA") && !bolIsFatima){%>

        <tr>
          <td height="14" colspan="2">(Business Office) Receipt printed by:<u>&nbsp;<%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%>&nbsp;&nbsp;</u> </td>
        </tr>

<%}%>
        <tr>
          <td height="14" colspan="2">
		  <%if(bolIsFatima) {//check here if there is any plan taken by student.. 
		  	String strPlanInfo = "select PLAN_NAME from FA_STUD_MIN_REQ_DP_PER_STUD "+
								"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.plan_ref = FA_STUD_MIN_REQ_DP_PER_STUD.plan_ref) "+
								" where is_temp_stud = 0 and stud_index = "+vORInfo.elementAt(0)+
								" and sy_from = "+astrSchYrInfo[0]+" and semester = "+astrSchYrInfo[2];
			strPlanInfo = dbOP.getResultOfAQuery(strPlanInfo, 0);
		  	if(strPlanInfo != null){%>
		  		<font size="2" style="font-weight:bold"><u>Plan Subscribed: <%=strPlanInfo.toUpperCase()%></u></font>
		  <%}}%>
		  </td>
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
 
 %>
       <tr>
          <td height="14" colspan="2"><font size="2"><b><%=((String)vInstallmentDtls.elementAt(5)).toUpperCase()%> DUE
		  <%if(bolShowExamDate){%>(<%=vInstallmentDtls.elementAt(6)%>)
		  <%}%>
		  : <%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(7)) + dAddToInstallationFee,true)%></b></font> </td>
        </tr>
        <tr>
          <td height="14" colspan="2"> <%
if(vInstallmentDtls != null && vInstallmentDtls.size() > 5 + 3*1) //prelim
{%> <%=((String)vInstallmentDtls.elementAt(5+3*1)).toUpperCase()%> DUE <%if(bolShowExamDate){%>(<%=vInstallmentDtls.elementAt(5+3*1 + 1)%>)<%}%>: <%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+3*1 +2)) + dAddToInstallationFee,true)%> <%}%> </td>
        </tr>
        <%if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*2) {//midterm%>
        <tr>
          <td height="14" colspan="2"><%=((String)vInstallmentDtls.elementAt(5+ 3*2)).toUpperCase()%> DUE <%if(bolShowExamDate){%>(<%=vInstallmentDtls.elementAt(5+3*2 + 1)%>)<%}%>: <%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+ 3*2+2)) + dAddToInstallationFee,true)%> </td>
        </tr>
        <%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*3) {//prelim%>
        <tr>
          <td height="14" colspan="2"><%=((String)vInstallmentDtls.elementAt(5+ 3*3)).toUpperCase()%> DUE <%if(bolShowExamDate){%>(<%=vInstallmentDtls.elementAt(5+3*3 + 1)%>)<%}%>: <%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+ 3*3+2)) + dAddToInstallationFee,true)%> </td>
        </tr>
        <%}%>
<%}//for UL have to show differently. 

if(strSchoolCode.startsWith("UL")){%>
       <tr>
	   
	   		<td colspan="2">
				<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
					<tr style="font-weight:bold">
						<td width="36%" class="thinborder">Exam Period</td>
						<td width="20%" class="thinborder">Amount</td>
						<td width="25%" class="thinborder">OR #</td>
						<td width="19%" class="thinborder">Permit #</td>
					</tr>
					<%for(int i =5; i < vInstallmentDtls.size(); i += 3){%>
						<tr style="font-weight:bold">
							<td class="thinborder"><%=((String)vInstallmentDtls.elementAt(i)).toUpperCase()%></td>
							<td class="thinborder"><%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(i+2),true)%></td>
							<td class="thinborder">&nbsp;</td>
							<td class="thinborder">&nbsp;</td>
						</tr>
					<%}%>
				</table>			</td>
        </tr>

<%}%>
       <tr>
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
<!--
<%if(!bolIsFatima){%>
        <tr>
          <td height="14" colspan="2">
<%if(strSchoolCode.startsWith("CSA")){%>
			NOTE: Assessment is subject to adjustment/s.
<%}else{%>
		  	(NOTE: Above installment schedule may change based on actual payment and after enrolment adjustments.)
<%}%>		  </td>
        </tr>
<%}%>
------------------------------------------------>
<%if(strSchoolCode.startsWith("CGH")){%>
        <tr>
          <td height="14" colspan="2">&nbsp;</td>
        </tr>
        <tr>
          <td height="14" colspan="2" style="border-top:solid 1px #000000;border-bottom:solid 1px #000000;border-left:solid 1px #000000;border-right:solid 1px #000000;">
		  	<table width="95%" align="center"><tr>
		  	  <td style="font-size:10px; font"><div align="justify">
			  This is to recognize without reservation, the authority of the College to bar or not to allow the student entrance to the school campus nor attendance to  his/her classes in case of failure to pay installments due for midterm/final period and demandable tuition and other school fees as indicated in the current schedule of payment and that he/she shall only be readmitted as soon as the tuition and other school fees are paid; Provided however, that the student will be solely responsible in keeping up with the lessons, assignments, examinations etc. given during the school days he/she was not allowed to enter and attend classes.
				<br>
				<br>
		  	  A student who is allowed to withdraw shall be charged corresponding administrative fees: P2,000 before the start of class; 25% of total school fees within first week after start of classes; 50% within second week; 100% after the second week of class. Reservation/Registration fees are non-refundable.
		  	    </div></td>
	  	  </tr></table>		  </td></tr>
<%}%>		  
<%if(strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("DBTC") || strSchoolCode.startsWith("PIT")){%>
        <tr>
          <td height="14" colspan="2">&nbsp;</td>
        </tr>
        <tr>
          <td height="14" colspan="2" style="border-top:solid 1px #000000;border-bottom:solid 1px #000000;border-left:solid 1px #000000;border-right:solid 1px #000000;">
		  	<table width="95%" align="center"><tr>
		  	  <td colspan="2" style="font-size:10px; font"><strong><font size="2">IMPORTANT!!!</font></strong>
			  <br>
			  <%if(strSchoolCode.startsWith("DBTC")){%>
				  <i>CHARGES IN CASE OF WITHDRAWAL OF ENROLMENT</i>
				  <br><br>
				  1. Withdrawal within enrolment period after the 2nd week of classes: 50% of the total charges will be charged.
				  <br>
				  2. Withdrawal within enrolment period after the 4th week of classes: total charges will be charged.
				  <br>
				  3. Changing, adding or withdrawing a subject must be properly done by accomplishing the forms and must be signed by the signatories required to make them official and valid.
				  <br>
				  4. If a student attends a subject in which he/she has not been officially enroled, he/she will not receive a rating or credit for that particular subject.
				  <br>
			  <%}else{%>
				  <i>CHARGES IN CASE OF WITHDRAWAL OF ENROLLMENT</i>
				  <br><br>
				  1. Withdrawal within the enrollment period up to the 1st week of classes: 10% of the total charges will be charged
				  <br>
				  2. Withdrawal within 2nd week of classes: 20% of the total charges will be charged
				  <br>
				  3. Withdrawal After 2nd week of classes: Total charges will be charged(no adjustment)
				  <br>
				  4. Withdrawal of enrollment for students who are not officially enrolled will be charged P200.00
				  <br>
				  5. Dropping one of two subjects (but not complete withdrawal from the course) fifteen(15) days after the official start date of classes should not carry a refund or adjustment of fees.
			  <%}%>
			  <br>
			  <%if(!strSchoolCode.startsWith("PIT")){%>
			  <br>NO WITHDRAWAL ADJUSTMENTS DURING SUMMER<br> 
			  <%}%>
			  __________________________________________________
			  <br><br>
			  This is to certify that the student whose name appears on this document is officially enrolled this term in the class listed above.			  </td>
		  	</tr>
		  	  <tr align="center">
		  	    <td style="font-size:10px; font">&nbsp;</td>
		  	    <td width="36%" rowspan="3" valign="bottom" align="center">
				<%if(strSchoolCode.startsWith("WNU")){%>
						<img src="./wnu_registrar_signature.jpg">
				<%}else{
				strTemp = CommonUtil.getNameForAMemberType(dbOP,"university registrar",7);
				if(strTemp == null)
					strTemp = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
				else	
					strTemp = strTemp.toUpperCase();
				%>
				<strong>
					<u><%=strTemp%></u><br>
					Registrar				</strong>
				<%}%>				</td>
	  	      </tr>
		  	  <tr align="center" valign="bottom">
		  	    <td width="64%" style="font-size:10px;"><u><%=((String)vStudInfo.elementAt(1)).toUpperCase()%></u></td>
  	          </tr>
		  	  <tr align="center" style="font-weight:bold">
		  	    <td style="font-size:10px; font">Student's Signature </td>
	  	      </tr>
	  	  </table>		  </td></tr>
<%}%>		  
<%if(strSchoolCode.startsWith("CSA") && false){%>
        <tr>
          <td height="14" colspan="2">&nbsp;</td>
        </tr>
        <tr>
          <td height="14" colspan="2" style="border-top:solid 1px #000000;border-bottom:solid 1px #000000;border-left:solid 1px #000000;border-right:solid 1px #000000;">
		  	<table width="95%" align="center"><tr>
		  	  <td colspan="2" style="font-size:11px; font"><strong><font size="2">STUDENT'S CONTRACT</font></strong>
			  <br>
				  <i>
				  	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					I hereby promise to abide by the rules and regulations of COLEGIO SAN AGUSTIN- BACOLOD particularly in fees, refunds, 
					and terms of payment including policies covering scholastic performance and disciplinary behavior of students.
					<br><br>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				  I further certify that I passed the prerequisites required for the foregoing subjects that I enrolled this school term.				  </i>			  </td>
		  	</tr>
		  	  <tr>
		  	    <td width="57%" align="center" style="font-size:8px;" height="45" valign="bottom"><strong>
					<u><%=((String)vStudInfo.elementAt(1)).toUpperCase()%></u><br>
				  			Student's Signature</strong>				</td>
	  	        <td width="43%" align="center" style="font-size:8px;" valign="bottom"><strong>
<%
				strTemp = CommonUtil.getNameForAMemberType(dbOP,"university registrar",7);
				if(strTemp == null)
					strTemp = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
				else	
					strTemp = strTemp.toUpperCase();
%>
					<u><%=strTemp%></u><br>
				  			Registrar</strong>				  </td>
		  	  </tr>
	  	  </table>		  </td></tr>
<%}
if(strSchoolCode.startsWith("UL")){%>
        <tr>
	   		<td colspan="2">
				<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
					<tr style="font-weight:bold">
						<td colspan="3" align="center" class="thinborder">OLD ACCOUNTS</td>
					</tr>
					<tr style="font-weight:bold" align="center">
						<td width="28%" class="thinborder">&nbsp;</td>
						<td width="37%" class="thinborder">Amount</td>
						<td width="35%" class="thinborder">OR#</td>
					</tr>
					<tr style="font-weight:bold" align="center">
						<td class="thinborder">1st</td>
						<td class="thinborder">&nbsp;</td>
						<td class="thinborder">&nbsp;</td>
					</tr>
					<tr style="font-weight:bold" align="center">
					  <td class="thinborder">2nd</td>
					  <td class="thinborder">&nbsp;</td>
					  <td class="thinborder">&nbsp;</td>
				  </tr>
					<tr style="font-weight:bold" align="center">
					  <td class="thinborder">3rd</td>
					  <td class="thinborder">&nbsp;</td>
					  <td class="thinborder">&nbsp;</td>
				  </tr>
					<tr style="font-weight:bold" align="center">
					  <td class="thinborder">4th</td>
					  <td class="thinborder">&nbsp;</td>
					  <td class="thinborder">&nbsp;</td>
				  </tr>
				</table>			</td>
        </tr>
       <tr>
          <td height="14" colspan="2">&nbsp;</td>
        </tr>
        <tr>
          <td height="14" colspan="2" style="border-top:solid 1px #000000;border-bottom:solid 1px #000000;border-left:solid 1px #000000;border-right:solid 1px #000000;">
		  	<table width="95%" align="center"><tr>
		  	  <td colspan="2" style="font-size:10px; font"><strong><font size="2">IMPORTANT!!!</font></strong>
			  <br>
				  <i>CHARGES IN CASE OF WITHDRAWAL OF ENROLMENT</i>
				  <br><br>
				  1. Withdrawal within enrolment period: 5% of the total charges will be charged.
				  <br>
				  2. Withdrawal within 1st week of classes: 25% of the total charges will be charged.
				  <br>
				  3. Withdrawal within 2nd week of classes: 50% of the total charges will be charged
				  <br>
				  4. Withdrawal after 2nd week of classes: 100% of the total charges will be charged (No Adjustment)
				  <br>
				  5. Dropping one of two subjects (but not complete withdrawal from the course) fifteen(15) days after the official start of date of classes should not carry a refund or adjustment of fees.
			  <br>
			  <br>
			  This is to certify that the student whose name appears on this document is officially enrolled this term in the class listed above.			  </td>
		  	</tr>
		  	  <tr>
		  	    <td width="57%" align="center" style="font-size:8px;" height="45" valign="bottom"><strong>
					<u><%=((String)vStudInfo.elementAt(1)).toUpperCase()%></u><br>
				  			Student's Signature</strong>				</td>
	  	        <td width="43%" align="center" style="font-size:8px;" valign="bottom"><strong>
					<u><%=strDeanName%></u><br>
				  			Dean</strong>				  </td>
		  	  </tr>
	  	  </table>		  </td></tr>

<%}%>

      </table>
	</td>
  </tr>
</table>



<!--
<%if(!strSchoolCode.startsWith("DBTC") && !bolIsFatima){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(strSchoolCode.startsWith("VMUF") && (vStudInfo.elementAt(15) != null && ((String)vStudInfo.elementAt(15)).toLowerCase().startsWith("o"))){%>
  <tr >
    <td height="20" colspan="4" >&nbsp;</td>
  </tr>
  <tr >
    <td width="25%" height="25" valign="bottom" > <div align="left">______________________________</div></td>
    <td width="27%" valign="bottom" > <div align="left">_______________________________</div></td>
    <td width="26%" valign="bottom" > <div align="left">______________________________</div></td>
    <td width="22%" valign="bottom" ><%if(false){%>______________________________<%}%></td>
  </tr>
  <tr >
    <td height="25" valign="top" >&nbsp;&nbsp;&nbsp;
	<%if(vStudInfo.elementAt(15) != null && ((String)vStudInfo.elementAt(15)).toLowerCase().startsWith("o")){%>
	(Office of Student Affairs)
	<%}else{%>(Guidance and Testing Center)<%}%></td>
    <td valign="top" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Clinic)</td>
    <td valign="top" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Library)</td>
    <td valign="top" ><div align="center"><%if(false){%>(Internet)<%}%></div></td>
  </tr>
 <%}else if(strSchoolCode.startsWith("UI")){%>
  <tr >
    <td width="25%" height="10" valign="bottom" ></td>
    <td width="27%" valign="bottom" ></td>
    <td width="26%" valign="bottom" align="right">______</div></td>
    <td width="22%" valign="bottom" >______________________________</td>
  </tr>
  <tr >
    <td height="10" valign="top" ></td>
    <td valign="top" ></td>
    <td valign="top" ></td>
    <td valign="top" ><div align="center">(ICTC)</div></td>
  </tr>
 <%}
 if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("CGH") && !strSchoolCode.startsWith("WNU") 
 	&& !strSchoolCode.startsWith("PIT") && !strSchoolCode.startsWith("UL") && !strSchoolCode.startsWith("CSA")){%>
<!--
 <tr >
    <td height="19" colspan="2" valign="top">Student load verified &amp; confirmed by :</td>
    <td colspan="2" valign="bottom" >&nbsp;</td>
  </tr>
  <tr >
    <td height="10" colspan="2" align="center">___________________________________________________</td>
    <td colspan="2" align="center"><%if(bolIsFatima){%>___________________________________________________<%}%></td> 
  </tr>
  <tr >
    <td height="10" colspan="2" align="center"><em><strong>Registrar</strong></em></td>
    <td colspan="2" align="center"><%if(bolIsFatima) {%><em><strong>Student</strong></em><%}%></td>
  </tr>

<%}%>
</table>

<%}//do not show this block for DBTC%>
-->

<%if(!strSchoolCode.startsWith("UPHSD") && !strSchoolCode.startsWith("FATIMA")){%>
<table width="100%" cellpadding="0" cellspacing="0" class="thinborderALL">
	<tr><td align="center" height="40px"><font size="2"><strong>YOU'RE NOW ENROLLED, WELCOME!</strong></font></td></tr>
</table>
<%}%>

<%if(false && strSchoolCode.startsWith("UDMC") && vStudInfo.elementAt(15) != null &&
	((String)vStudInfo.elementAt(15)).compareTo("New") == 0){%>
<table width="100%" cellpadding="0" cellspacing="0" class="thinborderALL">
  <tr>
    <td height="25" colspan="3" align="center"><font size="2"> <u> <strong>CONTRACT
      OF ENROLMENT </strong> </u> </font> </td>
  </tr>
  <tr>
    <td colspan="3"> &nbsp;&nbsp;&nbsp;&nbsp;I certify the data I have given data
      are true and correct, and that I have read the SACI rules and regulations
      on enrollment, schedules and fess. Furthermore, I herby certify that I have
      passed all the prerequisites to the subjects I am presently enrolling.<br><br>
      &nbsp;&nbsp;&nbsp;&nbsp;I am willing to be enrolled conditionally until
      I submit the record/ to SACI on or before ______________.</td>
  </tr>
  <tr>
    <td width="186"><div align="right"></div></td>
    <td><div align="justify">( ) H.S Report card<br>
        ( ) Birth Certificate<br>
        ( ) TOR </div></td>
    <td width="355">( ) Cert. Of Good moral Char<br>
      ( ) ID photo, 4 pcs.<br>
      ( ) Honorable Dismissal </td>
  </tr>
  <tr>
    <td colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;I agree that my enrollment will be
      cancelled if I have enrolled with false data and questionable credentials
      or if I fail to submit the above records on time.<br>
      <br>
      &nbsp;&nbsp;&nbsp;&nbsp;Upon proper notification by the Dean/Registrar,
      I also agree to be barred from readmission at SACI due to poor grades and
      violation of schools rules and regulations</td>
  </tr>
  <tr>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="24">&nbsp;</td>
    <td width="205">&nbsp;</td>
    <td>___________________<br>
      Student's Signature</td>
  </tr>
</table>

<%}//show only for UDMC.

		}//if payment detail and payment mode not null;
	}//if student information exists.
}//if miscellaneous fee information exists.
dbOP.cleanUP();
%>
</body>
</html>
