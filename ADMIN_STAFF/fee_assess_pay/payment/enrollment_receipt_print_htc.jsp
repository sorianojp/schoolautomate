<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,
	enrollment.FAAssessment,enrollment.SubjectSection,enrollment.EnrlAddDropSubject,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5 = WI.getStrValue((String)request.getSession(false).getAttribute("info5"));

	int iIndexOf = 0;

	if(strSchoolCode == null) {
		%>
		<font style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:#FF0000">
			You are already logged out. Please login again to access this page.
		<%
		return;
	}
	boolean bolIsFatima = strSchoolCode.startsWith("FATIMA");
	
	
	//strSchoolCode = "UL";
	boolean bolIsUL = strSchoolCode.startsWith("UL");

	//for swu :: multiply by two for swu and for foreign student.
	boolean bolMultiplyByTwo = false;
	
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
    TD.thinborderBOTTOM {
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

<body onLoad="<%if(WI.fillTextValue("view_").length() == 0) {%>window.print();<%}%>">
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
Vector vLabCharges = new Vector();
Vector vAssessedSubDetail = null;
Vector vInstallmentDtls = null;

Vector vTermAll = new Vector();
Vector vTerm1 = new Vector();
Vector vTerm2 = new Vector();
Vector vSubjEnrolled = new Vector();



float fTotLabCharges = 0f;

vORInfo = faPayment.viewPmtDetail(dbOP,strORNumber);
if(vORInfo == null || vORInfo.size() ==0)
{%>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=faPayment.getErrMsg()%></font></p>
<%
	dbOP.cleanUP();
	return;
}
//I have to check if this is called for basic student.. 
if(vORInfo.elementAt(19) == null) {//basic.. 
	dbOP.cleanUP();
	///forward the page.. 
	response.sendRedirect(response.encodeRedirectURL("./enrollment_receipt_print_bas.jsp?or_number="+strORNumber+"&prevent_forward="+WI.fillTextValue("prevent_forward")));
	return;
}

double dDPFineCGH = 0d;
double dFatimaInstallmentFee = 0d;

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
        (String)vORInfo.elementAt(22));//System.out.println("Test : "+vMiscFeeInfo);
		
	
	strTemp = (String)vStudInfo.elementAt(6);//major
	if(WI.getStrValue(strTemp).length() > 0)
		strTemp = " and major_index = "+strTemp;
	else
		strTemp = "";
	
	//if(WI.getStrValue((String)vStudInfo.elementAt(4)).length() > 0)	//year level
	//	strTemp += " and year_level = "+(String)vStudInfo.elementAt(4);
	strTemp += " and sy_index=(select sy_index from FA_SCHYR where sy_from=" + (String)vORInfo.elementAt(23) + ") ";
	
	strTemp = " select distinct fee_name,AMOUNT  from FA_MISC_FEE where CATG_INDEX is not null  "+ 
			" and COURSE_INDEX = "+(String)vStudInfo.elementAt(5)+ strTemp +" and IS_VALID = 1 and is_del = 0 "+
			" and MISC_OTHER_CHARGE = 1 and fee_name like '%lab%'";
	rs = dbOP.executeQuery(strTemp);
	fTotLabCharges = 0f;
	while(rs.next()){
		vLabCharges.addElement(rs.getString(1));
		vLabCharges.addElement(rs.getString(2));		
	}rs.close();
	
	

	strTemp = "select c_name, dean_name from college join course_offered on (course_offered.c_index = college.c_index) where course_index = "+(String)vStudInfo.elementAt(5);
	rs = dbOP.executeQuery(strTemp); 
	if(rs.next()) {
		strCollegeName = rs.getString(1);
		strDeanName    = rs.getString(2);
	}
	rs.close();
	
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
}
if(strErrMsg == null) //collect fee details here.
{
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
	//for swu foreign student, multiply the subject rate by 2. -- well, it can be done by calling fOperation.isForeignStud();
	if(strSchoolCode.startsWith("SWU") && vStudInfo != null && (String)vStudInfo.elementAt(0) != null){
		bolMultiplyByTwo = fOperation.isForeignStud();
	}

	//System.out.println((String)vORInfo.elementAt(4));
	//System.out.println(fTutionFee);
	if(fTutionFee > 0f)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
		fOperation.checkIsEnrolling(dbOP, (String)vStudInfo.elementAt(0),
				(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
		fOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));
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
			
			//System.out.println(" fEnrollmentDiscount : "+fEnrollmentDiscount);
			//System.out.println(" fPayableAfterDiscount : "+fPayableAfterDiscount);
			//System.out.println(" fMiscFee : "+fMiscFee);
			//System.out.println(" fTutionFee : "+fTutionFee);
			//System.out.println(" fCompLabFee : "+fCompLabFee);
			//System.out.println(" fMiscOtherFee : "+fMiscOtherFee);
			//System.out.println(" fOutstanding : "+fOutstanding);
		}

		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5), "degree_type"," and is_valid=1 and is_del=0");
		vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
					(String)vORInfo.elementAt(22),"1",strDegreeType);
		if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0)
			strErrMsg = FA.getErrMsg();
		else{
		
			strTemp = " select e_sub_section.sub_sec_index, sub_code, sub_name, TERM_ESS  "+
					" from enrl_final_cur_list  "+
					" join E_SUB_SECTION on (E_SUB_SECTION.SUB_SEC_INDEX = ENRL_FINAL_CUR_LIST.SUB_SEC_INDEX) "+
					" join subject on (subject.SUB_INDEX = E_SUB_SECTION.SUB_INDEX) "+
					" where ENRL_FINAL_CUR_LIST.is_valid=1  "+
					" and ENRL_FINAL_CUR_LIST.sy_from="+astrSchYrInfo[0]+
					" and ENRL_FINAL_CUR_LIST.CURRENT_SEMESTER="+astrSchYrInfo[2]+
					" and ENRL_FINAL_CUR_LIST.user_index="+(String)vStudInfo.elementAt(0)+
					" and ENRL_FINAL_CUR_LIST.IS_TEMP_STUD=0";
			rs = dbOP.executeQuery(strTemp);
			while(rs.next()){
				vSubjEnrolled.addElement(rs.getString(1));//[0]sub_sec_index
				vSubjEnrolled.addElement(rs.getString(3));//[1]sub_code
				vSubjEnrolled.addElement(rs.getString(4));//[2]TERM_ESS
			}rs.close();
		
		
			for (int i = 0; i < vAssessedSubDetail.size(); i += 10) {
				strTemp = (String)vAssessedSubDetail.elementAt(i);
				iIndexOf = vSubjEnrolled.indexOf((String)vAssessedSubDetail.elementAt(i+2));
				if(iIndexOf == -1)
					continue;
				strTemp = WI.getStrValue(vSubjEnrolled.elementAt(iIndexOf + 1),"0");
				if(strTemp.equals("0")){
					vTermAll.addElement(vAssessedSubDetail.elementAt(i));	
					vTermAll.addElement(vAssessedSubDetail.elementAt(i+1));	
					vTermAll.addElement(vAssessedSubDetail.elementAt(i+2));	
					vTermAll.addElement(vAssessedSubDetail.elementAt(i+3));	
					vTermAll.addElement(vAssessedSubDetail.elementAt(i+4));	
					vTermAll.addElement(vAssessedSubDetail.elementAt(i+5));	
					vTermAll.addElement(vAssessedSubDetail.elementAt(i+6));	
					vTermAll.addElement(vAssessedSubDetail.elementAt(i+7));	
					vTermAll.addElement(vAssessedSubDetail.elementAt(i+8));	
					vTermAll.addElement(vAssessedSubDetail.elementAt(i+9));		
				}else if(strTemp.equals("1")){
					vTerm1.addElement(vAssessedSubDetail.elementAt(i));	
					vTerm1.addElement(vAssessedSubDetail.elementAt(i+1));	
					vTerm1.addElement(vAssessedSubDetail.elementAt(i+2));	
					vTerm1.addElement(vAssessedSubDetail.elementAt(i+3));	
					vTerm1.addElement(vAssessedSubDetail.elementAt(i+4));	
					vTerm1.addElement(vAssessedSubDetail.elementAt(i+5));	
					vTerm1.addElement(vAssessedSubDetail.elementAt(i+6));	
					vTerm1.addElement(vAssessedSubDetail.elementAt(i+7));	
					vTerm1.addElement(vAssessedSubDetail.elementAt(i+8));	
					vTerm1.addElement(vAssessedSubDetail.elementAt(i+9));			
				}else if(strTemp.equals("2")){
					vTerm2.addElement(vAssessedSubDetail.elementAt(i));	
					vTerm2.addElement(vAssessedSubDetail.elementAt(i+1));	
					vTerm2.addElement(vAssessedSubDetail.elementAt(i+2));	
					vTerm2.addElement(vAssessedSubDetail.elementAt(i+3));	
					vTerm2.addElement(vAssessedSubDetail.elementAt(i+4));	
					vTerm2.addElement(vAssessedSubDetail.elementAt(i+5));	
					vTerm2.addElement(vAssessedSubDetail.elementAt(i+6));	
					vTerm2.addElement(vAssessedSubDetail.elementAt(i+7));	
					vTerm2.addElement(vAssessedSubDetail.elementAt(i+8));	
					vTerm2.addElement(vAssessedSubDetail.elementAt(i+9));		
				}					
			}
		
		}
			
		if(strSchoolCode.startsWith("CGH") || strSchoolCode.startsWith("UDMC") || 
		strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("DBTC")) {
			dReservationFee = paymentUtil.getReservationFeeCGH(dbOP, (String)vStudInfo.elementAt(0),astrSchYrInfo[0], astrSchYrInfo[1],
						astrSchYrInfo[2],paymentUtil.isTempStud());
			//I have to find out if there is a d/p late charge.
			if(strSchoolCode.startsWith("CGH")){
				//get late fine for d/p
				strTemp = "select AMOUNT from FA_STUD_PAYABLE where is_valid = 1 and user_index = "+
					(String)vStudInfo.elementAt(0)+" and sy_from ="+(String)vORInfo.elementAt(23)+
					" and semester = "+(String)vORInfo.elementAt(22) +" and note like 'Late payment surcharge(D/P)'";
				strTemp = dbOP.getResultOfAQuery(strTemp,0);
				if(strTemp != null) {
					try {
						dDPFineCGH = Double.parseDouble(strTemp);
					}
					catch(Exception e){}
				}
					
			}
		}
		if(bolIsFatima) {			
			String strSQLQuery = "select amount from fa_stud_payable where user_index = "+vORInfo.elementAt(0) +" and sy_from = "+astrSchYrInfo[0]+
									" and semester = "+astrSchYrInfo[2]+" and is_valid = 1 and reference_index = 582";//fee name is Installment Fee and sy_index = 0;
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null)
				dFatimaInstallmentFee = Double.parseDouble(strSQLQuery);
		}
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
	if(fOperation.vMultipleOCMapInfo != null && fOperation.vMultipleOCMapInfo.size() > 0) 
		vMiscFeeInfo.addAll(fOperation.vMultipleOCMapInfo);

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

