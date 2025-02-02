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
</style>
</head>
<%
	String strSchCode =  (String)request.getSession(false).getAttribute("school_code");

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

	strSchCode = dbOP.getSchoolIndex();
	strEmployeeIndex = dbOP.mapUIDToUIndex(strEmpID);
	double[] adContributions = new double[6]; 	
	
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

	if(strSchCode.startsWith("CLDH") || strSchCode.startsWith("CLC")){
		vEmpLoans = PRRetLoan.getEmpLoansWithBalPay(dbOP,request);		
		if(strSchCode.startsWith("CLDH"))	
			vYTDInfo = rptPayExtn.getYTDInfo(dbOP,strEmployeeIndex);
	}
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
double dTempSalary = 0d;
double dAbsenceAmt = 0d;
double dOtherEarning = 0d;
double dHonorarium = 0d;
String[] astrPtFt = {"Part-Time","Full-Time",""};
String strGrossPayTotal = null;
String strPtFt = WI.fillTextValue("pt_ft");
//if (strSchCode.startsWith("CPU")){
//strGrossPayTotal = dbOP.mapOneToOther("pr_edtr_salary","is_valid","1", "sum(gross_salary)",
//						  " and user_index = " + strEmployeeIndex);
//}

strSlash = "";
if (strPtFt.length() == 0){
	strPtFt = dbOP.mapOneToOther("info_faculty_basic","is_valid","1", "pt_ft",
						  " and user_index = " + strEmployeeIndex);
	strPtFt = WI.getStrValue(strPtFt,"1");
}
%>
<body <%if(WI.fillTextValue("skip_print").length() == 0){%>onLoad="javascript:window.print()"<%}%>>
<form>
<%if(strSchCode.startsWith("VMUF") || strSchCode.startsWith("CLDH")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="30" colspan="5" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong>
				<%if(strSchCode.startsWith("VMUF")){%>
		<br><%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
		<%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false),",&nbsp;","","")%><br><br>	
		<%if(strSchCode.startsWith("VMUF")){%>
				Human Resources Development Office<br>
		Tel Nos. (075) 634-1111, (075) 531-2222 loc. 137/142
<br><br>
		<%}
		}%>
		</td>
		</tr>
	</table>
  <%if(strSchCode.startsWith("VMUF")){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="3" align="center"><strong>EMPLOYEE PAYROLL 
        SLIP</strong></td>
    </tr>	
  </table>
  <%} // ! CLDH%>
  <%if(strSchCode.startsWith("WNU")){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="49%" valign="top">
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">		
		<tr>
		  <td height="17" colspan="3" class="thinborderNONEcl"><table width="100%" border="0" cellspacing="0" cellpadding="0" id="header_">
        <tr>
          <td width="43%"><strong><%=WI.getStrValue(strEmpID,"","","")%></strong></td>
          <td width="57%"><%}// CLDH || VMUF %></td>
          </tr>
        <tr>
          <td colspan="2">&nbsp;<strong><u><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4).toUpperCase()%></u></strong></td>
          </tr>
        <tr>
          <td>&nbsp;</td> 
          <td><%=strPeriodEnding%></td>
          </tr>
      </table></td>
		  </tr>
		
		<tr> 
			<td width="51%" height="18" valign="top">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
						<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "INCOME";
							%>							
            <td width="60%" height="19"><strong><%=strTemp%></strong></td>
            <td width="40%">&nbsp;</td>
          </tr>
          <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Basic";
							%>					
            <td height="19"><font size="1">&nbsp;<%=strTemp%></font></td>
						<% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							strTemp = (String)vDTRManual.elementAt(38);			
							dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}
						%>						
            <td align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
          </tr>
          <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Overload";
							%>									
            <td height="19"><font size="1">&nbsp;<%=strTemp%></font></td>
					<% dTemp = 0d;
						if (vDTRManual != null && vDTRManual.size() > 0){ 
						// faculty pay
						strTemp = (String) vDTRManual.elementAt(44);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
		
						strTemp = (String) vDTRManual.elementAt(67);
						// manually encoded overload Amount
						dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
		
						dGrossSalary += dTemp; 
						}					
						strTemp = CommonUtil.formatFloat(dTemp,true);			
 					 %>						
            <td align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
          </tr>
          <tr>
						<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "COLA";
							%>						
            <td height="19"><font size="1">&nbsp;<%=strTemp%></font></td>
					 <% 			
						strTemp = (String) vDTRManual.elementAt(31);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dGrossSalary += dTemp;
					 %>						
            <td align="right"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</td>
          </tr>
          <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Sub/OT";
							%>							
            <td height="19"><font size="1">&nbsp;<%=strTemp%></font></td>
					<% dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						// OT
						strTemp = (String) vDTRManual.elementAt(10);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			

						strTemp = (String) vDTRManual.elementAt(60);
 						// sub teaching salary
						dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						// Night Differential
						strTemp = (String) vDTRManual.elementAt(25);
						dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							
						dGrossSalary += dTemp; 
					}	
					strTemp = CommonUtil.formatFloat(dTemp, true);
 					%>						
            <td align="right"> <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
          </tr>
           
					<tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Honorarium";
							%>							
					  <td height="19"><font size="1">&nbsp;<%=strTemp%></font></td>
					<%
					dHonorarium = 0d;
					dOtherEarning = 0d;
					
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						// Honorarium
						strTemp = (String)vDTRManual.elementAt(43);					
						dHonorarium = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
					}	

					if(vEarnings != null && vEarnings.size() > 1){
						for(i = 1; i < vEarnings.size(); i += 2) {
							strTemp = (String) vEarnings.elementAt(i+1);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = (String) vEarnings.elementAt(i);
							if(strTemp == null || strTemp.length() == 0){
								dOtherEarning += dTemp;
 							}else{
								if(strTemp.toLowerCase().indexOf("honorarium") != -1)
									dHonorarium += dTemp;	
								else
									dOtherEarning += dTemp;												
							}
						}// END FOR LOOP
					}// END NULL CHECK
					
					dGrossSalary += dHonorarium; 
					strTemp = CommonUtil.formatFloat(dHonorarium, true);
					%>							
					  <td align="right"><%=strTemp%>&nbsp;</td>
					</tr>					
					<tr>
						<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Other Allowances";
							%>						
						<td height="19"><font size="1">&nbsp;<%=strTemp%></font></td>
						<% //dOtherEarning = 0d;
							//if(vEarnings != null && vEarnings.size() > 1)
							//	dOtherEarning = Double.parseDouble((String)vEarnings.elementAt(0));
							
							if (vDTRManual != null && vDTRManual.size() > 0){ 	
								// adhoc bonus
								strTemp = (String) vDTRManual.elementAt(22);
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
								dOtherEarning += dTemp;

								// holiday pay
								strTemp = (String) vDTRManual.elementAt(26);
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
								dOtherEarning += dTemp;
							}
						
							strTemp = CommonUtil.formatFloat(dOtherEarning,2);
							dGrossSalary += dOtherEarning;
						%>							
						<td align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
					</tr>
          <tr>
							<%
								if(bolUsePrePrinted){
									strTemp = "&nbsp;";
									strBorder = "";
								}else{
									strTemp = "Adjustments";
									strBorder = "thinborderBOTTOMonly";
								}
							%>					
            <td height="19" class="<%=strBorder%>"><font size="1">&nbsp;<%=strTemp%></font></td>				
 				    <% dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp =(String) vDTRManual.elementAt(20);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						if (dTemp < 0d)
							strTemp = "(" + ConversionTable.replaceString((String) vDTRManual.elementAt(20),"-","") + ")";
						dGrossSalary += dTemp;
					}	
 					%>						
            <td align="right" class="<%=strBorder%>"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
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
						
						if(vEarnDed != null && vEarnDed.size() > 1){		
							strTemp = (String) vEarnDed.elementAt(0);
							dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
						}

						dGrossSalary -= dAbsenceAmt;						
					}
 						
				   %>	
					<tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Less : Absences";
							%>						
					  <td height="19" class="<%=strBorder%>"><font size="1">&nbsp;<%=strTemp%></font></td>
						<%
						strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);
						%>
					  <td align="right" class="<%=strBorder%>"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
				  </tr>
 					<tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Gross Pay";
							%>					
					  <td height="19" class="thinborderNONE"><font size="1">&nbsp;<%=strTemp%></font></td>
					  <td align="right"><%=CommonUtil.formatFloat(dGrossSalary, true)%>&nbsp;</td>
				  </tr>     

					<tr valign="bottom"> 
						<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "DEDUCTIONS";
							%>						
						<td height="25" colspan="2"><strong><%=strTemp%></strong></td>
					</tr>
					<tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "SSS Ee";
							%>						
						<td height="19" valign="bottom"><font size="1">&nbsp;<%=strTemp%></font></td>
						<td align="right" valign="bottom">
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
						<%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
					</tr>
					<tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Phil Health";
							%>							
						<td height="19" valign="bottom"><font size="1">&nbsp;<%=strTemp%></font></td>
						<td align="right" valign="bottom">
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
						<%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
				  </tr>
					<tr> 
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Wtax";
							%>						
						<td height="19" valign="bottom"><font size="1">&nbsp;<%=strTemp%></font></td>
						<td align="right" valign="bottom">
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
							<%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
				  </tr>
					<%if(bolIsSchool){%>
					<tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "PERAA";
							%>					
						<td height="19" valign="bottom"><font size="1">&nbsp;<%=strTemp%></font></td>
						<td align="right" valign="bottom">
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
						<%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
				  </tr>
					<%} // end if(bolIsSchool)%>
					<tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Pag-IBIG";
							//System.out.println("dOtherDeduction " + dTotalDeduction);
							%>						
							
						<td height="19" valign="bottom"><font size="1">&nbsp;<%=strTemp%></font></td>
						<td align="right" valign="bottom">
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
							<%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
				  </tr>					
				</table>				 </td>
			<td width="1%" valign="top">&nbsp;</td>
			<td width="48%" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
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
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
							%>					
          <td height="19" valign="bottom"><font size="1">&nbsp;<%=WI.getStrValue(strTemp,"")%></font></td>
				 <% 
					strTemp = CommonUtil.formatFloat(dTemp,true);
					dTotalDeduction += dTemp; 
				 %>
          <td align="right" valign="bottom"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
        </tr>
        <%}
					}%>
				<tr>
							<%
								if(bolUsePrePrinted){
									strTemp = "&nbsp;";
									strBorder = "";
								}else{
									strTemp = "Other/Misc.";
									strBorder = "thinborderBOTTOMonly";
								}
							%>					
              <td height="19" valign="bottom" class="<%=strBorder%>"><font size="1">&nbsp;<%=strTemp%></font></td>
              <% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 	
						strTemp = (String) vDTRManual.elementAt(18);//MISC_DEDUCTION (Addl ded)
						dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					}
						strTemp = CommonUtil.formatFloat(dOtherDeduction,true);
						dTotalDeduction += dOtherDeduction; 
					%>
              <td align="right" valign="bottom" class="<%=strBorder%>"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
        </tr>
        <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Total Ded.";
							%>					
          <td width="51%" height="19" class="<%=strBorder%>"><!--Total Ded.-->
            <font size="1">&nbsp;<%=strTemp%></font></td>
          <td width="49%" align="right" class="<%=strBorder%>">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%>&nbsp;</td>
        </tr>
        <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "NET PAY";
							%>					
          <td height="19" class="<%=strBorder%>"><!--NET PAY -->
            <font size="1">&nbsp;<%=strTemp%></font></td>
					<%
 						dNetSalary += dGrossSalary - dTotalDeduction;
					%>					
          <td align="right" nowrap class="<%=strBorder%>"><u><strong>*<%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%>&nbsp;</strong></u></td>
        </tr>
      </table></td>
		</tr>
		<tr>
		  <td height="18" colspan="3" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="48%" height="59" valign="bottom">&nbsp;<strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4).toUpperCase()%></strong></td>
          <td width="4%">&nbsp;</td>
          <td width="48%">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
      </table></td>
		  </tr>
	</table>		</td>
		<td width="1%">&nbsp;</td>
		<%
			dGrossSalary = 0d;
			dNetSalary = 0d;
			dTotalDeduction	= 0d;	
		%>
    <td width="49%" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
      <tr>
        <td height="17" colspan="3" class="thinborderNONEcl"><table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td width="43%"><strong><%=WI.getStrValue(strEmpID,"","","")%></strong></td>
              <td width="57%">&nbsp;</td>
            </tr>
            <tr>
              <td colspan="2">&nbsp;<strong><u><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4).toUpperCase()%></u></strong></td>
            </tr>
            <tr>
              <td>&nbsp;</td> 
              <td><%=strPeriodEnding%></td>
            </tr>
        </table></td>
      </tr>
      
      <tr>
        <td width="51%" height="18" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
						<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "INCOME";
							%>								
              <td height="19" width="60%" ><strong><%=strTemp%></strong></td>
              <td width="40%" >&nbsp;</td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Basic";
							%>
              <td height="19"><font size="1">&nbsp;<%=strTemp%></font></td>
              <% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							strTemp = (String)vDTRManual.elementAt(38);			
							dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}
						%>
              <td align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Overload";
							%>						
              <td height="19"><font size="1">&nbsp;<%=strTemp%></font></td>
              <% dTemp = 0d;
						if (vDTRManual != null && vDTRManual.size() > 0){ 
						// faculty pay
						strTemp = (String) vDTRManual.elementAt(44);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
		
						strTemp = (String) vDTRManual.elementAt(67);
						// manually encoded overload Amount
						dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
		
						dGrossSalary += dTemp; 
						}					
						strTemp = CommonUtil.formatFloat(dTemp,true);			
 					 %>
              <td align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "COLA";
							%>							
              <td height="19"><font size="1">&nbsp;<%=strTemp%></font></td>
              <% 			
						strTemp = (String) vDTRManual.elementAt(31);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dGrossSalary += dTemp;
					 %>
              <td align="right"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Sub/OT";
							%>							
              <td height="19"><font size="1">&nbsp;<%=strTemp%></font></td>
              <% dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						// OT
						strTemp = (String) vDTRManual.elementAt(10);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			

						strTemp = (String) vDTRManual.elementAt(60);
						// sub teaching salary
						dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						// Night Differential
						strTemp = (String) vDTRManual.elementAt(25);
						dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							
						dGrossSalary += dTemp; 
					}	
					strTemp = CommonUtil.formatFloat(dTemp, true);
 					%>
              <td align="right"> <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Honorarium";
							%>							
              <td height="19"><font size="1">&nbsp;<%=strTemp%></font></td>
              <%
					dHonorarium = 0d;
					dOtherEarning = 0d;
					
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						// Honorarium
						strTemp = (String)vDTRManual.elementAt(43);					
						dHonorarium = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
					}	

					if(vEarnings != null && vEarnings.size() > 1){
						for(i = 1; i < vEarnings.size(); i += 2) {
							strTemp = (String) vEarnings.elementAt(i+1);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = (String) vEarnings.elementAt(i);
							if(strTemp == null || strTemp.length() == 0){
								dOtherEarning += dTemp;
								continue;
							}else{
								if(strTemp.toLowerCase().indexOf("honorarium") != -1)
									dHonorarium += dTemp;	
								else
									dOtherEarning += dTemp;												
							}
						}// END FOR LOOP
					}// END NULL CHECK
					
					dGrossSalary += dHonorarium; 
					strTemp = CommonUtil.formatFloat(dHonorarium, true);
					%>	
              <td align="right"><%=strTemp%>&nbsp;</td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Other Allowances";
							%>							
              <td height="19"><font size="1">&nbsp;<%=strTemp%></font></td>
              <% //dOtherEarning = 0d;
							//if(vEarnings != null && vEarnings.size() > 1)
							//	dOtherEarning = Double.parseDouble((String)vEarnings.elementAt(0));
							
							if (vDTRManual != null && vDTRManual.size() > 0){ 	
								// adhoc bonus
								strTemp = (String) vDTRManual.elementAt(22);
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
								dOtherEarning += dTemp;

								// holiday pay
								strTemp = (String) vDTRManual.elementAt(26);
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
								dOtherEarning += dTemp;
							}
						
							strTemp = CommonUtil.formatFloat(dOtherEarning,2);
							dGrossSalary += dOtherEarning;
						%>
              <td align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Adjustments";
							%>							
              <td height="19" class="<%=strBorder%>"><font size="1">&nbsp;<%=strTemp%></font></td>
              <% dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp =(String) vDTRManual.elementAt(20);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						if (dTemp < 0d)
							strTemp = "(" + ConversionTable.replaceString((String) vDTRManual.elementAt(20),"-","") + ")";
						dGrossSalary += dTemp;
					}	
 					%>
              <td align="right" class="<%=strBorder%>"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
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
						
						if(vEarnDed != null && vEarnDed.size() > 1){		
							strTemp = (String) vEarnDed.elementAt(0);
							dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
						}

						dGrossSalary -= dAbsenceAmt;						
					}
 						
				   %>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Less : Absences";
							%>							
              <td height="19" class="<%=strBorder%>"><font size="1">&nbsp;<%=strTemp%></font></td>
							<%
								strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);
							%>
              <td align="right" class="<%=strBorder%>"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Gross Pay";
							%>							
              <td height="19" class="thinborderNONE"><font size="1">&nbsp;<%=strTemp%></font></td>
              <td align="right"><%=CommonUtil.formatFloat(dGrossSalary, true)%>&nbsp;</td>
            </tr>
            <tr valign="bottom">
						<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "DEDUCTIONS";
							%>								
              <td height="25" colspan="2"><strong><%=strTemp%></strong></td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "SSS Ee";
							%>											
              <td height="19" valign="bottom"><font size="1">&nbsp;<%=strTemp%></font></td>
              <td align="right" valign="bottom">
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
                <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Phil Health";
							%>											
               <td height="19" valign="bottom"><font size="1"> &nbsp;<%=strTemp%></font></td>
              <td align="right" valign="bottom">
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
                <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Wtax";
							%>											
               <td height="19" valign="bottom"><font size="1">&nbsp;<%=strTemp%></font></td>
              <td align="right" valign="bottom">
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
                <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            </tr>
            <%if(bolIsSchool){%>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "PERAA";
							%>											
              <td height="19" valign="bottom"><font size="1">&nbsp;<%=strTemp%></font></td>
              <td align="right" valign="bottom">
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
                <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            </tr>
            <%} // end if(bolIsSchool)%>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Pag-IBIG";
							%>											
               <td height="19" valign="bottom"><font size="1">&nbsp;<%=strTemp%></font></td>
              <td align="right" valign="bottom">
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
                <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            </tr>
        </table></td>
        <td width="1%" valign="top">&nbsp;</td>
        <td width="48%" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
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
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
							%>											
               <td width="70%" height="19" valign="bottom"><font size="1">&nbsp;<%=strTemp%></font></td>
               <td width="30%" align="right" valign="bottom"><% 
						strTemp = CommonUtil.formatFloat(dTemp,true);
						dTotalDeduction += dTemp; 
					 %>
                <%=WI.getStrValue(strTemp,"")%></td>
            </tr>
            <%}
					}%>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Other/Misc.";
							%>											
               <td height="19" valign="bottom" class="<%=strBorder%>"><font size="1">&nbsp;<%=strTemp%></font></td>
              <% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 	
						strTemp = (String) vDTRManual.elementAt(18);//MISC_DEDUCTION (Addl ded)
						dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					}
						strTemp = CommonUtil.formatFloat(dOtherDeduction,true);
						dTotalDeduction += dOtherDeduction; 
					%>
              <td align="right" valign="bottom" class="<%=strBorder%>"><%=WI.getStrValue(strTemp,"")%></td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "Total Ded.";
							%>								
              <td height="19" class="<%=strBorder%>"><font size="1">&nbsp;<%=strTemp%></font></td>
              <td align="right" class="<%=strBorder%>">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%></td>
            </tr>
            <tr>
							<%
								if(bolUsePrePrinted)
									strTemp = "&nbsp;";
								else
									strTemp = "NET PAY";
							%>							
              <td height="19" class="<%=strBorder%>"><font size="1">&nbsp;<%=strTemp%></font></td>
              <%
						dNetSalary += dGrossSalary - dTotalDeduction;
						%>
              <td align="right" nowrap class="<%=strBorder%>"><u><strong>*<%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%></strong></u></td>
            </tr>
        </table></td>
      </tr>
      <tr>
        <td height="18" colspan="3" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td width="48%" height="58" valign="bottom">&nbsp;<strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4).toUpperCase()%></strong></td>
              <td width="4%">&nbsp;</td>
              <td width="48%">&nbsp;</td>
            </tr>
            <!--
						<tr>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
            </tr>
						-->
        </table></td>
      </tr>
    </table>		</td> 
    <td width="1%">&nbsp;</td>
  </tr>
