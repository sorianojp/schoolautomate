<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String strInfo5   = (String)request.getSession(false).getAttribute("info5");

if(strSchCode == null)
	strSchCode = "";
if(strSchCode.startsWith("UB")) {
	response.sendRedirect("./cashier_report_summary_UB_Without_Course.jsp");
	return;
}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	var oRows = document.getElementById('myADTable2').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	while(iRowCount > 0) {
		document.getElementById('myADTable2').deleteRow(0);
		--iRowCount;
	}

   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function ViewReport() {
	//document.daily_cash.view_report.value = 1;
}
function ReloadPage() {
	//document.daily_cash.view_report.value = "";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	Vector vTuitionFee = null;
	Vector vOtherFee   = null;
	Vector vRetResult  = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cashier_report_summary.jsp");
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
														"cashier_report_summary.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(),
														"cashier_report_summary.jsp");
}
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Administrators","Enrollment",request.getRemoteAddr(),
														null);
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
boolean bolIsJonelta = false;
if(strInfo5 != null && strInfo5.equals("jonelta"))
	bolIsJonelta = true;


//end of authenticaion code.
Vector vEmployeeInfo = null;
Authentication auth = new Authentication();
DailyCashCollection DC = new DailyCashCollection();

Vector vReservationFeeAUF = null;//auf needs another column for reservation fee.. 
Vector vResFeeName        = null;
Vector vResCollegeTotal   = null;
boolean bolShowReservationFee = false; double dTempResFee = 0d; double dTemp = 0d;

vEmployeeInfo = auth.operateOnBasicInfo(dbOP, request,"0");
if(vEmployeeInfo == null)
	strErrMsg = auth.getErrMsg();
else if(WI.fillTextValue("date_of_col").length() > 0)
{
	if(WI.fillTextValue("date_of_col_to").length() > 0)
		DC.strCollectionDateTo = WI.fillTextValue("date_of_col_to");

	vRetResult  = DC.viewDailyCashColSummary(dbOP,request.getParameter("date_of_col"),request.getParameter("emp_id"), request);
	if(vRetResult == null)
		strErrMsg = DC.getErrMsg();
	else {
		vTuitionFee = (Vector)vRetResult.remove(0);
		vOtherFee   = (Vector)vRetResult.remove(0);
		if(WI.fillTextValue("res_as_tuition").length() > 0) {
			vReservationFeeAUF = DC.getReservationFeeSummary(dbOP, request);
			if(vReservationFeeAUF != null)
				bolShowReservationFee = true;
		}
	}
}
//System.out.println(vTuitionFee);
%>

<form name="daily_cash" method="post" action="./cashier_report_summary.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          DAILY CASHIER'S REPORT - SUMMARY::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
<%
boolean bolIsOnlyYL  = false;
boolean bolYLExclude = false;
if(strSchCode.startsWith("EAC")){
//if cavite do not proceed.. 
strTemp = "select info5 from sys_info";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp == null) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
<%
strErrMsg = WI.fillTextValue("show_YL");
if(strErrMsg.length() == 0 || strErrMsg.equals("0"))
	strTemp = " checked";
else	
	strTemp = "";
%>
		  <input type="radio" name="show_YL" value="0" <%=strTemp%>> Show All 
<%
if(strErrMsg.equals("1")) {
	strTemp = " checked";
	bolIsOnlyYL = true;
}
else	
	strTemp = "";
%>
		  <input type="radio" name="show_YL" value="1" <%=strTemp%>> Show only Yaman Lahi 
<%
if(strErrMsg.equals("2")) {
	strTemp = " checked";
	bolYLExclude = true;
}
else	
	strTemp = "";
%>
		  <input type="radio" name="show_YL" value="2" <%=strTemp%>> Exclude Yahman Lahi
	  </td>
    </tr>
