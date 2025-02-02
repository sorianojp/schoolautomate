<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>One Receipt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

@page {
	size:8in 5.5in; 
	margin:.1in .1in .1in .5in; 
}

@media print { 
  @page {
		size:8in 5.5in; 
		margin:.1in .1in .1in .5in;
		
		/*
		margin:25px 50px 75px 100px;
		 top margin is 25px
		 right margin is 50px
		 bottom margin is 75px
		 left margin is 100px
		*/
	}
}

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

<body topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" onLoad="window.print();">
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

boolean bolIsBasic   = false; String strYrLevel = null;

String strSYTermInfo = null;
String[] astrConvertSem = {"SUMMER","1<sup>st</sup> Sem","2<sup>nd</sup> Sem","3<sup>rd</sup> Sem"};
String[] astrYearLevel = {"","<sup>st</sup> Year","<sup>nd</sup> Year","<sup>rd</sup> Year","<sup>th</sup> Year","<sup>th</sup> Year","<sup>th</sup> Year"};
double dChkAmt = 0d; double dCashAmt = 0;



String strAmtTendered = null;
String strAmtChange   = null;


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
		//get sy/term of payment.. 
		if(vRetResult.elementAt(22) != null){
				strSYTermInfo = (String)vRetResult.elementAt(23) + "-"+(String)vRetResult.elementAt(24);
				//if(vRetResult.elementAt(22).equals("0"))
				//	strSYTermInfo = (String)vRetResult.elementAt(24);
				strSYTermInfo = strSYTermInfo + "/ "+astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))];
		}

		strStudID     = WI.getStrValue((String)vRetResult.elementAt(25),"");
		//name
		if( vRetResult.elementAt(0) != null)
			strStudName     = (String)vRetResult.elementAt(18);
		else
			strStudName     = (String)vRetResult.elementAt(1);

		strCourse     = WI.getStrValue((String)vRetResult.elementAt(35),"");
		if(strCourse.length() == 0 && vRetResult.elementAt(21) != null) {//basic student.
			int iYear  = Integer.parseInt((String)vRetResult.elementAt(21));
			strCourse  = dbOP.getBasicEducationLevel(iYear);
			strCourse = strCourse.substring(strCourse.indexOf("-") + 1);
			bolIsBasic = true;
		}
		else {
			strYrLevel = (String)vRetResult.elementAt(21);
			if(strYrLevel != null)
				strCourse = strCourse + "/ "+strYrLevel+astrYearLevel[Integer.parseInt(strYrLevel)];
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
		
		dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
		dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));

		strAmtTendered = (String)vRetResult.elementAt(48);
		strAmtChange   = (String)vRetResult.elementAt(49);

		if(strAmtTendered.equals("0.00"))
			strAmtTendered = CommonUtil.formatFloat(strAmount,true);



}



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

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

