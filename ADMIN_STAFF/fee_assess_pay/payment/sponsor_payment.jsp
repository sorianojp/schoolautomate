<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ShowHideCheckNO()
{
	if(document.fa_payment.payment_type.selectedIndex == 1 || document.fa_payment.payment_type.selectedIndex == 3) {
		document.fa_payment.CHECK_FR_BANK_INDEX.disabled = false;
		document.fa_payment.check_number.disabled = false;
	}
	else {
		document.fa_payment.CHECK_FR_BANK_INDEX.selectedIndex = 0;
		document.fa_payment.CHECK_FR_BANK_INDEX.disabled = true;
		document.fa_payment.check_number.disabled = true;
	}
	//show or hide emp ID input fields.
	if(document.fa_payment.payment_type.selectedIndex == 2)
	{
		showLayer('_empID');
		showLayer('_empID1');
		document.fa_payment.hide_search.src = "../../../images/search.gif";
	}
	else
	{
		hideLayer('_empID');
		hideLayer('_empID1');
		document.fa_payment.cash_adv_from_emp_id.value = "";
		document.fa_payment.hide_search.src = "../../../images/blank.gif";
	}
	if(document.fa_payment.payment_type.selectedIndex == 3)
		showLayer('myADTable1');
	else
		hideLayer('myADTable1');
	document.fa_payment.chk_amt.value = "";
	document.fa_payment.cash_amt.value = "";

}
function FullPayment() {
	document.fa_payment.amount.value = "";
	this.ReloadPage();
}
function ReloadPage()
{
	document.fa_payment.addRecord.value="";
	document.fa_payment.submit();
}
function AddRecord()
{
	document.fa_payment.addRecord.value="1";
	document.fa_payment.hide_save.src = "../../../images/blank.gif";
	document.fa_payment.submit();
}
function ChangePmtSchName()
{
	document.fa_payment.pmt_schedule_name.value = document.fa_payment.pmt_schedule[document.fa_payment.pmt_schedule.selectedIndex].value;
}

