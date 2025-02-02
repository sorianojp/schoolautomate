<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>

</head>
<body>
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	MessageConstant mConst = new MessageConstant();

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = {"Summer","Regular","2nd Sem","3rd Sem"};

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


FAPaymentUtil paymentUtil = new FAPaymentUtil();
paymentUtil.setIsBasic(true);
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

//dbOP.cleanUP();
if(strErrMsg != null){dbOP.cleanUP();%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td align="center"><strong><%=strErrMsg%></strong></td>
    </tr>
</table>
<%return;}

if(vBasicInfo != null && vBasicInfo.size() > 0){%>
  <table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        </div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><br>
        STUDENT LEDGER<br>
        <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>
		(<%=astrConvertTerm[Integer.parseInt(request.getParameter("semester"))]%>)

        </strong></div>
		<div align="right">Date and time printed: <%=WI.getTodaysDateTime()%></div></td>
    </tr>
   </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="37%" height="25">Student ID :<strong> <%=request.getParameter("stud_id")%></strong></td>
      
    <td width="61%" height="25"  colspan="4">&nbsp; </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
      
    <td  colspan="4" height="25">Current Year/Term :<strong> <%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue(vBasicInfo.elementAt(4),"0")))%>/ 
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
  
<table width="100%" border="1" cellpadding="0" cellspacing="0" >
  <tr bgcolor="#E6E6EA"> 
    <td width="11%" height="20" align="center"><strong>DATE</strong></td>
    <td width="40%" align="center"><strong>PARTICULARS</strong></td>
    <td width="6%">&nbsp;</td>
    <td width="13%" align="center"><strong>DEBIT</strong></td>
    <td width="13%" align="center"><strong>CREDIT</strong></td>
    <td width="17%" align="center"><strong>BALANCE</strong></td>
  </tr>
  <tr > 
    <td height="25" >&nbsp;</td>
    <td align="right">OLD ACCOUNT</td>
    <td align="center">&nbsp;</td>
    <td  align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
