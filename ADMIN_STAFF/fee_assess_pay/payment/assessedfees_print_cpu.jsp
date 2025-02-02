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
<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

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
Vector vInstallmentDtls = null;

float fTutionFee  		= 0f;
float fCompLabFee 		= 0f;
float fMiscFee    		= 0f;
float fOutstanding     	= 0f;
float fTotalPayableAmt 	= 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,
double dOldAccountExemption = 0d; // i dont know where to get this one!
float fTotalAssessedHour_ = 0f;

 float fExtraPayment = 0f; // extra payment after paying the fOutstanding.. 
 float fExtraPayable = 0f;

String 	strCollegeName 	= null;

boolean bolShowReceiptHeading = false;

float fEnrollmentDiscount = 0f; //this sum of full payment, early enrollment or late enrollment discount/fine implementations.
String strEnrolmentDiscDetail = null;
float fPayableAfterDiscount = 0f;

enrollment.SubjectSectionCPU ssCPU = new enrollment.SubjectSectionCPU();
SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
Advising advising = new Advising();



double dTotalLaboratory  = 0d;
float fScholarshipGrants = 0f;

Vector vAssessedSubDetail = null;
Vector vAssessedHrDetail_ = new Vector();
Vector vTuitionFeeDtls_ = new Vector();
String[] astrWeekDay = {"S","M","T","W","TH","F","SAT",""};


vStudInfo = advising.getStudInfo(dbOP,request.getParameter("stud_id"));

if(vStudInfo == null) {
	strErrMsg = advising.getErrMsg();

}
else
{
	astrSchYrInfo[0]=(String)vStudInfo.elementAt(16);//take sy from/to/sem from student registration information.
	astrSchYrInfo[1]=(String)vStudInfo.elementAt(17);
	astrSchYrInfo[2]=(String)vStudInfo.elementAt(18);

	paymentUtil.setTempUser((String)vStudInfo.elementAt(10));
	
	
//	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
//        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(2),
//        (String)vStudInfo.elementAt(3),(String)vStudInfo.elementAt(6),
//        astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);

	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(2),
        (String)vStudInfo.elementAt(3),(String)vStudInfo.elementAt(6),
        astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2],false,false,true);//System.out.println("Test : "+vMiscFeeInfo);

		
		

	strCollegeName = new CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(2));
	if(vMiscFeeInfo == null){
		strErrMsg = paymentUtil.getErrMsg();
//		System.out.println("strErrMsg : " + strErrMsg);
	}
}
if(strErrMsg == null) //collect fee details here.
{

	if (strSchoolCode.startsWith("CPU")) { 
		fOperation.bolComputeTFI = true;
		fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),
						paymentUtil.isTempStud(), astrSchYrInfo[0],
						astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);

		vAssessedHrDetail_.addAll(fOperation.vAssessedHrDetail);
		vTuitionFeeDtls_.addAll(fOperation.vTuitionFeeDtls);
		fTotalAssessedHour_ = fOperation.fTotalAssessedHour;
		
		fOperation.bolComputeTFI = false;
		fOperation.resetFees();
	}

	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
	if(fTutionFee > 0)
	{
		strTemp = dbOP.mapOneToOther("temp_fee_adjust","user_index",(String)vStudInfo.elementAt(0), 
		"sum(adjust_amt)", " and is_temp_stud = " +  (String)vStudInfo.elementAt(10) + 
		" and (is_rejected = 0  or is_rejected is null) ");

//		System.out.println("strTemp : " + strTemp);

		if (strTemp != null) 
			fScholarshipGrants = Float.parseFloat(strTemp);



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
		if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0){
			strErrMsg = FA.getErrMsg();
//			System.out.println("strErrMSg : " + strErrMsg);
		}
	}
	else{
		strErrMsg = fOperation.getErrMsg();
//		System.out.println("strErrMSg : " + strErrMsg);
	}
}
//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null )
{
	if(fMiscFee > 0.1f) {
	
		vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),
						 paymentUtil.isTempStud(),astrSchYrInfo[0],astrSchYrInfo[1],
						 (String)vStudInfo.elementAt(6),astrSchYrInfo[2],true);	

		if(vTemp == null){
			strErrMsg = paymentUtil.getErrMsg();
//			System.out.println("strErrMsg : " + strErrMsg);
		}else
			vMiscFeeInfo.addAll(vTemp);
	}

	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");
		vMiscFeeInfo.addElement(null);
	}

	vInstallmentDtls = FA.getInstallmentPayablePerStudent(dbOP,(String)vStudInfo.elementAt(0),
							astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),
							astrSchYrInfo[2],false,true) ;
							
	if(vInstallmentDtls == null)
		strErrMsg = FA.getErrMsg();

