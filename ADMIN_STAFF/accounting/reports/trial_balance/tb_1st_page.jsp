<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
function ShowDetail(strPrintStat) {
	strTBDate = document.form_.tb_date.value;
	if(strTBDate.length == 0) {
		alert("Please enter  cutoff date..");
		return;
	}
	document.form_.print_stat.value = strPrintStat;
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function generateCSV() {
	var pgLoc = "./tb_print_csv.jsp?print_pg=1&tb_date="+document.form_.tb_date.value;
	if(document.form_.forward_balance.checked)
		pgLoc += "&forward_balance=checked";
	if(document.form_.show_one_entry.checked)
		pgLoc += "&show_one_entry=checked";
	//var win=window.open(pgLoc);
	location = pgLoc;
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.WebInterface" %>
<%
	WebInterface WI  = new WebInterface(request);
	if(WI.fillTextValue("generateCSV").length() > 0) {%>
		<jsp:forward page="./tb_print_csv.jsp"/>
	<%return;}
	
	
	if(WI.fillTextValue("print_pg").length() > 0) {
		if(WI.fillTextValue("report_ref").length() == 0) {%>
			<jsp:forward page="./tb_print.jsp"/>
		<%}else{%>
			<jsp:forward page="./tb_print_userdefined.jsp"/>
		<%}
	}
	
	utility.DBOperation dbOP = new utility.DBOperation();
	
%>
<form name="form_" method="post" action="./tb_1st_page.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          TRIAL BALANCE REPORT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2" style="font-size:11px; font-weight:bold; color:#0000FF">
<!--
	  	<input type="checkbox" name="print_header_account" value="checked" <%=WI.fillTextValue("print_header_account")%>> Print Header Account 
-->	  	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="checkbox" name="show_one_entry" value="checked" <%=WI.fillTextValue("show_one_entry")%>> Show One Entry per Account
<!--
	  	<input type="checkbox" name="print_header_account2" value="checked" <%=WI.fillTextValue("print_header_account2")%>> Show Header Account Only
-->	  </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2">Trial Balance Report : 
<select name="report_ref">
	<option value="">Show ALL Account With Transaction</option>
	<%//=dbOP.loadCombo("REPORT_REF","REPORT_NAME", " from AC_SET_TB_REPORT order by REPORT_NAME",WI.fillTextValue("report_ref"),false)%> 
        </select>	
		
		&nbsp;<font size="1">
		<input type="checkbox" name="forward_balance" value="checked" <%=WI.fillTextValue("forward_balance")%>> Include balance forward of Prev Year (Last month of prev year must be closed)
		</font>	  </td>
    </tr>
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="11%">Date </td>
      <td width="85%">
<%
String strTemp = WI.fillTextValue("tb_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
	  <input name="tb_date"  type="text" size="11" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.tb_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2">
	  <a href="javascript:generateCSV();">Generate CSV File (account number, account name, debit, credit)</a> </td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%" height="25">&nbsp;</td>
      <td width="85%" height="25">Number of rows Per page : 
	  	<select name="rows_per_pg">
		<option value="100000000">Print All</option>
	  	<%String strErrMsg = null;
		int iDefVal = 0;
		strTemp = WI.fillTextValue("rows_per_pg");
		if(strTemp.length() == 0) 
			iDefVal = 30;
		else	
			iDefVal = Integer.parseInt(strTemp);
		for(int i =30; i < 100; ++i){%>
			<option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
		<%}%>
	  	</select>
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" style="font-size:10px;">
	  <a href="javascript:ShowDetail('0');">
	  	<img src="../../../../images/show_list.gif" border="0"></a>click to preview list &nbsp;
	  <a href="javascript:ShowDetail('1');"><img src="../../../../images/print.gif" border="0"></a> 
        click to print list</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_pg">
  <input type="hidden" name="print_stat">
  <input type="hidden" name="generateCSV">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