function FocusID() {
	document.fa_payment.sponsor_name.focus();
}
function OpenSearch(studPosIndex) {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=fa_payment.stud_id"+studPosIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearchFaculty() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=fa_payment.cash_adv_from_emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function computeCashChkAmt() {
	var totAmt  = document.fa_payment.amount.value;
	var chkAmt  = document.fa_payment.chk_amt.value;
	var cashAmt = document.fa_payment.cash_amt.value;

	if(totAmt.length == 0)
		return;
	if(chkAmt.length == 0) {
		document.fa_payment.cash_amt.value = "";
		return;
	}
	cashAmt = eval(totAmt - chkAmt);
	document.fa_payment.cash_amt.value = eval(cashAmt);
}
function CopySponsorName() {
	document.fa_payment.sponsor_name.value = document.fa_payment.sponsor_name_ref[document.fa_payment.sponsor_name_ref.selectedIndex].value;
}
function computeTotPmt() {
	var totPmt = 0;
	var maxStud = document.fa_payment.tot_stud[document.fa_payment.tot_stud.selectedIndex].value;
	var amount  = 0;
	for(i = 0; i < maxStud;++i) {
		amount = eval('document.fa_payment.amount'+i+'.value');
		if(amount.length == 0)
			continue;
		totPmt = eval(totPmt) + eval(amount);
	}
	document.fa_payment.amount.value = eval(totPmt);
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
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Installment fees","install_assessed_fees_payment.jsp");
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
														"install_assessed_fees_payment.jsp");
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
	if(faPayment.saveSponsorPayment(dbOP,request)){
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
	strErrMsg ="<font size=1>Note :</strong> If sponser is paying for <strong>downpayment during enrollment</strong>, Please validate the student in link "+
	"Registrar Management::Student IDs::New IDs(for new student),Validate IDs(for old students)</font>";


	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

if(strSchCode.startsWith("DLSHSI")) //tracking is for lasalle only.. 
	request.getSession(false).setAttribute("start_time_long_or",String.valueOf(new java.util.Date().getTime()));


%>

<form name="fa_payment" action="./sponsor_payment.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          SCHEDULE ASSESSMENT PAGE ::::</strong></font></div></td>
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
      <td height="25" colspan="2">
<%
strTemp = WI.fillTextValue("late_fine");
if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>	  <input type="checkbox" name="late_fine" value="1"<%=strTemp%>>
        <font color="#0000FF"><strong>Implement fine for late Installment</strong></font></td>
      <td height="25">&nbsp;</td>
      <td width="56%" height="25"> <%//get here cutoff time information.
	  Vector vTempCO = new enrollment.FADailyCashCollectionDtls().getCurrentCutoffStat(dbOP, (String)request.getSession(false).getAttribute("userId"));//System.out.println(vTempCO);
	  //I have to get currency rate..
	  String strCurrencyInfo = new locker.Currency().getLatestCurrencyRate(dbOP);
	  if(vTempCO != null){%> <table width="90%" class="thinborderALL" cellpadding="0" cellspacing="0">
          <tr>
            <td height="20" align="right"> <%
		  strTemp = "Time :: "+(String)vTempCO.elementAt(0);
		  if(vTempCO.elementAt(1) != null) {//cut off time is set.
		  	if( ((String)vTempCO.elementAt(2)).compareTo("1") == 0)
				strTemp += "<br><font color=red>Cut off :: "+(String)vTempCO.elementAt(1)+"</font>";
			else
				strTemp += "<br>Cut off :: "+(String)vTempCO.elementAt(1);
		  }
                  if(vTempCO.elementAt(2) != null)
                  	strTemp += "<br>Collection :: "+(String)vTempCO.elementAt(3);
                  %> <strong><%=strTemp%><%=strCurrencyInfo%></strong> </td>
          </tr>
        </table>
        <%}//only if cutoff time is set.%> </td>
    </tr>
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
	  onKeyUp='DisplaySYTo("fa_payment","sy_from","sy_to")'>
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
      <td>Date Paid:
        <%
strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%> <input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Sponsor Name</td>
      <td><input name="sponsor_name" type="text" size="32" value="<%=WI.fillTextValue("sponsor_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td><select name="sponsor_name_ref" style="font-size:10px" onclick="CopySponsorName();">
          <option value="">Select sponsor name</option>
          <%=dbOP.loadCombo("distinct NAME","name"," from FA_STUD_PAYMENT where is_valid = 1 and IS_SPONSOR = 1 and user_index is null order by FA_STUD_PAYMENT.name", request.getParameter("sponsor_name_ref"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Total student sponsored:
        <select name="tot_stud" onChange="ReloadPage();">
          <%
iNoOfStudSponsored = Integer.parseInt(WI.getStrValue(WI.fillTextValue("tot_stud"),"1"));
for(int i = 1; i <= 10; ++i) {
	if(i == iNoOfStudSponsored)
		strTemp = " selected";
	else
		strTemp = "";
%>
          <option value="<%=i%>" <%=strTemp%>><%=i%></option>
          <%}%>
        </select></td>
      <td>NOTE:</td>
      <td> Select full pmt for full pmt discount &amp; d/pmt if paid for enrollment
        d/p </td>
    </tr>
    <%
for(int i = 0; i <iNoOfStudSponsored; ++i){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Stud. ID<br>
<%
strTemp = WI.fillTextValue("sy_from"+i);
if(strTemp.length() == 0)
	strTemp = strSYFrom;
%>
<input name="sy_from<%=i%>" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" style="font-size:10px;">
	  -
<select name="semester<%=i%>" style="font-size:10px">
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
        </select>
	  </td>
      <td><input name="stud_id<%=i%>" type="text" size="16" value="<%=WI.fillTextValue("stud_id"+i)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <select name="pmt_schedule<%=i%>" style="font-size:10px">
	        <option value="0">Down Payment</option>
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
          <%=strTemp.toLowerCase()%> </select><br>
<%
if(WI.fillTextValue("fp"+i).length() == 0)
	strTemp = "";
else
	strTemp = " checked";
%>        <input type="checkbox" name="fp<%=i%>" value="1"<%=strTemp%>>
        <strong><font size="1">Is Full payment</font></strong> </td>
      <td valign="top"><a href="javascript:OpenSearch(<%=i%>);"><img src="../../../images/search.gif" border="0"></a></td>
      <td valign="top">Amount:
        <input name="amount<%=i%>" type="text" size="12" value="<%=WI.fillTextValue("amount"+i)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('fa_payment','amount<%=i%>');computeTotPmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('fa_payment','amount<%=i%>');computeTotPmt();">
        &nbsp;&nbsp; <font style="font-size:9px"><strong>Name:</strong>
        <%if(WI.fillTextValue("stud_id"+i).length() > 0){%>
        <%=CommonUtil.getName(dbOP,WI.fillTextValue("stud_id"+i),4)%>
        <%}%>
        </font></td>
    </tr>
    <%}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%" height="25">&nbsp; </td>
      <td width="26%" height="25">&nbsp; </td>
      <td width="3%" height="25">&nbsp;</td>
      <td>&nbsp; </td>
    </tr>
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
      <td width="18%">Amount paid </td>
      <td width="28%">
	   <input name="amount" type="text" size="12" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('fa_payment','amount');computeCashChkAmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('fa_payment','amount');computeCashChkAmt();">
        Php </td>
      <td width="8%">&nbsp;</td>
      <td width="44%"><input type="hidden" name="pmt_receive_type" value="Internal"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Approval date</td>
      <td><font size="1">
        <input name="date_approved" type="text" size="16" value="<%=WI.fillTextValue("date_approved")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('fa_payment.date_approved');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font> </td>
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
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Salary deduction</option>
          <%}else{%>
          <option value="2">Salary deduction</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>Cash and check</option>
          <%}else{%>
          <option value="5">Cash and check</option>
          <%}%>
        </select>
        <br>
        <input name="text" type="text" class="textbox_noborder" id="_empID" value="Emp ID:" size="6" readonly="yes">
        <input type="text" name="cash_adv_from_emp_id" value="<%=WI.fillTextValue("cash_adv_from_emp_id")%>" size="12" id="_empID1" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearchFaculty();"><img src="../../../images/search.gif" width="25" height="23" border="0" id="hide_search"></a>
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
        <div id="myADTable1">Check amt:
          <input name="chk_amt" type="text" size="12" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('fa_payment','amount');computeCashChkAmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('fa_payment','chk_amt');computeCashChkAmt();">
          cash:
          <input name="cash_amt" type="text" size="12" class="textbox_noborder" readonly="yes"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        </div>
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
      <td colspan="4" height="25">&nbsp;</td>
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
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
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
