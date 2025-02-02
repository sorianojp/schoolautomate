<%
	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";
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
<%}%>
-->
</style>
</head>

<body>
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

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	String[] astrSchYrInfo = {"0","0","0"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-assessedfees print(enrollment)","assessedfees_print.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"assessedfees.jsp");
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

String 	strCollegeName = null;

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

		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5), "degree_type"," and is_valid=1 and is_del=0");
		vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
					(String)vORInfo.elementAt(22),"1",strDegreeType);
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
	enrollment.ReadPropertyFileImpl readPropFileImpl = new enrollment.ReadPropertyFileImpl();
	int iRetValue = readPropFileImpl.showReceiptHeading();
	if(iRetValue == -1)
		strErrMsg = readPropFileImpl.getErrMsg();
	else if(iRetValue == 1)
		bolShowReceiptHeading = true;
}
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
if(bolShowReceiptHeading){%>
    <tr >
      <td height="25"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%><br>
        <br>
          <%=strCollegeName%></div></td>
    </tr>
<%}%>
    <tr >
      <td height="20" ><div align="center"><strong>FEE
          PAYMENT DETAILS </strong><br>
        <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%> ,AY <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%>
		</div></td>
    </tr>
    <tr >
      <td height="20" align="right">Date and time printed: <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
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


<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td height="18">Student ID </td>
    <td><strong><font size="2"><%=(String)vORInfo.elementAt(25)%></font></strong></td>
    <td>Course/Major</td>
    <td colspan="2"><strong><%=(String)vStudInfo.elementAt(2)%>
      <%if(vStudInfo.elementAt(6) != null){%>
      / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="18" width="11%">Student Name </td>
    <td width="35%"><strong><font size="2"><%=(String)vStudInfo.elementAt(1)%></font></strong></td>
    <td width="13%">Year Level</td>
    <td width="20%"><strong><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></strong></td>
    <td width="16%">Gender : <strong><%=WI.getStrValue(vStudInfo.elementAt(13),"")%></strong></td>
  </tr>
<%if(!strSchoolCode.startsWith("UI") && !strSchoolCode.startsWith("AUF")){%>
  <tr>
    <td height="18">Student's Signature</td>
    <td>____________________________________</td>
    <td>Parent's/Guardian Signature</td>
    <td colspan="2">__________________________________________</td>
  </tr>
<%}%>
</table>
<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0)
{%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr > 
    <td width="10%" height="18" class="thinborder"><strong>SUBJECT CODE </strong></td>
    <td width="26%" height="19" class="thinborder"><strong>SUBJECT TITLE </strong></td>
    <td width="24%" class="thinborder"><strong>SCHEDULE</strong></td>
    <td width="12%" class="thinborder"><strong>SECTION/ROOM #</strong></td>
    <%if(!strSchoolCode.startsWith("AUF")){%>
    <td width="5%" class="thinborder"><strong>LEC/LAB UNITS </strong></td>
    <%
if(!strSchoolCode.startsWith("UI")) {%>
    <td width="5%" class="thinborder"><strong>TOTAL UNITS</strong></td>
    <%}
}%>
    <td width="5%" class="thinborder"><strong>UNITS TAKEN</strong></td>
    <%
if(strSchoolCode.startsWith("UI") && fOperation.vAssessedHrDetail != null &&
		fOperation.vAssessedHrDetail.size() > 0) {%>
    <td width="5%" class="thinborder"><strong>ASSESSED HRS</strong></td>
    <%}
if(!strSchoolCode.startsWith("AUF")) {%>
    <td width="6%" class="thinborder"><strong>RATE/UNIT</strong></td>
    <td width="7%" class="thinborder"><strong>TOTAL SUBJECT FEE </strong></td>
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
    <td height="19" class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+2)%></td>
    <td class="thinborder"><%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class="thinborder"><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
    <%if(!strSchoolCode.startsWith("AUF")) {%>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+3)%>/<%=(String)vAssessedSubDetail.elementAt(i+4)%></td>
    <%
if(!strSchoolCode.startsWith("UI")) {%>
    <td class="thinborder"><%=fTotalUnit%></td>
    <%}
}%>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+9)%></td>
    <%