//for auf , i have to print the footer for 2007/08 2nd sem.. 
String strAUFFooter = null;
//System.out.println(strSchoolCode);
//System.out.println(astrSchYrInfo[2]);
//System.out.println(astrSchYrInfo[1]);
if(astrSchYrInfo != null && strSchoolCode.startsWith("AUF") && astrSchYrInfo[2].equals("2") && astrSchYrInfo[0].equals("2007") ) {
	strAUFFooter = "<font style='font-size:10px;'>AUF-Form-RO-02<br>August 1, 2007-Rev.0</font>";
}
	

//System.out.println(fOperation.vAssessedHrDetail);
boolean bolShowMiscDtls = true;
boolean bolShowOthChargeDtls = true;

boolean bolShowExamDate = false;
if(strSchoolCode.startsWith("DBTC") || bolIsFatima)
	bolShowExamDate = true;
if(strSchoolCode.startsWith("PIT") || strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("CSA")
	|| strSchoolCode.startsWith("VMUF") || bolIsFatima)
	bolShowReceiptHeading = false;
if(bolIsFatima) {
	bolShowMiscDtls      = false;
	bolShowOthChargeDtls = false;
}


//System.out.println(FA.vCommonVector);
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(bolShowReceiptHeading){%>
    <tr >
      <td height="25" colspan="2"><div align="center"><font size="2">
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
	strTemp = "OFFICIAL ENROLMENT SHEET";
else if(strSchoolCode.startsWith("UPH"))
	strTemp = "CERTIFICATE OF ENROLLMENT";
else if(strSchoolCode.startsWith("SPC"))
	strTemp = "OFFICIAL REGISTRATION FORM";
else
	strTemp = "FEE PAYMENT DETAILS";
%>
    <tr >
      <td height="20" colspan="2" style="font-size:12px;"><div align="center"><strong><%=strTemp%></strong><br>
        <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%> AY <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%>
		</div></td>
    </tr>
	
    <tr >
      <td height="20" align="right" colspan="2">Date and time printed: <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
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
    <td width="10%"><strong><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></strong></td>
    <td width="26%"><%if(!strSchoolCode.startsWith("FATIMA")){%>Gender : <strong><%=WI.getStrValue(vStudInfo.elementAt(13),"")%></strong><%}%>
	
	<%if(strSchoolCode.startsWith("UL")){%>&nbsp;&nbsp; DOB: <%=WI.getStrValue(vStudInfo.elementAt(23))%><%}%>	</td>
  </tr>
  <tr>
    <td height="18" width="11%">Student Type</td>
    <td><strong><font size="2"><%=(String)vStudInfo.elementAt(15)%>
	<%if(strSchoolCode.startsWith("AUF")){%>
		/<%if(vStudInfo.elementAt(21).equals("0")){%>Regular<%}else{%>Irregular<%}%>
	<%}%>

	
	</font></strong></td>
    <td colspan="3">
	<%if(bolIsFatima){%>
		<%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>, AY <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%>
	<%}else if(strSchoolCode.startsWith("UL")){%>
		Parents/Guardian: <%=WI.getStrValue(vStudInfo.elementAt(24))%>
	<%}%>
	&nbsp;</td>
  </tr>
<%if(!strSchoolCode.startsWith("UI") && !strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC") && 
	!strSchoolCode.startsWith("WNU") && !strSchoolCode.startsWith("UL") && !strSchoolCode.startsWith("CSA") && !strSchoolCode.startsWith("SPC") &&
	!bolIsFatima){%>
  <tr>
    <td height="18">Student's Signature</td>
    <td>____________________________________</td>
    <td>Parent's/Guardian's Signature</td>
    <td colspan="2">__________________________________________</td>
  </tr>
<%}%>
<%if(strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("CSA")){%>
  <tr>
    <td height="18">Address</td>
    <td colspan="3"><%=WI.getStrValue(vStudInfo.elementAt(26))%></td>
    <td>Contact Number: <%=WI.getStrValue(vStudInfo.elementAt(25))%></td>
  </tr>
<%}%>
</table>
<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0)
{%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr >
    <td width="10%" height="19" class="thinborder"><strong>SUBJECT CODE </strong></td>
    <td width="26%" height="19" class="thinborder"><strong>SUBJECT TITLE </strong></td>
    <td width="21%" class="thinborder"><strong>SCHEDULE</strong></td>
    <td width="15%" class="thinborder"><strong>SECTION/ROOM #</strong></td>
    <%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")){%>
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
    <%}
