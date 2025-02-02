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

double dOutStandingBalance = 0d;


String strLine1 = null;//COLLEGE-REG/ 3rd YEAR
String strLine2 = null;//TERM, SY
String strLine3 = null;//Total Amt Paid, Balance.
String[] astrConvertSem  = {"Summer", "1st Tri", "2nd Tri", "3rd Tri", ""};
String[] astrConvertYear = {"", "1ST YEAR", "2ND YEAR", "3RD YEAR", "4TH YEAR", "5TH YEAR","6TH YEAR","7TH YEAR"};
boolean bolIsBasic = false;


//print permit.. 
Vector vSubjectsTaken = new Vector();
String strPmtSchName  = null;

String strSQLQuery     = null;
java.sql.ResultSet rs  = null;

String strTellerName = (String)request.getSession(false).getAttribute("first_name");
/**
(String)request.getSession(false).getAttribute("userIndex");
if(strTellerName != null) {
	strTellerName = "select fname from user_table where user_index = "+strTellerName;
	strTellerName = dbOP.getResultOfAQuery(strTellerName, 0).toLowerCase();
}
**/

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
		if(vRetResult.elementAt(0) != null) {
			enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
			dOutStandingBalance= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vRetResult.elementAt(0), true, true);
			if(dOutStandingBalance < 0d)
				dOutStandingBalance = 0d;
		}

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
		
		///get tellers name.
			strTellerName = (String)vRetResult.elementAt(39);
			int iIndexOf = strTellerName.indexOf(", ");
			if(iIndexOf > 0) 
				strTellerName = strTellerName.substring(iIndexOf + 1);
		
		if(vRetResult.elementAt(33) != null)
			strPaymentFor = (String)vRetResult.elementAt(33);
		
		else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0) {
			if(vRetResult.elementAt(27).equals("0")) {//downpayment.
				strPaymentFor = "Student Income Receivable";
				
				strLine3 = null;//Total Amt Paid, Balance. -- nothing to show.
			}
			else {//Tuition.
				strPaymentFor = "Student Income Receivable";
				
				strSQLQuery = "select sum(amount) from fa_stud_payment where or_number is not null and is_valid = 1 and sy_from = "+
								vRetResult.elementAt(23)+" and semester = "+vRetResult.elementAt(22)+" and user_index = "+vRetResult.elementAt(0);
				rs = dbOP.executeQuery(strSQLQuery);
				if(rs.next())
					strLine3 = "Amt Pd: "+CommonUtil.formatFloat(rs.getDouble(1), true);
				else	
					strLine3 = "Amt Pd: 0.00";
				rs.close();
				
				strLine3 = strLine3 + " Bal: "+CommonUtil.formatFloat(dOutStandingBalance, true);
			}
			if(bolIsBasic) {
				int iYear = Integer.parseInt((String)vRetResult.elementAt(21));
				if(iYear < 4)
					strLine1 = "PS";
				else if(iYear < 10 || iYear == 14 || iYear == 15 || iYear == 16) 
					strLine1 = "GS";
				else if(iYear < 14 || (iYear > 16 && iYear < 25) ) 
					strLine1 = "JHS";
				else
					strLine1 = "SHS"; 
				strLine1 = strLine1 + "/ "+strCourse;
				strLine2 = vRetResult.elementAt(23)+"-"+vRetResult.elementAt(24);
			}
			else {//get college. 
				strSQLQuery = "select c_code, c_name from college join course_offered on (course_offered.c_index = college.c_index) where course_code = '"+strCourse+"'";
				rs = dbOP.executeQuery(strSQLQuery);
				if(rs.next()) {
					strTemp = rs.getString(2);
					if(strTemp.indexOf("WEEKEND") > -1) 
						strTemp = "WKC";
					else if(strTemp.indexOf("REGULAR") > -1) 
						strTemp = "Reg College";
					else	
						strTemp = rs.getString(1);
				}
				rs.close();
				if(strTemp != null) {
					strLine1 = strTemp + "/ "+astrConvertYear[Integer.parseInt((String)vRetResult.elementAt(21))];
				}
				strLine2 = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))] +" "+vRetResult.elementAt(23)+"-"+vRetResult.elementAt(24);
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

boolean bolTuitionPmt = false;//add to handle tuition-non tuition payment.
if(vRetResult.elementAt(27) != null && vRetResult.elementAt(28) != null && !((String)vRetResult.elementAt(4)).equals("0"))
	bolTuitionPmt = true;

//if multiple payment, i have to split it.. 
Vector vMultiplePmtInfo = new Vector();

