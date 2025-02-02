<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CANCEL OR</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex,strAction) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction == 1)
		document.form_.hide_save.src = "../../../images/blank.gif";
	
	document.form_.print_pg.value = "";
	document.form_.submit();

}
function Cancel() {
	location = "./cancel_or_new.jsp?sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester.value;
}
function PrepareToEdit(strInfoIndex) {
	document.form_.prepareToEdit.value = "1";
	document.form_.page_action.value = "";
	document.form_.info_index.value = strInfoIndex;
	
	document.form_.print_pg.value = "";
	document.form_.submit();
}
function ReloadPage() {
	document.form_.print_pg.value = "";
	document.form_.submit();
}
function PrintPg() {
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.DBOperation,utility.CommonUtil,utility.WebInterface,enrollment.FAPayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);
	
	if(WI.fillTextValue("print_pg").compareTo("1") == 0){%>
		<jsp:forward page="./cancel_or_print.jsp" />
	<%return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Cancel OR","cancel_or.jsp");
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
														"cancel_or.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

FAPayment faPayment = new FAPayment();
Vector vRetResult = new Vector();Vector vEditInfo = null;
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

strTemp = WI.fillTextValue("page_action");
boolean bolCITCancelBookPayment = false;
if(strTemp.length() > 0) {
	if(faPayment.operateOnCancelORNew(dbOP, request, Integer.parseInt(strTemp)) != null ) {
		strErrMsg = "Operation Successful.";
		strPrepareToEdit = "0";
		if(WI.fillTextValue("del_debit_entry").length() > 0) {
			strTemp = "update fa_stud_payable set is_valid = 0, payee_addr ='deleted due to cancel OR : "+WI.fillTextValue("or_number2") +"' where payable_index in ("+
					WI.fillTextValue("del_debit_entry")+")";
			dbOP.executeUpdateWithTrans(strTemp, null, null, false);
		}
		//added for CIT.
		if(strTemp.equals("1") && strSchCode.startsWith("CIT"))
			bolCITCancelBookPayment = true;
	}
	else	
		strErrMsg = faPayment.getErrMsg();
		
}
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = faPayment.operateOnCancelORNew(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = faPayment.getErrMsg();
}
vRetResult = faPayment.operateOnCancelORNew(dbOP, request, 4);

Vector vORInfo = null;

boolean bolAllowDPCancel = false;//I have to allow D/P (even if one only.).
bolAllowDPCancel = true;//added 2011-11-09 // too many requests to cancel d/p.. 

if(WI.fillTextValue("or_number2").length() > 0 ){
	vORInfo = faPayment.viewPmtDetail(dbOP, WI.fillTextValue("or_number2"));
	if(vORInfo == null && strErrMsg == null)
		strErrMsg = faPayment.getErrMsg();
	else if(vORInfo != null && vORInfo.size() > 0 && vORInfo.elementAt(27).equals("0")) {//check if there are two d/p.. 
		String strSQLQuery = "select count(*) from fa_stud_payment where pmt_sch_index = 0 and is_valid = 1 and user_index = "+(String)vORInfo.elementAt(0)+
							" and is_stud_temp = "+(String)vORInfo.elementAt(29)+" and sy_from = "+(String)vORInfo.elementAt(23)+" and semester = "+(String)vORInfo.elementAt(22);
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null && Integer.parseInt(strSQLQuery) > 1)
			bolAllowDPCancel = true;
	}
}
if(bolCITCancelBookPayment && WI.fillTextValue("payment_table").toUpperCase().equals("FA_STUD_PAYMENT")   ) {
			//invalidate if there is any bs book payment.
	strTemp = "select user_index from fa_stud_payment where payment_index = "+WI.fillTextValue("payment_index");
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null) {
		strTemp = "update bs_book_payment set is_valid = 0, is_del = 1, last_mod_by = 5, last_mod_date = '"+WI.getTodaysDate()+"' where fa_payment_index = "+
					WI.fillTextValue("payment_index")+" and user_index = "+strTemp;
		dbOP.executeUpdateWithTrans(strTemp, null, null, false);
	}
}



boolean bolShowDelete = false;
if(strSchCode.startsWith("VMA") || strSchCode.startsWith("EAC") || 
strSchCode.startsWith("PWC") || strSchCode.startsWith("CDD") || strSchCode.startsWith("CSA"))
	bolShowDelete = true;