//	System.out.println("vInstallmentDtls : " + vInstallmentDtls);

}
if(fMiscFee <=0.1f) {
	vMiscFeeInfo = new Vector();
	vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");
	vMiscFeeInfo.addElement("");
}


//for re-enrollment schemes.
  boolean bolIsOnlyReEnrollment = false;
  if(vStudInfo != null && vStudInfo.size() > 0) {
	  	bolIsOnlyReEnrollment = CommonUtil.isOnlyReEnrollmentStud(dbOP, (String)vStudInfo.elementAt(0),
  										astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
  }

if(strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("CLDH"))

if(strErrMsg == null && request.getParameter("view_status") != null 
		&& request.getParameter("view_status").compareTo("0") == 0 ){
		//If starts with AUF, i have to validate here - for old student.
		if(dbOP.mapUIDToUIndex(request.getParameter("stud_id")) != null) {
			//automatic validation.
			enrollment.RegAssignID regAssignID = new enrollment.RegAssignID();
			if(!regAssignID.confirmOldStudEnrollment(dbOP, request.getParameter("stud_id"),
														(String)request.getSession(false).getAttribute("userId"))){
				strErrMsg = regAssignID.getErrMsg();
//				System.out.println("strErrMsg  : " + strErrMsg);
			}
		}
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

	if (((String)vStudInfo.elementAt(2)).equals("0"))
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
        <br>
      &nbsp;</td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td height="18" colspan="2">Name : &nbsp;<strong><font size="1"><%=(String)vStudInfo.elementAt(1)%></font></strong></td>
    <td colspan="2">ID # : <strong><font size="1"><%=request.getParameter("stud_id")%></font></strong></td>
  </tr>
  <tr>
    <td width="35%" height="18">Course &amp; Year &nbsp;:&nbsp; <strong><%=(String)vStudInfo.elementAt(7)%>
        <%if(vStudInfo.elementAt(8) != null){%>
/ <%=WI.getStrValue(vStudInfo.elementAt(8))%>
<%}%><%=WI.getStrValue((String)vStudInfo.elementAt(6)," - ","","")%> </strong></td>
    <td width="35%">&nbsp;<%=strCollegeName%></td>
    <td width="11%">Classification:&nbsp;</td>
	
<% strTemp =(String)vStudInfo.elementAt(11);
	if (strTemp.equals("Transferee") ||  strTemp.equals("Second Course"))
		strTemp = "New";
	else if (strTemp.equals("Second Course(Old)") || strTemp.equals("Old"))
		strTemp = "Regular";

	 if (new enrollment.CourseRequirement().isForeignNational(dbOP, 
	 									(String)vStudInfo.elementAt(0),
										((String)vStudInfo.elementAt(10)).equals("1"))){
	 	strTemp = "Foreign";
	 }
%>
 
	
    <td width="19%">&nbsp;<%=strTemp%></td>
  </tr>
</table>


<% if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0){%>
  
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
	String strSubTotalRate = null;//System.out.println(fOperation.vTuitionFeeDtls);

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

			if(vAssessedHrDetail_ != null && vAssessedHrDetail_.size() > iIndex)
				strAssessedHour = (String)vAssessedHrDetail_.elementAt(iIndex);
			else
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
    <td><%=strAssessedHour%><%if(bolWithLab){%><br>
      - -<%}%></td>
<% 
	strTemp = "";
	if (vMiscFeeInfo != null){
//		System.out.println("strSubSecIndex : " + strSubSecIndex);
		
		j = vMiscFeeInfo.indexOf(strSubSecIndex);
		if (j != -1){
			strTemp = (String)vMiscFeeInfo.elementAt(j-2);
			dTotalLaboratory += Double.parseDouble((String)vMiscFeeInfo.elementAt(j-2));
	}  }
%>
    <td>&nbsp;<%=WI.getStrValue(strTemp)%><%if(bolWithLab){%><br>- - &nbsp;&nbsp;<%}%></td>
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
		strTemp = Float.toString(fUnitsTaken);
	}else{
		strTemp = Float.toString(fTotalAssessedHour_);		
	}	 
%>	
    <td class="topBottom"><strong><%=strTemp%></strong></td>
    <td class="topBottom" align="right">
	<% if ( dTotalLaboratory > 1d) {%> 
	<%=CommonUtil.formatFloat(dTotalLaboratory,true)%>
	<%}%> 
	
	&nbsp;</td>
  </tr>
</table>

<% }//if vAssessedSubDetail no null


