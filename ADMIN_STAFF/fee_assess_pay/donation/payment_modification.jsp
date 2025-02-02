<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function EditRecord()
{
	document.form_.editRecord.value = "1";
}
function ReloadPage()
{
	document.form_.editRecord.value="";
	document.form_.submit();
}
function ReloadParentWnd() {
//	window.opener.document.form_.submit();
}
</script>

<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<%@ page language="java" import="utility.*,enrollment.FADonation,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;


//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-DONATION-Modifications","payment_modification.jsp");
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
														"Fee Assessment & Payments","DONATION",request.getRemoteAddr(),
														"payment_modification.jsp");
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
FADonation faDonation = new FADonation();
Vector vRetResult = null;
strTemp = WI.getStrValue(WI.fillTextValue("editRecord"),"0");
vRetResult = faDonation.modifyPayment(dbOP, request, Integer.parseInt(strTemp));
if(vRetResult == null)
	strErrMsg = faDonation.getErrMsg();
else if(strTemp.compareTo("1") == 0)
	strErrMsg = "Payment information changed successfully.";
	
//System.out.println(vRetResult);}
dbOP.cleanUP();
%>
<form name="form_" action="./payment_modification.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          PAYMENT MODIFICATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <font size="3">Message: <strong><%=WI.getStrValue(strErrMsg)%></strong></font>
      </td>
    </tr>
	</table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="22%">Amount : <strong>
	  <%
	  if(vRetResult.elementAt(1) == null){%>
	  <%=CommonUtil.formatFloat((String)vRetResult.elementAt(2),true)%>
	  <%}else{%>
	  <%=CommonUtil.formatFloat((String)vRetResult.elementAt(1),true)%>
	  <%}%>
	  </strong></td>
      <td width="44%">TYPE : <strong>
	  <%
	  if(vRetResult.elementAt(1) == null){%>CREDIT<%}else{%>DEBIT<%}%></strong></td>
      <td width="30%">Transaction Date: <strong>
	  <%
	  if(vRetResult.elementAt(6) == null){%>
	  <%=(String)vRetResult.elementAt(7)%>
	  <%}else{%>
	  <%=(String)vRetResult.elementAt(6)%>
	  <input type="hidden" name="posted" value="1">
	  <%}%>
	  </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Correct Amount</td>
      <td colspan="2"><strong> 
        <input name="amount" type="text" size="16" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Transaction Date</td>
      <td colspan="2"><input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_of_payment');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <%
if(iAccessLevel > 1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><strong> </strong></td>
      <td colspan="2"> <input type="image" src="../../../images/save.gif" onClick="EditRecord();"> 
        <font size="1">Click to correct the amount/date</font> </td>
    </tr>
  </table>
 <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<%}%>
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

</form>
</body>
</html>
