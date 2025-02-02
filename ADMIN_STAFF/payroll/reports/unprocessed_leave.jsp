<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>ATM Payroll listing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
    TABLE.thinborder {
    border-right: solid 1px #000000;
		border-top: solid 1px #000000;
  	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
		border-bottom: solid 1px #000000;
  	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
    }
		
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
  	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
    }
		
    TD.thinborderBOTTOMRIGHT {
    border-bottom: solid 1px #000000;
		border-right: solid 1px #000000;
  	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
    }		
		
    TD.thinborderBOLDBOTTOM {
    border-bottom: solid 2px #000000;
  	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
    }		
    TD.thinborderBOTTOMTOP {
    border-bottom: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
    }		
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	CopyName();
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function SearchEmployee()
{
	CopyName();		
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
 
function CopyName(){
  if(document.form_.c_index.value)
		document.form_.college_name.value = document.form_.c_index[document.form_.c_index.selectedIndex].text;
  else
  	document.form_.college_name.value = "";

  if(document.form_.d_index && document.form_.d_index.value)
	document.form_.dept_name.value = document.form_.d_index[document.form_.d_index.selectedIndex].text;
  else
  	document.form_.dept_name.value = "";
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}
///ajax here to load dept..
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


function loadClonedPeriod() {
	if(!document.form_.month_to)
		return;
	var strMonth = document.form_.month_to.value;
	var strYear = document.form_.year_to.value;
	var strWeekly = null;
	var strSalPeriod = document.form_.sal_period_index.value;
	
	if(document.form_.is_weekly){
		if(document.form_.is_weekly.checked)
			strWeekly = "1";
		else
			strWeekly = "";
	}
 	if(strSalPeriod.length == 0){		
		strSalPeriod = document.form_.sal_period_index[document.form_.sal_period_index.selectedIndex].value;
	}
 	var objCOAInput = document.getElementById("clone_periods");
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=304&month_to="+strMonth+
							 "&year_to="+strYear+"&is_weekly="+strWeekly+"&month_name=month_to&year_name=year_to"+
							 "&sal_period_index="+strSalPeriod;

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

function SaveData() {
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "1";
	document.form_.save.disabled = true;
	//document.form_.hide_save.src = "../../../../images/blank.gif";
	this.SubmitOnce('form_');
}
</script>
<body onLoad="loadClonedPeriod();">
<form name="form_" 	method="post" action="./unprocessed_leave.jsp">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	int i = 0;	
	String strUserID = (String)request.getSession(false).getAttribute("userId");
	boolean bolHasConfidential = false;
	boolean bolHasTeam = false;
		
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-ATM Payroll List","unprocessed_leave.jsp");
								
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
														"Payroll","REPORTS",request.getRemoteAddr(),
														"unprocessed_leave.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

String strSchCode = dbOP.getSchoolIndex();

//end of authenticaion code.
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	Vector vRetResult = null;
	Vector vTemp = null;
	Vector vLeaves = null;
	ReportPayrollExtn RptPayExtn = new ReportPayrollExtn(request);
	String strPayrollPeriod  = null;	
	String strTemp2 = null;	
	double dSalary = 0d;
	if(bolIsSchool)
		strTemp2 = "College";
	else
		strTemp2 = "Division";
	
	String[] astrSortByName = {strTemp2, "Department","Firstname","Lastname", "Bank Account"};
	String[] astrSortByVal  = {"c_name","d_name", "fname", "lname", "bank_account"};
	String[] astrAdjOption  = {"", "Set leave as processed/used","Create adjustment for a salary period"};
	String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
								"September","October","November","December"};

	String strPayEnd = null;
	Vector vEmpLeave = null;
	
	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0){
		if(RptPayExtn.operateOnUnprocessedLeave(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = RptPayExtn.getErrMsg();
		} else {
			if(strPageAction.equals("1"))
				strErrMsg = "Schedule successfully posted.";		
		}
	}
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
		vRetResult = RptPayExtn.operateOnUnprocessedLeave(dbOP, request, 4);
			if(vRetResult == null){
				strErrMsg = RptPayExtn.getErrMsg();
			}else{
				iSearchResult = RptPayExtn.getSearchCount();
			}
	}
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL: EMPLOYEE PAYROLL LIST  ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
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
	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
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
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - " + (String)vSalaryPeriod.elementAt(i + 7);
			strPayEnd = (String)vSalaryPeriod.elementAt(i + 7);
		%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> 
          <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> 
          <%=strTemp2%></option>
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
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Employee Status</td>
      <td height="10" colspan="3"><select name="pt_ft" onChange="ReloadPage();">
        <option value="" selected>All</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part - time</option>
        <option value="1">Full - time</option>
        <%}else if (WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="0">Part - time</option>
        <option value="1" selected>Full - time</option>
        <%}else {%>
        <option value="0">Part - time</option>
        <option value="1">Full - time</option>
        <%}%>
      </select></td>
    </tr>
     <%if(bolIsSchool){%>		
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee Category</td>
      <td height="10" colspan="3"><select name="employee_category" onChange="ReloadPage();">
        <option value="" selected>All</option>
        <%if (WI.fillTextValue("employee_category").equals("0")){%>
        <option value="0" selected>Non-Teaching</option>
        <option value="1">Teaching</option>
        <%}else if (WI.fillTextValue("employee_category").equals("1")){%>
        <option value="0">Non-Teaching</option>
        <option value="1" selected>Teaching</option>
        <%}else{%>
        <option value="0">Non-Teaching</option>
        <option value="1">Teaching</option>
        <%}%>
      </select></td>
    </tr>
    <%}else{%>
    <input type="hidden" name="employee_category" value="">
    <%}%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Position</td>
      <td height="10" colspan="3"><select name="emp_position">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE " +
				" where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_position"), false)%>
      </select></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Employer name </td>
      <td height="10" colspan="3">
			<select name="employer_index" onChange="ReloadPage();">
			<%
			String strEmployer = WI.fillTextValue("employer_index");
			boolean bolIsDefEmployer = false;
			java.sql.ResultSet rs = null;
			strTemp = "select employer_index, employer_name, is_default from pr_employer_profile where is_del = 0 order by is_default desc";
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
					
			%>			<option value="<%=strTemp%>" <%=strErrMsg%>><%=rs.getString(2)%></option>
			<%}
			rs.close();
			%>      
			</select>			</td>
    </tr>
    <% 	
		String strCollegeIndex = WI.fillTextValue("c_index");	
		if(strEmployer != null && strEmployer.length() > 0){
		%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="10" colspan="3"> <select name="c_index" onChange="ReloadPage();">
<%  
if(bolIsDefEmployer)
	strTemp = " from college where is_del= 0 and not exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.c_index = college.c_index and employer_index <>"+strEmployer+")";
else
	strTemp = " from college where is_del= 0 and exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.c_index = college.c_index and employer_index ="+strEmployer+")";
%>
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", strTemp, strCollegeIndex,false)%> </select></td>
    </tr>
		<%if(strCollegeIndex.length() == 0){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Department/Office</td>
      <td height="26" colspan="3">
			<label id="load_dept">
			<select name="d_index">
          <option value="">N/A</option>
<% 
if(bolIsDefEmployer)
	strTemp = " from department where is_del= 0 and (c_index is null or c_index = 0) and not exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.d_index = department.d_index and employer_index <>"+strEmployer+")";
else
	strTemp = " from department where is_del= 0 and (c_index is null or c_index = 0) and exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.d_index = department.d_index and employer_index ="+strEmployer+")";
%>
        <%=dbOP.loadCombo("d_index","d_name", strTemp,WI.fillTextValue("d_index"),false)%>
        </select>
			</label>			</td>
    </tr>
		<%}
		}%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Office/Dept filter</td>
      <td height="10" colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID</td>
      <td height="10" colspan="3"><input name="emp_id" type="text" size="16"maxlength="128" value="<%=WI.fillTextValue("emp_id")%>"
											onKeyUp="AjaxMapName(1);"><label id="coa_info"></label>	</td>
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
      <td height="10">Process Option</td>
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
		   
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<%if(!strSchCode.startsWith("CGH")){%>
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=RptPayExtn.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=RptPayExtn.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=RptPayExtn.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
		<%}%>
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
				<input name="image" type="image" onClick="ReloadPage()" src="../../../images/form_proceed.gif"> 
				-->
				<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:SearchEmployee();">
				<font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
  </table>	
	<% if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <!--
		<tr> 
      <td height="18"><div align="right"><font size="2">	    
		Number of Employees Per Page :</font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i =20; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}
			}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></div></td>
    </tr>
		-->
    <%		
	int iPageCount = iSearchResult/RptPayExtn.defSearchSize;		
	if(iSearchResult % RptPayExtn.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr> 
      <td><div align="right"><font size="2">Jump To page: 
          <select name="jumpto" onChange="SearchEmployee();">
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
          </font></div></td>
   </tr>
	 <%}%>
  </table>  
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="7" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    <tr>
      <td width="8%" class="thinborder">&nbsp;</td>
      <td width="13%" class="thinborder">&nbsp;</td> 
      <td width="35%" height="23" align="center" class="thinborderBOTTOMRIGHT"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="44%" align="right" class="thinborder"><font size="1">
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
      </font></td>
			<%if(WI.fillTextValue("viewOption").equals("1")){%>
      <!--
			<td width="5%" align="center" class="thinborder"><strong><font size="1">HOURS ABSENT <br>
            <a href="javascript:CopyHour();">Copy all</a></font></strong></td>
			<td width="5%" align="center" class="thinborder"><strong><font size="1">MINUTES ABSENT <br>
            <a href="javascript:CopyMinute();">Copy all</a></font></strong></td>
			-->			
			<%}else{%>
      <%}%>
    </tr>
    <% 	int iCount = 1;
			int iLeaves = 0;
			int iInner = 1;
	   for (i = 0; i < vRetResult.size(); i+=15,iCount++){
		 vLeaves = (Vector)vRetResult.elementAt(i+7);
		 %>
    <tr>
      <td align="right" valign="top" class="thinborder"><%=iCount%>&nbsp;</td>
      <td valign="top" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="21" valign="top" class="thinborderBOTTOMRIGHT"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="id_number_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
			<input type="hidden" name="u_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">		
      <td class="thinborder">
			<%if(vLeaves != null && vLeaves.size() > 0){
 			%>
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<%for(iLeaves = 0; iLeaves < vLeaves.size(); iLeaves+=12, iInner++){%>
				<input type="hidden" name="info_index_<%=iInner%>" value="<%=(String)vLeaves.elementAt(iLeaves+4)%>">			
				<input type="hidden" name="leave_date_<%=iInner%>" value="<%=(String)vLeaves.elementAt(iLeaves+1)%>">							
        <tr>
          <td width="41%" height="21" align="right" class="thinborderBOTTOM"><font size="1"><%=vLeaves.elementAt(iLeaves+1)%></font>&nbsp;</td>
					<input type="hidden" name="amount_<%=iInner%>" value="<%=vLeaves.elementAt(iLeaves+6)%>">
          <td width="41%" align="right" class="thinborderBOTTOM"><font size="1"><%=vLeaves.elementAt(iLeaves+6)%></font>&nbsp;</td>
          <td width="18%" align="center" class="thinborderBOTTOM"><input type="checkbox" name="save_<%=iInner%>" value="1" checked tabindex="-1"></td>
        </tr>				
				<%}%>
      </table>
			<%}%>			
			</td>  
    </tr>
    <%} //end for loop%>
	</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" align="right">Transaction option : </td>
			<%
				strTemp = WI.fillTextValue("adj_option");
			%>
      <td height="25">
				<select name="adj_option">
					<%for(i = 1; i < astrAdjOption.length; i++){
						if(strTemp.equals(Integer.toString(i))){
					%>
						<option value="<%=i%>" selected><%=astrAdjOption[i]%></option>
					<%}else{%>
						<option value="<%=i%>"><%=astrAdjOption[i]%></option>
					<%}
					}%>				
				</select>			 </td>
      </tr>
    <tr>
      <td width="20%" height="25" align="right">Month-Year : </td>
      <td width="80%" height="25"><select name="month_to" onChange="loadClonedPeriod();">
        <%=dbOP.loadComboMonth(WI.fillTextValue("month_to"))%>
      </select>
