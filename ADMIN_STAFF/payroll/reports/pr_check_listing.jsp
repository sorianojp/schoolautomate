<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Check Listing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
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
	document.form_.transmit.value="";
	this.SubmitOnce("form_");
}
function SearchEmployee()
{
	CopyName();		
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	document.form_.transmit.value="";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.transmit.value="";
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function Transmit(){
	document.form_.transmit.value="1";
	document.form_.print_page.value="";
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

  if(document.form_.employer_index && document.form_.employer_index.value)
	document.form_.comp_name.value = document.form_.employer_index[document.form_.employer_index.selectedIndex].text;
  else
  	document.form_.comp_name.value = "";
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
<body>
<form name="form_" 	method="post" action="./atm_payroll_listing.jsp">
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
								"Admin/staff-Payroll-REPORTS-ATM Payroll List","payroll_summary_for_bank.jsp");
								
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
														"payroll_summary_for_bank.jsp");
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

if (WI.fillTextValue("print_page").length() > 0){ 
   if(strSchCode.startsWith("CGH")){%>
	<jsp:forward page="./atm_payroll_listing_print_cgh.jsp" />
	<%}else if(strSchCode.startsWith("UDMC")){%>
	<jsp:forward page="./atm_payroll_listing_print_udmc.jsp" />
	<%}else if(strSchCode.startsWith("WNU")){%>
	<jsp:forward page="./atm_payroll_listing_print_wnu.jsp" />
	<%}else if(strSchCode.startsWith("FATIMA")){%>
	<jsp:forward page="./atm_payroll_listing_print_fatima.jsp" />
	<%}else{%>
	<jsp:forward page="./atm_payroll_listing_print.jsp" />
<% }return;}

if (WI.fillTextValue("transmit").length() > 0){ %>
	<jsp:forward page="./atm_transmittal.jsp"/>
<% return;}

