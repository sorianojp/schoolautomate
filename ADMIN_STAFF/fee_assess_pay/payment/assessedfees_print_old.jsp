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
-->
</style>
</head>

<body>
<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	strSchoolCode = WI.getStrValue(strSchoolCode);

	String strErrMsg = null;
	String strTemp = null;
	String strSubSecIndex = null;
	String strDegreeType  = null;

	Vector vLabSched      = null;

	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

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
astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)//db error
{
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=dbOP.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}
Vector vStudInfo = null;
Vector vMiscFeeInfo = null;
Vector vTemp = null;

float fTutionFee  		= 0f;
float fCompLabFee 		= 0f;
float fMiscFee    		= 0f;
float fOutstanding     	= 0f;
float fTotalPayableAmt 	= 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,

String 	strCollegeName 	= null;

boolean bolShowReceiptHeading = false;

float fEnrollmentDiscount = 0f; //this sum of full payment, early enrollment or late enrollment discount/fine implementations.
String strEnrolmentDiscDetail = null;
float fPayableAfterDiscount = 0f;


SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
Advising advising = new Advising();

Vector vAssessedSubDetail = null;

vStudInfo = advising.getStudInfo(dbOP,request.getParameter("stud_id"));
if(vStudInfo == null) strErrMsg = advising.getErrMsg();
else
{
	astrSchYrInfo[0]=(String)vStudInfo.elementAt(16);//take sy from/to/sem from student registration information.
	astrSchYrInfo[1]=(String)vStudInfo.elementAt(17);
	astrSchYrInfo[2]=(String)vStudInfo.elementAt(18);

	paymentUtil.setTempUser((String)vStudInfo.elementAt(10));
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(2),
        (String)vStudInfo.elementAt(3),(String)vStudInfo.elementAt(6),
        astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);

	strCollegeName = new CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(2));
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
}
if(strErrMsg == null) //collect fee details here.
{
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
	if(fTutionFee > 0)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
							astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
		fOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));

		fMiscOtherFee = fOperation.getMiscOtherFee();

		enrollment.FAFeeOperationDiscountEnrollment test =
				new enrollment.FAFeeOperationDiscountEnrollment(false,null);
		vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],
                                        (String)vStudInfo.elementAt(6),astrSchYrInfo[2],
                                        fOperation.dReqSubAmt);

		if(vTemp != null && vTemp.size() > 0)
			strEnrolmentDiscDetail = (String)vTemp.elementAt(0);//System.out.println(vTemp);//System.out.println(strEnrolmentDiscDetail);
		if(strEnrolmentDiscDetail != null && vTemp != null && vTemp.size() > 0)
		{
			fEnrollmentDiscount = ((Float)vTemp.elementAt(1)).floatValue();
			fPayableAfterDiscount = fTutionFee+fMiscFee+fCompLabFee+fOutstanding-fEnrollmentDiscount;
		}

		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(2), "degree_type"," and is_valid=1 and is_del=0");
		vAssessedSubDetail = FA.getAssessedSubDetail(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2],strDegreeType);
		if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0)
			strErrMsg = FA.getErrMsg();
	}
	else
		strErrMsg = fOperation.getErrMsg();
}
//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null )
{
	if(fMiscFee > 0.1f) {
		vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
						astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		if(vTemp == null)
			strErrMsg = paymentUtil.getErrMsg();
		else
			vMiscFeeInfo.addAll(vTemp);
	}

	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");
	}

}
if(fMiscFee <=0.1f) {
	vMiscFeeInfo = new Vector();
	vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");
}


