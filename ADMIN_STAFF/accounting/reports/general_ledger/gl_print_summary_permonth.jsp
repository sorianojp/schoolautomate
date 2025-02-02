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

%>
<body <%if(WI.fillTextValue("print_stat").equals("1")){%> onLoad="window.print();"<%}%>>
<%
String strCOAIndex = null;
while(vCOAList.size() > 0) {
	strCOAIndex = (String)vCOAList.remove(0);

	ReportGeneric rg  = new ReportGeneric();
	request.setAttribute("coa_index", strCOAIndex);
	Vector vRetResult = rg.getGLInfoSummaryPerMonth(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rg.getErrMsg();

	%>

	<body <%if(WI.fillTextValue("print_stat").equals("1")){%> onLoad="window.print();"<%}%>>
	<%if(strErrMsg != null){%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		  <td height="25" colspan="2" style="font-size:13px; font-weight:bold; color:#FF0000"><%=strErrMsg%></td>
		</tr>
	  </table>
	<%
	dbOP.cleanUP();return;}

	double dDebit    = 0d;
	double dCredit   = 0d;
	double dBalance  = 0d;
	double dTotalBal = 0d;


	//I have to add the income statement to un-appropriate earning : account number 2-6220
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	double dNetIncome = 0d;
	if(strSchCode.startsWith("CLDH") && strCOAIndex.equals("2-6220") && WI.fillTextValue("jv_month").equals("4")) {
		//I have to make sure that account is closed for the year..
		String strSQLQuery = "select coa_close_index from ac_coa_close join ac_coa on (ac_coa.coa_index = ac_coa_close.coa_index) where account_code = '2-6220' and "+
			" year = "+WI.fillTextValue("jv_year")+" and month = 4";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null) { //already closed, so i have to enter one row for income statement..
			Accounting.IncomeStatement IS = new Accounting.IncomeStatement();
			Vector vTempIS = IS.getIncomeStatementMonthlyYearly(dbOP, request);
			if(vTempIS != null && vTempIS.size() > 0)
				dNetIncome = Double.parseDouble(ConversionTable.replaceString((String)vTempIS.remove(0), ",", ""));
			//System.out.println(IS.getErrMsg());
		}
	}

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
		  <td width="72%" height="28" valign="bottom">Date and time printed : <%=WI.getTodaysDateTime()%></td>
		  <td width="28%" height="28" valign="bottom" align="right">&nbsp;</td>
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
		<tr>
			  <td class="thinborder" width="13%" align="center" style="font-size:9px; font-weight:bold">PARTICULARS</td>
		  <td class="thinborder" width="13%"><div align="center"><font size="1"><strong>BOOK</strong></font></div></td>
		  <td class="thinborder" width="17%"><div align="center"><strong><font size="1">DEBIT</font></strong></div></td>
		  <td height="30" class="thinborder" width="17%"><div align="center"><strong><font size="1">CREDIT</font></strong></div></td>
		  <td class="thinborder" width="17%"><div align="center"><strong><font size="1">BALANCE</font></strong></div></td>
		</tr>
	<%//System.out.println(vRetResult);
	String[] astrConvertBookType = {"Journal Voucher", "Disbursement","Cash Receipts", "&nbsp;"};
	String[] astrConverMonth = {"", "January","February","March","April","May","June","July","August","September","October","November","December"};
	//double dMonthlyBalance = 0d;
	int iMonthCur = 0; int iMonthPrev = -1; int iYear = 0;

	String strMonthEndDate = null;

	//get starting balance.
	iYear      = Integer.parseInt((String)vRetResult.remove(0));
	iMonthPrev = Integer.parseInt((String)vRetResult.remove(0)) + 1;
	dTotalBal  = Double.parseDouble( (String)vRetResult.remove(0));


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

	iMonthPrev = -1;//reset.
	%>
		<tr bgcolor="#CCCCCC">
		  <td class="thinborder"><%=strMonthEndDate%></td>
		  <td class="thinborder" colspan="4" align="right"><%=CommonUtil.formatFloat(dTotalBal,true)%></td>
		</tr>
	<%
	for(int i = 0; i < vRetResult.size(); i += 5){

		dDebit  = 0d;
		dCredit = 0d;

		dDebit  = Double.parseDouble(WI.getStrValue(vRetResult.elementAt(i + 2), "0"));
		dCredit = Double.parseDouble(WI.getStrValue(vRetResult.elementAt(i + 3), "0"));

		dBalance = dDebit - dCredit;

		iMonthCur = Integer.parseInt((String)vRetResult.elementAt(i));

	iYear = Integer.parseInt((String)vRetResult.elementAt(i + 1));
	if(iMonthCur != iMonthPrev && iMonthPrev > -1){ 
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
	%>
		<tr bgcolor="#CCCCCC">
		  <td class="thinborder"><%=strMonthEndDate%></td>
		  <td class="thinborder" colspan="4" align="right"><%=CommonUtil.formatFloat(dTotalBal,true)%></td>
		</tr>
	<%iMonthPrev = iMonthCur;
	}//show monthly balance.
	if(iMonthPrev == -1)
		iMonthPrev = iMonthCur;
	//dMonthlyBalance += dBalance;

	dTotalBal += dBalance;

	%>
		<tr>
		  <td class="thinborder"><%=astrConverMonth[iMonthCur]%>, <%=vRetResult.elementAt(i + 1)%></td>
		  <td height="21" class="thinborder"><%=astrConvertBookType[Integer.parseInt((String)vRetResult.elementAt(i + 4))]%></td>
		  <td class="thinborder" align="right"><%if(dDebit > 0d){%><%=CommonUtil.formatFloat(dDebit,true)%><%}else{%>&nbsp;<%}%></td>
		  <td class="thinborder" align="right"><%if(dCredit > 0d){%><%=CommonUtil.formatFloat(dCredit,true)%><%}else{%>&nbsp;<%}%></td>
		  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
		</tr>
	<%
	}//end of for loop - Inner printing.
	if(dNetIncome != 0d) {
	dTotalBal += dNetIncome;%>
		<tr>
		  <td class="thinborder">Net Income</td>
		  <td height="21" class="thinborder">&nbsp;</td>
		  <td class="thinborder" align="right">&nbsp;<%if(dNetIncome > 0d) {%><%=CommonUtil.formatFloat(dNetIncome, true)%><%}%></td>
		  <td class="thinborder" align="right">&nbsp;<%if(dNetIncome < 0d) {%><%=CommonUtil.formatFloat(-1 * dNetIncome, true)%><%}%></td>
		  <td class="thinborder" align="right">&nbsp;<%=CommonUtil.formatFloat(dTotalBal, true)%></td>
		</tr>
	<%}
	String strEndOfMonth = null;
	if(WI.fillTextValue("report_type").equals("2")){
		int iMonth = Integer.parseInt(WI.fillTextValue("jv_month"));
		iYear  = Integer.parseInt(WI.fillTextValue("jv_year"));
		int iMaxDayInMonth = 0;
		java.util.Calendar cal = java.util.Calendar.getInstance();
		iMaxDayInMonth = cal.get(java.util.Calendar.DAY_OF_MONTH);
		if(cal.get(java.util.Calendar.MONTH) != iMonth || cal.get(java.util.Calendar.YEAR) != iYear) {
			cal.set(iYear, iMonth , 28);
			while(cal.get(java.util.Calendar.MONTH) == iMonth)
				cal.add(java.util.Calendar.DAY_OF_MONTH, 1);
			cal.add(java.util.Calendar.DAY_OF_MONTH, -1);
			iMaxDayInMonth = cal.get(java.util.Calendar.DAY_OF_MONTH);
		}

		strEndOfMonth = astrConverMonth[iMonth + 1] +" "+Integer.toString(iMaxDayInMonth)+", "+WI.fillTextValue("jv_year");
	}

	%>
		<tr bgcolor="#CCCCCC">
		  <td class="thinborder">
			<%if(WI.fillTextValue("jv_date_fr").length() > 0 ) {%>
				<%=WI.formatDate(WI.fillTextValue("jv_date_fr"), 6)%>
			<%}else{%><%=WI.getStrValue(strEndOfMonth, "&nbsp;")%><%}%></td>
		  <td class="thinborder">&nbsp;</td>
		  <td class="thinborder" align="right">&nbsp;</td>
		  <td height="21" class="thinborder" align="right">&nbsp;</td>
		  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotalBal,true)%></td>
		</tr>
	  </table>
<%if(vCOAList.size() > 0) {%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
<%}%>
<%}//end of printing in batch -- %>

</body>
</html>
<%
dbOP.cleanUP();
%>
