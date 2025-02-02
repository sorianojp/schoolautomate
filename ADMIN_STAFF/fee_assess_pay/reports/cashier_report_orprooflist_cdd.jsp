<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
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
	if(document.daily_cash.emp_id.value.length ==0){
		alert("Please enter employee ID.");
		return;
	}
	if(document.daily_cash.date_of_col.value.length ==0) {
		alert("Please enter date of collection.");
		return;
	}
	//I have to call here the print page.
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	
	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
	document.getElementById('myADTable5').deleteRow(0);
	document.getElementById('myADTable5').deleteRow(0);
	
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
<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0" bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;String strTemp = null;

	Vector vTuitionFee      = null;
	Vector vSchFacDeposit   = null;
	Vector vRemittance      = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cashier_report_orprooflist_cdd.jsp");
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
														"cashier_report_orprooflist_cdd.jsp");
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

vEmployeeInfo = auth.operateOnBasicInfo(dbOP, request,"0");
if(vEmployeeInfo == null)
	strErrMsg = auth.getErrMsg();
else if(WI.fillTextValue("date_of_col").length() > 0 && WI.fillTextValue("emp_id").length() > 0)
{
	vCollectionInfo  =
		DC.viewDailyCashCollectionDtlsPerTellerORProofList(dbOP,request.getParameter("date_of_col"), (String)vEmployeeInfo.elementAt(0),request);
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
if(strSchCode == null)
	strSchCode = "";

boolean bolIsCLDH      = strSchCode.startsWith("CLDH");
boolean bolIsAUF       = strSchCode.startsWith("AUF");
boolean bolIsVMA       = strSchCode.startsWith("VMA");
if(strSchCode.startsWith("CSA"))
	bolIsAUF = true;
boolean bolIsPHILCST   = strSchCode.startsWith("PHILCST");
boolean bolIsDBTC      = strSchCode.startsWith("DBTC");


strTemp = WI.fillTextValue("show_con");
boolean bolShowOnlyCreditCard = strTemp.equals("1");
boolean bolShowOnlyEPay       = strTemp.equals("2");
boolean bolShowALL            = strTemp.equals("0");
if(strTemp.length() == 0) 
	bolShowALL = true;

Vector vModifiedBy      = new Vector();
if(strSchCode.startsWith("FATIMA") && vCollectionInfo != null) {
	String strSQLQuery = "select or_number, fname, mname, lname,modify_reason from fa_stud_payment "+
	"join user_table on (user_table.user_index = fa_stud_payment.modified_by) "+
	" where fa_stud_payment.is_valid = 1 and date_paid ";
	if(WI.fillTextValue("date_of_col").length() > 0) {
		if(WI.fillTextValue("date_to").length() > 0) {
			strSQLQuery += " between '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_of_col"))+
			"' and '"+	ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_to"))+"' ";
		}
		else {
			strSQLQuery += " = '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_of_col"))+"' ";
		}
	}
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vModifiedBy.addElement(rs.getString(1));
		vModifiedBy.addElement(WebInterface.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4));
	}
	rs.close();
}
%>

<form name="daily_cash" method="post" action="./cashier_report_orprooflist_cdd.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          DAILY CASH COLLECTION PAGE - OR PROOF LIST::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=strErrMsg%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">Employee ID&nbsp; </td>
      <td width="18%" height="25">
<%
strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("userId");
if(strTemp == null)
	strTemp = "";
%>
	  <input name="emp_id" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="67%"><input type="image" src="../../../images/form_proceed.gif" onClick="ReloadPage();"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date Of Collection </td>
      <td height="25"><font size="1">
        <%
strTemp = WI.fillTextValue("date_of_col");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_of_col" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_of_col');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">OR Range to Print </td>
      <td height="25" colspan="2"><input name="or_fr" type="text" size="16" value="<%=WI.fillTextValue("or_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        - 
        <input name="or_to" type="text" size="16" value="<%=WI.fillTextValue("or_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  
	  
	  		<input type="checkbox" name="all_teller" value="checked" <%=WI.fillTextValue("all_teller")%>> Include All Teller


</td>
    </tr>
	<tr>
      <td colspan="4" height="19"><hr size="1"></td>
    </tr>
  </table>
