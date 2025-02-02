<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Sheet/Register </title>
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
		font-family: Verdana, Arial, Geneva, Helvetica, sans-serif;
		font-size: 9px;
    }
    TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial, Geneva, Helvetica, sans-serif;
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
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
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
	CopyName();
	document.form_.print_pg.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}

function CopyName(){
  if(document.form_.c_index.value)
		document.form_.college_name.value = document.form_.c_index[document.form_.c_index.selectedIndex].text;
  else
  	document.form_.college_name.value = "";

  if(document.form_.d_index.value)
	document.form_.dept_name.value = document.form_.d_index[document.form_.d_index.selectedIndex].text;
  else
  	document.form_.dept_name.value = "";
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
<%@ page language="java" import="utility.*,java.util.Vector, payroll.PayrollSheet, 
																 payroll.PReDTRME, payroll.OvertimeMgmt" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	boolean bolHasConfidential = false;
	boolean bolShowALL = false;
	String strUserId = (String)request.getSession(false).getAttribute("userId");	
	if(strUserId != null && strUserId.equals("bricks"))
		bolShowALL = true;
	
//add security here.


if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./payroll_sheet_vmuf_print_old.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation(strUserId,
								"Admin/staff-Payroll-REPORTS-Payroll Sheet(VMUF)","payroll_sheet_vmuf_old.jsp");
								
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
														"Payroll","REPORTS",request.getRemoteAddr(),
														"payroll_sheet_vmuf_old.jsp");
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
	String[] astrSortByName    = {"College", "Department","Firstname","Lastname"};
	String[] astrSortByVal     = {"info_faculty_basic.c_index","info_faculty_basic.d_index","user_table.fname","lname"};
	
	double dBasic = 0d;
	double dTemp = 0d;
	double dExtraTotal = 0d;
	double dExtraAllow = 0d;
	double dTotalBonus = 0d;		
	double dTotalSalary = 0d;			
	double dTotalBasic = 0d;
	double dTotalHonorarium = 0d;
	double dTotalMainAllow = 0d;
	double dTotalCola = 0d;
	double dOtherTotal = 0d;
	double dTotalAbsences = 0d;
	double dTotalGross = 0d;
	double dTotalSSS = 0d;
	double dTotalHdmf = 0d;
	double dTotalPhealth = 0d;
	double dTotalTax = 0d;
	double dTotSSSLoan = 0d;
	double dTotCalLoan = 0d;
	double dTotHdmfLoan = 0d;
	double dTotalBoard = 0d;
	double dTotalAdv = 0d;

	double dTempOthers = 0d;
	double dEmpDeduct = 0d;
	double dTotalDeductions = 0d;
	double dTotalNet = 0d;	
	double dTotalAdjust = 0d;	
	double dOtherDed = 0d;
		
	double dLineTotal = 0d;
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	Vector vRetResult = null;
	Vector vOTTypes = null;
	Vector vAdjTypes = null;
	Vector vEmpOT = null;
	Vector vEmpAdjust = null;
		
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;
	int iOT = 0;
	int iIndex = 0;
	int iOTType = 0;
	int iAdjType =0;
		
	int iFieldCount = 75;// number of fields in the vector..
	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;
	
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
			 
		iSearchResult = RptPSheet.getSearchCount();		
	}

 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	
	//double[] aiNetpay = null;
	double[] adEarningTotal = new double[iEarnColCount];
	double[] adDeductTotal = new double[iDedColCount];
	double[] adEarnDedTotal = new double[iEarnDedCount];
	double[] adTotalOT = new double[iOTType];	
	double[] adTotalAdj = new double[iAdjType];	
 	
