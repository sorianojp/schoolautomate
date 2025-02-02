<%
String strStudID    = (String)request.getSession(false).getAttribute("userId");
String strSYFrom    = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo      = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
String strSemester  = (String)request.getSession(false).getAttribute("cur_sem");


if(strStudID == null) {
%>
 <p style="font-size:14px; color:#FF0000;">You are already logged out. Please login again.</p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var pgLoc = "./student_ledger_print.jsp?stud_id="+escape(document.stud_ledg.stud_id.value)+"&sy_from="+
			document.stud_ledg.sy_from.value+"&sy_to="+document.stud_ledg.sy_to.value+"&semester="+
			document.stud_ledg.semester[document.stud_ledg.semester.selectedIndex].value;

	var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}

function ReloadPage() {
	document.stud_ledg.submit();
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
function viewSOA() {
	location = "../../ADMIN_STAFF/fee_assess_pay/reports/statement_of_account_print.jsp?myhome=1&sy_from="+document.stud_ledg.sy_from.value+
		"&sy_to="+document.stud_ledg.sy_to.value+
		"&semester="+document.stud_ledg.semester[document.stud_ledg.semester.selectedIndex].value;
}
function viewInstallmentSched() {
	location = "pmt_schedule.jsp";
}
</script>
<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,enrollment.EnrlAddDropSubject,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	if(WI.fillTextValue("sy_from").length() > 0) {
		strSYFrom    = WI.fillTextValue("sy_from");
		strSYTo      = WI.fillTextValue("sy_to");
		strSemester  = WI.fillTextValue("semester");
	}
	

//forward the page here.
if(WI.fillTextValue("show_all").compareTo("1") ==0){
	response.sendRedirect("./student_ledger_viewall.jsp?show_coursecode=1&stud_id="+WI.fillTextValue("id_in_url"));
	return;
}

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};

	boolean bolProceed = true;
//add security here.
	try
	{
		dbOP = new DBOperation();
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

String strUserIndex = null;

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAStudentLedger faStudLedg = new FAStudentLedger();
EnrlAddDropSubject eADS = new EnrlAddDropSubject();

//check if basic.
String strSQLQuery = "select course_index from stud_curriculum_hist where sy_from = "+strSYFrom+
						" and is_valid = 1 and user_index = "+(String)request.getSession(false).getAttribute("userIndex");
						
			
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);

if(strSQLQuery != null && strSQLQuery.equals("0")) {
	dbOP.cleanUP();
	response.sendRedirect("./basic/student_ledger.jsp?sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+strSemester);
	return;
}


if(strStudID.length() > 0)
{
	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, strStudID,strSYFrom,strSYTo,strSemester);
	
	if(vBasicInfo == null)
		vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, strStudID);
	if(vBasicInfo == null) //may be it is the teacher/staff
		strErrMsg = paymentUtil.getErrMsg();
	else//check if this student is called for old ledger information.
	{
	
		strUserIndex = (String)vBasicInfo.elementAt(0);
		int iDisplayType = faStudLedg.isOldLedgerInformation(dbOP, strUserIndex,strSYFrom, strSYTo,strSemester);
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
			response.sendRedirect(response.encodeRedirectURL("./old_student_ledger_view.jsp?stud_id="+strStudID+"&sy_from="+
				strSYFrom+"&sy_to="+strSYTo+"&semester="+strSemester));
			return;
		}
	}
	//check if the applicant is having reservation already, if so - take directly to the print page,
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{//long lTime = new java.util.Date().getTime();
		boolean bolShowOnlyDroppedSub = false;
		if(WI.fillTextValue("show_dropped_only").length() > 0)
			bolShowOnlyDroppedSub = true;
		vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vBasicInfo.elementAt(0),strSYFrom,
			strSYTo,null,strSemester, bolShowOnlyDroppedSub);
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
if (strErrMsg == null){
//	getStudBasicInfoOLD ->  (stud_Index = 0 , course_type = 10)
	if (vBasicInfo != null && vBasicInfo.size() > 0){
		vAddedSub = eADS.getAddedDroppedList(dbOP, (String)vBasicInfo.elementAt(0),  (String)vBasicInfo.elementAt(10),
											 strSYFrom,strSYTo,
											 strSemester, true);
		vDroppedSub = eADS.getAddedDroppedList(dbOP, (String)vBasicInfo.elementAt(0),  (String)vBasicInfo.elementAt(10),
											 strSYFrom,strSYTo,
											 strSemester, false);
}	}
//System.out.println(vDroppedSub);
if(strErrMsg == null) strErrMsg = "";
String strSchCode = dbOP.getSchoolIndex();
if(strSchCode == null)
	strSchCode = "";


