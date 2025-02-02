<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>One Receipt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--

@media print { 
  @page {
		size:6.5in 4.5in; 
		/*margin:0in .5in 0in 1in; 
		 top right bottom left */
		 margin-top:.3in;
		 margin-bottom:0in;
	}
}

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
-->
</style>
</head>

<body leftmargin="30" rightmargin="0" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolIsDownPmt =false;
	String strAmtTendered = null;
	String strAmtChange   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Other school fees","otherschoolfees_print_receipt.jsp");
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
//boolean bolShowLabel = false;//for actual, set it to false;
//boolean bolIsGradeShoolPmt = false;

boolean bolIsBasic = false;


String strStudID     = null;
String strStudName   = null;
String strCourse     = null;
String strStudStatus = null;
String strAmount     = null;
String strBankName   = null;
String strCheckNo    = null;
String strDatePaid   = null;

String strPaymentFor = null;
String strPmtMode    = null;

double dChkAmt = 0d; 
double dCashAmt = 0d;
float fTutionFee        = 0f;
float fCompLabFee       = 0f;
float fMiscFee          = 0f;
float fOutstanding      = 0f;
float fTotalPayableAmt 	= 0f;
double dTotalDiscount   = 0d;
float fMiscOtherFee     = 0f;//This is the misc fee other charges,
float fEnrollmentDiscount = 0f;

FAPayment faPayment        = new FAPayment();
enrollment.FAAssessment FA = new enrollment.FAAssessment();
double dOutStandingBalance = 0d;
String strPmtSchName = null;
boolean bolIsOkForExam = false;
String strCollegeName = null;
Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));

//if(vRetResult != null && vRetResult.elementAt(0) != null && false) {
//	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
//	//System.out.println(vRetResult.elementAt(0));
//	dOutStandingBalance= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vRetResult.elementAt(0), true, true);
//
//	strPmtSchName = (String)vRetResult.elementAt(28);
//	if(strPmtSchName != null) {
//		if(strPmtSchName.toLowerCase().startsWith("final")) {//no o/s balance allowed.
//			if(dOutStandingBalance < 1d)
//				bolIsOkForExam = true;
//		}
//		else {
//			double dAmtDue  = 0d;//check amt due. if due is < 0d;, then ok for exam, else check 80% if paid.
//			boolean bolBreak = false;
//			Vector vInstallmentInfo = FA.getInstallmentSchedulePerStudAllInOneVersion2(dbOP, (String)vRetResult.elementAt(0),
//									  (String)vRetResult.elementAt(23), (String)vRetResult.elementAt(24), (String)vRetResult.elementAt(21), 
//									  (String)vRetResult.elementAt(22));//System.out.println(vInstallmentInfo);
//			if(vInstallmentInfo != null) {				
//				for(int i = 7; i < vInstallmentInfo.size()-1; i +=2) {			
//					if(strPmtSchName.equals(vInstallmentInfo.elementAt(i)))//consider only payment for the period.
//						//bolBreak = true;
//						dAmtDue += ((Double)vInstallmentInfo.elementAt(i + 1)).doubleValue();
//					//if(bolBreak)
//				 		//break;  
//				}
//			}
//			if(dAmtDue < 1d)
//				bolIsOkForExam = true;
//			else {
//				//from this, i can get only the amt paid for a pmt schedule.. 
//				vInstallmentInfo = FA.getInstallmentSchedulePerStudent(dbOP, (String)vRetResult.elementAt(0),
//										  (String)vRetResult.elementAt(23), (String)vRetResult.elementAt(24), (String)vRetResult.elementAt(21), 
//										  (String)vRetResult.elementAt(22));
//				//System.out.println(vInstallmentInfo);
//				//System.out.println("Amoutn Due : "+dAmtDue);
//				//I have to find out how much paid and payment amount.. 
//				double dAmtPaid = 0d;
//				
//		
//				bolBreak = false;
//				for(int i = 5; i < vInstallmentInfo.size()-1; i +=3) {			
//					if(strPmtSchName.equals(vInstallmentInfo.elementAt(i)))
//						bolBreak = true;
//					 dAmtPaid += ((Float)vInstallmentInfo.elementAt(i + 2)).doubleValue();	
//
//					 if(bolBreak)
//					 	break;
//				}//end of for loop..
//			 
//			 	double dAmtPayableEightPercent = dAmtDue * 4d;//must pay more than that amt.
//				if(dAmtPaid >= dAmtPayableEightPercent)
//					bolIsOkForExam = true;
//				//System.out.println("dAmtPayableEightPercent : "+dAmtPayableEightPercent);
//				//System.out.println("dAmtPaid : "+dAmtPaid);
//				//System.out.println("dAmtDue : "+dAmtDue);
//			}
//		}//end of else
//	}//if(strPmtSchName != null)
//}//if(vRetResult != null && vRetResult.elementAt(0) != null)

