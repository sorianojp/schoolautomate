<%
	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5      = (String)request.getSession(false).getAttribute("info5");
	if(strSchoolCode == null)
		strSchoolCode = "";

	boolean bolIsJonelta = false;
	if(strInfo5 != null && strInfo5.equals("jonelta"))
		bolIsJonelta = true;
	
	//strSchoolCode = "SPC";
	if(strSchoolCode.startsWith("WUP")){%>
		<jsp:forward page="./enrollment_receipt_print_WUP_bas.jsp" />
	<%}
	if(strSchoolCode.startsWith("PWC")){%>
		<jsp:forward page="./enrollment_receipt_print_bas_pwc.jsp" />
	<%}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
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
-->
</style>
</head>

<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,
	enrollment.FAAssessment,enrollment.SubjectSection,enrollment.EnrlAddDropSubject,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strSubSecIndex = null;
	Vector vLabSched      = null;
	String strORNumber    = WI.fillTextValue("or_number");

	String strDegreeType  = null;

	String[] astrConvertSem = {"Summer","",""};
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

	request.getSession(false).setAttribute("go_home","../admin_staff/admin_staff_bottom_content.htm");
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

double dReservationFee = 0d;//only for CGH.

float fTutionFee        = 0f;
float fCompLabFee       = 0f;
float fMiscFee          = 0f;
float fOutstanding      = 0f;
float fTotalPayableAmt 	= 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,

float fEnrollmentDiscount = 0f; //this sum of full payment, early enrollment or late enrollment discount/fine implementations.
String strEnrolmentDiscDetail = null;
float fPayableAfterDiscount = 0f;

String 	strCollegeName = null;
String[] astrConvertGender = {"Male","Female"};

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
FA.setIsBasic(true);
paymentUtil.setIsBasic(true);
fOperation.setIsBasic(true);

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

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
				(String)vORInfo.elementAt(25),(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
				(String)vORInfo.elementAt(22));
				
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
        (String)vORInfo.elementAt(22));

	strCollegeName = new CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(5));
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
}
if(strErrMsg == null) //collect fee details here.
{
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
	if(fTutionFee > 0)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
		fOperation.checkIsEnrolling(dbOP, (String)vStudInfo.elementAt(0),
				(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
		fOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));
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
		}

	vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
					(String)vORInfo.elementAt(22),"1","0");
			//System.out.println(vAssessedSubDetail);System.out.println(vAssessedSubDetail);
		if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0){
			strErrMsg = FA.getErrMsg();			
		}
		
		if(strSchoolCode.startsWith("DBTC") || strSchoolCode.startsWith("SPC"))
			dReservationFee = paymentUtil.getReservationFeeCGH(dbOP, (String)vStudInfo.elementAt(0),
								astrSchYrInfo[0], astrSchYrInfo[1],	astrSchYrInfo[2],paymentUtil.isTempStud());

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

boolean bolIsSPC = strSchoolCode.startsWith("SPC");

boolean bolShowOC = true;
boolean bolShowMisc = true;

boolean bolPreventForward = WI.fillTextValue("prevent_forward").equals("1");
if(bolIsJonelta) {
	bolShowOC = bolPreventForward;
	bolShowMisc = bolPreventForward;
}

if(strInfo5 != null && strInfo5.equals("ICA")) {
	bolShowOC = false;
	bolShowMisc = false;
}


/**
double dBookAmt  = 0;
if(bolIsSPC && vMiscFeeInfo != null && vMiscFeeInfo.size() > 0) {
	for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
		if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0)
			continue;
		if(((String)vMiscFeeInfo.elementAt(i + 2)).toLowerCase().startsWith("textbook") ==0) {
			dBookAmt = Double.parseDouble((String)vMiscFeeInfo.elementAt(i + 2));
			break;
		}
	}
	if(dBookAmt > 0d)
		dBookAmt = dBookAmt/6d;
}
**/

//System.out.println(fOperation.vAssessedHrDetail);
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%if(strSchoolCode.startsWith("UI")){%>
    <tr>
      <td>
	  <table width="100%" cellpadding="0" cellspacing="0">
	  	<tr>
			<td width="45%">UI-REG-005</td>
			<td width="55%" align="right">Revision No. 00: 06June 2005</td>
		</tr>
	  </table>
	  </td>
    </tr>
<%}
if(bolIsSPC){%>
    <tr >
      <td height="25"><div align="center"><font size="2"><strong>SAN PEDRO COLLEGE-ULAS CAMPUS</strong><br>
	  <font size="1">Davao-Bukidnon Highway, Ulas, Davao City</font></font></div></td>
    </tr>
<%}
else if(bolShowReceiptHeading){%>
    <tr >
      <td height="25"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
	  <font size="1">
	  <%if(strSchoolCode.startsWith("WNU")){%>
	  (Formerly West Negros College)<br>
	  <%}%>
        <%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false),"","<br>","")%>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=WI.getStrValue(SchoolInformation.getInfo1(dbOP,false,false),"","<br><br>","")%>        
          <%=strCollegeName%></font></font></div></td>
    </tr>
<%}
if(strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("CSA"))
	strTemp = "CERTIFICATION OF REGISTRATION";
else if(strSchoolCode.startsWith("DBTC") || strSchoolCode.startsWith("PIT"))
	strTemp = "Basic Education <br>OFFICIAL ENROLMENT SHEET";
else if(strSchoolCode.startsWith("UPH"))
	strTemp = "CERTIFICATE OF ENROLLMENT";
else if(bolIsSPC)
	strTemp = "OFFICIAL REGISTRATION FORM";
else
	strTemp = "OFFICIAL STUDY LOAD";

