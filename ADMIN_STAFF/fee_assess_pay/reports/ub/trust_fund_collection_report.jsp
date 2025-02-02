<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Trust Fund Collection Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
	function ReloadPage(){
		document.form_.reload_page.value = "1";
		document.form_.submit();
	}
	
	function PrintPg(){
			
		var pgLoc = "./trust_fund_collection_report_print.jsp?date_from="+document.form_.date_from.value+
		"&date_to="+document.form_.date_to.value+
		"&emp_id="+document.form_.emp_id.value+
		"&num_rec_page="+document.form_.num_rec_page.value+
		"&show_date_list=1";
	
		var win=window.open(pgLoc,"AddOrderItems",'width=800,height=600,top=20,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","trust_fund_collection_report.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"trust_fund_collection_report.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(),
														"trust_fund_collection_report.jsp");
}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//end of authenticaion code.
Vector vRetResult = new Vector();
Vector vSummary = new Vector();
Vector vDateListDetails = new Vector();
%>

<form name="form_" method="post" action="./trust_fund_collection_report.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          TRUST FUND COLLECTION REPORT::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong>
	  
	  <div align="right"><a href="./trust_fund_collection_report_detailed.jsp">Go to Detailed Report</a></div>
	  </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="15%" height="25">Collection Date</td>
      <td height="25" colspan="2"><font size="1">

        <input name="date_from" type="text" size="12" readonly="yes" maxlength="12" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
       to

        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" 
		onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        (for one day, leave to field empty.)
       
        </font></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">Teller ID</td>
      <td width="13%">

	  <input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" 
	  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td>&nbsp;</td>
    </tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td height="25">&nbsp;</td>
	<td colspan="5">
		<font size="2">Number of Rows Per Page :</font>
		<select name="num_rec_page">
		<% 
		int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
		for(int i = 10; i <=40 ; i++) {
			if ( i == iDefault) {%>
				<option selected value="<%=i%>"><%=i%></option>
			<%}else{%>
				<option value="<%=i%>"><%=i%></option>
			<%}
		}%>
		</select>
		
		&nbsp; &nbsp; &nbsp;
	  <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>
    <font size="1">click to print report</font>	</td></tr>  
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
<tr><td height="25" colspan="8">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<input type="hidden" name="reload_page">
<input type="hidden" name="show_date_list" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
