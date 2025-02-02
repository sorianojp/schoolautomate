<%
String strUserID = (String)request.getSession(false).getAttribute("userId");
if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}
if(!strUserID.toLowerCase().equals("sa-01")){%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are not allowed to access this link.</p>
<%return;}%>

<%@ page language="java" import="utility.*,sms.SystemSetup,sms.utility.CommonInterface, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;
	document.form_.submit();
}
function focusID() {
	document.form_.mobile.focus();
}
function PreparedToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.preparedToEdit.value = '1';
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	try {
		dbOP = new DBOperation(strUserID,"SMS-Setting","alert.jsp");
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

Vector vEditInfo = null;Vector vRetResult = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");

SystemSetup systemSetup = new SystemSetup();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(systemSetup.operateOnAlert(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = systemSetup.getErrMsg();
	else {
		strErrMsg = "Operation Successful.";
		strPreparedToEdit = "0"; 
	}
}
if(strPreparedToEdit.equals("1"))
	vEditInfo = systemSetup.operateOnAlert(dbOP, request, 3);
vRetResult = systemSetup.operateOnAlert(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null) 
	strErrMsg = systemSetup.getErrMsg();
%>
<form action="./alert.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: Alert Listing::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-weight:bold; color:#FF0000; font-size:15px">Must Read  : Only System provider of SMS Service should Add Alert. Keywords are encoded in ##. Incase there is any error in message content, pls contact system admin to do modification. </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Alert Reference </td>
      <td width="80%">
	  <select name="alert_ref">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(0);
else
	strTemp = WI.fillTextValue("alert_ref");

if(strTemp.length() == 0) 
	strTemp = "0";
int iTemp = Integer.parseInt(strTemp);

for(int i = 1; i <= 15; ++i) {
	if(iTemp == i)
		strErrMsg = "selected";
	else
		strErrMsg = "";
	%><option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
<%}%>
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Alert Description  </td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("desc");
%>
      <input type="text" name="desc" value="<%=strTemp%>" class="textbox" style="font-size:11px;" size="64"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="64"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Alert Message </td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("message");
%>
      <input type="text" name="message" value="<%=strTemp%>" class="textbox" style="font-size:11px;" size="124"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="124"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="27%">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="34%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" align="center">
<%
if(strPreparedToEdit.equals("0")){%>
	  	
		<input type="submit" name="1" value="&nbsp;&nbsp;Save&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';document.form_.preparedToEdit.value='';document.form_.info_index.value='';">
		<!--Save Not Allowed. Pls contact System Admin.-->
<%}else{%>
	  	<input type="submit" name="10" value="&nbsp;&nbsp;Edit&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=vEditInfo.elementAt(0)%>';">
	  	&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="submit" name="100" value="&nbsp;&nbsp;Cancel&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';">
<%}%>	  </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="136%" height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">ALERTS CURRENTLY AVAILABLE IN SYSTEM</font></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="11%" height="25" align="center" style="font-size:9px; font-weight:bold;">Alert Reference </td>
      <td width="11%" align="center" style="font-size:9px; font-weight:bold;">Alert Description </td>
      <td width="15%" style="font-size:9px; font-weight:bold;" align="center">New Alert Message </td>
      <td width="15%" style="font-size:9px; font-weight:bold;" align="center">Original Message </td>
<%if(false){%>
      <td width="11%" style="font-size:9px; font-weight:bold;" align="center">Edit</td>
      <td width="11%" style="font-size:9px; font-weight:bold;" align="center">Delete</td>
<%}%>
    </tr>
<%//System.out.println(vRetResult);
String strBGColor = "";
for(int i=0; i<vRetResult.size(); i+=5){
if(vRetResult.elementAt(i + 3).equals("0"))
	strBGColor = "bgcolor='#cccccc'";
else	
	strBGColor = "";
%>
    <tr <%=strBGColor%>> 
      <td height="25"><%=(String)vRetResult.elementAt(i)%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td ><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=(String)vRetResult.elementAt(i + 4)%></td>
<%if(false){%>
      <td align="center"><a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i)%>');"><img src="../../../images/edit.gif" border="0"></a></td>
      <td align="center"><a href="javascript:PageAction('<%=(String)vRetResult.elementAt(i)%>','0');"><img src="../../../images/delete.gif" border="0"></a></td>
<%}%>
    </tr>
<%}%>
  </table>
  <%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>