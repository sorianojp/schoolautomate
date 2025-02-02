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
	String strLHSTDColor  = "";//for view it is  bgcolor="#D2D6C0"
	String strRHSTDColor  = ""; //for view it is  bgcolor="#E9EADF"

	String strDegreeType  = null;
	boolean bolPrint = true;
	if(WI.fillTextValue("view_status").compareTo("1") == 0)
	{
		bolPrint = false;
		strLHSTDColor = " bgcolor=#D2D6C0 ";
		strRHSTDColor = " bgcolor=#E9EADF ";
	}

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

Vector vStudInfo = null;
Vector vMiscFeeInfo = null;
Vector vTemp = null;
Vector vORInfo = null;
Vector vInstallmentDtls = null;

float fTutionFee        = 0f;
float fCompLabFee       = 0f;
float fMiscFee          = 0f;
float fOutstanding      = 0f;
float fTotalPayableAmt 	= 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,

String 	strCollegeName = null;

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
Advising advising = new Advising();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

Vector vAssessedSubDetail = null;

if(strORNumber.length() == 0)
{
		strORNumber = paymentUtil.getORNumberOfDownpayment(dbOP, WI.fillTextValue("stud_id"));
		if(strORNumber == null)
			strErrMsg = paymentUtil.getErrMsg();
}

