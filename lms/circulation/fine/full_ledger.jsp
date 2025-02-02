<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Full Ledger</title>
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
	
Vector vRetResult   = null; 
String strUserIndex = WI.fillTextValue("user_i");
if(strUserIndex.length() == 0) 
	strErrMsg = "Patron's ID is missing.";

boolean bolIsPrintCalled = false;
if(WI.fillTextValue("print_").length() > 0) 
	bolIsPrintCalled = true;

String strHeader = null;
if(strErrMsg == null)
	strHeader = "<strong> "+SchoolInformation.getSchoolName(dbOP,true,false)+"</strong> <br>"+
				SchoolInformation.getAddressLine1(dbOP,false,false);
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
    <td width="92%"><strong>
<%
java.sql.ResultSet rs = dbOP.executeQuery("select fname,mname,lname,id_number from user_table where "+
						"user_index="+strUserIndex);
rs.next();
%><%=WI.formatName(rs.getString(1),rs.getString(2),rs.getString(3),4) + " ("+rs.getString(4)+")"%>
<%rs.close();%>		
	</strong></td>
  </tr>
<tr>
 <td colspan="2" height="10" align="right">&nbsp;</td>
 </tr>
</table>	 
 <table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
 <tr bgcolor="#DDDDDD">
	 <td width="15%" class="thinborder" height="20">Accession # </td>
	 <td width="30%" class="thinborder">Book Title </td>
	 <td width="8%" class="thinborder">Date Fined </td>
	 <td width="12%" class="thinborder">Fine Type</td>
	 <td width="9%" class="thinborder"><div align="right">Prev. Bal </div></td>
	 <td width="9%" class="thinborder"><div align="right">Amt Paid </div></td>
	 <td width="9%" class="thinborder"><div align="right">Waive Amt </div></td> 
     <td width="8%" class="thinborder"><div align="right">New Bal </div></td>
 </tr>
 <%
 rs = dbOP.executeQuery("select accession_no, book_title,LMS_FINE_TYPE.DESCRIPTION, FINE_AMOUNT, FINE_PAID, "+
 		"WAVED_AMT, FINE_BALANCE,lms_book_fine.create_date from lms_book_fine "+
		"join lms_fine_type on (lms_fine_type.fine_type_index = lms_book_fine.fine_type_index) "+
		"left join lms_lc_main on (lms_lc_main.book_index = lms_book_fine.book_index) "+
		"where user_index = "+strUserIndex+" order by fine_index desc");
		
 double dTotPrevBal = 0d; double dPrevBal = 0d;
 double dTotAmtPaid = 0d; double dAmtPaid = 0d;
 double dTotWaived  = 0d; double dWaived  = 0d;
 double dTotNewBal  = 0d; double dNewBal  = 0d;
 
 while(rs.next()){
 	dPrevBal = rs.getDouble(4);
 	dAmtPaid = rs.getDouble(5);
 	dWaived  = rs.getDouble(6);
 	dNewBal  = rs.getDouble(7);
	
 	dTotPrevBal += dPrevBal;
 	dTotAmtPaid += dAmtPaid;
 	dTotWaived  += dWaived;
 	dTotNewBal  += dNewBal;
 %>
  <tr>
	 <td class="thinborder" height="20"><%=WI.getStrValue(rs.getString(1),"&nbsp;")%></td>
	 <td class="thinborder"><%=WI.getStrValue(rs.getString(2),"&nbsp;")%></td>
	 <td class="thinborder"><%=ConversionTable.convertMMDDYYYY(rs.getDate(8))%></td>
	 <td class="thinborder"><%=rs.getString(3)%></td>
	 <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dPrevBal,true)%></div></td>
	 <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dAmtPaid,true)%></div></td>
	 <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dWaived,true)%></div></td> 
     <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dNewBal,true)%></div></td>
  </tr>
<%}rs.close();%>
  <tr>
    <td height="20" colspan="4" class="thinborder" align="right">TOTAL </td>
    <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTotPrevBal,true)%></div></td>
    <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTotAmtPaid,true)%></div></td>
    <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTotWaived,true)%></div></td>
    <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTotNewBal,true)%></div></td>
  </tr>
 </table>
<%if(bolIsPrintCalled){%>
 <script language="javascript">
	 window.print();
 </script> 
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
	
