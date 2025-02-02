<%
String strUserID = (String)request.getSession(false).getAttribute("userId");
if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}

//if(!strUserID.toLowerCase().equals("sa-01")){%>
	<!--
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are not allowed to access this link.</p>
	-->
<%//return;}%>

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
</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	try {
		dbOP = new DBOperation(strUserID,"SMS-Setting","comport_provider_map.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

Vector vRetResult = null;

SystemSetup systemSetup = new SystemSetup();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(systemSetup.operateOnComportToHandleProvider(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = systemSetup.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}
vRetResult = systemSetup.operateOnComportToHandleProvider(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null) 
	strErrMsg = systemSetup.getErrMsg();
%>
<form action="./comport_provider_map.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: COMPORT MAPPING ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Comport Number </td>
      <td width="80%">
	  <select name="comport_ref">
<%
//i have to find the comports already registered.. 
strTemp = "select COMPORT_NO,MOBILE_NO,provider_name from SMS_COMPORT_SIM "+
	"join SMS_GSM_PROVIDER_PREFIX on (SMS_COMPORT_SIM.prefix_index = SMS_GSM_PROVIDER_PREFIX.prefix_index) "+
	"join SMS_GSM_PROVIDER on (SMS_GSM_PROVIDER.provider_index = SMS_GSM_PROVIDER_PREFIX.provider_index) "+
	"where is_active = 1 order by comport_no";
 java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
 while(rs.next()){
 	strErrMsg = rs.getString(1);
	%>
		<option value="<%=strErrMsg%>">COM<%=strErrMsg%> (<%=rs.getString(2) +" - "+rs.getString(3)%>) </option>
<%}
rs.close();
%>	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Service Provider To Handle </td>
      <td><select name="provider_ref" style="font-size:11px;font-weight:bold">
	  	<%=dbOP.loadCombo("PROVIDER_INDEX","PROVIDER_NAME"," from SMS_GSM_PROVIDER order by provider_name asc", null, false)%>
      </select></td>
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
	  	<input type="submit" name="1" value="&nbsp;&nbsp;Save&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';document.form_.info_index.value='';">
	  </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="136%" height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">COMPORT TO HANDLE SERVICE PROVIDER </font></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="11%" height="25" align="center" style="font-size:9px; font-weight:bold;">Comport Number and SIM Number connected </td>
      <td width="11%" align="center" style="font-size:9px; font-weight:bold;">Service Provider </td>
      <td width="11%" style="font-size:9px; font-weight:bold;" align="center">Delete</td>
    </tr>
<%//System.out.println(vRetResult);
for(int i=0; i<vRetResult.size(); i+=5){
%>
    <tr> 
      <td height="25">COM<%=(String)vRetResult.elementAt(i + 1)%>(<%=vRetResult.elementAt(i + 4)%>)</td>
      <td><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td align="center"><a href="javascript:PageAction('<%=(String)vRetResult.elementAt(i)%>','0');"><img src="../../../images/delete.gif" border="0"></a></td>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>