<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,
	enrollment.FAAssessment,enrollment.SubjectSection,enrollment.EnrlAddDropSubject,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	strSchoolCode = "UC";
	boolean bolIsFatima = strSchoolCode.startsWith("FATIMA");
	
	if(strSchoolCode == null) {
		%>
		<font style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:#FF0000">
			You are already logged out. Please login again to access this page.
		<%
		return;
	}
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
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPBOTTOM {
    border-bottom: solid 1px #000000;
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPBOTTOMRIGHT {
    border-bottom: solid 1px #000000;
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
-->
</style>
</head>

<body onLoad="window.print();" leftmargin="0" rightmargin="0" bottommargin="0">
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
		dbOP = new DBOperation();
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
String strStudID   = WI.fillTextValue("stud_id");
String strSYFrom   = WI.fillTextValue("sy_from");
String strSYTo     = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");

String strAdviser = null;

if(strStudID.length() ==0 || strSYFrom.length() == 0 || strSemester.length() == 0)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Student ID, SY-Term can't be empty.</font></p>
		<%
	dbOP.cleanUP();
	return;
}

Vector vStudInfo = null;
Vector vTemp = null;
Vector vScheduledPmt = new Vector(); Vector vScheduledPmtNew = null;
Vector vAssessedSubDetail = null;


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

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
Advising advising = new Advising();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

//double dDPFineCGH = 0d;
double dFatimaInstallmentFee = 0d;
String strEnrollmentNo = null;

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
				strStudID,strSYFrom,strSYTo,strSemester);
if(vStudInfo == null) strErrMsg = enrlStudInfo.getErrMsg();
else
{//System.out.println(vStudInfo);
	astrSchYrInfo[0] = strSYFrom;
	astrSchYrInfo[1] = strSYTo;
	astrSchYrInfo[2] = strSemester;

	paymentUtil.setTempUser("0");
	
	strTemp = "select c_name, dean_name,tution_type from college join course_offered on (course_offered.c_index = college.c_index) where course_index = "+(String)vStudInfo.elementAt(5);
	rs = dbOP.executeQuery(strTemp); 
	strTemp = null;
	if(rs.next()) {
		strCollegeName = rs.getString(1);
		strDeanName    = rs.getString(2);
		strTemp = rs.getString(3);
	}
	rs.close();
	
	///get here cur_hist_index
	strEnrollmentNo = "select cur_hist_index from stud_curriculum_hist where sy_from = "+strSYFrom+" and semester = "+strSemester+
						" and is_valid = 1 and user_index = "+vStudInfo.elementAt(0);
	strEnrollmentNo = dbOP.getResultOfAQuery(strEnrollmentNo, 0);
	if(strTemp != null && strTemp.equals("2")) {
		astrConvertSem[1] = "1st Trimester";
		astrConvertSem[2] = "2nd Trimester";
		astrConvertSem[3] = "3rd Trimester";
	}
	if(strEnrollmentNo != null) {
		while(strEnrollmentNo.length() < 6)
			strEnrollmentNo = "0"+strEnrollmentNo;
	}
	
	strTemp = "select encoded_by from enrl_final_cur_list where sy_from = "+strSYFrom+" and current_semester = "+strSemester+
			" and user_index = "+vStudInfo.elementAt(0)+" order by enroll_index desc";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null) {
		strTemp = "select fname, mname, lname from user_table where user_index = "+strTemp;
		rs = dbOP.executeQuery(strTemp);
		if(rs.next())
			strAdviser = WI.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 4);
		rs.close();
	}

}
if(strErrMsg == null) //collect fee details here.
{
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					strSYFrom,strSYTo,(String)vStudInfo.elementAt(4),strSemester);

	if(fTutionFee > 0f)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					strSYFrom,strSYTo,(String)vStudInfo.elementAt(4),strSemester);
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					strSYFrom,strSYTo,(String)vStudInfo.elementAt(4),strSemester);
		fOperation.checkIsEnrolling(dbOP, (String)vStudInfo.elementAt(0),
				strSYFrom,strSYTo,strSemester);
		fOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));
		//I have to remove the ledg_history informations.
		if(!paymentUtil.isTempStud()) {
			double dLedgHistoryExcess = fOperation.calLedgHistoryEntryAfterASYTerm(dbOP, (String)vStudInfo.elementAt(0),
            	                                         strSYFrom, strSemester);
			if(dLedgHistoryExcess != fOperation.fDefaultErrorValue)
				fOutstanding -= (float)dLedgHistoryExcess;
		}
		fMiscOtherFee = fOperation.getMiscOtherFee();

		enrollment.FAFeeOperationDiscountEnrollment test = new enrollment.FAFeeOperationDiscountEnrollment();
		vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					strSYFrom,strSYTo,
                                        (String)vStudInfo.elementAt(4),strSemester,
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
					strSYFrom,strSYTo,(String)vStudInfo.elementAt(4),
					strSemester,"1",strDegreeType);
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
	//get scheduled payment information.
	vScheduledPmt =FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),strSYFrom,strSYTo,(String)vStudInfo.elementAt(4),
					strSemester);

	vScheduledPmtNew = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vStudInfo.elementAt(0),strSYFrom,strSYTo,(String)vStudInfo.elementAt(4),
					strSemester);
}

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


