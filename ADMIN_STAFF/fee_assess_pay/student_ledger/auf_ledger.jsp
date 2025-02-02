<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	document.getElementById('myADTable1').deleteRow(0);
	window.print();
}
function FocusID() {
	document.stud_ledg.stud_id.focus();
}
function ReloadPage() {
	document.stud_ledg.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=stud_ledg.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function studIDInURL() {
	var studID = document.stud_ledg.stud_id.value;
	if(studID.length > 0)
		document.stud_ledg.id_in_url.value = escape(studID);
	else
		document.stud_ledg.id_in_url.value = "";
	ReloadPage();
}
function ViewAUFLedger() {
	location = "./auf_ledger.jsp?stud_id="+document.stud_ledg.stud_id.value+
		"&sy_from="+document.stud_ledg.sy_from.value+
		"&sy_to="+document.stud_ledg.sy_to.value+
		"&semester="+document.stud_ledg.semester[document.stud_ledg.semester.selectedIndex].value;
}
</script>
<body topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,enrollment.EnrlAddDropSubject,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

//forward the page here.
if(WI.fillTextValue("show_all").compareTo("1") ==0){
	response.sendRedirect("./student_ledger_viewall.jsp?stud_id="+WI.fillTextValue("id_in_url"));
	return;
}

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = {"SU","FS","SS","TS"};

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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","STUDENT LEDGER",request.getRemoteAddr(),
														"student_ledger.jsp");
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


Vector vBasicInfo = null;
Vector vLedgerInfo = null;

Vector vTimeSch = null;
Vector vAdjustment = null;
Vector vRefund = null;
Vector vDorm = null;
Vector vOthSchFine = null;
Vector vPayment = null;
Vector vAddedSub = null;
Vector vDroppedSub = null;



Vector vTuitionFeeDetail = null;


FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAStudentLedger faStudLedg = new FAStudentLedger();
EnrlAddDropSubject eADS = new EnrlAddDropSubject();

if(WI.fillTextValue("stud_id").length() > 0)
{
	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"),
	request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));
	if(vBasicInfo == null)
		vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
		strErrMsg = paymentUtil.getErrMsg();
	else//check if this student is called for old ledger information.
	{
		int iDisplayType = faStudLedg.isOldLedgerInformation(dbOP, (String)vBasicInfo.elementAt(0),request.getParameter("sy_from"),
											request.getParameter("sy_to"),request.getParameter("semester"));
		if(iDisplayType ==-1) //Error.
		{
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=faStudLedg.getErrMsg()%></font></p>
			<%
			dbOP.cleanUP();
			return;
		}
		if(iDisplayType ==1)//this is called for old ledger information.
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./old_student_ledger_view.jsp?stud_id="+request.getParameter("stud_id")+"&sy_from="+
				request.getParameter("sy_from")+"&sy_to="+request.getParameter("sy_to")+"&semester="+request.getParameter("semester")));
			return;
		}
	}
	//check if the applicant is having reservation already, if so - take directly to the print page,
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{//long lTime = new java.util.Date().getTime();
		boolean bolShowOnlyDroppedSub = false;
		if(WI.fillTextValue("show_dropped_only").length() > 0)
			bolShowOnlyDroppedSub = true;
		vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vBasicInfo.elementAt(0),request.getParameter("sy_from"),
			request.getParameter("sy_to"),null,request.getParameter("semester"), bolShowOnlyDroppedSub);
		if(vLedgerInfo == null)
			strErrMsg = faStudLedg.getErrMsg();
		else
		{//System.out.println( (new java.util.Date().getTime() - lTime)/1000);
			vTimeSch 			= (Vector)vLedgerInfo.elementAt(0);
			vTuitionFeeDetail	= (Vector)vLedgerInfo.elementAt(1);
			vAdjustment			= (Vector)vLedgerInfo.elementAt(2);
			vRefund				= (Vector)vLedgerInfo.elementAt(3);
			vDorm 				= (Vector)vLedgerInfo.elementAt(4);
			vOthSchFine			= (Vector)vLedgerInfo.elementAt(5);//System.out.println(vOthSchFine);
			vPayment			= (Vector)vLedgerInfo.elementAt(6);
			if(vTimeSch == null || vTimeSch.size() ==0)
				strErrMsg = faStudLedg.getErrMsg();
		}

	}
}

//System.out.println(vDroppedSub);
if(strErrMsg == null) strErrMsg = "";
dbOP.cleanUP();
%>
<form name="stud_ledg" action="./student_ledger.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFDD">
      <td width="100%" height="25" class="thinborderNONE" style="font-size:11px;" onMouseMove="">
	  <strong><%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%>, <%=WI.fillTextValue("sy_from")%> <%=WI.fillTextValue("sy_to")%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp; <%=strErrMsg%></td>
    </tr>
  </table>

  <%