if(strSchoolCode.startsWith("UI") && fOperation.vAssessedHrDetail != null &&
		fOperation.vAssessedHrDetail.size() > 0) {%>
    <td class="thinborder"><%=strAssessedHour%></td>
    <%}
if(!strSchoolCode.startsWith("AUF")) {%>
    <td class="thinborder"><%=strRatePerUnit%></td>
    <td class="thinborder"><%=strSubTotalRate%></td>
    <%}%>
  </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}%>
  <tr > 
    <td colspan="9" height="18" class="thinborder"><div align="center"> 
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
          <td width="65%" height="14"><div align="right"><strong>:: FEE DETAILS 
              ::</strong></div></td>
          <td width="35%" height="14">&nbsp;</td>
        </tr>
       <%}%>
	    <tr> 
          <td height="14">TUITION FEE<strong><font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%> </font></strong></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></font></div></td>
        </tr>
        <tr> 
          <td height="14">COMP. LAB. FEE</td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></font></div></td>
        </tr>
        <tr> 
          <td height="14">MISCELLANEOUS FEES</td>
          <td height="14"><div align="right">
       <%if(strSchoolCode.startsWith("AUF")){%>
           <strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong> 
        <%}%>
		</div></td>
        </tr>
         <%
		 if(!strSchoolCode.startsWith("AUF")){
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
        <%}%>
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
        <tr> 
          <td height="14"><strong>TOTAL AMOUNT DUE</strong></td>
          <td height="14"><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding,true)%></strong></font></div></td>
        </tr>
        <tr> 
          <td height="14"><strong>TOTAL BALANCE DUE</strong></td>
          <td height="14"><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTotalPayableAmt - fAmtPaidDurEnrl ,true)%></strong></font></div></td>
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
	
	</td>
    <td width="10%">&nbsp;</td>
    <td width="45%" valign="top">&nbsp;
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <%if(!strSchoolCode.startsWith("AUF")){%>
        <tr> 
          <td width="54%" height="14"><div align="right"><strong>:: PAYMENT DETAILS 
              ::</strong></div></td>
          <td width="46%" height="14">&nbsp;</td>
        </tr>
        <%}%>
        <tr> 
          <td height="14">PAYEE TYPE</td>
          <td height="14"><strong><%=(String)vRetResult[0].elementAt(1)%></strong></td>
        </tr>
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
        <%}%>
        <tr> 
          <td height="14">PAYMENT RECEIVE TYPE</td>
          <td height="14"><strong><%=(String)vRetResult[1].elementAt(1)%></strong></td>
        </tr>
        <%if(vRetResult[1].elementAt(2) != null){%>
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
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
        <tr> 
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
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
        <tr> 
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
        <tr> 
          <td height="14" colspan="2"><font size="2"><b><%=((String)vInstallmentDtls.elementAt(5)).toUpperCase()%> 
            DUE: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(7),true)%></b></font> 
          </td>
        </tr>
        <tr> 
          <td height="14" colspan="2">
            <%
