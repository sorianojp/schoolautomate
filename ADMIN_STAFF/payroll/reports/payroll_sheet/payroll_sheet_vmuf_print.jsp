<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, 
																 payroll.PReDTRME, payroll.OvertimeMgmt" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;

WebInterface WI = new WebInterface(request);
String strHeaderSize = WI.getStrValue(WI.fillTextValue("header_size"), "12");
String strDetailSize = WI.getStrValue(WI.fillTextValue("detail_size"), "12");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary by Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD.NoBorder {
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=strDetailSize%>px;
  }
		
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=strDetailSize%>px;
	}	
	
  TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=strDetailSize%>px;
  }
  
	TD.thinborderTOP {
    border-top: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=strDetailSize%>px;
  }
		
  TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=strDetailSize%>px;
  }
	
	TD.headerBOTTOM {
    border-bottom: solid 1px #000000;    
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=strHeaderSize%>px;
  }

	TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=strHeaderSize%>px;
  }
  
	TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
		border-right: solid 1px #000000;    
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=strHeaderSize%>px;
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
	OvertimeMgmt otMgmt = new OvertimeMgmt();
	String strPayrollPeriod  = null;	
	String strHourlyRate = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dDailyRate = 0d;
	String strEmployerIndex = WI.fillTextValue("employer_index");
	Vector vEmployerInfo = null;
	vEmployerInfo = new payroll.PRRemittance(request).operateOnEmployerProfile(dbOP, 3, strEmployerIndex);
	if (vEmployerInfo == null || vEmployerInfo.size() == 0) {
		strErrMsg = "Employer profile not found";
	}
	
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
	int iColCounter = 0;
 	
 	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;

	Vector vOTDetail = null;
	Vector vSalDetail = null;

	Vector vOTTypes = null;
//	Vector vAdjTypes = null;
	Vector vEmpOT = null;
//	Vector vEmpAdjust = null;
	Vector vContributions = null;
	boolean bolShowBorder = (WI.fillTextValue("show_border")).length() > 0;
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
	double dDeptCola = 0d;
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
	double dDeptExtra = 0d;
	double dDeptTotalDed = 0d;
	double dDeptAdjust = 0d;
	
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
	double dGrandExtra = 0d;
	double dGrandTotalDed = 0d;
	double dGrandAdjust = 0d;
	
	double dTempOthers = 0d;
	double dBasic = 0d;
	double dEmpDeduct = 0d;
	
	double dPageGross = 0d;
	double dPageSSS = 0d;
	double dPageTax = 0d;
	double dPageHdmf = 0d;
	double dPageAdv = 0d;
	double dPageTotDed = 0d;
	double dPageAbsence = 0d;
	double dPageNet = 0d;
	double dPageOthers = 0d;
	double dPageAdjust = 0d;

	boolean bolOfficeTotal = false;
	boolean bolShowSignatory = false;
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
	int iOT = 0;
	int iOTType = 0;
//	int iAdjType = 0;
	int iContCount = 0;
	
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
 	vRows = (Vector)vRetResult.elementAt(0);
	vEarnCols = (Vector)vRetResult.elementAt(1);
	vDedCols = (Vector)vRetResult.elementAt(2);		
	vEarnDedCols = (Vector)vRetResult.elementAt(3);	
		if(WI.fillTextValue("hide_overtime").equals("1"))
			vOTTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, true);			
		else
			vOTTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "1");
		
//		if(WI.fillTextValue("hide_adjustment").equals("1"))
//			vAdjTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, false);
//		else
//			vAdjTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "0");	
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
	
//	if (vAdjTypes != null && vAdjTypes.size() > 0)
//		iAdjType = vAdjTypes.size()/19;		
	
	double[] adPageEarningTotal = new double[iEarnColCount];
	double[] adPageDeduct = new double[iDedColCount];	
	double[] adPageEarnDedTotal = new double[iEarnDedCount];
	double[] adPageTotalOT = new double[iOTType];
//	double[] adPageTotalAdj = new double[iAdjType];
	
	double[] adDeptEarningTotal = new double[iEarnColCount];
	double[] adDeptDeductTotal = new double[iDedColCount];
	double[] adDeptEarnDedTotal = new double[iEarnDedCount];
	double[] adDeptTotalOT = new double[iOTType];
//	double[] adDeptTotalAdj = new double[iAdjType];
 
 	double[] adEarningTotal = new double[iEarnColCount];
	double[] adDeductTotal = new double[iDedColCount];
	double[] adEarnDedTotal = new double[iEarnDedCount];	
	double[] adTotalOT = new double[iOTType];	