if(vBasicInfo != null && vBasicInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="72%" height="25"><strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td width="26%" height="25"  colspan="4"><strong><%=request.getParameter("stud_id")%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><strong><%=(String)vBasicInfo.elementAt(14)%></strong></td>
      <td  colspan="4" height="25" valign="top"><strong> <%=(String)vBasicInfo.elementAt(2)%>
          <%
	  if(vBasicInfo.elementAt(3) != null){%>
          -
        <%=WI.getStrValue(vBasicInfo.elementAt(3))%>
<%}%>
      </strong></td>
    </tr>
  </table>

<%
if(vTimeSch != null && vTimeSch.size() > 0){
float fBalance = ((Double)vTuitionFeeDetail.elementAt(0)).floatValue();
float fCredit = 0;
float fDebit = 0;
String strTransDate = null;
int iIndex = 0;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td width="11%" height="25" align="center" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td width="40%" align="center" bgcolor="#B9B292" class="thinborder"><strong><font size="1">REFERENCE</font></strong></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>CHARGES</strong></font></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>PAYMENTS</strong></font></td>
      <td width="17%" align="center" class="thinborder"><font size="1"><strong>BALANCE</strong></font></td>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>ACCTG CLERK</strong></font></td>
    </tr>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <td colspan="3" class="thinborder">BALANCE FORWARDED<%=faStudLedg.getDormOldAccountInfo(true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(fBalance,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <%
int iIndexOf = 0;
for(int i=0; i<vTimeSch.size(); ++i){
strTransDate = ConversionTable.convertMMDDYYYY((Date)vTimeSch.elementAt(i));

if(vTuitionFeeDetail.contains((Date)vTimeSch.elementAt(i))){
fDebit = ((Double)vTuitionFeeDetail.elementAt(1)).floatValue();
fBalance += fDebit;

%>
    <tr >
      <td height="25" class="thinborder"><%=strTransDate%></td>
      <td class="thinborder">TF</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(fDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(fBalance,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <%
fDebit = ((Double)vTuitionFeeDetail.elementAt(2)).floatValue();
fBalance += fDebit;
%>
    <tr >
      <td height="25" class="thinborder"><%=strTransDate%></td>
      <td class="thinborder">MISC</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(fDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(fBalance,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <%
fDebit = ((Double)vTuitionFeeDetail.elementAt(7)).floatValue();
if(fDebit > 0f){
fBalance += fDebit;%>
    <tr >
      <td height="25" class="thinborder"><%=strTransDate%></td>
      <td class="thinborder">OC</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(fDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(fBalance,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <%}
fDebit = ((Double)vTuitionFeeDetail.elementAt(3)).floatValue();
if(fDebit > 0f){
fBalance += fDebit;%>
    <tr >
      <td height="25" class="thinborder"><%=strTransDate%></td>
      <td class="thinborder">Hands on</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(fDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(fBalance,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <%}
//show this if there is any discounts.
if(vTuitionFeeDetail.elementAt(5) != null){
float fTemp = ((Double)vTuitionFeeDetail.elementAt(5)).floatValue();
if(fTemp > 0)
	fCredit = fTemp;
else
	fDebit  =  -1 * fTemp;
fBalance -= fTemp;

strTemp  = (String)vTuitionFeeDetail.elementAt(6);

	%>
    <tr >
      <td height="25" class="thinborder"><%=strTransDate%></td>
      <td class="thinborder"><%=strTemp%></td>
      <td  align="right" class="thinborder">&nbsp; <%if(fDebit > 0f){%> <%=CommonUtil.formatFloat(fDebit,true)%> <%}%> </td>
      <td align="right" class="thinborder">&nbsp; <%if(fCredit > 0f){%> <%=CommonUtil.formatFloat(fCredit,true)%> <%}%> </td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(fBalance,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <%}if(vTuitionFeeDetail.elementAt(8) != null){%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <td colspan="5" class="thinborder">NOTE : <%=(String)vTuitionFeeDetail.elementAt(8)%></td>
    </tr>
    <%}
} //for tuition fee detail.

//add or drop subject history here,

//adjustment here
//System.out.println(vAdjustment);
while( (iIndex = vAdjustment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	fCredit = Float.parseFloat((String)vAdjustment.elementAt(iIndex-3));
	fBalance -= fCredit;
%>
    <tr >
      <td height="25" class="thinborder">  <%=strTransDate%> </td>
      <td class="thinborder">DISC</td>
      <td  align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(fCredit,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(fBalance,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <%
//remove the element here.
vAdjustment.removeElementAt(iIndex);vAdjustment.removeElementAt(iIndex-1);vAdjustment.removeElementAt(iIndex-2);
vAdjustment.removeElementAt(iIndex-3);vAdjustment.removeElementAt(iIndex-4);
}

//Refund here
while( (iIndex = vRefund.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	fDebit = Float.parseFloat((String)vRefund.elementAt(iIndex-1));
	fBalance += fDebit;
%>
    <tr >
      <td height="25" class="thinborder"> <%=strTransDate%></td>
      <td class="thinborder">
	  <%if(vRefund.elementAt(iIndex - 2) != null){%>
	  <%=(String)vRefund.elementAt(iIndex-2)%>
	  <%}else{%>
	  <%=(String)vRefund.elementAt(iIndex-3)%>(Refund)
	  <%}%></td>
      <td  align="right" class="thinborder">
	  <%if(fDebit >= 0f){%> <%=CommonUtil.formatFloat(fDebit,true)%><%}%></td>
      <td align="right" class="thinborder">&nbsp;
	  <%if(fDebit < 0f){%> <%=CommonUtil.formatFloat(fDebit,true)%><%}%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(fBalance,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <%
//remove the element here.
vRefund.removeElementAt(iIndex);vRefund.removeElementAt(iIndex-1);vRefund.removeElementAt(iIndex-2);
vRefund.removeElementAt(iIndex-3);
}
//dormitory charges
while( (iIndex = vDorm.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	fDebit = Float.parseFloat((String)vDorm.elementAt(iIndex-1));
	fBalance += fDebit;
%>
    <tr >
      <td height="25" class="thinborder"><%=strTransDate%>  </td>
      <td class="thinborder"><%=(String)vDorm.elementAt(iIndex-2)%></td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(fDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(fBalance,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <%
//remove the element here.
vDorm.removeElementAt(iIndex);vDorm.removeElementAt(iIndex-1);vDorm.removeElementAt(iIndex-2);
}

//Other school fees/fine/school facility fee charges(except dormitory)
while( (iIndex = vOthSchFine.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	fDebit = Float.parseFloat((String)vOthSchFine.elementAt(iIndex-1));
	fBalance += fDebit;
%>
    <tr >
      <td height="25" class="thinborder"> <%=strTransDate%> </td>
      <td class="thinborder">OC</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(fDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(fBalance,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <%
//remove the element here.
vOthSchFine.removeElementAt(iIndex);vOthSchFine.removeElementAt(iIndex-1);vOthSchFine.removeElementAt(iIndex-2);
}

//vPayment goes here, ;-)
while( (iIndex = vPayment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	fCredit = Float.parseFloat((String)vPayment.elementAt(iIndex-2));
	fBalance -= fCredit;
strTemp = WI.getStrValue(vPayment.elementAt(iIndex+1));
iIndexOf = strTemp.indexOf(" Enrollment/downpayment");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf) + " - DP";
iIndexOf =  strTemp.indexOf(" - Cash");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf);
iIndexOf =  strTemp.indexOf(" - Check");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf);
iIndexOf =  strTemp.indexOf(" - SD");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf);
iIndexOf =  strTemp.indexOf(" Refunded");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf);
iIndexOf =  strTemp.indexOf(" Refund Transfered");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf);

if(fCredit < 0d)
	strTemp = "DM";
else if(vPayment.elementAt(iIndex-1) == null) //credit memo
	strTemp = "CM";

%>

    <tr >
      <td height="25" class="thinborder"> <%=strTransDate%></td>
      <td class="thinborder"> <%=WI.getStrValue(vPayment.elementAt(iIndex-1))%> <%=strTemp%>
	  </td>
      <td  align="right" class="thinborder">&nbsp;
	  <%//show only the refunds in debit column.
	  if(fCredit < 0d ||
	  	(vPayment.elementAt(iIndex+1) != null && ((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
	  <%=CommonUtil.formatFloat(-1 * fCredit,true)%>
	  <%}%></td>
      <td align="right" class="thinborder">&nbsp;
	  <%if(fCredit >= 0d &&
	  	(vPayment.elementAt(iIndex+1) == null || !((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
	  <%=CommonUtil.formatFloat(fCredit,true)%>
	  <%}%>	  </td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(fBalance,true)%></td>
      <td align="right" class="thinborder"><%=(String)vPayment.elementAt(iIndex + 3)%></td>
    </tr>
    <%
//remove the element here.
vPayment.removeElementAt(iIndex+3);
vPayment.removeElementAt(iIndex+2);
vPayment.removeElementAt(iIndex+1);
vPayment.removeElementAt(iIndex);
vPayment.removeElementAt(iIndex-1);
vPayment.removeElementAt(iIndex-2);
}%>
    <%
}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
      <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
        to print ledger</font></td>
      <td colspan="3" height="25">&nbsp;</td>
    </tr>
  </table>
<%}//only if vTimeSch is not null
%>
<input type="hidden" name="user_index" value="<%=(String)vBasicInfo.elementAt(0)%>">

<%} //only if basic info is not null;
%>
<input type="hidden" name="id_in_url">
</form>
</body>
</html>
