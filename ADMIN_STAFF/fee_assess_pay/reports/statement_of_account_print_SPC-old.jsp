<%@ page language="java" import="utility.*,EnrlReport.StatementOfAccount,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null) {%>
		<p style="font-size:16px; font-weight:bold; color:#FF0000">
			Session Expired. Please login again.		</p>
	<%return; 
}
	WebInterface WI = new WebInterface(request);
	String strStudID = WI.fillTextValue("stud_id");
	
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	
if(WI.fillTextValue("myhome").length() > 0) 
	strStudID = (String)request.getSession(false).getAttribute("userId");
else {
	if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4")) {%>
		<p style="font-size:24px; font-weight:bold">You are not authorized to access this account.</p>
	<%return;}
	
}

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	boolean bolIsFatima = strSchoolCode.startsWith("FATIMA");
	double dInstallmentFee = 0d;
	String strPlanInfo     = null;
	double dAddDropFee     = 0d;
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
<%
//add security here.
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

/**
* added to get hours enrolled/per hour computation
*/
double dTotalUnitsCharged = 0d;
Vector vSubjectPerHour = new Vector();
double dHoursCharged   = 0d;
double dUnitsExcluded  = 0d; double dUnitsSubNoFee = 0d;

Vector vDiscountDtls   = new Vector();

Vector vSubExcluded = new Vector();

/********* done *******/


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

String strDiscountName = null;//shown for fatima. name of discount.

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();
StatementOfAccount SOA = new StatementOfAccount();

boolean bolIsBasic = false;

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
					strStudID,WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
if(vStudInfo == null) 
	strErrMsg = enrlStudInfo.getErrMsg();
