<%@ page language="java" import="utility.*, java.sql.ResultSet, java.util.Vector, payroll.ReportPayroll, 
								enrollment.CurriculumCollege,  payroll.PRSalaryExtn, payroll.PRPayslip,
								payroll.PRSalary, payroll.PReDTRME, hr.HRInfoPersonalExtn, 								
								payroll.ReportPayrollExtn, payroll.PRRetirementLoan, payroll.PRFaculty " buffer="24kb"%>

<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Payslip</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborderALL {
		border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
		border-right: solid 1px #000000;
    border-top: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 9px;	
    }

    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }
	
    TD.thinborderNONEcl {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
    }
	
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

	TD.thinborderHeader {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPLEFTRIGHT {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPLEFTBOTTOM {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPRIGHT {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPLEFT {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPBOTTOMRIGHT {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 9px;
    }
	TD.thinborderBOTTOMonly {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
    }

    TD.thinborderBOTTOMRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	
	.main_table TD{
		height:15px;
		font-size:9px;
	}
	.main_table TD.right_value{
		text-align:right;
	}
</style>
</head>
<%


	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strSlash = null;
	String strImgFileExt = null;	
	String strSalIndex = WI.fillTextValue("sal_index");
	String strEmpID = WI.fillTextValue("emp_id");
 	if(WI.fillTextValue("my_home").equals("1")){
		strEmpID = (String)request.getSession(false).getAttribute("userId");		
	}

	String strEmployeeIndex = null;
	boolean bolShowSignature = false;
	boolean bolUsePrePrinted = (WI.fillTextValue("use_preprinted").length() > 0);
	String strBorder = null;
	int iIndexOf = 0;

//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-EmployeePayslip","payroll_slip_print.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		bolShowSignature = (readPropFile.getImageFileExtn("PAYSLIP_SIGNATURES","0")).equals("1");
		
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
int iAccessLevel = 2;

if(!WI.fillTextValue("my_home").equals("1")){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","REPORTS",request.getRemoteAddr(),
														"payroll_slip_print.jsp");
}else{
	strEmployeeIndex = dbOP.mapUIDToUIndex(strEmpID);
 	strTemp = 
		"select is_sal_released from pr_edtr_salary " +
		" join pr_edtr_manual on(pr_edtr_manual.MANUAL_ENCODING_INDEX = pr_edtr_salary.MANUAL_ENCODING_INDEX) " +
		" where sal_period_index = " + WI.getStrValue(WI.fillTextValue("sal_period_index"),"0") + 
		" and pr_edtr_manual.user_index = " + strEmployeeIndex;
 
  strTemp = dbOP.getResultOfAQuery(strTemp,0);
	strTemp = WI.getStrValue(strTemp,"0");	
  if(!strTemp.equals("1") || !WI.fillTextValue("is_printed").equals("1")){
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../../../../ADMIN_STAFF/admin_staff_index.htm");
		request.getSession(false).setAttribute("errorMessage","Payslip not yet finalized by the HR");
 		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;	
	}
	
	strTemp = 
		"select user_index from pr_edtr_salary where salary_index = " + WI.getStrValue(strSalIndex,"0");
  strTemp = dbOP.getResultOfAQuery(strTemp,0);
	strTemp = WI.getStrValue(strTemp,"0");	
	if(!strEmployeeIndex.equals(strTemp)){
			dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../../../../ADMIN_STAFF/admin_staff_index.htm");
		request.getSession(false).setAttribute("errorMessage","Cannot print payslip of another employee from ess");
 		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;	
	}
}
												
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

	Vector vPersonalDetails = new Vector(); 
	Vector vSalaryPeriod 	= null;//detail of salary period.
	Vector vDTRDetails      = null;
	Vector vDTRManual       = null;
	Vector vMiscDeduct  = null;
	Vector vLoansAndAdv     = null;
	Vector vSalIncentives  	= null;	
	Vector vUpdate  	    = null;
	Vector vColleges  	    = null;
	Vector vOtherCons	    = null;
	Vector vPayPerCollege   = null;
	Vector vFacAbsences     = null;
	Vector vYTDInfo = null;
	Vector vTemp 			      = null;
	Vector vVarAllowances   = null;
	Vector vEmpIDs          = null;
	Vector vSalIndex        = null;
	Vector vMiscEarnings    = null;
	Vector vOTEncoding      = null;
	Vector vEmpLoans        = null;
	Vector vPayslipItems    = null;
	Vector vDeductions      = null;
	Vector vEarnings        = null;
	Vector vEarnDed         = null;
	Vector vUnworkedDays    = null;
	Vector vOTWithType = null;
	Vector vOptionalItems   = null;
	
	HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
	PRSalary salary = new PRSalary();
	PRSalaryExtn salaryExtn = new PRSalaryExtn();
	ReportPayroll rptPay = new ReportPayroll(request);
	ReportPayrollExtn rptPayExtn = new ReportPayrollExtn(request);
	CurriculumCollege CC = new CurriculumCollege();	
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	PRPayslip payslip = new PRPayslip();	
	PRFaculty prFac = new PRFaculty();
	String[] astrTaxStatus = {"Z","S","HF","ME"};
	String[] astrGender = {"M","F"};
	double dUnreleasedSalary = 0d;
	int i = 0;
	int iTemp = 0;
	String strPayrollPeriod = null;
	String strCutOff = null;
	String strPeriodEnding = null;

	String strDailyRate = null;
	String strHourlyRate = null;
	String strPayslipUsed = null;
	String strSalaryBase = "0";

	String strSchCode = dbOP.getSchoolIndex();
	strEmployeeIndex = dbOP.mapUIDToUIndex(strEmpID);
	double[] adContributions = new double[6];
 	
	
	double dTaxableIncomeAllowance = 0d;
	double dNonTaxableIncomeAllowance = 0d;
	double dOtherIncomeAllowance = 0d;
	
	
	/*
	 DBTC 
	 AUF
	 PIT
	 
	 Payslip for these schools are in payroll_slip_print_sch.jsp
	 If you want to add other schools in the new page... don't forget to update 
	 regular_pay.jsp and batch_print.jsp	 
	*/
	
if (strEmpID.length() > 0) {
  enrollment.Authentication authentication = new enrollment.Authentication();
  vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
 //System.out.println("\n\ncode: " + vPersonalDetails	);
 	vDTRDetails = salary.getDTRDetails(dbOP,request);
	vDTRManual = salary.operateOnDTRManual(dbOP,request,7);		
	vColleges = CC.viewall(dbOP);
	if(strSchCode.startsWith("UI")){
	  vSalIndex = rptPayExtn.operateOnUnreleasedSalary(dbOP,strEmployeeIndex);
	}
	
	vEmpLoans = PRRetLoan.getEmpLoansWithBalPay(dbOP,request);		
		
	//System.out.println("339 strSalIndex: " + strSalIndex);
	vPayslipItems = rptPayExtn.getPayslipItems(dbOP, strSalIndex);
		
	if(WI.fillTextValue("hide_optional").length() > 0) {
		vOptionalItems = payslip.operateOnOptionalPayslipItems(dbOP,request, 4);
	}
	
	if(vPayslipItems != null){
		vDeductions = (Vector)vPayslipItems.elementAt(0);
 		vEarnings = (Vector)vPayslipItems.elementAt(1);
		vEarnDed = (Vector)vPayslipItems.elementAt(2);
	}
			
	if(vDTRManual != null){
		vMiscDeduct = (Vector)vDTRManual.elementAt(0);
    vLoansAndAdv = (Vector)vDTRManual.elementAt(1);
		vOtherCons = (Vector)vDTRManual.elementAt(42);
		vVarAllowances = (Vector) vDTRManual.elementAt(59);
		vMiscEarnings	= (Vector)vDTRManual.elementAt(62);
		vSalIncentives  = (Vector)vDTRManual.elementAt(63);
		strDailyRate = (String)vDTRManual.elementAt(79);
		strHourlyRate = (String)vDTRManual.elementAt(80);
	}
	if(vDTRDetails != null){
		//vSalIncentives = (Vector)vDTRDetails.elementAt(10);		
		if(strSchCode.startsWith("CLDH"))
			vUnworkedDays = (Vector) vDTRDetails.elementAt(41);
		
		vOTEncoding = (Vector)vDTRDetails.elementAt(68);
		strSalaryBase = (String)vDTRDetails.elementAt(70);
		vOTWithType = (Vector)vDTRDetails.elementAt(76);
		
		if(strDailyRate == null || strDailyRate.length() == 0)
			strDailyRate = (String)vDTRDetails.elementAt(18);
		
		if(strHourlyRate == null || strHourlyRate.length() == 0){
			strHourlyRate = (String)vDTRDetails.elementAt(19);
			strHourlyRate = ConversionTable.replaceString(strHourlyRate,",","");
		}
	}
	
	vPayPerCollege = prFac.getPayPerCollege(dbOP,strSalIndex);
	vEmpIDs = salaryExtn.getEmpContributionIDs(dbOP, strEmployeeIndex);
	
	strPayslipUsed = payslip.operateOnPayslipUse(dbOP, 4, request);
	strPayslipUsed = WI.getStrValue(strPayslipUsed);
}

if(WI.fillTextValue("finalize").length() > 0){
  if(!payslip.FinalizeSalary(dbOP,request,strSalIndex)){
		strErrMsg = "Error";
  }	

  // this is for the unreleased salary
  if(vSalIndex != null && vSalIndex.size() > 0){
    for(i = 1;i < vSalIndex.size(); i++){	
      if(!payslip.FinalizeSalary(dbOP,request,(String)vSalIndex.elementAt(i), strSalIndex)){
	    strErrMsg = "Error";
	  }	
	}
	strTemp = (String)vSalIndex.elementAt(0);
	dUnreleasedSalary = Double.parseDouble(strTemp);
  }
}

if(WI.fillTextValue("sal_period_index").length() > 0) {			
	vSalaryPeriod = rptPay.getSalaryPeriodRange(dbOP);
	strTemp = WI.fillTextValue("sal_period_index");					
	if (vSalaryPeriod!= null && vSalaryPeriod.size() > 0){
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 5) {
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
				 strPayrollPeriod = (String)vSalaryPeriod.elementAt(3) +" - "+(String)vSalaryPeriod.elementAt(4);
				 strCutOff = (String)vSalaryPeriod.elementAt(1) +" - "+(String)vSalaryPeriod.elementAt(2);
				 strPeriodEnding = (String)vSalaryPeriod.elementAt(4);
				 break;
			}
		}		
	}		
}

if (vSalaryPeriod != null && vSalaryPeriod.size() > 0){
	vFacAbsences = prFac.getFacAbsencesPerCollege(dbOP,strEmpID,(String)vSalaryPeriod.elementAt(1),(String)vSalaryPeriod.elementAt(2));
}

double dSubGross = 0d;
double dGrossSalary = 0d;
double dSubTotalDed = 0d;
double dTotalDeduction = 0d;
double dOtherDeduction  = 0d;
double dNetSalary = 0d;
double dTemp = 0d;
double dTempTotal = 0d;
double dTempSalary = 0d;
double dAbsenceAmt = 0d;
double dLateUtAmt = 0d;
double dOtherEarning = 0d;
double dHonorarium = 0d;
String[] astrPtFt = {"Part-Time","Full-Time",""};
String strGrossPayTotal = null;
String strPtFt = WI.fillTextValue("pt_ft");
//if (strSchCode.startsWith("CPU")){
//strGrossPayTotal = dbOP.mapOneToOther("pr_edtr_salary","is_valid","1", "sum(gross_salary)",
//						  " and user_index = " + strEmployeeIndex);
//}


//additional code in order to make mapping of taxable and non taxable easier. sul01222013
Vector vAllowanceDetails = salaryExtn.getPaySlipItems(dbOP, strSalIndex, WI.fillTextValue("sal_period_index") ,strEmployeeIndex);
//System.out.println("452 vAllowanceDetails: " + vAllowanceDetails);
//end of add code

strSlash = "";
if (strPtFt.length() == 0){
	strPtFt = dbOP.mapOneToOther("info_faculty_basic","is_valid","1", "pt_ft",
						  " and user_index = " + strEmployeeIndex);
	strPtFt = WI.getStrValue(strPtFt,"1");
}
%>
<body <%if(WI.fillTextValue("skip_print").length() == 0){%>onLoad="javascript:window.print()"<%}%>>
<form>


<!-- header -->
<table width="100%" cellpadding="0" border="0">
  <tr>
    <td width="84%" style="font-size:15px"><strong><%=(SchoolInformation.getSchoolName(dbOP,true,false)).toUpperCase()%></strong> </td>
    <td width="16%"><div style="width:145px;" align="center">
      <label style="font-size:20px;font-weight:bolder; font-family:Arial, Helvetica, sans-serif; letter-spacing:6px">PAY SLIP</label>
      <br/>
      <label style="font-size:11px;font-weight:bolder;font-family: Arial, Helvetica, sans-serif;">STRICTLY CONFIDENTIAL</label>
    </div></td>
  </tr>
</table>
<!-- end of header  -->


<div style="border:#000000 solid 1px; padding:3px" >
<table width="100%" cellpadding="0" border="0" class="main_table"><!-- main table-->
	<tr>
		<!------------------  start of COL1 ----------------->
		<td width="25%">			
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td width="72%">Basic Salary</td>	
					<td width="28%" class="right_value">
						<% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							strTemp = (String)vDTRManual.elementAt(38);			
							dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}
						%>
				  <%=WI.getStrValue(strTemp,"0")%>&nbsp;					</td>				
				</tr>
				<tr>
					<td>Adjustments</td>	
					<td class="right_value">
					<%
						///////////////////// absent , late , ut \\\\\\\\\\\\\\\\\\\		
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							// leave without pay			
							strTemp = (String) vDTRManual.elementAt(11);
							dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							// AWOL
							strTemp = (String) vDTRManual.elementAt(32);
							dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						
							// faculty absences
							strTemp = (String) vDTRManual.elementAt(45);
							dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
							if(dAbsenceAmt > 0)
								strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);
							else
								strTemp = "0.00";
								
							// Lates and undertimes
							strTemp = (String) vDTRManual.elementAt(33);
							dLateUtAmt = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));		
						}
						dGrossSalary -= (dAbsenceAmt+dLateUtAmt);
						///////////// end absent late ut \\\\\\\\\\\\\	
					%>	
						(<%=WI.getStrValue(CommonUtil.formatFloat(dAbsenceAmt+dLateUtAmt,true),"0")%>)&nbsp;					</td>				
				</tr>
				<tr>
					<td>Overtime</td>	
				  	<td class="right_value">
						<% dTemp = 0d;
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							// OT amount
							strTemp = (String) vDTRManual.elementAt(10);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
														
							// night diff
							strTemp = (String) vDTRManual.elementAt(25);
							dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							dGrossSalary += dTemp; 							
						}						
						%><%=WI.getStrValue(CommonUtil.formatFloat(dTemp,true),"0.00")%>&nbsp;					</td>				
				</tr>
				
				<!-- other income  -->
				<%
					if(bolIsSchool){
						dTemp = 0d;
						if (vDTRManual != null && vDTRManual.size() > 0){
							// faculty pay
							strTemp = (String) vDTRManual.elementAt(44);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

							// sub teaching salary
							strTemp = (String) vDTRManual.elementAt(60);							
							dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
 							dGrossSalary += dTemp;
						}//end of vDTRManual
						if(dTemp > 0d){
						 %>		
						<tr>
							<td>Sub Teaching</td>	
						  <td class="right_value"><%=WI.getStrValue(CommonUtil.formatFloat(dTemp,true),"")%><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>				
						</tr>						
						<%}//end of if dTemp
					}//end is school
					
					
					if (vDTRManual != null && vDTRManual.size() > 0){
						// additional bonuses
						strTemp = (String) vDTRManual.elementAt(22);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						if(dTemp > 0d){%>						
					<tr>
						<td><%=WI.getStrValue((String) vDTRManual.elementAt(23))%></td>	
						<td class="right_value">
							 <% 
								strTemp = CommonUtil.formatFloat(dTemp,true);
								dGrossSalary += dTemp; 
								if(dTemp == 0d)
									strTemp = "";				
 						    %>
           					<%=WI.getStrValue(strTemp,"")%>&nbsp;						</td>				
					</tr>					
						<%}//end of dtemp
					}//end of dtrmanual	
					%>					
					<!-- taxable earnings/income  -->
					 <%						
						dOtherEarning = 0d;
						for(i = 1; i < vEarnings.size(); i += 2) {
							strTemp = (String) vEarnings.elementAt(i+1);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			

							strTemp = (String) vEarnings.elementAt(i);
							if(strTemp == null || strTemp.length() == 0){
								dOtherEarning += dTemp;
								dOtherIncomeAllowance += dTemp;
								continue;
							}
							if(strTemp.startsWith("Taxable") || strTemp.startsWith("TAXABLE")){
								dTaxableIncomeAllowance += dTemp;
								dGrossSalary += dTemp;
							}else
								dNonTaxableIncomeAllowance += dTemp;							
						}// END FOR LOOP %>	
					<tr>
						<td>Other Taxable Inc</td>	
						<td class="right_value"><%=CommonUtil.formatFloat(dTaxableIncomeAllowance,true)%>&nbsp;</td>				
					</tr>					
					<!-- end of taxable income -->					
				<tr>
					<td>Holiday Pay</td>	
					<td class="right_value">
						 <% dTemp = 0d;
								if (vDTRManual != null && vDTRManual.size() > 0){ 
									// holiday pay
									strTemp = (String) vDTRManual.elementAt(26);
									dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
									dGrossSalary += dTemp;
								}	
							%>						
		                <%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;					</td>				
				</tr>
				<tr>
					<td>Gross Taxable</td>	
					<td class="right_value" style="border-top:#000000 solid 1px"><%=CommonUtil.formatFloat(dGrossSalary,true)%>&nbsp;</td>				
				</tr>				
				<tr>
					<td>Less: W/H Tax</td>	
					<% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							// tax
							strTemp = (String) vDTRManual.elementAt(24);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							dTotalDeduction += dTemp;							
						}	
					%>
					<td class="right_value"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>				
				</tr>
								
				<tr>
					<td>Gross After Tax</td>	
					<% dGrossSalary -= dTemp; %>
					<td class="right_value" style="border-top:#000000 solid 1px"><%=CommonUtil.formatFloat(dGrossSalary,true)%>&nbsp;</td>				
				</tr>
				<tr>
					<td colspan="2">Less: </td>	
				</tr>
				
				<tr>
					 <% 
					dTotalDeduction = 0; 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						// SSS
						strTemp = (String) vDTRManual.elementAt(12);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dTotalDeduction += dTemp; 
					}	
					 %>
					<td>&nbsp;&nbsp;&nbsp;SSS Premium</td>	
					<td class="right_value"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>				
				</tr>
				<tr>
					<td>&nbsp;&nbsp;&nbsp;PhilHealth </td>	
					<td class="right_value">
					<% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						// PHEAlth
						strTemp = (String) vDTRManual.elementAt(13);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dTotalDeduction += dTemp; 
					}	
					 %>					
					<%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>				
				</tr>
				<tr>
					<td>&nbsp;&nbsp;&nbsp;Pag-ibig </td>
					<% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
					// pag ibig
						strTemp = (String) vDTRManual.elementAt(14);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dTotalDeduction += dTemp; 
						if(dTemp == 0d)
							strTemp = "";
					}	
					 %>	
					<td class="right_value"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>				
				</tr>
				  <!--  Start of addition to enable viewing of PERAA sul09082012 --->
				<%if(bolIsSchool){
					//get the setting if allowed to show peraa on payslip
					 ReadPropertyFile readPropFile = new ReadPropertyFile();
					 boolean bolShowPERAA = (readPropFile.getImageFileExtn("HAS_PERAA","0")).equals("1");// == 1 show peraa
					 
					dTemp = 0;
					if (vDTRManual != null && vDTRManual.size() > 0 && bolShowPERAA){ 
						  //peraa
							strTemp = (String) vDTRManual.elementAt(54);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = CommonUtil.formatFloat(strTemp,true);
							dTotalDeduction += dTemp; 
							if(dTemp == 0d)
								strTemp = "";
					}				
					if(dTemp > 0){	
				%>
				  <tr>				
					 <td>&nbsp;&nbsp;&nbsp;PERAA</td>
					 <td align="right"> 
					 <strong><%=WI.getStrValue(strTemp,"")%></strong>&nbsp;</td>
				</tr> 
				<%} }//end of if school and peraa is not 0(if(dTemp > 0)) %>
			  <!--  end of PERAA Viewing -->
				
					<% 										
						if(vDeductions != null && vDeductions.size() > 1){
							dOtherDeduction = 0d;						
							for(i = 1; i < vDeductions.size(); i += 2) {
								strTemp = (String) vDeductions.elementAt(i+1);
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
	
								strTemp = (String) vDeductions.elementAt(i);
								if(strTemp == null || strTemp.length() == 0){
									dOtherDeduction += dTemp;									
									continue;
								}
								dTotalDeduction += dTemp; 
							if(dTemp > 0){	
							%>
							  <tr> 
								<td>&nbsp;&nbsp;&nbsp;<%=strTemp%></td>
								<td align="right">
								<% 
								strTemp = CommonUtil.formatFloat(dTemp,true);							
									if(dTemp == 0d)
										strTemp = "";				
									%> 
								<%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
					 		 </tr>
						<%}//end of dTemp > 0
						}// END FOR LOOP
					}// END NULL CHECK %>
				<tr>
					<td>&nbsp;&nbsp;&nbsp;Other Ded</td>
					<% 
					//dOtherDeduction = 0;
					if (vDTRManual != null && vDTRManual.size() > 0){ 	
						strTemp = (String) vDTRManual.elementAt(18);//MISC_DEDUCTION (Addl ded)
						dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					}						
						dTotalDeduction += dOtherDeduction; 
				%>
						
					<td class="right_value"><%=CommonUtil.formatFloat(dOtherDeduction,true)%>&nbsp;</td>				
				</tr>	
				
				<tr>
					<td colspan="2">Add: </td>	
				</tr>
				<tr>
					<td>&nbsp;&nbsp;&nbsp;Non Taxable Inc</td>	
					<td class="right_value"><%=CommonUtil.formatFloat(dNonTaxableIncomeAllowance,true)%>&nbsp;</td>				
				</tr>
				<tr>
					<td style="font-size:12px;"><strong>Net Pay</strong></td>	
					<td class="right_value" style="border-top:#000000 solid 1px; font-size:12px; padding:5px"><strong><%=CommonUtil.formatFloat((dGrossSalary + dNonTaxableIncomeAllowance)-dTotalDeduction,true)%></strong>&nbsp;</td>				
				</tr>				
				<tr>
					<td>TAX STATUS</td>
					<%
					if (vDTRDetails != null && vDTRDetails.size() > 0){
						strTemp = (String)vDTRDetails.elementAt(36);
						iTemp  = Integer.parseInt(WI.getStrValue(strTemp,"0"));
						strTemp2 = (String)vDTRDetails.elementAt(37);
						if(WI.getStrValue(strTemp2,"0").equals("0"))
							strTemp2 = "";
						}
					%>
					<td align="left"><%=astrTaxStatus[iTemp]%></td>				
				</tr>
			</table>
		</td>
		<!------------------  end of COL1 ----------------->

		<td width="1%" class="thinborderLEFT"><!-- dummy column for v line -->