if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && fTutionFee > 0)
{
	//get here payment detail payment method detail.
	Vector[] vRetResult = faPayment.viewTutionFeePaymentDetail(dbOP,(String)vStudInfo.elementAt(0),astrSchYrInfo[0],
							astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2],paymentUtil.isTempStudInStr(), "0");

	if(vRetResult == null)
	{ strErrMsg = faPayment.getErrMsg();
//		System.out.println("strErrMsg : " + strErrMsg);
%>
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
}	

///I have to do this for installment payment.
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
 float fInstalmentAmt  = 0f;//installment amt after 1st installment.
 double dReqdDP        = 0d;//this is set for UI type of installation.
 
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
 	if(strSchoolCode.startsWith("CLDH") || strSchoolCode.startsWith("CPU")) {
		//for cldh, downpayment is 50% of payable and finals is zero.
		--iInstalCount;
		dReqdDP = (fTotalPayableAmt - fOutstanding)/2 + fOutstanding;
		//if first payment is less than down payment, it should be added to first installment pmt.
	   	fInstalmentAmt = (fTotalPayableAmt - (float) dReqdDP) / iInstalCount;
		fFirstInstalAmt = (float) dReqdDP - fAmtPaidDurEnrl + fInstalmentAmt;

		vExamScheduleName.removeElementAt(vExamScheduleName.size() -1);
	}
	else {
		enrollment.FAStudMinReqDP fMinDP = new enrollment.FAStudMinReqDP(dbOP);
   		dReqdDP = fMinDP.getPayableDownPayment(dbOP, WI.fillTextValue("stud_id"),
								astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]); //gets the required d/p.
	   	fInstalmentAmt = (fTotalPayableAmt - fOutstanding - (float) dReqdDP) / iInstalCount;
		fFirstInstalAmt = fOutstanding + (float) dReqdDP - fAmtPaidDurEnrl + fInstalmentAmt;
	}
 }
 
 //System.out.println(fFirstInstalAmt);
 //System.out.println(fInstalmentAmt);
 //System.out.println(fTotalPayableAmt);
 //System.out.println(dReqdDP);
 if(fInstalmentAmt <0f && fFirstInstalAmt > 0f)
 	fFirstInstalAmt = 0f;
 if(fInstalmentAmt <0f)
 	fInstalmentAmt = 0f;

 
if ( fOutstanding > 0f){
	fAmtPaidDurEnrl = fAmtPaidDurEnrl - fOutstanding;
	if (fAmtPaidDurEnrl < 0f) {
		fExtraPayable = fOutstanding - Float.parseFloat((String)vRetResult[1].elementAt(5)); // outstanding - amount paid
		fAmtPaidDurEnrl = 0f;
	}
}