%>
<body>
<form name="form_" 	method="post" action="./payroll_sheet_vmuf_old.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL: PAYROLL SHEET PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td>
	    <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Salary Period</td>
      <td><strong>
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
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
        <%}// check if the company has weekly salary type%></td>
    </tr>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");
	%>
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
      </select>	  </td>
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
      <td>College</td>
      <td> 
				<!--
		    <select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%//=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0 " +
					//" and exists(select * from info_faculty_basic " +
					//" join pr_edtr_manual on (info_faculty_basic.user_index = pr_edtr_manual.user_index) " +
					//" where info_faculty_basic.is_valid = 1 and sal_period_index = " + WI.getStrValue(WI.fillTextValue("sal_period_index"),"0") +
					//" and college.c_index = info_faculty_basic.c_index) order by c_name", strCollegeIndex,false)%> 
        </select>
				-->
			<select name="c_index" onChange="ReloadPage();">
        <option value="">N/A</option>
				<% 
				if(bolIsDefEmployer)
					strTemp = " from college where is_del= 0 and not exists(select * from pr_employer_mapping " +
										"where pr_employer_mapping.c_index = college.c_index and employer_index <>"+strEmployer+")";
				else
					strTemp = " from college where is_del= 0 and exists(select * from pr_employer_mapping " +
										"where pr_employer_mapping.c_index = college.c_index and employer_index ="+strEmployer+")";
				strTemp += 
					" and exists(select * from info_faculty_basic " +
					" join pr_edtr_manual on (info_faculty_basic.user_index = pr_edtr_manual.user_index) " +
					" where info_faculty_basic.is_valid = 1 and sal_period_index = " + WI.getStrValue(WI.fillTextValue("sal_period_index"),"0") +
					" and college.c_index = info_faculty_basic.c_index) order by c_name";
				%>
        <%=dbOP.loadCombo("c_index","c_name", strTemp,strCollegeIndex,false)%>
      </select>			</td>
    </tr>
		<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td> 
	    <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%//if ((strCollegeIndex.length() == 0)){%>
          <%//=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index is null or c_index = 0) " +
					//" and exists(select * from info_faculty_basic  " +
					//" join pr_edtr_manual on (info_faculty_basic.user_index = pr_edtr_manual.user_index) " +
					//" where info_faculty_basic.is_valid = 1 and sal_period_index = " + WI.getStrValue(WI.fillTextValue("sal_period_index"),"0") +
					//" and department.d_index = info_faculty_basic.d_index) order by d_name", WI.fillTextValue("d_index"),false)%>
          <%//}else if (strCollegeIndex.length() > 0){%>
          <%//=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%//}%>
        </select> </td>
    </tr>
		-->
	<%if(strCollegeIndex.length() == 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3">
			<select name="d_index" onChange="ReloadPage();">
        <option value="">N/A</option>
					<% 
					if(bolIsDefEmployer)
						strTemp = " from department where is_del= 0 and (c_index is null or c_index = 0) and not exists(select * from pr_employer_mapping " +
											"where pr_employer_mapping.d_index = department.d_index and employer_index <>"+strEmployer+")";
					else
						strTemp = " from department where is_del= 0 and (c_index is null or c_index = 0) and exists(select * from pr_employer_mapping " +
											"where pr_employer_mapping.d_index = department.d_index and employer_index ="+strEmployer+")";
					strTemp += 
						" and exists(select * from info_faculty_basic  " +
						" join pr_edtr_manual on (info_faculty_basic.user_index = pr_edtr_manual.user_index) " +
						" where info_faculty_basic.is_valid = 1 and sal_period_index = " + WI.getStrValue(WI.fillTextValue("sal_period_index"),"0") +
						" and department.d_index = info_faculty_basic.d_index) order by d_name";
					%>
        <%=dbOP.loadCombo("d_index","d_name", strTemp,WI.fillTextValue("d_index"),false)%>
      </select>			</td>
    </tr>    
		<%}else{%>
			<input type="hidden" name="d_index">
		<%}%>		
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Salary base </td>
      <td height="10"><select name="salary_base" onChange="ReloadPage();">
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
      <td height="10">&nbsp;</td>
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
      <td height="10">&nbsp;</td>
      <td height="10"><input name="emp_id" type="text" size="16"maxlength="128" value="<%=WI.fillTextValue("emp_id")%>"
											onKeyUp="AjaxMapName(1);"><label id="coa_info"></label>	</td>
    </tr>
		<%}%>
    <tr>
      <td height="20">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hide_overtime");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>						
      <td height="20" colspan="2"><input type="checkbox" name="hide_overtime" value="1" <%=strTemp%>>
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
      <td height="20" colspan="2"><input type="checkbox" name="hide_adjustment" value="1" <%=strTemp%>>