if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC") && !strSchoolCode.startsWith("CSA") && !strSchoolCode.startsWith("FATIMA")) {%>
    <%}%>
  </tr>
  <%//System.out.println(vAssessedSubDetail);
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
	
	java.sql.PreparedStatement pstmtGetLecLabStat = null;
	strTemp = "select IS_ONLY_LAB from enrl_final_cur_list where sub_sec_index=? and enrl_final_cur_list.is_valid = 1 and "+
				"user_index = "+(String)vStudInfo.elementAt(0)+" and IS_TEMP_STUD = "+paymentUtil.isTempStudInStr();
	pstmtGetLecLabStat = dbOP.getPreparedStatement(strTemp);
	
	strTemp = "select TERM_ESS from E_SUB_SECTION where sub_sec_index = ? ";
	java.sql.PreparedStatement pstmtGetTermNo = dbOP.getPreparedStatement(strTemp);
	
	String[] astrTermNo = {"ALL TERM","FIRST TERM","SECOND TERM"};
	String strTermNo = null;
	
	
if(false){
	for(int i = 0; i< vAssessedSubDetail.size() ; ++i){
		if(strFeeTypeCatg == null)	strFeeTypeCatg = (String)vAssessedSubDetail.elementAt(8);

		fTotalUnit = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+3))+Float.parseFloat((String)vAssessedSubDetail.elementAt(i+4));
		fTotalLoad += fTotalUnit;
		fUnitsTaken += Float.parseFloat((String)vAssessedSubDetail.elementAt(i+9));
		strSubSecIndex = (String)vAssessedSubDetail.elementAt(i);
		strTermNo = "ALL TERM";
		pstmtGetTermNo.setString(1, strSubSecIndex);
		rs = pstmtGetTermNo.executeQuery();
		if(rs.next())
			strTermNo = astrTermNo[rs.getInt(1)];
		rs.close();
		
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
			
			//System.out.println(bolMultiplyByTwo);
			if(bolMultiplyByTwo) {
				strSubTotalRate = CommonUtil.formatFloat(Double.parseDouble(ConversionTable.replaceString(strSubTotalRate, ",","")) * 2d, true);
				strRatePerUnit = CommonUtil.formatFloat(Double.parseDouble(ConversionTable.replaceString(strRatePerUnit, ",","")) * 2d, true);
			}
			
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

