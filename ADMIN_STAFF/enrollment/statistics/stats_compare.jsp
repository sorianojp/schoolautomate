<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
	if(document.form_.prev_sy_from.value.length == 0) {
		alert("Please enter Previous School Year.");
		return;
	}
	if(document.form_.sy_from.value.length == 0) {
		alert("Please enter Current School Year.");
		return;
	}
	document.form_.print_page.value = "1";
	document.form_.submit();
}
function ReloadPage()
{
	document.form_.print_page.value = "";
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}
function CompareStat() {
	if(document.form_.prev_sy_from.value.length == 0) {
		alert("Please enter Previous School Year.");
		return;
	}
	if(document.form_.sy_from.value.length == 0) {
		alert("Please enter Current School Year.");
		return;
	}
	
	//if it is per year level, i have to popup another..
	if(document.form_.show_per_yr && document.form_.show_per_yr.checked) {
		//I have to now pop up the comparision page.. 
		var pgLoc = "./stat_compare_peryear.jsp?sy_from="+document.form_.sy_from.value+
		"&prev_sy_from="+document.form_.prev_sy_from.value+
		"&prev_semester="+document.form_.prev_semester[document.form_.prev_semester.selectedIndex].value+
		"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value;
		var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
		return;
	}
	
	document.form_.print_page.value = "";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.StatEnrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	if(WI.fillTextValue("print_page").compareTo("1") == 0){%>
		<jsp:forward page="./stats_compare_print.jsp" />
	<%}
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS-ENROLLEES","statistics_enrollees.jsp");
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
														"Enrollment","STATISTICS",request.getRemoteAddr(),
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

//end of authenticaion code.
StatEnrollment SE = new StatEnrollment();
Vector vRetResult = null;
Vector vRetResultBasic = null;
if(WI.fillTextValue("reloadPage").length() > 0 && WI.fillTextValue("reloadPage").compareTo("1") !=0) {
	
	//System.out.println(SE.getEnrolleeStatComparePerYrLevel(dbOP, request));
	//System.out.println(SE.getErrMsg());
	
	vRetResult = SE.getEnrolleeStatCompare(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SE.getErrMsg();
	
	if(WI.fillTextValue("show_basic").equals("1"))
		vRetResultBasic = SE.getEnrolleeStatCompareBasic(dbOP, request);
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form action="./stats_compare.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          STATISTICS COMPARISON - ENROLEES PAGE ::::</strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"></td>
      <td colspan="5"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td height="25" width="2%"></td>
      <td width="24%" valign="bottom"><font size="1"><strong>STUDENT STATUS</strong></font></td>
      <td width="10%" valign="bottom"><font size="1"><strong>PREV YEAR</strong></font></td>
      <td width="29%" valign="bottom"><font size="1"><strong>PREV TERM</strong></font></td>
      <td width="12%" valign="bottom"><font size="1"><strong>CURRENT YEAR</strong></font></td>
      <td width="23%" valign="bottom"><font size="1"><strong>TERM</strong></font></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td> 
        <select name="status_index">
          <option value="">ALL</option>
<%
strTemp = WI.fillTextValue("status_index");
if(strTemp.compareTo("-1") == 0){%>
          <option value="-1" selected>ALL OLD</option>
<%}else{%>
          <option value="-1">ALL OLD</option>
<%}if(strTemp.compareTo("-2") ==0){%>
          <option value="-2" selected>ALL NEW</option>
<%}else{%>
          <option value="-2">ALL NEW</option>
<%}%>
          <%=dbOP.loadCombo("status_index","status"," from user_status where is_for_student = 1 order by status asc",
					strTemp, false)%> </select></td>
      <td> <%
strTemp = WI.fillTextValue("prev_sy_from");
%> <input name="prev_sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
      <td><select name="prev_semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("prev_semester");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")) { 
		    if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}
		  }
		  
		  if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> 
      <td> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
      <td><select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")) {
		  	if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}
		  }
		  
		  if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></tr>
<%if(strSchCode.startsWith("UDMC")){%>
    <tr> 
      <td height="22"></td>
      <td style="font-size:9px" align="right">Enter Comparison Date : &nbsp;&nbsp;&nbsp;</td>
      <td><input name="date_prev" type="text" size="10" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_prev")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:9px;"></td>
      <td><a href="javascript:show_calendar('form_.date_prev');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td><input name="date_cur" type="text" size="10" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_cur")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:9px;"></td>
      <td><a href="javascript:show_calendar('form_.date_cur');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
