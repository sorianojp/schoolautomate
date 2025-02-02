<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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

-->
</style>
</head>

<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strSubSecIndex = null;

	String strDegreeType  = null;

	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Parent/Student-enrollment","fees_paid_enrollment.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForParentStudLink(dbOP,(String)request.getSession(false).getAttribute("userId"),
							(String)request.getSession(false).getAttribute("authTypeIndex"),request.getRemoteAddr());
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../PARENTS_STUDENTS/main_files/parents_students_bottom_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
//end of authenticaion code.

String strStudID = (String)request.getSession(false).getAttribute("userId");
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
Vector vStudInfo    = null;
Vector vMiscFeeInfo = null;
Vector vTemp        = null;
float fTutionFee  = 0;
float fCompLabFee = 0;
float fMiscFee    = 0;
float fOutstanding= 0;
float fMiscOtherFee = 0f;//This is the misc fee other charges,

float fEnrollmentDiscount = 0f; //this sum of full payment, early enrollment or late enrollment discount/fine implementations.
String strEnrolmentDiscDetail = null;
float fPayableAfterDiscount = 0f;


SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

Vector vAssessedSubDetail = null;
vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,strStudID, strStudID, astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
if(vStudInfo == null) strErrMsg = enrlStudInfo.getErrMsg();
else
{
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
}
if(strErrMsg == null) //collect fee details here.
{
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),false,
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
	if(fTutionFee > 0)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),false,
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),false,
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);

               fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
               		astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
               fOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));

		fMiscOtherFee = fOperation.getMiscOtherFee();

		enrollment.FAFeeOperationDiscountEnrollment test = new enrollment.FAFeeOperationDiscountEnrollment();
		vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,(String)vStudInfo.elementAt(0),false,
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),
                                        astrSchYrInfo[2],
                                        fOperation.dReqSubAmt);
		if(vTemp != null)
			strEnrolmentDiscDetail = (String)vTemp.elementAt(0);//System.out.println(vTemp);
		if(strEnrolmentDiscDetail != null)
		{
			fEnrollmentDiscount = ((Float)vTemp.elementAt(1)).floatValue();
			fPayableAfterDiscount = fTutionFee+fMiscFee+fCompLabFee+fOutstanding-fEnrollmentDiscount;
		}


		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5), "degree_type"," and is_valid=1 and is_del=0");
		vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),false,
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2],"1",strDegreeType);
		if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0)
			strErrMsg = FA.getErrMsg();
	}
	else
		strErrMsg = fOperation.getErrMsg();
}
//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null)
{
	vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
	if(vTemp == null)
		strErrMsg = paymentUtil.getErrMsg();
	else
		vMiscFeeInfo.addAll(vTemp);
	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");
	}
}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F">
      <td height="25" ><div align="center"><strong><font color="#FFFFFF">FEE PAYMENT DETAILS DURING
        ENROLLMENT</font></strong></div></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#BECED3">
      <td height="25" bgcolor="#BECED3"><div align="center"><font color="#FFFFFF" size="1"><strong>FEE
        PAYMENT DETAIL FOR <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>,
        SCHOOL YEAR <%=astrSchYrInfo[0]+"-"+astrSchYrInfo[1]%></strong></font></div></td>
    </tr>
  </table>

<% if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">

    <tr >
      <td height="25" ><div align="center">
	  <strong><font size="3"><%=strErrMsg%></font></strong></div></td>
    </tr>
	</table>
<%
	dbOP.cleanUP();
	return;
}

