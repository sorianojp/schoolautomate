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

<body leftmargin="30" topmargin="0" bottommargin="0" onLoad="window.print()">
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


double dChkAmt = 0d; double dCashAmt = 0;


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
		//student status.
		if( ((String)vRetResult.elementAt(29)).compareTo("0") == 0)
			strStudStatus = "Old Student";
		else
			strStudStatus = "New Student";
		
		strAmount     = (String)vRetResult.elementAt(11);
		if(vRetResult.elementAt(33) != null) 
			strPaymentFor = (String)vRetResult.elementAt(33);
		else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0)
			strPaymentFor = "Tuition";
		else {
			//if there is additional
			if(vRetResult.elementAt(42) != null)
				strPaymentFor = (String)vRetResult.elementAt(42);
			else if(vRetResult.elementAt(4).equals("10")) {
				strPaymentFor = "Back Account";
			}
			else
				strPaymentFor = (String)vRetResult.elementAt(5);
		}
		
		strPmtMode    = (String)vRetResult.elementAt(10);
		strBankName   = (String)vRetResult.elementAt(34);
		strCheckNo    = (String)vRetResult.elementAt(14);
		strDatePaid   = WI.getStrValue(vRetResult.elementAt(15));
		dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
		dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));
}

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

if(strErrMsg == null){%>
<br><br><br>
<table border=0 cellspacing=0 cellpadding=0>
<tr>
	<td valign="bottom"><table border=0 cellspacing=0 cellpadding=0 width=150>
	  <tr>
	    <td><%=WI.getStrValue(strBankName)%><br>
	        <%=WI.getStrValue(strCheckNo)%><br>
            <div align="right"><br>
                <br>
                <%if(	dChkAmt > 0d){%>
					<%=CommonUtil.formatFloat(dChkAmt,true)%> (check)
					<%if(dCashAmt > 0) {%>
						<%="<br>"+CommonUtil.formatFloat(dCashAmt,true)%> (cash)&nbsp;&nbsp;
					<%}%>	
                <%}else if(vRetResult.elementAt(14) != null){%>
                <%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
                <%}//show only if check.%>
            </div>
	      <br>
	      <br>
	      <br></td>
	    </tr>
	  </table>	</td>
	<td>

<table border=0 cellspacing=0 cellpadding=0 width=456>
  <tr> 
    <td colspan=2 valign=top>&nbsp;</td>
    <td colspan=2 valign=top>&nbsp;</td>
    <td width=175 valign=top> <%if(bolShowLabel){%>
      O.R. 
      <%}%> <br> <br> <br> <br><br><br>&nbsp;&nbsp;<%=request.getParameter("or_number")%> <br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=strDatePaid%></td>
  </tr>
  <tr> 
    <td colspan=5 valign=middle style='height:25.0pt'> <%if(bolShowLabel){%>
      NAME 
      <%}%>
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp; 
      <font style="font-size:13px">(<%=strStudID%>) <%=strStudName%> </font></td>
  </tr>
  <tr> 
    <td colspan=1 valign=bottom style='height:20.5pt'> <%if(bolShowLabel){%>
      Course/Yr 
      <%}//System.out.println(vRetResult.elementAt(11));System.out.println("Printing.."+Float.parseFloat((String)vRetResult.elementAt(11)));%> </td>
    <td colspan=4> <div align="left">
        <%//=WI.getStrValue((String)vRetResult.elementAt(35),"")%>
        <%=strCourse%><%=WI.getStrValue((String)vRetResult.elementAt(21)," - ","","")%> </div></td>
  </tr>
  <tr> 
    <td colspan=5 valign=top> <%if(bolShowLabel){%>
      AMOUNT IN WORDS 
        <%}//System.out.println(vRetResult.elementAt(11));System.out.println("Printing.."+Float.parseFloat((String)vRetResult.elementAt(11)));%>
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
            <%//=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vRetResult.elementAt(11)),"Pesos","Centavos")%> <font style="font-size:14px"><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%></font></td>
  </tr>
  <tr> 
    <td colspan=5 valign=middle><div align="right"> <br>
              <%//=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
      <font style="font-size:14px"><%=CommonUtil.formatFloat(strAmount,true)%></font> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </div></td>
  </tr>
  <tr> 
    <td colspan=5 valign=top style='height:25.5pt'> <%if(bolShowLabel){%>
      IN PAYMENT FOR 
      <%}%><%//if(WI.fillTextValue("payment_for_").length() > 0){%> <%//=WI.fillTextValue("payment_for_")%> <%//}else if(vRetResult.elementAt(33) != null) {%> <font size="1"> 
      <%//=(String)vRetResult.elementAt(33)%>
      </font> <%//}else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0){%> 
      <!--Tuition-->
      <%//}else{%> <%//=(String)vRetResult.elementAt(5)%> <%//}%>
      <br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      <%=strPaymentFor%> 
	  <%if(vRetResult.elementAt(22) != null) {%>
	  	(<%=astrConvertToSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>/ <%=(String)vRetResult.elementAt(23) + "-"+(String)vRetResult.elementAt(24)%>)
	  <%}%>	  </td>
  </tr>
  <tr> 
    <td colspan=3 valign=top style='height:12.5pt'>&nbsp;</td>
    <td width=31 valign=top >&nbsp;</td>
    <td width=175 valign="top">&nbsp;</td>
  </tr>
  <tr> 
    <td width=102 valign=top style='height:15.5pt'>&nbsp;</td>
    <td colspan=4 valign="bottom"><div align="right"> <br><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </div></td>
  </tr>
  <tr height=0> 
    <td width=102 style='border:none'>&nbsp;</td>
    <td width=104 style='border:none'></td>
    <td width=44 style='border:none'></td>
    <td width=31 style='border:none'></td>
    <td width=175 style='border:none'></td>
  </tr>
</table>	</td>
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
