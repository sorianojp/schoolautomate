<%
	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";
	//strSchoolCode = "CGH";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana,Arial,sans-serif,  Geneva, Helvetica ;
	font-size: 9px;
}

td {
	font-family:  Verdana,Arial, sans-serif,  Geneva,Helvetica ;
	font-size: 9px;
}

th {
	font-family: Verdana, Arial, sans-serif,Geneva, Helvetica ;
	font-size: 9px;
}
   TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family:  Verdana,Arial,sans-serif, Geneva,  Helvetica;
	font-size: 9px;
    }

    TD.topBottom {
    border-top: dashed 1px #000000;
    border-bottom: dashed 1px #000000;
	font-family: Verdana,Arial, sans-serif, Geneva, Helvetica ;
	font-size: 9px;
    }
	TD.thinborder {
    border-left: dashed 1px #000000;
    border-bottom: dashed 1px #000000;
	font-family: Verdana,Arial,sans-serif, Geneva,  Helvetica ;
	font-size: 9px;
    }
	
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana,Arial,sans-serif, Geneva,  Helvetica ;
	font-size: 11px;
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

	String strDegreeType  = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
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

float fTutionFee        = 0f;
float fCompLabFee       = 0f;
float fMiscFee          = 0f;
float fOutstanding      = 0f;
float fTotalPayableAmt 	= 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,



float fEnrollmentDiscount = 0f; //this sum of full payment, early enrollment or late enrollment discount/fine implementations.
String strEnrolmentDiscDetail = null;
float fPayableAfterDiscount = 0f;
double dTotalLaboratory = 0d;
double dOldAccountPayment = 0d;
double dSubLaboratory  = 0d;
float fScholarshipGrants = 0f;

String 	strCollegeName = null;


double dReservationFee = 0d;//only for CGH.

enrollment.SubjectSectionCPU ssCPU = new enrollment.SubjectSectionCPU();
SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
Advising advising = new Advising();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

Vector vAssessedSubDetail = null;
Vector vInstallmentDtls = null;
Vector vAssessedHrDetail_ = new Vector();
Vector vTuitionFeeDtls_ = new Vector();
float fTotalAssessedHour_ = 0f;
int iIndexOf = -1;

String[] astrWeekDay = {"S","M","T","W","TH","F","SAT",""};

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

if(vStudInfo == null) {
	strErrMsg = enrlStudInfo.getErrMsg();
}else
{//System.out.println(vStudInfo);
	astrSchYrInfo[0] = (String)vORInfo.elementAt(23);
	astrSchYrInfo[1] = (String)vORInfo.elementAt(24);
	astrSchYrInfo[2] = (String)vORInfo.elementAt(22);

	paymentUtil.setTempUser("0");
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        (String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
        (String)vORInfo.elementAt(22),false,false,true);//System.out.println("Test : "+vMiscFeeInfo);
		
	strCollegeName = new CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(5));
	
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
}
if(strErrMsg == null) //collect fee details here.
{

	if (strSchoolCode.startsWith("CPU")) { 
		fOperation.bolComputeTFI = true;
		fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),
						paymentUtil.isTempStud(), (String)vORInfo.elementAt(23),
						(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));

		vAssessedHrDetail_.addAll(fOperation.vAssessedHrDetail);
		vTuitionFeeDtls_.addAll(fOperation.vTuitionFeeDtls);
		
		fOperation.bolComputeTFI = false;
		fOperation.resetFees();
	}
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),
					paymentUtil.isTempStud(), (String)vORInfo.elementAt(23),
					(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));

	//System.out.println((String)vORInfo.elementAt(4));
	if(fTutionFee > 0f)
	{
		// strTemp = 
		strTemp = dbOP.mapOneToOther("temp_fee_adjust","user_index",(String)vStudInfo.elementAt(0), 
		"sum(adjust_amt)", " and is_temp_stud = " +  (String)vORInfo.elementAt(29) + 
		" and (is_rejected = 0  or is_rejected is null) ");

//		System.out.println("strTemp : " + strTemp);

		if (strTemp != null) 
			fScholarshipGrants = Float.parseFloat(strTemp);


		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
					(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));

		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
					(String)vORInfo.elementAt(22));
					
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
	

		vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,
							(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
							(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
                                        (String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),
                                        fOperation.dReqSubAmt);

		if(vTemp != null && vTemp.size() > 0)
			strEnrolmentDiscDetail = (String)vTemp.elementAt(0);//System.out.println(vTemp);
		if(strEnrolmentDiscDetail != null && vTemp != null && vTemp.size() > 0)
		{
			fEnrollmentDiscount = ((Float)vTemp.elementAt(1)).floatValue();
			fPayableAfterDiscount = fTutionFee+fMiscFee+fCompLabFee+
										fOutstanding-fEnrollmentDiscount;
		}

		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5), 
								"degree_type"," and is_valid=1 and is_del=0");
								
		vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),
					paymentUtil.isTempStud(),(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
					(String)vStudInfo.elementAt(4),	(String)vORInfo.elementAt(22),"1",strDegreeType);
					
