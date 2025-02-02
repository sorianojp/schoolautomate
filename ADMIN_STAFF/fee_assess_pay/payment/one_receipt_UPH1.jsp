<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>One Receipt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

</style>
</head>

<body  onLoad="window.print();" leftmargin="100">

<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean bolIsFine = false;
	boolean bolIsDownPmt =false;

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
boolean bolShowLabel = false;//for actual, set it to false;
boolean bolIsGradeShoolPmt = false;

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

double dChkAmt = 0d; double dCashAmt = 0d;

String strAmtTendered = null;
String strAmtChange   = null;

FAPayment faPayment        = new FAPayment();
enrollment.FAAssessment FA = new enrollment.FAAssessment();
double dOutStandingBalance = 0d;
String strPmtSchName = null;
boolean bolIsOkForExam = false; boolean bolIsTuitionPmt = false;


double dAssessment    = 0d;
double dTotalDiscount = 0d;
double dPrevBalance   = 0d;
double dPrevPayment   = 0d;

String strTellerName  = null;

//dOutStandingBalance = total outstanding balance -->

Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));
if(vRetResult == null) {
	//may be basic payment.
	vRetResult = new enrollment.FAElementaryPayment().viewPmtDetail(dbOP, request.getParameter("or_number"));//System.out.println(vRetResult);
	if(vRetResult != null) {
		bolIsGradeShoolPmt = true;
		strStudID     = (String)vRetResult.elementAt(4);
		strStudName   = WebInterface.formatName((String)vRetResult.elementAt(6),(String)vRetResult.elementAt(7),
						(String)vRetResult.elementAt(8),4);
		String[] astrConvertToEduLevel = {"Preparatory","Elementary","High School"};
		strCourse     = astrConvertToEduLevel[Integer.parseInt((String)vRetResult.elementAt(0))];
		strStudStatus = "";strPaymentFor = "Tuition";
		strAmount     = (String)vRetResult.elementAt(9);
		strPmtMode    = (String)vRetResult.elementAt(12);
		strBankName   = (String)vRetResult.elementAt(14);
		strCheckNo    = (String)vRetResult.elementAt(10);
		strDatePaid   = (String)vRetResult.elementAt(11);
		
		dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
		dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));
		
		
	}
	else
		strErrMsg = faPayment.getErrMsg();

}
else {//not basic payment.
	dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
	dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));
	
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

		strCourse     = WI.getStrValue((String)vRetResult.elementAt(35),"");
		if(strCourse.length() > 0) {
			//do nothing.. 
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
			//strPaymentFor = "Tuition";\
			
			String strSQLQuery = "select sum(amount) from fa_stud_payment where payment_for = 0 and is_valid = 1"+
				" and or_number is not null and amount > 0 and or_number <> '"+WI.fillTextValue("or_number")+
				"' and user_index = "+(String)vRetResult.elementAt(0)+" and sy_from = "+(String)vRetResult.elementAt(23)+
				" and semester = "+(String)vRetResult.elementAt(22);
			java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next()) 
				dPrevPayment = rs.getDouble(1);
			rs.close();
			
				
			bolIsTuitionPmt = true;

			enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
			enrollment.FAPaymentUtil paymentUtil = new enrollment.FAPaymentUtil();
			paymentUtil.setTempUser("0");
			
			float fTutionFee = fOperation.calTutionFee(dbOP, (String)vRetResult.elementAt(0),paymentUtil.isTempStud(),
								(String)vRetResult.elementAt(23),(String)vRetResult.elementAt(24),(String)vRetResult.elementAt(21),(String)vRetResult.elementAt(22));
			float fMiscFee   = fOperation.calMiscFee(dbOP, (String)vRetResult.elementAt(0),paymentUtil.isTempStud(),
								(String)vRetResult.elementAt(23),(String)vRetResult.elementAt(24),(String)vRetResult.elementAt(21),(String)vRetResult.elementAt(22));
			float fCompLabFee = fOperation.calHandsOn(dbOP, (String)vRetResult.elementAt(0),paymentUtil.isTempStud(),
								(String)vRetResult.elementAt(23),(String)vRetResult.elementAt(24),(String)vRetResult.elementAt(21),(String)vRetResult.elementAt(22));
	
			dAssessment = fTutionFee + fMiscFee + fCompLabFee;
			dTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vRetResult.elementAt(0),(String)vRetResult.elementAt(23),
        				(String)vRetResult.elementAt(24),(String)vRetResult.elementAt(21),(String)vRetResult.elementAt(22),null);
			
			enrollment.FAFeeOperationDiscountEnrollment test = new enrollment.FAFeeOperationDiscountEnrollment();
			Vector vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,(String)vRetResult.elementAt(0),paymentUtil.isTempStud(),
						(String)vRetResult.elementAt(23),(String)vRetResult.elementAt(24),
											(String)vRetResult.elementAt(21),(String)vRetResult.elementAt(22),
											fOperation.dReqSubAmt);
			if(vTemp != null && vTemp.size() > 0 && vTemp.elementAt(0) != null)
			{
				dTotalDiscount += ((Float)vTemp.elementAt(1)).doubleValue();
			}


			dPrevBalance= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vRetResult.elementAt(0));
			
			dOutStandingBalance= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vRetResult.elementAt(0), true, true);
			
			if(vRetResult.elementAt(27).equals("0"))
				strPaymentFor = "Downpayment";
			else {//do not consider OK for permit for d/p.. 
				strPaymentFor = "Tuition and Fees";
				if(dOutStandingBalance < 1d) 
					bolIsOkForExam = true;
				else if(!vRetResult.elementAt(27).equals("0")){	
					/**
					Vector vInstallmentDtls = FA.getInstallmentSchedulePerStudPerExamSch(dbOP,(String)vRetResult.elementAt(27), (String)vRetResult.elementAt(0),
												(String)vRetResult.elementAt(23),(String)vRetResult.elementAt(24),(String)vRetResult.elementAt(21), (String)vRetResult.elementAt(22)) ;
					if(vInstallmentDtls != null) {
						double dDueForThisPeriod = Double.parseDouble((String)vInstallmentDtls.elementAt(5));
						if(dDueForThisPeriod < 1d)
							bolIsOkForExam = true;
					}**/
				}
			}
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

		strAmtTendered = (String)vRetResult.elementAt(48);
		strAmtChange   = (String)vRetResult.elementAt(49);
		if(strAmtTendered.equals("0.00"))
			strAmtTendered = CommonUtil.formatFloat(strAmount,true);
		
		if(strBankName != null && strBankName.indexOf("(") > 0) {
			strBankName = strBankName.substring(0,strBankName.indexOf("(")); 
			strTemp = dbOP.getResultOfAQuery("select bank_code from fa_bank_list where bank_name = "+
				WI.getInsertValueForDB(strBankName, true, null)+" and is_valid = 1", 0);
			if(strTemp != null)
				strBankName = strTemp;
		}
		strTellerName = (String)vRetResult.elementAt(39);
		if(strTellerName != null)
			strTellerName = strTellerName.substring(strTellerName.indexOf(",") + 1);

}

