<%@ 
	page language="java" 
	import="utility.*, java.util.Vector, payroll.PRTaxStatus"
	import ="payroll.PayrollSheet, eDTR.ReportEDTRExtn, payroll.ReportPayroll" 
	import = "payroll.PReDTRME, payroll.OvertimeMgmt, eDTR.OverTime" 
	buffer="16kb"
%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;

WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary by Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
	}	
	
	TD.headerWithBorderRight {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }
	
	TD.headerWithBorder {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }
	
  TD.header {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }

  TD.headerNoBorder {
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }
		
  TD.thinborderTOP {
    border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }
	
  TD.NoBorder {
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }	
	
  TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }
	
  TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }	
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<%

	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	String[] astrTaxStat   = {"N","S","H","M"};	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheet","psheet_grouped.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");

		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");		
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
														"psheet_grouped.jsp");
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	OverTime overtime = new OverTime();
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
	ReportPayroll RptPay = new ReportPayroll(request);
	ReportEDTRExtn RE = new ReportEDTRExtn(request);
	PRTaxStatus prTaxStat = new PRTaxStatus();
	OvertimeMgmt otMgmt = new OvertimeMgmt();
	String strPayrollPeriod  = null;	
	String strHourlyRate = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dDailyRate = 0d;
	
	int iFieldCount = 75;// number of fields in the vector..
	int iNumRec = 0; 
	
	double dTemp = 0d;
 	double dLineTotal = 0d;
	double dNightDiffDeptAmtTotal = 0d;
	double dNightDiffAmtGrandTotal = 0d;
	double dNightDiffHrGrandTotal = 0d;
	double dNightDiffDeptHrTotal = 0d;
	
	double dDeptOTTotal = 0d;
	double dGrandOTTotal = 0d;
	
	boolean bolPageBreak = false;
	boolean bolMoveNextPage = false;
	int i = 0;
	int iIndex = 0;	  
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	Vector vRetResult = null;
	Vector vTaxStat = null;
	
	int iIncr = 1;
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;
	int iDeptCol = 0;
	
	if(WI.fillTextValue("show_emp_id").length() > 0)
		iDeptCol+=2;

	//if(WI.fillTextValue("show_monthly").length() > 0)
		//iDeptCol+=1;
	
	if(WI.fillTextValue("show_tax_stat").length() > 0)
		iDeptCol+=2;
	
	if(WI.fillTextValue("show_per_hour").length() > 0)
		iDeptCol+=2;
 	
	if(WI.fillTextValue("show_tax_stat").length() > 0 && WI.fillTextValue("show_emp_id").length() > 0 )
		iDeptCol -=1;
	 
 	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;

	Vector vOTDetail = null;
	Vector vSalDetail = null;
	
	Vector vNightDiff = null;	
	Vector vPSheetItems = null;
	Vector vSalaryInfo = null;
	Vector vDifferentialDetails = null;

	Vector vOTTypes = null;
	Vector vAdjTypes = null;
	Vector vEmpOT = null;
	Vector vEmpAdjust = null;
	Vector vContributions = null;
	boolean bolShowBorder = (WI.fillTextValue("show_border")).length() > 0;
	String strBorder = "";
	String strBorderRight = "";
	
	//>sul..start of additional variables
	Vector vOTType = null;//this is for ot grouping.note, there is also vOTTypes not for grouping
	Vector vOTGroupName = overtime.operateOnOvertimeGrouping(dbOP,request,4);//group names
	Vector vOTGroup = overtime.operateOnOTGroupTypeMapping(dbOP,request,4);
	Vector vOTNoGroup = overtime.operateOnOTGroupTypeMapping(dbOP,request,5);	
	Vector vOTGroupList = new Vector(); //holds the index and amount of ot w/ group  ->[type_index][amount][type_index][amount]
	Vector vOTNoGroupList = new Vector();//holds the index and amount of ot w/o group->[type_index][amount][type_index][amount]
	Vector vTemp = null;
	
	int iIndexOf = -1;
	int iOTCounter = 0;
	if(vOTGroupName != null && vOTGroupName.size() > 0)
			iOTCounter = vOTGroupName.size()/3;
	if(vOTNoGroup != null && vOTNoGroup.size() > 0)
			iOTCounter += vOTNoGroup.size()/3;		
	
	int iSize = 1;
	if(vOTGroupName != null && vOTGroupName.size() > 0)
		iSize = vOTGroupName.size()/3;	
	double []arrDGroupTotal = new double[iSize];
	double []arrDGroupGrandTotal = new double[iSize];	
	
	iSize = 1;		
	if(vOTNoGroup != null && vOTNoGroup.size() > 0)
		iSize = vOTNoGroup.size()/3;	
		
	double []arrDNoGroupTotal = new double[iSize];
	double []arrDNoGroupGrandTotal = new double[iSize];	
	//<sul..end of additional variables		

	double dOtherEarn = 0d;
	boolean bolNextDept = true;
	String strSalaryBase = null; 
	
	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
	String strCutOff = null;
	
 	double dTotalOTAmount = 0d;
	double dDaysWorked = 0d;
	double dOtherDed = 0d;
	double dDeptLateUT = 0d;
	double dDeptAbsence = 0d;
	int 	iDeptNoEmp = 0;
	double dDeptBasicSal = 0d;
	double dDeptBasic = 0d;
	double dDeptOT = 0d;
	double dDeptNP = 0d;
	double dDeptOverload = 0d;
	double dDeptOthEarn = 0d;
	double dDeptGross = 0d;
	double dDeptSSS = 0d;
	double dDeptMed = 0d;
	double dDeptTax = 0d;
	double dDeptPagibig = 0d;
	double dDeptPeraa = 0d;
	double dDeptOthDed = 0d;
	double dDeptNet = 0d;

	double dGrandLateUT = 0d;
	double dGrandAbsence = 0d;
	double dGrandBasicSal = 0d;
	double dGrandBasic = 0d;
	double dGrandOT = 0d;
	double dGrandNP = 0d;	
	double dGrandOverload = 0d;
	double dGrandOthEarn = 0d;
	double dGrandGross = 0d;
	double dGrandSSS = 0d;
	double dGrandMed = 0d;
	double dGrandTax = 0d;
	double dGrandPagibig = 0d;
	double dGrandPeraa = 0d;
	double dGrandOthDed = 0d;
	double dGrandNet = 0d;
	
	
		
	boolean bolOfficeTotal = false;
 	vRetResult = RptPSheet.getPSheetItems(dbOP);
 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	  if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		strCutOff =  (String)vSalaryPeriod.elementAt(i + 1) +" - "+(String)vSalaryPeriod.elementAt(i + 2);
		break;
	  }
	}
	// System.out.println("--------------------------------------");
	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iDeptCount = 0; int iOT = 0;
	int iOTType = 0;
	int iAdjType = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
 	vRows = (Vector)vRetResult.elementAt(0);
	vEarnCols = (Vector)vRetResult.elementAt(1);
	vDedCols = (Vector)vRetResult.elementAt(2);		
	vEarnDedCols = (Vector)vRetResult.elementAt(3);	
		if(WI.fillTextValue("hide_overtime").equals("1"))
			vOTTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, true);			
		else
			vOTTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "1");
		
		if(WI.fillTextValue("hide_adjustment").equals("1"))
			vAdjTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, false);
		else
			vAdjTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "0");	
		//System.out.println("vAdjTypes " + vAdjTypes);
		vContributions = RptPSheet.checkPSheetContributions(dbOP, request, WI.fillTextValue("sal_period_index"));
		
	if(vRows != null){
	int iTotalPages = (vRows.size())/(iFieldCount*iMaxRecPerPage);	
 
	if(vEarnCols != null && vEarnCols.size() > 0)
		iEarnColCount = vEarnCols.size() - 2;
	 
	if(vDedCols != null && vDedCols.size() > 0)
		iDedColCount = vDedCols.size() - 1;		
	 
	if (vEarnDedCols != null && vEarnDedCols.size() > 0)
		iEarnDedCount = vEarnDedCols.size() - 1;	
	
	if (vOTTypes != null && vOTTypes.size() > 0)
		iOTType = vOTTypes.size()/19;	
	
	if (vAdjTypes != null && vAdjTypes.size() > 0)
		iAdjType = vAdjTypes.size()/19;		
	
	double[] adDeptEarningTotal = new double[iEarnColCount];
	double[] adDeptDeductTotal = new double[iDedColCount];
	double[] adDeptEarnDedTotal = new double[iEarnDedCount];	
	double[] adDeptTotalOT = new double[iOTType];	
	double[] adDeptTotalAdj = new double[iAdjType];	
 
 	double[] adEarningTotal = new double[iEarnColCount];
	double[] adDeductTotal = new double[iDedColCount];
	double[] adEarnDedTotal = new double[iEarnDedCount];
	double[] adTotalOT = new double[iOTType];	
	double[] adTotalAdj = new double[iAdjType];		
	String[] astrContributions = {"1", "1", "1", "1", "1"};
	
	
	/////////////////// start of OT names \\\\\\\\\\\\\\\\\\\	
				if(vOTGroupName != null && vOTGroupName.size() > 0){					
					vTemp = new Vector();
					//print the group name					
					for(int iCols2 = 0;iCols2 < vOTGroupName.size(); iCols2+=3){						
						//save the ot_type_index
						vTemp = overtime.getOTTypeIndexInTheGroup(dbOP,request,(String)vOTGroupName.elementAt(iCols2));
						if(vTemp != null && vTemp.size() > 0){
							vOTGroupList.addElement(vTemp);
							vOTGroupList.addElement("0");
						}						
					}//end of for loop	 
							
				}//end of if there is group%>
				
				<%				
				if(vOTNoGroup != null && vOTNoGroup.size() > 0){
					//print the ot w/o group
					for(int iCols2 = 0;iCols2 < vOTNoGroup.size(); iCols2+=3){
						//save the ot_type_index						
						vOTNoGroupList.addElement((String)vOTNoGroup.elementAt(iCols2));
						vOTNoGroupList.addElement("0");						
					}//end of for loop
				}//end of if nogroup
				
				///////////////////// end of OT names \\\\\\\\\\\\\\\\\\\\\\\\
	
	
	
	// 0 = sss_amt
	// 1 = philhealth_amt
	// 2 = pag_ibig
	// 3 = gsis_ps
  // 4 = peraa
	if(WI.fillTextValue("hide_contributions").equals("1")){
		for(i = 0; i < vContributions.size(); i++)
			astrContributions[i] = (String)vContributions.elementAt(i);
	}	
	
	if((vRows.size() % (iFieldCount * iMaxRecPerPage)) > 0)
		 ++iTotalPages;

				
	 for (;iNumRec < vRows.size();iPage++){ // OUTERMOST FOR LOOP
	 	dTemp = 0d;
		dLineTotal = 0d;

		/*
		dGrandLateUT = 0d;
		dGrandBasic = 0d;
		dGrandOT = 0d;
		dGrandOthEarn = 0d;
		dGrandGross = 0d;
		dGrandSSS = 0d;
		dGrandMed = 0d;
		dGrandTax = 0d;
		dGrandPagibig = 0d;
		dGrandOthDed = 0d;
		dGrandNet = 0d;		
		// reset the page total 
		for(iCols = 2;iCols < iEarnColCount + 2; iCols++){
			adEarningTotal[iCols-2] = 0d;	
		}
		 				 
		for(iCols = 1;iCols < iDedColCount + 1; iCols++){
		 adDeductTotal[iCols-1] = 0d;
		}
		
		for(iCols = 1;iCols < iEarnDedCount + 1; iCols++){
		 adEarnDedTotal[iCols-1] = 0d;
		}
		*/
%>
<body onLoad="javascript:window.print();"> 
<form name="form_" 	method="post" action="psheet_grouped.jsp">
 
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">  
    <tr> 
      <td height="24" align="left"><strong><%=WI.fillTextValue("report_title")%> FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%> <%=WI.getStrValue(strCutOff, "Cut Off : ","","")%></td>
          <%if(WI.fillTextValue("team_index").length() > 0){%>
          <br>
		TEAM : <%=WI.fillTextValue("team_name")%>
			<%}%>
      	</td>	
		<td height="19"  align="right">&nbsp;Date and time printed : <%=WI.getTodaysDateTime()%></td>	
    </tr>	
	</table>
	
	
		<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <%
				if(bolShowBorder)
					strBorderRight =  "class='headerWithBorder'";
				else
					strBorderRight = "class='header'";
			%>
			<%if(WI.fillTextValue("show_emp_id").length() > 0){%>			
      <td width="13%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">ID</td> 
			<%}%>
      <td width="13%" height="33" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">NAME 
          OF EMPLOYEE 
      </td>
	  <%if(WI.fillTextValue("show_tax_stat").length() > 0){%>
	  	<td width="5%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">TAX STATUS </td>
	  <%}%>	
	  <%if(WI.fillTextValue("show_monthly").length() > 0){%>	
		<td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;"><span class="thinborderBOTTOM">&nbsp;BASIC SALARY </span></td>
	  <%}%>
			<!--
      <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">BASIC</td>
			-->
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">BASIC PAY </td>
			<%if(WI.fillTextValue("show_per_hour").length() > 0){%>
			<td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">RATE PER DAY </td>			
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">RATE PER HOUR</td>
			<%}%>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">Late/UT/ Absence</td>
      <!--
		<td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">Absence</td>
		-->
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">Leave w/ pay</td>
	  <!-- 20130705 -->
	  <td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">Night <br>Diff.<br>(hours)</td>
	  <td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">Night <br>Diff.<br>(Amount).</td>
	  <!-- end 20130705 -->
	  <td width="4%" align="center" colspan="<%=iOTCounter%>" <%=strBorderRight%> style="border-top:solid 1px #000000;">OVERTIME<br></td>
	  
      <%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			for(iOT = 0; iOT < vAdjTypes.size(); iOT+=19){
				if(!((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;			
				strTemp = (String)vAdjTypes.elementAt(iOT+1);
				if(!strSchCode.startsWith("TAMIYA"))
					strTemp += "<br>"+ CommonUtil.formatFloat((String)vAdjTypes.elementAt(iOT+3),false);
			%>      
			<td rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;"><%=strTemp%>*</td>			
			<%}
			}%>	
      <%
				if(bolShowBorder)
					strTemp =  "class='headerWithBorder'";
				else
					strTemp = "class='header'";
			%>				
     
			<%
			if(vOTTypes != null && vOTTypes.size() > 0){
					
					for(iOT = 0; iOT < vOTTypes.size(); iOT+=19){
						strTemp = (String)vOTTypes.elementAt(iOT+1);
						if(!strSchCode.startsWith("TAMIYA"))
							strTemp += "<br>"+ CommonUtil.formatFloat((String)vOTTypes.elementAt(iOT+3),false);
						%>      
					<!-- <td rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;"><%=strTemp%></td> -->			
					<%}//end of loop
				
			}//end of if has vOTTypes
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			for(iOT = 0; iOT < vAdjTypes.size(); iOT+=19){
				if(((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;			
				strTemp = (String)vAdjTypes.elementAt(iOT+1);
				if(!strSchCode.startsWith("TAMIYA"))
					strTemp += "<br>"+ CommonUtil.formatFloat((String)vAdjTypes.elementAt(iOT+3),false);
			%>      
			<td rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;"><%=strTemp%>*</td>			
			<%}
			}%>			
			<%if(!bolIsSchool){%>
			<td  width="3%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">NP</td>
			<%}%>
			<%if(WI.fillTextValue("employee_category").equals("1")){%>
      <td width="4%" colspan="2" align="center" class="headerNoBorder" style="border-top:solid 1px #000000;">OVERLOAD</td>
			<%}%>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
      <td rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;"><%=(String)vEarnCols.elementAt(iCols)%></td>			
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;"><%=(String)vEarnDedCols.elementAt(iCols)%></td>
			<%}%>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">OTHER INC. </td>
      <td width="5%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">TOTAL GROSS PAY</td>
	  <td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">TAX</td>
			<%if(astrContributions[0].equals("1")){%>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">SSS</td>
			<%}if(astrContributions[1].equals("1")){%>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">PHIC.</td>
			<%}if(astrContributions[2].equals("1")){%>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">HDMF</td>
			<%}if(astrContributions[4].equals("1")){%>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">PERAA</td>
			<%}%>
      <%			
			for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>
      <td rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;"><%=strTemp%></td>
			<%}%>
      <td width="5%" rowspan="2" align="center" <%=strBorderRight%> style="border-top:solid 1px #000000;">OTHER DED.</td>
      <%
				if(bolShowBorder)
					strTemp =  "class='headerWithBorderRight'";
				else
					strTemp = "class='header'";
			%>
      <td width="5%" rowspan="2" align="center" <%=strTemp%> style="border-top:solid 1px #000000;">NET PAY</td>
    </tr>
    <tr>      
			<%if(WI.fillTextValue("employee_category").equals("1")){%>
      <td width="4%" align="center" <%=strBorderRight%>>Rate</td>
      <td width="4%" align="center" <%=strBorderRight%>>Amount </td>
			<%}%>
			
	 	<%
			/////////////////// start of OT names \\\\\\\\\\\\\\\\\\\	
				if(vOTGroupName != null && vOTGroupName.size() > 0){					
					vTemp = new Vector();
					//print the group name					
					for(int iCols3 = 0;iCols3 < vOTGroupName.size(); iCols3+=3){%>
						<td align="center" class="thinborderBOTTOM" style="border-left:solid 1px #000000;" >&nbsp;<%=(String)vOTGroupName.elementAt(iCols3+1)%></td>
					<%}//end of for loop
				}//end of if there is group%>
				
				<%				
				if(vOTNoGroup != null && vOTNoGroup.size() > 0){
					//print the ot w/o group
					for(int iCols3 = 0;iCols3 < vOTNoGroup.size(); iCols3+=3){	%>
						<td align="center" class="thinborderBOTTOM" style="border-left:solid 1px #000000;">&nbsp;<%=(String)vOTNoGroup.elementAt(iCols3+1)%></td>
					<%}//end of for loop
				}//end of if nogroup
				
				///////////////////// end of OT names \\\\\\\\\\\\\\\\\\\\\\\\		
			
			%>					
			
			
    </tr>
    <% 
		for(; iNumRec < vRows.size();){ // DEPT FOR LOOP
				////////////////////////// start of initialixing ot toatal \\\\\\\\\\
				if(vOTGroupList != null && vOTGroupList.size() > 0){				
						for(int iCtr = 0, iCtr2 = 0 ; iCtr < vOTGroupList.size(); iCtr+=2, iCtr2++){					
							//arrDGroupGrandTotal[iCtr2] += arrDGroupTotal[iCtr2]; 
							arrDGroupTotal[iCtr2] = 0d; 					
						}	
				}	
				
				if(vOTNoGroupList != null && vOTNoGroupList.size() > 0){				
						for(int iCtr = 0, iCtr2 = 0 ; iCtr < vOTNoGroupList.size(); iCtr+=2, iCtr2++){					
							arrDNoGroupGrandTotal[iCtr2] += arrDNoGroupTotal[iCtr2]; 
							arrDNoGroupTotal[iCtr2] = 0d;
						}	
				}
				//////////////////// end of initializing total \\\\\\\\\\\\\\\\
			
		
		%>
    <%
 		if(bolNextDept || bolMoveNextPage){
			if(bolNextDept){
				// after adding to the grand total... zero out the department totals
				dDeptLateUT = 0d;	  
				dDeptAbsence = 0d;
				iDeptNoEmp = 0;
				dDeptBasicSal = 0d;
				dDeptBasic = 0d;
				dDeptNP = 0d;
				dNightDiffDeptHrTotal = 0d;
				dNightDiffDeptAmtTotal = 0d;
				dDeptOTTotal = 0d;
				// dDeptOT = 0d;
				for(iCols = 0;iCols < iOTType; iCols++){
					adDeptTotalOT[iCols] = 0d;	
				}
				
				//for(iCols=0;iCols<vOTGroupList.size();iCols++){
					//arrDGroupTotal[iCols] = 0d;
				//}
				
				for(iCols = 0;iCols < iAdjType; iCols++){
					adDeptTotalAdj[iCols] = 0d;	
				}
				
				dDeptOverload = 0d;
				for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
					adDeptEarningTotal[iCols-2] = 0d;	
				}
			
				for(iCols = 1;iCols < iEarnDedCount + 1; iCols++){
					adDeptEarnDedTotal[iCols-1] = 0d;
				}		
				dDeptOthEarn = 0d;
				dNightDiffDeptAmtTotal = 0d;
				dNightDiffDeptHrTotal = 0d;
				dDeptGross = 0d;
				dDeptTax = 0d;
				dDeptSSS = 0d;
				dDeptMed = 0d;
				dDeptPagibig = 0d;
				dDeptPeraa = 0d;
				dDeptOthDed = 0d;
				for(iCols = 1;iCols < iDedColCount + 1; iCols++){
					adDeptDeductTotal[iCols-1] = 0d;
				}
		
				dDeptNet = 0d;			
			}		
		
	  bolNextDept = false;	
		
		if(iDeptCount == 3){
			iDeptCount = 0;
			iCount++;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				bolMoveNextPage = true;
				continue;
			}
			else 
				bolPageBreak = false;			
		}else
			iDeptCount++;
    %>
		<%if(bolIsSchool)
				strTemp = "College : ";
			else
				strTemp = "Division : ";
				
			strTemp2 = (String)vRows.elementAt(iNumRec+63);
			strTemp2 = WI.getStrValue(strTemp2," Dept : ","","");
		%>		
    <tr>
      <%				
				if(bolShowBorder)
					strBorderRight = "class='thinborderBOTTOMLEFTRIGHT'";
				else
					strBorderRight = "class='NoBorder'";
			%>		
      <td height="19" colspan="54" valign="bottom" <%=strBorderRight%>><strong><%=(WI.getStrValue((String)vRows.elementAt(iNumRec+62),strTemp,strTemp2,strTemp2)).toUpperCase()%></strong></td>
    </tr>
		<%}// bolNextDept || bolMoveNextPage)%>
 
  <%for(; iNumRec < vRows.size();){// employee for loop
	i = iNumRec;	
	vOTType = (Vector)vRows.elementAt(i+65);	
	if(i+iFieldCount+1 < vRows.size()){
 		if(i == 0){
			strCurColl = WI.getStrValue((String)vRows.elementAt(i+2),"0");		
			strCurDept = WI.getStrValue((String)vRows.elementAt(i+3),"");	
		}
		strNextColl = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 2),"0");		
		strNextDept = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 3),"");		
			
 		if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
 			bolNextDept = true;
			bolOfficeTotal = true;
 		}
	}
  vEarnings = (Vector)vRows.elementAt(i+53);
	vDeductions = (Vector)vRows.elementAt(i+54);
	vSalDetail = (Vector)vRows.elementAt(i+55); 
	vOTDetail = (Vector)vRows.elementAt(i+56);
	vEarnDed  = (Vector)vRows.elementAt(i+59);
	vEmpOT = (Vector)vRows.elementAt(i+65);
			
	vEmpAdjust = (Vector)vRows.elementAt(i+67);
	dLineTotal = 0d;
	
	dDaysWorked = 0d;
 	dOtherEarn = 0d;
	dOtherDed = 0d;
	dTotalOTAmount = 0d;
	iCount++;
	if (iCount > iMaxRecPerPage){
		bolPageBreak = true;
 		break;
	}
	else 
		bolPageBreak = false; 
 		%>	
    <tr>
      <%
				if(bolShowBorder)
					strBorder =  "class='thinborder'";
				else
					strBorder = "class='NoBorder'";
			%>		

      <%
	  
	  strTemp = (String)vRows.elementAt(i + 60);
	  request.setAttribute("emp_id", strTemp);
	  
	  vPSheetItems = RptPSheet.getPSheetItems(dbOP, request, WI.fillTextValue("sal_period_index"));
	  vNightDiff = RE.generateNightDifferentialReport(dbOP);
	  vSalaryInfo = RptPay.getSalaryInfo(dbOP, false);
	  vTaxStat  = prTaxStat.operateOnTaxStatus(dbOP, request,4);
	  if(WI.fillTextValue("show_emp_id").length() > 0){				
			%>	
			<td valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp)%></td> 
			<%}%>
      <td height="22" valign="bottom" <%=strBorder%>><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong>
	  </td>
	  <%
				// tax status
				//do something
				strTemp = "&nbsp;";
				if( vTaxStat != null && vTaxStat.size() > 0 ){
					strTemp = (String)vTaxStat.elementAt(1);
					if( strTemp != null ){
						strTemp = strTemp.substring(0,1);		
						strTemp = astrTaxStat[Integer.parseInt(strTemp)];				
					}else
						strTemp = "&nbsp;";
				}
				
		%>
       <%if(WI.fillTextValue("show_tax_stat").length() > 0){%>
	  	<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%> &nbsp;</td>
	   <%}%>  
	  <%if(WI.fillTextValue("show_monthly").length() > 0){
	  		//monthly rate
			// 
			strTemp = (String)vRows.elementAt(i + 70);
			strTemp = WI.getStrValue(strTemp, "0");
			dDeptBasicSal += Double.parseDouble(strTemp.replaceAll(",",""));
 			if(strTemp.equals("0"))
				strTemp = "&nbsp;";			
			%>				
			<td align="right" valign="bottom"<%=strBorder%>><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%}%>
      <%
				// period rate
				dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));

				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
				dDeptBasic += dLineTotal;
				iDeptNoEmp += 1;
			%>			
      <td align="right" valign="bottom"<%=strBorder%>><%=CommonUtil.formatFloat(dLineTotal,true)%></td>      
      <%
	  	//rate per hour
				strHourlyRate = "";
				dDailyRate = 0d;
				if(vSalDetail != null && vSalDetail.size() > 0){
					strHourlyRate = (String)vSalDetail.elementAt(5); 			
					dDailyRate = Double.parseDouble((String)vSalDetail.elementAt(2));
				}			
			if(WI.fillTextValue("show_per_hour").length() > 0){%>
			<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDailyRate, false)%></td>
      <td align="right" valign="bottom" <%=strBorder%>><%=strHourlyRate%></td>
			<%}%>
 			<%			
			dTemp = 0d;
			// late_under_amt
			strTemp = (String)vRows.elementAt(i + 48); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

			//strTemp = CommonUtil.formatFloat(dTemp,true);

			//dLineTotal -= dTemp;
			//dDeptLateUT += dTemp;
			//if(dTemp == 0d)
			//	strTemp = "&nbsp;";
			%>
      <!--
			<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			-->
			<%			
			//dTemp = 0d;

			// faculty absences
			strTemp = (String)vRows.elementAt(i + 49); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");		
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
			
			// leave_deduction_amt
			strTemp = (String)vRows.elementAt(i + 33); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
	
			// AWOL // i dont know if theres an awol anyway
			strTemp = (String)vRows.elementAt(i + 47); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

			strTemp = CommonUtil.formatFloat(dTemp,true);

			dLineTotal -= dTemp;
			dDeptAbsence += dTemp;
			if(dTemp == 0d)
				strTemp = "&nbsp;";
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			<%			
			dTemp = 0d;
			// leaves with pay
			strTemp = WI.getStrValue((String)vRows.elementAt(i + 11));
			if(WI.fillTextValue("show_leave_amount").equals("1")){
				strTemp2 = (String)vRows.elementAt(i + 71);
				strTemp2 = CommonUtil.formatFloat(strTemp2, true);
				strTemp2 = ConversionTable.replaceString(strTemp2, ",","");
				if(Double.parseDouble(strTemp2) > 0d)				
					strTemp = strTemp2;
				else
					strTemp = CommonUtil.formatFloat((Double.parseDouble(strTemp) * dDailyRate), true);
			}else
				strTemp = CommonUtil.formatFloat(strTemp, false);
				
			if(strTemp.equals("0") || strTemp.equals("0.00"))
				strTemp = "&nbsp;";			
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
	  <!-- 20130705 -->
	  <%
				// Number of hours night differential
				strTemp = null;
				dTemp = 0d;
				//if(vOTDetail != null && vOTDetail.size() > 0){
					//strTemp = (String)vOTDetail.elementAt(4);
					//dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
					//dNightDiffDeptHrTotal += dTemp;	
					//dNightDiffHrGrandTotal += dNightDiffDeptHrTotal;	
				//}
				if(vNightDiff != null){
					vDifferentialDetails = (Vector) vNightDiff.elementAt(6);
					if( vDifferentialDetails != null ){
						dTemp = Double.parseDouble((String)vDifferentialDetails.elementAt(0)) + Double.parseDouble((String)vDifferentialDetails.elementAt(2));
						dNightDiffDeptHrTotal += dTemp;	
						dNightDiffHrGrandTotal += dTemp;
						strTemp = dTemp+"";
					}
				}
				//else if(vOTDetail != null && vOTDetail.size() > 0){
					//strTemp = (String)vOTDetail.elementAt(4);
					//dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
					//dNightDiffDeptHrTotal += dTemp;	
					//dNightDiffHrGrandTotal += dNightDiffDeptHrTotal;	
				//}
				if(dTemp == 0d)
					strTemp = "--";
			%>  
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%
				// night differential amount
				//strTemp = (String)vRows.elementAt(i + 24);  	
				//dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
				//dNightDiffDeptAmtTotal += dTemp;
				//dNightDiffAmtGrandTotal += dNightDiffDeptAmtTotal;
				dTemp = 0d;
				if(vNightDiff != null ){
					vDifferentialDetails = (Vector) vNightDiff.elementAt(6);
					if( vDifferentialDetails != null ){
						dTemp = Double.parseDouble((String)vDifferentialDetails.elementAt(1)) + Double.parseDouble((String)vDifferentialDetails.elementAt(3));	
						dNightDiffDeptAmtTotal += dTemp;
						dNightDiffAmtGrandTotal += dTemp;
						strTemp = dTemp+"";
					}
				}//else{
						//strTemp = (String)vRows.elementAt(i + 24);  	
						//dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
						//dNightDiffDeptAmtTotal += dTemp;
						//dNightDiffAmtGrandTotal += dNightDiffDeptAmtTotal;
				//}
				
				if(dTemp == 0d)
					strTemp = "--";
			%>      
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%>&nbsp;</td>
	  <!-- end 20130705 -->	 
	  
	  
      <%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			 for(iOT = 0, iCols = 0;iOT < vAdjTypes.size(); iOT+=19, iCols++){
				if(!((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;
				 strTemp = null;
				 iIndex = vEmpAdjust.indexOf((Integer)vAdjTypes.elementAt(iOT));
				 if(iIndex != -1){
					 strTemp = (String)vEmpAdjust.elementAt(iIndex+2);					 
				 }

				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
				adDeptTotalAdj[iCols] = adDeptTotalAdj[iCols] + dTemp;
 				strTemp = CommonUtil.formatFloat(dTemp,true);
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>			
			<%}
			}
	 
		/////////////////////// OT GROUP value \\\\\\\\\\\\\\\\\\\\\\\\			
		if(vOTGroupList != null && vOTGroupList.size() > 0){				
					for(int iCtr = 0; iCtr < vOTGroupList.size(); iCtr+=2){
						vOTGroupList.setElementAt("0",iCtr + 1);//initialize all values to zero -GROUP									
					}	
		}	
		
		if(vOTNoGroupList != null && vOTNoGroupList.size() > 0){				
				for(int iCtr = 0; iCtr < vOTNoGroupList.size(); iCtr+=2){
					vOTNoGroupList.setElementAt("0",iCtr + 1);//initialize all values to zero - NO GROUP
				}	
		}
		
		if(vOTType != null && vOTType.size() > 0){			
			
			for(int iCols2 = 0;iCols2 < vOTType.size(); iCols2 +=3){		
				dTemp = 0;	
				iIndexOf = -1;
				strTemp = WI.getStrValue((vOTType.elementAt(iCols2).toString()),"0");
				//check if ot is in the group			
				if(vOTGroupList != null && vOTGroupList.size() > 0){				
					for(int iCtr = 0 ; iCtr < vOTGroupList.size(); iCtr+=2){
						vTemp = (Vector)vOTGroupList.elementAt(iCtr);
						iIndexOf = vTemp.indexOf(strTemp);					
						if(iIndexOf != -1){
							dTemp = Double.parseDouble((String)vOTGroupList.elementAt(iCtr + 1));//current amount of ot in the group
							dTemp += Double.parseDouble(WI.getStrValue((String)vOTType.elementAt(iCols2+2),"0"));						
							vOTGroupList.setElementAt(CommonUtil.formatFloat(dTemp,2),iCtr + 1);
							break;
						}
					}//end of for loop w/ group
				}
				
				//System.out.println("----vOTNoGroupList: " + vOTNoGroupList);			
				//check if ot is not in the group
				if(vOTNoGroupList != null && vOTNoGroupList.size() > 0){				
					iIndexOf = vOTNoGroupList.indexOf(strTemp);
					if(iIndexOf != -1){
						vOTNoGroupList.setElementAt((String)vOTType.elementAt(iCols2+2),iIndexOf + 1);
					}
				}		
			}//end of for loop	
		}//end of OT List			
		
		//overtime
		if(vOTGroupList != null && vOTGroupList.size() > 0){
			for(int iCols2 = 0, iCols3 = 0;iCols2 < vOTGroupList.size(); iCols2+=2, iCols3++){
				//dTemp = Double.parseDouble(WI.getStrValue((String)vOTGroupList.elementAt(iCols2+1),"0"));
				//for the total
				//arrDGroupTotal[iCols3] += dTemp;
				strTemp = (String)vPSheetItems.elementAt(7);
				dTemp = Double.parseDouble(strTemp);
				dDeptOTTotal += dTemp;
				dGrandOTTotal += dTemp;
						
				if(dTemp > 0d){
					//dTemp = Double.parseDouble((String)vRows.elementAt(i+23));
					//arrDGroupTotal[iCols3] += dTemp;
					//arrDGroupGrandTotal[iCols3] += dTemp;//arrDGroupTotal[iCols3];
					strTemp = CommonUtil.formatFloat(dTemp+"",true);
				}else
					strTemp = "&nbsp;";
				%>
				<!-- overtime td -->
				<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>				
			  <%}//end of for loop
		}//end of if group		
		
		
		if(vOTNoGroupList != null && vOTNoGroupList.size() > 0){		  	  
			 for(int iCols2 = 0, iCols3 = 0 ;iCols2 < vOTNoGroupList.size(); iCols2 +=2, iCols3++){	
				dTemp = Double.parseDouble(WI.getStrValue((String)vOTNoGroupList.elementAt(iCols2+1),"0"));
				//for the total
				arrDNoGroupTotal[iCols3] += dTemp;
				if(dTemp > 0d)
					strTemp = "" + dTemp;		
				else
					strTemp = "&nbsp;"; 	
				%>
				 <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			 <%}//end of for loop
		}//end of no group
		
		////////////////////// end of OT group value \\\\\\\\\\\\\\\\\\\\\\
			
					// hours worked
				strTemp = (String)vRows.elementAt(i + 8);  	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
				strTemp = CommonUtil.formatFloat(dTemp,false);
							
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>
      <!--<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td> -->
			<%
			//dDeptBasic += dLineTotal;			
			%>
     <!-- <td align="right" valign="bottom" <%=strBorder%>>tt<%=CommonUtil.formatFloat(dLineTotal,true)%></td>-->
      <%
			// OVERTIME amount
			//strTemp = (String)vRows.elementAt(i + 23);  	
			//dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			//dLineTotal += dTemp;
			//dDeptOT += dTemp;
			//strTemp = CommonUtil.formatFloat(dTemp,true);

			//if(dTemp == 0d)
			//	strTemp = "";
			%>   
			<%
			if(vOTTypes != null && vOTTypes.size() > 0){
			 for(iOT = 0, iCols = 0;iOT < vOTTypes.size(); iOT+=19, iCols++){
				 strTemp = null;
				 iIndex = vEmpOT.indexOf((Integer)vOTTypes.elementAt(iOT));
				 if(iIndex != -1){
					 strTemp = (String)vEmpOT.elementAt(iIndex+2);					 
				 }

				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
				adDeptTotalOT[iCols] = adDeptTotalOT[iCols] + dTemp;
				dLineTotal += dTemp;
				dTotalOTAmount += dTemp;
				strTemp = CommonUtil.formatFloat(dTemp,true);
				if(dTemp == 0d)
					strTemp = "&nbsp;";	
					%>  
      			<%
			}//end of for loop
					
				strTemp = CommonUtil.formatFloat(dTotalOTAmount,true);
				if(dTotalOTAmount == 0d)
						strTemp = "&nbsp;"; %>												
				<%								
			} //end of OTWithTypes %>			
			<%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			 for(iOT = 0, iCols = 0;iOT < vAdjTypes.size(); iOT+=19, iCols++){
				if(((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;
				 strTemp = null;
				 iIndex = vEmpAdjust.indexOf((Integer)vAdjTypes.elementAt(iOT));
				 if(iIndex != -1){
					 strTemp = (String)vEmpAdjust.elementAt(iIndex+2);					 
				 }

				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
				adDeptTotalAdj[iCols] = adDeptTotalAdj[iCols] + dTemp;
				dLineTotal += dTemp;
				strTemp = CommonUtil.formatFloat(dTemp,true);
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>			
			<%}
			}%>
			<%
			// Night Differential
			strTemp = (String)vRows.elementAt(i + 24);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
			if(dTemp == 0d)
				strTemp = "&nbsp;";							
			dLineTotal += dTemp;
			dDeptNP += dTemp;
			// night diff is not included to other inc.
			if(bolIsSchool)
				dOtherEarn += 0d;
			else{%>
			<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			<%}%>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
      <%
	  	//overload rate per hour
				strTemp = "";
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp = (String)vSalDetail.elementAt(3);
  	  %>
			<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
	 		<%
			// overload
			strTemp = (String)vRows.elementAt(i + 22);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			dDeptOverload += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%> 		
			<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			<%}%>
		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			adDeptEarningTotal[iCols-2] = adDeptEarningTotal[iCols-2] + dTemp;
			dLineTotal += dTemp;
			if(dTemp == 0d)
				strTemp = "";			
		%>          
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				adDeptEarnDedTotal[iCols-1] = adDeptEarnDedTotal[iCols-1] + dTemp;
				dLineTotal -= dTemp;
				if(strTemp.equals("0"))
					strTemp = "";			
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"")%></td>
			<%}%>			
		<%try{%>	
      <%		
			
			if(vEarnings != null){
				// subject allowances 
				strTemp = (String)vEarnings.elementAt(0); 
				if (strTemp.length() > 0){
					dOtherEarn += Double.parseDouble(strTemp);
				}
				// ungrouped earnings.
				strTemp = (String)vEarnings.elementAt(1); 
				if (strTemp.length() > 0){
					dOtherEarn += Double.parseDouble(strTemp);
				}				
			}			
			
		// adjustment amount
		// add only the adjustment to other earnings if walay adjustment type
	  if ((vAdjTypes == null || vAdjTypes.size() == 0) 
				&&  vRows.elementAt(i+51) != null){
			strTemp = (String)vRows.elementAt(i+51); 
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
			//System.out.println("Adjust " + strTemp);
		}
		
		// holiday_pay_amt
		if (vRows.elementAt(i+26) != null){	
			strTemp = (String)vRows.elementAt(i+26); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
			//System.out.println("HPA " + strTemp);
		}
		
				// addl_payment_amt 
		if (vRows.elementAt(i+27) != null){	
			strTemp = (String)vRows.elementAt(i+27); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
		//	System.out.println("apa " + strTemp);
		}

		// Adhoc Allowances
		if (vRows.elementAt(i+28) != null){	
			strTemp = (String)vRows.elementAt(i+28); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
			//System.out.println("AA " + strTemp);
		}

		// addl_resp_amt
		if (vRows.elementAt(i+29) != null){	
			strTemp = (String)vRows.elementAt(i+29); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
			//System.out.println("ARA " + strTemp);
		}
		
		// substitute salary
		if (vRows.elementAt(i+38) != null){	
			strTemp = (String)vRows.elementAt(i+38); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
			//System.out.println("SS " + strTemp);
		}						
		
		// COLA
		strTemp = (String)vRows.elementAt(i + 25);  	
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
		dOtherEarn += dTemp;
		
		dLineTotal += dOtherEarn;
		dDeptOthEarn += dOtherEarn;
		strTemp = CommonUtil.formatFloat(dOtherEarn,2);
		if(dOtherEarn == 0d)
			strTemp = "&nbsp;";
	  %>			
	  		<!-- other inc. -->
			<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			<%
				// overwrite gross 
				// select direct to db
				if( vSalaryInfo != null ){
					strTemp = (vSalaryInfo.elementAt(5)+"").replaceAll(",", "");
					strTemp = CommonUtil.formatFloat(Double.parseDouble(strTemp), true);
				}else
					strTemp = CommonUtil.formatFloat(dLineTotal, true);
					
				dDeptGross += Double.parseDouble(strTemp.replaceAll(",",""));
			%>
			<!-- total gross pay -->
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
	   <%
				// tax withheld
				strTemp = (String)vRows.elementAt(i + 46);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				dDeptTax += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
      <%
				if(astrContributions[0].equals("1")){
				// sss contribution
				strTemp = (String)vRows.elementAt(i + 39);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);														
				dLineTotal -= dTemp;
				dDeptSSS += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>   		
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			<%}%>
      <%
				if(astrContributions[1].equals("1")){
				
				// philhealth
				strTemp = vRows.elementAt(i + 40)+"";			
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				dDeptMed += dTemp;
				
				if(dTemp == 0d)
					strTemp = "--";
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>     
			<%}%>
      <%
				if(astrContributions[2].equals("1")){
				// pag ibig
				strTemp = vRows.elementAt(i +41)+"";	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				dDeptPagibig += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			<%}%>
			<%
				if(astrContributions[4].equals("1")){
				// peraa
				strTemp = vRows.elementAt(i +43)+"";	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				dDeptPeraa += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			<%}%>			
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols ++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				adDeptDeductTotal[iCols-1] = adDeptDeductTotal[iCols-1] + dTemp;
				dLineTotal -= dTemp;
				if(dTemp == 0d)
					strTemp = "";			
			%>  			
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%}%>
      <%
			// this is the other ungrouped deductions
			strTemp = (String)vDeductions.elementAt(0);
			dTemp = Double.parseDouble(strTemp);
			dOtherDed += dTemp;
			
			// misc_deduction
			strTemp = (String)vRows.elementAt(i + 45); 
			strTemp = WI.getStrValue(strTemp,"0");
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dOtherDed += Double.parseDouble(strTemp);				

			dLineTotal -= dOtherDed;
			strTemp = CommonUtil.formatFloat(dOtherDed,true);
			dDeptOthDed += dOtherDed;
			if(dOtherDed == 0d)
				strTemp = "";
	  %>				
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			//dDeptNet += dLineTotal;
				/**dTemp = 0d;
				
				if(vOTGroupList != null && vOTGroupList.size() > 0){
					for(iCols = 0;iCols < vOTGroupList.size(); iCols +=2)
						dTemp = Double.parseDouble(WI.getStrValue((String)vOTGroupList.elementAt(iCols+1),"0"));
				}//end of if group
				strTemp = (String)vRows.elementAt(i+52);
				if( dTemp == 0d && Double.parseDouble((String)vRows.elementAt(i+23)) > 0d ){
					dTemp = Double.parseDouble((String)vRows.elementAt(i+23));
					strTemp = (Double.parseDouble(strTemp)-dTemp)+"";
				}**/
				//Copied from main sheet.. not sure why the above code was not changed.. updated Sept: 29, 2013.
				dTemp = 0d;
				if(vOTGroupList != null && vOTGroupList.size() > 0){
					for(iCols = 0;iCols < vOTGroupList.size(); iCols +=2)
						dTemp = Double.parseDouble(WI.getStrValue((String)vOTGroupList.elementAt(iCols+1),"0"));
				}//end of if group
				
				if( vSalaryInfo != null ){
					strTemp = ((String)vSalaryInfo.elementAt(6)).replaceAll(",", "");
					strTemp = CommonUtil.formatFloat(Double.parseDouble(strTemp), true);
				}
				else{
					strTemp = (String)vRows.elementAt(i+52);
					if( dTemp == 0d && Double.parseDouble((String)vRows.elementAt(i+23)) > 0d )
						strTemp = (Double.parseDouble(strTemp)-dTemp)+"";
				}
				
			
				//strTemp = (String)vRows.elementAt(i+52);
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dDeptNet += dTemp;
 				if(bolShowBorder)
					strBorderRight = "class='thinborderBOTTOMLEFTRIGHT'";
				else
					strBorderRight = "class='NoBorder'";
			%>				
      <td align="right" valign="bottom" <%=strBorderRight%>><%=CommonUtil.formatFloat(dTemp,true)%></td>
    <%}catch(Exception e){ System.out.println("****"); e.printStackTrace(); }%>
	</tr>
  <% 
 	 iNumRec+=iFieldCount;
	 iIncr++;
	 if(iNumRec < vRows.size()){
		 strCurColl = WI.getStrValue((String)vRows.elementAt(iNumRec+2),"0");
		 strCurDept = WI.getStrValue((String)vRows.elementAt(iNumRec+3),"");
	 }	 

 	if(bolNextDept){
		bolOfficeTotal = true;
		break;
	}

  %>
     <%}//end employee for loop%>  
  <%  
  if(bolOfficeTotal || (!bolOfficeTotal && iNumRec >= vRows.size())){
  	bolOfficeTotal = false;
	iCount++;

	if (iCount > iMaxRecPerPage)
		bolPageBreak = true;
	else
		bolPageBreak = false;
  %>	    
		<tr>
      <%
				if(bolShowBorder)
					strBorder =  "class='thinborder'";
				else
					strBorder = "class='NoBorder'";
	  %>
      <td height="22" colspan="<%=iDeptCol%>" valign="bottom" <%=strBorder%>>Dept Total |<font size="1">Emp. Per Cost Center: </font><strong><%=iDeptNoEmp%></strong></td>
	  <!--<td height="22" align="left" valign="bottom" <%=strBorder%>>&nbsp;<font size="1">Emp. Per Cost Center: </font><strong><%=iDeptNoEmp%>&nbsp;&nbsp;&nbsp;</strong></td>-->
	  <%if(WI.fillTextValue("show_monthly").length() > 0){%>
	  	<td height="22" align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptBasicSal,true)%></td>
	  <%}%> 
	  <!-- dept basic pay/salary total 2013070717 -->	  
	  <td height="22" align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptBasic,true)%></td>
	  <!-- end 20130717 -->
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptAbsence,true)%></td>
      <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
		<!-- 20130705 -->
		<td width="4%" valign="bottom" align="right" <%=strBorder%> ><%=dNightDiffDeptHrTotal%>&nbsp;</td>
		<td width="4%" valign="bottom" align="right" <%=strBorder%> ><%=CommonUtil.formatFloat(dNightDiffDeptAmtTotal,true)%>&nbsp;</td>
		<!-- end 20130705 -->	
      <%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			 for(iOT = 0, iCols = 0;iOT < vAdjTypes.size(); iOT+=19, iCols++){
				if(!((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;
 				strTemp = CommonUtil.formatFloat(adDeptTotalAdj[iCols] ,true);
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
							
			<%}
			}%>
        
      <%
	  //ot types
		/////////////////// start of OT total \\\\\\\\\\\\\\\\\\\	
		if(vOTGroupList != null && vOTGroupList.size() > 0){			
			//print the group name					
			for(int iCols2 = 0, iCols3 = 0;iCols2 < vOTGroupList.size(); iCols2+=2,iCols3++){
			%>		
				<!-- overtime dept total-->
				<!-- <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(arrDGroupTotal[iCols3],true)%>&nbsp;</td> -->
				<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptOTTotal,true)%>&nbsp;</td>
			<%}//end of for loop	 
					
		}//end of if there is group%>
		
		<%				
		if(vOTNoGroupList != null && vOTNoGroupList.size() > 0){
			//print the ot w/o group
			for(int iCols2 = 0, iCols3 = 0;iCols2 < vOTNoGroupList.size(); iCols2+=2, iCols3++){
			%>
		  <td align="right" valign="bottom" <%=strBorder%>><%=arrDNoGroupTotal[iCols3]%>&nbsp;</td>
			<%}//end of for loop
		}//end of if nogroup
		
		///////////////////// end of OT total \\\\\\\\\\\\\\\\\\\\\\\\			
			
		//end of ot types	
			
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			 for(iOT = 0, iCols = 0;iOT < vAdjTypes.size(); iOT+=19, iCols++){
				if(((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;
 				strTemp = CommonUtil.formatFloat(adDeptTotalAdj[iCols] ,true);
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>			
			<%}
			}%>	
			<%if(!bolIsSchool){%>
		  <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptNP,true)%></td>
			<%}%>
			
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
			<td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptOverload,true)%></td>
			<%}%>			
			<% for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adDeptEarningTotal[iCols-2],true)%></td>
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adDeptEarnDedTotal[iCols-1],true)%></td>
			<%}%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptOthEarn,true)%></td>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptGross,true)%></td>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptTax,true)%></td>
      <%if(astrContributions[0].equals("1")){%>
			<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptSSS,true)%></td>
			<%}if(astrContributions[1].equals("1")){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptMed,true)%></td>
			<%}if(astrContributions[2].equals("1")){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptPagibig,true)%></td>
			<%}if(astrContributions[4].equals("1")){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptPeraa,true)%></td>
			<%}%>
			
			<% for(iCols = 1;iCols < (iDedColCount)/2+1; iCols ++){ %>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adDeptDeductTotal[iCols-1],true)%></td>
			<%}%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptOthDed,true)%></td>
      <td align="right" valign="bottom" <%=strBorderRight%>><%=CommonUtil.formatFloat(dDeptNet,true)%></td>
    </tr>
    <% 
		dGrandLateUT += dDeptLateUT;
		dGrandAbsence += dDeptAbsence;
		dGrandBasicSal += dDeptBasicSal;
 		dGrandBasic += dDeptBasic;		
		dGrandNP += dDeptNP;
 		//dGrandOT += dDeptOT;
		for(iCols = 0;iCols < iOTType; iCols++){
			adTotalOT[iCols] += adDeptTotalOT[iCols];
		}		

		for(iCols = 0;iCols < iAdjType; iCols++){
			adTotalAdj[iCols] += adDeptTotalAdj[iCols];
		}		
		
		dGrandOverload += dDeptOverload;
	
		for(iCols = 2;iCols < iEarnColCount + 2; iCols++){
			adEarningTotal[iCols-2] += adDeptEarningTotal[iCols-2];
		}
		 				 
		for(iCols = 1;iCols < iDedColCount + 1; iCols++){
			adDeductTotal[iCols-1] += adDeptDeductTotal[iCols-1];
		}
 		dGrandOthEarn += dDeptOthEarn;
		dGrandGross += dDeptGross;
		dGrandTax += dDeptTax;
		dGrandSSS += dDeptSSS;
		dGrandMed += dDeptMed;
		dGrandPagibig += dDeptPagibig;
		dGrandPeraa += dDeptPeraa;

		for(iCols = 1;iCols < iEarnDedCount + 1; iCols++){
			adEarnDedTotal[iCols-1] += adDeptEarnDedTotal[iCols-1];			
		}
	
		dGrandOthDed += dDeptOthDed;
		dGrandNet += dDeptNet;
		}// if(bolOfficeTotal || (!bolOfficeTotal && iNumRec >= vRows.size()))
		%>
	<%if(iNumRec >= vRows.size()){%>		
    <tr>
      <td height="30" colspan="<%=iDeptCol%>" valign="bottom" <%=strBorder%>>Grand Total </td>
      <!--
			<td align="right" valign="bottom" class="NoBorder"><%=CommonUtil.formatFloat(dGrandLateUT,true)%></td>
			-->
			
	  <!-- grand total basic/salary 20130717 -->
	  <%if(WI.fillTextValue("show_monthly").length() > 0){%>
	  	<td height="22" align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandBasicSal,true)%></td>
	  <%}%>
	  	<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandBasic,true)%></td>
	  <!-- end 20130717 -->
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandAbsence,true)%></td>
      <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
		<!-- 20130705 -->
		<td width="4%" align="right" valign="bottom" <%=strBorder%>><%=dNightDiffHrGrandTotal%>&nbsp;</td>
		<td width="4%" align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dNightDiffAmtGrandTotal,true)%>&nbsp;</td>
		<!-- end 20130705 -->      
      <%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			 for(iOT = 0, iCols = 0;iOT < vAdjTypes.size(); iOT+=19, iCols++){
				if(!((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;
 				strTemp = CommonUtil.formatFloat(adTotalAdj[iCols] ,true);
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			<%}
			}%>
      
			<% 					
			//grand ot types
			  /////////////////// start of OT total \\\\\\\\\\\\\\\\\\\	
		if(vOTGroupList != null && vOTGroupList.size() > 0){
			//print the group name					
			for(int iCols2 = 0, iCols3 = 0;iCols2 < vOTGroupList.size(); iCols2+=2,iCols3++){
			%>		
				 <!-- overtime garnd total -->
				 <!-- <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(arrDGroupGrandTotal[iCols3],true)%>&nbsp;</td> -->
				 <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandOTTotal,true)%>&nbsp;</td>
			<%}//end of for loop	 //overtime
					
		}//end of if there is group%>
		
		<%				
		if(vOTNoGroupList != null && vOTNoGroupList.size() > 0){
			//print the ot w/o group
			for(int iCols2 = 0, iCols3 = 0;iCols2 < vOTNoGroupList.size(); iCols2+=2,iCols3++){
			%>
				<td align="right" valign="bottom" <%=strBorder%>><%=arrDNoGroupGrandTotal[iCols3]%>&nbsp;</td>
			<%}//end of for loop
		}//end of if nogroup
		
		///////////////////// end of OT names \\\\\\\\\\\\\\\\\\\\\\\\			
			  
			  
			//end of grand ot types
			     
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			 for(iOT = 0, iCols = 0;iOT < vAdjTypes.size(); iOT+=19, iCols++){
				if(((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;
 				strTemp = CommonUtil.formatFloat(adTotalAdj[iCols] ,true);
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>			
			<%}
			}%>		
			<%if(!bolIsSchool){%>
			<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandNP,true)%></td>
			<%}%>
			
			
			<%if(WI.fillTextValue("employee_category").equals("1")){%>
      <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandOverload,true)%></td>	  
			<%}%>
			<% for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adEarningTotal[iCols-2],true)%></td>
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adEarnDedTotal[iCols-1],true)%></td>
			<%}%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandOthEarn,true)%></td>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandGross,true)%></td>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandTax,true)%></td>
      <%if(astrContributions[0].equals("1")){%>
			<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandSSS,true)%></td>
			<%}if(astrContributions[1].equals("1")){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandMed,true)%></td>
			<%}if(astrContributions[2].equals("1")){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandPagibig,true)%></td>
			<%}if(astrContributions[4].equals("1")){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandPeraa,true)%></td>
			<%}%>			
			<% for(iCols = 1;iCols <= (iDedColCount/2); iCols ++){ %>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adDeductTotal[iCols-1],true)%></td>
			<%}%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandOthDed,true)%></td>
      <td align="right" valign="bottom" <%=strBorderRight%>><%=CommonUtil.formatFloat(dGrandNet,true)%></td>
    </tr>
	<%}/// bolPageBreak || iNumRec >= vRows.size()%>
	<%
		if(bolPageBreak){
			iCount = 0;
			break;
		}
	 }// end DEPT FOR LOOP %>		
  </table>  
	<%if(iNumRec >= vRows.size()){%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td>Prepared By: </td>
      <td>&nbsp;</td>
      <td>Reviewed by: </td>
      <td height="25">&nbsp;</td>
      <td height="25">Noted by: </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td align="center" valign="bottom"><%=WI.fillTextValue("prepared_by")%></td>
      <td>&nbsp;</td>
      <td align="center" valign="bottom"><%=WI.fillTextValue("reviewed_by")%></td>
      <td height="25">&nbsp;</td>
      <td height="25" align="center" valign="bottom"><%=WI.fillTextValue("noted_by")%></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="24%">&nbsp;</td>
      <td width="5%">&nbsp;</td>
      <td width="27%">&nbsp;</td>
      <td width="5%" height="25">&nbsp;</td>
      <td width="26%" height="25">&nbsp;</td>
      <td width="7%">&nbsp;</td>
    </tr>
  </table>
	<%}%>
	
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always">&nbsp;</Div>
  <%}//page break ony if it is not last page.
   } //end for (iNumRec < vRetResult.size() // END OUTERMOST FOR LOOP
  }// end if vRows != null;
 } //end end upper most if (vRetResult !=null)%>  
	<input type="hidden" name="is_grouped" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>