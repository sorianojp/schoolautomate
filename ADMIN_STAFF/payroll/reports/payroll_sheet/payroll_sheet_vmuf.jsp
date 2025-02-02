<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, 
																payroll.PReDTRME, payroll.OvertimeMgmt" buffer="16kb"%>
<%
boolean bolHasConfidential = false;
WebInterface WI = new WebInterface(request);
String strHeaderSize = WI.getStrValue(WI.fillTextValue("header_size"), "11");
String strDetailSize = WI.getStrValue(WI.fillTextValue("detail_size"), "11");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary by Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
  TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=strDetailSize%>.px;
  }
		
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=strDetailSize%>.px;
	}	
	
  TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=strDetailSize%>.px;
  }
	
  TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=strDetailSize%>.px;
  }
	
	TD.headerBOTTOM {
    border-bottom: solid 1px #000000;    
 		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=strHeaderSize%>.px;
  }

	TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
		font-family: Arial, Verdana,  Geneva,  Helvetica, sans-serif;
		font-size: <%=strHeaderSize%>.px;
  }
  
	TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
		border-right: solid 1px #000000;    
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=strHeaderSize%>.px;
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
	<jsp:forward page="./payroll_sheet_vmuf_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Sheet (By Office)","psheet_grouped.jsp");
								
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
	String strTemp2 = null;
	String strHourlyRate = null;
	double dDailyRate = 0d;
//	int iStart = 29; // this is where the null fields start
	int iFieldCount = 75;
	String strDateFrom = null;
	String strDateTo = null;
	String strBorder = "";

	double dBasic = 0d;
	double dTemp = 0d;
	double dLineTotal = 0d;
		
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
	double dExtraTotal = 0d;
	double dEmpDeduct = 0d;
	
	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;
	Vector vOTDetail = null;
	Vector vSalDetail = null;
//	Vector vLateUtDetail = null;
	Vector vOTTypes = null;
	Vector vEmpOT = null;
//	Vector vEmpAdjust = null;
	Vector vContributions = null;
 	String strDeanName = null;
	double dOtherEarn = 0d;
	double dOtherDed  = 0d;
	double dTempOthers = 0d;
	String strUserIndex = null;
	int iIndex = 0;

	boolean bolShowHeader = true; 	
	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
	boolean bolShowBorder = false;
	int i = 0;
	int iOTType = 0;
	int iContCount = 0;
	
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
		
//		if(WI.fillTextValue("hide_adjustment").equals("1"))
//			vAdjTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, false);			
//		else
//			vAdjTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "0");
			
		vContributions = RptPSheet.checkPSheetContributions(dbOP, request, WI.fillTextValue("sal_period_index"));
		
		if(vEarnCols != null && vEarnCols.size() > 0)
			iEarnColCount = vEarnCols.size() - 2;

		if(vDedCols != null && vDedCols.size() > 0)
			iDedColCount = vDedCols.size() - 1;		

		if (vEarnDedCols != null && vEarnDedCols.size() > 0)
			iEarnDedCount = vEarnDedCols.size()- 1;

 		if (vOTTypes != null && vOTTypes.size() > 0)
			iOTType = vOTTypes.size()/19;

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
			if(astrContributions[i].equals("1"))
				iContCount++;
		}
		
		if(astrContributions[0].equals("1") && astrContributions[1].equals("1"))
			iContCount--;
	}	else if(!WI.fillTextValue("hide_contributions").equals("1")){
			iContCount = 3;
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
<body>
<form name="form_" 	method="post" action="payroll_sheet_vmuf.jsp">
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
      <tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td><select name="employee_category" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%if (WI.fillTextValue("employee_category").equals("0")){%>
        <option value="0" selected>Non-Teaching</option>
        <option value="1">Teaching</option>
        <%} else if (WI.fillTextValue("employee_category").equals("1")){%>
        <option value="0">Non-Teaching</option>
        <option value="1" selected>Teaching</option>
        <%}else{%>
        <option value="0">Non-Teaching</option>
        <option value="1">Teaching</option>
        <%}%>
      </select></td>
    </tr>
      <tr>
        <td height="24">&nbsp;</td>
        <td>Employer name </td>
        <td><select name="employer_index" onChange="ReloadPage();">
        <%
			String strEmployer = WI.fillTextValue("employer_index");
			boolean bolIsDefEmployer = false;
			java.sql.ResultSet rs = null;
			strTemp = "select employer_index,employer_name,is_default from pr_employer_profile where is_del = 0 order by is_default desc";
			rs = dbOP.executeQuery(strTemp);
			while(rs.next()){
				strTemp = rs.getString(1);
				if(strEmployer.length() == 0 || strEmployer.equals(strTemp)) {
					strErrMsg = " selected";
					if(rs.getInt(3) == 1)
						bolIsDefEmployer = true;
					if(strEmployer.length() == 0)
						strEmployer = strTemp;
				}
				else	
					strErrMsg = "";
					
			%>
        <option value="<%=strTemp%>" <%=strErrMsg%>><%=rs.getString(2)%></option>
        <%}
			rs.close();
			%>
      </select></td>
      </tr>
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
      <td>College</td>
      <td> <select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0 order by c_name", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td> <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null) order by d_name", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex + "  order by d_name", WI.fillTextValue("d_index"),false)%> 
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
		  hide earning column without value</td>
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
				strTemp = WI.fillTextValue("show_page_sum");
				if(strTemp.length() > 0){
					strTemp = "checked";
 				}else{
					strTemp = "";					
 				}
			%>			
      <td height="10" colspan="2"><input type="checkbox" name="show_page_sum" value="1" <%=strTemp%>>