String strIsReadOnly = "";
if(strSchCode.startsWith("EAC"))
	strIsReadOnly = "readonly='yes'";
String strConvertSem[] = {"Summer","First Term","Second Term","Third Term"};

%>
<form name="stud_ledg" action="./student_ledger.jsp" method="post">
<input name="stud_id" type="hidden" value="<%=strStudID%>"> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#47768F"><div align="center"><font color="#FFFFFF"><strong>::::
      STUDENT'S LEDGER PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp; <%=strErrMsg%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 7);
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
      <td height="25">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%" height="25">SY-TERM</td>
      <td height="25"> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox_bigfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("stud_ledg","sy_from","sy_to")' <%=strIsReadOnly%>>
        -
 <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox_bigfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester" style="font-size:17px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif">
<%if(strIsReadOnly.length() == 0) {%>
         <option value="1">1st Sem</option>
<%
if(strSemester.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strSemester.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}if(strSemester.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>

<%}else{%>
	<option value="<%=strSemester%>"><%=strConvertSem[Integer.parseInt((String)request.getSession(false).getAttribute("cur_sem"))]%></option>
<%}%>

      </select>       



	  &nbsp;&nbsp;&nbsp;&nbsp;
	   <input name="image" type="image" src="../../images/form_proceed.gif"></td>
      <td height="25">&nbsp;</td>
    </tr>
<%if(strIsReadOnly.length() == 0) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><input type="checkbox" name="show_all" value="1" onClick="studIDInURL();">
        <font size="1">SHOW LEDGER from the first enrolled semester until present </font> 
			<div align="right">
			<%if(strSchCode.startsWith("CSA")){%>
					<a href="javascript:viewSOA();">View Statement of Account</a>
			<%}%>
			<a href="javascript:viewInstallmentSched();">View Installment Schedule</a>
			</div>
	  </td>
      <td width="2%">&nbsp;</td>
    </tr>
<%}%>
  </table>
  <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
<!--
  <tr>
  	<td width="2%"></td>
  	  <td width="98%" height="25"> <%
strTemp = WI.fillTextValue("show_dropped_only");
if(strTemp.equals("1"))
	strTemp = "checked";
else
	strTemp = "";
%>
        <input type="checkbox" name="show_dropped_only" value="1" onClick="ReloadPage();" <%=strTemp%>>
        <font size="1">SHOW DROPPED SUBJECT FEE DETAIL ONLY</font></td>
  </tr>
-->
<%if(false && strSchCode.startsWith("AUF")){%>
  <tr>
    <td></td>
    <td height="25">&nbsp; View Ledger in AUF Format 
	<a href="javascript:ViewAUFLedger();">
		<img src="../../images/view.gif" border="0"></a></td>
  </tr>
<%}%>
  </table>
