<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>One Receipt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css" media="print" >
body {
	font-family: Verdana, Geneva, sans-serif;
	font-size: 11pt;
	margin:40px 0px 0px 300px;
	letter-spacing:5px;
}

td {
	font-family: Verdana, Geneva, sans-serif;
	font-size: 11pt;
	letter-spacing:5px;
}

th {
	font-family: Verdana, Geneva, sans-serif;
	font-size: 11pt;
	letter-spacing:5px;
}
</style>
</head>

<body  onLoad="window.print();">
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
	strDatePaid   = WI.getStrValue(vRetResult.elementAt(15));
	
	///I have to update to tuition type paymetn and pmt_sch_index = 1 if other school fee name is Integrated Seminar or RLE Fee.
	//update FA_STUD_PAYMENT set PAYMENT_FOR = 0, PMT_SCH_INDEX = 2 where OR_NUMBER = 'A0015782'
	//conditions are if student Id length() > 0 && other school fee and othsch fee name length() > 1 and if rle fee or integrated seminar
		if(WI.getStrValue((String)vRetResult.elementAt(25),"").length() > 0 && WI.getStrValue((String)vRetResult.elementAt(5),"").length() > 0 && 
			(WI.getStrValue((String)vRetResult.elementAt(5),"").toLowerCase().equals("rle fee") || WI.getStrValue((String)vRetResult.elementAt(5),"").toLowerCase().equals("integrated seminar")) ){
			if(!((String)vRetResult.elementAt(4)).equals("0")) {
				String strSQLQuery = ConversionTable.convertTOSQLDateFormat(strDatePaid);
				strSQLQuery = "select pmt_sch_index from FA_PMT_SCHEDULE_EXTN where SY_FROM = "+(String)vRetResult.elementAt(23)+
								" and SEMESTER = "+(String)vRetResult.elementAt(22)+" and IS_VALID = 1 and EXAM_SCHEDULE >='"+strSQLQuery+
								"' order by EXAM_SCHEDULE asc";
				String strPmtSchIndex = dbOP.getResultOfAQuery(strSQLQuery, 0);
				if(strPmtSchIndex != null) {
					String strExamName = "select exam_name from FA_PMT_SCHEDULE where PMT_SCH_INDEX = "+strPmtSchIndex;
					strExamName = dbOP.getResultOfAQuery(strExamName, 0);
					
					strSQLQuery = "update FA_STUD_PAYMENT set PAYMENT_FOR = 0, PMT_SCH_INDEX = "+strPmtSchIndex+" where OR_NUMBER = '"+request.getParameter("or_number")+"'";
					dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
					
					//now update the fields..
					vRetResult.setElementAt("0", 4);//set as tuition
					vRetResult.setElementAt(strPmtSchIndex, 27);//set as pmt sch index
					//vRetResult.setElementAt(strExamName, 28);//set as pmt sch name
					vRetResult.setElementAt(vRetResult.elementAt(5), 28);//set as Fee name.
				}
			}
			else {//already set to d/p.. so just set the fee name.. 
				vRetResult.setElementAt(vRetResult.elementAt(5), 28);//set as Fee name.
			}
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
			bolIsTuitionPmt = true;
			dOutStandingBalance= new enrollment.FAFeeOperation().calOutStandingOfPrevYearSem(dbOP, (String)vRetResult.elementAt(0), true, true);
			
			if(vRetResult.elementAt(27).equals("0"))
				strPaymentFor = "Downpayment";
			else {//do not consider OK for permit for d/p.. 
				strPaymentFor = (String)vRetResult.elementAt(28);
				if(dOutStandingBalance < 1d) 
					bolIsOkForExam = true;
				else if(!vRetResult.elementAt(27).equals("0")){	
					Vector vInstallmentDtls = FA.getInstallmentSchedulePerStudPerExamSch(dbOP,(String)vRetResult.elementAt(27), (String)vRetResult.elementAt(0),
												(String)vRetResult.elementAt(23),(String)vRetResult.elementAt(24),(String)vRetResult.elementAt(21), (String)vRetResult.elementAt(22)) ;
					if(vInstallmentDtls != null) {
						double dDueForThisPeriod = Double.parseDouble((String)vInstallmentDtls.elementAt(5));
						if(((String)vInstallmentDtls.elementAt(1)).toLowerCase().startsWith("final")) {
							if(dDueForThisPeriod < 1d)
								bolIsOkForExam = true;
						}
						else if(dDueForThisPeriod < 500d)
							bolIsOkForExam = true;
					}
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
		

		strAmtTendered = (String)vRetResult.elementAt(48);
		strAmtChange   = (String)vRetResult.elementAt(49);
		if(strAmtTendered.equals("0.00"))
			strAmtTendered = CommonUtil.formatFloat(strAmount,true);

}

String[] astrConvertSem = {"Summer","1st Sem.","2nd Sem.",""};

if(strErrMsg == null){


	if(vRetResult.elementAt(22) != null) {
		strTemp = (String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24)).substring(2);
		if(vRetResult.elementAt(22).equals("0"))
			strTemp = (String)vRetResult.elementAt(24);
	}
	if(!bolIsBasic && vRetResult.elementAt(22) != null) 
		strTemp = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))] + ", "+strTemp;