//	double[] adTotalAdj = new double[iAdjType];		
	
	

	
	String[] astrContributions = {"1", "1", "1", "1", "1"};
	// 0 = sss_amt
	// 1 = philhealth_amt
	// 2 = pag_ibig
	// 3 = gsis_ps
  // 4 = peraa
	if(WI.fillTextValue("hide_contributions").equals("1") && vContributions != null){
		for(i = 0; i < vContributions.size(); i++){
			astrContributions[i] = (String)vContributions.elementAt(i);
			if(astrContributions[i].equals("1"))
				iContCount++;
		}
		
		if(astrContributions[0].equals("1") && astrContributions[1].equals("1"))
			iContCount--;
	}	else if(!WI.fillTextValue("hide_contributions").equals("1")){
			iContCount = 3;
	}
	
	if((vRows.size() % (iFieldCount * iMaxRecPerPage)) > 0)
		 ++iTotalPages;

	 for (;iNumRec < vRows.size();iPage++){ // OUTERMOST FOR LOOP
	 	dTemp = 0d;
		dLineTotal = 0d;

		dPageGross = 0d;
 		dPageSSS = 0d;
		dPageTax = 0d;
		dPageHdmf = 0d;
		for(iCols = 1;iCols < iDedColCount + 1; iCols++){
			adPageDeduct[iCols-1] = 0d;
		}
		
		for(iCols = 0;iCols < iOTType; iCols++){
			adPageTotalOT[iCols] = 0d;	
		}
		
//		for(iCols = 0;iCols < iAdjType; iCols++){
//			adPageTotalAdj[iCols] = 0d;	
//		}
		
 		for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			adPageEarningTotal[iCols-2] = 0d;	
		}
	
		for(iCols = 1;iCols < iEarnDedCount + 1; iCols++){
			adPageEarnDedTotal[iCols-1] = 0d;
		}				
		
		dPageAbsence = 0d;
		dPageAdv = 0d;
		dPageTotDed = 0d;
		dPageNet = 0d;
		dPageAdjust = 0d;
		dPageOthers = 0d;
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
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="center"><%if(vEmployerInfo != null){
					strTemp = (String) vEmployerInfo.elementAt(12);					
				%>
        <font size="2"><strong><%=strTemp%></strong></font>
				<%strTemp = "<br>" + (String) vEmployerInfo.elementAt(3) + "<br>";%>
				<%=strTemp%>				
        <%}else{%>
					<font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%></font>
      <%}%> </td>
  </tr>
