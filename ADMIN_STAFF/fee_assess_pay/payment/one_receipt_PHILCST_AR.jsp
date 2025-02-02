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

String strPaymentFor = null; boolean bolIsSupplies = false;

enrollment.FAAssessment FA     = new enrollment.FAAssessment();
String strPmtSchName = null;
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

	if(WI.fillTextValue("payment_for_").length() > 0)
		strPaymentFor = WI.fillTextValue("payment_for_");
	else if(vRetResult.elementAt(33) != null) 
		strPaymentFor = (String)vRetResult.elementAt(33);
	else if( ((String)vRetResult.elementAt(4)).equals("0"))
		strPaymentFor = "AR SCHOOL FEES";
	else if(vRetResult.elementAt(5) != null)
		strPaymentFor = (String)vRetResult.elementAt(5);
	else{
		if(vRetResult.elementAt(42) != null)
			strPaymentFor = (String)vRetResult.elementAt(42);
		else if(vRetResult.elementAt(4).equals("10"))
			strPaymentFor = "Back Account";
    }
	
		strAmtTendered = (String)vRetResult.elementAt(48);
		strAmtChange   = (String)vRetResult.elementAt(49);

		if(strAmtTendered.equals("0.00"))
			strAmtTendered = CommonUtil.formatFloat((String)vRetResult.elementAt(11),true);

	
	//I have to find if this is for supplies.
	strTemp = "select SUPPLY_REF from FA_OTH_SCH_FEE_SUPPLIES where SUPPLY_FEE_NAME = '"+strPaymentFor+"'";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null)
		bolIsSupplies = true;
}

if(strErrMsg == null){
double dReceived = 0d;
double dChange   = 0d;

if(WI.fillTextValue("sukli").length() > 0) {
	strTemp = (String)vRetResult.elementAt(11);
	dChange =  Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""));
	dReceived = Double.parseDouble(strTemp) +dChange;
}
else
	dReceived = Double.parseDouble((String)vRetResult.elementAt(11));
%>
<!--
<table border="0" width="170" cellpadding="0" cellspacing="0">
	<tr>
		<td width="182" height="36">Date: <strong><%=WI.getStrValue(vRetResult.elementAt(15))%></strong></td>
	</tr>
	<tr>
		<td height="36">AR No: <strong><%=request.getParameter("or_number")%></td>
	</tr>
	<tr>
		<td height="25">Student ID:<br/><strong><%=vRetResult.elementAt(25)%></strong></td>
  	</tr>
	<tr>
		<td height="25">Student Name:<br/>
		<strong>
		<%
		//if user index is null, the student is ex-studetn, so display only name,
		if( vRetResult.elementAt(0) != null){%>
	  		<%=(String)vRetResult.elementAt(18)%>
		<%}else{%>
			  <%=(String)vRetResult.elementAt(1)%>
		<%}%>
		</strong>		</td>
  	</tr>
	<tr>
	  <td height="25">Course/Major:<strong>
	  <%=WI.getStrValue((String)vRetResult.elementAt(35),"")%>
	  </strong></td>
	</tr>
  	  <%if(vRetResult.elementAt(22) != null) {
	  	strTemp = (String)vRetResult.elementAt(23) +"-"+ ((String)vRetResult.elementAt(24));
		if(vRetResult.elementAt(22).equals("0"))
			strTemp = (String)vRetResult.elementAt(24);
	  %>
	<tr>
	  <td height="25">Year/Sem/SY:<br/>
	  <strong><%=WI.getStrValue((String)vRetResult.elementAt(21),"","","")%>/<%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>/<%=strTemp%>	  </td>
  </tr>
  <%}%>
	<tr>
	  <td height="31" align="center"><strong>:: PAYMENT DETAILS ::</strong></td>
  </tr>
	<tr>
	  <td height="25">Amount Paid:<br/>
	  <strong><%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%></strong></td>
  </tr>
  </tr>
	<tr>
	  <td height="25">Amount Received:<br/>
	  <strong><%=CommonUtil.formatFloat(dReceived,true)%></strong></td>
  </tr>
	<tr>
	  <td height="25">Change :<br/>
	  <strong><%=CommonUtil.formatFloat(dChange,true)%></strong></td>
  </tr>
	<tr>
	  <td height="46">Payment for: <strong>
	  <%if(WI.fillTextValue("payment_for_").length() > 0){%>
      <%=WI.fillTextValue("payment_for_")%>
      <%}else if(vRetResult.elementAt(33) != null) {%>
      <font size="1"><%=(String)vRetResult.elementAt(33)%></font>
      <%}else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0){%>
      <%if(false){%>Tuition(do not show)<%}%>AR SCHOOL FEES
      <%}else if(vRetResult.elementAt(5) != null){%>
      <%=(String)vRetResult.elementAt(5)%>
      <%}else{
		if(vRetResult.elementAt(42) != null)
		strTemp = (String)vRetResult.elementAt(42);
		else if(vRetResult.elementAt(4).equals("10"))
			strTemp = "Back Account";%>
			<%=strTemp%>
	  <%}%></strong></td>
  </tr>
	<tr>
	  <td height="45">Received by:<br/><%=(String)request.getSession(false).getAttribute("first_name")%></td>
  </tr>
	<tr>
	  <td height="25">Date and time printed:<br/><strong><%=WI.getTodaysDateTime()%></strong><br/>	  </td>
  </tr>
