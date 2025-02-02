<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CANCEL OR</title>
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>
<body>
<%@ page language="java" import="utility.DBOperation,utility.CommonUtil,utility.WebInterface,enrollment.FAPayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);
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
Vector vRetResult = new Vector();
vRetResult = faPayment.operateOnCancelORNew(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = faPayment.getErrMsg();

//end of authenticaion code.
if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="3%" height="25">&nbsp;</td>
      <td width="97%" height="25"><b><font size="3"><%=WI.getStrValue(strErrMsg)%></font></b></td>
    </tr>
  </table>

<%}
if(vRetResult != null && vRetResult.size() > 0){%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td height="25" colspan="12" bgcolor="#CCCCCC" class="thinborder"><div align="center"><strong>LIST 
        OF CANCELLED OR</strong></div></td>
  </tr>
  <tr align="center"> 
    <td width="10%" height="25" class="thinborder"><div align="center"><font size="1"><strong>OR. NO.</strong></font></div></td>
    <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
    <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div></td>
    <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>SY (TERM)</strong></font></div></td>
    <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
    <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>REFERENCE NO.</strong></font></div></td>
    <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>OR PRINTED BY</strong></font></div></td>
    <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>TRANSACTION DATE</strong></font></div></td>
    <td width="13%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">DATE CANCELLED </td>
    <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>PAYMENT FOR </strong></font></div></td>
    <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>REASON FOR CANCELLATION</strong></font></div></td>
    <td width="18%" class="thinborder"><font size="1"><strong>CANCELLED BY</strong></font></td>
  </tr>
  <%
 for(int i = 0; i < vRetResult.size(); i += 19) {%>
  <tr> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 13),"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 14),"&nbsp;")%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%>-<%=(String)vRetResult.elementAt(i + 2)%> (<%=(String)vRetResult.elementAt(i + 3)%>)</td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 8)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 12)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 10)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 11)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 15)%></td>
  </tr>
  <%}%>
</table>
<script language="JavaScript">
	window.print();
 </script>
 <%}%>
 
</body>
</html>
<%
dbOP.cleanUP();
%>