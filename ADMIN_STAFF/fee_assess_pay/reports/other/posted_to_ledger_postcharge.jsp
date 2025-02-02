<%@ page language="java" import="utility.*,enrollment.FAExternalPay,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg= null;
	String strTemp   = null;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - External Payments","posted_to_ledger_postcharge.jsp");
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
														"posted_to_ledger_postcharge.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
Vector vSummaryPerCollege = new Vector();
Vector vSummaryPerCourse  = new Vector();
Vector vSummaryGS         = new Vector();//grade school.       


FAExternalPay fa = new FAExternalPay(request);
if(WI.fillTextValue("reloadPage").length() > 0) {
	vRetResult = fa.getPostChargeDetail(dbOP, request);
	if(vRetResult == null) 
		strErrMsg= fa.getErrMsg();
	else {
		vSummaryPerCollege = (Vector)vRetResult.remove(0);
		vSummaryPerCourse  = (Vector)vRetResult.remove(0);
		vSummaryGS         = (Vector)vRetResult.remove(0);
	}
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
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function showList(){
	document.form_.reloadPage.value = "1";
	document.form_.print_page.value = "";
	document.form_.submit();
}
function printPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
	
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
-->
</script>
<body bgcolor="#D2AE72">
<form action="./posted_to_ledger_postcharge.jsp" method="post" name="form_">

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>:::: POST CHARGE POSTED TO LEDGER  ::::</strong></font></strong></font></div></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%">Date Posted </td>
      <td width="81%"> 
        <input name="date_from" type="text" class="textbox" id="date_from" readonly="yes"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.fillTextValue("date_from")%>" size="10"> <a href="javascript:show_calendar('form_.date_from');"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <input name="date_to" type="text" class="textbox" id="date_to"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>" size="10"
	  readonly="yes">
      <a href="javascript:show_calendar('form_.date_to');"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY-Term(optional)</td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
- 
<select name="semester">
          <option value=""></option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.equals("0"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
          <option value="0" <%=strErrMsg%>>Summer</option>
<%
if(strTemp.equals("1"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.equals("2"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%>>3rd Sem</option>
      </select>  	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Rows per page </td>
      <td height="10">
	  <select name="no_of_rows">
<%
strTemp = WI.fillTextValue("no_of_rows");
if(strTemp.length() == 0) 
	strTemp = "45";
int iDef = Integer.parseInt(strTemp);
for(int i =  40; i < 60; ++i) {
	if(i == iDef)
		strErrMsg = " selected";
	else	
		strErrMsg = "";
%>
	<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
<%}%></select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Fee Type  </td>
      <td height="10">
		  <select name="fee_type" onChange="document.form_.reloadPage.value='';document.form_.submit();">
		  <option value=""></option>
<%
strTemp = WI.fillTextValue("fee_type");

if(strTemp.equals("1"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="1"<%=strErrMsg%>>Tuition Type</option>
<%
if(strTemp.equals("0"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="0"<%=strErrMsg%>>Non-Tuition Type</option>
      </select></td>
    </tr>
		  </select>	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Fee Name </td>
      <td height="10"><select name="fee_name" style="width:400px;">
        <option value=""></option>
<%
if(strTemp.equals("1"))
	strErrMsg = " and exists (select * from FA_OTH_SCH_FEE_TUITION  where FEE_NAME_T = fee_name) ";
else if(strTemp.equals("0"))
	strErrMsg = " and not exists (select * from FA_OTH_SCH_FEE_TUITION  where FEE_NAME_T = fee_name) ";
else	
	strErrMsg = "";
%>
        <%=dbOP.loadCombo("distinct fa_oth_sch_fee.fee_name","fa_oth_sch_fee.fee_name"," from fa_oth_sch_fee where is_valid = 1 "+strErrMsg+" order by fa_oth_sch_fee.fee_name", request.getParameter("refund_type"), false)%>
      </select></td>
    </tr>
    
    <tr>
      <td height="10">&nbsp;</td>
      <td>Sort By Option </td>
      <td height="10">
	  <select name="sort_by">
<%
strTemp = WI.fillTextValue("sort_by");
if(strTemp.length() == 0 && strSchCode.startsWith("UC"))
	strTemp = "student.lname, student.fname";

if(strTemp.equals("student.lname, student.fname")) 
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="fa_stud_payable.transaction_date">Transaction Date</option>
        <option value="student.lname, student.fname" <%=strErrMsg%>>Last Name,First Name</option>
      </select>
	  </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>Show Summary </td>
      <td height="10">
	  <select name="show_summary">
	  	<option value="0"></option>
<%
strTemp = WI.fillTextValue("show_summary");
if(strTemp.length() == 0 && strSchCode.startsWith("UC"))
	strTemp = "1";
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="1"<%=strErrMsg%>>Per College</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="2"<%=strErrMsg%>>Per Course</option>
	  </select>
	  
	  </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="10"><a href="javascript:showList()"><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
double dTotal  = 0d; 
if(vRetResult != null) {
String strDateRange = null;
if(WI.fillTextValue("date_to").length() > 0)
	strDateRange = WI.fillTextValue("date_from") +" to "+WI.fillTextValue("date_to");
else	
	strDateRange = WI.fillTextValue("date_from");
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr> 
      <td height="25" align="right" style="font-size:9px;"><a href="javascript:printPg();"><img src="../../../../images/print.gif" border="0"></a>Print Page</td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="7" bgcolor="#cccccc" class="thinborderTOPLEFTRIGHT"><div align="center"><strong><font size="2">LIST OF POST CHARGE POSTED TO LEDGER (<%=strDateRange%>)</font></strong></div></td>
    </tr>
</table>
<%
//System.out.println(vRetResult);

int iPageNo = 1;int i= 0; 
int iCurRow = 0;

while(vRetResult.size() > 0){
if(iPageNo > 1) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold"> 
      <td width="10%" height="25" class="thinborder" style="font-size:9px;">Transaction Date </td>
	  	<td width="10%" class="thinborder" style="font-size:9px;">Student ID </td>
	    <td width="15%" class="thinborder" style="font-size:9px;">Student Name</td>
        <td width="10%" class="thinborder" style="font-size:9px;">Course-Yr</td>
        <td width="7%" class="thinborder" style="font-size:9px;">Amount</td>
        <td width="31%" class="thinborder" style="font-size:9px;">Fee Name </td>
		<td width="12%" class="thinborder" style="font-size:9px;">Fee Type </td>
        <td width="8%" class="thinborder" style="font-size:9px;">Posted By </td>
    </tr>
<%
while(vRetResult.size() > 0) {
++i;
++iCurRow;
if(iCurRow > iDef) {
	iCurRow = 0;
	++iPageNo;
	break;
}
dTotal += 	Double.parseDouble((String)vRetResult.elementAt(3));
%>
    <tr>
      <td height="25" class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(0)%></td>
	  	<td width="10%" class="thinborder"><%=vRetResult.elementAt(1)%></td>
      <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(2)%></td>
      <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(6)%> 
	  <%=WI.getStrValue((String)vRetResult.elementAt(7), "-", "","")%></td>
      <td class="thinborder" style="font-size:10px;" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(3), true)%></td>
      <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(4)%></td>
	  <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(8)%></td>
      <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(5)%></td>
    </tr>
<%
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
}%>
  </table>
<%}//outer while.
}//if vRetResult is not null.

if(dTotal > 0d) {
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" style="font-weight:bold; font-size:12px">Total Post Charge: <%=CommonUtil.formatFloat(dTotal, true)%></td>
    </tr>
  </table>
<%}
strTemp = WI.fillTextValue("show_summary");
if(strTemp.equals("1") && vSummaryPerCollege.size() > 0){//summary per college%>
  <table width="50%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold"> 
      <td width="50%" height="22" class="thinborder">College</td>
      <td width="50%" class="thinborder">Amount</td>
    </tr>
	<%for(int i =0; i < vSummaryPerCollege.size(); i += 3) {%>
		<tr> 
		  <td height="22" class="thinborder"><%=vSummaryPerCollege.elementAt(i + 1)%></td>
		  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vSummaryPerCollege.elementAt(i + 2)).doubleValue(), true)%></td>
	    </tr>
	<%}%>
	<%for(int i =0; i < vSummaryGS.size(); i += 3) {%>
		<tr> 
		  <td height="22" class="thinborder"><%=vSummaryGS.elementAt(i + 1)%></td>
		  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vSummaryGS.elementAt(i + 2)).doubleValue(), true)%></td>
	    </tr>
	<%}%>
  </table>

<%}if(strTemp.equals("2") && vSummaryPerCourse.size() > 0){%>
  <table width="50%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold"> 
      <td width="33%" height="22" class="thinborder">Course</td>
      <td width="33%" class="thinborder">Amount</td>
    </tr>
	<%for(int i =0; i < vSummaryPerCourse.size(); i += 3) {%>
		<tr> 
		  <td height="22" class="thinborder"><%=vSummaryPerCourse.elementAt(i + 1)%></td>
		  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vSummaryPerCourse.elementAt(i + 2)).doubleValue(), true)%></td>
	    </tr>
	<%}%>
	<%for(int i =0; i < vSummaryGS.size(); i += 3) {%>
		<tr> 
		  <td height="22" class="thinborder"><%=vSummaryGS.elementAt(i + 1)%></td>
		  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vSummaryGS.elementAt(i + 2)).doubleValue(), true)%></td>
	    </tr>
	<%}%>
  </table>

<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable4">
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