<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRSalary, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

boolean bolHasConfidential = false;
boolean bolHasTeam = false;
String[] strColorScheme = CommonUtil.getColorScheme(6);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Batch Create payslip</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}

  /*this is what we want the div to look like*/
  div.processing{
    display:block;
    /*set the div in the bottom right corner*/
    position:absolute;
    width:400px;
	height:150;/** it expands on its own.. **/
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }


</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
.fontsize11 {		font-size : 11px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee(){
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function saveList(){
	document.form_.save_list.value = "1";
	document.form_.save.disabled = true;
	document.form_.proceed_btn.disabled = true;	
	document.form_.submit();
	//this.SubmitOnce('form_');
}

function viewSave(){
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function OpenSearch() {
	document.form_.searchEmployee.value="1";
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

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

///////////////////////////////////////// End of collapse and expand filter ////////////////////
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

function finalize(strDateFrom, strDateTo){
//	document.all.processing.style.visibility = "visible";
	var objCOAInput = document.getElementById("finalize_dtr");

	this.InitXmlHttpObject2(objCOAInput, 2, 'processing...<br><img src="../../../Ajax/ajax-loader_small_black.gif">');//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=600&date_fr="+strDateFrom+
	"&date_to=" + strDateTo + "&emp_id=" + document.form_.emp_id.value;
	this.processRequest(strURL);
 //	document.all.processing.style.visibility = "hidden";
}

function HideFinalize(){	
	if(!document.getElementById("finalize_fields"))
		return;
 	document.getElementById("finalize_fields").innerHTML = "";
}

function ShowBlockedEmployee(strStatus) {
	if(strStatus == 1)
		document.all.processing.style.visibility='visible';	
	else
		document.all.processing.style.visibility='hidden';	
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strHasWeekly  = null;
	int iSearchResult = 0;
	String strPayrollPeriod  = null;
	boolean bolHasAUFStyle = false;
	
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Create Payroll (Batch)","autocreate_pay.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
		bolHasAUFStyle = (readPropFile.getImageFileExtn("HAS_AUF_STYLE","0")).equals("1");
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
														"PAYROLL","DTR-MANUAL",request.getRemoteAddr(),null);
if(iAccessLevel == 0 && !strSchCode.startsWith("UPH")){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","DTR",request.getRemoteAddr(),
														"autocreate_pay.jsp");
}

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


Vector vSalaryPeriod = null;//detail of salary period.

PReDTRME prEdtrME = new PReDTRME();
Vector vRetResult = null;
PRSalary Salary = new PRSalary();
boolean bolShowSave = false;
String strStatus = null;
Vector vEmpWithPayable = null;
int iCount = 1;
int i = 1;
String strDateFrom = null;
String strDateTo = null;
				
//Salary.addEarningStatus(dbOP);
if(WI.fillTextValue("save_list").length() > 0){
	if(Salary.autoCreatePayroll(dbOP,request,1) == null){
		strErrMsg = Salary.getErrMsg();
	}
}

//if(WI.fillTextValue("year_of").length() > 0){
vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);   
	if(WI.fillTextValue("searchEmployee").equals("1") && vSalaryPeriod != null){	
	  vRetResult = Salary.autoCreatePayroll(dbOP,request,4);
	  if(vRetResult == null){
		 strErrMsg = Salary.getErrMsg();
   	}else{
			vEmpWithPayable = (Vector) vRetResult.elementAt(0);
		}
  }  

Vector vTotalBlocked = new Vector();
String strSQLQuery = null;
java.sql.ResultSet rs = null;
strSQLQuery = "select id_number, fname, mname, lname, reason from pr_block_payroll " +
              " join user_table on (pr_block_payroll.user_index = user_table.user_index) " +
              " where user_table.is_valid = 1 and user_table.is_del = 0 " +
              " and pr_block_payroll.is_valid = 1 " +
              " and (expire_date is null or expire_date >= '"+ WI.getTodaysDate()+"') order by lname";
rs= dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vTotalBlocked.addElement(rs.getString(1));//[0] id_number
	vTotalBlocked.addElement(WI.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4));//[0] id_number
	vTotalBlocked.addElement(rs.getString(5));//[0] id_number
}
rs.close();

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./autocreate_pay.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
      PAYROLL : CREATE PAYROLL BY BATCH PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="27"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="21%"> Salary Month/Year :</td>
      <td width="76%"> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Salary Period :</td>
      <td width="76%"><strong> 
        <label id="sal_periods">
				<select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="HideFinalize();">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");
		
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10){
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
				
				strDateFrom = (String)vSalaryPeriod.elementAt(i+1);
		  	strDateTo = (String)vSalaryPeriod.elementAt(i+2);
			%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
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
        <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="loadSalPeriods();">
        <font size="1">for weekly </font>
        <%}// check if the company has weekly salary type%> 
	  </td>
    </tr>
    <tr> 
      <td height="12" colspan="3"><hr size="1"></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
		<%if(bolIsSchool){%>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="20%">Payroll Category :</td>
      <td width="77%">&nbsp;</td>
    </tr>
		<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Payroll Status :</td>
      <td height="25"> 
	    <select name="pt_ft" onChange="ReloadPage();">		
		  <option value="">ALL</option>          
		  <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if (WI.fillTextValue("pt_ft").equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select>
	    <select name="employee_category" onChange="ReloadPage();">
          <option value="">ALL</option>
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
    <tr>
      <td height="12" colspan="3"><hr size="1"></td>
    </tr>    
    <% String strCollegeIndex = WI.fillTextValue("c_index"); %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="25"><select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Office</td>
      <td height="26">
				<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 " +
														" and (c_index = 0 or c_index is null) order by d_name", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select>
				</label>			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Position</td>
      <td><select name="position" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE " +
					" where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("position"), false)%> </select></td>
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
      <td height="26">&nbsp;</td>
      <td height="26">Team</td>
      <td height="26"><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>
    </tr>
		<%}%>		
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Office/Dept filter</td>
      <td height="26"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters) </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Employee ID </td>
      <td height="26"><strong>
        <input name="emp_id" type="text" class="textbox" size="16" maxlength="20" 
				value="<%=WI.fillTextValue("emp_id")%>" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      </strong>
        <div style="position:absolute; width:350px;">
      <label id="coa_info"></label></div> </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td height="26"><font size="1">
        <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="SearchEmployee();">
        click 
        to display employee list to create.</font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td width="3%">&nbsp;</td>
    <td width="97%"><strong>OPTIONS</strong><font size="1">(for aid in viewing which things an employee lack)</font></td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td><input name="bypass_floor" type="checkbox" value="1"> Ignore Floor Salary Setting for Employee</td>
  </tr>
	<%if(bolHasAUFStyle){%>
  <tr>
    <td>&nbsp;</td>
    <td><% 			
				strTemp = WI.fillTextValue("is_one_computation");
				if(strTemp.compareTo("1") == 0) 
					strTemp = " checked";
				else	
					strTemp = "";
			%>
			<input type="checkbox" name="is_one_computation" value="1" <%=strTemp%> onClick="ReloadPage();">
			process employees payroll computed once but multiple releasing		</td>
  </tr>
	<%}%>
  <tr>
    <td>&nbsp;</td>
	  <%if(WI.fillTextValue("salary_rate").length() > 0){
		  strTemp = " checked";
		  bolShowSave = true;
		}else
		  strTemp = "";
	  %>	
    <td><input name="salary_rate" type="checkbox" value="1"<%=strTemp%>>
