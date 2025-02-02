<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ShowHideCheckNO()
{
	if(document.form_.payment_type.selectedIndex == 1 || document.form_.payment_type.selectedIndex == 3) {
		document.form_.CHECK_FR_BANK_INDEX.disabled = false;
		document.form_.check_number.disabled = false;
	}
	else {
		document.form_.CHECK_FR_BANK_INDEX.selectedIndex = 0;
		document.form_.CHECK_FR_BANK_INDEX.disabled = true;
		document.form_.check_number.disabled = true;
	}
	//show or hide emp ID input fields.
	if(document.form_.payment_type.selectedIndex == 2)
	{
		showLayer('_empID');
		showLayer('_empID1');
		document.form_.hide_search.src = "../../../images/search.gif";
	}
	else
	{
		hideLayer('_empID');
		hideLayer('_empID1');
		document.form_.cash_adv_from_emp_id.value = "";
		document.form_.hide_search.src = "../../../images/blank.gif";
	}
	if(document.form_.payment_type.selectedIndex == 3)
		showLayer('myADTable1');
	else
		hideLayer('myADTable1');
	document.form_.chk_amt.value = "";
	document.form_.cash_amt.value = "";

}
function FullPayment() {
	document.form_.amount.value = "";
	this.ReloadPage();
}
function ReloadPage()
{
	document.form_.addRecord.value="";
	document.form_.submit();
}
function AddRecord()
{
	document.form_.addRecord.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function ChangePmtSchName()
{
	document.form_.pmt_schedule_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
}

function FocusID() {
		//alert("I am here."+document.form_.focus_2.value);
	if(document.form_.focus_2.value == '1') {

		document.form_.focus_2.focus();
	}
	else
		document.form_.sponsor_name.focus();
}
function OpenSearch(studPosIndex) {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id"+studPosIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearchFaculty() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.cash_adv_from_emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function computeCashChkAmt() {
	var totAmt  = document.form_.amount.value;
	var chkAmt  = document.form_.chk_amt.value;
	var cashAmt = document.form_.cash_amt.value;

	if(totAmt.length == 0)
		return;
	if(chkAmt.length == 0) {
		document.form_.cash_amt.value = "";
		return;
	}
	cashAmt = eval(totAmt - chkAmt);
	document.form_.cash_amt.value = eval(cashAmt);
}
function CopySponsorName() {
	document.form_.sponsor_name.value = document.form_.sponsor_name_ref[document.form_.sponsor_name_ref.selectedIndex].value;
}
function computeTotPmt() {
	var totPmt = 0;
	var maxStud = document.form_.tot_stud[document.form_.tot_stud.selectedIndex].value;
	var amount  = 0;
	for(i = 0; i < maxStud;++i) {
		amount = eval('document.form_.amount'+i+'.value');
		if(amount.length == 0)
			continue;
		totPmt = eval(totPmt) + eval(amount);
	}

	var totDebit = 0;
	var maxDebit = document.form_.tot_debit[document.form_.tot_debit.selectedIndex].value;
	for(i = 0; i < maxDebit;++i) {
		amount = eval('document.form_.amount_d'+i+'.value');
		if(amount.length == 0)
			continue;
		totDebit = eval(totDebit) + eval(amount);
	}
	document.form_.amount.value = eval(totPmt) - eval(totDebit);
}

//// - all about ajax..
var obj1;
var obj2;

function AjaxMapName(objStudID, labelName) {
	obj1 = objStudID;
	var objCOAInput = document.getElementById(labelName);
	obj2 = objCOAInput;
	
	var strCompleteName;
	strCompleteName = objStudID.value;
	if(strCompleteName.length < 2)
		return;

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	obj1.value = strID;
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	obj2.innerHTML = "";
}

var objCOA;
function AjaxCOA(objCOAInput, labelName,strCoaFieldName) {
	objCOA=document.getElementById(labelName);
	
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	///if blur, i must find one result only,, if there is no result foud
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
		objCOAInput.value+"&coa_field_name="+strCoaFieldName;
	this.processRequest(strURL);
}
function COASelected(strAccountName, objParticular) {
	objCOA.innerHTML = "";
}


</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.FAAssessment,enrollment.FAPaymentUtil,enrollment.FAPayment,java.util.Vector" buffer="16kb" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	WebInterface WI = new WebInterface(request);


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Sponsor Payment","sponsor_payment_new.jsp");
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
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(), null);
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

FAPayment faPayment = new FAPayment();
strTemp = WI.fillTextValue("addRecord");

if(strTemp != null && strTemp.compareTo("1") ==0)
{
	if(faPayment.saveSponsorPaymentNew(dbOP,request)){
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./otherschoolfees_print_receipt.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	else
		strErrMsg = faPayment.getErrMsg();
}

String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

int iNoOfStudSponsored = 0;
String strSYFrom = null;
String strSYTo   = null;
String strSemester = null;

if(strErrMsg == null)
	strErrMsg ="<font size=1>Note :</strong> If sponser is paying for <strong>downpayment during enrollment</strong>, Please validate the student";
%>

<form name="form_" action="./sponsor_payment_new.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          SPONSOR PAYMENT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(WI.fillTextValue("IS_FULL_PMT_INSTALLMENT").compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
%>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td> <%
strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() == 0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strSYFrom == null)
	strSYFrom = "";
