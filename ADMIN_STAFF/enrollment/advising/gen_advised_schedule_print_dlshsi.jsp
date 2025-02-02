<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
if(strSchoolCode.startsWith("CNU"))
	strSchoolCode = "CLDH";
//if(strSchoolCode.startsWith("CSAB"))
	//strSchoolCode = "UPH";
boolean bolIsOnlineAdvising = false;
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");



if(strAuthTypeIndex == null) {%>
	<p style="font-weight:bold; font-size:18px; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif">
		You are already logged out. Please login again.
	</p>
<%return;}
if(strAuthTypeIndex.equals("4") || strAuthTypeIndex.equals("0"))
	bolIsOnlineAdvising = true;	



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
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
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
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
-->
</style>
</head>

<body >
<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.CurriculumMaintenance,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strPrintedBy = null;
	String strCollegeName = null;
	String[] astrSchYrInfo = {null,null,null};
	boolean bolFatalErr = false;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","5th Sem"};
	if(strSchoolCode.startsWith("PWC")) {
		astrConvertSem[1] = "1st Tri";
		astrConvertSem[2] = "2nd Tri";
		astrConvertSem[3] = "3rd Tri";
	}

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

//get here the list of advised subjects.
Advising advising = new Advising();
Vector vAdvisedList = new Vector();
Vector vStudInfo    = new Vector();
Vector vTemp = null;

int iIndexOf = 0;
boolean bolShowSubjectFee = false;//for UPH, they want to see per subject fee.
boolean bolIsUPH = strSchoolCode.startsWith("UPH");
if(bolIsUPH)
	bolShowSubjectFee = true;
	

String strMaxAllowedLoad = null;
String strOverLoadDetail = null;
String strIsTempStud = null;

String strStudIndex = null;
String strStudID	= WI.fillTextValue("stud_id");
if(strStudID.length() ==0)
	strStudID = WI.fillTextValue("temp_id");
if(bolIsOnlineAdvising) {
	if(strAuthTypeIndex.equals("4"))
		strStudID = (String)request.getSession(false).getAttribute("userId");
	else
		strStudID = (String)request.getSession(false).getAttribute("tempId");
}
	
if(strStudID == null || strStudID.length() == 0)
{
	strErrMsg = "Student ID can't be empty.";
	bolFatalErr = true;
}
//get student information first.
if(!bolFatalErr)
{
	vStudInfo = advising.getStudInfo(dbOP,strStudID);
	if(vStudInfo == null)
	{
		strErrMsg = advising.getErrMsg();
		bolFatalErr = true;
	}
}
if(!bolFatalErr)
{
	astrSchYrInfo[0]=(String)vStudInfo.elementAt(16);//take sy from/to/sem from student registration information.
	astrSchYrInfo[1]=(String)vStudInfo.elementAt(17);
	astrSchYrInfo[2]=(String)vStudInfo.elementAt(18);
	strStudIndex = (String)vStudInfo.elementAt(0);
	strIsTempStud = (String)vStudInfo.elementAt(10);
}

//get the student's advised schedule information.
if(!bolFatalErr)
{
	vAdvisedList = advising.getAdvisedList(dbOP, strStudIndex,strIsTempStud,(String)vStudInfo.elementAt(2),
						astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	if(vAdvisedList == null)
	{
		strErrMsg = advising.getErrMsg();
		bolFatalErr = true;
	}
/**
	else if(bolShowSubjectFee) {
		String strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(2), "degree_type"," and is_valid=1 and is_del=0");
		boolean bolIsTempUser = false;
		if(strIsTempStud.equals("1"))
			bolIsTempUser = true;
		vFeeDetails = new enrollment.FAAssessment().getAssessedSubDetail(dbOP,strStudIndex,bolIsTempUser,astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6), astrSchYrInfo[2],strDegreeType);
	}
**/
}


if(!bolFatalErr)
{
	strCollegeName = new CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(2));
	strPrintedBy   = CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1);
	Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),
			astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2],(String)vStudInfo.elementAt(4),
			(String)vStudInfo.elementAt(5));
	if(vMaxLoadDetail == null)
	{
		bolFatalErr = true;
		strErrMsg = advising.getErrMsg();
	}
	else
	{
		strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
		if(vMaxLoadDetail.size() > 1)
			strOverLoadDetail = "Maximum load in curriculum for this sem "+(String)vMaxLoadDetail.elementAt(1)+
			" overloaded load "+(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+(String)vMaxLoadDetail.elementAt(2)+")";
		if(strMaxAllowedLoad.compareTo("-1") ==0)
			strMaxAllowedLoad = "N/A";
	}
}
//dbOP.cleanUP();

