<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>One Receipt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
-->
</style>
</head>

<body leftmargin="0" topmargin="0" bottommargin="0" onLoad="window.print();">
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

String[] astrConvertSem = {"SUMMER","1ST SEM","2ND SEM", "3RD SEM"};

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

String strAmtTendered = null;
String strAmtChange   = null;

double dChkAmt = 0d; double dCashAmt = 0d; String strYrLevel = null; String strFName = null;

boolean bolIsSupplies = false;

boolean bolIsCavite = false;
boolean bolIsICA    = false;

strTemp = "select info5 from sys_info";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp != null && strTemp.equals("Cavite"))
	bolIsCavite = true;
if(strTemp != null && strTemp.equals("ICA"))
	bolIsICA = true;


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
		strStudStatus = "";strPaymentFor = "AR Students";
		strAmount     = (String)vRetResult.elementAt(9);
		strPmtMode    = (String)vRetResult.elementAt(12);
		strBankName   = (String)vRetResult.elementAt(14);
		strCheckNo    = (String)vRetResult.elementAt(10);
		strDatePaid   = (String)vRetResult.elementAt(11);
		
		strYrLevel   = (String)vRetResult.elementAt(21);

		dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
		dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));
	}
	else
		strErrMsg = faPayment.getErrMsg();

}
else {//not basic payment.
		strStudID     = WI.getStrValue((String)vRetResult.elementAt(25),"External Pmt");
		//name
		if( vRetResult.elementAt(0) != null) {
			strStudName     = (String)vRetResult.elementAt(18);
						//get last name, first name and mi. 
			String strSQLQuery = "select fname, mname, lname from user_table where id_number = '"+strStudID+"'";
			//System.out.println(strSQLQuery);
			java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next()) {
				strStudName = rs.getString(3);
				strFName    = rs.getString(1);
				if(rs.getString(2) != null && rs.getString(2).length() > 0)
					strFName += " "+rs.getString(2);
					
			}
		}
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
		else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0) {
			if(bolIsICA)
				strPaymentFor = "Tuition Fee";
			else
				strPaymentFor = "AR Students";
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
		
		
		strTemp = "select SUPPLY_REF from FA_OTH_SCH_FEE_SUPPLIES where SUPPLY_FEE_NAME = '"+strPaymentFor+"'";
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null)
			bolIsSupplies = true;

}

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

if(strErrMsg == null){%>
<table border=0 cellspacing=0 cellpadding=0 width=700>
	<tr valign="top" align="center">
		<td height="60" colspan="3">&nbsp;</td>
		<td align="right"><%if(!bolIsCavite){%><%=request.getParameter("or_number")%><%}%></td>
	</tr>
	<tr valign="top" align="center">
		<td height="50" width="20%"><%=strStudID%></td>
		<!--<td width="30%">dlsfjdsljfsd</td>-->
		<td width="30%"><%=strStudName%></td>
		<td width="30%"><%=WI.getStrValue(strFName, "&nbsp;")%></td>
		<td width="20%" align="right"><%=strCourse%></td>
	</tr>
	<tr valign="top" align="center">
	  <td height="50"><%=CommonUtil.formatFloat(strAmount,true)%></td>
	  <td colspan="3"><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%></td>
  </tr>
</table>
<table border=0 cellspacing=0 cellpadding=0 width=700>
	<tr valign="top" align="center">
	  <td height="50" width="20%">&nbsp;</td>
	  <td width="30%"><br><%=strPaymentFor%></td>
	  <td width="10%">&nbsp;</td>
	  <td width="15%"><br>
	  <% if(vRetResult.elementAt(22) != null){%>
		<%=(String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24)).substring(2)%>
			<br>
		<%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>
		<%}%>
	  </td>
	  <td valign="bottom"><%=WI.getStrValue(strYrLevel, "&nbsp;")%></td>
  </tr>
</table>
<%
double dAmountTendered = Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""), "0")) + Double.parseDouble(ConversionTable.replaceString(strAmount, ",","")) ;
%>
<table border=0 cellspacing=0 cellpadding=0 width=700>
	<tr valign="top" align="center">
		<td height="50" width="12%">&nbsp;</td>
		<td width="23%" align="left"><br>
		<%=strAmtTendered%>
		<br>
		<%if(vRetResult.elementAt(14) == null){%>
			<%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
		<%}//show only if check.
		else if(dChkAmt > 0d){%>
			<%=CommonUtil.formatFloat(dCashAmt,true)%>
		<%}%>
		<br>
		<%if(strAmtTendered != null && !strAmtTendered.equals("0.00") && strAmtChange != null) {%>
			<%=strAmtChange%>
		<%}%>
		<%//=WI.fillTextValue("sukli")%>		</td>
		<!--<td width="30%">dlsfjdsljfsd</td>-->
		<td width="25%" valign="top"><br><br><%=(String)request.getSession(false).getAttribute("first_name")%></td>
		<td width="10%" valign="top"><br><br><%=strDatePaid%></td>
		<td align="left">
		<%if(bolIsCavite){%>
		<br><br>
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr align="center">
					<td width="50%" style="font-size:11px;"><%=request.getParameter("or_number")%></td>
					<td width="50%" align="right" style="font-size:11px;"><%=CommonUtil.formatFloat(strAmount,true)%></td>
				</tr>
			</table>
		<%}else if(!bolIsSupplies) {%>
			<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborderALL">
				<tr>
					<td width="69%" style="font-size:11px;">VATABLE</td>
					<td width="31%" align="right" style="font-size:11px;">0.00</td>
				</tr>
				<tr>
					<td style="font-size:11px;">NON-VAT/EXEMPT SALE</td>
					<td align="right" style="font-size:11px;"><%=CommonUtil.formatFloat(strAmount,true)%></td>
				</tr>
				<tr>
					<td style="font-size:11px;">VAT ZERO-RATED SALE</td>
					<td align="right" style="font-size:11px;">0.00</td>
				</tr>
				<tr>
					<td style="font-size:11px;">TOTAL SALES</td>
					<td align="right" style="font-size:11px;"><%=CommonUtil.formatFloat(strAmount,true)%></td>
				</tr>
				<tr>
					<td style="font-size:11px;">VAT</td>
					<td align="right" style="font-size:11px;">0.00</td>
				</tr>
			</table>
			
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
