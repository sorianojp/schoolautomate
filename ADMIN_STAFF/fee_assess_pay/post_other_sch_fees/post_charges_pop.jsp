<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Post Charges","post_charges_pop.jsp");
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
														"Fee Assessment & Payments","Post Charges",request.getRemoteAddr(),
														"post_charges_pop.jsp");
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

enrollment.FAFeePost feePost  = new enrollment.FAFeePost();

Vector vRetResult = feePost.viewAllDuplicate(dbOP, request);
if (vRetResult == null){
	strErrMsg = feePost.getErrMsg();
}
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
%>
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
 }

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
    }
-->
</style>
</head>

<body>
<form action="" method="post">
<%=WI.getStrValue(strErrMsg)%>
<% if (vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td colspan="4" class="thinborder"><div align="center"><strong><font size="2">LIST 
          OF DUPLICATE ENTRIES</font></strong><br>
        FOR SY/SEM : <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%> / 
		<%=astrConvertTerm[Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"0"))]%></div></td>
  </tr>
  <tr> 
    <td width="17%" class="thinborder"><font size="1">&nbsp;ID NUMBER</font></td>
    <td width="37%" class="thinborder"><font size="1">&nbsp;NAME OF STUDENT</font></td>
    <td width="35%" class="thinborder"><font size="1">&nbsp;NAME OF FEE</font></td>
    <td width="11%" height="25" class="thinborder"><font size="1"> &nbsp;NO. OF RECORDS</font></td>
  </tr>
<% for(int i = 0; i< vRetResult.size(); i+=4){%>
  <tr>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
    <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
  </tr>
<%}%>
</table>
<%}%>
<input type="hidden" name ="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name ="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name ="semester" value="<%=WI.fillTextValue("semester")%>">
</form>
</body>
</html>
