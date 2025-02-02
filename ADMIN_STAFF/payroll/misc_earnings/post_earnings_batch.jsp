<%@ page language="java" import="utility.*,java.util.Vector,payroll.PReDTRME, payroll.PRMiscEarnings" %>
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
<title>Set Misc. deduction by batch</title>
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

  /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:7;
	top:0;
    width:285px;
	height:200;/** it expands on its own.. **/
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }
  div.showPayment{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    left:7;
	top:0;
    width:400px;
	height:200;/** it expands on its own.. **/
	overflow:auto;
	visibility:hidden
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

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}

function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
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

function SaveData() {
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "1";
	document.form_.save.disabled = true;
	//document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}

function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function CopyAll(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
		
	if(eval(vItems) > 16){
		document.form_.copy_all.value = "1";
		document.form_.print_page.value = "";
		document.form_.searchEmployee.value = "1";		
		this.SubmitOnce('form_');
	}else{
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.amount_'+i+'.value=document.form_.amount_1.value');			
	}
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

function doPrint( vRetResult ){	
	var pgLoc = "./post_earnings_batch_print.jsp?result=" + vRetResult;
	var win=window.open(pgLoc,"PrintWindow",'width=770,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ShowHideLayer() {
	if(document.form_.show_dlshsi_ot_meal_allowance.checked)
		document.all.processing.style.visibility='visible';	
	else
		document.all.processing.style.visibility='hidden';	
	
}
function GetEmpListWithOT() {
	if(document.form_.date_from.value == '' || document.form_.date_to.value == '') {
		alert("Please enter date from/to value.");
		return;
	}
	document.form_.with_schedule[1].checked = true;
	document.form_.emp_list_with_addl_con.value='1';
	
	this.SearchEmployee();
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
//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./post_earnings_batch_print.jsp"/>
	<% 
return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions (Batch)","post_earnings_batch.jsp");

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
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"post_earnings_batch.jsp");
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

	Vector vRetResult         = null;
	Vector vSalaryPeriod      = null;//detail of salary period.
	PReDTRME prEdtrME         = new PReDTRME();
	PRMiscEarnings PREarnings = new PRMiscEarnings (request);
	int iSearchResult = 0;
	int i = 0;
	String strPayrollPeriod  = null;
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	String[] astrSortByName    = {"Employee ID","Firstname",strTemp,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","c_name","d_name"};
	String[] astrSalaryBase    = {"Monthly rate", "Daily rate", "Hourly rate"};
	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0){
		if(PREarnings.operateOnMiscEarningsBatch(dbOP, Integer.parseInt(strPageAction)) == null){
			strErrMsg = PREarnings.getErrMsg();
		} else {
			strErrMsg = "Operation successful";		
		}
	}
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = PREarnings.operateOnMiscEarningsBatch(dbOP,4);
		if(vRetResult == null)
			strErrMsg = PREarnings.getErrMsg();
		else
			iSearchResult = prEdtrME.getSearchCount();
	}	
	if(WI.fillTextValue("year_of").length() > 0) {
		vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	}
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	int iIndexOf = 0; int iMultiplier = 0;
	boolean bolShowOTFreq = false;
	if(strSchCode.startsWith("DLSHSI") && WI.fillTextValue("with_schedule").equals("0") && WI.fillTextValue("show_dlshsi_ot_meal_allowance").length() > 0) {
		bolShowOTFreq = true;
		if(PREarnings.vAddlInfo == null)
			PREarnings.vAddlInfo = new Vector();
	}
	
	
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="ShowHideLayer();">
<form action="post_earnings_batch.jsp" method="post" name="form_">

<div id="processing" class="processing"  style="visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#FFCC99">
	  <tr>
		  <td valign="top">
		  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
				  <tr>
					<td class="thinborderBOTTOM" style="font-size:11px;" height="22">Date Range </td>
			      </tr>
				  <tr>
					<td style="font-size:11px;" height="22">
					<input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
					  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
						<a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
						 to&nbsp; 
						<input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
					  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
						<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>					</td>
			      </tr>
				  <tr>
					<td style="font-size:11px;" height="22" valign="top">(Enter Cut off Date) </td>
			      </tr>
				  <tr>
				    <td style="font-size:11px;" align="center">
						<input type="button" value="Show Employee List" onClick="GetEmpListWithOT();" style="font-size:11px; height:25px;border: 2px solid #FF0000; background:#cccccc; color:#990099"> &nbsp;
					</td>
		      </tr>
				  <tr>
				    <td style="font-size:9px; font-weight:bold">
					Note: Result will show employees having more than 4 hours Approved OT.</td>
		      </tr>
			</table>
		  </td>
	  </tr>
</table>
</div>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        MISCELLANEOUS EARNINGS SET BY BATCH PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><a href="./misc_deduction_main.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    
	<tr> 
      <td height="25">&nbsp;</td>
      <td>Earning Name</td>
		<td width="78%" style="font-size:9px; color:#0000FF; font-weight:bold">
			  <select name="earning_index">
				  <option value="">Select earning Name</option>
				  <%=dbOP.loadCombo("earn_ded_index","earn_ded_name", " from preload_earn_ded order by earn_ded_name",WI.fillTextValue("earning_index"),false)%>
			  </select>
			  
			  <%if(strSchCode.startsWith("DLSHSI")){%>
			  	<input type="checkbox" name="show_dlshsi_ot_meal_allowance" value="checked" <%=WI.fillTextValue("show_dlshsi_ot_meal_allowance")%> onClick="ShowHideLayer();"> Show Employee Eligible for OT Meal Allowance
			  <%}%>
			  
		</td>
    </tr>
	
	<tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">Release date</td>
        <!--
			if(vInfoDetail!=null)
				strTemp = (String)vInfoDetail.elementAt(2);
			else
				strTemp= WI.fillTextValue("release_date");

			if(strTemp.trim().length() == 0)
				strTemp = WI.getTodaysDate(1);
		-->
		
      <td height="29"><strong>
        <input name="release_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("release_date")%>" class="textbox"
	    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.release_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0"></a>
      </strong></td>
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
      <td height="10">Office/Dept filter</td>
      <td height="10"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
(enter office/dept's first few characters)</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"><label id="coa_info"></label></td>
    </tr>
	<tr>
		<td height="10">&nbsp;</td>
		<td height="10">Remarks</td>
		<td height="10">
			<strong>
			<input  name="remarks" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
			onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("remarks")%>" size="32" maxlength="128">
			</strong>
		</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				if(WI.fillTextValue("inc_resigned").length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
		<td height="10" colspan="2">
			<input name="inc_resigned" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">
			include resigned employees 
		
		</td>
    </tr>

    <tr> 
      <td height="10" colspan="3"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10" colspan="3">OPTION:</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><%
	strTemp = WI.fillTextValue("with_schedule");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
View with set deductions 
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
View Employees w/out set deduction </td>
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
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font>
		</td>
    </tr>
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<% if(vRetResult != null && vRetResult.size() > 0 && WI.fillTextValue("with_schedule").equals("1")){%>
    <tr>         
      <td height="10"><div align="right"><font size="2">Number of Employees / rows Per 
        Page :</font>
                  <select name="num_rec_page">
                    <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
                    <option selected value="<%=i%>"><%=i%></option>
                    <%}else{%>
                    <option value="<%=i%>"><%=i%></option>
                    <%}}%>
                  </select>
                  <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></div></td>      
    </tr>
		<%}%>
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
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="11" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    <tr align="center">
      <td width="3%" class="thinborder" align="left" height="23">&nbsp;</td>
      <td width="10%" class="thinborder" style="font-weight:bold; font-size:9px;">EMPLOYEE ID</td> 
      <td width="28%" class="thinborder" style="font-weight:bold; font-size:9px;">EMPLOYEE NAME</td>
      <td width="40%" class="thinborder" style="font-weight:bold; font-size:9px;">DEPARTMENT/OFFICE</td>
<%if(bolShowOTFreq) {%>
      <td width="10%" class="thinborder" style="font-weight:bold; font-size:9px;">OT Frequency <br>(having &gt;=4hrs) </td>
<%}%>
      <td width="10%" class="thinborder" style="font-weight:bold; font-size:9px;">AMOUNT
      <%if(WI.fillTextValue("with_schedule").equals("0")){%>
		 <br><a href="javascript:CopyAll();">Copy all</a>
	  <%}%>	  </td>
	  <%if(WI.fillTextValue("with_schedule").equals("1")){%>
		<td width="10%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">EARNING BAL.</td>
      <%}%>
	  <td width="9%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">SELECT ALL<br>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>     </td>
    </tr>
    <% 	
		int iCount = 1;
		String strTDColor = null;//grey if already deducted
		String strDisabled = null;
		double dEarnBal = 0d;
		double dEarnAmt = 0d; //System.out.println(PREarnings.vAddlInfo);
		
		for (i = 0; i < vRetResult.size(); i+=9,iCount++){
			dEarnBal = Double.parseDouble( WI.getStrValue((String)vRetResult.elementAt(i + 8),"0"));
			dEarnAmt = Double.parseDouble( WI.getStrValue((String)vRetResult.elementAt(i + 6),"0"));
			if( dEarnBal < dEarnAmt ){
				strTDColor = "bgcolor=#DDDDDD";
				strDisabled = " disabled";
			} else {
				strTDColor = "";
				strDisabled = "";
			}
	 %>
    <tr <%=strTDColor%>>
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
 			<input type="hidden" name="post_ded_index_<%=iCount%>" value="<%=vRetResult.elementAt(i+7)%>">			
			<input type="hidden" name="emp_id_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">			
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%></td>
<%if(bolShowOTFreq) {
iMultiplier = 1;
iIndexOf = PREarnings.vAddlInfo.indexOf(vRetResult.elementAt(i));
if(iIndexOf == -1) {
	strTemp = "Not Found";
}
else {
	strTemp = (String)PREarnings.vAddlInfo.elementAt(iIndexOf + 1);
	iMultiplier = Integer.parseInt(strTemp);
}
%>
		<td align="center" class="thinborder"><%=strTemp%></td>
<%}
	
			strTemp = "";
	
			if(WI.fillTextValue("with_schedule").equals("1") && !WI.fillTextValue("copy_all").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 6);
			else{
				if(WI.fillTextValue("copy_all").equals("1"))
					strTemp = WI.fillTextValue("amount_1");
				
				//hardcoded to 10peso per frequency for lasalle..
				if(strTemp.length() == 0 && iMultiplier > 0)
					strTemp = String.valueOf(10*iMultiplier);
			}
			//strTemp = comUtil.formatFloat(strTemp, true);
			strTemp = WI.getStrValue(strTemp,"0");
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>			
      <td align="center" class="thinborder"><strong> 
		<%if(WI.fillTextValue("with_schedule").equals("1")){%>
			<%=strTemp%>
		<%}else{%>
			<input name="amount_<%=iCount%>" value="<%=strTemp%>" type="text" class="textbox" size="10" maxlength="8" style="text-align:right" onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" />
		<%}%>
      </strong></td>
		<%if(WI.fillTextValue("with_schedule").equals("1")){
			strTemp = "";
			strTemp = (String)vRetResult.elementAt(i+8);
			strTemp = WI.getStrValue(strTemp,"0");
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "&nbsp;";
		%>	
	  
	  <td align="center" class="thinborder"><strong> 
			<%=strTemp%>
	  </strong></td>
		<%}%>
      <td align="center" class="thinborder"><input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1" <%=strDisabled%>></td>
    </tr>
    <%} //end for loop%>
  </table>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr>
		<td height="25" colspan="6" align="center">
			<%if(WI.fillTextValue("with_schedule").equals("0")){%>
				<input type="checkbox" value="0" name="is_taxable" />
				Earning is non taxable
			<%}%>
			<%if(iAccessLevel > 1){%>
				<%if((WI.fillTextValue("with_schedule")).equals("1") && iAccessLevel == 2){%>
					<input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
					<font size="1">Click to delete selected </font>
				<%}%>
				<%if((WI.fillTextValue("with_schedule")).equals("0")){%>
					<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
				<font size="1">Click to save entries</font>
				<%}%>
			<%}%>
			<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
			<font size="1"> click to cancel or go previous</font>
		</td>
    </tr>
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
  
<% } // end vRetResult != null && vRetResult.size() > 0 %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="searchEmployee" > 
  <input type="hidden" name="page_action">	
  <input type="hidden" name="copy_all">	
  <input type="hidden" name="emp_list_with_addl_con">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>