</table>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
			<td height="24" colspan="<%= iEarnColCount + (iDedColCount/2) + iEarnDedCount + 17 + iOTType + iContCount%>" align="center" class="headerBOTTOM"><strong>PAYROLL 
      SHEET FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></strong></td>			
      <!--
			<td height="24" colspan="25" align="center" ><strong><font color="#0000FF"> <%=WI.fillTextValue("report_title")%> FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
			-->		
    </tr>
    <tr>
			
			<td colspan="<%=iEarnColCount + iEarnDedCount + 13 + iOTType%>" class="headerBOTTOMLEFT">&nbsp; </td>
			<td colspan="<%=(iDedColCount/2) + 3 + iContCount%>" align="center" class="headerBOTTOMLEFT"><strong>D E D U C T I O N S </strong></td>
			<td class="headerBOTTOMLEFTRIGHT">&nbsp;</td>
			<!--
      <td height="33" colspan="15" align="center" class="thinborderBOTTOM">&nbsp;</td>      
      <td colspan="9" align="center" class="thinborderBOTTOM"><span class="BOTTOMLEFT"><strong>D E D U C T I O N S</strong></span></td>
      <td align="center" class="thinborderBOTTOM">&nbsp;</td>
			-->		
    </tr>
    <tr>
      <td height="33" colspan="2" align="center" class="headerBOTTOMLEFT">&nbsp;</td>
      <td height="33" colspan="7" align="center" class="headerBOTTOMLEFT"><strong>PART TIME / EXTRA LOAD</font></td>

			
			<td colspan="<%=(iEarnColCount + iEarnDedCount + 4) + iOTType%>" class="headerBOTTOMLEFT">&nbsp;</td>
			<td colspan="<%=((iDedColCount/2) + 3 + iContCount)%>" class="headerBOTTOMLEFT">&nbsp;</td>
			<td class="headerBOTTOMLEFTRIGHT">&nbsp;</td>
			<!--
      <td colspan="6" align="center" class="thinborderBOTTOM">&nbsp;</td>
      <td colspan="9" align="center" class="thinborderBOTTOM">&nbsp;</td>
      <td align="center" class="thinborderBOTTOM">&nbsp;</td>
			-->			
    </tr>
    <tr>
      <%				
				if(bolShowBorder)
					strBorder =  "class='thinborder'";
				else
					strBorder = "class='thinborderBOTTOM'";
			%>		
      <td width="7%" height="33" align="center" <%=strBorder%>>NAME 
        OF EMPLOYEE </td>
      <%
				if(WI.fillTextValue("is_weekly").equals("1"))
					strTemp = "WEEKLY";
				else
					strTemp = "QUINCINA";
	
				if(bolShowBorder)
					strBorder =  "class='thinborder'";
				else
					strBorder = "class='thinborderBOTTOM'";
			%>					
      <td width="4%" align="center" <%=strBorder%>><%=strTemp%> SALARY</td>			
			<td width="4%" align="center" <%=strBorder%>>LEC. HOUR (inside)</td>
			<td width="4%" align="center" <%=strBorder%>>LAB. HOUR (inside)</td>
			<td width="4%" align="center" <%=strBorder%>>TOTAL HOURS</td>
			<td width="4%" align="center" <%=strBorder%>>LEC. HOUR (outside)</td>
			<td width="4%" align="center" <%=strBorder%>>LAB. HOUR (outside)</td>
			<td width="4%" align="center" <%=strBorder%>>TOTAL HOURS</td>
			<td width="4%" align="center" <%=strBorder%>>SUB TOTAL SALARY</td>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
			<td width="4%" align="center" <%=strBorder%>>&nbsp;<%=(String)vEarnCols.elementAt(iCols)%></td>
			<%}%>
      <%
			if(vOTTypes != null && vOTTypes.size() > 0){
			for(iOT = 0; iOT < vOTTypes.size(); iOT+=19){
				strTemp = (String)vOTTypes.elementAt(iOT+1);
			%>						
      <td width="4%" align="center" <%=strBorder%>><%=strTemp%></td>
			<%}
			}%>			
      <td width="4%" align="center" <%=strBorder%>>OTHERS</td>
      <td width="3%" align="center" <%=strBorder%>>ADJUST</td>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>			
      <td width="7%" align="center" <%=strBorder%>><%=(String)vEarnDedCols.elementAt(iCols)%></td>			
			<%}%>				
			<td width="5%" align="center" <%=strBorder%>>ABSENCES</td>
      <td width="5%" align="center" <%=strBorder%>>TOTAL GROSS PAY</td>
      <%if(astrContributions[0].equals("1") || astrContributions[1].equals("1")){%>
			<td width="4%" align="center" <%=strBorder%>>SSS 
      &amp; MED. </td>
      <%}if(astrContributions[2].equals("1")){%>
      <td width="4%" align="center" <%=strBorder%>>HDMF</td>
      <%}if(astrContributions[4].equals("1")){%>
			<td width="5%" align="center" <%=strBorder%>>PERAA</td>
      <%}%>
      <td width="5%" align="center" <%=strBorder%>>TAX</td>      
      
			<%			
			for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>
      <td align="center" <%=strBorder%>><%=strTemp%></td>
      <%}%>
      <td width="6%" align="center" <%=strBorder%>>ADVANCE 
      &amp; OTHER DED</td>
      <td width="6%" align="center" <%=strBorder%>>TOTAL 
      DEDUCT</td>
      <%				
				if(bolShowBorder)
					strBorder =  "class='headerBOTTOMLEFTRIGHT'";
				else
					strBorder = "class='thinborderBOTTOM'";
			%>			
      <td width="6%" align="center"<%=strBorder%>><span class="headerBOTTOMLEFT">NET 
      SALARY</span></td>
    </tr>
    <% 
		for(; iNumRec < vRows.size();){ // DEPT FOR LOOP
		%>
    <%
 		if(bolNextDept || bolMoveNextPage){
			if(bolNextDept){
				// after adding to the grand total... zero out the department totals
				dDeptLateUT = 0d;	  
				dDeptAbsence = 0d;
				dDeptBasic = 0d;
				dDeptNP = 0d;
				dDeptExtra = 0d;
				// dDeptOT = 0d;
				for(iCols = 0;iCols < iOTType; iCols++){
					adDeptTotalOT[iCols] = 0d;	
				}
				
				dDeptOverload = 0d;
				for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
					adDeptEarningTotal[iCols-2] = 0d;	
				}
			
				for(iCols = 1;iCols < iEarnDedCount + 1; iCols++){
					adDeptEarnDedTotal[iCols-1] = 0d;
				}		
				dDeptAdjust = 0d;
				
				dDeptTotalDed = 0d;				
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
		
			//iCount++;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				bolMoveNextPage = true;
				iCount = 0;
				break;
			}
			else 
				bolPageBreak = false;			
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
      <td height="19" colspan="<%= iEarnColCount + (iDedColCount/2) + iEarnDedCount + 20 + iOTType%>" valign="bottom" <%=strBorderRight%>><strong><%=(WI.getStrValue((String)vRows.elementAt(iNumRec+62),strTemp,strTemp2,strTemp2)).toUpperCase()%></strong></td>
    </tr>
		<%}// bolNextDept || bolMoveNextPage)%>
 
  <%
 	for(; iNumRec < vRows.size();){// employee for loop
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
//	vEmpAdjust = (Vector)vRows.elementAt(i+67);
	dEmpDeduct = 0d;
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
      <td height="22" valign="bottom" nowrap <%=strBorder%>><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong></td>
			<%
	  	//monthly rate
			strTemp = (String)vRows.elementAt(i + 70);
			strTemp = WI.getStrValue(strTemp, "0");
 			if(strTemp.equals("0"))
				strTemp = "&nbsp;";
  	  %>					
      <%
				// period rate
				dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));
				// System.out.println("dLineTotal " + dLineTotal);
				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dLineTotal,true)%></td>			
			<!--// excess lec in -->
    <%
	  	dTemp = 0d;
		strTemp = (String) vRows.elementAt(i+15); 
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp == 0d)
			strTemp = "";
	  %>
			<td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<!--// excess lab in -->
      <%
	  	dTemp = 0d;
		strTemp = (String) vRows.elementAt(i+16); 
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp == 0d)
			strTemp = "";
	  %>					
			<td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
	  	// excess lecture hours inside office hours
	  	dTemp = 0d;
	  	if (vRows.elementAt(i+15) != null){	
			strTemp = (String) vRows.elementAt(i+15); 
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
		 // excess lab hours inside office hours
	  	if (vRows.elementAt(i+16) != null){
			strTemp = (String) vRows.elementAt(i+16); 			
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp)/2;
			}
		}
		strTemp = Double.toString(dTemp);
	  %>
			<!--total hours inside office hours-->
			<td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
	  	dTemp = 0d;
		strTemp = (String) vRows.elementAt(i+18); 
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp == 0d)
			strTemp = "";
	  %>	
			<!--Excess lec out-->
			<td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<!--Excess lab out-->
      <%
	  	dTemp = 0d;
		strTemp = (String) vRows.elementAt(i+19); 
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp == 0d)
			strTemp = "";
	  %>
			<td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
	  	dTemp = 0d;
	  	if (vRows.elementAt(i+18) != null){	
			strTemp = (String) vRows.elementAt(i+18); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
	  	if (vRows.elementAt(i+19) != null){
			strTemp = (String) vRows.elementAt(i+19); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp)/2;
			}
		}
		strTemp = Double.toString(dTemp);
	  %>
			<!--total Excess out-->			
			<td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
	  	dTemp = 0d;
		// faculty salary 
	  	if (vRows.elementAt(i+30) != null){	
			strTemp = (String) vRows.elementAt(i+30); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
		// overload_amt
		if (vRows.elementAt(i+22) != null){	
			strTemp = (String)vRows.elementAt(i+22); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp);
			}
		}
		dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
		dDeptExtra += dTemp;
		dLineTotal += dTemp;
	  %>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dTemp, true)%></td>
		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dTemp = CommonUtil.formatFloatToCurrency(dTemp, 2);
			adEarningTotal[iCols-2] = adEarningTotal[iCols-2] + dTemp;
			adDeptEarningTotal[iCols-2] = adDeptEarningTotal[iCols-2] + dTemp;
			adPageEarningTotal [iCols-2] = adPageEarningTotal [iCols-2] + dTemp;
			dLineTotal += dTemp;
			if(dTemp == 0d)
				strTemp = "&nbsp;";			
		%>               
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
		<%}%>
 			<%
			if(vOTTypes != null && vOTTypes.size() > 0){
			 for(iOT = 0, iCols = 0;iOT < vOTTypes.size(); iOT+=19, iCols++){
				 strTemp = null;
				 iIndex = vEmpOT.indexOf((Integer)vOTTypes.elementAt(iOT));
				 if(iIndex != -1){
					 strTemp = (String)vEmpOT.elementAt(iIndex+2);					 
				 }

				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
				dLineTotal += dTemp;
				adDeptTotalOT[iCols] = adDeptTotalOT[iCols] + dTemp;
				adPageTotalOT[iCols] = adPageTotalOT[iCols] + dTemp;
				strTemp = CommonUtil.formatFloat(dTemp,true);
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
      <%}
			}%>					
      <%		
			if(vEarnings != null){
				// subject allowances 
				strTemp = (String)vEarnings.elementAt(0); 
				if (strTemp.length() > 0){
					dTempOthers = Double.parseDouble(strTemp);
				}
				// ungrouped earnings.
				strTemp = (String)vEarnings.elementAt(1); 
				if (strTemp.length() > 0){
					dTempOthers += Double.parseDouble(strTemp);
				}				
			}
			
		/*
		// ot_amt
		if (vRows.elementAt(i+23) != null){	
			strTemp = (String)vRows.elementAt(i+23); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}
		*/

		// COLA
		if (vRows.elementAt(i+25) != null){	
			strTemp = (String)vRows.elementAt(i+25); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}
		
		// night_diff_amt
		if (vRows.elementAt(i+24) != null){	
			strTemp = (String)vRows.elementAt(i+24); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}
		
		// holiday_pay_amt
		if (vRows.elementAt(i+26) != null){	
			strTemp = (String)vRows.elementAt(i+26); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}
		// addl_payment_amt 
		if (vRows.elementAt(i+27) != null){	
			strTemp = (String)vRows.elementAt(i+27); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}

		// Adhoc Allowances
		if (vRows.elementAt(i+28) != null){	
			strTemp = (String)vRows.elementAt(i+28); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}

		// addl_resp_amt
		if (vRows.elementAt(i+29) != null){	
			strTemp = (String)vRows.elementAt(i+29); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}
		
		// substitute salary
		if (vRows.elementAt(i+38) != null){	
			strTemp = (String)vRows.elementAt(i+38); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}						
		dTempOthers = CommonUtil.formatFloatToCurrency(dTempOthers,2);		
		dLineTotal += dTempOthers;
		dPageOthers += dTempOthers;
		dDeptOthEarn += dTempOthers;
		strTemp = Double.toString(dTempOthers);
	  %>
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
	<%
	  dTemp = 0d;
			// adjustment amount
	  if (vRows.elementAt(i+51) != null){	
			strTemp = (String)vRows.elementAt(i+51); 
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
		dTemp = CommonUtil.formatFloatToCurrency(dTemp, 2);
		strTemp = Double.toString(dTemp);
		dLineTotal += dTemp;
		dDeptAdjust += dTemp;
		dPageAdjust += dTemp;
	  %>		 
			<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>

		<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
				adEarnDedTotal[iCols-1] = adEarnDedTotal[iCols-1] + dTemp;
				adDeptEarnDedTotal[iCols-1] = adDeptEarnDedTotal[iCols-1] + dTemp;
				adPageEarnDedTotal[iCols-1] = adPageEarnDedTotal[iCols-1] + dTemp;
				dLineTotal -= dTemp;
				if(strTemp.equals("0"))
					strTemp = "";			
			%> 			
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"")%></td>
			<%}%> 		
			
		 <%			
	  	dTemp = 0d;
		// late_under_amt
		if (vRows.elementAt(i+48) != null){	
			strTemp = (String)vRows.elementAt(i+48); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp);
			}
		}
		
		//faculty_absence
	  	if (vRows.elementAt(i+49) != null){	
			strTemp = (String)vRows.elementAt(i+49); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp);
			}
		}
		
		//leave_deduction_amt
	  	if (vRows.elementAt(i+33) != null){	
			strTemp = (String)vRows.elementAt(i+33); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp);
			}
		}
		
		//awol_amt
	  	if (vRows.elementAt(i+47) != null){	
			strTemp = (String)vRows.elementAt(i+47); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp);
			}
		}
		
		dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
		dDeptAbsence += dTemp;
		dPageAbsence += dTemp;
		dLineTotal -= dTemp;
 	  %>
			<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dTemp, true)%></td>
      <%
	  	dLineTotal += dBasic;
			dDeptGross += dLineTotal;
			dPageGross += dLineTotal;
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"&nbsp;")%></td>
      <%if(astrContributions[0].equals("1") || astrContributions[1].equals("1")){
				// sss contribution
			dTemp = 0d;
				if (vRows.elementAt(i+39) != null){	
				strTemp = (String)vRows.elementAt(i+39); 
				strTemp = ConversionTable.replaceString(strTemp,",","");
				if (strTemp.length() > 0){
					dTemp = Double.parseDouble(strTemp);
				}
			}
	
				// phealth contribution	
			if (vRows.elementAt(i+40) != null){	
				strTemp = (String)vRows.elementAt(i+40); 
				strTemp = ConversionTable.replaceString(strTemp,",","");
				if (strTemp.length() > 0){
					dTemp += Double.parseDouble(strTemp);
				}
			}
			
			dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
			dEmpDeduct += dTemp;
			dDeptSSS += dTemp;
			dPageSSS += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp, true);
			if(dTemp == 0d)
				strTemp = "&nbsp;";
	//		System.out.println("SSS " +dTemp);
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
      <%}%>
      <%if(astrContributions[2].equals("1")){
	  	// hdmf contribution
	  	dTemp = 0d;
	  	if (vRows.elementAt(i+41) != null){	
				strTemp = (String)vRows.elementAt(i+41); 
				strTemp = ConversionTable.replaceString(strTemp,",","");
				if (strTemp.length() > 0){
					dTemp = Double.parseDouble(strTemp);
				}
			}
			dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
			dDeptPagibig += dTemp;
			dEmpDeduct += dTemp;
			dPageHdmf += dTemp;
			
			strTemp = CommonUtil.formatFloat(dTemp, true);
			if(dTemp == 0d)
				strTemp = "&nbsp;";
	//		System.out.println("hdmf " +dTemp);
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
      <%}%>
      <%if(astrContributions[4].equals("1")){
				// PERAA
				strTemp = (String)vRows.elementAt(i +43);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				dEmpDeduct += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
      <%}%>
       <%
	  	dTemp = 0d;
		// tax
	  	if (vRows.elementAt(i+46) != null){	
			strTemp = (String)vRows.elementAt(i+46); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
		dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
		dEmpDeduct += dTemp;
		dDeptTax += dTemp;
		dPageTax += dTemp;
		strTemp = Double.toString(dTemp);
//		System.out.println("Tax " +dTemp);
	  %>
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
       <%for(iCols = 1;iCols <= iDedColCount/2; iCols ++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				dEmpDeduct += dTemp;
				adDeptDeductTotal[iCols-1] = adDeptDeductTotal[iCols-1] + dTemp;
				adPageDeduct[iCols-1] = adPageDeduct[iCols-1] + dTemp;
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
			dEmpDeduct += dOtherDed;
			dDeptOthDed += dOtherDed;
			dPageAdv += dOtherDed;
			strTemp = CommonUtil.formatFloat(dOtherDed,true);
			if(dOtherDed == 0d)
				strTemp = "&nbsp;";
	  %>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
      <%
				dDeptTotalDed += dEmpDeduct;
				dPageTotDed += dEmpDeduct;
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(CommonUtil.formatFloat(dEmpDeduct,true),"&nbsp;")%></td>
      <%				
				if(bolShowBorder)
					strBorder =  "class='thinborderBOTTOMLEFTRIGHT'";
				else
					strBorder = "class='NoBorder'";
				
				strTemp = (String)vRows.elementAt(i+52);
				
 				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));			
				strTemp = CommonUtil.formatFloat(dTemp, 2);
				dTemp = Double.parseDouble(strTemp);

				dDeptNet += dTemp;		
				dPageNet += dTemp;
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
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
		bolShowSignatory = true;
  	bolOfficeTotal = false;
	//iCount++;

	if (iCount > iMaxRecPerPage || WI.fillTextValue("break_per_office").length() > 0)
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
      <td height="23" align="right" valign="bottom" nowrap <%=strBorder%>><strong>DEPT TOTAL</strong></td>
      <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
			<!--// excess lec in -->
			<td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
			<!--// excess lab in -->
			<td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
			<!--total hours inside office hours-->
			<td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
			<!--Excess lec out-->
			<td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
			<!--Excess lab out-->
			<td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
			<!--total Excess out-->			
			<td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptExtra, true)%></td>
		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%>     
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adDeptEarningTotal[iCols-2],true)%></td>
		<%}%>
			<% for(iCols = 0;iCols < iOTType; iCols++){%>      
			<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adDeptTotalOT[iCols],true)%></td>
      <%}%>					
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptOthEarn,true)%></td>
			<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptAdjust,true)%></td>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = CommonUtil.formatFloat(adDeptEarnDedTotal[iCols-1] ,true);
			%> 			
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"")%></td>
			<%}%> 		
			<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptAbsence,true)%></td>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptGross,true)%></td>
      <%if(astrContributions[0].equals("1") || astrContributions[1].equals("1")){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptSSS,true)%></td>
      <%}%>
      <%if(astrContributions[2].equals("1")){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptPagibig,true)%></td>
      <%}%>
      <%if(astrContributions[4].equals("1")){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
      <%}%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptTax,true)%></td>
       <%for(iCols = 1;iCols <= iDedColCount/2; iCols ++){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adDeptDeductTotal[iCols-1],true)%></td>
      <%}%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptOthDed,true)%></td>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptTotalDed,true)%></td>
      <%				
				if(bolShowBorder)
					strBorder =  "class='thinborderBOTTOMLEFTRIGHT'";
				else
					strBorder = "class='NoBorder'";
			%>			
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dDeptNet,true)%></td>
    </tr>
    <% 
		dGrandLateUT += dDeptLateUT;
		dGrandAbsence += dDeptAbsence;
 		dGrandBasic += dDeptBasic;		
		dGrandNP += dDeptNP;
		dGrandExtra += dDeptExtra;
		dGrandTotalDed += dDeptTotalDed;
 		//dGrandOT += dDeptOT;
		for(iCols = 0;iCols < iOTType; iCols++){
			adTotalOT[iCols] += adDeptTotalOT[iCols];
		}		
		dGrandAdjust += dDeptAdjust;
