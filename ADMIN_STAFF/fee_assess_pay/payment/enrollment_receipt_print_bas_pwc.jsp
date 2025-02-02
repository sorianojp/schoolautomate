<%
	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5      = (String)request.getSession(false).getAttribute("info5");
	if(strSchoolCode == null)
		strSchoolCode = "";


	boolean bolPWC = strSchoolCode.startsWith("PWC");

	boolean bolIsJonelta = false;
	if(strInfo5 != null && strInfo5.equals("jonelta"))
		bolIsJonelta = true;
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
<%if(!strSchoolCode.startsWith("AUF")){%>
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
	 
	 TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;
	 border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	 
	 TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
<%}%>
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
	java.sql.ResultSet rs = null;

double dReservationFee = 0d;//only for CGH.

float fTutionFee        = 0f;
float fCompLabFee       = 0f;
float fMiscFee          = 0f;
float fOutstanding      = 0f;
float fTotalPayableAmt 	= 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,
double dTotalDiscount = 0d;

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

String strSectionName = null;

String strAdviser = null;


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
else if(strSchoolCode.startsWith("PWC"))
	strTemp = "CERTIFICATE OF REGISTRATION";
else
	strTemp = "FEE PAYMENT DETAILS";

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

	if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0) {
		strSectionName = (String)vAssessedSubDetail.elementAt(0);
		strSectionName = "select section from e_sub_section where sub_sec_index= "+strSectionName;
		strSectionName = dbOP.getResultOfAQuery(strSectionName, 0);
	}
%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td height="18">Student ID </td>
    <td><strong><font size="2"><%=(String)vORInfo.elementAt(25)%></font></strong></td>
    <td>Grade Level</td>
    <td><strong><%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(4),"0")))%></strong></td>
  </tr>
  <tr>
    <td height="18" width="11%">Student Name </td>
    <td width="42%"><strong><font size="2"><%=(String)vStudInfo.elementAt(1)%></font></strong></td>
    <td width="15%">Section</td>
    <td width="32%"><strong><%=WI.getStrValue(strSectionName, "&nbsp;")%></strong></td>
  </tr>
  <tr>
    <td height="18" width="11%">Student Type</td>
    <td width="42%"><strong><font size="2"><%=WI.getStrValue((String)vStudInfo.elementAt(15),"")%></font></strong></td>
    <td width="15%">Gender : </td>
    <td width="32%"><strong><%=WI.getStrValue(vStudInfo.elementAt(13),"")%></strong></td>
  </tr>