</table>
 <!-- AUF payslip moved to payroll_slip_print_sch.jsp -->
 <!-- PIT payslip moved to payroll_slip_print_sch.jsp --> 
 <%}else if(strSchCode.startsWith("TSUNEISHI")){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
       <td colspan="5" class="thinborderNONE"><table width="100%" border="0" cellspacing="0" cellpadding="0">
         <tr>
           <td colspan="3"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></td>
           <td width="28%">PAYSLIP</td>
          </tr>
         <tr>
           <td width="8%">Name</td>
           <td width="41%">: <%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4).toUpperCase()%></td>
           <td width="23%">&nbsp;</td>
           <td>Period Ending : <%=strPeriodEnding%></td>
          </tr>
         <tr>
           <td>ID No. </td>
           <td>: <%=WI.getStrValue(strEmpID,"")%></td>
           <td>&nbsp;</td>
           <td>&nbsp;</td>
          </tr>
         <tr>
           <td>Div</td>
           <td>: <%=WI.getStrValue((String)vPersonalDetails.elementAt(13),"")%></td>
           <td colspan="2">Dept : <%=WI.getStrValue((String)vPersonalDetails.elementAt(14),"")%></td>
          </tr>
       </table></td>
     </tr>
     <tr>
       <td colspan="5" class="thinborderBOTTOM">&nbsp;</td>
     </tr>          
     <tr>
       <td colspan="2" valign="top" class="thinborderLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           <tr>
             <td colspan="2" class="thinborderNONE" height="18">Regular Earnings:</td>
           </tr>
           <tr>
             <td width="48%" class="thinborderNONE" height="16">&nbsp;</td>
             <td width="52%" class="thinborderNONE">&nbsp;</td>
           </tr>
           <tr>
             <td class="thinborderNONE" height="16">Basic Pay </td>
						<%
							if(vDTRManual != null && vDTRManual.size() > 0)
								strTemp = (String)vDTRManual.elementAt(38);

							if (vDTRDetails != null && vDTRDetails.size() > 0)
								strTemp = WI.getStrValue(strTemp, (String)vDTRDetails.elementAt(26));
								
							dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						%>
             <td class="thinborderNONE"><div align="right">
					 <%
						//if (vDTRDetails != null && vDTRDetails.size() > 0){ 
						//	strTemp = (String)vDTRDetails.elementAt(17);	
						//	dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						//}
						%>
                 <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</div></td>
           </tr>            
					 <% dTemp = 0d;
 					 if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String) vDTRManual.elementAt(26);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dGrossSalary += dTemp; 
					 }	
					 if(dTemp > 0d){				
					 %>
           <tr>
             <td class="thinborderNONE" height="16">Holiday pay </td>
             <td class="thinborderNONE"><div align="right"> <font size="1">
               <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</font></div></td>
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
             <td class="thinborderNONE" height="16">Overtime</td>
             <td class="thinborderNONE"><div align="right"> <font size="1">
               <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</font></div></td>
           </tr>
					 <%}%>
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
             <td class="thinborderNONE" height="16">Night Differential </td>
             <td class="thinborderNONE"><div align="right"><font size="1"> <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</font></div></td>
           </tr>
           <%}%>
				 <% 
				 	// COLA
					dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() >  0){ 	
						strTemp = (String) vDTRManual.elementAt(31);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dGrossSalary += dTemp; 
					}
					 
					if(dTemp > 0d){
 					%>
           <tr>
             <td class="thinborderNONE" height="16">COLA</td>
             <td class="thinborderNONE"><div align="right"><font size="1"> <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</font></div></td>
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
            <td  height="16" class="thinborderNONE"><%=strTemp%></td>
            <td align="right" class="thinborderNONE">
            <% 
								strTemp = CommonUtil.formatFloat(dTemp,true);
								dGrossSalary += dTemp; 
								if(dTemp == 0d)
									strTemp = "";				
 						    %>
            <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
          </tr>
					<%}// END FOR LOOP
					}// END NULL CHECK%>
           <tr>
             <td class="thinborderNONE" height="16">Less: Abs/UT/Late</td>
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
             <td class="thinborderNONE"><div align="right"><%=strTemp%>&nbsp;&nbsp;</div></td>
           </tr>
           <tr>
             <td class="thinborderNONE" height="12">&nbsp;</td>
             <td class="thinborderNONE">&nbsp;</td>
           </tr>
           <tr>
             <td class="thinborderNONE" height="16"> Gross Pay </td>
             <td class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dGrossSalary,true)%>&nbsp;&nbsp;</div></td>
           </tr>
				<%
						strTemp =(String) vDTRManual.elementAt(20);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						if (dTemp < 0d){
							strTemp = "(" + ConversionTable.replaceString((String) vDTRManual.elementAt(20),"-","") + ")";							
						}
					if(dTemp != 0d){
						dGrossSalary += dTemp;
			   %>           
					 <tr>
             <td class="thinborderNONE" height="16">Adjustment</td>
             <td align="right" class="thinborderNONE"><%=strTemp%>&nbsp;</td>
           </tr>
					 <%}%>
           <tr>
             <td class="thinborderNONE" height="16">Others</td>
						 
						 <%
							// addl pay amount
							strTemp = (String) vDTRManual.elementAt(17);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							dGrossSalary += dTemp;
							
							// addl bonus amount
							strTemp = (String) vDTRManual.elementAt(22);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							dGrossSalary += dTemp;								
							
							dGrossSalary += dOtherEarning;
						 %>
						 
             <td class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dOtherEarning,true)%>&nbsp;&nbsp;</div></td>
           </tr>
       </table></td>
       <td colspan="2" valign="top" class="thinborderLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           <tr>
             <td colspan="2" class="thinborderNONE" height="18"><strong>Regular Deductions</strong></td>
           </tr>
           <tr>
             <td width="56%" class="thinborderNONE" height="16">&nbsp;Tax Withheld</td>
             <td width="44%" class="thinborderNONE"><div align="right">
                 <% 
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(24);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
				dSubTotalDed += dTemp; 
				strTemp = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "";
			}	
		   %>
                 <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</div></td>
           </tr>
					<% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							strTemp = (String) vDTRManual.elementAt(12);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = CommonUtil.formatFloat(strTemp,true);
							dSubTotalDed += dTemp; 
						}	
						if(dTemp > 0d){
					 %>
           <tr>
             <td class="thinborderNONE" height="16"> &nbsp;SSS premium</td>
             <td class="thinborderNONE"><div align="right">
                 <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</div></td>
           </tr>
					 <%}%>
           <% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							strTemp = (String) vDTRManual.elementAt(61);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = CommonUtil.formatFloat(strTemp,true);
							dSubTotalDed += dTemp; 
						}	
						if(dTemp > 0d){
					 %>
           <tr>
             <td class="thinborderNONE" height="16"> &nbsp;GSIS premium</td>
             <td class="thinborderNONE"><div align="right">
                 <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</div></td>
           </tr>
					 <%}%>
           <tr>
             <td class="thinborderNONE" height="16">&nbsp;Phil. Health</td>
             <td class="thinborderNONE"><div align="right">
                 <% 
		if (vDTRManual != null && vDTRManual.size() > 0){ 
			strTemp = (String) vDTRManual.elementAt(13);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
			strTemp = CommonUtil.formatFloat(strTemp,true);
			dSubTotalDed += dTemp; 
			if(dTemp == 0d)
				strTemp = "";			
		}	
	   %>
                 <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</div></td>
           </tr>
           <tr>
             <td class="thinborderNONE" height="16"> &nbsp;Pag-ibig Premium</td>
             <td class="thinborderNONE"><div align="right">
            <% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							strTemp = (String) vDTRManual.elementAt(14);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = CommonUtil.formatFloat(strTemp,true);
							dSubTotalDed += dTemp; 
							if(dTemp == 0d)
								strTemp = "";
						}	
						 %>
                 <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</div></td>
           </tr>
           <% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							strTemp = (String) vDTRManual.elementAt(54); // Ret. Plan Fund
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = CommonUtil.formatFloat(strTemp,true);
							dSubTotalDed += dTemp; 
							dTotalDeduction = dSubTotalDed;
						}	
						if(dTemp > 0d){
					 %>
           <tr>
             <td class="thinborderNONE" height="18">&nbsp;Ret. Plan Fund</td>
             <td class="thinborderNONE"><div align="right">
                 <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</div></td>
           </tr>
					 <%}%>
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
             <td width="50%" class="thinborderNONE" height="16">&nbsp;<%=WI.getStrValue(strTemp,"")%></td>
             <td width="50%" align="right" class="thinborderNONE">
              <% 
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
             <td class="thinborderNONE" height="16">Others</td>
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
       <td valign="top" class="thinborderBOTTOMLEFTRIGHT">I acknowledge receipt of the amount stated below </td>
     </tr>
     <tr>
       <td colspan="2" valign="top" class="thinborderBOTTOMLEFT">&nbsp;</td>
       <td colspan="2" valign="top" class="thinborderBOTTOMLEFT">&nbsp;</td>
       <td align="center" valign="top" class="thinborderBOTTOMLEFTRIGHT">SIGNATURE</td>
     </tr>
     <tr>
       <td width="12%" valign="top" class="thinborderBOTTOMLEFT" height="16"><span class="thinborderNONE">TOTAL INCOME </span></td>
       <td width="13%" valign="top" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dGrossSalary,true)%>&nbsp;</div></td>
       <td width="14%" valign="top" class="thinborderBOTTOMLEFT">TOTAL DEDUCTIONS </td>
       <td width="11%" align="right" valign="top" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalDeduction,true)%>&nbsp;</td>
       <td width="12%" valign="top" class="thinborderBOTTOMLEFTRIGHT">
			 <table width="100%" border="0" cellspacing="0" cellpadding="0">
				 <tr>
					 <td width="50%" align="right" class="thinborderNONE">NET PAY </td>
					 <%dNetSalary = dGrossSalary-dTotalDeduction;%>
					 <td width="50%" class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dNetSalary,true)%>&nbsp;</div></td>
				 </tr>
       </table>			 </td>
     </tr>
     <tr>
       <td colspan="5"></td>
     </tr>
  </table>
	 <%if(vEmpLoans != null && vEmpLoans.size() > 0){
	 	int iCol = 0;
	 %>
	 <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			<tr>
				<td colspan="6" class="thinborderBOTTOM">LOAN DETAILS</td>
			</tr>
			<tr>
				<td width="19%" class="thinborder">&nbsp;</td>
				<td width="17%" align="center" class="thinborder">Principal Amt</td>
				<td width="15%" align="center" class="thinborderBOTTOMLEFTRIGHT">Balance</td>
			  <td width="17%" align="center" class="thinborder">&nbsp;</td>
			  <td width="16%" align="center" class="thinborder">Principal Amt</td>
			  <td width="16%" align="center" class="thinborderBOTTOMLEFTRIGHT">Balance</td>
			</tr>
			<%for(i = 0; i < vEmpLoans.size();){
				iCol = 0;
			%>			
 			<tr>				
				<%
				for(; i < vEmpLoans.size() && iCol < 2;i+=9, iCol++){
				%>
								
				<%
					strTemp = (String)vEmpLoans.elementAt(i+7);
				%>
				<td class="thinborder" height="19">&nbsp;&nbsp;<%=strTemp%></td>
				<%
					strTemp = (String)vEmpLoans.elementAt(i+3);
				%>
				<td align="right" class="thinborder"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
				<%
					strTemp = (String)vEmpLoans.elementAt(i+4);
				%>										
				<td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
				<%}%>
				<%while(iCol < 2){
						iCol ++;
				%>
			  <td align="right" class="thinborder">&nbsp;</td>
			  <td align="right" class="thinborder">&nbsp;</td>
			  <td align="right" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
				<%}%>
 			</tr>
			<%}%>
	</table>	 	 
		<%}%>
 <%}else if(strSchCode.startsWith("TAMIYA")){
 	////////////// This is a temporary fix for getting the Dept Code \\\\\\\\\|
	/*
		I just run the query here because sir B cant give the enrollment.authentication where
		the other details like dept name are coming from.
		sul09182012
	*/ 
 	String strDeptCode = "";	
	ResultSet rs = null;
	try{
		//System.out.println ("13 " + WI.getStrValue((String)vPersonalDetails.elementAt(13),""));
		//System.out.println ("14 " + WI.getStrValue((String)vPersonalDetails.elementAt(14),""));
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(13),WI.getStrValue((String)vPersonalDetails.elementAt(14),""));
		if(strTemp.length() > 0){
			strTemp = "select C_CODE from COLLEGE where C_NAME = '" + strTemp + "'";
			rs = dbOP.executeQuery(strTemp);
			if(rs.next())
				strDeptCode = rs.getString(1);				
			rs.close();
		}	
		
	}catch (Exception ex) {
       //do nothing
	   strDeptCode = "";
	   if(rs != null)
	   		rs.close();
    }
	////////////// end of getting the Dept Code \\\\\\\\\|		
 	dOtherEarning = 0d;
 %>
