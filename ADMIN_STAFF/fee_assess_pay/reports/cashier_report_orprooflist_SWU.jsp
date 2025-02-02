<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
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


function AjaxMapName() {
		var strCompleteName = document.daily_cash.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.daily_cash.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	
	document.daily_cash.view_report.value = 1;
	document.daily_cash.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0" bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;String strTemp = null;
	java.sql.ResultSet rs = null;
	Vector vTuitionFee       = null;
	Vector vSchFacDeposit   = null;
	Vector vRemittance      = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cashier_report_orprooflist.jsp");
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
														"cashier_report_orprooflist.jsp");
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

String strTellerNo = null;
Vector vEmployeeInfo = null;
Authentication auth = new Authentication();
DailyCashCollection DC = new DailyCashCollection();
Vector[] vCollectionInfo = null;
if(WI.fillTextValue("emp_id").length() > 0)
	vEmployeeInfo = auth.operateOnBasicInfo(dbOP, request,"0");
if(vEmployeeInfo == null)
	strErrMsg = auth.getErrMsg();
else if(WI.fillTextValue("date_of_col").length() > 0 && WI.fillTextValue("view_report").length() > 0)
{
	String strDatePaid = ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_of_col"));

	if(strDatePaid != null && WI.getStrValue(vEmployeeInfo.elementAt(0)).length() > 0){
		strTemp = "select teller_no from FA_TELLER_NO where is_valid = 1 "+
			" and FA_TELLER_NO.VALID_FROM <= '"+strDatePaid+"' and FA_TELLER_NO.VALID_TO >= '"+strDatePaid+
			"' and USER_INDEX = "+(String)vEmployeeInfo.elementAt(0);
		strTellerNo = dbOP.getResultOfAQuery(strTemp, 0);
	}

	vCollectionInfo  =
		DC.viewDailyCashCollectionDtlsPerTellerORProofList(dbOP,request.getParameter("date_of_col"),
			(String)vEmployeeInfo.elementAt(0),request);
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
if(strSchCode.startsWith("CSA"))
	bolIsAUF = true;
boolean bolIsPHILCST   = strSchCode.startsWith("PHILCST");
boolean bolIsDBTC      = strSchCode.startsWith("DBTC");

%>

<form name="daily_cash" method="post" action="./cashier_report_orprooflist_SWU.jsp">
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
      <td width="12%" height="25">Employee ID&nbsp; </td>
      <td width="19%" height="25">
<%
strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("userId");
if(strTemp == null)
	strTemp = "";
%>
	  <input name="emp_id" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"></td>
      <td width="67%"><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date of Collection </td>
      <td height="25">
<%
strTemp = WI.fillTextValue("date_of_col");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>        <input name="date_of_col" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_of_col');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 

	  </td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr> 
      <td>&nbsp;</td>
      <td width="26%">&nbsp;</td>
      <td width="41%"> <input name="image" type="image" src="../../../images/form_proceed.gif" onClick="ViewReport();"></td>
      <td><div align="right"> 
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
      <td colspan="4"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
<%
if(vCollectionInfo != null && vCollectionInfo.length > 0 && vTuitionFee != null && vTuitionFee.size() > 0){
String strTotalCol   = (String)vTuitionFee.remove(0);
String strCashCol    = (String)vTuitionFee.remove(0);
String strChkCol     = (String)vTuitionFee.remove(0);
String strCAdvCol    = (String)vTuitionFee.remove(0);
String strEPay       = (String)vTuitionFee.remove(0);
String strCreditCard = (String)vTuitionFee.remove(0);	
	
	
Vector vCancelledOR = new Vector();
Vector vTemp = new Vector(); //list of or canceled
strTemp = "select OR_NUMBER, OR_AMOUNT from FA_CANCEL_OR where IS_VALID= 1 "+
	" and OR_PRINTED_BY = "+WI.fillTextValue("teller_index")+" and TRANSACTION_DATE = '"+WI.fillTextValue("date_of_col")+"'";
rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	vCancelledOR.addElement("OR_"+rs.getString(1));
	vCancelledOR.addElement(rs.getString(2));
}rs.close();	
	
strTemp = "select fee_name from fa_oth_sch_fee where is_valid = 1 and ( fee_name like 'u-store%' or is_ustore = 1 )";	
rs = dbOP.executeQuery(strTemp);
Vector vUStorePayment = new Vector();
while(rs.next()){
	vUStorePayment.addElement(rs.getString(1));
}rs.close();
	

int iRowCount = 0;
int iMaxRowCount = 34;	
	
int iPageCount = 1;
int iTotalStud = (vTuitionFee.size()/12);
int iTotalPageCount = iTotalStud/iMaxRowCount;
if(iTotalStud % iMaxRowCount > 0)
	++iTotalPageCount;	


boolean bolPageBreak = false;

double dPageTotalSWU = 0d;
double dPageTotalUStore = 0d;

double dGrandTotalSWU = 0d;
double dGrandTotalUStore = 0d;

int iIndexOf = 0;
for(int i = 0,j=1; i < vTuitionFee.size();){
	dPageTotalSWU = 0d;
	dPageTotalUStore = 0d;
	if(bolPageBreak){
		bolPageBreak = false;
	%>
   	<div style="page-break-after:always;">&nbsp;</div>
   <%}%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
   	<tr>
      	<td width="71%" height="18"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
         <td width="29%">Page : 
      <label id="page_count_<%=iPageCount%>"><%=iPageCount%> of <%=iTotalPageCount%></label></td>
      </tr>
      <tr>
      	<td height="18"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
         <td>Date and Time Printed : <%=WI.getTodaysDateTime()%></td>
      </tr>
      <tr>
      	<td height="18">Daily Collection Listing</td>
         <td>&nbsp;</td>
      </tr>
      <tr>
      	<td>As of <%=WI.fillTextValue("date_of_col")%></td>
         <td>&nbsp;</td>
      </tr>
      <tr>
      	<td height="30" colspan="2" valign="bottom">
         	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
            	<tr>
               	<td width="28%">TELLER No. : [ <%=WI.getStrValue(strTellerNo,"&nbsp;")%> ]</td>
                  <td width="72%">Name :[ <%=WI.formatName((String)vEmployeeInfo.elementAt(1),(String)vEmployeeInfo.elementAt(2),
							(String)vEmployeeInfo.elementAt(3),1)%> ]</td>
               </tr>
            </table>
        </td>
      </tr>
   </table>
  
  

  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
   <tr> 
      <td width="5%" class="thinborderTOPLEFTBOTTOM"><div align="center"><font size="1"><strong>SEQ #</strong></font></div></td>
      <td width="14%" height="25" class="thinborderTOPLEFTBOTTOM"><div align="center"><font size="1"><strong>O.R. NUMBER</strong></font></div></td>
      <td width="13%" align="center" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong>STUDENT NO.</strong></font></td>
      <td width="33%" class="thinborderTOPLEFTBOTTOM"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>      
      <td width="15%" class="thinborderTOPLEFTBOTTOM"><div align="center"><strong><font size="1">COURSE CODE</font></strong></div></td> 
      <td width="10%" class="thinborderTOPLEFTBOTTOM"><div align="center"><strong><font size="1">SWU</font></strong></div></td>
      <td width="10%" class="thinborderALL"><div align="center"><strong><font size="1">U-STORE</font></strong></div></td>
    </tr>

<%for(; i < vTuitionFee.size(); i +=12,++j ){

	iIndexOf = vCancelledOR.indexOf( "OR_"+(String)vTuitionFee.elementAt(i + 1) );
	
	if( iIndexOf > -1){
		vTemp.addElement(vTuitionFee.elementAt(i));
		vTemp.addElement(vTuitionFee.elementAt(i+1));
		vTemp.addElement(vTuitionFee.elementAt(i+2));
				
		strErrMsg = "0";
		if((String)vTuitionFee.elementAt(i+6) != null){
			if(vUStorePayment.indexOf((String)vTuitionFee.elementAt(i+6)) > -1)
				strErrMsg = "1";
		}
		
		strTemp = (String)vCancelledOR.elementAt(iIndexOf + 1);
		
		vTemp.addElement(strTemp);
		vTemp.addElement(vTuitionFee.elementAt(i+4));
		vTemp.addElement(vTuitionFee.elementAt(i+5));
		vTemp.addElement(vTuitionFee.elementAt(i+6));
		vTemp.addElement(vTuitionFee.elementAt(i+7));
		vTemp.addElement(vTuitionFee.elementAt(i+8));
		vTemp.addElement(vTuitionFee.elementAt(i+9));
		vTemp.addElement(vTuitionFee.elementAt(i+10));
		vTemp.addElement(vTuitionFee.elementAt(i+11));
		vTemp.addElement(strErrMsg);
		continue;
	}

	iRowCount++;
	%>
   <tr> 
      <td class="thinborder" align="right" ><%=j%>&nbsp;&nbsp;</td>
      <td height="20" class="thinborder"><%=(String)vTuitionFee.elementAt(i + 1)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vTuitionFee.elementAt(i + 7),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vTuitionFee.elementAt(i + 2),"&nbsp;")%></td>      
      <td class="thinborder"><%=WI.getStrValue((String)vTuitionFee.elementAt(i + 10),"&nbsp;")%></td>        
      
      <%
		strTemp = WI.getStrValue((String)vTuitionFee.elementAt(i + 3),"0");
		strErrMsg = "0";
		if((String)vTuitionFee.elementAt(i+6) != null){
			if(vUStorePayment.indexOf((String)vTuitionFee.elementAt(i+6)) > -1){
				strErrMsg = WI.getStrValue((String)vTuitionFee.elementAt(i + 3),"0");
				strTemp = "0";				
			}
		}	
		
		dPageTotalSWU += Double.parseDouble(WI.getStrValue( ConversionTable.replaceString(strTemp,",",""),"0"));
		dPageTotalUStore += Double.parseDouble(WI.getStrValue( ConversionTable.replaceString(strErrMsg,",",""),"0"));
		
		if(strTemp.equals("0"))
			strTemp = "&nbsp;";
		if(strErrMsg.equals("0"))
			strErrMsg = "&nbsp;";
		
		%>
         
      <td class="thinborder"><div align="right"><%=strTemp%></div></td>
      <td class="thinborderBOTTOMLEFTRIGHT"><div align="right"><%=strErrMsg%></div></td>
    </tr>
	<%
	
	if(iRowCount >= iMaxRowCount){
		iRowCount = 0;
		i+=12;
		++j;
		iPageCount++;
		bolPageBreak = true;
		break;	
	}
	
	
	
	}
	
	
	 dGrandTotalSWU += dPageTotalSWU;
 	 dGrandTotalUStore += dPageTotalUStore;
	
	%>
   <tr>
   	<td colspan="5" align="center" height="18"> Sub - Total of this page => </td>
      <td align="right"><strong><%=CommonUtil.formatFloat(dPageTotalSWU, true)%></strong></td>
      <td align="right"><strong><%=CommonUtil.formatFloat(dPageTotalUStore, true)%></strong></td>
   </tr>
   
   <%if(i + 12 >= vTuitionFee.size()){%>
   <tr>
   	<td colspan="5" align="center" height="18"> Daily Total Collection &nbsp; &nbsp; : </td>
      <td align="right"><strong><%=CommonUtil.formatFloat(dGrandTotalSWU, true)%></strong></td>
      <td align="right"><strong><%=CommonUtil.formatFloat(dGrandTotalUStore, true)%></strong></td>
   </tr>
   <%}%>
  </table>
<%}%> 

	<%if( (iMaxRowCount - 8 ) < iRowCount){%>
    	<div style="page-break-after:always;">&nbsp;</div>
      <script>
		
      var iLoop = <%=iPageCount%>;
		var iLoop2 = iLoop + 1;
      	for(var i = 1; i <= iLoop; i++){
				document.getElementById("page_count_"+i).innerHTML = i + " of " +iLoop2;
			}
		
      </script>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
   	<tr>
      	<td width="78%" height="18"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
         <td width="22%">Page : <%=iPageCount = iPageCount + 1%> of <%=iTotalPageCount = iTotalPageCount + 1%></td>
      </tr>
      <tr>
      	<td height="18"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
         <td>Date and Time Printed : <%=WI.getTodaysDateTime()%></td>
      </tr>
      <tr>
      	<td height="18">Daily Collection Listing</td>
         <td>&nbsp;</td>
      </tr>
      <tr>
      	<td>As of <%=WI.fillTextValue("date_of_col")%></td>
         <td>&nbsp;</td>
      </tr>
      <tr>
      	<td height="30" colspan="2" valign="bottom">
         	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
            	<tr>
               	<td width="28%">TELLER No. : [ <%=WI.getStrValue(strTellerNo,"&nbsp;")%> ]</td>
                  <td width="72%">Name :[ <%=WI.formatName((String)vEmployeeInfo.elementAt(1),(String)vEmployeeInfo.elementAt(2),
							(String)vEmployeeInfo.elementAt(3),1)%> ]</td>
               </tr>
            </table>
        </td>
      </tr>
   </table>
<%}

