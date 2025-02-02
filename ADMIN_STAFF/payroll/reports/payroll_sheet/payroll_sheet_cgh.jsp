<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Sheet/Register</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.NoBorder {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }	
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.thinborderBOTTOMTOP {
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 11px;
    }

	TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
	font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
	font-size: 8px;
    }
    TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 8px;
    }    
	TD.thinborder {
	border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;	
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
	document.form_.print_pg.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
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
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
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
</script>

<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	String strUserID = (String)request.getSession(false).getAttribute("userId");
	boolean bolShowLink = false;
	if(strUserID != null && strUserID.equals("bricks"))
		bolShowLink = true;
//add security here.


if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./payroll_sheet_cgh_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation(strUserID,
								"Admin/staff-Payroll-REPORTS-Payroll Sheet FT","payroll_sheet_cgh.jsp");
								
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
														"payroll_sheet_cgh.jsp");
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
	String strHourlyRate = null;
	String strSchCode = dbOP.getSchoolIndex();
//	int iStart = 29; // this is where the null fields start
	int iFieldCount = 75;
	String strDateFrom = null;
	String strDateTo = null;

	double dBasic = 0d;
	double dTemp = 0d;
	double dTotalSalary = 0d;			
	double dTotalBasic = 0d;
	double dTotalAbsences = 0d;
	double dTotalIncentive = 0d;
	double dTotalHonorarium = 0d;
	double dTotalRice = 0d;
	double dTotalOT = 0d;
	double dTotalOverload = 0d;
	double dTotalCola = 0d;
	double dTotalSubsist = 0d;	
	double dTotalGross = 0d;
	double dTotalPhealth = 0d;
	double dTotHdmfLoan = 0d;
	double dTotalTax = 0d;
	double dTotalSSS = 0d;
	double dTotSSSLoan = 0d;
	double dTotalHdmf = 0d;		
	double dTotalNetBasic = 0d;
	double dTotalNetPay = 0d;
	double dLineTotal = 0d;
	double dTotalOtherDed = 0d;
	double dTotalOtherLoan = 0d;
	double dTotalSubTeach = 0d;
	double dTotalOtherEarn = 0d;
	double dTempHours = 0d;
		
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;

	Vector vRetResult = null;
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;

	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;
	Vector vOTDetail = null;
	Vector vSalDetail = null;
	Vector vLateUtDetail = null;
	Vector vAWOL = null;
	String strDeanName = null;
	double dOtherEarn = 0d;
	double dOtherDed  = 0d;
	String strUserIndex = null;
	int iIndex = 0;
		
	vRetResult = RptPSheet.getPSheetItems(dbOP);
	vAWOL = RptPSheet.getAWOLHours(dbOP,request);
	if(vRetResult == null)
		strErrMsg = RptPSheet.getErrMsg();
	else{
		vRows = (Vector)vRetResult.elementAt(0);
		vEarnCols = (Vector)vRetResult.elementAt(1);
		vDedCols = (Vector)vRetResult.elementAt(2);		
		vEarnDedCols = (Vector)vRetResult.elementAt(3);			
				
		if(vEarnCols != null && vEarnCols.size() > 0)
			iEarnColCount = vEarnCols.size() - 2;

		if(vDedCols != null && vDedCols.size() > 0)
			iDedColCount = vDedCols.size() - 1;		

		if (vEarnDedCols != null && vEarnDedCols.size() > 0)
			iEarnDedCount = vEarnDedCols.size()- 1;
			
		iSearchResult = RptPSheet.getSearchCount();		
	}

	double[] adEarningTotal = new double[iEarnColCount];
	double[] adDeductTotal = new double[iDedColCount];	
	double[] adEarnDedTotal = new double[iEarnDedCount];

	if(WI.fillTextValue("c_index").length() > 0){
		strDeanName = dbOP.mapOneToOther("college","c_index",WI.fillTextValue("c_index"),"dean_name","");
	}

 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body>