hide adjustment column without value </td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">SIGNATORIES</td>
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
      <td width="80%" height="20"><input type="text" class="textbox" value="<%=strTemp%>" name="accounting_head" size="40"></td>
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
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=RptPSheet.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=RptPSheet.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=RptPSheet.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
				<!--
				<input name="image" type="image" onClick="ReloadPage()" src="../../../../images/form_proceed.gif"> 
				-->
				<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
        <font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <%if (vRows != null && vRows.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="24" colspan="29" align="right"><font size="2">Font size of Printout:
          <select name="font_size">
            <option value="9">9</option>
            <%
strTemp = request.getParameter("font_size");
if(strTemp == null)
	strTemp = "10";
if(strTemp.compareTo("10") == 0) {%>
            <option value="10" selected>10 px</option>
            <%}else{%>
            <option value="10">10 px</option>
            <%}if(strTemp.compareTo("11") == 0) {%>
            <option value="11" selected>11 px</option>
            <%}else{%>
            <option value="11">11 px</option>
            <%}if(strTemp.compareTo("12") == 0) {%>
            <option value="12" selected>12 px</option>
            <%}else{%>
            <option value="12">12 px</option>
            <%}%>
          </select>
&nbsp;&nbsp;&nbsp;Number of Employees / rows Per 
          Page :</font><font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i = 15; i <=50 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
      <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></td>
    </tr>
	  <%
		int iPageCount = iSearchResult/RptPSheet.defSearchSize;
		if(iSearchResult % RptPSheet.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1) {%>
    <tr> 
      <td height="24" colspan="29"><div align="right">Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
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
        </div></td>
    </tr>
		<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="TOPRIGHT">
    <tr> 
      
			<td height="24" colspan="<%= iEarnColCount + (iDedColCount/2) + iEarnDedCount + 19 + iOTType + iAdjType%>" align="center" class="BOTTOMLEFT"><strong>PAYROLL 
      SHEET FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></strong></td>			
			<!--
      <td height="24" colspan="25" align="center" class="BOTTOMLEFT"><strong><font color="#0000FF">PAYROLL 
      SHEET FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>			
			-->
    </tr>
    <tr> 
			
			<td colspan="<%=iEarnColCount + iEarnDedCount + 13 + iOTType + iAdjType%>" class="headerBOTTOMLEFT">&nbsp; </td>
			<td colspan="<%=(iDedColCount/2) + 5%>" align="center" class="BOTTOMLEFT"><strong>D E D U C T I O N S </strong></td>
			<td class="headerBOTTOMLEFT">&nbsp;</td>
			<!--
			<td colspan="15" class="headerBOTTOMLEFT">&nbsp; </td>
      <td colspan="8" align="center" class="BOTTOMLEFT"><strong>D E D U C T I O N S</strong></td>			
      <td class="headerBOTTOMLEFT" colspan="2">&nbsp;</td>
			-->
    </tr>
    <tr> 
      <td height="20" colspan="2" class="BOTTOMLEFT"><font size="1">&nbsp;</font></td>
      <td colspan="7" align="center" class="BOTTOMLEFT"><strong><font size="1">PART TIME / 
        EXTRA LOAD</font></strong></td>
			<td colspan="<%=(iEarnColCount + iEarnDedCount + 4) + iOTType + iAdjType%>" class="BOTTOMLEFT">&nbsp;</td>
			<td colspan="<%=((iDedColCount/2) + 5)%>" class="BOTTOMLEFT">&nbsp;</td>
			<td class="BOTTOMLEFT">&nbsp;</td>
			<!--
			<td colspan="6" class="BOTTOMLEFT">&nbsp;</td>
			<td colspan="8" class="BOTTOMLEFT">&nbsp;</td>						
      <td colspan="2" class="BOTTOMLEFT">&nbsp;</td>
			-->
    </tr>
    <tr> 
      <td width="12%" height="33" align="center" class="headerBOTTOMLEFT"><strong>EMPLOYEE 
        NAME</strong></td>
      <%
				if(WI.fillTextValue("is_weekly").equals("1"))
					strTemp = "WEEKLY";
				else
					strTemp = "QUINCINA";
			%>
      <td width="4%" align="center" class="headerBOTTOMLEFT"><%=strTemp%>
        SALARY</td>
      <td width="3%" align="center" class="headerBOTTOMLEFT">LEC. HOUR (inside)</td>
      <td width="3%" align="center" class="headerBOTTOMLEFT">LAB. HOUR (inside)</td>
      <td width="3%" align="center" class="headerBOTTOMLEFT">TOTAL HOURS</td>
      <td width="3%" align="center" class="headerBOTTOMLEFT">LEC. HOUR (outside)</td>
      <td width="3%" align="center" class="headerBOTTOMLEFT">LAB. HOUR (outside)</td>
      <td width="3%" align="center" class="headerBOTTOMLEFT">TOTAL HOURS</td>
      <td width="3%" align="center" class="headerBOTTOMLEFT">SUB TOTAL SALARY</td>
				
	  	<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
      <td align="center" class="headerBOTTOMLEFT">&nbsp;<%=(String)vEarnCols.elementAt(iCols)%></td>
      <%}%>
      <td width="3%" align="center" class="headerBOTTOMLEFT">COLA</td>
      <%
			if(vOTTypes != null && vOTTypes.size() > 0){
			for(iOT = 0; iOT < vOTTypes.size(); iOT+=19){
				strTemp = (String)vOTTypes.elementAt(iOT+1);
			%>			
      <td width="3%" align="center" class="headerBOTTOMLEFT"><%=strTemp%></td>
			<%}
			}%>
      <td width="3%" align="center" class="headerBOTTOMLEFT">OTHERS</td>
      <%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			for(iOT = 0; iOT < vAdjTypes.size(); iOT+=19){
				strTemp = (String)vAdjTypes.elementAt(iOT+1);
			%>			
			<td width="3%" align="center" class="headerBOTTOMLEFT"><%=strTemp%></td>
      <%}
			}%>			
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td align="center" class="headerBOTTOMLEFT"><%=(String)vEarnDedCols.elementAt(iCols)%></td>
			<%}%>				
      <td width="3%" align="center" class="headerBOTTOMLEFT">ABSENCES</td>
      <td width="3%" align="center" class="headerBOTTOMLEFT">GROSS SALARY</td>
      <td width="3%" align="center" class="headerBOTTOMLEFT">SSS 
        &amp; MED. </td>
      <td width="3%" align="center" class="headerBOTTOMLEFT">HDMF</td>
      <td width="3%" align="center" class="headerBOTTOMLEFT">TAX</td>
			<%			
			for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>			
      <td align="center" class="headerBOTTOMLEFT">&nbsp;<%=strTemp%></td>
			<%}%>
      <td width="5%" align="center" class="headerBOTTOMLEFT">ADVANCE  &amp; OTHER DED</td>
      <td width="3%" align="center" class="headerBOTTOMLEFT">TOTAL 
        DEDUCT</td>
      <td width="4%" align="center" class="headerBOTTOMLEFT">NET 
        SALARY</td>
    </tr>
    <% 
	if (vRows != null && vRows.size() > 0 ){		
		for(int i = 0; i < vRows.size(); i += iFieldCount){
			vEarnings = (Vector)vRows.elementAt(i+53);
			vDeductions = (Vector)vRows.elementAt(i+54);
			vEarnDed  = (Vector)vRows.elementAt(i+59);
			vEmpOT = (Vector)vRows.elementAt(i+65);
			vEmpAdjust = (Vector)vRows.elementAt(i+67);			
			dLineTotal = 0d;
			dBasic = 0d;
			dEmpDeduct = 0d;
			dOtherDed = 0d;
			dTempOthers =0d;
	%>
    <tr> 
      <td height="24" class="BOTTOMLEFT"><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 9)%></strong></td>
      <%
		dBasic = 0d;
	  	if (vRows.elementAt(i+7) != null){	
			strTemp = (String) vRows.elementAt(i+7); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dBasic = Double.parseDouble(strTemp);
			}
		}
		dTotalBasic += dBasic;
	  %>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dBasic,true),"&nbsp;")%></td>
			<!--// excess lec in -->
    <%
	  	dTemp = 0d;
		strTemp = (String) vRows.elementAt(i+15); 
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp == 0d)
			strTemp = "";
	  %>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<!--// excess lab in -->
      <%
	  	dTemp = 0d;
		strTemp = (String) vRows.elementAt(i+16); 
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp == 0d)
			strTemp = "";
	  %>				
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
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
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%
	  	dTemp = 0d;
		strTemp = (String) vRows.elementAt(i+18); 
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp == 0d)
			strTemp = "";
	  %>	
			<!--Excess lec out-->
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<!--Excess lab out-->
      <%
	  	dTemp = 0d;
		strTemp = (String) vRows.elementAt(i+19); 
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp == 0d)
			strTemp = "";
	  %>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
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
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
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
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dTemp = CommonUtil.formatFloatToCurrency(dTemp, 2);
			adEarningTotal[iCols-2] = adEarningTotal[iCols-2] + dTemp;
			dLineTotal += dTemp;
			if(strTemp.equals("0"))
				strTemp = "";			
		%>      
      <td align="right" class="BOTTOMLEFT"><%=strTemp%></td>
			<%}%>
      <%
	  	dTemp = 0d;
			// COLA
	  	if (vRows.elementAt(i+25) != null){	
			strTemp = (String)vRows.elementAt(i+25); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
		dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
		dTotalCola += dTemp;
		dLineTotal += dTemp;
		strTemp = Double.toString(dTemp);
	  %>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
			<%
			if(vOTTypes != null && vOTTypes.size() > 0){
			 for(iOT = 0, iCols = 0;iOT < vOTTypes.size(); iOT+=19, iCols++){
				 strTemp = null;
				 iIndex = vEmpOT.indexOf((Integer)vOTTypes.elementAt(iOT));
				 if(iIndex != -1){
					 strTemp = (String)vEmpOT.elementAt(iIndex+2);					 
				 }

				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
				adTotalOT[iCols] = adTotalOT[iCols] + dTemp;
				dLineTotal += dTemp;
				strTemp = CommonUtil.formatFloat(dTemp,true);
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>			
			<td align="right" class="BOTTOMLEFT"><%=strTemp%></td>
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
		dOtherTotal +=dTempOthers;				
		strTemp = Double.toString(dTempOthers);
	  %>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
    <%
				/*
				dTemp = 0d;
				// adjustment amount
				if (vRows.elementAt(i+51) != null){	
				strTemp = (String)vRows.elementAt(i+51); 
				if (strTemp.length() > 0){
					dTemp = Double.parseDouble(strTemp);
				}
			}
			dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
			dLineTotal += dTemp;
			dTotalAdjust += dTemp;
			*/
	  %>	
		<%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			 for(iOT = 0, iCols = 0;iOT < vAdjTypes.size(); iOT+=19, iCols++){
				 strTemp = null;
				 iIndex = vEmpAdjust.indexOf((Integer)vAdjTypes.elementAt(iOT));
				 if(iIndex != -1){
					 strTemp = (String)vEmpAdjust.elementAt(iIndex+2);					 
				 }

				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
				adTotalAdj[iCols] = adTotalAdj[iCols] + dTemp;
 				strTemp = CommonUtil.formatFloat(dTemp,true);
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>
		 <td align="right" class="BOTTOMLEFT"><%=strTemp%></td>
      <%}
			}%>
				 
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
				adEarnDedTotal[iCols-1] = adEarnDedTotal[iCols-1] + dTemp;
				dLineTotal -= dTemp;
				if(strTemp.equals("0"))
					strTemp = "";			
			%>   			
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
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
		dTotalAbsences += dTemp;
		dLineTotal -= dTemp;
 	  %>
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp, true)%></td>
      <%
	  	dLineTotal += dBasic;
			dTotalGross += dLineTotal;
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"&nbsp;")%></td>
      <%
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
		dTotalSSS += dTemp;
		dEmpDeduct += dTemp;
		strTemp = Double.toString(dTemp);
