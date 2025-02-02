<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
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

</script>

<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./hr_demographic_profile_print.jsp" />
<% return;	}
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode == null)
		strSchCode = "";
	boolean bolAUF = strSchCode.startsWith("AUF");
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-REPORTS AND STATISTICS-Education",
								"hr_demographic_profile.jsp");

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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"HR Management","REPORTS AND STATISTICS", request.getRemoteAddr(),
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

boolean bolIsTsuneishi = strSchCode.startsWith("TSUNEISHI");
boolean bolHasTeam = new ReadPropertyFile().getImageFileExtn("HAS_TEAMS","0").equals("1");

String strTemp2 = "";
String strTemp3 = "";
String strTemp4 = "";
String strTemp5 = "";
if(bolIsTsuneishi){
	strTemp2 = "Hiring Batch";
	strTemp3 = "HR_HIRING_BATCH.HIRING_DUR_FR";
}	
if(bolHasTeam) {
	strTemp4 = "Team";
	strTemp5 = "TEAM_NAME";
}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};

String[] astrSortByName    = {"ID Number","Last Name","First Name","Emp. Tenure","Civil Status", "Religion",
								"Nationality","Birth Date"," Place of Birth","Emp. Status", "Date of Employment",strTemp2, strTemp4};
String[] astrSortByVal     = {"user_table.id_number","lname","user_table.fname","user_status.status","civil_status","religion",
								"nationality","dob","PLACE_OF_BIRTH","pt_ft", "info_faculty_basic.DOE",strTemp3, strTemp5};
boolean[] abolShowList= new boolean[22];
boolean bolShowID = WI.fillTextValue("show_id").equals("1");
			
int iIndex =1;

String[] astrCivilStatus={"","Single","Married","Separated", "Widow / Widower","Annuled","Living Together"};
String[] astrPTFT = {"PT","FT"};
String[] astrSalaryBasis = {"Monthly", "Daily", "Hourly"};

for(; iIndex <= 21; iIndex++){
	if(WI.fillTextValue("checkbox"+iIndex).equals("1"))
		abolShowList[iIndex] = true;	
}

Vector vRetResult = null;