if(vStudInfo != null && vStudInfo.size() > 0){

if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0)
{%>

<table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr >
    <td width="10%" height="18"><div align="center"><font size="1"><strong>SUBJECT
        CODE </strong></font></div></td>
    <td width="26%" height="19"><div align="center"><font size="1"><strong>SUBJECT
        NAME</strong></font></div></td>
    <td width="24%"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
    <td width="12%"><div align="center"><font size="1"><strong>SECTION/ROOM #</strong></font></div></td>
    <td width="5%"><div align="center"><font size="1"><strong>LEC/LAB UNITS </strong></font></div></td>
    <td width="5%"><div align="center"><font size="1"><strong>TOTAL UNITS</strong></font></div></td>
    <td width="5%"><div align="center"><font size="1"><strong>UNITS TAKEN</strong></font></div></td>
    <td width="6%"><div align="center"><font size="1"><strong>RATE/ UNIT</strong></font></div></td>
    <td width="7%"><div align="center"><font size="1"><strong>TOTAL SUBJECT FEE
        </strong></font></div></td>
  </tr>
  <%
	float fTotalLoad = 0;float fUnitsTaken = 0f;
	float fTotalSubFee = 0;
	float fTotalUnit = 0;
	float fSubTotalRate = 0 ; //unit * rate per unit.
String strSchedule = null;
String strRoomAndSection = null;
	String strRatePerUnit = null;
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
		//get schedule here.
		vSubSecDtls = SS.getRoomScheduleDetailInMWF(dbOP, strSubSecIndex);
		if(vSubSecDtls == null || vSubSecDtls.size() ==0)
		{
			strErrMsg = SS.getErrMsg();
			break;
		}
		for(int b=0; b<vSubSecDtls.size(); ++b)
		{
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
%>
  <tr >
    <td height="19"><%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
    <td><%=(String)vAssessedSubDetail.elementAt(i+2)%></td>
    <td><%=strSchedule%></td>
    <td><%=strRoomAndSection%></td>
    <td><%=(String)vAssessedSubDetail.elementAt(i+3)%>/<%=(String)vAssessedSubDetail.elementAt(i+4)%></td>
    <td><%=fTotalUnit%></td>
    <td><%=(String)vAssessedSubDetail.elementAt(i+9)%></td>
    <td><%=CommonUtil.formatFloat(strRatePerUnit,true)%></td>
    <td><%=CommonUtil.formatFloat(fSubTotalRate,true)%></td>
  </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}%>
  <tr >
    <td colspan="9" height="18"><div align="center">
        <%if(strErrMsg != null){%>
        <%=strErrMsg%>
        <%}else{%>
        TOTAL LOAD UNITS : <strong><%=fTotalLoad%>/<%=fUnitsTaken%></strong>
        <%}%>
      </div></td>
  </tr>
</table>
<%}//if vAssessedSubDetail no null
if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && fTutionFee > 0)
{
	//get here payment detail payment method detail.
	Vector[] vRetResult = faPayment.viewTutionFeePaymentDetail(dbOP,(String)vStudInfo.elementAt(0),astrSchYrInfo[0],
							astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2],"0", "0");

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
    <td colspan="4" height="25" bgcolor="#CBDCDE"><div align="center"><strong><font size="1">:: FEE DETAILS ::</font></strong></div></td>
    <td height="14" colspan="3" bgcolor="#DCE7E9"><div align="center"><strong><font size="1">:: PAYMENT DETAILS ::</font></strong></div></td>
  </tr>
  <tr >
    <td height="25" colspan="3" bgcolor="#CBDCDE">TUITION FEE </td>
    <td width="24%" bgcolor="#CBDCDE"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td width="19%" bgcolor="#DCE7E9">PAYEE TYPE</td>
    <td width="36%" bgcolor="#DCE7E9"><strong><%=(String)vRetResult[0].elementAt(1)%></strong></td>
  </tr>
  <tr >
    <td height="25" colspan="3" bgcolor="#CBDCDE">COMP. LAB. FEE</td>
    <td bgcolor="#CBDCDE"><font size="1"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">PAYEE NAME </td>
    <td bgcolor="#DCE7E9"> <strong><%=WI.getStrValue(vRetResult[0].elementAt(2))%></strong></td>
  </tr>
  <tr >
    <td height="25" colspan="4" bgcolor="#CBDCDE">MISCELLANEOUS FEES</td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">PAYMENT MODE </td>
    <td bgcolor="#DCE7E9"><strong> <%=(String)vRetResult[0].elementAt(3)%></strong></td>
  </tr>
  <tr >
    <td width="1%" bgcolor="#CBDCDE">&nbsp;</td>
    <td width="1%" height="25" bgcolor="#CBDCDE">&nbsp;</td>
    <td width="18%" bgcolor="#CBDCDE"><font size="1"><%=(String)vMiscFeeInfo.elementAt(0)%></font></td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 1){%>
      <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(1),true)%>
      <%}%>
      </font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">ASSISTANCE TYPE</td>
    <td bgcolor="#DCE7E9"><strong> <%=WI.getStrValue(vRetResult[0].elementAt(4))%></strong></td>
  </tr>
  <tr >
    <td bgcolor="#CBDCDE">&nbsp;</td>
    <td height="25" bgcolor="#CBDCDE">&nbsp;</td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 3 && ((String)vMiscFeeInfo.elementAt(5)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(3)%>
      <%}%>
      </font></td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 6 && ((String)vMiscFeeInfo.elementAt(8)).compareTo("0") ==0){%>
      <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(4),true)%>
      <%}%>
      </font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">AMOUNT PAID</td>
    <td bgcolor="#DCE7E9"><strong><%=CommonUtil.formatFloat((String)vRetResult[1].elementAt(5),true)%></strong></td>
  </tr>
 <%if(strEnrolmentDiscDetail != null){%>   <tr >
    <td height="15" bgcolor="#CBDCDE">&nbsp;</td>
    <td height="15" bgcolor="#CBDCDE">&nbsp;</td>
    <td height="15" bgcolor="#CBDCDE">&nbsp;</td>
    <td height="15" bgcolor="#CBDCDE">&nbsp;</td>
    <td height="15" bgcolor="#DCE7E9">&nbsp;</td>
    <td height="15" colspan="2" bgcolor="#DCE7E9"><font size="1">(<%=strEnrolmentDiscDetail%>)</font></td>
  </tr>
 <%}%>
 <tr >
    <td bgcolor="#CBDCDE">&nbsp;</td>
    <td height="25" bgcolor="#CBDCDE">&nbsp;</td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 6 && ((String)vMiscFeeInfo.elementAt(8)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(6)%>
      <%}%>
      </font></td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 7 && ((String)vMiscFeeInfo.elementAt(8)).compareTo("0") ==0){%>
      <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(7),true)%>
      <%}%>
      </font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">APPROVAL NO.</td>
    <td bgcolor="#DCE7E9"><strong><%=WI.getStrValue(vRetResult[1].elementAt(3))%></strong></td>
  </tr>
  <tr >
    <td bgcolor="#CBDCDE">&nbsp;</td>
    <td height="25" bgcolor="#CBDCDE">&nbsp;</td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 9 && ((String)vMiscFeeInfo.elementAt(11)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(9)%>
      <%}%>
      </font></td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 10  && ((String)vMiscFeeInfo.elementAt(11)).compareTo("0") ==0){%>
      <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(10),true)%>
      <%}%>
      </font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">PAYMENT RECEIVE TYPE</td>
    <td bgcolor="#DCE7E9"> <strong><%=(String)vRetResult[1].elementAt(1)%></strong></td>
  </tr>
  <tr >
    <td bgcolor="#CBDCDE">&nbsp;</td>
    <td height="25" bgcolor="#CBDCDE">&nbsp;</td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 12  && ((String)vMiscFeeInfo.elementAt(14)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(12)%>
      <%}%>
      </font></td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 13  && ((String)vMiscFeeInfo.elementAt(14)).compareTo("0") ==0){%>
      <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(13),true)%>
      <%}%>
      </font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">BANK NAME </td>
    <td bgcolor="#DCE7E9"> <strong><%=WI.getStrValue(vRetResult[1].elementAt(2))%></strong></td>
  </tr>
  <tr >
    <td bgcolor="#CBDCDE">&nbsp;</td>
    <td height="25" bgcolor="#CBDCDE">&nbsp;</td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 15  && ((String)vMiscFeeInfo.elementAt(17)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(15)%>
      <%}%>
      </font></td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 16  && ((String)vMiscFeeInfo.elementAt(17)).compareTo("0") ==0){%>
      <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(16),true)%>
      <%}%>
      </font></td>
    <td width="1%" bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">DATE PAID</td>
    <td bgcolor="#DCE7E9"><strong><%=(String)vRetResult[1].elementAt(8)%></strong></td>
  </tr>
  <tr>
    <td bgcolor="#CBDCDE">&nbsp;</td>
    <td height="25" bgcolor="#CBDCDE">&nbsp;</td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 18  && ((String)vMiscFeeInfo.elementAt(20)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(18)%>
      <%}%>
      </font></td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 19  && ((String)vMiscFeeInfo.elementAt(20)).compareTo("0") ==0){%>
      <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(19),true)%>
      <%}%>
      </font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">PAYMENT TYPE</td>
    <td bgcolor="#DCE7E9"><strong> <%=(String)vRetResult[1].elementAt(4)%></strong></td>
  </tr>
  <tr>
    <td bgcolor="#CBDCDE">&nbsp;</td>
    <td height="25" bgcolor="#CBDCDE">&nbsp;</td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 21  && ((String)vMiscFeeInfo.elementAt(23)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(21)%>
      <%}%>
      </font></td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 22  && ((String)vMiscFeeInfo.elementAt(23)).compareTo("0") ==0){%>
      <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(22),true)%>
      <%}%>
      </font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">CHECK #</td>
    <td bgcolor="#DCE7E9"> <strong><%=WI.getStrValue(vRetResult[1].elementAt(6))%></strong></td>
  </tr>
  <tr>
    <td bgcolor="#CBDCDE">&nbsp;</td>
    <td height="25" bgcolor="#CBDCDE">&nbsp;</td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 24  && ((String)vMiscFeeInfo.elementAt(26)).compareTo("0") ==0){%>
      <%=(String)vMiscFeeInfo.elementAt(24)%>
      <%}%>
      </font></td>
    <td bgcolor="#CBDCDE"><font size="1">
      <%if(vMiscFeeInfo.size() > 25  && ((String)vMiscFeeInfo.elementAt(26)).compareTo("0") ==0){%>
      <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(25),true)%>
      <%}%>
      </font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">O.R. NUMBER</td>
    <td bgcolor="#DCE7E9"> <strong><%=(String)vRetResult[1].elementAt(7)%></strong></td>
  </tr>
    <%
