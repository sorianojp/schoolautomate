<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance, payroll.PReDTRME, payroll.PRTransmittal" %>

<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
 if(strSchCode == null)
	strSchCode = "";
boolean bolShowAll = false;

WebInterface WI = new WebInterface(request);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SSS unsorted monthly remittance</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	<%if(WI.fillTextValue("generate").length() > 0){%>
	display: block;
	<%}else{%>
	display: none;
	<%}%>
	margin-left: 16px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function Generate(strGen){
	document.form_.generate.value = strGen;
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}

function ClearDocNo() {
	if(document.form_.doc_no){
		document.form_.doc_no.value = "";
		document.form_.pay_order_no.value = "";
	}
}

function PrintCover() {
	var pgLoc = "sss_monthly_cover.jsp?month_of="+document.form_.month_of.value+
				"&year_of="+document.form_.year_of.value+
				"&employer_index="+document.form_.employer_index.value+
				"&certified_by="+document.form_.certified_by.value +
				"&sbr_no="+document.form_.sbr_no.value;
	var win=window.open(pgLoc,"View",'width=650,height=550,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ForwardTo(){

//	document.form_.forward_grouped.value = "1";
//	document.form_.print_pg.value = "";
//	this.SubmitOnce('form_');

location = "./sss_monthly.jsp?month_of="+document.form_.month_of.value+
					 "&year_of="+document.form_.year_of.value+
					 "&pt_ft="+document.form_.pt_ft.value+
					 "&employee_category="+document.form_.employee_category.value+
					 "&employer_index="+document.form_.employer_index.value+
					 "&c_index="+document.form_.c_index.value+
					 "&d_index="+document.form_.d_index.value+
					 "&searchEmployee=1&grouped=1";
}
///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
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

///////////////////////////////////////// End of collapse and expand filter ////////////////////

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	String strTemp2 = null;
	String strPayrollPeriod  = null;
	String strDateFrom = null;
	String strDateTo = null;
	String strHasWeekly = null;
	
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolHasTeam = false;
	boolean bolHasInternal = false;
	
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){
	if(strSchCode.startsWith("UPH")){%>
		<jsp:forward page="./sss_monthly_unsort_print_uph.jsp" />
	<%}%>
		<jsp:forward page="./sss_monthly_unsort_print.jsp" />
<% return;}
  
try
	{
		strTemp = (String)request.getSession(false).getAttribute("userId");
		if(strTemp != null && (strTemp.equals("bricks") || strTemp.equals("GTI-01")))
			bolShowAll = true;

		dbOP = new DBOperation(strTemp,
								"Admin/staff-Payroll-Reports-Remittances-SSS Premium","sss_monthly_unsort.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
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
														"sss_monthly_unsort.jsp");
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

//end of authenticaion code.

Vector vRetResult = null;
PReDTRME prEdtrME = new PReDTRME();
Vector vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
PRRemittance PRRemit = new PRRemittance(request);
PRTransmittal transmit = new PRTransmittal(request);

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
String[] astrPtFt = {"PART-TIME","FULL-TIME"};

double dTemp = 0d;
double dLineTotal = 0d;
String strEmployer = "";
String strFilename = null;
String strEPFFilename = null;
String strMCLFilename = null;
boolean bolShowER = WI.fillTextValue("er").length() > 0;
boolean bolShowEC = WI.fillTextValue("ec").length() > 0;

double dGrandEE = 0d;
double dGrandER = 0d;
double dGrandEC = 0d;
double dGrandTotal = 0d;

int i = 0;
int iMonth = 0;

	if(WI.fillTextValue("generate").length() > 0){
		if(WI.fillTextValue("generate").equals("2"))
	 		strEPFFilename = transmit.SSSPreValidationTransmittal(dbOP);
		else if(WI.fillTextValue("generate").equals("3"))
			strMCLFilename = transmit.SSSMCLTransmittal(dbOP);
		else		
			strFilename = transmit.SSSTransmittal(dbOP);
			
		if(strFilename == null && strEPFFilename == null)
			strErrMsg = transmit.getErrMsg();
		else
			strErrMsg = "File Creation successful<br>" + WI.getStrValue(transmit.getErrMsg(),"");
	}

if(WI.fillTextValue("searchEmployee").equals("1")){
  vRetResult = PRRemit.SSSMonthlyPremium(dbOP);
	if(strErrMsg == null || strErrMsg.length() == 0)
		strErrMsg = PRRemit.getErrMsg();
	else
		strErrMsg = "<br>" + strErrMsg;
		
	if(vRetResult != null)
		iSearchResult = PRRemit.getSearchCount();
}

if(strErrMsg == null) 
strErrMsg = "";
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="./sss_monthly_unsort.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: SSS PREMIUM MONTHLY REMITTANCES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="3"><font size="1"><a href="./remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="23" colspan="3"><strong><%=strErrMsg%></strong></td>
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
      <td width="77%">
	  	<strong><label id="sal_periods">
			<select name="sal_period_index" style="font-weight:bold;font-size:11px">
          <%

			String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};
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
					strDateFrom = (String)vSalaryPeriod.elementAt(i + 1);
					strDateTo = (String)vSalaryPeriod.elementAt(i + 2) ;
				
		 %>
			<option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%> </option>
				
          		<%}else{%>
          	<option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%></option>
          		<%}//end of if condition.
		 	}//end of for loop.%>
		 %>
        </select>
		</label>
        </strong>
		<%
			strTemp = WI.fillTextValue("is_monthly");
			if(strTemp.compareTo("1") == 0) 
				strTemp = " checked";
			else	
				strTemp = "";
		%>
        <input type="checkbox" name="is_monthly" value="1"  <%=strTemp%> />
        <font size="1">( Check if Monthly Transaction )</font>
		</td>
    </tr>

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
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <%if(bolIsSchool){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td><select name="employee_category" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
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
        </select>      </td>
    </tr>
    <%}else{%>
		<input type="hidden" name="employee_category" value="">
		<%}%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employer name </td>
      <td>
			<select name="employer_index" onChange="ReloadPage();">
