<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

</style>
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) {
		//cancell is called.
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";

		document.form_.particular.value = "";
		document.form_.coa_index.value = "";
		document.form_.amount.value = "";

		if(document.form_.particular_c) {
			document.form_.particular_c.value = "";
			document.form_.coa_index_c.value = "";
			document.form_.amount_c.value = "";
		}
	}
	if(strAction == "0")
		document.form_.submit();
}
function PreparedToEdit(strInfoIndex, strDebitInfo) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.is_debit.value = strDebitInfo;

	if(strDebitInfo == "1")
		document.form_.set_focus.value='1';
	else
		document.form_.set_focus.value='2';

	document.form_.submit();
}
function AddCOA(strCOACF) {
	location = "./chart_of_account.jsp?coa_cf="+strCOACF;
}
function ConfirmDel(strInfoIndex) {
	if(confirm("Do you want to delete."))
		return this.PageAction('0',strInfoIndex);
}
function focusID() {
	if(!document.form_.set_focus)
		return;
	var strSetFocus = document.form_.set_focus.value;
	if(strSetFocus == "1")
		document.form_.focus_debit.focus();
	else if(strSetFocus == "2")
		document.form_.focus_credit.focus();
}
function AddDetail(strInfoIndex) {
	var pgLoc = "";
	var strJVType = document.form_.jv_type.value;
	//1 = scholarship, 2 = add/drop, 3 = enrollment -- more on JV


	//10 = CD others, 11 = cd Petty cash  -- more on cd.

	///go here if jv_type = 0
	pgLoc = "./jv_ar_student.jsp?credit_index="+strInfoIndex+
	"&jv_number="+document.form_.jv_number.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
}

////print called here..
function PrintJV() {
	strJVNumber = document.form_.jv_number.value;
	if(strJVNumber.length == 0) {
		alert("JV Number not found.");
		return;
	}
	var pgLoc = "./print_jv.jsp?jv_number="+strJVNumber;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
}
function PrintSupportingDoc() {
	strJVNumber = document.form_.jv_number.value;
	if(strJVNumber.length == 0) {
		alert("JV Number not found.");
		return;
	}

	var pgLoc = "";
	var strJVType = document.form_.jv_type.value;
	if(strJVType == "2") {//add drop.. print supporting doc of add/drop..
		strJVType = document.form_.jv_index.value;//jv_index
		pgLoc = "../../../fee_assess_pay/fee_adjustments/add_drop_entry.jsp?jv_index="+strJVType+"&add_drop_stat=0";
	}
	else if(strJVType == "1") {//scholarship.. print supporting doc of scholarship .. to come..
		strJVType = document.form_.jv_index.value;//jv_index
		pgLoc = "../../../fee_assess_pay/fee_adjustments/add_drop_entry.jsp?jv_index="+strJVType+"&add_drop_stat=0";
	}
	else
		pgLoc = "./print_jv_detail.jsp?jv_number="+strJVNumber;

	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
}

///
function UpatePCAmt() {
	var vSelIndex = document.form_.pc_select.selectedIndex;
	var dAmount = "";
	eval('dAmount = document.form_.pc_amount'+vSelIndex+'.value');
	document.form_.amount.value = dAmount;
}


///for searching COA
		var objCOA;
function MapCOAAjax(strIsBlur,strCoaFieldName, strParticularFieldName) {
		if(strCoaFieldName == 'coa_index')
			objCOA=document.getElementById("coa_info");
		else
			objCOA=document.getElementById("coa_info_c");

		var objCOAInput;
		eval('objCOAInput=document.form_.'+strCoaFieldName);
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name="+strCoaFieldName+"&coa_particular="+
			strParticularFieldName+"&is_blur="+strIsBlur;
		this.processRequest(strURL);
}
function COASelected(strAccountName, objParticular) {
	objCOA.innerHTML = "End of Processing..";
	if(objParticular != null) {
		objParticular.value = strAccountName;
	}
}

