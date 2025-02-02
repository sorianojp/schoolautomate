<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,Accounting.Report.ReportSpecialBooks,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
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

ReportSpecialBooks reportSB = new ReportSpecialBooks();

Vector vRetResult    = null;//all regarding check detail. 
Vector vMonthlyInfo  = null;

	vRetResult = reportSB.getSchedOfAccount(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = reportSB.getErrMsg();




if(vRetResult != null && vRetResult.size() > 0) {
boolean bolShowExplanation = false;
if(WI.fillTextValue("show_explanation").length() > 0)
	bolShowExplanation = true;
	
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	 <tr>
      <td height="25" colspan="7" align="center">
	  		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          	<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <br>
        <font style="font-size:11px; font-weight:bold"><u>
		SCHEDULE OF <%=((String)vRetResult.remove(0)).toUpperCase()%>
<%
String strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() > 0){%>
		<br>ACADEMIC YEAR <%=strSYFrom%> - <%=Integer.parseInt(strSYFrom) + 1%>
<%}%>	
	  </u></font>	   </td>
    </tr>
    <tr>
      <td height="25" colspan="7" align="right" style="font-size:9px;">Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp; </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%"><span class="thinborder" style="font-size:9px; font-weight:bold">DATE</span></td>
      <td height="26" class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="30%">PAYEE</td>
<%if(bolShowExplanation){%>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="30%">PARTICULAR</td>
<%}%>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%"><span class="thinborder" style="font-size:9px; font-weight:bold">VOUCHER # </span></td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%"><span class="thinborder" style="font-size:9px; font-weight:bold">AMOUNT</span></td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%">TOTAL </td>
    </tr>
<%java.util.Calendar cal = null;
while(vRetResult.size() > 0) {
strTemp = (String)vRetResult.remove(0);
vMonthlyInfo = (Vector)vRetResult.remove(2);
%>
    <tr>
      <td height="26" colspan="<%if(bolShowExplanation){%>6<%}else{%>5<%}%>" class="thinborder" style="font-weight:bold"><%=strTemp%></td>
    </tr>

<%
int iIndexOf = 0; String strBankCode = ""; String strCharAt = null;
for(int i = 0; i < vMonthlyInfo.size(); i += 5){%>
    <tr>
      <td class="thinborder"><%=vMonthlyInfo.elementAt(i)%></td>
      <td height="26" class="thinborder"><%=WI.getStrValue(vMonthlyInfo.elementAt(i + 1),"&nbsp;")%></td>
<%if(bolShowExplanation){
strTemp  = WI.getStrValue(vMonthlyInfo.elementAt(i + 4), "&nbsp;");
iIndexOf = strTemp.toLowerCase().indexOf("check #");
	//get bank code.

	while(iIndexOf > 0) {
		strCharAt = String.valueOf(strTemp.charAt(--iIndexOf));
		if(strCharAt.trim().length() == 0) {
			if(strBankCode.length() > 0)
				break;
			continue;
		}
		strBankCode = strCharAt + strBankCode;
	}
strBankCode = "";
if(iIndexOf > 0) 
	strTemp = strTemp.substring(0,iIndexOf);
	
//I have to format strTemp
if(strTemp == null)
	strTemp = "";
else	
	strTemp = strTemp.replaceAll("\n","<br>");
%>
      <td class="thinborder"><!--<pre><%//=strTemp%></pre>--><%=strTemp%></td>
<%}%>
      <td class="thinborder" align="right"><%=vMonthlyInfo.elementAt(i + 2)%></td>
      <td class="thinborder" align="right"><%=vMonthlyInfo.elementAt(i + 3)%></td>
      <td class="thinborder" align="right">&nbsp;&nbsp;</td>
    </tr>
<%}%>
    <tr style="font-weight:bold">
      <td height="26" colspan="<%if(bolShowExplanation){%>5<%}else{%>4<%}%>" class="thinborder" align="right"><%=vRetResult.remove(0)%></td>
      <td class="thinborder" align="right"><%=vRetResult.remove(0)%></td>
    </tr>
<%}%>
  </table>
  <%}//if(vRetResult != null && vRetResult.size() > 0) {
 else{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><div align="left"></div></td>
      <td width="94%" height="25" style="font-size:14px; color:#FF0000; font-weight:bold"><%=strErrMsg%></td>
    </tr>
</table>
 <%}%>
<%if(WI.fillTextValue("inc_cancelled").length() > 0 && false) {
	if(reportSB.vCancelledVoucher == null || reportSB.vCancelledVoucher.size() == 0) {%>
		<font style="font-size:12px; font-weight:bold;">No Cancelled Voucher Found for specified period.</font>
	<%}else{%><br>
	<font style="font-weight:bold; font-size:14px;"><u>List of Cancelled Vouchers</u></font>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" style="font-size:9px;font-weight:bold" class="thinborderTOPLEFTBOTTOM">Voucher Number</td>
      <td style="font-size:9px;font-weight:bold" class="thinborderALL">Voucher Date</td>
      <td style="font-size:9px;font-weight:bold">&nbsp;</td>
      <td style="font-size:9px;font-weight:bold" class="thinborderTOPLEFTBOTTOM">Voucher Number</td>
      <td style="font-size:9px;font-weight:bold" class="thinborderALL">Voucher Date</td>
      <td style="font-size:9px;font-weight:bold">&nbsp;</td>
      <td style="font-size:9px;font-weight:bold" class="thinborderTOPLEFTBOTTOM">Voucher Number</td>
      <td style="font-size:9px;font-weight:bold" class="thinborderALL">Voucher Date</td>
    </tr>
<%while( reportSB.vCancelledVoucher.size() > 0) {%>
   <tr>
      <td height="25" style="font-size:9px;" class="thinborderBOTTOMLEFT">&nbsp;<%=reportSB.vCancelledVoucher.remove(0)%></td>
      <td style="font-size:9px;" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=reportSB.vCancelledVoucher.remove(0)%></td>
      <td style="font-size:9px;">&nbsp;</td>
      <td style="font-size:9px;" class="thinborderBOTTOMLEFT">&nbsp;
	  <%if(reportSB.vCancelledVoucher.size() > 0) {%>
	  	<%=reportSB.vCancelledVoucher.remove(0)%>
	  <%}else{%>
	  	xx
	  <%}%> 
	  </td>
      <td style="font-size:9px;" class="thinborderBOTTOMLEFTRIGHT">
	  <%if(reportSB.vCancelledVoucher.size() > 0) {%>
	  	<%=reportSB.vCancelledVoucher.remove(0)%>
	  <%}else{%>
	  	xx
	  <%}%> 
	  </td>
      <td style="font-size:9px;">&nbsp;</td>
      <td style="font-size:9px;" class="thinborderBOTTOMLEFT">
	  <%if(reportSB.vCancelledVoucher.size() > 0) {%>
	  	<%=reportSB.vCancelledVoucher.remove(0)%>
	  <%}else{%>
	  	xx
	  <%}%> 
	  </td>
      <td style="font-size:9px;" class="thinborderBOTTOMLEFTRIGHT">
	  <%if(reportSB.vCancelledVoucher.size() > 0) {%>
	  	<%=reportSB.vCancelledVoucher.remove(0)%>
	  <%}else{%>
	  	xx
	  <%}%> 
	  </td>
    </tr>
<%}%>
</table>
<%}
}%> 


</body>
</html>
<%
dbOP.cleanUP();
%>