//		for(iCols = 0;iCols < iAdjType; iCols++){
//			adTotalAdj[iCols] += adDeptTotalAdj[iCols];
//		}		
		
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
	<%
		if(bolPageBreak){
			iCount = 0;
			break;
		}
	 }// end DEPT FOR LOOP %>		
	 
 <%if((bolPageBreak || iNumRec >= vRows.size()) && WI.fillTextValue("hide_page_total").length() == 0){
	//iCount++;
%>
<tr>
	<%				
		if(bolShowBorder)
			strBorder =  "class='thinborder'";
		else
			strBorder = "class='thinborderBottom'";
	%>
  <td height="23" align="right" valign="bottom" nowrap <%=strBorder%>><strong>PAGE TOTAL</strong></td>
  <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
  <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
  <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
  <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
  <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
  <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
  <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
  <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
  <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%>  
	<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adPageEarningTotal [iCols-2],true)%></td>
	<%}%>
  
  <% for(iCols = 0;iCols < iOTType; iCols++){%> 
	<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adPageTotalOT [iCols],true)%></td>
	<%}%>
  <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dPageOthers, true)%></td>
  <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dPageAdjust, true)%></td>
  <%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
		strTemp = CommonUtil.formatFloat(adPageEarnDedTotal[iCols-1] ,true);
	%> 		
	<td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"")%></td>
	<%}%>
  <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dPageAbsence,true)%></td>	
  <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dPageGross,true)%></td>
	<%if(astrContributions[0].equals("1") || astrContributions[1].equals("1")){%>
  <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dPageSSS,true)%></td>
	<%}%>
	<%if(astrContributions[2].equals("1")){%>
  <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dPageHdmf,true)%></td>
	<%}%>
  <%if(astrContributions[4].equals("1")){%>
	<td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
	<%}%>
  <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dPageTax,true)%></td>
  <%for(iCols = 1;iCols <= iDedColCount/2; iCols ++){%>
	<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(adPageDeduct[iCols-1],true)%></td>
	<%}%>
  <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dPageAdv,true)%></td>
  <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dPageTotDed,true)%></td>
	<%				
		if(bolShowBorder)
			strBorder =  "class='thinborderBOTTOMLEFTRIGHT'";
		else
			strBorder = "class='thinborderBottom'";
	%>		
  <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dPageNet,true)%></td>
