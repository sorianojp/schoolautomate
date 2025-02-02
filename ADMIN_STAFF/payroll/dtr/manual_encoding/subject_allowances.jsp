<%@ page language="java" import="utility.*,java.util.Vector, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Subject Allowances encoding</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD.thinborderBOTTOMRIGHT {
	border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOM{
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMLEFTRIGHT{
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function ReloadPage(){	
	document.form_.page_reloaded.value = "1";
	document.form_.searchEmployee.value="";
	document.form_.print_page.value="";	
	this.SubmitOnce("form_");
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(){
  var vProceed = confirm('Remove selected records?');
  if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.searchEmployee.value = "1";
		document.form_.print_page.value = "";
		this.SubmitOnce("form_");
  }	
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./subject_allowances.jsp";
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
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

function CopyHour(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	

	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.form_.hour_worked_'+i+'.value=document.form_.hour_worked_1.value');			
}

function CopyMin(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	

	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.form_.min_work_'+i+'.value=document.form_.min_work_1.value');			
		
}

function CopyRate(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	

	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.form_.rate_'+i+'.value=document.form_.rate_1.value');			
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
							 "&year_of="+strYear+"&is_weekly="+strWeekly;

	this.processRequest(strURL);
}
-->
</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strHasWeekly = null;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="subject_allowances_print.jsp" />
<% return;}

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-CONFIGURATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Subject Allowances","subject_allowances.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
										
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}

//end of authenticaion code.
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	
	PReDTRME prEdtrME = new PReDTRME();
	
	String strPayrollPeriod  = null;
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strPageAction = WI.fillTextValue("page_action");
	String strTemp2 = null;
	String strEmpCatg = null;
	String[] astrCategory = {"Staff","Faculty","Employees"};
	String[] astrStatus = {"Part-Time","Full-Time","Contractual",""};
	String[] astrCondition = {"between","more than","less than","equal to"};
	String strCurSem = (String) request.getSession(false).getAttribute("cur_sem");
	String strCurSYFr = (String) request.getSession(false).getAttribute("cur_sch_yr_from");
	String strCurSYto = (String) request.getSession(false).getAttribute("cur_sch_yr_to");
	String[] astrSortByName    = {"Employee ID","Firstname","College","Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","c_name","d_name"};
	String strHourCon = null;
	String strLoadCon = null;
	String strRateCon = null;
	boolean bolHasItems = false;
	int iCount = 1;
	int i = 0;
	int iSearchResult = 0;
	
	if (strPageAction.length() > 0){
		if (strPageAction.compareTo("0")==0) {
			if (prEdtrME.operateOnSubjectAllowances(dbOP,request,0) != null){
				strErrMsg = " Allowance removed successfully ";
			}else{
				strErrMsg = prEdtrME.getErrMsg();
			}
		}else if(strPageAction.compareTo("1") == 0){
			if (prEdtrME.operateOnSubjectAllowances(dbOP,request,1) != null){
				strErrMsg = " Allowance posted successfully ";
			}else{
				strErrMsg = prEdtrME.getErrMsg();
			}
		}
	}
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
		
		vRetResult = prEdtrME.operateOnSubjectAllowances(dbOP,request,4);
		
		if (vRetResult == null){
			strErrMsg = prEdtrME.getErrMsg();	
		}else{
			iSearchResult = prEdtrME.getSearchCount();
		}
	}	
 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);	
%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./subject_allowances.jsp" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: SUBJECT ALLOWANCE IMPLEMENTATION PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    

    <tr>
      <td height="24">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td><select name="month_of" onChange="loadSalPeriods();">
        <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
      </select>
-
<select name="year_of" onChange="loadSalPeriods();">
  <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
