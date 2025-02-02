<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../../jscript/common.js"></script>
<script src="../../../../Ajax/ajax.js"></script>
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
function OpenSearch() {
	var pgLoc = "../../../../search/srch_stud_basic.jsp?opner_info=stud_ledg.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function studIDInURL() {
	if(!document.stud_ledg.show_all.checked)
		return;
	var studID = document.stud_ledg.stud_id.value;
	location = "./student_ledger_viewall.jsp?stud_id="+studID;
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.stud_ledg.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.stud_ledg.stud_id.value = strID;
	document.stud_ledg.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.stud_ledg.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

/*** this ajax is called to record semestral remarks **/
function ajaxUpdateRemark() {
	//if there is no change, just return here..
	var strRemark = document.stud_ledg.sem_remark.value;
	var strParam = "stud_ref="+document.stud_ledg.user_index.value+"&sy_from="+document.stud_ledg.sy_from.value+
					"&semester="+document.stud_ledg.semester.value+"&sem_remark="+escape(strRemark);
	var objCOAInput = document.getElementById("coa_info_remark");
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=116&"+strParam;
	this.processRequest(strURL);
}



function ViewAssessment(strPgForward) {
	var strStudID = document.stud_ledg.stud_id.value;
	if(strStudID.length == 0) {
		alert("Please enter student ID.");
		return;
	}
	pgLoc="?is_confirmed=1&stud_id="+document.stud_ledg.stud_id.value+"&sy_from="+document.stud_ledg.sy_from.value+"&sy_to="+document.stud_ledg.sy_to.value+"&semester="+
		document.stud_ledg.semester[document.stud_ledg.semester.selectedIndex].value;
	pgLoc = "../../payment/re_print_assessment.jsp"+pgLoc;
	if(strPgForward != '')
		pgLoc += "&prevent_forward=1";
	
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ChargeSlip() {
	var strStudID = document.stud_ledg.stud_id.value;
	if(strStudID.length == 0) {
		alert("Please enter student ID.");
		return;
	}
	pgLoc="?stud_id="+document.stud_ledg.stud_id.value+"&sy_from="+document.stud_ledg.sy_from.value+"&sy_to="+document.stud_ledg.sy_to.value+"&semester="+
		document.stud_ledg.semester[document.stud_ledg.semester.selectedIndex].value;
	pgLoc = "../../reports/charge_slip_UB.jsp"+pgLoc;
	
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function StatementOfAccount() {
	var strStudID = document.stud_ledg.stud_id.value;
	if(strStudID.length == 0) {
		alert("Please enter student ID.");
		return;
	}
	pgLoc="?stud_id="+document.stud_ledg.stud_id.value+"&sy_from="+document.stud_ledg.sy_from.value+"&sy_to="+document.stud_ledg.sy_to.value+"&semester="+
		document.stud_ledg.semester[document.stud_ledg.semester.selectedIndex].value;
	pgLoc = "../../reports/statement_of_account_print.jsp"+pgLoc;
	
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#8C9AAA">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

//forward the page here.
if(WI.fillTextValue("show_all").compareTo("1") ==0){
	response.sendRedirect(response.encodeRedirectURL("./student_ledger_viewall.jsp?stud_id="+WI.fillTextValue("stud_id")));
	return;
}

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = {"Summer","",""};

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
	request.getSession(false).setAttribute("go_home","../admin_staff/admin_staff_bottom_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
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



Vector vTuitionFeeDetail = null;

String strUserIndex = null;

FAPaymentUtil paymentUtil = new FAPaymentUtil();
paymentUtil.setIsBasic(true);

FAStudentLedger faStudLedg = new FAStudentLedger();

String strStudID = WI.fillTextValue("stud_id");

if(strStudID.length() > 0) {
	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, strStudID);

	//check if rfid is scanned.. 
	if(dbOP.strBarcodeID != null)
		strStudID = dbOP.strBarcodeID;

	if(vBasicInfo == null){ //may be it is the teacher/staff
		strErrMsg = paymentUtil.getErrMsg();
	}else//check if this student is called for old ledger information.
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
			response.sendRedirect(response.encodeRedirectURL("./old_student_ledger_view.jsp?stud_id="+strStudID+"&sy_from="+
				request.getParameter("sy_from")+"&sy_to="+request.getParameter("sy_to")+"&semester="+request.getParameter("semester")));
			return;
		}
	}
	//check if the applicant is having reservation already, if so - take directly to the print page,
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{
		strUserIndex = (String)vBasicInfo.elementAt(0);
		vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vBasicInfo.elementAt(0),request.getParameter("sy_from"),
			request.getParameter("sy_to"),null,request.getParameter("semester"));
		if(vLedgerInfo == null){
			strErrMsg = faStudLedg.getErrMsg();
//			System.out.println("StrErrMsg  2: " + strErrMsg);
		}else
		{
			vTimeSch 			= (Vector)vLedgerInfo.elementAt(0);
			vTuitionFeeDetail	= (Vector)vLedgerInfo.elementAt(1);
			vAdjustment			= (Vector)vLedgerInfo.elementAt(2);
			vRefund				= (Vector)vLedgerInfo.elementAt(3);
			vDorm 				= (Vector)vLedgerInfo.elementAt(4);
			vOthSchFine			= (Vector)vLedgerInfo.elementAt(5);//System.out.println(vOthSchFine);
			vPayment			= (Vector)vLedgerInfo.elementAt(6);
			if(vTimeSch == null || vTimeSch.size() ==0){
				strErrMsg = faStudLedg.getErrMsg();
//				System.out.println("StrErrMsg  3: " + strErrMsg);
			}
		}

	}
}

boolean bolShowDiscDetail = true;
if(strSchCode.startsWith("PWC"))
	bolShowDiscDetail = false;
%>
<form name="stud_ledg" action="./student_ledger.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF"><strong>::::
          STUDENT'S LEDGER PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
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
      <td>&nbsp;</td>
      <td colspan="5" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2">School Year/Term</td>
      <td height="25" colspan="2">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("stud_ledg","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" readonly="yes">
        -
        <select name="semester">
          <option value="1">Regular</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="53%" height="25">
<input type="checkbox" name="show_all" value="1" onClick="studIDInURL();">
        <font size="1">SHOW LEDGER from the first enrolled until present </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Student ID &nbsp;</td>
      <td width="17%" height="25"><input name="stud_id" type="text" size="16" value="<%=strStudID%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="11%"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td><input type="image" src="../../../../images/form_proceed.gif">
<%
if(vBasicInfo != null && vBasicInfo.size() > 0){%>
	  	&nbsp;&nbsp;&nbsp;<a href="javascript:ViewAssessment('1');">View Assessment Detail</a>
<%}%>		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">
<%if(strSchCode.startsWith("CIT") || strSchCode.startsWith("UB") || strSchCode.startsWith("SWU")){%>
	<a href="javascript:ViewAssessment('');">Study Load</a>
<%}if(strSchCode.startsWith("UB")){%>
	 &nbsp;&nbsp; <a href="javascript:ChargeSlip();">Charge Slip</a>
	 &nbsp;&nbsp; <a href="javascript:StatementOfAccount();">Statement Of Account</a>
<%}%>
	  </td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td></td>
      <td colspan="3"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
  </table>
<%
if(vBasicInfo != null && vBasicInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="42%" height="25">Student ID :<strong> <%=strStudID%></strong></td>
      <td width="56%" height="25"  colspan="4">Educational Level : <strong>
	  <%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue(vBasicInfo.elementAt(4),"0")))%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td  colspan="4" height="25"><%=WI.getStrValue(astrConvertTerm[Integer.parseInt(WI.getStrValue((String)vBasicInfo.elementAt(5),"2"))],"Term :<strong> ","</strong>","&nbsp;")%></td>
    </tr>
<%
if(strSchCode.startsWith("AUF")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">
	  	  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr> 
				<td width="15%" valign="top" style="font-weight:bold; color:#FF0000"><br>Semestral Remark:</td>
				<td>
<%
strTemp = "select sem_remark from stud_curriculum_hist where sy_from = "+WI.fillTextValue("sy_from")+
				" and semester = "+WI.fillTextValue("semester")+" and is_valid = 1 and user_index = "+(String)vBasicInfo.elementAt(0);
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp == null)
	strTemp = "";
%>				<textarea name="sem_remark" style="font-size:11px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif; background-color:#CCCCCC" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#cccccc'" rows="4" cols="85"><%=strTemp%></textarea>
				<font style="color:#FF0000">
				<a href="javascript:ajaxUpdateRemark();">Update Remark</a>
				
				<label id="coa_info_remark" style="font-size:9px; font-weight:bold"></label>
				</font>
				<br>&nbsp;
				</td>
			</tr>
		</table>
	  
	  </td>
    </tr>
<%}%>
	
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
      <td width="11%" height="25" align="center" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td width="40%" align="center" bgcolor="#B9B292" class="thinborder"><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>COLLECTED
          BY (ID) </strong></font></div></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="17%" align="center" class="thinborder"><font size="1"><strong>BALANCE</strong></font></td>
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
if(dTemp > 0)
	dCredit = dTemp;