//for re-enrollment schemes.
  boolean bolIsOnlyReEnrollment = false;
  if(vStudInfo != null && vStudInfo.size() > 0) {
	  	bolIsOnlyReEnrollment = CommonUtil.isOnlyReEnrollmentStud(dbOP, (String)vStudInfo.elementAt(0),
  										astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
  }


if(!bolShowReceiptHeading) { //forced to enter ;-)
	enrollment.ReadPropertyFileImpl readPropFileImpl = new enrollment.ReadPropertyFileImpl();
	int iRetValue = readPropFileImpl.showReceiptHeading();
	if(iRetValue == -1)
		strErrMsg = readPropFileImpl.getErrMsg();
	else if(iRetValue == 1)
		bolShowReceiptHeading = true;
}
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
          <%=strCollegeName%></div></td>
    </tr>
<%}%>
    <tr >
      <td height="20" ><div align="center"><strong>OFFICIAL ENROLMENT SHEET</strong><br>
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
    <td><strong><font size="2"><%=request.getParameter("stud_id")%></font></strong></td>
    <td>Course/Major</td>
    <td colspan="2"><strong><%=(String)vStudInfo.elementAt(7)%>
      <%if(vStudInfo.elementAt(8) != null){%>
      / <%=WI.getStrValue(vStudInfo.elementAt(8))%>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="18" width="11%" >Student Name </td>
    <td width="35%"><strong><font size="2"><%=(String)vStudInfo.elementAt(1)%></font></strong></td>
    <td width="13%" height="18">Year Level</td>
    <td width="20%"><strong><%=WI.getStrValue(vStudInfo.elementAt(6),"N/A")%></strong></td>
    <td width="16%">Gender :<strong> <%=WI.getStrValue(vStudInfo.elementAt(19),"")%></strong></td>
  </tr>
  <%if(!strSchoolCode.startsWith("UI")){%>
  <tr>
    <td height="18">Student's Signature</td>
    <td height="18">____________________________________</td>
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
      <td width="10%" height="18" class="thinborder"><div align="center"><strong>SUBJECT CODE </strong></div></td>
      <td width="26%" height="19" class="thinborder"><div align="center"><strong>SUBJECT TITLE </strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>SCHEDULE</strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>SECTION/ROOM #</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>LEC/LAB UNITS </strong></div></td>
<%
if(!strSchoolCode.startsWith("UI")) {%>
      <td width="5%" class="thinborder"><div align="center"><strong>TOTAL UNITS</strong></div></td>
<%}%>
      <td width="5%" class="thinborder"><div align="center"><strong>UNITS TAKEN</strong></div></td>
<%
if(strSchoolCode.startsWith("UI") && fOperation.vAssessedHrDetail != null &&
		fOperation.vAssessedHrDetail.size() > 0) {%>
      <td width="5%" class="thinborder"><div align="center"><strong>ASSESSED HRS</strong></div></td>
<%}%>
      <td width="6%" class="thinborder"><div align="center"><strong>RATE/UNIT</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>TOTAL SUBJECT FEE </strong></div></td>
    </tr>
<%

	float fTotalLoad = 0;float fUnitsTaken = 0f;
	int iIndex = 0;
//	float fTotalSubFee = 0;
	float fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.

	String strOfferingDur = null;//this is for caregiver and other times schedule with offering_dur;-)

String strSchedule = null;
String strRoomAndSection = null;
String strLecLabStat = null;//0 = both,1 = lab, 2 = lec.
	String strRatePerUnit = null;String strSubTotalRate = null;
	String strAssessedHour = null;//only if it is UI and the assessment is per hour.
	Vector vSubSecDtls = new Vector();
	String strFeeTypeCatg = null; //0=>per unit,1= per lec/lab, 2=per subject,3=total tuition fee.

	float fNSTPUNIT  = 1.5f;

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
			if(((String)vAssessedSubDetail.elementAt(i+1)).indexOf("NSTP") != -1)
				fSubTotalRate = fNSTPUNIT * Float.parseFloat(strRatePerUnit);//units taken
			else
				fSubTotalRate = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+9)) * Float.parseFloat(strRatePerUnit);//units taken
		}
		//else
		else if(strFeeTypeCatg.compareTo("1") ==0)//per unit
		{
			strRatePerUnit = (String)vAssessedSubDetail.elementAt(i+6) +"/lec "+(String)vAssessedSubDetail.elementAt(i+7)+"/lab";
			if(((String)vAssessedSubDetail.elementAt(i+1)).indexOf("NSTP") != -1)
				fSubTotalRate = fNSTPUNIT * Float.parseFloat(strRatePerUnit);//units taken
			else
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

		strOfferingDur = WI.getStrValue(dbOP.mapOneToOther("E_SUB_SECTION","SUB_SEC_INDEX",strSubSecIndex,"offering_dur",null));

		if(strOfferingDur.length()> 0)
			strOfferingDur += "<br>";
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
			if(strLecLabStat != null && strLecLabStat.compareTo("1") == 0){//lab only.
				strRoomAndSection = (String)vSubSecDtls.elementAt(b);
				//System.out.println("Printing xx:::"+(String)vSubSecDtls.elementAt(b));
				b += 2;
				continue;
			}

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
		    strSchedule = WI.getStrValue(strSchedule) + "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
			strRoomAndSection = WI.getStrValue(strRoomAndSection) + "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
%>
    <tr >
    <td height="19" class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+2)%></td>
    <td class="thinborder"><%=WI.getStrValue(WI.getStrValue(strOfferingDur)+WI.getStrValue(strSchedule),"N/A")%></td>
    <td class="thinborder"><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+3)%>/<%=(String)vAssessedSubDetail.elementAt(i+4)%></td>
