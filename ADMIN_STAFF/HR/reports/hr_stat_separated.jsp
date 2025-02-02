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
function ViewServiceRecord(strIDNumber){
	var pgLoc = "../personnel/hr_personnel_service_rec.jsp?show_concurrent=1&emp_id="+strIDNumber;	
	var win=window.open(pgLoc,"ViewServiceRecord",'width=900,height=500,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function PrintPg()
{
	document.form_.print_page.value="1";
	document.form_.show_list.value="1";
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
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";

	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./hr_stat_separated_print.jsp" />
<% return;	}
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_stat_separated.jsp");

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

String[] astrSortByName    = {"Employee ID", "Last Name","First Name","Emp. Status","Separation Date"	};
String[] astrSortByVal     = {"id_number","lname","fname","status", "VALIDITY_DATE_TO" };//Resignation_date is saved in valid_date_to field.
Vector vRetResult = null;

if (WI.fillTextValue("show_list").equals("1")){
	vRetResult = hrStat.hrStatSeparated(dbOP);	
	if (vRetResult != null)
		iSearchResult = hrStat.getSearchCount();
	else
		strErrMsg = hrStat.getErrMsg();
}
%>
<form action="./hr_stat_separated.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: SEPARATED EMPLOYEES ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFF0F0">
    <tr> 
      <td height="25" colspan="2" class="fontsize10"><div align="center"><strong><font color="#FF0000"><u>EMPLOYMENT DETAILS</u></font></strong></div></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10" width="16%"> &nbsp;Position</td>
      <td><select name="emp_type_index">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("emp_type_index", "emp_type_name"," from hr_employment_type where is_del =0 order by emp_type_name",WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td><select name="c_index" onChange="ReloadPage()">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Dept / Office </td>
      <td><select name="d_index">
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
      <td><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
        (enter office/dept's first few characters) </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFF0">
    <tr valign="top"> 
      <td height="25" colspan="2" class="fontsize10"> <div align="center"><font color="#FF0000"><strong><u>SEPARATION DETAILS</u></strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10" width="16%">&nbsp;Major Reason</td>
      <td> <select name="reason_index">
          <option value="">&nbsp;</option>
          <%=dbOP.loadCombo("reason_index", "EXIT_INTV_REASON", " from HR_PRELOAD_EXIT_INTV_REASON order by EXIT_INTV_REASON", WI.fillTextValue("reason_index"),false)%> </select> <%%></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Date of Separation</td>
      <td><input type="text" name="date_from" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="10" value="<%=WI.fillTextValue("date_from")%>"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        &nbsp;&nbsp;-- &nbsp;&nbsp; <input type="text" name="date_to" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="10"
		value="<%=WI.fillTextValue("date_to")%>"> <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="16%">Sort by</td>
      <td width="27%"><select name="sort_by1" style="font-size:9px;">
          <option value="">N/A</option>
      <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="29%"><select name="sort_by2" style="font-size:9px;">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="28%"><select name="sort_by3" style="font-size:9px;">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><select name="sort_by1_con" style="font-size:9px;">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by2_con" style="font-size:9px;">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con" style="font-size:9px;">
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
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:showList()"%><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
  </table>

<% if (vRetResult != null && vRetResult.size() > 0) {%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp; </td>
      <td height="25" align="right">
	  <input type="checkbox" name="show_all" value="checked" <%=WI.fillTextValue("show_all")%>>
	  Show All 
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
      <td width="51%" align="right">&nbsp;
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
      <td width="15%" height="25"  class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></div></td>
      <td width="7%"  class="thinborder"><div align="center"><font size="1"><strong>Dept/office</strong></font></div></td>
<% if (strSchCode.startsWith("AUF")) {%> 
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>DATE FROM </strong></font></td>
<%
	strTemp ="DATE TO";
}else{
	strTemp ="Date of Separation"; 
}%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1"><%=strTemp%></font></strong></td>
<% if (strSchCode.startsWith("AUF")) {%> 
      <td width="7%" align="center" class="thinborder"><strong><font size="1">YEARS OF SERVICE</font></strong></td>
<%}%>
      <td width="8%" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
      <td width="8%" class="thinborder"><font size="1"><strong>STATUS</strong></font></td>
      <td width="7%" class="thinborder"><font size="1"><strong>RANK</strong></font></td>
      <td width="12%" class="thinborder"><font size="1"><strong>MAIN REASON</strong></font></td>
      <td width="9%" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
<% if (strSchCode.startsWith("LHS")) {%> 
	<td width="5%" class="thinborder"><font size="1"><strong>VIEW</strong></font></td>
<%}%>
    </tr>
    <% String strCurrentUserIndex = null;
		for (int i=0; i < vRetResult.size(); i+=25){
			strCurrentUserIndex = (String)vRetResult.elementAt(i);
	%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),
	  													(String)vRetResult.elementAt(i+2),
					 	  							    (String)vRetResult.elementAt(i+3),4)%></td>
      <% 
		strTemp = (String)vRetResult.elementAt(i+4);
		if (strTemp == null) 
			strTemp = (String)vRetResult.elementAt(i+5);
	
	%>
      <td class="thinborder"> <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
<% if (strSchCode.startsWith("AUF")) {%> 
      <td class="thinborder"><%=WI.formatDate((String)vRetResult.elementAt(i+6),10)%></td>
<%}%>
      <td class="thinborder"><%=WI.formatDate((String)vRetResult.elementAt(i+7),10)%></td>
<% if (strSchCode.startsWith("AUF")) {%> 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+14)%></td>
<%}%>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+9)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"&nbsp;")%></td>
	  <% 
		if ((i+15 < vRetResult.size() && 
				!strCurrentUserIndex.equals((String)vRetResult.elementAt(i+15)))
			|| (i+15 >= vRetResult.size()))
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11),"&nbsp;");
		else
			strTemp = "&nbsp;";
	  %> 
	  
      <td class="thinborder"><%=strTemp%></td>
	  <% 
		if ((i+15 < vRetResult.size() && 
				!strCurrentUserIndex.equals((String)vRetResult.elementAt(i+15)))
			|| (i+15 >= vRetResult.size()))
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12),"&nbsp;");
		else
			strTemp = "&nbsp;";
	  %> 

      <td class="thinborder"><%=strTemp%></td>
<%if(strSchCode.startsWith("LHS")){%> 
	<td class="thinborder" align="center"><a href="javascript:ViewServiceRecord('<%=(String)vRetResult.elementAt(i+15)%>')">
		<img src="../../../images/view.gif" border="0"></a></td>
<%}%>
    </tr>
    <%}// end for loop%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <% if (vRetResult!= null && vRetResult.size() > 0) {%>
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
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