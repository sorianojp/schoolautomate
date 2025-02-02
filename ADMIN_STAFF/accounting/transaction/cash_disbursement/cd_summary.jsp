<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) {%>
	<p style="font-size:14px; color:#FF0000; font-weight:bold">You are already logged out. Please login again.</p>
<%return;}%>
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
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function ShowVoucherDetail(strJVNumber, strJVType) {
	var pgLoc = "../journal_voucher/journal_voucher_entry.jsp?jv_number="+escape(strJVNumber)+"&is_cd="+
		document.form_.is_cd.value+"&jv_type="+strJVType;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Accounting","cd_summary.jsp");
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
	vRetResult = search.searchCD(dbOP);
	if(vRetResult == null)
		strErrMsg = search.getErrMsg();
	else
		iSearchResult = search.getSearchCount();
}

boolean bolIsWNU = strSchCode.startsWith("WNU");
bolIsWNU = true;
boolean bolIsTsuneishi = strSchCode.startsWith("TSUNEISHI");
%>
<form method="post" action="./cd_summary.jsp" name="form_" onSubmit="SubmitOnceButton(this);">
 <input type="hidden" name="is_cd" value="1">
 <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          DISBURSEMENT SUMMARY PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; color:#0000FF; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
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
%>           <option value="0"<%=strErrMsg%>>Not Posted</option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>         <option value="1"<%=strErrMsg%>>Posted/Locked</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>         <option value="2"<%=strErrMsg%>>For Liquidation</option>

      </select>

	  <a href="../../reports/bank_adjustments/update_check_stat.jsp?search_cc=1&show_cancelled=checked"> Go to search Cancelled Check</a>

	  </td>
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
      <td class="thinborderNONE">Released Date</td>
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
    <tr>
      <td height="26">&nbsp;</td>
      <td class="thinborderNONE">Payee Name(Voucher) </td>
      <td colspan="3">
	  <select name="payee_name_cd" style=" width:400px; font-size:10px;" onChange="document.form_.payee_name.value=document.form_.copy_pn[document.form_.copy_pn.selectedIndex].value">
	  <option value=""> - - - - - - - - - - - - - - - - - - - - - - - - - - - - Any - - - - - - - - - - - - - - - - - - - - - - - - - - - -</option>
<%=dbOP.loadCombo("distinct payee_name","PAYEE_NAME"," from AC_JV where IS_CD = 1 order by AC_JV.payee_name", WI.fillTextValue("payee_name_cd"), false)%>
        </select>		</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td class="thinborderNONE">Payee Name(Check) </td>
      <td colspan="3">
	  <select name="payee_name_chk" style=" width:400px; font-size:10px;" onChange="document.form_.payee_name.value=document.form_.copy_pn[document.form_.copy_pn.selectedIndex].value">
        <option value="">- - - - - - - - - - - - - - - - - - - - - - - - - - - - Any - - - - - - - - - - - - - - - - - - - - - - - - - - - -</option>
        <%=dbOP.loadCombo("distinct payee_name","PAYEE_NAME"," from AC_CD_CHECK_DTL order by AC_CD_CHECK_DTL.payee_name", WI.fillTextValue("payee_name_chk"), false)%>
      </select>
	  <font style="font-size:11px;">
	  Check# (starts with): 
	  <input name="chk_no_con" type="text" size="7" maxlength="32" value="<%=WI.fillTextValue("chk_no_con")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';">
	  </font>
	  </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td class="thinborderNONE">Voucher Amount </td>
      <td colspan="3"> Between
	  <input name="amount1" type="text" size="12" maxlength="32" value="<%=WI.fillTextValue("amount1")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount1');style.backgroundColor='white'"
	   		onKeyUp="AllowOnlyFloat('form_','amount1');">
			and
			<input name="amount2" type="text" size="12" maxlength="32" value="<%=WI.fillTextValue("amount2")%>" class="textbox"
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount2');style.backgroundColor='white'"
	   		onKeyUp="AllowOnlyFloat('form_','amount2');"></td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom" class="thinborderNONE"><strong><u>SORT</u></strong> </td>
      <td height="25" colspan="3" valign="bottom"><font style="font-size:11px; font-weight:bold; color:#0000FF">
		
        <input type="checkbox" name="show_empty" value="checked" <%=WI.fillTextValue("show_empty")%>>
        Show vouchers without any information created<br>
		<input type="checkbox" name="show_nocheck" value="checked" <%=WI.fillTextValue("show_nocheck")%>> Show Voucher without  check information
		<br>
		<input type="checkbox" name="show_cancelled" value="checked" <%=WI.fillTextValue("show_cancelled")%>> Include Cancelled CDs
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="checkbox" name="show_only_cancelled" value="checked" <%=WI.fillTextValue("show_only_cancelled")%>> Show only cancelled CDs
<%
strTemp= WI.fillTextValue("show_chk_amt");
if(strSchCode.startsWith("SWU") && request.getParameter("show_chk_amt") == null)
	strTemp = " checked";
%>
		<input type="checkbox" name="show_chk_amt" value="checked" <%=strTemp%>> Show Check Amont as Voucher Amount
		</font>
		
		</td>
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
          <input type="submit" name="12" value=" Search Voucher" style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		   onClick="document.form_.search_page.value='1'">
      </font></td>
    </tr>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
    <tr>
      <td height="26" colspan="5"><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>click to PRINT Summary List</font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="7" class="thinborderBOTTOM" style="font-size:11px; font-weight:bold" align="center"> :: DISBURSEMENT SUMMARY :: </td>
    </tr>
    <tr>
      <td height="23" colspan="6"><font size="1"><strong>TOTAL VOUCHER(S) : <%=search.getSearchCount()%></strong></font><strong></strong></td>
      <td height="23" style="font-size:9px;" align="right">Date and time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="9%" height="25" class="thinborder"><font size="1">Voucher Number </font></td>
      <td width="9%" class="thinborder"><font size="1">Voucher Date </font></td>
      <td width="9%" class="thinborder"><font size="1">Date Posted </font></td>
      <%if(bolIsWNU){%>
      <td width="6%" class="thinborder"><font size="1">Check Release Date </font></td>
      <td width="6%" class="thinborder" style="font-size:9px;">Check Number </td>
      <td width="9%" class="thinborder" style="font-size:9px;">Voucher Amount </td>
      <td width="15%" class="thinborder" style="font-size:9px;">Voucher Payee Name </td>
      <%}%>
      <td width="43%" class="thinborder"><font size="1">Explanation(s)</font></td>
    </tr>
<%
String strAddBr = null;
boolean bolIsCancelled = false;
//System.out.println(vRetResult.size());
for(int i = 0; i < vRetResult.size(); i += 11){
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
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3), "&nbsp;")%></td>
<%if(bolIsWNU){%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 2), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 10), "&nbsp;")%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(WI.getStrValue(vRetResult.elementAt(i + 8), "0;"), true)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 9), "&nbsp;")%></td>
<%}%>
      <td class="thinborder">
	  <%for(; i < vRetResult.size(); i += 11) {
	  	if(!strTemp.equals(vRetResult.elementAt(i))) {
			i -= 11;
			break;
		}%>
	  	<%=strAddBr%><%if(!bolIsTsuneishi){//do not show number.%><%=vRetResult.elementAt(i + 5)%>. <%}%><%=WI.getStrValue(vRetResult.elementAt(i + 6))%>
	  <%strAddBr = "<br>";}%>	  </td>
    </tr>
<%}//for loop..
}//end of if(vRetResult not null;./. %>
  </table>
<input type="hidden" name="search_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
