<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, 
																payroll.PReDTRME, payroll.OvertimeMgmt" buffer="16kb"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary by Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
  TD.detail_style {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("header_size"), "12")%>.px;
  }	
	
  TD.header_style {
		border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("header_size"), "12")%>.px;
  }

</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	String strAmt = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	String strUserId = (String)request.getSession(false).getAttribute("userId");	
	boolean bolShowALL = false;
	if(strUserId != null && strUserId.equals("bricks"))
		bolShowALL = true;
	boolean bolHasTeam = false;
	boolean bolHasPeraa = false;
//add security here.
 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Sheet (Gov)","psheet_gov.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");

		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");		
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolHasPeraa =(readPropFile.getImageFileExtn("HAS_PERAA","0")).equals("1");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"psheet_gov.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
	OvertimeMgmt otMgmt = new OvertimeMgmt();
	String strPayrollPeriod  = null;
	String strTemp2 = null;
	String strTerm = null;
	String strHourlyRate = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dDailyRate = 0d;
//	int iStart = 29; // this is where the null fields start
	int iFieldCount = 75;
	String strDateFrom = null;
	String strDateTo = null;
	double dTemp = 0d;
	double dLineTotal = 0d;
	double dTotalDed = 0d;
	double dNetPay = 0d;
	double dTotalNetPay = 0d;
		
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	Vector vLoanTerms = null;

	Vector vRetResult = null;
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;
	int iOT = 0;
	String strBgColor = "";

	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;
	Vector vOTDetail = null;
	Vector vSalDetail = null;