//./		System.out.println("vAssessedSubDetail : " + vAssessedSubDetail);		
		
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
		vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),
						 paymentUtil.isTempStud(), (String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
						 (String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),true);
						 
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
		vMiscFeeInfo.addElement(null);
	}

	vInstallmentDtls = FA.getInstallmentPayablePerStudent(dbOP,(String)vStudInfo.elementAt(0),
							(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
							(String)vStudInfo.elementAt(4), (String)vORInfo.elementAt(22),false, true) ;
	if(vInstallmentDtls == null)
		strErrMsg = FA.getErrMsg();

//	System.out.println("vInstallmentDtls : " + vInstallmentDtls);

}


if(fMiscFee <=0.1f) {
	vMiscFeeInfo = new Vector();
	vMiscFeeInfo.addElement("");	
	vMiscFeeInfo.addElement("");
	vMiscFeeInfo.addElement("");
	vMiscFeeInfo.addElement(null);
}

%>

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

	if (((String)vStudInfo.elementAt(5)).equals("0"))
		strTemp = "PRE-COLLEGIATE";
	else
		strTemp = "COLLEGIATE"; 
%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" >
<tr>
 <td width="61%">&nbsp;</td>
 <td width="39%"><%=strTemp%> <br>
   <br>
   <% if (astrSchYrInfo[2].equals("0")) {
   		strTemp = astrConvertSem[Integer.parseInt(astrSchYrInfo[2])] +" " + astrSchYrInfo[1];
	  }else{
   		strTemp = astrConvertSem[Integer.parseInt(astrSchYrInfo[2])] +" " +  
   					astrSchYrInfo[0] + " - " + astrSchYrInfo[1];
	  }
    %>
   <%=strTemp%><br>
   <br>&nbsp;</td>
 </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td height="18" colspan="2">Name : &nbsp;<strong><font size="1"><%=(String)vStudInfo.elementAt(1)%></font></strong></td>
    <td colspan="2">ID # : <strong><font size="1"><%=(String)vORInfo.elementAt(25)%></font></strong></td>
  </tr>
  <tr>
    <td width="35%" height="18">Course &amp; Year &nbsp;:&nbsp; <strong><%=(String)vStudInfo.elementAt(16)%>
        <%if(vStudInfo.elementAt(6) != null){%>
/ <%=WI.getStrValue(vStudInfo.elementAt(3))%>
<%}%><%=WI.getStrValue((String)vStudInfo.elementAt(4)," - ","","")%> </strong></td>
    <td width="35%">&nbsp;<%=strCollegeName%></td>
    <td width="9%">Classification:&nbsp;</td>
<% strTemp =(String)vStudInfo.elementAt(15);
	if (strTemp.equals("Transferee") ||  strTemp.equals("Second Course"))
		strTemp = "New";
	else if (strTemp.equals("Second Course(Old)") || strTemp.equals("Old"))
		strTemp = "Regular";

	 if (new enrollment.CourseRequirement().isForeignNational(dbOP, 
	 									(String)vStudInfo.elementAt(0),
										((String)vORInfo.elementAt(25)).equals("1"))){
	 	strTemp = "Foreign";
	 }