/**
		strLecLabStat  = dbOP.mapOneToOther("enrl_final_cur_list","sub_sec_index",strSubSecIndex, "IS_ONLY_LAB",
			" and enrl_final_cur_list.is_valid = 1 and enrl_final_cur_list.is_del = 0 and user_index = "+
			(String)vStudInfo.elementAt(0)+" and IS_TEMP_STUD = "+paymentUtil.isTempStudInStr());
**/
		strLecLabStat = null;
		if(strSchoolCode.startsWith("CIT"))
			strLecLabStat = "0";
		else {
			if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
				pstmtGetLecLabStat.setString(1,strSubSecIndex);
				rs = pstmtGetLecLabStat.executeQuery();
				if(rs.next())
					strLecLabStat = rs.getString(1);
				rs.close();
			}
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
		  //if(strSection == null)
		//	strSection = (String)vSubSecDtls.elementAt(0); 
		  for (int p = 0; p < vLabSched.size(); ++p)
		  {
			  if(strLecLabStat != null && strLecLabStat.compareTo("2") == 0)//lec only.
				continue;
				if(strSchedule != null)
					strSchedule += "<br>"+(String)vLabSched.elementAt(p+2);
				else
					strSchedule = (String)vLabSched.elementAt(p+2);
				if(strRoomAndSection != null)
					strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1);
				else
					strRoomAndSection = (String) vLabSched.elementAt(p + 1);
		    //strSchedule += "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
			//strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
%>
  <tr >
    <td height="19" class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+2)%></td>
    <td class="thinborder"><%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class="thinborder"><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
    <%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")) {%>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+3)%>/<%=(String)vAssessedSubDetail.elementAt(i+4)%></td>
    <%
if(!strSchoolCode.startsWith("UI")) {%>
    <td class="thinborder"><%=fTotalUnit%></td>
    <%}
}%>
    <td class="thinborder"><%=(String)vAssessedSubDetail.elementAt(i+9)%></td>    
    </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}

}//false


