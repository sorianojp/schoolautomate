<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;
	document.form_.csv_.value = '';

	document.form_.submit();
}
function ShowProcessing()
{
	imgWnd=
	window.open("../../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	imgWnd.focus();
	return true;
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}
function GenerateCSV(strInfoIndex, strPageAction) {
	document.form_.csv_.value = '1';

	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<%@ page language="java" import="utility.*,Accounting.Report.ReportBIRAnnual,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	if(WI.fillTextValue("csv_").length() > 0) {%>
		<jsp:forward page="./cash_receipt_csv.jsp"/>
	<%return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Reports-Bir Reports-AR Students","cash_receipt.jsp");
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


boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0)
	bolIsBasic = true;

Vector vRetResult = null;
ReportBIRAnnual reportBIR = new ReportBIRAnnual();

if(WI.fillTextValue("generate_").length() > 0) {
	vRetResult = reportBIR.generateCashReceipt(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportBIR.getErrMsg();
}
%>

<form name="form_" action="./cash_receipt.jsp" method="post" onSubmit="SubmitOnceButton(this);return ShowProcessing();">
<input type="hidden" name="generate_">
<input type="hidden" name="csv_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: CASH RECEIPT ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr style="font-weight:bold;">
      <td height="40">&nbsp;</td>
      <td colspan="6" style="font-size:18px">
	  Payment Date: 
	  <input name="date_fr" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_fr")%>" class="textbox" style="font-size:18px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>

-

	  <input name="date_to" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_to")%>" class="textbox" style="font-size:18px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
	  
	  </td>
    </tr>
    <tr>
      <td height="50">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td width="38%" align="center">
	  
	  <input type="submit" name="122" value="Generate Cash Receipt" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.generate_.value='1';ShowProcessing();">	  </td>
      <td width="41%" align="center"><a href="javascript:GenerateCSV();">Generate CSV</a></td>
      <td width="7%" align="center">&nbsp;</td>
    </tr>
  </table>
  
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
		<tr>
			<td> Total Transactions: <%=(vRetResult.size() - 1)/7%> &nbsp;&nbsp;&nbsp; Total Amount: <%=vRetResult.remove(0)%> 
		</tr>
	</table> 
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF" >
		<tr style="font-weight:bold" bgcolor="#FFFFCC">
			<td class="thinborder" width="5%" height="22"> Count </td>
			<td class="thinborder" width="10%"> Date Paid </td>
			<td class="thinborder" width="10%">OR Number </td>
			<td class="thinborder" width="20%"> Payment Particular </td>
			<td class="thinborder" width="10%">Student ID </td>
			<td class="thinborder" width="25%">Student Name </td>
			<td class="thinborder" width="10%">OR Amount </td>
			<td class="thinborder" width="10%">Status</td>
		</tr>
		<%for(int i = 0; i < vRetResult.size(); i += 7) {%>
			<tr>
				<td class="thinborder" height="22"><%=i/7 + 1%> </td>
				<td class="thinborder"><%=vRetResult.elementAt(i)%></td>
				<td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
				<td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
				<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"&nbsp;")%></td>
				<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"&nbsp;")%></td>
				<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"&nbsp;")%></td>
				<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
			</tr>
		<%}%>
	</table> 
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
