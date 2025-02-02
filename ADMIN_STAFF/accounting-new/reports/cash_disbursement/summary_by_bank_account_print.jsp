<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%
	WebInterface WI  = new WebInterface(request);
%>
<body onLoad="<%if(WI.fillTextValue("print_stat").equals("1")){%>window.print();<%}%>">
<%@ page language="java" import="utility.*,Accounting.Report.ReportGeneric,java.util.Vector" %>
<%
	DBOperation dbOP = null;

	String strTemp   = null;
	String strErrMsg = null;
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

ReportGeneric rg = new ReportGeneric();

Vector vRetResult = rg.getCashDisbursementReport(dbOP, request);

if(vRetResult == null) {
	strErrMsg = rg.getErrMsg();
}

String strDateFrom = WI.fillTextValue("cd_date_fr");String strDateTo = WI.fillTextValue("cd_date_to");

String strMonth    = WI.fillTextValue("cd_month");
String strYear     = WI.fillTextValue("cd_year");

String[] astrConvertYr = {"January","February","March","April","May","June","July","August",
							"September","October","November","December"};
if(strMonth.length() > 0)
	strMonth = astrConvertYr[Integer.parseInt(strMonth)];


if(vRetResult == null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="2" style="font-size:14px; color:#FF0000"><%=strErrMsg%></td>
    </tr>
</table>
<%
dbOP.cleanUP();
return;}

Vector vBGSummary = (Vector)vRetResult.remove(0);

int iRowPerPg  = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iTotalRow  = vRetResult.size()/4;
int iTotalPage = iTotalRow / iRowPerPg;
if(iTotalRow % iRowPerPg > 0)
	++iTotalPage;

int iCurPage   = 0;
int iCurRow    = 1; boolean bolEndOfPrinting = false;
int iRowCount  = 1;

String strTotFreq   = (String)vBGSummary.remove(1);
String strTotAmount = (String)vBGSummary.remove(0);
for(int i =0; i < vBGSummary.size(); i += 3) {
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
      <td height="25" colspan="2" align="center" style="font-size:11px; font-weight:bold;">List Disbursement Vouchers &nbsp;
        <%if(strDateFrom.length() > 0 && strDateTo.length() > 0) {%>
        From <%=strDateFrom%> to <%=strDateTo%>
        <%}else if(strDateFrom.length() > 0){%>
        For <%=strDateFrom%>
        <%}else{%>For Month of <%=strMonth%> <%=WI.fillTextValue("cd_year")%><%}%>
      <br> <div align="left">SUMMARY BY BANK ACCOUNT</div></td>
    </tr>
    <tr>
      <td width="50%" height="25" style="font-size:11px;">Date and Time Printed : <%=WI.getTodaysDateTime()%></td>
      <td width="50%" align="right" style="font-size:11px;">Page : Page <%=iCurPage%> of <%=iTotalPage%>&nbsp;&nbsp;</td>
    </tr>

    <tr>
      <td height="10" colspan="2"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td height="25" class="thinborder" width="70%"><div align="center"><strong><font size="1">BANK ACCOUNT </font></strong></div></td>
      <td class="thinborder" width="10%"><div align="center"><font size="1"><strong>FREQUENCY</strong></font></div></td>
      <td class="thinborder" width="20%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
    </tr>

<%
bolEndOfPrinting = true;
String strBGName = null;
String strBGFreq = null;
String strBGTot  = null;

for(; i < vBGSummary.size(); i += 3){
	strBGName = (String)vBGSummary.elementAt(i);

	++iCurRow;
	if(iCurRow > iRowPerPg) {//break out of here and print in other page..
		bolEndOfPrinting = false;
		i = i - 3;
		break;
	}
	%>
    <tr>
      <td height="21" class="thinborder" style="font-size:11px; font-weight:bold; color:#0000FF"><%=vBGSummary.elementAt(i)%></td>
      <td class="thinborder" style="font-size:11px; font-weight:bold; color:#0000FF"><%=vBGSummary.elementAt(i + 2)%></td>
      <td class="thinborder" align="right" style="font-size:11px; font-weight:bold; color:#0000FF"><%=vBGSummary.elementAt(i + 1)%></td>
    </tr>
<%while(vRetResult.size() > 0){
	if(!vRetResult.elementAt(0).equals(strBGName))
		break;
	++iCurRow;
	if(iCurRow > iRowPerPg) {//break out of here and print in other page..
		bolEndOfPrinting = false;
		break;
	}
	vRetResult.removeElementAt(0);	%>
    <tr>
      <td height="21" class="thinborder">&nbsp;&nbsp;<%=vRetResult.remove(0)%></td>
      <td class="thinborder"><%=vRetResult.remove(1)%></td>
      <td class="thinborder" align="right"><%=vRetResult.remove(0)%></td>
    </tr>
<%if(vRetResult.size() == 0){%>
    <tr>
      <td height="21" class="thinborder">&nbsp;&nbsp;G &nbsp;R &nbsp;A &nbsp;N &nbsp;D &nbsp;&nbsp;&nbsp;T &nbsp;O &nbsp;T &nbsp;A &nbsp;L</td>
      <td class="thinborder"><%=strTotFreq%></td>
      <td class="thinborder" align="right"><%=strTotAmount%></td>
    </tr>
<%}//show grand total.. %>

<%}//end of printing bg-code. vRetResult..while(vRetResult.size() > 0){
}//end of for loop - Inner printing.=  for(; i < vBGSummary.size(); i += 3){%>
  </table>
<%if(!bolEndOfPrinting) {%>
	<DIV style="page-break-after:always">&nbsp;</DIV><%}%>
<%}//end of page print.. outer for loop..
%>


