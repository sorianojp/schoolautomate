<%
String strErrMsg = null; String strTemp = null;
String strAuthID = (String)request.getSession(false).getAttribute("userIndex");

utility.WebInterface WI  = new utility.WebInterface(request);

if(strAuthID == null){%>
<p style="font-size:14px; font-weight:bold; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif"> You are already logged out. Please login again.</p>
<%return;}

String strPrintPg = WI.fillTextValue("print_pg");
String strReportType = WI.fillTextValue("report_format");

if(strPrintPg.equals("1")){	
if(strReportType.equals("0") || strReportType.equals("1") || strReportType.equals("2")) {%>
	<jsp:forward page="./is_monthly.jsp"/>
<%return;}else if(strReportType.equals("1")){%>
	<jsp:forward page="./is_yearly.jsp"/>
<%return;}
}

utility.DBOperation dbOP = new utility.DBOperation();
%>
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
	document.form_.print_stat.value = strPrintStat;
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.WebInterface" %>
<form name="form_" method="post" action="is_report_1st_page.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A" align="center"><font color="#FFFFFF"><strong>:::: INCOME STATEMENT ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2" style="font-size:11px;">Income statement title : 
	  <select name="title_index" style="font-size:14px; font-weight:bold">
<%=dbOP.loadCombo("is_title_index","TITLE"," from AC_SET_IS_TITLE order by IS_TITLE_INDEX asc",WI.fillTextValue("title_index"), false)%>
      </select>		  
	  </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Frequency </td>
      <td>
	  <select name="report_format" onChange="document.form_.print_pg.value='';document.form_.submit();">
	  	<option value="0">Monthly</option>
<%
if(strReportType.length() == 0) 
	strReportType = "0";
	
if(strReportType.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%>
	  	<option value="1"<%=strTemp%>>Yearly ( Summary)</option>
<%
if(strReportType.equals("2"))
	strTemp = " selected";
else	
	strTemp = "";
%>
	  	<option value='2'<%=strTemp%>>Specific Date Range</option>
<!--
	  	<option value='2'>Yearly ( Monthly Data)</option>
	  	<option value='3'>Yearly (Quarterly Data)</option>
-->
	  </select>
<%if(!strReportType.equals("0") && !strReportType.equals("2")){%>
<input type="checkbox" name="fiscal_yr" value="1" checked="checked"> Fiscal Year (Note : uncheck to consider Jan-Dec duration for selected Year) 	  
<%}%>	  </td>
    </tr>
<%if(!strReportType.equals("0") && !strReportType.equals("2")){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2" style="font-size:11px;">
	  <input type="checkbox" name="show_monthly" value="checked" <%=WI.fillTextValue("show_monthly")%> onClick="document.form_.print_pg.value='';document.form_.submit();">
	  Show Monthly Option ( Incase of Yearly Summary - If month is selected, report considers upto the selected Month) </td>
    </tr>
<%}%>
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="16%" style="font-size:11px;">Date</td>
      <td width="81%">
<%
if(strReportType.equals("2")){
	strTemp = WI.fillTextValue("date_fr");
%>
	  From 
        <input name="date_fr"  type="text" size="11" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        &nbsp;&nbsp;To 
        <input name="date_to"  type="text" size="11" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
<%}else {
if(strReportType.equals("0") || WI.fillTextValue("show_monthly").length() > 0){%>
        <select name="month_">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_"))%>
        </select>
<%}//end of showing for monthly.. %>
        <select name="year_">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_"),2,1)%>
        </select>      
<%}%>
		</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(!strReportType.equals("2")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">
        Show Comparison Data 
          <select name="prev_yr">
		  <option value=""></option>
<%
strTemp = WI.fillTextValue("prev_yr");
if(strTemp.length() == 0) 
	strTemp = "1";
%>          <%=dbOP.loadComboYear(strTemp,6,0)%>
          </select>        </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td width="19%" height="25">&nbsp;</td>
      <td width="81%" height="25">Number of rows Per page : 
	  	<select name="rows_per_pg">
	  	<%
		int iDefVal = 0;
		strTemp = WI.fillTextValue("rows_per_pg");
		if(strTemp.length() == 0) 
			iDefVal = 30;
		else	
			iDefVal = Integer.parseInt(strTemp);
		for(int i =30; i < 100; ++i){
			if( i == iDefVal)
				strErrMsg = " selected";
			else	
				strErrMsg = "";%>
	  	  <option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
		<%}%>
	  	</select>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" style="font-size:10px;">
	  <a href="javascript:ShowDetail('0');">
	  	<img src="../../../../images/show_list.gif" border="0"></a>click to preview list &nbsp;
	  <a href="javascript:ShowDetail('1');"><img src="../../../../images/print.gif" border="0"></a> 
        click to print list</td>
    </tr>
<!--    <tr> 
      <td height="25" colspan="2">
	  <input type="radio" name="report_" value="0"> Monthly
	  <input type="radio" name="report_" value="1"> Yearly summary
	  
	  	<a href="is_report_monthly.htm">format_monthly </a> &nbsp;&nbsp;&nbsp;
		<a href="is_report_yearly_12months.htm">format_yearly - monthly data </a>&nbsp;&nbsp;&nbsp;
		<a href="is_report_yearly_quarterly.htm">format_yearly - quarterly data</a>&nbsp;&nbsp;&nbsp;
		<a href="is_report_yearly_summary.htm">format_yearly - summary data </a>
		</td>
    </tr>
-->    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_pg">
  <input type="hidden" name="print_stat">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
