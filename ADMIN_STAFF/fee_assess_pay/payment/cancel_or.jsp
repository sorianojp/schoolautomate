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
	location = "./cancel_or.jsp";
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
FAPayment faPayment = new FAPayment();
Vector vRetResult = new Vector();Vector vEditInfo = null;
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(faPayment.operateOnCancelOR(dbOP, request, Integer.parseInt(strTemp)) != null ) {
		strErrMsg = "Operation Successful.";
		strPrepareToEdit = "0";
	}
	else	
		strErrMsg = faPayment.getErrMsg();
		
}
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = faPayment.operateOnCancelOR(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = faPayment.getErrMsg();
}
vRetResult = faPayment.operateOnCancelOR(dbOP, request, 4);


//end of authenticaion code.
%>
<form name="form_" action="./cancel_or.jsp" method="post">  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#A49A6A"> 
    <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CANCEL O.R. PAGE ::::</strong></font></div></td>
  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><b><font size="3"><%=WI.getStrValue(strErrMsg)%></font></b></td>
    </tr>
    <tr > 
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%">SY/Term</td>
      <td width="33%"> <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
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
      <td width="50%"><a href="javascript:ReloadPage();"><img name="hide_save" src="../../../images/form_proceed.gif" border="0"></a></td>
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
        Show All OR cancelled until today.</td>
    </tr>
    <tr > 
      <td height="25" colspan="4"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="0%" height="26">&nbsp;</td>
      <td width="15%">OR. NO.</td>
      <td width="36%"> <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("or_number");
%> <input name="or_number" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="17%">Transaction Date</td>
      <td width="32%"> <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(6);
else
	strTemp = WI.fillTextValue("transaction_date");
if(strTemp.length() ==0)
	strTemp = WI.getTodaysDate(1);
%> <input name="transaction_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.transaction_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>OR Amount</td>
      <td> <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(7);
else
	strTemp = WI.fillTextValue("amount");
%> <input name="amount" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Reference No.</td>
      <td> <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("ref_number");
%> <input name="ref_number" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td>OR Printed By<br>
        (Emp ID)</td>
      <td> <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(8);
else
	strTemp = WI.fillTextValue("emp_id");
%> <input name="emp_id" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top"><br>
        Payment for </td>
      <td valign="top"> <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(10);
else
	strTemp = WI.fillTextValue("payment_for");
%> <textarea name="payment_for" cols="25" rows="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=strTemp%></textarea> 
      </td>
      <td valign="top"><br>
        Reason for Cancellation</td>
      <td valign="top"> <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(11);
else
	strTemp = WI.fillTextValue("reason");
%> <textarea name="reason" cols="25" rows="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td height="30"><div align="center"></div></td>
      <td>&nbsp;</td>
      <td colspan="3"> <%
if(iAccessLevel >1 && strPrepareToEdit.compareTo("0") == 0){%> <a href='javascript:PageAction("","1");'><img name="hide_save" src="../../../images/save.gif" border="0"></a> 
        <font size="1">click to save entries </font> <%}else if(iAccessLevel > 1){%> <a href='javascript:PageAction("","2");'><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">Click to Edit</font> <%}%> <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to clear/cancel entries</font> <div align="right"> 
        </div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="10" ><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list</font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="10" bgcolor="#B9B292"><div align="center">LIST 
          OF CANCELLED OR</div></td>
    </tr>
    <tr> 
      <td width="10%" height="25"><div align="center"><font size="1"><strong>OR. 
          NO.</strong></font></div></td>
      <td width="14%"><div align="center"><font size="1"><strong>SY (TERM)</strong></font></div></td>
      <td width="14%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
      <td width="14%"><div align="center"><font size="1"><strong>REFERENCE NO.</strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>OR PRINTED BY</strong></font></div></td>
      <td width="13%"><div align="center"><font size="1"><strong>TRANSACTION DATE</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>PAYMENT FOR </strong></font></div></td>
      <td width="18%"><div align="center"><font size="1"><strong>REASON FOR CANCELLATION</strong></font></div></td>
      <td width="4%"><div align="center"><font size="1"><strong>EDIT </strong> 
          </font> </div></td>
      <td width="6%"><div align="center"><font size="1"><strong>DELETE</strong></font></div></td>
    </tr>
    <%
 for(int i = 0; i < vRetResult.size(); i += 12) {%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td><%=(String)vRetResult.elementAt(i + 1)%>-<%=(String)vRetResult.elementAt(i + 2)%>
	  	(<%=(String)vRetResult.elementAt(i + 3)%>)</td>
      <td><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td><%=(String)vRetResult.elementAt(i + 10)%></td>
      <td><%=(String)vRetResult.elementAt(i + 11)%></td>
      <td>
<%
if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a><%}%></td>
      <td>
<%if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a><%}%></td>
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