if(vRetResult == null) {
	//may be basic payment.
	vRetResult = new enrollment.FAElementaryPayment().viewPmtDetail(dbOP, request.getParameter("or_number"));//System.out.println(vRetResult);
	if(vRetResult != null) {
		//bolIsGradeShoolPmt = true;
		strStudID     = (String)vRetResult.elementAt(4);
		strStudName   = WebInterface.formatName((String)vRetResult.elementAt(6),(String)vRetResult.elementAt(7),
						(String)vRetResult.elementAt(8),4);
		String[] astrConvertToEduLevel = {"Preparatory","Elementary","High School"};
		strCourse     = astrConvertToEduLevel[Integer.parseInt((String)vRetResult.elementAt(0))];
		strStudStatus = "";
		strPaymentFor = "Tuition Fee";
		strAmount     = (String)vRetResult.elementAt(9);
		strPmtMode    = (String)vRetResult.elementAt(12);
		strBankName   = (String)vRetResult.elementAt(14);
		strCheckNo    = (String)vRetResult.elementAt(10);
		strDatePaid   = (String)vRetResult.elementAt(11);
		
		dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
		dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));
		
		strAmtTendered = (String)vRetResult.elementAt(48);
		strAmtChange   = (String)vRetResult.elementAt(49);
		if(strAmtTendered.equals("0.00"))
			strAmtTendered = CommonUtil.formatFloat(strAmount,true);
	}
	else
		strErrMsg = faPayment.getErrMsg();

}
else {//not basic payment.
	dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
	dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));
	
	strAmtTendered = (String)vRetResult.elementAt(48);
	strAmtChange   = (String)vRetResult.elementAt(49);
	if(strAmtTendered.equals("0.00"))
		strAmtTendered = CommonUtil.formatFloat(strAmount,true);
	
	if(!vRetResult.elementAt(45).equals("0")) {
		dChkAmt = dCashAmt;
		dCashAmt = 0d;
	}
		

		strStudID     = WI.getStrValue((String)vRetResult.elementAt(25),"");
		//name
		if( vRetResult.elementAt(0) != null)
			strStudName     = (String)vRetResult.elementAt(18);
		else
			strStudName     = (String)vRetResult.elementAt(1);

		strCourse     = WI.getStrValue((String)vRetResult.elementAt(35));
		
		if(strCourse.length() > 0) {
			strTemp = "select c_code from college join course_offered on (course_offered.c_index = college.c_index) "+
				" where course_code = "+WI.getInsertValueForDB(strCourse, true	, null);
			strCollegeName = dbOP.getResultOfAQuery(strTemp, 0);
		}
		
		if(strCourse.length() == 0 && vRetResult.elementAt(21) != null) {//basic student.
			int iYear = Integer.parseInt((String)vRetResult.elementAt(21));
			strCourse = dbOP.getBasicEducationLevel(iYear);
			bolIsBasic = true;
		}
		//student status.
		if( ((String)vRetResult.elementAt(29)).compareTo("0") == 0)
			strStudStatus = "Old Student";
		else
			strStudStatus = "New Student";
	
		if (WI.fillTextValue("oth_sch_fee").equals("1") && 
			 WI.fillTextValue("stud_status").equals("1")) 
			 	strStudStatus = "";

		strAmount     = (String)vRetResult.elementAt(11);
		if(vRetResult.elementAt(33) != null)
			strPaymentFor = (String)vRetResult.elementAt(33);
		else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0) {
			//id d/p then it is deposit, else it is the name of fee.
			strPaymentFor = "Tuition Fee";
		}
		else {
			//if there is additional
			if(vRetResult.elementAt(42) != null)
				strPaymentFor = (String)vRetResult.elementAt(42);
			else if(vRetResult.elementAt(4).equals("10"))
				strPaymentFor = "Back Account";
			else
				strPaymentFor = (String)vRetResult.elementAt(5);
		}
//System.out.println(vRetResult);

		strPmtMode    = (String)vRetResult.elementAt(10);
		strBankName   = (String)vRetResult.elementAt(34);
		strCheckNo    = (String)vRetResult.elementAt(14);
		strDatePaid   = WI.getStrValue(vRetResult.elementAt(15));
		if(strBankName != null) {
			int iIndexOf = strBankName.indexOf("(");
			if(iIndexOf > -1)
				strBankName = strBankName.substring(0,iIndexOf);
		}
		
		///may be it is bank posting.. 
		if(vRetResult.elementAt(51) != null)
			strBankName = (String)vRetResult.elementAt(51);
}



