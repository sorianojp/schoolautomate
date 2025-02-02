<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null) {%>
		<p style="font-size:16px; font-weight:bold; color:#FF0000">
			Session Expired. Please login again.		</p>
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

String strDiscountName = null;//shown for fatima. name of discount.

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();
StatementOfAccount SOA = new StatementOfAccount();

boolean bolIsBasic = false;


	String strSYFrom   = WI.fillTextValue("sy_from");
	String strSYTo     = WI.fillTextValue("sy_to");
	String strSemester = WI.fillTextValue("semester");
	String strStudID   = WI.fillTextValue("stud_id"); 
	String strExamPeriod = WI.fillTextValue("pmt_schedule");
	String strExamName   = WI.fillTextValue("grade_name");



/**
	These are the fee to be shown in SOA if not paid.
**/
Vector vOCPayable = new Vector();


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
		

				
		//get add charge details.. 
		int iIndexOf          = 0;
		strTemp = "select reference_index,fee_name, fa_stud_payable.amount from fa_stud_payable join fa_oth_sch_Fee on (othsch_fee_index = reference_index) where user_index = "+
				(String)vStudInfo.elementAt(0)+" and sy_from = "+strSYFrom +" and semester = "+strSemester+" and fa_stud_payable.is_valid = 1 and payable_type = 0";
		//System.out.println(strTemp);
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp); 
		while(rs.next()) {
			vOCPayable.addElement(rs.getString(1));//fee_index
			vOCPayable.addElement(rs.getString(2));//fee Name
			vOCPayable.addElement(CommonUtil.formatFloat(rs.getDouble(3), true));
		}
		rs.close();
		
		//now get payment for add/drop fee. 
		if(vOCPayable.size() > 0) {
			strTemp = "select othsch_fee_index from fa_stud_payment where user_index = "+(String)vStudInfo.elementAt(0)+" and sy_from = "+strSYFrom+
					" and semester = "+strSemester+" and is_valid = 1 and othsch_fee_index is not null";
			//System.out.println(strTemp);
			rs = dbOP.executeQuery(strTemp);
			while(rs.next()) {
				iIndexOf = vOCPayable.indexOf(rs.getString(1));
				if(iIndexOf == -1)
					continue;
				
				vOCPayable.remove(iIndexOf);
				vOCPayable.remove(iIndexOf);
				vOCPayable.remove(iIndexOf);
			}
			rs.close();
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
	if(strSchoolCode.startsWith("CSA") || strSchoolCode.startsWith("VMA")){
		vTemp = FA.getOtherChargePayable(dbOP,WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"), (String)vStudInfo.elementAt(0));
		if(vTemp != null && vTemp.size() > 0) {
			strTemp = (String)vTemp.elementAt(0);
			if(strTemp != null && !strTemp.equals("0.00"))
				dOtherSchPayable = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		}
	}
	if(bolIsFatima) {
		String strSQLQuery = "select PLAN_NAME from FA_STUD_MIN_REQ_DP_PER_STUD "+
							"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.plan_ref = FA_STUD_MIN_REQ_DP_PER_STUD.plan_ref) "+
							" where is_temp_stud = 0 and stud_index = "+vStudInfo.elementAt(0)+
							" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester");
		strPlanInfo = dbOP.getResultOfAQuery(strSQLQuery, 0);

		if(strPlanInfo != null) {
			strSQLQuery = "select amount from fa_stud_payable where user_index = "+vStudInfo.elementAt(0) +" and sy_from = "+WI.fillTextValue("sy_from")+
									" and semester = "+WI.fillTextValue("semester")+" and is_valid = 1 and reference_index = 582";//fee name is Installment Fee and sy_index = 0;
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null)
				dInstallmentFee = Double.parseDouble(strSQLQuery);
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
	<strong><%=((String)vStudInfo.elementAt(1)).toUpperCase()%>, <%=WI.fillTextValue("stud_id")%></strong></font></td>
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
<%if(bolIsBasic) 
	vSubjectDtls = null;
else{%>
  <tr>
    <td height="16">&nbsp;</td>
    <td colspan="2">No. of units enrolled in :</td>
    <td colspan="4"> <%if(strSchoolCode.startsWith("LNU")){%>
	<%=(String)vSubjectDtls.elementAt(2)%> <%=(String)vSubjectDtls.elementAt(3)%>
      <%if(fOperation.getRatePerUnit() > 0f){%>
      @ <%=fOperation.getRatePerUnit()%>
      <%}%>
	  <%}%>    </td>
  </tr>
<%}
if(vSubjectDtls != null && vSubjectDtls.size() > 0 && !strSchoolCode.startsWith("LNU")) {
%>
  <tr>
    <td height="10">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td width="14%">Lecture </td>
    <td width="3%">:</td>
    <td colspan="2"> <%=(String)vSubjectDtls.elementAt(0)%> <%=(String)vSubjectDtls.elementAt(3)%></td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td>Laboratory</td>
    <td>:</td>
    <td colspan="2"><%=(String)vSubjectDtls.elementAt(1)%> <%=(String)vSubjectDtls.elementAt(3)%></td>
  </tr>
<%if(!((String)vSubjectDtls.elementAt(4)).equals("0.0")){%>
  <tr>
    <td height="10">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td>P.E.</td>
    <td width="3%">:</td>
    <td colspan="2"><%=(String)vSubjectDtls.elementAt(4)%></td>
  </tr>
<%}if(!((String)vSubjectDtls.elementAt(5)).equals("0.0")){%>
  <tr>
    <td height="10">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td>NSTP-ROTC</td>
    <td>:</td>
    <td colspan="2"><%=(String)vSubjectDtls.elementAt(5)%></td>
  </tr>
<%}%>
  <tr>
    <td height="10">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td>Total</td>
    <td>:</td>
    <td colspan="2"><%=(String)vSubjectDtls.elementAt(2)%> <%=(String)vSubjectDtls.elementAt(3)%></td>
  </tr>
<%}//only if subject detail is not null;%>
  <tr>
    <td height="16">&nbsp;</td>
    <td colspan="5">Total Tuition Fees &nbsp;&nbsp;&nbsp;- - - - - - - - - - -
      - - - - - - - - - - - - - - - - - - - - </td>
    <td width="34%">P&nbsp;&nbsp;&nbsp;<%=CommonUtil.formatFloat(dTutionFee,true)%></td>
  </tr>
</table>
<%if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && dTutionFee > 0d)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td width="2%" height="16">&nbsp;</td>

    <td colspan="6"><strong>Miscellaneous Fees :</strong></td>
    </tr>
    <%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
		continue;
	}%>
    <tr>
      <td height="16" width="2%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="27%"><%=(String)vMiscFeeInfo.elementAt(i)%></td>
      <td width="18%">- - - - - - - - - - - - </td>
      <td width="5%">P</td>
      <td width="6%" align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
      <td width="38%">&nbsp;</td>
    </tr>
    <%}%>
  </table>
 <%}//if misc fee is not null
 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td  width="2%" height="16">&nbsp;</td>

    <td width="22%" ><strong>Total Miscellaneous Fees</strong> </td>
      <td width="43%" >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - -
        - - - - - - </td>
      <td width="3%">P&nbsp;&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dMiscFee - dMiscOtherFee,true)%> <div align="right"></div></td>
      <td width="20%">&nbsp;</td>
    </tr>