%>
	
	
    <td width="21%">&nbsp;<%=strTemp%></td>
  </tr>
</table>
<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0) {%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr >
    <td width="8%" height="19" class="topBottom"><strong>Stub</strong></td>
    <td width="17%" class="topBottom"><strong>Subject</strong></td>
    <td width="6%" height="19" class="topBottom"><div align="center"><strong>Cr</strong></div></td>
    <td width="12%" class="topBottom"><div align="center"><strong>Time</strong></div></td>
    <td width="12%" class="topBottom"><strong>Day</strong></td>
    <td width="10%" class="topBottom"><strong>Room</strong></td>
    <td width="20%" class="topBottom"><strong>Instructor</strong></td>
    <td width="5%" class="topBottom"><strong>Unt</strong></td>
    <td width="10%" class="topBottom"><strong>Lab. Fee</strong> </td>
  </tr>
  <%
	float fTotalLoad = 0;float fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	float fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.
String strSchedule = null;
String strRoomAndSection = null;

	String strRatePerUnit = null;
	String strAssessedHour = null;// the assessment is per hour.
	Vector vSubSecDtls = new Vector();
	String strFeeTypeCatg = null; //0=>per unit,1= per lec/lab, 2=per subject,3=total tuition fee.

	int iIndex = 0;
	String strSubTotalRate = null;//System.out.println(vTuitionFeeDtls_);

	int j = 0 ; 
	Vector vSubSchedule = null;
	String strWeekDay = null;
	String strTime  = null;
	String strCurrTime = null;
	String strLabRoom = "";
	String strLabWeekDay = "";
	String strLabTime = "";
	String strInstructor = "";
	String strLabInstructor = "";
	String strCurrTimeEntry = null;
	int iHr = 0;
	String strLabSubSecIndex = null;
	boolean bolWithLab = false;
				
	for(int i = 0; i< vAssessedSubDetail.size() ; ++i)
	{	bolWithLab = false;
		if(strFeeTypeCatg == null)	
			strFeeTypeCatg = (String)vAssessedSubDetail.elementAt(8);

		fTotalUnit = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+3))+
						Float.parseFloat((String)vAssessedSubDetail.elementAt(i+4));
						
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
		
		iIndex = vTuitionFeeDtls_.indexOf(strTemp);
