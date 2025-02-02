<%
utility.WebInterface WI = new utility.WebInterface(request);
boolean bolIsBIR = false;
if(WI.fillTextValue("bir_format").length() > 0) 
	bolIsBIR = true;

	if(WI.fillTextValue("print_pg").length() > 0 && bolIsBIR) {
		if(WI.fillTextValue("bir_csv").length() > 0) {%>
			<jsp:forward page="../../journal_voucher/jv_detail_print_bir_csv.jsp"/>
		<%}else{%>
			<jsp:forward page="../../journal_voucher/jv_detail_print_bir.jsp"/>
		<%}
	}


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
	if(document.form_.bir_format) {
		if(document.form_.bir_format.checked) {
			document.form_.print_stat.value = strPrintStat;
			document.form_.print_pg.value = "1";
			document.form_.submit();
			return;
		}
	}
		
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
	if(strPrintStat == '1') {
		document.form_.show_print_pages.value = '1';
		document.form_.submit();
		return;
	}
	var strGroupHeader = "";
	if(document.form_.group_.checked)
		strGroupHeader = "&group_=1";
	if(document.form_.remove_check.checked)
		strGroupHeader += "&remove_check=1";
	if(document.form_.group_sundry.checked)
		strGroupHeader += "&group_sundry=1";
	if(document.form_.inc_cancelled.checked)
		strGroupHeader +="&inc_cancelled=1";

	location = "./cash_disb_print.jsp?print_page_index="+document.form_.print_page_index.value+
		"&show_detail="+strPrintStat+strDateCon+
		"&report_format="+document.form_.report_format.selectedIndex+
		//"&bank_index="+document.form_.bank_index[document.form_.bank_index.selectedIndex].value+
		"&rows_per_pg="+document.form_.rows_per_pg[document.form_.rows_per_pg.selectedIndex].value+
		strGroupHeader;
}
/**
function ShowDetail(strPrintStat) {

	document.form_.print_stat.value = strPrintStat;
	document.form_.print_pg.value = "1";
	document.form_.submit();
}**/

function PrintSelPage() {
	var iMaxPage = document.form_.max_page.value;
	var objChkBox; var printPgVal = "";
	for( i = 0; i < iMaxPage; ++i) {
		eval('objChkBox=document.form_.checkbox_'+i);
		if(!objChkBox.checked)
			continue;
		if(printPgVal.length == 0)
			printPgVal = i;
		else
			printPgVal = printPgVal+","+i;
	}
	document.form_.print_page_index.value = printPgVal;
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
	  <strong>:::: DISBURSEMENT BOOK - DETAIL::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Frequency </td>
      <td style="font-weight:bold; color:#0000FF; font-size:11px;">
	  <select name="report_format" onChange="document.form_.print_pg.value='';document.form_.print_stat.value='';document.form_.submit()">
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
	  </select>	  
	  &nbsp;&nbsp;
	  <input type="checkbox" name="bir_format" value="checked" <%=WI.fillTextValue("bir_format")%> onClick="document.form_.submit()"> BIR Format
<%if(WI.fillTextValue("bir_format").length() > 0) {%>
	  <input type="checkbox" name="bir_csv" value="checked" <%=WI.fillTextValue("bir_csv")%>> Show in CSV Format
<%}%>	  
	  </td>
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
<%if(!bolIsBIR){%>
    <tr>
      <td height="20">&nbsp;</td>
      <td style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="group_" value="checked" <%=WI.fillTextValue("group_")%>> Group Accounts to Header Account
	  <br>
	  <input type="checkbox" name="group_sundry" value="checked" <%=WI.fillTextValue("group_sundry")%>> Group Sundry Account
	  </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td style="font-size:11px; font-weight:bold; color:#0000FF">
<%
strTemp = WI.fillTextValue("inc_cancelled");
if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>
	  <input type="checkbox" name="inc_cancelled" value="1"<%=strTemp%>> Include Cancelled Voucher
	  </td>
    </tr>
    <tr>
      <td height="20" colspan="2">&nbsp;&nbsp;<b><u>In Printing remove the following Column:</u></b></td>
    </tr>
    <tr>
      <td height="20" colspan="2">&nbsp;&nbsp;
	  <input type="checkbox" name="remove_check" value="checked" <%=WI.fillTextValue("remove_check")%>> Check #</td>
    </tr>
<%}//if not bir format%>
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
		for(int i =30; i < 1000; ++i){
			if( i == iDefVal)
				strErrMsg = " selected";
			else
				strErrMsg = "";%>
			<option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
		<%}%>
	  	</select>		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" style="font-size:10px;">
	  <a href="javascript:ShowDetail('1');" target="_self"><img src="../../../../../images/view.gif" border="0"></a> click to preview report &nbsp;
	  <a href="javascript:ShowDetail('0');" target="_self"><img src="../../../../../images/print.gif" border="0"></a> click to print report	  </td>
    </tr>
<%
if(!bolIsBIR){
	if(WI.fillTextValue("show_print_pages").length() > 0) {
		Accounting.Report.ReportSpecialBooks RSB = new Accounting.Report.ReportSpecialBooks();
		java.util.Vector vRetResult = RSB.getCDBookDetail(dbOP, request);
		java.util.Vector vCDInfo    = null;
		int iTotalPages   = 0;
		int iRowPerPg = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
		
		strErrMsg = null;
		if(vRetResult == null)
			strErrMsg = RSB.getErrMsg();
		else {
			vCDInfo = (java.util.Vector)vRetResult.remove(0);
			iTotalPages = vCDInfo.size()/(4 * iRowPerPg);
			if(vCDInfo.size() % (4 * iRowPerPg) > 0)
				++iTotalPages;
		}%>
			<tr>
			  <td height="35">&nbsp;</td>
			  <td style="font-size:9px; font-weight:bold; color:#0000FF"><%if(strErrMsg != null){%>Error msg : <%=strErrMsg%><%}else{%><u>Total Pages to print : <%=iTotalPages%> (select the pages to print and click print button - if no page is selected, Print button prints all)</u>
				<%}%></td>
			</tr>
	<%
	for(int i = 0; i < iTotalPages; ++i){%>
		<tr>
		  <td height="18">&nbsp;</td>
		  <td style="font-size:9px;"><input type="checkbox" name="checkbox_<%=i%>" value="<%=i+1%>" onClick="PrintSelPage()">Print Page : <%=i + 1%></td>
		</tr>
	<%}%>
	
	<input type="hidden" name="max_page" value="<%=iTotalPages%>">
	<%}
}%>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="show_print_pages">
<input type="hidden" name="print_page_index">
  
  
  <input type="hidden" name="jv_type" value="-1">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="print_stat">

</form>
</body>
</html>
<%
dbOP.rollbackOP();
dbOP.cleanUP();
%>
