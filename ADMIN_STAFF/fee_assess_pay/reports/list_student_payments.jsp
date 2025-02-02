<%@ page language="java" import="utility.*,enrollment.FAExternalPay,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - Student Payment Listing","list_student_payments.jsp");
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
														"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(),
														"list_student_payments.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
FAExternalPay fa = new FAExternalPay(request);
int iSearchResult = 0;
if(WI.fillTextValue("reloadPage").equals("1")) {
	vRetResult = fa.getStudentPaymentList(dbOP, request);
	if(vRetResult == null)
		strErrMsg = fa.getErrMsg();
}




String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript">
<!--
function ReloadPage(){
	document.form_.reloadPage.value ="";
	document.form_.print_page.value = "";
	document.form_.submit();
}
function showList(){
	document.form_.reloadPage.value = "1";
	document.form_.print_page.value = "";
	document.form_.submit();
}

function clearAll(){
	document.form_.date_from.value = "";
	document.form_.date_to.value = "";
}

function PrintPg(){
	document.form_.print_page.value = "1";
	document.form_.submit();	
}
-->
</script>
<body bgcolor="#D2AE72">
<form action="./list_student_payments.jsp" method="post" name="form_">

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5" align="center" style="font-weight:bold; color:#FFFFFF">
	  	:::: STUDENT PAYMENT LISTING PAGE ::::</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:9px; font-weight:bold; color:#0000FF">
<%
strTemp = WI.fillTextValue("show_all");

if(strTemp.equals("1") || strTemp.length() == 0) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  
	  <input type="radio" name="show_all" value="1" <%=strErrMsg%>> Show ALL  
<%
if(strTemp.equals("2")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  
	  <input type="radio" name="show_all" value="2" <%=strErrMsg%>> Show Only Enrolled
	  
<%
if(strTemp.equals("3")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  
	  <input type="radio" name="show_all" value="3" <%=strErrMsg%>> Show Only Not Enrolled	  </td>
	</tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY-TERM</td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0 && request.getParameter("sy_from") == null) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0 && request.getParameter("sy_from") == null) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>"
		 class="textbox" readonly="true">
	  <select name="semester">
	  <option value="1">1st Sem</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="3"<%=strErrMsg%>>3rd Sem</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="0"<%=strErrMsg%>>Summer</option>
	  </select>	  </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%">Date of Payment</td>
      <td width="81%"> 
        <input name="date_from" type="text" class="textbox" id="date_from" readonly="yes"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.fillTextValue("date_from")%>" size="10"> <a href="javascript:show_calendar('form_.date_from');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <input name="date_to" type="text" class="textbox" id="date_to"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>" size="10"
	  readonly="yes">
      <a href="javascript:show_calendar('form_.date_to');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:clearAll();"><img src="../../../images/clear.gif" width="55" height="19" border="0"></a></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Last Name </td>
      <td height="10">
	  <input name="lname" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("lname")%>" size="32">	</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Student ID </td>
      <td height="10">
	  <input name="stud_id" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("stud_id")%>" size="32">	  </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="10"></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="10"><a href="javascript:showList()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="15">&nbsp;</td>
    </tr>
  </table>
 <% if (vRetResult != null) {
 double dTotal = 0d;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr> 
      <td height="25" colspan="7" bgcolor="#cccccc" class="thinborderTOPLEFTRIGHT"><div align="center"><strong><font size="2">LIST OF PAYMENT</font></strong></div></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="3%" class="thinborder">Count</td> 
      <td width="7%" height="22" class="thinborder"><font size="1">Date</font></td>
      <td width="15%" class="thinborder"><font size="1">Student ID</font></td>
      <td width="25%" class="thinborder"><font size="1">Student Name</font></td>
      <td width="10%" class="thinborder"><font size="1">OR Number</font></td>
      <td width="10%" class="thinborder"><font size="1">AMOUNT</font></td>
      <td width="8%" class="thinborder"><font size="1">Fee Type</font></td>
      <td width="22%" class="thinborder"><font size="1">Fee Name</font></td>
    </tr>
<%for (int i= 0; i < vRetResult.size() ; i+=7) {
	dTotal += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+4),",",""));%>
    <tr>
      <td class="thinborder"><%=i/7 + 1%>.</td> 
      <td height="22" class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td  class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td  class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder" align="right"> <%=(String)vRetResult.elementAt(i+4)%>&nbsp;</td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6), "&nbsp;")%></td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr>
      <td height="22" colspan="8" style="font-size:14px; font-weight:bold">Total Amount: <%=CommonUtil.formatFloat(dTotal, true)%></td> 
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td width="50%" height="20" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>