</select>
(Must be filled up to display salary period information)</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Salary Period</td>
      <td><strong>
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
        <%}// check if the company has weekly salary type%></td>
    </tr>
    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Subject allowance </td>
			<%
				strTemp = WI.fillTextValue("sub_index");
			%>			
      <td><select name="sub_index">
        <option value="">Select Subject</option>
        <%=dbOP.loadCombo("subject.sub_index","sub_code",
				" from e_sub_section join subject on (e_sub_section.sub_index = subject.sub_index) " +
			  " join curriculum on (e_sub_section.cur_index = curriculum.cur_index) " +
				" where offering_sy_from = " + strCurSYFr + " and offering_sy_to = " + strCurSYto + 
				" and offering_sem = " + strCurSem + " and e_sub_section.is_del = 0 " +
				" and curriculum.is_del = 0 and (subject.is_del = 0 or subject.is_del = 2) " +
				" group by sub_code, subject.sub_index, subject.is_del " +
				" order by subject.is_del asc, sub_code asc", strTemp , false)%>
      </select></td>
    </tr>
    <tr>
      <td width="3%" height="24">&nbsp;</td>
      <td width="20%">Employee ID </td>
			<%
				strTemp = WI.fillTextValue("emp_id");
			%>
      <td width="77%"><input name="emp_id" type="text" class="textbox" value="<%=WI.getStrValue(strTemp,"")%>" size="8" maxlength="8"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      <a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a><label id="coa_info"></label></td>
    </tr>
   
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
	  <%
		strTemp = WI.fillTextValue("pt_ft");
		strTemp= WI.getStrValue(strTemp);
	  %>	  	  
      <td><select name="pt_ft">
          <option value="">ALL</option>
		  <%if (strTemp.equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if (strTemp.equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select></td>
    </tr>	
    <% 
	String strCollegeIndex = null;
	strCollegeIndex = WI.fillTextValue("c_index");
	strCollegeIndex = WI.getStrValue(strCollegeIndex);
	%>
	<%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
	  <%
	 	strTemp = WI.fillTextValue("employee_category");
		strTemp= WI.getStrValue(strTemp);
	  %>	  	  	  
      <td>
	    <select name="employee_category">
          <option value="">ALL</option>
          <%if (strTemp.equals("0")){%>
		  <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>
          <%}else if (strTemp.equals("1")){%>
		  <option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>
          <%}else{%>
		  <option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>
          <%}%>
		</select> </td>
    </tr>
	<%}%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> <select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
	  <%
		  strTemp = WI.fillTextValue("d_index");
	  %>	  	  	  
      <td> 
				<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", strTemp,false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , strTemp,false)%> 
          <%}%>
        </select>
				</label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)
</td>
    </tr>
    
    <tr>
      <td height="11" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="11" colspan="3">OPTION:</td>
    </tr>
    <tr>
      <td height="11" colspan="3"><%
	strTemp = WI.fillTextValue("with_schedule");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
        View with entered allowance
        <%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
	<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
