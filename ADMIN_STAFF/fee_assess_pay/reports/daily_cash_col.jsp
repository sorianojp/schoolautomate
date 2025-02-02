<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
	if(document.daily_cash.emp_id.value.length ==0){
		alert("Please enter employee ID.");
		return;
	}
	if(document.daily_cash.date_of_col.value.length ==0) {
		alert("Please enter date of collection.");
		return;
	}
	//I have to call here the print page.
	var pgLoc = "./daily_cash_col_print.jsp?emp_id="+escape(document.daily_cash.emp_id.value)+
				"&date_of_col="+document.daily_cash.date_of_col.value+"&teller_index="+
				document.daily_cash.teller_index.value;
	if(document.daily_cash.show_mp.checked)
		pgLoc += "&show_mp=1";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function ViewReport() {
	document.daily_cash.view_report.value = 1;
}
function ReloadPage() {
	document.daily_cash.view_report.value = "";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	String[] astrConvertGender = {"Male","Female"};

	Vector vTuitionFee       = null;
	Vector vSchFacDeposit   = null;
	Vector vRemittance      = null;
	int i = 0;

	double dSubTotalCash  = 0d;
	double dSubTotalCheck = 0d;
	double dSubTotalCA    = 0d;//cash advance
	double dSubTotalCC    = 0d;//credit card payment.. 


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","daily_cash_col.jsp");
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
														"daily_cash_col.jsp");
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
else if(WI.fillTextValue("date_of_col").length() > 0 && 
	WI.fillTextValue("teller_index").length() > 0 && WI.fillTextValue("view_report").length() > 0)
{
	vCollectionInfo  = DC.viewDailyCashCollectionDtlsPerTeller(dbOP,request.getParameter("date_of_col"),request.getParameter("teller_index"),request);
	if(vCollectionInfo == null)
		strErrMsg = DC.getErrMsg();
}
dbOP.cleanUP();

if(vCollectionInfo != null)
{
	vTuitionFee      = vCollectionInfo[0];
	vSchFacDeposit   = vCollectionInfo[1];
	vRemittance      = vCollectionInfo[2];
}
//System.out.println(vTuitionFee);
if(strErrMsg == null) 
	strErrMsg = "";

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>

<form name="daily_cash" method="post" action="./daily_cash_col.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          DAILY CASH COLLECTION DETAILS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=strErrMsg%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">Employee ID&nbsp; </td>
      <td width="18%" height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td width="67%"><input type="image" src="../../../images/form_proceed.gif" onClick="ReloadPage();"></td>
    </tr>
	<tr>
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
  </table>
