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
	font-size: 7px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 7px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 7px;
}

TABLE.thinborderALL{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 7px;

}
-->
</style>
</head>

<body leftmargin="0" topmargin="0" bottommargin="0" onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	utility.CommonUtil comUtil = new utility.CommonUtil();

	String strErrMsg = null;
	String strTemp = null;
	boolean bolIsFine = false;
	boolean bolIsDownPmt =false;
enrollment.ReportEnrollment reportEnrl = new enrollment.ReportEnrollment();
enrollment.SubjectSection SS = new enrollment.SubjectSection();
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
String strSQLQuery   = null;
String strPaymentFor = null;
String strPmtMode    = null;
String strPmtSchName = null;
String strAmtTendered = null;
String strAmtChange   = null;

String strAdmSlipNumber = null;

double dChkAmt = 0d; double dCashAmt = 0d; String strYrLevel = null;

boolean bolIsSupplies = false;

boolean bolIsCavite = false;
boolean bolIsICA    = false;

Vector vSubjectsTaken = new Vector();

strTemp = "select info5 from sys_info";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp != null && strTemp.equals("Cavite"))
	bolIsCavite = true;
if(strTemp != null && strTemp.equals("ICA"))
	bolIsICA = true;


FAPayment faPayment = new FAPayment();
Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));

if(vRetResult == null) {
	//may be basic payment.
	vRetResult = new enrollment.FAElementaryPayment().viewPmtDetail(dbOP, request.getParameter("or_number"));
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
			int iStudIndex = Integer.parseInt((String)vRetResult.elementAt(0));
			strStudName     = (String)vRetResult.elementAt(18);
			strSQLQuery = comUtil.getName(dbOP, iStudIndex, 4);
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

		strPmtSchName = (String)vRetResult.elementAt(28);
		
		if(strPmtSchName != null && vRetResult.elementAt(0) != null) {
			Vector vInstallmentInfo = new enrollment.FAAssessment().getPaymentDueForAnExam(dbOP, (String)vRetResult.elementAt(0),
									  (String)vRetResult.elementAt(23), (String)vRetResult.elementAt(24), 
									  (String)vRetResult.elementAt(21), 
									  (String)vRetResult.elementAt(22), null, strPmtSchName);
	
			if(vInstallmentInfo != null && vInstallmentInfo.elementAt(1).equals("0")) {
				strTemp = (String)vRetResult.elementAt(4);
				if(strTemp != null && strTemp.equals("0")) {//permit is OK now.
					strAdmSlipNumber = reportEnrl.autoGenAdmSlipNum(dbOP,(String)vRetResult.elementAt(0),(String)vRetResult.elementAt(27),
										(String)vRetResult.elementAt(23),(String)vRetResult.elementAt(22),
										(String)request.getSession(false).getAttribute("userIndex"));
				
					CommonUtil.setSubjectInEFCLTable(dbOP);
					
					strSQLQuery = "select sub_code, sub_sec_index from enrl_final_cur_list "+
									"join subject on (subject.sub_index = efcl_sub_index) "+
									" where user_index = "+vRetResult.elementAt(0)+" and is_temp_stud = 0 and sy_from = "+
									(String)vRetResult.elementAt(23)+" and current_semester = "+(String)vRetResult.elementAt(22)+
									" and is_valid = 1 order by sub_code ";
					java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
					while(rs.next()){
						vSubjectsTaken.addElement(rs.getString(1));
						vSubjectsTaken.addElement(rs.getString(2));
					}
					rs.close();
				}
			}
		}

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";



if(strErrMsg == null){%>
<table border="0" cellspacing=0 cellpadding=0 width="700px">
<tr>
  <td width="60%" height="95" valign="top">
  	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr valign="top" align="center">		
			<td height="2" colspan="3" align="right"><%if(!bolIsCavite){%><%=request.getParameter("or_number")%><%}%></td>
		</tr>
		<tr valign="top">
			<td height="2" width="20%"><%=strStudID%></td>		
			<td><%=strStudName%></td>
			<td width="20%"><%=strCourse%></td>
		</tr>
		<tr valign="top">
		  <td height="2">&nbsp;</td>
		  <td colspan="2">&nbsp;</td>
	    </tr>
		<tr valign="top">
		  <td height="2"><%=CommonUtil.formatFloat(strAmount,true)%></td>
		  <td colspan="2"><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strAmount),"Pesos","Centavos")%></td>
	  </tr>
	</table>
	<table border=0 cellspacing=0 cellpadding=0 width="100%">
		<tr valign="top">
		  <td width="46%" height="25" style="padding-left:40px;">
			 <%=strPaymentFor%></td>
		  <td>
			
			  <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>
			  <br>
			  <%=(String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24)).substring(2)%>		   
	      </td>
	  		<td width="28%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" >
					<tr>
						<td align="right" style="font-size:8px;"><%//=CommonUtil.formatFloat(strAmount,true)%></td>
				  </tr>
					<tr>
						<td align="right" style="font-size:8px;">&nbsp;</td>
				  </tr>
					<tr>
						<td align="right" style="font-size:8px;"><%//=CommonUtil.formatFloat(strAmount,true)%></td>
				  </tr>
					<tr>
						<td align="right" style="font-size:8px;">&nbsp;</td>
				  </tr>
				</table>	  
			</td>
  		</tr>
	</table>
