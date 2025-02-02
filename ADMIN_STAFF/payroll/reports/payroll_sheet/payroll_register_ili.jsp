<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolHasConfidential = false;
boolean bolHasTeam = false;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Sheet/Register</title>
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
		font-size: 9px;
    }
		TD.headerBOTTOMLEFTbold {
    border-bottom: solid 1px #000000;
		border-left: double 3px #000000;
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

		TD.BOTTOMLEFTbold {
    border-bottom: solid 1px #000000;
		border-left: double 3px #000000;
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
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
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

	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
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

function GoToNewReport() {
	document.form_.show_detailed.value = "";
	document.form_.show_net_only.value = "1";
	this.SubmitOnce('form_');
}
</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	String strUserId = (String)request.getSession(false).getAttribute("userId");
	boolean bolShowALL = false;
	if(strUserId != null && (strUserId.equals("bricks") || strUserId.equals("GTI-01")))
		bolShowALL = true;	
	boolean bolShowBorder = false;
	boolean bolHasInternal = false;
	
	if (WI.fillTextValue("show_net_only").length() > 0){ %>
	<jsp:forward page="./payroll_register_ili_net.jsp" />
<% return;}
	
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./payroll_register_ili_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation(strUserId,
								"Admin/staff-Payroll-REPORTS-Payroll Register","payroll_register_ili.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolHasInternal = (readPropFile.getImageFileExtn("HAS_INTERNAL","0")).equals("1");		
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
														"payroll_register_ili.jsp");
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
	String strPayrollPeriod  = null;
	String strTemp2 = null;
	int iFieldCount = 75;// number of fields in the vector..
	int i = 0;

	double dBasic = 0d;
	double dDaysWorked = 0d;
	double dTemp = 0d;
	double dLineOver = 0d;
	double dLineTotal = 0d;
	double dOtherDed = 0d;	
	double dEmpDeduct = 0d;
	double dTotalDeductions = 0d;
	double dCOLA = 0d;
	double dNetPay = 0d;

	Vector vRetResult = null;
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;
	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;
	Vector vOTDetail = null;
	Vector vSalDetail = null;
	Vector vContributions = null;
	double dOtherEarn = 0d;
	String strSchCode = dbOP.getSchoolIndex();
	int iHour = 0;
	int iMinute = 0;
	int iContributions = 0;
	String strDeptName = null;
	boolean[] abolShowCol = {false, false, false, false};
	
	vRetResult = RptPSheet.getPSheetItems(dbOP);
	if(vRetResult == null)
		strErrMsg = RptPSheet.getErrMsg();
	else{
		vRows = (Vector)vRetResult.elementAt(0);
		vEarnCols = (Vector)vRetResult.elementAt(1);
		vDedCols = (Vector)vRetResult.elementAt(2);		
		vEarnDedCols = (Vector)vRetResult.elementAt(3);		
		vContributions = RptPSheet.checkPSheetContributions(dbOP, request, WI.fillTextValue("sal_period_index"));

		if(WI.fillTextValue("excludeLoansMisc").length() > 0)
			vDedCols = null;
		
		if(vEarnCols != null && vEarnCols.size() > 0)
			iEarnColCount = vEarnCols.size() - 2;

		if(vDedCols != null && vDedCols.size() > 0)
			iDedColCount = vDedCols.size() - 1;		

		if(vEarnDedCols != null && vEarnDedCols.size() > 0)
			iEarnDedCount = vEarnDedCols.size() - 1;	
			
		iSearchResult = RptPSheet.getSearchCount();		
	}
	
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
			iContributions = 3;
	}
	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body>
<form name="form_" 	method="post" action="payroll_register_ili.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL: PAYROLL SHEET PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
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
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%">Salary Period</td>
      <td width="77%" colspan="3"><strong>
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
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
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
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Division</td>
      <td colspan="3"> <select name="c_index" onChange="loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"> 
				<label id="load_dept">
				<select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> 
				</label>			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salary base </td>
      <td colspan="3">
			<select name="salary_base" onChange="ReloadPage();">
			<option value="">All</option>
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
      </select></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Show option </td>
			<%
				strTemp = WI.fillTextValue("is_resigned");
			%>
      <td height="10" colspan="3"><select name="is_resigned" onChange="ReloadPage();">
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
		
		<%if(bolHasConfidential){%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Process option </td>
			<%
			String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";				
			%>					
      <td height="10" colspan="3"><select name="group_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group " +
													" where exists(select user_index from pr_group_proc " +
													" 	where pr_preload_group.group_index = pr_group_proc.group_index " +
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%>
      </select></td>
    </tr>
		<%}%>
<% 
		
			strTemp = WI.fillTextValue("atm_option");%>
			<tr>
			  <td height="25">&nbsp;</td>
			  <td>ATM/Non ATM </td>
			  <td>
			  	<select name="atm_option">
					<option value="" <%=strTemp.equals("")?"selected":"" %> >All</option>
					<option value="1" <%=strTemp.equals("1")?"selected":"" %> >ATM</option>
					<option value="0" <%=strTemp.equals("0")?"selected":"" %> >Non - ATM</option>
		  		</select>
		 	 </td>
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
		<%if(bolShowALL){%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Employee ID </td>
		  <td><input name="emp_id" type="text" size="16"maxlength="128" value="<%=WI.fillTextValue("emp_id")%>"
											onKeyUp="AjaxMapName(1);"><label id="coa_info"></label>	</td>
	  </tr>
		<%}%>
		<tr>
		  <td height="20">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_earnings");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>			
		  <td height="10" colspan="2"><input type="checkbox" name="hide_earnings" value="1" <%=strTemp%>>
		    hide earning column without value</td>
		</tr>
		<tr>
		  <td height="20">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_deductions");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>			
		  <td height="10" colspan="2"><input type="checkbox" name="hide_deductions" value="1" <%=strTemp%>>
		    hide deduction column without value</td>
		</tr>
		<!--
		<tr>
		  <td height="20">&nbsp;</td>
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
		  <td height="20">&nbsp;</td>
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
		-->
		<tr>
		  <td height="20">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_contributions");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>							
		  <td height="10" colspan="2"><input type="checkbox" name="hide_contributions" value="1" <%=strTemp%>>
		    hide contribution column without value</td>
		</tr>
		<tr>
		  <td height="20">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_account");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>
		  <td height="10" colspan="2"><input type="checkbox" name="hide_account" value="1" <%=strTemp%>> 
		    hide account number</td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_adjust");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>
		  <td height="10" colspan="2"><input type="checkbox" name="hide_adjust" value="1" <%=strTemp%>>
		    hide adjustment column if zero</td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_ot");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>
		  <td height="10" colspan="2"><input type="checkbox" name="hide_ot" value="1" <%=strTemp%>>
		    hide overtime column if zero</td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_oth_income");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>
		  <td height="10" colspan="2"><input type="checkbox" name="hide_oth_income" value="1" <%=strTemp%>>
		    hide other income column if zero</td>
	  </tr>				
		<tr>
		  <td height="20">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_oth_deduct");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>
		  <td height="10" colspan="2"><input type="checkbox" name="hide_oth_deduct" value="1" <%=strTemp%>> 
		    hide other deduction column if zero</td>
	  </tr>
		<%if(bolHasInternal || bolShowALL){%>
		<tr>
		  <td height="20">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_internal");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else	
					strTemp = "";
			%>
		  <td height="10" colspan="2">
				<input type="checkbox" name="show_internal" value="1" <%=strTemp%> onClick="ReloadPage();">
				show internal			</td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("excludeLoansMisc");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
		  <td height="10" colspan="2"><input type="checkbox" name="excludeLoansMisc" value="1" <%=strTemp%>> 
		    exclude loans and miscellaneous deductions from report</td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td height="10" colspan="2"><a href="javascript:GoToNewReport();">show only name and net pay</a></td>
	  </tr>		
		<%}%>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<!--
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
          <option value="">N/A</option>
          <%if(WI.fillTextValue("sort_by1").equals("ID_NUMBER"))		    
			{%>
    	      <option selected value="ID_NUMBER">Employee ID</option>
          <%}else{%>
	          <option value="ID_NUMBER">Employee ID</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by1").equals("LNAME"))
		    {%>
        	  <option selected value="LNAME">Lastname</option>
          <%}else{%>
    	      <option value="LNAME">Lastname</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by1").equals("FNAME"))
		   {%>
         	 <option selected value="FNAME">Firstname</option>
          <%}else{%>
	          <option value="FNAME">Firstname</option>
          <%}%>
        </select></td>

      <td height="29"><select name="sort_by2">
          <option value="">N/A</option>
          <%if(WI.fillTextValue("sort_by2").equals("ID_NUMBER"))		    
			{%>
    	      <option selected value="ID_NUMBER">Employee ID</option>
          <%}else{%>
	          <option value="ID_NUMBER">Employee ID</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by2").equals("LNAME"))
		    {%>
        	  <option selected value="LNAME">Lastname</option>
          <%}else{%>
    	      <option value="LNAME">Lastname</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by2").equals("FNAME"))
		   {%>
         	 <option selected value="FNAME">Firstname</option>
          <%}else{%>
	          <option value="FNAME">Firstname</option>
          <%}%>
        </select></td>

      <td height="29"><select name="sort_by3">
          <option value="">N/A</option>
          <%if(WI.fillTextValue("sort_by3").equals("ID_NUMBER"))		    
			{%>
    	      <option selected value="ID_NUMBER">Employee ID</option>
          <%}else{%>
	          <option value="ID_NUMBER">Employee ID</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by3").equals("LNAME"))
		    {%>
        	  <option selected value="LNAME">Lastname</option>
          <%}else{%>
    	      <option value="LNAME">Lastname</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by3").equals("FNAME"))
		   {%>
         	 <option selected value="FNAME">Firstname</option>
          <%}else{%>
	          <option value="FNAME">Firstname</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td width="11%" height="15">&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
	if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
		-->
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
      <font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr>
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <% if (vRows != null && vRows.size() > 0 ){%>
		<tr> 
      <td height="10">&nbsp;</td>
 	  
      <td height="10" colspan="4"><div align="right">
        <div align="right"><font size="2">Number of Employees / rows Per 
          Page :</font><font>
            <select name="num_rec_page">
              <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 15; i <=30 ; i++) {
				if ( i == iDefault) {%>
              <option selected value="<%=i%>"><%=i%></option>
              <%}else{%>
              <option value="<%=i%>"><%=i%></option>
              <%}}%>
            </select>
            <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div>
      </div></td>	   
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Prepared by : </td>
			<%
					strTemp = WI.fillTextValue("prepared_by");
			%>
      <td height="10"><input type="text" name="prepared_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("size_header");
				if(strTemp.length() == 0)
					strTemp = "9";
			%>
      <td height="10" align="right"><font size="2">Font size of header:
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
      <td>Reviewed by : </td>
			<%
				strTemp = WI.fillTextValue("reviewed_by");
			%>			
      <td><input type="text" name="reviewed_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
      <td>&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("font_size");
				if(strTemp.length() == 0)
					strTemp = "9";
			%>			
      <td align="right"><font size="2">Font size of details:
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
    <tr>
      <td height="10">&nbsp;</td>
      <td>Noted by : </td>
			<%
				strTemp = WI.fillTextValue("noted_by");
			%>				
      <td><input type="text" name="noted_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
      <td>&nbsp;</td>
      <td align="right">&nbsp;</td>
    </tr>
		<%}%>
  </table>
  <% if (vRows != null && vRows.size() > 0 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="23"> 
			<%
		int iPageCount = iSearchResult/RptPSheet.defSearchSize;
		if(iSearchResult % RptPSheet.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="SearchEmployee();">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( i =1; i<= iPageCount; ++i )
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
          </div><%}%>
      </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="21" align="center"><strong><font color="#0000FF">PAYROLL 
      SHEET FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>
  </table>
	<%
		if(WI.fillTextValue("hide_adjust").length()== 0)
			abolShowCol[0] = true;

		if(WI.fillTextValue("hide_ot").length() == 0)
			abolShowCol[1] = true;

		if(WI.fillTextValue("hide_oth_income").length() == 0)
			abolShowCol[2] = true;

		if(WI.fillTextValue("hide_oth_deduct").length() == 0)
			abolShowCol[3] = true;
	
		for(i = 0; i < vRows.size(); i += iFieldCount){	
			vDeductions = (Vector)vRows.elementAt(i+54);
			if(WI.fillTextValue("excludeLoansMisc").length() > 0){
				vDeductions.setElementAt("0",0) ;
			}			
			vEarnings = (Vector)vRows.elementAt(i+53);
					
			// check for adjustment 
			// if there are values na dili zero... then show column
			strTemp = (String)vRows.elementAt(i + 51);  	
			//strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			if(dTemp != 0d)
				abolShowCol[0] = true;

			// check for OT
			strTemp = (String)vRows.elementAt(i + 23);  	
			//strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			if(dTemp > 0d)
				abolShowCol[1] = true;
			
			if(!abolShowCol[2]){
				if(vEarnings != null){
					// subject allowances 
					strTemp = WI.getStrValue((String)vEarnings.elementAt(0), "0"); 
					dTemp = Double.parseDouble(strTemp);
					if(dTemp > 0d)
						abolShowCol[2] = true;
					// ungrouped earnings.
					strTemp = WI.getStrValue((String)vEarnings.elementAt(1), "0"); 
					dTemp = Double.parseDouble(strTemp);
					if(dTemp > 0d)
						abolShowCol[2] = true;
				}
	
				// night differential amount
				strTemp = (String)vRows.elementAt(i + 24);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				if(dTemp > 0d)
					abolShowCol[2] = true;
						
				// holiday_pay_amt
				strTemp = WI.getStrValue((String)vRows.elementAt(i+26), "0"); 
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(strTemp);
				if(dTemp > 0d)
					abolShowCol[2] = true;
		
				// addl_payment_amt 
				strTemp = WI.getStrValue((String)vRows.elementAt(i+27), "0"); 
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(strTemp);
				if(dTemp > 0d)
					abolShowCol[2] = true;
		
				// Adhoc Allowances
				strTemp = WI.getStrValue((String)vRows.elementAt(i+28), "0"); 
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(strTemp);
				if(dTemp > 0d)
					abolShowCol[2] = true;
		
				// addl_resp_amt
				strTemp = WI.getStrValue((String)vRows.elementAt(i+29), "0"); 
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(strTemp);
				if(dTemp > 0d)
					abolShowCol[2] = true;
				
				// substitute salary
				strTemp = WI.getStrValue((String)vRows.elementAt(i + 38), "0"); 
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(strTemp);
				if(dTemp > 0d)
					abolShowCol[2] = true;
			}
			
			if(!abolShowCol[3]){
				// this is the other ungrouped deductions
				strTemp = (String)vDeductions.elementAt(0);
				dTemp = Double.parseDouble(strTemp);
				if(dTemp > 0d)
					abolShowCol[3] = true;
					
				// misc_deduction
				strTemp = WI.getStrValue((String)vRows.elementAt(i + 45), "0"); 
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(strTemp);
				if(dTemp > 0d)
					abolShowCol[3] = true;
			}
		}
	%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="TOPRIGHT">
    <tr>
      <%if(WI.fillTextValue("hide_account").length() == 0){%>
			<td width="3%" class="headerBOTTOMLEFT">Acct. No </td>			
			<%}%>
			<td width="7%" align="center" class="headerBOTTOMLEFT">DEPARTMENT</td>
      <td width="7%" height="33" align="center" class="headerBOTTOMLEFT">NAME 
          OF EMPLOYEE </td>
<%
			//System.out.println("salary_base ---- " + WI.fillTextValue("salary_base"));
			if(WI.fillTextValue("salary_base").equals("1") || WI.fillTextValue("salary_base").equals("2")){%>
			<%
				if (WI.fillTextValue("salary_base").equals("1")){
					strTemp = "RATE PER DAY";
					strTemp2 = "DAYS WORKED";
				}else if (WI.fillTextValue("salary_base").equals("2")){
					strTemp = "RATE PER HOUR";
					strTemp2 = "HOURS WORKED";
				}else{
					strTemp = "&nbsp;";
					strTemp2 = "&nbsp;";
				}
			%>					
      <td width="2%" align="center" class="headerBOTTOMLEFT"><%=strTemp%></td>			
      <td width="2%" height="33" align="center" class="headerBOTTOMLEFT"><%=strTemp2%></td>
			<%}%>
      <td width="5%" align="center" class="headerBOTTOMLEFT">BASIC SALARY </td>
      <%if(abolShowCol[0]){%>
			<td width="3%" align="center" class="headerBOTTOMLEFT">ADJ. </td>
			<%}%>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
      <td width="2%" align="center" class="headerBOTTOMLEFT"><span class="headerBOTTOMLEFT"><%=(String)vEarnCols.elementAt(iCols)%></span></td>
			<%}%>
      <%if(abolShowCol[1]){%>
			<td width="7%" align="center" class="headerBOTTOMLEFT">OVERTIME</td>
			<%}%>
      <%if(WI.fillTextValue("show_internal").length() == 0){%>
			<td width="5%" align="center" class="headerBOTTOMLEFT">COLA</td>
			<%}%>
      <%if(abolShowCol[2]){%>
			<td width="5%" align="center" class="headerBOTTOMLEFT"><span class="BOTTOMLEFT">OTHERS</span></td>
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td align="center" class="headerBOTTOMLEFT"><%=(String)vEarnDedCols.elementAt(iCols)%></td>
			<%}%>
      <td width="7%" align="center" class="headerBOTTOMLEFTbold"><span class="BOTTOMLEFT">GROSS PAY </span></td>
      <td width="6%" align="center" class="headerBOTTOMLEFTbold">TARDINESS/<br>
      UNDERTIME</td>
      <%if(astrContributions[0].equals("1")){%>
			<td width="6%" height="33" align="center" class="headerBOTTOMLEFT">SSS </td>
			<%} if(astrContributions[1].equals("1")){%>
      <td width="6%" align="center" class="headerBOTTOMLEFT">PHILHEALTH</td>
			<%}if(astrContributions[2].equals("1")){%>
      <td width="6%" align="center" class="headerBOTTOMLEFT">PAG-IBIG</td>
			<%}%>
			<td width="5%" align="center" class="headerBOTTOMLEFT">WITHTAX</td>
			<%			
			for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>
			<td width="5%" align="center" class="headerBOTTOMLEFT"><%=strTemp%></td>
			<%}%>
			<%if(abolShowCol[3]){%>
			<td width="5%" align="center" class="headerBOTTOMLEFT">OTHERS</td>
			<%}%>
			<td width="5%" align="center" class="headerBOTTOMLEFTRIGHT">TOTAL DEDUCTIONS</td>
			<td width="5%" align="center" class="headerBOTTOMLEFT"><span class="BOTTOMLEFTRIGHT">NET PAY</span></td>
    </tr>
    <% 
	if (vRows != null && vRows.size() > 0 ){
		//System.out.println("vRows " + vRows.size());
		//System.out.println("vRows " + vRows);
      for(i = 0; i < vRows.size(); i += iFieldCount){
				vDeductions = (Vector)vRows.elementAt(i+54);
				if(WI.fillTextValue("excludeLoansMisc").length() > 0){
					vDeductions.setElementAt("0",0) ;
				}
			
			dEmpDeduct = 0d;
			dOtherDed = 0d;
			
			vEarnings = (Vector)vRows.elementAt(i+53);
			vSalDetail = (Vector)vRows.elementAt(i+55); 
			vOTDetail = (Vector)vRows.elementAt(i+56);
			vEarnDed = (Vector)vRows.elementAt(i+59);			
			dLineTotal = 0d;
			dBasic = 0d;
			dDaysWorked = 0d;
			dLineOver = 0d;
	%>
    <tr>
      <%
			if(WI.fillTextValue("hide_account").length() == 0){
				// Account number
				strTemp = null;
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp = (String)vSalDetail.elementAt(1);
			%>		
      <td class="BOTTOMLEFT">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td> 			
			<%}%>
      <%
				// DEPT NAME
				if(strDeptName == null || !strDeptName.equals((String)vRows.elementAt(i + 63))){
					strTemp = (String)vRows.elementAt(i + 63);
					strDeptName = strTemp;
				}else{
					strTemp = "&nbsp;";
				}					
			%>				
			<td class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
      <td height="18" class="BOTTOMLEFT"><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong></td>
			<%if(WI.fillTextValue("salary_base").equals("1") || WI.fillTextValue("salary_base").equals("2")){%>
      <%
				//rate per hour
				//strTemp = (String)vRows.elementAt(i + iStart + 2);
				strTemp2 = "";
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp2 = (String)vSalDetail.elementAt(6); 			
				//System.out.println("strTemp2 " + strTemp2);
				if(strTemp2.equals("1")){
					strTemp = (String)vSalDetail.elementAt(2); 			
				}else if(strTemp2.equals("2")){
					strTemp = (String)vSalDetail.elementAt(5); 								
				}else{
					strTemp = "";
				}
								
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dLineTotal = dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>
      <td align="right" class="BOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <%
				// days worked
				//strTemp = (String)vRows.elementAt(i + 16);
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp2 = (String)vSalDetail.elementAt(6); 	
							
				if(strTemp2.equals("1")){
					strTemp = (String)vRows.elementAt(i + 20);
				}else if(strTemp2.equals("2")){
					strTemp = (String)vRows.elementAt(i + 8); 			
				}else{
					strTemp = "";
				}
								
				dDaysWorked= Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				if(dDaysWorked== 0d)
					strTemp = "--";
			%>			
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp, false),"")%>&nbsp;</td>
			<%}%>
      <%
				// basic salary
				//	if(WI.fillTextValue("salary_base").equals("0"))
					dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));
				//else
				//	dLineTotal = dDaysWorked * dTemp;
					
				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
			%>		     
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
      <%
			if(abolShowCol[0]){
				// adjustment amount
				strTemp = (String)vRows.elementAt(i + 51); 	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp ,true);
				dLineTotal += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>		     
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
			<%}%>
		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dLineTotal += dTemp;
			if(strTemp.equals("0"))
				strTemp = "";			
		%>          
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<%}%> 
			<%
			if(abolShowCol[1]){
				// ot  amount
				strTemp = (String)vRows.elementAt(i + 23);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dLineTotal += dTemp;			
			%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%}%>
			<%
				// COLA
				strTemp = (String)vRows.elementAt(i + 25);  	
				dCOLA = Double.parseDouble(WI.getStrValue(strTemp,"0"));						
			if(WI.fillTextValue("show_internal").length() == 0){
				dLineTotal += dCOLA;
			%>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dCOLA,true)%>&nbsp;</td>
			<%}%>
      <%			
			if(abolShowCol[2]){
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
		
		// night differential amount
		strTemp = (String)vRows.elementAt(i + 24);  	
		//strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
		dOtherEarn += dTemp;
				
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
	  %>			
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				if(strTemp.equals("0"))
					strTemp = "";			
			%>   			
      <td width="7%" align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
			<%}%>      			
      <%
				dLineTotal += dLineOver;
			%>
      <td align="right" class="BOTTOMLEFTbold"><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
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
				dEmpDeduct += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>				
      <td align="right" class="BOTTOMLEFTbold"><%=CommonUtil.formatFloat(dTemp,true)%></td>
      <%if(astrContributions[0].equals("1")){
				// sss contribution
				strTemp = (String)vRows.elementAt(i + 39);			
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>	     
      <td height="18" align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			 <%}%>
      <%if(astrContributions[1].equals("1")){
				// philhealth
				strTemp = (String)vRows.elementAt(i + 40);				
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>	  
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<%}%>
      <%if(astrContributions[2].equals("1")){
				// pag ibig
				strTemp = (String)vRows.elementAt(i +41);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dEmpDeduct += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>	  
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<%}%>
      <%
				// tax withheld
				strTemp = (String)vRows.elementAt(i + 46);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);														
				dEmpDeduct += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>   
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
		
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols ++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				dEmpDeduct += dTemp;

				if(dTemp == 0d)
					strTemp = "";			
			%>  			
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%}%>
      <%
			if(abolShowCol[3]){
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
			%>			
			<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dOtherDed,true),"&nbsp;")%></td>
			<%}%>
			<td align="right" class="BOTTOMLEFTRIGHT"><%=WI.getStrValue(CommonUtil.formatFloat(dEmpDeduct,true),"&nbsp;")%></td>
			<%
				dNetPay = dLineTotal - dEmpDeduct;

				if(WI.fillTextValue("excludeLoansMisc").length() > 0)
					strTemp = CommonUtil.formatFloat(dNetPay,true);
				else
					strTemp = CommonUtil.formatFloat((String)vRows.elementAt(i+52), true);
				
				strTemp = ConversionTable.replaceString(strTemp, ",","");
				dTemp = Double.parseDouble(strTemp);
 				if(WI.fillTextValue("show_internal").length() > 0){					
					dTemp = dTemp - dCOLA;
				}
			%>
			<td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp, true)%></td>	
    </tr>
    <%}//end for loop
	} // end if %>
  </table>  
	 <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="is_grouped" value="1">
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_pg" value="">
	<input type="hidden" name="show_detailed" value="<%=WI.getStrValue("show_detailed")%>">	
	<input type="hidden" name="show_net_only" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>