if(vRetResult.elementAt(33) != null && ((String)vRetResult.elementAt(33)).length() > 0 && ((String)vRetResult.elementAt(4)).equals("8")) {
	Vector vAllPayment = CommonUtil.convertCSVToVector((String)vRetResult.elementAt(33), "<br>",true); 
	Vector vTemp = null;
	for(int p = 0; p < vAllPayment.size(); ++p) {
          vTemp = CommonUtil.convertCSVToVector((String)vAllPayment.elementAt(p), ":",true);
          vMultiplePmtInfo.addElement(vTemp.remove(0));
          vMultiplePmtInfo.addElement(vTemp.remove(0));
    }
	if(vMultiplePmtInfo.size() > 0 && ((String)vMultiplePmtInfo.elementAt(0)).equals("Tuition"))
		vMultiplePmtInfo.setElementAt(vRetResult.elementAt(28),0);
}
//System.out.println(vMultiplePmtInfo);


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

<table cellpadding="0" cellspacing="0" width="560px" onClick="ShowDIV();">
	<tr><td height="25">&nbsp;</td></tr>
</table>
<table cellpadding="0" cellspacing="0" width="560px" onClick="ShowDIV();">
<!--<table cellpadding="0" cellspacing="0" width="100%">-->
 <tr>
 <td valign="top">
	<table width="560px" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >		
		<tr valign="top">
		  	<td colspan="3" align="right"><%=WI.fillTextValue("or_number")%></td>		  	
	    </tr>
		
		<tr valign="top">
		  	<td align="right" height="25" valign="bottom"></td>
	        <td height="25" valign="bottom" width="123"><%=strStudID%></td>
		    <td width="530" align="right" valign="bottom"><%=strDatePaid%></td>
		</tr>	
		
		<tr valign="top">	
			<td width="47">&nbsp;</td>				
		  	<td height="25" colspan="2" valign="bottom" style="font-size:12px;"><%=strStudName%></td>
		</tr>	
		
		<tr><td colspan="3">&nbsp;</td></tr>
		<tr><td colspan="3" height="35">&nbsp;</td></tr>
    </table>	
	
    <table width="560px" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		
		<%if(vMultiplePmtInfo.size() == 0) {%>
			<tr>
				<td height="160px" align="left" valign="top"><%=strPaymentFor%>
				<br><br>
				<%=WI.getStrValue(strLine1,"","<br>","")%>
				<%=WI.getStrValue(strLine2,"","<br>","")%>
				<%=WI.getStrValue(strLine3,"","<br>","")%>
				<%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","")%>				</td>
				<td valign="top" align="right"><%=CommonUtil.formatFloat(strAmount,true)%></td>
			</tr>
  <%}else{%>
			<tr>
				<td height="160px" align="left" valign="top" colspan="2">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<%for(int a = 0; a < vMultiplePmtInfo.size(); a += 2) {%>
							<tr>
								<td width="75%"><%=vMultiplePmtInfo.elementAt(a)%></td>
								<td align="right" width="25%"><%=vMultiplePmtInfo.elementAt(a + 1)%></td>
							</tr>
						<%}%>
					</table>				</td>
			</tr>
		<%}%>
		<tr>
		  <td valign="top" align="left" width="75%" height="25"></td>
		  <td valign="top" align="right" width="25%">&nbsp;</td>
	    </tr>
		<tr><td class="thinborderBOTTOM" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%if(dCashAmt > 0d) {%><%=CommonUtil.formatFloat(dCashAmt,true)%><%}%></td>
          <td class="thinborderBOTTOM" valign="bottom" align="right"><%if(dChkAmt > 0d) {%><%=CommonUtil.formatFloat(dChkAmt,true)%><%}%></td>
		</tr>
		<tr>
		  <td class="thinborderBOTTOM" valign="bottom" style="font-size:9px">&nbsp;</td>
		  <td class="thinborderBOTTOM" valign="bottom" align="right"><%=WI.getStrValue(strCheckNo)%></td>
	    </tr>
		<tr>
		  <td class="thinborderBOTTOM" valign="bottom" style="font-size:9px">&nbsp;</td>
		  <td class="thinborderBOTTOM" valign="bottom" align="right"><%=WI.getStrValue(strBankName)%></td>
	    </tr>
		<tr>
		  <td class="thinborderBOTTOM" valign="bottom" style="font-size:9px">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strTellerName).toUpperCase()%></td>
		  <td class="thinborderBOTTOM" valign="bottom" align="right">&nbsp;</td>
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
