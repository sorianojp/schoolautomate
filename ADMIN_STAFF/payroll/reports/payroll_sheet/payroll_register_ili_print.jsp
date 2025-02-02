<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME" %>
<%
WebInterface WI = new WebInterface(request);
///added code for HR/companies.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Sheet/Register Printing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    table.TOPRIGHT {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }

    TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
    }
		
		TD.headerBOTTOMLEFTbold {
    border-bottom: solid 1px #000000;
		border-left: double 3px #000000;
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
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
    }
		
		TD.BOTTOMLEFTbold {
    border-bottom: solid 1px #000000;
		border-left: double 3px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
    }
		
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
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
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheet","payroll_register_ili_print.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0){
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
														"payroll_register_ili_print.jsp");
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
	double dCOLA = 0d;
	double dNetPay = 0d;
	
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
	double dTotalCOLA = 0d;
	
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
	double dGTotalCOLA = 0d;
	
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

	String strCurColl = null;
	String strCurDept = null;
	String strNextColl = null;
	String strNextDept = null;
	String strDeptName = null;
	boolean[] abolShowCol = {false, false, false, false};

	boolean bolOfficeTotal = false;
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
		if(WI.fillTextValue("excludeLoansMisc").length() > 0)
			vDedCols = null;
		
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
			iContributions = 3;
	}
	
	int iTotalPages = (vRows.size())/(iFieldCount*iMaxRecPerPage);			
	double[] adDeptEarningTotal = new double[iEarnColCount];
	double[] adGEarningTotal = new double[iEarnColCount];
	
	double[] adDeptDeductTotal = new double[iDedColCount];
	double[] adGDeductTotal = new double[iDedColCount];
	
	double[] adDeptEarnDedTotal = new double[iEarnDedCount];
	double[] adGEarnDedTotal = new double[iEarnDedCount];

	if(WI.fillTextValue("hide_adjust").length()== 0)
		abolShowCol[0] = true;

	if(WI.fillTextValue("hide_ot").length() == 0)
		abolShowCol[1] = true;

	if(WI.fillTextValue("hide_oth_income").length() == 0)
		abolShowCol[2] = true;

	if(WI.fillTextValue("hide_oth_deduct").length() == 0)
		abolShowCol[3] = true;
	
	for(i = 0; i < vRows.size(); i += iFieldCount){	
		vDeductions = (Vector)vRows.elementAt(i+54);
		if(WI.fillTextValue("excludeLoansMisc").length() > 0){
			vDeductions.setElementAt("0",0) ;
		}			
		vEarnings = (Vector)vRows.elementAt(i+53);
				
		// check for adjustment 
		// if there are values na dili zero... then show column
		strTemp = (String)vRows.elementAt(i + 51);  	
		//strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
		if(dTemp != 0d)
			abolShowCol[0] = true;

		// check for OT
		strTemp = (String)vRows.elementAt(i + 23);  	
		//strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
		if(dTemp > 0d)
			abolShowCol[1] = true;
		
		if(!abolShowCol[2]){
			if(vEarnings != null){
				// subject allowances 
				strTemp = WI.getStrValue((String)vEarnings.elementAt(0), "0"); 
				dTemp = Double.parseDouble(strTemp);
				if(dTemp > 0d)
					abolShowCol[2] = true;
				// ungrouped earnings.
				strTemp = WI.getStrValue((String)vEarnings.elementAt(1), "0"); 
				dTemp = Double.parseDouble(strTemp);
				if(dTemp > 0d)
					abolShowCol[2] = true;
			}

			// night differential amount
			strTemp = (String)vRows.elementAt(i + 24);  	
			//strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
			if(dTemp > 0d)
				abolShowCol[2] = true;
					
			// holiday_pay_amt
			strTemp = WI.getStrValue((String)vRows.elementAt(i+26), "0"); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			if(dTemp > 0d)
				abolShowCol[2] = true;
	
			// addl_payment_amt 
			strTemp = WI.getStrValue((String)vRows.elementAt(i+27), "0"); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			if(dTemp > 0d)
				abolShowCol[2] = true;
	
			// Adhoc Allowances
			strTemp = WI.getStrValue((String)vRows.elementAt(i+28), "0"); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			if(dTemp > 0d)
				abolShowCol[2] = true;
	
			// addl_resp_amt
			strTemp = WI.getStrValue((String)vRows.elementAt(i+29), "0"); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			if(dTemp > 0d)
				abolShowCol[2] = true;
			
			// substitute salary
			strTemp = WI.getStrValue((String)vRows.elementAt(i + 38), "0"); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			if(dTemp > 0d)
				abolShowCol[2] = true;
		}
		
		if(!abolShowCol[3]){
			// this is the other ungrouped deductions
			strTemp = (String)vDeductions.elementAt(0);
			dTemp = Double.parseDouble(strTemp);
			if(dTemp > 0d)
				abolShowCol[3] = true;
				
			// misc_deduction
			strTemp = WI.getStrValue((String)vRows.elementAt(i + 45), "0"); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			if(dTemp > 0d)
				abolShowCol[3] = true;
		}
	}

	if((vRows.size() % (iFieldCount*iMaxRecPerPage)) > 0) 
		 ++iTotalPages;

	 for (;iNumRec < vRows.size();iPage++){ 		 
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
    </tr>
    <tr>
      <td>PAYROLL - <%=strPayEnd%></td>
    </tr>
    <tr>
      <td>Days worked cut- off : <%=strPayrollPeriod%></td>
    </tr>
    <tr>
      <td height="18" align="right" class="thinborderBOTTOM">Page <%=iPage%> of <%=iTotalPages%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="TOPRIGHT">
    <tr>
			<%if(WI.fillTextValue("hide_account").length() == 0){%>
      <td width="7%" class="headerBOTTOMLEFT">Acct. No </td>			
			<%}%>
			<td width="8%" align="center" class="headerBOTTOMLEFT">DEPARTMENT</td>
      <td width="13%" height="33" align="center" class="headerBOTTOMLEFT">NAME 
          OF EMPLOYEE </td>
			<%if(WI.fillTextValue("salary_base").equals("1") || WI.fillTextValue("salary_base").equals("2")){%>
			<%
				if (WI.fillTextValue("salary_base").equals("1")){
					strTemp = "RATE PER DAY";
					strTemp2 = "DAYS WORKED";
				}else if (WI.fillTextValue("salary_base").equals("2")){
					strTemp = "RATE PER HOUR";
					strTemp2 = "HOURS WORKED";
				}else{
					strTemp = "&nbsp;";
					strTemp2 = "&nbsp;";
				}
			%>					
      <td width="2%" align="center" class="headerBOTTOMLEFT"><%=strTemp%></td>
      <td width="2%" height="33" align="center" class="headerBOTTOMLEFT"><%=strTemp2%></td>
			<%}%>
      <td width="5%" align="center" class="headerBOTTOMLEFT">BASIC SALARY </td>
      <%if(abolShowCol[0]){%>
			<td width="3%" align="center" class="headerBOTTOMLEFT">ADJ. </td>
			<%}%>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
      <td align="center" class="headerBOTTOMLEFT"><%=(String)vEarnCols.elementAt(iCols)%></td>
			<%}%>
      <%if(abolShowCol[1]){%>
			<td width="6%" align="center" class="headerBOTTOMLEFT">OVERTIME </td>
			<%}%>
			<%if(WI.fillTextValue("exclude_cola").length() == 0){%>		
      <td width="6%" align="center" class="headerBOTTOMLEFT">COLA</td>
			<%}%>
      <%if(abolShowCol[2]){%>
			<td width="6%" align="center" class="headerBOTTOMLEFT">OTHERS</td>
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td align="center" class="headerBOTTOMLEFT"><%=(String)vEarnDedCols.elementAt(iCols)%></td>
			<%}%>
      <td width="6%" align="center" class="headerBOTTOMLEFTbold"><span class="BOTTOMLEFT">GROSS PAY </span></td>
			<td width="6%" align="center" class="headerBOTTOMLEFTbold">TARDINESS/<br>