//		System.out.println("SSS " +dTemp);
	  %>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
      <%
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
			dTotalHdmf += dTemp;
			dEmpDeduct += dTemp;
			strTemp = Double.toString(dTemp);
	//		System.out.println("hdmf " +dTemp);
			%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
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
		dTotalTax += dTemp;
		dEmpDeduct += dTemp;
		strTemp = Double.toString(dTemp);
//		System.out.println("Tax " +dTemp);
	  %>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
		<%for(iCols = 1;iCols <= iDedColCount/2; iCols ++){
			strTemp = (String)vDeductions.elementAt(iCols);
			dTemp = Double.parseDouble(strTemp);
			dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
			dEmpDeduct += dTemp;
			adDeductTotal[iCols-1] = adDeductTotal[iCols-1] + dTemp;			
			if(dTemp == 0d)
				strTemp = "";			
		%>      
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
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

		
		dTotalAdv += dOtherDed;
		dEmpDeduct += dOtherDed;
	  %>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dOtherDed,true),"&nbsp;")%></td>
      <%
		  dTotalDeductions += dEmpDeduct;
	  	%>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dEmpDeduct,true),"&nbsp;")%></td>
      <%
	  	// salary
	  	//if (vRows.elementAt(i+52) != null){	
			// strTemp = (String)vRows.elementAt(i+52); 
			// if (strTemp.length() > 0){
			// 	dTemp = Double.parseDouble(strTemp);
			// }
    	//}
	  dLineTotal = dLineTotal - dEmpDeduct;
	  dLineTotal = CommonUtil.formatFloatToCurrency(dLineTotal,2);
	  dTotalNet += dLineTotal;
	  %>
      <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"&nbsp;")%></td>
    </tr>
    <%}// end if 	
	} // end for loop%>
	<!--
    <tr> 
      <td height="33" class="BOTTOMLEFT"><div align="right"><font size="1"><strong>TOTAL :   </strong></font></div></td>
      <td class="BOTTOMLEFT"><div align="right"><font size="1">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dTotalBasic,true)," ")%></font></div></td>
      <td class="BOTTOMLEFT">&nbsp;</td>
      <td class="BOTTOMLEFT">&nbsp;</td>
      <td class="BOTTOMLEFT">&nbsp;</td>
      <td class="BOTTOMLEFT">&nbsp;</td>
      <td class="BOTTOMLEFT">&nbsp;</td>
      <td class="BOTTOMLEFT">&nbsp;</td>
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(dExtraTotal,true)%></font></td>
		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%> 
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(adEarningTotal[iCols-2],true)%></font></td>
			<%}%>
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(dTotalCola,true)%></font></td>
			<% for(iCols = 0;iCols < iOTType; iCols++){%>
			<td class="BOTTOMLEFT"><%=CommonUtil.formatFloat(adTotalOT[iCols],true)%></td>
			<%}%>
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(dOtherTotal,true)%></font></td>
			<% for(iCols = 0;iCols < iAdjType; iCols++){%>
			<td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(adTotalAdj[iCols],true)%></font></td>
			<%}%>
  		<%for(iCols = 1;iCols <= iEarnDedCount; iCols++){%> 
      <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(adEarnDedTotal[iCols-1],true)%></td>
      <%}%>			
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(dTotalAbsences,true)%></font></td>
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(dTotalGross,true)%></font></td>
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(dTotalSSS,true)%></font></td>
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(dTotalHdmf,true)%></font></td>
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(dTotalTax,true)%></font></td>
			<%for(iCols = 1;iCols <= (iDedColCount/2); iCols++){%> 
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(adDeductTotal[iCols-1],true)%></font></td>
			<%}%>
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(dTotalAdv,true)%></font></td>
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(dTotalDeductions,true)%></font></td>
      <td align="right" class="BOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat(dTotalNet,true)%></font></td>
    </tr>
		-->
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">  
  <input type="hidden" name="college_name" value="<%=WI.fillTextValue("college_name")%>">
  <input type="hidden" name="dept_name" value="<%=WI.fillTextValue("dept_name")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>