//		System.out.println("vTuitionFeeDtls_ : " + vTuitionFeeDtls_);
		if(  iIndex != -1) {
			strRatePerUnit = (String)vTuitionFeeDtls_.elementAt(iIndex+1);
			strSubTotalRate  = (String)vTuitionFeeDtls_.elementAt(iIndex+2);
			if(iIndex %3 > 0)
				iIndex = iIndex / 3 + 1;
			else
				iIndex = iIndex / 3;

			if(vAssessedHrDetail_ != null && vAssessedHrDetail_.size() > iIndex){
				strAssessedHour = (String)vAssessedHrDetail_.elementAt(iIndex);
				fTotalAssessedHour_ += Float.parseFloat((String)vAssessedHrDetail_.elementAt(iIndex));
			}else
				strAssessedHour = "";

			
			
		}
		else {
			strRatePerUnit = "0.00";
			strSubTotalRate  = "0.00";
			strAssessedHour = "";
		}

		//get schedule here.
		vSubSchedule = null;

		strInstructor = "";
		strLabInstructor = "";				

		
		if(strSubSecIndex != null && !strSubSecIndex.equals("-1")) {
			vSubSecDtls = ssCPU.operateOnSchedule(dbOP,request,0,strSubSecIndex);
						

			if ( vSubSecDtls != null) {
				vSubSchedule = (Vector) vSubSecDtls.elementAt(20);
				strInstructor = (String)vSubSecDtls.elementAt(21);
			}
			
			if ( vSubSchedule != null) {
				strRoomAndSection = "";
				strWeekDay = "";
				strTime  = "";
				strLabRoom = "";
				strLabWeekDay = "";
				strLabTime  = "";				
				strCurrTime ="";
				strCurrTimeEntry = null;
				iHr = 0;
				
				for(j = 0; j < vSubSchedule.size() ; j+=9){
					iHr = Integer.parseInt(WI.getStrValue((String)vSubSchedule.elementAt(j+2),"0")) + 
							Integer.parseInt(WI.getStrValue((String)vSubSchedule.elementAt(j+4),"0"))*12;
							
					strCurrTimeEntry = CommonUtil.formatMinute(Integer.toString(iHr)) + 
							WI.getStrValue((String)vSubSchedule.elementAt(j+3),"0");
							
					iHr = Integer.parseInt(WI.getStrValue((String)vSubSchedule.elementAt(j+5),"0"));
					if (WI.getStrValue((String)vSubSchedule.elementAt(j+7),"0").equals("1") && 
						iHr != 12){
						iHr +=  12;
					}
						
							
					strCurrTimeEntry += "-" + CommonUtil.formatMinute(Integer.toString(iHr)) + 
							WI.getStrValue((String)vSubSchedule.elementAt(j+6),"0");


				if (!strCurrTime.equals(strCurrTimeEntry)){
					strCurrTime = strCurrTimeEntry;
					if (strTime.length() == 0) {
						strTime = strCurrTime;
						strWeekDay = 
								astrWeekDay[Integer.parseInt(WI.getStrValue((String)vSubSchedule.elementAt(j+1),"0"))];
						strRoomAndSection = WI.getStrValue((String)vSubSchedule.elementAt(j+8),"TBA");
					}else{
						strTime += "<br>" + strCurrTime;
						strWeekDay +="<br>" +
								 astrWeekDay[Integer.parseInt(WI.getStrValue((String)vSubSchedule.elementAt(j+1),"0"))];
						strRoomAndSection +="<br>" +
								WI.getStrValue((String)vSubSchedule.elementAt(j+8),"TBA");
					}
					continue;
				  }
				
					strWeekDay += astrWeekDay[Integer.parseInt(WI.getStrValue((String)vSubSchedule.elementAt(j+1),"0"))];
			  }
			  
			  // laboratory schedule 
			strLabSubSecIndex = ssCPU.getLabSchIndex(dbOP, strSubSecIndex);
					
			if (strLabSubSecIndex != null) {
				bolWithLab  = true;
				vSubSecDtls = ssCPU.operateOnSchedule(dbOP,request,0,strLabSubSecIndex);
				strLabInstructor = (String)vSubSecDtls.elementAt(21);
				
				if ( vSubSecDtls != null) 
					vSubSchedule = (Vector) vSubSecDtls.elementAt(20);
			
				if ( vSubSchedule != null) {
					strLabRoom = "";
					strLabWeekDay = "";
					strLabTime  = "";
					strCurrTime ="";
					strCurrTimeEntry = "";
					iHr = 0;
				
				for(j = 0; j < vSubSchedule.size() ; j+=9){
					iHr = Integer.parseInt(WI.getStrValue((String)vSubSchedule.elementAt(j+2),"0")) + 
							Integer.parseInt(WI.getStrValue((String)vSubSchedule.elementAt(j+4),"0"))*12;
							
					strCurrTimeEntry = Integer.toString(iHr) + 
							WI.getStrValue((String)vSubSchedule.elementAt(j+3),"0");
							
					iHr = Integer.parseInt(WI.getStrValue((String)vSubSchedule.elementAt(j+5),"0"));
					if (WI.getStrValue((String)vSubSchedule.elementAt(j+7),"0").equals("1") 
						&& iHr != 12){
						iHr +=  12;
					}
							
					strCurrTimeEntry += "-" + CommonUtil.formatMinute(Integer.toString(iHr)) + 
							WI.getStrValue((String)vSubSchedule.elementAt(j+6),"0");


				if (!strCurrTime.equals(strCurrTimeEntry)){
					strCurrTime = strCurrTimeEntry;				
					if (strLabTime.length() == 0) {
						strLabTime = strCurrTime;
						strLabWeekDay =  
								astrWeekDay[Integer.parseInt(WI.getStrValue((String)vSubSchedule.elementAt(j+1),"0"))];
						strLabRoom = WI.getStrValue((String)vSubSchedule.elementAt(j+8),"TBA");
					}else{
						strLabTime += "<br>" + strCurrTime;
						strLabWeekDay +="<br>" +
								 astrWeekDay[Integer.parseInt(WI.getStrValue((String)vSubSchedule.elementAt(j+1),"0"))];
						strLabRoom +="<br>" +
								WI.getStrValue((String)vSubSchedule.elementAt(j+8),"TBA");
					}
					continue;
				  }
					strLabWeekDay += astrWeekDay[Integer.parseInt(WI.getStrValue((String)vSubSchedule.elementAt(j+1),"0"))];
				} // end for loop
			   }
			  }
			 }
		    }
			
			
			if(strSubSecIndex != null && strSubSecIndex.equals("-1")){
				strSubSecIndex = "*****";
				strTime = " re - enroll ";
				strWeekDay = "***";
				strRoomAndSection = "*****";
				strInstructor = "*******";
			}
			
			
			
