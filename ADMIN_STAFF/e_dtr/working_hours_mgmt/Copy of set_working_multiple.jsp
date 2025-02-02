<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function ReloadPage()
{
	document.dtr_op.page_action.value="";
	document.dtr_op.submit();
}

function ChangeWorkingHrType(isRegularHr)
{
	if(isRegularHr ==1)
	{
		document.dtr_op.regular_wh.checked = true;
		document.dtr_op.specify_wh.checked = false;
		document.dtr_op.is_flex.checked = false;
		document.dtr_op.is_nonDTR.checked = false;
		document.dtr_op.iStatus.value=1;
	}
	else if  (isRegularHr==0)
	{
		document.dtr_op.regular_wh.checked = false;
		document.dtr_op.specify_wh.checked = true;
		document.dtr_op.is_flex.checked = false;
		document.dtr_op.is_nonDTR.checked = false;
		document.dtr_op.iStatus.value = 2;
		
	}else if (isRegularHr==2){
		document.dtr_op.regular_wh.checked = false;
		document.dtr_op.specify_wh.checked = false;
		document.dtr_op.is_flex.checked = true;
		document.dtr_op.is_nonDTR.checked = false;
		document.dtr_op.iStatus.value = 3;
	}else if (isRegularHr == 3){
		document.dtr_op.regular_wh.checked = false;
		document.dtr_op.specify_wh.checked = false;
		document.dtr_op.is_flex.checked = false;
		document.dtr_op.is_nonDTR.checked = true;
		document.dtr_op.iStatus.value = 4;
	}
	
	document.dtr_op.page_action.value=11;
	this.SubmitOnce('dtr_op');
}

function ViewRecord(){
	document.dtr_op.page_action.value=1;
}

function AddRecord(){
	document.dtr_op.page_action.value=2;
	document.dtr_op.save_.src ="../../../images/blank.gif";
	document.dtr_op.submit();
}

function RemoveEmployee(removeIndex)
{ // remove singe employee from list.. 
	document.dtr_op.remove_index.value = removeIndex;
	document.dtr_op.page_action.value  = 12;
	document.dtr_op.submit();
}

function DeleteEmpType(strEmpTypeIndex){
	document.dtr_op.del_emp_type_index.value = strEmpTypeIndex;
	document.dtr_op.page_action.value=11;
	document.dtr_op.submit();
}
	

function AddPosition(){
	 var strEmpIndex = document.dtr_op.emp_type_index_.value;
	 
	 if (document.dtr_op.emp_type_index.selectedIndex == 0){
	 	alert ("Please select position of employees");
		return;
	 }else{
	 	if (strEmpIndex.length > 0){
		 document.dtr_op.emp_type_index_.value =  strEmpIndex + "," + 
			document.dtr_op.emp_type_index[document.dtr_op.emp_type_index.selectedIndex].value;
		}else{
		 document.dtr_op.emp_type_index_.value =  strEmpIndex + 
			document.dtr_op.emp_type_index[document.dtr_op.emp_type_index.selectedIndex].value;
		}
	 }
	 
	 document.dtr_op.add_.src = "../../../images/blank.gif";
	 document.dtr_op.page_action.value ="10";
	 document.dtr_op.submit();
}

