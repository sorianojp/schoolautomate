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
  TD.thinborderTOP {
    border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 13px;
  }
	
  TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }	
	
  TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;
  }
	
	TD.thinborderBOTTOMTOP {
    border-bottom: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;
  }

	TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;
  }
  TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }
	
	TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: 11px;
  }
  
	TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 11px;
  }
	
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
	}
</style>
</head> 
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage(){
	//document.form_.print_pg.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
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

		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
								 "&year_of="+strYear+"&is_weekly="+strWeekly;

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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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

function CopyTeamName(){
	if(!document.form_.team_index)
		return;
		
  if(document.form_.team_index.value)
		document.form_.team_name.value = document.form_.team_index[document.form_.team_index.selectedIndex].text;
  else
  	document.form_.team_name.value = "";
}
</script>

<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	String strUserId = (String)request.getSession(false).getAttribute("userId");
	String[] astrTaxStat   = {"N","S","H","M"};	
	boolean bolShowALL = false;
	if(strUserId != null && strUserId.equals("bricks"))
		bolShowALL = true;
	boolean bolHasTeam = false;
	boolean bolHasPeraa = false;
//add security here.


if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./psheet_grouped_eac_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Sheet (By Office)","psheet_grouped_eac.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");

		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");		
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolHasPeraa =(readPropFile.getImageFileExtn("HAS_PERAA","0")).equals("1");
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
														"psheet_grouped_eac.jsp");
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
	String strTemp2 = null;
	String strHourlyRate = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dDailyRate = 0d;
//	int iStart = 29; // this is where the null fields start
	int iFieldCount = 75;
	String strDateFrom = null;
	String strDateTo = null;
	String strBorder = "";

	double dBasic = 0d;
	double dTemp = 0d;
	double dLineTotal = 0d;
	double dLineOver = 0d;
	double dTotalOTAmount = 0d;
		
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	Vector vTaxStat = null;

	Vector vRetResult = null;
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;
	int iOT = 0;
	String strBgColor = "";

	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;
	Vector vOTDetail = null;
	
	Vector vPSheetItems = null;
	Vector vNightDiff = null;	
	Vector vSalaryInfo = null;
	Vector vDifferentialDetails = null;

	Vector vSalDetail = null;
//	Vector vLateUtDetail = null;
	Vector vOTTypes = null;
	Vector vOTType = null;//my variable.sul
	Vector vOTGroupName = overtime.operateOnOvertimeGrouping(dbOP,request,4);//group names
	Vector vOTGroup = overtime.operateOnOTGroupTypeMapping(dbOP,request,4);
	Vector vOTNoGroup = overtime.operateOnOTGroupTypeMapping(dbOP,request,5);
	Vector vOTGroupList = new Vector(); //holds the index and amount of ot w/ group  ->[type_index][amount][type_index][amount]
	Vector vOTNoGroupList = new Vector();//holds the index and amount of ot w/o group->[type_index][amount][type_index][amount]
	Vector vTemp = null;
	
	Vector vAdjTypes = null;
	Vector vEmpOT = null;
	Vector vEmpAdjust = null;
	Vector vContributions = null;
 	String strDeanName = null;
	double dOtherEarn = 0d;
	double dOtherDed  = 0d;
	String strUserIndex = null;
	int iIndex = 0;
	int iIndexOf = -1;
	int iOTCounter = 0;
	if(vOTGroupName != null && vOTGroupName.size() > 0)
			iOTCounter = vOTGroupName.size()/3;
	if(vOTNoGroup != null && vOTNoGroup.size() > 0)
			iOTCounter += vOTNoGroup.size()/3;	

	boolean bolShowHeader = true; 	
	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
	boolean bolShowBorder = false;
	int i = 0;
	vRetResult = RptPSheet.getPSheetItems(dbOP);	
	
 	if(vRetResult == null)
		strErrMsg = RptPSheet.getErrMsg();
	else{
		vRows = (Vector)vRetResult.elementAt(0);
		vEarnCols = (Vector)vRetResult.elementAt(1);
		vDedCols = (Vector)vRetResult.elementAt(2);		

		vEarnDedCols = (Vector)vRetResult.elementAt(3);			
		if(WI.fillTextValue("hide_overtime").equals("1"))
			vOTTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, true);			
		else
			vOTTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "1");
			//System.out.println("vOTTypes " + vOTTypes);
		
		if(WI.fillTextValue("hide_adjustment").equals("1"))
			vAdjTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, false);			
		else
			vAdjTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "0");
			
		vContributions = RptPSheet.checkPSheetContributions(dbOP, request, WI.fillTextValue("sal_period_index"));
		
		if(vEarnCols != null && vEarnCols.size() > 0)
			iEarnColCount = vEarnCols.size() - 2;

		if(vDedCols != null && vDedCols.size() > 0)
			iDedColCount = vDedCols.size() - 1;		

		if (vEarnDedCols != null && vEarnDedCols.size() > 0)
			iEarnDedCount = vEarnDedCols.size()- 1;
			
		iSearchResult = RptPSheet.getSearchCount();		
	}

	String[] astrContributions = {"1", "1", "1", "1", "1"};
	// 0 = sss_amt
	// 1 = philhealth_amt
	// 2 = pag_ibig
	// 3 = gsis_ps
  // 4 = peraa
	
	
	if(WI.fillTextValue("hide_contributions").equals("1") && vContributions != null){
		for(i = 0; i < vContributions.size(); i++)
			astrContributions[i] = (String)vContributions.elementAt(i);
	}	
	
	double[] adEarningTotal = new double[iEarnColCount];
	double[] adDeductTotal = new double[iDedColCount];	
	double[] adEarnDedTotal = new double[iEarnDedCount];
	String[] astrSalaryBase = {"Monthly Rate", "Daily Rate", "Hourly Rate"};

	if(WI.fillTextValue("c_index").length() > 0){
		strDeanName = dbOP.mapOneToOther("college","c_index",WI.fillTextValue("c_index"),"dean_name","");
	}

	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body onLoad="javascript:CopyTeamName();">
