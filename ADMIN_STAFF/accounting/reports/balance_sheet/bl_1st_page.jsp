<%
String strErrMsg = null;
String strPrintPg = request.getParameter("print_pg");
if(strPrintPg != null && strPrintPg.equals("1")){%>
	<jsp:forward page="./bl_print.jsp"/>
<%return;}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/td.js"></script>
<script language="javascript">
function ShowDetail(strPrintStat) {
	document.form_.print_stat.value = strPrintStat;
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function ShowHideAsOfDate() {
	if(document.form_.jv_date.selectedIndex == 0) 
		showLayer('asofdate');
	else
		hideLayer('asofdate');
}
function AsOfDate() {
	if(!document.form_.as_of_date.checked)
		return;
		
	if(!document.form_.date_to || document.form_.date_to.value.length == 0) {
		alert("Please enter date to value and click As of Date check box");
		document.form_.as_of_date.checked = false;
		return;
	}
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*"%>
<%
String strFSYearStartFr = null; String strSQLQuery = null;

WebInterface WI          = new WebInterface(request);
java.sql.ResultSet rs    = null;
utility.DBOperation dbOP = new utility.DBOperation();

String strDateTo = WI.fillTextValue("date_to");
if(strDateTo.length() > 0) 
	strDateTo = ConversionTable.convertTOSQLDateFormat(strDateTo);
if(strDateTo == null) 
	strErrMsg = "Please enter correct date format.";
else if(WI.fillTextValue("as_of_date").length() > 0) {
	String strTrialBalanceYear = strDateTo.substring(0,4); 
    String strTrialBalanceMM   = strDateTo.substring(5,7);
    int iTBYear                = Integer.parseInt(strTrialBalanceYear);
	strSQLQuery = "select START_MONTH,START_DAY from AC_FISCAL where "+
            "(VALIDYR_TO is null and VALIDYR_FR <="+strTrialBalanceYear +") or "+
            strTrialBalanceYear +" between VALIDYR_FR and VALIDYR_TO";
	rs = dbOP.executeQuery(strSQLQuery);
    int iStartMonth = 0;
    if (!rs.next()) {
    	rs.close();
        strErrMsg ="Report for As of date can't be generated. Please create financial year information.";
    }
	else {
		iStartMonth = rs.getInt(1) + 1;
        if(iStartMonth > Integer.parseInt(strTrialBalanceMM))
        	--iTBYear;
		strFSYearStartFr = Integer.toString(iStartMonth)+"/"+rs.getString(2)+"/"+Integer.toString(iTBYear);
		rs.close();	
	}
}

  
dbOP.cleanUP();
%>
<form name="form_" method="post" action="./bl_1st_page.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A" align="center"><font color="#FFFFFF">
	  <strong>:::: BALANCE SHEET PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="3" color="#FF0000">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Report Format </td>
      <td>
	  <select name="report_format" onChange="document.form_.print_pg.value='';document.form_.submit();">
	  	<option value="1">Date Range</option>
<%
String strReportType = WI.fillTextValue("report_format");
String strTemp       = null;

if(strReportType.length() == 0) 
	strReportType = "1";
if(strReportType.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="2"<%=strErrMsg%>>Monthly</option>
<%
if(strReportType.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="3" <%=strErrMsg%>>Quarterly</option>
<%
if(strReportType.equals("4"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  	<option value="4"<%=strErrMsg%>>Yearly</option>
	  </select>
	  &nbsp;&nbsp;&nbsp;<%if(strReportType.equals("1")){%>
	  	<label id="asofdate" style="font-weight:bold; font-size:11px; color:#0000FF"><input type="checkbox" name="as_of_date" onClick="AsOfDate();">As of Date</label>
	  <%}%>
	  &nbsp;<font size="1">
		<input type="checkbox" name="forward_balance" value="checked" <%=WI.fillTextValue("forward_balance")%>> Include balance forward of Prev Year (Last month of prev year must be closed)
		</font>
	  </td>
    </tr>
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="16%" style="font-size:11px;">Date</td>
      <td width="81%">
<%if(strReportType.equals("3")){%>
		<select name="quarterly">
			<option value="1">1st Quarter</option>
			<option value="2">2nd Quarter</option>
			<option value="3">3rd Quarter</option>
			<option value="4">4th Quarter</option>
		</select>
<%}if(strReportType.equals("1")){
if(strFSYearStartFr != null)
	strTemp = strFSYearStartFr;
else	
	strTemp = WI.fillTextValue("date_fr");
%>
        <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>&nbsp; to &nbsp;&nbsp;
<%
strTemp = WI.fillTextValue("date_to");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        <!-- show if selected per month -->
<%}else if(strReportType.equals("2") || strReportType.equals("4") || strReportType.equals("3")){//monthly or yearly..
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
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
<%if(strReportType.equals("4") && false){%>
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
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
<%}%>

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
	  	</select>	  </td>
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