</table>
<%
if(dMiscOtherFee > 0f){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td width="2%" height="16">&nbsp;</td>

    <td colspan="6"><strong>Other Charges :</strong></td>
    </tr>
<%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		continue;
	}
	%>
    <tr>
      <td height="16" width="2%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="27%"><%=(String)vMiscFeeInfo.elementAt(i)%></td>
      <td width="18%">- - - - - - - - - - - - </td>
      <td width="5%">P</td>
      <td width="6%" align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
      <td width="38%">&nbsp;</td>
    </tr>
    <%}%>
  </table>
 <%}//if misc fee is not null
 %>
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
      <td height="16" width="2%">&nbsp;</td>

    <td width="22%" ><strong>Computer Lab. Fee</strong></td>
      <td width="43%" >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      </td>
      <td width="3%">&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dCompLabFee,true)%> </td>
      <td width="20%">&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td ><strong>Old Account </strong></td>
      <td >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - </td>
      <td>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dOutstanding,true)%></td>
      <td>&nbsp;</td>
    </tr>
<%if(strSchoolCode.startsWith("CSA") || strSchoolCode.startsWith("VMA")) {%>
    <tr>
      <td height="16" width="2%">&nbsp;</td>
      <td width="22%" ><strong>Other School Fee + Adjustments</strong></td>
      <td width="43%" >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -      </td>
      <td width="3%">&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dOtherSchPayable,true)%> </td>
      <td width="20%">&nbsp;</td>
    </tr>
