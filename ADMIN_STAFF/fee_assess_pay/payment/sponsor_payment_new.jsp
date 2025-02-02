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
	location = "./sponsor_payment_new.jsp?sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+
				"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
				"&date_of_payment="+document.form_.date_of_payment.value+"&sponsor_name_ref="+
				document.form_.sponsor_name_ref[document.form_.sponsor_name_ref.selectedIndex].value+
				"&sponsor_name="+escape(document.form_.sponsor_name_ref[document.form_.sponsor_name_ref.selectedIndex].text);
	//document.form_.sponsor_name.value = document.form_.sponsor_name_ref[document.form_.sponsor_name_ref.selectedIndex].text;
	//this.ReloadPage();
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
function DistributePayment() {
	if(document.form_.amount.value.length ==0) {
		alert("Please enter Amount to be distributed.");
		return;
	}
	document.form_.distribute_pmt.value='1';
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.FAAssessment,enrollment.FAPaymentUtil,enrollment.Sponsor,java.util.Vector" buffer="16kb" %>
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
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

if(strSchCode.startsWith("DLSHSI")) //tracking is for lasalle only.. 
	request.getSession(false).setAttribute("start_time_long_or",String.valueOf(new java.util.Date().getTime()));


Sponsor sponsorPayment = new Sponsor();
strTemp = WI.fillTextValue("addRecord");

if(strTemp != null && strTemp.compareTo("1") ==0)
{
	if(sponsorPayment.saveSponsorPaymentNew(dbOP,request)){
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./otherschoolfees_print_receipt.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	else
		strErrMsg = sponsorPayment.getErrMsg();
}

String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

int iNoOfStudSponsored = 0;
String strSYFrom = null;
String strSYTo   = null;
String strSemester = null;

double dTotalAmt      = 0d;
double dORMade        = 0d;
double dBalanceToMake = 0d;

///get sponsored student from sponsor management.
Vector vSponsorStudList = new Vector();
double dTotal = 0d;
double dTemp = 0d;
int iTotDebit = Integer.parseInt(WI.getStrValue(WI.fillTextValue("tot_debit"),"1"));

if(WI.fillTextValue("sponsor_name_ref").length() > 0) {
	String strSQLQuery = null;
	java.sql.ResultSet rs =  null;
	Vector vStudWithPmt = new Vector();
	int iIndexOf = 0;
	
	//get if amount already paid before.. 
	
	strSQLQuery = "select fa_stud_payment.user_index, sum(fa_stud_payment.amount) from fa_stud_payment "+
		"join SPONSOR_DETAILS on (SPONSOR_DETAILS.user_index = fa_stud_payment.user_index) "+
		"     and SPONSOR_DETAILS.stud_syf = fa_stud_payment.sy_from and SPONSOR_DETAILS.stud_sem = fa_stud_payment.semester"+
		" where  fa_stud_payment.is_valid = 1 and SPONSOR_DETAILS.sy_from = "+WI.fillTextValue("sy_from")+
		" and SPONSOR_DETAILS.semester = "+WI.fillTextValue("semester")+" and sponsor_index_  = "+WI.fillTextValue("sponsor_name_ref")+
		" and IS_SPONSORED = 1 and SPONSOR_DETAILS.is_valid = 1 group by fa_stud_payment.user_index";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vStudWithPmt.addElement(rs.getString(1));
		vStudWithPmt.addElement(rs.getString(2));
	}
	rs.close();



	strSQLQuery = "select id_number, amount, fname, mname, lname,STUD_SYF,STUD_SEM,user_table.user_index from SPONSOR_DETAILS join user_table on (user_Table.user_index = SPONSOR_DETAILS.user_index) where SPONSOR_INDEX = "+WI.fillTextValue("sponsor_name_ref")+
							" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester")+" and SPONSOR_DETAILS.is_valid = 1 order by lname ";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		dTotalAmt += rs.getDouble(2);

		iIndexOf = vStudWithPmt.indexOf(rs.getString(8));
		if(iIndexOf > -1) {
			dTemp = rs.getDouble(2) - Double.parseDouble((String)vStudWithPmt.elementAt(iIndexOf + 1));
			if(dTemp <= 0d)
				continue; 
		}
		else 
			dTemp = rs.getDouble(2);
		
		vSponsorStudList.addElement(rs.getString(1));
		vSponsorStudList.addElement(CommonUtil.formatFloat(dTemp, true));
		vSponsorStudList.addElement(WI.formatName(rs.getString(3),rs.getString(4),rs.getString(5),4));
		
		vSponsorStudList.addElement(rs.getString(6));
		vSponsorStudList.addElement(rs.getString(7));
		dTotal += dTemp;
		
	}
	rs.close();
	
	///get OR already made.
	strSQLQuery = "select sum(amount) from fa_stud_payment where is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+
						" and semester = "+WI.fillTextValue("semester")+" and sponsor_index_  = "+WI.fillTextValue("sponsor_name_ref")+" and is_sponsor = 1";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next())
		dORMade = rs.getDouble(1);
	rs.close();
	
	//now consider FA_STUD_PAYMENT_SPONSOR_DEBIT
	strSQLQuery = "select sum(FA_STUD_PAYMENT_SPONSOR_DEBIT.amount) from FA_STUD_PAYMENT_SPONSOR_DEBIT "+
					"join fa_stud_payment on (fa_stud_payment.payment_index = FA_STUD_PAYMENT_SPONSOR_DEBIT.payment_index) "+
					"where fa_stud_payment.is_valid = 1 and FA_STUD_PAYMENT_SPONSOR_DEBIT.is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+
					" and semester = "+WI.fillTextValue("semester")+" and sponsor_index_  = "+WI.fillTextValue("sponsor_name_ref")+" and is_sponsor = 1";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next())
		dORMade += rs.getDouble(1);
	rs.close();
	
	dBalanceToMake = 	dTotalAmt - dORMade;		
}

