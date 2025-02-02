<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCLDH = strSchCode.startsWith("CLDH");
boolean bolIsAUF = strSchCode.startsWith("AUF");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED Enrollment and billing statement</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

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


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	TD.thinborderBOTTOM {   
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }


</style>
</head>
<script>
function Toggle() {
	if(!confirm('Please click OK to show/hide payment information.'))
		return;
	if(document.form_.show_pmt_info.value == '1')
		document.form_.show_pmt_info.value = '0'
	else
		document.form_.show_pmt_info.value = '1'
	document.form_.submit();
}
</script>
<body onLoad="window.print()">
<form name="form_" method="post" action="./cert_enrol_billing_ched_print_UB.jsp">
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cert_enrol_billing_ched_print.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"cert_enrol_billing_ched_print.jsp");
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(),null);


if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vStudInfo     = null;
Vector vMiscFeeInfo  = null;
Vector vTemp         = null;
Vector vSubList      = null;
Vector vPayment 	 = null;
Vector vLedgerInfo   = null;
Vector vAdjustment   = null; Vector vPostChargeNotPaid = new Vector(); double dPostedNotPaid = 0d;
Vector vTimeSch		 = null;

float fTutionFee     = 0f;
float fCompLabFee    = 0f;
float fMiscFee       = 0f;
float fOutstanding   = 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,

float fTotalDiscount = 0f;
float fDownpayment   = 0f;
float fTotalAmtPaid  = 0f;

double dOutStandingBalance = 0d;

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();
enrollment.FAStudentLedger faStudLedg = new enrollment.FAStudentLedger();


boolean bolIsCurrentlyEnrolled = false;


vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
					WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
if(vStudInfo == null) strErrMsg = enrlStudInfo.getErrMsg();
else
{
	String strSQLQuery =
          "select sy_from,semester from stud_curriculum_hist" +
          " join semester_sequence on (semester_val = semester) " +
          " where is_valid = 1 and user_index = " + (String)vStudInfo.elementAt(0) +
          " order by sy_from desc, sem_order desc";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
	  if(WI.fillTextValue("sy_from").equals(rs.getString(1)) && WI.fillTextValue("semester").equals(rs.getString(2)))
	  	bolIsCurrentlyEnrolled = true;
	}
	rs.close();	  


	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
		
		
	//get others posted.. 
	strSQLQuery = "select sum(fa_stud_payable.amount), fee_name from fa_stud_payable join fa_oth_Sch_fee on (OTHSCH_FEE_INDEX = reference_index) "+
				" where fa_stud_payable.is_valid = 1 and user_index = "+(String)vStudInfo.elementAt(0)+
				" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester")+
				" and fa_stud_payable.is_valid = 1 and not exists (select * from fa_stud_payment where user_index = fa_stud_payable.user_index and "+
				" sy_from = fa_stud_payable.sy_from and semester = fa_stud_payable.semester and fa_stud_payment.is_valid = 1 and is_stud_temp = 0  "+
				" and othsch_fee_index = reference_index) group by fee_name order by fee_name";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		dPostedNotPaid += rs.getDouble(1);
		vPostChargeNotPaid.addElement(rs.getString(2));
		vPostChargeNotPaid.addElement(CommonUtil.formatFloat(rs.getDouble(1), true));
	}		
	rs.close();
	
	strSQLQuery = "select FA_STUD_REFUND.amount, refund_note from FA_STUD_REFUND where FA_STUD_REFUND.sy_from = "+WI.fillTextValue("sy_from")+
				  " and semester ="+WI.fillTextValue("semester")+" and FA_STUD_REFUND.is_valid = 1 and user_index = "+(String)vStudInfo.elementAt(0);
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		dPostedNotPaid += rs.getDouble(1);
		vPostChargeNotPaid.addElement(rs.getString(2));
		vPostChargeNotPaid.addElement(CommonUtil.formatFloat(rs.getDouble(1), true));
	}		
	rs.close();
}
if(strErrMsg == null) //collect fee details here.
{
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(fTutionFee > 0)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		if(bolIsCurrentlyEnrolled)
			fOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));
		else	
			fOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0), false, false, 
							WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		

		fMiscOtherFee = fOperation.getMiscOtherFee();

		fTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),null);
		fDownpayment   = fOperation.calAmoutPaidDurEnrollment(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		fTotalAmtPaid  = fOperation.calTotalAmoutPaidPerFee(dbOP, 0,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

		if(bolIsCurrentlyEnrolled)
			dOutStandingBalance= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0), true, true);
		else
			dOutStandingBalance= fOperation.calOutStandingCurYr(dbOP, (String)vStudInfo.elementAt(0),
				WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		//System.out.println(dOutStandingBalance);
	}
	else
		strErrMsg = fOperation.getErrMsg();
}
//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null)
{
	vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(vTemp == null)
		strErrMsg = paymentUtil.getErrMsg();
	else
		vMiscFeeInfo.addAll(vTemp);

	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");
	}
}
if(strErrMsg == null)
{
	vSubList = enrlStudInfo.getEnrolledList(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vSubList == null || vSubList.size() ==0)
	{
		strErrMsg = enrlStudInfo.getErrMsg();
	}
}