<%}%>
<%if(bolIsFatima && dInstallmentFee > 0d) {%>
    <tr>
      <td height="16" width="2%">&nbsp;</td>
      <td width="22%" ><strong>Installment Fee</strong></td>
      <td width="43%" >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -      </td>
      <td width="3%">&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dInstallmentFee,true)%> </td>
      <td width="20%">&nbsp;</td>
    </tr>
<%}%>
    <tr valign="bottom">
      <td height="16">&nbsp;</td>
      <td ><strong>Total Fees Due</strong></td>
      <td >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      </td>
      <td>&nbsp;</td>
      <td><div align="right"><strong><%=CommonUtil.formatFloat(dTutionFee+dCompLabFee+dMiscFee+dOutstanding + dOtherSchPayable + dInstallmentFee,true)%></strong></div></td>
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
      <td width="3%">P&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(fTotalDiscount,true)%></td>
      <td width="20%">&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td width="4%" ><font color="#0000FF">&nbsp;</font></td>
      <td width="39%" >Downpayment</td>
      <td width="22%">- - - - - - - - - - - - - - - </td>
      <td>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(fDownpayment,true)%></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td >&nbsp;</td>
      <td >Amount paid by the student </td>
      <td >- - - - - - - - - - - - - - - </td>
      <td>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(fTotalAmtPaid,true)%></td>
      <td>&nbsp;</td>
    </tr>
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
      <td> <strong>P</strong></td>
      <td align="right"><strong><%=CommonUtil.formatFloat((dTutionFee+dCompLabFee+dMiscFee-fTotalAmtPaid-fTotalDiscount),true)%></strong></td>
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
      <td ><strong>P</strong></td>
      <td align="right"><strong><%=CommonUtil.formatFloat((dTutionFee+dCompLabFee+dMiscFee-fTotalAmtPaid-fTotalDiscount+dOutstanding + dOtherSchPayable + dInstallmentFee),true)%></strong></td>
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
      <td colspan="4" >
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
				<td class="thinborder" valign="top"><%=vScheduledPmt.elementAt(i)%></td>
				<td class="thinborder"><%=CommonUtil.formatFloat(dTemp, true)%></td>
			</tr>
			<%}%>
	  	</table>
	  </td>
	  <td colspan="2" valign="top">
	  	<%if(vOCPayable.size() > 0) {%>
			<table border="0" width="95%" class="thinborder" align="left" cellpadding="0" cellspacing="0">
				<tr>
					<td width="73%" height="18" class="thinborder"><strong>Other School Fees Posted</strong></td>
					<td width="27%" class="thinborder"><strong>Amount</strong></td>
				</tr>
				<%
				for(int i = 0; i < vOCPayable.size(); i += 3) {%>
				<tr>
				  <td width="73%" class="thinborder" height="18"><%=vOCPayable.elementAt(i + 1)%></td>
					<td width="27%" class="thinborder"><%=vOCPayable.elementAt(i + 2)%></td>
				</tr>
				<%}%>
			</table>
	  
	  	<%}%>
	  </td>
    </tr>
<%
				}//if(vScheduledPmt != null && vScheduledPmt.size() > 0) 
				
			}//if(!strSchoolCode.startsWith("LNU"))
	
		}//if(!strSchoolCode.startsWith("LNU"))
	
	}//only if report type is current SA.

}//if(vStudInfo != null && vStudInfo.size() > 0) %>
  </table>
<%if(strSchoolCode.startsWith("LNU") || strSchoolCode.startsWith("UI") ){%>
  <br>
  <br>

<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td width="3%" height="10">&nbsp;</td>
    <td colspan="2" >&nbsp;</td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td colspan="2" ><strong>Approved by :</strong></td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td width="13%">&nbsp;</td>
    <td width="84%">____________________________</td>
  </tr>
  <%if(strSchoolCode.startsWith("LNU")){%>
  <tr>
    <td height="16">&nbsp;</td>
    <td height="16" valign="top" ><font size="1">&nbsp;</font></td>
    <td height="16" valign="top" ><font size="1"> <%=strPrintedBy.toUpperCase()%> <br>
      <strong>Accts. Custodian</strong> </font></td>
  </tr>
  <%}else{%>
  <tr>
    <td height="16">&nbsp;</td>
    <td height="16" valign="top" ><font size="1">&nbsp;</font></td>
    <td height="16" valign="top" ><font size="1"> MR. PAUL E. NECESARIO<br>
      Accountant </font></td>
  </tr>
  <%}%>
</table>
<%}else{%>
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
<%}%>
<%
	//}//only if student information is found.
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