//end of authenticaion code.
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	Vector vRetResult = null;
	Vector vTemp = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	String strPayrollPeriod  = null;	
	String strTemp2 = null;
	double dSalary = 0d;
	if(bolIsSchool)
		strTemp2 = "College";
	else
		strTemp2 = "Division";
	
	String[] astrSortByName    = {strTemp2, "Department","Firstname","Lastname", "Bank Account"};
	String[] astrSortByVal     = {"c_name","d_name", "fname", "lname", "bank_account"};
	String strPayEnd = null;
	
	vRetResult = RptPay.searchEmpATMListing(dbOP);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}else{
			iSearchResult = RptPay.getSearchCount();
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
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
        <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

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
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>ATM/Non ATM </td>
		  <td><select name="atm_option">
        <option value="">All</option>
        <%if (WI.fillTextValue("atm_option").equals("0")){%>
        <option value="0" selected>Non ATM</option>
        <option value="1">ATM</option>
        <%}else if (WI.fillTextValue("atm_option").equals("1")){%>
        <option value="0" >Non ATM</option>
        <option value="1" selected>ATM</option>
        <%}else{%>
				<option value="0" >Non ATM</option>
        <option value="1">ATM</option>
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
		  <td height="10">&nbsp;</td>
		  <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("with_account");
				if(strTemp.equals("1"))
					strTemp = "checked";
				else
					strTemp = "";
			%>
		  <td height="10" colspan="3"><input type="checkbox" name="with_account" value="1" <%=strTemp%>>
		  Show only Employees with account numbers </td>
	  </tr>   
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
        <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
    <tr> 
      <td height="18" colspan="2"><div align="right"><font size="2">	    
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
    <%		
	int iPageCount = iSearchResult/RptPay.defSearchSize;		
	if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr> 
      <td colspan="2"><div align="right"><font size="2">Jump To page: 
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
	 
	 <%if(WI.fillTextValue("bank_index").length() > 0){%>		   
	 <tr>
      <td colspan="2"><a href="javascript:Transmit()"><strong>Create file for bank transmittal</strong></a></td>
   </tr>
	 <%}%>
	 <%if(strSchCode.startsWith("WNU")){%>
	 <tr>
	   <td>Account Number </td>
		 <%
		 		strTemp = WI.fillTextValue("account_no");
		 		if(strTemp.length() == 0)
					strTemp = "1870589912";
		 %>
	   <td><input type="text" name="account_no" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
	 <tr>
      <td width="20%">Credit on Date </td>
			<%
				strTemp = WI.fillTextValue("credit_date");
				if(strTemp.length() == 0)
					strTemp = strPayEnd;
			%>
      <td width="80%"><input name="credit_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.credit_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
	 </tr>	 
	 <%}else if(strSchCode.startsWith("FATIMA")){%>	
		<tr>
      <td width="20%" nowrap>Depository Branch Code </td>
			<%
				strTemp = WI.fillTextValue("dep_branch_code");
				if(strTemp.length() == 0)
					strTemp = "029";
			%>
      <td width="80%"><input name="dep_branch_code" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	 </tr>	 	 		
	 <%}%>
  </table>
  <%if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC")){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="24">&nbsp; </td>
      <td width="2%">&nbsp;</td>
      <% if (vRetResult!= null && vRetResult.size() > 1){
				strTemp = (String)vRetResult.elementAt(0);			
				}
			%>
      <td width="17%" height="24"><font size="1">&nbsp;<%=WI.getStrValue(strTemp," ")%></font></td>
      <td width="56%" height="24" align="center"><strong><font color="#0000FF">PAYROLL 
      DATE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
      <td width="22%" height="24">&nbsp;</td>
    </tr>
  </table>
	<%if(strSchCode.equals("CGH")){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="28%" align="center" class="thinborderBOTTOM">EMPLOYEE NAME</td>
      <td width="3%">&nbsp;</td>
      <td width="32%" align="center" class="thinborderBOTTOM">ACCOUNT NO</td>
      <td width="10%">&nbsp;</td>
      <td width="22%" align="center" class="thinborderBOTTOM">AMOUNT</td>
    </tr>
    <% int iCount = 0;
	if (vRetResult != null && vRetResult.size() > 0){	  
	  for(i = 1,iCount=1; i < vRetResult.size(); i += 9,++iCount){
	  %>
    <tr> 
      <td height="18"><div align="right"><%=iCount%></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></td>
      <td>&nbsp;</td>
      <%	
	  	strTemp = null;		
		strTemp = (String)vRetResult.elementAt(i+5);			
	  %>
      <td><div align="left">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strTemp," ")%></div></td>
      <td>&nbsp;</td>
      <% 
				strTemp = (String)vRetResult.elementAt(i+4);
				strTemp = WI.getStrValue(strTemp, "0");
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dSalary = Double.parseDouble(strTemp);
				strTemp = CommonUtil.formatFloat(dSalary, 2);
				dSalary = Double.parseDouble(strTemp);				
			%>
      <td><div align="right"><%=CommonUtil.formatFloat(dSalary,true)%>&nbsp;&nbsp;&nbsp;</div></td>
    </tr>
    <% } // end for loop
	 }// end if%>
  </table>
	<%}else{// UDMC%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM">Employee Name </td>
      <td width="3%" class="thinborderBOTTOM">&nbsp;</td>
      <td width="25%" align="center" class="thinborderBOTTOM">S/ Account#</td>
      <td width="7%" class="thinborderBOTTOM">&nbsp;</td>
      <td width="22%" align="center" class="thinborderBOTTOM">Net PAY </td>
    </tr>
    <% int iCount = 0;
	if (vRetResult != null && vRetResult.size() > 0){	  
	  for(i = 1,iCount=1; i < vRetResult.size(); i += 9,++iCount){
	  %>
    <tr> 
      <td height="18"><div align="right"><%=iCount%></div></td>
      <td>&nbsp;</td>
      <td width="19%">&nbsp;<%=((String)vRetResult.elementAt(i+3)).toUpperCase()%></td>
      <td width="19%"><%=((String)vRetResult.elementAt(i+1)).toUpperCase()%></td>
      <td>&nbsp;</td>
      <%	
	  	strTemp = null;		
		strTemp = (String)vRetResult.elementAt(i+5);			
	  %>
      <td><div align="left">&nbsp;<%=WI.getStrValue(strTemp," ")%></div></td>
      <td>&nbsp;</td>
      <% 
				strTemp = (String)vRetResult.elementAt(i+4);
				strTemp = WI.getStrValue(strTemp, "0");
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dSalary = Double.parseDouble(strTemp);
				strTemp = CommonUtil.formatFloat(dSalary, 2);
				dSalary = Double.parseDouble(strTemp);				
			%>
      <td><div align="right"><%=CommonUtil.formatFloat(dSalary,true)%>&nbsp;&nbsp;&nbsp;</div></td>
    </tr>
    <% } // end for loop
	 }// end if%>
  </table>	
	<%}%>
	<%}else if(strSchCode.startsWith("FATIMA")){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="13%" align="center" class="thinborderBOTTOM">Employee Number </td>
      <td width="40%" align="center" class="thinborderBOTTOM">Employee Name </td>
      <td width="2%">&nbsp;</td>      
      <td width="10%" align="center" class="thinborderBOTTOM">Depository Br. Code </td>
      <td width="15%" align="center" class="thinborderBOTTOM">Salary</td>
			<td width="15%" align="center" class="thinborderBOTTOM">ACCOUNT Number </td>
    </tr>
    <% int iCount = 0;
	if (vRetResult != null && vRetResult.size() > 0){	  
	  for(i = 1,iCount=1; i < vRetResult.size(); i += 9,++iCount){
	  %>
    <tr> 
      <td height="18"><div align="right"><%=iCount%></div></td>
      <td>&nbsp;</td>
			<%
			strTemp = (String)vRetResult.elementAt(i);	
			%>
      <td><font size="1"><%=WI.getStrValue(strTemp," ").toUpperCase()%></font></td>
      <td>&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></td>
      <td>&nbsp;</td>
      <td><%=WI.fillTextValue("dep_branch_code")%></td>
      <% 
				strTemp = (String)vRetResult.elementAt(i+4);
				strTemp = WI.getStrValue(strTemp, "0");
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dSalary = Double.parseDouble(strTemp);
				strTemp = CommonUtil.formatFloat(dSalary, 2);
				dSalary = Double.parseDouble(strTemp);				
			%>
      <td><div align="right"><%=CommonUtil.formatFloat(dSalary,true)%>&nbsp;&nbsp;&nbsp;</div></td>
      <%	
	  	strTemp = null;		
			strTemp = (String)vRetResult.elementAt(i+5);			
			%>
      <td><div align="left"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(strTemp," ")%></font></div></td>
    </tr>
    <% } // end for loop
	 }// end if%>
  </table>	
  <%}else{%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
    <tr>
      <td height="18" colspan="5" align="center"><strong><font color="#0000FF">PAYROLL 
      DATE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>
    <tr> 
      <td height="18"><div align="center">&nbsp;</div></td>
    <%if (vRetResult!= null && vRetResult.size() > 1 
		      && WI.fillTextValue("bank_index").length() > 0)
				strTemp = (String)vRetResult.elementAt(0);			
			else
				strTemp = "";
		
	%>
			<td height="18" colspan="3"><font size="1">&nbsp;<%=WI.getStrValue(strTemp,"")%></font></td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;
      <div align="center"></div></td>
			<%if(WI.fillTextValue("bank_index").length() > 0)
					strTemp = "ACCOUNT #";
				else
					strTemp = "Employee ID";
			%>
      <td width="21%" align="center"><font size="1"><strong><%=strTemp%></strong></font></td>
			
      <td width="4%" align="center">&nbsp;</td>
      <td width="51%" align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></td>
      <td width="22%" align="center"><font size="1"><strong>SALARY</strong></font></td>
    </tr>
    <% int iCount = 0;
	if (vRetResult != null && vRetResult.size() > 0){	  
	  for(i = 1,iCount=1; i < vRetResult.size(); i += 9,++iCount){%>
    <tr> 
      <td height="24"><div align="right"><%=iCount%></div></td>
      <%if(WI.fillTextValue("bank_index").length() > 0)
					strTemp = (String)vRetResult.elementAt(i+5);			
				else
					strTemp = (String)vRetResult.elementAt(i);			
			%>
			
			<td><font size="1">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strTemp," ").toUpperCase()%></font></td>			
      <td>&nbsp;</td>
      <td><font size="1"><strong><%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></strong></font></td>
      <% 
				strTemp = (String)vRetResult.elementAt(i+4);
				strTemp = WI.getStrValue(strTemp, "0");
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dSalary = Double.parseDouble(strTemp);
				strTemp = CommonUtil.formatFloat(dSalary, 2);
				dSalary = Double.parseDouble(strTemp);				
			%>
      <td align="right"><font size="1"><%=CommonUtil.formatFloat(dSalary,true)%>&nbsp;&nbsp;&nbsp;</font></td>
    </tr>
    <% } // end for loop
	 }// end if%>
  </table>
  <%}// end else not CGH%>
  <%}%>
  
  <%if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <%}%>
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_page" value="">  
  <input type="hidden" name="transmit" value="">  		
  <input type="hidden" name="college_name" value="<%=WI.fillTextValue("college_name")%>">
  <input type="hidden" name="dept_name" value="<%=WI.fillTextValue("dept_name")%>">	
	<input type="hidden" name="comp_name" value="<%=WI.fillTextValue("comp_name")%>">	
	<input type="hidden" name="end_date" value="<%=strPayEnd%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>