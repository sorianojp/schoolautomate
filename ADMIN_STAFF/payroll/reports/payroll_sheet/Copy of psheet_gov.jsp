<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, 
																payroll.PReDTRME, payroll.OvertimeMgmt" buffer="16kb"%>
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
  TD.detail_style {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("header_size"), "12")%>.px;
  }	
	
  TD.header_style {
		border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("header_size"), "12")%>.px;
  }

</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_pg.value="";
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
</script>

<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	String strAmt = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	String strUserId = (String)request.getSession(false).getAttribute("userId");	
	boolean bolShowALL = false;
	if(strUserId != null && strUserId.equals("bricks"))
		bolShowALL = true;
	boolean bolHasTeam = false;
	boolean bolHasPeraa = false;
//add security here.


if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./psheet_gov_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Sheet (By Office)","psheet_gov.jsp");
								
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
														"psheet_gov.jsp");
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
	String strTemp2 = null;
	String strHourlyRate = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dDailyRate = 0d;
//	int iStart = 29; // this is where the null fields start
	int iFieldCount = 75;
	String strDateFrom = null;
	String strDateTo = null;

	double dBasic = 0d;
	double dTemp = 0d;
	double dLineTotal = 0d;
	double dTotalDed = 0d;
		
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;

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
	Vector vSalDetail = null;
//	Vector vLateUtDetail = null;
	Vector vOTTypes = null;
	Vector vAdjTypes = null;
	Vector vEmpOT = null;
	Vector vEmpAdjust = null;
	Vector vContributions = null;
 	String strDeanName = null;
	double dOtherEarn = 0d;
	double dOtherDed  = 0d;
	String strUserIndex = null;
	int iIndex = 0;

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
	double dNetPay  = 0d;
	
	String[] astrSalaryBase = {"Monthly Rate", "Daily Rate", "Hourly Rate"};

	if(WI.fillTextValue("c_index").length() > 0){
		strDeanName = dbOP.mapOneToOther("college","c_index",WI.fillTextValue("c_index"),"dean_name","");
	}

	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body>