if(vInstallmentDtls != null && vInstallmentDtls.size() > 5 + 3*1) //prelim
{%>
            <%=((String)vInstallmentDtls.elementAt(5+3*1)).toUpperCase()%> DUE: 
            <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+3*1 +2),true)%> 
            <%}%>
          </td>
        </tr>
  		<%if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*2) {//midterm%>
        <tr> 
          <td height="14" colspan="2"><%=((String)vInstallmentDtls.elementAt(5+ 3*2)).toUpperCase()%> 
            DUE: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*2+2),true)%> 
          </td>
        </tr>
        <%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*3) {//prelim%>
        <tr> 
          <td height="14" colspan="2"><%=((String)vInstallmentDtls.elementAt(5+ 3*3)).toUpperCase()%> 
            DUE: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*3+2),true)%> 
          </td>
        </tr>
        <%}%>
        <tr> 
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
      </table>
	</td>
  </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td colspan="4"><div align="center"><strong>:: FEE DETAILS ::</strong></div></td>
    <td height="14" colspan="3"><div align="center"><strong>:: PAYMENT DETAILS
        ::</strong></div></td>
  </tr>
  <tr >
    <td height="15" colspan="3">TUITION FEE<strong><font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%> </font></strong> </td>
    <td width="12%" height="15"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></font></div></td>
    <td height="15">&nbsp;</td>
    <td width="22%" height="15">PAYEE TYPE</td>
    <td width="29%" height="15"><strong><%=(String)vRetResult[0].elementAt(1)%></strong></td>
  </tr>
  <tr >
    <td height="15" colspan="3">COMP. LAB. FEE</td>
    <td height="15"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></font></div></td>
    <td height="15">&nbsp;</td>
    <td height="15">PAYEE NAME </td>
    <td height="15"> <strong><%=WI.getStrValue(vRetResult[0].elementAt(2))%></strong></td>
  </tr>
  <tr >
    <td height="15" colspan="4">MISCELLANEOUS FEES</td>
    <td height="15">&nbsp;</td>
    <td height="15">PAYMENT MODE </td>
    <td height="15"><strong> <%=(String)vRetResult[0].elementAt(3)%></strong></td>
  </tr>
  <tr >
    <td width="1%" height="15">&nbsp;</td>
    <td width="1%" height="15">&nbsp;</td>
    <td width="20%" height="15"><font size="1"><%=(String)vMiscFeeInfo.elementAt(0)%></font></td>
    <td height="15" align="right"><font size="1">
      <%if(vMiscFeeInfo.size() > 1 && ((String)vMiscFeeInfo.elementAt(0)).length() > 0){%>
      <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(1),true)%>
      <%}%>
      </font></td>
    <td height="15">&nbsp;</td>
    <td height="15">ASSISTANCE TYPE</td>
    <td height="15"><strong> <%=WI.getStrValue(vRetResult[0].elementAt(4))%></strong></td>
  </tr>
  <tr >
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15"><font size="1">
      <%if(vMiscFeeInfo.size() > 5 && ((String)vMiscFeeInfo.elementAt(5)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(3)%>
      <%}%>
      </font></td>
    <td height="15" align="right"><font size="1">
      <%if(vMiscFeeInfo.size() > 5 && ((String)vMiscFeeInfo.elementAt(5)).compareTo("0") ==0){%>
      <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(4),true)%>
      <%}%>
      </font></td>
    <td height="15">&nbsp;</td>
    <td height="15">AMOUNT PAID</td>
    <td height="15"><strong><%=CommonUtil.formatFloat((String)vRetResult[1].elementAt(5),true)%></strong></td>
  </tr>
  <%if(strEnrolmentDiscDetail != null){%>
  <tr >
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15" colspan="2"><font size="1">(<%=strEnrolmentDiscDetail%>)</font></td>
  </tr>
  <%}%>
  <tr >
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15"><font size="1">
      <%if(vMiscFeeInfo.size() > 8 && ((String)vMiscFeeInfo.elementAt(8)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(6)%>
      <%}%>
      </font></td>
    <td height="15"><div align="right"><font size="1">
        <%if(vMiscFeeInfo.size() > 8 && ((String)vMiscFeeInfo.elementAt(8)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(7),true)%>
        <%}%>
        </font></div></td>
    <td height="15">&nbsp;</td>
    <td height="15">APPROVAL NO.</td>
    <td height="15"><strong><%=WI.getStrValue(vRetResult[1].elementAt(3))%></strong></td>
  </tr>
  <tr >
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15"><font size="1">
      <%if(vMiscFeeInfo.size() > 11 && ((String)vMiscFeeInfo.elementAt(11)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(9)%>
      <%}%>
      </font></td>
    <td height="15"><div align="right"><font size="1">
        <%if(vMiscFeeInfo.size() > 11  && ((String)vMiscFeeInfo.elementAt(11)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(10),true)%>
        <%}%>
        </font></div></td>
    <td height="15">&nbsp;</td>
    <td height="15">PAYMENT RECEIVE TYPE</td>
    <td height="15"> <strong><%=(String)vRetResult[1].elementAt(1)%></strong></td>
  </tr>
  <tr >
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15"><font size="1">
      <%if(vMiscFeeInfo.size() > 14  && ((String)vMiscFeeInfo.elementAt(14)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(12)%>
      <%}%>
      </font></td>
    <td height="15"><div align="right"><font size="1">
        <%if(vMiscFeeInfo.size() > 14  && ((String)vMiscFeeInfo.elementAt(14)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(13),true)%>
        <%}%>
        </font></div></td>
    <td height="15">&nbsp;</td>
    <td height="15">BANK NAME </td>
    <td height="15"> <strong><%=WI.getStrValue(vRetResult[1].elementAt(2))%></strong></td>
  </tr>
  <tr >
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15"><font size="1">
      <%if(vMiscFeeInfo.size() > 17  && ((String)vMiscFeeInfo.elementAt(17)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(15)%>
      <%}%>
      </font></td>
    <td height="15"><div align="right"><font size="1">
        <%if(vMiscFeeInfo.size() > 17  && ((String)vMiscFeeInfo.elementAt(17)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(16),true)%>
        <%}%>
        </font></div></td>
    <td width="15%" height="15">&nbsp;</td>
    <td height="15">DATE PAID</td>
    <td height="15"><strong><%=(String)vRetResult[1].elementAt(8)%></strong></td>
  </tr>
  <tr>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15"><font size="1">
      <%if(vMiscFeeInfo.size() > 20  && ((String)vMiscFeeInfo.elementAt(20)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(18)%>
      <%}%>
      </font></td>
    <td height="15"><div align="right"><font size="1">
        <%if(vMiscFeeInfo.size() > 20  && ((String)vMiscFeeInfo.elementAt(20)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(19),true)%>
        <%}%>
        </font></div></td>
    <td height="15">&nbsp;</td>
    <td height="15">PAYMENT TYPE</td>
    <td height="15"><strong> <%=(String)vRetResult[1].elementAt(4)%></strong></td>
  </tr>
  <tr>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15"><font size="1">
      <%if(vMiscFeeInfo.size() > 23  && ((String)vMiscFeeInfo.elementAt(23)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(21)%>
      <%}%>
      </font></td>
    <td height="15"><div align="right"><font size="1">
        <%if(vMiscFeeInfo.size() > 23  && ((String)vMiscFeeInfo.elementAt(23)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(22),true)%>
        <%}%>
        </font></div></td>
    <td height="15">&nbsp;</td>
    <td height="15">CHECK #</td>
    <td height="15"> <strong><%=WI.getStrValue(vRetResult[1].elementAt(6))%></strong></td>
  </tr>
  <tr>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15"><font size="1">
      <%if(vMiscFeeInfo.size() > 26  && ((String)vMiscFeeInfo.elementAt(26)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(24)%>
      <%}%>
      </font></td>
    <td height="15"><div align="right"><font size="1">
        <%if(vMiscFeeInfo.size() > 26  && ((String)vMiscFeeInfo.elementAt(26)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(25),true)%>
        <%}%>
        </font></div></td>
    <td height="15">&nbsp;</td>
    <td height="15">REFERENCE NUMBER</td>
    <td height="15"> <strong><%=(String)vRetResult[1].elementAt(7)%></strong></td>
  </tr>
  <%
for(int i = 27; i< vMiscFeeInfo.size(); i +=2){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
		++i;
		continue;
	}
%>
  <tr>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i++)%></font></td>
    <td height="15"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i),true)%></font></div></td>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
  </tr>
  <%}%>
  <tr>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15"><strong>TOTAL MISC</strong></td>
    <td height="15"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></font></div></td>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp; </td>
  </tr>
  <%
if(fMiscOtherFee > 0f){%>
  <tr>
    <td height="15"><font size="1">&nbsp;</font></td>
    <td colspan="3"><font size="1">OTHER CHARGES</font></td>
    <td><font size="1">&nbsp;</font></td>
    <td><font size="1">&nbsp;</font></td>
    <td><font size="1">&nbsp;</font> </td>
  </tr>
  <%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		continue;
	}
	%>
  <tr>
    <td height="15"><font size="1">&nbsp;</font></td>
    <td><font size="1">&nbsp;</font></td>
    <td ><font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
    <td><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
    <td><font size="1">&nbsp;</font></td>
    <td><font size="1">&nbsp;</font></td>
    <td><font size="1">&nbsp;</font> </td>
  </tr>
  <%}%>
  <tr>
    <td height="15"><font size="1">&nbsp;</font></td>
    <td><font size="1">&nbsp;</font></td>
    <td><font size="1"><strong> OTHER CHARGE :</strong></font></td>
    <td><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%> </strong></font></div></td>
    <td><font size="1">&nbsp;</font></td>
    <td><font size="1">&nbsp;</font></td>
    <td><font size="1">&nbsp;</font> </td>
  </tr>
  <%}%>
  <tr>
    <td height="21" colspan="4"><hr size="1"></td>
    <td>&nbsp;</td>
    <td colspan="2"> (Business Office) Receipt printed by:<u>&nbsp;<%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%>&nbsp;&nbsp;</u></td>
  </tr>
  <tr>
    <td height="20" colspan="3"><strong>TOTAL ASSESSMENT :</strong></td>
    <td><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></strong></font></div></td>
    <td>&nbsp;</td>
    <td colspan="2"><div align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
  </tr>
  <tr>
    <td height="20" colspan="3"><strong>OLD ACCOUNTS :</strong></td>
    <td><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></div></td>
    <td>&nbsp;</td>
    <td colspan="2"><font size="2">&nbsp;</font></td>
  </tr>
  <tr>
    <td height="20" colspan="3"><strong>TOTAL AMOUNT DUE :</strong></td>
    <td><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding,true)%></strong></font></div></td>
    <td>&nbsp;</td>
    <td colspan="2"><font size="2"><b> <%=((String)vInstallmentDtls.elementAt(5)).toUpperCase()%> DUE: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(7),true)%></b></font> </td>
  </tr>
  <tr>
    <td height="20" colspan="3"><strong>TOTAL BALANCE DUE :</strong></td>
    <td><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTotalPayableAmt - fAmtPaidDurEnrl,true)%></strong></font></div></td>
    <td>&nbsp;</td>
    <td colspan="2"> <%
