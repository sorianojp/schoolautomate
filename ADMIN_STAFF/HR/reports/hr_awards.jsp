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
	document.form_.submit();
}

function ReloadPage(){
	document.form_.print_page.value="";
	document.form_.submit();
}

function showList(){
	document.form_.show_list.value="1";
	document.form_.print_page.value = "";
	document.form_.submit();
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
	<jsp:forward page="./hr_awards_print.jsp" />
<% return;	}
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-REPORTS AND STATISTICS-Awards",
								"hr_awards.jsp");

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
											request.getRemoteAddr(),"hr_awards.jsp");
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
String[] astrSortByName    = {"ID number", "College", "Department/Office"};
String[] astrSortByVal     = {"id_number", "c_name", "D_NAME"};

if(!bolIsSchool)
	astrSortByName[1] = "Division";
	

Vector vRetResult = null;
Vector vAwardDetail = null;
int iDetail = 0;

if (WI.fillTextValue("show_list").equals("1")){
	vRetResult = hrStat.awardsRecognitions(dbOP, true);
	
	if (vRetResult != null)
		iSearchResult = hrStat.getSearchCount();
	else
		strErrMsg = hrStat.getErrMsg();
}
%>
<form action="./hr_awards.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" class="footerDynamic"><font color="#FFFFFF"><strong>:::: 
      AWARDS/RECOGNITIONS REPORTS ::::</strong></font></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" style="font-size:16px; color:#FF0000; font-weight:bold">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFF0F0">
    <tr> 
      <td width="141" height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Employee ID </td>
      <td width="161"><input name="emp_id" type="text"  class="textbox" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		size="16" value="<%=WI.fillTextValue("emp_id")%>">      </td>
      <td width="440">&nbsp;<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Position</td>
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
      <td colspan="2"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
        (enter office/dept's first few characters) </td>
    </tr>
    <tr> 
      <td height="18" class="fontsize10">&nbsp;Award Type</td>
      <td height="18" colspan="2" class="fontsize10">
		<select name="award_type" onChange='document.form_.print_page.value="";document.form_.submit();'>
        	<option value="">Select Award Type</option>
            <%=dbOP.loadCombo("REWARD_TYPE_INDEX","REWARD_NAME"," FROM HR_REWARD_TYPE order by reward_name",WI.fillTextValue("award_type"),false)%> 
		</select>
		&nbsp;
			<%
				strTemp = WI.fillTextValue("filter_award");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>		
		<input type="checkbox" name="filter_award" value="1" <%=strTemp%>>
filter award      </td>
    </tr>
<%
strTemp = WI.fillTextValue("award_type");
if(strTemp.length() > 0) {%>
    <tr> 
      <td height="18" class="fontsize10">&nbsp; </td>
      <td height="18" colspan="2">
		<select name="award_name">
        	<option value="">Select Award Name</option>
			<%=dbOP.loadCombo("REWARD_INDEX","REWARD"," from HR_REWARD_NAME where REWARD_TYPE_INDEX="+strTemp + " order by reward",WI.fillTextValue("award_name"),false)%>
		</select>	  </td>
    </tr>
<%}%>
    <tr> 

      <td height="18" colspan="3" class="fontsize10">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="5">&nbsp;</td>
      <td>&nbsp;</td>
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
      <td width="47%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="0%">&nbsp;</td>
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
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="5">&nbsp;</td>
      <td>&nbsp;</td>
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
    <tr align="center" style="font-weight:bold">
      <td width="23%" height="25" class="thinborder"><font size="1">EMPLOYEE NAME</strong></font></td>
      <td width="19%" class="thinborder">IMMEDIATE HEAD/OFFICE</td>
      <td width="58%" class="thinborder"><font size="1">AWARDS/RECOGNITIONS DETAIL </font></td>
    </tr>
    <% 
		for (int i=0; i < vRetResult.size(); i+=20){
			vAwardDetail = (Vector)vRetResult.elementAt(i+9);
		%>
    <tr>
	
      <td height="25" valign="top" class="thinborder">&nbsp;<strong><%=WI.formatName((String)vRetResult.elementAt(i+2),
	  													(String)vRetResult.elementAt(i+3),
					 	  							    (String)vRetResult.elementAt(i+4),4)%></strong>
																<br>&nbsp;<%=vRetResult.elementAt(i + 1)%>
			<br>&nbsp;<%=vRetResult.elementAt(i + 10)%></td>
      <% 
				strTemp = (String)vRetResult.elementAt(i+5);
				if (strTemp == null) 
					strTemp = (String)vRetResult.elementAt(i+6);
				else 
					strTemp += WI.getStrValue((String)vRetResult.elementAt(i+6)," :: ","","");
			%>																	
      <td valign="top" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+11))%><br>&nbsp;<%=strTemp%></td>
      <td valign="top" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <%
				strTemp = "";
				for(iDetail = 0; iDetail < vAwardDetail.size(); iDetail += 10){%>
				<tr>
				<%
					strTemp = (String)vAwardDetail.elementAt(iDetail+1);
					strTemp += "-" + (String)vAwardDetail.elementAt(iDetail+2);
					strTemp += WI.getStrValue((String)vAwardDetail.elementAt(iDetail+4), " [", "]", "[--]");
				%>
          <td width="79%">&nbsp;<font size="1"><%=strTemp%></font></td>
          </tr>
				<%}%>
      </table></td>
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
      <td height="25">	  <div align="center"><font size="1">
	  </font><font size="2">Number of Employees / rows Per 
        Page :</font><font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select>
        </font><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click  to print List</font></div></td>
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