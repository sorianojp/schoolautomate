<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME" %>
<%
WebInterface WI = new WebInterface(request);
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Sheet/Register Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    table.TOPRIGHT {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }

	table.TOP {
   
    border-top: 1px solid #000000;
		}

    TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
    }
    TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
    }		

		TD.BOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
    }
		
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
    }		
    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
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
	String strImgFileExt = null;
	int iSearchResult = 0;
	int iEmpCounter = 0;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheet","payroll_register_cl.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"payroll_register_cl.jsp");
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
	
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	Vector vRetResult = null;
	int iCols = 0;
	double dEmpDeduct = 0d;
	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;
	Vector vOTDetail = null;
	Vector vSalDetail = null;
	Vector vContributions = null;
	double dOtherEarn = 0d;
	double dOtherDed  = 0d;
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
	String strPayrollPeriod  = null;
	String strPayEnd = null;
	String strTemp2 = null;
	boolean bolPageBreak  = false;
	int iFieldCount = 75;// number of fields in the vector..
	int i = 0;
	int iContributions = 0;

	double dBasic = 0d;
	double dDaysWorked = 0d;
	double dTemp = 0d;
	double dLineOver = 0d;
	
	double dTotalBasic = 0d;
	double dTotalAdjust = 0d;	
	double dHoursOver = 0d;
	double dTotalOverLoad = 0d;
			
	double dTotalRegOtHr = 0d;
	double dTotalRegOtAmt = 0d;
	double dTotalRestOtHr = 0d;
	double dTotalRestOtAmt = 0d;
	double dTotalNightHrs = 0d;
	double dTotalNightDiff = 0d;
	double dTotalOver = 0d;
	
	double dTotalLateUT = 0d;
	double dTotalGross = 0d;	
	double dTotalSSS = 0d;
	double dTotalPhealth = 0d;
	double dTotalHdmf = 0d;			
	double dTotalPERAA = 0d;
	double dTotalTax = 0d;
	double dTotalOtherDed = 0d;
	double dTotalOtherEarn = 0d;

	double dTotalDeductions = 0d;
	double dTotalNetPay = 0d;
	
	// grand Total
	double dGTotalBasic = 0d;
	double dGTotalAdjust = 0d;	
	double dGHoursOver = 0d;
	double dGTotalOverLoad = 0d;
			
	double dGTotalSalary = 0d;
	double dGTotalRegOtHr = 0d;
	double dGTotalRegOtAmt = 0d;
	double dGTotalRestOtHr = 0d;
	double dGTotalRestOtAmt = 0d;
	double dGTotalNightHrs = 0d;
	double dGTotalNightDiff = 0d;
	double dGTotalOver = 0d;
	
	double dGTotalLateUT = 0d;
	double dGTotalGross = 0d;	
	double dGTotalSSS = 0d;
	double dGTotalPhealth = 0d;
	double dGTotalHdmf = 0d;			
	double dGTotalPERAA = 0d;
	double dGTotalTax = 0d;
	double dGTotalOtherDed = 0d;
	double dGTotalSSSLoan = 0d;
	double dGTotalHdmfLoan = 0d;			
	double dGTotalPERAALoan = 0d;
	double dGTotalOtherEarn = 0d;

	double dGTotalDeductions = 0d;
	double dGTotalNetPay = 0d;
	// END GRAND TOTAL variables
	double dLineTotal = 0d;
	int iMainTemp = 0;
	
	
	String strEmpCatg = "";
	if(WI.fillTextValue("employee_category").length() > 0){
		if(WI.fillTextValue("employee_category").equals("1"))
			strEmpCatg = "Teaching";
		else
			strEmpCatg = "Non-Teaching";
	}
					
		
	vRetResult = RptPSheet.getPSheetItems(dbOP);
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");		
	 for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {			
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
				strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 1) + "-" + (String)vSalaryPeriod.elementAt(i + 2);
				strPayEnd = (String)vSalaryPeriod.elementAt(i + 7);
				break;
			}
	 }

	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRows);
	
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;
	int iHour = 0;
	int iMinute = 0;
	
	int iRegHourPage = 0;
	int iRegHourGrand = 0;
	int iRegMinPage = 0;
	int iRegMinGrand = 0;
	
	int iRestHourPage = 0;
	int iRestHourGrand = 0;
	int iRestMinPage = 0;
	int iRestMinGrand = 0;	
	int iColCounter = 0;

		vRows = (Vector)vRetResult.elementAt(0);		
		vEarnCols = (Vector)vRetResult.elementAt(1);
		vDedCols = (Vector)vRetResult.elementAt(2);		
		vEarnDedCols = (Vector)vRetResult.elementAt(3);		
		vContributions = RptPSheet.checkPSheetContributions(dbOP, request, WI.fillTextValue("sal_period_index"));
		
		if(vEarnCols != null && vEarnCols.size() > 0)
			iEarnColCount = vEarnCols.size() - 2;

		if(vDedCols != null && vDedCols.size() > 0)
			iDedColCount = vDedCols.size() - 1;		
			
		if(vEarnDedCols != null && vEarnDedCols.size() > 0)
			iEarnDedCount = vEarnDedCols.size() - 1;
				
	String[] astrContributions = {"1", "1", "1", "1", "1"};
	// 0 = sss_amt
	// 1 = philhealth_amt
	// 2 = pag_ibig
	// 3 = gsis_ps
  // 4 = peraa
	if(WI.fillTextValue("hide_contributions").equals("1") && vContributions != null){
		for(i = 0; i < vContributions.size(); i++){
			astrContributions[i] = (String)vContributions.elementAt(i);
			if(((String)vContributions.elementAt(i)).equals("1"))
				iContributions++;
		}
	}	else if(!WI.fillTextValue("hide_contributions").equals("1")){
		if(bolIsSchool)
			iContributions = 4;
		else
			iContributions = 3;
	}
	astrContributions[0] = "0";
		
	if(iContributions > 1)
		iContributions -= 1;	
	
	int iPagIbigLoanGroupIndex = -1;
	double dTotalPagibigLoan = 0;	
		
	int iTotalPages = (vRows.size())/(iFieldCount*iMaxRecPerPage);			
	double[] adEarningTotal = new double[iEarnColCount];
	double[] adGEarningTotal = new double[iEarnColCount];
	
	double[] adDeductTotal = new double[iDedColCount];
	double[] adGDeductTotal = new double[iDedColCount];
	
	double[] adEarnDedTotal = new double[iEarnDedCount];
	double[] adGEarnDedTotal = new double[iEarnDedCount];

	if((vRows.size() % (iFieldCount*iMaxRecPerPage)) > 0) 
		 ++iTotalPages;

	
	 for (;iNumRec < vRows.size();iPage++){	 	
		 iMainTemp = iNumRec;
		 dTotalBasic = 0d;
		 dTotalAdjust = 0d;	
		 for(iCols = 2;iCols < iEarnColCount; iCols++){
			adEarningTotal[iCols-2] = 0d;	
		 }
		 dHoursOver = 0d;
		 dTotalOverLoad = 0d;

		 dTotalRegOtHr = 0d;
		 dTotalRegOtAmt = 0d;
		 dTotalRestOtHr = 0d;
		 dTotalRestOtAmt = 0d;
		 dTotalNightHrs = 0d;
		 dTotalNightDiff = 0d;
		 dTotalOver = 0d;
		 dTotalOtherEarn = 0d;
		 dTotalLateUT = 0d;
		 dTotalGross = 0d;
		 
		 dTotalSSS = 0d;
		 dTotalPhealth = 0d;
		 dTotalHdmf = 0d;			
		 dTotalPERAA = 0d;
		 dTotalTax = 0d;
		 // reset the page total 
		 for(iCols = 1;iCols < iDedColCount; iCols++){
			 adDeductTotal[iCols-1] = 0d;
		 }
		 dTotalOtherDed = 0d;
		 dTotalDeductions = 0d;
		 dTotalNetPay = 0d;
		 for(iCols = 1;iCols < iEarnDedCount; iCols++){
			 adEarnDedTotal[iCols-1] = 0d;
		 }

		 iRegHourPage = 0;
		 iRegMinPage = 0;
		
		 iRestHourPage = 0;
		 iRestMinPage = 0;
		 boolean bolShowAccountNo = !(WI.fillTextValue("skip_account_no").equals("1"));
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td style="letter-spacing:15px;font-family:'Times New Roman', Times, serif" align="center" colspan="3"><font size="2"><strong>GENERAL PAYROLL</strong></font></td>
    </tr>   
	 <tr>
      <td align="center" colspan="3"><br /><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
    </tr>
	<tr>
      <td align="left" height="50" width="38%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We acknowledge receipt of the sum shown opposite our names as full compensation for services rendered for the period stated:</td>
	  <td width="24%" align="center"> <u><strong>&nbsp;&nbsp;&nbsp;&nbsp;<%=strPayrollPeriod%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong></u><br />Period </td>
	  <td width="38%" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sheet <%=iPage%> of <%=iTotalPages%> sheets</td>
    </tr>  
   
    <tr>
      <td height="19" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="150%" border="0" cellspacing="0" cellpadding="0" class="TOP">
    <tr>
      <td width="1%" rowspan="2" class="headerBOTTOMLEFT">&nbsp;</td>
      <td width="14%" height="33" rowspan="2" align="center" class="headerBOTTOMLEFT">NAMES</td>
      <td width="8%" height="33" rowspan="2" align="center" class="headerBOTTOMLEFT">POSITION</td>
      <%if(WI.fillTextValue("show_hourly").length() > 0){ %>
      <td width="3%" rowspan="2" align="center" class="headerBOTTOMLEFT">RATE PER HOUR</td>
      <td width="4%" height="33" rowspan="2" align="center" class="headerBOTTOMLEFT">HOURS RENDERED</td>
      <%}%>
      <%if(WI.fillTextValue("show_daily").length() > 0){%>
      <td width="28" rowspan="2" align="center" class="headerBOTTOMLEFT">RATE PER DAY</td>
      <td width="43" height="33" rowspan="2" align="center" class="headerBOTTOMLEFT">DAYS WORKED</td>
      <%}%>
      <td width="4%" rowspan="2" align="center" class="headerBOTTOMLEFT">AMOUNT ACCURED FOR THE PERIOD </td>
      <td width="4%" rowspan="2" align="center" class="headerBOTTOMLEFT">ADJ. </td>
      <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
      <td width="4%" rowspan="2" align="center" class="headerBOTTOMLEFT"><%=(String)vEarnCols.elementAt(iCols)%></td>
      <%}%>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
      <td width="3%" rowspan="2" align="center" class="headerBOTTOMLEFT">rate/hr<br>
        overload</td>
      <td width="2%" rowspan="2" align="center" class="headerBOTTOMLEFT"># of hours of o/l </td>
      <td width="2%" rowspan="2" align="center" class="headerBOTTOMLEFT">amount of o/l </td>
      <%}%>
      <td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFT"><%if(WI.fillTextValue("employee_category").equals("1")){%>
        OVERLOAD /
        <%}%>
        OVERTIME </td>
      <td width="4%" rowspan="2" align="center" class="headerBOTTOMLEFT"><span class="BOTTOMLEFT">OTHERS</span></td>
      <td colspan="<%=iEarnDedCount+1%>" align="center" class="headerBOTTOMLEFT">DEDUCTIONS</td>
      <td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFT"><span class="BOTTOMLEFT">GROSS EARNINGS </span></td>
      <%if(iContributions > 0){%>
      <td width="6%" colspan="<%=iContributions%>" align="center" class="headerBOTTOMLEFT"> CONTRIBUTIONS </td>
      <%}%>
      <td width="3%" rowspan="2" align="center" class="headerBOTTOMLEFT">WITHTAX</td>
      <%			
				for(iCols = 1;iCols <= iDedColCount; iCols +=2){
					strTemp = (String)vDedCols.elementAt(iCols);
					if(((strTemp).toUpperCase()).startsWith("PAG-IBIG"))
						iPagIbigLoanGroupIndex = iCols;	
			%>
      <td width="3%" rowspan="2" align="center" class="headerBOTTOMLEFT"><%=strTemp%></td>
      <%}%>
      <td width="4%" rowspan="2" align="center" class="headerBOTTOMLEFT">OTHERS</td>
      <td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFT">TOTAL DEDUCTIONS</td>
      <td width="2%" rowspan="2" align="center" class="headerBOTTOMLEFT">NO</td>
      <td width="9%" rowspan="2" align="center" class="headerBOTTOMLEFT">NET PAY</td>
      <td width="9%" rowspan="2" align="center" class="headerBOTTOMLEFTRIGHT">SIGNATURE OF PAYEE</td>
    </tr>
    <tr>
      <%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td align="center" class="headerBOTTOMLEFT"><%=(String)vEarnDedCols.elementAt(iCols)%></td>
      <%}%>
      <td height="25" align="center" class="headerBOTTOMLEFT">TARDINESS/<br>
        UNDERTIME</td>
      <%if(astrContributions[0].equals("1")){%>
      <td width="2%" align="center" class="headerBOTTOMLEFT">SSS PREM </td>
      <%} if(astrContributions[1].equals("1")){%>
      <td width="4%" align="center" class="headerBOTTOMLEFT">PHILHEALTH</td>
      <%}if(astrContributions[2].equals("1")){%>
      <td width="2%" align="center" class="headerBOTTOMLEFT">HDMF PREM </td>
      <%}if(bolIsSchool && astrContributions[4].equals("1")){%>
      <td width="2%" align="center" class="headerBOTTOMLEFT">PERAA</td>
      <%}%>
    </tr>
    <% 
	  	if(iEmpCounter > 0)
			iEmpCounter-=1;
		for(iCount = 1;iMainTemp < vRows.size(); iMainTemp += iFieldCount, ++iCount){
			 iEmpCounter += 1;		
		dEmpDeduct = 0d;
		dOtherDed = 0d;
		i = iMainTemp;
		//i = iNumRec;
		vDeductions = (Vector)vRows.elementAt(i+54);
		vSalDetail = (Vector)vRows.elementAt(i+55); 			
						
		  dLineTotal = 0d;
		  dBasic = 0d;
			dDaysWorked = 0d;
			dLineOver = 0d;		
					
		
		vEarnings = (Vector)vRows.elementAt(i+53);
		vSalDetail = (Vector)vRows.elementAt(i+55); 
		vOTDetail = (Vector)vRows.elementAt(i+56);
		vEarnDed = (Vector)vRows.elementAt(i+59);
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>
    <tr>
      <%
				// Account number
				strTemp = null;
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp = (String)vSalDetail.elementAt(1);
			%>
      <td class="BOTTOMLEFT"  align="right">&nbsp;<%=iEmpCounter%>&nbsp;</td>
      <td height="19" class="BOTTOMLEFT"><strong>&nbsp;<%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong></td>
      <td align="left" class="BOTTOMLEFT">&nbsp; <%=WI.getStrValue((String)vRows.elementAt(i+74),"")%>&nbsp;</td>
      <%if(WI.fillTextValue("show_hourly").length() > 0){%>
      <%				
				//rate per hour
				//strTemp = (String)vRows.elementAt(i + iStart + 2);
				strTemp = ConversionTable.replaceString((String)vSalDetail.elementAt(5),",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
 				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <%
				// days worked
				strTemp = CommonUtil.formatFloat((String)vRows.elementAt(i + 8), false);
				strTemp = ConversionTable.replaceString(strTemp, ",","");
				dDaysWorked = Double.parseDouble(strTemp);												
				if(dDaysWorked== 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%}%>
      <%if(WI.fillTextValue("show_daily").length() > 0){%>
      <%
				//daily rate
				strTemp = ConversionTable.replaceString((String)vSalDetail.elementAt(2),",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
 				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <%
				// days worked
				strTemp = WI.getStrValue((String)vRows.elementAt(i + 20),"0");
				dDaysWorked= Double.parseDouble(strTemp);												
				if(dDaysWorked== 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%}%>
      <%
				// basic salary
				//if(WI.fillTextValue("salary_base").equals("0"))
					dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));
				//else
				//	dLineTotal = dDaysWorked * dTemp;
					
				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
				dTotalBasic += dLineTotal;
			%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
      <%
				// adjustment amount
				strTemp = (String)vRows.elementAt(i + 51); 	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp ,true);
				dLineTotal += dTemp;
				dTotalAdjust += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dLineTotal += dTemp;
			adEarningTotal[iCols-2] = adEarningTotal[iCols-2] + dTemp;
			if(strTemp.equals("0"))
				strTemp = "";			
		%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%}%>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
      <%
				dTemp = 0d;
				// overload rate per hour
				if(vSalDetail != null && vSalDetail.size() > 0){
					strTemp = (String)vSalDetail.elementAt(3);				
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
					strTemp = CommonUtil.formatFloat(strTemp,true);
				}
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%
				// number of hours overload
				
				strTemp = (String)vRows.elementAt(i + 21);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
				dHoursOver += dTemp;
				strTemp = CommonUtil.formatFloat(strTemp,true);
				
				if(dTemp == 0d)
					strTemp = "--";
				else{
				  iHour = (int) dTemp;
				  dTemp = dTemp - iHour;
				  dTemp = CommonUtil.formatFloatToCurrency(dTemp * 60, 0);
				  iMinute = (int) dTemp;
				  
				  strTemp = Integer.toString(iHour);	
															
				  strTemp2 = Integer.toString(iMinute);
				  if(strTemp2.length() == 1)
					strTemp2 = "0" + strTemp2;
									
				  strTemp = strTemp + ":" + strTemp2;
				
				  if(iHour == 0 && iMinute == 0)
					  strTemp = "";	
			   }
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%
				// overload amount
				strTemp = (String)vRows.elementAt(i + 22);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				dLineOver += dTemp;
				dTotalOverLoad += dTemp;
				strTemp = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
      <%}%>
      <%
				// regular OT Hours
				/*
				strTemp = null;
				dTemp = 0d;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(0);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				dTotalRegOtHr += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
				*/
				strTemp = null;
				iHour = 0;
				iMinute = 0;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(5);
					iHour = Integer.parseInt(strTemp);	
																
					strTemp2 = (String)vOTDetail.elementAt(6);
					iMinute = Integer.parseInt(strTemp2);
					if(strTemp2.length() == 1)
						strTemp2 = "0" + strTemp2;
										
					strTemp = strTemp + ":" + strTemp2;
					
					iRegHourPage += iHour;
					iRegMinPage += iMinute;
				}				
				if(iHour == 0 && iMinute == 0)
					strTemp = "";					
			%>
      <%
				// regular OT amount
				strTemp = null;
				dTemp = 0d;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(1);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				dTotalRegOtAmt += dTemp;
				dLineOver += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <%
				// rest day OT hour
				/*
				strTemp = null;
				dTemp = 0d;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(2);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				dTotalRestOtHr += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
				*/
				strTemp = null;
				iHour = 0;
				iMinute = 0;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(7);
					iHour = Integer.parseInt(strTemp);	
																
					strTemp2 = (String)vOTDetail.elementAt(8);
					iMinute = Integer.parseInt(strTemp2);
					if(strTemp2.length() == 1)
						strTemp2 = "0" + strTemp2;
										
					strTemp = strTemp + ":" + strTemp2;
					iRestHourPage  += iHour;
					iRestMinPage += iMinute;					
				}
				if(iHour == 0 && iMinute == 0)
					strTemp = "";					
			%>
      <%
				// rest day OT amount
				strTemp = null;
				dTemp = 0d;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(3);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				dTotalRestOtAmt += dTemp;
				dLineOver += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <%
				// Number of hours night differential
				strTemp = null;
				dTemp = 0d;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(4);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				dTotalNightHrs += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <%
				// night differential amount
				strTemp = (String)vRows.elementAt(i + 24);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
				dTotalNightDiff += dTemp;
				dLineOver += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <%
				dTotalOver +=dLineOver;
			%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dLineOver,true)%>&nbsp;</td>
      <%		
			
			if(vEarnings != null){
				// subject allowances 
				strTemp = (String)vEarnings.elementAt(0); 
				if (strTemp.length() > 0){
					dOtherEarn = Double.parseDouble(strTemp);
				}
				// ungrouped earnings.
				strTemp = (String)vEarnings.elementAt(1); 
				if (strTemp.length() > 0){
					dOtherEarn += Double.parseDouble(strTemp);
				}				
			}			
					
		// holiday_pay_amt
		if (vRows.elementAt(i+26) != null){	
			strTemp = (String)vRows.elementAt(i+26); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
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
		dTotalOtherEarn += dOtherEarn;
		dLineTotal += dOtherEarn;
		strTemp = CommonUtil.formatFloat(dOtherEarn,2);
	  %>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				adEarnDedTotal[iCols-1] = adEarnDedTotal[iCols-1] + dTemp;				
				if(strTemp.equals("0"))
					strTemp = "";			
			%>
      <td width="4%" align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%}%>
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

				// late_under_amt
				strTemp = (String)vRows.elementAt(i + 48); 			
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// faculty absences
				strTemp = (String)vRows.elementAt(i + 49); 			
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dLineTotal -= dTemp;
				dTotalLateUT += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td width="5%" align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
      <%
				dLineTotal += dLineOver;
				dTotalGross += dLineTotal;
			%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
      <%if(astrContributions[0].equals("1")){
				// sss contribution
				strTemp = (String)vRows.elementAt(i + 39);			
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				dTotalSSS += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
      <%}%>
      <%if(astrContributions[1].equals("1")){
				// philhealth
				strTemp = (String)vRows.elementAt(i + 40);				
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				dTotalPhealth += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
      <%}%>
      <%if(astrContributions[2].equals("1")){
				// pag ibig
				strTemp = (String)vRows.elementAt(i +41);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				dTotalHdmf += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
      <%}%>
      <%if(bolIsSchool){%>
      <%if(astrContributions[4].equals("1")){
				// PERAA
				strTemp = (String)vRows.elementAt(i + 43);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				dTotalPERAA+= dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
      <%}
			}%>
      <%
				// tax withheld
				strTemp = (String)vRows.elementAt(i + 46);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);														
				dEmpDeduct += dTemp;
				dTotalTax += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
      <%for(iCols = 1;iCols <= iDedColCount/2; iCols ++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				adDeductTotal[iCols-1] = adDeductTotal[iCols-1] + dTemp;	
				dEmpDeduct += dTemp;			
				 
				if(dTemp == 0d)
					strTemp = "";			
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
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
		dTotalOtherDed += dOtherDed;
		dEmpDeduct += dOtherDed;		
		dTotalDeductions += dEmpDeduct;
	  %>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dOtherDed,true)%>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dEmpDeduct,true)%>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><%=iEmpCounter%>&nbsp;</td>
      <%
				strTemp = (String)vRows.elementAt(i+52);
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dTotalNetPay += dTemp;
			%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
      <td align="right" class="BOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    <%}%>
    <%
		dGTotalBasic    += dTotalBasic;
		dGTotalAdjust   += dTotalAdjust;
		dGHoursOver     += dHoursOver;
		dGTotalOverLoad += dTotalOverLoad;
		dGTotalRegOtHr  += dTotalRegOtHr;
		dGTotalRegOtAmt += dTotalRegOtAmt;
		dGTotalRestOtHr += dTotalRestOtHr;
		dGTotalRestOtAmt += dTotalRestOtAmt;
		dGTotalNightHrs  += dTotalNightHrs;
		dGTotalNightDiff += dTotalNightDiff;
		dGTotalOver += dTotalOver;
		dGTotalOtherEarn += dTotalOtherEarn;
		dGTotalLateUT += dTotalLateUT;
		dGTotalGross += dTotalGross;
		
		dGTotalSSS += dTotalSSS;
		dGTotalPhealth += dTotalPhealth;
		dGTotalHdmf += dTotalHdmf;
		dGTotalPERAA += dTotalPERAA;
		dGTotalTax += dTotalTax;

		dGTotalOtherDed += dTotalOtherDed;
		dGTotalDeductions += dTotalDeductions;
		dGTotalNetPay += dTotalNetPay;		
			
		%>
    <tr>
      <%if(bolShowAccountNo){%>
      <td class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <td height="19" class="BOTTOMLEFT"><font size="1"><strong>TOTAL :&nbsp;&nbsp;&nbsp;</strong></font></td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%if(WI.fillTextValue("show_hourly").length() > 0){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <%if(WI.fillTextValue("show_daily").length() > 0){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalBasic,true)%>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalAdjust,true)%></td>
      <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			adGEarningTotal[iCols-2] += adEarningTotal[iCols-2];	
		%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(adEarningTotal[iCols-2],true)%></td>
      <%}%>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%
		  iHour = (int) dHoursOver;
		  dHoursOver = dHoursOver - iHour;
		  dHoursOver = CommonUtil.formatFloatToCurrency(dHoursOver * 60, 0);
		  iMinute = (int) dHoursOver;
		  
		  strTemp = Integer.toString(iHour);	
													
		  strTemp2 = Integer.toString(iMinute);
		  if(strTemp2.length() == 1)
			strTemp2 = "0" + strTemp2;
							
		  strTemp = strTemp + ":" + strTemp2;
		
		  if(iHour == 0 && iMinute == 0)
			  strTemp = "";		  
	  %>
      <!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dHoursOver,true)%>&nbsp;</td>-->
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalOverLoad,true)%>&nbsp;</td>
      <%}%>
      <%
	  	iRegHourPage += iRegMinPage/60;
	  	iRegMinPage = iRegMinPage % 60;		
		
		strTemp = Integer.toString(iRegMinPage);
		if(strTemp.length() == 1)
		 	strTemp = "0" + strTemp; 
		
		iRegHourGrand += iRegHourPage;
		iRegMinGrand += iRegMinPage;
	  %>
      <%
	  	iRestHourPage += iRestMinPage/60;
	  	iRestMinPage = iRestMinPage % 60;		
		
		strTemp = Integer.toString(iRestMinPage);
		if(strTemp.length() == 1)
		 	strTemp = "0" + strTemp; 
		
		iRestHourGrand += iRestHourPage;
		iRestMinGrand += iRestMinPage;	

		
	  %>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalOver,true)%>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalOtherEarn,true)%>&nbsp;</td>
      <%for(iCols = 1;iCols <= iEarnDedCount; iCols++){
			adGEarnDedTotal[iCols-1] = adEarnDedTotal[iCols-1];	
			%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(adEarnDedTotal[iCols-1],true)%></td>
      <%}%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalLateUT,true)%>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalGross,true)%></td>
      <%if(astrContributions[0].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalSSS,true)%></td>
      <%}if(astrContributions[1].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalPhealth,true)%></td>
      <%}if(astrContributions[2].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalHdmf,true)%></td>
      <%}if(bolIsSchool && astrContributions[4].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalPERAA,true)%></td>
      <%}%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalTax,true)%></td>
      <%for(iCols = 1;iCols <= iDedColCount/2; iCols++){
				adGDeductTotal[iCols-1] += adDeductTotal[iCols-1];	
			%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalOtherDed,true)%></td>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalDeductions ,true)%></td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalNetPay,true)%></td>
      <td align="right" class="BOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    <%if(iMainTemp == vRows.size()){%>
    <tr>
      <td class="BOTTOMLEFT">&nbsp;</td>
      <td height="19" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%if(WI.fillTextValue("show_hourly").length() > 0){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <%if(WI.fillTextValue("show_daily").length() > 0){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%for(iCols = 1;iCols <= iEarnDedCount; iCols++){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <!-- additional sul 06272012 -->
      <td class="BOTTOMLEFT">&nbsp;</td>
      <td height="18" class="BOTTOMLEFT">&nbsp;</td>
      <%if(astrContributions[0].equals("1")){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%} if(astrContributions[1].equals("1")){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%} if(astrContributions[2].equals("1")){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%} if(bolIsSchool && astrContributions[4].equals("1")){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%for(iCols = 1;iCols <= iDedColCount/2; iCols++){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFTRIGHT">&nbsp;</td>
      <!-- <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>-->
      <!-- end of additional  -->
    </tr>
    <tr>
      <%if(bolShowAccountNo){%>
      <td class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <td height="19" class="BOTTOMLEFT" style="font-size:13px"><strong>GRAND TOTAL :&nbsp;&nbsp;&nbsp;</strong></td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%if(WI.fillTextValue("show_hourly").length() > 0){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <%if(WI.fillTextValue("show_daily").length() > 0){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%}%>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalBasic,true)%></strong></td>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalAdjust,true)%></strong></td>
      <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(adGEarningTotal[iCols-2],true)%></strong></td>
      <%}%>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%
		  iHour = (int) dGHoursOver;
		  dGHoursOver = dGHoursOver - iHour;
		  dGHoursOver = CommonUtil.formatFloatToCurrency(dGHoursOver * 60, 0);
		  iMinute = (int) dGHoursOver;
		  
		  strTemp = Integer.toString(iHour);	
													
		  strTemp2 = Integer.toString(iMinute);
		  if(strTemp2.length() == 1)
			strTemp2 = "0" + strTemp2;
							
		  strTemp = strTemp + ":" + strTemp2;
		
		  if(iHour == 0 && iMinute == 0)
			  strTemp = "";		  
	  %>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong>&nbsp;</td>
      <!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dGHoursOver,true)%>&nbsp;</td>-->
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalOverLoad,true)%></strong>&nbsp;</td>
      <%}%>
      <%
	  	iRegHourGrand += iRegMinGrand/60;
	  	iRegMinGrand = iRegMinGrand % 60;		
		
		strTemp = Integer.toString(iRegMinGrand);
		if(strTemp.length() == 1)
		 	strTemp = "0" + strTemp; 
	  %>
      <%
	  	iRestHourGrand += iRestMinGrand/60;
	  	iRestMinGrand = iRestMinGrand % 60;		
		
		strTemp = Integer.toString(iRestMinGrand);
		if(strTemp.length() == 1)
		 	strTemp = "0" + strTemp; 
	  %>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalOver,true)%></strong>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalOtherEarn,true)%></strong></td>
      <%for(iCols = 1;iCols <= iEarnDedCount; iCols++){%>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(adGEarnDedTotal[iCols-1],true)%></strong></td>
      <%}%>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalLateUT,true)%></strong>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalGross,true)%></strong></td>
      <!--  start of addiotanal sul 06282012  -->
      <% if(astrContributions[0].equals("1")){%>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalSSS,true)%></strong></td>
      <%} if(astrContributions[1].equals("1")){%>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalPhealth,true)%></strong></td>
      <%} if(astrContributions[2].equals("1")){%>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalHdmf,true)%></strong></td>
      <%} if(bolIsSchool && astrContributions[4].equals("1")){%>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalPERAA,true)%></strong></td>
      <%}%>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalTax,true)%></strong></td>
      <%for(iCols = 1;iCols <= iDedColCount/2; iCols++){
	  		if(iPagIbigLoanGroupIndex == iCols)
					dTotalPagibigLoan = adGDeductTotal[iCols-1];
	  %>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(adGDeductTotal[iCols-1],true)%></strong></td>
      <%}%>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalOtherDed,true)%></strong></td>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalDeductions ,true)%></strong></td>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT" style="font-size:13px"><strong><%=CommonUtil.formatFloat(dGTotalNetPay,true)%></strong></td>
      <td align="right" class="BOTTOMLEFTRIGHT">&nbsp;</td>
      <!-- end of additional -->
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td colspan="25"><div style="border:#000000 1px solid; width:550px">
          <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td width="1%" height="25">&nbsp;</td>
              <td width="11%">ENTRY : </td>
              <td width="40%">Salaries & Wages-Contractual </td>
              <td width="10%">&nbsp; - 706</td>
              <td width="15%" align="right"><%=CommonUtil.formatFloat(dGTotalGross,true)%></td>
              <td width="18%">&nbsp;</td>
			  <td width="5%">&nbsp;</td>
            </tr>
            <tr>
              <td width="1%" height="25">&nbsp;</td>
              <td width="11%">&nbsp;</td>
              <td width="40%">Payroll Fund</td>
              <td width="10%">&nbsp; - 106</td>
              <td width="15%">&nbsp;</td>
              <td width="18%" align="right"><%=CommonUtil.formatFloat(dGTotalGross - (dTotalPagibigLoan + dGTotalTax + dGTotalHdmf),true)%></td>
            </tr>
            <tr>
              <td width="1%" height="25">&nbsp;</td>
              <td width="11%">&nbsp;</td>
              <td width="40%">Due to BIR</td>
              <td width="10%">&nbsp; - 412</td>
              <td width="15%">&nbsp;</td>
              <td width="18%" align="right"><%=CommonUtil.formatFloat(dGTotalTax,true)%></td>
            </tr>
            <tr>
              <td width="1%" height="25">&nbsp;</td>
              <td width="11%">&nbsp;</td>
              <td width="40%">Due to Pag-ibig</td>
              <td width="10%">&nbsp; - 414</td>
              <td width="15%">&nbsp;</td>
              <td width="18%" align="right"><%=CommonUtil.formatFloat(dGTotalHdmf+dTotalPagibigLoan,true)%></td>
            </tr>
          </table>
      </div></td>
    </tr>
    <%}%>
  </table>
  <!-- signatories are every page here  -->
