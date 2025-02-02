<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		//cancell is called.
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
		
		document.form_.check_no.value = "";
		document.form_.amount.value = "";
	}
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}
function AddCOA(strCOACF) {
	location = "./chart_of_account.jsp?coa_cf="+strCOACF;
}
function ConfirmDel(strInfoIndex) {
	if(confirm("Do you want to delete."))
		return this.PageAction('0',strInfoIndex);
}
function SelAll() {
	var maxDisp = document.form_.max_disp.value;
	if(!document.form_.sel_all.checked) {
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.check_box'+i+'.checked=false');
		return;
	}
	else {
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.check_box'+i+'.checked=true');
	}	

}
function PrintOSCheck() {
	var strDaily = document.form_.report_type[0].checked;
	var strURLCon = "";
	if(strDaily) {
		var strDateFr = document.form_.chk_date_fr.value;
		var strDateTo = document.form_.chk_date_to.value;
		if(strDateFr.length == 0) {
			alert("Must enter Check date FROM Value.");
			return;
		}
		strURLCon = "&chk_date_fr="+strDateFr+"&chk_date_to="+strDateTo;
	}	
	else {//monthly.
		strURLCon = "&jv_month="+document.form_.jv_month.selectedIndex+
					"&jv_year="+document.form_.jv_year[document.form_.jv_year.selectedIndex].value;
	}
	var strChkStat = document.form_.chk_stat.selectedIndex;
	var pgLoc = "./os_check_print.jsp?chk_stat="+strChkStat+"&bank_index="+
					document.form_.bank_index[document.form_.bank_index.selectedIndex].value+
					strURLCon;
	//alert(pgLoc);				
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

////called when show summary / detail is called. 
function ShowSummary() {//alert(document.form_.show_summary[0].checked);alert(document.form_.show_summary[1].checked);
	if(document.form_.show_summary[0].checked) {//detail..
		document.form_.bank_index.disabled = false;
		document.form_.check_no.disabled   = false;
		
		document.form_.chk_stat.disabled   = false;
	}
	else {
		document.form_.bank_index.disabled = true;	
		
		document.form_.check_no.value = "";
		document.form_.check_no.disabled   = true;
		
		document.form_.chk_stat.disabled   = true;
	}
}

function PrintSummary() {
	///remove the td
	document.bgColor = "#FFFFFF";
	
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	
	document.getElementById('myADTable4').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();
}
</script>

<body bgcolor="#D2AE72" onLoad="ShowSummary();">
<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","update_check_stat.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

JvCD jvCD = new JvCD();
Vector vRetResult = null;//all regarding check detail. 

if(WI.fillTextValue("page_action").length() > 0) {
	if(jvCD.operateOnCDCheck(dbOP, request, 5) == null) 
		strErrMsg = jvCD.getErrMsg();
	else
		strErrMsg = "Status of selected Checks updated.";
}
if(WI.fillTextValue("search_").length() > 0) {//search here.
	vRetResult = jvCD.operateOnCDCheck(dbOP, request, 6);
	if(vRetResult == null) 
		strErrMsg = jvCD.getErrMsg();
}

String strShowSummary = WI.fillTextValue("show_summary");
if(strShowSummary.length() == 0) 
	strShowSummary = "0";
%>
<form action="../../../transaction/ap/check_mgmt/update_check_stat.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          CHECK MANAGEMENT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:11px; font-weight:bold; color:#FF0000">
	  	<a href="../../cash_disbursement/cash_disbursement.jsp"><img src="../../../../../images/go_back.gif" border="0"></a>
			&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Report Type </td>
      <td colspan="2" style="font-size:9px">
<%
if(strShowSummary.equals("0"))
	strTemp = " checked";
else	
	strTemp = "";
%>	  
	  	<input type="radio" name="show_summary" value="0"<%=strTemp%> onClick="ShowSummary();"> Detail 
<%
if(strShowSummary.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>	  
	  	<input type="radio" name="show_summary" value="1"<%=strTemp%> onClick="ShowSummary();"> Summary
	  </td>
      <td style="font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Bank </td>
      <td colspan="2">	  	
	  <select name="bank_index" style="font-size:11px;">
<%=dbOP.loadCombo("bank_index","BANK_CODE +'('+ACCOUNT_NO+' ::: '+ac_coa.complete_code+')' as bcode"," from AC_COA_BANKCODE join ac_coa on (ac_coa.coa_index = ac_coa_bankcode.coa_index) where ac_coa_bankcode.is_valid = 1 order by bcode",WI.fillTextValue("bank_index"),false)%>			
	  </select></td>
      <td style="font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Report Format </td>
      <td colspan="3"><span style="font-size:11px;">
        <%
strTemp = WI.fillTextValue("report_type");
if(strTemp.length() == 0 || strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
        <input type="radio" value="0" name="report_type"<%=strErrMsg%> onClick="document.form_.submit();">
Daily/Date Range &nbsp;&nbsp;
<%
if(strTemp != null && strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
<input type="radio" value="1" name="report_type"<%=strErrMsg%> onClick="document.form_.submit();">
Monthly </span></td>
    </tr>
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td width="13%" style="font-size:11px;">Check #.</td>
      <td width="23%">
	  <input name="check_no" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("check_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="15%" align="right" style="font-size:11px;">Check Date &nbsp;&nbsp;&nbsp;</td>
      <td width="47%" style="font-size:11px;">
<%
strTemp = WI.fillTextValue("report_type");
if(strTemp.equals("0") || strTemp.length() == 0){%>
      <input name="chk_date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("chk_date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.chk_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>&nbsp; to &nbsp;&nbsp;
       <input name="chk_date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("chk_date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.chk_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>
<!-- show if selected per month -->
<%}else{%>
		<select name="jv_month">
			<%=dbOP.loadComboMonth(WI.fillTextValue("jv_month"))%>
        </select>
	    <select name="jv_year">
			<%=dbOP.loadComboYear(WI.fillTextValue("jv_year"),5,1)%>
        </select>
<%}%>		</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td style="font-size:11px;">Show </td>
      <td>
<%
strTemp = WI.fillTextValue("chk_stat");
%>
	  	<select name="chk_stat">
			<option value="0">Outstanding</option>
		<%
		strTemp = WI.fillTextValue("chk_stat");
		if(strTemp.equals("1"))
			strErrMsg = " selected";
		%>
			<option value="1"<%=strErrMsg%>>Cleared</option>
	  </select></td>
      <td><input type="submit" name="12" value=" Proceed >>" style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.search_.value='1'"></td>
      <td>
<%
//I have to show summary.. 
Vector vSummary = null;
if(vRetResult != null) {
	//System.out.println("Start of printing..");
	vSummary = jvCD.operateOnCDCheck(dbOP, request, 7);
	//System.out.println(vSummary);
	if(vSummary != null) {vSummary.removeElementAt(0);vSummary.removeElementAt(0);%>
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFaa" class="thinborderALL">
			<tr>
				<td align="center" bgcolor="#999966" class="thinborderBOTTOM" colspan="3"><strong>Quick Check Info</strong></td>
			</tr>
			<%if(vSummary.remove(2).equals("0")){%>
			<tr>
				<td width="24%" class="thinborderBOTTOM">Outstanding </td>
			    <td width="16%" class="thinborderBOTTOM"><%=vSummary.remove(1)%></td>
			    <td width="60%" align="right" class="thinborderBOTTOM"><%=vSummary.remove(0)%></td>
			</tr>
			<%}if(vSummary.size() > 0) {%>
			<tr>
				<td class="thinborderNONE">Cleared</td>
			    <td class="thinborderNONE"><%=vSummary.remove(1)%></td>
			    <td align="right" class="thinborderNONE"><%=vSummary.remove(0)%></td>
			</tr>
			<%}%>
		</table>	  
<%}//end of if vSummar is not null
}//end of vRetResult != null;%>
	  </td>
    </tr>
    
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%int iMaxDisp = 0;
if(vRetResult != null && vRetResult.size() > 0) {
vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);

if(strShowSummary.equals("1")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="myADTable4">
    <tr> 
      <td height="26" style="font-size:11px; " colspan="4" align="right" class="thinborder">
	  	<a href="javascript:PrintSummary();"><img src="../../../../../images/print.gif" border="0"></a>Print Summary</td>
    </tr>
    <tr> 
      <td height="26" style="font-size:11px; font-weight:bold;" colspan="4" align="center" class="thinborder">::: SUMMARY ::: 
	  <div align="right">Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;</div></td>
    </tr>
    <tr>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="15%">BANK CODE </td> 
      <td height="26" class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="35%">BANK NAME </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="15%"># OF CHECKS </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="35%">AMOUNT</td>
    </tr>
<%
String strChkStat = null;
String strChkStatToDisp = null;
double dSubTotal = 0d;

for(int i = 0; i < vRetResult.size(); i += 5){
if(strChkStat == null || !strChkStat.equals(vRetResult.elementAt(i + 4)) ) {
	strChkStat = (String)vRetResult.elementAt(i + 4);
	if(strChkStat.equals("0"))
		strChkStatToDisp = "Outstanding";
	else	
		strChkStatToDisp = "Cleared";	
}
else	
	strChkStatToDisp = null;

dSubTotal += Double.parseDouble((String)vRetResult.elementAt(i + 2));
if(strChkStatToDisp != null){%>
    <tr>
      <td height="26" colspan="4" class="thinborder" style="font-size:11px; font-weight:bold">&nbsp;&nbsp;&nbsp;<u><%=strChkStatToDisp%></u></td>
    </tr>
<%}%>
    <tr>
      <td class="thinborder"><%=vRetResult.elementAt(i)%></td> 
      <td height="26" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 2),true)%>&nbsp;</td>
    </tr>
<%if( (i + 6) > vRetResult.size() || !strChkStat.equals(vRetResult.elementAt(i + 4 + 5)) ){%>
    <tr>
      <td height="26" colspan="4" class="thinborder" align="right">Total : <%=CommonUtil.formatFloat(dSubTotal,true)%>&nbsp;</td>
    </tr>
<%dSubTotal = 0d;}//end of showing sub total.. 
	
}//end of for loop.. %>
  </table>
<%}//if show summary
else {//show detail. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="26" style="font-size:11px; " colspan="8" align="right" class="thinborder">
	  	<a href="javascript:PrintOSCheck();"><img src="../../../../../images/print.gif" border="0"></a>Print   Check List </td>
    </tr>
    <tr bgcolor="#999999"> 
      <td height="26" style="font-size:11px; font-weight:bold; color:#0000FF" colspan="8" align="center" class="thinborder">::: LIST OF CHECK 	::: </td>
    </tr>
    <tr>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="15%">ACCOUNT # </td> 
      <td height="26" class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="15%">BANK CODE </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="15%">CHECK # </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="15%">DATE</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%">CHECK STATUS </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%">AMOUNT</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%">SELECT
	  <br><input type="checkbox" name="sel_all" checked onClick="SelAll();"></td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%">NEW STATUS </td>
    </tr>
<%String[] astrConvertCheckStat = {"Outstanding","Cleared","Bounced"};
for(int i = 0; i < vRetResult.size(); i += 10){%>
    <tr>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td> 
      <td height="26" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=astrConvertCheckStat[Integer.parseInt((String)vRetResult.elementAt(i + 7))]%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(i + 4)%>&nbsp;</td>
      <td class="thinborder" align="center"> 
	  	<input type="checkbox" name="check_box<%=iMaxDisp%>" value="<%=vRetResult.elementAt(i)%>" checked></td>
      <td class="thinborder">
	  <select name="chk_stat<%=iMaxDisp%>" style="font-size:10px;">
        <option value="0">Outstanding</option>
        <%strErrMsg = "";
		strTemp = WI.fillTextValue("chk_stat"+iMaxDisp);//System.out.println(strTemp);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = " selected";
		%>
        <option value="1"<%=strErrMsg%>>Cleared</option>
      </select></td>
    </tr>
<%++iMaxDisp;}%>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="94%" height="25" align="center">
	  	<input type="submit" name="122" value=" Update Check status >>" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='6';"></td>
    </tr>
</table>
 <%}//end of showing detail.. 
 
}//if(vRetResult != null && vRetResult.size() > 0) {%>
 

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">

<input type="hidden" name="search_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>