</tr>	
<%}%>	 

	<%if(iNumRec >= vRows.size() && WI.fillTextValue("hide_grand_total").length() == 0){%>		
    <tr>
		<%				
			if(bolShowBorder)
				strBorder =  "class='thinborder'";
			else
				strBorder = "class='NoBorder'";
		%>		
      <td height="23" align="right" nowrap <%=strBorder%>><strong>GRAND TOTAL</strong></td>
			<td align="right" <%=strBorder%>>&nbsp;</td>
			<td <%=strBorder%>>&nbsp;</td>
			<td <%=strBorder%>>&nbsp;</td>
			<td <%=strBorder%>>&nbsp;</td>
			<td <%=strBorder%>>&nbsp;</td>
			<td <%=strBorder%>>&nbsp;</td>
			<td <%=strBorder%>>&nbsp;</td>
			<td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandExtra,true)%></td>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%>
			<td <%=strBorder%>><%=CommonUtil.formatFloat(adEarningTotal[iCols-2],true)%></td>
			<%}%>
			<% for(iCols = 0;iCols < iOTType; iCols++){%>
			<td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(adTotalOT[iCols],true)%></td>
			<%}%>
			<td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandOthEarn,true)%></td>
			<td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandAdjust,true)%></td>
		<%for(iCols = 1;iCols <= iEarnDedCount; iCols++){%>
		<td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(adEarnDedTotal[iCols-1],true)%></td>
			<%}%>
			<td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandAbsence,true)%></td>
			<td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandGross,true)%></td>
			<%if(astrContributions[0].equals("1") || astrContributions[1].equals("1")){%>
			<td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandSSS,true)%></td>
			<%}%>
			<%if(astrContributions[2].equals("1")){%>
			<td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandPagibig,true)%></td>
			<%}%>
			<%if(astrContributions[4].equals("1")){%>
			<td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandPeraa,true)%></td>
			<%}%>
			<td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandTax,true)%></td>
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols++){%>
      <td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(adDeductTotal[iCols-1],true)%></td>
       <%}%>
      <td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandOthDed,true)%></td>
      <td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandTotalDed,true)%></td>
			<%				
				if(bolShowBorder)
					strBorder =  "class='thinborderBOTTOMLEFTRIGHT'";
				else
					strBorder = "class='NoBorder'";
			%>			
      <td align="right" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandNet,true)%></td>
     </tr>
	<%}/// bolPageBreak || iNumRec >= vRows.size()%>
  </table>  
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="77%" class="thinborderTOP">&nbsp;
		<%if(bolShowSignatory || WI.fillTextValue("break_per_office").length() == 0){
			bolShowSignatory = false;
		%>
		<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td height="20" colspan="3">CERTIFIED CORRECT BY:</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM">&nbsp;</td>
      </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top"><div align="center"><font size="1"><strong><%=WI.fillTextValue("accounting_head").toUpperCase()%><br>
          </strong>HEAD, ACCOUNTING SECTION </font></div></td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><strong><font size="1"><%=WI.fillTextValue("benefit_head").toUpperCase()%><br>
          </font></strong><font size="1">HEAD, BENEFIT SECTION </font></div></td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><font size="1"><strong><%=WI.fillTextValue("payroll_head").toUpperCase()%></strong><br>
          HEAD, PAYROLL SECTION </font></div></td>
      </tr>
    <tr> 
      <td height="14">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="3"><font size="1"><strong>APPROVED FOR PAYMENT</strong></font></td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="3" class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top" class="thinborderBOTTOM">&nbsp;</td>
      </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="3" valign="top"><div align="center"><strong><font size="1"><%=WI.fillTextValue("president").toUpperCase()%><br>
      </font></strong><font size="1">PRESIDENT</font></div></td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><strong><font size="1"><%=WI.fillTextValue("vp_finance").toUpperCase()%><br>
          </font></strong><font size="1">CTTP/VP-Finance</font></div></td>
      </tr>
    <tr>
      <td width="4%" height="18">&nbsp;</td>
      <td width="1%">&nbsp;</td>
      <td width="26%">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td width="10%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td width="10%">&nbsp;</td>
      <td width="9%">&nbsp;</td>
      </tr>
  </table>
		<%}%>
		</td>
    <td width="2%" class="thinborderTOP">&nbsp;</td>
    <td width="21%" class="thinborderTOP">&nbsp;<%if(WI.fillTextValue("show_page_sum").length() > 0){%>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="67%" class="NoBorder">SALARIES &amp; WAGES</td>
          <td width="33%" align="right" class="NoBorder"><%=CommonUtil.formatFloat(dPageGross,true)%>&nbsp;</td>
        </tr>
        <tr>
          <td class="NoBorder">SSS &amp; MED</td>
          <td align="right" class="NoBorder">&nbsp;<%=CommonUtil.formatFloat(dPageSSS,true)%>&nbsp;</td>
        </tr>
        <tr>
          <td class="NoBorder">HDMF</td>
          <td align="right" class="NoBorder"><%=CommonUtil.formatFloat(dPageHdmf,true)%>&nbsp;</td>
        </tr>
        <tr>
          <td class="NoBorder">W/HOLDING TAX</td>
          <td align="right" class="NoBorder">&nbsp;<%=CommonUtil.formatFloat(dPageTax,true)%>&nbsp;</td>
        </tr>
        <%						
					for(iCols = 1,iColCounter = 1;iColCounter <= iDedColCount; iCols++, iColCounter+=2){ 
						strTemp = (String)vDedCols.elementAt(iColCounter);
					%>
        <tr>
          <td class="NoBorder"><%=strTemp%></td>
          <td align="right" class="NoBorder"><%=CommonUtil.formatFloat(adPageDeduct[iCols-1],true)%>&nbsp;</td>
        </tr>
        <%}%>
        <tr>
          <td class="NoBorder">ADV'S TO EMPS</td>
          <td align="right" class="NoBorder">&nbsp;<%=CommonUtil.formatFloat(dPageAdv,true)%>&nbsp;</td>
        </tr>
        <tr>
          <td class="NoBorder">CASH IN BANK</td>
          <td align="right" class="NoBorder">&nbsp;<%=CommonUtil.formatFloat(dPageNet,true)%>&nbsp;</td>
        </tr>
      </table>
      <%}%></td>
  </tr>
</table>
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