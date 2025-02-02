<%if(request.getSession(false).getAttribute("is_sap") == null) {%>
	<p style="font-family:Verdana, Arial, Helvetica, sans-serif; font-weight:bold; font-size:18px; color:#FF0000">You are not authorized to view this link. </p>
	<%return;

}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;

	document.form_.submit();
}
function ShowProcessing()
{
	imgWnd=
	window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	imgWnd.focus();
	return true;
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}
</script>

<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<%@ page language="java" import="utility.*,sap.Configuration,sap.Payment, java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation();

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
String strMapStatus = null; 

//check number of tellers not mapped.. 
strTemp = "select count(distinct created_by) from fa_stud_payment "+
			"where fa_stud_payment.is_valid = 1 and amount > 0 and or_number is not null and not exists "+
			"(select * from SAP_TELLER_MAP where user_index = created_by)";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(!strTemp.equals("0"))
	strMapStatus = "Can't Proceed with Mapping. Teller IDs are not mapped. Total Count: "+strTemp;

if(strErrMsg == null && WI.fillTextValue("generate_").length() > 0) {
	Payment pmt = new Payment();
	pmt.generateNonTuitionPayment(dbOP, request);
	strErrMsg = pmt.getErrMsg();
}

%>


<form name="form_" action="./payment_non_tuition.jsp" method="post" onSubmit="SubmitOnceButton(this);return ShowProcessing();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: PAYMENT - NON TUITION ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
	<%if(strMapStatus != null) {%>
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3" style="color:#FF0000"><b><%=strMapStatus%></b></font></td>
    </tr>
	<%}%>
  </table>
<%if(strMapStatus == null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr style="font-weight:bold;">
      <td width="6%" height="25">&nbsp;</td>
      <td colspan="4" style="font-size:18px">		Payment Date: 
	  <input name="date_fr" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_fr")%>" class="textbox" style="font-size:18px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>

-

	  <input name="date_to" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_to")%>" class="textbox" style="font-size:18px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>

	  </td>
    </tr>
    <tr>
      <td height="60">&nbsp;</td>
      <td width="8%" align="center">&nbsp;</td>
      <td width="54%" align="center" valign="bottom">
	  
	  <input type="submit" name="122" value="Generate Payment (Non-Tuition Payments)" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.generate_.value='1';ShowProcessing();">
	  </td>
      <td width="25%" align="center">&nbsp;</td>
      <td width="7%" align="center">&nbsp;</td>
    </tr>
  </table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="generate_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
