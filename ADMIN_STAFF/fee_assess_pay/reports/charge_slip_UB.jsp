<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null) {%>
		<p style="font-size:16px; font-weight:bold; color:#FF0000">
			Session Expired. Please login again.
		</p>
	<%return; 
}


	boolean bolIsFatima = strSchoolCode.startsWith("FATIMA");
	double dInstallmentFee = 0d;
	String strPlanInfo     = null;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
    TABLE.thinborderALLThick {
    border-top: solid 2px #000000;
    border-bottom: solid 2px #000000;
    border-left: solid 2px #000000;
    border-right: solid 2px #000000;
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
<script language="JavaScript" src="../../../jscript/common.js"></script>

<body onLoad="window.print();">
<%@ page language="java" import="utility.*,EnrlReport.StatementOfAccount,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","statement_of_account.jsp");
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
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"statement_of_account.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
**/

//end of authenticaion code.
Vector vStudInfo     = null;
Vector vMiscFeeInfo  = null;
Vector vTemp         = null;
Vector vScheduledPmt = null;
Vector vSubjectDtls  = null;

double dTutionFee    = 0d;
double dCompLabFee   = 0d;
double dMiscFee      = 0d;
double dOutstanding  = 0d;
double dMiscOtherFee = 0d;//This is the misc fee other charges,

double dOtherSchPayable = 0d;//for CSA, i have to show total adjustment + other school payable.. 

float fTotalDiscount = 0f;
float fDownpayment   = 0f;
float fTotalAmtPaid  = 0f;
float fEnrolmentDiscount = 0f;//discount / fines during enrollment.

double dBackAccount = 0d;
double dReservationPmt = 0d;


String strDiscountName = null;//shown for fatima. name of discount.

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();
StatementOfAccount SOA = new StatementOfAccount();

boolean bolIsBasic = false;
String strSQLQuery = null;
java.sql.ResultSet rs = null;

String strDegreeType = null;//if 1 -- masteral :: total unit is element 1.

double dCurrentBalance = 0d;
Vector vTuitionTypePostCharge = new Vector();

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
					WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
if(vStudInfo == null) 
	strErrMsg = enrlStudInfo.getErrMsg();