if (WI.fillTextValue("show_list").equals("1")){

	vRetResult = hrStat.hrDemographicProfile(dbOP);
	
	if (vRetResult != null){
		iSearchResult = hrStat.getSearchCount();
	}else{
		strErrMsg = hrStat.getErrMsg();
	}
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
<form action="./hr_demographic_profile.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" class="footerDynamic"><font color="#FFFFFF"><strong>:::: 
      DEMOGRAPHIC PROFILE OF EMPLOYEES::::</strong></font></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr> 
      <td width="3%" height="25"><strong><font color="#0000FF">&nbsp;Check Columns 
        To Show in the Report : </font> </strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#E4EFFA">
    <tr> 
      <td width="33%" height="18">&nbsp;</td>
      <td width="34%">&nbsp;</td>
      <td width="33%">&nbsp;</td>
    </tr>
    <tr> 
      <td width="33%" height="25">
	  <% iIndex = 1;
	  if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
	  <input type="checkbox" name="checkbox1" value="1" <%=strTemp%>>
        Employment Status </td>
      <td width="34%">
	  <% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
	  <input type="checkbox" name="checkbox2" value="1" <%=strTemp%>>
        Marital Status</td>
      <td width="33%">
	  <% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
	  <input type="checkbox" name="checkbox3" value="1" <%=strTemp%>>
        Religion</td>
    </tr>
    <tr> 
      <td height="25">
	  <% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
	  <input type="checkbox" name="checkbox4" value="1" <%=strTemp%>>
        Nationality</td>
      <td>
	  <% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
	  <input type="checkbox" name="checkbox5" value="1" <%=strTemp%>>
        Birthdate / Age</td>
      <td>
	  <% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
	  <input type="checkbox" name="checkbox6" value="1" <%=strTemp%>>
        Place of Birth </td>
    </tr>
    <tr> 
      <td height="25">
	  <% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
	  <input name="checkbox7" type="checkbox" value="1" <%=strTemp%>>
        Date of Entry</td>
      <td>
	  <% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";
	  %>
	  <input name="checkbox8" type="checkbox" value="1"  <%=strTemp%>> Years of Service
	  &nbsp;      </td>
      <td>
  	  <% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
		<input name="checkbox9" type="checkbox" value="1"  <%=strTemp%>>
        License</td>
    </tr>
    <tr> 
      <td height="25"><% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
        <input name="checkbox10" type="checkbox" value="1" <%=strTemp%>> 
        Rank</td>
      <td>	  
	  <% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";
	  %>
	  <input name="checkbox11" type="checkbox" value="1"  <%=strTemp%>> 
	  Contact Number &nbsp;</td>
      <td>	   
<% 
if (abolShowList[iIndex++])  strTemp = "checked";
else strTemp = "";
%>
	  <input name="checkbox12" type="checkbox" value="1"  <%=strTemp%>> Contact Address
	    &nbsp;</td>
    </tr>
    <tr>
      <td height="25"><% if (bolShowID)  strTemp = "checked";
	  	else strTemp = "";%>
        <input name="show_id" type="checkbox" value="1" <%=strTemp%>> 
        ID Number      </td>
      <td>
	  <%if(bolIsSchool){
	  strTemp = WI.fillTextValue("teaching_staff");
	  if(strTemp.equals("1")) {
	  	strTemp = " selected";
		strErrMsg = "";
	  }else if(strTemp.equals("0")) {
	  	strTemp = "";
		strErrMsg = " selected";
	  }%>Category : 
	  	<select name="teaching_staff" >
			<option value=""></option>
			<option value="1"<%=strTemp%>>Academic Personnel </option>
			<option value="0"<%=strErrMsg%>>Non Teaching Personnel</option>
        </select>
	  <%}%>	  </td>
      <td>
<% 
if (abolShowList[13])  
	strTemp = "checked";
else 
	strTemp = "";
%>
	  <input name="checkbox13" type="checkbox" value="1"  <%=strTemp%>>Gender
	  
<%if(bolIsTsuneishi){%>
<% 
if (abolShowList[14])  
	strTemp = "checked";
else 
	strTemp = "";
%>
	  <input name="checkbox14" type="checkbox" value="1"  <%=strTemp%>>Hiring Batch
<% 
if (abolShowList[15])  
	strTemp = "checked";
else 
	strTemp = "";
%>
	  <input name="checkbox15" type="checkbox" value="1"  <%=strTemp%>>Team
<%}%>	  </td>
    </tr>
    <tr>
      <td height="25"><% 
if (abolShowList[16])  
	strTemp = "checked";
else 
	strTemp = "";
%>
        <input name="checkbox16" type="checkbox" value="1"  <%=strTemp%>>
      End Date </td>
      <td><% 
if (abolShowList[17])  
	strTemp = "checked";
else 
	strTemp = "";
%>
        <input name="checkbox17" type="checkbox" value="1"  <%=strTemp%>>
      Position</td>
      <td><% 
if (abolShowList[18])  
	strTemp = "checked";
else 
	strTemp = "";
%>
        <input name="checkbox18" type="checkbox" value="1"  <%=strTemp%>>
        Immediate Head </td>
    </tr>
    <tr>
      <td height="25"><% 
if (abolShowList[19])  
	strTemp = "checked";
else 
	strTemp = "";
%>
        <input name="checkbox19" type="checkbox" value="1"  <%=strTemp%>> 
        Blood group
</td>
      <td><% 
if (abolShowList[20])  
	strTemp = "checked";
else 
	strTemp = "";
%>
        <input name="checkbox20" type="checkbox" value="1"  <%=strTemp%>> 
        Salary Basis
</td>
      <td><!--
	  <% 
if (abolShowList[21])  
	strTemp = "checked";
else 
	strTemp = "";
%>
        <input name="checkbox21" type="checkbox" value="1"  <%=strTemp%>> 
        Job Code-->
</td>
    </tr>
    
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFF0F0">
    <tr> 
      <td colspan="4" style="font-size:11px; color:#0000FF; font-weight:bold">&nbsp;&nbsp;
<%
strTemp = WI.fillTextValue("inc_separated");
if(strTemp.length() == 0) 
	strTemp = "0";
if(strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	
	  <input type="radio" name="inc_separated" value="0" <%=strErrMsg%>> Exclude Separated Employees &nbsp;
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="inc_separated" value="1" <%=strErrMsg%>> Include Separated Employees &nbsp;
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="inc_separated" value="2" <%=strErrMsg%>> Show Only Separated Employees&nbsp;
<%if(bolShowNonEmployeeSetting){
	if(strTemp.equals("3"))
		strErrMsg = " checked";
	else	
		strErrMsg = "";
	%>
	  <input type="radio" name="inc_separated" value="3" <%=strErrMsg%>> Show Non-Employee
<%}%>	  </td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Position</td>
      <td colspan="3"><select name="emp_type_index">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("emp_type_index", "emp_type_name"," from hr_employment_type where is_del =0 order by emp_type_name",WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3">
	  <select name="c_index" onChange="ReloadPage()">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"), false)%> 
	   </select></td>
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
      <td colspan="3" class="fontsize10"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
        (enter office/dept's first few characters) </td>
    </tr>
    <tr> 
      <td height="18" colspan="4" class="fontsize10"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Emp. Status </td>
      <td width="34%"><select name="pt_ft" >
        <option value=""> ALL</option>
		<% if (WI.fillTextValue("pt_ft").equals("0")){%>
			<option value="0" selected> Part Time</option>
		<%}else{%> 
			<option value="0"> Part Time</option>
		<%} if (WI.fillTextValue("pt_ft").equals("1")){%> 		
			<option value="1" selected> Full Time</option>		
		<%}else{%> 
			<option value="1" > Full Time</option>		
		<%}%> 
      </select></td>
      <td width="12%" align="right" class="fontsize10">Marital Status&nbsp;&nbsp;</td>
      <td width="42%"><select name="civil_status">
          <option value="">ALL</option>
          <%	if (WI.fillTextValue("civil_status").equals("1")){ %>
          <option value="1" selected>Single</option>
          <%}else{%>
          <option value="1">Single</option>
          <%}	if (WI.fillTextValue("civil_status").equals("2")){ %>
          <option value="2" selected>Married</option>
          <%}else{%>
          <option value="2">Married</option>
          <%}	if (WI.fillTextValue("civil_status").equals("3")){ %>
          <option value="3" selected>Separated </option>
          <%}else{%>
          <option value="3">Separated</option>
          <%}	if (WI.fillTextValue("civil_status").equals("4")){ %>
          <option value="4" selected> Widow/Widower</option>
          <%}else{%>
          <option value="4"> Widow/Widower</option>
          <%}
		if(bolAUF){
			if (WI.fillTextValue("civil_status").equals("5")){ %>
          <option value="5" selected>Annuled</option>
          <%}else{%>
          <option value="5">Annuled</option>
          <%}	if (WI.fillTextValue("civil_status").equals("6")){ %>
          <option value="6" selected>Living Together</option>
          <%}else{%>
          <option value="6">Living Together</option>
          <%}
		}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Emp. Tenure </td>
      <td><select name="status_index">
        <option value=""> ALL</option>
        <%=dbOP.loadCombo("status_index", "status"," from user_status where IS_FOR_STUDENT = 0 order by status",
								WI.fillTextValue("status_index"), false)%>
      </select></td>
      <td align="right" class="fontsize10">Birthdate&nbsp;&nbsp;</td>
      <td class="fontsize10"> <input name="bday_from" type="text" class="textbox"  size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("bday_from")%>"> 
        <a href="javascript:show_calendar('form_.bday_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>&nbsp;&nbsp;To 
        <input name="bday_to" type="text" class="textbox" size="10" maxlength="10" readonly="yes"  value="<%=WI.fillTextValue("bday_to")%>"> 
        <a href="javascript:show_calendar('form_.bday_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0">        </a> </td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Nationality</td>
      <td><select name="nationality_index">
        <option value=""> &nbsp;</option>
        <%=dbOP.loadCombo("nationality_index", "nationality", " from HR_PRELOAD_NATIONALITY order by nationality", 
	  					WI.fillTextValue("nationality_index"),false)%>
      </select></td>
      <td align="right" class="fontsize10">Age&nbsp;&nbsp; </td>
      <td class="fontsize10"><!--
	  <input name="age" type="text" class="textbox" 
	  	value="<%=WI.fillTextValue("age")%>"  size="2" maxlength="2" 
		onKeyUp="AllowOnlyInteger('form_','age')" onBlur="AllowOnlyInteger('form_','age')">
	  -->
	  <select name="age_con" style="font-size:11px;">
	  	<option value="=">Equals</option>
		<%
		strTemp = WI.fillTextValue("age_con");
		if(strTemp.equals("<"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>
				<option value="<" <%=strErrMsg%>>Equal or more than</option>
		<%
		if(strTemp.equals(">"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>
	  	<option value=">" <%=strErrMsg%>>Less than</option>
	  </select>
	  <input name="age" type="text" class="textbox" 
	  	value="<%=WI.fillTextValue("age")%>"  size="2" maxlength="3" 
		onKeyUp="AllowOnlyInteger('form_','age')" onBlur="AllowOnlyInteger('form_','age')">
	  YRs 
	  As of: 
	  <select name="age_asof_yr" style="font-size:11px;">
		<option value="-1"></option>
          <%=dbOP.loadComboYear(WI.getStrValue(WI.fillTextValue("age_asof_yr"), "-1"),1,10)%> 
        </select> 
		-
		<select name="age_asof_mm" style="font-size:11px;">
		<option value="-1"></option>
          <%=dbOP.loadComboMonth(WI.getStrValue(WI.fillTextValue("age_asof_mm"), "-1"))%> 
        </select>
	  
	  
	  
	  </td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Religion</td>
      <td class="fontsize10"><select name="religion_index">
        <option value=""> &nbsp;</option>
        <%=dbOP.loadCombo("religion_index", "religion", " from HR_PRELOAD_religion order by religion", 
	  					WI.fillTextValue("religion_index"),false)%>
      </select></td>
      <td align="right" class="fontsize10"><%if(bolIsTsuneishi){%>Hiring Batch&nbsp;&nbsp; <%}%></td>
      <td class="fontsize10">
<%if(bolIsTsuneishi){%>
	  <select name="hiring_batch" style="font-size:11px;">
        <option value=""></option>
        <%=dbOP.loadCombo("HIRING_BATCH_INDEX","BATCH_NAME"," FROM HR_HIRING_BATCH where IS_VALID = 1 order by BATCH_NAME",WI.fillTextValue("hiring_batch"),false)%>
      </select>
	  Team: 
	   <select name="team_index">
			<option value=""></option>
			<%=dbOP.loadCombo("team_index","team_name"," from AC_TUN_TEAM where is_valid = 1 order by team_name",WI.fillTextValue("team_index"), false)%> 
	   </select>
<%}%>	  </td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;License</td>
      <td colspan="3" class="fontsize10"><select name="license_index">
          <option value=""> &nbsp;</option>
		  <% if (WI.fillTextValue("license_index").equals("0")) {%>
			  <option value="0" selected style="font-weight:bold; color:#0000FF"> Show Only Employees With License</option>
		  <%}else{%>
			  <option value="0" style="font-weight:bold; color:#0000FF"> Show Only Employees With License</option>
		   <%}%>		  
          <%=dbOP.loadCombo("LICENSE_INDEX", "LICENSE_NAME", " from HR_PRELOAD_LICENSE order by LICENSE_NAME",
		  					 WI.fillTextValue("license_index"),false)%> </select>      </td>
    </tr>
    <tr> 
      <td height="10" class="fontsize10">&nbsp;Address</td>
      <td colspan="3"><select name="address_con">
          <%=hrStat.constructGenericDropList(WI.fillTextValue("address_con"),astrDropListEqual,astrDropListValEqual)%> 
		  </select>
		  <input name="address" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("address")%>" size="48">	  </td>
    </tr>
    <tr>
      <td height="10" class="fontsize10">&nbsp;Last Name </td>
      <td colspan="3">
	  <input type="text" name="last_name" value="<%=WI.fillTextValue("last_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="10" class="fontsize10">&nbsp;First Name </td>
      <td colspan="3">
	  <input type="text" name="first_name" value="<%=WI.fillTextValue("first_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="10" class="fontsize10">&nbsp;ID Number </td>
      <td colspan="3">
	  <input type="text" name="id_" value="<%=WI.fillTextValue("id_")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="10" class="fontsize10">&nbsp;Gender</td>
      <td>
<select name="gender">
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
        </select>		</td>
      <td class="fontsize10" align="right">DOE : &nbsp;</td>
      <td>
		<input name="doe_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("doe_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.doe_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>	  

		to
		
		<input name="doe_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("doe_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.doe_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>	  </td>
    </tr>
    <tr>
      <td height="10" class="fontsize10">&nbsp;Name Format</td>
      <td height="10" class="fontsize10">
	  <select name="name_format">
	  	<option value="4">lname, fname mi.</option>
		<%
		strTemp = WI.fillTextValue("name_format");
		if(strTemp.equals("5"))
			strErrMsg = " selected";
		else	
			strErrMsg = "";
		%>
	  	<option value="5" <%=strErrMsg%>>lname, fname mname</option>
	  </select>	</td>
      <td height="10" class="fontsize10" align="right">Yrs Of Service : &nbsp;</td>
      <td height="10" class="fontsize10">
	  <select name="los_con" style="font-size:11px;">
	  	<option value="=">Equals</option>
<%
strTemp = WI.fillTextValue("los_con");
if(strTemp.equals("<"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>
	  	<option value="<" <%=strErrMsg%>>More than</option>
<%
if(strTemp.equals(">"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>
	  	<option value=">" <%=strErrMsg%>>Less than</option>
	  </select>
	  <input name="los" type="text" class="textbox" 
	  	value="<%=WI.fillTextValue("los")%>"  size="2" maxlength="3" 
		onKeyUp="AllowOnlyInteger('form_','los')" onBlur="AllowOnlyInteger('form_','los')">
	  YRs 
	  As of: 
	  <select name="los_asof_yr" style="font-size:11px;">
		<option value="-1"></option>
          <%=dbOP.loadComboYear(WI.getStrValue(WI.fillTextValue("los_asof_yr"), "-1"),1,10)%> 
        </select> 
		-
		<select name="los_asof_mm" style="font-size:11px;">
		<option value="-1"></option>
          <%=dbOP.loadComboMonth(WI.getStrValue(WI.fillTextValue("los_asof_mm"), "-1"))%> 
        </select>
		
	  </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="20%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="22%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="42%"><select name="sort_by3">
          <option value="">N/A</option>
      <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> </td>
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
    </tr>
    <tr> 
      <td height="18" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:showList()"%><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>

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
	<% if (bolShowID) {%> 
      <td width="5%" align="center"  class="thinborder"><font size="1"><strong>ID NO.</strong></font></td> 
	  <%}%>
      <td width="12%" height="25" align="center"  class="thinborder"><font size="1"><strong>EMPLOYEE NAME</strong></font></td>
<%
if(!bolIsSchool)
	strTemp = "Division/Office";
else {
	if(strSchCode.startsWith("AUF"))
		strTemp = "UNIT";
	else	
		strTemp = "College/Dept";
}%>

      <td width="3%" align="center"  class="thinborder"><font size="1"><strong><%=strTemp.toUpperCase()%></strong></font></td>
			<%if (abolShowList[17]){%>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
      <%} iIndex = 1; if (abolShowList[iIndex++]){%>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">EMP. STATUS</font></strong></td>
      <%}if (abolShowList[14]){%>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">HIRING BATCH</font></strong></td>
      <%}if (abolShowList[15]){%>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">TEAM</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">MARITAL STATUS</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="6%" class="thinborder"><font size="1"><strong>RELIGION</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="8%" class="thinborder"><font size="1"><strong>NATIONALITY</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="7%" class="thinborder"><font size="1"><strong>BIRTHDATE</strong></font></td>
      <td width="3%" class="thinborder"><font size="1"><strong>AGE</strong></font></td>
      <%}if (abolShowList[13]){%>
      <td width="3%" class="thinborder"><font size="1"><strong>GENDER</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="8%" class="thinborder"><font size="1"><strong>PLACE OF BIRTH</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="4%" class="thinborder"><font size="1"><strong>DATE OF ENTRY</strong></font></td>
			<%}if (abolShowList[16]){%>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>END DATE </strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>LENGTH OF SERVICE</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="5%" class="thinborder"><strong><font size="1">LICENSE</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="4%" class="thinborder"><strong><font size="1">RANK</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="6%" class="thinborder"><strong><font size="1">CONTACT NO.</font></strong> </td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="7%" class="thinborder"><strong><font size="1">ADDRESS</font></strong></td>
      <%}if (abolShowList[18]){%>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">IMMEDIATE HEAD</font></strong></td>
			<%}if (abolShowList[19]){%>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">BLOOD TYPE </font></strong></td>
			<%}if (abolShowList[20]){%>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">SALARY BASIS </font></strong></td>
			<%}if (abolShowList[21]){%>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">JOB CODE </font></strong></td>
      <%}%>
    </tr>
    <% //System.out.println(vRetResult);
		int iNameFormat = Integer.parseInt(WI.getStrValue(WI.fillTextValue("name_format"), "4"));
		String[] astrConvertGender = {"Male","Female"};
		Vector vServiceRec = null;
		for (int i=0; i < vRetResult.size(); i+=35){
		  vServiceRec = (Vector)vRetResult.elementAt(i+26);
			iIndex = 1;
	%>
    <tr>
<% if (bolShowID) {%> 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td> 
<%}%>
      <td height="25" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2),
	  													(String)vRetResult.elementAt(i+3),
					 	  							    (String)vRetResult.elementAt(i+4),iNameFormat)%></td>
      <% 
		strTemp = (String)vRetResult.elementAt(i+5);
		if (strTemp == null) strTemp = (String)vRetResult.elementAt(i+6);
		else strTemp += WI.getStrValue((String)vRetResult.elementAt(i+6)," :: ","","");
	%>
      <td class="thinborder"> <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%if (abolShowList[17]){%>
			<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+12),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){
	  	
			if (strSchCode.startsWith("AUF")) { 
				strTemp = astrPTFT[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+17),"1"))];
					if (WI.getStrValue((String)vRetResult.elementAt(i+17),"1").equals("1"))
						 strTemp += WI.getStrValue((String)vRetResult.elementAt(i+7)," ").charAt(0);
			}else{
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;");
			}
	  %>
      <td class="thinborder"><%=strTemp%></td>
      <%}if (abolShowList[14]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+22),"&nbsp;")%></td>
      <%}if (abolShowList[15]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+23),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td class="thinborder"> <%=astrCivilStatus[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+8),"0"))]%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+14),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){
	  		if ((String)vRetResult.elementAt(i+9) != null) {
				strTemp = "&nbsp;" +
						 ConversionTable.differenceInYearMonthDaysNow((String)vRetResult.elementAt(i+9));
				if (strTemp.indexOf("Years") != -1) 
					strTemp = strTemp.substring(0,strTemp.indexOf("Years"));
				else 
					strTemp = "&nbsp;";
			}else
				strTemp = "&nbsp;";
	  %>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+9),"&nbsp;")%></td>
      <td class="thinborder"><%=strTemp%></td>
      <%}if (abolShowList[13]){%>
      <td class="thinborder"><%=astrConvertGender[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+21),"0"))]%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+11),"&nbsp;")%></td>
			<%}if (abolShowList[16]){%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+24),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){
	  		if ((String)vRetResult.elementAt(i+11) != null) {
				if(vRetResult.elementAt(i+24) != null && ((String)vRetResult.elementAt(i+24)).length() > 6) {//valid end of contract
					java.util.Date dDateLHS = ConversionTable.convertMMDDYYYYToDate((String)vRetResult.elementAt(i+24));
					java.util.Date dDateRHS = ConversionTable.convertMMDDYYYYToDate((String)vRetResult.elementAt(i+11));
					
					strTemp = "&nbsp;" +
						 ConversionTable.differenceInYearMonthDays(dDateLHS, dDateRHS, 2);
						 
					//if(vRetResult.elementAt(i + 1).equals("05112")) {
					//	System.out.println(dDateLHS.toString());
					//	System.out.println(dDateRHS.toString());
					//}
				}
				else
					strTemp = "&nbsp;" +
						 ConversionTable.differenceInYearMonthDaysNow((String)vRetResult.elementAt(i+11));
				
				if (strTemp.indexOf("Months") != -1) {
					strTemp = strTemp.substring(0,strTemp.indexOf("M")) + " Months";
				}else if (strTemp.indexOf("Month") != -1) 
					strTemp = strTemp.substring(0,strTemp.indexOf("M")) + " Month";

			}else
				strTemp = "&nbsp;";	  
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+15),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%if(vServiceRec.size() > 1){%><%=vServiceRec.elementAt(1)%><%}else{%>&nbsp;<%}%><%//=WI.getStrValue((String)vRetResult.elementAt(i+18),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+19),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+20),"&nbsp;")%></td>
       <%}if (abolShowList[18]){
			 	strTemp = null;
			 	if(vServiceRec != null && vServiceRec.size() > 0){
					strTemp = WI.formatName((String)vServiceRec.elementAt(2), 
														 			(String)vServiceRec.elementAt(3), 
																	(String)vServiceRec.elementAt(4), 4);
				}
			 %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
			<%}if (abolShowList[19]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+25),"&nbsp;")%></td>
			<%}if (abolShowList[20]){%>
      <td class="thinborder"><%=astrSalaryBasis[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+27),"0"))]%></td>
			<%}if (abolShowList[21]){
			 	strTemp = null;
			 	if(vServiceRec != null && vServiceRec.size() > 0){
					strTemp = (String)vServiceRec.elementAt(1);
				}
			 %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
      <%}%>
    </tr>
    <%}// end for loop%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <% if (vRetResult!= null) {%>
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;&nbsp;Report Title for Printing: 
        <input name="title_report" type="text" value="<%=WI.fillTextValue("title_report")%>" size="64"></td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">
	  Number of Employees Per Page 
<%
int iDefaultVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_lines"), "40"));
%>
	  <select name="max_lines">
	  <option value="1000000">All in one page</option>
	  <% 
	  	for (int i =20; i <= 60; ++i){ 
		 if (iDefaultVal == i){
	  %>
	   <option selected><%=i%></option>	
	   <%}else{%>
	   <option><%=i%></option>		   
	  <%}
	  } // end for loop%>
	  </select>	  
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click 
          to print List</font></div></td>
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