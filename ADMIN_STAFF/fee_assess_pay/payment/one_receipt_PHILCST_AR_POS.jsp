<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>One Receipt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
-->
</style>
</head>

<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean bolIsFine = false;
	boolean bolIsDownPmt =false;


//add security here.
	try {
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
boolean bolShowLabel = false;//for actual, set it to false;

double dChkAmt = 0d; double dCashAmt = 0;
FAPayment faPayment = new FAPayment();

enrollment.FAAssessment FA     = new enrollment.FAAssessment();
String strPmtSchName = null;
boolean bolIsOkForExam = false;
String[] astrConvertSem = {"Summer","1<sup>st</sup> SEM","2<sup>nd</sup> SEM"};

String strAmtTendered = null;
String strAmtChange   = null;


Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));//System.out.println(vRetResult);
if(vRetResult == null)
	strErrMsg = faPayment.getErrMsg();
else {
	//dChkAmt = Double.parseDouble((String)viewPmtDetail);
	dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));

	//to know if it is ok for prelim/mterm / finals.
	strPmtSchName = (String)vRetResult.elementAt(28);
	if(strPmtSchName != null && vRetResult.elementAt(0) != null) {
		Vector vInstallmentInfo = FA.getPaymentDueForAnExam(dbOP, (String)vRetResult.elementAt(0),
								  (String)vRetResult.elementAt(23), (String)vRetResult.elementAt(24), (String)vRetResult.elementAt(21), 
								  (String)vRetResult.elementAt(22), null, strPmtSchName);
		if(vInstallmentInfo != null && vInstallmentInfo.elementAt(1).equals("0"))
			bolIsOkForExam = true;
		//System.out.println(vInstallmentInfo);
	}
	
		strAmtTendered = (String)vRetResult.elementAt(48);
		strAmtChange   = (String)vRetResult.elementAt(49);

		if(strAmtTendered.equals("0.00"))
			strAmtTendered = CommonUtil.formatFloat((String)vRetResult.elementAt(11),true);

}
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

if(strErrMsg != null){%>
<%=strErrMsg%>
<%dbOP.cleanUP();return;}

double dReceived = 0d;
double dChange   = 0d;

if(WI.fillTextValue("sukli").length() > 0) {
	strTemp = (String)vRetResult.elementAt(11);
	dChange =  Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""));
	dReceived = Double.parseDouble(strTemp) +dChange;
}
else
	dReceived = Double.parseDouble((String)vRetResult.elementAt(11));


String strStudentName = null;
if( vRetResult.elementAt(0) != null)
	strStudentName = (String)vRetResult.elementAt(18);
else	
	strStudentName = (String)vRetResult.elementAt(1);

String strPaymentFor = null;
if(WI.fillTextValue("payment_for_").length() > 0)
	strPaymentFor = WI.fillTextValue("payment_for_");
else if(vRetResult.elementAt(33) != null)
	strPaymentFor = (String)vRetResult.elementAt(33);
else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0)
    strPaymentFor = "AR SCHOOL FEES";
else if(vRetResult.elementAt(5) != null)
	strPaymentFor = (String)vRetResult.elementAt(5);
else{
	if(vRetResult.elementAt(42) != null)
		strPaymentFor = (String)vRetResult.elementAt(42);
	else if(vRetResult.elementAt(4).equals("10"))
		strPaymentFor = "Back Account";
}

%>

<pre>
Date: <%=WI.getStrValue(vRetResult.elementAt(15))%>

AR No: <%=request.getParameter("or_number")%>

Student ID:
<%=WI.getStrValue(vRetResult.elementAt(25))%>

Student Name: 
<%=WI.getStrValue(vRetResult.elementAt(18))%>

Course/Major: <%=WI.getStrValue((String)vRetResult.elementAt(35),"")%>

<%if(vRetResult.elementAt(22) != null) {
	strTemp = (String)vRetResult.elementAt(23) +"-"+ ((String)vRetResult.elementAt(24));
	if(vRetResult.elementAt(22).equals("0"))
		strTemp = (String)vRetResult.elementAt(24);
%>
Year/Sem/SY:
<%=WI.getStrValue((String)vRetResult.elementAt(21),"","","")%>/<%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>/<%=strTemp%>	
<%}%>
        :: PAYMENT DETAILS ::

Amount Paid:
<%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>

Amount Received:
<%=strAmtTendered%>

Change :
<%=strAmtChange%>

Payment for: <%=strPaymentFor%>

Received by:
<%=(String)request.getSession(false).getAttribute("first_name")%>

Date and time printed:
<%=WI.getTodaysDateTime()%>
</pre>
</body>

</html>
<%
dbOP.cleanUP();
%>
