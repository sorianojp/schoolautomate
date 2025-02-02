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
		border-top: solid 1px #000000;	
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
.style1 {border-bottom: solid 1px #000000; border-left: solid 1px #000000; font-family: Verdana, Arial, Geneva, Helvetica, sans-serif; font-weight: bold; }
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
								"Admin/staff-Payroll-REPORTS-payrollsheet","payroll_register_cl.jsp");
								
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
	 	
	String strDepartmentSelected = WI.fillTextValue("d_index");
	String strCollegeSelected = WI.fillTextValue("c_index");
	String strSQLQuery = null;	
	//>need to get the department and college selected here	
		if(strDepartmentSelected.length() > 0){			
			strSQLQuery  = "select d_name from department where d_index = " + strDepartmentSelected;
			strDepartmentSelected = dbOP.getResultOfAQuery(strSQLQuery, 0);
		}
		
		if(strCollegeSelected.length() > 0){			
			strSQLQuery  = "select c_name from college where c_index = " + strCollegeSelected;
			strCollegeSelected = dbOP.getResultOfAQuery(strSQLQuery, 0);
		}
		
	//<sul	
		
		
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
		if(bolIsSchool)
			iContributions = 4;
		else
			iContributions = 3;
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

	 for (;iNumRec < vRows.size();iPage++){
		 iMainTemp = iNumRec;
		 dTotalBasic = 0d;
		 dTotalAdjust = 0d;	
		 //for(iCols = 2;iCols < iEarnColCount; iCols++){
		 for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
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
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
	<td width="24">&nbsp;  </td>
      <td width="725" height="25"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></td>
    </tr>
			<!-- department -->	
	<%if(strDepartmentSelected != null && strDepartmentSelected.length() > 0){%>	
	<tr>
	 <td width="24">&nbsp;  </td>
      <td>DEPARTMENT : <%=strDepartmentSelected%></td>    
    </tr>
	<%}%>	
		
		<!-- COLLEGE -->	
	<%if(strCollegeSelected != null && strCollegeSelected.length() > 0){%>	
	<tr>
	 <td width="24">&nbsp;  </td>
      <td>COLLEGE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: <%=strCollegeSelected%></td>    
    </tr>
	<%}%>	
	
    <tr>
		<td width="24">&nbsp;  </td>
      <td>PAYROLL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : <%=strPayEnd%></td>
    </tr>
    <%
			if(bolIsSchool)
				strTemp = "/ teaching load cut off ";
			else
				strTemp = "";
		%>
		

		
    <tr>
	 <td width="24">&nbsp;  </td>
      <td>Days worked cut- off <%=strTemp%>: <%=strPayrollPeriod%></td>
      <td width="560" height="19" align="right" class="thinborderBOTTOM" >&nbsp;Date and time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
    <%if(strEmpCatg.length() > 0){%>
    <tr>
		<td width="24">&nbsp;  </td>
      <td><%=strEmpCatg%> Staff</td>
    </tr>
    <%}%>
    <tr>
		<td width="24">&nbsp;  </td>
		<td class="NoBorder">&nbsp;</td>
      <td height="19" class="NoBorder" align="right" >&nbsp;</td>
    </tr>
  </table>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">  
    <tr>
		<td>&nbsp;</td>
      <td width="7%" height="33" rowspan="2" align="center" class="headerBOTTOMLEFTTOP">NAME 
          OF EMPLOYEE </td>		
	 <!-- <td width="11%" rowspan="2" align="center" class="headerBOTTOMLEFTTOP">DEPARTMENT/COLLEGE </td>			-->
      <td width="4%" rowspan="2" align="center" class="headerBOTTOMLEFTTOP">BASIC SALARY </td>
      <td width="4%" rowspan="2" align="center" class="headerBOTTOMLEFTTOP">ADJ. </td>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
      <td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFTTOP"><%=(String)vEarnCols.elementAt(iCols)%></td>
			<%}%>     
      <td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFTTOP">OVERLOAD</td>
	  <td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFTTOP">OVERTIME </td>	  
      <td width="4%" rowspan="2" align="center"  class="others_header" ><span class="headerBOTTOMLEFTTOP">OTHERS</span></td>
      <td colspan="<%=iEarnDedCount+1%>" align="center" class="headerBOTTOMLEFTTOP">DEDUCTIONS</td>
      <td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFTTOP"><span class="BOTTOMLEFT">GROSS EARNINGS </span></td>
	  
	   <!-- 2nd table headers  -->
	   <%if(iContributions > 0){%>
			<td colspan="<%=iContributions%>" align="center" class="headerBOTTOMLEFTTOP">CONTRIBUTIONS</td>
			<%}%>
      <td width="4%" rowspan="2" align="center" class="headerBOTTOMLEFTTOP">WITHTAX</td>
			<%			
			for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>			
      <td width="3%" rowspan="2" align="center" class="headerBOTTOMLEFTTOP"><%=strTemp%></td>
			<%}%>
			<td width="5%" rowspan="2" align="center" class="headerBOTTOMLEFTTOP">OTHERS</td>
			<td width="6%" rowspan="2" align="center" class="headerBOTTOMLEFTTOP">TOTAL DEDUCTIONS</td>
			<td width="3%" rowspan="2" align="center" class="headerAll"  ><span class="BOTTOMLEFTRIGHT">NET PAY</span></td>
	  
	  <!-- end of  2nd table -->  	   
	  
    </tr>	
	
    <tr>
		<td>&nbsp;  </td>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td align="center" class="headerBOTTOMLEFT"><%=(String)vEarnDedCols.elementAt(iCols)%></td>
			<%}%>
      <td width="8%" height="25" align="center" class="headerBOTTOMLEFT">TARDINESS/<br>