if(dTotal > 0d && dBalanceToMake <=0d && strErrMsg == null)
	strErrMsg = "OR already made for required amount. Failed to proceed.";
if(strErrMsg == null)
	strErrMsg ="<font size=1>Note :</strong> If sponser is paying for <strong>downpayment during enrollment</strong>, Please validate the student first";
boolean bolDistribute = false;
if(WI.fillTextValue("distribute_pmt").length() > 0) 
	bolDistribute = true;	
double dAmtToDistribute = 0d;
if(	bolDistribute) {
	dAmtToDistribute  = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("amount"), ",",""));
	//System.out.println("dAmtToDistribute: "+dAmtToDistribute);
	//System.out.println("dTotal: "+dTotal);
	if(dAmtToDistribute < dTotal) {
		dTotal = dAmtToDistribute;
		
		//handle the debit entries.. 
		for(int i = 0; i <iTotDebit; ++i){
			if(WI.fillTextValue("amount_d"+i).length() > 0) {
				try {
					dAmtToDistribute = dAmtToDistribute + Double.parseDouble(WI.fillTextValue("amount_d"+i));
				}
				catch(Exception e) {}
			}
		}				
		
		for(int i = 0; i < vSponsorStudList.size(); i += 5) {
			if(dAmtToDistribute <= 0d) {
				vSponsorStudList.remove(i);vSponsorStudList.remove(i);vSponsorStudList.remove(i);vSponsorStudList.remove(i);vSponsorStudList.remove(i);
				
				i -= 5;
				continue;
			}
			dTemp = Double.parseDouble(ConversionTable.replaceString((String)vSponsorStudList.elementAt(i + 1), ",",""));
			dAmtToDistribute -= dTemp;
			if(dAmtToDistribute < 0d) {
				dAmtToDistribute = dAmtToDistribute+dTemp;
				vSponsorStudList.setElementAt(CommonUtil.formatFloat(dAmtToDistribute, true), i + 1);
				dAmtToDistribute = 0d;
			}
		}	
		
	}
		
}

%>

<form name="form_" action="./sponsor_payment_new.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          SPONSOR PAYMENT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:16px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=strErrMsg%></td>
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
        <a href="javascript:show_calendar('form_.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>