if(vInstallmentDtls != null && vInstallmentDtls.size() > 5 + 3*1) //prelim
{%> <%=((String)vInstallmentDtls.elementAt(5+3*1)).toUpperCase()%> DUE: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+3*1 +2),true)%> <%}%> </td>
  </tr>
  <%
if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*2) //prelim
{%>
  <tr>
    <td height="20" colspan="3">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2"> <%=((String)vInstallmentDtls.elementAt(5+ 3*2)).toUpperCase()%> DUE: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*2+2),true)%> </td>
  </tr>
  <%}
if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*3) //prelim
{%>
  <tr>
    <td height="20" colspan="3">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2"> <%=((String)vInstallmentDtls.elementAt(5+ 3*3)).toUpperCase()%> DUE: <%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*3+2),true)%> </td>
  </tr>
  <%}%>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(strSchoolCode.startsWith("VMUF")){%>
  <tr >
    <td height="20" colspan="4" >&nbsp;</td>
  </tr>
  <tr >
    <td width="25%" height="25" valign="bottom" > <div align="left">______________________________</div></td>
    <td width="27%" valign="bottom" > <div align="left">_______________________________</div></td>
    <td width="26%" valign="bottom" > <div align="left">______________________________</div></td>
    <td width="22%" valign="bottom" >______________________________</td>
  </tr>
  <tr >
    <td height="25" valign="top" >&nbsp;&nbsp;&nbsp;(Office of Student's Affairs)</td>
    <td valign="top" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Clinic)</td>
    <td valign="top" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Library)</td>
    <td valign="top" ><div align="center">(Internet)</div></td>
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
 <%}%>
  <tr >
    <td height="10" colspan="2" >Student load verified &amp; confirmed by :</td>
    <td colspan="2" valign="bottom" >&nbsp;</td>
  </tr>
  <tr >
    <td height="10" ><div align="left">&nbsp;</div></td>
    <td ><em></em></td>
    <td colspan="2" >&nbsp;</td>
  </tr>
  <tr >
    <td height="10" ><div align="left">&nbsp;</div></td>
    <td ><em><strong>Registrar</strong></em></td>
    <td colspan="2" >&nbsp;</td>
  </tr>