if(strORNumber == null || strORNumber.length() ==0)
{
	if(strErrMsg == null || strErrMsg.trim().length() ==0)
		strErrMsg = "OR Number can't be empty.";
%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=strErrMsg%></font></p>
		<%
	dbOP.cleanUP();
	return;
}



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
if(vStudInfo == null) {
 	//I have to check if this is called for a temp stud...
	strErrMsg = enrlStudInfo.getErrMsg();
}
else
{
	astrSchYrInfo[0] = (String)vORInfo.elementAt(23);
	astrSchYrInfo[1] = (String)vORInfo.elementAt(24);
	astrSchYrInfo[2] = (String)vORInfo.elementAt(22);

	paymentUtil.setTempUser("0");
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),	(String)vStudInfo.elementAt(4),
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
		if(!paymentUtil.isTempStud()) {
			double dLedgHistoryExcess = fOperation.calLedgHistoryEntryAfterASYTerm(dbOP, (String)vStudInfo.elementAt(0), 
            	                                         (String)vORInfo.elementAt(23), (String)vORInfo.elementAt(22));
			if(dLedgHistoryExcess != fOperation.fDefaultErrorValue) 
				fOutstanding -= (float)dLedgHistoryExcess;
		}

		fMiscOtherFee = fOperation.getMiscOtherFee();

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
if(strErrMsg == null && fMiscFee > 0.1f)
{
	vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
	if(vTemp == null)
		strErrMsg = paymentUtil.getErrMsg();
	else
		vMiscFeeInfo.addAll(vTemp);

	//add here the laboratory deposit if there is any.
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



if(strErrMsg == null)//get installment details.
{
	vInstallmentDtls = FA.getInstallmentPayablePerStudent(dbOP,(String)vStudInfo.elementAt(0),
                                (String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22)) ;
	if(vInstallmentDtls == null)
		strErrMsg = FA.getErrMsg();
}
//boolean bolShowReceiptHeading = false;
boolean bolShowReceiptHeading = true;
if(!bolShowReceiptHeading) { //forced to enter ;-)
	enrollment.ReadPropertyFileImpl readPropFileImpl = new enrollment.ReadPropertyFileImpl();
	int iRetValue = readPropFileImpl.showReceiptHeading();
	if(iRetValue == -1)
		strErrMsg = readPropFileImpl.getErrMsg();
	else if(iRetValue == 1)
		bolShowReceiptHeading = true;
}
%>
<form name="print_receipt">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25"><div align="center">
<%if(bolShowReceiptHeading){%>
	  <font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%><br>
<%}%>        <br>
          <%=strCollegeName%></div></td>
    </tr>
    <tr >
      <td height="20" ><div align="center"><strong>STUDENT ASSESSMENT SLIP</strong><br>
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
    <td><strong><%=(String)vORInfo.elementAt(25)%></strong></td>
    <td>Course/Major</td>
    <td colspan="2"><strong><%=(String)vStudInfo.elementAt(2)%>
      <%if(vStudInfo.elementAt(6) != null){%>
      / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="18" width="11%">Student Name </td>
    <td width="35%"><strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    <td width="13%">Year/Term</td>
    <td width="26%"><strong><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%> / <%=astrConvertSem[Integer.parseInt((String)vORInfo.elementAt(22))]%></strong></td>
    <td width="15%">Gender : <strong><%=WI.getStrValue(vStudInfo.elementAt(13),"")%></strong></td>
  </tr>
</table>
<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0)
{
	if(bolPrint)//remove the table.
		{%>
	<%="<!--"%>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr >
      <td width="10%" height="18" class="thinborder"><div align="center"><strong>SUBJECT CODE </strong></div></td>
      <td width="26%" height="19" class="thinborder"><div align="center"><strong>SUBJECT TITLE </strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>SCHEDULE</strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>SECTION/ROOM #</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>LEC/LAB UNITS </strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>TOTAL UNITS</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>UNITS TAKEN</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>RATE/UNIT</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>TOTAL SUBJECT FEE </strong></div></td>
    </tr>
<%
	int iIndex = 0;
	String strSubTotalRate = null;

 	float fFirstInstalAmt = 0f;
	float fTotalLoad = 0;float fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	float fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.
String strSchedule = null;
String strRoomAndSection = null;
String strLecLabStat = null;//0 = both,1 = lab, 2 = lec.
	String strRatePerUnit = null;
	Vector vSubSecDtls = new Vector();
	String strFeeTypeCatg = null; //0=>per unit,1= per lec/lab, 2=per subject,3=total tuition fee.


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
		}
		else {
			strRatePerUnit = "0.00";
			strSubTotalRate  = "0.00";
		}

		strLecLabStat  = dbOP.mapOneToOther("enrl_final_cur_list","sub_sec_index",strSubSecIndex, "IS_ONLY_LAB",
			" and enrl_final_cur_list.is_valid = 1 and enrl_final_cur_list.is_del = 0 and user_index = "+
			(String)vStudInfo.elementAt(0)+" and IS_TEMP_STUD = "+paymentUtil.isTempStudInStr());

		//get schedule here.
		vSubSecDtls = SS.getRoomScheduleDetailInMWF(dbOP, strSubSecIndex);
		vLabSched   = SS.getLabSched(dbOP,strSubSecIndex);
		if(vSubSecDtls == null || vSubSecDtls.size() ==0)
		{
			strErrMsg = SS.getErrMsg();
			break;
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
    <td class="thinborder"><%=strSchedule%></td>
    <td class="thinborder"><%=strRoomAndSection%></td>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+3)%>/<%=(String)vAssessedSubDetail.elementAt(i+4)%></td>
    <td class="thinborder"><%=fTotalUnit%></td>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+9)%></td>
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
        TOTAL LOAD UNITS : <strong><%=fTotalLoad%>/<%=fUnitsTaken%></strong>
        <%}%>
      </div></td>
    </tr>
  </table>
 <%
 if(bolPrint){//remove the table.
		%>
	<%="-->"%>
<br><strong>TOTAL LOAD UNITS :</strong><strong><%=fUnitsTaken%></strong>
<%} //only if it is for printing.

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
<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td colspan="4"><div align="center"><strong>:: FEE DETAILS ::</strong></div></td>
      <td height="14" colspan="3"><div align="center"><strong>:: PAYMENT DETAILS
          ::</strong></div></td>
    </tr>
    <tr >
      <td height="15" colspan="3">TUITION FEE<strong><font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%>
        </font></strong> </td>
      <td width="18%" height="15"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></font></td>
      <td height="15">&nbsp;</td>
      <td width="22%" height="15">PAYEE TYPE</td>
      <td width="29%" height="15"><strong><%=(String)vRetResult[0].elementAt(1)%></strong></td>
    </tr>
    <tr >
      <td height="15" colspan="3">COMP. LAB. FEE</td>
      <td height="15"><font size="1"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></font></td>
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
      <td height="15"><font size="1">
        <%if(vMiscFeeInfo.size() > 1){%>
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
      <td height="15"><font size="1">
        <%if(vMiscFeeInfo.size() > 5 && ((String)vMiscFeeInfo.elementAt(5)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(4),true)%>
        <%}%>
        </font></td>
      <td height="15">&nbsp;</td>
      <td height="15">AMOUNT PAID</td>
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
      <td height="15"><font size="1">
        <%if(vMiscFeeInfo.size() > 8 && ((String)vMiscFeeInfo.elementAt(8)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(7),true)%>
        <%}%>
        </font></td>
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
      <td height="15"><font size="1">
        <%if(vMiscFeeInfo.size() > 11  && ((String)vMiscFeeInfo.elementAt(11)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(10),true)%>
        <%}%>
        </font></td>
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
      <td height="15"><font size="1">
        <%if(vMiscFeeInfo.size() > 14  && ((String)vMiscFeeInfo.elementAt(14)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(13),true)%>
        <%}%>
        </font></td>
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
      <td height="15"><font size="1">
        <%if(vMiscFeeInfo.size() > 17  && ((String)vMiscFeeInfo.elementAt(17)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(16),true)%>
        <%}%>
        </font></td>
      <td width="9%" height="15">&nbsp;</td>
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
      <td height="15"><font size="1">
        <%if(vMiscFeeInfo.size() > 20  && ((String)vMiscFeeInfo.elementAt(20)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(19),true)%>
        <%}%>
        </font></td>
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
      <td height="15"><font size="1">
        <%if(vMiscFeeInfo.size() > 23  && ((String)vMiscFeeInfo.elementAt(23)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(22),true)%>
        <%}%>
        </font></td>
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
      <td height="15"><font size="1">
        <%if(vMiscFeeInfo.size() > 26  && ((String)vMiscFeeInfo.elementAt(26)).compareTo("0") ==0){%>
        <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(25),true)%>
        <%}%>
        </font></td>
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
      <td height="15"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i++)%></font></td>
      <td height="15"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i),true)%></font></td>
      <td height="15">&nbsp;</td>
      <td height="15">&nbsp;</td>
      <td height="15">&nbsp;</td>
    </tr>
    <%}%>
    <tr>
      <td height="15">&nbsp;</td>
      <td height="15">&nbsp;</td>
      <td height="15"><strong>TOTAL MISC</strong></td>
      <td height="15"><font size="1"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></font></td>
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
      <td><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font> </td>
    </tr>