if(strErrMsg == null) {//collect fee details here.
	vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vStudInfo.elementAt(0),request.getParameter("sy_from"),
	request.getParameter("sy_to"),null,request.getParameter("semester"), false);//bolShowOnlyDroppedSub=false
	if(vLedgerInfo == null)
		strErrMsg = faStudLedg.getErrMsg();
	else
	{//System.out.println( (new java.util.Date().getTime() - lTime)/1000);
		vTimeSch 			= (Vector)vLedgerInfo.elementAt(0);
		//vTuitionFeeDetail	= (Vector)vLedgerInfo.elementAt(1);
		vAdjustment			= (Vector)vLedgerInfo.elementAt(2);
		//vRefund				= (Vector)vLedgerInfo.elementAt(3);
		//vDorm 				= (Vector)vLedgerInfo.elementAt(4);
		//vOthSchFine			= (Vector)vLedgerInfo.elementAt(5);//System.out.println(vOthSchFine);
		vPayment			= (Vector)vLedgerInfo.elementAt(6);
		if(vTimeSch == null || vTimeSch.size() ==0)
			strErrMsg = faStudLedg.getErrMsg();
	}
}//System.out.println(vAdjustment);

boolean bolIsInternal = false;//only in case of UDMC
if(WI.fillTextValue("is_internal").equals("1"))
	bolIsInternal = true;
String[] astrConvertYrLevel = {"","1ST YEAR","2ND YEAR","3RD YEAR","4TH YEAR","5TH YEAR","6TH YEAR","7TH YEAR"};
String[] astrConvertSem     = {"SUMMER","1ST SEMESTER","2ND SEMESTER","3RD SEMESTER","4TH SEMESTER"};
if(strErrMsg == null) 
	strErrMsg = "";

boolean	bolShowPmtInfo = true;
if(WI.fillTextValue("show_pmt_info").equals("0"))
	bolShowPmtInfo = false;

boolean	bolIsBasic = false;

if(vStudInfo.elementAt(16) == null)
	bolIsBasic = true;

%> 


<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td align="center">
		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
</td></tr>
<tr>
  <td width="100%" height="25" colspan="4"><div align="center"><font size="2"><strong>
	OFFICE OF THE TREASURER<br>         
	CERTIFICATE OF ENROLMENT AND BILLING
	</strong></font></div></td>
