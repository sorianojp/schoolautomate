<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Sheet/Register Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.header {
		font-family:  Verdana, Arial, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>px;
    }
		TD.BOTTOM {
    border-bottom: solid 1px #000000;
 		font-family:  Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<%

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;	
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheet","payroll_reg_udmc.jsp");
								
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
														"payroll_reg_udmc.jsp");
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
	String strPayrollPeriod  = null;	
	int iFieldCount = 75;// number of fields in the vector..
	int iNumRec = 0; 
	
	double dTemp = 0d;
 	double dLineTotal = 0d;
	boolean bolPageBreak = false;
	boolean bolMoveNextPage = false;
	int i = 0;
 
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	Vector vRetResult = null;
	int iIncr = 1;
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;

 	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;

	Vector vOTDetail = null;
	Vector vSalDetail = null;
	double dOtherEarn = 0d;
	boolean bolNextDept = true;
	String strSalaryBase = null; 
	
	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
 	
	double dDaysWorked = 0d;
	double dOtherDed = 0d;
	double dDeptLateUT = 0d;
	double dDeptAbs = 0d;
	double dDeptBasic = 0d;
	double dDeptSD = 0d;
	double dDeptHoliday = 0d;
	double dDeptDayOff = 0d;
	double dDeptLeavePay = 0d;
	double dDeptOthEarn = 0d;
	double dDeptGross = 0d;
	double dDeptSSS = 0d;
	double dDeptMed = 0d;
	double dDeptTax = 0d;
	double dDeptPagibig = 0d;
	double dDeptOthDed = 0d;
	double dDeptAdjust = 0d;
	double dDeptNet = 0d;
	
	double dPageLateUT = 0d;
	double dPageAbs = 0d;
	double dPageBasic = 0d;
	double dPageSD = 0d;
	double dPageHoliday = 0d;
	double dPageDayOff = 0d;
	double dPageLeavePay = 0d;
	double dPageOthEarn = 0d;
	double dPageGross = 0d;
	double dPageSSS = 0d;
	double dPageMed = 0d;
	double dPageTax = 0d;
	double dPagePagibig = 0d;
	double dPageOthDed = 0d;
	double dPageAdjust = 0d;
	double dPageNet = 0d;
		
	boolean bolOfficeTotal = false;
 
	vRetResult = RptPSheet.getPSheetItems(dbOP);
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	  if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		break;
	  }
	}
	// System.out.println("--------------------------------------");
	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iDeptCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	vRows = (Vector)vRetResult.elementAt(0);
	vEarnCols = (Vector)vRetResult.elementAt(1);
	vDedCols = (Vector)vRetResult.elementAt(2);		
	vEarnDedCols = (Vector)vRetResult.elementAt(3);	

	if(vRows != null){
	int iTotalPages = (vRows.size())/(iFieldCount*iMaxRecPerPage);	
 
	if(vEarnCols != null && vEarnCols.size() > 0)
		iEarnColCount = vEarnCols.size() - 2;
	 
	if(vDedCols != null && vDedCols.size() > 0)
		iDedColCount = vDedCols.size() - 1;		
	 
	if (vEarnDedCols != null && vEarnDedCols.size() > 0)
		iEarnDedCount = vEarnDedCols.size() - 1;	
	
	double[] aDeptEarningTotal = new double[iEarnColCount];
	double[] aDeptDeductTotal = new double[iDedColCount];
	double[] aDeptEarnDedTotal = new double[iEarnDedCount];	
			
	double[] adEarningTotal = new double[iEarnColCount];
	double[] adDeductTotal = new double[iDedColCount];
	double[] adEarnDedTotal = new double[iEarnDedCount];
	
	if((vRows.size() % (iFieldCount*iMaxRecPerPage)) > 0) 
		 ++iTotalPages;

	 for (;iNumRec < vRows.size();iPage++){ // OUTERMOST FOR LOOP
	 	dTemp = 0d;
		
		dPageLateUT = 0d;
		dPageAbs = 0d;
		dPageBasic = 0d;
		dPageSD = 0d;
		dPageHoliday = 0d;
		dPageDayOff = 0d;
		dPageLeavePay = 0d;
		dPageOthEarn = 0d;
		dPageGross = 0d;
		dPageSSS = 0d;
		dPageMed = 0d;
		dPageTax = 0d;
		dPagePagibig = 0d;
		dPageOthDed = 0d;
		dPageAdjust = 0d;
		dPageNet = 0d;
		dLineTotal = 0d;
		
		// reset the page total 
		for(iCols = 2;iCols < iEarnColCount + 2; iCols++){
			adEarningTotal[iCols-2] = 0d;	
		}
		 				 
		for(iCols = 1;iCols < iDedColCount + 1; iCols++){
		 adDeductTotal[iCols-1] = 0d;
		}
		
		for(iCols = 1;iCols < iEarnDedCount + 1; iCols++){
		 adEarnDedTotal[iCols-1] = 0d;
		}
%>
<body onLoad="javascript:window.print();">
<form name="form_"> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="24" colspan="21" align="center"><strong><font color="#0000FF">PAYROLL 
      SHEET FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>
    <tr>
      <td height="19" colspan="21">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="1">
    
    <tr>
      <td width="14%" height="33" align="center" class="header">Eamployee Name </td>
      <td width="4%" align="center" class="header">RATE<br> DaysWork</td>
      <td width="3%" align="center" class="header">SD Hr</td>
      <td width="4%" align="center" class="header">Holiday Day Off</td>
      <td width="2%" align="center" class="header">UT</td>
      <td width="4%" align="center" class="header">Leave Days</td>
      <td width="3%" align="center" class="header">Abs days </td>
	    <td width="5%" align="center" class="header">Absence</td>
      <td width="4%" align="center" class="header">Basic</td>
      <td width="4%" align="center" class="header">SD Reg.</td>
      <td width="4%" align="center" class="header">Holiday Day Off</td>
      <td width="4%" align="center" class="header">Leave Pay</td>
      <%for(iCols = 2;iCols < iEarnColCount + 2; iCols ++){%>
      <td align="center" class="header"><%=(String)vEarnCols.elementAt(iCols)%></td>			
		<%}%>
		<%for(iCols = 1;iCols < iEarnDedCount + 1; iCols ++){%>
	  <td align="center" class="header"><%=(String)vEarnDedCols.elementAt(iCols)%>&nbsp;</td>
		<%}%>
      <td width="4%" align="center" class="header">&nbsp;OTHERS&nbsp;</td>      
      <td width="4%" align="center" class="header">Gross</td>
      <td width="4%" align="center" class="header">SSS PREM<br>Medicare</td>
      <td width="4%" align="center" class="header">WITHTAX</td>
      <td width="4%" align="center" class="header"><br>PagI Prem </td>
      <%			
			for(iCols = 1;iCols < iDedColCount + 1; iCols ++){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>				
      <td width="4%" align="center" class="header"><%=strTemp%></td>
			<%}%>
      <td width="4%" align="center" class="header">Others</td>
      <td width="4%" align="center" class="header">ADJ</td>
      <td width="4%" align="center" class="header">NET PAY</td>
      <td width="4%" align="center" class="header">Signature</td>
    </tr>
    <% 
      for(; iNumRec < vRows.size();){ // DEPT FOR LOOP
  
	%>
    <%if(bolNextDept || bolMoveNextPage){
	  bolNextDept = false;
	  dDeptLateUT = 0d;
	  dDeptAbs = 0d;
	  dDeptBasic = 0d;
	  dDeptSD = 0d;
	  dDeptHoliday = 0d;
	  dDeptDayOff = 0d;
	  dDeptLeavePay = 0d;
	  dDeptOthEarn = 0d;
	  dDeptGross = 0d;
	  dDeptSSS = 0d;
	  dDeptMed = 0d;
	  dDeptTax = 0d;
	  dDeptPagibig = 0d;
	  dDeptOthDed = 0d;
	  dDeptAdjust = 0d;
	  dDeptNet = 0d;	
	  	for(iCols = 2;iCols < iEarnColCount + 2; iCols++){
			aDeptEarningTotal[iCols-2] = 0d;	
		}
		 				 
		for(iCols = 1;iCols < iDedColCount + 1; iCols++){
		 	aDeptDeductTotal[iCols-1] = 0d;
		}
		
		for(iCols = 1;iCols < iEarnDedCount + 1; iCols++){
			aDeptEarnDedTotal[iCols-1] = 0d;
		}
		
		if(iDeptCount == 3){
			iDeptCount = 0;
			iCount++;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				bolMoveNextPage = true;
				continue;
			}
			else 
				bolPageBreak = false;			
		}else
			iDeptCount++;
    %>
    <tr>
      <td height="24" colspan="24" valign="bottom">&nbsp;<strong><%=(WI.getStrValue((String)vRows.elementAt(iNumRec+62),"Dept : ","","Dept : " + (String)vRows.elementAt(iNumRec+63))).toUpperCase()%></strong></td>
    </tr>
	<%}%>
 
  <%for(; iNumRec < vRows.size();){// employee for loop
	i = iNumRec;
	if(i+iFieldCount+1 < vRows.size()){
		if(i == 0){
			strCurColl = WI.getStrValue((String)vRows.elementAt(i+2),"0");		
			strCurDept = WI.getStrValue((String)vRows.elementAt(i+3),"");	
		}
		strNextColl = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 2),"0");		
		strNextDept = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 3),"");		

 		if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
 			bolNextDept = true;
			bolOfficeTotal = true;
 		}
	}
  vEarnings = (Vector)vRows.elementAt(i+53);
	vDeductions = (Vector)vRows.elementAt(i+54);
	vSalDetail = (Vector)vRows.elementAt(i+55); 
	vOTDetail = (Vector)vRows.elementAt(i+56);
	vEarnDed  = (Vector)vRows.elementAt(i+59);
	dLineTotal = 0d;
	dDaysWorked = 0d;
 	dOtherEarn = 0d;
	dOtherDed = 0d;
	iCount++;
	if (iCount > iMaxRecPerPage){
		bolPageBreak = true;
 		break;
	}
	else 
		bolPageBreak = false; 
		%>	
    <tr>
      <td height="18" valign="bottom" class="BOTTOM"><%=(String)vRows.elementAt(i+60)%><br><%=iIncr%>&nbsp;<strong>
      <%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong></td>
      <%
				//rate per hour
				//strTemp = (String)vRows.elementAt(i + iStart + 2);
				strSalaryBase = "";
				if(vSalDetail != null && vSalDetail.size() > 0)
					strSalaryBase = (String)vSalDetail.elementAt(6); 			
				if(strSalaryBase.equals("0")){
					strTemp = (String)vSalDetail.elementAt(7); 			
					dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));
					strTemp2 = "";
				}else if(strSalaryBase.equals("1")){
					strTemp = (String)vSalDetail.elementAt(2); 					
					dDaysWorked = Double.parseDouble(strTemp);
					strTemp2 = (String)vRows.elementAt(i + 20); // days worked					
					dTemp = Double.parseDouble(strTemp2);
					dLineTotal = dDaysWorked * dTemp;
				}else if(strSalaryBase.equals("2")){
					strTemp = (String)vSalDetail.elementAt(5); 								
					dDaysWorked = Double.parseDouble(strTemp);
					strTemp2 = (String)vRows.elementAt(i + 8); // hours worked			
					dTemp = Double.parseDouble(strTemp2);
					dLineTotal = dDaysWorked * dTemp;					
				}else{
					strTemp = "";
					strTemp2 = "";
				}
			%>
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;<br>
      <%=WI.getStrValue(strTemp2,"")%>&nbsp;</td>
      <%
		// regular ot hours
		strTemp = null;
		dTemp = 0d;
		if(vOTDetail != null && vOTDetail.size() > 0){
			strTemp = (String)vOTDetail.elementAt(0);
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
		}
		if(dTemp == 0d)
			strTemp = "--";	
	  %>   
	  <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td> 	
	<%
		// rest day OT hour
		strTemp = null;
		dTemp = 0d;
		if(vOTDetail != null && vOTDetail.size() > 0){
			strTemp = (String)vOTDetail.elementAt(2);
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
		}
		if(dTemp == 0d)
			strTemp = "--";	
	%>	  		
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
		<%
			// late_under_amt
			strTemp = (String)vRows.elementAt(i + 48); 			
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal -= dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);
			dDeptLateUT += dTemp;	
			dPageLateUT += dTemp;
			if(dTemp == 0d)
				strTemp = "&nbsp;";
			%> 			
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;</td>
	   <%
		// leave days
		strTemp = (String)vRows.elementAt(i + 11);  	
		dTemp = Double.parseDouble(strTemp);
		strTemp = (String)vRows.elementAt(i + 12);  	
		dTemp += Double.parseDouble(strTemp);
		strTemp = Double.toString(dTemp);
		if(dTemp == 0d)
			strTemp = "";
	  %>   			
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
		<%
			// number of days absent
 			strTemp = (String)vRows.elementAt(i + 61); 			
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
			if(dTemp == 0d)
				strTemp = "";
		%>			  
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;</td>
		<%
			dTemp = 0d;
			// AWOL // i dont know if theres an awol anyway
			strTemp = (String)vRows.elementAt(i + 47); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

			// leave_deduction_amt
			strTemp = (String)vRows.elementAt(i + 33); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

			// faculty absences
			strTemp = (String)vRows.elementAt(i + 49); 			
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));				
			dLineTotal -= dTemp;
			dDeptAbs  += dTemp;
			dPageAbs += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);
			if(dTemp == 0d)
				strTemp = "--";
		%>
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;</td>
      <%
		// add the faculty salary
		dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
		dDeptBasic += dLineTotal;
		dPageBasic += dLineTotal;
	  %>		     
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
		
		  <%
			// regular OT amount
			strTemp = null;
			dTemp = 0d;
			if(vOTDetail != null && vOTDetail.size() > 0){
				strTemp = (String)vOTDetail.elementAt(1);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
			}
			dDeptSD += dTemp;
			dPageSD += dTemp;
 			if(dTemp == 0d)
				strTemp = "--";
			%> 
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;</td>
		<%
			// holiday pay amount
			strTemp = (String)vRows.elementAt(i + 26);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			dDeptHoliday += dTemp;
			dPageHoliday += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "&nbsp;";

			// rest day OT amount
			strTemp2 = null;
			dTemp = 0d;
			if(vOTDetail != null && vOTDetail.size() > 0){
				strTemp2 = (String)vOTDetail.elementAt(3);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp2,"0"));												
			}
			dDeptDayOff += dTemp;
 			if(dTemp == 0d)
				strTemp2 = "--";			
			%>  	
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;<br>
      <%=strTemp2%>&nbsp;</td>
		<%
			// leave deduction amt
			strTemp = (String)vRows.elementAt(i + 33);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			dDeptLeavePay += dTemp;
			dPageLeavePay += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "&nbsp;";
			%>  				
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;</td>
      <%
			for(iCols = 2;iCols < iEarnColCount + 2; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dLineTotal += dTemp;
			adEarningTotal[iCols-2] = adEarningTotal[iCols-2] + dTemp;
			aDeptEarningTotal[iCols-2] = aDeptEarningTotal[iCols-2] + dTemp;
			if(strTemp.equals("0"))
				strTemp = "";
			%>
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<%}%>	
			<%for(iCols = 1;iCols < iEarnDedCount + 1; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				adEarnDedTotal[iCols-1] = adEarnDedTotal[iCols-1] + dTemp;
				aDeptEarnDedTotal[iCols-1] = aDeptEarnDedTotal[iCols-1] + dTemp;
				if(strTemp.equals("0"))
					strTemp = "";			
			%>							
	  <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<%}%> 
      <%
				// overload amount
				strTemp = (String)vRows.elementAt(i + 22);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				dOtherEarn += dTemp;

				// night differential amount
				strTemp = (String)vRows.elementAt(i + 24);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dOtherEarn += dTemp;
				
				// COLA
				strTemp = (String)vRows.elementAt(i + 25);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dOtherEarn += dTemp;


			if(vEarnings != null){
				// subject allowances 
				strTemp = (String)vEarnings.elementAt(0); 
				if (strTemp.length() > 0){
					dOtherEarn += Double.parseDouble(strTemp);
				}
				// ungrouped earnings.
				strTemp = (String)vEarnings.elementAt(1); 
				if (strTemp.length() > 0){
					dOtherEarn += Double.parseDouble(strTemp);
				}				
			}			
					
		// addl_payment_amt 
		if (vRows.elementAt(i+27) != null){	
			strTemp = (String)vRows.elementAt(i+27); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
		}

		// Adhoc Allowances
		if (vRows.elementAt(i+28) != null){	
			strTemp = (String)vRows.elementAt(i+28); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
		}

		// addl_resp_amt
		if (vRows.elementAt(i+29) != null){	
			strTemp = (String)vRows.elementAt(i+29); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
		}
		
		// substitute salary
		if (vRows.elementAt(i+38) != null){	
			strTemp = (String)vRows.elementAt(i+38); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
		}						
		dLineTotal += dOtherEarn;
		dDeptOthEarn += dOtherEarn;
		dPageOthEarn += dOtherEarn;
		
		dPageGross += dLineTotal;
		dDeptGross += dLineTotal;
		if (dOtherEarn > 0d)
			strTemp = CommonUtil.formatFloat(dOtherEarn,true);
		else
			strTemp = "";
	  %>			
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>				
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
      <%
				// sss contribution
				strTemp = (String)vRows.elementAt(i + 39);			
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dLineTotal -= dTemp;					
				dDeptSSS += dTemp;							
				dPageSSS += dTemp;	
				strTemp = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "--";
					
				// philhealth
				strTemp2 = (String)vRows.elementAt(i + 40);				
				dTemp = Double.parseDouble(WI.getStrValue(strTemp2,"0"));	
				dLineTotal -= dTemp;			
				dDeptMed += dTemp;				
				dPageMed += dTemp;				
				strTemp2 = CommonUtil.formatFloat(strTemp2,true);
				if(dTemp == 0d)
					strTemp2 = "--";
			%>				
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;<br>
      <%=WI.getStrValue(strTemp2,"")%>&nbsp;</td>
      <%
				// tax withheld
				strTemp = (String)vRows.elementAt(i + 46);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
				dLineTotal -= dTemp;
				dDeptTax += dTemp;
				dPageTax += dTemp;
				strTemp = CommonUtil.formatFloat(strTemp,true);														
				if(dTemp == 0d)
					strTemp = "--";
			%> 			
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%
		// pag ibig
		strTemp = (String)vRows.elementAt(i +41);	
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dLineTotal -= dTemp;				
		dDeptPagibig += dTemp;	
		dPagePagibig += dTemp;
		strTemp = CommonUtil.formatFloat(strTemp,true);
		if(dTemp == 0d)
			strTemp = "--";
	  %>				
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%for(iCols = 1;iCols < iDedColCount + 1; iCols++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				adDeductTotal[iCols-1] = adDeductTotal[iCols-1] + dTemp;
				aDeptDeductTotal[iCols-1] = aDeptDeductTotal[iCols-1] + dTemp;
				if(dTemp == 0d)
					strTemp = "";			
			%> 			
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
			<%}%>
      <%
			// this is the other ungrouped deductions
			strTemp = (String)vDeductions.elementAt(0);
			dTemp = Double.parseDouble(strTemp);
			dOtherDed += dTemp;
			
			// misc_deduction
		if (vRows.elementAt(i + 45) != null){	
			strTemp = (String)vRows.elementAt(i + 45); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){ 
				dOtherDed += Double.parseDouble(strTemp);				
			}			
		}		
		dDeptOthDed += dOtherDed;	
		dPageOthDed += dOtherDed;
	  %> 
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(CommonUtil.formatFloat(dOtherDed,true),"&nbsp;")%>&nbsp;</td>
      <%
				// adjustment amount
				strTemp = (String)vRows.elementAt(i + 51); 	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp ,true);
				dLineTotal += dTemp;
				dDeptAdjust += dTemp;
				dPageAdjust += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>				
	  <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%>&nbsp;</td>
	<%
		dLineTotal -= dOtherDed;
		dDeptNet += dLineTotal;
		dPageNet += dLineTotal;
	%>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM">&nbsp;</td>
    </tr>
  <% 
 	 iNumRec+=iFieldCount;
	 iIncr++;
	 if(iNumRec < vRows.size()){
		 strCurColl = WI.getStrValue((String)vRows.elementAt(iNumRec+2),"0");
		 strCurDept = WI.getStrValue((String)vRows.elementAt(iNumRec+3),"");
	 }	 
 	if(bolNextDept){
		bolOfficeTotal = true;
		break;
	}

  %>
     <%}//end employee for loop%>
  
  <%  
  if(bolOfficeTotal || (!bolOfficeTotal && iNumRec >= vRows.size())){
  	bolOfficeTotal = false; 
	iCount++;
	if (iCount > iMaxRecPerPage){
		bolPageBreak = true;
 	}
	else 
		bolPageBreak = false; 	
  %>	
    <tr>
      <td height="26" colspan="4" valign="bottom" class="BOTTOM"><strong>Dept SubTotal </strong></td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptLateUT,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM">&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM">&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptAbs,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptBasic,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptSD,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptHoliday,true)%>&nbsp;<br>