if(vTermAll.size() > 0){
%>


  <tr>
      <td height="25" colspan="10" class="thinborder" align="center"><strong>ALL TERM</strong></td>
    </tr>
<%

for(int i = 0; i< vTermAll.size() ; ++i){
		if(strFeeTypeCatg == null)	strFeeTypeCatg = (String)vTermAll.elementAt(8);

		fTotalUnit = Float.parseFloat((String)vTermAll.elementAt(i+3))+Float.parseFloat((String)vTermAll.elementAt(i+4));
		fTotalLoad += fTotalUnit;
		fUnitsTaken += Float.parseFloat((String)vTermAll.elementAt(i+9));
		strSubSecIndex = (String)vTermAll.elementAt(i);		

		//GET THE INFORMATION FROM TUITION FEE FAFeeOperation.vTuitionFeeDtls;
		strTemp = (String)vTermAll.elementAt(i+1);
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
			
			//System.out.println(bolMultiplyByTwo);
			if(bolMultiplyByTwo) {
				strSubTotalRate = CommonUtil.formatFloat(Double.parseDouble(ConversionTable.replaceString(strSubTotalRate, ",","")) * 2d, true);
				strRatePerUnit = CommonUtil.formatFloat(Double.parseDouble(ConversionTable.replaceString(strRatePerUnit, ",","")) * 2d, true);
			}
			
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
		if(strSchoolCode.startsWith("CIT"))
			strLecLabStat = "0";
		else {
			if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
				pstmtGetLecLabStat.setString(1,strSubSecIndex);
				rs = pstmtGetLecLabStat.executeQuery();
				if(rs.next())
					strLecLabStat = rs.getString(1);
				rs.close();
			}
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
		  //if(strSection == null)
		//	strSection = (String)vSubSecDtls.elementAt(0); 
		  for (int p = 0; p < vLabSched.size(); ++p)
		  {
			  if(strLecLabStat != null && strLecLabStat.compareTo("2") == 0)//lec only.
				continue;
				if(strSchedule != null)
					strSchedule += "<br>"+(String)vLabSched.elementAt(p+2);
				else
					strSchedule = (String)vLabSched.elementAt(p+2);
				if(strRoomAndSection != null)
					strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1);
				else
					strRoomAndSection = (String) vLabSched.elementAt(p + 1);
		    //strSchedule += "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
			//strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
%>
  <tr >
    <td height="19" class="thinborder"><%=(String)vTermAll.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vTermAll.elementAt(i+2)%></td>
    <td class="thinborder"><%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class="thinborder"><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
    <%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")) {%>
    <td class="thinborder"><%=(String)vTermAll.elementAt(i+3)%>/<%=(String)vTermAll.elementAt(i+4)%></td>
    <%
if(!strSchoolCode.startsWith("UI")) {%>
    <td class="thinborder"><%=fTotalUnit%></td>
    <%}
}%>
    <td class="thinborder"><%=(String)vTermAll.elementAt(i+9)%></td>    
    </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}
}//end of term all





if(vTerm1.size() > 0){
%>


  <tr>
      <td height="25" colspan="10" class="thinborder" align="center"><strong>FIRST TERM</strong></td>
    </tr>
<%

for(int i = 0; i< vTerm1.size() ; ++i){
		if(strFeeTypeCatg == null)	strFeeTypeCatg = (String)vTerm1.elementAt(8);

		fTotalUnit = Float.parseFloat((String)vTerm1.elementAt(i+3))+Float.parseFloat((String)vTerm1.elementAt(i+4));
		fTotalLoad += fTotalUnit;
		fUnitsTaken += Float.parseFloat((String)vTerm1.elementAt(i+9));
		strSubSecIndex = (String)vTerm1.elementAt(i);		

		//GET THE INFORMATION FROM TUITION FEE FAFeeOperation.vTuitionFeeDtls;
		strTemp = (String)vTerm1.elementAt(i+1);
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
			
			//System.out.println(bolMultiplyByTwo);
			if(bolMultiplyByTwo) {
				strSubTotalRate = CommonUtil.formatFloat(Double.parseDouble(ConversionTable.replaceString(strSubTotalRate, ",","")) * 2d, true);
				strRatePerUnit = CommonUtil.formatFloat(Double.parseDouble(ConversionTable.replaceString(strRatePerUnit, ",","")) * 2d, true);
			}
			
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
		if(strSchoolCode.startsWith("CIT"))
			strLecLabStat = "0";
		else {
			if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
				pstmtGetLecLabStat.setString(1,strSubSecIndex);
				rs = pstmtGetLecLabStat.executeQuery();
				if(rs.next())
					strLecLabStat = rs.getString(1);
				rs.close();
			}
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
		  //if(strSection == null)
		//	strSection = (String)vSubSecDtls.elementAt(0); 
		  for (int p = 0; p < vLabSched.size(); ++p)
		  {
			  if(strLecLabStat != null && strLecLabStat.compareTo("2") == 0)//lec only.
				continue;
				if(strSchedule != null)
					strSchedule += "<br>"+(String)vLabSched.elementAt(p+2);
				else
					strSchedule = (String)vLabSched.elementAt(p+2);
				if(strRoomAndSection != null)
					strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1);
				else
					strRoomAndSection = (String) vLabSched.elementAt(p + 1);
		    //strSchedule += "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
			//strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
%>
  <tr >
    <td height="19" class="thinborder"><%=(String)vTerm1.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vTerm1.elementAt(i+2)%></td>
    <td class="thinborder"><%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class="thinborder"><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
    <%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")) {%>
    <td class="thinborder"><%=(String)vTerm1.elementAt(i+3)%>/<%=(String)vTerm1.elementAt(i+4)%></td>
    <%
if(!strSchoolCode.startsWith("UI")) {%>
    <td class="thinborder"><%=fTotalUnit%></td>
    <%}
}%>
    <td class="thinborder"><%=(String)vTerm1.elementAt(i+9)%></td>    
    </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}
}//end of first term



