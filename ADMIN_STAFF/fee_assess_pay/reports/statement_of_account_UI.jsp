<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintPg() {
	var pgLoc = "./statement_of_account_UI_print.jsp?stud_id="+
		document.form_.stud_id.value+"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+"&semester="+
		document.form_.semester[document.form_.semester.selectedIndex].value+
		"&report_type="+document.form_.report_type[document.form_.report_type.selectedIndex].value<%if(request.getParameter("pmt_schedule") != null){%>+
		"&pmt_schedule="+document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value<%}%>;

	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function ReloadPage() {
	document.form_.print_pg.value = "";
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc);//,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusID() {
	document.form_.stud_id.focus();
}

function AjaxMapName() {
	var strSearchCon = "&search_temp=2";
		var strCompleteName = "";
		if(document.form_.stud_id)
			strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 3)
			return;
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
		//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	this.ReloadPage();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,EnrlReport.StatementOfAccount,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strSchoolCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if (strSchoolCode.startsWith("VMA"))
		strSchoolCode = "DBTC_";

	// if this page is calling print page, i have to forward page to print page.
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./statement_of_account_UI_print.jsp" />
	<%	return;
	}
	if(strSchoolCode != null && strSchoolCode.startsWith("VMA")) {
		response.sendRedirect("./statement_of_account.jsp");
		return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","statement_of_account.jsp");
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
														"statement_of_account.jsp");
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
Vector vScheduledPmt = null;
Vector vSubjectDtls  = null;

double dDebit = 0f;
double dBalance = 0d;
double dTemp = 0d;

Vector vTuitionFeePaymentDtls = null;

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

//use the leder to get all details.
enrollment.FAStudentLedger faStudLedg = new enrollment.FAStudentLedger();
Vector vLedgerInfo = null;

Vector vTimeSch = null;
Vector vAdjustment = null;
Vector vRefund = null;
Vector vDorm = null;
Vector vOthSchFine = null;
Vector vPayment = null;
Vector vTuitionFeeDetail = null;
///////////// end of using ledger to get all information.