<%
double dAmountTendered = Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""), "0")) + Double.parseDouble(ConversionTable.replaceString(strAmount, ",","")) ;
%>
	<table border=0 cellspacing=0 cellpadding=0 width="100%">
		<tr valign="top" align="center">
			<td height="25" width="12%">&nbsp;</td>
			<td width="23%" align="left"><%=strAmtTendered%>
			<br>
			<%		
			if(vRetResult.elementAt(14) == null)
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(11),true);
			else if(dChkAmt > 0d)
				strTemp = CommonUtil.formatFloat(dChkAmt,true)	;	
			%>
			<%=strTemp%>		
			<br>
			<%if(strAmtTendered != null && !strAmtTendered.equals("0.00") && strAmtChange != null) {%>
				<%=strAmtChange%>
			<%}%>
		  </td>
			
			<td width="25%" valign="top"><br><br><%=(String)request.getSession(false).getAttribute("first_name")%></td>
			<td width="10%" valign="top"><br><br><%=strDatePaid%></td>
			<td align="left">
			
			<br><br>
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
					<tr align="center">
						<td width="50%" style="font-size:11px;">&nbsp;&nbsp;&nbsp;<%=request.getParameter("or_number")%></td>
						<td width="50%" align="right" style="font-size:11px;">&nbsp;&nbsp;&nbsp;<%=CommonUtil.formatFloat(strAmount,true)%></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>



	


<td width="30%" valign="top"  align="right">
	<table border="0" cellspacing="0" cellpadding="0" width="98%">
		<tr>
			<td width="42%"><strong><u><%=WI.getStrValue(strPmtSchName).toUpperCase()%></u></strong></td>
			<td width="58%" align="right" style="font-size:9px;"><%=strAdmSlipNumber%></td>
		</tr>
		<tr><td colspan="2" height="2"></td></tr>
	</table>
	
	<table border="0" cellspacing="0" cellpadding="0" width="98%">		
		<tr>
			<td colspan="2" style="padding-left:20px;"><%=strStudName%></td>
		</tr>
		<tr>
			<td width="37%" align="right" valign="middle"><%=strCourse%></td>
		    <td width="63%" align="right" valign="middle"><% if(vRetResult.elementAt(22) != null){%>
              <%=(String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24)).substring(2)%>/
              <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>
            <%}%>          </td>
	    </tr>		
	</table>	
	<table border="0" cellspacing="0" cellpadding="0" width="98%">
		
		<tr>
			<td width="36%" height="2"></td>
		    <td width="31%"></td>
		    <td width="33%"></td>
	    </tr>
		<%
		if (vSubjectsTaken != null && vSubjectsTaken.size() >0){
			for(int iCtr = 0; iCtr < vSubjectsTaken.size(); iCtr+=2){
		
		%>
		<tr>
			<td valign="bottom"><%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP,request,(String)vSubjectsTaken.elementAt(iCtr +1 ) ,(String)vRetResult.elementAt(23),(String)vRetResult.elementAt(22),"EAC"), "&nbsp;")%></td>
		    <td valign="bottom"><%=vSubjectsTaken.elementAt(iCtr)%></td>
		    <td align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%"></div></td>
		    <%}
		}%>
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
