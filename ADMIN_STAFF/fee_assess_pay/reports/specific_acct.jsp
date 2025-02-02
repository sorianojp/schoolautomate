<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//remove all fee from list.
function ClearAll() {
	document.specific_fee.list_count.value = 0;
	ReloadPage();
}
function ChangeFeeCatg()
{
	//document.specific_fee.list_count.value = 0;
	ReloadPage();
}
function RemoveFeeName(removeIndex)
{
	document.specific_fee.remove_index.value = removeIndex;
	ReloadPage();
}
function ReloadPage()
{
	document.specific_fee.print_pg.value = "";
	document.specific_fee.submit();
}
function AddFeeName()
{
	document.specific_fee.add_fee.value = "1";
	document.specific_fee.list_count.value = ++document.specific_fee.list_count.value;
	ReloadPage();
}
function PrintPg() {
	document.specific_fee.print_pg.value = "1";
	document.specific_fee.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.FeeExtraction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

if(WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="./specific_acct_print.jsp" />
<%return;
}	
	String strErrMsg = null;
	String strTemp = null;

	int iListCount = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","specific_acct.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"specific_acct.jsp");
**/
//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}


FeeExtraction FE = new FeeExtraction();
double dTotalAmount  = 0d;
String strSYIndex = dbOP.mapOneToOther("FA_SCHYR","sy_from",WI.fillTextValue("sy_from"),"sy_index", " and sy_to = "+WI.fillTextValue("sy_to"));
String[] astrConvertToSem = {"SUMMER", "1ST SEM","2ND SEM","3RD SEM"};
%>
<form name="specific_fee" action="./specific_acct.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SPECIFIC FEE COLLECTION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
<%
if(false){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="27%">
<%
strTemp = WI.fillTextValue("load_save_report");
if(strTemp.compareTo("0") ==0)
	strTemp = "checked";
else
	strTemp = "";
%>
	  <input type="radio" name="load_save_report" value="0" <%=strTemp%> onClick="ReloadPage();">
        Load Save Report Layout</td>
      <td width="70%">
<%//default value;
if(strTemp.length() ==0)
	strTemp = "checked";
else
	strTemp = "";
%>	  <input type="radio" name="load_save_report" value="1" <%=strTemp%> onClick="ReloadPage();">
        Create New Report Layout</td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%}//for now do not show.

if(WI.fillTextValue("load_save_report").compareTo("0") ==0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td>Report Layout :
        <select name="select3">
        </select></td>
    </tr>
    <tr>
      <td height="25" colspan="2"><hr size="1"></td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom">SY-Term: 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("specific_fee","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        : 
        <select name="semester" style="font-size:11px;">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>        <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>&nbsp;
	    <font style="font-size:10px; color:#0000FF; font-weight:bold">NOTE : This is a Projection not actual</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom">Fee Category</td>
    </tr>
    <%
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="32%"> <select name="fee_catg" onChange="ChangeFeeCatg();" style="font-size:11px">
          <option value="0">&lt;Miscellaneous fees&gt;</option>
          <%
strTemp = WI.fillTextValue("fee_catg");
if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>&lt;Other Charges&gt;</option>
          <%}else{%>
          <option value="3">&lt;Other Charges&gt;</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>&lt;Other School Fees&gt;</option>
          <%}else{%>
          <option value="1">&lt;Other School Fees&gt;</option>
          <%}if(strTemp.compareTo("ROTC") ==0){%>
          <option value="ROTC" selected>ROTC</option>
          <%}else{%>
          <option value="ROTC">ROTC</option>
          <%}if(strTemp.compareTo("TUITION FEE") == 0){%>
          <option value="TUITION FEE" selected>TOTAL TUITION FEE</option>
          <%}else{%>
          <option value="TUITION FEE" >TOTAL TUITION FEE</option>
          <%}if(strTemp.compareTo("MISC FEE") == 0){%>
          <option value="MISC FEE" selected>TOTAL MISC FEE</option>
          <%}else{%>
          <option value="MISC FEE" >TOTAL MISC FEE</option>
          <%}if(strTemp.compareTo("OTHER CHARGES") == 0){%>
          <option value="OTHER CHARGES" selected>TOTAL OTHER CHARGES</option>
          <%}else{%>
          <option value="OTHER CHARGES" >TOTAL OTHER CHARGES</option>
          <%}%>
        </select> </td>
      <td><select name="fee_name" style="font-size:11px">
          <%