if ( fAmtPaidDurEnrl > 0f){
	fExtraPayment =fAmtPaidDurEnrl; 
}


%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr> 
    <td width="45%" height="14" valign="top">&nbsp;
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
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
    <td width="10%">&nbsp;</td>
    <td width="45%" valign="top">&nbsp;
      <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td height="14" colspan="2">TOTAL CHARGES </td>
          <td width="25%" height="14" align="right"><font size="1"><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></font> </td>
          <td width="9%">&nbsp;</td>
        </tr>
        <tr>
          <td height="14">&nbsp;</td>
          <td>Less : Discount </td>
          <%// if (strEnrolmentDiscDetail != null && strEnrolmentDiscDetail.length() == 0) {
//				iIndexOf = strEnrolmentDiscDetail.indexOf("("); // remove 
//			if (iIndexOf != -1) 
//					strEnrolmentDiscDetail = strEnrolmentDiscDetail.substring(iIndexOf,strEnrolmentDiscDetail.length() - 1);
//		 }%>
          <td height="14" align="right"><font size="1"><%=CommonUtil.formatFloat(fEnrollmentDiscount,true)%></font></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="14">&nbsp;</td>
          <td><% if (fScholarshipGrants > 0f){%>
            Scholarship/s &amp; Grant/s
            <%}else{%>
            None
            <%}%>          </td>
          <td height="14" align="right"><font size="1"><%=CommonUtil.formatFloat(fScholarshipGrants,true)%></font></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td width="7%" height="14">&nbsp;</td>
          <td width="59%">NET CASH PAID </td>
          <td height="14" align="right"><font size="1">
            <% if (fExtraPayment >0f) {%>
            <%=CommonUtil.formatFloat(fExtraPayment,true)%>
            <%}else{%>
            0.00
            <%}%>
          </font></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="14"><font size="1"></font></td>
          <td height="14" colspan="3">(OR #<%=(String)vRetResult[1].elementAt(7)%> | <%=(String)vRetResult[1].elementAt(8)%> )</td>
        </tr>
        <tr>
          <td height="14" colspan="2">CURRENT RECEIVABLE </td>
          <td height="14" align="right"><font size="1"> <%=CommonUtil.formatFloat((fTutionFee+fCompLabFee+fMiscFee) - fExtraPayment - fScholarshipGrants,true)%> </font></td>
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
          <td height="14"><div align="right"><font size="1">&nbsp;
		  <% if (fOutstanding > 0f) {
		  		if (Float.parseFloat((String)vRetResult[1].elementAt(5)) >= fOutstanding){%> 
				<%=CommonUtil.formatFloat(fOutstanding,true)%>
		  <%	}else{ %>
				<%=CommonUtil.formatFloat(Float.parseFloat((String)vRetResult[1].elementAt(5),true)%>
		  <%	}
		     }else{%> 	0.00  <%}%> 
			</font></div></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="14" colspan="4"><% if ( fOutstanding > 0f) {%>
            (OR #<%=(String)vRetResult[1].elementAt(7)%> | <%=(String)vRetResult[1].elementAt(8)%> ) </td>
        </tr>
        <%}%>
        <tr>
          <td height="14" colspan="2">TOTAL RECEIVABLE </td>
          <td height="14" align="right"><font size="1">&nbsp;
		  <% if (fOutstanding < 0f) { %>
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
<%   if (fOutstanding < 0) 
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
      </table></td>
  </tr>
  <tr>
    <td height="14" valign="top"><div align="center"></div></td>
    <td>&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr>
    <td height="14" valign="top"><div align="center">===== (<%=(String)request.getSession(false).getAttribute("userId")%>/<%=(String)vRetResult[1].elementAt(8)%>) ===== </div></td>
    <td>&nbsp;</td>
    <td valign="top"><strong>NOTE : This is subject to audit.</strong></td>
  </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
</table>
<%
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