//get details.
Vector vMiscFeeInfo = null;
float fMiscFee   = 0f; float fCompLabFee         = 0f; float fOutstanding = 0f;float fMiscOtherFee = 0f;
float fTutionFee = 0f; float fEnrollmentDiscount = 0f;
String strEnrolmentDiscDetail = null;
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	enrollment.FAFeeOptional fOptional = new enrollment.FAFeeOptional();

double dReqdDP = 0d;/// show for UC> 
double dReservationFee = 0d;

enrollment.FAPaymentUtil paymentUtil = new enrollment.FAPaymentUtil();

if(!bolFatalErr && vStudInfo != null) {
	request.setAttribute("sy_from",astrSchYrInfo[0]);
	request.setAttribute("sy_to",astrSchYrInfo[1]);
	request.setAttribute("semester",astrSchYrInfo[2]);
	Vector vOthSetting = fOptional.operateOnAddlAssessementSetting(dbOP, request, 7);

	paymentUtil.setTempUser((String)vStudInfo.elementAt(10));
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(2),
		        (String)vStudInfo.elementAt(3),(String)vStudInfo.elementAt(6), astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);

	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),	astrSchYrInfo[0],astrSchYrInfo[1],
					(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
	if(fTutionFee > 0) {

		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
							astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
		fOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));
		//if(bolIsUPH)
		//	fOutstanding = 0f;

		fMiscOtherFee = fOperation.getMiscOtherFee();
		vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
				astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		if(vTemp == null)
			strErrMsg = paymentUtil.getErrMsg();
		else if(vMiscFeeInfo != null) {
			vMiscFeeInfo.addAll(vTemp);
			if(fOperation.vMultipleOCMapInfo != null && fOperation.vMultipleOCMapInfo.size() > 0) 
				vMiscFeeInfo.addAll(fOperation.vMultipleOCMapInfo);
		}
		
		if(vOthSetting != null && ((String)vOthSetting.elementAt(1)).compareTo("0") == 0){//full payment.
			enrollment.FAFeeOperationDiscountEnrollment test =
					new enrollment.FAFeeOperationDiscountEnrollment(paymentUtil.isTempStud(),WI.getTodaysDate(1));
			vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
						astrSchYrInfo[0],astrSchYrInfo[1],
											(String)vStudInfo.elementAt(6),astrSchYrInfo[2],
											fOperation.dReqSubAmt);
			if(vTemp != null && vTemp.size() > 0)
				strEnrolmentDiscDetail = (String)vTemp.elementAt(0);//System.out.println(vTemp);//System.out.println(strEnrolmentDiscDetail);
			if(strEnrolmentDiscDetail != null && vTemp != null && vTemp.size() > 0) {
				fEnrollmentDiscount = ((Float)vTemp.elementAt(1)).floatValue();
			}
		}
		
		
		///get the reservation fee for CGH. .
		if(strSchoolCode.startsWith("CGH")) {
			dReservationFee = paymentUtil.getReservationFeeCGH(dbOP, (String)vStudInfo.elementAt(0),
													astrSchYrInfo[0], astrSchYrInfo[1],
													astrSchYrInfo[2],paymentUtil.isTempStud());
		}
		
		enrollment.FAStudMinReqDP faMinDP = new enrollment.FAStudMinReqDP(null);
		faMinDP.setTotalAssessment(fTutionFee+fCompLabFee+fMiscFee + fOutstanding - fEnrollmentDiscount - dReservationFee);
		dReqdDP = faMinDP.getPayableDownPayment(dbOP, request.getParameter("stud_id"), astrSchYrInfo[0], astrSchYrInfo[1],astrSchYrInfo[2], strSchoolCode, 1, 
							(String)vStudInfo.elementAt(0), paymentUtil.isTempStud(), (String)vStudInfo.elementAt(2), 
							(String)vStudInfo.elementAt(3), (String)vStudInfo.elementAt(6));

		
		
	}
}

boolean bolShowFeeDetail = false;
boolean bolShowLabFee    = false;//for PWC only. 
boolean bolIsMariner     = false;
if(strSchoolCode.startsWith("MARINER"))
	bolIsMariner = true;

