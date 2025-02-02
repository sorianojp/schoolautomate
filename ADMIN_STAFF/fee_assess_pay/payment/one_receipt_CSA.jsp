<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>One Receipt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
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
-->
</style>
</head>

<body leftmargin="70" rightmargin="0" topmargin="0" bottommargin="0" onLoad="window.print();">
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


FAPayment faPayment        = new FAPayment();
enrollment.FAAssessment FA = new enrollment.FAAssessment();
double dOutStandingBalance = 0d;
String strPmtSchName = null;
boolean bolIsOkForExam = false;

String strAmtTendered = null;
String strAmtChange   = null;

//check FP only if d/p is paid.. #9
boolean bolIsFP = false;//if full payment, show OK for Prelim and Midterm

Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));

if(vRetResult != null && vRetResult.elementAt(0) != null) {
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	//System.out.println(vRetResult.elementAt(0));
	dOutStandingBalance= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vRetResult.elementAt(0), true, true);

	strPmtSchName = (String)vRetResult.elementAt(28);
	
	//System.out.println(strPmtSchName);
	
	if(strPmtSchName != null && !strPmtSchName.equals("Multiple Payment") && !strPmtSchName.startsWith("Back"))  {
		if(strPmtSchName.toLowerCase().startsWith("final") || strPmtSchName.toLowerCase().startsWith("fourth")) {//no o/s balance allowed.
			if(dOutStandingBalance < 1d)
				bolIsOkForExam = true;
		}
		else {
			double dAmtDue  = 0d;//check amt due. if due is < 0d;, then ok for exam, else check 80% if paid.
			boolean bolBreak = false;
			Vector vInstallmentInfo = FA.getInstallmentSchedulePerStudAllInOneVersion2(dbOP, (String)vRetResult.elementAt(0),
									  (String)vRetResult.elementAt(23), (String)vRetResult.elementAt(24), (String)vRetResult.elementAt(21), 
									  (String)vRetResult.elementAt(22));//System.out.println(vInstallmentInfo);
			if(vInstallmentInfo != null) {				
				for(int i = 7; i < vInstallmentInfo.size()-1; i +=2) {			
					if(strPmtSchName.equals(vInstallmentInfo.elementAt(i))) {//consider only payment for the period.
						//bolBreak = true;
						dAmtDue += ((Double)vInstallmentInfo.elementAt(i + 1)).doubleValue();
						break;
					}
					//if(((Double)vInstallmentInfo.elementAt(i + 1)).doubleValue() < 0d)
						dAmtDue += ((Double)vInstallmentInfo.elementAt(i + 1)).doubleValue();
						
					//if(bolBreak)
				 		//break;  
				}
			}//System.out.println(dAmtDue);
			if(dAmtDue < 1d)
				bolIsOkForExam = true;
			else {
				//from this, i can get only the amt paid for a pmt schedule.. 
				vInstallmentInfo = FA.getInstallmentSchedulePerStudent(dbOP, (String)vRetResult.elementAt(0),
										  (String)vRetResult.elementAt(23), (String)vRetResult.elementAt(24), (String)vRetResult.elementAt(21), 
										  (String)vRetResult.elementAt(22));
				//System.out.println(vInstallmentInfo);
				//System.out.println("Amoutn Due : "+dAmtDue);
				//I have to find out how much paid and payment amount.. 
				double dAmtPaid = 0d;
				
		
				bolBreak = false;
				for(int i = 5; i < vInstallmentInfo.size()-1; i +=3) {			
					if(strPmtSchName.equals(vInstallmentInfo.elementAt(i)))
						bolBreak = true;
					 //dAmtPaid += ((Float)vInstallmentInfo.elementAt(i + 2)).doubleValue(); - removed cumulative :: as discussed with charity : 2011-09-03. It should get amt paid for that period only.. 	
					dAmtPaid = ((Float)vInstallmentInfo.elementAt(i + 2)).doubleValue();
					
					 if(bolBreak)
					 	break;
				}//end of for loop..
			 
			 	double dAmtPayableEightPercent = dAmtDue * 4d;//must pay more than that amt.
				if(dAmtPaid >= dAmtPayableEightPercent)
					bolIsOkForExam = true;
				//System.out.println("dAmtPayableEightPercent : "+dAmtPayableEightPercent);
				//System.out.println("dAmtPaid : "+dAmtPaid);
				//System.out.println("dAmtDue : "+dAmtDue);
			}
		}//end of else
	}//if(strPmtSchName != null)
}//if(vRetResult != null && vRetResult.elementAt(0) != null)

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

		strStudID     = WI.getStrValue((String)vRetResult.elementAt(25),"");
		//name
		if( vRetResult.elementAt(0) != null)
			strStudName     = (String)vRetResult.elementAt(18);
		else
			strStudName     = (String)vRetResult.elementAt(1);

		strCourse     = WI.getStrValue((String)vRetResult.elementAt(35),"");
		if(strCourse.length() > 0) {
			strTemp = "select c_code from college join course_offered on (course_offered.c_index = college.c_index) "+
				" where course_offered.is_valid = 1 and course_code = '"+strCourse+"'";
			strTemp = dbOP.getResultOfAQuery(strTemp, 0);
			if(strTemp != null)
				strCourse = strCourse+"/"+strTemp;
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
			strPaymentFor = "Tuition";
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

		//strAmtTendered = (String)vRetResult.elementAt(48);
		//strAmtChange   = (String)vRetResult.elementAt(49);

		//if(strAmtTendered.equals("0.00"))
			//strAmtTendered = CommonUtil.formatFloat(strAmount,true);
		
		//check here if D/p and full payment.. 
		if(vRetResult.elementAt(31).equals("1"))
			bolIsFP = true;
		else if(vRetResult.elementAt(27).equals("0") && vRetResult.elementAt(4).equals("0")) {
			String strSQLQuery = "select PAYMENT_MODE from fa_stud_pmtmethod where sy_from = "+ vRetResult.elementAt(23)+" and semester = "+vRetResult.elementAt(22)+
								" and is_stud_temp = 0 and user_index = "+vRetResult.elementAt(0)+" and is_valid = 1";
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null && strSQLQuery.equals("0"))
				bolIsFP = true;
		}
		
		if(strCourse.length() == 0 && vRetResult.elementAt(21) != null) {//basic student.
			int iYear = Integer.parseInt((String)vRetResult.elementAt(21));
			strCourse = dbOP.getBasicEducationLevel(iYear);
			bolIsFP = false;
		}
		
}

