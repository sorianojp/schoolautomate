<%@ page language="java" import="utility.*,java.util.Vector, eDTR.RestDays" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
 String[] strColorScheme = CommonUtil.getColorScheme(7);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
.fontsize10 {		font-size:11px;
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
	//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
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
		
	if(eval(vItems) > 16){
		document.form_.copy_all.value = "1";
		document.form_.print_page.value = "";
		document.form_.searchEmployee.value = "1";		
		this.SubmitOnce('form_');
	}else{
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.hour_worked_'+i+'.value=document.form_.hour_worked_1.value');			
	}
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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

function showRDDateRange(){	
	if (document.form_.use_date_range.checked){
		document.getElementById("rd_date_range_row").style.display = "table-row";
		document.form_.rest_date.disabled = true;
		
	}else{		
		document.getElementById("rd_date_range_row").style.display = "none";
		document.form_.rest_date.disabled = false;
	}
}



</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strHasWeekly = null;
//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./batch_rest_day_print.jsp" />
	<% 
return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT-Rest Days(batch)","batch_rest_day.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");		
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
boolean bolIsRestricted = false;//if restricted, can only use the emplyee from same college/dept only.
if(request.getSession(false).getAttribute("wh_restricted") != null)
	bolIsRestricted = true;

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;
if(!bolIsRestricted) { 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(),
														"batch_rest_day.jsp");
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

	Vector vRetResult = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	RestDays rd = new RestDays();
	int iSearchResult = 0;
	int i = 0;
	String strPayrollPeriod  = null;
	String strDivision = null;
	if(bolIsSchool)
		strDivision = "College";
	else
		strDivision = "Division";
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strDivision,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};
		
	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0){
		if(rd.operateOnRestDayBatch(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = rd.getErrMsg();
		} else {
			if(strPageAction.equals("1"))
				strErrMsg = "Schedule successfully posted.";		
		}
	}
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = rd.operateOnRestDayBatch(dbOP,request, 4);
		if(vRetResult == null)
			strErrMsg = rd.getErrMsg();
		else
			iSearchResult = rd.getSearchCount();
	}	
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="batch_rest_day.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr bgcolor="#A49A6A"> 
				<td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
					REST DAY BATCH SETTING PAGE ::::</strong></font></td>
			</tr>
	</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="770" height="10">&nbsp;</td>
    </tr>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">Effective date </td>
      <td width="77%" colspan="3">
			<%
				strTemp = WI.fillTextValue("valid_fr");
			%>
        <input name="valid_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.valid_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> to
        <%
				strTemp = WI.fillTextValue("valid_to");
				%><input name="valid_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        
        <a href="javascript:show_calendar('form_.valid_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> <font size="1">(for valid rest days, leave &quot;effective date to&quot; 
      value empty)</font></td>
    </tr>
    
    <tr>
      <td height="24">&nbsp;</td>
      <td>Rest Days(in week day)</td>
      <td colspan="3"><select name="week_day">
        <option value="">N/A</option>
        <%	
				strTemp = WI.fillTextValue("week_day");
				
				if(strTemp.compareTo("0") == 0) {%>
        <option value="0" selected>Sunday</option>
        <%}else{%>
        <option value="0">Sunday</option>
        <%}if(strTemp.compareTo("1") == 0) {%>
        <option value="1" selected>Monday</option>
        <%}else{%>
        <option value="1">Monday</option>
        <%}if(strTemp.compareTo("2") == 0) {%>
        <option value="2" selected>Tuesday</option>
        <%}else{%>
        <option value="2">Tuesday</option>
        <%}if(strTemp.compareTo("3") == 0) {%>
        <option value="3" selected>Wednesday</option>
        <%}else{%>
        <option value="3">Wednesday</option>
        <%}if(strTemp.compareTo("4") == 0) {%>
        <option value="4" selected>Thursday</option>
        <%}else{%>
        <option value="4">Thursday</option>
        <%}if(strTemp.compareTo("5") == 0) {%>
        <option value="5" selected>Friday</option>
        <%}else{%>
        <option value="5">Friday</option>
        <%}if(strTemp.compareTo("6") == 0) {%>
        <option value="6" selected>Saturday</option>
        <%}else{%>
        <option value="6">Saturday</option>
        <%}%>
      </select></td>
    </tr>
		<%
			strTemp2 = WI.fillTextValue("use_date_range");			
			strTemp2 = strTemp2.equals("1")?"disabled":"";
			
		%>	
    <tr style="<%=strTemp2%>" id="single_restday">
      <td height="24">&nbsp;</td>
      <td>Rest Days(specific date)</td>
      <td>	  		
			<%
				strTemp = WI.fillTextValue("rest_date");
			%>
        <input name="rest_date" type="text" size="12" maxlength="12" readonly="yes" <%=strTemp2%> value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.rest_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
		&nbsp;&nbsp;
		<%
			strTemp = WI.fillTextValue("use_date_range");
			if(strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = "";
			%>	
				<label for="one_chk_opt_">
				<input name="use_date_range" type="checkbox"  value="1"  
				onClick="showRDDateRange()" tabindex="-1" <%=strTemp%>> 
        <font size="1">Use date range</font> 
				</label>
		</td>
		
    </tr>	
	<!-- start of rest day range sul..08132012-->
		<%
			strTemp2 = WI.fillTextValue("use_date_range");
			if(!strTemp2.equals("1"))
				strTemp2 = "display:none";
			else
				strTemp2 = "display:table-row";
		%>	
		<tr style="<%=strTemp2%>" id="rd_date_range_row">		
			  <td width="3%" height="25">&nbsp;</td>
			  <td width="20%">Rest date range </td>
			  <td width="77%" colspan="3">
					<%
						strTemp = WI.fillTextValue("restdate_fr");
					%>
				<input name="restdate_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.restdate_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> to
					<%
						strTemp = WI.fillTextValue("restdate_to");
					%><input name="restdate_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">				
				<a href="javascript:show_calendar('form_.restdate_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
			</tr>
	<!--  end of rest day range -->	
	
    <tr>
      <td height="21" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Status</td>
      <td colspan="3"><select name="pt_ft" onChange="ReloadPage();">
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
      <td colspan="3"> <select name="c_index" onChange="ReloadPage();">
<%if(!bolIsRestricted) {%>
          <option value="">All</option>
<%}
if(bolIsRestricted)
	strCollegeIndex = WI.getStrValue((String)request.getSession(false).getAttribute("info_faculty_basic.c_index"), "0");//get the college of logged in user.
if(bolIsRestricted)
	strErrMsg = " and c_index = "+ strCollegeIndex;//get the college of logged in user.
else	
	strErrMsg = "";

if(strCollegeIndex.equals("0"))
	strCollegeIndex = "";
	%>

          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0 "+strErrMsg, strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3">
	  	<select name="d_index" onChange="ReloadPage();">
<%if(!bolIsRestricted) {%>
          <option value="">All</option>
<%}

if(bolIsRestricted)
	strErrMsg = " and d_index = "+ WI.getStrValue((String)request.getSession(false).getAttribute("info_faculty_basic.d_index"), "0");//get the college of logged in user.
else	
	strErrMsg = "";
%>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index is null or c_index = 0)"+strErrMsg+" order by d_code", WI.fillTextValue("d_index"),false)%> 
          <%}else{%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex +strErrMsg+" order by d_code", WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select>	  </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Salary Basis</td>
      <td height="10" colspan="3"><select name="salary_base">
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
      <td height="10" colspan="3"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
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
					<%=rd.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
					<%=rd.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>      
				</select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>        
					<%=rd.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
        <font size="1">click to display employee list to print.</font></td>
    </tr>
  </table>    
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
                  <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
      <%}%>
    </tr>
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/rd.defSearchSize;		
	if(iSearchResult % rd.defSearchSize > 0) ++iPageCount;
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
      <td height="20" colspan="6" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    <tr>
      <td width="3%" class="thinborder">&nbsp;</td>
      <td width="5%" class="thinborder">&nbsp;</td> 
      <td width="34%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="29%" align="center" class="thinborder"><strong><font size="1">SET REST DAYS </font></strong></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
        </strong>
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">
      </font></td>
    </tr>
    <% 	int iCount = 1;
			Vector vRestDay = null;
			int iRd = 0;
			String strRestDay = null;
			String[] astrWeekDay = {"Sundays", "Mondays", "Tuesdays", "Wednesdays","Thursdays" ,"Fridays", "Saturdays"};
	   for (i = 0; i < vRetResult.size(); i+=8,iCount++){
		 	vRestDay = (Vector)vRetResult.elementAt(i+7);
			strRestDay = null;
		 %>
    <tr>
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
			<input type="hidden" name="id_number_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
			<% 
			if(vRestDay != null && vRestDay.size() > 0){
				for(iRd = 0; iRd < vRestDay.size(); iRd+=4){
					strTemp2 = (String) vRestDay.elementAt(iRd);
					if(strTemp2 != null && strTemp2.length() > 0){
						if(strRestDay == null)
							strRestDay = "Date : " + strTemp2;
						else
							strRestDay += "<br>&nbsp;Date : " + strTemp2;						
					}else{
						strTemp = (String) vRestDay.elementAt(iRd + 1);
						strTemp = astrWeekDay[Integer.parseInt(strTemp)];
						strTemp += ": " + (String) vRestDay.elementAt(iRd + 2) + " - " + WI.getStrValue((String) vRestDay.elementAt(iRd + 3),"Present");
						if(strRestDay == null){
							strRestDay = strTemp;
						}else{
							strRestDay += "<br>&nbsp;" + strTemp;					
						}
					}				
				}
			}
			%>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strRestDay)%></td>
			<%
				strTemp = WI.fillTextValue("save_"+iCount);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
			%>
      <td align="center" class="thinborder">
			<input type="checkbox" name="save_<%=iCount%>" value="1" <%=strTemp%> tabindex="-1">			</td>
    </tr>
    <%} //end for loop%>
    <tr>
      <td height="25">&nbsp; </td>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="6" align="center">
					<%if(iAccessLevel > 1){%>
				<!--
					<a href='javascript:SaveData();'><img src="../../../images/save.gif" border="0" id="hide_save"></a> 
					-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
				<font size="1">Click to save entries</font> 
        <!--
					<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
					-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
				<font size="1"> click to cancel or go previous</font>
				<%}%>  
			</td>
    </tr>
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
<% } // end vRetResult != null && vRetResult.size() > 0 %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
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