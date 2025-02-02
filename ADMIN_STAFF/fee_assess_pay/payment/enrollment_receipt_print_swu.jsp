<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,
	enrollment.FAAssessment,enrollment.SubjectSection,enrollment.EnrlAddDropSubject,java.util.Vector" %>
<%
	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null) {
		%>
		<font style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:#FF0000">
			You are already logged out. Please login again to access this page.
		<%
		return;
	}
	boolean bolIsSEACREST = false;
	
	String strInfo5 = (String)request.getSession(false).getAttribute("info5");
	if(strInfo5 != null && strInfo5.toLowerCase().startsWith("seacrest"))
		bolIsSEACREST = true;
	WebInterface WI = new WebInterface(request);
	
String strFontSize = "10px";	
	
	
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
	font-size: <%=strFontSize%>;
}

td {	
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}
    TABLE.thinborder {	
	border-top:solid 1px #000000;
	border-right:solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }

    TD.thinborder {
	border-bottom:solid 1px #000000;
	border-left:solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TD.thinborderBOTTOM {
	border-bottom:solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
	TD.thinborderTOPBOTTOM {	
	border-bottom:solid 1px #000000;
	border-top:solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }    
	
	.fontSize9{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
	}
-->
</style>
</head>

<body onLoad="window.print();" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
<%
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp = null;
	String strSubSecIndex = null;
	Vector vLabSched      = null;
	String strORNumber    = WI.fillTextValue("or_number");
	java.sql.ResultSet rs = null;
	String strSQLQuery    = null;


	String strDegreeType  = null;

	String[] astrConvertSem = {"SUMMER","FIRST TERM","SECOND TERM","THIRD TERM","FOURTH TERM","FIFTH TERM","SIXTH TERM"};
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

String strCollegeName = null; 
String strDeanName    = null;
//if(strSchoolCode != null && strSchoolCode.startsWith("UDMC"))
//	strSchoolCode = "CGH";

double dReservationFee = 0d;//only for CGH.

double dTotalAmtPaid = 0d;//only tuition.. 


SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
Advising advising = new Advising();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

Vector vAssessedSubDetail = null;
Vector vInstallmentDtls = null;

Vector vDroppedSub = new Vector();///get the sub_sec_indexes..

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
	if(strCollegeName == null)
		strCollegeName = "";
	else{
		if(bolIsSEACREST)
			strCollegeName = "SOUTHWESTERN UNIVERSITY - "+strCollegeName;
	}

	if(false && vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
	if(vMiscFeeInfo == null)
		vMiscFeeInfo = new Vector();
}
if(strErrMsg == null) //collect fee details here.
{
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
	//System.out.println((String)vORInfo.elementAt(4));
	//System.out.println(fTutionFee);
	if(fTutionFee >= 0f)
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
			
		strSQLQuery = "select sum(amount) from fa_stud_payment where payment_for = 0 and is_valid = 1 and user_index = "+(String)vStudInfo.elementAt(0)+
				" and sy_from = "+(String)vORInfo.elementAt(23)+" and semester = "+(String)vORInfo.elementAt(22)+" and is_stud_temp = 0";
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next())
			dTotalAmtPaid = rs.getDouble(1);
		rs.close();

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
	/**
	vInstallmentDtls = FA.getInstallmentPayablePerStudent(dbOP,(String)vStudInfo.elementAt(0),
							(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
							(String)vORInfo.elementAt(22)) ;
	**/
		vInstallmentDtls = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vStudInfo.elementAt(0),
							(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
							(String)vORInfo.elementAt(22));

	if(vInstallmentDtls == null)
		strErrMsg = FA.getErrMsg();
	else {
		strSQLQuery = "select sub_sec_index from enrl_final_cur_list where user_index = "+(String)vStudInfo.elementAt(0)+" and sy_from = "+ (String)vORInfo.elementAt(23)+
								" and current_semester = "+(String)vORInfo.elementAt(22)+" and is_valid = 1 and is_temp_stud = 0 and new_added_dropped = 2";
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next())
			vDroppedSub.addElement(rs.getString(1));
		rs.close();
	}


}
if(fMiscFee <=0.1f) {
	vMiscFeeInfo = new Vector();
	vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");
}