%>
<form name="form_" action="./cancel_or_new.jsp" method="post">  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#A49A6A"> 
    <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CANCEL O.R. PAGE ::::</strong></font></div></td>
  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(strSchCode.startsWith("UC")){%>
	<input type="hidden" name="keep_info" value="1">
    <tr > 
      <td height="25" colspan="4"><b><font size="3"><%=WI.getStrValue(strErrMsg,"","<br>","")%></font></b></td>
	</tr> 
<%}else{%>
    <tr > 
      <td height="25" colspan="4"><b><font size="3"><%=WI.getStrValue(strErrMsg,"","<br>","")%></font></b> 
	  <font size="2" color="#0000FF"><b> 
        <%if(strPrepareToEdit.compareTo("0") == 0){
		strTemp = WI.fillTextValue("keep_info");
		if(strTemp.equals("1"))
			strTemp = " checked";
		else	
			strTemp = "";
		%>        
		<input type="checkbox" name="keep_info" value="1"<%=strTemp%>>
        Keep OR information in Payment table (Amount in Payment table will be set to 0). 
        Deleting the Cancelled OR will put back the amount in Payment table.
        <%}%>
        </b></font></td>
    </tr>
<%}%>
    <tr > 
      <td height="25">&nbsp;</td>
      <td><strong>OR # to Cancel</strong></td>
      <td width="32%"><input name="or_number2" type="text" size="16" value="<%=WI.fillTextValue("or_number2")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="50%"><a href="javascript:ReloadPage();"><img name="hide_save" src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr > 
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%">SY/Term</td>
      <td colspan="2"> <%
if(vORInfo != null)
	strTemp = (String)vORInfo.elementAt(23);
else
	strTemp = WI.fillTextValue("sy_from");