///use ajax to update voucher date and voucher number.
function UpdateInfo(strIndex) {
	if(strIndex == '1') {//update voucher date
		if(!confirm("Are you sure you want to change voucher date?"))
			return;
		if(document.form_.voucher_date_prev.value == document.form_.jv_date.value) {
			alert("Please enter new voucher date and click update.");
			return;
		}
		document.form_.page_action_2.value = "1";
	}
	else {//update voucher number
		var strJVNumber = prompt("Please enter voucher Number : ", "");
		if(strJVNumber == null)
			return;
		if(strJVNumber.length == 0) {
			alert("Please enter new voucher number.");
			return;
		}
		if(strJVNumber == document.form_.jv_number.value) {
			alert("Please enter new voucher number.");
			return;
		}
		document.form_.new_jv_num.value = strJVNumber;
		document.form_.page_action_2.value = "2";
	}

	document.form_.submit();
}
function RemoveAllInfo() {
	if(!confirm("Are you sure you want to remove all information of this voucher? Click cancel to return, Ok to remove"))
		return;
	document.form_.remove_all.value = '1';
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","journal_voucher_entry.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
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

///if called to update payee name, change it here.
String strJVType = WI.fillTextValue("jv_type");
String strJVNumber = WI.fillTextValue("jv_number");/////I must get when i save / edit.
if(WI.fillTextValue("update_payee_name").length() > 0) {
	strTemp = WI.fillTextValue("payee_name");
	if(strTemp.length() == 0)
		strErrMsg = "Must enter payee name";
	else {
		dbOP.executeUpdateWithTrans("update ac_jv set payee_name="+
			WI.getInsertValueForDB(strTemp, true, null)+" where jv_number='"+strJVNumber+"'",
			null, null , false);
	}
}
Vector vRetResult = null;
JvCD jvCD = new JvCD();
boolean bolMustStop  = false;
boolean bolNewCreate = false;

if(WI.fillTextValue("page_action_2").length() > 0) {
	if(jvCD.modifyJVInfo(dbOP, request) == null)
		strErrMsg = jvCD.getErrMsg();
	else {
		if(WI.fillTextValue("page_action_2").equals("1"))
			strErrMsg = "Voucher date changed successfully.";
		else {
			strErrMsg = "Voucher Number changed successfully.";
			strJVNumber = WI.fillTextValue("new_jv_num");
		}
	}
	//System.out.println(strErrMsg);
}

if(strJVNumber.length() == 0 && (strJVType.equals("2") || strJVType.equals("1")) ){//add /drop - or scholarship..
	//I must save jv number automatically..
	if(strJVType.equals("1"))
		vRetResult = jvCD.createJVAddlJVType(dbOP, request, 2);
	else
		vRetResult = jvCD.createJVAddlJVType(dbOP, request, 1);

	if(vRetResult == null || vRetResult.size() == 0)  {
		bolMustStop = true;
		strErrMsg = jvCD.getErrMsg();
	}
	else
		strJVNumber = (String)vRetResult.elementAt(0);

}

boolean bolIsJVLocked = false;
Vector vJVInfo = null;////[0]=jv_index, [1] = jv_date [2]=is_locked,[3]=explanation,[4]=remark.

Vector vEditInfo  = null; Vector vJVDetail = null; //to show detail at bottom of page.

String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	request.setAttribute("jv_number",strJVNumber);
	Vector vTemp = jvCD.createJV(dbOP, request, Integer.parseInt(strTemp));
	if(vTemp == null) {
		strErrMsg = jvCD.getErrMsg();
		if(jvCD.strJVNum != null)
			strJVNumber = jvCD.strJVNum;
	}
	else {
		if(strTemp.equals("1") || strTemp.equals("2"))
			strJVNumber = (String)vTemp.elementAt(0);
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}

}
if(strJVNumber != null && strJVNumber.length() > 0) {
	request.setAttribute("jv_number",strJVNumber);
	vRetResult = jvCD.createJV(dbOP, request, 4);
	if(vRetResult == null) {
		if(strErrMsg == null)
			strErrMsg = jvCD.getErrMsg();
	}
	else {
		vJVInfo    = (Vector)vRetResult.remove(0);
		vRetResult = (Vector)vRetResult.remove(0);
		if(vJVInfo.elementAt(2).equals("1")) {
			if(!strSchCode.startsWith("UDMC"))//saci does not want to lock voucher..
				bolIsJVLocked = true;
			strErrMsg = "Voucher is locked. It is for viewing purpose only. Can't be modified anymore.";
		}
	}

}


