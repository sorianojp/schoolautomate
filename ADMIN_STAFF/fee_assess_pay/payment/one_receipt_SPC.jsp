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


//print permit.. 
Vector vSubjectsTaken = new Vector();
String strPmtSchName  = null;

String strSQLQuery     = null;

String strTellerName = (String)request.getSession(false).getAttribute("userIndex");
if(strTellerName != null) {
	strTellerName = "select fname from user_table where user_index = "+strTellerName;
	strTellerName = dbOP.getResultOfAQuery(strTellerName, 0).toLowerCase();
}

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
			if(vRetResult.elementAt(27).equals("0")) {
				strPaymentFor = "Downpayment";
				strSQLQuery  = "select payment_mode from fa_stud_pmtmethod where user_index = "+vRetResult.elementAt(0) +
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

boolean bolTuitionPmt = false;//add to handle tuition-non tuition payment.
if(vRetResult.elementAt(27) != null && vRetResult.elementAt(28) != null && !((String)vRetResult.elementAt(4)).equals("0"))
	bolTuitionPmt = true;
//System.out.println(bolTuitionPmt);

if(vRetResult != null && vRetResult.elementAt(0) != null && vRetResult.elementAt(4) != null && (((String)vRetResult.elementAt(4)).equals("0") || bolTuitionPmt) 
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
}
		//System.out.println(vRetResult.elementAt(33));
		//System.out.println(vRetResult.elementAt(27));
		//System.out.println(vRetResult.elementAt(28));
		//System.out.println(vRetResult.elementAt(4));

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


String[] astrConvertSem = {"S", "1st Semester", "2nd Semester", "3rd Semester", ""};



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
 <td valign="top">
	<table width="350" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >		
		<tr valign="top">
		  	<td colspan="2" align="right"><%=WI.fillTextValue("or_number")%></td>		  	
	    </tr>
		
		<tr valign="top">
		  	<td align="right" colspan="2" height="25" valign="bottom"><%=strDatePaid%></td>
	    </tr>	
		
		<tr valign="top">	
			<td width="80">&nbsp;</td>				
		  	<td height="25" valign="bottom" style="font-size:12px;"><%=strStudName%></td>
		</tr>	
		
		<tr><td colspan="2">&nbsp;</td></tr>
		<tr><td colspan="2" height="35">&nbsp;</td></tr>
				
    </table>	
	
    <table width="350" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		
		<%if(vMultiplePmtInfo.size() == 0) {%>
			<tr>
				<td height="270px" align="left" valign="top"><%=strPaymentFor%></td>
				<td valign="top" align="right"><%=CommonUtil.formatFloat(strAmount,true)%></td>
			</tr>
  <%}else{%>
			<tr>
				<td height="270px" align="left" valign="top" colspan="2">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<%for(int a = 0; a < vMultiplePmtInfo.size(); a += 2) {%>
							<tr>
								<td width="75%"><%=vMultiplePmtInfo.elementAt(a)%></td>
								<td align="right" width="25%"><%=vMultiplePmtInfo.elementAt(a + 1)%></td>
							</tr>
						<%}%>
					</table>
				
				
				</td>
			</tr>
		<%}%>
		<tr>
		  <td valign="top" align="left" width="75%"><%=WI.getStrValue(strCheckNo)%></td>
		  <td valign="top" align="right" width="25%">&nbsp;</td>
	    </tr>
		<tr>
		  <td valign="top" align="left">&nbsp;</td>
		  <td valign="top" align="right">&nbsp;</td>
	    </tr>
		<tr><td class="thinborderBOTTOM" valign="bottom" style="font-size:9px">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strTellerName).toLowerCase()%></td>
          <td class="thinborderBOTTOM" valign="bottom" align="right"><%=CommonUtil.formatFloat(strAmount,true)%></td>
		</tr>
    </table>
 </td>
 
 
 
 
 
 
 
 
 
 <!---------------------------------------------RIGHT SIDE------------------------------------------------------------>
 
 
 <td valign="top">
	<table width="350" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >		
		<tr valign="top">
			<td width="15">&nbsp;</td>
		  	<td colspan="2" align="right"><%=WI.fillTextValue("or_number")%></td>		  	
	    </tr>
		
		<tr valign="top">
			<td width="15">&nbsp;</td>
		  	<td align="right" colspan="2" valign="bottom" height="25"><%=strDatePaid%></td>
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
			<%
			if(vMultiplePmtInfo.size() == 0)
				strTemp = "2";
			else
				strTemp = "3";
			%>
			<td height="240px" align="left" valign="top" colspan="<%=strTemp%>">
			<%if(vMultiplePmtInfo.size() > 0) {%>
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
			  <%for(int a = 0; a < vMultiplePmtInfo.size(); a += 2) {%>
						<tr>
							<td width="75%"><%=vMultiplePmtInfo.elementAt(a)%></td>
							<td align="right" width="25%"><%=vMultiplePmtInfo.elementAt(a + 1)%></td>
						</tr>
					<%}%>
				</table>
			<%}else{%>
			  <%=strPaymentFor%>
			<%}
			
			
			if(vSubjectsTaken != null && vSubjectsTaken.size() > 0) {%>

				<table width="100%" cellpadding="0" cellspacing="0">
                	<tr><td colspan="4">&nbsp;</td>
					<tr>
						<td colspan="4" style="font-weight:bold"><%=strPmtSchName.toUpperCase()%> Permit<br>&nbsp;</td>
					</tr>
					<%while(vSubjectsTaken.size() > 0) {%>
						<tr>
							<td width="27%" style="font-size:9px;"><%=vSubjectsTaken.remove(0)%></td>
							<td width="24%">_____</td>
							<td width="22%" style="font-size:9px;"><%if(vSubjectsTaken.size() > 0) {%><%=vSubjectsTaken.elementAt(0)%><%}%></td>
							<td width="27%"><%if(vSubjectsTaken.size() > 0) {vSubjectsTaken.remove(0);%>_____<%}%></td>
						</tr>
					<%}%>
			  </table>
			<%}%></td>
			
			
			 <%if(vMultiplePmtInfo.size() == 0) {%>
			 <td valign="top" align="right"><%=CommonUtil.formatFloat(strAmount,true)%></td>
			 <%}%>
            <!--<br><br><br><br><br>-->
		</tr>
		<tr>
		  <td valign="top" align="left"><%=WI.getStrValue(strCheckNo)%></td>
		  <td valign="top" align="right">&nbsp;</td>
	    </tr>
		<tr>
		  <td valign="top" align="right">
		   <%if(vRetResult.elementAt(0) != null && vRetResult.elementAt(4) != null && (((String)vRetResult.elementAt(4)).equals("0") || bolTuitionPmt)) {%>
				Tuition Balance: <%=CommonUtil.formatFloat(dOutStandingBalance, true)%>			
			<%}%></td>
		  <td valign="top" align="right">&nbsp;</td>
	    </tr>
		<tr>
		  <td valign="top" align="left" height="30">&nbsp;</td>
		  <td valign="top" align="right">&nbsp;</td>
	    </tr>
		<tr><td class="thinborderBOTTOM" valign="bottom" style="font-size:9px">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strTellerName).toLowerCase()%></td>
          <td class="thinborderBOTTOM" valign="bottom" align="right">&nbsp;</td>
		  <td class="thinborderBOTTOM" valign="bottom" align="right"><%=CommonUtil.formatFloat(strAmount,true)%></td>
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