<form name="form_" 	method="post" action="payroll_sheet_cgh.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL: PAYROLL SHEET PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><font size="1">&nbsp;<a href="./payroll_sheet_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
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
		
		for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
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
        <%}// check if the company has weekly salary type%>      </td>
    </tr>
		<%if(strSchCode.startsWith("CGH")){%>
			<input type="hidden" name="pt_ft" value="1">
		<%}else{%>
		<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><select name="pt_ft" onChange="ReloadPage();">
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
		<%}%>
		<%if(bolIsSchool){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3">
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
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"> <select name="c_index" onChange="document.form_.noted_by.value='';loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"> 
				<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> 
				</label>			</td>
    </tr>
    <%if(bolShowLink){%>
		<tr>
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10" colspan="3">
			<input type="type" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" onKeyUp="AjaxMapName();">
				<div style="position:absolute; overflow:auto; width:300px;">
				<label id="coa_info"></label>
				</div></td>
    </tr>
		<%}%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Salary base</td>
      <td height="10" colspan="3"><select name="salary_base" onChange="ReloadPage();">
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
      <td height="10">&nbsp;</td>
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
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td width="26%" height="29"><select name="sort_by1">
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

      <td width="29%" height="29"><select name="sort_by2">
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

      <td width="29%" height="29"><select name="sort_by3">
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
      <td width="13%" height="15">&nbsp;</td>
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
      <td height="10" colspan="3"><font size="1">
        <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
        click to display employee list to print.</font></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Prepared By: </td>
			<%
				strTemp = WI.fillTextValue("prepared_by");
				if(strTemp.length() == 0)
					strTemp = CommonUtil.getNameForAMemberType(dbOP,"Payroll/HR Personnel",7);
				if( strTemp == null || strTemp.length() == 0)
					strTemp = (String)request.getSession(false).getAttribute("first_name");
			%>			
      <td height="10" colspan="3"><input type="text" name="prepared_by" maxlength="128" size="32" value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Reviewed By: </td>			
			<%
				strTemp = WI.fillTextValue("reviewed_by");
				if(strTemp.length() == 0)
					strTemp = CommonUtil.getNameForAMemberType(dbOP,"Assistant for Administrative Affairs",7);
				strTemp = WI.getStrValue(strTemp);
			%>						
      <td height="10" colspan="3"><input type="text" name="reviewed_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
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
      <td height="10" colspan="3"><input type="text" name="noted_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
    </tr>
    
    <tr> 
      <td height="10">&nbsp;</td>
 	  <% if (vRows != null && vRows.size() > 0 ){%>
      <td height="10" colspan="4"><div align="right"><font size="2">Font size of Printout:
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
          Page :</font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i = 15; i <=50 ; i++) {
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
          <%}%>
        </div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="23"><div align="center"><strong><font color="#0000FF">PAYROLL 
          SHEET FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></div></td>
    </tr>
    <tr> 
      <td width="7%" height="33" rowspan="2" align="center" class="thinborderBOTTOM">NAME 
          OF EMPLOYEE </td>
			<!--
      <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">BASIC</td>
			-->
      <td width="3%" rowspan="2" align="center" class="thinborderBOTTOM">SEMI-MO</td>
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOM">RATE 
          PER HOUR</td>
      <td height="33" colspan="2" align="center" class="NoBorder">UT / ABSENCES</td>
      <td width="4%" colspan="2" align="center" class="NoBorder">NET 
          BASIC </td>
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOM">OT 
          RATE</td>
      <td width="6%" rowspan="2" align="center" class="thinborderBOTTOM">OVERTIME</td>
			<%if(WI.fillTextValue("employee_category").equals("1")){%>
      <td width="4%" colspan="2" align="center" class="NoBorder">OVERLOAD</td>
			<%}%>
			<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
      <td rowspan="2" align="center" class="thinborderBOTTOM"><%=(String)vEarnCols.elementAt(iCols)%></td>			
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td rowspan="2" align="center" class="thinborderBOTTOM"><%=(String)vEarnDedCols.elementAt(iCols)%></td>
			<%}%>
      <td width="7%" rowspan="2" align="center" class="thinborderBOTTOM">OTHER INC. </td>
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOM">TOTAL GROSS PAY</td>
      <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">TAX</td>
      <td width="4%" rowspan="2" align="center" class="thinborderBOTTOM">SSS</td>
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOM">MED.</td>
      <td width="6%" rowspan="2" align="center" class="thinborderBOTTOM">HDMF</td>
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
      <td width="4%" height="33" align="center" class="thinborderBOTTOM"><br>
      HRS</td>
      <td width="6%" height="33" align="center" class="thinborderBOTTOM">AMT</td>
      <td width="2%" align="center" class="thinborderBOTTOM">Hours worked </td>
      <td width="2%" align="center" class="thinborderBOTTOM">AMT</td>
			<%if(WI.fillTextValue("employee_category").equals("1")){%>
      <td width="2%" align="center" class="thinborderBOTTOM">Rate</td>
      <td width="2%" align="center" class="thinborderBOTTOM">Amount</td>
			<%}%>
    </tr>
    <% 
	if (vRows != null && vRows.size() > 0 ){
		//System.out.println("vRows " + vRows.size());
      for(int i = 0; i < vRows.size(); i += iFieldCount){
			strUserIndex = (String)vRows.elementAt(i+1);
	  dLineTotal = 0d;
	  dBasic = 0d;
		dOtherDed = 0d;
		dOtherEarn = 0d;
		dTempHours = 0d;
		
		vEarnings = (Vector)vRows.elementAt(i+53);
		vDeductions = (Vector)vRows.elementAt(i+54);
		vSalDetail = (Vector)vRows.elementAt(i+55); 
		vOTDetail = (Vector)vRows.elementAt(i+56);	
		vEarnDed = (Vector)vRows.elementAt(i+59);
		vLateUtDetail= (Vector)vRows.elementAt(i+64);
	%>
    <tr> 
      <td height="30" valign="bottom" class="NoBorder"><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong></td>
			<!--
      <%
	  	//basic monthly
			//strTemp2 = "";
			//	if(vSalDetail != null && vSalDetail.size() > 0)
			//		strTemp2 = (String)vSalDetail.elementAt(7); 			
  	  %>
      <td align="right" valign="bottom" class="NoBorder"><%//=CommonUtil.formatFloat(strTemp2,true)%>&nbsp;</td>
			-->
      <%
				// period rate
				dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));

				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
				dTotalBasic += dLineTotal;
			%>			
      <td align="right" valign="bottom" class="NoBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
      <%
	  	//rate per hour
				strHourlyRate = "";
				//System.out.println("vSalDetail " + vSalDetail);
				if(vSalDetail != null && vSalDetail.size() > 0)
					strHourlyRate = (String)vSalDetail.elementAt(5); 			
  	  %>
      <td align="right" valign="bottom" class="NoBorder">&nbsp;<%=strHourlyRate%>&nbsp;</td>
		<%
			
			// number of days absent (AWOL)
			// dont add anymore... nor convert this to hours... 
			// ang hours absent already includes the the converted number of days into hours...
 			//strTemp = (String)vRows.elementAt(i + 61);
			//dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		
		// leave days
		//strTemp = (String)vRows.elementAt(i + 11); // day with pay
		//dTemp = Double.parseDouble(strTemp);
		dTemp = 0d;
		
		strTemp = (String)vRows.elementAt(i + 12); // days leave without pay
		dTemp = Double.parseDouble(strTemp);
		dTemp = dTemp * 8;
		//System.out.println("strTemp------------------- leave " + strTemp);
		
		/*
 		if(vAWOL != null && vAWOL.size() > 0){
			iIndex = vAWOL.indexOf(strUserIndex);
			if(iIndex != -1){
				dTemp = ((Double)vAWOL.remove(iIndex+1)).doubleValue();
				vAWOL.remove(iIndex);
			}
		}
		*/
		
		strTemp = (String)vRows.elementAt(i + 66); // hours_awol
 		dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		
 		//System.out.println("strTemp awol " + strTemp);

 		if(vLateUtDetail != null && vLateUtDetail.size() > 0){
			strTemp = (String)vLateUtDetail.elementAt(4);
			dTemp += Double.parseDouble(strTemp)/60;		
			//System.out.println("strTemp late " + strTemp);
		}
		//System.out.println("dTemp " + dTemp);
		strTemp2 = CommonUtil.formatFloat(dTemp,false);
		//System.out.println("strTemp2 " + strTemp2);
		if(dTemp == 0d)
			strTemp2 = "";
 	  %>  		
			<td align="right" valign="bottom" class="NoBorder"><%=WI.getStrValue(strTemp2,"&nbsp;")%></td>
      <%			
			dTemp = 0d;
	
			// late_under_amt
			strTemp = (String)vRows.elementAt(i + 48); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
			
			// faculty absences
			strTemp = (String)vRows.elementAt(i + 49); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");		
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
			
			// leave_deduction_amt
			strTemp = (String)vRows.elementAt(i + 33); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");
 			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
	
			// AWOL  
			strTemp = (String)vRows.elementAt(i + 47); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");
 			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
			
			strTemp = CommonUtil.formatFloat(dTemp,true);
			
			dLineTotal -= dTemp;
			dTotalAbsences += dTemp;
			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
      <%
				// hours worked
				strTemp = (String)vRows.elementAt(i + 8);  	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
				strTemp = CommonUtil.formatFloat(dTemp,false);
							
				if(dTemp == 0d)
					strTemp = "";
			%>					
      <td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
			dTotalNetBasic += dLineTotal;
			%>
      <td align="right" valign="bottom" class="NoBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
      <%
	  	// ot rate based on the regular working days		
