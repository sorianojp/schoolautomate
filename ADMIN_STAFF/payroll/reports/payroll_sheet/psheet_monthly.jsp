<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary by Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
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
	TD.thinborder {
	border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;	
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.NoBorder {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }	

    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
	
	TD.thinborderTOPLEFT {
    border-left: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.thinborderTOPLEFTRIGHT {
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	border-top: solid 1px #000000;
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
	CopyName();
	document.form_.searchEmployee.value="";
	document.form_.print_pg.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}

function SearchEmployee(){
	document.form_.searchEmployee.value="1";
	document.form_.print_pg.value="";
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
</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolShowItems = false;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.

if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./psheet_auf_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheet","psheet_monthly.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"psheet_monthly.jsp");
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRetResult = null;
	Vector vPeriods = null;
	ReportPayrollExtn RptPay = new ReportPayrollExtn(request);
	String strPayrollPeriod  = null;
	String[] astrConvertAlphabet = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"};
	double dBasic = 0d;
	double dLessTemp = 0d;
	double dTotalAbsences = 0d;
	double dLineTotal = 0d;
	double dTotalDeduction = 0d;
	double dTemp = 0d;
	double dTemp2 = 0d;
	double dTemp3 = 0d;
	double dTemp4= 0d;
	double dTemp5 = 0d;
	double dEarnings = 0d;
	double dNetPay = 0d;
	double dNetPay2 = 0d;
	String strTemp2 = null;
	int iDivider = 0;
	int iPay = 0;
	int iDedColCount = 0;
	Vector vDedCols = null;
	Vector vDeductions = null;
	String strRowItems = null;
	int iCols  = 0;
		
	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = RptPay.generateMasterListNew(dbOP);
		if(vRetResult == null)
			strErrMsg = RptPay.getErrMsg();
		else{
			iSearchResult = RptPay.getSearchCount();
			vDedCols = (Vector)vRetResult.elementAt(0);	
			if(vDedCols != null && vDedCols.size() > 0)
				iDedColCount = vDedCols.size() - 1;		
		}
	}

vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
if(WI.fillTextValue("year_of").length() > 0) {	
	vPeriods = RptPay.getMonthlyPeriods(dbOP);
	if(vPeriods != null && vPeriods.size() > 0)
		iDivider = vPeriods.size()/9;
	else{
		vRetResult = null;
		strErrMsg = "Error in getting periods for the month";
	}
		
	//System.out.println("iDivider  " + iDivider);
	//iDivider = RptPay.getPeriodCount(dbOP, request);
	//System.out.println("iDivider1  " + iDivider);
}
%>
<body>
<form name="form_" 	method="post" action="psheet_monthly.jsp">
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
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
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
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3"><input type="image" onClick="SearchEmployee()" src="../../../../images/form_proceed.gif"> 
        <font size="1">click to display employee list to print</font></td>
    </tr>
    <tr>
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
 	  <% if (vRetResult != null && vRetResult.size() > 0 ){%>
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
          Number of Employees / rows Per 
        Page :</font><font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i = 5; i <=9 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
	   <%}%>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 0 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="23"> <%
		int iPageCount = iSearchResult/RptPay.defSearchSize;
		if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="SearchEmployee();">
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
	  <td height="24" colspan="15"><div align="center"><strong><font color="#0000FF">PAYROLL 
          SHEET FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></div></td>
    </tr>
    <tr>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td height="19" valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td colspan="3" valign="bottom" class="thinborderTOPLEFT"><div align="center">OTHER EARNINGS </div></td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT"><div align="center">PREMIUM</div></td>
			<%
			iCols = iDedColCount/5;
			if(iDedColCount%5 > 0)
				iCols++;			
			%>
      <td valign="bottom" class="thinborderTOPLEFT" colspan="<%=iCols%>"><div align="center">DEDUCTIONS</div></td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFTRIGHT">&nbsp;</td>
    </tr>
    <tr>
      <td width="7%" valign="bottom" class="thinborderBOTTOMLEFT">Emp. No. </td> 
      <td width="7%" height="33" valign="bottom" class="thinborderBOTTOMLEFT"><div align="center">NAME OF EMPLOYEE </div></td>
      <td width="4%" valign="bottom" class="thinborderBOTTOMLEFT"><div align="center">BASIC</div></td>
      <td width="5%" valign="bottom" class="thinborderBOTTOMLEFT"><div align="center">Basic<br>
        Less<br>
        (Abs/UT/L)<br>
        ------------<br>
      Basic</div></td>
      <td width="5%" valign="bottom" class="thinborderBOTTOMLEFT"><div align="center">Adm/Pos<br>
      Less<br>
      (Abs/UT/L)<br>
      ------------<br>
      Net Admin </div></td>
      <td width="6%" valign="bottom" class="thinborderBOTTOMLEFT"><div align="center">Othr Erngs<br>
        Less<br>
        (Abs/UT/L)<br> 
      ------------<br>
Net earnings </div></td>
      <td width="6%" valign="bottom" class="thinborderBOTTOMLEFT">a. Honor<br>
        b. Incentive<br>
        c. Cash I<br>
        d. OP PB<br>
        e. UP PB</td>
      <td width="7%" valign="bottom" class="thinborderBOTTOMLEFT">
        f. AGD<br>
        g. Perf Bonus<br>
        h. Retro<br>
        i.Tchng Inc<br>
      j. Others        </td>
      <td width="7%" valign="bottom" class="thinborderBOTTOMLEFT">k. Over Pay<br>
        l. Und Pay<br>
        m. Refund NT<br>
        n. Refund T<br>
        o. UP Earn</td>
      <td width="6%" valign="bottom" class="thinborderBOTTOMLEFT">p. Ext Ser<br>
        q. Sn.Hol<br>
        r. Reg OT<br>
        s. OP Earn GROSS</td>
      <td width="6%" valign="bottom" class="thinborderBOTTOMLEFT">a. Pagibig<br>
        b. Ret Prem<br>
        c. SSS<br>
        d. Philhealth<br>
      e. WTP </td>
      <%
			int iRowCount = 0;
  		for(iCols = 1;iCols <= iDedColCount ; iCols ++){
 			iRowCount = 1;
			strRowItems = null;
			
			  for(;iCols <= iDedColCount ;iCols++,iRowCount++){				
 					if(strRowItems == null)
						strRowItems = astrConvertAlphabet[iCols-1] + ". " + (String)vDedCols.elementAt(iCols);
					else
						strRowItems += "<br>" + astrConvertAlphabet[iCols-1] + ". " + (String)vDedCols.elementAt(iCols);
					
					if(iRowCount == 5)
						break;
				}
			%>		
      <td valign="bottom" class="thinborderBOTTOMLEFT"><%=strRowItems%></td>
			<%}%>				
      <td width="5%" align="center" valign="bottom" class="thinborderBOTTOMLEFT">Total Deduction </td>
			<%
			strTemp = null;
			for(iPay = 0;iPay < iDivider;iPay++){
				if(strTemp == null)
					strTemp = "Netpay" + (iPay+1);
				else
					strTemp += "<br>Netpay" + (iPay+1);
			}%>
      <td width="5%" align="center" valign="bottom" class="thinborderBOTTOMLEFT"><%=strTemp%></td>
      <td width="5%" align="center" valign="bottom" class="thinborderBOTTOMLEFTRIGHT">NET 
          PAY</td>
    </tr>
    
    <% 
	if (vRetResult != null && vRetResult.size() > 1 ){
		//System.out.println("vRetResult " + vRetResult.size());
	  int iStart = 30; // this should be the same as the starting point in the java file	
      for(int i = 1; i < vRetResult.size(); i += 74){
	  dLineTotal = 0d;
	  dBasic = 0d;
	  dTotalDeduction = 0d;
	  dLessTemp = 0d;
		vDeductions = (Vector)vRetResult.elementAt(i+iStart+32); 		
	%>
    <tr>
			<%
				strTemp = (String)vRetResult.elementAt(i+29);
			%>
      <td valign="bottom" class="thinborderBOTTOM">&nbsp;<%=strTemp%></td> 
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+40));
				strTemp += "<br>" + WI.getStrValue((String)vRetResult.elementAt(i+iStart+41));
				strTemp += "<br>" + WI.getStrValue((String)vRetResult.elementAt(i+iStart+42));
				strTemp += "<br>" + WI.getStrValue((String)vRetResult.elementAt(i+iStart+43)) + "<br>";
			%>
      <td height="32" valign="bottom" class="thinborderBOTTOM"><%=strTemp%><strong><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4)%></strong></td>
      <%		
	  	// basic monthly
		strTemp = (String) vRetResult.elementAt(i+5); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		if (strTemp.length() > 0){
			dBasic = Double.parseDouble(strTemp);
			dLineTotal += dBasic;
		}		
	  %>
      <td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=CommonUtil.formatFloat(dBasic,true)%></div></td> 
      <%
	  	dTemp = 0d;
		// late_under_amt
		if (vRetResult.elementAt(i+18) != null){	
			strTemp = (String)vRetResult.elementAt(i+18); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dLessTemp += Double.parseDouble(strTemp);
			}
		}
		
		//faculty_absence
	  	if (vRetResult.elementAt(i+19) != null){	
			strTemp = (String)vRetResult.elementAt(i+19); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dLessTemp += Double.parseDouble(strTemp);
			}
		}
		
		//leave_deduction_amt
	  	if (vRetResult.elementAt(i+20) != null){	
			strTemp = (String)vRetResult.elementAt(i+20); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dLessTemp += Double.parseDouble(strTemp);
			}
		}
		
		//awol_amt
	  	if (vRetResult.elementAt(i+21) != null){	
			strTemp = (String)vRetResult.elementAt(i+21); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dLessTemp += Double.parseDouble(strTemp);
			}
		}

		dTotalAbsences += dLessTemp;
		dLineTotal -= dLessTemp;		
	  %>	       
      <td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=CommonUtil.formatFloat(dBasic,true)%>&nbsp;<br>
          <%=CommonUtil.formatFloat(dLessTemp,true)%>&nbsp;<br>
      <%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</div></td>    
	  <%
	    strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dLineTotal += dTemp;
	  %>  
      <td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=CommonUtil.formatFloat(dTemp,true)%></div></td>      
	  <%
	    strTemp = WI.getStrValue((String)vRetResult.elementAt(i+ iStart + 1),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dLineTotal += dTemp;
	  %>  
      <%
	    strTemp = WI.getStrValue((String)vRetResult.elementAt(i+ iStart + 38),"0"); 
	  %>  
      <td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=CommonUtil.formatFloat(strTemp,true)%></div></td>
	  <%
	  	// honorarium
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+2),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dLineTotal += dTemp;
		// other incentives
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+6),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);
		dLineTotal += dTemp2;
		// cash incentive
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+3),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);
		dLineTotal += dTemp3;
		// overpayment pb
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+7),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);				
		dLineTotal -= dTemp4;
		// under payment pb
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+10),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp5 = Double.parseDouble(strTemp);
		dLineTotal += dTemp5;
		
		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d && dTemp5 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp5,true);
		}		
	  %>
      <td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=strTemp2%></div></td>
	  <%
	  	// agd
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+5),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dLineTotal += dTemp;
		// performance bonus
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+9),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);
		dLineTotal += dTemp2;
		// retroactive  pay
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+11),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);
		dLineTotal += dTemp3;
		// teachin incentive
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+4),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);				
		dLineTotal += dTemp4;
		// others
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+18),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp5 = Double.parseDouble(strTemp);
		dLineTotal += dTemp5;

		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d && dTemp5 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp5,true);
		}		
	  %>		  
      <td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=strTemp2%></div></td>
	  <%
	  	// over payment
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+8),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dLineTotal -= dTemp;
		//under payment
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+12),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);
		dLineTotal += dTemp2;
		// refund non taxable
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+13),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);
		dLineTotal += dTemp3;
		// refund taxable
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+14),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);				
		dLineTotal += dTemp4;
		// underpayment earnings
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+16),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp5 = Double.parseDouble(strTemp);
		dLineTotal += dTemp5;

		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d && dTemp5 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp5,true);
		}		
	  %>			  
      <td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=strTemp2%></div></td>
	  <%
	  // extended service
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+17),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dLineTotal += dTemp;
		
		// holiday
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+17),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);
		dLineTotal += dTemp2;
		//Regular OT		
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+16),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);
		dLineTotal += dTemp3;
		// OP earning
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+15),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);				
		dLineTotal -= dTemp4;
		
		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true);
		}		
	  %>		  
      <td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=strTemp2%><br>
      <%=CommonUtil.formatFloat(dLineTotal,true)%></div></td>
	  <%
	  	// pagibig
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp;
		// retirement premium
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+28),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);		
		dTotalDeduction += dTemp2;
		// sss
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+10),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp3;
		// PHIC
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);				
		dTotalDeduction += dTemp4;
		// WTP
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp5 = Double.parseDouble(strTemp);				
		dTotalDeduction += dTemp5;
		
		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d && dTemp5 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp5,true);
		}		
	  %>			
      <td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=strTemp2%></div></td>		

		<%
		for(iCols = 1;iCols <= iDedColCount; iCols++){			
		 	iRowCount = 1;
			strRowItems = null;
			bolShowItems = false;
			
			  for(;iCols <= iDedColCount && vDeductions.size() > 1;iCols++,iRowCount++){
					strTemp = (String)vDeductions.elementAt(iCols);
					dTemp = Double.parseDouble(strTemp);
					dTotalDeduction += dTemp;
					if(dTemp > 0)
						bolShowItems = true;
					
 					if(strRowItems == null)
						strRowItems = strTemp;
					else
						strRowItems += "<br>" + strTemp;
					
					if(iRowCount == 5)
						break;
				}
				if(!bolShowItems)
					strRowItems = "&nbsp;";
		%>    		
      <td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=strRowItems%></div></td>
			<%}
			strTemp = (String)vDeductions.elementAt(0);
			dTemp = Double.parseDouble(strTemp);
			dTotalDeduction += dTemp;
			%>	     
      <td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=CommonUtil.formatFloat(dTotalDeduction,true)%></div></td>
	  <%
		strTemp = null;
	  dNetPay = dLineTotal - dTotalDeduction;			
		dNetPay = CommonUtil.formatFloatToCurrency(dNetPay,2);
		dNetPay2 = dNetPay/iDivider;
		dNetPay2 = CommonUtil.formatFloatToCurrency(dNetPay2,2);
		dTemp = 0d;		
		for(iPay = 0;iPay < iDivider;iPay++){						
			if(strTemp == null)
				strTemp = "" + CommonUtil.formatFloat(dNetPay2,2);
			else{				
				if(iPay < iDivider-1)
					strTemp += "<br>" + CommonUtil.formatFloat(dNetPay2,2);			
				else
					strTemp += "<br>" + CommonUtil.formatFloat(dNetPay-dTemp,2);			
			}
			dTemp = dTemp + dNetPay2;
		}
	  //dNetPay2 = dNetPay/2;
	  //strTemp = CommonUtil.formatFloat(dNetPay2,true);
	  //strTemp = ConversionTable.replaceString(strTemp,",","");
	  //dTemp = Double.parseDouble(strTemp);
	  //dNetPay2 = dNetPay - dTemp;
	  %>
	 		<td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=strTemp%></div></td>
      <td valign="bottom" class="thinborderBOTTOM"><div align="right"><%=CommonUtil.formatFloat(dNetPay,true)%></div></td>
    </tr>
    <%}//end for loop
	} // end if %>
    <tr>
      <td>&nbsp;</td> 
      <td height="33">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
    </tr>
  </table>  
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
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