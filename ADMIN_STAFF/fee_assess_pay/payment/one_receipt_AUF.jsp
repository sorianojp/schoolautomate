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

if(strErrMsg == null){%>
<br><br><br>
<table border=0 cellspacing=0 cellpadding=0 width=456>
  <tr>
    <td width=151 colspan=2 valign=top><%if(bolShowLabel){%>STUDENT NO.<%}%><br>
      &nbsp;<%//=WI.getStrValue((String)vRetResult.elementAt(25),"External Pmt")%><%=strStudID%></td>
    <td width=145 colspan=2 valign=top>
      <%if(bolShowLabel){%>
      DATE
      <%}%>
      <br>
      <%//=WI.getStrValue(vRetResult.elementAt(15))%><%=strDatePaid%></td>
    <td width=160 valign=top style='height:.5in'>
      <%if(bolShowLabel){%>
      O.R.
      <%}%>
      <br><br>
      <%=request.getParameter("or_number")%></td>
 </tr>
 <tr>
    <td colspan=5 valign=top style='height:35.0pt'>
      <%if(bolShowLabel){%>
      NAME<%}%><br>
      <%
//if user index is null, the student is ex-studetn, so display only name,
if( vRetResult.elementAt(0) != null){%> <%//=(String)vRetResult.elementAt(18)%> <%}else{%> <%//=(String)vRetResult.elementAt(1)%> <%}%>
<%=strStudName%>
</td>
 </tr>
 <tr>
    <td colspan=2 valign=top style='height:35.5pt'>
      <%if(bolShowLabel){%>
      COURSE
      <%}%>
      <br>
      <%//=WI.getStrValue((String)vRetResult.elementAt(35),"")%><%=strCourse%></td>
    <td colspan=2 valign=top><br>
	<%if(false && ((String)vRetResult.elementAt(29)).compareTo("0") == 0) {%>
	Old Student
	<%}else if(false){%>
	New Student
	<%}%><%=strStudStatus%>
	</td>
    <td valign=top>
      <%if(bolShowLabel){%>
      AMOUNT
      <%}%>
      <br>
      <%//=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%><%=CommonUtil.formatFloat(strAmount,true)%></td>
 </tr>
 <tr>
    <td colspan=5 valign=top style='height:71.0pt'>
      <%if(bolShowLabel){%>
      AMOUNT IN WORDS
      <%}//System.out.println(vRetResult.elementAt(11));System.out.println("Printing.."+Float.parseFloat((String)vRetResult.elementAt(11)));%>
      <br>
      <%//=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vRetResult.elementAt(11)),"Pesos","Centavos")%>
      <%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%></td>
 </tr>
 <tr>
    <td width=223 colspan=3 valign=top style='height:35.5pt'>
      <%if(bolShowLabel){%>
      IN PAYMENT FOR
      <%}%>
      <br>
      	<%//if(WI.fillTextValue("payment_for_").length() > 0){%>
	  <%//=WI.fillTextValue("payment_for_")%>
	  	<%//}else if(vRetResult.elementAt(33) != null) {%>
		<font size="1"><%//=(String)vRetResult.elementAt(33)%></font>
		<%//}else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0){%>
	  <!--Tuition-->
	  <%//}else{%>
	  	<%//=(String)vRetResult.elementAt(5)%>
	  <%//}%><%=strPaymentFor%>
	  </td>
    <td width=233 colspan=2 valign=top>
      <%if(bolShowLabel){%>
      MODE OF PAYMENT
      <%}%>
      <br>
      <%//=(String)vRetResult.elementAt(10)%><%=strPmtMode%></td>
 </tr>
 <tr>
  <td width=223 colspan=3 valign=top style='height:35.5pt'>&nbsp;</td>
    <td width=73 valign=top >
      <%if(bolShowLabel){%>
      BANK:
      <%}%>
      <br><br>
      <%if(bolShowLabel){%>
      CHECK NO.:
      <%}%>
    </td>
    <td width=160 valign="top">
	<%//=WI.getStrValue(vRetResult.elementAt(34))%><%=WI.getStrValue(strBankName)%><br><br>
	<%//=WI.getStrValue(vRetResult.elementAt(14))%><%=WI.getStrValue(strCheckNo)%></td>
 </tr>
    <tr style='height:33.25pt'>
      <td width=116 valign=top style='height:33.25pt'>&nbsp;</td>
    <td width=340 colspan=4 valign=top style='height:33.25pt'>&nbsp; <br>
      &nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getTodaysDate(1)%> &nbsp;&nbsp;&nbsp; <%=CommonUtil.formatFloat(strAmount,true)%><%//=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
    </td>
 </tr>
    <tr style='height:35.5pt'>

  <td width=116 valign=top style='height:15.5pt'>&nbsp;</td>
    <td width=340 colspan=4 valign="middle">&nbsp;
	<br>&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)request.getSession(false).getAttribute("userId")%>
	</td>
 </tr>
 <tr height=0>
  <td width=116 style='border:none'>&nbsp;</td>
  <td width=35 style='border:none'></td>
  <td width=72 style='border:none'></td>
  <td width=73 style='border:none'></td>
  <td width=160 style='border:none'></td>
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
