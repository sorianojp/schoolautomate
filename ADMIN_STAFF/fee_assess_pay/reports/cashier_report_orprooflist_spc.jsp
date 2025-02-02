<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
 }
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function CashCounting()
{
	var todayDate = document.daily_cash.date_of_col.value;
	var empID     = document.daily_cash.emp_id.value;
	if(todayDate.length ==0)
	{
		alert("Please enter Cash collection date");
		return;
	}
	if(todayDate.length ==0)
	{
		alert("Please enter Cash collection date");
		return;
	}
	var pgLoc = "./cash_counting.jsp?emp_id="+escape(empID)+"&date_of_col="+escape(todayDate);
	var win=window.open(pgLoc,"EditWindow",'width=950,height=700,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	return;
}
function PrintPg() {
//	if(document.daily_cash.emp_id.value.length ==0){
//		alert("Please enter employee ID.");
//		return;
//	}
	if(document.daily_cash.date_of_col.value.length ==0) {
		alert("Please enter date of collection.");
		return;
	}
	//I have to call here the print page.
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);

	
	
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.


}
function ViewReport() {
	document.daily_cash.view_report.value = 1;
}
function ReloadPage() {
	document.daily_cash.view_report.value = "";
}
</script>
<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;String strTemp = null;

	Vector vTuitionFee      = null;
	Vector vSchFacDeposit   = null;
	Vector vRemittance      = null;
	
	Vector vUnEarnedTuition = new Vector();
	double dUnEarned = 0d;
	double dARStudent = 0d;
	double dCashTotal = 0d;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cashier_report_orprooflist_spc.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"cashier_report_orprooflist_spc.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(),
														"cashier_report_summary.jsp");
}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vEmployeeInfo = null;
Authentication auth = new Authentication();
DailyCashCollection DC = new DailyCashCollection();
Vector[] vCollectionInfo = null;

String strTellerIndex = "";
String strAllTeller   = "";

vEmployeeInfo = auth.operateOnBasicInfo(dbOP, request,"0");

if(WI.fillTextValue("date_of_col").length() > 0 && WI.fillTextValue("view_report").length() > 0) {
	
	strTellerIndex = request.getParameter("teller_index");
	if(vEmployeeInfo != null && vEmployeeInfo.size() > 0){
		strAllTeller = "";
		strTellerIndex = (String)vEmployeeInfo.elementAt(0);
	}else
		strAllTeller = "1";

	vCollectionInfo  =
		DC.viewDailyCashCollectionDtlsPerTellerORProofList(dbOP,request.getParameter("date_of_col"),strTellerIndex,request);
	if(vCollectionInfo == null)
		strErrMsg = DC.getErrMsg();
}

if(vCollectionInfo != null)
{
	vTuitionFee      = vCollectionInfo[0];
	vSchFacDeposit   = vCollectionInfo[1];
	vRemittance      = vCollectionInfo[2];
}

if(strErrMsg == null) 
	strErrMsg = "";
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String strInfo5 = (String)request.getSession(false).getAttribute("info5");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsCLDH      = strSchCode.startsWith("CLDH");
if(strSchCode.startsWith("SPC"))
	bolIsCLDH = true;


Vector vTellerName    = new Vector();
if(vCollectionInfo != null) {
	if(WI.fillTextValue("date_of_col").length() > 0) {
		strTemp = "";
		if(WI.fillTextValue("date_to").length() > 0) {
			strTemp = " between '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_of_col"))+
			"' and '"+	ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_to"))+"' ";
		}
		else {
			strTemp += " = '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_of_col"))+"' ";
		}
	}
	String strSQLQuery = "select or_number, fname from fa_stud_payment join user_table on (user_Table.user_index = fa_stud_payment.created_by) "+
					" where fa_stud_payment.is_valid = 1 and date_paid ";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery+strTemp);
	while(rs.next()) {
		vTellerName.addElement(rs.getString(1));
		vTellerName.addElement(rs.getString(2).toLowerCase());
	}
	rs.close();
}
%>