&nbsp; &nbsp; &nbsp;
			<a href="javascript:CopySponsorName();"><img src="../../../images/refresh.gif" border="0"></a>
	  <font size="1">Click to Load Student List </font>		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderTOPLEFTBOTTOM" bgcolor="#99CCFF"><strong>SPONSOR NAME</strong></td>
      <td colspan="3" bgcolor="#99CCFF">
	  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="62%" height="25" class="thinborderTOP">
				<select name="sponsor_name_ref" style="font-size:10px;width:200px;" onChange="CopySponsorName();">
				<option value=""></option>
				<%=dbOP.loadCombo("SPONSOR_INDEX","SPONSOR_NAME"," from SPONSOR_MAIN where is_valid = 1 order by sponsor_name", request.getParameter("sponsor_name_ref"), false)%>
			  </select>	  			</td>
			    <td width="38%" style="font-size:14px;" class="thinborderTOPRIGHT">Total: <%=CommonUtil.formatFloat(dTotalAmt, true)%> &nbsp;&nbsp;&nbsp; 
				Balance: <%=CommonUtil.formatFloat(dBalanceToMake, true)%></td>
			</tr>
			<tr>
			  	<td class="thinborderBOTTOM">
			  <input name="sponsor_name" type="text" size="64" value="<%=WI.fillTextValue("sponsor_name")%>" class="textbox"
	 			 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">	  			</td>
		        <td style="font-size:14px;" class="thinborderBOTTOMRIGHT">Already Issued: <%=CommonUtil.formatFloat(dORMade, true)%> </td>
		  </tr>
		</table>
	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Total student sponsored:
        <select name="tot_stud" onChange="ReloadPage();">
          <%
int iTotMaxStud = 1000;
iNoOfStudSponsored = Integer.parseInt(WI.getStrValue(WI.fillTextValue("tot_stud"),"1"));
if(vSponsorStudList.size() > 0)
	iNoOfStudSponsored = vSponsorStudList.size()/5;
if(iNoOfStudSponsored >1000)
		iTotMaxStud = iNoOfStudSponsored;
	
for(int i = 1; i <= iTotMaxStud; ++i) {
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
if(vSponsorStudList.size() > 0) 
	strTemp = (String)vSponsorStudList.remove(3);

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
if(vSponsorStudList.size() > 0) 
	strTemp = (String)vSponsorStudList.remove(3);

if(strSemester == null)
	strSemester = "";
if(strTemp.length() == 0)
	strTemp = strSemester;

if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>SS</option>
          <%}else{%>
          <option value="2">SS</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>SU</option>
          <%}else{%>
          <option value="0">SU</option>
          <%}%>
        </select>	  </td>
      <td>
<%
strTemp = WI.fillTextValue("stud_id"+i);
if(vSponsorStudList.size() > 0) 
	strTemp = (String)vSponsorStudList.remove(0);
%>
  <input name="stud_id<%=i%>" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(document.form_.stud_id<%=i%>,'coa_info<%=i%>');">
        <select name="pmt_schedule<%=i%>" style="font-size:10px" tabindex="-1">
	        <!--<option value="0">Down Payment</option>-->
          <%
//i have to check if i should use the fa_pmt_schedule_extn or fa_pmt_schedule table.

strTemp = dbOP.loadCombo("fa_pmt_schedule_extn.PMT_SCH_INDEX","EXAM_NAME",
		" from fa_pmt_schedule_extn  join fa_pmt_schedule on (fa_pmt_schedule_extn.pmt_sch_index = fa_pmt_schedule.pmt_sch_index)"+
		" where fa_pmt_schedule_extn.is_del=0 and fa_pmt_schedule_extn.is_valid=1 and sy_from="+strSYFrom+
		" and semester="+strSemester+
		 " order by fa_pmt_schedule_extn.EXAM_PERIOD_ORDER desc", request.getParameter("pmt_schedule"+i), false);