if(vTerm2.size() > 0){
%>


  <tr>
      <td height="25" colspan="10" class="thinborder" align="center"><strong>SECOND TERM</strong></td>
    </tr>
<%

for(int i = 0; i< vTerm2.size() ; ++i){
		if(strFeeTypeCatg == null)	strFeeTypeCatg = (String)vTerm2.elementAt(8);

		fTotalUnit = Float.parseFloat((String)vTerm2.elementAt(i+3))+Float.parseFloat((String)vTerm2.elementAt(i+4));
		fTotalLoad += fTotalUnit;
		fUnitsTaken += Float.parseFloat((String)vTerm2.elementAt(i+9));
		strSubSecIndex = (String)vTerm2.elementAt(i);		

		//GET THE INFORMATION FROM TUITION FEE FAFeeOperation.vTuitionFeeDtls;
		strTemp = (String)vTerm2.elementAt(i+1);
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
			
			//System.out.println(bolMultiplyByTwo);
			if(bolMultiplyByTwo) {
				strSubTotalRate = CommonUtil.formatFloat(Double.parseDouble(ConversionTable.replaceString(strSubTotalRate, ",","")) * 2d, true);
				strRatePerUnit = CommonUtil.formatFloat(Double.parseDouble(ConversionTable.replaceString(strRatePerUnit, ",","")) * 2d, true);
			}
			
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
		if(strSchoolCode.startsWith("CIT"))
			strLecLabStat = "0";
		else {
			if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
				pstmtGetLecLabStat.setString(1,strSubSecIndex);
				rs = pstmtGetLecLabStat.executeQuery();
				if(rs.next())
					strLecLabStat = rs.getString(1);
				rs.close();
			}
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
		  //if(strSection == null)
		//	strSection = (String)vSubSecDtls.elementAt(0); 
		  for (int p = 0; p < vLabSched.size(); ++p)
		  {
			  if(strLecLabStat != null && strLecLabStat.compareTo("2") == 0)//lec only.
				continue;
				if(strSchedule != null)
					strSchedule += "<br>"+(String)vLabSched.elementAt(p+2);
				else
					strSchedule = (String)vLabSched.elementAt(p+2);
				if(strRoomAndSection != null)
					strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1);
				else
					strRoomAndSection = (String) vLabSched.elementAt(p + 1);
		    //strSchedule += "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
			//strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
%>
  <tr >
    <td height="19" class="thinborder"><%=(String)vTerm2.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vTerm2.elementAt(i+2)%></td>
    <td class="thinborder"><%=WI.getStrValue(strSchedule,"N/A")%></td>
    <td class="thinborder"><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
    <%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")) {%>
    <td class="thinborder"><%=(String)vTerm2.elementAt(i+3)%>/<%=(String)vTerm2.elementAt(i+4)%></td>
    <%
if(!strSchoolCode.startsWith("UI")) {%>
    <td class="thinborder"><%=fTotalUnit%></td>
    <%}
}%>
    <td class="thinborder"><%=(String)vTerm2.elementAt(i+9)%></td>    
    </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}
}//end of second term



%>


















  <tr >
    <td colspan="7" height="18" class="thinborder"><div align="center">
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

<%
if(false && strSchoolCode.startsWith("CGH")){}//page break.
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
boolean bolIsFullPmt = false;
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
       <%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC") && !bolIsFatima){%>
	    <tr>
          <td width="65%" height="14"><div align="right"><strong>:: FEE DETAILS ::</strong></div></td>
          <td width="35%" height="14">&nbsp;</td>
        </tr>
       <%}%>
	    <tr>
          <td height="14">TUITION FEE<strong><font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%> </font></strong></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></font></div></td>
        </tr>
     <%if(false && fCompLabFee > 0f){%>
       <tr>
          <td height="14">COMP. LAB. FEE</td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></font></div></td>
        </tr>
     <%}if(true || bolShowMiscDtls) {%>
	    <tr>
          <td height="14">MISCELLANEOUS FEES</td>
          <td height="14"><div align="right">
       
           <strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong>
        
		</div></td>
        </tr>
         <%}
		 if(false && !strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC")){
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0 || !bolShowMiscDtls)
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
        <%}
		

		Vector vLabFee = new Vector();
		boolean bolShowLabFee = false;
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
				continue;			
			
			if(vLabCharges.indexOf((String)vMiscFeeInfo.elementAt(i)) > -1){
				vLabFee.addElement(vMiscFeeInfo.remove(i));
				vLabFee.addElement(vMiscFeeInfo.remove(i));
				vLabFee.addElement(vMiscFeeInfo.remove(i));
				i-=3;
				continue;		
			}
			if(!bolShowLabFee)
				bolShowLabFee = true;			
		}
		if(bolShowLabFee){
		%>
		<tr>
		  <td height="14"><font size="1">OTHER CHARGES</font></td>
          <td height="14"><div align="right"></div></td>
        </tr>
         <%
		 fMiscOtherFee = 0f;
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){						
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
				continue;
			try{
				fMiscOtherFee += Float.parseFloat((String)vMiscFeeInfo.elementAt(i+1));
			}catch(Exception e){}
		%>
        <tr>
          <td height="14" style="padding-left:5px;"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
        <tr>
          <td height="14"><font size="1"><strong>TOTAL OTHER CHARGE</strong></font></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></font></div></td>
        </tr>
		
		<%}
		
		if(vLabFee != null && vLabFee.size() > 0){
			vMiscFeeInfo = vLabFee;
		fMiscOtherFee = 0f;
		%>
		<tr>
		  <td height="14"><font size="1">LABORATORY FEES</font></td>
          <td height="14"><div align="right"></div></td>
        </tr>
         <%
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){		
		try{
				fMiscOtherFee += Float.parseFloat((String)vMiscFeeInfo.elementAt(i+1));
			}catch(Exception e){}				
		%>
        <tr>
          <td height="14" style="padding-left:5px;"><font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
        <tr>
          <td height="14"><font size="1"><strong>TOTAL LABORATORY FEES</strong></font></td>
          <td height="14"><div align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></font></div></td>
        </tr>
		<%}%>
		