<%=CommonUtil.formatFloat(dDeptDayOff,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptLeavePay,true)%>&nbsp;</td>
	  <% for(iCols = 2;iCols < iEarnColCount + 2; iCols++){%>	  
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(aDeptEarningTotal[iCols-2],true)%>&nbsp;</td>
	  <%}%>
	  <%for(iCols = 1;iCols < iEarnDedCount + 1; iCols ++){%>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(aDeptEarnDedTotal[iCols-1],true)%>&nbsp;</td>
	  <%}%>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptOthEarn,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptGross,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptSSS,true)%>&nbsp;<br>
			<%=CommonUtil.formatFloat(dPageMed,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptTax,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptPagibig,true)%>&nbsp;</td>
      <% for(iCols = 1;iCols < iDedColCount + 1; iCols ++){ %>		  
      <td align="right" valign="bottom" class="BOTTOM"><font size="1"><%=CommonUtil.formatFloat(aDeptDeductTotal[iCols-1],true)%>&nbsp;</font></td>
	  <%}%>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptOthDed,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptAdjust,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dDeptNet,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM">&nbsp;</td>
    </tr>
    <%}// if(bolOfficeTotal || (!bolOfficeTotal && iNumRec >= vRows.size()))%>
	<%if(bolPageBreak || iNumRec >= vRows.size()){%>
    <tr>
      <td height="26" colspan="4" valign="bottom" class="BOTTOM"><strong>Page Total </strong></td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageLateUT,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM">&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM">&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageAbs,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageBasic,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageSD,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageHoliday,true)%>&nbsp;<br>