<%
if(vBasicInfo != null && vBasicInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="37%" height="25">Student ID :<strong> <%=strStudID%></strong></td>
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
      <td  colspan="4" height="25">Current Year(Term) :<strong> <%=WI.getStrValue(vBasicInfo.elementAt(4),"N/A")%>
        (<%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%>)</strong></td>
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td width="11%" height="25" align="center" bgcolor="#BECED3" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td width="40%" align="center" bgcolor="#BECED3" class="thinborder"><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="6%" bgcolor="#BECED3" class="thinborder"><div align="center"><font size="1"><strong>COLLECTED BY (ID)
      </strong></font></div></td>
      <td width="13%" align="center" bgcolor="#BECED3" class="thinborder"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="13%" align="center" bgcolor="#BECED3" class="thinborder"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="17%" align="center" bgcolor="#BECED3" class="thinborder"><font size="1"><strong>BALANCE</strong></font></td>
    </tr>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <td colspan="4" align="right" class="thinborder">OLD ACCOUNTS<%=faStudLedg.getDormOldAccountInfo(true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
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
      <td height="25" class="thinborder"><%=strTransDate%></td>
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
      <td class="thinborder">Miscellaneous Fee</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();
if(dDebit > 0f){
dBalance += dDebit;%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder">Other Charges</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%}
dDebit = ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
if(dDebit > 0f){
dBalance += dDebit;%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
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
if(dTemp > 0d)
	dCredit = dTemp;
else
	dDebit  =  -1 * dTemp;
dBalance -= dTemp;
%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder"><%=vTuitionFeeDetail.elementAt(6)%></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder">&nbsp; <%if(dDebit > 0f){%> <%=CommonUtil.formatFloat(dDebit,true)%> <%}%> </td>
      <td align="right" class="thinborder">&nbsp; <%if(dCredit > 0f){%> <%=CommonUtil.formatFloat(dCredit,true)%> <%}%> </td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
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
	dCredit = Float.parseFloat((String)vAdjustment.elementAt(iIndex-3));
	dBalance -= dCredit;
%>
    <tr >
      <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
      <td class="thinborder"><%=(String)vAdjustment.elementAt(iIndex-4)%>(Grant)</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dCredit,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
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
      <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
      <td class="thinborder">
	  <%if(vRefund.elementAt(iIndex - 2) != null){%>
	  <%=(String)vRefund.elementAt(iIndex-2)%>
	  <%}else{%>
	  <%=(String)vRefund.elementAt(iIndex-3)%>(Refund)
	  <%}%></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder">
	  <%if(dDebit >= 0f){%> <%=CommonUtil.formatFloat(dDebit,true)%><%}%></td>
      <td align="right" class="thinborder">&nbsp;
	  <%if(dDebit < 0f){%> <%=CommonUtil.formatFloat(dDebit,true)%><%}%></td>
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
	dDebit = Float.parseFloat((String)vDorm.elementAt(iIndex-1));
	dBalance += dDebit;
%>
    <tr >
      <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
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
while( (iIndex = vOthSchFine.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dDebit = Float.parseFloat((String)vOthSchFine.elementAt(iIndex-1));
	dBalance += dDebit;
%>
    <tr >
      <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
      <td class="thinborder"><%=(String)vOthSchFine.elementAt(iIndex-2)%></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
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
      <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
      <td class="thinborder"><%=WI.getStrValue(vPayment.elementAt(iIndex-1))%> <%=(String)vPayment.elementAt(iIndex+1)%>
	  <%if(false){%>(Refuned)<%}%></td>
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
	  <%}%>
	  </td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
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
<% if (vAddedSub != null && vAddedSub.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>  
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="25" colspan="6" bgcolor="#B4C1FA" class="thinborder"><div align="center"><strong>LIST 
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
      <td height="25" colspan="6" bgcolor="#B4C1FA" class="thinborder"><div align="center"><strong>LIST 
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
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
      <td colspan="3" height="25">&nbsp;</td>
    </tr>
  </table>
<%}//only if vTimeSch is not null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="user_index" value="<%=(String)vBasicInfo.elementAt(0)%>">

<%} //only if basic info is not null;
%>
<input type="hidden" name="id_in_url">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>