%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr valign="top">
		  <td width="43%" height="60" align="left">&nbsp;</td>
		  <td width="57%" align="left" valign="bottom">
		  <div style="padding:0px 0px 0px 0px; ">
		  <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>, <%=(String)vRetResult.elementAt(23) +"-"+ ((String)vRetResult.elementAt(24))%>
		  </div>
		  </td>
	  </tr>
		<tr valign="top" height="20">
		  <td valign="bottom"  align="left"><div style="padding:0px 0px 0px 30px"><%=request.getParameter("or_number")%></div></td>
		  <td valign="bottom"  align="left"><%=strDatePaid%> <%=vRetResult.elementAt(52)%></td>
	  </tr>
		<tr valign="top">
		  <td>&nbsp;
		  </td>
		  <td>
		  <%if(strStudID.length() > 0) {%><%=strStudID%> <%=strCourse%> <%=WI.getStrValue((String)vRetResult.elementAt(21))%>
		  <%}else{%>
		  	&nbsp;
		  <%}%>
		  
		  </td>
      </tr>
	<!--	<tr valign="top">
		  <td colspan="2">&nbsp;</td>
	  </tr>
      -->
		<tr valign="top">
		  <td colspan="2"><div style="padding:0px 0px 0px 120px"><%=strStudName%></div>
          <br></td>
	  </tr>
		<tr valign="top" height="12">
		  <td colspan="2" align="center">&nbsp;</td>
		</tr>
		<tr valign="bottom">
		  <td height="58" colspan="2" valign="top">
		  <div style="padding:0px 0px 0px 120px">
		  <%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%>
		  <br>
		  (<%=CommonUtil.formatFloat(strAmount, true)%>)
		  </div>
		  </td>
		</tr>
		<tr valign="top">
		  <td colspan="2">
		  <div style="padding:0px 0px 0px 120px">
		  <%if(bolIsTuitionPmt && strPaymentFor != null && !strPaymentFor.equals("Downpayment")){%>
          Current Outstanding Balance: <%=CommonUtil.formatFloat(dOutStandingBalance, true)%><%}%>&nbsp;
		  </div>
		  </td>
	  </tr>
		<tr valign="bottom">
		  <td colspan="2">
		  <div style="padding:0px 0px 0px 120px">
		  <%=strPaymentFor%>
		  <%if(bolIsTuitionPmt){
		  	if(bolIsOkForExam) {%>
				-> VALID AS PERMIT
			<%}
			}%>
		</div>  
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