//System.out.println(fOperation.vAssessedHrDetail);
//boolean bolShowMiscDtls = false;
//boolean bolShowOthChargeDtls = false;
//boolean bolShowExamDate = false;

//get total max units allowed.
//if(strErrMsg == null) {
//	Vector vOverloadDtls = new enrollment.OverideParameter().getStudentLoadInfo(dbOP, (String)vORInfo.elementAt(25), 
//							(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24), (String)vORInfo.elementAt(22));
//	if(vOverloadDtls  != null)
//		strMaxAllowedLoad = (String)vOverloadDtls.elementAt(5);
//}

String strStartOfClasses = "";
	strTemp = " select specific_date from FA_FEE_ADJ_ENROLLMENT where sy_from = "+(String)vORInfo.elementAt(23)+
	" and semester = "+(String)vORInfo.elementAt(22)+" and adj_parameter = 6 and is_valid = 1 " ;
	rs = dbOP.executeQuery(strTemp);
	if(rs.next())
		strStartOfClasses = WI.formatDate(ConversionTable.convertMMDDYYYY(rs.getDate(1)),6);
	rs.close();

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
//Vector vInputInfo = new Vector();
//vInputInfo.addElement((String)vStudInfo.elementAt(5));//[0] course_index, 
//vInputInfo.addElement((String)vStudInfo.elementAt(6));//[1] major_index, 
//vInputInfo.addElement((String)vORInfo.elementAt(23));//[2] sy_from, 
//vInputInfo.addElement((String)vORInfo.elementAt(22));//[3] semester, 
//vInputInfo.addElement((String)vORInfo.elementAt(4));//[4] yr_level,\

//get here lab fee charges.
//FA.getLabFee(dbOP, vInputInfo);
//
//Vector vDryLabSubject = new Vector();
//
//String strSQLQuery = "select distinct sub_code from fa_tution_fee join subject on (subject.sub_index = fa_tution_fee.sub_index) "+
//						"where is_valid = 1 and sy_index = (select sy_index from fa_schyr where sy_from = "+(String)vORInfo.elementAt(23)+")";
//rs = dbOP.executeQuery(strSQLQuery);
//while(rs.next())
//  vDryLabSubject.addElement(rs.getString(1));//[0] sub_code. of dry labs..
//rs.close();