<form name="form_" 	method="post" action="psheet_grouped_eac.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr > 
			<td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
			PAYROLL: PAYROLL SHEET PAGE :::: </strong></font></td>
		</tr>
	</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%">Salary Period</td>
      <td width="77%"><strong>
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
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
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
				strDateFrom = (String)vSalaryPeriod.elementAt(i + 1);
				strDateTo = (String)vSalaryPeriod.elementAt(i + 2) ;
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
        <%}// check if the company has weekly salary type%></td>
    </tr>
		<%if(strSchCode.startsWith("CGH")){%>
			<input type="hidden" name="pt_ft" value="1">
		<%}else{%>
		<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td><select name="pt_ft" onChange="ReloadPage();">
        <option value="" selected>ALL</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part - time</option>
        <option value="1">Full - time</option>
        <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="0">Part - time</option>
        <option value="1" selected>Full - time</option>
        <%}else{%>
        <option value="0">Part - time</option>
        <option value="1">Full - time</option>
        <%}%>
      </select></td>
    </tr>
		<%}%>
		<%if(bolIsSchool){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td>
	   <select name="employee_category" onChange="ReloadPage();">          
          <option value="">ALL</option>
		  <option value="0">Non-Teaching</option>
        <%if (WI.fillTextValue("employee_category").equals("1")){%>
          <option value="1" selected>Teaching</option>
        <%}else if (WI.fillTextValue("employee_category").equals("0")){%>
          <option value="1">Teaching</option>
        <%}%>
       </select></td>
    </tr>
		<%}%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee Type </td>
      <td><select name="status"  onChange="ReloadPage();">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("status"), false)%>
      </select></td>
    </tr>
    <% 	
		String strCollegeIndex = WI.fillTextValue("c_index");	
		%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> <select name="c_index" onChange="document.form_.noted_by.value='';ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td> <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Office/Dept filter</td>
      <td height="10"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
