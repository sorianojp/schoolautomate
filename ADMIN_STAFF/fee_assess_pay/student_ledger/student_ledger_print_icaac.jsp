<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode= "";	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

	.contentWrapper{
		display:block;
	}
	.contentWrapperFixedLong{
		display:block;		
		height: 605px;	
		margin-top:-2px;		
	}
	.contentWrapperFixedShort{
		display:block;		
		height: 510px;		
	}
	.duplicate_short{		
		position:absolute;
		height: 485px;		
		width: 100%;
		padding-right:2px;
		display:block;
		margin-top:-82px;
		padding-top:2px;
	}
	.duplicate_long{		
		position:absolute;
		height: 580px;
		display:block;
		width: 100%;
		padding-right:2px;						
	}
	.imageHeader{
		display:block;				
		height: 75px;	
	}
	.footerNote{
		position:relative;
		display:block;
		top: 5px;
		left:0px;
		bottom:0px;
	}

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

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

</style>

</head>
<body onLoad="window.print();">

<%@ page language="java" import="utility.*, enrollment.FAAssessment,enrollment.FAPayment,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,enrollment.EnrlAddDropSubject,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	MessageConstant mConst = new MessageConstant();

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};

	boolean bolProceed = true;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-Student ledger","student_ledger.jsp");
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
Vector vBasicInfo = null;
Vector vLedgerInfo = null;
Vector vTemp = null;

Vector vTimeSch = null;
Vector vAdjustment = null;
Vector vRefund = null;
Vector vDorm = null;
Vector vOthSchFine = null;
Vector vPayment = null;
Vector vScheduledPmt = new Vector();
Vector vTuitionFeeDetail = null;
Vector vScheduledPmtNew = null;

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAStudentLedger faStudLedg = new FAStudentLedger();
EnrlAddDropSubject eADS = new EnrlAddDropSubject();
FAAssessment FA = new FAAssessment();
FAPayment faPayment = new FAPayment();
enrollment.FAFeeOperation fOperation  = new enrollment.FAFeeOperation();

//for full pmt.
String strEnrolmentDiscDetail = null;
double dEnrollmentDiscount = 0d;
double dPayableAfterDiscount = 0d;
double dTotalAmtPaid =0d;
double dOutStandingBal = 0d;
double dAmoutPaidDurEnrollment = 0d;
int iRowCounter = 0;


