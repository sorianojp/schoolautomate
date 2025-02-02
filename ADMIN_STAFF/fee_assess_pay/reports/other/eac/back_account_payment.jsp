<%@ page language="java" import="utility.*,enrollment.FAExternalPay,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - Reports - Back Account","back_account_payment.jsp");
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
														"back_account_payment.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null; Vector vHeader = new Vector();
FAExternalPay fa = new FAExternalPay(request);

String strTotalAmt = null;
if(WI.fillTextValue("date_from").length() > 0) {
	vRetResult = fa.getBackAccountPaymentList(dbOP, request);
	if(vRetResult != null && vRetResult.size() > 0) 
		strTotalAmt = (String)vRetResult.remove(0);
	else	
		strErrMsg = fa.getErrMsg();
}

String[] asterConverTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function showList(){
	document.form_.reloadPage.value = "1";
	document.form_.print_page.value = "";
	document.form_.submit();
}
function printPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
	
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.

}
-->
</script>
<body>
<form action="./back_account_payment.jsp" method="post" name="form_">

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable1">
    <tr >
      <td height="20" colspan="5" align="center" valign="bottom" class="thinborderBOTTOM"><strong>:::: BACK ACCOUNT PAYMENT DETAIL ::::</strong></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%">Date of Payment</td>
      <td width="81%"> 
        <input name="date_from" type="text" class="textbox" id="date_from" readonly="yes"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.fillTextValue("date_from")%>" size="10"> <a href="javascript:show_calendar('form_.date_from');"><img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <input name="date_to" type="text" class="textbox" id="date_to"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>" size="10"
	  readonly="yes">
      <a href="javascript:show_calendar('form_.date_to');"><img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td>
<% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0) {
	if(request.getParameter("reloadPage") == null)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); 
}	
%> 
			<input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			to 
			<%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0) {
	if(request.getParameter("reloadPage") == null)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); 

}	
%> 

			<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
			- 
			<select name="semester">
				<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
				<option value="0" selected>Summer</option>
<%}else{%>
				<option value="0">Summer</option>
<%}if(strTemp.compareTo("1") ==0){%>
				<option value="1" selected>1st Sem</option>
<%}else{%>
				<option value="1">1st Sem</option>
<%}if(strTemp.compareTo("2") == 0){%>
				<option value="2" selected>2nd Sem</option>
<%}else{%>
				<option value="2">2nd Sem</option>
<%}if(strTemp.compareTo("3") == 0){%>
				<option value="3" selected>3rd Sem</option>
<%}else{%>
				<option value="3">3rd Sem</option>
<%}%>
	  </select></td>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="10"><a href="javascript:showList()"><img src="../../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null) {
String strDateRange = null;
if(WI.fillTextValue("date_to").length() > 0)
	strDateRange = WI.fillTextValue("date_from") +" to "+WI.fillTextValue("date_to");
else	
	strDateRange = WI.fillTextValue("date_from");
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr> 
      <td height="25" align="right" style="font-size:9px;">
	  <select name="rows_per_page">
<%
int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"), "50"));
	for(int i = 40;	i < 60; ++i) {
		if(iDefVal == i)
			strTemp = " selected";
		else
			strTemp = "";
	%><option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>  
	  </select>
	  Rows Per Page
	  
	  <a href="javascript:printPg();"><img src="../../../../../images/print.gif" border="0"></a>Print Page</td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="22" colspan="7" bgcolor="#cccccc" class="thinborderTOPLEFTRIGHT"><div align="center"><strong><font size="2">LIST OF BACK ACCOUNT PAYMENT (<%=strDateRange%>)
	  <%if(WI.fillTextValue("sy_from").length() > 0) {%>
	  	<br><%=asterConverTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
	  <%}%>
	  </font></strong></div></td>
    </tr>
</table>
<%
int iRowsPrinted = 0;
int iCount = 0;
for(int i = 0; i < vRetResult.size(); ){
	iRowsPrinted = 0;
	if(i > 0) {%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold"> 
        <td width="4%" height="22" class="thinborder">Count</td>
        <td width="12%" height="22" class="thinborder">Date Paid</td>
	  	<td width="10%" class="thinborder">OR Number </td>
	  	<td width="16%" class="thinborder">Student ID </td>
	  	<td width="26%" class="thinborder">Student Name </td>
	  	<td width="17%" class="thinborder">Amount Paid </td>
	  	<td width="15%" class="thinborder">Collected By </td>
  	</tr>
<%for(; i < vRetResult.size(); i += 10) {
	if(iRowsPrinted > iDefVal)
		break;
	%>
	<tr>
      <td height="22" class="thinborder"><%=++iCount%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 0)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(i + 3)%>&nbsp;</td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
    </tr>
<%}//end of For loop%>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	<tr>
      <td height="22" align="right" style="font-weight:bold; font-size:12px;">TOTAL: <%=strTotalAmt%>&nbsp;</td>
	  	<td width="15%"></td>
    </tr>
 </table>
<%}//end of out Loop.. 
}%>
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>