<table width="100%" border="0" cellspacing="10" cellpadding="0">
     
     <tr>
       <td colspan="4" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
         <tr>
           <td colspan="3"><strong>PAYSLIP</strong></td>
           <td width="33%">&nbsp;</td>
          </tr>
         
         <tr>
           <td width="8%">Period</td>
           <td width="45%">&nbsp;<font size="1"><%=WI.getStrValue(strCutOff,"")%></font></td>
           <td width="14%">Employee ID </td>
           <td><%=WI.getStrValue(strEmpID,"")%></td>
          </tr>
         <tr>
           <td>Group</td>
           <td>&nbsp;Tamiya (Phils.) Inc.:
		   <%=WI.getStrValue(strDeptCode,WI.getStrValue((String)vPersonalDetails.elementAt(13),""))%> 
		    <%// tamiya wants dept code nly not dept name like below%>		   
		   	<%//=WI.getStrValue((String)vPersonalDetails.elementAt(13),"")%>
			<%//=WI.getStrValue((String)vPersonalDetails.elementAt(14),"")%>
		   </td>
           <td>Name</td>
           <td><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4).toUpperCase()%></td>
          </tr>
         
       </table></td>
     </tr>
     
     
     <tr>
       <td valign="top" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
         
         <tr>
           <td width="51%" height="16" class="thinborderNONE"><strong>A. Basic</strong></td>
           <td width="49%" align="right" class="thinborderNONE">
              <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){ 
			strTemp = (String)vDTRDetails.elementAt(17);	
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}
		%>
              <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
         </tr>
         <% dTemp = 0d;
 					 if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String) vDTRManual.elementAt(26);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dGrossSalary += dTemp; 
					 }	
					 %>
         <tr>
           <td height="16" class="thinborderNONE"><strong>B. Holiday</strong></td>
           <td align="right" class="thinborderNONE"> <font size="1"> <%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
         </tr>        
         <tr>
           <td height="16" class="thinborderNONE"><strong>C. Leave</strong></td>
           <td align="right" class="thinborderNONE"><div align="right"></div></td>
         </tr>
         <% dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String) vDTRManual.elementAt(10);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dGrossSalary += dTemp; 
					}	
				 %>
         <tr>
           <td height="16" class="thinborderNONE"><strong>D. Overtime</strong></td>
           <td align="right" class="thinborderNONE"> <font size="1"> <%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%>&nbsp;</font></td>
         </tr>
				 <% 
					dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() >  0){ 	
						strTemp = (String) vDTRManual.elementAt(25);// night differential
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dGrossSalary += dTemp; 
					}
					if(dTemp > 0d){
						strTemp = "";
					%>
         <tr>
           <td class="thinborderNONE" height="16">Night Differential </td>
           <td align="right" class="thinborderNONE"><font size="1"> <%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%>&nbsp;</font></td>
         </tr>         
         <%}%>
				 <tr>
           <td height="16" colspan="2" class="thinborderNONE">
					 <%if(vOTWithType != null && vOTWithType.size() > 0){  %>
					<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="44%">&nbsp;</td>
            <td align="center" width="22%" ><font size="1">HRS</font></td>
            <td align="center" width="34%"><font size="1">Amount</font></td>
            </tr>
					<%
					/**
					IMPORTANT!
					change 
						for(i = 1; i < vOTWithType.size(); i+=11){			
					to
						for(i = 1; i < vOTWithType.size(); i+=20){			
					if you updated the PRSalary.class after Sir Harvy's last update to Tamiya.
					This is because, the current PRSalary.java (which was given by sir Biswa),
					has different vector size. So, the update of the class was 
					not been applied here.
					
					In short, if you try to update the PRSalary.class using Sir Biswa's or
					my copy, make sure to change the loop to 
						for(i = 1; i < vOTWithType.size(); i+=20){	
						
					PS: This can also be observed in dtr_manual.jsp							
					
					sul08302012	
					*/
 					for(i = 1; i < vOTWithType.size(); i+=20){						
						strTemp = (String)vOTWithType.elementAt(i+5);
						strTemp = ConversionTable.replaceString(strTemp, ",","");
						dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
						if(dTemp > 0){
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
         
         <%}// END FOR LOOP
					}// END NULL CHECK%>
         
       </table></td>
       <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
			 <tr>
				 <td  height="16" class="thinborderNONE"><strong>E. Allowances</strong></td>
				 <td align="right" class="thinborderNONE">&nbsp;</td>
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
           <td width="53%"  height="16" class="thinborderNONE">&nbsp;&nbsp;&nbsp;<%=strTemp%></td>
           <td width="47%" align="right" class="thinborderNONE"><% 
								strTemp = CommonUtil.formatFloat(dTemp,true);
								dGrossSalary += dTemp; 
								if(dTemp == 0d)
									strTemp = "";				
 						    %>
               <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
         </tr>
         <%}// END FOR LOOP
					}// END NULL CHECK%>         
         <tr>
           <td height="16" class="thinborderNONE"><strong>F. Other Income</strong></td>
           <%
							// addl pay amount
							strTemp = (String) vDTRManual.elementAt(17);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							dGrossSalary += dTemp;
							
							// addl bonus amount
							strTemp = (String) vDTRManual.elementAt(22);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							dGrossSalary += dTemp;								
							
							dGrossSalary += dOtherEarning;
						 %>
           <td class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dOtherEarning,true)%>&nbsp;&nbsp;</div></td>
         </tr>
				 <tr>
           <td height="16" class="thinborderNONE"><strong>G. Absences</strong></td>
           <% 			
			if (vDTRManual != null && vDTRManual.size() > 0){ 
			// leave without pay			
				strTemp = (String) vDTRManual.elementAt(11);
				dAbsenceAmt = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			// AWOL
				strTemp = (String) vDTRManual.elementAt(32);
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
           <td class="thinborderNONE"><div align="right"><%=strTemp%>&nbsp;&nbsp;</div></td>
         </tr>				 
         
       </table></td>
       <td valign="top" class="thinborderNONE"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           
           <tr>
             <td height="16" colspan="2" class="thinborderNONE"><strong>H. Tardiness/Undertime</strong></td>
             <% 			
						if (vDTRManual != null && vDTRManual.size() > 0){ 
						// Late and undertime
							strTemp = (String) vDTRManual.elementAt(33);
							dAbsenceAmt = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			
							dGrossSalary -= dAbsenceAmt;
							if(dAbsenceAmt > 0)
								strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);
							else
								strTemp = "-";
						}	
						 %>
             <td align="right" class="thinborderNONE"><%=strTemp%>&nbsp;&nbsp;</td>
           </tr>
           <tr>
             <td height="16" colspan="2" class="thinborderNONE"><strong>I. Gov't. Deductions </strong></td>
             <%
							if (vDTRManual != null && vDTRManual.size() > 0){ 
								// tax
								strTemp = (String) vDTRManual.elementAt(24);
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
								dSubTotalDed += dTemp; 
								adContributions[0] = dTemp;
								
								// SSS
								strTemp = (String) vDTRManual.elementAt(12);
 								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
								adContributions[1] = dTemp;

								// GSIS
								strTemp = (String) vDTRManual.elementAt(61);
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
								adContributions[2] = dTemp;
								
								// Phealth								
								strTemp = (String) vDTRManual.elementAt(13);
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
								adContributions[3] = dTemp;

								// hdmf
								strTemp = (String) vDTRManual.elementAt(14);
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
								adContributions[4] = dTemp;
								
								// PERAA or ret. plan fund
								strTemp = (String) vDTRManual.elementAt(54); // Ret. Plan Fund
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));										
								adContributions[5] = dTemp;
							}
							dTemp = 0d;
							for(i = 0; i < adContributions.length;i++){
								dTemp += adContributions[i];
							}
							dTotalDeduction = dTemp;
						 %>
						 <td align="right" class="thinborderNONE"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;&nbsp;</td>
           </tr>
           <tr>
             <td width="5%" class="thinborderNONE">&nbsp;</td>
             <td width="62%" class="thinborderNONE" height="16">&nbsp;&nbsp;W. Tax</td>
						 <%
						 	strTemp = CommonUtil.formatFloat(adContributions[0],true);
						 %>
             <td width="33%" align="right" class="thinborderNONE"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%>&nbsp;&nbsp;</td>
           </tr> 
           <tr>
             <td class="thinborderNONE">&nbsp;</td>
             <td class="thinborderNONE" height="16">&nbsp;&nbsp;SSS premium</td>
						 <%
						 	strTemp = CommonUtil.formatFloat(adContributions[1],true);
						 %>
             <td align="right" class="thinborderNONE">
                <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
					 <%if(adContributions[2] > 0d){%>
           <tr>
             <td class="thinborderNONE">&nbsp;</td>
						 <%						 	
						 	strTemp = CommonUtil.formatFloat(adContributions[2],true);
						 %>
             <td class="thinborderNONE" height="16">&nbsp;&nbsp;GSIS premium</td>
             <td align="right" class="thinborderNONE">
                <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
					 <%}%>
           <tr>
             <td class="thinborderNONE">&nbsp;</td>
             <td class="thinborderNONE" height="16">&nbsp;&nbsp;Phil. Health</td>
						 <%						 	
						 	strTemp = CommonUtil.formatFloat(adContributions[3],true);
						 %>
             <td align="right" class="thinborderNONE"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
           <tr>
             <td class="thinborderNONE">&nbsp;</td>
             <td class="thinborderNONE" height="16">&nbsp;&nbsp;Pag-ibig Premium</td>
						 <%						 	
						 	strTemp = CommonUtil.formatFloat(adContributions[4],true);
						 %>
             <td align="right" class="thinborderNONE"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
					 <%if(adContributions[5] > 0d){%>
           <tr>
             <td class="thinborderNONE">&nbsp;</td>
             <td class="thinborderNONE" height="18">&nbsp;&nbsp;Ret. Plan Fund</td>
						 <%						 	
						 	strTemp = CommonUtil.formatFloat(adContributions[5],true);
						 %>
             <td align="right" class="thinborderNONE"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
					 <%}%>
       </table></td>
       <td valign="top" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
          
         <tr>
           <td height="16" class="thinborderNONE"><strong>J. Other Deductions </strong></td>
         <%
					if(vDeductions != null && vDeductions.size() > 1){
						dOtherDeduction = 0d;
						for(i = 1; i < vDeductions.size(); i += 2) {
							strTemp = (String) vDeductions.elementAt(i+1);
							dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						}
					}

					if (vDTRManual != null && vDTRManual.size() > 0){ 	
						strTemp = (String) vDTRManual.elementAt(18);//MISC_DEDUCTION (Addl ded)
						dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					}
					dTotalDeduction += dOtherDeduction;
					%>					 
           <td align="right" class="thinborderNONE"><%=CommonUtil.formatFloat(dOtherDeduction, true)%>&nbsp;</td>
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
           <td width="57%" class="thinborderNONE" height="16">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strTemp,"")%></td>
           <td width="43%" align="right" class="thinborderNONE"><% 
							strTemp = CommonUtil.formatFloat(dTemp,true);
 							if(dTemp == 0d)
								strTemp = "";				
						 %>
               <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
         </tr>
         <%}// end for loop
						}// end null check%>
         <tr>
           <td class="thinborderNONE" height="16">&nbsp;&nbsp;&nbsp;Others</td>
           <% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 	
							strTemp = (String) vDTRManual.elementAt(18);//MISC_DEDUCTION (Addl ded)
							dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}
							strTemp = CommonUtil.formatFloat(dOtherDeduction,2);
 							if(dOtherDeduction == 0d)
								strTemp = "";						
						%>
           <td align="right" class="thinborderNONE"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%>&nbsp;</td>
         </tr>
         <tr>
           <td height="16" class="thinborderNONE"><strong>K. Total Deductions </strong></td>
           <td align="right" class="thinborderNONE"><%=CommonUtil.formatFloat(dTotalDeduction,true)%>&nbsp;</td>
         </tr>
       </table></td>
     </tr>
     
     <tr>
       <td valign="top">&nbsp;</td>
       <td valign="top">&nbsp;</td>
       <td valign="bottom">
			 <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderALL">
         <tr>
           <td width="54%" class="thinborderNONE">&nbsp;Gross Pay :</td>
           <td width="46%" align="right" class="thinborderNONE"><font size="1"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%>&nbsp;</strong></font></td>
          </tr>
         <tr>
           <td height="18" class="thinborderNONE">&nbsp;Net Pay :</td>
						<%
						dNetSalary += dGrossSalary - dTotalDeduction;
						%>						 
					 <td align="right" class="thinborderNONE"><font size="1"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%>&nbsp;</strong></font></td>
         </tr>
       </table></td>
       <td valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
			 <tr>
			   <td width="50%" >&nbsp;&nbsp;_______________________</td>
			 </tr>
			 <tr>
			   <td class="thinborderNONE" align="center">Employee Signature </td>
			 </tr>
		   </table>
	   </td>
     </tr>
     <tr>
       <td colspan="4" valign="top"><hr size="1"></td>
     </tr>
     
     <tr>
       <td width="25%" height="2" ></td>
       <td width="25%" ></td>
       <td width="25%" ></td>
       <td width="25%" ></td>
     </tr>
  </table>
 <%}else if(strSchCode.startsWith("VMUF") || strPayslipUsed.equals("1")){
 	dOtherEarning = 0d;
	
	
	boolean bolIsTeaching = false;
	//for UPH, i have to determine if teaching staff.
	if(vPersonalDetails != null && vPersonalDetails.elementAt(23).equals("1"))
		bolIsTeaching = true;
 %>
 <div id="p1_div" style="height:470px">
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
 	<%if(strSchCode.startsWith("UPH")){%>
		<tr>
			<td>
			<font style="font-weight:bold; font-size:14px;"><%=SchoolInformation.getSchoolName(dbOP,false,false)%></font><br>
			<font style="font-size:10px;"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>
			<br>
			<font style="font-weight:bold; font-size:14px;">
			<%if(bolIsTeaching) {%>
				FACULTY PAYROLL SLIP
			<%}else{%>
				NON-TEACHING SLIP
			<%}%></font><Br>
			For the pay period <%=WI.getStrValue(strPayrollPeriod,"&nbsp;")%><br><br>&nbsp;
			</td>
		</tr>
	
	<%}%>
 
  <tr>
    <%if(WI.fillTextValue("show_logo").length() > 0){%>  
		<td width="14%"><img src="../../../../images/logo/<%=strSchCode%>.gif" width="100" height="100"></td>
	<%}%>
    <td valign="bottom">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
			<%if(!strSchCode.startsWith("VMUF") && !strSchCode.startsWith("UPH")){%>
			  <tr>
				<%if(strSchCode.startsWith("WUP")){%>
					 <td height="18" colspan="4">Payroll date :&nbsp;<font size="1"><%=WI.getStrValue(strPayrollPeriod,"&nbsp;")%></font></td>
				<%}else{%>		  
					<td height="18" colspan="4">Cut off :&nbsp;<font size="1"><%=WI.getStrValue(strCutOff,"&nbsp;")%></font></td>
				<%}%>	
				<td height="18" colspan="2">&nbsp;</td>
			  </tr>
			<%}%>
			  <tr>
				<td height="18" colspan="4">Name:
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
				if(strSchCode.startsWith("WUP"))//WUP dont want to see rank/position.sul02282013
						strTemp = "";
				%>
				<td width="38%" height="18" colspan="2">&nbsp; <%=WI.getStrValue(strTemp,"")%></td>
			  </tr>
			  <tr>
				<%if(vPersonalDetails.elementAt(13) != null && vPersonalDetails.elementAt(14) != null){
							strSlash = "-";
						 }else{
							strSlash = "";	
						 }
						 strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(13),"") + strSlash + WI.getStrValue((String)vPersonalDetails.elementAt(14),"");
					 %>
				<td height="18" colspan="4"><font size="1">Department/
					  <%if(bolIsSchool){%>
				  College
				  <%}else{%>
				  Division
				  <%}%>
				  :&nbsp;<%=strTemp%></font></td>
				<td height="18" colspan="2">&nbsp;</td>
			  </tr>
    	</table>
	</td>
  </tr>