<table width="100%" border="0" cellspacing="0" cellpadding="0"  align="center">
    <tr>
      <td width="3%">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
    
	
	
    <tr>
      <td colspan="4" style="font-size:9px">&nbsp;CERITIFIED : Services has been duly rendered as stated.</td>
	  <td width="7%">&nbsp;</td>
	  <td width="27%" style="font-size:9px">APPROVED FOR PAYMENT: </td>
    </tr>
	 <tr>
      <td height="30">&nbsp;</td>
    </tr>
    <tr >
      <td>&nbsp;</td>
      <td width="19%" height="25" style="font-size:13PX" align="center"><strong>NORBERTO C. OLAVIDES </strong></td>
	   <td width="16%" align="center">&nbsp;__________________________</td>
	   <td width="5%">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="27%" height="25" style="font-size:13PX" align="center"><strong>DELIA T. COMBISTA </strong></td>
	   <td width="14%">&nbsp;_______________________</td>
	    <td width="9%">&nbsp;</td>
	   
    </tr>
    <tr>
      <td>&nbsp;</td>
	  <td align="center" style="font-size:9px"> Vice President for Administration / Professor VI</td>
	  <td align="center" style="font-size:9px">date</td>
	  <td>&nbsp;</td>	
	  <td>&nbsp;</td>	 

	  <td align="center" style="font-size:9px"> SUC President III </td>
	  <td align="center" style="font-size:9px">date</td>
    </tr>
	<tr>
      <td>&nbsp;</td>
    </tr>
	 <tr>
      <td colspan="2" style="font-size:9px">&nbsp;CERITIFIED : Funds available in the amount of</td>
	  <td colspan="2"><strong>P</strong> <span class="grand_basic">0</span> </td>
	  <td>&nbsp;</td>
	  <td colspan="3" style="font-size:9px">&nbsp;CERITIFIED : Each employee whose name appears above has been paid the amount indicated opposite his/her name.</td>
    </tr>
	 <tr>
      <td>&nbsp;</td>
    </tr>
    <tr >
      <td>&nbsp;</td>
      <td width="19%" height="25" style="font-size:13PX" align="center"><strong>SARAH FRANCES C. BATE </strong></td>
	   <td width="16%">&nbsp;__________________________</td>
	    <td width="5%">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="27%" height="25" style="font-size:13PX" align="center"><strong>PATRIA A. BATE </strong></td>
	   <td width="14%">&nbsp;_______________________</td>
	    <td width="9%">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
	  <td align="center" style="font-size:9px">Accountant III / Director FAS </td>
	   <td align="center" style="font-size:9px">date</td>
	  <td>&nbsp;</td>	
	  <td>&nbsp;</td>	 

	  <td align="center" style="font-size:9px"> Casier III </td>
	  <td align="center" style="font-size:9px">date</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%if(iMainTemp == vRows.size()){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
	  </tr>
	</table>	
	<%}%>	  
	<%if (bolPageBreak || iMainTemp == vRows.size()){%>		
    <DIV style="page-break-before:always">&nbsp;</Div>
  <% }//page break ony if it is not last page.%> 
	<%iMainTemp = iNumRec;%>	  	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="TOPRIGHT">	
   
    
    <% 
		for(iCount = 1;iNumRec < vRows.size();iNumRec += iFieldCount, ++iCount){		
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		} else 
			bolPageBreak = false;			
	  }//end for loop%>
		
	
  </table>	
	
	
	<%if (iNumRec < vRows.size()){%>
  <DIV style="page-break-before:always">&nbsp;</Div>
  <% }//page break ony if it is not last page.
	  } //end for (iNumRec < vRows.size()
  } //end end upper most if (vRows !=null)%>
	<input type="hidden" name="prepared_by" value="<%=WI.fillTextValue("prepared_by")%>">
	<input type="hidden" name="verified_by" value="<%=WI.fillTextValue("verified_by")%>">
	
	<!-- total -->
	  <script type="text/javascript">
  		var tds = document.getElementsByTagName("span");
		for (var i = 0; i<tds.length; i++) {
		
		  // If it currently has the ColumnHeader class...
		  if (tds[i].className == "grand_basic") {
			// delete here
			tds[i].innerHTML = "<strong><%=CommonUtil.formatFloat(dGTotalBasic,true)%></strong>";			
		  }
		}	
	  </script> 
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>