&nbsp;		</td>
		
		<!------------------  start of COL2 ----------------->
		<td width="22%" valign="top">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td colspan="2"><strong>Misc. Salary Adjustments</strong></td>			
				</tr>
				<tr>
					<td width="67%">&nbsp;&nbsp;&nbsp;Absent</td>	
					<td width="33%" align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dAbsenceAmt,true),"0")%>&nbsp;</td>				
				</tr>
				<tr>
					<td>&nbsp;&nbsp;&nbsp;Tardy</td>					
					<td align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dLateUtAmt,true),"0")%>&nbsp;</td>	
				</tr>
				<tr>		
					<td>&nbsp;</td>			
					<td align="right" style="border-top:#000000 solid 1px"><%=WI.getStrValue(CommonUtil.formatFloat(dAbsenceAmt + dLateUtAmt ,true),"0")%>&nbsp;</td>	
				</tr>		
					
					
					
				<tr>
					<td colspan="2"><strong>Other Tax Income Detail</strong></td>			
				</tr>	
				<%
					strTemp = "0.00";
					if(vAllowanceDetails != null && vAllowanceDetails.size() > 0 ) { 
						vTemp = (Vector)vAllowanceDetails.elementAt(0);	
						if(vTemp != null && vTemp.size() > 0 ) { 
							strTemp = CommonUtil.formatFloat(WI.getStrValue((String)vAllowanceDetails.elementAt(2),"0"),true);//get the toatal					
							for(i = 0 ; i < vTemp.size(); i+=2 ){	%>					
								<tr>
									<td>&nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vTemp.elementAt(i),"&nbsp;")%></td>					
									<td align="right"><%=CommonUtil.formatFloat(WI.getStrValue((String)vTemp.elementAt(i+1),"0"),true)%>&nbsp;</td>	
								</tr>
							<%}//end of for loop
						}//end of vTemp	
					}//end of vAllowance
				%>				
				<tr>		
					<td>&nbsp;</td>			
					<td align="right" style="border-top:#000000 solid 1px"><%=strTemp%>&nbsp;</td>	
				</tr>							
				
				
				<tr>
					<td colspan="2"><strong>Other Deduction/(Addition)</strong></td>			
				</tr>
				<%
					dTotalDeduction = 0d;
					dOtherDeduction = 0d;
					if(vDeductions != null && vDeductions.size() > 1){						
						for(i = 1; i < vDeductions.size(); i += 2) {
							strTemp = (String) vDeductions.elementAt(i+1);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = (String) vDeductions.elementAt(i);
							if(strTemp == null || strTemp.length() == 0){
								dOtherDeduction += dTemp;
								continue;
							}
							dTotalDeduction += dTemp;
						%>
				 <tr>
				   <td >&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strTemp,"")%></td>
				   <td align="right">
				  	<% 	
						strTemp = CommonUtil.formatFloat(dTemp,true);
						if(dTemp == 0d)
							strTemp = "";				
					%>
					   <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
				 </tr>
				 <%}// end for loop
				}// end null check%>	
				
				<tr>
					<td>&nbsp;&nbsp;&nbsp;Others</td>
						<% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 	
							strTemp = (String) vDTRManual.elementAt(18);//MISC_DEDUCTION (Addl ded)
							dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
						}
							strTemp = CommonUtil.formatFloat(dOtherDeduction,2);
							dTotalDeduction += dOtherDeduction; 
							if(dOtherDeduction == 0d)
								strTemp = "0.00";
						%>
             <td align="right"><%=WI.getStrValue(strTemp,"0.00")%>&nbsp;</td>
           </tr>	
		   <tr>		
				<td>&nbsp;</td>			
				<td align="right" style="border-top:#000000 solid 1px"><%=CommonUtil.formatFloat(dTotalDeduction,true)%>&nbsp;</td>	
			</tr>
			</table>
		</td>
		<!------------------  end of COL2 ----------------->
		<td width="1%"><!-- dummy column for space -->
