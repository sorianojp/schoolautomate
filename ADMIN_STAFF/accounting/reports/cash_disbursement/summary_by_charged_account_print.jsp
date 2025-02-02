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

String strTotAmount = (String)vRetResult.remove(0);
String strTotFreq   = (String)vRetResult.remove(0);


int iRowPerPg  = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iTotalRow  = vRetResult.size()/4;
int iTotalPage = iTotalRow / iRowPerPg;
if(iTotalRow % iRowPerPg > 0)
	++iTotalPage;

int iCurPage   = 0;
int iCurRow    = 1; boolean bolEndOfPrinting = false;
int iRowCount  = 1;

int iPageTotFreq = 0;
double dPageTotAmount = 0d;

for(int i =0; i < vRetResult.size(); i += 4) {
++iCurPage;
iCurRow = 0;

iPageTotFreq   = 0;
dPageTotAmount = 0d;
%>
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
      <br> <div align="left">SUMMARY BY CHARGED ACCOUNT</div></td>
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
      <td class="thinborder" width="5%" align="center" style="font-size:9px; font-weight:bold;">COUNT</td>
      <td class="thinborder" width="15%" align="center" style="font-size:9px; font-weight:bold;">ACCOUNT #</td>
      <td height="25" class="thinborder" width="55%" align="center" style="font-size:9px; font-weight:bold;">ACCOUNT NAME </td>
      <td class="thinborder" width="10%" align="center" style="font-size:9px; font-weight:bold;">FREQUENCY</td>
      <td class="thinborder" width="15%" align="center" style="font-size:9px; font-weight:bold;">AMOUNT</td>
    </tr>

<%
bolEndOfPrinting = true;

for(; i < vRetResult.size(); i += 4){
	++iCurRow;
	if(iCurRow > iRowPerPg) {//break out of here and print in other page..
		bolEndOfPrinting = false;
		i = i - 3;
		break;
	}
	iPageTotFreq   += Integer.parseInt((String)vRetResult.elementAt(i + 3));
	dPageTotAmount += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 2),",",""));%>
    <tr>
      <td class="thinborder"><%=iRowCount++%>.</td>
      <td class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td height="21" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(i + 2)%></td>
    </tr>
<%if(iCurRow == iRowPerPg || (i + 5) > vRetResult.size()) {%>
    <tr>
      <td height="21" class="thinborder" colspan="3">&nbsp;&nbsp;P &nbsp;A &nbsp;G &nbsp;E &nbsp;&nbsp;&nbsp;T &nbsp;O &nbsp;T &nbsp;A &nbsp;L</td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(i + 2)%></td>
    </tr>
<%}if( (i + 5) > vRetResult.size()){%>
    <tr>
      <td height="21" class="thinborder" colspan="3">&nbsp;&nbsp;G &nbsp;R &nbsp;A &nbsp;N &nbsp;D &nbsp;&nbsp;&nbsp;T &nbsp;O &nbsp;T &nbsp;A &nbsp;L</td>
      <td class="thinborder"><%=strTotFreq%></td>
      <td class="thinborder" align="right"><%=strTotAmount%></td>
    </tr>
<%}//show grand total.. %>

<%}//end of printing bg-code. vRetResult..while(vRetResult.size() > 0){
//}//end of for loop - Inner printing.=  for(; i < vBGSummary.size(); i += 3){%>
  </table>
<%if(!bolEndOfPrinting) {%>
	<DIV style="page-break-after:always">&nbsp;</DIV><%}%>
<%}//end of page print.. outer for loop..
%>


<!-------------- example only.. .................

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
      <td height="10" colspan="4" bgcolor="#FFFFFF"><strong>SUMMARY BY CHARGED
        ACCOUNT</strong></td>
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
      <td><div align="center"><strong><font size="1">COUNT</font></strong></div></td>
      <td height="30"><div align="center"><strong><font size="1">ACCOUNT #</font></strong></div></td>
      <td><div align="center"><strong><font size="1">ACCOUNT NAME</font></strong></div></td>
      <td bgcolor="#FFFFFF"><div align="center"><strong><font size="1">FREQUENCY</font></strong></div></td>
      <td height="30" bgcolor="#FFFFFF"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
    </tr>
    <tr>
      <td width="5%">&nbsp;</td>
      <td width="13%" height="21">&nbsp;</td>
      <td width="63%">&nbsp;</td>
      <td width="6%">&nbsp;</td>
      <td width="13%" height="21"><div align="right"></div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>0</td>
      <td height="25"><div align="right">0.00</div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>0</td>
      <td height="25"><div align="right">0.00</div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td>2</td>
      <td height="24"><div align="right">18,000.00</div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td>12</td>
      <td height="24"><div align="right">10,000.00</div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td>24</td>
      <td height="24"><div align="right">28,000.00</div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td>55</td>
      <td height="24"><div align="right">1,455,007.37</div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td>79</td>
      <td height="24"><div align="right">1,483,007.37</div></td>
    </tr>
    <tr>
      <td height="24" colspan="3"> P A G E&nbsp;&nbsp;&nbsp;T O T A L S : </td>
      <td>&nbsp;</td>
      <td height="24">&nbsp;</td>
    </tr>
    <tr>
      <td height="24" colspan="3">G R A N D &nbsp;&nbsp;&nbsp;T O T A L S : </td>
      <td>&nbsp;</td>
      <td height="24">&nbsp;</td>
    </tr>
  </table>
-=------------end of example.. .. -------------------->
</body>
</html>
<%
dbOP.cleanUP();
%>