else
	dDebit  =  -1 * dTemp;
dBalance -= dTemp;
%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder"><%=vTuitionFeeDetail.elementAt(6)%></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder">&nbsp;
        <%if(dDebit > 0f){%>
        <%=CommonUtil.formatFloat(dDebit,true)%>
        <%}%>
      </td>
      <td align="right" class="thinborder">&nbsp;
        <%if(dCredit > 0f){%>
        <%=CommonUtil.formatFloat(dCredit,true)%>
        <%}%>
      </td>
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
int iIndexOf2 = 0;			
Vector vDiscountAddlDetail = faStudLedg.vDiscountAddlDetail;
String strGrant = null;
String strGrantNote = null;

if(vDiscountAddlDetail == null)
	vDiscountAddlDetail = new Vector();

while( (iIndex = vAdjustment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dCredit = Float.parseFloat((String)vAdjustment.elementAt(iIndex-3));
	dBalance -= dCredit;
	
	iIndexOf2 = vDiscountAddlDetail.indexOf(new Integer((String)vAdjustment.elementAt(iIndex + 2)));
	if(iIndexOf2 == -1) {
		strTemp = null;
		strErrMsg = null;
	}
	else {
		strTemp = (String)vDiscountAddlDetail.elementAt(iIndexOf2 + 1);
		if(vDiscountAddlDetail.elementAt(iIndexOf2 + 2) != null && ((String)vDiscountAddlDetail.elementAt(iIndexOf2 + 2)).length() > 0) 
			strErrMsg = (String)vDiscountAddlDetail.elementAt(iIndexOf2 + 2);
		if(strSchCode.startsWith("UB")){
			if(vDiscountAddlDetail.elementAt(iIndexOf2 + 3) != null && ((String)vDiscountAddlDetail.elementAt(iIndexOf2 + 3)).length() > 0) 
				strGrantNote = (String)vDiscountAddlDetail.elementAt(iIndexOf2 + 3);
		}
	}
	
	strGrant = (String)vAdjustment.elementAt(iIndex-4);
	if(!bolShowDiscDetail && strGrant != null && strGrant.length() > 20 && strGrant.indexOf("<br>") > 0) {
		strGrant = strGrant.substring(0, strGrant.indexOf("<br>"));
	}
%>
    <tr >
      <td height="25" class="thinborder">
        <% if(bolDatePrinted){%>
        &nbsp;
        <%}else{%>
        <%=strTransDate%>
        <%bolDatePrinted=true;}%>
      </td>
      <td class="thinborder"><%//=(String)vAdjustment.elementAt(iIndex-4)%><!--(Grant)-->
	  <%=strGrant%>(Grant)
	  <%=WI.getStrValue(strErrMsg, "<br>Approval #: ","","")%>
	  <%=WI.getStrValue(strGrantNote, "<br>","","")%>
	  </td>
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
      <td height="25" class="thinborder">
        <% if(bolDatePrinted){%>
        &nbsp;
        <%}else{%>
        <%=strTransDate%>
        <%bolDatePrinted=true;}%>
      </td>
      <td class="thinborder"><%=(String)vRefund.elementAt(iIndex-3)%>(Refund)</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
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
      <td height="25" class="thinborder">
        <% if(bolDatePrinted){%>
        &nbsp;
        <%}else{%>
        <%=strTransDate%>
        <%bolDatePrinted=true;}%>
      </td>
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
      <td height="25" class="thinborder">
        <% if(bolDatePrinted){%>
        &nbsp;
        <%}else{%>
        <%=strTransDate%>
        <%bolDatePrinted=true;}%>
      </td>
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
      <td height="25" class="thinborder">
        <% if(bolDatePrinted){%>
        &nbsp;
        <%}else{%>
        <%=strTransDate%>
        <%bolDatePrinted=true;}%>
      </td>
      <td class="thinborder"><%=WI.getStrValue(vPayment.elementAt(iIndex-1))%>(<%=(String)vPayment.elementAt(iIndex+1)%>)</td>
      <td align="center" class="thinborder"><%=(String)vPayment.elementAt(iIndex + 3)%></td>
      <td  align="right" class="thinborder">&nbsp;
        <%//show only the refunds in debit column.
	  if(dCredit < 0d || (vPayment.elementAt(iIndex+1) != null && ((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
        <%=CommonUtil.formatFloat(-1 * dCredit,true)%>
        <%}%>
      </td>
      <td align="right" class="thinborder">&nbsp;
        <%if(dCredit > 0d && (vPayment.elementAt(iIndex+1) == null || !((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded"))){%>
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
        to print ledger</font></td>
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
      <td height="25" colspan="8" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="user_index" value="<%=(String)vBasicInfo.elementAt(0)%>">

<%} //only if basic info is not null;
%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>