<%}else{%>
    <tr> 
      <td height="22"></td>
      <td style="font-size:9px" align="right">&nbsp;&nbsp;&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>

<%}%>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25"></td>
      <td width="23%"><strong>Show By :</strong></td>
      <td width="75%">&nbsp;</td>
    </tr>
<!-- not need for now.. 
    <tr> 
      <td height="25"></td>
      <td>Previous School Type</td>
      <td><select name="school_type">
          <option value="">ALL</option>
          <option value="0">Private</option>
 <%
// strTemp = WI.fillTextValue("school_type");
// if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Public</option>
 <%//}else{%>
          <option value="1">Public</option>
 <%//}%>       </select>
        (not working now -- to be linked to update school list)</td>
    </tr>
--> 
    <tr> 
      <td height="25"></td>
      <td>College/School </td>
      <td><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 and c_name not like '%basic%' order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select>
		<% strTemp = WI.fillTextValue("show_basic");
		   if (strTemp.equals("1")) 	
		   		strTemp = "checked";
			else
				strTemp = ""; %>
		   	
				<input type="checkbox" value="1" name="show_basic" <%=strTemp%>>
				<font size="1">Include Basic Education </font></td>
    </tr>
    <tr> 
      <td ></td>
      <td>Course</td>
      <td><select name="course_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("c_index");
if(strTemp.length() > 0){%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and c_index="+strTemp+" order by course_name asc",
		  		request.getParameter("course_index"), false)%> 
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>Major</td>
      <td><select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.compareTo("0") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>Year Level</td>
      <td><select name="year_level">
          <option value="">All</option>
          <%
strTemp =WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="26"></td>
      <td>Gender</td>
      <td><select name="gender">
          <option value="">All</option>
<%
strTemp = WI.fillTextValue("gender");
if(strTemp.compareTo("M") ==0){%>
          <option value="M" selected>Male</option>
          <%}else{%>
          <option value="M">Male</option>
          <%}if(strTemp.compareTo("F") ==0){%>
          <option value="F" selected>Female</option>
          <%}else{%>
          <option value="F">Female</option>
          <%}%>
        </select> 
		<%if(strSchCode.startsWith("UDMC")){%>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<font style="font-size:11px; font-weight:bold; color:#0000FF">
		<input type="checkbox" value="1" name="show_per_yr"> Show Comparison per Year Level/Course
		<%}%>
		</font>
		</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>Age</td>
      <td><select name="age_con">
          <option value="0">Equal to</option>
          <%