//	  	if (vRows.elementAt(i+34) != null)	
//				strTemp = (String) vRows.elementAt(i+34); 			
//			else
				
				dTemp = Double.parseDouble(WI.getStrValue(strHourlyRate,"0"));
				dTemp = 1.25 * dTemp;				
				strTemp = CommonUtil.formatFloat(dTemp,2);
				if(dTemp == 0d)
					strTemp = "";
			%>
      <td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
		<%
			// OVERTIME amount
			strTemp = (String)vRows.elementAt(i + 23);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			dTotalOT += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>   
      <td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
      <%
	  	//rate per hour
				strTemp = "";
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp = (String)vSalDetail.elementAt(3);
  	  %>
			<td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
	 		<%
			// overload
			strTemp = (String)vRows.elementAt(i + 22);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			dTotalOverload += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%> 		
			<td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%}%>
			
			
		<%for(iCols = 2;iCols <= iEarnColCount +1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dLineTotal += dTemp;
			adEarningTotal[iCols - 2] = adEarningTotal[iCols - 2] + dTemp;
			
			if(dTemp == 0d)
				strTemp = "";			
		%>          
      <td align="right" valign="bottom" class="NoBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				adEarnDedTotal[iCols - 1] = adEarnDedTotal[iCols - 1] + dTemp;				
				if(strTemp.equals("0"))
					strTemp = "";			
			%>			
      <td width="7%" align="right" valign="bottom" class="NoBorder"><%=WI.getStrValue(strTemp,"")%></td>
			<%}%>			
			
      <%		
			
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
			
			// adjustment amount
	  if (vRows.elementAt(i+51) != null){	
			strTemp = (String)vRows.elementAt(i+51); 
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
			//System.out.println("Adjust " + strTemp);
		}
		
		// holiday_pay_amt
		if (vRows.elementAt(i+26) != null){	
			strTemp = (String)vRows.elementAt(i+26); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
			//System.out.println("HPA " + strTemp);
		}
		
				// addl_payment_amt 
		if (vRows.elementAt(i+27) != null){	
			strTemp = (String)vRows.elementAt(i+27); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
		//	System.out.println("apa " + strTemp);
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
		dTotalOtherEarn += dOtherEarn;
		dLineTotal += dOtherEarn;
		strTemp = CommonUtil.formatFloat(dOtherEarn,2);
		if(dOtherEarn == 0d)
			strTemp = "";
	  %>			
			<td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
      <%
	  	dTotalGross += dLineTotal;
	  %>
      <td align="right" valign="bottom" class="NoBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
      <%
				// tax withheld
				strTemp = (String)vRows.elementAt(i + 46);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				dTotalTax += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>			
      <td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
      <%
				// sss contribution
				strTemp = (String)vRows.elementAt(i + 39);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);														
				dLineTotal -= dTemp;
				dTotalSSS += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>   		
      <td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
      <%
				// philhealth
				strTemp = (String)vRows.elementAt(i + 40);			
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				dTotalPhealth += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>			
      <td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>     
      <%
				// pag ibig
				strTemp = (String)vRows.elementAt(i +41);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				dTotalHdmf +=dTemp;		
				if(dTemp == 0d)
					strTemp = "--";
			%>			
      <td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols ++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				adDeductTotal[iCols-1] = adDeductTotal[iCols-1] + dTemp;					
				dLineTotal -= dTemp;
				if(dTemp == 0d)
					strTemp = "";			
			%>  			
      <td align="right" valign="bottom" class="NoBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
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

			dTotalOtherDed += dOtherDed;
			dLineTotal -= dOtherDed;
			strTemp = CommonUtil.formatFloat(dOtherDed,true);
			if(dOtherDed == 0d)
				strTemp = "";
	  %>				
      <td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
      <%
	  dTotalNetPay += dLineTotal;
	  %>
      <td align="right" valign="bottom" class="NoBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    <%}//end for loop
	} // end if %>
    <tr> 
      <td height="33"><div align="right"><font size="1"><strong>TOTAL :   </strong></font></div></td>
      <!--
			<td align="right" class="thinborderTOP">&nbsp;</td>
			-->
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalBasic,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalAbsences,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalNetBasic,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalOT,true)%>&nbsp;</td>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
			<td align="right" class="thinborderTOP">&nbsp;</td>
			<td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalOverload,true)%>&nbsp;</td>
			<%}%>
  		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%> 
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(adEarningTotal[iCols-2],true)%></td>
      <%}%>
  		<%for(iCols = 1;iCols <= iEarnDedCount; iCols++){%> 
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(adEarnDedTotal[iCols-1],true)%></td>
      <%}%>			
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalOtherEarn,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalGross,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalTax,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalSSS,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalPhealth,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalHdmf,true)%>&nbsp;</td>
      <%for(iCols = 1;iCols <= (iDedColCount/2); iCols++){
				//adGDeductTotal[iCols] += adDeductTotal[iCols];	
			%> 
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(adDeductTotal[iCols-1],true)%>&nbsp;</td>
			<%}%>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalOtherDed,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalNetPay,true)%>&nbsp;</td>
    </tr>
  </table>  
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
	<input type="hidden" name="date_from" value="<%=WI.getStrValue(strDateFrom)%>">  
	<input type="hidden" name="date_to" value="<%=WI.getStrValue(strDateTo)%>">  
  <input type="hidden" name="print_pg" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>