<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	
	if(strSchoolCode == null) {%>
		<p style="font-size:16px; font-weight:bold; color:#FF0000">
			Session Expired. Please login again.
		</p>
	<%return;
}

	boolean bolIsFatima = strSchoolCode.startsWith("FATIMA");
	double dInstallmentFee = 0d;
	String strPlanInfo     = null;
	double dAddDropFee     = 0d;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Statement Of Account</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function ReloadPage() {
	document.form_.print_pg.value = "";
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusID() {
	document.form_.stud_id.focus();
}
function AjaxMapName() {
	var strSearchCon = "";
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

	// if this page is calling print page, i have to forward page to print page.
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {
			if(strSchoolCode.startsWith("CDD")){%>
				<jsp:forward page="./statement_of_account_print_CDD.jsp" />
			<%}if(strSchoolCode.startsWith("SWU")){%>
				<jsp:forward page="./statement_of_account_print_SWU.jsp" />
			<%}if(strSchoolCode.startsWith("VMA")){%>
				<jsp:forward page="./statement_of_account_print_vma.jsp" />
			<%}if(strSchoolCode.startsWith("UB")){%>
				<jsp:forward page="./cert_enrol_billing_ched_print_UB.jsp" />
			<%}else{%>
				<jsp:forward page="./statement_of_account_print.jsp" />
			<%	return;
			}
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
int iAccessLevel = 1;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
							//							"statement_of_account.jsp");
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

double dTutionFee     = 0d;
double dCompLabFee    = 0d;
double dMiscFee       = 0d;
double dOutstanding   = 0d;
double dMiscOtherFee = 0d;//This is the misc fee other charges,

double dOtherSchPayable = 0d;//for CSA, i have to show total adjustment + other school payable.. 

float fTotalDiscount = 0f;
float fDownpayment   = 0f;
float fTotalAmtPaid  = 0f;
float fEnrolmentDiscount = 0f;//discount / fines during enrollment.

boolean bolIsBasic = false;

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();
StatementOfAccount SOA = new StatementOfAccount();
if(!strSchoolCode.startsWith("CIT"))
vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
					WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
if(vStudInfo == null) {
	strErrMsg = enrlStudInfo.getErrMsg();
	if(strErrMsg == null)
		strErrMsg = "";
}
else {
	if(vStudInfo.elementAt(2) == null) 
		bolIsBasic = true;
	paymentUtil.setIsBasic(bolIsBasic);
	fOperation.setIsBasic(bolIsBasic);
	FA.setIsBasic(bolIsBasic);
	
		
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
}
if(strErrMsg == null) //collect fee details here.
{
	dTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(dTutionFee > 0)
	{
		dMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		dCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
				WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
		dOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));

		dMiscOtherFee = fOperation.getMiscOtherFee();

		fTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),null);
		fDownpayment   = fOperation.calAmoutPaidDurEnrollment(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		fTotalAmtPaid  = fOperation.calTotalAmoutPaidPerFee(dbOP, 0,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

		//calculate discount during enrollment.
		enrollment.FAFeeOperationDiscountEnrollment faEnrlDiscount =
								new enrollment.FAFeeOperationDiscountEnrollment();
    	vTemp = faEnrlDiscount.calEnrollmentDateDiscount(dbOP,(float)dTutionFee, (float)(dTutionFee + dMiscFee + dCompLabFee),
		(String)vStudInfo.elementAt(0),false, WI.fillTextValue("sy_from"),
        	WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),
        	fOperation.dReqSubAmt);
    	if (vTemp != null && vTemp.size() > 0 && vTemp.elementAt(0) != null) {
      		fEnrolmentDiscount = ( (Float) vTemp.elementAt(1)).floatValue();
      		//System.out.println(fEnrolmentDiscount);
			fTotalDiscount += fEnrolmentDiscount;
    	}
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
	if(fOperation.vMultipleOCMapInfo != null && fOperation.vMultipleOCMapInfo.size() > 0) 
		vMiscFeeInfo.addAll(fOperation.vMultipleOCMapInfo);
	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");
	}
}

if(strErrMsg == null)
{
	//I have to call this.. not sure why. but if i do nto call, the finals is not correct for SPC/.. etc.. 
	//vScheduledPmt = FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
     //   						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	//System.out.println("vScheduledPmt: "+vScheduledPmt);
	//if(vScheduledPmt == null)
	//	strErrMsg = FA.getErrMsg();
	//else 
		vScheduledPmt = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

	if(vScheduledPmt == null)
		strErrMsg = FA.getErrMsg();
	//System.out.println("vScheduledPmt: "+vScheduledPmt);
}