if(WI.getStrValue(strTemp).length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
if(vORInfo != null)
	strTemp = (String)vORInfo.elementAt(24);
else
	strTemp = WI.fillTextValue("sy_to");
if(WI.getStrValue(strTemp).length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
if(vORInfo != null)
	strTemp = (String)vORInfo.elementAt(22);
else
	strTemp = WI.fillTextValue("semester");
if(WI.getStrValue(strTemp).length() ==0)
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
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"> <%
strTemp = WI.fillTextValue("show_all");
if(strTemp.length() > 0)
	strTemp = "checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_all" value="1" <%=strTemp%>>
  Show All OR cancelled until today.&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td style="font-size:11px; color:#0000FF; font-weight:bold">Display Filter </td>
      <td colspan="2" style="font-size:10px">Date Cancelled: 
<%
if(request.getParameter("cancel_date_fr") == null)
	strTemp = WI.getTodaysDate(1);
else	
	strTemp = WI.fillTextValue("cancel_date_fr");
%>
<input name="cancel_date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.cancel_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        to
        <input name="cancel_date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("cancel_date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.cancel_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  </td>
    </tr>
    <tr > 
      <td colspan="4"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>

<%if(vORInfo != null){
strTemp = faPayment.getOthSchDebitRef(dbOP, WI.fillTextValue("or_number2"));
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Payee</td>
      <td colspan="2"><b>
	  <%if(vORInfo.elementAt(25) != null){%><%=(String)vORInfo.elementAt(18) + " ("+(String)vORInfo.elementAt(25)+")"%><%}else{%>
	  <%=(String)vORInfo.elementAt(1)%><%}%></b></td>
      <td style="font-weight:bold; color:#0000FF; font-size:11px;">
	  <%if(strTemp != null) {%>
	  	<input type="checkbox" name="del_debit_entry" value="<%=strTemp%>" checked="checked" onclick="return false" onkeydown="return false">
		
		Delete corresponding Debit Entry. (Uncheck to keep Debit Entry)
	   <%}%>
	  
	  </td>
    </tr>
    <tr> 
      <td width="0%" height="22">&nbsp;</td>
      <td width="15%">OR # in System (REF #)</td>
      <td width="36%"> <input name="or_number" type="text" size="22" value="<%=WI.fillTextValue("or_number2")%>" class="textbox_noborder"
	   readonly="yes"></td>
      <td width="17%">Transaction Date</td>
      <td width="32%"> <input name="transaction_date" type="text" size="14" maxlength="12" readonly="yes" 
	value="<%=(String)vORInfo.elementAt(15)%>" class="textbox_noborder"> </td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>OR Amount</td>
      <td> <input name="amount" type="text" size="12" value="<%=(String)vORInfo.elementAt(11)%>" class="textbox_noborder"
	   readonly="yes"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>OR # on Receipt</td>
      <td> <%
if(WI.fillTextValue("ref_number").length() > 0)
	strTemp = WI.fillTextValue("ref_number");
else
	strTemp = WI.fillTextValue("or_number2");
%> <input name="ref_number" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>OR Printed By<br>
        (Emp ID)</td>
      <td> <input name="emp_id" type="text" size="16" value="<%=(String)vORInfo.elementAt(38)%>" class="textbox_noborder" readonly="yes"> 
        <br> <b><%=(String)vORInfo.elementAt(39)%></b></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td valign="top"><br>
        Payment for </td>
      <td valign="top"> <%
strTemp = (String)vORInfo.elementAt(27);
if(strTemp.equals("0"))
	strTemp = "Downpayment";
else if(!strTemp.equals("-1"))
	strTemp = "Tuition";
else 
	strTemp = "Others";
%> <textarea name="payment_for" cols="25" rows="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>      </td>
      <td valign="top"><br>
        Reason for Cancellation</td>
      <td valign="top"> <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(11);
else
	strTemp = WI.fillTextValue("reason");
%> <textarea name="reason" cols="25" rows="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea> 
        <!-- fee here all hidden fields. -->
        <input type="hidden" name="payment_index" value="<%=(String)vORInfo.elementAt(30)%>"> 
        <input type="hidden" name="payment_index_name" value="<%=(String)vORInfo.elementAt(40)%>"> 
        <input type="hidden" name="payment_table" value="<%=(String)vORInfo.elementAt(41)%>">      </td>
    </tr>
    <tr> 
      <td height="30"><div align="center"></div></td>
      <td>&nbsp;</td>
      <td colspan="3" style="font-size:9px;"> <%//cancel is not allowed if it is downpayment.
	  if(!vORInfo.elementAt(27).equals("0") || bolAllowDPCancel){
			if(iAccessLevel >1 && strPrepareToEdit.compareTo("0") == 0){%> <a href='javascript:PageAction("","1");'><img name="hide_save" src="../../../images/save.gif" border="0"></a> click to save entries
			<%}else if(iAccessLevel > 1){%> 
				<a href='javascript:PageAction("","2");'><img src="../../../images/edit.gif" border="0"></a> Click to Edit 
			<%}%> 
			<a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> click to clear/cancel entries
	  <%}else{//do not allow%> <font size="3" color="#0000FF"><b>Can't remove/cancel downpayment information.</b></font> <%}%></td>
    </tr>
  </table>
<%}//do not show if vORInfo is null.

if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="13" ><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list</font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="13" bgcolor="#B9B292"><div align="center">LIST 
          OF CANCELLED OR</div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr align="center"> 
      <td width="10%" height="25"><div align="center"><font size="1"><strong>OR. NO.</strong></font></div></td>
      <td width="10%"><font size="1"><strong>Student ID</strong></font></td>
      <td width="14%"><font size="1"><strong>Student Name</strong></font></td>
      <td width="14%"><div align="center"><font size="1"><strong>SY (TERM)</strong></font></div></td>
      <td width="14%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
      <td width="14%"><div align="center"><font size="1"><strong>REFERENCE NO.</strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>OR PRINTED BY</strong></font></div></td>
      <td width="13%"><div align="center"><font size="1"><strong>TRANSACTION DATE</strong></font></div></td>
      <td width="13%" align="center" style="font-weight:bold; font-size:9px">DATE CANCELLED </td>
      <td width="15%"><div align="center"><font size="1"><strong>PAYMENT FOR </strong></font></div></td>
      <td width="18%"><div align="center"><font size="1"><strong>REASON FOR CANCELLATION</strong></font></div></td>
      <td width="18%"><font size="1"><strong>CANCELLED BY</strong></font></td>
      <%if(false){%><td width="4%"><div align="center"><font size="1"><strong>EDIT </strong> </font> </div></td><%}%>
      <%if(bolShowDelete){%><td width="6%"><div align="center"><font size="1"><strong>DELETE</strong></font></div></td><%}%>
    </tr>
    <%
 for(int i = 0; i < vRetResult.size(); i += 19) {%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i + 13),"&nbsp;")%></td>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i + 14),"&nbsp;")%></td>
      <td>
	  <%if( vRetResult.elementAt(i + 1) == null) {%>
	  N/A <%}else{%>
	  <%=(String)vRetResult.elementAt(i + 1)%>-<%=(String)vRetResult.elementAt(i + 2)%>
	  	(<%=(String)vRetResult.elementAt(i + 3)%>)
	  <%}%>
	  </td>
      <td><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td><%=(String)vRetResult.elementAt(i + 12)%></td>
      <td><%=(String)vRetResult.elementAt(i + 10)%></td>
      <td><%=(String)vRetResult.elementAt(i + 11)%></td>
      <td><%=(String)vRetResult.elementAt(i + 15)%></td>
      <%if(false){//no edit option.%>
	  	<td><%if(iAccessLevel > 1){%><a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a><%}%></td>
	  <%}if(bolShowDelete){%>
	  	<td><%if(iAccessLevel == 2){%><a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a><%}%></td>
	  <%}%>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="44" width="19%">&nbsp;</td>
      <td><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
        <font size="1">click to print list</font></font></td>
    </tr>
  </table>
 <%}%>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="31%" valign="middle">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="print_pg">
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>