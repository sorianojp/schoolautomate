<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction() {
	document.form_.page_action.value = "1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.new_amt.focus()">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	WebInterface WI = new WebInterface(request);


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments","fee_adjustment_show_adjustment_manual.jsp");
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
														"fee_adjustment_show_adjustment_manual.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT-FEE ADJUSTMENT",request.getRemoteAddr(),
														"fee_adjustment.jsp");
}
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
FAPmtMaintenance pmtMaintenance = new FAPmtMaintenance();
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(pmtMaintenance.operateOnManualDiscountOverride(dbOP, request, 1) == null)
		strErrMsg = pmtMaintenance.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
vRetResult = pmtMaintenance.operateOnManualDiscountOverride(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = pmtMaintenance.getErrMsg();
%>

<form name="form_" action="./fee_adjustment_show_adjustment_manual.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: FEE ADJUSTMENTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><strong><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="1%" height="25">&nbsp;</td>
      <td width="12%" height="25">New Amount: </td>
      <td height="25"  colspan="4">
		<input name="new_amt" type="text" size="12" value="<%=WI.fillTextValue("new_amt")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
	  </td>
      <td width="24%"><strong><u>System Computed Amount</u></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="4">
	  <a href="javascript:PageAction();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
        <font size="1">click to save entries</font>
	  </td>
      <td valign="top"><strong><%=WI.fillTextValue("orig_amt")%></strong></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="4"><div align="center"><strong>OVERRIDE HISTORY</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td height="25" width="20%" class="thinborder">New Amount </td>
      <td width="30%" class="thinborder">Old Amount </td>
      <td width="15%" class="thinborder">Created By </td>
      <td width="13%" class="thinborder">Date Created </td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 5) {%>
    <tr>
      <td height="22" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%><br><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
    </tr>
<%}%>
  </table>
<%}//if student info is not null%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="adj_ref" value="<%=WI.fillTextValue("adj_ref")%>">  
<input type="hidden" name="orig_amt" value="<%=WI.fillTextValue("orig_amt")%>">  
<input type="hidden" name="page_action">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