if(	strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("CLDH") || strSchoolCode.startsWith("CPU")    || 
	strSchoolCode.startsWith("UDMC")|| strSchoolCode.startsWith("CGH")  || strSchoolCode.startsWith("CSAB")   || 
	strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("UL")   || strSchoolCode.startsWith("PHILCST")|| 
	strSchoolCode.startsWith("DBTC")|| strSchoolCode.startsWith("PIT")  || strSchoolCode.startsWith("FATIMA") ||
	strSchoolCode.startsWith("EAC") || strSchoolCode.startsWith("UC")   || strSchoolCode.startsWith("WUP")    || 
	strSchoolCode.startsWith("UPH") || strSchoolCode.startsWith("PWC") || strSchoolCode.startsWith("MARINER") || strSchoolCode.startsWith("NEU") || strSchoolCode.startsWith("DLSHSI"))
		bolShowFeeDetail = true;
if(strSchoolCode.startsWith("PWC") && vStudInfo != null && vStudInfo.size() > 0) {
		bolShowLabFee = true;
}

String strInfo5 = (String)request.getSession(false).getAttribute("info5");

boolean bolHideFeeAmt = false;
if(strSchoolCode.startsWith("UPH") && strInfo5 == null) {
	strTemp = (String)vStudInfo.elementAt(11);
	strTemp = strTemp.toLowerCase();

	//bolShowFeeDetail = false;
	if(strTemp.equals("new") || strTemp.equals("cross enrollee") || strTemp.equals("transferee") || 
		strTemp.equals("second course") ) {
		bolShowLabFee = false;
		bolShowSubjectFee = false;
		bolHideFeeAmt = true;
	}
}
//bolShowFeeDetail = true;

/**
System.out.println(fMiscFee);
System.out.println(fMiscOtherFee);
System.out.println(vMiscFeeInfo);
System.out.println(fEnrollmentDiscount);
System.out.println(strEnrolmentDiscDetail);
**/
//I have added this to get the round off value for AUF.. 
double dDiff = 0d;
double dRoundOf = 0d;
double[] dTemp = null;

//if installment Fee, i have add it to the d/p.
double dInstallmentFeeCGH = 0d;

boolean bolShowNote = false;

if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0) {
	for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
		if(WI.getStrValue(vMiscFeeInfo.elementAt(i)).equalsIgnoreCase("Installment Fee")) {
			bolShowNote = true;
			break;
		}
	}
}

if(bolFatalErr){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" align="center"><%=strErrMsg%></td>
    </tr>
  </table>
<%
  dbOP.cleanUP();
  return;
}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%

String strSQLQuery = "update enrl_final_cur_list set is_printed_1 = 1 where user_index = "+strStudIndex+
					" and sy_from = "+astrSchYrInfo[0]+" and current_semester = "+astrSchYrInfo[2]+
					" and is_temp_stud="+strIsTempStud+" and is_valid = 1";
					
dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);

//set that, it is re-printed.
strSQLQuery = "update CIT_ALLOW_SECOND_ADVISING set is_used = 1 where sy_from = "+astrSchYrInfo[0]+" and sem = "+astrSchYrInfo[2]+
		        " and stud_index = "+strStudIndex+" and is_temp_stud = "+strIsTempStud; 
dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);


if(vMiscFeeInfo == null)
	vMiscFeeInfo = new Vector();

