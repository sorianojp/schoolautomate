<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>School Facility Fee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ComputeAmount(strAmountPerUnit)
{
	document.fa_payment.cal_amount.value =
	eval(strAmountPerUnit)*eval(document.fa_payment.no_of_unit.value);

	if(document.fa_payment.cal_amount.value == "NaN")
		document.fa_payment.cal_amount.value = "";
}
function ShowHideApprovalNo()
{
/*	if(document.fa_payment.payment_mode.selectedIndex == 2)
	{
		document.fa_payment.approval_number.disabled = false;
		showLayer('approval_');id="approval_"
		//document.page_auth.oth_mem_type.style ="font-family:Verdana, Arial, Helvetica, sans-serif;";
	}
	else
	{
		//document.page_auth.oth_mem_type.style ="border: 0;font-family:Verdana, Arial, Helvetica, sans-serif;";
		hideLayer('approval_');
		document.fa_payment.approval_number.disabled = true;
	}
*/
}
function ShowHideCheckNO()
{
	if(document.fa_payment.payment_type.selectedIndex == 1)
	{
		document.fa_payment.check_number.disabled = false;
		showLayer('approval_');
		//document.page_auth.oth_mem_type.style ="font-family:Verdana, Arial, Helvetica, sans-serif;";
	}
	else
	{
		//document.page_auth.oth_mem_type.style ="border: 0;font-family:Verdana, Arial, Helvetica, sans-serif;";
		hideLayer('approval_');
		document.fa_payment.check_number.disabled = true;
	}
}
function ReloadPage()
{
	document.fa_payment.payment_stat.value = document.fa_payment.pmt_status[document.fa_payment.pmt_status.selectedIndex].text;
	document.fa_payment.addRecord.value="0";
	document.fa_payment.submit();
}
function ReloadPageNoSubmit()
{
	document.fa_payment.addRecord.value="0";
}
function AddRecord()
{
	<%
	if(strSchoolCode.startsWith("CPU") || strSchoolCode.startsWith("CLDH") || strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("DBTC") || 
	strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("FATIMA")){%>
		this.SukliComputation();
	<%}//show Sukli computation%>
	document.fa_payment.addRecord.value="1";
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=fa_payment.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
///this is added for CLDH and CPU only.
function SukliComputation() {
	return;
	var vAmtPaid = document.fa_payment.amount.value;

	var vAmtReceived  = prompt("Please enter Amount received.", vAmtPaid);
    if(vAmtReceived == null || vAmtReceived.length == 0)  {
		vAmtReceived = vAmtPaid;
	}
	document.fa_payment.sukli.value = vAmtReceived;
}

function AjaxUpdateChange() {
		var strAmtPaid     = document.fa_payment.amount.value;
		var strAmtTendered = document.fa_payment.amount_tendered.value;
		if(strAmtPaid.length == 0 || strAmtTendered.length == 0)
			return;
		
		var objCOAInput = document.getElementById("change_");
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=152&amt_tendered="+strAmtTendered+"&amt_paid="+strAmtPaid;
		this.processRequest(strURL);
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.Authentication,enrollment.FASchoolFacility,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strAmount = null;Vector vTemp = null;
	String strStudStatus = WI.fillTextValue("stud_status");


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-School faclities fees","school_facilities.jsp");
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
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"school_facilities.jsp");
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
boolean bolIsStaff = false; //true only if the payee type is internal and not a student type.

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FASchoolFacility schFacility = new FASchoolFacility();
//System.out.println(request.getParameter("payment_for"));
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") ==0)
{
	if(schFacility.savePayment(dbOP,request))//always false for tution / fine payment
	{
		dbOP.cleanUP();
		String strSukli = WI.fillTextValue("sukli");
		if(strSukli.length() > 0) {
			//keep change in attribute.
			double dAmtReceived = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("sukli"),",",""));
			dAmtReceived = dAmtReceived - Double.parseDouble(WI.fillTextValue("amount"));
			strSukli = "&sukli="+ CommonUtil.formatFloat(dAmtReceived,true);
		}
		response.sendRedirect(response.encodeRedirectURL("./schoolfacfees_print_receipt.jsp?or_number="+
		request.getParameter("or_number")+strSukli));
		return;
	}
	else
		strErrMsg = schFacility.getErrMsg();
}
if(strStudStatus.compareTo("0") == 0)//only if student id is entered.
{
	vBasicInfo = paymentUtil.getStudBasicInfo(dbOP, request.getParameter("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
	{
	 	strErrMsg = paymentUtil.getErrMsg();
		bolIsStaff = true;
		request.setAttribute("emp_id",request.getParameter("stud_id"));
		vBasicInfo = new Authentication().operateOnBasicInfo(dbOP, request,"0");
		if(vBasicInfo != null)
			strErrMsg = null;
	}
	//System.out.println(strErrMsg);
}
if(strStudStatus == null || strStudStatus.trim().length() ==0)
{
	strErrMsg = "Please select payee status type.";
}
else
{
	if(request.getParameter("sy_from") == null || request.getParameter("sy_from").trim().length() ==0 ||
		request.getParameter("sy_to") == null 	|| request.getParameter("sy_to").trim().length() ==0)
	{
		strErrMsg = "Please enter school year from/to.";
	}
	if(strStudStatus.compareTo("1") == 0)
	{
		if(request.getParameter("payee_name") == null  	|| request.getParameter("payee_name").trim().length() ==0)
			strErrMsg = "Please eneter name of payee.";
	}
}
if(strErrMsg == null) strErrMsg = "";
%>
<form name="fa_payment" action="./school_facilities.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF"><strong>::::
          SCHOOL FACILITIES FEES PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><strong><%=strErrMsg%></strong></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Accounts</td>
      <td  colspan="3"><select name="stud_status" onChange="ReloadPage();">
          <option value="0">Internal</option>
          <%
if(strStudStatus.compareTo("1") ==0){%>
          <option value="1" selected>External</option>
          <%}else{%>
          <option value="1">External</option>
          <%}%>
        </select></td>
    </tr>
    <%if(strStudStatus.compareTo("1") != 0){%>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%" height="25"> ID Number</td>
      <td width="15%"> <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td width="7%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="63%">&nbsp;</td>
    </tr>
    <%}else{%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Payee Name </td>
      <td colspan="3"><input name="payee_name" type="text" size="50" value="<%=WI.fillTextValue("payee_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
    <!-- this is current school year the payee is paying. if payee is paying for 2 times,
	I can differentiate for school year. -->
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Address</td>
      <td colspan="3"><input name="payee_addr" type="text" size="64" maxlength="128" value="<%=WI.fillTextValue("payee_addr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
    <%}//school year is necessary here, because of the payee type, if payee type is employee-Internal type, i need
	//school year -- so i have to keep school year here.
	%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">School Year</td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
	  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fa_payment","sy_from","sy_to")'>
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td colspan="2">Payment Status:
        <select name="pmt_status" onChange="ReloadPage();">
          <option value="0">New Payment/Full Payment</option>
          <%
strTemp = WI.fillTextValue("pmt_status");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Installment</option>
          <%}else{%>
          <option value="1">Installment</option>
          <%}if(strTemp.compareTo("2") ==0 && WI.fillTextValue("stud_status").compareTo("1") !=0){%>
          <option value="2" selected>Deposit (one time)</option>
          <%}else if(WI.fillTextValue("stud_status").compareTo("1") !=0){%>
          <option value="2">Deposit (one time)</option>
          <%}%>
        </select></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Term</td>
      <td><select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <%//show only if it is a deposit
if(strTemp.compareTo("2") ==0){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="3">Start Date of Occupancy (mm/dd/yyyy)</td>
      <td ><font size="1">
        <input name="occupancy_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("occupancy_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('fa_payment.occupancy_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font> </td>
    </tr>
    <%}%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="3"><input name="image" type="image" src="../../../images/form_proceed.gif" onClick="ReloadPageNoSubmit();"></td>
    </tr>
  </table>

<%
if(strErrMsg.length() == 0){ // the outer most condition.

if(vBasicInfo != null && vBasicInfo.size() > 0 && !bolIsStaff)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1">
	  <!-- enter here all hidden fields for student. -->
	  <input type="hidden" name="stud_index" value="<%=(String)vBasicInfo.elementAt(0)%>">
	  <input type="hidden" name="year_level" value="<%=(String)vBasicInfo.elementAt(4)%>">
	  </td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="39%" height="25">Student name :<strong> <%=(String)vBasicInfo.elementAt(1)%> </strong></td>
      <td width="59%" height="25"  colspan="4">Course :<strong><%=(String)vBasicInfo.elementAt(2)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Year :<strong><%=(String)vBasicInfo.elementAt(4)%></strong> </td>
      <td  colspan="4" height="25">Major : <strong><%=WI.getStrValue(vBasicInfo.elementAt(3))%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Term : <%=(String)vBasicInfo.elementAt(5)%></td>
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
  </table>
<%}//if student info is not null
else if(vBasicInfo != null && vBasicInfo.size() > 0 && bolIsStaff)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2" height="25"><hr size="1"> </td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="98%" height="25">Employee name :<strong>
	  <%=WI.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),1)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Employee type :<strong> <%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Employee status :<strong> <%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">College/Department or Office :<strong> <%=WI.getStrValue(vBasicInfo.elementAt(13))%>/<%=(String)vBasicInfo.elementAt(14)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}//end of displaying information.%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="25" colspan="9" bgcolor="#B9B292"><div align="center">FEE
          DETAILS </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="18">&nbsp;</td>
      <td width="38%" valign="bottom">School facility name</td>
      <td width="60%" valign="bottom">School facility type</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><select name="fee_name" onChange="ReloadPage();">
          <option value="0">Select a fee</option>
          <%