else {

	if(vStudInfo.elementAt(2) == null) 
		bolIsBasic = true;
	paymentUtil.setIsBasic(bolIsBasic);
	fOperation.setIsBasic(bolIsBasic);
	FA.setIsBasic(bolIsBasic);

	strDegreeType = (String)vStudInfo.elementAt(9);

/**
	if(strSchoolCode.startsWith("FATIMA")) {
		strDiscountName = "select MAIN_TYPE_NAME,SUB_TYPE_NAME1,SUB_TYPE_NAME2,SUB_TYPE_NAME3,SUB_TYPE_NAME4,SUB_TYPE_NAME5 from FA_STUD_PMT_ADJUSTMENT "+
							"join FA_FEE_ADJUSTMENT on (FA_STUD_PMT_ADJUSTMENT.fa_fa_index = fa_fee_adjustment.fa_fa_index) "+
							" where stud_index = "+vStudInfo.elementAt(0)+" and sy_from = "+WI.fillTextValue("sy_from") +" and semester = "+WI.fillTextValue("semester")+
							" and is_valid = 1";
		java.sql.ResultSet rs = dbOP.executeQuery(strDiscountName);
		strDiscountName = null;
		while(rs.next()) {
			strTemp = rs.getString(6);
			if(strTemp == null) {
				strTemp = rs.getString(5);
				if(strTemp == null) {
					strTemp = rs.getString(4);
					if(strTemp == null) {
						strTemp = rs.getString(3);
						if(strTemp == null) {
							strTemp = rs.getString(2);
							if(strTemp == null)
								strTemp = rs.getString(1);
						}
					}
				}
			}
			if(strDiscountName == null)
				strDiscountName = strTemp;
			else	
				strDiscountName = strDiscountName + ", "+strTemp;
		}

	}
**/

	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
}
if(strErrMsg == null) //collect fee details here.
{
	dTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(dTutionFee > 0d)
	{
		dMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		dCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
				WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
		//dOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));
		//dOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));
		dOutstanding = fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0), false, false, 
							WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"),
							(String)vStudInfo.elementAt(4));
		
		dCurrentBalance = fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0), true, true, 
							WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"),
							(String)vStudInfo.elementAt(4));

		dMiscOtherFee = fOperation.getMiscOtherFee();

		fTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),null);
		fDownpayment   = fOperation.calAmoutPaidDurEnrollment(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		fTotalAmtPaid  = fOperation.calTotalAmoutPaidPerFee(dbOP, 0,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

		

      strSQLQuery = "select sum(amount) from fa_stud_payment where user_index = "+(String)vStudInfo.elementAt(0)+
        " and is_valid = 1 and payment_for = 10 and amount > 0 and or_number is not null and sy_from = "+
        WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester")+" and is_stud_temp = 0";
      rs = dbOP.executeQuery(strSQLQuery);
      if(rs.next()) 
        dBackAccount = rs.getDouble(1);
	  rs.close();
	  //fTotalAmtPaid += dBackAccount;
	  ///check if payment made for Application/Reservation Fee.
	  strSQLQuery = "select sum(fa_stud_payment.amount) from fa_stud_payment "+
	  				"join fa_oth_sch_fee on (fa_stud_payment.OTHSCH_FEE_INDEX = fa_oth_sch_fee.OTHSCH_FEE_INDEX) "+
					" where user_index = "+(String)vStudInfo.elementAt(0)+
        			" and fa_stud_payment.is_valid = 1 and fa_stud_payment.amount > 0 and or_number is not null and sy_from = "+
        			WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester")+" and fa_stud_payment.is_stud_temp = 0 and fee_name like 'Application%' ";
      rs = dbOP.executeQuery(strSQLQuery);
      if(rs.next()) 
        dReservationPmt = rs.getDouble(1);
	  rs.close();
	  fTotalAmtPaid += dReservationPmt;
	

		
		
		if(fTotalDiscount > 0f && strSchoolCode.startsWith("FATIMA")) {
			strDiscountName = "select MAIN_TYPE_NAME, SUB_TYPE_NAME1,SUB_TYPE_NAME2,SUB_TYPE_NAME3,SUB_TYPE_NAME4,SUB_TYPE_NAME5 from FA_STUD_PMT_ADJUSTMENT  "+
								"join FA_FEE_ADJUSTMENT on (FA_FEE_ADJUSTMENT.fa_fa_index = FA_STUD_PMT_ADJUSTMENT.fa_fa_index) " +
								" where USER_INDEX = "+vStudInfo.elementAt(0)+" and FA_STUD_PMT_ADJUSTMENT.sy_from = "+WI.fillTextValue("sy_from")+" and FA_STUD_PMT_ADJUSTMENT.semester = "+
								WI.fillTextValue("semester")+" and FA_STUD_PMT_ADJUSTMENT.is_valid = 1";
			rs = dbOP.executeQuery(strDiscountName);
			strDiscountName = null;
			while(rs.next()) {
				strTemp = rs.getString(1);
				if(rs.getString(2) != null)
					strTemp = strTemp + ": "+rs.getString(2);
				if(rs.getString(3) != null)
					strTemp = strTemp +": "+rs.getString(3);
				if(rs.getString(4) != null)
					strTemp = strTemp +": "+rs.getString(4);
				if(rs.getString(5) != null)
					strTemp = strTemp +": "+rs.getString(5);
				if(rs.getString(6) != null)
					strTemp = strTemp +": "+rs.getString(6);
					
				if(strDiscountName == null)
					strDiscountName = strTemp;
				else	
					strDiscountName =strDiscountName + ", "+strTemp;
			}
		}
		
		//calculate discount during enrollment.
		enrollment.FAFeeOperationDiscountEnrollment faEnrlDiscount =
								new enrollment.FAFeeOperationDiscountEnrollment();
    	vTemp = faEnrlDiscount.calEnrollmentDateDiscount(dbOP,(float)dTutionFee, (float)(dTutionFee + dMiscFee + dCompLabFee),
		(String)vStudInfo.elementAt(0),false, WI.fillTextValue("sy_from"),
        	WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),
                fOperation.dReqSubAmt);
    	if (vTemp != null && vTemp.size() > 0 && vTemp.elementAt(0) != null) {
      		fEnrolmentDiscount = ( (Float) vTemp.elementAt(1)).floatValue();
      		//System.out.println(fEnrolmentDiscount);
			fTotalDiscount += fEnrolmentDiscount;
    	}
		
		
		//check if not enrolled in current sy-term. if enrolled in current sy-term, I have to check os balance again, 
		
		int iStat = 0;
		strSQLQuery = "select sy_from, semester from stud_curriculum_hist join SEMESTER_SEQUENCE on (semester_val = semester) where user_index = "+
						vStudInfo.elementAt(0)+" and is_valid = 1 order by sy_from desc, sem_order desc";
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next())
			iStat = CommonUtil.compareSYTerm(rs.getString(1), rs.getString(2), WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
		rs.close();	
		if(iStat == 1) {
			//I have to now check os balance. 
			strSQLQuery = "select sum(amount) from fa_stud_payment where is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+
						WI.fillTextValue("semester")+" and user_index = "+vStudInfo.elementAt(0);
			rs = dbOP.executeQuery(strSQLQuery);
			rs.next();
			dCurrentBalance = -1 * rs.getDouble(1);
			rs.close();
			
			strSQLQuery = "select sum(amount*no_of_units) from fa_stud_payable where is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+
						WI.fillTextValue("semester")+" and user_index = "+vStudInfo.elementAt(0);
			rs = dbOP.executeQuery(strSQLQuery);
			rs.next();
			dCurrentBalance += rs.getDouble(1);
			rs.close();
			
			dCurrentBalance = dCurrentBalance + dOutstanding + dTutionFee+dMiscFee+dCompLabFee-fTotalDiscount;
		}
	}
	else
		strErrMsg = fOperation.getErrMsg();
}
//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null)
{
	vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(vTemp == null)
		strErrMsg = paymentUtil.getErrMsg();
	else
		vMiscFeeInfo.addAll(vTemp);
	if(fOperation.vMultipleOCMapInfo != null && fOperation.vMultipleOCMapInfo.size() > 0) 
		vMiscFeeInfo.addAll(fOperation.vMultipleOCMapInfo);
	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");
	}
}

