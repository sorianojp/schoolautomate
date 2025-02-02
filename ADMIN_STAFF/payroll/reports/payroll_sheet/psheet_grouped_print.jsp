<%@ page language="java" 
	import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.ReportPayroll,
																 payroll.PReDTRME, payroll.OvertimeMgmt" %>
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
	boolean bolIsPerTeam = false;
	if(WI.fillTextValue("print_per_team").length() > 0)
		bolIsPerTeam = true;

	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
	ReportPayroll RptPayroll = new ReportPayroll(request);
	OvertimeMgmt otMgmt = new OvertimeMgmt();
	String strPayrollPeriod  = null;	
	String strHourlyRate = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dDailyRate = 0d;
	
	int iFieldCount = 75;// number of fields in the vector..
	int iNumRec = 0; 
	
	double dTemp = 0d;
 	double dLineTotal = 0d;
	boolean bolPageBreak = false;
	boolean bolMoveNextPage = false;
	int i = 0;
	int iIndex = 0;	  
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	Vector vRetResult = null;
	int iIncr = 1;
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;
	int iDeptCol = 2;
	
	if(WI.fillTextValue("show_emp_id").length() > 0)
		iDeptCol++;

	if(WI.fillTextValue("show_monthly").length() > 0)
		iDeptCol++;
	
	if(WI.fillTextValue("show_per_hour").length() > 0)
		iDeptCol+=2;
 	
 	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;

	Vector vOTDetail = null;
	Vector vSalDetail = null;

	Vector vOTTypes = null;
	Vector vAdjTypes = null;
	Vector vEmpOT = null;
	Vector vEmpAdjust = null;
	Vector vContributions = null;
	boolean bolShowBorder = (WI.fillTextValue("show_border")).length() > 0;bolShowBorder = true;
	String strBorder = "";
	String strBorderRight = "";
	

	double dOtherEarn = 0d;
	boolean bolNextDept = true;
	String strSalaryBase = null; 
	
	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
 	
	double dDaysWorked = 0d;
	double dOtherDed = 0d;
	double dDeptLateUT = 0d;
	double dDeptAbsence = 0d;
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
	
	
	///updated added for NEU due to group added for college/dept.. they will print only 3 groups, College - HS - Elem.
	//if group is selected, i have to show page total instead of dept total, because report is printed per group (college-hs-elem)
	boolean bolIsColDeptNEU = false;
	if(WI.fillTextValue("neu_col_dept_group_index").length() > 0) 
		bolIsColDeptNEU = true;
	//System.out.println(WI.fillTextValue("neu_col_dept_group_index"));
	
		
	boolean bolOfficeTotal = false;
 	vRetResult = RptPSheet.getPSheetItems(dbOP);
 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	  if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
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
	
	boolean bolShowTeachOverload = false;
	if(!WI.fillTextValue("employee_category").equals("0") && bolIsSchool)
		bolShowTeachOverload = true;
	if(strSchCode.startsWith("UB") || strSchCode.startsWith("DLSHSI"))
		bolShowTeachOverload = true;
		
	if(!bolShowTeachOverload) {
		if(vRows != null && vRows.size() > 0) {
			for(int a = 0; a < vRows.size(); a += iFieldCount){
				strTemp = (String)vRows.elementAt(a + 21);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				if(dTemp > 0d) {
					bolShowTeachOverload = true;
					break;
				}
			}
		}
	}




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
/*
	Oh my Gulay. Lisuda i trace ani nga page oi! hahaha tagam Dec. 21, 2010 - harvey (on Vacation Mode)
*/
%>
<body onLoad="javascript:window.print();"> 
<form name="form_" 	method="post" action="psheet_grouped.jsp">
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" align="left" class="thinborderBOTTOM"><strong><%=WI.fillTextValue("report_title")%> FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%>
          <%if(WI.fillTextValue("team_index").length() > 0){%>
          <br>
TEAM : <%=WI.fillTextValue("team_name")%>
<%}%>
      </strong></td>
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
      <td width="13%" rowspan="2" align="center" <%=strBorderRight%>>ID</td> 
			<%}%>
      <td width="13%" height="33" rowspan="2" align="center" <%=strBorderRight%>>NAME 
          OF EMPLOYEE </td>
			<%if(WI.fillTextValue("show_monthly").length() > 0){%>	
			<td width="4%" rowspan="2" align="center" <%=strBorderRight%>><span class="thinborderBOTTOM">&nbsp;BASIC SALARY </span></td>
			<%}%>
			<!--
      <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">BASIC</td>
			-->
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%>>BASIC PAY </td>
			<%if(WI.fillTextValue("show_per_hour").length() > 0){%>
			<td width="4%" rowspan="2" align="center" <%=strBorderRight%>>RATE PER DAY </td>			
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%>>RATE PER HOUR</td>
			<%}%>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%>>Late/UT/ Absence</td>
      <!--
			<td width="4%" rowspan="2" align="center" <%=strBorderRight%>>Absence</td>
			-->
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%>>Leave w/ pay</td>
      <%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			for(iOT = 0; iOT < vAdjTypes.size(); iOT+=19){
				if(!((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;			
				strTemp = (String)vAdjTypes.elementAt(iOT+1);
				if(!strSchCode.startsWith("TAMIYA"))
					strTemp += "<br>"+ CommonUtil.formatFloat((String)vAdjTypes.elementAt(iOT+3),false);
			%>      
			<td rowspan="2" align="center" <%=strBorderRight%>><%=strTemp%>*</td>			
			<%}
			}%>	
      <%
				if(bolShowBorder)
					strTemp =  "class='headerWithBorder'";
				else
					strTemp = "class='header'";
			%>					
      <td width="4%" colspan="2" align="center" <%=strTemp%>>NET 
          BASIC </td>
			<%
			if(vOTTypes != null && vOTTypes.size() > 0){
			for(iOT = 0; iOT < vOTTypes.size(); iOT+=19){
				strTemp = (String)vOTTypes.elementAt(iOT+1);
				if(!strSchCode.startsWith("TAMIYA"))
					strTemp += "<br>"+ CommonUtil.formatFloat((String)vOTTypes.elementAt(iOT+3),false);
			%>      
			<td rowspan="2" align="center" <%=strBorderRight%>><%=strTemp%></td>			
			<%}
			}%>
			<%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			for(iOT = 0; iOT < vAdjTypes.size(); iOT+=19){
				if(((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;			
				strTemp = (String)vAdjTypes.elementAt(iOT+1);
				if(!strSchCode.startsWith("TAMIYA"))
					strTemp += "<br>"+ CommonUtil.formatFloat((String)vAdjTypes.elementAt(iOT+3),false);
			%>      
			<td rowspan="2" align="center" <%=strBorderRight%>><%=strTemp%>*</td>			
			<%}
			}%>			
			<%if(!bolIsSchool){%>
			<td  width="3%" rowspan="2" align="center" <%=strBorderRight%>>NP</td>
			<%}%>
			<%if(bolShowTeachOverload){%>
      <td width="4%" colspan="2" align="center" <%=strBorderRight%>>OVERLOAD</td>
			<%}%>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
      <td rowspan="2" align="center" <%=strBorderRight%>><%=(String)vEarnCols.elementAt(iCols)%></td>			
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td rowspan="2" align="center" <%=strBorderRight%>><%=(String)vEarnDedCols.elementAt(iCols)%></td>
			<%}%>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%>>OTHER INC. </td>
      <td width="5%" rowspan="2" align="center" <%=strBorderRight%>>TOTAL GROSS PAY</td>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%>>TAX</td>
			<%if(astrContributions[0].equals("1")){%>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%>>SSS</td>
			<%}if(astrContributions[1].equals("1")){%>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%>>PHIC.</td>
			<%}if(astrContributions[2].equals("1")){%>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%>>HDMF</td>
			<%}if(astrContributions[4].equals("1")){%>
      <td width="4%" rowspan="2" align="center" <%=strBorderRight%>>PERAA</td>
			<%}%>
      <%			
			for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>
      <td rowspan="2" align="center" <%=strBorderRight%>><%=strTemp%></td>
			<%}%>
      <td width="5%" rowspan="2" align="center" <%=strBorderRight%>>OTHER DED.</td>
      <%
				if(bolShowBorder)
					strTemp =  "class='headerWithBorderRight'";
				else
					strTemp = "class='header'";
			%>
      <td width="5%" rowspan="2" align="center" <%=strTemp%>>NET PAY</td>
    </tr>
    <tr> 
      <td width="4%" height="33" align="center" <%=strBorderRight%>>Hours worked </td>
      <td width="4%" align="center" <%=strBorderRight%>>AMT</td>
			<%if(bolShowTeachOverload){%>
      <td width="4%" align="center" <%=strBorderRight%>>Rate</td>
      <td width="4%" align="center" <%=strBorderRight%>>Amount </td>
			<%}%>
    </tr>
    <% 
		for(; iNumRec < vRows.size();){ // DEPT FOR LOOP
		%>
    <%
 		if(bolNextDept || bolMoveNextPage){
			if(bolNextDept || bolIsColDeptNEU){
				// after adding to the grand total... zero out the department totals
				dDeptLateUT = 0d;	  
				dDeptAbsence = 0d;
				dDeptBasic = 0d;
				dDeptNP = 0d;
		
				// dDeptOT = 0d;
				for(iCols = 0;iCols < iOTType; iCols++){
					adDeptTotalOT[iCols] = 0d;	
				}
				
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
	  //dept count can't be more than 1 if GROUP NEU is being printed.. 
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
		<%
			if(bolIsPerTeam)
				strTemp = "Team : ";
			else if(bolIsSchool)
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
	  if(WI.fillTextValue("show_emp_id").length() > 0){
				strTemp = (String)vRows.elementAt(i + 60);
			%>	
			<td valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp)%></td> 
			<%}%>
      <td height="22" valign="bottom" <%=strBorder%>><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong></td>
      <%if(WI.fillTextValue("show_monthly").length() > 0){
	  	//monthly rate
			strTemp = (String)vRows.elementAt(i + 70);
			strTemp = WI.getStrValue(strTemp, "0");
 			if(strTemp.equals("0"))
				strTemp = "&nbsp;";			
			%>				
			<td align="right" valign="bottom"<%=strBorder%>><%=strTemp%></td>
			<%}%>
      <%
				// period rate
				dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));

				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
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
			}%>
      <%
				// hours worked
				strTemp = (String)vRows.elementAt(i + 8);  	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
				strTemp = CommonUtil.formatFloat(dTemp,false);
							
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			<%
			dDeptBasic += dLineTotal;
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
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
				strTemp = CommonUtil.formatFloat(dTemp,true);
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>			
			<%}
			}%>
			
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
			if(bolIsSchool)
				dOtherEarn += dTemp;
			else{%>
			<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			<%}%>
      <%if(bolShowTeachOverload){%>
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
				strTemp = "&nbsp;";
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
		
	  //	System.out.println("COLA " + strTemp);
		dLineTotal += dOtherEarn;
		dDeptOthEarn += dOtherEarn;
		strTemp = CommonUtil.formatFloat(dOtherEarn,2);
		if(dOtherEarn == 0d)
			strTemp = "&nbsp;";
	  %>			
			<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			<%
	  			strTemp = (String)RptPayroll.getSalaryInfoByPeriod(dbOP, WI ).get("gross_salary");
				dDeptGross += Double.parseDouble(strTemp.replaceAll(",",""));
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(strTemp,true)%></td>
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
				strTemp = (String)vRows.elementAt(i + 40);			
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
				strTemp = (String)vRows.elementAt(i +41);	
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
				strTemp = (String)vRows.elementAt(i +43);	
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
				strTemp = (String)vRows.elementAt(i+52);
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dDeptNet += dTemp;
 				if(bolShowBorder)
					strBorderRight = "class='thinborderBOTTOMLEFTRIGHT'";
				else
					strBorderRight = "class='NoBorder'";
			%>				
      <td align="right" valign="bottom" <%=strBorderRight%>><%=CommonUtil.formatFloat(dTemp,true)%></td>
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

//added additional CODE to handle bolIsColDeptNEU
if(bolIsColDeptNEU && (iCount + 1) > iMaxRecPerPage){
		bolOfficeTotal = true;
		bolNextDept = true;
}

//System.out.println(bolPageBreak);		
//System.out.println(bolOfficeTotal);		
//System.out.println("bolIsColDeptNEU: "+bolIsColDeptNEU);		
%>
	 
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
      <td height="22" colspan="<%=iDeptCol%>" valign="bottom" <%=strBorder%>><%if(bolIsColDeptNEU || bolIsPerTeam){%>Page<%}else{%>Dept<%}%> Total </td>
      <!--
			<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptLateUT,true)%></td>
			-->
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptAbsence,true)%></td>
      <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
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
       <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptBasic,true)%></td>
      <% for(iCols = 0;iCols < iOTType; iCols++){%>
			<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adDeptTotalOT[iCols] ,true)%></td>			
			<%}%>
      <%
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
      <%if(bolShowTeachOverload){%>
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
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandAbsence,true)%></td>
      <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
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
       <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandBasic,true)%></td>
			<% for(iCols = 0;iCols < iOTType; iCols++){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adTotalOT[iCols] ,true)%></td>			
			<%}%>
      <%
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
			<%if(bolShowTeachOverload){%>
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