String[] astrConvertSem = {"Summer","1st Term","2nd Term","3rd Term"};

String strSYTerm = null;

if(strErrMsg == null){
	if(vRetResult.elementAt(22) != null) {
		strSYTerm = (String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24)).substring(2);
		if(vRetResult.elementAt(22).equals("0"))
			strSYTerm = (String)vRetResult.elementAt(24);
	}
	if(!bolIsBasic && vRetResult.elementAt(22) != null) 
		strSYTerm = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))] + ", "+strSYTerm;

%>
<br><br>
<table border=0 cellspacing=0 cellpadding=0 width="100%">
	<tr>
		<td valign="top" width="70%">
			<table border=0 cellspacing=0 cellpadding=0 width="100%">
				<tr><td colspan="3" height="30">&nbsp;</td></tr>
				
				<tr><td colspan="3" style="padding-left:80px;">
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
					  <%=WI.getStrValue(strTemp)%>
					  
					  &nbsp;<%=strStudID%> <%=strCourse%> <%=WI.getStrValue((String)vRetResult.elementAt(21))%>
				</td></tr>
				<tr><td colspan="3">&nbsp;</td></tr>
				
				<tr><td height="20" colspan="3" style="padding-left:60px;">
					<%=strStudName%></td></tr>
				<tr>
					<td width="29%" height="20" style="padding-left:40px;">&nbsp;<!-- for TIN--></td>
				   <td colspan="2">&nbsp;<!-- for 1st line address--></td>
				</tr>
				<tr><td height="20" colspan="3">&nbsp;<!-- for 2nd line address--></td></tr>
				<tr>
					<td height="30">&nbsp;<!-- for TIN--></td>
				   <td colspan="2" style="padding-left:60px;">&nbsp;<!-- for business style--></td>
				</tr>
				<tr><td height="20" colspan="3" style="padding-left:20px;"><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%></td></tr>
				<tr>
					<td height="20"><%=CommonUtil.formatFloat(strAmount,true)%></td>
					<td width="17%">&nbsp;</td>
				   <td width="54%"><%=strPaymentFor%></td>
				</tr>
				<tr><td height="20" colspan="3" valign="top">
					<table border=0 cellspacing=0 cellpadding=0 width="100%">
						<tr>
							<%
							strTemp = "";
							if(vRetResult.elementAt(14) == null || dCashAmt > 0d)
								strTemp = "<strong>X</strong>";								
							%>
							<td width="15%" align="right"><%=strTemp%>&nbsp;</td>
							<%
							strTemp = "";
							if(dChkAmt > 0)
								strTemp = "<strong>X</strong>";								
							%>
							<td width="9%" align="right"><%=strTemp%>&nbsp;</td>
							<td width="15%" align="right">&nbsp;</td>
							<td width="21%"><%=WI.getStrValue(strCheckNo)%>&nbsp;</td>
							<td width="15%" align="right">&nbsp;</td>
							<td width="25%" align="right">&nbsp;</td>							
						</tr>
					</table>
				</td></tr>
			</table>
		</td>
		
		
		<td valign="top">
			<table border=0 cellspacing=0 cellpadding=0 width="100%">
				<tr><td height="20" style="padding-left:150px;">&nbsp;</td></tr>
				<tr><td height="20" style="padding-left:150px;">&nbsp;<%=strDatePaid%></td></tr>
				<tr><td height="20" style="padding-left:150px;">&nbsp;<%=request.getParameter("or_number")%></td></tr>
			
				<tr><td height="10"></td></tr>
				
				<tr><td height="22" style="padding-left:150px;">&nbsp;<%if(dPrevBalance > 0d) {%><%=CommonUtil.formatFloat(dPrevBalance, true)%><%}%></td></tr>
				<tr><td height="22" style="padding-left:150px;">&nbsp;<%if(dAssessment > 0d) {%><%=CommonUtil.formatFloat(dAssessment, true)%><%}%></td></tr>
				<tr><td height="22" style="padding-left:150px;">&nbsp;<%if(dTotalDiscount > 0d) {%><%=CommonUtil.formatFloat(dTotalDiscount, true)%><%}%></td></tr>
				<tr><td height="22" style="padding-left:150px;">&nbsp;<%if(dPrevPayment > 0d) {%><%=CommonUtil.formatFloat(dPrevPayment, true)%><%}%></td></tr>
				<tr><td height="22" style="padding-left:150px;">&nbsp;<%=CommonUtil.formatFloat(strAmount,true)%></td></tr>					
				<tr><td height="22" style="padding-left:150px;">&nbsp;<%if(bolIsTuitionPmt){%><%=CommonUtil.formatFloat(dOutStandingBalance, true)%><%}%></td></tr>
				<tr><td height="22" style="padding-left:100px;">&nbsp;<%=CommonUtil.formatFloat(dOutStandingBalance, true)%></td></tr>
			</table>
		</td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td height="30" valign="bottom" style="padding-left:20px;"><%=WI.getStrValue(strTellerName)%></td>
	</tr>
	