(enter office/dept's first few characters)</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>Salary base </td>
			<%
				strTemp = WI.fillTextValue("salary_base");				
			%>
      <td>			
			<select name="salary_base" onChange="ReloadPage();">
				<option value="">ALL</option>
				<%for(i = 0; i < astrSalaryBase.length; i++){
					if(strTemp.equals(Integer.toString(i))){%>        
        <option value="<%=i%>" selected><%=astrSalaryBase[i]%></option>
				<%}else{%>
        <option value="<%=i%>"><%=astrSalaryBase[i]%></option>
        <%}
				}%>
      </select>
			<!--
			<select name="salary_base" onChange="ReloadPage();">
        <option value="0">Monthly rate</option>
        <%if (WI.fillTextValue("salary_base").equals("1")){%>
        <option value="1" selected>Daily Rate</option>
        <option value="2">Hourly Rate</option>
        <%} else if (WI.fillTextValue("salary_base").equals("2")){%>
        <option value="1">Daily Rate</option>
        <option value="2" selected>Hourly Rate</option>
        <%}else{%>
        <option value="1">Daily Rate</option>
        <option value="2">Hourly Rate</option>
        <%}%>
      </select>
			-->			</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Show option </td>
			<%
				strTemp = WI.fillTextValue("is_resigned");
			%>			
      <td height="10"><select name="is_resigned" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%if (strTemp.equals("1")){%>
        <option value="1" selected>Show only resigned for the period</option>
        <option value="2">Show only with valid status</option>
        <%}else if (strTemp.equals("2")){%>
        <option value="1">Show only resigned for the period</option>
        <option value="2"selected>Show only with valid status</option>
        <%}else{%>
        <option value="1">Show only resigned for the period</option>
        <option value="2">Show only with valid status</option>
        <%}%>
      </select></td>
    </tr>
 		<%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>      </td>
    </tr>
		<%}%>
    <%if(bolHasConfidential){%>
		<tr>
      <td height="10">&nbsp;</td>
      <td height="10">Process Option </td>
			<%
			String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";				
			%>
      <td height="10"><select name="group_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group " +
													" where exists(select user_index from pr_group_proc " +
													" 	where pr_preload_group.group_index = pr_group_proc.group_index " +
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%>
      </select></td>
    </tr>
		<%}%>		
		<%if(bolShowALL || iAccessLevel == 2){%>
		<tr>
		  <td height="10">&nbsp;</td>
		  <td>Employee ID </td>
		  <td><input name="emp_id" type="text" size="16"maxlength="128" value="<%=WI.fillTextValue("emp_id")%>"
											onKeyUp="AjaxMapName(1);"><label id="coa_info"></label>	</td>
	  </tr>
		<%}%>
		<tr>
		  <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_earnings");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>
		  <td height="10" colspan="2"><input type="checkbox" name="hide_earnings" value="1" <%=strTemp%>>
		  hide earning column without value </td>
	  </tr>
		<tr>
		  <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_deductions");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>
		  <td height="10" colspan="2"><input type="checkbox" name="hide_deductions" value="1" <%=strTemp%>>
	    hide deduction column without value </td>
	  </tr>
		<tr>
		  <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_overtime");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>			
		  <td height="10" colspan="2"><input type="checkbox" name="hide_overtime" value="1" <%=strTemp%>>
hide overtime column without value </td>
	  </tr>
		<tr>
		  <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_adjustment");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>			
		  <td height="10" colspan="2"><input type="checkbox" name="hide_adjustment" value="1" <%=strTemp%>>
hide adjustment column without value </td>
	  </tr>
		<tr>
		  <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_contributions");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>			
		  <td height="10" colspan="2"><input type="checkbox" name="hide_contributions" value="1" <%=strTemp%>>
hide contribution column without value </td>
	  </tr>		
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_emp_id");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>						
      <td height="10" colspan="2"><input type="checkbox" name="show_emp_id" value="1" <%=strTemp%>>
show Employee ID </td>
    </tr>
	<tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_tax_stat");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>						
		<td height="10" colspan="2"><input type="checkbox" name="show_tax_stat" value="1" <%=strTemp%>>&nbsp;show Employee Tax Status </td>
    </tr>
	
		<tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_monthly");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>						
      <td height="10" colspan="2"><input type="checkbox" name="show_monthly" value="1" <%=strTemp%>>
			show Monthly Rate/ Basic Salary </td>
    </tr>		
		<tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_per_hour");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>						
      <td height="10" colspan="2"><input type="checkbox" name="show_per_hour" value="1" <%=strTemp%>>
			show Rate per Hour and Rate Per Day </td>
    </tr>				
    <tr> 
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_border");
				if(strTemp.length() > 0){
					strTemp = "checked";
					bolShowBorder = true;
				}else{
					strTemp = "";					
					bolShowBorder = false;
				}
			%>
      <td height="10" colspan="2"><input type="checkbox" name="show_border" value="1" <%=strTemp%>> 
        show border</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_leave_amount");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>					
      <td height="10" colspan="2"><input type="checkbox" name="show_leave_amount" value="1" <%=strTemp%>>
