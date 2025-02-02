<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
-->
</style>
</head>

<%@ page language="java" import="utility.*,Accounting.Report.ReportGeneric, java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
	DBOperation dbOP = null;
	
	String strTemp   = null;
	String strErrMsg = null;
	
//add security here.
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.

ReportGeneric rg  = new ReportGeneric();
Vector vRetResult = rg.getTrialBalanceUserDefined(dbOP, request);
if(vRetResult == null)
	strErrMsg = rg.getErrMsg();
%>

<body <%if(WI.fillTextValue("print_stat").equals("1")){%> onLoad="window.print();"<%}%>>
<%if(strErrMsg != null || vRetResult == null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2" style="font-size:13px; font-weight:bold; color:#FF0000"><%=strErrMsg%></td>
    </tr>
  </table>
<%dbOP.cleanUP();return;}%>
<%
int iRowPerPg  = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iTotalRow  = vRetResult.size()/8;
int iTotalPage = iTotalRow / iRowPerPg;
if(iTotalRow % iRowPerPg > 0) 
	++iTotalPage;

int iCurPage   = 0;
int iCurRow    = 1; boolean bolEndOfPrinting = false;
int iRowCount  = 1;

String strTotalDebit  = (String)vRetResult.remove(0); 
String strTotalCredit = (String)vRetResult.remove(0);

///to indent.. 
String strTBName = dbOP.getResultOfAQuery("select REPORT_NAME from AC_SET_TB_REPORT where report_ref = "+WI.fillTextValue("report_ref"), 0);

String strTempDebitAmt = null;
String strTempCreditAmt = null;

for(int i =0; i < vRetResult.size(); i += 3) {
++iCurPage;	
iCurRow = 0; %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2">
	  	<div align="center"><font size="2">
      	<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br></div>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="30" colspan="2" valign="bottom"><div align="center"><strong><u>TRIAL BALANCE ::: <%=strTBName.toUpperCase()%><br>
      </u></strong><%=WI.formatDate(WI.fillTextValue("tb_date"),6)%> </div></td>
    </tr>
    <tr> 
    <tr> 
      <td width="72%" height="28" valign="bottom">Date and time printed : <%=WI.getTodaysDateTime()%></td>
      <td width="28%" height="28" valign="bottom" align="right">Page <%=iCurPage%> of <%=iTotalPage%></font></td>
    </tr>
    
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="47%" height="30" align="center" style="font-size:9px; font-weight:bold">ACCOUNT NAME</td>
      <td width="3%"  style="font-size:9px; font-weight:bold" align="center">C/D</td>
      <td width="15%" style="font-size:9px; font-weight:bold" align="right">DEBIT</td>
      <td width="15%" style="font-size:9px; font-weight:bold" align="right">CREDIT</td>
    </tr>
<%
bolEndOfPrinting = true;
for(; i < vRetResult.size(); i += 3){
	++iCurRow; 
	if(iCurRow > iRowPerPg) {//break out of here and print in other page.. 
		bolEndOfPrinting = false;
		i = i - 3;
		break;
	}
	strTempDebitAmt = (String)vRetResult.elementAt(i + 1);
	strTempCreditAmt = strTempDebitAmt;
	if(vRetResult.elementAt(i + 2).equals("0")){
		strTemp = "C";
		strTempDebitAmt = "0.00";
	}else{
		strTemp = "D";
		strTempCreditAmt = "0.00";
	}
	
	%>
    <tr> 
      <td height="25"><%=vRetResult.elementAt(i)%></td>
      <td align="center"><%=strTemp%></td>
      <td><div align="right"><%=strTempDebitAmt%></div></td>
      <td><div align="right"><%=strTempCreditAmt%></div></td>
    </tr>
<%}//end of for loop - Inner printing. 
if(bolEndOfPrinting) {%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="24" colspan="2"><div align="right"><strong>&nbsp;&nbsp;</strong></div>
        <div align="right"><strong>TOTALS :&nbsp;&nbsp; </strong></div></td>
      <td height="24" align="right"><strong><%=strTotalDebit%></strong></td>
      <td align="right"><strong><%=strTotalCredit%></strong></td>
    </tr>
<%}%>
  </table>
<%if(!bolEndOfPrinting) {%><DIV style="page-break-after:always">&nbsp;</DIV><%}%>

<%}//end of page print.. outer for loop.. 
%>










<!-- Example only... 

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#FFFFFF"><div align="center"> 
          <p><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>CENTRAL 
            PHILIPPINE UNIVERSITY</strong></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><br>
            <font size="2">Jaro, Iloilo City</font></font></p>
        </div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="50" bgcolor="#FFFFFF"><div align="center"><strong><u>TRIAL BALANCE<br>
          </u></strong>$date </div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="24" bgcolor="#FFFFFF"><div align="center">Balances Prior to 
          Adjustments </div>
        <div align="left"></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="10" bgcolor="#FFFFFF">Page # of $Total_number of pages</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="10" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="10" bgcolor="#FFFFFF"><font size="1">=====================================================================================================================================================</font></td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="11%" height="30"><div align="center"><font size="1"><strong>ACCOUNT 
          NUMBER</strong></font></div></td>
      <td width="57%"><div align="center"><font size="1"><strong>ACCOUNT NAME</strong></font></div></td>
      <td width="4%"><div align="center"><font size="1"><strong>C/D</strong></font></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>DEBIT</strong></font></div></td>
      <td width="16%"><div align="center"><strong><font size="1">CREDIT</font></strong></div></td>
    </tr>
    <tr> 
      <td height="21" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>$GROUP_NAME</strong></td>
    </tr>
    <tr> 
      <td height="25">6318</td>
      <td><font size="1">CAO Petty Cash Fund</font></td>
      <td>D</td>
      <td><div align="right">1,500.00</div></td>
      <td><div align="right"></div></td>
    </tr>
    <tr> 
      <td height="25"><font size="1">6317</font></td>
      <td><font size="1">CPU Centennial VIllage Petty Cash Fund</font></td>
      <td>D</td>
      <td><div align="right"><font size="1">25,000.00</font></div></td>
      <td><div align="right"></div></td>
    </tr>
    <tr> 
      <td height="24"><font size="1">5412</font></td>
      <td><font size="1">Dining Hall-Revolving Fund</font></td>
      <td><font size="1">D</font></td>
      <td><div align="right"><font size="1">10,000.00</font></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="24"><font size="1">3219</font></td>
      <td><font size="1">ABC Savings Account No. 1450-03233-3 (CPU ATM PAYROLL 
        ACCOUNT)</font></td>
      <td><font size="1">D</font></td>
      <td><div align="right"><font size="1"></font></div></td>
      <td><div align="right"><font size="1">1,759,720.36</font></div></td>
    </tr>
    <tr> 
      <td height="24" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>$GROUP_NAME</strong></td>
    </tr>
    <tr> 
      <td height="24"><font size="1">0036</font></td>
      <td><font size="1">Dollar Time Deposit with BPI/FEBTC</font></td>
      <td><font size="1">D</font></td>
      <td><div align="right"><font size="1">25,922,188.41</font></div></td>
      <td><font size="1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="24" colspan="3"><div align="right"><strong>&nbsp;&nbsp;</strong></div>
        <div align="right"><strong>TOTALS :&nbsp;&nbsp; </strong></div></td>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="24" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="24" colspan="5">End of Job.&nbsp;&nbsp; Time :&nbsp;$time&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        &nbsp;&nbsp;&nbsp; Date :$date</td>
    </tr>
  </table>
  </form>
-->
  
</body>
</html>
<%
dbOP.cleanUP();
%>