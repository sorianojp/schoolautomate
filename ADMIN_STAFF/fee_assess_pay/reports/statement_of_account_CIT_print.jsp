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
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<body onLoad="window.print();" leftmargin="50px">
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

String strPrintedBy = CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1);
if(strErrMsg == null)
{
	vSubjectDtls = SOA.getEnrolledSubSummary(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                      WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vSubjectDtls == null || vSubjectDtls.size() ==0)
		strErrMsg = SOA.getErrMsg();

	///get here the other other school fee and adjustment payable.. 
	if(strSchoolCode.startsWith("CSA")){
		vTemp = FA.getOtherChargePayable(dbOP,WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"), (String)vStudInfo.elementAt(0));
		if(vTemp != null && vTemp.size() > 0) {
			strTemp = (String)vTemp.elementAt(0);
			if(strTemp != null && !strTemp.equals("0.00"))
				dOtherSchPayable = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		}
	}
}


String[] astrConvertYrLevel = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
String[] astrConvertSem     = {"Summer","1ST SEM","2ND SEM","3RD SEM",
								"4TH SEM","5TH SEM","6TH SEM","7TH SEM"};
if(strErrMsg == null) strErrMsg = "";

 if(vStudInfo != null && vStudInfo.size() > 0)
 {%>
 <!--
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr valign="top">
      <td width="13%"><img src="../../../images/logo/CIT_CEBU.gif" height="75" width="75"></td>
      <td width="87%" height="16" align="center" style="font-size:18px">CEBU INSTITUTE OF TECHNOLOGY - UNIVERSITY <br>
	  <font size="1">
	  	N Bacalso Ave., Cebu City - 6000, Philippines<br>
		Tel. NO: 261-7741<br>
		Faxtel: 261-7743
	  </font></td>
    </tr>
</table>
-->
<br><br>
<br><br>
<br><br><br><br>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="16" colspan="2" align="center" style="font-size:18px">STATEMENT OF ACCOUNT<br>
        <br>&nbsp;
	  </td>
    </tr>
</table>
<%if(bolIsBasic){
astrConvertSem[1] = "Regular";%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr >
		  <td width="16%" height="20">NAME</td>
		  <td width="84%">: <%=((String)vStudInfo.elementAt(1)).toUpperCase()%></td>
		</tr>
		<tr >
		  <td height="20">GRADE LEVEL</td>
		  <td>: <%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(4))).toUpperCase()%></td>
		</tr>
		<tr >
		  <td height="20">TERM</td>
		  <td>: <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))].toUpperCase()%>, <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%></td>
		</tr>
	</table>
<%}else{%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr >
		  <td width="16%" height="20">NAME</td>
		  <td width="84%">: <%=((String)vStudInfo.elementAt(1)).toUpperCase()%></td>
		</tr>
		<tr >
		  <td height="20">COURSE</td>
		  <td>: <%=(String)vStudInfo.elementAt(2)%><%=WI.getStrValue((String)vStudInfo.elementAt(3), " - ", "","")%></td>
		</tr>
		<tr >
		  <td height="20">COLLEGE</td>
		  <td>: <%=((String)vStudInfo.elementAt(18)).toUpperCase()%></td>
		</tr>
		<tr >
		  <td height="20">TERM</td>
		  <td>: <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>, <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%></td>
		</tr>
	</table>
<%}%>

<br><br>
<br>
<table height="500px" cellpadding="0" cellspacing="0" width="100%"><tr><td valign="top">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		  <td width="36%" height="20">Tuition</td>
		  <td width="19%" align="right"><%=CommonUtil.formatFloat(dTutionFee,true)%></td>
		  <td width="45%">&nbsp;</td>
		</tr>
<%//if(dCompLabFee + dMiscOtherFee) > 0d) {%>
		<tr>
		  <td width="36%" height="20">Lab Fee</td>
		  <td width="19%" align="right"><%=CommonUtil.formatFloat(dCompLabFee + dMiscOtherFee,true)%></td>
		  <td width="45%">&nbsp;</td>
		</tr>
<%//}
	for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
		if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
			continue;
		}%>
		<tr >
		  <td><%=(String)vMiscFeeInfo.elementAt(i)%></td>
		  <td align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
		  <td height="20">&nbsp;</td>
		</tr>
	 <%}//if misc fee is not null%>
		<%
	for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
		if( true || ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
			continue;
		}
		%>
		<tr >
		  <td><%=(String)vMiscFeeInfo.elementAt(i)%></td>
		  <td align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
		  <td height="20">&nbsp;</td>
		</tr>
	 <%}//if misc fee is not null%>
		<tr>
		  <td colspan="3">----------------------------------------------------------------------------------------------------------------------------</td>
		</tr>
		<tr>
		  <td align="center">TOTAL ===========> </td>
		  <td align="right"><%=CommonUtil.formatFloat(dTutionFee+dCompLabFee+dMiscFee,true)%></td>
		  <td height="20">&nbsp;</td>
		</tr>
	</table>
</td></tr></table>
<%
}//if(vStudInfo != null && vStudInfo.size() > 0) %>
  </table><br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    
    <tr valign="bottom" align="center">
      <td width="1%" height="80" >&nbsp;</td>
      <td width="50%"><%=strPrintedBy%></td>
      <td width="36%" align="center">MR. LEONARDO C. NABUA</td>
      <td width="13%">&nbsp;</td>
    </tr>
    <tr valign="top" align="center">
      <td>&nbsp;</td>
      <td>Printed By </td>
      <td align="center">Accountant</td>
      <td>&nbsp;</td>
    </tr>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>
