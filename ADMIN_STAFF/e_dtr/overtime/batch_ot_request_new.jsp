<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.eDTRUtil,
																eDTR.OverTime" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View OverTime Requests</title>
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
TD{
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
</style>
</head>

<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--

function CancelRecord(){
	location = "./batch_ot_request_new.jsp";
}
///ajax here to load dept..
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.dtr_op.c_index[document.dtr_op.c_index.selectedIndex].value;
		
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

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

	function ReloadPage(){
		document.dtr_op.submit();
	}

	function ViewRecords(){
		document.dtr_op.reset_values.value = '1';	
		document.dtr_op.print_page.value = "";
		document.dtr_op.viewAll.value=1;
		document.dtr_op.submit();
	}

	function goToNextSearchPage()
	{
		document.dtr_op.viewAll.value=1;
		document.dtr_op.delete_records.value = "0";
		document.dtr_op.submit();
	}
	 
	function printpage(){
		document.dtr_op.print_page.value = "1";
		document.dtr_op.delete_records.value = "0";		
		document.dtr_op.submit();
	}

//all about ajax - to display student list with same name.
		var objCOA;
		var objCOAInput;
function AjaxMapName(strFieldName, strLabelID) {
		objCOA=document.getElementById(strLabelID);
		var strCompleteName = eval("document.dtr_op."+strFieldName+".value");
		eval('objCOAInput=document.dtr_op.'+strFieldName);
		if(strCompleteName.length <=2) {
			objCOA.innerHTML = "";
			return ;
		}		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
		"&name_format=4&complete_name="+escape(strCompleteName);
		this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	objCOAInput.value = strID;
	objCOA.innerHTML = "";
	//document.dtr_op.submit();
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function checkAllSave() {
	var maxDisp = document.dtr_op.emp_count.value;
	//unselect if it is unchecked.
	if(!document.dtr_op.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=true');
	}
}	

function checkAllNextDay() {
	var maxDisp = document.dtr_op.emp_count.value;
	//unselect if it is unchecked.
	if(!document.dtr_op.selAllNextDay.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.dtr_op.is_nextday_logout_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.dtr_op.is_nextday_logout_'+i+'.checked=true');
	}
}	

function SaveRequests(){
	document.dtr_op.save_requests.value = "1";
	document.dtr_op.viewAll.value="1";
	document.dtr_op.submit();
}

function CopyDetails(){
	var vItems = document.dtr_op.emp_count.value;
	if (vItems.length == 0)
		return;	
	var vObject	= document.getElementById("loader_");
//	if(eval(vItems) > 16){
//		document.dtr_op.copy_all.value = "1";
// 		document.dtr_op.viewAll.value = "1";		
//		this.SubmitOnce('dtr_op');
//	}else{
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.dtr_op.ot_reason_'+i+'.value=document.dtr_op.ot_reason_1.value');			
//	}
}

function CopyOT(){
	var vItems = document.dtr_op.emp_count.value;
	if (vItems.length == 0)
		return;	
	var bolHasBreak = '0';
	if(eval(vItems) > 16){
		document.dtr_op.copy_all.value = "1";
 		document.dtr_op.viewAll.value = "1";		
 		this.SubmitOnce('dtr_op');
	}else{
		for (var i = 1 ; i < eval(vItems);++i){
			eval('document.dtr_op.ot_date_'+i+'.value=document.dtr_op.ot_date_1.value');
			eval('document.dtr_op.ot_type_'+i+'.value=document.dtr_op.ot_type_1.value');
			eval('document.dtr_op.am_hr_fr_'+i+'.value=document.dtr_op.am_hr_fr_1.value');
			eval('document.dtr_op.am_min_fr_'+i+'.value=document.dtr_op.am_min_fr_1.value');
			eval('document.dtr_op.ampm_from_'+i+'.value=document.dtr_op.ampm_from_1.value');
			eval('document.dtr_op.am_hr_to_'+i+'.value=document.dtr_op.am_hr_to_1.value');
			eval('document.dtr_op.am_min_to_'+i+'.value=document.dtr_op.am_min_to_1.value');
			eval('document.dtr_op.ampm_to_'+i+'.value=document.dtr_op.ampm_to_1.value');
			eval('document.dtr_op.max_ot_hour_'+i+'.value=document.dtr_op.max_ot_hour_1.value');
			
			eval('document.dtr_op.break_hr_fr_'+i+'.value=document.dtr_op.break_hr_fr_1.value');
			eval('document.dtr_op.break_min_fr_'+i+'.value=document.dtr_op.break_min_fr_1.value');
			eval('document.dtr_op.break_ampm_fr_'+i+'.value=document.dtr_op.break_ampm_fr_1.value');
			eval('document.dtr_op.break_hr_to_'+i+'.value=document.dtr_op.break_hr_to_1.value');
			eval('document.dtr_op.break_min_to_'+i+'.value=document.dtr_op.break_min_to_1.value');
			eval('document.dtr_op.break_ampm_to_'+i+'.value=document.dtr_op.break_ampm_to_1.value');
  			if(document.dtr_op.has_break_1.checked)
				eval('document.dtr_op.has_break_'+i+'.checked=true');
			else
				eval('document.dtr_op.has_break_'+i+'.checked=false');
		}
	}
}

	function printpage(){
		document.dtr_op.print_page.value = "1";
		document.dtr_op.submit();
	}
-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
WebInterface WI = new WebInterface(request);
if(WI.fillTextValue("print_page").equals("1")){ //System.out.println("hellow1");
%>
	<jsp:forward page="./batch_ot_request_print.jsp" />
<%}

	DBOperation dbOP = null;	
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");

	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasTeam = false;
	boolean bolIsGovernment = false;
	int i = 0;	

//add security heot.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record--OVERTIME MANAGEMENT-Overtime Request(Batch)","batch_ot_request_new.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolIsGovernment= (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");		
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
int iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"eDaily Time Record","OVERTIME MANAGEMENT",
											request.getRemoteAddr(),"batch_ot_request_new.jsp");	
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","OVERTIME MANAGEMENT-Request Overtime",request.getRemoteAddr(), 
														"batch_ot_request_new.jsp");	
}
if(bolMyHome && iAccessLevel == 0) { 
	iAccessLevel = 1;	
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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};
if(bolIsSchool)
	strTemp = "College";
