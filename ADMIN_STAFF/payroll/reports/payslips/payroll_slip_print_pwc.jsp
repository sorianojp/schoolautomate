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
								"Admin/staff-Payroll-REPORTS-EmployeePayslip","payroll_slip_print_pwc.jsp");
								
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
														"payroll_slip_print_pwc.jsp");
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