String[] astrConvertSem = {"Summer","1st","2nd", "3rd"};
String[] astrConvertSemBasic = {"Summer","Regular"};

if(strErrMsg == null){
String strTimePaid = null;
String strPmtSchIndex = null;
strTemp = "select create_time, PMT_SCH_INDEX from FA_STUD_PAYMENT where IS_VALID = 1 and OR_NUMBER = "+WI.getInsertValueForDB(WI.fillTextValue("or_number"), true, null);
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
if(rs.next()){
	strTimePaid = CommonUtil.convert24HRTo12Hr(rs.getDouble(1));
	strPmtSchIndex = rs.getString(2);
	if(rs.getInt(2) == 0)
		bolIsDownPmt = true;
}rs.close();

strTemp = "select PMT_SCH_INDEX from FA_PMT_SCHEDULE where IS_VALID = 1 order by EXAM_PERIOD_ORDER";
if(bolIsBasic)
	strTemp = "select PMT_SCH_INDEX from FA_PMT_SCHEDULE where BSC_GRADING_NAME is not null and IS_VALID =2 order by EXAM_PERIOD_ORDER";
strTemp = dbOP.getResultOfAQuery(strTemp, 0); //first result is the first installment
if(strTemp != null && strTemp.equals(strPmtSchIndex))
	bolIsDownPmt = true;

if(bolIsDownPmt){
	enrollment.FAPaymentUtil paymentUtil = new enrollment.FAPaymentUtil();
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	paymentUtil.setTempUser("0");
	
	 fTutionFee = fOperation.calTutionFee(dbOP, (String)vRetResult.elementAt(0),paymentUtil.isTempStud(),
		 (String)vRetResult.elementAt(23),(String)vRetResult.elementAt(24),(String)vRetResult.elementAt(21),(String)vRetResult.elementAt(22));

	 if(fTutionFee > 0f)
	 {
	  fMiscFee  = fOperation.calMiscFee(dbOP, (String)vRetResult.elementAt(0),paymentUtil.isTempStud(),
		 (String)vRetResult.elementAt(23),(String)vRetResult.elementAt(24),(String)vRetResult.elementAt(21),(String)vRetResult.elementAt(22));
		 	
	  fCompLabFee = fOperation.calHandsOn(dbOP, (String)vRetResult.elementAt(0),paymentUtil.isTempStud(),
		 (String)vRetResult.elementAt(23),(String)vRetResult.elementAt(24),(String)vRetResult.elementAt(21),(String)vRetResult.elementAt(22));
	 
	 
	  /*fOperation.checkIsEnrolling(dbOP, (String)vRetResult.elementAt(0),
		(String)vRetResult.elementAt(23),(String)vRetResult.elementAt(24),(String)vRetResult.elementAt(22));*/
	  
	  fMiscOtherFee = fOperation.getMiscOtherFee();
	
	  enrollment.FAFeeOperationDiscountEnrollment test = new enrollment.FAFeeOperationDiscountEnrollment();
	  Vector vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,(String)vRetResult.elementAt(0),paymentUtil.isTempStud(),
		 (String)vRetResult.elementAt(23),(String)vRetResult.elementAt(24),(String)vRetResult.elementAt(21),(String)vRetResult.elementAt(22),
											fOperation.dReqSubAmt);
	  String strEnrolmentDiscDetail  = null;
	  if(vTemp != null && vTemp.size() > 0)
	   strEnrolmentDiscDetail = (String)vTemp.elementAt(0);//System.out.println(vTemp);
	  if(strEnrolmentDiscDetail != null && vTemp != null && vTemp.size() > 0)
	  {
	   fEnrollmentDiscount = ((Float)vTemp.elementAt(1)).floatValue();
	  }
	 }
	else
		strErrMsg = fOperation.getErrMsg();
}



String strCash = null;
String strCheck = null;

if(Integer.parseInt((String)vRetResult.elementAt(50)) > 0)
	CommonUtil.formatFloat((String)vRetResult.elementAt(11),true);
else if(vRetResult.elementAt(14) == null)
	strCash = CommonUtil.formatFloat((String)vRetResult.elementAt(11),true);