</table>
-->
<table border="0" width="170" cellpadding="0" cellspacing="0">
	<tr>
		<td width="182" height="36">Date: <strong><%=WI.getStrValue(vRetResult.elementAt(15))%></strong></td>
	</tr>
	<tr>
		<td height="36"><%if(bolIsSupplies){%>SR<%}else{%>AR<%}%> No: <strong><%=request.getParameter("or_number")%></td>
	</tr>
	<tr>
		<td height="25">Student ID:<br/><strong><%=vRetResult.elementAt(25)%></strong></td>
  	</tr>
	<tr>
		<td height="25">Student Name:<br/>
		<strong>
		<%
		//if user index is null, the student is ex-studetn, so display only name,
		if( vRetResult.elementAt(0) != null){%>
	  		<%=(String)vRetResult.elementAt(18)%>
		<%}else{%>
			  <%=(String)vRetResult.elementAt(1)%>
		<%}%>
		</strong>		</td>
  	</tr>
	<tr>
	  <td height="25">Course/Major:<strong>
	  <%=WI.getStrValue((String)vRetResult.elementAt(35),"")%>
	  </strong></td>
	</tr>
  	  <%if(vRetResult.elementAt(22) != null) {
			strTemp = (String)vRetResult.elementAt(23) +"-"+ ((String)vRetResult.elementAt(24));
			if(vRetResult.elementAt(22).equals("0"))
				strTemp = (String)vRetResult.elementAt(24);
	  %>
	<tr>
	  <td height="25">Year/Sem/SY:<br/>
	  <strong><%=WI.getStrValue((String)vRetResult.elementAt(21),"","","")%>/<%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>/<%=strTemp%>	  </td>
  </tr>
  <%}%>
	<tr>
	  <td height="31" align="center"><strong>:: PAYMENT DETAILS ::</strong></td>
  </tr>
	<tr>
	  <td height="25">Amount Paid:<br/>
	  <strong><%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%></strong></td>
  </tr>
  </tr>
	<tr>
	  <td height="25">Amount Received:<br/>
	  <strong><%=strAmtTendered%></strong></td>
  </tr>
	<tr>
	  <td height="25">Change :<br/>
	  <strong><%=strAmtChange%></strong></td>
  </tr>
<!-- amount tendered row
	<tr>
	  <td height="25">Amount Tendered:<br/><strong>
	 <%if(vRetResult.elementAt(14) == null){%>
		<%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
		<%}//show only if check.
				else if(dChkAmt > 0d){%>
		<%=CommonUtil.formatFloat(dCashAmt,true)%>
	  <%}%></strong></td>
  </tr>
  <tr>
	  <td height="25">Change:<br/>
	  <%=WI.fillTextValue("sukli")%>
	  </td>
  </tr>
-->  
	<tr>
	  <td height="46">Payment for: <strong>
	  <%if(WI.fillTextValue("payment_for_").length() > 0){%>
      <%=WI.fillTextValue("payment_for_")%>
      <%}else if(vRetResult.elementAt(33) != null) {%>
      <font size="1"><%=(String)vRetResult.elementAt(33)%></font>
      <%}else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0){%>
      <%if(false){%>Tuition(do not show)<%}%>AR SCHOOL FEES
      <%}else if(vRetResult.elementAt(5) != null){%>
      <%=(String)vRetResult.elementAt(5)%>
      <%}else{
		if(vRetResult.elementAt(42) != null)
		strTemp = (String)vRetResult.elementAt(42);
		else if(vRetResult.elementAt(4).equals("10"))
			strTemp = "Back Account";%>
			<%=strTemp%>
	  <%}%></strong></td>
  </tr>
	<tr>
	  <td height="45">Received by:<br/><%=(String)request.getSession(false).getAttribute("first_name")%></td>
  </tr>
	<tr>
	  <td height="25">Date and time printed:<br/><strong><%=WI.getTodaysDateTime()%></strong><br/>	  </td>
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