if(strErrMsg == null){%>

<table cellpadding="0" cellspacing="0" border="0" width="768px">
	<tr>
		<td valign="top" width=360>
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
				<tr><td height="90" colspan="5">&nbsp;</td></tr>
				<tr><td colspan="3" align="right" style="padding-right:20px;"><%=strDatePaid%></td></tr>
				<tr><td colspan="3" height="10"></td></tr>
				<tr><td colspan="3" style="padding-left:85px;"><%=strStudName%></td></tr>
				<%
				strTemp = WI.getStrValue(new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos"));					
				Vector vTemp = CommonUtil.convertCSVToVector(strTemp," ",true);				
				strTemp = "";
				strErrMsg = "";
				if(vTemp != null && vTemp.size() > 0){
					while(vTemp.size() > 0){
						if(strErrMsg.length() < 35)
							strErrMsg += " " +(String)vTemp.remove(0);
						else
							strTemp += " " +(String)vTemp.remove(0);
					}				
				}
				%>
				<tr>
				   <td height="15" colspan="3"></td>
			   </tr>
				<tr><td colspan="3" style="padding-left:75px;"><%=strErrMsg%></td></tr>
				<tr>
				   <td colspan="3" height="12"></td>
			   </tr>
				<tr>
					<td colspan="2"><%=strTemp%></td>
				   <td width="28%" align="right" style="padding-right:20px;"><%=CommonUtil.formatFloat(strAmount,true)%></td>
				</tr>
			<tr>
				   <td height="20" colspan="3" style="padding-left:50px;">&nbsp;</td>
			   </tr>	
			<%
			int iCount = 0;
			if(vMultiplePmtInfo.size() > 0){			
				for(int a = 0; a < vMultiplePmtInfo.size(); a += 2, iCount++) {%>
					<tr>
						<td width="67%"><%=vMultiplePmtInfo.elementAt(a)%></td>
						<td width="5%" align="center">=</td>
						<td width="28%" align="right" style="padding-right:20px;"><%=vMultiplePmtInfo.elementAt(a + 1)%></td>
					</tr>
				<%}				
			}else{
				iCount = 1;
			%>
					<tr>
						<td width="67%"><%=strPaymentFor%></td>
						<td width="5%" align="center">=</td>
						<td width="28%" align="right" style="padding-right:20px;"><%=CommonUtil.formatFloat(strAmount,true)%></td>
					</tr>
			<%}
			
			for(int i=iCount;i<17;i++){
			%>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
			<%}%>
				<tr>
					<td colspan="2" height="30" valign="bottom"><%=request.getSession(false).getAttribute("first_name")%></td>
				   <td width="28%" align="right" valign="bottom" style="padding-right:20px;"><%=CommonUtil.formatFloat(strAmount,true)%></td>
				</tr>
			</table>		
		</td>
		<td>&nbsp;</td>
		<td valign="top" width=360>
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
				<tr><td height="90" colspan="5">&nbsp;</td></tr>
				<tr><td colspan="3" align="right" style="padding-right:20px;"><%=strDatePaid%></td></tr>
				<tr><td colspan="3" height="10"></td></tr>
				<tr><td colspan="3" style="padding-left:85px;"><%=strStudName%></td></tr>
				<%
				strTemp = WI.getStrValue(new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos"));					
				vTemp = CommonUtil.convertCSVToVector(strTemp," ",true);				
				strTemp = "";
				strErrMsg = "";
				if(vTemp != null && vTemp.size() > 0){
					while(vTemp.size() > 0){
						if(strErrMsg.length() < 35)
							strErrMsg += " " +(String)vTemp.remove(0);
						else
							strTemp += " " +(String)vTemp.remove(0);
					}				
				}				
				%>
				<tr>
				   <td height="15" colspan="3"></td>
			   </tr>
				<tr><td colspan="3" style="padding-left:75px;"><%=strErrMsg%></td></tr>
				<tr>
				   <td colspan="3" height="12"></td>
			   </tr>
				<tr>
					<td colspan="2"><%=strTemp%></td>
				   <td width="28%" align="right" style="padding-right:20px;"><%=CommonUtil.formatFloat(strAmount,true)%></td>
				</tr>
			<tr>
				   <td height="20" colspan="3" style="padding-left:50px;">&nbsp;</td>
			   </tr>	
			<%
			iCount = 0;
			if(vMultiplePmtInfo.size() > 0){			
				for(int a = 0; a < vMultiplePmtInfo.size(); a += 2, iCount++) {%>
					<tr>
						<td width="67%"><%=vMultiplePmtInfo.elementAt(a)%></td>
						<td width="5%" align="center">=</td>
						<td width="28%" align="right" style="padding-right:20px;"><%=vMultiplePmtInfo.elementAt(a + 1)%></td>
					</tr>
				<%}				
			}else{
				iCount = 1;
			%>
					<tr>
						<td width="67%"><%=strPaymentFor%></td>
						<td width="5%" align="center">=</td>
						<td width="28%" align="right" style="padding-right:20px;"><%=CommonUtil.formatFloat(strAmount,true)%></td>
					</tr>
			<%}
			
			for(int i=iCount;i<17;i++){
			%>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
			<%}%>
				<tr>
					<td colspan="2" height="30" valign="bottom"><%=request.getSession(false).getAttribute("first_name")%></td>
				   <td width="28%" align="right" valign="bottom" style="padding-right:20px;"><%=CommonUtil.formatFloat(strAmount,true)%></td>
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