String strPrintedBy = CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1);
if(strErrMsg == null)
{
	vSubjectDtls = SOA.getEnrolledSubSummary(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                      WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vSubjectDtls == null || vSubjectDtls.size() ==0)
		strErrMsg = SOA.getErrMsg();

	
	///get here the other other school fee and adjustment payable.. 
	if(true){
		vTemp = FA.getOtherChargePayable(dbOP,WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester"), (String)vStudInfo.elementAt(0));
		if(vTemp != null && vTemp.size() > 0) {
			strTemp = (String)vTemp.elementAt(0);
			if(strTemp != null && !strTemp.equals("0.00"))
				dOtherSchPayable = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		}
	}
	if(bolIsFatima) { 
		dAddDropFee = 0d;//new enrollment.FAFeeMaintenance().addDropFeePayabaleBalance(dbOP, (String)vStudInfo.elementAt(0), WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
		if(dAddDropFee < 0d)
			dAddDropFee = 0d; 
		dOtherSchPayable = dOtherSchPayable - dAddDropFee;		

		String strSQLQuery = "select PLAN_NAME from FA_STUD_MIN_REQ_DP_PER_STUD "+
							"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.plan_ref = FA_STUD_MIN_REQ_DP_PER_STUD.plan_ref) "+
							" where is_temp_stud = 0 and stud_index = "+vStudInfo.elementAt(0)+
							" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester");
		strPlanInfo = dbOP.getResultOfAQuery(strSQLQuery, 0);

		if(strPlanInfo != null) {
			strSQLQuery = "select sum(fa_stud_payable.amount) from fa_stud_payable join fa_oth_sch_fee on (fa_oth_sch_fee.othsch_fee_index = reference_index) where user_index = "+
						vStudInfo.elementAt(0) +" and fa_stud_payable.sy_from = "+WI.fillTextValue("sy_from")+
						" and fa_stud_payable.semester = "+WI.fillTextValue("semester")+" and fa_stud_payable.is_valid = 1 and fee_name like 'installment%'";//reference_index = 582";//fee name is Installment Fee and sy_index = 0;
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null) {
				dInstallmentFee = Double.parseDouble(strSQLQuery);
				dOtherSchPayable = dOtherSchPayable - dInstallmentFee;
			}
		}
	}

	 
}
dbOP.cleanUP();


String[] astrConvertYrLevel = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
if(strErrMsg == null) strErrMsg = "";
%>
<form name="form_" action="./statement_of_account.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          STUDENT STATEMENT OF ACCOUNTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2">Statement of Account type</td>
      <td width="24%" height="25">School year </td>
      <td width="44%">Term</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><select name="report_type">
          <option value="0">Current SA</option>
<%
strTemp = WI.fillTextValue("report_type");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Educational Plans</option>
<%}else{%>
          <option value="1">Educational Plans</option>
<%}%>        </select></td>
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
      </td>
      <td height="25"><select name="semester">
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

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">Enter Student ID </td>
      <td width="11%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();"></td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="69%"><%if(!strSchoolCode.startsWith("CIT")){%>
	  	<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
	  <%}%>	  </td>
    </tr>
    <tr>
      <td></td>
      <td colspan="3"></td>
      <td><label id="coa_info" style="position:relative"></label></td>
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
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="6">Name of Student :<strong><%=((String)vStudInfo.elementAt(1)).toUpperCase()%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="6">
	  <%if(!bolIsBasic) {%>
		  Course/Major - Year : <strong><%=(String)vStudInfo.elementAt(2)%>
    	    <%
	  	if(vStudInfo.elementAt(3) != null){%>
       		/<%=(String)vStudInfo.elementAt(3)%>
        	<%}%>
        	- <%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%></strong>
	   <%}else{%>
	   	Grade Level: <b><%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0")))%></b>
	   <%}%>
      </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="18" colspan="6">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">No. of units enrolled in :</td>
      <td colspan="4"> <%if(strSchoolCode.startsWith("LNU")){%> <%=(String)vSubjectDtls.elementAt(2)%> <%=(String)vSubjectDtls.elementAt(3)%>
        <%if(fOperation.getRatePerUnit() > 0f){%>
		 @ <%=fOperation.getRatePerUnit()%><%}%>
        <%}%>
      </td>
    </tr>
    <%
