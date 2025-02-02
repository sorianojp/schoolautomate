<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
			
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 14px}
.style2 {font-size: 10px}
-->
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function showLunchBreak(){
	if (document.dtr_op.one_tin_tout.checked){
		document.getElementById("lunch_br").innerHTML = 
		"<input name=\"lunch_break\" type=\"text\" size=\"3\" maxlength=\"3\"  "+ 
		"value=\"<%=WI.fillTextValue("lunch_break")%>\" class=\"textbox\" " +
		"onFocus=\"style.backgroundColor=\'#D3EBFF\'\" onBlur=\"style.backgroundColor=\'#FFFFFF\'\" " +
		" onKeypress=\" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;\"> Lunch Break (in Minutes)";
		document.dtr_op.logout_nextday.disabled = false;
	}else{
		document.getElementById("lunch_br").innerHTML = "";
		document.dtr_op.logout_nextday.disabled = true;
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
	document.dtr_op.page_action.value=1;
}

function AddRecord(){
	document.dtr_op.page_action.value=2;
}
function DeleteRecord(index){
	document.dtr_op.page_action.value =3;
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

function viewHistory() {
	var pgLoc = "./set_working_history.jsp?emp_id=";
	
	if (document.dtr_op.emp_id) 
		pgLoc +=  escape(document.dtr_op.emp_id.value);
	
	pgLoc+="&my_home="+document.dtr_op.my_home.value;

	var win=window.open(pgLoc,"view_history",'dependent=yes,width=600,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
-->
</script>
<body bgcolor="#D2AE72" 
<% if (!WI.fillTextValue("my_home").equals("1")){%>
	onLoad="document.dtr_op.emp_id.focus();"
<%}%>>
<%
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strPrepareToEdit = null;

	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","set_working_day.jsp");
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
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"set_working_day.jsp");	
														
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

//end of authenticaion code.
	WorkingHour wHour = new WorkingHour(); 
	Vector vRetResult = null;
	Vector vEmployeeWH = null;
	String[] astrConverAMPM = {"AM","PM"};

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}
	
	
	if(WI.fillTextValue("page_action").equals("1")){
		vRetResult = wHour.operateOnDailyWH(dbOP, request,1);
		strErrMsg = wHour.getErrMsg();
	}else if(WI.fillTextValue("page_action").equals("2")){
		vRetResult = wHour.operateOnDailyWH(dbOP, request,2);
		strErrMsg = wHour.getErrMsg();
		if (strErrMsg == null)
			strErrMsg = "Working Hour added successfully." ;
	}else if(WI.fillTextValue("page_action").equals("3")){
		vRetResult = wHour.operateOnDailyWH(dbOP,request,3);
		strErrMsg = wHour.getErrMsg();
		if (strErrMsg == null)  strErrMsg = "Working Hour deleted successfully ." ;
	}
	if(WI.fillTextValue("non_EDTR").length() > 0) {
		if(wHour.removeNonEDTRWH(dbOP, WI.fillTextValue("non_EDTR"), 
				(String)request.getSession(false).getAttribute("login_log_index")))
			strErrMsg = "Working hour information removed successfully.";
		else	
			wHour.getErrMsg();
	}

	vEmployeeWH = wHour.getDailyWorkingHours(dbOP, request,false);
%>	
<form action="./set_working_day.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" ><strong>:::: 
      WORKING HOURS MGMT - SET WORKING HOURS PAGE ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25"><strong><font size=2>&nbsp;<%=WI.getStrValue(strErrMsg)%>&nbsp;</font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<% if (!bolMyHome) {%>
    <tr valign="top"> 
      <td width="2%" height="30" valign="top">&nbsp;</td>
      <td width="14%" height="30">Employee ID</td>
      <td width="19%" height="30" valign="top"><input name="emp_id" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);" value="<%=WI.fillTextValue("emp_id")%>" size="16">      </td>
      <td width="5%" valign="top"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="14%" valign="top"><input type="image"  src="../../../images/form_proceed.gif" name="proceed" onClick="ViewRecord()" >      </td>
      <td width="46%" valign="top"><label id="coa_info"></label></td>
    </tr>
<%}else{%>
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
      <td height="15" colspan="2"><font size="1">Position</font></td>
      <td height="15"><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office</font></td>
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

<% if(WI.fillTextValue("specify_wh").compareTo("1") == 0) strTemp = "checked";
else strTemp = "";%> 
<input type="checkbox" name="specify_wh" value="1" onClick="ChangeWorkingHrType(0);" <%=strTemp%>> Specify working hour			</td>
    </tr>
    <%if(WI.fillTextValue("regular_wh").compareTo("1") ==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"> 
 <%	vRetResult = wHour.getDefaultWHIndex(dbOP,null); 
	if (vRetResult == null || vRetResult.size() == 0) { %>
	 <div align="center"> <font size="3"><strong>No Record of Default working 
          hours</strong></font></div> 
 <%}else{%>
 <br>
	  <table width="65%" border="0" cellpadding="1" cellspacing="0" class="thinborder">
          <tr> 
<%	for(int i = 0; i < vRetResult.size(); i+=6){
	strTemp = (String)vRetResult.elementAt(i);
	if (strTemp == null) 
		strTemp = "N/A Week Day";
		
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
<%}%>		</td>
    </tr>
    <%}else if(WI.fillTextValue("specify_wh").equals("1")){%>
    <tr> 
      <td height="18">&nbsp;</td>
      <td width="19%">&nbsp; </td>
      <td colspan="2"></td>
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
        </select> &nbsp;&nbsp;&nbsp; <input name="one_tin_tout" type="checkbox"  value="1"  onClick="showLunchBreak()"> 
        <font size="1">employee has only one time in/time out </font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Second Time In</td>
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
		<label id="lunch_br"> </label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><input name="logout_nextday" type="checkbox" id="logout_nextday" value="1" disabled>
        <font size="1">employee logout is on the next day</font></td>
    </tr>
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
</select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Days :</td>
      <td colspan="2"><input type="text" name="work_day" value="<%=WI.fillTextValue("work_day")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" OnKeyUP="javascript:this.value=this.value.toUpperCase();"> 
        <font size="1">(M-T-W-TH-F-SAT-S) <!-- for now it is not allowed to have irregular week day.
		<input name="noWeekDay2" type="checkbox" id="noWeekDay2" value="1" >
        tick if weekday is irregular
	   -->
        </font></td>
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
      <td height=30 colspan=3 align="center"><p><strong> <font color="#993333"><span class="style1"><br>
        Employee 
        will not be required to time in and time out. </span><br>
        <br><br>
      </font></strong></p>      </td>
    </tr>
    <%} if ((iAccessLevel > 1) && ((WI.fillTextValue("is_flex").equals("1"))    || 
        (WI.fillTextValue("regular_wh").equals("1")) ||
		(WI.fillTextValue("specify_wh").equals("1")) ||
		(WI.fillTextValue("is_nonDTR").equals("1")))){%>	
    <tr>
      <td>&nbsp;</td>
      <td height=20>&nbsp;</td>
      <td height=20>&nbsp;</td>
      <td height=20>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height=30> Working Date : </td>
      <td height=30><input name="work_date" type="text" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" 
	   onBlur="style.backgroundColor='white'; AllowOnlyIntegerExtn('dtr_op','work_date','/');"
	   onKeyUp= "AllowOnlyIntegerExtn('dtr_op','work_date','/')"
	    value="<%=WI.fillTextValue("work_date")%>" size="10" maxlength="10">
      <a href="javascript:show_calendar('dtr_op.work_date');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td height=30>&nbsp;</td>
    </tr>
		
    <tr>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><div align="center">
          <input name="image" type="image" onClick="AddRecord();" src="../../../images/save.gif" width="48" height="28">
          <font size="1">click to save changes </font> &nbsp; </div></td>
    </tr>
<%}
 } // do not show if my home
%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr bgcolor="#B9B292"> 
        <td height="25" colspan="9" align="center" bgcolor="#B9B292">LIST OF 
          CURRENT WORKING HOURS FOR ID : <%=WI.fillTextValue("emp_id")%> (
          <input name="show_history" type="checkbox" value="1" onClick="javascript:viewHistory()">
			click to see history)</td>
      </tr>
    <tr> 
      <td height="25" colspan="9">
	  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
<% if (vEmployeeWH == null) {  %>
          <tr> 
            <td height="25" colspan=4 align="center" class="thinborder"><font size=2><strong> 
              No Record of Employee Working Hours</strong></font></td>
          </tr>
<% } // end if ( vRetResult == null)
    else{ // else if (vRetResult == null)%>
          <tr> 
            <td width="20%" height="25" class="thinborder"><strong>WORKING DATE </strong> </td>
            <td width="43%" align="center" class="thinborder"><strong>TIME / HOURS</strong></td>
            <td width="14%" align="center" class="thinborder"><strong>  BREAK </strong></td>
		<%if (!bolMyHome){%> 
            <td width="8%" align="center" class="thinborder"><strong> DELETE</strong></td>			
		<%}%> 
          </tr>
<% if(vEmployeeWH.size() == 2 && 
		((String)vEmployeeWH.elementAt(0)).equals("-1")){
		  vEmployeeWH.removeElementAt(0);//do not enter in next loop. %>
          <tr> 
            <td width="20%" height="25" class="thinborder">&nbsp;</td>
            <td height="25" colspan="2" align="center" class="thinborder"><strong>NON-EDTR EMPLOYEE</strong></td>
		<% if (!bolMyHome) {%> 
            <td width="8%" height="25"  class="thinborder">&nbsp; 
              <% if(iAccessLevel ==2){%>
              <a href='javascript:DeleteNonEDTR("<%=(String)vEmployeeWH.remove(0)%>")'> 
              <img src="../../../images/delete.gif" border="0"> </a> 
              <%} //end if (iAccessLelve == 2) %>            </td>
		<%}%> 
          </tr>
<% } else {//end if (vRetResult.size() == 2 && ((String)vRetResult.elementAt(0)).compareTo("-1") == 0)
		  for (int i = 0; i < vEmployeeWH.size(); i+=18){%>
          <tr> 
            <td height="25" bgcolor="#FFFFFF"  class="thinborder">&nbsp;
					<%=WI.getStrValue((String)vEmployeeWH.elementAt(i+16))%></td>
         <%
					 strTemp = "";
						// first login time
						strTemp2 = (String)vEmployeeWH.elementAt(i+1) +  ":"  + 
							CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+2)) +
							" " + astrConverAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(i+3))] + 
							" - " + (String)vEmployeeWH.elementAt(i+4) +  
							":"  + 	CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+5)) + 
							" " + astrConverAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(i+6))];

						// second login time
						if ((String)vEmployeeWH.elementAt(i+7) != null)
								strTemp = " / " + (String)vEmployeeWH.elementAt(i+7) +  ":" + 
								CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+8)) +
								" " + astrConverAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(i+9))] + 
								" - " + (String)vEmployeeWH.elementAt(i+10) + ":"  + 
								CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+11)) +  
								" " + astrConverAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(i+12))];
										 
							if (((String)vEmployeeWH.elementAt(i + 15)).equals("1"))
								strTemp +="(next day)";
					%>
            <td bgcolor="#FFFFFF" class="thinborder"><strong>&nbsp;<%=strTemp2%><%=WI.getStrValue(strTemp)%></strong></td>
         <td bgcolor="#FFFFFF"  class="thinborder"><strong>&nbsp;<%=WI.getStrValue((String)vEmployeeWH.elementAt(i+17))%></strong></td>
		<% if (!bolMyHome) {%>
         <td bgcolor="#FFFFFF"  class="thinborder">&nbsp;
           <%if(iAccessLevel ==2){%>
           <input type="image" src="../../../images/delete.gif" width="55" height="28" 
		   border="0" onClick='DeleteRecord("<%=(String)vEmployeeWH.elementAt(i)%>")'>
           <%} // end iAccessLevel == 2%>         </td>
		 <%}%> 
          </tr>
    <%
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
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="">
<input type="hidden" name="prepareToEdit" value="">
<input type="hidden" name="iStatus" value="">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">

<!-- for non-EDTR set user_index if called for nonEDTR remove info-->
<input type="hidden" name="non_EDTR">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