strTemp = WI.fillTextValue("age_con");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Less than</option>
          <%}else{%>
          <option value="1">Less than</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>More than</option>
          <%}else{%>
          <option value="2">More than</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>Between</option>
          <%}else{%>
          <option value="3">Between</option>
          <%}%>
        </select> <input name="age_fr" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("age_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <input name="age_to" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("age_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="2">
	  <a href="javascript:CompareStat();">
	  	<img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<%if (vRetResultBasic != null) {

	// I have to keep track of course programs, course, and major.
	String strCourseProgram = null;
	String strCourseName    = null;
	String strMajorName     = null;

	//displays the coruse name and major name only if major and course names are different :-)
	String strCourseNameToDisp = null;
	String strMajorNameToDisp  = null;

	String strPrevYrM = null;
	String strPrevYrF = null;
	String strCurYrM = null;
	String strCurYrF = null;
	
	String strPrevSY  = WI.fillTextValue("prev_sy_from");
	String strPrevSem = WI.fillTextValue("prev_semester");
	String strSY      = WI.fillTextValue("sy_from");
	String strSem     = WI.fillTextValue("semester");
	
	
	int iSubGrandTotalPrevSY = 0; 
	int iSubGrandTotalCurSY = 0; 
	
	int iSubTotalPrevSY = 0;
	int iSubTotalCurSY = 0;
	
	int iGTPrevSY = 0; 
	int iGTSY = 0;
	String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};


	
	iSubGrandTotalPrevSY = 0; 
	iSubGrandTotalCurSY = 0;
%>

<table width="100%" cellpadding="1" cellspacing="1"  bgcolor="#000000">
    <tr> 
      <td height="20" colspan="7" bgcolor="#DBD8C8"><strong> &nbsp;BASIC EDUCATION</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="70%" rowspan="2"><div align="center"><strong><font size="1">EDUCATIONAL LEVEL </font></strong></div></td>
      <td colspan="3" align="center"><font size="1"><strong><%=WI.fillTextValue("prev_sy_from")%> <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("prev_semester"))]%></strong></font></td>
      <td height="24" colspan="3"><div align="center"><font size="1"><strong><%=WI.fillTextValue("sy_from")%> <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]%></strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center" width="4%"><font size="1"><strong>M</strong></font></td>
      <td align="center" width="4%"><font size="1"><strong>F</strong></font></td>
      <td align="center" width="7%"><strong><font size="1">TOTAL</font></strong></td>
      <td width="4%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="4%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="7%"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
    </tr>
    <%
	boolean bolIncremented = false;
	for(int i = 0 ; i < vRetResultBasic.size();){//Inner loop for course/major for a course program.
		bolIncremented = false;
		strCourseNameToDisp = (String)vRetResultBasic.elementAt(i);
		
		strPrevYrM = null;strPrevYrF = null;strCurYrM = null;strCurYrF = null;
	
	
	//collect information for each year level for a course/major.			
	
	if(i < vRetResultBasic.size() && strCourseNameToDisp.equals((String)vRetResultBasic.elementAt(i)) &&
		strPrevSY.equals((String)vRetResultBasic.elementAt(i + 3)) &&
		strPrevSem.equals((String)vRetResultBasic.elementAt(i + 4)) &&
		((String)vRetResultBasic.elementAt(i+1)).equals("M")) // Prev year. male.
	{
		strPrevYrM = (String)vRetResultBasic.elementAt(i+2);
		iSubTotalPrevSY += Integer.parseInt(strPrevYrM);
		bolIncremented = true;
		i += 5;
	}else{
		strPrevYrM = "0";
	}

	if(i < vRetResultBasic.size() && strCourseNameToDisp.equals((String)vRetResultBasic.elementAt(i)) &&
		strPrevSY.equals((String)vRetResultBasic.elementAt(i+3)) &&
		strPrevSem.equals((String)vRetResultBasic.elementAt(i+4))  &&
		!((String)vRetResultBasic.elementAt(i+1)).equals("M")) // Prev sy female
	{
		strPrevYrF = (String)vRetResultBasic.elementAt(i+2);
		iSubTotalPrevSY += Integer.parseInt(strPrevYrF);
		bolIncremented = true;
		i += 5;
	}else{
		strPrevYrF = "0";
	}


	if(i < vRetResultBasic.size() && strCourseNameToDisp.equals((String)vRetResultBasic.elementAt(i)) &&
		strSY.equals((String)vRetResultBasic.elementAt(i+3)) &&
		strSem.equals((String)vRetResultBasic.elementAt(i+4)) &&
		((String)vRetResultBasic.elementAt(i+1)).equals("M")) // Curr Year Male
	{
		strCurYrM = (String)vRetResultBasic.elementAt(i+2);
		iSubTotalCurSY += Integer.parseInt(strCurYrM);
		bolIncremented = true;
		i += 5;
	}else{
		strCurYrM = "0";
	}
	if(i < vRetResultBasic.size() && strCourseNameToDisp.equals((String)vRetResultBasic.elementAt(i)) &&
		strSY.equals((String)vRetResultBasic.elementAt(i+3)) &&
		strSem.equals((String)vRetResultBasic.elementAt(i+4)) &&
		!((String)vRetResultBasic.elementAt(i+1)).equals("M")) // Curr Year Female
	{
		strCurYrF = (String)vRetResultBasic.elementAt(i+2);
		iSubTotalCurSY += Integer.parseInt(strCurYrF);
		bolIncremented = true;
		i += 5;
	}else{
		strCurYrF = "0";
	}
	iSubGrandTotalPrevSY += iSubTotalPrevSY; 
	iSubGrandTotalCurSY += iSubTotalCurSY;
	%>
    <tr bgcolor="#FFFFFF"> 
      <td height="24"><font size="1"><%=strCourseNameToDisp%></font></td>
      <td><div align="center"><font size="1"><%=WI.getStrValue(strPrevYrM,"&nbsp;")%></font></div></td>
      <td><div align="center"><font size="1"><%=WI.getStrValue(strPrevYrF,"&nbsp;")%></font></div></td>
      <td><div align="right"><font size="1"><%=iSubTotalPrevSY%>&nbsp;</font></div></td>
      <td><div align="center"><font size="1"><%=WI.getStrValue(strCurYrM,"&nbsp;")%></font></div></td>
      <td><div align="center"><font size="1"><%=WI.getStrValue(strCurYrF,"&nbsp;")%></font></div></td>
      <td><div align="right"><font size="1"><%=iSubTotalCurSY%>&nbsp;</font></div></td>
    </tr>
    <%iSubTotalPrevSY = 0;iSubTotalCurSY = 0; 
		if (!bolIncremented) break; 
	}%>
    <tr bgcolor="#FFFFFF"> 
      <td height="24" align="right"><strong><font size="1">TOTAL</font> 
        &nbsp;&nbsp;</strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><font size="1"><%=iSubGrandTotalPrevSY%>&nbsp;</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><font size="1"><%=iSubGrandTotalCurSY%>&nbsp;</font></div></td>
    </tr>
  </table>
  
  