StatementOfAccount SOA = new StatementOfAccount();


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
//	else {//do not display misc fee detail
//		vMiscFeeInfo = new Vector();//new design
//	}
}
if(strErrMsg == null) {//collect fee details here.
	vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vStudInfo.elementAt(0),request.getParameter("sy_from"),
	request.getParameter("sy_to"),null,request.getParameter("semester"), false);//bolShowOnlyDroppedSub=false
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
}//System.out.println(vAdjustment);
//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null)
{
	//get misc fee.
	fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	//the above method set the laboratory deposit information. so i have to call.

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
String strExamDueDate = null;
Vector vScheduledPmtNew = null;
double dDueForThisPeriod = 0d;
String strPmtScheduleName  = null;
if(WI.fillTextValue("pmt_schedule").length() > 0){
		strPmtScheduleName = dbOP.mapOneToOther("FA_PMT_SCHEDULE","pmt_sch_index",
			WI.fillTextValue("pmt_schedule"),"exam_name",null);

	strPmtScheduleName  = WI.getStrValue(strPmtScheduleName);

	if (strPmtScheduleName.toLowerCase().indexOf("Final") != -1
		 && WI.fillTextValue("print_final").equals("1")){
		 strPmtScheduleName = " Final"; // force to final
	}
}

if(strErrMsg == null && !strSchoolCode.startsWith("AUF"))
{
	vScheduledPmt = FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(vScheduledPmt == null)
		strErrMsg = FA.getErrMsg();
	else {
		if(strPmtScheduleName.length() > 0) {
			int iIndexOf = vScheduledPmt.indexOf(strPmtScheduleName);
			if(iIndexOf > -1)
				strExamDueDate = (String)vScheduledPmt.elementAt(iIndexOf + 1);
		}
		
		vScheduledPmtNew = FA.getPaymentDueForAnExam(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),
								WI.fillTextValue("pmt_schedule"),strPmtScheduleName);
		if(vScheduledPmtNew != null) {
			dDueForThisPeriod = ((Double)vScheduledPmtNew.elementAt(3)).doubleValue();
			if(dDueForThisPeriod < 0d)
				dDueForThisPeriod = 0d;
		}
			
		//System.out.println(vScheduledPmtNew);
	}	
}
String strPrintedBy = CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1);
if(strErrMsg == null)
{
	vSubjectDtls = SOA.getEnrolledSubSummary(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                      WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vSubjectDtls == null || vSubjectDtls.size() ==0)
		strErrMsg = SOA.getErrMsg();
	vTuitionFeePaymentDtls = SOA.getTuitionFeeDetailForSA(dbOP, (String)vStudInfo.elementAt(0),
								WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	//System.out.println("Payment Info: "+vScheduledPmt);
}

String[] astrConvertYrLevel = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
%>
<form name="form_" action="./statement_of_account_UI.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          STUDENT STATEMENT OF ACCOUNTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
<%//if(strErrMsg != null) {
	//dbOP.cleanUP();
	//return;
//}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2">Statement of Account type</td>
      <td width="36%" height="25">School year </td>
      <td width="33%"><%if(!strSchoolCode.startsWith("AUF")){%>Exam Period<%}%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><select name="report_type">
          <option value="0">Current SA</option>
        </select></td>
      <td height="25">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
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
        </select> </td>
      <td height="25">
        <%if(!strSchoolCode.startsWith("AUF")){%>
        <select name="pmt_schedule">
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        </select>
        <%}%>
      </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="10%"> Student ID </td>
      <td width="19%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();"></td>
      <td width="8%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="61%">
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td colspan="3"><label id="coa_info" style="position:relative"></label></td>
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
      <td width="14" height="25">&nbsp;</td>
      <td colspan="2">Name of Student :<strong>
	  <%=WebInterface.formatName((String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11),
	  	(String)vStudInfo.elementAt(12),4)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Course/Major - Year : <strong><%=(String)vStudInfo.elementAt(2)%>
        <%
	  if(vStudInfo.elementAt(3) != null){%>
        /<%=(String)vStudInfo.elementAt(3)%>
        <%}%>
        - <%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%></strong></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
  	<td width="50%" valign="top">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td width="4%"></td>
            <td width="76%">Tuition Fees</td>
            <td width="20%">
<%
dDebit = ((Double)vTuitionFeeDetail.elementAt(1)).doubleValue();
dBalance += dDebit;
%>
			<strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></td>
          </tr>
          <tr>
            <td></td>
            <td>Miscellaneous Fees</td>
            <td><strong>
<%
dDebit = ((Double)vTuitionFeeDetail.elementAt(2)).doubleValue();
dBalance += dDebit;
%>
			<%=CommonUtil.formatFloat((float)dDebit,true)%></strong></td>
          </tr>
          <%if(dDebit > 0d)
{//display mis fee detail.
	for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
		if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
			continue;
		}%>
          <!--<tr>
            <td></td>
            <td>&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
            <td><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
          </tr>-->
          <%}//end of for loop.
}//if misc fee is not null

dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();

if(dDebit > 0d){
dBalance += dDebit;%>
          <!-- do not display
		  <tr>
            <td></td>
            <td>Other Charges</td>
            <td><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></td>
          </tr> -->
          <%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		continue;
	}
	%>
          <tr>
            <td></td>
            <td><%=(String)vMiscFeeInfo.elementAt(i)%></td>
            <td><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
          </tr>
          <%}
}//end of displaying other Charges.

//show hands on.
dDebit = ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
if(dDebit > 0d){
dBalance += dDebit;%>
          <!-- HANDS ON -->
		  <tr>
            <td></td>
            <td>Hands On</td>
            <td><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></td>
          </tr>

<%}
//show now all the other facilities taken by student like internet card - printing etc.
dDebit = ((Double)vOthSchFine.elementAt(0)).doubleValue();

if(dDebit > 0d){
dBalance += dDebit;%>
          <!-- do not display
		  <tr>
            <td></td>
            <td>Other Charges</td>
            <td><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></td>
          </tr>-->
          <%
for(int i = 1; i< vOthSchFine.size(); i +=3) {%>
          <tr>
            <td></td>
            <td><%=(String)vOthSchFine.elementAt(i)%></td>
            <td><%=CommonUtil.formatFloat((String)vOthSchFine.elementAt(i+1),true)%></td>
          </tr>
          <%}
}//end of displaying other Charges.

%>
          <tr>
            <td></td>
            <td>&nbsp;</td>
            <td>---------</td>
          </tr>
          <tr>
            <td></td>
            <td>Total Assessment</td>
            <td><strong><%=CommonUtil.formatFloat((float)dBalance,true)%></strong></td>
          </tr>
          <tr>
            <td></td>
            <td>Back Account</td>
            <td>