strTemp = WI.fillTextValue("sy_from");
strTemp2 = WI.fillTextValue("sy_to");
if(strTemp.length() ==0) strTemp = "0";
if(strTemp2.length() ==0) strTemp2 = "0";
//if pmt_status is 2-> deposits to open account - show only the multiple fee charges.
if(WI.fillTextValue("pmt_status").compareTo("2") ==0)
{
	strTemp = " from FA_SCH_FACILITY join FA_SCHYR on (FA_SCH_FACILITY.sy_index=FA_SCHYR.sy_index) "+
				"where is_del=0 and is_valid=1 and sy_from="+strTemp+" and sy_to="+strTemp2+" and facility_type=1 order by fee_name,facility_type asc";
}
else
{
	strTemp = " from FA_SCH_FACILITY join FA_SCHYR on (FA_SCH_FACILITY.sy_index=FA_SCHYR.sy_index) "+
				"where is_del=0 and is_valid=1 and sy_from="+strTemp+" and sy_to="+strTemp2+" order by fee_name,facility_type asc";
}
%>
          <%=dbOP.loadCombo("SCH_FAC_FEE_INDEX","FEE_NAME",strTemp, WI.fillTextValue("fee_name"), false)%>
        </select>
        <%
strTemp = WI.fillTextValue("fee_name");
if(strTemp.length() ==0) strTemp = "0";
request.setAttribute("info_index",strTemp);
vTemp = schFacility.opOnSchFacTypeSingleFee(dbOP, request,4,request.getParameter("sy_from"),request.getParameter("sy_to"));
if(vTemp != null)
	strAmount = (String)vTemp.elementAt(1);