if(strErrMsg == null)
{
/**
	vScheduledPmt = FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(vScheduledPmt == null)
		strErrMsg = FA.getErrMsg();
**/
	vScheduledPmt = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
}

String strPrintedBy = CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1);
if(strErrMsg == null)
{
	vSubjectDtls = SOA.getEnrolledSubSummary(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                      WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vSubjectDtls == null || vSubjectDtls.size() ==0)
		strErrMsg = SOA.getErrMsg();
	
	
	///get here the other other school fee and adjustment payable.. 
	if(strSchoolCode.startsWith("CSA") || true){
		vTemp = FA.getOtherChargePayable(dbOP,WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"), (String)vStudInfo.elementAt(0));
		if(vTemp != null && vTemp.size() > 0) {
			strTemp = (String)vTemp.elementAt(0);
			if(strTemp != null && !strTemp.equals("0.00"))
				dOtherSchPayable = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		}
	}
	
	//get here the details of tuition type post charge.
	double dTuitionTypePostCharge = 0d;
		//get add charge.. 
	strSQLQuery = "select fee_name, fa_stud_payable.amount from fa_stud_payable "+
					"join fa_oth_sch_fee on (othsch_fee_index = reference_index) "+
					"join FA_OTH_SCH_FEE_TUITION on (FA_OTH_SCH_FEE_TUITION.fee_name_t = fee_name) "+
					"where user_index = "+(String)vStudInfo.elementAt(0)+
					" and sy_from = "+WI.fillTextValue("sy_from") +" and semester = "+WI.fillTextValue("semester")+" and fa_stud_payable.is_valid = 1 and payable_type = 0 order by fee_name";
	
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vTuitionTypePostCharge.addElement(rs.getString(1));
		vTuitionTypePostCharge.addElement(CommonUtil.formatFloat(rs.getDouble(2), true));
		dTuitionTypePostCharge += rs.getDouble(2);
	}
	rs.close();
	dOtherSchPayable = dOtherSchPayable - dTuitionTypePostCharge;

}
dOtherSchPayable += dReservationPmt;