&nbsp;		</td>
		<!------------------  start of COL3 ----------------->
		<td width="26%" valign="top">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
		
			<tr>
					<td colspan="2"><strong>Non Taxable Income/(Payments)</strong></td>			
			  </tr>	
				<%	strTemp = "0.00";
					if(vAllowanceDetails != null && vAllowanceDetails.size() > 0 ) { 
						vTemp = (Vector)vAllowanceDetails.elementAt(1);	
						if(vTemp != null && vTemp.size() > 0 ) { 	
							strTemp = CommonUtil.formatFloat(WI.getStrValue((String)vAllowanceDetails.elementAt(3),"0"),true);//get the toatal									
							for(i = 0 ; i < vTemp.size(); i+=2 ){	%>					
								<tr>
									<td>&nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vTemp.elementAt(i),"&nbsp;")%></td>					
									<td align="right"><%=CommonUtil.formatFloat(WI.getStrValue((String)vTemp.elementAt(i+1),"0"),true)%>&nbsp;</td>	
								</tr>
							<%}//end of for loop
						}//end of vTemp	
					}//end of vAllowance
				%>				
				<tr>		
					<td>&nbsp;</td>			
					<td align="right" style="border-top:#000000 solid 1px"><%=strTemp%>&nbsp;</td>	
				</tr>		
				
				
				<!-- OT and NDF  -->
				<tr>		
					<td colspan="2">&nbsp;</td>
				</tr>	
				<tr>
					<td><strong>Night Differential</strong></td>
					<td align="right">
						<% 
						dTemp = 0d;
						if (vDTRManual != null && vDTRManual.size() >  0){ 	
							strTemp = (String) vDTRManual.elementAt(25);// night differential
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						}		
						dTempTotal = dTemp;				
						%>
						<%=CommonUtil.formatFloat(dTemp,true)%>
					</td>			
			  	</tr>
				
				<tr>
					<td colspan="2"><strong>Overtime</strong></td>			
			  	</tr>					
				
				<tr>
					<td colspan="2">
						<%if(vOTWithType != null && vOTWithType.size() > 0){  %>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
						  <tr>
							<td width="44%">&nbsp;</td>
							<td align="right" width="22%"><font size="1">HRS</font></td>
							<td align="right" width="34%"><font size="1">Amount</font></td>
						  </tr>
									<%									
									for(i = 1; i < vOTWithType.size(); i+=20){						
										strTemp = (String)vOTWithType.elementAt(i+5);
										strTemp = ConversionTable.replaceString(strTemp, ",","");
										dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
										if(dTemp > 0){
											dTempTotal += dTemp;
									%>
						  <tr>
									<%
										strTemp = (String)vOTWithType.elementAt(i+9);
									%>
							<td height="20" class="thinborderNONE">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strTemp)%></td>
									<%
										strTemp = (String)vOTWithType.elementAt(i+6);
									%>
							<td align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%></font></td>
										<%
										strTemp = (String)vOTWithType.elementAt(i+5);					
										%>						
							<td align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"0")%>&nbsp;</font></td>
						  </tr>
										<%}
										}%>
					  </table>
					<%}// end vOTEncoding%>						
					</td>
				</tr>
				<tr>		
					<td>&nbsp;</td>			
					<td align="right" style="border-top:#000000 solid 1px"><%=CommonUtil.formatFloat(dTempTotal,true)%>&nbsp;</td>	
				</tr>
				
				<!-- end of ot and ndf -->
					
			</table>
		</td>
		<!------------------  end of COL3 ----------------->
		<td width="1%" ><!-- dummy column for space -->