<!----------- Example ..
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#FFFFFF"><div align="center">
          <p><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>CENTRAL
            PHILIPPINE UNIVERSITY</strong></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><br>
            <font size="2">Jaro, Iloilo City</font></font></p>
        </div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="44" colspan="4" valign="bottom" bgcolor="#FFFFFF"><div align="left"><font color="#000000" size="2" face="Verdana, Arial, Helvetica, sans-serif">
          <strong>List Disbursement Vouchers</strong> &nbsp;From &nbsp;<strong>mm/dd/yyyy</strong>
          &nbsp;&nbsp;&nbsp;To&nbsp; <strong>mm/dd/yyyy</strong>&nbsp;&nbsp;&nbsp;(Printed
          &nbsp;mm/dd/yyyy)&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Page
          $page_num<br>
          </font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="10" colspan="4" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="10" colspan="4" bgcolor="#FFFFFF"><strong>SUMMARY BY BANK ACCOUNT</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="10" colspan="4" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="10" colspan="4" bgcolor="#FFFFFF"><font size="1">=====================================================================================================================================================</font></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="30"><div align="center"><strong><font size="1">BANK ACCOUNT</font></strong></div></td>
      <td bgcolor="#FFFFFF"><div align="center"><strong><font size="1">FREQUENCY</font></strong></div></td>
      <td height="30" bgcolor="#FFFFFF"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
    </tr>
    <tr>
      <td width="62%" height="21"><font color="#000000" face="Verdana, Arial, Helvetica, sans-serif">Auxiliary
        Bank Accounts</font></td>
      <td width="16%">&nbsp;</td>
      <td width="22%" height="21"><div align="right"></div></td>
    </tr>
    <tr>
      <td height="25"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;&nbsp&nbsp&nbsp&nbspALLIED</font></td>
      <td>0</td>
      <td height="25"><div align="right">0.00</div></td>
    </tr>
    <tr>
      <td height="25"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;&nbsp&nbsp&nbsp&nbspUCPB</font></td>
      <td>0</td>
      <td height="25"><div align="right">0.00</div></td>
    </tr>
    <tr>
      <td height="24"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;&nbsp&nbsp&nbsp&nbspBPI
        - ASEP</font></td>
      <td>2</td>
      <td height="24"><div align="right">18,000.00</div></td>
    </tr>
    <tr>
      <td height="24"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;&nbsp&nbsp&nbsp&nbspPCI
        Bank </font> </td>
      <td>12</td>
      <td height="24"><div align="right">10,000.00</div></td>
    </tr>
    <tr>
      <td height="24"><font color="#000000" face="Verdana, Arial, Helvetica, sans-serif">Auxiliary
        Bank Accounts</font> total :</td>
      <td>24</td>
      <td height="24"><div align="right">28,000.00</div></td>
    </tr>
    <tr>
      <td height="24">BPI - General Bank Account :</td>
      <td>55</td>
      <td height="24"><div align="right">1,455,007.37</div></td>
    </tr>
    <tr>
      <td height="24">G R A N D &nbsp;&nbsp;T O T A L :</td>
      <td>79</td>
      <td height="24"><div align="right">1,483,007.37</div></td>
    </tr>
  </table>
  </form>
-------------------------- end of example.. -->
</body>
</html>
<%
dbOP.cleanUP();
%>
