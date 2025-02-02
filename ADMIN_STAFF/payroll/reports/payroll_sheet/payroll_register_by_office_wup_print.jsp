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

    TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"9")%>px;
    }
    TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"9")%>px;
    }	
	
	TD.headerBOTTOMLEFTTOP {
    	border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"9")%>px;
    }	
	
	TD.headerALL {
    	border: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"9")%>px;
    }		

		TD.BOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
    }
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
    }		
    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
		}
		
	.others_header{
		
		border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"9")%>px;
	}	
	.others_body{		
    	border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
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
	boolean bolRemoveOtherEarnings = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheet",null);
								
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
	 	
	String strSchCode = dbOP.getSchoolIndex();
	if(strSchCode == null)
		strSchCode = "";	

	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	Vector vRetResult = null;
	int iCols = 0;
	int iCols2 = 0;
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
	
	
	
		
	boolean bolShowHeader = false; 	
	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
	
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
	 //for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {			
//			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
//				strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 1) + "-" + (String)vSalaryPeriod.elementAt(i + 2);
//				strPayEnd = (String)vSalaryPeriod.elementAt(i + 7);
//				break;
//			}
//			
//	 }	 
	 for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		} 
	}//end of for loop.
	 
	 
	 
int iEmpCounterPerDept = 0;
int iTotalEmployees = 0;
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
	int iEmpCount = 1;

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
	//sub total	
	double dDeptTotalBasic = 0;
	double dDeptTotalAdj = 0;
	double dDeptTotalOverload = 0;
	double dDeptTotalOvertime = 0;
	double dDeptTotalOthersEarnings = 0;
	double dDeptTotalTardiness = 0;
	double []arrdDeptEarnings = new double[iEarnColCount]; 
	double []arrdDeptDeduction = new double[iDedColCount]; 
	double dDeptTotalOthersDed = 0;	
	double dDeptTotalGross = 0;
	double dDeptTotalSSS = 0;
	double dDeptTotalPhealth = 0;
	double dDeptTotalPagibig = 0;
	double dDeptTotalPeraa = 0;
	double dDeptTotalTax = 0;
	double dDeptTotalDedTotal= 0;
	double dDeptTotalNet = 0;
	int iDeptCounter = 1;
	int iDeptTotalCounter = 0;	
	//end sub total
	
	//>grand total
	double dGDeptTotalBasic = 0;
	double dGDeptTotalAdj = 0;
	double dGDeptTotalOverload = 0;
	double dGDeptTotalOvertime = 0;
	double dGDeptTotalOthersEarnings = 0;
	double dGDeptTotalTardiness = 0;
	double []arrdGDeptEarnings = new double[iEarnColCount]; 
	double []arrdGDeptDeduction = new double[iDedColCount]; 
	double dGDeptTotalOthersDed = 0;	
	double dGDeptTotalGross = 0;
	double dGDeptTotalSSS = 0;
	double dGDeptTotalPhealth = 0;
	double dGDeptTotalPagibig = 0;
	double dGDeptTotalPeraa = 0;
	double dGDeptTotalTax = 0;
	double dGDeptTotalDedTotal= 0;
	double dGDeptTotalNet = 0;
	
	//<sul
				
	String[] astrContributions = {"1", "1", "1", "1", "1"};
	// 0 = sss_amt
	// 1 = philhealth_amt
	// 2 = pag_ibig
	// 3 = gsis_ps
  // 4 = peraa
	
		if(bolIsSchool)
			iContributions = 4;
		else
			iContributions = 3;
	
	if(WI.fillTextValue("hide_sss").equals("1")){
		iContributions -= 1;
		astrContributions[0] = "0";
	}	
	if(WI.fillTextValue("hide_ph").equals("1")){
		iContributions -= 1;
		astrContributions[1] = "0";
	}
	if(WI.fillTextValue("hide_peraa").equals("1")){
		iContributions -= 1;
		astrContributions[4] = "0";
	}
	if(WI.fillTextValue("hide_pgbig").equals("1")){
		iContributions -= 1;
		astrContributions[2] = "0";
	}
	
	int iTotalPages = (vRows.size())/(iFieldCount*iMaxRecPerPage);			
	double[] adEarningTotal = new double[iEarnColCount];
	double[] adGEarningTotal = new double[iEarnColCount];
	
	double[] adDeductTotal = new double[iDedColCount];
	double[] adGDeductTotal = new double[iDedColCount];
	
	double[] adEarnDedTotal = new double[iEarnDedCount];
	double[] adGEarnDedTotal = new double[iEarnDedCount];

	if((vRows.size() % (iFieldCount*iMaxRecPerPage)) > 0) 
		 ++iTotalPages;

	 for (;i < vRows.size();iPage++){
		 
		 dDeptTotalBasic = 0;
		 dDeptTotalAdj = 0;
		 dDeptTotalOverload = 0;
		 dDeptTotalOvertime = 0;
		 dDeptTotalOthersEarnings = 0;
		 dDeptTotalTardiness = 0;
		  for(iCols = 0 ;iCols < iEarnColCount ; iCols ++)
				arrdDeptEarnings[iCols] = 0;	
		 for(iCols = 0;iCols < iDedColCount; iCols ++)		 	
			 arrdDeptDeduction[iCols] = 0; 
		 
		 dDeptTotalOthersDed = 0;	
		 dDeptTotalGross = 0;
		 dDeptTotalSSS = 0;
		 dDeptTotalPhealth = 0;
		 dDeptTotalPagibig = 0;
		 dDeptTotalPeraa = 0;
		 dDeptTotalTax = 0;
		 dDeptTotalDedTotal= 0;
		 dDeptTotalNet = 0;
	 
	 
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
		 
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  
 
   <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
    <tr>	 
		<td width="35%" valign="middle" align="center" style="padding-right:10px">		
		<span>		
			<div style="position: relative; display: inline; top: 35px;">			
				<img src="../../../../images/logo/<%=strSchCode%>.gif" width="70px"  height="70px" style="position:absolute; top:-40px"/>
				<span style="width: 200px; left: 75px; position: relative; top: -30px;" >
					<strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong>	
					<span style="display:block" >				 	
					 	<font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>				
					</span> 
					<span style="display:block" >		
						<BR />								 	
					 	<strong>HUMAN RESOURCE DEVELOPMENT DEPARTMENT	</strong>			
					</span> 
					<span style="display:block" >
						<BR />									 	
					 	<strong>STAFF PAYROLL BY DEPARTMENT</strong>
					</span> 
					<span style="display:block; padding-top:5px" >														 	
					 	<strong><font size ="1"> <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong>
					</span> 				 			
					
				</span> 
				
				
			</div>
		</span>
		</td>     
    </tr>
  </table>
  
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
		<td>&nbsp;</td>
		<td colspan="33" style="border-bottom:#000000 1px solid">&nbsp;</td>
	</tr>
    <tr> 
	  <td rowspan="2">&nbsp;</td>
      <td width="17%" height="33" rowspan="2" align="center" class="headerBOTTOMLEFT">DEPARTMENT/COLLEGE </td>
	  <td width="2%" rowspan="2" align="center" class="headerBOTTOMLEFT">&nbsp; </td>				
      <td width="4%" rowspan="2" align="center" class="headerBOTTOMLEFT">BASIC SALARY </td>
      <td width="3%" rowspan="2" align="center" class="headerBOTTOMLEFT">ADJ. </td>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
      <td width="3%" rowspan="2" align="center" class="headerBOTTOMLEFT"><span class="headerBOTTOMLEFT"><%=(String)vEarnCols.elementAt(iCols)%></span></td>
			<%}%>
	  
      <td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFT">OVERLOAD</td>
	  <td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFT">OVERTIME</td>
      <td width="5%" rowspan="2" align="center" class="others_header"><span class="BOTTOMLEFT">OTHERS</span></td>
      <td align="center" class="headerBOTTOMLEFT">DEDUCTIONS</td>
      <td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFT"><span class="BOTTOMLEFT">GROSS EARNINGS </span></td>
    
		  <!-- 2nd table headers  -->
	   <%if(iContributions > 0){%>
			<td width="8%" colspan="<%=iContributions%>" align="center" class="headerBOTTOMLEFT">CONTRIBUTIONS</td>
			<%}%>
      <td width="4%" rowspan="2" align="center" class="headerBOTTOMLEFT">WITHTAX</td>
			<%			
			for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>			
      <td width="3%" rowspan="2" align="center" class="headerBOTTOMLEFT"><%=strTemp%></td>
			<%}%>
			<td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFT">OTHERS</td>
			<td width="6%" rowspan="2" align="center" class="headerBOTTOMLEFT">TOTAL DEDUCTIONS</td>
			<td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFTRIGHT"><span class="BOTTOMLEFTRIGHT">NET PAY</span></td>
	  
	  <!-- end of  2nd table -->
	
	
	
	</tr>
		
		
    <tr>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td align="center" class="headerBOTTOMLEFT"><%=(String)vEarnDedCols.elementAt(iCols)%></td>
			<%}%>
      <td align="center" class="headerBOTTOMLEFT">TARDINESS/<br>UNDERTIME</td>
	  
	  <!-- start one table -->
	  <%if(astrContributions[0].equals("1")){%>
			<td width="5%" align="center" class="headerBOTTOMLEFT">SSS PREM </td>
			<%} if(astrContributions[1].equals("1")){%>
      <td width="6%" align="center" class="headerBOTTOMLEFT">PHILHEALTH</td>
			<%}if(astrContributions[2].equals("1")){%>
      <td width="4%" align="center" class="headerBOTTOMLEFT">HDMF PREM </td>
			<%} if(bolIsSchool && astrContributions[4].equals("1")){%>
			<td width="4%" align="center" class="headerBOTTOMLEFT">PERAA</td>
			<%}%>
	  <!-- end one table -->
	  
    </tr>
    <% 
	
	if (vRows != null && vRows.size() > 0 ){
	
	//double dDeptTotalBasic = 0;
//	double dDeptTotalAdj = 0;
//	double dDeptTotalOverload = 0;
//	double dDeptTotalOvertime = 0;
//	double dDeptTotalOthersEarnings = 0;
//	double dDeptTotalTardiness = 0;
//	double []arrdDeptEarnings = new double[iEarnColCount]; 
//	double []arrdDeptDeduction = new double[iDedColCount]; 
//	double dDeptTotalOthersDed = 0;	
//	double dDeptTotalGross = 0;
//	double dDeptTotalSSS = 0;
//	double dDeptTotalPhealth = 0;
//	double dDeptTotalPagibig = 0;
//	double dDeptTotalPeraa = 0;
//	double dDeptTotalTax = 0;
//	double dDeptTotalDedTotal= 0;
//	double dDeptTotalNet = 0;
//	int iDeptCounter = 1;
//	int iDeptTotalCounter = 0;
	
		//System.out.println("vRows " + vRows.size());
		//System.out.println("vRows " + vRows);
		
		
		
      for(i = 0; i < vRows.size(); ){
	  		iEmpCounterPerDept += 1;
			
	
	  		if(i+iFieldCount+1 < vRows.size()){
				if(i == 0){					 
					strCurColl = WI.getStrValue((String)vRows.elementAt(i+2),"0");		
					strCurDept = WI.getStrValue((String)vRows.elementAt(i+3),"0");	
				}
				 
				strNextColl = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 2),"0");		
				strNextDept = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 3),"0");		
				
				//if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
				if( ( !(strCurColl).equals(strNextColl) )    ||  ( !(strCurDept).equals(strNextDept) &&  strCurColl.equals("0") )  ){	
					bolShowHeader = true;
				} 
				
			}
	  
			vEarnings = (Vector)vRows.elementAt(i+53);
			vSalDetail = (Vector)vRows.elementAt(i+55); 
			vOTDetail = (Vector)vRows.elementAt(i+56);
			vEarnDed = (Vector)vRows.elementAt(i+59);			
			dLineTotal = 0d;
			dBasic = 0d;
			dDaysWorked = 0d;
			dLineOver = 0d;	
					
			vDeductions = (Vector)vRows.elementAt(i+54);
			dEmpDeduct = 0d;
			dOtherDed = 0d;
			dEmpDeduct = 0d;
			dOtherDed = 0d;
	%>
   <!-- <tr>-->
      <%
				// Account number
				strTemp = null;
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp = (String)vSalDetail.elementAt(1);
			%>	
     	
     <!-- <td height="18" class="BOTTOMLEFT"><strong>&nbsp;<%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong></td>-->	
							
							
		  <%
				// department
				strTemp = null;
				if((String)vRows.elementAt(i + 62)== null || (String)vRows.elementAt(i + 63)== null){
					strTemp = " ";			
				  }else{
					strTemp = " - ";
				  }
			%>	
     	
     <!-- <td height="18" class="BOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRows.elementAt(i + 62),"")%><%=strTemp%><%=WI.getStrValue((String)vRows.elementAt(i + 63),"")%></td>						-->
							
									
      <%
				// basic salary
				//	if(WI.fillTextValue("salary_base").equals("0"))
					dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));
				//else
				//	dLineTotal = dDaysWorked * dTemp;
						
				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
				dDeptTotalBasic += dLineTotal;
			%>		     
     <!-- <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>-->
      <%
				// adjustment amount
				strTemp = (String)vRows.elementAt(i + 51); 	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp ,true);
				dLineTotal += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
					
				dDeptTotalAdj  += dTemp;	
			%>		     
     <!-- <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dLineTotal += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);
			if(dTemp <= 0)
				strTemp = "0.00";			
			arrdDeptEarnings[iCols-2] += dTemp;
		%>          
     <!-- <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
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
		if(dTemp == 0d)
			strTemp = "0.00";
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
		}
		if(iHour == 0 && iMinute == 0)
			strTemp = "0.00";				 
	  %>
      <!--<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td> -->
      <%
				// regular OT amount
				strTemp = null;
				dTemp = 0d;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(1);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				//dLineOver += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>
      <!--<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td> -->
      		<%
				/*
				// rest day OT hour
				strTemp = null;
				dTemp = 0d;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(2);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				if(dTemp == 0d)
					strTemp = "0.00";
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
				}
				if(iHour == 0 && iMinute == 0)
					strTemp = "0.00";				
			%>  
      <!--<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
      <%
				// rest day OT amount
				strTemp = null;
				dTemp = 0d;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(3);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				//dLineOver += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>  	    
		<!--	<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
      <%
				// Number of hours night differential
				strTemp = null;
				dTemp = 0d;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(4);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				if(dTemp == 0d)
					strTemp = "0.00";
			%>  
      <!--<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
      <%
				// night differential amount
				strTemp = (String)vRows.elementAt(i + 24);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				//dLineOver += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>      
      <!--<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
	  
	   <%
				// overload
				strTemp = (String)vRows.elementAt(i + 22); 
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));																
				dLineTotal += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
				else
					strTemp = CommonUtil.formatFloat(dTemp,true);	
				
				dDeptTotalOverload  += dTemp;	
		%> 
	 <!-- <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>--><!-- overload -->	
	   <%
	   			// add night differential amount to OT total
				strTemp = (String)vRows.elementAt(i + 24);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dLineOver = dTemp;
	   
				// OT
				strTemp = (String)vRows.elementAt(i + 23); 
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dLineOver += dTemp;				
				if(dLineOver <= 0d)
					strTemp = "0.00";
				else
					strTemp = CommonUtil.formatFloat(dLineOver,true);
				dDeptTotalOvertime  += dLineOver;	
		%> 
      <!--<td align="right" class="BOTTOMLEFT"><%=strTemp%>&nbsp;</td>--><!-- OT total -->
	  
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
		dLineTotal += dOtherEarn;
		strTemp = CommonUtil.formatFloat(dOtherEarn,2);
		
		//check if has in order not to remove.sul01242013
		if(dOtherEarn > 0)
			bolRemoveOtherEarnings = false;
		dDeptTotalOthersEarnings  += dOtherEarn; 	
	  %>			
      <!--<td align="right" class="others_body"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				if(strTemp.equals("0"))
					strTemp = "0.00";			
			%>   			
      <!--<td width="6%" align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
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
				if(dTemp == 0d)
					strTemp = "0.00";
				dDeptTotalTardiness  += dTemp;	
			%>				
      <!--td width="5%" align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>-->
			<%
				dLineTotal += dLineOver;
				dDeptTotalGross  += dLineTotal;
			%>
     <!-- <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>-->
	  
	  <!-- start of one table -->
	  <%if(astrContributions[0].equals("1")){
				// sss contribution
				strTemp = (String)vRows.elementAt(i + 39);			
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
				dDeptTotalSSS  += dTemp;	
			%>	     
     <!-- <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
			 <%}%>
      <%if(astrContributions[1].equals("1")){
				// philhealth
				strTemp = (String)vRows.elementAt(i + 40);				
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
				dDeptTotalPhealth  += dTemp;		
			%>	  
     <!-- <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
			<%}%>
      <%if(astrContributions[2].equals("1")){
				// pag ibig
				strTemp = (String)vRows.elementAt(i +41);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
				dDeptTotalPagibig  += dTemp;		
			%>	  
     <!-- <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
			<%}%>
			<%if(bolIsSchool){%>			
			<%if(astrContributions[4].equals("1")){
				// PERAA
				strTemp = (String)vRows.elementAt(i + 43);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
				dDeptTotalPeraa  += dTemp;		
			%>	     
      <!--<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
			<%}
			}%>
      <%
				// tax withheld
				strTemp = (String)vRows.elementAt(i + 46);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);														
				dEmpDeduct += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
				dDeptTotalTax  += dTemp;		
			%>   
     <!-- <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>	-->	
		
			<%for(iCols = 1,iCols2 = 0;iCols <= iDedColCount/2; iCols ++,iCols2++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				dEmpDeduct += dTemp;
				strTemp = CommonUtil.formatFloat(dTemp,true);
				if(dTemp <= 0)
					strTemp = "0.00";	
				arrdDeptDeduction[iCols2] += dTemp;								
			%>  			
      <!--<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>-->
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
		dEmpDeduct += dOtherDed;
		dDeptTotalDedTotal += dEmpDeduct;
		dDeptTotalOthersDed += dOtherDed;
	  %>			
			<!--assume all ded have group.ingon si gretchen jose. 01242013 -->
			<!--<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dOtherDed,true),"&nbsp;")%>&nbsp;</td>-->
			<!--<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dEmpDeduct,true),"&nbsp;")%>&nbsp;</td>-->
			<%
				strTemp = (String)vRows.elementAt(i+52);
				dDeptTotalNet  += Double.parseDouble(strTemp);
			%>
			<!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>	-->
	  <!-- end of one table  -->
	  
   <!-- </tr>-->
    <%
		i = i + iFieldCount;  
		 if(i < vRows.size()){
			 strCurColl = WI.getStrValue((String)vRows.elementAt(i+2),"0");
			 strCurDept = WI.getStrValue((String)vRows.elementAt(i+3),"0");
		 }	 
		 
		if(bolShowHeader || i  >= vRows.size()){
			bolShowHeader = false;
			  %>
			<tr>
			<td align="right"><%=iDeptCounter%>&nbsp;</td>
			  <%
			  	iDeptCounter += 1;				
				strTemp =  WI.getStrValue( (String)vRows.elementAt( (i+62)-iFieldCount),"");
				strTemp2 = (String)vRows.elementAt((i+63) - iFieldCount );
				strTemp2 = WI.getStrValue(strTemp2,"");
				
				if(strTemp.length() == 0 )
					strTemp = strTemp2;
				
			%>
			  <td height="26"  valign="center" class='BOTTOMLEFT'><strong>&nbsp;<%=strTemp%></strong> </td>
			  	<td  align="right" class="BOTTOMLEFT"><strong><%=iEmpCounterPerDept%></strong>&nbsp;</td>
						  
			   <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalBasic ,true)%>&nbsp;</td>
			  <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalAdj ,true)%>&nbsp;</td>
			  <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
			 	 <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(arrdDeptEarnings[iCols-2],true)%>&nbsp;</td>
			  <%}%>
			  <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalOverload ,true)%>&nbsp;</td>
			  <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalOvertime ,true)%>&nbsp;</td>
			  <td  align="right" class="others_body"><%=CommonUtil.formatFloat(dDeptTotalOthersEarnings ,true)%>&nbsp;</td>
			  <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalTardiness ,true)%>&nbsp;</td>
			  
			  <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalGross  ,true)%>&nbsp;</td>
			  
			   <%if(astrContributions[0].equals("1")){%>
			  		<td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalSSS  ,true)%>&nbsp;</td>
				<%}%>
			<%if(astrContributions[1].equals("1")){%>
			  <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalPhealth  ,true)%>&nbsp;</td>
			 <%}%> 
			  <%if(astrContributions[2].equals("1")){%>			 
			  <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalPagibig  ,true)%>&nbsp;</td>
			  <%}%>
			   <%if(astrContributions[4].equals("1")){%>
			  <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalPeraa  ,true)%>&nbsp;</td>
			  <%}%>
			  <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalTax  ,true)%>&nbsp;</td>
			  <%  for(iCols = 0;iCols < iDedColCount/2; iCols++)	{ %>
			  <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(arrdDeptDeduction[iCols] ,true)%>&nbsp;</td>
			  <%}%>
			 <% /*assume all ded have group.ingon si gretchen jose. 01242013 
			* becasue if they dont,  wont display
			* They changed their mind. Display again. sul03132013
			*/			
			%>		
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalOthersDed,true)%></td>
			  <td  align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dDeptTotalDedTotal ,true)%>&nbsp;</td>
			  <td  align="right" class="BOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dDeptTotalNet  ,true)%>&nbsp;</td>
			  
			  
			</tr>
			<%
			iTotalEmployees += iEmpCounterPerDept; 
			iEmpCounterPerDept = 0;
						
			 dGDeptTotalBasic += dDeptTotalBasic;
			 dGDeptTotalAdj += dDeptTotalAdj;
			 dGDeptTotalOverload += dDeptTotalOverload;
			 dGDeptTotalOvertime += dDeptTotalOvertime;
			 dGDeptTotalOthersEarnings +=dDeptTotalOthersEarnings ;
			 dGDeptTotalTardiness +=dDeptTotalTardiness ;
			  for(iCols = 0 ;iCols < iEarnColCount ; iCols ++)
					arrdGDeptEarnings[iCols] += arrdDeptEarnings[iCols];	
			 for(iCols = 0;iCols < iDedColCount; iCols ++)		 	
				 arrdGDeptDeduction[iCols] +=arrdDeptDeduction [iCols]; 
			 
			 dGDeptTotalOthersDed += dDeptTotalOthersDed;	
			 dGDeptTotalGross += dDeptTotalGross;
			 dGDeptTotalSSS += dDeptTotalSSS;
			 dGDeptTotalPhealth +=dDeptTotalPhealth ;
			 dGDeptTotalPagibig += dDeptTotalPagibig;
			 dGDeptTotalPeraa += dDeptTotalPeraa;
			 dGDeptTotalTax +=dDeptTotalTax ;
			 dGDeptTotalDedTotal+=dDeptTotalDedTotal ;
			 dGDeptTotalNet +=dDeptTotalNet ;
			
			
			 dDeptTotalBasic = 0;
			 dDeptTotalAdj = 0;
			 dDeptTotalOverload = 0;
			 dDeptTotalOvertime = 0;
			 dDeptTotalOthersEarnings = 0;
			 dDeptTotalTardiness = 0;
			  for(iCols = 0 ;iCols < iEarnColCount ; iCols ++)
					arrdDeptEarnings[iCols] = 0;	
			 for(iCols = 0;iCols < iDedColCount; iCols ++)		 	
				 arrdDeptDeduction[iCols] = 0; 
			 
			 dDeptTotalOthersDed = 0;	
			 dDeptTotalGross = 0;
			 dDeptTotalSSS = 0;
			 dDeptTotalPhealth = 0;
			 dDeptTotalPagibig = 0;
			 dDeptTotalPeraa = 0;
			 dDeptTotalTax = 0;
			 dDeptTotalDedTotal= 0;
			 dDeptTotalNet = 0;
			
		}		
		
	}//end for loop	
	
	if(i >= vRows.size()){ %>
		<tr>
			<td align="right">&nbsp;</td>
			  <%
			  	iDeptCounter += 1;
				strTemp = "";
				strTemp2 = (String)vRows.elementAt((i+63) - iFieldCount );
				strTemp2 = WI.getStrValue(strTemp2,"");
			%>
			  <td height="32"  valign="center" class='BOTTOMLEFT' align="right"><strong>TOTAL&nbsp;&nbsp;&nbsp;&nbsp;</strong> </td>
			  	<td  align="right" class="BOTTOMLEFT"><strong><%=iTotalEmployees%></strong>&nbsp;</td>
						  
		   <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalBasic ,true)%></strong>&nbsp;</td>
			  <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalAdj ,true)%></strong>&nbsp;</td>
			  <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
		 	 <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(arrdGDeptEarnings[iCols-2],true)%></strong>&nbsp;</td>
			  <%}%>
		  <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalOverload ,true)%></strong>&nbsp;</td>
			  <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalOvertime ,true)%></strong>&nbsp;</td>
			  <td  align="right" class="others_body"><strong><%=CommonUtil.formatFloat(dGDeptTotalOthersEarnings ,true)%></strong>&nbsp;</td>
			  <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalTardiness ,true)%></strong>&nbsp;</td>
			  
			  <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalGross  ,true)%></strong>&nbsp;</td>
			  
			 
			     <%if(astrContributions[0].equals("1")){%>
			  		<td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalSSS  ,true)%></strong>&nbsp;</td>
				<%}%>
			<%if(astrContributions[1].equals("1")){%>
			  <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalPhealth  ,true)%></strong>&nbsp;</td>
			 <%}%> 
			  <%if(astrContributions[2].equals("1")){%>			 
			  <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalPagibig  ,true)%></strong>&nbsp;</td>
			  <%}%>
			   <%if(astrContributions[4].equals("1")){%>
			  <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalPeraa  ,true)%></strong>&nbsp;</td>
			  <%}%>
			  
			  
			  
			  <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalTax  ,true)%></strong>&nbsp;</td>
			  <%  for(iCols = 0;iCols < iDedColCount/2; iCols++)	{ %>
		  <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(arrdGDeptDeduction[iCols] ,true)%></strong>&nbsp;</td>
			  <%}%>
			  <%
			/*assume all ded have group.ingon si gretchen jose. 01242013 
			* becasue if they dont,  wont display
			* They changed their mind. Display again. sul03132013
			*/			
			%>		
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalOthersDed,true)%></strong>&nbsp;</td>  
		  <td  align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGDeptTotalDedTotal ,true)%></strong>&nbsp;</td>
			  <td  align="right" class="BOTTOMLEFTRIGHT"><strong><%=CommonUtil.formatFloat(dGDeptTotalNet  ,true)%></strong>&nbsp;</td>
	</tr>
	<tr>
		<td colspan="24">&nbsp; </td>
	
	</tr>
	<%}
	
	} // end if %>
	
  </table>	
	  
	<%if (bolPageBreak || iMainTemp == vRows.size()){%>
  <DIV style="page-break-before:always">&nbsp;</Div>
  <% }//page break ony if it is not last page.
  %> 
	
  

  
	<%if(i >= vRows.size()){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td width="8%">&nbsp;</td>
        <td width="21%">Prepared by: </td>
		<td width="71%">&nbsp;</td>
        
      </tr>
      <tr>
        <td>&nbsp;</td>      
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td align="center"><%=WI.fillTextValue("prepared_by")%></td>
		
      </tr>
      <tr>
        <td height="30">&nbsp;</td>
        <td  style="border-top:#000000 solid 1px;" align="center">HRD Staff</td>
		
      </tr>
    </table>
	<%}%>
	
	<%if (iNumRec < vRows.size()){%>
  <DIV style="page-break-before:always">&nbsp;</Div>
  <% }//page break ony if it is not last page.
	  } //end for (iNumRec < vRows.size()	  
  } //end end upper most if (vRows !=null)%>
  
  
    <%if(bolRemoveOtherEarnings){%>
	  <script type="text/javascript">
  		var tds = document.getElementsByTagName("td");
		for (var i = 0; i<tds.length; i++) {
		
		  // If it currently has the ColumnHeader class...
		  if (tds[i].className == "others_header" || tds[i].className == "others_body" ) {
			// delete here
			tds[i].style.display = "none";			
		  }
		}	
	  </script> 
 <%}//end of remove other earnigs%>	
 
	<input type="hidden" name="prepared_by" value="<%=WI.fillTextValue("prepared_by")%>">
	<input type="hidden" name="verified_by" value="<%=WI.fillTextValue("verified_by")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>