<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
if(strSchoolCode.startsWith("CNU"))
	strSchoolCode = "CLDH";
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

<%if(!strSchoolCode.startsWith("AUF")){%>
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
<%}%>
-->
</style>
</head>

<body >
<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.CurriculumMaintenance,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	java.sql.ResultSet rs = null;
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
Vector vTermAll = new Vector();
Vector vTerm1 = new Vector();
Vector vTerm2 = new Vector();
Vector  vSubjEnrolled = new Vector();
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

	strTemp = " select e_sub_section.sub_sec_index, sub_code, sub_name, TERM_ESS  "+
			" from enrl_final_cur_list  "+
			" join E_SUB_SECTION on (E_SUB_SECTION.SUB_SEC_INDEX = ENRL_FINAL_CUR_LIST.SUB_SEC_INDEX) "+
			" join subject on (subject.SUB_INDEX = E_SUB_SECTION.SUB_INDEX) "+
			" where ENRL_FINAL_CUR_LIST.is_valid=1  "+
			" and ENRL_FINAL_CUR_LIST.sy_from="+astrSchYrInfo[0]+
			" and ENRL_FINAL_CUR_LIST.CURRENT_SEMESTER="+astrSchYrInfo[2]+
			" and ENRL_FINAL_CUR_LIST.user_index="+strStudIndex+
			" and is_confirmed=0 and ENRL_FINAL_CUR_LIST.IS_TEMP_STUD="+strIsTempStud;
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		vSubjEnrolled.addElement(rs.getString(1));//[0]sub_sec_index
		vSubjEnrolled.addElement(rs.getString(2)+"_"+rs.getString(3));//[1]sub_code
		vSubjEnrolled.addElement(rs.getString(4));//[2]TERM_ESS
	}rs.close();
	
	
	for (int i = 1; i < vAdvisedList.size(); i += 11) {
		strTemp = (String)vAdvisedList.elementAt(i);
		strErrMsg = (String)vAdvisedList.elementAt(i+1);
		iIndexOf = vSubjEnrolled.indexOf(strTemp+"_"+strErrMsg);
		if(iIndexOf == -1)
			continue;
		strTemp = WI.getStrValue(vSubjEnrolled.elementAt(iIndexOf + 1),"0");
		if(strTemp.equals("0")){
			vTermAll.addElement(vAdvisedList.elementAt(i));	
			vTermAll.addElement(vAdvisedList.elementAt(i+1));	
			vTermAll.addElement(vAdvisedList.elementAt(i+2));	
			vTermAll.addElement(vAdvisedList.elementAt(i+3));	
			vTermAll.addElement(vAdvisedList.elementAt(i+4));	
			vTermAll.addElement(vAdvisedList.elementAt(i+5));	
			vTermAll.addElement(vAdvisedList.elementAt(i+6));	
			vTermAll.addElement(vAdvisedList.elementAt(i+7));	
			vTermAll.addElement(vAdvisedList.elementAt(i+8));	
			vTermAll.addElement(vAdvisedList.elementAt(i+9));	
			vTermAll.addElement(vAdvisedList.elementAt(i+10));			
		}else if(strTemp.equals("1")){
			vTerm1.addElement(vAdvisedList.elementAt(i));	
			vTerm1.addElement(vAdvisedList.elementAt(i+1));	
			vTerm1.addElement(vAdvisedList.elementAt(i+2));	
			vTerm1.addElement(vAdvisedList.elementAt(i+3));	
			vTerm1.addElement(vAdvisedList.elementAt(i+4));	
			vTerm1.addElement(vAdvisedList.elementAt(i+5));	
			vTerm1.addElement(vAdvisedList.elementAt(i+6));	
			vTerm1.addElement(vAdvisedList.elementAt(i+7));	
			vTerm1.addElement(vAdvisedList.elementAt(i+8));	
			vTerm1.addElement(vAdvisedList.elementAt(i+9));	
			vTerm1.addElement(vAdvisedList.elementAt(i+10));			
		}else if(strTemp.equals("2")){
			vTerm2.addElement(vAdvisedList.elementAt(i));	
			vTerm2.addElement(vAdvisedList.elementAt(i+1));	
			vTerm2.addElement(vAdvisedList.elementAt(i+2));	
			vTerm2.addElement(vAdvisedList.elementAt(i+3));	
			vTerm2.addElement(vAdvisedList.elementAt(i+4));	
			vTerm2.addElement(vAdvisedList.elementAt(i+5));	
			vTerm2.addElement(vAdvisedList.elementAt(i+6));	
			vTerm2.addElement(vAdvisedList.elementAt(i+7));	
			vTerm2.addElement(vAdvisedList.elementAt(i+8));	
			vTerm2.addElement(vAdvisedList.elementAt(i+9));	
			vTerm2.addElement(vAdvisedList.elementAt(i+10));			
		}
			
	}

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
	strSchoolCode.startsWith("UPH") || strSchoolCode.startsWith("PWC")  || strSchoolCode.startsWith("MARINER") || 
	strSchoolCode.startsWith("NEU") || strSchoolCode.startsWith("DLSHSI"))
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
%>
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
  <tr>
    <td height="22">Student's Signature : ________________________________________________</td>
    <td>Parent's Signature : ________________________________________________</td>
  </tr>
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

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="13%" height="25" class="thinborder"><strong>SUBJECT CODE</strong></td>
    <td width="21%" class="thinborder"><strong>SUBJECT TITLE </strong></td>
    <%if(!strSchoolCode.startsWith("AUF")){%>
	<td width="4%" class="thinborder"><strong>LEC. UNITS</strong></td>
    <td width="4%" class="thinborder"><strong>LAB. UNITS</strong></td>
    <td width="4%" class="thinborder"><strong>TOTAL UNITS</strong></td>
<%}%>
    <td width="4%" class="thinborder"><strong><font size="1">UNITS TAKEN</font></strong></td>
    <td width="13%" class="thinborder"><div align="center"><strong>
		<%if(strSchoolCode.startsWith("CPU")){%>STUB CODE<%}else{%>SECTION<%}%> </strong></div></td>
    <td width="8%" class="thinborder"><strong>&nbsp;ROOM</strong></td>
    <td width="19%" class="thinborder"><strong>&nbsp;SCHEDULE</strong></td>
