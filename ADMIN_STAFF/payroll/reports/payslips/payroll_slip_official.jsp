<%@ page language="java" import="utility.*, java.util.Vector, payroll.ReportPayroll, 
								enrollment.CurriculumCollege,  payroll.PRSalaryExtn, payroll.PRPayslip,
								payroll.PRSalary, payroll.PReDTRME, hr.HRInfoPersonalExtn, 								
								payroll.ReportPayrollExtn, payroll.PRRetirementLoan " buffer="24kb"%>

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
								"Admin/staff-Payroll-REPORTS-EmployeePayslip","payroll_slip_iligan.jsp");
								
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
														"payroll_slip_iligan.jsp");
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
	Vector vDTRDetails    = null;
	Vector vDTRManual     = null;
	Vector vMiscDeduct  = null;
	Vector vLoansAndAdv   = null;
	Vector vSalIncentives = null;	
	Vector vUpdate  	    = null;
	Vector vOtherCons	    = null;
	Vector vTemp 			    = null;
	Vector vVarAllowances = null;
	Vector vEmpIDs        = null;
	Vector vMiscEarnings  = null;
	Vector vOTEncoding    = null;
	Vector vPayslipItems  = null;
	Vector vDeductions    = null;
	Vector vEarnings      = null;
	Vector vEarnDed       = null;
	Vector vUnworkedDays  = null;
	Vector vOTWithType = null;
	Vector vInternal = null;
	
	HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
	PRSalary salary = new PRSalary();
	PRSalaryExtn salaryExtn = new PRSalaryExtn();
	ReportPayroll rptPay = new ReportPayroll(request);
	ReportPayrollExtn rptPayExtn = new ReportPayrollExtn(request);
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	PRPayslip payslip = new PRPayslip();	
	String[] astrTaxStatus = {"Z","S","HF","ME"};
	String[] astrGender = {"M","F"};
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
	double dBasicPay = 0d;
 	
if (strEmpID.length() > 0) {
  enrollment.Authentication authentication = new enrollment.Authentication();
  vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");	
 	vDTRDetails = salary.getDTRDetails(dbOP,request);
	vDTRManual = salary.operateOnDTRManual(dbOP,request,7);		
	vInternal  = salary.operateOnDTRManual(dbOP,request,7, true);		

	vPayslipItems = rptPayExtn.getPayslipItems(dbOP, strSalIndex);

	if(vPayslipItems != null){
		vDeductions = (Vector)vPayslipItems.elementAt(0);
 		vEarnings = (Vector)vPayslipItems.elementAt(1);
		vEarnDed = (Vector)vPayslipItems.elementAt(2);
	}
	
	if(vDTRManual != null){
		vMiscDeduct   = (Vector) vDTRManual.elementAt(0);
    vLoansAndAdv  = (Vector) vDTRManual.elementAt(1);
		vOtherCons    = (Vector) vDTRManual.elementAt(42);
		vVarAllowances= (Vector) vDTRManual.elementAt(59);
		vMiscEarnings	= (Vector) vDTRManual.elementAt(62);
		vSalIncentives= (Vector) vDTRManual.elementAt(63);
	}
	
	if(vDTRDetails != null){
		//vSalIncentives = (Vector)vDTRDetails.elementAt(10);		
		vUnworkedDays = (Vector) vDTRDetails.elementAt(41);
		vOTEncoding = (Vector)vDTRDetails.elementAt(68);
		strSalaryBase = (String)vDTRDetails.elementAt(70);
		vOTWithType = (Vector)vDTRDetails.elementAt(76);
	}	
	vEmpIDs = salaryExtn.getEmpContributionIDs(dbOP, strEmployeeIndex);
	
	strPayslipUsed = payslip.operateOnPayslipUse(dbOP, 4, request);
	strPayslipUsed = WI.getStrValue(strPayslipUsed);
}

if(WI.fillTextValue("finalize").length() > 0){
  if(!payslip.FinalizeSalary(dbOP,request,strSalIndex)){
		strErrMsg = "Error";
  }	

}