//	Vector vLateUtDetail = null;
	Vector vOTTypes = null;
	Vector vAdjTypes = null;
	Vector vEmpOT = null;
	Vector vEmpAdjust = null;
	Vector vContributions = null;
	String strUserIndex = null;
	double dOtherEarn = 0d;
	double dOtherDed  = 0d;
	
	double dTotalBasic = 0d;
	double dTotalGSIS = 0d;		
	double dTotalPHealth = 0d;		
	double dTotalHdmf = 0d;		
	double dTotalTax = 0d;
	double dTotalAdv = 0d;
	double dTotalGross = 0d;
	double dTotalOtherDed = 0d;
	
	double dGrandTotalDed = 0d;

	int iIndex = 0;
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"4"));

	int iNumRec = 0;//System.out.println(vRetResult);

	boolean bolShowBorder = false;
	double dNPGrandTotal = 0d;
	int i = 0;
	int iIndexOf = 0;
	vRetResult = RptPSheet.getPSheetItems(dbOP);	
 	if(vRetResult == null)
		strErrMsg = RptPSheet.getErrMsg();
	else{
		vRows = (Vector)vRetResult.elementAt(0);
		vEarnCols = (Vector)vRetResult.elementAt(1);
		vDedCols = (Vector)vRetResult.elementAt(2);		
		
		vEarnDedCols = (Vector)vRetResult.elementAt(3);			
		if(WI.fillTextValue("hide_overtime").equals("1"))
			vOTTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, true);			
		else
			vOTTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "1");
			//System.out.println("vOTTypes " + vOTTypes);
		
		if(WI.fillTextValue("hide_adjustment").equals("1"))
			vAdjTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, false);			
		else
			vAdjTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "0");
			
		vContributions = RptPSheet.checkPSheetContributions(dbOP, request, WI.fillTextValue("sal_period_index"));
		
		if(vEarnCols != null && vEarnCols.size() > 0)
			iEarnColCount = vEarnCols.size() - 2;

		if(vDedCols != null && vDedCols.size() > 0)
			iDedColCount = vDedCols.size() - 1;		

		if (vEarnDedCols != null && vEarnDedCols.size() > 0)
			iEarnDedCount = vEarnDedCols.size()- 1;
			
		iSearchResult = RptPSheet.getSearchCount();		
	}

	String[] astrContributions = {"1", "1", "1", "1", "1"};
	// 0 = sss_amt
	// 1 = philhealth_amt
	// 2 = pag_ibig
	// 3 = gsis_ps
  // 4 = peraa
	
	
	if(WI.fillTextValue("hide_contributions").equals("1") && vContributions != null){
		for(i = 0; i < vContributions.size(); i++)
			astrContributions[i] = (String)vContributions.elementAt(i);
	}	
	
	double[] adEarningTotal = new double[iEarnColCount];
	double[] adDeductTotal = new double[iDedColCount];	
	double[] adEarnDedTotal = new double[iEarnDedCount];
	double[] adWeeklyTotal = new double[4];
	
	boolean bolPageBreak  = false;
	int iColCounter  = 0;
	int iTotalPages = 0;
	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	  if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		break;
	  }
	}
		
	if(vRows != null && vRows.size() > 0){
		iTotalPages = (vRows.size())/(iFieldCount*iMaxRecPerPage);	
	if((vRows.size() % (iFieldCount*iMaxRecPerPage)) > 0) 
		 ++iTotalPages;

	 for (;iNumRec < vRows.size();iPage++){
	 	
		dTemp = 0d;

		dLineTotal = 0d;
		
		// reset the page total 
		//for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
		//	adEarningTotal[iCols-2] = 0d;	
		//}
		 				 
		//for(iCols = 1;iCols <= iDedColCount; iCols++){
		// adDeductTotal[iCols-1] = 0d;
		//}
		
		//for(iCols = 1;iCols <= iEarnDedCount; iCols++){
		// adEarnDedTotal[iCols-1] = 0d;
		//}	
%>
<body onLoad="window.print();">
<form name="form_" >
    <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="24" colspan="10" align="center" ><strong><font color="#0000FF"> <%=WI.fillTextValue("report_title")%> FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>
		</table>
		<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="10%" height="33" align="center" class="header_style">NAME 
        OF EMPLOYEE </td>
      <td width="19%" align="center" nowrap class="header_style">PERIOD OF SERVICE<br>
      FROM -- TO </td>
      <td width="11%" align="center" class="header_style">MONTHLY SALARY </td>
      <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
			<td width="5%" align="center" class="header_style"><%=(String)vEarnCols.elementAt(iCols)%></td>
			<%}%>
      <td width="8%" align="center" class="header_style">TOTAL SALARY </td>
      <td width="13%" align="center" class="header_style">TOTAL DEDUCTIONS </td>
      <td width="9%" align="center" class="header_style">NET AMOUNT DUE </td>
      <td width="9%" align="center" class="header_style">AMOUNT PAID IN CASH </td>
      <td width="5%" align="center" class="header_style">NO</td>
      <td width="11%" align="center" class="header_style">SIGNATURE OF PAYEE </td>
    </tr>
      <%
		for(iCount = 1;iNumRec<vRows.size(); iNumRec+=iFieldCount,++iCount){		
		i = iNumRec;	
 	strUserIndex = (String)vRows.elementAt(i+1);
  vEarnings = (Vector)vRows.elementAt(i+53);
	vDeductions = (Vector)vRows.elementAt(i+54);
	vSalDetail = (Vector)vRows.elementAt(i+55); 
	vOTDetail = (Vector)vRows.elementAt(i+56);
	vEarnDed  = (Vector)vRows.elementAt(i+59);		
	//vLateUtDetail = (Vector)vRows.elementAt(i+64);
	vEmpOT = (Vector)vRows.elementAt(i+65);
	vEmpAdjust = (Vector)vRows.elementAt(i+67);
	vLoanTerms = (Vector)vRows.elementAt(i+73);
	dLineTotal = 0d;
 	dOtherEarn = 0d;
	dOtherDed = 0d;
	dTotalDed = 0d;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			}
			else 
				bolPageBreak = false;			
		%>
    <tr bgcolor="<%=strBgColor%>">
      <td height="24" valign="bottom" nowrap class="detail_style" ><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong></td>
			<td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
			<%
	  	//monthly rate
			strTemp = (String)vRows.elementAt(i + 70);
			strTemp = WI.getStrValue(strTemp, "0");
			dTemp = Double.parseDouble(strTemp);
			dTotalBasic += dTemp;
			strTemp = CommonUtil.formatFloat(strTemp, true);
 			if(dTemp == 0d)
				strTemp = "&nbsp;";

			// period rate
			dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));				
  	  %>					
      <td align="right" valign="bottom" class="detail_style" ><%=strTemp%></td>
      <%for(iCols = 2;iCols <= iEarnColCount +1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);
			dTemp = Double.parseDouble(strTemp);
			dLineTotal += dTemp;
			adEarningTotal[iCols-2] = adEarningTotal[iCols-2] + dTemp;
			strTemp = CommonUtil.formatFloat(strTemp, true);
			if(dTemp == 0d)
				strTemp = "";
			%>			
      <td align="right" valign="bottom" class="detail_style" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%}%>
      <%
				// System.out.println("dLineTotal " + dLineTotal);
				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
				dTotalGross += dLineTotal;
			%>
      <td align="right" valign="bottom" class="detail_style" ><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
      <%				
				strTemp = (String)vRows.elementAt(i+52);
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dNetPay = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			%>			
      <td align="right" valign="bottom" class="detail_style" ><%=strTemp%></td>
      <td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
      <td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
      <td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
    </tr>
    <tr bgcolor="<%=strBgColor%>">
      <td height="24" valign="bottom" nowrap >&nbsp;</td>
      <td colspan="2" align="left" valign="bottom" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <%if(astrContributions[3].equals("1")){
					// GSIS
					strTemp = (String)vRows.elementAt(i + 42);			
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
					strTemp = CommonUtil.formatFloat(strTemp,true);
					dTotalDed += dTemp;
					dTotalGSIS += dTemp;
					if(dTemp == 0d)
						strTemp = "--";				
				%>
				<tr>
          <td width="63%" height="16" align="left" class="detail_style" >GSIS PREMIUM </td>
          <td width="37%"  align="right" class="detail_style"><%=strTemp%></td>
          </tr>
				<%}%>
				<%if(astrContributions[1].equals("1")){
					// philhealth
					strTemp = (String)vRows.elementAt(i + 40);			
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
					strTemp = CommonUtil.formatFloat(strTemp,true);
					dTotalDed += dTemp;
					dTotalPHealth += dTemp;
					if(dTemp == 0d)
						strTemp = "--";
				%>				
        <tr>
          <td height="16" align="left" class="detail_style" >PHIC</td>
          <td align="right" class="detail_style" ><%=strTemp%></td>
          </tr>
				<%}%>
				<%if(astrContributions[2].equals("1")){
				// pag ibig
				strTemp = (String)vRows.elementAt(i +41);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dTotalDed += dTemp;
				dTotalHdmf  += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
        <tr>
          <td height="16" align="left" class="detail_style" >PAG-IBIG FUND </td>
          <td align="right" class="detail_style" ><%=strTemp%></td>
          </tr>
				<%}%>
        <tr>
          <td height="16" align="left" class="detail_style" >W/TAX</td>
					<%
						// tax withheld
						strTemp = (String)vRows.elementAt(i + 46);
						dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
						strTemp = CommonUtil.formatFloat(strTemp,true);
						dTotalDed += dTemp;
						dTotalTax  += dTemp;
						if(dTemp == 0d)
							strTemp = "--";
					%>					
          <td align="right" class="detail_style" ><%=strTemp%></td>
          </tr>
      </table></td>
			<%if(iEarnColCount > 0){%>
			<td align="right" colspan="<%=iEarnColCount%>" valign="bottom" class="detail_style" >&nbsp;</td>
			<%}%>
			<td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
      <td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
      <%
			// Night Differential
			strTemp = (String)vRows.elementAt(i + 24);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
			if(dTemp > 0d){
				dNPGrandTotal += dTemp;
				strTemp = CommonUtil.formatFloat(dTemp, true);		
				strTemp = "NP : " + strTemp;
			}else{
				strTemp = "&nbsp;";						
			}
			%>					
      <td align="right" valign="top" class="detail_style" ><%=strTemp%></td>
      <td colspan="2" valign="top" class="detail_style" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
					<%
						dTemp = CommonUtil.formatFloatToCurrency(dNetPay/4, 0);
						strTemp = CommonUtil.formatFloat(dTemp, true);
						adWeeklyTotal[0] += dTemp;
						adWeeklyTotal[1] += dTemp;
						adWeeklyTotal[2] += dTemp;
					%>
          <td width="70%" height="20" align="right" class="detail_style"><%=strTemp%>&nbsp;</td>
          <td width="30%" align="right" class="detail_style">1&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="detail_style"><%=strTemp%>&nbsp;</td>
          <td align="right" class="detail_style">2&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="detail_style"><%=strTemp%>&nbsp;</td>
          <td align="right" class="detail_style">3&nbsp;</td>
        </tr>
        <tr>
					<%
						dTemp = dNetPay - (dTemp * 3);
						adWeeklyTotal[3] += dTemp;
						strTemp = CommonUtil.formatFloat(dTemp, true);
					%>					
          <td height="20" align="right" class="detail_style"><%=strTemp%>&nbsp;</td>
          <td align="right" class="detail_style">4&nbsp;</td>
        </tr>
      </table></td>
      <td align="right" valign="top" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="43%" height="20" align="right" class="thinborderBOTTOM">&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="thinborderBOTTOM">&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="thinborderBOTTOM">&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="thinborderBOTTOM">&nbsp;</td>
        </tr>
      </table></td>
    </tr>
    <tr bgcolor="<%=strBgColor%>">
      <td height="20" valign="bottom" nowrap >&nbsp;</td>
      <td colspan="2" align="right" valign="bottom" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
