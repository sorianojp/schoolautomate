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

<script language="JavaScript">
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
</script>

<%@ page language="java" import="utility.*, java.util.Vector, payroll.ReportPayroll, payroll.PRSalary, 
								payroll.PReDTRME, hr.HRInfoPersonalExtn,payroll.PRSalaryExtn, payroll.PRRetirementLoan, payroll.PRPayslip" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strImgFileExt = null;	
	String strPayrollPeriod = null;
	String strCutOff = null;
	String strPeriodEnding = null;

	String strSalIndex = WI.fillTextValue("sal_index");
	String strDailyRate = null;
	String strHourlyRate = null;	

//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-EmployeePayslip","payroll_slip_print2.jsp");
								
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
														"Payroll","REPORTS",request.getRemoteAddr(),
														"payroll_slip_print2.jsp");
if(WI.fillTextValue("my_home").equals("1")){
	iAccessLevel = 2;
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
	Vector vOtherCons	    = null;
	Vector vVarAllowances   = null;
	Vector vEmpIDs          = null;
	Vector vMiscEarnings    = null;
	Vector vOTEncoding      = null;
	Vector vEmpLoans        = null;
	HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
	PRSalary salary = new PRSalary();
	PRSalaryExtn salaryExtn = new PRSalaryExtn();
	ReportPayroll rptPay = new ReportPayroll(request);
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	PRPayslip payslip = new PRPayslip();
	int i = 0;
	int iTemp = 0;
		
	String strEmpID = WI.fillTextValue("emp_id");
	if(WI.fillTextValue("my_home").equals("1")){
		strEmpID = (String)request.getSession(false).getAttribute("userId");		
	}
	
	String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmpID);
	
if (strEmpID.length() > 0) {
  enrollment.Authentication authentication = new enrollment.Authentication();
  vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");	
	vDTRDetails = salary.getDTRDetails(dbOP,request);
	vDTRManual = salary.operateOnDTRManual(dbOP,request,7);		
	vEmpLoans = PRRetLoan.getEmpLoansWithBalPay(dbOP,request);			
	
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
	}	
	vEmpIDs = salaryExtn.getEmpContributionIDs(dbOP, strEmployeeIndex);
}