<%
 if(vEmployeeInfo != null && vEmployeeInfo.size() >0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr> 
      <td  width="2%" height="26">&nbsp;</td>
      <td height="26" colspan="2">Employee Name :<strong> <%=WI.formatName((String)vEmployeeInfo.elementAt(1),(String)vEmployeeInfo.elementAt(2),(String)vEmployeeInfo.elementAt(3),1)%></strong></td>
      <td width="31%" height="26">Employment Status : <strong><%=WI.getStrValue((String)vEmployeeInfo.elementAt(16))%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Job Title/Position : <strong><%=(String)vEmployeeInfo.elementAt(15)%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="26%">&nbsp;</td>
      <td width="41%">&nbsp;</td>
      <td height="25"><div align="right"> 
	  <%
	  if(vTuitionFee != null && vTuitionFee.size() > 0) {%>
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
          to print daily cash collection report</font> 
      <%}%>    <!--
	  <a href="javascript:CashCounting();"><img src="../../../images/cash_count.gif" border="0"></a><font size="1">click
          to encode/view cash counting for this collection</font>-->
        </div></td>
    </tr>
    <tr> 
      <td height="18" colspan="4"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
<%
if(vCollectionInfo != null && vCollectionInfo.length > 0 && vTuitionFee != null && vTuitionFee.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
<%if(strSchCode.startsWith("AUF")){%>
		<td width="31%" align="right">&nbsp;<img src="../../../images/logo/AUF_PAMPANGA.gif" width="100" height="100"></td>
<%}%>
      <td width="45%" align="center"> <font size="2"> <strong>
	  			<%=SchoolInformation.getSchoolName(dbOP,true,false)%>
	  </strong><br>
          <font size="1"><i><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false),",","","")%></i></font></font>
		  <br>
		  <font style="font-family:'Century Gothic'"><strong>ACCOUNTING AND FINANCE OFFICE
		  <br><br>
		  DAILY CASH COLLECTION DETAILED REPORT
		  </strong></font>
	  </td>
<%if(strSchCode.startsWith("AUF")){%>
		  <td width="24%">&nbsp;</td>
<%}%>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr >
    <td height="20" colspan="2" ><div align="center">DATE : <strong><%=WI.fillTextValue("date_of_col")%>
	<%if(WI.fillTextValue("date_to").length() > 0) {%>
		to <%=WI.fillTextValue("date_to")%>
	<%}
	if(WI.fillTextValue("or_fr").length() > 0) {%>
		- For OR Range <%=WI.fillTextValue("or_fr")%> to <%=WI.fillTextValue("or_to")%>
	<%}%>
	</strong></div></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr >
    <td width="48%" height="20" ><%if(WI.fillTextValue("all_teller").length() == 0) {%>Teller ID:<strong> <%=WI.fillTextValue("emp_id")%></strong><%}%></td>
    <td width="52%" height="20" >&nbsp;</td>
  </tr>
  <tr >
    <td height="20" ><%if(WI.fillTextValue("all_teller").length() == 0) {%>
		Name of Teller : <strong><%=WI.formatName((String)vEmployeeInfo.elementAt(1),(String)vEmployeeInfo.elementAt(2),(String)vEmployeeInfo.elementAt(3),1)%></strong>
	<%}%>
	</td>
    <td height="20" ><div align="right">&nbsp;Date/ Time Printed : <%=WI.getTodaysDateTime()%></div></td>
  </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#CCCCCC"> 
      <td height="25" colspan="10" class="thinborder"><div align="center"><strong>COLLECTION 
          ACCOUNTED AS FOLLOWS</strong></div></td>
    </tr>
 </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
   <tr> 
      <td width="4%" class="thinborder"><div align="center"><font size="1"><strong>S.L #</strong></font></div></td>
<%if(bolIsPHILCST || bolIsDBTC){%>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>PAYMENT DATE</strong></font></div></td>
<%}%>
      <td width="9%" height="25" class="thinborder"><div align="center"><font size="1"><strong><%if(strSchCode.startsWith("CIT")){%>T.R/<%}%>O.R. NUMBER</strong></font></div></td>
      <td width="12%" align="center" class="thinborder"><font size="1"><strong>STUDENT NO.</strong></font></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>NAME OF STUDENT/PAYEE</strong></font></div></td>
      <td width="15%" class="thinborder"><font size="1"><strong>FEE PARTICULARS</strong></font></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">COURSE CODE</font></strong></div></td>
      <td width="7%" class="thinborder" align="center"><strong><font size="1">TUITION</font></strong></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">RLE</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">OTHERS</font></strong></div></td>
   </tr>
<%
String[] astrConvertPmtType = {"Cash","Chk","CA", "","", "","Credit Card","E-Pay"};
String strTotalCol   = (String)vTuitionFee.remove(0);
String strCashCol    = (String)vTuitionFee.remove(0);
String strChkCol     = (String)vTuitionFee.remove(0);
String strCAdvCol    = (String)vTuitionFee.remove(0);
String strEPay       = (String)vTuitionFee.remove(0);
String strCreditCard = (String)vTuitionFee.remove(0);

Vector vFeeSummary   = new Vector(); 
int iIndexOf         = 0;
int iCount           = 0;
double dFeeAmount    = 0d;
int iTotalCollection = 0;

