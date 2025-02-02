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
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.show_list.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
	<jsp:forward page="./hr_sss_tin_pag_report_print.jsp" />
<%	return;}	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-SSS/TIN/PAG-IBIG","hr_sss_tin_pag_report.jsp");

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

boolean[] abolShowColumns={false, false, false, false,false, false, false}; 
boolean bolShowAtLeastOne = false;
int iShowColumns =0;
for (int i = 0; i < 7; i++){
	if ( WI.fillTextValue("checkbox"+i).equals("1")){
		abolShowColumns[i]= true;
		iShowColumns++;
	}
}
if (!bolIsSchool){
	abolShowColumns[4] = false;
}


HRStatsReports hrStat = new HRStatsReports(request);

if (iShowColumns > 0) {

	if ( WI.fillTextValue("show_list").equals("1")){
		vRetResult = hrStat.searchSSSTINPagIbig(dbOP);
		if(vRetResult == null)
			strErrMsg = hrStat.getErrMsg();
		else	
			iSearchResult = hrStat.getSearchCount();
	}
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolAUF = strSchCode.startsWith("AUF");
	
boolean bolIsTsuneishi = strSchCode.startsWith("TSUNEISHI");
boolean bolHasTeam = new ReadPropertyFile().getImageFileExtn("HAS_TEAMS","0").equals("1");

if (bolIsSchool) {
	if(bolAUF)
		strTemp = "AUF Retirement Plan";
	else
		strTemp = "PERAA" ;
}
else
	strTemp = "";

String strTemp2 = "";
String strTemp3 = "";
String strTemp4 = "";
String strTemp5 = "";
if(bolIsTsuneishi) {
	strTemp2 = "Hiring Batch";
	strTemp3 = "HR_HIRING_BATCH.HIRING_DUR_FR";
}
if(bolHasTeam) {
	strTemp4 = "Team";
	strTemp5 = "TEAM_NAME";
}


String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Last Name", "First Name", "POSITION", "COLLEGE", "DEPARTMENT", "SSS", "PAG-IBIG", "TIN","PHILHEALTH",strTemp,strTemp2, strTemp4};

if (bolIsSchool)
	strTemp = "PERAA";
else
	strTemp = "";
String[] astrSortByVal     = {"user_table.lname","user_table.fname","EMP_TYPE_NAME","C_CODE","D_CODE","SSS_NUMBER","PAG_IBIG","TIN","PHILHEALTH",strTemp,strTemp3, strTemp5};

if(!bolIsSchool)
	astrSortByName[3] = "Division";


%>
<form action="./hr_sss_tin_pag_report.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SSS / TIN/ PAG-IBIG / PHILHEALTH RECORDS ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%" class="fontsize11">Employee ID</td>
      <td width="30%"><select name="emp_id_con" >
          <%=hrStat.constructSortByDropList(WI.fillTextValue("emp_id_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="emp_id" type="text" value="<%=WI.fillTextValue("emp_id")%>" size="16" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="53%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="2"><select name="c_index" onChange="ReloadPage()">
          <option value=""></option>
          <%=dbOP.loadCombo("c_index","c_name"," FROM college where IS_DEL = 0 order by c_name",WI.fillTextValue("c_index"),false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Dept</td>
      <td colspan="2"><select name="d_index">
          <option value=""></option>
          <%
	if (WI.fillTextValue("c_index").length() != 0) 
		strTemp = " c_index = " + WI.fillTextValue("c_index");
	else
		strTemp = " (c_index is null or c_index = 0) ";
%>
          <%=dbOP.loadCombo("d_index","d_name"," FROM department where " + strTemp + " and IS_DEL = 0 order by d_name",WI.fillTextValue("d_index"),false)%> </select></td>
    </tr>
<%if(bolIsTsuneishi){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Hiring Batch </td>
      <td colspan="2">
	  <select name="hiring_batch">
        <option value=""></option>
        <%=dbOP.loadCombo("HIRING_BATCH_INDEX","BATCH_NAME"," FROM HR_HIRING_BATCH where IS_VALID = 1 order by BATCH_NAME",WI.fillTextValue("hiring_batch"),false)%>
      </select>
	  Team: 
	   <select name="team_index">
			<option value=""></option>
			<%=dbOP.loadCombo("team_index","team_name"," from AC_TUN_TEAM where is_valid = 1 order by team_name",WI.fillTextValue("team_index"), false)%> 
	   </select>
	  </td>
    </tr>
<%}%>
    <tr>
      <td class="fontsize11"></td>
      <td class="fontsize11"> Office/Dept filter </td>
      <td colspan="2" class="fontsize11"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
        (enter office/dept's first few characters) </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">PAG-IBIG No</td>
      <td colspan="2"><select name="pag_ibig_con" id="pag_ibig_con" >
          <%=hrStat.constructSortByDropList(WI.fillTextValue("pag_ibig_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="pag_ibig" type="text" class="textbox" id="pag_ibig" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("pag_ibig")%>" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">TIN No</td>
      <td colspan="2"><select name="tin_con" >
          <%=hrStat.constructSortByDropList(WI.fillTextValue("tin_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="tin" type="text" class="textbox" id="tin" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("tin")%>" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">SSS NO</td>
      <td colspan="2"> <select name="sss_con" >
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sss_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="sss_number" type="text" class="textbox" id="sss_number" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("sss_number")%>" size="16">      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">PHILHEALTH</td>
      <td colspan="2"><select name="philhealth_con" >
        <%=hrStat.constructSortByDropList(WI.fillTextValue("philhealth_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
        <input name="philhealth" type="text" class="textbox" id="philhealth" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("philhealth")%>" size="16"></td>
    </tr>
<% if (bolIsSchool) {%> 
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11"><%if(bolAUF){%>AUF Retirement Plan<%}else{%>PERAA<%}%></td>
      <td colspan="2"><select name="peraa_con" >
        <%=hrStat.constructSortByDropList(WI.fillTextValue("peraa_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
      <input name="peraa" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("peraa")%>" size="16"></td>
    </tr>
<%}%> 
    <tr>
      <td height="25">&nbsp;</td>
<% 
	if (WI.fillTextValue("show_only_record").equals("1")) 
		strTemp = "checked";
	else
		strTemp = "";
%> 
      <td height="25" colspan="3"><input type="checkbox" name="show_only_record" value="1"
	  <%=strTemp%> >
	  <font size="1"> check to show only employee's with record</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#DDEEFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25" class="fontsize11"> <strong>&nbsp;Select&nbsp;columns 
        to show in report : </strong></td>
    </tr>
    <tr> 
      <td height="23" class="fontsize11"> &nbsp; <% if (abolShowColumns[0]) strTemp = "checked";  else strTemp = ""; %> 
	    <input name="checkbox0" type="checkbox" value="1" <%=strTemp%>>
        SSS &nbsp;&nbsp; <% if (abolShowColumns[1]) strTemp = "checked";  else strTemp = ""; %> 
		<input name="checkbox1" type="checkbox" value="1" <%=strTemp%>>
        TIN&nbsp;&nbsp; <% if (abolShowColumns[2]) strTemp = "checked";  else strTemp = ""; %>
		<input name="checkbox2" type="checkbox" value="1" <%=strTemp%>>
        PAG-IBIG&nbsp;&nbsp; <% if (abolShowColumns[3]) strTemp = "checked";  else strTemp = ""; %> <input name="checkbox3" type="checkbox" value="1" <%=strTemp%>>
        PHILHEALTH&nbsp;&nbsp;  
		<%
		if ( bolIsSchool) {
		 if (abolShowColumns[4]) strTemp = "checked";  else strTemp = ""; %>
        <input name="checkbox4" type="checkbox" value="1" <%=strTemp%>> <%if(bolAUF){%>AUF Retirement Plan<%}else{%>PERAA<%}%> 
		<%}%>
		<%
		if ( bolIsTsuneishi) {
		 if (abolShowColumns[5]) strTemp = "checked";  else strTemp = ""; %>
        <input name="checkbox5" type="checkbox" value="1" <%=strTemp%>> Hiring Batch
		<%if (abolShowColumns[6]) strTemp = "checked";  else strTemp = "";%> 
        <input name="checkbox6" type="checkbox" value="1" <%=strTemp%>> Team 
		<%}%>
&nbsp;&nbsp; </td>
    </tr>
    <tr> 
      <td height="15"><font size="1">&nbsp;</font></td>
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
<% if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 

      <td height="25">
<% if (WI.fillTextValue("show_all").length() > 0) strTemp = "checked";
else strTemp ="";%>	  
	  <input type="checkbox" name="show_all" value="1" <%=strTemp%>>Check to show all </td>

      <td height="25" align="right">&nbsp;
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
      <td width="27%" height="18"  class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE 
          NAME </strong></font></div></td>

      <td width="10%"  class="thinborder"><div align="center"><strong><font size="1">POSITION</font></strong></div></td>
      <td width="12%"  class="thinborder"><div align="center"><strong><font size="1">OFFICE 
          </font></strong></div></td>
      <% if (abolShowColumns[0]) {%>
      <td width="13%"  class="thinborder"><div align="center"><font size="1"><strong>SSS</strong></font></div></td>
      <%} if (abolShowColumns[1]){%>
      <td width="13%"  class="thinborder"><div align="center"><font size="1"><strong>TIN</strong></font></div></td>
      <%} if (abolShowColumns[2]){%>	  
      <td width="13%" align="center" class="thinborder"><strong><font size="1">PAG-IBIG</font></strong></td>
      <%} if (abolShowColumns[3]){%>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">PHILHEALTH</font></strong></td>
      <%} if (abolShowColumns[4]){%>
      <td width="12%" align="center" class="thinborder"><strong><font size="1"><%if(bolAUF){%>AUF RETIREMENT PLAN<%}else{%>PERAA<%}%></font></strong></td>
      <%} if (abolShowColumns[5]){%>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">HIRING BATCH</font></strong></td>
      <%} if (abolShowColumns[6]){%>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">TEAM</font></strong></td>
      <%}%>
    </tr>
    <% 	for (int i=0; i < vRetResult.size(); i+=14){ %>
    <tr> 
      <td class="thinborder">&nbsp;(<%=(String)vRetResult.elementAt(i)%>)&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),
	  								(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%> </td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%> </td>
	 <% 
	 	strTemp = (String)vRetResult.elementAt(i+4); 
		if (strTemp == null) 
			strTemp = (String)vRetResult.elementAt(i+5); 
		else
			strTemp +=  WI.getStrValue((String)vRetResult.elementAt(i+5),"(", ")","");
		 
	 %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%> </td>
      <%if (abolShowColumns[0]){ %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+7))%></td>
      <%}if (abolShowColumns[1]){ %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
      <%}if (abolShowColumns[2]){ %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+9))%></td>
      <%}if (abolShowColumns[3]){ %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>
      <%}if (abolShowColumns[4]){ %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+11))%></td>
      <%}if (abolShowColumns[5]){ %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+12))%></td>
      <%}if (abolShowColumns[6]){ %>
	  <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+13))%></td>
	  <%}%> 
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
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>