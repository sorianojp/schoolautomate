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
	PRPayslip finalize = new PRPayslip();
	
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
}

if(WI.fillTextValue("finalize").length() > 0){
  if(!finalize.FinalizeSalary(dbOP,request,strSalIndex)){
	strErrMsg = "Error";
  }	

  // this is for the unreleased salary
  if(vSalIndex != null && vSalIndex.size() > 0){
    for(i = 1;i < vSalIndex.size(); i++){	
      if(!finalize.FinalizeSalary(dbOP,request,(String)vSalIndex.elementAt(i), strSalIndex)){
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
<body>
<form>
<%if(!strSchCode.startsWith("CPU")){
  if(!strSchCode.startsWith("CGH")){
	if(!strSchCode.startsWith("AUF")){
	if(!strSchCode.startsWith("UI")){
	if(!strSchCode.startsWith("UDMC")){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="40" colspan="5" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong>
        <%if(!strSchCode.startsWith("CLDH")){%>
		<br><%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
		<%}%>
		<%if(strSchCode.startsWith("VMUF")){%>		
		,&nbsp;<%=SchoolInformation.getAddressLine2(dbOP,false,false)%><br><br>	
        Human Resources Development Office<br>
		Tel Nos. (075) 634 2693;532-2380;955 5054 loc. 137<br><br>
		<%}%>
	  </td>
    </tr>
</table>
  <%if(!strSchCode.startsWith("CLDH")){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="3" height="18"><div align="center"><strong>EMPLOYEE PAYROLL 
          SLIP</strong></div></td>
    </tr>	
  </table>
  <%} // ! CLDH%>
  <%  }// !UDMC
		 }// !UI
    }// !AUF
   }// !CGH
  }// !CPU %>
  <%if(strSchCode.startsWith("UI")){%>
   <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
    <tr>
      <td height="18" colspan="4"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></div></td>
     </tr>
    <tr> 
      <td width="292" height="18"><font size="1"><strong>Name :</strong> 
        <%
	  if (vPersonalDetails != null && vPersonalDetails.size() > 0 ) {%>
        <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4).toUpperCase()%></strong> 
      <%}%></font></td>
      <td width="142" height="18"><font size="1"><strong>Payroll Slip</strong></font></td>
      <td width="115" align="right"><font size="1"><strong>DATE:</strong></font></td>
      <td width="214" align="right"><font size="1"><strong><%=WI.getStrValue(strPayrollPeriod,"0")%></strong></font></td>
    </tr>	
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#000000">	
    <tr> 
      <td height="187" colspan="2" valign="top" class="thinborderTOPLEFTBOTTOM"> 
        <div align="left"> 
          <table width="100%" border="0" cellpadding="0" cellspacing="0">
            <tr> 
              <td height="16" valign="top">&nbsp;</td>
              <td align="center"><strong><font size="1">Period</font></strong></td>
              <td align="center"><strong><font size="1">Daily/Hrs.</font></strong></td>
              <td colspan="2" align="center"><strong><font size="1">ABSENT</font></strong></td>
              <td align="center">&nbsp;</td>
            </tr>
            <tr> 
              <td height="16" class="thinborderBOTTOM"><font size="1"><strong>Dept.</strong></font></td>
              <td align="center" class="thinborderBOTTOM"><font size="1"><strong>Rate</strong></font></td>
              <td align="center" class="thinborderBOTTOM"><font size="1"><strong>Rate</strong></font></td>
              <td align="center" class="thinborderBOTTOM"><font size="1"><strong>NO.</strong></font></td>
              <td align="center" class="thinborderBOTTOM"><font size="1"><strong>AMT.</strong></font></td>
              <td align="center" class="thinborderBOTTOM"><strong><font size="1">TOTAL</font></strong></td>
            </tr>
            <tr> 
              <td width="16%" height="13"  class="thinborderNONE"><font size="1">&nbsp;Admin</font></td>
        <% if ((String)vPersonalDetails.elementAt(11) == null){
						 if (vDTRDetails != null && vDTRDetails.size() > 0){ 
								strTemp = (String)vDTRDetails.elementAt(17);			
								dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						 }
					  //System.out.println("vDTRDetails " + vDTRDetails);
					  strTemp = WI.getStrValue(strTemp,"0");
					  dTempSalary = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
					  //if (vPayPerCollege != null && vPayPerCollege.size() > 0){						
						//	for(int j = 0;j < vPayPerCollege.size(); j+=3){
						//		if (vPayPerCollege.elementAt(j+1) == null){
						//		 dTempSalary += ((Double)vPayPerCollege.elementAt(j)).doubleValue();							
						//		}
						//	}
					  //}
					}else{
						strTemp = " ";
					}				
				%>
              <td width="13%"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
              <% if ((String)vPersonalDetails.elementAt(11) == null){
					 if (vDTRDetails != null && vDTRDetails.size() > 0){ 
						 strDailyRate = (String)vDTRDetails.elementAt(18);			
						 strHourlyRate = (String)vDTRDetails.elementAt(19);
					  }else{
						strDailyRate = " ";
						strHourlyRate = " ";
					  }
					  if((String)vDTRDetails.elementAt(18) == null || (String)vDTRDetails.elementAt(19) == null)
						  strSlash = " ";				
					  else
						  strSlash = "/";									
				  }else{
						strDailyRate = " ";
						strHourlyRate = " ";
 				  }	
				%>
              <td width="24%" class="thinborderNONE"><div align="right"> 
                  <%=WI.getStrValue(strDailyRate," ")%><%=strSlash%><%=WI.getStrValue(strHourlyRate," ")%></div></td>
              <td width="12%"  class="thinborderNONE">&nbsp;</td>
              <% dTemp = 0d;
			    if ((String)vPersonalDetails.elementAt(11) == null){
						if (vDTRManual != null && vDTRManual.size() > 0){ 	
							strTemp = (String) vDTRManual.elementAt(32);//AWOL_AMT
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
							dGrossSalary -= dTemp;
						}				  
			    }
				if(dTemp == 0d)
				  strTemp = "";
		      %>
              <td width="15%" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
              <td width="20%" class="thinborderNONE"><div align="right"> 
                  <%if ((String)vPersonalDetails.elementAt(11) == null){%>
                  <%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%> 
                  <%}%>&nbsp;
                </div></td>
            </tr>
				<%if (vColleges != null && vColleges.size() > 0){%>
				<%for(i = 0;i<vColleges.size();i+=4){
					strSlash = "";
					dTempSalary = 0d;
					dAbsenceAmt = 0d;
				%>				
            <tr> 
              <td width="16%" height="13" class="thinborderNONE">&nbsp;<%=WI.getStrValue((String)vColleges.elementAt(i+1),"")%></td>
              <% dTempSalary = 0d;
			  if ((String)vPersonalDetails.elementAt(11) != null){
				 if (vDTRDetails != null && vDTRDetails.size() > 0){ 
						if(((String) vColleges.elementAt(i)).equals((String)vPersonalDetails.elementAt(11))){
							strTemp = (String)vDTRDetails.elementAt(17);			
							//dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}else{
								strTemp = " ";	
						}
				  }else{
		     	   	 strTemp = " ";
        	}
				 strTemp = WI.getStrValue(strTemp,"0");
				 dTempSalary = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));				 
				 if (vPayPerCollege != null && vPayPerCollege.size() > 0){
						for(int j = 0;j < vPayPerCollege.size(); j+=3){
							if (((String)vPayPerCollege.elementAt(j+1)).equals((String) vColleges.elementAt(i))){
								dTempSalary += ((Double)vPayPerCollege.elementAt(j)).doubleValue();
								break;
							}
						}					
				  }
				  //dGrossSalary +=dTempSalary;
				  strTemp = CommonUtil.formatFloat(dTempSalary,true);				  	
			   }
			   if(dTempSalary == 0d)
			   	strTemp = "";
  			   %>
              <td width="13%" class="thinborderNONE"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
              <% 
				  if ((String)vPersonalDetails.elementAt(11) != null){
					 if (vDTRDetails != null && vDTRDetails.size() > 0){
						if(((String) vColleges.elementAt(i)).equals((String)vPersonalDetails.elementAt(11))){
						  strDailyRate = (String)vDTRDetails.elementAt(18);			
						  strHourlyRate = (String)vDTRDetails.elementAt(19);			
						  if((String)vDTRDetails.elementAt(18) == null || (String)vDTRDetails.elementAt(19) == null)
							  strSlash = " ";				
						  else
							  strSlash = "/";
						}else{
						  strDailyRate = " ";
						  strHourlyRate = " ";		
						}
					  }else{
							 strDailyRate = " ";
							 strHourlyRate = " ";	
					  }						
				   }else{
						 strDailyRate = " ";
						 strHourlyRate = " ";	
				   }
  			   %>
              <td width="24%" class="thinborderNONE"><div align="right"> <%=WI.getStrValue(strDailyRate," ")%><%=strSlash%><%=WI.getStrValue(strHourlyRate," ")%></div></td>
              <td width="12%" class="thinborderNONE">&nbsp;</td>
              <% dAbsenceAmt = 0d;
			 if ((String)vPersonalDetails.elementAt(11) != null){
		  		if(((String) vColleges.elementAt(i)).equals((String)vPersonalDetails.elementAt(11))){
					if (vDTRManual != null && vDTRManual.size() > 0){ 					
						strTemp = (String) vDTRManual.elementAt(32);//AWOL_AMT
						//dGrossSalary -= Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					}
				}else{
					strTemp = "";
				}				
			 	strTemp = WI.getStrValue(strTemp,"0");
			 	dAbsenceAmt = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				//System.out.println("indexmain --------- "+(String) vColleges.elementAt(i));	
			 	if (vFacAbsences != null && vFacAbsences.size() > 0){				 	
				  for(int j = 0;j < vFacAbsences.size(); j+=3){				  		
					//System.out.println("index "+(String)vFacAbsences.elementAt(j+2));					
					//System.out.println("colleger "+(String) vColleges.elementAt(i));
						if (vFacAbsences.elementAt(j+2)!= null)	{
							if (((String)vFacAbsences.elementAt(j+2)).equals((String) vColleges.elementAt(i))){							
								dAbsenceAmt += ((Double)vFacAbsences.elementAt(j+1)).doubleValue();
								break;
							}
						}					
				  }					
			  }				
			  //	dGrossSalary -=dAbsenceAmt;
			  	strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);
			}
			if(dAbsenceAmt == 0d)
				strTemp = "";
		   %>
              <td width="15%" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
			<%
			dTemp = 0d;
			if ((String)vPersonalDetails.elementAt(11) != null){
			   if (vDTRDetails != null && vDTRDetails.size() > 0){ 
			     dTemp = dTempSalary - dAbsenceAmt;
				 dGrossSalary += dTemp;
			//if(((String) vColleges.elementAt(i)).equals((String)vPersonalDetails.elementAt(11))){
			//}// end equals condition
				strTemp = CommonUtil.formatFloat(dTemp,true);
			   }//end if (vDTRDetails != null
			}// end if vPersonalDetails!=null
			if(dTemp == 0d)
				strTemp = "";
			%> 
              <td width="20%" class="thinborderNONE"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
            </tr>
            <%}// end for(i = 0;i<vCollege...%>
            <%}/// end if %>
            <tr> 
              <td width="16%" height="13" class="thinborderNONE"><font size="1">&nbsp;Hon.</font></td>
			<% dTemp = 0d;
			  if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String)vDTRManual.elementAt(43);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				dGrossSalary += dTemp;
			  }
			  if(dTemp == 0d)
				strTemp = "";			  	
			%>
              <td width="13%" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
              <td width="24%" class="thinborderNONE">&nbsp;</td>
              <td width="12%" class="thinborderNONE">&nbsp;</td>
              <td width="15%" class="thinborderNONE">&nbsp;</td>
              <td width="20%" class="thinborderNONE">&nbsp;</td>
            </tr>
          </table>
        </div></td>
      <td width="25%" valign="top" class="thinborderTOPLEFTBOTTOM"> <table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td height="16" colspan="2"><strong><font size="1">DEDUCTION</font></strong></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td height="16" colspan="2" class="thinborderBOTTOM"><strong><font size="1">TYPE</font></strong></td>
            <td class="thinborderBOTTOM">&nbsp;</td>
            <td class="thinborderBOTTOM"><div align="right"><strong><font size="1">AMT.&nbsp;&nbsp;</font></strong></div></td>
          </tr>
          <tr> 
            <td width="3%" height="13">&nbsp;</td>
            <td width="61%" class="thinborderNONE">Pag-ibig Premium </td>
            <td width="8%">&nbsp;</td>
            <% dTemp = 0d;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(14);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			}			
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";
		   %>
            <td width="28%" align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td class="thinborderNONE">SSS</td>
            <td><font size="1">&nbsp;</font></td>
            <% dTemp = 0d;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(12);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			}			
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";
		   %>
            <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td class="thinborderNONE">PhilHealth</td>
            <td><font size="1">&nbsp;</font></td>
            <% dTemp = 0d;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(13);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			}			
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";
		   %>
            <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td class="thinborderNONE">W/ Tax</td>
            <td><font size="1">&nbsp;</font></td>
            <% dTemp = 0d;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(24);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			}			
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";	
		   %>
            <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
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
            <td height="13">&nbsp;</td>
            <td class="thinborderNONE"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
            <td>&nbsp;</td>
            <% 
							strTemp = CommonUtil.formatFloat(dTemp,true);
							dTotalDeduction += dTemp; 
							if(dTemp == 0d)
								strTemp = "";				
						%>
            <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
          </tr>
						<%}// end for loop
						}// end checking for null%>					
          <tr> 
            <td height="13">&nbsp;</td>
            <td class="thinborderNONE">Others</td>
            <td><font size="1">&nbsp;</font></td>
            <% 
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(11);//LEAVE_DEDUCTION_AMT
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				
				strTemp = (String) vDTRManual.elementAt(33);//LATE_UNDER_AMT
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				
				strTemp = (String) vDTRManual.elementAt(18);//MISC_DEDUCTION (Addl ded)
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			} 
			
				strTemp = CommonUtil.formatFloat(dOtherDeduction,true);
				dTotalDeduction += dOtherDeduction;
				if(dOtherDeduction ==0d)
					strTemp = "";
		   %>
            <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
          </tr>
        </table></td>
      <td width="25%" valign="top" class="thinborderBOTTOMLEFTRIGHT"> <table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="4%" height="16" class="thinborderTOP">&nbsp;</td>
            <td width="69%" class="thinborderTOP">&nbsp;</td>
            <td width="9%" class="thinborderTOP">&nbsp;</td>
            <td width="18%" class="thinborderTOP">&nbsp;</td>
          </tr>
          <tr> 
            <td height="16" class="thinborderBOTTOM">&nbsp;</td>
            <td class="thinborderBOTTOM">&nbsp;</td>
            <td class="thinborderBOTTOM">&nbsp;</td>
            <td class="thinborderBOTTOM">&nbsp;</td>
          </tr>
          <tr> 
            <td height="18">&nbsp;</td>
            <td class="thinborderNONE"><strong>TOTAL</strong></td>
            <td>&nbsp;</td>
            <%/* This was removed because they dont want to show/include the additional pay in the payslip
						// refer to the page ../reports/payroll_summary_addl_pay.jsp
		if (vDTRManual != null && vDTRManual.size() > 0){  
			strTemp = (String) vDTRManual.elementAt(27); // addl_resp_amt
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

			if (vSalIncentives != null && vSalIncentives.size() > 0){ 
				strTemp = ((Double) vSalIncentives.elementAt(0)).toString();
				dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			}	

			strTemp = (String) vDTRManual.elementAt(26);// HOLIDAY_PAY_AMT
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

			strTemp = (String) vDTRManual.elementAt(17);//ADDL_PAYMENT_AMT
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

			strTemp = (String) vDTRManual.elementAt(22);//ADHOC_BONUS
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

			strTemp = (String) vDTRManual.elementAt(25);//NIGHT_DIFF_AMT
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

			strTemp = (String) vDTRManual.elementAt(10);//OT_AMT
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		} */	
	   %>
            <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%></font></div></td>
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
            <td>&nbsp;</td>
            <td colspan="2" class="thinborderNONE">&nbsp;<%=strTemp%></td>
            <% 
							strTemp = CommonUtil.formatFloat(dTemp,true);
							dGrossSalary += dTemp; 
							if(dTemp == 0d)
								strTemp = "";				
						%>						
            <td align="right">&nbsp;<font size="1"><%=strTemp%></font></td>
          </tr>
					<%}// end for loop					
					}// end if vEarnings != null%>
          <% 
				/*	
				dTemp = 0d;
				if (vVarAllowances != null && vVarAllowances.size() > 2){
						for(i = 2;i < vVarAllowances.size(); i+=6){
					strTemp = WI.getStrValue((String)vVarAllowances.elementAt(i+3),"0");
					dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
					} // end for loop
					dGrossSalary += dTemp; 
				} // end if vVarAllowances != null 
				if(dTemp > 0d){*/
				%>
				 <!--
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2" class="thinborderNONE"><strong>Other Allowances</strong><font size="1">&nbsp;</font></td>
            <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dTemp,true),"")%></font></div></td>
          </tr>
					-->
          <%//} // end if dTemp > 0%>
          <tr> 
            <td height="18">&nbsp;</td>
            <td class="thinborderNONE"><strong>COLA</strong></td>
            <td><font size="1">&nbsp;</font></td>
          <% 
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						strTemp = (String) vDTRManual.elementAt(31);
						dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					}	
					 %>
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%></font></div></td>
          </tr>
					
					<%
						dGrossSalary += dOtherEarning;
						if(dOtherEarning > 0d){
					%>
          <tr>
            <td height="18">&nbsp;</td>
            <td class="thinborderNONE"><strong>Other</strong></td>
            <td>&nbsp;</td>
            <td align="right"><font size="1"><%=CommonUtil.formatFloat(dOtherEarning,2)%></font></td>
          </tr>
					<%}%>
          <!--
						<%dUnreleasedSalary = 0d;%>
					<tr>
            <td height="18">&nbsp;</td>
            <td class="thinborderNONE"><strong>Prev. Pay</strong></td>
            <td>&nbsp;</td>
            <td><div align="right"><font size="1"><%=CommonUtil.formatFloat(dUnreleasedSalary,true)%></font></div></td>
          </tr>
					-->
          <tr> 
            <td class="thinborderTOP" height="18">&nbsp;</td>
            <td class="thinborderTOP"><strong>GROSS PAY</strong></td>
            <td class="thinborderTOP"><font size="1">&nbsp;</font></td>
            <td class="thinborderTOP"><div align="right"><font size="1">&nbsp;<%=CommonUtil.formatFloat(dGrossSalary,2)%></font></div></td>
          </tr>
          <tr> 
            <td height="18">&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td class="thinborderTOP" height="18">&nbsp;</td>
            <td class="thinborderTOP"><strong>TOTAL DEDUCTIONS</strong></td>
            <td class="thinborderTOP"><font size="1">&nbsp;</font></td>
            <td class="thinborderTOP"><div align="right"><font size="1">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%></font></div></td>
          </tr>
          <!--
		  <tr> 
            <td height="18">&nbsp;</td>
            <td><font size="1"><strong>ADJUSTMENT AMOUNT</strong></font></td>
            <td><font size="1">&nbsp;</font></td>
            <%/* 
				if (vDTRManual != null && vDTRManual.size() > 0){ 
				  if (Double.parseDouble(ConversionTable.replaceString((String) vDTRManual.elementAt(20),",","")) < 0){
					strTemp = "(" + ConversionTable.replaceString((String) vDTRManual.elementAt(20),"-","") + ")";
					dTotalDeduction -= Double.parseDouble(ConversionTable.replaceString((String) vDTRManual.elementAt(20),",",""));
				  }else{
					strTemp =(String) vDTRManual.elementAt(20);
					dGrossSalary += Double.parseDouble(ConversionTable.replaceString((String) vDTRManual.elementAt(20),",",""));			
				  }
				}	*/
			   %>
            <td><div align="right"><font size="1">&nbsp;<strong><%//=WI.getStrValue(strTemp,"0")%></strong></font></div></td>
          </tr>
		  -->
          <tr> 
            <td height="13">&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td class="thinborderTOP" height="20">&nbsp;</td>
            <td class="thinborderTOP">&nbsp;</td>
            <td class="thinborderTOP">&nbsp;</td>
            <td class="thinborderTOP">&nbsp;</td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="20">&nbsp;</td>
            <td class="thinborderNONE"><strong>NET PAY </strong></td>
            <td class="thinborderNONE"><font size="1">&nbsp;</font></td>
            <%
				dNetSalary += dGrossSalary - dTotalDeduction + dUnreleasedSalary;
			%>
            <td class="thinborderNONE"><div align="right"><font size="1">&nbsp;<strong><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%></strong></font></div></td>
          </tr>
        </table></td>
    </tr>

  </table>	  
  <%}else if(strSchCode.startsWith("CPU")){%>
	<%
	if (vDTRDetails != null && vDTRDetails.size() > 0  && vDTRManual != null && vDTRManual.size() > 0){
	%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#000000">
    <tr> 
      <td colspan="4"><div align="center"><font size="1">Central Philippine University 
          - Employee Receipt No. <%=WI.fillTextValue("rec_no")%>&nbsp;<%=WI.getStrValue(WI.fillTextValue("tenure"),""," Payroll","")%></font></div></td>
      <td><div align="center"><font size="1">Central Philippine University</font></div></td>
    </tr>
    <tr> 
      <td colspan="4"><font size="1">Received from CPU, the amount stated below, 
        which is accepted in full for my services for the period&nbsp;<%=WI.getStrValue(strPayrollPeriod,"&nbsp;")%></font></td>
      <td><font size="1"> Employee Receipt No. <%=WI.fillTextValue("rec_no")%>&nbsp;<%=WI.getStrValue(WI.fillTextValue("tenure"),""," Payroll","")%></font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td colspan="2">Name : 
        <%			
	  if (vPersonalDetails != null && vPersonalDetails.size() > 0 ) {%> <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> <%}%> &nbsp; </td>
      <td><div align="right"><font size="1"><%=WI.getStrValue(strEmpID,"EmpNo. ","","")%>&nbsp;</font></div></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;&nbsp;Name : 
        <%			
	  if (vPersonalDetails != null && vPersonalDetails.size() > 0 ) {%>
        <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> 
        <%}%>
        </font></td>
    </tr>
    <tr> 
      <%	
		if (vPersonalDetails!= null && vPersonalDetails.size() > 0 ) {			
			strTemp = (String)vPersonalDetails.elementAt(15);
		}else{
			strTemp = null;	
		}			
		%>
      <td colspan="4"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <font size="1"><%=astrPtFt[Integer.parseInt(WI.getStrValue(strPtFt,"2"))]%> <%=WI.getStrValue(strTemp,"",","," ")%> 
        <%if(vPersonalDetails.elementAt(13) != null && vPersonalDetails.elementAt(14) != null){
			strTemp = ";";
		  }else{
			strTemp = "";	
		  }
		%>
        <%=WI.getStrValue((String)vPersonalDetails.elementAt(13),"")%> <%=strTemp%> <%=WI.getStrValue((String)vPersonalDetails.elementAt(14),"")%> 
		<%if(WI.fillTextValue("is_atm").equals("1")){%>
		&nbsp;(ATM)
		<%}%>
		</font> 
        <div align="right"></div></td>
      <td> <font size="1"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=astrPtFt[Integer.parseInt(WI.getStrValue(strPtFt,"2"))]%> 
        <%	
		if (vPersonalDetails!= null && vPersonalDetails.size() > 0 ) {			
			strTemp = (String)vPersonalDetails.elementAt(15);
		}else{
			strTemp = null;	
		}			
		%>
        <%=WI.getStrValue(strTemp," ")%></font></td>
    </tr>
    <tr> 
      <%	
		if (vDTRDetails!= null && vDTRDetails.size() > 0 ) {			
			strTemp = (String)vDTRDetails.elementAt(26);
		}else{
			strTemp = null;	
		}			
		%>
      <td colspan="2">Monthly Basic: <font size="1"><%=WI.getStrValue(strTemp," ")%></font></td>
      <td colspan="2"><div align="right"><font size="1"><%=WI.getStrValue(WI.fillTextValue("bank_account"),"Bank Acct: ","","")%>&nbsp;</font></div></td>
      <td><font size="1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="18"><font size="1"><strong>EARNINGS</strong></font></td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td width="20%" height="187" valign="top" class="thinborderTOPLEFT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <%			 
				 strTemp = (String)vDTRDetails.elementAt(17);
				 strTemp = ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",","");
				 dTempSalary = Double.parseDouble(strTemp);
				 
				 strTemp = (String)vDTRManual.elementAt(44);
				 strTemp = ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",","");
				 dTempSalary += Double.parseDouble(strTemp);				 
				 dGrossSalary += dTempSalary;
				 strTemp = Double.toString(dTempSalary);
			%>
          <%if(dTempSalary > 0){%>
          <tr> 
            <td width="63%"><font size="1">Salary</font></td>
            <td width="37%" height="15"><div align="right"><font size="1"><%=WI.getStrValue(strTemp," ")%>&nbsp;</font></div></td>
          </tr>
          <%}%>
          <% 			
				strTemp = (String) vDTRManual.elementAt(31);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				dGrossSalary += dTemp;
		   %>
          <%if (dTemp > 0){%>
          <tr> 
            <td width="63%" class="thinborderNONE">COLA</td>
            <td width="37%" height="15" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</font></div></td>
          </tr>
          <%}%>
          <% 
				strTemp = (String) vDTRManual.elementAt(10);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				dGrossSalary += dTemp;
		   %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="thinborderNONE">Overtime</td>
            <td height="15" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</font></div></td>
          </tr>
          <%}%>
          <% 
			strTemp = (String) vDTRManual.elementAt(25);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			dGrossSalary += dTemp;
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="thinborderNONE">Night Differential</td>
            <td height="15" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</font></div></td>
          </tr>
          <%}%>
          <% 
				strTemp = (String) vDTRManual.elementAt(26);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				dGrossSalary += dTemp;
			%>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="thinborderNONE">Holiday Pay</td>
            <td height="15" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</font></div></td>
          </tr>
          <%}%>
          <% 
			strTemp = (String)vDTRDetails.elementAt(20);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			dGrossSalary += dTemp;
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="thinborderNONE"><font size="1">Additonal Compensation / 
              <br>
              Part-time</font></td>
            <td height="15" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</font></div></td>
          </tr>
          <%}%>
          <% dTemp = 0d;
			if (vSalIncentives != null && vSalIncentives.size() > 0){ 
				dTemp = ((Double) vSalIncentives.elementAt(0)).doubleValue();					
			}	
			dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vDTRManual.elementAt(43),"0"),",",""));				
			strTemp = Double.toString(dTemp);
			dGrossSalary += dTemp;
			%>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="thinborderNONE"><font size="1">Incentives</font></td>
            <td height="15" class="thinborderNONE"><div align="right"><font size="1"><%=CommonUtil.formatFloat(WI.getStrValue(strTemp,"0"),true)%>&nbsp;</font></div></td>
          </tr>
          <%}%>
          <% 			
				strTemp = (String) vDTRManual.elementAt(17);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				dGrossSalary += dTemp;

		   %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="thinborderNONE"><font size="1">Additional Payment Amount</font></td>
            <td height="15" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</font></div></td>
          </tr>
          <%}%>
          <% 
				strTemp = (String) vDTRManual.elementAt(22);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				dGrossSalary += dTemp;
			%>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="thinborderNONE"><font size="1">Additional Bonus Amount</font></td>
            <td height="15" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</font></div></td>
          </tr>
          <%}%>
          <tr> 
            <td class="thinborderNONE">Adjustment</td>
            <% 
			  if (Double.parseDouble(ConversionTable.replaceString((String) vDTRManual.elementAt(20),",","")) < 0){
				strTemp = "(" + ConversionTable.replaceString((String) vDTRManual.elementAt(20),"-","") + ")";
				dTotalDeduction -= Double.parseDouble(ConversionTable.replaceString((String) vDTRManual.elementAt(20),",",""));
			  }else{
				strTemp =(String) vDTRManual.elementAt(20);
				dNetSalary += Double.parseDouble(ConversionTable.replaceString((String) vDTRManual.elementAt(20),",",""));			
			  }
		   %>
            <td height="20" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</font></div></td>
          </tr>
        </table></td>
      <td width="20%" valign="top" class="thinborderTOPLEFT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td height="18"><font size="1">&nbsp;<strong>DEDUCTION</strong></font></td>
            <td>&nbsp;</td>
          </tr>
          <% 			
			strTemp = (String) vDTRManual.elementAt(14);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			dTotalDeduction += dTemp;
		   %>
          <%if (dTemp > 0){%>
          <tr> 
            <td width="61%" height="15"><font size="1">PAG-IBIG</font> </td>
            <td width="24%"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%></font>&nbsp;</div></td>
          </tr>
          <%}%>
          <% 
				strTemp = (String) vDTRManual.elementAt(12);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				dTotalDeduction += dTemp;
		   %>
          <%if (dTemp > 0){%>
          <tr> 
            <td height="15"><font size="1">SSS</font></td>
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%></font>&nbsp;</div></td>
          </tr>
          <%}%>
          <% 
				strTemp = (String) vDTRManual.elementAt(13);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				dTotalDeduction += dTemp;
		   %>
          <%if (dTemp > 0){%>
          <tr> 
            <td height="15"><font size="1">PhilHealth</font></td>
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%></font>&nbsp;</div></td>
          </tr>
          <%}%>
          <% 
				strTemp = (String) vDTRManual.elementAt(24);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				dTotalDeduction += dTemp;
		   %>
          <%if (dTemp > 0){%>
          <tr> 
            <td height="15"><font size="1">W/Holding Tax</font></td>
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%></font>&nbsp;</div></td>
          </tr>
          <%}%>
          <%  if (vLoansAndAdv != null && vLoansAndAdv.size() > 1 ){
		  for (i = 1; i < vLoansAndAdv.size(); i +=9){
		  strTemp = (String)vLoansAndAdv.elementAt(i + 1);
		  dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		  dTotalDeduction += dTemp;
		   %>
          <%if (dTemp > 0){%>
          <tr> 
            <td height="15"><font size="1"><%=WI.getStrValue((String)vLoansAndAdv.elementAt(i+4),"")%></font></td>
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%></font>&nbsp;</div></td>
          </tr>
          <%}%>
          <%}// end for loop here
 		  }//end checking for null%>
          <%  if (vMiscDeductions != null && vMiscDeductions.size() > 0 ){
		  for (i = 1; i < vMiscDeductions.size(); i +=4){
			strTemp = (String)vMiscDeductions.elementAt(i + 2);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			dTotalDeduction += dTemp;
			%>
          <%if (dTemp > 0){%>
          <tr> 
            <td height="15"><font size="1"><%=WI.getStrValue((String)vMiscDeductions.elementAt(i+1),"")%></font></td>
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%></font>&nbsp;</div></td>
          </tr>
          <%}%>
          <%}// end for loop here
	 	  }//end checking for null%>
          <%  if (vOtherCons != null && vOtherCons.size() > 0 ){
		  for (i = 1; i < vOtherCons.size(); i +=5){
			strTemp = (String)vOtherCons.elementAt(i);
		dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		dTotalDeduction += dTemp;
		%>
          <%if (dTemp > 0){%>
          <tr> 
            <td height="15"><font size="1"><%=WI.getStrValue((String)vOtherCons.elementAt(i+4),"")%></font></td>
            <td><div align="right"><font size="1"> <%=WI.getStrValue(strTemp,"0")%></font>&nbsp;</div></td>
          </tr>
          <%}%>
          <%}// end for loop here
	 	  }//end checking for null%>
          <tr> 
            <td height="15"><font size="1">Others</font></td>
            <% 
				strTemp = (String) vDTRManual.elementAt(11);//LEAVE_DEDUCTION_AMT
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

				strTemp = (String) vDTRManual.elementAt(32);//AWOL
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
	
				strTemp = (String) vDTRManual.elementAt(33);//LATE_UNDER_AMT
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
	
				strTemp = (String) vDTRManual.elementAt(18);//MISC_DEDUCTION (Addl ded)
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			
				strTemp = (String) vDTRManual.elementAt(45); // faculty absence					
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

				strTemp = (String) vDTRManual.elementAt(56);// earnings deductions
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

				dTotalDeduction +=dOtherDeduction;
		   %>
            <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dOtherDeduction,true),"0")%></font>&nbsp;</div></td>
          </tr>
        </table></td>
      <td width="20%" valign="top" class="thinborderTOP">&nbsp;</td>
      <td width="17%" valign="top" class="thinborderTOPLEFT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="76%" height="18"><div align="right"><font size="1"><strong>NET 
                PAY &nbsp;&nbsp;&nbsp;&nbsp;</strong></font></div></td>
          </tr>
          <tr> 
            <%
				dNetSalary += dGrossSalary - dTotalDeduction;
			%>
            <td height="20"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
          </tr>
          <tr> 
            <td height="20">&nbsp;</td>
          </tr>
          <tr> 
            <td height="20">&nbsp;</td>
          </tr>
          <tr> 
            <td height="20">&nbsp;</td>
          </tr>
          <tr> 
            <td height="21">&nbsp;</td>
          </tr>
          <tr> 
            <td height="20">&nbsp;</td>
          </tr>
          <tr> 
            <td height="20">&nbsp;</td>
          </tr>
          <tr> 
            <td height="20"><div align="right"><font size="1">Period Ending : 
                <%=WI.getStrValue(strPeriodEnding,"0")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr>
            <td height="20"><div align="right"><font size="1">Gross Pay To Date: 
                <%=CommonUtil.formatFloat(WI.getStrValue(strGrossPayTotal,"0"),true)%>&nbsp;&nbsp;</font></div></td>
          </tr>
        </table></td>
      <td width="23%" valign="top" class="thinborderTOPLEFTRIGHT"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <%if(vPersonalDetails.elementAt(13) != null && vPersonalDetails.elementAt(14) != null){
				strTemp = ";";
			  }else{
			  	strTemp = "";	
			  }
			%>
            <td colspan="2" height="20"><div align="center"><font size="1"><%=WI.getStrValue((String)vPersonalDetails.elementAt(13),"")%><%=strTemp%> <%=WI.getStrValue((String)vPersonalDetails.elementAt(14),"")%></font></div></td>
          </tr>
          <tr> 
            <td width="66%" height="20">&nbsp;</td>
            <td width="34%">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="2" height="20"><font size="1">&nbsp;Period of <%=WI.getStrValue(strPayrollPeriod,"0")%></font></td>
          </tr>
          <tr> 
            <td height="20">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td height="20"><font size="1">&nbsp;Gross Earnings</font></td>
            <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%></font></div></td>
          </tr>
          <tr> 
            <td height="20"><font size="1">&nbsp;Total Deductions</font></td>
            <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%></font></div></td>
          </tr>
          <tr> 
            <td height="20"><font size="1">&nbsp;NET PAY</font></td>
            <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%></font></div></td>
          </tr>
          <tr> 
            <td height="20">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="2" height="20"><font size="1">&nbsp;Period Ending : <%=WI.getStrValue(strPeriodEnding,"0")%>&nbsp;&nbsp;&nbsp;</font></td>
          </tr>
          <tr>
            <td colspan="2" height="20"><font size="1">Gross Pay To Date: <%=CommonUtil.formatFloat(WI.getStrValue(strGrossPayTotal,"0"),true)%></font></td>
          </tr>
          <tr> 
            <td colspan="2" height="20"><font size="1">&nbsp;Payment RECEIVED:</font></td>
          </tr>
          <tr> 
            <td colspan="2" height="20"><font size="1">&nbsp;<%=WI.getStrValue(WI.fillTextValue("bank_account"),"Bank Acct: ","","")%>&nbsp;&nbsp;</font></td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="10" class="thinborderLEFT">&nbsp;</td>
      <td class="thinborderLEFT">&nbsp;</td>
      <td>&nbsp;</td>
      <td class="thinborderLEFT">&nbsp;</td>
      <td class="thinborderLEFTRIGHT">&nbsp;</td>
    </tr>
    <tr> 
      <td height="38" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="61%" height="18"><font size="1">&nbsp;TOTAL</font></td>
            <td width="24%"><div align="right"><strong><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%>&nbsp;&nbsp;</font></strong></div></td>
          </tr>
        </table></td>
      <td valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="61%" height="18"><font size="1">&nbsp;TOTAL</font></td>
            <td width="24%"><div align="right"><strong><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%>&nbsp;&nbsp;</font></strong></div></td>
          </tr>
        </table></td>
      <td valign="top" class="thinborderBOTTOM">&nbsp;</td>
      <td valign="top" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td valign="top" class="thinborderBOTTOMLEFTRIGHT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="8%" height="18"><font size="1">&nbsp;</font></td>
            <td width="31%" class="thinborderBOTTOM">&nbsp;</td>
            <td width="12%">&nbsp;</td>
            <td width="38%" class="thinborderBOTTOM">&nbsp;</td>
            <td width="11%">&nbsp;</td>
          </tr>
          <tr> 
            <td height="18">&nbsp;</td>
            <td><div align="center"><font size="1">Date</font></div></td>
            <td>&nbsp;</td>
            <td><div align="center"><font size="1">Signature</font></div></td>
            <td>&nbsp;</td>
          </tr>
        </table></td>
    </tr>
  </table>
  <%}//if (vDTRDetails != null && vDTRDetails.size() > 0  && vDTRManual != null && vDTRManual.size() > 0)%>
 <%}else if(strSchCode.startsWith("VMUF")){
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
      <td height="18" colspan="4">Department/College :&nbsp;<%=strTemp%></td>
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
   <%}else if(strSchCode.startsWith("CGH")){%>
   <table width="50%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="54"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          College of Nursing<br>
          <%=WI.formatDate(strPeriodEnding,6)%>&nbsp;Payslip<br>
      </div></td>
    </tr> 
  </table>
  <table width="50%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" >
    <tr> 
      <td height="20"><div align="center">PAY PERIOD <font size="1"><u><strong><%=WI.getStrValue(strCutOff,"&nbsp;")%></strong></u></font></div></td>
    </tr>
  </table>
  <table width="50%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
    <tr> 
      <td width="40%">Employee Name:</td>
      <td width="60%">&nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%><%=WI.getStrValue(strEmpID,"(",")","")%></td>
    </tr>
    <tr> 
      <%if(vPersonalDetails.elementAt(13) != null && vPersonalDetails.elementAt(14) != null){
			strTemp = ";";
		  }else{
			strTemp = "";	
		  }
		%>
      <td height="20"><div align="left">College/ Department</div></td>
      <td height="20">&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(13),"")%><%=strTemp%> 
        <%=WI.getStrValue((String)vPersonalDetails.elementAt(14),"")%></td>
    </tr>
    <tr> 
      <td height="18" colspan="2" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td height="10">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <%if(strPtFt.equals("0")){%>
          <tr> 
            <td height="10">&nbsp;&nbsp;RATE PER HOUR</td>
            <%
						// this hourly rate is the teaching rate (27)
						// This is the hourly rate (19);
					 if (vDTRDetails != null && vDTRDetails.size() > 0){ 
						 strHourlyRate = (String)vDTRDetails.elementAt(19);
						 strHourlyRate = ConversionTable.replaceString(strHourlyRate,",","");
						} else {
						strHourlyRate = "-";
						}				
					%>
            <td><div align="right"><%=strHourlyRate%>&nbsp;</div></td>
          </tr>
          <tr> 
            <td height="10">&nbsp;&nbsp;NO. OF HOURS</td>
            <%
			 if (vDTRManual != null && vDTRManual.size() > 0){ 
				 strTemp = (String)vDTRManual.elementAt(2);
				 if(vDTRDetails != null && vDTRDetails.size() > 0){
				 	 dTemp = Double.parseDouble(strTemp);
					 dTemp = dTemp * Double.parseDouble(strHourlyRate);
				 }else{
				 	dTemp = 0d;
				 }
			  }else{
				strTemp = "-";
			  }
			  
			  dGrossSalary += dTemp;
			%>
            <td><div align="right"><%=strTemp%>&nbsp;</div></td>
          </tr>
          <tr> 
            <td height="10">&nbsp;</td>
            <td><div align="right"></div></td>
          </tr>
          <tr> 
            <td height="10">&nbsp;</td>
            <td class="thinborderBOTTOMonly"><div align="right"></div></td>
          </tr>
          <tr> 
            <td height="10">&nbsp;</td>
            <td class="thinborderBOTTOMonly">&nbsp;</td>
          </tr>
          <tr> 
            <td height="10">&nbsp;&nbsp;BASIC PAY</td>
            <td align="right" class="thinborderBOTTOMonly">  
              <%
		//if (vDTRManual != null && vDTRManual.size() > 0){ 
			//strTemp = (String)vDTRManual.elementAt(44);							
		//}
		strTemp = CommonUtil.formatFloat(dGrossSalary,true);
		%>
              <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
          </tr>
          <%}// end if(strPtFt.equals("0"))%>
		  
          <%if(!strPtFt.equals("0")){%>
          <tr> 
            <td width="68%" height="10">&nbsp;&nbsp;BASIC</td>
            <td width="32%" align="right"> 
              <%
							if (vDTRDetails != null && vDTRDetails.size() > 0){ 
								strTemp = (String)vDTRDetails.elementAt(17);	
								dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							}
							%> 
			<%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
          </tr>
          <tr> 
            <td height="10">&nbsp;&nbsp;OVERLOAD</td>
            <td align="right"> 
              <% dTemp = 0d;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(67);
				// manually encoded overload Amount
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

				dGrossSalary += dTemp; 
				if(dTemp == 0d)
					strTemp = "";
			}	
		   %>
              <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;&nbsp;OVERTIME</td>
            <td align="right"> 
              <% dTemp = 0d;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(10);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
				dGrossSalary += dTemp; 
				if(dTemp == 0d)
					strTemp = "-";
			}	
		   %>
              <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;&nbsp;ECOLA-DISTORTION</td>
            <td align="right"> 
              <% 
							dTemp = 0d;
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							strTemp = (String) vDTRManual.elementAt(31);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}	
							dGrossSalary += dTemp;
							if(dTemp == 0d)
								strTemp = "-";
						 %>
              <%=WI.getStrValue(strTemp,"0")%>&nbsp;&nbsp;</td>
          </tr>
					<%}//if(!strPtFt.equals("0"))%>
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
            <td>&nbsp;&nbsp;<%=strTemp%></td>
            <td align="right">
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
					<!--
					<tr> 
            <td>&nbsp;&nbsp;HONORARIUM</td>
            <td align="right"> 
              <% dTemp = 0d;				
			//if (vDTRDetails != null && vDTRDetails.size() > 0){ 
			//	if (vSalIncentives != null && vSalIncentives.size() > 0){ 
			//		strTemp = ((Double) vSalIncentives.elementAt(0)).toString();
			//		dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			//	}	
			//}
			/*
			dTemp = 0d;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vDTRManual.elementAt(43),"0"),",",""));				
			}

			strTemp = Double.toString(dTemp);
			dGrossSalary += dTemp;
			strTemp = CommonUtil.formatFloat(strTemp,true);
			if(dTemp == 0d)
				strTemp = "-"; */
		  %>
              <%//=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;&nbsp;INCENTIVE PAY</td>
            <td align="right"> 
	            <% /*dTemp = 0d;
						if (vSalIncentives != null && vSalIncentives.size() > 0){ 
							dTemp = ((Double) vSalIncentives.elementAt(0)).doubleValue();					
						}	
						
						dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vDTRManual.elementAt(43),"0"),",",""));				
			
						strTemp = Double.toString(dTemp);
			
						if(dTemp == 0d)
							strTemp = "-";
						dGrossSalary += dTemp; */
					%>
            <%//=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
          </tr>
					-->
					<%dTemp = 0d;
						//if(vMiscEarnings != null && vMiscEarnings.size() > 0){
						//	dOtherEarning = ((Double)vMiscEarnings.elementAt(0)).doubleValue();	
 					  // }
						
					
					if (vDTRManual != null && vDTRManual.size() >  0){ 	
						// Night Differentials	
						strTemp = (String) vDTRManual.elementAt(25);
						dOtherEarning += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));									
 						// ADJUSTMENT
						strTemp = (String) vDTRManual.elementAt(20);
						dOtherEarning += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));									

						// additional bonuses
						strTemp = (String) vDTRManual.elementAt(22);
						dOtherEarning += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

						
						// holiday pay	
						strTemp = (String) vDTRManual.elementAt(26);
						dOtherEarning += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					

						// additional Responsibility
						strTemp = (String) vDTRManual.elementAt(27);
						dOtherEarning += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));						

 					}					
  					dGrossSalary += dOtherEarning; 
						strTemp = CommonUtil.formatFloat(dOtherEarning,true);	
						if(dOtherEarning > 0d){
					%>
          <tr>
            <td> &nbsp;&nbsp;OTHERS</td>
            <td align="right"><%=strTemp%>&nbsp;&nbsp;</td>
          </tr>
					<%}%>
					<%if(!strPtFt.equals("0")){%>
          <tr valign="bottom"> 
            <td height="24">&nbsp;&nbsp;LESS :</td>
            <td align="right">&nbsp;
              &nbsp;
              <div align="right"></div></td>
          </tr>
          <tr> 
            <td>&nbsp;&nbsp;&nbsp;ABSENCES/TARDINESS</td>
            <td align="right" class="thinborderBOTTOMonly">&nbsp; 
              <% dAbsenceAmt = 0d;			
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

			// lates / undertime
				strTemp = (String) vDTRManual.elementAt(33);
				dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				dGrossSalary -= dAbsenceAmt;
				
				if(dAbsenceAmt == 0d)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);			
			}	
		   %>
              <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
          </tr>
          <tr valign="bottom"> 
            <td height="24">&nbsp;&nbsp;TOTAL GROSS PAY</td>
            <td align="right" class="thinborderBOTTOMonly"><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%>&nbsp;&nbsp;</td>
          </tr>
          <%}//if(!strPtFt.equals("0"))%>
          <tr> 
            <td height="18">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;&nbsp;DEDUCTIONS :</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;&nbsp;WITHHOLDING TAX</td>
            <td align="right"> 
              <% 
			if (vDTRManual != null && vDTRManual.size() > 0){ 				
				strTemp = (String) vDTRManual.elementAt(24);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
				dTotalDeduction += dTemp; 
				strTemp = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "-";
			}	
		   %>
              <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td></tr>
          <tr> 
            <td>&nbsp;&nbsp;SSS</td>
            <td align="right"> 
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
              <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
		  </tr>
          
          <tr> 
            <td>&nbsp;&nbsp;HDMF</td>
            <td align="right"> 
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
              <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
		  </tr>
          <tr> 
            <td>&nbsp;&nbsp;MEDICARE</td>
            <td align="right"> 
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
              <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td></tr>
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
            <td>&nbsp;&nbsp;<%=WI.getStrValue(strTemp,"")%></td>
            <td align="right">
              <% 
							strTemp = CommonUtil.formatFloat(dTemp,true);
							dTotalDeduction += dTemp; 
							if(dTemp == 0d)
								strTemp = "";				
						 %>
              <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
		  </tr>
          <%}// end for loop here
	 		  }//end checking for null%>
				<%dTemp = 0d;
					if (vDTRManual != null && vDTRManual.size() > 0){ 
						// manual encoded additional deduction in the dtr manual page
						strTemp = (String) vDTRManual.elementAt(18);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					}	
					dOtherDeduction += dTemp;
					strTemp = CommonUtil.formatFloat(dOtherDeduction,true);					
					dTotalDeduction += dOtherDeduction; 
					if(dOtherDeduction > 0d){
				%>
          <tr>
            <td>&nbsp;&nbsp;OTHERS</td>
            <td align="right"><%=strTemp%>&nbsp;&nbsp;</td>
          </tr>
				 <%}%>
          
          <tr valign="bottom"> 
            <td height="24">&nbsp;&nbsp;TOTAL DEDUCTIONS</td>
            <td align="right" class="thinborderBOTTOMonly"><%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%>&nbsp;</td>
          </tr>
          <tr valign="bottom"> 
            <td height="24">&nbsp;&nbsp;NET PAY</td>
            <%
				dNetSalary += dGrossSalary - dTotalDeduction;
			%>
            <td align="right" class="thinborderBOTTOMonly"><u><font size="2"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%>&nbsp;</strong></font></u></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
  </table>  
    <%}else if(strSchCode.startsWith("AUF")){%>
   <table width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
       <td colspan="8" class="thinborderNONE">Angeles University Foundation </td>
     </tr>
     <tr>
       <td colspan="8" class="thinborderNONE">Payslip for the period : <font size="1"><%=WI.getStrValue(strPayrollPeriod,"&nbsp;")%></font></td>
     </tr>
     <tr>
       <td colspan="8" class="thinborderNONE">Employee Number :&nbsp;<%=WI.getStrValue(strEmpID,"")%></td>
     </tr>
     <tr>
       <td colspan="8" class="thinborderNONE">Employee Name : &nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%></td>
     </tr>
     <tr>
       <td colspan="8"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           <tr>
             <td width="12%" class="thinborderNONE">&nbsp;</td>
             <td width="13%" class="thinborderNONE">&nbsp;</td>
             <td width="12%" class="thinborderNONE">&nbsp;</td>
             <td width="13%" class="thinborderNONE">&nbsp;</td>
             <td width="13%" class="thinborderNONE">SSS Number  :</td>
             <%
			if(vEmpIDs != null && vEmpIDs.size() > 0)
				strTemp = (String)vEmpIDs.elementAt(0);
			else
				strTemp = "";
		%>
             <td width="12%" class="thinborderNONE">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
             <td width="12%" class="thinborderNONE">PHIC </td>
             <%
			if(vEmpIDs != null && vEmpIDs.size() > 0)
				strTemp = (String)vEmpIDs.elementAt(2);
			else
				strTemp = "";
		%>
             <td width="13%" class="thinborderNONE">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
           </tr>
           <tr>
             <td class="thinborderBOTTOM">Unit: UL</td>
             <td class="thinborderBOTTOM">&nbsp;</td>
             <td class="thinborderBOTTOM">PERAA:</td>
             <%
			if(vEmpIDs != null && vEmpIDs.size() > 0)
				strTemp = (String)vEmpIDs.elementAt(4);
			else
				strTemp = "";
		%>
             <td class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
             <td class="thinborderBOTTOM">TIN :</td>
             <%
			if(vEmpIDs != null && vEmpIDs.size() > 0)
				strTemp = (String)vEmpIDs.elementAt(1);
			else
				strTemp = "";
		%>
             <td class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
             <td class="thinborderBOTTOM">Pag-Ibig</td>
             <%
			if(vEmpIDs != null && vEmpIDs.size() > 0)
				strTemp = (String)vEmpIDs.elementAt(3);
			else
				strTemp = "";
		%>
             <td class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
           </tr>
       </table></td>
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
			dSubGross += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		}
		%>
                 <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</div></td>
           </tr>
           <% dTemp = 0d;
		if (vDTRManual != null && vDTRManual.size() > 0){ 
		  strTemp = (String) vDTRManual.elementAt(44);
		  dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		  dSubGross  += dTemp;		
		}
		if(dTemp > 0){
	   %>
           <tr>
             <td class="thinborderNONE" height="16">Faculty Pay </td>
             <td class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;&nbsp;</div></td>
           </tr>
           <%} // if dTemp > 0%>
           <% dTemp = 0d;
		if (vDTRManual != null && vDTRManual.size() > 0){ 
		  strTemp = (String) vDTRManual.elementAt(52);
		  dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		  dSubGross  += dTemp;		
		}
		if(dTemp > 0){
	   %>
           <tr>
             <td class="thinborderNONE" height="16">Additional Resp.</td>
             <td align="right" class="thinborderNONE"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;&nbsp;</td>
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
            <td align="right" class="thinborderNONE"><strong>
            <% 
								strTemp = CommonUtil.formatFloat(dTemp,true);
								dGrossSalary += dTemp; 
								if(dTemp == 0d)
									strTemp = "";				
 						    %>
            <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</strong></td>
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
				dSubGross -= dAbsenceAmt;
				if(dAbsenceAmt > 0)
					strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);
				else
					strTemp = "-";
			}	
		   %>
             <td class="thinborderNONE"><div align="right"><%=strTemp%>&nbsp;&nbsp;</div></td>
           </tr>
           <tr>
             <td class="thinborderNONE" height="16"> Basic</td>
             <td class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dSubGross,true)%>&nbsp;&nbsp;</div></td>
           </tr>
           <%
						// addl pay amount
						strTemp = (String) vDTRManual.elementAt(17);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dSubGross += dTemp;
						
						// addl bonus amount
						strTemp = (String) vDTRManual.elementAt(22);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dSubGross += dTemp;		
						
						%>
           <tr>
             <td class="thinborderNONE" height="16">Others</td>
             <td class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dOtherEarning,true)%>&nbsp;&nbsp;</div></td>
           </tr>
       </table></td>
       <td colspan="2" valign="top" class="thinborderLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           <tr>
             <td colspan="2" class="thinborderNONE" height="18"><strong>Other Earnings</strong></td>
           </tr>
           <tr>
             <td width="57%" class="thinborderNONE">&nbsp;</td>
             <td width="43%" class="thinborderNONE">&nbsp;</td>
           </tr>
           <tr>
             <td class="thinborderNONE" height="16">Holiday pay </td>
             <td class="thinborderNONE"><div align="right"> <font size="1">
               <% dTemp = 0d;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(26);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
				dGrossSalary += dTemp; 
				if(dTemp == 0d)
					strTemp = "";
			}	
		   %>
               <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</font></div></td>
           </tr>
           <tr>
             <td class="thinborderNONE" height="16">Regular Overtime</td>
             <td class="thinborderNONE"><div align="right"> <font size="1">
               <% dTemp = 0d;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(10);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
				dGrossSalary += dTemp; 
				if(dTemp == 0d)
					strTemp = "";
			}	
		   %>
               <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</font></div></td>
           </tr>
           <% 
		dTemp = 0d;
		if (vDTRManual != null && vDTRManual.size() >  0){ 	
			strTemp = (String) vDTRManual.elementAt(25);
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
           
           <tr>
             <td class="thinborderNONE" height="16">&nbsp;</td>
             <td class="thinborderNONE">&nbsp;</td>
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
           <tr>
             <td class="thinborderNONE" height="16"> SSS premium</td>
             <td class="thinborderNONE"><div align="right">
                 <% 
		if (vDTRManual != null && vDTRManual.size() > 0){ 
			strTemp = (String) vDTRManual.elementAt(12);
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
           <tr>
             <td class="thinborderNONE" height="18">Ret. Plan Fund</td>
             <td class="thinborderNONE"><div align="right">
                 <% 
						if (vDTRManual != null && vDTRManual.size() > 0){ 
							strTemp = (String) vDTRManual.elementAt(54);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							strTemp = CommonUtil.formatFloat(strTemp,true);
							dSubTotalDed += dTemp; 
							dTotalDeduction = dSubTotalDed;
							if(dTemp == 0d)
								strTemp = "";
						}	
						 %>
                 <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</div></td>
           </tr>
       </table></td>
       <td colspan="2" valign="top" class="thinborderLEFTRIGHT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           <tr>
             <td colspan="2" class="thinborderNONE" height="18"><strong>Other Deductions</strong></td>
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
             <td class="thinborderNONE" height="16">&nbsp;Others</td>
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
     </tr>
     <tr>
       <td colspan="2" valign="top" class="thinborderBOTTOMLEFT">&nbsp;</td>
       <td colspan="2" valign="top" class="thinborderBOTTOMLEFT">&nbsp;</td>
       <td colspan="2" valign="top" class="thinborderBOTTOMLEFT">&nbsp;</td>
       <td colspan="2" valign="top" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
     </tr>
     <tr>
       <td width="12%" valign="top" class="thinborderBOTTOMLEFT" height="16"><span class="thinborderNONE">Sub Total</span></td>
       <td width="13%" valign="top" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dSubGross,true)%>&nbsp;</div></td>
       <td width="13%" valign="top" class="thinborderBOTTOMLEFT">Gross</td>
       <td width="12%" valign="top" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dGrossSalary,true)%>&nbsp;</div></td>
       <td width="14%" valign="top" class="thinborderBOTTOMLEFT">Sub Total </td>
       <td width="11%" valign="top" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dSubTotalDed,true)%>&nbsp;</div></td>
       <td width="13%" valign="top" class="thinborderBOTTOMLEFTRIGHT">Total Deduction </td>
       <td width="12%" valign="top" class="thinborderBOTTOMLEFTRIGHT"><div align="right"><%=CommonUtil.formatFloat(dTotalDeduction,true)%>&nbsp;</div></td>
     </tr>
     <tr>
       <td colspan="8"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           <tr>
             <td width="5%">&nbsp;</td>
             <td width="51%" class="thinborderNONE">&nbsp;</td>
             <td width="31%" align="right" class="thinborderNONE">NET PAY </td>
             <%dNetSalary = dGrossSalary-dTotalDeduction;%>
             <td width="13%" class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dNetSalary,true)%>&nbsp;</div></td>
           </tr>
           <tr>
             <td>&nbsp;</td>
             <td class="thinborderNONE">Leadership is based on inspiration, not domination,<br>
             on cooperation, not intimidation - William Arthur Wood. </td>
             <td colspan="2" align="right" class="thinborderNONE">
						 <table width="100%" border="0" cellspacing="0" cellpadding="0">
							<%
							int iDivider = 0;
							int iPay = 0;
							double dNetSalary2 = 0d;
							Vector vPeriods = null;
							vPeriods = rptPayExtn.getMonthlyPeriods(dbOP);
							if(vPeriods != null && vPeriods.size() > 0)
								iDivider = vPeriods.size()/9;
							//iDivider = rptPayExtn.getPeriodCount(dbOP, request);
							strTemp = null;
							dNetSalary = CommonUtil.formatFloatToCurrency(dNetSalary,2);
							dNetSalary2 = dNetSalary/iDivider;
							dNetSalary2 = CommonUtil.formatFloatToCurrency(dNetSalary2,2);
							dTemp = 0d;		
							for(iPay = 0,i = 0;i < vPeriods.size();iPay++,i+=9){														
							%>
               <tr>		
									<%
										strTemp = (String)vPeriods.elementAt(i+2);
										strTemp = WI.formatDate(strTemp,14);
										if(strTemp != null && strTemp.length() > 0)
											strTemp = strTemp.substring(0,strTemp.indexOf(" "));
										else
											strTemp = "";
									%>
                 <td width="70%" align="right" class="thinborderNONE">Your NET PAY on the <%=strTemp%>&nbsp;</td>
								 <%
									if(iPay < iDivider-1)
										strTemp = CommonUtil.formatFloat(dNetSalary2,true);			
									else
										strTemp = CommonUtil.formatFloat(dNetSalary-dTemp,true);			
									%>
                 <td width="30%" align="right" class="thinborderNONE"><%=strTemp%>&nbsp;</td>
               </tr>               
							<%
							dTemp = dTemp + dNetSalary2;
							}%>
             </table></td>
           </tr>
           
       </table></td>
     </tr>
   </table>
	 <%}else if(strSchCode.startsWith("UDMC")){%>
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
	  
	  <td height="18" colspan="2"><font size="1">Prepared By: </font><img src="./signatory/Siony.jpg" width="82" height="45"></td>
	  <td colspan="2" valign="bottom"><font size="1">Checked by: </font><img src="./signatory/Elvie.jpg" width="86" height="45"></td>
	  <td colspan="2" valign="bottom"><font size="1">Approved by : </font><img src="./signatory/Mae.jpg" width="88" height="45"></td>
	  <!--
	  
	  <td height="18" colspan="2"><font size="1">Prepared By: </font><img src="./signatory/signatory1.gif"></td>
	  <td colspan="2" valign="bottom"><font size="1">Checked by: </font><img src="./signatory/signatory2.gif"></td>
	  <td colspan="2" valign="bottom"><font size="1">Approved by : </font><img src="./signatory/signatory3.gif"></td>
    	  -->
    </tr>
	<tr>
	  <td>&nbsp;</td> 
	  <td height="18" align="right">&nbsp;</td>
	  <td height="18"><font size="1"><strong><%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Payroll Head",7)),"Maria C. Reyes").toUpperCase()%></strong></font></td>
	  <td width="5%" align="right">&nbsp;</td>
	  <td width="25%"><font size="1"><strong><%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Accounting Head",7)),"Elvira B. Caguioa").toUpperCase()%></strong></font></td>
	  <td width="5%">&nbsp;</td>
	  <td width="34%"><font size="1"><strong><%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"HR Manager",7)),"Angeline Mae P. Juan").toUpperCase()%></strong></font></td>
    </tr>
	<tr>
	  <td width="1%">&nbsp;</td> 
	  <td width="6%" height="18">&nbsp;</td>
	  <td width="24%" valign="top"><em><font size="1">Head, Payroll Section </font></em></td>
	  <td>&nbsp;</td>
	  <td><em><font size="1">Head, Accounting Section </font></em></td>
	  <td>&nbsp;</td>
	  <td><em><font size="1">Head, Human Resources Development Office </font></em></td>
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
  <%}// end if not CLDH%>
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
window.setInterval("javascript:window.close();",0);
this.closeWnd = 1;
//or use this so that the window will not close
//window.setInterval("javascript:window.print();",0);
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>