if(strPreparedToEdit.equals("1")) {
	vEditInfo = jvCD.createJV(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = jvCD.getErrMsg();
}

if(strJVNumber != null)
	vJVDetail = jvCD.viewDetailJV(dbOP, strJVNumber);



String strIsCD = WI.fillTextValue("is_cd");
if(vJVDetail != null) {
	strIsCD = (String)((Vector)vJVDetail.elementAt(0)).elementAt(3);
	if(strIsCD == null)
		strIsCD = "0";
	strTemp = (String)((Vector)vJVDetail.elementAt(0)).elementAt(2);//jv type.
	if(!strTemp.equals(strJVType)) {
		strErrMsg = "Jv number does not belong to this jv type.";
		bolMustStop = true;
	}

}
else
	bolNewCreate = true;


if(strIsCD.length() == 0)
	strIsCD = "0";

///I have to check if jv type clicked is correct.
//for scholarship = get account number..
int iJVType = Integer.parseInt(strJVType);
if(iJVType > 9) {//must be strIsCD  = 1
	if(strIsCD.equals("0")) {
		strErrMsg = "Wrong re-direct. It must not be called from JV Page.";
		vRetResult = null;
	}//change vRetResult - null so that i return form this page.
}

Vector vPettyCashCDPending = null;
if(iJVType == 11) {//Petty cash
	vPettyCashCDPending = jvCD.operateOnCDPettyCash(dbOP, request, 5);


}

/**
boolean bolAFormatToggleAllowed = false;
int iAccountFormat = 0; int iAccountLen = 0;
java.sql.ResultSet rs = dbOP.executeQuery("select ACC_NO_FORMAT,LENGTH from AC_COA_AC_LEN");
rs.next();
iAccountFormat = rs.getInt(1);
iAccountLen    = rs.getInt(2);
rs.close();

if(dbOP.getResultOfAQuery("select COA_INDEX from AC_COA WHERE IS_VALID = 1", 0) == null)
	bolAFormatToggleAllowed = true;
if(WI.fillTextValue("toggle").length() > 0) {
	if(WI.fillTextValue("toggle").equals("1")) {///update account code length.
		if(dbOP.executeUpdateWithTrans("update AC_COA_AC_LEN set LENGTH = "+
			WI.fillTextValue("coa_len"), null, null, false) != -1)
			iAccountLen = Integer.parseInt(WI.fillTextValue("coa_len"));
	}
	else {
		if(iAccountFormat == 1)
			iAccountFormat = 0;
		else
			iAccountFormat = 1;
		dbOP.executeUpdateWithTrans("update AC_COA_AC_LEN set ACC_NO_FORMAT = "+
			Integer.toString(iAccountFormat), null, null, false);
	}
}


**/
boolean bolRemoveAllowed = false;

if(strSchCode.startsWith("UDMC") && vJVInfo != null){
	request.setAttribute("del_jv_index", vJVInfo.elementAt(0));

	if(jvCD.removeJVCDAllowed(dbOP, request))
		bolRemoveAllowed = true;

	//bolIsJVLocked = false;
	if(WI.fillTextValue("remove_all").equals("1")) {
		request.setAttribute("del_jv_index", vJVInfo.elementAt(0)) ;
		if(jvCD.removeJVCD(dbOP, request))
			strErrMsg = "Voucher information removed successfully.";
		else
			strErrMsg = jvCD.getErrMsg();
	}
}


%>
<form action="./journal_voucher_entry.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          <%if(strIsCD.equals("2")){%>PETTY CASH<%}else if(strIsCD.equals("1")){%>DISBURSEMENT<%}else{%>JOURNAL VOUCHER<%}%> ENTRY - DETAILS ENCODING PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; color:#0000FF; font-weight:bold"><a href="<%if(strIsCD.equals("2")){%>../petty_cash/petty_cash.jsp<%}else if(strIsCD.equals("1")){%>../cash_disbursement/cash_disbursement.jsp<%}else{%>./journal_voucher.jsp<%}%>"><img src="../../../../images/go_back.gif" border="0"></a>
		&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%>
	  </td>
    </tr>
  </table>
<%
if(bolMustStop) {
	dbOP.cleanUP();
	return;
}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="6%">&nbsp;</td>
      <td width="15%" valign="top">Voucher No.</td>
      <td width="79%" style="font-size:11px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strJVNumber,"<label onClick=UpdateInfo('2');>","</label>","To be auto generated")%>
	  <%
	  strTemp = strJVType;
	  if(strTemp.length() > 0) {
	  	int iJvType = Integer.parseInt(strTemp);
		if(iJVType == 0 || iJVType == 10)
			strTemp = "Others";
		else if(iJVType == 1)
			strTemp = "Scholarship";
		else if(iJVType == 2)
			strTemp = "Add/Drop";
		else if(iJVType == 3)
			strTemp = "Enrollment";
		else if(iJVType == 11)
			strTemp = "Petty Cash";
		else
			strTemp = "";
		%><div align="right" style="font-size:11px; color:#0000FF; font-weight:bold"><%=strTemp%></div>
	 <%}%>
	  </td>
    </tr>
<%
//if(strJVNumber != null && strJVNumber.length() > 0 && vRetResult == null) {
//dbOP.cleanUP();
//return;
//}
if(bolRemoveAllowed){%>
    <tr>
      <td height="9" colspan="3"><a href="javascript:RemoveAllInfo();"><font color="#333333">Remove All Voucher Information</font></a></td>
    </tr>
<%}%>
    <tr>
      <td height="9" colspan="3"><hr size="1"></td>
    </tr>
<%if(!bolIsJVLocked){//if locked, do not edit information. or show input boxes..
if(strIsCD.equals("1") || strIsCD.equals("2")){%>    <tr>
      <td height="25">&nbsp;</td>
      <td>Payee Name </td>
      <td style="font-size:9px;">
<%
//i have to get voucher date here if created already.
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("payee_name");
%>
	  <input name="payee_name" type="text" size="45" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">(one payee per voucher)
<%if(vJVInfo != null) {%>
<input type="submit" name="122" value=" Update Payee Name " style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.update_payee_name.value='1';PageAction('','');">
<%}%>
	  </td>
    </tr>
<%}//show payee name if this is for CD.. %>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Voucher Date</td>
      <td>
<%
//i have to get voucher date here if created already.
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(1);
else
	strTemp = WI.getTodaysDate(1);
%>
        <input name="jv_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.jv_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>

		&nbsp;&nbsp;&nbsp;&nbsp;
<%if(vJVInfo != null){%>
		<a href="javascript:UpdateInfo('1');">Update Voucher Date</a>
<%}%>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Group Number </td>
      <td>
<%if(bolNewCreate) {%><b style="font-size:11px;">1 - Fixed</b>
<%}else{%>
	  <select name="group_number" onChange="document.form_.submit();">
<%
strTemp = WI.fillTextValue("group_number");
int iGroupNo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("group_number"), "1"));
	for(int i =1; i < 6; ++i){
		if(iGroupNo == i)
			strTemp = " selected";
		else
			strTemp = "";
	%><option value="<%=i%>"<%=strTemp%>><%=i%></option>
<%}%></select>
<%}%>&nbsp;&nbsp;&nbsp;
	  <input type="submit" name="122" value=" Refresh " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFCCFF">
      <td height="28">&nbsp;</td>
      <td><strong><u><font size="3">DEBIT</font></u></strong></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Particular</td>
      <td colspan="2"><%