double dTuitionCol = 0d;
int iTuitionCount  = 0;



String strStudIDPrev = null;
boolean bolIsSamePayee = false;//System.out.println(vTuitionFee);

boolean bolIsCancelled = false;//only for cldh.. 
String strStrikeThru   = null;//strike thru' if OR is cancelled.

double dTuition = 0d;
double dRLE     = 0d;
double dOthers  = 0d;


for(int i = 0,j=1; i < vTuitionFee.size(); i +=12,++j ){


///to indicate cancelled OR for CLDH.
if(bolIsCLDH && WI.getStrValue(vTuitionFee.elementAt(i + 3)).equals("0.00")) {
	bolIsCancelled = true;
	strStrikeThru =" style='text-decoration:line-through;'";
}
else {	
	bolIsCancelled = false;
	strStrikeThru  = "";
}


//if(strStudIDPrev == null || !strStudIDPrev.equals(WI.getStrValue(vTuitionFee.elementAt(i + 7)))) {
//	bolIsSamePayee = false;
//	strStudIDPrev = WI.getStrValue(vTuitionFee.elementAt(i + 7));
//}
//else	
//	bolIsSamePayee = true;
	%>
   <tr> 
      <td class="thinborder" >&nbsp;<%=j%></td>
<%if(bolIsPHILCST || bolIsDBTC){%>
      <td class="thinborder"><%=vTuitionFee.elementAt(i + 11)%></td>
<%}%>
      <td height="20" class="thinborder"><%=(String)vTuitionFee.elementAt(i + 1)%></td>
      <td class="thinborder">
	  <%if(bolIsSamePayee || bolIsCancelled){%>&nbsp;<%}else{%>
	  <%=WI.getStrValue((String)vTuitionFee.elementAt(i + 7),"&nbsp;")%><%}%></td>
      <td class="thinborder"><%if(bolIsCancelled){%>
	  	<font style="color:#FF0000; font-size:9px; font-weight:bold;">Cancelled</font>
	  <%}else if(bolIsSamePayee){%>&nbsp;<%}else{%>
	  <%=WI.getStrValue((String)vTuitionFee.elementAt(i + 2),"&nbsp;")%><%}%></td>
      <td class="thinborder"><%
	  strTemp = WI.getStrValue((String)vTuitionFee.elementAt(i + 5),"&nbsp;");
	  	dTuition = 0d;
		dRLE     = 0d;
		dOthers  = 0d;
		%>
		<%=strTemp%>
		<%
	  if(vTuitionFee.elementAt(i+6) != null){
	  	strTemp = (String)vTuitionFee.elementAt(i+6);
	  	if(strTemp.startsWith("Application/Entrance/Reservation"))
	  		strTemp = "Appl/Entrance/Res. "+strTemp.substring(34);%>
      (<%=strTemp%>)
      <%}
	  //for CDD here. 
		dFeeAmount = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vTuitionFee.elementAt(i + 3),"0"), ", ", ""));
		if(strTemp.startsWith("Back Account") || strTemp.equals("Tuition")) {
	  		dTuition = dFeeAmount;
			dRLE     = 0d;
			dOthers  = 0d;
		}
		else if(strTemp.indexOf("RLE") > -1) {
	  		dTuition = 0d;
			dRLE     = dFeeAmount;
			dOthers  = 0d;
		}
		else {
	  		dTuition = 0d;
			dRLE     = 0d;
			dOthers  = dFeeAmount;
		}
	  	strTemp = (String)(String)vTuitionFee.elementAt(i + 5);
	  	if(vTuitionFee.elementAt(i+6) != null)
	  		strTemp = (String)vTuitionFee.elementAt(i+6);
		if(dFeeAmount <= 0d)
			strTemp = null;
			
	  	if(strTemp != null) {
		  
		  if(strTemp.equals("Tuition")) {
		  	dTuitionCol += dFeeAmount;
			++iTuitionCount;
		  }
		  else {//save in fee detail 		
		
			  iIndexOf = vFeeSummary.indexOf(strTemp);
			  if(iIndexOf == -1) {
				vFeeSummary.addElement(strTemp);
				vFeeSummary.addElement("1");
				vFeeSummary.addElement(Double.toString(dFeeAmount));
				++iTotalCollection;
			  }
			  else {
				iCount = Integer.parseInt((String)vFeeSummary.elementAt(iIndexOf + 1));
				++iCount;++iTotalCollection;
				dFeeAmount += Double.parseDouble((String)vFeeSummary.elementAt(iIndexOf + 2));
				
				vFeeSummary.setElementAt(Integer.toString(iCount), iIndexOf + 1);
				vFeeSummary.setElementAt(Double.toString(dFeeAmount), iIndexOf + 2);
			  }
	  	  }	
		}  
	  %></td>
      <td class="thinborder"><%if(bolIsSamePayee || bolIsCancelled){%>&nbsp;<%}else{%><%=WI.getStrValue((String)vTuitionFee.elementAt(i + 10),"&nbsp;")%><%}%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTuition, true)%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dRLE, true)%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dOthers, true)%></tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="25%" height="25">&nbsp;</td>
      <td width="50%">&nbsp;</td>
      <td width="25%">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td align="center">