else {

	if(vStudInfo.elementAt(2) == null) 
		bolIsBasic = true;
	paymentUtil.setIsBasic(bolIsBasic);
	fOperation.setIsBasic(bolIsBasic);
	FA.setIsBasic(bolIsBasic);


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
		dOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));

		dMiscOtherFee = fOperation.getMiscOtherFee();

		fTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),null);
		fDownpayment   = fOperation.calAmoutPaidDurEnrollment(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		fTotalAmtPaid  = fOperation.calTotalAmoutPaidPerFee(dbOP, 0,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		
		if(fTotalDiscount > 0f && strSchoolCode.startsWith("FATIMA")) {
			strDiscountName = "select MAIN_TYPE_NAME, SUB_TYPE_NAME1,SUB_TYPE_NAME2,SUB_TYPE_NAME3,SUB_TYPE_NAME4,SUB_TYPE_NAME5 from FA_STUD_PMT_ADJUSTMENT  "+
								"join FA_FEE_ADJUSTMENT on (FA_FEE_ADJUSTMENT.fa_fa_index = FA_STUD_PMT_ADJUSTMENT.fa_fa_index) " +
								" where USER_INDEX = "+vStudInfo.elementAt(0)+" and FA_STUD_PMT_ADJUSTMENT.sy_from = "+WI.fillTextValue("sy_from")+" and FA_STUD_PMT_ADJUSTMENT.semester = "+
								WI.fillTextValue("semester")+" and FA_STUD_PMT_ADJUSTMENT.is_valid = 1";
			java.sql.ResultSet rs = null;
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
	if(strSchoolCode.startsWith("CSA") || strSchoolCode.startsWith("VMA") || true){
		vTemp = FA.getOtherChargePayable(dbOP,WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"), (String)vStudInfo.elementAt(0));
		if(vTemp != null && vTemp.size() > 0) {
			strTemp = (String)vTemp.elementAt(0);
			if(strTemp != null && !strTemp.equals("0.00"))
				dOtherSchPayable = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		}
	}
	if(bolIsFatima) {
		dAddDropFee = 0d;//new enrollment.FAFeeMaintenance().addDropFeePayabaleBalance(dbOP, (String)vStudInfo.elementAt(0), WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
		if(dAddDropFee < 0d)
			dAddDropFee = 0d; 
		dOtherSchPayable = dOtherSchPayable - dAddDropFee;		

		String strSQLQuery = "select PLAN_NAME from FA_STUD_MIN_REQ_DP_PER_STUD "+
							"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.plan_ref = FA_STUD_MIN_REQ_DP_PER_STUD.plan_ref) "+
							" where is_temp_stud = 0 and stud_index = "+vStudInfo.elementAt(0)+
							" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester");
		strPlanInfo = dbOP.getResultOfAQuery(strSQLQuery, 0);

		if(strPlanInfo != null) {
			strSQLQuery = "select sum(fa_stud_payable.amount) from fa_stud_payable join fa_oth_sch_fee on (fa_oth_sch_fee.othsch_fee_index = reference_index) where user_index = "+
						vStudInfo.elementAt(0) +" and fa_stud_payable.sy_from = "+WI.fillTextValue("sy_from")+
						" and fa_stud_payable.semester = "+WI.fillTextValue("semester")+" and fa_stud_payable.is_valid = 1 and fee_name like 'installment%'";//reference_index = 582";//fee name is Installment Fee and sy_index = 0;
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null) {
				dInstallmentFee = Double.parseDouble(strSQLQuery);
				dOtherSchPayable = dOtherSchPayable - dInstallmentFee;
			}
		}
	}

}


String[] astrConvertYrLevel = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
String[] astrConvertSem     = {"Summer","1ST SEM","2ND SEM","3RD SEM",
								"4TH SEM","5TH SEM","6TH SEM","7TH SEM"};
if(strErrMsg == null) strErrMsg = "";

 if(vStudInfo != null && vStudInfo.size() > 0)
 {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="16" colspan="2" ><div align="center"><strong>
	  <font size="2">
	  <%if(strSchoolCode.startsWith("LNU")){%>
	  <br><br><br><br><br><br><br><br><%}%>
	  STATEMENT OF ACCOUNT</font></strong><br>
          <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>,
		  <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%></div></td>
    </tr>
    <tr >
      <td height="16" ><font size="2">&nbsp;</font></td>
      <td height="16" ><div align="right"><font size="1">&nbsp;Date
        and time printed: <%=WI.getTodaysDateTime()%></font></div></td>
    </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td width="2%" height="16">&nbsp;</td>
    <td colspan="6">
	<font size="2">Name and ID of Student :
	<strong><%=((String)vStudInfo.elementAt(1)).toUpperCase()%>, <%=strStudID%></strong></font></td>
  </tr>
  <tr>
    <td height="16">&nbsp;</td>
    <td colspan="6"><font size="2">
	  <%if(!bolIsBasic) {%>
		  Course/Major - Year : <strong><%=(String)vStudInfo.elementAt(2)%>
    	    <%
	  	if(vStudInfo.elementAt(3) != null){%>
       		/<%=(String)vStudInfo.elementAt(3)%>
        	<%}%>
        	- <%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%></strong>
	   <%}else{%>
	   	Grade Level: <b><%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0")))%></b>
	   <%}%>
	
	  </font></td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td width="14%">&nbsp;</td>
    <td width="3%">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  </table>
  <table width="50%" cellpadding="0" cellspacing="0" border="0">
  	<tr><td>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="dotborderBOTTOM" width="48%" height="18" style="padding-left:40px;">School Fee</td>
					<td class="dotborderBOTTOM" width="8%">Units</td>
					<td class="dotborderBOTTOM" width="9%">Hrs</td>
					<td class="dotborderBOTTOM" width="11%" align="right">Rate</td>
					<td class="dotborderBOTTOM" width="20%" align="right">Amount</td>
					<td class="dotborderBOTTOM" width="4%">&nbsp;</td>
				</tr>
<%if(dHoursCharged == 0d) {%>
				<tr>				 
				  <td height="18">Tuition Fee</td>
				  <td><%=dUnitsTaken%></td>
				  <td>&nbsp;</td>
				  <td align="right"><%if(dUnitsTaken == 0d) {%> 0.00<%}else{%><%=CommonUtil.formatFloat(((double)fTutionFee / dUnitsTaken) ,true)%><%}%></td>
				  <td align="right"><strong><%if(dUnitsTaken == 0d) {%> 0.00<%}else{%><%=CommonUtil.formatFloat(fTutionFee,true)%><%}%></strong></td>				 
				</tr>
<%}else{
double dUnitsCharged = dUnitsTaken - dUnitsExcluded;
double dUnitRate = fTutionFee / (dUnitsCharged + dHoursCharged) ;
if(dUnitsCharged > 0d) {
%>
				<tr>				 
				  <td height="18">Tuition Fee</td>
				  <td><%=dUnitsCharged%></td>
				  <td>&nbsp;</td>
				  <td align="right"><%=CommonUtil.formatFloat(dUnitRate ,true)%></td>
				  <td align="right"><strong><%=CommonUtil.formatFloat(dUnitRate *dUnitsCharged ,true)%></strong></td>				 
				</tr>
<%}%>
				<tr>				 
				  <td height="18">Tuition Fee w/Lab</td>
				  <td><%=dUnitsExcluded%></td>
				  <td><%=dHoursCharged%></td>
				  <td align="right"><%=CommonUtil.formatFloat(dUnitRate ,true)%></td>
				  <td align="right"><strong><%=CommonUtil.formatFloat(dUnitRate *dHoursCharged ,true)%></strong></td>				 
				</tr>
<%}if(fCompLabFee > 0f){%>
					<tr>					  
					  <td height="18">Computer Lab Fee.</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td><td>&nbsp;</td>
					  <td align="right"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></td>
					  
					</tr>
<%}%>
<%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
		continue;
%>
				<tr>				
				  <td>&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
				  <td align="right">&nbsp;<strong></strong></td>
				  
				</tr>
<%}%>
				
				<tr>				  
				  <td height="18">Miscellaneous and Other Fees</td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				</tr>
				<%
				for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
					if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0)
						continue;
				%>
				<tr>				
				  <td>&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
				  <%
				  strTemp = "";
				  if(i + 3 >= vMiscFeeInfo.size())
				  	strTemp = CommonUtil.formatFloat(fMiscFee + dLateFineSPC,true);
				  %>
				  <td align="right">&nbsp;<strong><%if(dLateFineSPC == 0d){%><%=strTemp%><%}%></strong></td>
				  
				</tr>
				<%}%>
				<%if(dLateFineSPC > 0d){%>
				<tr>				
				  <td>&nbsp;&nbsp;&nbsp;Late Enrollment Fine</td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td align="right"><%=CommonUtil.formatFloat(dLateFineSPC,true)%></td>
				  <td align="right">&nbsp;<strong><%=strTemp%></strong></td>
				  
				</tr>
				<%}%>
				<tr>
					<td height="18">TOTAL FEES</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td style="padding-left:10px;" align="right"><div style="border-top:solid 2px #000000;"><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee+dLateFineSPC,true)%></div></td>
					<td align="right" style="padding-left:10px;"><div style="border-top:solid 2px #000000; border-bottom:solid 2px #000000; font-weight:bold;">
						<%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee+dLateFineSPC,true)%></div></td>
				</tr>
			</table>
	</td></tr>
  </table>

 <table width="100%" border="0" cellpadding="0" cellspacing="0" >
 <%