<%
if(bolIsFatima && dFatimaInstallmentFee > 0d){%>
        <tr>
          <td height="14">INSTALLMENT FEE</td>
          <td height="14" style="font-weight:bold"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dFatimaInstallmentFee,true)%></font></div></td>
        </tr>
<%}%>
        <tr>
          <td height="14" colspan="2"><hr size="1"></td>
        </tr>
        <tr>
          <td height="14"><strong>TOTAL ASSESSMENT</strong></td>
          <td height="14"><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + dFatimaInstallmentFee,true)%></strong></font></div></td>
        </tr>
        <tr>
          <td height="14">OLD ACCOUNTS</td>
          <td height="14"><div align="right"><font size="1">Php <%=CommonUtil.formatFloat(fOutstanding,true)%></font></div></td>
        </tr>
<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("CGH")){%>
		<tr>
          <td height="14">TOTAL AMOUNT DUE</td>
          <td height="14"><div align="right"><font size="1">Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding,true)%></font></div></td>
        </tr>
<%}//donot show total amt due.. 

if(strSchoolCode.startsWith("UDMC") && strEnrolmentDiscDetail != null){
iIndexOf = strEnrolmentDiscDetail.indexOf(":");
if(iIndexOf > 0) {
	strTemp = strEnrolmentDiscDetail.substring(iIndexOf + 1);
	strEnrolmentDiscDetail = strEnrolmentDiscDetail.substring(0,iIndexOf - 1);
}
else	
	strTemp = "";
%>
        <tr style="font-weight:bold; font-size:9px;">
          <td height="14"><%=strEnrolmentDiscDetail.toUpperCase()%></td>
          <td height="14" align="right"><%=strTemp%></td>
        </tr>
<%}

if(dReservationFee > 0d){
fTotalPayableAmt = fTotalPayableAmt - (float)dReservationFee;%>
        <tr>
          <td height="14">LESS RESERVATION FEE</td>
          <td height="14"><div align="right"><font size="1">Php <%=CommonUtil.formatFloat(dReservationFee ,true)%></font></div></td>
        </tr>
<%}
if(dDPFineCGH > 0d && strSchoolCode.startsWith("CGH")){%>
        <tr>
          <td height="14">LATE SURCHARGE</td>
          <td height="14"><div align="right"><font size="1">Php <%=CommonUtil.formatFloat(dDPFineCGH,true)%></font></div></td>
        </tr>
<%}%>
<%if(strSchoolCode.startsWith("CGH")){%>
		<tr>
          <td height="14">TOTAL AMOUNT DUE</td>
          <td height="14"><div align="right"><font size="1">Php <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding - dReservationFee + dDPFineCGH,true)%></font></div></td>
        </tr>
<%}
else {%> 
        <tr>
          <td height="14"><strong>TOTAL BALANCE DUE</strong></td>
          <td height="14"><div align="right"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTotalPayableAmt + dDPFineCGH + dFatimaInstallmentFee - fAmtPaidDurEnrl ,true)%></strong></font></div></td>
        </tr>
<%}%>
        <tr>
          <td height="14">&nbsp;</td>
          <td height="14"><div align="right"></div></td>
        </tr>