if(WI.fillTextValue("finalize").length() > 0){
  if(!finalize.FinalizeSalary(dbOP,request,strSalIndex)){
	strErrMsg = "Error";
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

double dGrossSalary = 0d;
double dTotalDeduction = 0d;
double dNetSalary = 0d;
double dTemp = 0d;

String[] astrPtFt = {"Part-Time","Full-Time",""};
String strPtFt = WI.fillTextValue("pt_ft");
if (strPtFt.length() == 0){
	strPtFt = dbOP.mapOneToOther("info_faculty_basic","is_valid","1", "pt_ft",
						  " and user_index = " + strEmployeeIndex);
	strPtFt = WI.getStrValue(strPtFt,"1");
}
%>
<body>
<form>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="54" colspan="5"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%></font></div></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E8E8E8">
    <tr> 
      <td width="17%"><font size="1">&nbsp;Days worked cut off</font></td>
      <td width="32%"><font size="1"><strong>&nbsp;<%=WI.getStrValue(strCutOff,"0")%></strong></font></td>
      <td width="28%">&nbsp;</td>
      <td width="23%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="17"><font size="1">NAME</font></td>
      <td><font size="1">&nbsp;<strong><u><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 7).toUpperCase()%></u><%=WI.getStrValue(strEmpID,"(",")","")%></strong></font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
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
            <td valign="bottom"><font size="1">Regular Pay days</font></td>
            <td align="right" valign="bottom"><font size="1">
              <% 
						if (vDTRDetails != null && vDTRDetails.size() > 0){ 
							strTemp = (String)vDTRDetails.elementAt(17);			
							dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						}
						%>
              <%=WI.getStrValue(strTemp,"")%></font></td>
            <td>&nbsp;</td> 
            <td height="10">&nbsp;</td>
            <td align="right">&nbsp;</td>
            <td align="right">&nbsp;</td>
          </tr>
          <tr>
            <td valign="bottom"><font size="1">NIGHT DIFFERENTIAL</font></td>
            <td align="right" valign="bottom"><font size="1">
              <% 
			dTemp = 0d;
			if (vDTRManual != null && vDTRManual.size() >  0){ 	
				strTemp = (String) vDTRManual.elementAt(25);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
				dGrossSalary += dTemp; 
			}
			if(dTemp == 0d)
				strTemp = "";
			%>
              <%=WI.getStrValue(strTemp,"")%></font></td>
            <td>&nbsp;</td> 
            <td height="10">&nbsp;</td>
            <td align="right"><font size="1">&nbsp;</font></td>
            <td align="right">&nbsp;</td>
          </tr>
          <tr>
            <td valign="bottom"><font size="1">ADJUSTMENT</font></td>
            <td align="right" valign="bottom"><font size="1">
              <% dTemp = 0d;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
			  strTemp =(String) vDTRManual.elementAt(20);
			  dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			  if (dTemp < 0d){
				strTemp = "(" + ConversionTable.replaceString((String) vDTRManual.elementAt(20),"-","") + ")";
				dTotalDeduction -= Double.parseDouble(ConversionTable.replaceString((String) vDTRManual.elementAt(20),",",""));
			  }else{				
				dNetSalary += dTemp;			
			  }
			  if(dTemp == 0d)
				strTemp = "";
			}	
		   %>
              <%=WI.getStrValue(strTemp,"")%></font></td>
            <td>&nbsp;</td> 
            <td height="10"><font size="1">&nbsp;</font></td>
            <td align="right"><font size="1">&nbsp;</font></td>
            <td align="right">&nbsp;</td>
          </tr>
          <tr>
            <td valign="bottom"><font size="1">OVERLOAD</font></td>
            <td align="right" valign="bottom"><font size="1">
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
				if(dTemp == 0d)
					strTemp = "";
				strTemp = CommonUtil.formatFloat(dTemp,true);
			}	
		   %>
              <%=WI.getStrValue(strTemp,"")%></font></td>
            <td>&nbsp;</td> 
            <td height="10">&nbsp;</td>
            <td align="right"> <font size="1">&nbsp;</font></td>
            <td align="right">&nbsp;</td>
          </tr>
          
          <tr>
            <td valign="bottom"><font size="1">OVERTIME&nbsp;</font></td>
            <td align="right" valign="bottom"><font size="1">
              <% dTemp = 0d;
			if (vDTRManual != null && vDTRManual.size() > 0){ 
				strTemp = (String) vDTRManual.elementAt(10);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
				dGrossSalary += dTemp; 
				if(dTemp == 0d)
					strTemp = "";
			}	
		   %>
              <%=WI.getStrValue(strTemp,"")%></font></td>
            <td>&nbsp;</td> 
            <td height="10"><font size="1">&nbsp;</font></td>
            <td align="right"><font size="1">&nbsp;</font></td>
            <td align="right">&nbsp;</td>
          </tr>
				<%if (vVarAllowances != null && vVarAllowances.size() > 2){
					for(i = 2;i < vVarAllowances.size(); i+=5){
				%>					
				<tr>
				<%
					strTemp = WI.getStrValue((String)vVarAllowances.elementAt(i+1),"&nbsp;");
					strTemp += WI.getStrValue((String)vVarAllowances.elementAt(i+2)," (",")","&nbsp;");
			  %>
            <td height="19" valign="bottom"><font size="1"><%=strTemp%></font></td>
            <td align="right" valign="bottom"> 
              <% dTemp = 0d;			
				strTemp = WI.getStrValue((String)vVarAllowances.elementAt(i+3),"0");
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
				dGrossSalary += dTemp; 
				if(dTemp == 0d)
					strTemp = "-";
		     %>
              <font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
            <td>&nbsp;</td> 
            <td>&nbsp;</td>
            <td align="right">&nbsp;</td>
            <td align="right">&nbsp;</td>
          </tr>
          <%} // end for loop
	    } // end if vVarAllowances != null %>					
          <tr>
            <td valign="bottom"><font size="1"> INCENTIVE</font></td>
            <td align="right" valign="bottom"><font size="1">
              <% dTemp = 0d;
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
			strTemp = CommonUtil.formatFloat(strTemp,true);
			if(dTemp == 0d)
				strTemp = "";
		  %>
              <%=WI.getStrValue(strTemp,"")%></font></td>
            <td>&nbsp;</td> 
            <td>&nbsp;</td>
            <td align="right">&nbsp;</td>
            <td align="right">&nbsp;</td>
          </tr>
          
          <tr>
            <td width="28%">&nbsp;</td>
            <td width="19%">&nbsp;</td>
            <td width="3%">&nbsp;</td>
            <td width="28%">&nbsp;</td>			
            <td width="19%" align="right">&nbsp;</td>
            <td width="3%" align="right">&nbsp;</td>
          </tr>        
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
            <td valign="bottom"><font size="1">&nbsp;&nbsp;</font><font color="#000000" size="1">PHILHEALTH 
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
          <%  if (vLoansAndAdv != null && vLoansAndAdv.size() > 1 ){
		  for (i = 1; i < vLoansAndAdv.size(); i +=8){
		    dTemp = 0d;
			strTemp = (String)vLoansAndAdv.elementAt(i + 1);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		    dTotalDeduction += dTemp;			
			if(dTemp > 0d){
			  strTemp = (String)vLoansAndAdv.elementAt(i+5);			  			
			  //System.out.println("strTemp " + strTemp);
				if (strTemp == null){
					strTemp = (String)vLoansAndAdv.elementAt(i+6);
					if(strTemp.equals("0")){
					  strTemp = "Retirement Loan";
					}else{
					  strTemp = "Emergency Loan";
					}
				}
				//System.out.println("strTemp " + strTemp);
		   %>		   
          <tr> 
            <td valign="bottom"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(strTemp,"").toUpperCase()%></font>&nbsp;</font></td>
			<%
			  strTemp = CommonUtil.formatFloat(dTemp,true);
			%>			
            <td align="right" valign="bottom"><font size="1"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</font></td>
            <td align="right">&nbsp;</td>
            <td align="right">&nbsp;</td>
            <td align="right">&nbsp;</td>
          </tr>
		  
		    <%}%>
          <%}// end for loop here
 		  }//end checking for null%>
          <%  if (vMiscDeductions != null && vMiscDeductions.size() > 0 ){
		  for (i = 1; i < vMiscDeductions.size(); i +=4){
		    dTemp = 0d;
			strTemp = (String)vMiscDeductions.elementAt(i + 2);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			dTotalDeduction += dTemp;

		  if(dTemp > 0){
		  %>
          <tr> 
            <td valign="bottom"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue((String)vMiscDeductions.elementAt(i+1),"").toUpperCase()%></font> </td>
            <td align="right" valign="bottom"><font size="1"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</font></td>
            <td align="right">&nbsp;</td>
            <td align="right">&nbsp;</td>
            <td align="right">&nbsp;</td>
          </tr>
          <%} // end if 
		   }// end for loop here
 		  }//end checking for null%>
          <%  if (vOtherCons != null && vOtherCons.size() > 0 ){
		  for (i = 1; i < vOtherCons.size(); i +=5){
			dTemp = 0d;
			strTemp = (String)vOtherCons.elementAt(i);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			dTotalDeduction += dTemp;
			
			if(dTemp > 0){
		  %>
          <tr> 
            <td valign="bottom"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue((String)vOtherCons.elementAt(i+4),"").toUpperCase()%></font></td>
            <td align="right" valign="bottom"><font size="1"> <%=WI.getStrValue(strTemp,"0")%>&nbsp;</font></td>
            <td align="right">&nbsp;</td>
            <td align="right">&nbsp;</td>
            <td align="right">&nbsp;</td>
          </tr>
          <% } // end if dTemp > 0d
		   }// end for loop here
 		 }//end checking for null%>
          <tr> 
            <td valign="bottom"><font size="1">&nbsp;&nbsp;OTHERS</font></td>
            <% 
			if (vDTRManual != null && vDTRManual.size() > 0){ 	
				strTemp = (String) vDTRManual.elementAt(18);//MISC_DEDUCTION (Addl ded)
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dTotalDeduction += dTemp; 
				if(dTemp == 0d)
					strTemp = "";
			}
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
          <td width="78%" align="right"><font size="1">T</font><font size="1">OTAL 
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
          <td height="26" valign="bottom"><font size="2"><strong>&nbsp;&nbsp;NET SALARY :</strong></font></td>
          <%
				dNetSalary += dGrossSalary - dTotalDeduction;
			%>
          <td align="right" valign="bottom"><u><font size="2"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%>&nbsp;</strong></font></u></td>
        </tr>
      </table></td>
    </tr>
  </table>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="40%" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td colspan="2">Overtime Details:</td>
          <td width="26%">&nbsp;</td>
          <td width="27%">&nbsp;</td>
        </tr>
				<%
					if(vOTEncoding != null && vOTEncoding.size() > 0){
					for(i = 0; i < vOTEncoding.size(); i+=12){
				%>
        <tr>
					<%
						strTemp = (String)vOTEncoding.elementAt(i+5);
						strTemp2 = (String)vOTEncoding.elementAt(i+11);
					%>
          <td width="25%"><%=strTemp%>&nbsp;<%=strTemp2%></td>
					<%
						strTemp = (String)vOTEncoding.elementAt(i+1);						
					%>					
          <td width="25%"><%=strTemp%></td>
					<%
						strTemp = (String)vOTEncoding.elementAt(i+2);						
					%>
          <td width="25%"><%=strTemp%></td>
					<%
						strTemp = (String)vOTEncoding.elementAt(i+7);						
					%>
          <td width="25%" align="right"><%=strTemp%>&nbsp;</td>
        </tr>
				<%}// end for loop
				}// end vOTEncoding%>
      </table></td>			
			<td width="60%">
			<%if(vEmpLoans != null && vEmpLoans.size() > 0){%>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="21%">Loan Details:</td>
          <td width="19%">&nbsp;</td>
          <td width="21%">&nbsp;</td>
          <td width="22%">&nbsp;</td>
          <td width="17%">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td align="center"><font size="1">Principal Amt</font></td>
          <td align="center"><font size="1">Paid to Date</font></td>
          <td align="center"><font size="1">Pay Period Ded.</font></td>
          <td align="center"><font size="1">Balance</font></td>
        </tr>
				<%for(i = 0;i < vEmpLoans.size();i+=9){%>
        <tr>
					<%
						strTemp = (String)vEmpLoans.elementAt(i+7);
					%>
          <td><font size="1"><%=strTemp%></font></td>
					<%
						strTemp = (String)vEmpLoans.elementAt(i+3);
					%>					
          <td align="right"><font size="1"><%=strTemp%></font>&nbsp;</td>
					<%
						strTemp = (String)vEmpLoans.elementAt(i+5);
					%>					
          <td align="right"><font size="1"><%=strTemp%></font>&nbsp;</td>
					<%
						strTemp = (String)vEmpLoans.elementAt(i+8);
					%>					
          <td align="right"><font size="1"><%=strTemp%></font>&nbsp;</td>
					<%
						strTemp = (String)vEmpLoans.elementAt(i+4);
					%>										
          <td align="right"><font size="1"><%=strTemp%></font>&nbsp;</td>
        </tr>
				<%}%>
      </table>
			<%}%>
			</td>
		</tr>
	</table> 
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
//this.autoPrint();
//window.setInterval("javascript:window.close();",0);
//this.closeWnd = 1;
//or use this so that the window will not close
window.setInterval("javascript:window.print();",0);
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>