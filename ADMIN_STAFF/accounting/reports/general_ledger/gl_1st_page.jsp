<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
//strSchCode = "DBTC";


if(strSchCode == null) {%>
	<p style="font-size:16px; font-weight:bold; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif">You are already logged out. Please login again.</p>
<%return;}%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/td.js"></script>
<script language="javascript">
function SelAll(iStat) {
	var bolIsChecked = false;
	var iStart = 0;
	var iMaxDisp = document.form_.max_disp.value;
	
	if(iStat == '0') {
		iStart = 1;
		bolIsChecked = document.form_.sel_all0.checked;
	}
	else {
		iStart = 2;
		bolIsChecked = document.form_.sel_all1.checked;
	}	
	
	for(var i = iStart; i <= iMaxDisp; i +=2)
		eval('document.form_.sel_'+i+'.checked='+bolIsChecked);
		
}
function ShowDetail(strPrintStat) {
	if(document.form_.batch_print && document.form_.batch_print.checked) {
		
		
	}

	strCOANumber = document.form_.coa_index.value;
	if(strCOANumber.length == 0) {
		alert("Please enter chart of account number.");
		return;
	}
	if(document.form_.report_type[1].checked) {
		if(!document.form_.jv_month) {
			alert("Please select a month.");
			return;
		}
	}	
	
	
	document.form_.print_stat.value = strPrintStat;
	document.form_.print_pg.value = "1";
	
	if(document.form_.jv_year) 
		document.form_.year_.value = document.form_.jv_year[document.form_.jv_year.selectedIndex].value - 1;
	
	document.form_.submit();
}
function MapCOAAjax(strIsBlur) {
	if(document.form_.batch_print && document.form_.batch_print.checked)
		return;
	
		var objCOA;
		objCOA=document.getElementById("coa_info");
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			document.form_.coa_index.value+"&coa_field_name=coa_index&is_blur="+strIsBlur;
		this.processRequest(strURL);
}
function COASelected(strAccountName) {
	document.getElementById("coa_info").innerHTML = "End of Processing..";
}
function ShowHideAsOfDate() {
	if(document.form_.jv_date.selectedIndex == 0) 
		showLayer('asofdate');
	else
		hideLayer('asofdate');
}
function PrintBatchClicked() {
	document.getElementById("coa_info").innerHTML = "";
	var obj = document.getElementById("_name");
	if(document.form_.batch_print.checked)
		obj.innerHTML = "Header Account/Classfication";
	else
		obj.innerHTML = "Account Number";	
}
</script>
<%@ page language="java" import="utility.WebInterface, java.util.Vector" %>
<%
	String strTemp   = null;
	String strErrMsg = null;
	WebInterface WI  = new WebInterface(request);
	
	String strPageForwardPrintDetail   = "./gl_print_detail.jsp";
	String strPageForwardPrintSummary  = "./gl_print_summary.jsp";//never called.
	String strPageForwardPrintPerMonth = "./gl_print_summary_permonth.jsp";
	if(WI.fillTextValue("batch_print").length() > 0) {
		//strPageForwardPrintDetail   = "./gl_print_detail_batch.jsp";
		//strPageForwardPrintPerMonth = "./gl_print_summary_permonth_batch.jsp";
	}
	

	if(WI.fillTextValue("print_pg").length() > 0) {
		strTemp = WI.fillTextValue("report_type");
		if(strTemp.equals("1")){%>
		<jsp:forward page="<%=strPageForwardPrintDetail%>"/>
	<%	}else if(strTemp.equals("0") && false){%><!-- never called -->
		<jsp:forward page="<%=strPageForwardPrintSummary%>"/>
	<%	}else if(strTemp.equals("2")){%>
		<jsp:forward page="<%=strPageForwardPrintPerMonth%>"/>
	<%}
	}
	utility.DBOperation dbOP = new utility.DBOperation();
	
	Vector vCOAList = null;
	Accounting.Report.ReportGeneric RG = new Accounting.Report.ReportGeneric();
	
	if(WI.fillTextValue("coa_index").length() > 0) {
		vCOAList = RG.getGLCOABatch(dbOP, request);
		if(vCOAList == null)
			strErrMsg = RG.getErrMsg();
	}
	dbOP.cleanUP();
%>
<body bgcolor="#D2AE72" onLoad="ShowHideAsOfDate();">
<form name="form_" method="post" action="./gl_1st_page.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          GENERAL LEDGER REPORT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-weight:bold; color:#FF0000">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(strSchCode.startsWith("DBTC")){%>
   <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2" valign="top" style="font-weight:bold; font-size:11px; color:#0000FF">
	  <input type="checkbox" name="batch_print" value="checked" <%=WI.fillTextValue("batch_print")%> onChange="PrintBatchClicked();"> Print in Batch
	  </td>
      <td>&nbsp;</td>
    </tr>
<%}%>
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="20%" valign="top"><label id="_name">Account Number </label></td>
      <td width="21%" valign="top"><input name="coa_index" type="text" size="20" maxlength="32" value="<%=WI.fillTextValue("coa_index")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeyUp="MapCOAAjax('0');"></td>
      <td width="55%">
	  	<%if(strSchCode.startsWith("DBTC")){%>
			<input type="submit" value="Show List of Chart of Account to Print" onClick="document.form_.print_pg.value='';document.form_.print_stat.value=''">
		<%}%>
		
	  <label id="coa_info" style="font-size:11px;"></label>
	  </td>
    </tr>
    
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Show report for</td>
      <td colspan="2"><select name="jv_date" onChange="document.form_.print_pg.value='';document.form_.submit();">
        <option value="1">Specific Date</option>
        <%