include employees without valid salary rate </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
	  <%if(WI.fillTextValue("tax_status").length() > 0){
		  strTemp = " checked";
		  bolShowSave = true;
		}else
		  strTemp = "";
	  %>	
    <td><input name="tax_status" type="checkbox" value="1"<%=strTemp%>>
      include employees without tax status      </td>
    </tr>
  
  <tr>
    <td>&nbsp;</td>
	  <%if(WI.fillTextValue("saved_payroll").length() > 0){
		  strTemp = " checked";
		  bolShowSave = true;
		}else
		  strTemp = "";
	  %>		
    <td><input name="saved_payroll" type="checkbox" value="1"<%=strTemp%>>
      include employees with saved payroll  </td>
    </tr>
<%if(vTotalBlocked != null && vTotalBlocked.size() > 0) {
int iBlocked = vTotalBlocked.size()/3;
if(iBlocked == 1)
	strTemp = "1 Employee is blocked ";
else	
	strTemp = "Total "+iBlocked+" Employees are blocked ";
%>
  <tr>
    <td>&nbsp;</td>
    <td style="font-size:14px; font-weight: bold; color:#FF0000">
	 <a href="javascript:ShowBlockedEmployee(1);">
	 	Note: <%=strTemp%> and will not be part of Batch Process. Click here to view List 
	 </a>
	 	<div id="processing" class="processing"  style="visibility:hidden; overflow:auto; position:absolute">
		  	<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#FFCC99">
				<tr><td valign="top">
					<table width="100%" cellpadding="0" cellspacing="0">
					  <tr>
					  	<td>&nbsp;</td>
						<td valign="top" align="right" class="thinborderNONE" height="20" colspan="2"><a href="javascript:ShowBlockedEmployee(0)">Close Window X</a></td>
					  </tr>
					  </table>
					  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
					  <tr style="font-weight:bold">
					  	<td width="20%" class="thinborder">Emp ID</td>
						<td width="40%" class="thinborder">Emp Name</td>
						<td width="40%" class="thinborder">Reason</td>
					  </tr>
					  <%while(vTotalBlocked.size() > 0) {%>
						  <tr>
							<td class="thinborder"><%=vTotalBlocked.remove(0)%></td>
							<td class="thinborder"><%=WI.getStrValue((String)vTotalBlocked.remove(0), "&nbsp;")%></td>
							<td class="thinborder"><%=vTotalBlocked.remove(0)%></td>
						  </tr>
					  <%}%>
					</table>
				</td></tr>
			</table>
        </div>

	 
	 </td>
  </tr>
<%}%>
</table>

  <% //System.out.println("vRetResult " + vRetResult);
  if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    	
    <tr bgcolor="#B9B292" class="thinborder"> 
      <td height="23" colspan="6" align="center"><b>LIST OF EMPLOYEES</b></td>
    </tr>
    <tr bgcolor="#ffff99" class="thinborder"> 
      <td class="thinborder" height="25" colspan="2" align="center"><strong>EMPLOYEE 
        ID</strong></td>
      <td class="thinborder" width="30%" align="center"><strong>EMPLOYEE NAME</strong></td>
      <td class="thinborder" width="33%" align="center"><strong>DEPARTMENT/OFFICE</strong></td>
      <td width="19%" align="center" class="thinborder"><strong>Condition</strong></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
      </strong>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
      </font></td>
    </tr>
    <% 	//System.out.println("size " +vRetResult.size());		
	for(i = 1; i < vRetResult.size(); i += 11,++iCount){		
		strStatus = "";
		
		//System.out.println((String)vRetResult.elementAt(i+7));
		if((String)vRetResult.elementAt(i+7) == null)
			strStatus = "Lacks Valid Salary rate";
		if((String)vRetResult.elementAt(i+8) == null){
			strStatus = WI.getStrValue(strStatus,"","<br>&nbsp;Tax Status not set","Tax Status not set");
		}		
	//	if(strStatus.length() == 0){
	//		strStatus = "With Payroll";
	//	}
	%>	
    <tr bgcolor="#FFFFFF" class="thinborder"> 
        <input type="hidden" name="user_index_<%=iCount%>" value="<%=(String) vRetResult.elementAt(i)%>">
				<input type="hidden" name="id_number_<%=iCount%>" value="<%=(String) vRetResult.elementAt(i + 1)%>">
				<input type="hidden" name="pt_ft_<%=iCount%>" value="<%=(String) vRetResult.elementAt(i + 9)%>">
				<input type="hidden" name="category_<%=iCount%>" value="<%=(String) vRetResult.elementAt(i + 10)%>">
				
      <td class="thinborder" width="4%">&nbsp;<%=iCount%>.</td>
      <td class="thinborder" width="9%" height="25">&nbsp;<%=(String)vRetResult.elementAt(i +1)%></td>
      <td class="thinborder" >&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i + 2), 
	  								(String)vRetResult.elementAt(i + 3), (String)vRetResult.elementAt(i + 4),4)%>	  </td>
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>
      <td class="thinborder" >&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5)," ")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6)," ")%>      </td>
      <td class="thinborder" >&nbsp;<%=WI.getStrValue(strStatus,"&nbsp;")%></td>
      <td align="center" class="thinborder" ><input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1"></td>
    </tr>