<form name="daily_cash" method="post" action="./cashier_report_orprooflist_spc.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td height="25" colspan="2" align="center" style="font-size:12px;" valign="bottom" class="thinborderBOTTOM"><strong>:::: DAILY CASH COLLECTION PAGE - OR PROOF LIST ::::</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=strErrMsg%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%" height="25">Employee ID&nbsp; </td>
      <td height="25" colspan="3">
<%
strTemp = WI.fillTextValue("emp_id");

%>
	  <input name="emp_id" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  <font size="1">Leave empty for all teller</font>
	  </td>
    </tr>
	<tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="3" height="25">Date of collection: <font size="1"> 
<%
strTemp = WI.fillTextValue("date_of_col");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>        <input name="date_of_col" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_of_col');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        to
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>


		</font>
		
		
		&nbsp;
		<input type="checkbox" name="all_teller" value="checked" <%=WI.fillTextValue("all_teller")%>> Include All Teller
		</td>
      <td width="29%">&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="25" colspan="3" align="right"><input name="image" type="image" src="../../../images/form_proceed.gif" onClick="ViewReport();"></td>
      <td width="40%" align="right" style="font-size:11px;">
	  Rows Per Page: 	
	  <select name="no_of_rows" style="font-size:11px;">
	  <option value="">ALL In one page</option>
<%
int iDef = Integer.parseInt(WI.getStrValue(WI.fillTextValue("no_of_rows"), "46"));
	
