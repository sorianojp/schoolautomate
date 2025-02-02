<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED Enrollment and billing statement</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
 }

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script>
function ReloadPage() {
	document.financial_report.print_pg.value = "";
	document.financial_report.submit();
}
function PrintPg() {
	document.bgColor = "#FFFFFF";
    document.getElementById('myADTable1').deleteRow(0);
    document.getElementById('myADTable1').deleteRow(0);
    
	document.getElementById('myADTable2').deleteRow(0);

    document.getElementById('myADTable3').deleteRow(0);
    document.getElementById('myADTable3').deleteRow(0);
    document.getElementById('myADTable3').deleteRow(0);

    document.getElementById('myADTable4').deleteRow(0);
    document.getElementById('myADTable4').deleteRow(0);
    
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=financial_report.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" topmargin="100">
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
								"Admin/staff-Fee Assessment & Payments-REPORTS","cert_enrol_billing_ched.jsp");
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
														"cert_enrol_billing_ched.jsp");
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


float fTutionFee     = 0f;
float fCompLabFee    = 0f;
float fMiscFee       = 0f;
float fOutstanding   = 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,

float fTotalDiscount = 0f;
float fDownpayment   = 0f;
float fTotalAmtPaid  = 0f;

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
						WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vStudInfo == null) 
		strErrMsg = enrlStudInfo.getErrMsg();
	else
	{
		vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
			(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
			(String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
			WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
		if(vMiscFeeInfo == null)
			strErrMsg = paymentUtil.getErrMsg();
	}
}
if(strErrMsg == null && vStudInfo != null) //collect fee details here.
{
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(fTutionFee > 0)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		fOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));

		fMiscOtherFee = fOperation.getMiscOtherFee();

		fTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),null);
		fDownpayment   = fOperation.calAmoutPaidDurEnrollment(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		fTotalAmtPaid  = fOperation.calTotalAmoutPaidPerFee(dbOP, 0,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

	}
	else
		strErrMsg = fOperation.getErrMsg();
}
//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null && vStudInfo != null)
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
String[] astrConvertSem     = {"Summer","1ST SEM","2ND SEM","3RD SEM","4TH SEM","5TH SEM"};
%>
<form name="financial_report" method="post" action="./auf_certification(scholarship).jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          ACCOUNT CERTIFICATION (SCHOLARSHIP) ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
<%
//if(strErrMsg != null) {
//	dbOP.cleanUP();
//	return;
//}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%">SY</td>
      <td height="25" colspan="2">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("financial_report","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td width="66%">Term
        <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr> 
      <td height="25" colspan="6"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Enter ID </td>
      <td width="12%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="27%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></td>
      <td width="39%">
	  <%if(strErrMsg == null && vStudInfo != null){%>
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print report after pressing SAVE icon</font>
	  <%}%>
	  </td>
    </tr>
    <tr> 
      <td height="20" colspan="6"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0)
{%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="5%">&nbsp;</td>
      <td colspan="6"><div align="right"><%=WI.getTodaysDate(6)%></div></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="4">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="38" colspan="7"><div align="center"> <strong><font size=5>C&nbsp;&nbsp;E&nbsp;&nbsp;R&nbsp;&nbsp;T&nbsp;&nbsp;I&nbsp;&nbsp;F&nbsp;&nbsp;I&nbsp;&nbsp;C&nbsp;&nbsp;A&nbsp;&nbsp;T&nbsp;&nbsp;I&nbsp;&nbsp;O&nbsp;&nbsp;N</font></strong></div></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="4">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5">TO WHOM IT MAY CONCERN :</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="5">&nbsp;</td>
      <td width="16%">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="7"><p>This is to certify that 
          <%if(((String)vStudInfo.elementAt(13)).startsWith("M")){%>
          MR. 
          <%}else{%>
          MS. 
          <%}%>
          <%=WebInterface.formatName((String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11),
	  	(String)vStudInfo.elementAt(12),6).toUpperCase()%></font> (<%=(String)vStudInfo.elementAt(2)%>) is presently enrolled in this University this <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%> of Academic Year <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%>.</p>
        <p>The breakdown of Tuition and Other Charges incurred are as follows:</p></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="5">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="19%">&nbsp;</td>
      <td width="32%">Tuition Fee</td>
      <td width="2%"> P </td>
      <td width="20%"><div align="right"><%=CommonUtil.formatFloat(fTutionFee,true)%> &nbsp;</div></td>
      <td width="6%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>Miscellaneous Fee</td>
      <td>&nbsp;</td>
      <td><div align="right"><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%> &nbsp;</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%
if(fCompLabFee > 0f){%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>Computer Lab Fee</td>
      <td>&nbsp;</td>
      <td><div align="right"><%=CommonUtil.formatFloat(fCompLabFee,true)%> &nbsp;</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%}
	
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		continue;
	}%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><%=(String)vMiscFeeInfo.elementAt(i)%></td>
      <td>&nbsp;</td>
      <td><div align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%> &nbsp;</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right"><img src="./singleline.jpg"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>TOTAL FEES</td>
      <td>P</td>
      <td><div align="right"><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%> &nbsp;</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right"><img src="./doubleline.jpg"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="7">This certification is issued upon the request of 
        <%if(((String)vStudInfo.elementAt(13)).startsWith("M")){%>
        MR. 
        <%}else{%>
        MS. 
        <%}%> <%=((String)vStudInfo.elementAt(12)).toUpperCase()%> for scholarship purposes.</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="5">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="5">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="45">&nbsp;</td>
      <td colspan="5">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="3">Mr. Rudy J. Cruz</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="3">Head, Accounts Management</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}//only if vCHEDScholar is not null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
 	<tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
