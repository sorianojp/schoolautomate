<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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

//I have to find here if this is called from print batch.. if not it is just one
Vector vCOAList = new Vector();
boolean bolBatchPrint = false; boolean bolIsPrint = false;

if(WI.fillTextValue("batch_print").length() > 0) {
	bolBatchPrint = true;
	bolIsPrint = WI.fillTextValue("print_stat").equals("1");

	int iMaxDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_disp"), "0"));
	if(iMaxDisp == 0)
		strErrMsg = "No List found.";
	else {
		for(int i = 1; i <= iMaxDisp; ++i) {
			strTemp = WI.fillTextValue("sel_"+i);
			if(strTemp.length() == 0)
				continue;
			vCOAList.addElement(strTemp);
		}
	}
}
else {
	vCOAList.addElement(WI.fillTextValue("coa_index"));
}
//System.out.println(vCOAList);
%>
<body <%if(WI.fillTextValue("print_stat").equals("1")){%> onLoad="window.print();"<%}%>>
<%
String strCOAIndex = null;
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsWUP = strSchCode.startsWith("WUP");
boolean bolIsSWU = strSchCode.startsWith("SWU");

boolean bolShowAddlInfo = false;
if(WI.fillTextValue("show_addl_info_wup").length() > 0) {
	bolShowAddlInfo = true;
}
Vector vAddlInfo       = null;
String strPayeeName   = null;
String strExplanation = null;
String strCheckNo     = null;