String[] astrConvertYrLevel = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
String[] astrConvertSem     = {"Summer","1ST SEM","2ND SEM","3RD SEM",
								"4TH SEM","5TH SEM","6TH SEM","7TH SEM"};
if(strErrMsg == null) strErrMsg = "";

 if(vStudInfo != null && vStudInfo.size() > 0)
 {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td align="center">
		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
</td></tr>
<tr>
  <td width="100%" height="25" colspan="4"><div align="center"><font size="2"><strong>
	CHARGE SLIP
	</strong></font></div></td>
</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	
	
	<tr>
		<td height="20" width="15%">Enrollment No:</td>
		<td width="25%">&nbsp;</td>
		<td width="15%">School Year:</td>
		<td width="15%"><%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%> / <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%></td>
		<td width="15%" align="right">Enr. &nbsp;</td>
		<td> &nbsp;<%=WI.getTodaysDate(1)%></td>		
	</tr>
	
	<tr>
		<td height="20" >Student No:</td>
		<td><%=WI.fillTextValue("stud_id")%></td>
		<td>Department:</td>
		<td>&nbsp;</td>
		<td align="right">Curriculum: &nbsp;</td>
		<td> &nbsp;<%=(String)vStudInfo.elementAt(7)%>-<%=(String)vStudInfo.elementAt(8)%></td>		
	</tr>
	<tr>
		<td height="20" >Student Name:</td>
		<td><%=WebInterface.formatName((String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11), (String)vStudInfo.elementAt(12), 4)%></td>
		<td>Year Level:</td>
		<td><%=WI.getStrValue((String)vStudInfo.elementAt(4))%></td>
		<td align="right">Adjustment No: &nbsp;</td>
		<td>&nbsp; </td>		
	</tr>
	
	<tr>
		<td height="20">Course:</td>
		<td colspan="5">
<%if(vStudInfo.elementAt(2) == null){%>
<%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(4),"0")))%>
<%}else{%>
		<%=(String)vStudInfo.elementAt(2)%>
<%}%>
		</td>
	</tr>
	<tr><td height="5" colspan="7"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
	<tr><td height="1" colspan="7"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
</table>









