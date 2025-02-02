<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../../jscript/td.js"></script>
<script language="javascript">
function ShowDetail(strPrintStat) {
	strCOANumber = document.form_.coa_index.value;
	if(strCOANumber.length == 0) {
		alert("Please enter chart of account number.");
		return;
	}
	document.form_.print_stat.value = strPrintStat;
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function MapCOAAjax(strIsBlur) {
		var objCOA;
		objCOA=document.getElementById("coa_info");
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strExtraCon = "";
		if(document.form_.show_header[0].checked)
			strExtraCon = " and account_type =0 ";
		else if(document.form_.show_header[1].checked)
			strExtraCon = " and (account_type=0 or exists(select * from AC_JV_DC where COA_INDEX = ac_coa.coa_index)) ";
		else if(document.form_.show_header[2].checked)
			strExtraCon = " and exists(select * from AC_JV_DC where COA_INDEX = ac_coa.coa_index) ";
			
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			document.form_.coa_index.value+"&coa_field_name=coa_index&is_blur="+strIsBlur+"&extra_con="+
			escape(strExtraCon);
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
</script>
<%@ page language="java" import="utility.WebInterface" %>
<%
	WebInterface WI  = new WebInterface(request);

	if(WI.fillTextValue("print_pg").length() > 0) {%>
		<jsp:forward page="./sched_of_account.jsp"/>
	<%}
	utility.DBOperation dbOP = new utility.DBOperation(-1);
	//dbOP.cleanUP();
	String strTemp   = null;
	String strErrMsg = null;
%>
<body bgcolor="#D2AE72" onLoad="ShowHideAsOfDate();">
<form name="form_" method="post" action="./sched_of_account_main.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          Schedule of Account ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="3">
<%
strTemp = WI.fillTextValue("show_header");
if(strTemp.length() == 0) 
	strTemp = "0";
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		  <input name="show_header" type="radio" value="1"<%=strErrMsg%>> Show Only Header 
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		  <input name="show_header" type="radio" value="2"<%=strErrMsg%>> Show ALL 
<%
if(strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		  <input name="show_header" type="radio" value="0"<%=strErrMsg%>> Show non-header	  </td>
    </tr>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";
if(strSchCode.startsWith("AUF")){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="3" style="font-size:10px; font-weight:bold; color:#0000FF">
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
      <td height="26">&nbsp;</td>
      <td colspan="3" style="font-size:9px; font-weight:bold">
<%
strTemp = WI.fillTextValue("jv_only");
if(strTemp.equals("0"))
	strErrMsg = " checked";
else
	strErrMsg = "";
if(request.getParameter("jv_only") == null)
	strErrMsg = " checked";
%>
	  <input type="radio" name="jv_only" value="0" <%=strErrMsg%>> Show CD Only Information.
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
	  <input type="radio" name="jv_only" value="1" <%=strErrMsg%>> Show JV Only Information.
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
	  <input type="radio" name="jv_only" value="2" <%=strErrMsg%>> CD + JV mixed.	  </td>
    </tr>
<%}%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Academic Year </td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0 && request.getParameter("coa_index") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
	  <input type="text" name="sy_from" value="<%=WI.getStrValue(strTemp)%>" maxlength="4" size="5"></td>
      <td>Order by 
<%
strTemp = WI.fillTextValue("order_by");
if(strTemp.length() > 0) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input name="order_by" type="radio" value="jv_number"<%=strErrMsg%>> Voucher #
<%
if(strTemp.length() == 0) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input name="order_by" type="radio" value=""<%=strErrMsg%>> Voucher Date (Default)	  </td>
    </tr>
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="15%" valign="top">Account </td>
      <td width="26%" valign="top"><input name="coa_index" type="text" size="20" maxlength="32" value="<%=WI.fillTextValue("coa_index")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeyUp="MapCOAAjax('0');"></td>
      <td width="55%"><label id="coa_info" style="font-size:11px;">
	  <input type="checkbox" name="show_explanation" value="checked" <%=WI.fillTextValue("show_explanation")%>>
	  Show Particular(Explanation) </label></td>
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
        <option value="2"<%=strErrMsg%>>Date Range</option>
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
        <!--<option value="4"<%=strErrMsg%>>Yearly</option>-->
      </select></td>
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
        <a href="javascript:show_calendar('form_.jv_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>
        <%}if(iTemp == 2){%>        &nbsp;&nbsp;To 
        <input name="jv_date_to"  type="text" size="11" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("jv_date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
        <a href="javascript:show_calendar('form_.jv_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>
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
