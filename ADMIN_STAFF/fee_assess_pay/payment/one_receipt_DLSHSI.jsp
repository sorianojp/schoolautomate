<%
String strORNumber    = request.getParameter("or_number");
if(strORNumber == null || strORNumber.length() == 0){
	strORNumber = (String)request.getSession(false).getAttribute("or_number");
	if(strORNumber != null)	{
		request.getSession(false).removeAttribute("or_number");
		response.sendRedirect("./one_receipt_DLSHSI.jsp?or_number="+strORNumber);
		return;
	}
}


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>One Receipt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--

@page {
	size:11in 8.5in; 
	margin-top:0in;
	margin-bottom:0in;
	margin-left:.3in;
	margin-right:.3in;
}

@media print { 
  	@page {
		size:11in 8.5in; 
		margin-top:0in;
		margin-bottom:0in;
		margin-left:.3in;
		margin-right:.3in;
	}
}

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

TABLE.thinborderALL {
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
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


//print permit.. 
Vector vSubjectsTaken = new Vector();
String strPmtSchName  = null;
String strRemarks     = null;
String strSQLQuery    = null;



	
String[] astrConvertSem = {"Summer", "1st Sem", "2nd Sem", "3rd Sem", ""};
String[] astrConvertSem2 = {"Summer", "1st", "2nd", "3rd", ""};
String strTransationDur = null;//Duration taken for this Transcation.. 

String strTellerName = (String)request.getSession(false).getAttribute("userIndex");
if(strTellerName != null) {
	strTellerName = "select fname,mname,lname from user_table where user_index = "+strTellerName;
	java.sql.ResultSet rs = dbOP.executeQuery(strTellerName);
	if(rs.next())
		strTellerName = WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 4);
	rs.close();
}

FAPayment faPayment = new FAPayment();
Vector vRetResult = faPayment.viewPmtDetail(dbOP, strORNumber);//System.out.println(vRetResult);
if(vRetResult == null) {
	//may be basic payment.
	vRetResult = new enrollment.FAElementaryPayment().viewPmtDetail(dbOP, strORNumber);//System.out.println(vRetResult);
	if(vRetResult != null) {
		bolIsGradeShoolPmt = true;
		strStudID     = (String)vRetResult.elementAt(4);
		strStudName   = WebInterface.formatName((String)vRetResult.elementAt(6),(String)vRetResult.elementAt(7),
						(String)vRetResult.elementAt(8),4);
		String[] astrConvertToEduLevel = {"Preparatory","Elementary","High School"};
		strCourse     = astrConvertToEduLevel[Integer.parseInt((String)vRetResult.elementAt(0))];
		//vRetResult.setElementAt(strCourse,21);
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
		///save here tracking.. and then extract.. 
		/*enrollment.SetParameter SP = new enrollment.SetParameter();
		SP.trackTimeForPayment(dbOP, request, null, false, request.getParameter("or_number"));
		request.getSession(false).removeAttribute("start_time_long_or");
		
		//get time duration for this OR. 
		strTransationDur = SP.getDurForActivity(dbOP, request, null, false, null, null,"1",request.getParameter("or_number"));*/
		
		//System.out.println(strTransationDur);
		//System.out.println(request.getParameter("or_number"));
		
	
		if(vRetResult.elementAt(0) != null) {
			enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
			dOutStandingBalance= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vRetResult.elementAt(0), true, true);
			if(dOutStandingBalance < 0d)
				dOutStandingBalance = 0d;
		}

		strPmtMode    = (String)vRetResult.elementAt(10);
		strBankName   = (String)vRetResult.elementAt(34);
		//strBankName   = (String)vRetResult.elementAt(51);
		
		
		strCheckNo    = (String)vRetResult.elementAt(14);
		strDatePaid   = WI.getStrValue(vRetResult.elementAt(15));

		 ///may be it is bank posting.. 
		  if(vRetResult.elementAt(51) != null)
		   strBankName = (String)vRetResult.elementAt(51);
		   
		 if(strBankName != null) {
		   int iIndexOf = strBankName.indexOf("(");
		   if(iIndexOf > -1)
			strBankName = strBankName.substring(0,iIndexOf);
		  }

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
			vRetResult.setElementAt(strCourse, 21);
			strCourse = null;
			astrConvertSem[1] = "Regular";
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
		
		/*///get tellers name.
			strTellerName = (String)vRetResult.elementAt(39);
			int iIndexOf = strTellerName.indexOf(", ");
			if(iIndexOf > 0) 
				strTellerName = strTellerName.substring(iIndexOf + 1);*/
		
		if(vRetResult.elementAt(33) != null)
			strPaymentFor = (String)vRetResult.elementAt(33);
		
		else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0) {
			if(vRetResult.elementAt(27).equals("0")) {
				strPaymentFor = "Downpayment";
				strSQLQuery  = "select payment_mode from fa_stud_pmtmethod where user_index = "+vRetResult.elementAt(0) +
										" and is_valid = 1 and is_stud_temp = 0 and sy_from ="+
										vRetResult.elementAt(23)+" and semester = "+vRetResult.elementAt(22);
				strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
				if(strSQLQuery != null && strSQLQuery.equals("0"))
					  strPaymentFor = "Matriculation SY";//"Full Payment";
			}
			else {
				strPaymentFor = (String)vRetResult.elementAt(28);
				if(vRetResult.elementAt(33) != null && vRetResult.elementAt(33).equals("1"))
					strPaymentFor = "Matriculation SY";//"Full Payment";
			}
		}
		else {
			//if there is additional
			//if(vRetResult.elementAt(42) != null)
			//	strPaymentFor = (String)vRetResult.elementAt(42);
			//else 
			if(vRetResult.elementAt(4).equals("10"))
				strPaymentFor = "Back Account";
			else
				strPaymentFor = (String)vRetResult.elementAt(5);
		}
