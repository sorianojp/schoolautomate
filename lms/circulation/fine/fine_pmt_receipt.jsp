<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
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
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
    }
-->
</style>
</head>

<body topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.* ,lms.FineManagement, java.util.Vector" %>
<% 
//check if there is valid session
	DBOperation dbOP = null;
	String strErrMsg = null;
	String  strTemp  = null;
	WebInterface WI  = new WebInterface(request);
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
	
	Vector vRetResult  = null; 
	String strCode     = WI.fillTextValue("code_no");
	FineManagement fineMgmt = new FineManagement();
	if(strCode.length() == 0) 
		strErrMsg = "Receipt # is empty.";
	else {
		vRetResult = fineMgmt.printPmtReceipt(dbOP, strCode, request);
		if(vRetResult == null)
			strErrMsg = fineMgmt.getErrMsg();
	}

String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM"};	
String strHeader = null;
if(strErrMsg == null)
	strHeader = "<strong> "+SchoolInformation.getSchoolName(dbOP,true,false)+"</strong> <br>"+
				SchoolInformation.getAddressLine1(dbOP,false,false);
dbOP.cleanUP();
if(strErrMsg != null) {%>
<table width="100%">
 	<tr>
    	<td width="100%"><b><font size="3" color="#FF0000"><%=strErrMsg%></font></b></td>
    </tr>
</table>	
<%return;}%>
<table width="100%">
   <tr>
    	<td align="center"><%=strHeader%></td>
  </tr>
</table>	
<table width="100%" cellpadding="0" cellspacing="0" border="0">
  <tr> 
    <td colspan="2" align="right">Date and time Printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td>
  </tr>
<tr> 
    <td width="8%">Patron:</td>
    <td width="92%"><strong><%=(String)vRetResult.elementAt(1)%> (<%=(String)vRetResult.elementAt(0)%>)</strong></td>
  </tr>
<tr>
 <td colspan="2" height="10" align="right">&nbsp;</td>
 </tr>
</table>	 
 <table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
 <tr bgcolor="#DDDDDD">
	 <td width="20%" class="thinborder" height="20">Accession # </td>
	 <td width="40%" class="thinborder">Book Title </td>
	 <td width="10%" class="thinborder"><div align="right">Prev. Bal </div></td>
	 <td width="10%" class="thinborder"><div align="right">Amt Paid </div></td>
	 <td width="10%" class="thinborder"><div align="right">Waive Amt </div></td> 
     <td width="10%" class="thinborder"><div align="right">New Bal </div></td>
 </tr>
 <%
 double dTotPrevBal = 0d; double dPrevBal = 0d;
 double dTotAmtPaid = 0d; double dAmtPaid = 0d;
 double dTotWaived  = 0d; double dWaived  = 0d;
 double dTotNewBal  = 0d; double dNewBal  = 0d;
 
 for(int i = 4; i < vRetResult.size(); i += 7){
 	dPrevBal = ((Double)vRetResult.elementAt(i + 1)).doubleValue();
 	dAmtPaid = ((Double)vRetResult.elementAt(i + 0)).doubleValue();
 	dWaived  = ((Double)vRetResult.elementAt(i + 3)).doubleValue();
 	dNewBal  = ((Double)vRetResult.elementAt(i + 2)).doubleValue();
	
 	dTotPrevBal += dPrevBal;
 	dTotAmtPaid += dAmtPaid;
 	dTotWaived  += dWaived;
 	dTotNewBal  += dNewBal;
 %>
  <tr>
	 <td class="thinborder" height="20"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"&nbsp;")%></td>
	 <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"&nbsp;")%></td>
	 <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dPrevBal,true)%></div></td>
	 <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dAmtPaid,true)%></div></td>
	 <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dWaived,true)%></div></td> 
     <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dNewBal,true)%></div></td>
  </tr>
<%}%>
  <tr>
    <td height="20" colspan="2" class="thinborder" align="right">TOTAL </td>
    <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTotPrevBal,true)%></div></td>
    <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTotAmtPaid,true)%></div></td>
    <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTotWaived,true)%></div></td>
    <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTotNewBal,true)%></div></td>
  </tr>
 </table>
 <br>
 <table width="100%" cellpadding="0" cellspacing="0" border="0">
 <tr>
 	<td width="52%"><strong>Payment Received  by</strong>: <%=(String)vRetResult.elementAt(2)%></td>
 	<td width="48%" align="right">Date and time of Payment: <%=(String)vRetResult.elementAt(3)%>&nbsp;</td>
  </tr>
 <tr>
   <td>&nbsp;</td>
   <td align="right">Receipt Code : <%=strCode%>&nbsp;</td>
 </tr>
 
 <tr>
   <td colspan="2">Patron Name: <%=(String)vRetResult.elementAt(1)%></td>
   </tr>
 <tr>
   <td colspan="2">&nbsp;</td>
 </tr>
 <tr>
   <td colspan="2">Signature : _________________________________</td>
 </tr>	
 </table>
<script language="javascript">
 window.print();
</script> 

</body>
</html>
<%
dbOP.cleanUP();
%>
	
