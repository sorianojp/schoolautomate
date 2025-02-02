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

<body topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" onLoad="window.print();">
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

boolean bolIsBasic   = false; String strYrLevel = null;

String strSYTermInfo = null;
String[] astrConvertSem = {"SU","FS","SS"};
double dChkAmt = 0d; double dCashAmt = 0;

String strAmtTendered = null;
String strAmtChange   = null;


FAPayment faPayment = new FAPayment();
Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));//System.out.println(vRetResult);
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
	}
	else
		strErrMsg = faPayment.getErrMsg();

}
else {//not basic payment.
		//get sy/term of payment.. 
		if(vRetResult.elementAt(22) != null){
				strSYTermInfo = (String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24)).substring(2);
				//if(vRetResult.elementAt(22).equals("0"))
				//	strSYTermInfo = (String)vRetResult.elementAt(24);
				strSYTermInfo = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]+", "+ strSYTermInfo;
		}

		strStudID     = WI.getStrValue((String)vRetResult.elementAt(25),"");
		//name
		if( vRetResult.elementAt(0) != null)
			strStudName     = (String)vRetResult.elementAt(18);
		else
			strStudName     = (String)vRetResult.elementAt(1);

		strCourse     = WI.getStrValue((String)vRetResult.elementAt(35),"");
		if(strCourse.length() == 0 && vRetResult.elementAt(21) != null) {//basic student.
			int iYear  = Integer.parseInt((String)vRetResult.elementAt(21));
			strCourse  = dbOP.getBasicEducationLevel(iYear);
			strCourse = strCourse.substring(strCourse.indexOf("-") + 1);
			bolIsBasic = true;
		}
		else {
			strYrLevel = (String)vRetResult.elementAt(21);
			if(strYrLevel != null)
				strCourse = strCourse + " - "+strYrLevel;
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
		else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0)
			strPaymentFor = "Tuition";
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
		
		dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
		dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));

		strAmtTendered = (String)vRetResult.elementAt(48);
		strAmtChange   = (String)vRetResult.elementAt(49);

		if(strAmtTendered.equals("0.00"))
			strAmtTendered = CommonUtil.formatFloat(strAmount,true);
}

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

if(strErrMsg == null){%>
<br>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td width="35%" height="25"><!--
		<%if(bolIsBasic){%>Basic Education<%}else if(strCourse != null && strCourse.length() > 0){%>College<%}%>-->
		<%=WI.getStrValue(strCourse)%>		</td>
		<td width="35%"><%=WI.formatDate(strDatePaid,6)%></td>
		<td width="30%"><%=request.getParameter("or_number")%></td>
	</tr>
	<tr>
	  <td height="25" colspan="2"><%=strStudName%><%=WI.getStrValue(strStudID,"(",")","")%>	  </td>
      <td height="25"><%=WI.getStrValue(strSYTermInfo)%></td>
  </tr>
	
	<tr>
	  <td colspan="2" height="25"><u><strong>Payment Detail</strong></u></td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td colspan="3"><%=strPaymentFor%></td>
  </tr>
	<tr>
	  <td colspan="3" height="25">Total Amount Paid: <%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%>
	  (<%=CommonUtil.formatFloat(strAmount,true)%>)</td>
  </tr>
	<tr>
	  <td colspan="2" height="18">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
<%
if(strPmtMode != null) {
	if(strPmtMode.indexOf("Cash") > -1 && strPmtMode.indexOf("Check") > -1)
		strPmtMode = " Cash and Check";
}%>
	<!--<tr>
	  <td colspan="2" height="25">Mode Of Payment : <%=strPmtMode%></td>
	  <td>&nbsp;</td>
  </tr>-->
<%
double dAmountTendered = Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""), "0")) + Double.parseDouble(ConversionTable.replaceString(strAmount, ",","")) ;
%>
	<tr>
	  <td colspan="2" height="18">Amount Tendered : <%=strAmtTendered%></td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td colspan="2" height="25">
<%
strTemp = null;
if(dChkAmt > 0d)
	strTemp = "Cash &nbsp;Payment : "+CommonUtil.formatFloat(dCashAmt,true);
else if(vRetResult.elementAt(14) == null)
	strTemp = "Cash &nbsp;Payment : "+CommonUtil.formatFloat((String)vRetResult.elementAt(11),true);

if(dChkAmt > 0d) {
	if(strTemp == null)
		strTemp = "";
	else	
		strTemp = strTemp + "<br>";
	strTemp += "Check Payment : "+CommonUtil.formatFloat(dChkAmt,true);
}
else if(vRetResult.elementAt(14) != null){
	if(strTemp == null)
		strTemp = "";
	else	
		strTemp = strTemp + "<br>";
	strTemp += "Check Payment : "+CommonUtil.formatFloat((String)vRetResult.elementAt(11),true);
}%>
	<%=strTemp%>	
	<%=WI.getStrValue((String)vRetResult.elementAt(34),"<br>","","")%>
	<%=WI.getStrValue((String)vRetResult.elementAt(14),"<br>Check #: ","","")%>	  </td>
	  <td valign="bottom" align="center"><u><%=request.getSession(false).getAttribute("first_name")%></u></td>
  </tr>
	<tr>
	  <td colspan="2" height="25" valign="bottom">Change : <%=strAmtChange%></td>
	  <td align="center" valign="top">Prepared By</td>
  </tr>
	<tr>
	  <td colspan="2">&nbsp;</td>
	  <td>Time : <%=WI.getTodaysDate(15)%></td>
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
