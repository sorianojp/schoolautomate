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
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	if(strSchCode.startsWith("VMA")){%>
		<jsp:forward page="./print_check_VMA.jsp"></jsp:forward>
	<%return;}
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

String strVoucherNumber = null;//needed to be printed for WNU.. 

String strAmountInWords = null;

String strInfo5 = (String)request.getSession(false).getAttribute("info5");
boolean bolIsSeacrest = false;
if(strInfo5 != null && strInfo5.equals("SEACREST"))
	bolIsSeacrest = true;


String strCheckNo   = null;
String strBankIndex = null;

java.sql.ResultSet rs = dbOP.executeQuery("select AC_CD_CHECK_DTL.PAYEE_NAME, AMOUNT, CHK_DATE, check_no, bank_index,jv_number from ac_jv join AC_CD_CHECK_DTL on (cd_index = jv_index) where CHK_INDEX = "+strChkIndex);
if(rs.next()) {
	strPayeeName = rs.getString(1);
	dAmount      = rs.getDouble(2);
	strAmount    = CommonUtil.formatFloat(dAmount, true);
	strChkDate   = WI.formatDate(rs.getDate(3), 6);
	strAmountInWords = new ConversionTable().convertAmoutToFigure(dAmount, "","Centavos");
		
	strCheckNo   = rs.getString(4);
	strBankIndex = rs.getString(5);
	
	strVoucherNumber = rs.getString(6);
}
rs.close();

///if check no. starts with *, i have to sum the amount.. 
if(strCheckNo != null && strCheckNo.startsWith("*")) {
	String strSQLQuery = "select cd_index,amount from AC_CD_CHECK_DTL where check_no='"+strCheckNo+"' and bank_index="+strBankIndex;
	rs = dbOP.executeQuery(strSQLQuery);
	strSQLQuery = null; dAmount = 0d;
	while(rs.next()) {
		if(strSQLQuery == null)
			strSQLQuery = rs.getString(1);
		else	
			strSQLQuery += ","+rs.getString(1);
		dAmount += rs.getDouble(2);
	}
	rs.close();
	//I now have sum of amout.. 
	strSQLQuery = "update ac_jv set IS_LOCKED = 1, LOCK_DATE='" + WI.getTodaysDate() +
        "' where jv_index in (" + strSQLQuery+ ") and is_locked = 0";
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	
	strAmountInWords = new ConversionTable().convertAmoutToFigure(dAmount, "","Centavos");
	strAmount        = CommonUtil.formatFloat(dAmount, true);
}

if(strSchCode.startsWith("AUF") && strAmountInWords != null)
	strAmountInWords = ConversionTable.replaceString(strAmountInWords,"-"," ");
		
dbOP.cleanUP();

if(strSchCode.startsWith("TSUNEISHI") || bolIsSeacrest)
	strAmountInWords = new ConversionTable().convertAmoutToFigure(dAmount, ""," PESOS ONLY");

%>

<body topmargin="0" bottommargin="0" <%if(strPayeeName != null){%> onLoad="window.print()"<%}%>>

<%if(strPayeeName == null) {%>
<font style="font-size:13px; color:#FF0000; font-weight:bold">Check payment detail not found. Please try to print check again.</font>

<%return;}
int iIndexOf = strAmountInWords.indexOf(" and 0/100 Centavos");
if(iIndexOf > -1 && !strSchCode.startsWith("CLDH"))
	strAmountInWords = strAmountInWords.substring(0,iIndexOf)+" Only";
strAmountInWords = strAmountInWords.toUpperCase();

if(strSchCode.startsWith("AUF"))
	strSchCode = "CLDH";