else
	strTemp = "Division";

String[] astrSortByName    = {"Requested By","Date of Request","Date of OT", "No of Hours",
															"Status", "Last Name(Requested for)","Department",strTemp};

String[] astrSortByVal     = {"head_.lname","request_date","ot_specific_date","no_of_hour",
															"approve_stat", "sub_.lname","d_name","c_name"};

int iSearchResult = 0;

String strDateFrom = WI.fillTextValue("DateFrom");
String strDateTo = WI.fillTextValue("DateTo");
boolean bolHasOvertime = WI.fillTextValue("with_schedule").equals("1");

if (strDateFrom.length() ==0){
	String[] astrCutOffRange = eDTRUtil.getCurrentCutoffDateRange(dbOP,true);
	if (astrCutOffRange!= null && astrCutOffRange[0] != null){
		strDateFrom = astrCutOffRange[0];
		strDateTo = astrCutOffRange[1];
	}
}

OverTime ot = new OverTime();
Vector vRetResult = null;
boolean bolRetain = true;
Vector vOTSetting = null;
vOTSetting = ot.operateOnMinOvertime(dbOP, request, 3);

String strOTDate = null;
String strOTType = null;
String strHrFr = null;
String strMinFr = null;
String strAMPMFr = null;

String strHrTo = null;
String strMinTo = null;
String strAMPMTo = null;

String strBreakHrFr = null;
String strBreakMinFr = null;
String strBreakAMPMFr = null;

String strBreakHrTo = null;
String strBreakMinTo = null;
String strBreakAMPMTo = null;


String strMaxOT = null;
String strIsNextDay = null;
String strHasBreak = null;
//String strDefOTType = 
//			" select ot_type_index from pr_ot_mgmt where is_valid = 1 and is_for_ot = 1"+ 
//			" and exists(select holiday_type_index from EDTR_HOLIDAY where is_del = 0 "+
//			"    and holiday_date = '" + WI.getTodaysDate(1) + "' " +
//			"     and EDTR_HOLIDAY.holiday_type_index = pr_ot_mgmt.holiday_type_index)";
//		strDefOTType = dbOP.getResultOfAQuery(strDefOTType, 0);