<%if(strSchoolCode.startsWith("WNU")){
String strSQLQuery = "select NSTP_PMT_WNU from fa_stud_payment where or_number = '"+(String)vRetResult[1].elementAt(7)+"'";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && !strSQLQuery.equals("0.0") ) {%>
        <tr>
          <td height="14" style="font-weight:bold; font-size:11px;"><u>NOTE : NSTP Fee Paid : <%=CommonUtil.formatFloat(strSQLQuery, true)%></u></td>
          <td height="14"><div align="right"></div></td>
        </tr>
<%}//show only if NSTP fee paid.. 

}%>
      </table>

	</td>
    <td width="10%">&nbsp;</td>
    <td width="45%" valign="top">&nbsp;
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("UDMC") && !bolIsFatima){%>
        <tr>
          <td width="54%" height="14"><div align="right"><strong>:: PAYMENT DETAILS
              ::</strong></div></td>
          <td width="46%" height="14">&nbsp;</td>
        </tr>
<%}%>
<%if(!strSchoolCode.startsWith("WNU") && !strSchoolCode.startsWith("UL") && !strSchoolCode.startsWith("CSA") && false){%>
        <tr>
          <td height="14">PAYEE TYPE</td>
          <td height="14"><strong><%=(String)vRetResult[0].elementAt(1)%></strong></td>
        </tr>
<%}%>
        <%if(vRetResult[0].elementAt(2) != null){%>
        <tr>
          <td height="14">PAYEE NAME </td>
          <td height="14"><strong><%=WI.getStrValue(vRetResult[0].elementAt(2))%></strong></td>
        </tr>
        <%}%>
        <tr>
          <td height="14">PAYMENT MODE </td>
		  <%
		  if(WI.getStrValue((String)vRetResult[0].elementAt(3)).toLowerCase().equals("full"))
		  	bolIsFullPmt = true;
		  %>
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
        <%if(strEnrolmentDiscDetail != null && !strSchoolCode.startsWith("UDMC")){%>
        <tr>
          <td height="14" colspan="2"><font size="1">(<%=strEnrolmentDiscDetail%>)</font></td>
        </tr>
        <%}
		if(vRetResult[1].elementAt(3) != null){%>
        <tr>
          <td height="14">APPROVAL NO.</td>
          <td height="14"><strong><%=WI.getStrValue(vRetResult[1].elementAt(3))%></strong></td>
        </tr>
        <%} if(vRetResult[1].elementAt(1) != null && !(vRetResult[1].elementAt(1)).equals("Internal")){%>
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
if(!strSchoolCode.startsWith("WNU") && !strSchoolCode.startsWith("UL")){%>

<%if(!strSchoolCode.startsWith("UDMC") && !strSchoolCode.startsWith("CGH")){%>
        <tr>
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>
<%}if(!strSchoolCode.startsWith("CSA") && !strSchoolCode.startsWith("FATIMA") && !strSchoolCode.startsWith("MARINER") && !bolIsFatima){%>
        <tr>
          <td height="14" colspan="2">(Business Office) Receipt printed by:<u>&nbsp;<%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%>&nbsp;&nbsp;</u> </td>
        </tr>
<%}%>
        <tr>
          <td height="14" colspan="2">
		  <%if(bolIsFatima) {//check here if there is any plan taken by student.. 
		  	String strPlanInfo = "select PLAN_NAME from FA_STUD_MIN_REQ_DP_PER_STUD "+
								"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.plan_ref = FA_STUD_MIN_REQ_DP_PER_STUD.plan_ref) "+
								" where is_temp_stud = 0 and stud_index = "+vORInfo.elementAt(0)+
								" and sy_from = "+astrSchYrInfo[0]+" and semester = "+astrSchYrInfo[2];
			strPlanInfo = dbOP.getResultOfAQuery(strPlanInfo, 0);
		  	if(strPlanInfo != null){%>
		  		<font size="2" style="font-weight:bold"><u>Plan Subscribed: <%=strPlanInfo.toUpperCase()%></u></font>
		  <%}}%>		  </td>
          </tr>
<%}//do not show for WNU

fTotalPayableAmt = fTutionFee+fCompLabFee+fMiscFee + fOutstanding;

if(true || (!bolIsFullPmt && fTotalPayableAmt > 0f)){

vTemp = new Vector();
vTemp.addElement("ON REGISTRATION 35% of SubTotal");vTemp.addElement(Float.toString(fTotalPayableAmt * .35f));
vTemp.addElement("MIDTERM - Term 1 DUE 20%");vTemp.addElement(Float.toString(fTotalPayableAmt * .2f));
vTemp.addElement("FINALS - Term 1 DUE 20%");vTemp.addElement(Float.toString(fTotalPayableAmt * .2f));
vTemp.addElement("MIDTERM - Term 2 DUE 20%");vTemp.addElement(Float.toString(fTotalPayableAmt * .2f));
vTemp.addElement("FINALS - Term2 DUE 5%");vTemp.addElement(Float.toString(fTotalPayableAmt * .05f));
while(vTemp.size() > 0){
%>		
		<tr>
          <td height="14" colspan="2"><%=vTemp.remove(0)%> : <%=CommonUtil.formatFloat((String)vTemp.remove(0),true)%></td>
          </tr>
 <%}%>
       <tr>
          <td height="14">&nbsp;</td>
          <td height="14">&nbsp;</td>
        </tr>

        <tr>
          <td height="14" colspan="2">
		  	(NOTE: Above installment schedule may change based on actual payment and after enrolment adjustments.)	  </td>
        </tr>
<%}%>


<%if(strSchoolCode.startsWith("CGH")){}%>		  
<%if(strSchoolCode.startsWith("MARINER")){}%>		  
<%if(strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("DBTC") || strSchoolCode.startsWith("PIT")){}%>		  
<%if(strSchoolCode.startsWith("CSA") && false){}
if(strSchoolCode.startsWith("UL")){}%>
      </table>
	</td>
  </tr>
</table>


<%if(!strSchoolCode.startsWith("DBTC") && !bolIsFatima){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(strSchoolCode.startsWith("VMUF") && (vStudInfo.elementAt(15) != null && ((String)vStudInfo.elementAt(15)).toLowerCase().startsWith("o"))){
}else if(strSchoolCode.startsWith("UI")){}
 if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("CGH") && !strSchoolCode.startsWith("WNU") 
 	&& !strSchoolCode.startsWith("PIT") && !strSchoolCode.startsWith("UL") && !strSchoolCode.startsWith("CSA") && !strSchoolCode.startsWith("SPC")){%>
 <tr >
    <td height="19" colspan="2" valign="top">Student load verified &amp; confirmed by :</td>
    </tr>
  <tr >
    <td height="10" colspan="2" align="center">___________________________________________________</td>
    </tr>
  <tr >
    <td height="10" colspan="2" align="center"><em><strong>Registrar</strong></em></td>
    </tr>
<%}
 if(strSchoolCode.startsWith("SPC")){}%>
</table>

<%}//do not show this block for DBTC%>




<%

		}//if payment detail and payment mode not null;
	}//if student information exists.
}//if miscellaneous fee information exists.
dbOP.cleanUP();
%>
</body>
</html>
