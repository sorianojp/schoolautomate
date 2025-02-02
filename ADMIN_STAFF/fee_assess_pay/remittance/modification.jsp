<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function EditRecord()
{
	document.remittance.page_action.value = "1";
}
function DeleteRecord()
{
	document.remittance.page_action.value = "0";
}
function ReloadPage()
{
	document.remittance.reloadPage.value="1";
	this.SubmitOnce("remittance");
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FARemittance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REMITTANCE-Modifications","modification.jsp");
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
														"Fee Assessment & Payments","REMITTANCE",request.getRemoteAddr(),
														"modification.jsp");
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


FARemittance faRemit = new FARemittance(dbOP);
Vector vRetResult = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) //edit or delete.
{
	if(!faRemit.modifyPayment(dbOP,request,Integer.parseInt(strTemp)))
		strErrMsg = faRemit.getErrMsg();
	else
		strErrMsg = "Operation successful.";

}
if(strErrMsg == null)
{
	vRetResult = faRemit.getPaymentDetail(dbOP, request.getParameter("or_number"),(String)request.getSession(false).getAttribute("login_log_index"));
	if(vRetResult == null)
		strErrMsg = faRemit.getErrMsg();
}
dbOP.cleanUP();
%>
<form name="remittance" action="./modification.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          MODIFICATION OF PAYMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong>
      </td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td height="25">O.R. Number </td>
      <td width="81%" height="25"><input name="or_number" type="text" size="16" value="<%=WI.fillTextValue("or_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="25" colspan="9"><div align="center">PAYMENT
          DETAILS </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="24%">Amount Paid: <strong><%=(String)vRetResult.elementAt(1)%> &nbsp;&nbsp;&nbsp;</strong></td>
      <td width="38%">Remittance type: <strong><%=(String)vRetResult.elementAt(9)%></strong></td>
      <td>Date of Remittance :<strong><%=(String)vRetResult.elementAt(4)%></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2">Account Name : <strong><%=(String)vRetResult.elementAt(0)%> 
        &nbsp;&nbsp;</strong></td>
      <td width="35%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date Remittance : </td>
      <td colspan="2"><strong> 
        <input name="create_date" type="text" size="16" value="<%=(String)vRetResult.elementAt(4)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('remittance.create_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Correct Amount :<strong> </strong></td>
      <td colspan="2"><strong> 
        <input name="amount" type="text" size="16" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Reason : </td>
      <td colspan="2"><input type="text" name="reason" value="<%=WI.fillTextValue("reason")%>" maxlength="256" size="60" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><strong> </strong></td>
      <td colspan="2"><input type="image" src="../../../images/save.gif" onClick="EditRecord();"> 
        <font size="1">Click to correct the amount</font> (OR) 
        <%if(iAccessLevel ==2){%> <input type="image" src="../../../images/delete.gif" onClick="DeleteRecord();"> 
        <font size="1">Delete to remove the payment</font> <%}else{%>
        Not authorized to delete 
        <%}%> </td>
    </tr>
    <%}// if iAccessLevel > 1%>
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
<input type="hidden" name="page_action">
<input type="hidden" name="reloadPage">
</form>
</body>
</html>