if(WI.fillTextValue("reset_values").length() > 0)
	bolRetain = false;

if(WI.fillTextValue("save_requests").length() > 0){
	vRetResult = ot.addBatchOTRequestPerRow(dbOP, request, 1);
	if(vRetResult == null)
		strErrMsg = ot.getErrMsg();
	else{
		strErrMsg = "Operation Succesful";
		bolRetain = false;
	}
}

if (WI.fillTextValue("viewAll").equals("1")){
	vRetResult = ot.addBatchOTRequestPerRow(dbOP, request, 4);
	if (vRetResult==null){
		strErrMsg =  ot.getErrMsg();
	}else{
		iSearchResult = ot.getSearchCount();
	}
}
%>
<form action="./batch_ot_request_new.jsp" method="post" name="dtr_op">
<input type="hidden" name="print_page">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        OVERTIME REQUEST BY BATCH ::::</strong></font></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="28" colspan="5"><font size="2" color="#FF0000"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    
    <tr>
      <td height="24">&nbsp;</td>
      <td>Request Date</td>
				<% strTemp = WI.fillTextValue("request_date");
					if (strTemp.length() == 0) 
						strTemp = WI.getTodaysDate(1); %>			
      <td colspan="3"><input name="request_date" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" 
					 onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="10" maxlength="10" readonly="true">
        <a href="javascript:show_calendar('dtr_op.request_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" border="0"></a>
					(<font size="1">Date when the overtime was requested</font>)</td>
    </tr>
    <%if(bolHasOvertime){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>OT Date</td>
			<%
				strTemp = WI.fillTextValue("ot_specific_date");
				if(strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);
			%>
      <td colspan="3">
        <input name="ot_specific_date" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" 
					 onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="10" maxlength="10" readonly="true">
        <a href="javascript:show_calendar('dtr_op.ot_specific_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
			<img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
		<%}%>
    <tr>
      <td width="3%" height="24">&nbsp;</td>
      <td width="16%">Status</td>
      <td width="81%" colspan="3"><select name="pt_ft" onChange="ReloadPage();">
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
			</label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
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
      </select></td>
    </tr>
		<%}%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10" colspan="3"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('emp_id', 'coa_info');">
      <strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></strong>
			<label id="coa_info"></label></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10" colspan="5">OPTION:</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">
			<%
				strTemp = WI.fillTextValue("with_schedule");
				strTemp = WI.getStrValue(strTemp,"1");
				if(strTemp.compareTo("1") == 0) 
					strTemp = " checked";
				else	
					strTemp = "";	
			%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
View with overtime only
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
View all Employees</td>
    </tr>
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
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ViewRecords();">View ALL </td>
    </tr>		
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td width="29%" height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=ot.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td width="29%" height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=ot.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td width="29%" height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=ot.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>

    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td width="10%" height="15">&nbsp;</td>
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
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewRecords();">
      <font size="1">click to display employee list to print.</font></td>
    </tr>
  </table>
<% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(WI.fillTextValue("with_schedule").equals("1")){%>
		<tr>
      <td height="10" colspan="3" align="right"><a href="javascript:printpage();"><img src="../../../images/print.gif" 
			width="58" 	height="26"   border="0"></a> <font style="size:9px"> click to print result</font></td>
    </tr>
		<%}%>
    <tr> 
      <td width="48%" height="10">&nbsp;</td>
      <td width="52%" colspan="2" align="right">
		<%
		if(WI.fillTextValue("view_all").length() == 0){
		int iPageCount = iSearchResult/ot.defSearchSize;
		if(iSearchResult % ot.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%>
Jump To page:
  <select name="jumpto" onChange="ViewRecords();">
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
  <%}
	}%>	</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
			<% 
				if(bolHasOvertime)
					strTemp = " WITH OT REQUEST ON " + WI.fillTextValue("ot_specific_date");
				else
					strTemp = "";			
			%>
      <td height="20" colspan="8" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES <%=strTemp%></strong></td>
    </tr>
    <tr>
      <td width="3%" height="23" class="thinborder">&nbsp;</td>
      <td width="7%" class="thinborder">&nbsp;</td> 
      <td  width="46%" align="center" class="thinborder">&nbsp;
      <% if(!bolHasOvertime){%>
				<a href="javascript:CopyOT();">Copy Details</a><br>
				<input type="checkbox" name="selAllNextDay" value="0" onClick="checkAllNextDay();">
			Next day logout
			<%}%></td>			
			<% if(bolHasOvertime){%>
			<td width="4%" align="center" class="thinborder"><font size="1"><strong>OT Type </strong></font></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>No. of Hours</strong></font></td>
			<td width="7%" align="center" class="thinborder"><font size="1"><strong>Status</strong></font></td>			
			<%}%>			
			<td width="22%" align="center" class="thinborder"><font size="1"><strong>Details of OT</strong></font><br>
			<% if(!bolHasOvertime){%>			
					<label id="loader_"><a href="javascript:CopyDetails();">Copy</a></label>
			<%}%></td>
			<% if(!bolHasOvertime){%>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
        </strong>
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">
      </font></td>
			<%}%>
    </tr>
    
    <% 	int iCount = 1;
	   for (i = 0; i < vRetResult.size(); i+=28,iCount++){
		 %>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=iCount%></td>
			<input type="hidden" name="u_index_for_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">
			<input type="hidden" name="emp_id_for_<%=iCount%>" value="<%=vRetResult.elementAt(i+4)%>">
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td> 
      <input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
      <%if((String)vRetResult.elementAt(i + 21) == null || (String)vRetResult.elementAt(i + 22)== null){
					strTemp = " ";			
				}else{
					strTemp = " - ";
				}%>							
      <td nowrap class="thinborder"><font size="2" color="#FF0000"><strong><%=WI.formatName((String)vRetResult.elementAt(i+18), (String)vRetResult.elementAt(i+19),
							(String)vRetResult.elementAt(i+20), 4).toUpperCase()%></strong></font><br>
        <%
			if(bolHasOvertime){%>			
			&nbsp;<%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
			                       (String)vRetResult.elementAt(i+8),
										   (String)vRetResult.elementAt(i+9))%> - <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+10),
			  						 (String)vRetResult.elementAt(i+11),
									 (String)vRetResult.elementAt(i+12))%>
			<%}else{%>
			<%
			if(WI.fillTextValue("copy_all").length() > 0){
				strOTDate = WI.fillTextValue("ot_date_1");
				strOTType = WI.fillTextValue("ot_type_1");
				strHrFr = WI.fillTextValue("am_hr_fr_1");
				strMinFr = WI.fillTextValue("am_min_fr_1");
				strAMPMFr = WI.fillTextValue("ampm_from_1");
				
				strHrTo = WI.fillTextValue("am_hr_to_1");
				strMinTo = WI.fillTextValue("am_min_to_1");
				strAMPMTo = WI.fillTextValue("ampm_to_1");
				
				strBreakHrFr = WI.fillTextValue("break_hr_fr_1");
				strBreakMinFr = WI.fillTextValue("break_min_fr_1");
				strBreakAMPMFr = WI.fillTextValue("break_ampm_fr_1");
				
				strBreakHrTo = WI.fillTextValue("break_hr_to_1");
				strBreakMinTo = WI.fillTextValue("break_min_to_1");
				strBreakAMPMTo = WI.fillTextValue("break_ampm_to_1");				
				
				strMaxOT = WI.fillTextValue("max_ot_hour_1");
				strIsNextDay = WI.fillTextValue("is_nextday_logout_1");
				strHasBreak = WI.fillTextValue("has_break_1");
				bolRetain = false;
			}
			
			if(WI.fillTextValue("copy_all").length() > 0 && iCount == 1){
				bolRetain = true;
			}
			
			if(WI.fillTextValue("copy_all").length() == 0){
				if(bolRetain){
					strOTDate = WI.fillTextValue("ot_date_"+iCount);
					strOTType = WI.fillTextValue("ot_type_"+iCount);
					strHrFr = WI.fillTextValue("am_hr_fr_"+iCount);
					strMinFr = WI.fillTextValue("am_min_fr_"+iCount);
					strAMPMFr = WI.fillTextValue("ampm_from_"+iCount);
					
					strHrTo = WI.fillTextValue("am_hr_to_"+iCount);
					strMinTo = WI.fillTextValue("am_min_to_"+iCount);
					strAMPMTo = WI.fillTextValue("ampm_to_"+iCount);
					
					strBreakHrFr = WI.fillTextValue("break_hr_fr_"+iCount);
					strBreakMinFr = WI.fillTextValue("break_min_fr_"+iCount);
					strBreakAMPMFr = WI.fillTextValue("break_ampm_fr_"+iCount);
					
					strBreakHrTo = WI.fillTextValue("break_hr_to_"+iCount);
					strBreakMinTo = WI.fillTextValue("break_min_to_"+iCount);
					strBreakAMPMTo = WI.fillTextValue("break_ampm_to_"+iCount);					
					
					strMaxOT = WI.fillTextValue("max_ot_hour_"+iCount);
					strIsNextDay = WI.fillTextValue("is_nextday_logout_"+iCount);
					strHasBreak = WI.fillTextValue("has_break_"+iCount);
					if(strIsNextDay.length() > 0)
						strIsNextDay = "checked";
					else
						strIsNextDay = "";
					
					if(strHasBreak.length() > 0)
						strHasBreak = "checked";
					else
						strHasBreak = "";
				}else{
					strOTDate = "";
					strOTType = "";
					strHrFr = "";
					strMinFr = "";
					strAMPMFr = "";
					
					strHrTo = "";
					strMinTo = "";
					strAMPMTo = "";

	
					if(vOTSetting != null && vOTSetting.size() > 0){
						
						strBreakHrFr = (String)vOTSetting.elementAt(3);
						strBreakMinFr = (String)vOTSetting.elementAt(4);
						strBreakAMPMFr = (String)vOTSetting.elementAt(5);
						
						strBreakHrTo = (String)vOTSetting.elementAt(6);
						strBreakMinTo = (String)vOTSetting.elementAt(7);
						strBreakAMPMTo = (String)vOTSetting.elementAt(8);
					}else{
						strBreakHrFr = "";
						strBreakMinFr = "";
						strBreakAMPMFr = "";
						
						strBreakHrTo = "";
						strBreakMinTo = "";
						strBreakAMPMTo = "";					
					}
					
					strMaxOT = "";
					strIsNextDay = "";
					strHasBreak = "";
				}
			}
			%>	
			<input name="ot_date_<%=iCount%>" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" 
					 onBlur="style.backgroundColor='white'" value="<%=strOTDate%>" size="11" maxlength="10" style="font-size:9px">
			  <a href="javascript:show_calendar('dtr_op.ot_date_<%=iCount%>');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
					<br>
			  <select name="ot_type_<%=iCount%>">
          <option value="">Auto set overtime type</option>
          <%=dbOP.loadCombo("ot_type_index","ot_name", " from pr_ot_mgmt " +
					 " where is_valid = 1 and is_for_ot = 1 ", strOTType, false, true)%>
        </select>
			  <br>
			  <input name="am_hr_fr_<%=iCount%>" type="text" size="2" maxlength="2" value="<%=strHrFr%>" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox"
					onBlur="AllowOnlyInteger('dtr_op','am_hr_fr_<%=iCount%>');style.backgroundColor='white'"
			    onKeyUp="AllowOnlyInteger('dtr_op','am_hr_fr_<%=iCount%>');" style="font-size:9px">
					: 
					<input name="am_min_fr_<%=iCount%>" type="text" size="2" maxlength="2" value="<%=strMinFr%>" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox"
					onBlur="AllowOnlyInteger('dtr_op','am_min_fr_<%=iCount%>');style.backgroundColor='white'"
			    onKeyUp="AllowOnlyInteger('dtr_op','am_min_fr_<%=iCount%>');" style="font-size:9px">
					
					<select name="ampm_from_<%=iCount%>" id="ampm_from" style="font-size:9px">
						<option value=0>AM</option>
						<% if (strAMPMFr.equals("1")) {%>
						<option value=1 selected>PM</option>
						<% }else{%>
						<option value=1>PM</option>
						<%}%>
					</select>
					to 
				<input name="am_hr_to_<%=iCount%>" type="text" size="2" maxlength="2" value="<%=strHrTo%>" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox"
					onBlur="AllowOnlyInteger('dtr_op','am_hr_to_<%=iCount%>');style.backgroundColor='white'"
			    onKeyUp="AllowOnlyInteger('dtr_op','am_hr_to_<%=iCount%>');" style="font-size:9px">
										: 
					<input name="am_min_to_<%=iCount%>" type="text" size="2" maxlength="2" value="<%=strMinTo%>" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox"
					onBlur="AllowOnlyInteger('dtr_op','am_min_to_<%=iCount%>');style.backgroundColor='white'"
			    onKeyUp="AllowOnlyInteger('dtr_op','am_min_to_<%=iCount%>');" style="font-size:9px">
					
					<select name="ampm_to_<%=iCount%>" id="ampm_to_<%=iCount%>" style="font-size:9px">
						<option value="0">AM</option>
						<% if (strAMPMTo.equals("1")) {%>
						<option value="1" selected>PM</option>
						<%}else{%>
						<option value="1">PM</option>
						<%}%>
				</select> 
          <input name="max_ot_hour_<%=iCount%>" type="text"  size="6" value="<%=strMaxOT%>"
				 onFocus="style.backgroundColor='#D3EBFF'" class="textbox"
				 onBlur="AllowOnlyFloat('dtr_op','max_ot_hour_<%=iCount%>');style.backgroundColor='white'"
				 onKeyUp="AllowOnlyFloat('dtr_op','max_ot_hour_<%=iCount%>');" style="font-size:9px" >
					
				<font size="1">Max OT</font>
				hours
				<br>
				<input type="checkbox" value="1" name="is_nextday_logout_<%=iCount%>" <%=strIsNextDay%>>
				<font size="1">Next day logout </font>
				<br>
				<input name="break_hr_fr_<%=iCount%>" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strBreakHrFr)%>" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox"
					onBlur="AllowOnlyInteger('dtr_op','break_hr_fr_<%=iCount%>');style.backgroundColor='white'"
			    onKeyUp="AllowOnlyInteger('dtr_op','break_hr_fr_<%=iCount%>');" style="font-size:9px">