if(vSubjectDtls != null && vSubjectDtls.size() > 0 && !strSchoolCode.startsWith("LNU") ) {
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td width="14%">Lecture </td>
      <td width="3%">:</td>
      <td colspan="2"> <%=(String)vSubjectDtls.elementAt(0)%> <%=(String)vSubjectDtls.elementAt(3)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>Laboratory</td>
      <td>:</td>
      <td colspan="2"><%=(String)vSubjectDtls.elementAt(1)%> <%=(String)vSubjectDtls.elementAt(3)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>P.E.</td>
      <td width="3%">:</td>
      <td colspan="2"><%=(String)vSubjectDtls.elementAt(4)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>NSTP-ROTC</td>
      <td>:</td>
      <td colspan="2"><%=(String)vSubjectDtls.elementAt(5)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>Total</td>
      <td>:</td>
      <td colspan="2"><%=(String)vSubjectDtls.elementAt(2)%> <%=(String)vSubjectDtls.elementAt(3)%></td>
    </tr>
    <%}//only if subject detail is not null;%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="5">Total Tuition Fees &nbsp;&nbsp;&nbsp;- - - - - - - - - -
        - - - - - - - - - - - - - - - - - - - - - - - - </td>
      <td width="34%">P&nbsp;&nbsp;&nbsp;<%=CommonUtil.formatFloat(dTutionFee,true)%></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="5">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
  </table>
<%if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && dTutionFee > 0)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="6"><strong>Miscellaneous Fees :</strong></td>
    </tr>
    <%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
		continue;
	}%>
    <tr>
      <td height="24" width="2%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="27%"><%=(String)vMiscFeeInfo.elementAt(i)%></td>
      <td width="18%">- - - - - - - - - - - - </td>
      <td width="5%">P</td>
      <td width="6%" align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
      <td width="38%">&nbsp;</td>
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
 <%}//if misc fee is not null
 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="22%" ><strong>Total Miscellaneous Fees </strong></td>
      <td width="43%" >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - -
        - - - - - - </td>
      <td width="3%">P&nbsp;&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dMiscFee - dMiscOtherFee,true)%> <div align="right"></div></td>
      <td width="20%">&nbsp;</td>
    </tr>
  </table>
<%
if(dMiscOtherFee > 0d){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="6"><strong>Other Charges :</strong></td>
    </tr>
<%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		continue;
	}
	%>
    <tr>
      <td height="24" width="2%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="27%"><%=(String)vMiscFeeInfo.elementAt(i)%></td>
      <td width="18%">- - - - - - - - - - - - </td>
      <td width="5%">P</td>
      <td width="6%" align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
      <td width="38%">&nbsp;</td>
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
 <%}//if misc fee is not null
 %>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 <%
if(dMiscOtherFee > 0d){%>
   <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%" ><strong>Total Other Charge</strong></td>
      <td width="43%">- - - - - - - - - - - - - - - - - - - - - - - - - - - -
        - - -</td>
      <td width="3%">&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dMiscOtherFee,true)%></td>
      <td width="20%">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%" ><strong>Computer Lab. Fee</strong></td>
      <td width="43%" >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -      </td>
      <td width="3%">&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dCompLabFee,true)%> </td>
      <td width="20%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td ><strong>Old Account </strong></td>
      <td >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - </td>
      <td>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dOutstanding,true)%></td>
      <td>&nbsp;</td>
    </tr>
<%if(strSchoolCode.startsWith("CSA") || strSchoolCode.startsWith("VMA") || dOtherSchPayable > 0) {%>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%" ><strong>Other School Fee + Adjustments</strong></td>
      <td width="43%" >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -      </td>
      <td width="3%">&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dOtherSchPayable,true)%> </td>
      <td width="20%">&nbsp;</td>
    </tr>
<%}%>
<%if(bolIsFatima && dInstallmentFee > 0d) {%>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%" ><strong>Installment Fee</strong></td>
      <td width="43%" >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -      </td>
      <td width="3%">&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dInstallmentFee,true)%> </td>
      <td width="20%">&nbsp;</td>
    </tr>