-->
</script>
<body bgcolor="#D2AE72" >
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strPrepareToEdit = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","set_working_multiple.jsp");
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
														"set_working_multiple.jsp");	
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
	WorkingHour wh = new WorkingHour();
	Vector vRetResult = null;
	Vector vRetEmployees = null;
	Vector vPositions = null;
	String strEmpTypeIndex_ = null;
	
	int i  = 0; // index;
	int iListCount = 0;
	
	String[] astrConvertWeekDay= {"SUNDAY","MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};	
	String[] astrConverAMPM = {"AM","PM"};
	
	if(WI.fillTextValue("page_action").equals("1")){
		vRetResult = wh.operateOnEmployeeWH(dbOP, request,1);
		strErrMsg = wh.getErrMsg();
	}else if(WI.fillTextValue("page_action").compareTo("2")==0){
		vRetResult = wh.operateOnEmployeeWH(dbOP, request,2);
		strErrMsg = wh.getErrMsg();
		
		if (strErrMsg == null)  
			strErrMsg = "Work Schedule added successfully." ;
		
	}else if(WI.fillTextValue("page_action").compareTo("3")==0){
		vRetResult = wh.operateOnEmployeeWH(dbOP,request,3);
		strErrMsg = wh.getErrMsg();
		if (strErrMsg == null)  strErrMsg = "Work Schedule deleted successfully ." ;
	}
	
	if(WI.fillTextValue("non_EDTR").length() > 0) {
		if(wh.removeNonEDTRWH(dbOP, WI.fillTextValue("non_EDTR"), 
				(String)request.getSession(false).getAttribute("login_log_index")))
			strErrMsg = "Working hour information removed successfully.";
		else	
			wh.getErrMsg();
	}
	
	if (WI.fillTextValue("page_action").equals("10") ||
			WI.fillTextValue("page_action").equals("11") ||
			WI.fillTextValue("page_action").equals("12")) { 
		boolean bolGetOnlyPositions = false;
		
		if (WI.fillTextValue("page_action").equals("11") ||
			WI.fillTextValue("page_action").equals("12"))
			bolGetOnlyPositions = true;
			
		if (WI.fillTextValue("emp_type_index_").length() > 0) { 
			vRetEmployees = wh.getEmployeesDataWH(dbOP, request,bolGetOnlyPositions);
			if (vRetEmployees == null) 
				strErrMsg = wh.getErrMsg();
			
			vPositions = (Vector)vRetEmployees.elementAt(0);
			for (i = 0; i < vPositions.size(); i+=2){
				if (strEmpTypeIndex_ == null) 
					strEmpTypeIndex_ = (String)vPositions.elementAt(i+1);
				else
					strEmpTypeIndex_ += "," + (String)vPositions.elementAt(i+1);
			}
		}
	}

%>	
<form action="./set_working_multiple.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          WORKING HOURS MGMT - SET WORKING HOURS PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25"><strong><font size=2>&nbsp;<%=WI.getStrValue(strErrMsg)%>&nbsp;</font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="14%" height="30" align="right">Position : &nbsp;&nbsp;</td>
      <td width="30%"><select name="emp_type_index">
        <option value="">Select Position </option>
        <%=dbOP.loadCombo("emp_type_index","emp_type_name",
					" from hr_employment_type where is_del = 0 " +
					WI.getStrValue(strEmpTypeIndex_," and emp_type_index not in (",")","") + 
					" and exists (select emp_type_index from info_faculty_basic " + 
					" where info_faculty_basic.emp_type_index = hr_employment_type.emp_type_index " + 
					" and is_del = 0 and not exists (select user_index from edtr_wh  " + 
					" where (eff_date_to is null or eff_date_to >'" + WI.getTodaysDate() + "') and  " + 
					" edtr_wh.user_index = info_faculty_basic.user_index  " + 
					" and is_valid = 1 and is_del = 0)) " + 
					" order by emp_type_name",WI.fillTextValue("emp_type_index"),false)%>
      </select></td>
      <td width="56%"><a href="javascript:AddPosition()"><img src="../../../images/add.gif" border=0  name="add_"></a></td>
    </tr>
  </table>
<% if (vRetEmployees != null) {
	
	vPositions = (Vector)vRetEmployees.remove(0);
	i = 0;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="6" bgcolor="#F8F3E4" class="thinborder">&nbsp;&nbsp;<strong>Positions Added : </strong></td>
    </tr>
<% while (i < vPositions.size()) {%> 
    <tr>
      <td width="7%" height="25" align="right" class="thinborder">&nbsp;</td>
      <td width="35%" class="thinborderBOTTOM"><% if (i < vPositions.size()) {%> 
	  		<%=(String)vPositions.elementAt(i++)%>
	  	<%}else{%>&nbsp;<%}%> </td>
      <td width="8%" class="thinborder"><% if (i < vPositions.size()) {%>
        <a href="javascript:DeleteEmpType(<%=(String)vPositions.elementAt(i++)%>)"><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>&nbsp;<%}%> </td>
      <td width="7%" class="thinborder">&nbsp;</td>
      <td width="35%" class="thinborderBOTTOM"><% if (i < vPositions.size()) {%> 
	  		<%=(String)vPositions.elementAt(i++)%>
  	  <%}else{%>&nbsp;<%}%> </td>
      <td width="8%" class="thinborder"><% if (i < vPositions.size()) {%> 
		<a href="javascript:DeleteEmpType(<%=(String)vPositions.elementAt(i++)%>)"><img src="../../../images/delete.gif" border="0"></a>
  	  <%}else{%>&nbsp;<%}%> </td>
    </tr>
<%}%> 
  </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
      <tr>
        <td height="25" colspan="5" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>LIST OF EMPLOYEES </strong></div></td>
      </tr>
      <tr bgcolor="#33CCFF">
        <td width="37%" height="25" class="thinborder"><strong>&nbsp;(ID)&nbsp;&nbsp;EMPLOYEE NAME  </strong></td>
        <td width="8%" class="thinborder"><strong>REMOVE</strong></td>
      </tr>
      <%
strErrMsg = null;

int iRemoveIndex    = Integer.parseInt(WI.getStrValue(WI.fillTextValue("remove_index"),"-1"));
String strDelEmpTypeIndex = WI.fillTextValue("del_emp_type_index");

int iCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("list_count"),"0"));