for(int i = 20; i < 75; i += 2) {
	if(iDef == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
		<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>	  </td>
      <td height="25"><div align="right"> 
	  <%
	  if(vTuitionFee != null && vTuitionFee.size() > 0) {%>
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
          to print daily cash collection report</font> 
      <%}%>
        </div></td>
    </tr>
    <tr> 
      <td height="18" colspan="5"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
<%
if(vCollectionInfo != null && vCollectionInfo.length > 0 && vTuitionFee != null && vTuitionFee.size() > 0){
	int iPageNumber = 1; int iRowsPrinted = 0;
	
	/**
	String strTotalCol   = (String)vTuitionFee.remove(0);
	String strCashCol    = (String)vTuitionFee.remove(0);
	String strChkCol     = (String)vTuitionFee.remove(0);
	String strCAdvCol    = (String)vTuitionFee.remove(0);
	String strEPay       = (String)vTuitionFee.remove(0);
	String strCreditCard = (String)vTuitionFee.remove(0);
	**/
	vTuitionFee.remove(0);vTuitionFee.remove(0);vTuitionFee.remove(0);
	vTuitionFee.remove(0);vTuitionFee.remove(0);vTuitionFee.remove(0);
	
	int iIndexOf         = 0;
	int iCount           = 0;
	String strStudIDPrev = null;

	boolean bolIsSamePayee = false;//System.out.println(vTuitionFee);
	
	boolean bolIsCancelled = false;//only for cldh.. 
	String strStrikeThru   = null;//strike thru' if OR is cancelled.

for(int i = 0,j=1; i < vTuitionFee.size();){
	iRowsPrinted = 1;
	if(i > 0) {%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="92%" align="center" style="font-weight:bold">
	  	SAN PEDRO COLLEGE <br> Davao City<br>
	  	<br>
		 COLLECTION FOR PERIOD <br>
		 <font style="font-weight:normal">
		  DATE: <%=WI.fillTextValue("date_of_col")%>
		<%if(WI.fillTextValue("date_to").length() > 0) {%>
			to <%=WI.fillTextValue("date_to")%>
		<%}%>
		</font>
	  </td>
      <td width="8%" valign="bottom" align="right">Page.: <%=iPageNumber++%>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr >
    <td width="48%" height="20" >&nbsp;</td>
    <td width="52%" height="20" ><div align="right">&nbsp;Date/ Time Printed : <%=WI.getTodaysDateTime()%></div></td>
  </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
   <tr style="font-weight:bold; font-style:italic"> 
      <td width="4%" class="thinborderTOPBOTTOM" height="25" style="font-size:9px;"><font size="1">S.L #</font></td>
      <td width="11%" class="thinborderTOPBOTTOM" style="font-size:9px;">Student ID </td>
      <td width="30%" class="thinborderTOPBOTTOM" style="font-size:9px;">Student Name </td>
      <td width="10%" class="thinborderTOPBOTTOM" style="font-size:9px;">Course-YR</td>
      <td width="10%" class="thinborderTOPBOTTOM" style="font-size:9px;">Date</td>
      <td width="10%" class="thinborderTOPBOTTOM" style="font-size:9px;">OR Number </td>
      <td width="10%" class="thinborderTOPBOTTOM" style="font-size:9px;" align="right"><font size="1">Amount</font></td>
      <td width="5%" class="thinborderTOPBOTTOM" style="font-size:9px;">&nbsp;</td>
      <td width="10%" class="thinborderTOPBOTTOM" style="font-size:9px;">Teller</td>
   </tr>
<%
for(; i < vTuitionFee.size(); i +=12,++j ){
	if(iRowsPrinted++ > iDef)
		break;



///to indicate cancelled OR for CLDH.
if(bolIsCLDH && WI.getStrValue(vTuitionFee.elementAt(i + 3)).equals("0.00")) {
	bolIsCancelled = true;
	strStrikeThru =" style='text-decoration:line-through;'";
}
else {	
	bolIsCancelled = false;
	strStrikeThru  = "";
}

iIndexOf = vTellerName.indexOf(vTuitionFee.elementAt(i + 1));
if(iIndexOf == -1)
	strTemp = "&nbsp;";
else {
	strTemp = (String)vTellerName.elementAt(iIndexOf + 1);
	vTellerName.remove(iIndexOf);
	vTellerName.remove(iIndexOf);
}
%>
   <tr> 
      <td height="18">&nbsp;<%=j%></td>
      <td>
	  <%if(bolIsSamePayee || bolIsCancelled){%>&nbsp;<%}else{%>
	  <%=WI.getStrValue((String)vTuitionFee.elementAt(i + 7),"&nbsp;")%><%}%>	  </td>
      <td>
	  <%if(bolIsCancelled && false){%>
	  	<font style="color:#FF0000; font-size:9px; font-weight:bold;">Cancelled</font>
	  <%}else if(bolIsSamePayee){%>&nbsp;<%}else{%>
	  <%=WI.getStrValue((String)vTuitionFee.elementAt(i + 2),"&nbsp;")%><%}%>	  </td>
      <td><%if(bolIsSamePayee || bolIsCancelled){%>&nbsp;<%}else{%><%=WI.getStrValue((String)vTuitionFee.elementAt(i + 10),"&nbsp;")%><%}%></td>
      <td><%=vTuitionFee.elementAt(i + 11)%></td>
      <td><%=(String)vTuitionFee.elementAt(i + 1)%></td>
      <td>
			<div align="right">
				<%if(bolIsCancelled) {%>
					<font style="color:#FF0000; font-size:9px; font-weight:bold;">Cancelled</font>
				<%}else{				
					strErrMsg = WI.getStrValue((String)vTuitionFee.elementAt(i + 3));				
					dCashTotal += Double.parseDouble(ConversionTable.replaceString(strErrMsg,",",""));%>
				<%=WI.getStrValue(strErrMsg,"&nbsp;")%><%}%></div></td>
      <td>&nbsp;</td>
      <td><%=strTemp%></td>
   </tr>
<%}
if(i + 12 >= vTuitionFee.size()){
%>

	<tr>
		<td colspan="5" height="18" align="right"><strong>TOTAL COLLECTION</strong></td>
		<td align="right" colspan="2"><strong>
			<div style="border-bottom:solid 1px #000000; border-top:solid 1px #000000; width:80%;"><%=CommonUtil.formatFloat(dCashTotal,  true)%></div></strong></td>
	</tr>
	<tr>
	    <td colspan="5" height="5" align="right"></td>
	    <td align="right" colspan="2"><div style="border-top:solid 1px #000000; width:80%;"></div></td>
	</tr>
<%}%>
  </table>
<%}//external loop%>
<%
}//if collection information is not null.
%>

<input type="hidden" name="teller_index" value="<%=strTellerIndex%>">


<input type="hidden" name="show_mpmt" value="1">
<input type="hidden" name="view_report">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>