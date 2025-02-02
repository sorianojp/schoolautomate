<%
String strTemp = (String)request.getParameter("print_page");
if(strTemp != null && strTemp.equals("1")){//page forward here%>
	<jsp:forward page="./cdv_encode_check_dtls_print.jsp"></jsp:forward>
<%}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) {
		//cancell is called.
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";

		document.form_.check_no.value = "";
		document.form_.amount.value = "";
	}

	document.form_.print_page.value = '';
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";

	document.form_.print_page.value = '';
}
function AddCOA(strCOACF) {
	location = "./chart_of_account.jsp?coa_cf="+strCOACF;
}
function ConfirmDel(strInfoIndex) {
	if(confirm("Do you want to delete."))
		return this.PageAction('0',strInfoIndex);

	document.form_.print_page.value = '';
}
function PrintChk(strChkIndex) {
	var strSignatory = "";
	if(document.form_.sig1) {
		strSignatory = "&sig1="+escape(document.form_.sig1.value)+"&sig2="+escape(document.form_.sig2.value);
	}
	var pgLoc = "./print_check.jsp?chk_index="+strChkIndex+strSignatory;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPage() {
	document.form_.print_page.value = '1';
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="document.form_.cd_index.focus();">
<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","cdv_encode_check_dtls.jsp");
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

String strJVNumber = WI.fillTextValue("cd_index");/////I must get when i save / edit.
JvCD jvCD = new JvCD();

Vector vJVDetail  = null; //to show detail at bottom of page.
Vector vJVInfo    = null;
Vector vGroupInfo = null;

Vector vRetResult = null;//all regarding check detail.
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");

if(WI.fillTextValue("page_action").length() > 0) {
	if(jvCD.operateOnCDCheck(dbOP, request, Integer.parseInt(WI.fillTextValue("page_action"))) == null)
		strErrMsg = jvCD.getErrMsg();
	else {
		strErrMsg = "Operation successful.";
		strPreparedToEdit = "0";
	}
}
double dTotalCheckMade = 0d;
double dTotalBal       = 0d;
if(strPreparedToEdit.equals("1")) {
	vEditInfo = jvCD.operateOnCDCheck(dbOP, request, 3);
	if(vEditInfo != null) {
		vEditInfo.removeElementAt(0);vEditInfo.removeElementAt(0);
	}
}
if(strJVNumber.length() > 0) {
	vRetResult = jvCD.operateOnCDCheck(dbOP, request, 4);

	if(vRetResult != null) {
		dTotalBal       = Double.parseDouble((String)vRetResult.remove(0));
		dTotalCheckMade = Double.parseDouble((String)vRetResult.remove(0));
	}
}





if(strJVNumber.length() > 0) {
	vJVDetail = jvCD.viewDetailJV(dbOP, strJVNumber);
	if(vJVDetail == null)
		strErrMsg = jvCD.getErrMsg();
	else {
	    vJVInfo    = (Vector)vJVDetail.remove(0);//[0]=JV_INDEX,[1]=JV_DATE, [2] = jv_type, [3] = is_cd,[4] lock_date, [5] = payee name, [6] = total debit..
	    vGroupInfo = (Vector)vJVDetail.remove(0);//[0]=group number, [1]=Explanation, [2]=remarks.
    	vJVDetail  = (Vector)vJVDetail.remove(0);//[0]=coa_number,[1]=PARTICULAR,[2]=AMOUNT,[3]=GROUP_NUMBER,[4]=is_debit

		if(vJVInfo.elementAt(3).equals("0")) {
			strErrMsg = "Please enter Cash disbursement voucher number.";
			vJVInfo = null;
		}
	}
}
else
	strErrMsg = "Please enter voucher number.";

//for CD, i should get error if balance is not zero..
if(vJVInfo != null) {
	if(!vJVInfo.elementAt(7).equals("0.0")){
		strErrMsg = "Balance is not matching. Please check credit/debit amount. Both amount must match.";
		vRetResult = null;
	}
	//I have to find out if this CD is not for check pmt type..
	if(vJVInfo.elementAt(10) == null || !vJVInfo.elementAt(10).equals("1")) {
		strErrMsg = "Disbursement Voucher Payment Type is not CHECK. Checks can't be made. Proceed to Locking of voucher.";
		vRetResult = null;
	}
}


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCIT = strSchCode.startsWith("CIT");
%>
<form action="./cdv_encode_check_dtls.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          DISBURSEMENT : CHECK DETAILS ENCODING PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:11px; font-weight:bold; color:#FF0000">
	  	<a href="cash_disbursement.jsp"><img src="../../../../images/go_back.gif" border="0"></a>
			&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td>Voucher No.</td>
      <td width="18%">
	  <input name="cd_index" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("cd_index")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="9%"><a href="../journal_voucher/jv_summary.jsp?is_cd=1" target="_blank"><img src="../../../../images/search.gif" border="0"></a></td>
      <td width="54%">
      	<input type="submit" name="12" value=" Proceed >>" onClick="document.form_.page_action.value='';document.form_.info_index.value='';document.form_.print_page.value='';document.form_.preparedToEdit.value=''" style="font-size:11px; height:22px;border: 1px solid #FF0000;">
	  </td>
    </tr>
    <tr>
      <td height="26" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%if(vJVDetail != null && vJVDetail.size() > 0 && vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2" style="font-size:11px; font-weight:bold; color:#FF0000">
	  Total amount having check made : <%=CommonUtil.formatFloat(dTotalCheckMade, true)%>
	  &nbsp;&nbsp;&nbsp;Total Balance Amount : <%=CommonUtil.formatFloat(dTotalBal, true)%></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Charge To </td>
      <td>
	  <select name="cd_coa_index" onChange="document.form_.submit()">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strErrMsg = (String)vEditInfo.elementAt(9);
else
	strErrMsg = WI.fillTextValue("cd_coa_index");

String strChargeToCOAIndex = null;
double dMaxAllowedChkAmt = 0d;
String strSQLQuery = "select AC_JV_DC.coa_index, ac_coa.complete_code,sum(amount)  from AC_JV_DC "+
			"join ac_coa on (ac_coa.coa_index = AC_JV_DC.coa_index) where jv_index = "+
			(String)vJVInfo.elementAt(0)+" and is_debit=0 and exists (select * from AC_COA_BANKCODE where coa_index = ac_jv_dc.coa_index) "+
			" group by AC_JV_DC.coa_index,ac_coa.complete_code";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			if(strChargeToCOAIndex == null) {
				strChargeToCOAIndex = rs.getString(1);
				dMaxAllowedChkAmt   = rs.getDouble(3);
			}
			if(strErrMsg.equals(rs.getString(1))) {///get max amount allowed to make check for this chart of account.
				strTemp = " selected";
				strChargeToCOAIndex = rs.getString(1);
				dMaxAllowedChkAmt   = rs.getDouble(3);
			}
			else
				strTemp = "";
			%>	  <option value="<%=rs.getString(1)%>"<%=strTemp%>><%=rs.getString(2)%></option>
		<%}rs.close();%>
	  </select></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Payee Name </td>
      <td style="font-size:11px; font-weight:bold">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = (String)vJVInfo.elementAt(5);
%>
	  <input type="text" name="payee_name" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Bank  </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strErrMsg = (String)vEditInfo.elementAt(9);
else
	strErrMsg = WI.fillTextValue("bank_index");
%>
	  	<select name="bank_index">
<%
strSQLQuery = "select bank_index, BANK_CODE from AC_COA_BANKCODE "+
			"where is_valid = 1 and coa_index = "+strChargeToCOAIndex;
rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			if(strErrMsg.equals(rs.getString(1))) {
				strTemp = " selected";
			}
			else
				strTemp = "";
			%>	  <option value="<%=rs.getString(1)%>"<%=strTemp%>><%=rs.getString(2)%></option>
		<%}rs.close();%>

<%
//I have to get amount to have
strSQLQuery = "select sum(amount) from AC_CD_CHECK_DTL where cd_index = "+(String)vJVInfo.elementAt(0)+
	" and cd_coa_index="+strChargeToCOAIndex;
rs = dbOP.executeQuery(strSQLQuery);
rs.next();
dMaxAllowedChkAmt = dMaxAllowedChkAmt - rs.getDouble(1);
%>
<%//=dbOP.loadCombo("bank_index","BANK_CODE"," from AC_COA_BANKCODE where is_valid = 1 order by bank_code",strTemp,false)%>
		</select>	  </td>
    </tr>
    <tr>
      <td width="4%" height="26">&nbsp;</td>
      <td width="15%">Check Number </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("check_no");

if(strTemp.length() == 0)  {
	strTemp = WI.fillTextValue("cd_index");
	if(strTemp.startsWith("CD-"))
		strTemp = strTemp.substring(3);
}

%>	  <input name="check_no" type="text" size="22" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  &nbsp;&nbsp;&nbsp;
	  Check Date :

<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(6);
else
	strTemp = WI.fillTextValue("chk_date");
if(strTemp.length() == 0 && vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(1);
if(strTemp == null || strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>
	  <input name="chk_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.chk_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>	  </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Amount</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = ConversionTable.replaceString((String)vEditInfo.elementAt(4),",","");
else
	strTemp = Double.toString(dMaxAllowedChkAmt);
%>	  <input name="amount" type="text" size="12" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Check Status </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(7);
else
	strTemp = WI.fillTextValue("chk_stat");
%>
	  	<select name="chk_stat">
			<option value="0">Outstanding</option>
		<%strErrMsg = "";
		strTemp = WI.fillTextValue("chk_stat");
		if(strTemp.equals("1"))
			strErrMsg = " selected";
		%>
			<option value="1"<%=strErrMsg%>>Cleared</option>
		</select>	  </td>
    </tr>
<%if(dTotalBal > 0 || strPreparedToEdit.equals("1")) {%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="124" value=" Save Info " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
&nbsp;&nbsp;&nbsp;&nbsp;
	<%}else{%>
<input type="submit" name="124" value=" Edit Info " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
	<%}
}%>
<input type="submit" name="124" value=" Cancel " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');"></td>
    </tr>
<%}%>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2" style="font-size:11px; color:#FF0000; font-weight:bold">
	  <%if(dTotalBal <= 0d){%>
	  	Message : Check already made for required amount.
		<div align="right" style="font-size:9px;">
		<a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a> Print Page.		</div>
		<%}%>		</td>
    </tr>
 <%if(strSchCode.startsWith("TSUNEISHI")){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2" style="font-size:11px; font-weight:bold;">
	  Signatory1: <input type="text" name="sig1" size="32" value="<%=WI.fillTextValue("sig1")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">

	  Signatory2: <input type="text" name="sig2" size="32" value="<%=WI.fillTextValue("sig2")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">


	  </td>
    </tr>
 <%}%>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#999999">
      <td height="26" style="font-size:11px; font-weight:bold; color:#0000FF" colspan="10" align="center" class="thinborder">::: LIST OF CHECK ISSUED	::: 	</td>
    </tr>
    <tr>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="12%">Account # </td>
      <td height="26" class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="8%">Bank Code </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="20%">Check # </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="20%">Payee Name </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%">Date</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="7%">Check Status </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="8%">Amount</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="5%">print</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="7%">Edit</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="8%">Remove</td>
    </tr>
<%String[] astrConvertCheckStat = {"O/S","Cleared","Bounced"};
int iChkStat = 0;

String strCheckNo   = null; String strBankIndex = null;
String strMergeWith = null;
strSQLQuery = "select jv_number,amount from ac_jv join AC_CD_CHECK_DTL on (cd_index = jv_index) where ";

String strBGColor = "";
for(int i = 0; i < vRetResult.size(); i += 12){
strMergeWith = null;
iChkStat = Integer.parseInt((String)vRetResult.elementAt(i + 7));
//System.out.println("check stat : "+iChkStat);
if(iChkStat == 0)
	strBGColor = "";
else
	strBGColor = " bgcolor='#DDDDDD'";
if(bolIsCIT)
	iChkStat = 0;

strCheckNo   = (String)vRetResult.elementAt(i + 3);
strBankIndex = (String)vRetResult.elementAt(i + 1);
if(strCheckNo.startsWith("*")) {
	rs = dbOP.executeQuery(strSQLQuery +" chk_index <> "+(String)vRetResult.elementAt(i)+" and check_no='"+strCheckNo+"' and bank_index="+strBankIndex);
	while(rs.next()) {
		if(strMergeWith == null)
			strMergeWith = "<font size=1 color=blue>(CD#:"+rs.getString(1)+" ; "+CommonUtil.formatFloat(rs.getDouble(2), true);
		else
			strMergeWith += "<br>CD#:"+rs.getString(1)+" ; "+CommonUtil.formatFloat(rs.getDouble(2), true);
	}
	rs.close();
	if(strMergeWith != null)
		strMergeWith += ")</font>";
}

%>
    <tr <%=strBGColor%>>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
      <td height="26" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=strCheckNo%><%=WI.getStrValue(strMergeWith,"<br>","","")%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=astrConvertCheckStat[iChkStat]%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><a href="javascript:PrintChk(<%=vRetResult.elementAt(i)%>);"><img src="../../../../images/print.gif" border="0" width="45" height="27"></a></td>
      <td class="thinborder">&nbsp;<%if(iChkStat == 0) {%>
  	  <input type="submit" name="122" value=" Edit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
	  <%}%></td>
      <td class="thinborder">&nbsp;<%if(iChkStat == 0) {%>
  	  <input type="submit" name="123" value=" Delete" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
	  <%}%></td>
    </tr>
<%}%>
  </table>
 <%}%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size:13px; font-weight:bold" width="3%">&nbsp;</td>
      <td height="25" style="font-size:13px; font-weight:bold" width="67%"><u>DEBIT</u></td>
      <td style="font-size:13px; font-weight:bold" width="15%">&nbsp;</td>
      <td style="font-size:11px;" width="15%" align="right">Amount&nbsp;&nbsp;</td>
    </tr>
