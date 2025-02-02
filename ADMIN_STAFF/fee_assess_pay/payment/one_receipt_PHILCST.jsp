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

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
-->
</style>
</head>

<body onLoad="window.print();" topmargin="0">
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

double dChkAmt = 0d; double dCashAmt = 0;
FAPayment faPayment = new FAPayment();

enrollment.FAAssessment FA     = new enrollment.FAAssessment();
String strPmtSchName = null;
boolean bolIsOkForExam = false;

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

boolean bolIsBasic = false;

		String strAmtTendered = null;
		String strAmtChange   = null;


Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));//System.out.println(vRetResult);
if(vRetResult == null)
		strErrMsg = faPayment.getErrMsg();
else {//not basic payment.
		strStudID     = WI.getStrValue((String)vRetResult.elementAt(25),"External Pmt");
		//name
		if( vRetResult.elementAt(0) != null)
			strStudName     = (String)vRetResult.elementAt(18);
		else
			strStudName     = (String)vRetResult.elementAt(1);

		if(vRetResult.elementAt(35) != null)
			strCourse = WI.getStrValue((String)vRetResult.elementAt(35),"")+ WI.getStrValue((String)vRetResult.elementAt(21)," - ","","");
		else if(vRetResult.elementAt(21) != null) {//may be basic.. 	
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
			strPaymentFor = "Tuition";
			//I have to find if this is for any isntallment.. 
			//if(vRetResult.elementAt(42) != null)
			//	strPaymentFor = "Tuition ("+(String)vRetResult.elementAt(42)+"
			if(bolIsBasic) {
				if(vRetResult.elementAt(27).equals("0"))
					strPaymentFor += " - Downpayment";
				//else	
				//	strPaymentFor += " - "+(String)vRetResult.elementAt(27);
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



}
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

String[] astrConvertSem = {"Summer","1st Sem","2nd Sem", "3rd Sem"};
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(35) == null)
	astrConvertSem[1] = "Regular";
	
//System.out.println(vRetResult);
if(strErrMsg == null){
double dReceived = 0d;
double dChange   = 0d;

if(WI.fillTextValue("sukli").length() > 0) {
	strTemp = (String)vRetResult.elementAt(11);
	dChange =  Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"), ",",""));
	dReceived = Double.parseDouble(strTemp) +dChange;
}
else
	dReceived = Double.parseDouble((String)vRetResult.elementAt(11));

%>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr align="center" style="font-weight:bold">
	  <td colspan="5" style="font-size:13px">ACKNOWLEDGEMENT RECEIPT</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
		<td width="10%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
		<td width="44%">AR <%=request.getParameter("or_number")%><!--OR Number--></td>
		<td width="17%">&nbsp;</td>
		<td width="24%"><%=WI.getStrValue(vRetResult.elementAt(15))%><!--Date/--></td>
	</tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td><%=strStudID%><!-- student ID --></td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td><%=strStudName%></td>
	  <td>&nbsp;</td>
	  <td><%=WI.getStrValue(strCourse)%></td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td><br><br>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td><%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%></td>
	  <td>&nbsp;</td>
	  <td>Rcvd : <%=strAmtTendered%></td>
  </tr>
	<tr>
	  <td colspan="4"><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vRetResult.elementAt(11)),"Pesos","Centavos")%></td>
      <td>Chng : <%=strAmtChange%></td>
  </tr>
	<tr>
	  <td colspan="5">&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td colspan="3"><%=strPaymentFor%></td>
	</tr>
	<tr>
	  <td colspan="5">
	  	<%if(vRetResult.elementAt(22) != null){%>
		<%=(String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24))%>/ <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>
		<%
		//I have to check for full or partial payment. 
		strTemp = (String)vRetResult.elementAt(47);
		if(strTemp == null)
			strTemp = "";

		if(strTemp.equals("1"))
			strTemp = "Partial Payment";
		else	
			strTemp = "Full Payment";
		%>
		<%}%>
		<%=WI.getStrValue((String)vRetResult.elementAt(28), "-", "","")%> - <%=strTemp%>	  </td>
  </tr>
	<tr>
	  <td colspan="5" align="right"><%if(!bolIsBasic){%>Received By :<%}%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
	<tr>
	  <td colspan="5" align="right"><%=request.getSession(false).getAttribute("first_name")%></td>
  </tr>
</table>

<br><br><br><br><br><br><br><br><br>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr align="center" style="font-weight:bold">
	  <td colspan="5" style="font-size:13px">ACKNOWLEDGEMENT RECEIPT</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
		<td width="10%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
		<td width="44%">AR <%=request.getParameter("or_number")%><!--OR Number--></td>
		<td width="17%">&nbsp;</td>
		<td width="24%"><%=WI.getStrValue(vRetResult.elementAt(15))%><!--Date/--></td>
	</tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td><%=strStudID%><!-- student ID --></td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td><%=strStudName%></td>
	  <td>&nbsp;</td>
	  <td><%=WI.getStrValue(strCourse)%></td>
  </tr>
	<tr>
	  <td><br><br>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td><%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%></td>
	  <td>&nbsp;</td>
	  <td>Rcvd : <%=strAmtTendered%></td>
  </tr>
	<tr>
	  <td colspan="4"><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vRetResult.elementAt(11)),"Pesos","Centavos")%></td>
      <td>Chng : <%=strAmtChange%></td>
  </tr>
	<tr>
	  <td colspan="5">&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td colspan="3"><%=strPaymentFor%></td>
	</tr>
	<tr>
	  <td colspan="5">
	  	<%if(vRetResult.elementAt(22) != null){%>
		<%=(String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24))%>/ <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>
		<%
		//I have to check for full or partial payment. 
		strTemp = (String)vRetResult.elementAt(47);
		if(strTemp == null)
			strTemp = "";

		if(strTemp.equals("1"))
			strTemp = "Partial Payment";
		else	
			strTemp = "Full Payment";
		%>
		<%}%>
		<%=WI.getStrValue((String)vRetResult.elementAt(28), "-", "","")%> - <%=strTemp%>	  </td>
  </tr>
	<tr>
	  <td colspan="5" align="right"><%if(!bolIsBasic){%>Received By :<%}%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
	<tr>
	  <td colspan="5" align="right"><%=request.getSession(false).getAttribute("first_name")%></td>
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