if(WI.fillTextValue("sal_period_index").length() > 0) {			
	vSalaryPeriod = rptPay.getSalaryPeriodRange(dbOP);
	strTemp = WI.fillTextValue("sal_period_index");					
	if (vSalaryPeriod!= null && vSalaryPeriod.size() > 0){
		 strPayrollPeriod = (String)vSalaryPeriod.elementAt(3) +" - "+(String)vSalaryPeriod.elementAt(4);
		 strCutOff = (String)vSalaryPeriod.elementAt(1) +" - "+(String)vSalaryPeriod.elementAt(2);
		 strPeriodEnding = (String)vSalaryPeriod.elementAt(4);
 	}		
}

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
String strPtFt = WI.fillTextValue("pt_ft"); 
strSlash = "";
%>
<body <%if(WI.fillTextValue("skip_print").length() == 0){%>onLoad="javascript:window.print()"<%}%>>
<form>
 <%if(strPayslipUsed.equals("4")){%>
	<%if(vInternal != null && vInternal.size() > 0){
		dGrossSalary = 0d;
		dTotalDeduction = 0d;
		dAbsenceAmt = 0d;
		dOtherEarning = 0d;
		dOtherDeduction = 0d;
		dSubTotalDed = 0d;
	%>
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
             <td class="thinborderNONE"><div align="right">
                 <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){ 
			strTemp = (String)vDTRDetails.elementAt(17);	
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}
		%>
                 <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</div></td>
           </tr>            
					 <% dTemp = 0d;
 					 if (vInternal != null && vInternal.size() > 0){ 
						strTemp = (String) vInternal.elementAt(26);
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
							if (vInternal != null && vInternal.size() > 0){ 
								strTemp = (String) vInternal.elementAt(10);
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
					if (vInternal != null && vInternal.size() >  0){ 	
						strTemp = (String) vInternal.elementAt(25);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dGrossSalary += dTemp; 
					}
					if(dTemp > 0d){
						strTemp = "";
					%>
           <tr>
             <td class="thinborderNONE" height="16">Night Differential </td>
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
			if (vInternal != null && vInternal.size() > 0){ 
			// leave without pay			
				strTemp = (String) vInternal.elementAt(11);
				dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			// AWOL
				strTemp = (String) vInternal.elementAt(32);
				dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			// Lates and undertimes
				strTemp = (String) vInternal.elementAt(33);
				dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			// faculty absences
				strTemp = (String) vInternal.elementAt(45);
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
             <td class="thinborderNONE" height="16"> Gross Pay </td>
             <td class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dGrossSalary,true)%>&nbsp;&nbsp;</div></td>
           </tr>
           <tr>
             <td class="thinborderNONE" height="16">Others</td>
						 <%
							// addl pay amount
							strTemp = (String) vInternal.elementAt(17);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							dGrossSalary += dTemp;
							
							// addl bonus amount
							strTemp = (String) vInternal.elementAt(22);
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
             <td width="56%" class="thinborderNONE" height="16">Tax Withheld</td>
             <td width="44%" align="right" class="thinborderNONE">
                <% 
			if (vInternal != null && vInternal.size() > 0){ 
				strTemp = (String) vInternal.elementAt(24);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
				dSubTotalDed += dTemp; 
				strTemp = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "";
			}	
		   %>
               <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
					<% 
						if (vInternal != null && vInternal.size() > 0){ 
							strTemp = (String) vInternal.elementAt(12);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = CommonUtil.formatFloat(strTemp,true);
							dSubTotalDed += dTemp; 
						}	
						if(dTemp > 0d){
					 %>
           <tr>
             <td class="thinborderNONE" height="16"> SSS premium</td>
             <td align="right" class="thinborderNONE">
               <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
					 <%}%>
           <% 
						if (vInternal != null && vInternal.size() > 0){ 
							strTemp = (String) vInternal.elementAt(61);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = CommonUtil.formatFloat(strTemp,true);
							dSubTotalDed += dTemp; 
						}	
						if(dTemp > 0d){
					 %>
           <tr>
             <td class="thinborderNONE" height="16"> GSIS premium</td>
             <td align="right" class="thinborderNONE">
               <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
					 <%}%>
           <tr>
             <td class="thinborderNONE" height="16">Phil. Health</td>
             <td align="right" class="thinborderNONE">
                <% 
								if (vInternal != null && vInternal.size() > 0){ 
									strTemp = (String) vInternal.elementAt(13);
									dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
									strTemp = CommonUtil.formatFloat(strTemp,true);
									dSubTotalDed += dTemp; 
									if(dTemp == 0d)
										strTemp = "";			
								}	
								 %>
               <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
           <tr>
             <td class="thinborderNONE" height="16"> Pag-ibig Premium</td>
             <td align="right" class="thinborderNONE">
               <% 
						if (vInternal != null && vInternal.size() > 0){ 
							strTemp = (String) vInternal.elementAt(14);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = CommonUtil.formatFloat(strTemp,true);
							dSubTotalDed += dTemp; 
							if(dTemp == 0d)
								strTemp = "";
						}	
						 %>
               <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
           <% 
						if (vInternal != null && vInternal.size() > 0){ 
							strTemp = (String) vInternal.elementAt(54); // Ret. Plan Fund
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = CommonUtil.formatFloat(strTemp,true);
							dSubTotalDed += dTemp; 
							dTotalDeduction = dSubTotalDed;
						}	
						if(dTemp > 0d){
					 %>
           <tr>
             <td class="thinborderNONE" height="18">Ret. Plan Fund</td>
             <td align="right" class="thinborderNONE">
               <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
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
	<%}// end vInternal%><br>
<br>
<br> 
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
             <td class="thinborderNONE"><div align="right">
                 <%
		if (vDTRDetails != null && vDTRDetails.size() > 0){ 
			strTemp = (String)vDTRDetails.elementAt(17);	
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}
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
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							// This is for COLA
							strTemp = (String) vDTRManual.elementAt(31);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							dGrossSalary += dTemp;
						}	
						if(dTemp > 0d){
 						%>             					 
					 <tr> 
            <td class="thinborderNONE" height="14">&nbsp;COLA</td>
            <td align="right" class="thinborderNONE">    
		 				  <%=WI.getStrValue(strTemp,"0")%>&nbsp;</td>
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
             <td class="thinborderNONE" height="16"> Gross Pay </td>
             <td class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dGrossSalary,true)%>&nbsp;&nbsp;</div></td>
           </tr>
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
             <td width="56%" class="thinborderNONE" height="16">Tax Withheld</td>
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
             <td class="thinborderNONE" height="16"> SSS premium</td>
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
             <td class="thinborderNONE" height="16"> GSIS premium</td>
             <td class="thinborderNONE"><div align="right">
                 <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</div></td>
           </tr>
					 <%}%>
           <tr>
             <td class="thinborderNONE" height="16">Phil. Health</td>
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
             <td class="thinborderNONE" height="16"> Pag-ibig Premium</td>
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
             <td class="thinborderNONE" height="18">Ret. Plan Fund</td>
             <td class="thinborderNONE"><div align="right">
                 <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</div></td>
           </tr>
					 <%}%>
					<%
 					if(vDeductions != null && vDeductions.size() > 1 && WI.fillTextValue("excludeLoansMisc").length() == 0){
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
<%}else{
	 %>
	<%if(vInternal != null && vInternal.size() > 0){
		dGrossSalary = 0d;
		dTotalDeduction = 0d;
		dAbsenceAmt = 0d;
		dOtherEarning = 0d;
		dOtherDeduction = 0d;
		dSubTotalDed = 0d;
		dNetSalary = 0d;		
	%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
		<tr> 
			<td valign="top">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
		<tr> 
			<td width="17%" class="thinborderNONEcl" height="20">&nbsp;PAYROLL PERIOD</td>
			<%
				if(strCutOff == null || strCutOff.length() == 0){
					strCutOff = WI.fillTextValue("sal_cut_off");				
				}
			%>
			<td width="32%" class="thinborderNONEcl">&nbsp;<%=strCutOff%></td>
			<td width="28%">&nbsp;</td>
			<td width="23%">PAYSLIP</td>
		</tr>
		<tr> 
			<td height="20" class="thinborderNONEcl">&nbsp;NAME</td>
			<td class="thinborderBOTTOMonly">&nbsp;<strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%></strong></td>
		 <%if(vPersonalDetails.elementAt(13) != null && vPersonalDetails.elementAt(14) != null){
				strSlash = "-";
			 }else{
				strSlash = "";	
			 }
			 strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(13),"") + strSlash + WI.getStrValue((String)vPersonalDetails.elementAt(14),"");
		 %>
		  <td colspan="2" class="thinborderNONEcl">&nbsp;</td>
		</tr>
		<tr>
		  <td height="5" colspan="4"></td>
		  </tr>
		<tr> 
			<td height="18" colspan="2" valign="top" class="thinborderTOP"><table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr valign="bottom"> 
						<td height="25" colspan="6"><div align="center"><strong>GROSS PAY</strong></div></td>
					</tr>
					<tr>
						<td valign="bottom"><font size="1">RATE / DAY</font></td>
						<td align="right" valign="bottom"><font size="1">
							<% 
						 if (vDTRDetails != null && vDTRDetails.size() > 0){ 
							  strDailyRate = (String)vDTRDetails.elementAt(80);
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
						<td valign="bottom"><font size="1"> DAYS WORKED</font></td>
						<% 
						 if (vDTRDetails != null && vDTRDetails.size() > 0){ 
							 strTemp2 = (String)vDTRDetails.elementAt(85);			
							}else{
								strTemp2 = " ";
							}
						%>						
						<td align="right" valign="bottom"><font size="1"><%=strTemp%> (<%=CommonUtil.formatFloat(strTemp2, false)%>)</font></td>
						<td>&nbsp;</td> 
						<td height="10">&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
					  <td valign="bottom"><font size="1">BASIC SALARY</font></td>
					  <td align="right" valign="bottom">&nbsp;</td>
					  <td>&nbsp;</td>
					  <td height="10">&nbsp;</td>
						<% 
						if (vInternal != null && vInternal.size() > 0){ 
							strTemp = (String)vInternal.elementAt(38);			
							dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}
						%>						
					  <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
					  <td align="right">&nbsp;</td>
				  </tr>
					<% 
					dTemp = 0d;
					if (vInternal != null && vInternal.size() >  0){ 	
						strTemp = (String) vInternal.elementAt(25);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dGrossSalary += dTemp; 
					}
					if(dTemp > 0d){
					%>
					<tr>
						<td valign="bottom"><font size="1">NIGHT DIFFERENTIAL</font></td>
						<td align="right" valign="bottom">&nbsp;</td>
						<td>&nbsp;</td> 
						<td height="10">&nbsp;</td>
						<td align="right"><font size="1"> <%=WI.getStrValue(strTemp,"")%></font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}%>
				 <% dTemp = 0d;
					if (vInternal != null && vInternal.size() > 0){ 
						strTemp =(String) vInternal.elementAt(20);
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
						<td align="right" valign="bottom">&nbsp;</td>
						<td>&nbsp;</td> 
						<td height="10"><font size="1">&nbsp;</font></td>
						<td align="right"><font size="1"> <%=WI.getStrValue(strTemp,"")%></font></td>
						<td align="right">&nbsp;</td>
					</tr>
					<%}%>
					
					<% dTemp = 0d;
					if (vInternal != null && vInternal.size() > 0){ 
						// faculty pay
						strTemp = (String) vInternal.elementAt(44);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						strTemp = (String) vInternal.elementAt(60);
						// sub teaching salary
						dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
		
						strTemp = (String) vInternal.elementAt(67);
						// manually encoded overload Amount
						dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
		
						dGrossSalary += dTemp; 
						}					
						strTemp = CommonUtil.formatFloat(dTemp,true);			
						if(dTemp > 0d){
					 %>
					<tr>
						<td valign="bottom"><font size="1">OVERLOAD</font></td>
						<td align="right" valign="bottom">&nbsp;</td>
						<td>&nbsp;</td> 
						<td height="10">&nbsp;</td>
						<td align="right"> <font size="1"> <%=WI.getStrValue(strTemp,"")%></font></td>
						<td align="right">&nbsp;</td>
					</tr>
				 <%}%> 
					<% dTemp = 0d;
					if (vInternal != null && vInternal.size() > 0){ 
						strTemp = (String) vInternal.elementAt(10);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dGrossSalary += dTemp; 
					}	
						if(dTemp > 0d){
					%>
					<tr>
						<td valign="bottom"><font size="1">OVERTIME&nbsp;</font></td>
						<td align="right" valign="bottom">&nbsp;</td>
						<td>&nbsp;</td> 
						<td height="10"><font size="1">&nbsp;</font></td>
						<td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
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
							<td align="right" valign="bottom">&nbsp;</td>
							<td>&nbsp;</td> 
							<td>&nbsp;</td>
							<td align="right"><font size="1">
							  <% 
							strTemp = CommonUtil.formatFloat(dTemp,true);
							dGrossSalary += dTemp; 
							if(dTemp == 0d)
								strTemp = "";				
						%>
                <%=WI.getStrValue(strTemp,"")%></font></td>
							<td align="right">&nbsp;</td>
					</tr>
					<%} // end for loop
	   } // end if vVarAllowances != null %>
					<% 
					dTemp = 0d;
					if (vInternal != null && vInternal.size() > 0){ 	
						strTemp = (String) vInternal.elementAt(22);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
						dGrossSalary += dTemp;
					}
					if(dTemp > 0d) {
					%>
					<tr>
						<td width="42%"><font size="1"><%=WI.getStrValue((String) vInternal.elementAt(23))%></font></td>
						<td width="20%" align="right">&nbsp;</td>
						<td width="4%">&nbsp;</td>
						<td width="12%">&nbsp;</td>			
						<td width="19%" align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
						<td width="3%" align="right">&nbsp;</td>
					</tr>					
					<%}%>
					<tr>
						<td width="42%"><font size="1">OTHERS</font></td>
						<% 
							if (vInternal != null && vInternal.size() > 0){ 	
								strTemp = (String) vInternal.elementAt(26);
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
								dOtherEarning += dTemp;
							}
						
							strTemp = CommonUtil.formatFloat(dOtherEarning,2);
							dGrossSalary += dOtherEarning;
							if(dOtherEarning == 0d)
								strTemp = "";
						%>							
						<td width="20%" align="right">&nbsp;</td>
						<td width="4%">&nbsp;</td>
						<td width="12%">&nbsp;</td>			
						<td width="19%" align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
						<td width="3%" align="right">&nbsp;</td>
					</tr>
					<% 	
					dAbsenceAmt = 0d;		
					strTemp = null;
					if (vInternal != null && vInternal.size() > 0){ 
					// leave without pay			
						strTemp = (String) vInternal.elementAt(11);
						dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					// AWOL
						strTemp = (String) vInternal.elementAt(32);
						dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					// Lates and undertimes
						strTemp = (String) vInternal.elementAt(33);
						dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					// faculty absences
						strTemp = (String) vInternal.elementAt(45);
						dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
						dGrossSalary -= dAbsenceAmt;
					}
					if(dAbsenceAmt > 0){
						strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);
				   %>	
					<tr>
					  <td class="thinborderNONE">TARDINESS &amp; ABSENCES </td>
					  <td align="right">&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"(",")","")%></font></td>
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
					  <td align="right">&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td align="right"><font size="1">
            <% 
						strTemp = CommonUtil.formatFloat(dTemp,true);
						dGrossSalary -= dTemp; 
						if(dTemp == 0d)
							strTemp = "";				
					 %>
            <%=WI.getStrValue(strTemp,"(",")","")%></font></td>
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
					  <td align="right">&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
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
					if (vInternal != null && vInternal.size() > 0){ 
						strTemp = (String) vInternal.elementAt(24);
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
						<td valign="bottom"><font size="1">&nbsp;&nbsp;</font><font color="#000000" size="1">SSS</font></td>
						<td align="right" valign="bottom"><font size="1">
						<% 
		if (vInternal != null && vInternal.size() > 0){ 
			strTemp = (String) vInternal.elementAt(12);
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
						<td valign="bottom"><font size="1"> &nbsp;&nbsp;PHILHEALTH</font></td>
						<td align="right" valign="bottom"><font size="1">
						<% 
		if (vInternal != null && vInternal.size() > 0){ 
			strTemp = (String) vInternal.elementAt(13);
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
						<td valign="bottom"><font size="1">&nbsp;&nbsp;PAG-IBIG</font></td>
						<td align="right" valign="bottom"><font size="1">
							<% 
			if (vInternal != null && vInternal.size() > 0){ 
				strTemp = (String) vInternal.elementAt(14);
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
					<%if(bolIsSchool){%>
					<tr>
						<td valign="bottom"><font size="1">&nbsp;&nbsp;PERAA</font></td>
						<td align="right" valign="bottom"><font size="1">
						<% 
			if (vInternal != null && vInternal.size() > 0){ 
				strTemp = (String) vInternal.elementAt(54);
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
					<%} // end if(bolIsSchool)%>
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
					if (vInternal != null && vInternal.size() > 0){ 	
						strTemp = (String) vInternal.elementAt(18);//MISC_DEDUCTION (Addl ded)
						dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					}
						strTemp = CommonUtil.formatFloat(dOtherDeduction,true);
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
						<td width="36%">&nbsp;</td>
						<td width="20%">&nbsp;</td>
						<td width="4%">&nbsp;</td>
						<td width="21%">&nbsp;</td>			
						<td width="19%" align="right">&nbsp;</td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="19" colspan="2" valign="top" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="42%" height="18"><font size="1">GROSS PAY</font></td>
          <td width="20%" align="right">&nbsp;</td>
          <td width="4%" align="right">&nbsp;</td>
          <td width="12%" align="right">&nbsp;</td>
          <td width="19%"><div align="right">&nbsp;<font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%></font></div></td>
          <td width="3%">&nbsp;</td>
        </tr>
      </table></td>
			<td colspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
				
				<tr>
					<td width="55%"><font size="1">&nbsp;&nbsp;TOTAL DEDUCTIONS</font></td>
					<td width="45%"><div align="right"><font size="1">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%>&nbsp; </font></div></td>
				</tr>
				<tr>
					<td height="19" valign="bottom"><strong>&nbsp;&nbsp;NET PAY :</strong></td>
					<%
						dNetSalary += dGrossSalary - dTotalDeduction;
					%>
					<td align="right" valign="bottom"><u><strong><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%>&nbsp;</strong></u></td>
				</tr>
			</table></td>
		</tr>
	</table>	</td>
	</tr>
			
	<tr>
	<td>	
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="45%" valign="top">&nbsp;</td>			
				<td width="55%" valign="top"></td>
			</tr>			
		</table>			
		</td>
		</tr>
	 </table>	 
	 <%}%>
	 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="10"><hr noshade="noshade" size="1"></td>
		</tr>
	</table>
	<%
		// main Salary here
		dGrossSalary = 0d;
		dTotalDeduction = 0d;
		dAbsenceAmt = 0d;
		dOtherEarning = 0d;
		dOtherDeduction = 0d;
		dSubTotalDed = 0d;
		dNetSalary = 0d;		
	%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
		<tr> 
			<td valign="top">	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
		<tr> 
			<td width="17%" class="thinborderNONEcl" height="20">&nbsp;PAYROLL PERIOD</td>
			<%
				if(strCutOff == null || strCutOff.length() == 0){
					strCutOff = WI.fillTextValue("sal_cut_off");				
				}
			%>
			<td width="32%" class="thinborderNONEcl">&nbsp;<%=strCutOff%></td>
			<td width="28%">&nbsp;</td>
			<td width="23%">PAYSLIP</td>
		</tr>
		<tr> 
			<td height="19" class="thinborderNONEcl">&nbsp;NAME</td>
			<td class="thinborderBOTTOMonly">&nbsp;<strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%></strong></td>
		 <%if(vPersonalDetails.elementAt(13) != null && vPersonalDetails.elementAt(14) != null){
				strSlash = "-";
			 }else{
				strSlash = "";	
			 }
			 strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(13),"") + strSlash + WI.getStrValue((String)vPersonalDetails.elementAt(14),"");
		 %>
		  <td colspan="2" class="thinborderNONEcl">&nbsp;</td>
		</tr>
		<tr>
		  <td height="5" colspan="4"></td>
		  </tr>
		<tr> 
			<td height="18" colspan="2" valign="top" class="thinborderTOP"><table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr valign="bottom"> 
						<td height="25" colspan="6"><div align="center"><strong>GROSS PAY</strong></div></td>
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
						<td valign="bottom"><font size="1"> DAYS WORKED</font></td>
						<% 
						 if (vDTRDetails != null && vDTRDetails.size() > 0){ 
								strTemp2 = (String)vDTRDetails.elementAt(85);			
							}else{
								strTemp2 = "";
							}
						%>
						<td align="right" valign="bottom"><font size="1"><%=strTemp%> (<%=CommonUtil.formatFloat(strTemp2, false)%>)</font></td>
						<td>&nbsp;</td> 
						<td height="10">&nbsp;</td>
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
					<% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String)vDTRManual.elementAt(38);			
						dBasicPay = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dGrossSalary += dBasicPay;
					}
					%>					
					<tr>
					  <td valign="bottom"><font size="1">BASIC SALARY</font></td>
					  <td align="right" valign="bottom">&nbsp;</td>
					  <td>&nbsp;</td>
					  <td height="10">&nbsp;</td>
					  <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
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
						<td align="right" valign="bottom">&nbsp;</td>
						<td>&nbsp;</td> 
						<td height="10">&nbsp;</td>
						<td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
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
						<td align="right" valign="bottom">&nbsp;</td>
						<td>&nbsp;</td> 
						<td height="10"><font size="1">&nbsp;</font></td>
						<td align="right"><font size="1"> <%=WI.getStrValue(strTemp,"")%></font></td>
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
						<td align="right" valign="bottom">&nbsp;</td>
						<td>&nbsp;</td> 
						<td height="10">&nbsp;</td>
						<td align="right"> <font size="1"> <%=WI.getStrValue(strTemp,"")%></font></td>
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
						<td align="right" valign="bottom">&nbsp;</td>
						<td>&nbsp;</td> 
						<td height="10"><font size="1">&nbsp;</font></td>
						<td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
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
							<td align="right" valign="bottom">&nbsp;</td>
							<td>&nbsp;</td> 
							<td>&nbsp;</td>
							<td align="right"><font size="1">
              <% 
							strTemp = CommonUtil.formatFloat(dTemp,true);
							dGrossSalary += dTemp; 
							if(dTemp == 0d)
								strTemp = "";				
						%>
              <%=WI.getStrValue(strTemp,"")%></font></td>
							<td align="right">&nbsp;</td>
					</tr>
					<%} // end for loop
	   } // end if vVarAllowances != null %>
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
						<td width="20%" align="right">&nbsp;</td>
						<td width="4%">&nbsp;</td>
						<td width="12%">&nbsp;</td>			
						<td width="19%" align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
						<td width="3%" align="right">&nbsp;</td>
					</tr>					
					<%}%>
					<tr>
						<td width="42%"><font size="1">OTHERS</font></td>
						<% 
							if (vDTRManual != null && vDTRManual.size() > 0){ 	
								strTemp = (String) vDTRManual.elementAt(26);
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
								dOtherEarning += dTemp;
							}
						
							strTemp = CommonUtil.formatFloat(dOtherEarning,2);
							dGrossSalary += dOtherEarning;
							if(dOtherEarning == 0d)
								strTemp = "";
						%>							
						<td width="20%" align="right">&nbsp;</td>
						<td width="4%">&nbsp;</td>
						<td width="12%">&nbsp;</td>			
						<td width="19%" align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
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
					  <td align="right">&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"(",")","")%></font></td>
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
					  <td align="right">&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td align="right"><font size="1">
            <% 
						strTemp = CommonUtil.formatFloat(dTemp,true);
						dGrossSalary -= dTemp; 
						if(dTemp == 0d)
							strTemp = "";				
					 %>
            <%=WI.getStrValue(strTemp,"(",")","")%></font></td>
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
					  <td align="right">&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
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
						<td valign="bottom"><font size="1">&nbsp;&nbsp;</font><font color="#000000" size="1">SSS</font></td>
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
						<td valign="bottom"><font size="1"> &nbsp;&nbsp;PHILHEALTH</font></td>
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
						<td valign="bottom"><font size="1">&nbsp;&nbsp;PAG-IBIG<font color="#000000"> </font></font></td>
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
					<%if(bolIsSchool){%>
					<tr>
						<td valign="bottom"><font size="1">&nbsp;&nbsp;PERAA</font></td>
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
					<%} // end if(bolIsSchool)%>
					<%
					if(false){
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
					}
					}// end if false (Meaning dont bother showing me....)%>
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
						<td align="right">&nbsp;</td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
						<td width="36%">&nbsp;</td>
						<td width="20%">&nbsp;</td>
						<td width="4%">&nbsp;</td>
						<td width="21%">&nbsp;</td>			
						<td width="19%" align="right">&nbsp;</td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="19" colspan="2" valign="top" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
				<%if(WI.fillTextValue("show_bonus").length() > 0){%>
				<tr>
				  <td height="18" class="thinborderNONE">13th MONTH PAY </td>
				  <td align="right">&nbsp;</td>
				  <td align="right">&nbsp;</td>
				  <td align="right">&nbsp;</td>
					<%
						dBasicPay = dBasicPay/24;
						dGrossSalary += dBasicPay;
					%>
				  <td align="right"><font size="1"><%=CommonUtil.formatFloat(dBasicPay, true)%></font></td>
				  <td>&nbsp;</td>
				</tr>
				<%}%>
				<tr>
					<td width="42%" height="18"><font size="1">GROSS PAY</font></td>
					<td width="20%" align="right">&nbsp;</td>
					<td width="4%" align="right">&nbsp;</td>
					<td width="12%" align="right">&nbsp;</td>
					
					<td width="19%"><div align="right">&nbsp;<font size="1"><%=CommonUtil.formatFloat(dGrossSalary,true)%></font></div></td>
					<td width="3%">&nbsp;</td>
				</tr>
				
			</table></td>
			<td colspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
				
				<tr>
					<td width="55%"><font size="1">&nbsp;&nbsp;TOTAL DEDUCTIONS</font></td>
					<td width="45%"><div align="right"><font size="1">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%>&nbsp; </font></div></td>
				</tr>
				<tr>
					<td height="19" valign="bottom"><strong>&nbsp;&nbsp;NET PAY :</strong></td>
					<%
 						//System.out.println("dTotalDeduction- " + dTotalDeduction);
						//System.out.println("dGrossSalary- " + dGrossSalary);
						//System.out.println("dNetSalary- " + dNetSalary);
						dNetSalary += dGrossSalary - dTotalDeduction;
					%>
					<td align="right" valign="bottom"><u><strong><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%>&nbsp;</strong></u></td>
				</tr>
			</table></td>
		</tr>
	</table>		
	</td>
	</tr>
	<tr> 
		<td>		
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="45%" valign="top">
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
				<%}// end vOTEncoding%>				</td>			
				<td width="55%" valign="top"></td>
			</tr>			
		</table>			</td>
		</tr>
  </table>			
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
			  <td height="26">&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
		  </tr>
			<tr>
				<td width="42%">Received the amount in full as complete payment</td>
			  <td width="27%" align="center" class="thinborderBOTTOMonly"><span class="thinborderNONEcl">&nbsp;<strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%></strong></span></td>
			  <td width="2%">&nbsp;</td>
			  <td width="26%" align="center" class="thinborderBOTTOMonly">&nbsp;</td>
			  <td width="3%">&nbsp;</td>
			</tr>
			<tr>
			  <td>&nbsp;</td>
			  <td align="center">Name</td>
			  <td>&nbsp;</td>
			  <td align="center">Signature</td>
			  <td>&nbsp;</td>
		  </tr>
			<tr>
			  <td colspan="5"><hr noshade="noshade" size="1"></td>
		  </tr>
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
	<input type="hidden" name="skip_print" value="<%=WI.fillTextValue("skip_print")%>">  	
	<input type="hidden" name="excludeLoansMisc" value="<%=WI.fillTextValue("excludeLoansMisc")%>">  		
</form>

<script src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//get this from common.js
<%//if(WI.fillTextValue("skip_print").length() == 0){%>
//	this.autoPrint();
//	window.setInterval("javascript:window.close();",0);
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