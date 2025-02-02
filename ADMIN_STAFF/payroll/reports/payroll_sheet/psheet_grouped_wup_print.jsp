<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, 
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
  
  TD.thinborderHeader {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
	border-top: solid 1px #000000;	
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
	int iEmpCount = 1;
	
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
		
	Vector vSalaryPeriod 		= null;//detail of salary period.
	Vector vGroupDedNames = null;	
	Vector vGroupDedPerEmp = null;
	PReDTRME prEdtrME = new PReDTRME();
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
	OvertimeMgmt otMgmt = new OvertimeMgmt();
	String strPayrollPeriod  = null;	
	String strHourlyRate = null;
	String strSchCode = dbOP.getSchoolIndex();
	String strUserIndex = null;
	double dDailyRate = 0d;
	
	int iFieldCount = 75;// number of fields in the vector..
	int iNumRec = 0; 
	
	double dTemp = 0d;
 	double dLineTotal = 0d;
	boolean bolPageBreak = false;
	boolean bolMoveNextPage = false;
	int i = 0;
	int iIndex = 0;
	int iIndexOf = -1; 
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	Vector vRetResult = null;
	
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;
	int iDeptCol = 2;	
	 	
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
	String strCutOff = null;
	
 	double dTotalOTAmount = 0d;
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
	
	int iNumGroupDed = 0;
	
		
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

		//grouped ded
		vGroupDedNames = RptPSheet.getGroupedDeduction(dbOP);
		if(vGroupDedNames != null && vGroupDedNames.size() > 0){
			iNumGroupDed = vGroupDedNames.size();
			strTemp = " colspan='"+(iNumGroupDed+3)+"' ";
		}else{
			strTemp = " colspan='3' ";
		}	
			
		//this are the variables use for subtotal
		double[] adDeductSubTotal = new double[iNumGroupDed];
		double[] adDeductOverallTotal = new double[iNumGroupDed];
		double dOtherDedSubTotal = 0d;
		double dOtherDedOverallTotal = 0d;		
		double dLineDedSubTotal = 0d;
		double dLineDedOverallTotal = 0d;
		//end of var for subtotal
	
	
%>
<body onLoad="javascript:window.print();"> 
<form name="form_" 	method="post" action="psheet_grouped.jsp">
 
 
 	<%
	 for (;iNumRec < vRows.size();iPage++){ // OUTERMOST FOR LOOP
	 	dTemp = 0d;
		dLineTotal = 0d;
	%>
 
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">  
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
		<td width="3%">&nbsp;</td>
      <td height="24" align="left" colspan="2"><strong><%=WI.fillTextValue("report_title")%> FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%> <%=WI.getStrValue(strCutOff, "Cut Off : ","","")%></td>
          <%if(WI.fillTextValue("team_index").length() > 0){%>
          <br>
		TEAM : <%=WI.fillTextValue("team_name")%>
			<%}%>      	
	  <td width="49%" height="19"  align="right">&nbsp;Date and time printed : <%=WI.getTodaysDateTime()%></td>	
    </tr>	
	
	
	</table>
		<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>     
	  <td width="2%">&nbsp;</td>  		
      <td width="20%" height="33"  align="center" class="thinborderHeader">NAME 
        OF EMPLOYEE </td> 
		<!--<td width="19%" height="33"  align="center" class="thinborderHeader">DEPARTMENT/COLLEGE  </td>      -->
			<%				
			for(iIndex = 0;iIndex < iNumGroupDed; iIndex++){
				strTemp = (String)vGroupDedNames.elementAt(iIndex);
			%>
      			<td width="7%"  align="center" class="thinborderHeader"><%=strTemp%></td>
      		<%}//end of for loop%>			
      <!--<td width="8%"  align="center" class="thinborderHeader">OTHER DED</td>  -->
	  <td width="71%"  align="center" class="thinborderHeader" style="border-right:solid 1px #000000;">TOTAL DED</td>     
    </tr> 
    <% 
		
  for(; iNumRec < vRows.size();){// employee for loop
	i = iNumRec;
	
    //vEarnings = (Vector)vRows.elementAt(i+53);
	vDeductions = (Vector)vRows.elementAt(i+54);
	//vSalDetail = (Vector)vRows.elementAt(i+55); 
	//vOTDetail = (Vector)vRows.elementAt(i+56);
	vEarnDed  = (Vector)vRows.elementAt(i+59);
	//vEmpOT = (Vector)vRows.elementAt(i+65);
	//vEmpAdjust = (Vector)vRows.elementAt(i+67);
	dLineTotal = 0d;
	//dDaysWorked = 0d;
 	dOtherEarn = 0d;
	dOtherDed = 0d;
	//dTotalOTAmount = 0d;
	iCount++;
	
	strUserIndex = (String)vRows.elementAt(i+1);
	//call me here getDeductionDetails
	vGroupDedPerEmp = RptPSheet.getDeductionDetails(dbOP,strUserIndex,WI.fillTextValue("sal_period_index"));
	%>	
    <tr>
      <td width="2%" align="right"><%=iEmpCount++%>&nbsp;</td>
      <td height="22" valign="bottom" class="thinborder"><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),(String)vRows.elementAt(i+6), 4)%></td>			
      <%
				// department
				strTemp = null;
				if((String)vRows.elementAt(i + 62)== null || (String)vRows.elementAt(i + 63)== null){
					strTemp = " ";			
				  }else{
					strTemp = " - ";
				  }
			%>	
	<!-- <td height="22" valign="bottom" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRows.elementAt(i + 62),"")%><%=strTemp%><%=WI.getStrValue((String)vRows.elementAt(i + 63),"")%></td>	-->		
     			
		<%
	  //map group ded here	  
	  for(iCols = 0;iCols < iNumGroupDed; iCols ++){	  			
				strTemp = (String)vGroupDedNames.elementAt(iCols);//column name				
				iIndexOf = vGroupDedPerEmp.indexOf(strTemp);				
				dTemp = 0d;
				if(iIndexOf < 0)//emp has no such ded
					dTemp = 0d;
				else if(vGroupDedPerEmp.size() > (iIndexOf + 1)){//emp has this ded
					strTemp = (String)vGroupDedPerEmp.elementAt(iIndexOf + 1);//ded_amount
					dTemp = Double.parseDouble(strTemp);
					dLineTotal += dTemp;
					adDeductSubTotal[iCols] += dTemp;
				}		
				strTemp = CommonUtil.formatFloat(dTemp,true);
				if(dTemp <= 0)
					strTemp = "0.00";							
			%>     		
      <td align="right" valign="bottom" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%}%>
      <%
			// this is the other ungrouped deductions.they dont want to see other ded, ingon gretchen 02012013
			/*strTemp = (String)vDeductions.elementAt(0);
			dTemp = Double.parseDouble(strTemp);
			dOtherDed += dTemp;
			
			// misc_deduction
			strTemp = (String)vRows.elementAt(i + 45); 
			strTemp = WI.getStrValue(strTemp,"0");
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dOtherDed += Double.parseDouble(strTemp);				

			dLineTotal += dOtherDed;
			strTemp = CommonUtil.formatFloat(dOtherDed,true);
			dDeptOthDed += dOtherDed;
			if(dOtherDed == 0d)
				strTemp = "";
				
			dOtherDedSubTotal += dOtherDed;	
			dLineDedSubTotal  += dLineTotal;	*/	
	  %>				
      <!--<td align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>-->	
	  <%
	  	dLineDedOverallTotal += dLineTotal;
	  %>						
      <td align="right" valign="bottom" class='thinborderBOTTOMLEFTRIGHT' ><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
  <% 
 	 iNumRec+=iFieldCount;	
	 if(iNumRec >= vRows.size())	
		iCount++;

	if (iCount >= iMaxRecPerPage || i >= vRows.size()){		
		bolPageBreak = true; %>
		<DIV style="page-break-before:always">&nbsp;</Div>
	   	<% iCount = 0;
			break;
	}else
		bolPageBreak = false;		
	
	}//end employee for loop%>  
  	  
   <!-- hide the whole <tr> because not by dept.only aphabetical order -->  
		<tr>  
	 <!--<td>&nbsp;</td>-->
	 <!--
      <td width="18%" height="25"  align="center" class="thinborder"><strong>Dept. total</strong>&nbsp; </td>      
			<%				
			for(iIndex = 0;iIndex < iNumGroupDed; iIndex++){				
			%>
      			<td width="7%"  align="right" class="thinborder"><strong><%=CommonUtil.formatFloat(adDeductSubTotal[iIndex],true)%>&nbsp;</strong></td>
      		<%}//end of for loop%>			
      <td width="8%"  align="right" class="thinborder"><strong><%=CommonUtil.formatFloat(dOtherDedSubTotal,true)%>&nbsp;</strong></td>  
	  <td width="34%"  align="right" class="thinborderBOTTOMLEFTRIGHT"><strong><%=CommonUtil.formatFloat(dLineDedSubTotal,true)%>&nbsp;</strong></td>     
    </tr> -->
	
    <% 	
		for(iIndex = 0;iIndex < iNumGroupDed; iIndex++){
			adDeductOverallTotal[iIndex] += adDeductSubTotal[iIndex];
			adDeductSubTotal[iIndex]  = 0d;
		}
		dOtherDedOverallTotal += dOtherDedSubTotal;	
		dOtherDedSubTotal 	  = 0d;
		
		//dLineDedOverallTotal  += dLineDedSubTotal;
		dLineDedSubTotal   	  = 0d;
		

		%>
	<%if(iNumRec >= vRows.size()){%>		
	<tr><td>&nbsp;</td></tr>
	
    <tr>  
	 <td>&nbsp;</td>
      <td width="20%" height="33"  align="center" class="thinborderHeader"><strong>Grand total</strong>&nbsp; </td>  
	 <!-- <td width="14%" height="33"  align="center" class="thinborderHeader">&nbsp; </td>      -->
			<%				
			for(iIndex = 0;iIndex < iNumGroupDed; iIndex++){				
			%>
      			<td width="7%"  align="right" class="thinborderHeader"><strong><%=CommonUtil.formatFloat(adDeductOverallTotal[iIndex],true)%>&nbsp;</strong></td>
      		<%}//end of for loop%>	
		<!--			
      <td width="23%"  align="right" class="thinborderHeader"><strong><%=CommonUtil.formatFloat(dOtherDedOverallTotal,true)%>&nbsp;</strong></td>  -->
	  <td width="71%"  align="right" class="thinborderHeader" style="border-right:solid 1px #000000;"><strong><%=CommonUtil.formatFloat(dLineDedOverallTotal,true)%>&nbsp;</strong></td>     
    </tr>   
	<%}/// bolPageBreak || iNumRec >= vRows.size()%>
		
  </table>  
  
  
	<%if(iNumRec >= vRows.size()){%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
   	<tr><td>&nbsp;</td></tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>Prepared by: </td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td align="center" valign="bottom">&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center" valign="bottom" height="40"><%=WI.fillTextValue("prepared_by")%></td>
      <td height="25">&nbsp;</td>
      <td height="25" align="center" valign="bottom">&nbsp;</td>
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