//System.out.println(vRetResult);

}

boolean bolTuitionPmt = false;//add to handle tuition-non tuition payment.
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(27) != null && vRetResult.elementAt(28) != null && !((String)vRetResult.elementAt(4)).equals("0"))
	bolTuitionPmt = true;
	
strTemp = "select PMT_SCH_INDEX from FA_STUD_PAYMENT where IS_VALID =1 and OR_NUMBER = "+WI.getInsertValueForDB(strORNumber, true, null);
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp != null && Integer.parseInt(strTemp) >= 0)
	bolTuitionPmt = true;
	
if(bolTuitionPmt)	
	strPaymentFor = "Matriculation SY";
	
//System.out.println(bolTuitionPmt);

/*if(vRetResult != null && vRetResult.elementAt(0) != null && vRetResult.elementAt(4) != null && (((String)vRetResult.elementAt(4)).equals("0") || bolTuitionPmt) 
&& !((String)vRetResult.elementAt(4)).equals("10") ) {
	//System.out.println(vRetResult.elementAt(27));
	//System.out.println(vRetResult.elementAt(28));
	
	strSQLQuery = (String)vRetResult.elementAt(27);
	if(strSQLQuery != null && strSQLQuery.length() > 0 && Integer.parseInt(strSQLQuery) > 0) {
		strSQLQuery = "select prop_val from read_Property_file where prop_name='print_admslip_on_or' and prop_val = "+strSQLQuery;
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null)
			strSQLQuery = "1";
	}
	else	
		strSQLQuery = null;

	if(strSQLQuery != null && strSQLQuery.equals("1")) {
		//I have to check if ok for payment.
		strPmtSchName = (String)vRetResult.elementAt(28);
		if(strPmtSchName != null && vRetResult.elementAt(0) != null) {
			Vector vInstallmentInfo = new enrollment.FAAssessment().getPaymentDueForAnExam(dbOP, (String)vRetResult.elementAt(0),
									  (String)vRetResult.elementAt(23), (String)vRetResult.elementAt(24), (String)vRetResult.elementAt(21), 
									  (String)vRetResult.elementAt(22), null, strPmtSchName);
									  
			//System.out.println(vInstallmentInfo);
			if(vInstallmentInfo != null && vInstallmentInfo.elementAt(1).equals("0")) {
				strTemp = (String)vRetResult.elementAt(4);
				if(strTemp != null && (strTemp.equals("0") || bolTuitionPmt) ) {//permit is OK now.
					//I have to get the subjects taken by student.
					CommonUtil.setSubjectInEFCLTable(dbOP);
					
					strSQLQuery = "select sub_code from enrl_final_cur_list "+
									"join subject on (subject.sub_index = efcl_sub_index) "+
									" where user_index = "+vRetResult.elementAt(0)+" and is_temp_stud = 0 and sy_from = "+
									(String)vRetResult.elementAt(23)+" and current_semester = "+(String)vRetResult.elementAt(22)+
									" and is_valid = 1 order by sub_code ";
					java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
					while(rs.next())
						vSubjectsTaken.addElement(rs.getString(1));
					rs.close();
				}
			}
		}
	}
}*/
		//System.out.println(vRetResult.elementAt(33));
		//System.out.println(vRetResult.elementAt(27));
		//System.out.println(vRetResult.elementAt(28));
		//System.out.println(vRetResult.elementAt(4));