View faculties without allowance </td>
    </tr>
    <tr>
      <td height="11" colspan="3">
			<%
				if(WI.fillTextValue("view_all").length() > 0)
					strTemp = " checked";				
				else
					strTemp = "";				
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();"> View ALL </td>
    </tr>
		<%if(WI.fillTextValue("with_schedule").equals("1")){%>
    	
		<%}%>
  </table>	
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=prEdtrME.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=prEdtrME.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by3">
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
				<!--<input type="image" onClick="SearchEmployee()" src="../../../../images/form_proceed.gif"> -->
				<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="SearchEmployee();">
        <font size="1">click to display employee list to print.</font></td>
    </tr>
  </table>	
  
 <% if (vRetResult != null) {%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>   
      <% if (vRetResult != null && vRetResult.size() > 0 ){%>
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
                  <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	  <%
	  if((WI.fillTextValue("with_schedule")).equals("1"))
	    strTemp = "EMPLOYEES WITH ALLOWANCE";
	  else
	    strTemp = "EMPLOYEES WITHOUT ALLOWANCE";
	  %>	
    <tr> 
      <td height="25" colspan="8" align="center" bgcolor="#B9B292"><strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="24" rowspan="2" align="center" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
      <td width="9%" rowspan="2" align="center" class="thinborderBOTTOMRIGHT"><strong>EMPLOYEE ID </strong></td>
      <td width="21%" rowspan="2" align="center" class="thinborderBOTTOMRIGHT"><strong>EMPLOYEE NAME </strong></td>
      <td rowspan="2" align="center" class="thinborderBOTTOMRIGHT"><strong>DEPARTMENT/OFFICE</strong></td>
      <td colspan="2" align="center" class="thinborderBOTTOMRIGHT"><strong>WORK DURATION </strong></td>
      <td rowspan="2" align="center" class="thinborderBOTTOMRIGHT"><strong>Rate<br>
              <a href="javascript:CopyRate();">Copy all</a></strong></td>
      <%if(WI.fillTextValue("with_schedule").equals("1")){%>
			<%}%>			
			<%
				strTemp = "";
				if(WI.fillTextValue("selAllSave").length() > 0){
					strTemp = " checked";
				}else{
					strTemp = "";
				}
			%>
      <td rowspan="2" align="center" class="thinborderBOTTOMRIGHT"><strong>SELECT ALL<br>
      </strong>          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" <%=strTemp%>>      </td>
    </tr>
    <tr>
      <td align="center" class="thinborderBOTTOMRIGHT"><strong>Hours<font size="1"><br>
            <a href="javascript:CopyHour();">Copy all</a></font></strong></td>
      <td align="center" class="thinborderBOTTOMRIGHT"><strong>Minutes <br>
              <a href="javascript:CopyMin();">Copy all</a></strong></td>
    </tr>
    <% String[] astrDeductAbsent={"../../../../images/x.gif","../../../../images/tick.gif"};
	for (i = 0; i< vRetResult.size() ; i+=12, iCount++) {%>
		<%if(WI.fillTextValue("with_schedule").equals("1")){%>
		<input type="hidden" name="allowance_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		<%}%>
		<input type="hidden" name="user_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
    <tr> 
      <td height="25" align="right" class="thinborderBOTTOMLEFTRIGHT"><%=iCount%>&nbsp;</td>
			<td class="thinborderBOTTOMRIGHT"><span class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></span></td>			
			<td class="thinborderBOTTOMRIGHT"><font size="1"><strong>&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),
							(String)vRetResult.elementAt(i+5), 4).toUpperCase()%></strong></font></td>
      <%if((String)vRetResult.elementAt(i + 6)== null || (String)vRetResult.elementAt(i + 7)== null){
		  	strTemp = "";			
		  }else{
		  	strTemp = " - ";
		  }
		%>							
			<td width="34%" class="thinborderBOTTOMRIGHT"><span class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"")%> </span></td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 8);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>			
			<td width="8%" align="center" class="thinborderBOTTOMRIGHT"><strong>
			  <input name="hour_worked_<%=iCount%>" type="text" class="textbox" size="4" maxlength="6" 
	      onblur="AllowOnlyInteger('form_','hour_worked_<%=iCount%>');style.backgroundColor='white'" 
				onfocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" style="text-align:right" 
			  onKeyUp="AllowOnlyInteger('form_','hour_worked_<%=iCount%>');">
			</strong></td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 11);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>						
			<td width="8%" align="center" class="thinborderBOTTOMRIGHT"><strong>
			  <input name="min_work_<%=iCount%>" type="text" class="textbox" size="4" maxlength="6" 
	      onblur="AllowOnlyInteger('form_','min_work_<%=iCount%>');style.backgroundColor='white'" 
				onfocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" style="text-align:right" 
			  onKeyUp="AllowOnlyInteger('form_','min_work_<%=iCount%>');">
			</strong></td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 9);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
			else
				strTemp = CommonUtil.formatFloat(Double.parseDouble(strTemp),2);
		%>						
			<td width="8%" align="center" class="thinborderBOTTOMRIGHT"><strong>
			  <input name="rate_<%=iCount%>" type="text" class="textbox" size="5" maxlength="10" 
	      onblur="style.backgroundColor='white'" 
				onfocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" style="text-align:right" 
			  onKeyUp="AllowOnlyIntegerExtn('form_','rate_<%=iCount%>','.');">
			</strong></td>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">							
      <%if(WI.fillTextValue("with_schedule").equals("1")){%>
      <%}%>
			<%
				strTemp ="";
				if(WI.fillTextValue("save_"+iCount).equals("1")){
					strTemp = " checked";
				}else{
					strTemp = "";
				}
			%>
			<td width="9%" align="center" class="thinborderBOTTOMRIGHT"><span class="thinborder">
        <input type="checkbox" name="save_<%=iCount%>" value="1" <%=strTemp%> tabindex="-1">
      </span></td>
    </tr>
    <%}// end for loop%>
		<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">		
    <tr> 
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="35" colspan="2" align="center">  
        <% if (iAccessLevel > 1) {%>
				<% if((WI.fillTextValue("with_schedule")).equals("1")){%>        
				<!--
				<a href="javascript:AddRecord()"><img src="../../../../images/edit.gif" width="48" height="28"  border="0"></a>
				-->
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
				<font size="1">click to edit entries </font> 
				<!--
				<a href='javascript:DeleteRecord();'><img src="../../../../images/delete.gif" width="55" height="28" border="0" id="hide_save"></a>
				-->
        <input type="button" name="delete" value="Delete" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
        <font size="1">Click to delete selected</font>
        <%}else{%>
				<!--<a href="javascript:AddRecord()"><img src="../../../../images/save.gif" width="48" height="28"  border="0"></a>-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
				<font size="1">click to save entries </font> 				
				<%}%>
				<!--
        <a href="javascript:CancelRecord()"><img src="../../../../images/cancel.gif" border="0"></a>
				-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">				
				<font size="1">click to cancel entries</font> 
        <%} // end iAccessLevel > 1%>        </td>
    </tr>
    <tr> 
      <td width="5%" height="10">&nbsp;</td>
      <td width="95%" height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>	
<%}//end vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_reloaded" value="0">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
<input type="hidden" name="searchEmployee"> 
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