if(dMiscOtherFee > 0f){%>
   <tr>
      <td height="16" width="2%">&nbsp;</td>

    <td width="22%" ><strong>Total Other Charge</strong></td>
      <td width="43%">- - - - - - - - - - - - - - - - - - - - - - - - - - - -
        - - -</td>
      <td width="3%">&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dMiscOtherFee,true)%></td>
      <td width="20%">&nbsp;</td>
   </tr>
<%}%>
    <tr>
      <td height="16">&nbsp;</td>
      <td ><strong>Old Account </strong></td>
      <td >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - </td>
      <td>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dOutstanding,true)%></td>
      <td>&nbsp;</td>
    </tr>
<%if(dInstallmentFee > 0d) {%>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%" ><strong>Installment Fee</strong></td>
      <td width="43%" >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -      </td>
      <td width="3%">&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dInstallmentFee,true)%> </td>
      <td width="20%">&nbsp;</td>
    </tr>
<%}if(dAddDropFee > 0d ){%>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%" ><strong>Add/Drop Charges</strong></td>
      <td width="43%" >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -      </td>
      <td width="3%">&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dAddDropFee,true)%> </td>
      <td width="20%">&nbsp;</td>
    </tr>
<%}%>
    <tr valign="bottom">
      <td height="16">&nbsp;</td>
      <td ><strong>Total Fees Due</strong></td>
      <td >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      </td>
      <td>&nbsp;</td>
      <td><div align="right"><strong><%=CommonUtil.formatFloat(dTutionFee+dCompLabFee+dMiscFee+dOutstanding + dOtherSchPayable + dInstallmentFee + dAddDropFee,true)%></strong></div></td>
      <td>&nbsp;</td>
    </tr>