<%}

if(vRetResult != null){//System.out.println(vRetResult);
	// I have to keep track of course programs, course, and major.
	String strCourseProgram = null;
	String strCourseName    = null;
	String strMajorName     = null;

	//displays the coruse name and major name only if major and course names are different :-)
	String strCourseNameToDisp = null;
	String strMajorNameToDisp  = null;

	String strPrevYrM = null;
	String strPrevYrF = null;
	String strCurYrM = null;
	String strCurYrF = null;
	
	String strPrevSY  = WI.fillTextValue("prev_sy_from");
	String strPrevSem = WI.fillTextValue("prev_semester");
	String strSY      = WI.fillTextValue("sy_from");
	String strSem     = WI.fillTextValue("semester");
	
	int iSubGrandTotalPrevSY = 0; 
	int iSubGrandTotalCurSY = 0; 

	if (strSchCode.startsWith("UI")){
	
		if (strPrevSem.equals("0")){
			iSubGrandTotalPrevSY = Integer.parseInt(WI.getStrValue(strPrevSY,"0")) -1 ;
			strPrevSY = Integer.toString(iSubGrandTotalPrevSY);
		}
		
		if (strSem.equals("0")){
			iSubGrandTotalPrevSY = Integer.parseInt(WI.getStrValue(strSY,"0")) -1 ;
			strSY = Integer.toString(iSubGrandTotalPrevSY);
		}
	}
	
	iSubGrandTotalPrevSY = 0; 
	iSubGrandTotalCurSY = 0; 

	int iSubTotalPrevSY = 0;
	int iSubTotalCurSY = 0;
	
	int iGTPrevSY = 0; 
	int iGTSY = 0;
	String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};
	for(int i = 1 ; i< vRetResult.size() ;){//outer loop for each course program.
	strCourseProgram = (String)vRetResult.elementAt(i);
	strCourseName = null;
	
	iSubGrandTotalPrevSY = 0; 
	iSubGrandTotalCurSY = 0;
	%>
  <table  bgcolor="#000000" width="100%" cellspacing="1" cellpadding="1">
    <tr> 
      <td height="20" colspan="8" bgcolor="#DBD8C8"><strong>COLLEGE : <%=strCourseProgram%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="40%" rowspan="2"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
      <td rowspan="2" align="center"><strong></strong><strong><font size="1">MAJOR</font></strong></td>
      <td colspan="3" align="center"><font size="1"><strong><%=WI.fillTextValue("prev_sy_from")%> <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("prev_semester"))]%></strong></font></td>
      <td height="24" colspan="3"><div align="center"><font size="1"><strong><%=WI.fillTextValue("sy_from")%> <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]%></strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center" width="4%"><font size="1"><strong>M</strong></font></td>
      <td align="center" width="4%"><font size="1"><strong>F</strong></font></td>
      <td align="center" width="7%"><strong><font size="1">TOTAL</font></strong></td>
      <td width="4%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="4%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="7%"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
    </tr>
    <%
	for(int j = i; j< vRetResult.size();){//Inner loop for course/major for a course program.
	if(strCourseProgram.compareTo((String)vRetResult.elementAt(j)) != 0)
		break; //go back to main loop.
//System.out.println(strCourseName);
//System.out.println(strMajorName);

	if(strCourseName == null || strCourseName.compareTo((String)vRetResult.elementAt(j+1)) !=0)
	{
		strCourseName = (String)vRetResult.elementAt(j+1);
		strCourseNameToDisp = strCourseName;
		strMajorName = WI.getStrValue(vRetResult.elementAt(j+2));
		strMajorNameToDisp = strMajorName;
	}
	else if(strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0)//course name is same.
	{
		strCourseNameToDisp = "&nbsp;";
		if(strMajorName == null || strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2)) ) !=0)
		{
			strMajorName = WI.getStrValue(vRetResult.elementAt(j+2));
			strMajorNameToDisp = strMajorName;
		}
		else if(strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2)) ) ==0)
			strMajorNameToDisp = "&nbsp;";
	}
	strPrevYrM = null;strPrevYrF = null;strCurYrM = null;strCurYrF = null;
	
	
	//collect information for each year level for a course/major.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		strPrevSY.compareTo((String)vRetResult.elementAt(j + 5)) == 0 &&
		strPrevSem.compareTo((String)vRetResult.elementAt(j + 6)) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("M") ==0) // Prev year. male.
	{
		strPrevYrM = (String)vRetResult.elementAt(j+4);
		iSubTotalPrevSY += Integer.parseInt(strPrevYrM);
		j += 7;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		strPrevSY.compareTo((String)vRetResult.elementAt(j + 5)) == 0 &&
		strPrevSem.compareTo((String)vRetResult.elementAt(j + 6)) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("M") !=0) // Prev sy female
	{
		strPrevYrF = (String)vRetResult.elementAt(j+4);
		iSubTotalPrevSY += Integer.parseInt(strPrevYrF);
		j += 7;
	}
	//2nd year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		strSY.compareTo((String)vRetResult.elementAt(j + 5)) == 0 &&
		strSem.compareTo((String)vRetResult.elementAt(j + 6)) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("M") ==0) // 1st year. male.
	{
		strCurYrM = (String)vRetResult.elementAt(j+4);
		iSubTotalCurSY += Integer.parseInt(strCurYrM);
		j += 7;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		strSY.compareTo((String)vRetResult.elementAt(j + 5)) == 0 &&
		strSem.compareTo((String)vRetResult.elementAt(j + 6)) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("M") !=0) // 1st year. male.
	{
		strCurYrF = (String)vRetResult.elementAt(j+4);
		iSubTotalCurSY += Integer.parseInt(strCurYrF);
		j += 7;
	}
	iSubGrandTotalPrevSY += iSubTotalPrevSY; 
	iSubGrandTotalCurSY += iSubTotalCurSY;
	