if(vEditInfo != null && WI.fillTextValue("is_debit").equals("1"))
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("particular");
%>
      <textarea name="particular" rows="4" cols="70" class="textbox" style="font-size:11px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
<%
if(strPreparedToEdit.equals("1") && false){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Show when edit is clicked. </td>
      <td colspan="2"><input type="checkbox" name="checkbox3" value="checkbox">
        A/R FS &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <input type="checkbox" name="checkbox23" value="checkbox">
        A/R Student &nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <input type="checkbox" name="checkbox222" value="checkbox">
        A/R Others</td>
    </tr>
<%}//show only if edit is clicked.%>
    <tr>
      <td height="26">&nbsp;</td>
      <td valign="top">Charged to </td>
      <td width="28%" valign="top">
<%
if(vEditInfo != null && WI.fillTextValue("is_debit").equals("1"))
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("coa_index");
%>	  <input name="coa_index" type="text" size="26" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onkeyUP="MapCOAAjax('0','coa_index','document.form_.particular');"></td>
      <td width="51%"><label id="coa_info" style="font-size:11px;"></label></td>
    </tr>

<%if(iJVType != 11){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Amount </td>
      <td colspan="2">
	<%
	if(vEditInfo != null && WI.fillTextValue("is_debit").equals("1"))
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = WI.fillTextValue("amount");
	%>
		<input name="amount" type="text" size="12" maxlength="32" value="<%=strTemp%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'"
	   		onKeyUp="AllowOnlyFloat('form_','amount');"></td>
    </tr>
<%}else{
	if(iJVType == 11){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Petty Cash Reference #</td>
      <td colspan="2">
	  	<%if(vPettyCashCDPending != null){%>
			<select name="pc_select" onChange="UpatePCAmt();">
				<%strErrMsg = ""; String strIsSelected = "";
				strTemp = WI.fillTextValue("pc_select");
				for(int i =0; i < vPettyCashCDPending.size(); i += 2) {
					if(strTemp.equals(vPettyCashCDPending.elementAt(i))) {
						strErrMsg = (String)vPettyCashCDPending.elementAt(i+1);
						strIsSelected = " selected";
					}else
						strIsSelected = "";%>
						<option value="<%=vPettyCashCDPending.elementAt(i)%>"<%=strIsSelected%>><%=vPettyCashCDPending.elementAt(i)%></option>
				<%}if(strErrMsg.length() == 0)
					strErrMsg = (String)vPettyCashCDPending.elementAt(1);%>
			</select>
			<%for(int i =0; i < vPettyCashCDPending.size(); i += 2) {%>
			<input type="hidden" name="pc_amount<%=i/2%>" value="<%=vPettyCashCDPending.elementAt(i + 1)%>">
			<%}%>
	  <%}//only if vPettyCashCDPending is not null%>
	  <input type="textbox" name="amount" value="<%=strErrMsg%>" class="textbox_noborder" readonly>  	  </td>
    </tr>

<%strErrMsg = "";}//show for iJVType == 11
}%>

    <tr>
      <td height="10">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
      <td colspan="2"><%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');document.form_.is_debit.value='1';document.form_.set_focus.value='1'">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else if(WI.fillTextValue("is_debit").equals("1")){%>
