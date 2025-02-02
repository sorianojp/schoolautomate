<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode= "";

if(strSchCode.startsWith("ICAAC")){%>
	<jsp:forward page="./student_ledger_print_icaac.jsp" />
<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
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

-->
</style>

</head>
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term","","",""};

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

Vector vTimeSch = null;
Vector vAdjustment = null;
Vector vRefund = null;
Vector vDorm = null;
Vector vOthSchFine = null;
Vector vPayment = null;

Vector vTuitionFeeDetail = null;

Vector vAddedSub = null;
Vector vDroppedSub = null;
Vector vDissolvedSub = null;


FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAStudentLedger faStudLedg = new FAStudentLedger();

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

	}
}


if(WI.fillTextValue("inc_adddrop").length() > 0) {
		enrollment.EnrlAddDropSubject eADS = new enrollment.EnrlAddDropSubject();
		vAddedSub = eADS.getAddedDroppedList(dbOP, (String)vBasicInfo.elementAt(0),  (String)vBasicInfo.elementAt(10),
											 request.getParameter("sy_from"),request.getParameter("sy_to"),
											 request.getParameter("semester"), true);
		vDroppedSub = eADS.getAddedDroppedList(dbOP, (String)vBasicInfo.elementAt(0),  (String)vBasicInfo.elementAt(10),
											 request.getParameter("sy_from"),request.getParameter("sy_to"),
											 request.getParameter("semester"), false);
		//get Dissolved subject..
		vDissolvedSub = eADS.getDissolvedSubjectList(dbOP, (String)vBasicInfo.elementAt(0),  (String)vBasicInfo.elementAt(10),
											 request.getParameter("sy_from"),request.getParameter("sy_to"),
											 request.getParameter("semester"));

}

boolean bolShowDiscDetail = true;
if(strSchCode.startsWith("PWC"))
	bolShowDiscDetail = false;


String strBatchNumber = null;///used for SWU.. 
if(strSchCode.startsWith("SWU") && vBasicInfo != null && vBasicInfo.size() > 0) {
	strBatchNumber = "select section_name from stud_curriculum_hist where user_index = "+(String)vBasicInfo.elementAt(0)+" and section_name is not null and sy_from = "+request.getParameter("sy_from");
	strBatchNumber = dbOP.getResultOfAQuery(strBatchNumber, 0) ;
}
if(strBatchNumber != null) {
	astrConvertTerm[1] = "1st Term";
	astrConvertTerm[2] = "2nd Term";
	astrConvertTerm[3] = "3rd Term";
	astrConvertTerm[4] = "4th Term";
	astrConvertTerm[5] = "5th Term";
}


//dbOP.cleanUP();
if(strErrMsg != null){dbOP.cleanUP();%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td align="center"><strong><%=strErrMsg%></strong></td>
    </tr>
</table>
<%return;}

