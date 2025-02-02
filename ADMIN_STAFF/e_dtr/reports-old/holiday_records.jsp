<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	ViewRecords();
}	
function ReloadPage()
{
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value ="0";
	document.dtr_op.submit();
}

function ViewRecords()
{
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.submit();
}
function CallPrint()
{
	document.dtr_op.action = "./dtr_print.jsp";
}
function PrintPg() {
	var pgLoc = "../dtr_operations/set_holidays_print.jsp?yyyy_to_view="+
		document.dtr_op.yyyy_to_view.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.Holidays, eDTR.eDTRUtil" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;

	

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-School Year Holidays",
								"holiday_records.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"holiday_records.jsp");	
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
Holidays hol = new Holidays();

vRetResult = hol.getHolidays(dbOP, request,null);

strErrMsg = hol.getErrMsg();

strTemp = request.getParameter("dateFrom");
strTemp2 = request.getParameter("dateTo");

/**
if (strTemp!=null && strTemp2!=null && strTemp.length() > 0 && strTemp2.length() > 0){
	strTemp = "(" + strTemp + "-" + strTemp2 +")";	
}
**/

%>
<form action="./holiday_records.jsp" name="dtr_op" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" >
	  <strong>:::: LIST OF HOLIDAYS ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;</td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="5" cellspacing="5" bgcolor="#FFFFFF">
    <tr> 
      <td><%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
    <tr>
      <td>View Holiday for: 
        <%
strTemp = WI.fillTextValue("yyyy_to_view");
if(strTemp.length() == 0) 
	strTemp = Integer.toString(java.util.Calendar.getInstance().get(java.util.Calendar.YEAR));
%>
        <input name="yyyy_to_view" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        (YYYYY) &nbsp;&nbsp;<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
<!--    <tr> 
      <td><strong>Date</strong> &nbsp;&nbsp;&nbsp;&nbsp;:: &nbsp;From: 
        <input name="dateFrom" type="text"  id="from_date2" size="12" readonly="true"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("dateFrom")%>"> 
        <a href="javascript:show_calendar('dtr_op.dateFrom');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To 
        : 
        <input name="dateTo" type="text"  id="to_date2" size="12" readonly="true" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("dateTo")%>"> 
        <a href="javascript:show_calendar('dtr_op.dateTo');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;&nbsp; 
        <input name="image" type="image" onClick="ViewRecords()" src="../../../images/form_proceed.gif" width="81" height="21"></td>
    </tr>
-->
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td align="right"> 
        <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
      </td>
  </tr>
</table>

  <table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4" bgcolor="#006666"><p align="center"><strong><font color="#FFFFFF">LIST 
          OF HOLIDAYS &nbsp;<%=WI.getStrValue(strTemp)%></font></strong></p></td>
    </tr>
    <tr> 
      <td width="33%" align="center"><strong>Name </strong></td>
      <td width="23%"><strong>Date </strong></td>
      <td width="25%"><strong>Holiday Type</strong></td>
      <td width="19%"><strong>OT Rate</strong></td>
    </tr>
<% if (vRetResult != null) { 
	for (int i = 0; i < vRetResult.size() ; i +=7){
	strTemp = (String)vRetResult.elementAt(i+5);
	strTemp2 = (String)vRetResult.elementAt(i+6);
	
	if (strTemp2.compareTo("0") == 0)
		strTemp =  strTemp + "%";
	else
		strTemp = "Php" + strTemp;
%>
	
    <tr> 
      <td><%=(String)vRetResult.elementAt(i)%></td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=(String)vRetResult.elementAt(i+2)%></td>
	  <td><%=strTemp%></td>
    </tr>
<% }//end for loop%>
    <tr> 
      <td colspan="4">
		<hr size="1">
      </td>
    </tr>
<%} else{ %>
	<tr>
	<td colspan="4">
	<%=strErrMsg%>
	</td>
	</tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
	</table>
 <input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>"> 
        <input type=hidden name="viewRecords" value="0">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>