if(vStudInfo != null && vStudInfo.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td valign="top" width="70%">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">				
				<tr><td height="16"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></td></tr>
				<tr><td height="16">College: <%=strCollegeName.toUpperCase()%></td></tr>
				<tr><td height="16">Course: <%=((String)vStudInfo.elementAt(2)).toUpperCase()%> 
				<%=WI.getStrValue((String)vStudInfo.elementAt(3), " major in", "","")%><%=WI.getStrValue((String)vStudInfo.elementAt(4), " - ", "","")%> </td></tr>
				<tr><td height="16">Student No./Name: <strong><%=(String)vORInfo.elementAt(25)%> <%=(String)vStudInfo.elementAt(1)%></strong></td></tr>
			</table>		
		</td>
		<td valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr><td height="5"></td></tr>
				<tr><td align="right" height="14">Student Study Load</td></tr>
				<%
				if(Integer.parseInt(astrSchYrInfo[2]) == 0)
					strTemp = astrSchYrInfo[1];
				else
					strTemp = astrSchYrInfo[0]+"-"+astrSchYrInfo[1];
				%>
				<tr><td align="right" height="16"><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%> <%=strTemp%></td></tr>
				<tr><td align="right"><font style="font-size:8px;">Date & Time Printed: <%=WI.getTodaysDateTime()%></font></td></tr>
			</table>
		</td>
	</tr>	
</table>
<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0) {%>
	
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
	<td width="13%" height="16" align="center" class="thinborderTOPBOTTOM">Instructor</td>
	<td width="10%" align="center" class="thinborderTOPBOTTOM">Class Code</td>
	<td width="11%" align="center" class="thinborderTOPBOTTOM">Subject Name</td>
	<td width="33%" align="center" class="thinborderTOPBOTTOM">Descriptive Title</td>
	<td width="4%" align="" class="thinborderTOPBOTTOM">Units</td>
	<td width="23%" align="center" class="thinborderTOPBOTTOM">Days & Time</td>
	<td width="6%" align="" class="thinborderTOPBOTTOM">Room #</td>
</tr>
				  
	  <%//System.out.println(vAssessedSubDetail);
		float fFirstInstalAmt = 0f; int iCount = 0;
		float fTotalLoad = 0;float fUnitsTaken = 0f;
	//	float fTotalSubFee = 0;
		float fTotalUnit = 0;
	//	float fSubTotalRate = 0 ; //unit * rate per unit.
		String strSchedule = null;
		String strRoomAndSection = null; 
		String strSection = null;
		String strLecLabStat = null;//0 = both,1 = lab, 2 = lec.
		String strRatePerUnit = null;
		String strAssessedHour = null;//only if it is UI and the assessment is per hour.
		Vector vSubSecDtls = new Vector();
		String strFeeTypeCatg = null; //0=>per unit,1= per lec/lab, 2=per subject,3=total tuition fee.
	
		int iIndex = 0;
		String strSubTotalRate = null;//System.out.println(fOperation.vTuitionFeeDtls);
		
		java.sql.PreparedStatement pstmtGetLecLabStat = null;
		strTemp = "select IS_ONLY_LAB from enrl_final_cur_list where sub_sec_index=? and enrl_final_cur_list.is_valid = 1 and "+
					"user_index = "+(String)vStudInfo.elementAt(0)+" and IS_TEMP_STUD = "+paymentUtil.isTempStudInStr();
		pstmtGetLecLabStat = dbOP.getPreparedStatement(strTemp);
		
		strTemp = " select valid_date_fr_ess, valid_date_to_ess from E_SUB_SECTION where IS_VALID = 1  "+
				" and valid_date_fr_ess is not null "+
				" and valid_date_to_ess is not null "+
				" and SUB_SEC_INDEX = ? ";
		java.sql.PreparedStatement pstmtESSDateRange = dbOP.getPreparedStatement(strTemp);
		String strESSDateRange = null;
	
		String strLabFee = null;
		int iIndexOf = 0;
		
		for(int i = 0; i< vAssessedSubDetail.size() ; ++i)
		{
			if(strFeeTypeCatg == null)	strFeeTypeCatg = (String)vAssessedSubDetail.elementAt(8);
	
			fTotalUnit = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+3))+Float.parseFloat((String)vAssessedSubDetail.elementAt(i+4));
			fTotalLoad += fTotalUnit;
			fUnitsTaken += Float.parseFloat((String)vAssessedSubDetail.elementAt(i+9));
			strSubSecIndex = (String)vAssessedSubDetail.elementAt(i);			
			strESSDateRange = null;
			pstmtESSDateRange.setString(1, strSubSecIndex);
			rs= pstmtESSDateRange.executeQuery();
			if(rs.next())
				strESSDateRange = ConversionTable.convertMMDDYYYY(rs.getDate(1))+"-"+ConversionTable.convertMMDDYYYY(rs.getDate(2));
			rs.close();
	
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
			
			//strLabFee = null;
