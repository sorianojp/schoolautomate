<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary by Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.NoBorder {
	font-family:  Arial,  Verdana, Geneva,  Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }	
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("size_header")%>px;
    }
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	
//add security here.
 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheet","psheet_summary_udmc.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
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
														"psheet_summary_udmc.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
	String strPayrollPeriod  = null;
	String strTemp2 = null;
//	int iStart = 29; // this is where the null fields start
	int iFieldCount =31;
	int i = 0;
	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	  if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		break;
	  }
	}
	
 	double dTemp = 0d;
	double dLineTotal = 0d;
	
	double dNightDuty = 0d;
	double dRegular = 0d;
	double dOvertime = 0d;
	double dAdjustment = 0d;
	double dOtherInc = 0d;
	double dGross = 0d;
	double dSSSPrem = 0d;
	double dMedicare = 0d;
	double dWtax = 0d;
	double dPagibig = 0d;
	double dOtherDed = 0d;
	double dNetPay = 0d;
	 		
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;

	Vector vRetResult = null;
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;

	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;
	Vector vOTDetail = null;
	Vector vSalDetail = null;
 		
	vRetResult = RptPSheet.generatePSheetSummary(dbOP);
 
	vRows = (Vector)vRetResult.elementAt(0);
	vEarnCols = (Vector)vRetResult.elementAt(1);
	vDedCols = (Vector)vRetResult.elementAt(2);		
	vEarnDedCols = (Vector)vRetResult.elementAt(3);			

	if(vEarnCols != null && vEarnCols.size() > 0)
		iEarnColCount = vEarnCols.size() - 2;
	 
	if(vDedCols != null && vDedCols.size() > 0)
		iDedColCount = vDedCols.size() - 1;		
	 
	if (vEarnDedCols != null && vEarnDedCols.size() > 0)
		 iEarnDedCount = vEarnDedCols.size() - 1;	

	double[] adEarningTotal = new double[iEarnColCount];
	double[] adDeductTotal = new double[iDedColCount];
	double[] adEarnDedTotal = new double[iEarnDedCount];
 
