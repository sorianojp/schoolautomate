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
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/td.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
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

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function ShowVoucherDetail(strJVNumber, strJVType) {
	var pgLoc = "../journal_voucher/journal_voucher_entry.jsp?jv_number="+escape(strJVNumber)+"&is_cd="+
		document.form_.is_cd.value+"&jv_type="+strJVType;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SelALL() {
	var bolIsSel = document.form_.sel_all.checked;
	var iMaxDisp = document.form_.max_disp.value;
	var objChkBox;
	for(i = 0; i < eval(iMaxDisp); ++i) {
		eval('objChkBox=document.form_.jvi_'+i)
		if(!objChkBox)
			continue;
		objChkBox.checked = bolIsSel;
	}
}
</script>

<body topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
<%@ page language="java" import="utility.*,Accounting.Search,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Accounting","batch_lock_voucher.jsp");
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
Vector vRetResult = new Vector();
String strSQLQuery = null;
java.sql.ResultSet rs = null;
int iMaxDisp = 0;

if(WI.fillTextValue("page_action").length() > 0) {
	if(WI.fillTextValue("lock_date").length() == 0) {
		strErrMsg = "Please enter Lock Date.";
	}
	else {
		iMaxDisp = Integer.parseInt(WI.fillTextValue("max_disp"));
		for(int i =0; i < iMaxDisp; ++i) {
			strTemp = WI.fillTextValue("jvi_"+i);
			if(strTemp.length() == 0) 
				continue;
			if(strSQLQuery == null)
				strSQLQuery = strTemp;
			else	
				strSQLQuery = strSQLQuery+","+strTemp;
		}
		if(strSQLQuery == null) 
			strErrMsg = "Please select atleast one record to lock.";
		else {
			strSQLQuery = "update ac_jv set is_locked =1, lock_date = '"+
							ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("lock_date"))+
							"' where jv_index in ("+strSQLQuery+")";
			if(dbOP.executeUpdateWithTrans(strSQLQuery, (String)request.getSession(false).getAttribute("login_log_index"), "AC_JV", true) > -1)
				strErrMsg = "Vouchers Locked.";
			else	
				strErrMsg = "Failed to lock voucher. Please try again.";
		}
	}
}

if(WI.fillTextValue("search_page").length() > 0) {
	if(WI.fillTextValue("date_fr").length() == 0 || WI.fillTextValue("date_to").length() == 0) {
		strErrMsg = "Please enter voucher date fr and to.";
	}
	else {
		strSQLQuery = WI.fillTextValue("is_cd");
		if(strSQLQuery.length() > 0) 
			strSQLQuery = " and is_cd = "+WI.fillTextValue("is_cd");
		
		strSQLQuery = "select ac_jv.jv_index, jv_number, jv_date, jv_type, is_cd, payee_name,debit_amt, credit_amt, EXPLANATION  from ac_jv "+
						" join ( "+
						" 	select sum(amount) as debit_amt, jv_index as jvi1 from ac_jv_dc where IS_DEBIT = 1 group by jv_index "+
						" ) as DT_DC1 on DT_DC1.jvi1 = jv_index "+
						" join ( "+
						" 	select sum(amount) as credit_amt, jv_index as jvi2 from ac_jv_dc where IS_DEBIT = 0 group by jv_index "+
						" ) as DT_DC2 on DT_DC2.jvi2 = jv_index "+
						" join AC_JV_DC_GROUP on (AC_JV_DC_GROUP.jv_index = ac_jv.jv_index) "+
						" where IS_LOCKED = 0  and lock_date is null and debit_amt = credit_amt and jv_date between '"+
						ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_fr"))+"' and '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_to"))+
						"' "+strSQLQuery+" order by is_cd, jv_type, jv_date";
		//System.out.println(strSQLQuery);
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vRetResult.addElement(rs.getString(1));//[0] jv_index
			vRetResult.addElement(rs.getString(2));//[1] jv_number
			vRetResult.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(3)));//[2] jv_date
			vRetResult.addElement(rs.getString(4));//[3] jv_type
			vRetResult.addElement(rs.getString(5));//[4] is_cd
			vRetResult.addElement(WI.getStrValue(rs.getString(6), "&nbsp;"));//[5] payee_name
			vRetResult.addElement(CommonUtil.formatFloat(rs.getDouble(7), true));//[6] debit_amt
			vRetResult.addElement(rs.getString(9));//[7] EXPLANATION
		}
		rs.close();
		if(vRetResult.size() == 0 && strErrMsg == null) 
			strErrMsg = "No Result found.";
	}
}
%>
<form method="post" action="./batch_lock_voucher.jsp" name="form_" onSubmit="SubmitOnceButton(this);">
 <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          BATCH LOCKING PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; color:#0000FF; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="14%" class="thinborderNONE">Voucher Type </td>
      <td width="30%">
	  <select name="is_cd">
	  <!--<option></option>-->