<%
 if(vEmployeeInfo != null && vEmployeeInfo.size() >0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2">Employee Name :<strong> <%=WI.formatName((String)vEmployeeInfo.elementAt(1),(String)vEmployeeInfo.elementAt(2),(String)vEmployeeInfo.elementAt(3),1)%></strong></td>
      <td height="25">Employment Status : <strong><%=WI.getStrValue((String)vEmployeeInfo.elementAt(16))%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Job Title/Position : <strong><%=(String)vEmployeeInfo.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25">Date of collection: <font size="1">
<%
	strTemp = WI.fillTextValue("date_of_col");
	if(strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);
%>
        <input name="date_of_col" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_of_col');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font></td>
      <td width="49%">
<%
boolean bolCheck = false;
if(request.getParameter("date_of_col") == null && strSchCode.startsWith("CLDH"))
	bolCheck = true;
strTemp = WI.fillTextValue("show_mp");
if(strTemp.length() > 0 || bolCheck) 
	strTemp = " checked";
else	
	strTemp = "";
%>	  
	  <input type="checkbox" name="show_mp" value="1"<%=strTemp%>>
	  Show Multiple Payment Detail
	  
	  
	  &nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
      <td height="25"><div align="right"></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="26%" height="25">&nbsp;</td>
      <td width="23%" height="25">
	  <input name="image" type="image" src="../../../images/form_proceed.gif" onClick="ViewReport();"></td>
      <td height="25"><div align="right"><!--
	  <a href="javascript:CashCounting();"><img src="../../../images/cash_count.gif" border="0"></a><font size="1">click
          to encode/view cash counting for this collection</font>--></div></td>
    </tr>
  </table>
<%

boolean bolIsCancelled = false;//only for cldh.. 
boolean bolIsCLDH      = strSchCode.startsWith("CLDH");
String strStrikeThru   = null;//strike thru' if OR is cancelled.


if(vCollectionInfo != null && vCollectionInfo.length > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>COLLECTION 
          ACCOUNTED AS FOLLOWS</strong></font></div></td>
    </tr>
    <tr> 
      <td width="5%"><div align="center"><font size="1"><strong>TYPE OF PAYMENT</strong></font></div></td>
      <td width="15%" height="25"><div align="center"><font size="1"><strong>O.R. 
          NUMBER</strong></font></div></td>
      <td width="25%"><div align="center"><font size="1"><strong>NAME OF STUDENT/PAYEE</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>COURSE CODE</strong></font></div></td>
      <td width="25%"><font size="1"><strong>FEE PARTICULARS</strong></font></td>
    </tr>
    <tr> 
      <td><div align="center"><font size="1">CASH</font></div></td>
      <td height="25"><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
    </tr>
    <%//System.out.println(vTuitionFee);
if(vTuitionFee != null && vTuitionFee.size() > 0)
{
	for(i = 0; i< vTuitionFee.size(); ++i)
	{
		///to indicate cancelled OR for CLDH.
		if(bolIsCLDH && WI.getStrValue(vTuitionFee.elementAt(i + 3)).equals("0.0")) {
			bolIsCancelled = true;
			strStrikeThru =" style='text-decoration:line-through;'";
		}
		else {	
			bolIsCancelled = false;
			strStrikeThru  = "";
		}
		
		if( ((String)vTuitionFee.elementAt(i)).compareTo("0") !=0)//not cash, break here.
		{
			i=i+9;
			continue;
		}
		dSubTotalCash += Double.parseDouble((String)vTuitionFee.elementAt(i+3));
	%>
    <tr> 
      <td><font size="1">&nbsp;</font></td>
      <td height="25"><font size="1"><%=(String)vTuitionFee.elementAt(i+1)%></font></td>
      <td>
	<%if(bolIsCancelled){%>
		<font style="color:#FF0000; font-size:9px; font-weight:bold;">Cancelled</font>
	<%}else{%>	  
	  <font size="1">&nbsp;<%=(String)vTuitionFee.elementAt(i+2)%>
	  <%//System.out.println((String)vTuitionFee.elementAt(i+1)+" "+(String)vTuitionFee.elementAt(i+8));%></font>
	  <%}%>
	  </td>
      <td><div align="right"><font size="1">&nbsp;
	  <%=CommonUtil.formatFloat((String)vTuitionFee.elementAt(i+3),true)%></font></div></td>
      <td>
	  <%if(bolIsCancelled){%>&nbsp;<%}else{%>
	  <font size="1"><%=WI.getStrValue(vTuitionFee.elementAt(i+9),"&nbsp;")%></font>
	  <%}%>
	  </td>
      <td><font size="1"><%=(String)vTuitionFee.elementAt(i+5)%> 
        <%
	  if(vTuitionFee.elementAt(i+6) != null){%>
        (<%=(String)vTuitionFee.elementAt(i+6)%>) 
        <%}%>
        </font></td>
    </tr>
    <%i = i+9;	}
//I have to remove the entries here.
//for(;i>0;--i)
//	vTuitionFee.removeElementAt(0);
}%>
    <tr> 
      <td  colspan="3" height="25"><div align="right"><font size="1">TOTAL : Php 
          &nbsp;&nbsp;&nbsp;</font></div></td>
      <td><div align="right"><font size="1">&nbsp;<%=CommonUtil.formatFloat(dSubTotalCash,true)%></font></div></td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">CHECK</font></div></td>
      <td height="25"><font size="1">&nbsp;</font></td>
      <td height="25"><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
    </tr>
    <%
if(vTuitionFee != null && vTuitionFee.size() > 0)
{
	for(i = 0; i< vTuitionFee.size(); ++i)
	{
		if( ((String)vTuitionFee.elementAt(i)).compareTo("1") !=0)//not cash, break here.
		{
			i=i+9;
			continue;
		}

		dSubTotalCheck += Double.parseDouble((String)vTuitionFee.elementAt(i+3));
	%>
    <tr> 
      <td><font size="1">&nbsp;</font></td>
      <td height="25"><font size="1"><%=(String)vTuitionFee.elementAt(i+1)%></font></td>
      <td>
  	<%if(bolIsCancelled){%>
		<font style="color:#FF0000; font-size:9px; font-weight:bold;">Cancelled</font>
	<%}else{%>	
	  <font size="1">&nbsp;<%=(String)vTuitionFee.elementAt(i+2)%></font>
	<%}%>  
	  </td>
      <td><div align="right"><font size="1">&nbsp;<%=CommonUtil.formatFloat((String)vTuitionFee.elementAt(i+3),true)%></font></div></td>
      <td><font size="1">
        <%if(bolIsCancelled){%>
        &nbsp;
        <%}else{%>
        <font size="1"><%=WI.getStrValue(vTuitionFee.elementAt(i+9),"&nbsp;")%></font>
        <%}%>
</font></td>
      <td><font size="1"><%=(String)vTuitionFee.elementAt(i+5)%> 
        <%
	  if(vTuitionFee.elementAt(i+6) != null){%>
        (<%=(String)vTuitionFee.elementAt(i+6)%>) 
        <%}%>
        </font></td>
    </tr>
    <%i = i+9;	}
//I have to remove the entries here.
//for(;i>0;--i)
//	vTuitionFee.removeElementAt(0);
}%>
    <tr> 
      <td height="25"  colspan="3"><div align="right"><font size="1">TOTAL : Php 
          &nbsp;&nbsp;&nbsp; </font></div></td>
      <td><div align="right"><font size="1">&nbsp;<%=CommonUtil.formatFloat(dSubTotalCheck,true)%></font></div></td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
    </tr>
<%if(strSchCode.startsWith("CSA") || strSchCode.startsWith("AUF")){%>
	<tr> 
      <td height="25"><div align="center"><font size="1">CREDIT CARD</font></div></td>
      <td height="25"><font size="1">&nbsp;</font></td>
      <td height="25"><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
    </tr>
    <%
if(vTuitionFee != null && vTuitionFee.size() > 0)
{
	for(i = 0; i< vTuitionFee.size(); ++i) {
		strTemp = (String)vTuitionFee.elementAt(i);
		if(strTemp.equals("6") || strTemp.equals("7")) {//CC
			//do nothing;
		}
		else {
			i=i+9;
			continue;
		}

		dSubTotalCC += Double.parseDouble((String)vTuitionFee.elementAt(i+3));
	%>
    <tr> 
      <td><font size="1">&nbsp;</font></td>
      <td height="25"><font size="1"><%=(String)vTuitionFee.elementAt(i+1)%></font></td>
      <td>
  	<%if(bolIsCancelled){%>
		<font style="color:#FF0000; font-size:9px; font-weight:bold;">Cancelled</font>
	<%}else{%>	
	  <font size="1">&nbsp;<%=(String)vTuitionFee.elementAt(i+2)%></font>
	<%}%>  
	  </td>
      <td><div align="right"><font size="1">&nbsp;<%=CommonUtil.formatFloat((String)vTuitionFee.elementAt(i+3),true)%></font></div></td>
      <td><font size="1">
        <%if(bolIsCancelled){%>
        &nbsp;
        <%}else{%>
        <font size="1"><%=WI.getStrValue(vTuitionFee.elementAt(i+9),"&nbsp;")%></font>
        <%}%>
</font></td>
      <td><font size="1"><%=(String)vTuitionFee.elementAt(i+5)%> 
        <%
	  if(vTuitionFee.elementAt(i+6) != null){%>
        (<%=(String)vTuitionFee.elementAt(i+6)%>) 
        <%}%>
        </font></td>
    </tr>
    <%i = i+9;	}
//I have to remove the entries here.
//for(;i>0;--i)
//	vTuitionFee.removeElementAt(0);
}%>
    <tr> 
      <td height="25"  colspan="3"><div align="right"><font size="1">TOTAL : Php 
          &nbsp;&nbsp;&nbsp; </font></div></td>
      <td><div align="right"><font size="1">&nbsp;<%=CommonUtil.formatFloat(dSubTotalCC,true)%></font></div></td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
    </tr>
<%}%>	
    <tr> 
      <td height="25" colspan="3"><font size="1">SALARY DEDUCTION</font> <font size="1">&nbsp;&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
    </tr>
    <%
if(vTuitionFee != null && vTuitionFee.size() > 0)
{
	for(i = 0; i< vTuitionFee.size(); ++i)
	{
		if( ((String)vTuitionFee.elementAt(i)).compareTo("2") !=0)//not cash, break here.
		{
			i=i+9;
			continue;
		}
		dSubTotalCA += Double.parseDouble((String)vTuitionFee.elementAt(i+3));		
	%>
    <tr> 
      <td><font size="1">&nbsp;</font></td>
      <td height="25"><font size="1"><%=(String)vTuitionFee.elementAt(i+1)%></font></td>
      <td><font size="1">&nbsp;
        <%if(bolIsCancelled){%>
        <font style="color:#FF0000; font-size:9px; font-weight:bold;">Cancelled</font>
        <%}else{%>
        <font size="1">&nbsp;<%=(String)vTuitionFee.elementAt(i+2)%></font>
        <%}%>
</font></td>
      <td><div align="right"><font size="1">&nbsp;<%=CommonUtil.formatFloat((String)vTuitionFee.elementAt(i+3),true)%></font></div></td>
      <td><font size="1">
        <%if(bolIsCancelled){%>
        &nbsp;
        <%}else{%>
        <font size="1"><%=WI.getStrValue(vTuitionFee.elementAt(i+9),"&nbsp;")%></font>
        <%}%>
</font></td>
      <td><font size="1"><%=(String)vTuitionFee.elementAt(i+5)%> 
        <%
	  if(vTuitionFee.elementAt(i+6) != null){%>
        (<%=(String)vTuitionFee.elementAt(i+6)%>) 
        <%}%>
        </font></td>
    </tr>
    <%i = i+9;	}
//I have to remove the entries here.
//for(;i>0;--i)
//	vTuitionFee.removeElementAt(0);
}%>
    <tr> 
      <td height="25"  colspan="3"><div align="right"><font size="1">TOTAL : Php 
          &nbsp;&nbsp;&nbsp;</font></div></td>
      <td><div align="right"><font size="1">&nbsp;<%=CommonUtil.formatFloat(dSubTotalCA,true)%></font></div></td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="6"><font size="1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3"><div align="right"><font size="1">TOTAL COLLECTION 
          :Php &nbsp;&nbsp;&nbsp;</font></div></td>
      <td><font size="1">&nbsp;
	  <%//System.out.println("I am printing."+(double)dSubTotalCash);%>
	  <%=CommonUtil.formatFloat(dSubTotalCash+dSubTotalCheck+dSubTotalCA+dSubTotalCC,true)%></font></td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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

<%}//if collection information is not null.
//only if vEmployeeInfo is not null
}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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