-
<select name="year_to" onChange="loadClonedPeriod();">
  <%=dbOP.loadComboYear(WI.fillTextValue("year_to"),2,1)%>
</select></td>
      </tr>
    <tr>
      <td height="25" align="right">Salary period : </td>
      <td height="25"><strong>
       <label id="clone_periods">
				<select name="sal_index_to" style="font-weight:bold;font-size:11px">          
				<%
	 	strTemp = WI.fillTextValue("sal_index_to");		
		
		for(i = 0;	vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%></option>
          <%}//end of if condition.		  
		 }//end of for loop.%>
        </select>
				</label>
      </strong></td>
    </tr>
    <tr>
      <td height="25" colspan="2">Note : salary period will be ignored if you choose to set the leave as used. </td>
    </tr>
    <tr>
      <td height="25" colspan="2" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2" align="center">
				<%if(iAccessLevel > 1){%>
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
				<font size="1">Click to save entries</font>
			  <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
				  <font size="1"> click to cancel</font>
				<%}%>			</td>
    </tr>
    <input type="hidden" name="emp_count" value="<%=iInner%>">
  </table>
  <%}%>
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_page" value="">  
  <input type="hidden" name="college_name" value="<%=WI.fillTextValue("college_name")%>">
  <input type="hidden" name="dept_name" value="<%=WI.fillTextValue("dept_name")%>">	
	<input type="hidden" name="end_date" value="<%=strPayEnd%>">	
	<input type="hidden" name="page_action">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>