<%if(bolShowSubjectFee) {%>
    <td width="10%" class="thinborder"><strong>PER SUBJECT FEE</strong></td>
<%}if(bolShowLabFee) {%>
    <td width="10%" class="thinborder"><strong>LAB FEE</strong></td>
<%}%>
  </tr>
<%if(false){%>
  <tr>
      <td height="25" colspan="11" class="thinborder" align="center"><strong>SUBJECT ALL</strong></td>
    </tr>
<%
for(int i = 1; i<vAdvisedList.size(); ++i)
{%>
  <tr>
    <td height="20" class="thinborder"><%=(String)vAdvisedList.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vAdvisedList.elementAt(i+1)%></td>
<%if(!strSchoolCode.startsWith("AUF")){%>
    <td class="thinborder"><%=WI.getStrValue(vAdvisedList.elementAt(i+6),"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue(vAdvisedList.elementAt(i+7),"&nbsp;")%></td>
    <td class="thinborder"><%=(String)vAdvisedList.elementAt(i+8)%></td>
<%}%>
    <td class="thinborder"><%=(String)vAdvisedList.elementAt(i+9)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vAdvisedList.elementAt(i+3),"TBA")%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vAdvisedList.elementAt(i+4),"TBA")%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vAdvisedList.elementAt(i+2),"TBA")%> </td>
<%if(bolShowSubjectFee) {
		strTemp = (String)vAdvisedList.elementAt(i);
		//System.out.println(strTemp);
		if(strTemp.indexOf("NSTP") != -1){
          iIndexOf = strTemp.indexOf("(");
          if(iIndexOf != -1){
            strTemp = strTemp.substring(0,iIndexOf);
            strTemp = strTemp.trim();
		  }
		}
		if( (iIndexOf = fOperation.vTuitionFeeDtls.indexOf(strTemp)) != -1)
			strTemp  = (String)fOperation.vTuitionFeeDtls.elementAt(iIndexOf+2);
		else {
			strTemp  = "0.00";
		}
%>
    <td class="thinborder"><%=strTemp%></td>
<%}if(bolShowLabFee) {%>
    <td class="thinborder">&nbsp;</td>
<%}%>
  </tr>
  <%
i = i+10;
}
}