if (vRetEmployees.size() > 0) {
	iCount += vRetEmployees.size() / 4;
}

	String strIDNumber	   = null;	
	String strUserIndex    = null;
	String strEmpTypeIndex = null;
	String strEmpName	   = null;

for( i=0; i<iCount; ++i)
{

	if(i == iRemoveIndex)
		continue;
	
	if (WI.fillTextValue("page_action").equals("11") && 
		strDelEmpTypeIndex.equals(WI.fillTextValue("emp_type_index"+i))){
		continue;
	}

		strIDNumber     = WI.fillTextValue("user_id"+i);
		strUserIndex    = WI.fillTextValue("user_index"+i);
		strEmpTypeIndex = WI.fillTextValue("emp_type_index"+i);
		strEmpName  	= WI.fillTextValue("emp_name"+i);
	
		if(strIDNumber.length() ==0) {
			strUserIndex    = (String)vRetEmployees.remove(0);
			strIDNumber     = (String)vRetEmployees.remove(0);
			strEmpName  	= (String)vRetEmployees.remove(0);
			strEmpTypeIndex = (String)vRetEmployees.remove(0);
		}
	%>
      <input type="hidden" name="user_id<%=iListCount%>" value="<%=strIDNumber%>">
      <input type="hidden" name="user_index<%=iListCount%>" value="<%=strUserIndex%>">
      <input type="hidden" name="emp_type_index<%=iListCount%>" value="<%=strEmpTypeIndex%>">
      <input type="hidden" name="emp_name<%=iListCount%>" value="<%=strEmpName%>">
      <tr>
        <td height="25" class="thinborder">&nbsp;<%=iListCount + 1%>)&nbsp; &nbsp;<%=strIDNumber%> &nbsp; &nbsp;<%=strEmpName%></td>
        <td class="thinborder"><a href='javascript:RemoveEmployee("<%=iListCount%>");' tabindex="-1"><img src="../../../images/delete.gif" border="0"></a></td>
      </tr>
      <%
	//add here to list, it is safe now.
	++iListCount;
}%>
    </table>
    <%}%> 
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="18%">&nbsp;</td>
      <td width="61%">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="3"><u><strong><font color="#FF0000">Working Hours</font></strong></u></td>
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
      <td colspan="3"> 
 <%	vRetResult = wh.getDefaultWHIndex(dbOP,null); 
	if (vRetResult == null || vRetResult.size() == 0) { %>
	 <div align="center"> <font size="3"><strong>No Record of Default working 
          hours</strong></font></div> 
 <%}else{%>
 <br>
 <br> 
	  <table width="75%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr> 
<%	for(i = 0; i < vRetResult.size(); i+=6){ 
	strTemp = (String)vRetResult.elementAt(i);
	if (strTemp == null) 
		strTemp = "N/A Week Day";
	else  
		strTemp = astrConvertWeekDay[Integer.parseInt(strTemp)];
		
	strTemp2 = ((String)vRetResult.elementAt(i+1)) + " - " + 
		((String)vRetResult.elementAt(i+2)) + " / " + 
		((String)vRetResult.elementAt(i+3)) + " - " + ((String)vRetResult.elementAt(i+4));
	%>
            <td width="34%" height="22" class="thinborder">&nbsp;&nbsp;<%=WI.getStrValue(strTemp)%></td>
            <td width="66%" class="thinborder">&nbsp;&nbsp;<%=WI.getStrValue(strTemp2)%></td>
          </tr>
          <%}%>
        </table>
 <br>
 <br>
<%}%>		</td>
    </tr>
    <%}else if(WI.fillTextValue("specify_wh").compareTo("1") ==0){%>
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
        </select> &nbsp;&nbsp;&nbsp; <input name="one_tin_tout" type="checkbox"  value="1" > 
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
        <!-- for now it is not allowed to cross over 24 hour
        <input name="logout_nextday" type="checkbox" id="logout_nextday" value="1">
       <font size="1">employee logout is on the next day</font>  -->      </td>
    </tr>
    <%}if(WI.fillTextValue("is_flex").compareTo("1") ==0){%>
    <tr> 
      <td>&nbsp;</td>
      <td>Days :</td>
      <td colspan="2"><input type="text" name="work_day" value="<%=WI.fillTextValue("work_day")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" OnKeyUP="javascript:this.value=this.value.toUpperCase();"> 
        <font size="1">(M-T-W-TH-F-SAT-S) &nbsp;&nbsp;&nbsp;&nbsp; 
        <!-- for now it is not allowed to have irregular week day.
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
    <%}else if(WI.fillTextValue("is_nonDTR").compareTo("1") ==0){ %>
    <tr> 
      <td>&nbsp;</td>
      <td colspan=3 height=56><div align="center"><strong> <font color="#993333" size="3">Employee(s) 
          will not be required to time in and time out. </font><font color="#993333"><br>
          </font></strong></div></td>
    </tr>
    <%} if ((iAccessLevel > 1) && ((WI.fillTextValue("is_flex").equals("1"))    || 
        (WI.fillTextValue("regular_wh").equals("1")) ||
		(WI.fillTextValue("specify_wh").equals("1")) ||
		(WI.fillTextValue("is_nonDTR").equals("1")))){%>	
    <tr> 
      <td>&nbsp;</td>
      <td height=30>Effective Date From: </td>
      <td height=30>
	  <input name="date_from" type="text" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','date_from','/')"
	  onKeyUP="AllowOnlyIntegerExtn('dtr_op','date_from','/')"
	  value="<%=WI.fillTextValue("date_from")%>" size="10" maxlength="10"> 
		<a href="javascript:show_calendar('dtr_op.date_from');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td height=30>Effective Date To: 
        <input name="date_to" type="text" class="textbox"
		onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','date_to','/')"		
		onKeyUP="AllowOnlyIntegerExtn('dtr_op','date_to','/')"
		value="<%=WI.fillTextValue("date_to")%>" size="10" maxlength="10"> <a href="javascript:show_calendar('dtr_op.date_to');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        <font size="1">(leave empty if still applicable)</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height=10>&nbsp;</td>
      <td height=10>&nbsp;</td>
      <td height=10>&nbsp;</td>
    </tr>
		
<% if (iListCount > 0) {%>  
    <tr> 
      <td height="10" colspan="4"><div align="center">
	  <a href="javascript:AddRecord()"><img src="../../../images/save.gif" border="0" name="save_"></a>
          <font size="1">click to save changes </font> &nbsp; </div></td>
    </tr>
<%}
 }%>
  </table>
  <!-- here lies the great mysteries of and future-->
<table bgcolor="#FFFFFF" width="100%" cellpadding="0" cellspacing="0">
    <tr > 
      <td height="25"s>&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="multiple_entry" value="1">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="">
<input type="hidden" name="iStatus" value="">
<input type="hidden" name="emp_type_index_" value="<%=WI.getStrValue(strEmpTypeIndex_)%>">

<input type="hidden" name="list_count" value="<%=iListCount%>">
<input type="hidden" name="remove_index">
<input type="hidden" name="del_emp_type_index" value="">

<!-- for non-EDTR set user_index if called for nonEDTR remove info-->
<input type="hidden" name="non_EDTR">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
