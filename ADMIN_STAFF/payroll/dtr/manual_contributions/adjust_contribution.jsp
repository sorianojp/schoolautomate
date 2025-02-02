<%@ page language="java" import="utility.*,payroll.PRManContribution, payroll.PayrollConfig,java.util.Vector" %>
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
<title>Manual Contribution Entry</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
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
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
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
	}
	else {
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
	document.form_.submit();
	//document.form_.hide_save.src = "../../../../../images/blank.gif";
	//this.SubmitOnce('form_');
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
		
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.amount_'+i+'.value=document.form_.amount_1.value');			
}

function CopyEmployerShare(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
		
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.employer_share_'+i+'.value=document.form_.employer_share_1.value');			
}

function CopyEC(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
		
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.ec_'+i+'.value=document.form_.ec_1.value');			
}

function CopyBracket(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
		
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.bracket_'+i+'.value=document.form_.bracket_1.value');			
}

function OpenSearch() {
	document.form_.searchEmployee.value="1";
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp   = null;
	boolean bolHasInternal = false;
	boolean bolIsGovernment = false;
	boolean bolHasConfidential = false;	
	boolean bolHasTeam = false;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Fixed Contributions","adjust_contribution.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasInternal = (readPropFile.getImageFileExtn("HAS_INTERNAL","0")).equals("1");
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");

		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");		
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");		
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","DTR",request.getRemoteAddr(),
														"adjust_contribution.jsp");
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

	PRManContribution prd = new PRManContribution();
	PayrollConfig prConfig = new PayrollConfig();
	Vector vRetResult = null;
	Vector vContributionTable = null;
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";	
	String[] astrSortByName = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal  = {"id_number","user_table.fname","lname","c_name","d_name"};	
	// cont_type 0 = sss
	// cont_type 1 = pag ibig
	// cont_type 2 = philhealth
	// cont_type 3 = peraa
	// cont_type 4 = gsis	
	String[] astrConType = {"SSS", "Pag-Ibig/HDMF","Philhealth","PERAA", "GSIS"};
	int i = 0;
	int iSearchResult = 0;
	String strPageAction = WI.fillTextValue("page_action");
	String[] astrType = {"SSS","PAG-IBIG","PHILHEALTH","PERAA","GSIS"};
	String strContType = WI.getStrValue(WI.fillTextValue("cont_type"), "0");

	if(strPageAction.length() > 0) {
		if(prd.operateOnContributionAdjustments(dbOP, request, Integer.parseInt(strPageAction)) == null){	
			strErrMsg = prd.getErrMsg();			
		}else {	
			if(strPageAction.equals("2"))
				strErrMsg = "Employee information successfully edited.";						
			else if(strPageAction.equals("0"))
				strErrMsg = "Employee ID successfully deleted.";
			else 
				strErrMsg = "Operation successful";
		}
	}
	
	if(strContType.equals("0")){
		vContributionTable = prConfig.operateOnSSSTable(dbOP, request,4);
	}else if(strContType.equals("2")){
		vContributionTable = prConfig.operateOnPHTable(dbOP, request,4);	
	}
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = prd.operateOnContributionAdjustments(dbOP,request,4);		
		if(vRetResult == null)
			strErrMsg = prd.getErrMsg();
		else
			iSearchResult = prd.getSearchCount();
	}	

	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prd.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./adjust_contribution.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : MANUAL ENTRY OF <%=astrType[Integer.parseInt(strContType)]%> CONTRIBUTION ::::</strong></font></td>
    </tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5">&nbsp;<font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Contribution</td>
			<%
			// cont_type 0 = sss
			// cont_type 1 = pag ibig
			// cont_type 2 = philhealth
			// cont_type 3 = peraa
			// cont_type 4 = gsis				
			%>			
      <td colspan="3">			
			<select name="cont_type" onChange="ReloadPage();">
        <%for(i = 0; i < astrConType.length; i++){
					if(!bolIsSchool && i == 3)
						continue;
					if(!bolIsGovernment && i == 4)
						continue;
				
					if(Integer.toString(i).equals(strContType)){%>
        <option value="<%=i%>" selected><%=astrConType[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrConType[i]%></option>
        <%}
				}%>
      </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Month/ Year </td>
      <td colspan="3"><select name="month_of" onChange="loadSalPeriods();">
        <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
      </select>
-
<select name="year_of" onChange="loadSalPeriods();">
  <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
</select>
(Must be filled up to display salary period information)</td>
    </tr>
    <tr>
      <td width="4%" height="24">&nbsp;</td>
      <td width="19%">Status</td>
      <td width="77%" colspan="3"><select name="pt_ft" onChange="ReloadPage();">
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
		  <td colspan="3"><select name="emp_position">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE " +
				" where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_position"), false)%>
      </select></td>
	  </tr>
		<%if(bolIsSchool){%>
		<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3">
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
      <td colspan="3"> <select name="c_index" onChange="loadDept();">
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
      <td height="10" colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
			<%
				strTemp = WI.fillTextValue("emp_id");
			%>
      <td height="10" colspan="3"><strong>
        <input name="emp_id" type="text" class="textbox" size="16" maxlength="20" 
				value="<%=strTemp%>" style="text-align:right" onKeyUp="AjaxMapName(1);">
        <a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></strong>
				<label id="coa_info"></label>				</td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10" colspan="5">OPTION:</td>
    </tr>
	<%if((vContributionTable != null && vContributionTable.size() > 1) && strContType.equals("0")){%>
    <tr>
      <td height="25" colspan="6"><div onClick="showBranch('ssstable');swapFolder('sssFolder')">
          &nbsp;<img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="sssFolder">&nbsp;<strong><font color="#0000FF">View/hide SSS Table</font></strong></div>
        <span class="branch" id="ssstable">
        <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
					<tr> 
						<td height="25" colspan="5" bgcolor="#B9B292" class="thinborder"><div align="center">SSS 
								SCHEDULE OF CONTRIBUTIONS FOR EMPLOYED MEMBERS EFFECTIVE <%=(String)vContributionTable.elementAt(9)%></div></td>
					</tr>
					<tr> 
						<td height="28" rowspan="3" align="center" class="thinborder"><font size="1"><strong>RANGE 
						OF COMPENSATION</strong></font></td>
						<td rowspan="3" align="center" class="thinborder"><font size="1"><strong>MONTHLY 
						SALARY CREDIT </strong></font></td>
						<td height="13" colspan="3" align="center" class="thinborder"><strong><font size="1">MONTHLY 
						CONTRIBUTION</font></strong></td>
					</tr>
					<tr> 
						<td height="15" colspan="2" align="center" class="thinborder"><font size="1"><strong>EMPLOYER</strong></font></td>
						<td align="center" class="thinborder"><font size="1"><strong>EMPLOYEE</strong></font></td>
					</tr>
					<tr> 
						<td height="13" align="center" class="thinborder"><font size="1"><strong>ER</strong></font></td>
						<td align="center" class="thinborder"><font size="1"><strong>EC</strong></font></td>
						<td align="center" class="thinborder"><font size="1"><strong>EE</strong></font></td>
					</tr>
					<% for(i =1; i < vContributionTable.size(); i += 10){%>
					<tr> 
						<td width="23%" height="20" align="center" class="thinborder"><font size="1"><%=(String)vContributionTable.elementAt(i + 9)%></font></td>
						<td width="24%" align="center" class="thinborder"><font size="1"><%=CommonUtil.formatFloat((String)vContributionTable.elementAt(i + 3),true)%></font></td>
						<td width="9%" align="center" class="thinborder"><font size="1"><%=CommonUtil.formatFloat((String)vContributionTable.elementAt(i + 4),true)%></font></td>
						<td width="9%" align="center" class="thinborder"><font size="1"><%=CommonUtil.formatFloat((String)vContributionTable.elementAt(i + 5),true)%></font></td>
						<td width="9%" align="center" class="thinborder"><font size="1"><%=CommonUtil.formatFloat((String)vContributionTable.elementAt(i + 6),true)%></font></td>
					</tr>
					<%}%>
			</table>
        </span> </td>
    </tr>
		<%}%>
	<%if((vContributionTable != null && vContributionTable.size() > 1) && strContType.equals("2")){%>
    <tr>
      <td height="25" colspan="6"><div onClick="showBranch('pHealthTable');swapFolder('pHealth')">
          &nbsp;<img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="pHealth">&nbsp;<strong><font color="#0000FF">View/hide Philhealth Table</font></strong></div>
        <span class="branch" id="pHealthTable">
        <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr> 
					<td height="25" colspan="5" bgcolor="#B9B292" class="thinborder"><div align="center">PHILHEALTH 
							SCHEDULE OF CONTRIBUTIONS FOR EMPLOYED MEMBERS EFFECTIVE <%=(String)vContributionTable.elementAt(8)%></div></td>
				</tr>
				<tr>
					<td width="10%" align="center" class="thinborder"><font size="1"><strong>MONTHLY 
					  SALARY BRACKET </strong></font></td> 
					<td width="23%" height="25" align="center" class="thinborder"><font size="1"><strong>MONTHLY 
					  SALARY  RANGE</strong></font></td>
					<td width="16%" align="center" class="thinborder"><font size="1"><strong>SALARY 
					  BASE</strong></font></td>
					<td width="12%" align="center" class="thinborder"><font size="1"><strong>PERSONAL 
					  SHARE (PS)<br>
					  (PS = SB *1.25%)</strong></font></td>
					<td width="10%" align="center" class="thinborder"><font size="1"><strong>EMPLOYER 
					  SHARE (ES)<br>
					  (ES =PS) </strong></font></td>
					</tr>
				<% for(i = 1; i < vContributionTable.size(); i += 10){%>
				<tr>
					<td align="center" class="thinborder" height="20"><font size="1"><%=(String)vContributionTable.elementAt(i + 9)%></font></td> 
					<td align="center" class="thinborder"><font size="1"><%=(String)vContributionTable.elementAt(i + 8)%></font></td>
					<td align="center" class="thinborder"><font size="1"><%=CommonUtil.formatFloat((String)vContributionTable.elementAt(i + 3),true)%></font></td>
					<td align="center" class="thinborder"><font size="1"><%=CommonUtil.formatFloat((String)vContributionTable.elementAt(i + 4),true)%></font></td>
					<td align="center" class="thinborder"><font size="1"><%=CommonUtil.formatFloat((String)vContributionTable.elementAt(i + 5),true)%></font></td>
					</tr>
				<%}%>
			</table>
        </span> </td>
    </tr>
		<%}%>		
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4"><%
	strTemp = WI.fillTextValue("with_schedule");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
View with manual adjustment 
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
View Employees w/out manual adjustment </td>
    </tr>
    <%if(bolHasInternal){%>
		<tr>
      <td height="10">&nbsp;</td>
		<%
			strTemp = WI.fillTextValue("for_external");
			if(strTemp.length() > 0)
				strTemp = "checked";
			else	
				strTemp = "";				
		%>
      <td height="10" colspan="4">&nbsp;
      <input type="checkbox" name="for_external" value="1" <%=strTemp%> onChange="SearchEmployee();"> 
      For Internal use </td>
    </tr>
		<%}%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">
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
					<%=prd.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
					<%=prd.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>      
				</select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>        
					<%=prd.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
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
      <td height="10" colspan="3"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
        <font size="1">click to display employee list to print.</font></td>
    </tr>
  </table>    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<!--
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
		-->
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/prd.defSearchSize;		
	if(iSearchResult % prd.defSearchSize > 0) ++iPageCount;
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
  <%
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
  <tr>
    <td height="20" colspan="9" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
  </tr>
  <tr>
    <td width="5%" class="thinborder">&nbsp;</td>
    <td width="10%" class="thinborder">&nbsp;</td>
    <td width="34%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
    <!--
			cont_type 0 = sss
			cont_type 1 = pag ibig
			cont_type 2 = philhealth
			cont_type 3 = peraa
			cont_type 4 = gsis
		-->		
    <td width="11%" align="center" valign="bottom" class="thinborder"><strong><font size="1">EE<br>
      ADJUSTMENT<br>
		<a href="javascript:CopyAll();">Copy all</a> </font></strong></td>
		<%if(!strContType.equals("3")){%>				
    <td width="11%" align="center" valign="bottom" class="thinborder"><strong><font size="1">ER</font><font size="1"><br>
      ADJUSTMENT<br>
      <a href="javascript:CopyEmployerShare();">Copy all</a> </font></strong></td>
		<%if(!strContType.equals("1") && !strContType.equals("2")){%>
    <td width="11%" align="center" valign="bottom" class="thinborder"><strong><font size="1">EC</font><font size="1"> COMPENSATION<br>
      <a href="javascript:CopyEC();">Copy all</a> </font></strong></td>
		<%}%>
		<%}%>
		<%if(strContType.equals("2")){%>
		<td width="10%" align="center" valign="bottom" class="thinborder"><strong><font size="1"><strong>SALARY BRACKET</strong><br>
      <a href="javascript:CopyBracket();">Copy all</a> </font></strong></td>		
		<%}%>
		
		
    <td width="8%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
      </strong>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
    </font></td>
  </tr>
  <% 	int iCount = 1;
	   for (i = 0; i < vRetResult.size(); i+=20,iCount++){
		 %>
  <tr>
		<input type="hidden" name="adj_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">		
		<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
		<input type="hidden" name="id_number_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+2)%>">	
    <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
    <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),
							(String)vRetResult.elementAt(i+5), 4).toUpperCase()%></strong></font></td>
    <%if((String)vRetResult.elementAt(i + 6)== null || (String)vRetResult.elementAt(i + 7)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>
    <%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 8);
			
			strTemp = CommonUtil.formatFloat(strTemp, false);
			strTemp = ConversionTable.replaceString(strTemp, ",","");
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>
    <td align="center" class="thinborder"><strong>
      <input name="amount_<%=iCount%>" type="text" class="textbox" size="4" maxlength="6" 
	      onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				value="<%=strTemp%>" style="text-align:right" >
    </strong></td>
		<%if(!strContType.equals("3")){%>		
    <%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 9);

			strTemp = CommonUtil.formatFloat(strTemp, false);
			strTemp = ConversionTable.replaceString(strTemp, ",","");

			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";			
		%>		
    <td align="center" class="thinborder"><strong>
      <input name="er_amt_<%=iCount%>" type="text" class="textbox" size="4" maxlength="6" 
	      onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				value="<%=strTemp%>" style="text-align:right" >
    </strong></td>
		<%if(!strContType.equals("1") && !strContType.equals("2")){%>
    <%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 10);

			strTemp = CommonUtil.formatFloat(strTemp, false);
			strTemp = ConversionTable.replaceString(strTemp, ",","");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";			
		%>
    <td align="center" class="thinborder"><strong>
      <input name="ec_amt_<%=iCount%>" type="text" class="textbox" size="4" maxlength="6" 
	      onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				value="<%=strTemp%>" style="text-align:right" >
    </strong></td>
		<%}
		}%>
		<%if(strContType.equals("2")){%>
    <%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 11);

			strTemp = CommonUtil.formatFloat(strTemp, false);
			strTemp = ConversionTable.replaceString(strTemp, ",","");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";			
		%>				
		<td align="center" class="thinborder"><strong>
		  <input name="bracket_<%=iCount%>" type="text" class="textbox" size="4" maxlength="6" 
	      onKeypress=" if(event.keyCode<46 || event.keyCode > 57) event.returnValue=false;"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				value="<%=strTemp%>" style="text-align:right" >
		</strong></td>
		<%}%>
    <td align="center" class="thinborder"><input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1">    </td>
  </tr>
  <%} //end for loop%>
	</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">  
  <tr>
    <td height="19" colspan="8">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" colspan="8" align="center">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" colspan="8" align="center">
			<%if(iAccessLevel > 1){%>
      <!--
			<a href='javascript:SaveData();'><img src="../../../../images/save.gif" border="0" id="hide_save"></a> 
			-->
      <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
      <font size="1">click to save entries</font>
      <%if((WI.fillTextValue("with_schedule")).equals("1") && iAccessLevel == 2){%>      
			<!--
			<a href='javascript:DeleteRecord();'><img src="../../../../images/delete.gif" width="55" height="28" border="0" id="hide_save"></a>
			-->
			<input type="button" name="delete" value="  Delete  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
      <font size="1">Click to delete selected </font>
        <%}%>
    	<!--
		  <a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" border="0"></a> 
			-->
			<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
			<font size="1"> click to cancel or go previous</font>
			<%}%>		</td>
  </tr>
  <input type="hidden" name="emp_count" value="<%=iCount%>">
</table>
<%}%>	
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
   <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="cont_type" value="<%=WI.fillTextValue("cont_type")%>">			
  <input type="hidden" name="print_page">
  <input type="hidden" name="searchEmployee" > 
  <input type="hidden" name="page_action">	
	<input type="hidden" name="copy_all">			
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