%>
  <tr >
    <td height="18">&nbsp;<%=strSubSecIndex%><%if(bolWithLab){%><br>&nbsp;<%=strSubSecIndex%><%}%></td>
    <td><%=(String)vAssessedSubDetail.elementAt(i+1)%><%if(bolWithLab){%><br>&nbsp;&nbsp;(Lab)<%}%></td>
    <td><div align="right"><%=fTotalUnit%>&nbsp;&nbsp;<%if(bolWithLab){%><br>- - &nbsp;&nbsp;<%}%></div></td>
    <td>&nbsp;<%=WI.getStrValue(strTime,"TBA") + WI.getStrValue(strLabTime,"<br>&nbsp;","","")%></td>
    <td><%=WI.getStrValue(strWeekDay,"N/A") + WI.getStrValue(strLabWeekDay,"<br>","","")%>  </td>
    <td><%=WI.getStrValue(strRoomAndSection,"TBA") + WI.getStrValue(strLabRoom,"<br>","","")%></td>
    <td><%=WI.getStrValue(strInstructor,"c/o") + WI.getStrValue(strLabInstructor,"<br>","","")%></td>
	<% 
		if (strAssessedHour == null || strAssessedHour.length() == 0) {
			strAssessedHour = Float.toString(fTotalUnit);
		}	
	%>
    <td><%=strAssessedHour%><%if(bolWithLab){%><br>- -<%}%></td>
<% 
	strTemp = "";
	dSubLaboratory = 0d;
	if (vMiscFeeInfo != null){
		iIndexOf = 0 ; 
		while (vMiscFeeInfo != null && 
				vMiscFeeInfo.size() > 0 && 
				iIndexOf < vMiscFeeInfo.size()){
		
			j = vMiscFeeInfo.indexOf(strSubSecIndex);
			if (j != -1){
				dSubLaboratory += Double.parseDouble((String)vMiscFeeInfo.elementAt(j-2));
				dTotalLaboratory += Double.parseDouble((String)vMiscFeeInfo.elementAt(j-2));
				iIndexOf = j-3;
				vMiscFeeInfo.removeElementAt(j-3);
				vMiscFeeInfo.removeElementAt(j-3);
				vMiscFeeInfo.removeElementAt(j-3);
				vMiscFeeInfo.removeElementAt(j-3);
//				System.out.println("iIndexOf (in) : " + iIndexOf);
//				System.out.println("vMiscFeeInfo (in): " + vMiscFeeInfo.size());
			}else{
				break;
			}
		}
			if (dSubLaboratory > 0.1d){ 
				strTemp = CommonUtil.formatFloat(dSubLaboratory, true);
			}
	}