%> <input name="sy_from" type="text" size="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strSYTo = WI.fillTextValue("sy_to");
if(strSYTo.length() == 0)
	strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strSYTo == null)
	strSYTo = "";
%> <input name="sy_to" type="text" size="4" value="<%=strSYTo%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester" style="font-size:10px+">
          <option value="1">1st Sem</option>
          <%
strSemester = WI.fillTextValue("semester");
if(strSemester.length() ==0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");
if(strSemester == null)
	strSemester = "";
if(strSemester.compareTo("2") ==0){%>
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
      <td>&nbsp;</td>
      <td width="56%">Date Paid:
        <%
strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%> <input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td rowspan="2" class="thinborderTOPLEFTBOTTOM" bgcolor="#99CCFF"><strong>SPONSOR NAME</strong> </td>
      <td colspan="3" class="thinborderTOPRIGHT" bgcolor="#99CCFF"><select name="sponsor_name_ref" style="font-size:10px" onclick="CopySponsorName();">
        <option value="">Select sponsor name</option>
        <%=dbOP.loadCombo("distinct NAME","name"," from FA_STUD_PAYMENT where is_valid = 1 and IS_SPONSOR = 1 and user_index is null order by FA_STUD_PAYMENT.name", request.getParameter("sponsor_name_ref"), false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" class="thinborderBOTTOMRIGHT" bgcolor="#99CCFF"><input name="sponsor_name" type="text" size="64" value="<%=WI.fillTextValue("sponsor_name")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Total student sponsored:
        <select name="tot_stud" onChange="ReloadPage();">
          <%
iNoOfStudSponsored = Integer.parseInt(WI.getStrValue(WI.fillTextValue("tot_stud"),"1"));
for(int i = 1; i <= 20; ++i) {
	if(i == iNoOfStudSponsored)
		strTemp = " selected";
	else
		strTemp = "";
%>
          <option value="<%=i%>" <%=strTemp%>><%=i%></option>
          <%}%>
        </select>
&nbsp;&nbsp;&nbsp;&nbsp;		</td>
      <td>NOTE:</td>
      <td> Select full pmt for full pmt discount &amp; d/pmt if paid for enrollment
        d/p </td>
    </tr>
    <%
for(int i = 0; i <iNoOfStudSponsored; ++i){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">
<%
strTemp = WI.fillTextValue("sy_from"+i);
if(strTemp.length() == 0)
	strTemp = strSYFrom;
%>
<input name="sy_from<%=i%>" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" style="font-size:10px;" tabindex='-1'>
	  -
<select name="semester<%=i%>" style="font-size:10px" tabindex='-1'>
          <option value="1">FS</option>
<%
strTemp = WI.fillTextValue("semester"+i);
if(strTemp.length() == 0)
	strTemp = strSemester;

if(strSemester == null)
	strSemester = "";
if(strSemester.compareTo("2") ==0){%>
          <option value="2" selected>SS</option>
          <%}else{%>
          <option value="2">SS</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>SU</option>
          <%}else{%>
          <option value="0">SU</option>
          <%}%>
        </select>	  </td>
      <td><input name="stud_id<%=i%>" type="text" size="16" value="<%=WI.fillTextValue("stud_id"+i)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(document.form_.stud_id<%=i%>,'coa_info<%=i%>');">
        <select name="pmt_schedule<%=i%>" style="font-size:10px" tabindex="-1">
	        <!--<option value="0">Down Payment</option>-->
          <%
//i have to check if i should use the fa_pmt_schedule_extn or fa_pmt_schedule table.

strTemp = dbOP.loadCombo("fa_pmt_schedule_extn.PMT_SCH_INDEX","EXAM_NAME",
		" from fa_pmt_schedule_extn  join fa_pmt_schedule on (fa_pmt_schedule_extn.pmt_sch_index = fa_pmt_schedule.pmt_sch_index)"+
		" where fa_pmt_schedule_extn.is_del=0 and fa_pmt_schedule_extn.is_valid=1 and sy_from="+strSYFrom+
		" and semester="+strSemester+
		 " order by fa_pmt_schedule_extn.EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"+i), false);
//System.out.println("Printing : "+(String)vStudInfo.elementAt(8)+","+(String)vStudInfo.elementAt(9)+","+(String)vStudInfo.elementAt(5));
if(strTemp.length() ==0) {
	//dbOP.resetQueryLoadCombo();
	strTemp = dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc",
		request.getParameter("pmt_schedule"+i), false);
}
%>
          <%=strTemp.toLowerCase()%> </select>
		  <label style="position:absolute" id="coa_info<%=i%>"></label>		  </td>
      <td valign="top"><!--<a href="javascript:OpenSearch(<%=i%>);"><img src="../../../images/search.gif" border="0"></a>--></td>
      <td valign="top">Amount:
        <input name="amount<%=i%>" type="text" size="12" value="<%=WI.fillTextValue("amount"+i)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount<%=i%>');computeTotPmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','amount<%=i%>');computeTotPmt();">		</td>
    </tr>
    <%}%>
    <tr>
      <td width="2%">&nbsp;</td>
      <td width="11%">&nbsp; </td>
      <td width="28%">&nbsp; </td>
      <td width="3%">&nbsp;</td>
      <td>&nbsp; </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" style="font-weight:bold; font-size:24;" class="thinborderBOTTOM" valign="bottom">:: DEBIT ENTRY ::   
	  </td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Number of Debit Entries: 
        <select name="tot_debit" onChange="document.form_.focus_2.value='1';ReloadPage();">
          <%
int iTotDebit = Integer.parseInt(WI.getStrValue(WI.fillTextValue("tot_debit"),"1"));
for(int i = 1; i <= 5; ++i) {
	if(i == iTotDebit)
		strTemp = " selected";
	else
		strTemp = "";
%>
          <option value="<%=i%>" <%=strTemp%>><%=i%></option>
          <%}%>
        </select>
	  </td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%
for(int i = 0; i <iTotDebit; ++i){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Chart of Account </td>
      <td height="25"><input name="coa<%=i%>" type="text" size="24" value="<%=WI.fillTextValue("coa"+i)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxCOA(document.form_.coa<%=i%>,'coa_<%=i%>','coa<%=i%>');">
	  
	  &nbsp;
	  <label style="position:absolute" id="coa_<%=i%>"></label>
	  
	  </td>
      <td height="25">&nbsp;</td>
      <td>Amount: 
      <input name="amount_d<%=i%>" type="text" size="12" value="<%=WI.fillTextValue("amount_d"+i)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount_d<%=i%>');computeTotPmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','amount_d<%=i%>');computeTotPmt();"></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center">PAYMENT
          DETAILS </div></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%" style="font-weight:bold; font-size:24;">OR AMOUNT  </td>
      <td width="28%">
	   <input name="amount" type="text" size="18" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount');computeCashChkAmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','amount');computeCashChkAmt();" style="font-size:20px; font-weight:bold"></td>
      <td width="8%"></td>
      <td width="44%"><input type="hidden" name="pmt_receive_type" value="Internal"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">Ref #</td>
      <td valign="top"><font size="1"><b>
        <input name="or_number" type="text" size="18" value="<%=new FAPaymentUtil().generateORNumber(dbOP,(String)request.getSession(false).getAttribute("userId"))%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </b></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Payment type</td>
      <td><font size="1">
        <select name="payment_type" onChange="ShowHideCheckNO();">
          <option value="0">Cash</option>
          <%
strTemp = WI.fillTextValue("payment_type");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Check</option>
<%}else{%>
          <option value="1">Check</option>
<%}%>
        </select>
        <br>
        <a href="javascript:OpenSearchFaculty();"></a>
        </font> </td>
      <td valign="top">Check #</td>
      <td valign="top"><font size="1">
        <%