else {
	if(dCashAmt > 0d)
		strCash = CommonUtil.formatFloat(dCashAmt,true);						
	strCheck = CommonUtil.formatFloat(dChkAmt,true);
}

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<%
		strTemp = "";

		if(vRetResult.elementAt(22) != null) {
			if(!bolIsBasic)
			  	strTemp = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))];
			else{
				strTemp = (String)vRetResult.elementAt(22);
				if(Integer.parseInt(strTemp) > 1)
					strTemp = "1";
				strTemp = astrConvertSemBasic[Integer.parseInt(strTemp)];
			}
		}
		%>
		<td style="padding-left:100px;"><%//=strTemp%> 
			&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
			<%//=(String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24))%>
			</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="30%" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr><td colspan="2" height="35">&nbsp;</td></tr>
				<tr>
					<td width="51%">&nbsp;</td>
					<%
					strTemp = "";
					if(WI.getStrValue(strPaymentFor).toLowerCase().startsWith("tuition"))
						strTemp = strCash; 
						
					if(bolIsDownPmt)
						strTemp = CommonUtil.formatFloat(fTutionFee,true); 
					%>
					<td height="22" width="49%"><%//=WI.getStrValue(strTemp)%><!--tuition--></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<%
					strTemp = "";
					if(!WI.getStrValue(strPaymentFor).toLowerCase().startsWith("tuition"))
						strTemp = strCash; 
						
					if(bolIsDownPmt)
						strTemp = CommonUtil.formatFloat(fMiscOtherFee + fCompLabFee + (fMiscFee-fMiscOtherFee),true);
					%>
					<td height="22"><%//=strTemp%><!--misc--></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<%					
					strTemp = "";
					if(bolIsDownPmt)
						strTemp = CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true);
					%>
					<td height="22"><%//=strTemp%><!--total assessment--></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<%					
					strTemp = "";
					if(bolIsDownPmt && fEnrollmentDiscount > 0f)
						strTemp = CommonUtil.formatFloat(fEnrollmentDiscount,true);
					%>
					<td height="22"><%//=strTemp%><!--discount--></td>
				</tr>
				<tr>
					<td height="56px">&nbsp;</td>
					<%
					
					strTemp = strCash;
					
					
					if(bolIsDownPmt)
						strTemp = CommonUtil.formatFloat((fTutionFee+fCompLabFee+fMiscFee)-fEnrollmentDiscount,true);
					%>
					<td valign="bottom"><%//=WI.getStrValue(strTemp)%><!--total due--></td>
				</tr>
			</table>
		</td>
		<td width="70%" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr><td height="30">&nbsp;</td></tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr><td colspan="3" height="22" align="right"><!--or number--><%=WI.fillTextValue("or_number")%></td></tr>
				<tr><td width="53%" height="25" valign="bottom" style="padding-left:200px;"><!--stud id--><%=strStudID%></td>
				    <td width="26%" height="25" align="right" valign="bottom" style="padding-right:40px;">&nbsp;</td>
				    <td height="25" valign="bottom"><!--date paid--><%=strDatePaid%></td>
				</tr>
				
				<tr><td height="22" colspan="2"  style="padding-left:110px;"><!--stud name--><%=strStudName%></td>
				    <td style="padding-left:65px;"><%//=WI.getStrValue(strCollegeName)%></td>
				</tr>
				<tr>
				    <td>&nbsp;</td>
				    <td colspan="2">&nbsp;</td>
			    </tr>
				<!--<tr>
					<td height="22" colspan="3"></td>
			    </tr>
				<tr>
				    <td>&nbsp;</td>
				    <td colspan="2">&nbsp;</td>
			    </tr>-->
				<tr>
				    <td colspan="3" style="padding-left:90px;"><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%></td>
			    </tr>
				<tr>
				    <td height="20" colspan="3" style="padding-left:50px;">&nbsp;</td>
			    </tr>
				
				<tr>
				    <td height="16"></td>
			        <td height="16">&nbsp;</td>
			        <%
					if(strCash == null)
						strCash = strCheck;
					%>
				    <td width="21%" valign="top" style="padding-left:50px;"><%=WI.getStrValue(strCash)%></td>
				</tr>
				
				<tr>
				    <td style="padding-left:50px;" height="16"><!--CASH--><%=WI.getStrValue(strCash)%></td>
			        <td height="16" colspan="2" style="padding-left:50px;">Cash Received : <%=CommonUtil.formatFloat(strAmount,true)%></td>
			    </tr>
				<tr>
				    <td style="padding-left:50px;" height="16"><!--CHECK--><%=WI.getStrValue(strCheck)%></td>
			        <td height="16" colspan="2" style="padding-left:50px;">Amount Paid : <%=strAmtTendered%></td>
			    </tr>
				<tr>
				    <td style="padding-left:50px;" height="16"><!--CHECK NO--><%=WI.getStrValue(strCheckNo)%></td>
			        <td colspan="2" style="padding-left:50px;">Change : <%=strAmtChange%></td>
		        </tr>
				<tr>
				    <td style="padding-left:50px;" height="16"><!--BANK--><%=WI.getStrValue(strBankName)%></td>
			        <td height="16" colspan="2" style="padding-left:50px;"><!--Amount Paid : <%=strAmtTendered%>--></td>
		        </tr>
				<tr>
				    <td style="padding-left:50px;"><!--PMO--><%=WI.getStrValue(strPaymentFor).toUpperCase()%></td>
			        <td colspan="2" style="padding-left:50px;"><!--Change : <%=strAmtChange%>--></td>
		        </tr>
				
				<tr>
				    <td height="40" valign="bottom" style="padding-left:50px;">&nbsp;</td>
					<td valign="top" colspan="2" style="padding-left:30px;"><%=request.getSession(false).getAttribute("first_name")%>
					<font size="1"><%=WI.getStrValue(strTimePaid)%></font></td>
			    </tr>
			</table>
		</td>
	</tr>