%>
    <tr >
      <td height="20" ><div align="center"><strong><%=strTemp%></strong><br>
        <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%> AY <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%>
		</div></td>
    </tr>
    <tr >
      <td height="20" align="right">Date and time printed: <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
</table>
<!--
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%if(bolShowReceiptHeading){%>
    <tr >
      <td height="25"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <%=SchoolInformation.getInfo1(dbOP,false,false)%><br>
        <br>
          <%=strCollegeName%></div></td>
    </tr>
<%}%>
    <tr >
      <td height="20" ><div align="center">
	  <% if (strSchoolCode.startsWith("VMUF") && vStudInfo != null){%> 
	  	<font style="font-size:11px"><strong><%=(String)vStudInfo.elementAt(17)%>
			</strong></font><br>
	  <%}%> 	  
	  <strong>FEE PAYMENT DETAILS </strong><br>
        <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%> AY <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%>
		</div></td>
    </tr>
    <tr >
      <td height="20" align="right">Date and time printed: <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
	</table>
-->	
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

if(vStudInfo != null && vStudInfo.size() > 0){
%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td height="18">Student ID </td>
    <td><strong><font size="2"><%=(String)vORInfo.elementAt(25)%></font></strong></td>
    <td>Grade Level</td>
    <td colspan="2"><strong><%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(4),"0")))%></strong></td>
  </tr>
  <tr>
    <td height="18" width="11%">Student Name </td>
    <td width="35%"><strong><font size="2"><%=(String)vStudInfo.elementAt(1)%></font></strong></td>
    <td width="11%">Gender : </td>
    <td width="32%"><strong><%=WI.getStrValue(vStudInfo.elementAt(13),"")%></strong></td>
    <td width="11%">&nbsp;</td>
  </tr>
  <tr>
    <td height="18" width="11%">Student Type</td>
    <td width="35%"><strong><font size="2"><%=WI.getStrValue((String)vStudInfo.elementAt(15),"")%></font></strong></td>
    <td width="11%">&nbsp;</td>
    <td width="32%">&nbsp;</td>
    <td width="11%">&nbsp;</td>
  </tr>
<%if(!strSchoolCode.startsWith("UI") && !strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("WNU") && !bolIsSPC){%>
  
<%}%>
</table>
<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0) { %>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr > 
    <td width="10%" height="19" class="thinborder"><strong>SUBJECT CODE </strong></td>
    <td width="26%" height="19" class="thinborder"><strong>SUBJECT NAME</strong></td>
    <td width="21%" class="thinborder"><strong>SCHEDULE</strong></td>
    <td width="15%" class="thinborder"><strong>SECTION/ROOM #</strong></td>
    <%if(!strSchoolCode.startsWith("AUF")){%>
    <%
if(!strSchoolCode.startsWith("UI")) {%>
    <td width="5%" class="thinborder"><strong>TOTAL UNITS</strong></td>
    <%}
}%>
    <%
if(strSchoolCode.startsWith("UI") && fOperation.vAssessedHrDetail != null &&
		fOperation.vAssessedHrDetail.size() > 0) {%>
    <%}
if(!strSchoolCode.startsWith("AUF")) {%>
    <%}%>
  </tr>
  <%
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

	for(int i = 0; i< vAssessedSubDetail.size() ; ++i)
	{
		if(strFeeTypeCatg == null)	strFeeTypeCatg = (String)vAssessedSubDetail.elementAt(8);

		fTotalUnit = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+3))+Float.parseFloat(WI.getStrValue((String)vAssessedSubDetail.elementAt(i+4),"0"));
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

		strLecLabStat  = dbOP.mapOneToOther("enrl_final_cur_list","sub_sec_index",strSubSecIndex, "IS_ONLY_LAB",
			" and enrl_final_cur_list.is_valid = 1 and enrl_final_cur_list.is_del = 0 and user_index = "+
			(String)vStudInfo.elementAt(0)+" and IS_TEMP_STUD = "+paymentUtil.isTempStudInStr());

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
%>
  <tr > 
    <td height="19" class="thinborder">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
    <td class="thinborder">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+2)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
    <%if(!strSchoolCode.startsWith("AUF")) {%>
    <%
if(!strSchoolCode.startsWith("UI")) {%>
    <td class="thinborder">&nbsp;<%=fTotalUnit%></td>
    <%}
}%>
    <%
if(strSchoolCode.startsWith("UI") && fOperation.vAssessedHrDetail != null &&
		fOperation.vAssessedHrDetail.size() > 0) {%>
    <%}
if(!strSchoolCode.startsWith("AUF")) {%>
    <%}%>
  </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}%>

<!--
  <tr > 
    <td colspan="5" height="18" class="thinborder"><div align="center"> 
        <%if(strErrMsg != null){%>
        <%=strErrMsg%> 
        <%}else{%>
        TOTAL LOAD UNITS : <strong> 
        <%//=fTotalLoad%>
        <%=fUnitsTaken%></strong> 
        <%}%>
      </div></td>
  </tr>
 -->
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="18" colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td width="16%" >Advised and printed by : </td>
    <td width="40%" height="25"><strong><u><%=(String)request.getSession(false).getAttribute("first_name")%></u></strong></td>
    <td width="13%" height="25">Approved by :</td>
    <td width="31%" height="25">&nbsp;</td>
  </tr>
  <tr>
    <td width="16%" height="18">&nbsp;</td>
    <td valign="top"><em>Principal / Faculty/Secretary</em></td>
    <td valign="top">&nbsp;</td>
    <td valign="top" class="thinborderTOP" align="center" style="font-size:9px;"><em>Principal</em></td>
  </tr>
</table>

<%}//if vAssessedSubDetail no null
}//stud_info is not null.
dbOP.cleanUP();
%>
</body>
</html>