<%
if(false){
if(!strSchoolCode.startsWith("UI") && !strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("WNU") && !bolIsSPC){%>
  <tr>
    <td height="18">Student's Signature</td>
    <td>____________________________________</td>
    <td>Parent's/Guardian's Signature</td>
    <td>__________________________________________</td>
  </tr>
<%}}else{%>
	<tr>
    <td height="18" colspan="4"><font style="font-size:11px;">SUBJECT LOAD</font></td>
   </tr>
<%}%>
</table>
<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0)
{ 
	if(!strSchoolCode.startsWith("AUF")){
%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="55%" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			  <tr > 
				 <td width="24%" height="19" class="thinborder"><strong>SUBJECT CODE </strong></td>
				 <td width="76%" height="19" class="thinborder"><strong>SUBJECT NAME</strong></td>
				 <%if(!strSchoolCode.startsWith("AUF")){%>
				 <%
			if(!strSchoolCode.startsWith("UI")) {%>
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
			
				for(int i = 0; i< vAssessedSubDetail.size() ; ++i) {%>
			  <tr > 
				 <td height="19" class="thinborder">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
				 <td class="thinborder">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+2)%></td>
			  </tr>
			  <% i = i+9;
			strRoomAndSection = null;
			strSchedule = null;
			}%>
			
			</table>
		</td>
		
		<%if(bolPWC){%>
		<td width="2%">&nbsp;</td>
<!------------------MISCELLANEOUS-------------------------------->		



		<td valign="top">
		<%
if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && fTutionFee > 0){


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
			 fFirstInstalAmt = 0f;
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
          <td width="65%" height="14">TUITION FEE<strong><font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%> </font></strong></td>
          <td width="35%" height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></font></div></td>
        </tr>
        <!--
		<tr> 
          <td height="14">COMP. LAB. FEE</td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></font></div></td>
        </tr>
		-->
        <tr> 
          <td height="14">MISCELLANEOUS FEES</td>
          <td height="14"><div align="right">
       <%if(strSchoolCode.startsWith("AUF") || !bolShowMisc){%>
           <strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong> 
        <%}%>
		</div></td>
        </tr>
         <%
		 if(!strSchoolCode.startsWith("AUF") && bolShowMisc){
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0)
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
        <%}if(fMiscOtherFee > 0f){%>
		<tr> 
		  <td height="14"><font size="1">OTHER CHARGES</font></td>
          <td height="14"><div align="right"></div></td>
        </tr>
         <%
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
				continue;
		%>
        <tr>
          <td height="14">&nbsp;&nbsp;<font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
        <tr> 
          <td height="14"><font size="1"><strong>TOTAL OTHER CHARGE</strong></font></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></font></div></td>
        </tr>
		<%}%>
        <tr> 
          <td height="14" colspan="2"><hr size="1"></td>
        </tr>
        <tr> 
          <td height="14"><strong>TOTAL ASSESSMENT</strong></td>
          <td height="14"><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></strong></font></div></td>
        </tr>
        <tr> 
          <td height="14"><strong>OLD ACCOUNTS</strong></td>
          <td height="14"><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></div></td>
        </tr>
        <%if(!bolPWC){%>
			  <tr> 
				 <td height="14"><strong>TOTAL AMOUNT DUE</strong></td>
				 <td height="14"><div align="right"><font size="1"><strong>Php 
				 	<%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding,true)%></strong></font></div></td>
			  </tr>
			  <%}else{%>
			  	<tr> 
				 <td height="14"><strong>DISCOUNTS AVAILED</strong></td>
				 <td height="14"><div align="right"><font size="1"><strong>Php 
						<%if(dTotalDiscount == 0d) {%>
					  	0.00
					  <%}else{%>
					  <%=CommonUtil.formatFloat(dTotalDiscount, true)%>
					  <%}%> 	
				</strong></font></div></td>
			  </tr>
			  <%}%>
<%if(dReservationFee > 0d){
fTotalPayableAmt = fTotalPayableAmt - (float)dReservationFee;%>
        <tr>
          <td height="14">LESS RESERVATION FEE</td>
          <td height="14"><div align="right"><font size="1">Php <%=CommonUtil.formatFloat(dReservationFee ,true)%></font></div></td>
        </tr>
<%}%>
        <tr> 
          <td height="14"><strong>TOTAL BALANCE DUE</strong></td>
          <td height="14"><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTotalPayableAmt - fAmtPaidDurEnrl - dTotalDiscount ,true)%></strong></font></div></td>
        </tr>
        <tr> 
          <td height="14">&nbsp;</td>
          <td height="14"><div align="right"></div></td>
        </tr>
        <tr> 
          <td height="14">&nbsp;</td>
          <td height="14"><div align="right"></div></td>
        </tr>
      </table>
			
		<%}
}//if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && fTutionFee > 0)

else{%>&nbsp;<%}%>
	</td>
	<%}%>
	</tr>
</table>

<%
  } // if(!strSchoolCode.startsWith("AUF")
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


 %>

<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr> 
    <td width="45%" height="14" valign="top">&nbsp;
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <%if(!strSchoolCode.startsWith("AUF")){%>
        <tr> 
          <td width="54%" height="14"><div align="right"><strong>:: PAYMENT DETAILS 
              ::</strong></div></td>
          <td width="46%" height="14">&nbsp;</td>
        </tr>
        <%}%>