if(vTermAll.size() > 0){
%>


  <tr>
      <td height="25" colspan="11" class="thinborder" align="center"><strong>ALL TERM</strong></td>
    </tr>
<%
for(int i = 0; i<vTermAll.size(); ++i)
{%>
  <tr>
    <td height="20" class="thinborder"><%=(String)vTermAll.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vTermAll.elementAt(i+1)%></td>
<%if(!strSchoolCode.startsWith("AUF")){%>
    <td class="thinborder"><%=WI.getStrValue(vTermAll.elementAt(i+6),"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue(vTermAll.elementAt(i+7),"&nbsp;")%></td>
    <td class="thinborder"><%=(String)vTermAll.elementAt(i+8)%></td>
<%}%>
    <td class="thinborder"><%=(String)vTermAll.elementAt(i+9)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTermAll.elementAt(i+3),"TBA")%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTermAll.elementAt(i+4),"TBA")%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTermAll.elementAt(i+2),"TBA")%> </td>
<%if(bolShowSubjectFee) {
		strTemp = (String)vTermAll.elementAt(i);
		//System.out.println(strTemp);
		if(strTemp.indexOf("NSTP") != -1){
          iIndexOf = strTemp.indexOf("(");
          if(iIndexOf != -1){
            strTemp = strTemp.substring(0,iIndexOf);
            strTemp = strTemp.trim();
		  }
		}
		if( (iIndexOf = fOperation.vTuitionFeeDtls.indexOf(strTemp)) != -1)
			strTemp  = (String)fOperation.vTuitionFeeDtls.elementAt(iIndexOf+2);
		else {
			strTemp  = "0.00";
		}
%>
    <td class="thinborder"><%=strTemp%></td>
<%}if(bolShowLabFee) {%>
    <td class="thinborder">&nbsp;</td>
<%}%>
  </tr>
  <%
i = i+10;
}
}//end of all term

if(vTerm1.size() > 0){
%>


  <tr>
      <td height="25" colspan="11" class="thinborder" align="center"><strong>FIRST TERM</strong></td>
    </tr>
<%
for(int i = 0; i<vTerm1.size(); ++i)
{%>
  <tr>
    <td height="20" class="thinborder"><%=(String)vTerm1.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vTerm1.elementAt(i+1)%></td>
<%if(!strSchoolCode.startsWith("AUF")){%>
    <td class="thinborder"><%=WI.getStrValue(vTerm1.elementAt(i+6),"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue(vTerm1.elementAt(i+7),"&nbsp;")%></td>
    <td class="thinborder"><%=(String)vTerm1.elementAt(i+8)%></td>
<%}%>
    <td class="thinborder"><%=(String)vTerm1.elementAt(i+9)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTerm1.elementAt(i+3),"TBA")%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTerm1.elementAt(i+4),"TBA")%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTerm1.elementAt(i+2),"TBA")%> </td>
<%if(bolShowSubjectFee) {
		strTemp = (String)vTerm1.elementAt(i);
		//System.out.println(strTemp);
		if(strTemp.indexOf("NSTP") != -1){
          iIndexOf = strTemp.indexOf("(");
          if(iIndexOf != -1){
            strTemp = strTemp.substring(0,iIndexOf);
            strTemp = strTemp.trim();
		  }
		}
		if( (iIndexOf = fOperation.vTuitionFeeDtls.indexOf(strTemp)) != -1)
			strTemp  = (String)fOperation.vTuitionFeeDtls.elementAt(iIndexOf+2);
		else {
			strTemp  = "0.00";
		}
%>
    <td class="thinborder"><%=strTemp%></td>
<%}if(bolShowLabFee) {%>
    <td class="thinborder">&nbsp;</td>
<%}%>
  </tr>
  <%
i = i+10;
}
}//end of term 1
if(vTerm2.size() > 0){
%>

  <tr>
      <td height="25" colspan="11" class="thinborder" align="center"><strong>SECOND TERM</strong></td>
    </tr>
<%
for(int i = 0; i<vTerm2.size(); ++i)
{%>
  <tr>
    <td height="20" class="thinborder"><%=(String)vTerm2.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vTerm2.elementAt(i+1)%></td>
<%if(!strSchoolCode.startsWith("AUF")){%>
    <td class="thinborder"><%=WI.getStrValue(vTerm2.elementAt(i+6),"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue(vTerm2.elementAt(i+7),"&nbsp;")%></td>
    <td class="thinborder"><%=(String)vTerm2.elementAt(i+8)%></td>
<%}%>
    <td class="thinborder"><%=(String)vTerm2.elementAt(i+9)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTerm2.elementAt(i+3),"TBA")%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTerm2.elementAt(i+4),"TBA")%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTerm2.elementAt(i+2),"TBA")%> </td>