:
<input name="break_min_fr_<%=iCount%>" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strBreakMinFr)%>" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox"
					onBlur="AllowOnlyInteger('dtr_op','break_min_fr_<%=iCount%>');style.backgroundColor='white'"
			    onKeyUp="AllowOnlyInteger('dtr_op','break_min_fr_<%=iCount%>');" style="font-size:9px">
<select name="break_ampm_fr_<%=iCount%>" style="font-size:9px">
	<%strBreakAMPMFr = WI.getStrValue(strBreakAMPMFr);%>
  <option value=0>AM</option>
  <% if (strBreakAMPMFr.equals("1")) {%>
  <option value=1 selected>PM</option>
  <% }else{%>
  <option value=1>PM</option>
  <%}%>
</select>
to
<input name="break_hr_to_<%=iCount%>" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strBreakHrTo)%>" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox"
					onBlur="AllowOnlyInteger('dtr_op','break_hr_to_<%=iCount%>');style.backgroundColor='white'"
			    onKeyUp="AllowOnlyInteger('dtr_op','break_hr_to_<%=iCount%>');" style="font-size:9px">
:
<input name="break_min_to_<%=iCount%>" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strBreakMinTo)%>" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox"
					onBlur="AllowOnlyInteger('dtr_op','break_min_to_<%=iCount%>');style.backgroundColor='white'"
			    onKeyUp="AllowOnlyInteger('dtr_op','break_min_to_<%=iCount%>');" style="font-size:9px">
