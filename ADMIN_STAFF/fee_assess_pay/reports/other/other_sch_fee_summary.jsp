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
								"Admin/staff-Fee Assessment & Payments - External Payments","other_sch_fee_summary.jsp");
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
														"other_sch_fee_summary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null; Vector vHeader = new Vector();
FAExternalPay fa = new FAExternalPay(request);
if(WI.fillTextValue("date_from").length() > 0) {
	vRetResult = fa.getOtherSchoolFeePaymentSummary(dbOP, request);
	if(vRetResult != null && vRetResult.size() > 0) 
		vHeader = (Vector)vRetResult.remove(0);
	else	
		strErrMsg = fa.getErrMsg();
}

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
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
	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.

}
-->
</script>
<body bgcolor="#D2AE72">
<form action="./other_sch_fee_summary.jsp" method="post" name="form_">

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>:::: OTHER SCHOOL FEE COLLECTION SUMMARY ::::</strong></font></strong></font></div></td>
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
	  value="<%=WI.fillTextValue("date_from")%>" size="10"> <a href="javascript:show_calendar('form_.date_from');"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <input name="date_to" type="text" class="textbox" id="date_to"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>" size="10"
	  readonly="yes">
      <a href="javascript:show_calendar('form_.date_to');"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="10"><a href="javascript:showList()"><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
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
      <td height="25" align="right" style="font-size:9px;"><a href="javascript:printPg();"><img src="../../../../images/print.gif" border="0"></a>Print Page</td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="7" bgcolor="#cccccc" class="thinborderTOPLEFTRIGHT"><div align="center"><strong><font size="2">LIST OF OTHER SCHOOL FEE PAYMENTS (<%=strDateRange%>)</font></strong></div></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center"> 
      <td width="8%" height="25" class="thinborder"><strong>DATE</strong></td>
      <%for(int p = 1 ; p < vHeader.size(); p += 2) {%>
	  	<td width="10%" class="thinborder"><%=(String)vHeader.elementAt(p)%></td>
      <%}%>
	  <td width="8%" class="thinborder"><strong><font size="1">TOTAL</font></strong></td>
    </tr>
<%
//System.out.println(vRetResult);
double dRowTotal = 0d; int iIndexOf = 0; double dTemp = 0d;

Vector vTemp = null;
for(int i = 0; i < vRetResult.size(); i += 2){
vTemp = (Vector)vRetResult.elementAt(i + 1);
%>
    <tr align="center">
      <td height="25" class="thinborder" style="font-size:10px;"><%=(String)vRetResult.elementAt(i)%></td>
      <%for(int p = 1 ; p < vHeader.size(); p += 2) {
	  if(vTemp.size() == 0 || !vHeader.elementAt(p).equals(vTemp.elementAt(0)))
	  	strTemp = "&nbsp;";
	  else	{
	  	dTemp = ((Double)vTemp.elementAt(1)).doubleValue();
		dRowTotal += dTemp;
		vTemp.remove(0);vTemp.remove(0);
		strTemp = CommonUtil.formatFloat(dTemp, true);
	  }
	  %>
	  	<td width="10%" class="thinborder" align="right"><%=strTemp%></td>
      <%}%>
      <td class="thinborder" style="font-size:10px;" align="right"><%=CommonUtil.formatFloat(dRowTotal, true)%></td>
    </tr>
<%dRowTotal = 0d;}%>
    <tr align="center" style="font-weight:bold">
      <td height="25" class="thinborder" style="font-size:11px;">Total</td>
      <%for(int p = 1 ; p < vHeader.size(); p += 2) {%>
	  	<td width="10%" class="thinborder" align="right"><%=(String)vHeader.elementAt(p + 1)%></td>
      <%}%>
      <td class="thinborder" style="font-size:11px;" align="right"><%=(String)vHeader.elementAt(0)%></td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable4">
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>