<input type="submit" name="12" value=" Edit Info " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="3">
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	  	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#CCDDDD">
<%for(int i = 0; i < vRetResult.size() && vRetResult.elementAt(4).equals("1");){%>
          <tr>
            <td width="50%" height="20" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
            <td width="15%" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
            <td width="15%" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3), true)%></td>
            <td width="6%" class="thinborder" align="center"><a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i)%>','1');" style="font-size:11px; color:#0000aa">Edit</a></td>
            <td width="7%" class="thinborder" align="center"><a href="javascript:ConfirmDel('<%=vRetResult.elementAt(i)%>');" style="font-size:11px; color:#0000aa">Delete</a></td>
            <td width="7%" class="thinborder" align="center">
			<%if( iJVType == 11 || strIsCD.equals("2") || strJVType.equals("2") || strJVType.equals("3") ){%>&nbsp;<%}else{%>
				<a href="javascript:AddDetail('<%=vRetResult.elementAt(i)%>');" style="font-size:11px; color:#0000aa">Add Detail</a>
			<%}%></td>
          </tr>
<%
vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);

}//end of showing particular.%>
        </table>
<%}else{%><font style="font-size:11px; font-weight:bold; color:#FF0000">No particular created yet</font><%}%>	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="3"><input name="focus_debit" type="text" class="textbox_noborder" style="background-color:#FFFFFF" size="1" readonly=""></td>
    </tr>
