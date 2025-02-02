<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
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
	.fontsize11 {
		font-size:11px;
	}

a:link {
	text-decoration: none;
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
<script language="JavaScript">
function PrintPg()
{
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");	
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.show_list.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function EditRecord(strEmpID){
	var pgLoc = "../personnel/hr_personnel_education.jsp?emp_id=" + escape(strEmpID);
	var win=window.open(pgLoc,"EditWindow",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function UpdateAll(){
	var iNumCheckBox = Number(document.form_.max_value.value);

	if (iNumCheckBox == 0) {
		alert (" No Selection available");
		document.form_.select_all.checked = false;
		return;
	}

	
	if(document.form_.select_all.checked){
		// check all 
		for(var i = 0; i < iNumCheckBox;i++){
			eval("document.form_.checkboxED"+i+".checked = true");
		}
	}else{
		// remove all
		for(var i = 0; i < iNumCheckBox;i++){
			eval("document.form_.checkboxED"+i+".checked = false");
		}
	}
		
}
</script>

<body bgcolor="#663300" marginheight="0"  class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./hr_educ_reports_print.jsp" />
<%	return;}	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_educ_reports.jsp");

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
Vector vRetResult = null;

HRStatsReports hrStat = new HRStatsReports(request);

if ( WI.fillTextValue("show_list").equals("1")){
	vRetResult = hrStat.searchHREduc(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
	else	
		iSearchResult = hrStat.getSearchCount();
}


//System.out.println(vRetResult);


String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal","More than","Less Than"};
String[] astrDropListValGT = {"=","greater","less"};
String[] astrSortByName    = {"Position", "Emp. Status","Last Name", "First Name", "Educational Level"};
String[] astrSortByVal     = {"emp_type_name","status","lname","fname","hr_preload_edu_type.ORDER_NO"};

boolean[] abolShowColumns={false, false, false, false, false,false, false}; 
boolean bolShowAtLeastOne = false;
int iShowColumns =1;
for (int i = 0; i < 7; i++){
	if ( WI.fillTextValue("checkbox"+i).equals("1")){
		abolShowColumns[i]= true;
		iShowColumns++;
	}
}
if (iShowColumns ==1) {
	abolShowColumns[2] = true;
	iShowColumns = 2;	
}

if (WI.fillTextValue("sch_index").length() > 0){
	abolShowColumns[3] = true;
	iShowColumns++;
}
%>
<form action="hr_educ_reports.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          EDUCATION DEMOGRAPHIC REPORTS ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Employee ID</td>
      <td><select name="emp_id_con" >
          <%=hrStat.constructSortByDropList(WI.fillTextValue("emp_id_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="emp_id" type="text" value="<%=WI.fillTextValue("emp_id")%>" size="16" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          &nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%" class="fontsize11">Education Level</td>
      <td width="81%"> <select name="edu_type_index">
          <option value=""></option>
          <%=dbOP.loadCombo("EDU_TYPE_INDEX","EDU_NAME",",ORDER_NO FROM HR_PRELOAD_EDU_TYPE ORDER BY ORDER_NO",WI.fillTextValue("edu_type_index"),false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Emp. Status</td>
      <td><select name="status_index">
          <option value=""></option>
          <%=dbOP.loadCombo("STATUS_INDEX","STATUS"," FROM USER_STATUS where IS_FOR_STUDENT = 0 ",WI.fillTextValue("status_index"),false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Position</td>
      <td><select name="emp_type_index">
          <option value=""></option>
          <%=dbOP.loadCombo("emp_type_index","emp_type_name"," FROM HR_EMPLOYMENT_TYPE where IS_DEL = 0 order by position_order, emp_type_name ",WI.fillTextValue("emp_type_index"),false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td><select name="c_index" onChange="ReloadPage()">
          <option value=""></option>
          <%=dbOP.loadCombo("c_index","c_name"," FROM college where IS_DEL = 0 order by c_name",WI.fillTextValue("c_index"),false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Dept</td>
      <td><select name="d_index">
          <option value=""></option>
          <%
	if (WI.fillTextValue("c_index").length() != 0) 
		strTemp = " c_index = " + WI.fillTextValue("c_index");
	else
		strTemp = " (c_index is null or c_index = 0) ";
%>
          <%=dbOP.loadCombo("d_index","d_name"," FROM department where " + strTemp + " and IS_DEL = 0 order by d_name",WI.fillTextValue("d_index"),false)%> </select></td>
    </tr>
    <tr>
      <td class="fontsize11">&nbsp;</td>
      <td class="fontsize11"> Office/Dept filter </td>
      <td class="fontsize11"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
        (enter office/dept's first few characters) </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Name of School</td>
      <td><select name="sch_index" >
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_INDEX","SCH_NAME"," FROM HR_PRELOAD_SCHOOL ORDER BY SCH_NAME",WI.fillTextValue("sch_index"),false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Degree</td>
      <td><select name="degree_con">
          <%=hrStat.constructSortByDropList(WI.fillTextValue("degree_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="degree" type="text" size="64"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		  value="<%=WI.fillTextValue("degree")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11"> (Degree Major)</td>
      <td><select name="major_con">
        <%=hrStat.constructSortByDropList(WI.fillTextValue("major_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
      <input name="major_name" type="text"  class="textbox" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		size="64" value="<%=WI.fillTextValue("major_name")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">(Degree Minor)</td>
      <td><select name="minor_con">
        <%=hrStat.constructSortByDropList(WI.fillTextValue("minor_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
      <input name="minor_name" type="text"  class="textbox" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		size="64"  value="<%=WI.fillTextValue("minor_name")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Units Completed</td>
      <td>
	  
		<select name="units_con">
          <%=hrStat.constructGenericDropList(WI.fillTextValue("units_con"),astrDropListEqual,astrDropListValEqual)%> </select>
		<input name="units" type="text" size="4" maxlength="4"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onkeyup="AllowOnlyFloat('form_','units')" onBlur="AllowOnlyFloat('form_','units');style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Date of Graduation</td>
      <td> <input name="grad_month" type="text" size="2" maxlength="2" class="textbox" 
			  onKeyUp="AllowOnlyInteger('form_','grad_month')"  value="<%=WI.fillTextValue("grad_month")%>"
			  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        / 
        <input name="grad_day" type="text" size="2" maxlength="2" class="textbox" 
			  onKeyUp="AllowOnlyInteger('form_','grad_day')"    value="<%=WI.fillTextValue("grad_day")%>"
			  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        / 
        <input name="grad_year" type="text" size="4" maxlength="4" class="textbox" 
			  onKeyUp="AllowOnlyInteger('form_','grad_year')"   value="<%=WI.fillTextValue("grad_year")%>"
			   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font size="1">(mm/dd/yyyy)</font> </td>
    </tr>
	
<% if (bolIsSchool){%> 
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Emp. Category</td>
      <td>&nbsp;
        <select name="emp_category">
          <option value=""> ALL</option>
          <% if (WI.fillTextValue("emp_category").equals("1")) {%>
          <option value="1" selected> Academic Personnel</option>
          <%}else{%>
          <option value="1"> Academic Personnel</option>
          <%}if (WI.fillTextValue("emp_category").equals("0")){%>
          <option value="0" selected> Non Teaching Personnel</option>
          <%}else{%>
          <option value="0">Non Teaching Personnel</option>
          <%}%>
        </select>
        <font size="1" face="Arial, Helvetica, sans-serif">&lt;require entries 
        in service record&gt; </font></td>
    </tr>
<%}%> 
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" class="fontsize11"> <% if (WI.fillTextValue("remove_basic").equals("1")) strTemp = "checked";
	  	else strTemp = ""; %> <input type="checkbox" name="remove_basic" value="1" <%=strTemp%>>
        check to remove primary and secondary records</td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#DDEEFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25" class="fontsize11"> <strong>&nbsp;Select&nbsp;columns 
        to show in report : </strong></td>
    </tr>
    <tr> 
      <td height="23" class="fontsize11"> &nbsp; 
        <% if (abolShowColumns[0]) strTemp = "checked";  else strTemp = ""; %>
        <input name="checkbox0" type="checkbox" value="1" <%=strTemp%>>
        Employment Status &nbsp;&nbsp; 
<% if (abolShowColumns[1]) strTemp = "checked";  else strTemp = ""; %>		
        <input name="checkbox1" type="checkbox" value="1" <%=strTemp%>>
        Position&nbsp;&nbsp; 
<% if (abolShowColumns[2]) strTemp = "checked";  else strTemp = ""; %>		
        <input name="checkbox2" type="checkbox" value="1" <%=strTemp%>>
        Degree (Units)&nbsp;&nbsp; 
<% if (abolShowColumns[3]) strTemp = "checked";  else strTemp = ""; %>		
        <input name="checkbox3" type="checkbox" value="1" <%=strTemp%>>
        School Code&nbsp;&nbsp; 
<% if (abolShowColumns[6]) strTemp = "checked";  else strTemp = ""; %>		
        <input name="checkbox6" type="checkbox" value="1" <%=strTemp%>>
        School Name&nbsp;&nbsp; 
<% if (abolShowColumns[4]) strTemp = "checked";  else strTemp = ""; %>		
        <input name="checkbox4" type="checkbox" value="1" <%=strTemp%>>
        Educational Level 
<% if (abolShowColumns[5]) strTemp = "checked";  else strTemp = ""; %>
        <input name="checkbox5" type="checkbox" value="1" <%=strTemp%>>
        <% if (bolIsSchool){%> College / Dept<%}else{%> Division/Dept<%}%></td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="10%" height="25">&nbsp;Sort by</td>
      <td width="22%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="23%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="22%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="23%"><select name="sort_by4">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
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
      <td><select name="sort_by4_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by4_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:showList()"%><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<% 
	int iChkBox = 0;
	if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
<!--
      <td height="25">
<% if (WI.fillTextValue("show_all").length() > 0) strTemp = "checked";
else strTemp ="";%>	  
	  <input type="checkbox" name="show_all" value="1" <%=strTemp%>>Check to show all </td>
-->
      <td height="25" align="right">
<!--	  
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print result</font>
--> &nbsp;

	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="49%" height="25"><b>&nbsp;TOTAL RESULT : <%=iSearchResult%> </b></td>
      <td width="51%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="20%" align="center"  class="thinborder"><font size="1"><strong>EMPLOYEE 
        NAME </strong></font></td>
      <% if (abolShowColumns[0]) {%>
      <td width="7%" align="center"  class="thinborder"><font size="1"><strong>EMP. 
        STATUS</strong></font></td>
      <%} if (abolShowColumns[1]){%>
      <td width="10%" align="center"  class="thinborder"><strong><font size="1">POSITION</font></strong></td>
      <%} if (abolShowColumns[5]){%>
      <td width="9%" align="center"  class="thinborder"><strong><font size="1">OFFICE </font></strong></td>
      <%} if (abolShowColumns[4]) {%>
      <td width="10%"  class="thinborder"><font size="1"><strong>EDUC. LEVEL</strong></font></td>
      <%} if (abolShowColumns[2]){%>
      <td width="26%" align="center"  class="thinborder"><font size="1"><strong><font size="1">DEGREE 
        (UNITS)</font></strong></font></td>
      <%} if (abolShowColumns[3]){%>
      <td width="8%" align="center" class="thinborder"><strong><font size="1"><strong>SCHOOL CODE</strong></font></strong></td>
      <%} if (abolShowColumns[6]){%>
       <td width="15%" align="center" class="thinborder"><strong><font size="1">SCHOOL NAME</font></strong></td>
       <%}%>
      <td width="4%" align="center" class="thinborder"><strong><font size="1">SEL
	  <%
	  	 if (WI.fillTextValue("select_all").equals("1")) 
		 	strTemp = "checked";
		else
			strTemp = "";
	  %>
	  
	  <input type="checkbox" name ="select_all" value="1" <%=strTemp%> onClick="UpdateAll()">
	  
	   </font></strong></td>
    </tr>
    <% 
		String strCurrentUser = null;
		String strCurrentCollege = null;
		String strPrevCollege = null;
		boolean bolSameUser = false;
		boolean bolSameCollege = false;

		
//		System.out.println(vRetResult);
		
		for (int i=0; i < vRetResult.size(); i+=20){
			bolSameUser = false;
			bolSameCollege = false;
		
		if (strCurrentUser == null) {
			strCurrentUser = (String)vRetResult.elementAt(i+2);
			strPrevCollege = (String)vRetResult.elementAt(i+12); // college
			if (strPrevCollege == null)
				strPrevCollege = WI.getStrValue((String)vRetResult.elementAt(i+13),"Office Not Set");
			else
				strPrevCollege +=  WI.getStrValue((String)vRetResult.elementAt(i+13),"::","","");
		}
				
		if (strCurrentUser.equals((String)vRetResult.elementAt(i+2)) && i != 0)
			bolSameUser = true;
		else
			strCurrentUser = (String)vRetResult.elementAt(i+2);

		if (!bolSameUser){
			strCurrentCollege = (String)vRetResult.elementAt(i+12); // college
			if (strCurrentCollege == null)
				strCurrentCollege = (String)vRetResult.elementAt(i+13);
			else
				strCurrentCollege +=  WI.getStrValue((String)vRetResult.elementAt(i+13),"::","","");

			if(strCurrentCollege == null) {
				strCurrentCollege = "College info not set";
				strPrevCollege = "";
			}
			
			else 
							
			if (strPrevCollege.equals(strCurrentCollege)){
				bolSameCollege = true;
			}else{
				strPrevCollege = strCurrentCollege;
			}

			strTemp = WI.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),
	  							  (String)vRetResult.elementAt(i+5),4);
		}else{
			strTemp = "";
			bolSameCollege = true;	
		}	

		if (!bolSameCollege || i == 0) {
	%>
    <tr bgcolor="#F2E8D9">
      <td  colspan="<%=iShowColumns%>" ><strong>&nbsp;<%=strPrevCollege%></strong></td>
      <td ><input type="checkbox" name="checkboxED<%=iChkBox++%>" value="1"></td>
    </tr>
    <%} //end !bolSameCollege%>
    <tr>
      <td class="thinborder">&nbsp;
	  <% if (strTemp != null && strTemp.length()> 0){%>  
	  		<a href="javascript:EditRecord('<%=(String)vRetResult.elementAt(i+2)%>')"> 
					<%=strTemp.toUpperCase()%> </a>
	  <%}%>	  </td>
      <% if (abolShowColumns[0]) { 
	  		if (bolSameUser) strTemp = "";
			else
				strTemp = (String)vRetResult.elementAt(i+14);
	  %>
      <td class="thinborder">&nbsp;<%=strTemp%> </td>
      <%}if (abolShowColumns[1]) { 
	  		if (bolSameUser) strTemp = "";
			else
				strTemp = (String)vRetResult.elementAt(i+15);	  
	  %>
      <td class="thinborder">&nbsp;<%=strTemp%> </td>
      <%}if (abolShowColumns[5]) {  
	  		if (bolSameUser) 
				strTemp = "";
			else{
		  		strTemp = (String)vRetResult.elementAt(i+17);
				if (strTemp == null) 
					strTemp = (String)vRetResult.elementAt(i +18);
				else 	
					strTemp += WI.getStrValue((String)vRetResult.elementAt(i+18),"::","","");
			}
	  %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%> </td>
      <%} if (abolShowColumns[4]) { %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+1))%></td>
      <%}if (abolShowColumns[2]) { %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7))%> <%=WI.getStrValue((String)vRetResult.elementAt(i+16),"(",")","")%><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"(",")","")%></td>
      <%}if (abolShowColumns[3]) { %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>
      <%}if (abolShowColumns[6]) { %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+19))%></td>
      <%}%>
      <td class="thinborder"><input type="checkbox" name="checkboxED<%=iChkBox++%>" value="1"></td>
    </tr>
    <%}// end for loop
	%>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <% if (vRetResult!= null) {%>
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;Title of the Report: 
        <input name="title_report" type="text" class="textbox" size="48"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click 
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
  <input type="hidden" name="max_value" value="<%=iChkBox%>">
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>