for(int i = 27; i< vMiscFeeInfo.size(); i +=2){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
		++i;
		continue;
	}
	%>
  <tr>
    <td bgcolor="#CBDCDE">&nbsp;</td>
    <td height="25" bgcolor="#CBDCDE">&nbsp;</td>
    <td bgcolor="#CBDCDE"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i++)%>
      </font></td>
    <td bgcolor="#CBDCDE"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i),true)%>
      </font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
  </tr>
  <%}%>
  <tr>
    <td bgcolor="#CBDCDE">&nbsp;</td>
    <td height="25" bgcolor="#CBDCDE">&nbsp;</td>
    <td bgcolor="#CBDCDE"><font size="1"><strong>TOTAL MISC :</strong></font></td>
    <td bgcolor="#CBDCDE"><font size="1"><strong><%=CommonUtil.formatFloat(fMiscFee-fMiscOtherFee,true)%></strong></font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td bgcolor="#DCE7E9">&nbsp; </td>
  </tr>
<%
if(fMiscOtherFee > 0f){%>
    <tr>
      <td height="25" bgcolor="#CBDCDE"><font size="1">&nbsp;</font></td>
      <td colspan="3" bgcolor="#CBDCDE"><font size="1">OTHER CHARGES</font></td>
      <td bgcolor="#DCE7E9"><font size="1">&nbsp;</font></td>
      <td bgcolor="#DCE7E9"><font size="1">&nbsp;</font></td>
      <td bgcolor="#DCE7E9"><font size="1">&nbsp;</font> </td>
    </tr>
<%
for(int i = 0; i< vMiscFeeInfo.size(); i +=2){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		++i;
		continue;
	}
	%>
    <tr>
      <td height="25" bgcolor="#CBDCDE"><font size="1">&nbsp;</font></td>
      <td bgcolor="#CBDCDE"><font size="1">&nbsp;</font></td>
      <td bgcolor="#CBDCDE"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i++)%></font></td>
      <td bgcolor="#CBDCDE"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i),true)%></font></td>
      <td bgcolor="#DCE7E9"><font size="1">&nbsp;</font></td>
      <td bgcolor="#DCE7E9"><font size="1">&nbsp;</font></td>
      <td bgcolor="#DCE7E9"><font size="1">&nbsp;</font> </td>
    </tr>