<%if(!strSchoolCode.startsWith("UI")){%>
  <tr >
    <td height="10" colspan="4" ><strong>NOTE: Total fee charges may change when
      adjustments are implemented. </strong></td>
  </tr>
<%}%>
</table>
<%if(false && strSchoolCode.startsWith("UI")){%>
<table width="100%" cellpadding="0" cellspacing="0" class="thinborderALL">
  <tr>
    <td height="25" colspan="4" align="center"><font size="2">
      <u>
        <strong>CONTRACT OF ENROLMENT </strong>
      </u>
      </font> </td>
  </tr>
  <tr>
    <td colspan="4"> In consideration of my enrolment at the University of Iloilo,
      I agree to abide by the rules provided for in paragraph 137 of the Manual
      of Regulations for Private Schools, Seventh Edition quoted hereunder, to
      wit: </td>
  </tr>
  <tr>
    <td width="5%">&nbsp;</td>
    <td colspan="2"><div align="justify">&#8220;When a student register in a school,
        it is understood that he/she is enrolling for the entire school year for
        elementary and secondary courses and for the entire semester for collegiate
        courses. A student who transfer or otherwise withdraws, in writing, within
        two weeks after the beginning of classes, maybe charged ten percent of
        the total amount due for the term if he/she withdraws within the first
        week of classes or twenty percent if within the second week of classes,
        regardless of whether or not he/she has actually attended classes. The
        student maybe charged all the school fees in full if he/she withdraws
        anytime after the second week of classes. However, if the transfer or
        withdrawal is due to a justifiable reason, the student shall be charged
        the pertinent fees only up to and including the last month of attendance.
        Miscellaneous fees are not refundable.&#8221;</div></td>
    <td width="4%">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="4">and the rules an regulations embodied in the Student&#8217;s
      Handbook and such others as maybe issued by the University regarding the
      discipline and good behavior of the students.</td>
  </tr>
  <tr>
    <td colspan="4" width="10">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td width="73%">___________________<br>
      Student's Signature</td>
    <td width="18%">Date : <%=WI.getTodaysDate(1)%></td>
    <td>&nbsp;</td>
  </tr>
</table>
<table cellpadding="0" cellspacing="0" width="100%">
<tr >
    <td height="10" colspan="4" ><strong>NOTE: Total fee charges may change when
      adjustments are implemented. </strong></td>
  </tr>
</table>

<%}//show only for UI.

		}//if payment detail and payment mode not null;
	}//if student information exists.
}//if miscellaneous fee information exists.
dbOP.cleanUP();
%>
<script language="JavaScript">
	window.print();
</script>
</body>
</html>
