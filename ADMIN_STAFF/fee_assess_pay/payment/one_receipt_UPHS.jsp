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

<body leftmargin="30" topmargin="0" bottommargin="0" onLoad="window.print();">
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

double dChkAmt = 0d; 
double dCashAmt = 0d;



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
		
		dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
		dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));
	}
	else
		strErrMsg = faPayment.getErrMsg();

}
else {//not basic payment.
	//System.out.println(vRetResult);
	
		dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
		dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));
		
		if(!vRetResult.elementAt(45).equals("0")) {
			dChkAmt = dCashAmt;
			dCashAmt = 0d;
		}
		
		strStudID     = WI.getStrValue((String)vRetResult.elementAt(25),"External Pmt");
		//name
		if( vRetResult.elementAt(0) != null)
			strStudName     = (String)vRetResult.elementAt(18);
		else
			strStudName     = (String)vRetResult.elementAt(1);

		strCourse     = WI.getStrValue((String)vRetResult.elementAt(35),"");
		if(strCourse.length() == 0 && vRetResult.elementAt(21) != null) {//basic student.
			int iYear = Integer.parseInt((String)vRetResult.elementAt(21));
			strCourse = dbOP.getBasicEducationLevel(iYear);
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
}

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

String[] astrConvertSem = {"S", "1ST", "2ND", "3RD", ""};

if(strErrMsg == null){%>

<table border="0" cellpadding="0" cellspacing="0" width="600">
	<tr>
		<td width="220" valign="top">
			<table border="0" cellpadding="0" cellspacing="0" width="220">
				<tr>
					<td align="center"><% if(vRetResult.elementAt(22) != null){
					  strTemp = (String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24)).substring(2);
					  if(vRetResult.elementAt(22).equals("0"))
						strTemp = (String)vRetResult.elementAt(24);
					  %>
						<%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%> &nbsp; <%=strTemp%>
					  <%}%>
				  	</td>
				  </tr>
				<tr><td height="50">&nbsp;</td></tr>
				<tr><td><%=strPaymentFor%></td></tr>
				<tr><td height="150" valign="top">&nbsp;</td></tr>
				<tr><td align="right">&nbsp;<%=CommonUtil.formatFloat(strAmount,true)%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr>
			</table>		
		</td>
		
		
		<!------------------------RIGHT SIDE----------------------------->
		<td valign="top" width="380">
			<br><br><br>
			<table border="0" cellpadding="0" cellspacing="0" width="380">
				
				<tr>
					<td height="50">&nbsp;</td>
					<td height="50">&nbsp; <%=WI.fillTextValue("or_number")%></td>
				</tr>
				<tr>
					<td>&nbsp;&nbsp;&nbsp;&nbsp; <%=strCourse%></td>
					<td>&nbsp; <%=(String)vRetResult.elementAt(21)%></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td align="center"><%=WI.getTodaysDate(1)%></td>
				</tr>
				<tr><td align="right" height="60px" valign="middle"><%=strStudName%></td></tr>
				<tr><td colspan="2" height="40" valign="middle"><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%></td></tr>
				<tr><td height="40">&nbsp;</td><td align="center">&nbsp; <%=CommonUtil.formatFloat(strAmount,true)%></td></tr>
				
				
				<tr>
					<td height="40" align="right">&nbsp;</td>
					<td>&nbsp;<%=request.getSession(false).getAttribute("first_name")%></td>
				</tr>
				<tr><td colspan="2" height="40">
					<%if(vRetResult.elementAt(14) == null){%>
				&nbsp;CASH: <%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
			  <%}//show only if check.
				else {//it can be check only or cash and check
					if(dCashAmt > 0d){%>
						&nbsp;CASH: <%=CommonUtil.formatFloat(dCashAmt,true)%>&nbsp;&nbsp;
					<%}%>
					&nbsp;CHECK: <%=CommonUtil.formatFloat(dChkAmt,true)%>
				<%}%>					
				</td></tr>
				
				
				
			</table>	
		
		
		</td>
	</tr>
</table>


<!--

<table border="0" cellpadding="0" cellspacing="0" width=456>
	<tr>
		<td width=118 height="22">&nbsp;</td>
		<td colspan="3"><%=strStudName%></td>
	</tr>
	<tr>
	  <td height="22">&nbsp;</td>
	  <td width=178><%=strStudID%></td>
	  <td width="68">&nbsp;</td>
	  <td width="92"><%=strCourse%></td>
  </tr>
	<tr>
	  <td height="22">&nbsp;</td>
	  <td><%=request.getParameter("or_number")%></td>
	  <td>&nbsp;</td>
	  <td><%=strDatePaid%></td>
  </tr>
	<tr>
	  <td height="22">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(23))%></td>
	  <td align="right"><%=astrConvertSem[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(22), "4"))]%>&nbsp;</td>
  </tr>
	<tr>
	  <td height="22">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="22">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="22">&nbsp;</td>
	  <td><%=strPaymentFor%></td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="22">&nbsp;</td>
	  <td><%=WI.getStrValue(strBankName)%><%=WI.getStrValue(strCheckNo, "(", ")", "")%></td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="22">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="22">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="22">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
  <tr>
	  <td height="22">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td><%=CommonUtil.formatFloat(strAmount,true)%></td>
	  <td>&nbsp;</td>
  </tr>
</table>
-->

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