<%if(bolShowSubjectFee) {
		strTemp = (String)vTerm2.elementAt(i);
		//System.out.println(strTemp);
		if(strTemp.indexOf("NSTP") != -1){
          iIndexOf = strTemp.indexOf("(");
          if(iIndexOf != -1){
            strTemp = strTemp.substring(0,iIndexOf);
            strTemp = strTemp.trim();
		  }
		}
		if( (iIndexOf = fOperation.vTuitionFeeDtls.indexOf(strTemp)) != -1)
			strTemp  = (String)fOperation.vTuitionFeeDtls.elementAt(iIndexOf+2);
		else {
			strTemp  = "0.00";
		}
%>
    <td class="thinborder"><%=strTemp%></td>
<%}if(bolShowLabFee) {%>
    <td class="thinborder">&nbsp;</td>
<%}%>
  </tr>
  <%
i = i+10;
}

}//end of term 2

%>

</table>
<%//System.out.println("show fee: "+vMiscFeeInfo);
if(vMiscFeeInfo == null)
	vMiscFeeInfo = new Vector();
if(bolShowFeeDetail){//System.out.println("I am here.");%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="60%" valign="top"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
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
      </table></td>
    <td valign="top">
	<%if(strSchoolCode.startsWith("NEU")) {
	double dTotalPayable = fTutionFee+fCompLabFee+fMiscFee + fOutstanding;
		if(astrSchYrInfo[2].equals("0")){%>
        <br><br><br><br><font style="font-size:18px; font-weight:bold">Full Payment: <%=CommonUtil.formatFloat(dTotalPayable,true)%> </font>
		<%}else{%><br><br><br><br>
			<font style="font-size:14px; font-weight:bold">DownPayment (50%): <%=CommonUtil.formatFloat(dTotalPayable/2,true)%></font>
		 <%}%>
	<%}else if(strSchoolCode.startsWith("CGH")) {
	double dTotalPayable = fTutionFee+fCompLabFee+fMiscFee + fOutstanding - dReservationFee;%>
        <br><br><br><br>Full Payment : <%=CommonUtil.formatFloat(dTotalPayable,true)%> 
		<%if( dInstallmentFeeCGH == 0d) {%>
		  &nbsp;&nbsp;&nbsp; : 50% : <%=CommonUtil.formatFloat(dTotalPayable/2,true)%>
		 <%}else{%>
		 	<br>
			50% : <%=CommonUtil.formatFloat((dTotalPayable - dInstallmentFeeCGH)/2 + dInstallmentFeeCGH,true)%>
			(<%=CommonUtil.formatFloat((dTotalPayable - dInstallmentFeeCGH)/2,true)%> +  Installment Fee: <%=CommonUtil.formatFloat(dInstallmentFeeCGH,true)%>)
		 <%}%>
 	<%}else if(strSchoolCode.startsWith("UC")) {%>
        <br><br><br><br><font style="font-size:14px;"><u>Required DownPayment : <%=CommonUtil.formatFloat(dReqdDP,true)%></u></font> 
 	<%}else if(strSchoolCode.startsWith("MARINER")) {
		String strInvalidateAdviseNote = null;
		String strFullPaymentNote = null;
		
		strSQLQuery = "select SPECIFIC_DATE, amount, fee_type from FA_FEE_ADJ_ENROLLMENT  where sy_from = "+astrSchYrInfo[0]+
								" and semester = "+astrSchYrInfo[2]+"  and ADJ_PARAMETER = 0 and is_valid = 1 and specific_date is not null";
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			strFullPaymentNote = "Full Payment Discount on or before Date "+ConversionTable.convertMMDDYYYY(rs.getDate(1), true)+": "+
								CommonUtil.formatFloat(rs.getDouble(2), false)+"% on Tuition Fee";
		}
		rs.close();
		//get numbe of days advising will be removing.. 
		strSQLQuery = "select prop_val from READ_PROPERTY_FILE where prop_name= 'REMOVE_ADVISING_SUB'";
		rs =  dbOP.executeQuery(strSQLQuery);
		int iNoOfDays = -1;
		if(rs.next())
			iNoOfDays = rs.getInt(1);
		rs.close();
		
		if(iNoOfDays > -1)
			strInvalidateAdviseNote = "If NO Payment, advising will be removed after "+iNoOfDays+" days";
	%><br><br><br><br><font style="font-size:12px;">
		<%if(strFullPaymentNote != null){%>
			<%=strFullPaymentNote%><br>
		<%}if(strInvalidateAdviseNote != null){%>
			<%=strInvalidateAdviseNote%><br>
		<%}%>
		
		<br><br>
		
		<strong>MODE OF PAYMENT: </strong><br>
		Upon Enrollment: 40%<br>
		<%if(astrSchYrInfo[2].equals("0")){%>
			Midterm: 60%<br>
			Finals: 0%
		<%}else{%>
			Prelim: 20%<br>
			Midterm: 20%<br>
			Semi-Finals: 20%<br>
			Finals: 0%
		<%}%>		
		</font>
	<%}else {%>
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
double dTotalPayable = fTutionFee+fCompLabFee+fMiscFee + fOutstanding - fEnrollmentDiscount;

if(strSchoolCode.startsWith("EAC"))
	dTotalPayable = dTotalPayable - fOutstanding;

Vector vPmtSchInfo = new enrollment.FAPmtMaintenance().getAllowedPmtSchedue(dbOP, strStudIndex,astrSchYrInfo[0],astrSchYrInfo[2],
					true, paymentUtil.isTempStud());
enrollment.FAAssessment FA = new enrollment.FAAssessment();
int iNoOfInstallment = 0;
if(vPmtSchInfo != null) {
	//if(strSchoolCode.startsWith("CLDH") || strSchoolCode.startsWith("CPU")) {
	//	vPmtSchInfo.removeElementAt(vPmtSchInfo.size() - 1);
	//	vPmtSchInfo.removeElementAt(vPmtSchInfo.size() - 1);
	//	vPmtSchInfo.removeElementAt(vPmtSchInfo.size() - 1);
	//}
	iNoOfInstallment = vPmtSchInfo.size()/ 3 + 1;//System.out.println(vPmtSchInfo);
	if(strSchoolCode.startsWith("CLDH")) {
		//dTotalPayable = dTotalPayable/2;//for CLDH, 50% downpayment.
		//if(iNoOfInstallment > 1) {
		//	--iNoOfInstallment;
		//}
		//strErrMsg  = CommonUtil.formatFloat(dTotalPayable/iNoOfInstallment,true);
		dTotalPayable = dTotalPayable/(iNoOfInstallment);
		strErrMsg  = CommonUtil.formatFloat(dTotalPayable,true);
		
		
	}
	//for NU, d/p is other charges + misc fee.
	else if(strSchoolCode.startsWith("NU")){
		if(astrSchYrInfo != null && astrSchYrInfo[2].equals("0")) {
			strErrMsg = "0.00";
		}
		else {
			dTotalPayable = dTotalPayable - fTutionFee;
			strErrMsg = CommonUtil.formatFloat(fTutionFee/(iNoOfInstallment-1),true);
		}
		strSchoolCode = "CLDH";
	}
	else {
		dTotalPayable    = dTotalPayable/iNoOfInstallment;
		dTemp = FA.convertDoubleToNearestInt(strSchoolCode, dTotalPayable);
		if(dTemp != null) {
			dTotalPayable = dTemp[0];
			dDiff = dTemp[1] * iNoOfInstallment;
		}
		strErrMsg        = CommonUtil.formatFloat(dTotalPayable,true);
	}
}
if(iNoOfInstallment > 0){%>
        <tr>
          <td height="20">Downpayment :
		  <%if(strSchoolCode.startsWith("CLDH")) {%>
		  <%=CommonUtil.formatFloat(dTotalPayable,true)%>
		  <%}else{%>
		  <%=strErrMsg%>
		  <%}%>
		  </td>
        </tr>
<%for(int i = 0; i < vPmtSchInfo.size(); i += 3){
	//if last then i have to get the total payable + diff.
	if((i + 4) > vPmtSchInfo.size()) {
		strErrMsg        = CommonUtil.formatFloat(dTotalPayable + dDiff,true);
		
	}%>
        <tr>
          <td height="20"><%=((String)vPmtSchInfo.elementAt(i + 1)).toUpperCase()%> DUE : <%=strErrMsg%></td>
        </tr>
<%}
}%>
	 </table>
<%}%>
<br>
<%
//another table for enrollment data parameter.. 
if(strSchoolCode.startsWith("EAC")){
boolean bolIsCavite = false;
strTemp = dbOP.getResultOfAQuery("select info5 from sys_info", 0);
if(strTemp != null && strTemp.equals("Cavite"))
	bolIsCavite = true;

strTemp = null;
strSQLQuery = "select SPECIFIC_DATE, amount, fee_type from FA_FEE_ADJ_ENROLLMENT  where sy_from = "+astrSchYrInfo[0]+
						" and semester = "+astrSchYrInfo[2]+"  and ADJ_PARAMETER = 0 and is_valid = 1 and specific_date is not null";
rs = dbOP.executeQuery(strSQLQuery);
if(rs.next()) {
	double dDisAmt = (double)fTutionFee * rs.getDouble(2)/100d;
	
	strTemp = ConversionTable.convertMMDDYYYY(rs.getDate(1), true)+": "+rs.getDouble(2)+"% on Tuition ("+CommonUtil.formatFloat(dDisAmt, true)+")";
}
rs.close();
if(strTemp != null) {%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td>Full Payment Discount on or before <%=strTemp%> </td>
		</tr>
	</table>
<%}if(strSchoolCode.startsWith("EAC")) {%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td>Note: If No Payment, Advising will be removed after 2 days.</td>
		</tr>
	</table>
<%}

}%>
<%if(strSchoolCode.startsWith("UPH")) {%>
	<table width="80%" cellpadding="0" cellspacing="0" border="0" 
	style="border-top:solid 1px #000000; border-bottom:solid 1px #000000; border-left:solid 1px #000000; border-right:solid 1px #000000">
		<tr>
			<td style="font-weight:bold; font-size:11px;" bgcolor="#eeeeee">Note: If No Payment, Advising will be removed after 3 days.</td>
		</tr>
	</table>
<%}%>
   </td>
  </tr>