//System.out.println(schFacility.getErrMsg());
%>
      </td>
      <td><strong>
	  <%if(strAmount != null){%>
	  Single fee charges
	  <input type="hidden" name="sch_fac_type" value="0">
	  <%}else if(WI.fillTextValue("fee_name").length() > 0 && WI.fillTextValue("fee_name").compareTo("0") != 0)
	  {%>Multiple fee charges
	  <input type="hidden" name="sch_fac_type" value="1">
	  <%}%></strong></td>
    </tr>
</table>
<%
//do not show fee details if the payment is for deposits only.
if(WI.fillTextValue("pmt_status").compareTo("2") !=0 && strAmount != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="18">&nbsp;</td>
      <td width="38%">Unit</td>
      <td width="60%">Fee rate</td>
    </tr>
    <tr >
      <td height="24">&nbsp;</td>
      <td><strong><%=(String)vTemp.elementAt(3)%></strong>
      <td><strong><%=strAmount%></strong></td>
    </tr>
<%
if(WI.fillTextValue("pmt_status").compareTo("1") !=0){%>
    <tr >
      <td height="18">&nbsp; </td>
      <td>Usage (in nos)</td>
      <td>Amount payable (fee rate * usage)</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td><input name="no_of_unit" type="text" size="8" onKeyUp='ComputeAmount("<%=strAmount%>");' value="<%=WI.fillTextValue("no_of_unit")%>"></td>
      <td><input type=text name="cal_amount" size="20" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;" value="<%=WI.fillTextValue("cal_amount")%>" readonly="yes"></td>
    </tr>
<%}%>
    <tr >
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
//show this only if payment type is multiple charges, and get the outstanding balance and the current month charge detail.
//and if the payment is for installment or full payment.
}if(vTemp != null && ((String)vTemp.elementAt(2)).compareTo("1") ==0 && WI.fillTextValue("pmt_status").compareTo("2") !=0){
//get fee payable detail.
Vector vPayable = schFacility.getSchFacPayablePerMonth(dbOP,(String)vBasicInfo.elementAt(0),request.getParameter("fee_name"),null,null);
float fPrevBalance = 0;
if(vPayable != null)
	schFacility.calSchFacMulOutStandBal(dbOP,(String)vBasicInfo.elementAt(0),request.getParameter("fee_name"),
						(String)vPayable.elementAt(1),(String)vPayable.elementAt(1));
if(vPayable == null)
	strErrMsg = schFacility.getErrMsg();

String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","Septmber","October","November","December"};
float fTotalPayable = fPrevBalance;
if(vPayable == null){%>
<table width="100%" bgcolor="#FFFFFF">
<tr>
<td><strong><%=strErrMsg%></strong></td></tr></table>
<%
}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#CFCAB4">
      <td height="18"  colspan="4"><div align="center"><font size="1">CHARGES
          DETAILS FOR THE MONTH OF <strong><%=astrConvertMonth[Integer.parseInt((String)vPayable.elementAt(1))]%></strong>
		  YEAR <strong><%=(String)vPayable.elementAt(0)%></strong>(for multiple charges)</font></div></td>
    </tr>
    <tr>
      <td width="2%" height="18"><font size="1">&nbsp;</font></td>
      <td width="33%" height="25" valign="bottom"><font size="1"><strong><u>CHARGES</u></strong></font></td>
      <td width="33%" valign="bottom"><font size="1"><strong><u>UNIT </u></strong></font></td>
      <td width="32%" valign="bottom"><font size="1"><strong><u>AMOUNT (Php)</u></strong></font></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="25" valign="bottom">&nbsp;</td>
      <td valign="bottom">-- Previous outstanding balance --</td>
      <td valign="bottom"><%=fPrevBalance%></td>
    </tr>
<%
if(vPayable == null || vPayable.size() < 3){%>
	<tr>
      <td height="18">&nbsp;</td>
      <td height="25" valign="bottom">No charges posted for this month.</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">0</td>
    </tr>
<%}else{
for(int i=2; i< vPayable.size() ; ){
%>
<tr>
      <td height="18">&nbsp;</td>
      <td height="25" valign="bottom"><%=(String)vPayable.elementAt(i++)%></td>
      <td valign="bottom"><%=(String)vPayable.elementAt(i++)%></td>
      <td valign="bottom"><%=(String)vPayable.elementAt(i++)%></td>
    </tr>
<%
	fTotalPayable += Float.parseFloat((String)vPayable.elementAt(i-1));
	}
}%>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="25" valign="bottom">&nbsp;</td>
      <td valign="bottom"><div align="right"><strong><font size="2">TOTAL AMOUNT
          PAYABLE&nbsp;-&gt;&nbsp;&nbsp;&nbsp;</font><font size="1">&nbsp;</font></strong>&nbsp;</div></td>
      <td valign="bottom"><strong>Php <%=fTotalPayable%></strong></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="25" valign="bottom">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
    </tr>
  </table>

 <%	}//only if the payment type is multiple entry type.

 //}//if pmt status is != 2
 if(WI.fillTextValue("fee_name").length() > 0 && WI.fillTextValue("fee_name").compareTo("0") != 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5"><div align="center">PAYMENT DETAILS </div></td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
			<div id="change_div">
			<table cellpadding="0" cellspacing="0">
      			<td style="font-size:18px;">Change: &nbsp;</td>
      			<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
			</table>
		</div>		
	  </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%">Amount paid :</td>
      <td width="27%"><input name="amount" type="text" size="16" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();">
        Php </td>
      <td width="16%">Check # :</td>
      <td width="34%">
        <%
strTemp = "";
if(request.getParameter("payment_type") == null || 	 request.getParameter("payment_type").trim().length() ==0 ||
	request.getParameter("payment_type").compareTo("0") == 0)
{
	strTemp = "disabled";
}%>
        <input name="check_number" type="text" size="16" value="<%=WI.fillTextValue("check_number")%>" <%=strTemp%> id="approval_" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
<%
if(strTemp.compareTo("disabled") ==0){
%>
<script language="JavaScript">
hideLayer('approval_');
</script>
<%}%>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Amount Tendered </td>
      <td>
	  		<input name="amount_tendered" type="text" size="16" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();">
	  </td>
      <td>Date paid :</td>
      <td><font size="1">
<%
strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%>        <input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payment type :</td>
      <td> <select name="payment_type" onChange="ShowHideCheckNO();">
          <option value="0">Cash</option>
          <%
 strTemp = WI.fillTextValue("payment_type");
 if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Check</option>
          <%}else{%>
          <option value="1">Check</option>
          <%}%>
        </select> </td>
      <td>Ref. number :</td>
      <td><font size="1"><b>
        <!--       <%
	   	//strTemp = paymentUtil.generateORNumber(dbOP);
	   //	if(strTemp == null)
	   //		strTemp = paymentUtil.getErrMsg();
		//else{%>
        <input type="hidden" name="or_number" value="<%//=strTemp%>">
        <%//}%>
        <%//=strTemp%> -->
        <input name="or_number" type="text" size="18" value="<%=paymentUtil.generateORNumber(dbOP,(String)request.getSession(false).getAttribute("userIndex"), true)%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </b></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payment receive type :</td>
      <td> <select name="pmt_receive_type" onChange="ReloadPage();">
          <option value="Internal">Internal</option>
          <%
