<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(7);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Set specific date working hours</title>
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

function SearchEmployee(){	
	document.dtr_op.searchEmployee.value="1";
 	this.SubmitOnce("dtr_op");
}


function CancelRecord()
{
	location = "./set_working_day_batch.jsp";
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
	///document.dtr_op.submit();
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

function SaveRecord(){
	document.dtr_op.page_action.value=1;
	document.dtr_op.searchEmployee.value = "1";
//	document.dtr_op.save_.src ="../../../images/blank.gif";
	document.dtr_op.submit();
}

function DeleteRecord(){
	document.dtr_op.page_action.value=0;
	document.dtr_op.searchEmployee.value = "1";
//	document.dtr_op.save_.src ="../../../images/blank.gif";
	document.dtr_op.submit();
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

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","set_working_day_batch.jsp");
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
														"set_working_day_batch.jsp");	
														
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");

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
	WorkingHour wh = new WorkingHour(); 
	Vector vRetResult = null;
	Vector vRetEmployees = null;
	int iSearchResult = 0;
	int i = 0;
	String strCollDiv  = null;
	String[] astrConverAMPM = {"AM","PM"};
	if(bolIsSchool)
		 strCollDiv = "College";
	else
		 strCollDiv = "Division";	
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strCollDiv ,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};		
	int iListCount = 0;

 	if(WI.fillTextValue("page_action").equals("1")){
		if(wh.operateOnWorkingHourBatchDaily(dbOP, request, 1) == null)
			strErrMsg = wh.getErrMsg();
	}else if(WI.fillTextValue("page_action").equals("0")){
		if(wh.operateOnWorkingHourBatchDaily(dbOP, request, 0) == null)
			strErrMsg = wh.getErrMsg();				
	}
	
	if(WI.fillTextValue("searchEmployee").equals("1")){
		vRetEmployees = wh.operateOnWorkingHourBatchDaily(dbOP, request,4);
		if(vRetEmployees == null)
			strErrMsg = wh.getErrMsg();
		else
			iSearchResult = wh.getSearchCount();
	}
%>	
<form action="./set_working_day_batch.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      WORKING HOURS MGMT - SET WORKING HOURS PAGE ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25"><strong><font size=2>&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="3"><u><strong><font color="#FF0000">Working Hours</font></strong></u></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td width="19%"> Working Date : </td>
      <td width="79%" colspan="2"><input name="work_date" type="text" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" 
	   onBlur="style.backgroundColor='white'; AllowOnlyIntegerExtn('dtr_op','work_date','/');"
	   onKeyUp= "AllowOnlyIntegerExtn('dtr_op','work_date','/')"
	    value="<%=WI.fillTextValue("work_date")%>" size="10" maxlength="10">
        <a href="javascript:show_calendar('dtr_op.work_date');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
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
        </select> &nbsp;&nbsp;&nbsp; 
				<label for="one_chk_opt_">