<%boolean bolPrintGroup = false;
String strBGRed = null;
for(int i =0; i < vGroupInfo.size(); i += 4){
	if(vGroupInfo.elementAt(i + 3).equals("0") && vJVInfo.elementAt(3).equals("0"))//coloring is for jv only , for cd - none.
		strBGRed = " bgcolor=red";
	else
		strBGRed = "";
	strTemp = (String)vGroupInfo.elementAt(i);//group number;
	bolPrintGroup = true;%>
	<%for(int p = 0; p < vJVDetail.size(); p += 5) {
		if(!vJVDetail.elementAt(p + 3).equals(strTemp) )
			continue;
		if(vJVDetail.elementAt(p + 4).equals("0"))//if not debit or if not belong to same group.. continue.
			continue;%>
    <tr<%=strBGRed%>>
      <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>.
      <%}%></td>
      <td height="25" style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(p + 1)%></td>
      <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(p + 0)%></td>
      <td style="font-size:11px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%>&nbsp;</td>
    </tr>
	<%vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p -= 5;}//end of while loop.
}//end of for loop to print all debit.%>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;"><hr size="1"></td>
    </tr>
    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;</td>
      <td height="25" style="font-size:13px; font-weight:bold"><u>CREDIT</u></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%
for(int i =0; i < vGroupInfo.size(); i += 4){
	if(vGroupInfo.elementAt(i + 3).equals("0") && vJVInfo.elementAt(3).equals("0") )//coloring is for jv only , for cd - none.
		strBGRed = " bgcolor=red";
	else
		strBGRed = "";
	strTemp = (String)vGroupInfo.elementAt(i);//group number;
	bolPrintGroup = true;%>
	<%while(vJVDetail.size() > 0) {
		if(!vJVDetail.elementAt(3).equals(strTemp))//if not belong to same group.. break.
			break;%>
    <tr<%=strBGRed%>>
      <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>.<%}%></td>
      <td height="25" style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(1)%></td>
      <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(0)%></td>
      <td style="font-size:11px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>&nbsp;</td>
    </tr>
	<%
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);}//end of while loop.
}//end of for loop to print all debit.%>

    <tr>
      <td height="10" colspan="4" style="font-size:11px;"><hr size="1"></td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:13px; font-weight:bold"><u>EXPLANATION</u></td>
    </tr>
<%
for(int i =0; i < vGroupInfo.size(); i += 4){%>
    <tr>
      <td style="font-size:11px;" valign="top"><%=vGroupInfo.elementAt(i)%>.</td>
      <td height="25" colspan="3" valign="top"><%=WI.getStrValue(vGroupInfo.elementAt(i + 1))%></td>
    </tr>
<%}%>
  </table>
<%}//if(vJVDetail != null && vJVDetail.size() > 0) {%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><div align="left"></div></td>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