&nbsp;		</td>
		<!------------------  start of COL4 ----------------->
		<td width="24%" valign="top">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td colspan="2"><strong>Year to Date Summaries</strong></td>			
				</tr>	
				<tr>
					<%
						strTemp2 = null;
						strTemp = null;
						if(vAllowanceDetails != null && vAllowanceDetails.size() > 0 ) {
							strTemp = (String) vAllowanceDetails.elementAt(4);
							strTemp2 = (String) vAllowanceDetails.elementAt(5);
						}
					%>
					<td width="67%">&nbsp;&nbsp;&nbsp;Ytd W/H Tax</td>	
					<td width="33%" align="right"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"0.00")%>&nbsp;</td>				
				</tr>
				<tr>
					<td width="67%">&nbsp;&nbsp;&nbsp;Ytd Taxable Inc</td>	
					<td width="33%" align="right"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp2,true),"0.00")%>&nbsp;</td>				
				</tr>
				
				<tr>		
					<td colspan="2">&nbsp;</td>
				</tr>
				<!-- loan -->
				<%				
				if(vEmpLoans != null && vEmpLoans.size() > 0){%>
				
					<tr>
						<td colspan="2">						
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td colspan="2" class="thinborderNONE"><strong>Loan Details</strong></td>
								<td width="19%">&nbsp;</td>
								<!--<td width="21%">&nbsp;</td>-->
								<td width="17%">&nbsp;</td>
							</tr>
							<tr>
								<td width="24%" class="thinborderNONE">&nbsp;</td>
								<td width="19%" align="center" class="thinborderNONE">Loan</td>
								<td align="center" class="thinborderNONE">Payments</td>
								<!--<td align="center" class="thinborderNONE">Pay Period Ded.</td>-->
								<td align="center" class="thinborderNONE">Balance</td>
							</tr>
							<% dTempTotal = 0d;
							for(i = 0;i < vEmpLoans.size();i+=9){%>
							<tr>
								<%
									strTemp = (String)vEmpLoans.elementAt(i+7);
								%>
								<td class="thinborderNONE" height="15">&nbsp;<%=strTemp%></td>
								<%
									strTemp = (String)vEmpLoans.elementAt(i+3);
								%>					
								<td align="right" class="thinborderNONEcl"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
								<%
									strTemp = (String)vEmpLoans.elementAt(i+5);
									dTempTotal += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
								%>					
								<td align="right" class="thinborderNONEcl"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
								<%
									strTemp = (String)vEmpLoans.elementAt(i+8);
								%>					
								<!--<td align="right" class="thinborderNONEcl"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>-->
								<%
									strTemp = (String)vEmpLoans.elementAt(i+4);
								%>										
								<td align="right" class="thinborderNONEcl"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
							</tr>
							<%}//end of for loop%>
							<tr>
								<td colspan="2" class="thinborderNONE">&nbsp;</td>
								<td width="19%" class="thinborderTOP"><%=CommonUtil.formatFloat(dTempTotal,true)%></td>
								<!--<td width="21%">&nbsp;</td>-->
								<td width="17%">&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<%}//end of if nuot null %>			
				
				
				
				<!--  end of loan -->
		  </table>
		</td>
		<!------------------  end of COL4 ----------------->
	</tr>