if(strSchoolCode.startsWith("LNU")){%>
    <tr>
      <td height="7" colspan="7" align="left">L-NU REG # 100</td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="7"><div align="center"><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <br>
          <strong><font size="2"><%=strCollegeName%></font></strong><br>
          <br>
        <strong> <font size="2">
		<%if(!strSchoolCode.startsWith("AUF")){%>
		STUDENT ENROLMENT LOAD<%}else{%>ASSESSMENT OF FEES<%}%></font></strong><br>
        <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>, <%if(strSchoolCode.startsWith("PWC")) {%>SY<%}else{%>AY<%}%> <%=astrSchYrInfo[0]%>-<%=astrSchYrInfo[1]%></div></td>
    </tr>
    <tr>
      <td height="25" colspan="7"><div align="right">&nbsp; Date and time printed
          :<strong> <%=WI.getTodaysDateTime()%></strong></div></td>
    </tr>
  </table>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="22">Student ID : <strong><font size="2"><%=strStudID%></font></strong></td>
    <td width="57%">Course / Major : <strong><%=(String)vStudInfo.elementAt(7)%>
      <%if(vStudInfo.elementAt(8) != null){%>
      / <%=(String)vStudInfo.elementAt(8)%>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="22">Student name : <strong><font size="2"><%=(String)vStudInfo.elementAt(1)%></font></strong></td>
    <td> Curriculum Year : <strong><%=(String)vStudInfo.elementAt(4)%>
      - <%=(String)vStudInfo.elementAt(5)%></strong></td>
  </tr>
  <tr>
    <td width="43%" height="22">Student type : <strong><%=(String)vStudInfo.elementAt(11)%>
	<%if(strSchoolCode.startsWith("AUF")){%>
	/<%if(vStudInfo.elementAt(21).equals("0")){%>Regular<%}else{%>Irregular<%}%>
	<%}%>
	</strong></td>
    <td>Year : <strong><%=WI.getStrValue(vStudInfo.elementAt(6),"N/A")%>
      </strong></td>
  </tr>
<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("CPU") && !strSchoolCode.startsWith("CLDH")){%>
  
<%}%>
  <tr>
    <td height="12">&nbsp;</td>
    <td height="12">&nbsp;</td>
  </tr>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%if(!strSchoolCode.startsWith("AUF"))
if(strOverLoadDetail != null){%>
    <tr>
      <td  height="22">&nbsp;</td>
      <td colspan="6">Overload detail : <%=strOverLoadDetail%></td>
    </tr>
<%}%>
   <tr>
      <td width="9" height="22">&nbsp;</td>
      <td colspan="2">
	  <%if(!strSchoolCode.startsWith("AUF")){%>
		Maximum units the student can take : <strong><%=strMaxAllowedLoad%></strong>
	<%}%>	</td>

    <td colspan="4" width="326" height="25" >Total student load taken: <strong><%=(String)vAdvisedList.elementAt(0)%></strong></td>
    </tr>
  </table>
  <table width="100%" cellpadding="0" cellspacing="0" border="0">
  	<tr>
		<td width="30%" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderNONE">
			  <tr>
				<td width="80%" height="25" class="thinborderNONE"><strong>SUBJECT</strong></td>
				<td width="20%" class="thinborderNONE"><strong><font size="1">UNITS/HRS</font></strong></td>
			  </tr>
			  <%//System.out.println(vAdvisedList);
			//System.out.println(fOperation.vTuitionFeeDtls);
			for(int i = 1; i<vAdvisedList.size(); ++i)
			{%>
			  <tr>
				<td height="20" class="thinborderNONE"><%=WI.getStrValue((String)vAdvisedList.elementAt(i+3),"","-","TBA")%><%=(String)vAdvisedList.elementAt(i)%></td>
				<td class="thinborderNONE"><%=(String)vAdvisedList.elementAt(i+9)%></td>
			  </tr>
			  <%
			i = i+10;
			}%>
		  </table>
		  
		  <br><br><br>
		  <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td height="25">&nbsp;</td>
        </tr>
        <tr>
          <td height="20">&nbsp;</td>
        </tr>
        <tr>
          <td height="20">&nbsp;</td>
        </tr>
        <tr>
          <td height="20">-- Installment Payment Detail -- </td>
        </tr>
<%
double dTotalPayable   = fTutionFee+fCompLabFee+fMiscFee + fOutstanding - fEnrollmentDiscount;
double dDownPayment    = 0d;
double dInstallmentPmt = 0d;



if(strSchoolCode.startsWith("EAC"))
	dTotalPayable = dTotalPayable - fOutstanding;

Vector vPmtSchInfo = new enrollment.FAPmtMaintenance().getAllowedPmtSchedue(dbOP, strStudIndex,astrSchYrInfo[0],astrSchYrInfo[2],
					true, paymentUtil.isTempStud());
enrollment.FAAssessment FA = new enrollment.FAAssessment();
int iNoOfInstallment = 0;
if(vPmtSchInfo != null) {
	iNoOfInstallment = vPmtSchInfo.size()/ 3;
	if(iNoOfInstallment == 1)
		dDownPayment = dTotalPayable/2d;
	else if(iNoOfInstallment < 4)
		 dDownPayment = dTotalPayable * 0.4d;
	else	
		dDownPayment = dTotalPayable * 0.25d;
	
	dInstallmentPmt = (dTotalPayable - dDownPayment)/iNoOfInstallment;
}
if(iNoOfInstallment > 0){%>
        <tr>
          <td height="20">Downpayment :
		  <%=CommonUtil.formatFloat(dDownPayment,true)%>		  </td>
        </tr>
<%for(int i = 0; i < vPmtSchInfo.size(); i += 3){
		strErrMsg        = CommonUtil.formatFloat(dInstallmentPmt + dDiff,true);
	%>
        <tr>
          <td height="20"><%=((String)vPmtSchInfo.elementAt(i + 1)).toUpperCase()%> DUE : <%=strErrMsg%></td>
        </tr>
<%}
}%>
        
		<%if(bolShowNote){%>
			<tr>
			  <td height="20" align="center"><br>
			  		<table class="thinborderALL" bgcolor="#DDDDDD"><tr><td>
					  Installment Fee will be removed if Payment is made in FULL.</strong>
					  </td></tr></table>
			  </td>
			</tr>
		<%}%>
	 </table>
		  
        </td>
		<td width="2%">&nbsp;</td>
		<td width="68%">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
					  <td height="25" colspan="4">&nbsp;</td>
					</tr>
					<tr>
					  <td width="2%" height="20">&nbsp;</td>
					  <td width="57%">Tuition Fee</td>
					  <td width="18%" align="right"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></td>
					  <td width="23%">&nbsp;</td>
					</tr>
				 <%if(strSchoolCode.startsWith("AUF")){%>
					<tr>
					  <td height="20">&nbsp;</td>
					  <td>Misc. Fee</td>
					  <td align="right"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></td>
					  <td>&nbsp;</td>
					</tr>
				 <%}if(fCompLabFee > 0f){%>
					<tr>
					  <td height="20">&nbsp;</td>
					  <td>Computer Lab Fee.</td>
					  <td align="right"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></td>
					  <td>&nbsp;</td>
					</tr>
				<%}if(!strSchoolCode.startsWith("AUF")){%>
					<tr>
					  <td height="20">&nbsp;</td>
					  <td>MiscFee</td>
					  <td align="right"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></td>
					  <td>&nbsp;</td>
					</tr>
					<%
					for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
						if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0)
							continue;
					%>
					<tr>
					  <td height="18">&nbsp;</td>
					  <td>&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
					  <td align="right"><%if(!bolHideFeeAmt){%><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%><%}%></td>
					  <td>&nbsp;</td>
					</tr>
				<%}//end of for loop.
				}//show only if CLDH%>
					<tr>
					  <td height="20">&nbsp;</td>
					  <td>Other Charges </td>
					  <td align="right"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></td>
					  <td>&nbsp;</td>
					</tr>
					<%if(!bolHideFeeAmt){
					for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
						if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
							continue;
						if(strSchoolCode.startsWith("CGH")) {
							if(((String)vMiscFeeInfo.elementAt(i)).toLowerCase().startsWith("installment fee"))
								dInstallmentFeeCGH = Double.parseDouble((String)vMiscFeeInfo.elementAt(i+1));
						}
					%>
					<tr>
					  <td height="18">&nbsp;</td>
					  <td>&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
					  <td align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
					  <td>&nbsp;</td>
					</tr>
					<%}
					}//do not show if WUP
				if(strEnrolmentDiscDetail != null){%>
					<tr>
					  <td height="20">&nbsp;</td>
					  <td colspan="3"><%=strEnrolmentDiscDetail%></td>
					</tr>
					<%}
				if(fOutstanding != 0f && !strSchoolCode.startsWith("AUF")){%>
					<tr>
					  <td height="20">&nbsp;</td>
					  <td><div align="left">OLD ACCOUNT</div></td>
					  <td align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></td>
					  <td>&nbsp;</td>
					</tr>
					<%}%>
					 <%if(dReservationFee > 0d) {%>
							<tr>
							  <td height="20">&nbsp;</td>
							  <td>Less Reservation Fee </td>
							  <td align="right">(<%=CommonUtil.formatFloat(dReservationFee, true)%>)</td>
							  <td>&nbsp;</td>
							</tr>
					<%}%>
					
					
					<%if(strSchoolCode.startsWith("UPH"))
						fOutstanding = 0f;
						%>
					<tr>
					  <td height="20">&nbsp;</td>
					  <td><div align="right">Total Payable&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
					  <td align="right"><font size="1"><strong>
					  <%if(strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("EAC")){%>
						  <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee - fEnrollmentDiscount,true)%>
					  <%}else{%>
						  <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding - fEnrollmentDiscount - dReservationFee,true)%>
					  <%}%>
					  </strong></font></td>
					  <td>&nbsp;</td>
					</tr>
			<%if(strSchoolCode.startsWith("AUF")){%>
					<tr>
					  <td height="20">&nbsp;</td>
					  <td align="right">Old Account&nbsp;&nbsp;&nbsp;&nbsp;</td>
					  <td align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></td>
					  <td>&nbsp;</td>
					</tr>
			<%}%>
		  </table>
		</td>
	</tr>
  </table>
<%
if(WI.fillTextValue("print").compareTo("0") !=0){%>
<script language="javascript">
window.print();
</script>
<%}//incase only view
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
