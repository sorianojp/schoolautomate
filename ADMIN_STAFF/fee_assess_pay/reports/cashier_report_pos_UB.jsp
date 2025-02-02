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
<body>
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	Vector vOthSchFee  = null;
	Vector vRetResult  = null;
	Vector vORCollection = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cashier_report_pos_UB.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(), null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(), null);
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//end of authenticaion code.
Vector vEmployeeInfo   = null;
Authentication auth    = new Authentication();
DailyCashCollection DC = new DailyCashCollection();
String strTellerNo     = null;


vEmployeeInfo = auth.operateOnBasicInfo(dbOP, request,"0");
if(vEmployeeInfo == null)
	strErrMsg = auth.getErrMsg();
else if(WI.fillTextValue("date_of_col").length() > 0)
{
	if(WI.fillTextValue("date_of_col_to").length() > 0)
		DC.strCollectionDateTo = WI.fillTextValue("date_of_col_to");

	vRetResult  = DC.viewDailyCashColSummaryV2(dbOP, request);
	if(vRetResult == null)
		strErrMsg = DC.getErrMsg();
	else {
		vOthSchFee    = (Vector)vRetResult.remove(5);
		vORCollection = (Vector)vRetResult.remove(5);

		strTellerNo = "select teller_no from UB_TELLER_NO where teller_index = "+(String)vEmployeeInfo.elementAt(0);
		strTellerNo = dbOP.getResultOfAQuery(strTellerNo, 0);
	}	
}
//System.out.println(vTuitionFee);
%>

<form name="daily_cash" method="post" action="./cashier_report_pos_UB.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          DAILY CASHIER'S REPORT- POS ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
<%
if(strSchCode.startsWith("PHILCST") || strSchCode.startsWith("EAC")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
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
	strSchCode.startsWith("PHILCST")  || strSchCode.startsWith("UL")  || strSchCode.startsWith("FATIMA")  || strSchCode.startsWith("EAC")) {%>
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
	<table width="35%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="22" width="25%">Teller No.</td>
			<td width="30%"><%=WI.getStrValue(strTellerNo,"&nbsp;")%></td>
			<td width="25%">Date: </td>
			<td><%=WI.fillTextValue("date_of_col")%></td>
		</tr>
		<tr>
			<td height="22">OR Used: </td>
			<td colspan="3"><%=vRetResult.elementAt(3)%> - <%=vRetResult.elementAt(4)%></td>
		</tr>
		<tr><td colspan="4" height="15"></td></tr>
	</table>

	<table width="35%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<%
		for(int i = 0; i < vORCollection.size(); i += 3){%>
			<tr>	
				<td class="thinborderNONE" width="33%"><%=ConversionTable.replaceString((String)vORCollection.elementAt(i), "-","")%></td>
				<td class="thinborderNONE" width="33%"><%=(String)vORCollection.elementAt(i + 1)%></td>
				<td class="thinborderNONE" align="right" width="33%"><%=(String)vORCollection.elementAt(i + 2)%></td>
			</tr>
		<%}%>
			<tr>
			  <td class="thinborderNONE" height="25" colspan="3" align="right">Total : <%=vRetResult.elementAt(0)%></td>
			</tr>
	
	</table>
	<table width="35%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td class="thinborderNONE" height="25" colspan="2" valign="bottom"><hr></td>
		</tr>
		<tr>				  
			<td class="thinborderNONE" height="25" width="80%">TUITION RECEIVABLE</strong></td>				  
			<td class="thinborderNONE" height="25" align="right"><%=vRetResult.elementAt(1)%></td>
		</tr>

		<%
		for(int i = 0; i < vOthSchFee.size(); i += 2){%>
			<tr>	
				<td class="thinborderNONE"><%=(String)vOthSchFee.elementAt(i)%></td>
				<td class="thinborderNONE" height="25" align="right"><%=(String)vOthSchFee.elementAt(i + 1)%></td>
			</tr>
		<%}%>
	</table>

<%}//////////////////// end of report ////////////////////%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