while(vCOAList.size() > 0) {
	strCOAIndex = (String)vCOAList.remove(0);

	ReportGeneric rg  = new ReportGeneric();
	//request.setAttribute("coa_index", strCOAIndex);
	rg.strCOAIndexSet = strCOAIndex;

	//System.out.println("Set COA: "+strCOAIndex);

	Vector vRetResult = rg.getGLInfo(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rg.getErrMsg();
	else	
		strErrMsg = null;
	%>

	<%if(strErrMsg != null){
		if(bolIsPrint && bolBatchPrint)
			continue;
	%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		  <td height="25" colspan="2" style="font-size:13px; font-weight:bold; color:#FF0000"><%=strErrMsg%></td>
		</tr>
	  </table>
	<%continue;}

	int iRowPerPg  = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
	int iTotalRow  = vRetResult.size()/5;
	int iTotalPage = iTotalRow / iRowPerPg;
	if(iTotalRow % iRowPerPg > 0)
		++iTotalPage;

	int iCurPage   = 0;
	int iCurRow    = 1; boolean bolEndOfPrinting = false;
	int iRowCount  = 1;

	double dDebit  = 0d;
	double dCredit = 0d;

	double dTotalDebit  = 0d;
	double dTotalCredit = 0d;

	double dBalance     = 0d;
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
	<%
	String strMonthEndDate = null;

	//get starting balance.
	String[] astrConverMonth = {"", "January","February","March","April","May","June","July","August","September","October","November","December"};
	int iYear      = Integer.parseInt((String)vRetResult.remove(0));
	int iMonthPrev = Integer.parseInt((String)vRetResult.remove(0)) + 1;
	if(iMonthPrev == 2) {
		if(iYear %4 == 0)
			strMonthEndDate = "February 29, "+iYear;
		else
			strMonthEndDate = "February 28, "+iYear;
	}
	else if(iMonthPrev == 1 || iMonthPrev == 3 || iMonthPrev == 5 || iMonthPrev == 7 || iMonthPrev == 8 || iMonthPrev == 10 || iMonthPrev == 12)
		 strMonthEndDate = astrConverMonth[iMonthPrev]+ " 31, "+iYear;
	else
		 strMonthEndDate = astrConverMonth[iMonthPrev]+ " 30, "+iYear;


	dBalance = Double.parseDouble((String)vRetResult.remove(0));
	for(int i =0; i < vRetResult.size(); i += 5) {
	++iCurPage;
	iCurRow = 0; %>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		  <td width="72%" height="28" valign="bottom">Date and time printed : <%=WI.getTodaysDateTime()%></td>
		  <td width="28%" height="28" valign="bottom" align="right">Page <%=iCurPage%> of <%=iTotalPage%></font></td>
		</tr>

		<tr>
		  <td height="30" colspan="2" valign="bottom" style="font-size:11px; font-weight:bold;">GENERAL LEDGER </td>
		</tr>
		<tr>
		  <td height="20" colspan="2" valign="bottom" style="font-size:11px; font-weight:bold;"><%=strCOAIndex%>: &nbsp;&nbsp;&nbsp;<%=rg.getErrMsg()%></td>
		</tr>
	<%
	String strReportName = "";
	strTemp = WI.fillTextValue("jv_date");
	if(strTemp.equals("1")) {
		if(WI.fillTextValue("as_of_date").length() > 0)
			strReportName = "As of Date : ";
		else
			strReportName = "For : ";

		strReportName += WI.formatDate(WI.fillTextValue("jv_date_fr"), 6);
	}
	else if(strTemp.equals("2"))
		strReportName = "From  "+WI.formatDate(WI.fillTextValue("jv_date_fr"), 6) +" to "+WI.formatDate(WI.fillTextValue("jv_date_to"), 6);
	else if(strTemp.equals("3") && WI.fillTextValue("jv_month").length() > 0) {
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};
		strReportName = "For Month of : "+astrConvertMonth[Integer.parseInt(WI.fillTextValue("jv_month"))] +", "+WI.fillTextValue("jv_year");
	}
	else if(strTemp.equals("4") && WI.fillTextValue("jv_year").length() > 0)
		strReportName = "For the year : "+WI.fillTextValue("jv_year");



	boolean bolShowBookType = false;
	if(WI.fillTextValue("show_book_type").length() > 0)
		bolShowBookType = true;
	%>
		<tr>
		  <td height="20" colspan="2" valign="bottom"  style="font-size:11px; font-weight:bold;"><%=strReportName%></td>
		</tr>
		<tr>
		  <td height="10" colspan="2">&nbsp;</td>
		</tr>
	  </table>

	  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr align="center" style="font-weight:bold">
		  <td class="thinborder" width="4%"><font size="1">COUNT</font></td>
		  <td class="thinborder" width="10%"><font size="1">REFERENCE #</font></td>
	<%if(bolShowBookType){%>
		  <td class="thinborder" width="13%" style="font-size:9px;">BOOK</td>
	<%}%>      
		  <td class="thinborder" width="9%"><font size="1">DATE</font></td>
<%if(bolShowAddlInfo){%>
		  <td class="thinborder" width="10%" style="font-size:9px;">PAYEE NAME </td>
		  <td class="thinborder" width="10%" style="font-size:9px;">CHECK NUMBER </td>
<%if(!bolIsSWU){%>
		  <td class="thinborder" width="10%" style="font-size:9px;">REMARKS</td>
<%}
}%>
		  <td class="thinborder" width="8%"><font size="1">DEBIT</font></td>
		  <td height="30" class="thinborder" width="8%"><font size="1">CREDIT</font></td>
		  <td class="thinborder" width="8%"><font size="1">BALANCE</font></td>
<%if(!bolIsWUP){%>
		  <td class="thinborder" width="20%"><font size="1">REMARKS</font></td>
<%}%>
		</tr>
	<%if(i == 0) {//show the balance forwarded information.%>
		<tr bgcolor="#CCCCCC">
		  <td class="thinborder" <%if(bolShowAddlInfo){%>colspan="5"<%}else{%>colspan="3"<%}%> style="font-size:10px; font-weight:bold"><%=strMonthEndDate%></td>
<%if(bolShowAddlInfo && !bolIsSWU){%>
		  <td class="thinborder">&nbsp;</td>
<%}%>
		  <td class="thinborder" <%if(bolShowBookType){%>colspan="4"<%}else{%>colspan="3"<%}%> align="right" style="font-size:10px; font-weight:bold">
			<%=CommonUtil.formatFloat(dBalance, true)%></td>
          <%if(!bolIsWUP){%>
		  <td class="thinborder" width="20%">&nbsp;</td>
<%}%>
		</tr>
	<%}

	bolEndOfPrinting = true;//System.out.println(vRetResult);
		String[] astrConvertBookType = {"Journal Voucher","Cash Disbursements","Cash Receipts"};
	for(; i < vRetResult.size(); i += 7){
		++iCurRow;
		if(iCurRow > iRowPerPg) {//break out of here and print in other page..
			bolEndOfPrinting = false;
			i = i - 5;
			break;
		}

		dDebit  = 0d;
		dCredit = 0d;

		if(vRetResult.elementAt(i + 2).equals("0"))
			dDebit  = Double.parseDouble((String)vRetResult.elementAt(i + 3));
		else
			dCredit = Double.parseDouble((String)vRetResult.elementAt(i + 3));

		dTotalDebit  += dDebit;
		dTotalCredit += dCredit;

		dBalance = dBalance - dCredit;
		dBalance = dBalance + dDebit;
	%>

		<tr>
		  <td height="21" class="thinborder"><%=iRowCount++%>.</td>
		  <td class="thinborder"><%=vRetResult.elementAt(i)%></td>
	<%if(bolShowBookType){%>
		  <td class="thinborder"><%=astrConvertBookType[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
	<%}%>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
<%if(bolShowAddlInfo){
	vAddlInfo = (Vector)vRetResult.elementAt(i + 6);
strPayeeName   = null;
strExplanation = null;
strCheckNo     = null;
if(vAddlInfo != null && vAddlInfo.size() > 2) {
	strPayeeName   = (String)vAddlInfo.elementAt(0);
	strExplanation = (String)vAddlInfo.elementAt(1);
	strCheckNo     = (String)vAddlInfo.elementAt(2);
}
%>
		  <td class="thinborder"><%=WI.getStrValue(strPayeeName, "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(strCheckNo, "&nbsp;")%></td>
<%if(!bolIsSWU){%>
		  <td class="thinborder"><%=WI.getStrValue(strExplanation, "&nbsp;")%></td>
<%}
}%>
		  <td class="thinborder" align="right"><%if(dDebit > 0d){%><%=CommonUtil.formatFloat(dDebit,true)%><%}else{%>&nbsp;<%}%></td>
		  <td class="thinborder" align="right"><%if(dCredit > 0d){%><%=CommonUtil.formatFloat(dCredit,true)%><%}else{%>&nbsp;<%}%></td>
		  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
<%if(!bolIsWUP){%>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%></td>
<%}%>
		</tr>
	<%}//end of for loop - Inner printing.
	if(bolEndOfPrinting) {
	int iAdd = 0;
	if(bolShowAddlInfo) {
		if(bolIsSWU)
			iAdd = 2;
		else
			iAdd = 3;
	}
	%>
		<tr>
		  <td colspan="<%if(bolShowBookType){%><%=4+iAdd%><%}else{%><%=3+iAdd%><%}%>" class="thinborder"><div align="right">TOTALS : &nbsp;&nbsp;</div></td>
		  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotalDebit,true)%></td>
		  <td height="24" class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotalCredit,true)%></td>
		  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
          <%if(!bolIsWUP){%>
		  <td height="24" class="thinborder">&nbsp;</td>
<%}%>
		</tr>
	<%}%>
	  </table>
	<%if(!bolEndOfPrinting) {%><DIV style="page-break-after:always">&nbsp;</DIV><%}%>

	<%}//end of page print.. outer for loop..
	%>

<%if(vCOAList.size() > 0) {%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
<%}%>

<%}//end of printing in batch -- %>
</body>
</html>
<%
dbOP.cleanUP();
%>
