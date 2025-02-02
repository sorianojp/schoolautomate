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
	var win=window.open(pgLoc,"SearchID",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
	<jsp:forward page="./hr_demographic_profile_rank_print.jsp" />
<% return;	}
	
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
											"HR Management","REPORTS AND STATISTICS",
											request.getRemoteAddr(),"hr_demographic_profile.jsp");
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
String[] astrSortByName    = {"Rank", "Position", "Emp. Status","Last Name", "First Name"};
String[] astrSortByVal     = {"GRADE_NAME", "emp_type_name","status","lname","fname"};		

String[] astrPTFT = {"PT", "FT"};

int iIndex =1;

Vector vRetResult = null;

if (WI.fillTextValue("show_list").equals("1")){

	vRetResult = hrStat.hrDemographicRank(dbOP);
	
	if (vRetResult != null){
		iSearchResult = hrStat.getSearchCount();
	}else{
		strErrMsg = hrStat.getErrMsg();
	}
}
%>
<form action="./hr_demographic_profile_rank.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          EMPLOYEE TENURESHIP (LENGTH OF SERVICE)::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFF0F0">
    <tr> 
      <td width="13%" height="25" class="fontsize10"> &nbsp;Position</td>
      <td colspan="2"><select name="emp_type_index">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("emp_type_index", "emp_type_name"," from hr_employment_type where is_del =0 order by emp_type_name",WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="2"><select name="c_index" onChange="ReloadPage()">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Dept / Office </td>
      <td colspan="2"><select name="d_index">
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
      <td colspan="2" class="fontsize10"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
        (enter office/dept's first few characters) </td>
    </tr>
    <tr> 
      <td height="18" colspan="3" class="fontsize10"><hr size="1" noshade></td>
    </tr>
    <tr>
      <td height="25" class="fontsize10"> &nbsp;Emp. ID </td>
      <td width="18%"><input name="emp_id" type="text" class="textbox" id="emp_id" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16"></td>
      <td width="69%">
	  <a href="javascript:OpenSearch()"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
    </tr>
<%if(bolIsSchool){
  strTemp = WI.fillTextValue("teaching_staff");
  if(strTemp.equals("1")) {
	strTemp = " selected";
	strErrMsg = "";
  }else if(strTemp.equals("0")) {
	strTemp = "";
	strErrMsg = " selected";
  }
%>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Category</td>
      <td colspan="2">
	  <select name="teaching_staff" >
			<option value=""></option>
			<option value="1"<%=strTemp%>>Academic Personnel </option>
			<option value="0"<%=strErrMsg%>>Non Teaching Personnel</option>
        </select>
	 </td>
    </tr>
<%}%>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Emp. Status </td>
      <td colspan="2"><select name="pt_ft">
	  <option value=""> ALL </option>
	 <% if (WI.fillTextValue("pt_ft").equals("0")) {%> 
	  <option value="0" selected> Part Time</option>
	 <%}else{%> 
	  <option value="0"> Part Time</option>
	 <%} if (WI.fillTextValue("pt_ft").equals("1")){%>
	  <option value="1" selected> Full Time</option>
	 <%}else{%> 
	  <option value="1"> Full Time</option>
	 <%}%> 
	  </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Emp. Tenure </td>
      <td colspan="2"><select name="status_index">
          <option value=""> ALL</option>
          <%=dbOP.loadCombo("status_index", "status"," from user_status where IS_FOR_STUDENT = 0 order by status",
								WI.fillTextValue("status_index"), false)%> </select></td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Job Grade </td>
      <td colspan="2"><select name="rank_con" >
        <%=hrStat.constructSortByDropList(WI.fillTextValue("rank_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
        <input name="salary_grade" type="text" class="textbox" id="salary_grade" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("salary_grade")%>" size="16">
&nbsp;</td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Cut Off Date </td>
	  
<%
	strTemp = WI.fillTextValue("cut_off_date");
	if (strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);
%>
	  
      <td colspan="2"><input name="cut_off_date" type="text" class="textbox"   
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','cut_off_date','/')" 
			value="<%=strTemp%>" size="11" maxlength="10">
&nbsp;<font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="18" class="fontsize10">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
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
      <td width="44%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
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
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td colspan="4"><font size="1">Note: To view this report, it requires entries in the <strong><font color="#FF0000">SERVICE RECORD</font></strong></font> </td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="49%" height="25">&nbsp;</td>
      <td width="51%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="25%" height="20"  class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE 
      NAME</strong></font></div></td>
      <td width="13%"  class="thinborder"><div align="center"><font size="1"><strong>UNIT</strong></font></div></td>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>

      <td width="10%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
      <td width="19%" class="thinborder"><div align="center"><font size="1"><strong>LENGTH 
      OF SERVICE(PT)</strong></font></div></td>

      <td width="19%" class="thinborder"><div align="center"><font size="1"><strong>LENGTH OF SERVICE (FT) </strong></font></div></td>
    </tr>
    <% 
		for (int i=0; i < vRetResult.size(); i+=10){
	%>
    <tr> 
      <td height="20" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),
	  															(String)vRetResult.elementAt(i+2),
																(String)vRetResult.elementAt(i+3),4)%></td>
      <% 
		strTemp = (String)vRetResult.elementAt(i+4);
		if (strTemp == null) strTemp = (String)vRetResult.elementAt(i+5);
	%>
      <td class="thinborder">&nbsp; <%=strTemp%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
      <td class="thinborder">&nbsp;<%=astrPTFT[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9))%></td>
    </tr>
    <%}// end for loop%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <% if (vRetResult!= null) {%>
    <tr> 
      <td height="18" colspan="2">&nbsp;</td>
    </tr>

    <tr> 
      <td width="46%" height="25"><div align="right"><font size="1">
        
        Number of Employees Per Page 
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
        </select>	  
        
      </font></div></td>
      <td width="54%">&nbsp;&nbsp;<font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click 
      to print List</font></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
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