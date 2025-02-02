<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);

String strTemp2 = null;
//strColorScheme is never null. it has value always.

String strSchCode = (String)request.getSession(false).getAttribute("school_code");

if (strSchCode == null) 
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
	}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.form_.print_page.value="1";
	document.form_.show_list.value="1";
	document.form_.show_all.value="1";
	this.SubmitOnce("form_");
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.show_list.value="1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./hr_stat_trainings_print.jsp" />
<% return;	}
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Trainings","hr_stat_trainings.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Executive Management System","ENROLLMENT",request.getRemoteAddr(),
														null);
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


HRStatsReports hrStat = new HRStatsReports(request);

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"'='","less","greater"};
if(bolIsSchool)
   strTemp = "College";
else
   strTemp = "Division";
String[] astrSortByName    = {strTemp,"Department","Date","Budget","Scope", "Category","Seminar Type"};
String[] astrSortByVal     = {"c_code","d_code","DATE_RANGE_FR","approved_budget","train_scope","is_internal","seminar_type"};
String[] astrCatg  = {"Internal", "External"};

Vector vRetResult = null;

if (WI.fillTextValue("show_list").equals("1")){

	vRetResult = hrStat.hrDemoTrainings(dbOP);
	
	if (vRetResult != null){
		iSearchResult = hrStat.getSearchCount();
	}else{
		strErrMsg = hrStat.getErrMsg();
	}
}
%>
<form action="./hr_stat_trainings.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          REPORTS AND STATISTICS ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td width="15%" height="18">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><div align="center"><strong>EMPLOYMENT DETAILS</strong></div></td>
    </tr>
    <!--
    <tr> 
      <td height="25" class="fontsize10">&nbsp;AY / Term</td>
      <td>
	  <% strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	 %>
	  <input name="sy_from" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="4" maxlength="4" value="<%=strTemp%>"
	  onKeyUp='DisplaySYTo("fa_payment","sy_from","sy_to")'>
        - 
	  <% strTemp = WI.fillTextValue("sy_to");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	 %>
        <input name="sy_to" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="4" maxlength="4" value="<%=strTemp%>"> 
		
        <select name="semester">
          <option value="1"> 1st Sem</option>
          <% 
		strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");		  
		  
		  if (strTemp.equals("2")) {%>
          <option value="2" selected> 2nd Sem</option>
          <%}else{%>
          <option value="2" > 2nd Sem</option>
          <%}if (strTemp.equals("3")) {%>
          <option value="3" selected> 3rd Sem</option>
          <%}else{%>
          <option value="3" > 3rd Sem</option>
          <%}if (strTemp.equals("0")) {%>
          <option value="0" selected> Summer </option>
          <%}else{%>
          <option value="0" > Summer</option>
          <%}%>
        </select></td>
    </tr>
