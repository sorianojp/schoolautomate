<%@ page language="java" import="utility.*,search.SearchEmployee,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	if(WI.fillTextValue("print_page").compareTo("1") == 0) {%>
		<jsp:forward page="./srch_emp_print.jsp" />
		
	<%return;}
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	}
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";
		
///added code for HR/companies.
boolean bolIsSchool = false;
if((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
	
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.		
		
boolean bolMultipleEntry = WI.fillTextValue("multiple_entry").equals("1");
			
%>	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

</style>
</head>
<script language="JavaScript" src="../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../jscript/common.js"></script>
<script language="JavaScript">
function ShowHideOthers(strSelFieldName, strOthFieldName,strTextBoxID)
{
	if( eval('document.search_util.'+strSelFieldName+'.selectedIndex') == 0)
	{
		eval('document.search_util.'+strOthFieldName+'.disabled=false');
		showLayer(strTextBoxID);
	}
	else
	{
		eval('document.search_util.'+strOthFieldName+'.value=\'\'');
		hideLayer(strTextBoxID);
		eval('document.search_util.'+strOthFieldName+'.disabled=true');
	}
	//if dob to is disabled, i am sure, it is hidden. 
	if(document.search_util.dob_to.disabled)
		hideLayer("dob_to_cal_");
	else	
		showLayer("dob_to_cal_");
}
function ReloadPage()
{
	document.search_util.searchEmployee.value = "";
	document.search_util.print_page.value = "";
	document.search_util.submit();
}
function SearchEmployee()
{
	document.search_util.searchEmployee.value = "1";
	document.search_util.print_page.value = "";
	document.search_util.submit();	
}
function ViewDetail(strStudID)
{
//popup window here. 
	var pgLoc = "./stud_info_view.jsp?stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SetIDToCopy(strStudID) {
	document.search_util.id_to_copy.value = strStudID;
}
function CopyIDNumber() {
	if(document.search_util.opner_info.value.length ==0) {
		alert("Proceed copies ID to the caller page. Click Proceed only if search page is called clicking Search ICON.");
		return;
	}
	var opnerObj;
	eval('opnerObj=window.opener.document.'+document.search_util.opner_info.value);
	<%if(bolMultipleEntry){%>
		if(opnerObj.value.length > 0) 
			opnerObj.value = opnerObj.value+","+document.search_util.id_to_copy.value;
		else	
			opnerObj.value = document.search_util.id_to_copy.value;
		return;
	<%}else{%>
		opnerObj.value=document.search_util.id_to_copy.value;
	<%}%>
	
	window.opener.focus();
	<%
	if(strFormName != null && WI.fillTextValue("prevent_reload").length() == 0){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	self.close();
}
function PrintPg() {
	document.search_util.print_page.value = 1;
	document.search_util.submit();
}
function focusID() {
	document.search_util.id_number.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Employees","srch_emp.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
	// allow search employee only if the user is not a student / parent. 
	strTemp = (String)request.getSession(false).getAttribute("userId");
	if(strTemp == null)
		strErrMsg = "You are already logged out. Please login again.";
	else {
		strTemp = dbOP.mapOneToOther("user_table","id_number","'"+strTemp+"'","AUTH_TYPE_INDEX"," and is_valid = 1 and is_del = 0");
		if(strTemp == null || strTemp.equals("4") || strTemp.equals("6"))//student or parent or not having any access
			strErrMsg = "You are not authorized to view Employee search page.";		
	}
	if(strErrMsg != null) {
		dbOP.cleanUP();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
			

//end of authenticaion code.
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=","greater","less"};
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Tenureship","Salary","Emp. Status","Emp. Type","D.O.B"};
String[] astrSortByVal     = {"id_number","user_table.lname","user_table.fname","gender","doe","SALARY_AMT","user_status.status",
								"HR_EMPLOYMENT_TYPE.EMP_TYPE_NAME","dob"};
String[] astrDropListBetween = {"Between","Equal to","Less than","More than"};
String[] astrDropListValBetween = {"BETWEEN","=","greater","less"};//check for between
String[] astrDropListValBetweenAGE = {"BETWEEN","=","less","greater"};//for age, less than and greater than is swapped.

String[] astrMonthList     = {"January","February","March","April","May","June","July","August","September","October","November","December"};
String[] astrMonthListVal  = {"1","2","3","4","5","6","7","8","9","10","11","12"};
int iSearchResult = 0;

SearchEmployee searchEmp = new SearchEmployee(request);
if(WI.fillTextValue("searchEmployee").compareTo("1") == 0){
	vRetResult = searchEmp.searchGeneric(dbOP);
	if(vRetResult == null)
		strErrMsg = searchEmp.getErrMsg();
	else	
		iSearchResult = searchEmp.getSearchCount();
}
boolean bolShowNonEmployeeSetting = false;
if(strSchCode.startsWith("CIT"))
	bolShowNonEmployeeSetting = true;
else {
	strTemp = "select prop_val from read_property_file where prop_name = 'ENABLE_NON_EMPLOYEE_SETTING'";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null && strTemp.equals("0"))
		bolShowNonEmployeeSetting = true;
}

%>
<form action="./srch_emp.jsp" method="post" name="search_util">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SEARCH EMPLOYEE PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;
	  <font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%">Employee ID </td>
      <td width="9%"><select name="id_number_con">
          <%=searchEmp.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="14%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      <td width="9%">Gender</td>
      <td width="47%"> <select name="gender">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("gender").compareTo("1") == 0){%>
          <option value="1" selected>Female</option>
          <%}else{%>
          <option value="1">Female</option>
          <%}if(WI.fillTextValue("gender").compareTo("0") ==0){%>
          <option value="0" selected>Male</option>
          <%}else{%>
          <option value="0">Male</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><select name="lname_con">
          <%=searchEmp.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      <td> <%if(WI.fillTextValue("show_age").compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
%> 
        <!--
	  <input type="checkbox" name="show_age" value="1" <%=strTemp%>>
        Age -->      </td>
      <td> 
        <!--<select name="age_con" onChange='ShowHideOthers("age_con","age_to","age_to_");'>
          <%=searchEmp.constructGenericDropList(WI.fillTextValue("age_con"),astrDropListBetween,astrDropListValBetweenAGE)%> 
        </select>
		<input name="age_fr" type="text" size="3" value="<%=WI.fillTextValue("age_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        &nbsp;&nbsp;&nbsp; 
        <input name="age_to" type="text" size="3" value="<%=WI.fillTextValue("age_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" id="age_to_"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">  -->      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=searchEmp.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      <td>&nbsp;</td>
      <td> 
        <!--<select name="tenur_con" onChange='ShowHideOthers("tenur_con","tenur_to","tenur_to_");'>
          <%=searchEmp.constructGenericDropList(WI.fillTextValue("tenur_con"),astrDropListBetween,astrDropListValBetween)%> 
        </select> <input name="tenur_fr" type="text" size="3" value="<%=WI.fillTextValue("tenur_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        &nbsp;&nbsp;&nbsp; 
        <input name="tenur_to" type="text" size="3" value="<%=WI.fillTextValue("tenur_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" id="tenur_to_" 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> -->      </td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employment Status</td>
      <td colspan="4"> <select name="current_status">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("current_status"), false)%> </select>
        &nbsp;&nbsp;
	
	<% strTemp = WI.fillTextValue("inc_separated");
		if (strTemp.equals("1"))
			strTemp = "checked ";
		else
			strTemp = "";
	%>
     <input name="inc_separated" type="checkbox" value="1" <%=strTemp%>>
        check to include separated employees 
<%if(bolShowNonEmployeeSetting){%>
		&nbsp;&nbsp;&nbsp;
		<input type="checkbox" name="show_non_employee" value="checked" <%=WI.fillTextValue("show_non_employee")%>> Show Only Non-Employee
<%}%>
		</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Position</td>
      <td colspan="2"><select name="emp_type_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME",
		  " from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> 
        </select></td>
      <td valign="top">&nbsp;</td>
      <td class="thinborderALL">
<%if(WI.fillTextValue("fs").length() > 0) {//show only fs search is called.
strTemp = WI.fillTextValue("fs_nodata");
if(strTemp.length() > 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>	  <div style="background-color:#CCCCCC;color:#0000FF;font-weight:bold"><input type="checkbox" name="fs_nodata" value="1"<%=strTemp%>>
        Show employees without Finger Scan DATA</div></td>

<%}%>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>
<% if (bolIsSchool){%> 
	  College <%}else{%>Division<%}%> </td>
      <td colspan="4">
	  <select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
	strTemp = WI.getStrValue(WI.fillTextValue("c_index"),"0");

if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Office/Dept</td>
      <td colspan="4"><select name="d_index">
          <option value="">N/A</option>
          <%
strTemp3 = "";
strTemp3 = WI.fillTextValue("d_index");
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index="+strTemp+" or c_index is null) order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Office/Dept filter </td>
      <td colspan="4"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
        (enter office/dept's first few characters) </td>
    </tr>
<%if(strSchCode.startsWith("TSUNEISHI")){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Team</td>
      <td colspan="4">
	  <select name="team">
          <option value=""> &nbsp;</option>
      <%=dbOP.loadCombo("team_index", "team_name"," from AC_TUN_TEAM where is_valid =1 order by team_name",WI.fillTextValue("team"), false)%> </select>
	  </td>
    </tr>
<%} if (bolIsSchool && false){ %> 
    <tr>
      <td height="24">&nbsp;</td>
      <td colspan="5" class="thinborderTOPLEFTRIGHT" bgcolor="#DDDDDD">
		  SY-TERM : 
			<input name="sy_from" type="text" size="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		  onKeyUp='DisplaySYTo("search_util","sy_from","sy_to")' maxlength=4>
	to
	<input name="sy_to" type="text" size="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		  readonly="yes">
	&nbsp;&nbsp;
		<select name="semester">
		  <%
		strTemp = WI.fillTextValue("semester");
		if(strTemp.compareTo("1") ==0){%>
		  <option value="1" selected>1st Sem</option>
		  <%}else{%>
		  <option value="1">1st Sem</option>
		  <%}if(strTemp.compareTo("2") ==0){%>
		  <option value="2" selected>2nd Sem</option>
		  <%}else{%>
		  <option value="2">2nd Sem</option>
		  <%}
		  
		  if (!strSchCode.startsWith("CPU")) { 
		    if(strTemp.compareTo("3") ==0){%>
		  <option value="3" selected>3rd Sem</option>
			<%}else{%>
		  <option value="3">3rd Sem</option>
		  <%}
		  }
		  
		  if(strTemp.compareTo("0") ==0){%>
		  <option value="0" selected>Summer</option>
		  <%}else{%>
		  <option value="0">Summer</option>
		  <%}%>
		</select>
		&nbsp; 
<%
strTemp = WI.fillTextValue("faculty_active");
if(strTemp.length() > 0)
	strTemp = " checked";
%>		<input type="checkbox" name="faculty_active"<%=strTemp%>> Employee Teaching this SY/Term
		&nbsp;&nbsp;
<%
strTemp = WI.fillTextValue("faculty_inactive");
if(strTemp.length() > 0)
	strTemp = " checked";
%>		<input type="checkbox" name="faculty_inactive"<%=strTemp%>> Employee Not teaching this SY/Term		</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td colspan="5" class="thinborderBOTTOMLEFTRIGHT" bgcolor="#DDDDDD">&nbsp;</td>
    </tr>
<%}else {%>
    <tr>
      <td height="24">&nbsp;</td>
      <td colspan="5" class="thinborderTOPLEFTRIGHT" bgcolor="#DDDDDD">
		  Date of Employment: 
		  <input name="doe_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("doe_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('search_util.doe_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../images/calendar_new.gif" border="0"></a>
		
		to
		
		<input name="doe_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("doe_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('search_util.doe_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../images/calendar_new.gif" border="0"></a>
		  
		  </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td colspan="5" class="thinborderBOTTOMLEFTRIGHT" bgcolor="#DDDDDD">
	<%if(WI.fillTextValue("show_tenur").compareTo("1") ==0)
		strTemp = "checked";
	else
		strTemp = "";
	%> 
	  <input type="checkbox" name="show_tenur" value="1" <%=strTemp%>> Display Date Of Employment
		      
		</td>
    </tr>
<%}%> 
    <tr> 
      <td height="10" colspan="6"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="25%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=searchEmp.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
        </select> <br> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="24%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=searchEmp.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> <br> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="40%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=searchEmp.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> <br> <select name="sort_by3_con">
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
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">
	  <input type="image" src="../images/refresh.gif" onClick="SearchEmployee();">
        <font size="1">Click to search Employee.</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4"><strong><font color="#FF0000">NOTE:</font></strong> <font color="#0000FF">To 
        display all employees, click PROCEED button without specifying any search 
        parameter. Clicking the check box shows or hides values in report below</font></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><div align="right"><a href="javascript:PrintPg();"><img src="../images/print.gif" width="58" height="26" border="0"></a> 
          <font size="1">click to print result</font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF EMPLOYEE RECORDS</font></strong></div></td>
    </tr>
    <tr>
      <td width="66%" ><b> TOTAL RESULT: <%=iSearchResult%> - Showing(<%=searchEmp.getDisplayRange()%>)</b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/searchEmp.defSearchSize;
		if(iSearchResult % searchEmp.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
          <select name="jumpto" onChange="SearchEmployee();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
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
          <%}%>
        </div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="13%" height="25" ><div align="center"><strong><font size="1">EMPLOYEE 
          ID</font></strong></div></td>
      <td width="24%"><div align="center"><strong><font size="1">NAME (LNAME,FNAME 
          MI) </font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">GENDER</font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1">EMPLOYMENT STATUS</font></strong></div></td>
      <td width="9%"><div align="center"><strong><font size="1">EMPLOYMENT TYPE</font></strong></div></td>
      <td width="30%"><div align="center"><strong><font size="1">
	  <% if (bolIsSchool) {%> COLLEGE/ OFFICE <%}else{%>DIVISION / DEPT<%}%> </font></strong></div></td>
<%
if(WI.fillTextValue("show_dob").compareTo("1") ==0){%>
      <td width="5%"><div align="center"><strong><font size="1">DOB</font></strong></div></td>
<%}if(WI.fillTextValue("show_b_month").compareTo("1") ==0){%>
      <td width="5%"><div align="center"><strong><font size="1">BIRTH MONTH</font></strong></div></td>
<%}if(WI.fillTextValue("show_age").compareTo("1") ==0){%>
      <td width="5%"><div align="center"><strong><font size="1">AGE</font></strong></div></td>
<%}if(WI.fillTextValue("show_tenur").compareTo("1") ==0){%>
      <td width="5%"><div align="center"><strong><font size="1">DOE</font></strong></div></td>
<%}if(WI.fillTextValue("show_salary").compareTo("1") ==0){%>
      <td width="5%"><div align="center"><strong><font size="1">SALARY</font></strong></div></td>
<%}%>
      <td width="5%"><strong><font size="1">SELECT</font></strong></td>
    </tr>
<%
for(int i = 0 ; i < vRetResult.size(); i +=13){%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td height="25"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td>
	  <% 
	  strTemp = (String) vRetResult.elementAt(i + 6);
	  
	  if (strTemp != null) 
	  	strTemp += WI.getStrValue((String)vRetResult.elementAt(i+7),"/","","");
	  else
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;");
   	  %> <%=strTemp%> 
	  </td>
      <%
if(WI.fillTextValue("show_dob").compareTo("1") ==0){%>
      <td width="5%">
<div align="center"><%=(String)vRetResult.elementAt(i + 8)%></div></td>
      <%}if(WI.fillTextValue("show_b_month").compareTo("1") ==0){%>
      <td width="5%">
<div align="center"><%=(String)vRetResult.elementAt(i + 9)%></div></td>
      <%}if(WI.fillTextValue("show_age").compareTo("1") ==0){%>
      <td width="5%">
<div align="center"><%=(String)vRetResult.elementAt(i + 10)%></div></td>
      <%}if(WI.fillTextValue("show_tenur").compareTo("1") ==0){%>
      <td width="5%">
<div align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 11))%></div></td>
      <%}if(WI.fillTextValue("show_salary").compareTo("1") ==0){%>
      <td width="5%">
<div align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 12),"&nbsp;")%></div></td>
<%}%>
      <td><div align="center"><font size="1">&nbsp; 
          <input type="radio" name="radiobutton" value="<%=(String)vRetResult.elementAt(i + 1)%>" 
		  	onClick='SetIDToCopy("<%=(String)vRetResult.elementAt(i + 1)%>");'>
          </font></div></td>
    </tr>
<%}//end of for loop to display employee information.%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25"><div align="right">
	  <a href="javascript:CopyIDNumber();"><img src="../images/form_proceed.gif" border="0"></a>
	  <font color="#0000FF" size="1">Click to copy Employee ID </font></div></td>
      <td width="31%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();">
	  	<img src="../images/print.gif" width="58" height="26" border="0"></a> 
          <font size="1">click to print result</font></div></td>
    </tr>
  </table>
<%}//only if vRetResult not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="selectValue">
<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
<input type="hidden" name="id_to_copy">
<!--`opner info is formname.fieldname of the opener -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
<input type="hidden" name="print_page">

<!-- search finger scan information -->
<input type="hidden" name="fs" value="<%=WI.fillTextValue("fs")%>">

<!-- if multiple_entry=1 , there is multiple entry in the field, so
i have to append and do not close the window and no reloading of parent wnd -->
<input type="hidden" name="multiple_entry" value="<%=WI.fillTextValue("multiple_entry")%>">

<input type="hidden" name="prevent_reload" value="<%=WI.fillTextValue("prevent_reload")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>