if(vTemp.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="20" colspan="7">CANCELLED OFFICIAL RECEIPTS:</td></tr>
<%

for(int i = 0, j = 1; i < vTemp.size(); i+=13, j++){
	strErrMsg = (String)vTemp.elementAt(i+12);
	if(strErrMsg.equals("1")){
		strErrMsg = CommonUtil.formatFloat((String)vTemp.elementAt(i+3), true);
		strTemp = "&nbsp;";
	}else{
		strTemp = CommonUtil.formatFloat((String)vTemp.elementAt(i+3), true);
		strErrMsg = "&nbsp;";
	}
%>	
	<tr> 
      <td width="5%" align="right"><%=j%>.&nbsp;</td>
      <td width="14%" height="20"><%=(String)vTemp.elementAt(i + 1)%></td>
      <td width="13%"><%=WI.getStrValue((String)vTemp.elementAt(i + 7),"&nbsp;")%></td>
      <td width="33%"><%=WI.getStrValue((String)vTemp.elementAt(i + 2),"&nbsp;")%></td>      
      <td width="15%"><%=WI.getStrValue((String)vTemp.elementAt(i + 10),"&nbsp;")%></td> 
      <td width="10%"><div align="right"><%=strTemp%></div></td>
      <td width="10%"><div align="right"><%=strErrMsg%></div></td>
    </tr>
<%
}
%>
</table>
<%}%>	 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr>
   	 <td width="4%">&nbsp;</td>
      <td width="17%" height="60" valign="bottom" align="right">Teller's Signature &nbsp; &nbsp;</td>
      <td width="1%" valign="bottom" align="center">:</td>
      <td width="23%" valign="bottom"><div style="border-bottom:solid 1px #000000;"></div></td>
      <td width="5%">&nbsp;</td>
      <td width="12%" valign="bottom" align="right">Noted by &nbsp; &nbsp;</td>
      <td width="2%" valign="bottom">:</td>
      <td width="24%" valign="bottom"><div style="border-bottom:solid 1px #000000;"></div></td>
      <td width="12%">&nbsp;</td>
   </tr>
   <tr>
   	<td colspan="7"></td>
      <td valign="top" align="center">CASHIER</td>
   </tr>
   <tr>
   	 <td width="4%">&nbsp;</td>
      <td width="17%" height="60" valign="bottom" align="right">Audited by &nbsp; &nbsp;</td>
      <td width="1%" valign="bottom" align="center">:</td>
      <td width="23%" valign="bottom"><div style="border-bottom:solid 1px #000000;"></div></td>
      <td>&nbsp;</td>
   </tr>
   
   <tr>
   	<td colspan="3"></td>
      <td valign="top" align="center">AUDITOR</td>
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
      <td width="40%" height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>

<%}//if collection information is not null.
%>
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