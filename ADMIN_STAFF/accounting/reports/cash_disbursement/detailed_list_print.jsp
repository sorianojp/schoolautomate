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


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode ="";
//boolean bolIsAUF = strSchCode.startsWith("AUF");
//bolIsAUF = false;


if(vRetResult == null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="2" style="font-size:14px; color:#FF0000"><%=strErrMsg%></td>
    </tr>
</table>
<%
dbOP.cleanUP();
return;}


int iRowPerPg  = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iTotalRow  = vRetResult.size()/10;
int iTotalPage = iTotalRow / iRowPerPg;
if(iTotalRow % iRowPerPg > 0)
	++iTotalPage;

int iCurPage   = 0;
int iCurRow    = 1; boolean bolEndOfPrinting = false;
int iRowCount  = 1;
double dGrandTotal = 0d;

for(int i =0; i < vRetResult.size(); i += 10) {
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
      </td>
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
      <td height="25" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">VOUCHER DATE</font></strong></div></td>
      <td rowspan="2" class="thinborder"><div align="center"><strong><font size="1">VOUCHER #</font></strong></div></td>
      <td rowspan="2" class="thinborder"><div align="center"><font size="1"><strong>PAYEE</strong></font></div></td>
      <td rowspan="2" class="thinborder"><div align="center"><font size="1"><strong>EXPLANATION</strong></font></div></td>
      <td colspan="2" class="thinborder"><div align="center"><font size="1"><strong>CHECK DETAILS</strong></font></div></td>
      <td rowspan="2" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
      <td rowspan="2" class="thinborder"><div align="center"><font size="1"><strong>CHARGED <br>ACCOUNT NAME (DEBITED) </strong></font></div></td>
      <td rowspan="2" class="thinborder"><div align="center"><strong><font size="1">ACCOUNT NAME (CREDITED)</font></strong></div></td>
    </tr>
    <tr>
      <td width="6%" height="24" class="thinborder"><div align="center"><font size="1"><strong>BANK </strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>CHECK #</strong></font></div></td>
    </tr>
<%
bolEndOfPrinting = true;
String strJVDate  = null;
double dSubTotal  = 0d;
double dPageTotal = 0d;

for(; i < vRetResult.size(); i += 10){
	if(strJVDate == null)
		strJVDate = (String)vRetResult.elementAt(i);

	++iCurRow;
	if(iCurRow > iRowPerPg) {//break out of here and print in other page..
		bolEndOfPrinting = false;
		i = i - 10;
		break;
	}
	dSubTotal += Double.parseDouble((String)vRetResult.elementAt(i + 6));
	dPageTotal    += Double.parseDouble((String)vRetResult.elementAt(i + 6));
	dGrandTotal   += Double.parseDouble((String)vRetResult.elementAt(i + 6));

	%>
    <tr>
      <td width="5%" height="21" class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td width="4%" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td width="19%" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td width="18%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3),"&nbsp;")%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td width="8%" class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 6), true)%></td>
      <td width="16%" class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
      <td width="16%" class="thinborder"><%=vRetResult.elementAt(i + 9)%></td>
    </tr>
<%//System.out.println(i + 10);System.out.println(vRetResult.size());
if( (i + 11) < vRetResult.size() && !strJVDate.equals(vRetResult.elementAt(i + 10))) {
	strJVDate = (String)vRetResult.elementAt(i);%>
    <tr style="font-weight:bold">
      <td height="21" colspan="7" class="thinborder" align="right">
	  	Check Total : <%=CommonUtil.formatFloat(dSubTotal,true)%></td>
      <td colspan="2" class="thinborder">&nbsp;</td>
    </tr>
<%dSubTotal=0d;}//end of if.
}//end of for loop - Inner printing. %>
    <tr style="font-weight:bold">
      <td height="21" colspan="7" class="thinborder" align="right">
	  	Check Total : <%=CommonUtil.formatFloat(dSubTotal,true)%></td>
      <td colspan="2" class="thinborder">&nbsp;</td>
    </tr>
    <tr style="font-weight:bold">
      <td height="21" colspan="7" class="thinborder" align="right">
	  	Page Total : <%=CommonUtil.formatFloat(dPageTotal,true)%></td>
      <td colspan="2" class="thinborder">&nbsp;</td>
    </tr>
  </table>
<%if(!bolEndOfPrinting) {%>
	<DIV style="page-break-after:always" >&nbsp;</DIV><%}%>
<%}//end of page print.. outer for loop..
if(dGrandTotal > 0d) {%>
	<table width="100%">
    <tr style="font-weight:bold">
      <td style="font-size:14px;">
	  	GRAND TOTAL : <%=CommonUtil.formatFloat(dGrandTotal,true)%></td>
    </tr>
  </table>

<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