</table>

<!--
<br><br><br><br><br><br><br><br>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr valign="top">
		  <td width="82%" height="50" align="left">&nbsp;</td>
		  <td width="18%" valign="top" align="left"><%=strDatePaid%> <br><%=request.getParameter("or_number")%></td>
	  </tr>
	</table>
	<br>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr valign="top">
		  <td width="64%">
		  		<table width="100%" cellpadding="0" cellspacing="0" border="0">
					<tr>
						<td height="35">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<%=strStudName%>
						<%if(strStudID.length() > 0) {%>
							<br>SN: <%=strStudID%> 
							<%=strCourse%> <%=WI.getStrValue((String)vRetResult.elementAt(21))%>
							<br>SY/Term: <%=strSYTerm%>
						<%}%>
						</td>
					</tr>
					<tr>
						<td height="65" valign="top">
							<table width="100%" cellpadding="0" cellspacing="0">
								<tr>
								  	<td width="10%" height="26">&nbsp;</td>
									<td width="32%">&nbsp;&nbsp;
									<%=CommonUtil.formatFloat(strAmount, true)%></td>
									<td width="58%">&nbsp;</td>
								</tr>
								<tr>
								  <td>&nbsp;</td>
								  <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%if(dCashAmt > 0d) {%>X<%}%></td>
								  <td></td>
							  	</tr>
								<tr>
								  <td>&nbsp;</td>
								  <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%if(dChkAmt > 0d) {%>X<%}%></td>
								  <td><%if(dChkAmt > 0d) {%><%=WI.getStrValue(strBankName)%> <%=WI.getStrValue(strCheckNo)%><%}%></td>
							  	</tr>
								<tr>
								  <td>&nbsp;</td>
								  <td>&nbsp;</td>
								  <td>&nbsp;</td>
							  	</tr>
								<tr>
								  <td>&nbsp;</td>
								  <td>&nbsp;</td>
								  <td>&nbsp;</td>
							  	</tr>
								<tr>
								  <td>&nbsp;</td>
								  <td><%=strPaymentFor%></td>
								  <td>&nbsp;</td>
							  </tr>
								<tr>
								  <td>&nbsp;</td>
								  <td>&nbsp;</td>
								  <td>&nbsp;</td>
							  </tr>
								<tr>
								<td>&nbsp;</td>
								  <td colspan="2">
								  		  <%if(bolIsTuitionPmt){
											if(bolIsOkForExam) {%>
												<font size="4">OK to take <%=((String)vRetResult.elementAt(28)).toUpperCase()%></font>
											<%}
											}%>

								  
								  </td>
							  </tr>
							</table>
						
						
						
						</td>
					</tr>
				</table>
		  </td>
		  <td width="18%">&nbsp;
		  
		  </td>
		  <td width="18%">
		  <table width="100%" cellpadding="0" cellspacing="0">
            <tr>
              <td width="2%" height='18'>&nbsp;</td>
              <td width="98%">&nbsp;</td>
            </tr>
            
            <tr>
              <td height='16'>&nbsp;</td>
              <td><%if(dPrevBalance > 0d) {%><%=CommonUtil.formatFloat(dPrevBalance, true)%><%}%></td>
            </tr>
            <tr>
              <td height='16'>&nbsp;</td>
              <td><%if(dAssessment > 0d) {%><%=CommonUtil.formatFloat(dAssessment, true)%><%}%></td>
            </tr>
            <tr>
              <td height='16'>&nbsp;</td>
              <td><%if(dTotalDiscount > 0d) {%><%=CommonUtil.formatFloat(dTotalDiscount, true)%><%}%></td>
            </tr>
            <tr>
              <td height='16'>&nbsp;</td>
              <td><%if(dPrevPayment > 0d) {%><%=CommonUtil.formatFloat(dPrevPayment, true)%><%}%></td>
            </tr>
            <tr>
              <td height='16'>&nbsp;</td>
              <td><%=CommonUtil.formatFloat(strAmount, true)%></td>
            </tr>
            <tr>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
            </tr>
            <tr>
              <td height='16'>&nbsp;</td>
              <td colspan=2><%if(bolIsTuitionPmt){%><%=CommonUtil.formatFloat(dOutStandingBalance, true)%><%}%></td>
            </tr>
          </table>		  
          </td>
	  </tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="35%"></td>
			<td width="45%" align='center'>&nbsp;&nbsp;<%=WI.getStrValue(strTellerName)%></td>
			<td width="20%"></td>
		</tr>
	</table>-->
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