<%
dDebit = ((Double)vTuitionFeeDetail.elementAt(0)).doubleValue();
dBalance += dDebit;
%>			<strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></td>
          </tr>
          <tr>
            <td></td>
            <td>Total Charges</td>
            <td><strong><%=CommonUtil.formatFloat((float)dBalance,true)%></strong></td>
          </tr>
        </table>
	</td>
  	  <td width="50%" valign="top">
	  <table width="100%" cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td colspan="2">TOTAL CHARGES</td>
            <td width="31%"><strong><%=CommonUtil.formatFloat((float)dBalance,true)%></strong></td>
          </tr>
          <tr>
            <td colspan="2">LESS PAYMENTS/ADJUSTMENTS</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td width="47%">Date/OR #</td>
            <td width="22%">AMOUNT</td>
            <td>&nbsp;</td>
          </tr>
          <%
if(vPayment != null && vPayment.size() > 0){
	for(int i = 0; i < vPayment.size(); i += 6){
		dDebit = Double.parseDouble((String)vPayment.elementAt(i));
		dTemp += dDebit;
	%>
          <tr>
            <td><%=ConversionTable.convertMMDDYYYY((java.util.Date)vPayment.elementAt(i + 2))%>&nbsp;&nbsp;&nbsp;
<%
//refund is called also.
if(	vPayment.elementAt(i + 1) == null) {%>
	<%=(String)vPayment.elementAt(i + 3)%>
<%}else{%>
			<%=(String)vPayment.elementAt(i + 1)%>
<%}%>			</td>
            <td><%=CommonUtil.formatFloat((float)dDebit,true)%></td>
            <td>&nbsp;</td>
          </tr>
<%}
dBalance -= dTemp;//end of for loop%>
          <tr>
            <td align="right">&nbsp;</td>
            <td>TOTAL PAID</td>
            <td><u><strong><%=CommonUtil.formatFloat(dTemp,true)%></strong></u></td>
          </tr>
<%}else{//no payment -- whichi is not possible - because there has to be a downpayment.%>
          <tr>
            <td>&nbsp;</td>
            <td>0.00</td>
            <td>&nbsp;</td>
          </tr>
 <%}
 //show enrollment discount if there is any.
 if(vTuitionFeeDetail.elementAt(5) != null){
dDebit = ((Double)vTuitionFeeDetail.elementAt(5)).doubleValue();
dBalance -= dDebit;
%>
		  <tr>
            <td><%=vTuitionFeeDetail.elementAt(6)%></td>
            <td>&nbsp;</td>
            <td><u><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></u></td>
          </tr>
<%}
//show here grant / adjustmnet details.
if(vAdjustment != null && vAdjustment.size() > 1){
	for(int i = 1; i < vAdjustment.size(); i += 7) {

dDebit = Double.parseDouble((String)vAdjustment.elementAt(i + 1));
dBalance -= dDebit;
	%>
		  <tr>
            <td><%=(String)vAdjustment.elementAt(i)%></td>
            <td>&nbsp;</td>
            <td><u><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></u></td>
          </tr>
<%}//end of for loop

}//show if adjustment is valid.

//now get refund.
for(int i = 0; i < vRefund.size() ; i += 4) {
	dDebit = Double.parseDouble((String)vRefund.elementAt(i + 2));
	dBalance += dDebit;
%>
          <tr>
            <td><%=WI.getStrValue(vRefund.elementAt(i + 1))%> (Refund)</td>
            <td>&nbsp;</td>
            <td><strong><%=CommonUtil.formatFloat((float)dDebit,true)%></strong></td>
          </tr>
<%}%>
          <tr>
            <td>BALANCE</td>
            <td>&nbsp;</td>
            <td><strong><%=CommonUtil.formatFloat((float)dBalance,true)%></strong></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
<%//System.out.println(vScheduledPmt);
if(vScheduledPmt != null && vScheduledPmt.size() > 0) {%>
          <tr>
            <td colspan="3"><strong>Amount Due this <%=strPmtScheduleName%> Examination: <%=CommonUtil.formatFloat((float)dDueForThisPeriod,true)%></strong></td>
          </tr>
        <tr>
          <td><%if(strExamDueDate != null) {%>Due Date : <%=strExamDueDate%><%}%></td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
<%
}//end of if condition
%>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
        </table>

	  </td>
  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><a href="javascript:PrintPg();">
	  <img src="../../../images/print.gif" border="0"></a><font size="1">click
          to print statement of account</font></td>
      <td width="1%" height="25" colspan="3">&nbsp;</td>
  </table>
<%
	}//only if student information is found.
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
