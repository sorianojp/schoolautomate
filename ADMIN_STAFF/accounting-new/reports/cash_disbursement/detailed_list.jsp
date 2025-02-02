<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function PrintPg(strPrintStat) {
	var strDaily = document.form_.report_type[0].checked;
	var strURLCon = "";
	if(strDaily) {
		var strDateFr = document.form_.cd_date_fr.value;
		var strDateTo = document.form_.cd_date_to.value;
		if(strDateFr.length == 0) {
			alert("Must enter Check date FROM Value.");
			return;
		}
		strURLCon = "&cd_date_fr="+strDateFr+"&cd_date_to="+strDateTo;
	}
	else {//monthly.
		strURLCon = "&cd_month="+document.form_.cd_month.selectedIndex+
					"&cd_year="+document.form_.cd_year[document.form_.cd_year.selectedIndex].value;
	}
	var strReportFormat=document.form_.report_format.value;
	strURLCon = strURLCon +"&report_format="+strReportFormat;
	strURLCon = "?rows_per_pg="+
				document.form_.rows_per_pg[document.form_.rows_per_pg.selectedIndex].value+
				strURLCon+"&print_stat="+strPrintStat;

	var pgLoc = "";
	if(strReportFormat == 1)
		pgLoc = "./detailed_list_print.jsp"+strURLCon;
	else if(strReportFormat == 2) //summary by bank account.
		pgLoc = "./summary_by_bank_account_print.jsp"+strURLCon;
	else if(strReportFormat == 3) //summary by Charged to account.
		pgLoc = "./summary_by_charged_account_print.jsp"+strURLCon;


	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();

}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation();
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
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
if(WI.fillTextValue("report_format").equals("1"))//(Detailed)
	strTemp = "List of Disbursement Vouchers (Detailed) PAGE";
else if(WI.fillTextValue("report_format").equals("2"))//(Summary by Bank Account)
	strTemp = "List of Disbursement Vouchers (Summary by Bank Account) PAGE";
else // (Summary by Charged to Account)
	strTemp = "List of Disbursement Vouchers (Summary by Charged to Account) PAGE";

%>
<form action="detailed_list.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          DISBURSEMENT REPORT ::::<br><%=strTemp%></strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1"><a href="rep_cash_disbursement.htm"><img src="../../../../images/go_back.gif" border="0"></a></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="26">&nbsp;</td>
      <td width="19%" style="font-size:11px;">Report Format </td>
      <td width="77%">
<%
strTemp = WI.fillTextValue("report_type");
if(strTemp.length() == 0 || strTemp.equals("0"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
	  <input type="radio" value="0" name="report_type"<%=strErrMsg%> onClick="document.form_.submit();"> Daily/Date Range &nbsp;&nbsp;
<%
if(strTemp != null && strTemp.equals("1"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>	  <input type="radio" value="1" name="report_type"<%=strErrMsg%> onClick="document.form_.submit();"> Monthly</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Date </td>
      <td>
	  <%
		if(strTemp.equals("0") || strTemp.length() == 0){%>
			  <input name="cd_date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("cd_date_fr")%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.cd_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>&nbsp; to &nbsp;&nbsp;
			   <input name="cd_date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("cd_date_to")%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.cd_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
		<!-- show if selected per month -->
		<%}else{%>
				<select name="cd_month">
					<%=dbOP.loadComboMonth(WI.fillTextValue("cd_month"))%>
				</select>
				<select name="cd_year">
					<%=dbOP.loadComboYear(WI.fillTextValue("cd_year"),5,1)%>
				</select>
		<%}%>		</td>
    </tr>
    <tr>
      <td height="26" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="15%" height="25">&nbsp;</td>
      <td width="85%" height="25">Number of rows Per page :
	  	<select name="rows_per_pg">
	  	<%
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
      <td width="14%" height="25">&nbsp;</td>
      <td width="86%" height="25"><font size="1">
	  <a href="javascript:PrintPg('0');"><img src="../../../../images/show_list.gif" border="0"></a>
        click to preview list &nbsp;<a href="javascript:PrintPg('1');"><img src="../../../../images/print.gif" border="0"></a>
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
 <input type="hidden" name="report_format" value="<%=WI.fillTextValue("report_format")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