UNDERTIME</td>
		 <!-- start one table -->
	  <%if(astrContributions[0].equals("1")){%>
			<td width="3%" align="center" class="headerBOTTOMLEFT">SSS PREM </td>
			<%} if(astrContributions[1].equals("1")){%>
      <td width="6%" align="center" class="headerBOTTOMLEFT">PHILHEALTH</td>
			<%}if(astrContributions[2].equals("1")){%>
      <td width="4%" align="center" class="headerBOTTOMLEFT">HDMF PREM </td>
			<%} if(bolIsSchool && astrContributions[4].equals("1")){%>
			<td width="6%" align="center" class="headerBOTTOMLEFT">PERAA</td>
			<%}%>
	  <!-- end one table -->





    </tr>
	  <% 
		for(iCount = 1;iMainTemp < vRows.size(); iMainTemp += iFieldCount, ++iCount){
					
	  dLineTotal = 0d;
	  dBasic = 0d;
		dDaysWorked = 0d;
		dLineOver = 0d;	
		
		dEmpDeduct = 0d;
		dOtherDed = 0d;
				
		i = iMainTemp;
		vEarnings = (Vector)vRows.elementAt(i+53);
		vDeductions = (Vector)vRows.elementAt(i+54);
		vSalDetail = (Vector)vRows.elementAt(i+55); 
		vOTDetail = (Vector)vRows.elementAt(i+56);
		vEarnDed = (Vector)vRows.elementAt(i+59);
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>
    <tr>
      <%
				// Account number
				strTemp = null;
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp = (String)vSalDetail.elementAt(1);
			%>		
	  <td width="1%" align="right" class="NoBorder"><%=iEmpCount++%>&nbsp;</td>
      <td height="19" class="BOTTOMLEFT"><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong></td>
		
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
				//if(WI.fillTextValue("salary_base").equals("0"))
					dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));
				//else
				//	dLineTotal = dDaysWorked * dTemp;
					
				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
				dTotalBasic += dLineTotal;
			%>		     
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
      <%
				// adjustment amount
				strTemp = (String)vRows.elementAt(i + 51); 	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp ,true);
				dLineTotal += dTemp;
				dTotalAdjust += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>		     
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dLineTotal += dTemp;
			adEarningTotal[iCols-2] = adEarningTotal[iCols-2] + dTemp;			
			strTemp = CommonUtil.formatFloat(dTemp,true);
			if(dTemp <= 0)
				strTemp = "0.00";
					
		%>          
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<%}%>
			
		<%
				// overload
				strTemp = (String)vRows.elementAt(i + 22); 
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dLineTotal += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
				else
					strTemp = CommonUtil.formatFloat(dTemp,true);	
				dTotalOverLoad += dTemp;
		%>		
	 <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td><!-- overload -->	
      <%
				// regular OT Hours
				/*
				strTemp = null;
				dTemp = 0d;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(0);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				dTotalRegOtHr += dTemp;
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
					
					iRegHourPage += iHour;
					iRegMinPage += iMinute;
				}				
				if(iHour == 0 && iMinute == 0)
					strTemp = "";		
	 
				// regular OT amount
				strTemp = null;
				dTemp = 0d;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(1);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				dTotalRegOtAmt += dTemp;
				dLineOver += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			
				// rest day OT hour
				/*
				strTemp = null;
				dTemp = 0d;
				if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(2);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				dTotalRestOtHr += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
				*/
				strTemp = null;
				iHour = 0;
				iMinute = 0;
			//	if(vOTDetail != null && vOTDetail.size() > 0){