<%}//show for eac main.. 

}if(strSchCode.startsWith("PHILCST") || strSchCode.startsWith("EAC") || strSchCode.startsWith("NEU")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
<%
strTemp = WI.fillTextValue("show_con_aror");
if(strTemp.length() == 0) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con_aror" value=""<%=strErrMsg%>> Show All &nbsp;&nbsp;
<%
if(strTemp.equals("1")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con_aror" value="1"<%=strErrMsg%>> Show OR Only &nbsp;&nbsp;
<%
if(strTemp.equals("2")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con_aror" value="2"<%=strErrMsg%>> Show AR Only
	  
	  <br><br>
	  <input type="checkbox" name="show_all_teller" value="checked"<%=WI.fillTextValue("show_all_teller")%>> Include All Teller	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="15%" height="25">Collection Date</td>
      <td height="25" colspan="3"><font size="1">
<%
strTemp = WI.fillTextValue("date_of_col");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_of_col" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_of_col');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
<%if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC") || strSchCode.startsWith("CLDH")  || 
	strSchCode.startsWith("PHILCST")  || strSchCode.startsWith("UL")  || strSchCode.startsWith("FATIMA")  || 
	strSchCode.startsWith("EAC") || strSchCode.startsWith("UC") || strSchCode.startsWith("MARINER") || strSchCode.startsWith("UPH") || 
	strSchCode.startsWith("NEU") || strSchCode.startsWith("DLSHSI")) {%>
        to
<%
strTemp = WI.fillTextValue("date_of_col_to");
%>
        <input name="date_of_col_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_of_col_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        (for one day, leave to field empty.)
        <%}//show date to only for CGH
%>
<%if(strSchCode.startsWith("UC")) {%>
	  <input type="checkbox" name="show_all_teller" value="checked"<%=WI.fillTextValue("show_all_teller")%>> Include All Teller
<%}%>
        </font></td>
    </tr>
    <tr>
      <td width="2%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" class="thinborderBOTTOM">Teller ID</td>
      <td width="13%" height="25" class="thinborderBOTTOM">
<%
strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("userId");
if(strTemp == null)
	strTemp = "";
%>
	  <input name="emp_id" type="text" size="16" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="44%" class="thinborderBOTTOM" style="font-size:9px;">&nbsp;&nbsp;&nbsp;<input type="image" src="../../../images/form_proceed.gif" onClick="ReloadPage();">
	  
	  <%if(strSchCode.startsWith("AUF")){
	  if(request.getParameter("date_of_col") == null)
	  	strTemp = " checked";
	  else	
	   	strTemp = WI.fillTextValue("res_as_tuition");
	  %>
	  <input type="checkbox" name="res_as_tuition" value="checked" <%=strTemp%>> Show Reservation in Tuition Fee Group
	  <%}%>      </td>
      <td width="26%" class="thinborderBOTTOM">&nbsp;
<%if(vRetResult != null) {%>
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print</font>
<%}%>	  </td>
    </tr>
  </table>

<!------------------- display report here ------------------------->
<%if(vRetResult != null) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
<%if(strSchCode.startsWith("AUF") || strSchCode.startsWith("DLSHSI")){%>
		<td width="31%" align="right">&nbsp;<img src="../../../images/logo/<%=strSchCode%>.gif" width="100" height="100"></td>
<%}%>
      <td width="45%" align="center"> <font size="2"> <strong>
	  		<%if(bolYLExclude) {%>
				EMILIO AGUINALDO EDUC. CORP.
			<%}
	  		else {
				if(bolIsOnlyYL) {%>YLFI - <%}%>
	  			<%=SchoolInformation.getSchoolName(dbOP,true,false)%>
			<%}//show for non-eac clients.. %>
			
			</strong><br>
          <font size="1"><i><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false),",","","")%></i></font></font>
		  <br>
		  <font style="font-family:'Century Gothic'"><strong>ACCOUNTING AND FINANCE OFFICE
		  <br><br>
		  DAILY CASHIER'S REPORT SUMMARY
		  </strong></font>
	  </td>