<%} // end for loop%>
	<input type="hidden" name="emp_count" value="<%=iCount%>">
	<%if(!bolShowSave){%>
    <%if(iAccessLevel == 2 && strSchCode.startsWith("TSUNEISHI")) {%>
		<tr bgcolor="#FFFFFF" class="thinborder">
      <td height="25" colspan="6">
			<label id="finalize_fields">
			click <a href="javascript:finalize('<%=strDateFrom%>','<%=strDateTo%>');">HERE TO FINALIZE DTR ENTRIES </a>
			</label>
			<font size="+2" color="#FF0000"><label id="finalize_dtr"></label></font>			
		  </td>
    </tr>
		<%}%>
    <tr bgcolor="#FFFFFF" class="thinborder">
      <td height="25" colspan="6" align="center">
			<%if(iAccessLevel > 1){%>
      <font size="1">
        <input type="submit" name="save" value=" SAVE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:saveList();"> 
        click to save selected employees </font>
      <%}%>			</td>
    </tr>	
	<%}%>
  </table>
  <%} // end if vRetResult != null && vRetResult.size() %>
	<%if(vEmpWithPayable != null && vEmpWithPayable.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td><div onClick="showBranch('branch6');swapFolder('folder6')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
          <b><font color="#0000FF">LIST OF EMPLOYEES WITH LOAN PAYABLE BUT NO MORE SCHEDULE</font></b></div>
        <span class="branch" id="branch6">
        <table width="95%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    	
 
    <tr bgcolor="#ffff99" class="thinborder"> 
      <td class="thinborder" height="25" colspan="2" align="center"><strong>EMPLOYEE 
        ID</strong></td>
      <td class="thinborder" width="72%" align="center"><strong>EMPLOYEE NAME</strong></td>
    </tr>
    <% 	//System.out.println("size " +vRetResult.size());
	for(i = 0, iCount=1; i < vEmpWithPayable.size(); i += 4,++iCount){		
	%>	
    <tr bgcolor="#FFFFFF" class="thinborder"> 
      <td class="thinborder" width="8%">&nbsp;<%=iCount%>.</td>
      <td class="thinborder" width="20%" height="25">&nbsp;<%=(String)vEmpWithPayable.elementAt(i)%></td>
      <td class="thinborder" >&nbsp;<%=WI.formatName((String)vEmpWithPayable.elementAt(i + 1), 
	  								(String)vEmpWithPayable.elementAt(i + 2), (String)vEmpWithPayable.elementAt(i + 3),4)%></td>
    </tr>
<%} // end for loop%>
  </table>
        </span> </td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="save_list">
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
  <input type="hidden" name="sal_index" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>