<table width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td height="730px" width="50%" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" >
				<tr><td height="60" colspan="3">&nbsp;</td></tr>
				<tr><td colspan="3" align="center">ASSESSMENT OF FEES</td></tr>
				<tr>
					<td class="thinborderTOPBOTTOM"><font size="1">PARTICULARS</font></td>
					<td class="thinborderTOPBOTTOM" align="center"><font size="1">UNITS</font></td>
					<td align="center" class="thinborderTOPBOTTOM">&nbsp;</td>
				</tr>
			<%if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && dTutionFee > 0d)
				{%>
					<tr>
						<td colspan="3">MISCELLANEOUS FEES</td>
					</tr>
					<%
				for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
					if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
						continue;
					}%>
					<tr>					  					  
					  <td colspan="2"> &nbsp; &nbsp; &nbsp; <%=(String)vMiscFeeInfo.elementAt(i)%></td>					  
					  <td align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>					  
					</tr>
					<%}%>
					<tr><td height="1" colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
					<tr><td colspan="2"><strong>Sub Total:</strong></td><td align="right"><strong><%=CommonUtil.formatFloat(dMiscFee - dMiscOtherFee,true)%></strong></td></tr>
				 	
				 <%}%>
				 
				 	<tr>				
						<td colspan="2">TUITION FEES</td>
						<td align="right"><%=CommonUtil.formatFloat(dTutionFee,true)%></td>
					</tr>
				 
				 <%if(dMiscOtherFee > 0f){%>				  
					<tr>
						<td colspan="3">OTHER CHARGES</td>
					</tr>
					<%
					for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
						if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
							continue;
					}
					%>
					<tr>
					  <td colspan="2"><%=(String)vMiscFeeInfo.elementAt(i)%></td>					  
					  <td align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>					  
					</tr>
					<%}
					}//if misc fee is not null%>
					<tr><td height="1" colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
					<tr><td colspan="2"><strong>Sub Total:</strong></td><td align="right"><strong><%=CommonUtil.formatFloat(dMiscOtherFee,true)%></strong></td></tr>
					<tr style="font-weight:bold">
					  <td width="68%" class="thinborderTOPBOTTOM" style="font-size:9px;">Total Assessment </td>
					  <td width="15%" class="thinborderTOPBOTTOM" style="font-size:9px;" align="center">
					  <%
					  strTemp = "";
					  if(strDegreeType != null && strDegreeType.equals("1"))
					  	strTemp = (String)vSubjectDtls.elementAt(0);
					  else if(vSubjectDtls != null)	
					  	  strTemp = (String)vSubjectDtls.elementAt(2);
					  %>	  
					  <%=strTemp%></td><!-- removed dOtherSchPayable from total assessment --> 
					  <td align="right" class="thinborderTOPBOTTOM" style="font-size:9px;"><%=CommonUtil.formatFloat(dTutionFee+dCompLabFee+dMiscFee + dInstallmentFee,true)%></td>
			 		</tr>
					
					
					
					   
					<tr>      
						  <td colspan="2" ><strong>OLD ACCOUNT</strong></td>      
						  <td align="right"><%=CommonUtil.formatFloat(dOutstanding-dBackAccount,true)%></td>      
						</tr>
					
						<tr>      
						  <td colspan="2" ><strong>DISCOUNT/ADJUSTMENTS</strong></td> <!--dOtherSchPayable-->     
						  <td align="right" width="17%"><%=CommonUtil.formatFloat(fTotalDiscount - dOtherSchPayable,true)%> </td>      
						</tr>
					<%while(vTuitionTypePostCharge.size() > 0) {%>
						<tr>					  
						  <td colspan="2" ><strong><%=vTuitionTypePostCharge.remove(0)%></strong></td>					  
						  <td align="right"><%=vTuitionTypePostCharge.remove(0)%></td>					
						</tr>
					<%}%>
					<tr>					  
					  <td colspan="2" ><strong>TOTAL PAYMENTS</strong></td>					  
					  <td align="right"><%=CommonUtil.formatFloat(fTotalAmtPaid,true)%></td>					
					</tr>
					<tr><td height="1" colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
					<tr>
						  <td colspan="2"><strong>BALANCE </strong></td>						  
						  <td align="right"><strong>
						  <%//=CommonUtil.formatFloat((dTutionFee+dCompLabFee+dMiscFee-fTotalAmtPaid-fTotalDiscount+dOutstanding + dOtherSchPayable + dInstallmentFee),true)%>
						  <%=CommonUtil.formatFloat(dCurrentBalance, true)%>
						  </strong></td>						  
					</tr>
					<tr><td height="1" colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
					<tr><td height="1" colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
					<tr><td height="3" colspan="3"></td></tr> 
					 <%
						double dTemp = 0d; double dCumulative = 0d;
					if(vScheduledPmt != null && vScheduledPmt.size() > 0) {%>
						<tr>						  
						  <td colspan="7" >
							<table border="0" width="50%" class="thinborder" align="left" cellpadding="0" cellspacing="0">
								<%//System.out.println(vScheduledPmt);
								for(int i = 7; i < vScheduledPmt.size(); i += 2) {
								dTemp = ((Double)vScheduledPmt.elementAt(i + 1)).doubleValue();
								//System.out.println(dTemp);
								dCumulative += dTemp ;
								if(dCumulative < dTemp)
									dTemp = dCumulative;
								//System.out.println(dCumulative);	
								
								if(dTemp < 0d)
									dTemp = 0d;
									strTemp = "";
									if(!WI.fillTextValue("semester").equals("0") && !bolIsBasic) {
										if(((String)vScheduledPmt.elementAt(i)).startsWith("P"))
											strTemp = "25%";
										else if(((String)vScheduledPmt.elementAt(i)).startsWith("M"))
											strTemp = "40%";
										else if(((String)vScheduledPmt.elementAt(i)).startsWith("S"))
											strTemp = "30%";
										else if(((String)vScheduledPmt.elementAt(i)).startsWith("F")) {
											strTemp = "5%";
											//if(dCurrentBalance != dCumulative)
											//	dTemp = dCurrentBalance;
										}
									}
									%>
								<tr>
									<td class="thinborder"><%=vScheduledPmt.elementAt(i)%> <%=strTemp%></td>
									<td class="thinborder"><%=CommonUtil.formatFloat(dTemp, true)%></td>
								</tr>
								<%}%>
							</table>						  </td>
						</tr>
					<%}//if(vScheduledPmt != null && vScheduledPmt.size() > 0) %>
				</table>		</td>
		
		
		
		
		
		
		
		
		<td>&nbsp;</td>
		
		
		
		
		
		
		
		
		
		
		
		
		
		<td width="49%" valign="top">
		<%if(!bolIsBasic){%>
			<table width="100%">
				<tr><td height="120" colspan="2">&nbsp;</td></tr>
				<tr><td colspan="2"><font size="+1"><strong>IMPORTANT ! ! !</strong></font></td></tr>
				<tr><td colspan="2"><i><font size="1">SCHEDULE OF CHARGES OF SHOOL ACCOUNTS UPON WITHDRWAL:</font></i></td></tr>
				<tr><td colspan="2" height="12"></td></tr>
				<tr><td>20%</td><td>- Start of classes to within Add, Drop, Change (ADC) period.</td></tr>
				<tr><td colspan="2" height="12"></td></tr>
				<tr><td>30%</td><td>- After ADC period but before scheduled Pre-lim exam.</td></tr>
				<tr><td colspan="2" height="12"></td></tr>
				<tr><td>50%</td><td>- After scheduled Pre-lim exam but before Mid-term exam.</td></tr>
				<tr><td colspan="2" height="12"></td></tr>
				<tr><td>100%</td><td>- After Mid-term exam.</td></tr>
				<!--
				<tr><td colspan="2" height="40" valign="bottom"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
				<tr><td align="justify" colspan="2">This is to certify that the student whose name appears on this document is officially
					enrolled this term in the class listed above.</td></tr>
				-->
			</table>	
	    <%}%>
			<!--
			<table width="100%">
				<tr>
					<td width="50%" align="center" height="50" valign="bottom" class="thinborderBOTTOM">
					<%=(String)vStudInfo.elementAt(10)%> <%=WI.getStrValue(strTemp)%> <%=(String)vStudInfo.elementAt(12)%></td>
					<td width="50%" align="center" height="50" valign="bottom" class="thinborderBOTTOM">DALTA MELDA T. MAGNO, CPA,</td>
				</tr>
				<tr>
					<td align="center" valign="top">
					Student Signature</td>
					<td align="center" valign="top">
					Registrar</td>
				</tr>
			</table>		
			-->
			
			</td>
	</tr>
	<tr>
	  <td colspan="3" valign="top">
	  <table width="100%" cellpadding="0" cellspacing="0">
	  	<tr>
	  	  <td align="center">&nbsp;</td>
	  	  <td align="center">&nbsp;</td>
	  	  <td align="center">&nbsp;</td>
	  	  <td align="center">&nbsp;</td>
  	    </tr>
	  	<tr>
			<td width="25%" align="center"><table class="thinborderALLThick" cellpadding="0" cellspacing="0"><tr><td width="117" height="24">&nbsp;</td></tr></table></td>
			<td width="25%" align="center"><table class="thinborderALLThick" cellpadding="0" cellspacing="0"><tr><td width="117" height="24">&nbsp;</td></tr></table></td>
			<td width="25%" align="center"><table class="thinborderALLThick" cellpadding="0" cellspacing="0"><tr><td width="117" height="24">&nbsp;</td></tr></table></td>
			<td width="25%" align="center"><table class="thinborderALLThick" cellpadding="0" cellspacing="0"><tr><td width="117" height="24">&nbsp;</td></tr></table></td>
		</tr>
	  	<tr>
	  	  <td align="center">&nbsp;</td>
	  	  <td align="center">&nbsp;</td>
	  	  <td align="center">&nbsp;</td>
	  	  <td align="center">&nbsp;</td>
  	    </tr>
	  </table>
	  
	  </td>
  </tr>
	
	
	
	
	<tr>
		<td><font size="1">Printed By:<%=(String)request.getSession(false).getAttribute("first_name")%></font></td>
		<td colspan="2" align="right"><font size="1">Date and Time Printed: <%=WI.getTodaysDateTime()%></font></td>
	</tr>
</table>




 
 
 
<%
}//if(vStudInfo != null && vStudInfo.size() > 0) %>
  </table>

  


</body>
</html>
<%
dbOP.cleanUP();
%>