if(vStudInfo != null && vStudInfo.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td>UNIVERSITY OF THE CORDILLERAS</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td> Governor Pack Road, Baguio City&nbsp;</td>
    <td width="50%" align="right">Date and Time Printed:<%=WI.getTodaysDate(1) +"  " + WI.formatDateTime(Long.parseLong(WI.getTodaysDate(28)),3)%></td>
  </tr>


  <tr>
    <td colspan="2" align="center" valign="bottom"><font style="font-size:16px;"><strong>FINAL CLASS SCHEDULE</strong></font></td>
  </tr>
  
  <tr>
    <td colspan="2"height="25" align="center" valign="top" style="font-size:9px;"><strong><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%> SY <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%></strong></td>
  </tr>
  <tr>
  	<td width="50%"></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td width="50%">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				
				<tr>
					<td width="24%">Enrollment No.</td>
					<td><%=strEnrollmentNo%></td>
				</tr>
				<tr>
					<td colspan="2"></td>
				</tr>
				<tr>
				  <td colspan="2">			      </td>
			  </tr>
				<tr>
					<td width="24%">Student ID</td>
					<td><%=strStudID%> (<%=(String)vStudInfo.elementAt(15)%>)</td>
				</tr>
				<tr>
					<td width="24%">Student Name</td>
					<td><%=(String)vStudInfo.elementAt(1)%></td>
				</tr>
			</table>
		</td>
		<td width="50%" valign="top">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td width="17%" align="right">Course&nbsp;&nbsp;&nbsp;</td>
					<td width="83%" style="font-size:8px;"><%=(String)vStudInfo.elementAt(2)%></td>
				</tr>
				<tr>
					<td colspan="2"></td>
				</tr>
				<tr>
					<td width="17%" align="right">Major&nbsp;&nbsp;&nbsp;</td>
					<td style="font-size:8px;"><%=WI.getStrValue(vStudInfo.elementAt(3))%></td>
				</tr>
				<tr>
					<td width="17%" align="right">Year&nbsp;&nbsp;&nbsp;</td>
					<td style="font-size:8px;"><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>


<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0)
{%>
<table width="100%" cellpadding="0" cellspacing="0" border="0" height=""><tr><td valign="top">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr align="center">
    <td width="12%" class="thinborderTOPBOTTOMRIGHT" style="font-size:8px;"><strong>SECTION</strong></td>
    <td width="12%" height="18" class="thinborderTOPBOTTOMRIGHT" style="font-size:8px;"><strong>SUBJECT CODE </strong></td>
    <td width="42%" class="thinborderTOPBOTTOMRIGHT" style="font-size:8px;"><strong>SUBJECT TITLE </strong></td>
    <td width="23%" class="thinborderTOPBOTTOMRIGHT" style="font-size:8px;"><strong>SCHEDULE</strong></td>
    <td width="8%" class="thinborderTOPBOTTOMRIGHT" style="font-size:8px;"><strong>ROOM </strong></td>
    <td width="3%" class="thinborderTOPBOTTOM" style="font-size:8px;"><strong>UNITS</strong></td>
  </tr>
  <%//System.out.println(vAssessedSubDetail);
 	float fFirstInstalAmt = 0f;
	float fTotalLoad = 0;float fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	float fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.
String strSchedule = null;
String strRoom = null; String strSection = null;
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

			if(strRoom == null)
			{
				strSection  = (String)vSubSecDtls.elementAt(b);
				strRoom     = (String)vSubSecDtls.elementAt(b+1);
				strSchedule = (String)vSubSecDtls.elementAt(b+2);
			}
			else
			{
				strRoom += "<br>"+(String)vSubSecDtls.elementAt(b+1);
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
			strRoom += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
%>
  <tr >
    <td class="thinborderRIGHT" style="font-size:8px;" height="18"><%=WI.getStrValue(strSection,"N/A")%></td>
    <td class="thinborderRIGHT" style="font-size:8px;"><%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
    <td class="thinborderRIGHT" style="font-size:8px;"><%=(String)vAssessedSubDetail.elementAt(i+2)%></td>
    <td class="thinborderRIGHT" style="font-size:8px;"><%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class="thinborderRIGHT" style="font-size:8px;"><%=WI.getStrValue(strRoom,"N/A")%></td>
    <td class="thinborderNONE" align="center" style="font-size:8px;"><%=(String)vAssessedSubDetail.elementAt(i+9)%></td>
  </tr>
  <% i = i+9;
strRoom = null;
strSchedule = null;
}%>
  <tr >
    <td colspan="5" align="right" class="thinborderTOP">
        <%if(strErrMsg != null){%>
        	<%=strErrMsg%>
        <%}else{%>
        TOTAL LOAD UNITS:&nbsp; 
        <%}%>    
	</td>
    <td class="thinborderTOP">
        <%if(strErrMsg == null){%>
        	<%=fUnitsTaken%>
        <%}%>    
	</td>
  </tr>
</table>
</td></tr></table><!-- added to have fixex height -->

<%}//if vAssessedSubDetail no null
if(fTutionFee > 0) {
	fTotalPayableAmt = fTutionFee+fCompLabFee+fMiscFee + fOutstanding  - fEnrollmentDiscount;
double dOSBal = Double.parseDouble(ConversionTable.replaceString((String)vScheduledPmtNew.elementAt(6), ",",""));
 %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td width="35%" height="14" valign="top">&nbsp;
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
         <tr>
          <td width="67%" height="18">Old accounts/(Advance)</td>
          <td width="33%"><div align="right"><font size="1">Php <%=CommonUtil.formatFloatToLedger(fOutstanding)%></font></div></td>
        </tr>
         <tr>
          <td height="18">TOTAL ASSESSMENT</td>
          <td align="right">Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + dFatimaInstallmentFee,true)%></td>
          </tr>
         <tr>
           <td height="18">CURRENT BALANCE </td>
           <td align="right"><strong><font size="1">Php </font><%=CommonUtil.formatFloat(dOSBal, true)%></strong></td>
         </tr>
      </table>

	</td>
    <td width="27%">&nbsp;</td>
    <td width="38%" valign="top">&nbsp;
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
 
        <tr>
          <td valign="top" colspan="2">
		  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td width="65%" valign="top">
					<table width="80%" cellpadding="0" cellspacing="0">
						<%
							double dAmtDue = 0; 
							//System.out.println(dOSBal);
							//System.out.println(vScheduledPmtNew);
							double dCumulativeBal = 0d;
							
							for(int i = 7; i < vScheduledPmtNew.size(); i += 2) {
								dAmtDue = ((Double)vScheduledPmtNew.elementAt(i + 1)).doubleValue();//System.out.println("Amt Due: "+dAmtDue);
								dCumulativeBal += dAmtDue;
								if(dAmtDue > dCumulativeBal)
									dAmtDue = dCumulativeBal;
									
								if(dCumulativeBal <= 0d || dAmtDue <=0d || dOSBal <=0d) 
									dAmtDue = 0d;
								%>				
									<tr>
									  <td height="15" width="5%">&nbsp;</td>
									  <td width="45%"><%=vScheduledPmtNew.elementAt(i)%></td>
									  <td align="right"><%=CommonUtil.formatFloat(dAmtDue, true)%></td>
									</tr>
							<%}%>
					</table>
					<div>Advised by: <%=strAdviser%></div>
					
					
					</td>
				
				</tr>
			</table>		  </td>
        </tr>
      </table>
	</td>
  </tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" class="">

 <tr>
   <td height="18px" colspan="3" style="font-size:12px;"><strong>IMPORTANT NOTES:</strong></td>
 </tr>
 <tr>
   <td colspan="3">&nbsp;1.  This is your final class schedule.</td>
 </tr>
 <tr>
   <td colspan="3">&nbsp;2.  Please check all information indicated in this form, including course, major and year level.</td>
 </tr>
 <tr>
   <td colspan="3">&nbsp;3.  Any unauthorized erasures or alterations to this form renders it INVALID.</td>
 </tr>
 <tr>
   <td colspan="3">&nbsp;4.  Please immediately notify the Office of the College Dean of any discrepancies.<!-- by accomplishing Adding/Dropping Form within <u>6 days</u> from the date this form was printed. If the Dean's Office does not receive any change/s within the 6-day deadline, this class schedule shall be considered <b>FINAL.</b>--></td>
 </tr>
 <tr>
   <td height="18" colspan="3" valign="bottom"><font size="1"><b>DISCLAIMER:</b></font></td>
  </tr>
 <tr>
   
   <td colspan="2">Total tuition and other school fees are computed based on information received by the Accounting Office as of the date this form was printed.</td>
  </tr>
 <tr>
  
   <td width="6%" ><u>Omissions</u></td>
   <td width="93%" ><div>/inclusions related to school fees are not included in the initial computation of fees and will be subsequently adjusted.</div></td>
 </tr>
</table>
<%	}//if student information exists.
}//if miscellaneous fee information exists.
dbOP.cleanUP();
%>
</body>
</html>