if(WI.fillTextValue("stud_id").length() > 0)
{
	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
		strErrMsg = paymentUtil.getErrMsg();
	//check if the applicant is having reservation already, if so - take directly to the print page,
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{
		vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vBasicInfo.elementAt(0),request.getParameter("sy_from"),
			request.getParameter("sy_to"),null,request.getParameter("semester"));
		if(vLedgerInfo == null)
			strErrMsg = faStudLedg.getErrMsg();
		else
		{
			vTimeSch 			= (Vector)vLedgerInfo.elementAt(0);
			vTuitionFeeDetail	= (Vector)vLedgerInfo.elementAt(1);
			vAdjustment			= (Vector)vLedgerInfo.elementAt(2);
			vRefund				= (Vector)vLedgerInfo.elementAt(3);
			vDorm 				= (Vector)vLedgerInfo.elementAt(4);
			vOthSchFine			= (Vector)vLedgerInfo.elementAt(5);
			vPayment			= (Vector)vLedgerInfo.elementAt(6);
			if(vTimeSch == null || vTimeSch.size() ==0)
				strErrMsg = faStudLedg.getErrMsg();
		}
		
		//---------------------------------------------------   additional code for ICAAC (sul)  -------------------------------------
		//double dOutStandingBal = 0d;
		String[] astrSchYrInfo= {(String)vBasicInfo.elementAt(8),(String)vBasicInfo.elementAt(9),
						(String)vBasicInfo.elementAt(5)};
						
		float fTutionFee = fOperation.calTutionFee(dbOP, (String)vBasicInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vBasicInfo.elementAt(4),astrSchYrInfo[2]);
		float fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vBasicInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vBasicInfo.elementAt(4),astrSchYrInfo[2]);
		float fCompLabFee = fOperation.calHandsOn(dbOP, (String)vBasicInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vBasicInfo.elementAt(4),astrSchYrInfo[2]);
		fOperation.checkIsEnrolling(dbOP,(String)vBasicInfo.elementAt(0),
							astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);	
		
		float fMiscOtherFee = fOperation.getMiscOtherFee();
		enrollment.FAFeeOperationDiscountEnrollment test = new enrollment.FAFeeOperationDiscountEnrollment(true,WI.getTodaysDate(1));
		test.setForceFullPmt();
		vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,  (String)vBasicInfo.elementAt(0),paymentUtil.isTempStud(),
						astrSchYrInfo[0],astrSchYrInfo[1],(String)vBasicInfo.elementAt(6), astrSchYrInfo[2],fOperation.dReqSubAmt);

		if(vTemp != null && vTemp.size() > 0)
			strEnrolmentDiscDetail = (String)vTemp.elementAt(0);
		if(strEnrolmentDiscDetail != null) {
			dEnrollmentDiscount = ((Float)vTemp.elementAt(1)).doubleValue();
	
			//dFullPmtPayableAmt = dFullPmtPayableAmt - dEnrollmentDiscount;
		}
		
		dOutStandingBal = fOperation.calOutStandingOfPrevYearSem(dbOP,(String)vBasicInfo.elementAt(0), true, true);		
		//get scheduled payment information.
		vScheduledPmt =FA.getInstallmentSchedulePerStudent(dbOP,(String)vBasicInfo.elementAt(0),(String)vBasicInfo.elementAt(8),
								(String)vBasicInfo.elementAt(9),(String)vBasicInfo.elementAt(4),(String)vBasicInfo.elementAt(5));

		dAmoutPaidDurEnrollment = ((Float)vScheduledPmt.elementAt(2)).doubleValue();
		//System.out.println("Schedule Pmt : "+vScheduledPmt);
		if(vScheduledPmt == null || vScheduledPmt.size() ==0)
			strErrMsg = FA.getErrMsg();//System.out.println(FA.getErrMsg());
		else
			dPayableAfterDiscount = Float.parseFloat((vScheduledPmt.elementAt(0)).toString()) - dEnrollmentDiscount;
		
		//---------------------------------------------------  end of   additional code for ICAAC (sul)  -------------------------------------
	
	}
}