<%
strTemp = WI.fillTextValue("one_tin_tout");
if(strTemp.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%>
				<input name="one_tin_tout" type="checkbox"  value="1"  id="one_chk_opt_"
				onClick="showLunchBreak()" tabindex="-1" <%=strTemp%>> 
        <font size="1">employee has only one time in/time out </font> 
				</label>  </td>
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
			</div>	</td>
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
		<% if ((iAccessLevel > 1)){%>	
    

    <tr>
      <td height="12" colspan="4"><hr size="1" color="#000000"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
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
		<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td><select name="pt_ft" onChange="ReloadPage();">
        <option value="" selected>ALL</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part - time</option>
        <option value="1">Full - time</option>
        <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="0">Part - time</option>
        <option value="1" selected>Full - time</option>
        <%}else{%>
        <option value="0">Part - time</option>
        <option value="1">Full - time</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td width="2%" height="24">&nbsp;</td>
      <td width="24%">Position</td>
			<%
			strTemp = WI.fillTextValue("emp_type_index");
			%>
      <td width="74%"><select name="emp_type_index">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("emp_type_index","emp_type_name",
					" from hr_employment_type where is_del = 0 " +
					//WI.getStrValue(strEmpTypeIndex_," and emp_type_index not in (",")","") + 
					" and exists (select emp_type_index from info_faculty_basic " + 
					" where info_faculty_basic.emp_type_index = hr_employment_type.emp_type_index " + 
					" and is_del = 0 and not exists (select user_index from edtr_wh  " + 
					" where (eff_date_to is null or eff_date_to >'" + WI.getTodaysDate() + "') and  " + 
					" edtr_wh.user_index = info_faculty_basic.user_index  " + 
					" and is_valid = 1 and is_del = 0)) " + 
					" order by emp_type_name",WI.fillTextValue("emp_type_index"),false)%>
      </select></td>
    </tr>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
		
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> <select name="c_index" onChange="SearchEmployee();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td>
	  	<select name="d_index" onChange="SearchEmployee();">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select>	  </td>
    </tr>
    
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Salary Basis</td>
      <td height="10"><select name="salary_base">
        <option value="">ALL </option>
        <% strTemp =  WI.fillTextValue("salary_base");
				if(strTemp.equals("0")){%>
        <option value="0" selected>Monthly rate</option>
        <%}else{%>
        <option value="0">Monthly rate</option>
        <%}if(strTemp.equals("1")){%>
        <option value="1" selected>Daily rate</option>
        <%}else{%>
        <option value="1">Daily rate</option>
        <%}if(strTemp.equals("2")) {%>
        <option value="2" selected>Hourly rate</option>
        <%}else{%>
        <option value="2">Hourly rate</option>
        <%}%>
      </select></td>
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
      <td height="10" colspan="2"><%
	strTemp = WI.fillTextValue("with_schedule");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="SearchEmployee();">
View with specific schedule
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="SearchEmployee();">
View Employees without specific schedule for the day </td>
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
        <%=wh.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=wh.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=wh.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
      <font size="1">click to display employee list</font></td>
    </tr>
  </table>	
<%}%>
<%if(vRetEmployees != null && vRetEmployees.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" colspan="4"><hr size="1"></td>
    </tr>
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/wh.defSearchSize;		
	if(iSearchResult % wh.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr> 
      <td height="10" colspan="4"><div align="right"><font size="2">Jump To page:
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
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="6" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    <tr>
      <td width="4%" class="thinborder">&nbsp;</td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">EMP ID </font></strong></td> 
      <td width="38%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="35%" align="center" class="thinborder"><strong><font size="1">SCHEDULE</font></strong></td>
			<!--
      <td width="8%" align="center" class="thinborder">&nbsp;</td>
			-->
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
        </strong>
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
      </font></td>
    </tr>
    
    <%int iCount = 1;
	   for (i = 0; i < vRetEmployees.size(); i+=25,iCount++){
		 %>
    <tr>
      <td class="thinborder">&nbsp;<%=iCount%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetEmployees.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetEmployees.elementAt(i+2), (String)vRetEmployees.elementAt(i+3),
							(String)vRetEmployees.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="user_index_<%=iCount%>" value="<%=(String)vRetEmployees.elementAt(i)%>">
			<input type="hidden" name="id_number_<%=iCount%>" value="<%=(String)vRetEmployees.elementAt(i+1)%>">
			<input type="hidden" name="wh_index_<%=iCount%>" value="<%=(String)vRetEmployees.elementAt(i+24)%>">
         <%
					 strTemp = "";
						// first login time
						if((String)vRetEmployees.elementAt(i+5) != null){
						strTemp = (String)vRetEmployees.elementAt(i+5) +  ":"  + 
							CommonUtil.formatMinute((String)vRetEmployees.elementAt(i+6)) +
							" " + astrConverAMPM[Integer.parseInt((String)vRetEmployees.elementAt(i+7))] + 
							" - " + (String)vRetEmployees.elementAt(i+8) +  
							":"  + 	CommonUtil.formatMinute((String)vRetEmployees.elementAt(i+9)) + 
							" " + astrConverAMPM[Integer.parseInt((String)vRetEmployees.elementAt(i+10))];

						// second login time
						if ((String)vRetEmployees.elementAt(i+14) != null)
								strTemp += " / " + (String)vRetEmployees.elementAt(i+14) +  ":" + 
								CommonUtil.formatMinute((String)vRetEmployees.elementAt(i+15)) +
								" " + astrConverAMPM[Integer.parseInt((String)vRetEmployees.elementAt(i+16))] + 
								" - " + (String)vRetEmployees.elementAt(i+17) + ":"  + 
								CommonUtil.formatMinute((String)vRetEmployees.elementAt(i+18)) +  
								" " + astrConverAMPM[Integer.parseInt((String)vRetEmployees.elementAt(i+19))];
										 
							if (((String)vRetEmployees.elementAt(i + 11)).equals("1"))
								strTemp +="(next day)";
						}
					%>							
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <!--
			<td align="center" class="thinborder"><strong><a href="javascript:ViewSchedule('<%=(String)vRetEmployees.elementAt(i+1)%>');"><img src="../../../../images/view.gif" width="40" height="31" border="0"></a></strong></td>
			-->
      <td align="center" class="thinborder"> <input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1"> </td>
    </tr>
    <%} //end for loop%>
    <tr>
      <td height="25" colspan="6" align="center">
			<font size="1"> 
				<%if((WI.fillTextValue("with_schedule")).equals("1")){%>
					<input type="button" name="1222" value=" Delete " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
					Click to delete selected
         <%}else{%>
					<input type="button" name="122" value=" Save " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SaveRecord();">
					click to save entries				 
				 <%}%>
        <input type="button" name="1223" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();">
      click to cancel or go previous</font></td>
    </tr>
    <input type="hidden" name="emp_count" value="<%=iCount%>">
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
	<input type="hidden" name="searchEmployee">
	<input type="hidden" name="page_action">	
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
