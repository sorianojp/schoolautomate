<%@ page language="java" import="utility.*,java.util.Vector,payroll.PReDTRME, payroll.OvertimeMgmt" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Manual Encoding Summary</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.searchEmployee.value="";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
 
function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
} 

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	boolean bolHasConfidential = false;	
	boolean bolHasTeam = false;	
	boolean bolIsGovernment = false;
	
//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./manual_summary_print.jsp" />
	<% 
return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Manual Adjustment","manual_summary.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");	
		
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");		
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");		
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
														"Payroll","DTR",request.getRemoteAddr(),
														"manual_summary.jsp");
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

	Vector vRetResult = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	OvertimeMgmt otMgmt = new OvertimeMgmt();
	int iSearchResult = 0;
	int i = 0;
	int iCtr = 0;
	int iOT = 0;
	int iIndex = 0;
	
	int iHour = 0;
	int iMinute = 0;
	
	String strValue = null;
	double dTemp = 0d;
	String strPayrollPeriod  = null;	
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	String[] astrSortByName  = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal   = {"id_number","user_table.fname","lname","c_name","d_name"};
	
	Vector vEmpWorked = null;
	Vector vEmpAllowance = null;
	Vector vEmpAdjustment = null;
	Vector vEmpAbsence = null;
	Vector vEmpLateUt = null;
	Vector vEmpTaxOverride = null;
	Vector vFixedCon = null;
	Vector vEmpRate = null;
	Vector vEmpOT  = null;

	Vector vOTTypes = null;
	if(WI.fillTextValue("hide_overtime").equals("1"))
		vOTTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, true);			
	else
		vOTTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "1");
	
	Vector vAdjTypes = null;
	if(WI.fillTextValue("hide_adjustment").equals("1"))
		vAdjTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, false);			
	else
		vAdjTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "0");
	 
	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = prEdtrME.getManualEncodingSummary(dbOP,request);
		if(vRetResult == null)
			strErrMsg = prEdtrME.getErrMsg();
		else
			iSearchResult = prEdtrME.getSearchCount();
	}	
 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);	
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="manual_summary.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL: MANUALLY ENCODED PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="770" height="10">&nbsp;</td>
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
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">Salary Period</td>
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
        <%}// check if the company has weekly salary type%>			</td>
    </tr>
    
    <tr>
      <td height="24">&nbsp;</td>
      <td>Status</td>
      <td><select name="pt_ft" onChange="ReloadPage();">
        <option value="">All</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part-time</option>
        <%}else{%>
        <option value="0">Part-time</option>
        <%}if (WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="1" selected>Full-time</option>
        <%}else{%>
        <option value="1">Full-time</option>
        <%}%>
      </select></td>
    </tr>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td>Position</td>
		  <td><select name="emp_position">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE " +
				" where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_position"), false)%>
      </select></td>
	  </tr>
		<%if(bolIsSchool){%>
		<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td>
	   <select name="employee_category" onChange="ReloadPage();">          
        <option value="">All</option>
				<%if (WI.fillTextValue("employee_category").equals("0")){%>
				  <option value="0" selected>Non-Teaching</option>
        <%}else{%>
          <option value="0">Non-Teaching</option>				
        <%}if (WI.fillTextValue("employee_category").equals("1")){%>
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
      <td> <select name="c_index" onChange="loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td>
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
<tr>
      <td height="10">&nbsp;</td>
      <td height="10">Salary Basis </td>
      <td height="10"><select name="salary_base" onChange="ReloadPage();">
				<option value="">ALL</option>
        <%if (WI.fillTextValue("salary_base").equals("0")){%>
				<option value="0" selected>Monthly rate</option>
        <option value="1">Daily Rate</option>
        <option value="2">Hourly Rate</option>        
        <%} else if (WI.fillTextValue("salary_base").equals("1")){%>
				<option value="0">Monthly rate</option>
        <option value="1" selected>Daily Rate</option>
        <option value="2">Hourly Rate</option>
        <%} else if (WI.fillTextValue("salary_base").equals("2")){%>
				<option value="0">Monthly rate</option>
        <option value="1">Daily Rate</option>
        <option value="2" selected>Hourly Rate</option>
        <%}else{%>
				<option value="0">Monthly rate</option>
        <option value="1">Daily Rate</option>
        <option value="2">Hourly Rate</option>
        <%}%>
      </select></td>
    </tr>
		<%if(bolHasConfidential){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Process Option</td>
			<%
			String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";		
			%>			
      <td><select name="group_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group " +
													" where exists(select user_index from pr_group_proc " +
													" 	where pr_preload_group.group_index = pr_group_proc.group_index " +
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%>
      </select></td>
    </tr>
		<%}%>		
		<%if(bolHasTeam){%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Team</td>
      <td height="10"><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select> </td>
    </tr>
		<%}%>				
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Office/Dept filter</td>
      <td height="10"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      <strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></strong>
			<label id="coa_info"></label></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1" color="#000000"></td>
    </tr>
    
    <tr>
      <td height="10" colspan="3">OPTION:</td>
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
hide adjustment column without value</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_ot_time");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>
      <td height="10" colspan="2"><input type="checkbox" name="show_ot_time" value="1" <%=strTemp%>>
				show OT in hours encoded</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_adj_duration");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";					
			%>
      <td height="10" colspan="2"><input type="checkbox" name="show_adj_duration" value="1" <%=strTemp%>>
show adjustment in duration</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">
			<%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">        View ALL </td>
    </tr>		
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td width="27%" height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=prEdtrME.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td width="27%" height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=prEdtrME.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td width="32%" height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=prEdtrME.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
      <td>
			<select name="sort_by3_con">
        <option value="asc">Ascending</option>
        <%if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
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
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
        click to display employee list to print.</font></td>
    </tr>
  </table>    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>   
      <% if (vRetResult != null && vRetResult.size() > 0){%>
      <td height="10"><div align="right"><font size="2">Number of Employees / rows Per 
        Page :</font><font>
                  <select name="num_rec_page">
                    <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
                    <option selected value="<%=i%>"><%=i%></option>
                    <%}else{%>
                    <option value="<%=i%>"><%=i%></option>
                    <%}}%>
                  </select>
                  
									<a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
      <%}%>
    </tr>
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/prEdtrME.defSearchSize;		
	if(iSearchResult % prEdtrME.defSearchSize > 0) ++iPageCount;
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
    <%} // end if pages > 1
		}// end if not view all%>
  </table>
  <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="20" colspan="10" align="center" bgcolor="#B9B292"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
	   <tr>
      <td width="2%" class="thinborder">&nbsp;</td>
      <td width="4%" class="thinborder">&nbsp;</td> 
      <td width="24%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">BASIC RATE </font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">WORK DURATION</font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">LATE / UNDERTIME </font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">ABSENCES</font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">TAX</font></strong></td>
       <%
 			if(vOTTypes != null && vOTTypes.size() > 0){
			for(iOT = 0; iOT < vOTTypes.size(); iOT+=19){
				strTemp = (String)vOTTypes.elementAt(iOT+1);
				//if(!strSchCode.startsWith("TAMIYA"))
				//	strTemp += "<br>"+ CommonUtil.formatFloat((String)vAdjTypes.elementAt(iOT+3),false);
			%>
			<td width="5%" align="center" class="thinborder"><%=strTemp%></td>      
      <%}
			}%>
			<%
 			if(vAdjTypes != null && vAdjTypes.size() > 0){
			for(iOT = 0; iOT < vAdjTypes.size(); iOT+=19){

				strTemp = (String)vAdjTypes.elementAt(iOT+1);
				//if(!strSchCode.startsWith("TAMIYA"))
				//	strTemp += "<br>"+ CommonUtil.formatFloat((String)vAdjTypes.elementAt(iOT+3),false);
			%>
			<td width="5%" align="center" class="thinborder"><%=strTemp%>*</td>            
      <%}
			}%>
			<td width="5%" align="center" class="thinborder"><font size="1">SSS</font></td>
      <td width="5%" align="center" class="thinborder"><font size="1">PHIC</font></td>
      <td width="5%" align="center" class="thinborder"><font size="1">PAG-IBIG</font></td>
      <%if(bolIsGovernment){%>
			<td width="5%" align="center" class="thinborder"><font size="1">GSIS</font></td>
			<%}%>
			<%if(bolIsSchool){%>
      <td width="5%" align="center" class="thinborder"><font size="1">PERAA</font></td>
			<%}%>
    </tr>
    <%int iCount = 1;
	   for (i = 0; i < vRetResult.size(); i+=35,iCount++){
		 	vEmpAdjustment = (Vector)vRetResult.elementAt(i+8);
			vEmpAbsence = (Vector)vRetResult.elementAt(i+9);
			vEmpLateUt = (Vector)vRetResult.elementAt(i+10);
			vEmpTaxOverride = (Vector)vRetResult.elementAt(i+11);
			vFixedCon =  (Vector)vRetResult.elementAt(i+12);
			vEmpWorked = (Vector)vRetResult.elementAt(i+13);
			vEmpRate  = (Vector)vRetResult.elementAt(i+14);
			vEmpOT  = (Vector)vRetResult.elementAt(i+15);
			//vFixedCon = null;
			//vEmpWorked = null;
			vEmpAllowance = null;
			//vEmpAdjustment = null;			
			//vEmpLateUt = null;
		 %>
    <tr>
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<%
				strTemp = "&nbsp;";
 				if(vEmpRate != null && vEmpRate.size() > 0){					
					strTemp	 = (String)vEmpRate.elementAt(0);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
					if(dTemp == 0d){
						strTemp	 = (String)vEmpRate.elementAt(1);
						strTemp = CommonUtil.formatFloat(strTemp, true);
						dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
						if(dTemp == 0d){					
							strTemp = "&nbsp;";
						}
					}
 				}
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <%
				strValue = "";
				strTemp2 = "";
 				if(vEmpWorked != null && vEmpWorked.size() > 0){					
					for(iCtr = 0;iCtr < vEmpWorked.size(); iCtr += 8){						
						strTemp2 = WI.getStrValue((String)vEmpWorked.elementAt(iCtr+2));
						if(strTemp2.equals("1")){
							// days
							strTemp2 = (String)vEmpWorked.elementAt(iCtr+1) + " day(s)";
						} else if(strTemp2.equals("2")){
							// hours
							strTemp2 = (String)vEmpWorked.elementAt(iCtr+1) + " hour(s)";
						} else if(strTemp2.equals("3")){
						  // faculty hours
							strTemp2 = (String)vEmpWorked.elementAt(iCtr+1) + " hour(s)(fac)";
						} else if(strTemp2.equals("4")){
						  // overload							
							strTemp2 = (String)vEmpWorked.elementAt(iCtr+1) + " hour(s)(OL)";
						}

						if(strValue.length() == 0)
							strValue = strTemp2;
						else
							strValue += "<br>" + strTemp2;
					}
				}
			%>
		  <td align="right" class="thinborder">&nbsp;<font size="1"><%=WI.getStrValue(strValue)%></font></td>
			<%
				strValue = "";
				strTemp2 = "";
				strTemp = null;
  				if(vEmpLateUt != null && vEmpLateUt.size() > 0){					
					for(iCtr = 0;iCtr < vEmpLateUt.size(); iCtr += 10){						
						strTemp	 = (String)vEmpLateUt.elementAt(iCtr+1);
						strTemp = CommonUtil.formatFloat(strTemp, true);
						dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
						if(dTemp == 0d)						
							strTemp = "";
						strTemp2 = WI.getStrValue((String)vEmpLateUt.elementAt(iCtr+4));
						if(strTemp2.equals("1")){
							// UNDERTIME
							strTemp2 = WI.getStrValue(strTemp, "UT : ","","");
						} else {
							// LATE
							strTemp2 = WI.getStrValue(strTemp, "Late : ","","");
						} 
						
						if(strValue.length() == 0)
							strValue = strTemp2;
						else
							strValue += "<br>" + strTemp2;
					}
				}
			%>
      <td align="right" class="thinborder"><font size="1"><%=WI.getStrValue(strValue,"&nbsp;")%></font></td>
			<%
				strTemp = "&nbsp;";
 				if(vEmpAbsence != null && vEmpAbsence.size() > 0){					
					strTemp	 = (String)vEmpAbsence.elementAt(1);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
					if(dTemp == 0d)						
						strTemp = "";
 				}
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		  <%
			strValue = "--";
			strTemp = "";
 			if(vEmpTaxOverride != null && vEmpTaxOverride.size() > 0){					
				strTemp = (String)vEmpTaxOverride.elementAt(1);
				strValue = (String)vEmpTaxOverride.elementAt(0);
				if(strTemp.equals("1"))
					strValue = CommonUtil.formatFloat(strValue, true);
				else
					strValue = CommonUtil.formatFloat(strValue, false) + "%";
			}
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strValue, "&nbsp;")%></td>
			<%
			if(vOTTypes != null && vOTTypes.size() > 0){
			 for(iOT = 0;iOT < vOTTypes.size(); iOT+=19){
			 		
				 strTemp = null;
				 iIndex = vEmpOT.indexOf((Integer)vOTTypes.elementAt(iOT));
				 if(iIndex != -1){
				 		if(WI.fillTextValue("show_ot_time").length() > 0){
							strTemp = WI.getStrValue((String)vEmpOT.elementAt(iIndex+2), "0");
							dTemp = Double.parseDouble(strTemp);
							iHour = (int)dTemp/60;
							iMinute = (int)(dTemp - (iHour*60));
							if(iHour > 0 || iMinute > 0)
								strTemp = iHour + ":" + iMinute;
							else
								strTemp = "&nbsp;";
							
					 	}else{
							strTemp = (String)vEmpOT.elementAt(iIndex+1);					 
							dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
							//dLineTotal += dTemp;
							strTemp = CommonUtil.formatFloat(dTemp,true);
							if(dTemp == 0d)
								strTemp = "&nbsp;";							
						}
				 }
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
      <%}
			}%>	
			<%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			 for(iOT = 0;iOT < vAdjTypes.size(); iOT+=19){
				 strTemp = null;
				 dTemp = 0d;
				 iIndex = vEmpAdjustment.indexOf((Integer)vAdjTypes.elementAt(iOT));
				 if(iIndex != -1){
						if(WI.fillTextValue("show_adj_duration").length() > 0){
							strTemp = WI.getStrValue((String)vEmpAdjustment.elementAt(iIndex+3), "0");
							dTemp = Double.parseDouble(strTemp);
					 	}else{
							strTemp = (String)vEmpAdjustment.elementAt(iIndex+2);					 
							dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
							//dLineTotal += dTemp;
						}
					}
					
					strTemp = CommonUtil.formatFloat(dTemp, true);
					if(dTemp == 0d)
						strTemp = "&nbsp;";												
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>            
      <%}
			}%>	
			<%
				// d_type
				// 0 = sss_amt
				// 1 = pag_ibig
				// 2 = philhealth_amt
				// 3 = peraa
				// 4 = gsis_ps
				strTemp = null;
				if(vFixedCon != null && vFixedCon.size() > 0){
					iIndex = vFixedCon.indexOf(new Integer(0));
					if(iIndex != -1){
						strTemp = (String)vFixedCon.elementAt(iIndex+2);
					}					
				}
			%>
			<td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%>&nbsp;</td>
			<%
				strTemp = null;
				if(vFixedCon != null && vFixedCon.size() > 0){
					iIndex = vFixedCon.indexOf(new Integer(2));
					if(iIndex != -1){
						strTemp = (String)vFixedCon.elementAt(iIndex+2);
					}					
				}
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%
				strTemp = null;
				if(vFixedCon != null && vFixedCon.size() > 0){
					iIndex = vFixedCon.indexOf(new Integer(1));
					if(iIndex != -1){
						strTemp = (String)vFixedCon.elementAt(iIndex+2);
					}					
				}
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			
			<%
				if(bolIsGovernment){
 				strTemp = null;
				if(vFixedCon != null && vFixedCon.size() > 0){
					iIndex = vFixedCon.indexOf(new Integer(4));
					if(iIndex != -1){
						strTemp = (String)vFixedCon.elementAt(iIndex+2);
					}					
				}
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%}%>
			<%if(bolIsSchool){
				strTemp = null;
				if(vFixedCon != null && vFixedCon.size() > 0){
					iIndex = vFixedCon.indexOf(new Integer(3));
					if(iIndex != -1){
						strTemp = (String)vFixedCon.elementAt(iIndex+2);
					}					
				}
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%}%>
    </tr>
    <%} //end for loop%>
    
 
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><strong>Note: <br>
      &nbsp;1. Values in this report are the values that were encoded in the manual encoding pages.<br>
      &nbsp;2. Overtime and adjustment entries that were encoded in amount can only display amount. </strong></td>
    </tr>
  </table>  
<% } // end vRetResult != null && vRetResult.size() > 0 %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="searchEmployee"> 
  <input type="hidden" name="page_action">
	<input type="hidden" name="copy_all">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>