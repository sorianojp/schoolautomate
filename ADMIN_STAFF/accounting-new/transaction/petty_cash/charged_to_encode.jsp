<%@ page language="java" import="utility.*, Accounting.Transaction, java.util.Vector"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
///////////////to reload parent window if this is closed //////////////
function CloseWindow(){
	document.form_.close_wnd_called.value = "1";

	window.opener.document.form_.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.form_.submit();
		window.opener.focus();
	}
}

function PageAction(strAction,strCOAIndex){
	document.form_.donot_call_close_wnd.value = 1;
	document.form_.page_action.value = strAction;
	if (strAction == 0){
		document.form_.prepareToEdit.value = "";
	}
	if(strCOAIndex.length > 0)
		document.form_.coa_index.value = strCOAIndex;
}
function PrepareToEdit(strCOAIndex) {
	document.form_.donot_call_close_wnd.value = 1;
	document.form_.coa_index.value = strCOAIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
//	this.SubmitOnce('form_');
}
function ConfirmDel(strCOAIndex,strDel) {
	document.form_.donot_call_close_wnd.value = 1;
	if(confirm("Do you want to delete " + strDel + "?"))
		return this.PageAction('0',strCOAIndex);
}
</script>

<body bgcolor="#D2AE72"  onUnload="ReloadParentWnd();">
<%
	WebInterface WI = new WebInterface(request);
	String strTemp  = null;
//add security here.
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
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
DBOperation dbOP = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-ACCOUNTING-TRANSACTION-Requisition Info","charged_to_encode.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authentication code.

	Transaction Transaction = new Transaction();
	String strPageAction = WI.fillTextValue("page_action");
	String[] astrCategory = {"Personal (School Personnel)","Personal (Non-School Personnel)","Company"};
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strErrMsg  = "";
	Vector vRetResult = null;
	Vector vEditInfo = null;

	if(strPageAction.length() > 0){
		if(Transaction.operateOnChargeTo(dbOP,request,Integer.parseInt(strPageAction)) == null){
			strErrMsg = Transaction.getErrMsg();
		}
	}
	if (strPrepareToEdit.equals("1")){
	  vEditInfo = Transaction.operateOnChargeTo(dbOP,request,3);
	}

	vRetResult = Transaction.operateOnChargeTo(dbOP,request,4);

%>
<form action="./charged_to_encode.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          PETTY CASH/DISBURSEMENT : ENCODING OF CHARGED TO PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1"><a href="javascript:CloseWindow();"><img src="../../../../images/close_window.gif" border="0"></a></font>click
        to close window and have the changes reflected in the Charged to table</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="27" colspan="3"  style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td height="27">&nbsp;</td>
      <td>Charged to</td>
	  <% if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String) vEditInfo.elementAt(1);
		else
	  		strTemp = WI.fillTextValue("charged_to");
	  %>
      <td><input name="charged_to" type="text" class="textbox"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="16" maxlength="16">
        (encode specific account number if data is available)</td>
    </tr>
	<!--
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td width="13%" height="25">Account Group</td>
      <td width="81%" height="25"><font size="1">
        <select name="select2">
          <option>General Fund</option>
          <option>Restricted Fund</option>
          <option>Endowment/Trust Fund</option>
        </select>
        <select name="select">
        </select>
        <select name="select3">
        </select>
        (NOTE: Show sub-list if available for that account)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Account No.</strong></td>
      <td height="25"><strong>$account_num :: $account_Description</strong></td>
    </tr>
	-->
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Amount</td>
	  <% if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String) vEditInfo.elementAt(3);
		else
	  		strTemp = WI.fillTextValue("amount");
	  %>
      <td height="25"><strong><font size="1">
        <input name="amount" type="text" size="16" maxlength="16" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=CommonUtil.formatFloat(WI.getStrValue(strTemp,"0"),true)%>"
	  onKeyUp="AllowOnlyFloat('form_','amount');"
	  onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'">
        </font></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><font size="1">
        <%if(!strPrepareToEdit.equals("1")) {%>
        <font size="1" > <font size="1" >
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
        </font>click to save entries</font>
        <%}else{%>
        <input type="submit" name="122" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
        <font size="1">click to save changes</font>
        <%}%>
        <a href="javascript:ProceedClicked();">
        <input type="submit" name="123" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.charged_to.value='';document.form_.amount.value=''">
        </a> <font size="1">click to cancel edit</font></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%if(vRetResult!= null && vRetResult.size() > 0){
  %>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF"><strong>::
          LIST OF CHARGED TO FOR THIS VOUCHER :: </strong></font></div></td>
    </tr>
    <tr>
      <td width="41%" height="25"><div align="center"><strong><font size="1">CHARGED
          TO </font></strong></div></td>
      <td width="41%"><div align="center"><strong><font size="1">AMOUNT</font></strong></div></td>
      <td width="15%"><font size="1">&nbsp;</font></td>
    </tr>
	<%for(int i = 0; i < vRetResult.size() ; i +=4){%>
    <tr>
      <td height="25"><strong><%=(String)vRetResult.elementAt(i+1)%> :: <%=(String)vRetResult.elementAt(i+2)%></strong></td>
      <td><strong>&nbsp;<%=(String)vRetResult.elementAt(i+3)%></strong></td>
      <td><div align="center"><font size="1">
          <input type="submit" name="1222" value="Edit" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PrepareToEdit('<%=vRetResult.elementAt(i)%>');">
          <input type="submit" name="1232" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="ConfirmDel('<%=vRetResult.elementAt(i)%>','<%=vRetResult.elementAt(i + 1)%>');">
          </font></div></td>
    </tr>
	<%}%>
  </table>
  <%} // end if vRetResult != null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <!--
	<tr>
      <td width="19%" height="25"><div align="left"></div></td>
      <td width="81%" height="25"><font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../../images/save.gif" border="0"></a>click
        to save setting</font></td>
    </tr>
	-->
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
	<!-- this is very important - onUnload do not call close window -->
  <input type="hidden" name="pc_index" value="<%=WI.fillTextValue("pc_index")%>">
  <input type="hidden" name="coa_index" value="<%=WI.fillTextValue("coa_index")%>">
  <input type="hidden" name="total_amount" value="<%=WI.fillTextValue("total_amount")%>">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