//dbOP.cleanUP();
if(strErrMsg != null){dbOP.cleanUP();%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td align="center"><strong><%=strErrMsg%></strong></td>
    </tr>
</table>
<%return;}
if(vBasicInfo != null && vBasicInfo.size() > 0){%>
<div id="original" class="contentWrapperFixedLong" >	
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr><td>
  <table width="100%" border="0" >
    <tr>
      <td width="100%" align="center">	
		<div class="imageHeader">
			<img src="../../../images/logo/ICAAC.jpg" />
			<!--<%=SchoolInformation.getSchoolName(dbOP,true,false)%>-->
		</div>
		<div style="margin-top:-5px">STUDENT LEDGER<br>
			<%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>
			(<%=astrConvertTerm[Integer.parseInt(request.getParameter("semester"))]%>)			
		</div>
			<div align="right">Date and time printed: <%=WI.getTodaysDateTime()%></div>
			
		</td>
	</td>
    </tr>    
   
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td  width="2%" height="15">&nbsp;</td>
      <td width="58%" height="15">Student ID :<strong> <%=request.getParameter("stud_id")%></strong></td>
      <td width="40%" height="15"  colspan="4">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
        <%
	  if(vBasicInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
        <%}%>
        </strong> </td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td height="15">Student name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td  colspan="4" height="20">Current Year/Term :<strong> <%=WI.getStrValue(vBasicInfo.elementAt(4),"xx")%>/
        <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong></td>
    </tr>
  </table>

<%
if(vTimeSch != null && vTimeSch.size() > 0){
double dBalance = ((Double)vTuitionFeeDetail.elementAt(0)).doubleValue();
double dCredit = 0d;
double dDebit = 0d;
String strTransDate = null;
int iIndex = 0;
boolean bolDatePrinted = false;
%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#E6E6EA"> 
    <td width="11%" height="20" align="center" class="thinborder" style="font-size:11px;"><strong>Date</strong></td>
    <td width="40%" align="center" class="thinborder" style="font-size:11px;"><strong>Particulars</strong></td>
    <td width="6%" class="thinborder" style="font-size:11px;"><div align="center"><strong>Collected by (ID) </strong></div></td>
    <td width="13%" align="center" class="thinborder" style="font-size:11px;"><strong>Debit</strong></td>
    <td width="13%" align="center" class="thinborder" style="font-size:11px;"><strong>Credit</strong></td>
    <td width="17%" align="center" class="thinborder" style="font-size:11px;"><strong>Balance</strong></td>
  </tr>
  <tr > 
    <td height="20" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder">Old Account </td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td  align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
for(int i=0; i<vTimeSch.size(); ++i){
strTransDate = ConversionTable.convertMMDDYYYY((Date)vTimeSch.elementAt(i));
bolDatePrinted = false;

if(vTuitionFeeDetail.contains((Date)vTimeSch.elementAt(i))){
dDebit = ((Double)vTuitionFeeDetail.elementAt(1)).doubleValue();
dBalance += dDebit;

bolDatePrinted = true;
iRowCounter++;
%>
  <tr > 
    <td height="20" class="thinborder"><%=strTransDate%></td>
    <td class="thinborder">Tuition Fee</td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(2)).doubleValue();
dBalance += dDebit;
iRowCounter++;
%>
  <tr > 
    <td height="20" class="thinborder">&nbsp;</td>
    <td class="thinborder">Miscellaneous Fee</td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
    <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();
if(dDebit > 0d){
dBalance += dDebit;
iRowCounter++;%>
    <tr > 
      <td height="20" class="thinborder">&nbsp;</td>
      <td class="thinborder">Other Charges</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%}
dDebit = ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
if(dDebit > 0d){
  dBalance += dDebit; 
  iRowCounter++;%>
  <tr > 
    <td height="20" class="thinborder">&nbsp;</td>
    <td class="thinborder">Hands on</td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
<%}
//show this if there is any discounts. 
if(vTuitionFeeDetail.elementAt(5) != null){
	iRowCounter++;
double dTemp = ((Double)vTuitionFeeDetail.elementAt(5)).doubleValue();
if(dTemp > 0)
	dCredit = dTemp;
else	
	dDebit  =  -1 * dTemp;
dBalance -= dTemp;
%>
    <tr >
      <td height="20" class="thinborder">&nbsp;</td>
      <td class="thinborder"><%=vTuitionFeeDetail.elementAt(6)%></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder">&nbsp;
	  <%if(dDebit > 0d){%>
	  <%=CommonUtil.formatFloat(dDebit,true)%>
	  <%}%>
	  </td>
      <td align="right" class="thinborder">&nbsp;
	  <%if(dCredit > 0d){%>
	  <%=CommonUtil.formatFloat(dCredit,true)%>
	  <%}%>
	  </td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
<%}if(vTuitionFeeDetail.elementAt(8) != null){
	iRowCounter++;%>	
    <tr > 
      <td height="20" class="thinborder">&nbsp;</td>
      <td colspan="5" class="thinborder">NOTE : <%=(String)vTuitionFeeDetail.elementAt(8)%></td>
    </tr>
  <%}
} //for tuition fee detail.

//adjustment here
while( (iIndex = vAdjustment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{	iRowCounter++;
	dCredit = Double.parseDouble((String)vAdjustment.elementAt(iIndex-3));
	dBalance -= dCredit;
%>
  <tr > 
    <td height="20" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <td class="thinborder"><%=(String)vAdjustment.elementAt(iIndex-4)%>(Grant)</td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td  align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dCredit,true)%></td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
//remove the element here.
vAdjustment.removeElementAt(iIndex);
vAdjustment.removeElementAt(iIndex-1);
vAdjustment.removeElementAt(iIndex-2);
vAdjustment.removeElementAt(iIndex-3);
vAdjustment.removeElementAt(iIndex-4);
vAdjustment.removeElementAt(iIndex-5);
}

//Refund here
while( (iIndex = vRefund.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{	iRowCounter++;
	dDebit = Double.parseDouble((String)vRefund.elementAt(iIndex-1));
	dBalance += dDebit;
%>
  <tr > 
    <td height="20" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <td class="thinborder"><%=(String)vRefund.elementAt(iIndex-3)%>(Refund)</td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
//remove the element here.
vRefund.removeElementAt(iIndex);vRefund.removeElementAt(iIndex-1);vRefund.removeElementAt(iIndex-2);
vRefund.removeElementAt(iIndex-3);
}
//dormitory charges
while( (iIndex = vDorm.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{	iRowCounter++;
	dDebit = Double.parseDouble((String)vDorm.elementAt(iIndex-1));
	dBalance += dDebit;
%>
  <tr > 
    <td height="20" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <td class="thinborder"><%=(String)vDorm.elementAt(iIndex-2)%></td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
//remove the element here.
vDorm.removeElementAt(iIndex);vDorm.removeElementAt(iIndex-1);vDorm.removeElementAt(iIndex-2);
}

//Other school fees/fine/school facility fee charges(except dormitory)
while( (iIndex = vOthSchFine.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{	iRowCounter++;
	dDebit = Double.parseDouble((String)vOthSchFine.elementAt(iIndex-1));
	dBalance += dDebit;
%>
  <tr > 
    <td height="20" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <td class="thinborder"><%=(String)vOthSchFine.elementAt(iIndex-2)%></td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
//remove the element here.
vOthSchFine.removeElementAt(iIndex);vOthSchFine.removeElementAt(iIndex-1);vOthSchFine.removeElementAt(iIndex-2);
}
//vPayment goes here, ;-)
while( (iIndex = vPayment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{	iRowCounter++;
	dCredit = Double.parseDouble((String)vPayment.elementAt(iIndex-2));
	dBalance -= dCredit;
%>
  <tr > 
    <td height="20" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <td class="thinborder"><%=WI.getStrValue(vPayment.elementAt(iIndex-1))%> <%=(String)vPayment.elementAt(iIndex+1)%>
<%if(false){%>
      (Refuned)
      <%}%>
    </td>
    <td align="center" class="thinborder"><%=(String)vPayment.elementAt(iIndex + 3)%></td>
    <td  align="right" class="thinborder">&nbsp;
	  <%//show only the refunds in debit column.
	  if(dCredit < 0d || 
	  	(vPayment.elementAt(iIndex+1) != null && ((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
	  <%=CommonUtil.formatFloat(-1 * dCredit,true)%>
	  <%}%></td>
      <td align="right" class="thinborder">&nbsp;
	  <%if(dCredit >= 0d && 
	  	(vPayment.elementAt(iIndex+1) == null || !((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
	  <%=CommonUtil.formatFloat(dCredit,true)%>
	  <%}%>
	  </td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
//remove the element here.
vPayment.removeElementAt(iIndex+2);vPayment.removeElementAt(iIndex+1);vPayment.removeElementAt(iIndex);
vPayment.removeElementAt(iIndex-1);vPayment.removeElementAt(iIndex-2);
}%>
  <%
}%>
</table>
<% if(vBasicInfo != null && vBasicInfo.size() > 0 && vBasicInfo.elementAt(0) != null && dBalance > 0) { %>		
		
		<table  border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		  
		    <tr>
		      <td height="20" width="2%">&nbsp;</td>
		      <td align="center" style="font-size:12px; font-weight:bold">COMMENTS </td> 
			  
		    </tr>
		<%			
			
			iRowCounter++;
			int iNoOfInstallments = 1;
			vScheduledPmtNew = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vBasicInfo.elementAt(0),(String)vBasicInfo.elementAt(8),
							(String)vBasicInfo.elementAt(9),(String)vBasicInfo.elementAt(4),(String)vBasicInfo.elementAt(5));
			
			if(vScheduledPmtNew != null && vScheduledPmtNew.size() > 0) {				
					//iNoOfInstallments = ((Integer)vScheduledPmt.elementAt(4)).intValue();
					iNoOfInstallments = 2;
					int iIndexOf = 0;
					double[] adTemp = null; 					
					double dAmtDue = 0; 
					double dTotalDue = 0d; 
					double dOSBal = Double.parseDouble(ConversionTable.replaceString((String)vScheduledPmtNew.elementAt(6), ",",""));
					
					/*//>sul varialbles
					double dRemainingBalance = dPayableAfterDiscount - dAmoutPaidDurEnrollment;
					double dDuePerInstallment = dRemainingBalance/iNoOfInstallments; //payable per installment
					double dAmountPaidPerInstallment = 0d;
					double dAmountDueForInstallment = 0d;
					double dDueDefualtInstallment = dPayableAfterDiscount/iNoOfInstallments;
					double dExcessPayment = 0d;				
					//<sul varialbles	
															
					for(int i = 7; i < vScheduledPmtNew.size(); i += 2) {
						
						//date schedule
						iIndexOf = vScheduledPmt.indexOf(vScheduledPmtNew.elementAt(i));
						if(iIndexOf == -1)
							strTemp = null;
						else
							strTemp = (String)vScheduledPmt.elementAt(iIndexOf + 1);			
							
						dAmountDueForInstallment = ((Double)vScheduledPmtNew.elementAt(i + 1)).doubleValue();											
						dAmountDueForInstallment += dExcessPayment; //becoz dExcessPayment is negative it will deduct
						
						if(dAmountDueForInstallment < 0)
							dExcessPayment = dAmountDueForInstallment;
						
									
						/*dAmountPaidPerInstallment = 0;
						dAmountDueForInstallment  = dDuePerInstallment;
						iIndexOf = vScheduledPmt.indexOf(vScheduledPmtNew.elementAt(i));
						if(iIndexOf == -1)
							strTemp = null;
						else
							strTemp = (String)vScheduledPmt.elementAt(iIndexOf + 1);										
						dAmtDue = ((Double)vScheduledPmtNew.elementAt(i + 1)).doubleValue();
						
						if(dOSBal <= 0 && dAmtDue <=0d)
							dTotalDue = dAmtDue;
						else
							dTotalDue += dAmtDue;
				
						//if(dTotalDue >= dOSBal)
						//	dTotalDue = dOSBal;
				
						if(((i + 3) > vScheduledPmtNew.size()) )
							dTotalDue = dOSBal;
						
						if(i==7)//first installment payment
							dAmtDue+=dAmoutPaidDurEnrollment;
							
						dAmtDue-=dExcessPayment;										
						//dAmtDue -> value saved in the vector for installment payables
						if(dAmtDue != dDueDefualtInstallment )
							dAmountPaidPerInstallment = dDueDefualtInstallment - dAmtDue;						
						
						if(dAmountPaidPerInstallment < dDuePerInstallment ){
							dAmountDueForInstallment = dDuePerInstallment - dAmountPaidPerInstallment;
							dExcessPayment = 0;
						}else{ //excess installment payment
							dAmountDueForInstallment = 0;
							dExcessPayment += (dAmountPaidPerInstallment - dDuePerInstallment);
						}						
						*/						
						
						/*if(dAmountDueForInstallment <= 0)	
							continue;
							
						iRowCounter++;	
						*/
						
						double d2ndPmt = ((Double)vScheduledPmtNew.elementAt(8)).doubleValue();
						double dLastPmt = ((Double)vScheduledPmtNew.elementAt(10)).doubleValue();

						if (d2ndPmt < 0){
							dLastPmt = dLastPmt + d2ndPmt;
							d2ndPmt = 0d;
						}						
						if(dLastPmt < 0d && d2ndPmt > 0) {//swap
							dLastPmt = d2ndPmt;
							d2ndPmt = 0;
						}							
						
															
											
						if(d2ndPmt > 0d){
							//2nd payment date
							iIndexOf = vScheduledPmt.indexOf(vScheduledPmtNew.elementAt(7));
							if(iIndexOf == -1)
								strTemp = null;
							else
								strTemp = (String)vScheduledPmt.elementAt(iIndexOf + 1);
					%>
						<tr>
							<td height="15">&nbsp;</td>	
							<td>
								<%=vScheduledPmtNew.elementAt(7)%> <b>Php <%=CommonUtil.formatFloat(d2ndPmt,true)%>  </b>
								on or before <b> <%=WI.formatDate((String)strTemp,10)%> </b>
							</td>
						</tr>
						<%} //end of 2nd payment > 0
												
						if(dLastPmt > 0d){
							//2nd payment date
							iIndexOf = vScheduledPmt.indexOf(vScheduledPmtNew.elementAt(9));
							if(iIndexOf == -1)
								strTemp = null;
							else
								strTemp = (String)vScheduledPmt.elementAt(iIndexOf + 1);
					%>
						<tr>
							<td height="15">&nbsp;</td>	
							<td>
								<%=vScheduledPmtNew.elementAt(9)%> <b>Php <%=CommonUtil.formatFloat(dLastPmt,true)%>  </b>
								on or before <b> <%=WI.formatDate((String)strTemp,10)%> </b>
							</td>
						</tr>
						
						<%} //end of last payment > 0
						
					//} //loop %>
				<%} //vScheduledPmtNew != null %>	
			</table>					
		<!-- end of new implementation -->
	<%} //end of if vBasicInfo != null %>
	<!--<div class="footerNote">-->
	<br />
	<div>
	<table width="100%" align="center">
		<tr align="center">
			<td><b>Thank you for your prompt payment!</b><br/></td>
		</tr>
		<tr align="center">
			<td>
				<font size="1">
					Make all checks payable to: <b><i>International Culinary Arts Academy Cebu (ICAAC)</i></b><br/>
					Bank Deposit: <b>RCBC-Guadalupe Branch Cebu - Account number - 144 6363-855</b><br/>		
					<b>China Trust - Account number - 401 016 002371</b><br/>
					<b>I</b>nternational <b>C</b>ulinary <b>A</b>rts <b>A</b>ccademy <b>C</b>ebu<br/>
					Don Gervacio Quijada Street, Guadalupe<br/>	
					Cebu City 6000, Philippines
				</font>	
			</td>
		</tr>
	</table>
	</div>
<%}//only if vTimeSch is not null %>

</td></tr>
</table>
</div>
<% 
	if(iRowCounter > 14){//wont fit in long, so page 2
		strTemp = "";
	%>
	<br style="page-break-before:always"  />
	<%}else if(iRowCounter > 9 && iRowCounter <=14 ){//wont fit in short, so long
		strTemp = "class = 'duplicate_long' ";
	}else{ //short  
		strTemp = "class = 'duplicate_short' ";
	} %>	
<!----------------------------------------  DUPLICATE --------------------------------------------->
<div id="duplicate" <%=strTemp%> ></div>
<script type="text/javascript">
	//duplicateDiv();
	//function duplicateDiv(){
		document.getElementById("duplicate").innerHTML = document.getElementById("original").innerHTML;

	//}
</script>
<!---------------------------------------  DUPLICATE ----------------------------------------------->
<%} //only if basic info is not null;
%>
<!--
<script type="text/javascript">
//window.print();
</script>
-->
</body>
</html>
<%
dbOP.cleanUP();
%>