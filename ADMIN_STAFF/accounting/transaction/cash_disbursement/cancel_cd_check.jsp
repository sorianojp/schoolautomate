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
function ConfirmDel(strInfoIndex) {
	if(confirm("Do you want to delete."))
		return this.PageAction('0',strInfoIndex);
}
function CheckVoucher() {
	if(document.form_.old_cd_number.value != document.form_.cd_index.value) {
		alert("Please click Cancel again after page reloads. To avoid this error, after enter a new CD Number, Pls click proceed always.");
		return;
	}
	if(!document.form_.info_index) {
		document.form_.page_action.value = "2";
		return;
	}
	var objChkBox = document.form_.cancel_type[0];
	if(!objChkBox)
		objChkBox = document.form_.cancel_type;

	if(objChkBox.checked)
		document.form_.page_action.value = "0";
	else
		document.form_.page_action.value = "1";
}
function CheckCancelClicked(objChkBox) {
	if(objChkBox.checked) {
		document.form_.cancel_type[0].checked = false;
		document.form_.cancel_type[1].checked = true;
	}
}
function  CheckCancelClicked2() {
	var objChkBox = document.form_.cancel_type[0];
	if(!objChkBox)
		objChkBox = document.form_.cancel_type;
	if(objChkBox.checked && document.form_.max_disp) {
		var iMaxCheck = document.form_.max_disp.value;
		var obj;
		for(var i = 0; i < eval(iMaxCheck); ++i) {
			eval('obj=document.form_._'+i);
			if(!obj)
				continue;
			if(obj.checked) {//if any check is clicked, i must keep the select of cancel type to "cancel check";
				document.form_.cancel_type[1].checked = true;
				break;
			}
		}
	}
}
//call this to undelete check or complete voucher..
function UnDeleteCD(strPageAction, strInfoIndex) {
	document.form_.page_action_undelete.value = strPageAction;
	document.form_.i_index.value = strInfoIndex;
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="document.form_.cd_index.focus();">
<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
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

if(WI.fillTextValue("page_action").length() > 0) {
	if(jvCD.operateOnCancellCDOrCheck(dbOP, request, Integer.parseInt(WI.fillTextValue("page_action"))) == null)
		strErrMsg = jvCD.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}
double dTotalCheckMade = 0d;
double dTotalBal       = 0d;
if(strJVNumber.length() > 0) {
	vRetResult = jvCD.operateOnCDCheck(dbOP, request, 4);

	if(vRetResult != null) {
		dTotalBal       = Double.parseDouble((String)vRetResult.remove(0));
		dTotalCheckMade = Double.parseDouble((String)vRetResult.remove(0));
	}

	vJVDetail = jvCD.viewDetailJV(dbOP, strJVNumber);
	if(vJVDetail == null) {
		if(strErrMsg == null)
			strErrMsg = jvCD.getErrMsg();
	}
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

boolean bolIsChkCleared = false;


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolAllowCancelEvenIfLocked = false;
if(strSchCode.startsWith("CGH"))
	bolAllowCancelEvenIfLocked = true;

//boolean bolReloadPage = false;//if true, I must reload Page.
%>
<form action="./cancel_cd_check.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          DISBURSEMENT : CANCEL CD/CV AND/OR CHECK PAGE ::::</strong></font></div></td>
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
      <td width="4%" height="25">&nbsp;</td>
      <td width="14%" style="font-size:11px">Voucher No.</td>
      <td width="19%"> <input name="cd_index" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("cd_index")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="9%"><a href="../journal_voucher/jv_summary.jsp?is_cd=1" target="_blank"><img src="../../../../images/search.gif" border="0"></a></td>
      <td width="54%" valign="top"> <input type="submit" name="12" value=" Proceed >>" style="font-size:11px; height:22px;border: 1px solid #FF0000;">
<%
strTemp = WI.fillTextValue("page_action_undelete");
strErrMsg = null;//System.out.println("strTemp : "+strTemp);
if(strTemp.length() > 0) {
	if(jvCD.operateOnUndeleteCDCheck(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = jvCD.getErrMsg();
	else
		strErrMsg = "Undelete Successful.";
}
Vector vCancelledCDInfo = null;
if(strJVNumber != null)
	vCancelledCDInfo = jvCD.operateOnUndeleteCDCheck(dbOP, request, 4);
if(strErrMsg != null) {%>
	<font style="font-weight:bold; font-size:14px; color:#FF0000"><%=strErrMsg + "<br>"%></font>
<%}
boolean bolIsCDCancelled = false;
if(vCancelledCDInfo != null){//show the table..
	if(vCancelledCDInfo.elementAt(0).equals("1")) {
		bolIsCDCancelled = true;%>
	  <br>Voucher is Cancelled. <a href="javascript:UnDeleteCD('1','');">Click here</a> to un-delete the CD Information.
	<%}else{%>
	  <br>Voucher is Active. <%if(vCancelledCDInfo.size() > 2){%>List of Cancelled Checks shown below<%}%>
	<%}if(vCancelledCDInfo.size() > 2){%>
	<br>
	<table cellpadding="0" cellspacing="0" class="thinborder">
		<tr bgcolor="#CCCCCC" style="font-weight:bold">
			<td class="thinborder">Check No</td>
			<td class="thinborder">Check Date</td>
			<td class="thinborder">Amount</td>
			<td class="thinborder">Bank Code</td>
			<%if(!bolIsCDCancelled){%><td class="thinborder">&nbsp;</td><%}%>
		</tr>
		<%while(vCancelledCDInfo.size() > 2){%>
		<tr>
			<td class="thinborder"><%=vCancelledCDInfo.remove(3)%></td>
			<td class="thinborder"><%=vCancelledCDInfo.remove(4)%></td>
			<td class="thinborder"><%=vCancelledCDInfo.remove(3)%></td>
			<td class="thinborder"><%=vCancelledCDInfo.remove(3)%></td>
			<%if(!bolIsCDCancelled){%><td class="thinborder"><a href="javascript:UnDeleteCD('2','<%=vCancelledCDInfo.remove(2)%>');">Un-Delete</a></td><%}else{vCancelledCDInfo.remove(2);}%>
		</tr>
		<%}%>
	</table>
<%}//show table only if there are cancelled checks%>
<input type="hidden" name="c_index" value="<%=vCancelledCDInfo.elementAt(1)%>">
<input type="hidden" name="i_index">
<input type="hidden" name="page_action_undelete">
<%//if successful I have to reload page..
if(strErrMsg != null && strErrMsg.startsWith("Undelete")){%>
	<script language="javascript">
	alert("Undelete is successful. Click ok to refresh the page. Please wait until system reloads.");
	document.form_.submit();
	</script>
<%}%>


<%}//if(vCancelledCDInfo != null){%>
	  </td>
    </tr>
<%if(vRetResult == null || vRetResult.size() == 0) {%>
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Check Number </td>
      <td colspan="3" style="font-size:11px;">
	  <input name="chk_no" type="text" size="60" style="font-size:11px;" value="<%=WI.fillTextValue("chk_no")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Cancellation Date</td>
      <td colspan="2" style="font-size:11px;">
<%
strTemp = WI.fillTextValue("cancel_date");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>	  <input name="cancel_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.cancel_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
      <td style="font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;" valign="top"><br>Reason To Cancel  </td>
      <td colspan="3" style="font-size:11px;">
	  	<textarea cols="50" rows="5" class="textbox" name="reason" onFocus="style.backgroundColor='#D3EBFF'"
			onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("reason")%></textarea>
	  </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="4" style="font-weight:bold; font-size:11px; color:#0000FF">CANCEL :
<%
strTemp = WI.fillTextValue("cancel_type");
if(strTemp.equals("1") || vRetResult == null || vRetResult.size() == 0 ) {
	strTemp = " checked";
	strErrMsg = "";
}
else {
	strTemp = "";
	strErrMsg = " checked";
}
%>
	  <input type="radio" name="cancel_type" value="1"<%=strTemp%> onClick="CheckCancelClicked2();"> Disbursement/Check Voucher &nbsp;
<%if(vRetResult != null && vRetResult.size()> 0) {%>
	  <input type="radio" name="cancel_type" value="0"<%=strErrMsg%> onClick="CheckCancelClicked2();"> Check
<%}%>	  </td>
    </tr>
    <tr>
      <td height="26" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%if(vJVDetail != null && vJVDetail.size() > 0 && vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="2" style="font-size:11px; font-weight:bold; color:#FF0000">
	  Total amount having check made : <%=CommonUtil.formatFloat(dTotalCheckMade, true)%>
	  &nbsp;&nbsp;&nbsp;Total Balance Amount : <%=CommonUtil.formatFloat(dTotalBal, true)%></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2" style="font-size:18px; color:#FF0000; font-weight:bold; color:#FF0000" align="right">
	  <%if(vJVInfo.elementAt(4) != null) {%>
	  	-- Voucher is Locked --
	  <%}%>	
	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#999999">
      <td height="26" style="font-size:11px; font-weight:bold; color:#0000FF" colspan="8" align="center" class="thinborder">::: LIST OF CHECK ISSUED	::: 	</td>
    </tr>
    <tr>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="15%">Account # </td>
      <td height="26" class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%">Bank Code </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="15%">Check # </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="20%">Payee Name </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%">Date</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="7%">Check Status </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="8%">Amount</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="8%">CANCEL</td>
    </tr>
<%String[] astrConvertCheckStat = {"O/S","Cleared","Stale","Cancelled"};
int iChkStat = 0; int j = 0;
for(int i = 0; i < vRetResult.size(); i += 12){
iChkStat = Integer.parseInt((String)vRetResult.elementAt(i + 7));
if(iChkStat == 1)
	bolIsChkCleared = true;
%>
    <tr>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
      <td height="26" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=astrConvertCheckStat[iChkStat]%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">&nbsp;
        <%if(iChkStat != 1) {%>
	        <input type="checkbox" name="_<%=j++%>" value="<%=vRetResult.elementAt(i)%>" onClick="CheckCancelClicked(document.form_._<%=(j-1)%>);">
        <%}%>
	  </td>
    </tr>
<%}%>
  </table>
<input type="hidden" name="max_disp" value="<%=j%>">
 <%}else {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td style="font-size:11px; font-weight:bold; color:#0000FF" align="center" class="thinborder">No Check Made.</td>
    </tr>
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
    <%
boolean bolPrintGroup = false;
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
      <td style="font-size:11px;" valign="top">
        <%if(bolPrintGroup){bolPrintGroup = false;%>
        <%=strTemp%>.
        <%}%>      </td>
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
      <td style="font-size:11px;" valign="top">
        <%if(bolPrintGroup){bolPrintGroup = false;%>
        <%=strTemp%>.
        <%}%>      </td>
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
      <td width="29%" height="10">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%if(vJVInfo == null || (vJVInfo.size() > 0 && (vJVInfo.elementAt(4) == null || bolAllowCancelEvenIfLocked) ))  {%>
    <tr>
      <td height="39">&nbsp;</td>
      <td width="71%" height="39">
	  	<input type="submit" value=" Save Cancel CD/Check Information" style="font-size:13px; color:#0055aa; font-weight:bold; height:28px; border: 1px solid #FF0000; background:#DDDDDD" onClick="CheckVoucher();"></td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="old_cd_number" value="<%=WI.fillTextValue("cd_index")%>">
<%if(vJVInfo != null && vJVInfo.size() > 0) {%>
	<input type="hidden" name="info_index">
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
