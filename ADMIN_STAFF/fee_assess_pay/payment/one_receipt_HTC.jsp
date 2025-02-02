<%


String strORNumber    = request.getParameter("or_number");
if(strORNumber == null || strORNumber.length() == 0){
	strORNumber = (String)request.getSession(false).getAttribute("or_number");
	if(strORNumber != null)	{
		request.getSession(false).removeAttribute("or_number");
		response.sendRedirect("./one_receipt_HTC.jsp?or_number="+strORNumber);
		return;
	}
}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>One Receipt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--

@page {
	size:6.75in 4in; 
	margin:0in 0in 0in 0in; 
}

@media print { 
  	@page {
		size:6.75in 4in; 
		margin:0in 0in 0in 0in; 
	}
}

body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight:bold;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight:bold;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight:bold;
}

TABLE.thinborderALL {
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight:bold;
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
int iIndexOf = 0;

//print permit.. 
Vector vSubjectsTaken = new Vector();
String strPmtSchName  = null;
String strRemarks     = null;
String strSQLQuery    = null;


java.sql.ResultSet rs = null;
	
String[] astrConvertSem = {"Summer", "1st Sem", "2nd Sem", "3rd Sem", ""};
String[] astrConvertSem2 = {"Summer", "1st", "2nd", "3rd", ""};
String strTransationDur = null;//Duration taken for this Transcation.. 

String strTellerName = null;

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
		   iIndexOf = strBankName.indexOf("(");
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

if(vRetResult != null && vRetResult.size() > 0){
	strTemp = " select fname, mname, lname from FA_STUD_PAYMENT "+
			" join USER_TABLE on (USER_TABLE.USER_INDEX = FA_STUD_PAYMENT.CREATED_BY) "+
			" where OR_NUMBER = "+WI.getInsertValueForDB(strORNumber, true, null);
	rs = dbOP.executeQuery(strTemp);
	if(rs.next())
		strTellerName = WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 4);
	rs.close();
}

boolean bolTuitionPmt = false;//add to handle tuition-non tuition payment.
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(27) != null && vRetResult.elementAt(28) != null && !((String)vRetResult.elementAt(4)).equals("0"))
	bolTuitionPmt = true;
	
String strTimePaid = null;
strTemp = "select create_time from FA_STUD_PAYMENT where IS_VALID = 1 and OR_NUMBER = "+WI.getInsertValueForDB(WI.fillTextValue("or_number"), true, null);
rs = dbOP.executeQuery(strTemp);
if(rs.next())
	strTimePaid = CommonUtil.convert24HRTo12Hr(rs.getDouble(1));
rs.close();	
	
//strTemp = "select PMT_SCH_INDEX from FA_STUD_PAYMENT where IS_VALID =1 and OR_NUMBER = "+WI.getInsertValueForDB(strORNumber, true, null);
//strTemp = dbOP.getResultOfAQuery(strTemp, 0);
//if(strTemp != null && Integer.parseInt(strTemp) >= 0)
//	bolTuitionPmt = true;
	
//if(bolTuitionPmt)	
//	strPaymentFor = "Matriculation SY";
	
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



if(vRetResult != null && vRetResult.size() > 42)
	strRemarks = (String)vRetResult.elementAt(42);




if(strErrMsg == null){%>

<table width="875" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="250" valign="top">
		<table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
				<td height="180" valign="top">
					<table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
						<tr><td colspan="2" height="16"></td></tr>
						<%if(vMultiplePmtInfo.size() == 0) {%>
							<tr>			
								<td width="55%" align="left" valign="top"><%=strPaymentFor%></td>
								<td width="45%" align="right" valign="top"><%=CommonUtil.formatFloat(strAmount,true)%></td>
							</tr>
						<%}else{%>
							<tr>
								<td align="left" valign="top" colspan="2">
									<table width="100%" cellpadding="0" cellspacing="0" border="0">
										<%for(int a = 0; a < vMultiplePmtInfo.size(); a += 2) {%>
											<tr>
												<td width="55%"><%=vMultiplePmtInfo.elementAt(a)%></td>
												<td align="right" width="45%"><%=vMultiplePmtInfo.elementAt(a + 1)%></td>
											</tr>
										<%}%>
									</table>
								
								
								</td>
							</tr>
						<%}%>
							<tr>			
								<td width="55%" align="left" valign="top">TOTAL</td>
								<td width="45%" align="right" valign="top"><%=CommonUtil.formatFloat(strAmount,true)%></td>
							</tr>
					</table>
				</td>
			</tr>
			<tr>
			
				<td height="180" valign="top">
					<table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
						<tr>
							<td align="center"><%if(dCashAmt > 0){%>X<%}%></td>
							<td align="center"><%if(dChkAmt > 0){%>X<%}%></td>
						</tr>
					</table>
				</td>
			
				
			</tr>
		</table>
		
		</td>
		<td width="625" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr><td height="22" colspan="2" align="right">&nbsp;</td></tr>
				<tr>
					<%
					strTemp  = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))] + ", "+ (String)vRetResult.elementAt(23)+ "-"+(String)vRetResult.elementAt(24);
					%>
					<td height="20" colspan="2" align="right"><%=strTemp%></td>
				</tr>
				<tr>
				    <td height="17" colspan="2" align="right"><%=strDatePaid%> <%=strTimePaid%></td>
			    </tr>
				<tr>
				    <td valign="top" height="20" colspan="2" style="padding-left:170px;"><%=strStudName%></td>
			    </tr>
				<tr>
				    <td height="26" colspan="2" align="right">&nbsp;</td>
			    </tr>
				<%
				iIndexOf = 0;
				strErrMsg = "";
				strTemp = new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos");
				if(strTemp != null && strTemp.length() > 28){
					strErrMsg = strTemp.substring(0, 28);
					iIndexOf = strErrMsg.lastIndexOf(" ");
					strErrMsg = strErrMsg.substring(0, iIndexOf);
					strTemp = strTemp.substring(iIndexOf + 1);
				}
					
				%>
				<tr>
				    <td height="20" colspan="2" style="padding-left:190px;"><%=strErrMsg%></td>
			    </tr>
				<tr>
					<td height="20" style="padding-left:80px;"><%=strTemp%></td>
				    <td height="20" align="right" style="padding-right:40px;"><%=CommonUtil.formatFloat(strAmount,true)%></td>
			        
				</tr>
				<tr>
				    <td height="20" colspan="2" style="padding-left:240px;"><%=WI.getStrValue(strCourse)%></td>
			    </tr>
				<tr>
				    <td height="35" colspan="2" style="padding-left:60px;">&nbsp;</td>
			    </tr>
								
				<tr>
				    <td width="52%" height="20">&nbsp;</td>
			        <td width="48%" align="center"><%=WI.getStrValue(strTellerName)%></td>
				</tr>
				<tr>
				    <td height="15"></td>
				    <td align="center"></td>
			    </tr>
				<tr>
				    <td height="20">&nbsp;</td>
				    <td align="center">OR# <%=strORNumber%></td>
			    </tr>
			</table>
		</td>
	</tr>
</table>


		
	
    


<%}else{//print error msg

%>
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
