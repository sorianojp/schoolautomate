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




FAPayment faPayment = new FAPayment();
Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));//System.out.println(vRetResult);
if(vRetResult == null) {
	strErrMsg = faPayment.getErrMsg();

}
else {//not basic payment.
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

if(strErrMsg == null){
if(strStudName != null && strStudName.length() > 20)
	strStudName = strStudName.substring(0, 20);


//check if paid for trust fund.. 
String strTrustFundOR = null;
String strTrustFundAmt = null;

if(vRetResult != null && vRetResult.size() > 0) {
	strTrustFundOR = "select or_number, amount from fa_stud_payment where parent_pmt_index = "+
					(String)vRetResult.elementAt(30);
	java.sql.ResultSet rs = dbOP.executeQuery(strTrustFundOR);
	if(rs.next()) {
		strTrustFundOR  = rs.getString(1);
		strTrustFundAmt = CommonUtil.formatFloat(rs.getDouble(2), true);
	}
	else	
		strTrustFundOR = null;
	rs.close();
}				

%>
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
<script language="javascript">
<%if(vRetResult != null && vRetResult.size() > 20 && vRetResult.elementAt(4).equals("0") && //tuition
	!vRetResult.elementAt(27).equals("-1") && !vRetResult.elementAt(27).equals("0")) {%>//having a payment sched.. 
	document.onkeydown = function (e) {
		var keyPress;
		
		if (typeof event !== 'undefined') {
			keyPress = event.keyCode;
		}
		else if (e) {
			keyPress = e.which;
		}
		
		if(keyPress == 113) {//F2 
			//call printing of admission slip.. \
			location = "../reports/charge_slip_print_control_number_ub.jsp?show_result=1&stud_id=<%=WI.getStrValue(strStudID)%>"+
						"&sy_from=<%=vRetResult.elementAt(23)%>&sy_to=<%=vRetResult.elementAt(24)%>&semester=<%=vRetResult.elementAt(22)%>&pmt_schedule=<%=vRetResult.elementAt(27)%>";
		}
		
	
	  return false;   // Prevents the default action
	};
<%}%>
</script>

<body leftmargin="10" topmargin="0" bottommargin="0" onLoad="window.print();">
<br><br><br><br><br><br><br><br><br>
<table border=0 cellspacing=0 cellpadding=0 width=100%>
 <tr>
    <td width="9%">&nbsp;<%if(false){%>ID No<%}%></td>
    <td width="27%">&nbsp;<%if(false){%>Name<%}%></td>
    <td width="22%">&nbsp;<%if(false){%>Course&amp;Yr<%}%></td>
    <td width="12%">&nbsp;<%if(false){%>Date<%}%></td>
    <td width="14%">&nbsp;<%if(false){%>Trans No.<%}%></td>
    <td width="16%">&nbsp;<%if(false){%>Amount &amp; Code<%}%></td>
 </tr>
 <tr>
   <td><%=strStudID%></td>
   <td><%=strStudName%></td>
   <td><%=strCourse%> <%=WI.getStrValue((String)vRetResult.elementAt(21), " - ", "","")%></td>
   <td><%=strDatePaid%></td>
   <td><%=WI.fillTextValue("or_number")%></td>
   <td><%=CommonUtil.formatFloat(strAmount,true)%></td>
 </tr>
<%if(strTrustFundOR != null) {%>
 <tr>
   <td><%=strStudID%></td>
   <td><%=strStudName%></td>
   <td><%=strCourse%> <%=WI.getStrValue((String)vRetResult.elementAt(21), " - ", "","")%></td>
   <td><%=strDatePaid%></td>
   <td><%=strTrustFundOR%></td>
   <td><%=strTrustFundAmt%></td>
 </tr>
<%}%>
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
