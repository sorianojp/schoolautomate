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

<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0" onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
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

double dChkAmt = 0d; double dCashAmt = 0d;


String strAmtTendered = null;
String strAmtChange   = null;


FAPayment faPayment = new FAPayment();
enrollment.FAAssessment FA     = new enrollment.FAAssessment();
String strPmtSchName = null;
boolean bolIsOkForExam = false;

Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));
double dAmtVatable = 0d;
double d12Percent  = 0d;
double dTaxExempt  = 0d;
if(vRetResult != null) {
	strPmtSchName = (String)vRetResult.elementAt(28);
	if(strPmtSchName != null && vRetResult.elementAt(0) != null) {
		Vector vInstallmentInfo = FA.getPaymentDueForAnExam(dbOP, (String)vRetResult.elementAt(0),
								  (String)vRetResult.elementAt(23), (String)vRetResult.elementAt(24), (String)vRetResult.elementAt(21), 
								  (String)vRetResult.elementAt(22), null, strPmtSchName);
								  
		//System.out.println(vInstallmentInfo);
		
		if(vInstallmentInfo != null && vInstallmentInfo.elementAt(1).equals("0")) {
			strTemp = (String)vRetResult.elementAt(4);
			if(strTemp != null && strTemp.equals("0")) {
				bolIsOkForExam = true;
			}
		}
	}
	
	Vector vFeeVatable = new Vector();
	
	strTemp = 
		" select othsch_fee_index,fee_name from fa_oth_sch_fee where is_valid = 1  "+
		" and sy_index = (select sy_index from fa_schyr where sy_from ="+(String)vRetResult.elementAt(23)+") "+
		" and is_vatable =1 ";	
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		vFeeVatable.addElement(rs.getString(1));
		vFeeVatable.addElement(rs.getString(2));
	}rs.close();
	
	
	//check if the payment is vatable
	String strORNumber = WI.getInsertValueForDB(request.getParameter("or_number"), true, null);
	strTemp = "select OTHSCH_FEE_INDEX, amount from fa_stud_payment where is_valid =1 and MULTIPLE_PMT_NOTE is null and or_number = "+strORNumber;
	rs = dbOP.executeQuery(strTemp);		
	while(rs.next()){
		if(vFeeVatable.indexOf(rs.getString(1)) == -1)
			continue;
		dAmtVatable += rs.getDouble(2);
	}rs.close();	
	
	strTemp = 
		" select reference_index,amount*no_of_units from FA_STUD_PAYABLE where IS_VALID =1 "+
		" and exists( "+
		" 	select * from FA_STUD_PAYMENT where IS_VALID = 1 "+
		" 	and OR_NUMBER = "+strORNumber+" and payment_index = FA_STUD_PAYABLE.payment_index "+
		"	and MULTIPLE_PMT_NOTE is not null "+
		" ) ";
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		if(vFeeVatable.indexOf(rs.getString(1)) == -1)
			continue;
		dAmtVatable += rs.getDouble(2);	
	}rs.close();
	
	if(dAmtVatable > 0d){
		d12Percent  = dAmtVatable * .12;
		dTaxExempt  = dAmtVatable - d12Percent;
	}
	
}

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


		strAmtTendered = (String)vRetResult.elementAt(48);
		strAmtChange   = (String)vRetResult.elementAt(49);
		if(strAmtTendered.equals("0.00"))
			strAmtTendered = CommonUtil.formatFloat(strAmount,true);
}

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

String[] astrConvertSem = {"Summer","1st","2nd"};

if(strErrMsg == null){

//I need to find if there is NSTP fee paid for this .. 
String strSQLQuery = "select NSTP_PMT_WNU from fa_stud_payment where or_number = '"+request.getParameter("or_number")+"'";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && !strSQLQuery.equals("0.0") )
	strPaymentFor += "<br>NSTP Fee Paid : "+CommonUtil.formatFloat(strSQLQuery, true);


double dAmountTendered = Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""), "0")) + Double.parseDouble(ConversionTable.replaceString(strAmount, ",","")) ;