<%
strEmployer = WI.fillTextValue("employer_index");
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
		
%>			<option value="<%=strTemp%>" <%=strErrMsg%>><%=rs.getString(2)%></option>
<%}
rs.close();
%>      </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td><!--
			<select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
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
%>
        <%=dbOP.loadCombo("c_index","c_name", strTemp,strCollegeIndex,false)%>
      </select>      </td>
    </tr>
     <tr>
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td><!-- <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> 
				-->
        <select name="d_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <% 
				if(bolIsDefEmployer)
					strTemp = " from department where is_del= 0 " +
										" and not exists(select * from pr_employer_mapping " +
										"   where pr_employer_mapping.d_index = department.d_index " +
										"   and employer_index <> " + strEmployer + ")";
				else
					strTemp = " from department where is_del= 0 " +
										" and exists(select * from pr_employer_mapping " +
										"   where pr_employer_mapping.d_index = department.d_index " +
										"   and employer_index = " + strEmployer + ")";
				if ((strCollegeIndex.length() == 0))
					strTemp += " and (c_index = 0 or c_index is null) ";
				else
					strTemp += " and c_index = " + strCollegeIndex;
				%>
          <%=dbOP.loadCombo("d_index","d_name", strTemp,WI.fillTextValue("d_index"),false)%>
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
		<%if(bolShowAll){%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Emp ID </td>
	    <td><input type="text" class="textbox" size="12" value="<%=WI.fillTextValue("emp_id")%>" name="emp_id"></td>
		</tr>
		<%}%>
		<tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = "";
				if(WI.fillTextValue("inc_resigned").length() > 0)
					strTemp = " checked";
			%>
      <td colspan="2"><input type="checkbox" name="inc_resigned" value="1" <%=strTemp%>>
      include resigned employees in report</td>
    </tr>		
		<tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = "";
				if(WI.fillTextValue("show_adjusted").length() > 0)
					strTemp = " checked";
			%>			
      <td colspan="2"><input type="checkbox" name="show_adjusted" value="1" <%=strTemp%> onChange="SearchEmployee();">
