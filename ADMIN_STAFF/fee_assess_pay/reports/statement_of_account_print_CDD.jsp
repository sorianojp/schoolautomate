<%@ page language="java" import="utility.*,EnrlReport.StatementOfAccount,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	//strSchoolCode = "HTC";
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
	
	if(strSchoolCode.startsWith("HTC")){%>
		<jsp:forward page="./statement_of_account_print_HTC.jsp" />
	<%}
	if(strSchoolCode.startsWith("CIT")){%>
		<jsp:forward page="./statement_of_account_CIT_print.jsp" />
	<%}
	if(strSchoolCode.startsWith("SWU")){%>
		<jsp:forward page="./statement_of_account_print_SWU.jsp" />
	<%}
	if(strSchoolCode.startsWith("UB")){%>
		<jsp:forward page="./cert_enrol_billing_ched_print_UB.jsp" />
	<%}
	if(strSchoolCode.startsWith("VMA")){%>
		<jsp:forward page="./statement_of_account_print_vma.jsp" />
	<%}
	if(strSchoolCode.startsWith("SPC")){%>
		<jsp:forward page="./statement_of_account_print_SPC.jsp" />
	<%}
	if(strSchoolCode.startsWith("UPH") && !strSchoolCode.startsWith("UPH07")){
		strTemp = (String)request.getSession(false).getAttribute("info5");//dbOP.getResultOfAQuery("select info5 from sys_info", 0);
		if(strTemp != null && strTemp.equals("jonelta")) {%>
			<jsp:forward page="./statement_of_account_UPHJ_print.jsp" />
		<%}
	}
	if(strSchoolCode.startsWith("WNU")) {%>
			<jsp:forward page="./statement_of_account_WNU_print_perexam.jsp" />
		<%
	return;}
	if(strSchoolCode.startsWith("AUF")) {
		if(WI.fillTextValue("is_sa_perexam").equals("1")){%>
			<jsp:forward page="./statement_of_account_AUF_print_perexam.jsp" />
		<%}else{%>
			<jsp:forward page="./statement_of_account_AUF_print_new.jsp" />
	<%}
	return;}

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


@media print { 
  div.dlshsi_footer{
  	position:absolute;
	bottom:0px;
  }
}

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
<%if(strSchoolCode.startsWith("DLSHSI")){%>
	<tr >
        <td height="16" colspan="2" align="center" >
		<div style="display:block;"><img src="../../../images/logo/<%=strSchoolCode%>.gif" border="0" height="70" width="70" align="absmiddle">
		&nbsp;<strong style="font-size:21px;"><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong></div>		</td>
    </tr>
	<tr >
	    <td width="49%" height="16" ><strong style="font-size:12px">STATEMENT OF ACCOUNT</strong><br>
		<%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>,
	    <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%></td>
		<%
		strTemp = new enrollment.DLSHSIAutogen().autogenNumber(dbOP, 1, 6, "SOA");
		%>
        <td width="51%" align="right" ><%=strTemp%></td>
	</tr>
<%}else{%>
    <tr >
      <td height="16" colspan="2"><div align="center"><strong>
	  <font size="2">
	  <%if(strSchoolCode.startsWith("LNU")){%>
	  <br><br><br><br><br><br><br><br><%}%>	  
	  STATEMENT OF ACCOUNT</font></strong><br>
          <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>,
		  <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%></div></td>
    </tr>    
    <tr >
      <td height="16" colspan="3" ><font size="2">&nbsp;</font>          <div align="right"><font size="1">&nbsp;Date
        and time printed: <%=WI.getTodaysDateTime()%></font></div></td>
    </tr>
<%}%>
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
<%if(strSchoolCode.startsWith("CSA") || strSchoolCode.startsWith("VMA") || dOtherSchPayable > 0d) {%>
    <tr>
      <td height="16" width="2%">&nbsp;</td>
      <td width="22%" ><strong>Other School Fee + Adjustments</strong></td>
      <td width="43%" >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -      </td>
      <td width="3%">&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dOtherSchPayable,true)%> </td>
      <td width="20%">&nbsp;</td>
    </tr>
