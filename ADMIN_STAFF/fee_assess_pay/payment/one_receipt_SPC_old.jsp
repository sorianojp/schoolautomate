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
		TABLE.thinborderALL {
			border-top: solid 1px #000000;
			border-bottom: solid 1px #000000;
			border-left: solid 1px #000000;
			border-right: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 11px;
		}
-->
</style>
</head>
<script>
function ShowDIV() {
		if(document.all.processing.style.visibility =='visible')
			document.all.processing.style.visibility='hidden';
		else	
			document.all.processing.style.visibility='visible';
		
}
</script>
<body onLoad="window.print();" onafterprint="ShowDIV()">
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
		strPmtMode    = (String)vRetResult.elementAt(10);
		strBankName   = (String)vRetResult.elementAt(34);
		strCheckNo    = (String)vRetResult.elementAt(14);
		strDatePaid   = WI.getStrValue(vRetResult.elementAt(15));

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
		
		else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0) {
			if(vRetResult.elementAt(27).equals("0")) {
				strPaymentFor = "Downpayment";
				String strSQLQuery  = "select payment_mode from fa_stud_pmtmethod where user_index = "+vRetResult.elementAt(0) +
										" and is_valid = 1 and is_stud_temp = 0 and sy_from ="+
										vRetResult.elementAt(23)+" and semester = "+vRetResult.elementAt(22);
				strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
				if(strSQLQuery != null && strSQLQuery.equals("0"))
					  strPaymentFor = "Full Payment";
			}
			else {
				strPaymentFor = (String)vRetResult.elementAt(28);
				if(vRetResult.elementAt(33) != null && vRetResult.elementAt(33).equals("1"))
					strPaymentFor = "Full Payment";
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

}

//System.out.println(vRetResult);
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

String[] astrConvertSem = {"S", "1st Semester", "2nd Semester", "3rd Semester", ""};

String strTellerName = (String)request.getSession(false).getAttribute("userIndex");
if(strTellerName != null) {
	strTellerName = "select fname from user_table where user_index = "+strTellerName;
	strTellerName = dbOP.getResultOfAQuery(strTellerName, 0).toLowerCase();
}


if(strErrMsg == null){%>

<div id="processing" style="position:absolute; top:0px; left:0px; width:350px; height:100px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:15px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif;">Change: <%=vRetResult.elementAt(49)%>
			</p>

			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>

<table cellpadding="0" cellspacing="0" width="750" onClick="ShowDIV();">
	<tr><td height="50">&nbsp;</td></tr>
</table>
<table cellpadding="0" cellspacing="0" width="750" onClick="ShowDIV();">
<!--<table cellpadding="0" cellspacing="0" width="100%">-->
 <tr>
 <td>
	<table width="350" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >		
		<tr valign="top">
		  	<td colspan="2" align="right"><%=WI.fillTextValue("or_number")%></td>		  	
	    </tr>
		
		<tr valign="top">
		  	<td align="right" colspan="2" height="25" valign="bottom"><%=WI.getTodaysDate(1)%></td>
	    </tr>	
		
		<tr valign="top">	
			<td width="80">&nbsp;</td>				
		  	<td height="25" valign="bottom" style="font-size:12px;"><%=strStudName%></td>
		</tr>	
		
		<tr><td colspan="2">&nbsp;</td></tr>
		<tr><td colspan="2" height="35">&nbsp;</td></tr>
				
    </table>	
	
    <table width="350" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		<tr>
			<td height="270px" valign="top" align="left"><%=strPaymentFor%></td>
			<td width="25%" valign="top" align="right"><%=CommonUtil.formatFloat(strAmount,true)%></td>
		</tr>
		<tr>
		  <td valign="top" align="left"><%=WI.getStrValue(strCheckNo)%></td>
		  <td valign="top" align="right">&nbsp;</td>
	    </tr>
		<tr>
		  <td valign="top" align="left">&nbsp;</td>
		  <td valign="top" align="right">&nbsp;</td>
	    </tr>
		<tr><td class="thinborderBOTTOM" colspan="2" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=strTellerName%></td></tr>
		
		<tr>			
			<td height="25" width="50">&nbsp;</td>
			<td align="right" valign="top"><%=CommonUtil.formatFloat(strAmount,true)%></td>
		</tr>		
    </table>
 </td>
 
 
 
 
 
 
 
 
 
 <!---------------------------------------------RIGHT SIDE------------------------------------------------------------>
 
 
 <td>
	<table width="350" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >		
		<tr valign="top">
			<td width="15">&nbsp;</td>
		  	<td colspan="2" align="right"><%=WI.fillTextValue("or_number")%></td>		  	
	    </tr>
		
		<tr valign="top">
			<td width="15">&nbsp;</td>
		  	<td align="right" colspan="2" valign="bottom" height="25"><%=WI.getTodaysDate(1)%></td>
	    </tr>	
		
		<tr valign="top">
			<td width="15">&nbsp;</td>	
			<td width="70" >&nbsp;</td>				
		  	<td height="25" valign="bottom" style="font-size:12px;"><%=strStudName%></td>
		</tr>	
		
		<tr><td colspan="3">&nbsp;</td></tr>
		<tr><td colspan="3" height="35">&nbsp;</td></tr>
				
    </table>	
    <table width="350" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		<tr>
			<td height="270px" valign="top" align="left"><%=strPaymentFor%></td>
			<td width="25%" valign="top" align="right"><%=CommonUtil.formatFloat(strAmount,true)%></td>
		</tr>
		<tr>
		  <td valign="top" align="left"><%=WI.getStrValue(strCheckNo)%></td>
		  <td valign="top" align="right">&nbsp;</td>
	    </tr>
		<tr>
		  <td valign="top" align="left">&nbsp;</td>
		  <td valign="top" align="right">&nbsp;</td>
	    </tr>
		<tr><td class="thinborderBOTTOM" colspan="2" valign="bottom">
			&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
				<%=strTellerName%></td></tr>
		
		<tr>			
			<td height="25" width="50">&nbsp;</td>
			<td align="right" valign="top"><%=CommonUtil.formatFloat(strAmount,true)%></td>
		</tr>		
    </table>
 </td>
 
 </tr></table>

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