<%=CommonUtil.formatFloat(dPageDayOff,true)%>&nbsp;</td>
       <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageLeavePay,true)%>&nbsp;</td>
	  <% for(iCols = 2;iCols < iEarnColCount + 2; iCols++){%>	  
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(adEarningTotal[iCols-2],true)%>&nbsp;</td>
	  <%}%>
	  <%for(iCols = 1;iCols < iEarnDedCount + 1; iCols ++){%>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(adEarnDedTotal[iCols-1],true)%>&nbsp;</td>
      <%}%>
	  <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageOthEarn,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageGross,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageSSS,true)%>&nbsp;<br>
<%=CommonUtil.formatFloat(dPageMed,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageTax,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPagePagibig,true)%>&nbsp;</td>
      <% for(iCols = 1;iCols < iDedColCount + 1; iCols ++){ %>		  
      <td align="right" valign="bottom" class="BOTTOM"><font size="1"><%=CommonUtil.formatFloat(adDeductTotal[iCols-1],true)%>&nbsp;</font></td>
	  <%}%>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageOthDed,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageAdjust,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dPageNet,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="BOTTOM">&nbsp;</td>
    </tr>
	<%}/// bolPageBreak || iNumRec >= vRows.size()%>
	<%
		if(bolPageBreak){
			iCount = 0;
			break;
		}
	 }// end DEPT FOR LOOP %>
  </table>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always">&nbsp;</Div>
  <%}//page break ony if it is not last page.
   } //end for (iNumRec < vRetResult.size() // END OUTERMOST FOR LOOP
  }// end if vRows != null;
 } //end end upper most if (vRetResult !=null)%>  
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_pg" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>