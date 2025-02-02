<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

</style>
</head>

<script language="javascript">
function ChangePayeeName() {
	var strPayeeNameNew = prompt('Enter New Payee Name','');
	if(strPayeeNameNew == null || strPayeeNameNew.length == 0) 
		return;
	document.getElementById("lable_pname").innerHTML = strPayeeNameNew;
}
</script>

<%@ page language="java" import="utility.*" %>
<%
	DBOperation dbOP   = null;
	WebInterface WI    = new WebInterface(request);

	String strTemp     = null;
	String strErrMsg   = null;
	String strChkIndex = WI.getStrValue(WI.fillTextValue("chk_index"), "0");
	
//add security here.
	try {
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

String strPayeeName = null;
String strAmount    = null;
String strChkDate   = null;
double dAmount      = 0d;

String strAmountInWords = null;

java.sql.ResultSet rs = dbOP.executeQuery("select AC_CD_CHECK_DTL.PAYEE_NAME, AMOUNT, CHK_DATE from ac_jv join AC_CD_CHECK_DTL on (cd_index = jv_index) where CHK_INDEX = "+strChkIndex);
if(rs.next()) {
	strPayeeName = rs.getString(1);
	dAmount      = rs.getDouble(2);
	strAmount    = CommonUtil.formatFloat(dAmount, true);
	strChkDate   = WI.formatDate(rs.getDate(3), 6);
	strAmountInWords = new ConversionTable().convertAmoutToFigure(dAmount, "","Centavos");
}
rs.close();
dbOP.cleanUP();

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
strSchCode = "CLDH";
%>

<body topmargin="0" bottommargin="0" <%if(strPayeeName != null){%> onLoad="window.print()"<%}%>>

<%if(strPayeeName == null) {%>
<font style="font-size:13px; color:#FF0000; font-weight:bold">Check payment detail not found. Please try to print check again.</font>

<%return;}
int iIndexOf = strAmountInWords.indexOf(" and 0/100 Centavos");
if(iIndexOf > -1 && !strSchCode.startsWith("CLDH"))
	strAmountInWords = strAmountInWords.substring(0,iIndexOf)+" Only";
strAmountInWords = strAmountInWords.toUpperCase();%>
<%if(strSchCode.startsWith("AUF")){///////////////////////////////////////////////// for AUF.%>
<form>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
	  <td height="33" colspan="2">&nbsp;</td>
	  <td colspan="2" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;<%=strChkDate%></td>
  </tr>
	<tr>
		<td colspan="4" height="25">&nbsp;</td>
	</tr>
	<tr>
		<td width="13%">&nbsp;</td>
		<td width="61%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**<label id="lable_pname" onClick="ChangePayeeName()"><%=strPayeeName.toUpperCase()%></label>**</td>
		<td width="1%">&nbsp;</td>
		<td width="25%">**<%=strAmount%>**</td>
	</tr>
	<tr>
	  <td height="19" colspan="4">&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
      <td colspan="3" style="font-size:14px">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  **<%=strAmountInWords%>**</td>
  </tr>
</table>
</form>
<%}else if(strSchCode.startsWith("CLDH")){///////////////////////////////////////////////////// CLDH%>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
	  <td height="33" colspan="2">&nbsp;</td>
	  <td colspan="2" valign="top"><%=strChkDate%></td>
  </tr>
	<tr>
		<td colspan="4" height="25">&nbsp;</td>
	</tr>
	<tr>
		<td width="13%">&nbsp;</td>
		<td width="58%">**<%=strPayeeName.toUpperCase()%>**</td>
		<td width="4%">&nbsp;</td>
		<td width="25%">**<%=strAmount%>**</td>
	</tr>
	<tr>
	  <td height="19" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
      <td colspan="3" style="font-size:14px">**<%=strAmountInWords%>**</td>
  </tr>
</table>
<%}else{%>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
<%//if(strSchCode.startsWith("CGH")){%>
	<tr>
	  <td height="16" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
<%//}%>
	<tr>
	  <td height="33" colspan="2">&nbsp;</td>
	  <td colspan="2" valign="top"><%=strChkDate%></td>
  </tr>
	<tr>
		<td width="13%">&nbsp;</td>
		<td width="58%">**<%=strPayeeName.toUpperCase()%>**</td>
		<td width="4%">&nbsp;</td>
		<td width="25%" valign="top"><table><tr><td>**<%=strAmount%>**</td></tr></table></td>
	</tr>
<%//if(!strSchCode.startsWith("CGH")){%>
	<tr>
	  <td height="19" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
<%//}%>
  </tr>
	<tr>
	  <td>&nbsp;</td>
      <td colspan="3" style="font-size:13px">**<%=strAmountInWords%>**</td>
  </tr>
</table>

<%}%>

</body>
</html>