<form name="form_" 	method="post" action="psheet_gov.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr > 
			<td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
			PAYROLL: PAYROLL SHEET PAGE ::::</strong></font></td>
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
      <td><select name="select" onChange="ReloadPage();">
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
          <option value="0">Non-Teaching</option>
        <%if (WI.fillTextValue("employee_category").equals("1")){%>
          <option value="1" selected>Teaching</option>
        <%}else{%>
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
      <td> <select name="c_index" onChange="ReloadPage();">
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
      <td height="10">Signatory 1 </td>
			<%
				strTemp = WI.fillTextValue("signatory_1");
			%>			
      <td height="10">
			<input type="text" name="signatory_1" maxlength="128" size="32" 
			value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Position</td>
			<%
				strTemp = WI.fillTextValue("position_1");
				if(strTemp.length() == 0)
					strTemp = "Chief Administrative Officer";				
			%>					
      <td height="10"><input type="text" name="position_1" maxlength="128" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td height="10" colspan="3"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Signatory 2 </td>			
			<%
				strTemp = WI.fillTextValue("signatory_2");
				strTemp = WI.getStrValue(strTemp);
			%>						
      <td height="10"><input type="text" name="signatory_2" maxlength="128" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Position</td>
			<%
				strTemp = WI.fillTextValue("position_2");
				if(strTemp.length() == 0)
					strTemp = "Director III";					
			%>					
      <td height="10"><input type="text" name="position_2" maxlength="128" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td height="10" colspan="3"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Signatory 3 </td>
			<%
				strTemp = WI.fillTextValue("signatory_3");				
				strTemp = WI.getStrValue(strTemp);
			%>			
      <td height="10"><input type="text" name="signatory_3" maxlength="128" size="32" value="<%=strTemp%>"></td>
    </tr>
    
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Position</td>
			<%
				strTemp = WI.fillTextValue("position_3");
				if(strTemp.length() == 0)
					strTemp = "Accountant III";					
			%>					
      <td height="10"><input type="text" name="position_3" maxlength="128" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td height="10" colspan="3"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>Signatory 4 </td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("signatory_4"));
			%>
      <td><input type="text" name="signatory_4" maxlength="64" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Position</td>
			<%
				strTemp = WI.fillTextValue("position_4");
				if(strTemp.length() == 0)
					strTemp = "Cashier III";					
			%>					
      <td height="10"><input type="text" name="position_4" maxlength="128" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
 	  <% if (vRows != null && vRows.size() > 0 ){%>
      <td height="10" colspan="2"><div align="right"><font size="2">Number of Employees / rows Per 
          Page :</font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"25"));
			for(i = 3; i <=10 ; i++) {
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
				strTemp = WI.fillTextValue("header_size");
				if(strTemp.length() == 0)
					strTemp = "10";
			%>
      <td height="10" colspan="2" align="right"><font size="2">Font size of header:
          <select name="header_size">	
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
				strTemp = WI.fillTextValue("detail_size");
				if(strTemp.length() == 0)
					strTemp = "10";
			%>
      <td height="10" colspan="2" align="right"><font size="2">Font size of details:
          <select name="detail_size">
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
      <td height="24" colspan="10" align="center" ><strong><font color="#0000FF"> <%=WI.fillTextValue("report_title")%> FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>
    <tr>
      <td width="7%" height="33" align="center" class="header_style">NAME 
        OF EMPLOYEE </td>
      <td width="4%" align="center" nowrap class="header_style">PERIOD OF SERVICE<br>
        FROM -- TO </td>
      <td width="4%" align="center" class="header_style">MONTHLY SALARY </td>
      <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
			<td width="5%" align="center" class="header_style"><%=(String)vEarnCols.elementAt(iCols)%></td>
			<%}%>
      <td width="5%" align="center" class="header_style">TOTAL SALARY </td>
      <td width="4%" align="center" class="header_style">TOTAL DEDUCTIONS </td>
      <td width="6%" align="center" class="header_style">NET AMOUNT DUE </td>
      <td width="6%" align="center" class="header_style">AMOUNT PAID IN CASH </td>
      <td width="6%" align="center" class="header_style">NO</td>
    </tr>
    
    <% 
	if (vRows != null && vRows.size() > 0 ){
      for(i = 0; i < vRows.size();){	
	%> 
    <%for(; i < vRows.size();){
			if(i % 150 == iFieldCount){
				strBgColor = "#EEEEEE";
			}else{
				strBgColor = "";
			}	
 	strUserIndex = (String)vRows.elementAt(i+1);
  vEarnings = (Vector)vRows.elementAt(i+53);
	vDeductions = (Vector)vRows.elementAt(i+54);
	vSalDetail = (Vector)vRows.elementAt(i+55); 
	vOTDetail = (Vector)vRows.elementAt(i+56);
	vEarnDed  = (Vector)vRows.elementAt(i+59);		
	//vLateUtDetail = (Vector)vRows.elementAt(i+64);
	vEmpOT = (Vector)vRows.elementAt(i+65);
	vEmpAdjust = (Vector)vRows.elementAt(i+67);
	dLineTotal = 0d;
	dBasic = 0d;
 	dOtherEarn = 0d;
	dOtherDed = 0d;
	dTotalDed = 0d;
		%>
    <tr bgcolor="<%=strBgColor%>">
      <td height="24" valign="bottom" nowrap class="detail_style" ><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong></td>
			<td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
			<%
	  	//monthly rate
			strTemp = (String)vRows.elementAt(i + 70);
			strTemp = WI.getStrValue(strTemp, "0");
 			if(strTemp.equals("0"))
				strTemp = "&nbsp;";
				
			// period rate
			dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));
				
  	  %>					
      <td align="right" valign="bottom" class="detail_style" ><%=strTemp%></td>
      <%for(iCols = 2;iCols <= iEarnColCount +1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);
			dTemp = Double.parseDouble(strTemp);
			dLineTotal += dTemp;
			 
			if(dTemp == 0d)
				strTemp = "";
			%>			
      <td align="right" valign="bottom" class="detail_style" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%}%>
      <%
 				// System.out.println("dLineTotal " + dLineTotal);
				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
			%>
      <td align="right" valign="bottom" class="detail_style" ><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
      <td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
      <%				
				strTemp = (String)vRows.elementAt(i+52);
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dNetPay = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			%>			
      <td align="right" valign="bottom" class="detail_style" ><%=CommonUtil.formatFloat(strTemp,true)%></td>
      <td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
      <td align="right" valign="bottom" class="detail_style" >&nbsp;</td>
    </tr>
    <tr bgcolor="<%=strBgColor%>">
      <td height="24" valign="bottom" nowrap >&nbsp;</td>
      <td colspan="2" align="right" valign="bottom" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <%if(astrContributions[3].equals("1")){
					// GSIS
					strTemp = (String)vRows.elementAt(i + 42);			
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
					strTemp = CommonUtil.formatFloat(strTemp,true);
					dTotalDed += dTemp;
					if(dTemp == 0d)
						strTemp = "--";				
				%>
				<tr>
          <td width="43%" class="detail_style" >GSIS PREMIUM </td>
          <td width="24%"  align="right" class="detail_style"><%=strTemp%></td>
          </tr>
				<%}%>
				<%if(astrContributions[1].equals("1")){
					// philhealth
					strTemp = (String)vRows.elementAt(i + 40);			
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
					strTemp = CommonUtil.formatFloat(strTemp,true);
					dTotalDed += dTemp;
					if(dTemp == 0d)
						strTemp = "--";
				%>				
        <tr>
          <td class="detail_style" >PHIC</td>
          <td align="right" class="detail_style" ><%=strTemp%></td>
          </tr>
				<%}%>
				<%if(astrContributions[2].equals("1")){
				// pag ibig
				strTemp = (String)vRows.elementAt(i +41);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dTotalDed += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
        <tr>
          <td class="detail_style" >PAG-IBIG FUND </td>
          <td align="right" class="detail_style" ><%=strTemp%></td>
          </tr>
				<%}%>
        <tr>
          <td class="detail_style" >W/TAX</td>
					<%
						// tax withheld
						strTemp = (String)vRows.elementAt(i + 46);
						dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
						strTemp = CommonUtil.formatFloat(strTemp,true);
						dTotalDed += dTemp;
						if(dTemp == 0d)
							strTemp = "--";
					%>					
          <td align="right" class="detail_style" ><%=strTemp%></td>
          </tr>
			<%			
 		
			for(iCols = 1;iCols <= iDedColCount; iCols+=2){
				strTemp = (String)vDedCols.elementAt(iCols);
				strAmt = (String)vDeductions.elementAt(1+(iCols/2));
				dTemp = Double.parseDouble(strAmt);
				dTotalDed += dTemp;
				if(dTemp > 0d){
				
				//for(iCols = 1;iCols <= iDedColCount/2; iCols ++)
				//strTemp = (String)vDeductions.elementAt(iCols);
				//for(iCols = 1;iCols <= iDedColCount; iCols +=2)
				//strTemp = (String)vDedCols.elementAt(iCols);				
				// vDedCols [null, Calamity Loan, 1, Provident Loan, 2]
				// vDeductions [5512.80, 0.00, 2166.67]
			%>				
        <tr>
          <td class="detail_style" ><%=strTemp%></td>
          <td align="right" class="detail_style" >&nbsp;<%=strAmt%></td>
        </tr>
				<%}
				}%>
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
 			dTotalDed += dOtherDed;
			strTemp = CommonUtil.formatFloat(dOtherDed,true);
			if(dOtherDed > 0d){
		  %>				
        <tr>
          <td class="detail_style" > Other deductions </td>
          <td align="right" class="detail_style" >&nbsp;<%=strTemp%></td>
          </tr>
				<%}%>
      </table></td>
      <td colspan="<%=iEarnColCount%>"align="right" valign="bottom" >&nbsp;</td>
			<td align="right" valign="bottom" >&nbsp;</td>
			<td align="right" valign="bottom" >&nbsp;</td>
      <%
			// Night Differential
			strTemp = (String)vRows.elementAt(i + 24);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
			if(dTemp > 0d){
				strTemp = CommonUtil.formatFloat(dTemp, true);		
				strTemp = "NP : " + strTemp;
			}else{
				strTemp = "&nbsp;";						
			}
			%>						
      <td align="right" valign="top" ><%=strTemp%></td>
      <td colspan="2" align="right" valign="top" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
					<%
						dTemp = CommonUtil.formatFloatToCurrency(dNetPay/4, 0);
						strTemp = CommonUtil.formatFloat(dTemp, true);
					%>
          <td width="53%" height="20" align="right" class="detail_style"><%=strTemp%>&nbsp;</td>
          <td width="47%" align="right" class="detail_style">1&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="detail_style"><%=strTemp%>&nbsp;</td>
          <td align="right" class="detail_style">2&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="detail_style"><%=strTemp%>&nbsp;</td>
          <td align="right" class="detail_style">3&nbsp;</td>
        </tr>
        <tr>
					<%
						dTemp = dNetPay - (dTemp * 3);
						strTemp = CommonUtil.formatFloat(dTemp, true);
					%>					
          <td height="20" align="right" class="detail_style"><%=strTemp%>&nbsp;</td>
          <td align="right" class="detail_style">4&nbsp;</td>
        </tr>
      </table></td>
    </tr>
    <tr bgcolor="<%=strBgColor%>">
      <td height="24" valign="bottom" nowrap >&nbsp;</td>
      <td colspan="2" align="right" valign="bottom" >&nbsp;</td>
      <td colspan="<%=iEarnColCount%>"align="right" valign="bottom" >&nbsp;</td>
			<td align="right" valign="bottom" >&nbsp;</td>
			<td align="right" valign="bottom" class="detail_style"><%=CommonUtil.formatFloat(dTotalDed, true)%></td>
      <td align="right" valign="bottom" >&nbsp;</td>
      <td colspan="2" align="right" valign="top" >&nbsp;</td>
    </tr>
    <% i = i + iFieldCount; %>
    <%}//end for loop %>
    <%
	 }// end outer for loop... for office name
	} // end if %>
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