<%}%>
     <tr>
      <td height="25" bgcolor="#CBDCDE"><font size="1">&nbsp;</font></td>
      <td bgcolor="#CBDCDE"><font size="1">&nbsp;</font></td>
      <td bgcolor="#CBDCDE"><font size="1"><strong> OTHER CHARGE :</strong></font></td>
      <td bgcolor="#CBDCDE"><font size="1"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%> </strong></font></td>
      <td bgcolor="#DCE7E9"><font size="1">&nbsp;</font></td>
      <td bgcolor="#DCE7E9"><font size="1">&nbsp;</font></td>
      <td bgcolor="#DCE7E9"><font size="1">&nbsp;</font> </td>
    </tr>
<%}%>
 <tr>
    <td height="21" colspan="4" bgcolor="#CBDCDE"><hr size="1"></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td colspan="2" bgcolor="#DCE7E9">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" colspan="3" bgcolor="#CBDCDE"><strong>TOTAL TUITION FEE :</strong></td>
    <td bgcolor="#CBDCDE"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></strong></font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td colspan="2" bgcolor="#DCE7E9"><div align="center"></div></td>
  </tr>
  <tr>
    <td height="20" colspan="3" bgcolor="#CBDCDE"><strong>OLD ACCOUNT</strong></td>
    <td bgcolor="#CBDCDE"><font size="1"><strong><%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td colspan="2" bgcolor="#DCE7E9">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" colspan="3" bgcolor="#CBDCDE"><strong>TOTAL AMOUNT DUE</strong></td>
    <td bgcolor="#CBDCDE"><font size="1"><strong>
	<%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding - fEnrollmentDiscount ,true)%></strong></font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td colspan="2" bgcolor="#DCE7E9">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" colspan="3" bgcolor="#CBDCDE"><strong>TOTAL BALANCE DUE</strong></td>
    <td bgcolor="#CBDCDE"><font size="1"><strong>
	<%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding - fEnrollmentDiscount - Float.parseFloat((String)vRetResult[1].elementAt(5)),true)%></strong></font></td>
    <td bgcolor="#DCE7E9">&nbsp;</td>
    <td colspan="2" bgcolor="#DCE7E9">&nbsp;</td>
  </tr>
</table>

<%		}//if payment detail and payment mode not null;
	}//if student information exists.
}//if miscellaneous fee information exists.
dbOP.cleanUP();
%>
  <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="200%" colspan="2"><div align="center"> </div></td>
    </tr>
    <tr>
      <td height="25" colspan="2" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>

</body>
</html>