//System.out.println("Printing : "+(String)vStudInfo.elementAt(8)+","+(String)vStudInfo.elementAt(9)+","+(String)vStudInfo.elementAt(5));
if(strTemp.length() ==0) {
	//dbOP.resetQueryLoadCombo();
	strTemp = dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER desc",
		request.getParameter("pmt_schedule"+i), false);
}
%>
          <%=strTemp.toLowerCase()%> </select>
		  <label style="position:absolute" id="coa_info<%=i%>"></label>		  </td>
      <td valign="top"><!--<a href="javascript:OpenSearch(<%=i%>);"><img src="../../../images/search.gif" border="0"></a>--></td>
      <td valign="top">Amount:
<%
strTemp = WI.fillTextValue("amount"+i);
if(vSponsorStudList.size() > 0) 
	strTemp = (String)vSponsorStudList.remove(0);
strTemp = ConversionTable.replaceString(strTemp, ",","");
%>
        <input name="amount<%=i%>" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount<%=i%>');computeTotPmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','amount<%=i%>');computeTotPmt();">		
<%if(vSponsorStudList.size() > 0) {%>&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-size:9px;"><%=vSponsorStudList.remove(0)%><%}%></font>	  </td>
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
      <td height="25" colspan="2" style="font-weight:bold; font-size:24;" class="thinborderBOTTOM" valign="bottom">:: DEBIT ENTRY ::	  </td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Number of Debit Entries: 
        <select name="tot_debit" onChange="document.form_.focus_2.value='1';ReloadPage();">
<%
for(int i = 1; i <= 5; ++i) {
	if(i == iTotDebit)
		strTemp = " selected";
	else
		strTemp = "";
%>
          <option value="<%=i%>" <%=strTemp%>><%=i%></option>
          <%}%>
        </select>	  </td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%
for(int i = 0; i <iTotDebit; ++i){
if(WI.fillTextValue("amount_d"+i).length() > 0) {
	try {
		if(!bolDistribute)
			dTotal = dTotal - Double.parseDouble(WI.fillTextValue("amount_d"+i));
	}
	catch(Exception e) {}
}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Chart of Account </td>
      <td height="25"><input name="coa<%=i%>" type="text" size="24" value="<%=WI.fillTextValue("coa"+i)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxCOA(document.form_.coa<%=i%>,'coa_<%=i%>','coa<%=i%>');">
	  
	  &nbsp;
	  <label style="position:absolute" id="coa_<%=i%>"></label>	  </td>
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
<%if(dBalanceToMake > 0d) {%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center">PAYMENT
          DETAILS </div></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%" style="font-weight:bold; font-size:24;">OR AMOUNT  </td>
      <td width="28%">
<%
strTemp = WI.fillTextValue("amount");
if(dTotal > 0d) {
	strTemp = CommonUtil.formatFloat(dTotal, true);
	strTemp = ConversionTable.replaceString(strTemp, ",","");
}
%>	   <input name="amount" type="text" size="18" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount');computeCashChkAmt();style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','amount');computeCashChkAmt();" style="font-size:20px; font-weight:bold"></td>
      <td colspan="2">
	  <input type="button" name="122" value="Distribute Payment" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="DistributePayment();">
	  <font style="font-size:9px; font-weight:bold">
	  	<br>NOTE: Click here to distribute payment among the students if Payment is less than required 
	  </font>
	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Bank Payment </td>
      <td>
        <select name="bank_payment_index" style="font-size:11px" >
          <option value=""></option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH",
		" from FA_BANK_LIST where is_valid = 1 and is_used_bank_post = 1 order by bank_code", request.getParameter("CHECK_FR_BANK_INDEX"), false)%>
        </select>	  </td>
      <td valign="top" width="8%">Ref #</td>
      <td valign="top" width="44%"><font size="1"><b>
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
<%}%>
<script language="JavaScript">
this.ShowHideCheckNO();
this.computeTotPmt();
</script>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="9"><hr size="1"></td>
    </tr>
<%if(iAccessLevel > 1 && dBalanceToMake > 0d){%>
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
 <input type="hidden" name="pmt_receive_type" value="Internal">
 <input type="hidden" name="distribute_pmt">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
