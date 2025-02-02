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

//System.out.println(vRetResult);
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

String[] astrConvertSem = {"S", "1st Semester", "2nd Semester", "3rd Semester", ""};

if(strErrMsg == null){%>


<table cellpadding="0" cellspacing="0" width="816">
	<tr><td height="80px">&nbsp;</td></tr>
</table>

<table cellpadding="0" cellspacing="0" width="816">
<!--<table cellpadding="0" cellspacing="0" width="100%">-->
 <tr>
 <td>
	<table width="408" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >		
		<tr valign="top">		  	
		  	<td width="110"><%=strStudID%></td>			
		  	<td colspan="2"><%=strStudName%></td>		  	
	    </tr>
		
		<tr valign="top">		  	
		  	<td><%=strDatePaid%></td>			
		  	<td width="168" ><%=strCourse%></td>
		  	<td width="130"><%=WI.fillTextValue("or_number")%></td>
	    </tr>	
		
		<tr valign="top">				
		  	<td colspan="2">S.Y. 
			<% if(vRetResult.elementAt(22) != null){
		  		strTemp = (String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24));
		  		if(vRetResult.elementAt(22).equals("0"))
		  			strTemp = (String)vRetResult.elementAt(24);
			%>
            <%=strTemp%>, <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>
          	<%}%></td>
			<td>&nbsp;</td>
		</tr>	
		
		
		<tr><td height="60px" colspan="5">&nbsp;<br>
		<%if(strBankName != null && strCheckNo != null) {%>
			<%=strBankName%>/<%=strCheckNo%>: &nbsp;&nbsp;<%=CommonUtil.formatFloat(dChkAmt, true)%>
		<%}%>
		</td></tr>		
    </table>
	
	
     <table width="408" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >		
		<tr>			
			<!-------------------DRI IBUTANG ANG PAYMENT FOR-------------------------------->
			<td colspan="2">&nbsp;<%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%></td>
			<!--------------AMOUNT PAID------------------>			
		</tr>
		
		<tr>	
			<%
				if(vRetResult.elementAt(14) == null){
					strTemp = " &nbsp;CASH:";					
			  	}//show only if check.
				else {//it can be check only or cash and check
					if(dCashAmt > 0d){
						strTemp = " &nbsp;CASH: ";
					}
					strTemp = " &nbsp;CHECK:";
			}%>	
				
			<td width="70"><%=strTemp%></td>
			<td>
				<%if(vRetResult.elementAt(14) == null){%>
				&nbsp; <%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
			  	<%}//show only if check.
				else {//it can be check only or cash and check
					if(dCashAmt > 0d){%>
						&nbsp; <%=CommonUtil.formatFloat(dCashAmt,true)%>&nbsp;&nbsp;
					<%}%>
					&nbsp; <%=CommonUtil.formatFloat(dChkAmt,true)%>
				<%}%>
			</td>
		</tr>
		
    </table>
	
	
    <table width="408" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		<tr><td colspan="3">&nbsp;</td></tr>
		
		<tr><td colspan="3" height="50">&nbsp;</td></tr>
		
		 <tr><td colspan="3"><%=strPaymentFor%></td></tr>
		 
		<tr><td colspan="3">&nbsp;</td></tr>
		<tr><td class="thinborderBOTTOM" height="85" colspan="2">&nbsp;</td></tr>
		
		<tr>			
			<td height="25" width="200">&nbsp;</td>
			<td align="center" valign="bottom">&nbsp;<%=CommonUtil.formatFloat(strAmount,true)%></td>
		</tr>
		<tr>		  
		  <td height="30">&nbsp;</td>
		  <td align="right" valign="bottom"><%=request.getSession(false).getAttribute("first_name")%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	    </tr>	
    </table>
 </td>
 
 
 
 
 
 
 
 
 
 <!---------------------------------------------RIGHT SIDE------------------------------------------------------------>
 
 
 <td>
	<table width="408" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >		
		<tr valign="top">
			<td width="15">&nbsp;</td>		  	
		  	<td width="111"><%=strStudID%></td>			
		  	<td colspan="2"><%=strStudName%></td>		  	
	    </tr>
		
		<tr valign="top">
			<td width="15">&nbsp;</td>		  	
		  	<td><%=strDatePaid%></td>			
		  	<td width="152" ><%=strCourse%></td>
		  	<td width="130"><%=WI.fillTextValue("or_number")%></td>
	    </tr>	
		
		<tr valign="top">	
			<td width="15">&nbsp;</td>			
		  	<td colspan="2">S.Y. 
			<% if(vRetResult.elementAt(22) != null){
		  		strTemp = (String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24));
		  		if(vRetResult.elementAt(22).equals("0"))
		  			strTemp = (String)vRetResult.elementAt(24);
			%>
            <%=strTemp%>, <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>
          	<%}%></td>
			<td>&nbsp;</td>
		</tr>	
		
		
		<tr><td height="60px" colspan="5">&nbsp;<br>
		<%if(strBankName != null && strCheckNo != null) {%>
			<%=strBankName%>/<%=strCheckNo%>: &nbsp;&nbsp;<%=CommonUtil.formatFloat(dChkAmt, true)%>
		<%}%>

</td></tr>		
    </table>
	
	
     <table width="408" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >		
		<tr>
			<td width="15">&nbsp;</td>			
			<!-------------------DRI IBUTANG ANG PAYMENT FOR-------------------------------->
			<td colspan="2">&nbsp;<%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%></td>
			<!--------------AMOUNT PAID------------------>			
		</tr>
		
		<tr>	
			<td width="15">&nbsp;</td>
			<%
				if(vRetResult.elementAt(14) == null){
					strTemp = " &nbsp;CASH:";					
			  	}//show only if check.
				else {//it can be check only or cash and check
					if(dCashAmt > 0d){
						strTemp = " &nbsp;CASH: ";
					}
					strTemp = " &nbsp;CHECK:";
			}%>	
				
			<td width="70"><%=strTemp%></td>
			<td>
				<%if(vRetResult.elementAt(14) == null){%>
				&nbsp; <%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
			  	<%}//show only if check.
				else {//it can be check only or cash and check
					if(dCashAmt > 0d){%>
						&nbsp; <%=CommonUtil.formatFloat(dCashAmt,true)%>&nbsp;&nbsp;
					<%}%>
					&nbsp; <%=CommonUtil.formatFloat(dChkAmt,true)%>
				<%}%>
			</td>
		</tr>
		
    </table>
	
	
    <table width="408" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		<tr><td width="15">&nbsp;</td><td colspan="3">&nbsp;</td></tr>
		
		<tr><td width="15" height="50">&nbsp;</td><td colspan="3">&nbsp;</td></tr>
		
		 <tr><td width="15">&nbsp;</td><td colspan="3"><%=strPaymentFor%></td></tr>
		 
		<tr><td width="15">&nbsp;</td><td colspan="3">&nbsp;</td></tr>
		<tr><td width="15">&nbsp;</td><td class="thinborderBOTTOM" height="85" colspan="2">&nbsp;</td></tr>
		
		<tr>
			<td width="15">&nbsp;</td>			
			<td height="25" width="200">&nbsp;</td>
			<td align="center" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=CommonUtil.formatFloat(strAmount,true)%></td>
		</tr>
		<tr>		
			<td width="15">&nbsp;</td>  
		  	<td height="30">&nbsp;</td>
		  	<td align="right" valign="bottom"><%=request.getSession(false).getAttribute("first_name")%></td>
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