strTemp = WI.fillTextValue("pmt_receive_type");
if(strTemp.compareTo("External") ==0){%>
          <option value="External" selected>External</option>
          <%}else{%>
          <option value="External">External</option>
          <%}%>
        </select> </td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <% if(strTemp.compareTo("External") ==0) //External
{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Bank name :</td>
      <td> <select name="bank">
          <%=dbOP.loadCombo("AB_INDEX","AFF_BANK_NAME"," from FA_AFFILIATED_BANK where is_del=0 order by AFF_BANK_NAME asc",
   		request.getParameter("bank"), false)%> </select> <font size="1">(if External)</font></td>
      <td colspan="2"></td>
    </tr>
    <%}//only if receive type is external
%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="9"><hr size="1"></td>
    </tr>
<%if(iAccessLevel > 1){%>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td colspan="3" height="25"><input type="image" src="../../../images/save.gif" onClick="AddRecord();"></a><font size="1">click
        to save payment detail</font></td>
      <td width="10%"  height="25">&nbsp;</td>
    </tr>
<%}%>
</table>
<%	}//only if there is a fee selected.
}//if error message is null -> outer most condition.
%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	<td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

 <input type="hidden" name="addRecord" value="0">
 <input type="hidden" name="payment_stat">

 <input type="hidden" name="sukli">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