%>
    <td><div align="right"><%=WI.getStrValue(strTemp)%>&nbsp;&nbsp;
        <%if(bolWithLab){%>
        <br>
        - - &nbsp;&nbsp;
        <%}%>
    </div></td>
  </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}%>
  <tr >
    <td height="18" class="topBottom"><strong>TOTALS</strong></td>
    <td height="18" class="topBottom">&nbsp;</td>
    <td height="18" class="topBottom"><div align="right">
      <%if(strErrMsg != null){%>
      <%=strErrMsg%>
      <%}else{%>
      <strong>
        <%=fUnitsTaken%>&nbsp;&nbsp;</strong>
        <%}%>
    </div></td>
    <td class="topBottom">&nbsp;</td>
    <td height="18" class="topBottom">&nbsp;</td>
    <td class="topBottom">&nbsp;</td>
    <td class="topBottom">&nbsp;</td>
<% 
	if (fTotalAssessedHour_< 0.1f){
		strTemp = CommonUtil.formatFloat(fUnitsTaken,false);
	}else{
		strTemp = CommonUtil.formatFloat(fTotalAssessedHour_,false);
	}	 
%>
    <td class="topBottom"><strong><%=strTemp%></strong></td>
    <td class="topBottom" align="right">	
	<% if ( dTotalLaboratory > 1d) {%> 
	<%=CommonUtil.formatFloat(dTotalLaboratory,true)%>
	<%}%> &nbsp;</td>
  </tr>
</table>
<%

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
    <td align="center"><strong><font size="2"><%=strErrMsg%></font></strong></td>
  </tr>