//					strTemp = (String)vOTDetail.elementAt(7);
//					iHour = Integer.parseInt(strTemp);	
//																
//					strTemp2 = (String)vOTDetail.elementAt(8);
//					iMinute = Integer.parseInt(strTemp2);
//					if(strTemp2.length() == 1)
//						strTemp2 = "0" + strTemp2;
//										
//					strTemp = strTemp + ":" + strTemp2;
//					iRestHourPage  += iHour;
//					iRestMinPage += iMinute;					
//				}
				//if(iHour == 0 && iMinute == 0)
//					strTemp = "";					
//			
//				// rest day OT amount
//				strTemp = null;
//				dTemp = 0d;
//				if(vOTDetail != null && vOTDetail.size() > 0){
//					strTemp = (String)vOTDetail.elementAt(3);
//					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
//				}
//				dTotalRestOtAmt += dTemp;
//				dLineOver += dTemp;
//				if(dTemp == 0d)
//					strTemp = "0.00";
			
//				// Number of hours night differential
//				strTemp = null;
//				dTemp = 0d;
//				if(vOTDetail != null && vOTDetail.size() > 0){
//					strTemp = (String)vOTDetail.elementAt(4);
//					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
//				}
//				dTotalNightHrs += dTemp;
//				if(dTemp == 0d)
//					strTemp = "0.00";
			
				//ot total amount
				strTemp = (String)vRows.elementAt(i + 23); 
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dLineOver = dTemp;
				
				// night differential amount
				strTemp = (String)vRows.elementAt(i + 24);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
				dTotalNightDiff += dTemp;				
				if(dTemp == 0d)
					strTemp = "0.00";
			
				dLineOver += dTemp;
				dTotalOver +=dLineOver;
			%>			
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dLineOver,true)%>&nbsp;</td><!-- ot -->	
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
		dTotalOtherEarn += dOtherEarn;
		dLineTotal += dOtherEarn;
		strTemp = CommonUtil.formatFloat(dOtherEarn,2);
		
		//check if has in order not to remove.sul01242013
		if(dOtherEarn > 0)
			bolRemoveOtherEarnings = false;
		
	  %>			
      <td align="right" class="others_body"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				adEarnDedTotal[iCols-1] = adEarnDedTotal[iCols-1] + dTemp;				
				if(strTemp.equals("0"))
					strTemp = "0.00";			
			%>			
      <td width="6%" align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
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
				dTotalLateUT += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>				
      <td width="5%" align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				dLineTotal += dLineOver;
				dTotalGross += dLineTotal;
			%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
	  
	  <!-- start of table2 -->
	  
	  <%if(astrContributions[0].equals("1")){
				// sss contribution
				strTemp = (String)vRows.elementAt(i + 39);			
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				dTotalSSS += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>	     
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%}%>
      <%if(astrContributions[1].equals("1")){
				// philhealth
				strTemp = (String)vRows.elementAt(i + 40);				
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				dTotalPhealth += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
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
					strTemp = "0.00";
			%>	  
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%}%>
			<%if(bolIsSchool){%>
			<%if(astrContributions[4].equals("1")){
				// PERAA
				strTemp = (String)vRows.elementAt(i + 43);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				dTotalPERAA+= dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>	     
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%}
			}%>
      <%
				// tax withheld
				strTemp = (String)vRows.elementAt(i + 46);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);														
				dEmpDeduct += dTemp;
				dTotalTax += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>   
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols ++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				adDeductTotal[iCols-1] = adDeductTotal[iCols-1] + dTemp;	
				dEmpDeduct += dTemp;
				strTemp = CommonUtil.formatFloat(dTemp,true);
				if(dTemp <= 0)
					strTemp = "0.00";
							
			%>  			
	  		
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
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
		dTotalOtherDed += dOtherDed;
		dEmpDeduct += dOtherDed;		
		dTotalDeductions += dEmpDeduct;
	  %>			
	  		<%
			/*assume all ded have group.ingon si gretchen jose. 01242013 
			* becasue if htey dont, it wont display.
			* just to make sure if they will change their mind again, just uncomment the td below	
			* Sakto jud akong instinct. They changed their mind. Display again. sul03132013
			*/
			%>
			<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dOtherDed,true)%></td>
			<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dEmpDeduct,true)%></td>
			<%
				strTemp = (String)vRows.elementAt(i+52);
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dTotalNetPay += dTemp;
			%>
			<td align="right" class="BOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(strTemp, true)%></td>
	  
	  
	  
	  
    </tr>
		<%}%>
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
		
		
		%>
		
   <!-- no sub total 
    <tr>
	  <td height="19">&nbsp;</td>
      <td height="19" class="BOTTOMLEFT"><font size="1"><strong>TOTAL :&nbsp;&nbsp;&nbsp;</strong></font></td>
     		
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalBasic,true)%>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalAdjust,true)%></td>
	 --> 
  		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			adGEarningTotal[iCols-2] += adEarningTotal[iCols-2];				
		%> 
     	 <!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(adEarningTotal[iCols-2],true)%></td>-->
      <%
	  	adEarningTotal[iCols-2] = 0;
	  }%>
			
	  <%
	  	iRegHourPage += iRegMinPage/60;
	  	iRegMinPage = iRegMinPage % 60;		
		
		strTemp = Integer.toString(iRegMinPage);
		if(strTemp.length() == 1)
		 	strTemp = "0" + strTemp; 
		
		iRegHourGrand += iRegHourPage;
		iRegMinGrand += iRegMinPage;
	  %>
      
	  <%
			iRestHourPage += iRestMinPage/60;
			iRestMinPage = iRestMinPage % 60;		
			
			strTemp = Integer.toString(iRestMinPage);
			if(strTemp.length() == 1)
				strTemp = "0" + strTemp; 
			
			iRestHourGrand += iRestHourPage;
			iRestMinGrand += iRestMinPage;
		  %>
	  <!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalOverLoad,true)%>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalOver,true)%>&nbsp;</td>
      <td align="right" class="others_body"><%=CommonUtil.formatFloat(dTotalOtherEarn,true)%>&nbsp;</td>-->
  		<%for(iCols = 1;iCols <= iEarnDedCount; iCols++){
			adGEarnDedTotal[iCols-1] = adEarnDedTotal[iCols-1];	
			%> 
      	<!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(adEarnDedTotal[iCols-1],true)%></td>-->
      <%
	  		adEarnDedTotal[iCols-1] = 0;	
	  }%>
     <!-- <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalLateUT,true)%>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalGross,true)%></td>-->
	  
	  
	  <!--
		<%if(astrContributions[0].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalSSS,true)%></td>
			<%}if(astrContributions[1].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalPhealth,true)%></td>
			<%}if(astrContributions[2].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalHdmf,true)%></td>
	  
      	<%}if(bolIsSchool && astrContributions[4].equals("1")){%>
			<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalPERAA,true)%></td>
			<%}%>
		-->
			
      	<!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalTax,true)%></td>-->
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols++){
				adGDeductTotal[iCols-1] += adDeductTotal[iCols-1];	
			%> 
			<!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(adDeductTotal[iCols-1],true)%></td>-->
			<%
				adDeductTotal[iCols-1] = 0;
			}%>
		<%
			/*assume all ded have group.ingon si gretchen jose. 01242013 
			* becasue if htey dont, it wont display		
			*/
			%>		
      <!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalOtherDed,true)%></td>-->
      <!--<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalDeductions ,true)%></td>
      <td align="right" class="BOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dTotalNetPay,true)%></td>
	  
    </tr>
	-->
		<%if(iMainTemp == vRows.size()){%>
    <tr>	  
     <td height="19">&nbsp;</td>
     <td height="19" class="BOTTOMLEFT">&nbsp;</td>    
	 <!-- <td align="right" class="BOTTOMLEFT">&nbsp;</td> 		-->
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
	  <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="others_body">&nbsp;</td>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%> 
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>			
	
     
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="others_body">&nbsp;</td>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols++){%> 
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
	  
	  
	  <%if(astrContributions[0].equals("1")){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%} if(astrContributions[1].equals("1")){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%} if(astrContributions[2].equals("1")){%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%} if(bolIsSchool && astrContributions[4].equals("1")){%>
			<td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols++){%> 
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
			<%}%>
      <%
			/*assume all ded have group.ingon si gretchen jose. 01242013 
			* becasue if htey dont, i wont display		
			* Sakto jud akong instinct. They changed their mind. Display again. sul03132013
			*/
			%>
	  <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFTRIGHT">&nbsp;</td>
	  
	  
    </tr>
    <tr>
	  <td>&nbsp;</td>	
      <td height="19" class="BOTTOMLEFT"><font size="1"><strong>GRAND TOTAL :&nbsp;&nbsp;&nbsp;</strong></font></td>
	   <!--<td align="right" class="BOTTOMLEFT">&nbsp;</td>-->
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalBasic,true)%></strong></td>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalAdjust,true)%></strong></td>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%> 
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(adGEarningTotal[iCols-2],true)%></strong></td>
			<%}%>			
	  <%
	  	iRegHourGrand += iRegMinGrand/60;
	  	iRegMinGrand = iRegMinGrand % 60;		
		
		strTemp = Integer.toString(iRegMinGrand);
		if(strTemp.length() == 1)
		 	strTemp = "0" + strTemp; 
	 	  
	  	iRestHourGrand += iRestMinGrand/60;
	  	iRestMinGrand = iRestMinGrand % 60;		
		
		strTemp = Integer.toString(iRestMinGrand);
		if(strTemp.length() == 1)
		 	strTemp = "0" + strTemp; 
	  %>	 
     <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalOverLoad,true)%></strong>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalOver,true)%></strong>&nbsp;</td> 
	    <td align="right" class="others_body"><strong><%=CommonUtil.formatFloat(dGTotalOtherEarn,true)%></strong>&nbsp;</td>    
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols++){%> 
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(adGEarnDedTotal[iCols-1],true)%>&nbsp;</strong></td>
			<%}%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalLateUT,true)%></strong>&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalGross,true)%></strong></td>
	  <% if(astrContributions[0].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalSSS,true)%></strong></td>
			<%} if(astrContributions[1].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalPhealth,true)%></strong></td>
			<%} if(astrContributions[2].equals("1")){%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalHdmf,true)%></strong></td>
      <%} if(bolIsSchool && astrContributions[4].equals("1")){%>
			<td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalPERAA,true)%></strong></td>
			<%}%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalTax,true)%></strong></td>
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols++){%>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(adGDeductTotal[iCols-1],true)%></strong></td>
			<%}%>
		 <%
			/*assume all ded have group.ingon si gretchen jose. 01242013 
			* becasue if htey dont, i wont display
			* They changed their mind. Display again. sul03132013
			*/			
			%>		
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalOtherDed,true)%></td>
      <td align="right" class="BOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGTotalDeductions ,true)%></strong></td>
      <td align="right" class="BOTTOMLEFTRIGHT"><strong><%=CommonUtil.formatFloat(dGTotalNetPay,true)%></strong></td>
    </tr>
		    
    <%}%>
  </table>	
	  
	<%if (bolPageBreak || iMainTemp == vRows.size()){%>
  <DIV style="page-break-before:always">&nbsp;</Div>
  <% }//page break ony if it is not last page.
  %> 
	<%iMainTemp = iNumRec;%>	
    
  
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
   
    <% 
		for(iCount = 1;iNumRec < vRows.size();iNumRec += iFieldCount, ++iCount){		
		if (iCount > iMaxRecPerPage){			
			break;
		} else 
			bolPageBreak = false;			
	  }//end for loop
	%>
		
  </table>	
  
	<%if(iNumRec == vRows.size()){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td width="4%">&nbsp;</td>
        <td width="17%">Prepared by: </td>
		<td width="2%">&nbsp;</td>
        <td width="20%">Checked by: </td>
		<td width="2%">&nbsp;</td>
        <td width="19%">Audited by: </td>
		<td width="2%">&nbsp;</td>
        <td width="24%"><strong>APPROVED FOR PAYMENT </strong></td>
		<td width="10%">&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>      
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td align="center"><%=WI.fillTextValue("prepared_by")%></td>
		<td>&nbsp;</td>
        <td align="center"><%=WI.fillTextValue("checked_by")%></td>
		<td>&nbsp;</td>
		<td align="center"><%=WI.fillTextValue("audited_by")%></td>
		<td>&nbsp;</td>
        <td align="center"><%=WI.fillTextValue("approved_by")%></td>
      </tr>
      <tr>
        <td height="30">&nbsp;</td>
        <td  style="border-top:#000000 solid 1px;">&nbsp;</td>
		<td>&nbsp;</td>
        <td align="center" style="border-top:#000000 solid 1px;">Director, HRD</td>
		<td>&nbsp;</td>		
		<td align="center" style="border-top:#000000 solid 1px;">Internal Auditor</td>
		<td>&nbsp;</td>
        <td align="center" style="border-top:#000000 solid 1px;">President</td>
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