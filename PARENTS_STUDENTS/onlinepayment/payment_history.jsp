<%
String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");

if(strAuthIndex == null || !strAuthIndex.equals("4")) {%>
<p style="font-size:16px; font-weight:bold; color:#FF0000">You are already logged out. Please login again.
<%return;}%>

<%@ page language="java" import="utility.*,onlinepayment.OnlinePayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
			<p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%
		return;
	}

OnlinePayment op = new OnlinePayment();


String strSucFail = WI.fillTextValue("suc_fail");
String strSYFrom   = WI.fillTextValue("sy_from");
String strSYTo   = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");
String strTransDateFrom = WI.fillTextValue("date_from");
String strTransDateTo = WI.fillTextValue("date_to");


	int iCount=0;
	if(strSYFrom.length() == 0) {
		strSYFrom   = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		strSemester = (String)request.getSession(false).getAttribute("cur_sem");
	}
	
 Vector vRetResult = new Vector();
 if(WI.fillTextValue("show_data").length() > 0){
	
	vRetResult = op.getPaymentReportStudent(dbOP, request);
	if(vRetResult == null)
		strErrMsg = op.getErrMsg();	
 }	
  int iMaxStudPerPage =20; 
		
		if (WI.fillTextValue("num_stud_page").length() > 0){
			iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
		}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head><style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
-->
</style>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../Ajax/ajax.js" ></script>
<script language="JavaScript">

function showList(){
	document.report_student.show_data.value = "1";
	document.report_student.submit();
}

</script>
<body>
<jsp:include page="./inc.jsp?pgIndex=2" />

<form name="report_student" action="payment_history.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5" align="center" style="font-weight:bold; color:#FFFFFF"> :::: ONLINE PAYMENT REPORT (FOR STUDENT) PAGE ::::</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="10%">SY-TERM</td>
      <td width="31%"><input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
		    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		    onkeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" 
			onKeyUp='AllowOnlyInteger("report_student","sy_from");DisplaySYTo("report_student","sy_from","sy_to")'/>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onkeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        <select name="semester" onChange="document.report_school.submit()">
          <%	
		  strSemester = WI.fillTextValue("semester");
		if(strSemester.equals("1"))
		
			strErrMsg = " selected";
		else
			strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st Sem</option>
          <%
		if(strSemester.equals("2"))
			strErrMsg = " selected";
		else
			strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
          <%
		if(strSemester.equals("3"))
			strErrMsg = " selected";
		else
			strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>3rd Sem</option>
          <%
		if(strSemester.equals("0"))
			strErrMsg = " selected";
		else
			strErrMsg = "";
%>
          <option value="0"<%=strErrMsg%>>Summer</option>
      </select> (only if success)      </td>
      <td width="57%" >Process Status: 
        <select name="suc_fail" style="width:100px">
          <option value=""></option>
          <%	
if(strSucFail.equals("1"))

	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="1"<%=strErrMsg%>>Success</option>
          <%	
if(strSucFail.equals("1"))

	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="-1"<%=strErrMsg%>>Show All Failed</option>
          <%
if(strSucFail.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="0"<%=strErrMsg%>>Failed</option>
          <%
if(strSucFail.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>Failed - In Progress</option>
          <%
if(strSucFail.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>Failed - Stopped before payment process</option>
          <%
if(strSucFail.equals("4"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="4"<%=strErrMsg%>>Failed - Stopped before processing</option>
      </select></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="10%">Transaction Date</td>
      <td>
<%
strTemp = WI.fillTextValue("date_from");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
	  <input name="date_from" type="text" class="textbox" id="date_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=strTemp%>" size="10" />
        <a href="javascript:show_calendar('report_student.date_from');"><img src="../../images/calendar_new.gif" width="20" height="16" border="0" /></a> to
        <input name="date_to" type="text" class="textbox" id="date_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>" size="10"
	  />
        <a href="javascript:show_calendar('report_student.date_to');"><img src="../../images/calendar_new.gif" width="20" height="16" border="0" /></a> </td>
	 <td></td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="15" ></td>
	 <td></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="10"><a href="javascript:showList()"><img src="../../images/form_proceed.gif" border="0" /></a></td>
	 <td></td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="15">&nbsp;</td>
	 <td></td>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="7" bgcolor="#cccccc" class="thinborderTOPLEFTRIGHT"><div align="center"><strong><font size="2">VIEW PAYMENT DETAIL</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="6%" class="thinborder"><font size="1">Transaction Ref.</font></td>
      <td width="10%" height="22" class="thinborder"><font size="1">Transaction/OR #.</font></td>
      <td width="8%" class="thinborder"><font size="1">Date Paid</font></td>
      <td width="8%" class="thinborder"><font size="1">Amount Paid</font></td>
      <td width="10%" class="thinborder"><font size="1">Payment For</font></td>
      <td width="8%" class="thinborder"><font size="1">SY-Term</font></td>
      <td width="10%" class="thinborder"><font size="1">Payment- Type</font></td>
      <td width="10%" class="thinborder"><font size="1">Transaction Status</font></td>
      <td width="30%" class="thinborder"><font size="1">Reason</font></td>
    </tr>
    <%for(int i=1; i<vRetResult.size(); i+=10) {%>
    <tr>
      <td class="thinborder" height="22"><%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1), "&nbsp;")%></td>
      <td  class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td  class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td  class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%> - <%=(String)vRetResult.elementAt(i+6)%> </td>
      <td class="thinborder" ><%=(String)vRetResult.elementAt(i+7)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+9), "&nbsp;")%></td>
    </tr>
    <%}%>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td><strong>Total Successful Payment: <%=vRetResult.remove(0)%></strong></td>
    </tr>
  </table>
  <%}%>
  <input type="hidden" name="reloadPage" value="0">
  <input type="hidden" name="show_data" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