<%}if(dAddDropFee > 0d ){%>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%" ><strong>Add/Drop Charges</strong></td>
      <td width="43%" >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -      </td>
      <td width="3%">&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(dAddDropFee,true)%> </td>
      <td width="20%">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td ><strong>Total Fees Due</strong></td>
      <td >&nbsp;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -      </td>
      <td>&nbsp;</td>
      <td><div align="right"><strong><%=CommonUtil.formatFloat(dTutionFee+dCompLabFee+dMiscFee+dOutstanding + dOtherSchPayable + dInstallmentFee + dAddDropFee,true)%></strong></div></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(!strSchoolCode.startsWith("LNU")){%>  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td colspan="6" >Less: </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td >Discount (grants,scholarships etc.)</td>
      <td >- - - - - - - - - - - - - - -</td>
      <td width="3%">P&nbsp;&nbsp;</td>
      <td align="right" width="10%"><%=CommonUtil.formatFloat(fTotalDiscount,true)%></td>
      <td width="20%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="4%" ><font color="#0000FF">&nbsp;</font></td>
      <td width="39%" >Downpayment</td>
      <td width="22%">- - - - - - - - - - - - - - - </td>
      <td>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(fDownpayment,true)%></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td >Amount paid by the student </td>
      <td >- - - - - - - - - - - - - - - </td>
      <td>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(fTotalAmtPaid,true)%></td>
      <td>&nbsp;</td>
    </tr>
    <!--
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" ><em><font color="#0000FF" size="1">do not show amount to be paid
        by edu plans if not Educational Plan</font></em></td>
    </tr>
-->
    <%
if(WI.fillTextValue("report_type").compareTo("1") ==0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" >Amount to be paid by Educational plan</td>
      <td >- - - - - - - - - - - - - - - </td>
      <td> <strong>P</strong></td>
      <td align="right"><strong><%=CommonUtil.formatFloat((dTutionFee+dCompLabFee+dMiscFee-fTotalAmtPaid-fTotalDiscount),true)%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <%}
else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" ><strong>OUTSTANDING BALANCE </strong></td>
      <td >&nbsp;</td>
      <td ><strong>P</strong></td>
      <td align="right"><strong><%=CommonUtil.formatFloat((dTutionFee+dCompLabFee+dMiscFee-fTotalAmtPaid-fTotalDiscount+dOutstanding + dOtherSchPayable + dInstallmentFee+dAddDropFee),true)%></strong></td>
      <td >&nbsp;</td>
    </tr>
<%
if(!strSchoolCode.startsWith("LNU")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="6" >&nbsp;</td>
    </tr>
<%if(strPlanInfo != null) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="6" ><font size="2" style="font-weight:bold"><u>Plan Subscribed: <%=strPlanInfo.toUpperCase()%></u></font></td>
    </tr>
<%}%>
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td colspan="6" >Payment Schedule: </td>
    </tr>
    <%
if(vScheduledPmt != null && vScheduledPmt.size() > 0) {%>
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td colspan="6" >
	  	<table border="0" width="50%" class="thinborder" align="left" cellpadding="0" cellspacing="0">
			<%
			for(int i = 7; i < vScheduledPmt.size(); i += 2) {
			double dTemp = ((Double)vScheduledPmt.elementAt(i + 1)).doubleValue();
			if(dTemp < 0d) {
				if( (i + 3) <  vScheduledPmt.size()) {
					vScheduledPmt.setElementAt(new Double(((Double)vScheduledPmt.elementAt(i + 3)).doubleValue() + dTemp), i + 3);
				}
				dTemp = 0d;
				
			}%>
			<tr>
				<td class="thinborder" style="font-size:12px;"><%=vScheduledPmt.elementAt(i)%></td>
				<td class="thinborder" style="font-size:12px;"><%=CommonUtil.formatFloat(dTemp, true)%></td>
			</tr>
			<%}%>
	  	</table>
	  
	  </td>
    </tr>
<%
				}//if(vScheduledPmt != null && vScheduledPmt.size() > 0) 
				
			}//if(!strSchoolCode.startsWith("LNU"))
	
		}//if(!strSchoolCode.startsWith("LNU"))
	
	}//only if report type is current SA.

}//if(vStudInfo != null && vStudInfo.size() > 0) %>
  </table>
<%if(strSchoolCode.startsWith("LNU") || strSchoolCode.startsWith("UI") ){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="10">&nbsp;</td>
      <td colspan="2" >&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2" ><strong>Approved by :</strong></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td width="16%">&nbsp;</td>
      <td width="79%">____________________________</td>
    </tr>
    <%if(strSchoolCode.startsWith("LNU")){%>
    <tr>
      <td height="16">&nbsp;</td>
      <td height="16" valign="top" ><font size="1">&nbsp;</font></td>
      <td height="16" valign="top" ><font size="1"> <%=strPrintedBy.toUpperCase()%><br>
        <strong>Accts. Custodian </strong></font></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="16">&nbsp;</td>
      <td height="16" valign="top" ><font size="1">&nbsp;</font></td>
      <td height="16" valign="top" ><font size="1"> MR. PAUL E. NECESARIO<br>
        Accountant </font></td>
    </tr>
    <%}%>
  </table>
<%}else if(strErrMsg == null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="10">&nbsp;</td>
      <td colspan="2" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" >Prepared by :</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="91%"><u><%=strPrintedBy%></u></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" valign="top" >&nbsp;</td>
    </tr>
</table>
<%}%>
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
	//}//only if student information is found.
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