<%}%>
    <tr>
      <td height="15"><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1"><strong> OTHER CHARGE :</strong></font></td>
      <td><font size="1"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%> </strong></font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font> </td>
    </tr>
<%}%>
    <tr>
      <td height="21" colspan="4"><hr size="1"></td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="20" colspan="3"><strong>TOTAL ASSESSMENT :</strong></td>
      <td><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></strong></font></td>
      <td>&nbsp;</td>
      <td>
        <%
	  if(vInstallmentDtls != null && vInstallmentDtls.size() > 5) //prelim
	  {%>
        Amount due this <%=((String)vInstallmentDtls.elementAt(5)).toUpperCase()%>
      </td>
      <td><%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(7),true)%>
        <%}%>
      </td>
    </tr>
    <tr>
      <td height="20" colspan="3"><strong>OLD ACCOUNTS :</strong></td>
      <td><font size="1"><strong>Php <%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></td>
      <td>&nbsp;</td>
      <td>
        <%
	  if(vInstallmentDtls != null && vInstallmentDtls.size() > 5 + 3*1) //prelim
	  {%>
        Amount due this <%=((String)vInstallmentDtls.elementAt(5+3*1)).toUpperCase()%>
      </td>
      <td><%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+3*1 +2),true)%>
        <%}%>
      </td>
    </tr>
    <%
 fTotalPayableAmt = fTutionFee+fCompLabFee+fMiscFee + fOutstanding ;
 float fAmtPaidDurEnrl = Float.parseFloat((String)vRetResult[1].elementAt(5));
 float fFirstInstalAmt = 0f;
 int iEnrlSetting      = FA.getEnrollemntInstallmentSetting();
 int iInstalCount      = FA.getNoOfInstallment(dbOP,(String)vORInfo.elementAt(23),
 						(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
 if(iEnrlSetting ==0)//1= (total due-first payment)/iInstalCount, 0=total due/iInstallCount - first installment.
 	fFirstInstalAmt = fTotalPayableAmt/iInstalCount - fAmtPaidDurEnrl;
 else
 	fFirstInstalAmt = (fTotalPayableAmt - fAmtPaidDurEnrl)/iInstalCount;
//System.out.println(iInstalCount);

 %>
    <tr>
      <td height="20" colspan="3"><strong>TOTAL AMOUNT DUE :</strong></td>
      <td><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding,true)%></strong></font></td>
      <td>&nbsp;</td>
      <td>
        <%
	  if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*2) //prelim
	  {%>
        Amount due this <%=((String)vInstallmentDtls.elementAt(5+ 3*2)).toUpperCase()%>
      </td>
      <td><%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*2+2),true)%>
        <%}%>
      </td>
    </tr>
    <tr>
      <td height="20" colspan="3"><strong>TOTAL BALANCE DUE :</strong></td>
      <td><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTotalPayableAmt - fAmtPaidDurEnrl,true)%></strong></font></td>
      <td>&nbsp;</td>
      <td>
        <%
	  if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*3) //prelim
	  {%>
        Amount due this <%=((String)vInstallmentDtls.elementAt(5+ 3*3)).toUpperCase()%>
      </td>
      <td><%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*3+2),true)%>
        <%}%>
      </td>
    </tr>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#FFFFFF" >
    <td height="20" colspan="4" ><font color="#000000">&nbsp;</font></td>
  </tr>
  <tr bgcolor="#FFFFFF" >
    <td height="25" colspan="2" ><font color="#000000">&nbsp;</font></td>
    <td height="25" ><div align="left"><font color="#000000">Assessment printed
        by:</font></div></td>
    <td height="25" ><font color="#000000"><u>&nbsp;<%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%>&nbsp;&nbsp;</u></font></td>
  </tr>
  <tr bgcolor="#FFFFFF" >
    <td width="24%" height="25" ><font color="#000000">&nbsp;</font></td>
    <td width="25%" height="25" ><font color="#000000">&nbsp;</font></td>
    <td width="15%" height="25" ><div align="center"><font color="#000000"></font></div></td>
    <td width="36%" height="25" ><font color="#000000"><em>Assessment In-charge</em></font></td>
  </tr>
  <tr bgcolor="#FFFFFF" >
    <td height="25" colspan="4" >&nbsp;</td>
  </tr>
  <tr bgcolor="#FFFFFF" >
    <td height="25" colspan="4" ><font color="#000000"><strong>NOTE: Total fee
      charges may change when adjustments are implemented. </strong></font></td>
  </tr>
</table>
<%		}//if payment detail and payment mode not null;
	}//if student information exists.
}//if miscellaneous fee information exists.
dbOP.cleanUP();

if(strErrMsg == null && request.getParameter("view_status") != null && request.getParameter("view_status").compareTo("0") == 0 ){%>
<script language="JavaScript">
	window.print();
</script>
<%}%>

<input type="hidden" name="view_status" value="<%=WI.fillTextValue("view_status")%>">
</form>
</body>
</html>