strTemp = WI.fillTextValue("jv_date");
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
        <!--<option value="2"<%=strErrMsg%>>Date Range</option>-->
        <%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
        <option value="3"<%=strErrMsg%>>Monthly</option>
        <%
if(strTemp.equals("4"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
        <option value="4"<%=strErrMsg%>>Yearly</option>
      </select>
	  &nbsp;&nbsp;&nbsp;
	  <label id="asofdate" style="font-weight:bold; font-size:11px; color:#0000FF"><input type="checkbox" name="as_of_date" checked>As of Date</label>

<%if(false){%>
	<input type="checkbox" name="show_book_type" value="checked" <%=WI.fillTextValue("show_book_type")%>> Show Book Type in report
<%}%>	  
<%
if(true){%>
	<input type="checkbox" name="show_addl_info_wup" value="checked" <%=WI.fillTextValue("show_addl_info_wup")%>> Show Payee Name, Check Number, Explanation
<%}%>	  

</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="3">
	  <%
strTemp = (String)request.getParameter("report_type");
if(strTemp == null)
	strTemp = "1";
	
if(strTemp.equals("1")) 
	strErrMsg = " checked";
else
	strErrMsg = " checked";
%>
	  <input name="report_type" type="radio" value="1"<%=strErrMsg%>> Detailed 
<%
if(strTemp.equals("0")) 
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
<!--      <input name="report_type" type="radio" value="0"<%=strErrMsg%>> Summary -->
<%
if(strTemp.equals("2")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
      <input name="report_type" type="radio" value="2"<%=strErrMsg%>> Summary Per Month (new)		</td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><%
strTemp = WI.fillTextValue("jv_date");	
int iTemp = Integer.parseInt(WI.getStrValue(strTemp, "1"));
if(iTemp == 2){%>  
	  From 
<%}if(iTemp == 1 || iTemp == 2){
strTemp = WI.fillTextValue("jv_date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);%>
        <input name="jv_date_fr"  type="text" size="11" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
        <a href="javascript:show_calendar('form_.jv_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
<%}if(iTemp == 2){%>
        &nbsp;&nbsp;To 
        <input name="jv_date_to"  type="text" size="11" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("jv_date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
        <a href="javascript:show_calendar('form_.jv_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
<%}if(iTemp == 3){%>
		<select name="jv_month">
			<%=dbOP.loadComboMonth(WI.fillTextValue("jv_month"))%>
        </select>
<%}if(iTemp >2) {%>
	    <select name="jv_year">
			<%=dbOP.loadComboYear(WI.fillTextValue("jv_year"),5,1)%>
        </select>
<%}%></td>
    </tr>
    <tr> 
      <td height="26" colspan="4"><hr size="1"></td>
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
			strErrMsg = "";
		%>
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
  </table>
<%if(vCOAList != null && vCOAList.size() > 0) {
int iCount = 1;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="49%" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
				<tr bgcolor="#CCCCCC" align="center" style="font-weight:bold">
					<td width="2%" class="thinborder">Count</td>
					<td width="30%" class="thinborder">Account Code</td>
					<td width="60%" class="thinborder">Account Name</td>
					<td width="15%" class="thinborder">Select (ALL) <br>
					<input type="checkbox" name="sel_all0" onClick="SelAll('0')"></td>
				</tr>
				<%for(int i = 0; i < vCOAList.size(); i += 4, iCount += 2) {%>
					<tr>
						<td class="thinborder"><%=iCount%>.</td>
						<td class="thinborder"><%=vCOAList.elementAt(i)%></td>
						<td class="thinborder"><%=vCOAList.elementAt(i + 1)%></td>
						<td class="thinborder" align="center"><input type="checkbox" name="sel_<%=iCount%>" value="<%=vCOAList.elementAt(i)%>"></td>
					</tr>
				<%}%>
			</table>	
		</td>
		<td width="2%">&nbsp;</td>
		<td width="49%" valign="top">
		<%if(vCOAList.size() > 2) {iCount = 2;%>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
				<tr bgcolor="#CCCCCC" align="center" style="font-weight:bold">
					<td width="2%" class="thinborder">Count</td>
					<td width="30%" class="thinborder">Account Code</td>
					<td width="60%" class="thinborder">Account Name</td>
					<td width="15%" class="thinborder">Select (ALL) <br>
					<input type="checkbox" name="sel_all1" onClick="SelAll('1')"></td>
				</tr>
				<%for(int i = 2; i < vCOAList.size(); i += 4, iCount += 2) {%>
					<tr>
						<td class="thinborder"><%=iCount%>.</td>
						<td class="thinborder"><%=vCOAList.elementAt(i)%></td>
						<td class="thinborder"><%=vCOAList.elementAt(i + 1)%></td>
						<td class="thinborder" align="center"><input type="checkbox" name="sel_<%=iCount%>" value="<%=vCOAList.elementAt(i)%>"></td>
					</tr>
				<%}%>
			</table>	
		<%}%>
		</td>
	<tr>
  </table>
<input type="hidden" name="max_disp" value="<%=vCOAList.size()/2%>">
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_pg">
  <input type="hidden" name="print_stat">
  
  <!-- added for income statement computation -->
<input type="hidden" name="fiscal_yr" value="1">
<input type="hidden" name="year_" value="<%=WI.fillTextValue("year_")%>">
<input type="hidden" name="title_index" value="1"><!-- income statement title -->

</form>
</body>
</html>
