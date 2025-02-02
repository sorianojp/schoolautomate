<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function FocusID() {
	//document.form_.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}

</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.CheckPayment, java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg   = null;
	String strTemp     = null;
	Vector vRetResult = null;
	Vector vTemp1 = null;
	Vector vTemp2 = null;
	String strCol = null;
	int iCtr = 0;
	String[] astrConvertToSem = {"SU","1ST","2ND","3RD"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Installment fees","view_check_payments.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
							//							"view_check_payments.jsp");
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
CheckPayment chkPmt = new CheckPayment();
if(WI.fillTextValue("stud_id").length() > 0 && WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("semester").length()>0) 
{	
		vRetResult = chkPmt.getChkPaymentDtls(dbOP, WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("semester"));
		if (vRetResult == null)
			strErrMsg = chkPmt.getErrMsg();
}

%>
<form name="form_" action="./view_check_payments.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PRINT RE-ASSESSMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp; <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2">School Year/Term</td>
      <td height="25" colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="53%" height="25">&nbsp; </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Student ID &nbsp;</td>
      <td width="20%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
      </td>
      <td width="11%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size()>0){
  vTemp1 = (Vector)vRetResult.elementAt(1);
  vTemp2 = (Vector)vRetResult.elementAt(2);
  if (vTemp1!= null && vTemp1.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td colspan="4" bgcolor="#B9B292" height="22" class="thinborder"><font color="#FFFFFF"><strong>Current Payments</strong></font></td>
	</tr>
	<tr>
	<td width="20%" class="thinborder" height="22" align="center"><font size="1"><strong>OR NUMBER</strong></font></td>
	<td width="20%" class="thinborder" align="center"><font size="1"><strong>CHECK NUMBER</strong></font></td>
	<td width="50%" class="thinborder" align="center"><font size="1"><strong>BANK DETAILS</strong></font></td>
	<td width="10%" class="thinborder" align="center"><font size="1"><strong>AMOUNT</strong></font></td>
	</tr>
	<%
	for (iCtr = 0; iCtr < vTemp1.size(); iCtr+=8){
	if (((String)vTemp1.elementAt(iCtr+7)).equals("1"))
	strCol = " bgcolor='#F5CFD0'";
	else
	strCol = " bgcolor='#FFFFFF'";%>
	<tr <%=strCol%>>
		<td class="thinborder" height="22"><font size="1">&nbsp;<%=(String)vTemp1.elementAt(iCtr+3)%></font></td>
		<td class="thinborder"><font size="1">&nbsp;<%=(String)vTemp1.elementAt(iCtr+4)%></font></td>
		<td class="thinborder"><font size="1">&nbsp;<%=(String)vTemp1.elementAt(iCtr+5)%></font></td>
		<td class="thinborder"><font size="1">&nbsp;<%=CommonUtil.formatFloat(Double.parseDouble((String)vTemp1.elementAt(iCtr+6)),true)%>
		</font></td>
	</tr>
	<%}%>
  </table>
  <%}
  if (vTemp2 != null && vTemp2.size()>0){%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td colspan="5" bgcolor="#B9B292"  height="22" class="thinborder"><font color="#FFFFFF"><strong>Other Payments</strong></font></td>
	</tr>
	<tr>
	<td width="20%" class="thinborder" height="22" align="center"><font size="1"><strong>SY INFO</strong></font></td>
	<td width="15%" class="thinborder" align="center"><font size="1"><strong>OR NUMBER</strong></font></td>
	<td width="15%" class="thinborder" align="center"><font size="1"><strong>CHECK NUMBER</strong></font></td>
	<td width="40%" class="thinborder" align="center"><font size="1"><strong>BANK DETAILS</strong></font></td>
	<td width="10%" class="thinborder" align="center"><font size="1"><strong>AMOUNT</strong></font></td>
	</tr>
	<%for (iCtr = 0; iCtr < vTemp2.size(); iCtr+=8){
	if (((String)vTemp2.elementAt(iCtr+7)).equals("1"))
	strCol = " bgcolor='#F5CFD0'";
	else
	strCol = " bgcolor='#FFFFFF'";%>
	<tr <%=strCol%>>
		<td class="thinborder" height="22"><font size="1">&nbsp;<%=(String)vTemp2.elementAt(iCtr+0)%> - 
		<%=(String)vTemp2.elementAt(iCtr+1)%> <%=astrConvertToSem[Integer.parseInt((String)vTemp2.elementAt(iCtr+2))]%></font></td>
		<td class="thinborder"><font size="1">&nbsp;<%=(String)vTemp2.elementAt(iCtr+3)%></font></td>
		<td class="thinborder"><font size="1">&nbsp;<%=(String)vTemp2.elementAt(iCtr+4)%></font></td>
		<td class="thinborder"><font size="1">&nbsp;<%=(String)vTemp2.elementAt(iCtr+5)%></font></td>
		<td class="thinborder"><font size="1">&nbsp;<%=CommonUtil.formatFloat(Double.parseDouble((String)vTemp2.elementAt(iCtr+6)),true)%></font></td>
	</tr>
	<%}%>
  </table>
  <%}}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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