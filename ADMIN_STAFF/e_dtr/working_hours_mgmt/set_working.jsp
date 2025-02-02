<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour"  buffer="16kb"%>
<%
//include non-employee.. added nov 11, 2014 to include NAS of CIT. 	
request.setAttribute("inc_nonemployee", "1");


	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(7);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	if(bolMyHome)
		strColorScheme = CommonUtil.getColorScheme(9);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Set working hours</title>
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
<style type="text/css">
<!--
.style1 {font-size: 14px}
.style2 {font-size: 10px}
-->
</style>
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
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function showLunchBreak(){
	if (document.dtr_op.one_tin_tout.checked){
		document.getElementById("lunch_br").innerHTML = 
		"<input name=\"lunch_break\" type=\"text\" size=\"3\" maxlength=\"3\"  "+ 
		"value=\"<%=WI.fillTextValue("lunch_break")%>\" class=\"textbox\" " +
		"onFocus=\"style.backgroundColor=\'#D3EBFF\'\" onBlur=\"style.backgroundColor=\'#FFFFFF\'\" " +
		" onKeypress=\" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;\"> Break (in Minutes)";

		document.getElementById("lbl_second_set").innerHTML = "Break Time <a href='javascript:showNote(1);'>NOTE</a>";
		
		document.dtr_op.logout_nextday.disabled = false;
//		document.dtr_op.pm_hr_fr.disabled = true;
//		document.dtr_op.pm_min_fr.disabled = true;
//		document.dtr_op.ampm_from1.disabled = true;
//		document.dtr_op.pm_hr_to.disabled = true;
//		document.dtr_op.pm_min_to.disabled = true;
//		document.dtr_op.ampm_to1.disabled = true;
	}else{
		document.getElementById("lunch_br").innerHTML = "";
		document.dtr_op.logout_nextday.disabled = true;
		document.getElementById("lbl_second_set").innerHTML = "Second Time In";
//		document.dtr_op.pm_hr_fr.disabled = false;
//		document.dtr_op.pm_min_fr.disabled = false;
//		document.dtr_op.ampm_from1.disabled = false;
//		document.dtr_op.pm_hr_to.disabled = false;
//		document.dtr_op.pm_min_to.disabled = false;
//		document.dtr_op.ampm_to1.disabled = false;
	}
}

function showFlexiBreak(){	
	if (document.dtr_op.no_break_flexi.checked){
		document.getElementById("flexi_breaktime_row").style.display = "none";
	}else{		
		document.getElementById("flexi_breaktime_row").style.display = "table-row";
	}
}

function showNote(strShow){
	var iframe = document.getElementById('iframetop');
	var layer = document.getElementById("note_");
	
	if(strShow == '0'){		
		layer.style.visibility = "hidden";
		iframe.style.display = 'none';
		layer.style.display = 'none';	
	}else{
		layer.style.visibility = "visible";
		iframe.style.display = 'block';
		layer.style.display = 'block';	
		iframe.style.width = layer.offsetWidth-5;	
		iframe.style.left = layer.offsetLeft;
		iframe.style.top = layer.offsetTop;
		iframe.style.height = (layer.offsetHeight-5);
	}
}

function ChangeWorkingHrType(isRegularHr)
{
	if(isRegularHr ==1)
	{
		if (!document.dtr_op.regular_wh.checked){
			document.dtr_op.regular_wh.checked = true
			return;
		}
			
		document.dtr_op.regular_wh.checked = true;
		document.dtr_op.specify_wh.checked = false;
		document.dtr_op.is_flex.checked = false;
		document.dtr_op.is_nonDTR.checked = false;
		document.dtr_op.iStatus.value=1;
	}
	else if  (isRegularHr==0)
	{
		if (!document.dtr_op.specify_wh.checked){
			document.dtr_op.specify_wh.checked = true;
			return;
		}
	
		document.dtr_op.regular_wh.checked = false;
		document.dtr_op.specify_wh.checked = true;
		document.dtr_op.is_flex.checked = false;
		document.dtr_op.is_nonDTR.checked = false;
		document.dtr_op.iStatus.value = 2;
		
	}else if (isRegularHr==2){
		if (!document.dtr_op.is_flex.checked){
			document.dtr_op.is_flex.checked = true;
			return;
		}
 		document.dtr_op.regular_wh.checked = false;
		document.dtr_op.specify_wh.checked = false;
		document.dtr_op.is_flex.checked = true;
		document.dtr_op.is_nonDTR.checked = false;
		document.dtr_op.iStatus.value = 3;
	}else if (isRegularHr == 3){
	
		if (!document.dtr_op.is_nonDTR.checked){
			document.dtr_op.is_nonDTR.checked = true;
			return;
		}
	
		document.dtr_op.regular_wh.checked = false;
		document.dtr_op.specify_wh.checked = false;
		document.dtr_op.is_flex.checked = false;
		document.dtr_op.is_nonDTR.checked = true;
		document.dtr_op.iStatus.value = 4;
	}
	this.SubmitOnce('dtr_op');
}

function ViewRecord(){	
	document.dtr_op.page_action.value="1";
 	this.SubmitOnce("dtr_op");
}

function AddRecord(){
	document.dtr_op.page_action.value = 2;
}

function DeleteRecord(index){
	document.dtr_op.page_action.value = 3;
	document.dtr_op.info_index.value = index;
}