show page summary in print </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_page_total");
				if(strTemp.length() > 0){
					strTemp = "checked";
 				}else{
					strTemp = "";					
 				}
			%>			
      <td height="10" colspan="2"><input type="checkbox" name="hide_page_total" value="1" <%=strTemp%>>
        hide page total</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_grand_total");
				if(strTemp.length() > 0){
					strTemp = "checked";
 				}else{
					strTemp = "";					
 				}
			%>						
      <td height="10" colspan="2"><input type="checkbox" name="hide_grand_total" value="1" <%=strTemp%>>
        hide grand total</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("break_per_office");
				if(strTemp.length() > 0){
					strTemp = "checked";
 				}else{
					strTemp = "";					
 				}
			%>			
      <td height="10" colspan="2"><input type="checkbox" name="break_per_office" value="1" <%=strTemp%>>
      break per office</td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="3%" height="10">&nbsp;</td>
      <td width="14%" height="10">&nbsp;</td>
      <td width="83%" height="10">&nbsp;</td>
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
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <tr>
      <td width="3%" height="20">&nbsp;</td>
      <td width="19%" height="20">SIGNATORIES</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Accounting Section </td>
			<%
				strTemp = WI.fillTextValue("accounting_head");
				if(strTemp.length() == 0)
					strTemp = "Elvira B. Caguioa";
			%>
      <td width="78%" height="20"><input type="text" class="textbox" value="<%=strTemp%>" name="accounting_head" size="40"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Payroll Section </td>
			<%
				strTemp = WI.fillTextValue("payroll_head");
				if(strTemp.length() == 0)
					strTemp = "Maria C. Reyes";
			%>			
      <td height="10"><input type="text" class="textbox" value="<%=strTemp%>" name="payroll_head" size="40"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("benefit_head");
				if(strTemp.length() == 0)
					strTemp = "LEONCIO R. MANGALIAG";
			%>
      <td height="10">Benefit Section </td>
      <td height="10"><input type="text" class="textbox" value="<%=strTemp%>" name="benefit_head" size="40"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">President</td>
			<%
				strTemp = WI.fillTextValue("president");
				if(strTemp.length() == 0)
					strTemp = "MA. LILIA P. JUAN, MD.,FPCHA";
			%>			
      <td height="10"><input type="text" class="textbox" value="<%=strTemp%>" name="president" size="40"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">CTTP/VP-Finance</td>
			<%
				strTemp = WI.fillTextValue("vp_finance");
				if(strTemp.length() == 0)
					strTemp = "COL. AVELINO V. GEAGA (Ret.)";
			%>			
      <td height="10"><input type="text" class="textbox" value="<%=strTemp%>" name="vp_finance" size="40"></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
 	  <% if (vRows != null && vRows.size() > 0 ){%>
      <td height="10" colspan="2"><div align="right"><font size="2">Number of  rows Per 
          Page :</font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"25"));
			for(i = 15; i <=25 ; i++) {
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
					<%for(i = 7; i < 14; i++){%>
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
            <%for(i = 7; i < 14; i++){%>
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
      <td height="33" colspan="7" align="center" class="headerBOTTOMLEFT"><strong><font size="1">PART TIME / 
      EXTRA LOAD</font></strong></td>

			
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
      <td width="4%" align="center" <%=strBorder%>>ADJUST</td>
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
      <td width="6%" align="center" <%=strBorder%>>OTHER DED.</td>
      <td width="6%" align="center" <%=strBorder%>>TOTAL 
      DEDUCT</td>
      <%				
				if(bolShowBorder)
					strBorder =  "class='headerBOTTOMLEFTRIGHT'";
				else
					strBorder = "class='thinborderBOTTOM'";
			%>			
      <td width="6%" align="center"<%=strBorder%>>NET PAY</td>
    </tr>
    
    <% 
    for(i = 0; i < vRows.size();){	
		if(bolShowHeader){
		bolShowHeader = false;
	  %>
    <tr>
      <%
			strTemp = "Division : ";
				
			strTemp2 = (String)vRows.elementAt(i+63);
			strTemp2 = WI.getStrValue(strTemp2," Dept : ","","");
	
			if(bolShowBorder)
				strBorder =  "class='thinborderBOTTOMLEFTRIGHT'";
			else
				strBorder = "class='NoBorder'";
			%>
			
      <td height="26" colspan="<%= iEarnColCount + (iDedColCount/2) + iEarnDedCount + 20 + iOTType%>" valign="bottom" <%=strBorder%>><strong> <%=(WI.getStrValue((String)vRows.elementAt(i+62),strTemp, strTemp2, strTemp2)).toUpperCase()%></strong> </td>
			<!--
			<td height="26" colspan="25" valign="bottom" <%=strBorder%>><strong> <%=(WI.getStrValue((String)vRows.elementAt(i+62),strTemp, strTemp2, strTemp2)).toUpperCase()%></strong> </td>
			-->
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
//	vEmpAdjust = (Vector)vRows.elementAt(i+67);
	dLineTotal = 0d;
	dBasic = 0d;
 	dOtherEarn = 0d;
	dOtherDed = 0d;
	dEmpDeduct = 0d;
		%>
    <tr bgcolor="<%=strBgColor%>">
      <%				
				if(bolShowBorder)
					strBorder =  "class='thinborder'";
				else
					strBorder = "class='NoBorder'";
			%>
      <td height="24" valign="bottom" nowrap <%=strBorder%>><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
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
		dExtraTotal += dTemp;
		
		dLineTotal += dTemp;
	  %>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dTemp, true)%></td>
		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dTemp = CommonUtil.formatFloatToCurrency(dTemp, 2);
			adEarningTotal[iCols-2] = adEarningTotal[iCols-2] + dTemp;
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
		//dTotalAdjust += dTemp;
	  %>		
			<td align="right" valign="bottom" <%=strBorder%>><%=strTemp%></td>
		<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
				adEarnDedTotal[iCols-1] = adEarnDedTotal[iCols-1] + dTemp;
				dLineTotal -= dTemp;
				if(dTemp == 0d)
					strTemp = "&nbsp;";			
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
		dLineTotal -= dTemp;
 	  %>
			<td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dTemp, true)%></td>
      <%
	  	dLineTotal += dBasic;
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
			strTemp = Double.toString(dTemp);
	//		System.out.println("SSS " +dTemp);
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%>&nbsp;</td>
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
			dEmpDeduct += dTemp;
			strTemp = Double.toString(dTemp);
	//		System.out.println("hdmf " +dTemp);
			%>
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%>&nbsp;</td>
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
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%>&nbsp;</td>
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
		strTemp = Double.toString(dTemp);
//		System.out.println("Tax " +dTemp);
	  %>
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%>&nbsp;</td>
       <%for(iCols = 1;iCols <= iDedColCount/2; iCols ++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				dEmpDeduct += dTemp;
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
			strTemp = CommonUtil.formatFloat(dOtherDed,true);
			if(dOtherDed == 0d)
				strTemp = "";
	  %>
      <td align="right" valign="bottom" <%=strBorder%>><%=strTemp%>&nbsp;</td>
      <td align="right" valign="bottom" <%=strBorder%>><%=WI.getStrValue(CommonUtil.formatFloat(dEmpDeduct,true),"&nbsp;")%></td>
      <%				
				if(bolShowBorder)
					strBorder =  "class='thinborderBOTTOMLEFTRIGHT'";
				else
					strBorder = "class='NoBorder'";
			%>			
			<%
				strTemp = (String)vRows.elementAt(i+52);
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