<%if(!strSchoolCode.startsWith("WNU")){%>
        <tr> 
          <td height="14">PAYEE TYPE</td>
          <td height="14"><strong><%=(String)vRetResult[0].elementAt(1)%></strong></td>
        </tr>
<%}if(vRetResult[0].elementAt(2) != null){%>
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
        <%if(strEnrolmentDiscDetail != null){%>
        <tr> 
          <td height="14" colspan="2"><font size="1">(<%=strEnrolmentDiscDetail%>)</font></td>
        </tr>
        <%}
		if(vRetResult[1].elementAt(3) != null){%>
        <tr> 
          <td height="14">APPROVAL NO.</td>
          <td height="14"><strong><%=WI.getStrValue(vRetResult[1].elementAt(3))%></strong></td>
        </tr>
        <%}if(vRetResult[1].elementAt(1) != null && !((String)vRetResult[1].elementAt(1)).equals("Internal")) {%>
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
if(!strSchoolCode.startsWith("WNU") && !strSchoolCode.startsWith("UPH") && !bolShowMisc){%>
        <tr> 
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
        <tr> 
          <td height="14" colspan="2">(Business Office) Receipt printed by:<u>&nbsp;<%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%>&nbsp;&nbsp;</u> </td>
        </tr>
        <tr> 
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
<%}%>
        <tr> 
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
<% if (vInstallmentDtls != null && vInstallmentDtls.size() > 5 ){%> 
        <tr> 
          <td height="14" colspan="2"><font size="2"><b>DUE FOR <%=((String)vInstallmentDtls.elementAt(5)).toUpperCase()%>: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(7),true)%></b></font> </td>
        </tr>
        <tr> 
          <td height="14" colspan="2"> 
<% } if(vInstallmentDtls != null && vInstallmentDtls.size() > 5 + 3*1) //prelim
{%> DUE FOR <%=((String)vInstallmentDtls.elementAt(5+3*1)).toUpperCase()%>: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+3*1 +2),true)%> <%}%> </td>
        </tr>
        <%if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*2) {//midterm%>
        <tr> 
          <td height="14" colspan="2">DUE FOR <%=((String)vInstallmentDtls.elementAt(5+ 3*2)).toUpperCase()%>: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*2+2),true)%> </td>
        </tr>
        <%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*3) {//prelim%>
        <tr> 
          <td height="14" colspan="2">DUE FOR <%=((String)vInstallmentDtls.elementAt(5+ 3*3)).toUpperCase()%>: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*3+2),true)%> </td>
        </tr>
        <%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*4) {//prelim%>
        <tr> 
          <td height="14" colspan="2">DUE FOR <%=((String)vInstallmentDtls.elementAt(5+ 3*4)).toUpperCase()%>: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*4+2),true)%> </td>
        </tr>
        <%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*5) {//prelim%>
        <tr> 
          <td height="14" colspan="2">DUE FOR <%=((String)vInstallmentDtls.elementAt(5+ 3*5)).toUpperCase()%>: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*5+2),true)%> </td>
        </tr>
        <%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*6) {//prelim%>
        <tr> 
          <td height="14" colspan="2">DUE FOR <%=((String)vInstallmentDtls.elementAt(5+ 3*6)).toUpperCase()%>: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*6+2),true)%> </td>
        </tr>
        <%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*7) {//prelim%>
        <tr> 
          <td height="14" colspan="2">DUE FOR <%=((String)vInstallmentDtls.elementAt(5+ 3*7)).toUpperCase()%>: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*7+2),true)%>		  </td>
        </tr>
        <%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*8) {//prelim%>
        <tr> 
          <td height="14" colspan="2">DUE FOR <%=((String)vInstallmentDtls.elementAt(5+ 3*8)).toUpperCase()%>: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*8+2),true)%>		  </td>
        </tr>
        <%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*9) {//prelim%>
        <tr> 
          <td height="14" colspan="2">DUE FOR <%=((String)vInstallmentDtls.elementAt(5+ 3*9)).toUpperCase()%>: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*9+2),true)%>		  </td>
        </tr>
        <%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*10) {//prelim%>
        <tr> 
          <td height="14" colspan="2">DUE FOR <%=((String)vInstallmentDtls.elementAt(5+ 3*9)).toUpperCase()%>: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*10+2),true)%>		  </td>
        </tr>
        <%}%>
        <tr> 
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
        <tr> 
          <td height="14" colspan="2">(NOTE: Above installment schedule may change 
            based on actual payment and after enrolment adjustments.)</td>
        </tr>

		<tr><Td colspan="2" height="25">&nbsp;</Td></tr>
	  <tr >
		<td height="20" >Advised by :</td>
		<td class="thinborderBOTTOM"><%=strAdviser%></td>    
	  </tr>
	  <tr >
		<td height="20" width="25%">Printed by :</td>
	   <td class="thinborderBOTTOM"><%=request.getSession(false).getAttribute("first_name")%></td>    
	  </tr>
	 
      </table>
		
	</td>
    <td width="10%">&nbsp;</td>
    <td width="45%" valign="top">&nbsp;
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td>
							1. PWC shall refund tuition and related payments only upon the execution by parents 
							or guardians of students of a written "Official notice of withdrawal from enrollment", 
							indicating the date, which the Registrar must approve and the Principal/authorized representative must note.
						</td>
					</tr>
					<tr>
						<td>
							2. The school shall charge a student, who drops out before classes start, a service fee of P1,000.
						</td>
					</tr>
					<tr>
						<td>
							3. Depending on the timing of the submission of the written notice of withdrawal from enrollment, the following schedule of charges shall apply:
						</td>
					</tr>
					<tr>
						<td valign="top">
							<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
								<tr>
									<td class="thinborder" align="center">Filling of notice of<br>Withdrawal</td>
									<td class="thinborder" align="center">%Charged Against Equivalent<br>of First Installment</td>
								</tr>
								
								<tr>
									<td class="thinborder">Within the 1st week of classes</td>
									<td class="thinborder" align="center">25%</td>
								</tr>
								<tr>
									<td class="thinborder">Within the 2ndweek of classes</td>
									<td class="thinborder" align="center">50%</td>
								</tr>
								<tr>
									<td class="thinborder">Within the 3rd week of classes</td>
									<td class="thinborder" align="center">75%</td>
								</tr>
								<tr>
									<td class="thinborder">Within the 4th week of classes</td>
									<td class="thinborder" align="center">100%</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td>
							<br>
							4. A student who officially drops out after the fourth week of classes shall 
							pay the tuition fees covering the period of the student’s stay in school up to the time of withdrawal. 
							The student shall also pay the full amount of miscellaneous and other fees and charges, 
							except when the transfer or withdrawal is for due cause.
						</td>
					</tr>
					
					<tr>
						<td>
							5. The school shall issue refunds in case of overpayment. 
							Refunds processing shall begin only after enrollment has officially closed and will require a 
							statement of account duly signed by the cashier indicating the overpayment.
						</td>
					</tr>
					
					<tr>
						<td>
							6. Students become officially enrolled only upon compliance with the required down payment. 
							They forfeit their down payment if they drop out after classes started.
						</td>
					</tr>
					
			</table>
			<br>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
				<tr>
					<td class="thinborderLEFT" width="50%" align="center" height="22" valign="bottom">CONFORME:</td>
					<td width="3%">&nbsp;</td>
					<td valign="bottom" align="center">VERIFIED & CONFIRM BY:</td>
				</tr>
				<tr>
					<td height="25" valign="bottom" align="center" class="thinborderLEFT"><div style="border-bottom:solid 1px #000000; width:90%;"></div></td>
					<td width="3%">&nbsp;</td>
					<td height="25" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%;"></div></td>
				</tr>
				<tr>
					<td align="center" valign="top" class="thinborderLEFT">STUDENT SIGNATURE</td>
					<td width="3%"></td>
					<td align="center" valign="top">REGISTRAR</td>
				</tr>
				
				<tr>
					<td height="25" valign="bottom" class="thinborderLEFT" align="center"><div style="border-bottom:solid 1px #000000; width:90%;"></div></td>		
					<td rowspan="2" class="thinborderBOTTOM" colspan="2">&nbsp;</td>			
				</tr>
				<tr>
					<td align="center" valign="top" class="thinborderBOTTOMLEFT">PARENT/GUARDIAN SIGNATURE</td>					
				</tr>
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