<%if(strSchCode.startsWith("AUF") || strSchCode.startsWith("DLSHSI")){%>
		  <td width="24%">&nbsp;</td>
<%}%>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr valign="bottom">
      <td width="42%" height="24">RUN DATE : <%=WI.getTodaysDateTime()%></td>
      <td width="35%" height="24">Collection Date <%=WI.fillTextValue("date_of_col")%>
	  <%if(WI.fillTextValue("date_of_col_to").length() > 0) {%>
	  	- <%=WI.fillTextValue("date_of_col_to")%>
	  <%}%>
	  
	  </td>
      <td width="23%" height="24">Teller ID #:<%=WI.fillTextValue("emp_id")%></td>
    </tr>
  </table>
<%
double dTotalTuitionAmt = 0d;
double dTotalOthAmt     = 0d;

double dTotResFee  = 0d;//only for AUF.. they need to show another column for reservation fee.. 
if(bolShowReservationFee)
	dTotResFee = Double.parseDouble((String)vReservationFeeAUF.remove(0));

if(vTuitionFee != null && vTuitionFee.size() > 0) {
dTotalTuitionAmt = Double.parseDouble((String)vTuitionFee.remove(0));

%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18" colspan="5">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="5"><strong><u>ACCOUNTS RECEIVABLES - STUDENT </u></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="2">COURSE</td>
      <td width="18%"><div align="center">
          <%if(bolShowReservationFee){%>RESERVATION FEE<%}%>
        </div></td>
      <td width="18%"><div align="center">COLLECTION</div></td>
      <td width="12%"><div align="center">TOTAL</div></td>
    </tr>
<%
String strDispExt1 = "xxxxx";
String strDispExt2 = "xxxxx";
if(strSchCode.startsWith("CLDH")) {
	strDispExt1 = "External Payment";
	strDispExt2 = "Ext. Pmt.";
}
boolean bolIsBasic = false;
int iHSPrinted     = -1;
for(int i = 0; i < vTuitionFee.size() ; ) {
strTemp = (String)vTuitionFee.remove(i);
if(strTemp != null && strTemp.startsWith(" Basic"))
	bolIsBasic = true;
else	
	bolIsBasic = false;
%>
    <tr>
      <td height="25" colspan="2"><%=WI.getStrValue(strTemp,strDispExt1)%></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" align="right"><%=(String)vTuitionFee.remove(i)%>&nbsp;</td>
    </tr>
<%
for(; i < vTuitionFee.size(); i += 3) {
	if(vTuitionFee.elementAt(i) != null)
		break;
	strTemp = (String)vTuitionFee.elementAt(i + 1);
	if(strTemp != null && bolIsBasic && iHSPrinted == -1 && 
		(strTemp.startsWith("1st") || strTemp.startsWith("2nd") || strTemp.startsWith("3rd") || 
		strTemp.startsWith("4th")))
		iHSPrinted = 0;
	
	dTempResFee = 0d;
	if(bolShowReservationFee && vReservationFeeAUF.size() > 0) {
		if(strTemp.equals(vReservationFeeAUF.elementAt(1))) {
			dTempResFee = Double.parseDouble((String)vReservationFeeAUF.remove(2));
			vReservationFeeAUF.remove(0);vReservationFeeAUF.remove(0);
		}	
	}
	dTemp = Double.parseDouble(ConversionTable.replaceString((String)vTuitionFee.elementAt(i + 2), ",","")) - dTempResFee;
		
	if(strTemp != null && strTemp.startsWith("_"))
		strTemp = strTemp.substring(1);
		
	if(bolIsBasic && iHSPrinted == 0){%>
		<tr>
		  <td height="25" colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;High School </td>
		  <td height="25">&nbsp;</td>
		  <td height="25">&nbsp;</td>
		  <td height="25">&nbsp;</td>
	   </tr>
	<%iHSPrinted = 1;}%>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="48%"><%=WI.getStrValue(strTemp,strDispExt2)%></td>
      <td height="25" align="center"><%if(dTempResFee > 0d){%><%=CommonUtil.formatFloat(dTempResFee, true)%><%}%>&nbsp;</td>
      <td height="25"><div align="center"><%if(dTemp > 0d){%><%=CommonUtil.formatFloat(dTemp, true)%><%}%></div></td>
      <td height="25">&nbsp;</td>
   </tr>
<%}
}%>
    <tr>
      <td height="21">&nbsp;</td>
      <td height="21">&nbsp;</td>
      <td height="21"><%if(bolShowReservationFee) {%><hr size="1"><%}%></td>
      <td height="21"><%if(bolShowReservationFee) {%><hr size="1"><%}%></td>
      <td height="21"><hr size="1"></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18"><strong>SUBTOTAL FOR ACCOUNTS RECEIVABLES - STUDENT </strong></td>
      <td height="18" align="center"><strong><%=CommonUtil.formatFloat(dTotResFee,true)%></strong></td>
      <td height="18" align="center"><strong><%=CommonUtil.formatFloat(dTotalTuitionAmt - dTotResFee,true)%></strong></td>
      <td height="18" align="right"><strong><%=CommonUtil.formatFloat(dTotalTuitionAmt,true)%>&nbsp;</strong></td>
    </tr>
  </table>
<%}//show only if vTuitionFee is not null.%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
<%if(vOtherFee != null && vOtherFee.size() > 1){%>
    <tr>
      <td height="26" colspan="6"><strong>OTHER INCOME/OTHERS</strong></td>
    </tr>
<%
if(vOtherFee.size() %2 == 0) 
	dTotalOthAmt = 0d;
else
	dTotalOthAmt = Double.parseDouble((String)vOtherFee.remove(0));
for(int i = 0; i < vOtherFee.size(); i += 2){%>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="18%">&nbsp;</td>
      <td colspan="3"><%=(String)vOtherFee.elementAt(i)%></td>
      <td width="12%" align="right"><%=(String)vOtherFee.elementAt(i + 1)%>&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">&nbsp;</td>
      <td height="10"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"><strong>SUBTOTAL FOR OTHER INCOME/OTHERS</strong></td>
      <td height="25" align="right"><strong><%=CommonUtil.formatFloat(dTotalOthAmt,true)%>&nbsp;</strong></td>
    </tr>
<%}//end of othr fee collection%>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="25%" height="18">&nbsp;</td>
      <td height="18" colspan="3">&nbsp;</td>
      <td width="13%" height="18">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><strong>Total Collection for the Day :</strong></td>
      <td height="25" align="right"><strong><%=CommonUtil.formatFloat(dTotalOthAmt + dTotalTuitionAmt, true)%>&nbsp;</strong></td>
    </tr>
    <tr>
      <td height="25" colspan="4"><strong>Total Cash/Check Deposits :</strong></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="4">&nbsp;</td>
      <td height="10"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25"><strong>Cash (Short) or Over :</strong></td>
      <td width="26%" height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td width="17%" height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
<%if(strSchCode.startsWith("WNU") || bolIsJonelta){
strTemp = (String)vRetResult.remove(0);
if(strTemp != null && !strTemp.equals("0.00")) {%>
    <tr>
      <td height="25" colspan="5" style="font-weight:bold; font-size:11px;">
	  	<u>Note : Total NSTP Fee Collected for the day : <%=strTemp%></u></td>
    </tr>
<%}
}%>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
<%if(!strSchCode.startsWith("EAC")){%>
    <tr>
      <td height="25">Official Receipts Used :</td>
      <td height="25" colspan="4">OR No. Range :
<%
vRetResult = DC.getOrNumberRangeUsed(dbOP, (String)vEmployeeInfo.elementAt(0),request.getParameter("date_of_col"));
if(vRetResult != null && vRetResult.size() > 0) {
	for(int i = 0; i < vRetResult.size(); i += 2){
		if(i > 0){%>
        &nbsp;,
        <%}%>
	<%=(String)vRetResult.elementAt(i) + " to "+ (String)vRetResult.elementAt(i + 1)%>
<%}
}%>		  </td>
    </tr>
<%}%>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr valign="bottom">
      <td height="14">Prepared by:</td>
      <td height="14">Verified by:</td>
      <td width="19%">Checked by:</td>
      <td height="14" colspan="2">Counter Check  by:</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>

<%}//////////////////// end of report ////////////////////%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