i = j;

	%>
    <tr bgcolor="#FFFFFF"> 
      <td height="24"><font size="1"><%=strCourseNameToDisp%></font></td>
      <td><font size="1"><%=WI.getStrValue(strMajorNameToDisp,"&nbsp;")%></font></td>
      <td><div align="center"><font size="1"><%=WI.getStrValue(strPrevYrM,"&nbsp;")%></font></div></td>
      <td><div align="center"><font size="1"><%=WI.getStrValue(strPrevYrF,"&nbsp;")%></font></div></td>
      <td><div align="right"><font size="1"><%=iSubTotalPrevSY%>&nbsp;</font></div></td>
      <td><div align="center"><font size="1"><%=WI.getStrValue(strCurYrM,"&nbsp;")%></font></div></td>
      <td><div align="center"><font size="1"><%=WI.getStrValue(strCurYrF,"&nbsp;")%></font></div></td>
      <td><div align="right"><font size="1"><%=iSubTotalCurSY%>&nbsp;</font></div></td>
    </tr>
    <%iSubTotalPrevSY = 0;iSubTotalCurSY = 0; }%>
    <tr bgcolor="#FFFFFF"> 
      <td height="24" colspan="2" align="right"><strong><font size="1">TOTAL</font> 
        &nbsp;&nbsp;</strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><font size="1"><%=iSubGrandTotalPrevSY%>&nbsp;</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><font size="1"><%=iSubGrandTotalCurSY%>&nbsp;</font></div></td>
    </tr>
    <%
 	iGTPrevSY += iSubGrandTotalPrevSY; 
	iGTSY += iSubGrandTotalCurSY;
	iSubGrandTotalPrevSY = 0; iSubGrandTotalCurSY = 0;}//outer most loop%>
    <tr bgcolor="#FFFFFF"> 
      <td height="24" colspan="2" align="right"><strong><font size="1" color="#0000FF">GRAND 
        TOTAL</font> &nbsp;&nbsp;</strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><font size="1" color="#0000FF"><%=iGTPrevSY%>&nbsp;</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><font size="1" color="#0000FF"><%=iGTSY%>&nbsp;</font></div></td>
    </tr>
  </table>
<%}//only if vRetResult is not null
%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print statement of account</font></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