if(vBasicInfo != null && vBasicInfo.size() > 0){

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
<%if(strSchCode.startsWith("DLSHSI")){%>
    <tr>	
      <td width="29%" align="right" style="padding-right:20px;"><img src="../../../images/logo/<%=strSchCode%>.gif" border="0" height="70" width="70" align="absmiddle"></td>
      <td width="71%"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
    </tr>
<%}else{%>	
	<tr>
	
      <td colspan="2"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        </div></td>
    </tr>
<%}%>	
	<%
	strTemp = "center";
	if(strSchCode.startsWith("DLSHSI"))
		strTemp = "";
	%>
    <tr>
      <td height="30" colspan="2"><div align="<%=strTemp%>"><br>
        STUDENT LEDGER<br>
        <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>
		(<%=astrConvertTerm[Integer.parseInt(request.getParameter("semester"))]%>)

        </strong>
		<%if(strSchCode.startsWith("DLSHSI")){%>
		Date and time printed: <%=WI.getTodaysDateTime()%>
		<%}%>
		</div>
		<%if(!strSchCode.startsWith("DLSHSI")){%><div align="right">Date and time printed: <%=WI.getTodaysDateTime()%></div><%}%></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="37%" height="25">Student ID :<strong> <%=request.getParameter("stud_id")%></strong></td>
      <td width="61%" height="25"  colspan="4">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
        <%
	  if(vBasicInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
        <%}%>
        </strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td  colspan="4" height="25">Current Year/Term :<strong> <%=WI.getStrValue(vBasicInfo.elementAt(4),"xx")%>/
        <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong>
		<font  style="font-weight:bold; font-size:22px;"><%if(strBatchNumber != null) {%>&nbsp;&nbsp;&nbsp;&nbsp;Batch: <%=strBatchNumber%><%}%></font>
		</td>
    </tr>
<%
if(strSchCode.startsWith("FATIMA")){
String strPlanInfo = "select PLAN_NAME from FA_STUD_MIN_REQ_DP_PER_STUD "+
					"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.plan_ref = FA_STUD_MIN_REQ_DP_PER_STUD.plan_ref) "+
					" where is_temp_stud = 0 and stud_index = "+vBasicInfo.elementAt(0)+
					" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester");
strPlanInfo = dbOP.getResultOfAQuery(strPlanInfo, 0);

if(strPlanInfo != null){
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-weight:bold; color:#0000FF; font-size:12px;"><u>Plan Subscribed: <%=strPlanInfo.toUpperCase()%></u></td>
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
<%}
}%>
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
    <%if(strSchCode.startsWith("DLSHSI")){%><td width="11%" align="center" class="thinborder" style="font-size:11px;"><strong>Reference No.</strong></td><%}%>
    <td width="40%" align="center" class="thinborder" style="font-size:11px;"><strong>Particulars</strong></td>
    <td width="6%" class="thinborder" style="font-size:11px;"><div align="center"><strong>Collected by (ID) </strong></div></td>
    <td width="13%" align="center" class="thinborder" style="font-size:11px;"><strong>Debit</strong></td>
    <td width="13%" align="center" class="thinborder" style="font-size:11px;"><strong>Credit</strong></td>
    <td width="17%" align="center" class="thinborder" style="font-size:11px;"><strong>Balance</strong></td>
  </tr>
  <tr > 
    <td height="25" class="thinborder">&nbsp;</td>
    <%if(strSchCode.startsWith("DLSHSI")){%><td class="thinborder">&nbsp;</td><%}%>
    <td align="right" class="thinborder">Old Account </td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td  align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
String strGrant = null;

for(int i=0; i<vTimeSch.size(); ++i){
strTransDate = ConversionTable.convertMMDDYYYY((Date)vTimeSch.elementAt(i));
bolDatePrinted = false;

if(vTuitionFeeDetail.contains((Date)vTimeSch.elementAt(i))){
dDebit = ((Double)vTuitionFeeDetail.elementAt(1)).doubleValue();
dBalance += dDebit;

bolDatePrinted = true;
%>
  <tr > 
    <td height="25" class="thinborder"><%=strTransDate%></td>
    <%if(strSchCode.startsWith("DLSHSI")){%><td class="thinborder">&nbsp;</td><%}%>
    <td class="thinborder">Tuition Fee</td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(2)).doubleValue();
dBalance += dDebit;
%>
  <tr > 
    <td height="25" class="thinborder">&nbsp;</td>
    <%if(strSchCode.startsWith("DLSHSI")){%><td class="thinborder">&nbsp;</td><%}%>
    <td class="thinborder">Miscellaneous Fee</td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
    <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();
if(dDebit > 0d){
dBalance += dDebit;%>
    <tr > 
      <td height="25" class="thinborder">&nbsp;</td>
      <%if(strSchCode.startsWith("DLSHSI")){%><td class="thinborder">&nbsp;</td><%}%>
      <td class="thinborder">Other Charges</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%}
dDebit = ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
if(dDebit > 0d){
  dBalance += dDebit; %>
  <tr > 
    <td height="25" class="thinborder">&nbsp;</td>
    <%if(strSchCode.startsWith("DLSHSI")){%><td class="thinborder">&nbsp;</td><%}%>
    <td class="thinborder">Hands on</td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
<%}
//show this if there is any discounts. 
if(vTuitionFeeDetail.elementAt(5) != null){
double dTemp = ((Double)vTuitionFeeDetail.elementAt(5)).doubleValue();
if(dTemp > 0)
	dCredit = dTemp;
else	
	dDebit  =  -1 * dTemp;
dBalance -= dTemp;
%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <%if(strSchCode.startsWith("DLSHSI")){%><td class="thinborder">&nbsp;</td><%}%>
      <td class="thinborder"><%=vTuitionFeeDetail.elementAt(6)%></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder">&nbsp;
	  <%if(dDebit > 0d){%>
	  <%=CommonUtil.formatFloat(dDebit,true)%>
	  <%}%>	  </td>
      <td align="right" class="thinborder">&nbsp;
	  <%if(dCredit > 0d){%>
	  <%=CommonUtil.formatFloat(dCredit,true)%>
	  <%}%>	  </td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
<%}if(vTuitionFeeDetail.elementAt(8) != null){%>	
    <tr > 
      <td height="25" class="thinborder">&nbsp;</td>
      <%if(strSchCode.startsWith("DLSHSI")){%><td class="thinborder">&nbsp;</td><%}%>
      <td colspan="5" class="thinborder">NOTE : <%=(String)vTuitionFeeDetail.elementAt(8)%></td>
    </tr>
  <%}
} //for tuition fee detail.