</table>
<%}%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="18" colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td width="16%" >Advised and printed by : </td>
    <td height="25"><strong><u><%=strPrintedBy%></u></strong></td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <%if(!strSchoolCode.startsWith("WUP") && !bolIsOnlineAdvising){%>
  <tr>
    <td width="16%" height="18">&nbsp;</td>
    <td colspan="3" valign="top"><em>Dean / Faculty/Secretary</em></td>
  </tr>
  <%}if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("EAC") && 
  !strSchoolCode.startsWith("WUP") && !strSchoolCode.startsWith("UPH") && !bolIsOnlineAdvising){%>
  <tr>
    <td height="18">&nbsp;</td>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="25">Approved by : </td>
    <td width="37%" height="25">_____________________________________</td>
    <td> <%if(!strSchoolCode.startsWith("CPU") && !strSchoolCode.startsWith("CLDH")){%>
      Confirmed by :
      <%}%> </td>
    <td> <%if(!strSchoolCode.startsWith("CPU") && !strSchoolCode.startsWith("CLDH")){%>
      ___________________________________
      <%}%></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25" valign="top"><em>College Dean/Dept. Head</em></td>
    <td width="10%">&nbsp;</td>
    <td width="37%" valign="top"> <%if(!strSchoolCode.startsWith("CPU") && !strSchoolCode.startsWith("CLDH")){%> <em>Registrar</em> <%}%> </td>
  </tr>
  <%}//do not show for AUF.

if(strSchoolCode.startsWith("LNU")){%>
  <tr>
    <td height="25" colspan="4"><font size="2"><strong>NOTE : </strong><br>
    Please proceed to Student Affairs Office for ID application/validation to be <strong>OFFICIALLY ENROLLED
    <br>Get ten percent
      (10%) discount on tuition fees upon full paymentof total school fees not
      later than 1st week of classes</strong></font></td>
  </tr>
  <tr>
    <td height="25" colspan="4" align="center">
	<table width="98%" cellpadding="0" cellspacing="0" class="thinborderALL">
        <tr>
          <td width="20%" align="center">ISSUE STATUS</td>
          <td width="20%" align="center">REVISION</td>
          <td width="20%" align="center">DATE</td>
          <td width="20%" align="center">APPROVED BY</td>
          <td width="20%" align="center">PAGE</td>
        </tr>
        <tr>
          <td align="center">1</td>
          <td align="center">0</td>
          <td align="center">15 May 2005</td>
          <td align="center">(SGD) Atty. Gonzalo T. Duque</td>
          <td align="center">1</td>
        </tr>
      </table>
	</td>
  </tr>
  <%}%>
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
