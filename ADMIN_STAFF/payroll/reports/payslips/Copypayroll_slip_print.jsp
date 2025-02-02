<%@ page language="java" import="utility.*, java.util.Vector, payroll.ReportPayroll, payroll.PRSalary, 
								payroll.PReDTRME, hr.HRInfoPersonalExtn,enrollment.CurriculumCollege, 
								payroll.PRSalaryExtn, payroll.ReportPayrollExtn, payroll.PRRetirementLoan, 
								payroll.PRPayslip" %>

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
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }
	
    TD.thinborderNONEcl {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
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

//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-EmployeePayslip","payroll_slip_print.jsp");
								
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

	Vector vSalaryPeriod 	= null;//detail of salary period.
	Vector vPersonalDetails = new Vector(); 
	Vector vDTRDetails      = null;
	Vector vDTRManual       = null;
	Vector vMiscDeductions  = null;
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
	
	HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
	PRSalary salary = new PRSalary();
	PRSalaryExtn salaryExtn = new PRSalaryExtn();
	ReportPayroll rptPay = new ReportPayroll(request);
	ReportPayrollExtn rptPayExtn = new ReportPayrollExtn(request);
	CurriculumCollege CC = new CurriculumCollege();	
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	PRPayslip payslip = new PRPayslip();
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
	String strPayslipUsed = "3";

	String strSchCode = dbOP.getSchoolIndex();	
	strEmployeeIndex = dbOP.mapUIDToUIndex(strEmpID);
	
if (strEmpID.length() > 0) {
  enrollment.Authentication authentication = new enrollment.Authentication();
  vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");	
	vDTRDetails = salary.getDTRDetails(dbOP,request);
	vDTRManual = salary.operateOnDTRManual(dbOP,request,7);		
	vColleges = CC.viewall(dbOP);
	if(strSchCode.startsWith("UI")){
	  vSalIndex = rptPayExtn.operateOnUnreleasedSalary(dbOP,strEmployeeIndex);
	}

	if(strSchCode.startsWith("CLDH")){
		vEmpLoans = PRRetLoan.getEmpLoansWithBalPay(dbOP,request);			
		vYTDInfo = rptPayExtn.getYTDInfo(dbOP,strEmployeeIndex);
	}
	
	vPayslipItems = rptPayExtn.getPayslipItems(dbOP, strSalIndex);
	if(vPayslipItems != null){
		vDeductions = (Vector)vPayslipItems.elementAt(0);
		vEarnings = (Vector)vPayslipItems.elementAt(1);
		vEarnDed = (Vector)vPayslipItems.elementAt(2);
	}
	
	if(vDTRManual != null){
		vMiscDeductions = (Vector)vDTRManual.elementAt(0);
    vLoansAndAdv = (Vector)vDTRManual.elementAt(1);
		vOtherCons = (Vector)vDTRManual.elementAt(42);
		vVarAllowances = (Vector) vDTRManual.elementAt(59);
		vMiscEarnings	= (Vector)vDTRManual.elementAt(62);
	}
	if(vDTRDetails != null){
		vSalIncentives = (Vector)vDTRDetails.elementAt(10);
		vOTEncoding = (Vector)vDTRDetails.elementAt(68);
		vUnworkedDays = (Vector) vDTRDetails.elementAt(41);
	}	
	vPayPerCollege = salary.getPayPerCollege(dbOP,strSalIndex);
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
	vFacAbsences = salary.getFacAbsencesPerCollege(dbOP,strEmpID,(String)vSalaryPeriod.elementAt(1),(String)vSalaryPeriod.elementAt(2));
}

double dSubGross = 0d;
double dGrossSalary = 0d;
double dSubTotalDed = 0d;
double dTotalDeduction = 0d;
double dOtherDeduction  = 0d;
double dNetSalary = 0d;
double dTemp = 0d;
double dTempSalary = 0d;
double dAbsenceAmt = 0d;
double dOtherEarning = 0d;
String[] astrPtFt = {"Part-Time","Full-Time",""};
String strGrossPayTotal = null;
String strPtFt = WI.fillTextValue("pt_ft");
if (strSchCode.startsWith("CPU")){
strGrossPayTotal = dbOP.mapOneToOther("pr_edtr_salary","is_valid","1", "sum(gross_salary)",
						  " and user_index = " + strEmployeeIndex);
}

strSlash = "";
if (strPtFt.length() == 0){
	strPtFt = dbOP.mapOneToOther("info_faculty_basic","is_valid","1", "pt_ft",
						  " and user_index = " + strEmployeeIndex);
	strPtFt = WI.getStrValue(strPtFt,"1");
}
%>
<body onLoad="CloseWnd();">
<form>
  <%if(strPayslipUsed.equals("1")){
 	dOtherEarning = 0d;
 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
    <tr> 
      <td height="18" colspan="4">Name :
        <%
	  if (vPersonalDetails != null && vPersonalDetails.size() > 0 ) {%>
        <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong>
        <%}%>
      <%=WI.getStrValue(strEmpID,"(",")","")%>&nbsp;&nbsp;&nbsp; - &nbsp;<%=astrGender[Integer.parseInt(WI.getStrValue((String)vPersonalDetails.elementAt(4),"1"))]%></td>	
        <%
		strTemp = WI.fillTextValue("rank");
		if(strTemp.length() == 0){
			if (vPersonalDetails!= null && vPersonalDetails.size() > 0 ) 	
				strTemp = (String)vPersonalDetails.elementAt(15);
			else 
				strTemp = null;	
		}
		%>		
      <td height="18" colspan="2">&nbsp; <%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr>
 <%if(vPersonalDetails.elementAt(13) != null && vPersonalDetails.elementAt(14) != null){
					strSlash = "-";
				 }else{
					strSlash = "";	
				 }
				 strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(13),"") + strSlash + WI.getStrValue((String)vPersonalDetails.elementAt(14),"");
			 %>		
      <td height="18" colspan="4">Department :&nbsp;<%=strTemp%></td>
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td colspan="2" class="thinborderTOPBOTTOM" height="18"><strong>SALARY/COMPENSATION</strong></td>
          </tr>
          <tr> 
            <td width="68%" class="thinborderNONE" height="14">&nbsp;Basic salary</td>
            <td width="32%" align="right" class="thinborderNONE">  
              <% 
						if (vDTRDetails != null && vDTRDetails.size() > 0){ 
							strTemp = (String)vDTRDetails.elementAt(17);			
							dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}
						%>              <strong><%=WI.getStrValue(strTemp,"0")%>&nbsp;</strong></td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Transportation Allowance</td>
            <td align="right" class="thinborderNONE"> 
              <% strTemp = null;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(52);
				dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			}	
		   %>              <strong><%=WI.getStrValue(strTemp,"0")%>&nbsp;</strong></td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Incentives/honorarium</td>
            <td align="right" class="thinborderNONE">  
              <% 
			if (vDTRDetails != null && vDTRDetails.size() > 0){ 
				if (vSalIncentives != null && vSalIncentives.size() > 0){ 
					strTemp = ((Double) vSalIncentives.elementAt(0)).toString();
					dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				}	
			}			
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vDTRManual.elementAt(43),"0"),",",""));				
			}
			strTemp = Double.toString(dTemp);
			dGrossSalary += dTemp;
		  %>              <strong><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"0")%>&nbsp;</strong></td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Additional Payment Amount</td>
            <td align="right" class="thinborderNONE">  
              <% 
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(17);
				dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			}	
		   %>              <strong><%=WI.getStrValue(strTemp,"0")%>&nbsp;</strong></td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Part time/ Extra Salary</td>
            <td align="right" class="thinborderNONE">  
              <% 
		if (vDTRManual != null && vDTRManual.size() > 0){
			// faculty pay 
			strTemp = (String) vDTRManual.elementAt(44);
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			// overload pay
			strTemp = (String) vDTRManual.elementAt(67);
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
		}	
	   %>              <strong><%=WI.getStrValue(strTemp,"0")%>&nbsp;</strong></td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Night Differential</td>
            <td align="right" class="thinborderNONE">   
              <% 
		strTemp = null;
		if (vDTRManual != null && vDTRManual.size() >  0) 	
			strTemp = (String) vDTRManual.elementAt(25);
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		%>              <strong><%=WI.getStrValue(strTemp,"0")%>&nbsp;</strong></td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Overtime Amount</td>
            <td align="right" class="thinborderNONE">   
              <% 
		if (vDTRManual != null && vDTRManual.size() > 0){ 
			// OT Amount
			strTemp = (String) vDTRManual.elementAt(10);
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}	
	   %>              <strong><%=WI.getStrValue(strTemp,"0")%>&nbsp;</strong></td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Tardiness &amp; absences</td>
            <% 			
			if (vDTRManual != null && vDTRManual.size() > 0){ 
			// leave without pay			
				strTemp = (String) vDTRManual.elementAt(11);
				dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			// AWOL
				strTemp = (String) vDTRManual.elementAt(32);
				dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			// Lates and undertimes
				strTemp = (String) vDTRManual.elementAt(33);
				dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			// faculty absences
				strTemp = (String) vDTRManual.elementAt(45);
				dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
				dGrossSalary -= dAbsenceAmt;
			}	
		   %>
            <td align="right" class="thinborderNONE"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dAbsenceAmt,true),"(",")","0")%>&nbsp;</strong></td>
          </tr>
        </table></td>
      <td colspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td colspan="3" class="thinborderTOPBOTTOM" height="18"><strong>DEDUCTIONS</strong></td>
          </tr>
          <tr> 
            <td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;W/Holding 
              Tax</td>
            <td width="38%" align="right" class="thinborderNONE">   
              <% 
		if (vDTRManual != null && vDTRManual.size() > 0){ 
			strTemp = (String) vDTRManual.elementAt(24);
			dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}	
	   %>
              <strong><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></strong>&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;SSS</td>
            <td align="right" class="thinborderNONE">   
              <% 
		if (vDTRManual != null && vDTRManual.size() > 0){ 
			strTemp = (String) vDTRManual.elementAt(12);
			dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}	
	   %>
              <strong><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"0")%></strong>&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;PhilHealth</td>
            <td align="right" class="thinborderNONE">   
              <% 
		if (vDTRManual != null && vDTRManual.size() > 0){ 
			strTemp = (String) vDTRManual.elementAt(13);
			dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}	
	   %>
              <strong><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"0")%></strong>&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;PAG-IBIG</td>
            <td align="right" class="thinborderNONE">   
              <% 
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(14);
				dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			}	
		   %>
              <strong><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"0")%></strong>&nbsp;</td>
          </tr>
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
						%>
          <tr> 
            <td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;<%=strTemp%></td>
            <td align="right" class="thinborderNONE">
            <% 
							strTemp = CommonUtil.formatFloat(dTemp,true);
							dTotalDeduction += dTemp; 
							if(dTemp == 0d)
								strTemp = "";				
						 %>            <strong><%=WI.getStrValue(strTemp,"")%></strong>&nbsp;</td>
          </tr>
					<%}// END FOR LOOP
					}// END NULL CHECK%>					
          
          <tr> 
            <td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;Advances &amp; Other Ded</td>            
					<% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String) vDTRManual.elementAt(18);
						dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dTotalDeduction += dOtherDeduction;				
					}	
					 %>			
            <td align="right" class="thinborderNONE"> <strong><%=WI.getStrValue(CommonUtil.formatFloat(dOtherDeduction,true),"0")%></strong>&nbsp;</td>
          </tr>
        </table></td>
      <td colspan="2" valign="top" class="thinborderBOTTOMLEFTRIGHT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="73%" height="18" class="thinborderTOP">&nbsp;</td>
            <td width="27%" class="thinborderTOP">&nbsp;</td>
          </tr>
					<%
						if(vEarnings != null && vEarnings.size() > 1){
						dOtherEarning = 0d;
						for(i = 1; i < vEarnings.size(); i += 2) {
							strTemp = (String) vEarnings.elementAt(i+1);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			

							strTemp = (String) vEarnings.elementAt(i);
							if(strTemp == null || strTemp.length() == 0){
								dOtherEarning += dTemp;
								continue;
							}
						%>							
          <tr> 
            <td><font size="1">&nbsp;<%=strTemp%></font></td>
            <td align="right" class="thinborderNONE"><strong>
            <% 
								strTemp = CommonUtil.formatFloat(dTemp,true);
								dGrossSalary += dTemp; 
								if(dTemp == 0d)
									strTemp = "";				
 						    %>
            <%=WI.getStrValue(strTemp,"")%></strong></td>
          </tr>
					<%}// END FOR LOOP
					}// END NULL CHECK%>
					
          <% 					
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						// additional bonuses
						strTemp = (String) vDTRManual.elementAt(22);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dOtherEarning += dTemp;
						
						// holiday pay	
						strTemp = (String) vDTRManual.elementAt(26);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
						dOtherEarning += dTemp;

						// additional Responsibility
						strTemp = (String) vDTRManual.elementAt(27);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));						
						dOtherEarning += dTemp;

						// This is for COLA
						strTemp = (String) vDTRManual.elementAt(31);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dOtherEarning += dTemp;

					}// vDTRManual != null 

						dGrossSalary += dOtherEarning;
						if(dOtherEarning > 0d){
					%>
          <tr>
            <td height="18" class="thinborderNONE">&nbsp;&nbsp;OTHER EARNINGS </td>
            <td align="right" class="thinborderNONE"><strong><%=CommonUtil.formatFloat(dOtherEarning,2)%></strong></td>
          </tr>
					<%}%>
          <tr> 
            <td height="18" class="thinborderNONE"><strong>&nbsp;&nbsp;GROSS SALARY</strong></td>
            <td class="thinborderNONE"><div align="right">&nbsp;<strong><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%></strong></div></td>
          </tr>
          <tr> 
            <td height="10"></td>
            <td></td>
          </tr>
          <tr> 
            <td height="18" class="thinborderTOP"><strong>&nbsp;&nbsp;TOTAL 
              DEDUCTIONS</strong></td>
            <td class="thinborderTOP"><div align="right"><font size="1">&nbsp;<strong><%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%></strong></font></div></td>
          </tr>
          <tr> 
            <td height="18" class="thinborderNONE"><strong>&nbsp;&nbsp;ADJUSTMENT AMOUNT</strong></td>
            <% dTemp = 0d;
				if (vDTRManual != null && vDTRManual.size() > 0){ 
				  if (Double.parseDouble(ConversionTable.replaceString((String) vDTRManual.elementAt(20),",","")) < 0){
					strTemp = "(" + ConversionTable.replaceString((String) vDTRManual.elementAt(20),"-","") + ")";
					dTemp = Double.parseDouble(ConversionTable.replaceString((String) vDTRManual.elementAt(20),",",""));
				  }else{
					strTemp =(String) vDTRManual.elementAt(20);
					dTemp = Double.parseDouble(ConversionTable.replaceString((String) vDTRManual.elementAt(20),",",""));			
				  }
				}	
			   %>
            <td><div align="right"><font size="1">&nbsp;<strong><%=WI.getStrValue(strTemp,"0")%></strong></font></div></td>
          </tr>
          <tr> 
            <td height="18">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          
        </table></td>
    </tr>
    <tr> 
      <td width="20%" height="21" class="thinborderBOTTOMLEFT"><font size="1"><strong>&nbsp;&nbsp;GROSS 
        SALARY</strong></font></td>
      <td width="17%" height="21" class="thinborderBOTTOMLEFT"><div align="right"><font size="1">&nbsp;<strong><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%>&nbsp;</strong></font></div></td>
      <td width="20%" class="thinborderBOTTOMLEFT"><font size="1"><strong>&nbsp;&nbsp;TOTAL 
        DEDUCTIONS</strong></font></td>
      <td width="10%" class="thinborderBOTTOMLEFT"><div align="right"><font size="1">&nbsp;<strong><%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%>&nbsp;</strong></font></div></td>
      <td width="20%" class="thinborderBOTTOMLEFT"><strong>&nbsp;&nbsp;NET 
      SALARY :</strong></td>
			<%
				dNetSalary = dGrossSalary - dTotalDeduction + dTemp;
			%>			
      <td width="13%" align="right" class="thinborderBOTTOMLEFTRIGHT"><font size="1">&nbsp;<strong><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%></strong></font></td>
    </tr>
    <tr>
      <td height="7" colspan="6"></td>
    </tr>
  </table>   
	<%if(vUnworkedDays != null && vUnworkedDays.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">		
		<%
			strTemp = null;
			for(i = 0;i < vUnworkedDays.size(); i++){
				if(strTemp == null)
					strTemp = (vUnworkedDays.elementAt(i)).toString();
				else
					strTemp += ", " + (vUnworkedDays.elementAt(i)).toString();
			}
		%>
		<tr>
			<td height="14">Absences : <font size="1"><%=strTemp%></font></td>
		</tr>
	</table>
	<%}%>
   <%}else if(strPayslipUsed.equals("2")){%>
	 <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
			<tr> 
				<td><font size="1"><span class="thinborderNONE">DEPARTMENT </span></font></td>
			  <%if(vPersonalDetails.elementAt(13) != null && vPersonalDetails.elementAt(14) != null){
					strSlash = "-";
				 }else{
					strSlash = "";	
				 }
				 strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(13),"") + strSlash + WI.getStrValue((String)vPersonalDetails.elementAt(14),"");
			 %>				
				<td colspan="2"><font size="1"><%=strTemp%><font size="1">&nbsp;</font></font></td>
				<td>&nbsp;</td>
				<td align="right" class="thinborderNONE">Payslip : <%=strPayrollPeriod%></td>
			  <td colspan="2">&nbsp;</td>
			</tr>
			<tr> 
				<td height="17" class="thinborderBOTTOM"><font size="1">NAME</font></td>
				<td class="thinborderBOTTOM"><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
								(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%></td>
			  <td class="thinborderBOTTOM"><%=WI.getStrValue(strEmpID,"(",")","")%></td>
			  <td class="thinborderBOTTOM">&nbsp;</td>
				<%
				 if (vDTRDetails != null && vDTRDetails.size() > 0){ 		
					 strHourlyRate = (String)vDTRDetails.elementAt(19);
					}else{
						strHourlyRate = "&nbsp;";
					}	
				%>			 
				<td class="thinborderBOTTOM">RATE : <%=strHourlyRate%></td>
			  <td colspan="2" class="thinborderBOTTOM">&nbsp;</td>
			</tr>
			<tr> 
				<td height="18" colspan="3" valign="top">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">						
						<tr>
						  <td width="26%" valign="bottom" class="thinborderNONE">Earnings</td>
						 <% 
							 if (vDTRManual != null && vDTRManual.size() > 0){ 
									strTemp = (String)vDTRManual.elementAt(68);			
								}else{
									strTemp = "";
								}
							%>							
							<td width="37%" height="10" valign="bottom" class="thinborderNONE">Basic Pay </td>
							<% 
							if (vDTRDetails != null && vDTRDetails.size() > 0){ 
								// period rate
								strTemp = (String)vDTRDetails.elementAt(17);			
								dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							}
							%>
							<td width="37%" align="right" valign="bottom"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
						</tr>											
					 <% dTemp = 0d;
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							// OT amount
							strTemp = (String) vDTRManual.elementAt(10);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							dGrossSalary += dTemp; 
						}	
						if(dTemp == 0d)
							 strTemp = "";
						%>
						<tr>
						  <td valign="bottom">&nbsp;</td>
							<td height="10" valign="bottom"><font size="1">Overtime</font></td>
							<td align="right" valign="bottom"><font size="1">
								<%=WI.getStrValue(strTemp,"")%></font></td>
						</tr>
          <% 
						dTemp = 0d;
						if (vDTRManual != null && vDTRManual.size() >  0){ 	
							// night diff
							strTemp = (String) vDTRManual.elementAt(25);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							dGrossSalary += dTemp; 
						}
						if(dTemp > 0d){
						%>
						<tr>
						  <td valign="bottom">&nbsp;</td>
						  <td height="10" valign="bottom"><font size="1">Night Differential </font></td>
						  <td align="right" valign="bottom"><font size="1"> <%=WI.getStrValue(strTemp,"")%></font></td>
				  	</tr>
						<%}%>	
						<tr>
						  <td valign="bottom">&nbsp;</td>
						  <td height="10" valign="bottom" class="thinborderNONE"><span class="thinborderNONE">Holiday pay </span></td>
              <% dTemp = 0d;
								if (vDTRManual != null && vDTRManual.size() > 0){ 
									// holiday pay
									strTemp = (String) vDTRManual.elementAt(26);
									dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
									dGrossSalary += dTemp; 
									if(dTemp == 0d)
										strTemp = "";
								}	
							%>
						  <td align="right" valign="bottom"> 
                <%=WI.getStrValue(strTemp,"")%></td>
				  </tr>					 
				  </table></td>
				<td valign="top">&nbsp;</td>
				<td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <% dTemp = 0d;
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							// faculty pay
							strTemp = (String) vDTRManual.elementAt(44);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = (String) vDTRManual.elementAt(60);
							// sub teaching salary
							dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
			
							strTemp = (String) vDTRManual.elementAt(67);
							// manually encoded overload Amount
							dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
			
							dGrossSalary += dTemp; 
							}					
							strTemp = CommonUtil.formatFloat(dTemp,true);			
							if(dTemp > 0d){
						 %>
          <tr>
            <td height="10" valign="bottom" class="thinborderNONE">Overload / Faculty pay</td>
            <td align="right" valign="bottom" class="thinborderNONE"><%=WI.getStrValue(strTemp,"")%></td>
          </tr>
          <%}%>         
					<% 
						dTemp = 0d;
						if(vEarnings != null && vEarnings.size() > 1){
							strTemp = (String) vEarnings.elementAt(0);
							dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));			
						 }// END NULL CHECK
						 
						 if (vDTRManual != null && vDTRManual.size() > 0){
							// manual encoded additional payment amount in the dtr manual page
								strTemp = (String) vDTRManual.elementAt(17);
								dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
								
								// additional bonuses
								strTemp = (String) vDTRManual.elementAt(22);
								dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

								// additional resp
								strTemp = (String) vDTRManual.elementAt(27);
								dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));								
							}
							
						%>							
          <tr> 
            <td  height="16" class="thinborderNONE">Other Income </td>
            <td align="right" class="thinborderNONE">
            <% 
								strTemp = CommonUtil.formatFloat(dTemp,true);
								dGrossSalary += dTemp; 
								if(dTemp == 0d)
									strTemp = "";				
 						    %>
            <%=WI.getStrValue(strTemp,"")%></td>
          </tr>					
					<% 			
					if (vDTRManual != null && vDTRManual.size() > 0){ 
					// leave without pay			
						strTemp = (String) vDTRManual.elementAt(11);
						dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					// AWOL
						strTemp = (String) vDTRManual.elementAt(32);
						dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					// Lates and undertimes
						strTemp = (String) vDTRManual.elementAt(33);
						dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					// faculty absences
						strTemp = (String) vDTRManual.elementAt(45);
						dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
						dGrossSalary -= dAbsenceAmt;
						if(dAbsenceAmt > 0)
							strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);
						else
							strTemp = "-";
					}	
					 %>
          <tr>
            <td width="70%" class="thinborderNONE">Abs/UT/Late</td>
            <td width="30%" align="right" class="thinborderNONE"><%=strTemp%></td>
          </tr>
        </table></td>
			  <td align="right" valign="bottom" class="thinborderBOTTOMonly"><font size="2"><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%></font></td>
			  <td align="right" valign="bottom" class="thinborderBOTTOMonly">
          <% dTemp = 0d;
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							// adjustment
							strTemp =(String) vDTRManual.elementAt(20);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							if (dTemp < 0d)//{
							strTemp = "(" + ConversionTable.replaceString((String) vDTRManual.elementAt(20),"-","") + ")";
							//dTotalDeduction -= Double.parseDouble(ConversionTable.replaceString((String) vDTRManual.elementAt(20),",",""));
							//}else{				
							
							//}
							dNetSalary += dTemp;			
						}	
							if(dTemp != 0d){
					%>				
				Adjustment<br><%=strTemp%>
				<%}%>
			  </td>
			</tr>
			<tr>
			  <td height="10" colspan="7" valign="top"></td>
	   </tr>
			<tr>
			  <td height="18" colspan="3" valign="top" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr>
            <td width="26%" valign="bottom" class="thinborderNONE" height="14">Deductions</td>
            <td width="38%" valign="bottom"><font color="#000000" size="1">W/Tax</font></td>
            <td width="36%" align="right" valign="bottom"><font size="1">
              <% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							// tax
							strTemp = (String) vDTRManual.elementAt(24);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							dTotalDeduction += dTemp; 
							strTemp = CommonUtil.formatFloat(strTemp,true);
							if(dTemp == 0d)
								strTemp = "";
						}	
						 %>
              <%=WI.getStrValue(strTemp,"")%></font></td>
          </tr>
          <tr>
            <td valign="bottom" height="14">&nbsp;</td>
            <td valign="bottom"><font color="#000000" size="1">SSS Premium</font></td>
            <td align="right" valign="bottom"><font size="1">
              <% 
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				// SSS
				strTemp = (String) vDTRManual.elementAt(12);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dTotalDeduction += dTemp; 
				if(dTemp == 0d)
					strTemp = "";			
			}	
			 %>
              <%=WI.getStrValue(strTemp,"")%></font></td>
          </tr>
          <tr>
            <td valign="bottom" height="14">&nbsp;</td>
            <td valign="bottom"><font color="#000000" size="1">Philhealth</font></td>
            <td align="right" valign="bottom"><font size="1">
              <% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						// PHEAlth
						strTemp = (String) vDTRManual.elementAt(13);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						strTemp = CommonUtil.formatFloat(strTemp,true);
						dTotalDeduction += dTemp; 
						if(dTemp == 0d)
							strTemp = "";			
					}	
					 %>
              <%=WI.getStrValue(strTemp,"")%></font></td>
          </tr>
          <tr>
            <td valign="bottom" height="14">&nbsp;</td>
            <td valign="bottom"><font size="1">Pag-ibig Premium </font></td>
            <td align="right" valign="bottom"><font size="1">
              <% 
				if (vDTRManual != null && vDTRManual.size() > 0){ 
				// pag ibig
					strTemp = (String) vDTRManual.elementAt(14);
					dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
					strTemp = CommonUtil.formatFloat(strTemp,true);
					dTotalDeduction += dTemp; 
					if(dTemp == 0d)
						strTemp = "";
				}	
				 %>
              <%=WI.getStrValue(strTemp,"")%></font></td>
          </tr>
          <tr>
            <td valign="bottom" height="14">&nbsp;</td>
            <td valign="bottom"><font size="1">PERAA Premium </font></td>
            <td align="right" valign="bottom"><font size="1">
              <% 
				if (vDTRManual != null && vDTRManual.size() > 0){ 
				  //peraa
					strTemp = (String) vDTRManual.elementAt(54);
					dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
					strTemp = CommonUtil.formatFloat(strTemp,true);
					dTotalDeduction += dTemp; 
					if(dTemp == 0d)
						strTemp = "";
				}	
				 %>
              <%=WI.getStrValue(strTemp,"")%></font></td>
          </tr> 
        <% 
				if (vDTRManual != null && vDTRManual.size() > 0){ 
				  // GSIS
					strTemp = (String) vDTRManual.elementAt(61);
					dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
					strTemp = CommonUtil.formatFloat(strTemp,true);
					dTotalDeduction += dTemp; 
					if(dTemp > 0d){
				 %>					
          <tr>
            <td valign="bottom" height="14">&nbsp;</td>
            <td valign="bottom"><font size="1">GSIS Premium </font></td>
            <td align="right" valign="bottom"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
          </tr>           
					<%}
				 }%>
        </table></td>
			  <td valign="top" class="thinborderBOTTOM">&nbsp;</td>
			  <td valign="top" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          
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
						%>
          <tr>
            <td width="50%" class="thinborderNONE" height="14">&nbsp;<%=WI.getStrValue(strTemp,"")%></td>
            <td width="50%" align="right" class="thinborderNONE"><% 
							strTemp = CommonUtil.formatFloat(dTemp,true);
							dTotalDeduction += dTemp; 
							if(dTemp == 0d)
								strTemp = "";				
						 %>
                <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
          </tr>
          <%}// end for loop
						}// end null check%>
          <tr>
            <td class="thinborderNONE" height="14">&nbsp;OTHERS</td>
            <% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 	
							strTemp = (String) vDTRManual.elementAt(18);//MISC_DEDUCTION (Addl ded)
							dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}
							strTemp = CommonUtil.formatFloat(dOtherDeduction,2);
							dTotalDeduction += dOtherDeduction; 
							if(dOtherDeduction == 0d)
								strTemp = "";
						
						%>
            <td align="right" class="thinborderNONE"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
          </tr>
        </table></td>
	      <td align="right" valign="bottom" class="thinborderBOTTOM"><font size="2"><%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%></font></td>
				<%
					dNetSalary += dGrossSalary - dTotalDeduction;
				%>				
		    <td align="right" valign="bottom" class="thinborderBOTTOM"><strong><font size="2"><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%></font>&nbsp;</strong></td>
		 </tr>
			<%if(vEarnings != null && vEarnings.size() > 1){%>
			<tr>
			  <td height="18" valign="top" class="thinborderNONE">Other Inc. </td>
			  <td height="18" colspan="2" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <%						
						dOtherEarning = 0d;
						for(i = 1; i < vEarnings.size(); i += 2) {
							strTemp = (String) vEarnings.elementAt(i+1);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			

							strTemp = (String) vEarnings.elementAt(i);
							if(strTemp == null || strTemp.length() == 0){
								dOtherEarning += dTemp;
								continue;
							}
						%>							
          <tr> 
            <td  height="16" class="thinborderNONE"><%=strTemp%></td>
            <td align="right" class="thinborderNONE">
            <% 
								strTemp = CommonUtil.formatFloat(dTemp,true);
								dGrossSalary += dTemp; 
								if(dTemp == 0d)
									strTemp = "";				
 						    %>
            <%=WI.getStrValue(strTemp,"")%></td>
          </tr>
					<%}// END FOR LOOP					
					%>
				<%dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						// manual encoded additional payment amount in the dtr manual page
						strTemp = (String) vDTRManual.elementAt(17);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					}	
					dOtherEarning += dTemp;
					strTemp = CommonUtil.formatFloat(dOtherEarning,true);					
					if(dOtherEarning > 0d){
				%>
          <tr>
            <td class="thinborderNONE">OTHERS</td>
            <td align="right" class="thinborderNONE"><%=strTemp%></td>
          </tr>
				 <%}%>					
        </table></td>
			  <td valign="top">&nbsp;</td>
			  <td valign="top">&nbsp;</td>
			  <td valign="bottom">&nbsp;</td>
			  <td align="right" valign="bottom">&nbsp;</td>
	   </tr>
		 <%}%>
			<tr>
			  <td height="18" colspan="3" valign="top" class="thinborderNONE">Cut - off Date : <%=WI.getStrValue(strCutOff,"0")%></td>
			  <td valign="top">&nbsp;</td>
			  <td valign="top">&nbsp;</td>
			  <td valign="bottom">&nbsp;</td>
			  <td align="right" valign="bottom">&nbsp;</td>
	   </tr>
		 <tr>
			  <td width="12%" height="18" valign="top">&nbsp;</td>
			  <td width="22%" valign="top">&nbsp;</td>
			  <td width="7%" valign="top">&nbsp;</td>
			  <td width="2%" valign="top">&nbsp;</td>
			  <td width="35%" valign="top">&nbsp;</td>
			  <td width="10%" valign="bottom">&nbsp;</td>
			  <td width="12%" align="right" valign="bottom">&nbsp;</td>
	   </tr>
	</table>	 
		<%}else{
	 	//  This is mainly for cldh... but other schools/ companies without payslip could use this
	 %>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
		<tr> 
			<td width="17%" class="thinborderNONEcl">&nbsp;PAYROLL PERIOD</td>
			<td width="32%" class="thinborderNONEcl">&nbsp;<%=WI.getStrValue(strCutOff,"0")%></td>
			<td width="28%">&nbsp;</td>
			<td width="23%">&nbsp;</td>
		</tr>
		<tr> 
			<td height="17" class="thinborderNONEcl">&nbsp;NAME</td>
			<td class="thinborderNONEcl">&nbsp;<strong><u><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%></u><%=WI.getStrValue(strEmpID,"(",")","")%></strong></td>
		 <%if(vPersonalDetails.elementAt(13) != null && vPersonalDetails.elementAt(14) != null){
				strSlash = "-";
			 }else{
				strSlash = "";	
			 }
			 strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(13),"") + strSlash + WI.getStrValue((String)vPersonalDetails.elementAt(14),"");
		 %>
		  <td colspan="2" class="thinborderNONEcl">&nbsp;DEPARTMENT : <%=strTemp%></td>
		</tr>
		<tr>
		  <td height="34">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="2" class="thinborderNONE">&nbsp;</td>
	  </tr>
		<tr> 
			<td height="18" colspan="2" valign="top" class="thinborderTOP"><table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr valign="bottom"> 
						<td height="25" colspan="6"><div align="center"><strong>EARNINGS</strong></div></td>
					</tr>
					<tr>
						<td valign="bottom"><font size="1">RATE / DAY</font></td>
						<td align="right" valign="bottom"><font size="1">
							<% 
						 if (vDTRDetails != null && vDTRDetails.size() > 0){ 
							 strDailyRate = (String)vDTRDetails.elementAt(18);			
							}else{
							strDailyRate = " ";
							}
						%>
							<%=WI.getStrValue(strDailyRate,"0")%></font></td>
						<td>&nbsp;</td> 
						<td height="10">&nbsp;</td>
						<td align="right"><font size="1">&nbsp;</font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
					 <% 
						 if (vDTRManual != null && vDTRManual.size() > 0){ 
								strTemp = (String)vDTRManual.elementAt(68);			
							}else{
								strTemp = "";
							}
						%>							
						<td valign="bottom"><font size="1">Regular Pay <br>
						<%=strTemp%> days</font></td>
						<% 
						if (vDTRDetails != null && vDTRDetails.size() > 0){ 
							strTemp = (String)vDTRDetails.elementAt(17);			
							dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}
						%>
						<td align="right" valign="bottom"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
						<td>&nbsp;</td> 
						<td height="10">&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
					<% 
					dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() >  0){ 	
						strTemp = (String) vDTRManual.elementAt(25);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dGrossSalary += dTemp; 
					}
					if(dTemp > 0d){
					%>
					<tr>
						<td valign="bottom"><font size="1">NIGHT DIFFERENTIAL</font></td>
						<td align="right" valign="bottom"><font size="1">
							<%=WI.getStrValue(strTemp,"")%></font></td>
						<td>&nbsp;</td> 
						<td height="10">&nbsp;</td>
						<td align="right"><font size="1">&nbsp;</font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}%>
				 <% dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp =(String) vDTRManual.elementAt(20);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						if (dTemp < 0d){
							strTemp = "(" + ConversionTable.replaceString((String) vDTRManual.elementAt(20),"-","") + ")";							
						}
						dGrossSalary += dTemp;
					}	
						if(dTemp != 0d){
					%>
					<tr>
						<td valign="bottom"><font size="1">ADJUSTMENT</font></td>
						<td align="right" valign="bottom"><font size="1">
							<%=WI.getStrValue(strTemp,"")%></font></td>
						<td>&nbsp;</td> 
						<td height="10"><font size="1">&nbsp;</font></td>
						<td align="right"><font size="1">&nbsp;</font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}%>
					
					<% dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						// faculty pay
						strTemp = (String) vDTRManual.elementAt(44);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						strTemp = (String) vDTRManual.elementAt(60);
						// sub teaching salary
						dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
		
						strTemp = (String) vDTRManual.elementAt(67);
						// manually encoded overload Amount
						dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
		
						dGrossSalary += dTemp; 
						}					
						strTemp = CommonUtil.formatFloat(dTemp,true);			
						if(dTemp > 0d){
					 %>
					<tr>
						<td valign="bottom"><font size="1">OVERLOAD</font></td>
						<td align="right" valign="bottom"><font size="1">
							<%=WI.getStrValue(strTemp,"")%></font></td>
						<td>&nbsp;</td> 
						<td height="10">&nbsp;</td>
						<td align="right"> <font size="1">&nbsp;</font></td>
						<td align="right">&nbsp;</td>
					</tr>
				 <%}%> 
					<% dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String) vDTRManual.elementAt(10);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dGrossSalary += dTemp; 
					}	
						if(dTemp > 0d){
					%>
					<tr>
						<td valign="bottom"><font size="1">OVERTIME&nbsp;</font></td>
						<td align="right" valign="bottom"><font size="1">
							<%=WI.getStrValue(strTemp,"")%></font></td>
						<td>&nbsp;</td> 
						<td height="10"><font size="1">&nbsp;</font></td>
						<td align="right"><font size="1">&nbsp;</font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}%>
				<%
					if(vEarnings != null && vEarnings.size() > 1){
					dOtherEarning = 0d;
					for(i = 1; i < vEarnings.size(); i += 2) {
						strTemp = (String) vEarnings.elementAt(i+1);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			

						strTemp = (String) vEarnings.elementAt(i);
						if(strTemp == null || strTemp.length() == 0){
							dOtherEarning += dTemp;
							continue;
						}
					%>					
					<tr>
						<td height="10" valign="bottom"><font size="1"><%=strTemp%></font></td>
							<td align="right" valign="bottom"><font size="1">
			<% 
							strTemp = CommonUtil.formatFloat(dTemp,true);
							dGrossSalary += dTemp; 
							if(dTemp == 0d)
								strTemp = "";				
						%>
			<%=WI.getStrValue(strTemp,"")%></font></td>
							<td>&nbsp;</td> 
							<td>&nbsp;</td>
							<td align="right">&nbsp;</td>
							<td align="right">&nbsp;</td>
					</tr>
					<%} // end for loop
	   } // end if vVarAllowances != null %>
										
				<%//if (vVarAllowances != null && vVarAllowances.size() > 2){
				//	for(i = 2;i < vVarAllowances.size(); i+=6){ %>
				<!--
				<tr>
				<%
					//strTemp = WI.getStrValue((String)vVarAllowances.elementAt(i+1),"&nbsp;");
				//	strTemp += WI.getStrValue((String)vVarAllowances.elementAt(i+2)," (",")","&nbsp;");
				%>
						<td height="19" valign="bottom"><font size="1"><%=strTemp%></font></td>
						<td align="right" valign="bottom"> 
							<% //dTemp = 0d;			
			// strTemp = WI.getStrValue((String)vVarAllowances.elementAt(i+3),"0");
		  // dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
			//	dGrossSalary += dTemp; 
			//	if(dTemp == 0d)
			//		strTemp = "-";
				 %>
							<font size="1"><%//=WI.getStrValue(strTemp,"")%></font></td>
						<td>&nbsp;</td> 
						<td>&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
				</tr>
				-->
					<%//} // end for loop
	   //} // end if vVarAllowances != null %>

				 <% dTemp = 0d;
					if (vDTRDetails != null && vDTRDetails.size() > 0){
						if (vSalIncentives != null && vSalIncentives.size() > 0){ 
							strTemp = ((Double) vSalIncentives.elementAt(0)).toString();
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}	
					}
					
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = ConversionTable.replaceString(WI.getStrValue((String)vDTRManual.elementAt(43),"0"),",","");
						dTemp += Double.parseDouble(strTemp);				
					}
					
					strTemp = Double.toString(dTemp);
					dGrossSalary += dTemp;
					strTemp = CommonUtil.formatFloat(strTemp,true);
					if(dTemp > 0d){
					%>
					<tr>
						<td valign="bottom"><font size="1"> INCENTIVE</font></td>
						<td align="right" valign="bottom"><font size="1">
							<%=WI.getStrValue(strTemp,"")%></font></td>
						<td>&nbsp;</td> 
						<td>&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}%>
					<tr>
						<td width="33%"><font size="1">OTHERS</font></td>
						<% 
							strTemp = CommonUtil.formatFloat(dOtherEarning,2);
							dGrossSalary += dOtherEarning;
							if(dOtherEarning == 0d)
								strTemp = "";
						%>							
						<td width="25%" align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
						<td width="4%">&nbsp;</td>
						<td width="16%">&nbsp;</td>			
						<td width="19%" align="right">&nbsp;</td>
						<td width="3%" align="right">&nbsp;</td>
					</tr>
					<% 	
					dAbsenceAmt = 0d;		
					strTemp = null;
					if (vDTRManual != null && vDTRManual.size() > 0){ 
					// leave without pay			
						strTemp = (String) vDTRManual.elementAt(11);
						dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					// AWOL
						strTemp = (String) vDTRManual.elementAt(32);
						dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					// Lates and undertimes
						strTemp = (String) vDTRManual.elementAt(33);
						dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					// faculty absences
						strTemp = (String) vDTRManual.elementAt(45);
						dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
						dGrossSalary -= dAbsenceAmt;
					}
					if(dAbsenceAmt > 0){
						strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);
				   %>	
					<tr>
					  <td class="thinborderNONE">TARDINESS &amp; ABSENCES </td>
					  <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"(",")","")%></font></td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td align="right">&nbsp;</td>
					  <td align="right">&nbsp;</td>
					</tr>
					<%}%>
					<%
					dOtherDeduction = 0d;
					if(vEarnDed != null && vEarnDed.size() > 1){							
						for(i = 1; i < vEarnDed.size(); i += 2) {
							strTemp = (String) vEarnDed.elementAt(i+1);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			

							strTemp = (String) vEarnDed.elementAt(i);
							if(strTemp == null || strTemp.length() == 0){
								dOtherDeduction += dTemp;
								continue;
							}
					%>
					<tr>
					  <td><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
					  <td align="right"><font size="1">
					  <% 
						strTemp = CommonUtil.formatFloat(dTemp,true);
						dGrossSalary -= dTemp; 
						if(dTemp == 0d)
							strTemp = "";				
					 %>
					  <%=WI.getStrValue(strTemp,"(",")","")%></font></td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td align="right">&nbsp;</td>
					  <td align="right">&nbsp;</td>
					</tr>
					 <%}
					 }%>  
											
					<% 
						strTemp = CommonUtil.formatFloat(dOtherDeduction,2);
						dGrossSalary -= dOtherDeduction;
						if(dOtherDeduction > 0d){
							strTemp = "";
					%>						
					<tr>
					  <td><font size="1">OTHERS</font></td>
					  <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td align="right">&nbsp;</td>
					  <td align="right">&nbsp;</td>
					</tr>     
					<%}%>
				</table></td>
			<td colspan="2" valign="top" class="thinborderTOPLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr valign="bottom"> 
						<td height="25" colspan="5"><div align="center"><strong>DEDUCTIONS</strong></div></td>
					</tr>
					<tr> 
						<td valign="bottom"><font size="1">&nbsp;&nbsp;</font><font color="#000000" size="1">W/HOLDING 
						TAX </font></td>
						<td align="right" valign="bottom"><font size="1">
					 <% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String) vDTRManual.elementAt(24);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dTotalDeduction += dTemp; 
						strTemp = CommonUtil.formatFloat(strTemp,true);
						if(dTemp == 0d)
							strTemp = "";
					}	
					 %>
							<%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
						<td valign="bottom"><font size="1">&nbsp;&nbsp;</font><font color="#000000" size="1">SSS 
						PREM.</font></td>
						<td align="right" valign="bottom"><font size="1">
						<% 
		if (vDTRManual != null && vDTRManual.size() > 0){ 
			strTemp = (String) vDTRManual.elementAt(12);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
			strTemp = CommonUtil.formatFloat(strTemp,true);
			dTotalDeduction += dTemp; 
			if(dTemp == 0d)
				strTemp = "";			
		}	
		 %>
						<%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
						<td valign="bottom"><font size="1"> &nbsp;&nbsp;PHILHEALTH 
						PREM.</font></td>
						<td align="right" valign="bottom"><font size="1">
						<% 
		if (vDTRManual != null && vDTRManual.size() > 0){ 
			strTemp = (String) vDTRManual.elementAt(13);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
			strTemp = CommonUtil.formatFloat(strTemp,true);
			dTotalDeduction += dTemp; 
			if(dTemp == 0d)
				strTemp = "";			
		}	
		 %>
						<%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
						<td valign="bottom"><font size="1">&nbsp;&nbsp;PAG-IBIG<font color="#000000"> </font><font color="#000000" size="1">PREM.</font></font></td>
						<td align="right" valign="bottom"><font size="1">
							<% 
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(14);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dTotalDeduction += dTemp; 
				if(dTemp == 0d)
					strTemp = "";
			}	
			 %>
							<%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
						<td valign="bottom"><font size="1">&nbsp;&nbsp;PERAA </font><font color="#000000" size="1">PREM.</font></td>
						<td align="right" valign="bottom"><font size="1">
						<% 
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(54);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dTotalDeduction += dTemp; 
				if(dTemp == 0d)
					strTemp = "";
			}	
			 %>
						<%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
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
					%>
					<tr>
						<td valign="bottom"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(strTemp,"")%></font></td>
						<td align="right" valign="bottom"><font size="1">
						<% 
						strTemp = CommonUtil.formatFloat(dTemp,true);
						dTotalDeduction += dTemp; 
						if(dTemp == 0d)
							strTemp = "";				
					 %>
						<%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}
					}%>
					<tr> 
						<td valign="bottom"><font size="1">&nbsp;&nbsp;OTHERS</font></td>
						<% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 	
						strTemp = (String) vDTRManual.elementAt(18);//MISC_DEDUCTION (Addl ded)
						dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					}
						strTemp = CommonUtil.formatFloat(dOtherEarning,true);
						dTotalDeduction += dOtherDeduction; 
						if(dOtherDeduction == 0d)
							strTemp = "";
					
					%>
						<td align="right" valign="bottom"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
						<td width="32%">&nbsp;</td>
						<td width="19%">&nbsp;</td>
						<td width="3%">&nbsp;</td>
						<td width="27%">&nbsp;</td>			
						<td width="19%" align="right">&nbsp;</td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="19" colspan="2" valign="top" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="78%" height="18" align="right"><font size="1">T</font><font size="1">OTAL 
						EARNINGS&nbsp;</font></td>
					<td width="19%"><div align="right">&nbsp;<font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%></font>&nbsp;</div></td>
					<td width="3%">&nbsp;</td>
				</tr>
				
			</table></td>
			<td colspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
				
				<tr>
					<td width="55%"><font size="1">&nbsp;&nbsp;TOTAL DEDUCTIONS</font></td>
					<td width="45%"><div align="right"><font size="1">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%>&nbsp; </font></div></td>
				</tr>
				<tr>
					<td height="19" valign="bottom"><strong>&nbsp;&nbsp;NET SALARY :</strong></td>
					<%
				dNetSalary += dGrossSalary - dTotalDeduction;
			%>
					<td align="right" valign="bottom"><u><strong><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%>&nbsp;</strong></u></td>
				</tr>
			</table></td>
		</tr>
	</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="45%" valign="top">
				<%if(vOTEncoding != null && vOTEncoding.size() > 0){%>
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td colspan="2" class="thinborderNONE">OVERTIME DETAILS </td>
						<td width="36%">&nbsp;</td>
						<td width="19%">&nbsp;</td>
					</tr>
					<%					
						for(i = 0; i < vOTEncoding.size(); i+=12){
					%>
					<tr>
						<%
							strSlash = " and ";
							strTemp = (String)vOTEncoding.elementAt(i+5);
							iTemp = Integer.parseInt(strTemp);
							if(iTemp <= 0){
								strTemp = "";
								strSlash = "";
							}
							
							strTemp2 = (String)vOTEncoding.elementAt(i+11);
							iTemp = Integer.parseInt(strTemp2);
							if(iTemp <= 0){
								strTemp2 = "";
								strSlash = "";
							}						
						%>
						<td width="24%" height="20" valign="top" class="thinborderNONE"><%=WI.getStrValue(strTemp,"","hr(s)" + strSlash,"")%>&nbsp;<%=WI.getStrValue(strTemp2,"","min(s)","")%></td>
						<% 
							strTemp = (String)vOTEncoding.elementAt(i+1); 
						%>					
						<td width="21%" valign="top" class="thinborderNONE"><%=strTemp%></td>
						<%
							strTemp = (String)vOTEncoding.elementAt(i+2);						
						%>
						<td width="36%" valign="top" class="thinborderNONE"><%=strTemp%></td>
						<%
							strTemp = (String)vOTEncoding.elementAt(i+7);						
						%>
						<td width="19%" align="right" valign="top" class="thinborderNONEcl"><%=strTemp%>&nbsp;</td>
					</tr>
					<%}// end for loop%>
				</table>
				<%}// end vOTEncoding%>
				</td>			
				<td width="55%" valign="top">
				<%if(vEmpLoans != null && vEmpLoans.size() > 0){%>
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td colspan="2" class="thinborderNONE">LOAN DETAILS : </td>
						<td width="21%">&nbsp;</td>
						<td width="22%">&nbsp;</td>
						<td width="17%">&nbsp;</td>
					</tr>
					<tr>
						<td width="21%" class="thinborderNONE">&nbsp;</td>
						<td width="19%" align="center" class="thinborderNONE">Principal Amt</td>
						<td align="center" class="thinborderNONE">Paid to Date</td>
						<td align="center" class="thinborderNONE">Pay Period Ded.</td>
						<td align="center" class="thinborderNONE">Balance</td>
					</tr>
					<%for(i = 0;i < vEmpLoans.size();i+=9){%>
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
						%>					
						<td align="right" class="thinborderNONEcl"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
						<%
							strTemp = (String)vEmpLoans.elementAt(i+8);
						%>					
						<td align="right" class="thinborderNONEcl"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
						<%
							strTemp = (String)vEmpLoans.elementAt(i+4);
						%>										
						<td align="right" class="thinborderNONEcl"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
					</tr>
					<%}%>
				</table>
				<%}%>			</td>
			</tr>
			<%if(strSchCode.startsWith("CLDH")){%>
			<tr>
				<td height="18" colspan="2"><hr size="1" color="#000000"></td>
			</tr>			
			<tr>
				<td colspan="2" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td width="17%" align="right" class="thinborderNONEcl">Salary Rate :&nbsp; </td>
						<td width="12%" class="thinborderNONEcl">&nbsp;</td>
						<%
							if(vEmpIDs != null && vEmpIDs.size() > 0)
								strTemp = (String)vEmpIDs.elementAt(0);
							else
								strTemp = "";
						%>		
						<td width="18%" align="right" class="thinborderNONEcl">SSS :&nbsp;</td>
						<td width="16%" class="thinborderNONEcl"><strong>&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
						<td width="19%" align="right" class="thinborderNONEcl">Bank Account&nbsp;:&nbsp;</td>
						<td width="18%" class="thinborderNONEcl"><strong>&nbsp;<%=WI.getStrValue(WI.fillTextValue("bank_account"),"")%></strong></td>
					</tr>
					<tr>
						<td align="right" class="thinborderNONEcl">YTD Basic :&nbsp;</td>					
						<%
							if(vYTDInfo != null && vYTDInfo.size() > 0)
								strTemp = (String)vYTDInfo.elementAt(0);
							else
								strTemp = "";
						%>
						<td align="right" class="thinborderNONEcl"><strong><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</strong></td>
						<%
							if(vEmpIDs != null && vEmpIDs.size() > 0)
								strTemp = (String)vEmpIDs.elementAt(3);
							else
								strTemp = "";
						%>
						<td align="right" class="thinborderNONEcl">PAGIBIG :&nbsp;</td>
						<td class="thinborderNONEcl"><strong>&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
						<td align="right" class="thinborderNONEcl">Tax Status&nbsp;:&nbsp;</td>
						<%
						if (vDTRDetails != null && vDTRDetails.size() > 0){
							strTemp = (String)vDTRDetails.elementAt(36);
							iTemp  = Integer.parseInt(WI.getStrValue(strTemp,"0"));
							strTemp2 = (String)vDTRDetails.elementAt(37);
							if(WI.getStrValue(strTemp2,"0").equals("0"))
								strTemp2 = "";
							}
						%>
						<td class="thinborderNONEcl"><strong>&nbsp;<%=astrTaxStatus[iTemp]%>
								<%if (iTemp > 1){%>
								<%=strTemp2%>
								<%}%>
					  </strong></td>
					</tr>
					<tr>
						<td align="right" class="thinborderNONEcl">YTD Taxable :&nbsp;</td>
						<%
							if(vYTDInfo != null && vYTDInfo.size() > 0)
								strTemp = (String)vYTDInfo.elementAt(1);
							else
								strTemp = "";
						%>
						<td align="right" class="thinborderNONEcl"><strong><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</strong></td>
						<%
							if(vEmpIDs != null && vEmpIDs.size() > 0)
								strTemp = (String)vEmpIDs.elementAt(2);
							else
								strTemp = "";
						%>							
						<td align="right" class="thinborderNONEcl">PHILHEALTH :&nbsp;</td>
						<td class="thinborderNONEcl"><strong>&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
						<%
							if(vEmpIDs != null && vEmpIDs.size() > 0)
								strTemp = (String)vEmpIDs.elementAt(4);
							else
								strTemp = "";
						%>							
						<td align="right" class="thinborderNONEcl">PERAA :&nbsp;</td>
						<td class="thinborderNONEcl"><strong>&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
					</tr>
					<tr>
						<td align="right" class="thinborderNONEcl">YTD Tax Withheld :&nbsp;</td>
						<%
							if(vYTDInfo != null && vYTDInfo.size() > 0)
								strTemp = (String)vYTDInfo.elementAt(2);
							else
								strTemp = "";
						%>
						<td align="right" class="thinborderNONEcl"><strong><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</strong></td>
						<%
							if(vEmpIDs != null && vEmpIDs.size() > 0)
								strTemp = (String)vEmpIDs.elementAt(1);
							else
								strTemp = "";
						%>							
						<td align="right" class="thinborderNONEcl">TIN :&nbsp;</td>
						<td class="thinborderNONEcl"><strong>&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
						<td class="thinborderNONEcl">&nbsp;</td>
						<td class="thinborderNONEcl">&nbsp;</td>
					</tr>
				</table></td>
			</tr>
			<%}// for CLDH%>
		</table>
	<%}%>
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
</form>

<script src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//get this from common.js
this.autoPrint();
//window.setInterval("javascript:window.close();",0);
this.closeWnd = 1;
//or use this so that the window will not close
//window.setInterval("javascript:window.print();",0);
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>