<%
if(!strSchoolCode.startsWith("UI")) {%>
    <td class="thinborder"><%=fTotalUnit%></td>
<%}%>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+9)%></td>
<%
if(strSchoolCode.startsWith("UI") && fOperation.vAssessedHrDetail != null &&
		fOperation.vAssessedHrDetail.size() > 0) {%>
<td class="thinborder"><%=strAssessedHour%></td>
<%}%>
    <td class="thinborder"><%=strRatePerUnit%></td>
    <td class="thinborder"><%=strSubTotalRate%></td>
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
        TOTAL LOAD UNITS : <strong><!--<%=fTotalLoad%>/--><%=fUnitsTaken%></strong>
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
	Vector[] vRetResult = faPayment.viewTutionFeePaymentDetail(dbOP,(String)vStudInfo.elementAt(0),astrSchYrInfo[0],
							astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2],paymentUtil.isTempStudInStr(), "0");

	if(vRetResult == null)
	{
	strErrMsg = faPayment.getErrMsg();%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td align="center"><strong><font size="2"><br><%=strErrMsg%></font></strong></td>
  </tr>
</table>
<%}else{
//if paymetn is full, then check for discount, if it is not full, there will be no discount.
if(((String)vRetResult[0].elementAt(3)).compareToIgnoreCase("full") != 0)
{
//	strEnrolmentDiscDetail = null;
//	fEnrollmentDiscount  = 0f;
}	%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td colspan="4"><div align="center"><strong>:: FEE DETAILS ::</strong></div></td>
    <td height="14" colspan="3"><div align="center"><strong>:: PAYMENT DETAILS
        ::</strong></div></td>
  </tr>
  <tr >
    <td height="15" colspan="3">TUITION FEE<strong><font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%> </font></strong></td>
    <td width="13%" height="15"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></font></div></td>
    <td height="15">&nbsp;</td>
    <td width="24%" height="15">PAYEE TYPE</td>
    <td width="21%" height="15"><strong><%=(String)vRetResult[0].elementAt(1)%></strong></td>
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
    <td width="27%" height="15"><font size="1"><%=(String)vMiscFeeInfo.elementAt(0)%></font></td>
    <td height="15"><div align="right"><font size="1">
        <%if(vMiscFeeInfo.size() > 1 && ((String)vMiscFeeInfo.elementAt(0)).length() > 0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(1),true)%>
        <%}%>
        </font></div></td>
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
    <td height="15"><div align="right"><font size="1">
        <%if(vMiscFeeInfo.size() > 5 && ((String)vMiscFeeInfo.elementAt(5)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(4),true)%>
        <%}%>
        </font></div></td>
    <td height="15">&nbsp;</td>
    <td height="15">AMOUNT PAID<font size="1">
      <%if(strEnrolmentDiscDetail != null){%>
      (<%=strEnrolmentDiscDetail%>)
      <%}%>
      </font></td>
    <td height="15"><strong><%=CommonUtil.formatFloat((String)vRetResult[1].elementAt(5),true)%></strong></td>
  </tr>
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
    <td width="13%" height="15">&nbsp;</td>
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
	}%>
  <tr>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i++)%> </font></td>
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
    <td height="15" colspan="2">
	<%if(bolIsOnlyReEnrollment){%><br><br><%}%>
      (Business Office) Receipt printed by:<u>&nbsp;<%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%>&nbsp;&nbsp;</u> </td>
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
    <td height="19" colspan="4"><hr size="1"></td>
    <td>&nbsp;</td>
    <td colspan="2"> <div align="center"></div></td>
  </tr>
  <tr>
    <td height="20" colspan="3"><strong>TOTAL ASSESSMENT :</strong></td>
    <td><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></strong></font></div></td>
    <td>&nbsp;</td>
    <td colspan="2"><div align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
  </tr>
  <%
  int iInstalCount = 0;

  Vector vExamScheduleName = new Vector();
  enrollment.FAPmtMaintenance pmtM = new enrollment.FAPmtMaintenance();//new way of computation.
  vTemp = pmtM.getPmtSchIndexForSpecificSYorCourse(dbOP,(String)vStudInfo.elementAt(0),
  					astrSchYrInfo[0], astrSchYrInfo[2],paymentUtil.isTempStud());
  if(vTemp != null && vTemp.size() > 0) {
  	iInstalCount = vTemp.size();
	for(int i = 0; i < vTemp.size(); ++i)
		vExamScheduleName.addElement(dbOP.mapOneToOther("FA_PMT_SCHEDULE","pmt_sch_index",
				(String)vTemp.elementAt(i),"EXAM_NAME",null));
  }

 fTotalPayableAmt = fTutionFee+fCompLabFee+fMiscFee + fOutstanding - fEnrollmentDiscount;
 float fAmtPaidDurEnrl = Float.parseFloat((String)vRetResult[1].elementAt(5));
 float fFirstInstalAmt = 0f;
 float fInstalmentAmt = 0f;//installment amt after 1st installment.
 int iEnrlSetting      = FA.getEnrollemntInstallmentSetting();

 if(iInstalCount == 0) {
  iInstalCount      = FA.getNoOfInstallment(dbOP,astrSchYrInfo[0],astrSchYrInfo[1],
 								astrSchYrInfo[2]);
  vExamScheduleName = FA.getInstallmentName(dbOP,astrSchYrInfo[0],astrSchYrInfo[1],
	 							astrSchYrInfo[2]);
 }//System.out.println(vExamScheduleName);System.out.println(iInstalCount);
 if(iEnrlSetting ==0) {//1= (total due-first payment)/iInstalCount, 0=total due/iInstallCount - first installment.
 	fInstalmentAmt = fTotalPayableAmt/iInstalCount;
	fFirstInstalAmt =  fInstalmentAmt - fAmtPaidDurEnrl;
/**	if(fFirstInstalAmt < 0f && iInstalCount > 1)
		fInstalmentAmt += fFirstInstalAmt/(iInstalCount - 1);

	if(fFirstInstalAmt < 0f)
		fFirstInstalAmt = 0f;
	if(fInstalmentAmt <0f)
		fInstalmentAmt = 0f;**/
 }
 else if(iEnrlSetting == 1) {//LNU
 	fFirstInstalAmt = (fTotalPayableAmt - fAmtPaidDurEnrl)/iInstalCount;
	fInstalmentAmt = fFirstInstalAmt;
 }
 else if(iEnrlSetting == 2) {//UI
	enrollment.FAStudMinReqDP fMinDP = new enrollment.FAStudMinReqDP(dbOP);
    double dReqdDP = fMinDP.getPayableDownPayment(dbOP, WI.fillTextValue("stud_id"),
							astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]); //gets the required d/p.

    fInstalmentAmt = (fTotalPayableAmt - fOutstanding - (float) dReqdDP) / iInstalCount;
	fFirstInstalAmt = fOutstanding + (float) dReqdDP - fAmtPaidDurEnrl + fInstalmentAmt;
 }
 %>
  <tr>
    <td height="20" colspan="3"><strong>OLD ACCOUNTS :</strong></td>
    <td><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></div></td>
    <td>&nbsp;</td>
    <td colspan="2">

	<%if(!bolIsOnlyReEnrollment){//only if re-enrollement.%>

	<font size="2"><b>PRELIM EXAMINATION DUE:
      <%if(fFirstInstalAmt < 0f){%>
      0.00
      <%}else{%>
      <%=CommonUtil.formatFloat(fFirstInstalAmt,true)%>
      <%}%>
      </b></font><%}//print only if not only re-enrollment.%></td>
  </tr>
  <tr>
    <td height="20" colspan="3"><strong>TOTAL AMOUNT DUE :</strong></td>
    <td><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding,true)%></strong></font></div></td>
    <td>&nbsp;</td>
    <td colspan="2"> <%