show adjusted contribution </td>
    </tr>		
		<%
 		if(bolHasInternal){
			strTemp = WI.fillTextValue("show_internal");
			if(strTemp.length() > 0)
				strTemp = "checked";
			else	
				strTemp = "";
		%>		
		<tr>
		  <td height="25">&nbsp;</td>
		  <td colspan="2"><input type="checkbox" name="show_internal" value="1" <%=strTemp%>>
	    show internal</td>
	  </tr>
		<%}%>
		<tr>
		  <td height="25">&nbsp;</td>
		<%
 			strTemp = WI.fillTextValue("view_all");
			if(strTemp.length() > 0)
				strTemp = "checked";
			else	
				strTemp = "";
		%>					
		  <td colspan="2"><input type="checkbox" name="view_all" value="1" <%=strTemp%>>show all result in single page</td>
	  </tr>
		
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><strong><font color="#0000FF">Check additional columns 
      to show in the report : <br>
      </font></strong><table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#E4EFFA">
    
    <tr>
      <td width="27%" height="21">
				<% 
				if (bolShowER)  
					strTemp = "checked";
	  		else 
					strTemp = "";
				%>
          <input type="checkbox" name="er" value="1" <%=strTemp%>>
        Employer Share (ER)</td>
      <td width="40%">
				<% 
				if (bolShowEC)  
					strTemp = "checked";
	  		else 
					strTemp = "";
				%>			
          <input type="checkbox" name="ec" value="1" <%=strTemp%>>
        Employer Compensation (EC)</td>
      </tr>
    
  </table></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%"><!--
			<a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
          <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
          <font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr>
      <td height="10" colspan="3"><a href="javascript:ForwardTo()">View grouped by Department </a></td>
    </tr>
    <tr>
      <td height="10" colspan="3"></td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 1){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"><hr size="1" color="#000000"></td>
  </tr>
    
    <tr>
      <td height="18"></td>
      <td> Note: Employees with invalid entries will not be included in the transmittal list. 
			<div onClick="showBranch('branch6');swapFolder('folder6')">
          <img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
          <b><font color="#0000FF">SSS Transmittal</font></b></div>
        <span class="branch" id="branch6">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
						<%
							strTemp = WI.fillTextValue("branch_code");
						%>					
            <td>Code&nbsp;				
            <input type="text" class="textbox" name="branch_code" value="<%=WI.getStrValue(strTemp,"20")%>" size="5" maxlength="2"></td>
            <td colspan="2">&nbsp;</td>
          </tr>
          <tr>
						<%
							strTemp = WI.fillTextValue("sbr_no");
						%>					
            <td colspan="3">Trans/SBR No. 
            <input type="text" class="textbox" name="sbr_no" value="<%=WI.getStrValue(strTemp)%>" size="15"></td>
          </tr>

          <tr>
					<%
						strTemp = WI.fillTextValue("certified_by");
						if(strTemp.length() == 0)
							strTemp = CommonUtil.getNameForAMemberType(dbOP,"Payroll/HR Personnel",7);
						if(strTemp == null || strTemp.length() == 0)
							strTemp = (String)request.getSession(false).getAttribute("first_name");
					%>
            <td colspan="3">Certified by : 
            	<input type="text" class="textbox" name="certified_by" value="<%=WI.getStrValue(strTemp,"20")%>" size="64" maxlength="64">
			</td>
          </tr>
		  <tr>
            <td colspan="3">File Format: 
				<select name="fileformat" >
					<%if (WI.fillTextValue("fileformat").matches("1|")){%>
						<option value="1" selected>Foramt 1</option>
						<option value="2">Format 2</option>
						<option value="3">Format 3</option>
					<%}else if (WI.fillTextValue("fileformat").equals("2")){%>
						<option value="2" selected>Format 2</option>
						<option value="3">Format 3</option>
						<option value="1">Format 1</option>
					<%} else {%>
						<option value="3" selected>Format 3</option>
						<option value="2">Format 2</option>
						<option value="1">Format 1</option>
					<%}%>
				</select>
			</td>
          </tr>
          <tr>
            <td width="36%"><input type="button" name="proceed_btn2" value=" GENERATE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:Generate('1');"></td>						
            <%if(strFilename != null && strFilename.length() > 0){%>
						<td width="22%">&nbsp;
						<a href="../../../../download/nr3001dk.txt" target="_blank">
							<img src="../../../../images/download.gif" width="72" height="27" border="0">						</a>						</td>
            <td width="42%"><a href="javascript:PrintCover()">
						<img src="../../../../images/print.gif" border="0"></a> 
						<font size="1">click to print transmittal summary </font></td>
						<%}%>						
          </tr>
        </table>
      </span> </td>
    </tr>
		
    <%if(strSchCode.startsWith("TSUN") || strSchCode.startsWith("TAMIYA") || 
				strSchCode.startsWith("CIT") || bolShowAll){%>
    <tr>
      <td height="18"></td>
      <td><div onClick="showBranch('branch1');swapFolder('folder1')">
          <img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
          <b><font color="#0000FF">Employee Pre-Validation File</font></b></div>
        <span class="branch" id="branch1">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="50%"><input type="button" name="proceed_btn2" value=" GENERATE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:Generate('2');">
            <%if(strEPFFilename != null && strEPFFilename.length() > 0){%>
						<a href="../../../../download/epf.txt" target="_blank"><img src="../../../../images/download.gif" width="72" height="27" border="0"></a>
						<%}%>						</td>						
						<td width="50%">&nbsp;</td>            
          </tr>
        </table>
      </span> </td>
    </tr>
		<tr>
      <td height="18"></td>
      <td><div onClick="showBranch('branch2');swapFolder('folder2')">
          <img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2">
          <b><font color="#0000FF">SSS MCL </font></b></div>
        <span class="branch" id="branch2">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td>Document #</td>
						<%
							strTemp = WI.fillTextValue("doc_no");
							if(strTemp.length() == 0){
								iMonth = Integer.parseInt(WI.fillTextValue("month_of")) + 1;
								strTemp = Integer.toString(iMonth);
								if(strTemp.length() == 1)
									strTemp = "0" + strTemp;
								strTemp = WI.fillTextValue("year_of") + strTemp;
							}
							
						%>
            <td><input type="text" class="textbox" name="doc_no" value="<%=WI.getStrValue(strTemp)%>" 
						size="8" maxlength="6" onKeyUp="AllowOnlyInteger('form_','doc_no')" 
						onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','doc_no')"
					  onFocus="style.backgroundColor='#D3EBFF'"></td>
          </tr>
          <tr>
            <td>Transmission date</td>
						<%
							strTemp = WI.fillTextValue("transmit_date");
							if(strTemp.length() == 0)
								strTemp = WI.getTodaysDate(1);
						%>
            <td><input name="transmit_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
              <a href="javascript:show_calendar('form_.transmit_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
          </tr>
          <tr>
            <td>Branch Code</td>
						<%
							strTemp = WI.fillTextValue("mcl_branch_code");
						%>
            <td><input type="text" class="textbox" name="mcl_branch_code" value="<%=WI.getStrValue(strTemp)%>" size="5" maxlength="3"></td>
          </tr>
          <tr>
            <td>Locator Code</td>
						<%
							strTemp = WI.fillTextValue("locator_code");
						%>
            <td><input type="text" class="textbox" name="locator_code" value="<%=WI.getStrValue(strTemp)%>" size="5" maxlength="3"></td>
          </tr>
          <tr>
            <td>Payment Order # </td>
						<%
							strTemp = WI.fillTextValue("pay_order_no");
							if(strTemp.length() == 0){
								iMonth = Integer.parseInt(WI.fillTextValue("month_of")) + 1;								
								strTemp = Integer.toString(iMonth);
								if(strTemp.length() == 1)
									strTemp = "0" + strTemp;
								if(strTemp.equals("02"))									
									strTemp = WI.fillTextValue("year_of") + strTemp + "28";
								else
									strTemp = WI.fillTextValue("year_of") + strTemp + "30";
							}							
						%>						
            <td>
            <input type="text" class="textbox" name="pay_order_no" value="<%=WI.getStrValue(strTemp)%>" 
						size="10" maxlength="8" onKeyUp="AllowOnlyInteger('form_','pay_order_no')" 
						onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','pay_order_no')"
					  onFocus="style.backgroundColor='#D3EBFF'"></td>
          </tr>
          <tr>
            <td width="17%"><input type="button" name="proceed_btn2" value=" GENERATE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:Generate('3');">            </td>						
						<td width="83%">
						<%if(strMCLFilename != null && strMCLFilename.length() > 0){%>
						<a href="../../../../download/sss_mcl.txt" target="_blank"><img src="../../../../images/download.gif" width="72" height="27" border="0"></a>
						<%}%></td>            
          </tr>
        </table>
      </span> </td>
    </tr>		
		<%} // END FOR TSUNEISHI%>
    <tr> 
      <td height="18"></td>
      <td align="right"><font><a href="javascript:PrintPg()"> </a></font><font size="2"> Number of Employees Per 
          Page :</font><font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 15; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
      </font><font><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></td>
    </tr>
    <tr>
      <td height="18"></td>
      <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="13%">Prepared by</td>
					<%
						strTemp = WI.fillTextValue("prepared_by");
						if(strTemp.length() == 0)
							strTemp = CommonUtil.getNameForAMemberType(dbOP,"Payroll/HR Personnel",7);

						if(strTemp == null || strTemp.length() == 0)
							strTemp = (String)request.getSession(false).getAttribute("first_name");
					%>
          <td width="87%"><input type="text" class="textbox" name="prepared_by" value="<%=WI.getStrValue(strTemp)%>" size="64" ma2length="64"></td>
        </tr>
        <tr>
          <td>Position</td>
					<%
						strTemp = WI.fillTextValue("position");
						if(strTemp.length() == 0){
							if(strSchCode.startsWith("TSUNEISHI"))
								strTemp = "HR STAFF";
							else
								strTemp = "HR/PAYROLL OFFICER";
						}						
					%>
          <td><input type="text" class="textbox" name="position" value="<%=WI.getStrValue(strTemp)%>" size="64" ma2length="64"></td>
        </tr>
      </table></td>
    </tr>
    
    <%		
	if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/PRRemit.defSearchSize;
	if(iSearchResult % PRRemit.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr>
      <td height="18" colspan="2" align="right"><font size="2">Jump To page:
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
      </font></td>
    </tr>
		<%}
		}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="7"><div align="center"><strong>SSS Premiums - <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
  </tr>
  <tr>
    <td height="18" colspan="3">&nbsp;Records found : <%=iSearchResult%></td>
    <td>&nbsp;</td>
    <%if(bolShowER){%>
		<td>&nbsp;</td>
		<%}%>
		<%if(bolShowEC){%>
    <td>&nbsp;</td>
		<%}%>
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td width="3%">&nbsp;</td>
    <td width="18%" align="center"><strong>SSS number </strong></td>
    <td width="37%">&nbsp;</td>
    <td width="10%" align="center"><strong>EE</strong></td>
		<%if(bolShowER){%>
    <td width="10%" align="center"><strong>ER</strong></td>
		<%}%>
		<%if(bolShowEC){%>
    <td width="11%" align="center"><strong>EC</strong></td>
		<%}%>
    <td width="11%" align="center"><strong>TOTAL</strong></td>
    </tr>
  <%for(i = 3; i < vRetResult.size();i+=19){
 	dLineTotal = 0d;
  %>
  
  <tr>
    <td height="23">&nbsp;</td>
    <td>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%></td>
    <td>&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%> </td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dGrandEE += dTemp;
		dLineTotal += dTemp;
	%>
    <td align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
	<%if(bolShowER){%>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);	
		dGrandER += dTemp;	
		dLineTotal += dTemp;
	%>	
    <td align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
		<%}%>
		<%if(bolShowEC){%>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dGrandEC += dTemp;
		dLineTotal += dTemp;		
	%>	
    <td align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
		<%}
		dGrandTotal += dLineTotal;
		%>
    <td align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"")%>&nbsp;</td>
  </tr>
  <%}%>
	<%if(WI.fillTextValue("view_all").length() > 0){%>
	<tr>
    <td height="23" class="thinborderTOP">&nbsp;</td>
    <td class="thinborderTOP">&nbsp;</td>
    <td align="right" class="thinborderTOP"><strong>GRAND TOTAL </strong></td>
    <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dGrandEE ,true)%>&nbsp;</td>
    <%if(bolShowER){%>
		<td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dGrandER ,true)%>&nbsp;</td>
		<%}%>
		<%if(bolShowEC){%>
    <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dGrandEC ,true)%>&nbsp;</td>
		<%}%>
    <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dGrandTotal ,true)%>&nbsp;</td>
  </tr>  
	<%}%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>

<%} // if (vRetResult != null && vRetResult.size() > 0 )%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25">&nbsp;</td>
  </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="grouped" value="0">
	<input type="hidden" name="generate">		
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>