-->
 <%if(bolIsSchool) {%>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Emp. Category</td>
      <td colspan="3"> <select name="emp_catg">
          <option value=""> All</option>
          <%if (WI.fillTextValue("emp_catg").equals("1"))  {%>
          <option value="1" selected> Faculty</option>
          <%}else{%>
          <option value="1"> Faculty</option>
          <%} if (WI.fillTextValue("emp_catg").equals("0"))  {%>
          <option value="0" selected> Non Teaching Personnel</option>
          <%}else{%>
          <option value="0"> Non Teaching Personnel</option>
          <%}%>
        </select></td>
    </tr>
 <%}%>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Employee ID</td>
      <td width="16%"> <input name="emp_id" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" maxlength="16"
		  value="<%=WI.fillTextValue("emp_id")%>">      </td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="64%"><% if (WI.fillTextValue("per_employee").equals("1"))
		  		strTemp = " checked";
			 else
			 	strTemp = "";%>
        <input name="per_employee" type="checkbox"  value="1" <%=strTemp%>>
        <font size="1"> show summary internal/extenal per employee </font></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Position</td>
      <td colspan="3"><select name="emp_type_index">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("emp_type_index", "emp_type_name"," from hr_employment_type where is_del =0 order by emp_type_name",WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"><select name="c_index" onChange="ReloadPage()">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Dept / Office </td>
      <td colspan="3"><select name="d_index">
          <option value=""> &nbsp;</option>
          <%
			if (WI.fillTextValue("c_index").length() > 0) 
				strTemp = "  c_index = " + WI.fillTextValue("c_index");
			else 
				strTemp = "  (c_index is null or c_index  = 0)";

		%>
          <%=dbOP.loadCombo("d_index", "d_name"," from department where "+ strTemp  +" and is_del = 0 order by d_name",WI.fillTextValue("d_index"), false)%> </select></td>
    </tr>
    <tr>
      <td class="fontsize10">&nbsp;Office/Dept filter </td>
      <td colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
        (enter office/dept's first few characters) </td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Emp. Status</td>
      <td colspan="3"><select name="status_index">
          <option value=""> ALL</option>
          <%=dbOP.loadCombo("status_index", "status"," from user_status where IS_FOR_STUDENT = 0  " +
		   " order by status",WI.fillTextValue("status_index"), false)%> </select></td>
    </tr>
<!--
    <tr> 
      <td height="10">&nbsp;</td>
      <td colspan="2"><input type="checkbox" name="active_emp" value="1">
        <font size="1">show only active employees</font></td>
    </tr>
-->
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#F2F0FF">
    <tr> 
      <td width="16%" height="18">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" class="fontsize10"><div align="center"><strong>TRAINING 
          DETAILS</strong></div></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Title of Seminar</td>
      <td><select name="seminar_con">
          <%=hrStat.constructSortByDropList(WI.fillTextValue("seminar_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="seminar" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("seminar")%>" > 
		  <% if (WI.fillTextValue("per_college_summary").equals("1"))
		  		strTemp = " checked";
			 else
			 	strTemp = "";%>
		  <input type="checkbox" name="per_college_summary" value="1" <%=strTemp%>>
		  <font size="1"> show summary per <%if(bolIsSchool){%>College<%}else{%>Division<%}%> </font>	  </td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Training Catg. </td>
      <td><select name="is_internal">
        <option value = "">ALL</option>
        <% strTemp = WI.fillTextValue("is_internal");
		 if (strTemp.equals("0")){%>
        <option value="0" selected>Internal </option>
        <%}else{%>
        <option value="0">Internal </option>
        <%} if (strTemp.equals("1")){%>
        <option value="1" selected>External</option>
        <%}else{%>
        <option value="1">External</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Type</td>
      <td><select name="seminar_type">
                <option value="">ANY</option>
<!--
                <% strTemp = WI.fillTextValue("seminar_type");
if (strTemp.equals("1")){%>
                <option value="1" selected>Official Time </option>
<%}else{%>
                <option value="1">Official Time </option>
<%} if (strTemp.equals("2")){%>
                <option value="2" selected>Official Business</option>
<%}else{%>
                <option value="2">Official Business</option>
<%} if (strTemp.equals("3")){%>
                <option value="3" selected>Representative/Proxy</option>
<%}else{%>
                <option value="3">Representative/Proxy</option>
<%}%>
-->              
		</select>
	  </td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Date </td>
      <td width="84%"><input type="text" name="date_from" class="textbox" onKeyUp="AllowOnlyIntegerExtn('form_','date_from','/')" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_from','/')" size="10" maxlength="10" value="<%=WI.fillTextValue("date_from")%>"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      &nbsp;&nbsp;-- &nbsp;&nbsp; <input type="text" name="date_to" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="10"
		value="<%=WI.fillTextValue("date_to")%>"> <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Duration</td>
      <td><input name="duration" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','duration')" onKeyUp="AllowOnlyFloat('form_','duration')" value="<%=WI.fillTextValue("duration")%>" size="4" maxlength="4"> 
        <select name="duration_index">
          <option value="">&nbsp;Any</option>
          <% strTemp = WI.fillTextValue("duration_index");
		    if (strTemp.equals("0")) {%>
          <option value="0" selected>Hours</option>
          <%}else{%>
          <option value="0" >Hours</option>
          <%}if (strTemp.equals("1")) {%>
          <option value="1" selected>Days</option>
          <%}else{%>
          <option value="1" >Days</option>
          <%}if (strTemp.equals("2")) {%>
          <option value="2" selected>Weeks</option>
          <%}else{%>
          <option value="2" >Weeks</option>
          <%}if (strTemp.equals("3")) {%>
          <option value="3" selected>Months</option>
          <%}else{%>
          <option value="3" >Months</option>
          <%}if(strTemp.equals("4")) {%>
          <option value="4" selected>Years</option>
          <%}else{%>
          <option value="4" >Years</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Venue</td>
      <td><select name="venue_con">
          <%=hrStat.constructSortByDropList(WI.fillTextValue("venue_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="venue" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("venue")%>">      </td>
    </tr>
<% if (strSchCode.startsWith("CPU")) {%> 
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Place</td>
      <td><select name="place_con">
          <%=hrStat.constructSortByDropList(WI.fillTextValue("place_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="place" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="256" value="<%=WI.fillTextValue("place")%>">      </td>
    </tr>
<%}%> 
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Approved Budget</td>
      <td><select name="approved_budget_con" id="approved_budget_con">
          <%=hrStat.constructSortByDropList(WI.fillTextValue("approved_budget_con"),astrDropListGT,astrDropListValGT)%> </select> <input name="approved_budget" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" maxlength="16"
		  onKeyUp="AllowOnlyFloat('form_','approved_budget')" value="<%=WI.fillTextValue("approved_budget")%>"> &nbsp;
		  <% if (WI.fillTextValue("university_funded").equals("1")) 
		  		strTemp = "checked";
			 else
			 	strTemp = ""; %>
		  <%if(bolIsSchool){%>
			  <input type="checkbox" name="university_funded" value="1" <%=strTemp%>>
			  <font size="1">check to show only university funded </font> 
		  <%}%>
		  
		  <% if (WI.fillTextValue("show_total_budget").equals("1")) 
		  		strTemp = "checked";
			 else
			 	strTemp = ""; %>  
		  <input type="checkbox" name="show_total_budget" value="1" <%=strTemp%>>
		  <font size="1">show TOTAL In Report </font></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Scope </td>
      <td><select name="seminar_scope">
          <option value="">Any</option>
          <%=dbOP.loadCombo("train_scope_index","train_scope"," FROM hr_preload_training_scope order by train_scope",WI.fillTextValue("seminar_scope"),false)%> </select></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td  width="5%" height="25">&nbsp;</td>
      <td width="10%">Sort by</td>
      <td width="21%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="20%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="19%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="25%"><select name="select">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
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
      <td><select name="select2">
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
      <td height="18" colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:showList()"%><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<% 
Vector vPerCollege = null;
Vector vSummary = null;
if (vRetResult != null && vRetResult.size() > 0) {
	 vSummary = (Vector)vRetResult.elementAt(0);
	 vPerCollege = (Vector)vRetResult.elementAt(1);
%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">
<% if (WI.fillTextValue("show_all").length() > 0) strTemp = "checked";
else strTemp ="";%>	  
	  <input type="checkbox" name="show_all" value="1" <%=strTemp%>>Check to show all </td>
      <td height="25" align="right">&nbsp;
 
	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="49%" height="25"><b>&nbsp;TOTAL RESULT : <%=iSearchResult%> 
	  	<% if (WI.fillTextValue("show_all").length() ==0 ) {%>
			 - Showing(<%=hrStat.getDisplayRange()%>)
		<%}%>
			 </b></td>
      <td width="51%">&nbsp;
        <%
		if (WI.fillTextValue("show_all").length() == 0){
		
			int iPageCount = iSearchResult/hrStat.defSearchSize;
			if(iSearchResult % hrStat.defSearchSize > 0) ++iPageCount;

			if(iPageCount > 1)
			{%>
    	    <div align="right">Jump To page: 
	          <select name="jumpto" onChange="showList();">
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
          </select></div>
          <%}
		  }// end if (WI.fillTextValue("show_all")%>
		  
		  
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="13%" height="25"  class="thinborder"><strong><font size="1">EMP NAME </font></strong></td>
      <td width="12%"  class="thinborder"><div align="center"><font size="1"><strong>OFFICE 
      UNIT </strong></font></div></td>
      <td width="22%" align="center" class="thinborder"><font size="1"><strong>TITLE 
        OF SEMINAR / TRAINING</strong></font></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>DATE<br>
      (DURATION )</strong></font></div></td>
      <td width="20%" class="thinborder"><font size="1"><strong>
	  VENUE <% if(strSchCode.startsWith("CPU")){%> (PLACE) <%}%> </strong></font></td>
      <td width="11%" class="thinborder"><font size="1"><strong>APPROVED BUDGET</strong></font></td>
      <td width="10%" class="thinborder"><font size="1"><strong>CATG/SCOPE</strong></font></td>
    </tr>
    <% 	
	String[] astrConvertDurationUnit={" hour(s)", " day(s)", " week(s)", " month(s)", " year(s)"};
//	System.out.println(vRetResult);
	double dTotalBudget = 0d;


	for (int i=2; i < vRetResult.size(); i+=17){ %>
    <tr> 
      <td height="23" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+12),
	  													(String)vRetResult.elementAt(i+13),
														(String)vRetResult.elementAt(i+14),4)%></td>
	  <% strTemp = (String)vRetResult.elementAt(i+1);
	  	  if (strTemp == null) 
		  	strTemp = (String)vRetResult.elementAt(i+2);
		  else 
		  	strTemp += WI.getStrValue((String)vRetResult.elementAt(i+2)," :: ","","");
	  %>
	  
      <td class="thinborder"> <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+9) + WI.getStrValue((String)vRetResult.elementAt(i+10)," - " ,"","")%> 
	 <% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6),"<br> Duration : ","","");
	    if (strTemp.length() > 0) {
			if ((String)vRetResult.elementAt(i+7) != null) 
				strTemp +=  astrConvertDurationUnit[Integer.parseInt((String)vRetResult.elementAt(i+7))];
		}%> <%=strTemp%>	  </td>
	 <% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5));
	 	if (strTemp.length() > 0)
			strTemp +=WI.getStrValue((String)vRetResult.elementAt(i+15),", ","","") ;
		else
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15)) ;
	 %>		
      <td class="thinborder">&nbsp;<%=strTemp%>	  </td>
	  <%dTotalBudget += Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+8),"0")); %>
      <td align="right" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8))%>&nbsp;&nbsp;</td>
      <td class="thinborder">&nbsp;
  <% strTemp = astrCatg[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+11),"0"))];
	 if (strTemp.length() != 0) 
	 	strTemp += WI.getStrValue((String)vRetResult.elementAt(i+3)," / <br>","","");
	 else
	 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3));
  %>
	  <%=strTemp%></td>
    </tr>
    <%}// end for loop
	
	if (WI.fillTextValue("show_total_budget").equals("1")) { 
	%>

    <tr>
      <td height="23" colspan="5" align="right" class="thinborder"><strong>TOTAL : &nbsp;&nbsp;&nbsp;</strong></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalBudget,true)%>&nbsp;&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
    </tr>