<select name="break_ampm_to_<%=iCount%>" style="font-size:9px">
<%strBreakAMPMTo = WI.getStrValue(strBreakAMPMTo);%>
  <option value="0">AM</option>
  <% if (strBreakAMPMTo.equals("1")) {%>
  <option value="1" selected>PM</option>
  <%}else{%>
  <option value="1">PM</option>
  <%}%>
</select><input type="checkbox" value="1" name="has_break_<%=iCount%>" <%=strHasBreak%> id="has_break_<%=iCount%>" checked>
      <label for="has_break_<%=iCount%>"><font size="1">Has break </font></label>
			<%}%>			</td>
			<%if(bolHasOvertime){%>
      <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+24))%></td>
      <%			
				strTemp = (String)vRetResult.elementAt(i+5);
				strTemp = WI.getStrValue(strTemp,"&nbsp;");
			%>
		  <td align="center" class="thinborder"><%=strTemp%></td>
        <%
				strTemp = (String)vRetResult.elementAt(i+13);
				strTemp = WI.getStrValue(strTemp);
				if(strTemp.equals("1")){ 
					strTemp = "APPROVED";
				}else if (strTemp.equals("0")){
					strTemp = "DISAPPROVED";
				}else
					strTemp = "PENDING";
			%>			
			<td align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>			
			<%}%>
			<%
			strTemp = WI.fillTextValue("ot_reason_"+iCount);
			if(bolRetain)
				strTemp = WI.getStrValue(strTemp);
			else
				strTemp = "";
		%>
			<td class="thinborder">			
			<%if(bolHasOvertime){
				strTemp = (String)vRetResult.elementAt(i+23);
			%>	
			&nbsp;<%=WI.getStrValue(strTemp, "&nbsp;")%>
			<%}else{%>
			  <textarea name="ot_reason_<%=iCount%>" cols="28" rows="3" class="textbox" 
				style="font-size:9px" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
			<%}%>			</td>
			<% if(!bolHasOvertime){
			strTemp = WI.fillTextValue("save_"+iCount);
			if(strTemp.length() > 0 && bolRetain)
				strTemp = " checked";
			else
				strTemp = "";
			%>			
      <td align="center" class="thinborder">
			<input type="checkbox" name="save_<%=iCount%>" value="1" tabindex="-1" <%=strTemp%>></td>
			<%}%>
    </tr>
    <%} //end for loop%>
		 <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
	<%if(WI.fillTextValue("with_schedule").equals("0")){%>
	<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
		<%if(bolIsGovernment){%>
		<tr> 
			<td>&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("auto_approve");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else	
					strTemp = "";
			%>
		  <td>&nbsp;<input type="checkbox" value="1" name="auto_approve" <%=strTemp%> id="auto_approve_">
		    <label for="auto_approve_"><font size="1">Save and Approve</font></label></td>
	  </tr>
		<%}%>
		<tr>
			<td width="15%" align="right">Requested by</td>
			<%
				strTemp = (String)request.getSession(false).getAttribute("userId");
				
				strTemp = WI.fillTextValue("requested_by");
			%>
			<td>
			<input name="requested_by" type="text" class="textbox" 
			onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('requested_by', 'req_by');"
			value="<%=strTemp%>" size="16">
			<label id="req_by" style="position:absolute; width:400px;"></label>
			(<font size="1">Leave blank if the employee who applied  is the one who will render overtime</font>)				</td>
		</tr>
		<tr>
			<td colspan="2" align="right">&nbsp;</td>
	  </tr>
	</table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="7" align="center">
			<%if(iAccessLevel > 1){%>
      <a href='javascript:SaveRequests();'></a> <font size="1"> 
        <input type="button" name="122" value=" Save " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SaveRequests();">
        click to save entries
            </font>
        <a href="javascript:CancelRecord();"></a> <font size="1"> 
        <input type="button" name="1223" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();">
        click to cancel or go previous</font>
          <%}%>
			</td>
    </tr>   
  </table>
  <%}%>
<% } // end vRetResult != null && vRetResult.size() > 0 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td width="100%" height="25">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="reset_values">
	<input type="hidden" name="viewAll" value="">
	<input type="hidden" name="copy_all" value="">	
	<input type="hidden" name="save_requests">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>