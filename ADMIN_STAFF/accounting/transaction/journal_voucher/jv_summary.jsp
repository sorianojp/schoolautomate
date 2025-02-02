<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/td.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function ShowVoucherDetail(strJVNumber, strJVType) {
	var pgLoc = "./journal_voucher_entry.jsp?jv_number="+escape(strJVNumber)+"&is_cd="+
		document.form_.is_cd.value+"&jv_type="+strJVType;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function jvTypeChanged() {
	var iSelectedIndex = document.form_.jv_type.selectedIndex;
	if(iSelectedIndex >= 2)
		document.getElementById("gjv_crj").innerHTML = "";
	else {
		document.getElementById("gjv_crj").innerHTML = 
			"<input type='checkbox' name='gjv_crj' value='checked'> Show only GJV created for Bank Deposit from CRJ";
	}
		
}
</script>

<body onLoad="document.form_.jv_number.focus();" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
<%@ page language="java" import="utility.*,Accounting.Search,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
boolean bolIsCD = false;
if(WI.fillTextValue("is_cd").equals("1")) {
	response.sendRedirect("../cash_disbursement/cd_summary.jsp");
	return;
}

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Accounting","jv_summary.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Voucher No.","Voucher Date","Date Posted"};
String[] astrSortByVal     = {"jv_number","jv_date","lock_date"};

int iSearchResult = 0;

Search search = new Search(request);
if(WI.fillTextValue("search_page").compareTo("1") == 0){
	vRetResult = search.searchJV(dbOP);
	if(vRetResult == null)
		strErrMsg = search.getErrMsg();
	else
		iSearchResult = search.getSearchCount();
}


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsTsuneishi = strSchCode.startsWith("TSUNEISHI");
%>
<form method="post" action="./jv_summary.jsp" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          <%if(bolIsCD){%>DISBURSEMENT<%}else{%>JOURNAL VOUCHER<%}%> SUMMARY PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; color:#0000FF; font-weight:bold"><!--
  	  <a href="<%if(bolIsCD){%>../cash_disbursement/cash_disbursement.jsp<%}else{%>./journal_voucher.jsp<%}%>"><img src="../../../../images/go_back.gif" border="0"></a>--><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="14%" class="thinborderNONE">Voucher Number</td>
      <td width="30%"><select name="jv_number_con" style="font-size:10px;">
        <%=search.constructGenericDropList(WI.fillTextValue("jv_number_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
      <input name="jv_number" type="text" size="12" maxlength="32" value="<%=WI.fillTextValue("jv_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';"></td>
      <td width="11%" class="thinborderNONE">Status </td>
      <td width="42%"><select name="is_locked">
	  <option value=""></option>
<%
strTemp = WI.fillTextValue("is_locked");
if(strTemp.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>           <option value="0"<%=strErrMsg%>><%if(bolIsCD){%>With Cashier<%}else{%>Not Posted<%}%></option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>         <option value="1"<%=strErrMsg%>><%if(bolIsCD){%>Released<%}else{%>Posted<%}%></option>

      </select></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td class="thinborderNONE">Voucher Date</td>
      <td> <select name="jv_date" onChange="document.form_.submit();">
          <option value="1">Specific Date</option>
<%
strTemp = WI.fillTextValue("jv_date");
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>          <option value="2"<%=strErrMsg%>>Date Range</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>          <option value="3"<%=strErrMsg%>>Monthly</option>
<%
if(strTemp.equals("4"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>          <option value="4"<%=strErrMsg%>>Yearly</option>
        </select></td>
      <td class="thinborderNONE"><%if(bolIsCD){%>Released Date<%}else{%>Posted Date<%}%></td>
      <td class="thinborderNONE">From
        <input name="jv_posted_fr"  type="text" size="11" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("jv_posted_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
        <a href="javascript:show_calendar('form_.jv_posted_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        &nbsp;&nbsp;To
        <input name="jv_posted_to"  type="text" size="11" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("jv_posted_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
        <a href="javascript:show_calendar('form_.jv_posted_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>		</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td class="thinborderNONE">Voucher Type </td>
      <td colspan="3">
	  	<select name="jv_type" onChange="jvTypeChanged();">
			<option value="">ALL</option>
<%
strTemp = WI.fillTextValue("jv_type");
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
			<option value="0"<%=strErrMsg%>>General Journal</option>
<%
if(strTemp.equals("4"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
			<option value="4"<%=strErrMsg%>>CRJ</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
			<option value="3"<%=strErrMsg%>>ARJ</option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
			<option value="1"<%=strErrMsg%>>Scholarship</option>
<%
if(strTemp.equals("12"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
			<option value="12"<%=strErrMsg%>>APJ</option>
		</select>	  
		<label id='gjv_crj' style="visibility:visible; font-size:11px; font-weight:bold; color:#FF9966">
			<input type="checkbox" name="gjv_crj" value="checked" <%=WI.fillTextValue("gjv_crj")%>>
			Show only GJV created for Bank Deposit from CRJ
		</label>
		</td>
    </tr>

    <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3" class="thinborderNONE">
<%
strTemp = WI.fillTextValue("jv_date");
int iTemp = Integer.parseInt(WI.getStrValue(strTemp, "1"));
if(iTemp == 2){%>
	  From
<%}if(iTemp == 1 || iTemp == 2){%>
        <input name="jv_date_fr"  type="text" size="11" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("jv_date_fr")%>" class="textbox"
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
<%}%>		</td>
    </tr>
<!--
    <tr>
      <td height="26">&nbsp;</td>
      <td>Charged to</td>
      <td colspan="3">&nbsp;</td>
    </tr>
-->
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom" class="thinborderNONE"><strong><u>SORT</u></strong> </td>
      <td height="25" colspan="3" valign="bottom"><font style="font-size:11px; font-weight:bold; color:#0000FF">
        <input type="checkbox" name="show_empty" value="checked" <%=WI.fillTextValue("show_empty")%>>
        Show vouchers without any information created<br>
		<%if(bolIsCD){%>
		<input type="checkbox" name="show_nocheck" value="checked" <%=WI.fillTextValue("show_nocheck")%>> Show Voucher without  check information
		<br>
		<input type="checkbox" name="show_cancelled" value="checked" <%=WI.fillTextValue("show_cancelled")%>> Include Cancelled CDs
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="checkbox" name="show_only_cancelled" value="checked" <%=WI.fillTextValue("show_only_cancelled")%>> Show only cancelled CDs
		<%}%>
		</font>		</td>
    </tr>
    <tr>
      <td height="38">&nbsp;</td>
      <td height="38" colspan="4">1.)
        <select name="sort_by1" style="font-size:10px">
<%=search.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
        </select>
        <select name="sort_by1_con" style="font-size:10px">
          <option value="asc">Asc</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
          <%}else{%>
          <option value="desc">Desc</option>
          <%}%>
        </select>
        2.)
        <select name="sort_by2" style="font-size:10px">
		 	<option value="">N/A</option>
<%=search.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
        </select>
        <select name="sort_by2_con" style="font-size:10px">
          <option value="asc">Asc</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
          <%}else{%>
          <option value="desc">Desc</option>
          <%}%>
        </select>
        3.)
        <select name="sort_by3" style="font-size:10px">
		 	<option value="">N/A</option>
<%=search.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
        </select>
        <select name="sort_by3_con" style="font-size:10px">
          <option value="asc">Asc</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
          <%}else{%>
          <option value="desc">Desc</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="38"><div align="center"><font size="1"></font></div></td>
      <td height="38">&nbsp;</td>
      <td height="38" colspan="3" valign="bottom"><font size="1"><a href="../../../../ADMIN_STAFF/accounting/transaction/petty_cash/petty_cash.htm"></a>
          <input type="submit" name="12" value=" Search <%if(bolIsCD){%>CD<%}else{%>JV<%}%> " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		   onClick="document.form_.search_page.value='1'">
      </font></td>
    </tr>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
    <tr>
      <td height="26" colspan="5"><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>click to PRINT Summary List</font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="5" class="thinborder" style="font-size:11px; font-weight:bold" align="center">
	  :: <%if(bolIsCD){%>DISBURSEMENT<%}else{%>JOURNAL VOUCHER<%}%> SUMMARY :: </td>
    </tr>
    <tr>
      <td height="23" colspan="4" class="thinborder"><font size="1"><strong>TOTAL VOUCHER(S) : <%=search.getSearchCount()%></strong></font><strong></strong></td>
      <td height="23" style="font-size:9px;" align="right" class="thinborder">Date and time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
    <tr>
      <td width="10%" height="25" class="thinborder"><div align="center"><font size="1"><strong>VOUCHER NO.</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>VOUCHER DATE</strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">STATUS</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">DATE POSTED</font></strong></div></td>
      <td width="53%" class="thinborder"><div align="center"><strong><font size="1">EXPLANATION(S)</font></strong></div></td>
    </tr>
<%
String strAddBr = null;
boolean bolIsCancelled = false;

for(int i = 0; i < vRetResult.size(); i += 8){
strTemp = (String)vRetResult.elementAt(i);
strAddBr = "";
if(vRetResult.elementAt(i + 7).equals("0"))
	bolIsCancelled = true;
else
	bolIsCancelled = false;
%>
    <tr valign="top" <%if(bolIsCancelled){%> bgcolor="#DDDDDD"<%}%>>
      <td height="25" class="thinborder"><%if(!bolIsCancelled){%>
	  	<a href="javascript:ShowVoucherDetail('<%=vRetResult.elementAt(i)%>','<%=vRetResult.elementAt(i + 4)%>');" style="text-decoration:none; color:#000000"><%}%><%=vRetResult.elementAt(i)%><%if(!bolIsCancelled){%></a><%}%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%if(vRetResult.elementAt(i + 2).equals("1")){%>Posted<%}%>&nbsp;</td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3), "&nbsp;")%></td>
      <td class="thinborder">
	  <%for(; i < vRetResult.size(); i += 7) {
	  	if(!strTemp.equals(vRetResult.elementAt(i))) {
			i -= 7;
			break;
		}%>
	  	<%=strAddBr%><%if(!bolIsTsuneishi){//do not show number.%><%=vRetResult.elementAt(i + 5)%>. <%}%><%=WI.getStrValue(vRetResult.elementAt(i + 6))%>
	  <%strAddBr = "<br>";}%>
	  </td>
    </tr>
<%}//for loop..
}//end of if(vRetResult not null;./. %>
  </table>
<input type="hidden" name="search_page">
<input type="hidden" name="is_cd" value="<%=WI.getStrValue(WI.fillTextValue("is_cd"),"0")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