<%			
			for(iCols = 1;iCols <= iDedColCount; iCols+=2){
				strTemp = (String)vDedCols.elementAt(iCols);
				strAmt = (String)vDeductions.elementAt(1+(iCols/2));
				dTemp = Double.parseDouble(strAmt);
				adDeductTotal[iCols-1] = adDeductTotal[iCols-1] + dTemp;	
				dTotalDed += dTemp;
				strAmt = CommonUtil.formatFloat(strAmt, true);
				if(dTemp > 0d){
			%>				
        <tr>
          <td width="63%" height="18" align="left" class="detail_style" ><%=strTemp%></td>
          <td width="37%" align="right" class="detail_style" >&nbsp;<%=strAmt%></td>
          </tr>
				<%}
				}%>
			<%
			// this is the other ungrouped deductions
			strTemp = (String)vDeductions.elementAt(0);
			dTemp = Double.parseDouble(strTemp);
			dOtherDed += dTemp;
			
			// misc_deduction
			strTemp = (String)vRows.elementAt(i + 45); 
			strTemp = WI.getStrValue(strTemp,"0");
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dOtherDed += Double.parseDouble(strTemp);				
 			dTotalDed += dOtherDed;
			dTotalOtherDed += dOtherDed;
			strTemp = CommonUtil.formatFloat(dOtherDed,true);
			if(dOtherDed > 0d){
		  %>				
        <tr>
          <td height="16" align="left" class="detail_style" > Other deductions </td>
          <td align="right" class="detail_style" >&nbsp;<%=strTemp%></td>
          </tr>
				<%}%>
      </table></td>
      <td align="right" colspan="<%=iEarnColCount + 2%>>" valign="top" class="detail_style" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
			<%
  			for(iCols = 1;iCols <= iDedColCount; iCols+=2){
				strTemp = (String)vDedCols.elementAt(iCols);
				strAmt = (String)vDeductions.elementAt(1+(iCols/2));
				dTemp = Double.parseDouble(strAmt);
				if(dTemp > 0d){
					strTerm = null;
					iIndexOf = vLoanTerms.indexOf(strTemp);
					while(iIndexOf != -1){
						vLoanTerms.remove(iIndexOf); // remove group name
	
						if(strTerm == null){
							strTemp2 = (String)vLoanTerms.remove(iIndexOf);
							strTerm = strTemp2.substring(0, strTemp2.indexOf("/"));
							
							strTemp2 = "/" +strTemp2.substring(strTemp2.length() - 2, strTemp2.length());
							strTerm += strTemp2;
	
							strTemp2 = (String)vLoanTerms.remove(iIndexOf);
							strTerm += " - " +strTemp2.substring(0, strTemp2.indexOf("/"));
							strTemp2 = "/" +strTemp2.substring(strTemp2.length() - 2, strTemp2.length());
							strTerm +=  strTemp2;						
						}else{
							strTemp2 = (String)vLoanTerms.remove(iIndexOf);
							strTerm += ", " + strTemp2.substring(0, strTemp2.indexOf("/"));
							strTemp2 = "/" +strTemp2.substring(strTemp2.length() - 2, strTemp2.length());
							strTerm +=  strTemp2;
	
							strTemp2 = (String)vLoanTerms.remove(iIndexOf);
							strTerm += " - " + strTemp2.substring(0, strTemp2.indexOf("/"));
							strTemp2 = "/" +strTemp2.substring(strTemp2.length() - 2, strTemp2.length());
							strTerm += strTemp2;						
						}
						
						vLoanTerms.remove(iIndexOf); // remove ret_loan_index
						iIndexOf = vLoanTerms.indexOf(strTemp);
					}
				
 			%>				
        <tr>
          <td class="detail_style" height="18">&nbsp;<%=WI.getStrValue(strTerm,"(",")","")%></td>
         </tr>
				<%}
				}%>
      </table></td>
      <td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
      <td colspan="2" valign="top" class="detail_style" >&nbsp;</td>
      <td align="right" valign="top" >&nbsp;</td>
    </tr>
    <tr bgcolor="<%=strBgColor%>">
      <td height="20" valign="bottom" nowrap >&nbsp;</td>
      <td colspan="2" align="right" valign="bottom" >&nbsp;</td>
			<%if(iEarnColCount > 0){%>
      <td align="right" colspan="<%=iEarnColCount%>" valign="bottom" class="detail_style" >&nbsp;</td>
			<%}%>
			<td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
			<%
				dGrandTotalDed +=dTotalDed;
			%>
      <td align="right" valign="bottom" class="detail_style" ><%=CommonUtil.formatFloat(dTotalDed, true)%></td>
      <td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
      <td colspan="2" valign="top" class="detail_style" >&nbsp;</td>
      <td align="right" valign="top" >&nbsp;</td>
    </tr>
    <tr bgcolor="<%=strBgColor%>">
      <td height="5" colspan="<%=9+ iEarnColCount%>"  valign="bottom"><hr size="1"> </td>
      </tr>
    <%}//end for loop %>
  </table>

  <%if (bolPageBreak){%>
<DIV style="page-break-before:always">&nbsp;</Div>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()%>
	<%if(iNumRec >= vRows.size()){%> 	
	<DIV style="page-break-before:always">&nbsp;</Div>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="16%" height="22" align="center" bgcolor="#FFFFFF" class="header_style">BASIC</td>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
			<td width="6%" align="center" class="header_style" >&nbsp;<%=(String)vEarnCols.elementAt(iCols)%></td>
			<%}%>
			<%if(dNPGrandTotal > 0d){%>
			<td width="7%" align="center" class="header_style" >NP</td>
			<%}%>			
      <td width="25%" align="center" bgcolor="#FFFFFF" class="header_style">GROSS AMOUNT </td>
      <td width="23%" height="22" align="center" bgcolor="#FFFFFF" class="header_style">DEDUCTIONS</td>
      <td width="23%" height="22" align="center" bgcolor="#FFFFFF" class="header_style">NET AMOUNT </td>
    </tr>
    <tr>
      <td height="26" align="center" valign="top" bgcolor="#FFFFFF" class="detail_style"><%=CommonUtil.formatFloat(dTotalBasic, true)%></td>
      
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%>
			<td align="right" valign="top" class="detail_style" ><%=CommonUtil.formatFloat(adEarningTotal[iCols-2],true)%></td>
			<%}%>
			<%if(dNPGrandTotal > 0d){%>
			<td align="right" valign="top" class="detail_style" ><%=CommonUtil.formatFloat(dNPGrandTotal, true)%>&nbsp;</td>
			<%}%>			
      <td align="center" valign="top" bgcolor="#FFFFFF" class="detail_style"><%=CommonUtil.formatFloat(dTotalGross, true)%></td>
      <td height="26" align="center" valign="top" bgcolor="#FFFFFF"><table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
				  <td height="16" class="detail_style">GSIS PREMIUM </td>
				  <td align="right" class="detail_style"><%=CommonUtil.formatFloat(dTotalGSIS, true)%>&nbsp;</td>
				  </tr>
				<tr>
				  <td height="16" class="detail_style">PHIC</td>
				  <td align="right" class="detail_style"><%=CommonUtil.formatFloat(dTotalPHealth, true)%>&nbsp;</td>
				  </tr>
				<tr>
				  <td height="16" class="detail_style">PAG-IBIG FUND </td>
				  <td align="right" class="detail_style"><%=CommonUtil.formatFloat(dTotalHdmf, true)%>&nbsp;</td>
				  </tr>
				<tr>
				  <td height="16" class="detail_style">W/TAX</td>
				  <td align="right" class="detail_style"><%=CommonUtil.formatFloat(dTotalTax, true)%>&nbsp;</td>
				</tr>
				<%			
					for(iCols = 1;iCols <= iDedColCount; iCols +=2){
						strTemp = (String)vDedCols.elementAt(iCols);
					if(adDeductTotal[iCols-1] > 0d){
				%>
				<tr>
          <td width="62%" height="16" class="detail_style"><%=strTemp%></td>
          <td width="38%" align="right" class="detail_style"><%=CommonUtil.formatFloat(adDeductTotal[iCols-1],true)%>&nbsp;</td>
        </tr>
				<%}// end if
				}%>
				<%if(dTotalDed > 0d){%>
				<tr>
				  <td height="16" class="detail_style">Other Deductions </td>
				  <td align="right" class="detail_style"><%=CommonUtil.formatFloat(dTotalOtherDed, true)%>&nbsp;</td>
				</tr>
				<tr>
				  <td height="18" class="detail_style">&nbsp;</td>
				  <td align="right" class="thinborderBOTTOM">&nbsp;</td>
				  </tr>
				<tr>
				  <td height="18" class="detail_style">TOTAL DEDUCTION: </td>
				  <td align="right" class="detail_style"><%=CommonUtil.formatFloat(dGrandTotalDed, true)%></td>
				  </tr>
				<%}%>
      </table></td>
      <td height="26" align="center" valign="top" bgcolor="#FFFFFF"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="57%" align="right" class="detail_style">1 st</td>
          <%
						strTemp = CommonUtil.formatFloat(adWeeklyTotal[0], true);
					%>
          <td width="57%" height="20" align="right" class="detail_style"><%=strTemp%>&nbsp;</td>
          </tr>
        <tr>
          <td align="right" class="detail_style">2 nd</td>
          <%
						strTemp = CommonUtil.formatFloat(adWeeklyTotal[1], true);
					%>
          <td height="20" align="right" class="detail_style"><%=strTemp%>&nbsp;</td>
          </tr>
        <tr>
          <td align="right" class="detail_style">3 rd</td>
          <%
						strTemp = CommonUtil.formatFloat(adWeeklyTotal[2], true);
					%>
          <td height="20" align="right" class="detail_style"><%=strTemp%>&nbsp;</td>
          </tr>
        <tr>
          <td align="right" class="detail_style">4 th</td>
          <%
						strTemp = CommonUtil.formatFloat(adWeeklyTotal[3], true);
					%>
          <td height="20" align="right" class="detail_style"><%=strTemp%>&nbsp;</td>
          </tr>
        <tr>
          <td align="right" class="detail_style">&nbsp;</td>
          <td height="20" align="right" class="thinborderBOTTOM">&nbsp;</td>
          </tr>
        <tr>
          <td align="right" class="detail_style">TOTAL</td>
					<%
					dTotalNetPay = 0d;
					for(i = 0; i < 4; i++)
						dTotalNetPay += adWeeklyTotal[i];
					%>		
          <td height="20" align="right" class="detail_style"><%=CommonUtil.formatFloat(dTotalNetPay, true)%></td>
          </tr>
      </table></td>
    </tr>
  </table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="13%">&nbsp;</td>
    <td width="7%">&nbsp;</td>
    <td width="29%">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="21%">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="14%">&nbsp;</td>
    </tr>
  <tr>
    <td><font size="1">CERTIFIED:</font></td>
    <td colspan="2"><font size="1">Services duly rendered as stated</font></td>
    <td>&nbsp;</td>
    <td><font size="1">APPROVED FOR PAYMENT </font></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center"><strong><%=WI.fillTextValue("signatory_1").toUpperCase()%></strong></td>
    <td>&nbsp;</td>
    <td colspan="2" align="center"><strong><%=WI.fillTextValue("signatory_2").toUpperCase()%></strong></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center"><%=WI.fillTextValue("position_1")%></td>
    <td>&nbsp;</td>
    <td colspan="2" align="center"><%=WI.fillTextValue("position_2")%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">Administrative division </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td colspan="3"><font size="1">CERTIFIED: Supporting dosuments complete and proper, and cash available in the amount of  <u><%=new ConversionTable().convertAmoutToFigure(dTotalNetPay,"Pesos","Centavos")%></u> </font></td>
    <td>&nbsp;</td>
    <td colspan="5"><font size="1">CERTIFIED: Each employee whose name appears above has been paid the amount indicated opposite on his/ her name. </font></td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center"><strong><%=WI.fillTextValue("signatory_3").toUpperCase()%></strong></td>
    <td>&nbsp;</td>
    <td colspan="2" align="center"><strong><%=WI.fillTextValue("signatory_4").toUpperCase()%></strong></td>
    <td align="center" class="thinborderBOTTOM"><%=WI.getTodaysDate(1)%></td>
    <td>&nbsp;</td>
    <td rowspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="55%">ALOBS</td>
        <td width="45%" class="thinborderBOTTOM">&nbsp;</td>
      </tr>
      <tr>
        <td>DATE</td>
        <td class="thinborderBOTTOM">&nbsp;</td>
      </tr>
      <tr>
        <td>JEV NO. </td>
        <td class="thinborderBOTTOM">&nbsp;</td>
      </tr>
      <tr>
        <td>DATE</td>
        <td class="thinborderBOTTOM">&nbsp;</td>
      </tr>
    </table></td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center" valign="top"><%=WI.fillTextValue("position_3")%></td>
    <td>&nbsp;</td>
    <td colspan="2" align="center" valign="top"><%=WI.fillTextValue("position_4")%></td>
    <td align="center" valign="top">Date</td>
    <td>&nbsp;</td>
    </tr>
</table>

	<%}%>	
<%} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>