if(strSchCode.startsWith("AUF") ){///////////////////////////////////////////////// for AUF.%>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
	  <td height="20" colspan="2">&nbsp;</td>
	  <td colspan="2" valign="bottom" style="font-weight:bold">&nbsp;&nbsp;&nbsp;&nbsp;<%=strChkDate%></td>
  </tr>
	<tr>
		<td colspan="4" height="10">&nbsp;</td>
	</tr>
	<tr style="font-weight:bold">
		<td width="13%">&nbsp;</td>
		<td width="61%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**<label id="lable_pname" onClick="ChangePayeeName()"><%=strPayeeName.toUpperCase()%></label>**</td>
		<td width="1%">&nbsp;</td>
		<td width="25%">**<%=strAmount%>**</td>
	</tr>
	<tr>
	  <td height="10" colspan="4">&nbsp;</td>
  </tr>
	<tr style="font-weight:bold">
	  <td>&nbsp;</td>
      <td colspan="3" style="font-size:14px">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  **<%=strAmountInWords%>**</td>
  </tr>
</table>
<%}else if(strSchCode.startsWith("CLDH") || strSchCode.startsWith("CGH")){///////////////////////////////////////////////////// CLDH%>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
	  <td height="20" colspan="2">&nbsp;</td>
	  <td colspan="3" valign="bottom">&nbsp;</td>
  </tr>
	<tr valign="bottom">
		<td height="28">&nbsp;</td>
	    <td width="58%" height="28">&nbsp;</td>
	    <td width="2%" height="28">&nbsp;</td>
        <td height="28" colspan="2"><br>&nbsp;&nbsp;<%=strChkDate%></td>
	</tr>
	<tr>
		<td width="13%">&nbsp;</td>
		<td colspan="4">&nbsp;</td>
	</tr>
	<tr>
	  <td height="22">&nbsp;</td>
      <td colspan="3" style="font-size:<%if(strSchCode.startsWith("CGH")){%>11px<%}else{%>13px<%}%>">**<%=strPayeeName.toUpperCase()%>**</td>
      <td width="23%" style="font-size:<%if(strSchCode.startsWith("CGH")){%>13px<%}else{%>13px<%}%>">**<%=strAmount%>**</td>
  </tr>
	<tr>
		<td width="13%">&nbsp;</td>
		<td colspan="4">&nbsp;</td>
	</tr>
<%
iIndexOf = strAmountInWords.toLowerCase().indexOf("centavos");
if(iIndexOf > -1)
	strAmountInWords = strAmountInWords.substring(0,iIndexOf) + "ONLY";
%>	<tr>
      <td>&nbsp;</td>
      <td colspan="4" style="font-size:<%if(strSchCode.startsWith("CGH")){%>11px<%}else{%>13px<%}%>">**<%=strAmountInWords%>**</td>
  </tr>
</table>
<%}else if(strSchCode.startsWith("WNU")){%>
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
		<td>&nbsp;</td>
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**<%=strPayeeName.toUpperCase()%>**</td>
		<td>&nbsp;</td>
		<td width="25%" valign="top"><table><tr><td>**<%=strAmount%>**</td></tr></table></td>
	</tr>
	<tr>
	  <td height="19" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="19" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="19" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="19" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="19" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="19" width="13%">&nbsp;</td>
	  <td height="19" width="58%">&nbsp;</td>
	  <td height="19" width="4%">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="19">&nbsp;</td>
	  <td height="19">&nbsp;</td>
	  <td height="19">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="19">&nbsp;</td>
	  <td height="19">&nbsp;</td>
	  <td height="19">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="19">&nbsp;</td>
	  <td height="19"><%=strVoucherNumber%></td>
	  <td height="19">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
</table>
<%}else if(strSchCode.startsWith("TSUNEISHI")){%>

<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
	  <td height="20" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
	</tr>
	<tr>
	  <td height="16" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
	</tr>
	<tr>
	  <td height="30" colspan="2">&nbsp;</td>
	  <td colspan="2" valign="top"><%=strChkDate%></td>
  </tr>
	<tr>
		<td width="13%">&nbsp;</td>
		<td width="58%">**<%=strPayeeName.toUpperCase()%>**</td>
		<td width="4%">&nbsp;</td>
		<td width="25%" valign="top"><table><tr><td>**<%=strAmount%>**</td></tr></table></td>
	</tr>
	<tr>
	  <td height="12" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
      <td colspan="3" style="font-size:13px">**<%=strAmountInWords%>**</td>
  </tr>
	<tr>
	  <td height="16" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
	</tr>
	<tr>
	  <td height="16" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
	</tr>
	<tr>
	  <td height="16" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
	</tr>
	<tr>
	  <td height="16" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
	</tr>
	<tr>
	  <td height="16" colspan="4" align="right" style="font-size:9px;">
	  	<table width="100%" cellpadding="0" cellspacing="0">
			<tr>
				<td width="65%" align="right" style="font-size:11px;"><%=WI.fillTextValue("sig1")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td width="35%" style="font-size:11px;" align="center"><%=WI.fillTextValue("sig2")%></td>
			</tr>
		</table>
		</td>
	</tr>

</table>

<%}else if(strSchCode.startsWith("CIT")){%>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
	  <td height="16" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
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
	<tr>
	  <td height="19" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td>&nbsp;</td>
      <td colspan="3" style="font-size:13px">&nbsp;</td>
  </tr>
</table>

<%}else if(strSchCode.startsWith("SWU") && !bolIsSeacrest){%>
<br>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
	  <td height="16" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
	<tr>
	  <td height="33" colspan="2">&nbsp;</td>
	  <td colspan="2" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=strChkDate%></td>
  </tr>
	<tr>
		<td width="11%">&nbsp;</td>
		<td width="70%">**<%=strPayeeName.toUpperCase()%>**</td>
		<td width="4%">&nbsp;</td>
		<td width="15%" valign="top"><table><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**<%=strAmount%>**</td></tr></table></td>
	</tr>
	<tr>
	  <td height="19" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td height="25" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
      <td colspan="3" style="font-size:13px">**<%=strAmountInWords%>**</td>
  </tr>
</table>
<%}else if(bolIsSeacrest){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
		  <td height="33" colspan="2">&nbsp;</td>
		  <td colspan="2" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=strChkDate%></td>
	  </tr>
		<tr>
			<td width="11%">&nbsp;</td>
			<td width="70%">**<%=strPayeeName.toUpperCase()%>**</td>
			<td width="4%">&nbsp;</td>
			<td width="15%" valign="top"><table><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**<%=strAmount%>**</td></tr></table></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td colspan="3" style="font-size:13px" valign="bottom">**<%=strAmountInWords%>**</td>
	  </tr>
	</table>
<%}else{%>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
<%if(strSchCode.startsWith("VMA")){%>
	<tr>
	  <td height="25" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
	 </tr>
<%}%>
<%//if(strSchCode.startsWith("CGH")){%>
	<tr>
	  <td height="16" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
<%//}%>
	<tr>
	  <td height="33" colspan="2">&nbsp;</td>
	  <td colspan="2" valign="top"><%if(strSchCode.startsWith("ARTCRAFT")){%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}%><%=strChkDate%></td>
  </tr>
	<tr>
		<td width="13%">&nbsp;</td>
		<td width="58%">**<%=strPayeeName.toUpperCase()%>**</td>
		<td width="4%">&nbsp;</td>
		<td width="25%" valign="top"><table><tr><td>**<%=strAmount%>**</td></tr></table></td>
	</tr>
<%if(strSchCode.startsWith("VMA")){%>
	<tr>
	  <td height="25" colspan="3">&nbsp;</td>
	  <td>&nbsp;</td>
	 </tr>
<%}%>
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