//adjustment here
int iIndexOf2 = 0;
Vector vDiscountAddlDetail = faStudLedg.vDiscountAddlDetail;
if(vDiscountAddlDetail == null)
	vDiscountAddlDetail = new Vector();
	
while( (iIndex = vAdjustment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dCredit = Double.parseDouble((String)vAdjustment.elementAt(iIndex-3));
	dBalance -= dCredit;
	
	iIndexOf2 = vDiscountAddlDetail.indexOf(new Integer((String)vAdjustment.elementAt(iIndex + 2)));
	if(iIndexOf2 == -1) {
		strTemp = null;
		strErrMsg = null;
	}
	else {
		strTemp = (String)vDiscountAddlDetail.elementAt(iIndexOf2 + 1);
		if(vDiscountAddlDetail.elementAt(iIndexOf2 + 2) != null && ((String)vDiscountAddlDetail.elementAt(iIndexOf2 + 2)).length() > 0) 
			strErrMsg = (String)vDiscountAddlDetail.elementAt(iIndexOf2 + 2);
	}
	strGrant = (String)vAdjustment.elementAt(iIndex-4);
	if(!bolShowDiscDetail && strGrant != null && strGrant.length() > 20 && strGrant.indexOf("<br>") > 0) {
		strGrant = strGrant.substring(0, strGrant.indexOf("<br>"));
	}
%>
  <tr > 
    <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <%if(strSchCode.startsWith("DLSHSI")){%><td class="thinborder">&nbsp;</td><%}%>
    <td class="thinborder"><%=strGrant%>(Grant)
	  <%=WI.getStrValue(strErrMsg, "<br>Approval #: ","","")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
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
{
	dDebit = Double.parseDouble((String)vRefund.elementAt(iIndex-1));
	dBalance += dDebit;
%>
  <tr > 
    <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <%if(strSchCode.startsWith("DLSHSI")){%><td class="thinborder">&nbsp;</td><%}%>
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
{
	dDebit = Double.parseDouble((String)vDorm.elementAt(iIndex-1));
	dBalance += dDebit;
%>
  <tr > 
    <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <%if(strSchCode.startsWith("DLSHSI")){%><td class="thinborder">&nbsp;</td><%}%>
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
int iIndexOfPostedBy = 0;
while( (iIndex = vOthSchFine.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
iIndexOfPostedBy = (iIndex - 2)/3;
if(faStudLedg.vOthSchFeePostedBy.size() > iIndexOfPostedBy) {
	strTemp = (String)faStudLedg.vOthSchFeePostedBy.elementAt(iIndexOfPostedBy);
	faStudLedg.vOthSchFeePostedBy.remove(iIndexOfPostedBy);
}
else
	strTemp = null;
	
	dDebit = Double.parseDouble((String)vOthSchFine.elementAt(iIndex-1));
	dBalance += dDebit;
%>
  <tr > 
    <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <%if(strSchCode.startsWith("DLSHSI")){%><td class="thinborder">&nbsp;</td><%}%>
    <td class="thinborder"><%=(String)vOthSchFine.elementAt(iIndex-2)%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right" class="thinborder">&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
//remove the element here.
//vOthSchFine.removeElementAt(iIndex + 1);
vOthSchFine.removeElementAt(iIndex);vOthSchFine.removeElementAt(iIndex-1);vOthSchFine.removeElementAt(iIndex-2);
}

//vPayment goes here, ;-)
while( (iIndex = vPayment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dCredit = Double.parseDouble((String)vPayment.elementAt(iIndex-2));
	dBalance -= dCredit;
%>
  <tr > 
    <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <%if(strSchCode.startsWith("DLSHSI")){%><td class="thinborder"><%=WI.getStrValue(vPayment.elementAt(iIndex-1))%></td><%}%>
    <td class="thinborder"><%if(!strSchCode.startsWith("DLSHSI")){%><%=WI.getStrValue(vPayment.elementAt(iIndex-1))%><%}%><%=(String)vPayment.elementAt(iIndex+1)%>
<%if(false){%>
      (Refuned)
      <%}%>    </td>
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
	  <%}%>	  </td>
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
<%}//only if vTimeSch is not null

} //only if basic info is not null;
%>
<% if (vAddedSub != null && vAddedSub.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>  
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="25" colspan="6" class="thinborder"><div align="center"><strong>LIST 
          OF ADDED SUBJECTS</strong></div></td>
    </tr>
    <tr> 
      <td width="16%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Subject</strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>Section </strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>Units</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>Date Approved</strong></font></div></td>
      <td width="35%" class="thinborder"><div align="center"><font size="1"><strong>Reason For Adding</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>Added By</strong></font></div></td>
    </tr>
    <% for (int i = 0; i < vAddedSub.size(); i+=18){%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vAddedSub.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vAddedSub.elementAt(i+6)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vAddedSub.elementAt(i+12)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vAddedSub.elementAt(i+14),"&nbsp")%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vAddedSub.elementAt(i+15),"&nbsp")%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vAddedSub.elementAt(i+16)%></font></td>
    </tr>
    <%}//end for loop%>
  </table>

<%} if (vDroppedSub != null && vDroppedSub.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" colspan="6">&nbsp;</td>
    </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
   <tr bgcolor="#FFFFAF"> 
      <td height="25" colspan="6" class="thinborder"><div align="center"><strong>LIST 
          OF DROPPED SUBJECTS</strong></div></td>
    </tr>
    <tr> 
      <td width="16%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Subject</strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>Section </strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>Units</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>Date Approved</strong></font></div></td>
      <td width="35%" class="thinborder"><div align="center"><font size="1"><strong>Reason For Dropping</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>Dropped By</strong></font></div></td>
    </tr>
    <% for (int i = 0; i < vDroppedSub.size(); i+=18){%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vDroppedSub.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vDroppedSub.elementAt(i+6)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vDroppedSub.elementAt(i+12)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vDroppedSub.elementAt(i+14),"&nbsp")%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vDroppedSub.elementAt(i+15),"&nbsp")%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vDroppedSub.elementAt(i+16)%></font></td>
    </tr>
    <%}//end for loop%>
  </table>
<%} if (vDissolvedSub != null && vDissolvedSub.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" colspan="6">&nbsp;</td>
    </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
   <tr bgcolor="#FFFFAF"> 
      <td height="25" colspan="5" class="thinborder"><div align="center"><strong>LIST OF DISSOLVED SUBJECTS</strong></div></td>
    </tr>
    <tr> 
      <td width="16%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Subject</strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>Section </strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>Units</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>Date Dissolved</strong></font></div></td>
      <td width="45%" class="thinborder"><div align="center"><font size="1"><strong>Dissolved By</strong></font></div></td>
    </tr>
    <% for (int i = 0; i < vDissolvedSub.size(); i+=13){%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vDissolvedSub.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vDissolvedSub.elementAt(i+6)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vDissolvedSub.elementAt(i+9)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vDissolvedSub.elementAt(i+10),"&nbsp")%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vDissolvedSub.elementAt(i+12)%></font></td>
    </tr>
    <%}//end for loop%>
  </table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>