//			if(FA.vCommonVector != null) {
//				if(vDryLabSubject.indexOf(vAssessedSubDetail.elementAt(i+1)) == -1) {
//					iIndexOf = FA.vCommonVector.indexOf((String)vAssessedSubDetail.elementAt(i+1));
//					if(iIndexOf > -1) {
//						strLabFee = (String)FA.vCommonVector.elementAt(iIndexOf + 2);
//					}
//				}
//			}
			
	strTemp = (String)vAssessedSubDetail.elementAt(i+2);
	if(strTemp.length() > 26) 
		strTemp = strTemp.substring(0, 26);
	%>
	  <tr>
	  	<td valign="top" height="16" class="thinborderBOTTOM" align="center">&nbsp;<%if(vDroppedSub.indexOf(vAssessedSubDetail.elementAt(i)) > -1) {%> W <%}%></td>
		<td class="fontSize9" valign="top">&nbsp;<%=strSection%></td>
		<td class="fontSize9" valign="top">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
		<td class="fontSize9" valign="top">&nbsp;<%=strTemp.toUpperCase()%><%=WI.getStrValue(strESSDateRange, "<br>", "", "")%></td>
		<td class="fontSize9" valign="top">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+9)%></td>
		<td class="fontSize9" valign="top" style="padding-left:5px;"><%=WI.getStrValue(strSchedule,"N/A")%></td>
		<td class="fontSize9" valign="top" style="padding-left:5px;"><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
	  </tr>	  
	  
	<% i = i+9;
	strRoomAndSection = null;
	strSchedule = null;
	}%>	  
	</table>