<%//if(!strIsCD.equals("0") || !bolNewCreate) { //before CD was allowing mis matching.. now it is not.
if(!bolNewCreate) {%>
    <tr bgcolor="#99CCFF">
      <td height="28">&nbsp;</td>
      <td><strong><u><font size="3">CREDIT</font></u></strong></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Particular</td>
      <td colspan="2">
<%
if(vEditInfo != null && WI.fillTextValue("is_debit").equals("0"))
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("particular_c");
%>
	  <textarea name="particular_c" rows="4" cols="70" class="textbox" style="font-size:11px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
<%
if(false && strPreparedToEdit.equals("1")){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Show when edit is clicked. </td>
      <td colspan="2"><input type="checkbox" name="checkbox3" value="checkbox">
        A/R FS &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <input type="checkbox" name="checkbox23" value="checkbox">
        A/R Student &nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <input type="checkbox" name="checkbox222" value="checkbox">
        A/R Others</td>
    </tr>
<%}//show only if edit is clicked.%>
    <tr>
      <td height="26">&nbsp;</td>
      <td valign="top">Charged to </td>
      <td valign="top">
<%
if(vEditInfo != null && WI.fillTextValue("is_debit").equals("0"))
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("coa_index_c");
%>	  <input name="coa_index_c" type="text" size="22" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onkeyUP="MapCOAAjax('0','coa_index_c','document.form_.particular_c');"></td>
      <td><label id="coa_info_c" style="font-size:11px;"></label></td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td>Amount </td>
      <td colspan="2">
<%
if(vEditInfo != null && WI.fillTextValue("is_debit").equals("0"))
	strTemp = (String)vEditInfo.elementAt(3);
else if(strIsCD.equals("1") && vJVDetail != null && vJVDetail.elementAt(0) != null)
	strTemp = (String)((Vector)vJVDetail.elementAt(0)).elementAt(7);
else
	strTemp = WI.fillTextValue("amount_c");
%>	  <input name="amount_c" type="text" size="12" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount_c');style.backgroundColor='white'"
	   onKeyUp="AllowOnlyFloat('form_','amount_c');"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
      <td colspan="2"><%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');document.form_.is_debit.value='0';document.form_.set_focus.value='2'">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else if(WI.fillTextValue("is_debit").equals("0")){%>
<input type="submit" name="124" value=" Edit Info " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="3">
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	  	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#BFBFBF">
<%for(int i = 0; i < vRetResult.size();){%>
          <tr>
            <td width="50%" height="20" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
            <td width="15%" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
            <td width="15%" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3), true)%></td>
            <td width="6%" class="thinborder" align="center"><a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i)%>','0');" style="font-size:11px; color:#0000aa">Edit</a></td>
            <td width="7%" class="thinborder" align="center"><a href="javascript:ConfirmDel('<%=vRetResult.elementAt(i)%>');" style="font-size:11px; color:#0000aa">Delete</a></td>
            <td width="7%" class="thinborder" align="center">
			<%if(strIsCD.equals("2") || strJVType.equals("2") || strJVType.equals("3") ){%>&nbsp;<%}else{%><a href="javascript:AddDetail('<%=vRetResult.elementAt(i)%>');" style="font-size:11px; color:#0000aa">Add Detail</a><%}%>
			</td>
          </tr>
