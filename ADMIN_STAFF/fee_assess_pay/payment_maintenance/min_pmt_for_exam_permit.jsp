<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	if(strAction == "1")
		document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMinAmtForExam,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Required Payment Parameter","min_pmt_for_exam_permit.jsp");
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
														"Fee Assessment & Payments","PAYMENT MAINTENANCE",request.getRemoteAddr(),
														"min_pmt_for_exam_permit.jsp");
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

FAFeeMinAmtForExam FA = new FAFeeMinAmtForExam();
Vector vRetResult = null;

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	if(FA.operateOnMinAmtForExam(dbOP, request,Integer.parseInt(strTemp)) == null)
		strErrMsg = FA.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}
//I have to get all information.
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = FA.operateOnMinAmtForExam(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = FA.getErrMsg();
}
%>
<form name="form_" action="./min_pmt_for_exam_permit.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          MINIMUM REQUIRED PAYMENT PARAMETER PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">SY/TERM</td>
      <td width="42%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	   readonly="yes">
        &nbsp;&nbsp;<select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
      <td width="43%"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a><font size="1">click
        to refresh the page display</font></td>
    </tr>
    <tr>
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="24">&nbsp;</td>
      <td width="22%">Exam Period</td>
      <td width="76%"><select name="pmt_schedule">
	  	<option value="">ALL</option>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Required Minimum to Pay</td>
      <td>
        <input name="amount" type="text" size="6" maxlength="6" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        <select name="unit">
          <option value="0">Amount</option>
<%
strTemp = WI.fillTextValue("unit");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>%</option>
<%}else{%>
          <option value="1">%</option>
<%}%>        </select>
        <select name="parameter">
          <option value="0">Period Amount Due</option>
<%
strTemp = WI.fillTextValue("parameter");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Total Payable Due</option>
<%}else{%>
          <option value="1">Total Payable Due</option>
<%}%>        </select>
        </td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td></td>
      <td> <a href='javascript:PageAction("","1");'>
	  	<img src="../../../images/save.gif" border="0" name="hide_save"></a>
		<font size="1">click to add</font> </td>
    </tr>
    <%}//if iAccessLevel > 1%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center"><strong><font color="#FFFFFF">LIST
          OF EXISTING MINIMUM REQUIRED PAYMENT PARAMETERS</font></strong></div></td>
    </tr>
	</table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td width="21%" height="26"><div align="center"><font size="1"><strong>EXAMINATION
          PERIOD </strong></font></div></td>
      <td width="65%"><div align="center"><font size="1"><strong>REQUIRED MINIMUM
          TO PAY</strong></font></div></td>
      <td width="14%" align="center"><strong><font size="1">SEMESTER</font></strong></td>
      <td width="14%" align="center"><strong><font size="1">DELETE</font></strong></td>
      <!--      <td width="10%" align="center"><font size="1"><strong>DELETE</strong></font></td>-->
    </tr>
    <%
String[] astrCovnertUnit  = {"Amount","Percentage(%)"};
String[] astrCovnertParam = {"PERIOD AMT DUE","TOTAL PAYABLE"};

for(int i = 0 ; i< vRetResult.size() ; i += 7)
{%>
    <tr >
      <td height="25"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"ALL")%> </div></td>
      <td><%=(String)vRetResult.elementAt(i+3)%>,
	  <%=astrCovnertUnit[Integer.parseInt((String)vRetResult.elementAt(i+4))]%>,
	  <%=astrCovnertParam[Integer.parseInt((String)vRetResult.elementAt(i+5))]%></td>
      <td align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"ALL")%></td>
      <td align="center"> <%if(iAccessLevel > 1){%> <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%> <font size="1">Not authorized </font> <%}%> </td>
    </tr>
    <%
	}//end of displaying the entries in loop.
%>
  </table>
<%}//end of displaying the created exising payment schedule entries.
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="6" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
<input type="hidden" name="info_index" value="">
<input type="hidden" name="page_action" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