if(iInstalCount > 1 && !bolIsOnlyReEnrollment) //midterm -- for rule refere FA.getInstallmentPayablePerStudent line number 855
{%> <%=((String)vExamScheduleName.elementAt(1)).toUpperCase()%> Due:
      <%if(fFirstInstalAmt < 0f) {
	if((2*fInstalmentAmt - fAmtPaidDurEnrl) < 0f){%>
      0.00
      <%}else if( (2*fInstalmentAmt - fAmtPaidDurEnrl) > fInstalmentAmt){%> <%=CommonUtil.formatFloat(fInstalmentAmt,true)%>
      <%}else{%> <%=CommonUtil.formatFloat(2*fInstalmentAmt - fAmtPaidDurEnrl,true)%> <%}
}else{%> <%=CommonUtil.formatFloat(fInstalmentAmt,true)%> <%}
}%> </td>
  </tr>
  <tr>
    <td height="20" colspan="3"><strong>TOTAL BALANCE DUE :</strong></td>
    <td><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTotalPayableAmt - fAmtPaidDurEnrl ,true)%></strong></font></div></td>
    <td>&nbsp;</td>
    <td colspan="2"> <%
if(iInstalCount > 2 && !bolIsOnlyReEnrollment) //prelim
{%> <%=((String)vExamScheduleName.elementAt(2)).toUpperCase()%> DUE:
      <%if(fFirstInstalAmt < 0f) {
	if((3*fInstalmentAmt - fAmtPaidDurEnrl) < 0f){%>
      0.00
      <%}else if( (3*fInstalmentAmt - fAmtPaidDurEnrl) > fInstalmentAmt){%> <%=CommonUtil.formatFloat(fInstalmentAmt,true)%>
      <%}else{%> <%=CommonUtil.formatFloat(3*fInstalmentAmt - fAmtPaidDurEnrl,true)%> <%}
}else{%> <%=CommonUtil.formatFloat(fInstalmentAmt,true)%> <%}
	 }%> </td>
  </tr>
  <%if(iInstalCount > 3 && !bolIsOnlyReEnrollment) //prelim
{%>
  <tr>
    <td height="20" colspan="3">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2"><%=((String)vExamScheduleName.elementAt(3)).toUpperCase()%> DUE:
      <%if(fFirstInstalAmt < 0f){
	if((4*fInstalmentAmt - fAmtPaidDurEnrl) < 0f){%>
      0.00
      <%}else if( (4*fInstalmentAmt - fAmtPaidDurEnrl) > fInstalmentAmt){%> <%=CommonUtil.formatFloat(fInstalmentAmt,true)%>
      <%}else{%> <%=CommonUtil.formatFloat(4*fInstalmentAmt - fAmtPaidDurEnrl,true)%> <%}
}else{%> <%=CommonUtil.formatFloat(fInstalmentAmt,true)%> <%}%> </td>
  </tr>
  <%}%>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%//System.out.println(strSchoolCode);
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
    <td width="25%" height="25" valign="bottom" ></td>
    <td width="27%" valign="bottom" ></td>
    <td width="26%" valign="bottom" align="right">_______</td>
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
    <td colspan="2" valign="bottom" >
	<%if(paymentUtil.isTempStud()){%>
	PERMANENT STUDENT ID : ______________________________<%}%></td>
  </tr>
  <tr >
    <td height="10" ><div align="left"></div></td>
    <td height="10" ><em><strong>Registrar</strong></em></td>
    <td colspan="2" >
	<%if(paymentUtil.isTempStud()){%>
	Write student permanent ID after confirming enrolment (new student only)<%}%></td>
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
        <strong>CONTRACT OF ENROLMENT</strong>
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
    <td colspan="4">&nbsp;</td>
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

if(strErrMsg == null && request.getParameter("view_status") != null && request.getParameter("view_status").compareTo("0") == 0 ){%>
<script language="JavaScript">
	window.print();
</script>
<%}%>
</body>
</html>
