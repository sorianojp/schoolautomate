<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function ShowResult() {
	document.form_.show_result.value = "1";
	this.SubmitOnce('form_');	
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Program fix-Fix class program",
								"move_multiple_payments.jsp");

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
														"System Administration","Application Fix",request.getRemoteAddr(),
														"move_multiple_payments.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

enrollment.FAExternalPay progFix = new enrollment.FAExternalPay(request);
Vector vRetResult = null;

if(WI.fillTextValue("show_result").length() > 0) {
	vRetResult = progFix.updateOldMultiplePayments(dbOP);
	if(vRetResult == null) 
		strErrMsg = progFix.getErrMsg();
	else
		strErrMsg  = " Number of Inserted Items : " + ((String)vRetResult.remove(0)) + 
		"<br> Edited OR Numbers : " + vRetResult  ;
}		

%>


<form name="form_" action="./move_multiple_payments.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          MOVE RECORDS OF MULTIPLE PAYMENTS ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="4%">&nbsp;</td>
      <td><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%" height="25"><a href="javascript:ShowResult();"><img src="../../../images/update.gif" width="60" height="26" border="0">  </a>click move records of multiple payments to payable (Applicable only for External Payment) </td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td height="27">&nbsp;</td>
    </tr>
  </table>
<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="show_result">
<input type="hidden" name="sub_sec_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