//if multiple payment, i have to split it.. 
Vector vMultiplePmtInfo = new Vector();

if(vRetResult != null && vRetResult.size() > 0 && 
	vRetResult.elementAt(33) != null && ((String)vRetResult.elementAt(33)).length() > 0 && ((String)vRetResult.elementAt(4)).equals("8")) {
	
	Vector vAllPayment = CommonUtil.convertCSVToVector((String)vRetResult.elementAt(33), "<br>",true); 
	Vector vTemp = null;
	for(int p = 0; p < vAllPayment.size(); ++p) {
          vTemp = CommonUtil.convertCSVToVector((String)vAllPayment.elementAt(p), ":",true);
		  strTemp = (String)vTemp.remove(0);
		  if(strTemp != null)
		  	strTemp = strTemp.toUpperCase();
          vMultiplePmtInfo.addElement(strTemp);
          vMultiplePmtInfo.addElement(vTemp.remove(0));
    }
	if(vMultiplePmtInfo.size() > 0 && ((String)vMultiplePmtInfo.elementAt(0)).equalsIgnoreCase("Tuition"))
		vMultiplePmtInfo.setElementAt(vRetResult.elementAt(28),0);
}
//System.out.println(vMultiplePmtInfo);
if(vRetResult.elementAt(22) != null) {				
	strTemp = ((String)vRetResult.elementAt(23)).substring(2) + "-"+((String)vRetResult.elementAt(24)).substring(2);
	
	if(strPaymentFor != null && strPaymentFor.toLowerCase().startsWith("matriculation"))
		strPaymentFor = strPaymentFor+" "+strTemp+"<br>Term :"+astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))];					
	
}

if(vMultiplePmtInfo.size() == 0){
	vMultiplePmtInfo.addElement(strPaymentFor);
	vMultiplePmtInfo.addElement(strAmount);
}


if(vRetResult != null && vRetResult.size() > 42)
	strRemarks = WI.getStrValue((String)vRetResult.elementAt(42));