String[] astrConvertSem = {"Summer","1st","2nd", "3rd"};

if(strErrMsg == null){


%>
<br><br><br><br><br><br><br>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		
		<tr valign="top">
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td><%=strStudID%></td>
		  <td><% if(vRetResult.elementAt(22) != null){
		  strTemp = (String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24)).substring(2);
		  if(vRetResult.elementAt(22).equals("0"))
		  	strTemp = (String)vRetResult.elementAt(24);
		  %>
            <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>, <%=strTemp%>
          <%}%> 
         <%=WI.getStrValue(strCourse, "-","","")%> 
		  
		  </td>
	  </tr>
		<tr valign="top">
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="2"><%=strStudName%></td>
	  </tr>
		<tr valign="bottom">
		  <td height="18">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="2"><!---- print here address --></td>
	  </tr>
		<tr valign="bottom">
		  <td height="18">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="2"><!-- print here business --></td>
	  </tr>
		
		<tr valign="bottom">
		  <td height="18">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="2" style="font-weight:bold; font-size:15px;">&nbsp;&nbsp;&nbsp;&nbsp;EXACTLY <%=CommonUtil.formatFloat(strAmount, true)%> PESOS ONLY</td>
	    </tr>
		
		<tr valign="bottom">
		  <td height="18">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="2"><%=strPaymentFor%></td>
	  </tr>
    </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		<tr valign="bottom">
		  <td width="22%" height="18">&nbsp;</td>
		  <td width="27%">
		  <%if(vRetResult.elementAt(14) == null){%>
			CASH: <%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
		  <%}//show only if check.
		    else {//it can be check only or cash and check
				if(dCashAmt > 0d){%>
					CASH: <%=CommonUtil.formatFloat(dCashAmt,true)%>&nbsp;&nbsp;
				<%}%>
				CHECK: <%=CommonUtil.formatFloat(dChkAmt,true)%>
			<%}%>		  </td>
	      <td width="51%" style="font-size:14px; font-weight:bold">
		  <%if(bolIsFP){%>
		  		OK for Prelim and Midterm
		  
		  <%}else if(bolIsOkForExam) {
		  	//System.out.println(WI.fillTextValue("fp"));System.out.println(strPmtSchName);
		  	if(WI.fillTextValue("fp").length() > 0 && strPmtSchName.toUpperCase().equals("PRELIM"))
				strTemp = " and Midterm Only ";
			else	
				strTemp = "";%>
				OK for <%=strPmtSchName+strTemp%>
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
			<td class="thinborderBOTTOM" height="50">&nbsp;</td>
			<td valign="top" class="thinborderBOTTOM">&nbsp;</td>
		    <td valign="top" class="thinborderBOTTOM">
			<%strTemp =(String)request.getSession(false).getAttribute("first_name");
			if(strTemp == null)
				strTemp = "";
			else
				strTemp = strTemp.substring(strTemp.indexOf(",") + 1);
			%> 
			<%=strTemp%>
			&nbsp;&nbsp;&nbsp;<%=request.getParameter("or_number")%>
			<br>
			<br>
			<%=WI.getStrValue(vRetResult.elementAt(15))%>
			&nbsp;&nbsp; 
			<%if(vRetResult.elementAt(0) != null) {%>
				BALANCE: <%=CommonUtil.formatFloat(dOutStandingBalance, true)%>			
			<%}%>
			</td>
		</tr>
    </table> 
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