</table><!-- end of main table -->
</div>

<!-- Employee Info -->
<table width="100%" cellpadding="0" border="0">
  <tr>
    <td width="83%">
		<table width="100%" cellpadding="2" cellspacing="0" border="0">
			<tr>
				<td width="20%" class="thinborderTOPLEFT"><strong>ID NO</strong></td>
				<td width="80%" class="thinborderTOPRIGHT"><strong>NAME</strong></td>
			</tr>	
			<tr>
				<td width="20%" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strEmpID,"")%></td>
				<td width="80%" class="thinborderBOTTOMRIGHT"><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4).toUpperCase()%></td>
			</tr>			
			<tr>
				<td colspan="2" class="thinborderLEFTRIGHT"><strong>UNIT</strong></td>				
			</tr>	
			<tr>
				<td colspan="2" class="thinborderBOTTOMLEFTRIGHT" ><%=WI.getStrValue((String)vPersonalDetails.elementAt(13),"")%>&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(14),"")%></td>				
			</tr>
		</table>
	</td>
    <td width="17%">
		<table width="100%" cellpadding="2" cellspacing="0" border="0" align="center" height="90%">
			<tr>
				<td class="thinborderTOPLEFTRIGHT">&nbsp;</td>				
			</tr>	
			<tr>
				<td class="thinborderLEFTRIGHT"><strong>PAY DATE</strong></td>				
			</tr>
			<tr>
				<td class="thinborderLEFTRIGHT"><%=WI.getStrValue(strCutOff,"&nbsp;")%></td>				
			</tr>
			<tr>
				<td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>				
			</tr>
			
		</table>
	</td>
  </tr>