<%}%>
  </table>
<%}

	if (WI.fillTextValue("per_college_summary").equals("1")
			&& vPerCollege != null && vPerCollege.size() > 0) {
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
  	<tr>
  	  <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
  	<tr>
  	  <td height="25" colspan="4" class="thinborder"><div align="center"><strong>LISTING OF SEMINAR ATTENDANCE</strong> </div></td>
    </tr>
	
	
	<% for (int i = 0; i < vPerCollege.size();) {  
	
	 if((String)vPerCollege.elementAt(i) != null) { 
	%> 
  	<tr>
  	  <td height="20" colspan="4" bgcolor="#EFF4FA" class="thinborder">&nbsp;<strong><%=(String)vPerCollege.elementAt(i)%></strong></td>
    </tr>
  	<tr>
		<td width="25%" height="20" align="center" class="thinborder"> <strong><%if(bolIsSchool){%>College<%}else{%>Division<%}%> / Office </strong></td>
		<td width="25%" class="thinborder">&nbsp; <strong>No.</strong></td>
		<td width="25%" class="thinborder"> <div align="center"><strong><%if(bolIsSchool){%>College<%}else{%>Division<%}%> :: Dept		</strong></div></td>
	    <td width="25%" class="thinborder">&nbsp;<strong> No.</strong></td>
  	</tr>
	<%}%> 
  	<tr>
	  <td width="24%" height="25" class="thinborder">&nbsp;<%=(String)vPerCollege.elementAt(i+1)%></td>
		<td width="28%" class="thinborder">&nbsp;<%=(String)vPerCollege.elementAt(i+2)%></td>
	 <% i += 3;
	 	strTemp ="";
		strTemp2 = "";
	 	if (i < vPerCollege.size() && 
			(String)vPerCollege.elementAt(i) == null) {
				strTemp = (String)vPerCollege.elementAt(i+1);
				strTemp2 = (String)vPerCollege.elementAt(i+2);
			i+=3;
		 }	
	%>
	  <td width="24%" class="thinborder">&nbsp;<%=strTemp%></td>
	    <td width="24%" class="thinborder">&nbsp;<%=strTemp2%></td>
    </tr>
   <%} // end for loop%>
  </table>
<%}

	if (WI.fillTextValue("per_employee").equals("1")
			&& vSummary != null && vSummary.size() > 0) {
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
  	<tr>
  	  <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
  	<tr>
  	  <td height="25" colspan="6" class="thinborder"><div align="center"><strong>LIST OF SEMINAR PER EMPLOYEE </strong> </div></td>
    </tr>
  	<tr>
		<td width="31%" height="20" class="thinborder"><strong>&nbsp;Employee</strong></td>
		<td width="11%" class="thinborder"><strong>Internal </strong></td>
		<td width="10%" class="thinborder"><strong>External </strong></td>
		<td width="28%" class="thinborder"><strong>&nbsp;Employee</strong></td>
	    <td width="10%" class="thinborder">&nbsp;<strong> Internal </strong></td>
  	    <td width="10%" class="thinborder"><strong>&nbsp;External</strong></td>
  	</tr>
	
	<% 
	String strCurrID = null;
	String strCollege = null;
	String strCurrName = null;
	
	for (int i = 0; i < vSummary.size();) {  
	
		if (i == 0) 
			strCurrID = (String)vSummary.elementAt(i+1);
			
	 if((String)vSummary.elementAt(i) != null) { 
	 
	%> 
  	<tr>
  	  <td height="20" colspan="6" bgcolor="#EFF4FA" class="thinborder">&nbsp;
	  				<strong><%=(String)vSummary.elementAt(i)%></strong>
	   </td>
    </tr>
	<%
		vSummary.setElementAt(null, i);
	}%> 

  	<tr>
		<td width="31%" height="25" class="thinborder">&nbsp;<%=(String)vSummary.elementAt(i+2)%></td>
		<%  strCurrID = ""; strCurrName = "";
			if (  i < vSummary.size() && vSummary.elementAt(i) == null) {
				strCurrID = (String)vSummary.elementAt(i+1);
				strCurrName = (String)vSummary.elementAt(i+2);
			}
		
			if ( i < vSummary.size() && 
			    vSummary.elementAt(i) == null  && 
				strCurrID.equals((String)vSummary.elementAt(i+1))
				&& WI.getStrValue((String)vSummary.elementAt(i+3)).equals("0")) {
				
				strTemp = (String)vSummary.elementAt(i+4);
				i += 5;
				
			}else{
				strTemp = "";
			}
		%>
		<td width="11%" class="thinborder">&nbsp;<%=strTemp%></td>
		<% if ( i < vSummary.size() && 
			    vSummary.elementAt(i) == null  && 
				strCurrID.equals((String)vSummary.elementAt(i+1))
				&& WI.getStrValue((String)vSummary.elementAt(i+3)).equals("1")) {
				
				strTemp = (String)vSummary.elementAt(i+4);
				i += 5;
				
			}else{
				strTemp = "";
			}
		%>
		<td width="10%" class="thinborder">&nbsp;<%=strTemp%></td>
		<% strCurrID = ""; strCurrName = "";
			 if (  i < vSummary.size() && vSummary.elementAt(i) == null) {
				strCurrID = (String)vSummary.elementAt(i+1);
				strCurrName = (String)vSummary.elementAt(i+2);
			}
			if ( i < vSummary.size() && 
			    vSummary.elementAt(i) == null  && 
 				WI.getStrValue((String)vSummary.elementAt(i+3)).equals("0")) {

				strTemp = (String)vSummary.elementAt(i+4);
				i += 5;
				
			}else{
				strTemp = "";
			}
		%>
		<td width="28%" class="thinborder">&nbsp;<%=strCurrName%></td>
	    <td width="10%" class="thinborder">&nbsp;<%=strTemp%></td>
		<%  if ( i < vSummary.size() && 
			    vSummary.elementAt(i) == null  && 
				strCurrID.equals((String)vSummary.elementAt(i+1)) &&  
 				WI.getStrValue((String)vSummary.elementAt(i+3)).equals("1")) {

				strTemp = (String)vSummary.elementAt(i+4);
				i += 5;
				
			}else{
				strTemp = "";
			}
		%>		
        <td width="10%" class="thinborder">&nbsp;<%=strTemp%></td>
  	</tr>
   <%} // end for loop%>
  </table>
<%}%> 

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <% if (vRetResult!= null) {%>
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
<!--
    <tr> 
      <td>&nbsp;&nbsp;Report Title for Printing: 
        <input name="title_report" type="text" value="<%=WI.fillTextValue("title_report")%>" size="64"></td>
    </tr>
-->
    <tr> 
      <td height="25">
	 <!--
	  <div align="center"><font size="1"> Number of Lines Per 
          Page 
          <select name="max_lines">
            <% 
	  	for (int i =20; i <= 30; ++i){ 
		 if (WI.fillTextValue("max_lines").equals(Integer.toString(i))){
	  %>
            <option selected><%=i%></option>
            <%}else{%>
            <option><%=i%></option>
            <%}
	  } // end for loop%>
          </select></font></div>
	   -->
          <a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
		  <font size="1">click  to print List</font>	  </td>
    </tr>
    <%}%>

    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>