UNDERTIME</td>
			<%if(astrContributions[0].equals("1")){%>		
      <td width="8%" height="33" align="center" class="headerBOTTOMLEFT">SSS</td>
			<%} if(astrContributions[1].equals("1")){%>
      <td width="8%" align="center" class="headerBOTTOMLEFT">PHILHEALTH</td>
			<%}if(astrContributions[2].equals("1")){%>
      <td width="8%" align="center" class="headerBOTTOMLEFT">PAG-IBIG</td>
			<%}%>
			<td width="8%" align="center" class="headerBOTTOMLEFT">WITHTAX</td>
			<%			
				for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>				
			<td width="8%" align="center" class="headerBOTTOMLEFT"><%=strTemp%></td>
			<%}%>
			<%if(abolShowCol[3]){%>
			<td width="8%" align="center" class="headerBOTTOMLEFT">OTHERS</td>
			<%}%>
			<td width="8%" align="center" class="headerBOTTOMLEFTRIGHT">TOTAL DEDUCTIONS</td>
			<td width="8%" align="center" class="headerBOTTOMLEFT"><span class="BOTTOMLEFTRIGHT">NET PAY</span></td>
    </tr>
	  <% 		
		//System.out.println("vRows.size() --------------------------------- " + vRows.size());
		for(iCount = 1;iNumRec < vRows.size(); iNumRec += iFieldCount, ++iCount){
			//System.out.println("iNumRec --- " + iNumRec);
			
			dLineTotal = 0d;
			dBasic = 0d;
			dDaysWorked = 0d;
			dLineOver = 0d;		
			i = iNumRec;
 		  
			//System.out.println("lname ----- " + (String)vRows.elementAt(i+6));
			
			strCurColl = WI.getStrValue((String)vRows.elementAt(i+2),"0");
		  strCurDept = WI.getStrValue((String)vRows.elementAt(i+3),"");
			//System.out.println("strCurColl ---- " + (String)vRows.elementAt(i+62));
			//System.out.println("strCurDept ---- " + (String)vRows.elementAt(i+63));			
			
			if(i+iFieldCount+1 < vRows.size()){
				strNextColl = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 2),"0");		
				strNextDept = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 3),"");		
					
				if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
					//bolNextDept = true;
					bolOfficeTotal = true;
					//System.out.println("coll -- " + (strCurColl).equals(strNextColl));
					//System.out.println("dept -- " + (strCurDept).equals(strNextDept));
				}
				//System.out.println("strNextColl ---- " + (String)vRows.elementAt(i+iFieldCount +62));
				//System.out.println("strNextDept ---- " + (String)vRows.elementAt(i+iFieldCount +63));
			}
			//System.out.println("(String)vRows.elementAt(i+6) ---- " + (String)vRows.elementAt(i+6));

			//System.out.println("bolOfficeTotal - " + bolOfficeTotal);
						
			vEarnings = (Vector)vRows.elementAt(i+53);
			vDeductions = (Vector)vRows.elementAt(i+54);		
			vSalDetail = (Vector)vRows.elementAt(i+55); 
			vOTDetail = (Vector)vRows.elementAt(i+56);
			vEarnDed = (Vector)vRows.elementAt(i+59);
			if(WI.fillTextValue("excludeLoansMisc").length() > 0)
				vDeductions.setElementAt("0",0) ;
			
			dEmpDeduct = 0d;
			dOtherDed = 0d;
			
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			}
			else 
				bolPageBreak = false;			
	  %>
    <tr>
			<%if(WI.fillTextValue("hide_account").length() == 0){ 
				// Account number
				strTemp = null;
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp = (String)vSalDetail.elementAt(1);
			%>		
      <td class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td> 			
			<%}%>
      <%
				// DEPT NAME
				if(strDeptName == null || !strDeptName.equals((String)vRows.elementAt(i + 63))){
					strTemp = (String)vRows.elementAt(i + 63);
					strDeptName = strTemp;
				}else{
					strTemp = "&nbsp;";
				}					
			%>
			<td class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td height="19" class="BOTTOMLEFT"><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong></td>
			<%if(WI.fillTextValue("salary_base").equals("1") || WI.fillTextValue("salary_base").equals("2")){%>
      <%
				//rate per hour
				strTemp2 = "";
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp2 = (String)vSalDetail.elementAt(6); 			
				
				if(strTemp2.equals("1")){
					strTemp = (String)vSalDetail.elementAt(2); 			
				}else if(strTemp2.equals("2")){
					strTemp = (String)vSalDetail.elementAt(5); 								
				}else{
					strTemp = "";
				}
								
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dLineTotal = dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=strTemp%></td>
      <%
				// days worked
				//strTemp = (String)vRows.elementAt(i + 16);
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp2 = (String)vSalDetail.elementAt(6); 	
							
				if(strTemp2.equals("1")){
					strTemp = (String)vRows.elementAt(i + 20);
				}else if(strTemp2.equals("2")){
					strTemp = (String)vRows.elementAt(i + 8); 			
				}else{
					strTemp = "";
				}
								
				dDaysWorked= Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				if(dDaysWorked== 0d)
					strTemp = "--";
			%>			
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp, false),"")%></td>
			<%}%>
      <%
				// basic salary
				if(WI.fillTextValue("salary_base").equals("0"))
					dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));
				else
					dLineTotal = dDaysWorked * dTemp;
					
				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
				dTotalBasic += dLineTotal;
			%>		     
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
      <%if(abolShowCol[0]){
				// adjustment amount
				strTemp = (String)vRows.elementAt(i + 51); 	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp ,true);
				dLineTotal += dTemp;
				dTotalAdjust += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>		     
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
			<%}%>
		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dLineTotal += dTemp;
 			adDeptEarningTotal[iCols-2] = adDeptEarningTotal[iCols-2] + dTemp;
			if(strTemp.equals("0"))
				strTemp = "";			
		%>          
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
			<%}%>	  
      <%if(abolShowCol[1]){
				// ot  amount
				strTemp = (String)vRows.elementAt(i + 23);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dLineTotal += dTemp;		
				dTotalOver += dTemp;		
			%>      
			<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%}%>
			<%
				// COLA
				strTemp = (String)vRows.elementAt(i + 25);  	
				dCOLA = Double.parseDouble(WI.getStrValue(strTemp,"0"));						
			if(WI.fillTextValue("exclude_cola").length() == 0){			
				dLineTotal += dCOLA;
				dTotalCOLA += dCOLA;
			%>
			<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dCOLA,true)%>&nbsp;</td>
			<%}%>
      <%
			if(abolShowCol[2]){
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
		// night differential amount
		strTemp = (String)vRows.elementAt(i + 24);  	
		//strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
		dOtherEarn += dTemp;
		
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
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				adDeptEarnDedTotal[iCols-1] = adDeptEarnDedTotal[iCols-1] + dTemp;	
				if(strTemp.equals("0"))
					strTemp = "";			
			%>			
      <td width="7%" align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
			<%}%>
      <%
				dLineTotal += dLineOver;
				dTotalGross += dLineTotal;
			%>
      <td align="right" class="BOTTOMLEFTbold"><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
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
				dEmpDeduct += dTemp;
				dTotalLateUT += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>				
      <td align="right" class="BOTTOMLEFTbold"><%=CommonUtil.formatFloat(dTemp,true)%></td>
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
      <td height="19" align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
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
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
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
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%}%>

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
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols ++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				adDeptDeductTotal[iCols-1] = adDeptDeductTotal[iCols-1] + dTemp;	
				dEmpDeduct += dTemp;

				if(dTemp == 0d)
					strTemp = "";			
			%>  			
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%}%>
      <%
			if(abolShowCol[3]){
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
			<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dOtherDed,true)%></td>
			<%}%>
			<td align="right" class="BOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dEmpDeduct,true)%></td>
			<%
				dNetPay = dLineTotal - dEmpDeduct;
				if(WI.fillTextValue("excludeLoansMisc").length() > 0)
					strTemp = CommonUtil.formatFloat(dNetPay,true);
				else
					strTemp = CommonUtil.formatFloat((String)vRows.elementAt(i+52), true);
				
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

				if(WI.fillTextValue("exclude_cola").length() > 0){					
					dTemp = dTemp - dCOLA;
				}				

				dTotalNetPay += dTemp;
			%>
			<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp, true)%></td>				
    </tr>			
		<%  
		if(bolOfficeTotal || (!bolOfficeTotal && (iNumRec + iFieldCount) >= vRows.size())){
  		bolOfficeTotal = false;
 		%>
    <tr>
      <%if(WI.fillTextValue("hide_account").length() == 0){%>
			<td class="BOTTOMLEFT">&nbsp;</td>			
			<%}%>
			<td class="BOTTOMLEFT"><strong>TOTAL</strong></td>
      <td height="19" class="BOTTOMLEFT">&nbsp;</td>
      <%if(WI.fillTextValue("salary_base").equals("1") || WI.fillTextValue("salary_base").equals("2")){%>
			<td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dTotalBasic,true)%></strong></td>
      <%if(abolShowCol[0]){%>
			<td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dTotalAdjust,true)%></strong></td>
			<%}%>
  		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
				adGEarningTotal[iCols-2] += adDeptEarningTotal[iCols-2];
			%> 
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(adDeptEarningTotal[iCols-2],true)%></strong></td>
      <%}%>
	    <%if(abolShowCol[1]){%>
			<td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dTotalOver,true)%>&nbsp;</strong></td>
			<%}%>
      <%if(WI.fillTextValue("exclude_cola").length() == 0){%>
			<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalCOLA,true)%>&nbsp;</td>
			<%}%>
      <%if(abolShowCol[2]){%>
			<td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dTotalOtherEarn,true)%>&nbsp;</strong></td>
			<%}%>
  		<%for(iCols = 1;iCols <= iEarnDedCount; iCols++){
			adGEarnDedTotal[iCols-1] = adDeptEarnDedTotal[iCols-1];	
			%> 
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(adDeptEarnDedTotal[iCols-1],true)%></strong></td>
      <%}%>
      <td align="right" class="BOTTOMLEFTbold"><strong><%=CommonUtil.formatFloat(dTotalGross,true)%></strong></td>
			<td align="right" class="BOTTOMLEFTbold"><strong><%=CommonUtil.formatFloat(dTotalLateUT,true)%></strong></td>
			<%if(astrContributions[0].equals("1")){%>
      <td height="19" align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dTotalSSS,true)%></strong></td>
			<%}if(astrContributions[1].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dTotalPhealth,true)%></strong></td>
			<%}if(astrContributions[2].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dTotalHdmf,true)%></strong></td>
			<%}%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dTotalTax,true)%></strong></td>
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols++){
				adGDeductTotal[iCols-1] += adDeptDeductTotal[iCols-1];
			%> 
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(adDeptDeductTotal[iCols-1],true)%></strong></td>
			<%}%>
      <%if(abolShowCol[3]){%>
			<td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dTotalOtherDed,true)%></strong></td>
			<%}%>
      <td align="right" class="BOTTOMLEFTRIGHT"><strong><%=CommonUtil.formatFloat(dTotalDeductions ,true)%></strong></td>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dTotalNetPay,true)%></strong></td>			
    </tr>
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
			dGTotalCOLA += dTotalCOLA;
			
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
			
			dTotalBasic = 0d;
			dTotalAdjust  = 0d;
			dHoursOver = 0d;
			dTotalOverLoad = 0d;
			dTotalRegOtHr = 0d;
			dTotalRegOtAmt = 0d;
			dTotalRestOtHr = 0d;
			dTotalRestOtAmt = 0d;
			dTotalNightHrs = 0d;
			dTotalNightDiff = 0d;
			dTotalOver = 0d;
			dTotalCOLA = 0d;
			dTotalOtherEarn = 0d;
			dTotalLateUT = 0d;
			dTotalGross = 0d;
			
			dTotalSSS = 0d;
			dTotalPhealth = 0d;
			dTotalHdmf = 0d;
			dTotalPERAA = 0d;
			dTotalTax = 0d;

			dTotalOtherDed = 0d;
			dTotalDeductions = 0d;
			dTotalNetPay = 0d;
			
			for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
				adDeptEarningTotal[iCols-2] = 0d;	
			}
		
			for(iCols = 1;iCols < iEarnDedCount + 1; iCols++){
				adDeptEarnDedTotal[iCols-1] = 0d;
			}		
			
			for(iCols = 1;iCols < iDedColCount + 1; iCols++){
				adDeptDeductTotal[iCols-1] = 0d;
			}
			
			
			}// end if show office total
		}// end inner for loop. 			
 		%>

		<%if(iNumRec == vRows.size()){%>
    <tr>
      <%if(WI.fillTextValue("hide_account").length() == 0){%>
			<td class="BOTTOMLEFT">&nbsp;</td>			
			<%}%>
			<td class="BOTTOMLEFT">&nbsp;</td>
      <td height="19" class="BOTTOMLEFT">&nbsp;</td>
      <%if(WI.fillTextValue("salary_base").equals("1") || WI.fillTextValue("salary_base").equals("2")){%>
			<td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <%if(abolShowCol[0]){%>
			<td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%> 
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
			<%if(WI.fillTextValue("employee_category").equals("1")){%>
      <%}%>
      <%if(abolShowCol[1]){%>
			<td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
      <%if(WI.fillTextValue("exclude_cola").length() == 0){%>
			<td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
      <%if(abolShowCol[2]){%>
			<td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols++){%> 
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
      <td align="right" class="BOTTOMLEFTbold">&nbsp;</td>
			<td align="right" class="BOTTOMLEFTbold">&nbsp;</td>
			<%if(astrContributions[0].equals("1")){%>
      <td height="19" align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%} if(astrContributions[1].equals("1")){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%} if(astrContributions[2].equals("1")){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols++){%> 
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
      <%if(abolShowCol[3]){%>
			<td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
      <td align="right" class="BOTTOMLEFTRIGHT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>			
    </tr>
    <tr>
      <%if(WI.fillTextValue("hide_account").length() == 0){%>
			<td class="BOTTOMLEFT">&nbsp;</td>			
			<%}%>
			<td class="BOTTOMLEFT"><strong>GRAND TOTAL</strong></td>
      <td height="19" class="BOTTOMLEFT">&nbsp;</td>
      <%if(WI.fillTextValue("salary_base").equals("1") || WI.fillTextValue("salary_base").equals("2")){%>
			<td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalBasic,true)%></strong></td>
      <%if(abolShowCol[0]){%>
			<td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalAdjust,true)%></strong></td>
			<%}%>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%> 
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(adGEarningTotal[iCols-2],true)%></strong></td>
			<%}%>
			<%if(WI.fillTextValue("employee_category").equals("1")){%>
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
	  <!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dGHoursOver,true)%>&nbsp;</td>-->
      <%}%>
	  <%
	  	iRegHourGrand += iRegMinGrand/60;
	  	iRegMinGrand = iRegMinGrand % 60;		
		
		strTemp = Integer.toString(iRegMinGrand);
		if(strTemp.length() == 1)
		 	strTemp = "0" + strTemp; 
	  %>	  
      <!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalRegOtHr,true)%>&nbsp;</td>-->
	  
	  <%
	  	iRestHourGrand += iRestMinGrand/60;
	  	iRestMinGrand = iRestMinGrand % 60;		
		
		strTemp = Integer.toString(iRestMinGrand);
		if(strTemp.length() == 1)
		 	strTemp = "0" + strTemp; 
	  %>	  
      <!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalRestOtHr,true)%>&nbsp;</td>-->
		  <%if(abolShowCol[1]){%>
			<td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalOver,true)%>&nbsp;</strong></td>
			<%}%>
      <%if(WI.fillTextValue("exclude_cola").length() == 0){%>
			<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalCOLA,true)%>&nbsp;</td>
			<%}%>
      <%if(abolShowCol[2]){%>
			<td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalOtherEarn,true)%></strong></td>
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols++){%> 
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(adGEarnDedTotal[iCols-1],true)%></strong></td>
			<%}%>
      <td align="right" class="BOTTOMLEFTbold"><strong><%=CommonUtil.formatFloat(dGTotalGross,true)%></strong></td>
			<td align="right" class="BOTTOMLEFTbold"><strong><%=CommonUtil.formatFloat(dGTotalLateUT,true)%></strong></td>
			<% if(astrContributions[0].equals("1")){%>
      <td height="19" align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalSSS,true)%></strong></td>
			<%} if(astrContributions[1].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalPhealth,true)%></strong></td>
			<%} if(astrContributions[2].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalHdmf,true)%></strong></td>
			<%}%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalTax,true)%></strong></td>
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols++){%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(adGDeductTotal[iCols-1],true)%></strong></td>
			<%}%>
      <%if(abolShowCol[3]){%>
			<td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalOtherDed,true)%></strong></td>
			<%}%>
      <td align="right" class="BOTTOMLEFTRIGHT"><strong><%=CommonUtil.formatFloat(dGTotalDeductions ,true)%></strong></td>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalNetPay,true)%></strong></td>			
    </tr>
		    
    <%}%>
  </table>	
	<%if(iNumRec == vRows.size()){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="30%">&nbsp;</td>
			<td width="26%">&nbsp;</td>
			<td width="22%">&nbsp;</td>
		  <td width="22%">&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>Prepared by: </td>
			<td>Reviewed by: </td>
		  <td>Noted by: </td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		  <td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><%=WI.fillTextValue("prepared_by")%></td>
			<td><%=WI.fillTextValue("reviewed_by")%></td>
		  <td><%=WI.fillTextValue("noted_by")%></td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	    <td>&nbsp;</td>
		</tr>
	</table>	
	<%}// if(iNumRec == vRows.size()) last page signatories%>
	<%} //end for (iNumRec < vRows.size()
	
  } //end end upper most if (vRows !=null)%>	
	<input type="hidden" name="is_grouped" value="<%=WI.fillTextValue("is_grouped")%>">
	<input type="hidden" name="prepared_by" value="<%=WI.fillTextValue("prepared_by")%>">
	<input type="hidden" name="verified_by" value="<%=WI.fillTextValue("verified_by")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>