</table>
<%if(!strSchoolCode.startsWith("LNU")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td  width="2%" height="16">&nbsp;</td>
      <td colspan="6" >Less: </td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td >&nbsp;</td>
      <td >Discount (<%if(strDiscountName != null) {%><%=strDiscountName%><%}else{%>grants,scholarships etc.<%}%>)</td>
      <td >- - - - - - - - - - - - - - -</td>
      <td width="3%">&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(fTotalDiscount,true)%></td>
      <td width="20%">&nbsp;</td>
    </tr>
<%if(!strSchoolCode.startsWith("CSA")){%>
    <tr>
      <td height="16">&nbsp;</td>
      <td width="4%" ><font color="#0000FF">&nbsp;</font></td>
      <td width="39%" >Downpayment</td>
      <td width="22%">- - - - - - - - - - - - - - - </td>
      <td>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(fDownpayment,true)%></td>
      <td>&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="16">&nbsp;</td>
      <td >&nbsp;</td>
      <td >Amount paid by the student </td>
      <td >- - - - - - - - - - - - - - - </td>
      <td>&nbsp;</td>
      <td align="right">
	  <%if(strSchoolCode.startsWith("CSA")) {%>
	  	<%=CommonUtil.formatFloat(fTotalAmtPaid - fDownpayment,true)%>
	  <%}else{%>
	  	<%=CommonUtil.formatFloat(fTotalAmtPaid,true)%>
	  <%}%>
	  </td>
      <td>&nbsp;</td>
    </tr>
<%if(strSchoolCode.startsWith("CSA")){%>
    <tr style="font-weight:bold">
      <td height="16">&nbsp;</td>
      <td colspan="2" >Total Amount Paid </td>
      <td style="font-weight:normal">- - - - - - - - - - - - - - -</td>
      <td>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(fTotalAmtPaid,true)%></td>      
      <td>&nbsp;</td>
    </tr>
<%}%>
    <!--
    <tr>
      <td height="16">&nbsp;</td>
      <td colspan="4" ><em><font color="#0000FF" size="1">do not show amount to be paid
        by edu plans if not Educational Plan</font></em></td>
    </tr>
-->
    <%
if(WI.fillTextValue("report_type").compareTo("1") ==0){%>
    <tr>
      <td height="16">&nbsp;</td>
      <td colspan="2" >Amount to be paid by Educational plan</td>
      <td >- - - - - - - - - - - - - - - </td>
      <td>&nbsp;</td>
      <td align="right"><strong><%=CommonUtil.formatFloat((dTutionFee+dCompLabFee+dMiscFee-fTotalAmtPaid-fTotalDiscount ),true)%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <%}
else{%>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2" ><strong>OUTSTANDING BALANCE </strong></td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td align="right"><strong><%=CommonUtil.formatFloat((dTutionFee+dCompLabFee+dMiscFee-fTotalAmtPaid-fTotalDiscount+dOutstanding + dOtherSchPayable + dInstallmentFee + dAddDropFee),true)%></strong></td>
      <td >&nbsp;</td>
    </tr>
<%
if(!strSchoolCode.startsWith("LNU")){%>
    <tr>
      <td  width="2%"height="10">&nbsp;</td>

    <td colspan="6" >Payment Schedule:</td>
    </tr>
    <%
	double dTemp = 0d;
if(vScheduledPmt != null && vScheduledPmt.size() > 0) {%>
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td colspan="6" >
	  	<table border="0" width="50%" class="thinborder" align="left" cellpadding="0" cellspacing="0">
			<%
			for(int i = 7; i < vScheduledPmt.size(); i += 2) {
			dTemp = ((Double)vScheduledPmt.elementAt(i + 1)).doubleValue();
			if(dTemp < 0d) {
				if( (i + 3) <  vScheduledPmt.size()) {
					vScheduledPmt.setElementAt(new Double(((Double)vScheduledPmt.elementAt(i + 3)).doubleValue() + dTemp), i + 3);
				}
				dTemp = 0d;
				
			}%>
			<tr>
				<td class="thinborder"><%=vScheduledPmt.elementAt(i)%></td>
				<td class="thinborder"><%=CommonUtil.formatFloat(dTemp, true)%></td>
			</tr>
			<%}%>
	  	</table>	  </td>
    </tr>
<%
				}//if(vScheduledPmt != null && vScheduledPmt.size() > 0) 
				
			}//if(!strSchoolCode.startsWith("LNU"))
	
		}//if(!strSchoolCode.startsWith("LNU"))
	
	}//only if report type is current SA.

}//if(vStudInfo != null && vStudInfo.size() > 0) %>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td width="1%" height="10">&nbsp;</td>
      <td colspan="2" >&nbsp;</td>
      <td colspan="3" >&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td colspan="2" >Prepared by :</td>
      <td colspan="3" >Approved by :</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="50%"><u>&nbsp;&nbsp;<%=strPrintedBy%>&nbsp;&nbsp;</u></td>
      <td width="9%">&nbsp;</td>

    <td width="23%" class="thinborderBOTTOM">&nbsp;</td>
    <td width="9%">&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td height="16" >&nbsp;</td>
      <td height="16" valign="top" ><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Printed
        by </font></td>
      <td height="16" valign="top" ><font size="1">&nbsp;</font></td>
      <td height="16" valign="top" ><font size="1">
      <div align="center">
	  <%if(strSchoolCode.startsWith("VMUF")){%>President<%}else{%>
	  Accountant<%}%></div>
      </font></td>
      <td valign="top" >&nbsp;</td>
    </tr>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>