</tr>
</table>
<%
if(vStudInfo != null && vStudInfo.size() > 0)
{%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td colspan="3">&nbsp;</td><td><%=WI.getTodaysDate(6)%></td></tr>
	<tr>
		<td width="20%">Student Name:</td>
		<% 
		strTemp = null;
		if(vStudInfo.elementAt(11) != null)
			strTemp = ((String)vStudInfo.elementAt(11)).charAt(0)+".";
		%>	  
		<td colspan="3"><strong><%=(String)vStudInfo.elementAt(10)%> <%=WI.getStrValue(strTemp)%> <%=(String)vStudInfo.elementAt(12)%> </strong></td>
	</tr>
	<tr>
		<td width="20%"><%if(bolIsBasic) {%>Grade Level<%}else{%>Course<%}%>:</td>
		<td width="40%">
<%if(bolIsBasic) {%>
	<%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0")))%>
<%}else{%>
		<%=(String)vStudInfo.elementAt(16)%><%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%>       
<%}%>
		</td>
		<td align="right" width="15%">Sex: &nbsp; </td>
		<td><strong> &nbsp; <%=(String)vStudInfo.elementAt(13)%></strong></td>		
	</tr>
<%if(!bolIsBasic) {%>
	<tr>
		<td width="20%">Year Level:</td>
		<td colspan="3"><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%></td>
	</tr>
<%}%>
	<tr>
		<td width="20%">School Year:</td>
		<td colspan="3"><%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%> / <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%></td>
	</tr>
</table>

  

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr><td colspan="10" height="40">&nbsp;</td></tr>
	<tr>      
      <td width="35%" height="20"><strong>SUBJECTS</strong></td>
      <td width="12%" align="center"><strong>UNITS</strong></td>
      <td width=""><strong>SCHOOL FEES</strong></td>
    </tr>
	<tr>		
		<td colspan="2" width="45%" valign="top">
			<%if(vSubList != null && vSubList.size() > 0){%>
			<table width="100%" border="0" cellpadding="0" bgcolor="#FFFFFF">
				<%
				for(int i=1; i<vSubList.size();++i)
				{%>
				<tr>					
					<td width="72%"><%=(String)vSubList.elementAt(i+3)%>(<%=(String)vSubList.elementAt(i+4)%>)</td>
					<td width="22%" align="center"><%=(String)vSubList.elementAt(i+13)%></td>
			   </tr>
			   <%
			   i = i+13;
			   }%>
			   <tr><td colspan="2" height="10"><div style="border-bottom:solid 1px #000000; width:97%; text-align:left"></div></td></tr>
			   <tr>
            		<td width="72%"><strong>TOTAL UNITS</strong></td>
					<td width="22%" align="center"><strong><%=CommonUtil.formatFloat((String)vSubList.elementAt(0), false)%></strong></td>
			   </tr>
			   <tr>
            		<td height="1"></td>
					<td align="center"><div style="border-bottom:solid 1px #000000; width:70%"></div></td>
			   </tr>
			   <tr>
            		<td height="1"></td>
					<td align="center"><div style="border-bottom:solid 1px #000000; width:70%"></div></td>
			   </tr>
		    </table>
		<%}//only if vSubList is not null%>
		</td>
		<td width="53%" valign="top" onDblClick="Toggle();">
			<table width="100%" border="0" cellpadding="0" bgcolor="#FFFFFF">
			<tr>
				<td width="5%">&nbsp;</td>

            <td width="61%"><strong>MISCELLANEOUS FEES(Total)</strong></td>

            <td width="34%" align="right"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></td>
			</tr>
    <%
for(int i=0; i<vMiscFeeInfo.size(); i += 3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
		continue;
	}%>
			<tr>
				<td width="5%">&nbsp;</td>
				<td width="61%">&nbsp;&nbsp;&nbsp;<%=((String)vMiscFeeInfo.elementAt(i)).toUpperCase()%></td>

            <td width="34%" align="right">
			<%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
			</tr>
<%}
if(fMiscOtherFee > 0f) {%>
			<tr>
				<td width="5%">&nbsp;</td>

            <td width="61%"><strong>OTHER FEES(Total)</strong></td>

            <td width="34%" align="right"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></td>
			</tr>
<%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		continue;
	}%>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="61%">&nbsp;&nbsp;&nbsp;<%=((String)vMiscFeeInfo.elementAt(i)).toUpperCase()%></td>
			<td width="34%" align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
		</tr>
		
	<%}//end of for loop
}//end of fMiscOtherFee if it is > 0f%>
			<tr>
				<td width="5%">&nbsp;</td>

            <td width="61%"><strong>COMPUTER LAB FEE</strong></td>

            <td width="34%" align="right"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></td>
			</tr>
			<tr>
				<td width="5%">&nbsp;</td>

            <td width="61%"><strong>TUITION FEES(Total)</strong></td>

            <td width="34%" align="right"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></td>
			</tr>
			</table>
		</td>
	</tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="20">&nbsp;</td>
      <td colspan="2" valign="bottom"></td>
      <td width="3%" height="20">&nbsp;</td>
      <td width="3%" height="20">&nbsp;</td>
      <td height="20" colspan="2"><hr size="1" width="100%" align="left"></td>
    </tr>
    <tr onDblClick="Toggle();">
      <td height="20" colspan="5">&nbsp;</td>
      <td width="32%" height="20"><strong>TOTAL FEES:</strong> <!--Gross Total--></td>
      <td width="18%" height="20" align="right"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></strong></td>
    </tr>
		
	