<%if(strSchCode.startsWith("CDD")){%>
		  <table cellpadding="0" cellspacing="0" class="thinborderALL" width="100%">
<%if(dTuitionCol > 0d) {%>
			  <tr> 
				<td width="75%" class="thinborderNONE"> Tuition Fee(<%=iTuitionCount%>) </td>
				<td width="2%" align="right" class="thinborderNONE">&nbsp;:</td>
				<td width="23%" align="right" class="thinborderNONE"><%=CommonUtil.formatFloat(dTuitionCol, true)%>&nbsp;</td>
			  </tr>
<%}for(int i =0; i < vFeeSummary.size(); i += 3) {%>
			  <tr> 
				<td width="75%" class="thinborderNONE"> <%=vFeeSummary.elementAt(i)%>(<%=vFeeSummary.elementAt(i + 1)%>)  </td>
				<td width="2%" align="right" class="thinborderNONE">&nbsp;:</td>
				<td width="23%" align="right" class="thinborderNONE"><%=CommonUtil.formatFloat((String)vFeeSummary.elementAt(i + 2), true)%>&nbsp;</td>
			  </tr>
<%}%>
			  <tr> 
				<td width="75%" class="thinborderNONE"> <strong>Total Collection(<%=iTuitionCount + iTotalCollection%>)</strong> </td>
				<td width="2%" align="right" class="thinborderNONE">&nbsp;:</td>
				<td width="23%" align="right" class="thinborderNONE"><strong><%=strTotalCol%></strong>&nbsp;</td>
			  </tr>
		  </table>
<%}else{%>	  
		  <table cellpadding="0" cellspacing="0" class="thinborderALL" width="100%">
	<%if(bolShowALL){%>
			  <tr> 
				<td width="46%"> Total Cash Payments</td>
				<td width="13%" align="right">&nbsp;:</td>
				<td width="41%" align="right"><%=strCashCol%>&nbsp;</td>
			  </tr>
			  <tr> 
				<td>Total Check Payment</td>
				<td align="right">:</td>
				<td align="right"><%=strChkCol%>&nbsp;</td>
			  </tr>
	<%}if(bolIsAUF){
	if(bolShowOnlyCreditCard || bolShowALL){%>
			  <tr>
				<td>Total Credit Card Payment </td>
				<td align="right">:</td>
				<td align="right"><%=strCreditCard%>&nbsp;</td>
			  </tr>
	<%}if(bolShowOnlyEPay || bolShowALL){%>
			  <tr>
				<td>Total E-Pay Payment </td>
				<td align="right">:</td>
				<td align="right"><%=strEPay%>&nbsp;</td>
			  </tr>
	<%}
	}if(strCAdvCol != null && strCAdvCol.compareTo("0.00") != 0) {%>
			  <tr> 
				<td>Total Cash Advance</td>
				<td align="right">:</td>
				<td align="right"><%=strCAdvCol%>&nbsp;</td>
			  </tr>
	<%}%>
			  <tr> 
				<td>Total Collection</td>
				<td align="right">:</td>
				<td align="right"><%=strTotalCol%>&nbsp;</td>
			  </tr>
			  <tr> 
				<td>&nbsp;</td>
				<td colspan="2" align="right">&nbsp;</td>
			  </tr>
		</table>
<%}//don ot show if CDD%>		
	  </td>
      <td>&nbsp;</td>
    </tr>
  </table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><div align="left">
	  <!--<a href="javascript:CashCounting();"><img src="../../../images/cash_count.gif" border="0"></a><font size="1">click
          to encode/view cash counting for this collection --><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click
          to print daily cash collection report</font></font></div></td>
      <td width="1%" height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>

<%
//System.out.println(vFeeSummary);
//System.out.println(CommonUtil.formatFloat(dTuitionCol, true));
//System.out.println(iTuitionCount);

}//if collection information is not null.
//only if vEmployeeInfo is not null
}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<%if(vEmployeeInfo != null && vEmployeeInfo.size() > 0){%>
 <input type="hidden" name="teller_index" value="<%=(String)vEmployeeInfo.elementAt(0)%>">
<%}%>
<input type="hidden" name="view_report">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>