if(strTemp.compareTo("0") ==0 || strTemp.length() ==0){//misc fee%>
          <%=dbOP.loadCombo("distinct fee_name","fee_name"," from fa_misc_fee where IS_DEL=0 and is_valid=1 and MISC_OTHER_CHARGE=0"+
		  " and sy_index = "+strSYIndex+" order by fa_misc_fee.fee_name",WI.fillTextValue("fee_name"), false)%> 
          <%}else if(strTemp.compareTo("3") ==0){//other charges %>
          <%=dbOP.loadCombo("distinct fee_name","fee_name"," from fa_misc_fee where IS_DEL=0 and is_valid=1 and MISC_OTHER_CHARGE=1"+
		  " and sy_index = "+strSYIndex+" order by fa_misc_fee.fee_name",WI.fillTextValue("fee_name"), false)%> 
          <%}else if(strTemp.compareTo("1") ==0){//other sch fee %>
          <%=dbOP.loadCombo("distinct fee_name","fee_name"," from FA_OTH_SCH_FEE where IS_DEL=0 and is_valid=1 "+
		  " and sy_index = "+strSYIndex+" order by FA_OTH_SCH_FEE.fee_name",WI.fillTextValue("fee_name"), false)%> 
          <%}else if(strTemp.compareTo("2") ==0){//school facility fee%>
          <%=dbOP.loadCombo("distinct fee_name","fee_name"," from FA_SCH_FACILITY where IS_DEL=0 and is_valid=1 "+
		  " and sy_index = "+strSYIndex+" order by FA_SCH_FACILITY.fee_name",WI.fillTextValue("fee_name"), false)%> 
          <%}else if(strTemp.compareTo("ROTC") ==0){%>
          <option value="ROTC">ROTC</option>
          <%}else if(strTemp.compareTo("TUITION FEE") == 0){%>
          <option value="TOTAL TUITION FEE">TOTAL TUITION FEE</option>
          <%}else if(strTemp.compareTo("MISC FEE") == 0){%>
          <option value="TOTAL MISC FEE">TOTAL MISC FEE</option>
          <%}else if(strTemp.compareTo("OTHER CHARGES") == 0){%>
          <option value="TOTAL OTHER CHARGES">TOTAL OTHER CHARGES</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp; <a href="javascript:AddFeeName();"><img src="../../../images/add.gif" width="40" height="32" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="middle"><a href="javascript:ClearAll();"><img src="../../../images/clear.gif" border="0"> 
        </a>Click here to remove all entries</td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0"  cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="12%">Date</td>
      <td width="50%">From
        <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('specific_fee.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;to
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('specific_fee.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td width="35%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp; </td>
      <td align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print </font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292" align="center"><font color="#FFFFFF" size="1"><strong>LIST
          OF FEE COLLECTIONS AND COLLECTED AMOUNT <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]+", "+WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%>
		   <%=WI.fillTextValue("date_from")%>
          <%
		if(WI.fillTextValue("date_to").length() > 0)
		{%>
          to <%=WI.fillTextValue("date_to")%>
          <%}%>
          </strong></font></td>
    </tr>
    <tr>
      <td width="68%" height="25"><div align="center"><strong><font size="1">FEE
          TYPE </font></strong></div></td>
      <td width="19%" align="center"><strong><font size="1">AMOUNT</font></strong></td>
      <td width="13%" align="center"><strong><font size="1">REMOVE FROM LIST</font></strong></td>
    </tr>
<%
strErrMsg = null;

Vector vUniqueFee = new Vector();String strFee = null;//this is fee already calculated.

Double dTemp = null;

int iRemoveIndex    = Integer.parseInt(WI.getStrValue(WI.fillTextValue("remove_index"),"-1"));

int iCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("list_count"),"0"));
for(int i=0; i<iCount; ++i)
{
	strFee = null;
	
	if(i == iRemoveIndex)
		continue;
	if( i == iCount -1 && WI.fillTextValue("add_fee").length() > 0)
		strTemp = WI.fillTextValue("fee_name");
	else {
		strTemp = WI.fillTextValue("fee_name"+i);
		strFee  = WI.fillTextValue("fee_amt"+i);
	}
	if(vUniqueFee.indexOf(strTemp) != -1)
		continue;
	
	if(strFee == null)
		dTemp = FE.getSpecificFeeCollected(dbOP,strTemp,WI.fillTextValue("fee_catg"), WI.fillTextValue("date_from"),
								   WI.fillTextValue("date_to"), WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), 
								   WI.fillTextValue("semester"));
	else	
		dTemp = new Double(WI.getStrValue(strFee,"0"));
		
	if(dTemp == null)
	{
		strErrMsg = FE.getErrMsg();
		break;
	}
	dTotalAmount += dTemp.doubleValue();
	%>
	<input type="hidden" name="fee_name<%=iListCount%>" value="<%=strTemp%>">
	<input type="hidden" name="fee_amt<%=iListCount%>" value="<%=dTemp.doubleValue()%>">

		<tr>
		  <td height="25"><%=strTemp%></td>

      <td align="right"><%=CommonUtil.formatFloat(dTemp.doubleValue(),true)%>&nbsp;&nbsp;&nbsp;</td>
		  <td align="center"><a href='javascript:RemoveFeeName("<%=iListCount%>");'><img src="../../../images/delete.gif" border="0"></a></td>
		</tr>
	<%
	//add here to list, it is safe now.
	++iListCount;
	vUniqueFee.addElement(strTemp);
}%>
    <tr>
      <td height="25" align="right"><strong><font size="1">TOTAL</font></strong></td>
      <td align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%>&nbsp;&nbsp;&nbsp;</strong></td>
      <td>&nbsp;</td>
    </tr>
<%
if(strErrMsg != null){%>
<tr>
      <td height="25" colspan="3"><font size="3"><%=strErrMsg%></font></td>
    </tr>
<%}%>

  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom"><%if(false){%>Report Name<%}%></td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="31%" height="25"> 
<%if(false){%>
<input name="report_name" type="text" size="32" value="<%=WI.fillTextValue("report_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%}%>	  </td>
      <td width="47%" height="25">
<%if(false){%>
	  <font size="1"><a href="javascript:SaveReport();"><img src="../../../images/save.gif" border="0"></a>click
        to save report layout</font>
<%}%>		</td>
      <td width="19%" height="25" colspan="3"><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
          to print </font></font></div></td>
    </tr>

<%}//show only if sy/term information exists.
%>
    <tr>
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="list_count" value="<%=iListCount%>">
<input type="hidden" name="remove_index">
<input type="hidden" name="add_fee">
<input type="hidden" name="print_pg">
<input type="hidden" name="total_amt" value="<%=dTotalAmount%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