</table>
<%}else{

 fTotalPayableAmt = fTutionFee+fCompLabFee+fMiscFee + fOutstanding  - fEnrollmentDiscount;
 float fAmtPaidDurEnrl = Float.parseFloat((String)vRetResult[1].elementAt(5));
 double dOldAccountExemption = 0d; // i dont know where to get this one!
 float fExtraPayment = 0f; // extra payment after paying the fOutstanding.. 

if ( fOutstanding > 0f){
	if (Float.parseFloat((String)vRetResult[1].elementAt(5)) > fOutstanding)
		fExtraPayment = Float.parseFloat((String)vRetResult[1].elementAt(5)) - fOutstanding;
}else{
	fExtraPayment = Float.parseFloat((String)vRetResult[1].elementAt(5));
}

 int iEnrlSetting      = FA.getEnrollemntInstallmentSetting();
 int iInstalCount      = FA.getNoOfInstallment(dbOP,(String)vORInfo.elementAt(23),
 							(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td height="16" colspan="3"><div align="center"><strong><font size="2">ASSESSMENT</font></strong></div></td>
  </tr>
  <tr>
    <td width="45%" height="14" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
	    <tr>
          <td height="14">TUITION</td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat(fTutionFee,true)%></font></div></td>
        </tr>
         <% for(int i = 0; i< vMiscFeeInfo.size(); i +=4){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0)
				continue;
		%>
 		<tr>
          <td height="14"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
        <%
		for(int i = 0; i< vMiscFeeInfo.size(); i +=4){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).equals("0") ||
				(String)vMiscFeeInfo.elementAt(i + 3) != null)
				continue;
		%>
        <tr>
          <td height="14"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
	<% if (dTotalLaboratory > 0.0d) {%> 
        <tr>
          <td height="14">Laboratory</td>
          <td height="14" align="right">&nbsp;<%=CommonUtil.formatFloat(dTotalLaboratory,true)%></td>
        </tr>
	<%}%> 
        <tr>
          <td height="14">&nbsp;</td>
          <td height="14"><div align="right"></div></td>
        </tr>
    </table>	</td>
    <td width="5%">&nbsp;</td>
    <td width="50%" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td height="14" colspan="2">TOTAL CHARGES </td>
          <td width="25%" height="14" align="right">
		  	<font size="1"><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></font>		  </td>
          <td width="9%">&nbsp;</td>
        </tr>
        <tr>
          <td height="14">&nbsp;</td>
          <td>Less : Discount </td>
          <td height="14" align="right"><font size="1"><%=CommonUtil.formatFloat(fEnrollmentDiscount,true)%></font></td>
          <td>&nbsp;</td>
        </tr>

        <tr>
          <td height="14">&nbsp;</td>
          <td>
<% if (fScholarshipGrants > 0f){%>		  
		  Scholarship/s &amp; Grant/s
<%}else{%> 
		  None <%}%> 
		   </td>
          <td height="14" align="right"><font size="1"><%=CommonUtil.formatFloat(fScholarshipGrants,true)%></font></td>
          <td>&nbsp;</td>
        </tr>


        <tr>
          <td width="7%" height="14">&nbsp;</td>
	      <td width="59%">NET CASH PAID </td>
          <td height="14" align="right"><font size="1">
		 <% if (fExtraPayment >0f) {%>
			  <%=CommonUtil.formatFloat(fExtraPayment,true)%>
		  <%}else{%>0.00 <%}%></font></td>
          <td>&nbsp;</td>
        </tr>
		
        <tr>
          <td height="14"><font size="1"></font></td>
          <td height="14" colspan="3">
		 <% if (fExtraPayment > 0.01f) {%>  
		  (OR #<%=(String)vRetResult[1].elementAt(7)%> | <%=(String)vRetResult[1].elementAt(8)%> )
		 <%}%> &nbsp;
		  </td>
          </tr>
        <tr>
          <td height="14" colspan="2">CURRENT RECEIVABLE </td>
          <td height="14" align="right"><font size="1">
		  	<%=CommonUtil.formatFloat((fTutionFee+fCompLabFee+fMiscFee) - fExtraPayment - fScholarshipGrants-fEnrollmentDiscount,true)%> </font></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="14" colspan="2">&nbsp;</td>
          <td height="14">&nbsp;</td>
          <td>&nbsp;</td>
        </tr>

        <tr>
          <td height="14" colspan="2">OLD ACCTS / CREDIT BALANCE </td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat(fOutstanding,true)%></font></div></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="14">&nbsp;</td>
          <td height="14">Old Acct Exemption </td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dOldAccountExemption,true)%></font></div></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="14">&nbsp;</td>
          <td height="14">OLD ACCT PAYMENT </td>
          <td height="14"><div align="right"><font size="1">
		  <% if (fOutstanding > 0f) {
		  		if (Float.parseFloat((String)vRetResult[1].elementAt(5)) > fOutstanding){ %> 
				<%=CommonUtil.formatFloat(fOutstanding,true)%>
		  <%
		  		}else{ 
		  %>
				<%=CommonUtil.formatFloat(Float.parseFloat((String)vRetResult[1].elementAt(5)),true)%>
		  <%	} 
		     }else{%> 	0.00  <%}%> 
		  </font></div>
		  </td>
          <td>&nbsp;</td>
        </tr>

        <tr>
          <td height="14" colspan="4">
<% if ( fOutstanding > 0f) {%> 		  
		  (OR #<%=(String)vRetResult[1].elementAt(7)%> | <%=(String)vRetResult[1].elementAt(8)%> )  
		  </td>
        </tr>
<%}%>
        <tr>
          <td height="14" colspan="2">TOTAL RECEIVABLE </td>
          <td height="14" align="right"><font size="1">&nbsp;
		  <% if (fOutstanding < 0f) {%>
	        <%=CommonUtil.formatFloat((fTutionFee+fCompLabFee+fMiscFee) 
										-  Float.parseFloat((String)vRetResult[1].elementAt(5))	
										- fEnrollmentDiscount
										- fScholarshipGrants,true)%>
			<%}else{%>
	        <%=CommonUtil.formatFloat((fTutionFee+fCompLabFee+fMiscFee+fOutstanding) 
										-  Float.parseFloat((String)vRetResult[1].elementAt(5))	
										- fEnrollmentDiscount
										- fScholarshipGrants,true)%>
			<%}%> 			
										</font> </td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="14" colspan="2">&nbsp;</td>
          <td height="14">&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
<% 
	if (fOutstanding < 0f) 
		fOutstanding = 0f;

	if ((fTutionFee+fCompLabFee+fMiscFee + fOutstanding) 
			-  Float.parseFloat((String)vRetResult[1].elementAt(5)) 
			-  fEnrollmentDiscount - fScholarshipGrants > 0.001f) {%> 		
        <tr>
          <td height="14" colspan="2">PAYMENT SCHEDULE </td>
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
        <tr>
          <td height="14">&nbsp;</td>
		 <% if (vInstallmentDtls != null) {
		 		if (vInstallmentDtls.size() == 8) {
			 		strTemp = "Final";
				}else{
					strTemp = ((String)vInstallmentDtls.elementAt(5));
				}
			}
  		%> 
          <td height="14"><%=strTemp%> payment: 
		  <br>&nbsp;&nbsp;&nbsp;&nbsp; (<%=((String)vInstallmentDtls.elementAt(6))%>) </td>
          <td height="14" align="right"><font size="1"><%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(7),true)%>		  </font></td>
          <td height="14">&nbsp;</td>
        </tr>
		<%if(vInstallmentDtls != null && vInstallmentDtls.size() > 5 + 3*1) { //prelim 
		 		if (vInstallmentDtls.size() == 5+3*1+3) {
			 		strTemp = "Final";
				}else{
					strTemp = ((String)vInstallmentDtls.elementAt(5+3*1));
				}
		%>
        <tr>
          <td height="14">&nbsp;</td>
          <td height="14"> <%=strTemp%> payment:<br>
          &nbsp;&nbsp;&nbsp;&nbsp; (<%=((String)vInstallmentDtls.elementAt(5+3*1+1))%>)</td>
          <td height="14" align="right">
		  	<font size="1"><%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+3*1 +2),true)%> </font></td>
          <td height="14">&nbsp;</td>
        </tr>
        <%}if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+3*2) {//midterm
		 		if (vInstallmentDtls.size() == 5+3*2+3) {
			 		strTemp = "Final";
				}else{
					strTemp = ((String)vInstallmentDtls.elementAt(5+3*2));
				}
		%>
        <tr>
          <td height="14">&nbsp;</td>
          <td height="14"><%=strTemp%> payment:<br>
          &nbsp;&nbsp;&nbsp;&nbsp; (<%=((String)vInstallmentDtls.elementAt(5+3*2+1))%>) </td>
          <td height="14" align="right"><font size="1"><%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*2+2),true)%> </font></td>
          <td height="14">&nbsp;</td>
        </tr>
        <%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*3) {//semifinal
		 		if (vInstallmentDtls.size() == 5+3*3+3) {
			 		strTemp = "Final";
				}else{
					strTemp = ((String)vInstallmentDtls.elementAt(5+3*3));
				}
		%>
        <tr>
          <td height="14">&nbsp;</td>
          <td height="14"><%=strTemp%> payment: <br>
          &nbsp;&nbsp;&nbsp;&nbsp; (<%=((String)vInstallmentDtls.elementAt(5+3*3+1))%>) </td>
          <td height="14" align="right">
		  		<font size="1"><%=CommonUtil.formatFloat((String)vInstallmentDtls.elementAt(5+ 3*3+2),true)%> </font>
		   </td>
          <td height="14">&nbsp;</td>
        </tr>
        <%} %>
		
        <tr>
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
          <td height="14" align="right">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
		
		<%}%>
      </table>	</td>
  </tr>
  <tr>
    <td height="14" valign="top">&nbsp;</td>
    <td>&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr>
    <td height="14" valign="top">
		<div align="center">===== (<%=(String)request.getSession(false).getAttribute("userId")%> / 
					<%=(String)vRetResult[1].elementAt(8)%>) ===== </div></td>
    <td>&nbsp;</td>
    <td><strong>NOTE : This is subject to audit.</strong> </td>
  </tr>
</table>
<%
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