</table>

<!--<br><br><br><br>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		<tr valign="top">
		  <td>&nbsp;</td>
		  <td>&nbsp;&nbsp;&nbsp;&nbsp;TR #: <%=WI.fillTextValue("or_number")%></td>
	  </tr>
		<tr valign="top">
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
		<tr valign="top">
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
		<tr valign="top">
		  <td width="69%"><%=strStudName%></td>
		  <td width="31%">&nbsp;&nbsp;&nbsp;&nbsp;<%=strDatePaid%></td>
	  </tr>
		<tr valign="top">
		  <td><%=strStudID%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  <%=strCourse%> <%=WI.getStrValue((String)vRetResult.elementAt(21))%>		  </td>
		  <td>&nbsp;&nbsp;&nbsp;&nbsp;
		    <% 
			if(vRetResult.elementAt(22) != null) {
		  		strTemp = (String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24)).substring(2);
		  		if(vRetResult.elementAt(22).equals("0"))
		  			strTemp = (String)vRetResult.elementAt(24);
			}
		  //System.out.println(vRetResult);%>
		  <%if(!bolIsBasic && vRetResult.elementAt(22) != null) {%>
		  	<%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>, 
		  <%}%>
		  <%=WI.getStrValue(strTemp)%>		  </td>
	  </tr>
		<tr valign="top">
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
		<tr valign="top">
		  <td><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%></td>
	      <td>&nbsp;&nbsp;&nbsp;&nbsp;<%=CommonUtil.formatFloat(strAmount,true)%></td>
	  </tr>
		<tr valign="bottom">
		  <td height="18" colspan="2">		  </td>
	  </tr>
		
		<tr valign="bottom">
		  <td height="40" colspan="2" valign="top"><%=strPaymentFor%></td>
	    </tr>
    </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		<tr valign="bottom">
		  <td width="22%" height="18">&nbsp;</td>
		  <td width="27%">
		  <%if(Integer.parseInt((String)vRetResult.elementAt(50)) > 0) {%>
		  	Bank Payment: <%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
		  <%}else if(vRetResult.elementAt(14) == null){%>
			aCASH: <%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
		  <%}//show only if check.
		    else {//it can be check only or cash and check
				if(dCashAmt > 0d){%>
					CASH: <%=CommonUtil.formatFloat(dCashAmt,true)%>&nbsp;&nbsp;
				<%}%>
				CHECK: <%=CommonUtil.formatFloat(dChkAmt,true)%>
			<%}%>		  </td>
	      <td width="51%" style="font-size:14px; font-weight:bold">
		  <%if(bolIsOkForExam && false) {%>
				OK FOR <%=strPmtSchName.toUpperCase()%>
          <%}%>
		  
		  &nbsp;</td>
	  </tr>
		<tr valign="bottom">
		  <td height="18">&nbsp;</td>
		  <td colspan="2"><%=WI.getStrValue(strBankName)%> </td>
	  </tr>
		<tr valign="bottom">
		  <td height="18">&nbsp;</td>
		  <td colspan="2"><%=WI.getStrValue(strCheckNo)%> </td>
	  </tr>
    </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="23%">&nbsp;</td>
			<td width="72%">&nbsp;
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td valign="top">&nbsp;</td>
	      <td valign="top" align="center">
			 
			<%=request.getSession(false).getAttribute("first_name")%></td>
		</tr>
    </table>--> 
	<script>window.print();</script>
<%}else{//print error msg%>
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
 	<tr>
      <td align="center"><%=strErrMsg%></td>
    </tr>
</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
