<%@ page language="java" import="utility.*,java.util.Vector,eDTR.OverTime" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(7);
	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").equals("1")){
		strColorScheme = CommonUtil.getColorScheme(9);
		bolMyHome = true;	
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Overtime request</title>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function AddRecord(){
	document.dtr_op.iAction.value="1";
	document.dtr_op.save_button.src ="../../../images/blank.gif"
	document.dtr_op.submit();
}
function DeleteRecord(index){
	document.dtr_op.iAction.value ="0";
	document.dtr_op.info_index.value=index;
}
function ReloadPage(){
	document.dtr_op.submit();
}

function ViewRecord(index){
	var pgLoc = "validate_approve_ot.jsp?info_index="+index+"&iAction=3&my_home="+
		document.dtr_op.my_home.value;

	var win=window.open(pgLoc,"ViewApprove",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}

function PrintPg() {
	var pgLoc = "./ot_print.jsp?date_from="+escape(document.dtr_op.date_from.value)+
			"&date_to="+escape(document.dtr_op.date_to.value)+"&my_home="+document.dtr_op.my_home.value+
			"&status="+document.dtr_op.status.value+"&emp_id_con="+document.dtr_op.emp_id_con.value+
			"&emp_id_search="+document.dtr_op.emp_id_search.value+"&print_page=1";
	var win=window.open(pgLoc,"PrintWindow",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch() {
	//requested_by, requested_for
	var strFocusStat = document.dtr_op.focus_stat.value;
	if(strFocusStat.length == 0) {
		alert("Please select 'Requested For' or 'Requested By' before clicking search.");
		return;
	}
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.";
	if(strFocusStat == '1')
		pgLoc += "requested_by";
	else	
		pgLoc +="requested_for";
		
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//all about ajax - to display student list with same name.
///for searching COA
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

function searchSubordinates() {
	var vObjSearch = document.getElementById("subordinates_");
  var strRequestBy = document.dtr_op.requested_by.value;
	var strUpdateField = document.dtr_op.requested_for; 
	var strMyHome = document.dtr_op.my_home.value;
	var divEmplist = document.getElementById("emp_list");
	
	if(strRequestBy.length <=2) {
		vObjSearch.innerHTML = "";
		divEmplist.style.height = "25px";		
		alert("Enter ID in requested by field");
		return ;
	}		
		this.InitXmlHttpObject(vObjSearch, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		divEmplist.style.height = "200px";		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=601&req_by="+escape(strRequestBy)+
			"&method_name=searchSubordinates&my_home="+strMyHome;
		this.processRequest(strURL);
}

function checkAllSave() {
	var maxDisp = document.dtr_op.emp_count.value;
	//unselect if it is unchecked.
	if(!document.dtr_op.selAllSave.checked) {
		for(var i =0; i< maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=false');
	}
	else {
		for(var i =0; i< maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=true');
	}
}

function copySelected() {
	var maxDisp = document.dtr_op.emp_count.value;
	var strSelected = null;
	//unselect if it is unchecked.
	for(var i =0; i< maxDisp; ++i){
 		if(eval('document.dtr_op.save_'+i+'.checked')){
			if(strSelected == null)
				strSelected = eval('document.dtr_op.emp_id_'+i+'.value');
			else
				strSelected += ", "+eval('document.dtr_op.emp_id_'+i+'.value');
		}			
	}
	if(strSelected == null)
		strSelected = "";
	
	document.dtr_op.requested_for.value = strSelected;
	closePopup();
}

function closePopup() {
	var vObjSearch = document.getElementById("subordinates_");
	var divEmplist = document.getElementById("emp_list");
	vObjSearch.innerHTML = "<a href='javascript:searchSubordinates();'>SELECT</a>";
	divEmplist.style.height = "25px";
}

function toggleBreakFields(){
	if (!document.dtr_op.has_break)
		return;
	if (document.dtr_op.has_break.checked){
		document.dtr_op.break_hr_fr.disabled = false;
		document.dtr_op.break_min_fr.disabled = false;
		document.dtr_op.break_ampm_fr.disabled = false;
		document.dtr_op.break_hr_to.disabled = false;
		document.dtr_op.break_min_to.disabled = false;
		document.dtr_op.break_ampm_to.disabled = false;
	}else{
		document.dtr_op.break_hr_fr.disabled = true;
		document.dtr_op.break_min_fr.disabled = true;
		document.dtr_op.break_ampm_fr.disabled = true;
		document.dtr_op.break_hr_to.disabled = true;
		document.dtr_op.break_min_to.disabled = true;
		document.dtr_op.break_ampm_to.disabled = true;
	}
}
</script>
</head>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="javascript:toggleBreakFields();">
<% 
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;

	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasOTBreak = false;
	boolean bolIsGovernment = false;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-OVERTIME MANAGEMENT-OT Request","schedule_overtime.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasOTBreak = (readPropFile.getImageFileExtn("HAS_OT_BREAK","0")).equals("1");
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");
		
	}	catch(Exception exp)	{
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
														"eDaily Time Record","OVERTIME MANAGEMENT",request.getRemoteAddr(), 
														"schedule_overtime.jsp");	
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","OVERTIME MANAGEMENT-Overtime Request",request.getRemoteAddr(), 
														"schedule_overtime.jsp");	
}

if (bolMyHome){
	iAccessLevel = 2;
}

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
OverTime OT = new OverTime();
Vector vRetResult = null;
Vector vOTSetting = null;
String strSchCode = dbOP.getSchoolIndex();

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Requested By","Date of Request","Date of OT", "No of Hours","Status", "Last Name(Requested for)"};
String[] astrSortByVal     = {"sup_employee.lname","request_date","ot_specific_date","no_of_hour","approve_stat", "employee.lname"};
vOTSetting = OT.operateOnMinOvertime(dbOP, request, 3);

if (WI.fillTextValue("iAction").equals("1")){
		if(bolMyHome){
			if (OT.addMultipleOTRequest(dbOP, request) == null)
				strErrMsg = OT.getErrMsg();
			else
				strErrMsg = "Multiple Overtime Added Successfully";
		}else{
			if (OT.operateOnOTChangeStatus(dbOP,request,1) == null)
				strErrMsg = OT.getErrMsg();
			else
				strErrMsg = "Overtime Added Successfully.";
		}
}else if(WI.fillTextValue("iAction").compareTo("0")==0){
		if (OT.operateOnOTChangeStatus(dbOP,request,0) == null)
			strErrMsg = OT.getErrMsg();
		else
			strErrMsg = " Overtime Record Successfully Deleted";
			
}else if (WI.fillTextValue("iAction").equals("2")){
	if (OT.operateOnOTChangeStatus(dbOP,request,2) == null)
		strErrMsg = OT.getErrMsg();
	else
		strErrMsg = " Overtime Status updated successfully";
}

 vRetResult = OT.getOTList(dbOP,request, null);
 if(vRetResult == null){
 	strErrMsg = OT.getErrMsg();
 }
 
 String strDateFrom = WI.fillTextValue("date_from");
 String strDateTo = WI.fillTextValue("date_to");

 if (WI.fillTextValue("first_entry").length() ==0) {
 	String[] aStrRange = eDTR.eDTRUtil.getCurrentCutoffDateRange(dbOP, true);
	if (aStrRange != null){
		strDateFrom = aStrRange[0];
		strDateTo = aStrRange[1];
	}else{
		strErrMsg = " Please set the DTR Cut off Dates";
	}
 }
%>
<form action="./schedule_overtime.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      OVERTIME REQUEST DETAILS PAGE ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25"> <strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td height="25"><table width="100%" border="0" cellpadding="2" cellspacing="0">
          <tr>
            <td width="16%" align="right" bgcolor="#F2F7FF">FILTER   DATES&nbsp; </td>
						<%
							strTemp = request.getParameter("date_from");
							if(strTemp == null)
								strTemp = WI.getTodaysDate(1);
						%>
            <td colspan="2" bgcolor="#F2F7FF"> &nbsp;&nbsp;From
              <input name="date_from" type="text" class="textbox"  
							onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
							value="<%=strTemp%>" size="10" maxlength="10" 
							onKeyUp="AllowOnlyIntegerExtn('dtr_op','date_from','/')">
              <a href="javascript:show_calendar('dtr_op.date_from');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;&nbsp;&nbsp;To 
					<%
							strTemp = request.getParameter("date_to");
							if(strTemp == null)
								strTemp = WI.getTodaysDate(1);
						%>							
              <input name="date_to" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="10" maxlength="10"  
							onKeyUp="AllowOnlyIntegerExtn('dtr_op','date_to','/')">
              <a href="javascript:show_calendar('dtr_op.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td width="40%" bgcolor="#F2F7FF"><a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" 
													width="71" height="23" border="0"></a></td>
          </tr>
          <tr>
            <td colspan="4" align="right" height="10"></td>
          </tr>
          <tr> 
            <td>Request Date</td>
						<% strTemp = WI.fillTextValue("request_date");
							if (strTemp.length() == 0) 
								strTemp = WI.getTodaysDate(1); %>
            <td colspan="3">
<%if(bolMyHome && bolIsSchool) {%>
							<input name="request_date" type="text" value="<%=strTemp%>" readonly="true" class="textbox_noborder">
<%}else{%>
							<input name="request_date" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" 
							 onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="10" maxlength="10" readonly="true"> 
              <a href="javascript:show_calendar('dtr_op.request_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../images/calendar_new.gif" border="0"></a>
<%}%>
			</td>
          </tr>
          <tr>
            <td>Requested by</td>
<%
	if (bolMyHome) 
		strTemp =  (String)request.getSession(false).getAttribute("userId");
	else{		
		strTemp =  WI.fillTextValue("requested_by");
		if(strTemp.length() == 0)
			strTemp =  (String)request.getSession(false).getAttribute("userId");
	}
%>
		<%
		//EAC wants to edit requested by even in my_home. sul12032012
		if(strSchCode.startsWith("EAC")){%>
            <td width="28%"><input name="requested_by" type="text" class="textbox" 
				onFocus="document.dtr_op.focus_stat.value='1';style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('requested_by', 'req_by');"
				value="<%=strTemp%>" size="16"></td>
		<%}else{%>
            <td width="28%"><input name="requested_by" type="text" class="textbox" 
				onFocus="<%if(!bolMyHome) {%>document.dtr_op.focus_stat.value='1';style.backgroundColor='#D3EBFF'<%}%>" 
				onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('requested_by', 'req_by');"
				value="<%=strTemp%>" size="16"
				<% if (bolMyHome) {%>readonly <%}%>></td>
		<%}%>				
				
            <td width="16%"> Requested For</td>
						<%
						strTemp =  WI.fillTextValue("requested_for");
						if(strTemp.length() == 0)
							strTemp =  (String)request.getSession(false).getAttribute("userId");						
						%>						
            <td>
				<% if (bolMyHome) {%>
				<textarea name="requested_for" cols="20" rows="2" class="textbox" 
				onFocus="document.dtr_op.focus_stat.value='2';style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" readonly style="font-size:10px"><%=strTemp%></textarea>				
				<div id="emp_list" style="width:145px;height:200px; overflow:auto; position:absolute;">
				<label id="subordinates_">
				<a href="javascript:searchSubordinates();">SELECT</a>				</label>
				</div>
				<%}else{%>
				<input name="requested_for" type="text" class="textbox" 
				onFocus="document.dtr_op.focus_stat.value='2';style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('requested_for','req_for');"
				value="<%=strTemp%>" size="16">
				<%}%>				</td>
          </tr>
          <tr> 
            <td colspan="2">&nbsp;<label id="req_by"></label></td>
            <td colspan="2">&nbsp;<label id="req_for"></label></td>
          </tr>
          <tr>
            <td align="right" bgcolor="#FFF2E6">Option &nbsp;</td>
            <td colspan="3" bgcolor="#FFF2E6"><select name="requestDayDate" onChange="ReloadPage()">
                <option value="0">Specific Date</option>
                <% if (WI.fillTextValue("requestDayDate").equals("1")) {%>
                <option value="1" selected>Days</option>
                <%}else{%>
                <option value="1">Days</option>
            <%}%></select>
              <% if (WI.fillTextValue("requestDayDate").equals("1")){%>
              <input name="DayDate" type="text"  class="textbox" value="<%=WI.fillTextValue("DayDate")%>"
			 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			 onKeyPress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" 
			 onKeyUp="javascript:this.value=this.value.toUpperCase();">
              <font size="1">(M-T-W-TH-F-SAT-S format) </font><br>
              <%}else{%>
              <input name="DayDate" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white'" size="10" value="<%=WI.fillTextValue("DayDate")%>">
							&nbsp;<a href="javascript:show_calendar('dtr_op.DayDate');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;
		<%}%></td>
          </tr>  
 		<% if (WI.fillTextValue("requestDayDate").equals("1")) {%>
          <tr> 
            <td align="right" valign="bottom" bgcolor="#FFF2E6">Inclusive Dates&nbsp;&nbsp;</td>
            <td colspan="3" bgcolor="#FFF2E6">From : 
              <input name="DateFrom" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white'" size="10" value="<%=WI.fillTextValue("DateFrom")%>">
              &nbsp;<a href="javascript:show_calendar('dtr_op.DateFrom');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
              &nbsp;&nbsp;&nbsp;To: 
              <input name="DateTo" type="text"  class="textbox" id="DateTo" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white'" size="10" value="<%=WI.fillTextValue("DateTo")%>">
              &nbsp;<a href="javascript:show_calendar('dtr_op.DateTo');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>            </td>
          </tr>
		  <%}%>
<tr>
            <td align="right" valign="bottom" bgcolor="#FFF2E6">Inclusive Time &nbsp;</td>
            <td colspan="3" valign="bottom" bgcolor="#FFF2E6">
              From : 
              <input name="am_hr_fr" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_hr_fr")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  >
              : 
              <input name="am_min_fr" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_min_fr")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
              <select name="ampm_from" id="ampm_from">
                <option value=0>AM</option>
                <% if (WI.fillTextValue("ampm_from").equals("1")) {%>
                <option value=1 selected>PM</option>
                <% }else{%>
                <option value=1>PM</option>
                <%}%>
              </select>
              to 
              <input name="am_hr_to" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_hr_to")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
              : 
              <input name="am_min_to" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_min_to")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
              <select name="ampm_to" id="ampm_to">
                <option value="0">AM</option>
                <% if (WI.fillTextValue("ampm_to").compareTo("1")== 0) {%>
                <option value="1" selected>PM</option>
                <%}else{%>
                <option value="1">PM</option>
                <%}%>
            </select>
            <input name="max_ot_hour" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="6" value="<%=WI.fillTextValue("max_ot_hour")%>">
<%
strTemp = WI.fillTextValue("is_nextday_logout");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>
            <font size="1">Max Overtime hours (optional) </font><br>
						<input type="checkbox" value="1" name="is_nextday_logout"<%=strTemp%>>
						<font size="1">Next day logout</font></td>
          </tr>
			
			<%if(bolHasOTBreak){%>
			<tr>
				<td align="right" valign="bottom" bgcolor="#FFF2E6">Break </td>
			<%
				if(vOTSetting != null && vOTSetting.size() > 0)
					strTemp = (String)vOTSetting.elementAt(3);
				else
					strTemp = WI.fillTextValue("break_hr_fr");
				strTemp = WI.getStrValue(strTemp);
			%>	
  <td colspan="3" valign="bottom" bgcolor="#FFF2E6"><input name="break_hr_fr" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" disabled>
:
			<%
				if(vOTSetting != null && vOTSetting.size() > 0)
					strTemp = (String)vOTSetting.elementAt(4);
				else
					strTemp = WI.fillTextValue("break_min_fr");
				strTemp = WI.getStrValue(strTemp);
			%>
<input name="break_min_fr" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" disabled>
			<%
				if(vOTSetting != null && vOTSetting.size() > 0)
					strTemp = (String)vOTSetting.elementAt(5);
				else
					strTemp = WI.fillTextValue("break_ampm_fr");
				strTemp = WI.getStrValue(strTemp);
			%>
<select name="break_ampm_fr" id="break_ampm_fr" disabled>
  <option value=0>AM</option>
  <% if (strTemp.equals("1")) {%>
  <option value=1 selected>PM</option>
  <% }else{%>
  <option value=1>PM</option>
  <%}%>
</select>
to
			<%
				if(vOTSetting != null && vOTSetting.size() > 0)
					strTemp = (String)vOTSetting.elementAt(6);
				else
					strTemp = WI.fillTextValue("break_hr_to");
				strTemp = WI.getStrValue(strTemp);
			%>
<input name="break_hr_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" disabled>
:
<%
					if(vOTSetting != null && vOTSetting.size() > 0)
						strTemp = (String)vOTSetting.elementAt(7);
					else
						strTemp = WI.fillTextValue("break_min_to");
					strTemp = WI.getStrValue(strTemp);
			%>
<input name="break_min_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" disabled>
<%
					if(vOTSetting != null && vOTSetting.size() > 0)
						strTemp = (String)vOTSetting.elementAt(8);
					else
						strTemp = WI.fillTextValue("break_ampm_to");
					strTemp = WI.getStrValue(strTemp);
			%>
<select name="break_ampm_to" id="break_ampm_to" disabled>
  <option value="0">AM</option>
  <% if (strTemp.compareTo("1")== 0) {%>
  <option value="1" selected>PM</option>
  <%}else{%>
  <option value="1">PM</option>
  <%}%>
</select>
<input type="checkbox" value="1" name="has_break" onClick="toggleBreakFields();" checked>
<font size="1">has break</font></td>
</tr>
<%}%>
          <%if(!bolMyHome){%>
					<tr>
            <td>&nbsp;</td>
						<%
							strTemp = WI.fillTextValue("ot_type_index");
							/*
 							if(strTemp.length()  == 0){
								strTemp = 
									" select ot_type_index from pr_ot_mgmt where is_valid = 1 and is_for_ot = 1"+ 
									" and exists(select holiday_type_index from EDTR_HOLIDAY where is_del = 0 "+
									"    and holiday_date = '" + WI.getTodaysDate(1) + "' " +
									"     and EDTR_HOLIDAY.holiday_type_index = pr_ot_mgmt.holiday_type_index)";
 								strTemp = dbOP.getResultOfAQuery(strTemp, 0);
 							}
							*/
 						%>
            <td colspan="3">
						<select name="ot_type_index">
              <option value="">Auto select overtime Type</option>
              <%=dbOP.loadCombo("ot_type_index","ot_name", " from pr_ot_mgmt " +
		 					 " where is_valid = 1 and is_for_ot = 1 ", strTemp,false)%>
            </select>
						<%if(bolIsGovernment && !bolMyHome){
							strTemp = WI.fillTextValue("auto_approve");
							if(strTemp.length() > 0)
								strTemp = "checked";
							else
								strTemp = "";
						%>
						<input type="checkbox" value="1" name="auto_approve" <%=strTemp%>>
            <font size="1">Save and Approve</font> 
						<%}%>
						</td>
          </tr>
					<%}%>
          <tr> 
            <td align="right">Details of Overtime </td>
            <td colspan="3"><textarea name="ot_reason" cols="48"rows="4" class="textbox" id="ot_reason" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("ot_reason")%></textarea>            </td>
          </tr>
      </table>			</td>
    </tr>
    <tr > 
      <td width="81%" height="25">
			<div align="center"> 
		  <% if (iAccessLevel > 1 || bolMyHome) {%> 
          <a href="javascript:AddRecord()"><img src="../../../images/save.gif" border="0" 
		  name="save_button"></a>
          <font size="1">click to add</font> 
		 	<%}%>
	 		</div></td>
    </tr>
		<tr> 
      <td height="17" colspan="3">
				 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">						
						<tr>
						  <td height="10" colspan="2"><hr size="1" color="#000000"></td>
				   </tr>
						<tr>
							<td width="16%" height="25"><strong>&nbsp;Status</strong></td>
							<td width="84%" height="25"><select name="status" id="status">
                <option value="">ALL</option>
                <% if (WI.fillTextValue("status").equals("1")){%>
                <option value="1" selected>APPROVED</option>
                <%}else{%>
                <option value="1">APPROVED</option>
                <%} if (WI.fillTextValue("status").equals("0")){%>
                <option value="0" selected>DISAPPROVED</option>
                <%}else{%>
                <option value="0" >DISAPPROVED</option>
                <%} if (WI.fillTextValue("status").equals("2")){%>
                <option value="2" selected>PENDING</option>
                <%}else{%>
                <option value="2">PENDING</option>
                <%}%>
              </select></td>
						</tr>
						
						<tr>
							<td height="25"><strong>&nbsp;Requested for </strong></td>
							<td height="25"><select name="emp_id_con">
                <%=OT.constructGenericDropList(WI.fillTextValue("emp_id_con"),astrDropListEqual,astrDropListValEqual)%>
              </select>
                <input name="emp_id_search" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="15"
			  value="<%=WI.fillTextValue("emp_id_search")%>" onKeyUp="AjaxMapName('emp_id_search', 'req_by_search');"><label id="req_by_search"></label></td>
						</tr>
						<tr>
							<td height="8" colspan="2"></td>
						</tr>
				</table>
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
            
            <tr>
              <td  width="10%" bgcolor="#FFFFFF"><strong>Sort By </strong></td>
              <td width="28%" bgcolor="#FFFFFF"><select name="sort_by1">
                  <option value="" selected>N/A</option>
                  <%=OT.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
                </select>
                  <br>
                  <select name="sort_by1_con">
                    <option value="asc">Ascending</option>
                    <%
					if(WI.fillTextValue("sort_by1").compareTo("desc") ==0){%>
                    <option value="desc" selected>Descending</option>
                    <%}else{%>
                    <option value="desc">Descending</option>
                    <%}%>
                </select></td>
              <td width="28%" bgcolor="#FFFFFF"><select name="sort_by2">
                  <option value="">N/A</option>
                  <%=OT.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
                </select>
                  <br>
                  <select name="sort_by2_con">
                    <option value="asc">Ascending</option>
                    <%
				if(WI.fillTextValue("sort_by2").compareTo("desc") ==0){%>
                    <option value="desc" selected>Descending</option>
                    <%}else{%>
                    <option value="desc">Descending</option>
                    <%}%>
                </select></td>
              <td width="34%" bgcolor="#FFFFFF"><select name="sort_by3">
                  <option value="">N/A</option>
                  <%=OT.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
                </select>
                  <br>
                  <select name="sort_by3_con">
                    <option value="asc">Ascending</option>
                    <% if(WI.fillTextValue("sort_by3").compareTo("desc") ==0){%>
                    <option value="desc" selected>Descending</option>
                    <%}else{%>
                    <option value="desc">Descending</option>
                    <%}%>
                </select></td>
            </tr>
            <tr>
              <td bgcolor="#FFFFFF">&nbsp;</td>
              <td bgcolor="#FFFFFF"><a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" 
							width="71" height="23" border="0"></a></td>
              <td bgcolor="#FFFFFF">&nbsp;</td>
              <td bgcolor="#FFFFFF">&nbsp;</td>
            </tr>
          </table></td>
    </tr>
  </table>
<%
	if (vRetResult != null && vRetResult.size()>3) { %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#868659">
      <td height="25" colspan="10" align="center" bgcolor="#868659">
  	  <font color="#FFFFFF"><strong> LIST OF OVERTIME  REQUEST </strong></font></td>
    </tr>
    <tr>
      <td width="18%" class="thinborder">
	  		<strong><font size="1">&nbsp;Requested by </font></strong></td>
      <td width="18%" class="thinborderBOTTOM">
	  		<font size="1"><strong>&nbsp;Requested For</strong></font></td>
      <td width="15%" height="25" class="thinborderBOTTOM">
	  		 <font size="1"><strong>&nbsp;Date of &nbsp;<br>
        &nbsp;Request</strong></font></td>
      <td width="18%" class="thinborderBOTTOM"><font size="1"><strong>&nbsp;Date/Days</strong></font></td>
      <td width="9%" class="thinborderBOTTOM"><font size="1"><strong>&nbsp;Inclusive<br>
      &nbsp;Time</strong></font></td>
      <td width="6%" class="thinborderBOTTOM"><font size="1"><strong>&nbsp;No. of<br>
        &nbsp;Hours</strong></font></td>
      <td width="10%" class="thinborderBOTTOM"><font size="1"><strong>&nbsp;Status</strong></font></td>
 			<td  class="thinborderBOTTOM"><font size="1"><strong>Reason</strong></font></td>
      <td  class="thinborderBOTTOM"><font size="1"><strong>&nbsp;DELETE</strong></font> </td>
    </tr>
    <%for(int i = 3 ; i < vRetResult.size() ; i+=17){ %>
    <tr>
      <% 
				strTemp =(String)vRetResult.elementAt(i+15); 
			%>
      <td class="thinborder"><font size="1"><%=WI.getStrValue(strTemp,"&nbsp;")%></font></td>
      <td class="thinborderBOTTOM"><font size="1"> <%=WI.getStrValue((String)vRetResult.elementAt(i+16),"&nbsp;")%></font></td>
      <td class="thinborderBOTTOM"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <% 
		   		strTemp = (String)vRetResult.elementAt(i+7);
		   		if (strTemp  == null || strTemp.length() == 0){
		   			strTemp = (String)vRetResult.elementAt(i+5);
		   		}else{
					strTemp += "<br> (" +  (String)vRetResult.elementAt(i+5) + " - " +
									       (String)vRetResult.elementAt(i+6) + ")";
				}
		   %>
      <td class="thinborderBOTTOM"><font size="1"><%=strTemp%></font></td>
      <td class="thinborderBOTTOM"><font size="1"><%=(String)vRetResult.elementAt(i+8)%> - <br>
            <%=(String)vRetResult.elementAt(i+9)%></font></td>
      <td class="thinborderBOTTOM"><font size="1">&nbsp;&nbsp;</font><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),false)%></font></td>
      <%
				strTemp = (String)vRetResult.elementAt(i+10);
				if(strTemp.equals("APPROVE")){ 
					strTemp = "<strong><font color=#0000FF>" + strTemp + "</font></strong>";
				}else if (strTemp.equals("DISAPPROVE")){
					strTemp = "<strong><font color=#FF0000>" + strTemp + "</font></strong>";
				}
			%>
      <td class="thinborderBOTTOM"><font size="1"><%=strTemp%></font></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+3);
				strTemp = WI.getStrValue(strTemp,"&nbsp;");
			%>
 			<td width="8%" class="thinborderBOTTOM"><font size="1"><%=strTemp%></font></td>
 	    <!--
      <td width="5%" class="thinborderBOTTOM">&nbsp;

	  <a href='javascript:ViewRecord("<%//=(String)vRetResult.elementAt(i+14)%>")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>
	  </td>
	  -->
      <td width="8%" class="thinborderBOTTOM"><% strTemp = (String)vRetResult.elementAt(i+10);
			   
			 if (iAccessLevel == 2 && !strTemp.equals("APPROVE") 
					&& !strTemp.equals("DISAPPROVE")) {%>
          <input name="image" type="image" 
					onClick='DeleteRecord("<%=(String)vRetResult.elementAt(i+14)%>")' 
					src="../../../images/delete.gif">
          <%}else{%>
        &nbsp;
        <%}%>      </td>
    </tr>
    <% } // end for loop %>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" align="center">
        <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
      </td>
    </tr>
  </table>  
<%}%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="iAction" value="">
<input type="hidden" name="info_index" value="">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
<input type="hidden" name="first_entry" value="1">
<input type="hidden" name="focus_stat">
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>