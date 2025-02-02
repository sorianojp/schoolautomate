<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function EditRecord()
{
	document.fa_payment.editRecord.value = "1";
}
function DeleteRecord()
{
	document.fa_payment.deleteRecord.value = "1";
}
function ReloadPage()
{
	document.fa_payment.editRecord.value="";
	document.fa_payment.deleteRecord.value="";
	document.fa_payment.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAElementaryPayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Modifications","basic_pmt_modification.jsp");
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
														"basic_pmt_modification.jsp");
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

enrollment.FAElementaryPayment faPaymentBASIC = new enrollment.FAElementaryPayment();
Vector vRetResult = null;
strTemp = WI.fillTextValue("editRecord");
if(strTemp.compareTo("1") ==0)
{
	if(!faPaymentBASIC.editDeltePaymentBasic(dbOP, request))
		strErrMsg = faPaymentBASIC.getErrMsg();
	else
		strErrMsg = "Payment changed successfully.";

}
strTemp = WI.fillTextValue("deleteRecord");
if(strTemp.compareTo("1") ==0)
{
	if(!faPaymentBASIC.editDeltePaymentBasic(dbOP, request))
		strErrMsg = faPaymentBASIC.getErrMsg();
	else
		strErrMsg = "Payment deleted successfully.";
}

if(strErrMsg == null && WI.fillTextValue("or_number").length() > 0)
{
	vRetResult = faPaymentBASIC.viewPmtDetail(dbOP, request.getParameter("or_number"));
	if(vRetResult == null)
		strErrMsg = faPaymentBASIC.getErrMsg();
}
//System.out.println(vRetResult);}
dbOP.cleanUP();
%>
<form name="fa_payment" action="./basic_pmt_modification.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          PAYMENT MODIFICATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="payment_modification_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
        Go to main page&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <% if(strErrMsg != null){%>
        <font size="3">Message: <strong><%=strErrMsg%></strong></font>
        <%
	  if(request.getParameter("editRecord") != null && request.getParameter("editRecord").trim().length() > 0)
	  	return; //it is not for the first time.
	}%>
      </td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="18%" height="25">Reference Number </td>
      <td width="78%" height="25"><input name="or_number" type="text" size="16" value="<%=WI.fillTextValue("or_number")%>" class="textbox_bigfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="4%" height="25">&nbsp;</td>
      <td width="44%" height="25">Student ID: <strong><%=WI.getStrValue(vRetResult.elementAt(4))%></strong></td>
      <td width="52%" height="25"  colspan="4">Student name :<strong> 
<%=WebInterface.formatName((String)vRetResult.elementAt(6), (String)vRetResult.elementAt(7), (String)vRetResult.elementAt(8), 4)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="25" colspan="9"><div align="center">PAYMENT
          DETAILS </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="22%">Amount Paid: <strong><%=(String)vRetResult.elementAt(9)%></strong></td>
      <td width="37%">&nbsp;</td>
      <td width="37%">Date Paid : <strong><%=(String)vRetResult.elementAt(11)%></strong></td>
    </tr>
    <%
strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("0") ==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Correct Amount</td>
      <td colspan="2"><strong> 
        <input name="amount" type="text" size="16" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong></td>
    </tr>
    <%}else if(strTemp.compareTo("1") ==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date of Payment</td>
      <td colspan="2"><input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </td>
    </tr>
<%}else if(strTemp.compareTo("4") ==0){//change school year information.%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>New SY Information</td>
      <td colspan="2">
<%
strTemp = WI.getStrValue((String)vRetResult.elementAt(2));
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fa_payment","sy_from","sy_to")'> 
        <%
strTemp = WI.getStrValue((String)vRetResult.elementAt(3));
%>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
      </td>
    </tr>
<%}

if(iAccessLevel > 1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><strong> </strong></td>
      <td colspan="2"> <%if(WI.fillTextValue("page_action").compareTo("3") != 0){%> <input type="image" src="../../../images/save.gif" onClick="EditRecord();"> 
        <font size="1">Click to correct the amount</font> <%}if(iAccessLevel ==2 && WI.fillTextValue("page_action").compareTo("3") ==0){%> <input type="image" src="../../../images/delete.gif" onClick="DeleteRecord();"> 
        <font size="1">Delete to remove the payment</font> <%}else{%>
        <%}%> </td>
    </tr>
    <%}%>
  </table>
 <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="17%" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="editRecord" value="0">

<input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">

</form>
</body>
</html>
