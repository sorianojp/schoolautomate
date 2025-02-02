<%@ page language="java" import="utility.*,enrollment.FAElementaryPayment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp ="";
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - Reports ","list_basic_educ_payments.jsp");
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
														"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(),
														"list_basic_educ_payments.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
int iSearchResult = 0;
FAElementaryPayment fa = new FAElementaryPayment(request);

	vRetResult = fa.searchBasicPayments(dbOP);
	if (vRetResult == null)
		strErrMsg = fa.getErrMsg();
	else	
		iSearchResult = fa.getSearchCount();
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
-->
</style>
<body>
<form action="./list_basic_educ_payments.jsp" method="post" name="form_">
  <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> 
  <% if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" >
    <tr> 
      <td height="25" ><div align="center">
	<font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,true)%></font></font></div></td>
    </tr>

    <tr> 
      <td height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" ><strong>&nbsp;TOTAL RESULT : <%=iSearchResult%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
	<% if (WI.fillTextValue("date_to").length() != 0 || 
			(WI.fillTextValue("date_from").length() == 0 && WI.fillTextValue("date_to").length() == 0)) strTemp ="5"; else strTemp="4";%>
      <td height="25" colspan="<%=strTemp%>" class="thinborder"><div align="center"><strong><font size="2"> 
          BASIC EDUCATION PAYMENTS 
	<% if (WI.fillTextValue("date_from").length() > 0 && WI.fillTextValue("date_to").length() == 0){%><%=" for " + WI.formatDate(request.getParameter("date_from"),6)%> <%}%>
		  </font></strong></div></td>
    </tr>
    <tr align="center"> 
	<% if (WI.fillTextValue("date_to").length() != 0 || 
			(WI.fillTextValue("date_from").length() == 0 && WI.fillTextValue("date_to").length() == 0)){%>
      <td width="10%" height="25" class="thinborder"><strong>DATE</strong></td>
	<%}%>
      <td width="16%" class="thinborder"><strong>STUDENT ID</strong></td>
      <td width="34%" class="thinborder"><strong>STUDENT NAME</strong></td>
      <td width="14%" class="thinborder"><strong>AMOUNT </strong></td>
      <td width="14%" class="thinborder"><strong>OR NUMBER</strong></td>
    </tr>
    <% double dTotal = 0d; double dCurrentAmount = 0d;
		for (int i= 0; i < vRetResult.size() ; i+=12) {
		dCurrentAmount = Double.parseDouble((String)vRetResult.elementAt(i+9));
		dTotal +=dCurrentAmount;
	%>
    <tr> 
	<% if (WI.fillTextValue("date_to").length() != 0 || 
			(WI.fillTextValue("date_from").length() == 0 && WI.fillTextValue("date_to").length() == 0)){%>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
	<%}%>	 
      <td  class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td  class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5),4)%></td>
      <td class="thinborder" align="right"> <%=CommonUtil.formatFloat(dCurrentAmount,true)%></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+8)%></div></td>
    </tr>
    <%}%>
    <tr> 
	<% if (WI.fillTextValue("date_to").length() != 0 || 
			(WI.fillTextValue("date_from").length() == 0 && WI.fillTextValue("date_to").length() == 0)){
		strTemp ="thinborderBOTTOM";
	%><td height="25" class="thinborder">&nbsp;</td>
	<%}else{ strTemp = "thinborder";}%>
      <td class="<%=strTemp%>">&nbsp;</td>
      <td class="thinborderBOTTOM"><div align="right"><strong>Total Amount : </strong></div></td>
      <td align="right" class="thinborderBOTTOM"><strong><%=CommonUtil.formatFloat(dTotal,true)%></strong></td>
      <td class="thinborderBOTTOM">&nbsp;</td>
    </tr>
  </table>
<%}%>
</form>
<script language="JavaScript">
	window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>