<%strTemp = WI.fillTextValue("is_cd");
if(strTemp.equals("1"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
		<option value="1" <%=strErrMsg%>>Disbursement Voucher</option>
<%
if(strTemp.equals("0"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
	  	<option value="0" <%=strErrMsg%>>General Journal</option>
	  </select>
	  
	  
	  </td>
      <td width="11%" class="thinborderNONE">&nbsp;</td>
      <td width="42%">&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td class="thinborderNONE">Voucher Date</td>
      <td>
From
        <input name="date_fr"  type="text" size="11" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        &nbsp;&nbsp;To
        <input name="date_to"  type="text" size="11" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>	  </td>
      <td class="thinborderNONE">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
    </tr>
    
    <tr>
      <td height="38"><div align="center"><font size="1"></font></div></td>
      <td height="38">&nbsp;</td>
      <td height="38" colspan="3" valign="bottom"><font size="1"><a href="../../../ADMIN_STAFF/accounting/transaction/petty_cash/petty_cash.htm"></a>
          <input type="submit" name="12" value=" Search Voucher" style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		   onClick="document.form_.search_page.value='1'">
      </font></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="7" class="thinborderBOTTOM" style="font-size:11px; font-weight:bold" align="center"> :: LIST OF VOUCHER(S) NOT YET LOCKED :: </td>
    </tr>
    <tr>
      <td height="23" colspan="6"><font size="1"><strong>TOTAL VOUCHER(S) : <%=vRetResult.size()/8%></strong></font></td>
      <td height="23" style="font-size:9px;" align="right">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="4%" class="thinborder"><font size="1">Count</font></td>
      <!--<td width="6%" class="thinborder"><font size="1">Voucher Type</font></td>-->
      <td width="8%" height="25" class="thinborder"><font size="1">Voucher Number </font></td>
      <td width="8%" class="thinborder"><font size="1">Voucher Date </font></td>
      <td width="8%" class="thinborder" style="font-size:9px;">Voucher Amount </td>
      <td width="22%" class="thinborder" style="font-size:9px;">Voucher Payee Name </td>
      <td width="45%" class="thinborder"><font size="1">Explanation(s)</font></td>
      <td width="5%" class="thinborder">Lock <br>
	  <input type="checkbox" name="sel_all" onClick="SelALL();">
	  </td>
    </tr>
<%
iMaxDisp = 0;
for(int i = 0; i < vRetResult.size(); i += 8,++iMaxDisp){%>
    <tr valign="top">
      <td class="thinborder"><%=iMaxDisp+1%></td>
      <!--<td class="thinborder"><%=strTemp%></td>-->
      <td height="18" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder" align="center"><input type="checkbox" name="jvi_<%=iMaxDisp%>" value="<%=vRetResult.elementAt(i)%>"></td>
    </tr>
<%}//for loop.%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="50">&nbsp;</td>
      <td width="10%" align="center">&nbsp;</td>
      <td width="76%" align="center" valign="bottom" style="font-size:18px;">
	  
	  <input type="submit" name="122" value="Post Verify Voucher" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='1';document.form_.search_page.value='1';">	  
		  
		  Date Posted (Lock Date):		  

<%
strTemp = WI.fillTextValue("lock_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
	  <input name="lock_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox" style="font-size:18px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">&nbsp;
      <a href="javascript:show_calendar('form_.lock_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  <img src="../../../images/calendar_new.gif" border="0"></a>

		  </td>
      <td width="13%" align="center">&nbsp;</td>
    </tr>
  </table>
<%}//end of if(vRetResult not null;./. %>
<input type="hidden" name="search_page">
<input type="hidden" name="page_action">
<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
