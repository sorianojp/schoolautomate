<%@ page language="java" import="utility.*,java.util.Vector,java.util.Date" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp   = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-PAYMENT"),"0"));
		if(iAccessLevel == 0) 
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
	}
			
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-Credit Card Setting","setting.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

enrollment.CreditCardInfo CCardInfo = new enrollment.CreditCardInfo();
Vector vRetResult = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	vRetResult = CCardInfo.operateOnCCardPaymentSetting(dbOP, request, Integer.parseInt(strTemp));
	strErrMsg = CCardInfo.getErrMsg();
}
else
	vRetResult = CCardInfo.operateOnCCardPaymentSetting(dbOP, request, 10);

dbOP.cleanUP();

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
</script>
<body>
<form name="form_" method="post" action="setting.jsp">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">
	  <jsp:include page="./inc.jsp?pgIndex=1"></jsp:include>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="22" colspan="3" align="center" style="font-size:11px; font-weight:bold"><u>:::: CREDIT CARD SETTING ::::</u></td>
    </tr>	
<%
if(strErrMsg != null) {%>
    <tr> 
      <td height="25" colspan="4" style="font-size:14px; font-weight:bold;">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
<%}%>
  </table>

<%if(strSchCode.startsWith("AUF")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
  	<td height="25" width="25%">Processing Fee(%ge) : </td>
  	<td width="10%">
	<input name="processing_fee" type="text" size="4" maxlength="4" value="<%=(String)vRetResult.elementAt(0)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','processing_fee');style.backgroundColor='white'"
	  onkeyup="AllowOnlyFloat('form_','processing_fee');">
	  </td>
  	<td style="font-size:9px;"><input type="image" src="../../../../images/update.gif" onClick="document.form_.page_action.value='1'"> 
  	(Please enter new Value and click update) </td>
  </tr>
  <tr>
  	<td height="35">Minimum Processing Fee : </td>
  	<td><input name="min_processing" type="text" size="4" maxlength="4" value="<%=(String)vRetResult.elementAt(4)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','min_processing');style.backgroundColor='white'"
	  onkeyup="AllowOnlyFloat('form_','min_processing');"></td>
  	<td style="font-size:9px;"><input type="image" src="../../../../images/update.gif" onClick="document.form_.page_action.value='0'">
	(Please enter new Value and click update) </td>
  </tr>
  <tr>
    <td height="25" colspan="3"><br><b><u>Other Fixed System Setting :</u> </b><br />
      1. For Full Payment (Downpayment) processing fee is not charged. <br />
	  2. For E-Pay processing fee is not charged. <br />
	  3. Full Payment discount is not applicable for E-Pay or Credit Card payment. <br />
	  
	  
	  </td>
    </tr>
  </table>	
<%}else{%>

	NOT APPLICABLE 
	
<%}%>
  <input type="hidden" name="page_action">
</form>
</body>
</html>