for(int i=0; i<vTimeSch.size(); ++i){
strTransDate = ConversionTable.convertMMDDYYYY((Date)vTimeSch.elementAt(i));
bolDatePrinted = false;

if(vTuitionFeeDetail.contains((Date)vTimeSch.elementAt(i))){
dDebit = ((Double)vTuitionFeeDetail.elementAt(1)).doubleValue();
dBalance += dDebit;

bolDatePrinted = true;
%>
  <tr > 
    <td height="25" ><%=strTransDate%></td>
    <td >Tuition Fee</td>
    <td align="center">&nbsp;</td>
    <td  align="right"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right">&nbsp;</td>
    <td align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(2)).doubleValue();
dBalance += dDebit;
%>
  <tr > 
    <td height="25" >&nbsp;</td>
    <td >Miscellaneous Fee</td>
    <td align="center">&nbsp;</td>
    <td  align="right"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right">&nbsp;</td>
    <td align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
    <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();
if(dDebit > 0f){
dBalance += dDebit;%>
    <tr > 
      <td height="25" >&nbsp;</td>
      <td >Other Charges</td>
      <td align="center">&nbsp;</td>
      <td  align="right"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right">&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%}
dDebit = ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
if(dDebit > 0f){
  dBalance += dDebit; %>
  <tr > 
    <td height="25" >&nbsp;</td>
    <td >Hands on</td>
    <td align="center">&nbsp;</td>
    <td  align="right"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right">&nbsp;</td>
    <td align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
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
      <td height="25" >&nbsp;</td>
      <td ><%=vTuitionFeeDetail.elementAt(6)%></td>
      <td align="center">&nbsp;</td>
      <td  align="right">&nbsp;
	  <%if(dDebit > 0f){%>
	  <%=CommonUtil.formatFloat(dDebit,true)%>
	  <%}%>
	  </td>
      <td align="right">&nbsp;
	  <%if(dCredit > 0f){%>
	  <%=CommonUtil.formatFloat(dCredit,true)%>
	  <%}%>
	  </td>
      <td align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
  <%}
} //for tuition fee detail.

//adjustment here
while( (iIndex = vAdjustment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dCredit = Float.parseFloat((String)vAdjustment.elementAt(iIndex-3));	
	dBalance -= dCredit;
%>
  <tr > 
    <td height="25" > <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <td ><%=(String)vAdjustment.elementAt(iIndex-4)%>(Grant)</td>
    <td align="center">&nbsp;</td>
    <td  align="right">&nbsp;</td>
    <td align="right"><%=CommonUtil.formatFloat(dCredit,true)%></td>
    <td align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
//remove the element here.
vAdjustment.removeElementAt(iIndex);vAdjustment.removeElementAt(iIndex-1);vAdjustment.removeElementAt(iIndex-2);
vAdjustment.removeElementAt(iIndex-3);vAdjustment.removeElementAt(iIndex-4);
}

//Refund here
while( (iIndex = vRefund.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dDebit = Float.parseFloat((String)vRefund.elementAt(iIndex-1));
	dBalance += dDebit;
%>
  <tr > 
    <td height="25" > <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <td ><%=(String)vRefund.elementAt(iIndex-3)%>(Refund)</td>
    <td align="center">&nbsp;</td>
    <td  align="right"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right">&nbsp;</td>
    <td align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
//remove the element here.
vRefund.removeElementAt(iIndex);vRefund.removeElementAt(iIndex-1);vRefund.removeElementAt(iIndex-2);
vRefund.removeElementAt(iIndex-3);
}
//dormitory charges
while( (iIndex = vDorm.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dDebit = Float.parseFloat((String)vDorm.elementAt(iIndex-1));
	dBalance += dDebit;
%>
  <tr > 
    <td height="25" > <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <td ><%=(String)vDorm.elementAt(iIndex-2)%></td>
    <td align="center">&nbsp;</td>
    <td  align="right"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right">&nbsp;</td>
    <td align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
//remove the element here.
vDorm.removeElementAt(iIndex);vDorm.removeElementAt(iIndex-1);vDorm.removeElementAt(iIndex-2);
}

//Other school fees/fine/school facility fee charges(except dormitory)
while( (iIndex = vOthSchFine.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dDebit = Float.parseFloat((String)vOthSchFine.elementAt(iIndex-1));
	dBalance += dDebit;
%>
  <tr > 
    <td height="25" > <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <td ><%=(String)vOthSchFine.elementAt(iIndex-2)%></td>
    <td align="center">&nbsp;</td>
    <td  align="right"><%=CommonUtil.formatFloat(dDebit,true)%></td>
    <td align="right">&nbsp;</td>
    <td align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
//remove the element here.
vOthSchFine.removeElementAt(iIndex);vOthSchFine.removeElementAt(iIndex-1);vOthSchFine.removeElementAt(iIndex-2);
}

//vPayment goes here, ;-)
while( (iIndex = vPayment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dCredit = Float.parseFloat((String)vPayment.elementAt(iIndex-2));
	dBalance -= dCredit;
%>
  <tr > 
    <td height="25" > <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
    <td ><%=WI.getStrValue((String)vPayment.elementAt(iIndex-1))%>(<%=(String)vPayment.elementAt(iIndex+1)%>)</td>
    <td align="center">&nbsp;</td>
    <td  align="right">&nbsp;<%if(dCredit < 0d){%><%=CommonUtil.formatFloat(-1 * dCredit,true)%><%}%></td>
    <td align="right">&nbsp;<%if(dCredit > 0d){%><%=CommonUtil.formatFloat(dCredit,true)%><%}%></td>
    <td align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
  </tr>
  <%
//remove the element here.
vPayment.removeElementAt(iIndex+2);vPayment.removeElementAt(iIndex+1);vPayment.removeElementAt(iIndex);
vPayment.removeElementAt(iIndex-1);vPayment.removeElementAt(iIndex-2);
}%>
  <%
}%>
</table>

<script language="JavaScript">
window.print();

</script>
<%}//only if vTimeSch is not null

} //only if basic info is not null;
%>
</body>
</html>
<%
dbOP.cleanUP();
%>