function PrepareToEdit(index){
	document.dtr_op.page_action.value = 4;
	document.dtr_op.prepareToEdit.value = 1;
}
function EditRecord(index){
	document.dtr_op.page_action.value = 5;
}
function CancelEdit()
{
	location = "./set_dtr_regular_wh.jsp";
}
function DeleteNonEDTR(strEmpIndex) {
	document.dtr_op.non_EDTR.value = strEmpIndex;
	document.dtr_op.info_index.value = "";
	document.dtr_op.page_action.value = "";
	document.dtr_op.prepareToEdit.value = "";
	
	this.SubmitOnce('dtr_op');
}
function ReloadPage() {
this.SubmitOnce('dtr_op');
}
function viewHistory() {
//	var pgLoc = "./set_working_history.jsp?emp_id=";	
//	if (document.dtr_op.emp_id) 
//		pgLoc +=  escape(document.dtr_op.emp_id.value);	
//	pgLoc+="&my_home="+document.dtr_op.my_home.value;

	var pgLoc = "./set_working_history.jsp?&my_home="+document.dtr_op.my_home.value;
	if (document.dtr_op.emp_id)
		pgLoc += "&emp_id="+escape(document.dtr_op.emp_id.value);
	var win=window.open(pgLoc,"view_history",'dependent=yes, width=700, height=500, top=10, left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewCloseDialog(strWHIndex, strEmpID) {
	var pgLoc = "./close_schedule.jsp?opner_info=dtr_op.emp_id&wh_index="+strWHIndex+"&emp_id="+strEmpID;
	var win=window.open(pgLoc,"CloseDialog",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ShowUpdate(strWHIndex, strEmpID) {
	var pgLoc = "./update_working.jsp?wh_index="+strWHIndex+"&emp_id="+strEmpID;
	var win=window.open(pgLoc,"UpdateWhour",'width=650,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.emp_id.value;
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
	document.dtr_op.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
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

function FocusArea() {
	var pageNo = <%=WI.getStrValue(WI.fillTextValue("focus_area"),"1")%>
	eval('document.dtr_op.area'+pageNo+'.focus()');
}
</script>
<body bgcolor="#D2AE72" 
<% if (!WI.fillTextValue("my_home").equals("1")){%>
	onLoad="document.dtr_op.emp_id.focus();"
<%}%> class="bgDynamic">
<%
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strPrepareToEdit = null;
	boolean bolAllowEdit = false;
	String strUserID = (String)request.getSession(false).getAttribute("userId");
	
	boolean bolViewOnly = WI.fillTextValue("view_only").equals("1");
	if(bolViewOnly)
		bolMyHome = true;
//add security here.
	try
	{
		dbOP = new DBOperation(strUserID,
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","set_working.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();								
		bolAllowEdit = readPropFile.getImageFileExtn("ALLOW_EDIT_DTR","0").equals("1");
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

boolean bolIsRestricted = false;//if restricted, can only use the emplyee from same college/dept only.
if(request.getSession(false).getAttribute("wh_restricted") != null)
	bolIsRestricted = true;


CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;
if(!bolIsRestricted) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"set_working.jsp");	
}													
														
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		iAccessLevel  = 1;
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//																					
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

//if employee ID is entered and if restrcited , i have to check if user is allowed to view the employees Information.
if(bolIsRestricted && WI.fillTextValue("emp_id").length() > 0) {
	if(!comUtil.isLoggedInUserBelongToCollegeOfEmployee(dbOP, request, null,WI.fillTextValue("emp_id"), null, null)) {
		dbOP.cleanUP();
		request.getSession(false).setAttribute("encoding_in_progress_id",null);
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=comUtil.getErrMsg()%></font></p>
		<%
		return;
	}	
}




	//end of authenticaion code.
	WorkingHour whPersonal = new WorkingHour(); 
	Vector vRetResult = null;
	Vector vEmployeeWH = null;
	String[] astrConvertWeekDay= {"SUNDAY","MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};	
	String[] astrConverAMPM = {"AM","PM"};
	boolean bolAllowDelete = true;
	String strDateTo = null;
	
	double dTime = 0d;
	int iHour = 0;
	int iMinute = 0;	
	String strAMPM = " AM";
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode.startsWith("CIT") || (strUserID != null && strUserID.equals("bricks"))
		|| strSchCode.startsWith("TAMIYA") || strSchCode.startsWith("CLC") || strSchCode.startsWith("ICAAC"))
		bolAllowEdit = true;

whPersonal.computeReqHours(dbOP);
String strEmpID = WI.fillTextValue("emp_id");
if(strEmpID.length() == 0)
	strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
strEmpID = WI.getStrValue(strEmpID);

if (WI.fillTextValue("emp_id").length() == 0 && strEmpID.length() > 0){
	request.setAttribute("emp_id",strEmpID);
}

	if(WI.fillTextValue("page_action").equals("1")){
		vRetResult = whPersonal.operateOnEmployeeWH(dbOP, request,1);
		strErrMsg = whPersonal.getErrMsg();
	}else if(WI.fillTextValue("page_action").equals("2")){
		vRetResult = whPersonal.operateOnEmployeeWH(dbOP, request,2);
		strErrMsg = whPersonal.getErrMsg();
		if (strErrMsg == null)  
			strErrMsg = "Working Hour added successfully." ;
	}else if(WI.fillTextValue("page_action").equals("3")){
		vRetResult = whPersonal.operateOnEmployeeWH(dbOP,request,3);
		strErrMsg = whPersonal.getErrMsg();
		if (strErrMsg == null)  strErrMsg = "Working Hour deleted successfully ." ;
	}
	if(WI.fillTextValue("non_EDTR").length() > 0) {
		if(whPersonal.removeNonEDTRWH(dbOP, WI.fillTextValue("non_EDTR"), 
				(String)request.getSession(false).getAttribute("login_log_index")))
			strErrMsg = "Working hour information removed successfully.";
		else	
			whPersonal.getErrMsg();
	}
	
	if(WI.fillTextValue("view_all_wh").length() > 0)
		vEmployeeWH = whPersonal.getEmployeeWorkingHours(dbOP, request, true, true);
	else
		vEmployeeWH = whPersonal.getEmployeeWorkingHours(dbOP, request, false, true);


System.out.println(strErrMsg);
%>	
<form action="./set_working.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      EMPLOYEE WORKING HOUR PAGE ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25"><strong><font size="2" >&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<% if (!bolMyHome) {%>
    <tr valign="top"> 
      <td width="2%" height="30" valign="top">&nbsp;</td>
      <td width="14%" height="30">Employee ID</td>
      <td width="19%" height="30" valign="top"><input name="emp_id" type="text" class="textbox" 
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AjaxMapName(1);" value="<%=strEmpID%>" size="16">
			</td>
      <td width="5%" valign="top"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="14%" valign="top"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewRecord();"></td>
      <td width="46%" valign="top"><label id="coa_info"></label></td>
    </tr>
<%}else{%>
		<input name="emp_id" type="hidden" value="<%=strTemp%>" size="16">
    <tr>
      <td colspan="6" height="25">&nbsp;Employee ID :<strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
      </td>
    </tr>
<%}%>	
  </table>
<% 

if (strTemp.length()  > 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
  vRetResult = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vRetResult !=null){
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="15">&nbsp;</td>
      <td height="15" colspan="2"><font size="1">Employee Name</font></td>
      <td height="15"><font size="1">Employee Status</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <% strTemp = WI.formatName((String)vRetResult.elementAt(1), (String)vRetResult.elementAt(2),
									(String)vRetResult.elementAt(3),1); %>
      <td colspan="2" valign="top"><strong><%=strTemp%></strong></td>
      <td valign="top"><strong><%=WI.getStrValue((String)vRetResult.elementAt(16))%></strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td colspan="2"><font size="1">Position</font></td>
      <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <% strTemp = (String)vRetResult.elementAt(15);%>
      <td colspan="2" valign="top"><strong><%=WI.getStrValue(strTemp)%></strong></td>
      <%
				if((String)vRetResult.elementAt(13) == null)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(14));
			else
			{	
				strTemp =WI.getStrValue((String)vRetResult.elementAt(13));
				if((String)vRetResult.elementAt(14) != null)
					strTemp += "/" + WI.getStrValue((String)vRetResult.elementAt(14));
			}
%>
      <td valign="top"><strong><%=WI.getStrValue(strTemp)%></strong></td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
<% if (!bolMyHome) {%> 
    <tr> 
      <td height="25">&nbsp;</td>
      <td><u>Working Hours</u></td>
      <td width="23%">&nbsp;</td>
      <td width="56%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"> 
<% if(WI.fillTextValue("regular_wh").compareTo("1") == 0) strTemp = "checked";
else strTemp = "";%> 
<input type="checkbox" name="regular_wh" value="1" onClick="ChangeWorkingHrType(1);" <%=strTemp%>> Regular working hours &nbsp;&nbsp;&nbsp;&nbsp; 

<% if(WI.fillTextValue("specify_wh").compareTo("1") == 0) strTemp = "checked";
else strTemp = "";%> 
<input type="checkbox" name="specify_wh" value="1" onClick="ChangeWorkingHrType(0);" <%=strTemp%>> Specify working hour &nbsp;&nbsp;&nbsp; 

<% if(WI.fillTextValue("is_flex").compareTo("1") == 0) 	strTemp = "checked";
else strTemp = "";%> 
<input type="checkbox" name="is_flex" value="1" onClick="ChangeWorkingHrType(2);" <%=strTemp%>> Flexible Working Hours 

<% if(WI.fillTextValue("is_nonDTR").compareTo("1") == 0) strTemp = "checked";
else  strTemp = ""; %> 
<input name="is_nonDTR" type="checkbox"  onClick="ChangeWorkingHrType(3);" value="1" <%=strTemp%>> Non DTR Employee</td>
    </tr>
    <%if(WI.fillTextValue("regular_wh").compareTo("1") ==0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3"><span class="thinborder">
        Schedule name :        
        <select name="sched_index" onChange="ReloadPage();">
          <%
						strTemp= WI.fillTextValue("sched_index");
					%>
          <option value="">Select schedule name</option>
          <%=dbOP.loadCombo("SCHED_INDEX","SCHED_NAME", " from edtr_wh_schedule order by SCHED_NAME",strTemp,false)%>
        </select>
      </span></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"> 
 <%	vRetResult = whPersonal.getDefaultWHIndex(dbOP,null, false, WI.fillTextValue("sched_index")); 
 	if (vRetResult == null || vRetResult.size() == 0) { %>
	 <div align="center"><font size="3"><strong>No Record of Default working 
          hours</strong></font></div> 
 <%}else{%>
 <br>
 
	  <table width="65%" border="0" cellpadding="1" cellspacing="0" class="thinborder">
       
       <tr>
<%	for(int i = 0; i < vRetResult.size(); i+=6){ 
	strTemp = (String)vRetResult.elementAt(i);
	if (strTemp == null) 
		strTemp = "N/A Week Day";
	else  
		strTemp = astrConvertWeekDay[Integer.parseInt(strTemp)];
		
	strTemp2 = ((String)vRetResult.elementAt(i+1)) + " - " + ((String)vRetResult.elementAt(i+2));
  if ((String)vRetResult.elementAt(i+3) != null) 
		strTemp2 +=  " / " + (String)vRetResult.elementAt(i+3) + " - "  + (String)vRetResult.elementAt(i+4);			
	%>
            <td width="34%" height="23" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
            <td width="66%" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp2)%></td>
          </tr>
          <%}%>
        </table>
			<br>		
			<%}%>			</td>
    </tr>
    <%}else if(WI.fillTextValue("specify_wh").equals("1")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="19%">Days</td>
      <td colspan="2"><input name="work_day" type="text" class="textbox"
	   OnKeyUP="javascript:this.value=this.value.toUpperCase();" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("work_day")%>"> 
        <font size="1">(M-T-W-TH-F-SAT-S) &nbsp;&nbsp;&nbsp;&nbsp; 
        <!-- for now it is not allowed to have irregular weekday.
		<input name="noWeekDay" type="checkbox" id="noWeekDay" value="1" >
        tick if weekday is irregular-->
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>First Time In</td>
      <td colspan="2"><input name="am_hr_fr" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_hr_fr")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" >
        : 
        <input name="am_min_fr" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_min_fr")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="ampm_from0">
          <option value="0" >AM</option>
          <% if (WI.fillTextValue("ampm_from0").equals("1")) {%>
          <option value="1" selected>PM</option>
          <% }else {%>
          <option value="1">PM</option>
          <%}%>
        </select>
        to 
        <input name="am_hr_to" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_hr_to")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input name="am_min_to" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_min_to")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="ampm_to0" >
          <option value="0" >AM</option>
          <% if (WI.fillTextValue("ampm_to0").equals("1")){ %>
          <option value="1" selected>PM</option>
          <% }else{ %>
          <option value="1">PM</option>
          <%}%>
        </select>&nbsp;&nbsp;&nbsp; 
				<%
			strTemp = WI.fillTextValue("one_tin_tout");
			if(strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = "";
			%>	
				<label for="one_chk_opt_">
				<input name="one_tin_tout" type="checkbox"  value="1"  id="one_chk_opt_"
				onClick="showLunchBreak()" tabindex="-1" <%=strTemp%>> 
        <font size="1">employee has only one time in/time out </font> 
				</label>
				</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><label id="lbl_second_set">Second Time In</label>
			<iframe width="0" scrolling="no" height="0" frameborder="0" id="iframetop" style="position:absolute;"> </iframe>
			<div id="note_" style="position:absolute;visibility:hidden; width:500px;">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFCC">
				<tr>
					<td width="90%">If you enter valid break time range, then the Break (in Minutes) will be disregarded</td>
					<td width="10%" align="center"><a href="javascript:showNote('0');">HIDE</a></td>
				</tr>
			</table>
			</div>			
			</td>
      <td colspan="2"><input name="pm_hr_fr" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("pm_hr_fr")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input name="pm_min_fr" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("pm_min_fr")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="ampm_from1" >
          <option value="0">AM</option>
          <%if(WI.fillTextValue("ampm_from1").equals("1")) {%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select>
        to 
        <input name="pm_hr_to" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("pm_hr_to")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input name="pm_min_to" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("pm_min_to")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="ampm_to1" >
          <option value="0" >AM</option>
          <% if (WI.fillTextValue("ampm_to1").equals("1")) {%>
          <option value="1" selected>PM</option>
          <% }else{ %>
          <option value="1">PM</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp; 
		<label id="lunch_br"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">
        <input name="logout_nextday" type="checkbox" id="logout_nextday" value="1" disabled>
       <font size="1">employee logout is on the next day</font></td>
    </tr>
		<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><span class="branch" id="branch2">
			<input name="break_hr_fr" type="text" size="2" maxlength="2" value="<%//=WI.fillTextValue("break_hr_fr")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
      : 
      <input name="break_min_fr" type="text" size="2" maxlength="2" value="<%//=WI.fillTextValue("break_min_fr")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
			<select name="break_ampm_fr" >
				<option value="0">AM</option>
				<%//if(WI.fillTextValue("break_ampm_fr").equals("1")) {%>
				<option value="1" selected>PM</option>
				<%//}else{%>
				<option value="1">PM</option>
				<%//}%>
			</select>
			to 
      <input name="break_hr_to" type="text" size="2" maxlength="2" value="<%//=WI.fillTextValue("break_hr_to")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
      <input name="break_min_to" type="text" size="2" maxlength="2" value="<%//=WI.fillTextValue("break_min_to")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
			<select name="break_ampm_to" >
				<option value="0" >AM</option>
				<%// if (WI.fillTextValue("break_ampm_to").equals("1")) {%>
				<option value="1" selected>PM</option>
				<%// }else{ %>
				<option value="1">PM</option>
				<%//}%>
			</select>
			</span></td>
    </tr>
		-->
    <%}if(WI.fillTextValue("is_flex").equals("1")){%>
    <tr>
      <td>&nbsp;</td>
      <td>Valid time in </td>
      <td colspan="2"><input name="am_hr_fr_flex" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_hr_fr_flex")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" >
:
  <input name="am_min_fr_flex" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_min_fr_flex")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
  <select name="ampm_from0_flex">
    <option value="0" >AM</option>
    <% if (WI.fillTextValue("ampm_from0_flex").equals("1")) {%>
    <option value="1" selected>PM</option>
    <% }else {%>
    <option value="1">PM</option>
    <%}%>
  </select>
to
<input name="am_hr_to_flex" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_hr_to_flex")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
:
<input name="am_min_to_flex" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_min_to_flex")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
<select name="ampm_to0_flex" >
  <option value="0" >AM</option>
  <% if (WI.fillTextValue("ampm_to0_flex").equals("1")){ %>
  <option value="1" selected>PM</option>
  <% }else{ %>
  <option value="1">PM</option>
  <%}%>
</select>
	&nbsp;&nbsp;&nbsp; 
				<%
			strTemp = WI.fillTextValue("no_break_flexi");
			if(strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = "";
			%>	
				<label for="one_chk_opt_">
				<input name="no_break_flexi" type="checkbox"  value="1"  
				onClick="showFlexiBreak()" tabindex="-1" <%=strTemp%>> 
        <font size="1">employee has no break time </font> 
				</label>

</td>
    </tr>
	<!-- start of addition for flexi break time -->	
		<%
			strTemp = WI.fillTextValue("no_break_flexi");
			if(strTemp.equals("1"))
				strTemp = "display:none";
			else
				strTemp = "display:table-row";
		%>	
	
		<tr style="<%=strTemp%>" id="flexi_breaktime_row">		
		  <td>&nbsp;</td>
		  <td>Fixed lunch break </td>
		  <td colspan="2">
		  	<input name="am_hr_fr_flex_br" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_hr_fr_flex_br")%>" class="textbox" 
		  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" >
			:
		 	<input name="am_min_fr_flex_br" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_min_fr_flex_br")%>" class="textbox" 
			  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
		  	
			<select name="ampm_from0_flex_br">
				<option value="0" >AM</option>
				<% if (WI.fillTextValue("ampm_from0_flex_br").equals("1")) {%>
					<option value="1" selected>PM</option>
				<% }else {%>
					<option value="1">PM</option>
				<%}%>
		 	</select>
			to
			<input name="am_hr_to_flex_br" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_hr_to_flex_br")%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
			:
			<input name="am_min_to_flex_br" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_min_to_flex_br")%>" class="textbox" 
		  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
			<select name="ampm_to0_flex_br" >
	  			<option value="0" >AM</option>
				<% if (WI.fillTextValue("ampm_to0_flex_br").equals("1")){ %>
					<option value="1" selected>PM</option>
				<% }else{ %>
					 <option value="1">PM</option>
				<%}%>
			</select>			
		</td>		
	</tr>	
	<!-- end of flexi break time -->
    <tr> 
      <td>&nbsp;</td>
      <td>Days :</td>
      <td colspan="2"><input type="text" name="work_day" value="<%=WI.fillTextValue("work_day")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" OnKeyUP="javascript:this.value=this.value.toUpperCase();"> 
        <font size="1">(M-T-W-TH-F-SAT-S) <!-- for now it is not allowed to have irregular week day.
		<input name="noWeekDay2" type="checkbox" id="noWeekDay2" value="1" >
        tick if weekday is irregular
	   --></font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Number of Hours : </td>
      <td colspan="2"><input name="flex_hour" type="text" class="textbox" onKeyUp="AllowOnlyFloat('dtr_op','flex_hour');"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("flex_hour")%>" size="4" maxlength="4"></td>
    </tr>
    <%}else if(WI.fillTextValue("is_nonDTR").equals("1")){ %>
    <tr> 
      <td>&nbsp;</td>
      <td height=30 colspan=3 align="center" class="thinborderALL"><p><strong> <font color="#993333"><span class="style1"><br>
        Employee will not be required to time in and time out.</span><br>
        <br>
      </font></strong></p>      </td>
    </tr>
    <%} 
			if ((iAccessLevel > 1) && ((WI.fillTextValue("is_flex").equals("1"))    
				|| (WI.fillTextValue("regular_wh").equals("1")) 
				|| (WI.fillTextValue("specify_wh").equals("1")) 
				|| (WI.fillTextValue("is_nonDTR").equals("1")
				))){%>	
		<%if(!WI.fillTextValue("is_nonDTR").equals("1")){%>
    <tr>
      <td>&nbsp;</td>
      <td height=20>&nbsp;</td>
      <td height=20>&nbsp;</td>
      <td height=20>&nbsp;</td>
    </tr>
		
    <tr>
      <td>&nbsp;</td>
      <td height=20 colspan="3">&nbsp;
        <input type="checkbox" name="force_close" value="1">
        <span class="style2">check to close previous active working hours </span></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height=30>Effective Date From: </td>
      <td height=30><input name="date_from" type="text" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" 
	   onBlur="style.backgroundColor='white'; AllowOnlyIntegerExtn('dtr_op','date_from','/');"
	   onKeyUp= "AllowOnlyIntegerExtn('dtr_op','date_from','/')"
	    value="<%=WI.fillTextValue("date_from")%>" size="10" maxlength="10">
      <a href="javascript:show_calendar('dtr_op.date_from');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td height=30>Effective Date To: 
        <input name="date_to" type="text" class="textbox"  
		onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','date_to','/');"
		onKeyUP= "AllowOnlyIntegerExtn('dtr_op','date_to','/')"
		value="<%=WI.fillTextValue("date_to")%>" size="10" maxlength="10"> 
        <a href="javascript:show_calendar('dtr_op.date_to');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        <font size="1">(leave blank if still applicable)</font></td>
    </tr>
		<%}%>
    <tr>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><div align="center">
          <input name="image" type="image" onClick="AddRecord();" src="../../../images/save.gif" width="48" height="28">
          <font size="1">click to save changes</font></div></td>
    </tr>
<%}
 } // do not show if my home
%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr bgcolor="#B9B292"> 
        <td height="25" colspan="9" align="center" bgcolor="#B9B292">LIST OF 
          CURRENT WORKING HOURS FOR ID : <%=WI.fillTextValue("emp_id")%>
					<%if(!bolViewOnly){%>
					(<input name="show_history" type="checkbox" value="1" onClick="javascript:viewHistory()">
					click to see history)
					<%}%>
				<%if(bolAllowEdit){
					strTemp = WI.fillTextValue("view_all_wh");
					if(strTemp.equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<br>
					<div align="left">
					<input name="view_all_wh" type="checkbox" value="1" <%=strTemp%> onClick="ViewRecord();">
					View all working hours
					</div>
				<%}%>
			</td>
      </tr>
    <tr> 
      <td height="25" colspan="9"><table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
<% if (vEmployeeWH == null) {  %>
          <tr> 
            <td height="25" colspan=6 align="center" class="thinborder"><font size=2><strong> 
              No Record of Employee Working Hours</strong></font></td>
          </tr>
<% } // end if ( vRetResult == null)
    else{ // else if (vRetResult == null)%>
          <tr> 
            <td width="22%" class="thinborder"><strong>&nbsp;EFFECTIVE DATES</strong> </td>
            <td width="13%" height="25" align="center" class="thinborder">
						<strong>WEEK DAY</strong></td>
            <td width="40%" align="center" class="thinborder"><strong>TIME / HOURS</strong></td>
            <% if (!bolMyHome) {%>
						<td width="5%" align="center" class="thinborder"><strong>CLOSE</strong></td>
						<%}%>
            <td width="12%" align="center" class="thinborder"><strong>  BREAK </strong></td>
						<%if (!bolMyHome){%> 
            <td width="8%" align="center" class="thinborder"><strong> OPTION </strong></td>			
		        <%}%> 
          </tr>
<% if(vEmployeeWH.size() == 2 && 
		((String)vEmployeeWH.elementAt(0)).equals("-1")){
		  vEmployeeWH.removeElementAt(0);//do not enter in next loop. %>
          <tr> 
            <td width="20%" height="22" class="thinborder">&nbsp;</td>
            <td colspan="4" align="center" class="thinborder"><strong>NON-EDTR EMPLOYEE</strong></td>
		<% if (!bolMyHome) {%> 
            <td width="8%" class="thinborder">&nbsp; 
              <% if(iAccessLevel ==2){%>
              <a href='javascript:DeleteNonEDTR("<%=(String)vEmployeeWH.remove(0)%>")'> 
              <img src="../../../images/delete.gif" border="0"> </a> 
              <%} //end if (iAccessLevel == 2) %>            </td>
		<%}%> 
          </tr>
<% } else {//end if (vRetResult.size() == 2 && ((String)vRetResult.elementAt(0)).compareTo("-1") == 0)
		  for (int i = 0; i < vEmployeeWH.size(); i+=42){%>          
<%		strTemp = (String)vEmployeeWH.elementAt(i+14);	
		if(strTemp.equals("1")){// flexi%>	
		<tr> 	
<%	strTemp2 =(String)vEmployeeWH.elementAt(i+1);
		
		if (strTemp2 == null) strTemp2 = "N/A Weekday";
		else strTemp2 = astrConvertWeekDay[Integer.parseInt(strTemp2)];
		strTemp = (String)vEmployeeWH.elementAt(i+15);
		
%>
            <td height="22" bgcolor="#FFFFFF"  class="thinborder">&nbsp;
				<%=WI.getStrValue((String)vEmployeeWH.elementAt(i+33),"**") + 
					WI.getStrValue((String)vEmployeeWH.elementAt(i+34)," - ",""," - present")%></td>
            <td bgcolor="#FFFFFF" class="thinborder">&nbsp;<%=strTemp2%></td>
					<%
						strTemp2 = (String)vEmployeeWH.elementAt(i+2) +  ":"  + 
							CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+3)) +
							" " +(String)vEmployeeWH.elementAt(i+4) + " - " + (String)vEmployeeWH.elementAt(i+5) +  
							":"  + 	CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+6)) + " " + 
							(String)vEmployeeWH.elementAt(i+7);
					%>
            <td bgcolor="#FFFFFF" class="thinborder"><strong>&nbsp;<%=strTemp2%> <%=WI.getStrValue(strTemp,"("," hours flex time)","")%></strong></td>
            <% if (!bolMyHome) {%>
						<td bgcolor="#FFFFFF"  class="thinborder">&nbsp;
						<%if(iAccessLevel > 1){%>
						<strong><a href="javascript:viewCloseDialog('<%=vEmployeeWH.elementAt(i+31)%>','<%=strEmpID%>')">CLOSE</a></strong>
						<%}%>&nbsp;</td>
						<%}%>
            <td bgcolor="#FFFFFF"  class="thinborder">				
					<%
						strTemp = (String)vEmployeeWH.elementAt(i+37);
						strTemp2 = (String)vEmployeeWH.elementAt(i+38);
						if(strTemp != null && strTemp2 != null){
							dTime = Double.parseDouble(strTemp);
							if(dTime >= 12){
								strAMPM = " PM";
								if(dTime > 12)
									dTime = dTime - 12;
							}else{
								strAMPM = " AM";
							}
							
							iHour = (int)dTime;
							dTime = (dTime - iHour) * 60 + .02;
							iMinute = (int)dTime;
							if(iHour == 0)
								iHour = 12;
							
							strTemp = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;
							
							dTime = Double.parseDouble(strTemp2);
							if(dTime >= 12){
								strAMPM = " PM";
								if(dTime > 12)
									dTime = dTime - 12;
							} else {
								strAMPM = " AM";
							}
							
							iHour = (int)dTime;
							dTime = ((dTime - iHour) * 60) + .02;
 							iMinute = (int)dTime;
							if(iHour == 0)
								iHour = 12;
							
							strTemp2 = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;
							
							strTemp += " - <br>" + strTemp2;
						}else{
							strTemp = (String)vEmployeeWH.elementAt(i+35);
 							if(Double.parseDouble(WI.getStrValue(strTemp,"0")) == 0)
								strTemp = "";
						}
						%>
           			&nbsp;<%=WI.getStrValue(strTemp)%>	
			</td>
		        <% if (!bolMyHome) {%>
         <td bgcolor="#FFFFFF"  class="thinborder">&nbsp;
						<%if(iAccessLevel > 1 && bolAllowEdit) {%>
						<a href='javascript:ShowUpdate("<%=vEmployeeWH.elementAt(i+31)%>", "<%=WI.fillTextValue("emp_id")%>");'><strong>EDIT</strong></a>
						<%}else{%>
						&nbsp;
						<%}%>				 
           <%if(iAccessLevel ==2){%>
           <input type="image" src="../../../images/delete.gif" width="55" height="28" 
		  			border="0" onClick='DeleteRecord("<%=(String)vEmployeeWH.elementAt(i+31)%>")'>
           <%} // end iAccessLevel == 2%>         </td>
		 <%}%> 
          </tr>
    <%}else { // else  %>
          
   <% strTemp = (String)vEmployeeWH.elementAt(i);
 	 if (strTemp != null){// use default %>
			 <tr> 
		<% strTemp = astrConvertWeekDay[Integer.parseInt((String)vEmployeeWH.elementAt(i+18))]; %>
          <td height="22"  class="thinborder">&nbsp;
		  		<%=WI.getStrValue((String)vEmployeeWH.elementAt(i+33),"**") + 
					WI.getStrValue((String)vEmployeeWH.elementAt(i+34)," - ",""," - present")%></td>
          <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		      <% 	strTemp = (String)vEmployeeWH.elementAt(i+19) +  ":"  + 
					CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+20)) + " " +
					(String)vEmployeeWH.elementAt(i+21) + " - " + (String)vEmployeeWH.elementAt(i+22)  +
					":"  + CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+23))  + " " + 
					(String)vEmployeeWH.elementAt(i+24);
					
					if ((String)vEmployeeWH.elementAt(i+25) != null)
					strTemp += " / " + (String)vEmployeeWH.elementAt(i+25) +  ":" + 
					CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+26)) +
					" " + (String)vEmployeeWH.elementAt(i+27) + " - " + 
					(String)vEmployeeWH.elementAt(i+28) + ":"  + 
					CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+29)) +  " " + 
					(String)vEmployeeWH.elementAt(i+30);
							 
				if (((String)vEmployeeWH.elementAt(i+32)).equals("1"))
					strTemp +="(next day)";
				%>
            <td class="thinborder"><strong>&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
						<%if(!bolMyHome) {%>
						<td class="thinborder">&nbsp;
						<%if(iAccessLevel > 1){%>
						<strong><a href="javascript:viewCloseDialog('<%=vEmployeeWH.elementAt(i+31)%>','<%=strEmpID%>')">CLOSE</a></strong>
						<%}%>&nbsp;</td>
						<%}%>
						<%
						strTemp = (String)vEmployeeWH.elementAt(i+37);
						strTemp2 = (String)vEmployeeWH.elementAt(i+38);
						if(strTemp != null && strTemp2 != null){
							dTime = Double.parseDouble(strTemp);
							if(dTime >= 12){
								strAMPM = " PM";
								if(dTime > 12)
									dTime = dTime - 12;
							}else{
								strAMPM = " AM";
							}
							
							iHour = (int)dTime;
							dTime = (dTime - iHour) * 60 + .02;
							iMinute = (int)dTime;
							if(iHour == 0)
								iHour = 12;
							
							strTemp = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;
							
							dTime = Double.parseDouble(strTemp2);
							if(dTime >= 12){
								strAMPM = " PM";
								if(dTime > 12)
									dTime = dTime - 12;
							} else {
								strAMPM = " AM";
							}
							
							iHour = (int)dTime;
							dTime = ((dTime - iHour) * 60) + .02;
 							iMinute = (int)dTime;
							if(iHour == 0)
								iHour = 12;
							
							strTemp2 = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;
							
							strTemp += " - <br>" + strTemp2;
						}else{
							strTemp = (String)vEmployeeWH.elementAt(i+35);
 							if(Double.parseDouble(WI.getStrValue(strTemp,"0")) == 0)
								strTemp = "";
						}
						%>
            <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		        <% if (!bolMyHome) {%> 
            <td class="thinborder">&nbsp; 
							<%if(iAccessLevel > 1 && bolAllowEdit) {%>
							<a href='javascript:ShowUpdate("<%=vEmployeeWH.elementAt(i+31)%>", "<%=WI.fillTextValue("emp_id")%>");'><strong>EDIT</strong></a>
							<%}else{%>
							&nbsp;
							<%}%>									
              <% 	if(iAccessLevel == 2){%>
              <input type="image" src="../../../images/delete.gif" width="55" height="28" 
			  					onClick='DeleteRecord("<%=vEmployeeWH.elementAt(i+31)%>")'>
              <%} //end iAccessLevel ==2%></td>
		        <%}%> 
          </tr>
          <% }else{
		strTemp = (String)vEmployeeWH.elementAt(i+33);
 		if(strTemp != null && strTemp.length() > 0){
		
		strTemp = (String)vEmployeeWH.elementAt(i+1);		
		if (strTemp == null)
			strTemp = "N/A Weekday";
		else
			strTemp = astrConvertWeekDay[Integer.parseInt(strTemp)];

		strTemp2 = (String)vEmployeeWH.elementAt(i+2) +  ":"  + 
			CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+3)) +
			" " +(String)vEmployeeWH.elementAt(i+4) + " - " + (String)vEmployeeWH.elementAt(i+5) +  
			":"  + 	CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+6)) + " " + 
			(String)vEmployeeWH.elementAt(i+7);
		
		if ((String)vEmployeeWH.elementAt(i+8) != null){
		strTemp2 += " / " + (String)vEmployeeWH.elementAt(i+8) + ":"  + 
			CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+9)) + " " + 
			(String)vEmployeeWH.elementAt(i+10) +  " - " + (String)vEmployeeWH.elementAt(i+11) + 
			":"  + CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+12)) +  " " + 
			(String)vEmployeeWH.elementAt(i+13);			
		}
 		if (((String)vEmployeeWH.elementAt(i+32)).equals("1"))
			strTemp2 +=" (next day)";
			
		strDateTo = (String)vEmployeeWH.elementAt(i+34);
		bolAllowDelete = true;
		if(strDateTo == null || strDateTo.length() == 0)
			bolAllowDelete = false;
		%>          
					<tr> 
            <td height="22" class="thinborder">&nbsp;<%=WI.getStrValue((String)vEmployeeWH.elementAt(i+33),"**") + WI.getStrValue(strDateTo," - ",""," - present")%></td>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
            <td class="thinborder"><strong>&nbsp;<%=WI.getStrValue(strTemp2,"")%></strong></td>
						<% if (!bolMyHome) {%>
						<td class="thinborder">&nbsp;
						<%if(iAccessLevel > 1){%>
						<strong><a href="javascript:viewCloseDialog('<%=vEmployeeWH.elementAt(i+31)%>','<%=strEmpID%>')">CLOSE</a></strong>
						<%}%>
						&nbsp;</td>
						<%}%>
						<%
						strTemp = (String)vEmployeeWH.elementAt(i+37);
						strTemp2 = (String)vEmployeeWH.elementAt(i+38);
						if(strTemp != null && strTemp2 != null){
							dTime = Double.parseDouble(strTemp);
							if(dTime >= 12){
								strAMPM = " PM";
								if(dTime > 12)
									dTime = dTime - 12;
							}else{
								strAMPM = " AM";
							}
							
							iHour = (int)dTime;
							dTime = (dTime - iHour) * 60 + .02;
							iMinute = (int)dTime;
							if(iHour == 0)
								iHour = 12;
							
							strTemp = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;
							
							dTime = Double.parseDouble(strTemp2);
							if(dTime >= 12){
								strAMPM = " PM";
								if(dTime > 12)
									dTime = dTime - 12;
							} else {
								strAMPM = " AM";
							}
							
							iHour = (int)dTime;
							dTime = ((dTime - iHour) * 60) + .02;
 							iMinute = (int)dTime;
							if(iHour == 0)
								iHour = 12;
							
							strTemp2 = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;
							
							strTemp += " - <br>" + strTemp2;
						}else{
							strTemp = (String)vEmployeeWH.elementAt(i+35);
 							if(Double.parseDouble(WI.getStrValue(strTemp,"0")) == 0)
								strTemp = "";
						}
 						%> 
           <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	         <% if (!bolMyHome){%> 
           <td class="thinborder">&nbsp;
						<%if(iAccessLevel > 1 && bolAllowEdit) {%>
						<a href='javascript:ShowUpdate("<%=vEmployeeWH.elementAt(i+31)%>", "<%=WI.fillTextValue("emp_id")%>");'><strong>EDIT</strong></a>
						<%}else{%>
						&nbsp;
						<%}%>						 
        <%if(iAccessLevel ==2){
					if(bolAllowDelete){
				%>
        <input type="image" src="../../../images/delete.gif" width="55" border="0" 
	  	  onClick='DeleteRecord("<%=WI.getStrValue((String)vEmployeeWH.elementAt(i+31))%>")'>
					<%}else{%>
					N/A
					<%}%>
          <%} //end if (iAccessLevel == 2) %>            
					</td>
				<%}%> 
          </tr>
          <%
				}// end (String)vEmployeeWH.elementAt(i+33) != null
			}// end else
    }
   } // end for loop
  } // end if
 } // else if (vRetResult == null)
} %>
      </table></td>
    </tr>
</table>
<%}%>
<!-- here lies the great mysteries of and future-->
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25"s>&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="">
<input type="hidden" name="prepareToEdit" value="">
<input type="hidden" name="iStatus" value="">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">

<!-- for non-EDTR set user_index if called for nonEDTR remove info-->
<input type="hidden" name="non_EDTR">
<input type="hidden" name="focus_area">
<input type="hidden" name="view_only" value="<%=WI.fillTextValue("view_only")%>">

</form>
</body>
</html>
<% dbOP.cleanUP(); %>