%>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="psheet_summary_udmc.jsp">
  <% if (vRows != null && vRows.size() > 0 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="16"><div align="center"><strong>PAYROLL 
          SHEET FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></strong></div></td>
    </tr>
    
    <tr>
      <td width="8%" height="33" align="center" class="thinborderBOTTOM">NightDuty</td>
      <td width="5%" align="center" class="thinborderBOTTOM">Regular</td>
      <td width="7%" align="center" class="thinborderBOTTOM">OT pay </td>
      <td width="7%" align="center" class="thinborderBOTTOM">Adjustment</td> 
			<%for(iCols = 2;iCols < iEarnColCount; iCols ++){%>
      <td width="7%" height="33" align="center" class="thinborderBOTTOM"><%=(String)vEarnCols.elementAt(iCols)%></td>
			<%}%>
      <td width="7%" height="33" align="center" class="thinborderBOTTOM">Other Inc </td>
			<%for(iCols = 1;iCols < iEarnDedCount; iCols ++){%>			
      <td width="9%" align="center" class="thinborderBOTTOM"><%=(String)vEarnDedCols.elementAt(iCols)%>&nbsp;</td>
			<%}%>
      <td width="9%" align="center" class="thinborderBOTTOM">Lates &amp; Absences</td>
      <td width="9%" align="center" class="thinborderBOTTOM">Gross Pay </td>
      <td width="8%" align="center" class="thinborderBOTTOM">SSS Prem </td>
      <td width="7%" align="center" class="thinborderBOTTOM">Medicare</td>
      <td width="8%" align="center" class="thinborderBOTTOM">W/tax</td>
      <td width="8%" align="center" class="thinborderBOTTOM">Pag Prem </td>
      <%			
			for(iCols = 1;iCols < iDedColCount; iCols ++){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>						
      <td align="center" class="thinborderBOTTOM"><%=strTemp%></td>
			<%}%>
      <td width="7%" align="center" class="thinborderBOTTOM">Other deds </td>
      <td width="5%" align="center" class="thinborderBOTTOM">Net pay </td>
    </tr>
    <% 
	if (vRows != null && vRows.size() > 0 ){
      for(i = 0; i < vRows.size(); i += iFieldCount){
	  dLineTotal = 0d;
	   
		vEarnings = (Vector)vRows.elementAt(i+28);
		vDeductions = (Vector)vRows.elementAt(i+29);
		vEarnDed = (Vector)vRows.elementAt(i+30);
	%>
    <tr>
			<%
				strTemp = WI.getStrValue((String)vRows.elementAt(i+2),(String)vRows.elementAt(i+3));  	
				strTemp = WI.getStrValue(strTemp,"No Office");
			%>
      <td height="18" colspan="16" class="NoBorder">&nbsp;<strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
		<%
			// Night diff
			strTemp = (String)vRows.elementAt(i + 4);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);
			 dNightDuty += dTemp;

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td height="21" align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
		<%
			// period rate
			strTemp = (String)vRows.elementAt(i + 5);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			dRegular += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>			
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
		<%
			// OT Amount
			strTemp = (String)vRows.elementAt(i + 6);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			dOvertime += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>			
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
		<%
			// Adjustment
			strTemp = (String)vRows.elementAt(i + 7);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			dAdjustment += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = "";
			%>			
			<%for(iCols = 2;iCols < iEarnColCount; iCols++){
				strTemp = (String)vEarnings.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				adEarningTotal[iCols-2] = adEarningTotal[iCols-2] + dTemp;
				dLineTotal += dTemp;				
				if(dTemp == 0d)
					strTemp = "";			
			%>  
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%}%>
		<%
			dTemp = 0d;
			if(vEarnings != null){
				// subject allowances 
				strTemp = (String)vEarnings.elementAt(0); 
				if (strTemp.length() > 0){
					dTemp = Double.parseDouble(strTemp);
				}
				// ungrouped earnings.
				strTemp = (String)vEarnings.elementAt(1); 
				if (strTemp.length() > 0){
					dTemp += Double.parseDouble(strTemp);
				}				
			}	
			// addl_payment_amt
			strTemp = (String)vRows.elementAt(i + 8);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// adhoc_bonus
			strTemp = (String)vRows.elementAt(i + 9);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// holiday_pay_amt
			strTemp = (String)vRows.elementAt(i + 10);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// addl_resp_amt
			strTemp = (String)vRows.elementAt(i + 11);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// cola_amt
			strTemp = (String)vRows.elementAt(i + 12);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// faculty_salary
			strTemp = (String)vRows.elementAt(i + 13);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// fac_allowance
			strTemp = (String)vRows.elementAt(i + 14);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// tax_refund
			strTemp = (String)vRows.elementAt(i + 15);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// honorarium
			strTemp = (String)vRows.elementAt(i + 16);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// substitute_sal
			strTemp = (String)vRows.elementAt(i + 17);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// overload_amt
			strTemp = (String)vRows.elementAt(i + 18);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			dOtherInc += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%for(iCols = 1;iCols < iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				adEarnDedTotal[iCols-1] = adEarnDedTotal[iCols-1] + dTemp;
				dLineTotal -= dTemp;
				if(strTemp.equals("0"))
					strTemp = "";			
			%>				
		  <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%}%>
		  <%
			dTemp = 0d;
			if(vEarnDed != null){
				// subject allowances 
				strTemp = (String)vEarnDed.elementAt(0); 
				if (strTemp.length() > 0){
					dTemp = Double.parseDouble(strTemp);
				}
			}					
			// leave_deduction_amt
			strTemp = (String)vRows.elementAt(i + 24);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// awol_amt
			strTemp = (String)vRows.elementAt(i + 26);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// late_under_amt
			strTemp = (String)vRows.elementAt(i + 27);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			dLineTotal -= dTemp;
			dGross += dLineTotal;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>			
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
      <td align="right" valign="top" class="NoBorder"><%=CommonUtil.formatFloat(dLineTotal,2)%>&nbsp;</td>
		<%
			// sss_amt
			strTemp = (String)vRows.elementAt(i + 19);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal -= dTemp;
			dSSSPrem += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
			// phealth
			strTemp = (String)vRows.elementAt(i + 20);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal -= dTemp;
			dMedicare += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
		<%
			// tax
			strTemp = (String)vRows.elementAt(i + 21);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal -= dTemp;
			dWtax += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
		<%
			// pag ibig
			strTemp = (String)vRows.elementAt(i + 22);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal -= dTemp;
			dPagibig += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%for(iCols = 1;iCols < iDedColCount; iCols++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				if(dTemp == 0d)
					strTemp = "";			
			%>  				
      <td width="7%" align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%}%>
		<%
			// gsis_ps
			strTemp = (String)vRows.elementAt(i + 23);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// misc_deduction
			strTemp = (String)vRows.elementAt(i + 25);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			dLineTotal -= dTemp;
			dOtherDed += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>			
	  <td align="right" valign="top" class="NoBorder"><%=strTemp%></td>		
		<%
		dNetPay += dLineTotal;
		%>	
      <td align="right" valign="top" class="NoBorder"><%=CommonUtil.formatFloat(dLineTotal,2)%>&nbsp;</td>
    </tr>
    <%}//end for loop
	} // end if %>
    <tr> 
      <td height="20" align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dNightDuty ,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dRegular ,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dOvertime ,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dAdjustment ,true)%>&nbsp;</td>
			<%for(iCols = 2;iCols < iEarnColCount; iCols ++){%>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(adEarningTotal[iCols-2],true)%></td>
			<%}%>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dOtherInc ,true)%>&nbsp;</td>
			<%for(iCols = 1;iCols < iEarnDedCount; iCols++){%> 
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(adEarnDedTotal[iCols-1],true)%></td>
			<%}%>
      <td align="right" class="thinborderTOP">&nbsp; </td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dGross ,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dSSSPrem ,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dMedicare ,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dWtax ,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dPagibig ,true)%>&nbsp;</td>
      <%for(iCols = 1;iCols < iDedColCount; iCols++){
			%> 			
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(adDeductTotal[iCols-1],true)%></td>
			<%}%>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dOtherDed ,true)%></td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dNetPay ,true)%>&nbsp;</td>
    </tr>
  </table>  
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
 
	<input type="hidden" name="is_for_sheet" value="0">  	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>