</table>

 <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
    <tr> 
      <td height="18" colspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td colspan="2" class="thinborderTOPBOTTOM" height="18"><strong>SALARY/COMPENSATION</strong></td>
          </tr>
          <tr> 
            <td width="68%" class="thinborderNONE" height="14">&nbsp;<%if(bolIsTeaching) {%>Teaching Hours Pay<%}else{%>Basic salary<%}%></td>
            <td width="32%" align="right" class="thinborderNONE">  
						<% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							strTemp = (String)vDTRManual.elementAt(38);			
							dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}
						%>
						<strong><%=WI.getStrValue(strTemp,"0")%>&nbsp;</strong>						
			  </td>
          </tr>
					<!--
          <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Transportation Allowance</td>
            <td align="right" class="thinborderNONE"> 
              <% /*strTemp = null;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(52);
				dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			}	*/
		   %>              <strong><%//=WI.getStrValue(strTemp,"0")%>&nbsp;</strong></td>
          </tr>		
          <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Incentives/honorarium</td>
            <td align="right" class="thinborderNONE">  
              <% /*
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
			dGrossSalary += dTemp;*/
		  %>              <strong><%//=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"0")%>&nbsp;</strong></td>
          </tr>
					-->
          
		  
		<% 
		dTemp = 0d;
		if (vDTRManual != null && vDTRManual.size() > 0){
			// faculty pay 
			strTemp = (String) vDTRManual.elementAt(44);
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}	
		//dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		if(dTemp > 0){
	   %>   
          <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Teaching Hours Pay</td>
            <td align="right" class="thinborderNONE"><strong><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</strong></td>
          </tr>
		<%}//end of not zero %>
	   <% 
	    dTemp = 0d;
		if (vDTRManual != null && vDTRManual.size() > 0){
			// overload pay
			strTemp = (String) vDTRManual.elementAt(67);
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));	
			
			dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));		
		}	
		//dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		if(dTemp > 0){
	   %>   
          <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Overload Pay</td>
            <td align="right" class="thinborderNONE"><strong><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</strong></td>
          </tr>
		<%}//end of not zero %>
		<% 
		strTemp = null;
		if (vDTRManual != null && vDTRManual.size() >  0){
			strTemp = (String) vDTRManual.elementAt(25);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			dGrossSalary += dTemp;
		}
		if(dTemp > 0d){
		%>
		  <tr> 
			<td class="thinborderNONE" height="14">&nbsp;Night Differential</td>
			<td align="right" class="thinborderNONE">   
			  <strong><%=WI.getStrValue(strTemp,"0")%>&nbsp;</strong></td>
		  </tr>
		<%}%>
        <% 
		if (vDTRManual != null && vDTRManual.size() > 0){ 
			// OT Amount
			strTemp = (String) vDTRManual.elementAt(10);
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}	
		dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		if(dTemp > 0){
	    %>         
	   	  <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Overtime Amount</td>
            <td align="right" class="thinborderNONE">   
	        <strong><%=WI.getStrValue(strTemp,"0")%>&nbsp;</strong></td>
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
							dGrossSalary += dTemp; 
							if(dTemp > 0){	
					%>						        
          <tr>
            <td class="thinborderNONE" height="14"><font size="1">&nbsp;<%=strTemp%></font></td>
            <td align="right" class="thinborderNONE"><strong>
            	<% 
								strTemp = CommonUtil.formatFloat(dTemp,true);								
								if(dTemp == 0d)
									strTemp = "";				
 						    %>
            <%=WI.getStrValue(strTemp,"")%>&nbsp;</strong></td>
          </tr>
			<%			}//end of dTemp > 0
					}// END FOR LOOP
				}// END NULL CHECK%>
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
		if(dAbsenceAmt > 0 ) {		
	    %>							
          <tr> 
            <td class="thinborderNONE" height="14">&nbsp;Tardiness &amp; absences</td>
            
            <td align="right" class="thinborderNONE"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dAbsenceAmt,true),"(",")","0")%>&nbsp;</strong></td>
          </tr>
		  <%}%>
		  
        </table></td>
      <td colspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td colspan="3" class="thinborderTOPBOTTOM" height="18"><strong>DEDUCTIONS</strong></td>
          </tr>          
              <% 
		if (vDTRManual != null && vDTRManual.size() > 0){ 
			strTemp = (String) vDTRManual.elementAt(24);
			dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}
		dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		if(dTemp > 0){			
	   %>
	   <tr> 
            <td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;W/Holding 
              Tax</td>
            <td width="38%" align="right" class="thinborderNONE">   
              <strong><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></strong>&nbsp;</td>
          </tr>
		<%}%>  
		        
        <% 
		if (vDTRManual != null && vDTRManual.size() > 0){ 
			strTemp = (String) vDTRManual.elementAt(12);
			dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}	
		dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		if(dTemp > 0){	
	   %>
	    <tr> 
            <td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;SSS</td>
            <td align="right" class="thinborderNONE">   
              <strong><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"0")%></strong>&nbsp;</td>
          </tr>
		<%}%> 		  
           
        <% 
		if (vDTRManual != null && vDTRManual.size() > 0){ 
			strTemp = (String) vDTRManual.elementAt(13);
			dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}
		dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		if(dTemp > 0){		
	   %>
	   <tr> 
            <td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;PhilHealth</td>
            <td align="right" class="thinborderNONE">  
              <strong><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"0")%></strong>&nbsp;</td>
          </tr>
		<%}%>
         <% 
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(14);
				dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			}	
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			if(dTemp > 0){
		  %>
		  <tr> 
            <td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;PAG-IBIG</td>
            <td align="right" class="thinborderNONE">  
              <strong><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"0")%></strong>&nbsp;</td>
          </tr>
		  <%}%>
		  
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
				 <td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;PERAA</td>
           		 <td align="right" class="thinborderNONE"> 
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
					<td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;<%=strTemp%></td>
					<td align="right" class="thinborderNONE">
					<% 
									strTemp = CommonUtil.formatFloat(dTemp,true);							
									if(dTemp == 0d)
										strTemp = "";				
								 %>            <strong><%=WI.getStrValue(strTemp,"")%></strong>&nbsp;</td>
				  </tr>
				<%		}//end of dTemp > 0
					}// END FOR LOOP
				}// END NULL CHECK%>
				<% 
				if (vDTRManual != null && vDTRManual.size() > 0){ 
					strTemp = (String) vDTRManual.elementAt(18);
					dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					dTotalDeduction += dOtherDeduction;				
				}
				if(dOtherDeduction > 0){	
				 %>	
		 <tr> 
            <td colspan="2" class="thinborderNONE" height="14">&nbsp;&nbsp;Advances &amp; Other Ded</td>            			 		
            <td align="right" class="thinborderNONE"> <strong><%=WI.getStrValue(CommonUtil.formatFloat(dOtherDeduction,true),"0")%></strong>&nbsp;</td>
          </tr>
		  <%}%>
        </table></td>
      <td colspan="2" valign="top" class="thinborderBOTTOMLEFTRIGHT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="73%" height="18" class="thinborderTOP">&nbsp;</td>
            <td width="27%" class="thinborderTOP">&nbsp;</td>
          </tr>							
          <tr> 
            <td>&nbsp;</td>
            <td align="right" class="thinborderNONE">&nbsp;</td>
          </tr>				
          <% 					
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						// this is Additional pay amount
						strTemp = (String) vDTRManual.elementAt(17);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dOtherEarning += dTemp;
						
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
			   if( (dTemp*dTemp) > 0){//dTemp * dTemp in order to show also negative values (debit-credit)sul.02152013
			   %>			   
			  <tr> 
				<td height="18" class="thinborderNONE"><strong>&nbsp;&nbsp;ADJUSTMENT AMOUNT</strong></td>   
				<td><div align="right"><font size="1">&nbsp;<strong><%=WI.getStrValue(strTemp,"0")%></strong></font></div></td>
			  </tr>
			  <%}%>
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
				//dNetSalary = dGrossSalary - dTotalDeduction + dTemp;
			strTemp = null;
			if(vDTRManual != null && vDTRManual.size() > 0){
				strTemp = (String)vDTRManual.elementAt(9);
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dNetSalary = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			}
			%>			
      <td width="13%" align="right" class="thinborderBOTTOMLEFTRIGHT"><font size="1">&nbsp;<strong><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%></strong></font></td>
    </tr>
    <tr>
      <td height="7" colspan="6"></td>
    </tr>
  </table>   
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="50%"><%if(vUnworkedDays != null && vUnworkedDays.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">		
		<%
			strTemp = null;
			for(i = 1;i < vUnworkedDays.size(); i+=2){
				if(strTemp == null)
					strTemp = (vUnworkedDays.elementAt(i)).toString();
				else
					strTemp += ", " + (vUnworkedDays.elementAt(i)).toString();
			}
		%>
		<tr>
			<td height="14">Absences :<font size="1"><%=WI.getStrValue(strTemp)%></font></td>
		</tr>
	</table>
	<%}%></td>
    <td width="50%"><%
				if(vOTEncoding != null && vOTEncoding.size() > 0){%>
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td colspan="2" class="thinborderNONE">OVERTIME DETAILS </td>
						<td width="33%">&nbsp;</td>
						<td width="19%">&nbsp;</td>
					</tr>
					<%					
						for(i = 0; i < vOTEncoding.size(); i+=13){
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
						<td width="24%" height="20" valign="top" class="thinborderNONE"><%=CommonUtil.formatMinute(strTemp)%>:<%=CommonUtil.formatMinute(strTemp2)%></td>
						<% 
							strTemp = (String)vOTEncoding.elementAt(i+1); 
						%>					
						<td width="24%" valign="top" class="thinborderNONE"><%=strTemp%></td>
						<%
							strTemp = (String)vOTEncoding.elementAt(i+2);						
						%>
						<td width="33%" valign="top" class="thinborderNONE"><%=strTemp%></td>
						<%
							strTemp = (String)vOTEncoding.elementAt(i+7);						
						%>
						<td width="19%" align="right" valign="top" class="thinborderNONEcl"><%=strTemp%>&nbsp;</td>
					</tr>
					<%}// end for loop%>
				</table>
				<%}// end vOTEncoding%></td>
  </tr>