if(strErrMsg == null){%>

<%--<div id="processing" style="position:absolute; top:0px; left:0px; width:350px; height:100px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:15px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif;">Change: <%=vRetResult.elementAt(49)%>
			</p>

			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>--%>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td valign="top" width="48%">
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
	    <td height="55" align="center">&nbsp;</td>
    </tr>
	<tr><td height="25" align="center"><strong style="font-size:14px">OFFICIAL RECEIPT</strong></td></tr>
</table>

<table cellpadding="0" border="0" cellspacing="0" width="100%">
	<tr>
		<td valign="top">
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
				<tr>
					<td width="31%">ID/HOSP.NO./TIN.:</td>
					<td width="32%"><%=strStudID%></td>
					<td width="20%">NUMBER:</td>
					<td width="17%"><%=strORNumber%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
				<tr>
					<td width="15%">PAYOR:</td>
					<td width="48%"><%=strStudName%><%=WI.getStrValue(strCourse," - ","","")%></td>
					<td width="10%">DATE:</td>
					<td width="27%"><%=strDatePaid%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
				<tr>
					<td width="23%">YEAR LEVEL:</td>
					<td width="8%"><%=WI.getStrValue((String)vRetResult.elementAt(21))%></td>
					<td width="17%">SEMESTER:</td>
					<td width="15%"><%=astrConvertSem2[Integer.parseInt((String)vRetResult.elementAt(22))]%></td>
					<td width="25%">SCHOOL YEAR :</td>
					<%
					strTemp = ((String)vRetResult.elementAt(23)).substring(2) + "-"+((String)vRetResult.elementAt(24)).substring(2);
					%>
					<td width="12%"><%=WI.getStrValue(strTemp)%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td width="50%" height="20" align="center" style="font-size:12px"><u>P A R T I C U L A R S</u></td>
		<td width="50%" align="center" style="font-size:12px"><u>A M O U N T</u></td>
	</tr>
	<%
	int iTotCount = 0;
	for(int a = 0; a < vMultiplePmtInfo.size(); a += 2) {
	++iTotCount;
	%>
	<tr>
		<td height="16"><%=vMultiplePmtInfo.elementAt(a)%></td>
		<td style="padding-right:80px;" align="right"><%=CommonUtil.formatFloat((String)vMultiplePmtInfo.elementAt(a + 1),true)%></td>
	</tr>
	<%}
	if(iTotCount < 10){	
	for(int a = iTotCount; a <= 10; a++) {	
	%>
	<tr>
		<td height="16">&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<%}
	}%>	
</table>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr><td valign="top" height="30">REMARKS: <%=strRemarks%></td></tr>
</table>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr><td width="75%" height="16" style="padding-left:20px; font-size:9px;">TOTAL SALES(VAT INCLUSIVE)</td>
	    </tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">Less:VAT</td>
	    </tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">TOTAL</td>
	    </tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">Less:SC/PWD Discount</td>
	    </tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">TOTAL DUE</td>
	    </tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">Less:WITHHOLDING TAX</td>
	    </tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">AMOUNT DUE</td>
	    </tr>
</table>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr><td width="38%" height="15"></td>
	    <td colspan="2"></td>
	</tr>
	
	<tr><td height="16" style="padding-left:20px; font-size:9px;">SR.CITIZEN TIN:</td>
	    <td colspan="2" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"></div></td>
	</tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">SC/PWD Card No.:</td>
	    <td colspan="2" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"></div></td>
	</tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">Signature:</td>
	    <td colspan="2" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"></div></td>
	</tr>
	<tr><td width="38%" height="15"></td>
	    <td colspan="2"></td>
	</tr>
	
	<tr><td height="16" style="padding-left:20px; font-size:10px;">VATABLE SALES</td>
	    <td colspan="2" style="padding-left:20px;">&nbsp;</td>
	</tr>
	<tr><td height="16" style="padding-left:20px; font-size:10px;">VAT EXEMPT SALES</td>
	    <td width="38%"><div style="border-bottom:dotted 1px #000000;"></div></td>
	    <td width="24%" align="right" style="padding-right:40px;"><strong style="font-size:12px;"><%=CommonUtil.formatFloat(strAmount,true)%></strong></td>
	</tr>
	<tr><td height="16" style="padding-left:20px; font-size:10px;">ZERO-RATED SALES</td>
	    <td colspan="2" style="padding-left:20px;">&nbsp;</td>
	</tr>
	<tr><td height="16" style="padding-left:20px; font-size:10px;">VAT AMOUNT</td>
	    <td colspan="2" style="padding-left:20px;">&nbsp;</td>
	</tr>
	<tr><td width="38%" height="15"></td>
	    <td colspan="2"></td>
	</tr>
	<tr><td height="16" style="padding-left:20px; font-size:10px;">TOTAL SALES</td>
	    <td><div style="border-bottom:dotted 1px #000000;"></div></td>
	    <td style="padding-right:40px;" align="right"><strong style="font-size:13px;"><%=CommonUtil.formatFloat(strAmount,true)%></strong></td>
	</tr>
</table>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr><td width="34%" height="16" style="padding-left:20px; font-size:10px;">CHECK NUMBER</td>
	    <td colspan="2">&nbsp;</td>
	</tr>
	<tr><td height="16" align="right" style=" font-size:10px;">BANK:&nbsp;</td>
	    <td colspan="2"><strong><%=WI.getStrValue(strBankName)%><%=WI.getStrValue(strCheckNo)%></strong></td>
	</tr>
	<tr>
	    <td height="16" colspan="3" align="center"><div style="border-bottom:solid 1px  #000000; width:70%;"><%=WI.getStrValue(strTellerName)%></div>CASHIER</td>
    </tr>
	<tr>
	    <td style="font-size:8px;" height="16" colspan="2">BIR PERMIT NO. <0000-000-00000> CAS &lt;month/date/year&gt;</td>
        <td style="font-size:10px;" width="28%" align="right"><u>ORIGINAL COPY</u></td>
	</tr>
</table>
		</td>
		<td>&nbsp;</td>
		<td valign="top" width="48%">
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
	    <td height="55" align="center">&nbsp;</td>
    </tr>
	<tr><td height="25" align="center"><strong style="font-size:14px">OFFICIAL RECEIPT</strong></td></tr>
</table>

<table cellpadding="0" border="0" cellspacing="0" width="100%">
	<tr>
		<td valign="top">
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
				<tr>
					<td width="25%">ID/HOSP.NO./TIN.:</td>
					<td width="38%"><%=strStudID%></td>
					<td width="20%">NUMBER:</td>
					<td width="17%"><%=strORNumber%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
				<tr>
					<td width="15%">PAYOR:</td>
					<td width="48%"><%=strStudName%><%=WI.getStrValue(strCourse," - ","","")%></td>
					<td width="10%">DATE:</td>
					<td width="27%"><%=strDatePaid%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
				<tr>
					<td width="19%">YEAR LEVEL:</td>
					<td width="12%"><%=WI.getStrValue((String)vRetResult.elementAt(21))%></td>
					<td width="17%">SEMESTER:</td>
					<td width="15%"><%=astrConvertSem2[Integer.parseInt((String)vRetResult.elementAt(22))]%></td>
					<td width="22%">SCHOOL YEAR :</td>
					<%
					strTemp = ((String)vRetResult.elementAt(23)).substring(2) + "-"+((String)vRetResult.elementAt(24)).substring(2);
					%>
					<td width="15%"><%=WI.getStrValue(strTemp)%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td width="50%" height="20" align="center" style="font-size:12px"><u>P A R T I C U L A R S</u></td>
		<td width="50%" align="center" style="font-size:12px"><u>A M O U N T</u></td>
	</tr>
	<%
	iTotCount = 0;
	for(int a = 0; a < vMultiplePmtInfo.size(); a += 2) {
	++iTotCount;
	%>
	<tr>
		<td height="16"><%=vMultiplePmtInfo.elementAt(a)%></td>
		<td style="padding-right:80px;" align="right"><%=CommonUtil.formatFloat((String)vMultiplePmtInfo.elementAt(a + 1),true)%></td>
	</tr>
	<%}
	if(iTotCount < 10){	
	for(int a = iTotCount; a <= 10; a++) {	
	%>
	<tr>
		<td height="16">&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<%}
	}%>	
</table>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr><td valign="top" height="30">REMARKS: <%=strRemarks%></td></tr>
</table>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr><td width="56%" height="16" style="padding-left:20px; font-size:9px;">TOTAL SALES(VAT INCLUSIVE)</td>
	    </tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">Less:VAT</td>
	    </tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">TOTAL</td>
	    </tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">Less:SC/PWD Discount</td>
	    </tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">TOTAL DUE</td>
	    </tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">Less:WITHHOLDING TAX</td>
	    </tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">AMOUNT DUE</td>
	    </tr>
</table>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr><td width="38%" height="15"></td>
	    <td colspan="2"></td>
	</tr>
	
	<tr><td height="16" style="padding-left:20px; font-size:9px;">SR.CITIZEN TIN:</td>
	    <td colspan="2" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"></div></td>
	</tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">SC/PWD Card No.:</td>
	    <td colspan="2" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"></div></td>
	</tr>
	<tr><td height="16" style="padding-left:20px; font-size:9px;">Signature:</td>
	    <td colspan="2" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"></div></td>
	</tr>
	<tr><td width="38%" height="15"></td>
	    <td colspan="2"></td>
	</tr>
	
	<tr><td height="16" style="padding-left:20px; font-size:10px;">VATABLE SALES</td>
	    <td colspan="2" style="padding-left:20px;">&nbsp;</td>
	</tr>
	<tr><td height="16" style="padding-left:20px; font-size:10px;">VAT EXEMPT SALES</td>
	    <td width="38%"><div style="border-bottom:dotted 1px #000000;"></div></td>
	    <td width="24%" align="right" style="padding-right:40px;"><strong style="font-size:12px;"><%=CommonUtil.formatFloat(strAmount,true)%></strong></td>
	</tr>
	<tr><td height="16" style="padding-left:20px; font-size:10px;">ZERO-RATED SALES</td>
	    <td colspan="2" style="padding-left:20px;">&nbsp;</td>
	</tr>
	<tr><td height="16" style="padding-left:20px; font-size:10px;">VAT AMOUNT</td>
	    <td colspan="2" style="padding-left:20px;">&nbsp;</td>
	</tr>
	<tr><td width="38%" height="15"></td>
	    <td colspan="2"></td>
	</tr>
	<tr><td height="16" style="padding-left:20px; font-size:10px;">TOTAL SALES</td>
	    <td><div style="border-bottom:dotted 1px #000000;"></div></td>
	    <td style="padding-right:40px;" align="right"><strong style="font-size:13px;"><%=CommonUtil.formatFloat(strAmount,true)%></strong></td>
	</tr>
</table>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr><td width="34%" height="16" style="padding-left:20px; font-size:10px;">CHECK NUMBER</td>
	    <td colspan="2">&nbsp;</td>
	</tr>
	<tr><td height="16" align="right" style=" font-size:10px;">BANK:&nbsp;</td>
	    <td colspan="2"><strong><%=WI.getStrValue(strBankName)%><%=WI.getStrValue(strCheckNo)%></strong></td>
	</tr>
	<tr>
	    <td height="16" colspan="3" align="center"><div style="border-bottom:solid 1px  #000000; width:70%;"><%=WI.getStrValue(strTellerName)%></div>CASHIER</td>
    </tr>
	<tr>
	    <td style="font-size:8px;" height="16" colspan="2">BIR PERMIT NO. <0000-000-00000> CAS &lt;month/date/year&gt;</td>
        <td style="font-size:10px;" width="28%" align="right"><u>DUPLICATE COPY</u></td>
	</tr>
</table>
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
