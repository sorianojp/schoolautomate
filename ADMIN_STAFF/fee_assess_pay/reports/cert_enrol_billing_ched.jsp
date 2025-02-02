<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED Enrollment and billing statement</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script>
function ReloadPage() {
	document.financial_report.print_pg.value = "";
	document.financial_report.submit();
}
function PrintPg() {
	document.financial_report.print_pg.value = "1";
	document.financial_report.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=financial_report.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();">
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./cert_enrol_billing_ched_print.jsp" />
	<%	return;
	}

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


vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
					WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
if(vStudInfo == null) strErrMsg = enrlStudInfo.getErrMsg();
else
{
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
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

///get school code here. 
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
boolean bolIsUDMC = false;
if(strSchCode == null)
	strSchCode = "";
//strSchCode = "SPC";

boolean bolIsHTC = strSchCode.startsWith("HTC");
boolean bolIsSPC = strSchCode.startsWith("SPC");
	
if(strSchCode.startsWith("UDMC"))
	bolIsUDMC = true;


String[] astrConvertYrLevel = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
if(strErrMsg == null) strErrMsg = "";
%>
<form name="financial_report" method="post" action="./cert_enrol_billing_ched.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          CERTIFICATE OF ENROLMENT AND BILLING (CHED) PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=strErrMsg%></b></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%">School year </td>
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
        </select>
&nbsp;&nbsp;&nbsp;
<%if(bolIsUDMC){
strTemp = WI.fillTextValue("is_internal");
if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>
<input type="checkbox" name="is_internal" value="1" <%=strTemp%>> 
<font size="1" color="#0000FF"><b>For Internal Certification</b></font>
<%}%>
	</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Enter Student ID </td>
      <td width="12%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="66%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="20">&nbsp;</td>
      <td width="23%" height="20">Scholarship Program: </td>
      <td colspan="3"><input type="text" name="scholarship_name" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></strong></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">1. Grant/Award Number : </td>
      <td height="20" colspan="3"><input type="text" name="grant_award_no" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">2. Student's Name : </td>
      <td width="23%" height="20"><strong><%=(String)vStudInfo.elementAt(12)%></strong></td>
      <td width="22%"><strong><%=(String)vStudInfo.elementAt(10)%></strong></td>
      <td width="30%"><strong>
	  <%
	  if(vStudInfo.elementAt(11) != null){%>
	  <%=((String)vStudInfo.elementAt(11)).charAt(0)%>.</strong>
	  <%}%></td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td height="19">&nbsp;</td>
      <td height="19" valign="top"><font size="1"><em>Surname</em></font></td>
      <td><font size="1"><em>Firstname</em></font></td>
      <td><em><font size="1">M.I.</font></em></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">3. Sex : <strong><u><%=(String)vStudInfo.elementAt(13)%></u></strong></td>
      <td height="20" colspan="3">4. Course : <u><strong><%=(String)vStudInfo.elementAt(2)%>
        <%
	  if(vStudInfo.elementAt(3) != null){%>
        /<%=(String)vStudInfo.elementAt(3)%>
        <%}%>
        </strong></u></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20" colspan="4">5. Year Level : <u><strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%></strong></u></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="20">&nbsp;</td>
      <td width="33%">6. (A) Subjects Enrolled</td>
      <td width="12%">(B) Units</td>
      <td width="53%">7. Semestral Fees</td>
    </tr>
	<tr>
		<td width="2%" style="font-size: 16px;">&nbsp;</td>
		<td colspan="2" width="45%" valign="top">
			<%
			if(vSubList != null && vSubList.size() > 0){%>
			<table width="100%" border="0" cellpadding="0" bgcolor="#FFFFFF">
				<%
				for(int i=1; i<vSubList.size();++i)
				{%>
				<tr>
					<td width="4%">&nbsp; </td>
					<td width="74%" style="font-size: 9px;"><%=(String)vSubList.elementAt(i+3)%>(<%=(String)vSubList.elementAt(i+4)%>)</td>
					<td width="22%" style="font-size: 9px;"><%=(String)vSubList.elementAt(i+13)%></td>
			   </tr>
			   <%
			   i = i+13;
			   }%>
			   <tr>
					<td width="4%">&nbsp; </td>

            <td width="74%" align="right" style="font-size: 9px;"><strong>Total 
              Unit(s)</strong> &nbsp;&nbsp;&nbsp;</td>
					<td width="22%" style="font-size: 9px;"><%=(String)vSubList.elementAt(0)%></td>
			   </tr>
		    </table>
		<%}//only if vSubList is not null%>
		</td>
		<td width="53%" valign="top">
			<table width="100%" border="0" cellpadding="0" bgcolor="#FFFFFF">
			<tr>
				<td width="5%">&nbsp;</td>

            <td width="61%" style="font-size: 9px;"><strong>Tuition fee</strong></td>

            <td width="34%" style="font-size: 9px;"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></td>
			</tr>
			<tr>
				<td width="5%">&nbsp;</td>

            <td width="61%" style="font-size: 9px;"><strong>Computer Lab fee</strong></td>

            <td width="34%" style="font-size: 9px;"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></td>
			</tr>
			<tr>
				<td width="5%">&nbsp;</td>

            <td width="61%" style="font-size: 9px;"><strong>Miscellaneous fee(TOTAL)</strong></td>

            <td width="34%" style="font-size: 9px;"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></td>
			</tr>
    <%
for(int i=0; i<vMiscFeeInfo.size(); i += 3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
		continue;
	}%>
			<tr>
				<td width="5%">&nbsp;</td>
				<td width="61%" style="font-size: 9px;">&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>

            <td width="34%" style="font-size: 9px;">
			<%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
			</tr>
<%}
if(fMiscOtherFee > 0f) {%>
			<tr>
				<td width="5%">&nbsp;</td>

            <td width="61%" style="font-size: 9px;"><strong>Other fee(TOTAL)</strong></td>

            <td width="34%" style="font-size: 9px;"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></td>
			</tr>
<%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		continue;
	}%>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="61%" style="font-size: 9px;">&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
			<td width="34%" style="font-size: 9px;"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
		</tr>
	<%}//end of for loop
}//end of fMiscOtherFee if it is > 0f%>

			</table>
		</td>
	</tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="20">&nbsp;</td>
      <td colspan="2" valign="bottom"><div align="center"><%=(String)vStudInfo.elementAt(1)%>
        </div></td>
      <td width="3%" height="20">&nbsp;</td>
      <td width="3%" height="20">&nbsp;</td>
      <td height="20" colspan="2"><hr size="1" width="80%" align="left"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="2" valign="top"><div align="center">
          <hr size="1">
        </div></td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td width="32%" height="20"><font size="1">Gross Total</font></td>
      <td width="18%" height="20"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></strong></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><font size="1">Student
          Grantee</font></div></td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20"><font size="1">Amount Payable</font></td>
      <td height="20"><input type="text" name="amt_payable" class="textbox" size="12"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td width="33%">&nbsp;</td>
      <td width="7%">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>

    <tr>
		<%
		
		strTemp = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1));
		%>
      <td width="50%" height="25" align="center"><%if(!bolIsHTC){%><%=strTemp%><%}else{%>
	  <input type="text" name="college_registrar" value="<%=WI.fillTextValue("college_registrar")%>"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" class="textbox">
	  <%}%>
	  </td>
      <td width="50%"> <div align="center">
	  <%
	  strTemp  ="sch_coordinator";
	  strErrMsg = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"Scholarship Coordinator",1));
	  if(bolIsSPC){
		strTemp = "comptroller_name";
		strErrMsg = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"Comptroller",1));
		}
	if(bolIsHTC){
		strTemp = "checked_by";
		strErrMsg = WI.fillTextValue(strTemp);
	}
	  %>
	  <input type="text" name="<%=strTemp%>" value="<%=strErrMsg%>">
	  </div></td>
    </tr>
    <tr>
	<%
	strTemp = "University";
	if(bolIsHTC)
		strTemp = "College";
	%>
      <td height="25"><div align="center"><font size="1"><%=strTemp%> Registrar</font></div></td>
      <td><div align="center">
	  <%if(strSchCode.startsWith("CGH")){%>
        <input type="text" name="sch_coordinator_2" value="<%=WI.fillTextValue("sch_coordinator_2")%>">
	  <%}else{
	  	strTemp = "Scholoarship Coordinator";
		if(bolIsSPC)
			strTemp = "Comptroller";
		if(bolIsHTC)
			strTemp = "Checked By";
	  %>
	  	<%=strTemp%>
	  <%}%>
      </div></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="50%" height="25" style="padding-right:50px;">
	  <%if(bolIsSPC){%>
	  <div align="right">
	  	<input type="checkbox" name="print_assessment_only" value="1" <%=strErrMsg%>>Click to print assessment only
	  </div>
	  <%}%>
	  </td>
      <td colspan="4" height="25"><div align="left"><font size="1"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
          to print report</font></font></font></div></td>
      <td width="2%" height="25" colspan="3">&nbsp;</td>
    </tr>
	</table>



<%}//only if vCHEDScholar is not null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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