<%
if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && fTutionFee >= 0f) {//bolIsTempStudyLoad = true;
	//get here payment detail payment method detail.
	Vector[] vRetResult = faPayment.viewTutionFeePaymentDetail(dbOP,(String)vStudInfo.elementAt(0),(String)vORInfo.elementAt(23),
							(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),paymentUtil.isTempStudInStr(), "0");
if(vRetResult != null && !bolIsSEACREST) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="12%">Prev. Balance:</td>
		<td width="8%" align="right" class="thinborderBOTTOM">&nbsp; <%=CommonUtil.formatFloat(fOutstanding,true)%></td>
		<td width="14%">&nbsp; Curr. Charges:</td>
		<td width="9%" align="right" class="thinborderBOTTOM">&nbsp; <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></td>
		<td width="10%">&nbsp; Uniforms:</td>
		<td width="7%" align="right" class="thinborderBOTTOM">&nbsp;</td>
		<td width="11%">&nbsp; Adjustment:</td>
		<%
			if(dTotalDiscount == 0d)
				strTemp = "&nbsp;";
			else
				strTemp = CommonUtil.formatFloat(dTotalDiscount, true);
		%>
		<td width="9%" align="right" class="thinborderBOTTOM">&nbsp; <%=strTemp%></td>
		<td width="12%">&nbsp; Amount Paid:</td>
		<td width="8%" align="right" class="thinborderBOTTOM">&nbsp; <%=CommonUtil.formatFloat(dTotalAmtPaid, true)%></td>
	</tr>
	<%if(false){%><!--
	<tr>
		<td >Total Load:</td>
		<td align="right" class="thinborderBOTTOM">&nbsp; <%=fUnitsTaken%></td>
		<td >&nbsp; Prelim:</td>
		<td align="right" class="thinborderBOTTOM">&nbsp; 
				<%//=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(7)),true)%></td>
		<td >&nbsp; Midterm:</td>
		<td  align="right" class="thinborderBOTTOM">&nbsp; 
				<%//=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+3*1 +2)) ,true)%></td>
		<td >&nbsp; Semi-Final:</td>
		<td  align="right" class="thinborderBOTTOM">&nbsp; 
				<%//=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+ 3*2+2)),true)%></td>
		<td >&nbsp; Final:</td>
		<td  align="right" class="thinborderBOTTOM">&nbsp; 
				<%//=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+ 3*3+2)),true)%></td>
	</tr>
	
	<tr>
		<td colspan="8"></td>
		<td>&nbsp; Balance:</td> 
		<%
		float fBalance = (fOutstanding+fTutionFee+fCompLabFee+fMiscFee) - 
			(Float.parseFloat((String)vRetResult[1].elementAt(5)) + Float.parseFloat(Double.toString(dTotalDiscount))   );
		%>
		<td align="right" class="thinborderBOTTOM">&nbsp; <%=CommonUtil.formatFloat(fBalance,true)%></td>
	</tr>
	-->
  <%}	double dTemp = 0d;
  		for(int i = 7; i < vInstallmentDtls.size(); i += 2) {
			dTemp = ((Double)vInstallmentDtls.elementAt(i + 1)).doubleValue();
			if(dTemp < 0d) {
				vInstallmentDtls.setElementAt(new Double(0d), i + 1);//get to 0
				if( (i + 3) <  vInstallmentDtls.size()) {
					vInstallmentDtls.setElementAt(new Double(((Double)vInstallmentDtls.elementAt(i + 3)).doubleValue() + dTemp), i + 3);
				}
				dTemp = 0d;
				
			}
		}
	%>
  	<tr>
		<td >Total Load:</td>
		<td align="right" class="thinborderBOTTOM">&nbsp; <%=fUnitsTaken%></td>
		<td >&nbsp; Prelim:</td>
		<td align="right" class="thinborderBOTTOM">&nbsp;
				<%if(vInstallmentDtls.size() > 7 && ((String)vInstallmentDtls.elementAt(7)).startsWith("Prelim")){%>
					<%=CommonUtil.formatFloat(((Double)vInstallmentDtls.elementAt(8)).doubleValue(),true)%>
				<%vInstallmentDtls.remove(7);vInstallmentDtls.remove(7);}%>
				</td>
		<td >&nbsp; Midterm:</td>
		<td  align="right" class="thinborderBOTTOM">&nbsp; 
				<%if(vInstallmentDtls.size() > 7 && ((String)vInstallmentDtls.elementAt(7)).startsWith("Midterm")){%>
					<%=CommonUtil.formatFloat(((Double)vInstallmentDtls.elementAt(8)).doubleValue(),true)%>
				<%vInstallmentDtls.remove(7);vInstallmentDtls.remove(7);}%>
				</td>
		<td >&nbsp; Semi-Final:</td>
		<td  align="right" class="thinborderBOTTOM">&nbsp; 
				<%if(vInstallmentDtls.size() > 7 && ((String)vInstallmentDtls.elementAt(7)).startsWith("Semi")){%>
					<%=CommonUtil.formatFloat(((Double)vInstallmentDtls.elementAt(8)).doubleValue(),true)%>
				<%vInstallmentDtls.remove(7);vInstallmentDtls.remove(7);}%>
				</td>
		<td >&nbsp; Final:</td>
		<td  align="right" class="thinborderBOTTOM">&nbsp; 
				<%if(vInstallmentDtls.size() > 7 && ((String)vInstallmentDtls.elementAt(7)).startsWith("Final")){%>
					<%=CommonUtil.formatFloat(((Double)vInstallmentDtls.elementAt(8)).doubleValue(),true)%>
				<%vInstallmentDtls.remove(7);vInstallmentDtls.remove(7);}%>
				</td>
	</tr>
	
	<tr>
		<td colspan="8"></td>
		<td>&nbsp; Balance:</td> 
		<%
			strTemp = (String)vInstallmentDtls.elementAt(6);
			if(strTemp.startsWith("-"))
				strTemp = "0.00";
		%>
		<td align="right" class="thinborderBOTTOM">&nbsp; <%=strTemp%></td>
	</tr>

</table>
<%}
}%>	
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="16">Classes will start on <strong><u><%=strStartOfClasses%></u></strong></td></tr>
	<tr><td height="16">Note: Please present this form to your instructor on the first day of classes
	<%if(!bolIsSEACREST){%>. No study load, No Entry to classes.<%}else{%> for admission<%}%></td></tr>
</table>

	
<%
}//if vAssessedSubDetail no null

}//if(vStudInfo != null && vStudInfo.size() > 0){
dbOP.cleanUP();
%>
</body>
</html>