<%}%>
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
<%if(!strSchoolCode.startsWith("LNU") && !strSchoolCode.startsWith("DLSHSI")){%>
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
      <td>P</td>
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
      <td> <strong>P</strong></td>
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
      <td ><strong>P</strong></td>
      <td align="right"><strong><%=CommonUtil.formatFloat((dTutionFee+dCompLabFee+dMiscFee-fTotalAmtPaid-fTotalDiscount+dOutstanding + dOtherSchPayable + dInstallmentFee + dAddDropFee),true)%></strong></td>
      <td >&nbsp;</td>
    </tr>
<%
if(!strSchoolCode.startsWith("LNU")){%>
<%
if(strSchoolCode.startsWith("CSA") && !bolIsBasic){
//college code.
strTemp = ((String)vStudInfo.elementAt(19)).toUpperCase();
String strDepartmentalFee = null;
boolean bolIsRetreatFee = false;
if(strTemp.equals("CASE"))
	strDepartmentalFee = "500.00";
else if(strTemp.equals("CABECS"))
	strDepartmentalFee = "200.00";
else if(strTemp.equals("COE"))
	strDepartmentalFee = "700.00";
else if(strTemp.equals("CON"))
	strDepartmentalFee = "100.00";
else
	strDepartmentalFee = "-- Not Set --";

strTemp = ((String)vStudInfo.elementAt(16)).toUpperCase();
if(vStudInfo.elementAt(4).equals("5") || 
	(vStudInfo.elementAt(4).equals("4") && !strTemp.equals("BSECE") && !strTemp.equals("BSCHE") && !strTemp.equals("BSCE") && !strTemp.equals("BSME") && !strTemp.equals("BSCOE")) ) 
	bolIsRetreatFee = true;
%>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="6" ><strong><u>Total charges exclusive of:</u></strong></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="6" >
	  	<table width="60%" cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="35%">Departmental Fee</td>
				<td width="15%"><%=strDepartmentalFee%></td>
				<td width="35%">PTA</td>
				<td width="15%">50.00</td>
			</tr>
			<tr>
				<td>SG</td>
				<td>120.00</td>
				<td>Eagle</td>
				<td>35.00</td>
			</tr>
<%if(vStudInfo.elementAt(4).equals("3")){%>
			<tr>
			  <td>Recollection</td>
			  <td>400.00</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
		  </tr>
<%}if(bolIsRetreatFee){%>
			<tr>
			  <td>Retreat</td>
			  <td>650.00</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
		  </tr>
<%}%>		  
		</table>	  </td>
    </tr>
<%}//show only for CSA%>
<%
if(strPlanInfo != null){
%>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="6" ><font size="2" style="font-weight:bold"><u>Plan Subscribed: <%=strPlanInfo.toUpperCase()%></u></font></td>
    </tr>
<%}%>
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
<%}else{
	if(strSchoolCode.startsWith("DLSHSI")){
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td width="1%" height="10">&nbsp;</td>
      <td colspan="3" >&nbsp;</td>
      <td colspan="3" >&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td colspan="2" >Prepared by :</td>
      <td width="32%" >Checked by :</td>
      <td colspan="3" >Approved by :</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td><u>&nbsp;&nbsp;<%=strPrintedBy%>&nbsp;&nbsp;</u></td>
      <td valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%;"></div></td>
      <td width="5%">&nbsp;</td>

    <td width="21%" class="thinborderBOTTOM">&nbsp;</td>
    <td width="8%">&nbsp;</td>
    </tr>
    <tr>
      <td height="16">&nbsp;</td>
      <td height="16" >&nbsp;</td>
      <td height="16" valign="top" ><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Printed
        by </font></td>
      <td height="16" valign="top" >Head-Cash Services</td>
      <td height="16" valign="top" ><font size="1">&nbsp;</font></td>
      <td height="16" valign="top" ><font size="1">
      <div align="center">Director</div>
      </font></td>
      <td valign="top" >&nbsp;</td>
    </tr>
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
<%}

}%>

<%if(strSchoolCode.startsWith("DLSHSI")){%>
<div class="dlshsi_footer">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr>
	<td width="50%">BIR PERMIT NO. <0000-000-00000> CAS &lt;month/date/year&gt</td>
	<td align="right">Date and time printed: <%=WI.getTodaysDateTime()%></td>
</tr>
</table>
</div>
<%}%>

<%
	//}//only if student information is found.
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
