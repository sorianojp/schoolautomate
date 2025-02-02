<%
utility.WebInterface WI = new utility.WebInterface(request);
utility.DBOperation dbOP = new utility.DBOperation();
String strErrMsg = null;
String strTemp = null;

String strAuthType = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strAuthType == null)
	strAuthType = "";
int iAuthType = Integer.parseInt(WI.getStrValue(strAuthType, "1"));

if(request.getSession(false).getAttribute("userIndex") == null)
	strErrMsg = "You are already logged out. Please login again.";
else if(iAuthType >3 || iAuthType == 0)
	strErrMsg = "You are not authorized to go to this link.";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../../jscript/td.js"></script>
<script language="javascript">
function ShowDetail(strPrintStat) {

	var strDateCon = "";
	if(document.form_.report_format.selectedIndex == 0) {
		if(document.form_.date_fr.value.length == 0) {
			alert("Please enter report date.");
			return;
		}
		strDateCon="&date_fr="+document.form_.date_fr.value;
		if(document.form_.date_to.value.length > 0)
			strDateCon += "&date_to="+document.form_.date_to.value;
	}
	else
		strDateCon = "&jv_month="+document.form_.jv_month[document.form_.jv_month.selectedIndex].value+
						"&jv_year="+document.form_.jv_year[document.form_.jv_year.selectedIndex].value;
	if(strDateCon.length == 0) {
		alert("Report date information not found.");
		return;
	}


	location = "./wholding_source.jsp?show_detail="+strPrintStat+strDateCon+
	"&report_format="+document.form_.report_format.selectedIndex+
	//"&bank_index="+document.form_.bank_index[document.form_.bank_index.selectedIndex].value+
	"&rows_per_pg="+document.form_.rows_per_pg[document.form_.rows_per_pg.selectedIndex].value;
}
</script>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="./cd_book_1st_page.jsp">
<%if(strErrMsg != null) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" style="font-size:14px; font-weight:bold; color:#FF0000"><%=strErrMsg%></td>
  </tr>
</table>
<%dbOP.cleanUP();return;}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A" align="center"><font color="#FFFFFF">
	  <strong>:::: DISBURSEMENT BOOK - WITHHOLDING @SOURCE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Frequency </td>
      <td>
	  <select name="report_format" onChange="document.form_.submit()">
	  	<option value="0">Date Range</option>
<%
String strReportType = WI.fillTextValue("report_format");
if(strReportType.length() == 0)
	strReportType = "0";
if(strReportType.equals("1"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
	  	<option value="1"<%=strErrMsg%>>Montly</option>
	  </select>	  </td>
    </tr>
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="11%" style="font-size:11px;">Date</td>
      <td width="86%">
<%if(strReportType.equals("0")){%>
        <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>&nbsp; to &nbsp;&nbsp;
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>
        <!-- show if selected per month -->
<%}else if(strReportType.equals("1")){%>
		<select name="jv_month">
          <%=dbOP.loadComboMonth(WI.fillTextValue("jv_month"))%>
        </select>
        <select name="jv_year">
          <%=dbOP.loadComboYear(WI.fillTextValue("jv_year"),5,1)%>
        </select>
<%}%>      </td>
    </tr>
<%if(false){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Bank</td>
      <td><select name="bank_index" style="font-size:11px;">
        <option value="">ALL</option>
<%
strTemp = " from AC_COA_BANKCODE where exists (select * from AC_CD_CHECK_DTL where "+
			"AC_COA_BANKCODE.bank_index = AC_CD_CHECK_DTL.bank_index) order by bank_code";
%>
<%=dbOP.loadCombo("bank_index","bank_code+' ::: '+bank_name",strTemp, WI.fillTextValue("bank_index"), false)%>

      </select></td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="14%" height="25">&nbsp;</td>
      <td width="86%" height="25">Number of rows per page :
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
	  <a href="javascript:ShowDetail('1');" target="_self"><img src="../../../../../images/view.gif" border="0"></a> click to preview report &nbsp;
	  <a href="javascript:ShowDetail('0');" target="_self"><img src="../../../../../images/print.gif" border="0"></a> click to print report
	  </td>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