</table>
	<%if(!strSchCode.startsWith("VMUF") && bolShowSignature){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="40%" height="30">&nbsp;</td>
			<td width="28%" align="center" class="thinborderBOTTOM">&nbsp;</td>
			<td width="2%" align="center">&nbsp;</td>
			<td width="30%" align="center" valign="bottom" class="thinborderBOTTOM"><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td align="center" class="thinborderNONE">Head/Manager Signature </td>
			<td align="center">&nbsp;</td>
			<td align="center" class="thinborderNONE">Employee Signature </td>
		</tr>
	</table>	
	<%}%>
  </div> <!-- end of p1_div -->
	
	 <%}else if(strSchCode.startsWith("UDMC") || strPayslipUsed.equals("2")){%>
	 <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <%if(WI.fillTextValue("show_logo").length() > 0){%>  
		<td width="14%" class="thinborderBOTTOM"><img src="../../../../images/logo/<%=strSchCode%>.gif" width="100" height="100"></td>
		<%}%>
    <td valign="bottom" class="thinborderBOTTOM"><table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
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
				<td height="17" class="thinborderNONE"><font size="1">NAME</font></td>
				<td class="thinborderNONE"><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
								(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%></td>
			  <td class="thinborderNONE"><%=WI.getStrValue(strEmpID,"(",")","")%></td>
			  <td class="thinborderNONE">&nbsp;</td>
				<%
				  if (vDTRDetails != null && vDTRDetails.size() > 0){
						if(strSalaryBase.equals("0")){// monthly or teaching
							//strTemp = ConversionTable.replaceString((String)vDTRDetails.elementAt(26),",","");
							strTemp = (String)vDTRDetails.elementAt(72);
							if(strTemp.equals("1")){ // 1 if salary is fully from teaching load
								strTemp = WI.getStrValue((String)vDTRDetails.elementAt(27),"Teaching Rate: ","","");
							}else{
								strTemp = WI.getStrValue((String)vDTRDetails.elementAt(26),"RATE :","","");
							}
						}else if(strSalaryBase.equals("1")){
							strTemp = WI.getStrValue((String)vDTRDetails.elementAt(18),"RATE :","/day","");
						}else if(strSalaryBase.equals("2")){
							strTemp = WI.getStrValue((String)vDTRDetails.elementAt(19),"RATE :","/hour","");
						}else{
							strTemp = "&nbsp;";	
						}
					}else{
						strTemp = "&nbsp;";
					}
				%>
				<td class="thinborderNONE"><%=strTemp%></td>
			  <td colspan="2" class="thinborderNONE">&nbsp;</td>
			</tr>
			</table></td>
  </tr>
</table>

			<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">				
			<tr> 
				<td height="18" colspan="3" valign="top">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">						
						<tr>
						  <td width="24%" valign="bottom" class="thinborderNONE">Earnings</td>
							<% strTemp = "";
								if (vDTRDetails != null && vDTRDetails.size() > 0 && vDTRManual != null && vDTRManual.size() > 0){
									if(strSalaryBase.equals("0")){// monthly or teaching
										//strTemp = ConversionTable.replaceString((String)vDTRDetails.elementAt(26),",","");
										strTemp = (String)vDTRDetails.elementAt(72);
										if(strTemp.equals("1")){ // 1 if salary is fully from teaching load
											strTemp = WI.getStrValue((String)vDTRDetails.elementAt(71),""," hrs","");
										}else{
											strTemp = "";
										}
									}else if(strSalaryBase.equals("1")){
										strTemp = WI.getStrValue((String)vDTRManual.elementAt(68),""," days","");
									}else if(strSalaryBase.equals("2")){
										strTemp = WI.getStrValue((String)vDTRManual.elementAt(2),""," hrs","");
									}
								}
							%>
							<td width="49%" height="10" valign="bottom" class="thinborderNONE">Basic Pay <%=WI.getStrValue(strTemp,"(",")","&nbsp;")%></td>
						<% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							strTemp = (String)vDTRManual.elementAt(38);			
							dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}
						%>
							<td width="27%" align="right" valign="bottom"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
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
					<%
						if(bolIsSchool){
					%>
          <% dTemp = 0d;
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							// faculty pay
							strTemp = (String) vDTRManual.elementAt(44);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

							// sub teaching salary
							strTemp = (String) vDTRManual.elementAt(60);							
							dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
 							dGrossSalary += dTemp; 
							}					
							 	
							if(dTemp > 0d){
						 %>				
          <tr>
            <td height="10" valign="bottom" class="thinborderNONE">Sub Teaching </td>
            <td align="right" valign="bottom" class="thinborderNONE"><%=WI.getStrValue(CommonUtil.formatFloat(dTemp,true),"")%></td>
          </tr>
					<%}%>
          <% dTemp = 0d;
						  if (vDTRManual != null && vDTRManual.size() > 0){ 
								// manually encoded overload Amount
								strTemp = (String) vDTRManual.elementAt(67);							
								dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
								dGrossSalary += dTemp; 
							}					
							 	
							if(dTemp > 0d){
						 %>
          <tr>
							<% strTemp = "";
								if (vDTRManual != null && vDTRManual.size() > 0){
									strTemp = WI.getStrValue((String)vDTRManual.elementAt(66),"("," hours)","");
								}
							%>						
            <td height="10" valign="bottom" class="thinborderNONE">Overload <%=strTemp%></td>
            <td align="right" valign="bottom" class="thinborderNONE"><%=WI.getStrValue(CommonUtil.formatFloat(dTemp,true),"")%></td>
          </tr>
          <%}%>    
					<%} // end if(bolIsSchool)%>
					<%
					if (vDTRManual != null && vDTRManual.size() > 0){
								// additional bonuses
								strTemp = (String) vDTRManual.elementAt(22);
								dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						if(dTemp > 0d){
					%>
					<tr> 
            <td  height="16" class="thinborderNONE"><%=WI.getStrValue((String) vDTRManual.elementAt(23))%></td>
            <td align="right" class="thinborderNONE">
            <% 
								strTemp = CommonUtil.formatFloat(dTemp,true);
								dGrossSalary += dTemp; 
								if(dTemp == 0d)
									strTemp = "";				
 						    %>
            <%=WI.getStrValue(strTemp,"")%></td>
          </tr>							     
					<%}
					}%>
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
							strTemp = "--";
					}	
					 %>
          <tr>
            <td width="65%" class="thinborderNONE">Abs/UT/Late</td>
            <td width="35%" align="right" class="thinborderNONE"><%=strTemp%></td>
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
				<%}%>			  </td>
			</tr>
			<tr>
			  <td height="10" colspan="7" valign="top"></td>
	   </tr>
			<tr>
			  <td height="18" colspan="3" valign="top" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr>
            <td width="24%" valign="bottom" class="thinborderNONE" height="14">Deductions</td>
            <td width="49%" valign="bottom"><font color="#000000" size="1">W/Tax</font></td>
            <td width="27%" align="right" valign="bottom"><font size="1">
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
					<%if(bolIsSchool){%>
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
					<%}%>
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
            <td width="65%" class="thinborderNONE" height="14">&nbsp;<%=WI.getStrValue(strTemp,"")%></td>
            <td width="35%" align="right" class="thinborderNONE"><% 
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
			  <td colspan="3" rowspan="2" valign="top">
				<%if(bolShowSignature){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="28%" height="30">&nbsp;</td>
			<td width="2%" align="center">&nbsp;</td>
			<td width="30%" align="center" valign="bottom" class="thinborderBOTTOM"><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%></td>
		</tr>
		<tr>
			<td align="center" class="thinborderNONE">&nbsp;</td>
			<td align="center">&nbsp;</td>
			<td align="center" class="thinborderNONE">Employee Signature </td>
		</tr>
	</table>
	<%}%></td>
			  </tr>
		  <tr>
		    <td height="18" valign="top">&nbsp;</td>
		    <td valign="top">&nbsp;</td>
		    <td valign="top">&nbsp;</td>
		    <td valign="top">&nbsp;</td>
		    </tr>
		  <tr>
			  <td width="11%" height="5" valign="top"></td>
			  <td width="23%" valign="top"></td>
			  <td width="11%" valign="top"></td>
			  <td width="1%" valign="top"></td>
			  <td width="34%" valign="top"></td>
			  <td width="9%" valign="bottom"></td>
			  <td width="11%" align="right" valign="bottom"></td>
	   </tr>
	</table>	 
		<%}else{
	 	//  This is mainly for cldh... but other schools/ companies without payslip could use this
	 %>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <%if(WI.fillTextValue("show_logo").length() > 0){%>  
		<td width="14%" height="101" class="thinborderBOTTOM"><img src="../../../../images/logo/<%=strSchCode%>.gif" width="100" height="100"></td>
		<%}%>
    <td valign="bottom"><table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
		
		<tr> 
			<td width="17%" class="thinborderNONEcl">&nbsp;PAYROLL PERIOD</td>
			<%
				if(strCutOff == null || strCutOff.length() == 0){
					strCutOff = WI.fillTextValue("sal_cut_off");				
				}
			%>
			<td width="32%" class="thinborderNONEcl">&nbsp;<%//=strCutOff%><%=strPayrollPeriod%> </td>
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
		  <td height="8"></td>
		  <td></td>
		  <td colspan="2" class="thinborderNONE">&nbsp;</td>
	  </tr>
		</table></td>
  </tr>
</table>

		<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
		<tr> 
			<td height="18" colspan="2" valign="top" class="thinborderTOP"><table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr valign="bottom"> 
						<td height="20" colspan="6" align="center"><strong>EARNINGS</strong></td>
					</tr>
					<%
						iIndexOf = -1;
 						if(vOptionalItems != null){							
							iIndexOf = vOptionalItems.indexOf("DAILY_HOURLY");
						}
 					%>
					<%if(iIndexOf == -1){%>
					<tr>
						<td valign="bottom"><font size="1">RATE / DAY</font></td>
						<td align="right" valign="bottom"><font size="1"><%=WI.getStrValue(strDailyRate,"0")%></font></td>
						<td>&nbsp;</td> 
						<td height="10">&nbsp;</td>
						<td align="right"><font size="1">&nbsp;</font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}%>
					<tr>
					 <% 
						 if (vDTRManual != null && vDTRManual.size() > 0){ 
								strTemp = (String)vDTRManual.elementAt(68);			
							}else{
								strTemp = "";
							}
							
						iIndexOf = -1;
						if(vOptionalItems != null){							
							iIndexOf = vOptionalItems.indexOf("DAILY_HOURLY");
						}
													
						%>							
						
						<td valign="bottom"><font size="1">Basic</font>
						<%if(iIndexOf == - 1){%>
						<font size="1"> Pay <br><%=strTemp%> days</font>
						<%}%>						</td>
						<% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							strTemp = (String)vDTRManual.elementAt(38);			
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
					}
					
					if(vOptionalItems != null){
						iIndexOf = vOptionalItems.indexOf("NIGHT_DIFF");					
						if(iIndexOf != -1)
							dTemp = 0d;
					}

					dGrossSalary += dTemp; 
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
						strTemp =(String) vDTRManual.elementAt(17);				
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						if (dTemp < 0d){
							strTemp = "(" + ConversionTable.replaceString((String) vDTRManual.elementAt(17),"-","") + ")";							
						}						
					}						
					if(vOptionalItems != null){
						iIndexOf = vOptionalItems.indexOf("ADJUSTMENT");					
						if(iIndexOf != -1)
							dTemp = 0d;
					}
					dGrossSalary += dTemp;
						if(dTemp != 0d){
					%>
					<tr>
						<td valign="bottom"><font size="1"><%=WI.getStrValue((String) vDTRManual.elementAt(30),"")%></font></td>
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
						strTemp =(String) vDTRManual.elementAt(20);
						
						//System.out.println("vOptionalItems: " + vOptionalItems);
						//System.out.println("strTemp: " + strTemp);
						//System.out.println("strTemp: " +  vDTRManual.elementAt(17));
						//System.out.println("strTemp: " +  vDTRManual.elementAt(30));						
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						if (dTemp < 0d){
							strTemp = "(" + ConversionTable.replaceString((String) vDTRManual.elementAt(20),"-","") + ")";							
						}
						
					}	
					
					if(vOptionalItems != null){
						iIndexOf = vOptionalItems.indexOf("ADJUSTMENT");					
						if(iIndexOf != -1)
							dTemp = 0d;
					}
					dGrossSalary += dTemp;										
					
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
							if(vOptionalItems != null){
								iIndexOf = vOptionalItems.indexOf("FACULTY_PAY");					
								if(iIndexOf != -1)
									dTemp = 0d;
							}		
							
							// sub teaching salary
							strTemp = (String) vDTRManual.elementAt(60);							
							if(vOptionalItems != null){
								iIndexOf = vOptionalItems.indexOf("SUBSTITUTION");					
								if(iIndexOf != -1)
									strTemp = "0";
							}
							dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
			
							// manually encoded overload Amount
							strTemp = (String) vDTRManual.elementAt(67);		
							if(vOptionalItems != null){
								iIndexOf = vOptionalItems.indexOf("OVERLOAD");					
								if(iIndexOf != -1)
									strTemp = "0";
							}												
							dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));	
						}					
						dGrossSalary += dTemp; 
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
					}	
						if(vOptionalItems != null){
							iIndexOf = vOptionalItems.indexOf("OVERTIME");					
							if(iIndexOf != -1)
								dTemp = 0d;
						}	
						dGrossSalary += dTemp; 
					
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
					//System.out.println("3611 vEarnings: " + vEarnings);
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
					<!--
				 <% /*
				  dTemp = 0d;
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
					*/
					%>
					<tr>
						<td valign="bottom"><font size="1"> INCENTIVE</font></td>
						<td align="right" valign="bottom"><font size="1">
							<%//=WI.getStrValue(strTemp,"")%></font></td>
						<td>&nbsp;</td> 
						<td>&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
					<%//}%>
					-->
					<% 
					dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() > 0){ 	
						strTemp = (String) vDTRManual.elementAt(22);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
						dGrossSalary += dTemp;
					}
					if(dTemp > 0d) {
					%>
					<tr>
						<td width="42%"><font size="1"><%=WI.getStrValue((String) vDTRManual.elementAt(23))%></font></td>
						<td width="20%" align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
						<td width="4%">&nbsp;</td>
						<td width="12%">&nbsp;</td>			
						<td width="19%" align="right">&nbsp;</td>
						<td width="3%" align="right">&nbsp;</td>
					</tr>					
					<%}%>
				<% 
					dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() > 0){ 	
						strTemp = (String) vDTRManual.elementAt(26); // holiday pay
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
					}
						if(vOptionalItems != null){
							iIndexOf = vOptionalItems.indexOf("HOLIDAYS");					
							if(iIndexOf != -1)
								dTemp = 0d;
						}						
					dGrossSalary += dTemp;
					if(dTemp > 0d) {
					%>
					<tr>
						<td width="42%"><font size="1">HOLIDAY PAY </font></td>
						<td width="20%" align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
						<td width="4%">&nbsp;</td>
						<td width="12%">&nbsp;</td>			
						<td width="19%" align="right">&nbsp;</td>
						<td width="3%" align="right">&nbsp;</td>
					</tr>					
					<%}%>				
						<% 
							
							strTemp = CommonUtil.formatFloat(dOtherEarning,2);
							dGrossSalary += dOtherEarning;
							if(dOtherEarning > 0d){							
								
						%>
						
					<tr>
						<td width="42%"><font size="1">OTHERS</font></td>
						<td width="20%" align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td width="4%">&nbsp;</td>
						<td width="12%">&nbsp;</td>			
						<td width="19%" align="right">&nbsp;</td>
						<td width="3%" align="right">&nbsp;</td>
					</tr>
					<%}%>
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
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dAbsenceAmt += dTemp;
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
						<%
						strTemp2 = "";
						if(dTemp > 0d){
							strTemp = (String)vDTRDetails.elementAt(83);
							dTemp = Double.parseDouble(strTemp);
							if(dTemp > 0)
								strTemp2 = WI.getStrValue(strTemp, "Late(","min)","");

							strTemp = (String)vDTRDetails.elementAt(84);
							dTemp = Double.parseDouble(strTemp);
							if(dTemp > 0)
								strTemp2 += WI.getStrValue(strTemp, "&nbsp;UT(","min)","");							
						}%>
					  <td colspan="2" class="thinborderNONE">&nbsp;<%=strTemp2%></td>
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
						<td height="20" colspan="3" align="center"><strong>DEDUCTIONS</strong></td>
					</tr>
					 <% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String) vDTRManual.elementAt(24);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dTotalDeduction += dTemp; 
						strTemp = CommonUtil.formatFloat(strTemp,true);
						if(dTemp == 0d)
							strTemp = "";
					}	
						if(WI.fillTextValue("hide_zero").length() == 0 || dTemp > 0d){
					 %>
					<tr> 
						<td valign="bottom"><font size="1">&nbsp;&nbsp;</font><font color="#000000" size="1">W/HOLDING 
						TAX </font></td>
						<td align="right" valign="bottom"><font size="1">
							<%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}%>
					<% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String) vDTRManual.elementAt(12);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						strTemp = CommonUtil.formatFloat(strTemp,true);
						dTotalDeduction += dTemp; 
						if(dTemp == 0d)
							strTemp = "";			
					}	
						if(WI.fillTextValue("hide_zero").length() == 0 || dTemp > 0d){
					 %>
					<tr>
						<td valign="bottom"><font size="1">&nbsp;&nbsp;</font><font color="#000000" size="1">SSS 
						PREM.</font></td>
						<td align="right" valign="bottom"><font size="1">
						<%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}%>
						<% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String) vDTRManual.elementAt(13);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						strTemp = CommonUtil.formatFloat(strTemp,true);
						dTotalDeduction += dTemp; 
						if(dTemp == 0d)
							strTemp = "";			
					}	
						if(WI.fillTextValue("hide_zero").length() == 0 || dTemp > 0d){
					 %>
					<tr>
						<td valign="bottom"><font size="1"> &nbsp;&nbsp;PHILHEALTH 
						PREM.</font></td>
						<td align="right" valign="bottom"><font size="1">
						<%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}%>
							<% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String) vDTRManual.elementAt(14);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						strTemp = CommonUtil.formatFloat(strTemp,true);
						dTotalDeduction += dTemp; 
						if(dTemp == 0d)
							strTemp = "";
					}	
					if(WI.fillTextValue("hide_zero").length() == 0 || dTemp > 0d){
					 %>
					<tr>
						<td valign="bottom"><font size="1">&nbsp;&nbsp;PAG-IBIG<font color="#000000"> </font><font color="#000000" size="1">PREM.</font></font></td>
						<td align="right" valign="bottom"><font size="1">
							<%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}%>
					<%if(bolIsSchool){%>
						<% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String) vDTRManual.elementAt(54);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						strTemp = CommonUtil.formatFloat(strTemp,true);
						dTotalDeduction += dTemp; 
						if(dTemp == 0d)
							strTemp = "";
					}	
					if(WI.fillTextValue("hide_zero").length() == 0 || dTemp > 0d){
					 %>
					<tr>
						<td valign="bottom"><font size="1">&nbsp;&nbsp;PERAA </font><font color="#000000" size="1">PREM.</font></td>
						<td align="right" valign="bottom"><font size="1">
							<%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}
					} // end if(bolIsSchool)%>
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
						strTemp = CommonUtil.formatFloat(dOtherDeduction,true);
						dTotalDeduction += dOtherDeduction; 
						if(dOtherDeduction == 0d)
							strTemp = "";
					
					%>
						<td align="right" valign="bottom"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
						<td width="36%" height="6"></td>
						<td width="20%"></td>
						<td width="19%" align="right"></td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="19" colspan="2" valign="top" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="78%" height="18" align="right"><font size="1">TOTAL 
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
					<td height="18" valign="bottom"><strong>&nbsp;&nbsp;NET SALARY :</strong></td>
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
				<td width="42%" valign="top">
			<%
 			if(vUnworkedDays != null && vUnworkedDays.size() > 0){%>
				<table width="100%" cellpadding="0" cellspacing="0" border="0">		
					<%
						strTemp = null;
						for(i = 1;i < vUnworkedDays.size(); i+=2){
							if(strTemp == null)
								strTemp = (vUnworkedDays.elementAt(i)).toString();
							else
								strTemp += ", " + (vUnworkedDays.elementAt(i)).toString();
						}
					%>
					<tr>
						<td height="14">Absences :<font size="1"><%=WI.getStrValue(strTemp)%></font></td>
					</tr>
				</table>
				<%}%>				
				<%
				if(vOTEncoding != null && vOTEncoding.size() > 0){%>
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td colspan="2" class="thinborderNONE">OVERTIME DETAILS </td>
						<td width="36%">&nbsp;</td>
						<td width="19%">&nbsp;</td>
					</tr>
					<%					
						for(i = 0; i < vOTEncoding.size(); i+=13){
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
				<td width="58%" valign="top">
				<%if(vEmpLoans != null && vEmpLoans.size() > 0){%>
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td colspan="2" class="thinborderNONE">LOAN DETAILS : </td>
						<td width="19%">&nbsp;</td>
						<td width="21%">&nbsp;</td>
						<td width="17%">&nbsp;</td>
					</tr>
					<tr>
						<td width="24%" class="thinborderNONE">&nbsp;</td>
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
	<%if(bolShowSignature){%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
				<td width="19%" height="30"><span class="thinborderNONE">Employee Signature </span></td>
				<td width="28%" align="center" valign="bottom" class="thinborderBOTTOM"><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
								(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%></td>
			  <td width="53%" align="center" valign="bottom">&nbsp;</td>
			</tr>
		</table>
		<%}%>		
	<%}%>
  
  <%if(strSchCode.startsWith("VMUF") && !WI.fillTextValue("my_home").equals("1")){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
  	  <td>&nbsp;</td> 
	  <td height="19" colspan="6"><font size="1">Received the amount of <strong> 
        <u> 
        <%if (dNetSalary > 0) {%>
        <%=new ConversionTable().convertAmoutToFigure(dNetSalary,"Pesos","Centavos")%> 
        <%}else{%>
        zero 
        <%}%>
      </u> </strong> as payroll for cut off period <u><strong> <%=WI.getStrValue(strCutOff,"&nbsp;")%></strong></u>.</font></td>
	</tr>	
	
	<tr>
	  <td>&nbsp;</td> 
	  
	  <td height="18" colspan="2"><font size="1">Prepared By: </font><img src="./signatory/signatory1.jpg" width="82" height="45"></td>
	  <td colspan="2" valign="bottom"><font size="1">Checked by: </font><img src="./signatory/signatory2.jpg" width="86" height="45"></td>
	  <td colspan="2" valign="bottom"><font size="1">Approved by : </font><img src="./signatory/signatory3.jpg" width="88" height="45"></td>
	  <!--
	  <td height="18" colspan="2"><font size="1">Prepared By: </font><img src="./signatory/signatory1.gif"></td>
	  <td colspan="2" valign="bottom"><font size="1">Checked by: </font><img src="./signatory/signatory2.gif"></td>
	  <td colspan="2" valign="bottom"><font size="1">Approved by : </font><img src="./signatory/signatory3.gif"></td>
    -->
    </tr>
	<tr>
	  <td>&nbsp;</td> 
	  <td height="14" align="right">&nbsp;</td>
	  <td ><font size="1"><strong><%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Payroll Head",7)),"Maria C. Reyes").toUpperCase()%></strong></font></td>
	  <td width="5%" align="right">&nbsp;</td>
	  <td width="25%"><font size="1"><strong><%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Accounting Head",7)),"Elvira B. Caguioa").toUpperCase()%></strong></font></td>
	  <td width="5%">&nbsp;</td>
	  <td width="34%"><font size="1"><strong><%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"HR Manager",7)),"Angeline Mae P. Juan").toUpperCase()%></strong></font></td>
    </tr>
	<tr>
	  <td width="1%">&nbsp;</td> 
	  <td width="6%" height="14">&nbsp;</td>
	  <td width="24%" valign="top"><em><font size="1">Head, Payroll Section </font></em></td>
	  <td valign="top">&nbsp;</td>
	  <td valign="top"><em><font size="1">Head, Accounting Section </font></em></td>
	  <td valign="top">&nbsp;</td>
	  <td valign="top"><em><font size="1">Head, Human Resources Development Office</font></em></td>
    </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td height="18">&nbsp;</td>
	  <td valign="top"></td>
	  <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td height="18" align="right"><font size="1">Payee :</font></td>
	  <td valign="top">&nbsp;<font size="1"><strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
					(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%></strong></font></td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
  </table>
  <%}// end if strSchCode.startsWith("VMUF")%>
  
  <%if( false && strSchCode.startsWith("WUP")){ //start of duplicate because WUP wants to print 2 copies of payslip per short bond paper.sul03142013<br>
									  //changed their mind again and want to display 1 copy only. sul03142013								
	%>
	<div id="p1_div_copy"></div><!-- end of p1_div_copy  -->
	
	<script type="text/javascript">
		document.getElementById("p1_div_copy").innerHTML = document.getElementById("p1_div").innerHTML;
	</script>
	<%}//end of if WUP%>
  
  
  
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