%>
<br><br><br>
<table cellpadding="0" cellspacing="0" width="816">
 <tr>
 <td>
	<table width="408" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		
		<tr valign="top">
		  <td>&nbsp;</td>
		  <td><%if(bolShowLabel){%>
		    <i>SY/Term</i>&nbsp;
		    <%}else{%>&nbsp;<%}%></td>
		  <td colspan="2"><% if(vRetResult.elementAt(22) != null){
		  strTemp = (String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24)).substring(2);
		  if(vRetResult.elementAt(22).equals("0"))
		  	strTemp = (String)vRetResult.elementAt(24);
		  %>
            <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>, <%=strTemp%>
          <%}%></td>
		  <td><%if(bolShowLabel){%>
		    <i>Date:</i>
		    <%}else{%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}%>
            <%=WI.getStrValue(vRetResult.elementAt(15))%></td>
	    </tr>
		<tr valign="bottom">
		  <td height="18">&nbsp;</td>
		  <td colspan="2">&nbsp;</td>
		  <td width="108">&nbsp;</td>
		  <td>&nbsp;</td>
	    </tr>
		<tr valign="top">
			<td width="12" height="20">&nbsp;</td>
			<td><%if(bolShowLabel){%><i>Student ID</i><%}%></td>
			<td colspan="2"><%=strStudID%></td>
			<td width="142"><%if(bolShowLabel){%><i>Course</i><%}else{%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}%><%=strCourse%></td>
		</tr>
		<tr>
			<td height="18">&nbsp;</td>
			<td width="114" align="left"><em> <%if(bolShowLabel){%> Received from<%}%></em></td>
			<td colspan="3"><%=strStudName%></td>
	    </tr>
		<tr>
			<td height="18">&nbsp;</td>
			<td align="left"><em><%if(bolShowLabel){%>the sum of <%}%></em></td>
			<td colspan="3"><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%>&nbsp;(<%=CommonUtil.formatFloat(strAmount,true)%>)</td>
		</tr>
    </table>
    <table width="408" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="12">&nbsp;</td>
		<td width="413" height="80" valign="top">
				<table width="100%" class="thinborderALL">
					<tr>
					  <td align="center" class="thinborderBOTTOM">&nbsp;</td>
				  </tr>
					<tr>
					  <td width="100%" align="center" class="thinborderBOTTOM"> &nbsp;<%if(bolShowLabel){%><i><u>PAYMENT DESCRIPTION</u></i> <%}%> </td>					</tr>
				   <tr>
					  <td class="thinborderBOTTOM"><span style="height:35.5pt"><%=strPaymentFor%> </span></td>
				  </tr>
      			</table>
 		</td>
    </tr>
    </table>
    <table width="408" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		<tr>
			<td width="12" height="25">&nbsp;</td>
			<td width="250"><u>Amount Tendered:</u> 
			<%=strAmtTendered%>			</td>
			<td width="210" style="font-size:12px; font-weight:bold"><%if(bolIsOkForExam) {%>OK FOR <%=strPmtSchName.toUpperCase()%><%}%></td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>CHECK Amount : 
		  <%if(vRetResult.elementAt(14) != null){
			if(dChkAmt > 0d){%><%=CommonUtil.formatFloat(dChkAmt,true)%>
			<%}else{%>
				<%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
			<%}
			}//show only if check.%>		  </td>
		  <td>
		  <%if(bolShowLabel){%> CHECK&nbsp;Bank/No:<%}else{%><br> <%}%>
		  <%=WI.getStrValue(strBankName)%> <%=WI.getStrValue(strCheckNo)%>		  </td>
	    </tr>
		 <tr>
			<td>&nbsp;</td>
			<td> <%if(bolShowLabel){%>CASH Amount:<%}else{%><br><%}%>
			<%if(vRetResult.elementAt(14) == null){%>
			<%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
			<%}//show only if check.
					else if(dChkAmt > 0d){%>
			<%=CommonUtil.formatFloat(dCashAmt,true)%>
			<%}%></td>	
			<td rowspan="2" valign="top">
				<%if(dAmtVatable > 0d){
					
				%>
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
					<tr>
						<td width="65%">TAX EXEMPT</td>
						<td width="5%">-</td>
						<td width="30%" align="right"><%=CommonUtil.formatFloat(dTaxExempt, 2)%></td>
					</tr>					
					<tr>
						<td>12% VAT SALES</td>
						<td>-</td>
						<td align="right"><%=CommonUtil.formatFloat(d12Percent, 2)%></td>
					</tr>
					<tr>
						<td>TOTAL SALES</td>
						<td>-</td>
						<td align="right" valign="top"><div  style="border-top:solid 1px #000000;"><%=CommonUtil.formatFloat(dAmtVatable,2)%></div></td>
					</tr>
				</table>
				<%}else{%>&nbsp;<%}%>
			</td>	
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>Change:&nbsp;<%=strAmtChange%>	</td>
			</tr>
		<tr>
			<td class="thinborderBOTTOM" height="25">&nbsp;</td>
			<td colspan="2" valign="top" class="thinborderBOTTOM"><%if(bolShowLabel){%>OR Ref no.:<%}%><%=request.getParameter("or_number")%></td>
		</tr>
		<tr>
		  <td class="thinborderBOTTOM" height="25">&nbsp;</td>
		  <td colspan="2" valign="top" class="thinborderBOTTOM">Thank You,
		  <br>
		  <br>
		  <u><%=(String)request.getSession(false).getAttribute("first_name")%></u>
		  <br>
		  &nbsp;&nbsp;&nbsp;&nbsp;Cashier		  </td>
	    </tr>
    </table>
 </td>
 	
 <td>
	<table width="408" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		
		<tr valign="top">
		  <td>&nbsp;</td>
		  <td><%if(bolShowLabel){%>
		    <i>SY/Term</i>&nbsp;
		    <%}else{%>&nbsp;<%}%>
            </td>
		  <td colspan="2"><% if(vRetResult.elementAt(22) != null){
		  strTemp = (String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24)).substring(2);
		  if(vRetResult.elementAt(22).equals("0"))
		  	strTemp = (String)vRetResult.elementAt(24);
		  %>
            <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>, <%=strTemp%>
          <%}%></td>
		  <td><%if(bolShowLabel){%>
		    <i>Date:</i>
		    <%}else{%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}%>
            <%=WI.getStrValue(vRetResult.elementAt(15))%></td>
	    </tr>
		<tr valign="bottom">
		  <td height="18">&nbsp;</td>
		  <td colspan="2">&nbsp;</td>
		  <td width="108">&nbsp;</td>
		  <td>&nbsp;</td>
	    </tr>
		<tr valign="top">
			<td width="12" height="20">&nbsp;</td>
			<td><%if(bolShowLabel){%><i>Student ID</i><%}%></td>
			<td colspan="2"><%=strStudID%></td>
			<td width="142"><%if(bolShowLabel){%><i>Course</i><%}else{%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}%><%=strCourse%></td>
		</tr>
		<tr>
			<td height="18">&nbsp;</td>
			<td width="114" align="left"><em> <%if(bolShowLabel){%> Received from<%}%></em></td>
			<td colspan="3"><%=strStudName%></td>
	    </tr>
		<tr>
			<td height="18">&nbsp;</td>
			<td align="left"><em><%if(bolShowLabel){%>the sum of <%}%></em></td>
			<td colspan="3"><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%>&nbsp;(<%=CommonUtil.formatFloat(strAmount,true)%>)</td>
		</tr>
    </table>
    <table width="408" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="12">&nbsp;</td>
		<td width="413" height="80" valign="top">
				<table width="100%" class="thinborderALL">
					<tr>
					  <td align="center" class="thinborderBOTTOM">&nbsp;</td>
				  </tr>
					<tr>
					  <td width="100%" align="center" class="thinborderBOTTOM"> &nbsp;<%if(bolShowLabel){%><i><u>PAYMENT DESCRIPTION</u></i> <%}%> </td>					</tr>
				   <tr>
					  <td class="thinborderBOTTOM"><span style="height:35.5pt"><%=strPaymentFor%> </span></td>
				  </tr>
      			</table>
 		</td>
    </tr>
    </table>
    <table width="408" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		<tr>
			<td width="12" height="25">&nbsp;</td>
			<td width="250"><u>Amount Tendered:</u>  
			<%=strAmtTendered%>			</td>
			<td width="210" style="font-size:12px; font-weight:bold"><%if(bolIsOkForExam) {%>OK FOR <%=strPmtSchName.toUpperCase()%><%}%></td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>CHECK Amount : 
		  <%if(vRetResult.elementAt(14) != null){
			if(dChkAmt > 0d){%><%=CommonUtil.formatFloat(dChkAmt,true)%>
			<%}else{%>
				<%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
			<%}
			}//show only if check.%>		  </td>
		  <td>
		  <%if(bolShowLabel){%> CHECK&nbsp;Bank/No:<%}else{%><br> <%}%>
		  <%=WI.getStrValue(strBankName)%> <%=WI.getStrValue(strCheckNo)%>		  </td>
	    </tr>
		 <tr>
			<td>&nbsp;</td>
			<td> <%if(bolShowLabel){%>CASH Amount:<%}else{%><br><%}%>
			<%if(vRetResult.elementAt(14) == null){%>
			<%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
			<%}//show only if check.
					else if(dChkAmt > 0d){%>
			<%=CommonUtil.formatFloat(dCashAmt,true)%>
			<%}%></td>	
			<td rowspan="2" valign="top">
				<%if(dAmtVatable > 0d){
					
				%>
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
					<tr>
						<td width="65%">TAX EXEMPT</td>
						<td width="5%">-</td>
						<td width="30%" align="right"><%=CommonUtil.formatFloat(dTaxExempt, 2)%></td>
					</tr>					
					<tr>
						<td>12% VAT SALES</td>
						<td>-</td>
						<td align="right"><%=CommonUtil.formatFloat(d12Percent, 2)%></td>
					</tr>
					<tr>
						<td>TOTAL SALES</td>
						<td>-</td>
						<td align="right" valign="top"><div  style="border-top:solid 1px #000000;"><%=CommonUtil.formatFloat(dAmtVatable,2)%></div></td>
					</tr>
				</table>
				<%}else{%>&nbsp;<%}%>
			</td>	
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>Change:&nbsp;<%=strAmtChange%>	</td>
			</tr>
		<tr>
			<td class="thinborderBOTTOM" height="25">&nbsp;</td> 
			<td colspan="2" valign="top" class="thinborderBOTTOM"><%if(bolShowLabel){%>OR Ref no.:<%}%><%=request.getParameter("or_number")%></td>
		</tr>
		<tr>
		  <td class="thinborderBOTTOM" height="25">&nbsp;</td>
		  <td colspan="2" valign="top" class="thinborderBOTTOM">Thank You,
		  <br>
		  <br>
		  <u><%=(String)request.getSession(false).getAttribute("first_name")%></u>
		  <br>
		  &nbsp;&nbsp;&nbsp;&nbsp;Cashier		  </td>
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
