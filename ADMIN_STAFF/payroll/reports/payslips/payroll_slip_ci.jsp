<%@ page language="java" import="utility.*, java.util.Vector, payroll.ReportPayroll, payroll.PRSalary, 
								payroll.PReDTRME, hr.HRInfoPersonalExtn,
								payroll.ReportPayrollExtn, payroll.PRRetirementLoan" %>

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
	TD.thinborderBOTTOMonly {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
    }

</style>
</head>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strImgFileExt = null;	
	String strEmpID = WI.fillTextValue("emp_id");
	if(WI.fillTextValue("my_home").equals("1")){
		strEmpID = (String)request.getSession(false).getAttribute("userId");		
	}

	String strEmployeeIndex = null;

//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-EmployeePayslip","payroll_slip_ci.jsp");
								
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
														"payroll_slip_ci.jsp");
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
	Vector vSalaryDetails   = null;
	Vector vDTRManual       = null;
	Vector vSalIncentives  	= null;	
	Vector vHonorarium      = null;
	
	HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
	PRSalary salary = new PRSalary();
	ReportPayroll rptPay = new ReportPayroll(request);
	ReportPayrollExtn rptPayExtn = new ReportPayrollExtn(request);
	int i = 0;
	int iTemp = 0;
	//String strPayrollPeriod = null;
	String strCutOffFr = null;
	String strCutOffTo = null;
	String strCutOff = null;
	String strPeriodEnding = null;

	String strHourlyRate = null;

	strEmployeeIndex = dbOP.mapUIDToUIndex(strEmpID);
	
if (strEmpID.length() > 0) {
  enrollment.Authentication authentication = new enrollment.Authentication();
  vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");	
	// vDTRDetails = salary.getDTRDetails(dbOP,request);
	vDTRManual = salary.operateOnDTRManual(dbOP,request,7);		

	if(vDTRManual != null){
			vSalIncentives  = (Vector)vDTRManual.elementAt(63);
			vHonorarium     = (Vector)vDTRManual.elementAt(64);
	}	
}

if(WI.fillTextValue("sal_period_index").length() > 0) {			
	vSalaryPeriod = rptPay.getSalaryPeriodRange(dbOP);
	strTemp = WI.fillTextValue("sal_period_index");					
	if (vSalaryPeriod!= null && vSalaryPeriod.size() > 0){
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 5) {
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
				 //strPayrollPeriod = (String)vSalaryPeriod.elementAt(3) +" - "+(String)vSalaryPeriod.elementAt(4);
				 strCutOffFr = (String)vSalaryPeriod.elementAt(1);
				 strCutOffTo = (String)vSalaryPeriod.elementAt(2);
				 strCutOff = strCutOffFr  + " - " + strCutOffTo;
				 strPeriodEnding = (String)vSalaryPeriod.elementAt(4);
				 break;
			}
		}		
	}		
}


		
double dGrossSalary = 0d;
double dTotalDeduction = 0d;
double dOtherDeduction  = 0d;
double dNetSalary = 0d;
double dTemp = 0d;
double dOtherEarning = 0d;

String strSalPeriodIndex = WI.fillTextValue("sal_period_index");
	vSalaryDetails = salary.getSalaryDetails(dbOP, strEmployeeIndex, strCutOffFr, strCutOffTo);

%>
<body>
<form>
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
            <td width="68%" height="10">&nbsp;</td>
            <td width="32%">&nbsp;</td>
          </tr>
          <tr> 
            <td height="10">&nbsp;&nbsp;RATE PER HOUR</td>
            <%
						// this hourly rate is the teaching rate (27)
						// This is the hourly rate (19);
					 if (vSalaryDetails != null && vSalaryDetails.size() > 0){ 
					 	// by default get the hourly rate... 
						// if the hourly rate if the employee does not exist get teaching rate
						 strHourlyRate = WI.getStrValue((String)vSalaryDetails.elementAt(4), (String)vSalaryDetails.elementAt(5));
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
							 dTemp = Double.parseDouble(strTemp);
							 dTemp = dTemp * Double.parseDouble(strHourlyRate);
						}else{
							 strTemp = "-";
						}
						dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
 						dGrossSalary += dTemp;
					%>
            <td><div align="right"><%=strTemp%>&nbsp;</div></td>
          </tr>
          <tr> 
            <td height="10">&nbsp;</td>
            <td><div align="right"></div></td>
          </tr>
          
          <tr> 
            <td height="10">&nbsp;&nbsp;BASIC PAY</td>
            <td align="right" class="thinborderBOTTOMonly">  
              <% 
							strTemp = CommonUtil.formatFloat(dGrossSalary,true);
							%>
              <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
          </tr> 
          
					<tr> 
            <td>&nbsp;&nbsp;HONORARIUM</td>
            <td align="right"> 
              <% 
								strTemp = "0";
								if (vHonorarium != null && vHonorarium.size() > 0){ 
									strTemp = ((Double) vHonorarium.elementAt(0)).toString();
								}
							dTemp = Double.parseDouble(strTemp);
							dGrossSalary += dTemp;
							strTemp = CommonUtil.formatFloat(strTemp,true);
							if(dTemp == 0d)
								strTemp = "-"; 
							%>
              <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;&nbsp;INCENTIVE PAY</td>
            <td align="right"> 
	            <% dTemp = 0d;
						if (vSalIncentives != null && vSalIncentives.size() > 0){ 
							dTemp = ((Double) vSalIncentives.elementAt(0)).doubleValue();					
						}	
						strTemp = CommonUtil.formatFloat(dTemp,true);
						if(dTemp == 0d)
							strTemp = "-";
						dGrossSalary += dTemp; 
					%>
            <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
          </tr>

          <tr>
            <td>&nbsp;</td>
            <td align="right">&nbsp;</td>
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
  <input type="hidden" name="sal_period_index" value="<%=WI.fillTextValue("sal_period_index")%>">
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