<%
vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);

}//end of showing particular.%>
        </table>
<%}else{%><font style="font-size:11px; font-weight:bold; color:#FF0000">No particular created yet</font><%}%></td>
    </tr>

    <tr>
      <td height="26" colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td valign="top"><br>Explanation</td>
      <td colspan="2">
<%
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("explanation");
%>
	  <textarea name="explanation" rows="4" cols="70" class="textbox" style="font-size:11px;"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr>
      <td  width="6%"height="34">&nbsp;</td>
      <td width="15%" valign="top"><br>Remark</td>
      <td colspan="2">
<%
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("remark");
%>
	  <textarea name="remark" rows="4" cols="70" class="textbox" style="font-size:11px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" valign="bottom">
	  <%if(iAccessLevel > 1) {%>
        <input type="submit" name="123" value=" Update Information " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('5','');">
	  <%}%>	</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><input name="focus_credit" type="text" class="textbox_noborder" style="background-color:#FFFFFF" size="1" readonly></td>
      <td colspan="2" style="font-size:14px; color:#0000FF; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>

<%	}//show the credit only after jv is created..

}//if (!bolIsJVLocked)%>
  </table>

<%if(vJVDetail != null && vJVDetail.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="5" class="thinborder" style="font-size:10px; font-weight:bold" align="right">&nbsp;</td>
    </tr>
    <tr>
      <td class="thinborder" style="font-size:10px; font-weight:bold">Print <%if(strIsCD.equals("2")){%>PC<%}else if(strIsCD.equals("1")){%>CD<%}else{%>JV<%}%> <a href="javascript:PrintJV();">
	  	<img src="../../../../images/print.gif" border="0"></a> </td>
      <td height="25" colspan="4" align="right" class="thinborder" style="font-size:10px; font-weight:bold;">
	  <%if(strIsCD.equals("2")){%>&nbsp;<%}else{%>Print supporting Document
	  <a href="javascript:PrintSupportingDoc();"><img src="../../../../images/print.gif" border="0"></a><%}%></td>
    </tr>
    <tr bgcolor="#D9DFE1">
      <td height="27" colspan="5" class="thinborder" align="center" style="font-size:10px; font-weight:bold; color:#FF0000">
	  ::  VOUCHER FOR -:  <%=WI.getStrValue(strJVNumber)%> ::</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#99CCFF" class="thinborder" width="32%"><div align="center"><strong>DEBIT </strong></div></td>
      <td bgcolor="#FFCC99" class="thinborder" width="32%"><div align="center"><strong>CREDIT</strong></div></td>
      <td class="thinborder" width="15%" align="center">Explanation</td>
      <td class="thinborder" width="15%" align="center">Remarks</td>
      <td class="thinborder" width="6%" align="center">Edit</td>
    </tr>
<%
    vJVInfo    = (Vector)vJVDetail.remove(0);//[0]=JV_INDEX,[1]=JV_DATE
    Vector vGroupInfo = (Vector)vJVDetail.remove(0);//[0]=group number, [1]=Explanation, [2]=remarks.
    vJVDetail  = (Vector)vJVDetail.remove(0);//[0]=coa_number,[1]=PARTICULAR,[2]=AMOUNT,[3]=GROUP_NUMBER,[4]=is_debit
String strBGRed = null;//must be red if credit/debit not matching.
%><input type="hidden" name="jv_index" value="<%=vJVInfo.elementAt(0)%>">
<%
for(int i =0; i < vGroupInfo.size(); i += 4){
	if(vGroupInfo.elementAt(i + 3).equals("0") )///&& strIsCD.equals("0"))
		strBGRed = " bgcolor=red";
	else
		strBGRed = "";
	strTemp = (String)vGroupInfo.elementAt(i);//group number;%>
     <tr<%=strBGRed%>>
      <td height="25" bgcolor="#99CCFF" class="thinborder" valign="top">
	  	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			<tr>
				<td width="60%" class="thinborder"><strong>Particular</strong></td>
				<td width="25%" class="thinborder"><strong>Account #</strong></td>
				<td width="15%" class="thinborder"><strong>Amount</strong></td>
			</tr>
			<%while(vJVDetail.size() > 0) {
				if(!vJVDetail.elementAt(3).equals(strTemp) || vJVDetail.elementAt(4).equals("0"))//if not debit or if not belong to same group.. break.
					break;%>
				<tr>
					<td width="60%" class="thinborder"><%=vJVDetail.elementAt(1)%></td>
					<td width="25%" class="thinborder"><%=vJVDetail.elementAt(0)%></td>
					<td width="15%" class="thinborder"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%></td>
				</tr>
			<%
			vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
			vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);}%>
		</table>	  </td>
      <td bgcolor="#FFCC99" class="thinborder" valign="top">
	  	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			<tr>
				<td width="60%" class="thinborder"><strong>Particular</strong></td>
				<td width="25%" class="thinborder"><strong>Account #</strong></td>
				<td width="15%" class="thinborder"><strong>Amount</strong></td>
			</tr>
			<%while(vJVDetail.size() > 0) {
				if(!vJVDetail.elementAt(3).equals(strTemp) || vJVDetail.elementAt(4).equals("1"))//if not debit or if not belong to same group.. break.
					break;%>
				<tr>
					<td width="60%" class="thinborder"><%=vJVDetail.elementAt(1)%></td>
					<td width="25%" class="thinborder"><%=vJVDetail.elementAt(0)%></td>
					<td width="15%" class="thinborder"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%></td>
				</tr>
			<%
			vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
			vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);}%>
		</table>	  </td>
      <td class="thinborder" valign="top"><%=vGroupInfo.elementAt(i + 1)%></td>
      <td class="thinborder" valign="top"><%=WI.getStrValue(vGroupInfo.elementAt(i + 2),"&nbsp;")%></td>
      <td class="thinborder" align="center" valign="top"><%if(!bolIsJVLocked){%>
	  <br>
	  <a href="./journal_voucher_entry.jsp?jv_number=<%=strJVNumber%>&group_number=<%=vGroupInfo.elementAt(i)%>&jv_type=<%=strJVType%>&is_cd=<%=WI.fillTextValue("is_cd")%>">Edit</a>
	  <%}else{%>&nbsp;<%}%></td>
    </tr>
<%}//end of vGroupInfo%>
</table>


  <%}//end if vJVDetail display.. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="page_action_2">
<input type="hidden" name="new_jv_num">

<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<!-- Indicates debit info .. if debit is clicked is_debit = 1, if credit is clicked it is 0 -->
<input type="hidden" name="is_debit" value="<%=WI.fillTextValue("is_debit")%>">

<input type="hidden" name="jv_number" value="<%=strJVNumber%>">
<input type="hidden" name="set_focus" value="<%=WI.fillTextValue("set_focus")%>">

<%if(vJVInfo != null){%>
<input type="hidden" name="voucher_date_prev" value="<%=(String)vJVInfo.elementAt(1)%>">
<%}%>


<%

/*******************************this is jv type **********************************
 0 = others, 1 = scholarship, 2 = add/drop, 3 = enrollment, 4 = more to come.
 10 = others - cd, 11 = Petty cash - cd.
**********************************************************************************/
%>
<input type="hidden" name="jv_type" value="<%=strJVType%>">
<input type="hidden" name="is_cd" value="<%=strIsCD%>">

<input type="hidden" name="update_payee_name">

<%if(strSchCode.startsWith("UDMC")){%>
<input type="hidden" name="remove_all">
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