strTemp = "";
if(request.getParameter("payment_type") == null || 	 request.getParameter("payment_type").trim().length() ==0 ||
	request.getParameter("payment_type").compareTo("0") == 0)
{
	strTemp = "disabled";
}%>
        <input name="check_number" type="text" size="16" value="<%=WI.fillTextValue("check_number")%>" <%=strTemp%> class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;&nbsp;&nbsp;
        <select name="CHECK_FR_BANK_INDEX" style="font-size:10px" >
          <option value=""></option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH",
		" from FA_BANK_LIST where is_valid = 1 order by bank_code", request.getParameter("CHECK_FR_BANK_INDEX"), false)%>
        </select>
      </font> </td>
    </tr>
  </table>
<script language="JavaScript">
this.ShowHideCheckNO();
this.computeTotPmt();
</script>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="9"><hr size="1"></td>
    </tr>
<%if(iAccessLevel > 1){%>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4" height="25"></td>
      <td colspan="3" height="25"><a href="javascript:AddRecord();">
	  		<img name="hide_save" src="../../../images/save.gif" border="0"></a>
        <font size="1">click to save entries&nbsp; </font></td>
      <td width="10%"  height="25">&nbsp;</td>
    </tr>
<%		}//only if iAccessLevel > 1
%>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;<input type="text" size="1" class="textbox_noborder" style="font-size:1px;" name="focus_2" value="<%=WI.fillTextValue("focus_2")%>"></td>
    </tr>
  </table>
 <input type="hidden" name="payment_for" value="0">
 <input type="hidden" name="addRecord" value="0">
 <input type="hidden" name="pmt_schedule_name" value="<%=WI.fillTextValue("pmt_schedule_name")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