show leave w/pay in amount </td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="3%" height="10">&nbsp;</td>
      <td width="13%" height="10">&nbsp;</td>
      <td width="84%" height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><font size="1">
        <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
        click to display employee list to print.</font></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Prepared By</td>
			<%
				strTemp = WI.fillTextValue("prepared_by");
				if(strTemp.length() == 0)
					strTemp = CommonUtil.getNameForAMemberType(dbOP,"Payroll/HR Personnel",7);
				if( strTemp == null || strTemp.length() == 0)
					strTemp = (String)request.getSession(false).getAttribute("first_name");
			%>			
      <td height="10">
			<input type="text" name="prepared_by" maxlength="128" size="32" 
			value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Reviewed By</td>			
			<%
				strTemp = WI.fillTextValue("reviewed_by");
				if(strTemp.length() == 0)
					strTemp = CommonUtil.getNameForAMemberType(dbOP,"Assistant for Administrative Affairs",7);
				strTemp = WI.getStrValue(strTemp);
			%>						
      <td height="10"><input type="text" name="reviewed_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Noted By </td>
			<%
				strTemp = WI.fillTextValue("noted_by");				
				if(strTemp.length() == 0)
					strTemp = strDeanName;
				strTemp = WI.getStrValue(strTemp);
			%>			
      <td height="10"><input type="text" name="noted_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
    </tr>
    
    <tr>
      <td height="10">&nbsp;</td>
      <td>Report Title </td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("report_title"),"PAYROLL SHEET");
			%>
      <td><input type="text" name="report_title" maxlength="128" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
 	  <% if (vRows != null && vRows.size() > 0 ){%>
      <td height="10" colspan="2"><div align="right"><font size="2">Number of Employees / rows Per 
          Page :</font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"25"));
			for(i = 15; i <=30 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a>
          <font size="1">click to print</font></div></td>
	   <%}%>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("size_header");
				if(strTemp.length() == 0)
					strTemp = "10";
			%>
      <td height="10" colspan="2" align="right"><font size="2">Font size of header:
          <select name="size_header">	
					<%for(i = 8; i < 13; i++){%>
						<%if(strTemp.equals(Integer.toString(i))){%>
            <option value="<%=i%>" selected><%=i%> px</option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> px</option>
            <%}
						}%>
          </select>
      </font></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("font_size");
				if(strTemp.length() == 0)
					strTemp = "10";
			%>
      <td height="10" colspan="2" align="right"><font size="2">Font size of details:
          <select name="font_size">
            <%for(i = 8; i < 13; i++){%>
            <%if(strTemp.equals(Integer.toString(i))){%>
            <option value="<%=i%>" selected><%=i%> px</option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> px</option>
            <%}
						}%>
          </select>
      </font></td>
    </tr>
  </table>
  <% if (vRows != null && vRows.size() > 0 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="23"> <%
		int iPageCount = iSearchResult/RptPSheet.defSearchSize;
		if(iSearchResult % RptPSheet.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="24" colspan="28" align="center" ><strong><font color="#0000FF"> <%=WI.fillTextValue("report_title")%> FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>
    <tr>
      <%if(WI.fillTextValue("show_emp_id").length() > 0){%>
			<td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">ID</td>
			<%}%>
      <td width="7%" height="33" rowspan="2" align="center" class="thinborderBOTTOM">NAME 
        OF EMPLOYEE	  </td>
	  <%if(WI.fillTextValue("show_tax_stat").length() > 0){%>
	  	<td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">TAX STATUS </td>
	  <%}%>
	  <%if(WI.fillTextValue("show_monthly").length() > 0){%>		
      <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">&nbsp;BASIC SALARY </td>
			<%}%>
      <!--
      <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">BASIC</td>
			-->
      <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">BASIC PAY </td>			
			<%if(WI.fillTextValue("show_per_hour").length() > 0){%>			
			<td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">RATE PER DAY </td>
      <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">RATE PER HOUR</td>
			<%}%>
      <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">Late/UT / Absence</td>
      <!--
			<td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">Absence</td>
			-->
      <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">Leave w/ pay </td>
	  <!-- 20130705 -->
	  <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">Night <br>Diff.<br>(hours)</td>
	  <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">Night <br>Diff.<br>(Amount).</td>
	  <!-- end 20130705 -->
	  <td width="36" colspan="<%=iOTCounter%>" align="center" class="thinborderBOTTOM">OVERTIME<br></td>		
      <%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			for(iOT = 0; iOT < vAdjTypes.size(); iOT+=19){
				// added to basic-- if != 1 meaning not added sa pikas side ibutang and adjustment
				if(!((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;
				strTemp = (String)vAdjTypes.elementAt(iOT+1);
				if(!strSchCode.startsWith("TAMIYA"))
					strTemp += "<br>"+ CommonUtil.formatFloat((String)vAdjTypes.elementAt(iOT+3),false);
			%>
     <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM"><%=strTemp%>*</td> 
      <%}
			}%>	    
      <%	  	
		if(vOTTypes != null && vOTTypes.size() > 0){
			
				for(iOT = 0; iOT < vOTTypes.size(); iOT+=19){
					strTemp = (String)vOTTypes.elementAt(iOT+1);
					if(!strSchCode.startsWith("TAMIYA"))
						strTemp += "<br>"+ CommonUtil.formatFloat((String)vOTTypes.elementAt(iOT+3),false);
					%>
     			 	<!--<td width="3%" rowspan="2" align="center" class="thinborderBOTTOM">&nbsp;<%=strTemp%></td>orig ot names-->
     		 <%	}//end of loop		
	 	}//end of if has vOTTypes%>
      <%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			for(iOT = 0; iOT < vAdjTypes.size(); iOT+=19){
				if(((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;			
				strTemp = (String)vAdjTypes.elementAt(iOT+1);
				if(!strSchCode.startsWith("TAMIYA"))
					strTemp += "<br>"+ CommonUtil.formatFloat((String)vAdjTypes.elementAt(iOT+3),false);
			%>
      <td width="3%" rowspan="2" align="center" class="thinborderBOTTOM">&nbsp;<%=strTemp%>*</td><!-- adjustment..sul -->
      <%}
			}%>
      <%if(!bolIsSchool){%>
      <td width="6%" rowspan="2" align="center" class="thinborderBOTTOM">NP</td>
      <%}%>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
      <td width="4%" colspan="2" align="center" class="NoBorder">OVERLOAD</td>
      <%}%>
      <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
      <td rowspan="2" align="center" class="thinborderBOTTOM"><%=(String)vEarnCols.elementAt(iCols)%></td>
      <%}%>
      <%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td rowspan="2" align="center" class="thinborderBOTTOM"><%=(String)vEarnDedCols.elementAt(iCols)%></td>
      <%}%>     
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOM">TOTAL GROSS PAY</td>
	  <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">TAX</td>
      <%if(astrContributions[0].equals("1")){%>
      <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">SSS</td>
      <%} if(astrContributions[1].equals("1")){%>
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOM">PHIC</td>
      <%}if(astrContributions[2].equals("1")){%>
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOM">HDMF</td>
      <%}if(astrContributions[4].equals("1") && bolIsSchool){%>
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOM">PERAA</td>
      <%}%>
			<%			
			for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>
      <td rowspan="2" align="center" class="thinborderBOTTOM"><%=strTemp%></td>
      <%}%>
      <td width="6%" rowspan="2" align="center" class="thinborderBOTTOM">OTHER DED.</td>
      <td width="6%" rowspan="2" align="center" class="thinborderBOTTOM">NET PAY</td>
    </tr>
    <tr> 
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
      <td width="4%" align="center" class="thinborderBOTTOM">Rate</td>
      <td width="4%" align="center" class="thinborderBOTTOM">Amount</td>
      <%}%>
	  
	  <%
			/////////////////// start of OT names \\\\\\\\\\\\\\\\\\\	
				if(vOTGroupName != null && vOTGroupName.size() > 0){					
					vTemp = new Vector();
					//print the group name					
					for(iCols = 0;iCols < vOTGroupName.size(); iCols+=3){						
						//save the ot_type_index
						vTemp = overtime.getOTTypeIndexInTheGroup(dbOP,request,(String)vOTGroupName.elementAt(iCols));
						if(vTemp != null && vTemp.size() > 0){
							vOTGroupList.addElement(vTemp);
							vOTGroupList.addElement("0");
						}						
					%>
						<td align="center" class="thinborderBOTTOM">&nbsp;<%=(String)vOTGroupName.elementAt(iCols+1)%></td>
					<%}//end of for loop	 
							
				}//end of if there is group%>
				
				<%				
				if(vOTNoGroup != null && vOTNoGroup.size() > 0){
					//print the ot w/o group
					for(iCols = 0;iCols < vOTNoGroup.size(); iCols+=3){
						//save the ot_type_index						
						vOTNoGroupList.addElement((String)vOTNoGroup.elementAt(iCols));
						vOTNoGroupList.addElement("0");						
					%>
						<td align="center" class="thinborderBOTTOM">&nbsp;<%=(String)vOTNoGroup.elementAt(iCols+1)%></td>
					<%}//end of for loop
				}//end of if nogroup
				
				///////////////////// end of OT names \\\\\\\\\\\\\\\\\\\\\\\\
				%>
    </tr>
	
	
    <% 
    for(i = 0; i < vRows.size();){	
		if(bolShowHeader){
		bolShowHeader = false;
	  %>
    <tr>
      <%
			if(bolIsSchool)
				strTemp = "College : ";
			else
				strTemp = "Division : ";
				
			strTemp2 = (String)vRows.elementAt(i+63);
			strTemp2 = WI.getStrValue(strTemp2," Dept : ","","");
	
			if(bolShowBorder)
				strBorder =  "class='thinborderBottomLeftRight'";
			else
				strBorder = "class='NoBorder'";
			%>
      <td height="26" colspan="54" valign="bottom" <%=strBorder%>><strong>&nbsp;<%=(WI.getStrValue((String)vRows.elementAt(i+62),strTemp, strTemp2, strTemp2)).toUpperCase()%></strong> </td>
    </tr>
    <%}%>
		
    <%for(; i < vRows.size();){
			if(i % 150 == iFieldCount){
				strBgColor = "#EEEEEE";
			}else{
				strBgColor = "";
			}	
 	strUserIndex = (String)vRows.elementAt(i+1);
	if(i+iFieldCount+1 < vRows.size()){
		if(i == 0){
		strCurColl = WI.getStrValue((String)vRows.elementAt(i+2),"0");		
		strCurDept = WI.getStrValue((String)vRows.elementAt(i+3),"0");	
		}
		strNextColl = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 2),"0");		
		strNextDept = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 3),"0");		
 		
		if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
			bolShowHeader = true;
		} 
	}
  	vEarnings = (Vector)vRows.elementAt(i+53);
	vDeductions = (Vector)vRows.elementAt(i+54);
	vSalDetail = (Vector)vRows.elementAt(i+55); 
	vOTDetail = (Vector)vRows.elementAt(i+56);
	vEarnDed  = (Vector)vRows.elementAt(i+59);		
	//vLateUtDetail = (Vector)vRows.elementAt(i+64);
	vEmpOT = (Vector)vRows.elementAt(i+65);
	vOTType = (Vector)vRows.elementAt(i+65);	
	vEmpAdjust = (Vector)vRows.elementAt(i+67);
	dLineOver = 0d;
	dLineTotal = 0d;
	dBasic = 0d;
 	dOtherEarn = 0d;
	dOtherDed = 0d;
	dTotalOTAmount = 0d;
		%>
    <tr bgcolor="<%=strBgColor%>">
      <%
	  strTemp = (String)vRows.elementAt(i + 60);
	  request.setAttribute("emp_id", strTemp);

  	  vPSheetItems = RptPSheet.getPSheetItems(dbOP, request, WI.fillTextValue("sal_period_index"));	  
	  vNightDiff = RE.generateNightDifferentialReport(dbOP);
	  vSalaryInfo = RptPay.getSalaryInfo(dbOP, false);
	  vTaxStat  = prTaxStat.operateOnTaxStatus(dbOP, request,4);
	  
	  if(WI.fillTextValue("show_emp_id").length() > 0){%>
			<td valign="bottom" nowrap <%=strBorder%>>&nbsp;<%=WI.getStrValue(strTemp)%></td>
			<%}
			
			%>
      <%				
				if(bolShowBorder)
					strBorder =  "class='thinborder'";
				else
					strBorder = "class='NoBorder'";
			%>
      <td height="24" valign="bottom" nowrap <%=strBorder%>><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong>	  </td>
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
			strTemp = (String)vRows.elementAt(i + 70);
			strTemp = WI.getStrValue(strTemp, "0");
 			if(strTemp.equals("0"))
				strTemp = "&nbsp;";
  	  %>					
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
			<%}%>
      <%
				// period rate
				dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));
				// System.out.println("dLineTotal " + dLineTotal);
				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dLineTotal,true)%></td>			
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
			//strTemp = CommonUtil.formatFloat(dTemp,true);
			
			//dLineTotal -= dTemp;
			//if(dTemp == 0d)
			//	strTemp = "";
			%>
      <!--
			<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%>&nbsp;</td>
			-->
      <%			
			//dTemp = 0d;
			dTemp = 0d;
			// late_under_amt
			strTemp = (String)vRows.elementAt(i + 48); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		
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
			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
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
				//}
				if(vNightDiff != null){
					vDifferentialDetails = (Vector) vNightDiff.elementAt(6);
					if( vDifferentialDetails != null ){
						dTemp = Double.parseDouble((String)vDifferentialDetails.elementAt(0)) + Double.parseDouble((String)vDifferentialDetails.elementAt(2));
						strTemp = dTemp+"";
					}
				}else if(vOTDetail != null && vOTDetail.size() > 0){
					strTemp = (String)vOTDetail.elementAt(4);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				}
				
				if(dTemp == 0d)
					strTemp = "--";
			%>  
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%
				// night differential amount
				//strTemp = (String)vRows.elementAt(i + 24);  	
				//dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				//dLineOver += dTemp;
				dTemp =0d;
				if(vNightDiff != null){
					vDifferentialDetails = (Vector) vNightDiff.elementAt(6);
					if( vDifferentialDetails != null ){
						dTemp = Double.parseDouble((String)vDifferentialDetails.elementAt(1)) + Double.parseDouble((String)vDifferentialDetails.elementAt(3));	
						dLineOver += dTemp;
						strTemp = dTemp+"";
					}
				}//else{
					//strTemp = (String)vRows.elementAt(i + 24);  	
					//dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
					//dLineOver += dTemp;
				//}
				
				if(dTemp == 0d)
					strTemp = "--";
			%>      
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
	  <!-- end 20130705 -->	  
		<%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			 for(iOT = 0;iOT < vAdjTypes.size(); iOT+=19){
				if(!((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;
			 		
				 strTemp = null;
				 iIndex = vEmpAdjust.indexOf((Integer)vAdjTypes.elementAt(iOT));
				 if(iIndex != -1){
					 strTemp = (String)vEmpAdjust.elementAt(iIndex+2);					 
				 }

				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				//dLineTotal += dTemp;
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
					strTemp = "";
			%>
			
			<%
			/////////////////////// OT GROUP value \\\\\\\\\\\\\\\\\\\\\\\\	
			if(vOTGroupList != null && vOTGroupList.size() > 0){				
						for(int iCtr = 0 ; iCtr < vOTGroupList.size(); iCtr+=2)
							vOTGroupList.setElementAt("0",iCtr + 1);//initialize all values to zero -GROUP
			}	
			
			if(vOTNoGroupList != null && vOTNoGroupList.size() > 0){				
					for(int iCtr = 0 ; iCtr < vOTNoGroupList.size(); iCtr+=2)
						vOTNoGroupList.setElementAt("0",iCtr + 1);//initialize all values to zero - NO GROUP
			}
			
			if(vOTType != null && vOTType.size() > 0){			
				
				for(iCols = 0;iCols < vOTType.size(); iCols +=3){		
					dTemp = 0;	
					iIndexOf = -1;
					strTemp = WI.getStrValue((vOTType.elementAt(iCols).toString()),"0");
					//check if ot is in the group			
					if(vOTGroupList != null && vOTGroupList.size() > 0){				
						for(int iCtr = 0 ; iCtr < vOTGroupList.size(); iCtr+=2){
							vTemp = (Vector)vOTGroupList.elementAt(iCtr);
							iIndexOf = vTemp.indexOf(strTemp);					
							if(iIndexOf != -1){
								dTemp = Double.parseDouble((String)vOTGroupList.elementAt(iCtr + 1));//current amount of ot in the group
								dTemp += Double.parseDouble(WI.getStrValue((String)vOTType.elementAt(iCols+2),"0"));						
								vOTGroupList.setElementAt(CommonUtil.formatFloat(dTemp,2),iCtr + 1);
								break;
							}
						}//end of for loop w/ group					
						//System.out.println("vOTGroupList: " + vOTGroupList);
					}
					
					//System.out.println("----vOTNoGroupList: " + vOTNoGroupList);			
					//check if ot is not in the group
					if(vOTNoGroupList != null && vOTNoGroupList.size() > 0){				
						iIndexOf = vOTNoGroupList.indexOf(strTemp);
						if(iIndexOf != -1){
							vOTNoGroupList.setElementAt((String)vOTType.elementAt(iCols+2),iIndexOf + 1);
						}
					}		
				}//end of for loop	
			}//end of OT List	
			
			if(vOTGroupList != null && vOTGroupList.size() > 0){
				for(iCols = 0;iCols < vOTGroupList.size(); iCols +=2){
					//dTemp = Double.parseDouble(WI.getStrValue((String)vOTGroupList.elementAt(iCols+1),"0"));
					//dTemp = Double.parseDouble((String)vRows.elementAt(i+23));
					strTemp = (String)vPSheetItems.elementAt(7);
					dTemp = Double.parseDouble(strTemp);
					
					if(dTemp > 0d)
						strTemp = CommonUtil.formatFloat(dTemp+"",true);		
					else
						strTemp = "&nbsp;";
					%>
					 <!-- overtime -->
					 <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>					 
				  <%}//end of for loop
			}//end of if group
			
			if(vOTNoGroupList != null && vOTNoGroupList.size() > 0){		  	  
				 for(iCols = 0;iCols < vOTNoGroupList.size(); iCols +=2){	
					dTemp = Double.parseDouble(WI.getStrValue((String)vOTNoGroupList.elementAt(iCols+1),"0"));
					if(dTemp > 0d)
						strTemp = "" + dTemp;		
					else
						strTemp = "&nbsp;";
					%>
					 <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
				 <%}//end of for loop
			}//end of no group
			
			////////////////////// end of OT group value \\\\\\\\\\\\\\\\\\\\\\
			
		
			// OVERTIME amount
			//strTemp = (String)vRows.elementAt(i + 23);  	
			//dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
			//dLineTotal += dTemp;
			//strTemp = CommonUtil.formatFloat(dTemp,true);
			//if(dTemp == 0d)
			//	strTemp = "";
			%>
      <%
			if(vOTTypes != null && vOTTypes.size() > 0){
				//System.out.println("vEmpOT " + vEmpOT);
			 	for(iOT = 0;iOT < vOTTypes.size(); iOT+=19){
				 	strTemp = null;
				 	iIndex = vEmpOT.indexOf((Integer)vOTTypes.elementAt(iOT));
				 	if(iIndex != -1){
					 	strTemp = (String)vEmpOT.elementAt(iIndex+2);					 
				 	}

					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dLineTotal += dTemp;
					dTotalOTAmount += dTemp;
					strTemp = CommonUtil.formatFloat(dTemp,true);
					if(dTemp == 0d)
						strTemp = "&nbsp;";
					
					%>     				
						<!--<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td> orig ot names-->
      			<%
				}//end of for loop										
												
			} //end of OTWithTypes %>
      <%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			 for(iOT = 0;iOT < vAdjTypes.size(); iOT+=19){
				if(((String)vAdjTypes.elementAt(iOT+11)).equals("1"))
					continue;
								 
				 strTemp = null;
				 iIndex = vEmpAdjust.indexOf((Integer)vAdjTypes.elementAt(iOT));
				 if(iIndex != -1){
					 strTemp = (String)vEmpAdjust.elementAt(iIndex+2);					 
				 }

				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
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
 			if(!bolIsSchool){%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
      <%}%>
      <%
			if(bolIsSchool)
				dOtherEarn += dTemp;
			%>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
      <%
	  	//rate per hour
				strTemp = "";
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp = (String)vSalDetail.elementAt(3);
  	  %>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%>&nbsp;</td>
      <%
			// overload
			strTemp = (String)vRows.elementAt(i + 22);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%>&nbsp;</td>
      <%}%>
      <%for(iCols = 2;iCols <= iEarnColCount +1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dLineTotal += dTemp;
			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%}%>
      <%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				if(strTemp.equals("0"))
					strTemp = "";			
			%>
      <td width="7%" align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp,"")%></td>
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
	  if ((vAdjTypes == null || vAdjTypes.size() == 0) && 
			vRows.elementAt(i+51) != null){	
			strTemp = (String)vRows.elementAt(i+51); 
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
		strTemp = CommonUtil.formatFloat(dOtherEarn,2);
		if(dOtherEarn == 0d)
			strTemp = "";
		
		// overwrite gross 
		// select direct to db
		if( vSalaryInfo != null ){
			strTemp = ((String)vSalaryInfo.elementAt(5)).replaceAll(",", "");
			strTemp = CommonUtil.formatFloat(Double.parseDouble(strTemp), true);
		}
		else
			strTemp = CommonUtil.formatFloat(dLineTotal,true);
			
			
	  %>     
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(Double.parseDouble(strTemp.replaceAll(",", "")),true)%>&nbsp;</td>
      <%
				// tax withheld
				strTemp = (String)vRows.elementAt(i + 46);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%>&nbsp;</td>
      <%if(astrContributions[0].equals("1")){
				// sss contribution
				strTemp = (String)vRows.elementAt(i + 39);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);														
				dLineTotal -= dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%>&nbsp;</td>
      <%}%>
      <%if(astrContributions[1].equals("1")){
				// philhealth
				strTemp = (String)vRows.elementAt(i + 40);			
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%>&nbsp;</td>
      <%}%>
      <%if(astrContributions[2].equals("1")){
				// pag ibig
				strTemp = (String)vRows.elementAt(i +41);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%>&nbsp;</td>
      <%}%>
      <%if(astrContributions[4].equals("1") && bolIsSchool){
				// pag ibig
				strTemp = (String)vRows.elementAt(i +43);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%>&nbsp;</td>
      <%}%>			
      <%for(iCols = 1;iCols <= iDedColCount/2; iCols ++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
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
			if(dOtherDed == 0d)
				strTemp = "";
	  %>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%>&nbsp;</td>
      <%				
				if(bolShowBorder)
					strBorder =  "class='thinborderBottomLeftRight'";
				else
					strBorder = "class='NoBorder'";
			%>			
			<%
				
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
			%>
			
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(strTemp,true)%></td>
    </tr>
    <% 
     i = i + iFieldCount;  	
	 if(i < vRows.size()){
		 strCurColl = WI.getStrValue((String)vRows.elementAt(i+2),"0");
		 strCurDept = WI.getStrValue((String)vRows.elementAt(i+3),"0");
	 }	 
  	 
	if(bolShowHeader){
		break;
	}

  %>
    <%}//end for loop %>
    <%
	 }// end outer for loop... for office name
		%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="is_grouped" value="1">
	<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
	<input type="hidden" name="date_from" value="<%=WI.getStrValue(strDateFrom)%>">  
	<input type="hidden" name="date_to" value="<%=WI.getStrValue(strDateTo)%>">  
  <input type="hidden" name="print_pg" value="">  
	<input type="hidden" name="team_name" value="<%=WI.fillTextValue("team_name")%>">
	<!-- this ot type is to get the overtime types in the table only
			naka share man gud ang table sa types of adjustment og ang table sa overtime types
			if zero or blank ni. and adjustment types ang i return sa system. 	
			// had to hide this one also... kailangan sad nako mapagawas ang adjustment columns
			<input type="hidden" name="ot_type" value="1">  	
			
	-->
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>