<%if(bolShowPmtInfo){%>
	
	<tr><td colspan="5">&nbsp;</td><td height="20" colspan="2"><strong>LESS: ADJUSTMENTS</strong></td></tr>
	
	<tr>
		<td colspan="5">&nbsp;</td>
		<td colspan="2">
		<table width="100%">
			<%
			double dDebit = 0d;
			if(vAdjustment != null && vAdjustment.size() > 1){
				for(int i = 1; i < vAdjustment.size(); i += 7) {			
			dDebit = Double.parseDouble((String)vAdjustment.elementAt(i + 1));
			//dBalance -= dDebit;
				%>
					  <tr>
						<td width="65%"> &nbsp; &nbsp; &nbsp; <%=(String)vAdjustment.elementAt(i)%></td>						
						<td align="right"><%=CommonUtil.formatFloat((float)dDebit,true)%></td>
					  </tr>
			<%}//end of for loop
			
			}%>
		</table>
	</td></tr>
	<%if(dPostedNotPaid > 0d) {%>
		<tr><td colspan="5">&nbsp;</td><td height="20" colspan="2"><strong>ADD (LESS): OTHER ADJUSTMENTS</strong></td></tr>
		
		<tr>
			<td colspan="5">&nbsp;</td>
			<td colspan="2">
			<table width="100%">
				<%
					for(int i = 0; i < vPostChargeNotPaid.size(); i += 2) {	
						strTemp = (String)vPostChargeNotPaid.elementAt(i + 1);
						if(strTemp.startsWith("-"))
							strTemp = "("+strTemp.substring(1)+")";		
					%>
						  <tr>
							<td width="65%"> &nbsp; &nbsp; &nbsp; <%=(String)vPostChargeNotPaid.elementAt(i)%></td>						
							<td align="right"><%=strTemp%></td>
						  </tr>
				<%}//end of for loop%>
			</table>
		</td></tr>
	<%}%>
	
	
	<tr><td colspan="5">&nbsp;</td><td height="20" colspan="2"><strong>LESS: PAYMENTS</strong></td></tr>
    <tr>
		<td colspan="5">&nbsp;</td>
		<td colspan="2">
		<table width="100%">
			<tr>
				<td width="25%" align=""><u>Date</u></td>
				<td width="25%" align=""><u>OR No</u></td>
				<td width="25%" align="center"><u>Amount</u></td>
				<td>&nbsp;</td>
			</tr>
			
			
		<%
		double dTotPayment = 0d;//System.out.println(vPayment);
		if(vPayment != null && vPayment.size() > 0){
		for(int i = 0; i < vPayment.size(); i += 6){
			if(vPayment.elementAt(i + 4).equals("-1"))
				continue;
			dDebit = Double.parseDouble((String)vPayment.elementAt(i));
			dTotPayment += dDebit;
		%>
          <tr>
            <td><%=ConversionTable.convertMMDDYYYY((java.util.Date)vPayment.elementAt(i + 2))%></td>
            <td>
			<%if(vPayment.elementAt(i + 1) == null) {%>
				<%=(String)vPayment.elementAt(i + 3)%>
			<%}else{%>
				<%=(String)vPayment.elementAt(i + 1)%>
			<%}%>
			</td>
            <td align="right"><%=WI.getStrValue(CommonUtil.formatFloat((float)dDebit,true),"(",")","")%></td>
			<td>&nbsp;</td>
          </tr>
		<%}
		}%>
		<tr><td colspan="4" align="right"><%=WI.getStrValue(CommonUtil.formatFloat((float)dTotPayment,true),"(",")","")%></td></tr>
			
			
		
		</table>
	</td></tr>
	<tr><td colspan="5">&nbsp;</td><td height="25">ADD (LESS) PREVIOUS SEMESTER BALANCE:</td><td align="right"><%=CommonUtil.formatFloat(fOutstanding,true)%></td></tr>
	<tr><td height="1" colspan="5"></td><td height="1" colspan="2"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
	<tr><td colspan="5">&nbsp;</td><td><strong>BALANCE</strong></td><td align="right"><strong>
		<%=CommonUtil.formatFloat(dOutStandingBalance,true)%></strong></td></tr>
	<tr><td height="1" colspan="5"></td><td height="1" colspan="2"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
	<tr><td height="1" colspan="5"></td><td height="1" colspan="2"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
<%}%>

    <tr>	
      <td height="20" colspan="7">&nbsp;</td>
    </tr>
	<tr>
      <td height="20" colspan="7">&nbsp;</td>
    </tr>
	<tr>
      <td height="20" colspan="7">&nbsp;</td>
    </tr>
	<tr>
      <td height="20" colspan="5" align="center"><div style="border-bottom:solid 1px #000000; width:50%; text-align:center;"><strong>MERLINDA V. MENDEZ, CPA</strong></div></td>
      <td height="20" colspan="2">&nbsp;</td>
    </tr>
	<tr>
      <td height="20" colspan="5" align="center">Accountant</td>
      <td height="20" colspan="2">&nbsp;</td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr><td colspan="2" height="50">&nbsp;</td></tr>
	<tr>
		<td width="15%" align="center"><font size="1">NOT VALID WITHOUT<br>UNIVERSITY<br>SEAL</font></td>
		<td valign="top"><%if(dOutStandingBalance <0.1f){%>
		This is to certify that <%=(String)vStudInfo.elementAt(10)%> <%=WI.getStrValue(strTemp)%> <%=(String)vStudInfo.elementAt(12)%>  
		has fully paid his/her school acounts.
		<%}%>
		</td>
	</tr>
  
  </table>
  
<%
}//only if vCHEDScholar is not null
%>

<input type="hidden" name="show_pmt_info" value="<%=WI.getStrValue(WI.fillTextValue("show_pmt_info"), "1")%>">
<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
