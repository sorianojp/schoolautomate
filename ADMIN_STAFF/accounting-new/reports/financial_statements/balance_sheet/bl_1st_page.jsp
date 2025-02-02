<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript">
function ShowDetail(strPrintStat) {
	strTBDate = document.form_.bl_date.value;
	if(strTBDate.length == 0) {
		alert("Please enter  cutoff date..");
		return;
	}
	document.form_.print_stat.value = strPrintStat;
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.WebInterface" %>
<form name="form_" method="post" action="bl_1st_page.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A" align="center"><font color="#FFFFFF">
	  <strong>:::: BALANCE SHEET PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Report Format </td>
      <td>
	  <select name="report_format" onChange="document.form_.submit();">
	  	<option value="1">Date Range</option>
<%
WebInterface WI          = new WebInterface(request);
java.sql.ResultSet rs    = null;
utility.DBOperation dbOP = new utility.DBOperation();
rs = dbOP.executeQuery("select  
dbOP.cleanUP();

String strReportType = WI.fillTextValue("report_format");
String strErrMsg     = null;
String strTemp       = null;

if(strReportType.length() == 0) 
	strReportType = "1";
if(strReportType.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="2"<%=strErrMsg%>>Montly</option>
<%
if(strReportType.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="3"<%=strErrMsg%>>Quarterly</option>
<%
if(strReportType.equals("4"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  	<option value="4"<%=strErrMsg%>>Yearly</option>
	  </select>
	  
	  </td>
    </tr>
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="16%" style="font-size:11px;">Date</td>
      <td width="81%">
<%
if(strReportType.equals("1")){%>
        <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>&nbsp; to &nbsp;&nbsp;
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>
        <!-- show if selected per month -->
<%}else if(strReportType.equals("2") || strReportType.equals("4")){//monthly or yearly..
	if(strReportType.equals("2")){%>
        <select name="jv_month">
          <%=dbOP.loadComboMonth(WI.fillTextValue("jv_month"))%>
        </select>
	<%}//end of showing for monthly.. %>
        <select name="jv_year">
          <%=dbOP.loadComboYear(WI.fillTextValue("jv_year"),5,1)%>
        </select>
<%}%>
      </td>
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
		for(int i =30; i < 100; ++i){
			if( i == iDefVal)
				strErrMsg = " selected";
			else	
				strErrMsg = "";%>
			<option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
		<%}%>
	  	</select>
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" style="font-size:10px;">
	  <a href="javascript:ShowDetail('0');">
	  	<img src="../../../../../images/show_list.gif" border="0"></a>click to preview list &nbsp;
	  <a href="javascript:ShowDetail('1');"><img src="../../../../../images/print.gif" border="0"></a> 
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
</form>
</body>
</html>
