<%@ page language="java" import="utility.*,java.lang.Integer, java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME, eDTR.OverTime, eDTR.ReportEDTRExtn" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
boolean bolHasTeam = false;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Control Total for Payroll</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
    table.TOPRIGHT {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }

    TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 9px;
    }
    TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 9px;
    }		

		TD.BOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }		
    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
		}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	
	var strPrepared = document.form_.prepared_by.value;
	var strReviewed = document.form_.reviewed_by.value;
	
	//check prepared by and verified by
	if(strPrepared.length == 0){
		alert("Please enter prepared by name.");
		return;		
	}
	if(strReviewed.length == 0 ){
		alert("Please enter verified by name.");
		return;		
	}
	
	document.bgColor = "#FFFFFF";	
	document.getElementById("school_header").style.display = "table"; //header
	document.getElementById("school_info").style.display = "table-row"; //title	
	document.getElementById("print_icon").style.display = "none";	
	document.getElementById("table2").style.display = "none";	
	document.getElementById("table3").style.display = "none";	
	document.getElementById("view_option").style.display = "none";		

	document.getElementById("prepared_by_label").innerHTML = strPrepared;
	document.getElementById("reviewed_by_label").innerHTML = strReviewed;
	
	 document.form_.prepared_by.style.display = "none";
	 document.form_.reviewed_by.style.display = "none";
	
	alert("Print this page?");
	window.print();
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}
function loadSalPeriods() {
	var strMonth = document.form_.month_of.value;
	var strYear = document.form_.year_of.value;
	var strWeekly = null;
	
	if(document.form_.is_weekly){
		if(document.form_.is_weekly.checked)
			strWeekly = "1";
		else
			strWeekly = "";
	}
	
	var objCOAInput = document.getElementById("sal_periods");
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly+"&onchange=ReloadPage()";

	this.processRequest(strURL);
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>

<%
	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	String strUserId = (String)request.getSession(false).getAttribute("userId");
	boolean bolShowALL = false;
	if(strUserId != null && (strUserId.equals("bricks") || strUserId.equals("SA-01")) )
		bolShowALL = true;	
	boolean bolShowBorder = false;
	
	//sul..for display only 06272012
	boolean bIsOneTableDisplay = false;
	String strOneTable =  WI.getStrValue(WI.fillTextValue("show_all"),"0");
	if (strOneTable.equals("1"))		
		bIsOneTableDisplay = true;	
//add security here.

try
	{
		dbOP = new DBOperation(strUserId,
								"Admin/staff-Payroll-REPORTS-Control Payroll","control_report.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"control_report.jsp");
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
	ReportEDTRExtn RE = new ReportEDTRExtn(request);
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
	String strPayrollPeriod  = null;
	String strTemp2 = null;
	int iFieldCount = 75;// number of fields in the vector..
	int i = 0;

	double dBasic = 0d;
	double dTotalBasic = 0d;
	double dTotalOvertime = 0d;
	double dTotalTardiness = 0d;
	double dTotalNightDiff = 0d;
	double dDaysWorked = 0d;
	double dTemp = 0d;
	double dLineOver = 0d;
	double dLineTotal = 0d;
	double dOtherDed = 0d;	
	double dGTotalOtherEarn = 0;
	double dTotalOtherEarn  = 0;
	double dEmpDeduct = 0d;
	double dTotalDeductions = 0d;
	double dOverAllTotal = 0d;
	double dGTotalBasic = 0d;
	
	

	Vector vRetResult = null;
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	Vector vOtherEarnDetails = new Vector();
	
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;
	
	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vNightDiff = null;	
	Vector	vEmpAdjust = null;
	Vector vEarnDed = null;
	Vector vOTDetail = null;
	Vector vOTType = null;
	Vector vOTGroupName = overtime.operateOnOvertimeGrouping(dbOP,request,4);//group names
	Vector vOTGroup = overtime.operateOnOTGroupTypeMapping(dbOP,request,4);
	Vector vOTNoGroup = overtime.operateOnOTGroupTypeMapping(dbOP,request,5);	
	Vector vOTGroupList = new Vector(); //holds the index and amount of ot w/ group  ->[type_index][amount][type_index][amount]
	Vector vOTNoGroupList = new Vector();//holds the index and amount of ot w/o group->[type_index][amount][type_index][amount]
	Vector vTemp = null;
	
	Vector vSalDetail = null;
	Vector vContributions = null;
	Vector vPSheetDetails = null;
	
	Vector vGroupDedNames = null;
	
	double dOtherEarn = 0d;
	String strSchCode = dbOP.getSchoolIndex();
	int iHour = 0;
	int iMinute = 0;
	int iContributions = 0;
	int iIndexOf = -1;
	int iOTCounter = 0;
	
	if(vOTGroupName != null && vOTGroupName.size() > 0)
			iOTCounter = vOTGroupName.size()/3;
	if(vOTNoGroup != null && vOTNoGroup.size() > 0)
			iOTCounter += vOTNoGroup.size()/3;	
		
		
	vRetResult = RptPSheet.getPSheetItems(dbOP);
	if(vRetResult == null)
		strErrMsg = RptPSheet.getErrMsg();
	else{
		vRows = (Vector)vRetResult.elementAt(0);
		vEarnCols = (Vector)vRetResult.elementAt(1);
		vDedCols = (Vector)vRetResult.elementAt(2);		
		vEarnDedCols = (Vector)vRetResult.elementAt(3);		
		vContributions = RptPSheet.checkPSheetContributions(dbOP, request, WI.fillTextValue("sal_period_index"));
		vPSheetDetails = RptPSheet.getPSheetDetails(dbOP, request, WI.fillTextValue("sal_period_index"));
		vOtherEarnDetails = RptPSheet.getOtherIncomesByDeails( dbOP );
		if(vEarnCols != null && vEarnCols.size() > 0)
			iEarnColCount = vEarnCols.size() - 2;

		if(vDedCols != null && vDedCols.size() > 0)
			iDedColCount = vDedCols.size() - 1;		

		if(vEarnDedCols != null && vEarnDedCols.size() > 0)
			iEarnDedCount = vEarnDedCols.size() - 1;	
			
		iSearchResult = RptPSheet.getSearchCount();		
	}
	
	double[] adEarningTotal = new double[iEarnColCount];
	double[] adGEarningTotal = new double[iEarnColCount];
	
	double[] adDeductTotal = new double[iDedColCount];
	double[] adGDeductTotal = new double[iDedColCount];
	
	double[] adEarnDedTotal = new double[iEarnDedCount];
	double[] adGEarnDedTotal = new double[iEarnDedCount];
	
	Vector []arrVGroupDedDetails = new Vector[iDedColCount];
	Vector []arrVGroupEarnDetails = new Vector[iEarnColCount];
	Vector vGroupDed = null;
	Vector vGroupEarnings = null;
	
	
	String[] astrSalaryBase = {"Monthly rate", "Daily Rate", "Hourly Rate"};
	
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
	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body>
<form name="form_" 	method="post" action="control_report_old.jsp">
<table  id="table1" width="100%"> 
<tr><td>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table2">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL: CONTROL TOTAL FOR PAYROLL ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="table3">
    <tr> 
      <td height="23" colspan="5"><font size="2" color="#FF0000"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="3"> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td width="16%" height="25">&nbsp;</td>
      <td width="18%">Salary Period</td>
      <td width="66%" colspan="3"><strong>
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="ReloadPage();">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
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
		%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%></option>
          <%}//end of if condition.		  
		 }//end of for loop.%>
        </select>
		</label>
        </strong>
        <% 
				if(strHasWeekly.equals("1")){
					strTemp = WI.fillTextValue("is_weekly");
					if(strTemp.compareTo("1") == 0) 
						strTemp = " checked";
					else	
						strTemp = "";
				%>
        <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="ReloadPage();">
        <font size="1">for weekly </font>
        <%}// check if the company has weekly salary type%>      </td>
    </tr>
	<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salary base </td>
			<%
				strTemp = WI.fillTextValue("salary_base");
			%>
      <td colspan="3">
			<select name="salary_base" onChange="ReloadPage();">
				<option value="">ALL</option>
        <%for(i = 0; i < astrSalaryBase.length; i++){
					if(strTemp.equals(Integer.toString(i))){
				%>
				<option value="<%=i%>" selected><%=astrSalaryBase[i]%></option>
				<%}else{%>
				<option value="<%=i%>"><%=astrSalaryBase[i]%></option>
				<%}
				}%>
      </select></td>
    </tr>
	-->
	
		
	<tr><td>&nbsp;</td></tr>
	<tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();"></td>
    </tr>
	
	
  </table> 
  
 </td></tr></table> <!-- end of table1 --> 
  
  </table>
	
	
<% if(vPSheetDetails != null && vPSheetDetails.size() > 1 && vRows != null && vRows.size() > 1){ 

		vGroupDed = RptPSheet.getDeductionDetails(dbOP,null,WI.fillTextValue("sal_period_index"));
		vGroupEarnings =  RptPSheet.getEarningDetails(dbOP,null,WI.fillTextValue("sal_period_index"));
		
		 for (i = 0 ;i < vRows.size();i+=75){
			
			// Night Diff	
				strTemp = (String)vRows.elementAt(i + 60);
			  	request.setAttribute("emp_id", strTemp);
				vTemp = RE.generateNightDifferentialReport(dbOP);
				if(vTemp != null){
					vNightDiff = (Vector) vTemp.elementAt(6);
					if( vNightDiff != null )
						dTotalNightDiff += Double.parseDouble( WI.getStrValue( (String)vNightDiff.elementAt(1),"0") ) + Double.parseDouble( WI.getStrValue((String)vNightDiff.elementAt(3),"0"));
				}
			
				
			// late_under_amt
				strTemp = (String)vRows.elementAt(i + 48); 			
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTotalTardiness += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
			// faculty absences
				strTemp = (String)vRows.elementAt(i + 49); 			
				strTemp = ConversionTable.replaceString(strTemp,",","");		
				dTotalTardiness += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
			// leave_deduction_amt
				strTemp = (String)vRows.elementAt(i + 33); 			
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTotalTardiness += Double.parseDouble(WI.getStrValue(strTemp,"0"));
			
			// AWOL // i dont know if theres an awol anyway
				strTemp = (String)vRows.elementAt(i + 47); 			
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTotalTardiness += Double.parseDouble(WI.getStrValue(strTemp,"0"));
			
		
		 	//BASIC
				dTotalBasic += Double.parseDouble((String)vRows.elementAt(i + 7));
				// add the faculty salary
				dTotalBasic += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));	
				
			//EARNINGS
				vEarnings = (Vector)vRows.elementAt(i+53);
				for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
					strTemp = (String)vEarnings.elementAt(iCols);			
					dTemp = Double.parseDouble(strTemp);					
					adGEarningTotal[iCols-2] += dTemp;					
				}
				//25   29 28 27 51 26
			//Other earnings
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
			// substitute salary
			if (vRows.elementAt(i+38) != null){	
				strTemp = (String)vRows.elementAt(i+38); 
				strTemp = ConversionTable.replaceString(strTemp,",","");
				if (strTemp.length() > 0){
					dOtherEarn += Double.parseDouble(strTemp);
				}
			}						
			dTotalOtherEarn += dOtherEarn;	
			
			
			//DEDUCTIONS
			vDeductions = (Vector)vRows.elementAt(i+54);	
			for(iCols = 1;iCols <= iDedColCount/2; iCols ++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				adDeductTotal[iCols-1] += dTemp;				
			}	
				
		 }//end of vRows loop
		//for(iCols = 1;iCols <= iDedColCount/2; iCols ++){
		 	//System.out.println("527 adDeductTotal[iCols-1] " +(iCols-1)+"  "+ adDeductTotal[iCols-1]);
		//}
	%>
	<br />
	
	
	<table width="54%" border="0"  align="center" cellspacing="0" cellpadding="0" id="view_option">	 
	<%
		boolean bShowOtherEarnDetails = WI.fillTextValue("show_other_details").equals("1");
		if( bShowOtherEarnDetails )
			strTemp = " checkded";
		else
			strTemp = "";
	%>
		<tr>     
		  <td width="27%" colspan="3"height="25">&nbsp;Show Other Eearnings details: <input type="checkbox" name="show_other_details" value="1" <%=strTemp%> ></td>	
		<tr>
		<tr>     
		  <td width="27%" height="25">&nbsp;Show Details for:</td>	
		  <td height="10"  align="left">&nbsp;&nbsp;<strong>EARNINGS</strong></td>
		  <td width="36%" height="10" colspan="3" align="left"><strong>DEDUCTIONS</strong></td>
	  	</tr>
	  	<tr>      
      		<td height="10" width="27%">&nbsp;</td>      
	 		<td width="34%"  valign="top"> 
			 <%		String strDedName = ""; 
					int iEarnCtr = 0;	
					for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++,iEarnCtr++){
						strDedName = (String)vEarnCols.elementAt(iCols);
		
						arrVGroupEarnDetails[iEarnCtr] = new Vector();
						if(WI.fillTextValue("group_earn_"+iCols).equals("1")){ 
							strTemp = " checked";					
							arrVGroupEarnDetails[iEarnCtr] = RptPSheet.getGroupedEarnings(dbOP,strDedName);
						}else	
							strTemp = "";
				%>
				&nbsp;
				<input type="checkbox" name="group_earn_<%=iCols%>" value="1" <%=strTemp%> >
				<font size="1">&nbsp;<%=strDedName%> </font><br />
			 
			<%}//end of loop%>
			</td>
	<td height="10" colspan="3" valign="top">	
	 <%		strDedName = ""; 	
			for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strDedName = (String)vDedCols.elementAt(iCols);
			
				arrVGroupDedDetails[iCols] = new Vector();		
				if(WI.fillTextValue("group_ded_"+iCols).equals("1")){
					strTemp = " checked";
					arrVGroupDedDetails[iCols] = RptPSheet.getGroupedDeduction(dbOP,strDedName);				
				}else
					strTemp = "";
			%>
        <input type="checkbox" name="group_ded_<%=iCols%>" value="1" <%=strTemp%> >
        <font size="1">&nbsp;<%=strDedName%> </font><br />
	 
	<%		
	}//end of loop%>
	 </td>
	</tr>	
	</table>
	
	
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="school_header" style="display:none">
    <tr>
      <td align="center" colspan="2"><strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong></td>	  
    </tr>  
	 <tr>
      <td align="center" colspan="2"><font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></td>	  
    </tr> 
	 <tr>
      <td colspan="2">&nbsp;</td>
	 </tr>		
    <tr>
      <td>&nbsp;</td>
	  <td height="19" align="right" >&nbsp;Date and time printed : <%=WI.getTodaysDateTime()%></td>    
    </tr>
 </table>
	
	<table width="54%" border="0" align="center" cellpadding="5" cellspacing="0" >
	
	  <tr id="print_icon">		 
		  <td colspan="2" align="right">&nbsp;
		  	<a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font>		  </td>
	  </tr>		  
	  
	  
	  <tr  id="school_info" style="display:none">	  
	  	<td width="62%" height="50">
			<div style=" margin-left: -5px; padding: 10px 0px 10px 5px;" >
			  <strong>CONTROL TOTAL FOR PAYROLL</strong><BR/>			  
			  	CUT-OFF :  <%=strPayrollPeriod%> <br/>
				 <%
					strTemp = WI.fillTextValue("salary_base");
					if(strTemp.length() > 0){%>
						<%=astrSalaryBase[Integer.parseInt(strTemp)]%>					
					<%}%>				
			</div>		</td>
		
		<td>&nbsp;</td>
	  </tr>
	  
	  	<%
			for(int ii=0; ii<vOtherEarnDetails.size(); ii+=3){
				strTemp = vOtherEarnDetails.elementAt(ii+1).toString().toUpperCase();
				dTemp = ((Double)vOtherEarnDetails.elementAt(ii+2)).doubleValue();
				
				if( strTemp.startsWith("BASIC PAY") ){
					//vOtherEarnDetails.remove(vOtherEarnDetails.elementAt(ii+1));
					//vOtherEarnDetails.remove(vOtherEarnDetails.elementAt(ii+2));
					//vOtherEarnDetails.remove(vOtherEarnDetails.elementAt(ii+3));
					dTotalBasic += dTemp;
				}else if( strTemp.startsWith("OVERTIME") ){
					//vOtherEarnDetails.remove(vOtherEarnDetails.elementAt(ii+1));
					//vOtherEarnDetails.remove(vOtherEarnDetails.elementAt(ii+2));
					//vOtherEarnDetails.remove(vOtherEarnDetails.elementAt(ii+3));
					dTotalOvertime += dTemp;
				}
				vOtherEarnDetails.remove(ii);vOtherEarnDetails.remove(ii);vOtherEarnDetails.remove(ii);				
			}
			
		%>
		
		
		<tr>			
		  <td width="62%" class="thinborderTOPLEFTBOTTOM" >BASIC PAY </td>
		  <td width="30%" class="thinborderALL" >&nbsp;<%=CommonUtil.formatFloat((dTotalBasic-dTotalTardiness),true)%></td>			
		</tr>
		<tr>			
			<td width="62%" class="thinborder">OVERTIME PAY </td>
			<%
				strTemp = (String)vPSheetDetails.elementAt(7);
				dTotalOvertime += (Double.parseDouble(strTemp)+dTotalNightDiff);
			%>
		  	<td width="30%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat(dTotalOvertime+"",true)%></td>
			<%
				dOverAllTotal = Double.parseDouble(WI.getStrValue(dTotalOvertime+"","0"));
			%>
		</tr>	
		<% iEarnCtr = 0;
			strTemp2 = null;
		//System.out.println("635 vGroupEarnings: " + vGroupEarnings);		
		for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++,iEarnCtr++){		
			if(arrVGroupEarnDetails[iEarnCtr] != null && arrVGroupEarnDetails[iEarnCtr].size() > 0 ){			
				//System.out.println("553 arrVGroupEarnDetails : " + arrVGroupEarnDetails[iEarnCtr]); 				
				//dispaly detailed deduction for this group
				for(int iCtr2 = 0; iCtr2 < arrVGroupEarnDetails[iEarnCtr].size(); iCtr2++){	
					//System.out.println("641 arrVGroupEarnDetails[iEarnCtr].elementAt(iCtr2): " + ((Vector)arrVGroupEarnDetails[iEarnCtr]).elementAt(iCtr2));				
					strTemp = (String)(arrVGroupEarnDetails[iEarnCtr].elementAt(iCtr2));//column name						
					iIndexOf = vGroupEarnings.indexOf(strTemp);		

					if(iIndexOf < 0)//no such earnings
						continue;
					else if(vGroupEarnings.size() > (iIndexOf + 1)) {//has this earnings
						//System.out.println("Name: " + strTemp);
						strTemp2 = (String)vGroupEarnings.elementAt(iIndexOf + 1);//earnings amount
						dTemp = Double.parseDouble(strTemp2); %>
						<tr>
							<td width="62%" class="thinborder"><%=strTemp%></td>
   			 				<td width="30%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat(dTemp,true)%></td>	
						</tr>
					<%}//end of else earnings exists					
				}//end of for loop for cheking detailed earnings				
				
			}else{//end of if its detailed%>
			<%
				strTemp = ((String)vEarnCols.elementAt(iCols)).toUpperCase();
				for(int ii=0; i<vOtherEarnDetails.size(); ii+=3){
					strTemp2 = vOtherEarnDetails.elementAt(ii+1).toString().toUpperCase();
					dTemp = ((Double)vOtherEarnDetails.elementAt(ii+2)).doubleValue();
			
					if( strTemp.startsWith(strTemp2) ){
						dOverAllTotal += dTemp;
						vOtherEarnDetails.remove(ii);vOtherEarnDetails.remove(ii);vOtherEarnDetails.remove(ii);
						//vOtherEarnDetails.remove(vOtherEarnDetails.elementAt(i+1));
						//vOtherEarnDetails.remove(vOtherEarnDetails.elementAt(ii+2));
						//vOtherEarnDetails.remove(vOtherEarnDetails.elementAt(ii+3));
						break;
					}
					
				}			
			%>			
				<tr>				
				  <td width="62%" class="thinborder"><%=strTemp%></td>
				  <td width="30%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat(adGEarningTotal[iCols-2],true)%></td>					
				</tr>
			<%}	
			 dOverAllTotal+=adGEarningTotal[iCols-2];
		}%>
		<tr>			
			<td width="62%" class="thinborder">OTHER EARNINGS </td>
		  	<td width="30%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%= ( bShowOtherEarnDetails ?  "&nbsp;" : CommonUtil.formatFloat(dTotalOtherEarn,true)) %></td>
		</tr>
		
		<%if( bShowOtherEarnDetails ){ 
			dTotalOtherEarn = 0d;
		%>
			<%for( int ii=0;ii<vOtherEarnDetails.size(); ii+=3 ){
				strTemp = vOtherEarnDetails.elementAt(ii+1).toString().toUpperCase();
				dTemp = ((Double)vOtherEarnDetails.elementAt(ii+2)).doubleValue();
				dTotalOtherEarn += dTemp;
			%>
		<tr>			
			<td width="62%" class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;<%=strTemp%></td>
			<td width="30%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat(dTemp,true)%></td>
		</tr>
			<%}%>
		<%}%>
		
		<tr>
			
			<td width="62%"  align="right"><strong>TOTAL &nbsp;</strong></td>
		  <td width="30%" class="thinborderBOTTOMLEFTRIGHT"><strong>&nbsp;<%=CommonUtil.formatFloat(dOverAllTotal+dTotalOtherEarn+dTotalBasic,true)%></strong></td>
		</tr>
		<tr><td colspan="3">&nbsp;</td></tr>	
		
		
		
		<tr>
			
			<td width="62%" class="thinborderTOPLEFTBOTTOM">NET PAY </td>
		  <td width="30%" class="thinborderALL">&nbsp;<%=CommonUtil.formatFloat((String)vPSheetDetails.elementAt(9),true)%></td>			
		</tr>
		<tr>
			
			<td width="62%" class="thinborder">W/ TAX </td>
		  <td width="30%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat((String)vPSheetDetails.elementAt(10),true)%></td>
		</tr>
		<tr>
			
			<td width="62%" class="thinborder">PH PREMIUM - EMPLOYEE </td>
		  <td width="30%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat((String)vPSheetDetails.elementAt(1),true)%></td>
		</tr>
		<tr>
			
			<td width="62%" class="thinborder">PAGIBIG PREMIUM - EMPLOYEE </td>
		  <td width="30%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat((String)vPSheetDetails.elementAt(2),true)%></td>
		</tr>
		<tr>
			
			<td width="62%" class="thinborder">SSS PREMIUM - EMPLOYEE </td>
		  	<td width="30%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat((String)vPSheetDetails.elementAt(0),true)%></td>
		</tr>
		<% 			
			dOverAllTotal  = Double.parseDouble(WI.getStrValue((String)vPSheetDetails.elementAt(9),"0"));
			dOverAllTotal += Double.parseDouble(WI.getStrValue((String)vPSheetDetails.elementAt(10),"0"));
			dOverAllTotal += Double.parseDouble(WI.getStrValue((String)vPSheetDetails.elementAt(1),"0"));
			dOverAllTotal += Double.parseDouble(WI.getStrValue((String)vPSheetDetails.elementAt(2),"0"));
			dOverAllTotal += Double.parseDouble(WI.getStrValue((String)vPSheetDetails.elementAt(0),"0"));
		
		//System.out.println("676 vGroupDed: " + vGroupDed);								
		int iCols2 = 1;
		for(iCols = 1;iCols <= iDedColCount; iCols +=2, iCols2++){
			
			if(arrVGroupDedDetails[iCols] != null && arrVGroupDedDetails[iCols].size() > 0 ){
				//System.out.println("681 arrVGroupDedDetails["+iCols+"]: " + arrVGroupDedDetails[iCols]);
								
				//dispaly detailed deduction for this group
				for(int iCtr2 = 0; iCtr2 < arrVGroupDedDetails[iCols].size(); iCtr2++){					
					String strTemp1 = null;
					strTemp = (String)(arrVGroupDedDetails[iCols].elementAt(iCtr2));//column name	
					iIndexOf = vGroupDed.indexOf(strTemp);		
					//System.out.println("686: " + strTemp );						
					//System.out.println("687 indexOf: " + iIndexOf);					
					if(iIndexOf < 0)//no such ded
						continue;
					else{//has this ded
						strTemp = (String)vGroupDed.elementAt(iIndexOf + 1);//ded_amount
						dTemp = Double.parseDouble(strTemp); 
						strTemp1 = ((String)arrVGroupDedDetails[iCols].elementAt(iCtr2) ).toUpperCase();
						if( strTemp1.equals("SALARY LOAN") )
							strTemp1 += " :: " + vGroupDed.elementAt(iIndexOf + 2);	
						%>
						<tr>
						
							<td width="62%" class="thinborder"><%=strTemp1%></td>
   			 				<td width="30%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat(dTemp,true)%></td>	
						</tr>
					<%}//end of else ded exists					
				}//end of for loop for cheking detailed ded				
				
			}else{//end of if its detailed
				strTemp = (String)vDedCols.elementAt(iCols);%>
				<tr>				
				  <td width="62%" class="thinborder"><%=strTemp.toUpperCase()%></td>
   				  <td width="30%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat(adDeductTotal[iCols2-1],true)%></td>			
				</tr>
			<%}
				
			dOverAllTotal += adDeductTotal[iCols2-1];
			%>			
		 	
		<%}%>	
			
		<tr>
			
			<td width="62%" align="right"><strong>TOTAL &nbsp;</strong></td>
		  <td width="30%" class="thinborderBOTTOMLEFTRIGHT"><strong><%=CommonUtil.formatFloat(dOverAllTotal,true)%></strong></td>
		</tr>
		<tr><td colspan="3">&nbsp;</td></tr>	
		
		
		
		<% dOverAllTotal = 0;%>		
			<tr>
				
				<td width="62%" class="thinborderTOPLEFTBOTTOM">PH PREMIUM - EMPLOYER</td>
			  <td width="30%" class="thinborderALL"><%=CommonUtil.formatFloat((String)vPSheetDetails.elementAt(4),true)%></td>			
			</tr>
			<tr>
				
				<td width="62%" class="thinborder">SSS EC - EMPLOYER</td>
			  <td width="30%" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat((String)vPSheetDetails.elementAt(6),true)%></td>			
			</tr>
			<tr>
				
				<td width="62%" class="thinborder">PAGIBIG PREMIUM - EMPLOYER</td>
			  <td width="30%" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat((String)vPSheetDetails.elementAt(5),true)%></td>			
			</tr>
			<tr>
				
				<td width="62%"  align="right"><strong>TOTAL &nbsp;</strong></td>
				<td width="30%" class="thinborderBOTTOMLEFTRIGHT">
					<%
						//TOTAL here
						dOverAllTotal = Double.parseDouble((String)vPSheetDetails.elementAt(4)) +  Double.parseDouble((String)vPSheetDetails.elementAt(6)) +  Double.parseDouble((String)vPSheetDetails.elementAt(5));
					
					%>
					<strong><%=CommonUtil.formatFloat(dOverAllTotal,true)%></strong>			  </td>
			</tr>
			
			
			<tr><td colspan="3">&nbsp;</td></tr>	
		
		
						
		<tr>
			
			<td width="62%"><strong>NO. OF EMPLOYEES &nbsp;</strong></td>
		  <td width="30%"><strong><%=iSearchResult%></strong></td>
		</tr>
  </table>
  
  	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="18%">&nbsp;</td>
			<td width="42%">&nbsp;</td>
			<td width="40%">&nbsp;</td>
		</tr>
		<tr>
			<td width="18%">&nbsp;</td>
			<td width="42%">&nbsp;</td>
			<td width="40%">&nbsp;</td>
		</tr>
		<tr>
			<td width="18%">&nbsp;</td>
			<td width="42%">&nbsp;</td>
			<td width="40%">&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>Prepared by: 											
				<input type="text" name="prepared_by" maxlength="128" size="32" value="<%=WI.fillTextValue("prepared_by")%>">
				<strong><label id="prepared_by_label"></label></strong>
			</td>
			
			<td>Reviewed by: 
				<input type="text" name="reviewed_by" maxlength="128" size="32" value="<%=WI.fillTextValue("reviewed_by")%>">						
				<strong><label id="reviewed_by_label"></label></strong>
		  </td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>		
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
	</table>	
  
  
	<%} //end of  if pheetdetails not null%>
	
 
	
    <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="view_all" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>