</table>
<!-- end of emp info-->

<input type="hidden" name="sal_period_index" value="<%=WI.fillTextValue("sal_period_index")%>">
  <input type="hidden" name="sal_index" value="<%=WI.fillTextValue("sal_index")%>">
  <input type="hidden" name="bank_account" value="<%=WI.fillTextValue("bank_account")%>">
  <input type="hidden" name="rec_no" value="<%=WI.fillTextValue("rec_no")%>">
  <input type="hidden" name="pt_ft" value="<%=WI.fillTextValue("pt_ft")%>">
  <input type="hidden" name="is_atm" value="<%=WI.fillTextValue("is_atm")%>">
  <input type="hidden" name="tenure" value="<%=WI.fillTextValue("tenure")%>">  
  <input type="hidden" name="finalize" value="<%=WI.fillTextValue("finalize")%>">  
  <input type="hidden" name="salary_period" value="<%=WI.fillTextValue("salary_period")%>">  	
  <input type="hidden" name="month_of" value="<%=WI.fillTextValue("month_of")%>">  	
  <input type="hidden" name="year_of" value="<%=WI.fillTextValue("year_of")%>">  	
	<input type="hidden" name="skip_print" value="<%=WI.fillTextValue("skip_print")%>">  	
</form>

<script src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//get this from common.js
<%//if(WI.fillTextValue("skip_print").length() == 0){%>
	//this.autoPrint();
	<%//if(!WI.fillTextValue("my_home").equals("1")){%>
//	window.setInterval("javascript:window.close();",0);
	<%//}%>
//	this.closeWnd = 1;
<%//}%>
//alert("closeWnd -" + closeWnd);
//or use this so that the window will not close
//window.setInterval("javascript:window.print();",0);
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>